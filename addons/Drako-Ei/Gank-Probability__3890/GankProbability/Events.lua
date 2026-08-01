local GP = GankProbability
local internal = GP.internal
local activeEvents = false
internal.playerCanEngage = true

function internal.initializeAddon(event, name)
    if(name == GP.name) then
        internal.initializeGankProbability()
        internal.initializeModel()
        internal.initializeMenu()
        internal.toggleEvents(GP.savedVars.active)
    end
end

function internal.playerActivated(event, name)
    internal.clearReticle()
    internal.targettedPlayers = {}
end

function internal.onEngageCooldownOver()
    internal.playerCanEngage = true
end 

function internal.onCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)

    if result ~= ACTION_RESULT_DAMAGE and result ~= ACTION_RESULT_KILLING_BLOW then return end
	if (sourceType ~= COMBAT_UNIT_TYPE_PLAYER and sourceType ~= COMBAT_UNIT_TYPE_PLAYER_PET) and targetType ~= COMBAT_UNIT_TYPE_OTHER and targetType ~= COMBAT_UNIT_TYPE_PLAYER then return end
    
    sourceName = zo_strformat("<<1>>", sourceName)
    if sourceName ~= GetUnitName("player") then return end

    local targettedPlayer = internal.targettedPlayers[zo_strformat("<<1>>", targetName)]

    if targettedPlayer == nil then return end

    if result == ACTION_RESULT_KILLING_BLOW then
        if internal.engagedPlayer ~= nil and internal.engagedPlayer.name == targettedPlayer.name then
            internal.engagedPlayer = nil
            zo_callLater(internal.onEngageCooldownOver, 1000)
            internal.registerGankAttempt(targettedPlayer, true)
        end
    else
        
        -- Save the first player engaged
        if internal.engagedPlayer == nil and internal.playerCanEngage then
            internal.playerCanEngage = false
            internal.engagedPlayer = targettedPlayer
        end

    end
   
end

function internal.onDeathEvent(eventCode)
    if internal.engagedPlayer ~= nil then
        zo_callLater(internal.onEngageCooldownOver, 1000)
        internal.registerGankAttempt(internal.engagedPlayer, false)
        internal.engagedPlayer = nil
    end
end

function internal.onCombatState(eventCode, inCombat)
    if not inCombat and internal.engagedPlayer ~= nil then
        zo_callLater(internal.onEngageCooldownOver, 1000)
        internal.registerGankAttempt(internal.engagedPlayer, false)
        internal.engagedPlayer = nil
    end
end

function internal.toggleEvents(active)
    if active == activeEvents then return end
    activeEvents = active
    if active then
        EVENT_MANAGER:RegisterForEvent(GP.name, EVENT_RETICLE_TARGET_CHANGED, internal.onReticleTargetChanged)
        EVENT_MANAGER:RegisterForEvent(GP.name, EVENT_PLAYER_ACTIVATED, internal.playerActivated)
        EVENT_MANAGER:RegisterForEvent(GP.name, EVENT_COMBAT_EVENT, internal.onCombatEvent)
        EVENT_MANAGER:RegisterForEvent(GP.name, EVENT_PLAYER_DEAD, internal.onDeathEvent)
        EVENT_MANAGER:RegisterForEvent(GP.name, EVENT_PLAYER_COMBAT_STATE, internal.onCombatState)
    else
        EVENT_MANAGER:UnregisterForEvent(GP.name, EVENT_RETICLE_TARGET_CHANGED)
        EVENT_MANAGER:UnregisterForEvent(GP.name, EVENT_PLAYER_ACTIVATED)
        EVENT_MANAGER:UnregisterForEvent(GP.name, EVENT_COMBAT_EVENT)
        EVENT_MANAGER:UnregisterForEvent(GP.name, EVENT_PLAYER_DEAD)
        EVENT_MANAGER:UnregisterForEvent(GP.name, EVENT_PLAYER_COMBAT_STATE)
    end
end

EVENT_MANAGER:RegisterForEvent(GP.name, EVENT_ADD_ON_LOADED, internal.initializeAddon)



