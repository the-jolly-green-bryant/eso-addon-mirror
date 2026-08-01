local Addon = LarvalTearMod
local Log = Addon.Common.Log
local LTM_SKILL_PASSIVE_APPLY = Addon.Modules.SkillPassiveApply

local M = LTM_SKILL_PASSIVE_APPLY
local SHARED_UTIL = Addon.Common.Util
local LTM_APPLY_COOLDOWN_GATE = Addon.Modules.ApplyCooldownGate
local LTM_PASSIVE_SNAPSHOT_APPLY = Addon.Modules.PassiveSnapshotApply
local LTM_PIPELINE_CONTEXT = Addon.Modules.PipelineContext
local LTM_SKILL_SNAPSHOT_AUDIT = Addon.Modules.SkillSnapshotAudit
local LTM_SKILL_PASSIVE = Addon.Modules.SkillPassive
local LTM_BUILD_CODEC = Addon.Modules.BuildCodec

local PASSIVE_READY_RETRY_MS = 200
local PASSIVE_READY_MAX_ATTEMPTS = 20
local PASSIVE_COMPLETION_POLL_MS = 250
local PASSIVE_COMPLETION_MAX_ATTEMPTS = 40
local PASSIVE_EXACT_RETRY_DELAY_MS = 50
local PASSIVE_EXACT_MAX_ATTEMPTS = 5
local PASSIVE_EXACT_COMPLETION_DELAY_MS = 50
local PASSIVE_DIRECT_SCENE_NAME_KEYBOARD = "skills"
local PASSIVE_DIRECT_SCENE_NAME_GAMEPAD = "gamepad_skills_root"
local PASSIVE_AUTO_FILL_INSUFFICIENT_POINTS_PARTIAL = "passive_auto_fill_insufficient_points_partial"

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

local function CreateSkippedResult(code, details)
    details = type(details) == "table" and details or {}
    details.status = "skipped"
    details.reason = code
    details.intentional = true
    return {
        ok = true,
        skipped = true,
        code = code,
        details = details,
    }
end

local function NormalizeLineIdList(lineIds)
    if type(SHARED_UTIL) == "table" and type(SHARED_UTIL.NormalizeLineIdList) == "function" then
        return SHARED_UTIL:NormalizeLineIdList(lineIds)
    end

    return type(lineIds) == "table" and lineIds or {}
end

local function HasPendingSkillChanges()
    if type(SKILLS_AND_ACTION_BAR_MANAGER) ~= "table"
        or type(SKILLS_AND_ACTION_BAR_MANAGER.HasAnyPendingChanges) ~= "function" then
        return nil
    end

    return SKILLS_AND_ACTION_BAR_MANAGER:HasAnyPendingChanges()
end

local function BuildPendingSkillChangeSnapshot()
    local hasPendingChanges = HasPendingSkillChanges()
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

    return {
        hasPendingChanges = hasPendingChanges,
        allocationPending = allocationPending,
        linePending = linePending,
        actionBarPending = actionBarPending,
        pendingChangesIncurCost = pendingChangesIncurCost,
    }
end

local function IsActionBarOnlyPendingSkillChanges(snapshot)
    snapshot = type(snapshot) == "table" and snapshot or BuildPendingSkillChangeSnapshot()
    if snapshot.hasPendingChanges ~= true then
        return false
    end

    local substantivePending = snapshot.allocationPending == true
        or snapshot.linePending == true
        or snapshot.pendingChangesIncurCost == true

    return substantivePending ~= true and snapshot.actionBarPending == true
end

local function CapturePassiveSnapshot()
    if type(LTM_SKILL_SNAPSHOT_AUDIT) ~= "table"
        or type(LTM_SKILL_SNAPSHOT_AUDIT.CaptureCurrentSnapshot) ~= "function" then
        return nil
    end

    local ok, snapshot = pcall(LTM_SKILL_SNAPSHOT_AUDIT.CaptureCurrentSnapshot, LTM_SKILL_SNAPSHOT_AUDIT)
    if ok and type(snapshot) == "table" then
        return snapshot
    end

    return nil
end

