local LCCC = LibCodesCommonCode
local RCR = Raidificator

RCR.CB = {
	name = "RCR_CastBlocker",

	BLOCKED_IDS = {
		[ 40195] = true, -- Camouflaged Hunter
		[ 40478] = true, -- Inner Light
		[ 61489] = true, -- Revealing Flare
		[ 61519] = true, -- Lingering Flare
		[ 61524] = true, -- Blinding Flare
		[103564] = true, -- Temporal Guard
	},

	HOTBARS = {
		HOTBAR_CATEGORY_PRIMARY,
		HOTBAR_CATEGORY_BACKUP,
	},

	eligible = false,
	hooked = false,
}
local CB = RCR.CB

function CB.HasBlockedAbilitySlotted( )
	for _, hotbarCategory in ipairs(CB.HOTBARS) do
		for i = 3, 8 do
			if (CB.BLOCKED_IDS[GetSlotBoundId(i, hotbarCategory)]) then
				return true
			end
		end
	end
	return false
end

function CB.SetupHook( )
	ZO_PreHook("ZO_ActionBar_CanUseActionSlots", function( )
		if (CB.eligible and RCR.vars.castBlocker) then
			local slotIndex = tonumber(debug.traceback():match("ACTION_BUTTON_(%d)"))
			if (CB.BLOCKED_IDS[GetSlotBoundId(slotIndex)]) then
				ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, SI_RESPECRESULT6)
				ZO_ActionBar_OnActionButtonUp(slotIndex)
				return true
			end
		end
	end)
end

function CB.CheckHookStatus( )
	if (CB.eligible and RCR.vars.castBlocker and not CB.hooked) then
		CB.SetupHook()
		CB.hooked = true
	end
end

local function CombatStateChange( eventCode, inCombat )
	CB.eligible = inCombat and CB.HasBlockedAbilitySlotted()
	CB.CheckHookStatus()
end

LCCC.MonitorZoneChanges(CB.name, function( zoneId )
	if (RCR.GetZoneClassification(zoneId)) then
		EVENT_MANAGER:RegisterForEvent(CB.name, EVENT_PLAYER_COMBAT_STATE, CombatStateChange)
		CombatStateChange(nil, IsUnitInCombat("player"))
	else
		EVENT_MANAGER:UnregisterForEvent(CB.name, EVENT_PLAYER_COMBAT_STATE)
		CB.eligible = false
	end
end)
