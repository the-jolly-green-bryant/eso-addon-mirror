local Classes = MyCollection.Internals.Classes
local Constants = MyCollection.Internals.Constants
local Dependencies = MyCollection.Internals.Dependencies
local Extensions = MyCollection.Internals.Functions.Extensions

Classes.Item = {}
Classes.Item.__index = Classes.Item

local Item = Classes.Item

-- Constructor
function Item.New(savedTable, characterId, bagId, slotId)
    local instance = {}
    setmetatable(instance, Item)    

    if instance:Initialize(savedTable, characterId, bagId, slotId) then
        return instance
    else
        return nil
    end
end

Item.savedTableReference = nil

-- Properties
Item.bagId = nil
Item.slotId = nil
Item.characterId = nil

Item.equipType = nil
Item.armorType = nil
Item.weaponType = nil
Item.traitType = nil
Item.setId = nil
Item.link = nil

-- Functions
function Item:Equals(setId, equipType, traitType, armorType, weaponType)  
    if 
        setId == self.setId and
        equipType == self.equipType and
        (traitType == nil or traitType == 0 or traitType == self.traitType) and
        (armorType == nil or armorType == 0 or armorType == self.armorType) and
        (weaponType == nil or weaponType == 0 or weaponType == self.weaponType)
    then
        return true
    end

    return false
end

function Item:GetLink()
    return self.link
end

function Item:GetId()
    if self.characterId == nil then
        return "account_".. tostring(self.bagId) .. "_".. tostring(self.slotId)
    else
        return tostring(self.characterId) .. "_" .. tostring(self.bagId) .. "_".. tostring(self.slotId)
    end
end

function Item:Initialize(savedTable, characterId, bagId, slotId)
    self.savedTableReference = savedTable

    self.bagId = bagId
    self.slotId = slotId
    self.characterId = characterId
    
    if savedTable.equipType == nil then
        _, _, _, _, _, self.equipType, _, _ = Dependencies.Officials.GetItemInfo(self.bagId, self.slotId)
    else
        self.equipType = savedTable.equipType
    end
    self.savedTableReference.equipType = self.equipType
    
    -- Skip further read if not equipment
    if not Extensions.Constants.IsEquipment(self.equipType) then
        return false
    end

    if savedTable.link == nil then
        self.link = Dependencies.Officials.GetItemLink(self.bagId, self.slotId)    
    else
        self.link = savedTable.link
    end
    self.savedTableReference.link = self.link

    if savedTable.setId == nil then
        _, _, self.setId, _, _, _ = Dependencies.LibSets.IsSetByItemLink(self.link)
    else
        self.setId = savedTable.setId
    end
    self.savedTableReference.setId = self.setId

    -- Skip further if not set item
    if self.setId == nil or self.setId == 0 then
        return false
    end

    if savedTable.traitType == nil then
        self.traitType = Dependencies.Officials.GetItemTrait(self.bagId, self.slotId)
    else
        self.traitType = savedTable.traitType
    end
    self.savedTableReference.traitType = self.traitType

    if Extensions.Constants.IsWeaponOrShield(self.equipType) then 
        if savedTable.weaponType == nil then
            self.weaponType = Dependencies.Officials.GetItemWeaponType(self.bagId, self.slotId)
        else
            self.weaponType = savedTable.weaponType
        end
        self.equipType = Extensions.Constants.GetEquipTypeOfWeapon(self.weaponType)
        self.savedTableReference.equipType = self.equipType
    else         
        if Extensions.Constants.IsArmor(self.equipType) then
            if savedTable.armorType == nil then
                self.armorType = Dependencies.Officials.GetItemArmorType(self.bagId, self.slotId)
            else
                self.armorType = savedTable.armorType
            end
            self.savedTableReference.armorType = self.armorType
        end
    end
    
    return true
end