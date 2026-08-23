local Addon = LarvalTearMod
local Log = Addon.Common.Log
local M = Addon.Modules.ClassMasteryApply
local SHARED_UTIL = Addon.Common.Util
local LTM_APPLY_COOLDOWN_GATE = Addon.Modules.ApplyCooldownGate
local ClassMasteryLookup = Addon.Modules.ClassMasteryLookup

local MASTERY_READY_RETRY_MS = 200
local MASTERY_READY_MAX_ATTEMPTS = 40
local MASTERY_COMPLETION_POLL_MS = 250
local MASTERY_COMPLETION_MAX_ATTEMPTS = 40
local MASTERY_SCENE_NAME_KEYBOARD = "skills"
local MASTERY_SCENE_NAME_GAMEPAD = "gamepad_skills_root"

local function CreateSuccessResult(details)
    return {
        ok = true,
        details = details,
    }
end

local function CreateFailureResult(code, details)
    return {
        ok = false,
        code = code,
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

local function LogMastery(...)
    Log.LogDebugSummary(...)
end

local function CountTableEntries(entries)
    local count = 0
    for _ in pairs(entries or {}) do
        count = count + 1
    end
    return count
end

local function IncrementReason(summary, reason)
    if type(summary) ~= "table" or type(reason) ~= "string" or reason == "" then
        return
    end

    summary.reasonCounts[reason] = (summary.reasonCounts[reason] or 0) + 1
end

local function NormalizePurchasedAbilities(purchasedAbilities)
    if purchasedAbilities == nil then
        return nil
    end

    local normalized = {}
    if type(purchasedAbilities) ~= "table" then
        return normalized
    end

    for abilityId, rank in pairs(purchasedAbilities) do
        local normalizedAbilityId = tonumber(abilityId)
        local normalizedRank = tonumber(rank)
        if normalizedAbilityId ~= nil and normalizedAbilityId > 0
            and normalizedRank ~= nil and normalizedRank > 0 then
            normalized[math.floor(normalizedAbilityId)] = math.floor(normalizedRank)
        end
    end

    return normalized
end

local function BuildReasonSummary(reasonCounts)
    local reasons = {}
    for reason in pairs(reasonCounts or {}) do
        reasons[#reasons + 1] = reason
    end
    table.sort(reasons)

    if #reasons == 0 then
        return "none"
    end

    local parts = {}
    for _, reason in ipairs(reasons) do
        parts[#parts + 1] = tostring(reason) .. "=" .. tostring(reasonCounts[reason] or 0)
    end
    return table.concat(parts, ",")
end

local function BuildRankSummary(ranks)
    local abilityIds = {}
    for abilityId in pairs(ranks or {}) do
        abilityIds[#abilityIds + 1] = abilityId
    end
    table.sort(abilityIds)

    if #abilityIds == 0 then
        return "(none)"
    end

    local parts = {}
    for _, abilityId in ipairs(abilityIds) do
        parts[#parts + 1] = tostring(abilityId) .. ":" .. tostring(ranks[abilityId])
    end
    return table.concat(parts, ",")
end

local function BuildSummary(classMastery, purchasedAbilities)
    return {
        ok = true,
        targetSkillLineId = type(classMastery) == "table" and tonumber(classMastery.targetSkillLineId) or nil,
        targetAbilityCount = CountTableEntries(purchasedAbilities),
        restoredCount = 0,
        skippedCount = 0,
        warningCount = 0,
        reasonCounts = {},
    }
end

local function HasPendingSkillChanges()
    if type(SKILLS_AND_ACTION_BAR_MANAGER) ~= "table"
        or type(SKILLS_AND_ACTION_BAR_MANAGER.HasAnyPendingChanges) ~= "function" then
        return nil
    end

    return SKILLS_AND_ACTION_BAR_MANAGER:HasAnyPendingChanges()
end

local function IsSceneShowingSafe(sceneName)
    if type(SCENE_MANAGER) ~= "table" or type(SCENE_MANAGER.IsShowing) ~= "function" then
        return false
    end

    return SCENE_MANAGER:IsShowing(sceneName) == true
end

local function GetCurrentSceneNameSafe()
    if type(SCENE_MANAGER) ~= "table" then
        return nil
    end

    if type(SCENE_MANAGER.GetCurrentSceneName) == "function" then
        local sceneName = SCENE_MANAGER:GetCurrentSceneName()
        if sceneName ~= nil then
            return sceneName
        end
    end

    if type(SCENE_MANAGER.GetCurrentScene) ~= "function" then
        return nil
    end

    local currentScene = SCENE_MANAGER:GetCurrentScene()
    if type(currentScene) == "table" and type(currentScene.GetName) == "function" then
        return currentScene:GetName()
    end

    return nil
end

local function BuildMasteryReadySnapshot(context)
    local isShowingKeyboardSkills = IsSceneShowingSafe(MASTERY_SCENE_NAME_KEYBOARD)
    local isShowingGamepadSkills = IsSceneShowingSafe(MASTERY_SCENE_NAME_GAMEPAD)
    local sceneReady = isShowingKeyboardSkills or isShowingGamepadSkills
    local hasSkillsManager = type(SKILLS_AND_ACTION_BAR_MANAGER) == "table"
    local allocationMode = hasSkillsManager
        and type(SKILLS_AND_ACTION_BAR_MANAGER.GetSkillPointAllocationMode) == "function"
        and SKILLS_AND_ACTION_BAR_MANAGER:GetSkillPointAllocationMode()
        or nil
    local interactionType = type(GetInteractionType) == "function" and GetInteractionType() or nil
    local purchaseOnlyMode = (SKILL_POINT_ALLOCATION_MODE_PURCHASE_ONLY ~= nil and allocationMode == SKILL_POINT_ALLOCATION_MODE_PURCHASE_ONLY)
        or allocationMode == 0
    local ready = sceneReady
        and hasSkillsManager
        and purchaseOnlyMode
        and (INTERACTION_SKILL_RESPEC == nil or interactionType ~= INTERACTION_SKILL_RESPEC)
    local attempt = type(context) == "table" and tonumber(context.readyAttemptIndex) or nil

    return {
        attempt = attempt,
        maxAttempts = MASTERY_READY_MAX_ATTEMPTS,
        startInvoked = type(context) == "table" and context.startInvoked == true,
        isShowingKeyboardSkills = isShowingKeyboardSkills,
        isShowingGamepadSkills = isShowingGamepadSkills,
        currentSceneName = GetCurrentSceneNameSafe(),
        hasSkillsManager = hasSkillsManager,
        allocationMode = allocationMode,
        interactionType = interactionType,
        ready = ready == true,
        timeoutImminent = attempt ~= nil and attempt >= MASTERY_READY_MAX_ATTEMPTS - 1,
        timeoutPending = attempt ~= nil and attempt >= MASTERY_READY_MAX_ATTEMPTS,
    }
end

local function ShouldLogMasteryReadyAttempt(snapshot)
    local attempt = type(snapshot) == "table" and tonumber(snapshot.attempt) or nil
    if attempt == nil then
        return false
    end

    return snapshot.ready == true
        or snapshot.timeoutImminent == true
        or attempt == 1
        or attempt == 2
        or attempt == 5
        or attempt == 10
        or attempt == 15
        or attempt == 20
        or attempt == 30
end

local function LogMasteryReadySnapshot(message, snapshot)
    snapshot = type(snapshot) == "table" and snapshot or {}
    LogMastery(
        message,
        "attempt=" .. tostring(snapshot.attempt),
        "maxAttempts=" .. tostring(snapshot.maxAttempts),
        "startInvoked=" .. tostring(snapshot.startInvoked),
        "isShowingKeyboardSkills=" .. tostring(snapshot.isShowingKeyboardSkills),
        "isShowingGamepadSkills=" .. tostring(snapshot.isShowingGamepadSkills),
        "currentScene=" .. tostring(snapshot.currentSceneName),
        "hasSkillsManager=" .. tostring(snapshot.hasSkillsManager),
        "allocationMode=" .. tostring(snapshot.allocationMode),
        "interactionType=" .. tostring(snapshot.interactionType),
        "ready=" .. tostring(snapshot.ready),
        "timeoutImminent=" .. tostring(snapshot.timeoutImminent),
        "timeoutPending=" .. tostring(snapshot.timeoutPending)
    )
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

local function IsReadyForMasteryApply()
    return BuildMasteryReadySnapshot().ready == true
end

local function ShowMasteryPurchaseScene()
    if type(SCENE_MANAGER) ~= "table" then
        return false
    end

    if type(IsInGamepadPreferredMode) == "function" and IsInGamepadPreferredMode() then
        if type(MAIN_MENU_GAMEPAD) == "table" and type(MAIN_MENU_GAMEPAD.ShowScene) == "function" then
            MAIN_MENU_GAMEPAD:ShowScene(MASTERY_SCENE_NAME_GAMEPAD)
            return true
        end
        SCENE_MANAGER:Push(MASTERY_SCENE_NAME_GAMEPAD)
        return true
    end

    SCENE_MANAGER:Push(MASTERY_SCENE_NAME_KEYBOARD)
    return true
end

local function AreTargetsSatisfied(skillLineData, purchasedAbilities)
    local currentRanks = ClassMasteryLookup:CaptureCommittedRanks(skillLineData)
    for abilityId, targetRank in pairs(purchasedAbilities or {}) do
        if (tonumber(currentRanks[abilityId]) or 0) < (tonumber(targetRank) or 0) then
            return false
        end
    end
    return true
end

local function LogTargetSatisfaction(skillLineData, purchasedAbilities, summary)
    local currentRanks = type(skillLineData) == "table"
        and ClassMasteryLookup:CaptureCommittedRanks(skillLineData)
        or {}
    local missingCount = 0
    for abilityId, targetRank in pairs(purchasedAbilities or {}) do
        if (tonumber(currentRanks[abilityId]) or 0) < (tonumber(targetRank) or 0) then
            missingCount = missingCount + 1
        end
    end

    if missingCount > 0 then
        IncrementReason(summary, "target_not_satisfied")
        summary.warningCount = (summary.warningCount or 0) + 1
    end

    LogMastery(
        "Mastery target satisfaction",
        "targetSkillLineId=" .. tostring(summary and summary.targetSkillLineId or nil),
        "satisfied=" .. tostring(missingCount == 0),
        "missingCount=" .. tostring(missingCount),
        "currentRanks=" .. BuildRankSummary(currentRanks),
        "targetRanks=" .. BuildRankSummary(purchasedAbilities)
    )

    return missingCount == 0, missingCount
end

local function TryRestoreMasterySkill(skillData, targetRank, summary)
    local allocator = type(skillData) == "table"
        and type(skillData.GetPointAllocator) == "function"
        and skillData:GetPointAllocator()
        or nil
    if type(allocator) ~= "table" then
        summary.skippedCount = summary.skippedCount + 1
        IncrementReason(summary, "allocator_unavailable")
        return false
    end

    local changed = false
    while true do
        local currentRank, purchased = ClassMasteryLookup:GetCommittedRank(skillData)
        if currentRank >= targetRank then
            break
        end

        if not purchased then
            if type(allocator.CanPurchase) == "function" and allocator:CanPurchase() then
                if allocator:Purchase() then
                    summary.restoredCount = summary.restoredCount + 1
                    changed = true
                    break
                else
                    IncrementReason(summary, "purchase_failed")
                    break
                end
            else
                summary.skippedCount = summary.skippedCount + 1
                if type(allocator.HasEnoughAvailableSkillPointsForSingleTransaction) == "function"
                    and not allocator:HasEnoughAvailableSkillPointsForSingleTransaction() then
                    IncrementReason(summary, "insufficient_mastery_points")
                else
                    IncrementReason(summary, "cannot_purchase")
                end
                break
            end
        elseif type(allocator.CanIncreaseRank) == "function" and allocator:CanIncreaseRank() then
            if allocator:IncreaseRank() then
                summary.restoredCount = summary.restoredCount + 1
                changed = true
                break
            else
                IncrementReason(summary, "increase_rank_failed")
                break
            end
        else
            summary.skippedCount = summary.skippedCount + 1
            IncrementReason(summary, "target_rank_unavailable")
            break
        end

    end

    local _, purchased = ClassMasteryLookup:GetCommittedRank(skillData)
    if not changed and purchased then
        IncrementReason(summary, "already_restored")
    end

    return changed
end

local function RestoreMasteryAbilities(skillLineData, purchasedAbilities, summary)
    local changed = false
    local matchedTargets = {}
    for _, skillData in ipairs(ClassMasteryLookup:IteratePassives(skillLineData)) do
        local abilityId = ClassMasteryLookup:ResolveRankOneAbilityId(skillData)
        local targetRank = abilityId ~= nil and purchasedAbilities[abilityId] or nil
        if targetRank ~= nil then
            matchedTargets[abilityId] = true
            if TryRestoreMasterySkill(skillData, targetRank, summary) then
                changed = true
            end
        end
    end

    for abilityId in pairs(purchasedAbilities or {}) do
        if matchedTargets[abilityId] ~= true then
            summary.skippedCount = summary.skippedCount + 1
            IncrementReason(summary, "saved_ability_not_found")
        end
    end

    for reason, count in pairs(summary.reasonCounts) do
        if reason ~= "already_restored" then
            summary.warningCount = summary.warningCount + count
        end
    end

    return changed
end

local function BuildPipelinePhaseResult(success, summary, err, skipped)
    local details = {
        mode = "pipeline_phase",
        classMasterySummary = summary,
    }
    if success == true and skipped ~= true then
        details.commitAt = SHARED_UTIL:GetFrameTimeMillisecondsSafe()
        details.mutatingAction = "class_mastery_purchase"
    end

    if success == true then
        if skipped == true then
            return CreateSkippedResult(err or "class_mastery_apply_skipped", details)
        end
        return CreateSuccessResult(details)
    end

    return CreateFailureResult(err or "class_mastery_apply_failed", details)
end

function M:GetLastResult()
    return self.lastResult
end

function M:SetLastResult(result)
    self.lastResult = result
end

function M:LogSummary(summary)
    LogMastery(
        "Mastery restore complete",
        "targetSkillLineId=" .. tostring(summary and summary.targetSkillLineId or nil),
        "targetAbilityCount=" .. tostring(summary and summary.targetAbilityCount or 0),
        "restoredCount=" .. tostring(summary and summary.restoredCount or 0),
        "skippedCount=" .. tostring(summary and summary.skippedCount or 0),
        "warnings=" .. tostring(summary and summary.warningCount or 0),
        "reasons=" .. tostring(BuildReasonSummary(summary and summary.reasonCounts or nil))
    )
end

function M:Finalize(context, success, err, result)
    if self.pendingContext ~= context then
        return
    end

    self.pendingContext = nil
    context.finished = true
    self:SetLastResult(result)

    if success == true and type(result) == "table" and result.skipped ~= true then
        LTM_APPLY_COOLDOWN_GATE:RecordMutation("skill", SHARED_UTIL:GetFrameTimeMillisecondsSafe())
    end

    local completion = context.completion
    if type(completion) == "function" then
        pcall(completion, success == true, err, result)
    end
end

function M:PollCompletion(context)
    if self.pendingContext ~= context or context.finished or context.completionResolved == true then
        return
    end

    context.completionAttemptIndex = (context.completionAttemptIndex or 0) + 1
    local skillLineData = ClassMasteryLookup:ResolveLineData(context.targetSkillLineId, true, false)
    local satisfied = type(skillLineData) == "table" and AreTargetsSatisfied(skillLineData, context.purchasedAbilities)

    if satisfied == true then
        LogTargetSatisfaction(skillLineData, context.purchasedAbilities, context.summary)
        context.completionResolved = true
        self:Finalize(context, true, nil, BuildPipelinePhaseResult(true, context.summary))
        return
    end

    if context.completionAttemptIndex >= MASTERY_COMPLETION_MAX_ATTEMPTS then
        LogTargetSatisfaction(skillLineData, context.purchasedAbilities, context.summary)
        context.completionResolved = true
        self:Finalize(context, false, "class_mastery_result_timeout", BuildPipelinePhaseResult(false, context.summary, "class_mastery_result_timeout"))
        return
    end

    zo_callLater(function()
        M:PollCompletion(context)
    end, MASTERY_COMPLETION_POLL_MS)
end

function M:Commit(context)
    local skillLineData, lineErr = ClassMasteryLookup:ResolveLineData(context.targetSkillLineId, true, false)
    if lineErr == "mastery_line_inactive" then
        IncrementReason(context.summary, lineErr)
        LogMastery("Mastery restore unavailable", "reason=" .. lineErr, "targetSkillLineId=" .. tostring(context.targetSkillLineId))
        if (context.summary.targetAbilityCount or 0) > 0 then
            IncrementReason(context.summary, "target_not_satisfied")
            self:Finalize(
                context,
                false,
                "target_not_satisfied",
                BuildPipelinePhaseResult(false, context.summary, "target_not_satisfied")
            )
            return
        end

        self:Finalize(context, true, nil, BuildPipelinePhaseResult(true, context.summary, lineErr, true))
        return
    elseif skillLineData == nil then
        IncrementReason(context.summary, lineErr or "mastery_line_unavailable")
        self:Finalize(context, false, lineErr or "mastery_line_unavailable", BuildPipelinePhaseResult(false, context.summary, lineErr or "mastery_line_unavailable"))
        return
    end

    LogMastery("Mastery line detected", "targetSkillLineId=" .. tostring(context.targetSkillLineId))
    LogMastery(
        "Mastery restore begin",
        "targetSkillLineId=" .. tostring(context.targetSkillLineId),
        "targetAbilityCount=" .. tostring(context.summary.targetAbilityCount or 0)
    )

    if context.summary.targetAbilityCount == 0 then
        self:LogSummary(context.summary)
        self:Finalize(context, true, nil, BuildPipelinePhaseResult(true, context.summary))
        return
    end

    local changed = RestoreMasteryAbilities(skillLineData, context.purchasedAbilities, context.summary)
    self:LogSummary(context.summary)

    if changed == true then
        context.completionResolved = false
        context.completionAttemptIndex = 0
        self:PollCompletion(context)
        return
    end

    local satisfied = LogTargetSatisfaction(skillLineData, context.purchasedAbilities, context.summary)
    if satisfied == true then
        self:Finalize(context, true, nil, BuildPipelinePhaseResult(true, context.summary))
        return
    end

    self:Finalize(
        context,
        false,
        "target_not_satisfied",
        BuildPipelinePhaseResult(false, context.summary, "target_not_satisfied")
    )
end

function M:ContinueReadyCheck(context)
    if self.pendingContext ~= context or context.finished then
        return
    end

    context.readyAttemptIndex = (context.readyAttemptIndex or 0) + 1
    local readySnapshot = BuildMasteryReadySnapshot(context)
    if ShouldLogMasteryReadyAttempt(readySnapshot) then
        LogMasteryReadySnapshot("Mastery ready check", readySnapshot)
    end

    if readySnapshot.ready == true then
        self:Commit(context)
        return
    end

    if context.readyAttemptIndex >= MASTERY_READY_MAX_ATTEMPTS then
        LogMasteryReadySnapshot("Mastery ready timeout", readySnapshot)
        self:Finalize(context, false, "class_mastery_ready_timeout", BuildPipelinePhaseResult(false, context.summary, "class_mastery_ready_timeout"))
        return
    end

    if context.startInvoked ~= true then
        if not ShowMasteryPurchaseScene() then
            self:Finalize(context, false, "show_mastery_purchase_scene_unavailable", BuildPipelinePhaseResult(false, context.summary, "show_mastery_purchase_scene_unavailable"))
            return
        end
        context.startInvoked = true
    end

    zo_callLater(function()
        M:ContinueReadyCheck(context)
    end, MASTERY_READY_RETRY_MS)
end

function M:Run(config)
    self:SetLastResult(nil)

    local pipelineContext = type(config) == "table" and config._pipelineContext or nil
    local continuation = type(config) == "table" and config._pipelineContinuation or nil
    local build = type(pipelineContext) == "table" and pipelineContext.targetBuild or nil
    local classMastery = type(config) == "table" and config or nil
    if type(build) == "table" and type(build.classMastery) == "table" then
        classMastery = build.classMastery
    end

    if type(classMastery) ~= "table" then
        local summary = BuildSummary(nil, nil)
        LogMastery("Mastery restore skipped", "reason=class_mastery_missing")
        self:SetLastResult(BuildPipelinePhaseResult(true, summary, "class_mastery_missing", true))
        return true
    end

    local targetSkillLineId = tonumber(classMastery.targetSkillLineId)
    if targetSkillLineId == nil or targetSkillLineId <= 0 then
        local summary = BuildSummary(classMastery, nil)
        LogMastery("Mastery restore skipped", "reason=target_skill_line_missing")
        self:SetLastResult(BuildPipelinePhaseResult(true, summary, "target_skill_line_missing", true))
        return true
    end

    local purchasedAbilities = NormalizePurchasedAbilities(classMastery.purchasedAbilities)
    local summary = BuildSummary(classMastery, purchasedAbilities)

    if purchasedAbilities == nil then
        IncrementReason(summary, "skip_legacy")
        LogMastery("Mastery restore skipped", "reason=skip_legacy", "targetSkillLineId=" .. tostring(targetSkillLineId))
        self:SetLastResult(BuildPipelinePhaseResult(true, summary, "skip_legacy", true))
        return true
    end

    if summary.targetAbilityCount == 0 then
        LogMastery("Mastery restore begin", "targetSkillLineId=" .. tostring(targetSkillLineId), "targetAbilityCount=0")
        self:LogSummary(summary)
        self:SetLastResult(BuildPipelinePhaseResult(true, summary))
        return true
    end

    local pendingSnapshot = BuildPendingSkillChangeSnapshot()
    if pendingSnapshot.hasPendingChanges == true and not IsActionBarOnlyPendingSkillChanges(pendingSnapshot) then
        self:SetLastResult(BuildPipelinePhaseResult(false, summary, "skill_pending_changes_blocking_apply"))
        return false, "skill_pending_changes_blocking_apply"
    end

    if self.pendingContext ~= nil and self.pendingContext.finished ~= true then
        self:SetLastResult(BuildPipelinePhaseResult(false, summary, "class_mastery_context_exists"))
        return false, "class_mastery_context_exists"
    end

    local context = {
        classMastery = classMastery,
        completion = function(success, completionErr, result)
            M:SetLastResult(result)
            if type(continuation) == "function" then
                continuation(success == true, completionErr)
            end
        end,
        finished = false,
        startInvoked = false,
        readyAttemptIndex = 0,
        purchasedAbilities = purchasedAbilities,
        summary = summary,
        targetSkillLineId = math.floor(targetSkillLineId),
    }
    self.pendingContext = context

    if IsReadyForMasteryApply() then
        zo_callLater(function()
            M:Commit(context)
        end, 0)
        return true, "deferred"
    end

    zo_callLater(function()
        M:ContinueReadyCheck(context)
    end, 0)
    return true, "deferred"
end
