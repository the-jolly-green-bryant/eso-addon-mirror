-- =============================================================================
-- Guild Activity Tracker — Core Logic v1.0.0
-- Guild roster scanning, history loading, filtering & sorting.
-- Scene-based UI with GAMEPAD_DRIVEN_UI_WINDOW for native console input.
-- =============================================================================

GAT = GAT or {}
GAT.name    = "GuildActivityTracker"
GAT.version = "3.6.23"

-- Runtime state
GAT.savedVars       = nil
GAT.guildList        = {}   -- { {id, name, count}, ... }
GAT.currentGuildIdx  = 1
GAT.currentGuildId   = nil
GAT.memberDataAll    = {}
GAT.memberDataFiltered = {}
GAT.historyDataAll   = {}
GAT.historyDataFiltered = {}
GAT.rosterGuildId    = nil
GAT.rosterLoadedAtS  = 0
GAT.historyGuildId   = nil
GAT.historyCatId     = nil
GAT.historyLoadedAtS = 0
GAT.historyLoadTruncated = false
GAT.memberHistoryLoadTruncated = false

-- Search state
GAT.searchText       = ""

-- Member detail state
GAT.selectedMember         = nil   -- member data table from roster
GAT.memberHistoryAll       = {}
GAT.memberHistoryFiltered  = {}
GAT.detailCatIndex         = 1

-- ---------------------------------------------------------------------------
-- Default saved variables
-- ---------------------------------------------------------------------------
local SAVED_VAR_VERSION = 1
local SV_DEFAULTS = {
    lastGuildIndex = 1,
    activeTab      = "roster",
    historyMaxDays = 7,
}

-- ---------------------------------------------------------------------------
-- Constants
-- ---------------------------------------------------------------------------
local DAY_SECONDS      = 86400
local HISTORY_MIN_DAYS = 1
local HISTORY_MAX_DAYS = 30
local HISTORY_DAY_CHOICES = { 1, 5, 10, 15, 30 }
local BATCH_SIZE       = 200
local ROSTER_REFRESH_INTERVAL_S = 20
local HISTORY_REFRESH_INTERVAL_S = 20

-- Guild history fetch limits (avoid loading entire trader category into memory at once)
local HISTORY_FETCH_CHUNK = 400
local MAX_GUILD_HISTORY_EVENTS_DEFAULT = 5000
local MAX_GUILD_HISTORY_EVENTS_TRADER = 3000
local MAX_MEMBER_HISTORY_PER_CAT_DEFAULT = 2500
local MAX_MEMBER_HISTORY_PER_CAT_TRADER = 1500

local function ClearArray(t)
    for i = #t, 1, -1 do
        t[i] = nil
    end
end

-- ---------------------------------------------------------------------------
-- Keybinding string registration (for Bindings.xml custom actions)
-- ---------------------------------------------------------------------------
ZO_CreateStringId("SI_BINDING_NAME_GAT_TOGGLE",      "Toggle Guild Activity Tracker")
ZO_CreateStringId("SI_BINDING_NAME_GAT_NEXT_TAB",    "Next Tab")
ZO_CreateStringId("SI_BINDING_NAME_GAT_PREV_TAB",    "Previous Tab")
ZO_CreateStringId("SI_BINDING_NAME_GAT_SCROLL_DOWN", "Scroll Down")
ZO_CreateStringId("SI_BINDING_NAME_GAT_SCROLL_UP",   "Scroll Up")
ZO_CreateStringId("SI_BINDING_NAME_GAT_CLOSE",       "Close Tracker")

-- ---------------------------------------------------------------------------
-- Inactivity filter definitions
-- ---------------------------------------------------------------------------
GAT.FILTERS = {
    { label = "All Members",       days = 0 },
    { label = "Online Only",       days = -1 },
    { label = "Inactive 1+ days",  days = 1 },
    { label = "Inactive 3+ days",  days = 3 },
    { label = "Inactive 7+ days",  days = 7 },
    { label = "Inactive 14+ days", days = 14 },
    { label = "Inactive 30+ days", days = 30 },
}
GAT.filterIndex = 1

-- ---------------------------------------------------------------------------
-- Sort definitions
-- ---------------------------------------------------------------------------
GAT.SORTS = {
    { label = "Name (A-Z)",           field = "displayName", asc = true },
    { label = "Name (Z-A)",           field = "displayName", asc = false },
    { label = "Rank",                 field = "rankIndex",   asc = true },
    { label = "Last Online (Recent)", field = "sortTime",    asc = true },
    { label = "Last Online (Oldest)", field = "sortTime",    asc = false },
}
GAT.sortIndex = 1

-- ---------------------------------------------------------------------------
-- History category definitions (built at runtime)
-- ---------------------------------------------------------------------------
GAT.HISTORY_CATS = {}
GAT.historyCatIndex = 1