local function BuildPassiveLineIdSet(targetSkillLineIds)
    local set = {}
    for _, skillLineId in ipairs(targetSkillLineIds or {}) do
        if type(skillLineId) == "number" and skillLineId > 0 then
            set[skillLineId] = true
        end
    end
    return set
end

local function BuildTrackedPassiveSnapshot(snapshot, targetSkillLineIds)
    local tracked = {
        totalPoints = 0,
        skillCount = 0,
        passiveByKey = {},
    }

    if type(snapshot) ~= "table" then
        return tracked
    end

    local targetLineIdSet = BuildPassiveLineIdSet(targetSkillLineIds)
    for _, lineEntry in ipairs(snapshot.lines or {}) do
        local skillLineId = tonumber(lineEntry.skillLineId) or 0
        if targetLineIdSet[skillLineId] == true then
            for _, skillEntry in ipairs(lineEntry.skills or {}) do
                if type(skillEntry) == "table" and skillEntry.isPassive == true then
                    local skillIndex = tonumber(skillEntry.skillIndex) or 0
                    local passiveKey = tostring(skillLineId) .. ":" .. tostring(skillIndex)
                    local pointsAllocated = tonumber(skillEntry.pointsAllocated) or 0
                    tracked.passiveByKey[passiveKey] = {
                        pointsAllocated = pointsAllocated,
                        currentRank = tonumber(skillEntry.currentRank) or 0,
                        numRanks = tonumber(skillEntry.numRanks) or 0,
                    }
                    tracked.totalPoints = tracked.totalPoints + pointsAllocated
                    tracked.skillCount = tracked.skillCount + 1
                end
            end
        end
    end

    return tracked
end

local function CompareTrackedPassiveSnapshots(beforeSnapshot, afterSnapshot)
    local comparison = {
        changed = false,
        totalPointDelta = 0,
        changedPassiveCount = 0,
    }

    local seenKeys = {}
    for passiveKey, afterEntry in pairs(type(afterSnapshot) == "table" and afterSnapshot.passiveByKey or {}) do
        seenKeys[passiveKey] = true
        local beforeEntry = type(beforeSnapshot) == "table" and beforeSnapshot.passiveByKey and beforeSnapshot.passiveByKey[passiveKey] or nil
        local beforePoints = type(beforeEntry) == "table" and (tonumber(beforeEntry.pointsAllocated) or 0) or 0
        local afterPoints = type(afterEntry) == "table" and (tonumber(afterEntry.pointsAllocated) or 0) or 0
        local delta = afterPoints - beforePoints
        if delta ~= 0 then
            comparison.changed = true
            comparison.totalPointDelta = comparison.totalPointDelta + delta
            comparison.changedPassiveCount = comparison.changedPassiveCount + 1
        end
    end

    for passiveKey, beforeEntry in pairs(type(beforeSnapshot) == "table" and beforeSnapshot.passiveByKey or {}) do
        if not seenKeys[passiveKey] then
            local beforePoints = type(beforeEntry) == "table" and (tonumber(beforeEntry.pointsAllocated) or 0) or 0
            if beforePoints ~= 0 then
                comparison.changed = true
                comparison.totalPointDelta = comparison.totalPointDelta - beforePoints
                comparison.changedPassiveCount = comparison.changedPassiveCount + 1
            end
        end
    end

    return comparison
end

local function IsReadyForPassiveApply()
    local sceneReady = SCENE_MANAGER:IsShowing(PASSIVE_DIRECT_SCENE_NAME_KEYBOARD)
        or SCENE_MANAGER:IsShowing(PASSIVE_DIRECT_SCENE_NAME_GAMEPAD)
    local hasSkillsManager = type(SKILLS_AND_ACTION_BAR_MANAGER) == "table"
    local allocationMode = hasSkillsManager
        and type(SKILLS_AND_ACTION_BAR_MANAGER.GetSkillPointAllocationMode) == "function"
        and SKILLS_AND_ACTION_BAR_MANAGER:GetSkillPointAllocationMode()
        or nil
    local interactionType = type(GetInteractionType) == "function" and GetInteractionType() or nil
    local purchaseOnlyMode = (SKILL_POINT_ALLOCATION_MODE_PURCHASE_ONLY ~= nil and allocationMode == SKILL_POINT_ALLOCATION_MODE_PURCHASE_ONLY)
        or allocationMode == 0

    return sceneReady
        and hasSkillsManager
        and purchaseOnlyMode
        and (INTERACTION_SKILL_RESPEC == nil or interactionType ~= INTERACTION_SKILL_RESPEC)
