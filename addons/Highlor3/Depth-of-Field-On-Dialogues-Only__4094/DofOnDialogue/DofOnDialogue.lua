local ADDON_NAME = "DofOnDialogue"
local Dof = {}
Dof.vars = nil

local L = DofOnDialogue_L  -- Grab localized strings

-- Depth of Field modes
local DoFModes = {
    ["Simple"] = 1,
    ["Smooth"] = 2,
    ["Circular"] = 3,
}

local DoFModeNames = {
    [1] = "Simple",
    [2] = "Smooth",
    [3] = "Circular",
}

-- Core DoF override
local function SetDepthOfFieldMode(modeIndex)
    local modeStr = tostring(modeIndex)
    SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DEPTH_OF_FIELD_MODE, modeStr)
    SetCVar("DEPTH_OF_FIELD_MODE", modeStr)
    SetCVar("DEPTH_OF_FIELD", "0")
    SetCVar("DepthofFieldSettingUpgraded", "1")

    zo_callLater(function()
        SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DEPTH_OF_FIELD_MODE, modeStr)
        SetCVar("DEPTH_OF_FIELD_MODE", modeStr)
        SetCVar("DEPTH_OF_FIELD", "0")
        SetCVar("DepthofFieldSettingUpgraded", "1")
    end, 100)
end

local function EnableDepthOfField()
    if not Dof.vars or not Dof.vars.enabled then return end
    SetDepthOfFieldMode(Dof.vars.selectedMode or 3)
end

local function DisableDepthOfField()
    if not Dof.vars or not Dof.vars.enabled then return end
    SetDepthOfFieldMode(0)
end

-- Event handlers
local function OnDialogueStart()
    EnableDepthOfField()
end

local function OnDialogueEnd()
    DisableDepthOfField()
end

-- LibAddonMenu config
local function CreateSettingsMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = L.ADDON_NAME,
        author = "Highlor3 & ChatGPT",
        version = "1.1.46c",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel(ADDON_NAME .. "Panel", panelData)

    local options = {
        {
            type = "checkbox",
            name = L.ADDON_ENABLED,
            tooltip = L.ADDON_ENABLED_TOOLTIP,
            getFunc = function() return Dof.vars.enabled end,
            setFunc = function(val) Dof.vars.enabled = val end,
            default = true,
        },
        {
            type = "dropdown",
            name = L.DOF_MODE,
            tooltip = L.DOF_MODE_TOOLTIP,
            choices = {"Simple", "Smooth", "Circular"},
            getFunc = function()
                return DoFModeNames[Dof.vars.selectedMode or 3] or "Circular"
            end,
            setFunc = function(choice)
                Dof.vars.selectedMode = DoFModes[choice] or 3
            end,
            default = "Circular",
            disabled = function() return not Dof.vars.enabled end,
        },
        {
            type = "checkbox",
            name = L.CRAFTING_ENABLED,
            tooltip = L.CRAFTING_ENABLED_TOOLTIP,
            getFunc = function() return Dof.vars.enableCrafting end,
            setFunc = function(val) Dof.vars.enableCrafting = val end,
            default = true,
            disabled = function() return not Dof.vars.enabled end,
        },
    }

    LAM:RegisterOptionControls(ADDON_NAME .. "Panel", options)
end

-- Initialization
local function OnAddonLoaded(event, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    Dof.vars = ZO_SavedVars:NewAccountWide("DofOnDialogueSaved", 1, nil, {
        enabled = true,
        selectedMode = 3,
        enableCrafting = true,
    })

    DisableDepthOfField()

    -- Dialogue & interaction events
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CHATTER_BEGIN, OnDialogueStart)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CHATTER_END, OnDialogueEnd)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CONVERSATION_UPDATED, OnDialogueStart)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_QUEST_OFFERED, OnDialogueStart)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_QUEST_COMPLETE_DIALOG, OnDialogueStart)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_SHOW_TALK_TO_INTERACTABLE, OnDialogueStart)

    -- Crafting stations
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CRAFTING_STATION_INTERACT, function(_, station)
        if Dof.vars.enableCrafting then
            EnableDepthOfField()
        end
    end)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_END_CRAFTING_STATION_INTERACT, function()
        if Dof.vars.enableCrafting then
            DisableDepthOfField()
        end
    end)

    CreateSettingsMenu()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
