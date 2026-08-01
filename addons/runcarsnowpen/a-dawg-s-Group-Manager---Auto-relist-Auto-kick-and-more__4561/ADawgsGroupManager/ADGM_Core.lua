local ADDON_NAME = "ADawgsGroupManager"
local ADGM = _G[ADDON_NAME] or {}
_G[ADDON_NAME] = ADGM
ADGM.name = "ADawgsGroupManager"
ADGM.version = "1.1.1"

local COLOR_TITLE = "|c9BCBFF"
local COLOR_GOOD = "|c66FF66"
local COLOR_WARN = "|cFFD966"
local COLOR_BAD = "|cFF6666"
local COLOR_MUTED = "|cB0B0B0"
local COLOR_RESET = "|r"

local ACTION_NOTIFY = "notify"
local ACTION_WOULD_KICK = "wouldKick"
local ACTION_AUTO = "auto"

ZO_CreateStringId("SI_BINDING_NAME_ADGM_MANUAL_RELIST", "Manual List")
local GROUP_FINDER_FAILURE_BACKOFF_SECONDS = 300
local GROUP_FINDER_BLOCKED_RETRY_SECONDS = 60
local GROUP_FINDER_AUTO_RELIST_DELAY_SECONDS = 5
local GROUP_FINDER_STEP_DELAY_MS = 300
local GROUP_LEFT_RELIST_RECHECK_MS = 1000
local SAVED_VARIABLES_VERSION = 2
local SOCIAL_CACHE_TTL_SECONDS = 30
local GUARD_TIMER_NAME = ADGM.name .. "Guards"
local GUARD_CHECK_INTERVAL_SECONDS = 60
local GUARD_CHECK_INTERVAL_MS = GUARD_CHECK_INTERVAL_SECONDS * 1000
local GUARD_MIN_INTERVAL_SECONDS = 1
local OFFLINE_RETRY_SECONDS = 30
local INVITE_COOLDOWN_SECONDS = 10
local ROLE_GUARD_WINDOW_SECONDS = 15
local ROLE_GUARD_WINDOW_MS = ROLE_GUARD_WINDOW_SECONDS * 1000
local ROLE_GUARD_BASELINE_DELAY_MS = 50
local GROUP_FINDER_APPLICATION_ROLE_TTL_MS = 30000
local GROUP_FINDER_APPLICATION_APPROVAL_TIMEOUT_MS = 15000
local ROLE_GUARD_AVAILABLE = true

local RESTRICTION_ANYONE = "anyone"
local RESTRICTION_FRIENDS = "friends"
local RESTRICTION_GUILD = "guild"
local RESTRICTION_FRIENDS_GUILD = "friends_guild"

local EXPECTED_ZONE_PLAYER = "player"
local EXPECTED_ZONE_LEADER = "leader"
local EXPECTED_ZONE_LOCKED = "locked"

local DEFAULTS = {
    enabled = true,
    debug = false,
    chatMessages = true,
    serverSavedVarsMigrated = false,
    offOnGameStart = {
        addon = false,
        autoInvite = false,
        offlineGuard = false,
        zoneGuard = false,
        roleGuard = false,
        autoRelist = false,
        groupFinderAutoAcceptApplications = false,
        autoKick = false,
    },
    selectedPreset = "custom",
    customPresets = {
        nextId = 1,
        order = {},
        presets = {},
        draftName = "",
        includeGroupFinderTemplate = false,
    },
    targetGroupSize = 12,
    minGroupSizeForAutoKick = 1,
    syncKickSafetyWithTargetSize = true,
    autoInvite = {
        enabled = false,
        triggers = "+dolmen",
        allowPartialMatch = false,
        delayMs = 0,
        restriction = RESTRICTION_ANYONE,
        channels = {
            say = true,
            yell = true,
            zone = true,
            whisper = true,
            group = false,
            guild1 = false,
            guild2 = false,
            guild3 = false,
            guild4 = false,
            guild5 = false,
        },
    },
    offlineGuard = {
        enabled = true,
        action = ACTION_NOTIFY,
        timeoutSeconds = 30,
    },
    zoneGuard = {
        enabled = false,
        action = ACTION_NOTIFY,
        expectedZone = EXPECTED_ZONE_PLAYER,
        lockedZoneIndex = nil,
        graceSeconds = 120,
        timeoutSeconds = 300,
    },
    roleGuard = {
        enabled = false,
        action = ACTION_NOTIFY,
    },
    groupFinder = {
        relistOnLeave = false,
        mode = ACTION_NOTIFY,
        cooldownSeconds = 30,
        onlyWhenBelowTargetSize = true,
        autoAcceptApplications = false,
        twelvePlayerRelistThreshold = 11,
        eventLog = false,
        savedListing = nil,
    },
}

local CHANNEL_KEY_BY_TYPE = {
    [CHAT_CHANNEL_SAY] = "say",
    [CHAT_CHANNEL_YELL] = "yell",
    [CHAT_CHANNEL_WHISPER] = "whisper",
    [CHAT_CHANNEL_WHISPER_SENT] = "whisper",
    [CHAT_CHANNEL_PARTY] = "group",
    [CHAT_CHANNEL_ZONE] = "zone",
    [CHAT_CHANNEL_ZONE_LANGUAGE_1] = "zone",
    [CHAT_CHANNEL_ZONE_LANGUAGE_2] = "zone",
    [CHAT_CHANNEL_ZONE_LANGUAGE_3] = "zone",
    [CHAT_CHANNEL_ZONE_LANGUAGE_4] = "zone",
    [CHAT_CHANNEL_GUILD_1] = "guild1",
    [CHAT_CHANNEL_GUILD_2] = "guild2",
    [CHAT_CHANNEL_GUILD_3] = "guild3",
    [CHAT_CHANNEL_GUILD_4] = "guild4",
    [CHAT_CHANNEL_GUILD_5] = "guild5",
    [CHAT_CHANNEL_OFFICER_1] = "guild1",
    [CHAT_CHANNEL_OFFICER_2] = "guild2",
    [CHAT_CHANNEL_OFFICER_3] = "guild3",
    [CHAT_CHANNEL_OFFICER_4] = "guild4",
    [CHAT_CHANNEL_OFFICER_5] = "guild5",
}

