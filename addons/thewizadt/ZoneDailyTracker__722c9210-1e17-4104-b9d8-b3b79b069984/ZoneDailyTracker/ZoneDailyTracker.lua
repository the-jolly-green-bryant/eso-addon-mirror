-------------------------------------------------------------------------------
-- Global Data Store & Addon Name
-------------------------------------------------------------------------------
local rawAddonName = ...
local ADDON_NAME = (type(rawAddonName) == "string" and rawAddonName ~= "") and rawAddonName or "ZoneDailyTracker"

ZoneDailyTracker = ZoneDailyTracker or {}
ZoneDailyDataStore = ZoneDailyDataStore or {}

local PIN_TYPE = "ZoneDailyMarkerPin"
local isInitialized = false

local LMP = LibMapPins

-------------------------------------------------------------------------------
-- Texture Presets
-------------------------------------------------------------------------------
local ICON_PRESETS = {
    ["Red Hostile Dot"]    = "/EsoUI/Art/MapPins/hostile_pin.dds",
    ["Quest Repeatable"]   = "/esoui/art/compass/repeatablequest_available_icon.dds",
    ["Quest Normal"]       = "/EsoUI/Art/Compass/quest_icon.dds",
    ["waypoint Icon"]      = "esoui/art/compass/compass_waypoint.dds",
}

local ICON_CHOICES = {
    "Red Hostile Dot",
    "Quest Repeatable",
    "Quest Normal",
    "waypoint Icon",
}

-------------------------------------------------------------------------------
-- Static Base Layout Table for LibMapPins
-------------------------------------------------------------------------------
local PIN_LAYOUT = {
    level = 200,
    texture = "/EsoUI/Art/MapPins/hostile_pin.dds",
    size = 28,
}

-------------------------------------------------------------------------------
-- Saved Variables & Character Tracking Core
-------------------------------------------------------------------------------
local cachedCharId = nil

local function GetCurrentCharKey()
    if not cachedCharId then
        local rawId = GetCurrentCharacterId()
        cachedCharId = (rawId and rawId ~= "") and tostring(rawId) or GetUnitName("player")
    end
    return cachedCharId
end

local function InitializeSavedVars()
    ZoneDailyTrackerSavedVars = ZoneDailyTrackerSavedVars or {}
    
    if ZoneDailyTrackerSavedVars.showPins == nil then ZoneDailyTrackerSavedVars.showPins = true end
    if ZoneDailyTrackerSavedVars.iconSize == nil then ZoneDailyTrackerSavedVars.iconSize = 28 end
    if ZoneDailyTrackerSavedVars.iconChoice == nil then ZoneDailyTrackerSavedVars.iconChoice = "Red Hostile Dot" end
    if ZoneDailyTrackerSavedVars.useAccountWide == nil then ZoneDailyTrackerSavedVars.useAccountWide = false end
    if ZoneDailyTrackerSavedVars.iconTexture == nil then
        ZoneDailyTrackerSavedVars.iconTexture = ICON_PRESETS[ZoneDailyTrackerSavedVars.iconChoice] or ICON_PRESETS["Red Hostile Dot"]
    end

    ZoneDailyTrackerSavedVars.charactersData = ZoneDailyTrackerSavedVars.charactersData or {}
    
    local charKey = GetCurrentCharKey()
    local charName = GetUnitName("player")

    ZoneDailyTrackerSavedVars.charactersData[charKey] = ZoneDailyTrackerSavedVars.charactersData[charKey] or {
        name = charName,
        activeDailies = {},
        completedDailies = {},
    }
    ZoneDailyTrackerSavedVars.charactersData[charKey].name = charName
    ZoneDailyTrackerSavedVars.charactersData[charKey].completedDailies = ZoneDailyTrackerSavedVars.charactersData[charKey].completedDailies or {}
end

-------------------------------------------------------------------------------
-- Scan Journal on Login / Relog
-------------------------------------------------------------------------------
local function SyncJournalQuests()
    InitializeSavedVars()
    local charKey = GetCurrentCharKey()
    local charDailies = ZoneDailyTrackerSavedVars.charactersData[charKey].activeDailies

    local numEntries = GetNumJournalQuests()
    for i = 1, numEntries do
        local questName = GetJournalQuestName(i)
        local questId = GetJournalQuestId(i)

        if questId and questId > 0 then
            charDailies[tonumber(questId)] = true
            charDailies[tostring(questId)] = true
        end

        if questName and questName ~= "" then
            charDailies[questName] = true
        end
    end
end

local function GetActiveAndCompletedTrackedTable()
    InitializeSavedVars()
    
    local combined = {}
    
    local function MergeTable(source)
        if not source then return end
        for k, v in pairs(source) do
            if v then combined[k] = true end
        end
    end

    if ZoneDailyTrackerSavedVars.useAccountWide then
        for _, charData in pairs(ZoneDailyTrackerSavedVars.charactersData) do
            if charData then
                MergeTable(charData.activeDailies)
                MergeTable(charData.completedDailies)
            end
        end
    else
        local charKey = GetCurrentCharKey()
        local charData = ZoneDailyTrackerSavedVars.charactersData[charKey]
        if charData then
            MergeTable(charData.activeDailies)
            MergeTable(charData.completedDailies)
        end
    end

    return combined
