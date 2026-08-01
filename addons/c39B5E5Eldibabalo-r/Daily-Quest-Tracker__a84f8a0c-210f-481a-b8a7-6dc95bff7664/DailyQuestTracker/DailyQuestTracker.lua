-- =============================================================================
-- Daily Quest Tracker v1.2.4
-- Track daily quest completion across all ESO zones.
-- Console/gamepad ready via ZO_Scene + GAMEPAD_DRIVEN_UI_WINDOW.
-- =============================================================================

DQT = DQT or {}
DQT.name    = "DailyQuestTracker"
DQT.version = "1.2.4"

DQT.savedVars    = nil
DQT.zoneList     = {}
DQT.filteredList = {}
DQT.searchText   = ""

-- ---------------------------------------------------------------------------
-- Keybinding strings
-- ---------------------------------------------------------------------------
ZO_CreateStringId("SI_BINDING_NAME_DQT_TOGGLE",      "Toggle Daily Quest Tracker")
ZO_CreateStringId("SI_BINDING_NAME_DQT_SCROLL_UP",   "Scroll Up")
ZO_CreateStringId("SI_BINDING_NAME_DQT_SCROLL_DOWN", "Scroll Down")
ZO_CreateStringId("SI_BINDING_NAME_DQT_CLOSE",       "Close Tracker")

-- ═══════════════════════════════════════════════════════════════════════════
-- DAILY QUEST ZONE DATABASE
-- ═══════════════════════════════════════════════════════════════════════════

DQT.ZONE_DATABASE = {
    { zone = "Undaunted Pledges",   dailyCount = 3,  category = "Guilds" },
    { zone = "Fighters Guild",     dailyCount = 1,  category = "Guilds" },
    { zone = "Mages Guild",        dailyCount = 1,  category = "Guilds" },

    { zone = "Craglorn",           dailyCount = 6,  category = "Base Game" },
    { zone = "Cyrodiil",           dailyCount = 10, category = "PvP" },
    { zone = "Imperial City",      dailyCount = 6,  category = "PvP" },

    { zone = "Wrothgar",           dailyCount = 6,  category = "DLC" },
    { zone = "Gold Coast",         dailyCount = 2,  category = "DLC" },
    { zone = "Hew's Bane",         dailyCount = 2,  category = "DLC" },

    { zone = "Vvardenfell",        dailyCount = 7,  category = "Chapter" },
    { zone = "Clockwork City",     dailyCount = 6,  category = "DLC" },
    { zone = "Summerset",          dailyCount = 7,  category = "Chapter" },
    { zone = "Murkmire",           dailyCount = 2,  category = "DLC" },
    { zone = "Northern Elsweyr",   dailyCount = 7,  category = "Chapter" },
    { zone = "Southern Elsweyr",   dailyCount = 2,  category = "DLC" },
    { zone = "Western Skyrim",     dailyCount = 7,  category = "Chapter" },
    { zone = "The Reach",          dailyCount = 2,  category = "DLC" },
    { zone = "Blackwood",          dailyCount = 7,  category = "Chapter" },
    { zone = "Deadlands",          dailyCount = 2,  category = "DLC" },
    { zone = "High Isle",          dailyCount = 7,  category = "Chapter" },
    { zone = "Galen",              dailyCount = 2,  category = "DLC" },
    { zone = "Telvanni Peninsula", dailyCount = 7,  category = "Chapter" },
    { zone = "Apocrypha",          dailyCount = 2,  category = "DLC" },
    { zone = "West Weald",         dailyCount = 7,  category = "Chapter" },
    { zone = "Gold Road",          dailyCount = 2,  category = "DLC" },
}

-- ═══════════════════════════════════════════════════════════════════════════
-- CONSTANTS
-- ═══════════════════════════════════════════════════════════════════════════

DQT.STATUS_NOT_STARTED = 0
DQT.STATUS_IN_PROGRESS = 1
DQT.STATUS_COMPLETE    = 2

