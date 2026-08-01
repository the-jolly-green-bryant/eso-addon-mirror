local ADGM = _G["ADawgsGroupManager"]
local COLOR_GOOD = ADGM.COLOR_GOOD
local COLOR_WARN = ADGM.COLOR_WARN
local COLOR_BAD = ADGM.COLOR_BAD
local COLOR_RESET = ADGM.COLOR_RESET
local ACTION_WOULD_KICK = ADGM.ACTION_WOULD_KICK
local ACTION_AUTO = ADGM.ACTION_AUTO
local GROUP_FINDER_AUTO_RELIST_DELAY_SECONDS = ADGM.GROUP_FINDER_AUTO_RELIST_DELAY_SECONDS
local GROUP_LEFT_RELIST_RECHECK_MS = ADGM.GROUP_LEFT_RELIST_RECHECK_MS
local GUARD_TIMER_NAME = ADGM.GUARD_TIMER_NAME
local GUARD_CHECK_INTERVAL_SECONDS = ADGM.GUARD_CHECK_INTERVAL_SECONDS
local GUARD_CHECK_INTERVAL_MS = ADGM.GUARD_CHECK_INTERVAL_MS
local GUARD_MIN_INTERVAL_SECONDS = ADGM.GUARD_MIN_INTERVAL_SECONDS
local OFFLINE_RETRY_SECONDS = ADGM.OFFLINE_RETRY_SECONDS
local INVITE_COOLDOWN_SECONDS = ADGM.INVITE_COOLDOWN_SECONDS
local ROLE_GUARD_WINDOW_SECONDS = ADGM.ROLE_GUARD_WINDOW_SECONDS
local ROLE_GUARD_WINDOW_MS = ADGM.ROLE_GUARD_WINDOW_MS
local ROLE_GUARD_BASELINE_DELAY_MS = ADGM.ROLE_GUARD_BASELINE_DELAY_MS
local GROUP_FINDER_APPLICATION_ROLE_TTL_MS = ADGM.GROUP_FINDER_APPLICATION_ROLE_TTL_MS
local ROLE_GUARD_AVAILABLE = ADGM.ROLE_GUARD_AVAILABLE
local RESTRICTION_ANYONE = ADGM.RESTRICTION_ANYONE
local RESTRICTION_FRIENDS = ADGM.RESTRICTION_FRIENDS
local RESTRICTION_GUILD = ADGM.RESTRICTION_GUILD
local RESTRICTION_FRIENDS_GUILD = ADGM.RESTRICTION_FRIENDS_GUILD
local EXPECTED_ZONE_LEADER = ADGM.EXPECTED_ZONE_LEADER
local EXPECTED_ZONE_LOCKED = ADGM.EXPECTED_ZONE_LOCKED
local DEFAULTS = ADGM.DEFAULTS
local CHANNEL_KEY_BY_TYPE = ADGM.CHANNEL_KEY_BY_TYPE
local Chat = ADGM.Chat
local Debug = ADGM.Debug
local GetNow = ADGM.GetNow
local GetNowMs = ADGM.GetNowMs
local CanUseLeaderActions = ADGM.CanUseLeaderActions
local GetAutoRelistStartSize = ADGM.GetAutoRelistStartSize
local SetGroupFinderListingSleeping = ADGM.SetGroupFinderListingSleeping
local IsGroupFinderListingRuntimeArmed = ADGM.IsGroupFinderListingRuntimeArmed
local ClearGroupFinderListingRuntimeState = ADGM.ClearGroupFinderListingRuntimeState
local MaybeSleepGroupFinderListingForFullGroup = ADGM.MaybeSleepGroupFinderListingForFullGroup
local ClearLeaderAutomationState = ADGM.ClearLeaderAutomationState
local IsAddonAwake = ADGM.IsAddonAwake
local NormalizeName = ADGM.NormalizeName
local UnitKey = ADGM.UnitKey
local IsPlayerUnit = ADGM.IsPlayerUnit
local GetUnitTagForName = ADGM.GetUnitTagForName
local SplitTriggers = ADGM.SplitTriggers
local GetCachedSocialLookup = ADGM.GetCachedSocialLookup
local MarkCustomPreset = ADGM.MarkCustomPreset

local ScheduleGroupFinderRelistRetry
local RefreshGuardTimer
local ScheduleOfflineGuardCheck
local KickUnit

local function TextMatchesTrigger(text)
    text = string.lower(zo_strtrim(text or ""))
    if text == "" then
        return false, nil
    end

    local rawTriggers = ADGM.vars.autoInvite.triggers or ""
    if ADGM.state.triggerCache.raw ~= rawTriggers then
        ADGM.state.triggerCache.raw = rawTriggers
        ADGM.state.triggerCache.triggers = SplitTriggers(rawTriggers)
    end

    local triggers = ADGM.state.triggerCache.triggers
    for _, trigger in ipairs(triggers) do
        if ADGM.vars.autoInvite.allowPartialMatch then
            if string.find(text, trigger, 1, true) then
                return true, trigger
            end
        elseif text == trigger then
            return true, trigger
        end
    end
    return false, nil
end

local function IsChannelAllowed(channelType)
    local key = CHANNEL_KEY_BY_TYPE[channelType]
    return key ~= nil and ADGM.vars.autoInvite.channels[key] == true
end

local function LookupFriend(lowerDisplayName)
    for i = 1, GetNumFriends() do
        local friendDisplayName = GetFriendInfo(i)
        if friendDisplayName and string.lower(friendDisplayName) == lowerDisplayName then
            return true
        end
    end
    return false
end

local function IsFriend(displayName)
    return GetCachedSocialLookup(ADGM.state.friendCache, displayName, LookupFriend)
end

local function LookupGuildMember(lowerDisplayName)
    for guildIndex = 1, GetNumGuilds() do
        local guildId = GetGuildId(guildIndex)
        if guildId then
            for memberIndex = 1, GetNumGuildMembers(guildId) do
                local memberDisplayName = GetGuildMemberInfo(guildId, memberIndex)
                if memberDisplayName and string.lower(memberDisplayName) == lowerDisplayName then
                    return true
                end
            end
        end
    end
    return false
end

local function IsGuildMember(displayName)
    return GetCachedSocialLookup(ADGM.state.guildMemberCache, displayName, LookupGuildMember)
end