-- ═══════════════════════════════════════════════════════════════════════════
-- UTILITY
-- ═══════════════════════════════════════════════════════════════════════════

local function StripCommas(str)
    return str:gsub(",", "")
end

local function ResolveItemLinks(text)
    if not text then return "" end
    return text:gsub("(|H.-|h)(.-)(|h)", function(header, display, closer)
        if display and display ~= "" then
            return display
        end
        local fullLink = header .. display .. closer
        if GetItemLinkName then
            local ok, name = pcall(GetItemLinkName, fullLink)
            if ok and name and name ~= "" then return name end
        end
        return ""
    end)
end

local function StripMarkup(text)
    if not text then return "" end
    text = text:gsub("|c%x%x%x%x%x%x", "")
    text = text:gsub("|r", "")
    text = text:gsub("|H[^|]-|h", "")
    text = text:gsub("|h", "")
    text = text:gsub("|t[^|]-|t", "")
    text = text:gsub("|u[^|]-|u", "")
    return text
end

local function MakeSearchable(text)
    return StripCommas(StripMarkup(ResolveItemLinks(text)):lower())
end

local function PrepareSearch(str)
    if not str or str == "" then return nil end
    return StripCommas(str:lower())
end

local function GetTraderCategoryId()
    return _G["GUILD_HISTORY_EVENT_CATEGORY_TRADER"]
end

local function MaxGuildHistoryEventsForCategory(catId)
    local tid = GetTraderCategoryId()
    if tid and catId == tid then
        return MAX_GUILD_HISTORY_EVENTS_TRADER
    end
    return MAX_GUILD_HISTORY_EVENTS_DEFAULT
end

local function MaxMemberHistoryEventsForCategory(catId)
    local tid = GetTraderCategoryId()
    if tid and catId == tid then
        return MAX_MEMBER_HISTORY_PER_CAT_TRADER
    end
    return MAX_MEMBER_HISTORY_PER_CAT_DEFAULT
end

local function EventTooOld(formattedTime)
    if not formattedTime or formattedTime == "" then return false end
    local maxDays = (GAT and GAT.GetHistoryMaxDays and GAT:GetHistoryMaxDays()) or 7
    local num = formattedTime:match("(%d+)%s+day")
    if num then return tonumber(num) > maxDays end
    local weeks = formattedTime:match("(%d+)%s+week")
    if weeks then return (tonumber(weeks) * 7) > maxDays end
    if formattedTime:match("week") then return 7 > maxDays end
    local months = formattedTime:match("(%d+)%s+month")
    if months then return (tonumber(months) * 30) > maxDays end
    if formattedTime:match("month") then return 30 > maxDays end
    local years = formattedTime:match("(%d+)%s+year")
    if years then return (tonumber(years) * 365) > maxDays end
    if formattedTime:match("year") then return 365 > maxDays end
    return false
end

local function FormatTimeSince(seconds)
    if not seconds or seconds <= 0 then
        return "Unknown"
    elseif seconds < 60 then
        return "Just now"
    elseif seconds < 3600 then
        local m = math.floor(seconds / 60)
        return m .. (m == 1 and " min ago" or " mins ago")
    elseif seconds < DAY_SECONDS then
        local h = math.floor(seconds / 3600)
        return h .. (h == 1 and " hour ago" or " hours ago")
    else
        local d = math.floor(seconds / DAY_SECONDS)
        return d .. (d == 1 and " day ago" or " days ago")
    end
end
GAT.FormatTimeSince = FormatTimeSince

-- ═══════════════════════════════════════════════════════════════════════════
-- GUILD LIST
-- ═══════════════════════════════════════════════════════════════════════════

function GAT:RefreshGuildList()
    ClearArray(self.guildList)
    local numGuilds = GetNumGuilds()
    for i = 1, numGuilds do
        local guildId = GetGuildId(i)
        local guildName = GetGuildName(guildId)
        local memberCount = GetNumGuildMembers(guildId)
        table.insert(self.guildList, {
            id    = guildId,
            name  = guildName,
            count = memberCount,
        })
    end
end

function GAT:SelectGuild(idx)
    if idx < 1 then idx = #self.guildList end
    if idx > #self.guildList then idx = 1 end
    self.currentGuildIdx = idx
    local g = self.guildList[idx]
    if g then
        self.currentGuildId = g.id
        self.savedVars.lastGuildIndex = idx
    else
        self.currentGuildId = nil
    end
end

function GAT:CycleGuild()
    self:SelectGuild(self.currentGuildIdx + 1)
    self:LoadGuildRoster()
    self:FilterMembers()
end

function GAT:ShouldRefreshRoster()
    if not self.currentGuildId then return false end
    if self.rosterGuildId ~= self.currentGuildId then return true end
    if not self.memberDataAll or #self.memberDataAll == 0 then return true end
    local now = (GetTimeStamp and GetTimeStamp()) or 0
    local last = self.rosterLoadedAtS or 0
    return (now - last) >= ROSTER_REFRESH_INTERVAL_S
