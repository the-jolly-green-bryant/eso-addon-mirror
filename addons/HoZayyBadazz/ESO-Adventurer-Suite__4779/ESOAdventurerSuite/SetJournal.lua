-- ESO Adventurer Suite
-- Copyright (c) 2026 HoZayyBadazz. All Rights Reserved.
-- Proprietary source. Unauthorized redistribution, republication, rebranding,
-- or public distribution of modified/derivative versions is prohibited.
-- Private personal-use modifications are permitted. See LICENSE.txt.

local EPC = ESOProgressionCoach
EPC.SetJournal = EPC.SetJournal or {}
local J = EPC.SetJournal

J.PAGE_SIZE = 6
J.validFilters = { ALL=true, OVERLAND=true, DUNGEON=true, TRIAL=true }

local function lower(v) return string.lower(tostring(v or "")) end
local function trim(v)
    v = tostring(v or "")
    if zo_strtrim then return zo_strtrim(v) end
    return (v:gsub("^%s+", ""):gsub("%s+$", ""))
end
local function num(v, fallback) return tonumber(v) or tonumber(fallback) or 0 end

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a, b, c, d = pcall(fn, ...)
    if not ok then return fallback end
    return a, b, c, d
end

local function contains(haystack, needle)
    haystack, needle = lower(haystack), lower(needle)
    return needle ~= "" and string.find(haystack, needle, 1, true) ~= nil
end

function J:Initialize()
    self.searchText = ""
    self.filter = (EPC.saved and EPC.saved.setJournalFilter) or "ALL"
    if not self.validFilters[self.filter] then self.filter = "ALL" end
    self.page = 1
    self.selectedId = nil
    self.index = nil
    self.categoryPathCache = {}
    self.pieceSummaryCache = {}
    self.lastView = nil
end

function J:GetCategoryPath(setId)
    setId = num(setId, 0)
    if setId <= 0 then return {} end
    if self.categoryPathCache[setId] then return self.categoryPathCache[setId] end

    local path, seen = {}, {}
    local categoryId = safe(GetItemSetCollectionCategoryId, 0, setId)
    categoryId = num(categoryId, 0)
    local safety = 0
    while categoryId > 0 and not seen[categoryId] and safety < 12 do
        safety = safety + 1
        seen[categoryId] = true
        local name = trim(safe(GetItemSetCollectionCategoryName, "", categoryId))
        if name ~= "" then table.insert(path, 1, name) end
        categoryId = num(safe(GetItemSetCollectionCategoryParentId, 0, categoryId), 0)
    end
    self.categoryPathCache[setId] = path
    return path
end

function J:GetSourceText(setId)
    local path = self:GetCategoryPath(setId)
    if #path == 0 then return "Source category unavailable" end
    return table.concat(path, " > ")
end

function J:BuildIndex()
    if self.index then return self.index end
    local index = {}
    if type(GetNextItemSetCollectionId) ~= "function" or type(GetItemSetName) ~= "function" then
        self.index = index
        return index
    end

    local last, safety = nil, 0
    while safety < 10000 do
        local setId = safe(GetNextItemSetCollectionId, nil, last)
        if setId == nil then break end
        safety = safety + 1
        last = setId
        local name = trim(safe(GetItemSetName, "", setId))
        if name ~= "" then
            local path = self:GetCategoryPath(setId)
            index[#index + 1] = {
                setId = setId,
                name = name,
                path = path,
                sourceText = #path > 0 and table.concat(path, " > ") or "Source category unavailable",
            }
        end
    end
    table.sort(index, function(a, b) return lower(a.name) < lower(b.name) end)
    self.index = index
    return index
end

function J:GetProgress(setId)
    local total = type(GetNumItemSetCollectionPieces) == "function" and num(safe(GetNumItemSetCollectionPieces, 0, setId), 0) or 0
    local unlocked = type(GetNumItemSetCollectionSlotsUnlocked) == "function" and num(safe(GetNumItemSetCollectionSlotsUnlocked, 0, setId), 0) or 0
    return unlocked, total
end

function J:GetPieceSummary(setId)
    if self.pieceSummaryCache[setId] then return self.pieceSummaryCache[setId] end
    local summary = { armor=0, weapons=0, other=0 }
    local total = type(GetNumItemSetCollectionPieces) == "function" and num(safe(GetNumItemSetCollectionPieces, 0, setId), 0) or 0
    for i = 1, total do
        local pieceId = safe(GetItemSetCollectionPieceInfo, nil, setId, i)
        if pieceId then
            local link = safe(GetItemSetCollectionPieceItemLink, "", pieceId, LINK_STYLE_DEFAULT or LINK_STYLE_BRACKETS or 0, ITEM_TRAIT_TYPE_NONE or 0)
            if link and link ~= "" then
                local weaponType = type(GetItemLinkWeaponType) == "function" and num(safe(GetItemLinkWeaponType, 0, link), 0) or 0
                local armorType = type(GetItemLinkArmorType) == "function" and num(safe(GetItemLinkArmorType, 0, link), 0) or 0
                local isWeapon = WEAPONTYPE_NONE ~= nil and weaponType ~= WEAPONTYPE_NONE or weaponType > 0
                local isArmor = ARMORTYPE_NONE ~= nil and armorType ~= ARMORTYPE_NONE or armorType > 0
                if isWeapon then summary.weapons = summary.weapons + 1
                elseif isArmor then summary.armor = summary.armor + 1
                else summary.other = summary.other + 1 end
            else
                summary.other = summary.other + 1
            end
        end
    end
    self.pieceSummaryCache[setId] = summary
    return summary
