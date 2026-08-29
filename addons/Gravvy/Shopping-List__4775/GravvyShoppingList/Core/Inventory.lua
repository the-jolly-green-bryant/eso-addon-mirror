ShoppingListInventory = {}

local Inventory = ShoppingListInventory

local function addBag(bags, bagId, kind)
    if bagId ~= nil then
        bags[#bags + 1] = { id = bagId, kind = kind }
    end
end

function Inventory:New(owner)
    return setmetatable({
        owner = owner,
        counts = {},
        refreshSerial = 0,
    }, { __index = self })
end

function Inventory:Initialize()
    self.bags = {}
    addBag(self.bags, BAG_BACKPACK, "backpack")
    addBag(self.bags, BAG_BANK, "bank")
    addBag(self.bags, BAG_SUBSCRIBER_BANK, "bank")
    addBag(self.bags, BAG_VIRTUAL, "craftBag")

    self.bagKinds = {}
    for _, bag in ipairs(self.bags) do
        self.bagKinds[bag.id] = bag.kind
    end

    EVENT_MANAGER:RegisterForEvent(
        "GravvyShoppingList_InventorySlot",
        EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        function(_, bagId)
            if self.bagKinds[bagId] then
                self:QueueRefresh()
            end
        end
    )
    EVENT_MANAGER:RegisterForEvent(
        "GravvyShoppingList_InventoryFull",
        EVENT_INVENTORY_FULL_UPDATE,
        function() self:QueueRefresh() end
    )
    EVENT_MANAGER:RegisterForEvent(
        "GravvyShoppingList_InventoryBank",
        EVENT_OPEN_BANK,
        function() self:QueueRefresh() end
    )
    EVENT_MANAGER:RegisterForEvent(
        "GravvyShoppingList_InventoryCraftBag",
        EVENT_INVENTORY_ITEMS_AUTO_TRANSFERRED_TO_CRAFT_BAG,
        function() self:QueueRefresh() end
    )
    EVENT_MANAGER:RegisterForEvent(
        "GravvyShoppingList_InventoryActivated",
        EVENT_PLAYER_ACTIVATED,
        function() self:QueueRefresh(250) end
    )

    self:QueueRefresh(250)
end

function Inventory:QueueRefresh(delayMs)
    self.refreshSerial = self.refreshSerial + 1
    local serial = self.refreshSerial
    zo_callLater(function()
        if serial == self.refreshSerial then
            self:Refresh()
        end
    end, delayMs or 100)
end

local function addCandidate(index, key, candidate)
    if key == nil or key == "" then
        return
    end
    local entries = index[key]
    if not entries then
        entries = {}
        index[key] = entries
    end
    entries[#entries + 1] = candidate
end

local function readSlot(byName, byItemId, items, bag, slotIndex)
    local stack = GetSlotStackSize(bag.id, slotIndex) or 0
    if stack == 0 then
        return
    end

    local itemName = GetItemName(bag.id, slotIndex)
    local normalizedName = ShoppingListData.NormalizeName(itemName)
    if normalizedName == "" then
        return
    end

    local link = GetItemLink(bag.id, slotIndex, LINK_STYLE_DEFAULT)
    local candidate = {
        kind = bag.kind,
        link = link,
        name = itemName,
        stack = stack,
    }
    items[#items + 1] = candidate
    addCandidate(byName, normalizedName, candidate)
    addCandidate(byItemId, GetItemLinkItemId(link), candidate)
end

function Inventory:ReadItems()
    local byName = {}
    local byItemId = {}
    local items = {}
    for _, bag in ipairs(self.bags) do
        if bag.id == BAG_VIRTUAL then
            local slotIndex = GetNextVirtualBagSlotId()
            while slotIndex do
                readSlot(byName, byItemId, items, bag, slotIndex)
                slotIndex = GetNextVirtualBagSlotId(slotIndex)
            end
        else
            local size = GetBagSize(bag.id) or 0
            for slotIndex = 0, size - 1 do
                readSlot(byName, byItemId, items, bag, slotIndex)
            end
        end
    end
    return byName, byItemId, items
end

local function emptyCounts()
    return {
        backpack = 0,
        bank = 0,
        craftBag = 0,
        total = 0,
    }
end

function Inventory:AllocateShoppingInventory(inventoryItems)
    local entries = {}
    local needed = {}
    local allocated = {}
    for index, item in ipairs(self.owner.data:GetShoppingItems()) do
        if self.owner.data:GetTargetMode(item) == "own" then
            entries[#entries + 1] = { item = item, index = index }
            needed[item.id] = math.max(0, tonumber(item.desired) or 0)
            allocated[item.id] = emptyCounts()
        end
    end

    for _, candidate in ipairs(inventoryItems or {}) do
        local matches = {}
        for _, entry in ipairs(entries) do
            local score = self.owner.matcher:GetItemMatchScore(
                entry.item,
                candidate.link,
                candidate.name
            )
            if score then
                matches[#matches + 1] = {
                    entry = entry,
                    score = score,
                }
            end
        end
        table.sort(matches, function(left, right)
            if left.score == right.score then
                return left.entry.index < right.entry.index
            end
            return left.score > right.score
        end)

        local available = candidate.stack
        for _, match in ipairs(matches) do
            if available <= 0 then
                break
            end
            local itemId = match.entry.item.id
            local quantity = math.min(available, needed[itemId])
            if quantity > 0 then
                local counts = allocated[itemId]
                counts[candidate.kind] = counts[candidate.kind] + quantity
                counts.total = counts.total + quantity
                needed[itemId] = needed[itemId] - quantity
                available = available - quantity
            end
        end
        if available > 0 and matches[1] then
            local itemId = matches[1].entry.item.id
            local counts = allocated[itemId]
            counts[candidate.kind] = counts[candidate.kind] + available
            counts.total = counts.total + available
        end
    end

    self.allocatedCounts = allocated
end

function Inventory:Refresh()
    local inventoryByName, inventoryByItemId, inventoryItems = self:ReadItems()
    local counts = {}
    local changedItemIds = {}

    for _, list in ipairs(self.owner.data:GetLists()) do
        for _, item in ipairs(list.items) do
            local owned = emptyCounts()
            local candidates = item.itemId and inventoryByItemId[item.itemId]
                or inventoryByName[item.normalizedName] or {}
            for _, candidate in ipairs(candidates) do
                if self.owner.matcher:MatchesItem(item, candidate.link, candidate.name) then
                    owned[candidate.kind] = owned[candidate.kind] + candidate.stack
                    owned.total = owned.total + candidate.stack
                end
            end
            counts[item.id] = owned
            local previous = self.counts and self.counts[item.id]
            local changed = not previous and owned.total > 0
            if previous then
                changed = previous.backpack ~= owned.backpack
                    or previous.bank ~= owned.bank
                    or previous.craftBag ~= owned.craftBag
                    or previous.total ~= owned.total
            end
            if changed then
                changedItemIds[#changedItemIds + 1] = item.id
            end
        end
    end

    self.counts = counts
    self.inventoryItems = inventoryItems
    self:AllocateShoppingInventory(inventoryItems)
    if self.owner.data.RefreshInventoryCompletion then
        for _, list in ipairs(self.owner.data:GetLists()) do
            for _, item in ipairs(list.items) do
                self.owner.data:RefreshInventoryCompletion(item)
            end
        end
    end
    if #changedItemIds > 0 and self.owner.data.NotifyUpdate then
        self.owner.data:NotifyUpdate("item", {
            action = "inventoryChanged",
            itemIds = changedItemIds,
        })
    end
    if self.owner.ui then
        self.owner.ui:Refresh()
    end
    if self.owner.gamepad then
        self.owner.gamepad:Refresh()
    end
end

function Inventory:GetCounts(item)
    if not item then
        return nil
    end
    if self.owner.data:GetTargetMode(item) == "own"
        and self.allocatedCounts
        and self.allocatedCounts[item.id]
    then
        return self.allocatedCounts[item.id]
    end
    return self.counts[item.id]
end

function Inventory:GetRawCounts(item)
    return item and self.counts[item.id] or nil
end

function Inventory:RefreshAllocations()
    self:AllocateShoppingInventory(self.inventoryItems or {})
    if self.owner.data.RefreshInventoryCompletion then
        for _, list in ipairs(self.owner.data:GetLists()) do
            for _, item in ipairs(list.items) do
                self.owner.data:RefreshInventoryCompletion(item)
            end
        end
    end
end
