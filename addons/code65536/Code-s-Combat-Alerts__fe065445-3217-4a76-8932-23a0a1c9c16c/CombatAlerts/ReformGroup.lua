--[[
This is a rudimentary stub client for Raidificator's group reformation feature,
to auto-accept invites from a group leader who had recently disbanded the group.

The code here is active only if Raidificator is not installed.
]]--

LibCombatAlerts.RunAfterInitialLoadscreen(function( )
	local RCR = Raidificator
	if (type(RCR) == "table" and type(RCR.DTR) == "table") then return end

	local DTR = DungeonTrialReset
	if (type(DTR) == "table" and type(DTR.version) == "number" and DTR.version >= 1) then return end

	local name = "CA_ReformGroup"
	local allowance = 5000
	local disbandLeader = ""
	local disbandTime = 0
	local kickTime = 0

	EVENT_MANAGER:RegisterForEvent(name, EVENT_GROUP_MEMBER_LEFT, function( _, _, reason, isLocalPlayer, isLeader, memberDisplayName )
		if (not isLocalPlayer and isLeader and reason == GROUP_LEAVE_REASON_DISBAND) then
			disbandLeader = memberDisplayName
			disbandTime = GetGameTimeMilliseconds()
		elseif (isLocalPlayer and reason == GROUP_LEAVE_REASON_KICKED) then
			kickTime = GetGameTimeMilliseconds()
		end
	end)

	EVENT_MANAGER:RegisterForEvent(name, EVENT_GROUP_INVITE_RECEIVED, function( _, _, inviterDisplayName )
		if ( (inviterDisplayName == disbandLeader and GetGameTimeMilliseconds() - disbandTime < allowance) or
		     (GetGameTimeMilliseconds() - kickTime < allowance) ) then
			AcceptGroupInvite()
		end
	end)
end)