local function PassesRestriction(displayName)
    local restriction = ADGM.vars.autoInvite.restriction
    if restriction == RESTRICTION_ANYONE then
        return true
    elseif restriction == RESTRICTION_FRIENDS then
        return IsFriend(displayName)
    elseif restriction == RESTRICTION_GUILD then
        return IsGuildMember(displayName)
    elseif restriction == RESTRICTION_FRIENDS_GUILD then
        return IsFriend(displayName) or IsGuildMember(displayName)
    end
    return false
end

local function IsSelfDisplayName(displayName)
    local normalizedName = NormalizeName(displayName)
    local playerDisplayName = NormalizeName(GetDisplayName())
    return normalizedName and playerDisplayName and string.lower(normalizedName) == string.lower(playerDisplayName)
end

local function IsSelfName(name)
    local normalizedName = NormalizeName(name)
    if not normalizedName then
        return false
    end

    local lowerName = string.lower(normalizedName)
    local playerDisplayName = NormalizeName(GetDisplayName())
    if playerDisplayName and lowerName == string.lower(playerDisplayName) then
        return true
    end

    local playerCharacterName = NormalizeName(GetUnitName("player"))
    return playerCharacterName and lowerName == string.lower(playerCharacterName)
end

local function GetRoleLabel(role)
    if role == LFG_ROLE_TANK then
        return "tank"
    elseif role == LFG_ROLE_HEAL then
        return "healer"
    elseif role == LFG_ROLE_DPS then
        return "damage"
    elseif role == LFG_ROLE_INVALID then
        return "no role"
    end
    return "unknown"
end

local function IsTrackableRole(role)
    return role == LFG_ROLE_TANK
        or role == LFG_ROLE_HEAL
        or role == LFG_ROLE_DPS
end

local function AddApplicationRoleAlias(entry, name)
    name = NormalizeName(name)
    if not entry or not name then
        return
    end

    entry.keys = entry.keys or {}
    entry.keys[name] = true
    ADGM.state.groupFinderApplicationRoles[name] = entry
end

local function ClearApplicationRole(entry)
    if not entry or not entry.keys then
        return
    end

    for key in pairs(entry.keys) do
        ADGM.state.groupFinderApplicationRoles[key] = nil
    end
end

function ADGM.StoreGroupFinderApplicationRole(displayName, characterName, role, characterId)
    if not IsTrackableRole(role) then
        Debug("Group Finder application role ignored: " .. GetRoleLabel(role) .. ".")
        return
    end

    local key = NormalizeName(displayName and displayName ~= "" and displayName or characterName)
    if not key then
        return
    end

    local entry = {
        role = role,
        characterId = characterId,
        expiresAtMs = GetNowMs() + GROUP_FINDER_APPLICATION_ROLE_TTL_MS,
        keys = {},
    }

    AddApplicationRoleAlias(entry, displayName)
    AddApplicationRoleAlias(entry, characterName)
    Debug("Stored Group Finder application role for " .. tostring(key) .. ": " .. GetRoleLabel(role) .. ".")

    zo_callLater(function()
        if ADGM.state.groupFinderApplicationRoles[key] == entry then
            ClearApplicationRole(entry)
        end
    end, GROUP_FINDER_APPLICATION_ROLE_TTL_MS)
end

local function ConsumeGroupFinderApplicationRole(unitTag)
    local displayName = NormalizeName(GetUnitDisplayName(unitTag))
    local characterName = NormalizeName(GetUnitName(unitTag))
    local entry = (displayName and ADGM.state.groupFinderApplicationRoles[displayName])
        or (characterName and ADGM.state.groupFinderApplicationRoles[characterName])

    if not entry then
        return nil
    end

    ClearApplicationRole(entry)
    if GetNowMs() > (entry.expiresAtMs or 0) then
        return nil
    end
    return entry.role
end

local function ClearRoleTracking(key)
    key = NormalizeName(key)
    if key then
        local entry = ADGM.state.roles[key]
        if entry and entry.keys then
            for alias in pairs(entry.keys) do
                ADGM.state.roles[alias] = nil
            end
            if entry.unitTags then
                for unitTag in pairs(entry.unitTags) do
                    ADGM.state.roleUnitTags[unitTag] = nil
                end
            end
        else
            ADGM.state.roles[key] = nil
        end
    end
end

local function AddRoleTrackingAlias(entry, alias)
    alias = NormalizeName(alias)
    if not entry or not alias then
        return
    end

    entry.keys = entry.keys or {}
    entry.keys[alias] = true
    ADGM.state.roles[alias] = entry
end

local function AddRoleTrackingUnitAliases(entry, unitTag)
    if not entry or not unitTag then
        return
    end

    entry.unitTags = entry.unitTags or {}
    entry.unitTags[unitTag] = true
    ADGM.state.roleUnitTags[unitTag] = entry.primaryKey
    AddRoleTrackingAlias(entry, GetUnitDisplayName(unitTag))
    AddRoleTrackingAlias(entry, GetUnitName(unitTag))
end

local function GetRoleTrackingEntryForUnit(unitTag)
    local unitKey = ADGM.state.roleUnitTags[unitTag]
    if unitKey and ADGM.state.roles[unitKey] then
        return ADGM.state.roles[unitKey], unitKey
    end

    local displayName = NormalizeName(GetUnitDisplayName(unitTag))
    local characterName = NormalizeName(GetUnitName(unitTag))

    if displayName and ADGM.state.roles[displayName] then
        local entry = ADGM.state.roles[displayName]
        AddRoleTrackingUnitAliases(entry, unitTag)
        return entry, displayName
    end
    if characterName and ADGM.state.roles[characterName] then
        local entry = ADGM.state.roles[characterName]
        AddRoleTrackingUnitAliases(entry, unitTag)
        return entry, characterName
    end

    return nil, displayName or characterName
end

local function ScheduleRoleGuardExpiry(key, token)
    key = NormalizeName(key)
    if not key then
        return
    end

    zo_callLater(function()
        local entry = ADGM.state.roles[key]
        if entry and entry.token == token then
            ClearRoleTracking(key)
        end
    end, ROLE_GUARD_WINDOW_MS + 100)
end

local function CanUseRoleGuard()
    return ROLE_GUARD_AVAILABLE
        and ADGM.vars
        and ADGM.vars.enabled
        and ADGM.vars.roleGuard
        and ADGM.vars.roleGuard.enabled
        and CanUseLeaderActions()
end

