AntiDK = AntiDK or {}

-- Effect logging is now handled in AntiDK_Func.lua
-- This file is kept for legacy compatibility

AntiDK.Effects = AntiDK.Effects or {}

function AntiDK:OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, startTimeSec, endTimeSec, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, _, abilityId, sourceType)
    -- Only track effects on the player from a target
    
    if GetUnitClass("player") ~= "Dragonknight" then return end
    
    local targetName = GetUnitName(targetUnitTag)
    if not targetName then return end
    
    -- Create effect entry
    if not AntiDK.Effects[targetName] then
        AntiDK.Effects[targetName] = {}
    end
    
    -- Log effect application or removal
    if changeType == EFFECT_RESULT_GAINED then
        -- Check for tracked abilities
        if abilityId == 24364 or effectName == "Corrosive Armor" then
            AntiDK:LogCorrosiveArmor(targetName, endTimeSec - startTimeSec, stackCount)
        elseif abilityId == 22633 or effectName == "Fossilize" then
            AntiDK:LogFossilize(targetName, GetUnitName("player"), endTimeSec - startTimeSec)
        elseif abilityId == 24366 or effectName == "Molten Whip" then
            AntiDK:LogMoltenWhip(targetName, GetUnitName("player"), 0, endTimeSec - startTimeSec, stackCount)
        else
            -- Log generic effect
            AntiDK.Effects[targetName][effectName] = {
                name = effectName,
                abilityId = abilityId,
                startTime = startTimeSec,
                endTime = endTimeSec,
                duration = endTimeSec - startTimeSec,
                stackCount = stackCount,
                iconName = iconName,
                buffType = buffType,
                effectType = effectType,
                abilityType = abilityType,
                statusEffectType = statusEffectType,
                gainedAt = GetTimeStamp(),
            }
        end
    elseif changeType == EFFECT_RESULT_FADED or changeType == EFFECT_RESULT_REMOVED then
        if AntiDK.Effects[targetName] then
            AntiDK.Effects[targetName][effectName] = nil
        end
    elseif changeType == EFFECT_RESULT_UPDATED then
        -- Update stack count when effect is updated
        if AntiDK.Effects[targetName] and AntiDK.Effects[targetName][effectName] then
            AntiDK.Effects[targetName][effectName].stackCount = stackCount
            AntiDK.Effects[targetName][effectName].endTime = endTimeSec
        elseif abilityId == 24364 or effectName == "Corrosive Armor" then
            AntiDK:LogCorrosiveArmor(targetName, endTimeSec - startTimeSec, stackCount)
        elseif abilityId == 24366 or effectName == "Molten Whip" then
            AntiDK:LogMoltenWhip(targetName, GetUnitName("player"), 0, endTimeSec - startTimeSec, stackCount)
            
        end
    end
end