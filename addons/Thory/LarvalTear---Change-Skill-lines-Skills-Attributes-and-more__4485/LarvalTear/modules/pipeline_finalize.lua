local Addon = LarvalTearMod
local Log = Addon.Common.Log
local LTM_PIPELINE_FINALIZE = Addon.Modules.PipelineFinalize
local LTM_APPLY_START_STATE = Addon.Modules.ApplyStartState
local LTM_PIPELINE_CONTEXT = Addon.Modules.PipelineContext

local FINALIZE_POLL_MS = 250
local FINALIZE_MAX_ATTEMPTS = 12
local FINALIZE_FAILED = "PIPELINE_E_FINALIZE_FAILED"

local function IsShowingScene(sceneName)
    return SCENE_MANAGER:IsShowing(sceneName)
end

local function GetInteractionTypeSafe()
    if type(GetInteractionType) == "function" then
        return GetInteractionType()
    end

    return nil
end

local function BuildFinalizeSnapshot()
    return {
        statsShowing = IsShowingScene("stats"),
        gamepadStatsShowing = IsShowingScene("gamepad_stats_root"),
        skillsShowing = IsShowingScene("skills"),
        gamepadSkillsShowing = IsShowingScene("gamepad_skills_root"),
        interaction = GetInteractionTypeSafe(),
    }
end

local function IsFinalizeSuccess(snapshot)
    return snapshot.statsShowing == false
        and snapshot.gamepadStatsShowing == false
        and snapshot.skillsShowing == false
        and snapshot.gamepadSkillsShowing == false
        and (snapshot.interaction == nil or snapshot.interaction == 0)
end

local function LogFinalizeSuccess(branch, context)
    Log.Debug(
        "Finalize success branch="
            .. tostring(branch)
            .. " attempt="
            .. tostring(context and context.attemptIndex)
    )
end

local function LogFinalizeFailure(branch, context, reason)
    Log.Debug(
        "Finalize failure branch="
            .. tostring(branch)
            .. " error="
            .. FINALIZE_FAILED
            .. " attempt="
            .. tostring(context and context.attemptIndex)
            .. " reason="
            .. tostring(reason or FINALIZE_FAILED)
    )
end

local function LogIntentionalSkillSkipRejected(reason, branch)
    Log.Debug(
        "Pipeline intentional skill skip rejected reason="
            .. tostring(reason or "unknown")
            .. " branch="
            .. tostring(branch or "unknown")
    )
end

local function LogPartialSuccessRejected(reason, branch)
    Log.Debug(
        "Pipeline partial success rejected reason="
            .. tostring(reason or "unknown")
            .. " branch="
            .. tostring(branch or "unknown")
    )
end

