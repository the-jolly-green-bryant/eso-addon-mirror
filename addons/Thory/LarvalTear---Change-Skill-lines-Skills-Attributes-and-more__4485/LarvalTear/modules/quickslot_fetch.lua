local Addon = LarvalTearMod
local QuickslotFetch = Addon.Modules.QuickslotFetch
local QuickslotInventory = Addon.Modules.QuickslotInventory
local QuickslotSnapshot = Addon.Modules.QuickslotSnapshot
local Util = Addon.Common.Util

local FETCH_POLL_INTERVAL_MS = 100
local FETCH_POLL_MAX_ATTEMPTS = 30
local FETCH_MODE_MISSING = "missing"
local FETCH_MODE_REFILL_MAX = "refill_max"
local SIEGE_REFILL_TARGET_COUNT = 20
local REFILL_TO_STACK_MAX_SPECIALIZED_ITEM_TYPES = {
    [400] = true, -- Trebuchet
    [401] = true, -- Ballista
    [402] = true, -- Ram
    [404] = true, -- Catapult
    [407] = true, -- Flaming Oil
}

local function IsSupportedFetchBag(bagId)
    if bagId == BAG_BANK or bagId == BAG_SUBSCRIBER_BANK then
        return true
    end

    if type(IsHouseBankBag) == "function" and IsHouseBankBag(bagId) then
        return true
    end

    return false
end

