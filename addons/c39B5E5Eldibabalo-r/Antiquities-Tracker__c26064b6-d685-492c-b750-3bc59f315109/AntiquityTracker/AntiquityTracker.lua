-- =============================================================================
-- Antiquity Tracker v2.3.4
-- Flat scrollable list of every antiquity with sort & filter support.
-- Console/gamepad ready via ZO_Scene + GAMEPAD_DRIVEN_UI_WINDOW.
-- =============================================================================

AT = AT or {}
AT.name    = "AntiquityTracker"
AT.version = "2.3.4"

-- Runtime state
AT.savedVars        = nil
AT.antiquityList    = {}
AT.filteredList     = {}
AT.searchText       = ""
AT.lastCollectS     = 0
AT.collectIntervalS = 30

-- ---------------------------------------------------------------------------
-- Keybinding string registration — MUST be at top level (before Bindings.xml
-- is evaluated by the keybind UI), matching GAT's proven pattern.
-- ---------------------------------------------------------------------------
ZO_CreateStringId("SI_BINDING_NAME_AT_TOGGLE",      "Toggle Antiquity Tracker")
ZO_CreateStringId("SI_BINDING_NAME_AT_SCROLL_UP",   "Scroll Up")
ZO_CreateStringId("SI_BINDING_NAME_AT_SCROLL_DOWN", "Scroll Down")
ZO_CreateStringId("SI_BINDING_NAME_AT_CLOSE",       "Close Tracker")

-- ═══════════════════════════════════════════════════════════════════════════
-- CONSTANTS
-- ═══════════════════════════════════════════════════════════════════════════

AT.QUALITY_COLORS = {
    [ITEM_DISPLAY_QUALITY_TRASH]     = "FFFFFF",
    [ITEM_DISPLAY_QUALITY_NORMAL]    = "FFFFFF",
    [ITEM_DISPLAY_QUALITY_MAGIC]     = "2DC50E",
    [ITEM_DISPLAY_QUALITY_ARCANE]    = "3A92FF",
    [ITEM_DISPLAY_QUALITY_ARTIFACT]  = "A02EF7",
    [ITEM_DISPLAY_QUALITY_LEGENDARY] = "EECA2A",
    [ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE] = "E6C859",
}

function AT.QualityHex(quality)
    return AT.QUALITY_COLORS[quality] or "FFFFFF"
end

AT.difficultyStars = {}
for i = 1, 5 do
    AT.difficultyStars[i] = string.rep("*", i)
end

function AT.FormatLeadTime(seconds)
    if not seconds or seconds <= 0 then return "" end
    local days  = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local mins  = math.floor((seconds % 3600) / 60)
    if days > 0 then return days .. "d " .. hours .. "h" end
    if hours > 0 then return hours .. "h " .. mins .. "m" end
    if mins > 0 then return mins .. "m" end
    return "<1m"
end

-- ═══════════════════════════════════════════════════════════════════════════
-- FILTER DEFINITIONS (each filter has its own automatic sort)
-- ═══════════════════════════════════════════════════════════════════════════

local SORT_ZONE_NAME = "zone_name"
local SORT_TIME_ASC  = "time_asc"
local SORT_QUALITY   = "quality_desc"

AT.FILTERS = {
    { label = "All Antiquities", fn = function(e) return true end,                                              sortMode = SORT_ZONE_NAME },
    { label = "Has Lead",        fn = function(e) return e.hasLead == true end,                                 sortMode = SORT_TIME_ASC },
    { label = "Time Left",       fn = function(e) return e.hasLead and e.leadTimeS and e.leadTimeS > 0 end,     sortMode = SORT_TIME_ASC },
    { label = "Recovered",       fn = function(e) return e.recovered > 0 end,                                   sortMode = SORT_ZONE_NAME },
    { label = "Not Recovered",   fn = function(e) return e.recovered == 0 end,                                  sortMode = SORT_ZONE_NAME },
    { label = "Mythic / Set",    fn = function(e) return e.setId ~= nil end,                                    sortMode = SORT_QUALITY },
    { label = "Repeatable",      fn = function(e) return e.repeatable == true end,                               sortMode = SORT_ZONE_NAME },
}
AT.filterIndex = 1

