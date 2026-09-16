-- ESO Adventurer Suite
-- Market Price Checker polish: ESO-Hub-first source policy, TTC cross-check,
-- and exact hovered Guild Trader row deal comparison.

local EPC = ESOProgressionCoach
if not EPC or not EPC.MarketPriceChecker then return end

local M = EPC.MarketPriceChecker
if M._marketPricePolish029683 then return end
M._marketPricePolish029683 = true

-- ESO-Hub is the Suite's primary aggregate source. TTC remains the fallback and
-- cross-check source. The user can still explicitly choose TTC or Freshest Available.
EPC.defaults = EPC.defaults or {}
EPC.defaults.marketPriceSource029683 = "ESOHUB"

local GOLD = "|cFFD700"
local WHITE = "|cFFFFFF"
local GREY = "|cA0A0A0"
local GREEN = "|c66FF66"
local CYAN = "|c66CCFF"
local YELLOW = "|cFFFF66"
local ORANGE = "|cFFAA55"
local RED = "|cFF6666"
local RESET = "|r"

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
    if minutes < 60 then return tostring(minutes) .. "m " .. tostring(seconds % 60) .. "s" end
    local hours = math.floor(minutes / 60)
    if hours < 48 then return tostring(hours) .. "h " .. tostring(minutes % 60) .. "m" end
    local days = math.floor(hours / 24)
    return tostring(days) .. "d " .. tostring(hours % 24) .. "h"
end

local function ageColor(seconds)
    local hours = (safeNumber(seconds) or math.huge) / 3600
    if hours <= 6 then return GREEN end
    if hours <= 24 then return CYAN end
    if hours <= 72 then return YELLOW end
    return RED
end

local function marketReference(market)
    if type(market) ~= "table" then return nil, nil end

    local saleAvg = safeNumber(market.saleAvg)
    if saleAvg and saleAvg > 0 then
        return saleAvg, "recent sale avg"
    end

    local lo = safeNumber(market.suggestedMin)
    local hi = safeNumber(market.suggestedMax)
    if lo and lo > 0 and hi and hi > 0 then
        return (lo + hi) * 0.5, "suggested midpoint"
    end
    if lo and lo > 0 then return lo, "suggested price" end
    if hi and hi > 0 then return hi, "suggested price" end

    local avg = safeNumber(market.avg)
    if avg and avg > 0 then return avg, "average listing" end

    local low = safeNumber(market.min)
    if low and low > 0 then return low, "global low" end
    return nil, nil
end

function M:GetMarketSources029683(itemLink)
    local saved = EPC.saved or {}
    if saved.marketPriceCheckerEnabled029683 == false then return nil, nil end

    local esoHub = self:GetESOHubData029683(itemLink)
    local ttc = self:GetTTCData029683(itemLink)
    local preference = tostring(saved.marketPriceSource029683 or EPC.defaults.marketPriceSource029683 or "ESOHUB")

    if preference == "TTC" then
        return ttc or esoHub, (ttc and esoHub) or nil
    end

    if preference == "FRESHEST" then
        if esoHub and ttc then
            local ehTs = safeNumber(esoHub.timestamp) or 0
            local ttcTs = safeNumber(ttc.timestamp) or 0
            if ttcTs > ehTs then return ttc, esoHub end
            return esoHub, ttc
        end
        return esoHub or ttc, nil
    end

    -- Default and explicit ESOHUB mode: ESO-Hub first, TTC fallback/cross-check.
    return esoHub or ttc, (esoHub and ttc) or nil
end

function M:GetMarketData029683(itemLink)
    local primary = self:GetMarketSources029683(itemLink)
    return primary
end

