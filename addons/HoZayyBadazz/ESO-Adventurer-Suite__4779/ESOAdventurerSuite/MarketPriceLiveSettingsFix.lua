-- ESO Adventurer Suite
-- Settings extension for the v0.29.689 Live Market Engine.

local EPC = ESOProgressionCoach
if not EPC or not EPC.Settings or not EPC.MarketPriceChecker then return end
local S = EPC.Settings
local M = EPC.MarketPriceChecker
if S._marketLiveSettings029687 then return end
S._marketLiveSettings029687 = true

local baseInitialize = S.Initialize

local function liveControls()
    return {
        {
            type = "header",
            name = "Live Guild Trader Engine",
        },
        {
            type = "description",
            text = "EAS captures ESO Guild Trader search results immediately and preserves the best recent located listings. The normal workflow is fully button-driven through the Live Market Control Center and Teleporter > Tools. TTC is optional; EAS can full-scan the current store itself with ESO's native Trading House API.",
            width = "full",
        },
        {
            type = "button",
            name = "Live Market Control Center",
            buttonText = "OPEN CONTROL CENTER",
            tooltip = "Opens the full button-driven Live Market panel with scan, route, next hub, pause/resume, reset, auto-scan, refresh, and cache controls.",
            func = function() if M.OpenLiveMarketControlPanel029689 then M:OpenLiveMarketControlPanel029689() end end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Auto-scan stale Guild Traders",
            tooltip = "During an active Guild Trader Scan Route, opening a stale trader starts a full-store scan. EAS uses TTC Scan All when TTC is available; otherwise it uses the native ESO Trading House API. Outside the route, normal shopping is never forced into a native full scan.",
            getFunc = function() return EPC.saved.marketLiveAutoScanTTC029687 ~= false end,
            setFunc = function(value) EPC.saved.marketLiveAutoScanTTC029687 = value == true end,
            default = EPC.defaults.marketLiveAutoScanTTC029687,
        },
        {
            type = "slider",
            name = "Live listing freshness window (minutes)",
            min = 5, max = 180, step = 5,
            tooltip = "Listings seen inside this window are prioritized as fresh. Auto-scan also uses this window to avoid immediately rescanning the same trader.",
            getFunc = function() return math.floor(tonumber(EPC.saved.marketLiveFreshMinutes029687) or 30) end,
            setFunc = function(value) EPC.saved.marketLiveFreshMinutes029687 = math.floor(tonumber(value) or 30) end,
            default = EPC.defaults.marketLiveFreshMinutes029687,
        },
        {
            type = "slider",
            name = "Maximum age for TRAVEL TO (minutes)",
            min = 5, max = 360, step = 5,
            tooltip = "EAS will not route you to an old listing even if it remains in history. This protects Travel to Cheapest from stale observations.",
            getFunc = function() return math.floor(tonumber(EPC.saved.marketLiveTravelMaxAgeMinutes029687) or 60) end,
            setFunc = function(value) EPC.saved.marketLiveTravelMaxAgeMinutes029687 = math.floor(tonumber(value) or 60) end,
            default = EPC.defaults.marketLiveTravelMaxAgeMinutes029687,
        },
        {
            type = "slider",
            name = "Located-listing retention (days)",
            min = 1, max = 14, step = 1,
            tooltip = "How long EAS can retain historical exact trader observations for comparison. Expired ESO listings are still removed immediately, and TRAVEL uses the much shorter maximum-age setting above.",
            getFunc = function() return math.floor(tonumber(EPC.saved.marketLiveRetentionDays029687) or 7) end,
            setFunc = function(value)
                EPC.saved.marketLiveRetentionDays029687 = math.floor(tonumber(value) or 7)
                if M.PruneLiveMarketCache029687 then M:PruneLiveMarketCache029687() end
            end,
            default = EPC.defaults.marketLiveRetentionDays029687,
        },
        {
            type = "slider",
            name = "Live price history window (hours)",
            min = 6, max = 72, step = 6,
            tooltip = "Controls the compact hourly low/high history shown by LIVE INTELLIGENCE in Market Details.",
            getFunc = function() return math.floor(tonumber(EPC.saved.marketLiveHistoryHours029688) or 24) end,
            setFunc = function(value)
                EPC.saved.marketLiveHistoryHours029688 = math.floor(tonumber(value) or 24)
                if M.PruneLiveMarketHistory029688 then M:PruneLiveMarketHistory029688() end
            end,
            default = (EPC.defaults and EPC.defaults.marketLiveHistoryHours029688) or 24,
        },
        {
            type = "button",
            name = "Current Guild Trader",
            buttonText = "FULL STORE SCAN",
            tooltip = "Open a Guild Trader first. EAS uses TTC Scan All when available; otherwise it pages through the complete current store using ESO's public Trading House API and native search cooldown.",
            func = function() if M.StartCurrentTraderFullScan029687 then M:StartCurrentTraderFullScan029687(true) end end,
            width = "half",
        },
        {
            type = "button",
            name = "Live Market Database",
            buttonText = "OPEN STATUS",
            tooltip = "Opens the Live Market Control Center showing fresh/known trader counts, locations, cached item count, active scanner provider, current scan progress, and route state.",
            func = function() if M.OpenLiveMarketControlPanel029689 then M:OpenLiveMarketControlPanel029689() elseif M.PrintLiveMarketStatus029687 then M:PrintLiveMarketStatus029687() end end,
            width = "half",
        },
        {
            type = "button",
            name = "Guild Trader Scan Route",
            buttonText = "START / RESTART",
            tooltip = "Builds a route from discovered wayshrines to known trader hubs. At each hub, open the Guild Traders; EAS captures searches and can automatically run a full scan with TTC or the native scanner. Use the Live Market Control Center or Teleporter > Tools to advance to the next hub.",
            func = function() if M.StartTraderRoute029687 then M:StartTraderRoute029687(true) end end,
            width = "half",
        },
        {
            type = "button",
            name = "Live Market Cache",
            buttonText = "PRUNE NOW",
            tooltip = "Removes expired/old located listings and enforces the bounded item/listing/history cache limits immediately.",
            func = function()
                if M.PruneLiveMarketCache029687 then M:PruneLiveMarketCache029687() end
                if M.PruneLiveMarketHistory029688 then M:PruneLiveMarketHistory029688() end
                if EPC.Print then EPC:Print("Live Market cache pruned.") end
            end,
            width = "half",
        },
        {
            type = "description",
            title = "Normal workflow",
            text = "Open a Guild Trader and click EAS LIVE MARKET, or open Teleporter > Tools > LIVE MARKET CONTROL CENTER. Use the buttons there for scanning and the trader route. Slash commands remain available only as optional diagnostics/fallbacks; they are not required for normal use.",
            width = "full",
        },
    }
