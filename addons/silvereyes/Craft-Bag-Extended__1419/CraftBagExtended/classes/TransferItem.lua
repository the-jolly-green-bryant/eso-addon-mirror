local cbe   = CraftBagExtended
local util  = cbe.utility
local class = cbe.classes
class.TransferItem = ZO_Object:Subclass()

local name = cbe.name .. "TransferItem"
local debug = false
local instanceId = 0

function class.TransferItem:New(queue, slotIndex, quantity, callback, ...)
    local instance = ZO_Object.New(self)
    instance:Initialize(queue, slotIndex, quantity, callback, ...)
    return instance
end

local function GetNewInstanceId()
    instanceId = instanceId + 1
    return instanceId
end

function class.TransferItem:Initialize(queue, slotIndex, quantity, callback, ...)
    local itemLink = GetItemLink(queue.sourceBag, slotIndex)
    local itemId = GetItemId(queue.sourceBag, slotIndex)
    if not quantity then
        local stackSize, maxStackSize = GetSlotStackSize(queue.sourceBag, slotIndex)
        quantity = math.min(stackSize, maxStackSize)
        local scope = util.GetTransferItemScope(queue.sourceBag, queue.targetBag)
        local default = cbe.settings:GetTransferDefault(scope, itemId)
        if default then
            quantity = math.min(quantity, default)
        end
    end
    
    self.queue = queue
    self.bag = queue.sourceBag
    self.slotIndex = slotIndex
    self.itemId = itemId
    self.itemLink = itemLink
    self.quantity = quantity
    self.targetBag = queue.targetBag
    self.callback = callback
    self.callbackParams = { ... }
    self.location = cbe.constants.LOCATION.SOURCE_BAG
    self.instanceId = GetNewInstanceId()
    self.name = name .. tostring(self.instanceId)
    
    if cbe.noAutoReturn then
        self.noAutoReturn = cbe.noAutoReturn
        cbe.noAutoReturn = nil
    end
end

function class.TransferItem:CancelUnqueueTimeout()
    if not self.unqueueTimeout then 
        return
    end
    util.Debug(self.name..":CancelUnqueueTimeout()", debug)
    local scopeName = name .. tostring(self.instanceId) .. "Unqueue"
    EVENT_MANAGER:UnregisterForUpdate(scopeName)
end

--[[ Undoes a previous enqueue operation for this item ]]
function class.TransferItem:Dequeue()
    util.Debug(self.name..":Dequeue()", debug)
    self.queue:DequeueItem(self)
end

--[[ Performs the next configured callback, and clears it so that it doesn't
     run again, setting the targetSlotIndex and passing any additional params.
     If self.callback is a table with multiple entries, the first entry is popped
     and executed. ]]
function class.TransferItem:ExecuteCallback(targetSlotIndex, ...)
    if not self.callback then return end
    
    -- If multiple callbacks are specified, pop the first one off
    local callback
    local callbackParams
    if type(self.callback) == "table"  then
        if #self.callback == 0 then
            self.callback = nil
            self.callbackParams = nil
            callback = nil
            callbackParams = nil
        else
            callback = table.remove(self.callback, 1)
            if #self.callbackParams > 0 then
                callbackParams = table.remove(self.callbackParams, 1)
            else
                callbackParams = { }
            end
            if #self.callback == 0 then
                self.callback = nil
                self.callbackParams = nil
            end
        end
    -- Only one callback. Clear it.
    else
        callback = self.callback
        callbackParams = self.callbackParams
        self.callback = nil
        self.callbackParams = nil
    end
    
    -- Raise the callback, if it's a function. Otherwise, ignore.
    if type(callback) == "function" then
        util.Debug(self.name..": calling callback on bag "..util.GetBagName(self.targetBag).." slot "..tostring(targetSlotIndex), debug)
        self.targetSlotIndex = targetSlotIndex
        callback(self, callbackParams, ...)
    else
        util.Debug(self.name..": callback on bag "..util.GetBagName(self.targetBag).." slot "..tostring(targetSlotIndex).." was not a function. it was a "..type(callback), debug)
    end
end

--[[ Returns true if the current transfer item still has a callback configured. ]]
function class.TransferItem:HasCallback()
    return (type(self.callback) == "table" and self.callback[1])
           or type(self.callback) == "function"
end

--[[ Queues the same transfer item up again to be handled by another server 
     event. If targetBag is supplied, then the item is queued for transfer to 
     the new bag.  Otherwise, the item is added to its original queue. ]]
function class.TransferItem:Requeue(targetBag)
    util.Debug(self.name..":Requeue("..util.GetBagName(targetBag)..")", debug)
    -- If queuing a transfer to a new bag, get the new transfer queue and queue
    -- up a new transfer item.
    if targetBag and targetBag ~= self.targetBag then
        local transferQueue = util.GetTransferQueue(self.targetBag, targetBag)
        return transferQueue:Enqueue(self.targetSlotIndex, self.quantity, self.callback)
        
    -- If queuing a non-transfer for temporary data storage between events, just
    -- add this item back to the queue.
    else
        if targetBag then
            self.location = cbe.constants.LOCATION.IN_TRANSIT
        end
        return self.queue:AddItem(self)
    end
    
end

local function unqueueSourceBagForItem(transferItem)
    return function()
        transferItem:UnqueueSourceBag()
    end
end

function class.TransferItem:StartUnqueueTimeout(timeoutMilliseconds)
    util.Debug(self.name..":StartUnqueueTimeout("..tostring(timeoutMilliseconds)..")", debug)
    self.unqueueTimeout = timeoutMilliseconds
    local scopeName = name .. tostring(self.instanceId) .. "Unqueue"
    EVENT_MANAGER:RegisterForUpdate( scopeName, timeoutMilliseconds, unqueueSourceBagForItem(self))
end

function class.TransferItem:UnqueueSourceBag()
    if self.location == cbe.constants.LOCATION.SOURCE_BAG then
        util.Debug(self.name..":UnqueueSourceBag()", debug)
        -- Mark the location as in-transit so that any future removals from its source slot don't try to mark it as in transit.
        self.location = cbe.constants.LOCATION.IN_TRANSIT
        self.queue:DequeueItem(self)
        return true
    end 
end

function class.TransferItem:UpdateQuantity(quantity)
    util.Debug(self.name..":UpdateQuantity("..tostring(quantity)..")", debug)
    local oldKey = self.queue:GetKey(self.itemId, self.quantity)
    local newKey = self.queue:GetKey(self.itemId, quantity)
    self.queue:UpdateKey(self, oldKey, newKey)
    self.quantity = quantity
end