end

local function ShowPassivePurchaseScene()
    if type(IsInGamepadPreferredMode) == "function" and IsInGamepadPreferredMode() then
        if type(MAIN_MENU_GAMEPAD) == "table" and type(MAIN_MENU_GAMEPAD.ShowScene) == "function" then
            MAIN_MENU_GAMEPAD:ShowScene(PASSIVE_DIRECT_SCENE_NAME_GAMEPAD)
            return true
        end
        SCENE_MANAGER:Push(PASSIVE_DIRECT_SCENE_NAME_GAMEPAD)
        return true
    end

    SCENE_MANAGER:Push(PASSIVE_DIRECT_SCENE_NAME_KEYBOARD)
    return true
end

local function BuildPassiveCompletionSnapshot(context)
    local pendingChanges = HasPendingSkillChanges()
    local allocationMode = type(SKILLS_AND_ACTION_BAR_MANAGER) == "table"
        and type(SKILLS_AND_ACTION_BAR_MANAGER.GetSkillPointAllocationMode) == "function"
        and SKILLS_AND_ACTION_BAR_MANAGER:GetSkillPointAllocationMode()
        or nil
    local interactionType = type(GetInteractionType) == "function" and GetInteractionType() or nil

    return {
        pendingChanges = pendingChanges,
        allocationMode = allocationMode,
        interactionType = interactionType,
    }
end

local function ResolveTargetSkillLineIds(build, fallbackLineIds)
    local explicitLineIds = type(build) == "table"
        and type(build.subclass) == "table"
        and build.subclass.targetSkillLineIds
        or nil
    return NormalizeLineIdList(explicitLineIds or fallbackLineIds)
end

local function IsExactPassivePolicy(policy)
    return policy == "class_only" or policy == "all"
end

local function ResolveSpSaverPassiveSkip(pipelineContext)
    local reason = type(LTM_PIPELINE_CONTEXT) == "table"
        and type(LTM_PIPELINE_CONTEXT.GetSpSaverSkipReason) == "function"
        and LTM_PIPELINE_CONTEXT:GetSpSaverSkipReason(pipelineContext, "normal_passive_changes")
        or nil
    return reason ~= nil, reason
end

local function RecordSpSaverPassiveSkip(pipelineContext, reason)
    if type(LTM_PIPELINE_CONTEXT) == "table"
        and type(LTM_PIPELINE_CONTEXT.RecordSpSaverSkip) == "function" then
        LTM_PIPELINE_CONTEXT:RecordSpSaverSkip(
            pipelineContext,
            "normal_passive_changes",
            reason
        )
    end
end

local function BuildSpSaverSkippedSummary(build, targetSkillLineIds, reason)
    return {
        ok = true,
        skipped = true,
        policy = LTM_BUILD_CODEC:NormalizePassivePolicy(type(build) == "table" and build.passivePolicy or nil),
        targetLineCount = #(targetSkillLineIds or {}),
        targetSkillLineIds = targetSkillLineIds,
        restoredCount = 0,
        skippedCount = 0,
        warningCount = 0,
        reasonCounts = {
            [reason] = 1,
        },
        spSaverReason = reason,
    }
end

local function BuildAutoFillPartialSuccessResult(summary)
    if type(summary) ~= "table" then
        return nil
    end

    local policy = summary.policy
    local skippedCount = tonumber(summary.skippedCount) or 0
    local reasonCounts = type(summary.reasonCounts) == "table" and summary.reasonCounts or nil
    local insufficientSkillPointCount = type(reasonCounts) == "table"
        and (tonumber(reasonCounts.insufficient_skill_points) or 0)
        or 0

    if policy ~= "class_all_purchase"
        or skippedCount <= 0
        or insufficientSkillPointCount <= 0 then
        return nil
    end

    return {
        sourcePhase = "PassiveSkills",
        resultCode = PASSIVE_AUTO_FILL_INSUFFICIENT_POINTS_PARTIAL,
        reasons = {
            "passive_ranks_not_restored",
        },
        residualSummary = {
            policy = policy,
            targetLineCount = tonumber(summary.targetLineCount) or 0,
            targetSkillLineIds = summary.targetSkillLineIds,
            targetPassiveCount = tonumber(summary.targetPassiveCount) or 0,
            restoredCount = tonumber(summary.restoredCount) or 0,
            skippedCount = skippedCount,
            warningCount = tonumber(summary.warningCount) or 0,
            insufficientSkillPointCount = insufficientSkillPointCount,
            reasonCounts = reasonCounts,
        },
    }
