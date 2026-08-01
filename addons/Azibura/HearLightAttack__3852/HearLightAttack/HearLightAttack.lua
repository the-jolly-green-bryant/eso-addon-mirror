HearLightAttack = {
    name = "HearLightAttack",
    version = "1.0.1"
	}

local EVENT_MANAGER = GetEventManager()

function HearLightAttack.onUpdate(_, actionResult, _, _, _,slotType, sourceName)
			local playerName = GetRawUnitName("player")
            if slotType == ACTION_SLOT_TYPE_LIGHT_ATTACK and playerName == sourceName and (actionResult == ACTION_RESULT_DAMAGE or actionResult == ACTION_RESULT_CRITICAL_DAMAGE) then
				PlaySound("Dialog_Decline")
			end
end

EVENT_MANAGER:RegisterForEvent("RunHearLightAttack", EVENT_COMBAT_EVENT, HearLightAttack.onUpdate)