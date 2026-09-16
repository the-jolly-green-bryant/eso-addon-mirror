-- ESO Adventurer Suite
-- Market price checker + located guild-trader travel helper.
-- Uses installed ESO-Hub/TTC price data, never performs network I/O from ESO.

local EPC = ESOProgressionCoach
if not EPC then return end

EPC.MarketPriceChecker = EPC.MarketPriceChecker or {}
local M = EPC.MarketPriceChecker

EPC.defaults.marketPriceCheckerEnabled029683 = true
EPC.defaults.marketPriceTooltipEnabled029683 = true
EPC.defaults.marketPriceTravelEnabled029683 = true
EPC.defaults.marketPriceSource029683 = "FRESHEST"
EPC.defaults.marketPriceMaxDealAgeHours029683 = 24
EPC.defaults.marketPriceUseTTCLocations029683 = true

local NAME = (EPC.name or "ESOAdventurerSuite") .. "_MarketPriceChecker029683"
local GOLD = "|cFFD700"
local WHITE = "|cFFFFFF"
local GREY = "|cA0A0A0"
local GREEN = "|c66FF66"
local YELLOW = "|cFFFF66"
local ORANGE = "|cFFAA55"
local RED = "|cFF6666"
local CYAN = "|c66CCFF"
local RESET = "|r"

