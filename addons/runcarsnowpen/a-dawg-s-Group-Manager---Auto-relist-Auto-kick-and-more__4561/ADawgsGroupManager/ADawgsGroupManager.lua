local ADGM = _G["ADawgsGroupManager"]
local SAVED_VARIABLES_VERSION = ADGM.SAVED_VARIABLES_VERSION
local GUARD_MIN_INTERVAL_SECONDS = ADGM.GUARD_MIN_INTERVAL_SECONDS
local ROLE_GUARD_AVAILABLE = ADGM.ROLE_GUARD_AVAILABLE
local DEFAULTS = ADGM.DEFAULTS
local Chat = ADGM.Chat
local Debug = ADGM.Debug
local CopyDefaults = ADGM.CopyDefaults
local CopySavedVarsTable = ADGM.CopySavedVarsTable
local MigrateLegacySavedVars = ADGM.MigrateLegacySavedVars
local ApplyOffOnGameStartPolicy = ADGM.ApplyOffOnGameStartPolicy
local RegisterSocialCacheInvalidationEvents = ADGM.RegisterSocialCacheInvalidationEvents
local RegisterLeaderUpdateEvents = ADGM.RegisterLeaderUpdateEvents
local IsPresetKeyValid = ADGM.IsPresetKeyValid
local RefreshGuardTimer = ADGM.RefreshGuardTimer
local RegisterGroupFinderEvents = ADGM.RegisterGroupFinderEvents
local RefreshGroupFinderListingRuntimeState = ADGM.RefreshGroupFinderListingRuntimeState

function ADGM.OnAddonLoaded(_, addonName)
    if addonName ~= ADGM.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ADGM.name, EVENT_ADD_ON_LOADED)
    local savedVarsTable = CopySavedVarsTable(ADawgsGroupManagerVars)
    local serverNamespace = GetWorldName()
    ADGM.vars = ZO_SavedVars:NewAccountWide("ADawgsGroupManagerVars", SAVED_VARIABLES_VERSION, serverNamespace, DEFAULTS)
    MigrateLegacySavedVars(savedVarsTable, serverNamespace)
    CopyDefaults(ADGM.vars, DEFAULTS)
    if ADGM.vars.zoneGuard.graceSeconds == 60 then
        ADGM.vars.zoneGuard.graceSeconds = DEFAULTS.zoneGuard.graceSeconds
    end
    if ADGM.vars.zoneGuard.timeoutSeconds == 120 then
        ADGM.vars.zoneGuard.timeoutSeconds = DEFAULTS.zoneGuard.timeoutSeconds
    end
    if ADGM.vars.syncKickSafetyWithTargetSize then
        ADGM.vars.minGroupSizeForAutoKick = ADGM.vars.targetGroupSize
    end
    if ADGM.vars.groupFinder.twelvePlayerRelistThreshold == 10 then
        ADGM.vars.groupFinder.twelvePlayerRelistThreshold = 11
    end
    if not IsPresetKeyValid(ADGM.vars.selectedPreset) then
        ADGM.vars.selectedPreset = "custom"
    end
    ApplyOffOnGameStartPolicy()
    ADGM.state.lastKnownGroupSize = GetGroupSize()

    SLASH_COMMANDS["/adgm"] = ADGM.HandleCommand

    EVENT_MANAGER:RegisterForEvent(ADGM.name .. "Chat", EVENT_CHAT_MESSAGE_CHANNEL, ADGM.OnChatMessage)
    EVENT_MANAGER:RegisterForEvent(ADGM.name .. "Joined", EVENT_GROUP_MEMBER_JOINED, ADGM.OnMemberJoined)
    EVENT_MANAGER:RegisterForEvent(ADGM.name .. "Left", EVENT_GROUP_MEMBER_LEFT, ADGM.OnMemberLeft)
    EVENT_MANAGER:RegisterForEvent(ADGM.name .. "Connected", EVENT_GROUP_MEMBER_CONNECTED_STATUS, ADGM.OnMemberConnectedStatus)
    if ROLE_GUARD_AVAILABLE then
        EVENT_MANAGER:RegisterForEvent(ADGM.name .. "UnitCreated", EVENT_UNIT_CREATED, ADGM.OnUnitCreated)
        EVENT_MANAGER:RegisterForEvent(ADGM.name .. "UnitDestroyed", EVENT_UNIT_DESTROYED, ADGM.OnUnitDestroyed)
        EVENT_MANAGER:RegisterForEvent(ADGM.name .. "RoleChanged", EVENT_GROUP_MEMBER_ROLE_CHANGED, ADGM.OnGroupMemberRoleChanged)
    end
    RegisterGroupFinderEvents()
    RefreshGroupFinderListingRuntimeState()
    zo_callLater(RefreshGroupFinderListingRuntimeState, 1000)
    RegisterSocialCacheInvalidationEvents()
    RegisterLeaderUpdateEvents()
    ADGM.CheckOfflineGuard()
    local nextZoneCheckSeconds = ADGM.CheckZoneGuard()
    if nextZoneCheckSeconds then
        RefreshGuardTimer(math.floor(math.max(GUARD_MIN_INTERVAL_SECONDS, nextZoneCheckSeconds) * 1000))
    else
        RefreshGuardTimer()
    end

    ADGM.RegisterSettings()
    ADGM.HookNativeGroupFinderCreatePanel()
    zo_callLater(ADGM.HookNativeGroupFinderCreatePanel, 2000)
    Debug("Loaded " .. ADGM.version)
end

EVENT_MANAGER:RegisterForEvent(ADGM.name, EVENT_ADD_ON_LOADED, ADGM.OnAddonLoaded)
