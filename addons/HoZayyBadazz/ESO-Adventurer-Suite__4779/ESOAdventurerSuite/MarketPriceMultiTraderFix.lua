-- ESO Adventurer Suite
-- Suite Market Price Checker multi-trader persistence and travel-button reliability.
-- Keeps real trader observations beyond TTC's short-lived AutoRecordEntries cleanup,
-- shows multiple known traders for the hovered item, and does not hide TRAVEL merely
-- because a wayshrine cannot be pre-resolved before the user clicks it.

local EPC = ESOProgressionCoach
if not EPC or not EPC.MarketPriceChecker then return end

local M = EPC.MarketPriceChecker
if M._marketPriceMultiTrader029683 then return end
M._marketPriceMultiTrader029683 = true

EPC.defaults = EPC.defaults or {}
EPC.defaults.marketPriceTraderComparisonCount029683 = 5

local GOLD = "|cFFD700"
local WHITE = "|cFFFFFF"
local GREY = "|cA0A0A0"
local GREEN = "|c66FF66"
local CYAN = "|c66CCFF"
local RESET = "|r"

local MAX_TRADERS_PER_ITEM = 12
local MAX_CACHED_ITEMS = 600
local MAX_CACHE_AGE = 30 * 24 * 60 * 60

local function safeNumber(value)
    local n = tonumber(value)
    if not n or n ~= n or n == math.huge or n == -math.huge then return nil end
    return n
end

local function now()
    if type(GetTimeStamp) == "function" then
        local ok, value = pcall(GetTimeStamp)
        if ok then return tonumber(value) or 0 end
    end
    return 0
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

local function itemKey(itemLink)
    itemLink = tostring(itemLink or "")
    if itemLink == "" then return nil end
    local payload = itemLink:match("|H%d+:item:([^|]+)|h")
    if payload and payload ~= "" then return payload end
    return itemLink
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

local function cacheRoot()
    EPC.saved = EPC.saved or {}
    if type(EPC.saved.marketPriceTraderCache029683) ~= "table" then
        EPC.saved.marketPriceTraderCache029683 = {}
    end
    return EPC.saved.marketPriceTraderCache029683
end

local function traderIdentity(record)
    if type(record) ~= "table" then return nil end
    local kioskId = safeNumber(record.kioskId)
    local guild = lower(record.guildName)
    local trader = lower(record.traderName)
    local location = lower(record.locationName)
    local zone = lower(record.zoneName)

    if kioskId then
        return "k:" .. tostring(math.floor(kioskId)) .. "|g:" .. guild
    end
    if guild ~= "" then
        return "g:" .. guild .. "|l:" .. location .. "|z:" .. zone
    end
    if trader ~= "" then
        return "t:" .. trader .. "|l:" .. location .. "|z:" .. zone
    end
    if location ~= "" or zone ~= "" then
        return "l:" .. location .. "|z:" .. zone
    end
    return nil
end

local function isExpired(record, currentTime)
    if type(record) ~= "table" then return true end
    currentTime = currentTime or now()
    local expireAt = safeNumber(record.expireAt)
    if expireAt and expireAt > 0 and expireAt <= currentTime then return true end
    local seenAt = safeNumber(record.seenAt)
    if seenAt and seenAt > 0 and currentTime - seenAt > MAX_CACHE_AGE then return true end
    return false
end

local function trimTraderGroup(group)
    if type(group) ~= "table" or type(group.traders) ~= "table" then return end
    local currentTime = now()
    local rows = {}
    for id, record in pairs(group.traders) do
        if isExpired(record, currentTime) then
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
    for i = MAX_TRADERS_PER_ITEM + 1, #rows do
        group.traders[rows[i].id] = nil
    end
end

