-- -----------------------------------------------------------------------------
-- Bound Armaments Counter
-- Author:  g4rr3t/Masel
-- Created: Sep 27, 2019
--
-- Tracking.lua
-- -----------------------------------------------------------------------------

local currentStack = 0

function BAC.RegisterEvents()

    -- Events for each skill morph
    -- Separate namespaces for each are required as
    -- duplicate filters against the same namespace
    -- overwrite the previously set filter.
    --
    -- These filter the EVENT_EFFECT_CHANGED event to
    -- hit the callback *only* when these specific
    -- ability IDs change and avoid the need to conditionally
    -- exclude all skills we are not interested in.

    for morph, morphTable in pairs(BAC.ABILITIES) do
        BAC:Trace(2, "Registering: " .. morph)
        for abilityType, abilityId in pairs(morphTable) do
            local name = "BAC_" .. morph .. "_" .. abilityType
            BAC:Trace(3, "Registering: " .. name .. " (" .. abilityId .. ")")

            EVENT_MANAGER:RegisterForEvent(name, EVENT_EFFECT_CHANGED, function(...) BAC.OnEffectChanged(...) end)
            EVENT_MANAGER:AddFilterForEvent(name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId)
            EVENT_MANAGER:AddFilterForEvent(name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
        end
    end

    -- Register start/end combat events
    EVENT_MANAGER:RegisterForEvent(name, EVENT_PLAYER_COMBAT_STATE, function(...) BAC.IsInCombat(...) end)
end

function BAC.UnregisterEvents()
    for morph, morphTable in pairs(BAC.ABILITIES) do
        for abilityType, abilityId in pairs(morphTable) do
            local name = "BAC_" .. morph .. "_" .. abilityType
            BAC:Trace(3, "Unregistering: " .. name .. " (" .. abilityId .. ")")
            EVENT_MANAGER:UnregisterForEvent(name, EVENT_EFFECT_CHANGED)
        end
    end

    EVENT_MANAGER:UnregisterForEvent(BAC.name .. "COMBAT_STATE", EVENT_PLAYER_COMBAT_STATE)
end

function BAC.RegisterUnfilteredEvents()
    EVENT_MANAGER:RegisterForEvent(BAC.name .. "COMBAT_STATE", EVENT_PLAYER_COMBAT_STATE, function(...) BAC.IsInCombat(...) end)
    EVENT_MANAGER:RegisterForEvent(BAC.name .. "UNFILTERED", EVENT_EFFECT_CHANGED, function(...) BAC.OnEffectChanged(...) end)
    BAC:Trace(3, "Registering unfiltered complete")
end

function BAC.UnregisterUnfilteredEvents()
    EVENT_MANAGER:UnregisterForEvent(BAC.name .. "COMBAT_STATE", EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForEvent(BAC.name .. "UNFILTERED", EVENT_EFFECT_CHANGED)
    BAC:Trace(3, "Unregistering unfiltered complete")
end

function BAC.IsInCombat(_, inCombat)
    BAC.isInCombat = inCombat

    if inCombat then
        BAC:Trace(2, "Entered Combat")
    else
        BAC:Trace(2, "Left Combat")
        BAC.UpdateStacks(currentStack)
    end

end

function BAC.OnEffectChanged(_, changeType, _, effectName, unitTag, _, _,
        stackCount, _, _, _, _, _, _, _, effectAbilityId)

    BAC:Trace(3, effectName .. " (" .. effectAbilityId .. ")")

    -- If we have a stack
    if stackCount > 0 then
        BAC:Trace(2, "Stack for Ability ID: " .. effectAbilityId)

        BAC.SetSkillColorOverlay('default')

        if changeType == EFFECT_RESULT_FADED then
            currentStack = 0
            BAC:Trace(2, "Faded on stack #" .. stackCount)
            BAC.UpdateStacks(currentStack)
        else
            currentStack = stackCount
            BAC:Trace(1, "Stack #" .. currentStack)

            -- Update color for 3 stacks and optionally play a sound
            if currentStack == 3 then
                BAC.SetSkillColorOverlay('three')
            -- Update color for proc
            -- There would be a more "true" way to set this
            -- via a callback for the proc event gained,
            -- but this is more straight-forward than setting
            -- up another callback just for changing a color.
            elseif currentStack == 4 then
                BAC.SetSkillColorOverlay('proc')
            end

            BAC.UpdateStacks(currentStack)
        end

        return
    end

    -- Not a stack
    if changeType == EFFECT_RESULT_GAINED then
        BAC:Trace(2, "Skill Activated: " ..  effectName .. " (" .. effectAbilityId ..") with " .. currentStack .. " stacks")
        BAC.abilityActive = true
        BAC.SetSkillFade(false)

        if currentStack == 3 then
            BAC.SetSkillColorOverlay('three')
        elseif currentStack == 4 then
            BAC.SetSkillColorOverlay('proc')
        else
            BAC.SetSkillColorOverlay('default')
        end

        BAC.UpdateStacks(currentStack)
        return
    end

    if changeType == EFFECT_RESULT_FADED then
        BAC:Trace(2, "Skill Inactive: " ..  effectName .. " (" .. effectAbilityId ..") with " .. currentStack .. " stacks")
        BAC.abilityActive = false
        BAC.SetSkillFade(true)
        BAC.SetSkillColorOverlay('inactive')
        BAC.UpdateStacks(currentStack)
        return
    end

end
