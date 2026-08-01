local Classes = MyCollection.Internals.Classes
local Constants = MyCollection.Internals.Constants
local Logger = MyCollection.Internals.Dependencies.Logger
local Dependencies = MyCollection.Internals.Dependencies

Classes.Bag = {}
Classes.Bag.__index = Classes.Bag

local Bag = Classes.Bag

-- Constructor
function Bag.New(savedTable, characterId)
    local instance = {}
    setmetatable(instance, Bag)

    instance:Initialize(savedTable, characterId)
    return instance
end

Bag.savedTableReference = nil

-- Properties
Bag.worn = nil
Bag.backpack = nil
Bag.characterId = nil

-- Functions
function Bag:FindAll(setId, equipType, traitType, armorType, weaponType)
    local items = {}
    if next(self.worn) ~= nil then
        for _, item in pairs(self.worn) do
            if item:Equals(setId, equipType, traitType, armorType, weaponType) then
                table.insert(items, item)
            end
        end
    end 
    if next(self.backpack) ~= nil then
        for _, item in pairs(self.backpack) do
            if item:Equals(setId, equipType, traitType, armorType, weaponType) then
                table.insert(items, item)
            end
        end
    end 

    return items
end

function Bag:AddItem(bagId, slotId)
    local item = nil
    if bagId == Constants.BagTypes.Worn then
        self.savedTableReference[Constants.BagTypes.Worn][slotId] = {}
        item = Classes.Item.New(self.savedTableReference[Constants.BagTypes.Worn][slotId], characterId, bagId, slotId)
        if item ~= nil then
            self.worn[slotId] = item
        else
            self.savedTableReference[Constants.BagTypes.Worn][slotId] = nil
            table.remove(self.savedTableReference[Constants.BagTypes.Worn], slotId)
        end
    end
    if bagId == Constants.BagTypes.Backpack then  
        self.savedTableReference[Constants.BagTypes.Backpack][slotId] = {}
        item = Classes.Item.New(self.savedTableReference[Constants.BagTypes.Backpack][slotId], self.characterId, bagId, slotId)  
        if item ~= nil then
            self.backpack[slotId] = item
        else
            self.savedTableReference[Constants.BagTypes.Backpack][slotId] = nil
            table.remove(self.savedTableReference[Constants.BagTypes.Backpack], slotId)
        end
    end    

    return item
end

function Bag:RemoveItem(bagId, slotId)
    local item = nil
    if bagId == Constants.BagTypes.Worn then
        item = self.worn[slotId]
        table.remove(self.worn, slotId)
        table.remove(self.savedTableReference[Constants.BagTypes.Worn], slotId)
    end
    if bagId == Constants.BagTypes.Backpack then
        item = self.backpack[slotId]
        table.remove(self.backpack, slotId)
        table.remove(self.savedTableReference[Constants.BagTypes.Backpack], slotId)
    end

    return item
end

function Bag:Clear()
    self.worn = {}
    self.backpack = {}
    self.savedTableReference[Constants.BagTypes.Worn] = {}
    self.savedTableReference[Constants.BagTypes.Backpack] = {}
end

function Bag:Refresh()
    self:Clear()
    Dependencies.Officials.SharedInventory:RefreshInventory(Constants.BagTypes.Worn)
    Dependencies.Officials.SharedInventory:RefreshInventory(Constants.BagTypes.Backpack)
end

function Bag:Initialize(savedTable, characterId)
    self.worn = {}
    self.backpack = {}
    self.characterId = characterId

    self.savedTableReference = savedTable
    if savedTable == nil then
        savedTable = {}
    end
    if (savedTable[Constants.BagTypes.Worn] == nil) then savedTable[Constants.BagTypes.Worn] = {} end
    if (savedTable[Constants.BagTypes.Backpack] == nil) then savedTable[Constants.BagTypes.Backpack] = {} end

    if (next(savedTable[Constants.BagTypes.Worn]) ~= nil) then
        for slotId, item in pairs(savedTable[Constants.BagTypes.Worn]) do
            self.worn[slotId] = Classes.Item.New(self.savedTableReference[Constants.BagTypes.Worn][slotId], characterId, Constants.BagTypes.Worn, slotId)
        end
    end

    if (next(savedTable[Constants.BagTypes.Backpack]) ~= nil) then
        for slotId, item in pairs(savedTable[Constants.BagTypes.Backpack]) do
            self.backpack[slotId] = Classes.Item.New(self.savedTableReference[Constants.BagTypes.Backpack][slotId], characterId, Constants.BagTypes.Backpack, slotId)
        end
    end
end