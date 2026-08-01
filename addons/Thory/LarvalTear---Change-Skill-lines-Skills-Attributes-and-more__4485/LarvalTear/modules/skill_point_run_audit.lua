-- ReloadUI-scoped audit state for accepted Skill Point plans and terminal results.
-- This module never writes SavedVariables.
local Addon = LarvalTearMod
local Log = Addon.Common.Log
local SkillPointRunAudit = Addon.Modules.SkillPointRunAudit

local LOGGER_CHILD_TAG = "SkillPointRunAudit"

local acceptedPlansByRunId = {}
local DOWNSTREAM_FAILURE_PHASES = {
    Equipment = true,
    Role = true,
    ClassMastery = true,
    Attribute = true,
    ChampionPoints = true,
}
local SKILL_DOMAIN_PARTIAL_RESULT_CODES = {
    passive_auto_fill_insufficient_points_partial = true,
    passive_exact_restore_partial = true,
    route_b_degraded_insufficient_points = true,
    skill_phase_skipped_insufficient_points = true,
}
local PASSIVE_PARTIAL_RESULT_CODES = {
    passive_auto_fill_insufficient_points_partial = true,
    passive_exact_restore_partial = true,
    route_b_degraded_insufficient_points = true,
}

local function StringifyLogValue(value)
    local text = value == nil and "-" or tostring(value)
    text = string.gsub(text, "[%s]+", "_")
    return text
end

local function EmitAuditLog(message)
    if type(Log) ~= "table"
        or type(Log.IsDebugEnabled) ~= "function"
        or Log.IsDebugEnabled() ~= true
        or type(Log.GetChildLogger) ~= "function" then
        return
    end

    local ok, logger = pcall(Log.GetChildLogger, LOGGER_CHILD_TAG)
    if not ok or logger == nil or type(logger.Debug) ~= "function" then
        return
    end
    pcall(logger.Debug, logger, message)
end

local function CloneSpSaverPolicy(policy)
    if type(policy) ~= "table" then
        return nil
    end

    return {
        activeMode = policy.activeMode,
        passiveMode = policy.passiveMode,
        activeAction = policy.activeAction,
        passiveAction = policy.passiveAction,
        reason = policy.reason,
        source = policy.source,
    }
end

local function HasSkippedTarget(targets)
    return type(targets) == "table"
        and (targets.normal_skill_changes == true or targets.normal_passive_changes == true)
end

local function ResolveExpectedSkippedTargets(finalResult)
    local expected = type(finalResult) == "table" and finalResult.spSaverExpected or nil
    return type(expected) == "table" and type(expected.skippedTargets) == "table"
        and expected.skippedTargets
        or {}
end

local function ResolveExpectedSpSaverReason(policy, expectedTargets)
    if type(policy) ~= "table" or not HasSkippedTarget(expectedTargets) then
        return nil
    end
    if expectedTargets.normal_skill_changes == true then
        return "sp_saver_skip_skill_changes"
    end
    if expectedTargets.normal_passive_changes ~= true then
        return nil
    end
    if policy.activeAction == "skip_skill_changes" then
        return "sp_saver_skip_skill_changes"
    end
    if policy.passiveMode == "all_or_nothing" then
        return "sp_saver_passive_all_or_nothing_skipped"
    end
    if policy.passiveMode == "preserve_current" then
        return "sp_saver_passive_preserve_current_skipped"
    end
    return nil
end

local function ResolveExpectedTerminalResult(expectedResult, policy, expectedTargets)
    local hasSkipAction = type(policy) == "table"
        and (policy.activeAction == "skip_skill_changes"
            or policy.passiveAction == "skip_passive_changes")
    if hasSkipAction then
        return HasSkippedTarget(expectedTargets) and "partial_success" or "full_success"
    end
    if expectedResult == "full_success" then
        return "full_success"
    end
    if expectedResult == "passive_partial" or expectedResult == "skill_phase_skip" then
        return "partial_success"
    end
    return "failure"
