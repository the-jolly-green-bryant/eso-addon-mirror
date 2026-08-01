local Addon = LarvalTearMod
local M = Addon.Modules.SkillRespecPurchase
local Util = Addon.Common.Util

local OUTCOME_PURCHASED = "purchased"
local OUTCOME_ALREADY_OWNED_OR_PENDING = "already_owned_or_pending"
local OUTCOME_SKIPPED_INSUFFICIENT_POINTS = "skipped_insufficient_points"
local OUTCOME_SKIPPED_CANNOT_PURCHASE = "skipped_cannot_purchase"
local OUTCOME_UNEXPECTED_FAILURE = "unexpected_failure"

local function CreateSummary()
    return {
        attemptedCount = 0,
        selectedCount = 0,
        dedupedCount = 0,
        purchasedCount = 0,
        alreadyOwnedOrPendingCount = 0,
        skippedInsufficientPointsCount = 0,
        skippedCannotPurchaseCount = 0,
        unexpectedFailureCount = 0,
        degradedCandidateCount = 0,
        hardFailure = false,
        hardFailureReason = nil,
        hardFailureTarget = nil,
        outcomeCounts = {},
        expectedMissingAbilityIds = {},
        expectedMissingProgressionIds = {},
    }
end

local function IncrementOutcome(summary, outcome)
    if type(summary) ~= "table" or type(outcome) ~= "string" or outcome == "" then
        return
    end

    summary.outcomeCounts[outcome] = (summary.outcomeCounts[outcome] or 0) + 1
end

