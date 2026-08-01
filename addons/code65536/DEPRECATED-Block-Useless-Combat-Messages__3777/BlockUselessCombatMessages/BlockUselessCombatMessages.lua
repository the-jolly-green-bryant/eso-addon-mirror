local NAME = "BlockUselessCombatMessages"

EVENT_MANAGER:RegisterForEvent(NAME, EVENT_PLAYER_ACTIVATED, function( )
	EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_PLAYER_ACTIVATED)

	local blocked = {
		-- "Target is immune."
		[GetString("SI_ACTIONRESULT", ACTION_RESULT_IMMUNE)] = true,
		[SOUNDS.ABILITY_TARGET_IMMUNE] = true,

		-- "Item not ready yet"
		[GetString(SI_ITEM_FORMAT_STR_ON_COOLDOWN)] = true,
		[SOUNDS.ITEM_ON_COOLDOWN] = true,
	}

	ZO_PreHook(ZO_RecentMessages, "ShouldDisplayMessage", function( _, message )
		return blocked[message]
	end)
end)