local function EnsureRoleGuardEntryForUnit(unitTag)
    if not unitTag or not ZO_Group_IsGroupUnitTag(unitTag) or IsPlayerUnit(unitTag) or IsUnitOnline(unitTag) == false then
        return nil, nil
    end

    local key = UnitKey(unitTag)
    key = NormalizeName(key)
    if not key or IsSelfName(key) then
        return nil, nil
    end

    local nowMs = GetNowMs()
    local entry = ADGM.state.roles[key]
    if not entry then
        ADGM.state.roleGuardSerial = (ADGM.state.roleGuardSerial or 0) + 1
        entry = {
            primaryKey = key,
            startedAtMs = nowMs,
            expiresAtMs = nowMs + ROLE_GUARD_WINDOW_MS,
            token = ADGM.state.roleGuardSerial,
            keys = {},
            unitTags = {},
        }
    end

    AddRoleTrackingAlias(entry, key)
    AddRoleTrackingUnitAliases(entry, unitTag)
    return entry, key
end

local function SetRoleGuardBaseline(entry, key, role, unitTag, reason)
    if not entry or not IsTrackableRole(role) then
        return false
    end

    entry.baselineRole = role
    entry.baselineAtMs = GetNowMs()
    AddRoleTrackingUnitAliases(entry, unitTag)
    Debug("Role Guard baseline for " .. tostring(key) .. ": " .. GetRoleLabel(role)
        .. (reason and " (" .. reason .. ")" or "") .. ".")
    return true
end

local function ApplyRoleGuardAction(key, unitTag, newRole)
    if ADGM.vars.roleGuard.action == ACTION_AUTO then
        KickUnit(unitTag, "role changed", true)
    elseif ADGM.vars.roleGuard.action == ACTION_WOULD_KICK then
        Chat(COLOR_WARN .. "Would kick " .. tostring(key) .. " (role changed)." .. COLOR_RESET)
    else
        Chat(COLOR_WARN .. tostring(key) .. " changed role to " .. GetRoleLabel(newRole) .. "." .. COLOR_RESET)
    end
    ClearRoleTracking(key)
end

local function HandleRoleGuardRole(unitTag, newRole, baselineReason)
    local entry, key = GetRoleTrackingEntryForUnit(unitTag)
    if not entry or not key then
        return
    end

    key = NormalizeName(key)
    if not key or IsSelfName(key) then
        return
    end

    if not IsTrackableRole(newRole) then
        Debug("Ignored transient role change for " .. tostring(key) .. ": " .. GetRoleLabel(newRole))
        return
    end

    AddRoleTrackingUnitAliases(entry, unitTag)

    if GetNowMs() > (entry.expiresAtMs or 0) then
        ClearRoleTracking(key)
        Debug("Ignored role change for " .. tostring(key) .. " outside Role Guard window.")
        return
    end

    if not entry.baselineRole then
        SetRoleGuardBaseline(entry, key, newRole, unitTag, baselineReason or "first role")
        return
    end

    if newRole ~= entry.baselineRole then
        ApplyRoleGuardAction(key, unitTag, newRole)
    end
end

local function TrySetRoleGuardBaselineFromUnit(key, unitTag, reason)
    key = NormalizeName(key)
    if not key then
        return false
    end

    if not unitTag or IsPlayerUnit(unitTag) or IsUnitOnline(unitTag) == false or UnitKey(unitTag) ~= key then
        return false
    end

    local entry = ADGM.state.roles[key]
    if not entry then
        return false
    end
    if GetNowMs() > (entry.expiresAtMs or 0) then
        ClearRoleTracking(key)
        return false
    end

    local role = GetGroupMemberSelectedRole(unitTag)
    if IsTrackableRole(role) then
        return SetRoleGuardBaseline(entry, key, role, unitTag, reason)
    end
    return false
end

local function TrackUnitCreatedForRoleGuard(unitTag)
    if not CanUseRoleGuard()
        or not unitTag
        or not ZO_Group_IsGroupUnitTag(unitTag)
        or IsPlayerUnit(unitTag)
    then
        return
    end

    local entry, key = GetRoleTrackingEntryForUnit(unitTag)
    if not entry then
        return
    end
    AddRoleTrackingUnitAliases(entry, unitTag)

    local token = entry.token
    ScheduleRoleGuardExpiry(key, token)
    local applicationRole = ConsumeGroupFinderApplicationRole(unitTag)
    if IsTrackableRole(applicationRole) then
        SetRoleGuardBaseline(entry, key, applicationRole, unitTag, "application")
        zo_callLater(function()
            local currentEntry = ADGM.state.roles[key]
            if currentEntry
                and currentEntry.token == token
                and currentEntry.baselineRole == applicationRole
                and UnitKey(unitTag) == key
            then
                HandleRoleGuardRole(unitTag, GetGroupMemberSelectedRole(unitTag), "application verify")
            end
        end, ROLE_GUARD_BASELINE_DELAY_MS)
        return
    end

    zo_callLater(function()
        local currentEntry = ADGM.state.roles[key]
        if not currentEntry
            or currentEntry.token ~= token
            or currentEntry.baselineRole ~= nil
        then
            return
        end

        if GetNowMs() > (currentEntry.expiresAtMs or 0) then
            ClearRoleTracking(key)
            return
        end

        if UnitKey(unitTag) ~= key then
            ClearRoleTracking(key)
            return
        end

        TrySetRoleGuardBaselineFromUnit(key, unitTag, "unit created")
    end, ROLE_GUARD_BASELINE_DELAY_MS)
end

local function TrackMemberJoinedForRoleGuard(memberCharacterName, memberDisplayName)
    if not CanUseRoleGuard() then
        return
    end

    local key = NormalizeName(memberDisplayName and memberDisplayName ~= "" and memberDisplayName or memberCharacterName)
    if not key or IsSelfName(key) then
        return
    end

    zo_callLater(function()
        if not CanUseRoleGuard() then
            return
        end

        local unitTag = GetUnitTagForName(key)
        if not unitTag or IsPlayerUnit(unitTag) or IsUnitOnline(unitTag) == false then
            return
        end

        local entry, entryKey = EnsureRoleGuardEntryForUnit(unitTag)
        if not entry then
            return
        end

        ScheduleRoleGuardExpiry(entryKey, entry.token)
        if entry.baselineRole then
            return
        end

        local applicationRole = ConsumeGroupFinderApplicationRole(unitTag)
        if IsTrackableRole(applicationRole) then
            SetRoleGuardBaseline(entry, entryKey, applicationRole, unitTag, "application")
            HandleRoleGuardRole(unitTag, GetGroupMemberSelectedRole(unitTag), "application verify")
            return
        end

        TrySetRoleGuardBaselineFromUnit(entryKey, unitTag, "member joined")
    end, ROLE_GUARD_BASELINE_DELAY_MS)