function AT:CycleFilter()
    self.filterIndex = (self.filterIndex % #self.FILTERS) + 1
    self.searchText = ""
    self:FilterAndSort()
end

function AT:GetCurrentFilterLabel()
    return "Filter: " .. self.FILTERS[self.filterIndex].label
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SEARCH HELPERS
-- ═══════════════════════════════════════════════════════════════════════════

local function PrepareSearch(str)
    if not str or str == "" then return nil end
    return str:lower()
end

-- ═══════════════════════════════════════════════════════════════════════════
-- DATA COLLECTION — flat list of every visible antiquity
-- ═══════════════════════════════════════════════════════════════════════════

function AT:CollectData()
    self.antiquityList = {}

    local sets = {}
    local count = 0

    local antiquityId = GetNextAntiquityId()
    while antiquityId do
        local ok, isVisible = pcall(DoesAntiquityPassVisibilityRequirements, antiquityId)
        if ok and isVisible then
            local name       = GetAntiquityName(antiquityId)
            local quality    = GetAntiquityQuality(antiquityId)
            local icon       = GetAntiquityIcon(antiquityId)
            local difficulty = GetAntiquityDifficulty(antiquityId)
            local zoneId     = GetAntiquityZoneId(antiquityId)
            local setId      = GetAntiquitySetId(antiquityId)
            local reqLead    = DoesAntiquityRequireLead(antiquityId)
            local hasLead    = DoesAntiquityHaveLead(antiquityId)
            local leadTime   = GetAntiquityLeadTimeRemainingSeconds(antiquityId)
            local recovered  = GetNumAntiquitiesRecovered(antiquityId)
            local numLore    = GetNumAntiquityLoreEntries(antiquityId)
            local loreDone   = GetNumAntiquityLoreEntriesAcquired(antiquityId)
            local repeatable = IsAntiquityRepeatable(antiquityId)

            local zoneName = ""
            if zoneId and zoneId ~= 0 then
                pcall(function() zoneName = GetZoneNameById(zoneId) or "" end)
            end

            local setName     = nil
            local setPieces   = nil
            local setRecovered = nil
            local setQuality  = nil

            if setId and setId ~= 0 then
                if not sets[setId] then
                    local sn = GetAntiquitySetName(setId)
                    local sq = GetAntiquitySetQuality(setId)
                    local si = GetAntiquitySetIcon(setId)
                    local numPieces = GetNumAntiquitySetAntiquities(setId)
                    sets[setId] = {
                        name     = sn or "Unknown Set",
                        quality  = sq or quality,
                        icon     = si or icon,
                        total    = numPieces or 0,
                        recoveredPieces = 0,
                    }
                end
                if recovered and recovered > 0 then
                    sets[setId].recoveredPieces = sets[setId].recoveredPieces + 1
                end
                setName      = sets[setId].name
                setPieces    = sets[setId].total
                setRecovered = sets[setId].recoveredPieces
                setQuality   = sets[setId].quality
            end

            local leadTimeS = 0
            if hasLead and leadTime then
                leadTimeS = leadTime
            end

            -- sortTime: leads with less time sort first; no-lead items go to the end
            local sortTime = 999999999
            if hasLead and leadTimeS > 0 then
                sortTime = leadTimeS
            elseif hasLead then
                sortTime = 999999998
            end

            local leadHint = nil
            if AT_LEAD_LOCATIONS and name then
                leadHint = AT_LEAD_LOCATIONS[name]
            end
            if not leadHint and reqLead and zoneName and zoneName ~= "" then
                leadHint = zoneName .. " — zone chests, world bosses, delves, or daily rewards"
            end

            table.insert(self.antiquityList, {
                id           = antiquityId,
                name         = name or "???",
                quality      = quality or 1,
                icon         = icon or "",
                difficulty   = difficulty or 1,
                zoneId       = zoneId or 0,
                zoneName     = zoneName,
                requiresLead = reqLead,
                hasLead      = hasLead,
                leadTimeS    = leadTimeS,
                sortTime     = sortTime,
                recovered    = recovered or 0,
                repeatable   = repeatable or false,
                numLore      = numLore or 0,
                loreDone     = loreDone or 0,
                setId        = (setId and setId ~= 0) and setId or nil,
                setName      = setName,
                setPieces    = setPieces,
                setRecovered = setRecovered,
                setQuality   = setQuality,
                leadHint     = leadHint,
            })
            count = count + 1
        end

        antiquityId = GetNextAntiquityId(antiquityId)
    end

    self.lastCollectS = (GetTimeStamp and GetTimeStamp()) or self.lastCollectS or 0
    self:FilterAndSort()
end

function AT:NeedsCollect(force)
    if force then return true end
    if not self.antiquityList or #self.antiquityList == 0 then return true end
    if self.collectIntervalS <= 0 then return true end
    local now = (GetTimeStamp and GetTimeStamp()) or 0
    local last = self.lastCollectS or 0
    return (now - last) >= self.collectIntervalS
end

function AT:EnsureDataFresh(force)
    if self:NeedsCollect(force) then
        self:CollectData()
        return
    end
    -- Data is still fresh; re-apply current filter/search only.
    self:FilterAndSort()
end

-- ═══════════════════════════════════════════════════════════════════════════
-- FILTER & SORT
-- ═══════════════════════════════════════════════════════════════════════════

function AT:FilterAndSort()
    self.filteredList = {}

    local filterDef  = self.FILTERS[self.filterIndex]
    if not filterDef then filterDef = self.FILTERS[1] end
    local filterFn   = filterDef.fn
    local searchTerm = PrepareSearch(self.searchText)

    for _, entry in ipairs(self.antiquityList) do
        local pass = true
        local ok, result = pcall(filterFn, entry)
        if ok then
            pass = result
        end

        if pass and searchTerm then
            local haystack = (entry.name .. " " .. entry.zoneName .. " " .. (entry.setName or "")):lower()
            if not haystack:find(searchTerm, 1, true) then pass = false end
        end

        if pass then
            table.insert(self.filteredList, entry)
        end
    end

    local mode = filterDef.sortMode or SORT_ZONE_NAME

    if mode == SORT_TIME_ASC then
        table.sort(self.filteredList, function(a, b)
            local ta = a.sortTime or 999999999
            local tb = b.sortTime or 999999999
            if ta == tb then
                return (a.name or ""):lower() < (b.name or ""):lower()
            end
            return ta < tb
        end)
    elseif mode == SORT_QUALITY then
        table.sort(self.filteredList, function(a, b)
            local qa = a.quality or 0
            local qb = b.quality or 0
            if qa == qb then
                local za = (a.zoneName or ""):lower()
                local zb = (b.zoneName or ""):lower()
                if za == zb then
                    return (a.name or ""):lower() < (b.name or ""):lower()
                end
                return za < zb
            end
            return qa > qb
        end)
    else
        table.sort(self.filteredList, function(a, b)
            local za = (a.zoneName or ""):lower()
            local zb = (b.zoneName or ""):lower()
            if za == zb then
                return (a.name or ""):lower() < (b.name or ""):lower()
            end
            return za < zb
        end)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- STATS
-- ═══════════════════════════════════════════════════════════════════════════

function AT:GetStats()
    local total     = #self.antiquityList
    local showing   = #self.filteredList
    local recovered = 0
    local leads     = 0

    local mythicSets     = {}
    local mythicTotal    = 0
    local mythicComplete = 0

    for _, e in ipairs(self.antiquityList) do
        if e.recovered > 0 then recovered = recovered + 1 end
        if e.hasLead then leads = leads + 1 end

        if e.setId and e.setQuality and e.setQuality >= ITEM_DISPLAY_QUALITY_LEGENDARY then
            if not mythicSets[e.setId] then
                mythicSets[e.setId] = { total = e.setPieces or 0, recovered = 0 }
                mythicTotal = mythicTotal + 1
            end
            if e.recovered > 0 then
                mythicSets[e.setId].recovered = mythicSets[e.setId].recovered + 1
            end
        end
    end

    for _, info in pairs(mythicSets) do
        if info.total > 0 and info.recovered >= info.total then
            mythicComplete = mythicComplete + 1
        end
    end

    return total, showing, recovered, leads, mythicComplete, mythicTotal
end

-- ═══════════════════════════════════════════════════════════════════════════
-- TOGGLE
-- ═══════════════════════════════════════════════════════════════════════════

function AT:ToggleWindow()
    if AT_UI then
        AT_UI:Toggle()
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════════════════════════

local SAVED_VAR_VERSION = 2
local SV_DEFAULTS = {
    filterIndex = 1,
}

function AT:Initialize()
    self.savedVars = ZO_SavedVars:NewAccountWide(
        "AntiquityTrackerSV", SAVED_VAR_VERSION, nil, SV_DEFAULTS)

    self.filterIndex = self.savedVars.filterIndex or 1
    if self.filterIndex > #self.FILTERS then self.filterIndex = 1 end

    SLASH_COMMANDS["/at"] = function()
        self:ToggleWindow()
    end
end

function AT:LateInitialize()
    if AT_UI then
        AT_UI:Initialize()
        AT_UI:LateInit()
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- EVENT HOOKS
-- ═══════════════════════════════════════════════════════════════════════════

local function OnAddonLoaded(_, addonName)
    if addonName ~= AT.name then return end
    EVENT_MANAGER:UnregisterForEvent(AT.name, EVENT_ADD_ON_LOADED)
    AT:Initialize()
end

local function OnPlayerActivated()
    EVENT_MANAGER:UnregisterForEvent(AT.name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED)
    zo_callLater(function()
        AT:LateInitialize()
    end, 2000)
end

EVENT_MANAGER:RegisterForEvent(AT.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent(AT.name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
