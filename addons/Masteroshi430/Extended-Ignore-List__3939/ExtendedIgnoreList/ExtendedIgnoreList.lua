IGNORE_DATA = 1
IGNORE_LIST_ENTRY_SORT_KEYS =
{
    ["displayName"] = { },
}

ZO_IgnoreList = ZO_SocialManager:Subclass()

local EVENT_NAMESPACE = "IgnoreList"

-- Duration constants (seconds)
local SECONDS_PER_DAY    = 86400
local SECONDS_PER_WEEK   = 604800
local SECONDS_PER_MONTH  = SECONDS_PER_WEEK * 4
local SECONDS_PER_YEAR   = SECONDS_PER_WEEK * 52

-- Ordered list of ban durations used to build both the context menu and the label text
local IGNORE_DURATIONS =
{
    { label = "one day",   seconds = SECONDS_PER_DAY },
    { label = "one week",  seconds = SECONDS_PER_WEEK },
    { label = "one month", seconds = SECONDS_PER_MONTH },
    { label = "one year",  seconds = SECONDS_PER_YEAR },
}

-- How often (ms) we proactively re-check for expired temp-ignores instead of only on player activation
local EXPIRY_CHECK_INTERVAL = 60000

-- Safety window (seconds): if EVENT_IGNORE_ADDED never fires for a pending request
-- (e.g. the ignore attempt silently failed), drop it so it can't misapply to some
-- unrelated future ignore of the same displayName.
local PENDING_DURATION_TTL = 30

function ZO_IgnoreList:New()
    local manager = ZO_SocialManager.New(self)
    ZO_IgnoreList.Initialize(manager)
    return manager
end

function ZO_IgnoreList:Initialize()

    -- displayName -> seconds to add, once EVENT_IGNORE_ADDED confirms the ignore actually landed.
    -- Replaces the old "wait 5s and hope it's done" callLater approach.
    self.pendingDurations = {}

    self.noteEditedFunction = function(displayName, newNote)
        local index = self:GetDisplaynameIndex(displayName)
        if index then
            SetIgnoreNote(index, newNote)
        end
    end

    self:BuildMasterList()

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_SOCIAL_DATA_LOADED, function() self:OnSocialDataLoaded() end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_IGNORE_ADDED, function(_, displayName) self:OnIgnoreAdded(displayName) end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_IGNORE_REMOVED, function(_, displayName) self:OnIgnoreRemoved(displayName) end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_IGNORE_NOTE_UPDATED, function(_, displayName, note) self:OnIgnoreNoteUpdated(displayName, note) end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, function() self:CheckExpiredIgnores() end)

    -- Periodic sweep so auto-unban isn't gated behind a zone change / reload
    EVENT_MANAGER:RegisterForUpdate(EVENT_NAMESPACE .. "ExpiryCheck", EXPIRY_CHECK_INTERVAL, function() self:CheckExpiredIgnores() end)
end

function ZO_IgnoreList:SetupEntry(control, data, selected)
    control.displayName = data.displayName

    GetControl(control, "DisplayName"):SetText(ZO_FormatUserFacingDisplayName(data.displayName))

    local note = GetControl(control, "Note")
    if note then
        note:SetHidden(data.note == "")
    end
end

function ZO_IgnoreList:BuildMasterList()
    ZO_ClearNumericallyIndexedTable(self.masterList)
    local numIgnored = GetNumIgnored()
    for i = 1, numIgnored do
        local displayName, note = GetIgnoredInfo(i)

        local ignoreListEntry = {
            displayName = displayName,
            note = note,
            type = SOCIAL_NAME_SEARCH,
            ignoreIndex = i,
        }
        self.masterList[i] = ignoreListEntry
    end
end

function ZO_IgnoreList:GetNoteEditedFunction()
    return self.noteEditedFunction
end

-- Addon functions
----------

function ZO_IgnoreList:GetDisplaynameIndex(displayName)
    local numIgnored = GetNumIgnored()
    for i = 1, numIgnored do
        local storedDisplayName = GetIgnoredInfo(i)
        if storedDisplayName == displayName then
            return i
        end
    end
end

function ZO_IgnoreList:SetPendingDuration(displayName, durationSeconds)
    self.pendingDurations[displayName] = { seconds = durationSeconds, requestTime = GetTimeStamp() }
end

-- Called once we KNOW the ignore has been registered (EVENT_IGNORE_ADDED), not on a blind timer.
function ZO_IgnoreList:ApplyPendingDuration(displayName)
    local pending = self.pendingDurations[displayName]
    if not pending then return end
    self.pendingDurations[displayName] = nil

    -- Guard against a stale/unrelated ignore-add event arriving long after the original request.
    if GetTimeStamp() - pending.requestTime > PENDING_DURATION_TTL then return end

    local index = self:GetDisplaynameIndex(displayName)
    if not index then return end

    local expiryTimestamp = GetTimeStamp() + pending.seconds
    SetIgnoreNote(index, tostring(expiryTimestamp))

    local link = ZO_LinkHandler_CreateLink(displayName, nil, "display", displayName)
    d("|cffffff[Extended Ignore List]:|r " .. link .. " has been temporarily ignored.")
