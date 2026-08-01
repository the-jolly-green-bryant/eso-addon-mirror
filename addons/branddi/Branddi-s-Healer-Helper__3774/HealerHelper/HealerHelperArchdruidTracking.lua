


HealerHelper.nextArchdruidRequiredByTime = 0


function HealerHelper.ArchdruidOnCombatEvent(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)

	if sourceType == COMBAT_UNIT_TYPE_NONE and HealerHelper.nextArchdruidRequiredByTime < GetGameTimeMilliseconds() + 7000 then
	    -- someone else proced Archdruid delay yours by 7 seconds
	    HealerHelper.nextArchdruidRequiredByTime = GetGameTimeMilliseconds()+7000
	elseif sourceType == COMBAT_UNIT_TYPE_PLAYER then
	    -- you cast proced archdruid, your next cast in 15 seconds
	    HealerHelper.nextArchdruidRequiredByTime = GetGameTimeMilliseconds()+15000
	end
end


HealerHelper.ArchdruidTrackingEnable = false

function HealerHelper.InitialiseArchdruidTracking()
    if HealerHelper.ArchdruidTrackingEnable == false then

    	EVENT_MANAGER:RegisterForEvent(HealerHelper.name .. "ArchdruidTracking", EVENT_COMBAT_EVENT, HealerHelper.ArchdruidOnCombatEvent)
	    EVENT_MANAGER:AddFilterForEvent(HealerHelper.name .. "ArchdruidTracking", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
	    EVENT_MANAGER:AddFilterForEvent(HealerHelper.name .. "ArchdruidTracking", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 176813)

        HealerHelper.ArchdruidTrackingEnable = true
    end
end

function HealerHelper.DeinitialiseArchdruidTracking()
    if HealerHelper.ArchdruidTrackingEnable == true then

        EVENT_MANAGER:UnregisterForEvent(HealerHelper.name .. "ArchdruidTracking", EVENT_COMBAT_EVENT)

        HealerHelper.ArchdruidTrackingEnable = false
    end
end

function HealerHelper.ShouldProcArchdruid()


    if  HealerHelper.checkIfGearSetEquipped("Archdruid") and HealerHelper.nextArchdruidRequiredByTime - 500 <= GetGameTimeMilliseconds() then
    -- for lighting and resto procing Archdruid at 0.5 seconds early is about perfect
    -- for fire and ice 0.5 works, just need to release the heavy early to get it to proc earlier
        return true
    else
        return false
    end
end