end

-------------------------------------------------------------------------------
-- Helper: Hide Pin Check
-------------------------------------------------------------------------------
local function IsPinHidden(target)
    if not target or not ZoneDailyTrackerSavedVars then return false end
    if not ZoneDailyTrackerSavedVars.showPins then return true end

    local tracked = GetActiveAndCompletedTrackedTable()
    if not tracked then return false end

    -- 1. Multiple Quest IDs Evaluation
    if target.questIds and type(target.questIds) == "table" and #target.questIds > 0 then
        if target.requireAll then
            for _, questId in ipairs(target.questIds) do
                local numId = tonumber(questId)
                local strId = tostring(questId)
                if not (tracked[numId] or tracked[strId]) then return false end
            end
            return true
        else
            for _, questId in ipairs(target.questIds) do
                local numId = tonumber(questId)
                local strId = tostring(questId)
                if tracked[numId] or tracked[strId] then return true end
            end
        end
    end

    -- 2. Single Quest ID Evaluation
    if target.questId then
        local numId = tonumber(target.questId)
        local strId = tostring(target.questId)
        if tracked[numId] or tracked[strId] then return true end
    end

    -- 3. Quest Giver / Quest Name Evaluation
    local pinName = target.questName or target.name
    if pinName and pinName ~= "" then
        local lowerPin = tostring(pinName):lower()
        for trackedKey, isPresent in pairs(tracked) do
            if isPresent then
                local lowerTracked = tostring(trackedKey):lower()
                if lowerPin == lowerTracked or lowerPin:find(lowerTracked, 1, true) or lowerTracked:find(lowerPin, 1, true) then
                    return true
                end
            end
        end
    end

    return false
end

-------------------------------------------------------------------------------
-- Helper: Validate Active Map Context
-------------------------------------------------------------------------------
local function GetStrictSubMapKey()
    local rawMapTexture = (GetMapTileTexture() or ""):lower()
    local fileName = rawMapTexture:match("art/maps/[^/]+/(.+)%.dds")
    if not fileName then return "" end

    local cleanName = fileName:gsub("%d+$", ""):gsub("_$", ""):gsub("_base$", "")

    if GetMapType() == MAPTYPE_ZONE then
        return cleanName .. "_main"
    end

    return cleanName
end

-------------------------------------------------------------------------------
-- Clean Map Refresh Handler
-------------------------------------------------------------------------------
local function HardRefreshPins()
    local mapPins = LMP or LibMapPins
    if not mapPins then return end
    mapPins:RefreshPins(PIN_TYPE)
end

-------------------------------------------------------------------------------
-- Update Pin Layout Parameters Dynamically
-------------------------------------------------------------------------------
local function UpdatePinLayout()
    local mapPins = LMP or LibMapPins
    if not mapPins then return end

    local texture = ZoneDailyTrackerSavedVars.iconTexture or ICON_PRESETS["Red Hostile Dot"]
    local size = ZoneDailyTrackerSavedVars.iconSize or 28

    PIN_LAYOUT.texture = texture
    PIN_LAYOUT.size = size

    if mapPins.SetLayoutKey then
        mapPins:SetLayoutKey(PIN_TYPE, "texture", texture)
        mapPins:SetLayoutKey(PIN_TYPE, "size", size)
    end

    HardRefreshPins()
end

-------------------------------------------------------------------------------
-- Quest Pickup & Abandon/Completion Event Tracking
-------------------------------------------------------------------------------
local function OnQuestAdded(eventCode, journalIndex, questName, objectiveName)
    InitializeSavedVars()

    local charKey = GetCurrentCharKey()
    local charDailies = ZoneDailyTrackerSavedVars.charactersData[charKey].activeDailies
    local questId = GetJournalQuestId(journalIndex)

    if questId and questId > 0 then
        charDailies[tonumber(questId)] = true
        charDailies[tostring(questId)] = true
    end

    if questName and questName ~= "" then
        charDailies[questName] = true
    end

    HardRefreshPins()
end

local function OnQuestRemoved(eventCode, isCompleted, journalIndex, questName, zoneIndex, poiIndex, questId)
    InitializeSavedVars()

    local charKey = GetCurrentCharKey()
    local charData = ZoneDailyTrackerSavedVars.charactersData[charKey]
    local activeDailies = charData.activeDailies
    local completedDailies = charData.completedDailies

    local numId = questId and tonumber(questId)
    local strId = questId and tostring(questId)

    if isCompleted then
        -- Mark as completed so the dot stays hidden
        if numId and numId > 0 then completedDailies[numId] = true end
        if strId and strId ~= "0" then completedDailies[strId] = true end
        if questName and questName ~= "" then completedDailies[questName] = true end
    else
        -- Abandoned: Clear completion and active state so the dot reappears
        if numId then completedDailies[numId] = nil end
        if strId then completedDailies[strId] = nil end
        if questName then completedDailies[questName] = nil end
    end

    -- Always remove from active journal records
    if numId then activeDailies[numId] = nil end
    if strId then activeDailies[strId] = nil end
    if questName then activeDailies[questName] = nil end

    HardRefreshPins()
