local cbe           = CraftBagExtended
local util          = cbe.utility
local class         = cbe.classes
local debug         = false
class.TransferQueue = ZO_Object:Subclass()

function class.TransferQueue:New(...)
    local controller = ZO_Object.New(self)
    controller:Initialize(...)
    return controller
end

function class.TransferQueue:Initialize(name, sourceBag, targetBag)

    self.name      = name or cbe.name .. "TransferQueue"
    self.sourceBag = sourceBag or BAG_VIRTUAL
    self.targetBag = targetBag or BAG_BACKPACK
    self:Clear()
    if self.targetBag ~= BAG_GUILDBANK then
        self.emptySlotTracker = util.GetSingleton(class.EmptySlotTracker, self.targetBag)
    end
    if self.sourceBag ~= BAG_GUILDBANK then
        self.sourceSlotTracker = util.GetSingleton(class.EmptySlotTracker, self.sourceBag)
    end
end

function class.TransferQueue:Clear()
    util.Debug(self.name..": Clear()")
    if self.emptySlotTracker then
        if self.itemsByTargetSlotIndex then
            for targetSlotIndex, _ in pairs(self.itemsByTargetSlotIndex) do
                self.emptySlotTracker:UnreserveSlot(targetSlotIndex)
            end
        end
        self.emptySlotTracker:UnregisterStackArrivedCallback(self.name, util.OnStackArrived)
    end
    if self.sourceSlotTracker then
        self.sourceSlotTracker:UnregisterStackRemovedCallback(self.name, util.OnStackRemoved)
    end
    self.itemCount = 0
    self.items = {}
    self.itemsByKey = {}
    self.itemsByTargetSlotIndex = {}
    self.itemsBySourceSlotIndex = {}
    self.dequeuedItemsBySourceSlotIndex = {}
end

function class.TransferQueue:AddItem(item)
    if item.itemId == 0 or not item.itemId then 
        util.Debug(self.name..": enqueue failed for item with itemId "..tostring(item.itemId), debug)
        return
    elseif self.targetBag == BAG_VIRTUAL then
        if not cbe.hasCraftBagAccess then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, SI_CRAFT_BAG_STATUS_LOCKED_DESCRIPTION)
            return
        elseif not CanItemBeVirtual(self.sourceBag, item.slotIndex) then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, SI_CBE_CRAFTBAG_ITEM_INVALID)
            return
        else
            item.targetSlotIndex = item.itemId
        end
    end
    
    -- Don't allow items from the same stack to queue before previous transfers have all left the source bag
    if item.location == cbe.constants.LOCATION.SOURCE_BAG 
       and self.itemsBySourceSlotIndex[item.slotIndex]
    then
        for _, queuedItem in ipairs(self.itemsBySourceSlotIndex[item.slotIndex]) do
            if queuedItem.location == cbe.constants.LOCATION.SOURCE_BAG then
                util.Debug(self.name..": enqueue disallowed due to duplicate queued item still in source bag for "
                           ..item.itemLink.." id "..tostring(item.itemId).." bag "..tostring(item.bag).." slot "
                           ..tostring(item.slotIndex).." qty "..tostring(item.quantity), debug)
                return
            end
        end
    end
    
    if self.emptySlotTracker then
        if item.targetSlotIndex == nil then
            local targetSlotIndex = self.emptySlotTracker:ReserveSlot()
            if not targetSlotIndex then
                if self.targetBag == BAG_BANK and IsESOPlusSubscriber() then
                    item.targetBag = BAG_SUBSCRIBER_BANK
                    item.queue = util.GetTransferQueue(self.sourceBag, BAG_SUBSCRIBER_BANK)
                    return item.queue:AddItem(item)
                end
                util.Debug(self.name..": enqueue failed for "..item.itemLink.." id "..tostring(item.itemId)
                           .." bag "..tostring(item.bag).." slot "..tostring(item.slotIndex).." qty "
                           ..tostring(item.quantity), debug)
                return
            end
            item.targetSlotIndex = targetSlotIndex
        end
        if not self.itemsByTargetSlotIndex[item.targetSlotIndex] then
            self.itemsByTargetSlotIndex[item.targetSlotIndex] = { item }
        else
            table.insert(self.itemsByTargetSlotIndex[item.targetSlotIndex], item)
        end
    end
    
    local key = self:GetKey(item.itemId, item.quantity, self.targetBag)
    if not self.itemsByKey[key] then
        self.itemsByKey[key] = {}
    end
    table.insert(self.itemsByKey[key], item)
    if not self.itemsBySourceSlotIndex[item.slotIndex] then
        self.itemsBySourceSlotIndex[item.slotIndex] = { }
    end
    table.insert(self.itemsBySourceSlotIndex[item.slotIndex], item)
    table.insert(self.items, item)
    self.itemCount = self.itemCount + 1
    if self.itemCount == 1 then
        if self.emptySlotTracker then
            self.emptySlotTracker:RegisterStackArrivedCallback(self.name, util.OnStackArrived)
        end
        if self.sourceSlotTracker then
            self.sourceSlotTracker:RegisterStackRemovedCallback(self.name, util.OnStackRemoved)
        end
    end
    if self.sourceBag == BAG_VIRTUAL and item.quantity ~= cbe.constants.QUANTITY_UNSPECIFIED then
        item:StartUnqueueTimeout(cbe.constants.UNQUEUE_TIMEOUT_MS)
    end
    util.Debug(self.name..": enqueue succeeded for "..item.itemLink.." x"..tostring(item.quantity)
               .." (id:"..tostring(item.itemId)..") source bag "..util.GetBagName(item.bag).." slot "
               ..tostring(item.slotIndex).." to target bag "..util.GetBagName(self.targetBag)
               .." slot "..tostring(item.targetSlotIndex), debug)
    return item
