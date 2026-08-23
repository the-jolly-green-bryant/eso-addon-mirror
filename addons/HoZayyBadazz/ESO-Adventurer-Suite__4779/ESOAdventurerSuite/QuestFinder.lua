-- ESO Adventurer Suite
-- Copyright (c) 2026 HoZayyBadazz. All Rights Reserved.
-- Proprietary source. Unauthorized redistribution, republication, rebranding,
-- or public distribution of modified/derivative versions is prohibited.
-- Private personal-use modifications are permitted. See LICENSE.txt.

local EPC = ESOProgressionCoach
EPC.QuestFinder = EPC.QuestFinder or {}
local Q = EPC.QuestFinder

Q.PAGE_SIZE = 10
Q.SCAN_MAX_ID = 15000
Q.SCAN_CHUNK = 250

local function lower(v) return string.lower(tostring(v or "")) end
local function trim(v)
    v = tostring(v or "")
    if zo_strtrim then return zo_strtrim(v) end
    return (v:gsub("^%s+", ""):gsub("%s+$", ""))
end
local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a, b, c, d = pcall(fn, ...)
    if not ok then return fallback end
    return a, b, c, d
end

-- A small hint table remains for well-known quest starters. The actual browser is
-- built from ESO's quest records at runtime instead of being capped to this list.
Q.curatedHints = {
    [lower("Soul Shriven in Coldharbour")] = {starter="The Hooded Figure / alliance starter city", access="BASE GAME", type="Main Story"},
    [lower("The Harborage")] = {starter="The Prophet", access="BASE GAME", type="Main Story"},
    [lower("The Demon Weapon")] = {starter="Abnur Tharn", access="BASE-GAME PROLOGUE", type="Prologue"},
    [lower("The Coven Conspiracy")] = {starter="Skald-King's Agent / Crown Store starter", access="BASE-GAME PROLOGUE", type="Prologue"},
    [lower("Orsinium")] = {starter="Stuga / Wrothgar introduction", access="ORSINIUM", type="Zone Story"},
    [lower("Divine Conundrum")] = {starter="Vvardenfell story introduction", access="MORROWIND", type="Zone Story"},
    [lower("The Queen's Decree")] = {starter="Razum-dar / Summerset introduction", access="SUMMERSET", type="Zone Story"},
    [lower("A Rage of Dragons")] = {starter="Northern Elsweyr story introduction", access="ELSWEYR", type="Zone Story"},
    [lower("The Gathering Storm")] = {starter="Western Skyrim story introduction", access="GREYMOOR", type="Zone Story"},
    [lower("A Mortal's Touch")] = {starter="Blackwood story introduction", access="BLACKWOOD", type="Zone Story"},
    [lower("No Regrets")] = {starter="High Isle story introduction", access="HIGH ISLE", type="Zone Story"},
    [lower("Fate's Proxy")] = {starter="Necrom story introduction", access="NECROM", type="Zone Story"},
    [lower("The Untraveled Road")] = {starter="Gold Road story introduction", access="GOLD ROAD", type="Zone Story"},
}

local function likelyInternalQuest(name)
    local s = lower(trim(name))
    if s == "" then return true end
    if string.find(s, "_outofdate", 1, true) then return true end
    if string.find(s, "debug quest", 1, true) then return true end
    if string.find(s, "dummy quest", 1, true) then return true end
    if string.find(s, "placeholder quest", 1, true) then return true end
    if string.find(s, "do not use", 1, true) then return true end
    if string.find(s, "bug check", 1, true) then return true end
    if s == "simple kill quest" then return true end
    if string.match(s, "^tm%d+") then return true end
    return false
end

local function questTypeText(questId)
    local questType = safe(GetQuestType, nil, questId)
    if questType ~= nil and type(GetString) == "function" then
        local ok, text = pcall(GetString, "SI_QUESTTYPE", questType)
        if ok and text and text ~= "" then return text end
    end
    return "Quest"
end

function Q:Initialize()
    self.searchText = ""
    self.filter = "NOT_STARTED"
    self.offset = 0
    self.selectedKey = nil
    self.lastView = nil
    self.index = {}
    self.indexByKey = {}
    self.scanNextId = 1
    self.scanDone = false
    self.scanStarted = false
end

function Q:StartScan()
    if self.scanStarted then return end
    self.scanStarted = true
    local function kickoff() self:ScanChunk() end
    if type(zo_callLater) == "function" then zo_callLater(kickoff, 25) else kickoff() end