DQT.STATUS_COLORS = {
    [DQT.STATUS_NOT_STARTED] = "888888",
    [DQT.STATUS_IN_PROGRESS] = "3A92FF",
    [DQT.STATUS_COMPLETE]    = "2DC50E",
}

DQT.STATUS_LABELS = {
    [DQT.STATUS_NOT_STARTED] = "Not Started",
    [DQT.STATUS_IN_PROGRESS] = "In Progress",
    [DQT.STATUS_COMPLETE]    = "All Done!",
}

DQT.CATEGORY_COLORS = {
    ["Guilds"]    = "A02EF7",
    ["Base Game"] = "FFFFFF",
    ["PvP"]       = "E53935",
    ["DLC"]       = "3A92FF",
    ["Chapter"]   = "EECA2A",
}

-- ═══════════════════════════════════════════════════════════════════════════
-- DAILY RESET (06:00 UTC)
-- ═══════════════════════════════════════════════════════════════════════════

local DAILY_RESET_HOUR_UTC = 6

local function GetCurrentResetDay()
    local ts = GetTimeStamp()
    local utcHour = (math.floor(ts / 3600)) % 24
    if utcHour < DAILY_RESET_HOUR_UTC then
        ts = ts - 86400
    end
    return math.floor(ts / 86400)
end

function DQT:CheckDailyReset()
    local today = GetCurrentResetDay()
    if self.savedVars.lastResetDay ~= today then
        self.savedVars.completedToday = {}
        self.savedVars.activeQuests   = {}
        self.savedVars.lastResetDay   = today
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- UNDAUNTED PLEDGE DETECTION
-- ═══════════════════════════════════════════════════════════════════════════

local PLEDGE_PREFIX = "pledge:"

