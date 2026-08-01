local ADDON_NAME = "ScreenshotMode"
ScreenshotMode = {}

local nextEventHandleIndex = 1

local function RegisterForEvent(event, callback)
    local eventHandleName = ADDON_NAME .. nextEventHandleIndex
    EVENT_MANAGER:RegisterForEvent(eventHandleName, event, callback)
    nextEventHandleIndex = nextEventHandleIndex + 1
    return eventHandleName
end

local function UnregisterForEvent(event, name)
    EVENT_MANAGER:UnregisterForEvent(name, event)
end

local function WrapFunction(object, functionName, wrapper)
    if(type(object) == "string") then
        wrapper = functionName
        functionName = object
        object = _G
    end
    local originalFunction = object[functionName]
    object[functionName] = function(...) return wrapper(originalFunction, ...) end
end

local function OnAddonLoaded(callback)
    local eventHandle = ""
    eventHandle = RegisterForEvent(EVENT_ADD_ON_LOADED, function(event, name)
        if(name ~= ADDON_NAME) then return end
        callback()
        UnregisterForEvent(event, name)
    end)
end

-----------------------------------------------------------------------
local UPDATE_TIME = 50 --ms, setting the frame position won't work at faster update rates

local CAMERA_MIN_VERTICAL_OFFSET = -0.3 -- we can set below this value, but it won't move the camera
local CAMERA_MAX_VERTICAL_OFFSET = 0.5
local CAMERA_VERTICAL_OFFSET_DELTA = 0.04

local CAMERA_MIN_HORIZONTAL_OFFSET = -1
local CAMERA_MAX_HORIZONTAL_OFFSET = 1
local CAMERA_HORIZONTAL_OFFSET_DELTA = 0.04

local CAMERA_MIN_HORIZONTAL_POSITION_MULTIPLIER = -1
local CAMERA_MAX_HORIZONTAL_POSITION_MULTIPLIER = 1
local CAMERA_HORIZONTAL_POSITION_MULTIPLIER_DELTA = 0.04

local CAMERA_MIN_FOV = 35
local CAMERA_MAX_FOV = 65
local CAMERA_FOV_DELTA = 1

local MAX_FRAME_POSITION = 1
local MIN_FRAME_POSITION = 0
local FRAME_POSITION_DELTA = 0.02

local INGAME_GUI_NAME = "ingame"
local ACTION_LAYER_NAME = "Screenshot Mode"
local INTERCEPT_LAYER_NAME = "SceneChangeInterceptLayer"
local ACTIONS = {
    TOGGLE_SCREENSHOT_MODE = {
        label = "Toggle Screenshot Mode",
    },
	SCM_COMBOSHOT = {
		label = "Toggle UI and Take Screenshot",
	},
}
local DESIRED_SETTINGS = {
    [SETTING_TYPE_UI] = {
        [UI_SETTING_SHOW_QUEST_BESTOWER_INDICATORS] = false,
        [UI_SETTING_SHOW_FRAMERATE] = false,
        [UI_SETTING_SHOW_LATENCY] = false,
    },
    [SETTING_TYPE_NAMEPLATES] = {
        [NAMEPLATE_TYPE_ALL_HEALTHBARS] = false,
        [NAMEPLATE_TYPE_ALL_NAMEPLATES] = false,
        [NAMEPLATE_TYPE_ALLIANCE_INDICATORS] = NAMEPLATE_CHOICE_NEVER,
        [NAMEPLATE_TYPE_GROUP_INDICATORS] = false,
        [NAMEPLATE_TYPE_RESURRECT_INDICATORS] = false,
        [NAMEPLATE_TYPE_FOLLOWER_INDICATORS] = false,
    },
    [SETTING_TYPE_COMBAT] = {
        [COMBAT_SETTING_SCROLLING_COMBAT_TEXT_ENABLED] = false,
    },
    [SETTING_TYPE_CHAT_BUBBLE] = {
        [CHAT_BUBBLE_SETTING_ENABLED] = false,
    },
    [SETTING_TYPE_IN_WORLD] = {
        [IN_WORLD_UI_SETTING_TARGET_GLOW_ENABLED] = false,
        [IN_WORLD_UI_SETTING_INTERACTABLE_GLOW_ENABLED] = false,
    }
}

local displayName = GetDisplayName()
local characterName = GetUnitName("player")
local characterPortraitMode = false
local guiHiddenBefore = false
local savedSettings

local function SaveSettings()
    for system, entry in pairs(savedSettings) do
        for settingId, value in pairs(entry) do
            if(type(value) == "boolean") then
                savedSettings[system][settingId] = GetSetting_Bool(system, settingId)
            else
                savedSettings[system][settingId] = tonumber(GetSetting(system, settingId))
            end
        end
    end