end

function ADGM.OnUnitCreated(eventCode, unitTag)
    if not unitTag or not ZO_Group_IsGroupUnitTag(unitTag) then
        return
    end

    TrackUnitCreatedForRoleGuard(unitTag)
end

function ADGM.OnUnitDestroyed(eventCode, unitTag)
    if not unitTag or not ZO_Group_IsGroupUnitTag(unitTag) then
        return
    end

    local key = ADGM.state.roleUnitTags[unitTag]
    if key then
        ClearRoleTracking(key)
    end
end

local function InviteByDisplayName(displayName, trigger)
    if not ADGM.vars
        or not ADGM.vars.enabled
        or not ADGM.vars.autoInvite.enabled
        or not IsAddonAwake()
    then
        return
    end
    if not displayName or displayName == "" then
        return
    end
    if IsSelfDisplayName(displayName) then
        Debug("Invite skipped, trigger came from the current player.")
        return
    end
    local cooldownKey = string.lower(NormalizeName(displayName) or displayName)
    local now = GetNow()
    local lastInviteAt = ADGM.state.inviteCooldown[cooldownKey] or 0
    if now - lastInviteAt < INVITE_COOLDOWN_SECONDS then
        Debug("Invite skipped, recent invite already sent to " .. tostring(displayName) .. ".")
        return
    end
    if GetGroupSize() >= ADGM.vars.targetGroupSize then
        Debug("Invite skipped, target group size reached.")
        return
    end
    if not CanUseLeaderActions() then
        Debug("Invite skipped, not group leader.")
        return
    end
    GroupInviteByName(displayName)
    ADGM.state.inviteCooldown[cooldownKey] = now
    Chat("Invited " .. COLOR_GOOD .. displayName .. COLOR_RESET .. " from trigger " .. COLOR_WARN .. trigger .. COLOR_RESET .. ".")
end

function ADGM.OnChatMessage(eventCode, channelType, fromName, text, isCustomerService, fromDisplayName)
    if not ADGM.vars.enabled or not ADGM.vars.autoInvite.enabled then
        return
    end
    if not IsAddonAwake() then
        return
    end
    if isCustomerService then
        return
    end
    if not IsChannelAllowed(channelType) then
        return
    end

    local matches, trigger = TextMatchesTrigger(text)
    if not matches then
        return
    end

    local inviteName = fromDisplayName and fromDisplayName ~= "" and fromDisplayName or fromName
    if not PassesRestriction(inviteName) then
        Debug("Invite skipped by restriction: " .. tostring(inviteName))
        return
    end

    local delay = ADGM.vars.autoInvite.delayMs or 0
    if delay > 0 then
        zo_callLater(function()
            InviteByDisplayName(inviteName, trigger)
        end, delay)
    else
        InviteByDisplayName(inviteName, trigger)
    end
end

function ADGM.OnMemberJoined(eventCode, memberCharacterName, memberDisplayName)
    if GetGroupSize() > 0 and not CanUseLeaderActions() then
        ClearLeaderAutomationState("not group leader")
        ADGM.state.lastKnownGroupSize = GetGroupSize()
        RefreshGuardTimer()
        return
    end

    local key = NormalizeName(memberDisplayName and memberDisplayName ~= "" and memberDisplayName or memberCharacterName)
    if key and not IsSelfName(key) then
        ADGM.state.joinedAt[key] = GetNow()
        ADGM.state.offline[key] = nil
        ADGM.state.wrongZone[key] = nil
        TrackMemberJoinedForRoleGuard(memberCharacterName, memberDisplayName)
    end
    ADGM.state.lastKnownGroupSize = GetGroupSize()
    MaybeSleepGroupFinderListingForFullGroup()
    if ADGM.vars and ADGM.vars.enabled and ADGM.vars.offlineGuard.enabled then
        ADGM.CheckOfflineGuard()
    end
    if ADGM.vars and ADGM.vars.enabled and ADGM.vars.zoneGuard.enabled then
        local nextZoneCheckSeconds = ADGM.CheckZoneGuard()
        if nextZoneCheckSeconds then
            RefreshGuardTimer(math.floor(math.max(GUARD_MIN_INTERVAL_SECONDS, nextZoneCheckSeconds) * 1000))
        else
            RefreshGuardTimer()
        end
    else
        RefreshGuardTimer()
    end
end

local function ShouldAutoRelistAfterMemberLeft(currentGroupSize)
    if ADGM.vars.groupFinder.onlyWhenBelowTargetSize
        and currentGroupSize >= (ADGM.vars.targetGroupSize or DEFAULTS.targetGroupSize)
    then
        MaybeSleepGroupFinderListingForFullGroup()
        Debug("Auto-relist sleeping because group is at/above target size.")
        return false
    end

    local startSize = GetAutoRelistStartSize()
    if ADGM.vars.targetGroupSize == 12 and ADGM.vars.selectedPreset ~= "trialFill" then
        if currentGroupSize > startSize then
            if ADGM.state.groupFinderListingActive then
                SetGroupFinderListingSleeping("above re-list threshold")
            end
            Debug("Auto-relist sleeping until group size is " .. tostring(startSize) .. " or lower.")
            return false
        end
    end

    ADGM.state.groupFinderListingSleeping = false
    ADGM.state.groupFinderListingSleepReason = nil
    return true
end

local function CanAutoRelistCurrentGroup()
    if not ADGM.vars
        or not ADGM.vars.enabled
        or not ADGM.vars.groupFinder
        or not ADGM.vars.groupFinder.relistOnLeave
        or ADGM.vars.groupFinder.mode ~= ACTION_AUTO
        or not ADGM.vars.groupFinder.savedListing
        or not IsGroupFinderListingRuntimeArmed()
        or GetGroupSize() == 0
        or not CanUseLeaderActions()
    then
        return false
    end

    return ShouldAutoRelistAfterMemberLeft(GetGroupSize())
end

