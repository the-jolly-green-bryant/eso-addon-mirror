-----------------------------------------------------------------------------------
-- Addon Name: Champion Point Import
-- Creator: TaxTalis
-- Addon Ideal: Import Champion Points from text
-- Addon Creation Date: 2022-06-20
--
-- File Name: InterfaceMain.lua
-- File Description: This file contains the main user interface
-- Load Order Requirements: TBD
--
-----------------------------------------------------------------------------------
local CPI = ChampionPointImport
local DataManager = CPI.Import(CPI.DataManager)
local AM = CPI.Import(ZO_ARMORY_MANAGER)
local Interface = CPI.Import(CPI.classes.Interface)
local PresetDropdown = CPI.Import(CPI.classes.PresetDropdown)

local InterfaceMain = Interface:Subclass()

function InterfaceMain:New(...)
    local object = Interface.New(self, ...)
    return object
end

function InterfaceMain:Initialize()
    local title = "CP Import"
    local controlName = "ChampionPointImport_InterfaceMain"
    self.interfaceName = "Main"
    self.DataManager = DataManager:GetInterfaceMainDataManager()
    Interface.Initialize(self, title, controlName)
    self.presetDropdown = self:GetControl("PresetDropdown")
    self.armoryList = self:GetControl("ArmoryList")
    self.redistributeButton = self:GetControl("Redistribute")

    self:BuildArmoryList()
    self:InitializePresetDropdown()

    local function RegisterGlobalCallbacks()
        local callbacks = {}
        callbacks[CHAMPION_PERKS_SCENE] = {
            ["StateChange"] = function()
                self:OnSceneStateChange(CHAMPION_PERKS_SCENE)
            end,
        }
        callbacks[GAMEPAD_CHAMPION_PERKS_SCENE] = {
            ["StateChange"] = function()
                self:OnSceneStateChange(GAMEPAD_CHAMPION_PERKS_SCENE)
            end,
        }
        callbacks[DataManager] = {
            ["Initialize"] = function()
                self.DataManager.Initialize()
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
            ["ArmoryList"] = function()
                self:RefreshArmoryList()
            end,
            ["Redistribute"] = function()
                self:ButtonRedistributeRefresh()
            end,
            ["AddArmoryBuild"] = function()
                self:BuildArmoryList()
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

function InterfaceMain:OnSceneStateChange(Scene)
    if (Scene:IsShowing()) then
        self:SetHidden(false)
    else
        self:SetHidden(true)
        CPI.InterfaceEditor:SetHidden(true)
    end
end

function InterfaceMain:BuildArmoryList()
    ZO_ScrollList_AddDataType(self.armoryList, 1, "ChampionPointImport_InterfaceMain_ArmoryRow", 40, function(control, data)
        self:SetupArmoryRow(control, data)
    end)

    ZO_ScrollList_Clear(self.armoryList)
    local scrollData = ZO_ScrollList_GetDataList(self.armoryList)

    AM:RefreshBuildList()
    AM:RefreshBuildIcons()
    for buildIndex = 1, GetNumUnlockedArmoryBuilds() do
        local dropdown = self:InitializeArmoryPresetDropdown(buildIndex)
        local entryData = ZO_EntryData:New({buildIndex = buildIndex, dropdown = dropdown})
        table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, entryData))
    end

    ZO_ScrollList_Commit(self.armoryList)
end

function InterfaceMain:SetupArmoryRow(control, data)
    local dropdown = data.dropdown
    dropdown:AttachControl(control:GetNamedChild("Dropdown"))

    local buildIndex = data.buildIndex
    local buildData = AM:GetBuildDataByIndex(buildIndex)

    local label = control:GetNamedChild("Label")
    label:SetText(buildData:GetName())

    local icon = control:GetNamedChild("Icon")
    icon:SetTexture(buildData:GetIcon())

    local remove = control:GetNamedChild("Remove")
    remove:SetHandler("OnClicked", function()
        DataManager:RemovePresetForArmoryBuild(buildIndex)
    end)
end

function InterfaceMain:Refresh()
    self:RefreshArmoryList()
end

function InterfaceMain:RefreshArmoryList()
    ZO_ScrollList_RefreshVisible(self.armoryList)
end

function InterfaceMain:InitializePresetDropdown()
    local function OnSelectionChanged(control, name, entry, selectionChanged)
        self.DataManager.LoadPreset(entry.name)
    end
    local function GetSelectedPreset()
        return self.DataManager.GetSelectedPreset()
    end
    PresetDropdown:New(self.interfaceName, GetSelectedPreset, OnSelectionChanged, self.presetDropdown)
end

function InterfaceMain:InitializeArmoryPresetDropdown(buildIndex)
    local function OnSelectionChanged(control, name, entry, selectionChanged)
        DataManager:SavePresetForArmoryBuild(buildIndex, entry.name)
    end
    local function GetSelectedPreset()
        return DataManager:GetPresetForArmoryBuild(buildIndex)
    end
    return PresetDropdown:New("Armory"..tostring(buildIndex), GetSelectedPreset, OnSelectionChanged)
end

function InterfaceMain:ButtonEditOnClicked()
    CPI.InterfaceEditor:ToggleHidden()
end

function InterfaceMain:ButtonRedistributeRefresh()
    -- skill points button
    local buttonText = "Spend Points"
    if (self.DataManager.IsRespecNeeded()) then
        buttonText = "Redistribute"
    end
    self.redistributeButton:SetText(buttonText)
    local isEnabled = not self.DataManager.IsEqualToCurrent()
    self.redistributeButton:SetEnabled(isEnabled)
end

function InterfaceMain:ButtonRedistributeOnClicked()
    local allowRespec = true
    self.DataManager.Redistribute(allowRespec)
end

CPI.InterfaceMain = InterfaceMain:New()