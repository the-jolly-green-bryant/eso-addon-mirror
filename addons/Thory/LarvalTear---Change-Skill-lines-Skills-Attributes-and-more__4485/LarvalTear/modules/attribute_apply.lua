local Addon = LarvalTearMod
local LTM = Addon
local Log = Addon.Common.Log
local LTM_ATTRIBUTE_APPLY = Addon.Modules.AttributeApply
local LTM_APPLY_COOLDOWN_GATE = Addon.Modules.ApplyCooldownGate
local LTM_ATTRIBUTE_RETRY = Addon.Modules.AttributeRetry
local LTM_ATTRIBUTE_SCENE = Addon.Modules.AttributeScene
local LTM_RESPEC_OBSERVER = Addon.Modules.RespecObserver
local SHARED_UTIL = Addon.Common.Util
local DOMAINS = Addon.Common.Domains
local ATTRIBUTE_TYPES = DOMAINS.AttributeTypes
local ATTRIBUTE_ORDER = DOMAINS.AttributeOrder
local AUTO_ENTRY_RETRY_DELAYS_MS = { 0, 250, 500, 750, 1000 }
local AUTO_ENTRY_START_RETRY_DELAY_MS = 2000
local AUTO_ENTRY_MAX_START_ATTEMPTS = 5
local STATS_SCENE_READY_RETRY_DELAYS_MS = { 0, 100, 250, 500, 750 }
local ATTRIBUTE_CAST_TIMEOUT_MS = 7000
local ATTRIBUTE_RESULT_WAIT_INITIAL_DELAY_MS = 4000
local ATTRIBUTE_RESULT_WAIT_POLL_MS = 250
local ATTRIBUTE_RESULT_WAIT_MAX_ATTEMPTS = 48
local ATTR_E_SCENE_READY_TIMEOUT = "ATTR_E_SCENE_READY_TIMEOUT"
local ATTR_E_RESPEC_ENTRY_TIMEOUT = "ATTR_E_RESPEC_ENTRY_TIMEOUT"
local ATTR_E_MANAGER_MISSING = "ATTR_E_MANAGER_MISSING"
local ATTR_E_CLEAR_FAILED = "ATTR_E_CLEAR_FAILED"
local ATTR_E_ALLOCATE_FAILED = "ATTR_E_ALLOCATE_FAILED"
local ATTR_E_FINALIZE_REQUEST_FAILED = "ATTR_E_FINALIZE_REQUEST_FAILED"
local ATTR_E_RESULT_WAIT_REGISTER_FAILED = "ATTR_E_RESULT_WAIT_REGISTER_FAILED"
local ATTR_E_COMPLETION_TIMEOUT = "ATTR_E_COMPLETION_TIMEOUT"
local ATTR_E_RESULT_75_RETRY_EXHAUSTED = "ATTR_E_RESULT_75_RETRY_EXHAUSTED"
local ATTR_E_CAST_TIMEOUT = "ATTR_E_CAST_TIMEOUT"
local ATTR_E_DUPLICATE_COMMIT_BLOCKED = "ATTR_E_DUPLICATE_COMMIT_BLOCKED"
local ATTR_E_CANCELLED = "ATTR_E_CANCELLED"
local ATTR_E_UNEXPECTED = "ATTR_E_UNEXPECTED"
local ATTRIBUTE_RUN_SEQUENCE = 0
local EnableBatchMode
local FindKeyboardSpinner
local SearchClearCandidates
local ClearCurrentAllocation
local AllocateTargetValues
local BuildAllocationDeltaFromSpinners
local FinalizeAllocation
local SendAttributeCommitAttempt
local LogAsyncAttempt
local FinishAsyncContext
local DispatchAttributeApplyCore
local EnsureRespecInteractionOrDefer
local BeginAttributeResultWait
local RegisterAttributeResultWait
local IsActivityDisallowedResult

local function ResolveAttributeScene()
    if type(LTM_ATTRIBUTE_SCENE) == "table" then
        return LTM_ATTRIBUTE_SCENE
    end

    return nil
end

local function ResolveAttributeRetry()
    if type(LTM_ATTRIBUTE_RETRY) == "table" then
        return LTM_ATTRIBUTE_RETRY
    end

    return nil
end

local function ResolveRespecObserver()
    if type(LTM_RESPEC_OBSERVER) == "table" then
        return LTM_RESPEC_OBSERVER
    end

    return nil
end

-- Logging / error helpers
-- Trace messages are debug-only and can be as verbose as needed for probes.
local function TraceStep(...)
    if type(Log.IsSummaryDebugEnabled) ~= "function" or not Log.IsSummaryDebugEnabled() then
        return
    end

    if type(Log.Debug) == "function" then
        Log.Debug(...)
        return
    end
end

local function LogStep(...)
    TraceStep(...)
end

local function LogCommitTrace(...)
    TraceStep(...)
end

local function LogDebugSummary(...)
    if type(Log.LogDebugSummary) == "function" then
        Log.LogDebugSummary(...)
    end
end

local function LogAttributeRetrySummary(status, ...)
    LogDebugSummary("Attribute retry summary", "status=" .. tostring(status), ...)
end

local function LogAttributeAutoEntrySummary(status, ...)
    LogDebugSummary("Attribute auto-entry summary", "status=" .. tostring(status), ...)
end

local function GetAttributeSpentPointsSafe(attributeType)
    if type(GetAttributeSpentPoints) ~= "function" then
        return nil
    end

    local ok, points = pcall(GetAttributeSpentPoints, attributeType)
    if ok then
        return points
    end

    return nil
end

local function GetGamepadAddedPoints(statsManager, attributeType)
    local data = type(statsManager) == "table" and type(statsManager.attributeData) == "table"
        and statsManager.attributeData[attributeType]
        or nil
    if type(data) == "table" then
        return data.addedPoints
    end

    return nil
end

local function NormalizeErrorCode(errorCode, fallbackCode)
    if errorCode == ATTR_E_SCENE_READY_TIMEOUT
        or errorCode == ATTR_E_RESPEC_ENTRY_TIMEOUT
        or errorCode == ATTR_E_MANAGER_MISSING
        or errorCode == ATTR_E_CLEAR_FAILED
        or errorCode == ATTR_E_ALLOCATE_FAILED
        or errorCode == ATTR_E_FINALIZE_REQUEST_FAILED
        or errorCode == ATTR_E_RESULT_WAIT_REGISTER_FAILED
        or errorCode == ATTR_E_COMPLETION_TIMEOUT
        or errorCode == ATTR_E_RESULT_75_RETRY_EXHAUSTED
        or errorCode == ATTR_E_CAST_TIMEOUT
        or errorCode == ATTR_E_DUPLICATE_COMMIT_BLOCKED
        or errorCode == ATTR_E_CANCELLED
        or errorCode == ATTR_E_UNEXPECTED then
        return errorCode
    end

    return fallbackCode or ATTR_E_UNEXPECTED
