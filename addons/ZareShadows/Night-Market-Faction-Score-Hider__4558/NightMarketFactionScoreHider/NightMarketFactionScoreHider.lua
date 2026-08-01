-- NightMarketFactionScoreHider.lua

NightMarketFactionScoreHider = NightMarketFactionScoreHider or {}
local NMFSH = NightMarketFactionScoreHider

local ADDON_NAME = "NightMarketFactionScoreHider"
local DISPLAY_NAME = "Night Market Faction Score Hider"
local SAVED_VARIABLES_NAME = "NightMarketFactionScoreHider_SavedVariables"
local SAVED_VARIABLES_VERSION = 1

NMFSH.name = ADDON_NAME
NMFSH.version = "1.0.1"

local EVENT_MANAGER = EVENT_MANAGER
local EVENT_ADD_ON_LOADED = EVENT_ADD_ON_LOADED
local EVENT_PLAYER_ACTIVATED = EVENT_PLAYER_ACTIVATED
local EVENT_ZONE_UPDATE = EVENT_ZONE_UPDATE
local EVENT_GUI_HIDDEN = EVENT_GUI_HIDDEN
local SLASH_COMMANDS = SLASH_COMMANDS
local GetControl = GetControl
local GetWorldName = GetWorldName
local ZO_CreateStringId = ZO_CreateStringId
local ZO_PreHookHandler = ZO_PreHookHandler
local ZO_SavedVars = ZO_SavedVars
local d = d
local ipairs = ipairs
local stringFormat = string.format
local type = type

local DEFAULTS = {
    hidden = true,
    migratedFromRoot = false,
}

local TARGET_CONTROL_NAMES = {
    "ZO_AdvZoneHUDTrackerContainer",
    "ZO_AdvZoneHUD_TopLevel",
}

local hookedControls = {}

local function GetSavedVars()
    return NMFSH.savedVars
end

local function IsHiddenEnabled()
    local savedVars = GetSavedVars()
    return not savedVars or savedVars.hidden ~= false
end

local function SetControlHidden(control, hidden)
    if not control then return end

    control:SetHidden(hidden)
end

local function HookControl(control)
    if not control or hookedControls[control] then return end

    hookedControls[control] = true

    ZO_PreHookHandler(control, "OnShow", function()
        if IsHiddenEnabled() then
            control:SetHidden(true)
        end
    end)
end

local function ApplyState()
    local hidden = IsHiddenEnabled()

    for _, controlName in ipairs(TARGET_CONTROL_NAMES) do
        local control = GetControl(controlName)

        if control then
            HookControl(control)
            SetControlHidden(control, hidden)
        end
    end
end

local function PrintState()
    local stateText = IsHiddenEnabled() and "hidden" or "shown"
    d(stringFormat("%s: faction score HUD %s.", DISPLAY_NAME, stateText))
end

function NMFSH.Toggle()
    local savedVars = GetSavedVars()
    savedVars.hidden = not IsHiddenEnabled()

    ApplyState()
    PrintState()
end

function NMFSH.Hide()
    local savedVars = GetSavedVars()
    savedVars.hidden = true

    ApplyState()
    PrintState()
end

function NMFSH.Show()
    local savedVars = GetSavedVars()
    savedVars.hidden = false

    ApplyState()
    PrintState()
end

local function RegisterKeybindStrings()
    ZO_CreateStringId(
        "SI_BINDING_NAME_NIGHTMARKETFACTIONSCOREHIDER_TOGGLE",
        "Toggle Faction Score HUD - Recommended: F2"
    )
end

local function RegisterSlashCommands()
    SLASH_COMMANDS["/nmfsh"] = NMFSH.Toggle
    SLASH_COMMANDS["/nmfshhide"] = NMFSH.Hide
    SLASH_COMMANDS["/nmfshshow"] = NMFSH.Show
end

local function MigrateRootSavedVariableIfNeeded(rootHiddenValue)
    local savedVars = GetSavedVars()

    if not savedVars or savedVars.migratedFromRoot then return end

    if rootHiddenValue ~= nil then
        savedVars.hidden = rootHiddenValue ~= false
    end

    savedVars.migratedFromRoot = true
end

local function CreateSavedVariables()
    local rootHiddenValue

    if type(NightMarketFactionScoreHider_SavedVariables) == "table" then
        rootHiddenValue = NightMarketFactionScoreHider_SavedVariables.hidden
    end

    NMFSH.savedVars = ZO_SavedVars:NewAccountWide(
        SAVED_VARIABLES_NAME,
        SAVED_VARIABLES_VERSION,
        nil,
        DEFAULTS,
        GetWorldName()
    )

    MigrateRootSavedVariableIfNeeded(rootHiddenValue)
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    CreateSavedVariables()
    RegisterKeybindStrings()
    RegisterSlashCommands()
    ApplyState()

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, ApplyState)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ZONE_UPDATE, ApplyState)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GUI_HIDDEN, ApplyState)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)