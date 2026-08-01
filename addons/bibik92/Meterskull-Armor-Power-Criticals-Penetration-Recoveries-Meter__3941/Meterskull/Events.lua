--------------------------------------------------------------------------------
-- EVENT HANDLERS MODULE
--------------------------------------------------------------------------------
-- This module handles all game event registrations and related logic

local MS = Meterskull

--------------------------------------------------------------------------------
-- RENDER HELPERS
--------------------------------------------------------------------------------
local function RenderAllModules(initial)
    for _, mod in pairs(MS.modules) do
        mod:Render(initial)
    end
end

-- Render tick disable state tracking for penetration module
local renderTickDisabledPen = false
local targetCooldownDuration = 1000
local penDisableTimestamp = 0

local function DisableRenderTickForPen()
    if not MS.modules.penskull or not MS.db.sharedSettings.showPenskull then return end
    renderTickDisabledPen = true
    penDisableTimestamp = penDisableTimestamp + 1
    local myTimestamp = penDisableTimestamp
    EVENT_MANAGER:UnregisterForUpdate(MS.modules.penskull.eventNamespace .. "Render")
    zo_callLater(function()
        -- Only re-enable if no newer disable was issued
        if myTimestamp ~= penDisableTimestamp then return end
        renderTickDisabledPen = false
        if MS.db.sharedSettings.showPenskull then
            EVENT_MANAGER:RegisterForUpdate(
                MS.modules.penskull.eventNamespace .. "Render",
                MS.db.sharedSettings.renderTick,
                function() MS.modules.penskull:Render() end
            )
        end
    end, targetCooldownDuration)
end

--------------------------------------------------------------------------------
-- PLAYER DEATH/ALIVE EVENTS
--------------------------------------------------------------------------------
local function RegisterDeathCheckEvents()
    local function CheckPlayerDeathStatus()
        local playerIsDead = IsUnitDead("player")
        for _, mod in pairs(MS.modules) do
            local showKey = "show"..string.gsub(mod.name,"^%l",string.upper)
            local shouldShow = MS.db.sharedSettings[showKey]
            mod:ToggleVisibility(shouldShow)
        end
    end

    EVENT_MANAGER:RegisterForEvent(MS.name .. "DeathCheck", EVENT_PLAYER_ALIVE, CheckPlayerDeathStatus)
    EVENT_MANAGER:RegisterForEvent(MS.name .. "DeathCheck", EVENT_PLAYER_DEAD, CheckPlayerDeathStatus)
end

--------------------------------------------------------------------------------
-- WEAPON SWAP EVENT
--------------------------------------------------------------------------------
local function RegisterWeaponSwapEvent()
    EVENT_MANAGER:RegisterForEvent(MS.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function()
        RenderAllModules(true)
    end)
end

--------------------------------------------------------------------------------
-- TARGET CHANGE EVENT
--------------------------------------------------------------------------------
local function RegisterTargetChangeEvent()
    EVENT_MANAGER:RegisterForEvent(MS.name, EVENT_RETICLE_TARGET_CHANGED, function()
        if MS.modules.critskull then MS.modules.critskull:Render() end
        if (not DoesUnitExist('reticleover') or IsUnitPlayer('reticleover')) and IsUnitInCombat('player') then
            DisableRenderTickForPen()
        else
            if renderTickDisabledPen and IsUnitInCombat('player') then
                renderTickDisabledPen = false
                if MS.modules.penskull and MS.db.sharedSettings.showPenskull then
                    EVENT_MANAGER:RegisterForUpdate(
                        MS.modules.penskull.eventNamespace .. "Render",
                        MS.db.sharedSettings.renderTick,
                        function() MS.modules.penskull:Render() end
                    )
                end
            end
            if MS.modules.penskull then MS.modules.penskull:Render() end
        end
    end)
end

--------------------------------------------------------------------------------
-- BLOCK STATE EVENT
--------------------------------------------------------------------------------
local function RegisterBlockStateEvent()
    local function GetVisualBlockState()
        local currentTime = GetGameTimeMilliseconds()
        local isDodging = currentTime <= MS.blockTracking.dodgeStartTime + 600
        
        if isDodging then
            return false
        end
        
        return MS.IsReallyBlocking()
    end
    
    local wasApiBlocking = IsBlockActive()
    local wasVisualBlocking = GetVisualBlockState()
    
    EVENT_MANAGER:RegisterForUpdate(MS.name .. "BlockCheck", 100, function()
        local nowApiBlocking = IsBlockActive()
        local nowVisualBlocking = GetVisualBlockState()
        
        if (nowApiBlocking ~= wasApiBlocking) or (nowVisualBlocking ~= wasVisualBlocking) then
            if MS.modules.magskull then MS.modules.magskull:Render() end
            if MS.modules.stamskull then MS.modules.stamskull:Render() end
            if MS.modules.critresiskull then MS.modules.critresiskull:Render() end
        end
        
        wasApiBlocking = nowApiBlocking
        wasVisualBlocking = nowVisualBlocking
    end)
end

--------------------------------------------------------------------------------
-- DODGE ROLL EVENT
--------------------------------------------------------------------------------
local function RegisterDodgeEvent()
    EVENT_MANAGER:RegisterForEvent(MS.name .. "DodgeDetection", EVENT_COMBAT_EVENT, function(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
        if abilityId == 28549 then
            MS.blockTracking.dodgeStartTime = GetGameTimeMilliseconds()
        end
    end)
    EVENT_MANAGER:AddFilterForEvent(MS.name .. "DodgeDetection", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    EVENT_MANAGER:AddFilterForEvent(MS.name .. "DodgeDetection", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
    EVENT_MANAGER:AddFilterForEvent(MS.name .. "DodgeDetection", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 28549)
end

--------------------------------------------------------------------------------
-- SHIELD WALL EVENT
--------------------------------------------------------------------------------
local function RegisterShieldWallEvent()
    EVENT_MANAGER:RegisterForEvent(MS.name .. "ShieldWall", EVENT_EFFECT_CHANGED, function(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceUnitType)
        if changeType == EFFECT_RESULT_GAINED and (abilityId == 83272 or abilityId == 83292 or abilityId == 83310) then
            MS.blockTracking.shieldWallEndTime = GetGameTimeMilliseconds() + (endTime - beginTime) * 1000
        end
    end)
    EVENT_MANAGER:AddFilterForEvent(MS.name .. "ShieldWall", EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
end

--------------------------------------------------------------------------------
-- SPRINT EVENT
--------------------------------------------------------------------------------
local function RegisterSprintEvent()
    local lastStaminaRecovery = GetPlayerStat(STAT_STAMINA_REGEN_COMBAT)
    
    EVENT_MANAGER:RegisterForUpdate(MS.name .. "SprintCheck", 50, function()
        local currentStaminaRecovery = GetPlayerStat(STAT_STAMINA_REGEN_COMBAT)
        
        if currentStaminaRecovery ~= lastStaminaRecovery then
            if MS.modules.stamskull then MS.modules.stamskull:Render() end
            if MS.modules.magskull then MS.modules.magskull:Render() end
        end
        
        lastStaminaRecovery = currentStaminaRecovery
    end)
end

--------------------------------------------------------------------------------
-- MAIN EVENT REGISTRATION
--------------------------------------------------------------------------------
-- Register all game events (called after modules are initialized)
function MS.RegisterGameEvents()
    RegisterDeathCheckEvents()
    RegisterWeaponSwapEvent()
    RegisterTargetChangeEvent()
    RegisterBlockStateEvent()
    RegisterDodgeEvent()
    RegisterShieldWallEvent()
    RegisterSprintEvent()
end