end

function GAT:EnsureRosterFresh(force)
    if force or self:ShouldRefreshRoster() then
        self:LoadGuildRoster()
    end
    self:FilterMembers()
end

function GAT:ShouldRefreshHistory()
    if not self.currentGuildId then return false end
    local selectedCat = self.HISTORY_CATS[self.historyCatIndex]
    local selectedCatId = selectedCat and selectedCat.id or nil
    if self.historyGuildId ~= self.currentGuildId then return true end
    if self.historyCatId ~= selectedCatId then return true end
    if self.historyDaysUsed ~= self:GetHistoryMaxDays() then return true end
    if not self.historyDataAll or #self.historyDataAll == 0 then return true end
    local now = (GetTimeStamp and GetTimeStamp()) or 0
    local last = self.historyLoadedAtS or 0
    return (now - last) >= HISTORY_REFRESH_INTERVAL_S
end

function GAT:EnsureHistoryFresh(force)
    if force or self:ShouldRefreshHistory() then
        self:LoadGuildHistory()
    else
        self:FilterHistory()
    end
end

function GAT:GetCurrentGuildLabel()
    local g = self.guildList[self.currentGuildIdx]
    if g then
        return g.name
    end
    return "(No Guilds)"
end

-- ═══════════════════════════════════════════════════════════════════════════
-- ROSTER LOADING
-- ═══════════════════════════════════════════════════════════════════════════

function GAT:LoadGuildRoster()
    ClearArray(self.memberDataAll)
    if not self.currentGuildId then return end

    local numMembers = GetNumGuildMembers(self.currentGuildId)
    for i = 1, numMembers do
        local name, note, rankIndex, playerStatus, secsSinceLogoff =
            GetGuildMemberInfo(self.currentGuildId, i)

        if name and name ~= "" then
            local displayName = zo_strformat("<<1>>", name)

            -- Rank name
            local rankName = ""
            local ok, result = pcall(GetGuildRankCustomName, self.currentGuildId, rankIndex)
            if ok and result and result ~= "" then
                rankName = result
            else
                rankName = "Rank " .. tostring(rankIndex)
            end

            -- Character info (zone)
            local zone = ""
            local okC, c1, c2, c3 = pcall(GetGuildMemberCharacterInfo, self.currentGuildId, i)
            if okC and c1 then
                zone = c3 or ""
            end

            -- Status
            local isOnline = (playerStatus ~= PLAYER_STATUS_OFFLINE)
            local statusText, statusKey
            if playerStatus == PLAYER_STATUS_ONLINE then
                statusText = "Online"
                statusKey  = "online"
            elseif playerStatus == PLAYER_STATUS_AWAY then
                statusText = "Away"
                statusKey  = "away"
            elseif playerStatus == PLAYER_STATUS_DO_NOT_DISTURB then
                statusText = "DND"
                statusKey  = "dnd"
            else
                statusText = "Offline"
                statusKey  = "offline"
            end

            -- Inactivity
            local daysOffline = 0
            if not isOnline and secsSinceLogoff and secsSinceLogoff > 0 then
                daysOffline = secsSinceLogoff / DAY_SECONDS
            end

            -- Last online text
            local lastOnlineText = isOnline and "Now" or FormatTimeSince(secsSinceLogoff or 0)

            -- Sort time: online = 0, offline = seconds since logoff
            local sortTime = isOnline and 0 or (secsSinceLogoff or 999999999)
            local searchable = MakeSearchable(
                (displayName or "") .. " " .. (rankName or "") .. " " .. (zone or "")
            )

            table.insert(self.memberDataAll, {
                displayName     = displayName,
                rawName         = name,
                note            = note or "",
                rankIndex       = rankIndex or 99,
                rankName        = rankName,
                playerStatus    = playerStatus,
                secsSinceLogoff = secsSinceLogoff or 0,
                isOnline        = isOnline,
                daysOffline     = daysOffline,
                statusText      = statusText,
                statusKey       = statusKey,
                lastOnlineText  = lastOnlineText,
                zone            = zone,
                sortTime        = sortTime,
                searchText      = searchable,
            })
        end
    end
    self.rosterGuildId = self.currentGuildId
    self.rosterLoadedAtS = (GetTimeStamp and GetTimeStamp()) or self.rosterLoadedAtS or 0
end

-- ═══════════════════════════════════════════════════════════════════════════
-- ROSTER FILTERING & SORTING
-- ═══════════════════════════════════════════════════════════════════════════

