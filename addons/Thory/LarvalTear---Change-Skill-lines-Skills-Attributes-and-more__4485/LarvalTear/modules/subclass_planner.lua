local Addon = LarvalTearMod
local LTM_SUBCLASS_PLANNER = Addon.Modules.SubclassPlanner
local SHARED_UTIL = Addon.Common.Util

local function CloneArray(values)
    local cloned = {}
    for index, value in ipairs(values or {}) do
        cloned[index] = value
    end
    return cloned
end

local function ExtractCurrentActiveSkillLineIds(currentState)
    if type(currentState) ~= "table" then
        return {}
    end

    if type(currentState.activeSkillLineIds) == "table" then
        return SHARED_UTIL:NormalizeLineIdList(currentState.activeSkillLineIds)
    end

    local extracted = {}
    for _, entry in ipairs(currentState.activeLines or {}) do
        if type(entry) == "table" then
            extracted[#extracted + 1] = entry.skillLineId
        end
    end

    return SHARED_UTIL:NormalizeLineIdList(extracted)
end

local function ResolveBaseClassId(context, currentState)
    if type(context) == "table" and context.baseClassId ~= nil then
        return context.baseClassId
    end

    if type(currentState) == "table" and type(currentState.classInfo) == "table" then
        return currentState.classInfo.baseClassId
    end

    return nil
end

local function GetCurrentActiveLines(currentState)
    if type(currentState) ~= "table" or type(currentState.activeSkillLines) ~= "table" then
        return {}
    end

    return currentState.activeSkillLines
end

local function BuildSkillLineClassIdMap(currentState)
    local map = {}

    if type(currentState) == "table" and type(currentState.allSkillLineById) == "table" then
        for skillLineId, line in pairs(currentState.allSkillLineById) do
            if type(line) == "table" then
                map[skillLineId] = line.classId
            end
        end
    end

    for _, line in ipairs(GetCurrentActiveLines(currentState)) do
        if type(line) == "table" and type(line.skillLineId) == "number" then
            map[line.skillLineId] = line.classId
        end
    end

    return map
end

local function FindCurrentMainClassLineId(currentState, baseClassId)
    if baseClassId == nil then
        return nil
    end

    for _, line in ipairs(GetCurrentActiveLines(currentState)) do
        if type(line) == "table" and line.classId == baseClassId and type(line.skillLineId) == "number" then
            return line.skillLineId
        end
    end

    return nil
end

local function FindTargetMainClassLineId(targetSkillLineIds, skillLineClassIdMap, baseClassId)
    if baseClassId == nil then
        return nil
    end

    for _, skillLineId in ipairs(targetSkillLineIds or {}) do
        if skillLineClassIdMap[skillLineId] == baseClassId then
            return skillLineId
        end
    end

    return nil
end

local function SortNumeric(list)
    table.sort(list, function(left, right)
        return (left or 0) < (right or 0)
    end)
end

local function BuildOrderedOperations(activate, deactivate, currentMainClassLineId, targetMainClassLineId)
    local orderedOperations = {}
    local orderedDeactivate = CloneArray(deactivate)
    local orderedActivate = CloneArray(activate)

    SortNumeric(orderedDeactivate)
    SortNumeric(orderedActivate)

    if currentMainClassLineId ~= nil then
        table.sort(orderedDeactivate, function(left, right)
            if left == currentMainClassLineId then
                return true
            end
            if right == currentMainClassLineId then
                return false
            end
            return (left or 0) < (right or 0)
        end)
    end

    if targetMainClassLineId ~= nil then
        table.sort(orderedActivate, function(left, right)
            if left == targetMainClassLineId then
                return true
            end
            if right == targetMainClassLineId then
                return false
            end
            return (left or 0) < (right or 0)
        end)
    end

    for _, skillLineId in ipairs(orderedDeactivate) do
        orderedOperations[#orderedOperations + 1] = {
            op = "deactivate",
            skillLineId = skillLineId,
            priority = skillLineId == currentMainClassLineId and "main_class" or "normal",
        }
    end

    for _, skillLineId in ipairs(orderedActivate) do
        orderedOperations[#orderedOperations + 1] = {
            op = "activate",
            skillLineId = skillLineId,
            priority = skillLineId == targetMainClassLineId and "main_class" or "normal",
        }
    end

    return orderedOperations
end

local function BuildDiagnostics(currentState, targetState)
    return {
        plannerVersion = 1,
        constraints = {
            requireBaseClassLine = true,
            maxOneExternalLinePerClass = true,
        },
        currentActiveLineCount = #(ExtractCurrentActiveSkillLineIds(currentState) or {}),
        targetPresent = type(targetState) == "table",
        planningImplemented = true,
    }
end

function LTM_SUBCLASS_PLANNER:BuildSubclassPlan(context, currentState, targetState)
    if type(targetState) ~= "table" then
        return {
            ok = false,
            reason = "target_subclass_state_missing",
            steps = {},
            diagnostics = BuildDiagnostics(currentState, targetState),
        }
    end

    local targetSkillLineIds = SHARED_UTIL:NormalizeLineIdList(targetState.targetSkillLineIds)
    local currentSkillLineIds = ExtractCurrentActiveSkillLineIds(currentState)
    local targetSet = SHARED_UTIL:BuildLineIdSet(targetSkillLineIds)
    local currentSet = SHARED_UTIL:BuildLineIdSet(currentSkillLineIds)
    local activate = {}
    local deactivate = {}
    local baseClassId = ResolveBaseClassId(context, currentState)
    local skillLineClassIdMap = BuildSkillLineClassIdMap(currentState)
    local currentMainClassLineId = FindCurrentMainClassLineId(currentState, baseClassId)
    local targetMainClassLineId = FindTargetMainClassLineId(targetSkillLineIds, skillLineClassIdMap, baseClassId)
    local mainClassTargetIncluded = targetMainClassLineId ~= nil

    for _, lineId in ipairs(targetSkillLineIds) do
        if not currentSet[lineId] then
            activate[#activate + 1] = lineId
        end
    end

    for _, lineId in ipairs(currentSkillLineIds) do
        if not targetSet[lineId] then
            deactivate[#deactivate + 1] = lineId
        end
    end

    local hasDiff = #activate > 0 or #deactivate > 0
    local orderedOperations = BuildOrderedOperations(
        activate,
        deactivate,
        mainClassTargetIncluded and currentMainClassLineId or nil,
        mainClassTargetIncluded and targetMainClassLineId or nil
    )
    local diagnostics = BuildDiagnostics(currentState, targetState)
    diagnostics.currentSkillLineIds = currentSkillLineIds
    diagnostics.targetSkillLineIds = targetSkillLineIds
    diagnostics.baseClassId = baseClassId
    diagnostics.currentMainClassLineId = currentMainClassLineId
    diagnostics.targetMainClassLineId = targetMainClassLineId
    diagnostics.mainClassTargetIncluded = mainClassTargetIncluded

    return {
        ok = true,
        reason = hasDiff and "subclass_diff_detected" or "subclass_already_matches_target",
        steps = {},
        activate = activate,
        deactivate = deactivate,
        orderedOperations = orderedOperations,
        hasDiff = hasDiff,
        currentSkillLineIds = currentSkillLineIds,
        targetSkillLineIds = targetSkillLineIds,
        diagnostics = diagnostics,
        currentState = currentState,
        targetState = targetState,
        immutable = {
            characterId = context and context.characterId or nil,
            baseClassId = baseClassId,
        },
    }
end