end

local function ApplyCustomSettings(settings)
    for system, entry in pairs(settings) do
        for settingId, value in pairs(entry) do
            SetSetting(system, settingId, tostring(value))
        end
    end
end

local function OnGuiHidden()
	SetFullscreenEffect(FULLSCREEN_EFFECT_NONE)
    if (GetGuiHidden(INGAME_GUI_NAME)) then
        SaveSettings()
        ApplyCustomSettings(DESIRED_SETTINGS)
        SetFloatingMarkerGlobalAlpha(0)
        PushActionLayerByName(INTERCEPT_LAYER_NAME)
        PushActionLayerByName(ACTION_LAYER_NAME)
       
    else
        ApplyCustomSettings(savedSettings)
        SetFloatingMarkerGlobalAlpha(1)
        RemoveActionLayerByName(ACTION_LAYER_NAME)
        RemoveActionLayerByName(INTERCEPT_LAYER_NAME)
        EVENT_MANAGER:UnregisterForUpdate(ACTION_LAYER_NAME)

        if(characterPortraitMode) then
            SetFrameLocalPlayerInGameCamera(false)
            SetFullscreenEffect(FULLSCREEN_EFFECT_NONE)
            characterPortraitMode = false
        end
    end
end


function ScreenshotMode.ToggleScreenshotMode()
    if(characterPortraitMode) then
        SetFullscreenEffect(FULLSCREEN_EFFECT_NONE)
        if(not guiHiddenBefore and GetGuiHidden(INGAME_GUI_NAME)) then
            SetGuiHidden(INGAME_GUI_NAME, false)
        end
    else
        guiHiddenBefore = GetGuiHidden(INGAME_GUI_NAME)
        if(not guiHiddenBefore) then
            SetGuiHidden(INGAME_GUI_NAME, true)
        end
    end
    characterPortraitMode = not characterPortraitMode
    OnGuiHidden()
end

function ScreenshotMode.ComboShot()
	ScreenshotMode.ToggleScreenshotMode()
	zo_callLater(function() TakeScreenshot() end, 100)
	zo_callLater(function() ScreenshotMode.ToggleScreenshotMode() end, 200)
end

OnAddonLoaded(function()
    ScreenshotMode_SaveData = ScreenshotMode_SaveData or {}
    local userData = ScreenshotMode_SaveData[displayName] or {}
    ScreenshotMode_SaveData[displayName] = userData
    savedSettings = userData[characterName]
    if(not savedSettings) then
        savedSettings = ZO_DeepTableCopy(DESIRED_SETTINGS)
        savedSettings[SETTING_TYPE_CAMERA] = { -- we don't have a desired value for them, but still want to save their current state
            [CAMERA_SETTING_THIRD_PERSON_VERTICAL_OFFSET] = 0,
            [CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_OFFSET] = 0,
            [CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_POSITION_MULTIPLIER] = 0,
            [CAMERA_SETTING_FIRST_PERSON_FIELD_OF_VIEW] = 0,
            [CAMERA_SETTING_THIRD_PERSON_FIELD_OF_VIEW] = 0,
        }
        SaveSettings() -- initialize with the actual values
    else
        local updatedSavedSettings = {}
        for system, entry in pairs(DESIRED_SETTINGS) do
            updatedSavedSettings[system] = {}
            for settingId, value in pairs(entry) do
                if(savedSettings[system][settingId] == nil) then -- add newly added settings
                    updatedSavedSettings[system][settingId] = DESIRED_SETTINGS[system][settingId]
                else
                    updatedSavedSettings[system][settingId] = savedSettings[system][settingId]
                end
            end
        end
        savedSettings = updatedSavedSettings
    end
    userData[characterName] = savedSettings

    for name, data in pairs(ACTIONS) do
        ZO_CreateStringId(("SI_BINDING_NAME_%s"):format(name), data.label)
        if(data.defaultKey) then
            CreateDefaultActionBind(name, data.defaultKey)
        end
    end

    WrapFunction("ToggleShowIngameGui", function(originalToggleShowIngameGui)
        originalToggleShowIngameGui()
        OnGuiHidden()
    end)

    -- save and restore the settings when player is deactivated and activated, otherwise they may get messed up
    RegisterForEvent(EVENT_PLAYER_ACTIVATED, function()
        if(not GetGuiHidden(INGAME_GUI_NAME)) then
            ApplyCustomSettings(savedSettings)
        else
            ApplyCustomSettings(DESIRED_SETTINGS)
        end
    end)
    RegisterForEvent(EVENT_PLAYER_DEACTIVATED, function()
        if(not GetGuiHidden(INGAME_GUI_NAME)) then
            SaveSettings()
        end
    end)
end)
