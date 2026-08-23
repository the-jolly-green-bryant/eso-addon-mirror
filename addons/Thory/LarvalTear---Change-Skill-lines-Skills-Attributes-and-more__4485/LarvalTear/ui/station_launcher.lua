local Addon = LarvalTearMod
local LTM_UI = Addon.UI
local StationLauncher = Addon.UI.StationLauncher

local STATION_INTERACT_EVENT_NAME = "LTM_UI_StationLauncher_StationInteract"
local STATION_END_EVENT_NAME = "LTM_UI_StationLauncher_StationEnd"

local activeStationType = nil
local activeLauncherContexts = {}
local registeredLauncherContexts = {}
local keybindGroupAdded = false
local keybindGroupStripId = nil
local supportedUiRegistrationRetryCount = 0
local SUPPORTED_UI_REGISTRATION_RETRY_MAX = 30
local SUPPORTED_UI_REGISTRATION_RETRY_INTERVAL_MS = 1000

local function IsGamepadPreferredMode()
    return type(IsInGamepadPreferredMode) == "function" and IsInGamepadPreferredMode() == true
end

local function IsSupportedStationType(craftingType)
    if craftingType == nil then
        return false
    end

    return craftingType == rawget(_G, "CRAFTING_TYPE_ALCHEMY")
        or craftingType == rawget(_G, "CRAFTING_TYPE_ENCHANTING")
        or craftingType == rawget(_G, "CRAFTING_TYPE_SCRIBING")
end

local function IsKeybindStripAvailable()
    return type(KEYBIND_STRIP) == "table"
        and type(KEYBIND_STRIP.AddKeybindButtonGroup) == "function"
        and type(KEYBIND_STRIP.RemoveKeybindButtonGroup) == "function"
end

local function GetCurrentKeybindStripId()
    local championPerks = rawget(_G, "CHAMPION_PERKS")
    if activeLauncherContexts.champion == true
        and type(championPerks) == "table"
        and championPerks.keybindStripId ~= nil then
        return championPerks.keybindStripId
    end

    return nil
end

local function IsWaitingForChampionKeybindStripId()
    local championPerks = rawget(_G, "CHAMPION_PERKS")
    return activeLauncherContexts.champion == true
        and type(championPerks) == "table"
        and championPerks.keybindStripId == nil
end

local function HasActiveLauncherContext()
    for _, active in pairs(activeLauncherContexts) do
        if active == true then
            return true
        end
    end

    return false
end

local function ShouldOpenQuickSettings()
    return activeLauncherContexts.craft_station == true or activeLauncherContexts.quickslot == true
end

local function OpenLarvalTearFromSupportedSurface()
    if IsGamepadPreferredMode() then
        return
    end

    LTM_UI:ShowMainWindow()
    if ShouldOpenQuickSettings() then
        LTM_UI:SetMainTab("quick_settings")
    end
end

local keybindDescriptor = {
    alignment = KEYBIND_STRIP_ALIGN_LEFT,
    {
        name = "LarvalTear",
        keybind = "LTM_PRIMARY_SHORTCUT",
        callback = OpenLarvalTearFromSupportedSurface,
        visible = function()
            return HasActiveLauncherContext() and not IsGamepadPreferredMode()
        end,
    },
}

local function AddStationKeybindGroup()
    if keybindGroupAdded == true or not IsKeybindStripAvailable() then
        return
    end
    if IsWaitingForChampionKeybindStripId() then
        return
    end

    keybindGroupStripId = GetCurrentKeybindStripId()
    KEYBIND_STRIP:AddKeybindButtonGroup(keybindDescriptor, keybindGroupStripId)
    keybindGroupAdded = true
end

local function RemoveStationKeybindGroup()
    if keybindGroupAdded ~= true or not IsKeybindStripAvailable() then
        keybindGroupAdded = false
        return
    end

    KEYBIND_STRIP:RemoveKeybindButtonGroup(keybindDescriptor, keybindGroupStripId)
    keybindGroupAdded = false
    keybindGroupStripId = nil
end

local function OnStationOpen(_, craftingType)
    if not IsSupportedStationType(craftingType) then
        return
    end

    activeStationType = craftingType
    activeLauncherContexts.craft_station = true
    if IsGamepadPreferredMode() then
        RemoveStationKeybindGroup()
        return
    end

    AddStationKeybindGroup()
end

local function OnStationClose()
    activeStationType = nil
    activeLauncherContexts.craft_station = nil
    RemoveStationKeybindGroup()
end

local function OnSupportedSceneShowing(contextKey)
    activeLauncherContexts[contextKey] = true
    if IsGamepadPreferredMode() then
        RemoveStationKeybindGroup()
        return
    end

    AddStationKeybindGroup()
    if contextKey == "champion" and type(zo_callLater) == "function" then
        zo_callLater(function()
            if activeLauncherContexts.champion == true and keybindGroupAdded ~= true then
                AddStationKeybindGroup()
            end
        end, 1)
    end
end