end

local function LogAttributeFailure(context, errorCode, stage, rawError)
    local fields = {
        "runId=" .. tostring(context and context.runId),
        "error=" .. tostring(errorCode),
        "reason=" .. tostring(rawError or errorCode),
        "stage=" .. tostring(stage or "unknown"),
        "attemptIndex=" .. tostring(context and context.attemptIndex),
        "commitAttempt=" .. tostring(context and context.commitAttempt),
        "commitSent=" .. tostring(context and context.commitSent == true),
        "castStarted=" .. tostring(context and context.castStarted == true),
        "resultCode=" .. tostring(context and context.resultCode),
        "targetHealth=" .. tostring(context and context.target and context.target.health),
        "targetMagicka=" .. tostring(context and context.target and context.target.magicka),
        "targetStamina=" .. tostring(context and context.target and context.target.stamina),
    }

    LogDebugSummary("Attribute failure detail", unpack(fields))
end

local function FailContext(context, errorCode, fallbackCode, stage)
    local normalized = NormalizeErrorCode(errorCode, fallbackCode)
    if context then
        context.errorCode = normalized
        context.finished = true
    end
    if context == nil or context.failureLogged ~= true then
        if context then
            context.failureLogged = true
        end
        LogAttributeFailure(context, normalized, stage, errorCode)
    end
    return false, normalized
end

local function SucceedContext(context)
    if context then
        context.finished = true
    end
    return true
end

local function ClearResultWaitRegistration(context)
    local observer = ResolveRespecObserver()
    if observer and type(observer.UnregisterAttributeEvents) == "function" then
        observer:UnregisterAttributeEvents(context)
        observer:ClearAttributeObservationSignature(context)
        return
    end

    if context then
        context.resultEventRegistered = false
        context.castEventRegistered = false
        context.attributeObserverSnapshotSignature = nil
    end
end

function LTM_ATTRIBUTE_APPLY:ClearPendingContext()
    local context = self.pendingContext
    if context then
        ClearResultWaitRegistration(context)
        context.finished = true
    end

    self.pendingContext = nil
end

local function IsCompletionSuccess(snapshot)
    if snapshot.commitSent ~= true then
        return false, nil
    end

    if snapshot.resultCode == RESPEC_RESULT_SUCCESS then
        return true, "resultCode"
    end

    if snapshot.allocationMode == 0 then
        return true, "allocationMode"
    end

    return false, nil
end

local function MarkCompletionResolved(context)
    if context then
        context.completionResolved = true
    end
end

local function IsContextInactive(context)
    return context == nil or context.finished or context.completionResolved
end

local function FinishDeferredContextIfNeeded(context, errorCode)
    if context
        and context.deferredPhase == true
        and type(context.pipelineContinuation) == "function" then
        FinishAsyncContext(context, false, errorCode)
        return true
    end

    return false
end

local function FailStartAttributeExecution(context, errorCode, fallbackCode)
    local normalized = NormalizeErrorCode(errorCode, fallbackCode)
    if FinishDeferredContextIfNeeded(context, normalized) then
        return false, normalized
    end

    return FailContext(context, normalized, nil, "start")
end

local function ResolveApplyCooldownGate()
    if type(LTM_APPLY_COOLDOWN_GATE) == "table" then
        return LTM_APPLY_COOLDOWN_GATE
    end

    return nil
end

local function RecordSharedCooldownMutation(kind, atMs)
    local gate = ResolveApplyCooldownGate()
    if gate and type(gate.RecordMutation) == "function" then
        gate:RecordMutation(kind, atMs)
    end
end

function LTM_ATTRIBUTE_APPLY:NotifyPipelineContinuation(context, success)
    if context and context.continuationCalled then
        return
    end

    local continuation = context and context.pipelineContinuation or nil
    if context then
        context.continuationCalled = true
    end
    if type(continuation) == "function" then
        continuation(success, context and context.errorCode or nil)
    end
end

local function BuildCompletionSnapshot(context)
    local statsManager = context and context.statsManager or nil
    local sceneHelper = ResolveAttributeScene()
    local observer = ResolveRespecObserver()
    if observer and type(observer.BuildAttributeSnapshot) == "function" then
        return observer:BuildAttributeSnapshot(context, statsManager, sceneHelper)
    end

    return {
        resultReceived = context and context.resultReceived or false,
        resultCode = context and context.resultCode or nil,
        commitSent = context and context.commitSent or false,
        commitAttempt = context and context.commitAttempt or 0,
    }
end

local function LogCompletionPoll(context, snapshot)
    local observer = ResolveRespecObserver()
    if observer and type(observer.LogAttributeSnapshotIfChanged) == "function" then
        observer:LogAttributeSnapshotIfChanged(context, "poll", snapshot)
    end
end

local function ResolveCompletionSuccess(context, snapshot)
    MarkCompletionResolved(context)
    RecordSharedCooldownMutation("attribute", SHARED_UTIL:GetFrameTimeMillisecondsSafe())
    return FinishAsyncContext(context, true)
end

local function InvalidateResultWait(context)
    ClearResultWaitRegistration(context)
    context.resultWaitGeneration = (context.resultWaitGeneration or 0) + 1
end

local function ScheduleCommitAttempt(context, delayMs, reason)
    if IsContextInactive(context) then
        return false, ATTR_E_UNEXPECTED
    end

    if type(zo_callLater) ~= "function" then
        return false, "zo_callLater_unavailable"
    end

    context.commitTimerGeneration = (context.commitTimerGeneration or 0) + 1
    local generation = context.commitTimerGeneration
    context.retryScheduled = true
    if type(LTM) == "table" and type(LTM.NotifyWaitStarted) == "function" then
        local waitSeconds = type(delayMs) == "number" and (delayMs / 1000) or nil
        if reason == "retry" then
            LTM:NotifyWaitStarted(context, "attribute_retry", waitSeconds)
        else
            LTM:NotifyWaitStarted(context, "server_busy", waitSeconds)
        end
    end

    local retryHelper = ResolveAttributeRetry()
    local retrySummary = retryHelper and retryHelper:BuildRetrySummary(reason, context, delayMs) or nil
    if retrySummary then
        if retrySummary.nextAttempt ~= nil then
            LogAttributeRetrySummary(
                retrySummary.status,
                "delayMs=" .. tostring(retrySummary.delayMs),
                "nextAttempt=" .. tostring(retrySummary.nextAttempt)
            )
        else
            LogAttributeRetrySummary(retrySummary.status, "delayMs=" .. tostring(retrySummary.delayMs))
        end
    end

    zo_callLater(function()
        if IsContextInactive(context) or LTM_ATTRIBUTE_APPLY.pendingContext ~= context then
            return
        end

        if context.commitTimerGeneration ~= generation or context.castStarted then
            return
        end

        context.retryScheduled = false
        LogAttributeRetrySummary("attempt", "attempt=" .. tostring((context.commitAttempt or 0) + 1))
        local sendOk, sendErr = SendAttributeCommitAttempt(context)
        if not sendOk then
            FinishAsyncContext(context, false, sendErr or ATTR_E_FINALIZE_REQUEST_FAILED)
        end
    end, delayMs)

    return true
