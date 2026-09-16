-- ESO Adventurer Suite
-- v0.29.688 native Guild Trader full-scan fallback.
--
-- TTC is optional. When the Tamriel Trade Centre addon runtime is present, EAS can
-- continue using TTC's mature Scan All implementation. When TTC is absent, EAS
-- performs the same store-page traversal through ESO's public Trading House API,
-- obeying the native cooldown and consuming EVENT_TRADING_HOUSE_SEARCH_RESULTS_RECEIVED.
-- This fixes Live Market being limited to the one visible 50-item page when TTC
-- is not installed/enabled.

local EPC = ESOProgressionCoach
if not EPC or not EPC.MarketPriceChecker then return end
local M = EPC.MarketPriceChecker
if M._nativeTraderScan029688 then return end
M._nativeTraderScan029688 = true

local NAME = (EPC.name or "ESOAdventurerSuite") .. "_NativeTraderScan029688"
local GREEN = "|c66FF66"
local GOLD = "|cFFD700"
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

local function lower(value)
    return string.lower(clean(value))
end

local function currentContext()
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

    local traderName, locationName, zoneName = "", "", ""
    if type(GetUnitName) == "function" then
        local ok, value = pcall(GetUnitName, "interact")
        if ok then traderName = clean(value) end
    end
    if traderName == "" and type(GetRawUnitName) == "function" then
        local ok, value = pcall(GetRawUnitName, "interact")
        if ok then traderName = clean(value) end
    end
    if type(GetPlayerLocationName) == "function" then
        local ok, value = pcall(GetPlayerLocationName)
        if ok then locationName = clean(value) end
    end
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

local function hasTTCRuntime()
    local ttc = rawget(_G, "TamrielTradeCentre")
    return type(ttc) == "table" and type(ttc.StartNewGuildListingScan) == "function"
end

local function routeIsActive()
    local state = EPC.saved and EPC.saved.marketLiveRoute029687
    return type(state) == "table" and state.active == true and state.paused ~= true
end

-- Count location health even without TTC kiosk ids. The original Live Market
-- health table keyed locations only by TTC KioskLocationID, which made a native
-- observation display 0/0 locations despite having a real ESO area + zone.
local baseUpdateHealth029688 = M.UpdateTraderHealth029687
if type(baseUpdateHealth029688) == "function" then
    function M:UpdateTraderHealth029687(context, fullScan, rows, pages)
        local result = baseUpdateHealth029688(self, context, fullScan, rows, pages)
        context = context or currentContext()
        if not safeNumber(context.kioskId) then
            local locationName = clean(context.locationName)
            local zoneName = clean(context.zoneName)
            if locationName ~= "" or zoneName ~= "" then
                EPC.saved = EPC.saved or {}
                EPC.saved.marketLiveTraderHealth029687 = type(EPC.saved.marketLiveTraderHealth029687) == "table"
                    and EPC.saved.marketLiveTraderHealth029687 or { traders = {}, locations = {} }
                local root = EPC.saved.marketLiveTraderHealth029687
                root.locations = type(root.locations) == "table" and root.locations or {}
                local key = "native:" .. lower(locationName) .. "|" .. lower(zoneName)
                local record = root.locations[key]
                if type(record) ~= "table" then record = {} root.locations[key] = record end
                record.locationName = locationName
                record.zoneName = zoneName
                record.lastSeen = now()
                if fullScan then record.lastFullScan = record.lastSeen end
            end
        end
        return result
    end
end

function M:IsNativeTraderScanAvailable029688()
    return type(ExecuteTradingHouseSearch) == "function"
        and type(GetTradingHouseSearchResultsInfo) == "function"
        and type(GetTradingHouseSearchResultItemInfo) == "function"
        and type(GetTradingHouseSearchResultItemLink) == "function"
        and EVENT_TRADING_HOUSE_SEARCH_RESULTS_RECEIVED ~= nil
end

function M:CancelNativeTraderScan029688(reason)
    local session = self.marketLiveScanSession029687
    if type(session) ~= "table" or session.provider ~= "EAS NATIVE" then return false end
    self.marketLiveScanSession029687 = nil
    if EPC and type(EPC.Print) == "function" and reason then
        EPC:Print("Live Market native scan stopped: " .. tostring(reason) .. ".")
    end
    return true
end

