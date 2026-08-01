local Addon = LarvalTearMod
local M = Addon.Modules.SkillRespecClassMasteryPurchase
local Util = Addon.Common.Util
local logging = Addon.Modules.SkillRespecLogging
local ClassMasteryLookup = Addon.Modules.ClassMasteryLookup

local function CreateSummary()
    return {
        attemptedCount = 0,
        purchasedCount = 0,
        increasedCount = 0,
        alreadySatisfiedCount = 0,
        failedCount = 0,
        reasonCounts = {},
        targets = {},
    }
end

local function IncrementReason(summary, reason)
    reason = type(reason) == "string" and reason or "unknown"
    summary.reasonCounts[reason] = (summary.reasonCounts[reason] or 0) + 1
end

local function IsAllocatorPurchased(allocator)
    return Util:SafeCallMethod(allocator, "IsPurchased") == true
end

local function GetAllocatorRank(allocator)
    local rank = tonumber(Util:SafeCallMethod(allocator, "GetRank"))
    return rank ~= nil and math.floor(rank) or 0
end

local function ResolvePointFailureReason(allocator, fallback)
    if type(allocator) == "table"
        and type(allocator.HasEnoughAvailableSkillPointsForSingleTransaction) == "function"
        and Util:SafeCallMethod(allocator, "HasEnoughAvailableSkillPointsForSingleTransaction") == false then
        return "insufficient_mastery_points"
    end

    return fallback
end

function M:ResolvePlan(context)
    local routeBConfig = type(context) == "table" and context.routeBConfig or nil
    local pipelinePlan = type(routeBConfig) == "table" and routeBConfig._pipelinePlan or nil
    local skillRespec = type(pipelinePlan) == "table"
        and type(pipelinePlan.configs) == "table"
        and type(pipelinePlan.configs.skillRespec) == "table"
        and pipelinePlan.configs.skillRespec
        or nil
    local diff = type(skillRespec) == "table" and skillRespec.classMasteryReduction or nil
    if type(diff) ~= "table" or diff.requiresRespec ~= true then
        return nil
    end

    return diff
end

