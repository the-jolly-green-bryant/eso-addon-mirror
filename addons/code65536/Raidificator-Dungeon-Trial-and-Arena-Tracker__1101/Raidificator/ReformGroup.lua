local LCCC = LibCodesCommonCode
local RCR = Raidificator

RCR.DTR = {
	name = "RCR_DungeonTrialReset",
	version = 1,

	-- Time allowance for what is considered a "recent" disband or rejoin,
	-- mostly to accomodate for server response times
	allowance = 5000, -- 5 seconds

	-- Time delay between invites, to avoid dropped invites
	inviteDelays = {
		{ 200, 150 }, -- 150ms for high ping (200+)
		{ 100, 125 }, -- 125ms for medium ping (100-200)
		{   0, 100 }, -- 100ms for low ping
	},

	confirmationCount = 3,
	confirmationSensitivity = 1500, -- 1.5 seconds

	selfName = GetDisplayName(),
	members = { },
	disbandLeader = "",
	disbandTime = 0,
	kickTime = 0,
	requestTime = 0,
	requestCount = 0,
}
local DTR = RCR.DTR

function DTR.Initialize( )
	ZO_Dialogs_RegisterCustomDialog("RCR_DTR_SLASH_CONFIRM", {
		canQueue = true,
		gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC },
		title = { text = SI_RCR_DTR_TITLE },
		mainText = { text = SI_RCR_DTR_SLASH_CONFIRM },
		buttons = {
			{ text = SI_DIALOG_CONFIRM, callback = DTR.ReformGroup },
			{ text = SI_DIALOG_CANCEL },
		},
	})

	LCCC.RegisterSlashCommands(DTR.ReformGroupSlash, "/reformgroup")
	DTR.RegisterEventHandlers()
end


--------------------------------------------------------------------------------
-- Entry points
--------------------------------------------------------------------------------

function DTR.ReformGroupKeybind( )
	if (IsUnitGroupLeader("player")) then
		local currentTime = GetGameTimeMilliseconds()
		if (currentTime - DTR.requestTime < DTR.confirmationSensitivity) then
			DTR.requestCount = DTR.requestCount + 1
		else
			DTR.requestCount = 1
		end
		DTR.requestTime = currentTime

		if (DTR.requestCount < DTR.confirmationCount) then
			RCR.Msg(string.format(GetString(SI_RCR_KEYBIND_CONFIRM), GetString(SI_RCR_DTR_TITLE), DTR.confirmationCount - DTR.requestCount, DTR.confirmationSensitivity / 1000))
		else
			DTR.requestCount = 0
			DTR.ReformGroup()
		end
	else
		RCR.Msg(GetString(SI_GROUPNOTIFICATIONMESSAGE1))
	end
end

function DTR.ReformGroupSlash( )
	if (IsUnitGroupLeader("player")) then
		ZO_Dialogs_ShowDialog("RCR_DTR_SLASH_CONFIRM")
	else
		RCR.Msg(GetString(SI_GROUPNOTIFICATIONMESSAGE1))
	end
end


--------------------------------------------------------------------------------
-- Core functions
--------------------------------------------------------------------------------

function DTR.ReformGroup( )
	DTR.members = { }
	for i = 1, GetGroupSize() do
		local member = GetUnitDisplayName(GetGroupUnitTagByIndex(i))
		if (member and member ~= DTR.selfName) then
			table.insert(DTR.members, member)
		end
	end

	DTR.disbandTime = GetGameTimeMilliseconds()
	GroupDisband()
end

function DTR.InviteMember( index, delay )
	if (index > 0) then
		GroupInviteByName(DTR.members[index])
	end
	if (index < #DTR.members) then
		zo_callLater(function() DTR.InviteMember(index + 1, delay) end, delay)
	end
end

function DTR.GetInviteDelay( )
	local ping = GetLatency()
	if (ping < 1) then ping = 1 end

	for _, entry in ipairs(DTR.inviteDelays) do
		if (ping >= entry[1]) then
			return entry[2]
		end
	end
end

function DTR.RegisterEventHandlers( )
	EVENT_MANAGER:RegisterForEvent(DTR.name, EVENT_GROUP_MEMBER_LEFT, function( eventCode, memberCharacterName, reason, isLocalPlayer, isLeader, memberDisplayName, actionRequiredVote )
		if (isLeader and reason == GROUP_LEAVE_REASON_DISBAND) then
			local currentTime = GetGameTimeMilliseconds()
			if (not isLocalPlayer) then
				-- Disband not issued by you: prep for receiving invite
				DTR.disbandLeader = memberDisplayName
				DTR.disbandTime = currentTime
			elseif (currentTime - DTR.disbandTime < DTR.allowance) then
				-- Disband issued by player: reinvite the group
				DTR.InviteMember(0, DTR.GetInviteDelay())
			end
		elseif (isLocalPlayer and reason == GROUP_LEAVE_REASON_KICKED) then
			DTR.kickTime = GetGameTimeMilliseconds()
		end
	end)

	EVENT_MANAGER:RegisterForEvent(DTR.name, EVENT_GROUP_INVITE_RECEIVED, function( eventCode, inviterCharacterName, inviterDisplayName )
		if ( (inviterDisplayName == DTR.disbandLeader and GetGameTimeMilliseconds() - DTR.disbandTime < DTR.allowance) or
		     (GetGameTimeMilliseconds() - DTR.kickTime < DTR.allowance) ) then
			AcceptGroupInvite()
		end
	end)
end