end

function M:GetLastResult()
    return self.lastResult
end

function M:SetLastResult(result)
    self.lastResult = result
end

function M:RecordAutoFillPartialSuccess(pipelineContext, summary)
    if type(pipelineContext) ~= "table" then
        return nil
    end

    local partialResult = BuildAutoFillPartialSuccessResult(summary)
    if type(partialResult) ~= "table" then
        return nil
    end

    partialResult.domain = "PassiveSkills"
    partialResult.severity = "partial"
    return LTM_PIPELINE_CONTEXT:RecordDomainResult(pipelineContext, partialResult)
end

function M:Log(...)
    if type(Log.LogDebugSummary) == "function" then
        Log.LogDebugSummary(...)
    end
end

function M:ResolvePassiveOnlyEligibility(build, pipelinePlan)
    local passivePolicy = LTM_BUILD_CODEC:NormalizePassivePolicy(type(build) == "table" and build.passivePolicy or nil)
    local targetSkillLineIds = ResolveTargetSkillLineIds(build)

    if passivePolicy ~= "class_all_purchase" then
        return false, "policy_none", {
            passivePolicy = passivePolicy,
            targetSkillLineIds = targetSkillLineIds,
        }
    end

    if #targetSkillLineIds == 0 then
        return false, "no_target_lines", {
            passivePolicy = passivePolicy,
            targetSkillLineIds = targetSkillLineIds,
        }
    end

    if type(pipelinePlan) ~= "table" then
        return false, "pipeline_plan_unavailable", {
            passivePolicy = passivePolicy,
            targetSkillLineIds = targetSkillLineIds,
        }
    end

    local eligible = pipelinePlan.route == "A"
        and pipelinePlan.needsRespec ~= true
        and pipelinePlan.needsSubclassChange ~= true
        and pipelinePlan.needsPurchaseChange ~= true
        and pipelinePlan.needsMorphChange ~= true
        and pipelinePlan.needsStandalonePassiveAutoFill == true
    local reason = nil
    if not eligible then
        reason = "passive_only_requires_matching_skill_state"
    end

    return eligible, reason, {
        passivePolicy = passivePolicy,
        targetSkillLineIds = targetSkillLineIds,
        plan = pipelinePlan,
    }
end

