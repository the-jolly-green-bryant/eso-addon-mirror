local Addon = LarvalTearMod
local Domains = Addon.Common.Domains
local Log = Addon.Common.Log
local LTM_CHAMPION_CHANGE = Addon.Modules.ChampionChange

local CHAMPION_FORCE_RESPEC_GRAPH_SEEDS = {
    warfare = { 11, 6, 99 },
    fitness = { 37, 38, 39 },
    craft = { 68, 74, 69 },
}
local CHAMPION_FORCE_RESPEC_GRAPH_INDEPENDENT = {
    warfare = { 3, 4, 5 },
    fitness = { 2, 34, 35 },
    craft = { 1, 65, 66, 279 },
}
local CHAMPION_PURCHASE_COOLDOWN_RESULT = 22
local CHAMPION_PURCHASE_SLOTTED_NOT_PURCHASED_RESULT = 20
local CHAMPION_FORCE_RESPEC_INSUFFICIENT_GOLD_REASON = "champion_force_respec_insufficient_gold"
local CHAMPION_FORCE_RESPEC_GRAPH_ALLOCATION_REASON = "champion_force_respec_graph_allocation"
local CHAMPION_FORCE_RESPEC_GRAPH_INDEPENDENT_REASON = "champion_force_respec_graph_independent"
local CHAMPION_FORCE_RESPEC_GRAPH_REFUND_REASON = "champion_force_respec_graph_refund"
local CHAMPION_FORCE_RESPEC_GRAPH_UNREACHABLE_REASON = "champion_force_respec_graph_unreachable"
local CHAMPION_TARGET_STAR_NOT_ACTIVE_REASON = "target_star_not_active"
local CHAMPION_SKILL_NOT_SLOTTABLE_REASON = "champion_skill_not_slottable"
local CHAMPION_SLOT_TARGET_HAS_ZERO_POINTS_REASON = "champion_slot_target_has_zero_points"
local CHAMPION_SLOT_TARGET_REFUNDED_REASON = "champion_slot_target_refunded"

local function CountMapEntries(entries)
    local count = 0
    for _ in pairs(entries or {}) do
        count = count + 1
    end
    return count
end

local function SortChampionIdList(entries)
    table.sort(entries, function(left, right)
        return left < right
    end)
end

