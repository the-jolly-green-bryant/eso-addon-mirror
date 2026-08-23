local Addon = LarvalTearMod
local LTM = Addon
local M = Addon.Modules.SkillRespecCompletion
local logging = Addon.Modules.SkillRespecLogging
local SHARED_UTIL = Addon.Common.Util
local CONSTANTS = Addon.Modules.SkillRespecConstants

local ROUTE_B_COMPLETION_POLL_MS = CONSTANTS.ROUTE_B_COMPLETION_POLL_MS
local ROUTE_B_COMPLETION_MAX_ATTEMPTS = CONSTANTS.ROUTE_B_COMPLETION_MAX_ATTEMPTS
local RESULT_EVENT_NAMESPACE = "LTM_SkillRespecApply_Result"
local ROUTE_B_CAST_EVENT_NAMESPACE = "LTM_SkillRespecApply_RouteB_Cast"

function M:GetResultEventNamespace()
    return RESULT_EVENT_NAMESPACE
end

function M:GetRouteBCastEventNamespace()
    return ROUTE_B_CAST_EVENT_NAMESPACE
end

function M:IsSkillRespecCastDialogShowing()
    if type(ZO_Dialogs_IsShowing) ~= "function" then
        return false
    end

    local keyboardShowing = ZO_Dialogs_IsShowing("SKILL_RESPEC_CAST_KEYBOARD")
    local gamepadShowing = ZO_Dialogs_IsShowing("SKILL_RESPEC_CAST_GAMEPAD")
    local keyboardHiding = type(ZO_Dialogs_IsDialogHiding) == "function"
        and ZO_Dialogs_IsDialogHiding("SKILL_RESPEC_CAST_KEYBOARD")
        or false
    local gamepadHiding = type(ZO_Dialogs_IsDialogHiding) == "function"
        and ZO_Dialogs_IsDialogHiding("SKILL_RESPEC_CAST_GAMEPAD")
        or false

    return (keyboardShowing and not keyboardHiding) or (gamepadShowing and not gamepadHiding)
end

function M:GetSkillRespecCastTimeRemainingMsSafe()
    if type(GetSkillRespecCastTimeRemainingMs) == "function" then
        return GetSkillRespecCastTimeRemainingMs()
    end

    return nil
end

function M:IsRouteBContextInactive(context)
    return context == nil or context.finished or context.completionResolved == true
end

function M:MarkRouteBCompletionResolved(context, success, reason)
    if type(context) ~= "table" then
        return
    end

    context.completionResolved = true
    context.resultWaitGeneration = (context.resultWaitGeneration or 0) + 1
end

function M:ResolveRouteBCompletionSuccess(apply, context, snapshot, successKind)
    self:MarkRouteBCompletionResolved(context, true, successKind)
    logging.Log("Route B completion observed kind=" .. tostring(successKind))
    if context.subclassOnlyMode == true then
        apply:FinalizeRouteBSuccess(context)
        return
    end

    apply:BeginRouteBPostCommitVerifyRetry(context, snapshot, successKind)
end

function M:ResolveRouteBCompletionFailure(apply, context, reason, details)
    self:MarkRouteBCompletionResolved(context, false, reason)
    logging.Log(
        "Route B completion failure",
        "reason=" .. tostring(reason),
        "attempt=" .. tostring(type(context) == "table" and context.completionAttemptIndex or 0),
        "result=" .. tostring(type(context) == "table" and context.resultCode or nil),
        "acceptanceSource=" .. tostring(type(context) == "table" and context.commitAcceptanceSource or nil)
    )
    apply:FinalizeRouteBFailure(context, reason, details)
end

