local SRC = SupportRotationCallouts
SRC.WarhornEventAdapter = SRC.WarhornEventAdapter or {}
local Adapter = SRC.WarhornEventAdapter

function Adapter:Initialize()
    for abilityId in pairs(SRC.Warhorn.ABILITY_IDS) do
        local eventName = SRC.name .. "WarhornCast" .. tostring(abilityId)
        EVENT_MANAGER:RegisterForEvent(
            eventName,
            EVENT_COMBAT_EVENT,
            function(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType,
                    sourceName, sourceType, targetName, targetType, hitValue, powerType,
                    damageType, log, sourceUnitId, targetUnitId, observedAbilityId, overflow)
                SRC.Diagnostics:AddFields("RAW_CAST", "Warhorn combat event", {
                    abilityId = observedAbilityId,
                    configuredAbilityId = abilityId,
                    abilityName = abilityName,
                    result = result,
                    sourceName = sourceName,
                    sourceType = sourceType,
                    targetName = targetName,
                    targetType = targetType,
                    sourceUnitId = sourceUnitId,
                    targetUnitId = targetUnitId,
                })
            end
        )
        EVENT_MANAGER:AddFilterForEvent(
            eventName,
            EVENT_COMBAT_EVENT,
            REGISTER_FILTER_ABILITY_ID,
            abilityId
        )
    end

    for effectId in pairs(SRC.Warhorn.EFFECT_IDS) do
        local eventName = SRC.name .. "HornEffect" .. tostring(effectId)
        EVENT_MANAGER:RegisterForEvent(
            eventName,
            EVENT_EFFECT_CHANGED,
            function(_, changeType, effectSlot, effectName, unitTag, beginTime, endTime,
                    stackCount, iconName, buffType, effectType, abilityType,
                    statusEffectType, unitName, unitId, abilityId, sourceType)
                SRC.Diagnostics:AddFields("RAW_EFFECT", "Warhorn effect event", {
                    abilityId = abilityId,
                    effectName = effectName,
                    changeType = changeType,
                    unitTag = unitTag,
                    unitName = unitName,
                    beginTime = beginTime,
                    endTime = endTime,
                    remaining = endTime - GetGameTimeSeconds(),
                    sourceType = sourceType,
                })

                if not SRC.saved.enabled
                    or not SRC.saved.warhornEnabled
                    or endTime <= GetGameTimeSeconds() then
                    return
                end

                SRC.WarhornRotation:OnEffectUpdate({
                    beginTime = beginTime,
                    endTime = endTime,
                    unitTag = unitTag,
                    unitName = unitName,
                    abilityId = abilityId,
                })
            end
        )
        EVENT_MANAGER:AddFilterForEvent(
            eventName,
            EVENT_EFFECT_CHANGED,
            REGISTER_FILTER_ABILITY_ID,
            effectId
        )
        EVENT_MANAGER:AddFilterForEvent(
            eventName,
            EVENT_EFFECT_CHANGED,
            REGISTER_FILTER_UNIT_TAG,
            "player"
        )
    end

    SRC.Diagnostics:AddFields("WARHORN", "Warhorn listeners registered", {
        baseAbilityId = 38564,
        aggressiveSlottedAbilityId = 40223,
        aggressivePublicAbilityId = 40224,
        sturdyAbilityId = 40221,
        majorForceEffectId = 40225,
    })
end
