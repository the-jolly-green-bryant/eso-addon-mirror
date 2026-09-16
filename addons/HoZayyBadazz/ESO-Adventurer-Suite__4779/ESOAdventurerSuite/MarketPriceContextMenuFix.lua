-- ESO Adventurer Suite
-- Market Price Checker right-click UX.
-- Adds a durable Guild Trader context-menu travel action and a persistent,
-- opaque market-details panel so travel/details do not depend on mouse hover.

local EPC = ESOProgressionCoach
if not EPC or not EPC.MarketPriceChecker then return end
local M = EPC.MarketPriceChecker
if M._marketPriceContextMenu029685 then return end
M._marketPriceContextMenu029685 = true

local GOLD = "|cFFD700"
local WHITE = "|cFFFFFF"
local GREY = "|cA0A0A0"
local GREEN = "|c66FF66"
local CYAN = "|c66CCFF"
local YELLOW = "|cFFFF66"
local RESET = "|r"
local MAX_ROWS = 5

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
    local days = math.floor(hours / 24)
    return tostring(days) .. "d " .. tostring(hours % 24) .. "h"
end

local function now()
    if type(GetTimeStamp) ~= "function" then return 0 end
    local ok, value = pcall(GetTimeStamp)
    return ok and (safeNumber(value) or 0) or 0
end

local function currentTraderContext()
    local guildId, guildName = 0, ""
    if type(GetCurrentTradingHouseGuildDetails) == "function" then
        local ok, id, name = pcall(GetCurrentTradingHouseGuildDetails)
        if ok then guildId, guildName = safeNumber(id) or 0, clean(name) end
    end

    local kioskId = nil
    local ttc = rawget(_G, "TamrielTradeCentre")
    if type(ttc) == "table" and type(ttc.GetCurrentKioskID) == "function" then
        local ok, value = pcall(ttc.GetCurrentKioskID, ttc)
        if ok then kioskId = safeNumber(value) end
    end

    local traderName, locationName, zoneName = "", "", ""
    if type(GetUnitName) == "function" then
        local ok, value = pcall(GetUnitName, "interact")
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
    return guildId, guildName, kioskId, traderName, locationName, zoneName
end

local function searchResultIndex(searchResultSlot)
    if not searchResultSlot then return nil end

    if type(ZO_InventorySlot_GetInventorySlotComponents) == "function" and type(ZO_Inventory_GetSlotIndex) == "function" then
        local okSlot, inventorySlot = pcall(ZO_InventorySlot_GetInventorySlotComponents, searchResultSlot)
        if okSlot and inventorySlot then
            local okIndex, index = pcall(ZO_Inventory_GetSlotIndex, inventorySlot)
            index = okIndex and safeNumber(index) or nil
            if index and index > 0 then return math.floor(index) end
        end
    end

    local dataEntry = searchResultSlot.dataEntry
    local data = type(dataEntry) == "table" and dataEntry.data or searchResultSlot.data
    if type(data) == "table" then
        local candidates = { data.slotIndex, data.index, data.searchResultIndex, data.tradingHouseIndex }
        for i = 1, #candidates do
            local value = safeNumber(candidates[i])
            if value and value > 0 then return math.floor(value) end
        end
    end
    return nil
end

function M:CaptureClickedTraderListing029685(searchResultSlot)
    local index = searchResultIndex(searchResultSlot)
    if not index or type(GetTradingHouseSearchResultItemLink) ~= "function" or type(GetTradingHouseSearchResultItemInfo) ~= "function" then return nil, nil end

    local okLink, itemLink = pcall(GetTradingHouseSearchResultItemLink, index)
    if not okLink or type(itemLink) ~= "string" or itemLink == "" then return nil, nil end

    local okInfo, _, _, _, stackCount, sellerName, timeRemaining, totalPrice, _, uniqueId, unitPrice = pcall(GetTradingHouseSearchResultItemInfo, index)
    if not okInfo then return itemLink, nil end

    stackCount = math.max(1, safeNumber(stackCount) or 1)
    totalPrice = safeNumber(totalPrice) or 0
    unitPrice = safeNumber(unitPrice) or (totalPrice > 0 and totalPrice / stackCount or nil)
    if not unitPrice or unitPrice <= 0 then return itemLink, nil end

    local guildId, guildName, kioskId, traderName, locationName, zoneName = currentTraderContext()
    local seenAt = now()
    local record = {
        rowIndex = index,
        itemLink = itemLink,
        unitPrice = unitPrice,
        totalPrice = totalPrice,
        amount = stackCount,
        sellerName = clean(sellerName),
        timeRemaining = safeNumber(timeRemaining) or 0,
        itemUniqueId = uniqueId,
        guildId = guildId,
        guildName = guildName,
        kioskId = kioskId,
        traderName = traderName,
        locationName = locationName,
        zoneName = zoneName,
        seenAt = seenAt,
        expireAt = seenAt + math.max(0, safeNumber(timeRemaining) or 0),
        source = "LIVE RIGHT-CLICK",
    }

    if type(self.PutLocatedListing029683) == "function" then
        self:PutLocatedListing029683(record)
    elseif type(self.StorePersistentTraderListing029683) == "function" then
        self:StorePersistentTraderListing029683(record)
    end
    return itemLink, record