ADGM.state = {
    offline = {},
    wrongZone = {},
    roles = {},
    joinedAt = {},
    lastRelistNotice = 0,
    lastRelistAttempt = 0,
    lastGroupFinderResult = nil,
    lastGroupFinderResultAt = 0,
    groupFinderBackoffUntil = 0,
    groupFinderRetryToken = 0,
    groupFinderRelistToken = 0,
    groupFinderRelistInProgress = false,
    pendingGroupFinderRetryAt = 0,
    pendingGroupFinderRetryReason = nil,
    groupFinderListingActive = false,
    groupFinderListingSleeping = false,
    groupFinderListingSleepReason = nil,
    lastGroupFinderRequestName = nil,
    lastGroupFinderRequestReason = nil,
    lastGroupFinderRequestByAddon = false,
    lastKnownGroupSize = 0,
    gfEventRegistered = false,
    leaderEventRegistered = false,
    nativeGroupFinderHooked = false,
    nativeGroupFinderCreatePanel = nil,
    settingsPresetCallbacksRegistered = false,
    guardTimerActive = false,
    guardTimerIntervalMs = nil,
    socialCacheEventsRegistered = false,
    safetySkipLogged = {},
    roleUnitTags = {},
    groupFinderApplicationRoles = {},
    groupFinderApplicationApprovals = {},
    groupFinderApplicationApprovalQueue = {},
    groupFinderApplicationApprovalInFlight = nil,
    groupFinderApplicationApprovalToken = 0,
    lastRoleGuardAutoAcceptWarningAt = 0,
    inviteCooldown = {},
    triggerCache = { raw = nil, triggers = {} },
    friendCache = {},
    guildMemberCache = {},
    commandChatDepth = 0,
    roleGuardSerial = 0,
}


local function IsPassiveGroupMemberForChat()
    return GetGroupSize() > 0 and not IsUnitGroupLeader("player")
end

local function Chat(message, force)
    if IsPassiveGroupMemberForChat() and (ADGM.state.commandChatDepth or 0) <= 0 then
        return
    end

    if force or (ADGM.vars and ADGM.vars.chatMessages) then
        d(COLOR_TITLE .. "[ADGM]" .. COLOR_RESET .. " " .. tostring(message))
    end
end

local function Debug(message)
    if ADGM.vars and ADGM.vars.debug then
        Chat(COLOR_MUTED .. tostring(message) .. COLOR_RESET, true)
    end
end

local function CopyDefaults(target, defaults)
    for key, value in pairs(defaults) do
        if type(value) == "table" then
            target[key] = target[key] or {}
            CopyDefaults(target[key], value)
        elseif target[key] == nil then
            target[key] = value
        end
    end
end

local function CopySavedVarsTable(source)
    if type(source) ~= "table" then
        return source
    end

    local target = {}
    for key, value in pairs(source) do
        target[key] = CopySavedVarsTable(value)
    end
    return target
end

local function MergeSavedVars(target, source)
    if type(target) ~= "table" or type(source) ~= "table" then
        return
    end

    for key, value in pairs(source) do
        if key ~= "version" and key ~= "serverSavedVarsMigrated" then
            if type(value) == "table" then
                if type(target[key]) ~= "table" then
                    target[key] = {}
                end
                MergeSavedVars(target[key], value)
            else
                target[key] = value
            end
        end
    end
end

local function GetAccountWideTableFromNamespace(namespaceData)
    if type(namespaceData) ~= "table" then
        return nil
    end

    local displayName = GetDisplayName()
    if displayName and type(namespaceData[displayName]) == "table" and type(namespaceData[displayName]["$AccountWide"]) == "table" then
        return namespaceData[displayName]["$AccountWide"]
    end

    for _, accountData in pairs(namespaceData) do
        if type(accountData) == "table" and type(accountData["$AccountWide"]) == "table" then
            return accountData["$AccountWide"]
        end
    end
    return nil
end

local function FindLegacyAccountWideSavedVars(savedVarsTable, serverNamespace)
    if type(savedVarsTable) ~= "table" then
        return nil
    end

    local legacy = GetAccountWideTableFromNamespace(savedVarsTable.Default)
    if legacy then
        return legacy
    end

    for namespace, namespaceData in pairs(savedVarsTable) do
        if namespace ~= serverNamespace then
            legacy = GetAccountWideTableFromNamespace(namespaceData)
            if legacy then
                return legacy
            end
        end
    end
    return nil
end

local function MigrateLegacySavedVars(savedVarsTable, serverNamespace)
    if ADGM.vars.serverSavedVarsMigrated then
        return
    end

    local legacyVars = FindLegacyAccountWideSavedVars(savedVarsTable, serverNamespace)
    if legacyVars then
        MergeSavedVars(ADGM.vars, legacyVars)
    end
    ADGM.vars.serverSavedVarsMigrated = true
end

local function GetNow()
    return GetTimeStamp()
end

local function GetNowMs()
    return GetGameTimeMilliseconds()
end

local function CanUseLeaderActions()
    return IsUnitSoloOrGroupLeader("player")
end

local function GetAutoRelistStartSize()
    if not ADGM.vars then
        return DEFAULTS.targetGroupSize - 1
    end

    if ADGM.vars.targetGroupSize == 12 and ADGM.vars.selectedPreset ~= "trialFill" then
        return ADGM.vars.groupFinder.twelvePlayerRelistThreshold or DEFAULTS.groupFinder.twelvePlayerRelistThreshold
    end

    return zo_max(1, (ADGM.vars.targetGroupSize or DEFAULTS.targetGroupSize) - 1)
end

local function CancelGroupFinderRelistRetry()
    ADGM.state.groupFinderRetryToken = (ADGM.state.groupFinderRetryToken or 0) + 1
    ADGM.state.pendingGroupFinderRetryAt = 0
    ADGM.state.pendingGroupFinderRetryReason = nil
end

local function CancelGroupFinderRelistSteps()
    ADGM.state.groupFinderRelistToken = (ADGM.state.groupFinderRelistToken or 0) + 1
    ADGM.state.groupFinderRelistInProgress = false
end

local function SetGroupFinderListingActive(reason)
    if ADGM.state.groupFinderListingActive
        and not ADGM.state.groupFinderListingSleeping
        and (ADGM.state.pendingGroupFinderRetryAt or 0) <= 0
    then
        return
    end
    CancelGroupFinderRelistRetry()
    ADGM.state.groupFinderListingActive = true
    ADGM.state.groupFinderListingSleeping = false
    ADGM.state.groupFinderListingSleepReason = nil
end

local function SetGroupFinderListingSleeping(reason)
    if ADGM.state.groupFinderListingSleeping
        and ADGM.state.groupFinderListingSleepReason == reason
        and (ADGM.state.pendingGroupFinderRetryAt or 0) <= 0
    then
        return
    end
    CancelGroupFinderRelistRetry()
    ADGM.state.groupFinderListingActive = false
    ADGM.state.groupFinderListingSleeping = true
    ADGM.state.groupFinderListingSleepReason = reason
end

local function IsGroupFinderListingRuntimeArmed()
    return ADGM.state.groupFinderListingActive == true
        or ADGM.state.groupFinderListingSleeping == true
end

local function ClearGroupFinderListingRuntimeState(reason, keepPendingRetry)
    if not ADGM.state.groupFinderListingActive
        and not ADGM.state.groupFinderListingSleeping
        and ADGM.state.groupFinderListingSleepReason == nil
        and (ADGM.state.pendingGroupFinderRetryAt or 0) <= 0
    then
        return
    end
    if not keepPendingRetry then
        CancelGroupFinderRelistRetry()
    end
    ADGM.state.groupFinderListingActive = false
    ADGM.state.groupFinderListingSleeping = false
    ADGM.state.groupFinderListingSleepReason = nil
end