end

local function appendToMarketSubmenu(options)
    if type(options) ~= "table" then return end
    for _, option in ipairs(options) do
        if type(option) == "table" and option.type == "submenu" and option.name == "Market & Trading" then
            option.controls = type(option.controls) == "table" and option.controls or {}
            for _, existing in ipairs(option.controls) do
                if type(existing) == "table" and existing.name == "Live Guild Trader Engine" then return end
            end
            for _, control in ipairs(liveControls()) do option.controls[#option.controls + 1] = control end
            return
        end
    end
end

function S:Initialize(...)
    local LAM = LibAddonMenu2
    if not LAM or type(LAM.RegisterOptionControls) ~= "function" then
        return baseInitialize(self, ...)
    end

    local previousRegister = LAM.RegisterOptionControls
    LAM.RegisterOptionControls = function(lam, panelName, options, ...)
        if panelName == "ESOProgressionCoachSettings" then appendToMarketSubmenu(options) end
        return previousRegister(lam, panelName, options, ...)
    end

    local ok, result = pcall(baseInitialize, self, ...)
    LAM.RegisterOptionControls = previousRegister
    if not ok then
        if EPC and type(EPC.Print) == "function" then EPC:Print("Live Market settings integration failed: " .. tostring(result)) end
        return nil
    end
    return result
end

EPC.marketPriceLiveSettings029687 = true