function M:FinishNativeTraderScan029688(reason)
    local session = self.marketLiveScanSession029687
    if type(session) ~= "table" or session.provider ~= "EAS NATIVE" then return false end
    local ctx = currentContext()
    local rows = math.floor(safeNumber(session.rows) or 0)
    local pages = math.floor(safeNumber(session.pages) or 0)
    local startedAt = safeNumber(session.startedAt) or 0

    self.marketLiveScanSession029687 = nil
    if type(self.UpdateTraderHealth029687) == "function" then
        self:UpdateTraderHealth029687(ctx, true, rows, pages)
    end
    if startedAt > 0 and type(self.PurgeTraderListingsBefore029687) == "function" then
        self:PurgeTraderListingsBefore029687(ctx, startedAt)
    end
    if type(self.PruneLiveMarketCache029687) == "function" then self:PruneLiveMarketCache029687() end

    if EPC and type(EPC.Print) == "function" then
        EPC:Print(GREEN .. "Live Market native full scan complete" .. RESET .. ": " ..
            (clean(ctx.guildName) ~= "" and ctx.guildName or clean(session.guildName) ~= "" and session.guildName or "Guild Trader") ..
            " - " .. tostring(rows) .. " listing" .. (rows == 1 and "" or "s") ..
            " across " .. tostring(pages) .. " page" .. (pages == 1 and "" or "s") ..
            (reason and (" [" .. tostring(reason) .. "]") or "") .. ".")
    end
    return true
end

function M:RequestNativeTraderPage029688(page)
    local session = self.marketLiveScanSession029687
    if type(session) ~= "table" or session.provider ~= "EAS NATIVE" then return false end
    if session.requestQueued == true then return true end

    page = math.max(0, math.floor(safeNumber(page) or 0))
    session.nextPage = page
    session.requestQueued = true

    local function attempt()
        local market = EPC and EPC.MarketPriceChecker
        local active = market and market.marketLiveScanSession029687
        if type(active) ~= "table" or active.provider ~= "EAS NATIVE" then return end
        active.requestQueued = false

        local ctx = currentContext()
        if clean(ctx.guildName) == "" then
            market:CancelNativeTraderScan029688("Guild Trader closed")
            return
        end
        if safeNumber(active.guildId) and safeNumber(active.guildId) > 0 and safeNumber(ctx.guildId)
            and safeNumber(ctx.guildId) > 0 and math.floor(active.guildId) ~= math.floor(ctx.guildId) then
            market:CancelNativeTraderScan029688("Guild Trader changed")
            return
        end

        local cooldown = 0
        if type(GetTradingHouseCooldownRemaining) == "function" then
            local ok, value = pcall(GetTradingHouseCooldownRemaining)
            if ok then cooldown = math.max(0, math.floor(safeNumber(value) or 0)) end
        end
        if cooldown > 0 then
            active.requestQueued = true
            if type(zo_callLater) == "function" then zo_callLater(attempt, cooldown + 350) end
            return
        end

        local search = rawget(_G, "TRADING_HOUSE_SEARCH")
        if type(search) == "table" and type(search.CanDoCommonOperation) == "function" then
            local ok, canDo = pcall(search.CanDoCommonOperation, search)
            if ok and canDo == false then
                active.requestQueued = true
                if type(zo_callLater) == "function" then zo_callLater(attempt, 350) end
                return
            end
        end

        active.awaitingPage = page
        active.lastRequestAt = now()
        local ok, err = pcall(ExecuteTradingHouseSearch, page, TRADING_HOUSE_SORT_SALE_PRICE, true, false)
        if not ok then
            active.awaitingPage = nil
            active.retries = (safeNumber(active.retries) or 0) + 1
            if active.retries <= 3 and type(zo_callLater) == "function" then
                active.requestQueued = true
                zo_callLater(attempt, 1500)
            else
                market:CancelNativeTraderScan029688("ESO rejected the search request: " .. tostring(err))
            end
        else
            active.retries = 0
        end
    end

    if type(zo_callLater) == "function" then zo_callLater(attempt, 0) else attempt() end
    return true
end