local function EvaluateSkillsPartialSuccess(pipelineContext)
    local result = type(LTM_PIPELINE_CONTEXT) == "table"
        and type(LTM_PIPELINE_CONTEXT.GetPhaseResult) == "function"
        and LTM_PIPELINE_CONTEXT:GetPhaseResult(pipelineContext, "SkillRespec")
        or nil
    if type(result) ~= "table" or result.ok ~= true then
        return nil, "skills_result_unavailable"
    end

    local details = type(result.details) == "table" and result.details or nil
    if type(details) ~= "table" then
        return nil, "skills_result_details_missing"
    end

    local restoreSummary = details.restoreSummary
    local reasonCounts = type(restoreSummary) == "table" and restoreSummary.reasonCounts or nil
    local skillNotPurchased = type(reasonCounts) == "table" and (reasonCounts.skill_not_purchased or 0) or 0
    local alreadyMatches = type(reasonCounts) == "table" and (reasonCounts.already_matches or 0) or 0
    local hasOnlyExpectedReasons = type(reasonCounts) == "table"
    if hasOnlyExpectedReasons then
        for reason in pairs(reasonCounts) do
            if reason ~= "already_matches" and reason ~= "skill_not_purchased" then
                hasOnlyExpectedReasons = false
                break
            end
        end
    end

    if details.route ~= "route_b" then
        return nil, "route_not_route_b"
    end
    if details.degraded ~= true then
        return nil, "degraded_flag_missing"
    end
    if details.resultCode ~= "route_b_degraded_insufficient_points" then
        return nil, "result_code_not_partial_candidate"
    end
    if details.subclassVerified ~= true then
        return nil, "subclass_not_verified"
    end
    if details.commitPerformed == true then
        return nil, "commit_performed"
    end
    if (details.unexpectedPurchaseCount or 0) > 0 then
        return nil, "unexpected_purchase_remaining"
    end
    if type(details.readiness) == "table" and ((details.readiness.morphCount or 0) > 0 or (details.readiness.unresolvedCount or 0) > 0) then
        return nil, "morph_or_unresolved_remaining"
    end
    if type(restoreSummary) ~= "table" then
        return nil, "restore_summary_missing"
    end
    if hasOnlyExpectedReasons ~= true then
        return nil, "restore_reason_unexpected"
    end
    if skillNotPurchased <= 0 then
        return nil, "skill_not_purchased_absent"
    end
    if (restoreSummary.errors or 0) ~= skillNotPurchased then
        return nil, "restore_error_mismatch"
    end
    if (details.expectedMissingPurchaseCount or 0) ~= skillNotPurchased then
        return nil, "expected_missing_mismatch"
    end

    return {
        sourcePhase = "Skills",
        resultCode = details.resultCode,
        reasons = details.degradeReasons or { "insufficient_skill_points" },
        residualSummary = {
            skillNotPurchased = skillNotPurchased,
            alreadyMatches = alreadyMatches,
            expectedMissingPurchaseCount = details.expectedMissingPurchaseCount or 0,
        },
    }
end