function M:Execute(apply, context)
    local plan = self:ResolvePlan(context)
    if type(plan) ~= "table" then
        context.classMasteryPurchaseSummary = CreateSummary()
        return true, nil, context.classMasteryPurchaseSummary
    end

    local targets = type(plan.additions) == "table" and plan.additions or {}
    local summary = CreateSummary()

    for _, target in ipairs(targets) do
        summary.attemptedCount = summary.attemptedCount + 1
        local skillLineId = tonumber(target.skillLineId)
        local abilityId = tonumber(target.abilityId)
        local targetRank = tonumber(target.targetRank)
        skillLineId = skillLineId ~= nil and math.floor(skillLineId) or nil
        abilityId = abilityId ~= nil and math.floor(abilityId) or nil
        targetRank = targetRank ~= nil and math.floor(targetRank) or 0

        local entry = {
            skillLineId = skillLineId,
            abilityId = abilityId,
            currentRank = target.currentRank,
            targetRank = targetRank,
            finalRank = nil,
            purchased = false,
            increased = 0,
            ok = false,
            reason = nil,
        }
        summary.targets[#summary.targets + 1] = entry

        local skillLineData, lineErr = ClassMasteryLookup:ResolveLineData(skillLineId, true, true)
        if skillLineData == nil then
            entry.reason = lineErr or "skill_line_data_missing"
            summary.failedCount = summary.failedCount + 1
            IncrementReason(summary, entry.reason)
        else
            local skillData, skillErr = ClassMasteryLookup:FindPassiveByAbilityId(skillLineData, abilityId)
            local allocator = type(skillData) == "table" and Util:SafeCallMethod(skillData, "GetPointAllocator") or nil
            if skillData == nil then
                entry.reason = skillErr or "skill_data_unavailable"
                summary.failedCount = summary.failedCount + 1
                IncrementReason(summary, entry.reason)
            elseif type(allocator) ~= "table" then
                entry.reason = "allocator_unavailable"
                summary.failedCount = summary.failedCount + 1
                IncrementReason(summary, entry.reason)
            else
                if not IsAllocatorPurchased(allocator) then
                    if Util:SafeCallMethod(allocator, "CanPurchase") ~= true then
                        entry.reason = ResolvePointFailureReason(allocator, "cannot_purchase")
                    elseif Util:SafeCallMethod(allocator, "Purchase") == true then
                        entry.purchased = true
                        summary.purchasedCount = summary.purchasedCount + 1
                        context.modifiedAllocators = context.modifiedAllocators or {}
                        context.modifiedAllocators[#context.modifiedAllocators + 1] = allocator
                    else
                        entry.reason = "purchase_failed"
                    end
                end

                while IsAllocatorPurchased(allocator) and GetAllocatorRank(allocator) < targetRank do
                    if Util:SafeCallMethod(allocator, "CanIncreaseRank") ~= true then
                        entry.reason = entry.reason or ResolvePointFailureReason(allocator, "cannot_increase_rank")
                        break
                    end
                    if Util:SafeCallMethod(allocator, "IncreaseRank") ~= true then
                        entry.reason = "increase_rank_failed"
                        break
                    end
                    entry.increased = entry.increased + 1
                    summary.increasedCount = summary.increasedCount + 1
                    context.modifiedAllocators = context.modifiedAllocators or {}
                    context.modifiedAllocators[#context.modifiedAllocators + 1] = allocator
                end

                entry.finalRank = IsAllocatorPurchased(allocator) and GetAllocatorRank(allocator) or 0
                entry.ok = entry.finalRank >= targetRank
                if entry.ok ~= true then
                    entry.reason = entry.reason or "target_rank_not_reached"
                    summary.failedCount = summary.failedCount + 1
                    IncrementReason(summary, entry.reason)
                elseif entry.purchased ~= true and entry.increased == 0 then
                    summary.alreadySatisfiedCount = summary.alreadySatisfiedCount + 1
                    IncrementReason(summary, "already_satisfied")
                end
            end
        end
    end

    context.classMasteryPurchaseSummary = summary

    logging.Log(
        "Route B class mastery purchase end",
        "attempted=" .. tostring(summary.attemptedCount),
        "purchased=" .. tostring(summary.purchasedCount),
        "increased=" .. tostring(summary.increasedCount),
        "alreadySatisfied=" .. tostring(summary.alreadySatisfiedCount),
        "failed=" .. tostring(summary.failedCount),
        "reason=" .. tostring(plan.reason),
        "targetLine=" .. tostring(plan.targetSkillLineId),
        "reasonSummary=" .. logging.FormatReasonCounts(summary.reasonCounts)
    )

    if summary.failedCount > 0 then
        return false, "class_mastery_purchase_failed", summary
    end

    return true, nil, summary
end

function M:AuditCommittedTargets(context)
    local plan = self:ResolvePlan(context)
    local targets = type(plan) == "table" and type(plan.additions) == "table" and plan.additions or {}
    local summary = {
        attemptedCount = 0,
        matchedCount = 0,
        failedCount = 0,
        targets = {},
        ok = true,
    }

    for _, target in ipairs(targets) do
        summary.attemptedCount = summary.attemptedCount + 1
        local skillLineId = tonumber(target.skillLineId)
        local abilityId = tonumber(target.abilityId)
        local targetRank = tonumber(target.targetRank)
        skillLineId = skillLineId ~= nil and math.floor(skillLineId) or nil
        abilityId = abilityId ~= nil and math.floor(abilityId) or nil
        targetRank = targetRank ~= nil and math.floor(targetRank) or 0

        local entry = {
            skillLineId = skillLineId,
            abilityId = abilityId,
            targetRank = targetRank,
            committedRank = nil,
            ok = false,
            reason = nil,
        }
        summary.targets[#summary.targets + 1] = entry

        local skillLineData, lineErr = ClassMasteryLookup:ResolveLineData(skillLineId, true, true)
        if skillLineData == nil then
            entry.reason = lineErr or "skill_line_data_missing"
        else
            local skillData, skillErr = ClassMasteryLookup:FindPassiveByAbilityId(skillLineData, abilityId)
            if skillData == nil then
                entry.reason = skillErr or "skill_data_unavailable"
            else
                local committedRank, purchased = ClassMasteryLookup:GetCommittedRank(skillData)
                entry.committedRank = committedRank
                if purchased then
                    entry.ok = entry.committedRank >= targetRank
                    if entry.ok ~= true then
                        entry.reason = "target_rank_not_committed"
                    end
                else
                    entry.reason = "target_not_purchased_after_commit"
                end
            end
        end

        if entry.ok == true then
            summary.matchedCount = summary.matchedCount + 1
        else
            summary.failedCount = summary.failedCount + 1
            summary.ok = false
        end
    end

    logging.Log(
        "Route B class mastery purchase committed",
        "attempted=" .. tostring(summary.attemptedCount),
        "matched=" .. tostring(summary.matchedCount),
        "failed=" .. tostring(summary.failedCount),
        "ok=" .. tostring(summary.ok == true)
    )

    return summary
end
