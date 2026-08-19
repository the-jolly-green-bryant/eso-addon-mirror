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

local function readSlot(byName, bag, slotIndex)
    local stack = GetSlotStackSize(bag.id, slotIndex) or 0
    if stack == 0 then
        return
    end

    local itemName = GetItemName(bag.id, slotIndex)
    local normalizedName = ShoppingListData.NormalizeName(itemName)
    if normalizedName == "" then
        return
    end

    local entries = byName[normalizedName]
    if not entries then
        entries = {}
        byName[normalizedName] = entries
    end
    entries[#entries + 1] = {
        kind = bag.kind,
        link = GetItemLink(bag.id, slotIndex, LINK_STYLE_DEFAULT),
        name = itemName,
        stack = stack,
    }
end

function Inventory:ReadItems()
    local byName = {}
    for _, bag in ipairs(self.bags) do
        if bag.id == BAG_VIRTUAL then
            local slotIndex = GetNextVirtualBagSlotId()
            while slotIndex do
                readSlot(byName, bag, slotIndex)
                slotIndex = GetNextVirtualBagSlotId(slotIndex)
            end
        else
            local size = GetBagSize(bag.id) or 0
            for slotIndex = 0, size - 1 do
                readSlot(byName, bag, slotIndex)
            end
        end
    end
    return byName
end

function Inventory:Refresh()
    local inventoryItems = self:ReadItems()
    local counts = {}

    for _, list in ipairs(self.owner.data:GetLists()) do
        for _, item in ipairs(list.items) do
            local owned = {
                backpack = 0,
                bank = 0,
                craftBag = 0,
                total = 0,
            }
            local candidates = inventoryItems[item.normalizedName] or {}
            for _, candidate in ipairs(candidates) do
                if self.owner.matcher:MatchesItem(item, candidate.link, candidate.name) then
                    owned[candidate.kind] = owned[candidate.kind] + candidate.stack
                    owned.total = owned.total + candidate.stack
                end
            end
            counts[item.id] = owned
        end
    end

    self.counts = counts
    if self.owner.ui then
        self.owner.ui:Refresh()
    end
    if self.owner.gamepad then
        self.owner.gamepad:Refresh()
    end
end

function Inventory:GetCounts(item)
    return item and self.counts[item.id] or nil
end
