LibAbilityLogger = LibAbilityLogger or {}
LibAbilityLogger.name = "LibAbilityLogger"
LibAbilityLogger.version = 1.0
LibAbilityLogger.debug = false
function LibAbilityLogger:Print(...)
    if self.debug then
        d(string.format("[%s] %s", self.name, string.format(...)))
    end
end
function LibAbilityLogger:EnableDebug()
    self.debug = true
    self:Print("Debug enabled")
end
function LibAbilityLogger:DisableDebug()
    self:Print("Debug disabled")
    self.debug = false
end
function LibAbilityLogger:IsDebugEnabled()
    return self.debug
end
function LibAbilityLogger:ToggleDebug()
    if self.debug then
        self:DisableDebug()
    else
        self:EnableDebug()
    end
end
EVENT_MANAGER:RegisterForEvent(LibAbilityLogger.name, EVENT_ADD_ON_LOADED, function(event, addonName)
    if addonName == LibAbilityLogger.name then
        LibAbilityLogger:Print("Loaded version %s", LibAbilityLogger.version)
        EVENT_MANAGER:UnregisterForEvent(LibAbilityLogger.name, EVENT_ADD_ON_LOADED)
    end
end)
-- Slash command to toggle debugging
SLASH_COMMANDS["/lab"] = function()
    LibAbilityLogger:ToggleDebug()
end
-- Usage example:
-- LibAbilityLogger:Print("This is a debug message")
SLASH_COMMANDS["/labhelp"] = function()
    d("LibAbilityLogger Commands:")
    d("/lab - Toggle debug messages on/off")
    d("/labhelp - Show this help message")
