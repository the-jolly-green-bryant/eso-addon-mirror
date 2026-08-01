local Addon = LarvalTearMod
local LTM_ATTRIBUTE_RETRY = Addon.Modules.AttributeRetry

local ATTRIBUTE_COMMIT_RETRY_INTERVAL_MS = 2000
local ATTRIBUTE_COMMIT_MAX_ATTEMPTS = 5
local ATTRIBUTE_RESULT_75_RETRY_CODE = 75

function LTM_ATTRIBUTE_RETRY:GetCommitRetryIntervalMs()
    return ATTRIBUTE_COMMIT_RETRY_INTERVAL_MS
end

function LTM_ATTRIBUTE_RETRY:IsBusyRetryableResult(resultCode)
    return resultCode == ATTRIBUTE_RESULT_75_RETRY_CODE
end

function LTM_ATTRIBUTE_RETRY:IsRetrySchedulingBlocked(context)
    return context == nil
        or context.finished == true
        or context.completionResolved == true
        or context.retryScheduled == true
        or context.castStarted == true
end

function LTM_ATTRIBUTE_RETRY:IsRetryExhausted(context)
    return (context and context.commitAttempt or 0) >= ATTRIBUTE_COMMIT_MAX_ATTEMPTS
end

function LTM_ATTRIBUTE_RETRY:BuildRetrySummary(reason, context, delayMs)
    return {
        status = "scheduled",
        delayMs = delayMs,
        nextAttempt = tostring((context and context.commitAttempt or 0) + 1),
    }
end
