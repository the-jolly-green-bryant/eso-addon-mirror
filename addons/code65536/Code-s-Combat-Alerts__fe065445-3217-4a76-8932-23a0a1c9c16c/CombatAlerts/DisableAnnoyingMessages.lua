local LCA = LibCombatAlerts
local CA2 = CombatAlerts2

local MESSAGES = {
	GetString("SI_ACTIONRESULT", ACTION_RESULT_IMMUNE),
	GetString(SI_ITEM_FORMAT_STR_ON_COOLDOWN),
}

local BLOCKED = {
	-- "Target is immune."
	[MESSAGES[1]] = true,
	[SOUNDS.ABILITY_TARGET_IMMUNE] = true,

	-- "Item not ready yet"
	[MESSAGES[2]] = true,
	[SOUNDS.ITEM_ON_COOLDOWN] = true,
}

local IsHooked = false

function CA2.DisableAnnoyingMessages( )
	if (IsHooked or not CA2.loaded or not CA2.sv.disableAnnoyingMessages) then return end
	IsHooked = true
	ZO_PreHook(ZO_RecentMessages, "ShouldDisplayMessage", function( _, message )
		return CA2.sv.disableAnnoyingMessages and BLOCKED[message]
	end)
end

function CA2.GetAnnoyingMessages( )
	return MESSAGES
end

function CA2.GetAnnoyingMessagesBlockList( )
	return BLOCKED
end

LCA.RunAfterInitialLoadscreen(CA2.DisableAnnoyingMessages)