end

local function ScheduleRetryAfterBusyResult(context)
    local retryHelper = ResolveAttributeRetry()
    if retryHelper and retryHelper:IsRetrySchedulingBlocked(context) then
        return true
    end

    if IsContextInactive(context) then
        return true
    end

    if retryHelper and retryHelper:IsRetryExhausted(context) then
        Log.Debug(string.format(
            "Attribute commit retry exhausted runId=%s attempts=%s",
            tostring(context.runId),
            tostring(context.commitAttempt or 0)
        ))
        return FinishAsyncContext(context, false, ATTR_E_RESULT_75_RETRY_EXHAUSTED)
    end

    context.resultReceived = false
    context.resultCode = nil
    InvalidateResultWait(context)
    local retryDelayMs = retryHelper and retryHelper:GetCommitRetryIntervalMs() or 1000
    return ScheduleCommitAttempt(context, retryDelayMs, "retry")
end

local function OnAttributeRespecCastEvent(context, generation)
    if LTM_ATTRIBUTE_APPLY.pendingContext ~= context or IsContextInactive(context) then
        return
    end

    if generation ~= nil and context.resultWaitGeneration ~= generation then
        return
    end

    if context.castStarted then
        return
    end

    context.castStarted = true
    context.castStartedAt = SHARED_UTIL:GetFrameTimeMillisecondsSafe()
    context.retryScheduled = false
    context.commitTimerGeneration = (context.commitTimerGeneration or 0) + 1
    if type(LTM) == "table" and type(LTM.ResetWaitNotification) == "function" then
        LTM:ResetWaitNotification(context)
    end
    LogDebugSummary("Attribute cast/result summary", "kind=cast", "attempt=" .. tostring(context.commitAttempt or 0))
end

local function HandleAttributeResultCode(context, result)
    context.resultReceived = true
    context.resultCode = result

    LogDebugSummary("Attribute cast/result summary", "kind=result", "result=" .. tostring(result), "attempt=" .. tostring(context.commitAttempt or 0))

    local retryHelper = ResolveAttributeRetry()
    if retryHelper and retryHelper:IsBusyRetryableResult(result) then
        if context.castStarted then
            return true
        end
        return ScheduleRetryAfterBusyResult(context)
    end

    if IsActivityDisallowedResult(result) then
        if type(LTM) == "table" and type(LTM.NotifyActivityDisallowed) == "function" then
            LTM:NotifyActivityDisallowed("attributes")
        end
        return FinishAsyncContext(context, false, "activity_disallowed")
    end

    if result ~= nil and result ~= RESPEC_RESULT_SUCCESS then
        return FinishAsyncContext(context, false, ATTR_E_FINALIZE_REQUEST_FAILED)
    end

    return true
end

local function OnAttributeResultWaitReady(context, generation)
    if LTM_ATTRIBUTE_APPLY.pendingContext ~= context or IsContextInactive(context) then
        return
    end

    if generation ~= nil and context.resultWaitGeneration ~= generation then
        return
    end

    context.resultPollAttemptIndex = (context.resultPollAttemptIndex or 0) + 1
    local snapshot = BuildCompletionSnapshot(context)
    LogCompletionPoll(context, snapshot)

    if context.castStarted ~= true
        and type(snapshot.castRemainingMs) == "number"
        and snapshot.castRemainingMs > 0 then
        OnAttributeRespecCastEvent(context, generation)
    end

    local success = IsCompletionSuccess(snapshot)
    if success then
        return ResolveCompletionSuccess(context, snapshot)
    end

    if context.castStarted and context.castStartedAt ~= nil then
        local castElapsedMs = SHARED_UTIL:GetFrameTimeMillisecondsSafe() - context.castStartedAt
        if castElapsedMs >= ATTRIBUTE_CAST_TIMEOUT_MS then
            LogDebugSummary("Attribute timeout detail", "kind=cast", "runId=" .. tostring(context.runId), "elapsedMs=" .. tostring(castElapsedMs))
            return FinishAsyncContext(context, false, ATTR_E_CAST_TIMEOUT)
        end
    end

    local retryHelper = ResolveAttributeRetry()
    if retryHelper and retryHelper:IsBusyRetryableResult(snapshot.resultCode) then
        return ScheduleRetryAfterBusyResult(context)
    end

    if context.resultPollAttemptIndex >= ATTRIBUTE_RESULT_WAIT_MAX_ATTEMPTS then
        MarkCompletionResolved(context)
        LogDebugSummary("Attribute timeout detail", "kind=completion", "runId=" .. tostring(context.runId))
        return FinishAsyncContext(context, false, ATTR_E_COMPLETION_TIMEOUT)
    end

    zo_callLater(function()
        OnAttributeResultWaitReady(context)
    end, ATTRIBUTE_RESULT_WAIT_POLL_MS)
end

local function OnAttributeRespecResultEvent(context, generation, result)
    if LTM_ATTRIBUTE_APPLY.pendingContext ~= context or IsContextInactive(context) then
        return
    end

    if generation ~= nil and context.resultWaitGeneration ~= generation then
        return
    end

    HandleAttributeResultCode(context, result)
end

function LTM_ATTRIBUTE_APPLY:OnObservedAttributeRespecResult(result)
    local context = self.pendingContext
    if context == nil or IsContextInactive(context) then
        return
    end

    HandleAttributeResultCode(context, result)
end

function LTM_ATTRIBUTE_APPLY:OnObservedAttributeRespecCast()
    local context = self.pendingContext
    if context == nil or IsContextInactive(context) then
        return
    end

    OnAttributeRespecCastEvent(context, context.resultWaitGeneration)
end

local function ArmAttributeResultWait(context)
    context.resultReceived = false
    context.resultCode = nil
    context.resultPollAttemptIndex = 0
    context.resultWaitGeneration = (context.resultWaitGeneration or 0) + 1
    LTM_ATTRIBUTE_APPLY.pendingContext = context

    local generation = context.resultWaitGeneration
    local registerOk, registerErr = RegisterAttributeResultWait(context, generation)
    if not registerOk then
        return false, registerErr
    end

    return true, generation
end