-- Kiosk ids and friendly locations are derived from factual trader-location
-- observations in the user-supplied TTC/ESO-Hub updater reference. The updater
-- itself is not bundled or executed by ESO Adventurer Suite. The exact guild/listing
-- still comes from a live/local listing record; aggregate price tables do not name
-- the guild trader that owns the global minimum.
local KIOSK_LOCATIONS = {
    [0] = { label = "Belkarth", zone = "Craglorn" },
    [1] = { label = "Belkarth Outlaws Refuge", zone = "Craglorn" },
    [2] = { label = "The Hollow City", zone = "Coldharbour" },
    [3] = { label = "Haj Uxith Wayshrine", zone = "Coldharbour" },
    [4] = { label = "Court of Contempt Wayshrine", zone = "Coldharbour" },
    [5] = { label = "Rawl'kha", zone = "Reaper's March" },
    [6] = { label = "Rawl'kha Outlaws Refuge", zone = "Reaper's March" },
    [7] = { label = "Vinedusk Wayshrine", zone = "Reaper's March" },
    [8] = { label = "Dune", zone = "Reaper's March" },
    [9] = { label = "Baandari Trading Post", zone = "Malabal Tor" },
    [10] = { label = "Dra'bul Wayshrine", zone = "Malabal Tor" },
    [11] = { label = "Valeguard Wayshrine", zone = "Malabal Tor" },
    [12] = { label = "Velyn Harbor Outlaws Refuge", zone = "Malabal Tor" },
    [13] = { label = "Marbruk", zone = "Greenshade" },
    [14] = { label = "Marbruk Outlaws Refuge", zone = "Greenshade" },
    [15] = { label = "Verrant Morass Wayshrine", zone = "Greenshade" },
    [16] = { label = "Greenheart Wayshrine", zone = "Greenshade" },
    [17] = { label = "Elden Root", zone = "Grahtwood" },
    [18] = { label = "Elden Root Outlaws Refuge", zone = "Grahtwood" },
    [19] = { label = "Cormount Wayshrine", zone = "Grahtwood" },
    [20] = { label = "Southpoint Wayshrine", zone = "Grahtwood" },
    [21] = { label = "Skywatch", zone = "Auridon" },
    [22] = { label = "Firsthold Wayshrine", zone = "Auridon" },
    [23] = { label = "Vulkhel Guard", zone = "Auridon" },
    [24] = { label = "Vulkhel Guard Outlaws Refuge", zone = "Auridon" },
    [25] = { label = "Mistral", zone = "Khenarthi's Roost" },
    [26] = { label = "Evermore", zone = "Bangkorai" },
    [27] = { label = "Evermore Outlaws Refuge", zone = "Bangkorai" },
    [28] = { label = "Bangkorai Pass Wayshrine", zone = "Bangkorai" },
    [29] = { label = "Hallin's Stand", zone = "Bangkorai" },
    [30] = { label = "Sentinel", zone = "Alik'r Desert" },
    [31] = { label = "Sentinel Outlaws Refuge", zone = "Alik'r Desert" },
    [32] = { label = "Morwha's Bounty Wayshrine", zone = "Alik'r Desert" },
    [33] = { label = "Bergama Wayshrine", zone = "Alik'r Desert" },
    [34] = { label = "Shornhelm", zone = "Rivenspire" },
    [35] = { label = "Shornhelm Outlaws Refuge", zone = "Rivenspire" },
    [36] = { label = "Hoarfrost Downs", zone = "Rivenspire" },
    [37] = { label = "Oldgate Wayshrine", zone = "Rivenspire" },
    [38] = { label = "Wayrest", zone = "Stormhaven" },
    [39] = { label = "Wayrest Outlaws Refuge", zone = "Stormhaven" },
    [40] = { label = "Firebrand Keep Wayshrine", zone = "Stormhaven" },
    [41] = { label = "Koeglin Village", zone = "Stormhaven" },
    [42] = { label = "Daggerfall", zone = "Glenumbra" },
    [43] = { label = "Daggerfall Outlaws Refuge", zone = "Glenumbra" },
    [44] = { label = "Lion Guard Redoubt Wayshrine", zone = "Glenumbra" },
    [45] = { label = "Wyrd Tree Wayshrine", zone = "Glenumbra" },
    [46] = { label = "Stonetooth", zone = "Betnikh" },
    [47] = { label = "Port Hunding", zone = "Stros M'Kai" },
    [48] = { label = "Riften", zone = "The Rift" },
    [49] = { label = "Riften Outlaws Refuge", zone = "The Rift" },
    [50] = { label = "Nimalten", zone = "The Rift" },
    [51] = { label = "Fallowstone Hall", zone = "The Rift" },
    [52] = { label = "Windhelm", zone = "Eastmarch" },
    [53] = { label = "Windhelm Outlaws Refuge", zone = "Eastmarch" },
    [54] = { label = "Voljar Meadery Wayshrine", zone = "Eastmarch" },
    [55] = { label = "Fort Amol", zone = "Eastmarch" },
    [56] = { label = "Stormhold", zone = "Shadowfen" },
    [57] = { label = "Stormhold Outlaws Refuge", zone = "Shadowfen" },
    [58] = { label = "Venomous Fens Wayshrine", zone = "Shadowfen" },
    [59] = { label = "Hissmir Wayshrine", zone = "Shadowfen" },
    [60] = { label = "Mournhold", zone = "Deshaan" },
    [61] = { label = "Mournhold Outlaws Refuge", zone = "Deshaan" },
    [62] = { label = "Tal'Deic Grounds Wayshrine", zone = "Deshaan" },
    [63] = { label = "Muth Gnaar Hills Wayshrine", zone = "Deshaan" },
    [64] = { label = "Ebonheart", zone = "Stonefalls" },
    [65] = { label = "Kragenmoor", zone = "Stonefalls" },
    [66] = { label = "Davon's Watch", zone = "Stonefalls" },
    [67] = { label = "Davon's Watch Outlaws Refuge", zone = "Stonefalls" },
    [68] = { label = "Dhalmora", zone = "Bal Foyen" },
    [69] = { label = "Bleakrock Wayshrine", zone = "Bleakrock Isle" },
    [70] = { label = "Orsinium", zone = "Wrothgar" },
    [71] = { label = "Orsinium Outlaws Refuge", zone = "Wrothgar" },
    [72] = { label = "Morkul Stronghold", zone = "Wrothgar" },
    [73] = { label = "Thieves Den", zone = "Hew's Bane" },
    [74] = { label = "Abah's Landing", zone = "Hew's Bane" },
    [75] = { label = "Anvil", zone = "Gold Coast" },
    [76] = { label = "Kvatch", zone = "Gold Coast" },
    [77] = { label = "Anvil Outlaws Refuge", zone = "Gold Coast" },
    [78] = { label = "Vivec City", zone = "Vvardenfell" },
    [79] = { label = "Vivec City Outlaws Refuge", zone = "Vvardenfell" },
    [80] = { label = "Sadrith Mora", zone = "Vvardenfell" },
    [81] = { label = "Balmora", zone = "Vvardenfell" },
    [82] = { label = "Brass Fortress", zone = "Clockwork City" },
    [83] = { label = "Brass Fortress Outlaws Refuge", zone = "Clockwork City" },
    [84] = { label = "Lillandril", zone = "Summerset" },
    [85] = { label = "Shimmerene", zone = "Summerset" },
    [86] = { label = "Alinor", zone = "Summerset" },
    [87] = { label = "Alinor Outlaws Refuge", zone = "Summerset" },
    [88] = { label = "Lilmoth", zone = "Murkmire" },
    [89] = { label = "Lilmoth Outlaws Refuge", zone = "Murkmire" },
    [90] = { label = "Rimmen", zone = "Northern Elsweyr" },
    [91] = { label = "Rimmen Outlaws Refuge", zone = "Northern Elsweyr" },
    [92] = { label = "Senchal", zone = "Southern Elsweyr" },
    [93] = { label = "Senchal Outlaws Refuge", zone = "Southern Elsweyr" },
    [94] = { label = "Solitude", zone = "Western Skyrim" },
    [95] = { label = "Solitude Outlaws Refuge", zone = "Western Skyrim" },
    [96] = { label = "Markarth", zone = "The Reach" },
    [97] = { label = "Markarth Outlaws Refuge", zone = "The Reach" },
    [98] = { label = "Leyawiin", zone = "Blackwood" },
    [99] = { label = "Leyawiin Outlaws Refuge", zone = "Blackwood" },
    [100] = { label = "Fargrave", zone = "Fargrave" },
    [101] = { label = "Fargrave Outlaws Refuge", zone = "Fargrave" },
    [102] = { label = "Gonfalon Bay", zone = "High Isle" },
    [103] = { label = "Gonfalon Bay Outlaws Refuge", zone = "High Isle" },
    [104] = { label = "Vastyr", zone = "Galen" },
    [105] = { label = "Vastyr Outlaws Refuge", zone = "Galen" },
    [106] = { label = "Necrom", zone = "Telvanni Peninsula" },
    [107] = { label = "Necrom Outlaws Refuge", zone = "Telvanni Peninsula" },
    [108] = { label = "Skingrad", zone = "West Weald" },
    [109] = { label = "Skingrad Outlaws Refuge", zone = "West Weald" },
    [110] = { label = "Sunport", zone = "Solstice" },
    [111] = { label = "Sunport Outlaws Refuge", zone = "Solstice" },
}
M.KIOSK_LOCATIONS = KIOSK_LOCATIONS

