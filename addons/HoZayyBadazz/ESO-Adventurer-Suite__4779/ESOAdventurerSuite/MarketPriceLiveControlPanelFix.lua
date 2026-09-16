-- ESO Adventurer Suite
-- v0.29.689 button-driven Live Market control center.
-- Makes the normal market scanning/route workflow fully usable without slash commands.

local EPC = ESOProgressionCoach
if not EPC or not EPC.MarketPriceChecker then return end
local M = EPC.MarketPriceChecker
if M._liveMarketControlPanel029689 then return end
M._liveMarketControlPanel029689 = true

local GOLD = "|cFFD700"
local GREEN = "|c66FF66"
local CYAN = "|c66CCFF"
local YELLOW = "|cFFFF66"
local GREY = "|cA0A0A0"
local WHITE = "|cFFFFFF"
local RESET = "|r"
local NAME = (EPC.name or "ESOAdventurerSuite") .. "_MarketControl029689"

local function safeNumber(value)
    local n = tonumber(value)
    if not n or n ~= n or n == math.huge or n == -math.huge then return nil end
    return n
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

local function routeState()
    EPC.saved = EPC.saved or {}
    local state = EPC.saved.marketLiveRoute029687
    if type(state) ~= "table" then
        state = { active = false, paused = false, index = 1, visited = {} }
        EPC.saved.marketLiveRoute029687 = state
    end
    state.visited = type(state.visited) == "table" and state.visited or {}
    return state
end

local function setButtonText(button, text)
    if button and type(button.SetText) == "function" then button:SetText(text) end
end

local function setEnabled(button, enabled)
    if not button then return end
    if type(button.SetEnabled) == "function" then button:SetEnabled(enabled == true) end
    if type(button.SetAlpha) == "function" then button:SetAlpha(enabled == true and 1 or 0.45) end
end

local function createButton(parent, name, text, x, y, width, height, callback)
    local button = WINDOW_MANAGER:CreateControl(name, parent, CT_BUTTON)
    button:SetDimensions(width, height)
    button:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    if type(button.SetFont) == "function" then button:SetFont("ZoFontGameBold") end
    button:SetText(text)
    button:SetHandler("OnClicked", function()
        if callback then callback() end
        if EPC and EPC.MarketPriceChecker and EPC.MarketPriceChecker.RefreshLiveMarketControlPanel029689 then
            EPC.MarketPriceChecker:RefreshLiveMarketControlPanel029689()
        end
    end)

    local bg = WINDOW_MANAGER:CreateControl(name .. "BG", button, CT_BACKDROP)
    bg:SetAnchorFill(button)
    bg:SetCenterColor(0.06, 0.06, 0.075, 0.96)
    bg:SetEdgeColor(0.72, 0.55, 0.12, 0.92)
    bg:SetMouseEnabled(false)
    if type(bg.SetDrawLevel) == "function" then bg:SetDrawLevel(0) end
    return button
end