end

local function HasReason(finalResult, expectedReason)
    if type(finalResult) ~= "table" or type(expectedReason) ~= "string" or expectedReason == "" then
        return false
    end

    if finalResult.reason == expectedReason or finalResult.resultCode == expectedReason then
        return true
    end
    for _, reason in ipairs(type(finalResult.reasons) == "table" and finalResult.reasons or {}) do
        if reason == expectedReason then
            return true
        end
    end

    for _, entry in ipairs(type(finalResult.results) == "table" and finalResult.results or {}) do
        local reasons = type(entry) == "table" and entry.reasons or nil
        for _, reason in ipairs(type(reasons) == "table" and reasons or {}) do
            if reason == expectedReason then
                return true
            end
        end
    end
    return false
end

local function ResolveActualFinalReason(finalResult, expectedReason)
    if HasReason(finalResult, expectedReason) then
        return expectedReason
    end
    if type(finalResult) == "table" and type(finalResult.resultCode) == "string" then
        return finalResult.resultCode
    end
    if type(finalResult) == "table" and type(finalResult.reason) == "string" then
        return finalResult.reason
    end
    local reasons = type(finalResult) == "table" and finalResult.reasons or nil
    if type(reasons) == "table" and reasons[1] ~= nil then
        return reasons[1]
    end
    local results = type(finalResult) == "table" and finalResult.results or nil
    for _, entry in ipairs(type(results) == "table" and results or {}) do
        local entryReasons = type(entry) == "table" and entry.reasons or nil
        if type(entryReasons) == "table" and entryReasons[1] ~= nil then
            return entryReasons[1]
        end
    end
    return nil
end

local function ResolveActualSkippedTargets(finalResult)
    local spSaver = type(finalResult) == "table" and finalResult.spSaver or nil
    return type(spSaver) == "table" and type(spSaver.skippedTargets) == "table"
        and spSaver.skippedTargets
        or {}
end

local function IsTargetSkipped(targets, target)
    return type(targets) == "table" and targets[target] == true
end

local function SkippedTargetsMatch(expectedTargets, actualTargets)
    return IsTargetSkipped(expectedTargets, "normal_skill_changes")
            == IsTargetSkipped(actualTargets, "normal_skill_changes")
        and IsTargetSkipped(expectedTargets, "normal_passive_changes")
            == IsTargetSkipped(actualTargets, "normal_passive_changes")
end