function M:GetDealLabel029683(listing, market)
    if type(listing) ~= "table" or type(market) ~= "table" then return nil end
    local live = safeNumber(listing.unitPrice)
    local reference, basis = marketReference(market)
    if not live or live <= 0 or not reference or reference <= 0 then return nil end

    local ts = safeNumber(market.timestamp) or 0
    local age = ts > 0 and math.max(0, now() - ts) or math.huge
    local maxAgeHours = math.max(1, safeNumber((EPC.saved or {}).marketPriceMaxDealAgeHours029683) or 24)
    if age > maxAgeHours * 3600 then return nil end

    local pct = ((reference - live) / reference) * 100
    if pct >= 35 then
        return string.format("EXCEPTIONAL DEAL  %.0f%% below %s", pct, basis), GREEN, pct, basis
    elseif pct >= 20 then
        return string.format("GREAT DEAL  %.0f%% below %s", pct, basis), GREEN, pct, basis
    elseif pct >= 10 then
        return string.format("GOOD DEAL  %.0f%% below %s", pct, basis), GREEN, pct, basis
    elseif pct >= 5 then
        return string.format("BELOW MARKET  %.0f%% below %s", pct, basis), CYAN, pct, basis
    elseif pct > -5 then
        return string.format("FAIR PRICE  %.0f%% vs %s", math.abs(pct), basis), WHITE, pct, basis
    elseif pct > -15 then
        return string.format("SLIGHT MARKUP  %.0f%% above %s", math.abs(pct), basis), YELLOW, pct, basis
    elseif pct > -30 then
        return string.format("MARKUP  %.0f%% above %s", math.abs(pct), basis), ORANGE, pct, basis
    end
    return string.format("HIGH MARKUP  %.0f%% above %s", math.abs(pct), basis), RED, pct, basis
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

local function safeField(object, key)
    if object == nil then return nil end
    local ok, value = pcall(function() return object[key] end)
    if ok then return value end
    return nil
end

function M:GetHoveredTraderRow029683(expectedItemLink)
    if type(GetTradingHouseSearchResultItemInfo) ~= "function" or type(GetTradingHouseSearchResultItemLink) ~= "function" then return nil end

    local tradingHouse = rawget(_G, "TRADING_HOUSE")
    if tradingHouse and type(tradingHouse.GetCurrentMode) == "function" and ZO_TRADING_HOUSE_MODE_BROWSE ~= nil then
        local okMode, mode = pcall(tradingHouse.GetCurrentMode, tradingHouse)
        if okMode and mode ~= ZO_TRADING_HOUSE_MODE_BROWSE then return nil end
    end

    local control = getMouseControl()
    local rowIndex = nil
    for _ = 1, 8 do
        if not control then break end
        local dataEntry = safeField(control, "dataEntry")
        local data = type(dataEntry) == "table" and dataEntry.data or safeField(control, "data")
        if type(data) == "table" then
            local candidate = safeNumber(data.slotIndex or data.resultIndex or data.index)
            local looksLikeTraderRow = data.purchasePrice ~= nil or data.purchasePricePerUnit ~= nil or data.sellerName ~= nil
            if candidate and candidate >= 1 and looksLikeTraderRow then
                rowIndex = math.floor(candidate)
                break
            end
        end
        if type(control.GetParent) ~= "function" then break end
        local okParent, parent = pcall(control.GetParent, control)
        control = okParent and parent or nil
    end
    if not rowIndex then return nil end

    local okLink, itemLink = pcall(GetTradingHouseSearchResultItemLink, rowIndex)
    if not okLink or type(itemLink) ~= "string" or itemLink == "" then return nil end
    if type(expectedItemLink) == "string" and expectedItemLink ~= "" and itemLink ~= expectedItemLink then
        -- Item links can be equivalent while differing in display-link style. Only
        -- reject when their item IDs prove they are actually different.
        if type(GetItemLinkItemId) == "function" then
            local okA, idA = pcall(GetItemLinkItemId, itemLink)
            local okB, idB = pcall(GetItemLinkItemId, expectedItemLink)
            if okA and okB and tonumber(idA) and tonumber(idB) and tonumber(idA) ~= tonumber(idB) then return nil end
        end
    end

    local okInfo, _, _, _, stackCount, sellerName, timeRemaining, totalPrice, _, itemUniqueId, unitPrice = pcall(GetTradingHouseSearchResultItemInfo, rowIndex)
    if not okInfo then return nil end
    stackCount = math.max(1, safeNumber(stackCount) or 1)
    totalPrice = safeNumber(totalPrice) or 0
    unitPrice = safeNumber(unitPrice) or (totalPrice > 0 and totalPrice / stackCount or nil)
    if not unitPrice or unitPrice <= 0 then return nil end

    return {
        rowIndex = rowIndex,
        itemLink = itemLink,
        unitPrice = unitPrice,
        totalPrice = totalPrice,
        amount = stackCount,
        sellerName = tostring(sellerName or ""),
        timeRemaining = safeNumber(timeRemaining) or 0,
        itemUniqueId = itemUniqueId,
        source = "LIVE ROW",
    }
