local Addon = LarvalTearMod
local QuickslotInventory = Addon.Modules.QuickslotInventory
local QuickslotSnapshot = Addon.Modules.QuickslotSnapshot
local Util = Addon.Common.Util

local DEFAULT_SLOT_COUNT = 8

local function GetQuickslotCategory()
    local category = rawget(_G, "HOTBAR_CATEGORY_QUICKSLOT_WHEEL")
    return type(category) == "number" and category or nil
end

local function GetQuickslotSlotCount()
    local slotCount = rawget(_G, "ACTION_BAR_UTILITY_BAR_SIZE")
    if type(slotCount) == "number" and slotCount > 0 then
        return slotCount
    end

    return DEFAULT_SLOT_COUNT
end

local function NormalizeDisplayText(text)
    if type(text) ~= "string" or text == "" then
        return ""
    end

    if type(zo_strformat) == "function" then
        return zo_strformat("<<C:1>>", text)
    end

    return text
end

local function GetSearchBagIds()
    local bagIds = {}
    if rawget(_G, "BAG_BACKPACK") ~= nil then
        bagIds[#bagIds + 1] = BAG_BACKPACK
    end
    return bagIds
end

function QuickslotSnapshot:GetQuickslotCategory()
    return GetQuickslotCategory()
end

function QuickslotSnapshot:IsItemEntry(entry)
    return type(entry) == "table" and entry.actionType == rawget(_G, "ACTION_TYPE_ITEM")
end

function QuickslotSnapshot:IsSimpleActionEntry(entry)
    if type(entry) ~= "table" then
        return false
    end

    local actionType = entry.actionType
    return actionType == rawget(_G, "ACTION_TYPE_COLLECTIBLE")
        or actionType == rawget(_G, "ACTION_TYPE_QUEST_ITEM")
        or actionType == rawget(_G, "ACTION_TYPE_EMOTE")
        or actionType == rawget(_G, "ACTION_TYPE_QUICK_CHAT")
end

function QuickslotSnapshot:IsEmptyEntry(entry)
    return entry == nil
        or (type(entry) == "table"
            and (entry.actionType == nil or entry.actionType == rawget(_G, "ACTION_TYPE_NOTHING")))
end

function QuickslotSnapshot:BuildInventoryIndex()
    return QuickslotInventory:BuildBagIndex(GetSearchBagIds())
end

function QuickslotSnapshot:FindInventoryItem(entry, targetSlotIndex, inventoryIndex)
    local hotbarCategory = GetQuickslotCategory()
    if type(entry) ~= "table" or type(hotbarCategory) ~= "number" then
        return nil
    end

    inventoryIndex = type(inventoryIndex) == "table" and inventoryIndex or self:BuildInventoryIndex()
    local found, totalCount = QuickslotInventory:FindIndexedResolvedItemState(entry, inventoryIndex, function(itemState)
        return type(IsValidItemForSlot) ~= "function"
            or IsValidItemForSlot(
                itemState.bagId,
                itemState.slotIndex,
                targetSlotIndex or entry.slotIndex,
                hotbarCategory
            )
    end)

    if type(found) ~= "table" then
        return nil
    end

    local resolvedItemState = {}
    for key, value in pairs(found) do
        resolvedItemState[key] = value
    end
    resolvedItemState.totalCount = totalCount
    return resolvedItemState
end

function QuickslotSnapshot:ResolveEntry(entry, inventoryIndex)
    if type(entry) ~= "table" then
        return nil
    end

    local resolved = {}
    for key, value in pairs(entry) do
        resolved[key] = value
    end

    if self:IsItemEntry(resolved) then
        local itemState = self:FindInventoryItem(resolved, resolved.slotIndex, inventoryIndex)
        if itemState ~= nil then
            resolved.bagId = itemState.bagId
            resolved.bagSlotIndex = itemState.bagSlotIndex
            resolved.currentCount = tonumber(itemState.totalCount) or itemState.stackCount
            resolved.missing = false
        else
            resolved.bagId = nil
            resolved.bagSlotIndex = nil
            resolved.currentCount = 0
            resolved.missing = true
        end
    end

    return resolved
end

function QuickslotSnapshot:CaptureSlot(slotIndex, hotbarCategory, inventoryIndex)
    local actionType = type(GetSlotType) == "function" and Util:SafeCall(GetSlotType, slotIndex, hotbarCategory) or nil
    local itemLink = type(GetSlotItemLink) == "function" and Util:SafeCall(GetSlotItemLink, slotIndex, hotbarCategory) or nil
    local name = type(GetSlotName) == "function" and Util:SafeCall(GetSlotName, slotIndex, hotbarCategory) or nil

    local entry = {
        slotIndex = slotIndex,
        actionType = actionType,
        boundId = type(GetSlotBoundId) == "function" and Util:SafeCall(GetSlotBoundId, slotIndex, hotbarCategory) or nil,
        itemId = QuickslotInventory:GetItemLinkItemIdSafe(itemLink),
        itemLink = itemLink,
        name = NormalizeDisplayText(name),
        icon = type(GetSlotTexture) == "function" and Util:SafeCall(GetSlotTexture, slotIndex, hotbarCategory) or nil,
        savedCount = type(GetSlotItemCount) == "function" and Util:SafeCall(GetSlotItemCount, slotIndex, hotbarCategory) or nil,
    }

    return self:ResolveEntry(entry, inventoryIndex)
end

function QuickslotSnapshot:CaptureCurrent(inventoryIndex)
    local hotbarCategory = GetQuickslotCategory()
    if type(hotbarCategory) ~= "number" then
        return nil, "quickslot_category_missing"
    end

    inventoryIndex = type(inventoryIndex) == "table" and inventoryIndex or self:BuildInventoryIndex()
    local slotCount = GetQuickslotSlotCount()
    local snapshot = {
        capturedAt = type(GetTimeStamp) == "function" and GetTimeStamp() or 0,
        slotCount = slotCount,
        slots = {},
    }

    for slotIndex = 1, slotCount do
        snapshot.slots[slotIndex] = self:CaptureSlot(slotIndex, hotbarCategory, inventoryIndex)
    end

    return snapshot
end

function QuickslotSnapshot:BuildProfileSlotsFromSnapshot(snapshot)
    local slots = {}
    for slotIndex = 1, tonumber(snapshot and snapshot.slotCount) or GetQuickslotSlotCount() do
        local source = type(snapshot) == "table" and type(snapshot.slots) == "table" and snapshot.slots[slotIndex] or nil
        if self:IsEmptyEntry(source) then
            slots[slotIndex] = nil
        else
            local entry = {
                slotIndex = slotIndex,
                actionType = type(source) == "table" and source.actionType or rawget(_G, "ACTION_TYPE_NOTHING"),
                boundId = type(source) == "table" and source.boundId or nil,
                itemId = type(source) == "table" and source.itemId or nil,
                itemLink = type(source) == "table" and source.itemLink or nil,
                name = type(source) == "table" and source.name or nil,
                icon = type(source) == "table" and source.icon or nil,
                savedCount = type(source) == "table" and source.savedCount or nil,
            }
            slots[slotIndex] = entry
        end
    end
    return slots
end

function QuickslotSnapshot:ResolveProfile(profile, inventoryIndex)
    if type(profile) ~= "table" then
        return nil, "quickslot_profile_invalid"
    end

    inventoryIndex = type(inventoryIndex) == "table" and inventoryIndex or self:BuildInventoryIndex()
    local resolved = {}
    local slotCount = tonumber(profile.slotCount) or GetQuickslotSlotCount()
    for slotIndex = 1, slotCount do
        local entry = type(profile.slots) == "table" and profile.slots[slotIndex] or nil
        resolved[slotIndex] = self:ResolveEntry(entry or {
            slotIndex = slotIndex,
            actionType = rawget(_G, "ACTION_TYPE_NOTHING"),
        }, inventoryIndex)
    end

    return resolved
end

function QuickslotSnapshot:GetMissingItems(profile, inventoryIndex)
    local resolvedSlots = self:ResolveProfile(profile, inventoryIndex)
    local missing = {}
    for _, entry in ipairs(resolvedSlots or {}) do
        if self:IsItemEntry(entry) and entry.missing == true then
            missing[#missing + 1] = entry
        end
    end
    return missing
end

function QuickslotSnapshot:SlotMatchesEntry(currentEntry, targetEntry)
    if type(currentEntry) ~= "table" or type(targetEntry) ~= "table" then
        return false
    end

    if self:IsItemEntry(targetEntry) then
        if not self:IsItemEntry(currentEntry) then
            return false
        end

        if type(targetEntry.itemLink) == "string" and targetEntry.itemLink ~= "" and currentEntry.itemLink == targetEntry.itemLink then
            return true
        end

        return type(targetEntry.itemId) == "number"
            and targetEntry.itemId > 0
            and currentEntry.itemId == targetEntry.itemId
    end

    if self:IsSimpleActionEntry(targetEntry) then
        if not self:IsSimpleActionEntry(currentEntry) then
            return false
        end

        return currentEntry.actionType == targetEntry.actionType
            and currentEntry.boundId == targetEntry.boundId
    end

    if self:IsEmptyEntry(targetEntry) then
        return self:IsEmptyEntry(currentEntry)
    end

    if type(currentEntry.actionType) ~= "number" or currentEntry.actionType ~= targetEntry.actionType then
        return false
    end

    return currentEntry.boundId == targetEntry.boundId
end

function QuickslotSnapshot:CompareCurrentToProfile(profile, finalSnapshot, resolvedSlots)
    local result = {
        matched = 0,
        mismatched = 0,
        skippedMissing = 0,
        skippedUnsupported = 0,
        ignoredEmpty = 0,
        details = {},
    }

    resolvedSlots = resolvedSlots or self:ResolveProfile(profile) or {}
    local finalSlots = type(finalSnapshot) == "table" and type(finalSnapshot.slots) == "table" and finalSnapshot.slots or {}

    -- NOTE:
    -- ResolveProfile currently fills every slot.
    -- If resolvedSlots becomes sparse, ipairs will silently skip later entries.
    for _, targetEntry in ipairs(resolvedSlots) do
        if self:IsItemEntry(targetEntry) then
            if targetEntry.missing == true then
                result.skippedMissing = result.skippedMissing + 1
            elseif self:SlotMatchesEntry(finalSlots[targetEntry.slotIndex], targetEntry) then
                result.matched = result.matched + 1
            else
                result.mismatched = result.mismatched + 1
                result.details[#result.details + 1] = {
                    slotIndex = targetEntry.slotIndex,
                    reason = "verify_mismatch",
                    target = targetEntry,
                    current = finalSlots[targetEntry.slotIndex],
                }
            end
        elseif self:IsSimpleActionEntry(targetEntry) then
            if type(targetEntry.boundId) ~= "number" or targetEntry.boundId <= 0 then
                result.skippedUnsupported = result.skippedUnsupported + 1
            elseif self:SlotMatchesEntry(finalSlots[targetEntry.slotIndex], targetEntry) then
                result.matched = result.matched + 1
            else
                result.mismatched = result.mismatched + 1
                result.details[#result.details + 1] = {
                    slotIndex = targetEntry.slotIndex,
                    reason = "verify_mismatch",
                    target = targetEntry,
                    current = finalSlots[targetEntry.slotIndex],
                }
            end
        elseif self:IsEmptyEntry(targetEntry) then
            result.ignoredEmpty = result.ignoredEmpty + 1
        else
            result.skippedUnsupported = result.skippedUnsupported + 1
        end
    end

    return result
end
