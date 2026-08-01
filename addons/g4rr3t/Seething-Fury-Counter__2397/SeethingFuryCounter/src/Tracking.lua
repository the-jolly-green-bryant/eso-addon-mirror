-- -----------------------------------------------------------------------------
-- Seething Fury Counter
-- Author:  g4rr3t
-- Created: May 22, 2019
--
-- Tracking.lua
-- -----------------------------------------------------------------------------

SFC.Tracking = {}

local EM = EVENT_MANAGER

local SEETHING_FURY_SKILL_ID = 122658

function SFC.Tracking.GetAbilityDuration()
    return GetAbilityDuration(SEETHING_FURY_SKILL_ID, nil)
end

function SFC.Tracking.RegisterEvents()

    SFC:Trace(2, "Registering events")

    EM:RegisterForEvent(SFC.name, EVENT_EFFECT_CHANGED, SFC.OnEffectChanged)
    EM:AddFilterForEvent(SFC.name, EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_ABILITY_ID, SEETHING_FURY_SKILL_ID,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

end

function SFC.UnregisterEvents()
    EM:UnregisterForEvent(SFC.name, EVENT_EFFECT_CHANGED)
end


function SFC.OnEffectChanged(_, changeType, _, effectName, unitTag, _, _,
        stackCount, _, _, _, _, _, _, _, effectAbilityId)

    SFC:Trace(3, "<<1>> (<<2>>)", effectName, effectAbilityId)

    -- Ignore non-stacks
    if not stackCount then return end

    SFC:Trace(2, "Stack for Ability ID: <<1>>", effectAbilityId)

    if changeType == EFFECT_RESULT_FADED then
        SFC:Trace(2, "Faded on stack #<<1>>", stackCount)
        SFC.UI.UpdateStacks(stackCount, false)
    else
        SFC:Trace(1, "Stack #<<1>>", stackCount)
        SFC.UI.UpdateStacks(stackCount, true)
    end

end