local function GetChampionSkillLinkedIds(championSkillId)
    local linkedIds = {}
    if type(GetChampionSkillLinkIds) ~= "function"
        or type(championSkillId) ~= "number"
        or championSkillId <= 0 then
        return linkedIds
    end

    local ok, first, second, third, fourth, fifth, sixth, seventh, eighth =
        pcall(GetChampionSkillLinkIds, championSkillId)
    if not ok then
        return linkedIds
    end

    local rawIds = { first, second, third, fourth, fifth, sixth, seventh, eighth }
    local seen = {}
    for _, linkedId in ipairs(rawIds) do
        if type(linkedId) == "number" and linkedId > 0 and not seen[linkedId] then
            linkedIds[#linkedIds + 1] = linkedId
            seen[linkedId] = true
        end
    end

    return linkedIds
end

local function TraceChampionDebug(...)
    Log.LogDebugSummary(...)
end

local function GetCharacterGold()
    if type(GetCurrencyAmount) ~= "function" then
        return nil
    end

    local ok, amount = pcall(GetCurrencyAmount, CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
    if ok and type(amount) == "number" then
        return amount
    end

    return nil
end

local function GetChampionRespecCostSafe()
    if type(GetChampionRespecCost) ~= "function" then
        return nil
    end

    local ok, cost = pcall(GetChampionRespecCost)
    if ok and type(cost) == "number" then
        return cost
    end

    return nil
end

local function IsForceChampionRespecEnabled(options)
    return type(options) == "table" and options.forceChampionRespec == true
end

local function GetSavedChampionGroupSlottedIds(groupData)
    if type(groupData) ~= "table" then
        return {}
    end

    local source = type(groupData.slotted) == "table" and groupData.slotted or groupData
    local starIds = {}
    for _, championSkillId in ipairs(source) do
        if type(championSkillId) == "number" and championSkillId > 0 then
            starIds[#starIds + 1] = championSkillId
        end
    end
    return starIds
end

local function GetSavedChampionAllocatedMap(groupData)
    local allocated = {}
    if type(groupData) ~= "table" or type(groupData.allocated) ~= "table" then
        return allocated
    end

    for starId, spentPoints in pairs(groupData.allocated) do
        local numericStarId = tonumber(starId)
        if type(numericStarId) == "number" and numericStarId > 0 and type(spentPoints) == "number" and spentPoints > 0 then
            allocated[numericStarId] = math.floor(spentPoints)
        end
    end

    return allocated
end

local function NormalizeTargetChampionPoints(targetChampionPoints)
    if type(targetChampionPoints) ~= "table" then
        return nil, "champion_points_config_invalid"
    end

    local normalized = {
        groups = {},
        targetSlottedStars = 0,
        targetAllocatedStars = 0,
    }

    for _, group in ipairs(Domains.ChampionGroups) do
        local sourceGroup = targetChampionPoints[group.id]
        local slotted = GetSavedChampionGroupSlottedIds(sourceGroup)
        local allocated = GetSavedChampionAllocatedMap(sourceGroup)
        normalized.groups[group.id] = {
            id = group.id,
            slotted = slotted,
            allocated = allocated,
            hasAllocatedData = CountMapEntries(allocated) > 0,
        }
        normalized.targetSlottedStars = normalized.targetSlottedStars + #slotted
        normalized.targetAllocatedStars = normalized.targetAllocatedStars + CountMapEntries(allocated)
    end

    return normalized
end

local function GetCurrentChampionSpentPoints(championSkillId)
    if type(GetNumPointsSpentOnChampionSkill) ~= "function"
        or type(championSkillId) ~= "number"
        or championSkillId <= 0 then
        return 0
    end

    local ok, spentPoints = pcall(GetNumPointsSpentOnChampionSkill, championSkillId)
    if ok and type(spentPoints) == "number" and spentPoints >= 0 then
        return spentPoints
    end

    return 0
end

local function IsChampionSkillSlottable(championSkillId)
    if type(GetChampionSkillType) ~= "function" or type(CanChampionSkillTypeBeSlotted) ~= "function" then
        return false, "champion_slot_api_unavailable"
    end

    local typeOk, championSkillType = pcall(GetChampionSkillType, championSkillId)
    if not typeOk then
        return false, "champion_skill_type_failed"
    end

    local slotOk, canBeSlotted = pcall(CanChampionSkillTypeBeSlotted, championSkillType)
    if not slotOk then
        return false, "champion_slot_type_check_failed"
    end

    return canBeSlotted == true, canBeSlotted == true and nil or CHAMPION_SKILL_NOT_SLOTTABLE_REASON
end

local function WouldChampionSkillBePurchasedAtPoints(championSkillId, pendingPoints)
    if type(championSkillId) ~= "number" or championSkillId <= 0 then
        return false
    end

    pendingPoints = type(pendingPoints) == "number" and math.max(0, math.floor(pendingPoints)) or 0
    if type(WouldChampionSkillNodeBeUnlocked) == "function" then
        local ok, wouldBeUnlocked = pcall(WouldChampionSkillNodeBeUnlocked, championSkillId, pendingPoints)
        if ok then
            return wouldBeUnlocked == true
        end
    end

    return pendingPoints > 0
end

local function AppendSkippedReason(summary, reason)
    if type(summary) ~= "table" or type(reason) ~= "string" or reason == "" then
        return
    end

    summary.skippedReasons = summary.skippedReasons or {}
    summary.skippedReasonCounts = summary.skippedReasonCounts or {}
    if summary.skippedReasonCounts[reason] == nil then
        summary.skippedReasons[#summary.skippedReasons + 1] = reason
        summary.skippedReasonCounts[reason] = 0
    end
    summary.skippedReasonCounts[reason] = summary.skippedReasonCounts[reason] + 1
end

local function GetCurrentChampionAllocatedMapByGroup()
    local allocatedByGroup = {
        warfare = {},
        fitness = {},
        craft = {},
    }

    if type(GetNumChampionDisciplines) ~= "function"
        or type(GetChampionDisciplineId) ~= "function"
        or type(GetChampionDisciplineType) ~= "function"
        or type(GetNumChampionDisciplineSkills) ~= "function"
        or type(GetChampionSkillId) ~= "function" then
        return allocatedByGroup
    end

    for disciplineIndex = 1, GetNumChampionDisciplines() do
        local disciplineId = GetChampionDisciplineId(disciplineIndex)
        local disciplineType = type(disciplineId) == "number" and GetChampionDisciplineType(disciplineId) or nil
        local groupId = Domains.ChampionGroupByDisciplineType[disciplineType]
        local groupAllocated = type(groupId) == "string" and allocatedByGroup[groupId] or nil
        if type(groupAllocated) == "table" then
            for skillIndex = 1, GetNumChampionDisciplineSkills(disciplineIndex) do
                local starId = GetChampionSkillId(disciplineIndex, skillIndex)
                local spentPoints = GetCurrentChampionSpentPoints(starId)
                if type(starId) == "number" and starId > 0 and spentPoints > 0 then
                    groupAllocated[starId] = spentPoints
                end
            end
        end
    end

    return allocatedByGroup
end

local function RecordAllocatedMismatch(summary, groupId, championSkillId, currentPoints, targetPoints, reason)
    summary.skippedAllocationChanges = (summary.skippedAllocationChanges or 0) + 1
    summary.allocationResults = summary.allocationResults or {}
    summary.allocationResults[#summary.allocationResults + 1] = {
        groupId = groupId,
        championSkillId = championSkillId,
        status = "skipped",
        reason = reason,
        currentPoints = currentPoints,
        targetPoints = targetPoints,
    }
    AppendSkippedReason(summary, reason)
end

local function BuildTargetAllocatedLookup(normalizedTarget)
    local lookup = {}
    if type(normalizedTarget) ~= "table" or type(normalizedTarget.groups) ~= "table" then
        return lookup
    end

    for _, group in ipairs(Domains.ChampionGroups) do
        local targetGroup = normalizedTarget.groups[group.id]
        local allocated = type(targetGroup) == "table" and targetGroup.allocated or {}
        for championSkillId, targetPoints in pairs(allocated) do
            if type(championSkillId) == "number"
                and championSkillId > 0
                and type(targetPoints) == "number"
                and targetPoints > 0 then
                lookup[championSkillId] = {
                    groupId = group.id,
                    targetPoints = math.floor(targetPoints),
                }
            end
        end
    end

    return lookup
end

local function EvaluateAllocatedMismatches(normalizedTarget, plan)
    local summary = plan.summary
    local currentAllocatedByGroup = GetCurrentChampionAllocatedMapByGroup()

    for _, group in ipairs(Domains.ChampionGroups) do
        local targetGroup = normalizedTarget.groups[group.id]
        local targetAllocated = type(targetGroup) == "table" and targetGroup.allocated or {}
        local currentAllocated = currentAllocatedByGroup[group.id] or {}
        local visited = {}

        for starId, currentPoints in pairs(currentAllocated) do
            local targetPoints = targetAllocated[starId] or 0
            visited[starId] = true
            if currentPoints ~= targetPoints then
                local canBeSlotted = IsChampionSkillSlottable(starId)
                local reason = "champion_allocated_respec_unsupported"
                if targetPoints <= 0 and currentPoints > 0 and canBeSlotted ~= true then
                    reason = "champion_passive_deactivate_unsupported"
                elseif canBeSlotted ~= true then
                    reason = "champion_non_slottable_allocation_mismatch_skipped"
                end
                RecordAllocatedMismatch(summary, group.id, starId, currentPoints, targetPoints, reason)
            end
        end

        for starId, targetPoints in pairs(targetAllocated) do
            if not visited[starId] then
                local currentPoints = currentAllocated[starId] or 0
                if currentPoints ~= targetPoints then
                    local canBeSlotted = IsChampionSkillSlottable(starId)
                    local reason = canBeSlotted == true
                        and "champion_allocated_respec_unsupported"
                        or "champion_non_slottable_allocation_mismatch_skipped"
                    RecordAllocatedMismatch(summary, group.id, starId, currentPoints, targetPoints, reason)
                end
            end
        end
    end
end

local function GetChampionSkillNameSafe(championSkillId)
    if type(GetChampionSkillName) ~= "function" then
        return "unknown"
    end

    local ok, name = pcall(GetChampionSkillName, championSkillId)
    if ok and type(name) == "string" and name ~= "" then
        return name
    end

    return "unknown"
end

local function GetCurrentChampionAllocatedMap()
    local allocated = {}
    local allocatedByGroup = GetCurrentChampionAllocatedMapByGroup()
    for groupId, groupAllocated in pairs(allocatedByGroup or {}) do
        for championSkillId, currentPoints in pairs(groupAllocated or {}) do
            if type(championSkillId) == "number"
                and championSkillId > 0
                and type(currentPoints) == "number"
                and currentPoints > 0 then
                allocated[championSkillId] = {
                    groupId = groupId,
                    currentPoints = currentPoints,
                }
            end
        end
    end
    return allocated
end

local function RecordForceRespecGraphRequest(plan, entry, championSkillId, currentPoints, targetPoints, reason)
    if type(plan) ~= "table" or type(plan.summary) ~= "table" then
        return false
    end

    if type(championSkillId) ~= "number" or championSkillId <= 0 then
        return false
    end

    targetPoints = type(targetPoints) == "number" and math.max(0, math.floor(targetPoints)) or 0
    currentPoints = type(currentPoints) == "number" and math.max(0, math.floor(currentPoints)) or 0
    plan.requestedSkillPoints = plan.requestedSkillPoints or {}
    if plan.requestedSkillPoints[championSkillId] == targetPoints then
        return false
    end

    plan.requestedSkillPoints[championSkillId] = targetPoints

    local summary = plan.summary
    summary.requestedAllocationChanges = (summary.requestedAllocationChanges or 0) + 1
    summary.forceRespecPlannedChanges = (summary.forceRespecPlannedChanges or 0) + 1
    if targetPoints <= 0 then
        summary.forceRespecRefunds = (summary.forceRespecRefunds or 0) + 1
        summary.graphRefunds = (summary.graphRefunds or 0) + 1
    else
        summary.graphRequestedAllocations = (summary.graphRequestedAllocations or 0) + 1
        if reason == CHAMPION_FORCE_RESPEC_GRAPH_INDEPENDENT_REASON then
            summary.graphIndependentRequests = (summary.graphIndependentRequests or 0) + 1
        end
        if currentPoints <= 0 then
            summary.forceRespecPurchases = (summary.forceRespecPurchases or 0) + 1
        elseif currentPoints ~= targetPoints then
            summary.forceRespecUpdates = (summary.forceRespecUpdates or 0) + 1
        end
    end

    summary.allocationResults = summary.allocationResults or {}
    summary.allocationResults[#summary.allocationResults + 1] = {
        groupId = type(entry) == "table" and entry.groupId or nil,
        championSkillId = championSkillId,
        status = "request",
        reason = reason,
        currentPoints = currentPoints,
        targetPoints = targetPoints,
    }

    return true
end

local function GetSortedTargetAllocatedIdsByGroup(plan, groupId)
    local ids = {}
    for championSkillId, entry in pairs(type(plan) == "table" and plan.targetAllocatedByStar or {}) do
        if type(entry) == "table"
            and entry.groupId == groupId
            and type(entry.targetPoints) == "number"
            and entry.targetPoints > 0 then
            ids[#ids + 1] = championSkillId
        end
    end
    SortChampionIdList(ids)
    return ids
end

local function BuildIndependentLookup(groupId)
    local lookup = {}
    for _, championSkillId in ipairs(CHAMPION_FORCE_RESPEC_GRAPH_INDEPENDENT[groupId] or {}) do
        lookup[championSkillId] = true
    end
    return lookup
end

local function RegisterForceRespecGraphTarget(plan, championSkillId, reason)
    local entry = type(plan.targetAllocatedByStar) == "table" and plan.targetAllocatedByStar[championSkillId] or nil
    if type(entry) ~= "table" or type(entry.targetPoints) ~= "number" or entry.targetPoints <= 0 then
        return false
    end

    local currentPoints = GetCurrentChampionSpentPoints(championSkillId)
    return RecordForceRespecGraphRequest(
        plan,
        entry,
        championSkillId,
        currentPoints,
        entry.targetPoints,
        reason
    )
end

local function IsForceRespecGraphAdjacentToVisited(championSkillId, visited)
    if type(visited) ~= "table" then
        return false
    end

    local linkedIds = GetChampionSkillLinkedIds(championSkillId)
    for _, linkedId in ipairs(linkedIds) do
        if visited[linkedId] == true then
            return true
        end
    end

    return false
end

local function RecordForceRespecGraphUnreachable(plan, championSkillId, entry)
    local summary = plan.summary
    summary.graphUnreachableTargets = (summary.graphUnreachableTargets or 0) + 1
    summary.unresolvedStars = (summary.unresolvedStars or 0) + 1
    summary.failedGroups = (summary.failedGroups or 0) + 1
    summary.errorMessage = summary.errorMessage or CHAMPION_FORCE_RESPEC_GRAPH_UNREACHABLE_REASON

    summary.slotResults = summary.slotResults or {}
    summary.slotResults[#summary.slotResults + 1] = {
        groupId = type(entry) == "table" and entry.groupId or nil,
        championSkillId = championSkillId,
        status = "unresolved",
        reason = CHAMPION_FORCE_RESPEC_GRAPH_UNREACHABLE_REASON,
        targetPoints = type(entry) == "table" and entry.targetPoints or nil,
    }

    TraceChampionDebug(
        "Champion force respec graph unreachable target",
        "championSkillId=" .. tostring(championSkillId),
        "name=" .. GetChampionSkillNameSafe(championSkillId),
        "targetPoints=" .. tostring(type(entry) == "table" and entry.targetPoints or nil),
        "group=" .. tostring(type(entry) == "table" and entry.groupId or nil),
        "visitedCount=" .. tostring(summary.graphVisitedStars or 0),
        "registeredCount=" .. tostring(summary.graphRequestedAllocations or 0)
    )
end

local function CountForceRespecTargetAllocationDiffs(plan)
    local diffCount = 0
    for championSkillId, entry in pairs(type(plan) == "table" and plan.targetAllocatedByStar or {}) do
        local targetPoints = type(entry) == "table" and entry.targetPoints or nil
        if type(championSkillId) == "number"
            and championSkillId > 0
            and type(targetPoints) == "number"
            and targetPoints > 0 then
            local currentPoints = GetCurrentChampionSpentPoints(championSkillId)
            if currentPoints ~= targetPoints then
                diffCount = diffCount + 1
                TraceChampionDebug(
                    "Champion force respec allocation diff",
                    "championSkillId=" .. tostring(championSkillId),
                    "currentPoints=" .. tostring(currentPoints),
                    "targetPoints=" .. tostring(targetPoints)
                )
            end
        end
    end

    return diffCount
end

local function RecordSlotRequestRejected(plan, groupId, slotIndex, starId, targetPoints, reason, currentPoints)
    if type(plan) ~= "table" or type(plan.summary) ~= "table" then
        return
    end

    local summary = plan.summary
    summary.unresolvedStars = (summary.unresolvedStars or 0) + 1
    summary.failedGroups = (summary.failedGroups or 0) + 1
    summary.errorMessage = summary.errorMessage or reason
    summary.slotResults = summary.slotResults or {}
    summary.slotResults[#summary.slotResults + 1] = {
        groupId = groupId,
        slotIndex = slotIndex,
        championSkillId = starId,
        status = "unresolved",
        reason = reason,
        currentPoints = currentPoints,
        targetPoints = targetPoints,
    }

    TraceChampionDebug(
        "Champion slot request rejected",
        "slotIndex=" .. tostring(slotIndex),
        "starId=" .. tostring(starId),
        "targetPoints=" .. tostring(targetPoints),
        "reason=" .. tostring(reason)
    )
end

local function BuildForceRespecGraphAllocation(plan)
    if type(plan) ~= "table" or type(plan.summary) ~= "table" or type(plan.targetAllocatedByStar) ~= "table" then
        return false, "champion_force_respec_graph_plan_invalid"
    end

    plan.requestedSkillPoints = {}
    plan.forceRespecGraphRebuild = true

    local summary = plan.summary
    summary.requestedAllocationChanges = 0
    summary.forceRespecPlannedChanges = 0
    summary.forceRespecRefunds = 0
    summary.forceRespecPurchases = 0
    summary.forceRespecUpdates = 0
    summary.forceRespecSlotTargetsPurchasedInRequest = 0
    summary.forceRespecGraphRebuild = 1
    summary.graphRequestedAllocations = 0
    summary.graphRefunds = 0
    summary.graphIndependentRequests = 0
    summary.graphUnreachableTargets = 0
    summary.graphVisitedStars = 0
    summary.forceRespecPrerequisiteRepairResult = nil
    summary.forceRespecSlotOnlyEligible = false
    summary.forceRespecReason = "graph_rebuild"
    summary.forceRespecRefundScope = "active_not_in_target_graph"

    local visited = {}
    for _, group in ipairs(Domains.ChampionGroups) do
        local groupId = group.id
        local independentLookup = BuildIndependentLookup(groupId)
        local frontier = {}

        for _, seedId in ipairs(CHAMPION_FORCE_RESPEC_GRAPH_SEEDS[groupId] or {}) do
            if visited[seedId] ~= true then
                visited[seedId] = true
                frontier[#frontier + 1] = seedId
            end
            RegisterForceRespecGraphTarget(plan, seedId, CHAMPION_FORCE_RESPEC_GRAPH_ALLOCATION_REASON)
        end

        local index = 1
        while index <= #frontier do
            local championSkillId = frontier[index]
            index = index + 1
            local linkedIds = GetChampionSkillLinkedIds(championSkillId)
            SortChampionIdList(linkedIds)
            for _, linkedId in ipairs(linkedIds) do
                local linkedEntry = plan.targetAllocatedByStar[linkedId]
                if type(linkedEntry) == "table"
                    and linkedEntry.groupId == groupId
                    and type(linkedEntry.targetPoints) == "number"
                    and linkedEntry.targetPoints > 0
                    and independentLookup[linkedId] ~= true
                    and visited[linkedId] ~= true then
                    visited[linkedId] = true
                    RegisterForceRespecGraphTarget(
                        plan,
                        linkedId,
                        CHAMPION_FORCE_RESPEC_GRAPH_ALLOCATION_REASON
                    )
                    frontier[#frontier + 1] = linkedId
                end
            end

            local progress = true
            while progress do
                progress = false
                for _, targetChampionSkillId in ipairs(GetSortedTargetAllocatedIdsByGroup(plan, groupId)) do
                    if visited[targetChampionSkillId] ~= true
                        and independentLookup[targetChampionSkillId] ~= true
                        and IsForceRespecGraphAdjacentToVisited(targetChampionSkillId, visited) then
                        visited[targetChampionSkillId] = true
                        RegisterForceRespecGraphTarget(
                            plan,
                            targetChampionSkillId,
                            CHAMPION_FORCE_RESPEC_GRAPH_ALLOCATION_REASON
                        )
                        frontier[#frontier + 1] = targetChampionSkillId
                        progress = true
                    end
                end
            end
        end

        for _, championSkillId in ipairs(CHAMPION_FORCE_RESPEC_GRAPH_INDEPENDENT[groupId] or {}) do
            if RegisterForceRespecGraphTarget(
                plan,
                championSkillId,
                CHAMPION_FORCE_RESPEC_GRAPH_INDEPENDENT_REASON
            ) then
                visited[championSkillId] = true
            end
        end
    end

    summary.graphVisitedStars = CountMapEntries(visited)

    local ok = true
    for _, group in ipairs(Domains.ChampionGroups) do
        for _, championSkillId in ipairs(GetSortedTargetAllocatedIdsByGroup(plan, group.id)) do
            if plan.requestedSkillPoints[championSkillId] == nil then
                ok = false
                RecordForceRespecGraphUnreachable(plan, championSkillId, plan.targetAllocatedByStar[championSkillId])
            end
        end
    end

    if not ok then
        return false, CHAMPION_FORCE_RESPEC_GRAPH_UNREACHABLE_REASON
    end

    local currentAllocated = GetCurrentChampionAllocatedMap()
    local currentIds = {}
    for championSkillId in pairs(currentAllocated) do
        currentIds[#currentIds + 1] = championSkillId
    end
    SortChampionIdList(currentIds)
    for _, championSkillId in ipairs(currentIds) do
        if plan.requestedSkillPoints[championSkillId] == nil then
            local entry = currentAllocated[championSkillId]
            RecordForceRespecGraphRequest(
                plan,
                {
                    groupId = entry.groupId,
                },
                championSkillId,
                entry.currentPoints,
                0,
                CHAMPION_FORCE_RESPEC_GRAPH_REFUND_REASON
            )
        end
    end

    TraceChampionDebug(
        "Champion force respec graph rebuild summary",
        "graphRequestedAllocations=" .. tostring(summary.graphRequestedAllocations or 0),
        "graphRefunds=" .. tostring(summary.graphRefunds or 0),
        "graphIndependentRequests=" .. tostring(summary.graphIndependentRequests or 0),
        "graphUnreachableTargets=" .. tostring(summary.graphUnreachableTargets or 0),
        "graphVisitedStars=" .. tostring(summary.graphVisitedStars or 0),
        "skillRequests=" .. tostring(CountMapEntries(plan.requestedSkillPoints))
    )

    return true, nil
end

local function PlanForceRespecSlotRebuild(plan, targetSlotPurchaseRequests, currentSlottedEntries, targetSlottedSet)
    if type(plan) ~= "table" or type(plan.summary) ~= "table" then
        return false, "champion_force_respec_graph_plan_invalid"
    end

    local summary = plan.summary
    local targetSlotPurchaseRequestsCount = CountMapEntries(targetSlotPurchaseRequests)
    local allocationDiffCount = CountForceRespecTargetAllocationDiffs(plan)
    summary.forceRespecAllocationDiffCount = allocationDiffCount

    if targetSlotPurchaseRequestsCount <= 0 and allocationDiffCount <= 0 then
        summary.forceRespecSlotOnlyEligible = true
        summary.forceRespecReason = "none"
        TraceChampionDebug(
            "Champion force respec slot-only eligibility",
            "targetSlotPurchaseRequestsCount=" .. tostring(targetSlotPurchaseRequestsCount),
            "allocationDiffCount=" .. tostring(allocationDiffCount),
            "slotOnlyEligible=true"
        )
        return true, nil
    end

    TraceChampionDebug(
        "Champion force respec slot-only eligibility",
        "targetSlotPurchaseRequestsCount=" .. tostring(targetSlotPurchaseRequestsCount),
        "allocationDiffCount=" .. tostring(allocationDiffCount),
        "slotOnlyEligible=false"
    )
    return BuildForceRespecGraphAllocation(plan)
end

local function GetCurrentChampionSlottedStarId(slotIndex)
    if type(GetSlotBoundId) ~= "function" then
        return 0
    end

    local ok, championSkillId = pcall(GetSlotBoundId, slotIndex, HOTBAR_CATEGORY_CHAMPION)
    if ok and type(championSkillId) == "number" and championSkillId > 0 then
        return championSkillId
    end

    return 0
end

local function BuildChampionApplyPlan(normalizedTarget, options)
    local forceRespecEnabled = IsForceChampionRespecEnabled(options)
    local summary = {
        targetGroups = 0,
        targetSlottedStars = 0,
        targetAllocatedStars = 0,
        requestedSlotChanges = 0,
        requestedAllocationChanges = 0,
        unresolvedStars = 0,
        failedGroups = 0,
        skippedAllocationChanges = 0,
        purchaseExpectedResult = nil,
        skippedReasons = {},
        skippedReasonCounts = {},
        allocationResults = {},
        respecNeeded = false,
        forceRespecEnabled = forceRespecEnabled,
        forceRespecPlannedChanges = 0,
        forceRespecRefunds = 0,
        forceRespecPurchases = 0,
        forceRespecUpdates = 0,
        forceRespecSlotTargetsPurchasedInRequest = 0,
        forceRespecAllocationDiffCount = 0,
        forceRespecGraphRebuild = 0,
        graphRequestedAllocations = 0,
        graphRefunds = 0,
        graphIndependentRequests = 0,
        graphUnreachableTargets = 0,
        graphVisitedStars = 0,
        forceRespecPrerequisiteRepairResult = nil,
        forceRespecSlotOnlyEligible = forceRespecEnabled,
        forceRespecReason = "none",
        forceRespecRefundScope = "none",
        errorMessage = nil,
        slotResults = {},
    }
    local requestedHotbarSlots = {}
    local plan = {
        requestedHotbarSlots = requestedHotbarSlots,
        requestedSkillPoints = {},
        respecNeeded = false,
        forceRespecEnabled = forceRespecEnabled,
        summary = summary,
        target = normalizedTarget,
        targetAllocatedByStar = BuildTargetAllocatedLookup(normalizedTarget),
    }
    local targetSlotPurchaseRequests = {}
    local currentSlottedEntries = {}
    local targetSlottedSet = {}

    for _, group in ipairs(Domains.ChampionGroups) do
        local targetGroup = normalizedTarget.groups[group.id]
        summary.targetGroups = summary.targetGroups + 1
        summary.targetSlottedStars = summary.targetSlottedStars + #(targetGroup.slotted or {})
        summary.targetAllocatedStars = summary.targetAllocatedStars + CountMapEntries(targetGroup.allocated)

        for position, slotIndex in ipairs(group.slots or {}) do
            local targetStarId = targetGroup.slotted[position] or 0
            local currentStarId = GetCurrentChampionSlottedStarId(slotIndex)
            if currentStarId > 0 then
                currentSlottedEntries[#currentSlottedEntries + 1] = {
                    groupId = group.id,
                    slotIndex = slotIndex,
                    championSkillId = currentStarId,
                }
            end
            if targetStarId > 0 then
                targetSlottedSet[targetStarId] = true
                local targetAllocatedEntry = plan.targetAllocatedByStar[targetStarId]
                local targetAllocatedPoints = type(targetAllocatedEntry) == "table"
                    and type(targetAllocatedEntry.targetPoints) == "number"
                    and targetAllocatedEntry.targetPoints
                    or 0
                local currentPoints = GetCurrentChampionSpentPoints(targetStarId)
                local canBeSlotted, slotErr = IsChampionSkillSlottable(targetStarId)
                local isPurchased = currentPoints > 0
                if forceRespecEnabled then
                    isPurchased = WouldChampionSkillBePurchasedAtPoints(targetStarId, currentPoints)
                end
                local willPurchaseInRequest = forceRespecEnabled
                    and canBeSlotted == true
                    and targetAllocatedPoints > 0
                    and isPurchased ~= true
                if willPurchaseInRequest then
                    targetSlotPurchaseRequests[targetStarId] = {
                        groupId = group.id,
                        championSkillId = targetStarId,
                        currentPoints = currentPoints,
                        targetPoints = targetAllocatedPoints,
                    }
                end
                if forceRespecEnabled and targetAllocatedPoints <= 0 then
                    RecordSlotRequestRejected(
                        plan,
                        group.id,
                        slotIndex,
                        targetStarId,
                        targetAllocatedPoints,
                        CHAMPION_SLOT_TARGET_HAS_ZERO_POINTS_REASON,
                        currentPoints
                    )
                elseif isPurchased ~= true and not willPurchaseInRequest then
                    summary.unresolvedStars = summary.unresolvedStars + 1
                    summary.failedGroups = summary.failedGroups + 1
                    summary.errorMessage = summary.errorMessage or CHAMPION_TARGET_STAR_NOT_ACTIVE_REASON
                    summary.slotResults[#summary.slotResults + 1] = {
                        groupId = group.id,
                        slotIndex = slotIndex,
                        championSkillId = targetStarId,
                        status = "unresolved",
                        reason = CHAMPION_TARGET_STAR_NOT_ACTIVE_REASON,
                        currentPoints = currentPoints,
                    }
                elseif not canBeSlotted then
                    summary.unresolvedStars = summary.unresolvedStars + 1
                    summary.failedGroups = summary.failedGroups + 1
                    summary.errorMessage = summary.errorMessage or slotErr or CHAMPION_SKILL_NOT_SLOTTABLE_REASON
                    summary.slotResults[#summary.slotResults + 1] = {
                        groupId = group.id,
                        slotIndex = slotIndex,
                        championSkillId = targetStarId,
                        status = "unresolved",
                        reason = slotErr or CHAMPION_SKILL_NOT_SLOTTABLE_REASON,
                        currentPoints = currentPoints,
                    }
                elseif currentStarId ~= targetStarId then
                    requestedHotbarSlots[slotIndex] = targetStarId
                    summary.requestedSlotChanges = summary.requestedSlotChanges + 1
                    summary.slotResults[#summary.slotResults + 1] = {
                        groupId = group.id,
                        slotIndex = slotIndex,
                        championSkillId = targetStarId,
                        status = "slot",
                        currentPoints = currentPoints,
                        currentStarId = currentStarId,
                    }
                else
                    summary.slotResults[#summary.slotResults + 1] = {
                        groupId = group.id,
                        slotIndex = slotIndex,
                        championSkillId = targetStarId,
                        status = "slot_matched",
                        currentPoints = currentPoints,
                    }
                end
            elseif currentStarId ~= 0 then
                requestedHotbarSlots[slotIndex] = 0
                summary.requestedSlotChanges = summary.requestedSlotChanges + 1
                summary.slotResults[#summary.slotResults + 1] = {
                    groupId = group.id,
                    slotIndex = slotIndex,
                    status = "unslot",
                    currentStarId = currentStarId,
                }
            else
                summary.slotResults[#summary.slotResults + 1] = {
                    groupId = group.id,
                    slotIndex = slotIndex,
                    status = "empty_matched",
                }
            end
        end
    end

    plan.targetSlotPurchaseRequests = targetSlotPurchaseRequests
    plan.currentSlottedEntries = currentSlottedEntries
    plan.targetSlottedSet = targetSlottedSet
    if forceRespecEnabled then
        local graphOk, graphErr =
            PlanForceRespecSlotRebuild(plan, targetSlotPurchaseRequests, currentSlottedEntries, targetSlottedSet)
        if not graphOk then
            summary.errorMessage = summary.errorMessage or graphErr
        end
    else
        EvaluateAllocatedMismatches(normalizedTarget, plan)
    end
    summary.respecNeeded = CountMapEntries(plan.requestedSkillPoints) > 0
    plan.respecNeeded = summary.respecNeeded

    return plan
end

local function BuildDebugReasonSummary(summary)
    if type(summary) ~= "table" or type(summary.slotResults) ~= "table" then
        return nil
    end

    local reasonCounts = {}
    for _, result in ipairs(summary.slotResults) do
        if type(result) == "table" and type(result.reason) == "string" and result.reason ~= "" then
            reasonCounts[result.reason] = (reasonCounts[result.reason] or 0) + 1
        end
    end

    local parts = {}
    for reason, count in pairs(reasonCounts) do
        parts[#parts + 1] = string.format("%s=%d", reason, count)
    end

    table.sort(parts)
    return #parts > 0 and table.concat(parts, ",") or nil
end

local function BuildTargetSlottedDebugList(plan)
    local entries = {}
    if type(plan) ~= "table" or type(plan.target) ~= "table" or type(plan.target.groups) ~= "table" then
        return "none"
    end

    for _, group in ipairs(Domains.ChampionGroups) do
        local targetGroup = plan.target.groups[group.id]
        for position, championSkillId in ipairs(type(targetGroup) == "table" and targetGroup.slotted or {}) do
            if type(championSkillId) == "number" and championSkillId > 0 then
                entries[#entries + 1] = group.id .. ":" .. tostring(position) .. "=" .. tostring(championSkillId)
            end
        end
    end

    return #entries > 0 and table.concat(entries, ",") or "none"
end

local function BuildCurrentSlottedDebugList(plan)
    local entries = {}
    for _, entry in ipairs(type(plan) == "table" and plan.currentSlottedEntries or {}) do
        if type(entry) == "table" and type(entry.championSkillId) == "number" and entry.championSkillId > 0 then
            entries[#entries + 1] = tostring(entry.slotIndex) .. "=" .. tostring(entry.championSkillId)
        end
    end

    return #entries > 0 and table.concat(entries, ",") or "none"
end

local function BuildRequestedSkillDebugList(plan)
    local entries = {}
    for championSkillId, pendingPoints in pairs(type(plan) == "table" and plan.requestedSkillPoints or {}) do
        entries[#entries + 1] = tostring(championSkillId) .. "=" .. tostring(pendingPoints)
    end
    table.sort(entries)
    return #entries > 0 and table.concat(entries, ",") or "none"
end

local function BuildRequestedSlotDebugList(plan)
    local entries = {}
    for slotIndex, championSkillId in pairs(type(plan) == "table" and plan.requestedHotbarSlots or {}) do
        entries[#entries + 1] = tostring(slotIndex) .. "=" .. tostring(championSkillId)
    end
    table.sort(entries)
    return #entries > 0 and table.concat(entries, ",") or "none"
end

local function VerifyChampionApply(plan)
    if type(plan) ~= "table" or type(plan.target) ~= "table" then
        return false, "champion_verify_plan_invalid"
    end

    for _, group in ipairs(Domains.ChampionGroups) do
        local targetGroup = plan.target.groups[group.id]
        for position, slotIndex in ipairs(group.slots or {}) do
            local targetStarId = targetGroup.slotted[position] or 0
            if GetCurrentChampionSlottedStarId(slotIndex) ~= targetStarId then
                return false, "slot_binding_mismatch"
            end
        end
    end

    if plan.respecNeeded == true then
        for championSkillId, targetPoints in pairs(plan.requestedSkillPoints or {}) do
            if GetCurrentChampionSpentPoints(championSkillId) ~= targetPoints then
                return false, "slottable_spent_points_mismatch"
            end
        end
    end

    if plan.forceRespecEnabled == true then
        for championSkillId, entry in pairs(plan.targetAllocatedByStar or {}) do
            local targetPoints = type(entry) == "table" and entry.targetPoints or nil
            if type(championSkillId) == "number"
                and championSkillId > 0
                and type(targetPoints) == "number"
                and targetPoints > 0 then
                local currentPoints = GetCurrentChampionSpentPoints(championSkillId)
                if currentPoints ~= targetPoints then
                    TraceChampionDebug(
                        "Champion verify target allocation mismatch",
                        "championSkillId=" .. tostring(championSkillId),
                        "currentPoints=" .. tostring(currentPoints),
                        "targetPoints=" .. tostring(targetPoints)
                    )
                    return false, "target_spent_points_mismatch"
                end
            end
        end
    end

    return true
end

function LTM_CHAMPION_CHANGE:CreateApplyPlan(targetChampionPoints, options)
    local normalizedTarget, normalizeErr = NormalizeTargetChampionPoints(targetChampionPoints)
    if type(normalizedTarget) ~= "table" then
        return nil, normalizeErr, {
            targetGroups = 0,
            targetSlottedStars = 0,
            targetAllocatedStars = 0,
            requestedSlotChanges = 0,
            requestedAllocationChanges = 0,
            unresolvedStars = 0,
            failedGroups = 0,
            skippedAllocationChanges = 0,
            purchaseExpectedResult = nil,
            skippedReasons = {},
            skippedReasonCounts = {},
            allocationResults = {},
            slotResults = {},
            forceRespecAllocationDiffCount = 0,
        }
    end

    local plan = BuildChampionApplyPlan(normalizedTarget, type(options) == "table" and options or {})
    return plan, nil, plan.summary
end

function LTM_CHAMPION_CHANGE:HasPendingChanges(plan)
    if type(plan) ~= "table" or type(plan.summary) ~= "table" then
        return false
    end

    return (plan.summary.requestedSlotChanges or 0) > 0
        or (plan.summary.requestedAllocationChanges or 0) > 0
end

function LTM_CHAMPION_CHANGE:HasUnresolvedChanges(plan)
    return type(plan) == "table"
        and type(plan.summary) == "table"
        and ((plan.summary.unresolvedStars or 0) > 0 or (plan.summary.failedGroups or 0) > 0)
end

local function ValidateChampionPurchaseRequest(plan)
    if type(plan) ~= "table" then
        return false, "champion_plan_invalid"
    end

    for slotIndex, starId in pairs(plan.requestedHotbarSlots or {}) do
        if type(starId) == "number" and starId > 0 then
            local requestedPoints = type(plan.requestedSkillPoints) == "table"
                and plan.requestedSkillPoints[starId]
                or nil
            if requestedPoints == 0 then
                if type(plan.summary) == "table" then
                    plan.summary.errorMessage = plan.summary.errorMessage or CHAMPION_SLOT_TARGET_REFUNDED_REASON
                end
                TraceChampionDebug(
                    "Champion purchase request guard rejected",
                    "slotIndex=" .. tostring(slotIndex),
                    "starId=" .. tostring(starId),
                    "requestedSkillPoints=" .. tostring(requestedPoints),
                    "reason=" .. CHAMPION_SLOT_TARGET_REFUNDED_REASON
                )
                return false, CHAMPION_SLOT_TARGET_REFUNDED_REASON
            end
        end
    end

    return true, nil
end

local function BuildChampionPurchaseRequest(plan, label)
    PrepareChampionPurchaseRequest(plan.respecNeeded == true)
    local includeDetail = plan.purchaseRequestDetailLogged ~= true
    plan.purchaseRequestDetailLogged = true

    TraceChampionDebug(
        "Champion purchase request prepared",
        "label=" .. tostring(label or "initial"),
        "respecNeeded=" .. tostring(plan.respecNeeded == true),
        "forceRespecEnabled=" .. tostring(plan.forceRespecEnabled == true),
        "skillChanges=" .. tostring(CountMapEntries(plan.requestedSkillPoints)),
        "slotChanges=" .. tostring(CountMapEntries(plan.requestedHotbarSlots))
    )

    if plan.respecNeeded == true then
        for championSkillId, pendingPoints in pairs(plan.requestedSkillPoints or {}) do
            if includeDetail then
                TraceChampionDebug(
                    "Champion force respec skill request",
                    "label=" .. tostring(label or "initial"),
                    "championSkillId=" .. tostring(championSkillId),
                    "pendingPoints=" .. tostring(pendingPoints)
                )
            end
            AddSkillToChampionPurchaseRequest(championSkillId, pendingPoints)
        end
    end

    for slotIndex, championSkillId in pairs(plan.requestedHotbarSlots or {}) do
        if plan.requestedSkillPoints and plan.requestedSkillPoints[championSkillId] ~= nil then
            if includeDetail then
                TraceChampionDebug(
                    "Champion slot target included in skill request",
                    "label=" .. tostring(label or "initial"),
                    "slotIndex=" .. tostring(slotIndex),
                    "championSkillId=" .. tostring(championSkillId),
                    "pendingPoints=" .. tostring(plan.requestedSkillPoints[championSkillId])
                )
            end
        end
        if includeDetail then
            TraceChampionDebug(
                "Champion hotbar slot request",
                "label=" .. tostring(label or "initial"),
                "slotIndex=" .. tostring(slotIndex),
                "championSkillId=" .. tostring(championSkillId)
            )
        end
        AddHotbarSlotToChampionPurchaseRequest(slotIndex, championSkillId)
    end

    if type(GetExpectedResultForChampionPurchaseRequest) == "function" then
        local result = GetExpectedResultForChampionPurchaseRequest()
        plan.summary.purchaseExpectedResult = result
        TraceChampionDebug(
            "Champion purchase expected result",
            "label=" .. tostring(label or "initial"),
            "result=" .. tostring(result),
            "respecNeeded=" .. tostring(plan.respecNeeded == true),
            "forceRespecEnabled=" .. tostring(plan.forceRespecEnabled == true)
        )
        return result
    end

    return CHAMPION_PURCHASE_SUCCESS
end

local function ResolveChampionPurchaseRequestFailure(plan, result)
    if result == CHAMPION_PURCHASE_COOLDOWN_RESULT then
        return false, "champion_purchase_cooldown", plan.summary
    end

    if result == CHAMPION_PURCHASE_SLOTTED_NOT_PURCHASED_RESULT then
        AppendSkippedReason(plan.summary, "champion_slotted_not_purchased_skipped")
        return false, "champion_slotted_not_purchased_skipped", plan.summary
    end

    if plan.respecNeeded == true then
        AppendSkippedReason(plan.summary, "champion_force_respec_expected_result_failed")
    end
    return false, "champion_purchase_unavailable_" .. tostring(result), plan.summary
end

function LTM_CHAMPION_CHANGE:QueueChampionPurchaseRequest(plan)
    if type(plan) ~= "table" then
        return false, "champion_plan_invalid", nil
    end

    if type(PrepareChampionPurchaseRequest) ~= "function"
        or type(AddHotbarSlotToChampionPurchaseRequest) ~= "function"
        or type(SendChampionPurchaseRequest) ~= "function" then
        return false, "champion_purchase_api_unavailable", plan.summary
    end

    if plan.respecNeeded == true and type(AddSkillToChampionPurchaseRequest) ~= "function" then
        return false, "champion_force_respec_api_unavailable", plan.summary
    end

    if plan.forceRespecGraphRebuild == true
        and type(plan.summary) == "table"
        and (plan.summary.graphUnreachableTargets or 0) > 0 then
        TraceChampionDebug(
            "Champion force respec graph rebuild blocked before commit",
            "reason=" .. CHAMPION_FORCE_RESPEC_GRAPH_UNREACHABLE_REASON,
            "graphUnreachableTargets=" .. tostring(plan.summary.graphUnreachableTargets or 0),
            "graphVisitedStars=" .. tostring(plan.summary.graphVisitedStars or 0),
            "graphRequestedAllocations=" .. tostring(plan.summary.graphRequestedAllocations or 0)
        )
        return false, CHAMPION_FORCE_RESPEC_GRAPH_UNREACHABLE_REASON, plan.summary
    end

    local guardOk, guardErr = ValidateChampionPurchaseRequest(plan)
    if not guardOk then
        return false, guardErr, plan.summary
    end

    if plan.respecNeeded == true then
        local respecCost = GetChampionRespecCostSafe()
        local characterGold = GetCharacterGold()
        plan.summary.forceRespecCost = respecCost
        plan.summary.characterGold = characterGold
        TraceChampionDebug(
            "Champion force respec gold precheck",
            "gold=" .. tostring(characterGold),
            "cost=" .. tostring(respecCost)
        )
        if type(respecCost) == "number"
            and type(characterGold) == "number"
            and characterGold < respecCost then
            AppendSkippedReason(plan.summary, CHAMPION_FORCE_RESPEC_INSUFFICIENT_GOLD_REASON)
            return false, CHAMPION_FORCE_RESPEC_INSUFFICIENT_GOLD_REASON, plan.summary
        end
    end

    local result = BuildChampionPurchaseRequest(plan, "initial")
    if result == CHAMPION_PURCHASE_SUCCESS then
        plan.summary.forceRespecPrerequisiteRepairResult = result
        TraceChampionDebug("Champion purchase request final", "sent=true", "result=" .. tostring(result))
        return true, nil, plan.summary
    end

    if plan.forceRespecGraphRebuild == true then
        TraceChampionDebug(
            "Champion force respec graph rebuild request rejected",
            "result=" .. tostring(result),
            "repairFallback=false",
            "refundExclusionFallback=false"
        )
        return ResolveChampionPurchaseRequestFailure(plan, result)
    end

    return ResolveChampionPurchaseRequestFailure(plan, result)
end

function LTM_CHAMPION_CHANGE:VerifyAppliedPlan(plan)
    return VerifyChampionApply(plan)
end

function LTM_CHAMPION_CHANGE:GetPlanErrorMessage(plan)
    return type(plan) == "table"
        and type(plan.summary) == "table"
        and type(plan.summary.errorMessage) == "string"
        and plan.summary.errorMessage
        or nil
end

function LTM_CHAMPION_CHANGE:LogPlanDebug(plan)
    if type(plan) ~= "table" or type(plan.summary) ~= "table" then
        return
    end

    TraceChampionDebug(
        "Champion change summary",
        "targetGroups=" .. tostring(plan.summary.targetGroups or 0),
        "targetSlottedStars=" .. tostring(plan.summary.targetSlottedStars or 0),
        "targetAllocatedStars=" .. tostring(plan.summary.targetAllocatedStars or 0),
        "requestedSlotChanges=" .. tostring(plan.summary.requestedSlotChanges or 0),
        "requestedAllocationChanges=" .. tostring(plan.summary.requestedAllocationChanges or 0),
        "skippedAllocationChanges=" .. tostring(plan.summary.skippedAllocationChanges or 0),
        "purchaseExpectedResult=" .. tostring(plan.summary.purchaseExpectedResult),
        "respecNeeded=" .. tostring(plan.summary.respecNeeded == true),
        "forceRespecEnabled=" .. tostring(plan.summary.forceRespecEnabled == true),
        "forceRespecPlannedChanges=" .. tostring(plan.summary.forceRespecPlannedChanges or 0),
        "forceRespecRefunds=" .. tostring(plan.summary.forceRespecRefunds or 0),
        "forceRespecPurchases=" .. tostring(plan.summary.forceRespecPurchases or 0),
        "forceRespecUpdates=" .. tostring(plan.summary.forceRespecUpdates or 0),
        "forceRespecSlotTargetsPurchasedInRequest=" .. tostring(plan.summary.forceRespecSlotTargetsPurchasedInRequest or 0),
        "forceRespecAllocationDiffCount=" .. tostring(plan.summary.forceRespecAllocationDiffCount or 0),
        "forceRespecGraphRebuild=" .. tostring(plan.summary.forceRespecGraphRebuild or 0),
        "graphRequestedAllocations=" .. tostring(plan.summary.graphRequestedAllocations or 0),
        "graphRefunds=" .. tostring(plan.summary.graphRefunds or 0),
        "graphIndependentRequests=" .. tostring(plan.summary.graphIndependentRequests or 0),
        "graphUnreachableTargets=" .. tostring(plan.summary.graphUnreachableTargets or 0),
        "graphVisitedStars=" .. tostring(plan.summary.graphVisitedStars or 0),
        "forceRespecSlotOnlyEligible=" .. tostring(plan.summary.forceRespecSlotOnlyEligible == true),
        "forceRespecReason=" .. tostring(plan.summary.forceRespecReason or "none"),
        "forceRespecRefundScope=" .. tostring(plan.summary.forceRespecRefundScope or "none"),
        "unresolvedStars=" .. tostring(plan.summary.unresolvedStars or 0),
        "failedGroups=" .. tostring(plan.summary.failedGroups or 0)
    )

    TraceChampionDebug(
        "Champion force respec target/current slotted",
        "forceRespecEnabled=" .. tostring(plan.summary.forceRespecEnabled == true),
        "targetSlotted=" .. BuildTargetSlottedDebugList(plan),
        "currentSlotted=" .. BuildCurrentSlottedDebugList(plan)
    )

    TraceChampionDebug(
        "Champion force respec initial request",
        "skillRequests=" .. BuildRequestedSkillDebugList(plan),
        "slotRequests=" .. BuildRequestedSlotDebugList(plan)
    )
    local reasonSummary = BuildDebugReasonSummary(plan.summary)
    if type(reasonSummary) == "string" and reasonSummary ~= "" then
        TraceChampionDebug("Champion unresolved reasons", reasonSummary)
    end

    local skippedReasons = type(plan.summary.skippedReasons) == "table"
        and table.concat(plan.summary.skippedReasons, ",")
        or nil
    if type(skippedReasons) == "string" and skippedReasons ~= "" then
        TraceChampionDebug("Champion skipped reasons", skippedReasons)
    end
end