function M:EnsureLiveMarketControlPanel029689()
    if self.liveMarketControlPanel029689 then return self.liveMarketControlPanel029689 end
    if not WINDOW_MANAGER or not GuiRoot then return nil end

    local panel = WINDOW_MANAGER:CreateControl("EASLiveMarketControlPanel029689", GuiRoot, CT_CONTROL)
    panel:SetDimensions(700, 520)
    panel:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    panel:SetMouseEnabled(true)
    panel:SetMovable(true)
    panel:SetClampedToScreen(true)
    if type(panel.SetDrawTier) == "function" and DT_HIGH ~= nil then panel:SetDrawTier(DT_HIGH) end
    if type(panel.SetDrawLayer) == "function" and DL_OVERLAY ~= nil then panel:SetDrawLayer(DL_OVERLAY) end
    if type(panel.SetDrawLevel) == "function" then panel:SetDrawLevel(12500) end

    local bg = WINDOW_MANAGER:CreateControl("EASLiveMarketControlPanelBG029689", panel, CT_BACKDROP)
    bg:SetAnchorFill(panel)
    bg:SetCenterColor(0.012, 0.012, 0.02, 0.985)
    bg:SetEdgeColor(0.88, 0.67, 0.12, 1)
    bg:SetMouseEnabled(false)

    local title = WINDOW_MANAGER:CreateControl("EASLiveMarketControlTitle029689", panel, CT_LABEL)
    title:SetAnchor(TOPLEFT, panel, TOPLEFT, 20, 16)
    title:SetFont("ZoFontWinH2")
    title:SetColor(1, 0.82, 0.2, 1)
    title:SetText("ESO ADVENTURER SUITE — LIVE MARKET")

    local subtitle = WINDOW_MANAGER:CreateControl("EASLiveMarketControlSubtitle029689", panel, CT_LABEL)
    subtitle:SetAnchor(TOPLEFT, panel, TOPLEFT, 20, 48)
    subtitle:SetDimensions(650, 42)
    subtitle:SetFont("ZoFontGame")
    subtitle:SetColor(0.82, 0.82, 0.82, 1)
    subtitle:SetText("No slash commands required. Open a Guild Trader and use SCAN CURRENT STORE, or start the trader-hub route below.")

    local close = WINDOW_MANAGER:CreateControl("EASLiveMarketControlClose029689", panel, CT_BUTTON)
    close:SetDimensions(34, 28)
    close:SetAnchor(TOPRIGHT, panel, TOPRIGHT, -10, 10)
    close:SetFont("ZoFontGameBold")
    close:SetText("X")
    close:SetHandler("OnClicked", function() panel:SetHidden(true) end)

    local statusTitle = WINDOW_MANAGER:CreateControl("EASLiveMarketControlStatusTitle029689", panel, CT_LABEL)
    statusTitle:SetAnchor(TOPLEFT, panel, TOPLEFT, 20, 96)
    statusTitle:SetFont("ZoFontGameBold")
    statusTitle:SetColor(0.4, 0.8, 1, 1)
    statusTitle:SetText("LIVE MARKET STATUS")

    local status = WINDOW_MANAGER:CreateControl("EASLiveMarketControlStatus029689", panel, CT_LABEL)
    status:SetAnchor(TOPLEFT, panel, TOPLEFT, 20, 122)
    status:SetDimensions(655, 112)
    status:SetFont("ZoFontGame")
    status:SetColor(1, 1, 1, 1)
    status:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    status:SetVerticalAlignment(TEXT_ALIGN_TOP)

    local scan = createButton(panel, "EASLiveMarketScanButton029689", "SCAN CURRENT STORE", 20, 250, 315, 42, function()
        if M.StartCurrentTraderFullScan029687 then M:StartCurrentTraderFullScan029687(true) end
    end)
    local auto = createButton(panel, "EASLiveMarketAutoButton029689", "AUTO FULL SCAN: ON", 365, 250, 315, 42, function()
        EPC.saved = EPC.saved or {}
        EPC.saved.marketLiveAutoScanTTC029687 = not (EPC.saved.marketLiveAutoScanTTC029687 ~= false)
    end)
    local start = createButton(panel, "EASLiveMarketRouteStart029689", "START TRADER ROUTE", 20, 304, 315, 42, function()
        if M.StartTraderRoute029687 then M:StartTraderRoute029687(true) end
    end)
    local nextHub = createButton(panel, "EASLiveMarketRouteNext029689", "NEXT TRADER HUB", 365, 304, 315, 42, function()
        if M.NextTraderHub029687 then M:NextTraderHub029687() end
    end)
    local pause = createButton(panel, "EASLiveMarketRoutePause029689", "PAUSE ROUTE", 20, 358, 315, 42, function()
        local state = routeState()
        if M.PauseTraderRoute029687 then M:PauseTraderRoute029687(state.paused ~= true) end
    end)
    local reset = createButton(panel, "EASLiveMarketRouteReset029689", "RESET ROUTE", 365, 358, 315, 42, function()
        if M.ResetTraderRoute029687 then M:ResetTraderRoute029687() end
    end)
    local refresh = createButton(panel, "EASLiveMarketRefresh029689", "REFRESH STATUS", 20, 412, 315, 42, function() end)
    local prune = createButton(panel, "EASLiveMarketPrune029689", "PRUNE OLD MARKET DATA", 365, 412, 315, 42, function()
        if M.PruneLiveMarketCache029687 then M:PruneLiveMarketCache029687() end
        if M.PruneLiveMarketHistory029688 then M:PruneLiveMarketHistory029688() end
    end)

    local hint = WINDOW_MANAGER:CreateControl("EASLiveMarketControlHint029689", panel, CT_LABEL)
    hint:SetAnchor(BOTTOMLEFT, panel, BOTTOMLEFT, 20, -22)
    hint:SetDimensions(650, 34)
    hint:SetFont("ZoFontGameSmall")
    hint:SetColor(0.63, 0.63, 0.63, 1)
    hint:SetText("Route flow: START ROUTE → travel → open each Guild Trader → scan completes → NEXT TRADER HUB. Drag this panel to move it.")

    panel:SetHandler("OnMouseDown", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and type(control.StartMoving) == "function" then control:StartMoving() end
    end)
    panel:SetHandler("OnMouseUp", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and type(control.StopMovingOrResizing) == "function" then control:StopMovingOrResizing() end
    end)

    panel.status = status
    panel.scan = scan
    panel.auto = auto
    panel.start = start
    panel.nextHub = nextHub
    panel.pause = pause
    panel.reset = reset
    panel.refresh = refresh
    panel.prune = prune
    panel:SetHidden(true)
    self.liveMarketControlPanel029689 = panel
    return panel
