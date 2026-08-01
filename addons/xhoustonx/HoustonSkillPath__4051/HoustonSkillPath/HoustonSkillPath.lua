HoustonSkillPath = HoustonSkillPath or {}
HoustonSkillPath.name = "HoustonSkillPath"
HoustonSkillPath.version = "1.7"

-- Default settings for SavedVars
local defaultSettings = {
    hideGold = false,
    hidePurple = false,
    hideBlue = false,
    hideGreen = false
}

-- Funkcja inicjalizująca SavedVariables
local function InitializeSavedVars()
    HoustonSkillPath.savedVars = ZO_SavedVars:NewAccountWide("HoustonSkillPath_SavedVariables", 1, nil, defaultSettings)
    
    -- Zapewnia, że każda nowa opcja domyślna zostanie dodana do istniejących zapisanych zmiennych
    for key, value in pairs(defaultSettings) do
        if HoustonSkillPath.savedVars[key] == nil then
            HoustonSkillPath.savedVars[key] = value
        end
    end
end

-- Ensure skillTable and skillData are loaded
HoustonSkillPath.skillTable = HoustonSkillPath.skillTable or {}
HoustonSkillPath.skillData = HoustonSkillPath.skillData or {}

-- Definicja kategorii CP dla priorytetowego sortowania
local prioritySkills = {
    ["Deadly Aim (only while slotted)"] = true,
    ["Master-at-Arms (only while slotted)"] = true,
    ["Biting Aura (only while slotted)"] = true,
    ["Thaumaturge (only while slotted)"] = true
}

local prioritySecondary = {
    ["Backstabber (only while slotted)"] = true,
    ["Fighting Finesse (only while slotted)"] = true,
    ["Wrathful Strikes (only while slotted)"] = true
}

-- Pobiera nazwę skilla na podstawie jego ID (z skillData.lua)
local function GetSkillNameFromID(abilityId)
    if not abilityId then return nil end
    return HoustonSkillPath.skillData[tostring(abilityId)]
end


-- Pobiera CP na podstawie nazwy skilla (z skillTable.lua)
local function GetCPForSkill(skillName)
    return HoustonSkillPath.skillTable[skillName]
end

-- Funkcja dodająca informacje o CP do tooltipa
local function AddSkillInfoToTooltip(tooltip, abilityId)
    local skillName = GetSkillNameFromID(abilityId)
    local recommendedCP = skillName and GetCPForSkill(skillName) or nil

    local skillCategories = {
        priorityMain = {},
        prioritySecondary = {},
        priorityTertiary = {},
        otherSkills = {}
    }

    -- Jeśli skill nie ma CP lub jego wartość to "N/A"
    if not skillName or not recommendedCP or #recommendedCP == 0 or recommendedCP[1] == "N/A" then

        tooltip:AddVerticalPadding(5)
        tooltip:AddLine("|cFF2222        No Recommended CP |r", "ZoFontWinH3", 1, 1, 1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
        tooltip:AddVerticalPadding(5)
        return -- Zatrzymuje dalsze dodawanie CP
    end

    for _, cpName in ipairs(recommendedCP) do
        if prioritySkills[cpName] then
            table.insert(skillCategories.priorityMain, "|cFFD700 - " .. cpName .. "|r")
        elseif prioritySecondary[cpName] then
            table.insert(skillCategories.prioritySecondary, "|c800080 - " .. cpName .. "|r")
        elseif string.find(cpName, "(only while slotted)") then
            table.insert(skillCategories.priorityTertiary, "|c00BFFF - " .. cpName .. "|r")
        else
            table.insert(skillCategories.otherSkills, "|c00FF00 - " .. cpName .. "|r")
        end
    end

    tooltip:AddVerticalPadding(10)
    tooltip:AddLine("|cFFFFFFRecommended CP:|r", "ZoFontWinH4", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)

    -- Pozostałe kategorie CP z możliwością ukrywania
    if not HoustonSkillPath.savedVars.hideGold then
        for _, cp in ipairs(skillCategories.priorityMain) do
            tooltip:AddLine(cp, "ZoFontWinH4", 1, 1, 1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
        end
    end
    if not HoustonSkillPath.savedVars.hidePurple then
        for _, cp in ipairs(skillCategories.prioritySecondary) do
            tooltip:AddLine(cp, "ZoFontGameBold", 1, 1, 1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
        end
    end
    if not HoustonSkillPath.savedVars.hideBlue then
        for _, cp in ipairs(skillCategories.priorityTertiary) do
            tooltip:AddLine(cp, "ZoFontGameBold", 1, 1, 1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
        end
    end
    if not HoustonSkillPath.savedVars.hideGreen then
        for _, cp in ipairs(skillCategories.otherSkills) do
            tooltip:AddLine(cp, "ZoFontGame", 1, 1, 1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
        end
    end

    tooltip:AddLine("|c888888Source: https://eso-hub.com/|r", "ZoFontGame", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
end

-- Hook do przechwycenia tooltipa, aby dodać CP bez nadpisywania innych addonów
local isHooked = false

local function HookTooltips()
    if isHooked then return end -- Zapobiega wielokrotnemu hookowaniu
    isHooked = true

    SecurePostHook(ZO_ActiveSkillProgressionData, "SetKeyboardTooltip", function(self, tooltip, ...)
        local skillType, skillLineIndex, skillIndex = self:GetIndices()
        local abilityId = GetSpecificSkillAbilityInfo(skillType, skillLineIndex, skillIndex, self:GetMorphSlot(), 4)

        if type(abilityId) == "number" and abilityId > 0 then
            AddSkillInfoToTooltip(tooltip, abilityId)
        end
        
    end)
end

-- Funkcja obsługująca komendę /hcp do przełączania widoczności CP
local function ToggleCPVisibility(arg, varName, color)
    HoustonSkillPath.savedVars[varName] = not HoustonSkillPath.savedVars[varName]
    d(string.format("|cFFD700[HoustonSkillPath]|r %s CP is now %s", color, HoustonSkillPath.savedVars[varName] and "|cFF2222HIDDEN|r" or "|c22FF22VISIBLE|r"))

end

SLASH_COMMANDS["/hcp"] = function(args)
    local arg = string.lower(args)
    if arg == "gold" then
        ToggleCPVisibility(arg, "hideGold", "Gold")
    elseif arg == "purple" then
        ToggleCPVisibility(arg, "hidePurple", "Purple")
    elseif arg == "blue" then
        ToggleCPVisibility(arg, "hideBlue", "Blue")
    elseif arg == "green" then
        ToggleCPVisibility(arg, "hideGreen", "Green")
    else
        d("[HoustonSkillPath] Invalid option! Use: /hcp [gold/purple/blue/green] to toggle CP visibility.")
    end
end


-- Funkcja wywoływana po załadowaniu addona
local function OnAddOnLoaded(event, addonName)
    if addonName ~= HoustonSkillPath.name then return end
    EVENT_MANAGER:UnregisterForEvent(HoustonSkillPath.name, EVENT_ADD_ON_LOADED)
    InitializeSavedVars()
    zo_callLater(HookTooltips, 100)
end


EVENT_MANAGER:RegisterForEvent(HoustonSkillPath.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