local function AppendUniqueReason(reasons, value)
    if type(value) ~= "string" or value == "" then
        return
    end

    for _, existing in ipairs(reasons) do
        if existing == value then
            return
        end
    end
    reasons[#reasons + 1] = value
end

local function CollectActionBarRestoreResiduals(details, reasons, residual)
    local restoreResult = type(details) == "table" and details.actionBarRestoreResult or nil
    local restoreSummary = type(restoreResult) == "table" and restoreResult.summary or nil
    residual = type(residual) == "table" and residual or {
        errorCount = 0,
        slots = {},
        _slotReasonSet = {},
    }
    for _, slotResult in ipairs(type(restoreResult) == "table" and restoreResult.results or {}) do
        if type(slotResult) == "table" and slotResult.status == "error" then
            local reason = slotResult.reason or "action_bar_restore_failed"
            local slotReasonKey = table.concat({
                tostring(slotResult.hotbarCategory),
                tostring(slotResult.slotIndex),
                tostring(slotResult.progressionId),
                tostring(reason),
            }, ":")
            if residual._slotReasonSet[slotReasonKey] ~= true then
                residual._slotReasonSet[slotReasonKey] = true
                residual.errorCount = residual.errorCount + 1
                residual.slots[#residual.slots + 1] = {
                    hotbarCategory = slotResult.hotbarCategory,
                    slotIndex = slotResult.slotIndex,
                    progressionId = slotResult.progressionId,
                    reason = reason,
                }
            end
            AppendUniqueReason(reasons, reason)
        end
    end
    if type(details) == "table" and type(details.actionBarRestoreError) == "string" then
        local errorKey = "restore:" .. details.actionBarRestoreError
        if residual._slotReasonSet[errorKey] ~= true then
            residual._slotReasonSet[errorKey] = true
            residual.errorCount = residual.errorCount + 1
        end
        AppendUniqueReason(reasons, details.actionBarRestoreError)
    end

    if residual.errorCount <= 0 then
        return nil
    end
    residual.summary = restoreSummary or residual.summary
    residual.error = type(details) == "table" and details.actionBarRestoreError or residual.error
    return residual
end

local function EvaluateIntentionalSkillSkipSuccess(pipelineContext)
    local result = type(LTM_PIPELINE_CONTEXT) == "table"
        and type(LTM_PIPELINE_CONTEXT.GetPhaseResult) == "function"
        and LTM_PIPELINE_CONTEXT:GetPhaseResult(pipelineContext, "Skills")
        or nil
    local details = type(result) == "table" and type(result.details) == "table" and result.details or nil
    if type(result) ~= "table" or result.ok ~= true or type(details) ~= "table" then
        return nil, "skill_result_unavailable"
    end

    if details.status ~= "skipped" then
        return nil, "skill_status_not_skipped"
    end
    if details.reason ~= "insufficient_points_preflight"
        and details.reason ~= "sp_saver_skip_skill_changes" then
        return nil, "skill_skip_reason_not_supported"
    end
    if details.intentional ~= true then
        return nil, "skill_skip_not_intentional"
    end

    local spSaverSkip = details.reason == "sp_saver_skip_skill_changes"
    local reasons = {}
    local actualSkillSkip = false
    if spSaverSkip
        and type(LTM_PIPELINE_CONTEXT) == "table"
        and type(LTM_PIPELINE_CONTEXT.GetSpSaverRuntimeSummary) == "function" then
        local runtimeSummary = LTM_PIPELINE_CONTEXT:GetSpSaverRuntimeSummary(pipelineContext)
        actualSkillSkip = type(runtimeSummary) == "table"
            and type(runtimeSummary.skippedTargets) == "table"
            and runtimeSummary.skippedTargets.normal_skill_changes == true
    end
    if spSaverSkip and actualSkillSkip then
        AppendUniqueReason(reasons, details.reason)
    elseif not spSaverSkip then
        AppendUniqueReason(reasons, "insufficient_skill_points")
    end
    local actionBarResidual = CollectActionBarRestoreResiduals(details, reasons)
    if type(actionBarResidual) == "table" then
        actionBarResidual._slotReasonSet = nil
    end
    if spSaverSkip and not actualSkillSkip and actionBarResidual == nil then
        return nil, "sp_saver_no_actual_skip_or_restore_residual"
    end

    local resultCode = spSaverSkip and reasons[1] or "skill_phase_skipped_insufficient_points"
    return {
        sourcePhase = "Skills",
        reason = details.reason,
        resultCode = resultCode,
        reasons = reasons,
        residualSummary = {
            skillPhaseSkipped = true,
            spSaver = spSaverSkip and actualSkillSkip or false,
            actionBarRestore = actionBarResidual,
        },
    }
end

local function BuildSpSaverPartialSuccess(pipelineContext)
    local runtimeSummary = type(LTM_PIPELINE_CONTEXT) == "table"
        and type(LTM_PIPELINE_CONTEXT.GetSpSaverRuntimeSummary) == "function"
        and LTM_PIPELINE_CONTEXT:GetSpSaverRuntimeSummary(pipelineContext)
        or nil
    local skippedTargets = type(runtimeSummary) == "table" and runtimeSummary.skippedTargets or nil
    if type(skippedTargets) ~= "table"
        or (skippedTargets.normal_skill_changes ~= true
            and skippedTargets.normal_passive_changes ~= true) then
        return nil
    end

    local reasons = type(runtimeSummary.reasons) == "table" and runtimeSummary.reasons or {}
    local primaryReason = reasons[1]
    if type(primaryReason) ~= "string" or primaryReason == "" then
        return nil
    end

    return {
        sourcePhase = skippedTargets.normal_skill_changes == true and "Skills" or "PassiveSkills",
        resultCode = primaryReason,
        reasons = reasons,
        residualSummary = {
            spSaver = runtimeSummary,
        },
    }
end

local function StoreSpSaverPartial(pipelineContext)
    local partialResult = BuildSpSaverPartialSuccess(pipelineContext)
    if type(partialResult) ~= "table" then
        return nil
    end

    return LTM_PIPELINE_CONTEXT:RecordDomainResult(pipelineContext, partialResult)
end

local function StoreIntentionalSkillSkipPartial(pipelineContext)
    local skipSuccess = EvaluateIntentionalSkillSkipSuccess(pipelineContext)
    if type(skipSuccess) ~= "table" or type(pipelineContext) ~= "table" then
        return nil
    end

    LTM_PIPELINE_CONTEXT:RecordDomainResult(pipelineContext, skipSuccess)
    Log.Debug("Pipeline intentional skill skip accepted reason=" .. tostring(skipSuccess.reason))
    return skipSuccess
end

local function StoreSkillsPartial(pipelineContext)
    local partialResult = EvaluateSkillsPartialSuccess(pipelineContext)
    if type(partialResult) ~= "table" then
        return nil
    end

    return LTM_PIPELINE_CONTEXT:RecordDomainResult(pipelineContext, partialResult)
end

local function StoreActionBarRestorePartial(pipelineContext)
    local skillRespecResult = type(LTM_PIPELINE_CONTEXT) == "table"
        and type(LTM_PIPELINE_CONTEXT.GetPhaseResult) == "function"
        and LTM_PIPELINE_CONTEXT:GetPhaseResult(pipelineContext, "SkillRespec")
        or nil
    local skillRespecDetails = type(skillRespecResult) == "table"
        and type(skillRespecResult.details) == "table"
        and skillRespecResult.details
        or nil
    local skillsResult = type(LTM_PIPELINE_CONTEXT) == "table"
        and type(LTM_PIPELINE_CONTEXT.GetPhaseResult) == "function"
        and LTM_PIPELINE_CONTEXT:GetPhaseResult(pipelineContext, "Skills")
        or nil
    local skillsDetails = type(skillsResult) == "table"
        and type(skillsResult.details) == "table"
        and skillsResult.details
        or nil

    local candidates = {}
    if type(skillRespecResult) == "table"
        and skillRespecResult.ok == true
        and type(skillRespecDetails) == "table"
        and skillRespecDetails.route == "route_b" then
        candidates[#candidates + 1] = {
            source = "skill_respec",
            details = skillRespecDetails,
        }
    end
    if type(skillsResult) == "table"
        and skillsResult.ok == true
        and type(skillsDetails) == "table"
        and skillsDetails.status == "restore_only" then
        candidates[#candidates + 1] = {
            source = "skills_restore_only",
            details = skillsDetails,
        }
    end

    local reasons = {}
    local residual = nil
    local sources = {}
    for _, candidate in ipairs(candidates) do
        local updated = CollectActionBarRestoreResiduals(candidate.details, reasons, residual)
        if updated ~= nil then
            residual = updated
            sources[#sources + 1] = candidate.source
        end
    end
    if residual == nil then
        return nil
    end
    residual._slotReasonSet = nil
    residual.mode = "post_route_b"
    residual.intentionalSkillSkip = false
    residual.sources = sources
    return LTM_PIPELINE_CONTEXT:RecordDomainResult(pipelineContext, {
        domain = "ActionBarRestore",
        sourcePhase = "Skills",
        severity = "partial",
        resultCode = "action_bar_restore_partial",
        reasons = reasons,
        residualSummary = residual,
    })
end

local function StoreTerminalPartialResults(pipelineContext)
    StoreIntentionalSkillSkipPartial(pipelineContext)
    StoreSkillsPartial(pipelineContext)
    StoreSpSaverPartial(pipelineContext)
    StoreActionBarRestorePartial(pipelineContext)
end

function LTM_PIPELINE_FINALIZE:NotifyPipelineContinuation(context, success, err)
    local continuation = context and context.pipelineContinuation or nil
    if type(continuation) == "function" and not context.pipelineContinuationNotified then
        context.pipelineContinuationNotified = true
        continuation(success, err)
    end
end

function LTM_PIPELINE_FINALIZE:Run(config)
    local initial = BuildFinalizeSnapshot()

    if IsFinalizeSuccess(initial) then
        StoreTerminalPartialResults(type(config) == "table" and config._pipelineContext or nil)
        LogFinalizeSuccess("already_clean")
        return true
    end

    SCENE_MANAGER:ShowBaseScene()

    if type(zo_callLater) ~= "function" then
        local current = BuildFinalizeSnapshot()
        if IsFinalizeSuccess(current) then
            StoreTerminalPartialResults(type(config) == "table" and config._pipelineContext or nil)
            LogFinalizeSuccess("base_scene_clean")
            return true
        end

        LogFinalizeFailure("base_scene_no_scheduler", nil, "zo_callLater_unavailable")
        return false, FINALIZE_FAILED
    end

    local context = {
        attemptIndex = 0,
        pipelineContinuation = config and config._pipelineContinuation or nil,
        pipelineContext = config and config._pipelineContext or nil,
        finished = false,
    }

    local function Poll()
        if context.finished then
            return
        end

        context.attemptIndex = context.attemptIndex + 1
        local snapshot = BuildFinalizeSnapshot()

        if IsFinalizeSuccess(snapshot) then
            context.finished = true
            StoreTerminalPartialResults(context.pipelineContext)
            LogFinalizeSuccess("poll_clean", context)
            LTM_PIPELINE_FINALIZE:NotifyPipelineContinuation(context, true, nil)
            return
        end

        if context.attemptIndex >= FINALIZE_MAX_ATTEMPTS then
            local skipSuccess, skipRejectReason = EvaluateIntentionalSkillSkipSuccess(context.pipelineContext)
            if type(skipSuccess) == "table"
                and type(LTM_APPLY_START_STATE) == "table"
                and type(LTM_APPLY_START_STATE.NormalizeToHudBaseline) == "function" then
                local normalizeStarted, normalizeErr = LTM_APPLY_START_STATE:NormalizeToHudBaseline(function(ok, cleanReason, cleanSnapshot)
                    if context.finished then
                        return
                    end

                    if ok == true and IsFinalizeSuccess(cleanSnapshot or {}) then
                        context.finished = true
                        StoreTerminalPartialResults(context.pipelineContext)
                        LogFinalizeSuccess("intentional_skill_skip_clean_exit", context)
                        LTM_PIPELINE_FINALIZE:NotifyPipelineContinuation(context, true, nil)
                        return
                    end

                    context.finished = true
                    LogIntentionalSkillSkipRejected(cleanReason or "clean_exit_failed", "clean_exit_callback")
                    LogFinalizeFailure("intentional_skill_skip_clean_exit_failed", context, cleanReason or "clean_exit_failed")
                    LTM_PIPELINE_FINALIZE:NotifyPipelineContinuation(context, false, FINALIZE_FAILED)
                end)

                if normalizeStarted then
                    return
                end

                LogIntentionalSkillSkipRejected(normalizeErr or "normalize_start_failed", "normalize_start")
            elseif skipRejectReason ~= nil then
                LogIntentionalSkillSkipRejected(skipRejectReason, "candidate")
            end

            local partialResult, rejectReason = EvaluateSkillsPartialSuccess(context.pipelineContext)
            if type(partialResult) == "table"
                and type(LTM_APPLY_START_STATE) == "table"
                and type(LTM_APPLY_START_STATE.NormalizeToHudBaseline) == "function" then
                Log.Debug(
                    "Pipeline partial success reason="
                        .. tostring((partialResult.reasons and partialResult.reasons[1]) or "")
                        .. " residualSummary=skillNotPurchased="
                        .. tostring(type(partialResult.residualSummary) == "table" and partialResult.residualSummary.skillNotPurchased or 0)
                        .. ",expectedMissingPurchaseCount="
                        .. tostring(type(partialResult.residualSummary) == "table" and partialResult.residualSummary.expectedMissingPurchaseCount or 0)
                )
                local normalizeStarted, normalizeErr = LTM_APPLY_START_STATE:NormalizeToHudBaseline(function(ok, cleanReason, cleanSnapshot)
                    if context.finished then
                        return
                    end

                    Log.Debug(
                        "Pipeline partial success discard applied="
                            .. tostring(ok == true)
                            .. " reason="
                            .. tostring(cleanReason)
                            .. " hasPendingChanges="
                            .. tostring(type(cleanSnapshot) == "table" and cleanSnapshot.hasPendingChanges)
                            .. " interaction="
                            .. tostring(type(cleanSnapshot) == "table" and cleanSnapshot.interaction)
                            .. " skillsShowing="
                            .. tostring(type(cleanSnapshot) == "table" and cleanSnapshot.skillsShowing)
                            .. " gamepadSkillsShowing="
                            .. tostring(type(cleanSnapshot) == "table" and cleanSnapshot.gamepadSkillsShowing)
                            .. " statsShowing="
                            .. tostring(type(cleanSnapshot) == "table" and cleanSnapshot.statsShowing)
                            .. " gamepadStatsShowing="
                            .. tostring(type(cleanSnapshot) == "table" and cleanSnapshot.gamepadStatsShowing)
                    )

                    if ok == true and IsFinalizeSuccess(cleanSnapshot or {}) then
                        context.finished = true
                        if type(context.pipelineContext) == "table" then
                            LTM_PIPELINE_CONTEXT:RecordDomainResult(context.pipelineContext, partialResult)
                        end
                        StoreSpSaverPartial(context.pipelineContext)
                        Log.Debug(
                            "Pipeline partial success accepted phase="
                                .. tostring(partialResult.sourcePhase)
                                .. " resultCode="
                                .. tostring(partialResult.resultCode)
                                .. " skillNotPurchased="
                                .. tostring(type(partialResult.residualSummary) == "table" and partialResult.residualSummary.skillNotPurchased or 0)
                                .. " expectedMissingPurchaseCount="
                                .. tostring(type(partialResult.residualSummary) == "table" and partialResult.residualSummary.expectedMissingPurchaseCount or 0)
                        )
                        LogFinalizeSuccess("partial_success_clean_exit", context)
                        LTM_PIPELINE_FINALIZE:NotifyPipelineContinuation(context, true, nil)
                        return
                    end

                    context.finished = true
                    LogPartialSuccessRejected(cleanReason or "clean_exit_failed", "clean_exit_callback")
                    LogFinalizeFailure("partial_success_clean_exit_failed", context, cleanReason or "clean_exit_failed")
                    LTM_PIPELINE_FINALIZE:NotifyPipelineContinuation(context, false, FINALIZE_FAILED)
                end)

                if normalizeStarted then
                    return
                end

                LogPartialSuccessRejected(normalizeErr or "normalize_start_failed", "normalize_start")
            else
                LogPartialSuccessRejected(rejectReason or "partial_candidate_missing", "candidate")
            end

            context.finished = true
            LogFinalizeFailure("poll_exhausted", context, "finalize_timeout")
            LTM_PIPELINE_FINALIZE:NotifyPipelineContinuation(context, false, FINALIZE_FAILED)
            return
        end

        zo_callLater(Poll, FINALIZE_POLL_MS)
    end

    Log.Debug(
        "Finalize deferred branch=poll_wait"
            .. " pollMs="
            .. tostring(FINALIZE_POLL_MS)
            .. " maxAttempts="
            .. tostring(FINALIZE_MAX_ATTEMPTS)
    )
    zo_callLater(Poll, FINALIZE_POLL_MS)
    return true, "deferred"
end