function M:PrunePersistentTraderCache029683()
    local root = cacheRoot()
    local currentTime = now()
    local groups = {}
    for key, group in pairs(root) do
        if type(group) ~= "table" then
            root[key] = nil
        else
            group.traders = type(group.traders) == "table" and group.traders or {}
            trimTraderGroup(group)
            local lastSeen = safeNumber(group.lastSeen) or 0
            local any = next(group.traders) ~= nil
            if not any or (lastSeen > 0 and currentTime - lastSeen > MAX_CACHE_AGE) then
                root[key] = nil
            else
                groups[#groups + 1] = { key = key, lastSeen = lastSeen }
            end
        end
    end
    if #groups > MAX_CACHED_ITEMS then
        table.sort(groups, function(a, b) return a.lastSeen > b.lastSeen end)
        for i = MAX_CACHED_ITEMS + 1, #groups do root[groups[i].key] = nil end
    end
end

function M:StorePersistentTraderListing029683(record)
    if type(record) ~= "table" or type(record.itemLink) ~= "string" or record.itemLink == "" then return false end
    local key = itemKey(record.itemLink)
    local identity = traderIdentity(record)
    local unitPrice = safeNumber(record.unitPrice)
    if not key or not identity or not unitPrice or unitPrice <= 0 then return false end

    local currentTime = now()
    if isExpired(record, currentTime) then return false end

    local root = cacheRoot()
    local group = root[key]
    if type(group) ~= "table" then
        group = { lastSeen = 0, traders = {} }
        root[key] = group
    end
    group.traders = type(group.traders) == "table" and group.traders or {}

    local seenAt = safeNumber(record.seenAt) or currentTime
    local old = group.traders[identity]
    local replace = old == nil or isExpired(old, currentTime)
    if old and not replace then
        local oldSeen = safeNumber(old.seenAt) or 0
        local oldPrice = safeNumber(old.unitPrice) or math.huge
        -- Newer observations replace older ones. Within the same observation time,
        -- keep the cheaper row for that trader.
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
    trimTraderGroup(group)
    return true
end

local basePutLocatedListing029683 = M.PutLocatedListing029683
function M:PutLocatedListing029683(record)
    self:StorePersistentTraderListing029683(record)
    return basePutLocatedListing029683(self, record)
end

function M:ImportTTCTraderHistory029683(force)
    if self.ttcPersistentImportBuilding then return end
    if self.ttcPersistentImportReady and not force then return end

    local ttc = rawget(_G, "TamrielTradeCentre")
    local data = type(ttc) == "table" and ttc.Data or nil
    local auto = type(data) == "table" and data.AutoRecordEntries or nil
    local guilds = type(auto) == "table" and auto.Guilds or nil
    if type(guilds) ~= "table" then
        self.ttcPersistentImportReady = true
        return
    end

    self.ttcPersistentImportBuilding = true
    self.ttcPersistentImportReady = false
    local currentTime = now()

    local co = coroutine.create(function()
        local processed = 0
        for guildName, guildData in pairs(guilds) do
            if type(guildData) == "table" then
                local kioskId = safeNumber(guildData.KioskLocationID)
                local lastUpdate = safeNumber(guildData.LastUpdate) or 0
                local players = guildData.PlayerListings
                if type(players) == "table" then
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
                                            guildName = clean(guildName),
                                            kioskId = kioskId,
                                            seenAt = safeNumber(entry.DiscoverTime) or lastUpdate,
                                            expireAt = expireAt,
                                            source = "TTC HISTORY",
                                        })
                                    end
                                    processed = processed + 1
                                    if processed % 200 == 0 then coroutine.yield() end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    local function step()
        if not M.ttcPersistentImportBuilding then return end
        local ok, err = coroutine.resume(co)
        if not ok then
            M.ttcPersistentImportBuilding = false
            M.ttcPersistentImportReady = true
            if EPC and type(EPC.Print) == "function" then EPC:Print("Market multi-trader TTC import failed: " .. tostring(err)) end
            return
        end
        if coroutine.status(co) == "dead" then
            M.ttcPersistentImportBuilding = false
            M.ttcPersistentImportReady = true
            M:PrunePersistentTraderCache029683()
            M.lastTooltipSignature = nil
            return
        end
        if type(zo_callLater) == "function" then zo_callLater(step, 12) else step() end
    end
    step()
end

local baseStartTTCSeenIndex029683 = M.StartTTCSeenIndex029683
function M:StartTTCSeenIndex029683(force)
    local result = baseStartTTCSeenIndex029683(self, force)
    if type(zo_callLater) == "function" then
        zo_callLater(function()
            if EPC.MarketPriceChecker then EPC.MarketPriceChecker:ImportTTCTraderHistory029683(force == true) end
        end, 30)
    else
        self:ImportTTCTraderHistory029683(force == true)
    end
    return result
