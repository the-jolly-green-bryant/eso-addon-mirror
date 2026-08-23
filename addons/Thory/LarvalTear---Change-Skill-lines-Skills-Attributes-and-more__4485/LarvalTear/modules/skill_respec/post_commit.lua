local Addon = LarvalTearMod
local LTM = Addon
local M = Addon.Modules.SkillRespecPostCommit
local SHARED_UTIL = Addon.Common.Util
local logging = Addon.Modules.SkillRespecLogging
local LTM_SKILL_RESPEC_APPLY = Addon.Modules.SkillRespecApply
local LTM_SKILL_RESPEC_COMPLETION = Addon.Modules.SkillRespecCompletion
local LTM_ACTIVE_SKILL_RESTORE = Addon.Modules.ActiveSkillRestore
local LTM_PASSIVE_SNAPSHOT_APPLY = Addon.Modules.PassiveSnapshotApply
local LTM_PIPELINE_CONTEXT = Addon.Modules.PipelineContext
local CONSTANTS = Addon.Modules.SkillRespecConstants

local ROUTE_B_VERIFY_KICKOFF_DELAY_MS = CONSTANTS.ROUTE_B_VERIFY_KICKOFF_DELAY_MS
local ROUTE_B_COMMIT_OBSERVE_POLL_MS = CONSTANTS.ROUTE_B_COMMIT_OBSERVE_POLL_MS
local ROUTE_B_COMMIT_OBSERVE_MAX_ATTEMPTS = CONSTANTS.ROUTE_B_COMMIT_OBSERVE_MAX_ATTEMPTS
local ROUTE_B_COMMIT_RETRY_DELAY_MS = CONSTANTS.ROUTE_B_COMMIT_RETRY_DELAY_MS
local ROUTE_B_POST_COMMIT_VERIFY_INITIAL_DELAY_MS = CONSTANTS.ROUTE_B_POST_COMMIT_VERIFY_INITIAL_DELAY_MS
local ROUTE_B_POST_COMMIT_VERIFY_RETRY_MS = CONSTANTS.ROUTE_B_POST_COMMIT_VERIFY_RETRY_MS
local ROUTE_B_POST_COMMIT_VERIFY_MAX_ATTEMPTS = CONSTANTS.ROUTE_B_POST_COMMIT_VERIFY_MAX_ATTEMPTS

local function ShouldLogPostCommitVerifyAttempt(attemptIndex)
    attemptIndex = tonumber(attemptIndex)
    if attemptIndex == nil then
        return false
    end

    local midpoint = math.ceil(ROUTE_B_POST_COMMIT_VERIFY_MAX_ATTEMPTS / 2)
    return attemptIndex == 1
        or attemptIndex == midpoint
        or attemptIndex >= ROUTE_B_POST_COMMIT_VERIFY_MAX_ATTEMPTS
end

function M:SchedulePostCommitWatchdog(apply, context)
    if type(context) ~= "table" or context.postCommitWatchdogScheduled == true then
        return
    end

    context.postCommitWatchdogScheduled = true
    zo_callLater(function()
        apply:RunRouteBCallback(context, "post_commit_watchdog", function()
            apply:KickOffRouteBPostCommitVerify(context, "post_commit_watchdog")
        end)
    end, ROUTE_B_VERIFY_KICKOFF_DELAY_MS)
end

function M:MarkCommitAccepted(apply, context, source)
    if type(context) ~= "table" or apply.pendingContext ~= context or apply:IsRouteBContextInactive(context) then
        return false
    end

    if context.commitAccepted == true then
        return false
    end

    context.commitAccepted = true
    context.commitAt = SHARED_UTIL:GetFrameTimeMillisecondsSafe()
    context.commitSent = true
    context.commitAcceptanceSource = source
    apply:MarkSkillRespecCommitExecuted(context)
    logging.Log(
        "Route B commit accepted",
        "retryCount=" .. tostring(apply:GetRouteBCommitRetryCount(context)),
        "source=" .. tostring(source)
    )
    self:SchedulePostCommitWatchdog(apply, context)
    return true