local function AppendExpectedMissing(summary, resolvedTarget)
    if type(summary) ~= "table" or type(resolvedTarget) ~= "table" then
        return
    end

    local targetAbilityId = resolvedTarget.targetAbilityId
    if type(targetAbilityId) == "number" and targetAbilityId > 0 then
        summary.expectedMissingAbilityIds[#summary.expectedMissingAbilityIds + 1] = targetAbilityId
    end

    local progressionId = resolvedTarget.progressionId
    if type(progressionId) == "number" and progressionId > 0 then
        summary.expectedMissingProgressionIds[#summary.expectedMissingProgressionIds + 1] = progressionId
    end
end

local function ResolveSkillLineId(skillData)
    if type(skillData) == "table" and type(skillData.GetSkillLineId) == "function" then
        local skillLineId = skillData:GetSkillLineId()
        if type(skillLineId) == "number" and skillLineId > 0 then
            return skillLineId
        end
    end

    local skillLineData = type(skillData) == "table"
        and type(skillData.GetSkillLineData) == "function"
        and skillData:GetSkillLineData()
        or nil
    if type(skillLineData) == "table" and type(skillLineData.GetId) == "function" then
        local skillLineId = skillLineData:GetId()
        if type(skillLineId) == "number" and skillLineId > 0 then
            return skillLineId
        end
    end

    if type(skillLineData) == "table" and type(skillLineData.GetSkillLineId) == "function" then
        local skillLineId = skillLineData:GetSkillLineId()
        if type(skillLineId) == "number" and skillLineId > 0 then
            return skillLineId
        end
    end

    return nil
end

local function MarkOutcome(summary, audit, resolvedTarget, outcome, reason)
    audit.outcome = outcome
    audit.reason = reason
    IncrementOutcome(summary, outcome)

    if outcome == OUTCOME_PURCHASED then
        summary.purchasedCount = summary.purchasedCount + 1
    elseif outcome == OUTCOME_ALREADY_OWNED_OR_PENDING then
        summary.alreadyOwnedOrPendingCount = summary.alreadyOwnedOrPendingCount + 1
    elseif outcome == OUTCOME_SKIPPED_INSUFFICIENT_POINTS then
        summary.skippedInsufficientPointsCount = summary.skippedInsufficientPointsCount + 1
        summary.degradedCandidateCount = summary.degradedCandidateCount + 1
        AppendExpectedMissing(summary, resolvedTarget)
    elseif outcome == OUTCOME_SKIPPED_CANNOT_PURCHASE then
        summary.skippedCannotPurchaseCount = summary.skippedCannotPurchaseCount + 1
    elseif outcome == OUTCOME_UNEXPECTED_FAILURE then
        summary.unexpectedFailureCount = summary.unexpectedFailureCount + 1
    end
end

local function FinalizeFailure(summary, resolvedTarget, target, reason)
    summary.hardFailure = true
    summary.hardFailureReason = reason
    summary.hardFailureTarget = target
    if type(resolvedTarget) == "table" and resolvedTarget.targetAbilityId ~= nil then
        summary.hardFailureTargetAbilityId = resolvedTarget.targetAbilityId
        summary.hardFailureProgressionId = resolvedTarget.progressionId
    end
end

function M:ResolveTarget(apply, target)
    if type(SKILLS_DATA_MANAGER) ~= "table" then
        return nil, "skills_data_manager_unavailable"
    end

    local targetAbilityId = target and target.targetAbilityId or nil
    if targetAbilityId == nil or targetAbilityId <= 0 then
        return nil, "invalid_target_ability_id"
    end

    local progressionData = Util:SafeCallMethod(SKILLS_DATA_MANAGER, "GetProgressionDataByAbilityId", targetAbilityId)
    if progressionData == nil then
        return nil, "unknown_target_ability"
    end

    local skillData = Util:SafeCallMethod(progressionData, "GetSkillData")
    if skillData == nil then
        return nil, "skill_data_unavailable"
    end

    local allocator = Util:SafeCallMethod(skillData, "GetPointAllocator")
    if allocator == nil then
        return nil, "allocator_unavailable"
    end

    local skillLineData = Util:SafeCallMethod(skillData, "GetSkillLineData")

    return {
        targetAbilityId = targetAbilityId,
        hotbarCategory = target.hotbarCategory,
        slotIndex = target.slotIndex,
        progressionId = target.progressionId or Util:SafeCallMethod(skillData, "GetProgressionId"),
        skillLineId = ResolveSkillLineId(skillData),
        progressionData = progressionData,
        skillLineData = skillLineData,
        skillData = skillData,
        allocator = allocator,
    }
end

function M:ExecutePending(apply, context, skillTargetPlan)
    local purchaseTargets = type(skillTargetPlan) == "table" and skillTargetPlan.purchaseTargets or nil
    if type(purchaseTargets) ~= "table" or #purchaseTargets == 0 then
        local emptySummary = CreateSummary()
        context.purchaseOutcomeSummary = emptySummary
        return true, nil, emptySummary
    end

    context.purchaseTargetAuditEntries = {}
    context.purchaseSelectedProgressionKeys = {}
    local summary = CreateSummary()
    local seen = {}
    for _, target in ipairs(purchaseTargets) do
        summary.attemptedCount = summary.attemptedCount + 1
        local resolvedTarget, resolveErr = self:ResolveTarget(apply, target)
        if resolvedTarget == nil then
            local failedAudit = {
                selected = false,
                purchaseInvoked = false,
                canPurchase = nil,
                hasEnoughPoints = nil,
                pendingObserved = false,
                purchasedObserved = false,
                skipReason = resolveErr,
                outcome = OUTCOME_UNEXPECTED_FAILURE,
                reason = resolveErr,
                targetAbilityId = target and target.targetAbilityId or nil,
                progressionId = target and target.progressionId or nil,
                deduped = false,
                dedupeKey = nil,
            }
            context.purchaseTargetAuditEntries[#context.purchaseTargetAuditEntries + 1] = failedAudit
            MarkOutcome(summary, failedAudit, nil, OUTCOME_UNEXPECTED_FAILURE, resolveErr)
            FinalizeFailure(summary, nil, target, resolveErr)
            context.purchaseOutcomeSummary = summary
            apply:LogRouteBPurchaseTargetAuditSummary(context)
            return false, resolveErr, summary
        end

        local purchaseKey = tostring(resolvedTarget.progressionId or resolvedTarget.targetAbilityId)
        local audit = {
            selected = false,
            purchaseInvoked = false,
            canPurchase = nil,
            hasEnoughPoints = nil,
            purchaseOk = nil,
            pendingObserved = false,
            purchasedObserved = false,
            skipReason = nil,
            deduped = false,
            dedupeKey = purchaseKey,
            targetAbilityId = resolvedTarget.targetAbilityId,
            progressionId = resolvedTarget.progressionId,
            outcome = nil,
            reason = nil,
        }
        local allocator = resolvedTarget.allocator
        if type(allocator) == "table"
            and type(allocator.HasEnoughAvailableSkillPointsForSingleTransaction) == "function" then
            audit.hasEnoughPoints = Util:SafeCallMethod(
                allocator,
                "HasEnoughAvailableSkillPointsForSingleTransaction"
            ) == true
        end
        audit.pendingObserved = Util:SafeCallMethod(allocator, "IsPurchasedChangePending") == true
        audit.purchasedObserved = Util:SafeCallMethod(allocator, "IsPurchased") == true
            or Util:SafeCallMethod(resolvedTarget.skillData, "IsPurchased") == true

        if seen[purchaseKey] then
            audit.skipReason = "duplicate_progression_deduped"
            audit.deduped = true
            summary.dedupedCount = summary.dedupedCount + 1
            context.purchaseTargetAuditEntries[#context.purchaseTargetAuditEntries + 1] = audit
        else
            seen[purchaseKey] = true
            audit.selected = true
            summary.selectedCount = summary.selectedCount + 1
            context.purchaseSelectedProgressionKeys[purchaseKey] = true

            if allocator.CanPurchase ~= nil then
                audit.canPurchase = Util:SafeCallMethod(allocator, "CanPurchase")
                if audit.canPurchase ~= true then
                    local reason = audit.hasEnoughPoints == false
                        and "insufficient_skill_points"
                        or "cannot_purchase_target_skill"
                    audit.skipReason = reason
                    local outcome = nil
                    if audit.pendingObserved == true or audit.purchasedObserved == true then
                        outcome = OUTCOME_ALREADY_OWNED_OR_PENDING
                        reason = "already_owned_or_pending"
                        audit.skipReason = reason
                    else
                        outcome = audit.hasEnoughPoints == false
                            and OUTCOME_SKIPPED_INSUFFICIENT_POINTS
                            or OUTCOME_SKIPPED_CANNOT_PURCHASE
                    end
                    MarkOutcome(summary, audit, resolvedTarget, outcome, reason)
                    context.purchaseTargetAuditEntries[#context.purchaseTargetAuditEntries + 1] = audit
                    if outcome ~= OUTCOME_SKIPPED_INSUFFICIENT_POINTS
                        and outcome ~= OUTCOME_ALREADY_OWNED_OR_PENDING then
                        FinalizeFailure(summary, resolvedTarget, target, reason)
                        context.purchaseOutcomeSummary = summary
                        apply:LogRouteBPurchaseTargetAuditSummary(context)
                        return false, reason, summary
                    end
                elseif allocator.Purchase == nil then
                    audit.skipReason = "purchase_unavailable"
                    MarkOutcome(summary, audit, resolvedTarget, OUTCOME_UNEXPECTED_FAILURE, "purchase_unavailable")
                    context.purchaseTargetAuditEntries[#context.purchaseTargetAuditEntries + 1] = audit
                    FinalizeFailure(summary, resolvedTarget, target, "purchase_unavailable")
                    context.purchaseOutcomeSummary = summary
                    apply:LogRouteBPurchaseTargetAuditSummary(context)
                    return false, "purchase_unavailable", summary
                else
                    local purchaseOk = Util:SafeCallMethod(allocator, "Purchase")
                    audit.purchaseOk = purchaseOk == true
                    audit.pendingObserved = Util:SafeCallMethod(allocator, "IsPurchasedChangePending") == true
                    audit.purchasedObserved = Util:SafeCallMethod(allocator, "IsPurchased") == true
                    audit.purchaseInvoked = true

                    if not purchaseOk then
                        audit.skipReason = "purchase_pending_failed"
                        MarkOutcome(summary, audit, resolvedTarget, OUTCOME_UNEXPECTED_FAILURE, "purchase_pending_failed")
                        context.purchaseTargetAuditEntries[#context.purchaseTargetAuditEntries + 1] = audit
                        FinalizeFailure(summary, resolvedTarget, target, "purchase_pending_failed")
                        context.purchaseOutcomeSummary = summary
                        apply:LogRouteBPurchaseTargetAuditSummary(context)
                        return false, "purchase_pending_failed", summary
                    end

                    if not audit.pendingObserved and not audit.purchasedObserved then
                        audit.skipReason = "purchase_pending_not_observed"
                        MarkOutcome(summary, audit, resolvedTarget, OUTCOME_UNEXPECTED_FAILURE, "purchase_pending_not_observed")
                        context.purchaseTargetAuditEntries[#context.purchaseTargetAuditEntries + 1] = audit
                        FinalizeFailure(summary, resolvedTarget, target, "purchase_pending_not_observed")
                        context.purchaseOutcomeSummary = summary
                        apply:LogRouteBPurchaseTargetAuditSummary(context)
                        return false, "purchase_pending_not_observed", summary
                    end

                    MarkOutcome(summary, audit, resolvedTarget, OUTCOME_PURCHASED, "purchase_observed")
                    context.modifiedAllocators = context.modifiedAllocators or {}
                    context.modifiedAllocators[#context.modifiedAllocators + 1] = allocator
                    context.purchaseTargetAuditEntries[#context.purchaseTargetAuditEntries + 1] = audit
                end
            else
                audit.skipReason = "can_purchase_unavailable"
                MarkOutcome(summary, audit, resolvedTarget, OUTCOME_UNEXPECTED_FAILURE, "can_purchase_unavailable")
                context.purchaseTargetAuditEntries[#context.purchaseTargetAuditEntries + 1] = audit
                FinalizeFailure(summary, resolvedTarget, target, "can_purchase_unavailable")
                context.purchaseOutcomeSummary = summary
                apply:LogRouteBPurchaseTargetAuditSummary(context)
                return false, "can_purchase_unavailable", summary
            end
        end
    end

    context.purchaseOutcomeSummary = summary

    local pendingChanges = type(SKILLS_AND_ACTION_BAR_MANAGER) == "table"
        and SKILLS_AND_ACTION_BAR_MANAGER.HasAnyPendingChanges
        and SKILLS_AND_ACTION_BAR_MANAGER:HasAnyPendingChanges()
        or nil
    if summary.purchasedCount > 0 and pendingChanges ~= true then
        summary.hardFailure = true
        summary.hardFailureReason = "purchase_pending_changes_missing"
        apply:LogRouteBPurchaseTargetAuditSummary(context)
        return false, "purchase_pending_changes_missing", summary
    end

    apply:LogRouteBPurchaseTargetAuditSummary(context)
    return true, nil, summary
end