ScheduleGroupFinderRelistRetry = function(delaySeconds, reason, announce)
    if not ADGM.RelistSavedGroupFinderListing or not CanAutoRelistCurrentGroup() then
        return false
    end

    local now = GetNow()
    local delay = zo_max(1, math.floor(tonumber(delaySeconds) or 1))
    local backoffRemaining = (ADGM.state.groupFinderBackoffUntil or 0) - now
    if backoffRemaining > delay then
        delay = math.floor(backoffRemaining) + 1
    end
    local cooldownSeconds = ADGM.vars.groupFinder.cooldownSeconds or DEFAULTS.groupFinder.cooldownSeconds
    local cooldownRemaining = cooldownSeconds - (now - (ADGM.state.lastRelistAttempt or 0))
    if cooldownRemaining > delay then
        delay = math.floor(cooldownRemaining) + 1
    end

    ADGM.state.groupFinderRetryToken = (ADGM.state.groupFinderRetryToken or 0) + 1
    local token = ADGM.state.groupFinderRetryToken
    ADGM.state.pendingGroupFinderRetryAt = now + delay
    ADGM.state.pendingGroupFinderRetryReason = reason

    if announce then
        Debug("Group Finder create was blocked by ESO. Retrying automatically in " .. tostring(delay) .. " seconds.")
    end

    zo_callLater(function()
        if ADGM.state.groupFinderRetryToken ~= token then
            return
        end
        ADGM.state.pendingGroupFinderRetryAt = 0
        ADGM.state.pendingGroupFinderRetryReason = nil
        if CanAutoRelistCurrentGroup() then
            ADGM.RelistSavedGroupFinderListing(reason or "auto retry")
        end
    end, delay * 1000)

    return true
end

local function HandleAutoRelistAfterMemberLeft(localPlayerLeft)
    local currentGroupSize = GetGroupSize()

    if localPlayerLeft or currentGroupSize == 0 then
        ClearGroupFinderListingRuntimeState("left group")
        ADGM.state.lastKnownGroupSize = currentGroupSize
        return
    end

    if ADGM.vars.enabled
        and ADGM.vars.groupFinder.relistOnLeave
        and CanUseLeaderActions()
    then
        local now = GetNow()
        if not ShouldAutoRelistAfterMemberLeft(currentGroupSize) then
            ADGM.state.lastKnownGroupSize = currentGroupSize
            return
        end

        if ADGM.vars.groupFinder.mode == ACTION_AUTO and ADGM.RelistSavedGroupFinderListing then
            if now - (ADGM.state.lastRelistNotice or 0) > 5 then
                ADGM.state.lastRelistNotice = now
                Debug("Group member left. Scheduling Group Finder re-list with saved template.")
            end
            ScheduleGroupFinderRelistRetry(GROUP_FINDER_AUTO_RELIST_DELAY_SECONDS, "member left")
        elseif now - (ADGM.state.lastRelistNotice or 0) > 5 then
            ADGM.state.lastRelistNotice = now
            Chat(COLOR_WARN .. "Group member left. Run /adgm gfrelist to create the saved Group Finder listing." .. COLOR_RESET)
        end
    end

    ADGM.state.lastKnownGroupSize = currentGroupSize
end

local function ScheduleAutoRelistAfterMemberLeft(localPlayerLeft)
    zo_callLater(function()
        HandleAutoRelistAfterMemberLeft(localPlayerLeft)
    end, GROUP_LEFT_RELIST_RECHECK_MS)
end

function ADGM.OnMemberLeft(eventCode, memberCharacterName, reason, isLocalPlayer, isLeader, memberDisplayName)
    local currentGroupSize = GetGroupSize()
    local playerDisplayName = GetDisplayName()
    local playerCharacterName = GetUnitName("player")
    local localPlayerLeft = isLocalPlayer == true
        or (playerDisplayName and memberDisplayName == playerDisplayName)
        or (playerCharacterName and memberCharacterName == playerCharacterName)

    if not localPlayerLeft and currentGroupSize > 0 and not CanUseLeaderActions() then
        ClearLeaderAutomationState("not group leader")
        ADGM.state.lastKnownGroupSize = currentGroupSize
        RefreshGuardTimer()
        return
    end

    local key = NormalizeName(memberDisplayName and memberDisplayName ~= "" and memberDisplayName or memberCharacterName)
    if key then
        if ADGM.state.offline[key] then
            ADGM.state.offline[key].checkToken = (ADGM.state.offline[key].checkToken or 0) + 1
        end
        ADGM.state.joinedAt[key] = nil
        ADGM.state.offline[key] = nil
        ADGM.state.wrongZone[key] = nil
        ClearRoleTracking(key)
    end
    if localPlayerLeft or currentGroupSize == 0 then
        ClearGroupFinderListingRuntimeState("left group")
        ADGM.state.roles = {}
        ADGM.state.roleUnitTags = {}
        ADGM.state.groupFinderApplicationRoles = {}
        ADGM.state.groupFinderApplicationApprovals = {}
        ADGM.state.groupFinderApplicationApprovalQueue = {}
        ADGM.state.groupFinderApplicationApprovalInFlight = nil
        ADGM.state.groupFinderApplicationApprovalToken = (ADGM.state.groupFinderApplicationApprovalToken or 0) + 1
    end
    if ADGM.vars and ADGM.vars.enabled and ADGM.vars.zoneGuard.enabled then
        local nextZoneCheckSeconds = ADGM.CheckZoneGuard()
        if nextZoneCheckSeconds then
            RefreshGuardTimer(math.floor(math.max(GUARD_MIN_INTERVAL_SECONDS, nextZoneCheckSeconds) * 1000))
        else
            RefreshGuardTimer()
        end
    else
        RefreshGuardTimer()
    end

    ScheduleAutoRelistAfterMemberLeft(localPlayerLeft)
end

function ADGM.OnMemberConnectedStatus(eventCode, unitTag, isOnline)
    if not ADGM.vars.enabled or not ADGM.vars.offlineGuard.enabled or not CanUseLeaderActions() then
        return
    end

    local key = UnitKey(unitTag)
    if not key then
        return
    end

    if isOnline then
        if ADGM.state.offline[key] then
            ADGM.state.offline[key].checkToken = (ADGM.state.offline[key].checkToken or 0) + 1
        end
        ADGM.state.offline[key] = nil
        RefreshGuardTimer()
        return
    end

    ADGM.state.offline[key] = ADGM.state.offline[key] or {
        firstSeen = GetNow(),
        warned = false,
        checkToken = 0,
    }
    ScheduleOfflineGuardCheck(key, ADGM.vars.offlineGuard.timeoutSeconds)
    RefreshGuardTimer()
end

