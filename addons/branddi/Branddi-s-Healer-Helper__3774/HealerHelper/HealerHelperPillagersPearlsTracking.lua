function HealerHelper.playerMagPercentage()
    local current, max, effectiveMax = GetUnitPower("player", POWERTYPE_MAGICKA)
    return  (current/max)*100
end

function HealerHelper.playerStamPercentage()
    local current, max, effectiveMax = GetUnitPower("player", POWERTYPE_STAMINA)
    return  (current/max)*100
end


function HealerHelper.PillagersAndPearlsRecommendBlockingMagRegen()



    if HealerHelper.savedVars.pillagersPearlsEnable==false or HealerHelper.checkIfGearSetEquipped("Pillager's") == false  or HealerHelper.checkIfGearSetEquipped("Pearls of Ehlnofey") == false then
        return false
    else
        if HealerHelper.playerMagPercentage() <= HealerHelper.savedVars.pillagersPearlsMagTarget then
            return false
        else
            return true
        end
    end
end


function HealerHelper.PillagersAndPearlsRecommendBlockingPotion()



    if (HealerHelper.savedVars.pillagersPearlsNightbladeForcePotions and HealerHelper.playerClass == HealerHelper.CLASS_NIGHTBLADE) or HealerHelper.savedVars.pillagersPearlsEnable==false or HealerHelper.checkIfGearSetEquipped("Pillager's") == false  or HealerHelper.checkIfGearSetEquipped("Pearls of Ehlnofey") == false then
        return false
    else
        if HealerHelper.playerMagPercentage() <= HealerHelper.savedVars.pillagersPearlsMagTarget then
            return false
        else
            return true
        end
    end
end


function HealerHelper.PillagersAtSpecifiedUltimate()


    local ultiPower = GetUnitPower("player", POWERTYPE_ULTIMATE)
    if ultiPower >= HealerHelper.savedVars.recommendPillagersAtUlt then
        return true
    else
        return false
    end
end