function M:BuildRouteBCompletionSnapshot(context)
    local allocationMode = type(SKILLS_AND_ACTION_BAR_MANAGER) == "table"
        and type(SKILLS_AND_ACTION_BAR_MANAGER.GetSkillPointAllocationMode) == "function"
        and SKILLS_AND_ACTION_BAR_MANAGER:GetSkillPointAllocationMode()
        or nil

    return {
        interactionType = type(GetInteractionType) == "function" and GetInteractionType() or nil,
        allocationMode = allocationMode,
        castStarted = context.castStarted == true,
        castRemainingMs = self:GetSkillRespecCastTimeRemainingMsSafe(),
        castDialogShowing = self:IsSkillRespecCastDialogShowing(),
        resultReceived = context.resultReceived == true,
        resultCode = context.resultCode,
        commitSent = context.commitSent == true,
        verifyMatched = context.verifyMatched == true,
        elapsedSinceVerifyMs = context.verifyMatchedAt ~= nil and (SHARED_UTIL:GetFrameTimeMillisecondsSafe() - context.verifyMatchedAt) or nil,
    }
end

function M:IsRouteBCompletionSuccess(context, snapshot)
    if type(snapshot) ~= "table" or snapshot.commitSent ~= true or snapshot.verifyMatched ~= true then
        return false, nil
    end

    if context.subclassOnlyMode == true then
        if snapshot.resultCode == RESPEC_RESULT_SUCCESS then
            return true, "resultCode"
        end

        if context.commitAcceptanceSource ~= "cast_dialog"
            or snapshot.castDialogShowing == true
            or type(snapshot.castRemainingMs) ~= "number"
            or snapshot.castRemainingMs > 0 then
            return false, nil
        end

        return true, "castEnd"
    end

    if snapshot.resultCode == RESPEC_RESULT_SUCCESS then
        return true, "resultCode"
    end

    if snapshot.castDialogShowing then
        return false, nil
    end

    if snapshot.castRemainingMs ~= nil and snapshot.castRemainingMs > 0 then
        return false, nil
    end

    if snapshot.castStarted then
        return true, "castEnd"
    end

    if snapshot.allocationMode == 0 then
        return true, "allocationMode"
    end

    if INTERACTION_SKILL_RESPEC ~= nil and snapshot.interactionType ~= INTERACTION_SKILL_RESPEC then
        return true, "interactionEnd"
    end

    return false, nil
end

function M:PollRouteBCompletion(apply, context, generation)
    if apply.pendingContext ~= context or self:IsRouteBContextInactive(context) then
        return
    end

    if generation ~= nil and context.resultWaitGeneration ~= generation then
        return
    end

    context.completionAttemptIndex = (context.completionAttemptIndex or 0) + 1

    local snapshot = self:BuildRouteBCompletionSnapshot(context)

    local success, successKind = self:IsRouteBCompletionSuccess(context, snapshot)
    if success then
        self:ResolveRouteBCompletionSuccess(apply, context, snapshot, successKind)
        return
    end

    if context.completionAttemptIndex >= ROUTE_B_COMPLETION_MAX_ATTEMPTS then
        self:ResolveRouteBCompletionFailure(apply, context, "route_b_completion_timeout", {
            result = context.resultCode,
            verify = context.verifyResult,
            completion = snapshot,
        })
        return
    end

    zo_callLater(function()
        M:PollRouteBCompletion(apply, context, generation)
    end, ROUTE_B_COMPLETION_POLL_MS)
end

function M:BeginRouteBCompletionWait(apply, context, snapshot)
    if apply.pendingContext ~= context or self:IsRouteBContextInactive(context) then
        return
    end

    if context.completionArmed == true then
        return
    end

    context.verifyMatched = true
    context.verifyMatchedAt = SHARED_UTIL:GetFrameTimeMillisecondsSafe()
    context.completionArmed = true
    context.verifiedState = snapshot.currentState
    context.verifyResult = snapshot.verifyResult
    context.verifyCurrentSkillLineIds = snapshot.currentSkillLineIds
    context.verifyTargetSkillLineIds = snapshot.targetSkillLineIds

    context.resultWaitGeneration = (context.resultWaitGeneration or 0) + 1
    logging.Log(
        "Route B completion begin",
        "acceptanceSource=" .. tostring(context.commitAcceptanceSource),
        "verifyMatched=" .. tostring(context.verifyMatched == true)
    )
    self:PollRouteBCompletion(apply, context, context.resultWaitGeneration)