local function safeField(object, key)
    if object == nil then return nil end
    local ok, value = pcall(function() return object[key] end)
    if ok then return value end
    return nil
end

local function clean(value)
    local text = tostring(value or "")
    if type(zo_strformat) == "function" then
        local ok, formatted = pcall(zo_strformat, "<<1>>", text)
        if ok and type(formatted) == "string" and formatted ~= "" then text = formatted end
    end
    text = text:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
    text = text:gsub("[%c]+", " "):gsub("%s+", " ")
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    return text
end

local function lower(value)
    return string.lower(clean(value))
end

local function formatNumber(value)
    local n = tonumber(value)
    if not n then return "-" end
    n = math.floor(n + 0.5)
    if type(ZO_CommaDelimitDecimalNumber) == "function" then
        local ok, formatted = pcall(ZO_CommaDelimitDecimalNumber, n)
        if ok and formatted then return tostring(formatted) end
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

local function now()
    if type(GetTimeStamp) == "function" then
        local ok, value = pcall(GetTimeStamp)
        if ok then return tonumber(value) or 0 end
    end
    return 0
end

local function itemKey(itemLink)
    itemLink = tostring(itemLink or "")
    if itemLink == "" then return nil end
    local payload = itemLink:match("|H%d+:item:([^|]+)|h")
    if payload and payload ~= "" then return payload end
    return itemLink
end

local function itemName(itemLink)
    if type(GetItemLinkName) == "function" then
        local ok, value = pcall(GetItemLinkName, itemLink)
        if ok and value and value ~= "" then
            if type(zo_strformat) == "function" and SI_TOOLTIP_ITEM_NAME ~= nil then
                local fmtOk, formatted = pcall(zo_strformat, SI_TOOLTIP_ITEM_NAME, value)
                if fmtOk and formatted and formatted ~= "" then return tostring(formatted) end
            end
            return tostring(value)
        end
    end
    return "Item"
end

local function formatAge(seconds)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0))
    if seconds < 60 then return tostring(seconds) .. "s" end
    local minutes = math.floor(seconds / 60)
    if minutes < 60 then return tostring(minutes) .. "m" end
    local hours = math.floor(minutes / 60)
    if hours < 48 then return tostring(hours) .. "h " .. tostring(minutes % 60) .. "m" end
    local days = math.floor(hours / 24)
    return tostring(days) .. "d " .. tostring(hours % 24) .. "h"
end

local function statusForAge(seconds)
    local hours = (tonumber(seconds) or 0) / 3600
    if hours <= 6 then return "FRESH", GREEN end
    if hours <= 24 then return "CURRENT", CYAN end
    if hours <= 72 then return "AGING", YELLOW end
    return "STALE", RED
end

local function currentSettings()
    local saved = EPC.saved or {}
    return {
        enabled = saved.marketPriceCheckerEnabled029683 ~= false,
        tooltip = saved.marketPriceTooltipEnabled029683 ~= false,
        travel = saved.marketPriceTravelEnabled029683 ~= false,
        source = tostring(saved.marketPriceSource029683 or "FRESHEST"),
        maxDealAgeHours = math.max(1, tonumber(saved.marketPriceMaxDealAgeHours029683) or 24),
        useTTCLocations = saved.marketPriceUseTTCLocations029683 ~= false,
    }
end

function M:GetESOHubData029683(itemLink)
    local lib = rawget(_G, "LibEsoHubPrices")
    if type(lib) ~= "table" or type(lib.GetItemPriceData) ~= "function" then return nil end
    local ok, data = pcall(lib.GetItemPriceData, itemLink)
    if not ok or type(data) ~= "table" then return nil end

    local internal = lib.internal
    local ts = type(internal) == "table" and tonumber(internal.dataTimeStamp) or 0
    return {
        source = "ESO-Hub",
        timestamp = ts or 0,
        min = tonumber(data.listingPriceMin),
        max = tonumber(data.listingPriceMax),
        avg = tonumber(data.averageListing),
        listings = tonumber(data.numberOfListings),
        suggestedMin = tonumber(data.suggestedListingPriceMin),
        suggestedMax = tonumber(data.suggestedListingPriceMax),
        saleAvg = tonumber(data.averageSales),
        sales = tonumber(data.numberOfSales),
    }
end

function M:GetTTCData029683(itemLink)
    local price = rawget(_G, "TamrielTradeCentrePrice")
    if type(price) ~= "table" or type(price.GetPriceInfo) ~= "function" then return nil end
    local ok, data = pcall(price.GetPriceInfo, price, itemLink)
    if not ok or type(data) ~= "table" then return nil end

    local ts = 0
    local tableData = safeField(price, "PriceTable")
    if type(tableData) == "table" then ts = tonumber(tableData.TimeStamp) or 0 end
    local suggested = tonumber(data.SuggestedPrice)
    return {
        source = "TTC",
        timestamp = ts,
        min = tonumber(data.Min),
        max = tonumber(data.Max),
        avg = tonumber(data.Avg),
        listings = tonumber(data.EntryCount),
        suggestedMin = suggested,
        suggestedMax = suggested and (suggested * 1.25) or nil,
        saleAvg = tonumber(data.SaleAvg),
        sales = tonumber(data.SaleEntryCount),
    }
end