end

local function currentTraderIdentity()
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

    if kioskId then return "k:" .. tostring(math.floor(kioskId)) .. "|g:" .. lower(guildName), kioskId, guildName, guildId end
    if guildName ~= "" then return "g:" .. lower(guildName), kioskId, guildName, guildId end
    return nil, kioskId, guildName, guildId
end

function M:GetComparableTraderListings029683(itemLink, limit)
    local key = itemKey(itemLink)
    if not key then return {} end
    local root = cacheRoot()
    local group = root[key]
    if type(group) ~= "table" or type(group.traders) ~= "table" then return {} end

    trimTraderGroup(group)
    local currentIdentity, currentKiosk, currentGuild = currentTraderIdentity()
    local currentGuildLower = lower(currentGuild)
    local rows = {}
    local currentTime = now()

    for id, record in pairs(group.traders) do
        if type(record) == "table" and not isExpired(record, currentTime) then
            local isCurrent = false
            local recordKiosk = safeNumber(record.kioskId)
            local recordGuild = lower(record.guildName)
            if currentKiosk and recordKiosk and math.floor(currentKiosk) == math.floor(recordKiosk) then
                if currentGuildLower == "" or recordGuild == "" or currentGuildLower == recordGuild then isCurrent = true end
            elseif currentIdentity and id == currentIdentity then
                isCurrent = true
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

    limit = math.max(1, math.floor(safeNumber(limit) or EPC.defaults.marketPriceTraderComparisonCount029683 or 5))
    while #rows > limit do table.remove(rows) end
    return rows
end

function M:GetBestTravelTrader029683(itemLink)
    local rows = self:GetComparableTraderListings029683(itemLink, MAX_TRADERS_PER_ITEM)
    for _, record in ipairs(rows) do
        if not record._easCurrentTrader and self:GetLocationInfo029683(record) then return record end
    end
    for _, record in ipairs(rows) do
        if self:GetLocationInfo029683(record) then return record end
    end
    return self:GetLocatedListing029683(itemLink)
end

-- The old implementation hid the button unless a matching discovered wayshrine
-- was found during tooltip construction. Keep the button visible whenever a real
-- trader location exists. TravelToActiveListing029683 performs the authoritative
-- wayshrine lookup after the user clicks it and can explain any failure.
function M:UpdateTravelButton029683(tooltip, record)
    local saved = EPC.saved or {}
    local button = self:EnsureTravelButton029683()
    if not button then return end
    if saved.marketPriceCheckerEnabled029683 == false or saved.marketPriceTravelEnabled029683 == false or not tooltip or not record then
        self:HideTravelButton029683()
        return
    end

    local location = self:GetLocationInfo029683(record)
    if not location then
        self:HideTravelButton029683()
        return
    end

    self.activeLocatedListing = record
    button:SetDimensions(260, 34)
    button:ClearAnchors()

    local placeAbove = false
    if type(tooltip.GetBottom) == "function" and GuiRoot and type(GuiRoot.GetHeight) == "function" then
        local okBottom, bottom = pcall(tooltip.GetBottom, tooltip)
        local okHeight, height = pcall(GuiRoot.GetHeight, GuiRoot)
        if okBottom and okHeight and safeNumber(bottom) and safeNumber(height) and bottom + 42 > height then placeAbove = true end
    end
    if placeAbove then
        button:SetAnchor(BOTTOMRIGHT, tooltip, TOPRIGHT, 0, -4)
    else
        button:SetAnchor(TOPRIGHT, tooltip, BOTTOMRIGHT, 0, 4)
    end

    local label = clean(location.label)
    local text = "TRAVEL TO: " .. label
    if #text > 40 then text = string.sub(text, 1, 37) .. "..." end
    button:SetText(text)

    if not button._easMarketBackdrop and WINDOW_MANAGER then
        local bg = WINDOW_MANAGER:CreateControl("EASMarketTravelButtonBackdrop029683", button, CT_BACKDROP)
        bg:SetAnchorFill(button)
        if type(bg.SetCenterColor) == "function" then bg:SetCenterColor(0.04, 0.04, 0.04, 0.96) end
        if type(bg.SetEdgeColor) == "function" then bg:SetEdgeColor(0.85, 0.65, 0.12, 1) end
        if type(bg.SetEdgeTexture) == "function" then pcall(bg.SetEdgeTexture, bg, nil, 1, 1, 1) end
        if type(bg.SetDrawLayer) == "function" and DL_BACKGROUND ~= nil then bg:SetDrawLayer(DL_BACKGROUND) end
        button._easMarketBackdrop = bg
    end

    button:SetHidden(false)