local function OnSupportedSceneHidden(contextKey)
    activeLauncherContexts[contextKey] = nil
    if not HasActiveLauncherContext() then
        RemoveStationKeybindGroup()
    end
end

local function RegisterSceneCallbacks(sceneName, contextKey)
    if registeredLauncherContexts[contextKey] == true then
        return true
    end
    if type(SCENE_MANAGER) ~= "table" or type(SCENE_MANAGER.GetScene) ~= "function" then
        return false
    end

    local scene = SCENE_MANAGER:GetScene(sceneName)
    if type(scene) ~= "table" or type(scene.RegisterCallback) ~= "function" then
        return false
    end

    scene:RegisterCallback("StateChange", function(_, newState)
        if newState == SCENE_SHOWING or newState == SCENE_SHOWN then
            OnSupportedSceneShowing(contextKey)
        elseif newState == SCENE_HIDING or newState == SCENE_HIDDEN then
            OnSupportedSceneHidden(contextKey)
        end
    end)
    registeredLauncherContexts[contextKey] = true
    return true
end

local function RegisterQuickslotFragmentCallback()
    if registeredLauncherContexts.quickslot == true then
        return true
    end
    if type(KEYBOARD_QUICKSLOT_FRAGMENT) ~= "table" or type(KEYBOARD_QUICKSLOT_FRAGMENT.RegisterCallback) ~= "function" then
        return false
    end

    KEYBOARD_QUICKSLOT_FRAGMENT:RegisterCallback("StateChange", function(_, newState)
        if newState == SCENE_FRAGMENT_SHOWING or newState == SCENE_FRAGMENT_SHOWN then
            OnSupportedSceneShowing("quickslot")
        elseif newState == SCENE_FRAGMENT_HIDING or newState == SCENE_FRAGMENT_HIDDEN then
            OnSupportedSceneHidden("quickslot")
        end
    end)

    if type(KEYBOARD_QUICKSLOT_FRAGMENT.IsShowing) == "function" and KEYBOARD_QUICKSLOT_FRAGMENT:IsShowing() == true then
        OnSupportedSceneShowing("quickslot")
    end

    registeredLauncherContexts.quickslot = true
    return true
end

local function RegisterSupportedUiCallbacks()
    local skillsRegistered = RegisterSceneCallbacks("skills", "skills")
    local championRegistered = RegisterSceneCallbacks("championPerks", "champion")
    local quickslotRegistered = RegisterQuickslotFragmentCallback()

    return skillsRegistered == true and championRegistered == true and quickslotRegistered == true
end

local function RefreshCurrentSupportedUiState()
    if type(SCENE_MANAGER) == "table" and type(SCENE_MANAGER.IsShowing) == "function" then
        if SCENE_MANAGER:IsShowing("skills") == true then
            activeLauncherContexts.skills = true
        end
        if SCENE_MANAGER:IsShowing("championPerks") == true then
            activeLauncherContexts.champion = true
        end
    end
    if type(KEYBOARD_QUICKSLOT_FRAGMENT) == "table"
        and type(KEYBOARD_QUICKSLOT_FRAGMENT.IsShowing) == "function"
        and KEYBOARD_QUICKSLOT_FRAGMENT:IsShowing() == true then
        activeLauncherContexts.quickslot = true
    end

    if HasActiveLauncherContext() and not IsGamepadPreferredMode() then
        AddStationKeybindGroup()
    end
end

local function RegisterStationEvents()
    if EVENT_MANAGER == nil or type(EVENT_MANAGER.RegisterForEvent) ~= "function" then
        return false
    end

    local stationInteractEvent = rawget(_G, "EVENT_CRAFTING_STATION_INTERACT")
    local stationEndEvent = rawget(_G, "EVENT_END_CRAFTING_STATION_INTERACT")
    if stationInteractEvent == nil or stationEndEvent == nil then
        return false
    end

    EVENT_MANAGER:RegisterForEvent(STATION_INTERACT_EVENT_NAME, stationInteractEvent, OnStationOpen)
    EVENT_MANAGER:RegisterForEvent(STATION_END_EVENT_NAME, stationEndEvent, OnStationClose)
    return true
end

local function RegisterSupportedUiCallbacksOnce()
    if StationLauncher.supportedUiCallbacksRegistered == true then
        return
    end

    local allRegistered = RegisterSupportedUiCallbacks()
    RefreshCurrentSupportedUiState()
    if allRegistered == true then
        StationLauncher.supportedUiCallbacksRegistered = true
        return
    end

    if type(zo_callLater) ~= "function" or supportedUiRegistrationRetryCount >= SUPPORTED_UI_REGISTRATION_RETRY_MAX then
        return
    end

    supportedUiRegistrationRetryCount = supportedUiRegistrationRetryCount + 1
    zo_callLater(RegisterSupportedUiCallbacksOnce, SUPPORTED_UI_REGISTRATION_RETRY_INTERVAL_MS)
end

function StationLauncher:Initialize()
    if self.initialized == true then
        return false
    end
    self.initialized = true
    RegisterStationEvents()
    RegisterSupportedUiCallbacksOnce()
    return true
end