end

function M:ScheduleCommitRetry(apply, context, reason, details)
    details = type(details) == "table" and details or {}

    if not apply:CanRetryRouteBCommit(context) then
        local retries = apply:GetRouteBCommitRetryCount(context)
        logging.Log("Route B commit retry timeout retries=" .. tostring(retries))
        details.retryCount = retries
        details.retryReason = reason
        apply:FinalizeRouteBFailure(context, "route_b_commit_retry_exhausted", details)
        return
    end

    context.commitRetryScheduled = true
    context.commitRetryCount = apply:GetRouteBCommitRetryCount(context) + 1
    LTM:NotifyWaitStarted(context, "skill_cooldown", ROUTE_B_COMMIT_RETRY_DELAY_MS / 1000)
    logging.Log(
        "Route B commit retry scheduled",
        "delayMs=" .. tostring(ROUTE_B_COMMIT_RETRY_DELAY_MS),
        "retryCount=" .. tostring(context.commitRetryCount),
        "reason=" .. tostring(reason)
    )

    zo_callLater(function()
        if LTM_SKILL_RESPEC_APPLY.pendingContext ~= context or LTM_SKILL_RESPEC_APPLY:IsRouteBContextInactive(context) then
            return
        end

        context.commitRetryScheduled = false
        if context.commitAccepted == true or context.completionArmed == true then
            return
        end

        apply:ApplyRouteBChangesAndMaybeWait(context)
    end, ROUTE_B_COMMIT_RETRY_DELAY_MS)
end

function M:GetObservedAcceptanceSource(apply, context)
    if type(context) ~= "table" then
        return nil
    end

    if context.resultReceived == true and context.resultCode == RESPEC_RESULT_SUCCESS then
        return "result_state"
    end

    if context.castStarted == true then
        return "cast_event"
    end

    local castRemainingMs = LTM_SKILL_RESPEC_COMPLETION:GetSkillRespecCastTimeRemainingMsSafe()
    local castDialogShowing = LTM_SKILL_RESPEC_COMPLETION:IsSkillRespecCastDialogShowing()

    if castDialogShowing then
        return "cast_dialog"
    end

    if castRemainingMs ~= nil and castRemainingMs > 0 then
        return "cast_timer"
    end

    return nil
end

function M:RunCommitObserveWait(apply, context, generation)
    if type(context) ~= "table" or apply.pendingContext ~= context or apply:IsRouteBContextInactive(context) then
        return
    end

    if generation ~= nil and context.commitAttemptGeneration ~= generation then
        return
    end

    if context.commitAccepted == true or context.commitRetryScheduled == true then
        return
    end

    local acceptanceSource = self:GetObservedAcceptanceSource(apply, context)
    if acceptanceSource ~= nil then
        self:MarkCommitAccepted(apply, context, acceptanceSource)
        return
    end

    context.commitObserveAttemptIndex = (context.commitObserveAttemptIndex or 0) + 1
    if context.commitObserveAttemptIndex >= ROUTE_B_COMMIT_OBSERVE_MAX_ATTEMPTS then
        self:ScheduleCommitRetry(apply, context, "acceptance_timeout", {
            observeAttempts = context.commitObserveAttemptIndex,
            timeoutMs = ROUTE_B_COMMIT_OBSERVE_POLL_MS * ROUTE_B_COMMIT_OBSERVE_MAX_ATTEMPTS,
            result = context.resultCode,
        })
        return
    end

    zo_callLater(function()
        M:RunCommitObserveWait(apply, context, generation)
    end, ROUTE_B_COMMIT_OBSERVE_POLL_MS)
end