local function StartAttributeResultWaitPolling(context, generation)
    if type(zo_callLater) ~= "function" then
        return false, "zo_callLater_unavailable"
    end

    zo_callLater(function()
        OnAttributeResultWaitReady(context, generation)
    end, ATTRIBUTE_RESULT_WAIT_INITIAL_DELAY_MS)

    return true
end

RegisterAttributeResultWait = function(context, generation)
    local observer = ResolveRespecObserver()
    if observer and type(observer.RegisterAttributeEvents) == "function" then
        return observer:RegisterAttributeEvents(context, generation, {
            onResult = function(result)
                OnAttributeRespecResultEvent(context, generation, result)
            end,
            onCast = function()
                OnAttributeRespecCastEvent(context, generation)
            end,
        })
    end

    return false, "respec_observer_unavailable"
end

local function IsWholeNumber(value)
    return type(value) == "number" and value >= 0 and value == math.floor(value)
end

-- Validation / state helpers
local function NormalizeAttributes(config)
    if type(config) ~= "table" then
        return nil, "attributes config must be a table"
    end

    local normalized = {}
    for _, key in ipairs(ATTRIBUTE_ORDER) do
        local value = config[key]
        if not IsWholeNumber(value) then
            return nil, string.format("%s must be a non-negative integer", key)
        end
        normalized[key] = value
    end

    local total = normalized.health + normalized.magicka + normalized.stamina
    if total > 64 then
        return nil, string.format("attribute total exceeds supported limit: %d", total)
    end

    return normalized
end

local function ResolveStatsManager()
    if type(IsInGamepadPreferredMode) == "function" and IsInGamepadPreferredMode() then
        if type(GAMEPAD_STATS) == "table" then
            return GAMEPAD_STATS
        end
    end

    if type(STATS) == "table" then
        return STATS
    end

    if type(GAMEPAD_STATS) == "table" then
        return GAMEPAD_STATS
    end

    return nil
end

local function IsGamepadStatsManager(statsManager)
    return type(statsManager) == "table"
        and type(statsManager.attributeData) == "table"
        and type(statsManager.SetAddedPoints) == "function"
end

local function PrepareGamepadStatsForAttributeRespec(statsManager)
    if not IsGamepadStatsManager(statsManager) then
        return true
    end

    if type(statsManager.PerformDeferredInitializationRoot) == "function" then
        local initOk, initErr = pcall(statsManager.PerformDeferredInitializationRoot, statsManager)
        if not initOk then
            return false, initErr
        end
    end

    if type(statsManager.RefreshMainList) == "function" then
        local refreshOk, refreshErr = pcall(statsManager.RefreshMainList, statsManager)
        if not refreshOk then
            return false, refreshErr
        end
    end

    if type(statsManager.SelectAttributes) == "function" then
        local selectOk, selectErr = pcall(statsManager.SelectAttributes, statsManager)
        if not selectOk then
            return false, selectErr
        end
    end

    if type(statsManager.UpdateScreenVisibility) == "function" then
        pcall(statsManager.UpdateScreenVisibility, statsManager)
    end

    return true
end

local function ResolvePaymentType(statsManager)
    if statsManager and type(statsManager.GetAttributeRespecPaymentType) == "function" then
        local ok, paymentType = pcall(statsManager.GetAttributeRespecPaymentType, statsManager)
        if ok and paymentType ~= nil then
            return paymentType
        end
    end

    if RESPEC_PAYMENT_TYPE_GOLD ~= nil then
        return RESPEC_PAYMENT_TYPE_GOLD
    end

    return nil
end

local function CheckPreconditions()
    if type(IsUnitInCombat) == "function" and IsUnitInCombat("player") then
        return false, "player is in combat"
    end

    return true
end

IsActivityDisallowedResult = function(result)
    return RESPEC_RESULT_DISALLOWED_IN_ACTIVITY ~= nil and result == RESPEC_RESULT_DISALLOWED_IN_ACTIVITY
end

-- Debug probe helpers
local function SnapshotAttributeState(statsManager)
    local sceneHelper = ResolveAttributeScene()
    if sceneHelper and type(sceneHelper.SnapshotAttributeState) == "function" then
        return sceneHelper:SnapshotAttributeState(statsManager)
    end

    return nil
end

-- Protected call helper
local function InvokeCoreCallable(stepLabel, fn, ...)
    if type(fn) ~= "function" then
        LogStep(stepLabel .. " missing callable")
        return false, ATTR_E_UNEXPECTED
    end

    local results = { pcall(fn, ...) }
    local callOk = table.remove(results, 1)
    if not callOk then
        LogStep(stepLabel .. " failed", tostring(results[1]))
        return false, ATTR_E_UNEXPECTED
    end

    return true, unpack(results)
end