local function GetExpectedZoneIndex()
    local mode = ADGM.vars.zoneGuard.expectedZone
    if mode == EXPECTED_ZONE_LOCKED then
        return ADGM.vars.zoneGuard.lockedZoneIndex
    elseif mode == EXPECTED_ZONE_LEADER and GetGroupSize() > 0 then
        for i = 1, GetGroupSize() do
            local unitTag = GetGroupUnitTagByIndex(i)
            if IsUnitGroupLeader(unitTag) then
                return GetUnitZoneIndex(unitTag)
            end
        end
    end
    return GetUnitZoneIndex("player")
end

local function MinPositive(current, candidate)
    if not candidate or candidate <= 0 then
        return current
    end
    if not current or candidate < current then
        return candidate
    end
    return current
end

KickUnit = function(unitTag, reason, bypassSafety)
    if not unitTag or not CanUseLeaderActions() then
        return false
    end
    local groupSize = GetGroupSize()
    local safetyMinimum = ADGM.vars.minGroupSizeForAutoKick or DEFAULTS.minGroupSizeForAutoKick
    if not bypassSafety and groupSize < safetyMinimum then
        local skipKey = tostring(UnitKey(unitTag) or unitTag) .. ":" .. tostring(reason)
        if not ADGM.state.safetySkipLogged[skipKey] then
            ADGM.state.safetySkipLogged[skipKey] = true
            Debug("Skipped auto-kick for " .. tostring(UnitKey(unitTag) or unitTag)
                .. " because group size " .. tostring(groupSize)
                .. " is below the safety minimum " .. tostring(safetyMinimum) .. ".")
        end
        return false
    end
    ADGM.state.safetySkipLogged[tostring(UnitKey(unitTag) or unitTag) .. ":" .. tostring(reason)] = nil
    GroupKick(unitTag)
    Chat(COLOR_BAD .. "Kicked " .. tostring(UnitKey(unitTag)) .. COLOR_RESET .. " (" .. reason .. ").")
    return true
end

function ADGM.OnGroupMemberRoleChanged(eventCode, unitTag, newRole)
    if not CanUseRoleGuard()
        or not unitTag
        or not ZO_Group_IsGroupUnitTag(unitTag)
        or IsPlayerUnit(unitTag)
    then
        return
    end

    HandleRoleGuardRole(unitTag, newRole, "first role")
end

local function ResolveOfflineMemberUnitTag(key)
    local unitTag = GetUnitTagForName(key)
    if unitTag and UnitKey(unitTag) then
        return unitTag
    end
    return nil
end

local function HandleOfflineGuardForKey(key, unitTag)
    if not ADGM.vars.enabled or not ADGM.vars.offlineGuard.enabled or not CanUseLeaderActions() then
        return
    end

    local entry = ADGM.state.offline[key]
    if not entry then
        return
    end

    unitTag = unitTag or ResolveOfflineMemberUnitTag(key)
    if not unitTag or IsUnitOnline(unitTag) ~= false then
        ADGM.state.offline[key] = nil
        RefreshGuardTimer()
        return
    end

    local now = GetNow()
    local firstSeen = entry.firstSeen or now
    entry.firstSeen = firstSeen
    local elapsed = now - firstSeen
    local timeout = ADGM.vars.offlineGuard.timeoutSeconds or DEFAULTS.offlineGuard.timeoutSeconds
    if elapsed >= timeout then
        if ADGM.vars.offlineGuard.action == ACTION_AUTO then
            if KickUnit(unitTag, "offline") then
                ADGM.state.offline[key] = nil
                RefreshGuardTimer()
            else
                ScheduleOfflineGuardCheck(key, OFFLINE_RETRY_SECONDS)
            end
        elseif not entry.warned then
            entry.warned = true
            Chat(COLOR_WARN .. key .. " has been offline for " .. tostring(elapsed) .. " seconds." .. COLOR_RESET)
        end
    else
        ScheduleOfflineGuardCheck(key, timeout - elapsed)
    end
end

ScheduleOfflineGuardCheck = function(key, delaySeconds)
    if not key then
        return
    end

    local entry = ADGM.state.offline[key]
    if not entry then
        return
    end

    entry.checkToken = (entry.checkToken or 0) + 1
    local token = entry.checkToken
    local delayMs = zo_max(0, math.floor((delaySeconds or 0) * 1000))
    zo_callLater(function()
        local current = ADGM.state.offline[key]
        if current and current.checkToken == token then
            HandleOfflineGuardForKey(key)
        end
    end, delayMs)
end

local function RescheduleOfflineGuardChecks()
    for key in pairs(ADGM.state.offline) do
        HandleOfflineGuardForKey(key)
    end
end

function ADGM.CheckOfflineGuard()
    if not ADGM.vars.enabled or not ADGM.vars.offlineGuard.enabled or not CanUseLeaderActions() then
        return
    end

    local now = GetNow()
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        local key = UnitKey(unitTag)
        if key then
            if IsUnitOnline(unitTag) == false then
                local entry = ADGM.state.offline[key] or { firstSeen = now, warned = false, checkToken = 0 }
                ADGM.state.offline[key] = entry
                HandleOfflineGuardForKey(key, unitTag)
            else
                if ADGM.state.offline[key] then
                    ADGM.state.offline[key].checkToken = (ADGM.state.offline[key].checkToken or 0) + 1
                end
                ADGM.state.offline[key] = nil
            end
        end
    end
end

