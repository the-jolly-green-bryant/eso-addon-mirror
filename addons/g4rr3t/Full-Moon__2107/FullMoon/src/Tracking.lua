-- -----------------------------------------------------------------------------
-- Full Moon
-- Author:  g4rr3t
-- Created: Aug 23, 2018
--
-- Tracking.lua
-- -----------------------------------------------------------------------------

local BLOOD_SCENT_ID = 111387
local FRENZIED_ID = 111386
local updateIntervalMs = 100

MOON.timeOfProc = 0
MOON.procDurationMs = 5000
MOON.cooldownDurationMs = 18000

function MOON.RegisterEvents()

    -- Blood Scent
    EVENT_MANAGER:RegisterForEvent(MOON.name .. "BLOOD_SCENT", EVENT_EFFECT_CHANGED, function(...) MOON.OnBloodScent(...) end)
    EVENT_MANAGER:AddFilterForEvent(MOON.name .. "BLOOD_SCENT", EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_ABILITY_ID, BLOOD_SCENT_ID,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    -- Frenzied
    EVENT_MANAGER:RegisterForEvent(MOON.name .. "FRENZIED", EVENT_EFFECT_CHANGED, function(...) MOON.OnFrenzied(...) end)
    EVENT_MANAGER:AddFilterForEvent(MOON.name .. "FRENZIED", EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_ABILITY_ID, FRENZIED_ID,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    -- Hide/Show on Death/Alive
    EVENT_MANAGER:RegisterForEvent(MOON.name, EVENT_PLAYER_ALIVE, MOON.OnAlive)
    EVENT_MANAGER:RegisterForEvent(MOON.name, EVENT_PLAYER_DEAD, MOON.OnDeath)

    -- Combat State
    if MOON.preferences.hideOOC then
        MOON.RegisterCombatEvent()
    end

end

function MOON.UnregisterEvents()
    EVENT_MANAGER:UnregisterForEvent(MOON.name .. "BLOOD_SCENT", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(MOON.name .. "FRENZIED", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(MOON.name, EVENT_PLAYER_ALIVE)
    EVENT_MANAGER:UnregisterForEvent(MOON.name, EVENT_PLAYER_DEAD)

    if MOON.preferences.showOOC then
        MOON.UnregisterCombatEvent()
    end
end

function MOON.OnAlive()
    MOON.isDead = false
    MOON:SetCombatStateDisplay()
end

function MOON.OnDeath()
    MOON.isDead = true
    MOON:SetCombatStateDisplay()
end

function MOON.RegisterCombatEvent()
    EVENT_MANAGER:RegisterForEvent(MOON.name .. "COMBAT", EVENT_PLAYER_COMBAT_STATE, function(...) MOON.IsInCombat(...) end)
    MOON:Trace(2, "Registered combat events")
end

function MOON.UnregisterCombatEvent()
    EVENT_MANAGER:UnregisterForEvent(MOON.name .. "COMBAT", EVENT_PLAYER_COMBAT_STATE)
    MOON:Trace(2, "Unregistered combat events")
end

function MOON.IsInCombat(_, inCombat)
    MOON.isInCombat = inCombat
    MOON:Trace(2, "In Combat: <<1>>", tostring(inCombat))
    MOON:SetCombatStateDisplay()
end

function MOON.OnBloodScent(_, changeType, _, effectName, _, _, _, stackCount,
        _, _, _, _, _, _, _, effectAbilityId)

    MOON:Trace(3, effectName .. " (" .. effectAbilityId .. ")")

    -- Set to zero if stacks faded
    if changeType == EFFECT_RESULT_FADED then
        MOON:Trace(2, "Stack faded on #<<1>> for <<2>> (<<3>>), setting stacks to zero.", stackCount, effectName, effectAbilityId)
        MOON.UpdateStacks(0)
    else
        MOON:Trace(2, "Stack #<<1>> for <<2>> (<<3>>)", stackCount, effectName, effectAbilityId)
        MOON.UpdateStacks(stackCount)
    end

end

function MOON.SetDidUpdate(setName, equipped)
    if equipped then
        MOON.enabled = true
        MOON.RegisterEvents()
        MOON.DrawUI()
        MOON:Trace(1, 'Enabling Blood Moon tracking')
    else
        MOON.enabled = false
        MOON.UnregisterEvents()
        MOON.DrawUI()
        MOON:Trace(1, 'Disabling Blood Moon tracking')
    end
end

function MOON.OnFrenzied(_, changeType, _, effectName, _, _, _, _, _, _,
        _, _, _, _, _, effectAbilityId)

    MOON:Trace(3, "<<1>> (<<2>>)", effectName, effectAbilityId)

    if changeType == EFFECT_RESULT_GAINED then
        MOON:Trace(2, "Frenzied!")
        MOON.timeOfProc = GetGameTimeMilliseconds()
        MOON.onCooldown = true
        MOON.Frenzied(true)
        MOON.Update() -- Manually call first update
        EVENT_MANAGER:RegisterForUpdate(MOON.name .. "FRENZIED", updateIntervalMs, MOON.Update)
        return
    end

    if changeType == EFFECT_RESULT_FADED then
        MOON:Trace(2, "No longer Frenzied!")
        MOON.Frenzied(false)
        MOON.Update() -- Manually call update to keep sync
        return
    end

end