end

local function ensurePanel()
    if M.marketContextPanel029685 then return M.marketContextPanel029685 end
    if not WINDOW_MANAGER or not GuiRoot then return nil end

    local panel = WINDOW_MANAGER:CreateControl("EASMarketContextPanel029685", GuiRoot, CT_CONTROL)
    panel:SetDimensions(620, 430)
    panel:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    panel:SetMouseEnabled(true)
    panel:SetMovable(true)
    panel:SetClampedToScreen(true)
    if type(panel.SetDrawTier) == "function" and DT_HIGH ~= nil then panel:SetDrawTier(DT_HIGH) end
    if type(panel.SetDrawLayer) == "function" and DL_OVERLAY ~= nil then panel:SetDrawLayer(DL_OVERLAY) end
    if type(panel.SetDrawLevel) == "function" then panel:SetDrawLevel(12050) end

    local bg = WINDOW_MANAGER:CreateControl("EASMarketContextPanelBG029685", panel, CT_BACKDROP)
    bg:SetAnchorFill(panel)
    bg:SetCenterColor(0.015, 0.015, 0.02, 0.985)
    bg:SetEdgeColor(0.86, 0.66, 0.12, 1)
    bg:SetMouseEnabled(false)

    local title = WINDOW_MANAGER:CreateControl("EASMarketContextPanelTitle029685", panel, CT_LABEL)
    title:SetAnchor(TOPLEFT, panel, TOPLEFT, 18, 14)
    title:SetFont("ZoFontWinH2")
    title:SetColor(1, 0.82, 0.2, 1)
    title:SetText("ESO ADVENTURER SUITE MARKET")

    local close = WINDOW_MANAGER:CreateControl("EASMarketContextPanelClose029685", panel, CT_BUTTON)
    close:SetDimensions(34, 28)
    close:SetAnchor(TOPRIGHT, panel, TOPRIGHT, -10, 10)
    close:SetFont("ZoFontGameBold")
    close:SetText("X")
    close:SetHandler("OnClicked", function() panel:SetHidden(true) end)

    local content = WINDOW_MANAGER:CreateControl("EASMarketContextPanelContent029685", panel, CT_LABEL)
    content:SetAnchor(TOPLEFT, panel, TOPLEFT, 18, 54)
    content:SetDimensions(584, 300)
    content:SetFont("ZoFontGame")
    content:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    content:SetVerticalAlignment(TEXT_ALIGN_TOP)
    content:SetColor(1, 1, 1, 1)

    local travel = WINDOW_MANAGER:CreateControl("EASMarketContextPanelTravel029685", panel, CT_BUTTON)
    travel:SetDimensions(430, 38)
    travel:SetAnchor(BOTTOMLEFT, panel, BOTTOMLEFT, 18, -18)
    travel:SetFont("ZoFontGameBold")
    travel:SetText("TRAVEL TO CHEAPEST LOCATED TRADER")
    travel:SetHandler("OnClicked", function()
        local record = panel.travelRecord
        if not record then return end
        M.activeLocatedListing = record
        M:TravelToActiveListing029683()
    end)

    local hint = WINDOW_MANAGER:CreateControl("EASMarketContextPanelHint029685", panel, CT_LABEL)
    hint:SetAnchor(BOTTOMRIGHT, panel, BOTTOMRIGHT, -18, -27)
    hint:SetFont("ZoFontGameSmall")
    hint:SetColor(0.68, 0.68, 0.68, 1)
    hint:SetText("Drag panel to move")

    panel.bg, panel.title, panel.close, panel.content, panel.travel, panel.hint = bg, title, close, content, travel, hint
    panel:SetHandler("OnMouseDown", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and type(control.StartMoving) == "function" then control:StartMoving() end
    end)
    panel:SetHandler("OnMouseUp", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and type(control.StopMovingOrResizing) == "function" then control:StopMovingOrResizing() end
    end)
    panel:SetHidden(true)
    M.marketContextPanel029685 = panel
    return panel
