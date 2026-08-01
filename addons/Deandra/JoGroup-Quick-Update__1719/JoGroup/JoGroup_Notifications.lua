JoGroup = JoGroup or {}
local Jo = JoGroup
local inviteTime = 0

-------------------------------------------------------------------------------------------------
--  Notifications --
-------------------------------------------------------------------------------------------------
function Jo.LeaderUpdated(eventCode, leaderTag)
    Jo.RegisterDelayedRefresh(eventCode)

    if Jo.savedVars.show.notifications then
        if not IsUnitGrouped("player") then return end
        if not DoesUnitExist(leaderTag) then return end

        local name = ""
        if ZO_ShouldPreferUserId() then
            name = zo_strformat(SI_PLAYER_PRIMARY_AND_SECONDARY_NAME_FORMAT, GetUnitDisplayName(leaderTag), GetUnitName(leaderTag))
        else
            name = zo_strformat("<<2>><<1>>", GetUnitDisplayName(leaderTag), GetUnitName(leaderTag))
        end
        d(zo_strformat(SI_GROUP_NOTIFICATION_GROUP_LEADER_CHANGED, name))
    end
end

function Jo.NotifyUnitJoined(eventCode, memberName)
    if Jo.savedVars.show.notifications then
        d(zo_strformat(GetString(SI_JOGROUP_JOINED), memberName))
    end
end

function Jo.NotifyUnitLeft(eventCode, memberCharacterName, reason, isLocalPlayer, isLeader, memberDisplayName, actionRequiredVote)
    if Jo.savedVars.show.notifications then

        if reason == GROUP_LEAVE_REASON_VOLUNTARY then
            d(zo_strformat(SI_GROUPLEAVEREASON0, memberDisplayName, memberCharacterName))

        elseif reason == GROUP_LEAVE_REASON_KICKED then
            d(zo_strformat(SI_GROUPLEAVEREASON1, memberDisplayName, memberCharacterName))

        elseif reason == GROUP_LEAVE_REASON_DISBAND and isLeader then
            d(zo_strformat(SI_GROUPLEAVEREASON2, memberDisplayName, memberCharacterName))

        elseif reason == GROUP_LEAVE_REASON_DESTROYED and isLocalPlayer then
            d(GetString(SI_GROUPELECTIONFAILURE8))
        end
    end
end

function Jo.NotifyInvited(eventCode, inviterCharacterName, inviterDisplayName)
	if Jo.savedVars.show.notifications and inviterDisplayName ~= GetUnitDisplayName("player") then
        local name = ""
        if ZO_ShouldPreferUserId() then
            name = zo_strformat(SI_PLAYER_PRIMARY_AND_SECONDARY_NAME_FORMAT, inviterDisplayName, inviterCharacterName)
        else
            name = zo_strformat("<<2>><<1>>", inviterDisplayName, inviterCharacterName)
        end
		if (GetFrameTimeSeconds() - inviteTime) > 1 then
			d(zo_strformat(SI_GROUP_INVITE_MESSAGE, name))
		end
		inviteTime = GetFrameTimeSeconds()
	end
end
