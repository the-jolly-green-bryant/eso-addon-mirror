local cbe   = CraftBagExtended
local util  = cbe.utility
local class = cbe.classes
class.EmptySlotTracker = ZO_Object:Subclass()

local namePrefix = cbe.name .. "EmptySlotTracker"
local debug = false

function class.EmptySlotTracker:New(bagId)
    local instance = ZO_Object.New(self)
    instance:Initialize(bagId)
    return instance
end

function class.EmptySlotTracker.GetName(bagId)
    return cbe.name .. util.GetBagName(bagId) .. "EmptySlotTracker"
end

function class.EmptySlotTracker:GetReservationIndex(slotIndex)
    local reservationIndex
    for i=1,#self.reservedSlotIndexes do
        if self.reservedSlotIndexes[i] == slotIndex then
            return i
        end
    end
end

local function RaiseSlotUpdateCallbacks(callbacksTable, bagId, slotIndex, stackSize, stackCountChange)
    
    for _, callback in ipairs(callbacksTable) do
        local parameters
        if type(callback) == "table" then
            parameters = callback.parameters
            callback = callback.callback
        else
            parameters = { }
        end
        if type(callback) == "function" then
            callback(bagId, slotIndex, stackSize, stackCountChange, unpack(parameters))
        end
    end
end

--[[ Handles inventory item slot update events ]]
local function OnSlotUpdate(bagId, slotIndex, stackSize, stackCountChange)
    
    local self = util.GetSingleton(class.EmptySlotTracker, bagId)
    util.Debug(self.name..".OnSlotUpdate("..util.GetBagName(bagId)..",slotIndex="..tostring(slotIndex)..",stackSize="..tostring(stackSize)..",stackCountChange="..tostring(stackCountChange)..")", debug)
    if stackCountChange < 0 then
        RaiseSlotUpdateCallbacks(self.stackRemovedCallbacks, bagId, slotIndex, stackSize, stackCountChange)
        return 
    end
    
    if self.bagId == BAG_VIRTUAL then
        RaiseSlotUpdateCallbacks(self.stackArrivedCallbacks, bagId, slotIndex, stackSize, stackCountChange)
        return
    elseif #self.reservedSlotIndexes < 1 then 
        return
    end
    
    self:UnreserveSlot(slotIndex)
    
    RaiseSlotUpdateCallbacks(self.stackArrivedCallbacks, bagId, slotIndex, stackSize, stackCountChange)
end

function class.EmptySlotTracker:Initialize(bagId)
    self.bagId               = bagId
    self.reservedSlotIndexes = { }
    self.stackArrivedCallbacks = { }
    self.stackRemovedCallbacks = { }
    self.stackArrivedCallbackScopes = { }
    self.stackRemovedCallbackScopes = { }
end

function class.EmptySlotTracker:GetReservedSlotCount()
   return #self.reservedSlotIndexes 
end

function GetNextEmptySlotIndex(self)
    local slotIndex = FindFirstEmptySlotInBag(self.bagId)
    if not slotIndex or not self:GetReservationIndex(slotIndex) then
        return slotIndex
    end
    while slotIndex do
        slotIndex = ZO_GetNextBagSlotIndex(self.bagId, slotIndex)
        if GetSlotStackSize(self.bagId, slotIndex) == 0 and not self:GetReservationIndex(slotIndex) then
            return slotIndex               
        end
    end
end

function class.EmptySlotTracker:OnSlotUpdate(...)
    OnSlotUpdate(...)
end

function class.EmptySlotTracker:RegisterStackArrivedCallback(scope, callback)
    if not util.Contains(self.stackArrivedCallbacks, callback) then
        table.insert(self.stackArrivedCallbacks, callback)
        self.stackArrivedCallbackScopes[callback] = { scope }
        if #self.stackRemovedCallbacks < 1 then
            util.RegisterSlotUpdateEventHandler(self.bagId, OnSlotUpdate)
        end
        return
    end
    if util.Contains(self.stackArrivedCallbackScopes[callback], scope) then
        return
    end
    table.insert(self.stackArrivedCallbackScopes[callback], scope)
end

function class.EmptySlotTracker:RegisterStackRemovedCallback(scope, callback)
    if not util.Contains(self.stackRemovedCallbacks, callback) then
        table.insert(self.stackRemovedCallbacks, callback)
        self.stackRemovedCallbackScopes[callback] = { scope }
        if #self.stackArrivedCallbacks < 1 then
            util.RegisterSlotUpdateEventHandler(self.bagId, OnSlotUpdate)
        end
        return
    end
    if util.Contains(self.stackRemovedCallbackScopes[callback], scope) then
        return
    end
    table.insert(self.stackRemovedCallbackScopes[callback], scope)
end

function class.EmptySlotTracker:ReserveSlot()
    
    local reservedSlotIndex = GetNextEmptySlotIndex(self)
    if not reservedSlotIndex then
        util.Debug("Cannot ReserveSlot() for bag "..util.GetBagName(self.bagId)..". No empty slots left. "..tostring(#self.reservedSlotIndexes).." slots already reserved.", debug)
        return
    end
    
    table.insert(self.reservedSlotIndexes, reservedSlotIndex)
    local reservationIndex = #self.reservedSlotIndexes
    
    util.Debug("ReserveSlot(): reservationIndex="..tostring(reservationIndex)..",reservedSlotIndex="..tostring(reservedSlotIndex), debug)
    return reservedSlotIndex
end

function class.EmptySlotTracker:UnregisterStackArrivedCallback(scope, callback)
    if not self.stackArrivedCallbackScopes[callback] then
        return
    end
    util.RemoveValue(self.stackArrivedCallbackScopes[callback], scope)
    if #self.stackArrivedCallbackScopes[callback] < 1 then
        util.RemoveValue(self.stackArrivedCallbacks, callback)
        self.stackArrivedCallbackScopes[callback] = nil
    end
    if #self.stackArrivedCallbacks < 1 and #self.stackRemovedCallbacks < 1 then
        util.UnregisterSlotUpdateEventHandler(self.bagId)
    end
end

function class.EmptySlotTracker:UnregisterStackRemovedCallback(scope, callback)
    if not self.stackRemovedCallbackScopes[callback] then
        return
    end
    util.RemoveValue(self.stackRemovedCallbackScopes[callback], scope)
    if #self.stackRemovedCallbackScopes[callback] < 1 then
        util.RemoveValue(self.stackRemovedCallbacks, callback)
        self.stackRemovedCallbackScopes[callback] = nil
    end
    if #self.stackRemovedCallbacks < 1 and #self.stackArrivedCallbacks < 1 then
        util.UnregisterSlotUpdateEventHandler(self.bagId)
    end
end

function class.EmptySlotTracker:UnreserveSlot(slotIndex)
    local reservationIndex = self:GetReservationIndex(slotIndex)
    if not reservationIndex then
        return
    end
    
    util.Debug(self.name..": unreserving "..util.GetBagName(self.bagId).." slot "..tostring(slotIndex).." reservation index "..tostring(reservationIndex), debug)
    table.remove(self.reservedSlotIndexes, reservationIndex)
    return reservationIndex
end