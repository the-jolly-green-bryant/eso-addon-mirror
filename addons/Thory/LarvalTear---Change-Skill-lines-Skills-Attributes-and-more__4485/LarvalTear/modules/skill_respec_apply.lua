local Addon = LarvalTearMod
local LTM = Addon
local Log = Addon.Common.Log
local LTM_SKILL_RESPEC_APPLY = Addon.Modules.SkillRespecApply
local LTM_APPLY_START_STATE = Addon.Modules.ApplyStartState
local LTM_APPLY_COOLDOWN_GATE = Addon.Modules.ApplyCooldownGate
local SHARED_UTIL = Addon.Common.Util
local LTM_ACTIVE_SKILL_RESTORE = Addon.Modules.ActiveSkillRestore
local LTM_PIPELINE_CONTEXT = Addon.Modules.PipelineContext
local LTM_SKILL_PASSIVE_APPLY = Addon.Modules.SkillPassiveApply
local LTM_PASSIVE_SNAPSHOT_APPLY = Addon.Modules.PassiveSnapshotApply
local LTM_SKILL_RESTORE = Addon.Modules.SkillRestore
local LTM_SKILL_RESPEC_CLASS_MASTERY_REDUCE = Addon.Modules.SkillRespecClassMasteryReduce
local LTM_SKILL_RESPEC_CLASS_MASTERY_PURCHASE = Addon.Modules.SkillRespecClassMasteryPurchase
local LTM_SKILL_RESPEC_CONSTANTS = Addon.Modules.SkillRespecConstants
local LTM_SKILL_RESPEC_COMPLETION = Addon.Modules.SkillRespecCompletion
local logging = Addon.Modules.SkillRespecLogging
local LTM_SKILL_RESPEC_MORPH = Addon.Modules.SkillRespecMorph
local LTM_SKILL_RESPEC_PLANNER = Addon.Modules.SkillRespecPlanner
local LTM_SKILL_RESPEC_POST_COMMIT = Addon.Modules.SkillRespecPostCommit
local LTM_SKILL_RESPEC_PURCHASE = Addon.Modules.SkillRespecPurchase
local LTM_SKILL_RESPEC_SUBCLASS_OPS = Addon.Modules.SkillRespecSubclassOps
local LTM_SKILL_RESPEC_VERIFY = Addon.Modules.SkillRespecVerify
local Unpack = unpack or table.unpack

local SKILL_RESPEC_READY_RETRY_DELAYS_MS = LTM_SKILL_RESPEC_CONSTANTS.SKILL_RESPEC_READY_RETRY_DELAYS_MS
local SKILL_RESPEC_START_RETRY_DELAY_MS = LTM_SKILL_RESPEC_CONSTANTS.SKILL_RESPEC_START_RETRY_DELAY_MS
local SKILL_RESPEC_MAX_START_ATTEMPTS = LTM_SKILL_RESPEC_CONSTANTS.SKILL_RESPEC_MAX_START_ATTEMPTS
local SKILL_RESPEC_CONFIRM_RETRY_MS = LTM_SKILL_RESPEC_CONSTANTS.SKILL_RESPEC_CONFIRM_RETRY_MS
local SKILL_RESPEC_CONFIRM_MAX_ATTEMPTS = LTM_SKILL_RESPEC_CONSTANTS.SKILL_RESPEC_CONFIRM_MAX_ATTEMPTS
local ROUTE_B_COMMIT_MAX_RETRIES = LTM_SKILL_RESPEC_CONSTANTS.ROUTE_B_COMMIT_MAX_RETRIES
local ROUTE_B_MORPH_MAX_PASSES = LTM_SKILL_RESPEC_CONSTANTS.ROUTE_B_MORPH_MAX_PASSES
local ROUTE_B_PASSIVE_EXACT_RETRY_DELAY_MS = LTM_SKILL_RESPEC_CONSTANTS.ROUTE_B_PASSIVE_EXACT_RETRY_DELAY_MS

local function IsSummaryDebugEnabled()
    return Log.IsSummaryDebugEnabled() == true
end

local function ShouldLogRouteBPollAttempt(attemptIndex, maxAttempts, force)
    attemptIndex = tonumber(attemptIndex)
    maxAttempts = tonumber(maxAttempts) or 0
    if force == true then
        return true
    end
    if attemptIndex == nil then
        return false
    end

    local midpoint = maxAttempts > 0 and math.ceil(maxAttempts / 2) or nil
    return attemptIndex == 1
        or (midpoint ~= nil and attemptIndex == midpoint)
        or (maxAttempts > 0 and attemptIndex >= maxAttempts)
end

local function IsShowingSkillScene()
    return SCENE_MANAGER:IsShowing("skills") or SCENE_MANAGER:IsShowing("gamepad_skills_root")
end

local function GetCurrentSceneName()
    local scene = SCENE_MANAGER:GetCurrentScene()
    if type(scene) ~= "table" or type(scene.GetName) ~= "function" then
        return nil
    end

    return scene:GetName()
end

local function CreateFailureResult(code, details)
    return {
        ok = false,
        code = code,
        details = details,
    }
end

local function CreateSuccessResult(details)
    return {
        ok = true,
        details = details,
    }
end

local function RecordSharedCooldownMutation(kind, atMs)
    LTM_APPLY_COOLDOWN_GATE:RecordMutation(kind, atMs)
end

function LTM_SKILL_RESPEC_APPLY:GetLastResult()
    return self.lastResult
end

function LTM_SKILL_RESPEC_APPLY:SetLastResult(result, pipelineContext)
    self.lastResult = result
    LTM_PIPELINE_CONTEXT:SetPhaseResult(pipelineContext, "SkillRespec", result)
end

function LTM_SKILL_RESPEC_APPLY:BeginSharedCooldownGateWait(config)
    local remainingMs = LTM_APPLY_COOLDOWN_GATE:GetRemainingDelayMs(
        "skill",
        SHARED_UTIL:GetFrameTimeMillisecondsSafe()
    )
    if type(remainingMs) ~= "number" or remainingMs <= 0 then
        return false
    end

    if type(zo_callLater) ~= "function" then
        return false, "zo_callLater_unavailable"
    end

    if type(self.pendingGateContext) == "table" and self.pendingGateContext.finished ~= true then
        return false, "skill_gate_wait_pending"
    end

    local waitContext = {
        finished = false,
        delayedConfig = config,
    }
    self.pendingGateContext = waitContext

    LTM:NotifyWaitStarted(waitContext, "skill_cooldown", remainingMs / 1000)
    logging.Log("Skill shared cooldown gate wait", "delayMs=" .. tostring(remainingMs))

    zo_callLater(function()
        if LTM_SKILL_RESPEC_APPLY.pendingGateContext ~= waitContext or waitContext.finished then
            return
        end

        waitContext.finished = true
        LTM_SKILL_RESPEC_APPLY.pendingGateContext = nil
        LTM:ResetWaitNotification(waitContext)
        LTM_SKILL_RESPEC_APPLY:Run(config)
    end, remainingMs)

    return true, "deferred"
end

function LTM_SKILL_RESPEC_APPLY:NotifyPipelineContinuation(context, success)
    local continuation = context and context.pipelineContinuation or nil
    if type(continuation) == "function" and not context.pipelineContinuationNotified then
        context.pipelineContinuationNotified = true
        continuation(success, context and context.failureCode or nil)
    end
end

local function IsCurrentRouteBCallbackContext(apply, context, expectedRunId)
    return type(context) == "table"
        and apply.pendingContext == context
        and context.runId == expectedRunId
        and context.finished ~= true
        and context.routeBFinalized ~= true
end

function LTM_SKILL_RESPEC_APPLY:RunRouteBCallback(context, callbackName, callback)
    local expectedRunId = type(context) == "table" and context.runId or nil
    if type(callback) ~= "function"
        or not IsCurrentRouteBCallbackContext(self, context, expectedRunId) then
        return false
    end

    local ok, err = pcall(callback)
    if ok then
        return true
    end

    if not IsCurrentRouteBCallbackContext(self, context, expectedRunId) then
        return false, err
    end

    local commitPerformed = context.commitAt ~= nil
    local commitPhase = commitPerformed and "post_commit" or "pre_commit"
    local pipelineRunId = type(context.pipelineContext) == "table" and context.pipelineContext.runId or nil
    logging.Log(
        "Route B callback error",
        "callback=" .. tostring(callbackName),
        "commitPhase=" .. tostring(commitPhase),
        "routeBRunId=" .. tostring(expectedRunId),
        "pipelineRunId=" .. tostring(pipelineRunId),
        "error=" .. tostring(err)
    )
    self:FinalizeRouteBFailure(context, "route_b_callback_error", {
        callback = callbackName,
        commitPhase = commitPhase,
        commitPerformed = commitPerformed,
        routeBRunId = expectedRunId,
        pipelineRunId = pipelineRunId,
        error = tostring(err),
    })
    return false, err
end

function LTM_SKILL_RESPEC_APPLY:MarkSkillRespecCommitExecuted(context)
    local pipelineContext = context and context.pipelineContext or nil
    LTM_PIPELINE_CONTEXT:SetRuntimeFlag(pipelineContext, "priorSkillRespecCommitted", true)
end

local function MarkRouteBRespecInterfaceUsed(context)
    if type(context) ~= "table" or context.respecInterfaceUsed == true then
        return
    end

    context.respecInterfaceUsed = true
    LTM_PIPELINE_CONTEXT:SetRuntimeFlag(
        context.pipelineContext,
        "routeBRespecInterfaceUsed",
        true
    )
end

function LTM_SKILL_RESPEC_APPLY:ResolveRouteBSkillConfig(config)
    return LTM_SKILL_RESPEC_PLANNER:ResolveRouteBSkillConfig(config)
end

function LTM_SKILL_RESPEC_APPLY:AnalyzeRouteBSkillTarget(target)
    return LTM_SKILL_RESPEC_PLANNER:AnalyzeRouteBSkillTarget(target)
end

function LTM_SKILL_RESPEC_APPLY:BuildRouteBSkillTargetPlan(config)
    return LTM_SKILL_RESPEC_PLANNER:BuildRouteBSkillTargetPlan(config)
end