end

function M:ShowMarketContextPanel029685(itemLink, clickedRecord)
    if type(itemLink) ~= "string" or itemLink == "" then return end
    local panel = ensurePanel()
    if not panel then return end

    local primary, cross = nil, nil
    if type(self.GetMarketSources029683) == "function" then
        primary, cross = self:GetMarketSources029683(itemLink)
    elseif type(self.GetMarketData029683) == "function" then
        primary = self:GetMarketData029683(itemLink)
    end
    local rows = type(self.GetComparableTraderListings029683) == "function" and self:GetComparableTraderListings029683(itemLink, 12) or {}
    local travelRecord = type(self.GetBestTravelTrader029683) == "function" and self:GetBestTravelTrader029683(itemLink) or nil

    local itemName = type(GetItemLinkName) == "function" and clean(GetItemLinkName(itemLink)) or "Item"
    local lines = { GOLD .. itemName .. RESET }

    local function sourceLine(label, market)
        if type(market) ~= "table" then return end
        local bits = { CYAN .. label .. RESET }
        if safeNumber(market.min) then bits[#bits + 1] = "Global low " .. GOLD .. formatNumber(market.min) .. "g" .. RESET .. GREY .. " (location unknown)" .. RESET end
        if safeNumber(market.avg) then bits[#bits + 1] = "Avg " .. formatNumber(market.avg) .. "g" end
        if safeNumber(market.listings) then bits[#bits + 1] = formatNumber(market.listings) .. " listings" end
        local stamp = safeNumber(market.timestamp) or 0
        if stamp > 0 then bits[#bits + 1] = GREY .. formatAge(math.max(0, now() - stamp)) .. " old" .. RESET end
        lines[#lines + 1] = table.concat(bits, "   ")
    end

    sourceLine("Aggregate", primary)
    sourceLine("Cross-check", cross)

    if clickedRecord then
        local line = WHITE .. "RIGHT-CLICKED LISTING  " .. GOLD .. formatNumber(clickedRecord.unitPrice) .. "g/unit" .. RESET
        if safeNumber(clickedRecord.amount) and clickedRecord.amount > 1 then
            line = line .. GREY .. "  x" .. tostring(math.floor(clickedRecord.amount)) .. " = " .. formatNumber(clickedRecord.totalPrice) .. "g" .. RESET
        end
        lines[#lines + 1] = line
    end

    local others = 0
    for _, row in ipairs(rows) do if not row._easCurrentTrader then others = others + 1 end end
    lines[#lines + 1] = CYAN .. "VERIFIED LOCATED TRADERS" .. RESET .. GREY .. "  " .. tostring(#rows) .. " known / " .. tostring(others) .. " other" .. RESET

    if #rows == 0 then
        lines[#lines + 1] = YELLOW .. "No verified trader locations are cached for this item yet." .. RESET
    else
        for i = 1, math.min(MAX_ROWS, #rows) do
            local row = rows[i]
            local location = type(self.GetLocationInfo029683) == "function" and self:GetLocationInfo029683(row) or nil
            local where = location and clean(location.label) or clean(row.locationName)
            local guild = clean(row.guildName)
            local marker = row._easCurrentTrader and (GREEN .. "CURRENT" .. RESET) or (WHITE .. "OTHER" .. RESET)
            local line = tostring(i) .. ". " .. GOLD .. formatNumber(row.unitPrice) .. "g" .. RESET .. "  " .. marker
            if guild ~= "" then line = line .. "  " .. CYAN .. guild .. RESET end
            if where ~= "" then line = line .. "  " .. WHITE .. where .. RESET end
            lines[#lines + 1] = line
        end
    end

    if others == 0 then
        lines[#lines + 1] = GREY .. "Aggregate ESO-Hub/TTC pricing cannot identify the guild trader that owns its global-low price." .. RESET
    end

    panel.content:SetText(table.concat(lines, "\n"))
    panel.travelRecord = travelRecord
    if travelRecord then
        local location = self:GetLocationInfo029683(travelRecord)
        local label = location and clean(location.label) or "LOCATED TRADER"
        panel.travel:SetText("TRAVEL TO: " .. label .. " — " .. formatNumber(travelRecord.unitPrice) .. "g")
        panel.travel:SetEnabled(true)
        panel.travel:SetAlpha(1)
    else
        panel.travel:SetText("NO OTHER VERIFIED TRADER LOCATION AVAILABLE")
        panel.travel:SetEnabled(false)
        panel.travel:SetAlpha(0.55)
    end

    if type(self.HideTravelButton029683) == "function" then self:HideTravelButton029683() end
    panel:SetHidden(false)
end

function M:EnsureMarketTooltipShade029685(tooltip)
    if not tooltip or not WINDOW_MANAGER then return nil end
    if tooltip._easMarketShade029685 then
        tooltip._easMarketShade029685:SetHidden(false)
        return tooltip._easMarketShade029685
    end
    local shade = WINDOW_MANAGER:CreateControl(nil, tooltip, CT_BACKDROP)
    shade:SetAnchorFill(tooltip)
    shade:SetCenterColor(0.01, 0.01, 0.015, 0.965)
    shade:SetEdgeColor(0.35, 0.28, 0.08, 0.95)
    shade:SetMouseEnabled(false)
    if type(shade.SetDrawLayer) == "function" and DL_BACKGROUND ~= nil then shade:SetDrawLayer(DL_BACKGROUND) end
    tooltip._easMarketShade029685 = shade
    local oldHide = tooltip:GetHandler("OnHide")
    tooltip:SetHandler("OnHide", function(control)
        if oldHide then pcall(oldHide, control) end
        if control._easMarketShade029685 then control._easMarketShade029685:SetHidden(true) end
    end)
    return shade
end

local baseAppendMarketTooltip029683 = M.AppendMarketTooltip029683
function M:AppendMarketTooltip029683(tooltip, itemLink)
    baseAppendMarketTooltip029683(self, tooltip, itemLink)
    local primary, cross = nil, nil
    if type(itemLink) == "string" and itemLink ~= "" then
        if type(self.GetMarketSources029683) == "function" then
            primary, cross = self:GetMarketSources029683(itemLink)
        elseif type(self.GetMarketData029683) == "function" then
            primary = self:GetMarketData029683(itemLink)
        end
    end
    local rows = type(self.GetComparableTraderListings029683) == "function" and self:GetComparableTraderListings029683(itemLink, 1) or {}
    if primary or cross or #rows > 0 then self:EnsureMarketTooltipShade029685(tooltip) end
end

function M:OpenTraderRightClickMenu029685(searchResultSlot, button)
    if button ~= MOUSE_BUTTON_INDEX_RIGHT then return end
    local saved = EPC.saved or {}
    if saved.marketPriceCheckerEnabled029683 == false then return end

    local itemLink, clickedRecord = self:CaptureClickedTraderListing029685(searchResultSlot)
    if not itemLink then return end
    local travelRecord = self:GetBestTravelTrader029683(itemLink)

    if type(AddCustomMenuItem) ~= "function" or type(ShowMenu) ~= "function" then
        if EPC.Print then EPC:Print("LibCustomMenu is required for the Market right-click actions.") end
        return
    end

    AddCustomMenuItem("ESO ADVENTURER SUITE — OPEN MARKET DETAILS", function()
        M:ShowMarketContextPanel029685(itemLink, clickedRecord)
    end, MENU_ADD_OPTION_LABEL)

    if travelRecord and saved.marketPriceTravelEnabled029683 ~= false then
        local location = self:GetLocationInfo029683(travelRecord)
        local where = location and clean(location.label) or "Located Trader"
        local text = "TRAVEL TO " .. string.upper(where) .. " — " .. formatNumber(travelRecord.unitPrice) .. "g"
        AddCustomMenuItem(text, function()
            M.activeLocatedListing = travelRecord
            M:TravelToActiveListing029683()
        end, MENU_ADD_OPTION_LABEL)
    else
        AddCustomMenuItem("TRAVEL — NO OTHER VERIFIED TRADER LOCATION", function()
            if EPC.Print then EPC:Print("No other verified trader location is available for this item yet. Aggregate global-low pricing does not include a kiosk location.") end
        end, MENU_ADD_OPTION_LABEL)
    end

    ShowMenu(searchResultSlot)
end

if type(SecurePostHook) == "function" and type(rawget(_G, "ZO_TradingHouse_OnSearchResultClicked")) == "function" then
    SecurePostHook("ZO_TradingHouse_OnSearchResultClicked", function(searchResultSlot, button)
        if EPC.MarketPriceChecker then EPC.MarketPriceChecker:OpenTraderRightClickMenu029685(searchResultSlot, button) end
    end)
end

EPC.marketPriceContextMenu029685 = true
