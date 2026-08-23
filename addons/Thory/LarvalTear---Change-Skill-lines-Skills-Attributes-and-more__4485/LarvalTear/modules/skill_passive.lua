local Addon = LarvalTearMod
local Log = Addon.Common.Log
local LTM_SKILL_PASSIVE = Addon.Modules.SkillPassive
local SHARED_UTIL = Addon.Common.Util

local PASSIVE_POLICY_NONE = "none"

local function NormalizeNonNegativeInteger(value)
    local number = tonumber(value)
    if number == nil or number < 0 or math.floor(number) ~= number then
        return nil
    end
    return number
end

local function GetSkillName(skillData)
    return SHARED_UTIL:SafeCallMethod(skillData, "GetName")
        or SHARED_UTIL:SafeCallMethod(skillData, "GetFormattedName")
        or SHARED_UTIL:SafeCallMethod(skillData, "GetRawName")
        or ""
end

local function GetAllocatorRank(allocator)
    return NormalizeNonNegativeInteger(SHARED_UTIL:SafeCallMethod(allocator, "GetRank"))
end

local function ResolvePassiveMaxRank(skillData)
    local rank = NormalizeNonNegativeInteger(SHARED_UTIL:SafeCallMethod(skillData, "GetMaxRank"))
    if rank ~= nil and rank > 0 then
        return rank
    end

    rank = NormalizeNonNegativeInteger(SHARED_UTIL:SafeCallMethod(skillData, "GetNumRanks"))
    if rank ~= nil and rank > 0 then
        return rank
    end

    local rankData = SHARED_UTIL:SafeCallMethod(skillData, "GetRankData")
    rank = NormalizeNonNegativeInteger(type(rankData) == "table" and rankData.maxRank or nil)
    if rank ~= nil and rank > 0 then
        return rank
    end

    return nil
end

local function ResolveReasonSummary(reasonCounts)
    if type(reasonCounts) ~= "table" then
        return "none"
    end

    local reasons = {}
    for reason in pairs(reasonCounts) do
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

local function IncrementReason(reasonCounts, reason)
    if type(reasonCounts) ~= "table" or type(reason) ~= "string" or reason == "" then
        return
    end

    reasonCounts[reason] = (reasonCounts[reason] or 0) + 1
end

local function ResolveSkillLineData(skillLineId)
    if type(SKILLS_DATA_MANAGER) ~= "table"
        or type(SKILLS_DATA_MANAGER.GetSkillLineDataById) ~= "function" then
        return nil, "skills_data_manager_unavailable"
    end

    local skillLineData = SKILLS_DATA_MANAGER:GetSkillLineDataById(skillLineId)
    if skillLineData == nil then
        return nil, "skill_line_data_missing"
    end

    if type(skillLineData.RefreshDynamicData) == "function" then
        skillLineData:RefreshDynamicData(true)
    end

    return skillLineData
end

local function ResolveTargetLine(input, skillLineId)
    local pendingLinesById = input and input.pendingActivatedSkillLinesById or nil
    if type(pendingLinesById) == "table" and type(pendingLinesById[skillLineId]) == "table" then
        local lineData = pendingLinesById[skillLineId]
        if type(lineData.RefreshDynamicData) == "function" then
            lineData:RefreshDynamicData(true)
        end
        return lineData, "pending_activated_line"
    end

    local skillLineData, err = ResolveSkillLineData(skillLineId)
    if skillLineData == nil then
        return nil, err
    end

    return skillLineData, "skills_data_manager"
end

local function BuildSummary(input)
    local explicitTargetLineIds = input and input.targetSkillLineIds or nil
    local fallbackTargetLineIds = input and input.newlyActivatedSkillLineIds or nil
    local targetLineIds = SHARED_UTIL:NormalizeLineIdList(explicitTargetLineIds or fallbackTargetLineIds)
    return {
        ok = true,
        policy = input.passiveRestore,
        targetLineCount = #targetLineIds,
        targetSkillLineIds = targetLineIds,
        targetPassiveCount = 0,
        restoredCount = 0,
        skippedCount = 0,
        warningCount = 0,
        reasonCounts = {},
    }
end

