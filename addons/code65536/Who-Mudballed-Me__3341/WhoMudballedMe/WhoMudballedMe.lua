local NAME = "WhoMudballedMe"

local PROJECTILES = {
	[86774] = "Mudball",
	[116879] = "Revelry Pie",
	[129540] = "Snowball",
}

EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, function( eventCode, addonName )
	if (addonName ~= NAME) then return end

	EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)

	for abilityId, abilityName in pairs(PROJECTILES) do
		local name = NAME .. abilityId

		EVENT_MANAGER:RegisterForEvent(name, EVENT_COMBAT_EVENT, function( ... )
			CHAT_ROUTER:AddSystemMessage(zo_strformat("[<<1>>] <<2>> from |H1:character:<<3>>|h[<<3>>]|h", os.date("%H:%M:%S", GetTimeStamp()), abilityName, select(7, ...)))
		end)

		EVENT_MANAGER:AddFilterForEvent(name, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
		EVENT_MANAGER:AddFilterForEvent(name, EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
		EVENT_MANAGER:AddFilterForEvent(name, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
	end
end)
