CrystalFragmentsLogger = CrystalFragmentsLogger or {}

-- Crystal Fragments の abilityId はログを見て後でここに入れる
CrystalFragmentsLogger.ids = {
    normal = nil,   -- 通常版
    instant = nil,  -- 即時発動版
    buff = nil,     -- Proc バフ（8秒）
}

function CrystalFragmentsLogger.Initialize()
    CrystalFragmentsLogger.saved = ZO_SavedVars:NewAccountWide(
        "CrystalFragmentsLogger_SV", 1, nil, { logs = {} }
    )

    EVENT_MANAGER:RegisterForEvent("CFL_Combat", EVENT_COMBAT_EVENT, CrystalFragmentsLogger.OnCombat)
    EVENT_MANAGER:RegisterForEvent("CFL_Effect", EVENT_EFFECT_CHANGED, CrystalFragmentsLogger.OnEffect)
end

local function Log(msg)
    d(msg)
    table.insert(CrystalFragmentsLogger.saved.logs, msg)
end

-- ダメージ・ヒット系（通常版と即時版の abilityId がここで取れる）
function CrystalFragmentsLogger.OnCombat(_, result, isError, abilityId, hitValue,
                                        powerType, damageType, log, sourceName,
                                        sourceType, targetName, targetType)
    if sourceName == GetUnitName("player") then
        Log(string.format("[CF COMBAT] abilityId=%d hit=%d", abilityId, hitValue))
    end
end

-- Proc バフ（Crystal Fragments Ready）の検知
function CrystalFragmentsLogger.OnEffect(_, changeType, effectSlot, effectName, unitTag,
                                        beginTime, endTime, stackCount, iconName,
                                        buffType, effectType, abilityType, statusEffectType,
                                        unitName, unitId, abilityId, sourceType)

    if unitTag ~= "player" then return end

    -- Proc バフは EFFECT_RESULT_GAINED
    if changeType == EFFECT_RESULT_GAINED then
        Log(string.format("[CF BUFF] abilityId=%d begin=%.2f end=%.2f duration=%.2f",
            abilityId, beginTime, endTime, endTime - beginTime))
    end
end

EVENT_MANAGER:RegisterForEvent("CFL_Init", EVENT_ADD_ON_LOADED, function(_, addon)
    if addon == "CrystalFragmentsLogger" then
        CrystalFragmentsLogger.Initialize()
    end
end)