function LTM_SKILL_RESPEC_APPLY:LogRouteBSkillTargetPlan(label, plan)
    if type(plan) ~= "table" or type(plan.diagnostics) ~= "table" then
        return
    end
    if not IsSummaryDebugEnabled() then
        return
    end

    local craftedFallbackCount = 0
    for _, target in ipairs(plan.nonSlottableTargets or {}) do
        if target.fallbackCraftedAbilityId ~= nil and target.fallbackCraftedAbilityId > 0 then
            craftedFallbackCount = craftedFallbackCount + 1
        end
    end

    local function AppendSamples(parts, targets, bucketName, limit)
        if type(targets) ~= "table" then
            return
        end

        limit = limit or 3
        local samples = {}
        for index, target in ipairs(targets) do
            if index > limit then
                break
            end
            samples[#samples + 1] = string.format(
                "%s:%s:%s:slotActionType=%s:craftedAbilityId=%s:fallbackCraftedAbilityId=%s:reason=%s:bucket=%s",
                tostring(target.hotbarCategory),
                tostring(target.slotIndex),
                tostring(target.targetAbilityId),
                tostring(target.slotActionType),
                tostring(target.craftedAbilityId),
                tostring(target.fallbackCraftedAbilityId),
                tostring(target.reason),
                tostring(target.finalBucket or bucketName)
            )
        end
        if #samples > 0 then
            parts[#parts + 1] = bucketName .. "Samples=" .. table.concat(samples, "|")
        end
    end

    local parts = {
        label,
        "targets=" .. tostring(plan.totalTargets or 0),
        "subclassOps=" .. tostring(plan.diagnostics.subclassOpCount or 0),
        "ready=" .. tostring(plan.diagnostics.readyCount or 0),
        "purchase=" .. tostring(plan.diagnostics.purchaseCount or 0),
        "purchaseUniqueProgressions=" .. tostring(plan.diagnostics.purchaseUniqueProgressions or 0),
        "morph=" .. tostring(plan.diagnostics.morphCount or 0),
        "morphUniqueProgressions=" .. tostring(plan.diagnostics.morphUniqueProgressions or 0),
        "unresolved=" .. tostring(plan.diagnostics.unresolvedCount or 0),
        "nonSlottable=" .. tostring(plan.diagnostics.nonSlottableCount or 0),
        "morphOnlyRouteB=" .. tostring(plan.diagnostics.morphOnlyRouteB == true),
        "routeBReason=" .. tostring(plan.diagnostics.routeBReason),
        "unresolvedReasons=" .. logging.BuildReasonSummary(plan.unresolvedTargets),
        "nonSlottableReasons=" .. logging.BuildReasonSummary(plan.nonSlottableTargets),
        "craftedFallbackCount=" .. tostring(craftedFallbackCount),
        "readyForRestore=" .. tostring(plan.readyForRestore == true),
    }
    AppendSamples(parts, plan.unresolvedTargets, "unresolved")
    AppendSamples(parts, plan.nonSlottableTargets, "nonSlottable")

    logging.Log(
        Unpack(parts)
    )
end

function LTM_SKILL_RESPEC_APPLY:CountUniqueProgressions(targets)
    return LTM_SKILL_RESPEC_PLANNER:CountUniqueProgressions(targets)
end

function LTM_SKILL_RESPEC_APPLY:LogRouteBPurchaseTargetAuditSummary(context)
    local entries = type(context) == "table" and context.purchaseTargetAuditEntries or nil
    if type(entries) ~= "table" or #entries == 0 then
        return
    end

    local selectedCount = 0
    local purchaseInvokedCount = 0
    local dedupedCount = 0
    local canPurchaseFalseCount = 0
    local insufficientPointsCount = 0
    local unexpectedFailureCount = 0
    for _, entry in ipairs(entries) do
        if entry.selected == true then
            selectedCount = selectedCount + 1
        end
        if entry.purchaseInvoked == true then
            purchaseInvokedCount = purchaseInvokedCount + 1
        end
        if entry.deduped == true then
            dedupedCount = dedupedCount + 1
        end
        if entry.canPurchase == false then
            canPurchaseFalseCount = canPurchaseFalseCount + 1
        end
        if entry.outcome == "skipped_insufficient_points" then
            insufficientPointsCount = insufficientPointsCount + 1
        elseif entry.outcome == "unexpected_failure" then
            unexpectedFailureCount = unexpectedFailureCount + 1
        end
    end

    local outcomeSummary = type(context) == "table" and context.purchaseOutcomeSummary or nil

    logging.Log(
        "Route B purchase summary",
        "targets=" .. tostring(#entries),
        "selected=" .. tostring(selectedCount),
        "purchaseInvoked=" .. tostring(purchaseInvokedCount),
        "deduped=" .. tostring(dedupedCount),
        "canPurchaseFalse=" .. tostring(canPurchaseFalseCount),
        "insufficientPoints=" .. tostring(insufficientPointsCount),
        "unexpectedFailure=" .. tostring(unexpectedFailureCount),
        "purchased=" .. tostring(type(outcomeSummary) == "table" and outcomeSummary.purchasedCount or 0),
        "alreadyOwnedOrPending=" .. tostring(
            type(outcomeSummary) == "table" and outcomeSummary.alreadyOwnedOrPendingCount or 0
        ),
        "skippedCannotPurchase=" .. tostring(
            type(outcomeSummary) == "table" and outcomeSummary.skippedCannotPurchaseCount or 0
        ),
        "hardFailure=" .. tostring(type(outcomeSummary) == "table" and outcomeSummary.hardFailure == true),
        "hardFailureReason=" .. tostring(
            type(outcomeSummary) == "table" and outcomeSummary.hardFailureReason or ""
        )
    )
end

function LTM_SKILL_RESPEC_APPLY:IsActivePriorityShortagePolicy(context)
    local skillSettings = LTM_PIPELINE_CONTEXT:GetSkillSettings(
        type(context) == "table" and context.pipelineContext or nil
    )
    return skillSettings.activeShortage == "active_priority"
        and skillSettings.activeAction ~= "skip_all"
end

function LTM_SKILL_RESPEC_APPLY:RecordRouteBExpectedMissingTargets(context, kind, targets)
    if type(context) ~= "table"
        or (kind ~= "purchase" and kind ~= "morph")
        or type(targets) ~= "table"
        or not self:IsActivePriorityShortagePolicy(context) then
        return
    end

    context.expectedMissingActiveTargets = context.expectedMissingActiveTargets or {
        purchases = {},
        morphs = {},
        purchaseByProgression = {},
        morphByProgression = {},
    }
    local records = kind == "purchase"
        and context.expectedMissingActiveTargets.purchases
        or context.expectedMissingActiveTargets.morphs
    local recordSet = kind == "purchase"
        and context.expectedMissingActiveTargets.purchaseByProgression
        or context.expectedMissingActiveTargets.morphByProgression

    for _, target in ipairs(targets) do
        local progressionId = tonumber(type(target) == "table" and target.progressionId or nil)
        if progressionId ~= nil and progressionId > 0 and recordSet[progressionId] == nil then
            local record = {
                progressionId = progressionId,
                targetAbilityId = target.targetAbilityId,
                targetMorphSlot = target.targetMorphSlot,
                source = target.source,
                owner = target.owner or target.source,
                transformKind = target.transformKind,
                shortageReason = "insufficient_skill_points",
            }
            recordSet[progressionId] = record
            records[#records + 1] = record
        end
    end

end

function LTM_SKILL_RESPEC_APPLY:ApplyRouteBPurchaseOutcomeSummary(context, summary)
    if type(context) ~= "table" or type(summary) ~= "table" then
        return
    end

    context.purchaseOutcomeSummary = summary
    self:RecordRouteBExpectedMissingTargets(context, "purchase", summary.expectedMissingTargets)
end

function LTM_SKILL_RESPEC_APPLY:ApplyRouteBMorphOutcomeSummary(context, summary)
    if type(context) ~= "table" or type(summary) ~= "table" then
        return
    end
    context.morphOutcomeSummary = summary
    self:RecordRouteBExpectedMissingTargets(context, "morph", summary.expectedMissingTargets)
end

function LTM_SKILL_RESPEC_APPLY:IsExpectedMissingDueToInsufficientPoints(context, target, kind)
    if type(context) ~= "table" or type(target) ~= "table" then
        return false
    end

    local expected = context.expectedMissingActiveTargets or {}
    local recordSet = kind == "morph" and expected.morphByProgression
        or kind == "purchase" and expected.purchaseByProgression
        or nil
    local progressionId = tonumber(target.progressionId)
    return type(recordSet) == "table"
        and progressionId ~= nil
        and recordSet[progressionId] ~= nil
end

function LTM_SKILL_RESPEC_APPLY:ResolveRouteBVerifyMode(context)
    local expected = type(context) == "table" and context.expectedMissingActiveTargets or nil
    local purchaseCount = type(expected) == "table" and type(expected.purchases) == "table"
        and #expected.purchases
        or 0
    local morphCount = type(expected) == "table" and type(expected.morphs) == "table"
        and #expected.morphs
        or 0
    return purchaseCount + morphCount > 0 and "degraded" or "strict"
end

function LTM_SKILL_RESPEC_APPLY:GetRouteBCommitReadiness(skillTargetPlan, context)
    local diagnostics = type(skillTargetPlan) == "table" and skillTargetPlan.diagnostics or nil
    local verifyMode = self:ResolveRouteBVerifyMode(context)
    local readiness = {
        ok = false,
        verifyMode = verifyMode,
        purchaseCount = 0,
        morphCount = 0,
        unresolvedCount = 0,
        expectedMissingPurchaseCount = 0,
        unexpectedPurchaseCount = 0,
        expectedMissingMorphCount = 0,
        unexpectedMorphCount = 0,
    }

    if type(diagnostics) ~= "table" then
        return readiness
    end

    readiness.purchaseCount = diagnostics.purchaseCount or 0
    readiness.morphCount = diagnostics.morphCount or 0
    readiness.unresolvedCount = diagnostics.unresolvedCount or 0

    for _, target in ipairs(type(skillTargetPlan.purchaseTargets) == "table" and skillTargetPlan.purchaseTargets or {}) do
        if verifyMode == "degraded"
            and self:IsExpectedMissingDueToInsufficientPoints(context, target, "purchase") then
            readiness.expectedMissingPurchaseCount = readiness.expectedMissingPurchaseCount + 1
        else
            readiness.unexpectedPurchaseCount = readiness.unexpectedPurchaseCount + 1
        end
    end
    for _, target in ipairs(type(skillTargetPlan.morphTargets) == "table" and skillTargetPlan.morphTargets or {}) do
        if verifyMode == "degraded"
            and self:IsExpectedMissingDueToInsufficientPoints(context, target, "morph") then
            readiness.expectedMissingMorphCount = readiness.expectedMissingMorphCount + 1
        else
            readiness.unexpectedMorphCount = readiness.unexpectedMorphCount + 1
        end
    end

    readiness.ok = readiness.unexpectedPurchaseCount == 0
        and readiness.unexpectedMorphCount == 0
        and readiness.unresolvedCount == 0

    return readiness
end

function LTM_SKILL_RESPEC_APPLY:ResolveRouteBPreCommitBlockedCode(skillTargetPlan, readiness, fallbackCode)
    local code = fallbackCode or "route_b_morph_substep_only"
    local unresolvedTargets = type(skillTargetPlan) == "table" and skillTargetPlan.unresolvedTargets or nil

    for _, target in ipairs(type(unresolvedTargets) == "table" and unresolvedTargets or {}) do
        if type(target) == "table" and target.reason == "cryptcanon_special_ultimate_requires_overwrite" then
            return "cryptcanon_special_ultimate_requires_overwrite", readiness
        end
    end

    if readiness.unresolvedCount > 0 then
        code = "route_b_unresolved_slot_target_before_commit"
    end

    return code, readiness
end

function LTM_SKILL_RESPEC_APPLY:NotifyCryptCanonOverwriteRequired(context)
    if type(context) ~= "table" then
        return
    end

    if context.cryptCanonOverwriteNoticeShown == true then
        return
    end

    context.cryptCanonOverwriteNoticeShown = true
    Log.WriteChat(LTM.GetStringText("SI_LTM_STATUS_CRYPTCANON_OVERWRITE_REQUIRED"))
end

function LTM_SKILL_RESPEC_APPLY:GetRouteBPendingChangesState()
    local manager = type(SKILLS_AND_ACTION_BAR_MANAGER) == "table" and SKILLS_AND_ACTION_BAR_MANAGER or nil
    local hasMethod = type(manager) == "table" and type(manager.HasAnyPendingChanges) == "function"
    local hasPendingChanges = nil
    if hasMethod then
        hasPendingChanges = manager:HasAnyPendingChanges()
    end

    local allocationPending = type(SKILL_POINT_ALLOCATION_MANAGER) == "table"
        and type(SKILL_POINT_ALLOCATION_MANAGER.IsAnyChangePending) == "function"
        and SKILL_POINT_ALLOCATION_MANAGER:IsAnyChangePending()
        or false
    local linePending = type(SKILL_LINE_ASSIGNMENT_MANAGER) == "table"
        and type(SKILL_LINE_ASSIGNMENT_MANAGER.IsAnyChangePending) == "function"
        and SKILL_LINE_ASSIGNMENT_MANAGER:IsAnyChangePending()
        or false
    local actionBarPending = type(ACTION_BAR_ASSIGNMENT_MANAGER) == "table"
        and type(ACTION_BAR_ASSIGNMENT_MANAGER.IsAnyChangePending) == "function"
        and ACTION_BAR_ASSIGNMENT_MANAGER:IsAnyChangePending()
        or false
    local allocationMode = type(SKILLS_AND_ACTION_BAR_MANAGER) == "table"
        and type(SKILLS_AND_ACTION_BAR_MANAGER.GetSkillPointAllocationMode) == "function"
        and SKILLS_AND_ACTION_BAR_MANAGER:GetSkillPointAllocationMode()
        or nil
    local pendingAllocators = self:CollectPendingRouteBAllocators(nil, IsSummaryDebugEnabled())
    if hasPendingChanges == nil then
        hasPendingChanges = allocationPending == true
            or linePending == true
            or actionBarPending == true
            or #pendingAllocators > 0
    end

    return {
        pendingChanges = hasPendingChanges,
        hasPendingChanges = hasPendingChanges,
        allocationPending = allocationPending,
        linePending = linePending,
        actionBarPending = actionBarPending,
        allocationMode = allocationMode,
        pendingAllocatorCount = #pendingAllocators,
        pendingAllocatorSamples = pendingAllocators.samples,
        hasManager = manager ~= nil,
        hasMethod = hasMethod,
    }
end

function LTM_SKILL_RESPEC_APPLY:CollectPendingRouteBAllocators(limit, includeSamples)
    local allocators = {}
    allocators.samples = {}
    limit = limit or 5
    includeSamples = includeSamples == true

    local manager = type(SKILL_POINT_ALLOCATION_MANAGER) == "table" and SKILL_POINT_ALLOCATION_MANAGER or nil
    if type(manager) ~= "table" or type(manager.AllocatorIterator) ~= "function" then
        return allocators
    end

    local function IsPendingAllocator(allocator)
        return type(allocator) == "table"
            and type(allocator.IsAnyChangePending) == "function"
            and allocator:IsAnyChangePending() == true
    end

    for _, allocator in manager:AllocatorIterator({ IsPendingAllocator }) do
        allocators[#allocators + 1] = allocator
        if includeSamples and #allocators.samples < limit then
            local skillData = type(allocator) == "table" and allocator.skillData or nil
            local progressionId = type(skillData) == "table" and type(skillData.GetProgressionId) == "function"
                and skillData:GetProgressionId()
                or nil
            allocators.samples[#allocators.samples + 1] = tostring(progressionId or "nil")
        end
    end

    return allocators
end

function LTM_SKILL_RESPEC_APPLY:LogRouteBMorphTargetAuditSummary(context)
    local entries = type(context) == "table" and context.morphTargetAuditEntries or nil
    local progressionEntries = type(context) == "table" and context.morphProgressionAuditEntries or nil
    local normalization = type(context) == "table" and context.morphNormalizationSummary or nil
    if type(entries) ~= "table" or #entries == 0 or type(progressionEntries) ~= "table" then
        return
    end

    local selectedCount = 0
    local conflictCount = 0
    local canMorphFalseCount = 0
    for _, entry in ipairs(progressionEntries) do
        if entry.selected == true then
            selectedCount = selectedCount + 1
        end
        if entry.hasConflict == true then
            conflictCount = conflictCount + 1
        end
        if entry.canMorph == false then
            canMorphFalseCount = canMorphFalseCount + 1
        end
    end

    logging.Log(
        "Route B morph summary",
        "targets=" .. tostring(#entries),
        "uniqueProgressions=" .. tostring(#progressionEntries),
        "selected=" .. tostring(selectedCount),
        "conflicts=" .. tostring(conflictCount),
        "canMorphFalse=" .. tostring(canMorphFalseCount),
        "normalizedProgressions=" .. tostring(
            type(normalization) == "table" and normalization.progressionCount or 0
        ),
        "resolved=" .. tostring(type(normalization) == "table" and normalization.resolvedCount or 0),
        "dropped=" .. tostring(type(normalization) == "table" and normalization.droppedCount or 0)
    )
end

function LTM_SKILL_RESPEC_APPLY:RevertRouteBPendingPreparation(context)
    if type(context) ~= "table" then
        return nil
    end

    local beforeState = self:GetRouteBPendingChangesState()
    local revertedAllocators = {}
    local revertedAllocatorSet = {}
    local contextModifiedAllocatorCount = #(context.modifiedAllocators or {})
    local pendingAllocators = self:CollectPendingRouteBAllocators()
    for _, allocator in ipairs(pendingAllocators) do
        if type(allocator) == "table" and type(allocator.Revert) == "function" and revertedAllocatorSet[allocator] ~= true then
            revertedAllocatorSet[allocator] = true
            pcall(allocator.Revert, allocator)
            revertedAllocators[#revertedAllocators + 1] = allocator
        end
    end
    for _, allocator in ipairs(context.modifiedAllocators or {}) do
        if type(allocator) == "table" and type(allocator.Revert) == "function" and revertedAllocatorSet[allocator] ~= true then
            revertedAllocatorSet[allocator] = true
            pcall(allocator.Revert, allocator)
            revertedAllocators[#revertedAllocators + 1] = allocator
        end
    end

    context.modifiedAllocators = {}

    local shouldResetPreparedState = context.respecInterfaceUsed == true
        or #pendingAllocators > 0
        or contextModifiedAllocatorCount > 0
    if shouldResetPreparedState then
        -- ResetRespecState is the ESO-owned full reset. Its callbacks release
        -- the active allocator pool and reset skill-line and player-hotbar caches.
        LTM_APPLY_START_STATE:ResetRespecInterface()
    end

    LTM_PIPELINE_CONTEXT:SetRuntimeFlag(context.pipelineContext, "priorSkillRespecCommitted", false)
    -- NOTE:
    -- Current revert paths run before routeBCompleted=true.
    -- Revisit routeBCompleted reset if post-completion revert paths are added.
    local pendingState = self:GetRouteBPendingChangesState()
    logging.Log(
        "Route B cleanup pending state",
        "beforeHasPendingChanges=" .. tostring(type(beforeState) == "table" and beforeState.hasPendingChanges),
        "beforeAllocationPending=" .. tostring(type(beforeState) == "table" and beforeState.allocationPending),
        "beforeActionBarPending=" .. tostring(type(beforeState) == "table" and beforeState.actionBarPending),
        "beforeAllocationMode=" .. tostring(type(beforeState) == "table" and beforeState.allocationMode),
        "pendingAllocatorCount=" .. tostring(#pendingAllocators),
        "revertedAllocators=" .. tostring(#revertedAllocators),
        "contextModifiedAllocators=" .. tostring(contextModifiedAllocatorCount),
        "afterHasPendingChanges=" .. tostring(type(pendingState) == "table" and pendingState.hasPendingChanges),
        "afterAllocationPending=" .. tostring(type(pendingState) == "table" and pendingState.allocationPending),
        "afterLinePending=" .. tostring(type(pendingState) == "table" and pendingState.linePending),
        "afterActionBarPending=" .. tostring(type(pendingState) == "table" and pendingState.actionBarPending),
        "afterAllocationMode=" .. tostring(type(pendingState) == "table" and pendingState.allocationMode),
        "remainingPendingAllocators=" .. tostring(type(pendingState) == "table" and pendingState.pendingAllocatorCount or 0),
        "remainingAllocatorSamples=" .. tostring(
            type(pendingState) == "table"
                and type(pendingState.pendingAllocatorSamples) == "table"
                and table.concat(pendingState.pendingAllocatorSamples, "|")
                or ""
        )
    )

    local result = {
        before = beforeState,
        after = pendingState,
        pendingAllocatorCount = #pendingAllocators,
        revertedAllocatorCount = #revertedAllocators,
        contextModifiedAllocatorCount = contextModifiedAllocatorCount,
        incomplete = type(pendingState) == "table"
            and (pendingState.hasPendingChanges == true
                or pendingState.allocationPending == true
                or pendingState.linePending == true
                or pendingState.actionBarPending == true
                or (pendingState.pendingAllocatorCount or 0) > 0)
            or false,
    }

    context.routeBCleanupResult = result
    return result
end

function LTM_SKILL_RESPEC_APPLY:ExecuteRouteBPendingPurchases(context, skillTargetPlan)
    return LTM_SKILL_RESPEC_PURCHASE:ExecutePending(self, context, skillTargetPlan)
end

function LTM_SKILL_RESPEC_APPLY:ExecuteRouteBPendingMorphs(context)
    return LTM_SKILL_RESPEC_MORPH:ExecutePending(self, context)
end

function LTM_SKILL_RESPEC_APPLY:AuditRouteBMorphTargets(context, skillTargetPlan)
    return LTM_SKILL_RESPEC_MORPH:AuditTargets(self, context, skillTargetPlan)
end

function LTM_SKILL_RESPEC_APPLY:CheckGeneralPreconditions()
    if type(IsUnitInCombat) == "function" and IsUnitInCombat("player") then
        return false, "player_in_combat"
    end

    if type(IsCurrentCampaignVengeanceRuleset) == "function" and IsCurrentCampaignVengeanceRuleset() then
        return false, "vengeance_ruleset_active"
    end

    return true
end

function LTM_SKILL_RESPEC_APPLY:BuildDirtyStatePrecheckSnapshot(config)
    local pipelineContext = type(config) == "table" and config._pipelineContext or nil
    local runtime = type(pipelineContext) == "table" and pipelineContext.runtime or nil
    local hasPendingChanges = nil
    if type(SKILLS_AND_ACTION_BAR_MANAGER) == "table"
        and type(SKILLS_AND_ACTION_BAR_MANAGER.HasAnyPendingChanges) == "function" then
        hasPendingChanges = SKILLS_AND_ACTION_BAR_MANAGER:HasAnyPendingChanges()
    end
    local allocationPending = type(SKILL_POINT_ALLOCATION_MANAGER) == "table"
        and type(SKILL_POINT_ALLOCATION_MANAGER.IsAnyChangePending) == "function"
        and SKILL_POINT_ALLOCATION_MANAGER:IsAnyChangePending()
        or false
    local linePending = type(SKILL_LINE_ASSIGNMENT_MANAGER) == "table"
        and type(SKILL_LINE_ASSIGNMENT_MANAGER.IsAnyChangePending) == "function"
        and SKILL_LINE_ASSIGNMENT_MANAGER:IsAnyChangePending()
        or false
    local actionBarPending = type(ACTION_BAR_ASSIGNMENT_MANAGER) == "table"
        and type(ACTION_BAR_ASSIGNMENT_MANAGER.IsAnyChangePending) == "function"
        and ACTION_BAR_ASSIGNMENT_MANAGER:IsAnyChangePending()
        or false
    local pendingChangesIncurCost = type(SKILLS_AND_ACTION_BAR_MANAGER) == "table"
        and type(SKILLS_AND_ACTION_BAR_MANAGER.DoPendingChangesIncurCost) == "function"
        and SKILLS_AND_ACTION_BAR_MANAGER:DoPendingChangesIncurCost()
        or false

    local interaction = type(GetInteractionType) == "function" and GetInteractionType() or nil
    local lastRunOwnedPendingSuspected = type(runtime) == "table"
        and (runtime.priorSkillRespecCommitted == true or runtime.routeBCompleted == true)
        or false

    return {
        scene = GetCurrentSceneName(),
        interaction = interaction,
        hasPendingChanges = hasPendingChanges,
        allocationPending = allocationPending,
        linePending = linePending,
        actionBarPending = actionBarPending,
        pendingChangesIncurCost = pendingChangesIncurCost,
        phase = type(config) == "table" and config._pipelinePhaseName or nil,
        lastRunOwnedPendingSuspected = lastRunOwnedPendingSuspected,
        priorSkillRespecCommitted = type(runtime) == "table" and runtime.priorSkillRespecCommitted == true or false,
        routeBCompleted = type(runtime) == "table" and runtime.routeBCompleted == true or false,
        skillSceneShowing = IsShowingSkillScene(),
    }
end

function LTM_SKILL_RESPEC_APPLY:LogDirtyStatePrecheck(result)
    if type(result) ~= "table" then
        return
    end

    local snapshot = type(result.snapshot) == "table" and result.snapshot or {}
    Log.LogDebugSummary(
        "Skill respec dirty precheck",
        "classification=" .. tostring(result.classification),
        "scene=" .. tostring(snapshot.scene),
        "interaction=" .. tostring(snapshot.interaction),
        "hasPendingChanges=" .. tostring(snapshot.hasPendingChanges),
        "allocationPending=" .. tostring(snapshot.allocationPending),
        "linePending=" .. tostring(snapshot.linePending),
        "actionBarPending=" .. tostring(snapshot.actionBarPending),
        "pendingChangesIncurCost=" .. tostring(snapshot.pendingChangesIncurCost),
        "phase=" .. tostring(snapshot.phase),
        "lastRunOwnedPendingSuspected=" .. tostring(snapshot.lastRunOwnedPendingSuspected),
        "skillSceneShowing=" .. tostring(snapshot.skillSceneShowing)
    )
end

function LTM_SKILL_RESPEC_APPLY:ClassifyDirtyStatePrecheck(config)
    if type(SKILLS_AND_ACTION_BAR_MANAGER) ~= "table" then
        local unavailableResult = {
            ok = false,
            classification = nil,
            code = "skills_and_action_bar_manager_unavailable",
            snapshot = self:BuildDirtyStatePrecheckSnapshot(config),
        }
        self:LogDirtyStatePrecheck(unavailableResult)
        return unavailableResult
    end

    if type(SKILLS_AND_ACTION_BAR_MANAGER.HasAnyPendingChanges) ~= "function" then
        local missingResult = {
            ok = false,
            classification = nil,
            code = "skills_pending_state_unavailable",
            snapshot = self:BuildDirtyStatePrecheckSnapshot(config),
        }
        self:LogDirtyStatePrecheck(missingResult)
        return missingResult
    end

    local snapshot = self:BuildDirtyStatePrecheckSnapshot(config)
    local classification = "clean"
    local code = nil

    if snapshot.hasPendingChanges == true then
        local substantivePending = snapshot.allocationPending == true
            or snapshot.linePending == true
            or snapshot.pendingChangesIncurCost == true

        if substantivePending then
            classification = snapshot.lastRunOwnedPendingSuspected and "self_pending_recoverable" or "foreign_pending"
            code = "skill_pending_changes_blocking_apply"
        elseif snapshot.actionBarPending == true then
            classification = "action_bar_only_pending_ignored"
        end
    end

    local result = {
        ok = classification == "clean" or classification == "action_bar_only_pending_ignored",
        classification = classification,
        code = code,
        snapshot = snapshot,
    }
    self:LogDirtyStatePrecheck(result)
    return result
end

function LTM_SKILL_RESPEC_APPLY:ClearPendingContext()
    local eventManager = SHARED_UTIL:GetEventManager()
    local resultEventNamespace = LTM_SKILL_RESPEC_COMPLETION:GetResultEventNamespace()
    local routeBCastEventNamespace = LTM_SKILL_RESPEC_COMPLETION:GetRouteBCastEventNamespace()
    if type(eventManager) == "table" and type(eventManager.UnregisterForEvent) == "function" then
        eventManager:UnregisterForEvent(resultEventNamespace, EVENT_SKILL_RESPEC_RESULT)
        if EVENT_START_SKILL_RESPEC_CAST ~= nil then
            eventManager:UnregisterForEvent(routeBCastEventNamespace, EVENT_START_SKILL_RESPEC_CAST)
        end
    end
    self.pendingContext = nil
end

local function CompleteRouteBSuccessAfterCleanup(self, context, details)
    local pipelineContext = context.pipelineContext

    LTM_PIPELINE_CONTEXT:SetRuntimeFlag(pipelineContext, "routeBRespecInterfaceUsed", false)
    LTM_PIPELINE_CONTEXT:SetRuntimeFlag(pipelineContext, "routeBCompleted", true)
    LTM_PIPELINE_CONTEXT:SetRuntimeFlag(
        pipelineContext,
        "routeBSubclassOnly",
        context.routeBSubclassOnlyExecuted == true
    )

    logging.Log("Route B restore handoff target=skill_restore mode=post_route_b")

    if context.originPhase == "Skills" then
        local restoreOk, restoreErr = LTM_SKILL_RESTORE:RunRestoreOnly(context.routeBConfig or {})
        if not restoreOk then
            context.failureCode = restoreErr or "route_b_restore_failed"
            self:SetLastResult(CreateFailureResult("route_b_restore_failed", {
                error = restoreErr,
            }), pipelineContext)
            self:NotifyPipelineContinuation(context, false)
            return
        end

        local restoreResult = LTM_SKILL_RESTORE:GetLastResult()
        if type(restoreResult) == "table" then
            details.actionBarRestoreResult = restoreResult
        end
    end

    LTM_SKILL_RESPEC_VERIFY:VerifyTransformSnapshotsPostCommit(context)

    if context.passiveSummary ~= nil then
        LTM_SKILL_PASSIVE_APPLY:RecordAutoFillPartialSuccess(
            pipelineContext,
            context.passiveSummary
        )
    end

    self:SetLastResult(CreateSuccessResult(details), pipelineContext)
    Log.Debug("Skill respec Route B finished")
    self:NotifyPipelineContinuation(context, true)
end

function LTM_SKILL_RESPEC_APPLY:FinalizeRouteBSuccess(context, extra)
    if type(context) == "table" and context.routeBFinalized == true then
        return
    end

    local details = type(extra) == "table" and type(extra.readiness) == "table"
        and { readiness = extra.readiness }
        or {}

    local expectedMissing = type(context.expectedMissingActiveTargets) == "table"
        and context.expectedMissingActiveTargets
        or {}
    local expectedMissingPurchases = type(expectedMissing.purchases) == "table"
        and expectedMissing.purchases
        or {}
    local expectedMissingMorphs = type(expectedMissing.morphs) == "table"
        and expectedMissing.morphs
        or {}
    local expectedMissingPurchaseCount = #expectedMissingPurchases
    local expectedMissingMorphCount = #expectedMissingMorphs
    if self:IsActivePriorityShortagePolicy(context)
        and expectedMissingPurchaseCount + expectedMissingMorphCount > 0 then
        details.resultCode = "route_b_active_priority_insufficient_points"
    end

    if type(context) == "table"
        and type(context.classMasteryPurchaseSummary) == "table"
        and (context.classMasteryPurchaseSummary.attemptedCount or 0) > 0 then
        local committedAudit = LTM_SKILL_RESPEC_CLASS_MASTERY_PURCHASE:AuditCommittedTargets(context)
        if type(committedAudit) == "table" and committedAudit.ok ~= true then
            self:FinalizeRouteBFailure(context, "class_mastery_purchase_commit_mismatch", {
                classMasteryPurchaseSummary = context.classMasteryPurchaseSummary,
                classMasteryCommittedAudit = committedAudit,
            })
            return
        end
    end

    if type(context) == "table" then
        context.routeBFinalized = true
    end

    self:ClearPendingContext()
    context.finished = true
    RecordSharedCooldownMutation("skill", SHARED_UTIL:GetFrameTimeMillisecondsSafe())

    if context.respecInterfaceUsed ~= true then
        CompleteRouteBSuccessAfterCleanup(self, context, details)
        return
    end

    local normalizeStarted, normalizeErr = LTM_APPLY_START_STATE:NormalizeToHudBaseline(function(ok, cleanReason)
        if ok ~= true then
            local failureCode = "route_b_baseline_cleanup_failed"
            context.failureCode = failureCode
            self:SetLastResult(CreateFailureResult(failureCode, {
                cleanupReason = cleanReason,
            }), context.pipelineContext)
            Log.Debug("Route B baseline cleanup failed error=" .. tostring(cleanReason))
            self:NotifyPipelineContinuation(context, false)
            return
        end

        CompleteRouteBSuccessAfterCleanup(self, context, details)
    end)
    if normalizeStarted ~= true then
        context.failureCode = "route_b_baseline_cleanup_failed"
        self:SetLastResult(CreateFailureResult(context.failureCode, {
            cleanupReason = normalizeErr,
        }), context.pipelineContext)
        Log.Debug("Route B baseline cleanup failed error=" .. tostring(normalizeErr))
        self:NotifyPipelineContinuation(context, false)
    end
end

function LTM_SKILL_RESPEC_APPLY:FinalizeRouteBFailure(context, code, details)
    if type(context) == "table" and context.routeBFinalized == true then
        return
    end

    details = details or {}
    if details.resultWaitMode == nil then
        details.resultWaitMode = context.resultWaitMode
    end
    if type(context) == "table"
        and details.classMasteryReductionSummary == nil
        and context.classMasteryReductionSummary ~= nil then
        details.classMasteryReductionSummary = context.classMasteryReductionSummary
    end
    if type(context) == "table"
        and details.classMasteryPurchaseSummary == nil
        and context.classMasteryPurchaseSummary ~= nil then
        details.classMasteryPurchaseSummary = context.classMasteryPurchaseSummary
    end
    local originalCode = code
    local cleanupResult = type(context) == "table" and context.routeBCleanupResult or nil
    if type(context) == "table" and context.commitAt == nil then
        if type(cleanupResult) ~= "table" then
            cleanupResult = self:RevertRouteBPendingPreparation(context)
        end
        if type(cleanupResult) == "table" then
            details.cleanup = cleanupResult
            if cleanupResult.incomplete == true then
                details.originalFailureCode = originalCode
                code = "route_b_cleanup_incomplete"
            end
        end
    end
    if type(context) == "table" then
        context.routeBFinalized = true
    end

    self:ClearPendingContext()
    context.finished = true

    local function finishFailure(cleanOk, cleanReason)
        if cleanOk == true then
            LTM_PIPELINE_CONTEXT:SetRuntimeFlag(
                context.pipelineContext,
                "routeBRespecInterfaceUsed",
                false
            )
        else
            details.originalFailureCode = details.originalFailureCode or code
            details.baselineCleanupReason = cleanReason
            code = "route_b_baseline_cleanup_failed"
        end

        context.failureCode = code
        self:SetLastResult(CreateFailureResult(code, details), context.pipelineContext)
        Log.Debug("Route B failed error=" .. tostring(code))
        logging.Log(
            "Route B failure detail",
            "error=" .. tostring(code),
            "originalError=" .. tostring(originalCode),
            "cleanupIncomplete=" .. tostring(
                type(cleanupResult) == "table" and cleanupResult.incomplete == true or false
            ),
            "baselineCleanup=" .. tostring(cleanOk == true),
            "baselineCleanupReason=" .. tostring(cleanReason)
        )
        self:NotifyPipelineContinuation(context, false)
    end

    if context.respecInterfaceUsed ~= true then
        finishFailure(true, nil)
        return
    end

    local normalizeStarted, normalizeErr = LTM_APPLY_START_STATE:NormalizeToHudBaseline(function(ok, cleanReason)
        finishFailure(ok == true, cleanReason)
    end)
    if normalizeStarted ~= true then
        finishFailure(false, normalizeErr or "normalize_start_failed")
    end
end

-- Route B commit cooldown failure previously short-circuited into immediate
-- verify/result failure because ApplyChanges() success was treated as "commit
-- sent". Retry is now scoped to the commit attempt boundary only: accept on
-- cast/result observation, retry only on cooldown-like rejection/timeout, and
-- keep verify/completion unchanged after acceptance.
function LTM_SKILL_RESPEC_APPLY:GetRouteBCommitRetryCount(context)
    if type(context) ~= "table" then
        return 0
    end

    return context.commitRetryCount or 0
end

function LTM_SKILL_RESPEC_APPLY:IsRouteBCommitRetryableResult(result)
    return RESPEC_RESULT_ON_COOLDOWN_SKILLS ~= nil
        and result == RESPEC_RESULT_ON_COOLDOWN_SKILLS
end

function LTM_SKILL_RESPEC_APPLY:CanRetryRouteBCommit(context)
    return type(context) == "table"
        and self.pendingContext == context
        and not self:IsRouteBContextInactive(context)
        and context.completionArmed ~= true
        and context.commitAccepted ~= true
        and context.commitRetryScheduled ~= true
        and self:GetRouteBCommitRetryCount(context) < ROUTE_B_COMMIT_MAX_RETRIES
end

function LTM_SKILL_RESPEC_APPLY:MarkRouteBCommitAccepted(context, source)
    return LTM_SKILL_RESPEC_POST_COMMIT:MarkCommitAccepted(self, context, source)
end

function LTM_SKILL_RESPEC_APPLY:ScheduleRouteBCommitRetry(context, reason, details)
    return LTM_SKILL_RESPEC_POST_COMMIT:ScheduleCommitRetry(self, context, reason, details)
end

function LTM_SKILL_RESPEC_APPLY:BeginRouteBPostCommitVerifyRetry(context, snapshot, successKind)
    return LTM_SKILL_RESPEC_POST_COMMIT:BeginPostCommitVerifyRetry(self, context, snapshot, successKind)
end

function LTM_SKILL_RESPEC_APPLY:IsRouteBContextInactive(context)
    return LTM_SKILL_RESPEC_COMPLETION:IsRouteBContextInactive(context)
end

function LTM_SKILL_RESPEC_APPLY:MarkRouteBCompletionResolved(context, success, reason)
    return LTM_SKILL_RESPEC_COMPLETION:MarkRouteBCompletionResolved(context, success, reason)
end

function LTM_SKILL_RESPEC_APPLY:ResolveRouteBCompletionSuccess(context, snapshot, successKind)
    return LTM_SKILL_RESPEC_COMPLETION:ResolveRouteBCompletionSuccess(self, context, snapshot, successKind)
end

function LTM_SKILL_RESPEC_APPLY:ResolveRouteBCompletionFailure(context, reason, details)
    return LTM_SKILL_RESPEC_COMPLETION:ResolveRouteBCompletionFailure(self, context, reason, details)
end

function LTM_SKILL_RESPEC_APPLY:LogRouteBRespecEntryStart(context)
    if type(context) ~= "table" then
        return
    end

    if context.respecEntryLogged then
        return
    end

    context.respecEntryLogged = true
    logging.Log("Route B respec entry start")
end

function LTM_SKILL_RESPEC_APPLY:IsReadyForSubclass(context)
    local interactionReady = type(GetInteractionType) == "function" and GetInteractionType() == INTERACTION_SKILL_RESPEC
    local sceneReady = IsShowingSkillScene()
    local hasSkillsManager = type(SKILLS_AND_ACTION_BAR_MANAGER) == "table"
    local allowsSkillLineRespec = hasSkillsManager
        and type(SKILLS_AND_ACTION_BAR_MANAGER.DoesSkillPointAllocationModeAllowSkillLineRespec) == "function"
        and SKILLS_AND_ACTION_BAR_MANAGER:DoesSkillPointAllocationModeAllowSkillLineRespec()
        or false

    return interactionReady and sceneReady and hasSkillsManager and allowsSkillLineRespec, {
        interactionReady = interactionReady,
        sceneReady = sceneReady,
        hasSkillsManager = hasSkillsManager,
        allowsSkillLineRespec = allowsSkillLineRespec,
        currentAllocationMode = hasSkillsManager
            and SKILLS_AND_ACTION_BAR_MANAGER.GetSkillPointAllocationMode
            and SKILLS_AND_ACTION_BAR_MANAGER:GetSkillPointAllocationMode()
            or nil,
    }
end

function LTM_SKILL_RESPEC_APPLY:ResolveSubclassPlan(config)
    local plan = config and config._pipelinePlan or nil
    local subclassDiff = type(plan) == "table" and type(plan.diagnostics) == "table" and plan.diagnostics.subclassDiff or nil
    if type(subclassDiff) ~= "table" then
        return nil, "subclass_plan_missing"
    end

    if subclassDiff.ok ~= true then
        return nil, subclassDiff.reason or "subclass_plan_not_ok"
    end

    return subclassDiff
end

function LTM_SKILL_RESPEC_APPLY:RunRouteBGeneralPrecheck(config)
    local generalOk, generalErr = self:CheckGeneralPreconditions()
    if not generalOk then
        return false, generalErr
    end

    local subclassPlan, planErr = self:ResolveSubclassPlan(config)
    if subclassPlan == nil then
        return false, planErr
    end

    local pipelinePlan = type(config) == "table" and config._pipelinePlan or nil
    local activeRestorePlan = type(pipelinePlan) == "table"
        and type(pipelinePlan.configs) == "table"
        and type(pipelinePlan.configs.skillRespec) == "table"
        and pipelinePlan.configs.skillRespec.activeRestorePlan
        or nil
    if type(activeRestorePlan) ~= "table" or activeRestorePlan.ok ~= true then
        return false, type(activeRestorePlan) == "table"
            and activeRestorePlan.blockReason
            or "active_restore_plan_invalid"
    end

    return true, subclassPlan
end

function LTM_SKILL_RESPEC_APPLY:RunRouteBDirtyStatePrecheck(config)
    local dirtyPrecheck = self:ClassifyDirtyStatePrecheck(config)
    if dirtyPrecheck.ok ~= true then
        return false, dirtyPrecheck.code, dirtyPrecheck
    end

    return true, dirtyPrecheck
end

function LTM_SKILL_RESPEC_APPLY:RunRouteBPassivePhase(context, completion)
    local build = type(context) == "table" and type(context.pipelineContext) == "table"
        and context.pipelineContext.targetBuild
        or nil
    local targetSkillLineIds = SHARED_UTIL:NormalizeLineIdList(
        type(build) == "table" and type(build.subclass) == "table" and build.subclass.targetSkillLineIds or nil
    )

    local pipelineContext = type(context) == "table" and context.pipelineContext or nil
    local skillSettings = LTM_PIPELINE_CONTEXT:GetSkillSettings(pipelineContext)
    local passiveRestore = skillSettings.passiveRestore
    local skillSettingsReason = LTM_PIPELINE_CONTEXT:GetSkillSettingsSkipReason(
        pipelineContext,
        "normal_passive_changes"
    )
    if skillSettingsReason ~= nil then
        LTM_PIPELINE_CONTEXT:RecordSkillSettingsSkip(
            pipelineContext,
            "normal_passive_changes",
            skillSettingsReason
        )
        local summary = {
            ok = true,
            skipped = true,
            policy = passiveRestore,
            targetLineCount = #targetSkillLineIds,
            targetSkillLineIds = targetSkillLineIds,
            restoredCount = 0,
            skippedCount = 0,
            warningCount = 0,
            reasonCounts = {
                [skillSettingsReason] = 1,
            },
            skillSettingsReason = skillSettingsReason,
        }
        context.passiveSummary = summary
        return summary
    end

    if passiveRestore == "class_exact" or passiveRestore == "all_exact" then
        local function finish(success, err, result)
            if self.pendingContext ~= context or context.finished then
                return
            end

            context.passivePhasePending = false
            context.passiveSummary = result
            if success == true
                and type(context.pipelineContext) == "table"
                and type(result) == "table"
                and type(result.partialSuccessResult) == "table" then
                LTM_PIPELINE_CONTEXT:RecordDomainResult(context.pipelineContext, result.partialSuccessResult)
            end
            if type(result) == "table" and type(result.modifiedAllocators) == "table" then
                context.modifiedAllocators = context.modifiedAllocators or {}
                for _, allocator in ipairs(result.modifiedAllocators) do
                    context.modifiedAllocators[#context.modifiedAllocators + 1] = allocator
                end
                result.modifiedAllocatorSet = nil
                result.modifiedAllocators = nil
            end

            logging.Log(
                "Route B passive exact summary",
                "ok=" .. tostring(success == true),
                "error=" .. tostring(err),
                "applied=" .. tostring(type(result) == "table" and result.appliedCount or 0),
                "residual=" .. tostring(type(result) == "table" and result.residualCount or 0),
                "invalid=" .. tostring(type(result) == "table" and result.invalidCount or 0)
            )

            if type(completion) == "function" then
                completion(success == true, err, result)
            end
        end

        context.passivePhasePending = type(completion) == "function"
        local ok, err, result = LTM_PASSIVE_SNAPSHOT_APPLY:RunExactRestore(build, {
            operationMode = "respec_transaction",
            allowedOperations = {
                purchase = true,
                reduction = true,
            },
            maxAttempts = 5,
            retryDelayMs = ROUTE_B_PASSIVE_EXACT_RETRY_DELAY_MS,
            completionDelayMs = ROUTE_B_PASSIVE_EXACT_RETRY_DELAY_MS,
            pipelineContext = pipelineContext,
            passiveRestore = passiveRestore,
            completion = type(completion) == "function" and finish or nil,
        })

        if type(completion) == "function" then
            if ok == false then
                context.passivePhasePending = false
                finish(false, err, result)
            end
            return result, "deferred"
        end

        finish(ok == true, err, result)
        return result
    end

    local summary = LTM_SKILL_PASSIVE_APPLY:RunPendingPhase({
        context = context,
        build = build,
        targetSkillLineIds = targetSkillLineIds,
        pendingActivatedSkillLinesById = context.pendingActivatedSkillLinesById,
        pipelineContext = pipelineContext,
        onAllocatorModified = function(allocator)
            if type(allocator) ~= "table" then
                return
            end

            context.modifiedAllocators = context.modifiedAllocators or {}
            context.modifiedAllocators[#context.modifiedAllocators + 1] = allocator
        end,
    })
    context.passiveSummary = summary
    return summary
end

function LTM_SKILL_RESPEC_APPLY:ResolveRouteBTargetState(config)
    local context = config and config._pipelineContext or nil
    return LTM_PIPELINE_CONTEXT:GetTargetSubclassState(context)
end

function LTM_SKILL_RESPEC_APPLY:ExecuteRouteBPendingOperations(context)
    return LTM_SKILL_RESPEC_SUBCLASS_OPS:ExecutePendingOperations(self, context)
end

function LTM_SKILL_RESPEC_APPLY:CollectRouteBVerifySnapshot(context)
    local snapshot, snapshotErr, detail = LTM_SKILL_RESPEC_VERIFY:CollectRouteBVerifySnapshot(context)
    if snapshot == nil and snapshotErr == "subclass_verify_call_failed" then
        logging.Log("Route B collect verify error=" .. tostring(detail))
    end
    return snapshot, snapshotErr
end

function LTM_SKILL_RESPEC_APPLY:BuildRouteBCompletionSnapshot(context)
    return LTM_SKILL_RESPEC_COMPLETION:BuildRouteBCompletionSnapshot(context)
end

function LTM_SKILL_RESPEC_APPLY:IsRouteBCompletionSuccess(context, snapshot)
    return LTM_SKILL_RESPEC_COMPLETION:IsRouteBCompletionSuccess(context, snapshot)
end

-- Once verify matches, Route B waits for commit completion signals and only
-- then resumes the deferred pipeline continuation. UI restore stays in finalizer.
function LTM_SKILL_RESPEC_APPLY:PollRouteBCompletion(context, generation)
    return LTM_SKILL_RESPEC_COMPLETION:PollRouteBCompletion(self, context, generation)
end

function LTM_SKILL_RESPEC_APPLY:BeginRouteBCompletionWait(context, snapshot)
    return LTM_SKILL_RESPEC_COMPLETION:BeginRouteBCompletionWait(self, context, snapshot)
end

function LTM_SKILL_RESPEC_APPLY:KickOffRouteBPostCommitVerify(context, source)
    return LTM_SKILL_RESPEC_POST_COMMIT:KickOffPostCommitVerify(self, context, source)
end

function LTM_SKILL_RESPEC_APPLY:CheckRouteBConfirmationInner(context)
    -- Confirm only arms completion wait. A matched snapshot is not immediate success.
    if self.pendingContext ~= context or self:IsRouteBContextInactive(context) then
        return
    end

    if context.completionArmed == true then
        return
    end

    context.verifyStarted = true
    context.confirmAttemptIndex = (context.confirmAttemptIndex or 0) + 1
    local shouldLogAttempt = ShouldLogRouteBPollAttempt(context.confirmAttemptIndex, SKILL_RESPEC_CONFIRM_MAX_ATTEMPTS)
    local bypassSubclassVerify = self:ShouldBypassSubclassVerify(context)
    local snapshot = nil

    if not bypassSubclassVerify then
        local snapshotErr = nil
        snapshot, snapshotErr = self:CollectRouteBVerifySnapshot(context)
        if snapshot == nil then
            self:FinalizeRouteBFailure(context, "subclass_verify_snapshot_failed", {
                error = snapshotErr,
                result = context.resultCode,
            })
            return
        end

        if shouldLogAttempt or snapshot.ok ~= true or snapshot.matched == true then
            local retryScheduled = snapshot.ok == true
                and snapshot.matched ~= true
                and context.confirmAttemptIndex < SKILL_RESPEC_CONFIRM_MAX_ATTEMPTS
            logging.Log(
                "Route B verify result ok=" .. tostring(snapshot.ok == true),
                "matched=" .. tostring(snapshot.matched == true),
                "reason=" .. tostring(snapshot.reason or ""),
                "current=" .. logging.FormatLineIdList(snapshot.currentSkillLineIds),
                "target=" .. logging.FormatLineIdList(snapshot.targetSkillLineIds),
                "attempt=" .. tostring(context.confirmAttemptIndex),
                "retryScheduled=" .. tostring(retryScheduled)
            )
        end
        if snapshot.ok ~= true then
            self:FinalizeRouteBFailure(context, "subclass_verify_failed", {
                result = context.resultCode,
                reason = snapshot.reason,
                currentSkillLineIds = snapshot.currentSkillLineIds,
                targetSkillLineIds = snapshot.targetSkillLineIds,
                verify = snapshot.verifyResult,
            })
            return
        end
    else
        logging.Log(
            "Route B verify result ok=true matched=true reason=subclass_ops_skipped",
            "attempt=" .. tostring(context.confirmAttemptIndex)
        )
    end

    if bypassSubclassVerify or snapshot.matched == true then
        if context.subclassOnlyMode == true then
            context.routeBSubclassOnlyExecuted = true
        end

        if self.pendingContext ~= context then
            return
        end

        if context.finished then
            return
        end

        if context.completionResolved == true then
            return
        end

        if context.completionArmed == true then
            return
        end

        self:BeginRouteBCompletionWait(context, snapshot or {})
        return
    end

    if context.confirmAttemptIndex >= SKILL_RESPEC_CONFIRM_MAX_ATTEMPTS then
        self:FinalizeRouteBFailure(context, "subclass_verify_mismatch", {
            result = context.resultCode,
            currentSkillLineIds = snapshot.currentSkillLineIds,
            targetSkillLineIds = snapshot.targetSkillLineIds,
            verify = snapshot.verifyResult,
        })
        return
    end

    zo_callLater(function()
        LTM_SKILL_RESPEC_APPLY:CheckRouteBConfirmation(context)
    end, SKILL_RESPEC_CONFIRM_RETRY_MS)
end

function LTM_SKILL_RESPEC_APPLY:CheckRouteBConfirmation(context)
    return self:RunRouteBCallback(context, "confirmation", function()
        self:CheckRouteBConfirmationInner(context)
    end)
end

function LTM_SKILL_RESPEC_APPLY:OnRouteBResultEvent(context, result)
    return LTM_SKILL_RESPEC_COMPLETION:OnRouteBResultEvent(self, context, result)
end

function LTM_SKILL_RESPEC_APPLY:OnRouteBCastEvent(context)
    return LTM_SKILL_RESPEC_COMPLETION:OnRouteBCastEvent(self, context)
end

function LTM_SKILL_RESPEC_APPLY:RegisterRouteBResultWait(context)
    return LTM_SKILL_RESPEC_COMPLETION:RegisterRouteBResultWait(self, context)
end

function LTM_SKILL_RESPEC_APPLY:ApplyRouteBChangesAndMaybeWait(context)
    return LTM_SKILL_RESPEC_POST_COMMIT:ApplyChangesAndMaybeWait(self, context)
end

function LTM_SKILL_RESPEC_APPLY:RunRouteBSubclassPhase(context)
    return self:ExecuteRouteBPendingOperations(context)
end

function LTM_SKILL_RESPEC_APPLY:IsSubclassOnlyMode(config)
    local pipelineContext = type(config) == "table" and config._pipelineContext or nil
    if LTM_PIPELINE_CONTEXT:GetSkillSettingsSkipReason(pipelineContext, "normal_skill_changes") ~= nil then
        return true
    end

    return LTM_PIPELINE_CONTEXT:GetPreflightMode(pipelineContext) == "subclass_only"
end

function LTM_SKILL_RESPEC_APPLY:RunRouteBPurchasePhase(context, skillTargetPlan)
    return self:ExecuteRouteBPendingPurchases(context, skillTargetPlan)
end

function LTM_SKILL_RESPEC_APPLY:RunRouteBClassMasteryReductionPhase(context)
    return LTM_SKILL_RESPEC_CLASS_MASTERY_REDUCE:Execute(self, context)
end

function LTM_SKILL_RESPEC_APPLY:RunRouteBClassMasteryPurchasePhase(context)
    return LTM_SKILL_RESPEC_CLASS_MASTERY_PURCHASE:Execute(self, context)
end

function LTM_SKILL_RESPEC_APPLY:RunRouteBMorphPhase(context, postPurchasePlan)
    local preCommitPlan = postPurchasePlan
    local morphPassCount = 0
    local finalReadiness = nil

    while true do
        finalReadiness = self:GetRouteBCommitReadiness(preCommitPlan, context)
        if (finalReadiness.unexpectedMorphCount or 0) == 0 then
            break
        end
        morphPassCount = morphPassCount + 1
        if morphPassCount > ROUTE_B_MORPH_MAX_PASSES then
            return nil, "route_b_morph_substep_only", {
                skillTargetPlanAfterMorph = preCommitPlan,
                morphPassCount = morphPassCount - 1,
            }
        end

        self:AuditRouteBMorphTargets(context, preCommitPlan)
        local morphOk, morphErr, morphSummary = self:ExecuteRouteBPendingMorphs(context)
        self:ApplyRouteBMorphOutcomeSummary(context, morphSummary)
        if not morphOk then
            return nil, morphErr, {
                failedMorphTarget = type(morphSummary) == "table" and morphSummary.hardFailureTarget or nil,
                morphOutcomeSummary = morphSummary,
                skillTargetPlanAfterMorph = preCommitPlan,
                morphPassCount = morphPassCount,
            }
        end

        preCommitPlan = self:BuildRouteBSkillTargetPlan(context.routeBConfig)
        context.skillTargetPlan = preCommitPlan
        self:LogRouteBSkillTargetPlan("Route B morph final summary", preCommitPlan)
    end

    if finalReadiness.ok ~= true then
        local blockedCode, readiness = self:ResolveRouteBPreCommitBlockedCode(
            preCommitPlan,
            finalReadiness,
            "route_b_morph_substep_only"
        )
        if blockedCode == "cryptcanon_special_ultimate_requires_overwrite" then
            self:NotifyCryptCanonOverwriteRequired(context)
        end
        return nil, blockedCode, {
            skillTargetPlanAfterMorph = preCommitPlan,
            morphPassCount = morphPassCount,
            readiness = readiness,
        }
    end

    return preCommitPlan, nil, {
        morphPassCount = morphPassCount,
    }
end

function LTM_SKILL_RESPEC_APPLY:ContinueRouteBAfterPassivePhase(context)
    if self.pendingContext ~= context or context.finished then
        return
    end

    local pendingState = self:GetRouteBPendingChangesState()
    if pendingState.pendingChanges == false then
        context.commitPerformed = false
        context.noCommitPendingState = pendingState
        context.postCommitVerifyRetryAttemptIndex = 0
        LTM_SKILL_RESPEC_POST_COMMIT:RunPostCommitVerifyRetry(self, context)
        return
    end

    context.commitPerformed = true
    local commitOk, commitErr = self:RunRouteBCommitPhase(context)
    if commitOk == nil then
        return
    end
    if not commitOk then
        self:FinalizeRouteBFailure(context, commitErr)
        return
    end
end

function LTM_SKILL_RESPEC_APPLY:RunRouteBCommitPhase(context)
    local eventManager = SHARED_UTIL:GetEventManager()
    local hasEventManager = type(eventManager) == "table"
    local hasResultEvent = EVENT_SKILL_RESPEC_RESULT ~= nil
    local hasSkillsManager = type(SKILLS_AND_ACTION_BAR_MANAGER) == "table"
    local hasApplyChanges = hasSkillsManager and type(SKILLS_AND_ACTION_BAR_MANAGER.ApplyChanges) == "function"

    if not hasResultEvent then
        return false, "event_skill_respec_result_unavailable"
    end

    if not hasSkillsManager then
        return false, "skills_and_action_bar_manager_unavailable"
    end

    if not hasApplyChanges then
        return false, "apply_changes_unavailable"
    end

    if hasEventManager then
        context.resultWaitMode = "event"
        if not self:RegisterRouteBResultWait(context) then
            return nil
        end
    else
        context.resultWaitMode = "degraded_verify_only"
    end

    self:ApplyRouteBChangesAndMaybeWait(context)
    return true
end

function LTM_SKILL_RESPEC_APPLY:CommitRouteBSubclassOnly(context)
    local opOk, opErr, failedOperation = self:RunRouteBSubclassPhase(context)
    if not opOk then
        self:FinalizeRouteBFailure(context, opErr, {
            failedOperation = failedOperation,
        })
        return
    end
    local reductionOk, reductionErr =
        LTM_ACTIVE_SKILL_RESTORE:ExecutePendingReductions(context.activeRestorePlan, context)
    if reductionOk ~= true then
        self:RevertRouteBPendingPreparation(context)
        self:FinalizeRouteBFailure(context, reductionErr or "active_reduction_failed")
        return
    end

    local postSubclassPlan = self:BuildRouteBSkillTargetPlan(context.routeBConfig)

    context.skillTargetPlan = postSubclassPlan
    self:LogRouteBSkillTargetPlan("Route B post-subclass target summary", postSubclassPlan)

    local masteryReduceOk, masteryReduceErr, masteryReduceSummary = self:RunRouteBClassMasteryReductionPhase(context)
    context.classMasteryReductionSummary = masteryReduceSummary
    if not masteryReduceOk then
        self:RevertRouteBPendingPreparation(context)
        self:FinalizeRouteBFailure(context, masteryReduceErr or "class_mastery_reduction_failed", {
            classMasteryReductionSummary = masteryReduceSummary,
        })
        return
    end

    local masteryPurchaseOk, masteryPurchaseErr, masteryPurchaseSummary = self:RunRouteBClassMasteryPurchasePhase(context)
    context.classMasteryPurchaseSummary = masteryPurchaseSummary
    if not masteryPurchaseOk then
        self:RevertRouteBPendingPreparation(context)
        self:FinalizeRouteBFailure(context, masteryPurchaseErr or "class_mastery_purchase_failed", {
            classMasteryReductionSummary = masteryReduceSummary,
            classMasteryPurchaseSummary = masteryPurchaseSummary,
        })
        return
    end

    if context.subclassOnlyMode == true then
        context.preCommitSkillTargetPlan = postSubclassPlan
        local pendingState = self:GetRouteBPendingChangesState()
        logging.Log(
            "Route B subclass-only mode",
            "pendingChanges=" .. tostring(pendingState.pendingChanges)
        )
        self:ContinueRouteBAfterPassivePhase(context)
        return
    end

    local purchaseOk, purchaseErr, purchaseSummary = self:RunRouteBPurchasePhase(context, postSubclassPlan)
    self:ApplyRouteBPurchaseOutcomeSummary(context, purchaseSummary)
    if not purchaseOk then
        self:RevertRouteBPendingPreparation(context)
        self:FinalizeRouteBFailure(context, purchaseErr, {
            error = purchaseErr,
            failedPurchaseTarget = type(purchaseSummary) == "table" and purchaseSummary.hardFailureTarget or nil,
            purchaseOutcomeSummary = purchaseSummary,
            skillTargetPlan = postSubclassPlan,
        })
        return
    end

    local postPurchasePlan = self:BuildRouteBSkillTargetPlan(context.routeBConfig)
    context.skillTargetPlan = postPurchasePlan
    self:LogRouteBSkillTargetPlan("Route B post-purchase target summary", postPurchasePlan)
    local preCommitPlan, morphErr, morphDetails = self:RunRouteBMorphPhase(context, postPurchasePlan)
    if preCommitPlan == nil then
        self:RevertRouteBPendingPreparation(context)
        self:FinalizeRouteBFailure(context, morphErr, {
            error = morphErr,
            skillTargetPlanAfterPurchase = postPurchasePlan,
            skillTargetPlanAfterMorph = morphDetails and morphDetails.skillTargetPlanAfterMorph or postPurchasePlan,
            morphPassCount = morphDetails and morphDetails.morphPassCount or 0,
            failedMorphTarget = morphDetails and morphDetails.failedMorphTarget or nil,
            readiness = morphDetails and morphDetails.readiness or nil,
        })
        return
    end

    context.preCommitSkillTargetPlan = preCommitPlan
    if self:ResolveRouteBVerifyMode(context) == "degraded" then
        self:ContinueRouteBAfterPassivePhase(context)
        return
    end
    local _, passiveState = self:RunRouteBPassivePhase(context, function(success, err)
        if success ~= true then
            self:RevertRouteBPendingPreparation(context)
            self:FinalizeRouteBFailure(context, err or "route_b_passive_exact_failed", {
                passiveSummary = context.passiveSummary,
            })
            return
        end

        self:ContinueRouteBAfterPassivePhase(context)
    end)
    if passiveState == "deferred" then
        return
    end

    self:ContinueRouteBAfterPassivePhase(context)
end

function LTM_SKILL_RESPEC_APPLY:ShouldBypassSubclassVerify(context)
    local skillTargetPlan = type(context) == "table" and context.preCommitSkillTargetPlan or nil
    local diagnostics = type(skillTargetPlan) == "table" and skillTargetPlan.diagnostics or nil
    local hasTransformTarget = type(context) == "table"
        and type(context.transformPlan) == "table"
        and context.transformPlan.hasTarget == true
        and (type(context.activeRestorePlan) ~= "table"
            or context.activeRestorePlan.neutralized ~= true)
    return type(diagnostics) == "table"
        and (diagnostics.subclassOpCount or 0) == 0
        and not hasTransformTarget
end

function LTM_SKILL_RESPEC_APPLY:ContinueRouteBReadyCheck(context, startAttemptIndex, waitAttemptIndex)
    if self.pendingContext ~= context or context.finished then
        return
    end

    startAttemptIndex = startAttemptIndex or 1
    waitAttemptIndex = waitAttemptIndex or 1
    context.startAttemptIndex = startAttemptIndex
    context.attemptIndex = waitAttemptIndex

    local ready, state = self:IsReadyForSubclass(context)

    if ready then
        MarkRouteBRespecInterfaceUsed(context)
        self:LogRouteBRespecEntryStart(context)
        self:CommitRouteBSubclassOnly(context)
        return
    end

    if waitAttemptIndex == 1 then
        if type(StartSkillRespecFromUI) ~= "function" then
            self:FinalizeRouteBFailure(context, "start_skill_respec_from_ui_unavailable")
            return
        end

        context.entryStartCount = (context.entryStartCount or 0) + 1
        self:LogRouteBRespecEntryStart(context)
        local startOk, startErr = pcall(StartSkillRespecFromUI)
        if not startOk then
            self:FinalizeRouteBFailure(context, "start_skill_respec_from_ui_failed", {
                error = tostring(startErr),
            })
            return
        end
        MarkRouteBRespecInterfaceUsed(context)
    end

    if waitAttemptIndex >= #SKILL_RESPEC_READY_RETRY_DELAYS_MS then
        if startAttemptIndex >= SKILL_RESPEC_MAX_START_ATTEMPTS then
            self:FinalizeRouteBFailure(context, "route_b_ready_timeout", {
                state = state,
                startAttempt = startAttemptIndex,
                waitAttempt = waitAttemptIndex,
            })
            return
        end

        logging.Log(
            "Route B respec entry retry",
            "startAttempt=" .. tostring(startAttemptIndex),
            "nextStartAttempt=" .. tostring(startAttemptIndex + 1),
            "delayMs=" .. tostring(SKILL_RESPEC_START_RETRY_DELAY_MS)
        )
        zo_callLater(function()
            LTM_SKILL_RESPEC_APPLY:ContinueRouteBReadyCheck(context, startAttemptIndex + 1, 1)
        end, SKILL_RESPEC_START_RETRY_DELAY_MS)
        return
    end

    local nextWaitAttemptIndex = waitAttemptIndex + 1
    local delayMs = SKILL_RESPEC_READY_RETRY_DELAYS_MS[nextWaitAttemptIndex]
        or SKILL_RESPEC_READY_RETRY_DELAYS_MS[#SKILL_RESPEC_READY_RETRY_DELAYS_MS]
        or 0
    zo_callLater(function()
        LTM_SKILL_RESPEC_APPLY:ContinueRouteBReadyCheck(context, startAttemptIndex, nextWaitAttemptIndex)
    end, delayMs)
end

function LTM_SKILL_RESPEC_APPLY:CreateRouteBContext(config, subclassPlan)
    local targetState = self:ResolveRouteBTargetState(config)
    local pipelinePlan = config and config._pipelinePlan or nil
    local transformPlan = type(pipelinePlan) == "table"
        and type(pipelinePlan.configs) == "table"
        and type(pipelinePlan.configs.skillRespec) == "table"
        and pipelinePlan.configs.skillRespec.transformPlan
        or nil
    local activeRestorePlan = type(pipelinePlan) == "table"
        and type(pipelinePlan.configs) == "table"
        and type(pipelinePlan.configs.skillRespec) == "table"
        and pipelinePlan.configs.skillRespec.activeRestorePlan
        or nil
    return {
        runId = (self.nextRouteBRunId or 0) + 1,
        plan = subclassPlan,
        targetState = targetState,
        attemptIndex = 0,
        confirmAttemptIndex = 0,
        completionAttemptIndex = 0,
        postCommitVerifyRetryAttemptIndex = 0,
        finished = false,
        routeBFinalized = false,
        respecInterfaceUsed = false,
        modifiedAllocators = {},
        pendingActivatedSkillLinesById = {},
        resultReceived = false,
        resultCode = nil,
        commitAttemptIndex = 0,
        commitAttemptGeneration = 0,
        commitRetryCount = 0,
        commitRetryScheduled = false,
        commitSent = false,
        commitAccepted = false,
        commitAcceptanceSource = nil,
        commitObserveAttemptIndex = 0,
        castStarted = false,
        castStartedAt = nil,
        verifyMatched = false,
        verifyMatchedAt = nil,
        postCommitWatchdogScheduled = false,
        completionArmed = false,
        completionResolved = false,
        completionSuccessSnapshot = nil,
        completionSuccessKind = nil,
        resultWaitGeneration = 0,
        purchaseOutcomeSummary = nil,
        morphOutcomeSummary = nil,
        expectedMissingActiveTargets = {
            purchases = {},
            morphs = {},
            purchaseByProgression = {},
            morphByProgression = {},
        },
        subclassOnlyMode = self:IsSubclassOnlyMode(config),
        routeBConfig = config,
        pipelineContext = config._pipelineContext,
        pipelineContinuation = config._pipelineContinuation,
        originPhase = config._pipelinePhaseName,
        transformPlan = transformPlan,
        activeRestorePlan = activeRestorePlan,
    }
end

function LTM_SKILL_RESPEC_APPLY:RunRouteBSubclassOnly(config)
    local plan = config and config._pipelinePlan or nil
    if type(plan) ~= "table" then
        self:SetLastResult(CreateFailureResult("pipeline_plan_missing"), config and config._pipelineContext)
        return false, "pipeline_plan_missing"
    end

    if plan.route ~= "B" then
        self:SetLastResult(CreateFailureResult("route_b_required"), config._pipelineContext)
        return false, "route_b_required"
    end

    local generalOk, generalResult = self:RunRouteBGeneralPrecheck(config)
    if not generalOk then
        self:SetLastResult(CreateFailureResult(generalResult), config._pipelineContext)
        return false, generalResult
    end

    local dirtyOk, dirtyCode, dirtyState = self:RunRouteBDirtyStatePrecheck(config)
    if not dirtyOk then
        self:SetLastResult(CreateFailureResult(dirtyCode, {
            dirtyState = dirtyState,
        }), config._pipelineContext)
        return false, dirtyCode
    end

    if type(zo_callLater) ~= "function" then
        self:SetLastResult(CreateFailureResult("zo_callLater_unavailable"), config._pipelineContext)
        return false, "zo_callLater_unavailable"
    end

    if self.pendingContext and not self.pendingContext.finished then
        self:SetLastResult(CreateFailureResult("route_b_pending_context_exists"), config._pipelineContext)
        return false, "route_b_pending_context_exists"
    end

    local context = self:CreateRouteBContext(config, generalResult)
    self.nextRouteBRunId = context.runId

    context.skillTargetPlan = self:BuildRouteBSkillTargetPlan(config)
    self:LogRouteBSkillTargetPlan("Route B target summary", context.skillTargetPlan)
    local ready = self:IsReadyForSubclass(context)
    self.pendingContext = context

    if ready then
        MarkRouteBRespecInterfaceUsed(context)
        self:LogRouteBRespecEntryStart(context)
        self:CommitRouteBSubclassOnly(context)
        return true, "deferred"
    end

    self:ContinueRouteBReadyCheck(context)
    return true, "deferred"
end

function LTM_SKILL_RESPEC_APPLY:Run(config)
    config = config or {}
    local pipelineContext = config._pipelineContext
    self:SetLastResult(nil, pipelineContext)

    local plan = config._pipelinePlan
    local route = type(plan) == "table" and plan.route or nil
    if route == "B" then
        local gateOk, gateErr = self:BeginSharedCooldownGateWait(config)
        if gateOk == true and gateErr == "deferred" then
            return true, "deferred"
        end
        if gateOk == false and gateErr ~= nil then
            self:SetLastResult(CreateFailureResult(gateErr), pipelineContext)
            logging.Log("skill respec gate wait failed", tostring(gateErr))
            return false, gateErr
        end
    end

    if route == "B" then
        return self:RunRouteBSubclassOnly(config)
    end

    self:SetLastResult(CreateFailureResult("skill_respec_route_not_selected"), pipelineContext)
    logging.Log("skill_respec_route_not_selected")
    return false, "skill_respec_route_not_selected"
end