end

-------------------------------------------------------------------------------
-- Pin Provider Callback
-------------------------------------------------------------------------------
local function PinTypeAddCallback(pinManager)
    local mapPins = LMP or LibMapPins
    if not ZoneDailyDataStore or not mapPins then return end

    local activeKey = GetStrictSubMapKey()
    local mapData = ZoneDailyDataStore[activeKey]

    if not mapData then return end

    for i, target in ipairs(mapData) do
        local pinX = tonumber(target.x)
        local pinY = tonumber(target.y)

        if not IsPinHidden(target) then
            if pinX and pinY and pinX >= 0 and pinX <= 1 and pinY >= 0 and pinY <= 1 then
                mapPins:CreatePin(PIN_TYPE, target, pinX, pinY)
            end
        end
    end
end

-------------------------------------------------------------------------------
-- Settings Menu Construction (LibAddonMenu-2.0)
-------------------------------------------------------------------------------
local function BuildSettingsMenu()
    local LAM = LibAddonMenu2 or (LibStub and LibStub("LibAddonMenu-2.0", true))
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "ZoneDailyTracker_OptionsPanel",
        displayName = "|c00FF00Zone Daily Tracker|r",
        author = "wizadt",
        version = "1.2.2",
        registerForRefresh = true,
    }

    local optionsData = {
        {
            type = "header",
            name = "Map Pin Settings",
        },
        {
            type = "checkbox",
            name = "Enable Map Pins",
            tooltip = "Toggle display of zone daily quest giver pins on the map.",
            getFunc = function() return ZoneDailyTrackerSavedVars.showPins end,
            setFunc = function(value)
                ZoneDailyTrackerSavedVars.showPins = value
                local mapPins = LMP or LibMapPins
                if mapPins then mapPins:SetEnabled(PIN_TYPE, value) end
                HardRefreshPins()
            end,
            default = true,
        },
        {
            type = "dropdown",
            name = "Icon Texture Choice",
            tooltip = "Select the map pin icon style.",
            choices = ICON_CHOICES,
            getFunc = function() return ZoneDailyTrackerSavedVars.iconChoice end,
            setFunc = function(selectedName)
                ZoneDailyTrackerSavedVars.iconChoice = selectedName
                ZoneDailyTrackerSavedVars.iconTexture = ICON_PRESETS[selectedName] or ICON_PRESETS["Red Hostile Dot"]
                UpdatePinLayout()
            end,
            default = "Red Hostile Dot",
        },
        {
            type = "slider",
            name = "Icon Size",
            tooltip = "Adjust the rendered size of the map pin icons.",
            min = 12,
            max = 64,
            step = 1,
            getFunc = function() return ZoneDailyTrackerSavedVars.iconSize end,
            setFunc = function(value)
                ZoneDailyTrackerSavedVars.iconSize = value
                UpdatePinLayout()
            end,
            default = 28,
        },
    }

    local panelControl = LAM:RegisterAddonPanel("ZoneDailyTracker_OptionsPanel", panelData)
    LAM:RegisterOptionControls("ZoneDailyTracker_OptionsPanel", optionsData)
end

-------------------------------------------------------------------------------
-- Addon Initialization & Handlers
-------------------------------------------------------------------------------
local function InitializeAddon()
    if isInitialized then return end

    LMP = LMP or LibMapPins
    if not LMP then return end

    InitializeSavedVars()
    SyncJournalQuests()
    isInitialized = true

    PIN_LAYOUT.texture = ZoneDailyTrackerSavedVars.iconTexture
    PIN_LAYOUT.size = ZoneDailyTrackerSavedVars.iconSize

    LMP:AddPinType(
        PIN_TYPE,
        PinTypeAddCallback,
        nil,
        PIN_LAYOUT
    )

    LMP:SetEnabled(PIN_TYPE, ZoneDailyTrackerSavedVars.showPins)

    CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", HardRefreshPins)

    -- Register Quest Add / Remove listeners
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_QuestAdded", EVENT_QUEST_ADDED, OnQuestAdded)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_QuestRemoved", EVENT_QUEST_REMOVED, OnQuestRemoved)

    BuildSettingsMenu()
end

-------------------------------------------------------------------------------
-- Event Registration
-------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_OnLoaded", EVENT_ADDON_LOADED, function(event, loadedAddonName)
    if loadedAddonName == ADDON_NAME then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_OnLoaded", EVENT_ADDON_LOADED)
        InitializeAddon()
    end
end)

EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_OnActivated", EVENT_PLAYER_ACTIVATED, function()
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_OnActivated", EVENT_PLAYER_ACTIVATED)
    if not isInitialized then
        InitializeAddon()
    else
        SyncJournalQuests()
        HardRefreshPins()
    end
end)