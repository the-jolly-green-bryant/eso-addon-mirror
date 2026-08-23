local Addon = LarvalTearMod
local M = Addon.Modules.PassiveSnapshotApply
local Log = Addon.Common.Log
local ClassLineHelper = Addon.Modules.ClassLineHelper
local PipelineContext = Addon.Modules.PipelineContext
local Util = Addon.Common.Util

local SNAPSHOT_VERSION = 1
local POLICY_NONE = "none"
local POLICY_CLASS_ALL_PURCHASE = "class_purchase_all"
local POLICY_CLASS_ONLY = "class_exact"
local POLICY_ALL = "all_exact"
local EXACT_APPLY_RETRY_DELAY_MS = 50
local EXACT_APPLY_MAX_ATTEMPTS = 5
local EXACT_APPLY_COMPLETION_DELAY_MS = 50
local STANDALONE_VERIFY_WAIT_DELAY_MS = 150
local STANDALONE_VERIFY_WAIT_MAX_RETRIES = 8
local PASSIVE_DIRECT_SCENE_NAME_KEYBOARD = "skills"
local PASSIVE_DIRECT_SCENE_NAME_GAMEPAD = "gamepad_skills_root"
local CountSnapshotEntries
local FinalizePassiveExactResultStatus

local function NormalizePositiveInteger(value)
    local number = tonumber(value)
    if number == nil or number <= 0 or math.floor(number) ~= number then
        return nil
    end
    return number
end

local function NormalizeNonNegativeInteger(value)
    local number = tonumber(value)
    if number == nil or number < 0 or math.floor(number) ~= number then
        return nil
    end
    return number
end

local function GetSkillLineId(skillLineData)
    local skillLineId = type(skillLineData) == "table"
        and type(skillLineData.GetId) == "function"
        and tonumber(skillLineData:GetId())
        or nil
    if skillLineId ~= nil and skillLineId > 0 then
        return math.floor(skillLineId)
    end
    return nil
end

local function RefreshSkillLineData(skillLineData)
    if type(skillLineData) == "table" and type(skillLineData.RefreshDynamicData) == "function" then
        skillLineData:RefreshDynamicData(true)
    end
    return skillLineData
end

local function IsClassMasteryLine(skillLineData)
    return type(skillLineData) == "table"
        and type(skillLineData.IsClassMastery) == "function"
        and skillLineData:IsClassMastery() == true
end

local function IsAvailableSkillLine(skillLineData)
    if type(skillLineData) ~= "table" then
        return false
    end
    if type(skillLineData.IsAvailable) == "function" then
        return skillLineData:IsAvailable() == true
    end
    local discovered = type(skillLineData.IsDiscovered) ~= "function" or skillLineData:IsDiscovered() == true
    local active = type(skillLineData.IsActive) ~= "function" or skillLineData:IsActive() == true
    return discovered and active
end

local function GetMaxPassiveRankWithSource(skillData)
    if type(skillData) ~= "table" then
        return nil, "skill_data_unavailable"
    end

    local methodNames = {
        "GetNumRanks",
        "GetMaxRank",
        "GetMaxRanks",
        "GetNumPassiveRanks",
    }
    for _, methodName in ipairs(methodNames) do
        local rank = nil
        if type(skillData[methodName]) == "function" then
            local ok, value = pcall(skillData[methodName], skillData)
            if ok then
                rank = tonumber(value)
            end
        end
        if rank ~= nil and rank >= 0 then
            return math.floor(rank), methodName
        end
    end

    return nil, "max_rank_method_unavailable"
end

local function GetMaxPassiveRank(skillData)
    local rank = GetMaxPassiveRankWithSource(skillData)
    return rank
end

local function IsPassiveSkill(skillData)
    return type(skillData) == "table"
        and type(skillData.IsPassive) == "function"
        and skillData:IsPassive() == true
end

local function IsAutoGrantSkill(skillData)
    return type(skillData) == "table"
        and type(skillData.IsAutoGrant) == "function"
        and skillData:IsAutoGrant() == true
end

local function GetMinimumPassiveRank(skillData)
    return IsAutoGrantSkill(skillData) and 1 or 0
end

local function IsPassiveSnapshotRelevantSkill(skillData)
    if not IsPassiveSkill(skillData) then
        return false, "not_passive", nil, GetMinimumPassiveRank(skillData)
    end

    local maxRank = GetMaxPassiveRank(skillData)
    local minimumRank = GetMinimumPassiveRank(skillData)
    if maxRank == nil then
        return false, "max_rank_unavailable", maxRank, minimumRank
    end
    if maxRank <= minimumRank then
        return false, "auto_grant_only", maxRank, minimumRank
    end

    return true, nil, maxRank, minimumRank
end

local function GetCurrentPassiveRank(skillData)
    if type(skillData) ~= "table" then
        return 0
    end
    if type(skillData.IsPurchased) == "function" and skillData:IsPurchased() ~= true then
        return 0
    end
    local rank = tonumber(type(skillData.GetCurrentRank) == "function" and skillData:GetCurrentRank() or nil) or 0
    rank = math.floor(rank)
    return rank > 0 and rank or 0
end

local function GetRestorableCurrentPassiveRank(skillData)
    local currentRank = GetCurrentPassiveRank(skillData)
    local minimumRank = GetMinimumPassiveRank(skillData)
    return currentRank < minimumRank and minimumRank or currentRank
end

local function BuildLineIdSet(lineIds)
    local set = {}
    for _, lineId in ipairs(type(lineIds) == "table" and lineIds or {}) do
        lineId = NormalizePositiveInteger(lineId)
        if lineId ~= nil then
            set[lineId] = true
        end
    end
    return set
end

