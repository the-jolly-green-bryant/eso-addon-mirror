local Addon = LarvalTearMod
local M = Addon.Modules.SkillRespecClassMasteryReduce
local Util = Addon.Common.Util
local logging = Addon.Modules.SkillRespecLogging
local ClassMasteryLookup = Addon.Modules.ClassMasteryLookup

local function CreateSummary()
    return {
        attemptedCount = 0,
        reducedCount = 0,
        soldCount = 0,
        skippedCount = 0,
        failedCount = 0,
        reasonCounts = {},
        reductions = {},
    }
end

local function IncrementReason(summary, reason)
    reason = type(reason) == "string" and reason or "unknown"
    summary.reasonCounts[reason] = (summary.reasonCounts[reason] or 0) + 1
end

local function IsAllocatorPurchased(allocator, skillData)
    local purchased = Util:SafeCallMethod(allocator, "IsPurchased")
    if purchased ~= nil then
        return purchased == true
    end

    return Util:SafeCallMethod(skillData, "IsPurchased") == true
end

local function GetAllocatorRank(allocator, skillData)
    local rank = tonumber(Util:SafeCallMethod(allocator, "GetRank"))
    if rank ~= nil then
        return math.floor(rank)
    end

    rank = tonumber(Util:SafeCallMethod(skillData, "GetCurrentRank"))
    return rank ~= nil and math.floor(rank) or 0
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
        context.classMasteryReductionSummary = CreateSummary()
        return true, nil, context.classMasteryReductionSummary
    end

    local reductions = type(plan.reductions) == "table" and plan.reductions or {}
    local summary = CreateSummary()

    for _, reduction in ipairs(reductions) do
        summary.attemptedCount = summary.attemptedCount + 1
        local skillLineId = tonumber(reduction.skillLineId)
        local abilityId = tonumber(reduction.abilityId)
        local targetRank = tonumber(reduction.targetRank) or 0
        skillLineId = skillLineId ~= nil and math.floor(skillLineId) or nil
        abilityId = abilityId ~= nil and math.floor(abilityId) or nil
        targetRank = math.max(0, math.floor(targetRank))
        local entry = {
            skillLineId = skillLineId,
            abilityId = abilityId,
            startRank = reduction.currentRank,
            targetRank = targetRank,
            finalRank = nil,
            sold = false,
            reduced = 0,
            ok = false,
            reason = nil,
            pendingDeactivation = nil,
        }
        summary.reductions[#summary.reductions + 1] = entry

        local skillLineData, lineErr = ClassMasteryLookup:ResolveLineData(skillLineId, false, true)
        if type(skillLineData) == "table" and type(skillLineData.IsPendingDeactivation) == "function" then
            entry.pendingDeactivation = skillLineData:IsPendingDeactivation() == true
        end

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
                while IsAllocatorPurchased(allocator, skillData)
                    and GetAllocatorRank(allocator, skillData) > math.max(targetRank, 1) do
                    if Util:SafeCallMethod(allocator, "CanDecreaseRank") ~= true then
                        entry.reason = "cannot_decrease_rank"
                        break
                    end
                    if Util:SafeCallMethod(allocator, "DecreaseRank") ~= true then
                        entry.reason = "decrease_rank_failed"
                        break
                    end
                    entry.reduced = entry.reduced + 1
                    summary.reducedCount = summary.reducedCount + 1
                    context.modifiedAllocators = context.modifiedAllocators or {}
                    context.modifiedAllocators[#context.modifiedAllocators + 1] = allocator
                end

                if targetRank <= 0 and IsAllocatorPurchased(allocator, skillData) then
                    if Util:SafeCallMethod(allocator, "CanSell") ~= true then
                        entry.reason = entry.reason or "cannot_sell"
                    elseif Util:SafeCallMethod(allocator, "Sell") == true then
                        entry.sold = true
                        summary.soldCount = summary.soldCount + 1
                        context.modifiedAllocators = context.modifiedAllocators or {}
                        context.modifiedAllocators[#context.modifiedAllocators + 1] = allocator
                    else
                        entry.reason = "sell_failed"
                    end
                end

                local purchased = IsAllocatorPurchased(allocator, skillData)
                entry.finalRank = purchased and GetAllocatorRank(allocator, skillData) or 0
                entry.ok = entry.finalRank <= targetRank
                if entry.ok ~= true then
                    entry.reason = entry.reason or "target_rank_not_reached"
                    summary.failedCount = summary.failedCount + 1
                    IncrementReason(summary, entry.reason)
                elseif entry.reduced == 0 and entry.sold ~= true then
                    summary.skippedCount = summary.skippedCount + 1
                    IncrementReason(summary, "already_at_or_below_target")
                end
            end
        end
    end

    context.classMasteryReductionSummary = summary

    logging.Log(
        "Route B class mastery reduction end",
        "attempted=" .. tostring(summary.attemptedCount),
        "reduced=" .. tostring(summary.reducedCount),
        "sold=" .. tostring(summary.soldCount),
        "skipped=" .. tostring(summary.skippedCount),
        "failed=" .. tostring(summary.failedCount),
        "reason=" .. tostring(plan.reason),
        "currentLine=" .. tostring(plan.currentSkillLineId),
        "targetLine=" .. tostring(plan.targetSkillLineId),
        "reasonSummary=" .. logging.FormatReasonCounts(summary.reasonCounts)
    )

    if summary.failedCount > 0 then
        return false, "class_mastery_reduction_failed", summary
    end

    return true, nil, summary
end
