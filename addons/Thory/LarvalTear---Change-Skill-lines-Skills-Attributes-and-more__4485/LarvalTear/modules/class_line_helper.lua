local Addon = LarvalTearMod
local M = Addon.Modules.ClassLineHelper
local Util = Addon.Common.Util

local function NormalizePositiveInteger(value)
    local number = tonumber(value)
    if number == nil or number <= 0 or math.floor(number) ~= number then
        return nil
    end
    return number
end

local function NormalizeLineIds(lineIds)
    local normalized = {}
    local seen = {}
    for _, value in ipairs(type(lineIds) == "table" and lineIds or {}) do
        local lineId = NormalizePositiveInteger(value)
        if lineId ~= nil and seen[lineId] ~= true then
            seen[lineId] = true
            normalized[#normalized + 1] = lineId
        end
    end
    table.sort(normalized)
    return normalized, seen
end

local function ResolveTargetLineIds(buildOrLineIds)
    if type(buildOrLineIds) == "table"
        and type(buildOrLineIds.subclass) == "table"
        and type(buildOrLineIds.subclass.targetSkillLineIds) == "table" then
        return buildOrLineIds.subclass.targetSkillLineIds
    end
    return buildOrLineIds
end

local function IsClassSkillLineData(skillLineData, skillLineId)
    if type(skillLineData) == "table" then
        if Util:SafeCallMethod(skillLineData, "IsClassSkillLine") == true
            or Util:SafeCallMethod(skillLineData, "IsPlayerClassSkillLine") == true then
            return true
        end
        local classId = Util:SafeCallMethod(skillLineData, "GetClassId")
        if type(classId) == "number" and classId > 0 then
            return true
        end
    end

    return type(IsPlayerClassSkillLineById) == "function"
        and skillLineId ~= nil
        and IsPlayerClassSkillLineById(skillLineId) == true
end

function M:ResolveSkillLineData(skillLineId)
    skillLineId = NormalizePositiveInteger(skillLineId)
    if skillLineId == nil
        or type(SKILLS_DATA_MANAGER) ~= "table"
        or type(SKILLS_DATA_MANAGER.GetSkillLineDataById) ~= "function" then
        return nil
    end

    local skillLineData = SKILLS_DATA_MANAGER:GetSkillLineDataById(skillLineId)
    if type(skillLineData) == "table" and type(skillLineData.RefreshDynamicData) == "function" then
        skillLineData:RefreshDynamicData(true)
    end
    return skillLineData
end

function M:IsClassSkillLine(skillLineData, skillLineId)
    return IsClassSkillLineData(skillLineData, NormalizePositiveInteger(skillLineId))
end

function M:GetCurrentActiveClassLineIds()
    local subclassSnapshot = Addon.Modules.SubclassSnapshot
    if type(subclassSnapshot) == "table"
        and type(subclassSnapshot.CaptureCurrentSubclassState) == "function" then
        local state = subclassSnapshot:CaptureCurrentSubclassState({})
        local lineIds = type(state) == "table" and state.activeSkillLineIds or nil
        local normalized = NormalizeLineIds(lineIds)
        if #normalized > 0 then
            return normalized, {
                ok = #normalized == 3,
                currentLineIds = normalized,
                currentLineCount = #normalized,
                source = "subclass_snapshot",
                reason = #normalized == 3 and nil or "current_class_line_count_not_three",
            }
        end
    end

    local lineIds = {}
    local seen = {}
    if type(SKILLS_DATA_MANAGER) == "table" and type(SKILLS_DATA_MANAGER.SkillTypeIterator) == "function" then
        for _, skillTypeData in SKILLS_DATA_MANAGER:SkillTypeIterator() do
            if type(skillTypeData) == "table" and type(skillTypeData.SkillLineIterator) == "function" then
                for _, skillLineData in skillTypeData:SkillLineIterator() do
                    local skillLineId = NormalizePositiveInteger(Util:SafeCallMethod(skillLineData, "GetId"))
                    if skillLineId ~= nil
                        and seen[skillLineId] ~= true
                        and IsClassSkillLineData(skillLineData, skillLineId)
                        and Util:SafeCallMethod(skillLineData, "IsActive") == true then
                        seen[skillLineId] = true
                        lineIds[#lineIds + 1] = skillLineId
                    end
                end
            end
        end
    end
    table.sort(lineIds)
    return lineIds, {
        ok = #lineIds == 3,
        currentLineIds = lineIds,
        currentLineCount = #lineIds,
        source = "skill_type_iterator",
        reason = #lineIds == 3 and nil or "current_class_line_count_not_three",
    }
end

function M:HasClassCompositionChanged(buildOrLineIds)
    local targetLineIds, targetSet = NormalizeLineIds(ResolveTargetLineIds(buildOrLineIds))
    if #targetLineIds ~= 3 then
        return nil, {
            ok = false,
            comparisonResolved = false,
            reason = "target_line_count_not_three",
            targetLineIds = targetLineIds,
            targetLineCount = #targetLineIds,
        }
    end

    local currentLineIds, currentDiagnostics = self:GetCurrentActiveClassLineIds()
    if type(currentLineIds) ~= "table" or #currentLineIds ~= 3 then
        currentDiagnostics = type(currentDiagnostics) == "table" and currentDiagnostics or {}
        currentDiagnostics.ok = false
        currentDiagnostics.comparisonResolved = false
        currentDiagnostics.targetLineIds = targetLineIds
        currentDiagnostics.targetLineCount = #targetLineIds
        return nil, currentDiagnostics
    end

    local currentSet = {}
    for _, lineId in ipairs(currentLineIds) do
        currentSet[lineId] = true
    end

    local missingFromCurrent = {}
    local extraInCurrent = {}
    for _, lineId in ipairs(targetLineIds) do
        if currentSet[lineId] ~= true then
            missingFromCurrent[#missingFromCurrent + 1] = lineId
        end
    end
    for _, lineId in ipairs(currentLineIds) do
        if targetSet[lineId] ~= true then
            extraInCurrent[#extraInCurrent + 1] = lineId
        end
    end

    local changed = #missingFromCurrent > 0 or #extraInCurrent > 0
    return changed, {
        ok = true,
        comparisonResolved = true,
        classCompositionChanged = changed,
        currentLineIds = currentLineIds,
        targetLineIds = targetLineIds,
        currentLineCount = #currentLineIds,
        targetLineCount = #targetLineIds,
        missingFromCurrent = missingFromCurrent,
        extraInCurrent = extraInCurrent,
        reason = changed and "class_composition_changed" or nil,
    }
end
