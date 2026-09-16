-- ESO Adventurer Suite
-- Live Market Engine: high-freshness Guild Trader capture, TTC deep integration,
-- persistent top-listing cache, watch alerts, trader health, and Teleporter route tools.
--
-- This module intentionally performs no network I/O. It consumes ESO's live Guild
-- Trader search results plus already-loaded TTC observations. Global TTC listing
-- search can be added later as a provider if sanctioned access becomes available.

local EPC = ESOProgressionCoach
if not EPC or not EPC.MarketPriceChecker then return end
local M = EPC.MarketPriceChecker
if M._marketLiveEngine029687 then return end
M._marketLiveEngine029687 = true

EPC.defaults = EPC.defaults or {}
EPC.defaults.marketLiveAutoScanTTC029687 = true
EPC.defaults.marketLiveFreshMinutes029687 = 30
EPC.defaults.marketLiveTravelMaxAgeMinutes029687 = 60
EPC.defaults.marketLiveRetentionDays029687 = 7
EPC.defaults.marketLiveMaxListingsPerItem029687 = 24
EPC.defaults.marketLiveMaxCachedItems029687 = 2400

local NAME = (EPC.name or "ESOAdventurerSuite") .. "_MarketLive029687"
local GOLD = "|cFFD700"
local GREEN = "|c66FF66"
local CYAN = "|c66CCFF"
local YELLOW = "|cFFFF66"
local GREY = "|cA0A0A0"
local RESET = "|r"

local function safeNumber(value)
    local n = tonumber(value)
    if not n or n ~= n or n == math.huge or n == -math.huge then return nil end
    return n
end

