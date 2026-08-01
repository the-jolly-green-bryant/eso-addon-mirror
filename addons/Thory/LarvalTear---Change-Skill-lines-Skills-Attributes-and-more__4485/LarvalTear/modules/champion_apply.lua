local Addon = LarvalTearMod
local LTM = Addon
local Log = Addon.Common.Log
local LTM_CHAMPION_APPLY = Addon.Modules.ChampionApply
local LTM_PIPELINE_CONTEXT = Addon.Modules.PipelineContext
local LTM_CHAMPION_CHANGE = Addon.Modules.ChampionChange
local SHARED_UTIL = Addon.Common.Util

local CHAMPION_APPLY_E_CONFIG_INVALID = "CHAMPION_APPLY_E_CONFIG_INVALID"
local CHAMPION_APPLY_E_CHANGE_UNAVAILABLE = "CHAMPION_APPLY_E_CHANGE_UNAVAILABLE"
local CHAMPION_APPLY_E_CHANGE_FAILED = "CHAMPION_APPLY_E_CHANGE_FAILED"
local CHAMPION_APPLY_E_RUNTIME = "CHAMPION_APPLY_E_RUNTIME"
local CHAMPION_APPLY_E_PURCHASE_RESULT = "CHAMPION_APPLY_E_PURCHASE_RESULT"
local CHAMPION_APPLY_E_TIMEOUT = "CHAMPION_APPLY_E_TIMEOUT"
local CHAMPION_APPLY_VERIFY_DELAY_MS = 150
local CHAMPION_APPLY_TIMEOUT_MS = 5000
local CHAMPION_APPLY_EVENT_NAME = "LarvalTearChampionApplyResult"
local CHAMPION_APPLY_COOLDOWN_UPDATE_NAME = "LarvalTearChampionApplyCooldown"
local CHAMPION_APPLY_COOLDOWN_RESULT = 22
local CHAMPION_APPLY_COOLDOWN_SECONDS = 31
local CHAMPION_APPLY_SHORT_RETRY_DELAY_MS = 3000
local CHAMPION_APPLY_SHORT_RETRY_MAX_ATTEMPTS = 5
local CHAMPION_APPLY_E_PURCHASE_COOLDOWN = "champion_purchase_cooldown"
local CHAMPION_APPLY_PARTIAL_SLOTTED_NOT_PURCHASED = "champion_slotted_not_purchased_skipped"

function LTM_CHAMPION_APPLY:Log(...)
    if type(Log.LogDebugSummary) ~= "function" then
        return
    end

    Log.LogDebugSummary(...)
end

function LTM_CHAMPION_APPLY:BuildLastResult(ok, reason, details)
    self.lastResult = {
        ok = ok == true,
        details = {
            phase = "champion_apply",
            reason = reason,
            summary = details,
            commitAt = type(details) == "table" and details.commitAt or nil,
            mutatingAction = type(details) == "table" and details.commitAt and "champion_purchase" or nil,
        },
    }
end