end

function M:RefreshLiveMarketControlPanel029689()
    local panel = self:EnsureLiveMarketControlPanel029689()
    if not panel then return end

    local health = type(self.GetLiveMarketHealth029687) == "function" and self:GetLiveMarketHealth029687() or {}
    local state = routeState()
    local route = type(self.GetTraderHubRoute029687) == "function" and self:GetTraderHubRoute029687() or {}
    if type(route) ~= "table" then route = {} end
    local routeCount = #route
    local index = math.max(1, math.floor(safeNumber(state.index) or 1))
    if routeCount > 0 then index = math.min(index, routeCount) end

    local scanner = clean(health.scanProvider)
    if scanner == "" then scanner = health.ttc == true and "TTC + EAS" or "EAS Native" end
    local routeText = "Idle"
    if state.active == true then routeText = state.paused == true and "Paused" or "Active" end
    if routeCount > 0 and state.active == true then routeText = routeText .. " — hub " .. tostring(index) .. "/" .. tostring(routeCount) end

    local session = self.marketLiveScanSession029687
    local scanText = "No full-store scan running"
    if type(session) == "table" then
        local provider = clean(session.provider)
        if provider == "" then provider = scanner end
        local guild = clean(session.guildName)
        if guild == "" then guild = "Current Guild Trader" end
        scanText = string.format("%sScanning%s %s — %s — %d pages / %d listings",
            YELLOW, RESET, guild, provider,
            math.floor(safeNumber(session.pages) or 0), math.floor(safeNumber(session.rows) or 0))
    end

    panel.status:SetText(table.concat({
        string.format("%sScanner:%s %s%s%s", CYAN, RESET, WHITE, scanner, RESET),
        string.format("%sFresh traders:%s %d/%d    %sFresh locations:%s %d/%d    %sCached items:%s %d",
            GREEN, RESET, safeNumber(health.freshTraders) or 0, safeNumber(health.traders) or 0,
            GREEN, RESET, safeNumber(health.freshLocations) or 0, safeNumber(health.locations) or 0,
            GOLD, RESET, safeNumber(health.items) or 0),
        string.format("%sRoute:%s %s", CYAN, RESET, routeText),
        scanText,
    }, "\n"))

    local scanActive = type(session) == "table"
    setButtonText(panel.scan, scanActive and "SCAN IN PROGRESS..." or "SCAN CURRENT STORE")
    setEnabled(panel.scan, not scanActive)

    local autoEnabled = EPC.saved and EPC.saved.marketLiveAutoScanTTC029687 ~= false
    setButtonText(panel.auto, "AUTO FULL SCAN: " .. (autoEnabled and "ON" or "OFF"))
    setButtonText(panel.start, state.active == true and "RESTART TRADER ROUTE" or "START TRADER ROUTE")
    setButtonText(panel.pause, state.paused == true and "RESUME ROUTE" or "PAUSE ROUTE")
    setEnabled(panel.nextHub, state.active == true and state.paused ~= true and routeCount > 0)
    setEnabled(panel.pause, state.active == true)
    setEnabled(panel.reset, state.active == true or routeCount > 0)
end

function M:OpenLiveMarketControlPanel029689()
    local panel = self:EnsureLiveMarketControlPanel029689()
    if not panel then return false end
    panel:SetHidden(false)
    self:RefreshLiveMarketControlPanel029689()

    panel.refreshGeneration029689 = (panel.refreshGeneration029689 or 0) + 1
    local generation = panel.refreshGeneration029689
    local function tick()
        if not panel or panel:IsHidden() or panel.refreshGeneration029689 ~= generation then return end
        if EPC and EPC.MarketPriceChecker and EPC.MarketPriceChecker.RefreshLiveMarketControlPanel029689 then
            EPC.MarketPriceChecker:RefreshLiveMarketControlPanel029689()
        end
        if type(zo_callLater) == "function" then zo_callLater(tick, 1000) end
    end
    if type(zo_callLater) == "function" then zo_callLater(tick, 1000) end
    return true
end

function M:ToggleLiveMarketControlPanel029689()
    local panel = self:EnsureLiveMarketControlPanel029689()
    if not panel then return false end
    if panel:IsHidden() then return self:OpenLiveMarketControlPanel029689() end
    panel:SetHidden(true)
    return true
end

