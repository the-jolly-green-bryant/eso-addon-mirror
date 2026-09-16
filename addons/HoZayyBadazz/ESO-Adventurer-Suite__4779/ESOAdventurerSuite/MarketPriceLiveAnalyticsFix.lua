-- ESO Adventurer Suite
-- v0.29.688 Live Market analytics.
-- Keeps a compact hourly low/high history from real located Guild Trader
-- observations and adds freshness/trend intelligence to Market Details.

local EPC = ESOProgressionCoach
if not EPC or not EPC.MarketPriceChecker then return end
local M = EPC.MarketPriceChecker
if M._marketLiveAnalytics029688 then return end
M._marketLiveAnalytics029688 = true

EPC.defaults = EPC.defaults or {}
EPC.defaults.marketLiveHistoryHours029688 = 24
EPC.defaults.marketLiveHistoryMaxItems029688 = 800

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

local function now()
    if type(GetTimeStamp) ~= "function" then return 0 end
    local ok, value = pcall(GetTimeStamp)
    return ok and (safeNumber(value) or 0) or 0
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

local function formatNumber(value)
    local n = safeNumber(value)
    if not n then return "-" end
    n = math.floor(n + 0.5)
    if type(ZO_CommaDelimitDecimalNumber) == "function" then
        local ok, text = pcall(ZO_CommaDelimitDecimalNumber, n)
        if ok and text then return tostring(text) end
    end
    local digits = tostring(math.abs(n))
    while true do
        local replaced, count = digits:gsub("^(%d+)(%d%d%d)", "%1,%2")
        digits = replaced
        if count == 0 then break end
    end
    return (n < 0 and "-" or "") .. digits
end

local function formatAge(seconds)
    seconds = math.max(0, math.floor(safeNumber(seconds) or 0))
    if seconds < 60 then return tostring(seconds) .. "s" end
    local minutes = math.floor(seconds / 60)
    if minutes < 60 then return tostring(minutes) .. "m" end
    local hours = math.floor(minutes / 60)
    if hours < 48 then return tostring(hours) .. "h " .. tostring(minutes % 60) .. "m" end
    return tostring(math.floor(hours / 24)) .. "d"
end

local function itemKey(itemLink)
    if type(M.GetMarketItemKey029683) == "function" then
        local ok, key = pcall(M.GetMarketItemKey029683, M, itemLink)
        if ok and key then return key end
    end
    if type(itemLink) ~= "string" or itemLink == "" then return nil end
    return "raw:" .. itemLink
end

local function historyHours()
    local saved = EPC.saved or {}
    local value = safeNumber(saved.marketLiveHistoryHours029688) or 24
    return math.max(6, math.min(72, math.floor(value)))
end

local function historyMaxItems()
    local saved = EPC.saved or {}
    local value = safeNumber(saved.marketLiveHistoryMaxItems029688) or 800
    return math.max(200, math.min(2000, math.floor(value)))
end

local function historyRoot()
    EPC.saved = EPC.saved or {}
    if type(EPC.saved.marketLiveHourlyHistory029688) ~= "table" then
        EPC.saved.marketLiveHourlyHistory029688 = {}
    end
    return EPC.saved.marketLiveHourlyHistory029688
end