end

function class.TransferQueue:Dequeue(bag, slotIndex, quantity)

    if quantity == nil then
        if slotIndex == nil 
           or slotIndex == cbe.constants.QUANTITY_UNSPECIFIED 
        then
            quantity = slotIndex
            slotIndex = bag
            bag = self.targetBag
        end
    end
    
    if bag == self.targetBag and slotIndex and bag ~= BAG_GUILDBANK and bag ~= BAG_VIRTUAL then
        return self:DequeueTargetSlotIndex(slotIndex)
    end
    
    local itemId = GetItemId(bag, slotIndex)
    
    if (not quantity or quantity == 0) and bag ~= BAG_VIRTUAL then
        local stackSize, maxStackSize = GetSlotStackSize(bag, slotIndex)
        quantity = math.min(stackSize, maxStackSize)
        local scope = util.GetTransferItemScope(self.sourceBag, self.targetBag)
        local default = cbe.settings:GetTransferDefault(scope, itemId)
        if default then
            quantity = math.min(quantity, default)
        end
    end
    
    local key = self:GetKey(itemId, quantity, self.targetBag)
    
    if not self.itemsByKey[key] then
        util.Debug(self.name..": dequeue failed for key "..tostring(key), debug)
        return
    end
    
    local item = table.remove(self.itemsByKey[key], 1)
    self:DequeueItem(item, key)
    if not item.targetSlotIndex and bag == self.targetBag and slotIndex then
        item.targetSlotIndex = slotIndex
    end
    return item
end

function class.TransferQueue:DequeueItem(item, key)
    if not item then
        return
    end
    
    item:CancelUnqueueTimeout()
    
    if not util.RemoveValue(self.items, item) then
        return
    end
    
    if self.emptySlotTracker and item.targetSlotIndex and item.targetSlotIndex > 0 then
        self.emptySlotTracker:UnreserveSlot(item.targetSlotIndex)
    end
    
    if not key then
        key = self:GetKey(item.itemId, item.quantity, self.targetBag)
        if self.itemsByKey[key] then
            util.RemoveValue(self.itemsByKey[key], item)
        end
    end
    
    if self.itemsByKey[key] and #self.itemsByKey[key] < 1 then
        self.itemsByKey[key] = nil
    end
    
    if item.targetSlotIndex and self.itemsByTargetSlotIndex[item.targetSlotIndex] then
        util.RemoveValue(self.itemsByTargetSlotIndex[item.targetSlotIndex], item)
        if #self.itemsByTargetSlotIndex[item.targetSlotIndex] < 1 then
            self.itemsByTargetSlotIndex[item.targetSlotIndex] = nil
        end
    end
    if self.itemsBySourceSlotIndex[item.slotIndex] then
        util.RemoveValue(self.itemsBySourceSlotIndex[item.slotIndex], item)
        if #self.itemsBySourceSlotIndex[item.slotIndex] < 1 then
            self.itemsBySourceSlotIndex[item.slotIndex] = nil
        end
    end
    
    if item.location == cbe.constants.LOCATION.SOURCE_BAG then
        if not self.dequeuedItemsBySourceSlotIndex[item.slotIndex] then
            self.dequeuedItemsBySourceSlotIndex[item.slotIndex] = {}
        end
        table.insert(self.dequeuedItemsBySourceSlotIndex[item.slotIndex], item)
    end
    
    self.itemCount = self.itemCount - 1
    
    if self.itemCount < 1 then
        if self.emptySlotTracker then
            self.emptySlotTracker:UnregisterStackArrivedCallback(self.name, util.OnStackArrived)
        end
        if self.sourceSlotTracker and not next(self.dequeuedItemsBySourceSlotIndex) then
            self.sourceSlotTracker:UnregisterStackRemovedCallback(self.name, util.OnStackRemoved)
        end
    end
    
    item.location = cbe.constants.LOCATION.TARGET_BAG
    
    util.Debug(self.name..": dequeue succeeded for "..item.itemLink.." x"..tostring(item.quantity).." (id:"..tostring(item.itemId)..") target bag "..util.GetBagName(item.targetBag).." slot "..tostring(item.targetSlotIndex).." from source bag "..util.GetBagName(item.bag).." slot "..tostring(item.slotIndex), debug)
