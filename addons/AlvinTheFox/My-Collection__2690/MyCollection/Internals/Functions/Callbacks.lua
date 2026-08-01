local Functions = MyCollection.Internals.Functions
local Classes = MyCollection.Internals.Classes
local Data = MyCollection.Internals.Data
local Logger = MyCollection.Internals.Dependencies.Logger
local Dependencies = MyCollection.Internals.Dependencies

Functions.Callbacks = {}
local Callbacks = Functions.Callbacks

function Callbacks.Added(bagId, slotId, itemObject)
    local item = Data.Inventory:AddItem(bagId, slotId)
    if item ~= nil then
        Data.Collection:AddItem(item)
    end
end

function Callbacks.Removed(bagId, slotId, itemObject)
    local item = Data.Inventory:RemoveItem(bagId, slotId)
    if item ~= nil then
        Data.Collection:RemoveItem(item)
    end
end

function Callbacks.Updated(bagId, slotId, itemObject)
    local item = Data.Inventory:AddItem(bagId, slotId)
    if item ~= nil then
        Data.Collection:AddItem(item)
    end
end

