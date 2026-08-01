local Classes = MyCollection.Internals.Classes
local Constants = MyCollection.Internals.Constants
local Extensions = MyCollection.Internals.Functions.Extensions
local Dependencies = MyCollection.Internals.Dependencies
local Logger = MyCollection.Internals.Dependencies.Logger
local Data = MyCollection.Internals.Data

Classes.Piece = {}
Classes.Piece.__index = Classes.Piece

local Piece = Classes.Piece

-- Constructor
function Piece.New(savedTable, setId, equipType, traitType, armorType, weaponType)
    local instance = {}
    setmetatable(instance, Piece)
    
    instance:Initialize(savedTable, setId, equipType, traitType, armorType, weaponType)
    return instance
end

Piece.savedTableReference = nil

Piece.references = {}

-- Properties
Piece.setId = nil
Piece.equipType = nil
Piece.traitType = nil
Piece.armorType = nil
Piece.weaponType = nil

-- Functions
function Piece:SetTrait(traitType)
    self.traitType = traitType
    self.savedTableReference.traitType = traitType
    self:Refresh()
end

function Piece:GetReferences()
    return self.references
end

function Piece:HasItem()
    if next(self.references) ~= nil then
        return true
    end

    return false
end

function Piece:AddReference(item)       
    if self.traitType == nil or self.traitType == 0 or item.traitType == self.traitType then   
        self.references[item:GetId()] = item
    end

    if Logger ~= nil and item ~= nil then
        local _, setName, _, _, _, _ = Dependencies.LibSets.IsSetByItemLink(item.link)
        Logger:Debug("Found setId: '".. tostring(self.setId) .."', traitType: '".. tostring(self.traitType) .."', equipType: '".. tostring(self.equipType) .."', armorType: '".. tostring(self.armorType) .."', weaponType: '".. tostring(self.weaponType) .."', hasItem:'".. tostring(self:HasItem()) .. "'.")
        Logger:Debug("Added bagId:'".. item.bagId .. "', slotId: '".. item.slotId .. "' setName: '".. setName .."' Link: ".. item.link) 
    end
end

function Piece:RemoveReference(item)
    self.references[item:GetId()] = nil
end

function Piece:Refresh()
    self.references = {}
    local items = Data.Inventory:FindAll(self.setId, self.equipType, self.traitType, self.armorType, self.weaponType)
    if next(items) ~= nil then
        for _, item in ipairs(items) do
            self:AddReference(item)
        end
    end  
end

function Piece:Initialize(savedTable, setId, equipType, traitType, armorType, weaponType)    
    self.savedTableReference = savedTable

    self.setId = setId
    self.equipType = equipType
    if (traitType == nil) then
        traitType = Constants.TraitTypes.None
    end
    self.traitType = traitType
    self.armorType = armorType
    self.weaponType = weaponType

    if self.weaponType ~= nil then
        self.equipType = Extensions.Constants.GetEquipTypeOfWeapon(self.weaponType)
    end

    self.references = {}

    if (self.savedTableReference == nil) then
        self.savedTableReference = {
             setId = self.setId,
             equipType = self.equipType, 
             traitType = self.traitType, 
             armorType = self.armorType, 
             weaponType = self.weaponType,
        }         
     end

    self:Refresh()
end

-- For saving purpose
function Piece:GetSavedTable()
    return self.savedTableReference
end