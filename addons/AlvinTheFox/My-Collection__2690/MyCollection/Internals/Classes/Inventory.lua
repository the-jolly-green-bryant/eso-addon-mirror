local Classes = MyCollection.Internals.Classes
local Constants = MyCollection.Internals.Constants
local Extensions = MyCollection.Internals.Functions.Extensions
local Logger = MyCollection.Internals.Dependencies.Logger
local Dependencies = MyCollection.Internals.Dependencies
Classes.Inventory = {}
Classes.Inventory.__index = Classes.Inventory

local Inventory = Classes.Inventory

-- Constructor
function Inventory.New(savedTable)
    local instance = {}
    setmetatable(instance, Inventory)
    
    instance:Initialize(savedTable)
    return instance
end

Inventory.savedTableReference = nil

-- Properties
Inventory.banks = {
    [Constants.BagTypes.Bank] = {},
    [Constants.BagTypes.SubscriberBank] = {},
}
Inventory.bags = {}

-- Functions
function Inventory:FindAll(setId, equipType, traitType, armorType, weaponType)
    local items = {}
    for bankId, bank in pairs(self.banks) do   
        if next(bank) ~= nil then
            for slotId, item in pairs(bank) do
                if item:Equals(setId, equipType, traitType, armorType, weaponType) then
                    table.insert(items, self.banks[bankId][slotId])
                end
            end
        end
    end

    for _, bag in pairs(self.bags) do   
        for _, item in ipairs(bag:FindAll(setId, equipType, traitType, armorType, weaponType)) do
            table.insert(items, item)
        end
    end

    return items
end

function Inventory:AddItem(bagId, slotId)
    local item = nil
    if Extensions.Constants.IsCharacterBag(bagId) then
        local characterId = Dependencies.Officials.GetCurrentCharacterId()
        item = self:GetOrCreateCharacterBag(characterId):AddItem(bagId, slotId)
    else
        if Extensions.Constants.IsBank(bagId) then
            item = self:AddItemToBank(bagId, slotId)
        end
    end
    
    if Logger ~= nil and item ~= nil then
        local _, setName, _, _, _, _ = Dependencies.LibSets.IsSetByItemLink(item.link)
        Logger:Debug("Added bagId:'".. item.bagId .. "', slotId: '".. item.slotId .. "' setName: '".. setName .."' Link: ".. item.link) 
    end

    return item
end

function Inventory:RemoveItem(bagId, slotId)
    local item = nil
    if Extensions.Constants.IsCharacterBag(bagId) then
        local characterId = Dependencies.Officials.GetCurrentCharacterId()
        item = self:GetOrCreateCharacterBag(characterId):RemoveItem(bagId, slotId)
    else
        if Extensions.Constants.IsBank(bagId) then
            if (self.banks[bagId][slotId] ~= nil) then                
                item = self:RemoveItemFromBank(bagId, slotId)
            end
        end
    end
    
    if Logger ~= nil and item ~= nil then
        local _, setName, _, _, _, _ = Dependencies.LibSets.IsSetByItemLink(item.link)
        Logger:Debug("Removed bagId:'".. bagId .. "', slotId: '".. slotId .. "' setName: '".. setName .."' Link: ".. item.link) 
    end

    return item
end

function Inventory:AddBag(characterId)
    self.savedTableReference.bags[characterId] = {}
    self.bags[characterId] = Classes.Bag.New(self.savedTableReference.bags[characterId], characterId)
end

function Inventory:GetOrCreateCharacterBag(characterId)
    if self.bags[characterId] == nil then
        self:AddBag(characterId)
    end
    return self.bags[characterId]
end

function Inventory:AddItemToBank(bagId, slotId)    
    local characterId = Dependencies.Officials.GetCurrentCharacterId()

    self.savedTableReference.banks[bagId][slotId] = {}
    local item = Classes.Item.New(self.savedTableReference.banks[bagId][slotId], characterId, bagId, slotId)

    if item ~= nil then
        self.banks[bagId][slotId] = item
    else    
        self.savedTableReference.banks[bagId][slotId] = nil
        table.remove(self.savedTableReference.banks[bagId], slotId)
    end

    return item
end

function Inventory:RemoveItemFromBank(bagId, slotId)
    local item = self.banks[bagId][slotId]
    table.remove(self.banks[bagId], slotId)
    table.remove(self.savedTableReference.banks[bagId], slotId)

    return item
end

function Inventory:Clear(keepOtherCharacters)
    self.banks[Constants.BagTypes.Bank] = {}
    self.banks[Constants.BagTypes.SubscriberBank] = {}
    self.savedTableReference.banks[Constants.BagTypes.Bank] = {}
    self.savedTableReference.banks[Constants.BagTypes.SubscriberBank] = {}
    if keepOtherCharacters == nil or keepOtherCharacters then
        local characterId = Dependencies.Officials.GetCurrentCharacterId()
        if self.bags[characterId] ~= nil then
            self:GetOrCreateCharacterBag(characterId):Clear()
        end
    else
        for characterId, _ in pairs(self.bags) do
            self:GetOrCreateCharacterBag(characterId):Clear()
        end
    end
end

function Inventory:Refresh()
    self:Clear(true)
    Dependencies.Officials.SharedInventory:RefreshInventory(Constants.BagTypes.Bank)
    Dependencies.Officials.SharedInventory:RefreshInventory(Constants.BagTypes.SubscriberBank)

    local characterId = Dependencies.Officials.GetCurrentCharacterId()
    self:GetOrCreateCharacterBag(characterId):Refresh()
end

function Inventory:Initialize(savedTable)
    self.savedTableReference = savedTable

    if (next(savedTable.banks[Constants.BagTypes.Bank]) ~= nil) then
        for slotId, item in pairs(savedTable.banks[Constants.BagTypes.Bank]) do
            self.banks[Constants.BagTypes.Bank][slotId] = Classes.Item.New(self.savedTableReference.banks[Constants.BagTypes.Bank][slotId], characterId, Constants.BagTypes.Bank, slotId)
        end
    end

    if (next(savedTable.banks[Constants.BagTypes.SubscriberBank]) ~= nil) then
        for slotId, item in pairs(savedTable.banks[Constants.BagTypes.SubscriberBank]) do
            self.banks[Constants.BagTypes.SubscriberBank][slotId] = Classes.Item.New(self.savedTableReference.banks[Constants.BagTypes.SubscriberBank][slotId], characterId, Constants.BagTypes.SubscriberBank, slotId)
        end
    end

    if (next(savedTable.bags) ~= nil) then
        for characterId, _ in pairs(savedTable.bags) do
            self.bags[characterId] = Classes.Bag.New(savedTable.bags[characterId], characterId)            
        end
    end
end