ProcReminder = ProcReminder or {}
ProcReminder.name = "ProcReminder"
ProcReminder.version = "1.0.0"
ProcReminder.author = "Vixen Hunny"
ProcReminder.Data = ProcReminder.Data or {}
ProcReminder.Data.AbilityData = ProcReminder.Data.AbilityData or {}
ProcReminder.Data.lastStacks = ProcReminder.Data.lastStacks or {}  -- Track previous stack counts
local em = EVENT_MANAGER

function ProcReminder:OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, icon, buffType, effectType, aType, sET, unitName, unitId,  abilityId, sourceType)
    if changeType ~= EFFECT_RESULT_GAINED and changeType ~= EFFECT_RESULT_UPDATED and changeType ~= EFFECT_RESULT_FADED then
        return
    end
    if unitTag ~= "player" then return end
    
    -- Permanent effects: Merciless Resolve (reaches 10 stacks)
    if effectName == "Merciless Resolve" and changeType == EFFECT_RESULT_UPDATED then
        local lastStacks = ProcReminder.Data.lastStacks["Merciless Resolve"] or 0
        if stackCount >= 10 and lastStacks < 10 then
            ProcReminder:ShowProc(effectName.." On 10 stacks!", icon)
        end
        ProcReminder.Data.lastStacks["Merciless Resolve"] = stackCount
    
    -- Instant proc: Crystal Fragments (gained)
    elseif effectName == "Crystal Fragments" and changeType == EFFECT_RESULT_GAINED then
        ProcReminder:ShowProc(effectName.." Ready!", icon)
    
    -- Buff fade: Rally (faded)
    elseif effectName == "Rally" and changeType == EFFECT_RESULT_FADED then
        ProcReminder:ShowProc("Rally Expired!", icon)
    
    -- Permanent effects: Relentless Focus (reaches 8 stacks)
    elseif effectName == "Relentless Focus" and changeType == EFFECT_RESULT_UPDATED then
        local lastStacks = ProcReminder.Data.lastStacks["Relentless Focus"] or 0
        if stackCount >= 8 and lastStacks < 8 then
            ProcReminder:ShowProc("Relentless Focus at 8 stacks!", icon)
        end
        ProcReminder.Data.lastStacks["Relentless Focus"] = stackCount
    end
end