local function BuildSourceBagList(options)
    options = type(options) == "table" and options or {}

    if type(IsBankOpen) ~= "function" or IsBankOpen() ~= true then
        return nil, "fetch_source_closed", nil
    end

    local bankingBag = tonumber(options.sourceBankingBag)
    if bankingBag == nil then
        if type(GetBankingBag) ~= "function" then
            return nil, "fetch_source_unavailable", nil
        end

        bankingBag = GetBankingBag()
    end
    if type(bankingBag) ~= "number" or not IsSupportedFetchBag(bankingBag) then
        return nil, "fetch_source_invalid", bankingBag
    end

    local bagIds = {}
    local seen = {}

    local function AddBag(bagId)
        if type(bagId) ~= "number" or seen[bagId] == true then
            return
        end

        seen[bagId] = true
        bagIds[#bagIds + 1] = bagId
    end

    AddBag(bankingBag)

    if bankingBag == BAG_BANK or bankingBag == BAG_SUBSCRIBER_BANK then
        AddBag(BAG_BANK)
        if type(IsESOPlusSubscriber) == "function" and IsESOPlusSubscriber() == true then
            AddBag(BAG_SUBSCRIBER_BANK)
        end
    end

    return bagIds, nil, bankingBag
end

local function BuildItemKey(entry)
    if type(entry) ~= "table" then
        return nil
    end

    if type(entry.itemId) == "number" and entry.itemId > 0 then
        return "id:" .. tostring(entry.itemId)
    end

    if type(entry.itemLink) == "string" and entry.itemLink ~= "" then
        return "link:" .. entry.itemLink
    end

    return nil
end

local function NormalizeFetchMode(mode)
    if mode == FETCH_MODE_REFILL_MAX then
        return FETCH_MODE_REFILL_MAX
    end

    return FETCH_MODE_MISSING
end

local function ItemMatchesEntry(itemState, entry)
    return QuickslotInventory:EntryCountsTowardItemState(entry, itemState)
end

local function BuildBagItemState(bagId, slotIndex)
    return QuickslotInventory:BuildBagItemState(bagId, slotIndex, {
        includeCondition = true,
        includeMaxStackSize = true,
        includeProxyTailA = true,
    })
end

local function BuildInventoryIndex(bagIds)
    return QuickslotInventory:BuildBagIndex(bagIds, {
        includeCondition = true,
        includeMaxStackSize = true,
        includeProxyTailA = true,
    })
end

local function BuildRunInventoryIndex(sourceBagIds)
    local bagIds = { BAG_BACKPACK }
    local seen = {
        [BAG_BACKPACK] = true,
    }

    for _, bagId in ipairs(type(sourceBagIds) == "table" and sourceBagIds or {}) do
        if type(bagId) == "number" and seen[bagId] ~= true then
            seen[bagId] = true
            bagIds[#bagIds + 1] = bagId
        end
    end

    return BuildInventoryIndex(bagIds)
end

local function IsBetterSourceCandidate(candidate, bestCandidate, preferLowCondition)
    if type(candidate) ~= "table" then
        return false
    end

    if type(bestCandidate) ~= "table" then
        return true
    end

    if preferLowCondition == true then
        local candidateCondition = candidate.condition
        local bestCondition = bestCandidate.condition
        local candidateHasCondition = type(candidateCondition) == "number"
        local bestHasCondition = type(bestCondition) == "number"

        if candidateHasCondition and bestHasCondition and candidateCondition ~= bestCondition then
            return candidateCondition < bestCondition
        end

        if candidateHasCondition ~= bestHasCondition then
            return candidateHasCondition
        end

        local candidateProxy = tonumber(candidate.proxyTailA) or 0
        local bestProxy = tonumber(bestCandidate.proxyTailA) or 0
        if candidateProxy ~= bestProxy then
            return candidateProxy > bestProxy
        end
    end

    if (candidate.stackCount or 0) ~= (bestCandidate.stackCount or 0) then
        return (candidate.stackCount or 0) > (bestCandidate.stackCount or 0)
    end

    if candidate.bagId ~= bestCandidate.bagId then
        return (candidate.bagId or 0) < (bestCandidate.bagId or 0)
    end

    return (candidate.slotIndex or -1) > (bestCandidate.slotIndex or -1)
end

local function GetSpecializedItemTypeFromLink(itemLink)
    if type(itemLink) ~= "string" or itemLink == "" then
        return nil
    end

    local specializedItemType = nil
    if type(GetItemLinkSpecializedItemType) == "function" then
        specializedItemType = Util:SafeCall(GetItemLinkSpecializedItemType, itemLink)
    elseif type(GetItemLinkItemType) == "function" then
        specializedItemType = select(2, Util:SafeCall(GetItemLinkItemType, itemLink))
    end

    specializedItemType = tonumber(specializedItemType)
    if specializedItemType ~= nil and specializedItemType > 0 then
        return specializedItemType
    end

    return nil
end

local function UsesRefillToStackMaxPolicy(entry, sourceSummary)
    local itemLink = type(entry) == "table" and entry.itemLink or nil
    if type(itemLink) ~= "string" or itemLink == "" then
        itemLink = type(sourceSummary) == "table"
            and type(sourceSummary.bestCandidate) == "table"
            and sourceSummary.bestCandidate.itemLink
            or nil
    end

    local specializedItemType = GetSpecializedItemTypeFromLink(itemLink)
    return specializedItemType ~= nil
        and REFILL_TO_STACK_MAX_SPECIALIZED_ITEM_TYPES[specializedItemType] == true
end

local function GetRefillTargetCount(entry, backpackSummary, sourceSummary)
    if UsesRefillToStackMaxPolicy(entry, sourceSummary) == true then
        return SIEGE_REFILL_TARGET_COUNT
    end

    return math.max(
        tonumber(backpackSummary and backpackSummary.maxStackSize) or 0,
        tonumber(sourceSummary and sourceSummary.maxStackSize) or 0,
        1
    )
end

local function ResolveMaxStack(backpackSummary, sourceSummary)
    local backpackMaxStack = tonumber(backpackSummary and backpackSummary.maxStackSize)
    if backpackMaxStack ~= nil and backpackMaxStack > 1 then
        return backpackMaxStack
    end

    local sourceMaxStack = tonumber(sourceSummary and sourceSummary.maxStackSize)
    if sourceMaxStack ~= nil and sourceMaxStack > 1 then
        return sourceMaxStack
    end

    return nil
end

local function BuildItemRequirementMap(profile)
    local requirements = {}
    local orderedKeys = {}
    local targetSlots = 0

    local slots = type(profile) == "table" and type(profile.slots) == "table" and profile.slots or {}
    local slotCount = tonumber(type(profile) == "table" and profile.slotCount or nil) or #slots

    for slotIndex = 1, slotCount do
        local entry = slots[slotIndex]
        if QuickslotSnapshot:IsItemEntry(entry) then
            targetSlots = targetSlots + 1
            local itemKey = BuildItemKey(entry)
            if type(itemKey) == "string" then
                local requirement = requirements[itemKey]
                if requirement == nil then
                    requirement = {
                        key = itemKey,
                        entry = entry,
                        requiredSlots = 0,
                    }
                    requirements[itemKey] = requirement
                    orderedKeys[#orderedKeys + 1] = itemKey
                end
                requirement.requiredSlots = requirement.requiredSlots + 1
            end
        end
    end

    return requirements, orderedKeys, targetSlots
end

local function BuildEmptyBagSummary()
    return {
        slotCount = 0,
        totalCount = 0,
        maxStackSize = nil,
        bestCandidate = nil,
    }
end

local function AddItemStateToSummary(summary, itemState, preferLowCondition)
    summary.slotCount = summary.slotCount + 1
    summary.totalCount = summary.totalCount + math.max(tonumber(itemState.stackCount) or 0, 0)

    local maxStackSize = tonumber(itemState.maxStackSize)
    if maxStackSize ~= nil and maxStackSize > 0 then
        summary.maxStackSize = math.max(summary.maxStackSize or 0, maxStackSize)
    end

    if IsBetterSourceCandidate(itemState, summary.bestCandidate, preferLowCondition == true) then
        summary.bestCandidate = itemState
    end
end

local function SummarizeBagMatches(entry, bagIds, preferLowCondition)
    local summary = BuildEmptyBagSummary()

    if type(entry) ~= "table" or type(bagIds) ~= "table" then
        return summary
    end

    for _, bagId in ipairs(bagIds) do
        QuickslotInventory:IterateBagSlots(bagId, function(slotIndex)
            local itemState = BuildBagItemState(bagId, slotIndex)
            if not ItemMatchesEntry(itemState, entry) then
                return
            end

            AddItemStateToSummary(summary, itemState, preferLowCondition)
        end)
    end

    return summary
end

local function SummarizeIndexedBagMatches(entry, inventoryIndex, bagIds, preferLowCondition)
    local summary = BuildEmptyBagSummary()
    if type(entry) ~= "table" or type(inventoryIndex) ~= "table" or type(bagIds) ~= "table" then
        return summary
    end

    local includedBagIds = {}
    for _, bagId in ipairs(bagIds) do
        includedBagIds[bagId] = true
    end

    local itemStates = QuickslotInventory:GetIndexedCountingItemStates(entry, inventoryIndex)
    for _, itemState in ipairs(itemStates) do
        if includedBagIds[itemState.bagId] == true and ItemMatchesEntry(itemState, entry) then
            AddItemStateToSummary(summary, itemState, preferLowCondition)
        end
    end

    return summary
end

local function IsRequirementStackable(requirement, currentSummary, sourceSummary)
    if type(requirement) ~= "table" then
        return false
    end

    local currentMaxStack = tonumber(currentSummary and currentSummary.maxStackSize) or 0
    local sourceMaxStack = tonumber(sourceSummary and sourceSummary.maxStackSize) or 0
    if currentMaxStack > 1 or sourceMaxStack > 1 then
        return true
    end

    return false
end

local function BuildFetchPlanItems(requirement, sourceBagIds, options, inventoryIndex)
    options = type(options) == "table" and options or {}

    local mode = NormalizeFetchMode(options.mode)
    local backpackSummary = nil
    local sourceSummary = nil
    if type(inventoryIndex) == "table" then
        backpackSummary = SummarizeIndexedBagMatches(requirement.entry, inventoryIndex, { BAG_BACKPACK }, false)
        sourceSummary = SummarizeIndexedBagMatches(
            requirement.entry,
            inventoryIndex,
            sourceBagIds,
            options.preferLowCondition == true
        )
    else
        backpackSummary = SummarizeBagMatches(requirement.entry, { BAG_BACKPACK }, false)
        sourceSummary = SummarizeBagMatches(requirement.entry, sourceBagIds, options.preferLowCondition == true)
    end
    local isStackable = IsRequirementStackable(requirement, backpackSummary, sourceSummary)
    local currentCount = 0
    local targetCount = requirement.requiredSlots
    local neededCount = 0
    local isRefillTarget = false
    local usesRefillToStackMax = UsesRefillToStackMaxPolicy(requirement.entry, sourceSummary)

    if mode == FETCH_MODE_REFILL_MAX then
        currentCount = math.max(0, tonumber(backpackSummary.totalCount) or 0)
        targetCount = ResolveMaxStack(backpackSummary, sourceSummary) or 0
        isStackable = targetCount > 1
        isRefillTarget = isStackable
        neededCount = isStackable and math.max(0, targetCount - currentCount) or 0
        usesRefillToStackMax = false
    elseif usesRefillToStackMax then
        isStackable = true
        currentCount = math.max(0, tonumber(backpackSummary.totalCount) or 0)
        if currentCount > 0 then
            targetCount = currentCount
            neededCount = 0
        else
            targetCount = GetRefillTargetCount(requirement.entry, backpackSummary, sourceSummary)
            neededCount = math.max(0, targetCount - currentCount)
        end
    elseif isStackable then
        currentCount = math.max(0, tonumber(backpackSummary.totalCount) or 0)
        targetCount = requirement.requiredSlots
        neededCount = currentCount > 0 and 0 or 1
    else
        targetCount = requirement.requiredSlots
        currentCount = math.min(requirement.requiredSlots, tonumber(backpackSummary.slotCount) or 0)
        neededCount = math.max(0, targetCount - currentCount)
    end

    local availableCount = 0
    if isStackable then
        availableCount = (tonumber(sourceSummary.totalCount) or 0) > 0 and 1 or 0
    else
        availableCount = tonumber(sourceSummary.slotCount) or 0
    end

    local fetchableCount = math.min(neededCount, availableCount)

    return {
        isStackable = isStackable,
        isRefillTarget = isRefillTarget,
        usesRefillToStackMax = usesRefillToStackMax,
        currentCount = currentCount,
        targetCount = targetCount,
        neededCount = neededCount,
        availableCount = availableCount,
        fetchableCount = fetchableCount,
        backpackSummary = backpackSummary,
        sourceSummary = sourceSummary,
    }
end

local function FindBestSourceCandidate(entry, sourceBagIds, options, inventoryIndex)
    if type(entry) ~= "table" or type(sourceBagIds) ~= "table" or type(inventoryIndex) ~= "table" then
        return nil
    end

    options = type(options) == "table" and options or {}
    local preferLowCondition = options.preferLowCondition == true
    return SummarizeIndexedBagMatches(
        entry,
        inventoryIndex,
        sourceBagIds,
        preferLowCondition
    ).bestCandidate
end

local function FindFirstBackpackEmptySlot()
    if type(FindFirstEmptySlotInBag) == "function" then
        local slotIndex = FindFirstEmptySlotInBag(BAG_BACKPACK)
        if type(slotIndex) == "number" then
            return slotIndex
        end
    end

    if type(GetBagSize) ~= "function" or type(GetItemId) ~= "function" then
        return nil
    end

    local bagSize = GetBagSize(BAG_BACKPACK)
    for slotIndex = 0, bagSize - 1 do
        if GetItemId(BAG_BACKPACK, slotIndex) == 0 then
            return slotIndex
        end
    end

    return nil
end

local function DidMoveArrive(candidate, destSlot)
    if type(candidate) ~= "table" or type(destSlot) ~= "number" or type(GetItemLink) ~= "function" then
        return false
    end

    local itemLink = GetItemLink(BAG_BACKPACK, destSlot, LINK_STYLE_DEFAULT)
    if type(itemLink) ~= "string" or itemLink == "" then
        return false
    end

    if type(candidate.itemLink) == "string" and candidate.itemLink ~= "" then
        return itemLink == candidate.itemLink
    end

    local itemId = type(GetItemId) == "function" and Util:SafeCall(GetItemId, BAG_BACKPACK, destSlot) or nil
    return type(candidate.itemId) == "number"
        and candidate.itemId > 0
        and itemId == candidate.itemId
end

local function BuildUpdateName(moveIndex)
    local timeSeed = 0
    if type(GetFrameTimeMilliseconds) == "function" then
        timeSeed = GetFrameTimeMilliseconds() or 0
    elseif type(GetTimeStamp) == "function" then
        timeSeed = GetTimeStamp() or 0
    end

    return "LTM_QuickSlotFetchMove" .. tostring(timeSeed) .. "_" .. tostring(moveIndex or 0)
end

local function BuildFetchPlan(profile, options)
    if type(profile) ~= "table" then
        return false, "quickslot_profile_invalid", nil
    end

    options = type(options) == "table" and options or {}
    options.mode = NormalizeFetchMode(options.mode)

    local sourceBagIds, sourceErr, bankingBag = BuildSourceBagList(options)
    if type(sourceBagIds) ~= "table" then
        return false, sourceErr or "fetch_source_unavailable", {
            sourceBagIds = {},
            bankingBag = bankingBag,
            targetSlots = 0,
            missingSlots = 0,
            queuedItems = 0,
            unavailableItems = 0,
            fetchedItems = 0,
        }
    end

    local requirements, orderedKeys, targetSlots = BuildItemRequirementMap(profile)
    local inventoryIndex = BuildRunInventoryIndex(sourceBagIds)
    local plan = {
        sourceBagIds = sourceBagIds,
        bankingBag = bankingBag,
        items = {},
        targetSlots = targetSlots,
        mode = options.mode,
        refillTargets = 0,
        missingSlots = 0,
        queuedItems = 0,
        unavailableItems = 0,
        fetchedItems = 0,
    }
    for _, itemKey in ipairs(orderedKeys) do
        local requirement = requirements[itemKey]
        local requirementPlan = BuildFetchPlanItems(requirement, sourceBagIds, options, inventoryIndex)
        local neededCount = requirementPlan.neededCount
        local availableCount = requirementPlan.availableCount
        local candidate = requirementPlan.sourceSummary.bestCandidate
        local missingCount = math.max(0, neededCount - availableCount)

        if requirementPlan.isRefillTarget == true then
            plan.refillTargets = plan.refillTargets + 1
        end
        plan.missingSlots = plan.missingSlots + neededCount

        local queuedCount = 0
        if requirementPlan.isStackable == true then
            queuedCount = requirementPlan.fetchableCount > 0 and 1 or 0
        else
            queuedCount = math.max(0, tonumber(requirementPlan.fetchableCount) or 0)
        end
        local unavailableCount = missingCount

        for _ = 1, queuedCount do
            plan.queuedItems = plan.queuedItems + 1
            plan.items[#plan.items + 1] = {
                key = itemKey,
                entry = requirement.entry,
                mode = options.mode,
                isStackable = requirementPlan.isStackable,
                isRefillTarget = requirementPlan.isRefillTarget,
                usesRefillToStackMax = requirementPlan.usesRefillToStackMax,
                targetCount = requirementPlan.targetCount,
                itemId = requirement.entry.itemId or (candidate and candidate.itemId) or nil,
                itemLink = requirement.entry.itemLink or (candidate and candidate.itemLink) or nil,
                estimatedStackCount = candidate and candidate.stackCount or nil,
                estimatedCondition = candidate and candidate.condition or nil,
                estimatedProxyTailA = candidate and candidate.proxyTailA or nil,
            }
        end

        plan.unavailableItems = plan.unavailableItems + unavailableCount
    end

    table.sort(plan.items, function(left, right)
        if options.preferLowCondition == true then
            local leftProxy = tonumber(left.estimatedProxyTailA) or 0
            local rightProxy = tonumber(right.estimatedProxyTailA) or 0
            if leftProxy ~= rightProxy then
                return leftProxy > rightProxy
            end
        end

        if (left.estimatedCondition or 101) ~= (right.estimatedCondition or 101) and options.preferLowCondition == true then
            return (left.estimatedCondition or 101) < (right.estimatedCondition or 101)
        end

        if (left.estimatedStackCount or 0) ~= (right.estimatedStackCount or 0) then
            return (left.estimatedStackCount or 0) > (right.estimatedStackCount or 0)
        end

        if (left.itemId or 0) ~= (right.itemId or 0) then
            return (left.itemId or 0) < (right.itemId or 0)
        end

        return tostring(left.key or "") < tostring(right.key or "")
    end)

    return true, nil, plan
end

local function ExecuteMove(candidate, destSlot, quantity)
    if type(CallSecureProtected) ~= "function" then
        return false, "move_secure_unavailable"
    end

    quantity = tonumber(quantity) or tonumber(candidate and candidate.stackCount) or 0
    if quantity <= 0 then
        return false, "fetch_stack_missing"
    end

    local ok, err = pcall(CallSecureProtected, "RequestMoveItem", candidate.bagId, candidate.slotIndex, BAG_BACKPACK, destSlot, quantity)
    if not ok then
        return false, err or "request_move_item_failed"
    end

    return true
end

local function MoveQuantityNeedsBackpack(planEntry)
    return type(planEntry) == "table"
        and planEntry.isStackable == true
        and (planEntry.mode == FETCH_MODE_REFILL_MAX or planEntry.usesRefillToStackMax == true)
end

local function BuildMoveInventoryIndex(planEntry, sourceBagIds)
    local bagIds = {}
    local seen = {}
    for _, bagId in ipairs(type(sourceBagIds) == "table" and sourceBagIds or {}) do
        if type(bagId) == "number" and seen[bagId] ~= true then
            seen[bagId] = true
            bagIds[#bagIds + 1] = bagId
        end
    end

    if MoveQuantityNeedsBackpack(planEntry) and seen[BAG_BACKPACK] ~= true then
        bagIds[#bagIds + 1] = BAG_BACKPACK
    end

    return BuildInventoryIndex(bagIds)
end

local function BuildMoveQuantity(candidate, planEntry, sourceBagIds, options, inventoryIndex)
    if type(candidate) ~= "table" or type(planEntry) ~= "table" then
        return 0
    end

    local availableStack = math.max(0, tonumber(candidate.stackCount) or 0)
    if availableStack <= 0 then
        return 0
    end

    if planEntry.isStackable ~= true then
        return math.min(1, availableStack)
    end

    if planEntry.mode == FETCH_MODE_REFILL_MAX then
        local requirementPlan = BuildFetchPlanItems({
            entry = planEntry.entry,
            requiredSlots = 1,
        }, sourceBagIds, options, inventoryIndex)
        local remainingNeeded = math.max(0, tonumber(planEntry.targetCount) or 0)
        remainingNeeded = math.max(0, remainingNeeded - (tonumber(requirementPlan.currentCount) or 0))
        if remainingNeeded <= 0 then
            return 0
        end

        return math.min(availableStack, remainingNeeded)
    end

    if planEntry.usesRefillToStackMax ~= true then
        return availableStack
    end

    local requirementPlan = BuildFetchPlanItems({
        entry = planEntry.entry,
        requiredSlots = 1,
    }, sourceBagIds, options, inventoryIndex)
    local remainingNeeded = math.max(0, tonumber(planEntry.targetCount) or 0)
    remainingNeeded = math.max(0, remainingNeeded - (tonumber(requirementPlan.currentCount) or 0))
    if remainingNeeded <= 0 then
        return 0
    end

    return math.min(availableStack, remainingNeeded)
end

function QuickslotFetch:IsFetchContextAvailable()
    local bagIds = select(1, BuildSourceBagList())
    return type(bagIds) == "table" and #bagIds > 0
end

function QuickslotFetch:IsBusy()
    return self.pendingFetchContext ~= nil
end

local function BuildFetchCompletionReason(plan)
    if type(plan) == "table" and plan.mode == FETCH_MODE_REFILL_MAX then
        local fetchedItems = tonumber(plan.fetchedItems) or 0
        local neededItems = tonumber(plan.missingSlots) or 0
        return fetchedItems >= neededItems and "refill_completed" or "refill_partial"
    end

    return nil
end

function QuickslotFetch:BeginFetch(profile, options, completion)
    if self:IsBusy() then
        return false, "quickslot_fetch_busy", nil
    end

    if type(options) == "function" and completion == nil then
        completion = options
        options = {}
    end

    options = type(options) == "table" and options or {}
    options.mode = NormalizeFetchMode(options.mode)

    local planOk, planErr, plan = BuildFetchPlan(profile, options)
    if planOk ~= true then
        return false, planErr, plan
    end

    if plan.mode == FETCH_MODE_REFILL_MAX and plan.refillTargets <= 0 then
        return true, "no_refill_targets", plan
    end

    if plan.missingSlots <= 0 then
        if plan.mode == FETCH_MODE_REFILL_MAX then
            return true, "already_full", plan
        end

        return true, "nothing_missing", plan
    end

    if plan.queuedItems <= 0 then
        if plan.mode == FETCH_MODE_REFILL_MAX then
            return true, "refill_partial", plan
        end

        return true, "no_fetchable_items", plan
    end

    if type(completion) ~= "function" then
        return false, "fetch_completion_required", plan
    end

    local context = {
        plan = plan,
        moveIndex = 1,
        finished = false,
    }
    self.pendingFetchContext = context

    local function Finish(success, err)
        if context.finished then
            return
        end

        context.finished = true
        QuickslotFetch.pendingFetchContext = nil
        completion(success == true, err, context.plan)
    end

    local function MoveNext()
        if context.finished then
            return
        end

        local candidate = context.plan.items[context.moveIndex]
        if type(candidate) ~= "table" then
            Finish(true, BuildFetchCompletionReason(context.plan))
            return
        end

        local refreshedOptions = {}
        for key, value in pairs(options) do
            refreshedOptions[key] = value
        end

        local moveInventoryIndex = BuildMoveInventoryIndex(candidate, context.plan.sourceBagIds)
        local refreshedCandidate = FindBestSourceCandidate(
            candidate.entry,
            context.plan.sourceBagIds,
            refreshedOptions,
            moveInventoryIndex
        )
        if type(refreshedCandidate) ~= "table" or (refreshedCandidate.stackCount or 0) <= 0 then
            Finish(false, "fetch_source_missing")
            return
        end

        local moveQuantity = BuildMoveQuantity(
            refreshedCandidate,
            candidate,
            context.plan.sourceBagIds,
            refreshedOptions,
            moveInventoryIndex
        )
        if moveQuantity <= 0 then
            context.moveIndex = context.moveIndex + 1
            zo_callLater(MoveNext, FETCH_POLL_INTERVAL_MS)
            return
        end

        if type(DoesBagHaveSpaceFor) == "function"
            and DoesBagHaveSpaceFor(BAG_BACKPACK, refreshedCandidate.bagId, refreshedCandidate.slotIndex) ~= true then
            Finish(false, "inventory_full")
            return
        end

        local destSlot = FindFirstBackpackEmptySlot()
        if type(destSlot) ~= "number" then
            Finish(false, "inventory_full")
            return
        end

        local moveOk, moveErr = ExecuteMove(refreshedCandidate, destSlot, moveQuantity)
        if moveOk ~= true then
            Finish(false, moveErr or "move_failed")
            return
        end

        local updateName = BuildUpdateName(context.moveIndex)
        local attempts = 0
        EVENT_MANAGER:RegisterForUpdate(updateName, FETCH_POLL_INTERVAL_MS, function()
            if context.finished then
                EVENT_MANAGER:UnregisterForUpdate(updateName)
                return
            end

            attempts = attempts + 1
            if DidMoveArrive(refreshedCandidate, destSlot) then
                EVENT_MANAGER:UnregisterForUpdate(updateName)
                context.plan.fetchedItems = context.plan.fetchedItems + moveQuantity

                local requirementState = BuildFetchPlanItems({
                    entry = candidate.entry,
                    requiredSlots = 1,
                }, context.plan.sourceBagIds, refreshedOptions)

                if candidate.isStackable == true
                    and (tonumber(requirementState.currentCount) or 0) < (tonumber(candidate.targetCount) or 0)
                    and (tonumber(requirementState.availableCount) or 0) > 0 then
                    zo_callLater(MoveNext, FETCH_POLL_INTERVAL_MS)
                    return
                end

                context.moveIndex = context.moveIndex + 1
                zo_callLater(MoveNext, FETCH_POLL_INTERVAL_MS)
                return
            end

            if attempts >= FETCH_POLL_MAX_ATTEMPTS then
                EVENT_MANAGER:UnregisterForUpdate(updateName)
                Finish(false, "fetch_move_timeout")
            end
        end)
    end

    MoveNext()
    return true, "deferred", plan
end