-- Deferred orchestration
local function ContinueAttributeRespecEntry(context, startAttemptIndex, waitAttemptIndex)
    local pipelineContext = type(context) == "table" and context.pipelineContext or nil
    if IsContextInactive(context) then
        return
    end

    if type(pipelineContext) == "table" and pipelineContext.cancelRequested == true then
        FinishDeferredContextIfNeeded(context, ATTR_E_CANCELLED)
        return
    end

    context.startAttemptIndex = startAttemptIndex
    context.attemptIndex = waitAttemptIndex

    local statsManager = ResolveStatsManager()
    context.statsManager = statsManager

    if not statsManager then
        FinishAsyncContext(context, false, ATTR_E_MANAGER_MISSING)
        return
    end

    local snapshot = SnapshotAttributeState(statsManager)

    local sceneHelper = ResolveAttributeScene()
    if sceneHelper and sceneHelper:IsAttributeRespecReady(snapshot) then
        LogStep("Attribute auto-entry async continuing to core")
        local dispatchOk, dispatchErr = DispatchAttributeApplyCore(context, "async-ready")
        if dispatchOk == nil and dispatchErr == "deferred" then
            context.deferredPhase = true
            return
        end

        if dispatchOk == false and dispatchErr ~= nil then
            LogAttributeAutoEntrySummary("dispatch_failed", "error=" .. tostring(dispatchErr))
        end
        return
    end

    if waitAttemptIndex == 1 then
        if not (sceneHelper and sceneHelper:CanInvokeAttributeRespecStart(snapshot)) then
            if startAttemptIndex >= context.maxStartAttempts then
                FinishAsyncContext(context, false, ATTR_E_RESPEC_ENTRY_TIMEOUT)
                return
            end

            if type(zo_callLater) ~= "function" then
                FinishAsyncContext(context, false, ATTR_E_RESPEC_ENTRY_TIMEOUT)
                return
            end

            LogAttributeAutoEntrySummary(
                "start_deferred",
                "startAttempt=" .. tostring(startAttemptIndex),
                "delayMs=" .. tostring(context.startRetryDelayMs)
            )
            zo_callLater(function()
                ContinueAttributeRespecEntry(context, startAttemptIndex + 1, 1)
            end, context.startRetryDelayMs)
            return
        end

        if type(StartAttributeRespecFromUI) ~= "function" then
            FinishAsyncContext(context, false, ATTR_E_RESPEC_ENTRY_TIMEOUT)
            return
        end

        local prepareOk, prepareErr = PrepareGamepadStatsForAttributeRespec(statsManager)
        if not prepareOk then
            LogAttributeAutoEntrySummary("gamepad_prepare_failed", "error=" .. tostring(prepareErr))
            FinishAsyncContext(context, false, ATTR_E_RESPEC_ENTRY_TIMEOUT)
            return
        end

        local startOk, startErr = pcall(StartAttributeRespecFromUI)
        context.entryStartCount = (context.entryStartCount or 0) + 1
        if not startOk then
            LogAttributeAutoEntrySummary("start_failed", "error=" .. tostring(startErr))
            FinishAsyncContext(context, false, ATTR_E_RESPEC_ENTRY_TIMEOUT)
            return
        end
    end

    if waitAttemptIndex >= context.maxWaitAttempts then
        if startAttemptIndex >= context.maxStartAttempts then
            LogAttributeAutoEntrySummary(
                "timeout",
                "startAttempt=" .. tostring(startAttemptIndex),
                "waitAttempt=" .. tostring(waitAttemptIndex)
            )
            FinishAsyncContext(context, false, ATTR_E_RESPEC_ENTRY_TIMEOUT)
            return
        end

        if type(zo_callLater) ~= "function" then
            FinishAsyncContext(context, false, ATTR_E_RESPEC_ENTRY_TIMEOUT)
            return
        end

        LogAttributeAutoEntrySummary(
            "retry_start",
            "startAttempt=" .. tostring(startAttemptIndex),
            "nextStartAttempt=" .. tostring(startAttemptIndex + 1),
            "delayMs=" .. tostring(context.startRetryDelayMs)
        )
        zo_callLater(function()
            ContinueAttributeRespecEntry(context, startAttemptIndex + 1, 1)
        end, context.startRetryDelayMs)
        return
    end

    local nextWaitAttemptIndex = waitAttemptIndex + 1
    local delayMs = context.waitDelaysMs[nextWaitAttemptIndex] or context.waitDelaysMs[#context.waitDelaysMs] or 0
    if type(zo_callLater) ~= "function" then
        FinishAsyncContext(context, false, ATTR_E_RESPEC_ENTRY_TIMEOUT)
        return
    end

    zo_callLater(function()
        ContinueAttributeRespecEntry(context, startAttemptIndex, nextWaitAttemptIndex)
    end, delayMs)
end

local function BeginAttributeRespecEntry(context)
    LogAttributeAutoEntrySummary("begin")
    ContinueAttributeRespecEntry(context, 1, 1)
end

local function FindPhaseIndex(phases, phaseName)
    if type(phases) ~= "table" then
        return nil
    end

    for index, plannedPhaseName in ipairs(phases) do
        if plannedPhaseName == phaseName then
            return index
        end
    end

    return nil
end

local function ShouldUseSharedCooldownGate(context)
    local plan = type(context) == "table" and context.pipelinePlan or nil
    if type(plan) ~= "table" then
        return true
    end

    if plan.needsAttributeChange ~= true or plan.needsRespec ~= true then
        return false
    end

    local phases = plan.phases
    if type(phases) ~= "table" then
        return true
    end

    local attributeIndex = FindPhaseIndex(phases, "attribute_apply")
    if attributeIndex == nil then
        return false
    end

    local subclassIndex = FindPhaseIndex(phases, "subclass_apply")
    if subclassIndex ~= nil and subclassIndex < attributeIndex then
        return true
    end

    local skillIndex = FindPhaseIndex(phases, "skill_apply")
    return skillIndex ~= nil and skillIndex < attributeIndex
end

local function BeginSharedCooldownGateWait(context, continuation)
    if not ShouldUseSharedCooldownGate(context) then
        return false
    end

    local gate = ResolveApplyCooldownGate()
    if gate == nil or type(gate.GetRemainingDelayMs) ~= "function" then
        return false
    end

    local remainingMs = gate:GetRemainingDelayMs("attribute", SHARED_UTIL:GetFrameTimeMillisecondsSafe())
    if type(remainingMs) ~= "number" or remainingMs <= 0 then
        return false
    end

    if type(zo_callLater) ~= "function" then
        return false, "zo_callLater_unavailable"
    end

    context.sharedCooldownWaitGeneration = (context.sharedCooldownWaitGeneration or 0) + 1
    local generation = context.sharedCooldownWaitGeneration
    LTM_ATTRIBUTE_APPLY.pendingContext = context

    if type(LTM) == "table" and type(LTM.NotifyWaitStarted) == "function" then
        LTM:NotifyWaitStarted(context, "attribute_retry", remainingMs / 1000)
    end
    LogAttributeRetrySummary("gate_wait", "delayMs=" .. tostring(remainingMs))

    zo_callLater(function()
        local pipelineContext = type(context) == "table" and context.pipelineContext or nil
        if LTM_ATTRIBUTE_APPLY.pendingContext ~= context or context.finished then
            return
        end

        if type(pipelineContext) == "table" and pipelineContext.cancelRequested == true then
            FinishDeferredContextIfNeeded(context, ATTR_E_CANCELLED)
            return
        end

        if context.sharedCooldownWaitGeneration ~= generation then
            return
        end

        if type(LTM) == "table" and type(LTM.ResetWaitNotification) == "function" then
            LTM:ResetWaitNotification(context)
        end
        continuation(context)
    end, remainingMs)

    return true, "deferred"
end

local function EnsureStatsSceneReadyOrDefer(context)
    local snapshot = SnapshotAttributeState(context.statsManager)
    local sceneHelper = ResolveAttributeScene()
    if sceneHelper and sceneHelper:IsStatsSceneReady(snapshot) then
        return true
    end

    local candidates = sceneHelper and sceneHelper:BuildStatsSceneOpenCandidates() or {}
    local openInvoked = false
    for _, candidate in ipairs(candidates) do
        if sceneHelper and sceneHelper:InvokeStatsSceneOpenCandidate(candidate) then
            openInvoked = true
            break
        end
    end

    if not openInvoked then
        return false, ATTR_E_SCENE_READY_TIMEOUT
    end

    if type(zo_callLater) ~= "function" then
        return false, ATTR_E_SCENE_READY_TIMEOUT
    end

    context.sceneRetryDelaysMs = STATS_SCENE_READY_RETRY_DELAYS_MS
    context.maxSceneAttempts = #STATS_SCENE_READY_RETRY_DELAYS_MS

    local function ContinueStatsSceneReady(attemptIndex)
        if context.finished then
            return
        end

        local statsManager = ResolveStatsManager()
        context.statsManager = statsManager

        if not statsManager then
            FinishAsyncContext(context, false, ATTR_E_MANAGER_MISSING)
            return
        end

        local currentSnapshot = SnapshotAttributeState(statsManager)
        if sceneHelper and sceneHelper:IsStatsSceneReady(currentSnapshot) then
            LogAttributeAutoEntrySummary("stats_scene_ready")
            local interactionOk, interactionErr = EnsureRespecInteractionOrDefer(context)
            if interactionOk == nil and interactionErr == "deferred" then
                return
            end

            if not interactionOk then
                FinishAsyncContext(context, false, interactionErr)
                return
            end

            local dispatchOk, dispatchErr = DispatchAttributeApplyCore(context, "async-ready")
            if dispatchOk == nil and dispatchErr == "deferred" then
                context.deferredPhase = true
                return
            end

            if dispatchOk == false and dispatchErr ~= nil then
                LogAttributeAutoEntrySummary("dispatch_failed", "error=" .. tostring(dispatchErr))
            end
            return
        end

        if attemptIndex >= context.maxSceneAttempts then
            FinishAsyncContext(context, false, ATTR_E_SCENE_READY_TIMEOUT)
            return
        end

        local nextAttemptIndex = attemptIndex + 1
        local delayMs = context.sceneRetryDelaysMs[nextAttemptIndex] or context.sceneRetryDelaysMs[#context.sceneRetryDelaysMs] or 0
        zo_callLater(function()
            ContinueStatsSceneReady(nextAttemptIndex)
        end, delayMs)
    end

    zo_callLater(function()
        ContinueStatsSceneReady(1)
    end, context.sceneRetryDelaysMs[1] or 0)
    return nil, "deferred"
end

LogAsyncAttempt = function(context, snapshot)
    if context.attemptIndex == 1 then
        LogStep("Attribute auto-entry attempt begin")
    end
end

local function StartAttributeExecution(context)
    LogStep("Attribute phase: ensure stats scene")
    local sceneOk, sceneErr = EnsureStatsSceneReadyOrDefer(context)
    if sceneOk == nil and sceneErr == "deferred" then
        context.deferredPhase = true
        LTM_ATTRIBUTE_APPLY.pendingContext = context
        return true, "deferred"
    end

    if not sceneOk then
        return FailStartAttributeExecution(context, sceneErr, ATTR_E_SCENE_READY_TIMEOUT)
    end

    LogStep("Attribute phase: ensure respec interaction")
    local interactionOk, interactionErr = EnsureRespecInteractionOrDefer(context)
    if interactionOk == nil and interactionErr == "deferred" then
        context.deferredPhase = true
        LTM_ATTRIBUTE_APPLY.pendingContext = context
        return true, "deferred"
    end

    if not interactionOk then
        return FailStartAttributeExecution(context, interactionErr, ATTR_E_RESPEC_ENTRY_TIMEOUT)
    end

    LogStep("Attribute interaction ready path dispatching core")
    local applyOk, applyErr = DispatchAttributeApplyCore(context, "direct-ready")
    if applyOk == nil and applyErr == "deferred" then
        LTM_ATTRIBUTE_APPLY.pendingContext = context
        context.deferredPhase = true
        return true, "deferred"
    end

    if not applyOk then
        return false, applyErr
    end

    return true
end

-- Completion / core dispatch
FinishAsyncContext = function(context, ok, err)
    if context.finished then
        return ok, err
    end

    ClearResultWaitRegistration(context)
    LTM_ATTRIBUTE_APPLY.pendingContext = nil
    context.retryScheduled = false
    if type(LTM) == "table" and type(LTM.ResetWaitNotification) == "function" then
        LTM:ResetWaitNotification(context)
    end

    if ok then
        local resultOk, resultErr = SucceedContext(context)
        LTM_ATTRIBUTE_APPLY:NotifyPipelineContinuation(context, true)
        return resultOk, resultErr
    end

    local resultOk, resultErr = FailContext(context, err, nil, "async_finish")
    LTM_ATTRIBUTE_APPLY:NotifyPipelineContinuation(context, false)
    return resultOk, resultErr
end

BeginAttributeResultWait = function(context)
    local armOk, generationOrErr = ArmAttributeResultWait(context)
    if not armOk then
        return false, generationOrErr
    end

    return StartAttributeResultWaitPolling(context, generationOrErr)
end

SendAttributeCommitAttempt = function(context)
    if IsContextInactive(context) then
        return false, ATTR_E_UNEXPECTED
    end

    local statsManager = context.statsManager or select(1, ResolveStatsManager())
    if not statsManager then
        return false, ATTR_E_MANAGER_MISSING
    end

    context.statsManager = statsManager

    local paymentType = context.paymentType or ResolvePaymentType(statsManager)
    if paymentType == nil then
        return false, ATTR_E_FINALIZE_REQUEST_FAILED
    end

    context.paymentType = paymentType
    context.commitAttempt = (context.commitAttempt or 0) + 1

    local armOk, generationOrErr = ArmAttributeResultWait(context)
    if not armOk then
        return false, ATTR_E_RESULT_WAIT_REGISTER_FAILED
    end

    local stepOk, finalizeOk = InvokeCoreCallable(
        "Attribute core step10",
        FinalizeAllocation,
        statsManager,
        paymentType,
        context.runId,
        context.commitAttempt
    )
    if not stepOk or not finalizeOk then
        ClearResultWaitRegistration(context)
        return false, ATTR_E_FINALIZE_REQUEST_FAILED
    end

    context.commitSent = true

    local waitOk = StartAttributeResultWaitPolling(context, generationOrErr)
    if not waitOk then
        ClearResultWaitRegistration(context)
        return false, ATTR_E_RESULT_WAIT_REGISTER_FAILED
    end

    return true
end

local function RunAttributeApplyCore(context)
    if context.commitSent then
        return nil, "deferred"
    end

    local statsManager = context.statsManager or select(1, ResolveStatsManager())
    if not statsManager then
        return FinishAsyncContext(context, false, ATTR_E_MANAGER_MISSING)
    end

    context.statsManager = statsManager

    local step3Ok, batchOk, batchState = InvokeCoreCallable("Attribute core step3", EnableBatchMode, statsManager)
    if not step3Ok then
        return FinishAsyncContext(context, false, ATTR_E_UNEXPECTED)
    end
    if not batchOk then
        return FinishAsyncContext(context, false, ATTR_E_UNEXPECTED)
    end

    local step4Ok, clearCandidates = InvokeCoreCallable("Attribute core step4", SearchClearCandidates, statsManager)
    if not step4Ok then
        return FinishAsyncContext(context, false, ATTR_E_CLEAR_FAILED)
    end
    if not ((clearCandidates.keyboard_controls and clearCandidates.set_added_points_by_total)
        or (clearCandidates.gamepad_data and clearCandidates.set_gamepad_added_points)) then
        LogStep("Attribute spinner controls unavailable")
        return FinishAsyncContext(context, false, ATTR_E_CLEAR_FAILED)
    end

    LogStep("Attribute phase: clear current allocation")
    local step6Ok, clearOk, clearErr = InvokeCoreCallable("Attribute core step6", ClearCurrentAllocation, statsManager)
    if not step6Ok then
        return FinishAsyncContext(context, false, ATTR_E_CLEAR_FAILED)
    end
    if not clearOk then
        LogStep("Attribute clear current allocation failed")
        return FinishAsyncContext(context, false, ATTR_E_CLEAR_FAILED)
    end

    LogStep("Attribute phase: allocate target values")
    local step8Ok, allocateOk, allocateErr = InvokeCoreCallable("Attribute core step8", AllocateTargetValues, statsManager, context.target)
    if not step8Ok then
        return FinishAsyncContext(context, false, ATTR_E_ALLOCATE_FAILED)
    end
    if not allocateOk then
        return FinishAsyncContext(context, false, ATTR_E_ALLOCATE_FAILED)
    end

    LogStep("Attribute phase: finalize")
    local paymentType = ResolvePaymentType(statsManager)
    if paymentType == nil then
        return FinishAsyncContext(context, false, ATTR_E_FINALIZE_REQUEST_FAILED)
    end
    context.paymentType = paymentType

    LogStep("Attribute commit mode: immediate")
    local commitOk, commitErr = SendAttributeCommitAttempt(context)
    if not commitOk then
        LogStep("Attribute finalize immediate commit failed", tostring(commitErr))
        return FinishAsyncContext(context, false, commitErr)
    end

    return nil, "deferred"
end

DispatchAttributeApplyCore = function(context, sourceLabel)
    if context.finished then
        return false, ATTR_E_UNEXPECTED
    end

    if sourceLabel == "async-ready" and LTM_ATTRIBUTE_APPLY.pendingContext ~= context then
        return false, ATTR_E_UNEXPECTED
    end

    if type(context.statsManager) ~= "table" then
        return false, ATTR_E_MANAGER_MISSING
    end

    local ok, resultOk, resultErr = pcall(RunAttributeApplyCore, context)
    if not ok then
        LogStep("Attribute core dispatch failed", tostring(resultOk))
        return FinishAsyncContext(context, false, ATTR_E_UNEXPECTED)
    end

    return resultOk, resultErr
end

EnsureRespecInteractionOrDefer = function(context)
    local beforeContext = SnapshotAttributeState(context.statsManager)
    local sceneHelper = ResolveAttributeScene()

    local interactionOk = sceneHelper and sceneHelper:GetCurrentRespecInteractionState() or false
    if interactionOk then
        LogStep("Entered attribute respec interaction")
        return true
    end

    if sceneHelper and sceneHelper:IsAttributeRespecReady(beforeContext) then
        return true
    end

    if not sceneHelper then
        return false, ATTR_E_RESPEC_ENTRY_TIMEOUT
    end

    context.waitDelaysMs = AUTO_ENTRY_RETRY_DELAYS_MS
    context.maxWaitAttempts = #AUTO_ENTRY_RETRY_DELAYS_MS
    context.startRetryDelayMs = AUTO_ENTRY_START_RETRY_DELAY_MS
    context.maxStartAttempts = AUTO_ENTRY_MAX_START_ATTEMPTS
    BeginAttributeRespecEntry(context)
    return nil, "deferred"
end

-- Core apply helpers
EnableBatchMode = function(statsManager)
    local hasSetMode = statsManager and type(statsManager.SetAttributePointAllocationMode) == "function"
    if not hasSetMode then
        return true, "skipped"
    end

    local modeValue = nil

    if ATTRIBUTE_POINT_ALLOCATION_MODE_PURCHASE_FULL ~= nil then
        modeValue = ATTRIBUTE_POINT_ALLOCATION_MODE_PURCHASE_FULL
    end

    if modeValue == nil then
        return true, "skipped"
    end

    local targetObject = statsManager
    local targetMethod = targetObject and targetObject.SetAttributePointAllocationMode or nil

    if type(targetMethod) ~= "function" then
        return false, "target method missing: SetAttributePointAllocationMode"
    end

    local ok, err = pcall(function()
        targetMethod(targetObject, modeValue)
    end)
    if not ok then
        return true, "skipped"
    end

    return true, "enabled"
end

FindKeyboardSpinner = function(statsManager, attributeType)
    local sceneHelper = ResolveAttributeScene()
    if sceneHelper and type(sceneHelper.FindKeyboardSpinner) == "function" then
        return sceneHelper:FindKeyboardSpinner(statsManager, attributeType)
    end

    return nil, nil
end

SearchClearCandidates = function(statsManager)
    local sceneHelper = ResolveAttributeScene()
    if sceneHelper and type(sceneHelper.SearchClearCandidates) == "function" then
        return sceneHelper:SearchClearCandidates(statsManager)
    end

    return {
        keyboard_controls = false,
        gamepad_data = false,
        reset_added_points = false,
        set_added_points_by_total = false,
        set_gamepad_added_points = false,
    }
end

ClearCurrentAllocation = function(statsManager)
    local candidates = SearchClearCandidates(statsManager)
    if candidates.gamepad_data and candidates.set_gamepad_added_points then
        for _, key in ipairs(ATTRIBUTE_ORDER) do
            local attributeType = ATTRIBUTE_TYPES[key]
            local ok, err = pcall(statsManager.SetAddedPoints, statsManager, attributeType, 0)
            if not ok then
                return false, err
            end
        end

        if type(statsManager.UpdateSpendablePoints) == "function" then
            pcall(statsManager.UpdateSpendablePoints, statsManager)
        end

        return true
    end

    if not candidates.keyboard_controls or not candidates.set_added_points_by_total then
        return false, "clear path unresolved"
    end

    for _, key in ipairs(ATTRIBUTE_ORDER) do
        local attributeType = ATTRIBUTE_TYPES[key]
        local spinner, control = FindKeyboardSpinner(statsManager, attributeType)
        if not spinner or type(spinner.SetAddedPointsByTotalPoints) ~= "function" then
            return false, "clear spinner missing for " .. key
        end

        local ok, err = pcall(spinner.SetAddedPointsByTotalPoints, spinner, 0)
        if not ok then
            return false, err
        end

        if type(spinner.RefreshSpinnerMax) == "function" then
            pcall(spinner.RefreshSpinnerMax, spinner)
        end

        if spinner.pointsSpinner and type(spinner.pointsSpinner.SetValue) == "function" then
            pcall(spinner.pointsSpinner.SetValue, spinner.pointsSpinner, 0)
        end
    end

    if type(statsManager.UpdateSpendablePoints) == "function" then
        pcall(statsManager.UpdateSpendablePoints, statsManager)
    end

    return true
end

local function BuildGamepadAllocationDeltas(target)
    local deltas = {}
    for _, key in ipairs(ATTRIBUTE_ORDER) do
        local attributeType = ATTRIBUTE_TYPES[key]
        deltas[#deltas + 1] = {
            key = key,
            attributeType = attributeType,
            delta = (target[key] or 0) - (GetAttributeSpentPointsSafe(attributeType) or 0),
        }
    end

    return deltas
end

local function ApplyGamepadAllocationDeltas(statsManager, deltas, predicate)
    for _, entry in ipairs(deltas) do
        if predicate(entry.delta) then
            local ok, err = pcall(statsManager.SetAddedPoints, statsManager, entry.attributeType, entry.delta)
            if not ok then
                return false, err
            end
        end
    end

    return true
end

AllocateTargetValues = function(statsManager, target)
    if IsGamepadStatsManager(statsManager) then
        local deltas = BuildGamepadAllocationDeltas(target)
        local decreaseOk, decreaseErr = ApplyGamepadAllocationDeltas(statsManager, deltas, function(delta)
            return type(delta) == "number" and delta < 0
        end)
        if not decreaseOk then
            return false, decreaseErr
        end

        local increaseOk, increaseErr = ApplyGamepadAllocationDeltas(statsManager, deltas, function(delta)
            return type(delta) == "number" and delta >= 0
        end)
        if not increaseOk then
            return false, increaseErr
        end

        if type(statsManager.UpdateSpendablePoints) == "function" then
            pcall(statsManager.UpdateSpendablePoints, statsManager)
        end

        return true
    end

    for _, key in ipairs(ATTRIBUTE_ORDER) do
        local attributeType = ATTRIBUTE_TYPES[key]
        local spinner, control = FindKeyboardSpinner(statsManager, attributeType)
        if not spinner or type(spinner.SetAddedPointsByTotalPoints) ~= "function" then
            return false, "allocation spinner missing for " .. key
        end

        local ok, err = pcall(spinner.SetAddedPointsByTotalPoints, spinner, target[key])
        if not ok then
            return false, err
        end

        if type(spinner.RefreshSpinnerMax) == "function" then
            pcall(spinner.RefreshSpinnerMax, spinner)
        end

        if spinner.pointsSpinner and type(spinner.pointsSpinner.SetValue) == "function" then
            pcall(spinner.pointsSpinner.SetValue, spinner.pointsSpinner, target[key])
        end
    end

    if type(statsManager.UpdateSpendablePoints) == "function" then
        pcall(statsManager.UpdateSpendablePoints, statsManager)
    end

    return true
end

BuildAllocationDeltaFromSpinners = function(statsManager)
    if IsGamepadStatsManager(statsManager) then
        return {
            health = GetGamepadAddedPoints(statsManager, ATTRIBUTE_HEALTH),
            magicka = GetGamepadAddedPoints(statsManager, ATTRIBUTE_MAGICKA),
            stamina = GetGamepadAddedPoints(statsManager, ATTRIBUTE_STAMINA),
        }
    end

    local delta = {
        health = nil,
        magicka = nil,
        stamina = nil,
    }

    for _, key in ipairs(ATTRIBUTE_ORDER) do
        local attributeType = ATTRIBUTE_TYPES[key]
        local spinner = FindKeyboardSpinner(statsManager, attributeType)
        if not spinner or type(spinner.GetAllocatedPoints) ~= "function" then
            return nil, "allocated points unavailable for " .. key
        end

        delta[key] = spinner:GetAllocatedPoints()
    end

    return delta
end

FinalizeAllocation = function(statsManager, paymentType, runId, attempt)
    local hasRespecMethod = statsManager and type(statsManager.RespecAttributes) == "function"
    local hasAllocationRequest = type(SendAttributePointAllocationRequest) == "function"

    if hasRespecMethod then
        local ok, err = pcall(statsManager.RespecAttributes, statsManager)
        if ok then
            return true
        end
        LogCommitTrace("Attribute commit request failed", "path=statsManager:RespecAttributes", "error=" .. tostring(err))
    end

    if not hasAllocationRequest then
        return false, "finalize API unavailable"
    end

    local delta, deltaErr = BuildAllocationDeltaFromSpinners(statsManager)
    if not delta then
        return false, deltaErr
    end

    local ok, err = pcall(
        SendAttributePointAllocationRequest,
        paymentType,
        delta.health,
        delta.magicka,
        delta.stamina
    )
    if not ok then
        LogCommitTrace("Attribute commit request failed", "path=SendAttributePointAllocationRequest", "error=" .. tostring(err))
        return false, err
    end

    return true
end

function LTM_ATTRIBUTE_APPLY:Run(config)
    ATTRIBUTE_RUN_SEQUENCE = ATTRIBUTE_RUN_SEQUENCE + 1
    local runId = tostring(ATTRIBUTE_RUN_SEQUENCE)

    local target, attrErr = NormalizeAttributes(config)
    if not target then
        return FailContext(nil, attrErr, ATTR_E_UNEXPECTED, "config")
    end

    LogStep("Attribute phase begin")

    local preconditionsOk, preconditionErr = CheckPreconditions()
    if not preconditionsOk then
        LogDebugSummary("Attribute precondition detail", "error=" .. tostring(preconditionErr))
        return FailContext(nil, ATTR_E_UNEXPECTED, nil, "precondition")
    end

    local statsManager = ResolveStatsManager()
    if not statsManager then
        return FailContext(nil, ATTR_E_MANAGER_MISSING, nil, "run_start")
    end

    if self.pendingContext and not self.pendingContext.finished then
        return FailContext(nil, ATTR_E_UNEXPECTED, nil, "run_start")
    end

    local context = {
        runId = runId,
        target = target,
        statsManager = statsManager,
        pipelineContext = config._pipelineContext,
        pipelinePlan = config._pipelinePlan,
        finished = false,
        attemptIndex = 0,
        pipelineContinuation = config._pipelineContinuation,
        entryStarted = false,
        commitSent = false,
        commitAttempt = 0,
        retryScheduled = false,
        castStarted = false,
        castStartedAt = nil,
        commitTimerGeneration = 0,
        completionResolved = false,
        continuationCalled = false,
    }

    local gateOk, gateErr = BeginSharedCooldownGateWait(context, StartAttributeExecution)
    if gateOk == true and gateErr == "deferred" then
        context.deferredPhase = true
        return true, "deferred"
    end

    if gateOk == false and gateErr ~= nil then
        return FailContext(context, gateErr, ATTR_E_UNEXPECTED, "shared_cooldown_gate")
    end

    return StartAttributeExecution(context)
end