end
EVENT_MANAGER:RegisterForEvent(LibAbilityLogger.name, EVENT_EFFECT_CHANGED, function (...) 
    if not LibAbilityLogger.debug then return end
    local eventCode, changeType, effectSlot, effectName, unitTag = ...
    local changeTypeStr = GetString("SI_EFFECTCHANGESTYPE", changeType) or changeType
    local unitName = GetUnitName(unitTag) or "Unknown Unit"
    LibAbilityLogger:Print("Effect '%s' on %s (%s) changed: %s (Slot: %d)", effectName or "Unknown Effect", unitName, unitTag,changeTypeStr, effectSlot)
end)
EVENT_MANAGER:RegisterForEvent(LibAbilityLogger.name, EVENT_COMBAT_EVENT, function (...) 
    if not LibAbilityLogger.debug then return end
    local eventCode, actionResult, isError, abilityName, _, abilityactionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, _, sourceUnitId, targetUnitId, abilityId, overflow = ...
    if sourceType == COMBAT_UNIT_TYPE_PLAYER and eventType == COMBAT_EVENT_TYPE_DAMAGE or COMBAT_UNIT_TYPE_PLAYER_PET == sourceType then
        local abilityName = GetAbilityName(abilityId)
        local abilityIcon = GetAbilityIcon(abilityId)
        local targetName = targetName or "Unknown Target"
        local hitValue = hitValue
        local powerType = powerType
        local damageType = damageType or 0
        local abilityId = abilityId or 0
        local overflow = overflow or 0
        local sourceName = sourceName or "Unknown Source"
        local sourceType = sourceType or 0
        local targetType = targetType or 0
        local actionResult = actionResult or 0
        local isError = isError or false
        local abilityactionSlotType = abilityactionSlotType or 0
        local eventType = eventType or 0
        local eventCode = eventCode or 0
        local sourceUnitId = sourceUnitId or 0
        local targetUnitId = targetUnitId or 0
        local powerTypeStr = GetString("SI_COMBATMECHANICTYPE", powerType) or "Unknown Power Type"
        local damageTypeStr = GetString("SI_COMBATMECHANICTYPE", damageType) or "Unknown Damage Type"
        local actionResultStr = GetString("SI_COMBATACTIONRESULT", actionResult) or "Unknown Action Result"
        local abilitySlotTypeStr = GetString("SI_ABILITY_SLOTTYPE", abilityactionSlotType) or "Unknown Slot Type"
        local eventTypeStr = GetString("SI_COMBATEVENTTYPE", eventType) or "Unknown Event Type"
        local sourceTypeStr = GetString("SI_COMBATUNITTYPE", sourceType) or "Unknown Source Type"
        local targetTypeStr = GetString("SI_COMBATUNITTYPE", targetType) or "Unknown Target Type"
        -- Log the ability usage details
        local cost = GetAbilityCost(abilityId)
        local costStr = ""
        local result = ""
        if actionResult == ACTION_RESULT_DODGE then
            result = "dodged"
        elseif actionResult == ACTION_RESULT_EFFECT_GAINED_DURATION then
            result = "effect gained"
        elseif actionResult == ACTION_RESULT_EFFECT_GAINED then
            result = "effect gained"
        elseif actionResult == ACTION_RESULT_POWER_ENERGIZE then
            result = "energized"
        elseif actionResult == ACTION_RESULT_POWER_DRAIN then
            result = "drained"
        elseif actionResult == ACTION_RESULT_QUEUED then
            result = "queued"
        elseif actionResult == ACTION_RESULT_EFFECT_FADED then
            result = "effect faded"
        elseif actionResult == ACTION_RESULT_DAMAGE or actionResult == ACTION_RESULT_CRITICAL_DAMAGE then
            result = "damage"
        elseif actionResult == ACTION_RESULT_HEAL or actionResult == ACTION_RESULT_CRITICAL_HEAL then
            result = "healing"
        elseif actionResult == ACTION_RESULT_DOT_TICK or actionResult == ACTION_RESULT_DOT_TICK_CRITICAL then
            result = "damage over time"
        elseif actionResult == ACTION_RESULT_HOT_TICK or actionResult == ACTION_RESULT_HOT_TICK_CRITICAL then
            result = "healing over time"
        elseif actionResult == ACTION_RESULT_BLOCKED then
            result = "blocked"
        elseif actionResult == ACTION_RESULT_PARRIED then
            result = "parried"
        elseif actionResult == ACTION_RESULT_ABSORBED or actionResult == ACTION_RESULT_HEAL_ABSORBED then
            result = "absorbed"
        elseif actionResult == ACTION_RESULT_MISS then
            result = "miss"
        elseif actionResult == ACTION_RESULT_IMMUNE then
            result = "immune"
        elseif actionResult == ACTION_RESULT_RESIST or actionResult == ACTION_RESULT_PARTIAL_RESIST then
            result = "resisted"
        elseif actionResult == ACTION_RESULT_INTERRUPT then
            result = "interrupted"
        elseif actionResult == ACTION_RESULT_KILLED_BY_SUBZONE or actionResult == ACTION_RESULT_DIED then
            result = "died"
        else
            result = actionResult
        end
        if cost then
            costStr = string.format("%d %s", cost, powerTypeStr)
        else
            costStr = "No Cost"
        end

        -- You can log more details as needed
        
        LibAbilityLogger:Print("You used %d %s (%d) on %s for %d %s for the cost of %s",actionResult, abilityName or "Unknown Ability", abilityId, targetName or "Unknown Target", hitValue or 0, result or "Unknown", costStr)
    else
        local abilityName = GetAbilityName(abilityId)
        local abilityIcon = GetAbilityIcon(abilityId)
        local targetName = targetName or "Unknown Target"
        local hitValue = hitValue
        local powerType = powerType
        local damageType = damageType or 0
        local abilityId = abilityId or 0
        local overflow = overflow or 0
        local sourceName = sourceName or "Unknown Source"
        local sourceType = sourceType or 0
        local targetType = targetType or 0
        local actionResult = actionResult or 0
        local isError = isError or false
        local abilityactionSlotType = abilityactionSlotType or 0
        local eventType = eventType or 0
        local eventCode = eventCode or 0
        local sourceUnitId = sourceUnitId or 0
        local targetUnitId = targetUnitId or 0
        local powerTypeStr = GetString("SI_COMBATMECHANICTYPE", powerType) or "Unknown Power Type"
        local damageTypeStr = GetString("SI_COMBATMECHANICTYPE", damageType) or "Unknown Damage Type"
        local actionResultStr = GetString("SI_COMBATACTIONRESULT", actionResult) or "Unknown Action Result"
        local abilitySlotTypeStr = GetString("SI_ABILITY_SLOTTYPE", abilityactionSlotType) or "Unknown Slot Type"
        local eventTypeStr = GetString("SI_COMBATEVENTTYPE", eventType) or "Unknown Event Type"
        local sourceTypeStr = GetString("SI_COMBATUNITTYPE", sourceType) or "Unknown Source Type"
        local targetTypeStr = GetString("SI_COMBATUNITTYPE", targetType) or "Unknown Target Type"
        -- Log the ability usage details
        local cost = GetAbilityCost(abilityId)
        local costStr = ""
        local result = ""
        if actionResult == ACTION_RESULT_DODGE then
            result = "dodged"
        elseif actionResult == ACTION_RESULT_EFFECT_GAINED_DURATION then
            result = "effect gained"
        elseif actionResult == ACTION_RESULT_EFFECT_GAINED then
            result = "effect gained"
        elseif actionResult == ACTION_RESULT_EFFECT_FADED then
            result = "effect faded"
        elseif actionResult == ACTION_RESULT_DAMAGE or actionResult == ACTION_RESULT_CRITICAL_DAMAGE then
            result = "damage"
        elseif actionResult == ACTION_RESULT_HEAL or actionResult == ACTION_RESULT_CRITICAL_HEAL then
            result = "healing"
        elseif actionResult == ACTION_RESULT_DOT_TICK then
            result = "damage over time"
        elseif actionResult == ACTION_RESULT_HOT_TICK or actionResult == ACTION_RESULT_HOT_TICK_CRITICAL then
            result = "healing over time"
        else
            result = actionResultStr
        end
        if cost then
            costStr = string.format("%d %s", cost, powerTypeStr)
        else
            costStr = "No Cost"
        end

        -- You can log more details as needed
        
        LibAbilityLogger:Print("You used %d %s (%d) on %s for %d %s for the cost of %s",actionResult, abilityName or "Unknown Ability", abilityId, targetName or "Unknown Target", hitValue or 0, result or "Unknown", costStr)
    end
end)