end

local baseAppendMarketTooltip029683 = M.AppendMarketTooltip029683

function M:AppendMarketTooltip029683(tooltip, itemLink)
    baseAppendMarketTooltip029683(self, tooltip, itemLink)

    local saved = EPC.saved or {}
    if saved.marketPriceCheckerEnabled029683 == false or saved.marketPriceTooltipEnabled029683 == false then return end
    if not tooltip or type(tooltip.AddLine) ~= "function" or type(itemLink) ~= "string" or itemLink == "" then return end

    local primary, cross = self:GetMarketSources029683(itemLink)
    if cross then
        local crossBits = {}
        if safeNumber(cross.min) then crossBits[#crossBits + 1] = "low " .. GOLD .. formatNumber(cross.min) .. "g" .. RESET end
        if safeNumber(cross.avg) then crossBits[#crossBits + 1] = "avg " .. formatNumber(cross.avg) .. "g" end
        if safeNumber(cross.listings) then crossBits[#crossBits + 1] = formatNumber(cross.listings) .. " listings" end

        local ts = safeNumber(cross.timestamp) or 0
        local age = ts > 0 and math.max(0, now() - ts) or nil
        local ageText = age and (ageColor(age) .. formatAge(age) .. " old" .. RESET) or (GREY .. "age unknown" .. RESET)
        local line = CYAN .. "Cross-check " .. tostring(cross.source or "secondary") .. RESET
        if #crossBits > 0 then line = line .. ": " .. table.concat(crossBits, "   ") end
        line = line .. "   " .. ageText
        pcall(tooltip.AddLine, tooltip, line)

        if primary then
            local primaryRef = marketReference(primary)
            local crossRef = marketReference(cross)
            if primaryRef and crossRef and primaryRef > 0 then
                local gap = ((crossRef - primaryRef) / primaryRef) * 100
                pcall(tooltip.AddLine, tooltip, GREY .. string.format("Source reference gap: %+.1f%%", gap) .. RESET)
            end
        end
    end

    local liveRow = self:GetHoveredTraderRow029683(itemLink)
    if liveRow then
        local liveText = GOLD .. "LIVE LISTING  " .. formatNumber(liveRow.unitPrice) .. "g/unit" .. RESET
        if liveRow.amount and liveRow.amount > 1 then
            liveText = liveText .. GREY .. "  x" .. tostring(math.floor(liveRow.amount)) .. " = " .. formatNumber(liveRow.totalPrice) .. "g" .. RESET
        end
        pcall(tooltip.AddLine, tooltip, liveText)

        local dealText, dealColor = self:GetDealLabel029683(liveRow, primary)
        if dealText then
            pcall(tooltip.AddLine, tooltip, (dealColor or WHITE) .. dealText .. RESET)
        elseif primary and safeNumber(primary.timestamp) then
            local age = math.max(0, now() - safeNumber(primary.timestamp))
            local maxAgeHours = math.max(1, safeNumber(saved.marketPriceMaxDealAgeHours029683) or 24)
            if age > maxAgeHours * 3600 then
                pcall(tooltip.AddLine, tooltip, GREY .. "Deal rating withheld: aggregate market data is too old." .. RESET)
            end
        end
    end
end

EPC.marketPriceCheckerPolish029683 = true