local function IsPledgeQuest(questName)
    if not questName then return false end
    return questName:lower():sub(1, #PLEDGE_PREFIX) == PLEDGE_PREFIX
end

-- ═══════════════════════════════════════════════════════════════════════════
-- ZONE NAME MATCHING
-- ═══════════════════════════════════════════════════════════════════════════

local zoneAliases = {
    ["hew's bane"]         = "Hew's Bane",
    ["gold coast"]         = "Gold Coast",
    ["wrothgar"]           = "Wrothgar",
    ["craglorn"]           = "Craglorn",
    ["vvardenfell"]        = "Vvardenfell",
    ["clockwork city"]     = "Clockwork City",
    ["summerset"]          = "Summerset",
    ["murkmire"]           = "Murkmire",
    ["northern elsweyr"]   = "Northern Elsweyr",
    ["southern elsweyr"]   = "Southern Elsweyr",
    ["western skyrim"]     = "Western Skyrim",
    ["the reach"]          = "The Reach",
    ["blackwood"]          = "Blackwood",
    ["deadlands"]          = "Deadlands",
    ["fargrave"]           = "Deadlands",
    ["high isle"]          = "High Isle",
    ["galen"]              = "Galen",
    ["telvanni peninsula"] = "Telvanni Peninsula",
    ["apocrypha"]          = "Apocrypha",
    ["west weald"]         = "West Weald",
    ["cyrodiil"]           = "Cyrodiil",
    ["imperial city"]      = "Imperial City",
}

function DQT:MatchZoneName(questZone)
    if not questZone or questZone == "" then return nil end

    for _, entry in ipairs(self.ZONE_DATABASE) do
        if questZone == entry.zone then return entry.zone end
    end

    local lower = questZone:lower()
    if zoneAliases[lower] then return zoneAliases[lower] end

    for _, entry in ipairs(self.ZONE_DATABASE) do
        if lower:find(entry.zone:lower(), 1, true) then
            return entry.zone
        end
    end

    return nil
end

-- ═══════════════════════════════════════════════════════════════════════════
-- QUEST OBJECTIVE SCANNING
-- ═══════════════════════════════════════════════════════════════════════════

function DQT:GetQuestObjectives(questIndex)
    local objectives = {}
    local seen = {}

    local numSteps = GetJournalQuestNumSteps(questIndex)
    for step = 1, numSteps do
        local stepText, visibility, stepType, trackerOverrideText, numConditions =
            GetJournalQuestStepInfo(questIndex, step)

        for cond = 1, numConditions do
            local condText, current, max, isFailCondition, isComplete, isCreditShared, isVisible =
                GetJournalQuestConditionInfo(questIndex, step, cond)

            if condText and condText ~= "" and isVisible ~= false and not isFailCondition then
                local key = condText .. ":" .. tostring(current) .. ":" .. tostring(max)
                if not seen[key] then
                    seen[key] = true
                    table.insert(objectives, {
                        text       = condText,
                        current    = current or 0,
                        max        = max or 0,
                        isComplete = isComplete or false,
                    })
                end
            end
        end
    end

    return objectives
end

-- ═══════════════════════════════════════════════════════════════════════════
-- QUEST SCANNING
-- ═══════════════════════════════════════════════════════════════════════════

function DQT:ScanActiveQuests()
    self.savedVars.activeQuests = {}

    for questIndex = 1, GetNumJournalQuests() do
        local questName, _, _, _, _, completed, tracked, _, _, questType,
              instanceDisplayType = GetJournalQuestInfo(questIndex)
        local repeatType = GetJournalQuestRepeatType(questIndex)

        if repeatType == QUEST_REPEAT_DAILY then
            local zoneName = GetJournalQuestLocationInfo(questIndex)
            local matchedZone

            if IsPledgeQuest(questName) then
                matchedZone = "Undaunted Pledges"
            else
                matchedZone = self:MatchZoneName(zoneName)
            end

            if matchedZone then
                if not self.savedVars.activeQuests[matchedZone] then
                    self.savedVars.activeQuests[matchedZone] = {}
                end

                local objectives = self:GetQuestObjectives(questIndex)

                table.insert(self.savedVars.activeQuests[matchedZone], {
                    name       = questName,
                    completed  = completed,
                    objectives = objectives,
                })
            end
        end
    end
end

function DQT:OnQuestComplete(questName, zoneName)
    self:CheckDailyReset()

    local matchedZone
    if IsPledgeQuest(questName) then
        matchedZone = "Undaunted Pledges"
    else
        matchedZone = self:MatchZoneName(zoneName)
    end
    if not matchedZone then return end

    if not self.savedVars.completedToday[matchedZone] then
        self.savedVars.completedToday[matchedZone] = {}
    end

    for _, existing in ipairs(self.savedVars.completedToday[matchedZone]) do
        if existing == questName then return end
    end
    table.insert(self.savedVars.completedToday[matchedZone], questName)

    if self.savedVars.activeQuests[matchedZone] then
        for i = #self.savedVars.activeQuests[matchedZone], 1, -1 do
            if self.savedVars.activeQuests[matchedZone][i].name == questName then
                table.remove(self.savedVars.activeQuests[matchedZone], i)
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- DATA COLLECTION
-- ═══════════════════════════════════════════════════════════════════════════

function DQT:CollectData()
    self:CheckDailyReset()
    self:ScanActiveQuests()

    self.zoneList = {}

    for _, dbEntry in ipairs(self.ZONE_DATABASE) do
        local zoneName   = dbEntry.zone
        local totalDaily = dbEntry.dailyCount
        local category   = dbEntry.category

        local completedCount = 0
        local completedNames = {}
        if self.savedVars.completedToday[zoneName] then
            completedCount = #self.savedVars.completedToday[zoneName]
            completedNames = self.savedVars.completedToday[zoneName]
        end

        local activeCount = 0
        local activeQuests = {}
        if self.savedVars.activeQuests[zoneName] then
            activeCount = #self.savedVars.activeQuests[zoneName]
            activeQuests = self.savedVars.activeQuests[zoneName]
        end

        local status = DQT.STATUS_NOT_STARTED
        if completedCount >= totalDaily then
            status = DQT.STATUS_COMPLETE
        elseif completedCount > 0 or activeCount > 0 then
            status = DQT.STATUS_IN_PROGRESS
        end

        local progressPct = 0
        if totalDaily > 0 then
            progressPct = math.min(100, math.floor((completedCount / totalDaily) * 100))
        end

        table.insert(self.zoneList, {
            zone           = zoneName,
            category       = category,
            totalDaily     = totalDaily,
            completedCount = completedCount,
            completedNames = completedNames,
            activeCount    = activeCount,
            activeQuests   = activeQuests,
            status         = status,
            progressPct    = progressPct,
        })
    end

    self:FilterAndSort()
end

-- ═══════════════════════════════════════════════════════════════════════════
-- FILTERS
-- ═══════════════════════════════════════════════════════════════════════════

local SORT_ZONE     = "zone"
local SORT_PROGRESS = "progress"
local SORT_STATUS   = "status"

DQT.FILTERS = {
    { label = "All Zones",      fn = function(e) return true end,                                  sortMode = SORT_ZONE },
    { label = "Not Started",    fn = function(e) return e.status == DQT.STATUS_NOT_STARTED end,    sortMode = SORT_ZONE },
    { label = "In Progress",    fn = function(e) return e.status == DQT.STATUS_IN_PROGRESS end,    sortMode = SORT_PROGRESS },
    { label = "Completed",      fn = function(e) return e.status == DQT.STATUS_COMPLETE end,       sortMode = SORT_ZONE },
    { label = "Not Completed",  fn = function(e) return e.status ~= DQT.STATUS_COMPLETE end,       sortMode = SORT_STATUS },
    { label = "Guilds",         fn = function(e) return e.category == "Guilds" end,                 sortMode = SORT_ZONE },
    { label = "PvP",            fn = function(e) return e.category == "PvP" end,                    sortMode = SORT_ZONE },
    { label = "Chapters & DLC", fn = function(e) return e.category == "Chapter" or e.category == "DLC" end, sortMode = SORT_ZONE },
}
DQT.filterIndex = 1

function DQT:CycleFilter()
    self.filterIndex = (self.filterIndex % #self.FILTERS) + 1
    self.searchText = ""
    self:FilterAndSort()
end

function DQT:GetCurrentFilterLabel()
    return "Filter: " .. self.FILTERS[self.filterIndex].label
end

-- ═══════════════════════════════════════════════════════════════════════════
-- FILTER & SORT
-- ═══════════════════════════════════════════════════════════════════════════

local function PrepareSearch(str)
    if not str or str == "" then return nil end
    return str:lower()
end

function DQT:FilterAndSort()
    self.filteredList = {}

    local filterDef  = self.FILTERS[self.filterIndex]
    if not filterDef then filterDef = self.FILTERS[1] end
    local filterFn   = filterDef.fn
    local searchTerm = PrepareSearch(self.searchText)

    for _, entry in ipairs(self.zoneList) do
        local pass = true
        local ok, result = pcall(filterFn, entry)
        if ok then pass = result end

        if pass and searchTerm then
            local haystack = (entry.zone .. " " .. entry.category):lower()
            if not haystack:find(searchTerm, 1, true) then pass = false end
        end

        if pass then
            table.insert(self.filteredList, entry)
        end
    end

    local mode = filterDef.sortMode or SORT_ZONE

    if mode == SORT_PROGRESS then
        table.sort(self.filteredList, function(a, b)
            if a.progressPct == b.progressPct then
                return a.zone:lower() < b.zone:lower()
            end
            return a.progressPct > b.progressPct
        end)
    elseif mode == SORT_STATUS then
        table.sort(self.filteredList, function(a, b)
            if a.status == b.status then
                return a.zone:lower() < b.zone:lower()
            end
            return a.status < b.status
        end)
    else
        table.sort(self.filteredList, function(a, b)
            return a.zone:lower() < b.zone:lower()
        end)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- STATS
-- ═══════════════════════════════════════════════════════════════════════════

function DQT:GetStats()
    local totalZones    = #self.zoneList
    local showing       = #self.filteredList
    local zonesComplete = 0
    local totalQuests   = 0
    local totalDone     = 0

    for _, e in ipairs(self.zoneList) do
        totalQuests = totalQuests + e.totalDaily
        totalDone   = totalDone + e.completedCount
        if e.status == DQT.STATUS_COMPLETE then
            zonesComplete = zonesComplete + 1
        end
    end

    return totalZones, showing, zonesComplete, totalQuests, totalDone
end

-- ═══════════════════════════════════════════════════════════════════════════
-- TOGGLE
-- ═══════════════════════════════════════════════════════════════════════════

function DQT:ToggleWindow()
    if DQT_UI then
        DQT_UI:Toggle()
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════════════════════════

local SAVED_VAR_VERSION = 3
local SV_DEFAULTS = {
    filterIndex    = 1,
    completedToday = {},
    activeQuests   = {},
    lastResetDay   = 0,
}

function DQT:Initialize()
    self.savedVars = ZO_SavedVars:NewAccountWide(
        "DailyQuestTrackerSV", SAVED_VAR_VERSION, nil, SV_DEFAULTS)

    self.filterIndex = self.savedVars.filterIndex or 1
    if self.filterIndex > #self.FILTERS then self.filterIndex = 1 end

    self:CheckDailyReset()

    SLASH_COMMANDS["/dqt"] = function()
        self:ToggleWindow()
    end
    SLASH_COMMANDS["/dailies"] = function()
        self:ToggleWindow()
    end

end

function DQT:LateInitialize()
    if DQT_UI then
        DQT_UI:Initialize()
        DQT_UI:LateInit()
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- EVENT HOOKS
-- ═══════════════════════════════════════════════════════════════════════════

local function OnAddonLoaded(_, addonName)
    if addonName ~= DQT.name then return end
    EVENT_MANAGER:UnregisterForEvent(DQT.name, EVENT_ADD_ON_LOADED)
    DQT:Initialize()
end

local function OnPlayerActivated()
    EVENT_MANAGER:UnregisterForEvent(DQT.name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED)
    DQT:CollectData()
    zo_callLater(function()
        DQT:LateInitialize()
    end, 2000)
end

local function OnQuestComplete(_, questName, _, _, _, _, _, _, zoneIndex, questId)
    local zoneName = GetZoneNameByIndex(zoneIndex) or ""
    for questIdx = 1, GetNumJournalQuests() do
        local jName = GetJournalQuestInfo(questIdx)
        if jName == questName then
            local repeatType = GetJournalQuestRepeatType(questIdx)
            if repeatType ~= QUEST_REPEAT_DAILY then return end
            zoneName = GetJournalQuestLocationInfo(questIdx)
            break
        end
    end
    DQT:OnQuestComplete(questName, zoneName)
    if DQT_UI and DQT_UI.visible then
        DQT:CollectData()
        DQT_UI:RefreshAll()
    end
end

local function OnQuestRemoved(_, isCompleted, questId, questName, zoneIndex, phaseIndex)
    if not isCompleted then return end
    local zoneName = ""
    if zoneIndex and zoneIndex > 0 then
        zoneName = GetZoneNameByIndex(zoneIndex) or ""
    end
    DQT:OnQuestComplete(questName, zoneName)
    if DQT_UI and DQT_UI.visible then
        DQT:CollectData()
        DQT_UI:RefreshAll()
    end
end

EVENT_MANAGER:RegisterForEvent(DQT.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent(DQT.name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
EVENT_MANAGER:RegisterForEvent(DQT.name .. "_QuestComplete", EVENT_QUEST_COMPLETE, OnQuestComplete)
EVENT_MANAGER:RegisterForEvent(DQT.name .. "_QuestRemoved", EVENT_QUEST_REMOVED, OnQuestRemoved)
