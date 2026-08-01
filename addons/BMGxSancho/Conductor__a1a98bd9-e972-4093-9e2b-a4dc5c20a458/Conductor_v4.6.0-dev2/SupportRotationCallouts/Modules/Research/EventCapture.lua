local SRC = SupportRotationCallouts
SRC.ResearchCapture = SRC.ResearchCapture or {}
local Capture = SRC.ResearchCapture

local EFFECT_EVENT = SRC.name .. "ResearchEffects"
local COMBAT_EVENT = SRC.name .. "ResearchCombat"

local KEYWORDS = {
    "nazaray",
    "pillager",
    "major slayer",
    "roaring opportunist",
    "jorvuld",
    "master architect",
    "war machine",
}

local function Matches(name)
    local value = zo_strlower(tostring(name or ""))
    for _, keyword in ipairs(KEYWORDS) do
        if string.find(value, keyword, 1, true) then return true end
    end
    return false
end

local function Log(category, message, fields)
    if not SRC.saved or not SRC.saved.researchCaptureEnabled then return end
    if not SRC.saved.developerDiagnostics then return end
    if SRC.Diagnostics and SRC.Diagnostics.AddFields then
        SRC.Diagnostics:AddFields(category, message, fields)
    end
end

function Capture:OnEffectChanged(changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    if not Matches(effectName) and abilityId ~= 106754 then return end
    Log("RESEARCH_EFFECT", "Relevant effect event", {
        abilityId = abilityId,
        effectName = effectName,
        changeType = changeType,
        beginTime = beginTime,
        endTime = endTime,
        remaining = (endTime or 0) - GetGameTimeSeconds(),
        stackCount = stackCount,
        unitTag = unitTag,
        unitName = unitName,
        unitId = unitId,
        sourceType = sourceType,
        effectType = effectType,
        statusEffectType = statusEffectType,
    })
end

function Capture:OnCombatEvent(result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if not Matches(abilityName) then return end
    Log("RESEARCH_COMBAT", "Relevant combat event", {
        abilityId = abilityId,
        abilityName = abilityName,
        result = result,
        sourceName = sourceName,
        sourceType = sourceType,
        sourceUnitId = sourceUnitId,
        targetName = targetName,
        targetType = targetType,
        targetUnitId = targetUnitId,
        hitValue = hitValue,
    })
end

function Capture:Initialize()
    if not SRC.saved or SRC.saved.researchCaptureEnabled ~= true or SRC.saved.developerDiagnostics ~= true then
        if SRC.Diagnostics then SRC.Diagnostics:Add("Research capture listeners disabled") end
        return
    end
    EVENT_MANAGER:RegisterForEvent(EFFECT_EVENT, EVENT_EFFECT_CHANGED,
        function(_, ...) Capture:OnEffectChanged(...) end)
    EVENT_MANAGER:RegisterForEvent(COMBAT_EVENT, EVENT_COMBAT_EVENT,
        function(_, ...) Capture:OnCombatEvent(...) end)
    if SRC.Diagnostics then SRC.Diagnostics:Add("Research capture listeners registered") end
end