end

function J:MatchesFilter(entry)
    if self.filter == "ALL" then return true end
    local source = lower(entry.sourceText)
    if self.filter == "OVERLAND" then return contains(source, "overland") end
    if self.filter == "DUNGEON" then return contains(source, "dungeon") end
    if self.filter == "TRIAL" then return contains(source, "trial") end
    return true
end

function J:BuildEntries()
    local query = lower(trim(self.searchText))
    local entries = {}
    local index = self:BuildIndex()
    for i = 1, #index do
        local entry = index[i]
        if self:MatchesFilter(entry) then
            local hay = lower(entry.name .. " " .. entry.sourceText)
            if query == "" or string.find(hay, query, 1, true) then
                entries[#entries + 1] = entry
            end
        end
    end
    return entries
end

function J:BuildRow(entry)
    local unlocked, total = self:GetProgress(entry.setId)
    local pieces = self:GetPieceSummary(entry.setId)
    local kind = {}
    if pieces.armor > 0 then kind[#kind + 1] = tostring(pieces.armor) .. " armor" end
    if pieces.weapons > 0 then kind[#kind + 1] = tostring(pieces.weapons) .. " weapons" end
    if pieces.other > 0 then kind[#kind + 1] = tostring(pieces.other) .. " jewelry/other" end
    return {
        setId = entry.setId,
        name = entry.name,
        sourceText = entry.sourceText,
        path = entry.path,
        unlocked = unlocked,
        total = total,
        kindText = #kind > 0 and table.concat(kind, " / ") or "Set pieces",
    }
end

function J:BuildView()
    local entries = self:BuildEntries()
    local pageCount = math.max(1, math.ceil(#entries / self.PAGE_SIZE))
    self.page = math.max(1, math.min(num(self.page, 1), pageCount))
    local first = ((self.page - 1) * self.PAGE_SIZE) + 1
    local rows = {}
    for i = 0, self.PAGE_SIZE - 1 do
        local entry = entries[first + i]
        if entry then rows[#rows + 1] = self:BuildRow(entry) end
    end

    local selected = nil
    if self.selectedId then
        for i = 1, #entries do
            if entries[i].setId == self.selectedId then selected = self:BuildRow(entries[i]) break end
        end
    end
    if self.selectedId and not selected then self.selectedId = nil end

    local title = selected and selected.name or (trim(self.searchText) ~= "" and ("Search: " .. self.searchText) or "Find an armor or weapon set")
    local description
    if selected then
        description = string.format("%s. Collection progress %d/%d. Use ROUTE SOURCE for a discovered wayshrine match or ZONE QUESTS for quests in the closest matching source zone.", selected.sourceText, selected.unlocked, selected.total)
    else
        description = "Search ESO's live Item Set Collection by set name or source category. Select a set to see collection progress, its armor/weapon mix, and routing options."
    end

    local stats = {
        { label="FILTER", value=self.filter },
        { label="MATCHES", value=tostring(#entries) },
        { label="COLLECTED", value=selected and string.format("%d/%d", selected.unlocked, selected.total) or "SELECT A SET" },
        { label="PIECES", value=selected and selected.kindText or "ARMOR + WEAPONS" },
    }

    local view = {
        header = "EQUIPMENT SET JOURNAL",
        title = title,
        description = description,
        filter = self.filter,
        searchText = self.searchText,
        rows = rows,
        total = #entries,
        page = self.page,
        pageCount = pageCount,
        selected = selected,
        stats = stats,
        hint = selected and ("Source: " .. selected.sourceText) or "Press SEARCH and type a set name, or browse with the source filters.",
    }
    self.lastView = view
    return view
end

function J:SetFilter(filter)
    filter = string.upper(tostring(filter or "ALL"))
    if not self.validFilters[filter] then return false end
    self.filter = filter
    self.page = 1
    self.selectedId = nil
    if EPC.saved then EPC.saved.setJournalFilter = filter end
    EPC:RefreshNow("set-journal-filter")
    return true
end

function J:SetSearch(text)
    self.searchText = trim(text)
    self.page = 1
    self.selectedId = nil
    EPC:RefreshNow("set-journal-search")
end

function J:ClearSearch()
    self:SetSearch("")
end

function J:ChangePage(delta)
    self.page = math.max(1, num(self.page, 1) + num(delta, 0))
    self.selectedId = nil
    EPC:RefreshNow("set-journal-page")
end

function J:SelectRow(index)
    local view = self.lastView or self:BuildView()
    local row = view.rows and view.rows[num(index, 0)]
    if not row then return end
    self.selectedId = row.setId
    EPC:RefreshNow("set-journal-select")
end

function J:PromptSearch()
    if type(StartChatInput) == "function" then
        StartChatInput("/esosuite set ")
    else
        EPC:Print("Search with /esosuite set <set name>.")
    end
end

local GENERIC_SOURCE_NAMES = {
    ["overland sets"] = true, ["dungeon sets"] = true, ["trial sets"] = true,
    ["arena sets"] = true, ["pvp sets"] = true, ["crafted sets"] = true,
    ["monster masks"] = true, ["item sets"] = true, ["sets"] = true,
}

function J:FindTravelMatch(selected)
    if not selected or not EPC.Travel or type(EPC.Travel.GetWayshrines) ~= "function" then return nil, nil end
    local entries = EPC.Travel:GetWayshrines(EPC.lastSnapshot or {})
    local best, bestIndex, bestScore = nil, nil, 0
    local path = selected.path or self:GetCategoryPath(selected.setId)
    for i = 1, #entries do
        local zone = lower(entries[i].zoneName)
        for p = 1, #path do
            local part = lower(path[p])
            if part ~= "" and not GENERIC_SOURCE_NAMES[part] then
                local score = 0
                if zone == part then score = 100
                elseif string.find(part, zone, 1, true) or string.find(zone, part, 1, true) then score = 65 end
                if score > bestScore then best, bestIndex, bestScore = entries[i], i, score end
            end
        end
    end
    return best, bestIndex
end

function J:FastTravelSelected()
    local view = self.lastView or self:BuildView()
    local selected = view.selected
    if not selected then EPC:Print("Select a set first.") return end
    if not EPC.Travel or type(EPC.Travel.TravelToWayshrineNode) ~= "function" then
        EPC:Print("Fast travel is unavailable.")
        return
    end

    local entry = self:FindTravelMatch(selected)
    if not entry then
        EPC:Print("No discovered wayshrine matched this set's ESO source category. Source: " .. tostring(selected.sourceText))
        return
    end

    EPC:Print(string.format("Set travel: %s -> %s, %s.", selected.name, entry.name, entry.zoneName))
    EPC.Travel:TravelToWayshrineNode(entry.nodeIndex, entry.name)
end

function J:RouteSelected()
    local view = self.lastView or self:BuildView()
    local selected = view.selected
    if not selected then EPC:Print("Select a set first.") return end
    local entry, index = self:FindTravelMatch(selected)
    if not entry then
        EPC:Print("No discovered wayshrine matched this set's ESO source category. Source: " .. tostring(selected.sourceText))
        return
    end

    EPC.saved.activeTab = "MAP"
    EPC.saved.travelMode = "SHRINES"
    EPC.saved.travelPage = math.max(1, math.ceil(index / (EPC.Travel.PAGE_SIZE or 4)))
    EPC.saved.travelBookPage = math.max(1, math.ceil(index / (EPC.Travel.BOOK_PAGE_SIZE or 8)))
    EPC.Travel.selectedKey = entry.key
    local focused = EPC.Travel.GetFocusedQuest and EPC.Travel:GetFocusedQuest(EPC.lastSnapshot or {}) or nil
    EPC.Travel.lastFocusedQuestKey = focused and focused.identityKey or ""
    EPC:RefreshNow("set-journal-route")
    EPC:Print(string.format("Set route: %s -> %s, %s.", selected.name, entry.name, entry.zoneName))
end

function J:OpenSourceQuests()
    local view = self.lastView or self:BuildView()
    local selected = view.selected
    if not selected then EPC:Print("Select a set first.") return end
    if not EPC.QuestFinder then EPC:Print("Quest journal is unavailable.") return end

    local path = selected.path or self:GetCategoryPath(selected.setId)
    local bestZone = nil
    -- Prefer the deepest non-generic collection category; it is normally the
    -- actual zone/dungeon/trial name in ESO's Item Set Collection.
    for i = #path, 1, -1 do
        local part = trim(path[i])
        if part ~= "" and not GENERIC_SOURCE_NAMES[lower(part)] then
            bestZone = part
            break
        end
    end
    if not bestZone then
        EPC:Print("No quest-search zone could be inferred from this set source: " .. tostring(selected.sourceText))
        return
    end

    EPC.QuestFinder:SetSearch(bestZone)
    EPC.QuestFinder:SetFilter("ALL")
    EPC.saved.activeTab = "QUESTS"
    EPC:RefreshNow("set-journal-zone-quests")
    EPC:Print("Showing quest records matching set source: " .. bestZone .. ". These quests are navigation leads, not guaranteed set-piece rewards.")
end