function M:VerifyPostCommitState(apply, context)
    local plan = apply:BuildRouteBSkillTargetPlan(context.routeBConfig)
    local reductionVerify = LTM_ACTIVE_SKILL_RESTORE:VerifyCommittedReductions(
        context.activeRestorePlan
    )

    local readiness = apply:GetRouteBCommitReadiness(plan, context)
    readiness.reductionMismatchCount = reductionVerify.mismatchCount
    readiness.reductionVerify = reductionVerify
    readiness.ok = readiness.ok == true and reductionVerify.ok == true
    if readiness.ok == true
        and context.commitPerformed ~= true
        and type(apply.ShouldBypassSubclassVerify) == "function"
        and apply:ShouldBypassSubclassVerify(context) ~= true then
        local subclassSnapshot, subclassErr = apply:CollectRouteBVerifySnapshot(context)
        readiness.subclassVerify = subclassSnapshot
        readiness.subclassVerifyError = subclassErr
        readiness.subclassVerified = type(subclassSnapshot) == "table"
            and subclassSnapshot.ok == true
            and subclassSnapshot.matched == true
        readiness.ok = readiness.subclassVerified == true
    end
    return readiness.ok, plan, readiness
end

function M:VerifyPassiveExactPostCommit(context)
    local passiveSummary = type(context) == "table" and context.passiveSummary or nil
    if type(passiveSummary) ~= "table" or passiveSummary.mode ~= "exact_restore" then
        return nil
    end

    local build = type(context.pipelineContext) == "table" and context.pipelineContext.targetBuild or nil
    local verify = LTM_PASSIVE_SNAPSHOT_APPLY:VerifyPostCommitLiveRanks(build, passiveSummary, {
        source = "route_b_passive_exact_post_commit_verify",
        resetResiduals = true,
    })
    if type(context.pipelineContext) == "table"
        and type(passiveSummary.partialSuccessResult) == "table" then
        LTM_PIPELINE_CONTEXT:RecordDomainResult(context.pipelineContext, passiveSummary.partialSuccessResult)
    end
    return verify
end

function M:IsPostCommitVerifyRetryInactive(_apply, context)
    return context == nil or context.finished
end

function M:RunPostCommitVerifyRetry(apply, context)
    if apply.pendingContext ~= context or self:IsPostCommitVerifyRetryInactive(apply, context) then
        return
    end

    context.postCommitVerifyRetryAttemptIndex = (context.postCommitVerifyRetryAttemptIndex or 0) + 1
    local attemptIndex = context.postCommitVerifyRetryAttemptIndex
    local verifyOk, verifyPlan, readiness = self:VerifyPostCommitState(apply, context)
    local diagnostics = type(verifyPlan) == "table" and verifyPlan.diagnostics or {}

    local maxAttempts = context.commitPerformed == true
        and ROUTE_B_POST_COMMIT_VERIFY_MAX_ATTEMPTS
        or 1

    if not verifyOk
        and attemptIndex < maxAttempts
        and ShouldLogPostCommitVerifyAttempt(attemptIndex) then
        logging.Log(
            "Route B post-commit verify retry attempt=" .. tostring(attemptIndex),
            "verifyMode=" .. tostring(readiness.verifyMode or "strict"),
            "purchase=" .. tostring(diagnostics.purchaseCount or 0),
            "expectedMissingPurchase=" .. tostring(type(readiness) == "table" and readiness.expectedMissingPurchaseCount or 0),
            "unexpectedPurchase=" .. tostring(type(readiness) == "table" and readiness.unexpectedPurchaseCount or 0),
            "morph=" .. tostring(diagnostics.morphCount or 0),
            "expectedMissingMorph=" .. tostring(type(readiness) == "table" and readiness.expectedMissingMorphCount or 0),
            "unexpectedMorph=" .. tostring(type(readiness) == "table" and readiness.unexpectedMorphCount or 0),
            "reductionMismatch=" .. tostring(
                type(readiness) == "table" and readiness.reductionMismatchCount or 0
            ),
            "unresolved=" .. tostring(diagnostics.unresolvedCount or 0),
            "readyForRestore=" .. tostring(type(verifyPlan) == "table" and verifyPlan.readyForRestore == true)
        )
    end

    if verifyOk then
        self:VerifyPassiveExactPostCommit(context)
        context.postMutationVerifySucceeded = true
        local successPhase = context.commitPerformed == true
            and "route_b_commit_confirmed"
            or "route_b_no_commit_verified"
        logging.Log(
            "Route B post-commit verify retry success attempt=" .. tostring(attemptIndex),
            "phase=" .. successPhase
        )
        apply:FinalizeRouteBSuccess(context, {
            readiness = readiness,
        })
        return
    end

    if attemptIndex >= maxAttempts then
        apply:LogRouteBSkillTargetPlan("Route B post-commit verify exhausted", verifyPlan)
        apply:FinalizeRouteBFailure(context, "route_b_verify_retry_exhausted", {
            result = context.resultCode,
            verify = context.verifyResult,
            completion = context.completionSuccessSnapshot,
            completionSuccessKind = context.completionSuccessKind,
            verifyMode = readiness.verifyMode,
            readiness = readiness,
            postCommitSkillTargetPlan = verifyPlan,
            verifyRetryAttempts = attemptIndex,
        })
        return
    end

    zo_callLater(function()
        M:RunPostCommitVerifyRetry(apply, context)
    end, ROUTE_B_POST_COMMIT_VERIFY_RETRY_MS)