function M:GetMarketData029683(itemLink)
    local settings = currentSettings()
    if not settings.enabled then return nil end

    local eh = self:GetESOHubData029683(itemLink)
    local ttc = self:GetTTCData029683(itemLink)
    if settings.source == "ESOHUB" then return eh or ttc end
    if settings.source == "TTC" then return ttc or eh end
    if eh and ttc then
        local ehTs = tonumber(eh.timestamp) or 0
        local ttcTs = tonumber(ttc.timestamp) or 0
        if ttcTs > ehTs then return ttc end
        return eh
    end
    return eh or ttc
end

function M:GetLocationInfo029683(record)
    if type(record) ~= "table" then return nil end
    local kioskId = tonumber(record.kioskId)
    local mapped = kioskId and KIOSK_LOCATIONS[kioskId] or nil
    if mapped then
        return {
            label = mapped.label,
            zone = mapped.zone,
            kioskId = kioskId,
        }
    end

    local label = clean(record.locationName or record.traderName or "")
    local zone = clean(record.zoneName or "")
    if label == "" and zone == "" then return nil end
    return { label = label ~= "" and label or zone, zone = zone, kioskId = kioskId }
end

function M:PutLocatedListing029683(record)
    if type(record) ~= "table" or not record.itemLink then return end
    local key = itemKey(record.itemLink)
    if not key then return end
    local unit = tonumber(record.unitPrice)
    if not unit or unit <= 0 then return end

    self.sessionLocated = self.sessionLocated or {}
    local old = self.sessionLocated[key]
    local oldExpired = old and tonumber(old.expireAt) and tonumber(old.expireAt) > 0 and tonumber(old.expireAt) <= now()
    if not old or oldExpired or unit < (tonumber(old.unitPrice) or math.huge) or (unit == tonumber(old.unitPrice) and (tonumber(record.seenAt) or 0) > (tonumber(old.seenAt) or 0)) then
        self.sessionLocated[key] = record
    end
end

function M:GetLocatedListing029683(itemLink)
    local key = itemKey(itemLink)
    if not key then return nil end
    local currentTime = now()
    local best = self.sessionLocated and self.sessionLocated[key] or nil
    if best and tonumber(best.expireAt) and tonumber(best.expireAt) > 0 and tonumber(best.expireAt) <= currentTime then
        best = nil
    end

    local settings = currentSettings()
    if settings.useTTCLocations and self.ttcLocated then
        local ttc = self.ttcLocated[key]
        if ttc and (not tonumber(ttc.expireAt) or tonumber(ttc.expireAt) <= 0 or tonumber(ttc.expireAt) > currentTime) then
            if not best or (tonumber(ttc.unitPrice) or math.huge) < (tonumber(best.unitPrice) or math.huge) then
                best = ttc
            end
        end
    end
    return best
end

function M:RecordCurrentTraderResults029683()
    local settings = currentSettings()
    if not settings.enabled then return end
    if type(GetTradingHouseSearchResultsInfo) ~= "function" or type(GetTradingHouseSearchResultItemLink) ~= "function" then return end

    local okInfo, count = pcall(GetTradingHouseSearchResultsInfo)
    count = okInfo and tonumber(count) or 0
    if not count or count <= 0 then return end

    local guildId, guildName = 0, ""
    if type(GetCurrentTradingHouseGuildDetails) == "function" then
        local okGuild, id, name = pcall(GetCurrentTradingHouseGuildDetails)
        if okGuild then guildId, guildName = tonumber(id) or 0, clean(name) end
    end

    local kioskId = nil
    local ttc = rawget(_G, "TamrielTradeCentre")
    if type(ttc) == "table" and type(ttc.GetCurrentKioskID) == "function" then
        local okKiosk, value = pcall(ttc.GetCurrentKioskID, ttc)
        if okKiosk then kioskId = tonumber(value) end
    end

    local traderName = ""
    if type(GetUnitName) == "function" then
        local okTrader, value = pcall(GetUnitName, "interact")
        if okTrader then traderName = clean(value) end
    end
    local locationName = type(GetPlayerLocationName) == "function" and clean(GetPlayerLocationName()) or ""
    local zoneName = type(GetPlayerActiveZoneName) == "function" and clean(GetPlayerActiveZoneName()) or ""
    local seenAt = now()

    for i = 1, count do
        local okLink, link = pcall(GetTradingHouseSearchResultItemLink, i)
        if okLink and type(link) == "string" and link ~= "" then
            local okRow, _, _, _, stackCount, sellerName, timeRemaining, totalPrice = pcall(GetTradingHouseSearchResultItemInfo, i)
            if okRow then
                stackCount = math.max(1, tonumber(stackCount) or 1)
                totalPrice = tonumber(totalPrice) or 0
                if totalPrice > 0 then
                    self:PutLocatedListing029683({
                        itemLink = link,
                        unitPrice = totalPrice / stackCount,
                        totalPrice = totalPrice,
                        amount = stackCount,
                        sellerName = clean(sellerName),
                        guildName = guildName,
                        guildId = guildId,
                        kioskId = kioskId,
                        traderName = traderName,
                        locationName = locationName,
                        zoneName = zoneName,
                        seenAt = seenAt,
                        expireAt = seenAt + math.max(0, tonumber(timeRemaining) or 0),
                        source = "LIVE",
                    })
                end
            end
        end
    end
end