local function BuildSortedLineIdList(lineIds)
    local result = {}
    local seen = {}
    for _, lineId in ipairs(type(lineIds) == "table" and lineIds or {}) do
        lineId = NormalizePositiveInteger(lineId)
        if lineId ~= nil and seen[lineId] ~= true then
            seen[lineId] = true
            result[#result + 1] = lineId
        end
    end
    table.sort(result)
    return result, seen
end

local function SortedSnapshotLineIds(snapshot)
    local lineIds = {}
    for rawSkillLineId, lineEntries in pairs(type(snapshot) == "table" and type(snapshot.lines) == "table" and snapshot.lines or {}) do
        local skillLineId = NormalizePositiveInteger(rawSkillLineId)
        if skillLineId ~= nil and type(lineEntries) == "table" then
            lineIds[#lineIds + 1] = skillLineId
        end
    end
    table.sort(lineIds)
    return lineIds
end

local function SortedSnapshotSkillIndexes(lineEntries)
    local skillIndexes = {}
    for rawSkillIndex in pairs(type(lineEntries) == "table" and lineEntries or {}) do
        local skillIndex = NormalizePositiveInteger(rawSkillIndex)
        if skillIndex ~= nil then
            skillIndexes[#skillIndexes + 1] = skillIndex
        end
    end
    table.sort(skillIndexes)
    return skillIndexes
end

local function ResolveSkillLineData(skillLineId)
    return ClassLineHelper:ResolveSkillLineData(skillLineId)
end

local function ResolveSnapshotState(snapshot)
    if snapshot == nil then
        return "missing", 0, 0
    end
    if type(snapshot) ~= "table" or snapshot.version ~= SNAPSHOT_VERSION or type(snapshot.lines) ~= "table" then
        return "invalid", 0, 0
    end

    local lineCount, entryCount = CountSnapshotEntries(snapshot)
    if lineCount == 0 or entryCount == 0 then
        return "empty", lineCount, entryCount
    end
    return "valid", lineCount, entryCount
end

local function CreateAnalysis(build, policy)
    return {
        ok = true,
        policy = policy,
        snapshotRequired = policy == POLICY_CLASS_ONLY or policy == POLICY_ALL,
        snapshotState = "not_required",
        snapshotMissing = false,
        needsPassiveOption = false,
        hasPurchase = false,
        hasReduction = false,
        hasDefer = false,
        hasUnavailable = false,
        hasExactPassiveDiff = false,
        needsExactPassiveApply = false,
        requiresRespecForPassive = false,
        invalidCount = 0,
        noOpCount = 0,
        purchaseCount = 0,
        reductionCount = 0,
        deferCount = 0,
        unavailableCount = 0,
        targetEntries = {},
        targetLineIds = {},
        routeHint = "none",
        reasonCounts = {},
        buildId = type(build) == "table" and build.id or nil,
    }
end

local function IncrementReason(analysis, reason)
    if type(analysis) ~= "table" or type(reason) ~= "string" or reason == "" then
        return
    end
    analysis.reasonCounts[reason] = (analysis.reasonCounts[reason] or 0) + 1
end

local function IncrementResultReason(result, reason)
    if type(result) ~= "table" then
        return
    end
    reason = type(reason) == "string" and reason ~= "" and reason or "unknown"
    result.reasonCounts[reason] = (result.reasonCounts[reason] or 0) + 1
end

local function GetSkillName(skillData)
    return Util:SafeCallMethod(skillData, "GetName")
        or Util:SafeCallMethod(skillData, "GetFormattedName")
        or Util:SafeCallMethod(skillData, "GetRawName")
        or ""
end

local function CallAllocatorMutation(allocator, methodName, ...)
    if type(allocator) ~= "table" or type(allocator[methodName]) ~= "function" then
        return false
    end

    local ok, value = pcall(allocator[methodName], allocator, ...)
    return ok == true and value ~= false
end

local function BuildReasonSummary(reasonCounts)
    local parts = {}
    for reason in pairs(type(reasonCounts) == "table" and reasonCounts or {}) do
        parts[#parts + 1] = tostring(reason)
    end
    table.sort(parts)
    for index, reason in ipairs(parts) do
        parts[index] = tostring(reason) .. "=" .. tostring(reasonCounts[reason] or 0)
    end
    return table.concat(parts, ",")
end

local PASSIVE_EXACT_FATAL_REASON_SET = {
    passive_snapshot_missing = true,
    passive_snapshot_invalid = true,
    passive_analysis_failed = true,
    passive_policy_invalid = true,
}

local PASSIVE_EXACT_REASON_CATEGORY = {
    passive_snapshot_missing = "snapshot_missing",
    passive_snapshot_invalid = "snapshot_invalid",
    target_class_line_snapshot_missing = "snapshot_missing",
    saved_rank_invalid = "snapshot_invalid",
    saved_rank_out_of_range = "snapshot_invalid",
    max_rank_unavailable = "snapshot_invalid",
    invalid_entry = "entry_missing",
    skill_index_unresolvable = "entry_missing",
    skill_data_unavailable = "entry_unavailable",
    skill_line_unavailable = "entry_unavailable",
    target_class_line_unavailable = "entry_unavailable",
    target_class_line_inactive = "entry_unavailable",
    passive_entry_unresolvable = "entry_unavailable",
    passive_not_supported = "entry_unavailable",
    allocator_unavailable = "allocator_unavailable",
    insufficient_skill_points = "insufficient_skill_points",
    purchase_failed = "purchase_failed",
    cannot_purchase = "purchase_failed",
    cannot_increase_rank = "purchase_failed",
    increase_rank_failed = "purchase_failed",
    purchase_context_required = "purchase_failed",
    purchase_not_allowed_in_mode = "purchase_failed",
    safety_limit = "purchase_failed",
    reduction_requires_respec_route = "reduction_failed",
    respec_mode_required = "reduction_failed",
    decrease_rank_unavailable = "reduction_failed",
    decrease_rank_failed = "reduction_failed",
    sell_unavailable = "reduction_failed",
    sell_failed = "reduction_failed",
    minimum_rank_reached = "reduction_failed",
    cannot_reduce_rank = "reduction_failed",
    post_commit_live_rank_mismatch = "verify_mismatch",
    pending_live_update_wait = "verify_mismatch",
    expected_rank_unavailable = "verify_missing",
}

local PASSIVE_EXACT_USER_REASON = {
    snapshot_missing = "passive_snapshot_missing",
    snapshot_invalid = "passive_snapshot_invalid",
    entry_missing = "passive_skills_unavailable",
    entry_unavailable = "passive_skills_unavailable",
    allocator_unavailable = "passive_skills_unavailable",
    purchase_failed = "passive_ranks_not_restored",
    reduction_failed = "passive_ranks_not_restored",
    verify_mismatch = "passive_ranks_not_restored",
    verify_missing = "passive_ranks_not_restored",
    insufficient_skill_points = "insufficient_skill_points",
}

local function NormalizePassiveExactReason(reason)
    if type(reason) ~= "string" or reason == "" then
        return "passive_ranks_not_restored"
    end
    return PASSIVE_EXACT_REASON_CATEGORY[reason] or reason
end

local function ResolvePassiveExactUserReason(category)
    return PASSIVE_EXACT_USER_REASON[category] or "passive_ranks_not_restored"
end

local function IsPassiveExactFatalReason(reason)
    return type(reason) == "string" and PASSIVE_EXACT_FATAL_REASON_SET[reason] == true
end

local function AppendUnique(list, seen, value)
    if type(value) ~= "string" or value == "" or seen[value] == true then
        return
    end
    seen[value] = true
    list[#list + 1] = value
end

local function LogExactRestoreDebug(...)
    Log.LogDebugSummary("Passive exact restore", ...)
end

local function IsSkillSceneShowing()
    if type(SCENE_MANAGER) ~= "table" or type(SCENE_MANAGER.IsShowing) ~= "function" then
        return false
    end
    return SCENE_MANAGER:IsShowing(PASSIVE_DIRECT_SCENE_NAME_KEYBOARD) == true
        or SCENE_MANAGER:IsShowing(PASSIVE_DIRECT_SCENE_NAME_GAMEPAD) == true
end

local function GetSkillPointAllocationMode()
    if type(SKILLS_AND_ACTION_BAR_MANAGER) ~= "table"
        or type(SKILLS_AND_ACTION_BAR_MANAGER.GetSkillPointAllocationMode) ~= "function" then
        return nil
    end
    return SKILLS_AND_ACTION_BAR_MANAGER:GetSkillPointAllocationMode()
end

local function GetCurrentInteractionType()
    return type(GetInteractionType) == "function" and GetInteractionType() or nil
end

local function IsPurchaseContextReady()
    local allocationMode = GetSkillPointAllocationMode()
    local purchaseOnlyMode = (SKILL_POINT_ALLOCATION_MODE_PURCHASE_ONLY ~= nil and allocationMode == SKILL_POINT_ALLOCATION_MODE_PURCHASE_ONLY)
        or allocationMode == 0
    local interactionType = GetCurrentInteractionType()

    return IsSkillSceneShowing()
        and purchaseOnlyMode
        and (INTERACTION_SKILL_RESPEC == nil or interactionType ~= INTERACTION_SKILL_RESPEC)
end

local function IsRespecContextReady()
    local interactionType = GetCurrentInteractionType()
    if INTERACTION_SKILL_RESPEC ~= nil and interactionType ~= INTERACTION_SKILL_RESPEC then
        return false
    end
    return IsSkillSceneShowing()
end

local function DecorateAnalysisEntry(entry)
    if type(entry) ~= "table" then
        return entry
    end

    local skillLineId = NormalizePositiveInteger(entry.skillLineId)
    local skillLineData = skillLineId ~= nil and ResolveSkillLineData(skillLineId) or nil
    entry.isClassMastery = IsClassMasteryLine(skillLineData)
    entry.isClassSkillLine = Util:SafeCallMethod(skillLineData, "IsClassSkillLine") == true
    entry.isPlayerClassSkillLine = Util:SafeCallMethod(skillLineData, "IsPlayerClassSkillLine") == true

    local skillIndex = NormalizePositiveInteger(entry.skillIndex)
    local skillData = type(skillLineData) == "table"
        and skillIndex ~= nil
        and type(skillLineData.GetSkillDataByIndex) == "function"
        and skillLineData:GetSkillDataByIndex(skillIndex)
        or nil
    entry.costMultiplier = NormalizePositiveInteger(
        Util:SafeCallMethod(skillData, "GetSkillPointCostMultiplier")
    )
    return entry
end

local function BuildShadowDeferredTargets(skillLineData, skillLineId)
    local targets = {}
    if type(skillLineData) ~= "table"
        or type(skillLineData.GetNumSkills) ~= "function"
        or type(skillLineData.GetSkillDataByIndex) ~= "function" then
        return targets, false
    end

    local resolved = true
    local numSkills = tonumber(skillLineData:GetNumSkills()) or 0
    for skillIndex = 1, numSkills do
        local skillData = skillLineData:GetSkillDataByIndex(skillIndex)
        local relevant, reason, maxRank, minimumRank = IsPassiveSnapshotRelevantSkill(skillData)
        if type(skillData) ~= "table" then
            resolved = false
        elseif relevant and not IsClassMasteryLine(skillLineData) then
            targets[#targets + 1] = DecorateAnalysisEntry({
                skillLineId = skillLineId,
                skillIndex = skillIndex,
                savedRank = maxRank,
                currentRank = 0,
                maxRank = maxRank,
                minimumRank = minimumRank,
                isAutoGrant = IsAutoGrantSkill(skillData) == true,
                missingRank = math.max(0, maxRank - minimumRank),
                classification = "defer",
                reason = "target_class_line_inactive",
                targetClassLine = true,
            })
        elseif reason == "max_rank_unavailable" then
            resolved = false
        end
    end
    return targets, resolved
end

local function AppendClassifiedEntry(analysis, entry)
    entry = DecorateAnalysisEntry(entry)
    analysis.targetEntries[#analysis.targetEntries + 1] = entry
    if entry.classification == "purchase" then
        analysis.hasPurchase = true
        analysis.purchaseCount = analysis.purchaseCount + 1
    elseif entry.classification == "reduction" then
        analysis.hasReduction = true
        analysis.reductionCount = analysis.reductionCount + 1
    elseif entry.classification == "defer" or entry.classification == "unresolved" then
        analysis.hasDefer = true
        analysis.deferCount = analysis.deferCount + 1
    elseif entry.classification == "invalid" then
        analysis.invalidCount = analysis.invalidCount + 1
    elseif entry.classification == "unavailable" or entry.classification == "ignored" then
        analysis.hasUnavailable = true
        analysis.unavailableCount = analysis.unavailableCount + 1
    elseif entry.classification == "no-op" then
        analysis.noOpCount = analysis.noOpCount + 1
    end
    IncrementReason(analysis, entry.reason)
end

local function FinalizeAnalysis(analysis)
    local exactPolicy = analysis.policy == POLICY_CLASS_ONLY or analysis.policy == POLICY_ALL
    analysis.hasExactPassiveDiff = exactPolicy
        and (analysis.hasPurchase == true
            or analysis.hasReduction == true
            or analysis.hasDefer == true)
    analysis.needsExactPassiveApply = analysis.hasExactPassiveDiff == true
    analysis.requiresRespecForPassive = exactPolicy
        and (analysis.hasReduction == true or analysis.hasDefer == true)
    analysis.needsPassiveOption = analysis.hasPurchase == true
        or analysis.hasReduction == true
        or analysis.hasDefer == true
    if analysis.requiresRespecForPassive == true then
        analysis.routeHint = "route_b"
    elseif analysis.hasPurchase == true then
        analysis.routeHint = "route_a"
    else
        analysis.routeHint = "none"
    end
    return analysis
end

local function GetTargetLineIds(build)
    return type(build) == "table"
        and type(build.subclass) == "table"
        and build.subclass.targetSkillLineIds
        or nil
end

local function ResolveExactTargetLineIds(policy, build, snapshot)
    if policy == POLICY_CLASS_ONLY then
        return BuildSortedLineIdList(GetTargetLineIds(build))
    end
    if policy == POLICY_ALL then
        local lineIds = SortedSnapshotLineIds(snapshot)
        return lineIds, BuildLineIdSet(lineIds)
    end
    return {}, {}
end

local function AnalyzeSavedPassiveEntry(analysis, skillLineData, skillLineId, skillIndex, savedRank, targetClassLineSet)
    local targetClassLine = type(targetClassLineSet) == "table" and targetClassLineSet[skillLineId] == true
    if type(skillLineData) ~= "table" then
        AppendClassifiedEntry(analysis, {
            skillLineId = skillLineId,
            skillIndex = skillIndex,
            savedRank = savedRank,
            classification = "invalid",
            reason = "skill_line_unavailable",
            targetClassLine = targetClassLine == true,
        })
        return
    end

    local skillData = type(skillLineData.GetSkillDataByIndex) == "function"
        and skillLineData:GetSkillDataByIndex(skillIndex)
        or nil
    local relevant, relevanceReason, maxRank, minimumRank = IsPassiveSnapshotRelevantSkill(skillData)
    if not relevant then
        AppendClassifiedEntry(analysis, {
            skillLineId = skillLineId,
            skillIndex = skillIndex,
            savedRank = savedRank,
            maxRank = maxRank,
            minimumRank = minimumRank,
            isAutoGrant = IsAutoGrantSkill(skillData) == true,
            classification = "ignored",
            reason = relevanceReason or "passive_entry_unresolvable",
            targetClassLine = targetClassLine == true,
        })
        return
    end

    local originalSavedRank = savedRank
    if savedRank < minimumRank then
        savedRank = minimumRank
    end

    if maxRank == nil or savedRank > maxRank then
        AppendClassifiedEntry(analysis, {
            skillLineId = skillLineId,
            skillIndex = skillIndex,
            savedRank = savedRank,
            originalSavedRank = originalSavedRank,
            maxRank = maxRank,
            minimumRank = minimumRank,
            classification = "invalid",
            reason = "saved_rank_out_of_range",
            targetClassLine = targetClassLine == true,
        })
        return
    end

    if targetClassLine == true and not IsAvailableSkillLine(skillLineData) then
        AppendClassifiedEntry(analysis, {
            skillLineId = skillLineId,
            skillIndex = skillIndex,
            savedRank = savedRank,
            originalSavedRank = originalSavedRank,
            maxRank = maxRank,
            minimumRank = minimumRank,
            classification = "defer",
            reason = "target_class_line_inactive",
            targetClassLine = true,
        })
        return
    end

    if not IsAvailableSkillLine(skillLineData) then
        AppendClassifiedEntry(analysis, {
            skillLineId = skillLineId,
            skillIndex = skillIndex,
            savedRank = savedRank,
            originalSavedRank = originalSavedRank,
            maxRank = maxRank,
            minimumRank = minimumRank,
            classification = "invalid",
            reason = "skill_line_unavailable",
            targetClassLine = false,
        })
        return
    end

    local currentRank = GetRestorableCurrentPassiveRank(skillData)
    local classification = "no-op"
    if currentRank < savedRank then
        classification = "purchase"
    elseif currentRank > savedRank then
        classification = "reduction"
    end

    AppendClassifiedEntry(analysis, {
        skillLineId = skillLineId,
        skillIndex = skillIndex,
        savedRank = savedRank,
        originalSavedRank = originalSavedRank,
        currentRank = currentRank,
        maxRank = maxRank,
        minimumRank = minimumRank,
        isAutoGrant = IsAutoGrantSkill(skillData) == true,
        missingRank = savedRank > currentRank and (savedRank - currentRank) or 0,
        excessRank = currentRank > savedRank and (currentRank - savedRank) or 0,
        classification = classification,
        reason = classification,
        targetClassLine = targetClassLine == true,
    })
end

local function AnalyzeExactRestore(build, analysis)
    local snapshot = type(build) == "table" and build.passiveSnapshot or nil
    local snapshotState, snapshotLineCount, snapshotEntryCount = ResolveSnapshotState(snapshot)
    analysis.snapshotState = snapshotState
    analysis.snapshotLineCount = snapshotLineCount
    analysis.snapshotEntryCount = snapshotEntryCount

    if snapshotState == "missing" then
        analysis.ok = false
        analysis.snapshotMissing = true
        analysis.blockReason = "passive_snapshot_missing"
        IncrementReason(analysis, "passive_snapshot_missing")
        return FinalizeAnalysis(analysis)
    end
    if snapshotState == "invalid" then
        analysis.ok = false
        analysis.snapshotMissing = true
        analysis.blockReason = "passive_snapshot_invalid"
        IncrementReason(analysis, "passive_snapshot_invalid")
        return FinalizeAnalysis(analysis)
    end

    local targetLineIds, exactTargetLineSet = ResolveExactTargetLineIds(analysis.policy, build, snapshot)
    analysis.targetLineIds = targetLineIds
    local targetClassLineIds, targetClassLineSet = targetLineIds, exactTargetLineSet
    if analysis.policy ~= POLICY_CLASS_ONLY then
        targetClassLineIds, targetClassLineSet = BuildSortedLineIdList(GetTargetLineIds(build))
    end
    analysis.targetClassLineIds = targetClassLineIds

    if snapshotState == "empty" then
        return FinalizeAnalysis(analysis)
    end

    for _, skillLineId in ipairs(targetLineIds) do
        local lineEntries = snapshot.lines[skillLineId] or snapshot.lines[tostring(skillLineId)]
        if type(lineEntries) ~= "table" then
            if analysis.policy == POLICY_CLASS_ONLY then
                IncrementReason(analysis, "target_class_line_snapshot_missing")
            end
        else
            local skillLineData = ResolveSkillLineData(skillLineId)
            for _, skillIndex in ipairs(SortedSnapshotSkillIndexes(lineEntries)) do
                local savedRank = NormalizeNonNegativeInteger(lineEntries[skillIndex] or lineEntries[tostring(skillIndex)])
                if savedRank == nil then
                    AppendClassifiedEntry(analysis, {
                        skillLineId = skillLineId,
                        skillIndex = skillIndex,
                        classification = "invalid",
                        reason = "saved_rank_invalid",
                        targetClassLine = targetClassLineSet[skillLineId] == true,
                    })
                else
                    AnalyzeSavedPassiveEntry(analysis, skillLineData, skillLineId, skillIndex, savedRank, targetClassLineSet)
                end
            end
        end
    end

    return FinalizeAnalysis(analysis)
end

local function AnalyzeClassAllPurchase(build, analysis)
    analysis.snapshotState = "not_required"
    local targetLineIds = BuildSortedLineIdList(GetTargetLineIds(build))
    local mainClassLineSet = {}
    for _, skillLineId in ipairs(targetLineIds) do
        local skillLineData = ResolveSkillLineData(skillLineId)
        if Util:SafeCallMethod(skillLineData, "IsPlayerClassSkillLine") == true then
            mainClassLineSet[skillLineId] = true
        end
    end
    table.sort(targetLineIds, function(left, right)
        local leftMainClass = mainClassLineSet[left] == true
        local rightMainClass = mainClassLineSet[right] == true
        if leftMainClass ~= rightMainClass then
            return leftMainClass
        end
        return left < right
    end)
    analysis.targetLineIds = targetLineIds

    for _, skillLineId in ipairs(targetLineIds) do
        local skillLineData = ResolveSkillLineData(skillLineId)
        if type(skillLineData) ~= "table" then
            AppendClassifiedEntry(analysis, {
                skillLineId = skillLineId,
                classification = "unavailable",
                reason = "target_class_line_unavailable",
                targetClassLine = true,
            })
        elseif not IsAvailableSkillLine(skillLineData) then
            local shadowDeferredTargets, shadowDeferredTargetsResolved = BuildShadowDeferredTargets(
                skillLineData,
                skillLineId
            )
            AppendClassifiedEntry(analysis, {
                skillLineId = skillLineId,
                classification = "unavailable",
                reason = "target_class_line_inactive",
                targetClassLine = true,
                shadowDeferredTargets = shadowDeferredTargets,
                shadowDeferredTargetsResolved = shadowDeferredTargetsResolved == true,
            })
        elseif type(skillLineData.GetNumSkills) == "function" and type(skillLineData.GetSkillDataByIndex) == "function" then
            local numSkills = tonumber(skillLineData:GetNumSkills()) or 0
            for skillIndex = 1, numSkills do
                local skillData = skillLineData:GetSkillDataByIndex(skillIndex)
                local relevant, _, maxRank, minimumRank = IsPassiveSnapshotRelevantSkill(skillData)
                if relevant then
                    local currentRank = GetRestorableCurrentPassiveRank(skillData)
                    maxRank = maxRank or currentRank
                    local classification = currentRank < maxRank and "purchase" or "no-op"
                    AppendClassifiedEntry(analysis, {
                        skillLineId = skillLineId,
                        skillIndex = skillIndex,
                        savedRank = maxRank,
                        currentRank = currentRank,
                        maxRank = maxRank,
                        minimumRank = minimumRank,
                        isAutoGrant = IsAutoGrantSkill(skillData) == true,
                        missingRank = maxRank > currentRank and (maxRank - currentRank) or 0,
                        classification = classification,
                        reason = classification,
                        targetClassLine = true,
                    })
                end
            end
        end
    end

    return FinalizeAnalysis(analysis)
end

local function CreateExactApplyResult(build, analysis, options)
    local requestedMaxAttempts = tonumber(type(options) == "table" and options.maxAttempts or nil) or EXACT_APPLY_MAX_ATTEMPTS
    return {
        ok = true,
        policy = type(analysis) == "table" and analysis.policy or options.passiveRestore,
        mode = "exact_restore",
        operationMode = type(options) == "table" and options.operationMode or "standalone",
        attempts = 0,
        maxAttempts = requestedMaxAttempts,
        retryDelayMs = tonumber(type(options) == "table" and options.retryDelayMs or nil) or EXACT_APPLY_RETRY_DELAY_MS,
        appliedCount = 0,
        skippedCount = 0,
        residualCount = 0,
        invalidCount = type(analysis) == "table" and (tonumber(analysis.invalidCount) or 0) or 0,
        reasonCounts = {},
        residualReasonCounts = {},
        userReasons = {},
        residualEntries = {},
        skippedEntries = {},
        entryBlockReasons = {},
        modifiedAllocators = {},
        modifiedAllocatorSet = {},
        pendingRankByKey = {},
        targetEntries = type(analysis) == "table" and analysis.targetEntries or {},
        hasResidual = false,
        aggregateSummary = nil,
        finalStatus = nil,
        resultCode = nil,
        partialSuccessResult = nil,
        analysis = analysis,
        buildId = type(build) == "table" and build.id or nil,
    }
end

local function ResolveSkillSettingsPassiveSkip(pipelineContext)
    local reason = PipelineContext:GetSkillSettingsSkipReason(pipelineContext, "normal_passive_changes")
    return reason ~= nil, reason
end

local function RecordSkillSettingsPassiveSkip(pipelineContext, reason)
    PipelineContext:RecordSkillSettingsSkip(
        pipelineContext,
        "normal_passive_changes",
        reason
    )
end

local function MarkExactResultSkippedForSkillSettings(result, reason)
    result.ok = true
    result.skipped = true
    result.code = reason
    result.finalStatus = "full_success"
    result.resultCode = nil
    result.partialSuccessResult = nil
    result.reasonCounts[reason] = 1
    return result
end

local function ResolveRequiredAttemptCount(analysis)
    local maxSteps = 0
    for _, entry in ipairs(type(analysis) == "table" and analysis.targetEntries or {}) do
        if type(entry) == "table" and (entry.classification == "purchase" or entry.classification == "reduction") then
            local savedRank = NormalizeNonNegativeInteger(entry.savedRank)
            local currentRank = NormalizeNonNegativeInteger(entry.currentRank)
            if savedRank ~= nil and currentRank ~= nil then
                local steps = math.abs(savedRank - currentRank)
                if steps > maxSteps then
                    maxSteps = steps
                end
            end
        end
    end
    return math.max(EXACT_APPLY_MAX_ATTEMPTS, maxSteps + 2)
end

local function IsEntryOperationAllowed(entry, options)
    local classification = type(entry) == "table" and entry.classification or nil
    if classification ~= "purchase" and classification ~= "reduction" then
        return true
    end

    local allowed = type(options) == "table" and options.allowedOperations or nil
    if type(allowed) ~= "table" then
        return true
    end

    return allowed[classification] == true
end

local function BuildEntryKey(entry)
    if type(entry) ~= "table" then
        return nil
    end
    return tostring(entry.skillLineId) .. ":" .. tostring(entry.skillIndex)
end

local function GetPendingRank(result, entry)
    local key = BuildEntryKey(entry)
    if key == nil or type(result) ~= "table" or type(result.pendingRankByKey) ~= "table" then
        return nil
    end
    return result.pendingRankByKey[key]
end

local function SetPendingRank(result, entry, rank)
    local key = BuildEntryKey(entry)
    if key == nil or type(result) ~= "table" then
        return
    end
    result.pendingRankByKey = result.pendingRankByKey or {}
    result.pendingRankByKey[key] = rank
end

local function SetPendingRankFromAllocator(result, entry, allocator, fallbackRank)
    local allocatorRank = NormalizeNonNegativeInteger(Util:SafeCallMethod(allocator, "GetRank"))
    local pendingRank = allocatorRank
    local source = "allocator_rank"
    if pendingRank == nil then
        pendingRank = NormalizeNonNegativeInteger(fallbackRank)
        source = "fallback"
    end

    if pendingRank ~= nil then
        SetPendingRank(result, entry, pendingRank)
    end

    return pendingRank, source
end

local function SetEntryBlockReason(result, entry, reason)
    local key = BuildEntryKey(entry)
    if key == nil or type(result) ~= "table" or type(result.entryBlockReasons) ~= "table" then
        return
    end
    result.entryBlockReasons[key] = reason
end

local function ResolveEntrySkillData(entry)
    local skillLineId = NormalizePositiveInteger(type(entry) == "table" and entry.skillLineId or nil)
    local skillIndex = NormalizePositiveInteger(type(entry) == "table" and entry.skillIndex or nil)
    if skillLineId == nil or skillIndex == nil then
        return nil, nil, nil, "invalid_entry"
    end

    local skillLineData = ResolveSkillLineData(skillLineId)
    if type(skillLineData) ~= "table" then
        return nil, nil, nil, "skill_line_unavailable"
    end
    if not IsAvailableSkillLine(skillLineData) then
        return nil, skillLineData, nil, "skill_line_unavailable"
    end
    if type(skillLineData.GetSkillDataByIndex) ~= "function" then
        return nil, skillLineData, nil, "skill_index_unresolvable"
    end

    local skillData = skillLineData:GetSkillDataByIndex(skillIndex)
    local relevant, relevanceReason = IsPassiveSnapshotRelevantSkill(skillData)
    if not relevant then
        return nil, skillLineData, nil, relevanceReason or "passive_entry_unresolvable"
    end

    return skillData, skillLineData, skillIndex, nil
end

local function MarkEntrySkipped(result, entry, reason)
    local category = NormalizePassiveExactReason(reason)
    result.skippedCount = result.skippedCount + 1
    IncrementResultReason(result, reason)
    result.skippedEntries[#result.skippedEntries + 1] = {
        skillLineId = type(entry) == "table" and entry.skillLineId or nil,
        skillIndex = type(entry) == "table" and entry.skillIndex or nil,
        savedRank = type(entry) == "table" and entry.savedRank or nil,
        currentRank = type(entry) == "table" and entry.currentRank or nil,
        classification = type(entry) == "table" and entry.classification or nil,
        reason = reason,
        rawReason = reason,
        category = category,
        userReason = ResolvePassiveExactUserReason(category),
    }
end

local function AppendVerifyMismatch(result, verify, entry, reason, expectedRank, actualRank, pendingRank, blockReason)
    verify.mismatchCount = verify.mismatchCount + 1
    local category = NormalizePassiveExactReason(blockReason or reason)
    if verify.suppressResidualMutation ~= true then
        result.residualCount = result.residualCount + 1
        result.hasResidual = true
        IncrementResultReason(result, reason)
        if blockReason ~= nil then
            IncrementResultReason(result, blockReason)
        end
    end

    local detail = {
        skillLineId = type(entry) == "table" and entry.skillLineId or nil,
        skillIndex = type(entry) == "table" and entry.skillIndex or nil,
        savedRank = type(entry) == "table" and entry.savedRank or nil,
        expectedRank = expectedRank,
        actualRank = actualRank,
        pendingRank = pendingRank,
        classification = type(entry) == "table" and entry.classification or nil,
        reason = reason,
        rawReason = reason,
        blockReason = blockReason,
        category = category,
        userReason = ResolvePassiveExactUserReason(category),
    }
    verify.mismatchEntries[#verify.mismatchEntries + 1] = detail
    if verify.suppressResidualMutation ~= true then
        result.residualEntries[#result.residualEntries + 1] = detail
    end
end

local function AppendVerifyMissing(result, verify, entry, reason, pendingRank)
    verify.missingCount = verify.missingCount + 1
    local category = NormalizePassiveExactReason(reason)
    if verify.suppressResidualMutation ~= true then
        result.residualCount = result.residualCount + 1
        result.hasResidual = true
        IncrementResultReason(result, reason)
    end

    local detail = {
        skillLineId = type(entry) == "table" and entry.skillLineId or nil,
        skillIndex = type(entry) == "table" and entry.skillIndex or nil,
        savedRank = type(entry) == "table" and entry.savedRank or nil,
        pendingRank = pendingRank,
        classification = type(entry) == "table" and entry.classification or nil,
        reason = reason,
        rawReason = reason,
        category = category,
        userReason = ResolvePassiveExactUserReason(category),
    }
    verify.missingEntries[#verify.missingEntries + 1] = detail
    if verify.suppressResidualMutation ~= true then
        result.residualEntries[#result.residualEntries + 1] = detail
    end
end

local function ShouldVerifyEntryLiveRank(entry)
    local classification = type(entry) == "table" and entry.classification or nil
    return classification == "purchase"
        or classification == "reduction"
        or classification == "no-op"
end

local function ResolveExpectedLiveRank(entry, skillData)
    local expectedRank = NormalizeNonNegativeInteger(type(entry) == "table" and entry.savedRank or nil)
    if expectedRank == nil then
        return nil, nil, nil, "saved_rank_invalid"
    end

    local minimumRank = GetMinimumPassiveRank(skillData)
    local maxRank = GetMaxPassiveRank(skillData)
    if maxRank == nil then
        return nil, maxRank, minimumRank, "max_rank_unavailable"
    end

    if expectedRank < minimumRank then
        expectedRank = minimumRank
    end
    if expectedRank > maxRank then
        expectedRank = maxRank
    end

    return expectedRank, maxRank, minimumRank, nil
end

local function MarkAllocatorModified(result, allocator)
    if type(result) ~= "table" or type(allocator) ~= "table" then
        return
    end

    if type(result.modifiedAllocatorSet) == "table" and result.modifiedAllocatorSet[allocator] == true then
        return
    end

    result.modifiedAllocatorSet = result.modifiedAllocatorSet or {}
    result.modifiedAllocators = result.modifiedAllocators or {}
    result.modifiedAllocatorSet[allocator] = true
    result.modifiedAllocators[#result.modifiedAllocators + 1] = allocator
end

local function TryIncreasePassiveTowardRank(skillData, targetRank, result, entry, effectiveRank, maxRank, minimumRank)
    local allocator = Util:SafeCallMethod(skillData, "GetPointAllocator")
    if type(allocator) ~= "table" then
        return false, "allocator_unavailable"
    end

    local currentRank = effectiveRank
    if currentRank >= targetRank then
        return false, nil
    end

    maxRank = NormalizeNonNegativeInteger(maxRank) or targetRank
    minimumRank = NormalizeNonNegativeInteger(minimumRank) or 0
    local safetyLimit = math.max(maxRank + 2, 5)
    local changed = false
    local stopReason = "target_reached"
    local step = 0
    local allocatorRank = NormalizeNonNegativeInteger(Util:SafeCallMethod(allocator, "GetRank")) or currentRank

    local canIncreaseRank = type(allocator.CanIncreaseRank) == "function"
        and allocator:CanIncreaseRank() == true

    if currentRank <= 0 and canIncreaseRank ~= true then
        if type(allocator.CanPurchase) == "function" and allocator:CanPurchase() == true then
            if CallAllocatorMutation(allocator, "Purchase") then
                MarkAllocatorModified(result, allocator)
                currentRank = SetPendingRankFromAllocator(result, entry, allocator, 1) or 1
                allocatorRank = NormalizeNonNegativeInteger(Util:SafeCallMethod(allocator, "GetRank")) or currentRank
                result.appliedCount = result.appliedCount + 1
                changed = true
            else
                return false, "purchase_failed"
            end
        else
            if type(allocator.HasEnoughAvailableSkillPointsForSingleTransaction) == "function"
                and allocator:HasEnoughAvailableSkillPointsForSingleTransaction() ~= true then
                stopReason = "insufficient_skill_points"
            else
                stopReason = "cannot_purchase"
            end
            return changed, changed and nil or stopReason
        end
    end

    while step < safetyLimit do
        allocatorRank = NormalizeNonNegativeInteger(Util:SafeCallMethod(allocator, "GetRank")) or currentRank
        if allocatorRank >= targetRank then
            stopReason = "target_reached"
            break
        end

        canIncreaseRank = type(allocator.CanIncreaseRank) == "function"
            and allocator:CanIncreaseRank() == true
        if canIncreaseRank ~= true then
            if type(allocator.HasEnoughAvailableSkillPointsForSingleTransaction) == "function"
                and allocator:HasEnoughAvailableSkillPointsForSingleTransaction() ~= true then
                stopReason = "insufficient_skill_points"
            else
                stopReason = "cannot_increase_rank"
            end
            break
        end

        step = step + 1
        local ignoreCallbacks = allocatorRank + 1 < targetRank
        local stepChanged = CallAllocatorMutation(allocator, "IncreaseRank", ignoreCallbacks)

        if stepChanged then
            MarkAllocatorModified(result, allocator)
            currentRank = SetPendingRankFromAllocator(result, entry, allocator, allocatorRank + 1)
                or allocatorRank + 1
            result.appliedCount = result.appliedCount + 1
            changed = true
        else
            stopReason = "increase_rank_failed"
            break
        end
    end

    if step >= safetyLimit and (NormalizeNonNegativeInteger(Util:SafeCallMethod(allocator, "GetRank")) or currentRank) < targetRank then
        stopReason = "safety_limit"
        LogExactRestoreDebug(
            "safety_limit",
            "attempt=" .. tostring(type(result) == "table" and result.attempts or nil),
            "line=" .. tostring(type(entry) == "table" and entry.skillLineId or nil),
            "skillIndex=" .. tostring(type(entry) == "table" and entry.skillIndex or nil),
            "skillName=" .. tostring(GetSkillName(skillData)),
            "finalAllocatorRank=" .. tostring(NormalizeNonNegativeInteger(Util:SafeCallMethod(allocator, "GetRank"))),
            "finalPendingRank=" .. tostring(GetPendingRank(result, entry)),
            "targetRank=" .. tostring(targetRank),
            "stepCount=" .. tostring(step)
        )
    end

    if changed then
        return true, nil
    end
    return false, stopReason
end

local function TryReducePassiveTowardRank(skillData, targetRank, result, entry, effectiveRank, minimumRank)
    local allocator = Util:SafeCallMethod(skillData, "GetPointAllocator")
    if type(allocator) ~= "table" then
        return false, "allocator_unavailable"
    end

    local currentRank = effectiveRank
    if currentRank <= targetRank then
        return false, nil
    end

    minimumRank = tonumber(minimumRank) or 0

    if currentRank > math.max(1, minimumRank) then
        if type(allocator.DecreaseRank) ~= "function" then
            return false, "decrease_rank_unavailable"
        end
        if CallAllocatorMutation(allocator, "DecreaseRank") then
            MarkAllocatorModified(result, allocator)
            SetPendingRankFromAllocator(result, entry, allocator, currentRank - 1)
            result.appliedCount = result.appliedCount + 1
            return true, nil
        end
        return false, "decrease_rank_failed"
    end

    if targetRank == 0 and minimumRank <= 0 then
        if type(allocator.Sell) ~= "function" then
            return false, "sell_unavailable"
        end
        if CallAllocatorMutation(allocator, "Sell") then
            MarkAllocatorModified(result, allocator)
            SetPendingRankFromAllocator(result, entry, allocator, 0)
            result.appliedCount = result.appliedCount + 1
            return true, nil
        end
        return false, "sell_failed"
    end

    return false, minimumRank > 0 and "minimum_rank_reached" or "cannot_reduce_rank"
end

local function ApplyExactEntry(entry, result, options)
    local classification = type(entry) == "table" and entry.classification or nil
    if classification == "invalid" then
        MarkEntrySkipped(result, entry, entry.reason or "invalid")
        return false
    end
    if classification == "defer" or classification == "unresolved" or classification == "unavailable" or classification == "ignored" then
        MarkEntrySkipped(result, entry, entry.reason or classification)
        return false
    end
    if classification == "no-op" then
        return false
    end
    if classification ~= "purchase" and classification ~= "reduction" then
        MarkEntrySkipped(result, entry, entry.reason or "unsupported_classification")
        return false
    end
    if not IsEntryOperationAllowed(entry, options) then
        local reason = classification == "reduction" and "reduction_requires_respec_route" or "purchase_not_allowed_in_mode"
        SetEntryBlockReason(result, entry, reason)
        return false
    end

    local targetRank = NormalizeNonNegativeInteger(entry.savedRank)
    if targetRank == nil then
        MarkEntrySkipped(result, entry, "saved_rank_invalid")
        return false
    end

    local skillData, _, _, resolveErr = ResolveEntrySkillData(entry)
    if type(skillData) ~= "table" then
        MarkEntrySkipped(result, entry, resolveErr or "skill_data_unavailable")
        return false
    end

    local maxRank, maxRankSource = GetMaxPassiveRankWithSource(skillData)
    local minimumRank = GetMinimumPassiveRank(skillData)
    local originalTargetRank = targetRank
    if targetRank < minimumRank then
        targetRank = minimumRank
    end
    if maxRank == nil or targetRank > maxRank then
        MarkEntrySkipped(result, entry, "saved_rank_out_of_range")
        LogExactRestoreDebug(
            "entry_skipped",
            "attempt=" .. tostring(result.attempts),
            "line=" .. tostring(entry.skillLineId),
            "skillIndex=" .. tostring(entry.skillIndex),
            "savedRank=" .. tostring(targetRank),
            "originalSavedRank=" .. tostring(originalTargetRank),
            "maxRank=" .. tostring(maxRank),
            "maxRankSource=" .. tostring(maxRankSource),
            "minimumRank=" .. tostring(minimumRank),
            "classification=" .. tostring(classification),
            "reason=saved_rank_out_of_range"
        )
        return false
    end

    local liveRank = GetRestorableCurrentPassiveRank(skillData)
    local pendingRank = GetPendingRank(result, entry)
    local effectiveRank = pendingRank ~= nil and pendingRank or liveRank

    local changed, reason
    if classification == "purchase" then
        local allowRespecPurchase = type(options) == "table"
            and options.operationMode == "respec_transaction"
            and IsRespecContextReady()
        if not IsPurchaseContextReady() and not allowRespecPurchase then
            reason = "purchase_context_required"
            SetEntryBlockReason(result, entry, reason)
            return false
        end
        changed, reason = TryIncreasePassiveTowardRank(skillData, targetRank, result, entry, effectiveRank, maxRank, minimumRank)
    else
        if type(options) ~= "table"
            or options.operationMode ~= "respec_transaction"
            or not IsRespecContextReady() then
            reason = "respec_mode_required"
            SetEntryBlockReason(result, entry, reason)
            return false
        end
        changed, reason = TryReducePassiveTowardRank(skillData, targetRank, result, entry, effectiveRank, minimumRank)
    end

    if reason ~= nil then
        SetEntryBlockReason(result, entry, reason)
    end

    return changed == true
end

local function BuildFinalResiduals(build, result)
    if type(result) == "table" and result.operationMode == "respec_transaction" then
        return
    end

    local verify = M:VerifyPostCommitLiveRanks(build, result, {
        source = "passive_exact_apply_final",
        resetResiduals = true,
        includeModeInLog = true,
    })
    return verify
end

local function ScheduleExactRetry(callback, delayMs)
    if type(zo_callLater) == "function" then
        zo_callLater(callback, delayMs)
        return true
    end
    return false
end

local function CompleteExactApply(completion, success, err, result, delayMs)
    if type(completion) ~= "function" then
        return
    end
    if type(zo_callLater) == "function" then
        zo_callLater(function()
            completion(success == true, err, result)
        end, tonumber(delayMs) or 0)
        return
    end
    completion(success == true, err, result)
end

function CountSnapshotEntries(snapshot)
    local lineCount = 0
    local entryCount = 0
    local zeroCount = 0
    for _, lineEntries in pairs(type(snapshot) == "table" and type(snapshot.lines) == "table" and snapshot.lines or {}) do
        if type(lineEntries) == "table" then
            lineCount = lineCount + 1
            for _, rank in pairs(lineEntries) do
                entryCount = entryCount + 1
                if tonumber(rank) == 0 then
                    zeroCount = zeroCount + 1
                end
            end
        end
    end
    return lineCount, entryCount, zeroCount
end

local function CapturePassiveLineEntries(skillLineData)
    local entries = {}
    if type(skillLineData) ~= "table"
        or type(skillLineData.GetNumSkills) ~= "function"
        or type(skillLineData.GetSkillDataByIndex) ~= "function" then
        return entries
    end

    local numSkills = tonumber(skillLineData:GetNumSkills()) or 0
    for skillIndex = 1, numSkills do
        local skillData = skillLineData:GetSkillDataByIndex(skillIndex)
        local relevant = IsPassiveSnapshotRelevantSkill(skillData)
        if relevant then
            local currentRank = GetRestorableCurrentPassiveRank(skillData)
            entries[skillIndex] = currentRank
        end
    end
    return entries
end

local function IterateManagedSkillLines(callback)
    if type(callback) ~= "function"
        or type(SKILLS_DATA_MANAGER) ~= "table"
        or type(SKILLS_DATA_MANAGER.SkillTypeIterator) ~= "function" then
        return
    end

    local seen = {}
    for _, skillTypeData in SKILLS_DATA_MANAGER:SkillTypeIterator() do
        if type(skillTypeData) == "table" and type(skillTypeData.SkillLineIterator) == "function" then
            for _, skillLineData in skillTypeData:SkillLineIterator() do
                skillLineData = RefreshSkillLineData(skillLineData)
                local skillLineId = GetSkillLineId(skillLineData)
                if skillLineId ~= nil and seen[skillLineId] ~= true and not IsClassMasteryLine(skillLineData) then
                    seen[skillLineId] = true
                    callback(skillLineData, skillLineId)
                end
            end
        end
    end
end

local function CaptureAvailableSnapshot(skipClassLines)
    local snapshot = {
        version = SNAPSHOT_VERSION,
        lines = {},
    }

    IterateManagedSkillLines(function(skillLineData, skillLineId)
        if IsAvailableSkillLine(skillLineData) then
            local isClassLine = ClassLineHelper:IsClassSkillLine(skillLineData, skillLineId)
            if skipClassLines ~= true or isClassLine ~= true then
                local entries = CapturePassiveLineEntries(skillLineData)
                local hasEntry = false
                for _ in pairs(entries) do
                    hasEntry = true
                    break
                end
                if hasEntry then
                    snapshot.lines[skillLineId] = entries
                end
            end
        end
    end)

    return snapshot
end

local function MergeTargetClassLinesFromExisting(target, existingSnapshot, targetLineIds)
    local targetLineSet = BuildLineIdSet(targetLineIds)
    local existingLines = type(existingSnapshot) == "table" and type(existingSnapshot.lines) == "table" and existingSnapshot.lines or {}
    for skillLineId in pairs(targetLineSet) do
        local existingLine = existingLines[skillLineId] or existingLines[tostring(skillLineId)]
        if type(existingLine) == "table" then
            target.lines[skillLineId] = Util:DeepCopy(existingLine)
        end
    end
end

function M:CaptureCurrentSnapshot(options)
    options = type(options) == "table" and options or {}
    local build = options.build
    local targetLineIds = type(build) == "table"
        and type(build.subclass) == "table"
        and build.subclass.targetSkillLineIds
        or nil
    local classChanged, classDiagnostics = ClassLineHelper:HasClassCompositionChanged(build)

    local snapshot = CaptureAvailableSnapshot(classChanged == true)
    local captureState = "full"
    if classChanged == true then
        MergeTargetClassLinesFromExisting(snapshot, options.existingSnapshot, targetLineIds)
        captureState = "partial_class_mismatch"
    elseif classChanged == nil then
        captureState = "full_class_comparison_unresolved"
    end

    local lineCount, entryCount, zeroCount = CountSnapshotEntries(snapshot)
    Log.LogDebugSummary(
        "Passive snapshot capture summary",
        "overwriteType=" .. tostring(options.overwriteType),
        "buildId=" .. tostring(options.buildId),
        "captureState=" .. tostring(captureState),
        "lineCount=" .. tostring(lineCount),
        "entryCount=" .. tostring(entryCount),
        "rankZeroCount=" .. tostring(zeroCount),
        "classComparisonReason=" .. tostring(type(classDiagnostics) == "table" and classDiagnostics.reason or nil)
    )

    return snapshot, {
        ok = true,
        captureState = captureState,
        classCompositionChanged = classChanged == true,
        classDiagnostics = classDiagnostics,
        lineCount = lineCount,
        entryCount = entryCount,
        zeroCount = zeroCount,
    }
end

function M:AnalyzeBuild(build, options)
    local policy = options.passiveRestore
    local analysis = CreateAnalysis(build, policy)

    if policy == POLICY_NONE then
        analysis.snapshotState = "not_required"
        return FinalizeAnalysis(analysis)
    end
    if policy == POLICY_CLASS_ALL_PURCHASE then
        return AnalyzeClassAllPurchase(build, analysis)
    end
    if policy == POLICY_CLASS_ONLY or policy == POLICY_ALL then
        return AnalyzeExactRestore(build, analysis)
    end

    analysis.ok = false
    analysis.blockReason = "passive_policy_invalid"
    IncrementReason(analysis, "passive_policy_invalid")
    return FinalizeAnalysis(analysis)
end

function M:VerifyPostCommitLiveRanks(build, result, options)
    options = type(options) == "table" and options or {}
    local verifyEntries = type(result.targetEntries) == "table" and result.targetEntries or nil

    local analysis = self:AnalyzeBuild(build, {
        source = options.source or "passive_exact_post_commit_verify",
        passiveRestore = result.policy,
    })
    result.postCommitAnalysis = analysis
    result.finalAnalysis = analysis
    if verifyEntries == nil then
        verifyEntries = type(analysis) == "table" and analysis.targetEntries or {}
    end
    result.targetEntries = verifyEntries

    if options.resetResiduals == true then
        result.residualCount = 0
        result.residualEntries = {}
        result.hasResidual = false
    end

    local verify = {
        checkedCount = 0,
        mismatchCount = 0,
        missingCount = 0,
        pendingMatchedCount = 0,
        liveMatchedCount = 0,
        pendingLiveUpdateCount = 0,
        suppressResidualMutation = options.suppressResidualMutation == true,
        mismatchEntries = {},
        missingEntries = {},
        pendingLiveUpdateEntries = {},
    }

    for _, entry in ipairs(verifyEntries) do
        if ShouldVerifyEntryLiveRank(entry) then
            local pendingRank = GetPendingRank(result, entry)
            local entryBlockReason = type(result.entryBlockReasons) == "table"
                and result.entryBlockReasons[BuildEntryKey(entry)]
                or nil
            local skillData, _, _, resolveErr = ResolveEntrySkillData(entry)
            if type(skillData) ~= "table" then
                AppendVerifyMissing(result, verify, entry, resolveErr or "skill_data_unavailable", pendingRank)
            else
                local expectedRank, _, _, expectedErr = ResolveExpectedLiveRank(entry, skillData)
                if expectedRank == nil then
                    AppendVerifyMissing(result, verify, entry, expectedErr or "expected_rank_unavailable", pendingRank)
                else
                    verify.checkedCount = verify.checkedCount + 1
                    local actualRank = GetRestorableCurrentPassiveRank(skillData)
                    if pendingRank == expectedRank then
                        verify.pendingMatchedCount = verify.pendingMatchedCount + 1
                    end
                    if actualRank == expectedRank then
                        verify.liveMatchedCount = verify.liveMatchedCount + 1
                    end
                    if actualRank ~= expectedRank then
                        if options.deferPendingLiveMismatches == true and pendingRank == expectedRank then
                            verify.pendingLiveUpdateCount = verify.pendingLiveUpdateCount + 1
                            verify.pendingLiveUpdateEntries[#verify.pendingLiveUpdateEntries + 1] = {
                                skillLineId = type(entry) == "table" and entry.skillLineId or nil,
                                skillIndex = type(entry) == "table" and entry.skillIndex or nil,
                                savedRank = type(entry) == "table" and entry.savedRank or nil,
                                expectedRank = expectedRank,
                                actualRank = actualRank,
                                pendingRank = pendingRank,
                                classification = type(entry) == "table" and entry.classification or nil,
                                reason = "pending_live_update_wait",
                                rawReason = "pending_live_update_wait",
                                blockReason = entryBlockReason,
                                category = NormalizePassiveExactReason(entryBlockReason or "pending_live_update_wait"),
                                userReason = ResolvePassiveExactUserReason(
                                    NormalizePassiveExactReason(entryBlockReason or "pending_live_update_wait")
                                ),
                            }
                        else
                            AppendVerifyMismatch(
                                result,
                                verify,
                                entry,
                                "post_commit_live_rank_mismatch",
                                expectedRank,
                                actualRank,
                                pendingRank,
                                entryBlockReason
                            )
                        end
                    end
                end
            end
        elseif type(entry) == "table" and entry.classification == "invalid" then
            LogExactRestoreDebug(
                "final_invalid",
                "line=" .. tostring(entry.skillLineId),
                "skillIndex=" .. tostring(entry.skillIndex),
                "savedRank=" .. tostring(entry.savedRank),
                "currentRank=" .. tostring(entry.currentRank),
                "maxRank=" .. tostring(entry.maxRank),
                "reason=" .. tostring(entry.reason or "invalid")
            )
            if options.suppressResidualMutation ~= true then
                MarkEntrySkipped(result, entry, entry.reason or "invalid")
            end
        end
    end

    result.postCommitVerify = verify
    if options.suppressSummaryLog ~= true then
        local mode = type(result) == "table" and result.operationMode or nil
        local parts = {
            "Passive exact post-commit verify",
            "checked=" .. tostring(verify.checkedCount),
            "mismatch=" .. tostring(verify.mismatchCount),
            "missing=" .. tostring(verify.missingCount),
        }
        if options.includeModeInLog == true then
            parts[#parts + 1] = "mode=" .. tostring(mode)
        end
        if options.retryExhausted == true then
            parts[#parts + 1] = "retryExhausted=true"
        end
        Log.LogDebugSummary(unpack(parts))
    end

    if verify.mismatchCount > 0 and options.suppressMismatchDetailLog ~= true then
        for _, detail in ipairs(verify.mismatchEntries) do
            Log.LogDebugSummary(
                "Passive exact post-commit verify mismatch",
                "line=" .. tostring(detail.skillLineId),
                "skillIndex=" .. tostring(detail.skillIndex),
                "savedRank=" .. tostring(detail.savedRank),
                "expectedRank=" .. tostring(detail.expectedRank),
                "actualRank=" .. tostring(detail.actualRank),
                "pendingRank=" .. tostring(detail.pendingRank),
                "classification=" .. tostring(detail.classification),
                "reason=" .. tostring(detail.reason)
            )
        end
    end

    if options.suppressResidualMutation ~= true then
        FinalizePassiveExactResultStatus(result)
    end

    return verify
end

local function AddPassiveExactSummaryReason(summary, reason)
    local category = NormalizePassiveExactReason(reason)
    local userReason = ResolvePassiveExactUserReason(category)
    summary.residualReasonCounts[category] = (summary.residualReasonCounts[category] or 0) + 1
    AppendUnique(summary.userReasons, summary.userReasonSet, userReason)
end

local function BuildPassiveExactAggregateSummary(result)
    local summary = {
        restored = tonumber(type(result) == "table" and result.appliedCount or nil) or 0,
        skipped = tonumber(type(result) == "table" and result.skippedCount or nil) or 0,
        failed = 0,
        criticalResidual = 0,
        residual = tonumber(type(result) == "table" and result.residualCount or nil) or 0,
        invalid = tonumber(type(result) == "table" and result.invalidCount or nil) or 0,
        checked = 0,
        mismatch = 0,
        missing = 0,
        residualReasonCounts = {},
        userReasons = {},
        userReasonSet = {},
    }

    local verify = type(result) == "table" and result.postCommitVerify or nil
    if type(verify) == "table" then
        summary.checked = tonumber(verify.checkedCount) or 0
        summary.mismatch = tonumber(verify.mismatchCount) or 0
        summary.missing = tonumber(verify.missingCount) or 0
    end

    for _, entry in ipairs(type(result) == "table" and result.skippedEntries or {}) do
        summary.failed = summary.failed + 1
        AddPassiveExactSummaryReason(summary, type(entry) == "table" and (entry.category or entry.reason) or nil)
    end

    for _, entry in ipairs(type(result) == "table" and result.residualEntries or {}) do
        summary.failed = summary.failed + 1
        AddPassiveExactSummaryReason(summary, type(entry) == "table" and (entry.category or entry.blockReason or entry.reason) or nil)
    end

    for reason in pairs(type(result) == "table" and result.reasonCounts or {}) do
        if IsPassiveExactFatalReason(reason) then
            AddPassiveExactSummaryReason(summary, reason)
        end
    end

    summary.userReasonSet = nil
    summary.criticalResidual = summary.failed
    return summary
end

function FinalizePassiveExactResultStatus(result)
    if type(result) ~= "table" then
        return nil
    end

    local summary = BuildPassiveExactAggregateSummary(result)
    result.aggregateSummary = summary
    result.residualReasonCounts = summary.residualReasonCounts
    result.userReasons = summary.userReasons

    local fatal = result.ok == false
    if IsPassiveExactFatalReason(result.code) then
        fatal = true
    end
    for reason in pairs(type(result.reasonCounts) == "table" and result.reasonCounts or {}) do
        if IsPassiveExactFatalReason(reason) then
            fatal = true
            break
        end
    end

    if fatal then
        result.finalStatus = "failure"
        result.resultCode = result.code or "passive_exact_restore_failed"
    elseif (summary.failed or 0) > 0 or (summary.mismatch or 0) > 0 or (summary.missing or 0) > 0 then
        result.finalStatus = "partial_success"
        result.resultCode = "passive_exact_restore_partial"
        result.partialSuccessResult = {
            sourcePhase = "PassiveSkills",
            resultCode = result.resultCode,
            reasons = summary.userReasons,
            residualSummary = summary,
        }
    else
        result.finalStatus = "full_success"
        result.resultCode = nil
        result.partialSuccessResult = nil
    end

    return result.finalStatus
end

local function LogStandaloneVerifyWait(verify, retryIndex)
    Log.LogDebugSummary(
        "Passive exact standalone verify wait",
        "checked=" .. tostring(type(verify) == "table" and verify.checkedCount or 0),
        "pendingMatched=" .. tostring(type(verify) == "table" and verify.pendingMatchedCount or 0),
        "liveMatched=" .. tostring(type(verify) == "table" and verify.liveMatchedCount or 0),
        "retry=" .. tostring(retryIndex)
    )
end

local function ShouldLogPassiveExactAttempt(attempt, maxAttempts, analysis)
    attempt = tonumber(attempt)
    maxAttempts = tonumber(maxAttempts) or 0
    if attempt == nil then
        return false
    end

    local midpoint = maxAttempts > 2 and math.ceil(maxAttempts / 2) or nil
    return attempt == 1
        or attempt == midpoint
        or (maxAttempts > 0 and attempt >= maxAttempts)
        or type(analysis) ~= "table"
        or analysis.ok ~= true
end

function M:WaitStandalonePostCommitLiveRanks(build, result, options, completion)
    options = type(options) == "table" and options or {}
    local delayMs = tonumber(options.standaloneVerifyWaitDelayMs) or STANDALONE_VERIFY_WAIT_DELAY_MS
    local maxRetries = tonumber(options.standaloneVerifyWaitMaxRetries) or STANDALONE_VERIFY_WAIT_MAX_RETRIES
    if maxRetries < 1 then
        maxRetries = 1
    end

    local retryIndex = 0
    local function finish(retryExhausted)
        local verify = self:VerifyPostCommitLiveRanks(build, result, {
            source = "passive_exact_apply_final",
            resetResiduals = true,
            includeModeInLog = true,
            retryExhausted = retryExhausted == true,
            suppressMismatchDetailLog = result.operationMode == "standalone",
        })
        if type(completion) == "function" then
            CompleteExactApply(completion, true, nil, result, 0)
        end
        return verify
    end

    local function poll()
        retryIndex = retryIndex + 1
        local verify = self:VerifyPostCommitLiveRanks(build, result, {
            source = "passive_exact_apply_final",
            resetResiduals = true,
            deferPendingLiveMismatches = true,
            suppressResidualMutation = true,
            suppressSummaryLog = true,
            suppressMismatchDetailLog = true,
        })

        local pendingLiveUpdateCount = type(verify) == "table" and (verify.pendingLiveUpdateCount or 0) or 0
        if pendingLiveUpdateCount > 0 or retryIndex > 1 then
            LogStandaloneVerifyWait(verify, retryIndex)
        end

        if pendingLiveUpdateCount <= 0 then
            return finish(false)
        end

        if retryIndex >= maxRetries or type(zo_callLater) ~= "function" then
            return finish(true)
        end

        zo_callLater(poll, delayMs)
        return nil
    end

    return poll()
end

function M:RunExactRestore(build, options)
    options = type(options) == "table" and options or {}
    local completion = type(options.completion) == "function" and options.completion or nil
    local pipelineContext = options.pipelineContext
    local skipForSkillSettings, skillSettingsReason = ResolveSkillSettingsPassiveSkip(pipelineContext)
    if skipForSkillSettings then
        RecordSkillSettingsPassiveSkip(pipelineContext, skillSettingsReason)
        local skippedResult = MarkExactResultSkippedForSkillSettings(
            CreateExactApplyResult(build, nil, options),
            skillSettingsReason
        )
        if completion ~= nil then
            CompleteExactApply(completion, true, nil, skippedResult, 0)
            return true, "deferred", skippedResult
        end
        return true, nil, skippedResult
    end

    local initialAnalysis = self:AnalyzeBuild(build, {
        source = "passive_exact_apply",
        passiveRestore = options.passiveRestore,
    })
    local result = CreateExactApplyResult(build, initialAnalysis, options)
    result.maxAttempts = math.max(result.maxAttempts, ResolveRequiredAttemptCount(initialAnalysis))
    LogExactRestoreDebug(
        "begin",
        "policy=" .. tostring(result.policy),
        "operationMode=" .. tostring(result.operationMode),
        "requestedMaxAttempts=" .. tostring(tonumber(type(options) == "table" and options.maxAttempts or nil)),
        "effectiveMaxAttempts=" .. tostring(result.maxAttempts),
        "retryDelayMs=" .. tostring(result.retryDelayMs),
        "snapshotState=" .. tostring(type(initialAnalysis) == "table" and initialAnalysis.snapshotState or nil),
        "purchaseCount=" .. tostring(type(initialAnalysis) == "table" and initialAnalysis.purchaseCount or nil),
        "reductionCount=" .. tostring(type(initialAnalysis) == "table" and initialAnalysis.reductionCount or nil),
        "deferCount=" .. tostring(type(initialAnalysis) == "table" and initialAnalysis.deferCount or nil),
        "invalidCount=" .. tostring(type(initialAnalysis) == "table" and initialAnalysis.invalidCount or nil),
        "reasonCounts=" .. tostring(type(initialAnalysis) == "table" and BuildReasonSummary(initialAnalysis.reasonCounts) or nil)
    )

    if type(initialAnalysis) ~= "table" or initialAnalysis.ok ~= true then
        result.ok = false
        result.code = type(initialAnalysis) == "table" and initialAnalysis.blockReason or "passive_analysis_failed"
        IncrementResultReason(result, result.code)
        FinalizePassiveExactResultStatus(result)
        if completion ~= nil then
            CompleteExactApply(completion, false, result.code, result)
            return true, "deferred", result
        end
        return false, result.code, result
    end

    if initialAnalysis.policy ~= POLICY_CLASS_ONLY and initialAnalysis.policy ~= POLICY_ALL then
        result.ok = true
        result.skipped = true
        result.code = "policy_not_exact_restore"
        IncrementResultReason(result, "policy_not_exact_restore")
        FinalizePassiveExactResultStatus(result)
        if completion ~= nil then
            CompleteExactApply(completion, true, nil, result)
            return true, "deferred", result
        end
        return true, nil, result
    end

    local maxAttempts = result.maxAttempts
    local retryDelayMs = result.retryDelayMs
    local completionDelayMs = tonumber(options.completionDelayMs) or EXACT_APPLY_COMPLETION_DELAY_MS
    local runner

    local finalize = function(delayMs)
        if result.operationMode == "standalone" and completion ~= nil and type(zo_callLater) == "function" then
            M:WaitStandalonePostCommitLiveRanks(build, result, options, completion)
            return true, "deferred", result
        end

        BuildFinalResiduals(build, result)
        if completion ~= nil then
            CompleteExactApply(completion, true, nil, result, delayMs)
        end
        return true, nil, result
    end

    runner = function()
        local retrySkipForSkillSettings, retrySkillSettingsReason = ResolveSkillSettingsPassiveSkip(pipelineContext)
        if retrySkipForSkillSettings then
            RecordSkillSettingsPassiveSkip(pipelineContext, retrySkillSettingsReason)
            MarkExactResultSkippedForSkillSettings(result, retrySkillSettingsReason)
            if completion ~= nil then
                CompleteExactApply(completion, true, nil, result, 0)
            end
            return true, nil, result
        end

        result.attempts = result.attempts + 1
        local analysis = M:AnalyzeBuild(build, {
            source = "passive_exact_apply_retry",
            attempt = result.attempts,
            passiveRestore = result.policy,
        })
        result.analysis = analysis
        result.targetEntries = type(analysis) == "table" and analysis.targetEntries or result.targetEntries

        if ShouldLogPassiveExactAttempt(result.attempts, maxAttempts, analysis) then
            LogExactRestoreDebug(
                "attempt",
                "attempt=" .. tostring(result.attempts),
                "maxAttempts=" .. tostring(maxAttempts),
                "ok=" .. tostring(type(analysis) == "table" and analysis.ok == true),
                "purchaseCount=" .. tostring(type(analysis) == "table" and analysis.purchaseCount or nil),
                "reductionCount=" .. tostring(type(analysis) == "table" and analysis.reductionCount or nil),
                "deferCount=" .. tostring(type(analysis) == "table" and analysis.deferCount or nil),
                "invalidCount=" .. tostring(type(analysis) == "table" and analysis.invalidCount or nil),
                "reasonCounts=" .. tostring(type(analysis) == "table" and BuildReasonSummary(analysis.reasonCounts) or nil)
            )
        end

        if type(analysis) ~= "table" or analysis.ok ~= true then
            result.ok = false
            result.code = type(analysis) == "table" and analysis.blockReason or "passive_analysis_failed"
            IncrementResultReason(result, result.code)
            FinalizePassiveExactResultStatus(result)
            if completion ~= nil then
                CompleteExactApply(completion, false, result.code, result)
            end
            return false, result.code, result
        end

        local changed = false
        local actionableCount = 0
        for _, entry in ipairs(analysis.targetEntries or {}) do
            if entry.classification == "purchase" or entry.classification == "reduction" then
                actionableCount = actionableCount + 1
                if ApplyExactEntry(entry, result, options) then
                    changed = true
                end
            end
        end

        if actionableCount == 0 or changed ~= true then
            LogExactRestoreDebug(
                "finalize_trigger",
                "attempt=" .. tostring(result.attempts),
                "actionableCount=" .. tostring(actionableCount),
                "changed=" .. tostring(changed == true),
                "reasonCounts=" .. tostring(BuildReasonSummary(result.reasonCounts))
            )
            return finalize(0)
        end

        if result.attempts >= maxAttempts then
            LogExactRestoreDebug(
                "finalize_max_attempts",
                "attempt=" .. tostring(result.attempts),
                "maxAttempts=" .. tostring(maxAttempts),
                "reasonCounts=" .. tostring(BuildReasonSummary(result.reasonCounts))
            )
            if completion ~= nil and ScheduleExactRetry(function()
                finalize(0)
            end, completionDelayMs) then
                return true, "deferred", result
            end
            return finalize(0)
        end

        if completion ~= nil and ScheduleExactRetry(runner, retryDelayMs) then
            return true, "deferred", result
        end

        return runner()
    end

    if completion ~= nil and type(zo_callLater) == "function" then
        zo_callLater(function()
            runner()
        end, 0)
        return true, "deferred", result
    end

    local ok, err, runResult = runner()
    if completion ~= nil then
        return true, "deferred", result
    end
    return ok, err, runResult or result
end
