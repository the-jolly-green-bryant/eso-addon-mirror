AutoReadyCheck = AutoReadyCheck or {}

--- Group Ready Checks
-- Fires when another player initiates the ReadyCheck
local function OnGroupElectionNotificationAdded(_eventCode)
    local groupElectionInfo = GetGroupElectionInfo()
    if groupElectionInfo.electionType == GROUP_ELECTION_TYPE_KICK_MEMBER then return end -- dont auto kick

    if HasPendingGroupElectionVote() then
        CastGroupVote(GROUP_VOTE_CHOICE_FOR)
    end
end

local function RegisterGroupElectionEvent()
    EVENT_MANAGER:RegisterForEvent(
        AutoReadyCheck.name,
        EVENT_GROUP_ELECTION_NOTIFICATION_ADDED,
        OnGroupElectionNotificationAdded
    )
end

local function UnregisterGroupElectionEvent()
    EVENT_MANAGER:UnregisterForEvent(
        AutoReadyCheck.name,
        EVENT_GROUP_ELECTION_NOTIFICATION_ADDED
    )
end

function AutoReadyCheck.GetGroupElection()
    return AutoReadyCheck.settings.groupEnabled
end

function AutoReadyCheck.SetGroupElection(val)
    AutoReadyCheck.settings.groupEnabled = val

    -- If Enabled
    if val then
        RegisterGroupElectionEvent()
    else
        UnregisterGroupElectionEvent()
    end

    return AutoReadyCheck.SendToggleMessage(val, SI_ACTIVITYFINDERSTATUS4)
end

function AutoReadyCheck.GroupElectionToggle()
    local toggle = not AutoReadyCheck.settings.groupEnabled
    AutoReadyCheck.SetGroupElection(toggle)
end

function AutoReadyCheck:InitGroupElection()
    if not self.GetGroupElection() then return end

    RegisterGroupElectionEvent()
end