-- ESO Adventurer Suite
-- Verified market comparison + live trader capture.
-- Canonically matches the same sellable item across guild traders, keeps aggregate
-- pricing separate from verified trader locations, and only travels to a real
-- alternate trader record.

local EPC = ESOProgressionCoach
if not EPC or not EPC.MarketPriceChecker then return end
local M = EPC.MarketPriceChecker
if M._marketPriceLiveCapture029683 then return end
M._marketPriceLiveCapture029683 = true
M._marketPriceVerifiedComparison029683 = true

local GOLD = "|cFFD700"
local WHITE = "|cFFFFFF"
local GREY = "|cA0A0A0"
local GREEN = "|c66FF66"
local CYAN = "|c66CCFF"
local YELLOW = "|cFFFF66"
local RESET = "|r"

local MAX_TRADERS_PER_ITEM = 12
local MAX_CACHE_AGE = 30 * 24 * 60 * 60

local function safeNumber(value)
    local n = tonumber(value)
    if not n or n ~= n or n == math.huge or n == -math.huge then return nil end
    return n
end

local function safeCall(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, value = pcall(fn, ...)
    if not ok or value == nil then return fallback end
    return value
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

local function formatNumber(value)
    local n = safeNumber(value)
    if not n then return "-" end
    n = math.floor(n + 0.5)
    if type(ZO_CommaDelimitDecimalNumber) == "function" then
        local ok, text = pcall(ZO_CommaDelimitDecimalNumber, n)
        if ok and text then return tostring(text) end
    end
    local sign = n < 0 and "-" or ""
    local digits = tostring(math.abs(n))
    while true do
        local replaced, count = digits:gsub("^(%d+)(%d%d%d)", "%1,%2")
        digits = replaced
        if count == 0 then break end
    end
    return sign .. digits
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

local function firstResult(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, value = pcall(fn, ...)
    if ok then return value end
    return nil
end

-- TTC price rows may represent the same market item with item-link fields that are
-- not byte-for-byte identical. Build a stable market identity from public APIs.
local function canonicalItemKey(itemLink)
    if type(itemLink) ~= "string" or itemLink == "" then return nil end

    local itemId = safeNumber(firstResult(GetItemLinkItemId, itemLink))
    if not itemId or itemId <= 0 then
        local payload = itemLink:match("|H%d+:item:([^|]+)|h")
        return payload and ("raw:" .. payload) or ("raw:" .. itemLink)
    end

    local itemType, specializedItemType = 0, 0
    if type(GetItemLinkItemType) == "function" then
        local ok, a, b = pcall(GetItemLinkItemType, itemLink)
        if ok then
            itemType = safeNumber(a) or 0
            specializedItemType = safeNumber(b) or 0
        end
    end

    if rawget(_G, "ITEMTYPE_MASTER_WRIT") ~= nil and itemType == ITEMTYPE_MASTER_WRIT then
        local payload = itemLink:match("|H%d+:item:([^|]+)|h")
        return payload and ("writ:" .. payload) or ("writ:" .. itemLink)
    end

    local quality = safeNumber(firstResult(GetItemLinkQuality, itemLink)) or 0
    local reqLevel = safeNumber(firstResult(GetItemLinkRequiredLevel, itemLink)) or 0
    local reqCP = safeNumber(firstResult(GetItemLinkRequiredChampionPoints, itemLink)) or 0
    local traitType = safeNumber(firstResult(GetItemLinkTraitInfo, itemLink)) or 0
    local style = safeNumber(firstResult(GetItemLinkItemStyle, itemLink)) or 0
    local equipType = safeNumber(firstResult(GetItemLinkEquipType, itemLink)) or 0
    local armorType = safeNumber(firstResult(GetItemLinkArmorType, itemLink)) or 0
    local weaponType = safeNumber(firstResult(GetItemLinkWeaponType, itemLink)) or 0
    local name = lower(safeCall(GetItemLinkName, "", itemLink))

    local setName = ""
    if type(GetItemLinkSetInfo) == "function" then
        local ok, isSet, value = pcall(GetItemLinkSetInfo, itemLink)
        if ok and isSet then setName = lower(value) end
    end

    return table.concat({
        "v2", tostring(math.floor(itemId)), tostring(math.floor(itemType)),
        tostring(math.floor(specializedItemType)), tostring(math.floor(quality)),
        tostring(math.floor(reqLevel)), tostring(math.floor(reqCP)), tostring(math.floor(traitType)),
        tostring(math.floor(style)), tostring(math.floor(equipType)), tostring(math.floor(armorType)),
        tostring(math.floor(weaponType)), name, setName,
    }, ":")
end

function M:GetMarketItemKey029683(itemLink)
    return canonicalItemKey(itemLink)
end

local function cacheRoot()
    EPC.saved = EPC.saved or {}
    if type(EPC.saved.marketPriceTraderCacheV2029683) ~= "table" then
        EPC.saved.marketPriceTraderCacheV2029683 = {}
    end
    return EPC.saved.marketPriceTraderCacheV2029683
end

local function traderIdentity(record)
    if type(record) ~= "table" then return nil end
    local kioskId = safeNumber(record.kioskId)
    local guild = lower(record.guildName)
    local trader = lower(record.traderName)
    local location = lower(record.locationName)
    local zone = lower(record.zoneName)
    if kioskId then return "k:" .. tostring(math.floor(kioskId)) .. "|g:" .. guild end
    if guild ~= "" then return "g:" .. guild .. "|l:" .. location .. "|z:" .. zone end
    if trader ~= "" then return "t:" .. trader .. "|l:" .. location .. "|z:" .. zone end
    if location ~= "" or zone ~= "" then return "l:" .. location .. "|z:" .. zone end
    return nil
end

local function recordExpired(record, currentTime)
    if type(record) ~= "table" then return true end
    currentTime = currentTime or now()
    local expireAt = safeNumber(record.expireAt)
    if expireAt and expireAt > 0 and expireAt <= currentTime then return true end
    local seenAt = safeNumber(record.seenAt)
    if seenAt and seenAt > 0 and currentTime - seenAt > MAX_CACHE_AGE then return true end
    return false
end

local function trimGroup(group)
    if type(group) ~= "table" or type(group.traders) ~= "table" then return end
    local currentTime = now()
    local rows = {}
    for id, record in pairs(group.traders) do
        if recordExpired(record, currentTime) then
            group.traders[id] = nil
        else
            rows[#rows + 1] = { id = id, record = record }
        end
    end
    table.sort(rows, function(a, b)
        local ap = safeNumber(a.record.unitPrice) or math.huge
        local bp = safeNumber(b.record.unitPrice) or math.huge
        if ap ~= bp then return ap < bp end
        return (safeNumber(a.record.seenAt) or 0) > (safeNumber(b.record.seenAt) or 0)
    end)
    for i = MAX_TRADERS_PER_ITEM + 1, #rows do group.traders[rows[i].id] = nil end
end

-- This replaces the raw-link cache writer added by the earlier multi-trader fix.
-- All existing callers dispatch through this method, including live searches and
-- TTC AutoRecordEntries import.
function M:StorePersistentTraderListing029683(record)
    if type(record) ~= "table" or type(record.itemLink) ~= "string" or record.itemLink == "" then return false end
    local key = canonicalItemKey(record.itemLink)
    local identity = traderIdentity(record)
    local unitPrice = safeNumber(record.unitPrice)
    if not key or not identity or not unitPrice or unitPrice <= 0 then return false end
    local currentTime = now()
    if recordExpired(record, currentTime) then return false end

    local root = cacheRoot()
    local group = root[key]
    if type(group) ~= "table" then
        group = { lastSeen = 0, traders = {} }
        root[key] = group
    end
    group.traders = type(group.traders) == "table" and group.traders or {}

    local seenAt = safeNumber(record.seenAt) or currentTime
    local old = group.traders[identity]
    local replace = old == nil or recordExpired(old, currentTime)
    if old and not replace then
        local oldSeen = safeNumber(old.seenAt) or 0
        local oldPrice = safeNumber(old.unitPrice) or math.huge
        replace = seenAt > oldSeen or (seenAt == oldSeen and unitPrice < oldPrice)
    end

    if replace then
        group.traders[identity] = {
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
            source = clean(record.source ~= "" and record.source or "SUITE CACHE"),
        }
    end

    group.lastSeen = math.max(safeNumber(group.lastSeen) or 0, seenAt)
    trimGroup(group)
    return true
end

local function getCurrentTraderContext()
    local guildId, guildName = 0, ""
    if type(GetCurrentTradingHouseGuildDetails) == "function" then
        local ok, id, name = pcall(GetCurrentTradingHouseGuildDetails)
        if ok then guildId, guildName = safeNumber(id) or 0, clean(name) end
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

    return guildId, guildName, kioskId, traderName, locationName, zoneName
end

local function findCurrentResultForItem(expectedItemLink)
    if type(GetTradingHouseSearchResultsInfo) ~= "function" or type(GetTradingHouseSearchResultItemLink) ~= "function" or type(GetTradingHouseSearchResultItemInfo) ~= "function" then return nil end
    local expectedKey = canonicalItemKey(expectedItemLink)
    if not expectedKey then return nil end

    local okCount, count = pcall(GetTradingHouseSearchResultsInfo)
    count = okCount and safeNumber(count) or 0
    if not count or count <= 0 then return nil end

    local best = nil
    for i = 1, count do
        local okLink, link = pcall(GetTradingHouseSearchResultItemLink, i)
        if okLink and type(link) == "string" and link ~= "" and canonicalItemKey(link) == expectedKey then
            local okInfo, _, _, _, stackCount, sellerName, timeRemaining, totalPrice, _, uniqueId, unitPrice = pcall(GetTradingHouseSearchResultItemInfo, i)
            if okInfo then
                stackCount = math.max(1, safeNumber(stackCount) or 1)
                totalPrice = safeNumber(totalPrice) or 0
                unitPrice = safeNumber(unitPrice) or (totalPrice > 0 and totalPrice / stackCount or nil)
                if unitPrice and unitPrice > 0 and (not best or unitPrice < best.unitPrice) then
                    best = {
                        rowIndex = i,
                        itemLink = link,
                        unitPrice = unitPrice,
                        totalPrice = totalPrice,
                        amount = stackCount,
                        sellerName = clean(sellerName),
                        timeRemaining = safeNumber(timeRemaining) or 0,
                        itemUniqueId = uniqueId,
                        source = "LIVE",
                    }
                end
            end
        end
    end
    return best
end

function M:CaptureCurrentTraderForTooltip029683(itemLink)
    if type(itemLink) ~= "string" or itemLink == "" then return nil end
    local row = nil
    if type(self.GetHoveredTraderRow029683) == "function" then
        local ok, value = pcall(self.GetHoveredTraderRow029683, self, itemLink)
        if ok and type(value) == "table" then row = value end
    end
    if not row then row = findCurrentResultForItem(itemLink) end
    if not row then return nil end

    local guildId, guildName, kioskId, traderName, locationName, zoneName = getCurrentTraderContext()
    local seenAt = now()
    row.guildId = guildId
    row.guildName = guildName
    row.kioskId = kioskId
    row.traderName = traderName
    row.locationName = locationName
    row.zoneName = zoneName
    row.seenAt = seenAt
    row.expireAt = seenAt + math.max(0, safeNumber(row.timeRemaining) or 0)
    row.source = "LIVE"

    if type(self.PutLocatedListing029683) == "function" then
        self:PutLocatedListing029683(row)
    else
        self:StorePersistentTraderListing029683(row)
    end
    return row
end

function M:GetComparableTraderListings029683(itemLink, limit)
    local key = canonicalItemKey(itemLink)
    if not key then return {} end
    local group = cacheRoot()[key]
    if type(group) ~= "table" or type(group.traders) ~= "table" then return {} end
    trimGroup(group)

    local _, currentGuild, currentKiosk = getCurrentTraderContext()
    local currentGuildLower = lower(currentGuild)
    local rows = {}
    local currentTime = now()
    for _, record in pairs(group.traders) do
        if type(record) == "table" and not recordExpired(record, currentTime) then
            local recordKiosk = safeNumber(record.kioskId)
            local recordGuild = lower(record.guildName)
            local isCurrent = false
            if currentKiosk and recordKiosk and math.floor(currentKiosk) == math.floor(recordKiosk) then
                if currentGuildLower == "" or recordGuild == "" or currentGuildLower == recordGuild then isCurrent = true end
            elseif currentGuildLower ~= "" and recordGuild ~= "" and currentGuildLower == recordGuild then
                isCurrent = true
            end
            record._easCurrentTrader = isCurrent
            rows[#rows + 1] = record
        end
    end

    table.sort(rows, function(a, b)
        local ap = safeNumber(a.unitPrice) or math.huge
        local bp = safeNumber(b.unitPrice) or math.huge
        if ap ~= bp then return ap < bp end
        return (safeNumber(a.seenAt) or 0) > (safeNumber(b.seenAt) or 0)
    end)

    limit = math.max(1, math.min(MAX_TRADERS_PER_ITEM, math.floor(safeNumber(limit) or 5)))
    while #rows > limit do table.remove(rows) end
    return rows
end

function M:GetBestTravelTrader029683(itemLink)
    local rows = self:GetComparableTraderListings029683(itemLink, MAX_TRADERS_PER_ITEM)
    for _, record in ipairs(rows) do
        if not record._easCurrentTrader and self:GetLocationInfo029683(record) then return record end
    end
    return nil
end

local function addLine(tooltip, text)
    if tooltip and type(tooltip.AddLine) == "function" then pcall(tooltip.AddLine, tooltip, text) end
end

local function addMarketSource(tooltip, market, label)
    if type(market) ~= "table" then return end
    local ts = safeNumber(market.timestamp) or 0
    local ageText = ts > 0 and (formatAge(math.max(0, now() - ts)) .. " old") or "age unknown"
    addLine(tooltip, CYAN .. label .. ": " .. tostring(market.source or "market") .. RESET .. GREY .. "  " .. ageText .. RESET)

    local bits = {}
    if safeNumber(market.min) then bits[#bits + 1] = "Global low " .. GOLD .. formatNumber(market.min) .. "g" .. RESET .. GREY .. " (location unknown)" .. RESET end
    if safeNumber(market.avg) then bits[#bits + 1] = "Avg " .. formatNumber(market.avg) .. "g" end
    if safeNumber(market.listings) then bits[#bits + 1] = formatNumber(market.listings) .. " listings" end
    if #bits > 0 then addLine(tooltip, table.concat(bits, "   ")) end

    local lo, hi = safeNumber(market.suggestedMin), safeNumber(market.suggestedMax)
    if lo or hi then
        lo, hi = lo or hi, hi or lo
        local suggested = lo and hi and lo ~= hi and (formatNumber(lo) .. "-" .. formatNumber(hi) .. "g") or (formatNumber(lo or hi) .. "g")
        local line = "Suggested " .. suggested
        if safeNumber(market.saleAvg) then line = line .. "   Recent sale avg " .. formatNumber(market.saleAvg) .. "g" end
        addLine(tooltip, line)
    elseif safeNumber(market.saleAvg) then
        addLine(tooltip, "Recent sale avg " .. formatNumber(market.saleAvg) .. "g")
    end
end

-- This is the authoritative market tooltip renderer. It intentionally does not
-- call the older renderer, which could visually associate aggregate global-low
-- pricing with a locally observed trader even though ESO-Hub/TTC aggregate data
-- does not identify that global-low kiosk.
function M:AppendMarketTooltip029683(tooltip, itemLink)
    local saved = EPC.saved or {}
    if saved.marketPriceCheckerEnabled029683 == false or saved.marketPriceTooltipEnabled029683 == false then
        self:HideTravelButton029683()
        return
    end
    if not tooltip or type(tooltip.AddLine) ~= "function" or type(itemLink) ~= "string" or itemLink == "" then
        self:HideTravelButton029683()
        return
    end

    local captured = self:CaptureCurrentTraderForTooltip029683(itemLink)

    local primary, cross = nil, nil
    if type(self.GetMarketSources029683) == "function" then
        primary, cross = self:GetMarketSources029683(itemLink)
    else
        primary = self:GetMarketData029683(itemLink)
    end

    local rows = self:GetComparableTraderListings029683(itemLink, MAX_TRADERS_PER_ITEM)
    if not primary and not cross and #rows == 0 and not captured then
        self:HideTravelButton029683()
        return
    end

    if type(tooltip.AddVerticalPadding) == "function" then pcall(tooltip.AddVerticalPadding, tooltip, 5) end
    if type(ZO_Tooltip_AddDivider) == "function" then pcall(ZO_Tooltip_AddDivider, tooltip) end
    addLine(tooltip, GOLD .. "ESO ADVENTURER SUITE MARKET" .. RESET)

    if primary then addMarketSource(tooltip, primary, "Aggregate reference") end
    if cross then addMarketSource(tooltip, cross, "Cross-check") end
    if primary or cross then
        addLine(tooltip, GREY .. "Aggregate sources provide market prices, not the guild/kiosk owning their global-low listing." .. RESET)
    end

    if captured then
        local line = WHITE .. "CURRENT LISTING  " .. GOLD .. formatNumber(captured.unitPrice) .. "g/unit" .. RESET
        if safeNumber(captured.amount) and captured.amount > 1 then
            line = line .. GREY .. "  x" .. tostring(math.floor(captured.amount)) .. " = " .. formatNumber(captured.totalPrice) .. "g" .. RESET
        end
        addLine(tooltip, line)
        local dealText, dealColor = self:GetDealLabel029683(captured, primary)
        if dealText then addLine(tooltip, (dealColor or WHITE) .. dealText .. RESET) end
    end

    local others = 0
    for _, record in ipairs(rows) do if not record._easCurrentTrader then others = others + 1 end end
    addLine(tooltip, CYAN .. "VERIFIED LOCATED TRADERS" .. RESET .. GREY .. "  " .. tostring(#rows) .. " known / " .. tostring(others) .. " other" .. RESET)

    if #rows > 0 then
        local displayCount = math.min(5, #rows)
        for i = 1, displayCount do
            local record = rows[i]
            local location = self:GetLocationInfo029683(record)
            local guild = clean(record.guildName)
            local where = location and clean(location.label) or clean(record.locationName)
            local seenAt = safeNumber(record.seenAt) or 0
            local age = seenAt > 0 and formatAge(math.max(0, now() - seenAt)) or "unknown"
            local marker = record._easCurrentTrader and (GREEN .. "CURRENT" .. RESET) or (WHITE .. "OTHER" .. RESET)
            local cheapest = (i == 1) and (GOLD .. "  CHEAPEST LOCATED" .. RESET) or ""
            local line = tostring(i) .. ". " .. GOLD .. formatNumber(record.unitPrice) .. "g" .. RESET .. "  " .. marker .. cheapest
            if guild ~= "" then line = line .. "  " .. CYAN .. guild .. RESET end
            if where ~= "" then line = line .. "  " .. WHITE .. where .. RESET end
            line = line .. GREY .. "  seen " .. age .. " ago" .. RESET
            addLine(tooltip, line)
        end
    end

    if others == 0 then
        addLine(tooltip, YELLOW .. "No other verified trader is located yet; the aggregate global-low trader cannot be inferred." .. RESET)
        addLine(tooltip, GREY .. "Search the same item at another Guild Trader, or import a TTC observation that includes a kiosk, to create a real comparison." .. RESET)
    end

    local travelRecord = self:GetBestTravelTrader029683(itemLink)
    self:UpdateTravelButton029683(tooltip, travelRecord)
end

SLASH_COMMANDS = SLASH_COMMANDS or {}
SLASH_COMMANDS["/easmarketdebug"] = function()
    if not EPC.MarketPriceChecker then return end
    local link = EPC.MarketPriceChecker.lastTooltipLink or EPC.MarketPriceChecker:GetHoveredItemLink029683()
    if not link then
        if type(EPC.Print) == "function" then EPC:Print("Hover an item, then use /easmarketdebug.") end
        return
    end
    local rows = EPC.MarketPriceChecker:GetComparableTraderListings029683(link, MAX_TRADERS_PER_ITEM)
    local others = 0
    for _, row in ipairs(rows) do if not row._easCurrentTrader then others = others + 1 end end
    local primary = EPC.MarketPriceChecker.GetMarketSources029683 and EPC.MarketPriceChecker:GetMarketSources029683(link) or EPC.MarketPriceChecker:GetMarketData029683(link)
    local aggregate = primary and safeNumber(primary.min) and (formatNumber(primary.min) .. "g") or "none"
    if type(EPC.Print) == "function" then
        EPC:Print("Market debug: aggregate low " .. aggregate .. " (location unknown); " .. tostring(#rows) .. " verified located trader(s), " .. tostring(others) .. " other trader(s).")
    end
end

-- Rebuild the corrected cache from TTC's currently available observed-kiosk data.
if type(zo_callLater) == "function" then
    zo_callLater(function()
        if EPC.MarketPriceChecker and type(EPC.MarketPriceChecker.ImportTTCTraderHistory029683) == "function" then
            EPC.MarketPriceChecker.ttcPersistentImportReady = false
            EPC.MarketPriceChecker:ImportTTCTraderHistory029683(true)
            EPC.MarketPriceChecker.lastTooltipSignature = nil
        end
    end, 4700)
end

EPC.marketPriceLiveTraderCapture029683 = true
EPC.marketPriceVerifiedComparison029683 = true