end

function class.TransferQueue:DequeueTargetSlotIndex(targetSlotIndex)
    local item
    if self.itemsByTargetSlotIndex[targetSlotIndex] then
        item = table.remove(self.itemsByTargetSlotIndex[targetSlotIndex], 1)
        if #self.itemsByTargetSlotIndex[targetSlotIndex] < 1 then
            self.itemsByTargetSlotIndex[targetSlotIndex] = nil
        end
    end
    if not item then
        util.Debug(self.name..": dequeue failed for target slot index "..tostring(targetSlotIndex), debug)
        return
    end
    
    self:DequeueItem(item)
    
    return item
end

function class.TransferQueue:Enqueue(slotIndex, quantity, callback, ...)
    
    local item = class.TransferItem:New(self, slotIndex, quantity, callback, ...)
    return self:AddItem(item)
end

function class.TransferQueue:GetKey(itemId, quantity, bag)
    -- Match by id and quantity
    return tostring(itemId).."-"..tostring(quantity)
end

function class.TransferQueue.GetName(sourceBag, destinationBag)
    return cbe.name .. util.GetBagName(sourceBag) .. util.GetBagName(destinationBag) .. "Queue"
end

function class.TransferQueue:GetSourceBagItems()
    local items = {}
    for _, item in ipairs(self.items) do
        if item.location == cbe.constants.LOCATION.SOURCE_BAG then
            table.insert(items, item)
        end
    end
    return items
end

function class.TransferQueue:HasItems()
    return self.itemCount > 0
end

local function StowCallback(item)
    cbe:Stow(item.targetSlotIndex, item.quantity)
end

function class.TransferQueue:ReturnToCraftBag()
    if self.sourceBag ~= BAG_VIRTUAL then
        return
    end
    
    util.Debug(self.name..":ReturnToCraftBag()", debug)
    
    -- as soon as each item in the queue arrives in the backpack, stow it back in the craft bag
    for _, item in ipairs(self.items) do
        item.callback = StowCallback
    end
end

function class.TransferQueue:TryMarkInTransitItem(bag, slotIndex, quantity)
    
    if bag ~= self.sourceBag then
        return
    end
    
    if self.dequeuedItemsBySourceSlotIndex[slotIndex] then
        
        local item = table.remove(self.dequeuedItemsBySourceSlotIndex[slotIndex], 1)
        if #self.dequeuedItemsBySourceSlotIndex[slotIndex] < 1 then
            self.dequeuedItemsBySourceSlotIndex[slotIndex] = nil
            if self.itemCount < 1 and self.sourceSlotTracker and not next(self.dequeuedItemsBySourceSlotIndex) then
                self.sourceSlotTracker:UnregisterStackRemovedCallback(self.name, util.OnStackRemoved)
            end
        end
        
        util.Debug(self.name..": transfer item has already arrived at target bag "
                   ..util.GetBagName(item.targetBag).." slot "..tostring(item.targetSlotIndex), debug)
        return true
    
    elseif self.itemsBySourceSlotIndex[slotIndex] then
    
        for _, item in ipairs(self.itemsBySourceSlotIndex[slotIndex]) do
            if item.location == cbe.constants.LOCATION.SOURCE_BAG and item ~= cbe.transferDialogItem then
                item.location = cbe.constants.LOCATION.IN_TRANSIT
                util.Debug(self.name..": transfer item marked in-transit", debug)
                return true
            end
        end
    end
end

function class.TransferQueue:UpdateKey(item, oldKey, newKey)
    if not self.itemsByKey[newKey] then
        self.itemsByKey[newKey] = {}
    end
    if self.itemsByKey[oldKey] then
        util.RemoveValue(self.itemsByKey[oldKey], item)
        if #self.itemsByKey[oldKey] < 1 then
            self.itemsByKey[oldKey] = nil
        end
    end
    table.insert(self.itemsByKey[newKey], item)
end

function class.TransferQueue:UnqueueSourceBag()
    for _, item in ipairs(self.items) do
        if item:UnqueueSourceBag() then
            return item
        end
    end
end