end

function M:OnRouteBResultEvent(apply, context, result)
    if apply.pendingContext ~= context or self:IsRouteBContextInactive(context) then
        return
    end

    context.resultReceived = true
    context.resultCode = result

    if RESPEC_RESULT_DISALLOWED_IN_ACTIVITY ~= nil and result == RESPEC_RESULT_DISALLOWED_IN_ACTIVITY then
        LTM:NotifyActivityDisallowed("class_skills")
        apply:FinalizeRouteBFailure(context, "activity_disallowed", {
            result = result,
            targetSkillLineIds = context.plan and context.plan.targetSkillLineIds or nil,
        })
        return
    end

    if result ~= RESPEC_RESULT_SUCCESS then
        if context.commitAccepted ~= true
            and type(apply.IsRouteBCommitRetryableResult) == "function"
            and apply:IsRouteBCommitRetryableResult(result) then
            apply:ScheduleRouteBCommitRetry(context, "result_code", {
                result = result,
                targetSkillLineIds = context.plan and context.plan.targetSkillLineIds or nil,
            })
            return
        end

        self:ResolveRouteBCompletionFailure(apply, context, "route_b_result_failed", {
            result = result,
            targetSkillLineIds = context.plan and context.plan.targetSkillLineIds or nil,
        })
        return
    end

    if type(apply.MarkRouteBCommitAccepted) == "function" then
        apply:MarkRouteBCommitAccepted(context, "result_event")
    end

    if context.completionArmed == true then
        self:PollRouteBCompletion(apply, context, context.resultWaitGeneration)
        return
    end

    apply:KickOffRouteBPostCommitVerify(context, "result_event")
end

function M:OnRouteBCastEvent(apply, context)
    if apply.pendingContext ~= context or self:IsRouteBContextInactive(context) then
        return
    end

    context.castStarted = true
    context.castStartedAt = SHARED_UTIL:GetFrameTimeMillisecondsSafe()
    if type(apply.MarkRouteBCommitAccepted) == "function" then
        apply:MarkRouteBCommitAccepted(context, "cast_event")
    end

    if context.completionArmed == true then
        self:PollRouteBCompletion(apply, context, context.resultWaitGeneration)
    end
end

function M:RegisterRouteBResultWait(apply, context)
    local eventManager = SHARED_UTIL:GetEventManager()
    if eventManager == nil then
        apply:FinalizeRouteBFailure(context, "event_manager_unavailable")
        return false
    end

    if EVENT_SKILL_RESPEC_RESULT == nil then
        apply:FinalizeRouteBFailure(context, "event_skill_respec_result_unavailable")
        return false
    end

    if type(eventManager.RegisterForEvent) ~= "function" or type(eventManager.UnregisterForEvent) ~= "function" then
        apply:FinalizeRouteBFailure(context, "event_manager_register_for_event_unavailable")
        return false
    end

    eventManager:UnregisterForEvent(RESULT_EVENT_NAMESPACE, EVENT_SKILL_RESPEC_RESULT)
    eventManager:RegisterForEvent(RESULT_EVENT_NAMESPACE, EVENT_SKILL_RESPEC_RESULT, function(_, result)
        M:OnRouteBResultEvent(apply, context, result)
    end)

    if EVENT_START_SKILL_RESPEC_CAST ~= nil then
        eventManager:UnregisterForEvent(ROUTE_B_CAST_EVENT_NAMESPACE, EVENT_START_SKILL_RESPEC_CAST)
        eventManager:RegisterForEvent(ROUTE_B_CAST_EVENT_NAMESPACE, EVENT_START_SKILL_RESPEC_CAST, function()
            M:OnRouteBCastEvent(apply, context)
        end)
    end
    return true
end