function M:RunPendingPhase(input)
    local build = type(input) == "table" and input.build or nil
    local passivePolicy = LTM_BUILD_CODEC:NormalizePassivePolicy(type(build) == "table" and build.passivePolicy or nil)
    local targetSkillLineIds = ResolveTargetSkillLineIds(build, type(input) == "table" and input.targetSkillLineIds or nil)
    local modifiedAllocators = {}
    local seenAllocators = {}
    local pendingContext = type(input) == "table" and input.context or nil
    local pipelineContext = type(input) == "table" and input.pipelineContext or nil
    if type(pipelineContext) ~= "table" and type(pendingContext) == "table" then
        pipelineContext = pendingContext.pipelineContext
    end
    local skipForSpSaver, spSaverReason = ResolveSpSaverPassiveSkip(pipelineContext)
    if skipForSpSaver then
        RecordSpSaverPassiveSkip(pipelineContext, spSaverReason)
        return BuildSpSaverSkippedSummary(build, targetSkillLineIds, spSaverReason), modifiedAllocators, nil
    end

    if type(LTM_SKILL_PASSIVE) ~= "table" or type(LTM_SKILL_PASSIVE.Run) ~= "function" then
        local summary = {
            ok = false,
            policy = passivePolicy,
            targetLineCount = #targetSkillLineIds,
            targetSkillLineIds = targetSkillLineIds,
            restoredCount = 0,
            skippedCount = 0,
            warningCount = 1,
            reasonCounts = {
                passive_module_unavailable = 1,
            },
        }
        self:SetLastResult(CreateFailureResult("passive_module_unavailable", {
            passiveSummary = summary,
        }))
        return summary, modifiedAllocators, "passive_module_unavailable"
    end

    local summary = LTM_SKILL_PASSIVE:Run({
        context = type(input) == "table" and input.context or nil,
        build = build,
        passivePolicy = passivePolicy,
        targetSkillLineIds = targetSkillLineIds,
        pendingActivatedSkillLinesById = type(input) == "table" and input.pendingActivatedSkillLinesById or nil,
        onAllocatorModified = function(allocator)
            if type(allocator) ~= "table" or seenAllocators[allocator] == true then
                return
            end

            seenAllocators[allocator] = true
            modifiedAllocators[#modifiedAllocators + 1] = allocator
            local callback = type(input) == "table" and input.onAllocatorModified or nil
            if type(callback) == "function" then
                callback(allocator)
            end
        end,
    })

    return summary, modifiedAllocators, nil
end

function M:ClearPendingContext()
    self.pendingContext = nil
end

function M:Finalize(context, success, err, result)
    if self.pendingContext ~= context then
        return
    end

    self:ClearPendingContext()
    context.finished = true
    if success == true and type(result) == "table" and type(result.details) == "table" and result.skipped ~= true then
        result.details.commitAt = result.details.commitAt or SHARED_UTIL:GetFrameTimeMillisecondsSafe()
        result.details.mutatingAction = result.details.mutatingAction or "skill_purchase"
        self:RecordAutoFillPartialSuccess(context.pipelineContext, result.details.passiveSummary)
    end

    self:SetLastResult(result)

    if success == true and type(LTM_APPLY_COOLDOWN_GATE) == "table"
        and type(LTM_APPLY_COOLDOWN_GATE.RecordMutation) == "function" then
        LTM_APPLY_COOLDOWN_GATE:RecordMutation("skill", SHARED_UTIL:GetFrameTimeMillisecondsSafe())
    end

    local completion = context.completion
    if type(completion) == "function" then
        pcall(completion, success == true, err, result)
    end
end

local function BuildPipelinePhaseResult(success, summary, targetSkillLineIds, err, skipped)
    local details = {
        mode = "pipeline_phase",
        passiveSummary = summary,
        targetSkillLineIds = targetSkillLineIds,
    }
    if success == true and skipped ~= true then
        details.commitAt = SHARED_UTIL:GetFrameTimeMillisecondsSafe()
        details.mutatingAction = "skill_purchase"
    end

    if success == true then
        if skipped == true then
            return CreateSkippedResult(err or "passive_phase_skipped", details)
        end
        return CreateSuccessResult(details)
    end

    return CreateFailureResult(err or "passive_phase_failed", details)
end

local function BuildExactPipelinePhaseResult(success, result, targetSkillLineIds, err)
    local details = {
        mode = "exact_restore",
        passiveSummary = result,
        targetSkillLineIds = targetSkillLineIds,
    }
    if type(result) == "table" then
        details.finalStatus = result.finalStatus
        details.resultCode = result.resultCode
        details.aggregateSummary = result.aggregateSummary
    end
    if success == true then
        if type(result) == "table" and (tonumber(result.appliedCount) or 0) > 0 then
            details.commitAt = SHARED_UTIL:GetFrameTimeMillisecondsSafe()
            details.mutatingAction = "passive_exact_restore"
        end
        return CreateSuccessResult(details)
    end
    return CreateFailureResult(err or "passive_exact_restore_failed", details)
end

function M:RunExactRestorePhase(build, targetSkillLineIds, continuation, pipelineContext)
    local skipForSpSaver, spSaverReason = ResolveSpSaverPassiveSkip(pipelineContext)
    if skipForSpSaver then
        RecordSpSaverPassiveSkip(pipelineContext, spSaverReason)
        local summary = BuildSpSaverSkippedSummary(build, targetSkillLineIds, spSaverReason)
        self:SetLastResult(CreateSkippedResult(spSaverReason, {
            mode = "exact_restore",
            passiveSummary = summary,
            targetSkillLineIds = targetSkillLineIds,
        }))
        return true
    end

    if type(LTM_PASSIVE_SNAPSHOT_APPLY) ~= "table"
        or type(LTM_PASSIVE_SNAPSHOT_APPLY.RunExactRestore) ~= "function" then
        self:SetLastResult(BuildExactPipelinePhaseResult(false, nil, targetSkillLineIds, "passive_snapshot_apply_unavailable"))
        return false, "passive_snapshot_apply_unavailable"
    end

    local context = {
        build = build,
        continuation = continuation,
        finished = false,
        mode = "exact_restore",
        targetSkillLineIds = targetSkillLineIds,
        pipelineContext = pipelineContext,
    }
    self.pendingContext = context

    if IsReadyForPassiveApply() then
        self:CommitExactRestore(context)
        return true, "deferred"
    end

    self:ContinueReadyCheck(context)
    return true, "deferred"
end

function M:CommitExactRestore(context)
    if self.pendingContext ~= context or context.finished then
        return
    end

    local function finish(success, err, result)
        if M.pendingContext ~= context then
            return
        end
        if type(result) == "table" then
            result.modifiedAllocatorSet = nil
            result.modifiedAllocators = nil
        end
        context.finished = true
        M:ClearPendingContext()
        if success == true
            and type(context.pipelineContext) == "table"
            and type(result) == "table"
            and type(result.partialSuccessResult) == "table" then
            LTM_PIPELINE_CONTEXT:RecordDomainResult(context.pipelineContext, result.partialSuccessResult)
        end
        M:SetLastResult(BuildExactPipelinePhaseResult(success == true, result, context.targetSkillLineIds, err))
        if type(context.continuation) == "function" then
            context.continuation(success == true, err)
        end
    end

    local skipForSpSaver, spSaverReason = ResolveSpSaverPassiveSkip(context.pipelineContext)
    if skipForSpSaver then
        RecordSpSaverPassiveSkip(context.pipelineContext, spSaverReason)
        finish(true, nil, BuildSpSaverSkippedSummary(context.build, context.targetSkillLineIds, spSaverReason))
        return
    end

    local ok, runErr = LTM_PASSIVE_SNAPSHOT_APPLY:RunExactRestore(context.build, {
        operationMode = "standalone",
        allowedOperations = {
            purchase = true,
            reduction = false,
        },
        maxAttempts = PASSIVE_EXACT_MAX_ATTEMPTS,
        retryDelayMs = PASSIVE_EXACT_RETRY_DELAY_MS,
        completionDelayMs = PASSIVE_EXACT_COMPLETION_DELAY_MS,
        pipelineContext = context.pipelineContext,
        completion = finish,
    })

    if ok == false then
        context.finished = true
        self:ClearPendingContext()
        self:SetLastResult(BuildExactPipelinePhaseResult(false, nil, context.targetSkillLineIds, runErr))
        if type(context.continuation) == "function" then
            context.continuation(false, runErr)
        end
    end
end

function M:PollCompletion(context)
    if self.pendingContext ~= context or context.finished or context.completionResolved == true then
        return
    end

    context.completionAttemptIndex = (context.completionAttemptIndex or 0) + 1

    local completionSnapshot = BuildPassiveCompletionSnapshot(context)
    local currentSnapshot = CapturePassiveSnapshot()
    local trackedSnapshot = BuildTrackedPassiveSnapshot(currentSnapshot, context.targetSkillLineIds)
    local trackedComparison = CompareTrackedPassiveSnapshots(context.preCommitTrackedSnapshot, trackedSnapshot)
    local summary = type(context.passiveSummary) == "table" and context.passiveSummary or {}
    local expectedChanges = (tonumber(summary.restoredCount) or 0) > 0

    if context.completionAttemptIndex == 1
        or context.completionAttemptIndex == 5
        or context.completionAttemptIndex == 10
        or context.completionAttemptIndex == PASSIVE_COMPLETION_MAX_ATTEMPTS then
        self:Log(
            "Passive completion poll",
            "attempt=" .. tostring(context.completionAttemptIndex),
            "pendingChanges=" .. tostring(completionSnapshot.pendingChanges),
            "allocationMode=" .. tostring(completionSnapshot.allocationMode),
            "interactionType=" .. tostring(completionSnapshot.interactionType),
            "mode=direct_purchase",
            "totalPointDelta=" .. tostring(trackedComparison.totalPointDelta),
            "changedPassiveCount=" .. tostring(trackedComparison.changedPassiveCount),
            "availablePoints=" .. tostring(type(currentSnapshot) == "table" and currentSnapshot.availablePoints or nil)
        )
    end

    if trackedComparison.changed == true and trackedComparison.totalPointDelta > 0 then
        context.completionResolved = true
        self:Finalize(context, true, nil, CreateSuccessResult({
            mode = "passive_only",
            passiveSummary = context.passiveSummary,
            targetSkillLineIds = context.targetSkillLineIds,
            completion = {
                kind = "passiveSnapshotDiff",
                totalPointDelta = trackedComparison.totalPointDelta,
                changedPassiveCount = trackedComparison.changedPassiveCount,
                pendingChanges = completionSnapshot.pendingChanges,
                allocationMode = completionSnapshot.allocationMode,
                interactionType = completionSnapshot.interactionType,
            },
        }))
        return
    end

    if not expectedChanges
        and (completionSnapshot.pendingChanges == false or completionSnapshot.pendingChanges == nil) then
        context.completionResolved = true
        self:Finalize(context, true, nil, CreateSuccessResult({
            mode = "passive_only",
            passiveSummary = context.passiveSummary,
            targetSkillLineIds = context.targetSkillLineIds,
            completion = {
                kind = "passiveSnapshotNoExpectedChange",
                pendingChanges = completionSnapshot.pendingChanges,
                allocationMode = completionSnapshot.allocationMode,
                interactionType = completionSnapshot.interactionType,
            },
        }))
        return
    end

    if context.completionAttemptIndex >= PASSIVE_COMPLETION_MAX_ATTEMPTS then
        self:Finalize(context, false, "passive_only_result_timeout", CreateFailureResult("passive_only_result_timeout", {
            mode = "passive_only",
            passiveSummary = context.passiveSummary,
            targetSkillLineIds = context.targetSkillLineIds,
            timeoutMs = PASSIVE_COMPLETION_POLL_MS * PASSIVE_COMPLETION_MAX_ATTEMPTS,
            completion = {
                kind = "passiveDirectPurchasePoll",
                totalPointDelta = trackedComparison.totalPointDelta,
                changedPassiveCount = trackedComparison.changedPassiveCount,
                pendingChanges = completionSnapshot.pendingChanges,
                allocationMode = completionSnapshot.allocationMode,
                interactionType = completionSnapshot.interactionType,
            },
        }))
        return
    end

    zo_callLater(function()
        LTM_SKILL_PASSIVE_APPLY:PollCompletion(context)
    end, PASSIVE_COMPLETION_POLL_MS)
end

function M:CommitStandalone(context)
    context.preCommitTrackedSnapshot = BuildTrackedPassiveSnapshot(CapturePassiveSnapshot(), context.targetSkillLineIds)
    local summary, modifiedAllocators, pendingErr = self:RunPendingPhase({
        build = context.build,
        targetSkillLineIds = context.targetSkillLineIds,
        pipelineContext = context.pipelineContext,
    })
    context.passiveSummary = summary
    context.modifiedAllocators = modifiedAllocators

    if pendingErr ~= nil then
        self:Finalize(context, false, pendingErr, CreateFailureResult(pendingErr, {
            mode = "passive_only",
            passiveSummary = summary,
            targetSkillLineIds = context.targetSkillLineIds,
        }))
        return
    end

    if (tonumber(type(summary) == "table" and summary.restoredCount or nil) or 0) == 0 then
        self:Finalize(context, true, nil, CreateSuccessResult({
            mode = "passive_only",
            passiveSummary = summary,
            targetSkillLineIds = context.targetSkillLineIds,
            completion = {
                kind = "passiveNoOpComplete",
            },
        }))
        return
    end

    context.completionResolved = false
    context.completionAttemptIndex = 0
    self:PollCompletion(context)
end

function M:ContinueReadyCheck(context)
    if self.pendingContext ~= context or context.finished then
        return
    end

    context.readyAttemptIndex = (context.readyAttemptIndex or 0) + 1
    if IsReadyForPassiveApply() then
        if context.mode == "exact_restore" then
            self:CommitExactRestore(context)
        else
            self:CommitStandalone(context)
        end
        return
    end

    if context.readyAttemptIndex >= PASSIVE_READY_MAX_ATTEMPTS then
        self:Finalize(context, false, "passive_only_ready_timeout", CreateFailureResult("passive_only_ready_timeout", {
            targetSkillLineIds = context.targetSkillLineIds,
        }))
        return
    end

    if context.startInvoked ~= true then
        if not ShowPassivePurchaseScene() then
            self:Finalize(context, false, "show_passive_purchase_scene_unavailable", CreateFailureResult("show_passive_purchase_scene_unavailable"))
            return
        end
        context.startInvoked = true
    end

    zo_callLater(function()
        LTM_SKILL_PASSIVE_APPLY:ContinueReadyCheck(context)
    end, PASSIVE_READY_RETRY_MS)
end

function M:Run(config)
    self:SetLastResult(nil)

    local pipelineContext = type(config) == "table" and config._pipelineContext or nil
    local continuation = type(config) == "table" and config._pipelineContinuation or nil
    local build = type(pipelineContext) == "table" and pipelineContext.targetBuild
        or (type(config) == "table" and config.build or nil)
    local targetSkillLineIds = ResolveTargetSkillLineIds(build, type(config) == "table" and config.targetSkillLineIds or nil)

    if type(build) ~= "table" then
        self:SetLastResult(BuildPipelinePhaseResult(false, nil, targetSkillLineIds, "build_missing"))
        return false, "build_missing"
    end

    local skipForSpSaver, spSaverReason = ResolveSpSaverPassiveSkip(pipelineContext)
    if skipForSpSaver then
        RecordSpSaverPassiveSkip(pipelineContext, spSaverReason)
        local summary = BuildSpSaverSkippedSummary(build, targetSkillLineIds, spSaverReason)
        self:SetLastResult(BuildPipelinePhaseResult(true, summary, targetSkillLineIds, spSaverReason, true))
        return true
    end

    if self.pendingContext ~= nil and self.pendingContext.finished ~= true then
        self:SetLastResult(BuildPipelinePhaseResult(false, nil, targetSkillLineIds, "passive_only_context_exists"))
        return false, "passive_only_context_exists"
    end

    local pendingSnapshot = BuildPendingSkillChangeSnapshot()
    if pendingSnapshot.hasPendingChanges == true and not IsActionBarOnlyPendingSkillChanges(pendingSnapshot) then
        self:SetLastResult(BuildPipelinePhaseResult(false, nil, targetSkillLineIds, "skill_pending_changes_blocking_apply"))
        return false, "skill_pending_changes_blocking_apply"
    end

    if IsExactPassivePolicy(build.passivePolicy) then
        return self:RunExactRestorePhase(build, targetSkillLineIds, continuation, pipelineContext)
    end

    local pipelinePlan = type(config) == "table" and config._pipelinePlan or nil
    local eligible, eligibilityErr = self:ResolvePassiveOnlyEligibility(build, pipelinePlan)
    if not eligible then
        self:SetLastResult(BuildPipelinePhaseResult(true, nil, targetSkillLineIds, eligibilityErr or "passive_only_requires_matching_skill_state", true))
        return true
    end

    local context = {
        build = build,
        completion = function(success, completionErr, result)
            M:SetLastResult(result)
            if type(continuation) == "function" then
                continuation(success == true, completionErr)
            end
        end,
        finished = false,
        startInvoked = false,
        readyAttemptIndex = 0,
        pipelineContext = pipelineContext,
        targetSkillLineIds = targetSkillLineIds,
    }
    self.pendingContext = context

    self:Log(
        "Passive pipeline phase begin",
        "targetSkillLineIds=" .. tostring(table.concat(context.targetSkillLineIds or {}, ",")),
        "policy=" .. tostring(build.passivePolicy or "class_all_purchase")
    )

    if IsReadyForPassiveApply() then
        self:CommitStandalone(context)
        return true, "deferred"
    end

    self:ContinueReadyCheck(context)
    return true, "deferred"
end
