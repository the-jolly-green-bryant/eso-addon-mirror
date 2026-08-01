local Classes = MyCollection.Internals.Classes
local Constants = MyCollection.Internals.Constants
local Logger = MyCollection.Internals.Dependencies.Logger
local Dependencies = MyCollection.Internals.Dependencies

Classes.Collection = {}
Classes.Collection.__index = Classes.Collection

local Collection = Classes.Collection

-- Constructor
function Collection.New(savedTable)
    local instance = {}
    setmetatable(instance, Collection)

    instance:Initialize(savedTable)
    return instance
end

-- Fields
Collection.savedTableReference = nil

-- Properties
Collection.sets = {}

-- Functions
function Collection:GetSets()
    return self.sets
end

function Collection:AddItem(item)
    if (next(self.sets) ~= nil) then
        for key, set in pairs(self.sets) do
            if set:GetSetId() == item.setId then
                self.sets[key]:AddItem(item)
            end
        end
    end
end

function Collection:RemoveItem(item)
    if (next(self.sets) ~= nil) then
        for key, set in pairs(self.sets) do
            if set:GetSetId() == item.setId then
                self.sets[key]:RemoveItem(item)
            end
        end
    end
end

function Collection:AddSet(setId, armorType, orderNumber)
    local newId = 0
    if (next(self.sets) ~= nil) then
        for key, _ in pairs(self.sets) do
            if key > newId then
                newId = key
            end
        end
    end
    newId = newId + 1
    self.savedTableReference.sets[newId] = {}
    self.sets[newId] = Classes.Set.New(self.savedTableReference.sets[newId], setId, nil, armorType, orderNumber)
end

function Collection:RemoveSet(id)
    table.remove(self.sets, id)
    table.remove(self.savedTableReference.sets, id)
end

function Collection:Clear()
    self.sets = {}
    self.savedTableReference.sets = {}
end

function Collection:Initialize(savedTable)
    self.savedTableReference = savedTable
    
    if (next(savedTable.sets) ~= nil) then
        for id, set in pairs(savedTable.sets) do
            self.sets[id] = Classes.Set.New(savedTable.sets[id], set.setId, set.setName, set.armorType, set.orderNumber)
        end
    end
end