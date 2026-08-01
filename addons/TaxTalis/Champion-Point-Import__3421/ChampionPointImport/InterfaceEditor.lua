-----------------------------------------------------------------------------------
-- Addon Name: Champion Point Import
-- Creator: TaxTalis
-- Addon Ideal: Import Champion Points from text
-- Addon Creation Date: 2022-06-20
--
-- File Name: InterfaceEditor.lua
-- File Description: This file contains the editor user interface
-- Load Order Requirements: TBD
--
-----------------------------------------------------------------------------------
local CPI = ChampionPointImport
local DataManager = CPI.Import(CPI.DataManager)
local ImportManager = CPI.Import(CPI.ImportManager)
local Interface = CPI.Import(CPI.classes.Interface)
local PresetDropdown = CPI.Import(CPI.classes.PresetDropdown)

local InterfaceEditor = Interface:Subclass()

function InterfaceEditor:New(...)
    local object = Interface.New(self, ...)
    return object
end

function InterfaceEditor:Initialize()
    local title = "Preset Editor"
    local controlName = "ChampionPointImport_InterfaceEditor"
    self.interfaceName = "Editor"
    self.DataManager = DataManager:GetInterfaceEditorDataManager()
    Interface.Initialize(self, title, controlName)
    self.skillList = self:GetControl("SkillList")
    self.presetDropdown = self:GetControl("PresetDropdown")
    self.presetNameEditBox = self:GetControl("PresetName")
    self.presetInputEditBox = self:GetControl("Input")
    self.presetSaveButton = self:GetControl("PresetSave")
    self.presetDeleteButton = self:GetControl("PresetDelete")
    self.presetAutoRespecCheckButton = self:GetControl("AutoRespec")

    self:BuildSkillList()
    self:InitializePresetDropdown()
    self:InitializePresetAutoRespecCheckButton()

    local function RegisterGlobalCallbacks()
        local callbacks = {}
        callbacks[DataManager] = {
            ["Initialize"] = function()
                self.DataManager.Initialize()
            end,
            ["PresetDeleted"] = function()
                local presetName = self.DataManager:GetPreset()
                self.presetDeleteButton:SetEnabled(DataManager:IsExistingPresetName(presetName))
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
            ["PresetName"] = function(presetName)
                self:SetPresetName(presetName)
            end,
            ["PresetInput"] = function(input)
                self:SetPresetInput(input)
            end,
            ["AutoRespec"] = function(input)
                self:SetPresetAutoRespec(input)
            end,
            ["PresetUpdated"] = function()
                local presetName = self.DataManager:GetPreset()
                self.presetSaveButton:SetEnabled(presetName and #presetName > 0)
                self.presetDeleteButton:SetEnabled(DataManager:IsExistingPresetName(presetName))
            end,
            ["SkillList"] = function()
                self:RefreshSkillList()
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

function InterfaceEditor:OnSceneStateChange(Scene)
    if (Scene:IsShowing()) then
        self.control:SetHidden(false)
    else
        self.control:SetHidden(true)
    end
end

function InterfaceEditor:PresetChanged()
    local presetName = self.presetNameEditBox:GetText()
    local presetInput = self.presetInputEditBox:GetText()
    local presetSettings = {
        AutoRespec = ZO_CheckButton_IsChecked(self.presetAutoRespecCheckButton),
    }
    self.DataManager.SetPreset(presetName, presetInput, presetSettings)
end

function InterfaceEditor:PresetEditBoxesOnTextChanged(editBox)
    self:PresetChanged()
    ZO_EditDefaultText_OnTextChanged(editBox)
end

local function SetEditBoxText(editBox, text)
    local suppressCallback = true
    if(editBox:GetText() ~= text) then
        editBox:SetText(text, suppressCallback)
        ZO_EditDefaultText_OnTextChanged(editBox)
    end
end
function InterfaceEditor:SetPresetName(presetName)
    SetEditBoxText(self.presetNameEditBox, presetName)
end
function InterfaceEditor:SetPresetInput(input)
    SetEditBoxText(self.presetInputEditBox, input)
end

function InterfaceEditor:BuildSkillList()
    ZO_ScrollList_AddDataType(self.skillList, 1, "ChampionPointImport_Interface_ChampionDisciplineRow", 26, function(control, data)
        self:SetupDisciplineRow(control, data)
    end)
    ZO_ScrollList_AddDataType(self.skillList, 2, "ChampionPointImport_Interface_ChampionSkillRow", 23, function(control, data)
        self:SetupSkillRow(control, data)
    end)

    local scrollData = ZO_ScrollList_GetDataList(self.skillList)
    for disciplineId, discipline in DataManager:GetDisciplinesIterator() do
        ZO_ScrollList_AddCategory(self.skillList, disciplineId)
        scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(1,
                {
                    labelText = discipline.name,
                    color = ZO_CP_BAR_GLOW_COLORS[GetChampionDisciplineType(disciplineId)]
                },
                disciplineId
        )
        for _, skill in pairs(discipline.skills) do
            scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(2, skill, disciplineId)
        end
    end

    ZO_ScrollList_Commit(self.skillList)
end

function InterfaceEditor:SetupDisciplineRow(control, header)
    local label = control:GetNamedChild("Label")
    label:SetText(header.labelText)
    label:SetColor(header.color:UnpackRGBA())
end

function InterfaceEditor:SetupSkillRow(control, skill)
    -- skill name label
    local label = control:GetNamedChild("Label")
    label:SetText(skill.name)
    label:SetColor(skill.color:UnpackRGBA())

    -- skill current points
    local labelPointsCurrent = control:GetNamedChild("PointsCurrent")
    local pointsSpent = GetNumPointsSpentOnChampionSkill(skill.skillId)
    labelPointsCurrent:SetText("(" .. tostring(pointsSpent) .. ")")

    -- get outcome of calculations
    local disciplineId = skill.disciplineId
    local skillId = skill.skillId
    local outcome = self.DataManager.GetOutcome()
    local skillOutcome = ImportManager.GetOutcomeForSkill(outcome, disciplineId, skillId)

    -- calculations points reached
    local labelPointsReached = control:GetNamedChild("PointsReached")
    local pointsReached = table.concat(skillOutcome.pointsReached or {}, ", ")
    labelPointsReached:SetText("(" .. pointsReached .. ")")

    -- calculations points desired
    local labelPointsDesired = control:GetNamedChild("PointsDesired")
    local pointsDesired = table.concat(skillOutcome.pointsDesired or {}, ", ")
    labelPointsDesired:SetText("(" .. pointsDesired .. ")")

    -- calculations skill slotted
    local textureSlotted = control:GetNamedChild("SlottedIcon")
    local isHidden = not skillOutcome.slot
    textureSlotted:SetHidden(isHidden)
end

function InterfaceEditor:InitializePresetDropdown()
    local function OnSelectionChanged(control, name, entry, selectionChanged)
        self.DataManager.LoadPreset(entry.name)
    end
    local function GetSelectedPreset()
        return self.DataManager.GetSelectedPreset()
    end
    PresetDropdown:New(self.interfaceName, GetSelectedPreset, OnSelectionChanged, self.presetDropdown)
end

function InterfaceEditor:SavePreset()
    DataManager:SavePreset()
end

function InterfaceEditor:DeletePreset()
    DataManager:DeletePreset()
end

function InterfaceEditor:ButtonPresetSaveOnMouseEnter()
    local presetName = self.presetNameEditBox:GetText()
    local isOverwrite = DataManager:IsExistingPresetName(presetName)
    local text = "Save Preset"
    if (isOverwrite) then
        text = "Overwrite Preset"
    end
    SetTooltipText(InformationTooltip, text)
end

function InterfaceEditor:Refresh()
    self:RefreshSkillList()
end

function InterfaceEditor:RefreshSkillList()
    ZO_ScrollList_RefreshVisible(self.skillList)
end

function InterfaceEditor:SetPresetAutoRespec(input)
    input = input or false
    ZO_CheckButton_SetCheckState(self.presetAutoRespecCheckButton, input)
end

function InterfaceEditor:InitializePresetAutoRespecCheckButton()
    self.presetAutoRespecCheckButton.checkedText = "Redistribute On"
    self.presetAutoRespecCheckButton.uncheckedText = "Redistribute Off"

    local function OnClicked()
        self:PresetChanged()
    end

    ZO_CheckButton_SetToggleFunction(self.presetAutoRespecCheckButton, OnClicked)
end

function InterfaceEditor:ButtonLoadOnClicked()
    self.DataManager.Import()
end

CPI.InterfaceEditor = InterfaceEditor:New()