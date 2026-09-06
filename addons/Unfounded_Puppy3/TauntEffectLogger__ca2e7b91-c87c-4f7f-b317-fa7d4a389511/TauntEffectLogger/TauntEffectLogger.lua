local ADDON_NAME = "TauntEffectLogger"
local TAUNT_DEBUFF_ID = 38254

local function OnEffectChanged(
    eventCode, changeType, effectSlot, effectName, unitTag,
    beginTime, endTime, stackCount, iconName, buffType,
    effectType, abilityType, statusEffectType, unitName, unitId,
    abilityId, sourceType
)

    -- タウントデバフ以外は無視
--    if abilityId ~= TAUNT_DEBUFF_ID then
--        return
--    end

    d("===== TAUNT EFFECT DETECTED =====")
--    d("eventCode: " .. tostring(eventCode))
--    d("changeType: " .. tostring(changeType))
--    d("effectSlot: " .. tostring(effectSlot))
    d("effectName: " .. tostring(effectName))
    d("unitTag: " .. tostring(unitTag))
    d("beginTime: " .. tostring(beginTime))
    d("endTime: " .. tostring(endTime))
    d("stackCount: " .. tostring(stackCount))
    d("iconName: " .. tostring(iconName))
--    d("buffType: " .. tostring(buffType))
--    d("effectType: " .. tostring(effectType))
--    d("abilityType: " .. tostring(abilityType))
--    d("statusEffectType: " .. tostring(statusEffectType))
    d("unitName: " .. tostring(unitName))
    d("unitId: " .. tostring(unitId))
    d("abilityId: " .. tostring(abilityId))
    d("sourceType: " .. tostring(sourceType)) -- ★ 他人の taunt は 0 になる
end

local function OnAddOnLoaded(event, addonName)
    if addonName ~= ADDON_NAME then return end

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME,
        EVENT_EFFECT_CHANGED,
        OnEffectChanged
    )

--    EVENT_MANAGER:AddFilterForEvent(
--        ADDON_NAME,
--        EVENT_EFFECT_CHANGED,
--        REGISTER_FILTER_ABILITY_ID,
--        TAUNT_DEBUFF_ID
--    )

    d("TauntEffectLogger Loaded (API 101048)")
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)