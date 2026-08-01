-----------------------------------------------------------------------------------
-- Addon Name: Champion Point Import
-- Creator: TaxTalis
-- Addon Ideal: Import Champion Points from text
-- Addon Creation Date: 2022-06-20
--
-- File Name: Interface.lua
-- File Description: This file contains the user interface shared class
-- Load Order Requirements: TBD
--
-----------------------------------------------------------------------------------
local CPI = ChampionPointImport
local classes = CPI.Import(CPI.classes)
local DataManager = CPI.Import(CPI.DataManager)

local Interface = ZO_Object:Subclass()
classes.Interface = Interface

function Interface:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function Interface:Initialize(title, controlName)
    self.controlName = controlName
    self.control = self:GetControl()
    self.title = self:GetControl("Title")
    self.title:SetText(title)
end

function Interface:GetControl(controlName)
    if(controlName and #controlName > 0) then
        controlName = "_" .. controlName
    end
    return GetControl(self.controlName, controlName or "")
end

function Interface:Refresh()
end

function Interface:SetHidden(isHidden)
    if(not isHidden) then
        self:Refresh()
    end
    self.control:SetHidden(isHidden)
end
function Interface:ToggleHidden()
    self:Refresh()
    self.control:ToggleHidden()
end

local PresetDropdown = ZO_Object:Subclass()
classes.PresetDropdown = PresetDropdown

function PresetDropdown:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function PresetDropdown:Initialize(interfaceName, GetSelectedPreset, OnSelectionChanged, control)
    self.interfaceName = interfaceName
    self.GetSelectedPreset = GetSelectedPreset
    self.OnSelectionChanged = OnSelectionChanged
    if(control) then
        self:AttachControl(control)
    end

    local function RegisterGlobalCallbacks()
        local callbacks = {}
        callbacks[DataManager] =
        {
            ["Initialize"] = function()
                self:InitializeItems()
            end,
            ["PresetAdded"] = function(presetName)
                self:AddItem(presetName)
            end,
            ["PresetDeleted"] = function()
                self:DeleteItem()
            end,
        }
        for callbackObject, callbacks in pairs(callbacks) do
            for callbackName, callbackFunction in pairs(callbacks) do
                callbackObject:RegisterCallback(callbackName, callbackFunction)
            end
        end
    end
    RegisterGlobalCallbacks()
    local function RegisterCallbacks()
        local callbacks = {}
        callbacks[DataManager] = {
            ["PresetUpdated"] = function()
                self:SetItem()
            end,
        }
        for callbackObject, callbacks in pairs(callbacks) do
            for callbackName, callbackFunction in pairs(callbacks) do
                callbackObject:RegisterCallback(self.interfaceName .. callbackName, callbackFunction)
            end
        end
    end
    RegisterCallbacks()
end

function PresetDropdown:AttachControl(control)
    self.dropdown = ZO_ComboBox_ObjectFromContainer(control)
    self:InitializeItems()
end

function PresetDropdown:AddItem(presetName, suppressUpdate)
    if(not self.dropdown) then return end
    local update = ZO_COMBOBOX_UPDATE_NOW
    if(suppressUpdate) then
        update = ZO_COMBOBOX_SUPPRESS_UPDATE
    end
    local entry = ZO_ComboBox:CreateItemEntry(presetName, self.OnSelectionChanged)
    self.dropdown:AddItem(entry, update)
    if(not suppressUpdate) then
        self:SetEnabled()
    end
end

function PresetDropdown:InitializeItems()
    if(not self.dropdown) then return end
    self.dropdown:ClearItems()
    local suppressUpdate = true
    for presetName in DataManager:GetPresetNamesIterator() do
        self:AddItem(presetName, suppressUpdate)
    end
    self.dropdown:UpdateItems()
    self:SetEnabled()
    self:SetItem()
end

function PresetDropdown:DeleteItem()
    self:InitializeItems()
end

function PresetDropdown:SetEnabled()
    if(not self.dropdown) then return end
    self.dropdown:SetEnabled(self.dropdown:GetNumItems() > 0)
end

function PresetDropdown:SetItem()
    if(not self.dropdown) then return end
    local presetName = self.GetSelectedPreset()
    local suppressCallback = true
    local result = self.dropdown:SetSelectedItemByEval(function(item) return item.name == presetName end, suppressCallback)
    if(not result) then
        self.dropdown:SetSelectedItemText("")
    end
end