function M:StartTTCSeenIndex029683(force)
    local settings = currentSettings()
    if not settings.useTTCLocations then return end
    if self.ttcIndexBuilding then return end
    if self.ttcIndexReady and not force then return end

    local ttc = rawget(_G, "TamrielTradeCentre")
    local data = type(ttc) == "table" and safeField(ttc, "Data") or nil
    local auto = type(data) == "table" and data.AutoRecordEntries or nil
    local guilds = type(auto) == "table" and auto.Guilds or nil
    if type(guilds) ~= "table" then
        self.ttcIndexReady = true
        self.ttcLocated = {}
        return
    end

    self.ttcIndexBuilding = true
    self.ttcIndexReady = false
    self.ttcLocated = {}
    local target = self.ttcLocated
    local currentTime = now()

    local co = coroutine.create(function()
        local processed = 0
        for guildName, guildData in pairs(guilds) do
            if type(guildData) == "table" then
                local kioskId = tonumber(guildData.KioskLocationID)
                local lastUpdate = tonumber(guildData.LastUpdate) or 0
                local players = guildData.PlayerListings
                if type(players) == "table" then
                    for sellerName, listings in pairs(players) do
                        if type(listings) == "table" then
                            for _, entry in pairs(listings) do
                                if type(entry) == "table" then
                                    local link = entry.ItemLink
                                    local amount = math.max(1, tonumber(entry.Amount) or 1)
                                    local total = tonumber(entry.TotalPrice) or 0
                                    local expireAt = tonumber(entry.ExpireTime) or 0
                                    if type(link) == "string" and link ~= "" and total > 0 and (expireAt <= 0 or expireAt > currentTime) then
                                        local key = itemKey(link)
                                        local unit = total / amount
                                        if key and unit > 0 then
                                            local old = target[key]
                                            if not old or unit < (tonumber(old.unitPrice) or math.huge) then
                                                target[key] = {
                                                    itemLink = link,
                                                    unitPrice = unit,
                                                    totalPrice = total,
                                                    amount = amount,
                                                    sellerName = clean(sellerName),
                                                    guildName = clean(guildName),
                                                    kioskId = kioskId,
                                                    seenAt = tonumber(entry.DiscoverTime) or lastUpdate,
                                                    expireAt = expireAt,
                                                    source = "TTC SEEN",
                                                }
                                            end
                                        end
                                    end
                                    processed = processed + 1
                                    if processed % 250 == 0 then coroutine.yield() end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    local function step()
        if not M.ttcIndexBuilding then return end
        local ok, err = coroutine.resume(co)
        if not ok then
            M.ttcIndexBuilding = false
            M.ttcIndexReady = true
            if EPC and type(EPC.Print) == "function" then EPC:Print("Market TTC location index failed: " .. tostring(err)) end
            return
        end
        if coroutine.status(co) == "dead" then
            M.ttcIndexBuilding = false
            M.ttcIndexReady = true
            return
        end
        zo_callLater(step, 16)
    end
    step()
end

local function controlName(control)
    if not control or type(control.GetName) ~= "function" then return "" end
    local ok, value = pcall(control.GetName, control)
    return ok and tostring(value or "") or ""
end

local function getMouseControl()
    local wm = rawget(_G, "WINDOW_MANAGER")
    if wm and type(wm.GetMouseOverControl) == "function" then
        local ok, control = pcall(wm.GetMouseOverControl, wm)
        if ok then return control end
    end
    if type(GetMouseOverControl) == "function" then
        local ok, control = pcall(GetMouseOverControl)
        if ok then return control end
    end
    return nil
end

function M:GetItemLinkFromControl029683(control)
    local current = control
    for _ = 1, 7 do
        if not current then break end
        local dataEntry = safeField(current, "dataEntry")
        local data = type(dataEntry) == "table" and dataEntry.data or safeField(current, "data")
        if type(data) == "table" then
            local link = data.itemLink or data.link
            if type(link) == "string" and link ~= "" then return link end
            local bagId = data.bagId or data.bag
            local slotIndex = data.slotIndex or data.slot
            if bagId ~= nil and slotIndex ~= nil and type(GetItemLink) == "function" then
                local ok, itemLinkValue = pcall(GetItemLink, bagId, slotIndex, LINK_STYLE_DEFAULT)
                if ok and itemLinkValue and itemLinkValue ~= "" then return itemLinkValue end
            end
            local rowIndex = tonumber(data.slotIndex or data.index)
            if rowIndex and type(GetTradingHouseSearchResultItemLink) == "function" then
                local ok, itemLinkValue = pcall(GetTradingHouseSearchResultItemLink, rowIndex)
                if ok and itemLinkValue and itemLinkValue ~= "" then return itemLinkValue end
            end
        end

        local bagId = safeField(current, "bagId")
        local slotIndex = safeField(current, "slotIndex")
        if bagId ~= nil and slotIndex ~= nil and type(GetItemLink) == "function" then
            local ok, itemLinkValue = pcall(GetItemLink, bagId, slotIndex, LINK_STYLE_DEFAULT)
            if ok and itemLinkValue and itemLinkValue ~= "" then return itemLinkValue end
        end

        if type(current.GetParent) ~= "function" then break end
        local ok, parent = pcall(current.GetParent, current)
        current = ok and parent or nil
    end
    return nil
end

function M:GetHoveredItemLink029683()
    local popup = rawget(_G, "PopupTooltip")
    if popup and type(popup.IsHidden) == "function" then
        local okHidden, hidden = pcall(popup.IsHidden, popup)
        if okHidden and hidden == false then
            local link = safeField(popup, "lastLink")
            if type(link) == "string" and link ~= "" then return link end
        end
    end

    local control = getMouseControl()
    if control then
        local link = self:GetItemLinkFromControl029683(control)
        if link then return link end
    end
    return nil
end

function M:EnsureTravelButton029683()
    if self.travelButton or not WINDOW_MANAGER or not GuiRoot then return self.travelButton end
    local button = WINDOW_MANAGER:CreateControl("EASMarketTravelButton029683", GuiRoot, CT_BUTTON)
    button:SetDimensions(220, 30)
    if type(button.SetFont) == "function" then button:SetFont("ZoFontGameBold") end
    button:SetText("TRAVEL TO TRADER")
    button:SetMouseEnabled(true)
    if type(button.SetDrawLayer) == "function" and DL_OVERLAY ~= nil then button:SetDrawLayer(DL_OVERLAY) end
    if type(button.SetDrawTier) == "function" and DT_HIGH ~= nil then button:SetDrawTier(DT_HIGH) end
    button:SetHidden(true)
    button:SetHandler("OnClicked", function()
        if EPC.MarketPriceChecker then EPC.MarketPriceChecker:TravelToActiveListing029683() end
    end)
    self.travelButton = button
    return button
end

local function travelNeedle(label)
    local text = lower(label)
    text = text:gsub(" outlaws refuge", "")
    text = text:gsub(" wayshrine", "")
    text = text:gsub("^the ", "")
    text = text:gsub("%s+", " ")
    return text
end

function M:FindTravelNode029683(location, record)
    if type(location) ~= "table" or type(GetNumFastTravelNodes) ~= "function" or type(GetFastTravelNodeInfo) ~= "function" then return nil end

    if type(record) == "table" and tonumber(record.travelNodeIndex) then
        return tonumber(record.travelNodeIndex), record.travelNodeName
    end

    local needle = travelNeedle(location.label)
    local zoneNeedle = lower(location.zone)
    if needle == "" then return nil end

    local okCount, count = pcall(GetNumFastTravelNodes)
    count = okCount and tonumber(count) or 0
    local bestIndex, bestName, bestScore = nil, nil, -1
    for nodeIndex = 1, (count or 0) do
        local ok, known, nodeName, _, _, _, _, poiType, _, locked = pcall(GetFastTravelNodeInfo, nodeIndex)
        if ok and known == true and locked ~= true and type(nodeName) == "string" and nodeName ~= "" then
            if POI_TYPE_WAYSHRINE == nil or poiType == POI_TYPE_WAYSHRINE then
                local nodeNeedle = travelNeedle(nodeName)
                local score = 0
                if nodeNeedle == needle then
                    score = 1000
                elseif nodeNeedle:find(needle, 1, true) then
                    score = 800
                elseif needle:find(nodeNeedle, 1, true) then
                    score = 650
                else
                    local first = needle:match("^([^%s]+)")
                    if first and #first >= 5 and nodeNeedle:find(first, 1, true) then score = 300 end
                end

                -- Prefer a same-zone wayshrine when the Suite Travel module can
                -- expose zone metadata for the node. This prevents similarly named
                -- places in different zones from winning a loose name match.
                if score > 0 and zoneNeedle ~= "" and EPC.Travel and type(EPC.Travel.GetWayshrineNodeEntry) == "function" then
                    local entryOk, entry = pcall(EPC.Travel.GetWayshrineNodeEntry, EPC.Travel, nodeIndex)
                    if entryOk and type(entry) == "table" then
                        local nodeZone = lower(entry.zoneName)
                        if nodeZone ~= "" and nodeZone == zoneNeedle then
                            score = score + 500
                        elseif nodeZone ~= "" then
                            score = score - 200
                        end
                    end
                end

                if score > bestScore then
                    bestScore, bestIndex, bestName = score, nodeIndex, nodeName
                end
            end
        end
    end
    if bestScore < 300 then return nil end
    if type(record) == "table" then
        record.travelNodeIndex = bestIndex
        record.travelNodeName = bestName
    end
    return bestIndex, bestName
end

function M:TravelToActiveListing029683()
    local settings = currentSettings()
    if not settings.enabled or not settings.travel then return false end
    local record = self.activeLocatedListing
    local location = self:GetLocationInfo029683(record)
    if not location then
        if EPC and type(EPC.Print) == "function" then EPC:Print("No exact trader location is available for this listing yet.") end
        return false
    end

    local nodeIndex, nodeName = self:FindTravelNode029683(location, record)
    if not nodeIndex then
        if EPC and type(EPC.Print) == "function" then
            EPC:Print("No discovered matching wayshrine was found for " .. tostring(location.label) .. ".")
        end
        return false
    end

    -- Reuse the Suite's existing wayshrine travel owner whenever possible so
    -- Market travel follows the same discovered-node validation and messaging as
    -- the Teleporter instead of maintaining a second fast-travel implementation.
    if EPC.Travel and type(EPC.Travel.TravelToWayshrineNode) == "function" then
        local ok, result = pcall(EPC.Travel.TravelToWayshrineNode, EPC.Travel, nodeIndex, nodeName or location.label)
        return ok and result ~= false
    end

    if type(FastTravelToNode) ~= "function" then
        if EPC and type(EPC.Print) == "function" then EPC:Print("ESO's wayshrine travel API is unavailable.") end
        return false
    end

    if EPC and type(EPC.Print) == "function" then
        EPC:Print("Traveling toward " .. tostring(location.label) .. " via " .. tostring(nodeName or "wayshrine") .. ".")
    end
    local ok = pcall(FastTravelToNode, nodeIndex)
    if not ok and EPC and type(EPC.Print) == "function" then
        EPC:Print("ESO rejected the travel request. Try the normal World Map.")
    end
    return ok
end

function M:HideTravelButton029683()
    local button = self.travelButton
    if button then button:SetHidden(true) end
    self.activeLocatedListing = nil
end

function M:UpdateTravelButton029683(tooltip, record)
    local settings = currentSettings()
    local button = self:EnsureTravelButton029683()
    if not button then return end
    if not settings.enabled or not settings.travel or not tooltip or not record then
        self:HideTravelButton029683()
        return
    end

    local location = self:GetLocationInfo029683(record)
    local nodeIndex = location and self:FindTravelNode029683(location, record) or nil
    if not location or not nodeIndex then
        self:HideTravelButton029683()
        return
    end

    self.activeLocatedListing = record
    button:ClearAnchors()
    button:SetAnchor(TOPRIGHT, tooltip, BOTTOMRIGHT, 0, 4)
    local text = "TRAVEL: " .. clean(location.label)
    if #text > 34 then text = string.sub(text, 1, 31) .. "..." end
    button:SetText(text)
    button:SetHidden(false)
end

function M:GetDealLabel029683(located, market)
    if type(located) ~= "table" or type(market) ~= "table" then return nil end
    local live = tonumber(located.unitPrice)
    local low = tonumber(market.min)
    if not live or not low or low <= 0 then return nil end
    local ts = tonumber(market.timestamp) or 0
    local age = ts > 0 and math.max(0, now() - ts) or math.huge
    if age > currentSettings().maxDealAgeHours * 3600 then return nil end

    local pct = ((low - live) / low) * 100
    if pct >= 30 then return string.format("GREAT DEAL  %.0f%% below global low", pct), GREEN end
    if pct >= 15 then return string.format("GOOD DEAL  %.0f%% below global low", pct), GREEN end
    if pct >= 5 then return string.format("BELOW MARKET  %.0f%%", pct), CYAN end
    if pct >= -5 then return "NEAR CURRENT LOW", WHITE end
    return string.format("%.0f%% above current low", math.abs(pct)), ORANGE
end

function M:AppendMarketTooltip029683(tooltip, itemLink)
    local settings = currentSettings()
    if not settings.enabled or not settings.tooltip or not tooltip or type(itemLink) ~= "string" or itemLink == "" then
        self:HideTravelButton029683()
        return
    end

    local market = self:GetMarketData029683(itemLink)
    local located = self:GetLocatedListing029683(itemLink)
    if not market and not located then
        self:HideTravelButton029683()
        return
    end

    if type(tooltip.AddVerticalPadding) == "function" then pcall(tooltip.AddVerticalPadding, tooltip, 5) end
    if type(ZO_Tooltip_AddDivider) == "function" then pcall(ZO_Tooltip_AddDivider, tooltip) end
    if type(tooltip.AddLine) ~= "function" then return end

    pcall(tooltip.AddLine, tooltip, GOLD .. "ESO ADVENTURER SUITE MARKET" .. RESET)

    if market then
        local ts = tonumber(market.timestamp) or 0
        local age = ts > 0 and math.max(0, now() - ts) or nil
        local status, statusColor = "UNKNOWN", GREY
        if age then status, statusColor = statusForAge(age) end
        local ageText = age and (formatAge(age) .. " old") or "timestamp unavailable"
        pcall(tooltip.AddLine, tooltip, string.format("%sSource:%s %s  %s%s%s  %s", GREY, RESET, tostring(market.source), statusColor, status, RESET, ageText))

        local priceBits = {}
        if market.min then priceBits[#priceBits + 1] = "Global Low " .. GOLD .. formatNumber(market.min) .. "g" .. RESET end
        if market.avg then priceBits[#priceBits + 1] = "Avg " .. formatNumber(market.avg) .. "g" end
        if market.listings then priceBits[#priceBits + 1] = formatNumber(market.listings) .. " listings" end
        if #priceBits > 0 then pcall(tooltip.AddLine, tooltip, table.concat(priceBits, "   ")) end

        if market.suggestedMin or market.suggestedMax then
            local lo = market.suggestedMin or market.suggestedMax
            local hi = market.suggestedMax or market.suggestedMin
            local text = lo and hi and lo ~= hi and (formatNumber(lo) .. "-" .. formatNumber(hi) .. "g") or (formatNumber(lo or hi) .. "g")
            pcall(tooltip.AddLine, tooltip, "Suggested " .. text .. (market.saleAvg and ("   Sales Avg " .. formatNumber(market.saleAvg) .. "g") or ""))
        elseif market.saleAvg then
            pcall(tooltip.AddLine, tooltip, "Recent Sale Avg " .. formatNumber(market.saleAvg) .. "g")
        end
    end

    if located then
        local location = self:GetLocationInfo029683(located)
        local locPrice = tonumber(located.unitPrice)
        local guildName = clean(located.guildName)
        local seenAt = tonumber(located.seenAt) or 0
        local seenAge = seenAt > 0 and formatAge(math.max(0, now() - seenAt)) or "unknown"
        local title = "Located lowest seen " .. GOLD .. formatNumber(locPrice) .. "g" .. RESET
        if guildName ~= "" then title = title .. "  " .. CYAN .. guildName .. RESET end
        pcall(tooltip.AddLine, tooltip, title)
        if market and tonumber(market.min) and tonumber(market.min) > 0 and locPrice then
            local delta = math.abs(locPrice - tonumber(market.min))
            local tolerance = math.max(1, tonumber(market.min) * 0.001)
            if delta <= tolerance then
                pcall(tooltip.AddLine, tooltip, GREEN .. "MATCHES GLOBAL LOWEST" .. RESET)
            end
        end
        if location then
            local where = clean(location.label)
            if clean(location.zone) ~= "" and lower(location.zone) ~= lower(where) then where = where .. " - " .. clean(location.zone) end
            pcall(tooltip.AddLine, tooltip, WHITE .. where .. RESET .. GREY .. "  seen " .. seenAge .. " ago" .. (located.source and ("  [" .. tostring(located.source) .. "]") or "") .. RESET)
        end
        local dealText, dealColor = self:GetDealLabel029683(located, market)
        if dealText then pcall(tooltip.AddLine, tooltip, dealColor .. dealText .. RESET) end
    elseif market then
        pcall(tooltip.AddLine, tooltip, GREY .. "Exact trader location is not carried by the aggregate price table." .. RESET)
        pcall(tooltip.AddLine, tooltip, GREY .. "Visit/scan guild traders to build a travel-ready located listing." .. RESET)
    end

    self:UpdateTravelButton029683(tooltip, located)
end

function M:RefreshTooltip029683(tooltip)
    local itemLink = self:GetHoveredItemLink029683()
    if not itemLink then return end
    local key = itemKey(itemLink)
    local control = getMouseControl()
    local controlId = control and controlName(control) or ""
    local signature = tostring(key or "") .. "|" .. tostring(controlId)
    if self.lastTooltipSignature == signature then return end
    self.lastTooltipSignature = signature
    self.lastTooltipLink = itemLink
    self:AppendMarketTooltip029683(tooltip, itemLink)
end

function M:InitializeTooltipHooks029683()
    local tooltip = rawget(_G, "ItemTooltip")
    if not tooltip or type(tooltip.SetHandler) ~= "function" then return end

    tooltip:SetHandler("OnUpdate", function(control)
        if not EPC.MarketPriceChecker then return end
        EPC.MarketPriceChecker:RefreshTooltip029683(control)
    end, CONTROL_HANDLER_ORDER_AFTER)

    local function cleared()
        if not EPC.MarketPriceChecker then return end
        EPC.MarketPriceChecker.lastTooltipSignature = nil
        EPC.MarketPriceChecker.lastTooltipLink = nil
        EPC.MarketPriceChecker:HideTravelButton029683()
    end
    tooltip:SetHandler("OnHide", cleared, CONTROL_HANDLER_ORDER_AFTER)
    tooltip:SetHandler("OnCleared", cleared, CONTROL_HANDLER_ORDER_AFTER)
end

function M:Initialize029683()
    if self.initialized029683 then return end
    self.initialized029683 = true
    self.sessionLocated = {}
    self.ttcLocated = {}

    self:InitializeTooltipHooks029683()
    self:EnsureTravelButton029683()
    zo_callLater(function()
        if EPC.MarketPriceChecker then EPC.MarketPriceChecker:StartTTCSeenIndex029683(false) end
    end, 3500)

    if EVENT_MANAGER and EVENT_TRADING_HOUSE_RESPONSE_RECEIVED ~= nil then
        EVENT_MANAGER:RegisterForEvent(NAME .. "_Trader", EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, function()
            zo_callLater(function()
                if EPC.MarketPriceChecker then EPC.MarketPriceChecker:RecordCurrentTraderResults029683() end
            end, 50)
        end)
    end
    if EVENT_MANAGER and EVENT_CLOSE_TRADING_HOUSE ~= nil then
        EVENT_MANAGER:RegisterForEvent(NAME .. "_Close", EVENT_CLOSE_TRADING_HOUSE, function()
            if EPC.MarketPriceChecker then EPC.MarketPriceChecker:HideTravelButton029683() end
        end)
    end
end

if EVENT_MANAGER and EVENT_PLAYER_ACTIVATED ~= nil then
    EVENT_MANAGER:RegisterForEvent(NAME, EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_PLAYER_ACTIVATED)
        zo_callLater(function()
            if EPC.MarketPriceChecker then EPC.MarketPriceChecker:Initialize029683() end
        end, 500)
    end)
end

SLASH_COMMANDS = SLASH_COMMANDS or {}
SLASH_COMMANDS["/easmarket"] = function()
    if not EPC.MarketPriceChecker then return end
    local link = EPC.MarketPriceChecker.lastTooltipLink or EPC.MarketPriceChecker:GetHoveredItemLink029683()
    if not link then
        if type(EPC.Print) == "function" then EPC:Print("Hover an item, then use /easmarket.") end
        return
    end
    local market = EPC.MarketPriceChecker:GetMarketData029683(link)
    local located = EPC.MarketPriceChecker:GetLocatedListing029683(link)
    local parts = { itemName(link) }
    if market and market.min then parts[#parts + 1] = "global low " .. formatNumber(market.min) .. "g (" .. tostring(market.source) .. ")" end
    if located then
        local loc = EPC.MarketPriceChecker:GetLocationInfo029683(located)
        parts[#parts + 1] = "located " .. formatNumber(located.unitPrice) .. "g" .. (loc and (" at " .. tostring(loc.label)) or "")
    end
    if type(EPC.Print) == "function" then EPC:Print(table.concat(parts, " | ")) end
end

EPC.marketPriceChecker029683 = true