function M:EnsureLiveMarketTraderLauncher029689()
    if self.liveMarketTraderLauncher029689 then return self.liveMarketTraderLauncher029689 end
    if not WINDOW_MANAGER or not GuiRoot then return nil end

    local parent = rawget(_G, "ZO_TradingHouse") or GuiRoot
    local button = WINDOW_MANAGER:CreateControl("EASLiveMarketTraderLauncher029689", parent, CT_BUTTON)
    button:SetDimensions(190, 34)
    button:SetAnchor(TOPRIGHT, parent, TOPRIGHT, -36, 68)
    button:SetFont("ZoFontGameBold")
    button:SetText("EAS LIVE MARKET")
    button:SetHandler("OnClicked", function()
        if EPC and EPC.MarketPriceChecker then EPC.MarketPriceChecker:OpenLiveMarketControlPanel029689() end
    end)

    local bg = WINDOW_MANAGER:CreateControl("EASLiveMarketTraderLauncherBG029689", button, CT_BACKDROP)
    bg:SetAnchorFill(button)
    bg:SetCenterColor(0.025, 0.025, 0.035, 0.96)
    bg:SetEdgeColor(0.9, 0.68, 0.12, 1)
    bg:SetMouseEnabled(false)
    button:SetHidden(true)
    self.liveMarketTraderLauncher029689 = button
    return button
end

local function installTeleporterControlEntry()
    local Travel = EPC.Travel
    if not Travel or Travel._marketControlCenter029689 or type(Travel.ShowMapTeleporterToolsMenu02967) ~= "function" then return end
    Travel._marketControlCenter029689 = true
    local baseTools = Travel.ShowMapTeleporterToolsMenu02967

    function Travel:ShowMapTeleporterToolsMenu02967(owner)
        local originalFlyout = self.ShowMapTeleporterFlyout02969
        if type(originalFlyout) ~= "function" then return baseTools(self, owner) end
        local injected = false
        self.ShowMapTeleporterFlyout02969 = function(travel, titleText, items, flyoutOwner, contextMode)
            if not injected and tostring(titleText or "") == "TOOLS" and type(items) == "table" then
                injected = true
                table.insert(items, 1, {
                    label = "LIVE MARKET CONTROL CENTER",
                    action = function()
                        if EPC and EPC.MarketPriceChecker then EPC.MarketPriceChecker:OpenLiveMarketControlPanel029689() end
                    end,
                })
                for _, item in ipairs(items) do
                    if type(item) == "table" and type(item.label) == "string" and item.label:find("^Live Market:") then
                        item.action = function()
                            if EPC and EPC.MarketPriceChecker then EPC.MarketPriceChecker:OpenLiveMarketControlPanel029689() end
                        end
                    end
                end
            end
            return originalFlyout(travel, titleText, items, flyoutOwner, contextMode)
        end
        local ok, result = pcall(baseTools, self, owner)
        self.ShowMapTeleporterFlyout02969 = originalFlyout
        if not ok then
            if EPC and type(EPC.Print) == "function" then EPC:Print("Live Market Control Center integration failed: " .. tostring(result)) end
            return false
        end
        return result
    end
end

if EVENT_MANAGER then
    if EVENT_OPEN_TRADING_HOUSE ~= nil then
        EVENT_MANAGER:RegisterForEvent(NAME .. "_Open", EVENT_OPEN_TRADING_HOUSE, function()
            local market = EPC and EPC.MarketPriceChecker
            if not market then return end
            local launcher = market:EnsureLiveMarketTraderLauncher029689()
            if launcher then launcher:SetHidden(false) end
        end)
    end
    if EVENT_CLOSE_TRADING_HOUSE ~= nil then
        EVENT_MANAGER:RegisterForEvent(NAME .. "_Close", EVENT_CLOSE_TRADING_HOUSE, function()
            local launcher = EPC and EPC.MarketPriceChecker and EPC.MarketPriceChecker.liveMarketTraderLauncher029689
            if launcher then launcher:SetHidden(true) end
        end)
    end
    if EVENT_PLAYER_ACTIVATED ~= nil then
        EVENT_MANAGER:RegisterForEvent(NAME .. "_Activated", EVENT_PLAYER_ACTIVATED, function()
            EVENT_MANAGER:UnregisterForEvent(NAME .. "_Activated", EVENT_PLAYER_ACTIVATED)
            if type(zo_callLater) == "function" then
                zo_callLater(function()
                    installTeleporterControlEntry()
                    if EPC and EPC.MarketPriceChecker then EPC.MarketPriceChecker:EnsureLiveMarketTraderLauncher029689() end
                end, 2200)
            else
                installTeleporterControlEntry()
                M:EnsureLiveMarketTraderLauncher029689()
            end
        end)
    end
end

EPC.marketPriceLiveControlPanel029689 = true
