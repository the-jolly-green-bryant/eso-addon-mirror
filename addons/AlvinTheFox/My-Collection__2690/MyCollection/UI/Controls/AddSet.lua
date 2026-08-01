local Saved = MyCollection.Internals.Saved
local Data = MyCollection.Internals.Data
local Constants = MyCollection.Internals.Constants
local Dependencies = MyCollection.Internals.Dependencies
local Logger = MyCollection.Internals.Dependencies.Logger
local EventManager = MyCollection.Internals.Dependencies.Officials.EventManager
local UI = MyCollection.UI
local Controls = MyCollection.UI.Controls

Controls.AddSet = {}
Controls.AddSet.__index = Controls.AddSet

local AddSet = Controls.AddSet

-- Constructor
function AddSet.New(element)
    local instance = {}
    setmetatable(instance, AddSet)

    instance:Initialize(element)
    return instance
end

-- UI containers
AddSet.Element = nil

-- Sub Elements
AddSet.Label = nil
AddSet.OrderNumber = nil

-- Selectors
AddSet.ArmorSelector = nil
AddSet.SetSelector = nil

-- Functions

function AddSet:Initialize(element)
    self.Element = element

    -- Set Selector
    self.SetSelector = ZO_ComboBox_ObjectFromContainer(self.Element:GetNamedChild("Selector"))

    self.SetSelector:SetSortsItems(true)
    self.SetSelector:ClearItems()

    for key, _ in pairs(Dependencies.LibSets.GetAllSetIds()) do
        local name = Dependencies.LibSets.GetSetName(key)
        local entry = ZO_ComboBox:CreateItemEntry(name, function () end)
        entry.id = key
		self.SetSelector:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
    end

    self.SetSelector:SetSortOrder(ZO_SORT_ORDER_UP, ZO_SORT_BY_NAME)
    self.SetSelector:SetHeight(500)

    self.SetSelector:SelectFirstItem()

    -- Armor Type selector
    local armorTypeSelectorElement = self.Element:GetNamedChild("ArmorType")
    self.ArmorSelector = ZO_RadioButtonGroup:New()
    
    local lightButton = self.Element:GetNamedChild("Light")
    lightButton.armorType = Constants.ArmorTypes.Light
    self.ArmorSelector:Add(lightButton)
    
    local mediumButton = self.Element:GetNamedChild("Medium")
    mediumButton.armorType = Constants.ArmorTypes.Medium
    self.ArmorSelector:Add(mediumButton)

    local heavyButton = self.Element:GetNamedChild("Heavy")
    heavyButton.armorType = Constants.ArmorTypes.Heavy
    self.ArmorSelector:Add(heavyButton)
    
    self.ArmorSelector:SetClickedButton(lightButton)

    -- Order Number
    self.OrderNumber = self.Element:GetNamedChild("OrderNumber"):GetNamedChild("Box")
    self.OrderNumber:SetTextType(TEXT_TYPE_NUMERIC_UNSIGNED_INT)
    self.OrderNumber:SetMaxInputChars(4)
    self.OrderNumber:SetText(0)
    
    -- Add Button
    local addButton = self.Element:GetNamedChild("Add")
    addButton:SetHandler("OnMouseUp", AddSet.OnMouseUpItem)
end

function AddSet.OnMouseUpItem(control, button, upInside)
    local addSetMenu = UI.Frame.AddSet
    
    if (upInside) then
        if (button == MOUSE_BUTTON_INDEX_LEFT) then
            local setId = addSetMenu.SetSelector:GetSelectedItemData().id
            local armorType = addSetMenu.ArmorSelector:GetClickedButton().armorType
            local orderNumber = tonumber(addSetMenu.OrderNumber:GetText())
            Data.Collection:AddSet(setId, armorType, orderNumber)
            UI.Frame.MenuBar:DefaultPage()
		end
	end
end

-- https://esoapi.uesp.net/100031/src/libraries/zo_combobox/zo_combobox.lua.html
-- https://esodata.uesp.net/100031/src/libraries/utility/zo_radiobuttongroup.lua.html