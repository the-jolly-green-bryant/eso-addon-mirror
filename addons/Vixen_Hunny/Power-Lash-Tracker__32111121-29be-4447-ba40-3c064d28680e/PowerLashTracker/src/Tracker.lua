PLT = PLT or {}
em = EVENT_MANAGER
PLT.PLBuffTimer = 45 -- Duration in seconds
PLT.BuffTimerNow = 0 -- Now Buff start in seconds
PLT.CooldownTimerNow = 0 -- Now start in seconds
PLT.PLBuffID = 262658 -- Buff ID
PLT.PLCooldownTimer = 20 -- Duration in seconds
PLT.PLCooldownID = 34117 -- Cooldown ID
PLT.PLAbilityID = 20824 -- Power Lash ID
PLT.StacksActive = 0 -- Number of stacks active
PLT.lastTrigger = 0
PLT.spamDelay = 190  -- milliseconds
PLT.PowerLashActive = false -- Whether Power Lash is currently active
PLT.PreviousAttacker = "" -- Previous attacker name
PLT.UI = PLT.UI or {}
function PLT:StartUpdate(abilityId, duration, abilityType)
    if abilityType == "buff" then
        em:RegisterForUpdate("PowerLashTracker".."Buff", 100, function(...) PLT:OnUpdate(abilityId,"buff") end)
    elseif abilityType == "cooldown" then
        PLT.CooldownTimerNow = duration
        em:RegisterForUpdate("PowerLashTracker".."Cooldown", 100, function(...) PLT:OnUpdate(abilityId, "cooldown") end)
    elseif abilityType == "stacks" then
        PLT.CooldownTimerNow = duration
        em:RegisterForUpdate("PowerLashTracker".."Stacks", 100, function(...) PLT:OnUpdate(abilityId, "stacks") end)
    end
    
end
function PLT:OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, startTimeSec, endTimeSec, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, _, abilityId, sourceType)
    if unitTag ~= "player" then return end
    if effectName == "Power Lash" then
        if changeType == 3 and abilityId == PLT.PLBuffID then
            if PLT.BuffTimerNow == 0 then
                PLT.BuffTimerNow = GetFrameTimeMilliseconds()
                 PLT:StartUpdate(abilityId, GetFrameTimeMilliseconds(), "buff")
            else 
                PLT.BuffTimerNow = GetFrameTimeMilliseconds()
            end
        end
    end
end
PLT = PLT or {}

function PLT:OnCombatEvent(...)
    local eventCode, actionResult, isError, abilityName, _, abilityactionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, _, sourceUnitId, targetUnitId, abilityId, overflow = ...
     if abilityName ~= "Power Lash" then return end
    if abilityId == PLT.PLAbilityID and sourceName == GetRawUnitName("player") then
        local now = GetFrameTimeMilliseconds()
            if now - PLT.lastTrigger < PLT.spamDelay then
                return
            end
            PLT.lastTrigger = now
        if actionResult ~= ACTION_RESULT_BLOCKED_DAMAGE and actionResult ~= ACTION_RESULT_MISS and actionResult ~= ACTION_RESULT_DODGED and actionResult ~= ACTION_RESULT_DAMAGE and actionResult == ACTION_RESULT_CRITICAL_DAMAGE and actionResult == ACTION_RESULT_DAMAGE_SHIELDED then return end
        if actionResult == 2080 then return end
        if PLT.PowerLashActive ~= true then 
            PLT.StacksActive = 0
            PLT.UI.Stacks:SetText(string.format(""))
            return
        end

        PLT.StacksActive = PLT.StacksActive - 1
        if PLT.StacksActive == 0 then
            PLT.StacksActive = 0
        end
    end
    if PLT.PLCooldownID == abilityId then
        if actionResult == 2250 and targetName == GetRawUnitName("player") then
            PLT.StacksActive = 0
            PLT.PowerLashActive = false
            PLT.UI.Stacks:SetText(string.format(""))
            return
        end
        if hitValue == 5 and sourceName == GetRawUnitName("player") then
            PLT.StacksActive = 0
            PLT.PowerLashActive = true
            PLT.UI.Stacks:SetText(string.format(""))
            PLT.StacksActive = PLT.StacksActive + 5
            PLT:StartUpdate(abilityId, GetFrameTimeMilliseconds(), "stacks")
            PLT:StartUpdate(abilityId, GetFrameTimeMilliseconds(), "cooldown")
            return
        end

    end
end

