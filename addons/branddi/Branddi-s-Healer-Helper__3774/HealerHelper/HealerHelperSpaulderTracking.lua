HealerHelper.firstTime = true

function HealerHelper.SpaulderOnPlayerActivatedTask(initial)
    local newZone = GetUnitWorldPosition('player') ~= HealerHelper.savedVars.spaulderLastZoneID
    local first = HealerHelper.firstTime and initial

    if first or newZone  then
        HealerHelper.savedVars.spaulderBuffActive = false
        HealerHelper.firstTime = false
        HealerHelper.savedVars.spaulderLastZoneID = GetUnitWorldPosition('player')
    end
end



 function HealerHelper.SpaulderOnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if result == ACTION_RESULT_EFFECT_GAINED then
        HealerHelper.savedVars.spaulderBuffActive = true
    elseif result == ACTION_RESULT_EFFECT_FADED then
        HealerHelper.savedVars.spaulderBuffActive = false
    end
end

function HealerHelper.isSpaulderNeeded()


    if HealerHelper.savedVars.enableSpaulderWarning==false then
        return false
    end

	if HealerHelper.checkIfGearSetEquipped("Spaulder of Ruin") and HealerHelper.savedVars.spaulderBuffActive == false then
		return true
	else
		return false
	end
end


HealerHelper.SpaulderTrackingEnable = false

function HealerHelper.InitialiseSpaulderTracking()

    if HealerHelper.SpaulderTrackingEnable == false then

		EVENT_MANAGER:RegisterForEvent(HealerHelper.name .. "SpaulderTracking", EVENT_COMBAT_EVENT, HealerHelper.SpaulderOnCombatEvent)
        EVENT_MANAGER:AddFilterForEvent(HealerHelper.name .. "SpaulderTracking", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 163359, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

        HealerHelper.SpaulderTrackingEnable = true
    end
end

function HealerHelper.DeinitialiseSpaulderTracking()
    if HealerHelper.SpaulderTrackingEnable == true then

		EVENT_MANAGER:UnregisterForEvent(HealerHelper.name .. "SpaulderTracking", EVENT_COMBAT_EVENT)

        HealerHelper.SpaulderTrackingEnable = false
    end
end