local function MaybeSleepGroupFinderListingForFullGroup()
    if not ADGM.vars or not ADGM.vars.groupFinder or not ADGM.state.groupFinderListingActive then
        return
    end
    if GetGroupSize() >= (ADGM.vars.targetGroupSize or DEFAULTS.targetGroupSize) then
        SetGroupFinderListingSleeping("group full")
    end
end

local function ClearLeaderAutomationState(reason)
    for _, entry in pairs(ADGM.state.offline) do
        entry.checkToken = (entry.checkToken or 0) + 1
    end
    ADGM.state.offline = {}
    ADGM.state.wrongZone = {}
    ADGM.state.roles = {}
    ADGM.state.roleUnitTags = {}
    ADGM.state.groupFinderApplicationRoles = {}
    ADGM.state.groupFinderApplicationApprovals = {}
    ADGM.state.groupFinderApplicationApprovalQueue = {}
    ADGM.state.groupFinderApplicationApprovalInFlight = nil
    ADGM.state.groupFinderApplicationApprovalToken = (ADGM.state.groupFinderApplicationApprovalToken or 0) + 1
    ADGM.state.joinedAt = {}
    ADGM.state.safetySkipLogged = {}
    CancelGroupFinderRelistSteps()
    ClearGroupFinderListingRuntimeState(reason)
end

local function ApplyOffOnGameStartPolicy()
    local policy = ADGM.vars and ADGM.vars.offOnGameStart
    if not policy then
        return
    end

    if policy.addon then
        ADGM.vars.enabled = false
    end
    if policy.autoInvite then
        ADGM.vars.autoInvite.enabled = false
    end
    if policy.offlineGuard then
        ADGM.vars.offlineGuard.enabled = false
    end
    if policy.zoneGuard then
        ADGM.vars.zoneGuard.enabled = false
    end
    if policy.roleGuard then
        ADGM.vars.roleGuard.enabled = false
    end
    if policy.autoRelist then
        ADGM.vars.groupFinder.relistOnLeave = false
    end
    if policy.groupFinderAutoAcceptApplications then
        ADGM.vars.groupFinder.autoAcceptApplications = false
        ADGM.state.groupFinderApplicationApprovalQueue = {}
        ADGM.state.groupFinderApplicationApprovalInFlight = nil
        ADGM.state.groupFinderApplicationApprovalToken = (ADGM.state.groupFinderApplicationApprovalToken or 0) + 1
    end
    if policy.autoKick then
        if ADGM.vars.offlineGuard.action == ACTION_AUTO then
            ADGM.vars.offlineGuard.action = ACTION_NOTIFY
        end
        if ADGM.vars.zoneGuard.action == ACTION_AUTO then
            ADGM.vars.zoneGuard.action = ACTION_NOTIFY
        end
        if ADGM.vars.roleGuard.action == ACTION_AUTO then
            ADGM.vars.roleGuard.action = ACTION_NOTIFY
        end
    end
end

local function IsAddonAwake()
    return ADGM.vars and ADGM.vars.enabled and CanUseLeaderActions()
end

local function NormalizeName(name)
    if not name or name == "" then
        return nil
    end
    return zo_strformat("<<1>>", name)
end

local function UnitKey(unitTag)
    local displayName = GetUnitDisplayName(unitTag)
    local characterName = GetUnitName(unitTag)
    return NormalizeName(displayName and displayName ~= "" and displayName or characterName)
end

local function IsPlayerUnit(unitTag)
    return AreUnitsEqual(unitTag, "player")
end

local function GetUnitTagForName(name)
    name = NormalizeName(name)
    if not name then
        return nil
    end
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        local displayName = NormalizeName(GetUnitDisplayName(unitTag))
        local characterName = NormalizeName(GetUnitName(unitTag))
        if name == displayName or name == characterName then
            return unitTag
        end
    end
    return nil
end

