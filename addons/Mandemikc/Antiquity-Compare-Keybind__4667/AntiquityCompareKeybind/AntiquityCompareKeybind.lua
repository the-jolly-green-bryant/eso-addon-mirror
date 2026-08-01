AntiquityCompareKeybind = AntiquityCompareKeybind or {}
local ACK = AntiquityCompareKeybind

local ADDON_NAME = "AntiquityCompareKeybind"
local SAVED_VARIABLES_NAME = "AntiquityCompareKeybindSavedVariables"
local VERSION = "1.2.2"
local SAVED_VARIABLES_VERSION = 2
local UPDATE_NAME = ADDON_NAME .. "_ShiftWatch"
local UPDATE_INTERVAL_MS = 50

local EVENT_MANAGER = EVENT_MANAGER
local GetString = GetString
local IsShiftKeyDown = IsShiftKeyDown
local ZO_SavedVars = ZO_SavedVars
local zo_callLater = zo_callLater

local defaults = {
    enabled = true,
    activationMethod = "shift",
    migratedFromGlobal = false,
}

local savedVariables
local activeTile
local comparisonWasAvailable = { false, false }
local customKeyHeld = false
local lastActivationState = false
local secondTooltipLayoutGeneration = 0
local IsActivationHeld

local function AnchorSecondComparisonTooltip()
    if not activeTile or not IsActivationHeld() then
        return
    end

    if ComparativeTooltip1:IsHidden() or ComparativeTooltip2:IsHidden() then
        return
    end

    ComparativeTooltip2:ClearAnchors()
    ComparativeTooltip2:SetAnchor(TOPRIGHT, ComparativeTooltip1, TOPLEFT, -12, 0)
end

local function ScheduleSecondComparisonLayout()
    if not comparisonWasAvailable[1] or not comparisonWasAvailable[2] then
        return
    end

    secondTooltipLayoutGeneration = secondTooltipLayoutGeneration + 1
    local generation = secondTooltipLayoutGeneration

    local function TryAnchor()
        if generation ~= secondTooltipLayoutGeneration then
            return
        end

        AnchorSecondComparisonTooltip()
    end

    TryAnchor()
    zo_callLater(TryAnchor, 1)
    zo_callLater(TryAnchor, 50)
    zo_callLater(TryAnchor, 100)
    zo_callLater(TryAnchor, 200)
end

local function SetComparisonVisibility(show)
    ComparativeTooltip1:SetHidden(not (show and comparisonWasAvailable[1]))
    ComparativeTooltip2:SetHidden(not (show and comparisonWasAvailable[2]))

    if show and comparisonWasAvailable[1] and comparisonWasAvailable[2] then
        ScheduleSecondComparisonLayout()
    end
end

local function CaptureComparisonState()
    comparisonWasAvailable[1] = not ComparativeTooltip1:IsHidden()
    comparisonWasAvailable[2] = not ComparativeTooltip2:IsHidden()
end

IsActivationHeld = function()
    if savedVariables.activationMethod == "shift" then
        return IsShiftKeyDown()
    end

    return customKeyHeld
end

local function ApplyCurrentState()
    if not activeTile then
        return
    end

    if not savedVariables.enabled then
        SetComparisonVisibility(true)
        return
    end

    local held = IsActivationHeld()
    lastActivationState = held
    SetComparisonVisibility(held)
end

local function StopShiftWatch()
    EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
end

local function StartShiftWatch()
    StopShiftWatch()

    if not activeTile or not savedVariables.enabled or savedVariables.activationMethod ~= "shift" then
        return
    end

    EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, UPDATE_INTERVAL_MS, function()
        local held = IsShiftKeyDown()
        if held ~= lastActivationState then
            lastActivationState = held
            SetComparisonVisibility(held)
        end
    end)
end

local function RefreshShiftWatch()
    if activeTile and savedVariables.enabled and savedVariables.activationMethod == "shift" then
        StartShiftWatch()
    else
        StopShiftWatch()
    end
end

local function OnTooltipShown(tile)
    activeTile = tile
    CaptureComparisonState()
    ApplyCurrentState()
    RefreshShiftWatch()
end