function LTM_CHAMPION_APPLY:HasSkippedResidual(summary)
    return type(summary) == "table"
        and (
            (summary.skippedAllocationChanges or 0) > 0
            or (type(summary.skippedReasons) == "table" and #summary.skippedReasons > 0)
        )
end

function LTM_CHAMPION_APPLY:ResolvePartialReason(reason, summary)
    if type(reason) == "string" and reason ~= "" then
        return reason
    end

    if type(summary) == "table"
        and type(summary.skippedReasons) == "table"
        and type(summary.skippedReasons[1]) == "string"
        and summary.skippedReasons[1] ~= "" then
        return summary.skippedReasons[1]
    end

    return "champion_allocated_respec_unsupported"
end

function LTM_CHAMPION_APPLY:BuildSkippedReasonText(summary)
    if type(summary) ~= "table" or type(summary.skippedReasons) ~= "table" then
        return ""
    end

    return table.concat(summary.skippedReasons, ",")
end

local function NormalizeChampionApplyConfig(config)
    if type(config) ~= "table" then
        return nil, {}
    end

    return config.championPoints, type(config.options) == "table" and config.options or {}
end

function LTM_CHAMPION_APPLY:RecordPartialSuccess(pipelineContext, reason, summary)
    if type(pipelineContext) ~= "table" then
        return
    end

    local resolvedReason = self:ResolvePartialReason(reason, summary)
    local reasons = {}
    if type(summary) == "table" and type(summary.skippedReasons) == "table" and #summary.skippedReasons > 0 then
        for _, skippedReason in ipairs(summary.skippedReasons) do
            if type(skippedReason) == "string" and skippedReason ~= "" then
                reasons[#reasons + 1] = skippedReason
            end
        end
    end
    if #reasons == 0 then
        reasons[1] = resolvedReason
    end

    return LTM_PIPELINE_CONTEXT:RecordDomainResult(pipelineContext, {
        domain = "ChampionPoints",
        sourcePhase = "ChampionPoints",
        severity = "partial",
        resultCode = resolvedReason,
        reasons = reasons,
        residualSummary = summary,
    })
end

function LTM_CHAMPION_APPLY:FinishPartial(pipelineContext, reason, summary)
    local resolvedReason = self:ResolvePartialReason(reason, summary)
    self:BuildLastResult(true, resolvedReason, summary)
    self:RecordPartialSuccess(pipelineContext, resolvedReason, summary)
    self:Log(
        "Champion apply partial",
        "reason=" .. tostring(resolvedReason),
        "requestedSlotChanges=" .. tostring(type(summary) == "table" and summary.requestedSlotChanges or 0),
        "requestedAllocationChanges=" .. tostring(type(summary) == "table" and summary.requestedAllocationChanges or 0),
        "skippedAllocationChanges=" .. tostring(type(summary) == "table" and summary.skippedAllocationChanges or 0),
        "purchaseExpectedResult=" .. tostring(type(summary) == "table" and summary.purchaseExpectedResult or nil),
        "skippedReasons=" .. self:BuildSkippedReasonText(summary)
    )
    return true
end

function LTM_CHAMPION_APPLY:NotifyPipelineContinuation(context, success)
    local continuation = context and context.pipelineContinuation or nil
    if type(continuation) == "function" and not context.pipelineContinuationNotified then
        context.pipelineContinuationNotified = true
        continuation(success, context and context.errorCode or nil)
    end
end

function LTM_CHAMPION_APPLY:GetCooldownRemainingSeconds()
    local remaining = tonumber(self.cooldownRemainingSeconds) or 0
    if remaining < 0 then
        remaining = 0
    end

    return remaining
end

function LTM_CHAMPION_APPLY:StopCooldownLoop()
    if EVENT_MANAGER ~= nil and type(EVENT_MANAGER.UnregisterForUpdate) == "function" then
        EVENT_MANAGER:UnregisterForUpdate(CHAMPION_APPLY_COOLDOWN_UPDATE_NAME)
    end
end

function LTM_CHAMPION_APPLY:OnCooldownTick()
    local remaining = self:GetCooldownRemainingSeconds()
    if remaining <= 0 then
        self.cooldownRemainingSeconds = 0
        self:StopCooldownLoop()
        return
    end

    self.cooldownRemainingSeconds = remaining - 1
    if self.cooldownRemainingSeconds <= 0 then
        self.cooldownRemainingSeconds = 0
        self:StopCooldownLoop()
    end
end

function LTM_CHAMPION_APPLY:StartCooldown(seconds)
    local normalizedSeconds = type(seconds) == "number" and math.max(0, math.ceil(seconds)) or CHAMPION_APPLY_COOLDOWN_SECONDS
    if normalizedSeconds <= 0 then
        return
    end

    self.cooldownRemainingSeconds = normalizedSeconds
    if EVENT_MANAGER ~= nil and type(EVENT_MANAGER.RegisterForUpdate) == "function" then
        EVENT_MANAGER:UnregisterForUpdate(CHAMPION_APPLY_COOLDOWN_UPDATE_NAME)
        EVENT_MANAGER:RegisterForUpdate(CHAMPION_APPLY_COOLDOWN_UPDATE_NAME, 1000, function()
            LTM_CHAMPION_APPLY:OnCooldownTick()
        end)
    end
end

function LTM_CHAMPION_APPLY:IsCooldownResult(result)
    return result == CHAMPION_APPLY_COOLDOWN_RESULT
end

function LTM_CHAMPION_APPLY:IsCooldownError(err)
    return err == CHAMPION_APPLY_E_PURCHASE_COOLDOWN
        or err == "champion_purchase_unavailable_" .. tostring(CHAMPION_APPLY_COOLDOWN_RESULT)
end

function LTM_CHAMPION_APPLY:NotifyCooldownRetry(context)
    if type(LTM) == "table" and type(LTM.NotifyWaitStarted) == "function" then
        LTM:NotifyWaitStarted(context, "cp_cooldown", self:GetCooldownRemainingSeconds())
    end
end

function LTM_CHAMPION_APPLY:BeginCooldownRetry(context)
    if type(context) ~= "table" or context.finished then
        return true, "deferred"
    end

    if context.cpCooldownLongWaitStarted ~= true then
        context.cpCooldownLongWaitStarted = true
        context.deferredStarted = true
        self:StartCooldown(CHAMPION_APPLY_COOLDOWN_SECONDS)
        self:NotifyCooldownRetry(context)
        self:WaitForCooldownAndSend(context)
        return true, "deferred"
    end

    context.cpCooldownShortRetryCount = (context.cpCooldownShortRetryCount or 0) + 1
    if context.cpCooldownShortRetryCount > CHAMPION_APPLY_SHORT_RETRY_MAX_ATTEMPTS then
        self:Log(
            "Champion cooldown retry exhausted",
            "attempts=" .. tostring(CHAMPION_APPLY_SHORT_RETRY_MAX_ATTEMPTS)
        )
        return false, CHAMPION_APPLY_E_PURCHASE_RESULT .. "_cooldown_retry_exhausted"
    end

    if type(zo_callLater) ~= "function" then
        return false, CHAMPION_APPLY_E_TIMEOUT
    end

    if type(LTM) == "table" and type(LTM.NotifyWaitStarted) == "function" then
        LTM:NotifyWaitStarted(context, "cp_cooldown", CHAMPION_APPLY_SHORT_RETRY_DELAY_MS / 1000)
    end

    context.cooldownShortRetryGeneration = (context.cooldownShortRetryGeneration or 0) + 1
    local generation = context.cooldownShortRetryGeneration

    self:Log(
        "Champion cooldown short retry scheduled",
        "attempt=" .. tostring(context.cpCooldownShortRetryCount),
        "delayMs=" .. tostring(CHAMPION_APPLY_SHORT_RETRY_DELAY_MS)
    )

    zo_callLater(function()
        if context.finished or context.cooldownShortRetryGeneration ~= generation then
            return
        end

        local sendOk, sendErr = LTM_CHAMPION_APPLY:QueueAndBeginChampionPurchase(context)
        if not sendOk then
            LTM_CHAMPION_APPLY:FinishDeferred(context, false, sendErr)
        end
    end, CHAMPION_APPLY_SHORT_RETRY_DELAY_MS)

    return true, "deferred"
end

function LTM_CHAMPION_APPLY:FinishDeferred(context, success, err)
    if type(context) ~= "table" or context.finished then
        return
    end

    context.finished = true
    if EVENT_MANAGER ~= nil and type(EVENT_MANAGER.UnregisterForEvent) == "function" then
        EVENT_MANAGER:UnregisterForEvent(CHAMPION_APPLY_EVENT_NAME, EVENT_CHAMPION_PURCHASE_RESULT)
    end

    local summary = context.summary or {}
    if success then
        self:BuildLastResult(true, nil, summary)
        if self:HasSkippedResidual(summary) then
            self:RecordPartialSuccess(context.pipelineContext, nil, summary)
        end
        self:Log(
            "Champion apply finished",
            "targetGroups=" .. tostring(summary.targetGroups or 0),
            "requestedSlotChanges=" .. tostring(summary.requestedSlotChanges or 0),
            "requestedAllocationChanges=" .. tostring(summary.requestedAllocationChanges or 0),
            "skippedAllocationChanges=" .. tostring(summary.skippedAllocationChanges or 0),
            "purchaseExpectedResult=" .. tostring(summary.purchaseExpectedResult),
            "forceRespecEnabled=" .. tostring(summary.forceRespecEnabled == true),
            "forceRespecPlannedChanges=" .. tostring(summary.forceRespecPlannedChanges or 0),
            "forceRespecGraphRebuild=" .. tostring(summary.forceRespecGraphRebuild or 0),
            "graphRequestedAllocations=" .. tostring(summary.graphRequestedAllocations or 0),
            "graphRefunds=" .. tostring(summary.graphRefunds or 0),
            "graphIndependentRequests=" .. tostring(summary.graphIndependentRequests or 0),
            "graphUnreachableTargets=" .. tostring(summary.graphUnreachableTargets or 0),
            "graphVisitedStars=" .. tostring(summary.graphVisitedStars or 0),
            "forceRespecSlotOnlyEligible=" .. tostring(summary.forceRespecSlotOnlyEligible == true),
            "forceRespecReason=" .. tostring(summary.forceRespecReason or "none"),
            "skippedReasons=" .. self:BuildSkippedReasonText(summary)
        )
    else
        context.errorCode = err
        self:BuildLastResult(false, err, summary)
    end

    if type(LTM) == "table" and type(LTM.ResetWaitNotification) == "function" then
        LTM:ResetWaitNotification(context)
    end

    self:NotifyPipelineContinuation(context, success)
end

function LTM_CHAMPION_APPLY:BeginChampionPurchase(context)
    if EVENT_MANAGER == nil or type(EVENT_MANAGER.RegisterForEvent) ~= "function" then
        self:BuildLastResult(false, "champion_event_manager_unavailable", context and context.summary or nil)
        return false, CHAMPION_APPLY_E_CHANGE_FAILED
    end

    context.sendAttemptGeneration = (context.sendAttemptGeneration or 0) + 1
    local generation = context.sendAttemptGeneration

    EVENT_MANAGER:UnregisterForEvent(CHAMPION_APPLY_EVENT_NAME, EVENT_CHAMPION_PURCHASE_RESULT)
    EVENT_MANAGER:RegisterForEvent(CHAMPION_APPLY_EVENT_NAME, EVENT_CHAMPION_PURCHASE_RESULT, function(_, result)
        if context.sendAttemptGeneration ~= generation then
            return
        end
        LTM_CHAMPION_APPLY:HandleChampionPurchaseResult(context, result)
    end)

    local sendOk, sendErr = pcall(SendChampionPurchaseRequest)
    if not sendOk then
        EVENT_MANAGER:UnregisterForEvent(CHAMPION_APPLY_EVENT_NAME, EVENT_CHAMPION_PURCHASE_RESULT)
        self:BuildLastResult(false, sendErr, context.summary)
        return false, CHAMPION_APPLY_E_CHANGE_FAILED
    end

    if type(LTM) == "table" and type(LTM.ResetWaitNotification) == "function" then
        LTM:ResetWaitNotification(context)
    end

    self:Log(
        "Champion purchase sent",
        "requestedSlotChanges=" .. tostring(context.summary.requestedSlotChanges or 0),
        "requestedAllocationChanges=" .. tostring(context.summary.requestedAllocationChanges or 0),
        "forceRespecEnabled=" .. tostring(context.summary.forceRespecEnabled == true),
        "forceRespecPlannedChanges=" .. tostring(context.summary.forceRespecPlannedChanges or 0),
        "forceRespecRefunds=" .. tostring(context.summary.forceRespecRefunds or 0),
        "forceRespecPurchases=" .. tostring(context.summary.forceRespecPurchases or 0),
        "forceRespecUpdates=" .. tostring(context.summary.forceRespecUpdates or 0),
        "forceRespecGraphRebuild=" .. tostring(context.summary.forceRespecGraphRebuild or 0),
        "graphRequestedAllocations=" .. tostring(context.summary.graphRequestedAllocations or 0),
        "graphRefunds=" .. tostring(context.summary.graphRefunds or 0),
        "graphIndependentRequests=" .. tostring(context.summary.graphIndependentRequests or 0),
        "graphUnreachableTargets=" .. tostring(context.summary.graphUnreachableTargets or 0),
        "graphVisitedStars=" .. tostring(context.summary.graphVisitedStars or 0),
        "forceRespecPrerequisiteRepairResult="
            .. tostring(context.summary.forceRespecPrerequisiteRepairResult),
        "forceRespecSlotOnlyEligible=" .. tostring(context.summary.forceRespecSlotOnlyEligible == true),
        "forceRespecReason=" .. tostring(context.summary.forceRespecReason or "none"),
        "forceRespecRefundScope=" .. tostring(context.summary.forceRespecRefundScope or "none"),
        "respecNeeded=" .. tostring(context.plan and context.plan.respecNeeded == true)
    )

    if type(zo_callLater) == "function" then
        zo_callLater(function()
            if not context.finished and context.sendAttemptGeneration == generation then
                self:Log("Champion purchase timeout", "timeoutMs=" .. tostring(CHAMPION_APPLY_TIMEOUT_MS))
                LTM_CHAMPION_APPLY:FinishDeferred(context, false, CHAMPION_APPLY_E_TIMEOUT)
            end
        end, CHAMPION_APPLY_TIMEOUT_MS)
    end

    return true, "deferred"
end

function LTM_CHAMPION_APPLY:QueueAndBeginChampionPurchase(context)
    local queueOk, queueErr, queueSummary = LTM_CHAMPION_CHANGE:QueueChampionPurchaseRequest(context.plan)
    context.summary = queueSummary or context.summary or {}

    if not queueOk then
        if self:IsCooldownError(queueErr) then
            return self:BeginCooldownRetry(context)
        end

        if queueErr == CHAMPION_APPLY_PARTIAL_SLOTTED_NOT_PURCHASED then
            self:Log("Champion purchase request skipped", "reason=" .. tostring(queueErr))
            if context.deferredStarted == true then
                self:FinishPartial(context.pipelineContext, queueErr, context.summary)
                self:FinishDeferred(context, true, nil)
                return true, "deferred"
            end
            return self:FinishPartial(context.pipelineContext, queueErr, context.summary)
        end

        self:BuildLastResult(false, queueErr, context.summary)
        self:Log("Champion purchase request failed", "error=" .. tostring(queueErr))
        return false, CHAMPION_APPLY_E_CHANGE_FAILED
    end

    return self:BeginChampionPurchase(context)
end

function LTM_CHAMPION_APPLY:WaitForCooldownAndSend(context)
    if type(context) ~= "table" or context.finished then
        return
    end

    if type(zo_callLater) ~= "function" then
        self:FinishDeferred(context, false, CHAMPION_APPLY_E_TIMEOUT)
        return
    end

    context.cooldownWaitGeneration = (context.cooldownWaitGeneration or 0) + 1
    local generation = context.cooldownWaitGeneration

    zo_callLater(function()
        if context.finished or context.cooldownWaitGeneration ~= generation then
            return
        end

        if LTM_CHAMPION_APPLY:GetCooldownRemainingSeconds() > 0 then
            LTM_CHAMPION_APPLY:WaitForCooldownAndSend(context)
            return
        end

        local sendOk, sendErr = LTM_CHAMPION_APPLY:QueueAndBeginChampionPurchase(context)
        if not sendOk then
            LTM_CHAMPION_APPLY:FinishDeferred(context, false, sendErr)
        end
    end, 1000)
end

function LTM_CHAMPION_APPLY:HandleChampionPurchaseResult(context, result)
    self:Log("Champion purchase result", "result=" .. tostring(result))

    local function verifyAndFinish()
        local verifyOk = type(LTM_CHAMPION_CHANGE) == "table"
            and type(LTM_CHAMPION_CHANGE.VerifyAppliedPlan) == "function"
            and LTM_CHAMPION_CHANGE:VerifyAppliedPlan(context.plan)
        if verifyOk == true then
            self:FinishDeferred(context, true, nil)
        else
            self:Log("Champion verify failed", "error=" .. tostring(CHAMPION_APPLY_E_PURCHASE_RESULT))
            self:FinishDeferred(context, false, CHAMPION_APPLY_E_PURCHASE_RESULT)
        end
    end

    if result ~= CHAMPION_PURCHASE_SUCCESS then
        if self:IsCooldownResult(result) then
            if EVENT_MANAGER ~= nil and type(EVENT_MANAGER.UnregisterForEvent) == "function" then
                EVENT_MANAGER:UnregisterForEvent(CHAMPION_APPLY_EVENT_NAME, EVENT_CHAMPION_PURCHASE_RESULT)
            end
            local retryOk, retryErr = self:BeginCooldownRetry(context)
            if not retryOk then
                self:FinishDeferred(context, false, retryErr)
            end
            return
        end
        self:FinishDeferred(context, false, CHAMPION_APPLY_E_PURCHASE_RESULT .. "_" .. tostring(result))
        return
    end

    self:StartCooldown(CHAMPION_APPLY_COOLDOWN_SECONDS)

    if type(zo_callLater) == "function" then
        zo_callLater(verifyAndFinish, CHAMPION_APPLY_VERIFY_DELAY_MS)
    else
        verifyAndFinish()
    end
end

function LTM_CHAMPION_APPLY:Run(config)
    if type(config) ~= "table" then
        self:BuildLastResult(false, "champion_config_invalid", nil)
        return false, CHAMPION_APPLY_E_CONFIG_INVALID
    end

    if type(LTM_CHAMPION_CHANGE) ~= "table"
        or type(LTM_CHAMPION_CHANGE.CreateApplyPlan) ~= "function"
        or type(LTM_CHAMPION_CHANGE.QueueChampionPurchaseRequest) ~= "function" then
        self:BuildLastResult(false, "champion_change_unavailable", nil)
        return false, CHAMPION_APPLY_E_CHANGE_UNAVAILABLE
    end

    local targetChampionPoints, championOptions = NormalizeChampionApplyConfig(config)
    local runOk, plan, planErr, summary = pcall(
        LTM_CHAMPION_CHANGE.CreateApplyPlan,
        LTM_CHAMPION_CHANGE,
        targetChampionPoints,
        championOptions
    )
    if not runOk then
        self:BuildLastResult(false, tostring(plan), nil)
        return false, CHAMPION_APPLY_E_RUNTIME
    end

    if type(summary) == "table" then
        self:Log(
            "Champion apply summary",
            "targetGroups=" .. tostring(summary.targetGroups or 0),
            "targetSlottedStars=" .. tostring(summary.targetSlottedStars or 0),
            "targetAllocatedStars=" .. tostring(summary.targetAllocatedStars or 0),
            "requestedSlotChanges=" .. tostring(summary.requestedSlotChanges or 0),
            "requestedAllocationChanges=" .. tostring(summary.requestedAllocationChanges or 0),
            "skippedAllocationChanges=" .. tostring(summary.skippedAllocationChanges or 0),
            "purchaseExpectedResult=" .. tostring(summary.purchaseExpectedResult),
            "skippedReasons=" .. self:BuildSkippedReasonText(summary),
            "respecNeeded=" .. tostring(summary.respecNeeded == true),
            "forceRespecEnabled=" .. tostring(summary.forceRespecEnabled == true),
            "forceRespecPlannedChanges=" .. tostring(summary.forceRespecPlannedChanges or 0),
            "forceRespecRefunds=" .. tostring(summary.forceRespecRefunds or 0),
            "forceRespecPurchases=" .. tostring(summary.forceRespecPurchases or 0),
            "forceRespecUpdates=" .. tostring(summary.forceRespecUpdates or 0),
            "forceRespecSlotTargetsPurchasedInRequest="
                .. tostring(summary.forceRespecSlotTargetsPurchasedInRequest or 0),
            "forceRespecGraphRebuild=" .. tostring(summary.forceRespecGraphRebuild or 0),
            "graphRequestedAllocations=" .. tostring(summary.graphRequestedAllocations or 0),
            "graphRefunds=" .. tostring(summary.graphRefunds or 0),
            "graphIndependentRequests=" .. tostring(summary.graphIndependentRequests or 0),
            "graphUnreachableTargets=" .. tostring(summary.graphUnreachableTargets or 0),
            "graphVisitedStars=" .. tostring(summary.graphVisitedStars or 0),
            "forceRespecSlotOnlyEligible=" .. tostring(summary.forceRespecSlotOnlyEligible == true),
            "forceRespecReason=" .. tostring(summary.forceRespecReason or "none"),
            "forceRespecRefundScope=" .. tostring(summary.forceRespecRefundScope or "none"),
            "unresolvedStars=" .. tostring(summary.unresolvedStars or 0)
        )
    end

    if type(plan) ~= "table" then
        self:BuildLastResult(false, planErr, summary)
        self:Log("Champion plan failed", "error=" .. tostring(planErr))
        return false, CHAMPION_APPLY_E_CHANGE_FAILED
    end

    if type(LTM_CHAMPION_CHANGE.LogPlanDebug) == "function" then
        LTM_CHAMPION_CHANGE:LogPlanDebug(plan)
    end

    if type(LTM_CHAMPION_CHANGE.HasUnresolvedChanges) == "function"
        and LTM_CHAMPION_CHANGE:HasUnresolvedChanges(plan) then
        local unresolvedMessage = type(LTM_CHAMPION_CHANGE.GetPlanErrorMessage) == "function"
            and LTM_CHAMPION_CHANGE:GetPlanErrorMessage(plan)
            or "champion_target_unresolved"
        self:BuildLastResult(false, unresolvedMessage, summary)
        return false, tostring(unresolvedMessage)
    end

    if type(LTM_CHAMPION_CHANGE.HasPendingChanges) ~= "function"
        or not LTM_CHAMPION_CHANGE:HasPendingChanges(plan) then
        if self:HasSkippedResidual(summary) then
            return self:FinishPartial(config._pipelineContext, nil, summary)
        end
        self:BuildLastResult(true, nil, summary)
        self:Log(
            "Champion apply finished",
            "requestedSlotChanges=0",
            "requestedAllocationChanges=0",
            "skippedAllocationChanges=" .. tostring(summary.skippedAllocationChanges or 0),
            "purchaseExpectedResult=" .. tostring(summary.purchaseExpectedResult),
            "forceRespecEnabled=" .. tostring(summary.forceRespecEnabled == true),
            "forceRespecPlannedChanges=" .. tostring(summary.forceRespecPlannedChanges or 0),
            "forceRespecGraphRebuild=" .. tostring(summary.forceRespecGraphRebuild or 0),
            "graphRequestedAllocations=" .. tostring(summary.graphRequestedAllocations or 0),
            "graphRefunds=" .. tostring(summary.graphRefunds or 0),
            "graphIndependentRequests=" .. tostring(summary.graphIndependentRequests or 0),
            "graphUnreachableTargets=" .. tostring(summary.graphUnreachableTargets or 0),
            "graphVisitedStars=" .. tostring(summary.graphVisitedStars or 0),
            "forceRespecPrerequisiteRepairResult="
                .. tostring(summary.forceRespecPrerequisiteRepairResult),
            "forceRespecSlotOnlyEligible=" .. tostring(summary.forceRespecSlotOnlyEligible == true),
            "forceRespecReason=" .. tostring(summary.forceRespecReason or "none"),
            "skippedReasons=" .. self:BuildSkippedReasonText(summary)
        )
        return true
    end

    if EVENT_MANAGER == nil or type(EVENT_MANAGER.RegisterForEvent) ~= "function" then
        self:BuildLastResult(false, "champion_event_manager_unavailable", summary)
        return false, CHAMPION_APPLY_E_CHANGE_FAILED
    end

    local context = {
        finished = false,
        plan = plan,
        summary = summary or {},
        pipelineContinuation = config._pipelineContinuation,
        pipelineContinuationNotified = false,
        pipelineContext = config._pipelineContext,
    }
    context.summary.commitAt = SHARED_UTIL:GetFrameTimeMillisecondsSafe()
    if self:GetCooldownRemainingSeconds() > 0 then
        context.cpCooldownLongWaitStarted = true
        context.deferredStarted = true
        self:NotifyCooldownRetry(context)
        self:WaitForCooldownAndSend(context)
        return true, "deferred"
    end

    return self:QueueAndBeginChampionPurchase(context)
end

function LTM_CHAMPION_APPLY:GetLastResult()
    return self.lastResult
end
