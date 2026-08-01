local BEV = BetterEffectViewer

local function OnEffectChanged(eventCode, changeType,
    effectSlot, effectName, unitTag,
    beginTime, endTime, stackCount, iconName,
    buffType, effectType, abilityType, statusEffectType,
    unitName, unitId, abilityId, sourceType)

    if unitTag ~= "reticleover" and unitTag ~= "reticleoverplayer" then
        return
    end
    if not effectName or effectName == "" then
        return
    end

    local key = BEV:MakeEffectKey(abilityId, iconName, effectType)

    if changeType == EFFECT_RESULT_FADED
        or changeType == EFFECT_RESULT_FULLY_REMOVED
        or changeType == EFFECT_RESULT_TRANSFER then
        BEV:RemoveEffectByKey(key)
        BEV.needsRedraw = true
        return
    end

    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        local effect = BEV:BuildEffect(
            effectName,
            abilityId,
            iconName,
            effectType,
            buffType,
            beginTime,
            endTime,
            stackCount,
            statusEffectType,
            sourceType
        )

        BEV:UpsertEffect(effect)
        BEV.needsRedraw = true
    end
end

function BEV:RegisterEffectEvents()
    EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "reticleover")
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_EFFECT_CHANGED, OnEffectChanged)

    EVENT_MANAGER:AddFilterForEvent(self.name .. "Update", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "reticleoverplayer")
    EVENT_MANAGER:RegisterForEvent(self.name .. "Update", EVENT_EFFECT_CHANGED, OnEffectChanged)
end