local function OnTooltipHidden(tile)
    if activeTile ~= tile then
        return
    end

    activeTile = nil
    comparisonWasAvailable[1] = false
    comparisonWasAvailable[2] = false
    customKeyHeld = false
    lastActivationState = false
    secondTooltipLayoutGeneration = secondTooltipLayoutGeneration + 1
    StopShiftWatch()
end

local function SetCustomKeyHeld(isHeld)
    customKeyHeld = isHeld

    if savedVariables.enabled and savedVariables.activationMethod == "custom" and activeTile then
        lastActivationState = isHeld
        SetComparisonVisibility(isHeld)
    end
end

function ACK.OnKeyDown()
    SetCustomKeyHeld(true)
end

function ACK.OnKeyUp()
    SetCustomKeyHeld(false)
end

local function GetLegacySettings()
    local rawSavedVariables = _G[SAVED_VARIABLES_NAME]
    local defaultNamespace = rawSavedVariables and rawSavedVariables.Default
    local accountData = defaultNamespace and defaultNamespace[GetDisplayName()]
    return accountData and accountData["$AccountWide"]
end

local function InitializeSavedVariables()
    local legacySettings = GetLegacySettings()

    savedVariables = ZO_SavedVars:NewAccountWide(
        SAVED_VARIABLES_NAME,
        SAVED_VARIABLES_VERSION,
        GetWorldName(),
        defaults
    )

    if savedVariables.migratedFromGlobal or type(legacySettings) ~= "table" then
        return
    end

    if type(legacySettings.enabled) == "boolean" then
        savedVariables.enabled = legacySettings.enabled
    end

    if legacySettings.activationMethod == "shift" or legacySettings.activationMethod == "custom" then
        savedVariables.activationMethod = legacySettings.activationMethod
    end

    savedVariables.migratedFromGlobal = true
end

local function CreateSettings()
    local panelData = {
        type = "panel",
        name = GetString(SI_ANTIQUITYCOMPAREKEYBIND_NAME),
        displayName = GetString(SI_ANTIQUITYCOMPAREKEYBIND_NAME),
        author = "Mandemikc",
        version = VERSION,
        registerForDefaults = true,
    }

    local optionsData = {
        {
            type = "checkbox",
            name = GetString(SI_ANTIQUITYCOMPAREKEYBIND_ENABLE),
            tooltip = GetString(SI_ANTIQUITYCOMPAREKEYBIND_ENABLE_TT),
            getFunc = function()
                return savedVariables.enabled
            end,
            setFunc = function(value)
                savedVariables.enabled = value
                ApplyCurrentState()
                RefreshShiftWatch()
            end,
            default = defaults.enabled,
            width = "full",
        },
        {
            type = "dropdown",
            name = GetString(SI_ANTIQUITYCOMPAREKEYBIND_METHOD),
            tooltip = GetString(SI_ANTIQUITYCOMPAREKEYBIND_METHOD_TT),
            choices = {
                GetString(SI_ANTIQUITYCOMPAREKEYBIND_SHIFT),
                GetString(SI_ANTIQUITYCOMPAREKEYBIND_CUSTOM),
            },
            choicesValues = {
                "shift",
                "custom",
            },
            getFunc = function()
                return savedVariables.activationMethod
            end,
            setFunc = function(value)
                savedVariables.activationMethod = value
                customKeyHeld = false
                lastActivationState = false
                ApplyCurrentState()
                RefreshShiftWatch()
            end,
            default = defaults.activationMethod,
            width = "full",
        },
        {
            type = "description",
            text = GetString(SI_ANTIQUITYCOMPAREKEYBIND_INSTRUCTIONS),
            width = "full",
        },
    }

    local panelName = ADDON_NAME .. "Options"
    LibAddonMenu2:RegisterAddonPanel(panelName, panelData)
    LibAddonMenu2:RegisterOptionControls(panelName, optionsData)
end

local function Initialize()
    InitializeSavedVariables()

    ZO_PostHook(ZO_AntiquityTileBase_Keyboard, "ShowTooltip", OnTooltipShown)
    ZO_PostHook(ZO_AntiquityTileBase_Keyboard, "HideTooltip", OnTooltipHidden)

    CreateSettings()
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    Initialize()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
