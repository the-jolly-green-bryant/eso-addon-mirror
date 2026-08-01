local Classes = MyCollection.Internals.Classes
local Constants = MyCollection.Internals.Constants
local Dependencies = MyCollection.Internals.Dependencies
local Extensions = MyCollection.Internals.Functions.Extensions

Classes.Set = {}
Classes.Set.__index = Classes.Set

local Set = Classes.Set

-- Constructor
function Set.New(savedTable, setId, setName, armorType, orderNumber)
    local instance = {}
    setmetatable(instance, Set)
    
    instance:Initialize(savedTable, setId, setName, armorType, orderNumber)
    return instance
end

-- Fields
Set.savedTableReference = nil

-- Properties
Set.setId = nil
Set.setName = nil
Set.armorType = nil
Set.orderNumber = nil
Set.pieces = nil

-- Functions
function Set:GetArmorPiece(equipType)
    return self.pieces.armors[equipType]
end
function Set:GetJewelleryPiece(equipType)
    return self.pieces.jewelleries[equipType]
end
function Set:GetWeaponPiece(weaponType)
    return self.pieces.weapons[weaponType]
end

function Set:Completition()
    local count = 0
    for category, group in pairs(self.pieces) do
        for subCategory, piece in pairs(group) do
            if piece:HasItem() then
                count = count + 1
            end
        end
    end

    return count
end

function Set:SetOrderNumber(number)
    if number > 0 and number < 10001 then
        self.orderNumber = number
        self.savedTableReference.orderNumber = number
    end
    if number == 0 then
        self.orderNumber = nil
        self.savedTableReference.orderNumber = nil
    end
end

function Set:GetOrderNumber()
    return self.orderNumber
end

function Set:GetSetName()
    return self.setName
end

function Set:GetSetId()
    return self.setId
end

function Set:GetArmorType()
    return self.armorType
end

function Set:AddItem(item)
    if Extensions.Constants.IsWeaponOrShield(item.equipType) then
        self.pieces.weapons[item.weaponType]:AddReference(item)
    else
        if Extensions.Constants.IsJewellery(item.equipType) then
            self.pieces.jewelleries[item.equipType]:AddReference(item)
        else 
            if Extensions.Constants.IsArmor(item.equipType) and item.armorType == self.armorType then
                self.pieces.armors[item.equipType]:AddReference(item)
            end
        end
    end
end 

function Set:RemoveItem(item)
    if Extensions.Constants.IsWeaponOrShield(item.equipType) then
        self.pieces.weapons[item.weaponType]:RemoveReference(item)
    end

    if Extensions.Constants.IsJewellery(item.equipType) then
        self.pieces.jewelleries[item.equipType]:RemoveReference(item)
    end

    if Extensions.Constants.IsArmor(item.equipType) and item.armoryType == self.armorType then
        self.pieces.armors[item.equipType]:RemoveReference(item)
    end
end

function Set:Initialize(savedTable, setId, setName, armorType, orderNumber)
    self.pieces = {
        armors = {},
        jewelleries = {},
        weapons = {},
    }

    self.savedTableReference = savedTable
    
    self.setId = setId

    if setName == nil then
        setName = Dependencies.LibSets.GetSetName(setId)
    end
    
    self.setName = setName
    self.armorType = armorType
    self.orderNumber = orderNumber

    if savedTable ~= nil and next(savedTable) ~= nil then
        if (next(savedTable.armors) ~= nil) then
            for equipType, item in pairs(savedTable.armors) do
                self.pieces.armors[equipType] = Classes.Piece.New(savedTable.armors[equipType], item.setId, item.equipType, item.traitType, item.armorType, item.weaponType)
            end
        end

        if (next(savedTable.jewelleries) ~= nil) then
            for equipType, item in pairs(savedTable.jewelleries) do
                self.pieces.jewelleries[equipType] = Classes.Piece.New(savedTable.armors[equipType], item.setId, item.equipType, item.traitType, item.armorType, item.weaponType)
            end
        end

        if (next(savedTable.weapons) ~= nil) then
            for equipType, item in pairs(savedTable.weapons) do
                self.pieces.weapons[equipType] = Classes.Piece.New(savedTable.armors[equipType], item.setId, item.equipType, item.traitType, item.armorType, item.weaponType)
            end
        end
    else          
        savedTable.setId = setId
        savedTable.setName = setName
        savedTable.armorType = armorType
        savedTable.orderNumber = orderNumber

        savedTable.armors = {}
        savedTable.jewelleries = {} 
        savedTable.weapons = {} 

        for _, equipType in pairs(Constants.EquipTypes.Armors) do
            self.pieces.armors[equipType] = Classes.Piece.New(nil, self.setId, equipType, nil, self.armorType, nil)
            savedTable.armors[equipType] = self.pieces.armors[equipType]:GetSavedTable()
        end

        for _, equipType in pairs(Constants.EquipTypes.Jewelleries) do
            self.pieces.jewelleries[equipType] = Classes.Piece.New(nil, self.setId, equipType, nil, nil, nil)
            savedTable.jewelleries[equipType] = self.pieces.jewelleries[equipType]:GetSavedTable()
        end

        for _, weaponType in pairs(Constants.WeaponTypes) do
            self.pieces.weapons[weaponType] = Classes.Piece.New(nil, self.setId, equipType, nil, nil, weaponType)
            savedTable.weapons[weaponType] = self.pieces.weapons[weaponType]:GetSavedTable()
        end
    end
end