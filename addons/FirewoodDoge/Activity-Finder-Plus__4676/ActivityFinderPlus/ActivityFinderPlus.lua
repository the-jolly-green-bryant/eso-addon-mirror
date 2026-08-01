local ACTIVITY_FINDER_PLUS = ACTIVITY_FINDER_PLUS
local addonName = ACTIVITY_FINDER_PLUS.name
local em = ACTIVITY_FINDER_PLUS.eventManager
local LEGACY_SAVED_VARS_NAME = "GroupSynergizerSavedVars"

local function MigrateLegacySavedVariables(savedVariables)
    if savedVariables.migratedFromGroupSynergizer then return end

    local legacy = ZO_SavedVars:NewAccountWide(
        LEGACY_SAVED_VARS_NAME,
        ACTIVITY_FINDER_PLUS.variableVersion,
        nil,
        {},
        GetWorldName()
    )

    for key in pairs(ACTIVITY_FINDER_PLUS.defaults) do
        if savedVariables[key] == nil and legacy[key] ~= nil then
            savedVariables[key] = legacy[key]
        end
    end

    savedVariables.migratedFromGroupSynergizer = true
end

local function LoadSavedVariables()
    ACTIVITY_FINDER_PLUS.savedVariables = ZO_SavedVars:NewAccountWide(
        "ActivityFinderPlusSavedVars",
        ACTIVITY_FINDER_PLUS.variableVersion,
        nil,
        ACTIVITY_FINDER_PLUS.defaults,
        GetWorldName()
    )

    MigrateLegacySavedVariables(ACTIVITY_FINDER_PLUS.savedVariables)
    ACTIVITY_FINDER_PLUS.ApplyRuntimeSettings()
end

local function RegisterSlashCommands()
    for _, command in ipairs({ "/pledges", "/pledge", "/pl" }) do
        SLASH_COMMANDS[command] = ACTIVITY_FINDER_PLUS.DailyPledges
    end

    SLASH_COMMANDS["/leave"] = ACTIVITY_FINDER_PLUS.leaveGroup
    SLASH_COMMANDS["/lv"] = ACTIVITY_FINDER_PLUS.leaveGroup
end

local function InitializeAddon()
    LoadSavedVariables()
    RegisterSlashCommands()
    ACTIVITY_FINDER_PLUS.CreateSettingsWindow()
    ACTIVITY_FINDER_PLUS.InitializePledges()
end

local function OnAddOnLoaded(_, loadedAddonName)
    if loadedAddonName ~= addonName then return end

    InitializeAddon()
    em:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)
end

em:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
em:RegisterForEvent(addonName .. "_ActivityFinder", EVENT_ACTIVITY_FINDER_STATUS_UPDATE, ACTIVITY_FINDER_PLUS.OnActivityFinderStatusUpdate)
em:RegisterForEvent(addonName .. "_BattlegroundState", EVENT_BATTLEGROUND_STATE_CHANGED, ACTIVITY_FINDER_PLUS.OnBattlegroundStateChanged)

DEATH_FRAGMENT:RegisterCallback("StateChange", ACTIVITY_FINDER_PLUS.OnDeathFragmentStateChange)
KEYBOARD_GROUP_MENU_SCENE:RegisterCallback("StateChange", ACTIVITY_FINDER_PLUS.groupFinderVisible)
