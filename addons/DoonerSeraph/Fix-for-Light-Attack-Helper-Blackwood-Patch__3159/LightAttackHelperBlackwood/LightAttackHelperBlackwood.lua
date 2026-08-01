LightAttackHelperBlackwood = LightAttackHelperBlackwood or {}
LightAttackHelperBlackwood.name = "LightAttackHelperBlackwood"
LightAttackHelper = LightAttackHelper or {}

-------------------------------------
-- LAH override
------------------------------------
function LightAttackHelper.onCombatEvent(_, _, _, abilityName, _, abilityActionSlotType, sourceName, _, _, _, hitValue)
    if abilityActionSlotType == ACTION_SLOT_TYPE_LIGHT_ATTACK and LightAttackHelper.playerName == sourceName and LightAttackHelper.isTheActualAttackCast(hitValue) then
        LightAttackHelper.castingHeavyAttack = false
        LightAttackHelper.usedAbilityDuringHeavyAttack = false
        LightAttackHelper.setCounter(LightAttackHelper.LightAttackCounter + 1)
        LightAttackHelper.updateRatio(true)

    elseif abilityActionSlotType == ACTION_SLOT_TYPE_HEAVY_ATTACK then

        if abilityName == GetString(LAH_HEAVY_ATTACK) and LightAttackHelper.playerName == sourceName and LightAttackHelper.isTheActualAttackCast(hitValue) then
            LightAttackHelper.castingHeavyAttack = false
            LightAttackHelper.usedAbilityDuringHeavyAttack = false

            if LightAttackHelper.savedVariables.countHeavyAttacks then
                LightAttackHelper.setCounter(LightAttackHelper.LightAttackCounter + 1)
                LightAttackHelper.updateRatio(true)
            end
        end

    end

end