end

local baseAppendMarketTooltip029683 = M.AppendMarketTooltip029683
function M:AppendMarketTooltip029683(tooltip, itemLink)
    baseAppendMarketTooltip029683(self, tooltip, itemLink)

    local saved = EPC.saved or {}
    if saved.marketPriceCheckerEnabled029683 == false or saved.marketPriceTooltipEnabled029683 == false then return end
    if not tooltip or type(tooltip.AddLine) ~= "function" or type(itemLink) ~= "string" or itemLink == "" then return end

    local requested = math.max(1, math.floor(safeNumber(saved.marketPriceTraderComparisonCount029683) or EPC.defaults.marketPriceTraderComparisonCount029683 or 5))
    requested = math.min(MAX_TRADERS_PER_ITEM, requested)
    local rows = self:GetComparableTraderListings029683(itemLink, requested)

    if #rows > 0 then
        pcall(tooltip.AddLine, tooltip, CYAN .. "TRADER COMPARISON" .. RESET .. GREY .. "  (real listings seen by this client)" .. RESET)
        for i, record in ipairs(rows) do
            local price = formatNumber(record.unitPrice) .. "g"
            local guild = clean(record.guildName)
            local location = self:GetLocationInfo029683(record)
            local where = location and clean(location.label) or clean(record.locationName)
            local seenAt = safeNumber(record.seenAt) or 0
            local age = seenAt > 0 and formatAge(math.max(0, now() - seenAt)) or "unknown"
            local marker = record._easCurrentTrader and (GREEN .. "CURRENT" .. RESET) or (WHITE .. "OTHER" .. RESET)
            local line = tostring(i) .. ". " .. GOLD .. price .. RESET .. "  " .. marker
            if guild ~= "" then line = line .. "  " .. CYAN .. guild .. RESET end
            if where ~= "" then line = line .. "  " .. WHITE .. where .. RESET end
            line = line .. GREY .. "  seen " .. age .. " ago" .. RESET
            pcall(tooltip.AddLine, tooltip, line)
        end
    else
        pcall(tooltip.AddLine, tooltip, GREY .. "No other trader locations cached for this exact item yet." .. RESET)
        pcall(tooltip.AddLine, tooltip, GREY .. "The Suite now permanently remembers real traders as you search them." .. RESET)
    end

    local travelRecord = self:GetBestTravelTrader029683(itemLink)
    self:UpdateTravelButton029683(tooltip, travelRecord)
end

-- A small diagnostic command is useful when checking whether cross-trader data
-- exists without guessing from the tooltip.
SLASH_COMMANDS = SLASH_COMMANDS or {}
SLASH_COMMANDS["/easmarkettraders"] = function()
    if not EPC.MarketPriceChecker then return end
    local link = EPC.MarketPriceChecker.lastTooltipLink or EPC.MarketPriceChecker:GetHoveredItemLink029683()
    if not link then
        if type(EPC.Print) == "function" then EPC:Print("Hover an item, then use /easmarkettraders.") end
        return
    end
    local rows = EPC.MarketPriceChecker:GetComparableTraderListings029683(link, MAX_TRADERS_PER_ITEM)
    local others = 0
    for _, row in ipairs(rows) do if not row._easCurrentTrader then others = others + 1 end end
    if type(EPC.Print) == "function" then
        EPC:Print("Market cache: " .. tostring(#rows) .. " known trader(s) for this exact item; " .. tostring(others) .. " other trader(s).")
    end
end

if type(zo_callLater) == "function" then
    zo_callLater(function()
        if EPC.MarketPriceChecker then
            EPC.MarketPriceChecker:PrunePersistentTraderCache029683()
            EPC.MarketPriceChecker:ImportTTCTraderHistory029683(false)
        end
    end, 4500)
end

EPC.marketPriceMultiTrader029683 = true
