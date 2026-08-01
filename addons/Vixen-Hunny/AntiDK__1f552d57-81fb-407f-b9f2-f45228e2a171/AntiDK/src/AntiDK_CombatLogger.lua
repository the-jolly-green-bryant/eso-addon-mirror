AntiDK = AntiDK or {}

-- Combat logging is now handled in AntiDK_Func.lua
-- This file is kept for legacy compatibility

AntiDK.Combat = AntiDK.Combat or {}

function AntiDK:OnCombatEvent(...)
    local eventCode, actionResult, isError, abilityName, _, abilityactionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, uSType, sourceUnitId, targetUnitId, abilityId, overflow = ...
    
    -- Only track events where target is the player
    -- if sourceName ~= GetRawUnitName("player") then return end
    
    -- Only track events from Dragonknights (check source)
    -- if GetUnitClass(sourceUnitTag) ~= "Dragonknight" then return end
    d("Combat event from DK: " .. abilityName .. " (" .. abilityId .. ") by " .. sourceName .. " on " .. targetName)
    -- Create combat log entry for this source
    if not AntiDK.Combat[sourceName] then
        AntiDK.Combat[sourceName] = {}
    end
    
    -- Check for specific tracked abilities
    if abilityId == 34117 or abilityName == "Power Lash" then
        AntiDK:LogPowerLash(sourceName, targetName, hitValue)
    elseif abilityId == 32678 or abilityName == "Shattering Rocks" then
        AntiDK:LogFossilize(sourceName, targetName, 1)
    elseif abilityId == 32685 or abilityName == "Fossilize" then
        AntiDK:LogFossilize(sourceName, targetName, 1) -- Standard stun duration
    elseif abilityId == 29474 or abilityName == "Blessing at the Peak" then
        AntiDK:LogMoltenWhip(sourceName, targetName, hitValue)
    else
        -- Log generic ability
        local combatEntry = {
            abilityName = abilityName,
            abilityId = abilityId,
            sourceName = sourceName,
            targetName = targetName,
            actionResult = actionResult,
            isError = isError,
            hitValue = hitValue,
            powerType = powerType,
            damageType = damageType,
            abilityType = uSType,
            timestamp = GetTimeStamp(),
        }
        
        table.insert(AntiDK.Combat[sourceName], combatEntry)
    end
    
    -- Keep only last 50 events per source to avoid memory bloat
    if #AntiDK.Combat[sourceName] > 50 then
        table.remove(AntiDK.Combat[sourceName], 1)
    end
end