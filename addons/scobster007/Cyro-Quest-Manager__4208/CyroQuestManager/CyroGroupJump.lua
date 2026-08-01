CyroQuestManager = CyroQuestManager or {}
local CQM = CyroQuestManager

function CQM.GroupMemberJoined()
	CQM.SharePvPQuests(true)
end

function CQM.GroupInviteReceived()
	--Stop Waiting For Group Invites
	EVENT_MANAGER:UnregisterForEvent(CQM.name, EVENT_GROUP_INVITE_RECEIVED)
	AcceptGroupInvite()

	CHAT_SYSTEM:SetChannel(CHAT_CHANNEL_PARTY)
end

function CQM.JumpGroup(username, autoInvite)
		--Leave Current Group
		if CQM.isInCyrodiil() then
			if IsPlayerInGroup(GetUnitName("player")) then GroupLeave() end
		end

		--Prepare AutoInvite String For Sending
		CHAT_SYSTEM:StartTextEntry(string.format("%s", autoInvite), CHAT_CHANNEL_WHISPER, username)
		--Wait For Group Invite
		EVENT_MANAGER:RegisterForEvent(CQM.name, EVENT_GROUP_INVITE_RECEIVED, CQM.GroupInviteReceived)
	
end

function CQM_JumpToGroup1()
	CQM.JumpGroup(CQM.svChar.Leader1, CQM.svChar.AutoInv1)
end

function CQM_JumpToGroup2()
	CQM.JumpGroup(CQM.svChar.Leader2, CQM.svChar.AutoInv2)
end