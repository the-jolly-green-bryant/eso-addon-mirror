NoJumpToLeader = NoJumpToLeader or {}

function NoJumpToLeader_Initialize()
 if addonName ~= ADDON_NAME then return end
 EVENT_MANAGER:UnregisterForEvent( ADDON_NAME, EVENT_ADD_ON_LOADED )

	PLAYER_TO_PLAYER.control:UnregisterForEvent(EVENT_UNIT_CREATED)
	PLAYER_TO_PLAYER.control:UnregisterForEvent(EVENT_ZONE_UPDATE)
	PLAYER_TO_PLAYER.control:UnregisterForEvent(EVENT_GROUP_MEMBER_JOINED)
	PLAYER_TO_PLAYER.control:UnregisterForEvent(EVENT_LEADER_UPDATE)
	PLAYER_TO_PLAYER.control:UnregisterForEvent(EVENT_GROUP_MEMBER_LEFT)

end
EVENT_MANAGER:RegisterForEvent("NoJumpToLeader", EVENT_ADD_ON_LOADED, function(...) NoJumpToLeader_Initialize(...) end)