end

function Q:ScanChunk()
    if self.scanDone then return end
    if type(GetQuestName) ~= "function" or type(GetQuestZoneId) ~= "function" then
        self.scanDone = true
        return
    end

    local firstId = self.scanNextId or 1
    local lastId = math.min(self.SCAN_MAX_ID, firstId + self.SCAN_CHUNK - 1)
    for questId = firstId, lastId do
        local name = trim(safe(GetQuestName, "", questId))
        if name ~= "" and not likelyInternalQuest(name) then
            local zoneId = tonumber(safe(GetQuestZoneId, 0, questId)) or 0
            local zone = zoneId > 0 and trim(safe(GetZoneNameById, "", zoneId)) or ""
            -- zoneId 0 is commonly used by obsolete/internal records, so exclude it
            -- from the discovery index rather than presenting it as a real quest.
            if zoneId > 0 and zone ~= "" then
                local key = lower(name) .. "|" .. tostring(zoneId)
                if not self.indexByKey[key] then
                    local hint = self.curatedHints[lower(name)]
                    local entry = {
                        key = "QUEST:" .. tostring(questId),
                        questId = questId,
                        name = name,
                        zoneId = zoneId,
                        zone = zone,
                        type = hint and hint.type or questTypeText(questId),
                        starter = hint and hint.starter or "Exact unaccepted quest-giver position is not exposed; route to the zone and follow local quest markers.",
                        access = hint and hint.access or "GAME QUEST INDEX",
                        dlc = hint and hint.access ~= "BASE GAME" or false,
                    }
                    self.indexByKey[key] = entry
                    self.index[#self.index + 1] = entry
                end
            end
        end
    end

    self.scanNextId = lastId + 1
    if self.scanNextId > self.SCAN_MAX_ID then
        self.scanDone = true
        table.sort(self.index, function(a, b)
            local an, bn = lower(a.name), lower(b.name)
            if an == bn then return lower(a.zone) < lower(b.zone) end
            return an < bn
        end)
        if EPC.RequestRefresh then EPC:RequestRefresh("quest-index-ready") end
        return
    end

    if (lastId % 1000) == 0 and EPC.RequestRefresh then EPC:RequestRefresh("quest-index-scan") end
    local function again() self:ScanChunk() end
    if type(zo_callLater) == "function" then zo_callLater(again, 20) else again() end
end

function Q:GetActiveQuestMap()
    local byId, byName = {}, {}
    local max = MAX_JOURNAL_QUESTS or 25
    if type(GetJournalQuestName) ~= "function" then return byId, byName end
    for i = 1, max do
        local name = trim(safe(GetJournalQuestName, "", i))
        if name ~= "" then
            local questId = tonumber(safe(GetJournalQuestId, 0, i)) or 0
            if questId > 0 then byId[questId] = i end
            byName[lower(name)] = i
        end
    end
    return byId, byName
end

function Q:GetCompletedQuestSet()
    local now = tonumber(safe(GetFrameTimeMilliseconds, 0)) or 0
    if self.completedCache and (now <= 0 or (now - (self.completedCacheAt or 0)) < 5000) then
        return self.completedCache
    end
    local done = {}
    if type(GetNextCompletedQuestId) == "function" then
        local last, safety = nil, 0
        while safety < 20000 do
            local questId = safe(GetNextCompletedQuestId, nil, last)
            if questId == nil then break end
            done[questId] = true
            last = questId
            safety = safety + 1
        end
    end
    self.completedCache, self.completedCacheAt = done, now
    return done
end

function Q:BuildEntries()
    local activeById, activeByName = self:GetActiveQuestMap()
    local completed = self:GetCompletedQuestSet()
    local entries, seenActive = {}, {}
    local query = lower(trim(self.searchText))

    for i = 1, #self.index do
        local src = self.index[i]
        local activeIndex = activeById[src.questId] or activeByName[lower(src.name)]
        if activeIndex then seenActive[activeIndex] = true end
        local isCompleted = completed[src.questId] == true
        local status = activeIndex and "ACTIVE" or (isCompleted and "COMPLETED" or "NOT STARTED")
        local include = self.filter == "ALL"
            or (self.filter == "ACTIVE" and activeIndex ~= nil)
            or (self.filter == "NOT_STARTED" and activeIndex == nil and not isCompleted)
        if include then
            local hay = lower(src.name .. " " .. src.zone .. " " .. src.type .. " " .. src.access .. " " .. tostring(src.questId))
            if query == "" or string.find(hay, query, 1, true) then
                entries[#entries + 1] = {
                    key = src.key, questId = src.questId, name = src.name, zoneId = src.zoneId, zone = src.zone,
                    starter = src.starter, type = src.type, access = src.access, dlc = src.dlc,
                    status = status, questIndex = activeIndex, completed = isCompleted,
                }
            end
        end
    end

    -- Always include accepted journal quests even if their quest ID sits outside the
    -- scanned range or uses a record filtered from the discovery index.
    if self.filter == "ACTIVE" or self.filter == "ALL" then
        local max = MAX_JOURNAL_QUESTS or 25
        for i = 1, max do
            local name = trim(safe(GetJournalQuestName, "", i))
            if name ~= "" and not seenActive[i] then
                local questId = tonumber(safe(GetJournalQuestId, 0, i)) or 0
                local zone = "Accepted quest"
                local zoneName = safe(GetJournalQuestLocationInfo, "", i)
                if zoneName and zoneName ~= "" then zone = zoneName end
                local hay = lower(name .. " " .. zone .. " " .. tostring(questId))
                if query == "" or string.find(hay, query, 1, true) then
                    entries[#entries + 1] = {
                        key = "JOURNAL:" .. tostring(i), questId = questId, name = name, zone = zone,
                        starter = "Already accepted", type = "Journal Quest", access = "ACTIVE JOURNAL",
                        dlc = false, status = "ACTIVE", questIndex = i,
                    }
                end
            end
        end
    end

    table.sort(entries, function(a, b)
        local an, bn = lower(a.name), lower(b.name)
        if an == bn then return lower(a.zone) < lower(b.zone) end
        return an < bn
    end)
    return entries
end

function Q:BuildView()
    if not self.scanStarted then self:StartScan() end
    local entries = self:BuildEntries()
    local maxOffset = math.max(0, #entries - self.PAGE_SIZE)
    self.offset = math.max(0, math.min(self.offset or 0, maxOffset))
    local rows = {}
    for i = 1, self.PAGE_SIZE do
        local e = entries[self.offset + i]
        if e then rows[#rows + 1] = e end
    end
    local selected = nil
    if self.selectedKey then
        for i = 1, #entries do if entries[i].key == self.selectedKey then selected = entries[i] break end end
    end
    local progress = self.scanDone and "INDEX READY" or string.format("SCANNING %d/%d", math.min(self.scanNextId or 1, self.SCAN_MAX_ID), self.SCAN_MAX_ID)
    local view = {
        header = "QUEST JOURNAL",
        title = "Find quests you have not started",
        description = "Browse a runtime index of ESO quest records instead of a short curated list. Select a quest to route toward its zone. ESO does not expose one global 'currently obtainable quest' iterator, so retired/internal records are filtered on a best-effort basis.",
        filter = self.filter, searchText = self.searchText, rows = rows, total = #entries, offset = self.offset,
        selected = selected, scanDone = self.scanDone, scanProgress = progress, indexed = #self.index,
        stats = {
            {label="FILTER", value=self.filter == "NOT_STARTED" and "NOT STARTED" or self.filter},
            {label="MATCHES", value=tostring(#entries)},
            {label="INDEX", value=self.scanDone and tostring(#self.index) or progress},
            {label="SELECTED", value=selected and selected.status or "NONE"},
        },
    }
    self.lastView = view
    return view
end

function Q:SetFilter(filter)
    filter = string.upper(tostring(filter or "NOT_STARTED"))
    if filter == "NOT STARTED" then filter = "NOT_STARTED" end
    if filter ~= "NOT_STARTED" and filter ~= "ACTIVE" and filter ~= "ALL" then return false end
    self.filter, self.offset, self.selectedKey = filter, 0, nil
    return true
end

function Q:SetSearch(text)
    self.searchText, self.offset, self.selectedKey = tostring(text or ""), 0, nil
end

function Q:Scroll(delta)
    delta = tonumber(delta) or 0
    local view = self.lastView or self:BuildView()
    local maxOffset = math.max(0, (view.total or 0) - self.PAGE_SIZE)
    self.offset = math.max(0, math.min(maxOffset, (self.offset or 0) + delta))
    if EPC.UI and EPC.saved and EPC.saved.activeTab == "QUESTS" then EPC.UI:RenderQuest(self:BuildView()) end
end

function Q:AssistAcceptedQuest2511(entry, setMapZone)
    if not entry or not entry.questIndex then return false end
    local questIndex = tonumber(entry.questIndex)
    if not questIndex then return false end

    if setMapZone and type(SetMapToQuestZone) == "function" then
        pcall(SetMapToQuestZone, questIndex)
    end
    if TRACK_TYPE_QUEST ~= nil and type(SetTrackedIsAssisted) == "function" then
        if type(SetTracked) == "function" then
            pcall(SetTracked, TRACK_TYPE_QUEST, true, questIndex, 0)
        end
        pcall(SetTrackedIsAssisted, TRACK_TYPE_QUEST, true, questIndex, 0)
    end

    -- Refresh the Suite overlay immediately instead of waiting for ESO's
    -- tracking event/tick. A short follow-up refresh catches clients that
    -- apply the assisted-tracker state one frame later.
    if EPC.ActiveQuest and type(EPC.ActiveQuest.Refresh) == "function" then
        EPC.ActiveQuest:Refresh()
        if type(zo_callLater) == "function" then
            zo_callLater(function()
                if EPC.ActiveQuest and type(EPC.ActiveQuest.Refresh) == "function" then
                    EPC.ActiveQuest:Refresh()
                end
            end, 60)
        end
    end
    return true
end

function Q:SelectRow(index)
    local view = self.lastView or self:BuildView()
    local entry = view.rows and view.rows[index]
    if not entry then return end
    self.selectedKey = entry.key

    -- Selecting an already-accepted quest in Quest Finder now makes it the
    -- assisted/tracked quest immediately, so the Active Quest HUD switches
    -- to the same quest without requiring a separate TRAVEL/ROUTE click.
    if entry.questIndex then
        self:AssistAcceptedQuest2511(entry, false)
    end

    if EPC.UI and EPC.saved and EPC.saved.activeTab == "QUESTS" then EPC.UI:RenderQuest(self:BuildView()) end
end

function Q:RouteSelected()
    local view = self.lastView or self:BuildView()
    local q = view.selected
    if not q then EPC:Print("Select a quest first.") return end

    if q.questIndex then
        self:AssistAcceptedQuest2511(q, true)
        EPC:Print("Assisting active quest: " .. q.name)
        return
    end

    EPC.saved.questDiscoveryTarget = {name=q.name, zone=q.zone, zoneId=q.zoneId, starter=q.starter, access=q.access}
    EPC.saved.activeTab = "MAP"
    EPC.saved.travelMode = "SHRINES"
    EPC.saved.travelPage = 1
    EPC.saved.travelBookPage = 1
    if EPC.Travel then EPC.Travel.selectedKey = nil end
    EPC:RefreshNow("quest-discovery-route")
    EPC:Print(string.format("Quest route: %s - %s. %s", q.name, q.zone, q.starter))
end

-- v0.25.12: make the Quest Finder selection authoritative for the Suite HUD.
local easLegacyAssistAcceptedQuest_2512 = Q.AssistAcceptedQuest2511
function Q:AssistAcceptedQuest2511(entry, setMapZone)
    if entry and entry.questIndex and EPC.ActiveQuest and EPC.ActiveQuest.SetSelectedQuest2512 then
        EPC.ActiveQuest:SetSelectedQuest2512(entry.questIndex, entry.questId, entry.name, "QUEST_FINDER")
    end
    return easLegacyAssistAcceptedQuest_2512(self, entry, setMapZone)
end


-- v0.25.16: Suite quest-source priority. Selecting an accepted quest remembers
-- it in the appropriate source slot, but only the source selected in Settings
-- is allowed to become ESO's assisted quest.
function Q:AssistAcceptedQuest2511(entry, setMapZone)
    if not entry or not entry.questIndex then return false end
    local questIndex = tonumber(entry.questIndex)
    if not questIndex then return false end

    if setMapZone and type(SetMapToQuestZone) == "function" then
        pcall(SetMapToQuestZone, questIndex)
    end

    if EPC.ActiveQuest and EPC.ActiveQuest.SetSelectedQuest2512 then
        EPC.ActiveQuest:SetSelectedQuest2512(questIndex, entry.questId, entry.name, "QUEST_FINDER")
    end
    return true
end