local function safeCall(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a, b, c, d, e, f, g, h, i, j = pcall(fn, ...)
    if not ok then return fallback end
    return a, b, c, d, e, f, g, h, i, j
end

local function now()
    return safeNumber(safeCall(GetTimeStamp, 0)) or 0
end

local function clean(value)
    local text = tostring(value or "")
    if type(zo_strformat) == "function" then
        local ok, formatted = pcall(zo_strformat, "<<1>>", text)
        if ok and type(formatted) == "string" and formatted ~= "" then text = formatted end
    end
    text = text:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
    text = text:gsub("[%c]+", " "):gsub("%s+", " ")
    return text:gsub("^%s+", ""):gsub("%s+$", "")
end

local function lower(value)
    return string.lower(clean(value))
end

local function formatAge(seconds)
    seconds = math.max(0, math.floor(safeNumber(seconds) or 0))
    if seconds < 60 then return tostring(seconds) .. "s" end
    local minutes = math.floor(seconds / 60)
    if minutes < 60 then return tostring(minutes) .. "m" end
    local hours = math.floor(minutes / 60)
    if hours < 48 then return tostring(hours) .. "h " .. tostring(minutes % 60) .. "m" end
    local days = math.floor(hours / 24)
    return tostring(days) .. "d " .. tostring(hours % 24) .. "h"
end

local function formatNumber(value)
    local n = safeNumber(value)
    if not n then return "-" end
    n = math.floor(n + 0.5)
    if type(ZO_CommaDelimitDecimalNumber) == "function" then
        local ok, text = pcall(ZO_CommaDelimitDecimalNumber, n)
        if ok and text then return tostring(text) end
    end
    local digits = tostring(math.abs(n))
    local sign = n < 0 and "-" or ""
    while true do
        local nextDigits, count = digits:gsub("^(%d+)(%d%d%d)", "%1,%2")
        digits = nextDigits
        if count == 0 then break end
    end
    return sign .. digits
end

local function settingNumber(key, defaultValue, minimum, maximum)
    local saved = EPC.saved or {}
    local value = safeNumber(saved[key]) or defaultValue
    if minimum then value = math.max(minimum, value) end
    if maximum then value = math.min(maximum, value) end
    return value
end

local function freshSeconds()
    return settingNumber("marketLiveFreshMinutes029687", 30, 1, 1440) * 60
end

local function travelFreshSeconds()
    return settingNumber("marketLiveTravelMaxAgeMinutes029687", 60, 1, 10080) * 60
end

local function retentionSeconds()
    return settingNumber("marketLiveRetentionDays029687", 7, 1, 30) * 24 * 60 * 60
end

local function maxListingsPerItem()
    return math.floor(settingNumber("marketLiveMaxListingsPerItem029687", 24, 5, 60))
end

local function maxCachedItems()
    return math.floor(settingNumber("marketLiveMaxCachedItems029687", 2400, 250, 8000))
end

local function itemKey(itemLink)
    if type(M.GetMarketItemKey029683) == "function" then
        local ok, key = pcall(M.GetMarketItemKey029683, M, itemLink)
        if ok and key then return key end
    end
    itemLink = tostring(itemLink or "")
    if itemLink == "" then return nil end
    local payload = itemLink:match("|H%d+:item:([^|]+)|h")
    return payload and ("raw:" .. payload) or ("raw:" .. itemLink)
end

local function currentTraderContext()
    local guildId, guildName = 0, ""
    if type(GetCurrentTradingHouseGuildDetails) == "function" then
        local ok, id, name = pcall(GetCurrentTradingHouseGuildDetails)
        if ok then
            guildId = safeNumber(id) or 0
            guildName = clean(name)
        end
    end

    local kioskId = nil
    local ttc = rawget(_G, "TamrielTradeCentre")
    if type(ttc) == "table" and type(ttc.GetCurrentKioskID) == "function" then
        local ok, id = pcall(ttc.GetCurrentKioskID, ttc)
        if ok then kioskId = safeNumber(id) end
    end

    local traderName = ""
    if type(GetUnitName) == "function" then
        local ok, value = pcall(GetUnitName, "interact")
        if ok then traderName = clean(value) end
    end
    if traderName == "" and type(GetRawUnitName) == "function" then
        local ok, value = pcall(GetRawUnitName, "interact")
        if ok then traderName = clean(value) end
    end

    local locationName = ""
    if type(GetPlayerLocationName) == "function" then
        local ok, value = pcall(GetPlayerLocationName)
        if ok then locationName = clean(value) end
    end

    local zoneName = ""
    if type(GetPlayerActiveZoneName) == "function" then
        local ok, value = pcall(GetPlayerActiveZoneName)
        if ok then zoneName = clean(value) end
    end

    return {
        guildId = guildId,
        guildName = guildName,
        kioskId = kioskId,
        traderName = traderName,
        locationName = locationName,
        zoneName = zoneName,
    }
end

local function traderIdentity(record)
    if type(record) ~= "table" then return nil end
    local kioskId = safeNumber(record.kioskId)
    local guild = lower(record.guildName)
    if kioskId then return "k:" .. tostring(math.floor(kioskId)) .. "|g:" .. guild end
    local location = lower(record.locationName)
    local zone = lower(record.zoneName)
    if guild ~= "" then return "g:" .. guild .. "|l:" .. location .. "|z:" .. zone end
    local trader = lower(record.traderName)
    if trader ~= "" then return "t:" .. trader .. "|l:" .. location .. "|z:" .. zone end
    return nil
end

local function copyRecord(record)
    local out = {}
    for key, value in pairs(record or {}) do
        if type(value) ~= "table" then out[key] = value end
    end
    return out
end

local function isRecordExpired(record, currentTime)
    if type(record) ~= "table" then return true end
    currentTime = currentTime or now()
    local expireAt = safeNumber(record.expireAt)
    if expireAt and expireAt > 0 and expireAt <= currentTime then return true end
    local seenAt = safeNumber(record.seenAt) or 0
    if seenAt > 0 and currentTime - seenAt > retentionSeconds() then return true end
    return false
end

local function liveCache()
    EPC.saved = EPC.saved or {}
    if type(EPC.saved.marketLiveTopCache029687) ~= "table" then
        EPC.saved.marketLiveTopCache029687 = {}
    end
    return EPC.saved.marketLiveTopCache029687
end

local function healthRoot()
    EPC.saved = EPC.saved or {}
    if type(EPC.saved.marketLiveTraderHealth029687) ~= "table" then
        EPC.saved.marketLiveTraderHealth029687 = { traders = {}, locations = {} }
    end
    local root = EPC.saved.marketLiveTraderHealth029687
    root.traders = type(root.traders) == "table" and root.traders or {}
    root.locations = type(root.locations) == "table" and root.locations or {}
    return root
end

local function watchRoot()
    EPC.saved = EPC.saved or {}
    if type(EPC.saved.marketLiveWatchlist029687) ~= "table" then
        EPC.saved.marketLiveWatchlist029687 = {}
    end
    return EPC.saved.marketLiveWatchlist029687
end

local function routeState()
    EPC.saved = EPC.saved or {}
    if type(EPC.saved.marketLiveRoute029687) ~= "table" then
        EPC.saved.marketLiveRoute029687 = { active = false, paused = false, index = 1, visited = {} }
    end
    local state = EPC.saved.marketLiveRoute029687
    state.visited = type(state.visited) == "table" and state.visited or {}
    return state
end

local function trimLiveGroup(group)
    if type(group) ~= "table" then return end
    group.rows = type(group.rows) == "table" and group.rows or {}
    local currentTime = now()
    local rows = {}
    for identity, record in pairs(group.rows) do
        if isRecordExpired(record, currentTime) then
            group.rows[identity] = nil
        else
            rows[#rows + 1] = { identity = identity, record = record }
        end
    end
    table.sort(rows, function(a, b)
        local ap = safeNumber(a.record.unitPrice) or math.huge
        local bp = safeNumber(b.record.unitPrice) or math.huge
        if ap ~= bp then return ap < bp end
        return (safeNumber(a.record.seenAt) or 0) > (safeNumber(b.record.seenAt) or 0)
    end)
    local limit = maxListingsPerItem()
    for i = limit + 1, #rows do
        group.rows[rows[i].identity] = nil
    end
end

function M:PruneLiveMarketCache029687()
    local root = liveCache()
    local groups = {}
    for key, group in pairs(root) do
        if type(group) ~= "table" then
            root[key] = nil
        else
            trimLiveGroup(group)
            if next(group.rows or {}) == nil then
                root[key] = nil
            else
                groups[#groups + 1] = { key = key, lastSeen = safeNumber(group.lastSeen) or 0 }
            end
        end
    end
    local limit = maxCachedItems()
    if #groups > limit then
        table.sort(groups, function(a, b) return a.lastSeen > b.lastSeen end)
        for i = limit + 1, #groups do root[groups[i].key] = nil end
    end
    self.marketLiveStoresSincePrune029687 = 0
end

function M:StoreLiveTopListing029687(record)
    if type(record) ~= "table" or type(record.itemLink) ~= "string" or record.itemLink == "" then return false end
    local key = itemKey(record.itemLink)
    local identity = traderIdentity(record)
    local unitPrice = safeNumber(record.unitPrice)
    if not key or not identity or not unitPrice or unitPrice <= 0 then return false end
    local currentTime = now()
    if isRecordExpired(record, currentTime) then return false end

    local root = liveCache()
    local group = root[key]
    if type(group) ~= "table" then
        group = { itemLink = record.itemLink, lastSeen = 0, rows = {} }
        root[key] = group
    end
    group.rows = type(group.rows) == "table" and group.rows or {}

    local seenAt = safeNumber(record.seenAt) or currentTime
    local old = group.rows[identity]
    local replace = old == nil or isRecordExpired(old, currentTime)
    if old and not replace then
        local oldSeen = safeNumber(old.seenAt) or 0
        local oldPrice = safeNumber(old.unitPrice) or math.huge
        replace = seenAt > oldSeen or (seenAt == oldSeen and unitPrice < oldPrice)
    end

    if replace then
        group.rows[identity] = {
            itemLink = record.itemLink,
            unitPrice = unitPrice,
            totalPrice = safeNumber(record.totalPrice),
            amount = math.max(1, safeNumber(record.amount) or 1),
            sellerName = clean(record.sellerName),
            guildName = clean(record.guildName),
            guildId = safeNumber(record.guildId),
            kioskId = safeNumber(record.kioskId),
            traderName = clean(record.traderName),
            locationName = clean(record.locationName),
            zoneName = clean(record.zoneName),
            seenAt = seenAt,
            expireAt = safeNumber(record.expireAt),
            source = clean(record.source ~= "" and record.source or "EAS LIVE"),
            uid = record.uid,
        }
    end

    group.itemLink = record.itemLink
    group.lastSeen = math.max(safeNumber(group.lastSeen) or 0, seenAt)
    trimLiveGroup(group)

    self.marketLiveStoresSincePrune029687 = (self.marketLiveStoresSincePrune029687 or 0) + 1
    if self.marketLiveStoresSincePrune029687 >= 1500 then
        if type(zo_callLater) == "function" then
            if not self.marketLivePruneQueued029687 then
                self.marketLivePruneQueued029687 = true
                zo_callLater(function()
                    if EPC.MarketPriceChecker then
                        EPC.MarketPriceChecker.marketLivePruneQueued029687 = false
                        EPC.MarketPriceChecker:PruneLiveMarketCache029687()
                    end
                end, 25)
            end
        else
            self:PruneLiveMarketCache029687()
        end
    end

    self:CheckLiveWatch029687(group.rows[identity])
    return true
end

local baseStorePersistent029687 = M.StorePersistentTraderListing029683
if type(baseStorePersistent029687) == "function" then
    function M:StorePersistentTraderListing029683(record)
        local result = baseStorePersistent029687(self, record)
        self:StoreLiveTopListing029687(record)
        return result
    end
end

local baseComparable029687 = M.GetComparableTraderListings029683
function M:GetComparableTraderListings029683(itemLink, limit)
    local merged = {}
    local function accept(record)
        if type(record) ~= "table" or isRecordExpired(record) then return end
        local identity = traderIdentity(record)
        if not identity then return end
        local old = merged[identity]
        if not old then
            merged[identity] = copyRecord(record)
            return
        end
        local seenAt = safeNumber(record.seenAt) or 0
        local oldSeen = safeNumber(old.seenAt) or 0
        if seenAt > oldSeen or (seenAt == oldSeen and (safeNumber(record.unitPrice) or math.huge) < (safeNumber(old.unitPrice) or math.huge)) then
            merged[identity] = copyRecord(record)
        end
    end

    if type(baseComparable029687) == "function" then
        local ok, rows = pcall(baseComparable029687, self, itemLink, 60)
        if ok and type(rows) == "table" then
            for _, record in ipairs(rows) do accept(record) end
        end
    end

    local key = itemKey(itemLink)
    local group = key and liveCache()[key] or nil
    if type(group) == "table" then
        trimLiveGroup(group)
        for _, record in pairs(group.rows or {}) do accept(record) end
    end

    local ctx = currentTraderContext()
    local currentGuild = lower(ctx.guildName)
    local currentKiosk = safeNumber(ctx.kioskId)
    local currentTime = now()
    local rows = {}
    for _, record in pairs(merged) do
        local recordKiosk = safeNumber(record.kioskId)
        local recordGuild = lower(record.guildName)
        local isCurrent = false
        if currentKiosk and recordKiosk and math.floor(currentKiosk) == math.floor(recordKiosk) then
            if currentGuild == "" or recordGuild == "" or currentGuild == recordGuild then isCurrent = true end
        elseif currentGuild ~= "" and recordGuild ~= "" and currentGuild == recordGuild then
            isCurrent = true
        end
        record._easCurrentTrader = isCurrent
        local seenAt = safeNumber(record.seenAt) or 0
        record._easAge029687 = seenAt > 0 and math.max(0, currentTime - seenAt) or math.huge
        record._easFresh029687 = record._easAge029687 <= freshSeconds()
        rows[#rows + 1] = record
    end

    table.sort(rows, function(a, b)
        if a._easFresh029687 ~= b._easFresh029687 then return a._easFresh029687 == true end
        local ap = safeNumber(a.unitPrice) or math.huge
        local bp = safeNumber(b.unitPrice) or math.huge
        if ap ~= bp then return ap < bp end
        return (safeNumber(a.seenAt) or 0) > (safeNumber(b.seenAt) or 0)
    end)

    local requested = math.floor(safeNumber(limit) or maxListingsPerItem())
    requested = math.max(1, math.min(60, requested))
    while #rows > requested do table.remove(rows) end
    return rows
end

function M:GetBestTravelTrader029683(itemLink)
    local rows = self:GetComparableTraderListings029683(itemLink, 60)
    local maxAge = travelFreshSeconds()
    for _, record in ipairs(rows) do
        local age = safeNumber(record._easAge029687)
        if age == nil then
            local seenAt = safeNumber(record.seenAt) or 0
            age = seenAt > 0 and math.max(0, now() - seenAt) or math.huge
        end
        if not record._easCurrentTrader and age <= maxAge and self:GetLocationInfo029683(record) then
            return record
        end
    end
    return nil
end

function M:UpdateTraderHealth029687(context, fullScan, rows, pages)
    context = context or currentTraderContext()
    if clean(context.guildName) == "" then return end
    local root = healthRoot()
    local identity = traderIdentity(context)
    if not identity then identity = "g:" .. lower(context.guildName) end
    local record = root.traders[identity]
    if type(record) ~= "table" then
        record = {}
        root.traders[identity] = record
    end
    record.guildId = safeNumber(context.guildId)
    record.guildName = clean(context.guildName)
    record.kioskId = safeNumber(context.kioskId)
    record.traderName = clean(context.traderName)
    record.locationName = clean(context.locationName)
    record.zoneName = clean(context.zoneName)
    record.lastSeen = now()
    if fullScan then record.lastFullScan = record.lastSeen end
    if rows ~= nil then record.lastRows = safeNumber(rows) or 0 end
    if pages ~= nil then record.lastPages = safeNumber(pages) or 0 end

    if record.kioskId then
        local kioskKey = tostring(math.floor(record.kioskId))
        local location = root.locations[kioskKey]
        if type(location) ~= "table" then location = {} root.locations[kioskKey] = location end
        location.kioskId = record.kioskId
        location.locationName = record.locationName
        location.zoneName = record.zoneName
        location.lastSeen = math.max(safeNumber(location.lastSeen) or 0, record.lastSeen)
        if fullScan then location.lastFullScan = math.max(safeNumber(location.lastFullScan) or 0, record.lastSeen) end
    end
end

function M:IsCurrentTraderFresh029687()
    local ctx = currentTraderContext()
    if clean(ctx.guildName) == "" then return false end
    local root = healthRoot()
    local identity = traderIdentity(ctx) or ("g:" .. lower(ctx.guildName))
    local record = root.traders[identity]
    local ts = type(record) == "table" and (safeNumber(record.lastFullScan) or 0) or 0
    return ts > 0 and now() - ts <= freshSeconds()
end

function M:GetLiveMarketHealth029687()
    local root = healthRoot()
    local currentTime = now()
    local traders, freshTraders, locations, freshLocations = 0, 0, 0, 0
    for _, record in pairs(root.traders) do
        if type(record) == "table" then
            traders = traders + 1
            local ts = safeNumber(record.lastFullScan) or safeNumber(record.lastSeen) or 0
            if ts > 0 and currentTime - ts <= freshSeconds() then freshTraders = freshTraders + 1 end
        end
    end
    for _, record in pairs(root.locations) do
        if type(record) == "table" then
            locations = locations + 1
            local ts = safeNumber(record.lastFullScan) or safeNumber(record.lastSeen) or 0
            if ts > 0 and currentTime - ts <= freshSeconds() then freshLocations = freshLocations + 1 end
        end
    end
    local items = 0
    for _ in pairs(liveCache()) do items = items + 1 end
    return {
        traders = traders,
        freshTraders = freshTraders,
        locations = locations,
        freshLocations = freshLocations,
        items = items,
        ttc = type(rawget(_G, "TamrielTradeCentre")) == "table",
        scanActive = self.marketLiveScanSession029687 ~= nil,
    }
end

function M:PrintLiveMarketStatus029687()
    local h = self:GetLiveMarketHealth029687()
    local state = routeState()
    local routeText = state.active and (state.paused and "route paused" or "route active") or "route idle"
    if EPC and type(EPC.Print) == "function" then
        EPC:Print(string.format(
            "Live Market: %d/%d traders fresh, %d/%d locations fresh, %d cached items, TTC %s, %s.",
            h.freshTraders, h.traders, h.freshLocations, h.locations, h.items,
            h.ttc and "ready" or "not installed", routeText))
    end
end

function M:CaptureCurrentSearchPage029687(source)
    if type(GetTradingHouseSearchResultsInfo) ~= "function" or type(GetTradingHouseSearchResultItemLink) ~= "function" or type(GetTradingHouseSearchResultItemInfo) ~= "function" then return 0 end
    local okCount, count, currentPage = pcall(GetTradingHouseSearchResultsInfo)
    if not okCount then return 0 end
    count = math.max(0, math.floor(safeNumber(count) or 0))
    currentPage = math.max(0, math.floor(safeNumber(currentPage) or 0))
    local ctx = currentTraderContext()
    if clean(ctx.guildName) == "" then return 0 end
    local seenAt = now()
    local stored = 0

    for i = 1, count do
        local okLink, link = pcall(GetTradingHouseSearchResultItemLink, i)
        if okLink and type(link) == "string" and link ~= "" then
            local okInfo, _, _, _, stackCount, sellerName, timeRemaining, totalPrice, _, uid, unitPrice = pcall(GetTradingHouseSearchResultItemInfo, i)
            if okInfo then
                stackCount = math.max(1, safeNumber(stackCount) or 1)
                totalPrice = safeNumber(totalPrice) or 0
                unitPrice = safeNumber(unitPrice) or (totalPrice > 0 and totalPrice / stackCount or nil)
                if unitPrice and unitPrice > 0 then
                    local uidText = uid
                    if type(Id64ToString) == "function" and uid ~= nil then
                        local okUid, value = pcall(Id64ToString, uid)
                        if okUid then uidText = value end
                    end
                    self:StorePersistentTraderListing029683({
                        itemLink = link,
                        unitPrice = unitPrice,
                        totalPrice = totalPrice,
                        amount = stackCount,
                        sellerName = clean(sellerName),
                        guildName = ctx.guildName,
                        guildId = ctx.guildId,
                        kioskId = ctx.kioskId,
                        traderName = ctx.traderName,
                        locationName = ctx.locationName,
                        zoneName = ctx.zoneName,
                        seenAt = seenAt,
                        expireAt = seenAt + math.max(0, safeNumber(timeRemaining) or 0),
                        source = source or "LIVE SEARCH",
                        uid = uidText,
                    })
                    stored = stored + 1
                end
            end
        end
    end

    self:UpdateTraderHealth029687(ctx, false, stored, currentPage + 1)
    return stored, currentPage
end

function M:ImportCurrentTTCGuild029687(source)
    local ttc = rawget(_G, "TamrielTradeCentre")
    local data = type(ttc) == "table" and ttc.Data or nil
    local auto = type(data) == "table" and data.AutoRecordEntries or nil
    local guilds = type(auto) == "table" and auto.Guilds or nil
    local ctx = currentTraderContext()
    if type(guilds) ~= "table" or clean(ctx.guildName) == "" then return 0 end
    local guildData = guilds[ctx.guildName]
    if type(guildData) ~= "table" then return 0 end

    local kioskId = safeNumber(guildData.KioskLocationID) or ctx.kioskId
    local lastUpdate = safeNumber(guildData.LastUpdate) or now()
    local players = guildData.PlayerListings
    if type(players) ~= "table" then return 0 end
    local imported = 0
    local currentTime = now()

    for sellerName, listings in pairs(players) do
        if type(listings) == "table" then
            for _, entry in pairs(listings) do
                if type(entry) == "table" then
                    local link = entry.ItemLink
                    local amount = math.max(1, safeNumber(entry.Amount) or 1)
                    local total = safeNumber(entry.TotalPrice) or 0
                    local expireAt = safeNumber(entry.ExpireTime) or 0
                    if type(link) == "string" and link ~= "" and total > 0 and (expireAt <= 0 or expireAt > currentTime) then
                        self:StorePersistentTraderListing029683({
                            itemLink = link,
                            unitPrice = total / amount,
                            totalPrice = total,
                            amount = amount,
                            sellerName = clean(sellerName),
                            guildName = ctx.guildName,
                            guildId = ctx.guildId,
                            kioskId = kioskId,
                            traderName = ctx.traderName,
                            locationName = ctx.locationName,
                            zoneName = ctx.zoneName,
                            seenAt = safeNumber(entry.DiscoverTime) or lastUpdate,
                            expireAt = expireAt,
                            source = source or "TTC LIVE SCAN",
                            uid = entry.UID,
                        })
                        imported = imported + 1
                    end
                end
            end
        end
    end
    return imported
end

function M:FinishCurrentTraderScan029687(reason)
    local session = self.marketLiveScanSession029687
    if not session then return end
    local ctx = currentTraderContext()
    local imported = self:ImportCurrentTTCGuild029687("TTC FULL SCAN")
    session.rows = math.max(safeNumber(session.rows) or 0, imported)
    self:UpdateTraderHealth029687(ctx, true, session.rows, session.pages)
    self.marketLiveScanSession029687 = nil
    if type(self.PruneLiveMarketCache029687) == "function" then self:PruneLiveMarketCache029687() end
    if EPC and type(EPC.Print) == "function" then
        EPC:Print(string.format("Live Market scan complete: %s - %d listings captured across %d page%s%s.",
            clean(ctx.guildName) ~= "" and ctx.guildName or session.guildName or "Guild Trader",
            math.floor(safeNumber(session.rows) or 0), math.floor(safeNumber(session.pages) or 0),
            (safeNumber(session.pages) or 0) == 1 and "" or "s",
            reason and (" [" .. tostring(reason) .. "]") or ""))
    end
end

function M:StartCurrentTraderFullScan029687(force)
    if self.marketLiveScanSession029687 then
        if EPC and type(EPC.Print) == "function" then EPC:Print("A Live Market trader scan is already running.") end
        return false
    end
    local ctx = currentTraderContext()
    if clean(ctx.guildName) == "" then
        if EPC and type(EPC.Print) == "function" then EPC:Print("Open a Guild Trader first, then start the Live Market scan.") end
        return false
    end
    if not force and self:IsCurrentTraderFresh029687() then
        if EPC and type(EPC.Print) == "function" then EPC:Print(ctx.guildName .. " was fully scanned recently; skipping duplicate scan.") end
        return true
    end

    local ttc = rawget(_G, "TamrielTradeCentre")
    if type(ttc) ~= "table" or type(ttc.StartNewGuildListingScan) ~= "function" then
        if EPC and type(EPC.Print) == "function" then
            EPC:Print("Tamriel Trade Centre is required for automatic full-store scanning. Normal Guild Trader searches are still captured live by EAS.")
        end
        return false
    end
    if type(ttc.Settings) ~= "table" or ttc.Settings.EnableAutoRecordStoreEntries ~= true then
        if EPC and type(EPC.Print) == "function" then EPC:Print("Enable TTC's automatic store-entry recording before using full Live Market scans.") end
        return false
    end
    if not ctx.kioskId then
        if EPC and type(EPC.Print) == "function" then EPC:Print("TTC could not identify this Guild Trader kiosk, so a full routed scan was not started.") end
        return false
    end

    self.marketLiveScanSession029687 = {
        guildName = ctx.guildName,
        kioskId = ctx.kioskId,
        startedAt = now(),
        pages = 0,
        rows = 0,
        zeroTail = 0,
        sawResults = false,
    }
    local ok, err = pcall(ttc.StartNewGuildListingScan, ttc)
    if not ok then
        self.marketLiveScanSession029687 = nil
        if EPC and type(EPC.Print) == "function" then EPC:Print("TTC full scan could not start: " .. tostring(err)) end
        return false
    end

    if EPC and type(EPC.Print) == "function" then EPC:Print("Live Market: TTC full scan started for " .. ctx.guildName .. ".") end
    if type(zo_callLater) == "function" then
        zo_callLater(function()
            local market = EPC and EPC.MarketPriceChecker
            local session = market and market.marketLiveScanSession029687
            if session and now() - (safeNumber(session.startedAt) or now()) >= 600 then
                market.marketLiveScanSession029687 = nil
                if EPC and type(EPC.Print) == "function" then EPC:Print("Live Market scan timed out after 10 minutes; route progress was preserved.") end
            end
        end, 600000)
    end
    return true
end

function M:HandleTradingHouseResponse029687(responseType)
    if responseType ~= nil and TRADING_HOUSE_RESULT_SEARCH_PENDING ~= nil and responseType ~= TRADING_HOUSE_RESULT_SEARCH_PENDING then return end
    local source = self.marketLiveScanSession029687 and "LIVE FULL SCAN" or "LIVE SEARCH"
    local rows, currentPage = self:CaptureCurrentSearchPage029687(source)
    local session = self.marketLiveScanSession029687
    if not session then return end

    rows = safeNumber(rows) or 0
    currentPage = safeNumber(currentPage) or 0
    if rows > 0 then
        session.sawResults = true
        session.zeroTail = 0
        session.pages = math.max(safeNumber(session.pages) or 0, currentPage + 1)
        session.rows = (safeNumber(session.rows) or 0) + rows
    else
        session.zeroTail = (safeNumber(session.zeroTail) or 0) + 1
        if session.zeroTail >= 2 then
            if type(zo_callLater) == "function" then
                zo_callLater(function()
                    if EPC.MarketPriceChecker then EPC.MarketPriceChecker:FinishCurrentTraderScan029687("TTC") end
                end, 100)
            else
                self:FinishCurrentTraderScan029687("TTC")
            end
        end
    end
end

function M:MaybeAutoScanCurrentTrader029687()
    if not EPC.saved or EPC.saved.marketLiveAutoScanTTC029687 == false then return false end
    if self.marketLiveScanSession029687 then return false end
    return self:StartCurrentTraderFullScan029687(false)
end

function M:CheckLiveWatch029687(record)
    if type(record) ~= "table" then return end
    local source = string.upper(clean(record.source))
    if not source:find("LIVE", 1, true) and not source:find("FULL SCAN", 1, true) then return end
    local key = itemKey(record.itemLink)
    local watch = key and watchRoot()[key] or nil
    if type(watch) ~= "table" then return end
    local target = safeNumber(watch.target)
    local price = safeNumber(record.unitPrice)
    if not target or not price or price > target then return end
    local seenAt = safeNumber(record.seenAt) or 0
    if seenAt <= 0 or now() - seenAt > 300 then return end

    self.marketLiveAlerted029687 = self.marketLiveAlerted029687 or {}
    local alertKey = key .. "|" .. tostring(math.floor(price)) .. "|" .. lower(record.guildName)
    if self.marketLiveAlerted029687[alertKey] then return end
    self.marketLiveAlerted029687[alertKey] = true
    if EPC and type(EPC.Print) == "function" then
        local location = self:GetLocationInfo029683(record)
        local where = location and clean(location.label) or clean(record.locationName)
        EPC:Print(GREEN .. "MARKET WATCH HIT" .. RESET .. ": " .. clean(watch.name or "Item") .. " at " .. GOLD .. formatNumber(price) .. "g" .. RESET ..
            (clean(record.guildName) ~= "" and (" - " .. record.guildName) or "") .. (where ~= "" and (" - " .. where) or ""))
    end
end

function M:AddHoveredWatch029687(target)
    target = safeNumber(target)
    if not target or target <= 0 then
        if EPC and type(EPC.Print) == "function" then EPC:Print("Usage: /easwatch <max unit price> while hovering an item.") end
        return false
    end
    local link = self.lastTooltipLink or (type(self.GetHoveredItemLink029683) == "function" and self:GetHoveredItemLink029683())
    if type(link) ~= "string" or link == "" then
        if EPC and type(EPC.Print) == "function" then EPC:Print("Hover an item first, then use /easwatch <max unit price>.") end
        return false
    end
    local key = itemKey(link)
    if not key then return false end
    local name = clean(safeCall(GetItemLinkName, "Item", link))
    watchRoot()[key] = { itemLink = link, name = name ~= "" and name or "Item", target = target, addedAt = now() }
    if EPC and type(EPC.Print) == "function" then EPC:Print("Market watch added: " .. (name ~= "" and name or "Item") .. " <= " .. formatNumber(target) .. "g/unit.") end
    return true
end

function M:RemoveHoveredWatch029687()
    local link = self.lastTooltipLink or (type(self.GetHoveredItemLink029683) == "function" and self:GetHoveredItemLink029683())
    local key = type(link) == "string" and itemKey(link) or nil
    if not key or not watchRoot()[key] then
        if EPC and type(EPC.Print) == "function" then EPC:Print("Hover a watched item to remove it.") end
        return false
    end
    local name = clean(watchRoot()[key].name)
    watchRoot()[key] = nil
    if EPC and type(EPC.Print) == "function" then EPC:Print("Market watch removed: " .. (name ~= "" and name or "Item") .. ".") end
    return true
end

function M:PrintWatchlist029687()
    local count = 0
    for _, watch in pairs(watchRoot()) do
        if type(watch) == "table" then
            count = count + 1
            if EPC and type(EPC.Print) == "function" then EPC:Print("Watch: " .. clean(watch.name or "Item") .. " <= " .. formatNumber(watch.target) .. "g/unit") end
        end
    end
    if count == 0 and EPC and type(EPC.Print) == "function" then EPC:Print("Market watchlist is empty.") end
end

function M:BuildTraderHubRoute029687()
    local byNode = {}
    local locations = self.KIOSK_LOCATIONS or {}
    for kioskId, mapped in pairs(locations) do
        if type(mapped) == "table" then
            local record = { kioskId = kioskId }
            local location = self:GetLocationInfo029683(record)
            local nodeIndex, nodeName = nil, nil
            if location then nodeIndex, nodeName = self:FindTravelNode029683(location, record) end
            if nodeIndex then
                local key = tostring(math.floor(nodeIndex))
                local hub = byNode[key]
                if not hub then
                    hub = { nodeIndex = nodeIndex, nodeName = nodeName or mapped.label, zone = mapped.zone, kioskIds = {}, labels = {}, order = safeNumber(kioskId) or 9999 }
                    byNode[key] = hub
                end
                hub.order = math.min(hub.order or 9999, safeNumber(kioskId) or 9999)
                hub.kioskIds[#hub.kioskIds + 1] = kioskId
                hub.labels[#hub.labels + 1] = clean(mapped.label)
            end
        end
    end
    local route = {}
    for _, hub in pairs(byNode) do route[#route + 1] = hub end
    table.sort(route, function(a, b)
        if (a.order or 9999) ~= (b.order or 9999) then return (a.order or 9999) < (b.order or 9999) end
        return lower(a.nodeName) < lower(b.nodeName)
    end)
    self.marketLiveHubRoute029687 = route
    return route
end

function M:GetTraderHubRoute029687()
    return type(self.marketLiveHubRoute029687) == "table" and self.marketLiveHubRoute029687 or self:BuildTraderHubRoute029687()
end

function M:TravelTraderHub029687(hub)
    if type(hub) ~= "table" or not safeNumber(hub.nodeIndex) then return false end
    if EPC.Travel and type(EPC.Travel.TravelToWayshrineNode) == "function" then
        local ok, result = pcall(EPC.Travel.TravelToWayshrineNode, EPC.Travel, hub.nodeIndex, hub.nodeName or "Guild Trader hub")
        return ok and result ~= false
    end
    if type(FastTravelToNode) == "function" then return pcall(FastTravelToNode, hub.nodeIndex) end
    return false
end

function M:PrintRoutePosition029687()
    local state = routeState()
    local route = self:GetTraderHubRoute029687()
    local hub = route[math.max(1, math.floor(safeNumber(state.index) or 1))]
    if not hub then
        if EPC and type(EPC.Print) == "function" then EPC:Print("Guild Trader route has no reachable discovered hubs.") end
        return
    end
    if EPC and type(EPC.Print) == "function" then
        EPC:Print(string.format("Guild Trader route: hub %d/%d - %s%s. Open each trader here; EAS captures searches and can auto-run TTC full scans. Use /easmarketscan next when finished with the hub.",
            math.max(1, math.floor(safeNumber(state.index) or 1)), #route, clean(hub.nodeName or "Trader Hub"),
            clean(hub.zone) ~= "" and (" - " .. clean(hub.zone)) or ""))
    end
end

function M:StartTraderRoute029687(restart)
    local route = self:BuildTraderHubRoute029687()
    if #route == 0 then
        if EPC and type(EPC.Print) == "function" then EPC:Print("No discovered Guild Trader hub wayshrines could be resolved for the Live Market route.") end
        return false
    end
    local state = routeState()
    if restart == true or state.active ~= true then
        state.index = 1
        state.visited = {}
        state.startedAt = now()
    end
    state.active = true
    state.paused = false
    local index = math.max(1, math.min(#route, math.floor(safeNumber(state.index) or 1)))
    state.index = index
    local hub = route[index]
    self:PrintRoutePosition029687()
    return self:TravelTraderHub029687(hub)
end

function M:NextTraderHub029687()
    local state = routeState()
    local route = self:GetTraderHubRoute029687()
    if state.active ~= true then return self:StartTraderRoute029687(false) end
    if state.paused == true then
        if EPC and type(EPC.Print) == "function" then EPC:Print("Guild Trader route is paused. Resume it before advancing.") end
        return false
    end
    local current = math.max(1, math.min(#route, math.floor(safeNumber(state.index) or 1)))
    local hub = route[current]
    if hub then state.visited[tostring(hub.nodeIndex)] = now() end
    current = current + 1
    if current > #route then
        state.active = false
        state.paused = false
        if EPC and type(EPC.Print) == "function" then EPC:Print(GREEN .. "Guild Trader Live Scan Route complete." .. RESET) end
        return true
    end
    state.index = current
    self:PrintRoutePosition029687()
    return self:TravelTraderHub029687(route[current])
end

function M:PauseTraderRoute029687(paused)
    local state = routeState()
    state.paused = paused == true
    if EPC and type(EPC.Print) == "function" then EPC:Print("Guild Trader route " .. (state.paused and "paused." or "resumed.")) end
    if not state.paused and state.active then self:PrintRoutePosition029687() end
end

function M:ResetTraderRoute029687()
    local state = routeState()
    state.active = false
    state.paused = false
    state.index = 1
    state.visited = {}
    state.startedAt = nil
    self.marketLiveHubRoute029687 = nil
    if EPC and type(EPC.Print) == "function" then EPC:Print("Guild Trader route reset.") end
end

local function installTeleporterTools()
    local Travel = EPC.Travel
    if not Travel or Travel._marketLiveTools029687 or type(Travel.ShowMapTeleporterToolsMenu02967) ~= "function" then return end
    Travel._marketLiveTools029687 = true
    local baseTools = Travel.ShowMapTeleporterToolsMenu02967

    function Travel:ShowMapTeleporterToolsMenu02967(owner)
        local originalFlyout = self.ShowMapTeleporterFlyout02969
        if type(originalFlyout) ~= "function" then return baseTools(self, owner) end
        local injected = false
        self.ShowMapTeleporterFlyout02969 = function(travel, titleText, items, flyoutOwner, contextMode)
            if not injected and tostring(titleText or "") == "TOOLS" and type(items) == "table" then
                injected = true
                local market = EPC.MarketPriceChecker
                local health = market and market:GetLiveMarketHealth029687() or { freshTraders = 0, traders = 0 }
                local state = routeState()
                items[#items + 1] = {
                    label = string.format("Live Market: %d/%d Traders Fresh", health.freshTraders or 0, health.traders or 0),
                    action = function() if EPC.MarketPriceChecker then EPC.MarketPriceChecker:PrintLiveMarketStatus029687() end end,
                }
                items[#items + 1] = {
                    label = "Scan Current Guild Trader (TTC)",
                    enabled = health.ttc == true,
                    action = function() if EPC.MarketPriceChecker then EPC.MarketPriceChecker:StartCurrentTraderFullScan029687(true) end end,
                }
                items[#items + 1] = {
                    label = "Auto TTC Scan: " .. ((EPC.saved and EPC.saved.marketLiveAutoScanTTC029687 ~= false) and "ON" or "OFF"),
                    selected = EPC.saved and EPC.saved.marketLiveAutoScanTTC029687 ~= false,
                    action = function()
                        EPC.saved.marketLiveAutoScanTTC029687 = not (EPC.saved.marketLiveAutoScanTTC029687 ~= false)
                        if EPC.Print then EPC:Print("Live Market auto TTC scan " .. (EPC.saved.marketLiveAutoScanTTC029687 and "enabled." or "disabled.")) end
                    end,
                }
                items[#items + 1] = {
                    label = state.active and "Resume Guild Trader Scan Route" or "Start Guild Trader Scan Route",
                    action = function() if EPC.MarketPriceChecker then EPC.MarketPriceChecker:StartTraderRoute029687(false) end end,
                }
                items[#items + 1] = {
                    label = "Next Guild Trader Hub",
                    enabled = state.active == true and state.paused ~= true,
                    action = function() if EPC.MarketPriceChecker then EPC.MarketPriceChecker:NextTraderHub029687() end end,
                }
                items[#items + 1] = {
                    label = state.paused and "Resume Trader Route" or "Pause Trader Route",
                    enabled = state.active == true,
                    action = function() if EPC.MarketPriceChecker then EPC.MarketPriceChecker:PauseTraderRoute029687(not state.paused) end end,
                }
            end
            return originalFlyout(travel, titleText, items, flyoutOwner, contextMode)
        end

        local ok, result = pcall(baseTools, self, owner)
        self.ShowMapTeleporterFlyout02969 = originalFlyout
        if not ok then
            if EPC and type(EPC.Print) == "function" then EPC:Print("Live Market Teleporter tools failed: " .. tostring(result)) end
            return false
        end
        return result
    end
end

function M:InitializeLiveMarket029687()
    if self.marketLiveInitialized029687 then return end
    self.marketLiveInitialized029687 = true
    self.marketLiveAlerted029687 = {}
    healthRoot()
    liveCache()
    watchRoot()
    routeState()
    installTeleporterTools()

    if EVENT_MANAGER and EVENT_OPEN_TRADING_HOUSE ~= nil then
        EVENT_MANAGER:RegisterForEvent(NAME .. "_Open", EVENT_OPEN_TRADING_HOUSE, function()
            if not EPC.MarketPriceChecker then return end
            local market = EPC.MarketPriceChecker
            market:UpdateTraderHealth029687(currentTraderContext(), false)
            if type(zo_callLater) == "function" then
                zo_callLater(function()
                    if EPC.MarketPriceChecker then EPC.MarketPriceChecker:MaybeAutoScanCurrentTrader029687() end
                end, 850)
            else
                market:MaybeAutoScanCurrentTrader029687()
            end
        end)
    end

    if EVENT_MANAGER and EVENT_TRADING_HOUSE_RESPONSE_RECEIVED ~= nil then
        EVENT_MANAGER:RegisterForEvent(NAME .. "_Response", EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, function(_, responseType)
            local market = EPC and EPC.MarketPriceChecker
            if not market then return end
            if type(zo_callLater) == "function" then
                zo_callLater(function()
                    if EPC.MarketPriceChecker then EPC.MarketPriceChecker:HandleTradingHouseResponse029687(responseType) end
                end, 25)
            else
                market:HandleTradingHouseResponse029687(responseType)
            end
        end)
    end

    if EVENT_MANAGER and EVENT_CLOSE_TRADING_HOUSE ~= nil then
        EVENT_MANAGER:RegisterForEvent(NAME .. "_Close", EVENT_CLOSE_TRADING_HOUSE, function()
            local market = EPC and EPC.MarketPriceChecker
            if not market then return end
            if market.marketLiveScanSession029687 then
                market:ImportCurrentTTCGuild029687("TTC PARTIAL SCAN")
                market.marketLiveScanSession029687 = nil
            end
        end)
    end

    if type(zo_callLater) == "function" then
        zo_callLater(function()
            local market = EPC and EPC.MarketPriceChecker
            if not market then return end
            if type(market.ImportTTCTraderHistory029683) == "function" then market:ImportTTCTraderHistory029683(true) end
            market:PruneLiveMarketCache029687()
        end, 4200)
    end
end

SLASH_COMMANDS = SLASH_COMMANDS or {}
SLASH_COMMANDS["/easmarketlive"] = function()
    if EPC.MarketPriceChecker then EPC.MarketPriceChecker:PrintLiveMarketStatus029687() end
end

SLASH_COMMANDS["/easmarketscan"] = function(text)
    local market = EPC.MarketPriceChecker
    if not market then return end
    local command = lower(text)
    if command == "start" then
        market:StartTraderRoute029687(true)
    elseif command == "next" then
        market:NextTraderHub029687()
    elseif command == "pause" then
        market:PauseTraderRoute029687(true)
    elseif command == "resume" then
        local state = routeState()
        if state.active then market:PauseTraderRoute029687(false) else market:StartTraderRoute029687(false) end
    elseif command == "reset" then
        market:ResetTraderRoute029687()
    elseif command == "current" or command == "scan" then
        market:StartCurrentTraderFullScan029687(true)
    else
        market:PrintLiveMarketStatus029687()
        market:PrintRoutePosition029687()
        if EPC.Print then EPC:Print("/easmarketscan start | current | next | pause | resume | reset") end
    end
end

SLASH_COMMANDS["/easwatch"] = function(text)
    local market = EPC.MarketPriceChecker
    if not market then return end
    local command = lower(text)
    if command == "" or command == "list" then
        market:PrintWatchlist029687()
    elseif command == "remove" then
        market:RemoveHoveredWatch029687()
    elseif command == "clear" then
        EPC.saved.marketLiveWatchlist029687 = {}
        if EPC.Print then EPC:Print("Market watchlist cleared.") end
    else
        market:AddHoveredWatch029687(tonumber(text))
    end
end

if EVENT_MANAGER and EVENT_PLAYER_ACTIVATED ~= nil then
    EVENT_MANAGER:RegisterForEvent(NAME, EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_PLAYER_ACTIVATED)
        if type(zo_callLater) == "function" then
            zo_callLater(function()
                if EPC.MarketPriceChecker then EPC.MarketPriceChecker:InitializeLiveMarket029687() end
            end, 900)
        elseif EPC.MarketPriceChecker then
            EPC.MarketPriceChecker:InitializeLiveMarket029687()
        end
    end)
end

EPC.marketPriceLiveEngine029687 = true