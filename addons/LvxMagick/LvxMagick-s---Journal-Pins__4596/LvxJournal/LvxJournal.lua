--[[
    Lvx Journal - Chronicles
    Main addon controller for the open-book roleplay journal.

    ESOUI safety notes:
      * Uses only ESO UI/API calls, SavedVariables, and optional library calls.
      * Does not use loadstring, external file I/O, network access, or hidden executables.
      * Export/backup features write only through ESO SavedVariables on /reloadui/logout/exit.
      * Optional integrations are guarded so missing libraries do not break the addon.

    Maintenance notes:
      * LvxJournal.lua owns saved data, windows, editor/read/search/archive views,
        map marker data, pin integration, slash commands, and event logging.
      * LvxJournalTools.lua owns the roleplay tools pages: dice, oracle, coin toss,
        random activity/destination, daily checklist, marker manager buttons, and export tools.
]]

LvxJournal = LvxJournal or {}

LvxJournal.name = "LvxJournal"
LvxJournal.version = "2.4.45"

if ZO_CreateStringId then
    ZO_CreateStringId("SI_BINDING_NAME_LVX_JOURNAL_OPEN", "Open Journal")
    ZO_CreateStringId("SI_BINDING_NAME_LVX_JOURNAL_NEW", "New Journal Entry")
end

local em = EVENT_MANAGER
local wm = WINDOW_MANAGER
local MAP_MARKS_PER_PAGE = 1
local luaUnpack = unpack or (table and table.unpack)

-- -----------------------------------------------------------------------------
-- SavedVariables defaults and static data
-- -----------------------------------------------------------------------------
local defaults = {
    entries = {},
    selectedIndex = 1,
    lastOpenedIndex = 1,
    filter = "All Entries",
    viewMode = "archive",
    archivePage = 1,
    useRoleplayTime = true,
    search = {
        open = false,
        query = "",
        scope = "All",
        page = 1,
        results = {},
    },
    profile = {
        name = "",
        race = "",
        class = "",
        alliance = "",
        birthplace = "",
        personality = "",
        goals = "",
        companions = "",
        enemies = "",
        backstory = "",
    },
    pendingDeleteIndex = nil,
    theme = "blank",
    optionsPage = "themes",

    autoFocusMouse = false,
    showHelpTooltips = true,

    autoQuestCompleted = true,
    autoQuestAccepted = true,
    autoDeath = true,
    autoTravel = true,
    autoAchievement = true,

    knownZones = {},
    mapMarks = {},
    mapPinFilters = {
        journalPins = true,
    },
    showMapPins = true,
    autoPinJournalEntries = false,
    useBuiltInMapPinFallback = false,
    mapMarkPage = 1,
    mapMarkIcon = "book",
    stats = {
        totalMeters = 0,
        lastZoneId = nil,
        lastX = nil,
        lastY = nil,
        lastZ = nil,
        sessionMeters = 0,
        movementSamples = 0,
        sessionStart = 0,
        statsPage = 1,
        codexPage = 1,
        tributeWins = 0,
        tributeLosses = 0,
        tributeGames = 0,
        tributeLastResult = "",
        tributeLastSource = "",
        tributeLastTime = "",
        enemyKills = 0,
        bossKills = 0,
        sessionEnemyKills = 0,
        sessionBossKills = 0,
        goldCollected = 0,
        sessionGoldCollected = 0,
        lastKnownGold = nil,
    },
    windowX = 135,
    windowY = 35,
}

local categories = {
    { name = "All Entries", category = "All" },
    { name = "Favorites", category = "Bookmarks" },
    { name = "Quest Log", category = "Quest" },
    { name = "Travel Log", category = "Travel" },
    { name = "Death Log", category = "Death" },
    { name = "Achievement Log", category = "Achievement" },
    { name = "Personal Notes", category = "Manual" },
    { name = "Crafting Notes", category = "Crafting" },
    { name = "Profile", category = "Profile" },
    { name = "Stats", category = "Stats" },
    { name = "Codex", category = "Codex" },
    { name = "Options", category = "Options" },
}

local journalThemes = {
    {
        key = "classic",
        name = "Classic Parchment",
        texture = "LvxJournal/ui/journal_book_chronicles.dds",
        note = ""
    },
    {
        key = "arcane",
        name = "Arcane Midnight",
        texture = "LvxJournal/ui/themes/journal_book_arcane.dds",
        note = ""
    },
    {
        key = "dwemer",
        name = "Dwemer Brass",
        texture = "LvxJournal/ui/themes/journal_book_dwemer.dds",
        note = ""
    },
    {
        key = "warden",
        name = "Warden Nature",
        texture = "LvxJournal/ui/themes/journal_book_warden.dds",
        note = ""
    },
    {
        key = "daedric",
        name = "Daedric Crimson",
        texture = "LvxJournal/ui/themes/journal_book_daedric.dds",
        note = ""
    },
    {
        key = "blank",
        name = "Blank Reading",
        texture = "LvxJournal/ui/themes/journal_book_blank.dds",
        note = ""
    },
}

local function GetThemeByKey(key)
    for i = 1, #journalThemes do
        if journalThemes[i].key == key then return journalThemes[i] end
    end
    return journalThemes[1]
end

local function GetCurrentTheme()
    local s = LvxJournal.savedVars or defaults
    return GetThemeByKey(s.theme or "blank")
end


-- -----------------------------------------------------------------------------
-- Small utility helpers
-- -----------------------------------------------------------------------------
local function Msg(text)
    d("|cC79A4BJournal|r: " .. tostring(text))
end

local function DeepCopyTable(source, seen)
    if type(source) ~= "table" then return source end
    seen = seen or {}
    if seen[source] then return seen[source] end

    local copy = {}
    seen[source] = copy
    for key, value in pairs(source) do
        copy[DeepCopyTable(key, seen)] = DeepCopyTable(value, seen)
    end
    return copy
end

local function SafeCall(fn, ...)
    if type(fn) == "function" then
        local ok, a, b, c, d = pcall(fn, ...)
        if ok then return a, b, c, d end
    end
    return nil
end

local function SafeCallMany(fn, ...)
    if type(fn) == "function" then
        local results = { pcall(fn, ...) }
        if results[1] then
            table.remove(results, 1)
            if luaUnpack then return luaUnpack(results) end
        end
    end
    return nil
end

local function RegisterEventIfExists(suffix, eventName, callback)
    local eventId = _G[eventName]
    if eventId ~= nil then
        em:RegisterForEvent(LvxJournal.name .. "_" .. suffix, eventId, callback)
    end
end

local function GetRealDateDayText()
    -- ESOUI-safe date handling. Avoid Lua OS libraries; use ESO API only.
    local stamp = GetTimeStamp and GetTimeStamp() or nil

    if GetDateStringFromTimestamp and stamp then
        local dateText = GetDateStringFromTimestamp(stamp)
        if dateText and dateText ~= "" then return dateText end
    end

    return "Real Date Unknown"
end

local function GetRealTimeText()
    local dateText = GetRealDateDayText()
    local timeText = ""
    if GetTimeString then timeText = GetTimeString() or "" end
    if timeText ~= "" then return dateText .. " " .. timeText end
    return dateText
end

local function GetClockLabelText()
    local label = _G["ClockUITime"]
    if label and label.GetText then
        local text = label:GetText()
        if text and text ~= "" and text ~= "Error" then return text end
    end

    if cl and cl.vi then
        local possible = {"GetTime", "GetDate", "GetClockText", "GetLoreDate", "GetLoreTime"}
        for _, name in ipairs(possible) do
            if type(cl.vi[name]) == "function" then
                local value = SafeCall(cl.vi[name])
                if value and value ~= "" then return tostring(value) end
            end
        end
    end

    return nil
end

local function GetFallbackRoleplayTimeText()
    local hour, minute = nil, nil

    if GetTimeOfDay then
        local a, b = SafeCall(GetTimeOfDay)
        if type(a) == "number" and type(b) == "number" then
            hour, minute = a, b
        elseif type(a) == "number" then
            local raw = a
            if raw <= 1 then
                hour = math.floor(raw * 24)
                minute = math.floor(((raw * 24) - hour) * 60)
            else
                hour = math.floor(raw)
                minute = math.floor((raw - hour) * 60)
            end
        end
    end

    if hour then
        return string.format("2E 582, %02d:%02d", hour, minute or 0)
    end

    return "2E 582"
end

local function GetStampText()
    if LvxJournal.savedVars and LvxJournal.savedVars.useRoleplayTime then
        return GetClockLabelText() or GetFallbackRoleplayTimeText()
    end
    return GetRealTimeText()
end

local function GetLocationText()
    local zone = ""
    if GetUnitZoneIndex and GetZoneNameByIndex then
        zone = GetZoneNameByIndex(GetUnitZoneIndex("player")) or ""
    end
    if zone == "" and GetUnitZone then zone = GetUnitZone("player") or "" end
    if zone == "" then zone = "Unknown Location" end
    return zone
end

local function GetPlayerNameSafe()
    if GetUnitName then return GetUnitName("player") or "Unknown" end
    return "Unknown"
end

local function GetCategoryDisplay(entry)
    if not entry then return "" end
    if entry.category == "Manual" then return "Personal Notes" end
    if entry.category == "Quest" then return "Quest Log" end
    if entry.category == "Travel" then return "Travel Log" end
    if entry.category == "Death" then return "Death Log" end
    if entry.category == "Achievement" then return "Achievement Log" end
    if entry.category == "Crafting" then return "Crafting Notes" end
    return entry.category or "Entry"
end

local function CategoryMatches(entry, filter)
    if filter == "All Entries" then return true end
    if filter == "Bookmarks" then return entry.favorite == true end
    if filter == "Personal Notes" then return entry.category == "Manual" end
    if filter == "Quest Log" then return entry.category == "Quest" end
    if filter == "Travel Log" then return entry.category == "Travel" end
    if filter == "Death Log" then return entry.category == "Death" end
    if filter == "Achievement Log" then return entry.category == "Achievement" end
    if filter == "Crafting Notes" then return entry.category == "Crafting" end
    return true
end

local function GetCategoryForFilter(filter)
    if filter == "Stats" then return "Manual" end
    if filter == "Codex" then return "Manual" end
    if filter == "Profile" then return "Manual" end
    if filter == "Bookmarks" then return "Manual" end
    if filter == "Quest Log" then return "Quest" end
    if filter == "Travel Log" then return "Travel" end
    if filter == "Death Log" then return "Death" end
    if filter == "Achievement Log" then return "Achievement" end
    if filter == "Crafting Notes" then return "Crafting" end
    return "Manual"
end

local function GetDefaultTitleForFilter(filter)
    if filter == "Stats" then return "New Personal Note" end
    if filter == "Codex" then return "New Personal Note" end
    if filter == "Profile" then return "New Personal Note" end
    if filter == "Bookmarks" then return "New Bookmarked Note" end
    if filter == "Quest Log" then return "New Quest Note" end
    if filter == "Travel Log" then return "New Travel Note" end
    if filter == "Death Log" then return "New Death Note" end
    if filter == "Achievement Log" then return "New Achievement Note" end
    return "New Journal Entry"
end

local function GetVisibleEntries()
    local s = LvxJournal.savedVars
    local results = {}
    if not s then return results end

    for i = 1, #s.entries do
        local e = s.entries[i]
        if CategoryMatches(e, s.filter or "All Entries") then
            table.insert(results, { realIndex = i, entry = e })
        end
    end

    return results
end

local function GetArchivePageInfo()
    local s = LvxJournal.savedVars
    local visible = GetVisibleEntries()
    local perPage = 8
    local total = #visible
    local maxPage = math.max(1, math.ceil(total / perPage))

    s.archivePage = tonumber(s.archivePage) or 1
    if s.archivePage < 1 then s.archivePage = 1 end
    if s.archivePage > maxPage then s.archivePage = maxPage end

    local startIndex = ((s.archivePage - 1) * perPage) + 1
    local endIndex = math.min(startIndex + perPage - 1, total)

    return visible, s.archivePage, maxPage, startIndex, endIndex, total, perPage
end


local function GetSearchState()
    local s = LvxJournal.savedVars
    if not s then return nil end
    s.search = s.search or {}
    s.search.open = s.search.open == true
    s.search.query = s.search.query or ""
    s.search.scope = s.search.scope or "All"
    s.search.page = tonumber(s.search.page) or 1
    s.search.results = s.search.results or {}
    return s.search
end

local function LowerText(value)
    return string.lower(tostring(value or ""))
end

local function ContainsText(value, query)
    if not query or query == "" then return false end
    return string.find(LowerText(value), LowerText(query), 1, true) ~= nil
end

local function AnyContains(query, ...)
    for i = 1, select("#", ...) do
        if ContainsText(select(i, ...), query) then return true end
    end
    return false
end

local function AddSearchResult(results, resultType, title, sub, realIndex, codexPage, markIndex)
    table.insert(results, {
        resultType = resultType,
        title = title or "Result",
        sub = sub or "",
        realIndex = realIndex,
        codexPage = codexPage,
        markIndex = markIndex,
    })
end

local function GetAlchemyReagentPage(index)
    if index <= 10 then return 2 end
    if index <= 19 then return 3 end
    if index <= 28 then return 4 end
    return 5
end

local function GetEssenceRunePage(index)
    if index <= 9 then return 17 end
    if index <= 17 then return 18 end
    return 19
end

local function GetArmorTraitPage(index)
    if index <= 6 then return 23 end
    return 24
end

local function GetWeaponTraitPage(index)
    if index <= 6 then return 25 end
    return 26
end

local function GetJewelryTraitPage(index)
    if index <= 6 then return 27 end
    return 28
end

local function CountForFilter(filter)
    local s = LvxJournal.savedVars
    if not s then return 0 end

    local n = 0
    for i = 1, #s.entries do
        if CategoryMatches(s.entries[i], filter) then
            n = n + 1
        end
    end
    return n
end

local function AddEntry(title, body, category, subType, quiet)
    local s = LvxJournal.savedVars
    if not s then return end

    local stamp = GetStampText()
    local entry = {
        title = title or "Untitled Entry",
        body = body or "",
        category = category or "Manual",
        subType = subType or "",
        location = GetLocationText(),
        time = stamp,
        modified = nil,
        timeMode = s.useRoleplayTime and "Roleplay Time" or "Real Time",
        favorite = false,
        order = GetTimeStamp and GetTimeStamp() or #s.entries + 1,
    }

    table.insert(s.entries, 1, entry)
    s.selectedIndex = 1

    LvxJournal.RefreshAll()

    if not quiet then
        Msg("Entry added.")
    end
end


-- -----------------------------------------------------------------------------
-- New-entry templates
-- -----------------------------------------------------------------------------
local entryTemplates = {
    {
        key = "blank",
        name = "Blank Entry",
        title = "New Journal Entry",
        category = "Manual",
        body = "Write your entry here...",
    },
    {
        key = "quest",
        name = "Quest Notes",
        title = "New Quest Note",
        category = "Quest",
        body = "Quest:\n\nObjective:\n\nPeople involved:\n\nClues:\n\nOutcome:",
    },
    {
        key = "travel",
        name = "Travel Log",
        title = "New Travel Note",
        category = "Travel",
        body = "Destination:\n\nRoute:\n\nWeather:\n\nDiscoveries:\n\nDangers:\n\nNotes:",
    },
    {
        key = "death",
        name = "Death Record",
        title = "New Death Record",
        category = "Death",
        body = "Where it happened:\n\nCause:\n\nEnemy or hazard:\n\nWhat I learned:\n\nRecovery notes:",
    },
    {
        key = "crafting",
        name = "Crafting Notes",
        title = "New Crafting Note",
        category = "Crafting",
        body = "Crafting goal:\n\nMaterials needed:\n\nTrait/style:\n\nRecipe/glyph/potion:\n\nResult:",
    },
    {
        key = "diary",
        name = "Character Diary",
        title = "New Diary Entry",
        category = "Manual",
        body = "Today I...\n\nPeople I met:\n\nHow I feel:\n\nWhat comes next:",
    },
    {
        key = "discovery",
        name = "Discovery / Lore Note",
        title = "New Discovery Note",
        category = "Manual",
        body = "Discovery:\n\nLocation:\n\nSource:\n\nMeaning:\n\nFollow-up:",
    },
}

local function GetTemplateByKey(key)
    for i = 1, #entryTemplates do
        if entryTemplates[i].key == key then return entryTemplates[i] end
    end
    return entryTemplates[1]
end

function LvxJournal.OpenTemplateChooser()
    if LvxJournal.savedVars then
        LvxJournal.savedVars.activeChronicleKey = "JournalTemplates"
    end
    LvxJournal.AutoSaveCurrentEntry(true)
    if not LvxJournal.savedVars then return end
    LvxJournal.savedVars.viewMode = "templates"
    LvxJournal.RefreshAll()
end

function LvxJournal.CreateEntryFromTemplate(templateKey)
    local s = LvxJournal.savedVars
    if not s then return end
    local template = GetTemplateByKey(templateKey)
    local title = template.title
    local category = template.category
    local body = template.body

    if templateKey == "blank" then
        local filter = s.filter or "Personal Notes"
        category = GetCategoryForFilter(filter)
        title = GetDefaultTitleForFilter(filter)
        if filter == "All Entries" or filter == "Bookmarks" or filter == "Stats" or filter == "Codex" or filter == "Profile" or filter == "Options" then
            s.filter = "Personal Notes"
            category = "Manual"
            title = "New Personal Note"
        end
    else
        if category == "Quest" then s.filter = "Quest Log"
        elseif category == "Travel" then s.filter = "Travel Log"
        elseif category == "Death" then s.filter = "Death Log"
        else s.filter = "Personal Notes" end
    end

    s.viewMode = "edit"
    AddEntry(title, body, category, templateKey, false)
end

local function EnsureProfileTable()
    local s = LvxJournal.savedVars
    if not s then return nil end
    s.profile = s.profile or {}
    s.profile.name = s.profile.name or ""
    s.profile.race = s.profile.race or ""
    s.profile.class = s.profile.class or ""
    s.profile.alliance = s.profile.alliance or ""
    s.profile.birthplace = s.profile.birthplace or ""
    s.profile.personality = s.profile.personality or ""
    s.profile.goals = s.profile.goals or ""
    s.profile.companions = s.profile.companions or ""
    s.profile.enemies = s.profile.enemies or ""
    s.profile.backstory = s.profile.backstory or ""
    return s.profile
end

function LvxJournal.AutoSaveProfile(silent)
    local profile = EnsureProfileTable()
    if not profile then return false end
    if LvxJournal.savedVars.viewMode ~= "profile" then return false end
    if not LvxJournal.profileNameBox then return false end

    local changed = false
    local fields = {
        {"name", LvxJournal.profileNameBox},
        {"race", LvxJournal.profileRaceBox},
        {"class", LvxJournal.profileClassBox},
        {"alliance", LvxJournal.profileAllianceBox},
        {"birthplace", LvxJournal.profileBirthplaceBox},
        {"personality", LvxJournal.profilePersonalityBox},
        {"goals", LvxJournal.profileGoalsBox},
        {"companions", LvxJournal.profileCompanionsBox},
        {"enemies", LvxJournal.profileEnemiesBox},
        {"backstory", LvxJournal.profileBackstoryBox},
    }
    for i = 1, #fields do
        local key = fields[i][1]
        local control = fields[i][2]
        if control then
            local value = control:GetText() or ""
            if profile[key] ~= value then
                profile[key] = value
                changed = true
            end
        end
    end
    if changed and not silent then Msg("Profile saved.") end
    return changed
end

function LvxJournal.LoadProfile()
    local profile = EnsureProfileTable()
    if not profile or not LvxJournal.profileNameBox then return end
    if profile.name == "" then profile.name = GetPlayerNameSafe() end
    if profile.race == "" and GetUnitRace then profile.race = GetUnitRace("player") or "" end
    if profile.class == "" and GetUnitClass then profile.class = GetUnitClass("player") or "" end
    if profile.alliance == "" then
        local alliance = GetUnitAlliance and GetUnitAlliance("player") or nil
        if GetAllianceName and alliance then profile.alliance = GetAllianceName(alliance) or "" end
        if profile.alliance == "" and alliance == 1 then profile.alliance = "Aldmeri Dominion" end
        if profile.alliance == "" and alliance == 2 then profile.alliance = "Ebonheart Pact" end
        if profile.alliance == "" and alliance == 3 then profile.alliance = "Daggerfall Covenant" end
    end

    LvxJournal.profileNameBox:SetText(profile.name or "")
    LvxJournal.profileRaceBox:SetText(profile.race or "")
    LvxJournal.profileClassBox:SetText(profile.class or "")
    LvxJournal.profileAllianceBox:SetText(profile.alliance or "")
    LvxJournal.profileBirthplaceBox:SetText(profile.birthplace or "")
    LvxJournal.profilePersonalityBox:SetText(profile.personality or "")
    LvxJournal.profileGoalsBox:SetText(profile.goals or "")
    LvxJournal.profileCompanionsBox:SetText(profile.companions or "")
    LvxJournal.profileEnemiesBox:SetText(profile.enemies or "")
    LvxJournal.profileBackstoryBox:SetText(profile.backstory or "")
end

local BODY_WRAP_CHARS = 58
local BODY_VISIBLE_LINES = 10
local BODY_SCROLL_VISIBLE_WIDTH = 390
local BODY_SCROLL_VISIBLE_HEIGHT = 245
local BODY_SCROLL_EDIT_WIDTH = 390
local BODY_SCROLL_LINE_HEIGHT = 22
local BODY_SCROLL_WHEEL_LINES = 3

local function ClampNumber(value, minValue, maxValue)
    value = tonumber(value) or 0
    if value < minValue then return minValue end
    if value > maxValue then return maxValue end
    return value
end

local function SplitLines(text)
    text = tostring(text or "")
    text = string.gsub(text, "\r", "")
    local lines = {}
    for line in string.gmatch(text .. "\n", "([^\n]*)\n") do
        table.insert(lines, line)
    end
    if #lines == 0 then table.insert(lines, "") end
    return lines
end

local function WrapOneLine(line, out)
    line = tostring(line or "")
    if line == "" then
        table.insert(out, "")
        return
    end

    while string.len(line) > BODY_WRAP_CHARS do
        local cut = BODY_WRAP_CHARS
        for i = BODY_WRAP_CHARS, 1, -1 do
            local ch = string.sub(line, i, i)
            if ch == " " or ch == "\t" then
                cut = i
                break
            end
        end

        local part = string.sub(line, 1, cut)
        part = string.gsub(part, "%s+$", "")
        if part == "" then
            part = string.sub(line, 1, BODY_WRAP_CHARS)
            cut = BODY_WRAP_CHARS
        end

        table.insert(out, part)
        line = string.sub(line, cut + 1)
        line = string.gsub(line, "^%s+", "")
    end

    table.insert(out, line)
end

local function WrapJournalLines(text)
    local out = {}
    local rawLines = SplitLines(text)
    for i = 1, #rawLines do
        WrapOneLine(rawLines[i], out)
    end
    if #out == 0 then table.insert(out, "") end
    return out
end

local function WrapJournalText(text)
    return table.concat(WrapJournalLines(text), "\n")
end

local function GetBodyFullText()
    if LvxJournal.bodyLines and #LvxJournal.bodyLines > 0 then
        return table.concat(LvxJournal.bodyLines, "\n")
    end
    if LvxJournal.bodyBox then
        return LvxJournal.bodyBox:GetText() or ""
    end
    return ""
end

LvxJournal.GetCurrentBodyText = GetBodyFullText

local function ReplaceVisibleBodyLines(visibleText)
    local offset = LvxJournal.bodyLineOffset or 0
    local oldLines = LvxJournal.bodyLines or {""}
    local editedLines = WrapJournalLines(visibleText or "")
    local newLines = {}

    for i = 1, math.min(offset, #oldLines) do
        table.insert(newLines, oldLines[i])
    end

    for i = 1, #editedLines do
        table.insert(newLines, editedLines[i])
    end

    local afterStart = offset + BODY_VISIBLE_LINES + 1
    for i = afterStart, #oldLines do
        table.insert(newLines, oldLines[i])
    end

    if #newLines == 0 then table.insert(newLines, "") end
    LvxJournal.bodyLines = newLines
end

function LvxJournal.RenderBodyText()
    if not LvxJournal.bodyBox then return end

    local lines = LvxJournal.bodyLines or {""}
    local maxOffset = math.max(0, #lines - BODY_VISIBLE_LINES)
    LvxJournal.bodyLineOffset = ClampNumber(LvxJournal.bodyLineOffset or 0, 0, maxOffset)

    local visible = {}
    for i = 1, BODY_VISIBLE_LINES do
        local line = lines[(LvxJournal.bodyLineOffset or 0) + i]
        if line ~= nil then table.insert(visible, line) end
    end

    local displayText = table.concat(visible, "\n")
    LvxJournal.isRenderingBodyText = true
    LvxJournal.bodyBox:SetText(displayText)
    if LvxJournal.bodyBox.SetCursorPosition then
        LvxJournal.bodyBox:SetCursorPosition(string.len(displayText))
    end
    LvxJournal.isRenderingBodyText = false

    LvxJournal.UpdateBodyScroll(false)
end

function LvxJournal.SetBodyText(text, scrollToBottom)
    LvxJournal.bodyLines = WrapJournalLines(text or "")
    if scrollToBottom then
        LvxJournal.bodyLineOffset = math.max(0, #LvxJournal.bodyLines - BODY_VISIBLE_LINES)
    else
        LvxJournal.bodyLineOffset = 0
    end
    LvxJournal.RenderBodyText()
end

function LvxJournal.ScrollBodyTo(lineOffset)
    if not LvxJournal.bodyLines then return end
    local maxOffset = math.max(0, #LvxJournal.bodyLines - BODY_VISIBLE_LINES)
    LvxJournal.bodyLineOffset = ClampNumber(lineOffset, 0, maxOffset)
    LvxJournal.RenderBodyText()
end

function LvxJournal.ScrollBody(direction)
    if not LvxJournal.bodyLines then return end
    local delta = tonumber(direction) or 0
    LvxJournal.ScrollBodyTo((LvxJournal.bodyLineOffset or 0) - (delta * BODY_SCROLL_WHEEL_LINES))
end

function LvxJournal.UpdateBodyScroll(scrollToBottom)
    if scrollToBottom and LvxJournal.bodyLines then
        LvxJournal.bodyLineOffset = math.max(0, #LvxJournal.bodyLines - BODY_VISIBLE_LINES)
    end

    if LvxJournal.bodyBox then
        LvxJournal.bodyBox:ClearAnchors()
        if LvxJournal.bodyClip then
            LvxJournal.bodyBox:SetAnchor(TOPLEFT, LvxJournal.bodyClip, TOPLEFT, 0, 0)
        else
            LvxJournal.bodyBox:SetAnchor(TOPLEFT, LvxJournal.window, TOPLEFT, 710, 354)
        end
        LvxJournal.bodyBox:SetDimensions(BODY_SCROLL_EDIT_WIDTH, BODY_SCROLL_VISIBLE_HEIGHT)
    end

    if LvxJournal.bodyScrollBar and LvxJournal.bodyScrollThumb and LvxJournal.bodyLines then
        local totalLines = #LvxJournal.bodyLines
        local maxOffset = math.max(0, totalLines - BODY_VISIBLE_LINES)
        if maxOffset <= 0 then
            LvxJournal.bodyScrollBar:SetHidden(true)
            LvxJournal.bodyScrollThumb:SetHidden(true)
        else
            local trackHeight = BODY_SCROLL_VISIBLE_HEIGHT
            local thumbHeight = math.max(28, math.floor((BODY_VISIBLE_LINES / totalLines) * trackHeight))
            local travel = math.max(1, trackHeight - thumbHeight)
            local thumbY = math.floor(((LvxJournal.bodyLineOffset or 0) / maxOffset) * travel)
            LvxJournal.bodyScrollBar:SetHidden(false)
            LvxJournal.bodyScrollThumb:SetHidden(false)
            LvxJournal.bodyScrollThumb:SetDimensions(5, thumbHeight)
            LvxJournal.bodyScrollThumb:ClearAnchors()
            LvxJournal.bodyScrollThumb:SetAnchor(TOPLEFT, LvxJournal.bodyScrollBar, TOPLEFT, 0, thumbY)
        end
    end
end

function LvxJournal.OnBodyTextChanged()
    if LvxJournal.isRenderingBodyText then return end
    if not LvxJournal.bodyBox then return end

    local oldTotal = LvxJournal.bodyLines and #LvxJournal.bodyLines or 1
    ReplaceVisibleBodyLines(LvxJournal.bodyBox:GetText() or "")

    local visibleText = LvxJournal.bodyBox:GetText() or ""
    local visibleLineCount = #SplitLines(visibleText)
    local shouldScrollBottom = visibleLineCount > BODY_VISIBLE_LINES or #LvxJournal.bodyLines > oldTotal

    if shouldScrollBottom then
        LvxJournal.bodyLineOffset = math.max(0, #LvxJournal.bodyLines - BODY_VISIBLE_LINES)
        LvxJournal.RenderBodyText()
    else
        LvxJournal.UpdateBodyScroll(false)
    end
end

function LvxJournal.ApplyBodyWrap()
    if not LvxJournal.bodyBox then return end
    if LvxJournal.isRenderingBodyText then return end

    ReplaceVisibleBodyLines(LvxJournal.bodyBox:GetText() or "")
    LvxJournal.RenderBodyText()
end

function LvxJournal.AutoSaveCurrentEntry(silent)
    local s = LvxJournal.savedVars
    if not s then return false end
    if s.viewMode ~= "edit" then return false end
    if not LvxJournal.titleBox or not LvxJournal.bodyBox then return false end

    local index = s.selectedIndex or 1
    local entry = s.entries[index]
    if not entry then return false end

    local newTitle = LvxJournal.titleBox:GetText() or ""
    LvxJournal.ApplyBodyWrap()
    local newBody = GetBodyFullText()

    if newTitle == "" then
        newTitle = "Untitled Entry"
    end

    local changed = false
    if entry.title ~= newTitle then
        entry.title = newTitle
        changed = true
    end
    if entry.body ~= newBody then
        entry.body = newBody
        changed = true
    end

    if LvxJournal.pinNameBox then
        local newPinName = tostring(LvxJournal.pinNameBox:GetText() or "")
        if string.len(newPinName) > 40 then
            newPinName = string.sub(newPinName, 1, 40)
        end
        if entry.pinName ~= newPinName then
            entry.pinName = newPinName
            changed = true
        end
        if LvxJournal.GetSelectedEntryMapMarkIndex and s.mapMarks then
            local markIndex = LvxJournal.GetSelectedEntryMapMarkIndex()
            if markIndex and s.mapMarks[markIndex] then
                s.mapMarks[markIndex].pinName = newPinName
                s.mapMarks[markIndex].title = newTitle
            end
        end
    end

    if changed then
        entry.modified = GetStampText()
        entry.timeMode = s.useRoleplayTime and "Roleplay Time" or "Real Time"
        if not silent then Msg("Entry saved.") end
    end

    return changed
end

function LvxJournal.AddManualEntry()
    if LvxJournal.savedVars then
        LvxJournal.savedVars.activeChronicleKey = "JournalNew"
    end
    LvxJournal.OpenTemplateChooser()
    if LvxJournal.savedVars then
        LvxJournal.savedVars.activeChronicleKey = "JournalNew"
    end
end

function LvxJournal_NewEntryKeybind()
    LvxJournal.ToggleWindow(true)
    LvxJournal.AddManualEntry()
end

function LvxJournal.ApplyTheme()
    local theme = GetCurrentTheme()
    if not theme then return end
    if LvxJournal.bookTexture then
        LvxJournal.bookTexture:SetTexture(theme.texture)
    end
end

function LvxJournal.SetTheme(themeKey)
    local theme = GetThemeByKey(themeKey)
    if not theme then return end
    LvxJournal.savedVars.theme = theme.key
    LvxJournal.ApplyTheme()
    LvxJournal.RefreshOptionsPage()
    Msg("Theme set to: " .. theme.name)
end

function LvxJournal.NextTheme()
    local currentKey = (LvxJournal.savedVars and LvxJournal.savedVars.theme) or "blank"
    local nextIndex = 1
    for i = 1, #journalThemes do
        if journalThemes[i].key == currentKey then
            nextIndex = i + 1
            break
        end
    end
    if nextIndex > #journalThemes then nextIndex = 1 end
    LvxJournal.SetTheme(journalThemes[nextIndex].key)
end

local function SetJournalMouseFocus(enabled)
    if SetGameCameraUIMode then
        SafeCall(SetGameCameraUIMode, enabled == true)
    elseif SCENE_MANAGER and SCENE_MANAGER.SetInUIMode then
        SafeCall(SCENE_MANAGER.SetInUIMode, SCENE_MANAGER, enabled == true)
    end
end

function LvxJournal.ApplyMouseFocusForWindow(opening)
    local s = LvxJournal.savedVars
    if not s or s.autoFocusMouse ~= true then return end
    SetJournalMouseFocus(opening == true)
end

function LvxJournal.ToggleAutoFocusMouse()
    local s = LvxJournal.savedVars
    if not s then return end

    s.autoFocusMouse = not (s.autoFocusMouse == true)
    if LvxJournal.window and not LvxJournal.window:IsHidden() then
        LvxJournal.ApplyMouseFocusForWindow(true)
    end

    LvxJournal.RefreshOptionsPage()
    Msg("Auto focus mouse: " .. (s.autoFocusMouse and "ON" or "OFF"))
end

function LvxJournal.ToggleHelpTooltips()
    local s = LvxJournal.savedVars
    if not s then return end
    s.showHelpTooltips = not (s.showHelpTooltips == true)
    if LvxJournal.RefreshOptionsPage then LvxJournal.RefreshOptionsPage() end
    Msg("Hover help: " .. (s.showHelpTooltips and "ON" or "OFF"))
end


function LvxJournal.ToggleQuestTracking()
    local s = LvxJournal.savedVars
    if not s then return end
    s.trackQuestLog = not (s.trackQuestLog == true)
    s.autoQuestAdded = s.trackQuestLog
    s.autoQuestUpdated = s.trackQuestLog
    s.autoQuestCompleted = s.trackQuestLog
    if LvxJournal.RefreshOptionsPage then LvxJournal.RefreshOptionsPage() end
    Msg("Quest tracking: " .. (s.trackQuestLog and "ON" or "OFF"))
end

function LvxJournal.ToggleAchievementTracking()
    local s = LvxJournal.savedVars
    if not s then return end
    s.trackAchievementLog = not (s.trackAchievementLog == true)
    s.autoAchievements = s.trackAchievementLog
    if LvxJournal.RefreshOptionsPage then LvxJournal.RefreshOptionsPage() end
    Msg("Achievement tracking: " .. (s.trackAchievementLog and "ON" or "OFF"))
end

function LvxJournal.ToggleTributeTrackingLog()
    local s = LvxJournal.savedVars
    if not s then return end
    s.trackTributeLog = not (s.trackTributeLog == true)
    if LvxJournal.RefreshOptionsPage then LvxJournal.RefreshOptionsPage() end
    Msg("Tales of Tribute tracking: " .. (s.trackTributeLog and "ON" or "OFF"))
end

function LvxJournal.ShowOptionsPage(pageName)
    local s = LvxJournal.savedVars
    if not s then return end
    s.filter = "Options"
    s.viewMode = "options"
    s.optionsPage = pageName or "main"
    LvxJournal.currentChronicleMenu = "options"
    if LvxJournal.RefreshAll then
        LvxJournal.RefreshAll()
    elseif LvxJournal.RefreshOptionsPage then
        LvxJournal.RefreshOptionsPage()
    end
end

function LvxJournal.OpenOptionsSection(pageName)
    LvxJournal.AutoSaveCurrentEntry(true)
    LvxJournal.AutoSaveProfile(true)
    LvxJournal.ShowOptionsPage(pageName or "main")
end

function LvxJournal.DeleteAllJournalEntriesConfirmed()
    local s = LvxJournal.savedVars
    if not s then return end

    s.entries = {}
    s.mapMarks = {}
    s.selectedIndex = 1
    s.lastOpenedIndex = nil
    s.archivePage = 1
    s.pendingDeleteIndex = nil
    s.pendingDeleteAllEntries = nil
    s.viewMode = "archive"

    if LvxJournal.ClearCustomMapPins then LvxJournal.ClearCustomMapPins() end
    if LvxJournal.ClearInternalFallbackPinsSafe then LvxJournal.ClearInternalFallbackPinsSafe() end
    if LvxJournal.RefreshMapPins then LvxJournal.RefreshMapPins(true) end
    if LvxJournal.PulseMinimapRefresh then LvxJournal.PulseMinimapRefresh() end
    if LvxJournal.RefreshAll then LvxJournal.RefreshAll() end

    Msg("Journal entries and map pins cleared.")
end

function LvxJournal.ConfirmDeleteAllJournalEntries()
    local s = LvxJournal.savedVars
    if not s then return end

    if ZO_Dialogs_RegisterCustomDialog and ZO_Dialogs_ShowDialog and not LvxJournal.deleteAllDialogRegistered then
        ZO_Dialogs_RegisterCustomDialog("LVX_JOURNAL_DELETE_ALL_CONFIRM", {
            title = { text = "Delete All Journal Entries" },
            mainText = { text = "Delete all journal entries and all linked map pins?\n\nThis cannot be undone." },
            buttons = {
                { text = SI_DIALOG_ACCEPT, callback = function() LvxJournal.DeleteAllJournalEntriesConfirmed() end },
                { text = SI_DIALOG_CANCEL, callback = function() if LvxJournal.savedVars then LvxJournal.savedVars.pendingDeleteAllEntries = nil end end },
            }
        })
        LvxJournal.deleteAllDialogRegistered = true
    end

    if ZO_Dialogs_ShowDialog and LvxJournal.deleteAllDialogRegistered then
        ZO_Dialogs_ShowDialog("LVX_JOURNAL_DELETE_ALL_CONFIRM")
        return
    end

    if s.pendingDeleteAllEntries == true then
        s.pendingDeleteAllEntries = nil
        LvxJournal.DeleteAllJournalEntriesConfirmed()
    else
        s.pendingDeleteAllEntries = true
        Msg("Press Delete All Entries again to confirm.")
    end
end

function LvxJournal.RefreshOptionsPage()
    if not LvxJournal.optionsControls then return end
    if LvxJournal.savedVars and LvxJournal.savedVars.viewMode ~= "options" then
        for i = 1, #LvxJournal.optionsControls do
            local control = LvxJournal.optionsControls[i]
            if control and control.SetHidden then
                control:SetHidden(true)
            end
        end
        return
    end
    local currentTheme = GetCurrentTheme()
    local page = (LvxJournal.savedVars and LvxJournal.savedVars.optionsPage) or "main"

    if LvxJournal.optionsTitle then
        local titleText = "Options"
        if page == "themes" then titleText = "Options - Themes"
        elseif page == "commands" then titleText = "Options - Commands"
        elseif page == "mappins" then titleText = "Options - Map Pins"
        elseif page == "controls" then titleText = "Options - Controls"
        elseif page == "maintenance" then titleText = "Options - Maintenance"
        elseif page == "help" then titleText = "Options - Help"
        end
        LvxJournal.optionsTitle:SetText(titleText)
    end

    local showMain = page == "main"
    local showThemes = page == "themes"
    local showCommands = page == "commands"
    local showMapPins = page == "mappins"
    local showControls = page == "controls"
    local showMaintenance = page == "maintenance"
    local showHelp = page == "help"

    if LvxJournal.optionsThemesButton then
        LvxJournal.optionsThemesButton:SetHidden(true)
        LvxJournal.optionsThemesButton:SetText("Themes")
    end
    if LvxJournal.optionsCommandsButton then
        LvxJournal.optionsCommandsButton:SetHidden(true)
        LvxJournal.optionsCommandsButton:SetText("Commands")
    end
    if LvxJournal.optionsMapPinsButton then
        LvxJournal.optionsMapPinsButton:SetHidden(true)
        LvxJournal.optionsMapPinsButton:SetText("Map Pins")
    end
    if LvxJournal.optionsControlsButton then
        LvxJournal.optionsControlsButton:SetHidden(true)
        LvxJournal.optionsControlsButton:SetText("Controls")
    end
    if LvxJournal.optionsMaintenanceButton then
        LvxJournal.optionsMaintenanceButton:SetHidden(true)
        LvxJournal.optionsMaintenanceButton:SetText("Maintenance")
    end
    if LvxJournal.optionsBackButton then
        LvxJournal.optionsBackButton:SetHidden(true)
    end

    if LvxJournal.themeCurrentLabel then
        LvxJournal.themeCurrentLabel:SetHidden(not showThemes)
        if currentTheme then
            LvxJournal.themeCurrentLabel:SetText("Current Theme: " .. currentTheme.name)
        end
    end
    if LvxJournal.themeHelpLabel then
        LvxJournal.themeHelpLabel:SetHidden(not showThemes)
    end
    if LvxJournal.themeNoteLabel then
        LvxJournal.themeNoteLabel:SetHidden(not showThemes)
        LvxJournal.themeNoteLabel:SetText("")
    end
    if LvxJournal.nextThemeButton then
        LvxJournal.nextThemeButton:SetHidden(not showThemes)
    end

    if LvxJournal.themeRows then
        for i = 1, #LvxJournal.themeRows do
            local row = LvxJournal.themeRows[i]
            local theme = row.theme
            if theme and row.button then
                row.button:SetHidden(not showThemes)
                local prefix = theme.key == currentTheme.key and "* " or ""
                row.button:SetText(prefix .. theme.name)
            end
        end
    end

    if LvxJournal.commandsTitleLabel then
        LvxJournal.commandsTitleLabel:SetHidden(not showCommands)
    end
    if LvxJournal.commandsHelpLabel then
        LvxJournal.commandsHelpLabel:SetHidden(not showCommands)
        LvxJournal.commandsHelpLabel:SetText(
            "/journal - Open journal\n" ..
            "/journal new - New entry\n" ..
            "/journal save - Save entry\n" ..
            "/journal search <word>\n" ..
            "/journal stats / stats next / stats prev\n" ..
            "/journal dice\n" ..
            "/journal mark - Save map mark\n" ..
            "/journal marks - View marks\n" ..
            "/journal deletemark\n" ..
            "/journal markicon\n" ..
            "/journal togglemarks\n" ..
            "/journal autopin\n" ..
            "/journal fallbackpins\n" ..
            "/journal mousefocus\n" ..
            "/journal zoompin\n" ..
            "/journal pinnames\n" ..
            "/journal pintitles\n" ..
            "/journal tribute win / loss / reset\n" ..
            "/journal killtest\n\n" ..
            "Map Pins:\n" ..
            "Custom pins draw on the main ESO map.\n" ..
            "If LibMapPins is installed, LvxJournal registers a real LibMapPins pin type and map filter for minimap/addon compatibility.\n" ..
            "Pins only show when the saved map matches the currently opened zone map.\n\n" ..
            "Map Marks page:\n" ..
            "Tools > Map Marks lets you save, view, delete, and refresh journal pins."
        )
    end

    if LvxJournal.mapPinsOptionsTitle then LvxJournal.mapPinsOptionsTitle:SetHidden(true) end
    if LvxJournal.mapPinsToggleButton then
        LvxJournal.mapPinsToggleButton:SetHidden(not showMapPins)
        LvxJournal.mapPinsToggleButton:SetText((LvxJournal.savedVars and LvxJournal.savedVars.showMapPins == false) and "Show Map Pins" or "Hide Map Pins")
    end
    if LvxJournal.autoPinEntriesButton then
        LvxJournal.autoPinEntriesButton:SetHidden(not showMapPins)
        LvxJournal.autoPinEntriesButton:SetText((LvxJournal.savedVars and LvxJournal.savedVars.autoPinJournalEntries == true) and "Auto Pin: ON" or "Auto Pin: OFF")
    end
    if LvxJournal.mapPinFallbackButton then
        LvxJournal.mapPinFallbackButton:SetHidden(not showMapPins)
        LvxJournal.mapPinFallbackButton:SetText((LvxJournal.savedVars and LvxJournal.savedVars.useBuiltInMapPinFallback == true) and "Fallback Only: ON" or "Fallback Only: OFF")
    end
    if LvxJournal.mapPinsIconButton then
        LvxJournal.mapPinsIconButton:SetHidden(not showMapPins)
        local iconName = LvxJournal.GetMapMarkIconName and LvxJournal.GetMapMarkIconName((LvxJournal.savedVars and LvxJournal.savedVars.mapMarkIcon) or "book") or "Book"
        LvxJournal.mapPinsIconButton:SetText("Icon: " .. iconName)
    end
    if LvxJournal.mapPinNamesButton then
        LvxJournal.mapPinNamesButton:SetHidden(not showMapPins)
        LvxJournal.mapPinNamesButton:SetText((LvxJournal.savedVars and LvxJournal.savedVars.showMapPinNames == true) and "Pin Names: ON" or "Pin Names: OFF")
    end
    if LvxJournal.pinTitleNamesButton then
        LvxJournal.pinTitleNamesButton:SetHidden(not showMapPins)
        LvxJournal.pinTitleNamesButton:SetText((LvxJournal.savedVars and LvxJournal.savedVars.useJournalTitleForPinName == false) and "Journal Titles: OFF" or "Journal Titles: ON")
    end
    if LvxJournal.mapPinsOptionsText then
        LvxJournal.mapPinsOptionsText:SetHidden(not showMapPins)
        local backendText = LvxJournal.GetMapPinBackendStatusText and LvxJournal.GetMapPinBackendStatusText() or "Backend: Unknown"
        LvxJournal.mapPinsOptionsText:SetText(
            backendText .. "\n\n" ..
            "Visibility controls journal map pins. When LibMapPins is active, the built-in overlay is normally disabled to prevent duplicate/sliding pins.\n\n" ..
            "Fallback Only is for testing. It ignores LibMapPins and uses LvxJournal's internal ESO map-pin renderer. Internal pins support hover tooltips and click-to-open.\n\n" ..
            "Auto Pin creates a marker when an edited entry is saved or returned to read mode, if that entry has no marker yet.\n\n" ..
            "Icon controls new saved marks. Existing marks keep their saved icon.\n\n" ..
            "Pin Names shows text beside visible pins when supported.\n\n" ..
            "Journal Titles ON uses the entry title unless a short pin name is set in Edit Mode. OFF uses only the short pin name.\n\n" ..
            "Icons: Book, Quill, Star, X Mark."
        )
    end

    if LvxJournal.controlsOptionsTitle then LvxJournal.controlsOptionsTitle:SetHidden(not showControls) end
    if LvxJournal.autoMouseFocusButton then
        LvxJournal.autoMouseFocusButton:SetHidden(not showControls)
        LvxJournal.autoMouseFocusButton:SetText((LvxJournal.savedVars and LvxJournal.savedVars.autoFocusMouse == true) and "Auto Mouse: ON" or "Auto Mouse: OFF")
    end
    if LvxJournal.controlsOptionsText then
        LvxJournal.controlsOptionsText:SetHidden(not showControls)
        LvxJournal.controlsOptionsText:SetText(
            "Auto Mouse Focus unlocks/shows the mouse cursor when the journal opens.\n\n" ..
            "When the journal closes, it tries to return control to normal camera mode.\n\n" ..
            "Use this if you do not want to press Enter every time you open the journal."
        )
    end

    if LvxJournal.optionsMainTitle then
        LvxJournal.optionsMainTitle:SetHidden(not showMain)
        LvxJournal.optionsMainTitle:SetText("Choose an options section from the left page.")
    end
    if LvxJournal.optionsMainHelp then
        LvxJournal.optionsMainHelp:SetHidden(not showMain)
        LvxJournal.optionsMainHelp:SetText(
            "Open the left-side Options menu to pick Themes, Commands, Map Pins, Controls, or Maintenance.\n\n" ..
            "This keeps the right page for the selected options content instead of listing the categories here."
        )
    end

    if LvxJournal.maintenanceTitleLabel then LvxJournal.maintenanceTitleLabel:SetHidden(not showMaintenance) end
    if LvxJournal.questTrackingButton then
        LvxJournal.questTrackingButton:SetHidden(not showMaintenance)
        LvxJournal.questTrackingButton:SetText((LvxJournal.savedVars and LvxJournal.savedVars.trackQuestLog == true) and "Quest Tracking: ON" or "Quest Tracking: OFF")
    end
    if LvxJournal.achievementTrackingButton then
        LvxJournal.achievementTrackingButton:SetHidden(not showMaintenance)
        LvxJournal.achievementTrackingButton:SetText((LvxJournal.savedVars and LvxJournal.savedVars.trackAchievementLog == true) and "Achievements: ON" or "Achievements: OFF")
    end
    if LvxJournal.tributeTrackingButton then
        LvxJournal.tributeTrackingButton:SetHidden(not showMaintenance)
        LvxJournal.tributeTrackingButton:SetText((LvxJournal.savedVars and LvxJournal.savedVars.trackTributeLog == true) and "Tribute: ON" or "Tribute: OFF")
    end
    if LvxJournal.deleteAllEntriesButton then
        LvxJournal.deleteAllEntriesButton:SetHidden(not showMaintenance)
        LvxJournal.deleteAllEntriesButton:SetText("Delete All Entries")
    end
    if LvxJournal.maintenanceHelpLabel then LvxJournal.maintenanceHelpLabel:SetHidden(not showMaintenance) end

    if LvxJournal.helpOptionsTitle then LvxJournal.helpOptionsTitle:SetHidden(not showHelp) end
    if LvxJournal.helpTooltipsButton then
        LvxJournal.helpTooltipsButton:SetHidden(not showHelp)
        local helpText = (LvxJournal.savedVars and LvxJournal.savedVars.showHelpTooltips == false) and "Hover Help: OFF" or "Hover Help: ON"
        LvxJournal.helpTooltipsButton:SetText(helpText)
        if SetJournalTooltip and GetJournalTooltipText then
            SetJournalTooltip(LvxJournal.helpTooltipsButton, GetJournalTooltipText(helpText))
        end
    end
    if LvxJournal.helpOptionsText then
        LvxJournal.helpOptionsText:SetHidden(not showHelp)
        LvxJournal.helpOptionsText:SetText(
            "Hover Help shows a small explanation box when the mouse is held over supported journal buttons and menu entries.\n\n" ..
            "Use the Hover Help toggle above to turn those explanations on or off.\n\n" ..
            "Journal Basics:\n" ..
            "New starts a new entry. Archive opens saved entries. Save stores the current entry. Del removes the current entry. Book marks an entry as a favorite. Find searches the journal, map markers, Codex, Profile, and Stats.\n\n" ..
            "Map Marks:\n" ..
            "Tools > Map Marks lets you save your current map position, page through saved marks, zoom to a mark by clicking its Pos line, delete the selected mark, change icons, and refresh pins."
        )
    end
end

function LvxJournal.SetFilter(filter, statsPage)
    LvxJournal.AutoSaveCurrentEntry(true)
    LvxJournal.AutoSaveProfile(true)
    LvxJournal.savedVars.filter = filter
    LvxJournal.savedVars.archivePage = 1
    if filter == "Stats" then
        LvxJournal.savedVars.viewMode = "stats"
        LvxJournal.savedVars.stats = LvxJournal.savedVars.stats or {}
        if statsPage then
            LvxJournal.savedVars.stats.statsPage = statsPage
        end
    elseif filter == "Profile" then
        LvxJournal.savedVars.viewMode = "profile"
    elseif filter == "Codex" then
        LvxJournal.savedVars.viewMode = "codex"
    elseif filter == "Options" then
        LvxJournal.savedVars.viewMode = "options"
        LvxJournal.savedVars.optionsPage = "main"
        LvxJournal.currentChronicleMenu = "options"
    else
        LvxJournal.savedVars.viewMode = "archive"
    end
    LvxJournal.RefreshAll()
end


function LvxJournal.ShowToolsPage(pageName)
    LvxJournal.AutoSaveCurrentEntry(true)
    LvxJournal.AutoSaveProfile(true)
    LvxJournal.savedVars.toolsPage = pageName or "main"
    LvxJournal.savedVars.viewMode = "tools"
    LvxJournal.RefreshAll()
end

function LvxJournal.ShowChronicleMenu(menuName)
    LvxJournal.currentChronicleMenu = menuName or "main"
    LvxJournal.RefreshCategoryButtons()
end

function LvxJournal.HandleChronicleMenuItem(item)
    if not item then return end
    if item.key then
        LvxJournal.savedVars.activeChronicleKey = item.key
    end
    if item.action == "optionsMenu" then
        LvxJournal.OpenOptionsSection("main")
    elseif item.menu then
        LvxJournal.ShowChronicleMenu(item.menu)
    elseif item.filter then
        LvxJournal.SetFilter(item.filter, item.statsPage)
    elseif item.view == "tools" then
        LvxJournal.ShowToolsPage(item.page or "main")
    elseif item.view == "options" then
        LvxJournal.OpenOptionsSection(item.page or "main")
    elseif item.action == "new" then
        LvxJournal.savedVars.activeChronicleKey = "JournalNew"
        LvxJournal.AddManualEntry()
    elseif item.action == "save" then
        LvxJournal.savedVars.activeChronicleKey = "JournalSave"
        LvxJournal.SaveCurrentEntry()
    elseif item.action == "addMapMarker" then
        LvxJournal.savedVars.activeChronicleKey = "JournalMapMarker"
        LvxJournal.AddMapMarkFromCurrentLocation()
    elseif item.action == "search" then
        LvxJournal.savedVars.activeChronicleKey = "JournalSearch"
        LvxJournal.OpenSearch()
    elseif item.action == "templates" then
        LvxJournal.savedVars.activeChronicleKey = "JournalTemplates"
        LvxJournal.OpenTemplateChooser()
    elseif item.action == "archive" then
        LvxJournal.ShowArchive()
    end
end

function LvxJournal.SaveCurrentEntry()
    if LvxJournal.savedVars then
        LvxJournal.savedVars.activeChronicleKey = "JournalSave"
    end
    local profileChanged = LvxJournal.AutoSaveProfile(false)
    local changed = LvxJournal.AutoSaveCurrentEntry(false)
    if LvxJournal.AutoPinSelectedEntryIfNeeded then
        LvxJournal.AutoPinSelectedEntryIfNeeded()
    end
    LvxJournal.RefreshAll()
    if not changed and not profileChanged then Msg("Entry already saved.") end
end


function LvxJournal.RemoveMapMarksForDeletedEntry(deletedIndex)
    local s = LvxJournal.savedVars
    deletedIndex = tonumber(deletedIndex) or 0
    if not s or not s.mapMarks or deletedIndex <= 0 then return 0 end

    local removed = 0
    local i = #s.mapMarks
    while i >= 1 do
        local mark = s.mapMarks[i]
        local entryIndex = mark and tonumber(mark.entryIndex) or 0

        if entryIndex == deletedIndex then
            table.remove(s.mapMarks, i)
            removed = removed + 1
        elseif entryIndex > deletedIndex then
            mark.entryIndex = entryIndex - 1
        end

        i = i - 1
    end

    if removed > 0 and LvxJournal.RefreshMapPins then
        LvxJournal.RefreshMapPins(true)
    end
    if removed > 0 and LvxJournal.PulseMinimapRefresh then
        LvxJournal.PulseMinimapRefresh()
    end

    return removed
end

function LvxJournal.PerformDeleteCurrentEntry()
    local s = LvxJournal.savedVars
    if not s then return end
    local index = s.pendingDeleteIndex or s.selectedIndex or 1

    if s.entries[index] then
        local removedPins = 0
        if LvxJournal.RemoveMapMarksForDeletedEntry then
            removedPins = LvxJournal.RemoveMapMarksForDeletedEntry(index)
        end

        table.remove(s.entries, index)
        if index > #s.entries then index = #s.entries end
        if index < 1 then index = 1 end
        s.selectedIndex = index
        s.pendingDeleteIndex = nil
        s.viewMode = "archive"
        LvxJournal.RefreshAll()

        if removedPins and removedPins > 0 then
            Msg("Entry deleted. Removed linked map pin.")
        else
            Msg("Entry deleted.")
        end
    end
end

function LvxJournal.DeleteCurrentEntry()
    local s = LvxJournal.savedVars
    if not s then return end
    local index = s.selectedIndex or 1
    local entry = s.entries[index]
    if not entry then return end

    s.pendingDeleteIndex = index
    if ZO_Dialogs_RegisterCustomDialog and ZO_Dialogs_ShowDialog and not LvxJournal.deleteDialogRegistered then
        ZO_Dialogs_RegisterCustomDialog("LVX_JOURNAL_DELETE_CONFIRM", {
            title = { text = "Delete Journal Entry" },
            mainText = { text = "Delete this entry?\n\nThis cannot be undone." },
            buttons = {
                { text = SI_DIALOG_ACCEPT, callback = function() LvxJournal.PerformDeleteCurrentEntry() end },
                { text = SI_DIALOG_CANCEL, callback = function() if LvxJournal.savedVars then LvxJournal.savedVars.pendingDeleteIndex = nil end end },
            }
        })
        LvxJournal.deleteDialogRegistered = true
    end

    if ZO_Dialogs_ShowDialog and LvxJournal.deleteDialogRegistered then
        ZO_Dialogs_ShowDialog("LVX_JOURNAL_DELETE_CONFIRM")
    else
        if s.pendingDeleteArmed == index then
            s.pendingDeleteArmed = nil
            LvxJournal.PerformDeleteCurrentEntry()
        else
            s.pendingDeleteArmed = index
            Msg("Click Del again to confirm deleting this entry.")
        end
    end
end

function LvxJournal.ToggleFavorite()
    LvxJournal.AutoSaveCurrentEntry(true)
    local entry = LvxJournal.savedVars.entries[LvxJournal.savedVars.selectedIndex or 1]
    if not entry then return end

    entry.favorite = not entry.favorite
    if entry.favorite then
        Msg("Entry bookmarked.")
    else
        Msg("Bookmark removed.")
    end
    LvxJournal.RefreshAll()
end

function LvxJournal.LoadSelectedEntry()
    local s = LvxJournal.savedVars
    local entry = s.entries[s.selectedIndex or 1]

    if not LvxJournal.titleBox or not LvxJournal.bodyBox or not LvxJournal.metaLabel then return end

    if not entry then
        LvxJournal.titleBox:SetText("")
        LvxJournal.SetBodyText("", false)
        LvxJournal.metaLabel:SetText("No entry selected.")
        if LvxJournal.pinNameBox then
            LvxJournal.suppressPinNameChange = true
            LvxJournal.pinNameBox:SetText("")
            LvxJournal.suppressPinNameChange = false
        end
        return
    end

    LvxJournal.titleBox:SetText(entry.title or "")
    if LvxJournal.pinNameBox then
        LvxJournal.suppressPinNameChange = true
        LvxJournal.pinNameBox:SetText(entry.pinName or "")
        LvxJournal.suppressPinNameChange = false
    end
    LvxJournal.SetBodyText(entry.body or "", false)
    LvxJournal.bodyPreviousTextLength = string.len(entry.body or "")

    local function CleanMetaStamp(value)
        value = tostring(value or "")
        value = string.gsub(value, "\r", "")
        value = string.match(value, "([^\n]+)") or value
        value = string.gsub(value, "%s+", " ")
        value = string.gsub(value, "^%s+", "")
        value = string.gsub(value, "%s+$", "")
        return value
    end

    local lines = {}
    local header = GetCategoryDisplay(entry)
    if entry.location and entry.location ~= "" and entry.location ~= "Unknown" then
        header = header .. " - " .. entry.location
    end
    if entry.favorite then
        header = header .. " - Bookmarked"
    end
    table.insert(lines, header)

    local createdText = CleanMetaStamp(entry.time)
    if createdText ~= "" then
        table.insert(lines, "Created: " .. createdText)
    end

    local editedText = CleanMetaStamp(entry.modified)
    if editedText ~= "" and editedText ~= createdText and entry.modified ~= entry.time then
        table.insert(lines, "Edited: " .. editedText)
    end

    LvxJournal.metaLabel:SetText(table.concat(lines, "\n"))
end

function LvxJournal.LoadReadEntry()
    local s = LvxJournal.savedVars
    if not s then return end

    local entry = s.entries[s.selectedIndex or 1]
    if not entry then
        if LvxJournal.readTitle then LvxJournal.readTitle:SetText("No Entry Selected") end
        if LvxJournal.readMeta then LvxJournal.readMeta:SetText("Choose an entry from the archive.") end
        if LvxJournal.readBody then LvxJournal.readBody:SetText("") end
        return
    end

    if LvxJournal.readTitle then
        LvxJournal.readTitle:SetText(entry.title or "Untitled Entry")
    end

    if LvxJournal.readMeta then
        local meta = GetCategoryDisplay(entry)
        if entry.location and entry.location ~= "" and entry.location ~= "Unknown" then
            meta = meta .. " - " .. entry.location
        end
        if entry.favorite then
            meta = meta .. " - Bookmarked"
        end
        if LvxJournal.SelectedEntryHasMapMark and LvxJournal.SelectedEntryHasMapMark() then
            meta = meta .. " - Map Marked"
        end
        LvxJournal.readMeta:SetText(meta)
    end

    if LvxJournal.readBody then
        LvxJournal.readBody:SetText(WrapJournalText(entry.body or ""))
    end

    if LvxJournal.readZoomPinButton then
        local hasMark = LvxJournal.SelectedEntryHasMapMark and LvxJournal.SelectedEntryHasMapMark()
        LvxJournal.readZoomPinButton:SetHidden(not hasMark)
    end
end


function LvxJournal.RefreshEditorMapButtons()
    if not LvxJournal.savedVars then return end
    if LvxJournal.savedVars.viewMode == "edit" and LvxJournal.HideToolsControlsHard then
        LvxJournal.HideToolsControlsHard()
    end

    if LvxJournal.editorMapButton then
        if LvxJournal.SelectedEntryHasMapMark and LvxJournal.SelectedEntryHasMapMark() then
            LvxJournal.editorMapButton:SetText("Remove Pin")
            LvxJournal.editorMapButton:SetDimensions(96, 24)
        else
            LvxJournal.editorMapButton:SetText("Add Pin")
            LvxJournal.editorMapButton:SetDimensions(86, 24)
        end
    end

    if LvxJournal.editorMapIconButton then
        local iconName = LvxJournal.GetMapMarkIconName and LvxJournal.GetMapMarkIconName((LvxJournal.savedVars and LvxJournal.savedVars.mapMarkIcon) or "book") or "Icon"
        LvxJournal.editorMapIconButton:SetText("Icon: " .. iconName)
        LvxJournal.editorMapIconButton:SetDimensions(104, 24)
    end

    if LvxJournal.editorPinToggleButton then
        local hasMark = LvxJournal.SelectedEntryHasMapMark and LvxJournal.SelectedEntryHasMapMark()
        LvxJournal.editorPinToggleButton:SetText(hasMark and "[X]" or "[ ]")
    end

    if LvxJournal.editorZoomPinButton then
        local hasMark = LvxJournal.SelectedEntryHasMapMark and LvxJournal.SelectedEntryHasMapMark()
        LvxJournal.editorZoomPinButton:SetHidden(not hasMark)
    end
end

function LvxJournal.EditSelectedEntry()
    local s = LvxJournal.savedVars
    if not s then return end
    if not s.entries[s.selectedIndex or 1] then return end
    s.viewMode = "edit"
    LvxJournal.RefreshAll()
end

function LvxJournal.ReturnToReadMode()
    local s = LvxJournal.savedVars
    if not s then return end
    if not s.entries[s.selectedIndex or 1] then return end
    LvxJournal.AutoSaveCurrentEntry(true)
    if LvxJournal.AutoPinSelectedEntryIfNeeded then
        LvxJournal.AutoPinSelectedEntryIfNeeded()
    end
    s.viewMode = "read"
    LvxJournal.RefreshAll()
end

local function FormatDistance(meters)
    meters = tonumber(meters) or 0
    local km = meters / 1000
    local miles = meters / 1609.344
    return string.format("%.2f km / %.2f miles", km, miles)
end

local function CountEntriesByCategory(category)
    local s = LvxJournal.savedVars
    if not s then return 0 end
    local n = 0
    for i = 1, #s.entries do
        local e = s.entries[i]
        if category == "Bookmarks" then
            if e.favorite then n = n + 1 end
        elseif category == "All" then
            n = n + 1
        elseif e.category == category then
            n = n + 1
        end
    end
    return n
end


local function SafeGlobalValue(name)
    local value = nil
    local ok, result = pcall(function() return _G[name] end)
    if ok then value = result end
    return value
end

local function CombatUnitTypeEquals(value, globalName)
    local globalValue = SafeGlobalValue(globalName)
    return globalValue ~= nil and value == globalValue
end

local function IsPlayerCombatSource(sourceType, sourceName)
    if CombatUnitTypeEquals(sourceType, "COMBAT_UNIT_TYPE_PLAYER") then return true end
    if CombatUnitTypeEquals(sourceType, "COMBAT_UNIT_TYPE_PLAYER_PET") then return true end
    if CombatUnitTypeEquals(sourceType, "COMBAT_UNIT_TYPE_GROUP") then return true end

    local playerName = SafeCall(GetUnitName, "player")
    if playerName and sourceName and sourceName ~= "" and sourceName == playerName then
        return true
    end

    return false
end

local function IsEnemyTargetType(targetType)
    if CombatUnitTypeEquals(targetType, "COMBAT_UNIT_TYPE_PLAYER") then return false end
    if CombatUnitTypeEquals(targetType, "COMBAT_UNIT_TYPE_PLAYER_PET") then return false end
    return true
end

local function NormalizeKillName(name)
    name = tostring(name or "")
    name = name:gsub("%^.*$", "")
    name = name:gsub("^%s+", "")
    name = name:gsub("%s+$", "")
    if name == "" then
        return "Unknown Enemy"
    end
    return name
end

function LvxJournal.RefreshBossNameCache()
    LvxJournal.recentBossNames = LvxJournal.recentBossNames or {}
    local now = SafeCall(GetFrameTimeMilliseconds) or (GetTimeStamp and (GetTimeStamp() * 1000)) or 0

    for i = 1, 12 do
        local unitTag = "boss" .. tostring(i)
        local bossName = SafeCall(GetUnitName, unitTag)
        bossName = NormalizeKillName(bossName)
        if bossName ~= "Unknown Enemy" then
            LvxJournal.recentBossNames[bossName] = now
        end
    end
end

local function IsKnownBossKill(targetName)
    LvxJournal.RefreshBossNameCache()
    local bosses = LvxJournal.recentBossNames or {}
    local now = SafeCall(GetFrameTimeMilliseconds) or (GetTimeStamp and (GetTimeStamp() * 1000)) or 0
    local seenAt = bosses[targetName]
    if seenAt and (now - seenAt) <= 300000 then
        return true
    end
    return false
end

function LvxJournal.OnCombatKillEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType)
    local died = false
    local resultDied = SafeGlobalValue("ACTION_RESULT_DIED")
    local resultDiedXP = SafeGlobalValue("ACTION_RESULT_DIED_XP")
    local resultKillingBlow = SafeGlobalValue("ACTION_RESULT_KILLING_BLOW")

    if resultDied ~= nil and result == resultDied then died = true end
    if resultDiedXP ~= nil and result == resultDiedXP then died = true end
    if resultKillingBlow ~= nil and result == resultKillingBlow then died = true end
    if not died then return end
    if not IsEnemyTargetType(targetType) then return end

    -- DIED_XP and KILLING_BLOW are already strong indicators that the player received kill credit.
    -- For plain DIED events, keep the safer player-source check to avoid counting every nearby death.
    local trustedKillCredit = false
    if resultDiedXP ~= nil and result == resultDiedXP then
        trustedKillCredit = true
    elseif resultKillingBlow ~= nil and result == resultKillingBlow then
        trustedKillCredit = true
    elseif IsPlayerCombatSource(sourceType, sourceName) then
        trustedKillCredit = true
    end

    if not trustedKillCredit then return end

    targetName = NormalizeKillName(targetName)
    local now = SafeCall(GetFrameTimeMilliseconds) or (GetTimeStamp and (GetTimeStamp() * 1000)) or 0

    LvxJournal.recentKillTimes = LvxJournal.recentKillTimes or {}
    local dedupeKey = targetName .. ":" .. tostring(result or "")
    local last = LvxJournal.recentKillTimes[dedupeKey]
    if last and (now - last) < 1500 then
        return
    end
    LvxJournal.recentKillTimes[dedupeKey] = now

    local s = LvxJournal.savedVars
    if not s then return end
    s.stats = s.stats or {}

    s.stats.enemyKills = (tonumber(s.stats.enemyKills) or 0) + 1
    s.stats.sessionEnemyKills = (tonumber(s.stats.sessionEnemyKills) or 0) + 1

    if IsKnownBossKill(targetName) then
        s.stats.bossKills = (tonumber(s.stats.bossKills) or 0) + 1
        s.stats.sessionBossKills = (tonumber(s.stats.sessionBossKills) or 0) + 1
    end

    if s.viewMode == "stats" and LvxJournal.RefreshStatsPage then
        LvxJournal.RefreshStatsPage()
    end
end

local function RegisterCombatKillTracking()
    if not EVENT_COMBAT_EVENT then return end

    local resultDied = SafeGlobalValue("ACTION_RESULT_DIED")
    local resultDiedXP = SafeGlobalValue("ACTION_RESULT_DIED_XP")
    local resultKillingBlow = SafeGlobalValue("ACTION_RESULT_KILLING_BLOW")
    local filterResult = SafeGlobalValue("REGISTER_FILTER_COMBAT_RESULT")

    em:RegisterForEvent(LvxJournal.name .. "_CombatKillDied", EVENT_COMBAT_EVENT, LvxJournal.OnCombatKillEvent)
    if em.AddFilterForEvent and filterResult and resultDied then
        em:AddFilterForEvent(LvxJournal.name .. "_CombatKillDied", EVENT_COMBAT_EVENT, filterResult, resultDied)
    end

    if resultDiedXP then
        em:RegisterForEvent(LvxJournal.name .. "_CombatKillDiedXP", EVENT_COMBAT_EVENT, LvxJournal.OnCombatKillEvent)
        if em.AddFilterForEvent and filterResult then
            em:AddFilterForEvent(LvxJournal.name .. "_CombatKillDiedXP", EVENT_COMBAT_EVENT, filterResult, resultDiedXP)
        end
    end

    if resultKillingBlow then
        em:RegisterForEvent(LvxJournal.name .. "_CombatKillBlow", EVENT_COMBAT_EVENT, LvxJournal.OnCombatKillEvent)
        if em.AddFilterForEvent and filterResult then
            em:AddFilterForEvent(LvxJournal.name .. "_CombatKillBlow", EVENT_COMBAT_EVENT, filterResult, resultKillingBlow)
        end
    end
end

local function GetRaceNameSafe()
    if GetUnitRace then return GetUnitRace("player") or "Unknown" end
    return "Unknown"
end

local function GetClassNameSafe()
    if GetUnitClass then return GetUnitClass("player") or "Unknown" end
    return "Unknown"
end

local function GetAllianceNameSafe()
    local alliance = GetUnitAlliance and GetUnitAlliance("player") or nil
    if GetAllianceName and alliance then
        local name = GetAllianceName(alliance)
        if name and name ~= "" then return name end
    end
    if alliance == 1 then return "Aldmeri Dominion" end
    if alliance == 2 then return "Ebonheart Pact" end
    if alliance == 3 then return "Daggerfall Covenant" end
    return "Unknown"
end

local function GetLevelTextSafe()
    local level = GetUnitLevel and GetUnitLevel("player") or 0
    local cp = GetUnitChampionPoints and GetUnitChampionPoints("player") or 0
    if cp and cp > 0 then return tostring(level) .. " / CP " .. tostring(cp) end
    return tostring(level)
end

local function GetGoldTextSafe()
    local gold = GetCurrentMoney and GetCurrentMoney() or 0
    return tostring(gold)
end

local function GetBagTextSafe()
    local used = GetNumBagUsedSlots and GetNumBagUsedSlots(BAG_BACKPACK) or nil
    local size = GetBagSize and GetBagSize(BAG_BACKPACK) or nil
    if used and size then return tostring(used) .. " / " .. tostring(size) end
    return "Unknown"
end

local function GetMountStatTextSafe(statType)
    if GetRidingStats then
        local a, b, c = SafeCall(GetRidingStats)
        if statType == "speed" and a then return tostring(a) end
        if statType == "stamina" and b then return tostring(b) end
        if statType == "capacity" and c then return tostring(c) end
    end
    return "Unknown"
end

local function GetStatNumberSafe(statName)
    local stat = _G[statName]
    if GetPlayerStat and stat then
        local value = SafeCall(GetPlayerStat, stat)
        if value ~= nil then return tostring(value) end
    end
    return "Unknown"
end

local function GetPowerTextSafe(powerName)
    local powerType = _G[powerName]
    if GetUnitPower and powerType then
        local current, maximum, effectiveMax = SafeCall(GetUnitPower, "player", powerType)
        if current ~= nil and maximum ~= nil then
            if effectiveMax ~= nil and effectiveMax ~= maximum then
                return tostring(current) .. " / " .. tostring(maximum) .. " (effective " .. tostring(effectiveMax) .. ")"
            end
            return tostring(current) .. " / " .. tostring(maximum)
        end
    end
    return "Unknown"
end

local function GetCurrencyTextSafe(currencyName)
    local currencyType = _G[currencyName]
    local location = _G["CURRENCY_LOCATION_CHARACTER"] or _G["CURRENCY_LOCATION_ACCOUNT"] or _G["CURRENCY_LOCATION_BANK"]
    if GetCurrencyAmount and currencyType then
        local amount = nil
        if location then
            amount = SafeCall(GetCurrencyAmount, currencyType, location)
        else
            amount = SafeCall(GetCurrencyAmount, currencyType)
        end
        if amount ~= nil then return tostring(amount) end
    end
    return "Unknown"
end

local function GetBagLineSafe(label, bagName)
    local bag = _G[bagName]
    if bag == nil then return label .. ": Unknown" end
    local used = GetNumBagUsedSlots and SafeCall(GetNumBagUsedSlots, bag) or nil
    local size = GetBagSize and SafeCall(GetBagSize, bag) or nil
    if used ~= nil and size ~= nil then return label .. ": " .. tostring(used) .. " / " .. tostring(size) end
    if size ~= nil then return label .. ": " .. tostring(size) .. " slots" end
    return label .. ": Unknown"
end

local function GetMapPositionTextSafe()
    if GetMapPlayerPosition then
        local x, y = SafeCall(GetMapPlayerPosition, "player")
        if type(x) == "number" and type(y) == "number" then
            return string.format("%.2f, %.2f", x * 100, y * 100)
        end
    end
    return "Unknown"
end

local function GetHeadingTextSafe()
    if GetPlayerCameraHeading then
        local heading = SafeCall(GetPlayerCameraHeading)
        if type(heading) == "number" then
            return string.format("%.1f deg", heading * 57.2957795)
        end
    end
    return "Unknown"
end

local function GetSessionTimeTextSafe()
    local s = LvxJournal.savedVars
    if not s or not s.stats then return "Unknown" end
    local start = tonumber(s.stats.sessionStart) or 0
    local now = GetTimeStamp and GetTimeStamp() or 0
    if start <= 0 or now <= 0 then return "Unknown" end
    local seconds = math.max(0, now - start)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    return string.format("%02d:%02d", hours, minutes)
end

local function GetMostUsedChronicleText()
    local cats = {
        {"Quest Log", "Quest"},
        {"Travel Log", "Travel"},
        {"Death Log", "Death"},
        {"Achievement Log", "Achievement"},
        {"Personal Notes", "Manual"},
    }
    local bestName = "None"
    local bestCount = 0
    for i = 1, #cats do
        local count = CountEntriesByCategory(cats[i][2])
        if count > bestCount then
            bestName = cats[i][1]
            bestCount = count
        end
    end
    return bestName .. " (" .. tostring(bestCount) .. ")"
end

local function AddStatHeader(lines, text)
    table.insert(lines, text)
    table.insert(lines, "------------------------------")
end

local function AddStatLine(lines, label, value)
    table.insert(lines, label .. ": " .. tostring(value))
end


local craftTypes = {
    { label = "Blacksmithing", const = "CRAFTING_TYPE_BLACKSMITHING", research = true },
    { label = "Clothier", const = "CRAFTING_TYPE_CLOTHIER", research = true },
    { label = "Woodworking", const = "CRAFTING_TYPE_WOODWORKING", research = true },
    { label = "Jewelry", const = "CRAFTING_TYPE_JEWELRYCRAFTING", research = true },
    { label = "Alchemy", const = "CRAFTING_TYPE_ALCHEMY", research = false },
    { label = "Enchanting", const = "CRAFTING_TYPE_ENCHANTING", research = false },
    { label = "Provisioning", const = "CRAFTING_TYPE_PROVISIONING", research = false },
}

local function GetCraftingTypeValue(constName)
    return _G[constName]
end

local function FormatCraftingLevelText(rank)
    rank = tonumber(rank)
    if rank and rank > 0 then
        return tostring(rank)
    end
    return "Unknown"
end

local function GetCraftingSkillLinesSafe()
    local lines = {}
    local skillType = _G["SKILL_TYPE_TRADESKILL"]
    if not skillType or not GetNumSkillLines or not GetSkillLineInfo then
        return lines
    end

    local numLines = SafeCall(GetNumSkillLines, skillType) or 0
    for i = 1, numLines do
        -- ESO returns the skill line name first and the current skill rank/level second.
        -- Do not read later return values here; some are booleans and caused "Rank true".
        local name, rank = SafeCallMany(GetSkillLineInfo, skillType, i)
        if name and name ~= "" then
            table.insert(lines, tostring(name) .. ": Level " .. FormatCraftingLevelText(rank))
        end
    end
    return lines
end

local function GetCraftingSkillLineByNameSafe(label)
    local skillLines = GetCraftingSkillLinesSafe()
    local lowerLabel = string.lower(label or "")
    for i = 1, #skillLines do
        local line = skillLines[i]
        if string.find(string.lower(line), lowerLabel, 1, true) then
            return line
        end
    end
    return label .. ": Unknown"
end

local function GetCraftingStationTextSafe()
    if GetCraftingInteractionType then
        local craftingType = SafeCall(GetCraftingInteractionType)
        if craftingType and craftingType ~= 0 then
            if GetString then
                local strId = _G["SI_TRADESKILLTYPE"]
                if strId then
                    local name = SafeCall(GetString, strId, craftingType)
                    if name and name ~= "" then return name end
                end
            end
            return tostring(craftingType)
        end
    end
    return "Not at station / Unknown"
end

local function GetCraftBagTextSafe()
    local craftBag = _G["BAG_VIRTUAL"] or _G["BAG_CRAFTBAG"]
    if craftBag == nil then return "Unknown" end
    local used = GetNumBagUsedSlots and SafeCall(GetNumBagUsedSlots, craftBag) or nil
    local size = GetBagSize and SafeCall(GetBagSize, craftBag) or nil
    if used ~= nil and size ~= nil then return tostring(used) .. " / " .. tostring(size) end
    if used ~= nil then return tostring(used) .. " material stacks" end
    return "Unknown"
end

local function GetKnownRecipeCountTextSafe()
    if GetNumRecipeLists and GetRecipeListInfo then
        local lists = SafeCall(GetNumRecipeLists) or 0
        local known = 0
        local total = 0
        for listIndex = 1, lists do
            local name, numRecipes = SafeCallMany(GetRecipeListInfo, listIndex)
            numRecipes = tonumber(numRecipes) or 0
            total = total + numRecipes
            if GetRecipeInfo then
                for recipeIndex = 1, numRecipes do
                    local knownResult = SafeCallMany(GetRecipeInfo, listIndex, recipeIndex)
                    if knownResult == true then known = known + 1 end
                end
            end
        end
        if total > 0 then return tostring(known) .. " / " .. tostring(total) end
    end
    return "Unknown"
end

local function CountResearchTraitsSafe(craftingType)
    if not craftingType or not GetNumSmithingResearchLines or not GetSmithingResearchLineInfo or not GetSmithingResearchLineTraitInfo then
        return nil
    end

    local totalTraits = 0
    local knownTraits = 0
    local researchingTraits = 0
    local numLines = SafeCall(GetNumSmithingResearchLines, craftingType) or 0

    for lineIndex = 1, numLines do
        local lineName, lineIcon, numTraits = SafeCallMany(GetSmithingResearchLineInfo, craftingType, lineIndex)
        numTraits = tonumber(numTraits) or 0
        totalTraits = totalTraits + numTraits
        for traitIndex = 1, numTraits do
            local a, b, c, d, e, f = SafeCallMany(GetSmithingResearchLineTraitInfo, craftingType, lineIndex, traitIndex)
            local known = false
            local researching = false

            -- ESO API return order has changed over time, so this checks common boolean/number patterns safely.
            if type(a) == "boolean" then known = a end
            if type(b) == "boolean" then known = known or b end
            if type(c) == "boolean" then known = known or c end
            if type(d) == "boolean" then known = known or d end
            if type(e) == "number" and e > 0 then researching = true end
            if type(f) == "number" and f > 0 then researching = true end

            if known then knownTraits = knownTraits + 1 end
            if researching then researchingTraits = researchingTraits + 1 end
        end
    end

    return knownTraits, totalTraits, researchingTraits
end

local function GetResearchSlotsTextSafe(craftingType)
    if not craftingType then return "Unknown" end
    if GetMaxSimultaneousSmithingResearch and GetNumSmithingResearchLines then
        local maxSlots = SafeCall(GetMaxSimultaneousSmithingResearch, craftingType)
        if maxSlots ~= nil then return tostring(maxSlots) .. " slots" end
    end
    return "Unknown"
end

local function GetResearchSummaryTextSafe(typeInfo)
    local craftingType = GetCraftingTypeValue(typeInfo.const)
    if not craftingType then return "Unknown" end
    local knownTraits, totalTraits, researchingTraits = CountResearchTraitsSafe(craftingType)
    local slots = GetResearchSlotsTextSafe(craftingType)
    if knownTraits ~= nil and totalTraits ~= nil and totalTraits > 0 then
        return tostring(knownTraits) .. " / " .. tostring(totalTraits) .. " traits, " .. tostring(researchingTraits or 0) .. " researching, " .. slots
    end
    return slots
end


local function GetTributeConstantValue(constName)
    local value = _G[constName]
    if value ~= nil then return value end
    return nil
end

local function GetTributePlayerTypeText(playerType)
    if playerType == nil then return "Unknown" end
    if playerType == GetTributeConstantValue("TRIBUTE_PLAYER_TYPE_NPC") then return "NPC" end
    if playerType == GetTributeConstantValue("TRIBUTE_PLAYER_TYPE_PLAYER") then return "Player" end
    return tostring(playerType)
end

local function AddTributePlayerLine(lines, label, perspectiveConst)
    local perspective = GetTributeConstantValue(perspectiveConst)
    if not perspective or type(GetTributePlayerInfo) ~= "function" then
        AddStatLine(lines, label, "Unavailable")
        return
    end

    local name, playerType = SafeCall(GetTributePlayerInfo, perspective)
    if name and tostring(name) ~= "" then
        AddStatLine(lines, label, tostring(name) .. " (" .. GetTributePlayerTypeText(playerType) .. ")")
    else
        AddStatLine(lines, label, "Not in Tribute match")
    end
end

local function GetTributeRankTextSafe()
    -- ESO has changed/limited what Tribute rank data is exposed over time.
    -- Try known/likely globals safely and fall back instead of causing UI errors.
    local candidates = {
        "GetTributeRankInfo",
        "GetTributeRank",
        "GetCurrentTributeRank",
        "GetTributePlayerRankInfo",
        "GetTributePlayerRank",
    }

    for i = 1, #candidates do
        local fn = _G[candidates[i]]
        if type(fn) == "function" then
            local a, b, c, d = SafeCall(fn)
            if a ~= nil then
                if b ~= nil or c ~= nil or d ~= nil then
                    local parts = {}
                    if a ~= nil then parts[#parts + 1] = tostring(a) end
                    if b ~= nil then parts[#parts + 1] = tostring(b) end
                    if c ~= nil then parts[#parts + 1] = tostring(c) end
                    if d ~= nil then parts[#parts + 1] = tostring(d) end
                    return table.concat(parts, " / ")
                end
                return tostring(a)
            end
        end
    end

    return "Unavailable"
end

local function GetTributeLeaderboardTextSafe()
    local leaderboardType = GetTributeConstantValue("LEADERBOARD_TYPE_TRIBUTE")
    if leaderboardType and type(GetLeaderboardPlayerInfo) == "function" then
        local a, b, c, d = SafeCall(GetLeaderboardPlayerInfo, leaderboardType)
        if a ~= nil then
            local parts = {}
            if a ~= nil then parts[#parts + 1] = tostring(a) end
            if b ~= nil then parts[#parts + 1] = tostring(b) end
            if c ~= nil then parts[#parts + 1] = tostring(c) end
            if d ~= nil then parts[#parts + 1] = tostring(d) end
            return table.concat(parts, " / ")
        end
    end
    return "Unavailable"
end


local function GetTributeTrackedStatsText()
    local stats = (LvxJournal.savedVars and LvxJournal.savedVars.stats) or {}
    local wins = tonumber(stats.tributeWins) or 0
    local losses = tonumber(stats.tributeLosses) or 0
    local games = tonumber(stats.tributeGames) or 0

    if games <= 0 then
        games = wins + losses
    end

    local winPercentText = "No tracked games yet"
    if games > 0 then
        local percent = (wins / games) * 100
        winPercentText = string.format("%.1f%%", percent)
    end

    return wins, losses, games, winPercentText
end

local function AddTributeStatsPage(lines)
    local wins, losses, games, winPercentText = GetTributeTrackedStatsText()

    AddStatHeader(lines, "Tales of Tribute")
    AddStatLine(lines, "Rank Info", GetTributeRankTextSafe())
    AddStatLine(lines, "Leaderboard", GetTributeLeaderboardTextSafe())
    table.insert(lines, "")
    AddStatHeader(lines, "Tracked Results")
    AddStatLine(lines, "Games", tostring(games))
    AddStatLine(lines, "Wins", tostring(wins))
    AddStatLine(lines, "Losses", tostring(losses))
    AddStatLine(lines, "Win Percentage", winPercentText)
    AddStatLine(lines, "Last Result", tostring(((LvxJournal.savedVars and LvxJournal.savedVars.stats) or {}).tributeLastResult or ""))
    AddStatLine(lines, "Last Source", tostring(((LvxJournal.savedVars and LvxJournal.savedVars.stats) or {}).tributeLastSource or ""))
    AddStatLine(lines, "Last Time", tostring(((LvxJournal.savedVars and LvxJournal.savedVars.stats) or {}).tributeLastTime or ""))
    table.insert(lines, "")
    AddStatHeader(lines, "Current Match")
    AddTributePlayerLine(lines, "You", "TRIBUTE_PLAYER_PERSPECTIVE_SELF")
    AddTributePlayerLine(lines, "Opponent", "TRIBUTE_PLAYER_PERSPECTIVE_OPPONENT")
    table.insert(lines, "")
    table.insert(lines, "Tracked results only count games recorded by LvxJournal.")
    table.insert(lines, "Some Tribute values are only exposed while the Tribute or leaderboard UI is active.")
    table.insert(lines, "If ESO does not expose a value, the journal keeps it as Unavailable.")
end


local function GetTributeResultTextFromValues(...)
    for i = 1, select("#", ...) do
        local value = select(i, ...)
        local valueType = type(value)

        if valueType == "string" then
            local lower = string.lower(value)
            if lower:find("victory", 1, true) or lower:find("winner", 1, true) or lower:find("won", 1, true) or lower:find("win", 1, true) then
                return "win"
            end
            if lower:find("defeat", 1, true) or lower:find("lost", 1, true) or lower:find("loss", 1, true) or lower:find("lose", 1, true) then
                return "loss"
            end
        elseif valueType == "boolean" then
            if value == true then return "win" end
        elseif valueType == "number" then
            local selfPerspective = GetTributeConstantValue("TRIBUTE_PLAYER_PERSPECTIVE_SELF")
            local opponentPerspective = GetTributeConstantValue("TRIBUTE_PLAYER_PERSPECTIVE_OPPONENT")
            local winResult = GetTributeConstantValue("TRIBUTE_MATCH_RESULT_WIN") or GetTributeConstantValue("TRIBUTE_GAME_RESULT_WIN") or GetTributeConstantValue("TRIBUTE_RESULT_WIN")
            local lossResult = GetTributeConstantValue("TRIBUTE_MATCH_RESULT_LOSS") or GetTributeConstantValue("TRIBUTE_GAME_RESULT_LOSS") or GetTributeConstantValue("TRIBUTE_RESULT_LOSS")

            if selfPerspective ~= nil and value == selfPerspective then return "win" end
            if opponentPerspective ~= nil and value == opponentPerspective then return "loss" end
            if winResult ~= nil and value == winResult then return "win" end
            if lossResult ~= nil and value == lossResult then return "loss" end
        end
    end

    return nil
end

function LvxJournal.RecordTributeResult(result, source)
    result = tostring(result or "")
    if result ~= "win" and result ~= "loss" then return false end

    local s = LvxJournal.savedVars
    if not s then return false end
    s.stats = s.stats or {}

    local now = SafeCall(GetFrameTimeMilliseconds) or (GetTimeStamp and (GetTimeStamp() * 1000)) or 0
    local lastStamp = tonumber(s.stats.tributeLastStamp) or 0
    local lastResult = tostring(s.stats.tributeLastResult or "")

    if source ~= "Manual" and lastResult == result and lastStamp > 0 and (now - lastStamp) < 45000 then
        return false
    end

    s.stats.tributeGames = (tonumber(s.stats.tributeGames) or 0) + 1
    if result == "win" then
        s.stats.tributeWins = (tonumber(s.stats.tributeWins) or 0) + 1
    else
        s.stats.tributeLosses = (tonumber(s.stats.tributeLosses) or 0) + 1
    end

    s.stats.tributeLastResult = result
    s.stats.tributeLastSource = tostring(source or "Unknown")
    s.stats.tributeLastStamp = now
    s.stats.tributeLastTime = GetStampText()

    if LvxJournal.savedVars.viewMode == "stats" and LvxJournal.RefreshStatsPage then
        LvxJournal.RefreshStatsPage()
    end

    Msg("Tales of Tribute " .. result .. " recorded.")
    return true
end

local function CheckTributeResultFromAPIs(source)
    local candidates = {
        "GetTributeMatchResult",
        "GetTributeGameResult",
        "GetTributeResult",
        "GetTributeWinner",
        "GetTributeGameWinner",
        "GetTributeMatchWinner",
        "GetTributeWinningPlayerPerspective",
        "GetTributeVictoryState",
    }

    for i = 1, #candidates do
        local fn = _G[candidates[i]]
        if type(fn) == "function" then
            local a, b, c, d = SafeCall(fn)
            local result = GetTributeResultTextFromValues(a, b, c, d)
            if result then
                return LvxJournal.RecordTributeResult(result, source or candidates[i])
            end
        end
    end

    return false
end

function LvxJournal.OnTributeResultEvent(eventCode, ...)
    if not (LvxJournal.savedVars and LvxJournal.savedVars.trackTributeLog == true) then return end
    local result = GetTributeResultTextFromValues(...)
    if result then
        LvxJournal.RecordTributeResult(result, "Tribute Event")
        return
    end

    if zo_callLater then
        zo_callLater(function()
            CheckTributeResultFromAPIs("Tribute API delayed")
        end, 1500)
    else
        CheckTributeResultFromAPIs("Tribute API")
    end
end

local function RegisterTributeTracking()
    local eventNames = {
        "EVENT_TRIBUTE_GAME_FLOW_STATE_CHANGED",
        "EVENT_TRIBUTE_GAME_STATE_CHANGED",
        "EVENT_TRIBUTE_GAME_OVER",
        "EVENT_TRIBUTE_GAME_END",
        "EVENT_TRIBUTE_MATCH_OVER",
        "EVENT_TRIBUTE_MATCH_END",
        "EVENT_TRIBUTE_RESULT",
        "EVENT_TRIBUTE_MATCH_RESULT",
        "EVENT_TRIBUTE_RANK_CHANGED",
    }

    local registered = 0
    for i = 1, #eventNames do
        local eventId = _G[eventNames[i]]
        if eventId ~= nil then
            em:RegisterForEvent(LvxJournal.name .. "_" .. eventNames[i], eventId, LvxJournal.OnTributeResultEvent)
            registered = registered + 1
        end
    end

    LvxJournal.tributeTrackingRegistered = registered
end


local function FormatGoldValue(value)
    value = tonumber(value) or 0
    return tostring(math.floor(value))
end

local function GetJournalGoldAmountSafe()
    if GetCurrentMoney then
        local amount = SafeCall(GetCurrentMoney)
        if amount ~= nil then return tonumber(amount) end
    end
    return nil
end

function LvxJournal.TrackGoldChange()
    local s = LvxJournal.savedVars
    if not s then return end
    s.stats = s.stats or {}

    local currentGold = GetJournalGoldAmountSafe()
    if currentGold == nil then return end

    local lastGold = tonumber(s.stats.lastKnownGold)
    if lastGold ~= nil then
        local diff = currentGold - lastGold
        if diff > 0 then
            s.stats.goldCollected = (tonumber(s.stats.goldCollected) or 0) + diff
            s.stats.sessionGoldCollected = (tonumber(s.stats.sessionGoldCollected) or 0) + diff
        end
    end

    s.stats.lastKnownGold = currentGold
end

local function RegisterGoldTracking()
    if EVENT_MONEY_UPDATE then
        em:RegisterForEvent(LvxJournal.name .. "_MoneyUpdate", EVENT_MONEY_UPDATE, function()
            LvxJournal.TrackGoldChange()
            if LvxJournal.savedVars and LvxJournal.savedVars.viewMode == "stats" and LvxJournal.RefreshStatsPage then
                LvxJournal.RefreshStatsPage()
            end
        end)
    elseif EVENT_CURRENCY_UPDATE then
        em:RegisterForEvent(LvxJournal.name .. "_CurrencyUpdate", EVENT_CURRENCY_UPDATE, function()
            LvxJournal.TrackGoldChange()
            if LvxJournal.savedVars and LvxJournal.savedVars.viewMode == "stats" and LvxJournal.RefreshStatsPage then
                LvxJournal.RefreshStatsPage()
            end
        end)
    end
end

local function GetCurrentZoneTravelStats()
    local s = LvxJournal.savedVars
    local stats = s and s.stats or {}
    return {
        totalMeters = tonumber(stats.totalMeters) or 0,
        sessionMeters = tonumber(stats.sessionMeters) or 0,
        enemyKills = tonumber(stats.enemyKills) or 0,
        bossKills = tonumber(stats.bossKills) or 0,
        sessionEnemyKills = tonumber(stats.sessionEnemyKills) or 0,
        sessionBossKills = tonumber(stats.sessionBossKills) or 0,
        goldCollected = tonumber(stats.goldCollected) or 0,
        sessionGoldCollected = tonumber(stats.sessionGoldCollected) or 0,
    }
end

local function AttachZoneTravelStats(zoneData)
    if type(zoneData) ~= "table" then return end
    local stats = GetCurrentZoneTravelStats()
    zoneData.totalMeters = stats.totalMeters
    zoneData.sessionMeters = stats.sessionMeters
    zoneData.enemyKills = stats.enemyKills
    zoneData.bossKills = stats.bossKills
    zoneData.sessionEnemyKills = stats.sessionEnemyKills
    zoneData.sessionBossKills = stats.sessionBossKills
    zoneData.goldCollected = stats.goldCollected
    zoneData.sessionGoldCollected = stats.sessionGoldCollected

    if type(GetMapNameTextSafe) == "function" then
        zoneData.lastMap = GetMapNameTextSafe()
    elseif GetMapName then
        zoneData.lastMap = tostring(SafeCall(GetMapName) or "Unknown")
    else
        zoneData.lastMap = zoneData.lastMap or "Unknown"
    end

    if type(GetSubZoneTextSafe) == "function" then
        zoneData.lastSubzone = GetSubZoneTextSafe()
    elseif GetPlayerActiveSubzoneName then
        zoneData.lastSubzone = tostring(SafeCall(GetPlayerActiveSubzoneName) or "Unknown")
    else
        zoneData.lastSubzone = zoneData.lastSubzone or "Unknown"
    end
end

local function GetStatsMaxPage()
    local s = LvxJournal.savedVars
    local knownZoneCount = 0
    if s and s.knownZones then
        for _ in pairs(s.knownZones) do knownZoneCount = knownZoneCount + 1 end
    end
    local placePages = math.max(1, math.ceil(knownZoneCount / 4))
    return 11 + placePages
end


local function CleanLegacyZoneTime(value)
    value = tostring(value or "")
    if value == "" or value == "Earlier Save" then return "Previously recorded" end
    return value
end

local function GetKnownZoneRowsSorted()
    local s = LvxJournal.savedVars
    local rows = {}
    if not s or not s.knownZones then return rows end
    for zone, data in pairs(s.knownZones) do
        if type(data) == "table" then
            table.insert(rows, {
                zone = tostring(zone),
                first = CleanLegacyZoneTime(data.first),
                last = CleanLegacyZoneTime(data.last or data.first),
                visits = tonumber(data.visits) or 1,
                lastMap = tostring(data.lastMap or ""),
                lastSubzone = tostring(data.lastSubzone or ""),
                enemyKills = tonumber(data.enemyKills) or 0,
                bossKills = tonumber(data.bossKills) or 0,
                goldCollected = tonumber(data.goldCollected) or 0,
                questsCompleted = tonumber(data.questsCompleted) or 0,
                totalMeters = tonumber(data.totalMeters) or 0,
            })
        else
            table.insert(rows, {
                zone = tostring(zone),
                first = "Previously recorded",
                last = "Previously recorded",
                visits = 1,
                lastMap = "",
                lastSubzone = "",
                enemyKills = 0,
                bossKills = 0,
                goldCollected = 0,
                questsCompleted = 0,
                totalMeters = 0,
            })
        end
    end
    table.sort(rows, function(a, b)
        if a.visits == b.visits then return a.zone < b.zone end
        return a.visits > b.visits
    end)
    return rows
end

local function AddPlacesVisitedPage(lines, pageOffset)
    local rows = GetKnownZoneRowsSorted()
    local perPage = 4
    local startIndex = ((pageOffset - 1) * perPage) + 1
    local endIndex = math.min(startIndex + perPage - 1, #rows)
    AddStatHeader(lines, "Places Visited " .. tostring(pageOffset))
    if #rows == 0 then
        table.insert(lines, "No places recorded yet.")
        return
    end

    local s = LvxJournal.savedVars or {}
    local stats = s.stats or {}
    table.insert(lines, "Known Places: " .. tostring(#rows))
    table.insert(lines, "Enemies Defeated: " .. tostring(tonumber(stats.enemyKills) or 0) .. " total / " .. tostring(tonumber(stats.sessionEnemyKills) or 0) .. " session")
    table.insert(lines, "Bosses Defeated: " .. tostring(tonumber(stats.bossKills) or 0) .. " total / " .. tostring(tonumber(stats.sessionBossKills) or 0) .. " session")
    local totalZoneQuests = 0
    for _, row in ipairs(rows) do
        totalZoneQuests = totalZoneQuests + (tonumber(row.questsCompleted) or 0)
    end
    table.insert(lines, "Gold Collected: " .. FormatGoldValue(stats.goldCollected) .. " total / " .. FormatGoldValue(stats.sessionGoldCollected) .. " session")
    table.insert(lines, "Quests Completed in Recorded Zones: " .. tostring(totalZoneQuests))
    table.insert(lines, "Distance Traveled: " .. FormatDistance(tonumber(stats.totalMeters) or 0))
    table.insert(lines, "")

    for i = startIndex, endIndex do
        local row = rows[i]
        table.insert(lines, tostring(i) .. ". " .. row.zone)
        table.insert(lines, "  Visits: " .. tostring(row.visits) .. "  Last: " .. tostring(row.last))
        if row.lastSubzone ~= "" and row.lastSubzone ~= "Unknown" then
            table.insert(lines, "  Last Subzone: " .. row.lastSubzone)
        end
        if row.enemyKills > 0 or row.bossKills > 0 then
            table.insert(lines, "  At Last Visit: " .. tostring(row.enemyKills) .. " enemies / " .. tostring(row.bossKills) .. " bosses")
        end
        if row.questsCompleted > 0 then
            table.insert(lines, "  Quests Completed Here: " .. tostring(row.questsCompleted))
        end
        if row.goldCollected > 0 then
            table.insert(lines, "  Gold by Last Visit: " .. FormatGoldValue(row.goldCollected))
        end
    end

    table.insert(lines, "")
    table.insert(lines, tostring(startIndex) .. " - " .. tostring(endIndex) .. " of " .. tostring(#rows) .. " known places")
end

function LvxJournal.RefreshStatsPage()
    if not LvxJournal.statsText then return end
    local s = LvxJournal.savedVars
    if not s then return end
    s.stats = s.stats or {}

    local maxPage = GetStatsMaxPage()
    local page = tonumber(s.stats.statsPage) or 1
    if page < 1 then page = 1 end
    if page > maxPage then page = maxPage end
    s.stats.statsPage = page

    local totalMeters = tonumber(s.stats.totalMeters) or 0
    local sessionMeters = tonumber(s.stats.sessionMeters) or 0
    local knownZoneCount = 0
    if s.knownZones then
        for _ in pairs(s.knownZones) do knownZoneCount = knownZoneCount + 1 end
    end

    local lines = {}

    if page == 1 then
        AddStatHeader(lines, "Character")
        AddStatLine(lines, "Name", GetPlayerNameSafe())
        AddStatLine(lines, "Race", GetRaceNameSafe())
        AddStatLine(lines, "Class", GetClassNameSafe())
        AddStatLine(lines, "Alliance", GetAllianceNameSafe())
        AddStatLine(lines, "Level / Champion", GetLevelTextSafe())
        AddStatLine(lines, "Zone", GetLocationText())
        AddStatLine(lines, "Map Position", GetMapPositionTextSafe())
        AddStatLine(lines, "Camera Heading", GetHeadingTextSafe())
        AddStatLine(lines, "RP/Real Time", GetStampText())
    elseif page == 2 then
        AddStatHeader(lines, "Resources")
        AddStatLine(lines, "Health", GetPowerTextSafe("POWERTYPE_HEALTH"))
        AddStatLine(lines, "Magicka", GetPowerTextSafe("POWERTYPE_MAGICKA"))
        AddStatLine(lines, "Stamina", GetPowerTextSafe("POWERTYPE_STAMINA"))
        AddStatLine(lines, "Ultimate", GetPowerTextSafe("POWERTYPE_ULTIMATE"))
        AddStatLine(lines, "Health Recovery", GetStatNumberSafe("STAT_HEALTH_REGEN_COMBAT"))
        AddStatLine(lines, "Magicka Recovery", GetStatNumberSafe("STAT_MAGICKA_REGEN_COMBAT"))
        AddStatLine(lines, "Stamina Recovery", GetStatNumberSafe("STAT_STAMINA_REGEN_COMBAT"))
    elseif page == 3 then
        AddStatHeader(lines, "Combat")
        AddStatLine(lines, "Weapon Damage", GetStatNumberSafe("STAT_POWER"))
        AddStatLine(lines, "Spell Damage", GetStatNumberSafe("STAT_SPELL_POWER"))
        AddStatLine(lines, "Weapon Critical", GetStatNumberSafe("STAT_CRITICAL_STRIKE"))
        AddStatLine(lines, "Spell Critical", GetStatNumberSafe("STAT_SPELL_CRITICAL"))
        AddStatLine(lines, "Physical Resistance", GetStatNumberSafe("STAT_PHYSICAL_RESIST"))
        AddStatLine(lines, "Spell Resistance", GetStatNumberSafe("STAT_SPELL_RESIST"))
        AddStatLine(lines, "Armor Rating", GetStatNumberSafe("STAT_ARMOR_RATING"))
        table.insert(lines, "")
        AddStatHeader(lines, "Combat Log")
        AddStatLine(lines, "Enemies Killed", tonumber(s.stats.enemyKills) or 0)
        AddStatLine(lines, "Bosses Killed", tonumber(s.stats.bossKills) or 0)
        AddStatLine(lines, "Session Enemies", tonumber(s.stats.sessionEnemyKills) or 0)
        AddStatLine(lines, "Session Bosses", tonumber(s.stats.sessionBossKills) or 0)
        table.insert(lines, "")
        table.insert(lines, "Kill counts start from this addon version onward.")
    elseif page == 4 then
        AddStatHeader(lines, "Inventory / Currency")
        table.insert(lines, GetBagLineSafe("Backpack", "BAG_BACKPACK"))
        table.insert(lines, GetBagLineSafe("Bank", "BAG_BANK"))
        table.insert(lines, GetBagLineSafe("Subscriber Bank", "BAG_SUBSCRIBER_BANK"))
        table.insert(lines, GetBagLineSafe("Worn Gear", "BAG_WORN"))
        AddStatLine(lines, "Gold", GetGoldTextSafe())
        AddStatLine(lines, "Tel Var", GetCurrencyTextSafe("CURT_TELVAR_STONES"))
        AddStatLine(lines, "Alliance Points", GetCurrencyTextSafe("CURT_ALLIANCE_POINTS"))
        AddStatLine(lines, "Writ Vouchers", GetCurrencyTextSafe("CURT_WRIT_VOUCHERS"))
    elseif page == 5 then
        AddStatHeader(lines, "Travel")
        AddStatLine(lines, "Total Distance", FormatDistance(totalMeters))
        AddStatLine(lines, "This Session", FormatDistance(sessionMeters))
        AddStatLine(lines, "Movement Samples", tonumber(s.stats.movementSamples) or 0)
        AddStatLine(lines, "Places Visited", knownZoneCount)
        AddStatLine(lines, "Current Zone", GetLocationText())
        AddStatLine(lines, "Map Position", GetMapPositionTextSafe())
        AddStatLine(lines, "Heading", GetHeadingTextSafe())
        table.insert(lines, "")
        table.insert(lines, "Large teleports/zone jumps are ignored.")
    elseif page == 6 then
        AddStatHeader(lines, "Journal Totals")
        AddStatLine(lines, "All Entries", CountEntriesByCategory("All"))
        AddStatLine(lines, "Bookmarks", CountEntriesByCategory("Bookmarks"))
        AddStatLine(lines, "Quest Log", CountEntriesByCategory("Quest"))
        AddStatLine(lines, "Travel Log", CountEntriesByCategory("Travel"))
        AddStatLine(lines, "Death Log", CountEntriesByCategory("Death"))
        AddStatLine(lines, "Achievement Log", CountEntriesByCategory("Achievement"))
        AddStatLine(lines, "Personal Notes", CountEntriesByCategory("Manual"))
        AddStatLine(lines, "Crafting Notes", CountEntriesByCategory("Crafting"))
        AddStatLine(lines, "Most Used Chronicle", GetMostUsedChronicleText())
    elseif page == 7 then
        AddStatHeader(lines, "Mount")
        AddStatLine(lines, "Speed Training", GetMountStatTextSafe("speed"))
        AddStatLine(lines, "Stamina Training", GetMountStatTextSafe("stamina"))
        AddStatLine(lines, "Capacity Training", GetMountStatTextSafe("capacity"))
        table.insert(lines, "")
        table.insert(lines, "Mount values depend on what ESO exposes to the UI API.")
    elseif page == 8 then
        AddStatHeader(lines, "Crafting Skill Lines")
        local craftLines = GetCraftingSkillLinesSafe()
        if #craftLines > 0 then
            for i = 1, #craftLines do
                table.insert(lines, craftLines[i])
            end
        else
            AddStatLine(lines, "Crafting Skills", "Unknown")
        end
        table.insert(lines, "")
        AddStatLine(lines, "Current Crafting Station", GetCraftingStationTextSafe())
    elseif page == 9 then
        AddStatHeader(lines, "Crafting Research / Recipes")
        for i = 1, #craftTypes do
            local info = craftTypes[i]
            if info.research then
                AddStatLine(lines, info.label .. " Research", GetResearchSummaryTextSafe(info))
            end
        end
        table.insert(lines, "")
        AddStatLine(lines, "Known Provisioning Recipes", GetKnownRecipeCountTextSafe())
        AddStatLine(lines, "Craft Bag", GetCraftBagTextSafe())
    elseif page == 10 then
        AddTributeStatsPage(lines)
    elseif page == 11 then
        AddStatHeader(lines, "Session / Addon")
        AddStatLine(lines, "Addon Version", LvxJournal.version)
        AddStatLine(lines, "Session Time", GetSessionTimeTextSafe())
        AddStatLine(lines, "Session Distance", FormatDistance(sessionMeters))
        AddStatLine(lines, "Total Distance", FormatDistance(totalMeters))
        AddStatLine(lines, "Current Filter", s.filter or "All Entries")
        AddStatLine(lines, "Current View", s.viewMode or "archive")
        AddStatLine(lines, "Autosave", "Enabled")
        AddStatLine(lines, "Time Mode", s.useRoleplayTime and "Roleplay" or "Real")
    elseif page >= 12 then
        AddPlacesVisitedPage(lines, page - 11)
    end

    LvxJournal.statsText:SetText(table.concat(lines, "\n"))
    if LvxJournal.statsTitle then
        LvxJournal.statsTitle:SetText("Stats Page " .. tostring(page) .. " / " .. tostring(maxPage))
    end
    if LvxJournal.statsFooterLabel then
        LvxJournal.statsFooterLabel:SetText("Prev / Next changes stats pages")
    end
end

function LvxJournal.PrevStatsPage()
    local s = LvxJournal.savedVars
    if not s then return end
    s.stats = s.stats or {}
    local maxPage = GetStatsMaxPage()
    s.stats.statsPage = (tonumber(s.stats.statsPage) or 1) - 1
    if s.stats.statsPage < 1 then s.stats.statsPage = maxPage end
    s.viewMode = "stats"
    LvxJournal.RefreshAll()
end

function LvxJournal.NextStatsPage()
    local s = LvxJournal.savedVars
    if not s then return end
    s.stats = s.stats or {}
    local maxPage = GetStatsMaxPage()
    s.stats.statsPage = (tonumber(s.stats.statsPage) or 1) + 1
    if s.stats.statsPage > maxPage then s.stats.statsPage = 1 end
    s.viewMode = "stats"
    LvxJournal.RefreshAll()
end

function LvxJournal.TrackDistance()
    if LvxJournal.TrackGoldChange then LvxJournal.TrackGoldChange() end
    local s = LvxJournal.savedVars
    if not s then return end
    s.stats = s.stats or {}

    if not GetUnitRawWorldPosition then return end
    local zoneId, x, y, z = SafeCall(GetUnitRawWorldPosition, "player")
    if not zoneId or not x or not y or not z then return end

    local lastZoneId = s.stats.lastZoneId
    local lastX = s.stats.lastX
    local lastY = s.stats.lastY
    local lastZ = s.stats.lastZ

    if lastZoneId == zoneId and lastX and lastY and lastZ then
        local dx = x - lastX
        local dy = y - lastY
        local dz = z - lastZ
        local meters = math.sqrt((dx * dx) + (dy * dy) + (dz * dz)) / 100

        -- Ignore huge jumps from wayshrines, loading doors, reloads, or zone transitions.
        if meters > 0.25 and meters < 120 then
            s.stats.totalMeters = (tonumber(s.stats.totalMeters) or 0) + meters
            s.stats.sessionMeters = (tonumber(s.stats.sessionMeters) or 0) + meters
            s.stats.movementSamples = (tonumber(s.stats.movementSamples) or 0) + 1
            if LvxJournal.savedVars.viewMode == "stats" then
                LvxJournal.RefreshStatsPage()
            end
        end
    end

    s.stats.lastZoneId = zoneId
    s.stats.lastX = x
    s.stats.lastY = y
    s.stats.lastZ = z
end


local alchemyReagents = {
    {"Beetle Scuttle", {"Breach", "Increase Armor", "Protection", "Vitality"}},
    {"Blessed Thistle", {"Ravage Health", "Restore Stamina", "Increase Weapon Power", "Speed"}},
    {"Blue Entoloma", {"Restore Health", "Ravage Magicka", "Cowardice", "Invisible"}},
    {"Bugloss", {"Restore Health", "Restore Magicka", "Increase Spell Resist", "Cowardice"}},
    {"Butterfly Wing", {"Restore Health", "Uncertainty", "Lingering Health", "Vitality"}},
    {"Chaurus Egg", {"Ravage Magicka", "Restore Stamina", "Detection", "Timidity"}},
    {"Clam Gall", {"Increase Spell Resist", "Hindrance", "Vulnerability", "Defile"}},
    {"Columbine", {"Restore Health", "Restore Magicka", "Restore Stamina", "Unstoppable"}},
    {"Corn Flower", {"Ravage Health", "Restore Magicka", "Increase Spell Power", "Detection"}},
    {"Crimson Nirnroot", {"Restore Health", "Spell Critical", "Gradual Ravage Health", "Timidity"}},
    {"Dragon Rheum", {"Restore Magicka", "Enervation", "Speed", "Heroism"}},
    {"Dragon's Bile", {"Invisible", "Vulnerability", "Vitality", "Heroism"}},
    {"Dragon's Blood", {"Restore Stamina", "Lingering Health", "Defile", "Heroism"}},
    {"Dragonthorn", {"Restore Stamina", "Fracture", "Increase Weapon Power", "Weapon Critical"}},
    {"Emetic Russula", {"Ravage Health", "Ravage Magicka", "Ravage Stamina", "Entrapment"}},
    {"Fleshfly Larva", {"Ravage Stamina", "Vulnerability", "Gradual Ravage Health", "Vitality"}},
    {"Imp Stool", {"Ravage Stamina", "Increase Armor", "Maim", "Enervation"}},
    {"Lady's Smock", {"Restore Magicka", "Breach", "Increase Spell Power", "Spell Critical"}},
    {"Luminous Russula", {"Restore Health", "Ravage Stamina", "Maim", "Hindrance"}},
    {"Mountain Flower", {"Restore Health", "Restore Stamina", "Increase Armor", "Maim"}},
    {"Mudcrab Chitin", {"Increase Spell Resist", "Increase Armor", "Protection", "Defile"}},
    {"Namira's Rot", {"Spell Critical", "Unstoppable", "Invisible", "Speed"}},
    {"Nightshade", {"Ravage Health", "Protection", "Gradual Ravage Health", "Defile"}},
    {"Nirnroot", {"Ravage Health", "Uncertainty", "Enervation", "Invisible"}},
    {"Powdered Mother of Pearl", {"Speed", "Protection", "Lingering Health", "Vitality"}},
    {"Scrib Jelly", {"Ravage Magicka", "Speed", "Vulnerability", "Lingering Health"}},
    {"Spider Egg", {"Invisible", "Hindrance", "Lingering Health", "Defile"}},
    {"Stinkhorn", {"Ravage Health", "Ravage Stamina", "Fracture", "Increase Weapon Power"}},
    {"Torchbug Thorax", {"Fracture", "Enervation", "Detection", "Vitality"}},
    {"Vile Coagulant", {"Ravage Health", "Restore Magicka", "Protection", "Timidity"}},
    {"Violet Coprinus", {"Ravage Health", "Ravage Magicka", "Breach", "Increase Spell Power"}},
    {"Water Hyacinth", {"Restore Health", "Spell Critical", "Weapon Critical", "Entrapment"}},
    {"White Cap", {"Ravage Magicka", "Increase Spell Resist", "Cowardice", "Detection"}},
    {"Wormwood", {"Weapon Critical", "Unstoppable", "Detection", "Hindrance"}},
}

local potionSolvents = {
    {"Natural Water", "Lvl 3"}, {"Clear Water", "Lvl 10"}, {"Pristine Water", "Lvl 20"},
    {"Cleansed Water", "Lvl 30"}, {"Filtered Water", "Lvl 40"}, {"Purified Water", "CP 10"},
    {"Cloud Mist", "CP 50"}, {"Star Dew", "CP 100"}, {"Lorkhan's Tears", "CP 150"},
}

local poisonSolvents = {
    {"Grease", "Lvl 3"}, {"Ichor", "Lvl 10"}, {"Slime", "Lvl 20"}, {"Gall", "Lvl 30"},
    {"Terebinthine", "Lvl 40"}, {"Pitch-Bile", "CP 10"}, {"Tarblack", "CP 50"},
    {"Night-Oil", "CP 100"}, {"Alkahest", "CP 150"},
}


local aspectRunes = {
    {"Ta", "Base", "White / Normal"},
    {"Jejota", "Fine", "Green"},
    {"Denata", "Superior", "Blue"},
    {"Rekuta", "Artifact", "Purple"},
    {"Kuta", "Legendary", "Gold"},
}

local potencyRunes = {
    {"Jora", "Jode", "1 - 10", "Trifling"},
    {"Porade", "Notade", "5 - 15", "Inferior"},
    {"Jera", "Ode", "10 - 20", "Petty"},
    {"Jejora", "Tade", "15 - 25", "Slight"},
    {"Odra", "Jayde", "20 - 30/35", "Minor"},
    {"Pojora", "Edode", "25 - 35", "Lesser"},
    {"Edora", "Pojode", "30 - 40", "Moderate"},
    {"Jaera", "Rekude", "35 - 45", "Average"},
    {"Pora", "Hade", "40 - 50", "Strong"},
    {"Denara", "Idode", "CP 10 - 30", "Superior"},
    {"Rera", "Pode", "CP 30 - 50", "Greater"},
    {"Derado", "Kedeko", "CP 50 - 70", "Grand"},
    {"Rekura", "Rede", "CP 70 - 100", "Splendid"},
    {"Kura", "Kude", "CP 100 - 150", "Monumental"},
    {"Rejera", "Jehade", "CP 150", "Superb"},
    {"Repora", "Itade", "CP 160", "Truly Superb"},
}

local essenceRunes = {
    {"Dekeipa", "Frost", "Frost damage / Frost resistance"},
    {"Deni", "Stamina", "Max stamina / Absorb stamina"},
    {"Denima", "Stamina Regen", "Stamina recovery"},
    {"Deteri", "Armor", "Physical resistance"},
    {"Hakeijo", "Prism", "Prismatic glyphs"},
    {"Haoko", "Disease", "Disease damage / Disease resistance"},
    {"Indeko", "Prismatic Regen", "Tri-recovery"},
    {"Kaderi", "Shield", "Damage shield"},
    {"Kuoko", "Poison", "Poison damage / Poison resistance"},
    {"Makderi", "Spell Harm", "Spell damage"},
    {"Makko", "Magicka", "Max magicka / Absorb magicka"},
    {"Makkoma", "Magicka Regen", "Magicka recovery"},
    {"Meip", "Shock", "Shock damage / Shock resistance"},
    {"Oko", "Health", "Max health / Absorb health"},
    {"Okoma", "Health Regen", "Health recovery"},
    {"Okori", "Power", "Weapon and spell power"},
    {"Oru", "Alchemist", "Potion boost / Potion cooldown"},
    {"Rakeipa", "Fire", "Flame damage / Flame resistance"},
    {"Taderi", "Physical Harm", "Weapon damage"},
}

local armorTraits = {
    {"Divines", "Increases Mundus Stone effect"},
    {"Impenetrable", "Reduces critical damage taken"},
    {"Infused", "Increases armor enchantment effect"},
    {"Intricate", "Extra inspiration on deconstruction"},
    {"Nirnhoned", "Increases armor value"},
    {"Ornate", "Sells to merchants for more gold"},
    {"Prosperous", "Legacy trait, mostly historical"},
    {"Reinforced", "Increases armor value"},
    {"Sturdy", "Reduces block cost"},
    {"Training", "Increases experience from kills"},
    {"Well-fitted", "Reduces sprint and roll dodge cost"},
}

local weaponTraits = {
    {"Charged", "Increases status effect chance"},
    {"Decisive", "Chance to gain extra Ultimate"},
    {"Defending", "Increases resistances"},
    {"Infused", "Increases weapon enchantment effect"},
    {"Intricate", "Extra inspiration on deconstruction"},
    {"Nirnhoned", "Increases weapon damage"},
    {"Ornate", "Sells to merchants for more gold"},
    {"Powered", "Increases healing done"},
    {"Precise", "Increases critical chance"},
    {"Sharpened", "Increases penetration"},
    {"Training", "Increases experience from kills"},
}

local jewelryTraits = {
    {"Arcane", "Increases max magicka"},
    {"Bloodthirsty", "Increases damage against low-health enemies"},
    {"Harmony", "Increases synergy effectiveness"},
    {"Healthy", "Increases max health"},
    {"Infused", "Increases jewelry enchantment effect"},
    {"Intricate", "Extra inspiration on deconstruction"},
    {"Ornate", "Sells to merchants for more gold"},
    {"Protective", "Increases resistances"},
    {"Robust", "Increases max stamina"},
    {"Swift", "Increases movement speed"},
    {"Triune", "Increases health, magicka, and stamina"},
}

local craftingMaterials = {
    {"Blacksmithing", "Ore/ingots for heavy armor and metal weapons"},
    {"Clothier", "Cloth and leather for light/medium armor"},
    {"Woodworking", "Sanded wood for bows, staves, and shields"},
    {"Jewelry", "Ounces/platings for rings and necklaces"},
    {"Alchemy", "Reagents plus waters/oils"},
    {"Enchanting", "Potency + Essence + Aspect runes"},
    {"Provisioning", "Food/drink ingredients and recipes"},
    {"Furnishing", "Style mats, recipes/blueprints, and craft mats"},
}

local craftingStations = {
    {"Blacksmithing", "Heavy armor, axes, maces, swords, daggers"},
    {"Clothier", "Light armor and medium armor"},
    {"Woodworking", "Bows, shields, inferno/ice/lightning/resto staves"},
    {"Jewelry", "Rings, necklaces, jewelry traits"},
    {"Alchemy", "Potions and poisons"},
    {"Enchanting", "Armor, weapon, and jewelry glyphs"},
    {"Provisioning", "Food and drink buffs"},
    {"Transmute", "Change traits and reconstruct collected sets"},
    {"Outfit", "Visual style changes only"},
}

local positiveEffects = {
    ["Detection"] = true, ["Heroism"] = true, ["Increase Armor"] = true, ["Increase Spell Power"] = true,
    ["Increase Spell Resist"] = true, ["Increase Weapon Power"] = true, ["Invisible"] = true,
    ["Lingering Health"] = true, ["Protection"] = true, ["Restore Health"] = true,
    ["Restore Magicka"] = true, ["Restore Stamina"] = true, ["Speed"] = true,
    ["Spell Critical"] = true, ["Unstoppable"] = true, ["Vitality"] = true, ["Weapon Critical"] = true,
}


local function ColorText(color, text)
    return "|c" .. color .. tostring(text or "") .. "|r"
end

local function GetAlchemyEffectColor(effect)
    if positiveEffects[effect] then
        return "3FAE4D" -- beneficial green
    end

    if effect == "Ravage Health" or effect == "Ravage Magicka" or effect == "Ravage Stamina" or effect == "Gradual Ravage Health" then
        return "B84A3A" -- poison red
    end

    if effect == "Breach" or effect == "Fracture" or effect == "Defile" or effect == "Maim" or effect == "Vulnerability" or effect == "Cowardice" or effect == "Timidity" or effect == "Enervation" or effect == "Hindrance" or effect == "Entrapment" or effect == "Uncertainty" then
        return "9B6BC9" -- debuff purple
    end

    return "C79A4B" -- unknown/utility gold
end

local function ColorAlchemyEffect(effect)
    return ColorText(GetAlchemyEffectColor(effect), effect)
end

local function ColorAlchemyReagentName(name)
    return ColorText("2F80D0", name)
end

local function ColorAlchemyEffectList(effects)
    local colored = {}
    for i = 1, #effects do
        colored[#colored + 1] = ColorAlchemyEffect(effects[i])
    end
    return table.concat(colored, ", ")
end

local function ColorAlchemyReagentList(names)
    local colored = {}
    for i = 1, #names do
        colored[#colored + 1] = ColorAlchemyReagentName(names[i])
    end
    return table.concat(colored, ", ")
end


local function BuildEffectIndex()
    local index = {}
    for _, reagent in ipairs(alchemyReagents) do
        local name = reagent[1]
        for _, effect in ipairs(reagent[2]) do
            index[effect] = index[effect] or {}
            table.insert(index[effect], name)
        end
    end
    return index
end

local function AddCodexHeader(lines, title)
    table.insert(lines, title)
    table.insert(lines, string.rep("-", 32))
end


local function AddThreeColumnLines(lines, rows, startAt, endAt, formatText)
    for i = startAt, math.min(endAt, #rows) do
        local row = rows[i]
        table.insert(lines, formatText(row))
    end
end

local function AddNameDescriptionLines(lines, rows, startAt, endAt)
    for i = startAt, math.min(endAt, #rows) do
        local row = rows[i]
        table.insert(lines, row[1] .. ":")
        table.insert(lines, "  " .. row[2])
    end
end

local function AddReagentsRange(lines, firstIndex, lastIndex)
    for i = firstIndex, math.min(lastIndex, #alchemyReagents) do
        local reagent = alchemyReagents[i]
        table.insert(lines, ColorAlchemyReagentName(reagent[1]))
        table.insert(lines, "  " .. ColorAlchemyEffectList(reagent[2]))
    end
end

local function AddEffectLines(lines, positive, startAt, endAt)
    local index = BuildEffectIndex()
    local effects = {}
    for effect in pairs(index) do
        local isPositive = positiveEffects[effect] == true
        if isPositive == positive then table.insert(effects, effect) end
    end
    table.sort(effects)
    for i = startAt, math.min(endAt, #effects) do
        local effect = effects[i]
        table.insert(lines, ColorAlchemyEffect(effect) .. ":")
        table.insert(lines, "  " .. ColorAlchemyReagentList(index[effect]))
    end
end

local function GetCodexMaxPage()
    return 28
end

-- -----------------------------------------------------------------------------
-- Search / Find system
-- Searches journal entries, marker names, profile, stats, and codex data.
-- -----------------------------------------------------------------------------
function LvxJournal.BuildSearchResults()
    local s = LvxJournal.savedVars
    if not s then return {} end
    local search = GetSearchState()
    if not search then return {} end

    local query = search.query or ""
    local scope = search.scope or "All"
    local results = {}

    if query == "" then
        search.results = results
        return results
    end

    if scope == "All" or scope == "Journal" or scope == "Current" or scope == "Bookmarks" then
        for i = 1, #(s.entries or {}) do
            local e = s.entries[i]
            local allowed = true
            if scope == "Current" then allowed = CategoryMatches(e, s.filter or "All Entries") end
            if scope == "Bookmarks" then allowed = e and e.favorite == true end
            if allowed and e and AnyContains(query, e.title, e.body, e.location, e.category, GetCategoryDisplay(e), e.time, e.modified) then
                AddSearchResult(results, "Journal", e.title or "Untitled Entry", GetCategoryDisplay(e) .. " - " .. (e.location or "Unknown"), i, nil)
            end
        end
    end

    if scope == "All" or scope == "Markers" then
        local marks = s.mapMarks or {}
        for i = 1, #marks do
            local mark = marks[i]
            if mark and AnyContains(query, mark.title, mark.pinName, mark.zone, mark.map, mark.world, mark.created, "map mark marker pin") then
                local title = tostring(mark.pinName or "")
                if title == "" then title = tostring(mark.title or "") end
                if title == "" then title = "Journal Map Mark" end
                AddSearchResult(results, "Marker", title, "Map Marker - " .. tostring(mark.zone or mark.map or "Unknown"), nil, nil, i)
            end
        end
    end

    if scope == "All" or scope == "Profile" then
        local profile = EnsureProfileTable()
        if profile and AnyContains(query, profile.name, profile.race, profile.class, profile.alliance, profile.birthplace, profile.personality, profile.goals, profile.companions, profile.enemies, profile.backstory) then
            AddSearchResult(results, "Profile", profile.name ~= "" and profile.name or "Character Profile", "Character profile page", nil, nil)
        end
    end

    if scope == "All" or scope == "Stats" then
        local rows = GetKnownZoneRowsSorted()
        for i = 1, #rows do
            local row = rows[i]
            if AnyContains(query, row.zone, row.first, row.last, "places visited zone travel") then
                AddSearchResult(results, "Stats", row.zone, "Places Visited - " .. tostring(row.visits) .. " visit(s)", nil, nil)
            end
        end
    end

    if scope == "All" or scope == "Codex" then
        for i, reagent in ipairs(alchemyReagents) do
            local effects = table.concat(reagent[2], ", ")
            if AnyContains(query, reagent[1], effects) then
                AddSearchResult(results, "Codex", reagent[1], "Alchemy reagent - " .. effects, nil, GetAlchemyReagentPage(i))
            end
        end

        local index = BuildEffectIndex()
        local effects = {}
        for effect in pairs(index) do table.insert(effects, effect) end
        table.sort(effects)
        for i, effect in ipairs(effects) do
            local reagentText = table.concat(index[effect], ", ")
            if AnyContains(query, effect, reagentText) then
                local page = positiveEffects[effect] and (i <= 9 and 6 or 7) or (i <= 9 and 8 or 9)
                AddSearchResult(results, "Codex", effect, "Alchemy effect - " .. reagentText, nil, page)
            end
        end

        for _, row in ipairs(potionSolvents) do
            if AnyContains(query, row[1], row[2], "potion solvent water") then
                AddSearchResult(results, "Codex", row[1], "Potion solvent - " .. row[2], nil, 10)
            end
        end
        for _, row in ipairs(poisonSolvents) do
            if AnyContains(query, row[1], row[2], "poison solvent oil") then
                AddSearchResult(results, "Codex", row[1], "Poison solvent - " .. row[2], nil, 11)
            end
        end

        for _, row in ipairs(aspectRunes) do
            if AnyContains(query, row[1], row[2], row[3], "aspect rune runestone enchanting") then
                AddSearchResult(results, "Codex", row[1], "Aspect rune - " .. row[2] .. " - " .. row[3], nil, 14)
            end
        end
        for _, row in ipairs(potencyRunes) do
            if AnyContains(query, row[1], row[3], row[4], "additive potency rune runestone enchanting") then
                AddSearchResult(results, "Codex", row[1], "Additive potency - " .. row[3] .. " - " .. row[4], nil, 15)
            end
            if AnyContains(query, row[2], row[3], row[4], "subtractive potency rune runestone enchanting") then
                AddSearchResult(results, "Codex", row[2], "Subtractive potency - " .. row[3] .. " - " .. row[4], nil, 16)
            end
        end
        for i, row in ipairs(essenceRunes) do
            if AnyContains(query, row[1], row[2], row[3], "essence rune runestone enchanting glyph") then
                AddSearchResult(results, "Codex", row[1], "Essence rune - " .. row[2] .. ": " .. row[3], nil, GetEssenceRunePage(i))
            end
        end

        for i, row in ipairs(craftingStations) do
            if AnyContains(query, row[1], row[2], "crafting station") then
                AddSearchResult(results, "Codex", row[1], "Crafting station - " .. row[2], nil, 21)
            end
        end
        for i, row in ipairs(craftingMaterials) do
            if AnyContains(query, row[1], row[2], "crafting material") then
                AddSearchResult(results, "Codex", row[1], "Crafting material - " .. row[2], nil, 22)
            end
        end
        for i, row in ipairs(armorTraits) do
            if AnyContains(query, row[1], row[2], "armor trait") then
                AddSearchResult(results, "Codex", row[1], "Armor trait - " .. row[2], nil, GetArmorTraitPage(i))
            end
        end
        for i, row in ipairs(weaponTraits) do
            if AnyContains(query, row[1], row[2], "weapon trait") then
                AddSearchResult(results, "Codex", row[1], "Weapon trait - " .. row[2], nil, GetWeaponTraitPage(i))
            end
        end
        for i, row in ipairs(jewelryTraits) do
            if AnyContains(query, row[1], row[2], "jewelry trait") then
                AddSearchResult(results, "Codex", row[1], "Jewelry trait - " .. row[2], nil, GetJewelryTraitPage(i))
            end
        end
    end

    search.results = results
    return results
end

local function GetSearchPageInfo()
    local search = GetSearchState()
    local results = search and search.results or {}
    local perPage = 8
    local total = #results
    local maxPage = math.max(1, math.ceil(total / perPage))
    search.page = tonumber(search.page) or 1
    if search.page < 1 then search.page = 1 end
    if search.page > maxPage then search.page = maxPage end
    local startIndex = ((search.page - 1) * perPage) + 1
    local endIndex = math.min(startIndex + perPage - 1, total)
    return results, search.page, maxPage, startIndex, endIndex, total, perPage
end

function LvxJournal.RefreshCodexPage()
    if not LvxJournal.codexText then return end
    local s = LvxJournal.savedVars
    if not s then return end
    s.stats = s.stats or {}

    local maxPage = GetCodexMaxPage()
    local page = tonumber(s.stats.codexPage) or 1
    if page < 1 then page = 1 end
    if page > maxPage then page = maxPage end
    s.stats.codexPage = page

    local lines = {}
    if page == 1 then
        AddCodexHeader(lines, "Alchemy Codex")
        table.insert(lines, "Reagents: " .. tostring(#alchemyReagents))
        table.insert(lines, "Potion solvents: " .. tostring(#potionSolvents))
        table.insert(lines, "Poison solvents: " .. tostring(#poisonSolvents))
        table.insert(lines, "")
        table.insert(lines, "Use Prev / Next to browse:")
        table.insert(lines, "- All reagent effects")
        table.insert(lines, "- Beneficial potion effects")
        table.insert(lines, "- Harmful poison effects")
        table.insert(lines, "- Solvent levels")
        table.insert(lines, "- Discovery/recipe notes")
        table.insert(lines, "")
        table.insert(lines, "Rule: two or more reagents must share an effect to reveal/create that effect.")
        table.insert(lines, "")
        table.insert(lines, "Color Key:")
        table.insert(lines, ColorAlchemyReagentName("Blue") .. " = Reagent")
        table.insert(lines, ColorText("3FAE4D", "Green") .. " = Beneficial effect")
        table.insert(lines, ColorText("B84A3A", "Red") .. " = Poison/ravage effect")
        table.insert(lines, ColorText("9B6BC9", "Purple") .. " = Debuff/control effect")
    elseif page == 2 then
        AddCodexHeader(lines, "Reagents A - C")
        AddReagentsRange(lines, 1, 10)
    elseif page == 3 then
        AddCodexHeader(lines, "Reagents D - L")
        AddReagentsRange(lines, 11, 19)
    elseif page == 4 then
        AddCodexHeader(lines, "Reagents M - S")
        AddReagentsRange(lines, 20, 28)
    elseif page == 5 then
        AddCodexHeader(lines, "Reagents T - Z")
        AddReagentsRange(lines, 29, 34)
    elseif page == 6 then
        AddCodexHeader(lines, "Potion Effects A - L")
        AddEffectLines(lines, true, 1, 9)
    elseif page == 7 then
        AddCodexHeader(lines, "Potion Effects M - Z")
        AddEffectLines(lines, true, 10, 20)
    elseif page == 8 then
        AddCodexHeader(lines, "Poison Effects A - L")
        AddEffectLines(lines, false, 1, 9)
    elseif page == 9 then
        AddCodexHeader(lines, "Poison Effects M - Z")
        AddEffectLines(lines, false, 10, 20)
    elseif page == 10 then
        AddCodexHeader(lines, "Potion Solvents")
        for _, v in ipairs(potionSolvents) do table.insert(lines, v[1] .. " - " .. v[2]) end
        table.insert(lines, "")
        table.insert(lines, "Waters make drinkable potions.")
    elseif page == 11 then
        AddCodexHeader(lines, "Poison Solvents")
        for _, v in ipairs(poisonSolvents) do table.insert(lines, v[1] .. " - " .. v[2]) end
        table.insert(lines, "")
        table.insert(lines, "Oils make weapon poisons.")
    elseif page == 12 then
        AddCodexHeader(lines, "Useful Discovery Notes")
        table.insert(lines, "Tri-stat potion:")
        table.insert(lines, "  Columbine + Bugloss + Mountain Flower")
        table.insert(lines, "")
        table.insert(lines, "Spell power potion:")
        table.insert(lines, "  Corn Flower + Lady's Smock + Water Hyacinth")
        table.insert(lines, "")
        table.insert(lines, "Weapon power potion:")
        table.insert(lines, "  Blessed Thistle + Dragonthorn + Water Hyacinth")
        table.insert(lines, "")
        table.insert(lines, "Invisibility options:")
        table.insert(lines, "  Namira's Rot + Nirnroot")
        table.insert(lines, "  Blue Entoloma + Spider Egg")
        table.insert(lines, "")
        table.insert(lines, "Speed options:")
        table.insert(lines, "  Blessed Thistle + Namira's Rot")
        table.insert(lines, "  Dragon Rheum + Powdered Mother of Pearl")
    elseif page == 13 then
        AddCodexHeader(lines, "Enchanting Codex")
        table.insert(lines, "Glyph formula:")
        table.insert(lines, "  Potency + Essence + Aspect")
        table.insert(lines, "")
        table.insert(lines, "Potency = level and additive/subtractive type")
        table.insert(lines, "Essence = effect family")
        table.insert(lines, "Aspect = quality/color/power")
        table.insert(lines, "")
        table.insert(lines, "The next pages list every core rune type.")
    elseif page == 14 then
        AddCodexHeader(lines, "Aspect Runestones")
        AddThreeColumnLines(lines, aspectRunes, 1, #aspectRunes, function(row)
            return row[1] .. " - " .. row[2] .. " - " .. row[3]
        end)
    elseif page == 15 then
        AddCodexHeader(lines, "Potency Runes: Additive")
        AddThreeColumnLines(lines, potencyRunes, 1, #potencyRunes, function(row)
            return row[1] .. " - " .. row[3] .. " - " .. row[4]
        end)
    elseif page == 16 then
        AddCodexHeader(lines, "Potency Runes: Subtractive")
        AddThreeColumnLines(lines, potencyRunes, 1, #potencyRunes, function(row)
            return row[2] .. " - " .. row[3] .. " - " .. row[4]
        end)
    elseif page == 17 then
        AddCodexHeader(lines, "Essence Runes A - H")
        AddThreeColumnLines(lines, essenceRunes, 1, 9, function(row)
            return row[1] .. " - " .. row[2] .. ": " .. row[3]
        end)
    elseif page == 18 then
        AddCodexHeader(lines, "Essence Runes I - O")
        AddThreeColumnLines(lines, essenceRunes, 10, 17, function(row)
            return row[1] .. " - " .. row[2] .. ": " .. row[3]
        end)
    elseif page == 19 then
        AddCodexHeader(lines, "Essence Runes R - Z")
        AddThreeColumnLines(lines, essenceRunes, 18, #essenceRunes, function(row)
            return row[1] .. " - " .. row[2] .. ": " .. row[3]
        end)
    elseif page == 20 then
        AddCodexHeader(lines, "Glyph Notes")
        table.insert(lines, "Armor glyphs usually increase max resources or defenses.")
        table.insert(lines, "Weapon glyphs usually add damage, absorb, weaken, or proc effects.")
        table.insert(lines, "Jewelry glyphs usually alter recovery, cost, damage, resistances, or potion use.")
        table.insert(lines, "")
        table.insert(lines, "Common picks:")
        table.insert(lines, "  Oko / Makko / Deni = Health / Magicka / Stamina")
        table.insert(lines, "  Rakeipa / Dekeipa / Meip = Fire / Frost / Shock")
        table.insert(lines, "  Hakeijo = Prismatic defense/offense")
        table.insert(lines, "  Kuta = gold-quality glyph")
    elseif page == 21 then
        AddCodexHeader(lines, "Crafting Codex Overview")
        AddNameDescriptionLines(lines, craftingStations, 1, #craftingStations)
    elseif page == 22 then
        AddCodexHeader(lines, "Crafting Materials")
        AddNameDescriptionLines(lines, craftingMaterials, 1, #craftingMaterials)
    elseif page == 23 then
        AddCodexHeader(lines, "Armor Traits")
        AddNameDescriptionLines(lines, armorTraits, 1, 6)
    elseif page == 24 then
        AddCodexHeader(lines, "Armor Traits Continued")
        AddNameDescriptionLines(lines, armorTraits, 7, #armorTraits)
    elseif page == 25 then
        AddCodexHeader(lines, "Weapon Traits")
        AddNameDescriptionLines(lines, weaponTraits, 1, 6)
    elseif page == 26 then
        AddCodexHeader(lines, "Weapon Traits Continued")
        AddNameDescriptionLines(lines, weaponTraits, 7, #weaponTraits)
    elseif page == 27 then
        AddCodexHeader(lines, "Jewelry Traits")
        AddNameDescriptionLines(lines, jewelryTraits, 1, 6)
    elseif page == 28 then
        AddCodexHeader(lines, "Jewelry / Provisioning Notes")
        AddNameDescriptionLines(lines, jewelryTraits, 7, #jewelryTraits)
        table.insert(lines, "")
        table.insert(lines, "Provisioning:")
        table.insert(lines, "  Food usually increases max stats.")
        table.insert(lines, "  Drinks usually increase recovery stats.")
        table.insert(lines, "  Recipes determine required level and buff type.")
        table.insert(lines, "")
        table.insert(lines, "Master writs:")
        table.insert(lines, "  Often require exact set, trait, style, quality, or recipe knowledge.")
    end

    LvxJournal.codexText:SetText(table.concat(lines, "\n"))
    if LvxJournal.codexTitle then
        LvxJournal.codexTitle:SetText("Codex Page " .. tostring(page) .. " / " .. tostring(maxPage))
    end
    if LvxJournal.codexFooterLabel then
        LvxJournal.codexFooterLabel:SetText("Alchemy / Enchanting / Crafting Codex")
    end
end

function LvxJournal.PrevCodexPage()
    local s = LvxJournal.savedVars
    if not s then return end
    s.stats = s.stats or {}
    local maxPage = GetCodexMaxPage()
    s.stats.codexPage = (tonumber(s.stats.codexPage) or 1) - 1
    if s.stats.codexPage < 1 then s.stats.codexPage = maxPage end
    s.viewMode = "codex"
    LvxJournal.RefreshAll()
end

function LvxJournal.NextCodexPage()
    local s = LvxJournal.savedVars
    if not s then return end
    s.stats = s.stats or {}
    local maxPage = GetCodexMaxPage()
    s.stats.codexPage = (tonumber(s.stats.codexPage) or 1) + 1
    if s.stats.codexPage > maxPage then s.stats.codexPage = 1 end
    s.viewMode = "codex"
    LvxJournal.RefreshAll()
end

local function CreateLabel(parent, text, x, y, width, height, font, color)
    local label = wm:CreateControl(nil, parent, CT_LABEL)
    label:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    label:SetDimensions(width or 200, height or 24)
    label:SetFont(font or "ZoFontGame")
    if color then
        label:SetColor(color[1], color[2], color[3], color[4] or 1)
    else
        label:SetColor(0.16, 0.075, 0.018, 1)
    end
    label:SetText(text)
    return label
end

-- -----------------------------------------------------------------------------
-- Hover help tooltips
-- -----------------------------------------------------------------------------
journalTooltipText = {
    ["New"] = "Start a new journal entry.",
    ["Archive"] = "Open the saved-entry archive.",
    ["Save"] = "Save the current journal entry.",
    ["Del"] = "Delete the current journal entry.",
    ["Book"] = "Mark or unmark the current entry as a favorite.",
    ["RP"] = "Toggle roleplay time display.",
    ["Find"] = "Search journal entries, profile, stats, and codex text.",
    ["Journal"] = "Open journal writing, templates, search, and saved entry shortcuts.",
    ["Favorites"] = "Show entries marked with the Book button.",
    ["Archives"] = "Open categorized saved journal entries.",
    ["Character"] = "Open profile, character stats, places visited, and personal notes.",
    ["World / Stats"] = "Open world stats, Tales of Tribute stats, places visited, and travel logs.",
    ["Crafting"] = "Open crafting notes and crafting codex.",
    ["Tools"] = "Open roleplay tools such as dice, oracle, coin toss, random activity, map marks, and export.",
    ["Options"] = "Open journal settings and help pages.",
    ["Back"] = "Return to the previous/main left-page menu.",
    ["Themes"] = "Change the journal book background theme.",
    ["Commands"] = "View slash commands for the addon.",
    ["Map Pins"] = "Configure journal map pin behavior and icon settings.",
    ["Controls"] = "Configure journal control behavior.",
    ["Maintenance"] = "Configure tracking toggles and cleanup actions.",
    ["Help"] = "Read help text and toggle hover explanations.",
    ["Oracle"] = "Ask a roleplay yes/no question and roll an oracle result.",
    ["Dice"] = "Roll tabletop dice for roleplay decisions.",
    ["Coin Toss"] = "Flip a coin for a heads-or-tails result.",
    ["Random Destination"] = "Pick a random ESO zone for roleplay travel.",
    ["Random Activity"] = "Pick a random activity prompt.",
    ["Daily Quests"] = "Track repeatable daily tasks.",
    ["Map Marks"] = "Open the Map Marker Manager for standalone map marks and journal-linked pins.",
    ["Notes Backup"] = "Export personal notes through the optional backup addon.",
    ["Export"] = "Export journal data to SavedVariables after reload UI.",
    ["New Mark"] = "Create a new standalone map marker at your current location. It uses the Mark Name box if you typed one. It does not create or delete a journal entry.",
    ["Prev Page"] = "Show the previous map marks page.",
    ["Next Page"] = "Show the next map marks page.",
    ["Delete Mark"] = "Delete only the selected/visible map marker. This removes the pin/mark, not the linked journal entry.",
    ["Icon"] = "Change the icon used for new saved map marks.",
    ["Refresh"] = "Refresh journal map pins on the map.",
    ["Hover Help: ON"] = "Turn hover explanation boxes off.",
    ["Hover Help: OFF"] = "Turn hover explanation boxes on.",
    ["Mark Name"] = "Type a name here to rename the marker shown on this page live. New Mark creates a new standalone marker with the typed name.",
    ["Pin Toggle"] = "Toggle the journal entry map pin on or off. Checked adds a pin for this entry. Unchecked removes its pin.",
}

function GetJournalTooltipText(text)
    text = tostring(text or "")
    text = text:gsub("^%*%s*", "")
    text = text:gsub("^%[[Xx ]%]%s*", "")
    return journalTooltipText[text]
end

local function HideJournalHelpTooltip()
    if ClearTooltip and InformationTooltip then
        ClearTooltip(InformationTooltip)
    end
end

local function ShowJournalHelpTooltip(control)
    local s = LvxJournal.savedVars
    if s and s.showHelpTooltips == false then return end
    if not control or not control.lvxTooltipText or control.lvxTooltipText == "" then return end
    if not InitializeTooltip or not SetTooltipText or not InformationTooltip then return end
    InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
    SetTooltipText(InformationTooltip, control.lvxTooltipText)
end

function SetJournalTooltip(control, tooltipText)
    if not control then return end
    control.lvxTooltipText = tooltipText
    if control.lvxTooltipHandlersSet then return end
    control.lvxTooltipHandlersSet = true
    control:SetHandler("OnMouseEnter", function(self)
        self.lvxTooltipHovering = true
        if zo_callLater then
            zo_callLater(function()
                if self and self.lvxTooltipHovering == true then
                    ShowJournalHelpTooltip(self)
                end
            end, 1200)
        else
            ShowJournalHelpTooltip(self)
        end
    end)
    control:SetHandler("OnMouseExit", function(self)
        if self then self.lvxTooltipHovering = false end
        HideJournalHelpTooltip()
    end)
end

local function CreateButton(parent, text, x, y, width, height, callback, tooltipText)
    local btn = wm:CreateControl(nil, parent, CT_BUTTON)
    btn:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    btn:SetDimensions(width or 90, height or 28)
    btn:SetFont("ZoFontGame")
    btn:SetText(text)
    btn:SetNormalFontColor(0.18, 0.075, 0.018, 1)
    btn:SetMouseOverFontColor(0.70, 0.28, 0.03, 1)
    btn:SetPressedFontColor(0.08, 0.03, 0.01, 1)
    btn:SetHandler("OnClicked", callback)
    SetJournalTooltip(btn, tooltipText or GetJournalTooltipText(text))
    return btn
end

local function CreateDivider(parent, x, y, w)
    local line = wm:CreateControl(nil, parent, CT_BACKDROP)
    line:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    line:SetDimensions(w, 2)
    line:SetCenterColor(0.30, 0.18, 0.07, 0.55)
    line:SetEdgeColor(0, 0, 0, 0)
    return line
end

local function RefreshTimeButton()
    if not LvxJournal.timeButton then return end
    local s = LvxJournal.savedVars or {}
    LvxJournal.timeButton:SetText(s.useRoleplayTime and "RP" or "Real")
end

function LvxJournal.RefreshCategoryButtons()
    if not LvxJournal.categoryRows then return end

    local menus = LvxJournal.chronicleMenus or {}
    local menuName = LvxJournal.currentChronicleMenu or "main"
    local menu = menus[menuName] or menus.main or {}

    if LvxJournal.sectionLabel then
        local title = string.upper(menuName or "main")
        if menuName == "main" then title = "CHRONICLES" end
        LvxJournal.sectionLabel:SetText(title)
    end

    for i = 1, #LvxJournal.categoryRows do
        local row = LvxJournal.categoryRows[i]
        local item = menu[i]
        if item then
            row.item = item
            row.bg:SetHidden(false)
            row.label:SetHidden(false)
            row.count:SetHidden(false)
            row.button:SetHidden(false)
            row.label:SetText(item.text or "")
            local tooltipText = GetJournalTooltipText(item.text or "")
            SetJournalTooltip(row.button, tooltipText)
            SetJournalTooltip(row.bg, tooltipText)

            if item.filter then
                local count = CountForFilter(item.filter)
                if item.filter == "Stats" or item.filter == "Codex" or item.filter == "Profile" or item.filter == "Options" then
                    row.count:SetText("")
                else
                    row.count:SetText("(" .. tostring(count) .. ")")
                end
            else
                row.count:SetText("")
            end

            local active = false
            local activeKey = LvxJournal.savedVars.activeChronicleKey
            local currentStatsPage = 1
            if LvxJournal.savedVars.stats then
                currentStatsPage = tonumber(LvxJournal.savedVars.stats.statsPage) or 1
            end

            if item.view == "tools" and LvxJournal.savedVars.viewMode == "tools" then
                active = (item.page or "main") == (LvxJournal.savedVars.toolsPage or "main")
            elseif item.view == "options" and LvxJournal.savedVars.viewMode == "options" then
                active = (item.page or "main") == (LvxJournal.savedVars.optionsPage or "main")
            elseif item.action == "optionsMenu" and LvxJournal.savedVars.viewMode == "options" then
                active = true
            elseif item.filter == "Stats" and LvxJournal.savedVars.viewMode == "stats" then
                if item.statsPage == 12 then
                    active = currentStatsPage >= 12
                elseif item.statsPage then
                    active = currentStatsPage == item.statsPage
                else
                    active = currentStatsPage < 11
                end
            elseif item.key and activeKey == item.key then
                active = true
            elseif item.filter and item.filter == (LvxJournal.savedVars.filter or "All Entries") then
                active = true
            end
            if active then
                row.label:SetColor(0.55, 0.12, 0.02, 1)
                row.bg:SetCenterColor(0.70, 0.30, 0.08, 0.22)
            else
                row.label:SetColor(0.16, 0.075, 0.018, 1)
                row.bg:SetCenterColor(0.50, 0.34, 0.14, 0.16)
            end
        else
            row.item = nil
            row.bg:SetHidden(true)
            row.label:SetHidden(true)
            row.count:SetHidden(true)
            row.button:SetHidden(true)
        end
    end
end

function LvxJournal.OpenSearch()
    if LvxJournal.savedVars then
        LvxJournal.savedVars.activeChronicleKey = "JournalSearch"
    end
    LvxJournal.AutoSaveCurrentEntry(true)
    local search = GetSearchState()
    if not search then return end
    search.open = true
    search.page = 1
    search.query = search.query or ""
    search.scope = search.scope or "All"
    LvxJournal.savedVars.viewMode = "search"
    LvxJournal.BuildSearchResults()
    LvxJournal.RefreshAll()
    if LvxJournal.searchBox and LvxJournal.searchBox.TakeFocus then
        LvxJournal.searchBox:TakeFocus()
    end
end

function LvxJournal.CloseSearch()
    local search = GetSearchState()
    if search then search.open = false end
    local filter = LvxJournal.savedVars.filter or "All Entries"
    if filter == "Stats" then
        LvxJournal.savedVars.viewMode = "stats"
    elseif filter == "Profile" then
        LvxJournal.savedVars.viewMode = "profile"
    elseif filter == "Codex" then
        LvxJournal.savedVars.viewMode = "codex"
    elseif filter == "Options" then
        LvxJournal.savedVars.viewMode = "options"
    else
        LvxJournal.savedVars.viewMode = "archive"
    end
    LvxJournal.RefreshAll()
end

function LvxJournal.RunSearch()
    local search = GetSearchState()
    if not search then return end
    if LvxJournal.searchBox then
        search.query = LvxJournal.searchBox:GetText() or ""
    end
    search.page = 1
    LvxJournal.savedVars.viewMode = "search"
    LvxJournal.BuildSearchResults()
    LvxJournal.RefreshAll()
end

function LvxJournal.CycleSearchScope()
    local search = GetSearchState()
    if not search then return end
    if search.scope == "All" then
        search.scope = "Journal"
    elseif search.scope == "Journal" then
        search.scope = "Markers"
    elseif search.scope == "Markers" then
        search.scope = "Current"
    elseif search.scope == "Current" then
        search.scope = "Bookmarks"
    elseif search.scope == "Bookmarks" then
        search.scope = "Codex"
    elseif search.scope == "Codex" then
        search.scope = "Profile"
    elseif search.scope == "Profile" then
        search.scope = "Stats"
    else
        search.scope = "All"
    end
    search.page = 1
    LvxJournal.RunSearch()
end

function LvxJournal.PrevSearchPage()
    local search = GetSearchState()
    if not search then return end
    search.page = math.max(1, (tonumber(search.page) or 1) - 1)
    LvxJournal.RefreshAll()
end

function LvxJournal.NextSearchPage()
    local search = GetSearchState()
    if not search then return end
    local results, page, maxPage = GetSearchPageInfo()
    search.page = math.min(maxPage, (tonumber(search.page) or 1) + 1)
    LvxJournal.RefreshAll()
end

function LvxJournal.OpenSearchResult(result)
    if not result then return end
    if result.resultType == "Marker" and result.markIndex then
        LvxJournal.savedVars.mapMarkPage = tonumber(result.markIndex) or 1
        LvxJournal.savedVars.selectedMapMarkIndex = tonumber(result.markIndex) or nil
        LvxJournal.ShowToolsPage("mapMarks")
    elseif result.resultType == "Journal" and result.realIndex then
        LvxJournal.SelectEntry(result.realIndex)
    elseif result.resultType == "Codex" and result.codexPage then
        LvxJournal.savedVars.filter = "Codex"
        LvxJournal.savedVars.viewMode = "codex"
        LvxJournal.savedVars.profile = LvxJournal.savedVars.profile or {}
    LvxJournal.savedVars.theme = LvxJournal.savedVars.theme or "blank"
    LvxJournal.savedVars.optionsPage = LvxJournal.savedVars.optionsPage or "main"
    if LvxJournal.savedVars.autoFocusMouse == nil then LvxJournal.savedVars.autoFocusMouse = false end
    if LvxJournal.savedVars.showHelpTooltips == nil then LvxJournal.savedVars.showHelpTooltips = true end
    if LvxJournal.savedVars.showMapPins == nil then LvxJournal.savedVars.showMapPins = true end
    if LvxJournal.savedVars.autoPinJournalEntries == nil then LvxJournal.savedVars.autoPinJournalEntries = false end
    if LvxJournal.savedVars.useBuiltInMapPinFallback == nil then LvxJournal.savedVars.useBuiltInMapPinFallback = false end
    LvxJournal.savedVars.mapMarkPage = tonumber(LvxJournal.savedVars.mapMarkPage) or 1
    LvxJournal.savedVars.mapMarkIcon = LvxJournal.savedVars.mapMarkIcon or "book"
    LvxJournal.savedVars.pendingDeleteIndex = nil
    LvxJournal.savedVars.pendingDeleteArmed = nil
    LvxJournal.savedVars.stats = LvxJournal.savedVars.stats or {}
        LvxJournal.savedVars.stats.codexPage = result.codexPage
        LvxJournal.RefreshAll()
    elseif result.resultType == "Profile" then
        LvxJournal.savedVars.filter = "Profile"
        LvxJournal.savedVars.viewMode = "profile"
        LvxJournal.RefreshAll()
    elseif result.resultType == "Stats" then
        LvxJournal.savedVars.filter = "Stats"
        LvxJournal.savedVars.viewMode = "stats"
        LvxJournal.savedVars.profile = LvxJournal.savedVars.profile or {}
    LvxJournal.savedVars.theme = LvxJournal.savedVars.theme or "blank"
    LvxJournal.savedVars.pendingDeleteIndex = nil
    LvxJournal.savedVars.pendingDeleteArmed = nil
    LvxJournal.savedVars.stats = LvxJournal.savedVars.stats or {}
        LvxJournal.savedVars.stats.statsPage = 12
        LvxJournal.RefreshAll()
    end
end

function LvxJournal.RefreshSearch()
    if not LvxJournal.searchRows then return end
    local search = GetSearchState()
    if not search then return end

    if LvxJournal.searchBox and LvxJournal.searchBox:GetText() ~= search.query then
        LvxJournal.searchBox:SetText(search.query or "")
    end
    if LvxJournal.searchScopeButton then
        LvxJournal.searchScopeButton:SetText(search.scope or "All")
    end
    if LvxJournal.searchTitle then
        LvxJournal.searchTitle:SetText("Find Journal / Markers / Codex / Stats")
    end

    local results, page, maxPage, startIndex, endIndex, total = GetSearchPageInfo()

    if LvxJournal.searchEmpty then
        local query = search.query or ""
        if query == "" then
            LvxJournal.searchEmpty:SetText("Type a word, marker name, reagent, rune, trait, location, profile detail, or entry title, then click Go.")
            LvxJournal.searchEmpty:SetHidden(false)
        elseif total == 0 then
            LvxJournal.searchEmpty:SetText("No results found for: " .. query)
            LvxJournal.searchEmpty:SetHidden(false)
        else
            LvxJournal.searchEmpty:SetHidden(true)
        end
    end

    for i = 1, #LvxJournal.searchRows do
        local row = LvxJournal.searchRows[i]
        local result = results[startIndex + i - 1]
        if result then
            row.result = result
            row.title:SetText("[" .. (result.resultType or "Result") .. "] " .. (result.title or "Result"))
            row.sub:SetText(result.sub or "")
            row.bg:SetHidden(false)
            row.title:SetHidden(false)
            row.sub:SetHidden(false)
            if row.button then row.button:SetHidden(false) end
        else
            row.result = nil
            row.bg:SetHidden(true)
            row.title:SetHidden(true)
            row.sub:SetHidden(true)
            if row.button then row.button:SetHidden(true) end
        end
    end

    if LvxJournal.searchFooterLabel then
        if total == 0 then
            LvxJournal.searchFooterLabel:SetText("0 Results")
        else
            LvxJournal.searchFooterLabel:SetText(tostring(startIndex) .. " - " .. tostring(endIndex) .. " of " .. tostring(total) .. " Results  |  Page " .. tostring(page) .. " / " .. tostring(maxPage))
        end
    end
    if LvxJournal.searchPrevButton then LvxJournal.searchPrevButton:SetHidden(total <= 8) end
    if LvxJournal.searchNextButton then LvxJournal.searchNextButton:SetHidden(total <= 8) end
end

function LvxJournal.RefreshArchive()
    if not LvxJournal.archiveRows then return end

    local visible, page, maxPage, startIndex, endIndex, total = GetArchivePageInfo()
    local filter = LvxJournal.savedVars.filter or "All Entries"

    if LvxJournal.archiveTitle then
        LvxJournal.archiveTitle:SetText(filter .. " Archive")
    end

    if LvxJournal.archiveEmpty then
        if #visible == 0 then
            LvxJournal.archiveEmpty:SetText("No entries in this section yet. Click New to add one.")
            LvxJournal.archiveEmpty:SetHidden(false)
        else
            LvxJournal.archiveEmpty:SetHidden(true)
        end
    end

    for i = 1, #LvxJournal.archiveRows do
        local row = LvxJournal.archiveRows[i]
        local data = visible[startIndex + i - 1]

        if data and data.entry then
            local e = data.entry
            row.title:SetText((e.favorite and "[B] " or "") .. (e.title or "Untitled"))
            row.sub:SetText(GetCategoryDisplay(e) .. " - " .. (e.location or "Unknown"))
            row.realIndex = data.realIndex

            row.bg:SetHidden(false)
            row.title:SetHidden(false)
            row.sub:SetHidden(false)
            if row.button then row.button:SetHidden(false) end
        else
            row.realIndex = nil
            row.bg:SetHidden(true)
            row.title:SetHidden(true)
            row.sub:SetHidden(true)
            if row.button then row.button:SetHidden(true) end
        end
    end
end

local function SetControlListHidden(list, hidden)
    if not list then return end
    for i = 1, #list do
        if list[i] then list[i]:SetHidden(hidden) end
    end
end

function LvxJournal.HideToolsControlsHard()
    SetControlListHidden(LvxJournal.toolsControls, true)

    if LvxJournal.toolButtons then
        for i = 1, #LvxJournal.toolButtons do
            if LvxJournal.toolButtons[i] then LvxJournal.toolButtons[i]:SetHidden(true) end
        end
    end

    for i = 1, 12 do
        local btn = LvxJournal["toolButton" .. tostring(i)]
        if btn then btn:SetHidden(true) end
    end

    if LvxJournal.toolsTitle then LvxJournal.toolsTitle:SetHidden(true) end
    if LvxJournal.toolsIcon then LvxJournal.toolsIcon:SetHidden(true) end
    if LvxJournal.toolsResultLabel then LvxJournal.toolsResultLabel:SetHidden(true) end
    if LvxJournal.toolsFooter then LvxJournal.toolsFooter:SetHidden(true) end
    if LvxJournal.diceNumberLabel then LvxJournal.diceNumberLabel:SetHidden(true) end
end

function LvxJournal.RefreshViewMode()
    local mode = LvxJournal.savedVars.viewMode or "archive"
    local archiveHidden = mode ~= "archive"
    local editorHidden = mode ~= "edit"
    local readHidden = mode ~= "read"
    local statsHidden = mode ~= "stats"
    local codexHidden = mode ~= "codex"
    local searchHidden = mode ~= "search"
    local templateHidden = mode ~= "templates"
    local profileHidden = mode ~= "profile"
    local optionsHidden = mode ~= "options"
    local toolsHidden = mode ~= "tools"

    SetControlListHidden(LvxJournal.archiveControls, archiveHidden)
    SetControlListHidden(LvxJournal.editorControls, editorHidden)
    SetControlListHidden(LvxJournal.readControls, readHidden)
    SetControlListHidden(LvxJournal.statsControls, statsHidden)
    SetControlListHidden(LvxJournal.codexControls, codexHidden)
    SetControlListHidden(LvxJournal.searchControls, searchHidden)
    SetControlListHidden(LvxJournal.templateControls, templateHidden)
    SetControlListHidden(LvxJournal.profileControls, profileHidden)
    SetControlListHidden(LvxJournal.optionsControls, optionsHidden)
    SetControlListHidden(LvxJournal.toolsControls, toolsHidden)

    if LvxJournal.archiveRows then
        for i = 1, #LvxJournal.archiveRows do
            local row = LvxJournal.archiveRows[i]
            if archiveHidden then
                row.bg:SetHidden(true)
                row.title:SetHidden(true)
                row.sub:SetHidden(true)
                if row.button then row.button:SetHidden(true) end
            end
        end
    end

    if LvxJournal.searchRows then
        for i = 1, #LvxJournal.searchRows do
            local row = LvxJournal.searchRows[i]
            if searchHidden then
                row.bg:SetHidden(true)
                row.title:SetHidden(true)
                row.sub:SetHidden(true)
                if row.button then row.button:SetHidden(true) end
            end
        end
    end

    if mode == "archive" then
        LvxJournal.RefreshArchive()
    elseif mode == "search" then
        LvxJournal.RefreshSearch()
    elseif mode == "stats" then
        LvxJournal.RefreshStatsPage()
    elseif mode == "codex" then
        LvxJournal.RefreshCodexPage()
    elseif mode == "profile" then
        LvxJournal.LoadProfile()
    elseif mode == "options" then
        LvxJournal.RefreshOptionsPage()
    elseif mode == "tools" then
        if LvxJournal.Tools and LvxJournal.Tools.RefreshPage then LvxJournal.Tools.RefreshPage() end
    elseif mode == "read" then
        LvxJournal.LoadReadEntry()
    else
        LvxJournal.LoadSelectedEntry()
        if LvxJournal.RefreshEditorMapButtons then LvxJournal.RefreshEditorMapButtons() end
        if LvxJournal.HideToolsControlsHard then LvxJournal.HideToolsControlsHard() end
    end
end

function LvxJournal.RefreshFooter()
    if not LvxJournal.footerLabel then return end

    local visible, page, maxPage, startIndex, endIndex, total = GetArchivePageInfo()
    if total == 0 then
        LvxJournal.footerLabel:SetText("0 Entries")
    else
        LvxJournal.footerLabel:SetText(tostring(startIndex) .. " - " .. tostring(endIndex) .. " of " .. tostring(total) .. " Entries  |  Page " .. tostring(page) .. " / " .. tostring(maxPage))
    end

    if LvxJournal.prevPageButton then
        LvxJournal.prevPageButton:SetHidden(total <= 8)
    end
    if LvxJournal.nextPageButton then
        LvxJournal.nextPageButton:SetHidden(total <= 8)
    end
end

function LvxJournal.PrevArchivePage()
    LvxJournal.AutoSaveCurrentEntry(true)
    local s = LvxJournal.savedVars
    s.archivePage = math.max(1, (tonumber(s.archivePage) or 1) - 1)
    s.viewMode = "archive"
    LvxJournal.RefreshAll()
end

function LvxJournal.NextArchivePage()
    LvxJournal.AutoSaveCurrentEntry(true)
    local visible, page, maxPage = GetArchivePageInfo()
    local s = LvxJournal.savedVars
    s.archivePage = math.min(maxPage, (tonumber(s.archivePage) or 1) + 1)
    s.viewMode = "archive"
    LvxJournal.RefreshAll()
end

-- -----------------------------------------------------------------------------
-- Main view refresh / show-hide routing
-- -----------------------------------------------------------------------------
function LvxJournal.RefreshAll()
    if not LvxJournal.savedVars then return end
    RefreshTimeButton()
    LvxJournal.RefreshCategoryButtons()
    LvxJournal.RefreshFooter()
    LvxJournal.RefreshViewMode()
end

function LvxJournal.SelectEntry(realIndex)
    if not LvxJournal.savedVars.entries[realIndex] then return end

    LvxJournal.AutoSaveCurrentEntry(true)
    LvxJournal.savedVars.selectedIndex = realIndex
    LvxJournal.savedVars.lastOpenedIndex = realIndex
    LvxJournal.savedVars.viewMode = "read"
    LvxJournal.RefreshAll()
end

function LvxJournal.SelectRelativeEntry(delta)
    local s = LvxJournal.savedVars
    if not s then return end
    LvxJournal.AutoSaveCurrentEntry(true)

    local visible = GetVisibleEntries()
    if #visible == 0 then return end

    local current = s.selectedIndex or s.lastOpenedIndex or 1
    local position = nil
    for i = 1, #visible do
        if visible[i].realIndex == current then
            position = i
            break
        end
    end

    position = position or 1
    position = position + (tonumber(delta) or 0)
    if position < 1 then position = #visible end
    if position > #visible then position = 1 end

    local realIndex = visible[position].realIndex
    if realIndex and s.entries[realIndex] then
        s.selectedIndex = realIndex
        s.lastOpenedIndex = realIndex
        s.viewMode = "read"
        LvxJournal.RefreshAll()
    end
end

function LvxJournal.ShowArchive()
    LvxJournal.AutoSaveCurrentEntry(true)
    LvxJournal.AutoSaveProfile(true)
    if LvxJournal.savedVars.filter == "Stats" or LvxJournal.savedVars.filter == "Codex" or LvxJournal.savedVars.filter == "Options" then
        LvxJournal.savedVars.filter = "All Entries"
    end
    LvxJournal.savedVars.viewMode = "archive"
    LvxJournal.RefreshAll()
end

-- -----------------------------------------------------------------------------
-- Window construction
-- All controls are created once, then shown/hidden by RefreshAll().
-- -----------------------------------------------------------------------------
function LvxJournal.CreateWindow()
    if LvxJournal.window then return end

    local s = LvxJournal.savedVars or defaults

    local win = wm:CreateTopLevelWindow("LvxJournalWindow")
    win:SetDimensions(1200, 750)
    win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, s.windowX or 135, s.windowY or 35)
    win:SetMouseEnabled(true)
    win:SetMovable(true)
    win:SetClampedToScreen(true)
    win:SetHidden(true)
    win:SetDrawTier(DT_HIGH)
    win:SetDrawLayer(DL_CONTROLS)
    win:SetHandler("OnMoveStop", function(self)
        LvxJournal.savedVars.windowX = self:GetLeft()
        LvxJournal.savedVars.windowY = self:GetTop()
    end)
    win:SetHandler("OnHide", function()
        LvxJournal.AutoSaveCurrentEntry(true)
        LvxJournal.AutoSaveProfile(true)
    end)

    local texture = wm:CreateControl(nil, win, CT_TEXTURE)
    texture:SetAnchorFill(win)
    texture:SetTexture(GetCurrentTheme().texture)
    texture:SetMouseEnabled(false)
    LvxJournal.bookTexture = texture

    CreateButton(win, "X", 1120, 54, 32, 30, function() LvxJournal.ToggleWindow(false) end)

    LvxJournal.sectionLabel = CreateLabel(win, "CHRONICLES", 300, 78, 260, 42, "ZoFontGameBold")
    CreateDivider(win, 250, 126, 300)

    LvxJournal.categoryRows = {}
    LvxJournal.chronicleMenus = {
        main = {
            { text = "Journal", menu = "journal" },
            { text = "Favorites", filter = "Bookmarks", key = "Favorites" },
            { text = "Archives", menu = "archives" },
            { text = "Character", menu = "character" },
            { text = "World / Stats", menu = "world" },
            { text = "Crafting", menu = "crafting" },
            { text = "Tools", menu = "tools" },
            { text = "Options", action = "optionsMenu", key = "Options" },
        },
        journal = {
            { text = "New Entry", action = "new", key = "JournalNew" },
            { text = "Save Entry", action = "save", key = "JournalSave" },
            { text = "Search", action = "search", key = "JournalSearch" },
            { text = "Templates", action = "templates", key = "JournalTemplates" },
            { text = "All Entries", filter = "All Entries", key = "AllEntries" },
            { text = "Personal Notes", filter = "Personal Notes", key = "PersonalNotes" },
            { text = "Back", menu = "main" },
        },
        archives = {
            { text = "All Entries", filter = "All Entries", key = "AllEntries" },
            { text = "Favorites", filter = "Bookmarks", key = "Favorites" },
            { text = "Quest Log", filter = "Quest Log", key = "QuestLog" },
            { text = "Travel Log", filter = "Travel Log", key = "TravelLog" },
            { text = "Death Log", filter = "Death Log", key = "DeathLog" },
            { text = "Achievement Log", filter = "Achievement Log", key = "AchievementLog" },
            { text = "Crafting Notes", filter = "Crafting Notes", key = "CraftingNotes" },
            { text = "Back", menu = "main" },
        },
        character = {
            { text = "Profile", filter = "Profile", key = "Profile" },
            { text = "Character Stats", filter = "Stats", statsPage = 1, key = "CharacterStats" },
            { text = "Places Visited", filter = "Stats", statsPage = 12, key = "PlacesVisited" },
            { text = "Personal Notes", filter = "Personal Notes", key = "PersonalNotes" },
            { text = "Back", menu = "main" },
        },
        world = {
            { text = "Stats", filter = "Stats", statsPage = 1, key = "WorldStats" },
            { text = "Tales of Tribute", filter = "Stats", statsPage = 10, key = "TributeStats" },
            { text = "Places Visited", filter = "Stats", statsPage = 12, key = "PlacesVisited" },
            { text = "Travel Log", filter = "Travel Log", key = "TravelLog" },
            { text = "Achievement Log", filter = "Achievement Log", key = "AchievementLog" },
            { text = "Back", menu = "main" },
        },
        crafting = {
            { text = "Crafting Codex", filter = "Codex", key = "CraftingCodex" },
            { text = "Crafting Notes", filter = "Crafting Notes", key = "CraftingNotes" },
            { text = "Back", menu = "main" },
        },
        tools = {
            { text = "Oracle", view = "tools", page = "oracle", key = "ToolOracle" },
            { text = "Dice", view = "tools", page = "dice", key = "ToolDice" },
            { text = "Coin Toss", view = "tools", page = "coin", key = "ToolCoin" },
            { text = "Random Destination", view = "tools", page = "destination", key = "ToolDestination" },
            { text = "Random Activity", view = "tools", page = "activity", key = "ToolActivity" },
            { text = "Daily Quests", view = "tools", page = "daily", key = "ToolDaily" },
            { text = "Map Marks", view = "tools", page = "mapMarks", key = "ToolMapMarks" },
            { text = "Notes Backup", view = "tools", page = "personalExport", key = "ToolPersonalExport" },
            { text = "Export", view = "tools", page = "export", key = "ToolExport" },
            { text = "Back", menu = "main" },
        },
        options = {
            { text = "Themes", view = "options", page = "themes", key = "OptionsThemes" },
            { text = "Commands", view = "options", page = "commands", key = "OptionsCommands" },
            { text = "Map Pins", view = "options", page = "mappins", key = "OptionsMapPins" },
            { text = "Controls", view = "options", page = "controls", key = "OptionsControls" },
            { text = "Maintenance", view = "options", page = "maintenance", key = "OptionsMaintenance" },
            { text = "Help", view = "options", page = "help", key = "OptionsHelp" },
            { text = "Back", menu = "main" },
        },
    }
    LvxJournal.currentChronicleMenu = LvxJournal.currentChronicleMenu or "main"

    local tabX, tabY = 145, 165
    for i = 1, 11 do
        local y = tabY + ((i - 1) * 36)
        local bg = wm:CreateControl(nil, win, CT_BACKDROP)
        bg:SetAnchor(TOPLEFT, win, TOPLEFT, tabX, y - 4)
        bg:SetDimensions(245, 36)
        bg:SetCenterColor(0.50, 0.34, 0.14, 0.16)
        bg:SetEdgeColor(0.22, 0.12, 0.04, 0.38)
        bg:SetEdgeTexture("", 1, 1, 1)
        bg:SetMouseEnabled(true)

        local label = CreateLabel(win, "", tabX + 22, y, 170, 24, "ZoFontGame")
        local count = CreateLabel(win, "", tabX + 185, y, 55, 24, "ZoFontGameSmall")
        count:SetColor(0.25, 0.12, 0.035, 0.85)

        local tabButton = wm:CreateControl(nil, bg, CT_BUTTON)
        tabButton:SetAnchorFill(bg)
        tabButton:SetMouseEnabled(true)
        local function onMenuClick()
            local row = LvxJournal.categoryRows[i]
            if row then LvxJournal.HandleChronicleMenuItem(row.item) end
        end
        bg:SetHandler("OnMouseUp", onMenuClick)
        tabButton:SetHandler("OnClicked", onMenuClick)

        LvxJournal.categoryRows[i] = { bg = bg, label = label, count = count, button = tabButton }
    end

    local actionX, actionY = 710, 70
    CreateButton(win, "New", actionX, actionY, 58, 24, function() LvxJournal.AddManualEntry() end)
    CreateButton(win, "Archive", actionX + 66, actionY, 72, 24, function() LvxJournal.ShowArchive() end)
    CreateButton(win, "Save", actionX + 146, actionY, 54, 24, function() LvxJournal.SaveCurrentEntry() end)
    CreateButton(win, "Del", actionX + 206, actionY, 42, 24, function() LvxJournal.DeleteCurrentEntry() end)
    CreateButton(win, "Book", actionX + 254, actionY, 48, 24, function() LvxJournal.ToggleFavorite() end)

    LvxJournal.timeButton = CreateButton(win, "RP", actionX + 308, actionY, 45, 24, function()
        LvxJournal.AutoSaveCurrentEntry(true)
        LvxJournal.savedVars.useRoleplayTime = not LvxJournal.savedVars.useRoleplayTime
        LvxJournal.RefreshAll()
    end)

    -- Keep Find slightly inside the right page so it does not sit on the page border artwork.
    LvxJournal.searchTopButton = CreateButton(win, "Find", actionX + 338, actionY, 50, 24, function() LvxJournal.OpenSearch() end)

    LvxJournal.listRows = nil

    LvxJournal.archiveControls = {}
    LvxJournal.editorControls = {}
    LvxJournal.readControls = {}
    LvxJournal.archiveRows = {}

    LvxJournal.archiveTitle = CreateLabel(win, "Archive", 710, 108, 360, 28, "ZoFontGameBold")
    table.insert(LvxJournal.archiveControls, LvxJournal.archiveTitle)
    local archiveLine = CreateDivider(win, 710, 142, 360)
    table.insert(LvxJournal.archiveControls, archiveLine)
    LvxJournal.archiveEmpty = CreateLabel(win, "", 710, 170, 370, 44, "ZoFontGame")
    table.insert(LvxJournal.archiveControls, LvxJournal.archiveEmpty)

    local archiveX, archiveY = 710, 170
    for i = 1, 8 do
        local y = archiveY + ((i - 1) * 52)

        local bg = wm:CreateControl(nil, win, CT_BACKDROP)
        bg:SetAnchor(TOPLEFT, win, TOPLEFT, archiveX, y)
        bg:SetDimensions(365, 42)
        bg:SetCenterColor(0.50, 0.34, 0.14, 0.13)
        bg:SetEdgeColor(0.22, 0.12, 0.04, 0.34)
        bg:SetEdgeTexture("", 1, 1, 1)
        bg:SetMouseEnabled(true)

        local row = { bg = bg }
        row.title = CreateLabel(win, "", archiveX + 10, y + 4, 330, 20, "ZoFontGame")
        row.sub = CreateLabel(win, "", archiveX + 10, y + 23, 330, 17, "ZoFontGameSmall")

        -- Click catcher: labels/backdrops can sit above each other in ESO UI and block clicks.
        -- This transparent button makes the whole archive row reliably clickable.
        row.button = wm:CreateControl(nil, win, CT_BUTTON)
        row.button:SetAnchor(TOPLEFT, win, TOPLEFT, archiveX, y)
        row.button:SetDimensions(365, 42)
        row.button:SetText("")
        row.button:SetHandler("OnClicked", function()
            if row.realIndex then LvxJournal.SelectEntry(row.realIndex) end
        end)
        row.button:SetHandler("OnMouseEnter", function()
            if row.realIndex then bg:SetCenterColor(0.70, 0.30, 0.08, 0.20) end
        end)
        row.button:SetHandler("OnMouseExit", function()
            bg:SetCenterColor(0.50, 0.34, 0.14, 0.13)
        end)

        table.insert(LvxJournal.archiveRows, row)
    end

    LvxJournal.statsControls = {}
    LvxJournal.statsTitle = CreateLabel(win, "Stats Page", 710, 108, 360, 28, "ZoFontGameBold")
    table.insert(LvxJournal.statsControls, LvxJournal.statsTitle)
    local statsLine = CreateDivider(win, 710, 142, 360)
    table.insert(LvxJournal.statsControls, statsLine)
    LvxJournal.statsText = CreateLabel(win, "", 710, 168, 370, 400, "ZoFontGame")
    table.insert(LvxJournal.statsControls, LvxJournal.statsText)
    LvxJournal.statsPrevButton = CreateButton(win, "Prev", 710, 596, 58, 24, function() LvxJournal.PrevStatsPage() end)
    LvxJournal.statsNextButton = CreateButton(win, "Next", 776, 596, 58, 24, function() LvxJournal.NextStatsPage() end)
    table.insert(LvxJournal.statsControls, LvxJournal.statsPrevButton)
    table.insert(LvxJournal.statsControls, LvxJournal.statsNextButton)
    LvxJournal.statsFooterLabel = CreateLabel(win, "", 845, 598, 245, 24, "ZoFontGameSmall")
    table.insert(LvxJournal.statsControls, LvxJournal.statsFooterLabel)
    local statsHelpLabel = CreateLabel(win, "Unsupported API stats show as Unknown.", 710, 635, 385, 24, "ZoFontGameSmall")
    table.insert(LvxJournal.statsControls, statsHelpLabel)

    LvxJournal.codexControls = {}
    LvxJournal.codexTitle = CreateLabel(win, "Codex Page", 710, 108, 360, 28, "ZoFontGameBold")
    table.insert(LvxJournal.codexControls, LvxJournal.codexTitle)
    local codexLine = CreateDivider(win, 710, 142, 360)
    table.insert(LvxJournal.codexControls, codexLine)
    LvxJournal.codexText = CreateLabel(win, "", 710, 168, 385, 410, "ZoFontGame")
    table.insert(LvxJournal.codexControls, LvxJournal.codexText)
    LvxJournal.codexPrevButton = CreateButton(win, "Prev", 710, 596, 58, 24, function() LvxJournal.PrevCodexPage() end)
    LvxJournal.codexNextButton = CreateButton(win, "Next", 776, 596, 58, 24, function() LvxJournal.NextCodexPage() end)
    table.insert(LvxJournal.codexControls, LvxJournal.codexPrevButton)
    table.insert(LvxJournal.codexControls, LvxJournal.codexNextButton)
    LvxJournal.codexFooterLabel = CreateLabel(win, "", 845, 598, 245, 24, "ZoFontGameSmall")
    table.insert(LvxJournal.codexControls, LvxJournal.codexFooterLabel)
    local codexHelpLabel = CreateLabel(win, "Read-only crafting codex.", 710, 635, 385, 24, "ZoFontGameSmall")
    table.insert(LvxJournal.codexControls, codexHelpLabel)

    LvxJournal.searchControls = {}
    LvxJournal.searchRows = {}
    LvxJournal.searchTitle = CreateLabel(win, "Search Journal / Codex", 710, 108, 360, 28, "ZoFontGameBold")
    table.insert(LvxJournal.searchControls, LvxJournal.searchTitle)
    local searchLine = CreateDivider(win, 710, 142, 360)
    table.insert(LvxJournal.searchControls, searchLine)

    LvxJournal.searchBackdrop = wm:CreateControl(nil, win, CT_BACKDROP)
    LvxJournal.searchBackdrop:SetAnchor(TOPLEFT, win, TOPLEFT, 706, 151)
    LvxJournal.searchBackdrop:SetDimensions(226, 38)
    LvxJournal.searchBackdrop:SetCenterColor(0.96, 0.90, 0.74, 0.72)
    LvxJournal.searchBackdrop:SetEdgeColor(0.42, 0.25, 0.08, 0.95)
    LvxJournal.searchBackdrop:SetEdgeTexture("", 1, 1, 2)
    LvxJournal.searchBackdrop:SetMouseEnabled(false)
    table.insert(LvxJournal.searchControls, LvxJournal.searchBackdrop)

    LvxJournal.searchBox = wm:CreateControl(nil, win, CT_EDITBOX)
    LvxJournal.searchBox:SetAnchor(TOPLEFT, win, TOPLEFT, 710, 155)
    LvxJournal.searchBox:SetDimensions(218, 30)
    LvxJournal.searchBox:SetMaxInputChars(80)
    LvxJournal.searchBox:SetFont("ZoFontGame")
    LvxJournal.searchBox:SetColor(0.10, 0.045, 0.012, 1)
    LvxJournal.searchBox:SetMouseEnabled(true)
    if LvxJournal.searchBox.SetTextInsets then LvxJournal.searchBox:SetTextInsets(4, 4, 0, 0) end
    LvxJournal.searchBox:SetHandler("OnMouseUp", function(self) if self and self.TakeFocus then self:TakeFocus() end end)
    LvxJournal.searchBox:SetHandler("OnEnter", function() LvxJournal.RunSearch() end)
    table.insert(LvxJournal.searchControls, LvxJournal.searchBox)

    LvxJournal.searchGoButton = CreateButton(win, "Go", 936, 158, 36, 24, function() LvxJournal.RunSearch() end)
    LvxJournal.searchScopeButton = CreateButton(win, "All", 978, 158, 58, 24, function() LvxJournal.CycleSearchScope() end)
    LvxJournal.searchCloseButton = CreateButton(win, "X", 1044, 158, 28, 24, function() LvxJournal.CloseSearch() end)
    table.insert(LvxJournal.searchControls, LvxJournal.searchGoButton)
    table.insert(LvxJournal.searchControls, LvxJournal.searchScopeButton)
    table.insert(LvxJournal.searchControls, LvxJournal.searchCloseButton)

    LvxJournal.searchEmpty = CreateLabel(win, "", 710, 198, 370, 44, "ZoFontGame")
    table.insert(LvxJournal.searchControls, LvxJournal.searchEmpty)

    local searchX, searchY = 710, 198
    for i = 1, 8 do
        local y = searchY + ((i - 1) * 48)
        local bg = wm:CreateControl(nil, win, CT_BACKDROP)
        bg:SetAnchor(TOPLEFT, win, TOPLEFT, searchX, y)
        bg:SetDimensions(365, 39)
        bg:SetCenterColor(0.50, 0.34, 0.14, 0.13)
        bg:SetEdgeColor(0.22, 0.12, 0.04, 0.34)
        bg:SetEdgeTexture("", 1, 1, 1)
        bg:SetMouseEnabled(true)

        local row = { bg = bg }
        row.title = CreateLabel(win, "", searchX + 10, y + 3, 338, 18, "ZoFontGame")
        row.sub = CreateLabel(win, "", searchX + 10, y + 21, 338, 16, "ZoFontGameSmall")

        row.button = wm:CreateControl(nil, win, CT_BUTTON)
        row.button:SetAnchor(TOPLEFT, win, TOPLEFT, searchX, y)
        row.button:SetDimensions(365, 39)
        row.button:SetText("")
        row.button:SetHandler("OnClicked", function()
            if row.result then LvxJournal.OpenSearchResult(row.result) end
        end)
        row.button:SetHandler("OnMouseEnter", function()
            if row.result then bg:SetCenterColor(0.70, 0.30, 0.08, 0.20) end
        end)
        row.button:SetHandler("OnMouseExit", function()
            bg:SetCenterColor(0.50, 0.34, 0.14, 0.13)
        end)

        table.insert(LvxJournal.searchRows, row)
    end

    LvxJournal.searchFooterLabel = CreateLabel(win, "", 710, 598, 260, 24, "ZoFontGameSmall")
    LvxJournal.searchPrevButton = CreateButton(win, "Prev", 970, 596, 48, 24, function() LvxJournal.PrevSearchPage() end)
    LvxJournal.searchNextButton = CreateButton(win, "Next", 1024, 596, 48, 24, function() LvxJournal.NextSearchPage() end)
    table.insert(LvxJournal.searchControls, LvxJournal.searchFooterLabel)
    table.insert(LvxJournal.searchControls, LvxJournal.searchPrevButton)
    table.insert(LvxJournal.searchControls, LvxJournal.searchNextButton)

    local searchHelpLabel = CreateLabel(win, "Find searches journal entries, map markers, locations, Codex, Profile, and Stats.", 710, 635, 385, 24, "ZoFontGameSmall")
    table.insert(LvxJournal.searchControls, searchHelpLabel)

    LvxJournal.templateControls = {}
    LvxJournal.templateTitle = CreateLabel(win, "New Entry Template", 710, 108, 360, 28, "ZoFontGameBold")
    table.insert(LvxJournal.templateControls, LvxJournal.templateTitle)
    local templateLine = CreateDivider(win, 710, 142, 360)
    table.insert(LvxJournal.templateControls, templateLine)
    local templateHelp = CreateLabel(win, "Choose how you want this new entry to start.", 710, 160, 370, 30, "ZoFontGame")
    table.insert(LvxJournal.templateControls, templateHelp)
    local templateX, templateY = 710, 202
    for i = 1, #entryTemplates do
        local template = entryTemplates[i]
        local y = templateY + ((i - 1) * 48)
        local btn = CreateButton(win, template.name, templateX, y, 250, 28, function() LvxJournal.CreateEntryFromTemplate(template.key) end)
        table.insert(LvxJournal.templateControls, btn)
    end
    local cancelTemplate = CreateButton(win, "Cancel", 970, 596, 70, 24, function() LvxJournal.ShowArchive() end)
    table.insert(LvxJournal.templateControls, cancelTemplate)
    local templateFooter = CreateLabel(win, "Templates pre-fill the page. You can edit everything after creation.", 710, 635, 385, 24, "ZoFontGameSmall")
    table.insert(LvxJournal.templateControls, templateFooter)

    LvxJournal.profileControls = {}
    LvxJournal.profileTitle = CreateLabel(win, "Character Profile", 710, 108, 360, 28, "ZoFontGameBold")
    table.insert(LvxJournal.profileControls, LvxJournal.profileTitle)
    local profileLine = CreateDivider(win, 710, 142, 360)
    table.insert(LvxJournal.profileControls, profileLine)
    local function CreateProfileBox(labelText, x, y, w, h, multi)
        local label = CreateLabel(win, labelText, x, y, w, 18, "ZoFontGameSmall")
        table.insert(LvxJournal.profileControls, label)
        local controlName = "LvxJournalProfile" .. string.gsub(labelText or "Field", "%W", "") .. "Edit"
        local box = wm:CreateControlFromVirtual(controlName, win, multi and "ZO_DefaultEditMultiLineForBackdrop" or "ZO_DefaultEditForBackdrop")
        box:SetAnchor(TOPLEFT, win, TOPLEFT, x, y + 18)
        box:SetDimensions(w, h)
        box:SetMaxInputChars(multi and 1000 or 120)
        box:SetFont("ZoFontBookPaper")
        box:SetColor(0.10, 0.045, 0.012, 1)
        if multi and box.SetNewLineEnabled then box:SetNewLineEnabled(true) end
        if multi and box.SetMultiLine then box:SetMultiLine(true) end
        table.insert(LvxJournal.profileControls, box)
        return box
    end
    LvxJournal.profileNameBox = CreateProfileBox("Name", 710, 158, 170, 28, false)
    LvxJournal.profileRaceBox = CreateProfileBox("Race", 900, 158, 170, 28, false)
    LvxJournal.profileClassBox = CreateProfileBox("Class", 710, 212, 170, 28, false)
    LvxJournal.profileAllianceBox = CreateProfileBox("Alliance", 900, 212, 170, 28, false)
    LvxJournal.profileBirthplaceBox = CreateProfileBox("Birthplace", 710, 266, 360, 28, false)
    LvxJournal.profilePersonalityBox = CreateProfileBox("Personality", 710, 320, 170, 58, true)
    LvxJournal.profileGoalsBox = CreateProfileBox("Goals", 900, 320, 170, 58, true)
    LvxJournal.profileCompanionsBox = CreateProfileBox("Companions", 710, 416, 170, 58, true)
    LvxJournal.profileEnemiesBox = CreateProfileBox("Enemies", 900, 416, 170, 58, true)
    LvxJournal.profileBackstoryBox = CreateProfileBox("Backstory", 710, 512, 360, 74, true)
    local profileSave = CreateButton(win, "Save", 710, 596, 58, 24, function() LvxJournal.SaveCurrentEntry() end)
    table.insert(LvxJournal.profileControls, profileSave)
    local profileFooter = CreateLabel(win, "", 780, 598, 300, 24, "ZoFontGameSmall")
    table.insert(LvxJournal.profileControls, profileFooter)

    LvxJournal.optionsControls = {}
    LvxJournal.themeRows = {}
    LvxJournal.optionsTitle = CreateLabel(win, "Options", 710, 108, 360, 28, "ZoFontGameBold")
    table.insert(LvxJournal.optionsControls, LvxJournal.optionsTitle)
    local optionsLine = CreateDivider(win, 710, 142, 360)
    table.insert(LvxJournal.optionsControls, optionsLine)
    LvxJournal.optionsThemesButton = CreateButton(win, "Themes", 760, 204, 210, 28, function()
        LvxJournal.ShowOptionsPage("themes")
    end)
    table.insert(LvxJournal.optionsControls, LvxJournal.optionsThemesButton)
    LvxJournal.optionsCommandsButton = CreateButton(win, "Commands", 760, 242, 210, 28, function()
        LvxJournal.ShowOptionsPage("commands")
    end)
    table.insert(LvxJournal.optionsControls, LvxJournal.optionsCommandsButton)
    LvxJournal.optionsMapPinsButton = CreateButton(win, "Map Pins", 760, 280, 210, 28, function()
        LvxJournal.ShowOptionsPage("mappins")
    end)
    table.insert(LvxJournal.optionsControls, LvxJournal.optionsMapPinsButton)
    LvxJournal.optionsControlsButton = CreateButton(win, "Controls", 760, 318, 210, 28, function()
        LvxJournal.ShowOptionsPage("controls")
    end)
    table.insert(LvxJournal.optionsControls, LvxJournal.optionsControlsButton)
    LvxJournal.optionsMaintenanceButton = CreateButton(win, "Maintenance", 760, 356, 210, 28, function()
        LvxJournal.ShowOptionsPage("maintenance")
    end)
    table.insert(LvxJournal.optionsControls, LvxJournal.optionsMaintenanceButton)
    LvxJournal.optionsBackButton = CreateButton(win, "Back", 710, 168, 72, 24, function()
        LvxJournal.ShowOptionsPage("main")
    end)
    table.insert(LvxJournal.optionsControls, LvxJournal.optionsBackButton)

    LvxJournal.themeCurrentLabel = CreateLabel(win, "Current Theme:", 710, 204, 365, 24, "ZoFontGame")
    table.insert(LvxJournal.optionsControls, LvxJournal.themeCurrentLabel)
    local themeHelp = CreateLabel(win, "Choose a journal background theme.", 710, 232, 380, 44, "ZoFontGameSmall")
    LvxJournal.themeHelpLabel = themeHelp
    table.insert(LvxJournal.optionsControls, themeHelp)

    local themeX, themeY = 710, 280
    for i = 1, #journalThemes do
        local theme = journalThemes[i]
        local y = themeY + ((i - 1) * 46)
        local btn = CreateButton(win, theme.name, themeX, y, 230, 28, function() LvxJournal.SetTheme(theme.key) end)
        table.insert(LvxJournal.optionsControls, btn)
        table.insert(LvxJournal.themeRows, { theme = theme, button = btn })
    end

    LvxJournal.nextThemeButton = CreateButton(win, "Next Theme", 950, 280, 105, 28, function() LvxJournal.NextTheme() end)
    table.insert(LvxJournal.optionsControls, LvxJournal.nextThemeButton)
    LvxJournal.themeNoteLabel = CreateLabel(win, "", 710, 550, 365, 54, "ZoFontGameSmall")
    table.insert(LvxJournal.optionsControls, LvxJournal.themeNoteLabel)

    LvxJournal.commandsTitleLabel = CreateLabel(win, "Commands / Map Pins", 710, 204, 365, 24, "ZoFontGame")
    table.insert(LvxJournal.optionsControls, LvxJournal.commandsTitleLabel)
    LvxJournal.commandsHelpLabel = CreateLabel(win, "", 710, 232, 385, 370, "ZoFontGameSmall")
    table.insert(LvxJournal.optionsControls, LvxJournal.commandsHelpLabel)
    LvxJournal.mapPinsOptionsTitle = CreateLabel(win, "", 710, 204, 365, 24, "ZoFontGame")
    table.insert(LvxJournal.optionsControls, LvxJournal.mapPinsOptionsTitle)
    LvxJournal.mapPinsToggleButton = CreateButton(win, "Toggle Map Pins", 760, 222, 205, 28, function() LvxJournal.ToggleMapPinsVisible() end)
    table.insert(LvxJournal.optionsControls, LvxJournal.mapPinsToggleButton)
    LvxJournal.autoPinEntriesButton = CreateButton(win, "Auto Pin Entries", 760, 268, 205, 28, function() LvxJournal.ToggleAutoPinJournalEntries() end)
    table.insert(LvxJournal.optionsControls, LvxJournal.autoPinEntriesButton)
    LvxJournal.mapPinFallbackButton = CreateButton(win, "Fallback Only", 760, 314, 205, 28, function() LvxJournal.ToggleBuiltInMapPinFallback() end)
    table.insert(LvxJournal.optionsControls, LvxJournal.mapPinFallbackButton)
    LvxJournal.mapPinsIconButton = CreateButton(win, "Change Pin Icon", 760, 360, 205, 28, function() LvxJournal.NextMapMarkIcon() end)
    table.insert(LvxJournal.optionsControls, LvxJournal.mapPinsIconButton)
    LvxJournal.mapPinNamesButton = CreateButton(win, "Pin Names", 760, 396, 205, 28, function() LvxJournal.ToggleMapPinNames() end)
    table.insert(LvxJournal.optionsControls, LvxJournal.mapPinNamesButton)
    LvxJournal.pinTitleNamesButton = CreateButton(win, "Use Journal Titles", 760, 432, 205, 28, function() LvxJournal.ToggleUseJournalTitleForPinName() end)
    table.insert(LvxJournal.optionsControls, LvxJournal.pinTitleNamesButton)
    LvxJournal.mapPinsOptionsText = CreateLabel(win, "", 710, 470, 385, 145, "ZoFontGameSmall")
    table.insert(LvxJournal.optionsControls, LvxJournal.mapPinsOptionsText)

    LvxJournal.controlsOptionsTitle = CreateLabel(win, "Control Options", 710, 204, 365, 24, "ZoFontGame")
    table.insert(LvxJournal.optionsControls, LvxJournal.controlsOptionsTitle)
    LvxJournal.autoMouseFocusButton = CreateButton(win, "Auto Mouse Focus", 760, 246, 205, 28, function() LvxJournal.ToggleAutoFocusMouse() end)
    table.insert(LvxJournal.optionsControls, LvxJournal.autoMouseFocusButton)
    LvxJournal.controlsOptionsText = CreateLabel(win, "", 710, 296, 385, 240, "ZoFontGameSmall")
    table.insert(LvxJournal.optionsControls, LvxJournal.controlsOptionsText)

    LvxJournal.optionsMainTitle = CreateLabel(win, "Choose an options section.", 710, 168, 385, 24, "ZoFontGame")
    table.insert(LvxJournal.optionsControls, LvxJournal.optionsMainTitle)
    LvxJournal.optionsMainHelp = CreateLabel(win, "Settings are grouped into pages so the journal can support more options without crowding this page.", 710, 402, 385, 90, "ZoFontGameSmall")
    table.insert(LvxJournal.optionsControls, LvxJournal.optionsMainHelp)

    LvxJournal.maintenanceTitleLabel = CreateLabel(win, "Maintenance", 710, 204, 365, 24, "ZoFontGame")
    table.insert(LvxJournal.optionsControls, LvxJournal.maintenanceTitleLabel)
    LvxJournal.questTrackingButton = CreateButton(win, "Quest Tracking", 760, 246, 210, 28, function() LvxJournal.ToggleQuestTracking() end)
    table.insert(LvxJournal.optionsControls, LvxJournal.questTrackingButton)
    LvxJournal.achievementTrackingButton = CreateButton(win, "Achievement Tracking", 760, 284, 210, 28, function() LvxJournal.ToggleAchievementTracking() end)
    table.insert(LvxJournal.optionsControls, LvxJournal.achievementTrackingButton)
    LvxJournal.tributeTrackingButton = CreateButton(win, "Tribute Tracking", 760, 322, 210, 28, function() LvxJournal.ToggleTributeTrackingLog() end)
    table.insert(LvxJournal.optionsControls, LvxJournal.tributeTrackingButton)
    LvxJournal.deleteAllEntriesButton = CreateButton(win, "Delete All Entries", 760, 388, 210, 28, function() LvxJournal.ConfirmDeleteAllJournalEntries() end)
    table.insert(LvxJournal.optionsControls, LvxJournal.deleteAllEntriesButton)
    LvxJournal.maintenanceHelpLabel = CreateLabel(win, "Tracking toggles control automatic journal entries for noisy systems. Delete All clears every journal entry and linked map pin.", 710, 432, 385, 120, "ZoFontGameSmall")
    table.insert(LvxJournal.optionsControls, LvxJournal.maintenanceHelpLabel)

    LvxJournal.helpOptionsTitle = CreateLabel(win, "Help Options", 710, 204, 365, 24, "ZoFontGame")
    table.insert(LvxJournal.optionsControls, LvxJournal.helpOptionsTitle)
    LvxJournal.helpTooltipsButton = CreateButton(win, "Hover Help: ON", 710, 242, 210, 28, function() LvxJournal.ToggleHelpTooltips() end)
    table.insert(LvxJournal.optionsControls, LvxJournal.helpTooltipsButton)
    LvxJournal.helpOptionsText = CreateLabel(win, "", 710, 292, 385, 300, "ZoFontGameSmall")
    table.insert(LvxJournal.optionsControls, LvxJournal.helpOptionsText)

    local optionsFooter = CreateLabel(win, "", 710, 635, 385, 24, "ZoFontGameSmall")
    table.insert(LvxJournal.optionsControls, optionsFooter)

    LvxJournal.toolsControls = {}
    LvxJournal.toolsTitle = CreateLabel(win, "Tools", 710, 108, 360, 28, "ZoFontGameBold")
    table.insert(LvxJournal.toolsControls, LvxJournal.toolsTitle)
    local toolsLine = CreateDivider(win, 710, 142, 360)
    table.insert(LvxJournal.toolsControls, toolsLine)
    LvxJournal.toolsIcon = wm:CreateControl(nil, win, CT_TEXTURE)
    LvxJournal.toolsIcon:SetAnchor(TOPLEFT, win, TOPLEFT, 710, 165)
    LvxJournal.toolsIcon:SetDimensions(128, 128)
    LvxJournal.toolsIcon:SetTexture("LvxJournal/ui/tools/oracle_bubble.dds")
    table.insert(LvxJournal.toolsControls, LvxJournal.toolsIcon)
    LvxJournal.toolsResultLabel = CreateLabel(win, "Choose a tool from the left, then roll or export.", 855, 172, 230, 280, "ZoFontBookPaper")
    table.insert(LvxJournal.toolsControls, LvxJournal.toolsResultLabel)

    LvxJournal.mapMarkNameLabel = CreateLabel(win, "Mark Name", 710, 444, 90, 20, "ZoFontGameSmall")
    SetJournalTooltip(LvxJournal.mapMarkNameLabel, GetJournalTooltipText("Mark Name"))
    table.insert(LvxJournal.toolsControls, LvxJournal.mapMarkNameLabel)

    LvxJournal.mapMarkNameBackdrop = wm:CreateControl(nil, win, CT_BACKDROP)
    LvxJournal.mapMarkNameBackdrop:SetAnchor(TOPLEFT, win, TOPLEFT, 786, 434)
    LvxJournal.mapMarkNameBackdrop:SetDimensions(228, 38)
    LvxJournal.mapMarkNameBackdrop:SetCenterColor(0.96, 0.90, 0.74, 0.72)
    LvxJournal.mapMarkNameBackdrop:SetEdgeColor(0.42, 0.25, 0.08, 0.95)
    LvxJournal.mapMarkNameBackdrop:SetEdgeTexture("", 1, 1, 2)
    LvxJournal.mapMarkNameBackdrop:SetMouseEnabled(false)
    SetJournalTooltip(LvxJournal.mapMarkNameBackdrop, GetJournalTooltipText("Mark Name"))
    table.insert(LvxJournal.toolsControls, LvxJournal.mapMarkNameBackdrop)

    LvxJournal.mapMarkNameBox = wm:CreateControl("LvxJournalMapMarkNameEdit", win, CT_EDITBOX)
    LvxJournal.mapMarkNameBox:SetAnchor(TOPLEFT, win, TOPLEFT, 790, 438)
    LvxJournal.mapMarkNameBox:SetDimensions(220, 30)
    LvxJournal.mapMarkNameBox:SetMaxInputChars(40)
    LvxJournal.mapMarkNameBox:SetFont("ZoFontGame")
    LvxJournal.mapMarkNameBox:SetColor(0.10, 0.045, 0.012, 1)
    LvxJournal.mapMarkNameBox:SetMouseEnabled(true)
    if LvxJournal.mapMarkNameBox.SetTextInsets then LvxJournal.mapMarkNameBox:SetTextInsets(4, 4, 0, 0) end
    LvxJournal.mapMarkNameBox:SetHandler("OnMouseUp", function(control)
        if control and control.TakeFocus then control:TakeFocus() end
        if control and control.SetCursorPosition and control.GetText then control:SetCursorPosition(string.len(control:GetText() or "")) end
    end)
    LvxJournal.mapMarkNameBox:SetHandler("OnTextChanged", function()
        if LvxJournal.suppressMapMarkNameChange then return end
        if LvxJournal.LiveUpdateShownMapMarkName then
            LvxJournal.LiveUpdateShownMapMarkName()
        end
    end)
    LvxJournal.mapMarkNameBox:SetHandler("OnEnter", function()
        if LvxJournal.UpdateShownMapMarkName then
            LvxJournal.UpdateShownMapMarkName(true)
        end
    end)
    SetJournalTooltip(LvxJournal.mapMarkNameBox, GetJournalTooltipText("Mark Name"))
    table.insert(LvxJournal.toolsControls, LvxJournal.mapMarkNameBox)

    LvxJournal.mapMarkNameHelp = CreateLabel(win, "Typing renames live", 790, 468, 240, 18, "ZoFontGameSmall")
    LvxJournal.mapMarkNameHelp:SetColor(0.32, 0.20, 0.08, 0.92)
    SetJournalTooltip(LvxJournal.mapMarkNameHelp, GetJournalTooltipText("Mark Name"))
    table.insert(LvxJournal.toolsControls, LvxJournal.mapMarkNameHelp)

    LvxJournal.toolButtons = {}
    local toolX, toolY = 710, 320
    local function AddToolButton(text, y, callback)
        local btn = CreateButton(win, text, toolX, y, 170, 28, callback)
        table.insert(LvxJournal.toolsControls, btn)
        table.insert(LvxJournal.toolButtons, btn)
        return btn
    end
    for i = 1, 10 do
        LvxJournal["toolButton" .. i] = AddToolButton("", toolY + ((i - 1) * 31), function() end)
    end
    LvxJournal.toolsFooter = CreateLabel(win, "Exports write to SavedVariables after /reloadui, logout, or exit.", 710, 635, 385, 24, "ZoFontGameSmall")
    table.insert(LvxJournal.toolsControls, LvxJournal.toolsFooter)

    LvxJournal.footerLabel = CreateLabel(win, "", 710, 598, 260, 24, "ZoFontGameSmall")
    table.insert(LvxJournal.archiveControls, LvxJournal.footerLabel)

    LvxJournal.prevPageButton = CreateButton(win, "Prev", 970, 596, 48, 24, function() LvxJournal.PrevArchivePage() end)
    LvxJournal.nextPageButton = CreateButton(win, "Next", 1024, 596, 48, 24, function() LvxJournal.NextArchivePage() end)
    table.insert(LvxJournal.archiveControls, LvxJournal.prevPageButton)
    table.insert(LvxJournal.archiveControls, LvxJournal.nextPageButton)

    LvxJournal.readTitle = CreateLabel(win, "Read Entry", 710, 108, 365, 32, "ZoFontGameBold")
    table.insert(LvxJournal.readControls, LvxJournal.readTitle)
    local readLine = CreateDivider(win, 710, 148, 360)
    table.insert(LvxJournal.readControls, readLine)
    LvxJournal.readMeta = CreateLabel(win, "", 710, 164, 385, 44, "ZoFontGameSmall")
    table.insert(LvxJournal.readControls, LvxJournal.readMeta)
    LvxJournal.readBody = CreateLabel(win, "", 710, 222, 385, 320, "ZoFontBookPaper")
    table.insert(LvxJournal.readControls, LvxJournal.readBody)
    LvxJournal.readEditButton = CreateButton(win, "Edit", 710, 596, 54, 24, function() LvxJournal.EditSelectedEntry() end)
    table.insert(LvxJournal.readControls, LvxJournal.readEditButton)
    LvxJournal.readPrevButton = CreateButton(win, "Prev", 770, 596, 52, 24, function() LvxJournal.SelectRelativeEntry(-1) end)
    table.insert(LvxJournal.readControls, LvxJournal.readPrevButton)
    LvxJournal.readNextButton = CreateButton(win, "Next", 828, 596, 52, 24, function() LvxJournal.SelectRelativeEntry(1) end)
    table.insert(LvxJournal.readControls, LvxJournal.readNextButton)
    LvxJournal.readBookButton = CreateButton(win, "Book", 886, 596, 58, 24, function() LvxJournal.ToggleFavorite() end)
    table.insert(LvxJournal.readControls, LvxJournal.readBookButton)
    LvxJournal.readArchiveButton = CreateButton(win, "Archive", 950, 596, 72, 24, function() LvxJournal.ShowArchive() end)
    table.insert(LvxJournal.readControls, LvxJournal.readArchiveButton)
    LvxJournal.readZoomPinButton = CreateButton(win, "Zoom Pin", 1028, 596, 76, 24, function() LvxJournal.ZoomToSelectedEntryMapMark() end)
    table.insert(LvxJournal.readControls, LvxJournal.readZoomPinButton)
    LvxJournal.readFooter = CreateLabel(win, "Read Mode. Edit, zoom to pins, or flip entries.", 710, 635, 385, 24, "ZoFontGameSmall")
    table.insert(LvxJournal.readControls, LvxJournal.readFooter)

    local titleLabel = CreateLabel(win, "TITLE", 710, 105, 100, 22, "ZoFontGameSmall")
    table.insert(LvxJournal.editorControls, titleLabel)

    local titleBackdrop = wm:CreateControl(nil, win, CT_BACKDROP)
    titleBackdrop:SetAnchor(TOPLEFT, win, TOPLEFT, 706, 126)
    titleBackdrop:SetDimensions(368, 42)
    titleBackdrop:SetCenterColor(0.96, 0.90, 0.74, 0.72)
    titleBackdrop:SetEdgeColor(0.42, 0.25, 0.08, 0.95)
    titleBackdrop:SetEdgeTexture("", 1, 1, 2)
    titleBackdrop:SetMouseEnabled(false)
    table.insert(LvxJournal.editorControls, titleBackdrop)

    local titleBox = wm:CreateControl("LvxJournalTitleEdit", win, CT_EDITBOX)
    titleBox:SetAnchor(TOPLEFT, win, TOPLEFT, 710, 130)
    titleBox:SetDimensions(360, 34)
    titleBox:SetMaxInputChars(120)
    titleBox:SetFont("ZoFontBookPaper")
    titleBox:SetColor(0.10, 0.045, 0.012, 1)
    titleBox:SetMouseEnabled(true)
    titleBox:SetHandler("OnMouseUp", function(control) if control and control.TakeFocus then control:TakeFocus() end end)
    LvxJournal.titleBox = titleBox
    table.insert(LvxJournal.editorControls, titleBox)

    local editorLine = CreateDivider(win, 710, 174, 360)
    table.insert(LvxJournal.editorControls, editorLine)
    LvxJournal.metaLabel = CreateLabel(win, "", 710, 192, 390, 74, "ZoFontGameSmall")
    table.insert(LvxJournal.editorControls, LvxJournal.metaLabel)

    local entryLabel = CreateLabel(win, "ENTRY", 710, 322, 100, 24, "ZoFontGameBold")
    table.insert(LvxJournal.editorControls, entryLabel)

    local bodyBackdrop = wm:CreateControl(nil, win, CT_BACKDROP)
    bodyBackdrop:SetAnchor(TOPLEFT, win, TOPLEFT, 706, 350)
    bodyBackdrop:SetDimensions(BODY_SCROLL_VISIBLE_WIDTH + 8, BODY_SCROLL_VISIBLE_HEIGHT + 8)
    bodyBackdrop:SetCenterColor(0.96, 0.90, 0.74, 0.50)
    bodyBackdrop:SetEdgeColor(0.42, 0.25, 0.08, 0.95)
    bodyBackdrop:SetEdgeTexture("", 1, 1, 2)
    bodyBackdrop:SetMouseEnabled(false)
    table.insert(LvxJournal.editorControls, bodyBackdrop)

    -- Use a real multiline editor directly on the journal page.
    -- The previous clipped child control caused odd click/focus sensitivity.
    LvxJournal.bodyClip = nil

    local bodyBox = wm:CreateControl("LvxJournalBodyEdit", win, CT_EDITBOX)
    bodyBox:SetAnchor(TOPLEFT, win, TOPLEFT, 710, 354)
    bodyBox:SetDimensions(BODY_SCROLL_EDIT_WIDTH, BODY_SCROLL_VISIBLE_HEIGHT)
    bodyBox:SetMaxInputChars(8000)
    bodyBox:SetFont("ZoFontBookPaper")
    bodyBox:SetColor(0.10, 0.045, 0.012, 1)
    bodyBox:SetMouseEnabled(true)
    if bodyBox.SetTextInsets then bodyBox:SetTextInsets(4, 4, 4, 4) end
    if bodyBox.SetNewLineEnabled then bodyBox:SetNewLineEnabled(true) end
    if bodyBox.SetMultiLine then bodyBox:SetMultiLine(true) end
    bodyBox:SetHandler("OnTextChanged", function() LvxJournal.OnBodyTextChanged() end)
    bodyBox:SetHandler("OnMouseWheel", function(control, delta) LvxJournal.ScrollBody(delta) end)
    bodyBox:SetHandler("OnMouseDown", function(control)
        if control and control.TakeFocus then control:TakeFocus() end
    end)
    LvxJournal.bodyBox = bodyBox
    table.insert(LvxJournal.editorControls, bodyBox)

    local bodyScrollBar = wm:CreateControl(nil, win, CT_BACKDROP)
    bodyScrollBar:SetAnchor(TOPLEFT, win, TOPLEFT, 1098, 354)
    bodyScrollBar:SetDimensions(5, BODY_SCROLL_VISIBLE_HEIGHT)
    bodyScrollBar:SetCenterColor(0.20, 0.12, 0.04, 0.22)
    bodyScrollBar:SetEdgeColor(0.20, 0.12, 0.04, 0.08)
    bodyScrollBar:SetEdgeTexture("", 1, 1, 1)
    bodyScrollBar:SetMouseEnabled(true)
    bodyScrollBar:SetHandler("OnMouseWheel", function(control, delta) LvxJournal.ScrollBody(delta) end)
    LvxJournal.bodyScrollBar = bodyScrollBar
    table.insert(LvxJournal.editorControls, bodyScrollBar)

    local bodyScrollThumb = wm:CreateControl(nil, bodyScrollBar, CT_BACKDROP)
    bodyScrollThumb:SetAnchor(TOPLEFT, bodyScrollBar, TOPLEFT, 0, 0)
    bodyScrollThumb:SetDimensions(5, 28)
    bodyScrollThumb:SetCenterColor(0.54, 0.32, 0.10, 0.72)
    bodyScrollThumb:SetEdgeColor(0.20, 0.12, 0.04, 0.20)
    bodyScrollThumb:SetEdgeTexture("", 1, 1, 1)
    bodyScrollThumb:SetMouseEnabled(false)
    LvxJournal.bodyScrollThumb = bodyScrollThumb
    table.insert(LvxJournal.editorControls, bodyScrollThumb)
    LvxJournal.SetBodyText("", false)

    local archiveHelpLabel = CreateLabel(win, "", 710, 635, 385, 24, "ZoFontGameSmall")
    table.insert(LvxJournal.archiveControls, archiveHelpLabel)

    local pinNameLabel = CreateLabel(win, "PIN NAME", 710, 278, 95, 22, "ZoFontGameSmall")
    table.insert(LvxJournal.editorControls, pinNameLabel)

    local pinNameBackdrop = wm:CreateControl(nil, win, CT_BACKDROP)
    pinNameBackdrop:SetAnchor(TOPLEFT, win, TOPLEFT, 786, 270)
    pinNameBackdrop:SetDimensions(228, 38)
    pinNameBackdrop:SetCenterColor(0.96, 0.90, 0.74, 0.72)
    pinNameBackdrop:SetEdgeColor(0.42, 0.25, 0.08, 0.95)
    pinNameBackdrop:SetEdgeTexture("", 1, 1, 2)
    pinNameBackdrop:SetMouseEnabled(false)
    table.insert(LvxJournal.editorControls, pinNameBackdrop)

    local pinNameBox = wm:CreateControl("LvxJournalPinNameEdit", win, CT_EDITBOX)
    pinNameBox:SetAnchor(TOPLEFT, win, TOPLEFT, 790, 274)
    pinNameBox:SetDimensions(220, 30)
    pinNameBox:SetMaxInputChars(40)
    pinNameBox:SetFont("ZoFontGame")
    pinNameBox:SetColor(0.10, 0.045, 0.012, 1)
    pinNameBox:SetMouseEnabled(true)
    pinNameBox:SetHandler("OnMouseUp", function(control) if control and control.TakeFocus then control:TakeFocus() end end)
    if pinNameBox.SetTextInsets then pinNameBox:SetTextInsets(4, 4, 0, 0) end
    pinNameBox:SetHandler("OnTextChanged", function()
        if LvxJournal.suppressPinNameChange then return end
        if LvxJournal.UpdateSelectedEntryPinName then
            LvxJournal.UpdateSelectedEntryPinName()
        end
    end)
    LvxJournal.pinNameBox = pinNameBox
    table.insert(LvxJournal.editorControls, pinNameBox)

    LvxJournal.editorPinToggleButton = CreateButton(win, "[ ]", 1018, 274, 40, 30, function()
        local hasMark = LvxJournal.SelectedEntryHasMapMark and LvxJournal.SelectedEntryHasMapMark()
        if LvxJournal.SetSelectedEntryMapMarkEnabled then
            LvxJournal.SetSelectedEntryMapMarkEnabled(not hasMark)
        else
            LvxJournal.ToggleSelectedEntryMapMark()
        end
        if LvxJournal.RefreshEditorMapButtons then LvxJournal.RefreshEditorMapButtons() end
    end, GetJournalTooltipText("Pin Toggle"))
    table.insert(LvxJournal.editorControls, LvxJournal.editorPinToggleButton)

    local pinNameHelp = CreateLabel(win, "Optional short name for the map pin.", 710, 306, 300, 20, "ZoFontGameSmall")
    table.insert(LvxJournal.editorControls, pinNameHelp)

    local editorReadButton = CreateButton(win, "Read", 710, 608, 58, 24, function() LvxJournal.ReturnToReadMode() end)
    table.insert(LvxJournal.editorControls, editorReadButton)

    LvxJournal.editorMapButton = CreateButton(win, "Add Pin", 775, 608, 86, 24, function()
        LvxJournal.ToggleSelectedEntryMapMark()
        if LvxJournal.RefreshEditorMapButtons then LvxJournal.RefreshEditorMapButtons() end
        if LvxJournal.HideToolsControlsHard then LvxJournal.HideToolsControlsHard() end
    end)
    table.insert(LvxJournal.editorControls, LvxJournal.editorMapButton)

    LvxJournal.editorMapIconButton = CreateButton(win, "Icon", 868, 608, 104, 24, function()
        LvxJournal.NextMapMarkIcon()
        if LvxJournal.RefreshEditorMapButtons then LvxJournal.RefreshEditorMapButtons() end
        if LvxJournal.savedVars and LvxJournal.savedVars.viewMode == "edit" and LvxJournal.HideToolsControlsHard then
            LvxJournal.HideToolsControlsHard()
        end
    end)
    table.insert(LvxJournal.editorControls, LvxJournal.editorMapIconButton)

    LvxJournal.editorZoomPinButton = CreateButton(win, "Zoom Pin", 978, 608, 78, 24, function()
        LvxJournal.ZoomToSelectedEntryMapMark()
        if LvxJournal.HideToolsControlsHard then LvxJournal.HideToolsControlsHard() end
    end)
    table.insert(LvxJournal.editorControls, LvxJournal.editorZoomPinButton)

    local editorHelpLabel = CreateLabel(win, "", 1062, 610, 40, 24, "ZoFontGameSmall")
    table.insert(LvxJournal.editorControls, editorHelpLabel)

    LvxJournal.window = win
    LvxJournal.RefreshAll()
end

function LvxJournal.ToggleWindow(forceState)
    LvxJournal.CreateWindow()

    local win = LvxJournal.window
    local show = forceState

    if show == nil then
        show = win:IsHidden()
    end

    if not show then
        LvxJournal.AutoSaveCurrentEntry(true)
        LvxJournal.AutoSaveProfile(true)
    end

    win:SetHidden(not show)

    if LvxJournal.ApplyMouseFocusForWindow then
        LvxJournal.ApplyMouseFocusForWindow(show == true)
    end

    if show then
        local state = LvxJournal.savedVars
        if state and state.entries and state.lastOpenedIndex and state.entries[state.lastOpenedIndex] and (state.viewMode == "archive" or state.viewMode == nil) then
            state.selectedIndex = state.lastOpenedIndex
            state.viewMode = "read"
        end
        LvxJournal.RefreshAll()
    else
    end
end

function LvxJournal_Toggle()
    LvxJournal.ToggleWindow()
end


local function CleanQuestText(value)
    value = tostring(value or "")
    value = value:gsub("%^.*$", "")
    value = value:gsub("\r\n", "\n")
    value = value:gsub("\r", "\n")
    value = value:gsub("^%s+", "")
    value = value:gsub("%s+$", "")
    return value
end

local function GetQuestJournalIndexByName(questName)
    questName = CleanQuestText(questName)
    if questName == "" or not GetNumJournalQuests or not GetJournalQuestInfo then
        return nil
    end

    local count = tonumber(SafeCall(GetNumJournalQuests)) or 0
    for i = 1, count do
        local name = CleanQuestText(SafeCall(GetJournalQuestInfo, i))
        if name == questName then
            return i
        end
    end

    return nil
end

local function QuestValueOrUnknown(value)
    value = CleanQuestText(value)
    if value == "" then return "Unknown" end
    return value
end

local function GetQuestTypeTextSafe(questType)
    if questType == nil then return "Unknown" end
    return tostring(questType)
end

local function GetQuestInstanceTextSafe(instanceDisplayType)
    if instanceDisplayType == nil then return "Unknown" end
    return tostring(instanceDisplayType)
end

local function GetQuestZoneTextSafe(journalIndex)
    if journalIndex and GetJournalQuestLocationInfo then
        local zoneName, objectiveName, zoneIndex, poiIndex = SafeCall(GetJournalQuestLocationInfo, journalIndex)
        zoneName = CleanQuestText(zoneName)
        objectiveName = CleanQuestText(objectiveName)
        if zoneName ~= "" and objectiveName ~= "" then
            return zoneName .. " / " .. objectiveName
        elseif zoneName ~= "" then
            return zoneName
        elseif objectiveName ~= "" then
            return objectiveName
        end
    end

    return GetLocationText()
end

local function AddQuestConditionLines(lines, journalIndex)
    if not journalIndex or not GetJournalQuestNumSteps or not GetJournalQuestNumConditions or not GetJournalQuestConditionInfo then
        return
    end

    local stepCount = tonumber(SafeCall(GetJournalQuestNumSteps, journalIndex)) or 0
    if stepCount <= 0 then return end

    local addedHeader = false
    for step = 1, stepCount do
        local conditionCount = tonumber(SafeCall(GetJournalQuestNumConditions, journalIndex, step)) or 0
        for condition = 1, conditionCount do
            local conditionText, current, max, isFailCondition, isComplete = SafeCall(GetJournalQuestConditionInfo, journalIndex, step, condition)
            conditionText = CleanQuestText(conditionText)

            if conditionText ~= "" then
                if not addedHeader then
                    lines[#lines + 1] = ""
                    lines[#lines + 1] = "Objectives:"
                    addedHeader = true
                end

                local progress = ""
                if tonumber(max) and tonumber(max) > 1 then
                    progress = " (" .. tostring(tonumber(current) or 0) .. "/" .. tostring(max) .. ")"
                end

                local state = ""
                if isComplete then
                    state = " [Complete]"
                elseif isFailCondition then
                    state = " [Fail Condition]"
                end

                lines[#lines + 1] = "- " .. conditionText .. progress .. state
            end
        end
    end
end

local function BuildQuestLogBody(statusText, questName)
    questName = QuestValueOrUnknown(questName)
    local journalIndex = GetQuestJournalIndexByName(questName)

    local info = {}
    if journalIndex and GetJournalQuestInfo then
        info = { SafeCall(GetJournalQuestInfo, journalIndex) }
    end

    local name = CleanQuestText(info[1])
    if name == "" then name = questName end

    local backgroundText = CleanQuestText(info[2])
    local activeStepText = CleanQuestText(info[3])
    local activeStepTrackerOverrideText = CleanQuestText(info[5])
    local completed = info[6]
    local tracked = info[7]
    local questLevel = info[8]
    local pushed = info[9]
    local questType = info[10]
    local instanceDisplayType = info[11]

    local lines = {}
    lines[#lines + 1] = "Quest " .. statusText
    lines[#lines + 1] = ""
    lines[#lines + 1] = "Name: " .. name
    lines[#lines + 1] = "Status: " .. statusText
    lines[#lines + 1] = "Location: " .. GetQuestZoneTextSafe(journalIndex)
    lines[#lines + 1] = "Time: " .. GetStampText()

    if journalIndex then
        lines[#lines + 1] = "Journal Index: " .. tostring(journalIndex)
    end

    if questLevel ~= nil then
        lines[#lines + 1] = "Quest Level: " .. tostring(questLevel)
    end

    if questType ~= nil then
        lines[#lines + 1] = "Quest Type: " .. GetQuestTypeTextSafe(questType)
    end

    if instanceDisplayType ~= nil then
        lines[#lines + 1] = "Instance Type: " .. GetQuestInstanceTextSafe(instanceDisplayType)
    end

    if tracked ~= nil then
        lines[#lines + 1] = "Tracked: " .. tostring(tracked)
    end

    if completed ~= nil then
        lines[#lines + 1] = "Completed Flag: " .. tostring(completed)
    end

    if pushed ~= nil then
        lines[#lines + 1] = "Shared / Pushed: " .. tostring(pushed)
    end

    if activeStepText ~= "" then
        lines[#lines + 1] = ""
        lines[#lines + 1] = "Current Step:"
        lines[#lines + 1] = activeStepText
    end

    if activeStepTrackerOverrideText ~= "" and activeStepTrackerOverrideText ~= activeStepText then
        lines[#lines + 1] = ""
        lines[#lines + 1] = "Tracker:"
        lines[#lines + 1] = activeStepTrackerOverrideText
    end

    AddQuestConditionLines(lines, journalIndex)

    if backgroundText ~= "" then
        lines[#lines + 1] = ""
        lines[#lines + 1] = "Quest Text:"
        lines[#lines + 1] = backgroundText
    end

    if not journalIndex then
        lines[#lines + 1] = ""
        lines[#lines + 1] = "Note: ESO did not expose this quest in the active journal when the event fired, so only event/location details were saved."
    end

    return table.concat(lines, "\n")
end


-- -----------------------------------------------------------------------------
-- ESO event logging hooks
-- -----------------------------------------------------------------------------
function LvxJournal.OnQuestComplete(eventCode, questName)
    local s = LvxJournal.savedVars
    local zone = GetLocationText()
    if s and zone ~= "" and zone ~= "Unknown Location" then
        s.knownZones = s.knownZones or {}
        if type(s.knownZones[zone]) ~= "table" then
            if s.knownZones[zone] == true then
                s.knownZones[zone] = {
                    first = "Previously recorded",
                    last = GetStampText(),
                    visits = 1,
                }
            else
                s.knownZones[zone] = {
                    first = GetStampText(),
                    last = GetStampText(),
                    visits = 1,
                }
            end
        end
        local zoneData = s.knownZones[zone]
        zoneData.questsCompleted = (tonumber(zoneData.questsCompleted) or 0) + 1
        zoneData.last = GetStampText()
        AttachZoneTravelStats(zoneData)
    end

    if not (LvxJournal.savedVars and LvxJournal.savedVars.trackQuestLog == true) then return end
    questName = QuestValueOrUnknown(questName)
    AddEntry("Completed: " .. questName, BuildQuestLogBody("Completed", questName), "Quest", "Completed", true)
end

function LvxJournal.OnQuestAdded(eventCode, questName)
    if not (LvxJournal.savedVars and LvxJournal.savedVars.trackQuestLog == true) then return end
    questName = QuestValueOrUnknown(questName)
    AddEntry("Started: " .. questName, BuildQuestLogBody("Started", questName), "Quest", "Started", true)
end

function LvxJournal.OnPlayerDead()
    if not LvxJournal.savedVars.autoDeath then return end
    AddEntry("Defeated in " .. GetLocationText(), "I fell in " .. GetLocationText() .. ".\n\nDeath recorded for " .. GetPlayerNameSafe() .. ".", "Death", "Death", true)
end


local function CleanTravelText(value)
    value = tostring(value or "")
    value = value:gsub("%^.*$", "")
    value = value:gsub("\r\n", "\n")
    value = value:gsub("\r", "\n")
    value = value:gsub("^%s+", "")
    value = value:gsub("%s+$", "")
    return value
end

local function GetMapNameTextSafe()
    local mapName = CleanTravelText(SafeCall(GetMapName))
    if mapName ~= "" then return mapName end
    return "Unknown"
end

local function GetZoneIdTextSafe()
    local zoneId = nil
    if GetUnitZoneIndex and GetZoneId then
        local zoneIndex = SafeCall(GetUnitZoneIndex, "player")
        if zoneIndex then
            zoneId = SafeCall(GetZoneId, zoneIndex)
        end
    end

    if not zoneId and GetUnitZoneId then
        zoneId = SafeCall(GetUnitZoneId, "player")
    end

    if zoneId then return tostring(zoneId) end
    return "Unknown"
end

local function GetSubZoneTextSafe()
    local subZone = CleanTravelText(SafeCall(GetPlayerActiveSubzoneName))
    if subZone ~= "" then return subZone end

    subZone = CleanTravelText(SafeCall(GetUnitZone, "player"))
    if subZone ~= "" then return subZone end

    return "Unknown"
end

local function GetTravelMapPositionTextSafe()
    if GetMapPlayerPosition then
        local x, y = SafeCall(GetMapPlayerPosition, "player")
        if x and y then
            return string.format("%.2f, %.2f", (tonumber(x) or 0) * 100, (tonumber(y) or 0) * 100)
        end
    end
    return "Unknown"
end

local function GetTravelWorldPositionTextSafe()
    if GetUnitWorldPosition then
        local zoneId, worldX, worldY, worldZ = SafeCall(GetUnitWorldPosition, "player")
        if worldX and worldY and worldZ then
            return tostring(math.floor(worldX)) .. ", " .. tostring(math.floor(worldY)) .. ", " .. tostring(math.floor(worldZ))
        end
    end

    if GetUnitRawWorldPosition then
        local zoneId, worldX, worldY, worldZ = SafeCall(GetUnitRawWorldPosition, "player")
        if worldX and worldY and worldZ then
            return tostring(math.floor(worldX)) .. ", " .. tostring(math.floor(worldY)) .. ", " .. tostring(math.floor(worldZ))
        end
    end

    return "Unknown"
end

local function GetTravelHeadingTextSafe()
    if GetPlayerCameraHeading then
        local heading = tonumber(SafeCall(GetPlayerCameraHeading))
        if heading then
            return string.format("%.1f degrees", heading * 57.2957795)
        end
    end
    return "Unknown"
end

local function GetTravelSessionTextSafe()
    local s = LvxJournal.savedVars
    if not s or not s.stats then return "Unknown" end

    local sessionMeters = tonumber(s.stats.sessionMeters) or 0
    local totalMeters = tonumber(s.stats.totalMeters) or 0
    return "Session Distance: " .. FormatDistance(sessionMeters) .. "\nTotal Distance: " .. FormatDistance(totalMeters)
end


local function GetCurrentEntryTitleSafe()
    local s = LvxJournal.savedVars
    if s and s.entries and s.selectedIndex and s.entries[s.selectedIndex] then
        return s.entries[s.selectedIndex].title or "Journal Entry"
    end
    return "Journal Entry"
end


-- -----------------------------------------------------------------------------
-- Journal map markers and map pin integration
-- -----------------------------------------------------------------------------
local mapMarkIconTextures = {
    book = "LvxJournal/ui/map/journal_map_pin_book.dds",
    quill = "LvxJournal/ui/map/journal_map_pin_quill.dds",
    star = "LvxJournal/ui/map/journal_map_pin_star.dds",
    x = "LvxJournal/ui/map/journal_map_pin_x.dds",
}

local mapMarkIconNames = {
    book = "Book",
    quill = "Quill",
    star = "Star",
    x = "X Mark",
}

local mapMarkIconOrder = { "book", "quill", "star", "x" }

local function GetMapMarkIconTexture(icon)
    return mapMarkIconTextures[icon or "book"] or mapMarkIconTextures.book or "LvxJournal/ui/map/journal_map_pin.dds"
end

function LvxJournal.GetMapMarkIconTexture(icon)
    return GetMapMarkIconTexture(icon)
end

local function GetMapMarkIconName(icon)
    return mapMarkIconNames[icon or "book"] or "Book"
end

function LvxJournal.GetMapMarkIconName(icon)
    return GetMapMarkIconName(icon)
end

function LvxJournal.NextMapMarkIcon()
    local s = LvxJournal.savedVars
    if not s then return end
    local current = s.mapMarkIcon or "book"
    local nextIndex = 1
    for i = 1, #mapMarkIconOrder do
        if mapMarkIconOrder[i] == current then
            nextIndex = i + 1
            break
        end
    end
    if nextIndex > #mapMarkIconOrder then nextIndex = 1 end
    s.mapMarkIcon = mapMarkIconOrder[nextIndex]

    -- If the current entry already has a placed marker, update that marker too.
    local updatedExisting = false
    if LvxJournal.GetSelectedEntryMapMarkIndex and s.mapMarks then
        local markIndex = LvxJournal.GetSelectedEntryMapMarkIndex()
        if markIndex and s.mapMarks[markIndex] then
            s.mapMarks[markIndex].icon = s.mapMarkIcon
            updatedExisting = true
        end
    end

    if updatedExisting then
        Msg("Current map marker icon changed to: " .. GetMapMarkIconName(s.mapMarkIcon))
    else
        Msg("Default map marker icon: " .. GetMapMarkIconName(s.mapMarkIcon))
    end

    if LvxJournal.RefreshMapPins then
        LvxJournal.RefreshMapPins(true)
    end

    if LvxJournal.savedVars and LvxJournal.savedVars.viewMode == "tools" and LvxJournal.savedVars.toolsPage == "mapMarks" and LvxJournal.Tools and LvxJournal.Tools.RefreshPage then
        LvxJournal.Tools.RefreshPage()
    end

    if LvxJournal.RefreshEditorMapButtons then
        LvxJournal.RefreshEditorMapButtons()
    end
    if LvxJournal.RefreshOptionsPage and LvxJournal.savedVars and LvxJournal.savedVars.viewMode == "options" then
        LvxJournal.RefreshOptionsPage()
    end
    if LvxJournal.savedVars and LvxJournal.savedVars.viewMode == "edit" and LvxJournal.HideToolsControlsHard then
        LvxJournal.HideToolsControlsHard()
    end
end


function LvxJournal.GetMapPinBackendStatusText()
    local libInstalled = LibMapPins ~= nil
    local bridgeReady = LvxJournal.libMapPinsReady == true

    if libInstalled and bridgeReady then
        local fallbackText = (LvxJournal.savedVars and LvxJournal.savedVars.useBuiltInMapPinFallback == true) and "Testing: Internal fallback only; LibMapPins ignored" or "Internal fallback: Disabled while LibMapPins is active"
        return "|c3FAE4DBackend: LibMapPins bridge active|r\nLibMapPins: Installed\n" .. fallbackText
    elseif libInstalled then
        return "|cC79A4BBackend: Built-in custom pins|r\nLibMapPins: Installed\nBridge: Waiting/not active yet"
    else
        return "|cC79A4BBackend: Built-in custom pins|r\nLibMapPins: Not installed"
    end
end


function LvxJournal.RefreshLibMapPinsVisibilitySafe()
    local lib = LibMapPins
    local pinType = LvxJournal.libMapPinsType
    if not lib or not pinType then return end

    local s = LvxJournal.savedVars
    local showPins = s and s.showMapPins ~= false

    if showPins and type(lib.Enable) == "function" then
        pcall(function()
            lib:Enable(pinType)
        end)
    end

    if type(lib.RefreshPins) == "function" then
        pcall(function() lib:RefreshPins(pinType) end)
        if not showPins then
            pcall(function() lib:RefreshPins() end)
        end
    end
end


function LvxJournal.PulseMinimapRefresh()
    -- Lightweight refresh only. The previous broad refresh pulse could stall the game.
    local now = SafeCall(GetFrameTimeMilliseconds) or 0
    if LvxJournal.lastMinimapRefreshPulse and now > 0 and (now - LvxJournal.lastMinimapRefreshPulse) < 500 then
        return
    end
    LvxJournal.lastMinimapRefreshPulse = now

    local lib = LibMapPins
    local pinType = LvxJournal.libMapPinsType or "LvxJournalMapMarkBridge"
    if not lib or not pinType then return end

    if type(lib.RefreshPins) == "function" then
        pcall(function() lib:RefreshPins(pinType) end)
    end

    -- Only try the broad LibMapPins refresh when hiding pins, because that is when stale minimap pins can remain.
    if LvxJournal.savedVars and LvxJournal.savedVars.showMapPins == false and type(lib.RefreshPins) == "function" then
        pcall(function() lib:RefreshPins() end)
    end
end


function LvxJournal.ToggleMapPinsVisible()
    local s = LvxJournal.savedVars
    if not s then return end

    s.showMapPins = not (s.showMapPins == true)

    if not s.showMapPins then
        LvxJournal.ClearCustomMapPins()
        if LvxJournal.ClearInternalFallbackPinsSafe then
            LvxJournal.ClearInternalFallbackPinsSafe()
        end
    end

    if LvxJournal.RefreshLibMapPinsVisibilitySafe then
        LvxJournal.RefreshLibMapPinsVisibilitySafe()
    end

    if LvxJournal.RefreshMapPins then
        LvxJournal.RefreshMapPins(true)
        if zo_callLater then
            zo_callLater(function()
                if LvxJournal.RefreshLibMapPinsVisibilitySafe then LvxJournal.RefreshLibMapPinsVisibilitySafe() end
                if LvxJournal.PulseMinimapRefresh then LvxJournal.PulseMinimapRefresh() end
            end, 250)
        end
    end

    LvxJournal.RefreshOptionsPage()
    Msg("Map pins: " .. (s.showMapPins and "shown" or "hidden"))
end


function LvxJournal.ClearJournalLibMapPinsBridge()
    local lib = LibMapPins
    if not lib or not LvxJournal.libMapPinsType then return end

    if type(lib.RemoveCustomPin) == "function" then
        pcall(function()
            lib:RemoveCustomPin(LvxJournal.libMapPinsType)
        end)
    end

    if type(lib.Disable) == "function" then
        pcall(function()
            lib:Disable(LvxJournal.libMapPinsType)
        end)
    end
end


function LvxJournal.ClearInternalFallbackPinsSafe()
    local pinManager = ZO_WorldMap_GetPinManager and ZO_WorldMap_GetPinManager() or nil
    if not pinManager then return end

    local pinTypeName = "LvxJournalInternalMapMark"
    local pinTypeId = _G[pinTypeName]

    if pinTypeId and pinManager.SetCustomPinEnabled then
        pcall(function()
            pinManager:SetCustomPinEnabled(pinTypeId, false)
        end)
    end

    if pinTypeId and pinManager.RemovePins then
        pcall(function()
            pinManager:RemovePins(pinTypeName, pinTypeId)
        end)
        pcall(function()
            pinManager:RemovePins(pinTypeId)
        end)
    end

    LvxJournal.internalFallbackReady = false
end


function LvxJournal.ToggleMapPinNames()
    local s = LvxJournal.savedVars
    if not s then return end

    s.showMapPinNames = not (s.showMapPinNames == true)

    if LvxJournal.RefreshMapPins then
        LvxJournal.RefreshMapPins(true)
    end
    if LvxJournal.RefreshOptionsPage then
        LvxJournal.RefreshOptionsPage()
    end

    Msg("Map pin names: " .. (s.showMapPinNames and "ON" or "OFF"))
end

function LvxJournal.ToggleBuiltInMapPinFallback()
    local s = LvxJournal.savedVars
    if not s then return end

    s.useBuiltInMapPinFallback = not (s.useBuiltInMapPinFallback == true)
    if s.useBuiltInMapPinFallback then
        LvxJournal.ClearJournalLibMapPinsBridge()
    else
        LvxJournal.ClearCustomMapPins()
        LvxJournal.ClearInternalFallbackPinsSafe()
    end

    if LvxJournal.RefreshMapPins then
        LvxJournal.RefreshMapPins(true)
        if zo_callLater then
            zo_callLater(function() if LvxJournal.RefreshMapPins then LvxJournal.RefreshMapPins(true) end end, 250)
        end
    end
    LvxJournal.RefreshOptionsPage()
    Msg("Built-in map pin fallback: " .. (s.useBuiltInMapPinFallback and "ON" or "OFF"))
end

function LvxJournal.ToggleAutoPinJournalEntries()
    local s = LvxJournal.savedVars
    if not s then return end

    s.autoPinJournalEntries = not (s.autoPinJournalEntries == true)
    LvxJournal.RefreshOptionsPage()
    Msg("Auto pin journal entries: " .. (s.autoPinJournalEntries and "ON" or "OFF"))
end

function LvxJournal.AutoPinSelectedEntryIfNeeded()
    local s = LvxJournal.savedVars
    if not s or not s.autoPinJournalEntries then return false end
    if not s.entries or not s.selectedIndex or not s.entries[s.selectedIndex] then return false end
    if LvxJournal.SelectedEntryHasMapMark and LvxJournal.SelectedEntryHasMapMark() then return false end
    if not LvxJournal.AddMapMarkFromCurrentLocation then return false end

    return LvxJournal.AddMapMarkFromCurrentLocation(true)
end


local function GetCurrentEntryPinNameSafe()
    local s = LvxJournal.savedVars
    if not s or not s.entries then return "" end
    local entry = s.entries[s.selectedIndex or 1]
    if not entry then return "" end
    return tostring(entry.pinName or "")
end

local function CleanMapMarkName(value)
    value = tostring(value or "")
    value = value:gsub("^%s+", "")
    value = value:gsub("%s+$", "")
    if string.len(value) > 40 then value = string.sub(value, 1, 40) end
    return value
end

local function GetStandaloneMapMarkNameSafe()
    if LvxJournal.mapMarkNameBox and LvxJournal.mapMarkNameBox.GetText then
        return CleanMapMarkName(LvxJournal.mapMarkNameBox:GetText() or "")
    end
    return ""
end

local function GetMapMarkDisplayName(mark)
    if not mark then return "Journal Mark" end
    local s = LvxJournal.savedVars
    if s and s.useJournalTitleForPinName == false then
        local shortName = tostring(mark.pinName or "")
        if shortName ~= "" then return shortName end
        return ""
    end

    local shortName = tostring(mark.pinName or "")
    if shortName ~= "" then return shortName end
    return tostring(mark.title or "Journal Mark")
end

local function GetMapMarkActionLabel(mark)
    local label = GetMapMarkDisplayName(mark)
    if label == nil or tostring(label) == "" then
        label = tostring((mark and mark.title) or "Journal Entry")
    end
    return tostring(label)
end

local function GetMapMarkFromPinOrTag(pinOrMark)
    if pinOrMark and type(pinOrMark.GetPinTypeAndTag) == "function" then
        local ok, _, mark = pcall(function()
            return pinOrMark:GetPinTypeAndTag()
        end)
        if ok and mark then return mark end
    end

    if type(pinOrMark) == "table" then
        return pinOrMark
    end

    return nil
end

local function SetCurrentMapMarkActionTarget(mark)
    if mark then
        LvxJournal.currentMapMarkActionTarget = mark
    end
end

local function GetMapMarkActionLabelFromPin(pinOrMark)
    local mark = GetMapMarkFromPinOrTag(pinOrMark)
    if not mark then
        mark = LvxJournal.currentMapMarkActionTarget
    end
    return GetMapMarkActionLabel(mark)
end

local function GetSafeMapMarkActionLabel(pinOrMark)
    local ok, label = pcall(function()
        return GetMapMarkActionLabelFromPin(pinOrMark)
    end)
    if ok and label and tostring(label) ~= "" then
        return tostring(label)
    end
    return "Journal Map Mark"
end


function LvxJournal.UpdateSelectedEntryPinName()
    local s = LvxJournal.savedVars
    if not s or not s.entries then return end
    local entry = s.entries[s.selectedIndex or 1]
    if not entry then return end

    local value = ""
    if LvxJournal.pinNameBox and LvxJournal.pinNameBox.GetText then
        value = tostring(LvxJournal.pinNameBox:GetText() or "")
    end
    if string.len(value) > 40 then
        value = string.sub(value, 1, 40)
    end

    entry.pinName = value

    if LvxJournal.GetSelectedEntryMapMarkIndex and s.mapMarks then
        local markIndex = LvxJournal.GetSelectedEntryMapMarkIndex()
        if markIndex and s.mapMarks[markIndex] then
            s.mapMarks[markIndex].pinName = value
            if LvxJournal.RefreshMapPins then
                if zo_callLater then
                    if not LvxJournal.pinNameRefreshQueued then
                        LvxJournal.pinNameRefreshQueued = true
                        zo_callLater(function()
                            LvxJournal.pinNameRefreshQueued = false
                            if LvxJournal.RefreshMapPins then LvxJournal.RefreshMapPins(true) end
                        end, 250)
                    end
                else
                    LvxJournal.RefreshMapPins(true)
                end
            end
        end
    end
end

function LvxJournal.ToggleUseJournalTitleForPinName()
    local s = LvxJournal.savedVars
    if not s then return end

    s.useJournalTitleForPinName = not (s.useJournalTitleForPinName == true)

    if LvxJournal.RefreshMapPins then
        LvxJournal.RefreshMapPins(true)
    end
    if LvxJournal.RefreshOptionsPage then
        LvxJournal.RefreshOptionsPage()
    end

    Msg("Journal title pin labels: " .. (s.useJournalTitleForPinName and "ON" or "OFF"))
end


local function GetCurrentMapTextureKeySafe()
    if LibMapPins and LibMapPins.GetZoneAndSubzone then
        local key = CleanTravelText(SafeCall(LibMapPins.GetZoneAndSubzone, LibMapPins, true))
        if key ~= "" then return key end
    end

    if GetMapTileTexture then
        local texture = CleanTravelText(SafeCall(GetMapTileTexture))
        if texture ~= "" then
            texture = string.lower(texture)
            texture = texture:gsub("^.*/maps/", "")
            texture = texture:gsub("%.dds$", "")
            texture = texture:gsub("%d*$", "")
            texture = texture:gsub("_+$", "")
            return texture
        end
    end

    return ""
end

local function GetCurrentMapMarkData()
    local mapName = CleanTravelText(SafeCall(GetMapName))
    local zone = GetLocationText()
    local x, y = nil, nil

    if GetMapPlayerPosition then
        x, y = SafeCall(GetMapPlayerPosition, "player")
    end

    if not x or not y then
        return nil, "Map position unavailable. Open the zone map or move in the world and try again."
    end

    return {
        title = GetCurrentEntryTitleSafe(),
        pinName = GetCurrentEntryPinNameSafe(),
        zone = zone,
        map = mapName ~= "" and mapName or zone,
        mapKey = GetCurrentMapTextureKeySafe(),
        x = tonumber(x) or 0,
        y = tonumber(y) or 0,
        world = GetTravelWorldPositionTextSafe(),
        heading = GetTravelHeadingTextSafe(),
        created = GetStampText(),
        entryIndex = (LvxJournal.savedVars and LvxJournal.savedVars.selectedIndex) or 1,
        icon = (LvxJournal.savedVars and LvxJournal.savedVars.mapMarkIcon) or "book",
    }
end


function LvxJournal.GetSelectedEntryMapMarkIndex()
    local s = LvxJournal.savedVars
    if not s or not s.mapMarks then return nil end
    local entryIndex = tonumber(s.selectedIndex) or 0
    if entryIndex <= 0 then return nil end

    for i = 1, #s.mapMarks do
        local mark = s.mapMarks[i]
        if mark and tonumber(mark.entryIndex) == entryIndex then
            return i
        end
    end

    return nil
end

function LvxJournal.SelectedEntryHasMapMark()
    return LvxJournal.GetSelectedEntryMapMarkIndex() ~= nil
end

function LvxJournal.GetSelectedEntryMapMark()
    local s = LvxJournal.savedVars
    if not s or not s.mapMarks then return nil end
    local index = LvxJournal.GetSelectedEntryMapMarkIndex and LvxJournal.GetSelectedEntryMapMarkIndex() or nil
    if index and s.mapMarks[index] then
        return s.mapMarks[index]
    end
    return nil
end

local function TryCenterWorldMapOnMark(mark)
    if not mark then return false end
    local x = tonumber(mark.x) or 0
    local y = tonumber(mark.y) or 0
    if x <= 0 or y <= 0 then return false end

    local didSomething = false

    -- Open the world map scene first.
    if MAIN_MENU_KEYBOARD and MAIN_MENU_KEYBOARD.ShowScene then
        pcall(function() MAIN_MENU_KEYBOARD:ShowScene("worldMap") end)
        didSomething = true
    elseif SCENE_MANAGER and SCENE_MANAGER.Show then
        pcall(function() SCENE_MANAGER:Show("worldMap") end)
        didSomething = true
    elseif ShowWorldMap then
        pcall(function() ShowWorldMap() end)
        didSomething = true
    end

    -- Try known map pan/zoom helpers. ESO APIs vary, so keep every call safe.
    local function TryZoom()
        local ok = false

        if ZO_WorldMapZoomToNormalizedPosition then
            ok = pcall(function() ZO_WorldMapZoomToNormalizedPosition(x, y) end) or ok
        end
        if ZO_WorldMapPanToNormalizedPosition then
            ok = pcall(function() ZO_WorldMapPanToNormalizedPosition(x, y) end) or ok
        end

        local panZoom = _G["ZO_WorldMapPanAndZoom"] or (ZO_WorldMap and ZO_WorldMap.panAndZoom)
        if type(panZoom) == "table" then
            for _, fnName in ipairs({ "ZoomTo", "ZoomToNormalizedPosition", "PanToNormalizedPosition", "SetNormalizedPosition", "SetPanAndZoom" }) do
                if type(panZoom[fnName]) == "function" then
                    ok = pcall(function() panZoom[fnName](panZoom, x, y) end) or ok
                    ok = pcall(function() panZoom[fnName](panZoom, x, y, 2.0) end) or ok
                end
            end
        end

        if WORLD_MAP_MANAGER then
            for _, fnName in ipairs({ "ZoomToNormalizedPosition", "PanToNormalizedPosition", "SetMapPosition", "SetNormalizedMapPosition" }) do
                if type(WORLD_MAP_MANAGER[fnName]) == "function" then
                    ok = pcall(function() WORLD_MAP_MANAGER[fnName](WORLD_MAP_MANAGER, x, y) end) or ok
                    ok = pcall(function() WORLD_MAP_MANAGER[fnName](WORLD_MAP_MANAGER, x, y, 2.0) end) or ok
                end
            end
        end

        if ZO_WorldMap_GetPinManager then
            local pinManager = ZO_WorldMap_GetPinManager()
            if pinManager and type(pinManager.RefreshPins) == "function" then
                pcall(function() pinManager:RefreshPins() end)
            end
        end

        if LvxJournal.RefreshMapPins then
            LvxJournal.RefreshMapPins(true)
        end

        return ok
    end

    if zo_callLater then
        zo_callLater(TryZoom, 150)
        zo_callLater(TryZoom, 450)
    else
        TryZoom()
    end

    Msg("Opening map near journal pin: " .. tostring(mark.title or "Map Mark"))
    return didSomething
end


function LvxJournal.ZoomToMapMark(mark)
    if not mark then
        Msg("No map mark selected.")
        return false
    end

    -- Reuse selected-entry zoom helper logic by temporarily calling the same safe map open path.
    local x = tonumber(mark.x) or 0
    local y = tonumber(mark.y) or 0
    if x <= 0 or y <= 0 then
        Msg("This map mark has no saved map position.")
        return false
    end

    if MAIN_MENU_KEYBOARD and MAIN_MENU_KEYBOARD.ShowScene then
        pcall(function() MAIN_MENU_KEYBOARD:ShowScene("worldMap") end)
    elseif SCENE_MANAGER and SCENE_MANAGER.Show then
        pcall(function() SCENE_MANAGER:Show("worldMap") end)
    elseif ShowWorldMap then
        pcall(function() ShowWorldMap() end)
    end

    local function TryZoomMark()
        if ZO_WorldMapZoomToNormalizedPosition then
            pcall(function() ZO_WorldMapZoomToNormalizedPosition(x, y) end)
        end
        if ZO_WorldMapPanToNormalizedPosition then
            pcall(function() ZO_WorldMapPanToNormalizedPosition(x, y) end)
        end
        local panZoom = _G["ZO_WorldMapPanAndZoom"] or (ZO_WorldMap and ZO_WorldMap.panAndZoom)
        if type(panZoom) == "table" then
            for _, fnName in ipairs({ "ZoomTo", "ZoomToNormalizedPosition", "PanToNormalizedPosition", "SetNormalizedPosition", "SetPanAndZoom" }) do
                if type(panZoom[fnName]) == "function" then
                    pcall(function() panZoom[fnName](panZoom, x, y) end)
                    pcall(function() panZoom[fnName](panZoom, x, y, 2.0) end)
                end
            end
        end
        if LvxJournal.RefreshMapPins then LvxJournal.RefreshMapPins(true) end
    end

    if zo_callLater then
        zo_callLater(TryZoomMark, 150)
        zo_callLater(TryZoomMark, 450)
    else
        TryZoomMark()
    end

    Msg("Opening map near: " .. tostring(mark.title or "Map Mark"))
    return true
end

function LvxJournal.ZoomToSelectedEntryMapMark()
    local mark = LvxJournal.GetSelectedEntryMapMark and LvxJournal.GetSelectedEntryMapMark() or nil
    if not mark then
        Msg("This journal entry has no map pin.")
        return false
    end

    local ok = TryCenterWorldMapOnMark(mark)
    if not ok then
        Msg("Could not open the map automatically, but the marker is saved at " .. tostring(mark.map or "Unknown Map") .. ".")
    end
    return ok
end

function LvxJournal.RemoveMapMarkForSelectedEntry()
    local s = LvxJournal.savedVars
    if not s or not s.mapMarks then
        Msg("No journal map mark found for this entry.")
        return false
    end

    local index = LvxJournal.GetSelectedEntryMapMarkIndex()
    if not index then
        Msg("No journal map mark found for this entry.")
        return false
    end

    local removed = table.remove(s.mapMarks, index)
    Msg("Removed map mark: " .. tostring((removed and removed.title) or "Map Mark"))

    if LvxJournal.RefreshMapPins then
        LvxJournal.RefreshMapPins(true)
    end
    if LvxJournal.Tools and LvxJournal.savedVars.viewMode == "tools" and LvxJournal.savedVars.toolsPage == "mapMarks" and LvxJournal.Tools.RefreshPage then
        LvxJournal.Tools.RefreshPage()
    end
    if LvxJournal.savedVars.viewMode == "read" then
        LvxJournal.LoadReadEntry()
    end
    if LvxJournal.savedVars.viewMode == "edit" and LvxJournal.RefreshEditorMapButtons then
        LvxJournal.RefreshEditorMapButtons()
    end

    return true
end

function LvxJournal.ToggleSelectedEntryMapMark()
    local result = false
    if LvxJournal.SelectedEntryHasMapMark and LvxJournal.SelectedEntryHasMapMark() then
        result = LvxJournal.RemoveMapMarkForSelectedEntry()
    else
        result = LvxJournal.AddMapMarkFromCurrentLocation()
    end

    if LvxJournal.savedVars and LvxJournal.savedVars.viewMode == "edit" and LvxJournal.RefreshEditorMapButtons then
        LvxJournal.RefreshEditorMapButtons()
    end

    return result
end

-- Checkbox helper for edit mode. Checked means this entry owns a map pin.
function LvxJournal.SetSelectedEntryMapMarkEnabled(enabled)
    local hasMark = LvxJournal.SelectedEntryHasMapMark and LvxJournal.SelectedEntryHasMapMark()
    if enabled then
        if hasMark then return true end
        return LvxJournal.AddMapMarkFromCurrentLocation()
    else
        if not hasMark then return true end
        return LvxJournal.RemoveMapMarkForSelectedEntry()
    end
end


local function RefreshMapPinsAfterListChange()
    if LvxJournal.ClearCustomMapPins then
        LvxJournal.ClearCustomMapPins()
    end
    if LvxJournal.ClearInternalFallbackPinsSafe then
        LvxJournal.ClearInternalFallbackPinsSafe()
    end
    if LvxJournal.RefreshLibMapPinsVisibilitySafe then
        LvxJournal.RefreshLibMapPinsVisibilitySafe()
    end
    if LvxJournal.RefreshMapPins then
        LvxJournal.RefreshMapPins(true)
    end
    if LvxJournal.PulseMinimapRefresh then
        LvxJournal.PulseMinimapRefresh()
    end
    if zo_callLater then
        zo_callLater(function()
            if LvxJournal.RefreshLibMapPinsVisibilitySafe then LvxJournal.RefreshLibMapPinsVisibilitySafe() end
            if LvxJournal.RefreshMapPins then LvxJournal.RefreshMapPins(true) end
            if LvxJournal.PulseMinimapRefresh then LvxJournal.PulseMinimapRefresh() end
        end, 250)
    end
end

-- Adds or updates a map marker. forceNew=true is used by Map Marker Manager
-- and creates a standalone marker instead of linking to the selected journal entry.
function LvxJournal.AddMapMarkFromCurrentLocation(silent, forceNew)
    local s = LvxJournal.savedVars
    if not s then return false end
    s.mapMarks = s.mapMarks or {}

    local mark, err = GetCurrentMapMarkData()
    if not mark then
        if not silent then Msg(err or "Could not save map mark.") end
        return false
    end

    local existingIndex = nil
    if not forceNew and LvxJournal.GetSelectedEntryMapMarkIndex then
        existingIndex = LvxJournal.GetSelectedEntryMapMarkIndex()
    end

    if existingIndex then
        s.mapMarks[existingIndex] = mark
        if not silent then Msg("Journal map mark updated: " .. tostring(mark.title or "Map Mark")) end
    else
        if forceNew then
            -- Tool-page marks are standalone saved places. Do not tie them to selectedIndex.
            -- They use the Map Marker Manager's Mark Name box instead of inheriting the
            -- currently selected journal entry's short pin name/title.
            local managerName = GetStandaloneMapMarkNameSafe()
            if managerName == "" then managerName = "Journal Map Mark" end
            mark.entryIndex = nil
            mark.pinName = managerName
            mark.title = managerName
        end
        table.insert(s.mapMarks, mark)
        local maxPage = math.max(1, math.ceil(#s.mapMarks / MAP_MARKS_PER_PAGE))
        s.mapMarkPage = maxPage
        if not silent then Msg("Journal map mark saved: " .. tostring(mark.title or "Map Mark")) end
    end

    RefreshMapPinsAfterListChange()

    if LvxJournal.savedVars.viewMode == "tools" and LvxJournal.savedVars.toolsPage == "mapMarks" and LvxJournal.Tools and LvxJournal.Tools.RefreshPage then
        LvxJournal.Tools.RefreshPage()
    end
    if LvxJournal.savedVars.viewMode == "read" then
        LvxJournal.LoadReadEntry()
    end
    if LvxJournal.savedVars.viewMode == "edit" and LvxJournal.RefreshEditorMapButtons then
        LvxJournal.RefreshEditorMapButtons()
    end

    return true
end

function LvxJournal.AddStandaloneMapMarkFromCurrentLocation(silent)
    local ok = LvxJournal.AddMapMarkFromCurrentLocation(silent, true)
    if ok and LvxJournal.mapMarkNameBox and LvxJournal.mapMarkNameBox.SetText then
        LvxJournal.mapMarkNameBox:SetText("")
    end
    return ok
end


function LvxJournal.GetShownMapMark()
    local s = LvxJournal.savedVars
    if not s or not s.mapMarks or #s.mapMarks == 0 then return nil end
    local page = tonumber(s.mapMarkPage) or 1
    if page < 1 then page = 1 end
    local perPage = MAP_MARKS_PER_PAGE
    local startIndex = ((page - 1) * perPage) + 1
    return s.mapMarks[startIndex]
end

function LvxJournal.GetMapMarkOnCurrentPage(slot)
    local s = LvxJournal.savedVars
    if not s or not s.mapMarks or #s.mapMarks == 0 then return nil end

    slot = tonumber(slot) or 1
    if slot < 1 then slot = 1 end
    if slot > MAP_MARKS_PER_PAGE then slot = MAP_MARKS_PER_PAGE end

    local page = tonumber(s.mapMarkPage) or 1
    if page < 1 then page = 1 end

    local perPage = MAP_MARKS_PER_PAGE
    local index = ((page - 1) * perPage) + slot
    return s.mapMarks[index], index
end

-- Live rename for Map Marker Manager. It updates data without rebuilding the page,
-- so typing in the Mark Name box keeps focus.
function LvxJournal.LiveUpdateShownMapMarkName()
    if LvxJournal.suppressMapMarkNameChange then return false end

    local s = LvxJournal.savedVars
    if not s or not s.mapMarks or #s.mapMarks == 0 then return false end
    if s.viewMode ~= "tools" or s.toolsPage ~= "mapMarks" then return false end

    local mark, index = nil, nil
    if LvxJournal.GetMapMarkOnCurrentPage then
        mark, index = LvxJournal.GetMapMarkOnCurrentPage(1)
    end
    if not mark or not index then return false end

    local newName = GetStandaloneMapMarkNameSafe()
    if newName == "" then newName = "Journal Map Mark" end

    if mark.pinName == newName and mark.title == newName then return true end

    mark.pinName = newName
    mark.title = newName
    s.selectedMapMarkIndex = index

    LvxJournal.mapMarkRenameRefreshToken = (tonumber(LvxJournal.mapMarkRenameRefreshToken) or 0) + 1
    local token = LvxJournal.mapMarkRenameRefreshToken

    local function DoRenameRefresh()
        if token ~= LvxJournal.mapMarkRenameRefreshToken then return end

        -- Refresh the actual map pins, but do not rebuild the Map Marker Manager page
        -- while the player is typing. Rebuilding the page steals focus from the edit box.
        if RefreshMapPinsAfterListChange then RefreshMapPinsAfterListChange() end

        -- Keep typing focus in the Mark Name field after the delayed pin refresh.
        if LvxJournal.savedVars and LvxJournal.savedVars.viewMode == "tools" and LvxJournal.savedVars.toolsPage == "mapMarks" then
            if LvxJournal.mapMarkNameBox and LvxJournal.mapMarkNameBox.TakeFocus then
                LvxJournal.mapMarkNameBox:TakeFocus()
            end
        end
    end

    if zo_callLater then
        zo_callLater(DoRenameRefresh, 450)
    else
        DoRenameRefresh()
    end

    return true
end

function LvxJournal.UpdateShownMapMarkName(silent)
    local ok = LvxJournal.LiveUpdateShownMapMarkName and LvxJournal.LiveUpdateShownMapMarkName()
    if ok and LvxJournal.Tools and LvxJournal.Tools.RefreshPage and LvxJournal.savedVars and LvxJournal.savedVars.viewMode == "tools" and LvxJournal.savedVars.toolsPage == "mapMarks" then
        LvxJournal.Tools.RefreshPage()
        if LvxJournal.mapMarkNameBox and LvxJournal.mapMarkNameBox.TakeFocus then
            LvxJournal.mapMarkNameBox:TakeFocus()
        end
    end
    if ok and not silent then
        local newName = GetStandaloneMapMarkNameSafe()
        if newName == "" then newName = "Journal Map Mark" end
        Msg("Map marker renamed: " .. tostring(newName))
    end
    return ok
end

function LvxJournal.ZoomMapMarkOnCurrentPage(slot)
    local mark = nil
    local index = nil
    if LvxJournal.GetMapMarkOnCurrentPage then
        mark, index = LvxJournal.GetMapMarkOnCurrentPage(slot)
    end

    if not mark then
        Msg("No map mark in slot " .. tostring(slot) .. " on this page.")
        return false
    end

    -- Treat the clicked Pos line as the selected mark for the Delete Mark button.
    local s = LvxJournal.savedVars
    if s and index then
        s.selectedMapMarkIndex = index
    end

    if LvxJournal.ZoomToMapMark then
        return LvxJournal.ZoomToMapMark(mark)
    end

    Msg("Zoom to map mark is unavailable.")
    return false
end

-- Backward-compatible alias for older buttons/macros.
function LvxJournal.ZoomShownMapMark()
    return LvxJournal.ZoomMapMarkOnCurrentPage(1)
end

function LvxJournal.ZoomShownMapMark()
    local mark = LvxJournal.GetShownMapMark and LvxJournal.GetShownMapMark() or nil
    if not mark then
        Msg("No map mark shown on this page.")
        return false
    end
    if LvxJournal.ZoomToMapMark then
        return LvxJournal.ZoomToMapMark(mark)
    end
    Msg("Zoom to map mark is unavailable.")
    return false
end

function LvxJournal.DeleteShownMapMarks()
    local s = LvxJournal.savedVars
    if not s or not s.mapMarks or #s.mapMarks == 0 then
        Msg("No journal map marks to delete.")
        return false
    end

    local perPage = MAP_MARKS_PER_PAGE
    local maxPage = math.max(1, math.ceil(#s.mapMarks / perPage))
    local page = tonumber(s.mapMarkPage) or 1
    if page < 1 then page = 1 end
    if page > maxPage then page = maxPage end

    local startIndex = ((page - 1) * perPage) + 1
    local endIndex = math.min(startIndex + perPage - 1, #s.mapMarks)

    -- Delete only one mark. If the player clicked a Pos line first, delete that
    -- selected mark as long as it is visible on this page. Otherwise delete the
    -- top visible mark on the current page.
    local deleteIndex = tonumber(s.selectedMapMarkIndex) or startIndex
    if deleteIndex < startIndex or deleteIndex > endIndex then
        deleteIndex = startIndex
    end

    local removed = s.mapMarks[deleteIndex]
    if not removed then
        Msg("No map mark shown on this page.")
        return false
    end

    table.remove(s.mapMarks, deleteIndex)
    s.selectedMapMarkIndex = nil

    local newMaxPage = math.max(1, math.ceil(#s.mapMarks / perPage))
    if page > newMaxPage then page = newMaxPage end
    s.mapMarkPage = page

    RefreshMapPinsAfterListChange()

    if LvxJournal.savedVars.viewMode == "tools" and LvxJournal.savedVars.toolsPage == "mapMarks" and LvxJournal.Tools and LvxJournal.Tools.RefreshPage then
        LvxJournal.Tools.RefreshPage()
    end

    Msg("Deleted map mark: " .. tostring((removed and removed.title) or "Map Mark"))
    return true
end

function LvxJournal.DeleteNewestMapMark()
    return LvxJournal.DeleteShownMapMarks()
end

function LvxJournal.GetMapMarksText()
    local s = LvxJournal.savedVars
    local marks = (s and s.mapMarks) or {}
    if s then s.mapMarkPage = tonumber(s.mapMarkPage) or 1 end

    local lines = {}
    lines[#lines + 1] = "|c5A2015Map Marker Manager|r"
    lines[#lines + 1] = "Icon: |c3B160C" .. GetMapMarkIconName((s and s.mapMarkIcon) or "book") .. "|r"
    lines[#lines + 1] = ""

    if #marks == 0 then
        lines[#lines + 1] = "No map markers saved yet."
        return table.concat(lines, "\n")
    end

    local perPage = MAP_MARKS_PER_PAGE
    local maxPage = math.max(1, math.ceil(#marks / perPage))
    local page = tonumber(s and s.mapMarkPage) or 1
    if page < 1 then page = 1 end
    if page > maxPage then page = maxPage end
    if s then s.mapMarkPage = page end

    local index = ((page - 1) * perPage) + 1
    local mark = marks[index]
    lines[#lines + 1] = "Marker " .. tostring(index) .. " / " .. tostring(#marks) .. "    Page " .. tostring(page) .. " / " .. tostring(maxPage)
    lines[#lines + 1] = ""

    if mark then
        local title = tostring(GetMapMarkActionLabel(mark) or mark.title or "Map Marker")
        if string.len(title) > 34 then title = string.sub(title, 1, 31) .. "..." end
        lines[#lines + 1] = "|c3B160C" .. title .. "|r [" .. GetMapMarkIconName(mark.icon) .. "]"
        lines[#lines + 1] = "Zone: " .. tostring(mark.zone or "Unknown")
        lines[#lines + 1] = "Map: " .. tostring(mark.map or "Unknown")
        lines[#lines + 1] = "Saved: " .. tostring(mark.created or "")
    end

    return table.concat(lines, "\n")
end

function LvxJournal.PrevMapMarkPage()
    local s = LvxJournal.savedVars
    if not s then return end
    s.mapMarkPage = math.max(1, (tonumber(s.mapMarkPage) or 1) - 1)
    if LvxJournal.Tools and LvxJournal.Tools.RefreshPage then LvxJournal.Tools.RefreshPage() end
end

function LvxJournal.NextMapMarkPage()
    local s = LvxJournal.savedVars
    if not s then return end
    local marks = s.mapMarks or {}
    local maxPage = math.max(1, math.ceil(#marks / MAP_MARKS_PER_PAGE))
    s.mapMarkPage = math.min(maxPage, (tonumber(s.mapMarkPage) or 1) + 1)
    if LvxJournal.Tools and LvxJournal.Tools.RefreshPage then LvxJournal.Tools.RefreshPage() end
end

local function GetJournalMapParent()
    return _G["ZO_WorldMapContainer"] or _G["ZO_WorldMapScroll"] or _G["ZO_WorldMap"] or nil
end

local function IsMapCurrentlyVisible()
    local worldMap = _G["ZO_WorldMap"]
    if worldMap and worldMap.IsHidden then
        return not worldMap:IsHidden()
    end
    return false
end

local function GetCurrentJournalMapName()
    local mapName = CleanTravelText(SafeCall(GetMapName))
    if mapName ~= "" then return mapName end
    return GetLocationText()
end

local function MarkMatchesCurrentMap(mark)
    if not mark then return false end

    local currentMap = CleanTravelText(GetCurrentJournalMapName())
    local markMap = CleanTravelText(mark.map)

    -- Never draw journal pins on zoomed-out overview maps.
    -- Old behavior also matched the player's current zone, which caused pins to appear
    -- in the ocean on Tamriel/Aurbis maps because the coordinates belong to the zone map.
    local lowerMap = string.lower(currentMap or "")
    if lowerMap == "tamriel" or lowerMap == "the aurbis" or lowerMap == "aurbis" then
        return false
    end

    -- Prefer exact map texture/key matching for new marks.
    local currentKey = CleanTravelText(GetCurrentMapTextureKeySafe())
    local markKey = CleanTravelText(mark.mapKey)
    if currentKey ~= "" and markKey ~= "" then
        return currentKey == markKey
    end

    -- Fallback for older marks saved before mapKey existed.
    if markMap ~= "" and currentMap ~= "" then
        return markMap == currentMap
    end

    return false
end

local function HideJournalPinTooltip()
    if ClearTooltip and InformationTooltip then
        ClearTooltip(InformationTooltip)
    end
end

local function ShowJournalPinTooltip(control, mark)
    if not control or not mark or not InitializeTooltip or not SetTooltipText or not InformationTooltip then return end

    InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
    local text = tostring(mark.title or "Journal Map Mark")
    text = text .. "\nZone: " .. tostring(mark.zone or "Unknown")
    text = text .. "\nMap: " .. tostring(mark.map or "Unknown")
    text = text .. "\nSaved: " .. tostring(mark.created or "")
    SetTooltipText(InformationTooltip, text)
end

function LvxJournal.OpenMapMarkEntry(mark)
    if not mark then return end

    local s = LvxJournal.savedVars
    if not s or not s.entries then return end

    local function OpenOrToggleEntry(index)
        if not index or index <= 0 or not s.entries[index] then return false end

        local windowOpen = LvxJournal.window and LvxJournal.window.IsHidden and not LvxJournal.window:IsHidden()
        if windowOpen and s.viewMode == "read" and tonumber(s.selectedIndex) == tonumber(index) then
            LvxJournal.ToggleWindow(false)
            return true
        end

        s.selectedIndex = index
        s.lastOpenedIndex = index
        s.viewMode = "read"
        LvxJournal.ToggleWindow(true)
        LvxJournal.RefreshAll()
        return true
    end

    local index = tonumber(mark.entryIndex) or 0
    if OpenOrToggleEntry(index) then return end

    -- Fallback: find by title if the entry index shifted after deletes.
    local title = tostring(mark.title or "")
    for i = 1, #s.entries do
        if tostring(s.entries[i].title or "") == title then
            if OpenOrToggleEntry(i) then return end
        end
    end

    Msg("This standalone map marker is not linked to a journal entry.")
end

local function EnsureJournalMapPin(index)
    LvxJournal.mapPinControls = LvxJournal.mapPinControls or {}

    local control = LvxJournal.mapPinControls[index]
    if control then return control end

    local parent = GetJournalMapParent()
    if not parent or not wm then return nil end

    control = wm:CreateControl("LvxJournalMapPin" .. tostring(index), parent, CT_TEXTURE)
    control:SetDimensions(30, 30)
    control:SetTexture("LvxJournal/ui/map/journal_map_pin.dds")
    control:SetMouseEnabled(true)
    control:SetDrawLayer(DL_OVERLAY)
    control:SetDrawLevel(5)
    control:SetHidden(true)

    control:SetHandler("OnMouseEnter", function(self)
        ShowJournalPinTooltip(self, self.lvxMark)
    end)
    control:SetHandler("OnMouseExit", function()
        HideJournalPinTooltip()
    end)
    control:SetHandler("OnMouseUp", function(self)
        LvxJournal.OpenMapMarkEntry(self.lvxMark)
    end)

    LvxJournal.mapPinControls[index] = control
    return control
end

function LvxJournal.ClearCustomMapPins()
    if LvxJournal.mapPinControls then
        for i = 1, #LvxJournal.mapPinControls do
            local control = LvxJournal.mapPinControls[i]
            if control then
                control:SetHidden(true)
                control.lvxMark = nil
            end
        end
    end

    if LvxJournal.mapPinNameControls then
        for i = 1, #LvxJournal.mapPinNameControls do
            local label = LvxJournal.mapPinNameControls[i]
            if label then
                label:SetHidden(true)
                label.lvxMark = nil
            end
        end
    end
end

local function EnsureJournalMapPinName(index)
    LvxJournal.mapPinNameControls = LvxJournal.mapPinNameControls or {}

    local label = LvxJournal.mapPinNameControls[index]
    if label then return label end

    local parent = GetJournalMapParent()
    if not parent or not wm then return nil end

    label = wm:CreateControl("LvxJournalMapPinName" .. tostring(index), parent, CT_LABEL)
    label:SetDimensions(170, 22)
    label:SetFont("ZoFontGameSmall")
    label:SetColor(0.95, 0.86, 0.55, 1)
    label:SetDrawLayer(DL_OVERLAY)
    label:SetDrawLevel(6)
    label:SetMouseEnabled(false)
    label:SetHidden(true)

    LvxJournal.mapPinNameControls[index] = label
    return label
end

local function GetJournalPinTooltipText(mark)
    if not mark then return "Journal Map Mark" end

    local text = GetMapMarkActionLabel(mark)
    text = text .. "\nZone: " .. tostring(mark.zone or "Unknown")
    text = text .. "\nMap: " .. tostring(mark.map or "Unknown")
    text = text .. "\nSaved: " .. tostring(mark.created or "")
    text = text .. "\nClick: " .. GetMapMarkActionLabel(mark)
    return text
end

local function GetJournalMapMarkCountOnCurrentMap()
    local s = LvxJournal.savedVars
    if not s or not s.mapMarks then return 0 end

    local count = 0
    for i = 1, #s.mapMarks do
        local mark = s.mapMarks[i]
        if mark and mark.x and mark.y and MarkMatchesCurrentMap(mark) then
            count = count + 1
        end
    end
    return count
end

local function SetupJournalLibMapPinsBridge()
    local lib = LibMapPins
    if not lib then
        LvxJournal.libMapPinsStatus = "LibMapPins not installed"
        return
    end
    if LvxJournal.libMapPinsReady then return end

    if type(lib.AddPinType) ~= "function" or type(lib.CreatePin) ~= "function" or type(lib.RefreshPins) ~= "function" then
        LvxJournal.libMapPinsStatus = "LibMapPins found, but required API missing"
        return
    end

    local pinType = "LvxJournalMapMarkBridge"
    LvxJournal.libMapPinsType = pinType

    local function AddPins()
        local s = LvxJournal.savedVars
        if not s or not s.mapMarks or s.showMapPins == false then return end
        if lib.IsEnabled and not lib:IsEnabled(pinType) then return end

        for i = 1, #s.mapMarks do
            local mark = s.mapMarks[i]
            if mark and mark.x and mark.y and MarkMatchesCurrentMap(mark) then
                lib:CreatePin(pinType, mark, tonumber(mark.x) or 0, tonumber(mark.y) or 0)
            end
        end
    end

    local layout = {
        level = 80,
        texture = function(pin)
            local _, mark = pin:GetPinTypeAndTag()
            return GetMapMarkIconTexture(mark and mark.icon)
        end,
        name = function(pin)
            local _, mark = pin:GetPinTypeAndTag()
            SetCurrentMapMarkActionTarget(mark)
            return GetMapMarkActionLabel(mark)
        end,
        size = 28,
        minSize = 22,
        tooltip = ZO_MAP_TOOLTIP_MODE and ZO_MAP_TOOLTIP_MODE.INFORMATION or nil,
        tint = ZO_ColorDef and ZO_ColorDef:New(1, 1, 1, 1) or nil,
    }

    local tooltipCreator = {
        creator = function(pin)
            local _, mark = pin:GetPinTypeAndTag()
            SetCurrentMapMarkActionTarget(mark)
            if IsInGamepadPreferredMode and IsInGamepadPreferredMode() and ZO_MapLocationTooltip_Gamepad then
                local tip = ZO_MapLocationTooltip_Gamepad
                local baseSection = tip.tooltip
                if tip.LayoutIconStringLine and baseSection then
                    tip:LayoutIconStringLine(baseSection, nil, GetJournalPinTooltipText(mark), baseSection:GetStyle("mapLocationTooltipContentName"))
                end
            elseif InformationTooltip and InformationTooltip.AddLine then
                InformationTooltip:AddLine(GetJournalPinTooltipText(mark))
            elseif SetTooltipText and InformationTooltip then
                SetTooltipText(InformationTooltip, GetJournalPinTooltipText(mark))
            end
        end,
        tooltip = ZO_MAP_TOOLTIP_MODE and ZO_MAP_TOOLTIP_MODE.INFORMATION or 1,
    }

    local ok, pinTypeId = pcall(function()
        if _G[pinType] then
            return _G[pinType]
        end
        return lib:AddPinType(pinType, AddPins, nil, layout, tooltipCreator, "Show LvxJournal map marks.")
    end)

    if not ok or not pinTypeId then
        LvxJournal.libMapPinsStatus = "LibMapPins registration failed"
        return
    end

    if type(lib.SetClickHandlers) == "function" then
        lib:SetClickHandlers(pinType, {
            {
                name = "Journal Map Mark",
                gamepadName = "Journal Map Mark",
                buttonText = function(pin)
                    return GetSafeMapMarkActionLabel(pin)
                end,
                gamepadButtonText = function(pin)
                    return GetSafeMapMarkActionLabel(pin)
                end,
                callback = function(pin)
                    LvxJournal.OpenMapMarkEntry(GetMapMarkFromPinOrTag(pin))
                end,
            },
        }, nil)
    end

    local s = LvxJournal.savedVars
    if s then
        s.mapPinFilters = s.mapPinFilters or { journalPins = true }
        if type(lib.AddPinFilter) == "function" then
            pcall(function()
                lib:AddPinFilter(pinType, "LvxJournal Map Marks", false, s.mapPinFilters, "journalPins")
            end)
        end
        if s.showMapPins ~= false and type(lib.Enable) == "function" then
            pcall(function() lib:Enable(pinType) end)
        end
    end

    LvxJournal.libMapPinsReady = true
    LvxJournal.libMapPinsStatus = "LibMapPins bridge active"
end


local function RefreshJournalLibMapPinsBridge(force)
    SetupJournalLibMapPinsBridge()

    local now = SafeCall(GetFrameTimeMilliseconds) or 0
    if not force and LvxJournal.lastLibMapPinsRefresh and now > 0 and (now - LvxJournal.lastLibMapPinsRefresh) < 3000 then
        return
    end
    LvxJournal.lastLibMapPinsRefresh = now

    local lib = LibMapPins
    if lib and LvxJournal.libMapPinsType and type(lib.RefreshPins) == "function" then
        pcall(function()
            lib:RefreshPins(LvxJournal.libMapPinsType)
        end)
    end
end


function LvxJournal.SuppressFallbackPinsDuringZoom()
    local s = LvxJournal.savedVars
    if not s or s.useBuiltInMapPinFallback ~= true then return end

    if RefreshInternalFallbackPins then
        RefreshInternalFallbackPins(true)
    end
end


local function GetInternalMapPinTypeName()
    return "LvxJournalInternalMapMark"
end

local function GetInternalMapPinTypeId()
    return _G[GetInternalMapPinTypeName()]
end

local function InternalFallbackAddPins(pinManager)
    local s = LvxJournal.savedVars
    if not s or s.showMapPins == false or s.useBuiltInMapPinFallback ~= true then return end
    if not s.mapMarks then return end

    for i = 1, #s.mapMarks do
        local mark = s.mapMarks[i]
        if mark and mark.x and mark.y and MarkMatchesCurrentMap(mark) then
            pinManager:CreatePin(GetInternalMapPinTypeId(), mark, tonumber(mark.x) or 0, tonumber(mark.y) or 0)
        end
    end
end

local function InternalFallbackTooltipCreator(pin)
    local _, mark = pin:GetPinTypeAndTag()
    SetCurrentMapMarkActionTarget(mark)
    if not mark then return end

    local text = GetMapMarkActionLabel(mark)
    text = text .. "\nZone: " .. tostring(mark.zone or "Unknown")
    text = text .. "\nMap: " .. tostring(mark.map or "Unknown")
    text = text .. "\nSaved: " .. tostring(mark.created or "")
    text = text .. "\n\nClick: " .. GetMapMarkActionLabel(mark)

    if IsInGamepadPreferredMode and IsInGamepadPreferredMode() and ZO_MapLocationTooltip_Gamepad then
        local tip = ZO_MapLocationTooltip_Gamepad
        local baseSection = tip.tooltip
        if tip.LayoutIconStringLine and baseSection then
            tip:LayoutIconStringLine(baseSection, nil, text, baseSection:GetStyle("mapLocationTooltipContentName"))
        end
    elseif SetTooltipText and InformationTooltip then
        SetTooltipText(InformationTooltip, text)
    elseif InformationTooltip and InformationTooltip.AddLine then
        InformationTooltip:AddLine(text)
    end
end

local function SetupInternalFallbackPins()
    if LvxJournal.internalFallbackReady then return true end
    if not ZO_WorldMap_GetPinManager then
        LvxJournal.internalFallbackStatus = "Internal fallback unavailable: no world map pin manager"
        return false
    end

    local pinManager = ZO_WorldMap_GetPinManager()
    if not pinManager or not pinManager.AddCustomPin then
        LvxJournal.internalFallbackStatus = "Internal fallback unavailable: custom pins unsupported"
        return false
    end

    local pinTypeName = GetInternalMapPinTypeName()
    if _G[pinTypeName] then
        local pinTypeId = _G[pinTypeName]
        if pinTypeId and ZO_MapPin and ZO_MapPin.PIN_CLICK_HANDLERS and MOUSE_BUTTON_INDEX_LEFT then
            ZO_MapPin.PIN_CLICK_HANDLERS[MOUSE_BUTTON_INDEX_LEFT][pinTypeId] = {
                {
                    name = "Journal Map Mark",
                    gamepadName = "Journal Map Mark",
                    buttonText = function(pin)
                        return GetSafeMapMarkActionLabel(pin)
                    end,
                    gamepadButtonText = function(pin)
                        return GetSafeMapMarkActionLabel(pin)
                    end,
                    callback = function(pin)
                        LvxJournal.OpenMapMarkEntry(GetMapMarkFromPinOrTag(pin))
                    end,
                },
            }
        end
        LvxJournal.internalFallbackReady = true
        LvxJournal.internalFallbackStatus = "Internal fallback ready"
        return true
    end

    local layout = {
        level = 80,
        texture = function(pin)
            local _, mark = pin:GetPinTypeAndTag()
            return GetMapMarkIconTexture(mark and mark.icon)
        end,
        name = function(pin)
            local _, mark = pin:GetPinTypeAndTag()
            SetCurrentMapMarkActionTarget(mark)
            return GetMapMarkActionLabel(mark)
        end,
        size = 28,
        minSize = 22,
        tint = ZO_ColorDef and ZO_ColorDef:New(1, 1, 1, 1) or nil,
    }

    local tooltipCreator = {
        creator = InternalFallbackTooltipCreator,
        tooltip = ZO_MAP_TOOLTIP_MODE and ZO_MAP_TOOLTIP_MODE.INFORMATION or 1,
    }

    local ok = pcall(function()
        pinManager:AddCustomPin(pinTypeName, InternalFallbackAddPins, nil, layout, tooltipCreator)
        local pinTypeId = _G[pinTypeName]
        if pinTypeId and pinManager.SetCustomPinEnabled then
            pinManager:SetCustomPinEnabled(pinTypeId, true)
        end

        if pinTypeId and ZO_MapPin and ZO_MapPin.PIN_CLICK_HANDLERS and MOUSE_BUTTON_INDEX_LEFT then
            ZO_MapPin.PIN_CLICK_HANDLERS[MOUSE_BUTTON_INDEX_LEFT][pinTypeId] = {
                {
                    name = "Journal Map Mark",
                    gamepadName = "Journal Map Mark",
                    buttonText = function(pin)
                        return GetSafeMapMarkActionLabel(pin)
                    end,
                    gamepadButtonText = function(pin)
                        return GetSafeMapMarkActionLabel(pin)
                    end,
                    callback = function(pin)
                        LvxJournal.OpenMapMarkEntry(GetMapMarkFromPinOrTag(pin))
                    end,
                },
            }
        end
    end)

    if not ok or not _G[pinTypeName] then
        LvxJournal.internalFallbackStatus = "Internal fallback registration failed"
        return false
    end

    LvxJournal.internalFallbackReady = true
    LvxJournal.internalFallbackStatus = "Internal fallback active"
    return true
end

local function ClearInternalFallbackPins()
    if LvxJournal.ClearInternalFallbackPinsSafe then
        LvxJournal.ClearInternalFallbackPinsSafe()
        return
    end

    local pinManager = ZO_WorldMap_GetPinManager and ZO_WorldMap_GetPinManager() or nil
    local pinTypeId = GetInternalMapPinTypeId()
    if pinManager and pinTypeId and pinManager.RemovePins then
        pcall(function()
            pinManager:RemovePins(GetInternalMapPinTypeName(), pinTypeId)
        end)
        pcall(function()
            pinManager:RemovePins(pinTypeId)
        end)
    end
end

local function RefreshInternalFallbackPins(force)
    if not SetupInternalFallbackPins() then
        return false
    end

    local pinManager = ZO_WorldMap_GetPinManager and ZO_WorldMap_GetPinManager() or nil
    local pinTypeId = GetInternalMapPinTypeId()
    if not pinManager or not pinTypeId then return false end

    if pinManager.RemovePins then
        pcall(function()
            pinManager:RemovePins(GetInternalMapPinTypeName(), pinTypeId)
        end)
        pcall(function()
            pinManager:RemovePins(pinTypeId)
        end)
    end

    if pinManager.SetCustomPinEnabled then
        pcall(function()
            pinManager:SetCustomPinEnabled(pinTypeId, true)
        end)
    end

    if pinManager.RefreshCustomPins then
        pcall(function()
            pinManager:RefreshCustomPins(pinTypeId)
        end)
    end

    return true
end


function LvxJournal.RefreshMapPins(force)
    local s = LvxJournal.savedVars
    if not s then return end
    s.mapMarks = s.mapMarks or {}

    if s.showMapPins == false then
        LvxJournal.ClearCustomMapPins()
        if LvxJournal.ClearInternalFallbackPinsSafe then
            LvxJournal.ClearInternalFallbackPinsSafe()
        end
        if LvxJournal.RefreshLibMapPinsVisibilitySafe then
            LvxJournal.RefreshLibMapPinsVisibilitySafe()
        end
        LvxJournal.mapPinLibraryStatus = "Map pins hidden in Options"
        return
    end

    local fallbackOnly = s.useBuiltInMapPinFallback == true

    if fallbackOnly then
        -- Internal fallback testing mode: do not touch LibMapPins rendering.
        if LvxJournal.ClearJournalLibMapPinsBridge then
            LvxJournal.ClearJournalLibMapPinsBridge()
        end
        LvxJournal.ClearCustomMapPins()
        if RefreshInternalFallbackPins(force) then
            LvxJournal.mapPinLibraryStatus = tostring(LvxJournal.internalFallbackStatus or "Internal fallback active") .. "; LibMapPins ignored"
        else
            LvxJournal.mapPinLibraryStatus = tostring(LvxJournal.internalFallbackStatus or "Internal fallback unavailable")
        end
        return
    else
        ClearInternalFallbackPins()
        RefreshJournalLibMapPinsBridge(force)
        if LibMapPins and LvxJournal.libMapPinsReady == true then
            LvxJournal.ClearCustomMapPins()
            LvxJournal.mapPinLibraryStatus = "LibMapPins bridge active; built-in overlay disabled"
            if LvxJournal.libMapPinsStatus and LvxJournal.libMapPinsStatus ~= "" then
                LvxJournal.mapPinLibraryStatus = LvxJournal.mapPinLibraryStatus .. " / " .. LvxJournal.libMapPinsStatus
            end
            return
        end
    end

    local parent = GetJournalMapParent()
    if not parent or not parent.GetWidth or not parent.GetHeight then
        LvxJournal.ClearCustomMapPins()
        LvxJournal.mapPinLibraryStatus = "Built-in fallback waiting for map UI"
        return
    end

    if not IsMapCurrentlyVisible() then
        LvxJournal.ClearCustomMapPins()
        LvxJournal.mapPinLibraryStatus = fallbackOnly and "Fallback only ready; open the zone map" or "Custom map pins ready"
        return
    end

    local width = tonumber(parent:GetWidth()) or 0
    local height = tonumber(parent:GetHeight()) or 0
    if width <= 0 or height <= 0 then
        LvxJournal.ClearCustomMapPins()
        LvxJournal.mapPinLibraryStatus = "Built-in fallback waiting for map size"
        return
    end

    local currentMap = CleanTravelText(GetCurrentJournalMapName())
    local lowerMap = string.lower(currentMap or "")
    if lowerMap == "tamriel" or lowerMap == "the aurbis" or lowerMap == "aurbis" then
        LvxJournal.ClearCustomMapPins()
        LvxJournal.mapPinLibraryStatus = "Pins hidden on overview map"
        return
    end

    local used = 0
    local total = #s.mapMarks

    for i = 1, total do
        local mark = s.mapMarks[i]
        if mark and mark.x and mark.y and MarkMatchesCurrentMap(mark) then
            used = used + 1
            local pin = EnsureJournalMapPin(used)
            if pin then
                local x = (tonumber(mark.x) or 0) * width
                local y = (tonumber(mark.y) or 0) * height

                pin.lvxMark = mark
                pin:SetTexture(GetMapMarkIconTexture(mark.icon))
                pin:ClearAnchors()
                pin:SetAnchor(CENTER, parent, TOPLEFT, x, y)
                pin:SetHidden(false)

                local nameLabel = EnsureJournalMapPinName(used)
                if nameLabel then
                    nameLabel.lvxMark = mark
                    nameLabel:SetText(GetMapMarkDisplayName(mark))
                    nameLabel:ClearAnchors()
                    nameLabel:SetAnchor(LEFT, pin, RIGHT, 4, 0)
                    nameLabel:SetHidden(not (s.showMapPinNames == true))
                end
            end
        end
    end

    if LvxJournal.mapPinControls then
        for i = used + 1, #LvxJournal.mapPinControls do
            local pin = LvxJournal.mapPinControls[i]
            if pin then
                pin:SetHidden(true)
                pin.lvxMark = nil
            end
        end
    end
    if LvxJournal.mapPinNameControls then
        for i = used + 1, #LvxJournal.mapPinNameControls do
            local label = LvxJournal.mapPinNameControls[i]
            if label then
                label:SetHidden(true)
                label.lvxMark = nil
            end
        end
    end

    if fallbackOnly then
        LvxJournal.mapPinLibraryStatus = "Fallback only test: " .. tostring(used) .. " / " .. tostring(total) .. " marks on current map"
    elseif used == 1 then
        LvxJournal.mapPinLibraryStatus = "Custom pins: 1 on current map"
    else
        LvxJournal.mapPinLibraryStatus = "Custom pins: " .. tostring(used) .. " on current map"
    end

    if used == 0 and total > 0 then
        LvxJournal.mapPinLibraryStatus = LvxJournal.mapPinLibraryStatus .. " - open the saved zone map"
    end
end

local function SetupJournalMapPins()
    LvxJournal.mapPinLibraryStatus = "Custom map pins active"
    SetupJournalLibMapPinsBridge()

    if CALLBACK_MANAGER and not LvxJournal.customMapPinCallbacksRegistered then
        LvxJournal.customMapPinCallbacksRegistered = true
        CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function()
            if LvxJournal.RefreshMapPins then
                LvxJournal.RefreshMapPins("resetFallbackZoom")
            end
        end)
    end

    if not LvxJournal.customMapMouseWheelHooked then
        LvxJournal.customMapMouseWheelHooked = true
        local controls = {
            _G["ZO_WorldMap"],
            _G["ZO_WorldMapContainer"],
            _G["ZO_WorldMapScroll"],
        }

        for i = 1, #controls do
            local control = controls[i]
            if control and control.SetHandler and control.GetHandler then
                local oldWheel = control:GetHandler("OnMouseWheel")
                control:SetHandler("OnMouseWheel", function(...)
                    if LvxJournal.SuppressFallbackPinsDuringZoom then
                        LvxJournal.SuppressFallbackPinsDuringZoom()
                    end
                    if oldWheel then
                        oldWheel(...)
                    end
                end)
            end
        end
    end

    if WORLD_MAP_SCENE and not LvxJournal.customMapSceneCallbacksRegistered then
        LvxJournal.customMapSceneCallbacksRegistered = true
        WORLD_MAP_SCENE:RegisterCallback("StateChange", function(oldState, newState)
            if newState == SCENE_SHOWN or newState == SCENE_SHOWING then
                LvxJournal.fallbackZoomUnsafe = false
                LvxJournal.fallbackZoomSuppressUntil = 0
                if zo_callLater then
                    zo_callLater(function() if LvxJournal.RefreshMapPins then LvxJournal.RefreshMapPins("resetFallbackZoom") end end, 150)
                elseif LvxJournal.RefreshMapPins then
                    LvxJournal.RefreshMapPins("resetFallbackZoom")
                end
            elseif newState == SCENE_HIDDEN or newState == SCENE_HIDING then
                if LvxJournal.ClearCustomMapPins then LvxJournal.ClearCustomMapPins() end
            end
        end)
    end
end


local function BuildTravelLogBody(zone, isFirstVisit)
    zone = CleanTravelText(zone)
    if zone == "" then zone = "Unknown Location" end

    local lines = {}
    lines[#lines + 1] = isFirstVisit and "First Recorded Visit" or "Travel Update"
    lines[#lines + 1] = ""
    lines[#lines + 1] = "Zone: " .. zone
    lines[#lines + 1] = "Subzone: " .. GetSubZoneTextSafe()
    lines[#lines + 1] = "Map: " .. GetMapNameTextSafe()
    lines[#lines + 1] = "Zone ID: " .. GetZoneIdTextSafe()
    lines[#lines + 1] = "Map Position: " .. GetTravelMapPositionTextSafe()
    lines[#lines + 1] = "World Position: " .. GetTravelWorldPositionTextSafe()
    lines[#lines + 1] = "Camera Heading: " .. GetTravelHeadingTextSafe()
    lines[#lines + 1] = "Time: " .. GetStampText()
    lines[#lines + 1] = ""
    lines[#lines + 1] = GetTravelSessionTextSafe()
    lines[#lines + 1] = ""

    if isFirstVisit then
        lines[#lines + 1] = "Notes:"
        lines[#lines + 1] = "First time this character/account recorded this place in the journal."
    else
        lines[#lines + 1] = "Notes:"
        lines[#lines + 1] = "Returned to a previously recorded place."
    end

    return table.concat(lines, "\n")
end


function LvxJournal.OnZoneChanged()
    if LvxJournal.RefreshMapPins then LvxJournal.RefreshMapPins() end
    local s = LvxJournal.savedVars
    if not s.autoTravel then return end

    local zone = GetLocationText()
    if zone == "" or zone == "Unknown Location" then return end

    s.knownZones = s.knownZones or {}
    local firstVisit = s.knownZones[zone] == nil

    if type(s.knownZones[zone]) == "table" then
        s.knownZones[zone].visits = (tonumber(s.knownZones[zone].visits) or 0) + 1
        s.knownZones[zone].last = GetStampText()
        AttachZoneTravelStats(s.knownZones[zone])
    elseif s.knownZones[zone] == true then
        s.knownZones[zone] = {
            first = "Previously recorded",
            last = GetStampText(),
            visits = 2,
        }
        AttachZoneTravelStats(s.knownZones[zone])
    else
        s.knownZones[zone] = {
            first = GetStampText(),
            last = GetStampText(),
            visits = 1,
        }
        AttachZoneTravelStats(s.knownZones[zone])
    end

    if not firstVisit then return end

    AddEntry("Arrived in " .. zone, BuildTravelLogBody(zone, true), "Travel", "Zone", true)
end


local function CleanAchievementText(value)
    value = tostring(value or "")
    value = value:gsub("%^.*$", "")
    value = value:gsub("\r\n", "\n")
    value = value:gsub("\r", "\n")
    value = value:gsub("^%s+", "")
    value = value:gsub("%s+$", "")
    return value
end

local function GetAchievementCategoryTextSafe(achievementId)
    if not achievementId then return "Unknown" end

    if GetCategoryInfo and GetAchievementCategory and GetAchievementSubCategory then
        local categoryId = SafeCall(GetAchievementCategory, achievementId)
        local subCategoryId = SafeCall(GetAchievementSubCategory, achievementId)

        local categoryName = categoryId and SafeCall(GetCategoryInfo, categoryId) or nil
        local subCategoryName = subCategoryId and SafeCall(GetCategoryInfo, subCategoryId) or nil

        categoryName = CleanAchievementText(categoryName)
        subCategoryName = CleanAchievementText(subCategoryName)

        if categoryName ~= "" and subCategoryName ~= "" and categoryName ~= subCategoryName then
            return categoryName .. " / " .. subCategoryName
        elseif categoryName ~= "" then
            return categoryName
        elseif subCategoryName ~= "" then
            return subCategoryName
        end
    end

    return "Unknown"
end

local function GetAchievementPointsTextSafe(achievementId)
    if not achievementId then return "Unknown" end

    if GetAchievementRewardPoints then
        local points = SafeCall(GetAchievementRewardPoints, achievementId)
        if tonumber(points) then
            return tostring(points)
        end
    end

    if GetAchievementInfo then
        local values = { SafeCall(GetAchievementInfo, achievementId) }
        for i = 1, #values do
            local value = tonumber(values[i])
            if value and value >= 0 and value <= 5000 then
                -- ESO has changed return layouts across APIs. Use the first reasonable numeric value as a safe fallback.
                return tostring(value)
            end
        end
    end

    return "Unknown"
end

local function GetAchievementDescriptionSafe(achievementId)
    if not achievementId then return "" end

    if GetAchievementDescription then
        local desc = CleanAchievementText(SafeCall(GetAchievementDescription, achievementId))
        if desc ~= "" then return desc end
    end

    if GetAchievementInfo then
        local values = { SafeCall(GetAchievementInfo, achievementId) }
        for i = 1, #values do
            local value = CleanAchievementText(values[i])
            if value ~= "" and value ~= "true" and value ~= "false" and not tonumber(value) then
                -- The first string is usually the name, so prefer later strings if present.
                if i > 1 then
                    return value
                end
            end
        end
    end

    return ""
end

local function GetAchievementNameSafe(achievementId)
    if not achievementId then return "Achievement" end

    if GetAchievementInfo then
        local aName = CleanAchievementText(SafeCall(GetAchievementInfo, achievementId))
        if aName ~= "" then return aName end
    end

    return "Achievement"
end

local function BuildAchievementLogBody(achievementId, name)
    local lines = {}
    lines[#lines + 1] = "Achievement Unlocked"
    lines[#lines + 1] = ""
    lines[#lines + 1] = "Name: " .. CleanAchievementText(name)
    lines[#lines + 1] = "Achievement ID: " .. tostring(achievementId or "Unknown")
    lines[#lines + 1] = "Points: " .. GetAchievementPointsTextSafe(achievementId)
    lines[#lines + 1] = "Category: " .. GetAchievementCategoryTextSafe(achievementId)
    lines[#lines + 1] = "Location: " .. GetLocationText()
    lines[#lines + 1] = "Time: " .. GetStampText()

    local desc = GetAchievementDescriptionSafe(achievementId)
    if desc ~= "" and desc ~= name then
        lines[#lines + 1] = ""
        lines[#lines + 1] = "Description:"
        lines[#lines + 1] = desc
    end

    return table.concat(lines, "\n")
end


function LvxJournal.OnAchievementAwarded(eventCode, achievementId)
    if not (LvxJournal.savedVars and LvxJournal.savedVars.trackAchievementLog == true) then return end

    local name = GetAchievementNameSafe(achievementId)
    local body = BuildAchievementLogBody(achievementId, name)

    AddEntry("Achievement: " .. name, body, "Achievement", "Achievement", true)
end

function LvxJournal.HandleSlash(text)
    text = string.lower(text or "")

    if text == "" then
        LvxJournal.ToggleWindow()
    elseif text == "new" then
        LvxJournal.ToggleWindow(true)
        LvxJournal.AddManualEntry()
    elseif text == "save" then
        LvxJournal.SaveCurrentEntry()
    elseif text == "profile" then
        LvxJournal.ToggleWindow(true)
        LvxJournal.SetFilter("Profile")
    elseif text == "templates" then
        LvxJournal.ToggleWindow(true)
        LvxJournal.OpenTemplateChooser()
    elseif text == "tools" then
        LvxJournal.ToggleWindow(true)
        LvxJournal.ShowToolsPage("main")
    elseif text == "oracle" then
        LvxJournal.ToggleWindow(true)
        LvxJournal.ShowToolsPage("oracle")
        if LvxJournal.Tools then LvxJournal.Tools.RollOracle() end
    elseif text == "dice" then
        LvxJournal.ToggleWindow(true)
        LvxJournal.ShowToolsPage("dice")
    elseif text == "mark" or text == "mapmark" then
        LvxJournal.AddStandaloneMapMarkFromCurrentLocation()
        LvxJournal.ToggleWindow(true)
        LvxJournal.ShowToolsPage("mapMarks")
    elseif text == "marks" or text == "mapmarks" then
        LvxJournal.ToggleWindow(true)
        LvxJournal.ShowToolsPage("mapMarks")
    elseif text == "markicon" then
        LvxJournal.NextMapMarkIcon()
        LvxJournal.ToggleWindow(true)
        LvxJournal.ShowToolsPage("mapMarks")
    elseif text == "togglemarks" then
        LvxJournal.ToggleMapPinsVisible()
    elseif text == "autopin" then
        LvxJournal.ToggleAutoPinJournalEntries()
    elseif text == "fallbackpins" then
        LvxJournal.ToggleBuiltInMapPinFallback()
    elseif text == "mousefocus" then
        LvxJournal.ToggleAutoFocusMouse()
    elseif text == "zoompin" or text == "pinzoom" then
        LvxJournal.ZoomToSelectedEntryMapMark()
    elseif text == "pinnames" or text == "marknames" then
        LvxJournal.ToggleMapPinNames()
    elseif text == "pintitles" or text == "journaltitles" then
        LvxJournal.ToggleUseJournalTitleForPinName()
    elseif text == "deletemark" then
        LvxJournal.DeleteNewestMapMark()
        LvxJournal.ToggleWindow(true)
        LvxJournal.ShowToolsPage("mapMarks")
    elseif text == "export" then
        LvxJournal.ToggleWindow(true)
        LvxJournal.ShowToolsPage("export")
    elseif text == "options" or text == "themes" then
        LvxJournal.ToggleWindow(true)
        LvxJournal.SetFilter("Options")
    elseif text == "theme next" then
        LvxJournal.ToggleWindow(true)
        LvxJournal.SetFilter("Options")
        LvxJournal.NextTheme()
    elseif string.sub(text, 1, 6) == "theme " then
        LvxJournal.ToggleWindow(true)
        LvxJournal.SetFilter("Options")
        LvxJournal.SetTheme(string.sub(text, 7))
    elseif text == "stats" then
        LvxJournal.ToggleWindow(true)
        LvxJournal.SetFilter("Stats")
    elseif text == "stats next" then
        LvxJournal.ToggleWindow(true)
        LvxJournal.SetFilter("Stats")
        LvxJournal.NextStatsPage()
    elseif text == "stats prev" then
        LvxJournal.ToggleWindow(true)
        LvxJournal.SetFilter("Stats")
        LvxJournal.PrevStatsPage()
    elseif text == "killtest" then
        LvxJournal.savedVars.stats = LvxJournal.savedVars.stats or {}
        LvxJournal.savedVars.stats.enemyKills = (tonumber(LvxJournal.savedVars.stats.enemyKills) or 0) + 1
        LvxJournal.savedVars.stats.sessionEnemyKills = (tonumber(LvxJournal.savedVars.stats.sessionEnemyKills) or 0) + 1
        LvxJournal.ToggleWindow(true)
        LvxJournal.SetFilter("Stats", 3)
        Msg("Test enemy kill added.")
    elseif text == "tribute win" then
        LvxJournal.RecordTributeResult("win", "Manual")
        LvxJournal.ToggleWindow(true)
        LvxJournal.SetFilter("Stats", 10)
    elseif text == "tribute loss" then
        LvxJournal.RecordTributeResult("loss", "Manual")
        LvxJournal.ToggleWindow(true)
        LvxJournal.SetFilter("Stats", 10)
    elseif text == "tribute reset" then
        LvxJournal.savedVars.stats.tributeWins = 0
        LvxJournal.savedVars.stats.tributeLosses = 0
        LvxJournal.savedVars.stats.tributeGames = 0
        LvxJournal.savedVars.stats.tributeLastResult = ""
        LvxJournal.savedVars.stats.tributeLastSource = "Manual Reset"
        LvxJournal.savedVars.stats.tributeLastTime = GetStampText()
        LvxJournal.ToggleWindow(true)
        LvxJournal.SetFilter("Stats", 10)
        Msg("Tales of Tribute tracked results reset.")
    elseif text == "search" or text == "find" then
        LvxJournal.ToggleWindow(true)
        LvxJournal.OpenSearch()
    elseif string.sub(text, 1, 7) == "search " then
        LvxJournal.ToggleWindow(true)
        local search = GetSearchState()
        search.query = string.sub(text, 8) or ""
        search.page = 1
        LvxJournal.savedVars.viewMode = "search"
        LvxJournal.BuildSearchResults()
        LvxJournal.RefreshAll()
    elseif string.sub(text, 1, 5) == "find " then
        LvxJournal.ToggleWindow(true)
        local search = GetSearchState()
        search.query = string.sub(text, 6) or ""
        search.page = 1
        LvxJournal.savedVars.viewMode = "search"
        LvxJournal.BuildSearchResults()
        LvxJournal.RefreshAll()
    elseif text == "resetdistance" then
        LvxJournal.savedVars.profile = LvxJournal.savedVars.profile or {}
    LvxJournal.savedVars.theme = LvxJournal.savedVars.theme or "blank"
    LvxJournal.savedVars.pendingDeleteIndex = nil
    LvxJournal.savedVars.pendingDeleteArmed = nil
    LvxJournal.savedVars.stats = LvxJournal.savedVars.stats or {}
        LvxJournal.savedVars.stats.totalMeters = 0
        LvxJournal.savedVars.stats.sessionMeters = 0
        LvxJournal.RefreshAll()
        Msg("Travel distance reset.")
    elseif text == "time rp" then
        LvxJournal.savedVars.useRoleplayTime = true
        LvxJournal.RefreshAll()
        Msg("Time preference: roleplay time.")
    elseif text == "time real" then
        LvxJournal.savedVars.useRoleplayTime = false
        LvxJournal.RefreshAll()
        Msg("Time preference: real date and day.")
    else
        d("|cC79A4BJournal commands:|r")
        d("/journal")
        d("/journal new")
        d("/journal save")
        d("/journal profile")
        d("/journal templates")
        d("/journal options")
        d("/journal theme next")
        d("/journal theme <classic|arcane|dwemer|warden|daedric|blank>")
        d("/journal stats")
        d("/journal stats next")
        d("/journal stats prev")
        d("/journal killtest")
        d("/journal tribute win")
        d("/journal tribute loss")
        d("/journal tribute reset")
        d("/journal search")
        d("/journal search <word>")
        d("/journal resetdistance")
        d("/journal time rp")
        d("/journal time real")
    end
end

-- -----------------------------------------------------------------------------
-- Addon initialization and slash commands
-- -----------------------------------------------------------------------------
function LvxJournal.OnAddOnLoaded(event, addonName)
    if addonName ~= LvxJournal.name then return end
    em:UnregisterForEvent(LvxJournal.name, EVENT_ADD_ON_LOADED)

    local worldName = SafeCall(GetWorldName) or "Unknown Server"
    local oldAccountWideVars = ZO_SavedVars:NewAccountWide("LvxJournalSavedVars", 5, nil, defaults)
    LvxJournal.savedVars = ZO_SavedVars:NewAccountWide("LvxJournalSavedVars", 5, worldName, defaults)
    LvxJournal.exportVars = ZO_SavedVars:NewAccountWide("LvxJournalExportVars", 1, worldName, { exports = {}, lastExport = 0 })

    -- ESOUI release cleanup:
    -- Keep account-wide journal data separated by megaserver so NA, EU, and PTS do not share one journal table.
    -- If the user had data in the older non-server namespace, copy it once into the current server namespace.
    if oldAccountWideVars and oldAccountWideVars ~= LvxJournal.savedVars then
        local needsMigration = not LvxJournal.savedVars.esouiServerMigrationDone
        local oldHasEntries = oldAccountWideVars.entries and #oldAccountWideVars.entries > 0
        local newHasEntries = LvxJournal.savedVars.entries and #LvxJournal.savedVars.entries > 0

        if needsMigration and oldHasEntries and not newHasEntries then
            for key, value in pairs(oldAccountWideVars) do
                if type(value) == "table" then
                    LvxJournal.savedVars[key] = DeepCopyTable(value)
                else
                    LvxJournal.savedVars[key] = value
                end
            end
            LvxJournal.savedVars.esouiServerMigrationDone = true
            Msg("Migrated account-wide journal data to this server: " .. tostring(worldName))
        else
            LvxJournal.savedVars.esouiServerMigrationDone = true
        end
    end

    LvxJournal.savedVars.profile = LvxJournal.savedVars.profile or {}
    LvxJournal.savedVars.theme = LvxJournal.savedVars.theme or "blank"
    LvxJournal.savedVars.pendingDeleteIndex = nil
    LvxJournal.savedVars.pendingDeleteArmed = nil
    LvxJournal.savedVars.stats = LvxJournal.savedVars.stats or {}
    LvxJournal.savedVars.stats.sessionMeters = 0
    LvxJournal.savedVars.stats.sessionEnemyKills = 0
    LvxJournal.savedVars.stats.sessionBossKills = 0
    LvxJournal.savedVars.stats.sessionGoldCollected = 0
    LvxJournal.savedVars.stats.enemyKills = tonumber(LvxJournal.savedVars.stats.enemyKills) or 0
    LvxJournal.savedVars.stats.bossKills = tonumber(LvxJournal.savedVars.stats.bossKills) or 0
    LvxJournal.savedVars.stats.goldCollected = tonumber(LvxJournal.savedVars.stats.goldCollected) or 0
    LvxJournal.savedVars.stats.lastKnownGold = GetJournalGoldAmountSafe() or tonumber(LvxJournal.savedVars.stats.lastKnownGold) or nil
    LvxJournal.savedVars.stats.tributeWins = tonumber(LvxJournal.savedVars.stats.tributeWins) or 0
    LvxJournal.savedVars.stats.tributeLosses = tonumber(LvxJournal.savedVars.stats.tributeLosses) or 0
    LvxJournal.savedVars.stats.tributeGames = tonumber(LvxJournal.savedVars.stats.tributeGames) or 0
    LvxJournal.savedVars.stats.tributeLastResult = LvxJournal.savedVars.stats.tributeLastResult or ""
    LvxJournal.savedVars.stats.tributeLastSource = LvxJournal.savedVars.stats.tributeLastSource or ""
    LvxJournal.savedVars.stats.tributeLastTime = LvxJournal.savedVars.stats.tributeLastTime or ""
    LvxJournal.savedVars.stats.sessionStart = GetTimeStamp and GetTimeStamp() or 0
    LvxJournal.savedVars.stats.statsPage = tonumber(LvxJournal.savedVars.stats.statsPage) or 1
    LvxJournal.savedVars.stats.codexPage = tonumber(LvxJournal.savedVars.stats.codexPage) or 1
    LvxJournal.savedVars.search = LvxJournal.savedVars.search or {}
    LvxJournal.savedVars.search.query = LvxJournal.savedVars.search.query or ""
    LvxJournal.savedVars.search.scope = LvxJournal.savedVars.search.scope or "All"
    LvxJournal.savedVars.search.page = tonumber(LvxJournal.savedVars.search.page) or 1
    LvxJournal.savedVars.search.results = {}
    LvxJournal.CreateWindow()
    SetupJournalMapPins()

    RegisterEventIfExists("QuestComplete", "EVENT_QUEST_COMPLETE", LvxJournal.OnQuestComplete)
    RegisterEventIfExists("QuestAdded", "EVENT_QUEST_ADDED", LvxJournal.OnQuestAdded)
    RegisterEventIfExists("PlayerDead", "EVENT_PLAYER_DEAD", LvxJournal.OnPlayerDead)
    RegisterEventIfExists("ZoneChanged", "EVENT_ZONE_CHANGED", LvxJournal.OnZoneChanged)
    RegisterEventIfExists("ZoneUpdate", "EVENT_ZONE_UPDATE", LvxJournal.OnZoneChanged)
    RegisterEventIfExists("Achievement", "EVENT_ACHIEVEMENT_AWARDED", LvxJournal.OnAchievementAwarded)
    RegisterCombatKillTracking()
    RegisterTributeTracking()
    RegisterGoldTracking()

    if em.RegisterForUpdate then
        em:RegisterForUpdate(LvxJournal.name .. "_BossNameCache", 5000, LvxJournal.RefreshBossNameCache)
    end

    SLASH_COMMANDS["/journal"] = LvxJournal.HandleSlash
    SLASH_COMMANDS["/lvxjournal"] = LvxJournal.HandleSlash

    if em.RegisterForUpdate then
        em:RegisterForUpdate(LvxJournal.name .. "_DistanceTracker", 2000, LvxJournal.TrackDistance)
    end

    zo_callLater(function() LvxJournal.OnZoneChanged() end, 3000)
    Msg("Loaded. Use /journal.")
end

em:RegisterForEvent(LvxJournal.name, EVENT_ADD_ON_LOADED, LvxJournal.OnAddOnLoaded)