HealerHelper.lastUltimageGenerationLAandHATriggered = 0
HealerHelper.lastUltimageGenerationAlternateSource = 0

function HealerHelper.UltimateGenerationOnCombatEvent(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)
    local current_time = GetGameTimeMilliseconds()

	local isDodge = targetType == COMBAT_UNIT_TYPE_PLAYER and result == ACTION_RESULT_DODGED
	local isSourcePlayer = sourceType == COMBAT_UNIT_TYPE_PLAYER
	local isUltiAbility = isSourcePlayer and (abilityActionSlotType == ACTION_SLOT_TYPE_LIGHT_ATTACK or abilityActionSlotType == ACTION_SLOT_TYPE_HEAVY_ATTACK or abilityName == "Brace Cost")
	local isUltiRestoreTick = isSourcePlayer and abilityName == "Ultimate Gain Restore"
	local isSureExpired = HealerHelper.lastUltimageGenerationLAandHATriggered < current_time - 8000

	if (isUltiAbility or isDodge) then -- we got a garanteed utlimate generation event
		HealerHelper.lastUltimageGenerationLAandHATriggered = current_time
        --d("LA")
	elseif (isUltiRestoreTick and isSureExpired) then -- we got utimate generation from some other source
		HealerHelper.lastUltimageGenerationAlternateSource = current_time
		--d("alternate gen")
	end
end


function HealerHelper.requireUltimateGeneration(requestEarlySeconds)


    local current_time = GetGameTimeMilliseconds()
	local isExtensiveExpired = HealerHelper.lastUltimageGenerationAlternateSource < current_time - 1200
	local isSureExpired = HealerHelper.lastUltimageGenerationLAandHATriggered < current_time - 8000
	local isSureAlmostExpired = HealerHelper.lastUltimageGenerationLAandHATriggered < current_time - 8000 + requestEarlySeconds * 1000

	if (isSureExpired and isExtensiveExpired) then
	    return true
	elseif (isSureAlmostExpired and isExtensiveExpired) then
	    return true
    end

    return false
end


HealerHelper.UltimateGenerationTrackingEnable = false

function HealerHelper.InitialiseUltimateGenerationTracking()



    if HealerHelper.UltimateGenerationTrackingEnable == false then

        EVENT_MANAGER:RegisterForEvent(HealerHelper.name .. "UltimateGenerationTracking" , EVENT_COMBAT_EVENT, HealerHelper.UltimateGenerationOnCombatEvent)

        HealerHelper.UltimateGenerationTrackingEnable = true
    end
end

function HealerHelper.DeinitialiseUltimateGenerationTracking()
    if HealerHelper.UltimateGenerationTrackingEnable == true then

		EVENT_MANAGER:UnregisterForEvent(HealerHelper.name .. "UltimateGenerationTracking" , EVENT_COMBAT_EVENT)

        HealerHelper.UltimateGenerationTrackingEnable = false
    end
end