local function BuildSkippedTargetsText(skippedTargets)
    local targets = {}
    if type(skippedTargets) == "table" and skippedTargets.normal_skill_changes == true then
        targets[#targets + 1] = "normal_skill_changes"
    end
    if type(skippedTargets) == "table" and skippedTargets.normal_passive_changes == true then
        targets[#targets + 1] = "normal_passive_changes"
    end
    return #targets > 0 and table.concat(targets, ",") or nil
end

local function ClassifyTerminalResult(expectedResult, finalResult)
    local actualResult = type(finalResult) == "table" and finalResult.finalStatus or "failure"
    local resultCode = type(finalResult) == "table" and finalResult.resultCode or nil
    local failurePhase = type(finalResult) == "table" and finalResult.failurePhase or nil

    if actualResult == "failure" then
        local failurePhases = type(finalResult) == "table" and finalResult.failurePhases or nil
        local downstreamOnly = false
        if type(failurePhases) == "table" and #failurePhases > 0 then
            downstreamOnly = true
            for _, phaseName in ipairs(failurePhases) do
                if DOWNSTREAM_FAILURE_PHASES[phaseName] ~= true then
                    downstreamOnly = false
                    break
                end
            end
        elseif DOWNSTREAM_FAILURE_PHASES[failurePhase] == true then
            downstreamOnly = true
        end

        if downstreamOnly then
            return actualResult, "expected_difference", "downstream_domain_failure"
        end
        return actualResult, "unexplained_difference", "skill_or_unknown_domain_failure:" .. tostring(resultCode)
    end

    if expectedResult == "full_success" then
        if actualResult == "full_success" then
            return actualResult, "match", "none"
        end
        if actualResult == "partial_success" and SKILL_DOMAIN_PARTIAL_RESULT_CODES[resultCode] == true then
            return actualResult, "unexplained_difference", "skill_domain_partial_unexpected:" .. tostring(resultCode)
        end
        return actualResult, "expected_difference", "runtime_or_other_domain_result:" .. tostring(resultCode)
    end

    if expectedResult == "passive_partial" then
        if actualResult == "partial_success"
            and PASSIVE_PARTIAL_RESULT_CODES[resultCode] == true then
            return actualResult, "match", "none"
        end
        if actualResult == "partial_success" then
            return actualResult, "expected_difference", "partial_result_code_changed:" .. tostring(resultCode)
        end
        if actualResult == "full_success" then
            return actualResult, "unexplained_difference", "passive_partial_not_observed_by_runtime"
        end
        return actualResult, "unexplained_difference", "runtime_failed_instead_of_passive_partial:" .. tostring(resultCode)
    end

    if expectedResult == "skill_phase_skip" then
        if actualResult == "partial_success" and resultCode == "skill_phase_skipped_insufficient_points" then
            return actualResult, "match", "none"
        end
        if actualResult == "partial_success" then
            return actualResult, "expected_difference", "partial_result_code_changed:" .. tostring(resultCode)
        end
        return actualResult, "unexplained_difference", "skill_phase_skip_terminal_mismatch:" .. tostring(resultCode)
    end

    return actualResult, "unexplained_difference", "accepted_expected_result_invalid:" .. tostring(expectedResult)
end

local function ClassifyAcceptedRun(accepted, finalResult)
    local policy = type(accepted) == "table" and accepted.spSaver or nil
    local expectedTargets = ResolveExpectedSkippedTargets(finalResult)
    local actualTargets = ResolveActualSkippedTargets(finalResult)
    local expectedReason = ResolveExpectedSpSaverReason(policy, expectedTargets)
    local hasSkipAction = type(policy) == "table"
        and (policy.activeAction == "skip_skill_changes"
            or policy.passiveAction == "skip_passive_changes")
    if not hasSkipAction then
        if HasSkippedTarget(actualTargets) then
            local actualResult = type(finalResult) == "table" and finalResult.finalStatus or "failure"
            return actualResult, "unexplained_difference", "sp_saver_unexpected_runtime_skip"
        end
        return ClassifyTerminalResult(accepted.expectedResult, finalResult)
    end

    local actualResult = type(finalResult) == "table" and finalResult.finalStatus or "failure"
    if actualResult == "failure" then
        return ClassifyTerminalResult(accepted.expectedResult, finalResult)
    end

    if not SkippedTargetsMatch(expectedTargets, actualTargets) then
        return actualResult, "unexplained_difference", "sp_saver_expected_actual_target_mismatch"
    end

    if not HasSkippedTarget(expectedTargets) then
        return ClassifyTerminalResult("full_success", finalResult)
    end
    if actualResult == "partial_success" and HasReason(finalResult, expectedReason) then
        return actualResult, "match", "none"
    end

    return actualResult, "unexplained_difference", "sp_saver_runtime_terminal_mismatch"
end

function SkillPointRunAudit:RecordAcceptedRun(metadata, precheck)
    metadata = type(metadata) == "table" and metadata or {}
    local diagnostics = type(precheck) == "table" and precheck.diagnostics or nil
    local skillPointPlan = type(diagnostics) == "table" and diagnostics.skillPointPlan or nil

    if metadata.runId == nil or type(skillPointPlan) ~= "table" then
        return false
    end

    acceptedPlansByRunId[metadata.runId] = {
        runId = metadata.runId,
        buildId = metadata.buildId,
        expectedResult = skillPointPlan.expectedResult,
        spSaver = CloneSpSaverPolicy(type(precheck) == "table" and precheck.spSaver or nil),
    }
    return true
end

function SkillPointRunAudit:RecordTerminalSummary(runId, buildId, finalResult)
    local accepted = acceptedPlansByRunId[runId]
    acceptedPlansByRunId[runId] = nil
    if type(accepted) ~= "table" then
        return nil
    end

    local resolvedBuildId = buildId or accepted.buildId
    local expectedResult = accepted.expectedResult
    local spSaver = accepted.spSaver
    local expectedSkippedTargets = ResolveExpectedSkippedTargets(finalResult)
    local expectedSpSaverReason = ResolveExpectedSpSaverReason(spSaver, expectedSkippedTargets)
    local expectedTerminalResult = ResolveExpectedTerminalResult(expectedResult, spSaver, expectedSkippedTargets)
    local actualResult, comparison, mismatchReason = ClassifyAcceptedRun(accepted, finalResult)
    local actualFinalReason = ResolveActualFinalReason(finalResult, expectedSpSaverReason)
    local actualSkippedTargets = ResolveActualSkippedTargets(finalResult)
    local expectedSkippedTargetsText = BuildSkippedTargetsText(expectedSkippedTargets)
    local actualSkippedTargetsText = BuildSkippedTargetsText(actualSkippedTargets)
    local failurePhase = type(finalResult) == "table" and finalResult.failurePhase or nil
    local parts = {
        "SkillPointTerminalSummary:",
        "runId=" .. StringifyLogValue(accepted.runId),
        "buildId=" .. StringifyLogValue(resolvedBuildId),
        "expectedResult=" .. StringifyLogValue(expectedResult),
        "expectedTerminalResult=" .. StringifyLogValue(expectedTerminalResult),
        "actualResult=" .. StringifyLogValue(actualResult),
        "spSaverSource=" .. StringifyLogValue(type(spSaver) == "table" and spSaver.source or nil),
        "activeMode=" .. StringifyLogValue(type(spSaver) == "table" and spSaver.activeMode or nil),
        "passiveMode=" .. StringifyLogValue(type(spSaver) == "table" and spSaver.passiveMode or nil),
        "expectedActiveAction=" .. StringifyLogValue(type(spSaver) == "table" and spSaver.activeAction or nil),
        "expectedPassiveAction=" .. StringifyLogValue(type(spSaver) == "table" and spSaver.passiveAction or nil),
        "expectedSkippedTargets=" .. StringifyLogValue(expectedSkippedTargetsText),
        "actualSkippedTargets=" .. StringifyLogValue(actualSkippedTargetsText),
        "expectedReason=" .. StringifyLogValue(expectedSpSaverReason),
        "actualFinalReason=" .. StringifyLogValue(actualFinalReason),
        "failurePhase=" .. StringifyLogValue(failurePhase),
        "comparison=" .. StringifyLogValue(comparison),
        "mismatchReason=" .. StringifyLogValue(mismatchReason),
    }
    if comparison == "unexplained_difference" then
        EmitAuditLog(table.concat(parts, " "))
    end
    return {
        runId = accepted.runId,
        buildId = resolvedBuildId,
        expectedResult = expectedResult,
        expectedTerminalResult = expectedTerminalResult,
        actualResult = actualResult,
        spSaverSource = type(spSaver) == "table" and spSaver.source or nil,
        activeMode = type(spSaver) == "table" and spSaver.activeMode or nil,
        passiveMode = type(spSaver) == "table" and spSaver.passiveMode or nil,
        expectedActiveAction = type(spSaver) == "table" and spSaver.activeAction or nil,
        expectedPassiveAction = type(spSaver) == "table" and spSaver.passiveAction or nil,
        expectedSkippedTargets = expectedSkippedTargets,
        actualSkippedTargets = actualSkippedTargets,
        expectedReason = expectedSpSaverReason,
        actualFinalReason = actualFinalReason,
        failurePhase = failurePhase,
        comparison = comparison,
        mismatchReason = mismatchReason,
    }
end