function ADGM.CheckZoneGuard()
    if not ADGM.vars.enabled or not ADGM.vars.zoneGuard.enabled or not CanUseLeaderActions() then
        return nil
    end

    local expectedZone = GetExpectedZoneIndex()
    if not expectedZone then
        return nil
    end

    local now = GetNow()
    local hasWatchedMember = false
    local nextCheckSeconds = nil
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        if not IsPlayerUnit(unitTag) and IsUnitOnline(unitTag) then
            hasWatchedMember = true
            local key = UnitKey(unitTag)
            if key then
                local joinedAt = ADGM.state.joinedAt[key] or now
                ADGM.state.joinedAt[key] = joinedAt

                local graceRemaining = (ADGM.vars.zoneGuard.graceSeconds or 0) - (now - joinedAt)
                if graceRemaining > 0 then
                    nextCheckSeconds = MinPositive(nextCheckSeconds, graceRemaining)
                else
                    local zoneIndex = GetUnitZoneIndex(unitTag)
                    if zoneIndex and zoneIndex ~= 0 and zoneIndex ~= expectedZone then
                        local entry = ADGM.state.wrongZone[key] or { firstSeen = now, warned = false }
                        ADGM.state.wrongZone[key] = entry
                        local elapsed = now - entry.firstSeen
                        local timeout = ADGM.vars.zoneGuard.timeoutSeconds or DEFAULTS.zoneGuard.timeoutSeconds
                        local remaining = timeout - elapsed
                        if remaining <= 0 then
                            if ADGM.vars.zoneGuard.action == ACTION_AUTO then
                                if KickUnit(unitTag, "wrong zone") then
                                    ADGM.state.wrongZone[key] = nil
                                else
                                    nextCheckSeconds = MinPositive(nextCheckSeconds, OFFLINE_RETRY_SECONDS)
                                end
                            elseif not entry.warned then
                                entry.warned = true
                                Chat(COLOR_WARN .. key .. " is in another zone." .. COLOR_RESET)
                            end
                        else
                            nextCheckSeconds = MinPositive(nextCheckSeconds, math.min(remaining, GUARD_CHECK_INTERVAL_SECONDS))
                        end
                    else
                        ADGM.state.wrongZone[key] = nil
                        nextCheckSeconds = MinPositive(nextCheckSeconds, GUARD_CHECK_INTERVAL_SECONDS)
                    end
                end
            end
        end
    end

    if hasWatchedMember then
        return nextCheckSeconds or GUARD_CHECK_INTERVAL_SECONDS
    end
    return nil
end

function ADGM.CheckGuards()
    if not ADGM.vars.enabled then
        return
    end
    if not ADGM.vars.offlineGuard.enabled and not ADGM.vars.zoneGuard.enabled then
        return
    end
    if GetGroupSize() == 0 then
        return
    end
    if not CanUseLeaderActions() then
        RefreshGuardTimer()
        return
    end
    ADGM.CheckOfflineGuard()
    local nextZoneCheckSeconds = ADGM.CheckZoneGuard()
    if nextZoneCheckSeconds then
        RefreshGuardTimer(math.floor(math.max(GUARD_MIN_INTERVAL_SECONDS, nextZoneCheckSeconds) * 1000))
    else
        RefreshGuardTimer()
    end
end

RefreshGuardTimer = function(intervalMs)
    if not ADGM.vars then
        return
    end

    local shouldRun = ADGM.vars.enabled
        and CanUseLeaderActions()
        and ADGM.vars.zoneGuard.enabled
        and GetGroupSize() > 0
    local desiredIntervalMs = intervalMs or GUARD_CHECK_INTERVAL_MS

    if shouldRun and (not ADGM.state.guardTimerActive or ADGM.state.guardTimerIntervalMs ~= desiredIntervalMs) then
        if ADGM.state.guardTimerActive then
            EVENT_MANAGER:UnregisterForUpdate(GUARD_TIMER_NAME)
        end
        EVENT_MANAGER:RegisterForUpdate(GUARD_TIMER_NAME, desiredIntervalMs, ADGM.CheckGuards)
        ADGM.state.guardTimerActive = true
        ADGM.state.guardTimerIntervalMs = desiredIntervalMs
    elseif not shouldRun and ADGM.state.guardTimerActive then
        EVENT_MANAGER:UnregisterForUpdate(GUARD_TIMER_NAME)
        ADGM.state.guardTimerActive = false
        ADGM.state.guardTimerIntervalMs = nil
    end
end

function ADGM.OnLeadershipChanged()
    RefreshGuardTimer()
    if not ADGM.vars or not ADGM.vars.enabled or GetGroupSize() == 0 then
        return
    end
    if not CanUseLeaderActions() then
        ClearLeaderAutomationState("not group leader")
        return
    end

    if ADGM.vars.offlineGuard.enabled then
        ADGM.CheckOfflineGuard()
    end

    if ADGM.vars.zoneGuard.enabled then
        local nextZoneCheckSeconds = ADGM.CheckZoneGuard()
        if nextZoneCheckSeconds then
            RefreshGuardTimer(math.floor(math.max(GUARD_MIN_INTERVAL_SECONDS, nextZoneCheckSeconds) * 1000))
        end
    end
end

local function SetAddonEnabled(value)
    MarkCustomPreset()
    ADGM.vars.enabled = value == true
    if not ADGM.vars.enabled then
        ClearLeaderAutomationState("disabled")
    end
    RefreshGuardTimer()
    if ADGM.vars.enabled and ADGM.vars.offlineGuard.enabled then
        ADGM.CheckOfflineGuard()
    end
end

local function SetOfflineGuardEnabled(value)
    MarkCustomPreset()
    ADGM.vars.offlineGuard.enabled = value == true
    if ADGM.vars.offlineGuard.enabled then
        ADGM.CheckOfflineGuard()
    else
        for _, entry in pairs(ADGM.state.offline) do
            entry.checkToken = (entry.checkToken or 0) + 1
        end
        ADGM.state.offline = {}
    end
    RefreshGuardTimer()
end

local function SetZoneGuardEnabled(value)
    MarkCustomPreset()
    ADGM.vars.zoneGuard.enabled = value == true
    if ADGM.vars.zoneGuard.enabled then
        local nextZoneCheckSeconds = ADGM.CheckZoneGuard()
        if nextZoneCheckSeconds then
            RefreshGuardTimer(math.floor(math.max(GUARD_MIN_INTERVAL_SECONDS, nextZoneCheckSeconds) * 1000))
            return
        end
    else
        ADGM.state.wrongZone = {}
    end
    RefreshGuardTimer()
end

local function RefreshZoneGuardAfterSetting()
    if ADGM.vars.enabled and ADGM.vars.zoneGuard.enabled then
        local nextZoneCheckSeconds = ADGM.CheckZoneGuard()
        if nextZoneCheckSeconds then
            RefreshGuardTimer(math.floor(math.max(GUARD_MIN_INTERVAL_SECONDS, nextZoneCheckSeconds) * 1000))
        else
            RefreshGuardTimer()
        end
    else
        RefreshGuardTimer()
    end
end

local function SetZoneGuardExpectedZone(value)
    MarkCustomPreset()
    ADGM.vars.zoneGuard.expectedZone = value
    RefreshZoneGuardAfterSetting()
end

local function SetZoneGuardAction(value)
    MarkCustomPreset()
    ADGM.vars.zoneGuard.action = value
    RefreshZoneGuardAfterSetting()
end

