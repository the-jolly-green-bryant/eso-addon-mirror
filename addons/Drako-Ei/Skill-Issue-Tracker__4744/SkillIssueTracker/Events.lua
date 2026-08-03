local SIT = SkillIssueTracker
local events = SIT.events
local utils = SIT.utils
local target = SIT.target
local selector = SIT.selector
local menu = SIT.menu

local VALID_COMBAT_RESULTS = {
    [ACTION_RESULT_DAMAGE] = true,
    [ACTION_RESULT_DAMAGE_SHIELDED] = true,
    [ACTION_RESULT_CRITICAL_DAMAGE] = true,
    [ACTION_RESULT_DOT_TICK] = true,
    [ACTION_RESULT_DOT_TICK_CRITICAL] = true,
    [ACTION_RESULT_BLOCKED_DAMAGE] = true
}

events.OnReticleTargetChanged = function(event)
    
    local targetInfo = utils.getPlayerReticleInfo()
    if not targetInfo then return end

    selector.integratePlayerFromReticleInformation(targetInfo)
    target.updateTarget(targetInfo)

   
end

events.OnCombat = function(event, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    if not targetName then return end
    if not hitValue or hitValue <= 0 then return end
    if not VALID_COMBAT_RESULTS[result] then return end
    if targetType ~= COMBAT_UNIT_TYPE_OTHER then return end
    selector.integrateDamageEvent(result, zo_strformat(SI_UNIT_NAME, targetName), hitValue, abilityId, GetFrameTimeMilliseconds())

end

events.OnTick = function()
    selector.update(GetFrameTimeMilliseconds())
end

-- Activate only if the current world is battlegrounds
events.activateBattlegroundEvents = function()

    if SIT.savedVars.enabled and IsActiveWorldBattleground() then

        if not events.battlegroundEventsLoaded then
            EVENT_MANAGER:RegisterForEvent(SIT.name, EVENT_RETICLE_TARGET_CHANGED, events.OnReticleTargetChanged)
            EVENT_MANAGER:RegisterForEvent(SIT.name, EVENT_COMBAT_EVENT, events.OnCombat)
            EVENT_MANAGER:AddFilterForEvent(SIT.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
            EVENT_MANAGER:AddFilterForEvent(SIT.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_ERROR, false)
            EVENT_MANAGER:RegisterForUpdate(SIT.name .. "_OnTick", 3000, events.OnTick)
            target.reset()
            selector.reset()
            selector.initialize()
            events.battlegroundEventsLoaded = true
        end

    else

        if events.battlegroundEventsLoaded then
            EVENT_MANAGER:UnregisterForEvent(SIT.name, EVENT_RETICLE_TARGET_CHANGED)
            EVENT_MANAGER:UnregisterForEvent(SIT.name, EVENT_COMBAT_EVENT)
            EVENT_MANAGER:UnregisterForUpdate(SIT.name .. "_OnTick")
            events.battlegroundEventsLoaded = false
        end
    end

end

events.OnPlayerActivated = function(event)
    events.activateBattlegroundEvents()
end

events.OnAddonLoaded = function(event, addonName)

    if addonName ~= SIT.name then return end
    SIT.internal.initialize()
    menu.initialize()
    EVENT_MANAGER:UnregisterForEvent(SIT.name, EVENT_ADD_ON_LOADED)
    EVENT_MANAGER:RegisterForEvent(SIT.name, EVENT_PLAYER_ACTIVATED, events.OnPlayerActivated)
    events.activateBattlegroundEvents()

end

EVENT_MANAGER:RegisterForEvent(SIT.name, EVENT_ADD_ON_LOADED, events.OnAddonLoaded)