function M:StartNativeTraderFullScan029688(force)
    if self.marketLiveScanSession029687 then
        if EPC and type(EPC.Print) == "function" then EPC:Print("A Live Market trader scan is already running.") end
        return false
    end
    if not self:IsNativeTraderScanAvailable029688() then
        if EPC and type(EPC.Print) == "function" then EPC:Print("ESO's native Guild Trader search API is unavailable on this client.") end
        return false
    end

    local ctx = currentContext()
    if clean(ctx.guildName) == "" then
        if EPC and type(EPC.Print) == "function" then EPC:Print("Open a Guild Trader first, then start the Live Market scan.") end
        return false
    end
    if force ~= true and type(self.IsCurrentTraderFresh029687) == "function" and self:IsCurrentTraderFresh029687() then
        if EPC and type(EPC.Print) == "function" then EPC:Print(ctx.guildName .. " was fully scanned recently; skipping duplicate scan.") end
        return true
    end

    -- Full-store means no category/text/price restrictions. This intentionally
    -- takes over the current Guild Trader search only when the user explicitly
    -- requests a scan or while the Live Trader Route is active.
    if type(ClearAllTradingHouseSearchTerms) == "function" then pcall(ClearAllTradingHouseSearchTerms) end

    self.marketLiveScanSession029687 = {
        provider = "EAS NATIVE",
        nativeScan = true,
        guildId = ctx.guildId,
        guildName = ctx.guildName,
        startedAt = now(),
        pages = 0,
        rows = 0,
        seenPages = {},
        requestQueued = false,
        awaitingPage = nil,
        retries = 0,
    }

    if EPC and type(EPC.Print) == "function" then
        EPC:Print(GOLD .. "Live Market" .. RESET .. ": EAS native full-store scan started for " .. ctx.guildName .. ". TTC is not required.")
    end
    return self:RequestNativeTraderPage029688(0)
end

-- Keep TTC as the preferred provider when its addon runtime is actually present,
-- but never make TTC a requirement for EAS full-store scans.
local baseStartFullScan029688 = M.StartCurrentTraderFullScan029687
function M:StartCurrentTraderFullScan029687(force)
    if hasTTCRuntime() and type(baseStartFullScan029688) == "function" then
        return baseStartFullScan029688(self, force)
    end
    return self:StartNativeTraderFullScan029688(force)
end

-- The original response handler owns TTC scan bookkeeping. Native scans use the
-- more precise SEARCH_RESULTS_RECEIVED event (which includes page + hasMorePages),
-- so bypass the TTC completion heuristic while an EAS-native session is active.
local baseHandleResponse029688 = M.HandleTradingHouseResponse029687
if type(baseHandleResponse029688) == "function" then
    function M:HandleTradingHouseResponse029687(responseType)
        local session = self.marketLiveScanSession029687
        if type(session) == "table" and session.provider == "EAS NATIVE" then return end
        return baseHandleResponse029688(self, responseType)
    end
end

-- Auto full scanning without TTC is intentionally restricted to an active Trader
-- Route. Opening a store during normal shopping still captures the visible search
-- results, but EAS will not clear the shopper's filters just because TTC is absent.
local baseMaybeAuto029688 = M.MaybeAutoScanCurrentTrader029687
function M:MaybeAutoScanCurrentTrader029687()
    if hasTTCRuntime() and type(baseMaybeAuto029688) == "function" then
        return baseMaybeAuto029688(self)
    end
    if not EPC.saved or EPC.saved.marketLiveAutoScanTTC029687 == false then return false end
    if not routeIsActive() then return false end
    if self.marketLiveScanSession029687 then return false end
    return self:StartNativeTraderFullScan029688(false)
end

if EVENT_MANAGER and EVENT_TRADING_HOUSE_SEARCH_RESULTS_RECEIVED ~= nil then
    EVENT_MANAGER:RegisterForEvent(NAME .. "_Results", EVENT_TRADING_HOUSE_SEARCH_RESULTS_RECEIVED,
        function(_, guildId, numItemsOnPage, currentPage, hasMorePages)
            local market = EPC and EPC.MarketPriceChecker
            local session = market and market.marketLiveScanSession029687
            if type(session) ~= "table" or session.provider ~= "EAS NATIVE" then return end

            local expectedGuild = safeNumber(session.guildId)
            local receivedGuild = safeNumber(guildId)
            if expectedGuild and expectedGuild > 0 and receivedGuild and receivedGuild > 0
                and math.floor(expectedGuild) ~= math.floor(receivedGuild) then return end

            currentPage = math.max(0, math.floor(safeNumber(currentPage) or 0))
            local pageKey = tostring(currentPage)
            if session.seenPages[pageKey] then return end
            session.seenPages[pageKey] = true
            session.awaitingPage = nil

            local captured = 0
            if type(market.CaptureCurrentSearchPage029687) == "function" then
                local ok, value = pcall(market.CaptureCurrentSearchPage029687, market, "EAS NATIVE FULL SCAN")
                if ok then captured = math.max(0, math.floor(safeNumber(value) or 0)) end
            end
            if captured <= 0 then captured = math.max(0, math.floor(safeNumber(numItemsOnPage) or 0)) end
            session.rows = (safeNumber(session.rows) or 0) + captured
            session.pages = math.max(safeNumber(session.pages) or 0, currentPage + 1)

            if currentPage > 0 and currentPage % 10 == 9 and EPC and type(EPC.Print) == "function" then
                EPC:Print("Live Market native scan: " .. tostring(currentPage + 1) .. " pages / " .. tostring(math.floor(session.rows)) .. " listings captured...")
            end

            if hasMorePages == true then
                market:RequestNativeTraderPage029688(currentPage + 1)
            else
                if type(zo_callLater) == "function" then
                    zo_callLater(function()
                        if EPC.MarketPriceChecker then EPC.MarketPriceChecker:FinishNativeTraderScan029688("EAS NATIVE") end
                    end, 100)
                else
                    market:FinishNativeTraderScan029688("EAS NATIVE")
                end
            end
        end)