local function SetZoneGuardGraceSeconds(value)
    MarkCustomPreset()
    ADGM.vars.zoneGuard.graceSeconds = value
    RefreshZoneGuardAfterSetting()
end

local function SetZoneGuardTimeoutSeconds(value)
    MarkCustomPreset()
    ADGM.vars.zoneGuard.timeoutSeconds = value
    RefreshZoneGuardAfterSetting()
end

local function SetRoleGuardEnabled(value)
    MarkCustomPreset()
    ADGM.vars.roleGuard.enabled = value == true
    if not ADGM.vars.roleGuard.enabled then
        ADGM.state.roles = {}
        ADGM.state.roleUnitTags = {}
    elseif ADGM.WarnRoleGuardAutoAcceptConflict then
        ADGM.WarnRoleGuardAutoAcceptConflict("role guard enabled")
    end
end

local function SetRoleGuardAction(value)
    MarkCustomPreset()
    ADGM.vars.roleGuard.action = value
end

local function GetRoleGuardActionLabel()
    if ADGM.vars.roleGuard.action == ACTION_AUTO then
        return "auto kick"
    elseif ADGM.vars.roleGuard.action == ACTION_WOULD_KICK then
        return "would kick"
    end
    return "notify"
end

local function SetOfflineGuardTimeout(value)
    MarkCustomPreset()
    ADGM.vars.offlineGuard.timeoutSeconds = value
    RescheduleOfflineGuardChecks()
end

local function PrintStatus()
    Chat("Status: target size " .. tostring(ADGM.vars.targetGroupSize) .. ", current size " .. tostring(GetGroupSize()) .. ".", true)
    local listing = ADGM.vars.groupFinder and ADGM.vars.groupFinder.savedListing
    local gfMode = ADGM.vars.groupFinder.mode == ACTION_AUTO and "auto" or "notify"
    local awakeState = (GetGroupSize() > 0 and not CanUseLeaderActions()) and "passive/not leader"
        or (IsAddonAwake() and "awake" or "passive")
    local listingState = ADGM.state.groupFinderListingActive and "active"
        or (ADGM.state.groupFinderListingSleeping and ("sleeping/" .. tostring(ADGM.state.groupFinderListingSleepReason or "unknown")))
        or "inactive"
    Chat("Automation: " .. awakeState .. ", listing " .. listingState .. ".", true)
    Chat("Group Finder: template " .. (listing and COLOR_GOOD .. "saved" or COLOR_WARN .. "not saved") .. COLOR_RESET
        .. ", relist on leave " .. tostring(ADGM.vars.groupFinder.relistOnLeave)
        .. ", action " .. gfMode
        .. ", cooldown " .. tostring(ADGM.vars.groupFinder.cooldownSeconds or DEFAULTS.groupFinder.cooldownSeconds) .. "s"
        .. ", below target only " .. tostring(ADGM.vars.groupFinder.onlyWhenBelowTargetSize) .. ".", true)
    Chat("Role Guard: " .. tostring(ADGM.vars.roleGuard.enabled)
        .. ", action " .. GetRoleGuardActionLabel()
        .. ", window " .. tostring(ROLE_GUARD_WINDOW_SECONDS) .. "s.", true)
    if listing then
        Chat("Saved listing: category=" .. tostring(listing.category)
            .. ", size=" .. tostring(listing.groupSize)
            .. ", playstyle=" .. tostring(listing.playstyle)
            .. ", title=" .. tostring(listing.title or "") .. ".", true)
    end
    if ADGM.state.lastGroupFinderResult ~= nil then
        if ADGM.state.lastGroupFinderEventCode == EVENT_GROUP_FINDER_REMOVE_GROUP_LISTING_RESULT then
            Chat("Group Finder: last remove reason " .. ADGM.FormatRemoveGroupListingReason(ADGM.state.lastGroupFinderResult) .. ".", true)
        else
            Chat("Group Finder: last result " .. ADGM.FormatGroupFinderActionResult(ADGM.state.lastGroupFinderResult) .. ".", true)
        end
    end
    local backoffRemaining = (ADGM.state.groupFinderBackoffUntil or 0) - GetNow()
    if backoffRemaining > 0 then
        Chat("Group Finder: ESO block backoff " .. tostring(backoffRemaining) .. "s remaining.", true)
    end
    local retryRemaining = (ADGM.state.pendingGroupFinderRetryAt or 0) - GetNow()
    if retryRemaining > 0 then
        Chat("Group Finder: automatic retry in " .. tostring(retryRemaining) .. "s.", true)
    end
    if GetGroupSize() == 0 then
        return
    end
    local expectedZone = GetExpectedZoneIndex()
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        local name = UnitKey(unitTag) or unitTag
        local online = IsUnitOnline(unitTag)
        local zoneIndex = GetUnitZoneIndex(unitTag)
        local marker = online and COLOR_GOOD .. "online" .. COLOR_RESET or COLOR_BAD .. "offline" .. COLOR_RESET
        local zoneText = tostring(zoneIndex or "?")
        if expectedZone and zoneIndex and zoneIndex ~= expectedZone then
            zoneText = COLOR_WARN .. zoneText .. COLOR_RESET
        end
        Chat(name .. ": " .. marker .. ", zone " .. zoneText, true)
    end
end


-- Export locals used by later manifest files.
ADGM.GetRoleLabel = GetRoleLabel
ADGM.ScheduleGroupFinderRelistRetry = ScheduleGroupFinderRelistRetry
ADGM.RescheduleOfflineGuardChecks = RescheduleOfflineGuardChecks
ADGM.RefreshGuardTimer = RefreshGuardTimer
ADGM.SetAddonEnabled = SetAddonEnabled
ADGM.SetOfflineGuardEnabled = SetOfflineGuardEnabled
ADGM.SetZoneGuardEnabled = SetZoneGuardEnabled
ADGM.SetZoneGuardExpectedZone = SetZoneGuardExpectedZone
ADGM.SetZoneGuardAction = SetZoneGuardAction
ADGM.SetZoneGuardGraceSeconds = SetZoneGuardGraceSeconds
ADGM.SetZoneGuardTimeoutSeconds = SetZoneGuardTimeoutSeconds
ADGM.SetRoleGuardEnabled = SetRoleGuardEnabled
ADGM.SetRoleGuardAction = SetRoleGuardAction
ADGM.SetOfflineGuardTimeout = SetOfflineGuardTimeout
ADGM.PrintStatus = PrintStatus
