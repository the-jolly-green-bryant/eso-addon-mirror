RaidToolsGroup = {}

local function GetUnitTagByName(name)
	local unit_tag
	for i = 1, GetGroupSize() do
		unit_tag = 'group'..i
		if string.match(name, FixName(GetUnitName(unit_tag))) then return unit_tag end
	end
	return nil
end

function RaidToolsGroup.OnJoin(eventCode, memberName)
	memberName = FixName(memberName)
	if memberName == NAME then
		RaidTools.IndexGroup()
		if RaidTools.storage.modules.group_notifications then RaidTools.BaseMessage('You have joined a group.') end
	else
		RaidTools.RegisterGroupPlayer(memberName)
		local unit_tag = GetUnitTagByName(memberName)
		if unit_tag then
			if RaidTools.storage.modules.group_notifications then RaidTools.BaseMessage(ZO_LinkHandler_CreateDisplayNameLink(GetUnitDisplayName(unit_tag)).. ' joined the group') end
		end
	end
end

local GroupLeaveReason2String = {
	[GROUP_LEAVE_REASON_DESTROYED] = 'Destroyed',
	[GROUP_LEAVE_REASON_DISBAND] = 'Disbanded',
	[GROUP_LEAVE_REASON_KICKED] = 'Kicked',
	[GROUP_LEAVE_REASON_LEFT_BATTLEGROUND] = 'Battlegrounds over',
	[GROUP_LEAVE_REASON_VOLUNTARY] = 'Left'
}

function RaidToolsGroup.OnLeave(eventCode, memberName, reason, isLocalPlayer, isLeader, memberDisplayName, actionRequiredVote)
	RaidTools.DismemberGroupPlayer(FixName(memberName))
	if not IsUnitGrouped('player') then 
		RaidTools.IndexGroup()
	end
	if not RaidTools.storage.modules.group_notifications then return end
	if not isLocalPlayer then
		if reason ~= GROUP_LEAVE_REASON_DISBAND and reason ~= GROUP_LEAVE_REASON_DESTROYED then
			RaidTools.BaseMessage(ZO_LinkHandler_CreateDisplayNameLink(memberDisplayName).. ' left the group ('..GroupLeaveReason2String[reason]..')')
		end
	else
		if reason == GROUP_LEAVE_REASON_DISBAND then
			RaidTools.BaseMessage('Group has been disbanded.')
		else
			RaidTools.BaseMessage('You left the group.')
		end
	end
end