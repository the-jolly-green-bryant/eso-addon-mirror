local Addon = LarvalTearMod
local QuickslotInventory = Addon.Modules.QuickslotInventory
local Util = Addon.Common.Util

function QuickslotInventory:IterateBagSlots(bagId, visitor)
    if type(visitor) ~= "function" then
        return
    end

    if type(ZO_IterateBagSlots) == "function" then
        for slotIndex in ZO_IterateBagSlots(bagId) do
            visitor(slotIndex)
        end
        return
    end

    if type(GetBagSize) ~= "function" then
        return
    end

    local bagSize = GetBagSize(bagId)
    if type(bagSize) ~= "number" then
        return
    end

    for slotIndex = 0, bagSize - 1 do
        visitor(slotIndex)
    end
end

function QuickslotInventory:GetItemLinkItemIdSafe(itemLink)
    if type(itemLink) ~= "string" or itemLink == "" or type(GetItemLinkItemId) ~= "function" then
        return nil
    end

    local itemId = Util:SafeCall(GetItemLinkItemId, itemLink)
    if type(itemId) == "number" and itemId > 0 then
        return itemId
    end

    return nil
end

function QuickslotInventory:ExtractItemLinkProxyTailA(itemLink)
    if type(itemLink) ~= "string" or itemLink == "" then
        return nil
    end

    -- Best-effort discriminator for QuickSlot items where itemId alone is too broad,
    -- such as siege stacks or item instances encoded in the itemLink tail fields.
    local numbers = {}
    for field in string.gmatch(itemLink, ":(%-?%d+)") do
        numbers[#numbers + 1] = tonumber(field)
    end

    return numbers[#numbers - 1]
end

function QuickslotInventory:BuildBagItemState(bagId, slotIndex, options)
    if type(GetItemLink) ~= "function" then
        return nil
    end

    options = type(options) == "table" and options or {}

    local itemLink = Util:SafeCall(GetItemLink, bagId, slotIndex, LINK_STYLE_DEFAULT)
    if type(itemLink) ~= "string" or itemLink == "" then
        return nil
    end

    local itemId = type(GetItemId) == "function" and Util:SafeCall(GetItemId, bagId, slotIndex) or nil
    if type(itemId) ~= "number" or itemId <= 0 then
        itemId = self:GetItemLinkItemIdSafe(itemLink)
    end

    local stackCount, maxStackSize = nil, nil
    if type(GetSlotStackSize) == "function" then
        stackCount, maxStackSize = Util:SafeCall(GetSlotStackSize, bagId, slotIndex)
    end
    if type(stackCount) ~= "number" then
        stackCount = type(GetItemTotalCount) == "function" and Util:SafeCall(GetItemTotalCount, bagId, slotIndex) or nil
    end

    local state = {
        bagId = bagId,
        slotIndex = slotIndex,
        bagSlotIndex = slotIndex,
        itemLink = itemLink,
        itemId = itemId,
        stackCount = tonumber(stackCount) or 0,
    }

    if options.includeMaxStackSize == true then
        state.maxStackSize = tonumber(maxStackSize) or nil
    end

    if options.includeCondition == true then
        local condition = type(GetItemCondition) == "function" and Util:SafeCall(GetItemCondition, bagId, slotIndex) or nil
        state.condition = tonumber(condition) or nil
    end

    if options.includeProxyTailA == true then
        state.proxyTailA = self:ExtractItemLinkProxyTailA(itemLink)
    end

    return state
end

local function AddIndexedItemState(index, key, itemState)
    if key == nil or type(itemState) ~= "table" then
        return
    end

    local matches = index[key]
    if type(matches) ~= "table" then
        matches = {}
        index[key] = matches
    end
    matches[#matches + 1] = itemState
end

function QuickslotInventory:BuildBagIndex(bagIds, options)
    local index = {
        itemStates = {},
        itemLinks = {},
        itemIds = {},
        orderByItemState = {},
    }

    for _, bagId in ipairs(type(bagIds) == "table" and bagIds or {}) do
        self:IterateBagSlots(bagId, function(slotIndex)
            local itemState = self:BuildBagItemState(bagId, slotIndex, options)
            if type(itemState) ~= "table" then
                return
            end

            index.itemStates[#index.itemStates + 1] = itemState
            index.orderByItemState[itemState] = #index.itemStates
            AddIndexedItemState(index.itemLinks, itemState.itemLink, itemState)
            if type(itemState.itemId) == "number" and itemState.itemId > 0 then
                AddIndexedItemState(index.itemIds, itemState.itemId, itemState)
            end
        end)
    end

    return index
end

function QuickslotInventory:GetIndexedCountingItemStates(entry, index)
    if type(entry) ~= "table" or type(index) ~= "table" then
        return {}
    end

    if type(entry.itemId) == "number" and entry.itemId > 0 then
        local matches = type(index.itemIds) == "table" and index.itemIds[entry.itemId] or nil
        return type(matches) == "table" and matches or {}
    end

    if type(entry.itemLink) == "string" and entry.itemLink ~= "" then
        local matches = type(index.itemLinks) == "table" and index.itemLinks[entry.itemLink] or nil
        return type(matches) == "table" and matches or {}
    end

    return {}
end

function QuickslotInventory:EntryMatchesResolvedItemState(entry, itemState)
    -- Restore matching prefers itemLink first so we only reuse an item that can
    -- resolve back to the same QuickSlot entry when link-level identity is known.
    if type(entry) ~= "table" or type(itemState) ~= "table" then
        return false
    end

    if type(entry.itemLink) == "string" and entry.itemLink ~= "" and itemState.itemLink == entry.itemLink then
        return true
    end

    return type(entry.itemId) == "number"
        and entry.itemId > 0
        and itemState.itemId == entry.itemId
end

function QuickslotInventory:EntryCountsTowardItemState(entry, itemState)
    -- Refill counting prefers itemId because total availability is a stack-level
    -- aggregate; itemLink is only a fallback when itemId was not captured.
    if type(entry) ~= "table" or type(itemState) ~= "table" then
        return false
    end

    if type(entry.itemId) == "number" and entry.itemId > 0 then
        return itemState.itemId == entry.itemId
    end

    return type(entry.itemLink) == "string"
        and entry.itemLink ~= ""
        and itemState.itemLink == entry.itemLink
end

local function GetNextResolvedCandidate(linkMatches, linkIndex, idMatches, idIndex, orderByItemState)
    local linkCandidate = linkMatches[linkIndex]
    local idCandidate = idMatches[idIndex]
    if linkCandidate == nil then
        return idCandidate, linkIndex, idIndex + 1
    end
    if idCandidate == nil then
        return linkCandidate, linkIndex + 1, idIndex
    end
    if linkCandidate == idCandidate then
        return linkCandidate, linkIndex + 1, idIndex + 1
    end

    local linkOrder = orderByItemState[linkCandidate] or math.huge
    local idOrder = orderByItemState[idCandidate] or math.huge
    if linkOrder <= idOrder then
        return linkCandidate, linkIndex + 1, idIndex
    end

    return idCandidate, linkIndex, idIndex + 1
end

function QuickslotInventory:FindIndexedResolvedItemState(entry, index, validator)
    if type(entry) ~= "table" or type(index) ~= "table" then
        return nil, 0
    end

    local itemLinks = type(index.itemLinks) == "table" and index.itemLinks or {}
    local itemIds = type(index.itemIds) == "table" and index.itemIds or {}
    local orderByItemState = type(index.orderByItemState) == "table" and index.orderByItemState or {}
    local linkMatches = type(entry.itemLink) == "string" and entry.itemLink ~= ""
        and itemLinks[entry.itemLink]
        or nil
    local idMatches = type(entry.itemId) == "number" and entry.itemId > 0
        and itemIds[entry.itemId]
        or nil
    linkMatches = type(linkMatches) == "table" and linkMatches or {}
    idMatches = type(idMatches) == "table" and idMatches or {}

    local countMatches = self:GetIndexedCountingItemStates(entry, index)
    local totalCount = 0
    for _, itemState in ipairs(countMatches) do
        if self:EntryCountsTowardItemState(entry, itemState) then
            totalCount = totalCount + (tonumber(itemState.stackCount) or 0)
        end
    end

    local found = nil
    local linkIndex = 1
    local idIndex = 1
    while linkIndex <= #linkMatches or idIndex <= #idMatches do
        local candidate = nil
        candidate, linkIndex, idIndex = GetNextResolvedCandidate(
            linkMatches,
            linkIndex,
            idMatches,
            idIndex,
            orderByItemState
        )
        if self:EntryMatchesResolvedItemState(entry, candidate)
            and (type(validator) ~= "function" or validator(candidate) == true) then
            found = candidate
            break
        end
    end

    return found, totalCount
end