end

function M:BeginPostCommitVerifyRetry(apply, context, snapshot, successKind)
    if apply.pendingContext ~= context or self:IsPostCommitVerifyRetryInactive(apply, context) then
        return
    end

    context.completionSuccessSnapshot = snapshot
    context.completionSuccessKind = successKind
    context.postCommitVerifyRetryAttemptIndex = 0

    logging.Log(
        "Route B post-commit verify retry begin",
        "verifyMode=" .. tostring(apply:ResolveRouteBVerifyMode(context))
    )

    zo_callLater(function()
        M:RunPostCommitVerifyRetry(apply, context)
    end, ROUTE_B_POST_COMMIT_VERIFY_INITIAL_DELAY_MS)
end

function M:KickOffPostCommitVerify(apply, context, source)
    if apply.pendingContext ~= context then
        return
    end

    if context.finished then
        return
    end

    if context.verifyStarted then
        return
    end

    if context.completionArmed == true then
        return
    end

    context.verifyStarted = true
    if source == "post_commit_watchdog" then
        logging.Log("Route B post-commit watchdog verify start")
    end
    apply:CheckRouteBConfirmation(context)
end

function M:ApplyChangesAndMaybeWait(apply, context)
    context.commitAttemptIndex = (context.commitAttemptIndex or 0) + 1
    context.commitAttemptGeneration = (context.commitAttemptGeneration or 0) + 1
    context.commitRetryScheduled = false
    context.postCommitWatchdogScheduled = false
    context.commitAccepted = false
    context.commitAcceptanceSource = nil
    context.commitSent = false
    context.commitAt = nil
    context.resultReceived = false
    context.resultCode = nil
    context.castStarted = false
    context.castStartedAt = nil
    context.commitObserveAttemptIndex = 0

    logging.Log("Route B commit attempt", "retryCount=" .. tostring(apply:GetRouteBCommitRetryCount(context)))

    local applyOk, applyErr = pcall(function()
        SKILLS_AND_ACTION_BAR_MANAGER:ApplyChanges()
    end)

    if not applyOk then
        apply:FinalizeRouteBFailure(context, "route_b_commit_failed", {
            error = applyErr,
        })
        return
    end

    zo_callLater(function()
        M:RunCommitObserveWait(apply, context, context.commitAttemptGeneration)
    end, ROUTE_B_COMMIT_OBSERVE_POLL_MS)
end