local function IterateLinePassives(skillLineData)
    local passives = {}
    if type(skillLineData) ~= "table" then
        return passives
    end

    local numSkills = type(skillLineData.GetNumSkills) == "function" and skillLineData:GetNumSkills() or 0
    if type(numSkills) ~= "number" or numSkills <= 0 then
        return passives
    end

    if type(skillLineData.GetSkillDataByIndex) ~= "function" then
        return passives
    end

    for skillIndex = 1, numSkills do
        local skillData = skillLineData:GetSkillDataByIndex(skillIndex)
        if type(skillData) == "table"
            and type(skillData.IsPassive) == "function"
            and skillData:IsPassive() then
            passives[#passives + 1] = skillData
        end
    end

    return passives
end

local function TryRestorePassiveSkill(skillData, summary)
    if type(skillData) ~= "table" then
        summary.skippedCount = summary.skippedCount + 1
        IncrementReason(summary.reasonCounts, "skill_data_missing")
        return
    end

    local allocator = type(skillData.GetPointAllocator) == "function" and skillData:GetPointAllocator() or nil
    if type(allocator) ~= "table" then
        summary.skippedCount = summary.skippedCount + 1
        IncrementReason(summary.reasonCounts, "allocator_unavailable")
        return
    end

    local changed = false
    local onAllocatorModified = type(summary) == "table" and summary.onAllocatorModified or nil
    local maxRank = ResolvePassiveMaxRank(skillData)
    local safetyLimit = math.max((maxRank or 10) + 2, 5)
    local step = 0

    while step < safetyLimit do
        if type(allocator.CanPurchase) == "function" and allocator:CanPurchase() then
            if allocator:Purchase() then
                summary.restoredCount = summary.restoredCount + 1
                changed = true
                if type(onAllocatorModified) == "function" then
                    onAllocatorModified(allocator)
                end
            else
                IncrementReason(summary.reasonCounts, "purchase_failed")
                break
            end
        elseif type(allocator.CanIncreaseRank) == "function" and allocator:CanIncreaseRank() then
            local allocatorRank = GetAllocatorRank(allocator)
            local ignoreCallbacks = maxRank ~= nil and allocatorRank ~= nil and allocatorRank + 1 < maxRank
            if allocator:IncreaseRank(ignoreCallbacks) then
                summary.restoredCount = summary.restoredCount + 1
                changed = true
                if type(onAllocatorModified) == "function" then
                    onAllocatorModified(allocator)
                end
            else
                IncrementReason(summary.reasonCounts, "increase_rank_failed")
                break
            end
        else
            break
        end
        step = step + 1
    end

    if step >= safetyLimit then
        IncrementReason(summary.reasonCounts, "safety_limit")
        Log.LogDebugSummary(
            "Skill passive safety limit",
            "skillName=" .. tostring(GetSkillName(skillData)),
            "finalAllocatorRank=" .. tostring(GetAllocatorRank(allocator)),
            "maxRank=" .. tostring(maxRank),
            "stepCount=" .. tostring(step)
        )
    end

    if changed then
        return
    end

    summary.skippedCount = summary.skippedCount + 1
    if type(skillData.IsPurchased) == "function" and skillData:IsPurchased() then
        IncrementReason(summary.reasonCounts, "already_purchased_or_maxed")
        return
    end

    if type(allocator.HasEnoughAvailableSkillPointsForSingleTransaction) == "function"
        and not allocator:HasEnoughAvailableSkillPointsForSingleTransaction() then
        IncrementReason(summary.reasonCounts, "insufficient_skill_points")
        return
    end

    if type(skillData.MeetsLinePurchaseRequirement) == "function"
        and not skillData:MeetsLinePurchaseRequirement() then
        IncrementReason(summary.reasonCounts, "line_requirement_unmet")
        return
    end

    IncrementReason(summary.reasonCounts, "not_restorable")
end

function LTM_SKILL_PASSIVE:LogSummary(summary)
    if type(summary) ~= "table" then
        return
    end

    local reasonSummary = ResolveReasonSummary(summary.reasonCounts)
    Log.LogDebugSummary(
        "Skill passive summary",
        "policy=" .. tostring(summary.policy),
        "targetSkillLineIds=" .. tostring(table.concat(summary.targetSkillLineIds or {}, ",")),
        "targetPassiveCount=" .. tostring(summary.targetPassiveCount or 0),
        "restoredCount=" .. tostring(summary.restoredCount or 0),
        "skippedCount=" .. tostring(summary.skippedCount or 0),
        "warnings=" .. tostring(summary.warningCount or 0),
        "reasons=" .. tostring(reasonSummary)
    )
end

function LTM_SKILL_PASSIVE:Run(input)
    local summary = BuildSummary(input)
    local policy = summary.policy
    summary.onAllocatorModified = input and input.onAllocatorModified or nil

    if policy == PASSIVE_POLICY_NONE then
        summary.skippedCount = summary.targetLineCount
        IncrementReason(summary.reasonCounts, "policy_none")
        summary.warningCount = 0
        Log.LogDebugSummary(
            "passive skipped due to policy",
            "policy=" .. tostring(policy),
            "targetLineCount=" .. tostring(summary.targetLineCount or 0)
        )
        self:LogSummary(summary)
        summary.onAllocatorModified = nil
        return summary
    end

    if summary.targetLineCount == 0 then
        IncrementReason(summary.reasonCounts, "no_target_lines")
        self:LogSummary(summary)
        summary.onAllocatorModified = nil
        return summary
    end

    for _, skillLineId in ipairs(summary.targetSkillLineIds) do
        local skillLineData, lineSource = ResolveTargetLine(input, skillLineId)
        if skillLineData == nil then
            IncrementReason(summary.reasonCounts, lineSource or "skill_line_unavailable")
        else
            local passives = IterateLinePassives(skillLineData)
            summary.targetPassiveCount = summary.targetPassiveCount + #passives
            if #passives == 0 then
                IncrementReason(summary.reasonCounts, "passive_candidates_unavailable")
            end
            for _, skillData in ipairs(passives) do
                TryRestorePassiveSkill(skillData, summary)
            end
        end
    end

    for reason, count in pairs(summary.reasonCounts) do
        if reason ~= "already_purchased_or_maxed"
            and reason ~= "policy_none"
            and reason ~= "no_target_lines"
            and reason ~= "passive_candidates_unavailable" then
            summary.warningCount = summary.warningCount + count
        end
    end

    self:LogSummary(summary)
    summary.onAllocatorModified = nil
    return summary
end