function M:PruneLiveMarketHistory029688()
    local root = historyRoot()
    local cutoff = now() - ((historyHours() + 2) * 3600)
    local groups = {}

    for key, group in pairs(root) do
        if type(group) ~= "table" or type(group.hours) ~= "table" then
            root[key] = nil
        else
            local newest = 0
            for bucketKey, bucket in pairs(group.hours) do
                local stamp = type(bucket) == "table" and (safeNumber(bucket.time) or safeNumber(bucketKey) or 0) or 0
                if stamp < cutoff then
                    group.hours[bucketKey] = nil
                elseif stamp > newest then
                    newest = stamp
                end
            end
            group.lastSeen = math.max(safeNumber(group.lastSeen) or 0, newest)
            if next(group.hours) == nil then
                root[key] = nil
            else
                groups[#groups + 1] = { key = key, lastSeen = safeNumber(group.lastSeen) or 0 }
            end
        end
    end

    local limit = historyMaxItems()
    if #groups > limit then
        table.sort(groups, function(a, b) return a.lastSeen > b.lastSeen end)
        for i = limit + 1, #groups do root[groups[i].key] = nil end
    end
    self.marketLiveHistoryStores029688 = 0
    self.marketLiveHistoryPruneQueued029688 = false
end

function M:QueueLiveMarketHistoryPrune029688(delayMs)
    if self.marketLiveScanSession029687 or self.marketLiveHistoryPruneQueued029688 then return end
    self.marketLiveHistoryPruneQueued029688 = true
    if type(zo_callLater) == "function" then
        zo_callLater(function()
            local market = EPC and EPC.MarketPriceChecker
            if not market then return end
            if market.marketLiveScanSession029687 then
                market.marketLiveHistoryPruneQueued029688 = false
                return
            end
            market:PruneLiveMarketHistory029688()
        end, math.max(25, math.floor(safeNumber(delayMs) or 75)))
    else
        self:PruneLiveMarketHistory029688()
    end
end

function M:RecordLiveMarketHistory029688(record)
    if type(record) ~= "table" or type(record.itemLink) ~= "string" or record.itemLink == "" then return false end
    local price = safeNumber(record.unitPrice)
    local seenAt = safeNumber(record.seenAt) or now()
    if not price or price <= 0 or seenAt <= 0 then return false end
    local currentTime = now()
    if currentTime > 0 and currentTime - seenAt > (historyHours() + 2) * 3600 then return false end

    local key = itemKey(record.itemLink)
    if not key then return false end
    local root = historyRoot()
    local group = root[key]
    if type(group) ~= "table" then
        group = { itemLink = record.itemLink, lastSeen = 0, hours = {} }
        root[key] = group
    end
    group.hours = type(group.hours) == "table" and group.hours or {}

    local bucketTime = math.floor(seenAt / 3600) * 3600
    local bucketKey = tostring(bucketTime)
    local bucket = group.hours[bucketKey]
    if type(bucket) ~= "table" then
        bucket = { time = bucketTime, low = price, high = price, last = price }
        group.hours[bucketKey] = bucket
    else
        bucket.low = math.min(safeNumber(bucket.low) or price, price)
        bucket.high = math.max(safeNumber(bucket.high) or price, price)
        if seenAt >= (safeNumber(bucket.lastSeen) or 0) then bucket.last = price end
    end
    bucket.lastSeen = math.max(safeNumber(bucket.lastSeen) or 0, seenAt)
    group.itemLink = record.itemLink
    group.lastSeen = math.max(safeNumber(group.lastSeen) or 0, seenAt)

    self.marketLiveHistoryStores029688 = (self.marketLiveHistoryStores029688 or 0) + 1
    if not self.marketLiveScanSession029687 and self.marketLiveHistoryStores029688 >= 1200 then
        self:QueueLiveMarketHistoryPrune029688(75)
    end
    return true
end

local baseStore029688 = M.StorePersistentTraderListing029683
if type(baseStore029688) == "function" then
    function M:StorePersistentTraderListing029683(record)
        local result = baseStore029688(self, record)
        self:RecordLiveMarketHistory029688(record)
        return result
    end
end

-- Run one compact history cleanup after an authoritative TTC full-store scan,
-- never repeatedly while thousands of search rows are streaming in.
local baseFinish029688 = M.FinishCurrentTraderScan029687
if type(baseFinish029688) == "function" then
    function M:FinishCurrentTraderScan029687(reason)
        local result = baseFinish029688(self, reason)
        self.marketLiveHistoryPruneQueued029688 = false
        self:QueueLiveMarketHistoryPrune029688(125)
        return result
    end
end

local function average(values)
    if #values == 0 then return nil end
    local total = 0
    for i = 1, #values do total = total + values[i] end
    return total / #values
end

function M:GetLiveMarketAnalytics029688(itemLink)
    local currentTime = now()
    local freshWindow = ((EPC.saved and safeNumber(EPC.saved.marketLiveFreshMinutes029687)) or 30) * 60
    local rows = type(self.GetComparableTraderListings029683) == "function" and self:GetComparableTraderListings029683(itemLink, 60) or {}
    local freshestAge, freshRows, knownRows, locatedLow = nil, 0, 0, nil

    for _, row in ipairs(rows) do
        local seenAt = safeNumber(row.seenAt) or 0
        local age = seenAt > 0 and math.max(0, currentTime - seenAt) or math.huge
        knownRows = knownRows + 1
        if age <= freshWindow then freshRows = freshRows + 1 end
        if not freshestAge or age < freshestAge then freshestAge = age end
        local price = safeNumber(row.unitPrice)
        if price and (not locatedLow or price < locatedLow) then locatedLow = price end
    end

    local key = itemKey(itemLink)
    local group = key and historyRoot()[key] or nil
    local historyLow, historyHigh = nil, nil
    local recent, previous = {}, {}
    local bucketCount = 0
    local cutoff = currentTime - historyHours() * 3600
    local recentCutoff = currentTime - 6 * 3600

    if type(group) == "table" and type(group.hours) == "table" then
        for _, bucket in pairs(group.hours) do
            local stamp = type(bucket) == "table" and (safeNumber(bucket.time) or 0) or 0
            if stamp >= cutoff then
                local low = safeNumber(bucket.low)
                local high = safeNumber(bucket.high)
                if low then
                    bucketCount = bucketCount + 1
                    historyLow = historyLow and math.min(historyLow, low) or low
                    if stamp >= recentCutoff then recent[#recent + 1] = low else previous[#previous + 1] = low end
                end
                if high then historyHigh = historyHigh and math.max(historyHigh, high) or high end
            end
        end
    end

    local recentAverage = average(recent)
    local previousAverage = average(previous)
    local trendPercent = nil
    if recentAverage and previousAverage and previousAverage > 0 and #recent >= 1 and #previous >= 2 then
        trendPercent = ((recentAverage - previousAverage) / previousAverage) * 100
    end

    return {
        knownRows = knownRows,
        freshRows = freshRows,
        freshestAge = freshestAge,
        locatedLow = locatedLow,
        historyLow = historyLow,
        historyHigh = historyHigh,
        historyBuckets = bucketCount,
        recentLowAverage = recentAverage,
        previousLowAverage = previousAverage,
        trendPercent = trendPercent,
    }
end

function M:FormatLiveMarketAnalytics029688(itemLink)
    local a = self:GetLiveMarketAnalytics029688(itemLink)
    local bits = { CYAN .. "LIVE INTELLIGENCE" .. RESET }
    if a.knownRows > 0 then
        bits[#bits + 1] = GREEN .. tostring(a.freshRows) .. "/" .. tostring(a.knownRows) .. " fresh" .. RESET
    else
        bits[#bits + 1] = GREY .. "no located listings yet" .. RESET
    end
    if a.freshestAge and a.freshestAge < math.huge then bits[#bits + 1] = "freshest " .. formatAge(a.freshestAge) end
    if a.historyLow then bits[#bits + 1] = GOLD .. tostring(historyHours()) .. "h low " .. formatNumber(a.historyLow) .. "g" .. RESET end

    if a.trendPercent then
        local pct = math.abs(a.trendPercent)
        if pct < 1 then
            bits[#bits + 1] = GREY .. "low trend flat" .. RESET
        elseif a.trendPercent < 0 then
            bits[#bits + 1] = GREEN .. string.format("low trend down %.1f%%", pct) .. RESET
        else
            bits[#bits + 1] = YELLOW .. string.format("low trend up %.1f%%", pct) .. RESET
        end
    end
    return table.concat(bits, "   ")
end

local baseShowPanel029688 = M.ShowMarketContextPanel029685
if type(baseShowPanel029688) == "function" then
    function M:ShowMarketContextPanel029685(itemLink, clickedRecord)
        local result = baseShowPanel029688(self, itemLink, clickedRecord)
        local panel = self.marketContextPanel029685
        if panel and panel.content and type(panel.content.GetText) == "function" and type(panel.content.SetText) == "function" then
            local text = tostring(panel.content:GetText() or "")
            if not text:find("LIVE INTELLIGENCE", 1, true) then
                panel.content:SetText(text .. "\n" .. self:FormatLiveMarketAnalytics029688(itemLink))
            end
        end
        return result
    end
end

SLASH_COMMANDS = SLASH_COMMANDS or {}
SLASH_COMMANDS["/easmarkettrend"] = function()
    local market = EPC and EPC.MarketPriceChecker
    if not market then return end
    local link = market.lastTooltipLink or (type(market.GetHoveredItemLink029683) == "function" and market:GetHoveredItemLink029683())
    if type(link) ~= "string" or link == "" then
        if EPC and type(EPC.Print) == "function" then EPC:Print("Hover an item first, then use /easmarkettrend.") end
        return
    end
    if EPC and type(EPC.Print) == "function" then
        EPC:Print(clean(market:FormatLiveMarketAnalytics029688(link)))
    end
end

if type(zo_callLater) == "function" then
    zo_callLater(function()
        local market = EPC and EPC.MarketPriceChecker
        if market and market.QueueLiveMarketHistoryPrune029688 then market:QueueLiveMarketHistoryPrune029688(75) end
    end, 5500)
end

EPC.marketPriceLiveAnalytics029688 = true