end

-- Addon Events

function ZO_IgnoreList:CheckExpiredIgnores()
    local now = GetTimeStamp()
    local expiredNames = {}

    -- Collect first, then remove after the loop: removing mid-iteration reshuffles
    -- GetIgnoredInfo indices and could cause us to skip an entry.
    for i = 1, GetNumIgnored() do
        local displayName, note = GetIgnoredInfo(i)
        local endOfBan = tonumber(note) or 0
        if endOfBan ~= 0 and endOfBan < now then
            expiredNames[#expiredNames + 1] = displayName
        end
    end

    for _, displayName in ipairs(expiredNames) do
        RemoveIgnore(displayName)
        local link = ZO_LinkHandler_CreateLink(displayName, nil, "display", displayName)
        d("|cffffff[Extended Ignore List]:|r " .. link .. " has been auto-unbanned.")
    end

    self:PurgeStalePendingDurations(now)
end

-- Entries can go stale without EVENT_IGNORE_ADDED or EVENT_IGNORE_REMOVED ever firing
-- (e.g. a silently failed ignore attempt), so this sweep is the only thing guaranteed
-- to reclaim them.
function ZO_IgnoreList:PurgeStalePendingDurations(now)
    now = now or GetTimeStamp()
    for displayName, pending in pairs(self.pendingDurations) do
        if now - pending.requestTime > PENDING_DURATION_TTL then
            self.pendingDurations[displayName] = nil
        end
    end
end

--Events
------------

function ZO_IgnoreList:OnSocialDataLoaded()
    self:RefreshData()
end

function ZO_IgnoreList:OnIgnoreAdded(displayName)
    self:ApplyPendingDuration(displayName)
    self:RefreshData()
end

function ZO_IgnoreList:OnIgnoreRemoved(displayName)
    self.pendingDurations[displayName] = nil
    self:RefreshData()
end

function ZO_IgnoreList:OnIgnoreNoteUpdated(displayName, note)
    self:RefreshData()
end


-- A singleton will be used by both keyboard and gamepad screens
IGNORE_LIST_MANAGER = ZO_IgnoreList:New()


-- function overwrite for addon
function SharedChatSystem:ShowPlayerContextMenu(playerName, rawName)
    ClearMenu()

    -- Add to/Remove from Group
    if IsGroupModificationAvailable() then
        local localPlayerIsGrouped = IsUnitGrouped("player")
        local localPlayerIsGroupLeader = IsUnitGroupLeader("player")
        local otherPlayerIsInPlayersGroup = IsPlayerInGroup(rawName)
        if not localPlayerIsGrouped or (localPlayerIsGroupLeader and not otherPlayerIsInPlayersGroup) then
            AddMenuItem(GetString(SI_CHAT_PLAYER_CONTEXT_ADD_GROUP), function()
            local SENT_FROM_CHAT = false
            local DISPLAY_INVITED_MESSAGE = true
            TryGroupInviteByName(playerName, SENT_FROM_CHAT, DISPLAY_INVITED_MESSAGE) end)
        elseif otherPlayerIsInPlayersGroup and localPlayerIsGroupLeader then
            AddMenuItem(GetString(SI_CHAT_PLAYER_CONTEXT_REMOVE_GROUP), function() GroupKickByName(rawName) end)
        end
    end

    -- Whisper
    AddMenuItem(GetString(SI_CHAT_PLAYER_CONTEXT_WHISPER), function() self:StartTextEntry(nil, CHAT_CHANNEL_WHISPER, playerName) end)

    -- Ignore
    if not IsIgnored(playerName) then

        local entries = {}
        for _, duration in ipairs(IGNORE_DURATIONS) do
            entries[#entries + 1] = {
                label = GetString(SI_CHAT_PLAYER_CONTEXT_ADD_IGNORE) .. " " .. duration.label,
                callback = function()
                    IGNORE_LIST_MANAGER:SetPendingDuration(playerName, duration.seconds)
                    ZO_PlatformIgnorePlayer(playerName)
                end,
            }
        end
        entries[#entries + 1] = {
            label = GetString(SI_CHAT_PLAYER_CONTEXT_ADD_IGNORE) .. " permanently",
            callback = function() ZO_PlatformIgnorePlayer(playerName) end,
        }

        AddCustomSubMenuItem(GetString(SI_CHAT_PLAYER_CONTEXT_ADD_IGNORE), entries)
    end

    -- Add Friend
    if not IsFriend(playerName) then
        AddMenuItem(GetString(SI_CHAT_PLAYER_CONTEXT_ADD_FRIEND), function() ZO_Dialogs_ShowDialog("REQUEST_FRIEND", { name = playerName }) end)
    end

    -- Report player
    AddMenuItem(zo_strformat(SI_CHAT_PLAYER_CONTEXT_REPORT, rawName), function()
        ZO_HELP_GENERIC_TICKET_SUBMISSION_MANAGER:OpenReportPlayerTicketScene(playerName)
    end)

    if ZO_Menu_GetNumMenuItems() > 0 then
        ShowMenu()
    end
end