function GAT:FilterMembers()
    local filtered = self.memberDataFiltered
    if not filtered or filtered == self.memberDataAll then
        filtered = {}
        self.memberDataFiltered = filtered
    else
        ClearArray(filtered)
    end
    local filterDays = self.FILTERS[self.filterIndex].days
    local searchTerm = PrepareSearch(self.searchText)

    for _, m in ipairs(self.memberDataAll) do
        local pass = true
        if filterDays == -1 then
            if not m.isOnline then pass = false end
        elseif filterDays > 0 then
            if m.isOnline or m.daysOffline < filterDays then pass = false end
        end
        if pass and searchTerm then
            local haystack = m.searchText
            if not haystack then
                haystack = MakeSearchable((m.displayName or "") .. " " .. (m.rankName or "") .. " " .. (m.zone or ""))
                m.searchText = haystack
            end
            if not haystack:find(searchTerm, 1, true) then pass = false end
        end
        if pass then
            table.insert(filtered, m)
        end
    end

    local sortDef = self.SORTS[self.sortIndex]
    local field = sortDef.field
    local asc   = sortDef.asc

    table.sort(filtered, function(a, b)
        local va = a[field]
        local vb = b[field]
        if va == nil then va = "" end
        if vb == nil then vb = "" end
        if type(va) == "string" then
            va = va:lower()
            vb = (vb or ""):lower()
        end
        if asc then return va < vb else return va > vb end
    end)
end