end

-- Replace the status text so a missing TTC addon is reported as an optional
-- provider choice, not as a broken/required dependency.
local baseHealth029688 = M.GetLiveMarketHealth029687
if type(baseHealth029688) == "function" then
    function M:GetLiveMarketHealth029687()
        local health = baseHealth029688(self)
        health = type(health) == "table" and health or {}
        health.nativeScan = self:IsNativeTraderScanAvailable029688()
        health.ttc = hasTTCRuntime()
        health.scanProvider = health.ttc and "TTC + EAS Native" or (health.nativeScan and "EAS Native" or "Unavailable")
        return health
    end
end

function M:PrintLiveMarketStatus029687()
    local h = self:GetLiveMarketHealth029687()
    local state = EPC.saved and EPC.saved.marketLiveRoute029687
    local routeText = type(state) == "table" and state.active == true
        and (state.paused == true and "route paused" or "route active") or "route idle"
    if EPC and type(EPC.Print) == "function" then
        EPC:Print(string.format(
            "Live Market: %d/%d traders fresh, %d/%d locations fresh, %d cached items, scanner %s, %s.",
            safeNumber(h.freshTraders) or 0, safeNumber(h.traders) or 0,
            safeNumber(h.freshLocations) or 0, safeNumber(h.locations) or 0,
            safeNumber(h.items) or 0, tostring(h.scanProvider or "Unavailable"), routeText))
    end
end

-- Patch Teleporter > Tools after the v0.29.687 wrapper has installed. This makes
-- the full-scan button available whether TTC is installed or not and removes the
-- misleading TTC-required wording from the route controls.
local function patchTeleporterTools()
    local Travel = EPC and EPC.Travel
    if not Travel or Travel._nativeMarketTools029688 or type(Travel.ShowMapTeleporterToolsMenu02967) ~= "function" then return end
    Travel._nativeMarketTools029688 = true
    local baseTools = Travel.ShowMapTeleporterToolsMenu02967

    function Travel:ShowMapTeleporterToolsMenu02967(owner)
        local originalFlyout = self.ShowMapTeleporterFlyout02969
        if type(originalFlyout) ~= "function" then return baseTools(self, owner) end
        self.ShowMapTeleporterFlyout02969 = function(travel, titleText, items, flyoutOwner, contextMode)
            if tostring(titleText or "") == "TOOLS" and type(items) == "table" then
                local market = EPC.MarketPriceChecker
                local ttcReady = hasTTCRuntime()
                for _, item in ipairs(items) do
                    if type(item) == "table" then
                        local label = tostring(item.label or "")
                        if label == "Scan Current Guild Trader (TTC)" then
                            item.label = ttcReady and "Scan Current Guild Trader (TTC)" or "Scan Current Guild Trader (EAS Native)"
                            item.enabled = true
                        elseif label:find("Auto TTC Scan:", 1, true) == 1 then
                            item.label = label:gsub("Auto TTC Scan:", "Auto Full Scan:", 1)
                        end
                    end
                end
            end
            return originalFlyout(travel, titleText, items, flyoutOwner, contextMode)
        end
        local ok, result = pcall(baseTools, self, owner)
        self.ShowMapTeleporterFlyout02969 = originalFlyout
        if not ok then
            if EPC and type(EPC.Print) == "function" then EPC:Print("Native Live Market Teleporter tools failed: " .. tostring(result)) end
            return false
        end
        return result
    end
end

if EVENT_MANAGER and EVENT_PLAYER_ACTIVATED ~= nil then
    EVENT_MANAGER:RegisterForEvent(NAME, EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_PLAYER_ACTIVATED)
        if type(zo_callLater) == "function" then zo_callLater(patchTeleporterTools, 1800) else patchTeleporterTools() end
    end)
end

EPC.marketPriceNativeTraderScan029688 = true