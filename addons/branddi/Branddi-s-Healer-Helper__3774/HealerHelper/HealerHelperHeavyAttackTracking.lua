HealerHelper.lastWrongBarHeavyAttackTime = 0 -- last time the heavy attack was on the wrong bar
HealerHelper.lastUnnessisaryHeavyAttackTime = 0 -- last time a heavy attack was not required

HealerHelper.HA_RETURN_MAG = 1
HealerHelper.HA_RETURN_STAM = 2

HealerHelper.listOfHeavyAttacks = {
    [15279]={"Heavy Attack (One Handed)", HealerHelper.HA_RETURN_STAM},

    [16420]={"Heavy Attack (Dual Wield)", HealerHelper.HA_RETURN_STAM},
    [18429]={"Heavy Attack (Unarmed)", HealerHelper.HA_RETURN_STAM},

    [16691]={"Heavy Attack (Bow)", HealerHelper.HA_RETURN_STAM},

    [15383]={"Heavy Attack (Inferno)", HealerHelper.HA_RETURN_MAG},
    [16261]={"Heavy Attack (Ice)", HealerHelper.HA_RETURN_MAG},
    [16041]={"Heavy Attack (Two Handed)", HealerHelper.HA_RETURN_STAM},

    [18396]={"Heavy Attack (Lightning)", HealerHelper.HA_RETURN_MAG},
    [16212]={"Heavy Attack (Restoration)", HealerHelper.HA_RETURN_MAG},
}

function HealerHelper.heavyAttackTrackingOnCombatEvent(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)
    local validROHeavyAttack = false
    local validResourceHeavyAttack = false
    --d("HA "..HealerHelper.listOfHeavyAttacks[abilityId][1].." Detected")
    if HealerHelper.checkIfGearSetEquipped("Roaring Opportunist's") then
        if HealerHelper.ShouldProcRoaringOpportunist() then
            validResourceHeavyAttack = true -- don't complain about resource when RO is required
            if HealerHelper.currentBar == HealerHelper.getGetSetBars("Roaring Opportunist's") or HealerHelper.getGetSetBars("Roaring Opportunist's")==3 then
                validROHeavyAttack = true
                HealerHelper.lastWrongBarHeavyAttackTime = 0
            else
                HealerHelper.lastWrongBarHeavyAttackTime = GetGameTimeMilliseconds()
            end
        end
    end

    if HealerHelper.listOfHeavyAttacks[abilityId][2] == HealerHelper.HA_RETURN_MAG then -- HA will return mag
        if HealerHelper.playerMagPercentage() < HealerHelper.savedVars.unnecessaryResourcePercentage then
            validResourceHeavyAttack = true
        end
    end
    if HealerHelper.listOfHeavyAttacks[abilityId][2] == HealerHelper.HA_RETURN_STAM then -- HA will return stam
        if HealerHelper.playerStamPercentage() < HealerHelper.savedVars.unnecessaryResourcePercentage then
            validResourceHeavyAttack = true
        end
    end

    if validResourceHeavyAttack == false then
        HealerHelper.lastUnnessisaryHeavyAttackTime = GetGameTimeMilliseconds()
    else
        HealerHelper.lastUnnessisaryHeavyAttackTime = 0
    end

end

HealerHelper.HeavyAttackTrackingEnable = false

function HealerHelper.InitialiseHeavyAttackTracking()


    if HealerHelper.HeavyAttackTrackingEnable == false then
        for k, v in pairs(HealerHelper.listOfHeavyAttacks) do
            EVENT_MANAGER:RegisterForEvent(HealerHelper.name.."HeavyAttackOnCombatEvent_"..k, EVENT_COMBAT_EVENT, HealerHelper.heavyAttackTrackingOnCombatEvent)
            EVENT_MANAGER:AddFilterForEvent(HealerHelper.name .. "HeavyAttackOnCombatEvent_"..k, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, k, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
        end
        HealerHelper.HeavyAttackTrackingEnable = true
    end
end

function HealerHelper.DeinitialiseHeavyAttackTracking()
    if HealerHelper.HeavyAttackTrackingEnable == true then

        for k, v in pairs(HealerHelper.listOfHeavyAttacks) do
            EVENT_MANAGER:UnregisterForEvent(HealerHelper.name.."HeavyAttackOnCombatEvent_"..k, EVENT_COMBAT_EVENT)
        end
        HealerHelper.HeavyAttackTrackingEnable = false
    end
end