function GAT:CycleFilter()
    self.filterIndex = (self.filterIndex % #self.FILTERS) + 1
    self.searchText = ""
    self:FilterMembers()
end

function GAT:CycleSort()
    self.sortIndex = (self.sortIndex % #self.SORTS) + 1
    self:FilterMembers()
end

function GAT:GetCurrentFilterLabel()
    return "Filter: " .. self.FILTERS[self.filterIndex].label
end

function GAT:GetCurrentSortLabel()
    return "Sort: " .. self.SORTS[self.sortIndex].label
end

-- ═══════════════════════════════════════════════════════════════════════════
-- ROSTER STATS
-- ═══════════════════════════════════════════════════════════════════════════

function GAT:GetRosterStats()
    local total   = #self.memberDataAll
    local showing = #self.memberDataFiltered
    local online  = 0
    local inactive7  = 0
    local inactive30 = 0
    for _, m in ipairs(self.memberDataAll) do
        if m.isOnline then online = online + 1 end
        if m.daysOffline >= 7  then inactive7  = inactive7  + 1 end
        if m.daysOffline >= 30 then inactive30 = inactive30 + 1 end
    end
    return total, showing, online, inactive7, inactive30
end

-- ═══════════════════════════════════════════════════════════════════════════
-- HISTORY LOADING
-- ═══════════════════════════════════════════════════════════════════════════

function GAT:BuildHistoryCategoryDefs()
    self.HISTORY_CATS = {}
    local cats = {
        { global = "GUILD_HISTORY_EVENT_CATEGORY_BANKED_CURRENCY", label = "Gold Deposited" },
        { global = "GUILD_HISTORY_EVENT_CATEGORY_TRADER",          label = "Sales Done" },
        { global = "GUILD_HISTORY_EVENT_CATEGORY_BANKED_ITEM",     label = "Item Deposits/Withdrawals" },
        { global = "GUILD_HISTORY_EVENT_CATEGORY_ROSTER",          label = "Roster" },
    }
    for _, def in ipairs(cats) do
        local val = _G[def.global]
        if val then
            table.insert(self.HISTORY_CATS, { id = val, label = def.label })
        end
    end
    self.historyCatIndex = 1
end

function GAT:CycleHistoryCategory()
    self.historyCatIndex = (self.historyCatIndex % #self.HISTORY_CATS) + 1
    self.searchText = ""
    self:LoadGuildHistory()
end

function GAT:GetCurrentHistoryCatLabel()
    return "Category: " .. self.HISTORY_CATS[self.historyCatIndex].label
end

function GAT:GetHistoryMaxDays()
    local raw = self.savedVars and self.savedVars.historyMaxDays or SV_DEFAULTS.historyMaxDays
    local days = math.floor(tonumber(raw) or SV_DEFAULTS.historyMaxDays)
    if days < HISTORY_MIN_DAYS then days = HISTORY_MIN_DAYS end
    if days > HISTORY_MAX_DAYS then days = HISTORY_MAX_DAYS end
    return days
end

function GAT:SetHistoryMaxDays(days)
    local value = math.floor(tonumber(days) or SV_DEFAULTS.historyMaxDays)
    if value < HISTORY_MIN_DAYS then value = HISTORY_MIN_DAYS end
    if value > HISTORY_MAX_DAYS then value = HISTORY_MAX_DAYS end
    if not self.savedVars then
        return value, false
    end
    local changed = (self.savedVars.historyMaxDays ~= value)
    self.savedVars.historyMaxDays = value
    if changed then
        self.historyLoadedAtS = 0
    end
    return value, changed
end

function GAT:CycleHistoryMaxDays()
    local current = self:GetHistoryMaxDays()
    local nextValue = HISTORY_DAY_CHOICES[1]
    for i = 1, #HISTORY_DAY_CHOICES do
        if HISTORY_DAY_CHOICES[i] == current then
            nextValue = HISTORY_DAY_CHOICES[(i % #HISTORY_DAY_CHOICES) + 1]
            break
        end
        if HISTORY_DAY_CHOICES[i] > current then
            nextValue = HISTORY_DAY_CHOICES[i]
            break
        end
    end
    self:SetHistoryMaxDays(nextValue)
    return self:GetHistoryMaxDays()
end

function GAT:GetHistoryDaysLabel()
    return "Range: Last " .. tostring(self:GetHistoryMaxDays()) .. "d"
end

function GAT:RequestOlderHistory()
    if not self.currentGuildId or not GUILD_HISTORY_MANAGER then return end
    local ok, _ = pcall(function()
        local guildData = GUILD_HISTORY_MANAGER:GetGuildData(self.currentGuildId)
        if not guildData then return end
        local sel = self.HISTORY_CATS[self.historyCatIndex]
        local catId = sel and sel.id
        if catId then
            local categoryData = guildData:GetEventCategoryData(catId)
            if categoryData and categoryData.RequestOlderEvents then
                pcall(function()
                    categoryData:RequestOlderEvents()
                end)
            end
            return
        end
        for _, c in ipairs(self.HISTORY_CATS) do
            if c.id then
                local categoryData = guildData:GetEventCategoryData(c.id)
                if categoryData and categoryData.RequestOlderEvents then
                    pcall(function()
                        categoryData:RequestOlderEvents()
                    end)
                end
            end
        end
    end)
end

function GAT:CompleteGuildHistoryLoad()
    self.historyLoading = false
    self.historyGuildId = self.currentGuildId
    local selectedCat = self.HISTORY_CATS[self.historyCatIndex]
    self.historyCatId = selectedCat and selectedCat.id or nil
    self.historyDaysUsed = self:GetHistoryMaxDays()
    self.historyLoadedAtS = (GetTimeStamp and GetTimeStamp()) or self.historyLoadedAtS or 0
    self:FilterHistory()
    if GAT_UI and GAT_UI.visible then
        GAT_UI:RefreshList()
        GAT_UI:UpdateFooter()
    end
end

function GAT:CompleteMemberHistoryLoad()
    self.memberHistoryLoading = false
    self:FilterMemberHistory()
    if GAT_UI and GAT_UI.visible then
        GAT_UI:RefreshList()
        GAT_UI:UpdateFooter()
    end
end

-- Guild history: chunked GetXEventsFromStartingIndex (never allocate one giant events table).
-- Events are newest-first at index 1; EventTooOld stops further scanning in that category.
function GAT:LoadGuildHistory()
    ClearArray(self.historyDataAll)
    self.historyLoading = true
    self.historyLoadTruncated = false
    if not self.currentGuildId then
        self.historyLoading = false
        return
    end
    if not GUILD_HISTORY_MANAGER then
        self.historyLoading = false
        return
    end

    local guildData
    do
        local ok, gd = pcall(function()
            return GUILD_HISTORY_MANAGER:GetGuildData(self.currentGuildId)
        end)
        if not ok or not gd then
            self.historyLoading = false
            return
        end
        guildData = gd
    end

    local selectedCatId = self.HISTORY_CATS[self.historyCatIndex].id
    local catsToScan = {}
    if selectedCatId then
        for _, c in ipairs(self.HISTORY_CATS) do
            if c.id == selectedCatId then
                table.insert(catsToScan, c)
                break
            end
        end
    else
        for _, c in ipairs(self.HISTORY_CATS) do
            if c.id then
                table.insert(catsToScan, c)
            end
        end
    end

    local results = self.historyDataAll

    for _, cat in ipairs(catsToScan) do
        local categoryData = guildData:GetEventCategoryData(cat.id)
        if categoryData then
            local numEvents = categoryData:GetNumEvents() or 0
            local maxCap = MaxGuildHistoryEventsForCategory(cat.id)
            local startIndex = 1
            local scanned = 0
            local stopEarly = false

            while startIndex <= numEvents and scanned < maxCap and not stopEarly do
                local chunkRequest = math.min(HISTORY_FETCH_CHUNK, numEvents - startIndex + 1, maxCap - scanned)
                if chunkRequest <= 0 then
                    break
                end

                local events
                local okFetch, fetchErr = pcall(function()
                    events = categoryData:GetXEventsFromStartingIndex(startIndex, chunkRequest, true, nil)
                end)
                if not okFetch then
                    d("|cFF6666[GAT]|r Error loading history chunk: " .. tostring(fetchErr))
                    break
                end
                if not events or #events == 0 then
                    break
                end

                for _, ev in ipairs(events) do
                    local text = ""
                    local timeStr = ""
                    local okT, t = pcall(function()
                        return ev:GetText()
                    end)
                    if okT and t then
                        text = t
                    end
                    local okTs, ts = pcall(function()
                        return ev:GetFormattedTime()
                    end)
                    if okTs and ts then
                        timeStr = ts
                    end

                    if EventTooOld(timeStr) then
                        stopEarly = true
                        break
                    end

                    if text ~= "" then
                        table.insert(results, {
                            time = timeStr,
                            description = text,
                            category = cat.label,
                        })
                    end
                end

                scanned = scanned + #events
                startIndex = startIndex + #events
            end

            if (not stopEarly) and startIndex <= numEvents and scanned >= maxCap then
                self.historyLoadTruncated = true
            end
        end
    end

    self:CompleteGuildHistoryLoad()
end

function GAT:FilterHistory()
    local searchTerm = PrepareSearch(self.searchText)

    if not searchTerm then
        self.historyDataFiltered = self.historyDataAll
        return
    end

    local filtered = self.historyDataFiltered
    if not filtered or filtered == self.historyDataAll then
        filtered = {}
        self.historyDataFiltered = filtered
    else
        ClearArray(filtered)
    end
    for _, ev in ipairs(self.historyDataAll) do
        if not ev.searchText then
            ev.searchText = MakeSearchable(ev.description .. " " .. ev.category .. " " .. ev.time)
        end
        if ev.searchText:find(searchTerm, 1, true) then
            table.insert(filtered, ev)
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- MEMBER DETAIL — gold deposits, trader sales, bank activity for one member
-- ═══════════════════════════════════════════════════════════════════════════

GAT.DETAIL_CATS = {
    { id = nil, label = "All Activity" },
}

function GAT:BuildDetailCategoryDefs()
    self.DETAIL_CATS = {}
    local cats = {
        { global = "GUILD_HISTORY_EVENT_CATEGORY_BANKED_CURRENCY", label = "Gold Deposited" },
        { global = "GUILD_HISTORY_EVENT_CATEGORY_TRADER",          label = "Sales Done" },
        { global = "GUILD_HISTORY_EVENT_CATEGORY_BANKED_ITEM",     label = "Item Deposits/Withdrawals" },
        { global = "GUILD_HISTORY_EVENT_CATEGORY_ROSTER",          label = "Roster" },
    }
    for _, def in ipairs(cats) do
        local val = _G[def.global]
        if val then
            table.insert(self.DETAIL_CATS, { id = val, label = def.label })
        end
    end
    self.detailCatIndex = 1
end

function GAT:CycleDetailCategory()
    self.detailCatIndex = (self.detailCatIndex % #self.DETAIL_CATS) + 1
    self.searchText = ""
    self:FilterMemberHistory()
end

function GAT:GetCurrentDetailCatLabel()
    return "Category: " .. self.DETAIL_CATS[self.detailCatIndex].label
end

function GAT:SelectMember(memberData)
    self.selectedMember = memberData
    self.detailCatIndex = 1
    self:LoadMemberHistory(memberData.rawName or memberData.displayName)
end

function GAT:ClearSelectedMember()
    self.selectedMember = nil
    ClearArray(self.memberHistoryAll)
    if self.memberHistoryFiltered ~= self.memberHistoryAll then
        ClearArray(self.memberHistoryFiltered)
    end
    self.detailCatIndex = 1
end

-- Member history: one category at a time, chunked fetch (no giant rawEvents table).
-- Newest-first per category; EventTooOld ends that category only, then continues to next.
function GAT:LoadMemberHistory(memberName)
    ClearArray(self.memberHistoryAll)
    self.memberHistoryLoading = true
    self.memberHistoryLoadTruncated = false
    if not self.currentGuildId then
        self.memberHistoryLoading = false
        return
    end
    if not GUILD_HISTORY_MANAGER then
        self.memberHistoryLoading = false
        return
    end
    if not memberName or memberName == "" then
        self.memberHistoryLoading = false
        return
    end

    local nameLower = memberName:lower()
    local displayLower = zo_strformat("<<1>>", memberName):lower()

    local guildData
    do
        local ok, gd = pcall(function()
            return GUILD_HISTORY_MANAGER:GetGuildData(self.currentGuildId)
        end)
        if not ok or not gd then
            d("|cFF6666[GAT]|r Error loading member history (guild data).")
            self.memberHistoryLoading = false
            return
        end
        guildData = gd
    end

    local catsToScan = {}
    for _, c in ipairs(self.HISTORY_CATS) do
        if c.id then
            table.insert(catsToScan, c)
        end
    end

    local results = self.memberHistoryAll

    local loader = {
        guildData = guildData,
        catsToScan = catsToScan,
        catIdx = 0,
        categoryData = nil,
        categoryLabel = nil,
        categoryId = nil,
        startIndex = 1,
        numEvents = 0,
        maxCap = 0,
        scanned = 0,
        stopEarly = false,
    }

    local function advanceCategory()
        while loader.catIdx < #loader.catsToScan do
            loader.catIdx = loader.catIdx + 1
            local cat = loader.catsToScan[loader.catIdx]
            loader.categoryId = cat.id
            loader.categoryLabel = cat.label
            loader.categoryData = loader.guildData:GetEventCategoryData(cat.id)
            loader.numEvents = loader.categoryData and loader.categoryData:GetNumEvents() or 0
            loader.maxCap = MaxMemberHistoryEventsForCategory(cat.id)
            loader.startIndex = 1
            loader.scanned = 0
            loader.stopEarly = false
            if loader.categoryData and loader.numEvents > 0 then
                return true
            end
        end
        return false
    end

    local function processChunk()
        if not loader.categoryData then
            if not advanceCategory() then
                GAT:CompleteMemberHistoryLoad()
                return
            end
        end

        if loader.startIndex > loader.numEvents or loader.scanned >= loader.maxCap or loader.stopEarly then
            if (not loader.stopEarly) and loader.startIndex <= loader.numEvents and loader.scanned >= loader.maxCap then
                GAT.memberHistoryLoadTruncated = true
            end
            loader.categoryData = nil
            loader.stopEarly = false
            zo_callLater(processChunk, 0)
            return
        end

        local chunkRequest = math.min(HISTORY_FETCH_CHUNK, loader.numEvents - loader.startIndex + 1, loader.maxCap - loader.scanned)
        if chunkRequest <= 0 then
            loader.categoryData = nil
            zo_callLater(processChunk, 0)
            return
        end

        local events
        local okFetch, fetchErr = pcall(function()
            events = loader.categoryData:GetXEventsFromStartingIndex(loader.startIndex, chunkRequest, true, nil)
        end)
        if not okFetch then
            d("|cFF6666[GAT]|r Error loading member history chunk: " .. tostring(fetchErr))
            loader.categoryData = nil
            zo_callLater(processChunk, 0)
            return
        end
        if not events or #events == 0 then
            loader.categoryData = nil
            zo_callLater(processChunk, 0)
            return
        end

        for _, ev in ipairs(events) do
            local text = ""
            local timeStr = ""
            local okT, t = pcall(function()
                return ev:GetText()
            end)
            if okT and t then
                text = t
            end
            local okTs, ts = pcall(function()
                return ev:GetFormattedTime()
            end)
            if okTs and ts then
                timeStr = ts
            end

            if EventTooOld(timeStr) then
                loader.stopEarly = true
                break
            end

            if text ~= "" then
                local resolved = ResolveItemLinks(text):lower()
                if resolved:find(nameLower, 1, true) or resolved:find(displayLower, 1, true) then
                    table.insert(results, {
                        time = timeStr,
                        description = text,
                        category = loader.categoryLabel,
                        catId = loader.categoryId,
                    })
                end
            end
        end

        loader.scanned = loader.scanned + #events
        loader.startIndex = loader.startIndex + #events

        zo_callLater(processChunk, 0)
    end

    zo_callLater(processChunk, 0)
end

function GAT:FilterMemberHistory()
    local selectedCatId = self.DETAIL_CATS[self.detailCatIndex].id
    if not selectedCatId then
        self.memberHistoryFiltered = self.memberHistoryAll
        return
    end

    local filtered = self.memberHistoryFiltered
    if not filtered or filtered == self.memberHistoryAll then
        filtered = {}
        self.memberHistoryFiltered = filtered
    else
        ClearArray(filtered)
    end
    for _, ev in ipairs(self.memberHistoryAll) do
        if ev.catId == selectedCatId then
            table.insert(filtered, ev)
        end
    end
end

function GAT:GetMemberDetailStats()
    local total = #self.memberHistoryAll
    local goldDeposits = 0
    local traderSales  = 0
    local bankItems    = 0
    local goldCatId   = _G["GUILD_HISTORY_EVENT_CATEGORY_BANKED_CURRENCY"]
    local traderCatId = _G["GUILD_HISTORY_EVENT_CATEGORY_TRADER"]
    local bankCatId   = _G["GUILD_HISTORY_EVENT_CATEGORY_BANKED_ITEM"]

    for _, ev in ipairs(self.memberHistoryAll) do
        if goldCatId   and ev.catId == goldCatId   then goldDeposits = goldDeposits + 1 end
        if traderCatId and ev.catId == traderCatId then traderSales  = traderSales  + 1 end
        if bankCatId   and ev.catId == bankCatId   then bankItems    = bankItems    + 1 end
    end

    return total, goldDeposits, traderSales, bankItems
end

-- ═══════════════════════════════════════════════════════════════════════════
-- TOGGLE
-- ═══════════════════════════════════════════════════════════════════════════

function GAT:ToggleWindow()
    if GAT_UI then
        GAT_UI:Toggle()
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- INITIALISATION
-- ═══════════════════════════════════════════════════════════════════════════

function GAT:Initialize()
    self.savedVars = ZO_SavedVars:NewAccountWide(
        "GuildActivityTrackerSV", SAVED_VAR_VERSION, nil, SV_DEFAULTS)
    self:SetHistoryMaxDays(self.savedVars.historyMaxDays)

    self:BuildHistoryCategoryDefs()
    self:BuildDetailCategoryDefs()
    self:RefreshGuildList()

    -- Restore saved guild selection
    local savedIdx = self.savedVars.lastGuildIndex or 1
    if savedIdx > #self.guildList then savedIdx = 1 end
    self:SelectGuild(savedIdx)
    self:LoadGuildRoster()
    self:FilterMembers()

    -- Initialize UI
    if GAT_UI then
        GAT_UI:Initialize()
    end

    -- Slash commands
    SLASH_COMMANDS["/gat"] = function(args)
        local raw = tostring(args or "")
        local cmd, rest = raw:match("^(%S+)%s*(.-)$")
        cmd = string.lower(cmd or "")
        rest = rest or ""
        if cmd == "roster" then
            if GAT_UI then GAT_UI:Show() GAT_UI:SetActiveTab("roster") end
        elseif cmd == "history" then
            if GAT_UI then GAT_UI:Show() GAT_UI:SetActiveTab("history") end
        elseif cmd == "days" then
            if rest == "" then
                d("|cE8C05C[GAT]|r History range: last " .. tostring(self:GetHistoryMaxDays()) .. " days.")
                return
            end
            local requested = tonumber(rest:match("(%d+)"))
            if not requested then
                d("|cE8C05C[GAT]|r Usage: /gat days <1-30>")
                return
            end
            local finalValue, changed = self:SetHistoryMaxDays(requested)
            d("|cE8C05C[GAT]|r History range set to last " .. tostring(finalValue) .. " days.")
            if changed and GAT_UI and GAT_UI.visible and GAT_UI.activeTab == "history" and not GAT_UI.inDetailView then
                self:LoadGuildHistory()
                GAT_UI:RefreshAll()
            end
            return
        elseif cmd == "close" or cmd == "hide" then
            if GAT_UI then GAT_UI:Hide() end
        elseif cmd == "help" or cmd == "?" then
            d("|cE8C05C[GAT] Commands:|r")
            d("  |c00FFFF/gat|r — toggle tracker")
            d("  |c00FFFF/gat roster|r / |c00FFFF/gat history|r — open tab")
            d("  |c00FFFF/gat days <1-30>|r — set history range")
            d("  |c00FFFF/gat close|r — close tracker")
            d("  L1/R1 = tabs, L2/R2 = scroll, Triangle = filter, Square = guild")
        else
            self:ToggleWindow()
        end
    end

    -- Register for roster change events
    EVENT_MANAGER:RegisterForEvent(self.name .. "_MemberAdded",
        EVENT_GUILD_MEMBER_ADDED, function(_, guildId)
            if guildId == self.currentGuildId then
                self:LoadGuildRoster()
                self:FilterMembers()
                if GAT_UI and GAT_UI.visible then GAT_UI:RefreshList() end
            end
        end)
    EVENT_MANAGER:RegisterForEvent(self.name .. "_MemberRemoved",
        EVENT_GUILD_MEMBER_REMOVED, function(_, guildId)
            if guildId == self.currentGuildId then
                self:LoadGuildRoster()
                self:FilterMembers()
                if GAT_UI and GAT_UI.visible then GAT_UI:RefreshList() end
            end
        end)
    EVENT_MANAGER:RegisterForEvent(self.name .. "_StatusChanged",
        EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, function(_, guildId)
            if guildId == self.currentGuildId then
                self:LoadGuildRoster()
                self:FilterMembers()
                if GAT_UI and GAT_UI.visible then GAT_UI:RefreshList() end
            end
        end)
end

-- Late initialization: add to Journal menu after game UI is fully loaded
function GAT:LateInitialize()
    if GAT_UI then
        GAT_UI:LateInit()
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- EVENT HOOKS
-- ═══════════════════════════════════════════════════════════════════════════

local function OnAddonLoaded(_, addonName)
    if addonName ~= GAT.name then return end
    EVENT_MANAGER:UnregisterForEvent(GAT.name, EVENT_ADD_ON_LOADED)
    GAT:Initialize()
end

local function OnPlayerActivated()
    EVENT_MANAGER:UnregisterForEvent(GAT.name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED)
    zo_callLater(function()
        GAT:LateInitialize()
    end, 2000)
end

EVENT_MANAGER:RegisterForEvent(GAT.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent(GAT.name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