local function SplitTriggers(text)
    local triggers = {}
    text = text or ""
    for token in string.gmatch(text, "[^,%s]+") do
        triggers[#triggers + 1] = string.lower(token)
    end
    return triggers
end

local function GetCachedSocialLookup(cache, displayName, lookupFn)
    if not displayName or displayName == "" then
        return false
    end

    local key = string.lower(displayName)
    local now = GetNow()
    local entry = cache[key]
    if entry and now - entry.at <= SOCIAL_CACHE_TTL_SECONDS then
        return entry.value
    end

    local value = lookupFn(key) == true
    cache[key] = { value = value, at = now }
    return value
end

local function ClearSocialCaches()
    ADGM.state.friendCache = {}
    ADGM.state.guildMemberCache = {}
end

local SOCIAL_CACHE_EVENTS = {
    { "FriendAdded", EVENT_FRIEND_ADDED },
    { "FriendRemoved", EVENT_FRIEND_REMOVED },
    { "FriendStatus", EVENT_FRIEND_PLAYER_STATUS_CHANGED },
    { "GuildMemberAdded", EVENT_GUILD_MEMBER_ADDED },
    { "GuildMemberRemoved", EVENT_GUILD_MEMBER_REMOVED },
    { "GuildMemberStatus", EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED },
    { "GuildDataLoaded", EVENT_GUILD_DATA_LOADED },
}

local LEADER_UPDATE_EVENTS = {
    { "LeaderUpdate", EVENT_LEADER_UPDATE },
    { "GroupUpdate", EVENT_GROUP_UPDATE },
}

local function RegisterSocialCacheInvalidationEvents()
    if ADGM.state.socialCacheEventsRegistered then
        return
    end

    for _, event in ipairs(SOCIAL_CACHE_EVENTS) do
        EVENT_MANAGER:RegisterForEvent(ADGM.name .. event[1], event[2], ClearSocialCaches)
    end

    ADGM.state.socialCacheEventsRegistered = true
end

local function RegisterLeaderUpdateEvents()
    if ADGM.state.leaderEventRegistered then
        return
    end

    for _, event in ipairs(LEADER_UPDATE_EVENTS) do
        EVENT_MANAGER:RegisterForEvent(ADGM.name .. event[1], event[2], ADGM.OnLeadershipChanged)
    end

    ADGM.state.leaderEventRegistered = true
end

local function MarkCustomPreset()
    if not ADGM.vars or (ADGM.state and ADGM.state.applyingPreset) then
        return
    end
    if ADGM.vars.selectedPreset ~= "custom" then
        ADGM.vars.selectedPreset = "custom"
        if ADGM.UpdatePresetControls then
            ADGM.UpdatePresetControls()
        elseif ADGM.UpdateNativeGroupFinderCreatePanel then
            ADGM.UpdateNativeGroupFinderCreatePanel()
        end
    end
end

local function SetTargetGroupSize(size)
    MarkCustomPreset()
    ADGM.vars.targetGroupSize = size
    if ADGM.vars.syncKickSafetyWithTargetSize then
        ADGM.vars.minGroupSizeForAutoKick = size
    end
end

local function SetSyncKickSafetyWithTargetSize(value)
    MarkCustomPreset()
    ADGM.vars.syncKickSafetyWithTargetSize = value == true
    if ADGM.vars.syncKickSafetyWithTargetSize then
        ADGM.vars.minGroupSizeForAutoKick = ADGM.vars.targetGroupSize
    end
end

local PRESET_KEYS = {
    "custom",
    "dolmen",
    "worldBoss",
    "nightMarket",
    "dungeon",
    "trialFill",
}

local CUSTOM_PRESET_PREFIX = "customPreset:"

local PRESET_LABELS = {
    "Custom",
    "Dolmen",
    "World Boss",
    "Night Market",
    "Dungeon",
    "Trial",
}

local GROUP_FINDER_SIZE_SMALL_VALUE = GROUP_FINDER_SIZE_SMALL
local GROUP_FINDER_SIZE_STANDARD_VALUE = GROUP_FINDER_SIZE_STANDARD
local GROUP_FINDER_SIZE_LARGE_VALUE = GROUP_FINDER_SIZE_LARGE
local GROUP_FINDER_SPECIFIC_ROLE_TYPES = {}
local GROUP_FINDER_ROLE_TYPES = {}
local function AddGroupFinderRole(roleType, includeInSpecificRoles)
    if includeInSpecificRoles then
        GROUP_FINDER_SPECIFIC_ROLE_TYPES[#GROUP_FINDER_SPECIFIC_ROLE_TYPES + 1] = roleType
    end
    GROUP_FINDER_ROLE_TYPES[#GROUP_FINDER_ROLE_TYPES + 1] = roleType
end
AddGroupFinderRole(LFG_ROLE_TANK, true)
AddGroupFinderRole(LFG_ROLE_HEAL, true)
AddGroupFinderRole(LFG_ROLE_DPS, true)
AddGroupFinderRole(LFG_ROLE_INVALID, false)

local PRESETS = {
    dolmen = {
        label = "Dolmen",
        size = 12,
        triggers = "+dolmen",
        channels = { say = true, yell = true, zone = true, whisper = true },
        relistMode = ACTION_AUTO,
        relistThreshold = 11,
        offlineAction = ACTION_AUTO,
        offlineTimeout = 90,
        zoneAction = ACTION_NOTIFY,
        zoneGrace = 120,
        zoneTimeout = 300,
    },
    worldBoss = {
        label = "World Boss",
        size = 12,
        triggers = "+wb",
        channels = { say = true, yell = true, zone = true, whisper = true, guild1 = true, guild2 = true, guild3 = true, guild4 = true, guild5 = true },
        relistMode = ACTION_AUTO,
        relistThreshold = 11,
        offlineAction = ACTION_AUTO,
        offlineTimeout = 90,
        zoneAction = ACTION_NOTIFY,
        zoneGrace = 120,
        zoneTimeout = 300,
    },
    nightMarket = {
        label = "Night Market",
        size = 12,
        triggers = "+nm",
        channels = { say = true, yell = true, zone = true, whisper = true, guild1 = true, guild2 = true, guild3 = true, guild4 = true, guild5 = true },
        relistMode = ACTION_AUTO,
        relistThreshold = 11,
        offlineAction = ACTION_AUTO,
        offlineTimeout = 90,
        zoneAction = ACTION_NOTIFY,
        zoneGrace = 120,
        zoneTimeout = 300,
    },
    dungeon = {
        label = "Dungeon",
        size = 4,
        triggers = "+dungeon",
        channels = { say = true, zone = true, whisper = true },
        relistMode = ACTION_AUTO,
        relistThreshold = 4,
        offlineAction = ACTION_AUTO,
        offlineTimeout = 90,
        zoneAction = ACTION_AUTO,
        zoneGrace = 120,
        zoneTimeout = 300,
    },
    trialFill = {
        label = "Trial",
        size = 12,
        triggers = "+trial",
        channels = { zone = true, whisper = true, guild1 = true, guild2 = true, guild3 = true, guild4 = true, guild5 = true },
        relistMode = ACTION_AUTO,
        relistThreshold = 11,
        offlineAction = ACTION_NOTIFY,
        offlineTimeout = 90,
        zoneAction = ACTION_NOTIFY,
        zoneGrace = 180,
        zoneTimeout = 420,
    },
}

local function GetCustomPresetStore()
    if not ADGM.vars then
        return nil
    end

    if type(ADGM.vars.customPresets) ~= "table" then
        ADGM.vars.customPresets = CopySavedVarsTable(DEFAULTS.customPresets)
    end

    local store = ADGM.vars.customPresets
    if type(store.order) ~= "table" then
        store.order = {}
    end
    if type(store.presets) ~= "table" then
        store.presets = {}
    end
    store.nextId = tonumber(store.nextId) or 1
    store.draftName = store.draftName or ""
    store.includeGroupFinderTemplate = store.includeGroupFinderTemplate == true
    return store
end

local function GetCustomPresetIdFromKey(key)
    if type(key) ~= "string" then
        return nil
    end

    if string.sub(key, 1, #CUSTOM_PRESET_PREFIX) == CUSTOM_PRESET_PREFIX then
        local id = string.sub(key, #CUSTOM_PRESET_PREFIX + 1)
        if id ~= "" then
            return id
        end
    end
    return nil
end

local function GetCustomPresetById(id)
    local store = GetCustomPresetStore()
    if not store or not id then
        return nil
    end
    return store.presets[tostring(id)]
end

local function GetCustomPresetByKey(key)
    local id = GetCustomPresetIdFromKey(key)
    return GetCustomPresetById(id), id
end

local function IsCustomPresetKey(key)
    return GetCustomPresetByKey(key) ~= nil
end

local function CustomPresetHasGroupFinderTemplate(key)
    local preset = GetCustomPresetByKey(key)
    return preset
        and preset.settings
        and preset.settings.groupFinder
        and preset.settings.groupFinder.savedListing ~= nil
end

local CaptureAutomationPresetSettings

local function FormatAction(value)
    if value == ACTION_AUTO then
        return "auto kick"
    elseif value == ACTION_WOULD_KICK then
        return "would kick"
    end
    return "notify"
end

local CHANNEL_LABELS = {
    { key = "say", label = "say" },
    { key = "yell", label = "yell" },
    { key = "zone", label = "zone" },
    { key = "whisper", label = "whisper" },
    { key = "group", label = "group" },
    { key = "guild1", label = "guild 1" },
    { key = "guild2", label = "guild 2" },
    { key = "guild3", label = "guild 3" },
    { key = "guild4", label = "guild 4" },
    { key = "guild5", label = "guild 5" },
}

local function FormatChannels(channels)
    if type(channels) ~= "table" then
        return "none"
    end

    local labels = {}
    for _, channel in ipairs(CHANNEL_LABELS) do
        if channels[channel.key] == true then
            labels[#labels + 1] = channel.label
        end
    end
    return #labels > 0 and table.concat(labels, ", ") or "none"
end

local function FormatEnabled(value)
    return value == true and "on" or "off"
end

local function GetBooleanOrDefault(value, defaultValue)
    if value == nil then
        return defaultValue == true
    end
    return value == true
end

local function BuildPresetTooltipFromSettings(label, settings, hasGroupFinderTemplate)
    if type(settings) ~= "table" then
        return label
    end

    local autoInvite = settings.autoInvite or DEFAULTS.autoInvite
    local offlineGuard = settings.offlineGuard or DEFAULTS.offlineGuard
    local zoneGuard = settings.zoneGuard or DEFAULTS.zoneGuard
    local roleGuard = settings.roleGuard or DEFAULTS.roleGuard
    local groupFinder = settings.groupFinder or DEFAULTS.groupFinder

    local lines = {
        label,
        "Size: " .. tostring(settings.targetGroupSize or DEFAULTS.targetGroupSize),
        "Auto-kick safety: " .. tostring(settings.minGroupSizeForAutoKick or (ADGM.vars and ADGM.vars.minGroupSizeForAutoKick) or DEFAULTS.minGroupSizeForAutoKick) .. ", sync " .. FormatEnabled(GetBooleanOrDefault(settings.syncKickSafetyWithTargetSize, DEFAULTS.syncKickSafetyWithTargetSize)),
        "Auto invite: " .. FormatEnabled(autoInvite.enabled) .. ", trigger " .. tostring(autoInvite.triggers or ""),
        "Channels: " .. FormatChannels(autoInvite.channels),
        "Relist: " .. FormatEnabled(groupFinder.relistOnLeave) .. ", " .. tostring(groupFinder.mode or ACTION_NOTIFY) .. ", cooldown " .. tostring(groupFinder.cooldownSeconds or DEFAULTS.groupFinder.cooldownSeconds) .. "s",
        "Below target only: " .. FormatEnabled(GetBooleanOrDefault(groupFinder.onlyWhenBelowTargetSize, DEFAULTS.groupFinder.onlyWhenBelowTargetSize)),
        "ADGM auto-accept: " .. FormatEnabled(GetBooleanOrDefault(groupFinder.autoAcceptApplications, DEFAULTS.groupFinder.autoAcceptApplications)),
        "Relist threshold: " .. tostring(groupFinder.twelvePlayerRelistThreshold or DEFAULTS.groupFinder.twelvePlayerRelistThreshold),
        "Offline guard: " .. FormatEnabled(offlineGuard.enabled) .. ", " .. FormatAction(offlineGuard.action) .. " after " .. tostring(offlineGuard.timeoutSeconds or DEFAULTS.offlineGuard.timeoutSeconds) .. "s",
        "Zone guard: " .. FormatEnabled(zoneGuard.enabled) .. ", " .. FormatAction(zoneGuard.action) .. ", grace " .. tostring(zoneGuard.graceSeconds or DEFAULTS.zoneGuard.graceSeconds) .. "s, timeout " .. tostring(zoneGuard.timeoutSeconds or DEFAULTS.zoneGuard.timeoutSeconds) .. "s",
        "Role guard: " .. FormatEnabled(roleGuard.enabled) .. ", " .. FormatAction(roleGuard.action),
        "Group Finder template: " .. (hasGroupFinderTemplate and "included" or "not included"),
    }
    return table.concat(lines, "\n")
end

local function BuildBuiltinPresetTooltip(key)
    if key == "custom" then
        if ADGM.vars then
            return BuildPresetTooltipFromSettings("Custom", CaptureAutomationPresetSettings(false), false)
        end
        return "Custom\nKeeps your current settings."
    end

    local preset = PRESETS[key]
    if not preset then
        return tostring(key)
    end

    local currentGroupFinder = ADGM.vars and ADGM.vars.groupFinder or DEFAULTS.groupFinder
    local currentSyncKickSafety = DEFAULTS.syncKickSafetyWithTargetSize
    if ADGM.vars then
        currentSyncKickSafety = ADGM.vars.syncKickSafetyWithTargetSize == true
    end

    local settings = {
        targetGroupSize = preset.size,
        minGroupSizeForAutoKick = ADGM.vars and ADGM.vars.minGroupSizeForAutoKick or DEFAULTS.minGroupSizeForAutoKick,
        syncKickSafetyWithTargetSize = currentSyncKickSafety,
        autoInvite = {
            enabled = true,
            triggers = preset.triggers,
            channels = preset.channels,
        },
        offlineGuard = {
            enabled = true,
            action = preset.offlineAction,
            timeoutSeconds = preset.offlineTimeout,
        },
        zoneGuard = {
            enabled = true,
            action = preset.zoneAction,
            graceSeconds = preset.zoneGrace,
            timeoutSeconds = preset.zoneTimeout,
        },
        roleGuard = ADGM.vars and CopySavedVarsTable(ADGM.vars.roleGuard) or DEFAULTS.roleGuard,
        groupFinder = {
            relistOnLeave = true,
            mode = preset.relistMode,
            cooldownSeconds = currentGroupFinder.cooldownSeconds,
            onlyWhenBelowTargetSize = currentGroupFinder.onlyWhenBelowTargetSize == true,
            autoAcceptApplications = currentGroupFinder.autoAcceptApplications == true,
            twelvePlayerRelistThreshold = preset.relistThreshold or DEFAULTS.groupFinder.twelvePlayerRelistThreshold,
        },
    }
    return BuildPresetTooltipFromSettings(preset.label, settings, false)
end

local function GetPresetTooltip(key)
    local customPreset = GetCustomPresetByKey(key)
    if customPreset then
        return BuildPresetTooltipFromSettings(customPreset.name, customPreset.settings, CustomPresetHasGroupFinderTemplate(key))
    end
    return BuildBuiltinPresetTooltip(key)
end

local function IsPresetKeyValid(key)
    return key == "custom" or PRESETS[key] ~= nil or IsCustomPresetKey(key)
end

local function GetPresetLabel(key)
    if key == "custom" then
        return "Custom"
    end

    local builtin = PRESETS[key]
    if builtin then
        return builtin.label
    end

    local preset = GetCustomPresetByKey(key)
    if preset then
        return preset.name
    end

    return "Custom"
end

local function GetPresetChoices()
    local labels = {}
    local values = {}
    local tooltips = {}

    for index, key in ipairs(PRESET_KEYS) do
        labels[#labels + 1] = PRESET_LABELS[index]
        values[#values + 1] = key
        tooltips[#tooltips + 1] = GetPresetTooltip(key)
    end

    local store = GetCustomPresetStore()
    if store then
        for _, id in ipairs(store.order) do
            id = tostring(id)
            local preset = store.presets[id]
            if preset and preset.name then
                local key = CUSTOM_PRESET_PREFIX .. id
                labels[#labels + 1] = preset.name
                values[#values + 1] = key
                tooltips[#tooltips + 1] = GetPresetTooltip(key)
            end
        end
    end

    return labels, values, tooltips
end

local function NotifyPresetControlsChanged()
    if ADGM.UpdatePresetControls then
        ADGM.UpdatePresetControls()
    elseif ADGM.UpdateNativeGroupFinderCreatePanel then
        ADGM.UpdateNativeGroupFinderCreatePanel()
    end
end

local function CleanCustomPresetName(name)
    name = zo_strtrim(name or "")
    if name == "" then
        return nil
    end
    return string.sub(name, 1, 64)
end

local function AllocateCustomPresetId(store)
    local nextId = tonumber(store.nextId) or 1
    local id = tostring(nextId)
    while store.presets[id] do
        nextId = nextId + 1
        id = tostring(nextId)
    end
    store.nextId = nextId + 1
    return id
end

CaptureAutomationPresetSettings = function(includeGroupFinderTemplate)
    local groupFinder = ADGM.vars.groupFinder
    local settings = {
        targetGroupSize = ADGM.vars.targetGroupSize,
        minGroupSizeForAutoKick = ADGM.vars.minGroupSizeForAutoKick,
        syncKickSafetyWithTargetSize = ADGM.vars.syncKickSafetyWithTargetSize == true,
        autoInvite = CopySavedVarsTable(ADGM.vars.autoInvite),
        offlineGuard = CopySavedVarsTable(ADGM.vars.offlineGuard),
        zoneGuard = CopySavedVarsTable(ADGM.vars.zoneGuard),
        roleGuard = CopySavedVarsTable(ADGM.vars.roleGuard),
        groupFinder = {
            relistOnLeave = groupFinder.relistOnLeave == true,
            mode = groupFinder.mode,
            cooldownSeconds = groupFinder.cooldownSeconds,
            onlyWhenBelowTargetSize = groupFinder.onlyWhenBelowTargetSize == true,
            autoAcceptApplications = groupFinder.autoAcceptApplications == true,
            twelvePlayerRelistThreshold = groupFinder.twelvePlayerRelistThreshold,
        },
    }

    if includeGroupFinderTemplate and groupFinder.savedListing then
        settings.groupFinder.savedListing = CopySavedVarsTable(groupFinder.savedListing)
    end

    return settings
end

local function ApplyDefaultsToPresetTables()
    CopyDefaults(ADGM.vars.autoInvite, DEFAULTS.autoInvite)
    CopyDefaults(ADGM.vars.offlineGuard, DEFAULTS.offlineGuard)
    CopyDefaults(ADGM.vars.zoneGuard, DEFAULTS.zoneGuard)
    CopyDefaults(ADGM.vars.roleGuard, DEFAULTS.roleGuard)
    CopyDefaults(ADGM.vars.groupFinder, DEFAULTS.groupFinder)
end

local function ApplyAutomationPresetSettings(settings)
    if type(settings) ~= "table" then
        return false
    end

    ADGM.vars.targetGroupSize = settings.targetGroupSize or ADGM.vars.targetGroupSize
    ADGM.vars.syncKickSafetyWithTargetSize = settings.syncKickSafetyWithTargetSize == true
    if ADGM.vars.syncKickSafetyWithTargetSize then
        ADGM.vars.minGroupSizeForAutoKick = ADGM.vars.targetGroupSize
    else
        ADGM.vars.minGroupSizeForAutoKick = settings.minGroupSizeForAutoKick or ADGM.vars.minGroupSizeForAutoKick
    end

    ADGM.vars.autoInvite = CopySavedVarsTable(settings.autoInvite or DEFAULTS.autoInvite)
    ADGM.vars.offlineGuard = CopySavedVarsTable(settings.offlineGuard or DEFAULTS.offlineGuard)
    ADGM.vars.zoneGuard = CopySavedVarsTable(settings.zoneGuard or DEFAULTS.zoneGuard)
    ADGM.vars.roleGuard = CopySavedVarsTable(settings.roleGuard or DEFAULTS.roleGuard)

    local savedListing = ADGM.vars.groupFinder and ADGM.vars.groupFinder.savedListing
    local eventLog = ADGM.vars.groupFinder and ADGM.vars.groupFinder.eventLog
    ADGM.vars.groupFinder = CopySavedVarsTable(DEFAULTS.groupFinder)
    if type(settings.groupFinder) == "table" then
        ADGM.vars.groupFinder.relistOnLeave = settings.groupFinder.relistOnLeave == true
        ADGM.vars.groupFinder.mode = settings.groupFinder.mode or DEFAULTS.groupFinder.mode
        ADGM.vars.groupFinder.cooldownSeconds = settings.groupFinder.cooldownSeconds or DEFAULTS.groupFinder.cooldownSeconds
        ADGM.vars.groupFinder.onlyWhenBelowTargetSize = settings.groupFinder.onlyWhenBelowTargetSize == true
        ADGM.vars.groupFinder.autoAcceptApplications = settings.groupFinder.autoAcceptApplications == true
        ADGM.vars.groupFinder.twelvePlayerRelistThreshold = settings.groupFinder.twelvePlayerRelistThreshold or DEFAULTS.groupFinder.twelvePlayerRelistThreshold
        if settings.groupFinder.savedListing then
            ADGM.vars.groupFinder.savedListing = CopySavedVarsTable(settings.groupFinder.savedListing)
        else
            ADGM.vars.groupFinder.savedListing = savedListing
        end
    else
        ADGM.vars.groupFinder.savedListing = savedListing
    end
    ADGM.vars.groupFinder.eventLog = eventLog == true

    ApplyDefaultsToPresetTables()
    return true
end

local function RefreshAutomationAfterPresetApply()
    ADGM.CheckOfflineGuard()
    local nextZoneCheckSeconds = ADGM.CheckZoneGuard()
    if nextZoneCheckSeconds then
        ADGM.RefreshGuardTimer(math.floor(math.max(GUARD_MIN_INTERVAL_SECONDS, nextZoneCheckSeconds) * 1000))
    else
        ADGM.RefreshGuardTimer()
    end
    NotifyPresetControlsChanged()
end

local function SaveCustomPreset(name, includeGroupFinderTemplate)
    name = CleanCustomPresetName(name)
    if not name then
        Chat(COLOR_BAD .. "Enter a custom preset name first." .. COLOR_RESET, true)
        return false
    end
    if includeGroupFinderTemplate and not ADGM.vars.groupFinder.savedListing then
        Chat(COLOR_BAD .. "No Group Finder template saved. Save a listing template first or disable Include Group Finder template." .. COLOR_RESET, true)
        return false
    end

    local store = GetCustomPresetStore()
    local id = AllocateCustomPresetId(store)
    store.presets[id] = {
        name = name,
        settings = CaptureAutomationPresetSettings(includeGroupFinderTemplate == true),
    }
    store.order[#store.order + 1] = id
    store.draftName = name
    ADGM.vars.selectedPreset = CUSTOM_PRESET_PREFIX .. id
    NotifyPresetControlsChanged()
    Chat("Saved custom preset: " .. name .. ".", true)
    return true
end

local function UpdateSelectedCustomPreset(includeGroupFinderTemplate)
    local preset = GetCustomPresetByKey(ADGM.vars.selectedPreset)
    if not preset then
        Chat(COLOR_BAD .. "Select a custom preset first." .. COLOR_RESET, true)
        return false
    end
    if includeGroupFinderTemplate and not ADGM.vars.groupFinder.savedListing then
        Chat(COLOR_BAD .. "No Group Finder template saved. Save a listing template first or disable Include Group Finder template." .. COLOR_RESET, true)
        return false
    end

    preset.settings = CaptureAutomationPresetSettings(includeGroupFinderTemplate == true)
    NotifyPresetControlsChanged()
    Chat("Updated custom preset: " .. tostring(preset.name) .. ".", true)
    return true
end

local function RenameSelectedCustomPreset(name)
    name = CleanCustomPresetName(name)
    if not name then
        Chat(COLOR_BAD .. "Enter a new custom preset name first." .. COLOR_RESET, true)
        return false
    end

    local preset = GetCustomPresetByKey(ADGM.vars.selectedPreset)
    if not preset then
        Chat(COLOR_BAD .. "Select a custom preset first." .. COLOR_RESET, true)
        return false
    end

    preset.name = name
    local store = GetCustomPresetStore()
    if store then
        store.draftName = name
    end
    NotifyPresetControlsChanged()
    Chat("Renamed custom preset to " .. name .. ".", true)
    return true
end

local function DeleteSelectedCustomPreset()
    local store = GetCustomPresetStore()
    local preset, id = GetCustomPresetByKey(ADGM.vars.selectedPreset)
    if not preset or not id then
        Chat(COLOR_BAD .. "Select a custom preset first." .. COLOR_RESET, true)
        return false
    end

    store.presets[id] = nil
    for index = #store.order, 1, -1 do
        if tostring(store.order[index]) == tostring(id) then
            table.remove(store.order, index)
        end
    end
    ADGM.vars.selectedPreset = "custom"
    store.draftName = ""
    NotifyPresetControlsChanged()
    Chat("Deleted custom preset: " .. tostring(preset.name) .. ".", true)
    return true
end

local function PrintCustomPresets()
    local store = GetCustomPresetStore()
    if not store or #store.order == 0 then
        Chat("No custom presets saved.", true)
        return
    end

    Chat("Custom presets:", true)
    for _, id in ipairs(store.order) do
        local preset = store.presets[tostring(id)]
        if preset then
            Chat("- " .. tostring(preset.name), true)
        end
    end
end

local function ApplyChannelPreset(channels)
    local target = ADGM.vars.autoInvite.channels
    target.say = channels.say == true
    target.yell = channels.yell == true
    target.zone = channels.zone == true
    target.whisper = channels.whisper == true
    target.group = channels.group == true
    target.guild1 = channels.guild1 == true
    target.guild2 = channels.guild2 == true
    target.guild3 = channels.guild3 == true
    target.guild4 = channels.guild4 == true
    target.guild5 = channels.guild5 == true
end

local SetTwelvePlayerRelistThreshold

local function ApplyPreset(key)
    local customPreset, customId = GetCustomPresetByKey(key)
    if customPreset then
        ADGM.vars.selectedPreset = CUSTOM_PRESET_PREFIX .. customId
        local store = GetCustomPresetStore()
        if store then
            store.draftName = customPreset.name or ""
        end
        ADGM.state.applyingPreset = true
        local ok = ApplyAutomationPresetSettings(customPreset.settings)
        ADGM.state.applyingPreset = false
        if not ok then
            Chat(COLOR_BAD .. "Custom preset is missing settings: " .. tostring(customPreset.name) .. COLOR_RESET, true)
            return
        end
        RefreshAutomationAfterPresetApply()
        Chat("Applied custom preset: " .. tostring(customPreset.name) .. ".", true)
        return
    end

    if key == "custom" then
        ADGM.vars.selectedPreset = key
        Chat("Preset set to Custom. Current settings were kept.", true)
        NotifyPresetControlsChanged()
        return
    end

    local preset = PRESETS[key]
    if not preset then
        Chat(COLOR_BAD .. "Unknown preset: " .. tostring(key) .. COLOR_RESET, true)
        return
    end

    ADGM.vars.selectedPreset = key
    ADGM.state.applyingPreset = true
    SetTargetGroupSize(preset.size)
    ADGM.vars.autoInvite.enabled = true
    ADGM.vars.autoInvite.triggers = preset.triggers
    ApplyChannelPreset(preset.channels)

    ADGM.vars.groupFinder.relistOnLeave = true
    ADGM.vars.groupFinder.mode = preset.relistMode
    SetTwelvePlayerRelistThreshold(preset.relistThreshold or DEFAULTS.groupFinder.twelvePlayerRelistThreshold)

    ADGM.vars.offlineGuard.enabled = true
    ADGM.vars.offlineGuard.action = preset.offlineAction
    ADGM.vars.offlineGuard.timeoutSeconds = preset.offlineTimeout

    ADGM.vars.zoneGuard.enabled = true
    ADGM.vars.zoneGuard.action = preset.zoneAction
    ADGM.vars.zoneGuard.graceSeconds = preset.zoneGrace
    ADGM.vars.zoneGuard.timeoutSeconds = preset.zoneTimeout
    ADGM.state.applyingPreset = false

    RefreshAutomationAfterPresetApply()
    Chat("Applied preset: " .. preset.label .. ".", true)
end

local function SetGroupFinderRelistOnLeave(value)
    MarkCustomPreset()
    ADGM.vars.groupFinder.relistOnLeave = value == true
    NotifyPresetControlsChanged()
end

local function SetGroupFinderMode(value)
    MarkCustomPreset()
    ADGM.vars.groupFinder.mode = value
    if value == ACTION_AUTO then
        ADGM.vars.groupFinder.relistOnLeave = true
    end
    NotifyPresetControlsChanged()
end

local function SetGroupFinderAutoAcceptApplications(value)
    MarkCustomPreset()
    ADGM.vars.groupFinder.autoAcceptApplications = value == true
    NotifyPresetControlsChanged()
end

SetTwelvePlayerRelistThreshold = function(value)
    MarkCustomPreset()
    local threshold = math.floor(tonumber(value) or DEFAULTS.groupFinder.twelvePlayerRelistThreshold)
    ADGM.vars.groupFinder.twelvePlayerRelistThreshold = zo_min(11, zo_max(1, threshold))
    NotifyPresetControlsChanged()
end


-- Export locals used by later manifest files.
ADGM.COLOR_TITLE = COLOR_TITLE
ADGM.COLOR_GOOD = COLOR_GOOD
ADGM.COLOR_WARN = COLOR_WARN
ADGM.COLOR_BAD = COLOR_BAD
ADGM.COLOR_RESET = COLOR_RESET
ADGM.ACTION_NOTIFY = ACTION_NOTIFY
ADGM.ACTION_WOULD_KICK = ACTION_WOULD_KICK
ADGM.ACTION_AUTO = ACTION_AUTO
ADGM.GROUP_FINDER_FAILURE_BACKOFF_SECONDS = GROUP_FINDER_FAILURE_BACKOFF_SECONDS
ADGM.GROUP_FINDER_BLOCKED_RETRY_SECONDS = GROUP_FINDER_BLOCKED_RETRY_SECONDS
ADGM.GROUP_FINDER_AUTO_RELIST_DELAY_SECONDS = GROUP_FINDER_AUTO_RELIST_DELAY_SECONDS
ADGM.GROUP_FINDER_STEP_DELAY_MS = GROUP_FINDER_STEP_DELAY_MS
ADGM.GROUP_LEFT_RELIST_RECHECK_MS = GROUP_LEFT_RELIST_RECHECK_MS
ADGM.SAVED_VARIABLES_VERSION = SAVED_VARIABLES_VERSION
ADGM.GUARD_TIMER_NAME = GUARD_TIMER_NAME
ADGM.GUARD_CHECK_INTERVAL_SECONDS = GUARD_CHECK_INTERVAL_SECONDS
ADGM.GUARD_CHECK_INTERVAL_MS = GUARD_CHECK_INTERVAL_MS
ADGM.GUARD_MIN_INTERVAL_SECONDS = GUARD_MIN_INTERVAL_SECONDS
ADGM.OFFLINE_RETRY_SECONDS = OFFLINE_RETRY_SECONDS
ADGM.INVITE_COOLDOWN_SECONDS = INVITE_COOLDOWN_SECONDS
ADGM.ROLE_GUARD_WINDOW_SECONDS = ROLE_GUARD_WINDOW_SECONDS
ADGM.ROLE_GUARD_WINDOW_MS = ROLE_GUARD_WINDOW_MS
ADGM.ROLE_GUARD_BASELINE_DELAY_MS = ROLE_GUARD_BASELINE_DELAY_MS
ADGM.GROUP_FINDER_APPLICATION_ROLE_TTL_MS = GROUP_FINDER_APPLICATION_ROLE_TTL_MS
ADGM.GROUP_FINDER_APPLICATION_APPROVAL_TIMEOUT_MS = GROUP_FINDER_APPLICATION_APPROVAL_TIMEOUT_MS
ADGM.ROLE_GUARD_AVAILABLE = ROLE_GUARD_AVAILABLE
ADGM.RESTRICTION_ANYONE = RESTRICTION_ANYONE
ADGM.RESTRICTION_FRIENDS = RESTRICTION_FRIENDS
ADGM.RESTRICTION_GUILD = RESTRICTION_GUILD
ADGM.RESTRICTION_FRIENDS_GUILD = RESTRICTION_FRIENDS_GUILD
ADGM.EXPECTED_ZONE_PLAYER = EXPECTED_ZONE_PLAYER
ADGM.EXPECTED_ZONE_LEADER = EXPECTED_ZONE_LEADER
ADGM.EXPECTED_ZONE_LOCKED = EXPECTED_ZONE_LOCKED
ADGM.DEFAULTS = DEFAULTS
ADGM.CHANNEL_KEY_BY_TYPE = CHANNEL_KEY_BY_TYPE
ADGM.Chat = Chat
ADGM.Debug = Debug
ADGM.CopyDefaults = CopyDefaults
ADGM.CopySavedVarsTable = CopySavedVarsTable
ADGM.MigrateLegacySavedVars = MigrateLegacySavedVars
ADGM.GetNow = GetNow
ADGM.GetNowMs = GetNowMs
ADGM.CanUseLeaderActions = CanUseLeaderActions
ADGM.GetAutoRelistStartSize = GetAutoRelistStartSize
ADGM.CancelGroupFinderRelistRetry = CancelGroupFinderRelistRetry
ADGM.SetGroupFinderListingActive = SetGroupFinderListingActive
ADGM.SetGroupFinderListingSleeping = SetGroupFinderListingSleeping
ADGM.IsGroupFinderListingRuntimeArmed = IsGroupFinderListingRuntimeArmed
ADGM.ClearGroupFinderListingRuntimeState = ClearGroupFinderListingRuntimeState
ADGM.MaybeSleepGroupFinderListingForFullGroup = MaybeSleepGroupFinderListingForFullGroup
ADGM.ClearLeaderAutomationState = ClearLeaderAutomationState
ADGM.ApplyOffOnGameStartPolicy = ApplyOffOnGameStartPolicy
ADGM.IsAddonAwake = IsAddonAwake
ADGM.NormalizeName = NormalizeName
ADGM.UnitKey = UnitKey
ADGM.IsPlayerUnit = IsPlayerUnit
ADGM.GetUnitTagForName = GetUnitTagForName
ADGM.SplitTriggers = SplitTriggers
ADGM.GetCachedSocialLookup = GetCachedSocialLookup
ADGM.RegisterSocialCacheInvalidationEvents = RegisterSocialCacheInvalidationEvents
ADGM.RegisterLeaderUpdateEvents = RegisterLeaderUpdateEvents
ADGM.MarkCustomPreset = MarkCustomPreset
ADGM.SetTargetGroupSize = SetTargetGroupSize
ADGM.SetSyncKickSafetyWithTargetSize = SetSyncKickSafetyWithTargetSize
ADGM.PRESET_KEYS = PRESET_KEYS
ADGM.PRESET_LABELS = PRESET_LABELS
ADGM.CUSTOM_PRESET_PREFIX = CUSTOM_PRESET_PREFIX
ADGM.GetPresetChoices = GetPresetChoices
ADGM.GetPresetLabel = GetPresetLabel
ADGM.GetPresetTooltip = GetPresetTooltip
ADGM.IsPresetKeyValid = IsPresetKeyValid
ADGM.IsCustomPresetKey = IsCustomPresetKey
ADGM.CustomPresetHasGroupFinderTemplate = CustomPresetHasGroupFinderTemplate
ADGM.SaveCustomPreset = SaveCustomPreset
ADGM.UpdateSelectedCustomPreset = UpdateSelectedCustomPreset
ADGM.RenameSelectedCustomPreset = RenameSelectedCustomPreset
ADGM.DeleteSelectedCustomPreset = DeleteSelectedCustomPreset
ADGM.PrintCustomPresets = PrintCustomPresets
ADGM.GROUP_FINDER_SIZE_SMALL_VALUE = GROUP_FINDER_SIZE_SMALL_VALUE
ADGM.GROUP_FINDER_SIZE_STANDARD_VALUE = GROUP_FINDER_SIZE_STANDARD_VALUE
ADGM.GROUP_FINDER_SIZE_LARGE_VALUE = GROUP_FINDER_SIZE_LARGE_VALUE
ADGM.GROUP_FINDER_SPECIFIC_ROLE_TYPES = GROUP_FINDER_SPECIFIC_ROLE_TYPES
ADGM.GROUP_FINDER_ROLE_TYPES = GROUP_FINDER_ROLE_TYPES
ADGM.PRESETS = PRESETS
ADGM.SetTwelvePlayerRelistThreshold = SetTwelvePlayerRelistThreshold
ADGM.ApplyPreset = ApplyPreset
ADGM.SetGroupFinderRelistOnLeave = SetGroupFinderRelistOnLeave
ADGM.SetGroupFinderMode = SetGroupFinderMode
ADGM.SetGroupFinderAutoAcceptApplications = SetGroupFinderAutoAcceptApplications
