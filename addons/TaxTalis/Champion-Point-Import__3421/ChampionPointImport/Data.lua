-----------------------------------------------------------------------------------
-- Addon Name: Champion Point Import
-- Creator: TaxTalis
-- Addon Ideal: Import Champion Points from text
-- Addon Creation Date: 2022-06-20
--
-- File Name: Data.lua
-- File Description: This file contains the saved variable data handler
-- Load Order Requirements: TBD
--
-----------------------------------------------------------------------------------
local CPI = ChampionPointImport
local CP = CPI.Import(CHAMPION_PERKS)
local ImportManager = CPI.Import(CPI.ImportManager)

local function GetKeyIterator(...)
    local keys = {}
    local tables = {...}
    for _, table in pairs(tables) do
        for key in pairs(table) do
            keys[key] = true
        end
    end
    return pairs(keys)
end

local function strip(String)
    return String:gsub('’', ''):gsub('[^%w%s%c]+', ''):lower()
end

local accountSavedVariableVersion = 0
local characterSavedVariableVersion = 0

-- credit to sirinsidiator
local MAX_SAVE_DATA_LENGTH = 1999 -- buffer length used by ZOS
local function WriteToSavedVariable(presetData, presetName, presetInput, presetSettings)
    local input = presetInput
    if (presetInput) then
        local byteLength = #presetInput
        if (byteLength > MAX_SAVE_DATA_LENGTH) then
            input = {}
            local startPos = 1
            local endPos = startPos + MAX_SAVE_DATA_LENGTH - 1
            while startPos <= byteLength do
                input[#input + 1] = presetInput:sub(startPos, endPos)
                startPos = endPos + 1
                endPos = startPos + MAX_SAVE_DATA_LENGTH - 1
            end
        end
    end
    presetData[presetName] = {input = input, settings = presetSettings}
end
-- credit to sirinsidiator
local function ReadFromSavedVariable(presetData, presetName)
    local presetInput, presetSettings
    local data = presetData[presetName]
    if(data) then
        presetInput = data.input
        if (type(presetInput) == "table") then
            presetInput = table.concat(presetInput, "")
        end
        presetSettings = data.settings
    else
        presetName = ""
    end
    return presetName, presetInput or "", presetSettings or {}
end

local defaultAccount = {
    presetData = {},
    editorData = {},
}
local defaultCharacter = {
    presetData = {},
    armoryBuildPresetNames = {},
}

local DataManager = ZO_InitializingCallbackObject:Subclass()
function DataManager:GetInitializationTime()
    return self.initializationTime
end

function DataManager:Initialize()
    local startTime = GetGameTimeMilliseconds()
    self.outcome = self.outcome or {}
    self.interfaceDataManager = self.interfaceDataManager or {}
    self:InitializeDisciplines()

    self.account = self.account or defaultAccount
    self.character = self.character or defaultCharacter

    self:FireCallbacks("Initialize")

    self.initializationTime = GetGameTimeMilliseconds() - startTime
end
function DataManager:LoadSavedVariables()
    self.account = ZO_SavedVars:NewAccountWide(
            "CPIAccount",
            accountSavedVariableVersion,
            nil,
            defaultAccount
    )
    self.character = ZO_SavedVars:New(
            "CPICharacter",
            characterSavedVariableVersion,
            nil,
            defaultCharacter,
            nil,
            GetDisplayName(),
            GetUnitName("player"),
            GetCurrentCharacterId(),
            ZO_SAVED_VARS_CHARACTER_ID_KEY
    )
    self:Initialize()
end

-------------------------------------------
--- PRESETS -------------------------------
-------------------------------------------
function DataManager:GetPresetNamesIterator()
    local presetData = self.account.presetData
    local presets = {}
    for presetName in pairs(presetData) do
        presets[presetName] = true
    end
    return pairs(presets)
end
function DataManager:SavePreset()
    local dataManager = self:GetInterfaceEditorDataManager()
    local presetName, presetInput, presetSettings = dataManager.GetPreset()

    local presetData = self.account.presetData
    local isNew = presetData[presetName] == nil
    WriteToSavedVariable(presetData, presetName, presetInput, presetSettings)
    if (isNew) then
        self:FireCallbacks("PresetAdded", presetName)
    end
    self:FireCallbacks("EditorPresetUpdated")
end
function DataManager:DeletePreset()
    local dataManager = self:GetInterfaceEditorDataManager()
    local presetName = dataManager.GetPreset()
    if(self:IsExistingPresetName(presetName)) then
        local presetData = self.account.presetData
        presetData[presetName] = nil
        self:FireCallbacks("PresetDeleted")
    end
end
function DataManager:GetPresetByPresetName(presetName)
    local presetData = self.account.presetData
    return ReadFromSavedVariable(presetData, presetName)
end
function DataManager:IsExistingPreset(presetName, presetInput, presetSettings)
    local existingName, existingInput, existingSettings = self:GetPresetByPresetName(presetName)
    if(presetName ~= existingName or presetInput ~= existingInput) then
        return false
    end
    for key in GetKeyIterator(existingSettings, presetSettings) do
        if(presetSettings[key] ~= existingSettings[key]) then
            return false
        end
    end
    return true
end
function DataManager:IsExistingPresetName(presetName)
    return presetName and self.account.presetData[presetName] ~= nil
end
function DataManager:IsExistingPresetInput(presetInput)
    local isExisting = false
    local presetData = self.account.presetData
    for validPresetName in pairs(presetData) do
        local _, validPresetInput = self:GetPresetByPresetName(validPresetName)
        if(presetInput == validPresetInput) then
            isExisting = true
            break
        end
    end
    return isExisting
end
function DataManager:GetPresetInputForPresetName(presetName)
    local _, presetInput = self:GetPresetByPresetName(presetName)
    return presetInput
end
function DataManager:GetPresetNameForPresetInput(presetInput)
    local presetName = ""
    local presetData = self.account.presetData
    for validPresetName in pairs(presetData) do
        local _, validPresetInput = self:GetPresetByPresetName(validPresetName)
        if(presetInput == validPresetInput) then
            presetName = validPresetName
            break
        end
    end
    return presetName
end
function DataManager:GetPresetByName(presetName)
    local presetInput, presetSettings
    local presetData = self.account.presetData
    presetName, presetInput, presetSettings = ReadFromSavedVariable(presetData, presetName)
    return presetName, presetInput, presetSettings
end


-------------------------------------------
--- INTERFACE DATA MANAGER ----------------
-------------------------------------------
local function FireCallbacks(self, interfaceName, callbackName, callbackData)
    self:FireCallbacks(interfaceName .. callbackName, callbackData)
end
local function GetPreset(presetData)
    local returnPresetName, returnPresetInput, returnPresetSettings = "", "", {}
    for presetName in pairs(presetData) do
        returnPresetName, returnPresetInput, returnPresetSettings = ReadFromSavedVariable(presetData, presetName)
        break
    end
    return returnPresetName, returnPresetInput, returnPresetSettings
end
local function GetPresetSetting(presetData, setting)
    local presetName, presetInput, presetSettings = GetPreset(presetData)
    return presetSettings[setting]
end
local function GetSelectedPreset(self, presetData)
    local returnPresetName, returnPresetInput, returnPresetSettings = "", "", {}
    local presetName, presetInput, presetSettings = GetPreset(presetData)
    if(self:IsExistingPreset(presetName, presetInput, presetSettings)) then
        returnPresetName, returnPresetInput, returnPresetSettings = presetName, presetInput, presetSettings
    end
    return returnPresetName, returnPresetInput, returnPresetSettings
end

local function SetPreset(self, interfaceName, presetData, presetName, presetInput, presetSettings)
    local oldPresetName, oldPresetInput, oldPresetSettings = GetPreset(presetData)
    presetData[oldPresetName] = nil
    WriteToSavedVariable(presetData, presetName, presetInput, presetSettings)
    if(oldPresetName ~= presetName) then
        FireCallbacks(self, interfaceName, "PresetName", presetName)
    end
    if(oldPresetInput ~= presetInput) then
        FireCallbacks(self, interfaceName, "PresetInput", presetInput)
    end
    for key in GetKeyIterator(oldPresetSettings, presetSettings) do
        if(not oldPresetSettings[key] or oldPresetSettings[key] ~= presetSettings[key]) then
            FireCallbacks(self, interfaceName, key, presetSettings[key])
        end
    end
    FireCallbacks(self, interfaceName,"PresetUpdated")
end
local function Import(self, interfaceName, presetData)
    local _, presetInput = GetPreset(presetData)
    local import = ImportManager.Import(self.skillsByName, presetInput)
    self.outcome[interfaceName] = ImportManager.Calculate(self.disciplines, import)
    FireCallbacks(self, interfaceName, "SkillList")
    FireCallbacks(self, interfaceName, "Redistribute")
end
local function LoadPreset(self, interfaceName, presetData, presetName)
    local presetName, presetInput, presetSettings = self:GetPresetByName(presetName)
    SetPreset(self, interfaceName, presetData, presetName, presetInput, presetSettings)
    Import(self, interfaceName, presetData)
end
local function Initialize(self, interfaceName, presetData)
    local presetName, presetInput, presetSettings = GetPreset(presetData)
    if(self:IsExistingPreset(presetName, presetInput, presetSettings)) then
        Import(self, interfaceName, presetData, presetName)
    end
    FireCallbacks(self, interfaceName, "PresetName", presetName)
    FireCallbacks(self, interfaceName, "PresetInput", presetInput)
    for key in GetKeyIterator(presetSettings) do
        FireCallbacks(self, interfaceName, key, presetSettings[key])
    end
    FireCallbacks(self, interfaceName,"PresetUpdated")
end
local function GetOutcome(self, interfaceName)
    return self.outcome[interfaceName] or {}
end
local function IsRespecNeeded(self, interfaceName)
    local outcome = GetOutcome(self, interfaceName)
    return ImportManager.IsRespecNeeded(outcome)
end
local function IsEqualToCurrent(self, interfaceName)
    local outcome = GetOutcome(self, interfaceName)
    return ImportManager.IsEqualToCurrent(outcome)
end
local function Redistribute(self, interfaceName, allowRespec)
    local outcome = GetOutcome(self, interfaceName)
    ImportManager.Redistribute(outcome, allowRespec)
end

local function CreateInterfaceDataManager(self, interfaceName, presetDataFunction)
    if(not self.interfaceDataManager[interfaceName]) then
        local object = {}
        object.FireCallbacks = function(...) return FireCallbacks(self, interfaceName, ...) end
        object.GetPreset = function(...) return GetPreset(presetDataFunction(), ...) end
        object.GetPresetSetting = function(...) return GetPresetSetting(presetDataFunction(), ...) end
        object.GetSelectedPreset = function(...) return GetSelectedPreset(self, presetDataFunction(), ...) end
        object.SetPreset = function(...) return SetPreset(self, interfaceName, presetDataFunction(), ...) end
        object.Import = function(...) return Import(self, interfaceName, presetDataFunction(), ...) end
        object.LoadPreset = function(...) return LoadPreset(self, interfaceName, presetDataFunction(), ...) end
        object.Initialize = function(...) return Initialize(self, interfaceName, presetDataFunction(), ...) end
        object.GetOutcome = function(...) return GetOutcome(self, interfaceName, ...) end
        object.IsRespecNeeded = function(...) return IsRespecNeeded(self, interfaceName, ...) end
        object.IsEqualToCurrent = function(...) return IsEqualToCurrent(self, interfaceName, ...) end
        object.Redistribute = function(...) return Redistribute(self, interfaceName, ...) end
        self.interfaceDataManager[interfaceName] = object
    end
    return self.interfaceDataManager[interfaceName]
end

function DataManager:GetInterfaceEditorDataManager()
    local interfaceName = "Editor"
    local function PresetDataFunction()
        return self.account.editorData
    end
    return CreateInterfaceDataManager(self, interfaceName, PresetDataFunction)
end
function DataManager:GetInterfaceMainDataManager()
    local interfaceName = "Main"
    local function PresetDataFunction()
        return self.character.presetData
    end
    return CreateInterfaceDataManager(self, interfaceName, PresetDataFunction)
end

-------------------------------------------
--- ARMORY --------------------------------
-------------------------------------------
function DataManager:GetPresetForArmoryBuild(buildIndex)
    local presetName = self.character.armoryBuildPresetNames[buildIndex]
    if(not self:IsExistingPresetName(presetName)) then
        self.character.armoryBuildPresetNames[buildIndex] = nil
        presetName = ""
    end
    return presetName
end
function DataManager:SavePresetForArmoryBuild(buildIndex, presetName)
    self.character.armoryBuildPresetNames[buildIndex] = presetName
end
function DataManager:RemovePresetForArmoryBuild(buildIndex)
    self.character.armoryBuildPresetNames[buildIndex] = nil
    FireCallbacks(self, "Armory" .. tostring(buildIndex), "PresetUpdated")
end
function DataManager:LoadPresetForArmoryBuild(buildIndex)
    local presetName = self:GetPresetForArmoryBuild(buildIndex)
    local dataManager = self:GetInterfaceMainDataManager()
    dataManager.LoadPreset(presetName)
    local allowRespec = dataManager.GetPresetSetting("AutoRespec") or false
    dataManager.Redistribute(allowRespec)
end

-------------------------------------------
--- DISCIPLINES AND SKILLS ----------------
-------------------------------------------
function DataManager:InitializeDisciplines()
    if(not self.disciplines or not self.skillsByName) then
        local disciplines = {}
        local skillsByName = {}
        for disciplineIndex = 1, GetNumChampionDisciplines() do
            local disciplineId = GetChampionDisciplineId(disciplineIndex)
            local name = GetChampionDisciplineName(disciplineId)
            local color = ZO_CP_BAR_GLOW_COLORS[GetChampionDisciplineType(disciplineId)]
            local skills = {}
            for skillIndex = 1, GetNumChampionDisciplineSkills(disciplineIndex) do
                local skillId = GetChampionSkillId(disciplineIndex, skillIndex)
                local name = GetChampionSkillName(skillId)
                local type = GetChampionSkillType(skillId)
                local isSlottable = CanChampionSkillTypeBeSlotted(type)
                local skill = {
                    disciplineId = disciplineId,
                    skillId = skillId,
                    name = name,
                    color = color,
                    isSlottable = isSlottable,
                }
                skills[#skills + 1] = skill
                skillsByName[strip(name)] = skill
            end
            table.sort(skills, function(a, b)
                return a.name < b.name
            end)

            local bar = {}
            local championBar = CP:GetChampionBar()
            for slotIndex = championBar:GetFirstSlotIndexForDiscipline(disciplineId), championBar:GetNumSlots() do
                if (disciplineId ~= GetRequiredChampionDisciplineIdForSlot(slotIndex, HOTBAR_CATEGORY_CHAMPION)) then
                    break
                end
                bar[slotIndex] = true
            end

            disciplines[disciplineId] = { name = name, skills = skills, bar = bar, color = color }
        end
        self.disciplines = disciplines
        self.skillsByName = skillsByName
    end
end
function DataManager:GetDisciplinesIterator()
    return pairs(self.disciplines or {})
end
function DataManager:GetSkillsByNameIterator()
    return pairs(self.skillsByName or {})
end

-------------------------------------------
--- INITIALIZE ----------------------------
-------------------------------------------
CPI.DataManager = DataManager:New()

local function initialize()
    CPI.DataManager:LoadSavedVariables()
    if (CPI.debugFlag) then
        d("ChampionManager initialized in " .. tostring(CPI.DataManager:GetInitializationTime()) .. "ms")
    end
end
CPI.addInitialize(initialize)