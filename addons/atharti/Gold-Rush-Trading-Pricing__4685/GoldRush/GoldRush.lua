GoldRush = {}

local GR = GoldRush

local SECONDS_IN_HOUR = 3600
local SECONDS_IN_DAY = 24 * 60 * 60
local SECONDS_IN_WEEK = 604800
local ROW_HEIGHT = 30

local defaultSV = {
    keepDays = 30,
    windowLeft = 0,
    windowTop = 87,
    windowWidth = 956,
    windowHeight = 674,
    savedSales = {},
    lastEventIds = {},
	itemPriceHistory = {},
	guildProcessorsEnabled = {},
	guildMapping = {},
	enableSaleNotifications = true,
	enableSaleNotificationsChat = true,
	lifetimeGold = 0,
}

GR.SV = {}
GR.sales = {}
GR.guildListeners = {}
GR.avgPriceCache = {}
GR.ui = {}
GR.displayName = nil

GR._playerSales = {}
GR._salesToSave = {}

-- ============================================
-- Global functions for XML callbacks
-- ============================================

function GR.OnWindowInitialized(window)
    GR.ui = {}
    GR.ui.window = window
    GR.ui.scrollList = window:GetNamedChild("List")
    
    window:SetHandler("OnMoveStop", function()
        if GR.ui and GR.ui.window and GR.SV then
            GR.SV.windowLeft = GR.ui.window:GetLeft()
            GR.SV.windowTop = GR.ui.window:GetTop()
        end
    end)
	
    local lastWidth, lastHeight
    window:SetHandler("OnUpdate", function()
        if not GR.ui or not GR.ui.scrollList or not GR.ui.initialized or GR.ui.window:IsHidden() then
            return
        end
        local w, h = GR.ui.window:GetDimensions()
        if w ~= lastWidth or h ~= lastHeight then
            lastWidth, lastHeight = w, h
            ZO_ScrollList_Commit(GR.ui.scrollList)
        end
    end)	
	
	window:SetHandler("OnShow", GR.BuildSalesList)
    
    local headers = window:GetNamedChild("Headers")
	GR.headers = headers
    if headers then
        local guildHeader = headers:GetNamedChild("Guild")
        guildHeader:SetText("|t24:24:/esoui/art/icons/servicemappins/servicepin_guildkiosk.dds|t")
        
        local buyerHeader = headers:GetNamedChild("Buyer")
        buyerHeader:SetText("|t24:24:/esoui/art/tutorial/gamepad/gp_playermenu_icon_character.dds|t")
        
        local itemHeader = headers:GetNamedChild("Item")
        itemHeader:SetText("|t24:24:/esoui/art/notifications/gamepad/gp_notificationicon_trade.dds|t")
        
        local timeHeader = headers:GetNamedChild("Time")
        timeHeader:SetText("|t24:24:/esoui/art/addons/gamepad/gp_mod_listing_category_castbarsandcooldowns.dds|t")
        
        local priceHeader = headers:GetNamedChild("Price")
        priceHeader:SetText("|t24:24:/esoui/art/tradinghouse/tradinghouse_emptysellslot_icon.dds|t")
    end
	
    
    ZO_ScrollList_Initialize(GR.ui.scrollList)
    
    GR.ui.initialized = false
	
	GR.InitializeFooterControls()
	
	GR.fragment = ZO_HUDFadeSceneFragment:New(window)
	MAIL_INBOX_SCENE:AddFragment(GR.fragment)
	MAIL_SEND_SCENE:AddFragment(GR.fragment)

	window:SetHidden(true)
end

function GR.OnWindowResizeStop(window)    
    if GR.ui and GR.ui.window and GR.SV then
        GR.SV.windowLeft = GR.ui.window:GetLeft()
        GR.SV.windowTop = GR.ui.window:GetTop()
        GR.SV.windowWidth = GR.ui.window:GetWidth()
        GR.SV.windowHeight = GR.ui.window:GetHeight()
    end
    
    if GR.ui and GR.ui.scrollList and GR.ui.initialized then
        ZO_ScrollList_Commit(GR.ui.scrollList)
    end
end

function GR.CloseWindow()
    if GR.ui and GR.ui.window then
        GR.ui.window:SetHidden(true)
    end
end

function GR.FormatTimeAgo(timestamp)
    if not timestamp then return "" end
    return ZO_FormatDurationAgo(GetTimeStamp() - timestamp)
end

-- ============================================
-- Scroll List Functions
-- ============================================

function GR.SetupSaleRow(rowControl, rowData)
    local sale = rowData
    
    local guildLabel = rowControl:GetNamedChild("Guild")
    local buyerLabel = rowControl:GetNamedChild("Buyer")
    local itemControl = rowControl:GetNamedChild("Item")
    local itemText = itemControl:GetNamedChild("Text")
    local itemIcon = itemControl:GetNamedChild("Icon")
    local itemQty = itemControl:GetNamedChild("Quantity")
    local timeLabel = rowControl:GetNamedChild("Time")
    local priceLabel = rowControl:GetNamedChild("Price")
    
    local headers = GR.headers
    if headers then
        local headerGuild = headers:GetNamedChild("Guild")
        local headerBuyer = headers:GetNamedChild("Buyer")
        local headerItem = headers:GetNamedChild("Item")
        local headerTime = headers:GetNamedChild("Time")
        local headerPrice = headers:GetNamedChild("Price")
        local masterLeft = headers:GetLeft()

        guildLabel:ClearAnchors()
        guildLabel:SetAnchor(TOPLEFT, rowControl, TOPLEFT, headerGuild:GetLeft() - masterLeft, 0)
        guildLabel:SetWidth(headerGuild:GetWidth())

        buyerLabel:ClearAnchors()
        buyerLabel:SetAnchor(TOPLEFT, rowControl, TOPLEFT, headerBuyer:GetLeft() - masterLeft, 0)
        buyerLabel:SetWidth(headerBuyer:GetWidth())

        itemControl:ClearAnchors()
        itemControl:SetAnchor(TOPLEFT, rowControl, TOPLEFT, headerItem:GetLeft() - masterLeft, 0)
        itemControl:SetWidth(headerItem:GetWidth())

        timeLabel:ClearAnchors()
        timeLabel:SetAnchor(TOPLEFT, rowControl, TOPLEFT, headerTime:GetLeft() - masterLeft, 0)
        timeLabel:SetWidth(headerTime:GetWidth())

        priceLabel:ClearAnchors()
        priceLabel:SetAnchor(TOPLEFT, rowControl, TOPLEFT, headerPrice:GetLeft() - masterLeft, 0)
        priceLabel:SetWidth(headerPrice:GetWidth() - 5)
    end

    guildLabel:SetText(sale.guildName or "")
    buyerLabel:SetText(sale.buyerName or "")
    itemText:SetText(sale.itemLink or "")
    
	local icon = GetItemLinkIcon(sale.itemLink)
	if icon and icon ~= 0 then
		itemIcon:SetTexture(icon)
	end
    
    local qty = sale.quantity or 1
    if qty == 1 then
        itemQty:SetText("")
    else
        itemQty:SetText(tostring(qty))
    end
    
    timeLabel:SetText(GR.FormatTimeAgo(sale.timeStamp))
    priceLabel:SetText(GR.FormatPriceFull(sale.price or 0))
end

function GR.BuildSalesList()
    if not GR.ui or not GR.ui.scrollList or not GR.ui.initialized then return end
    
    ZO_ScrollList_Clear(GR.ui.scrollList)
    
    local dataList = ZO_ScrollList_GetDataList(GR.ui.scrollList)
    if not dataList then return end
    
    ZO_ClearNumericallyIndexedTable(GR._playerSales)
    
    local totalGoldEarned = 0

    for _, sale in pairs(GR.sales) do
        if GR.IsSaleInTimeWindow(sale.timeStamp) then
            table.insert(GR._playerSales, sale)
            totalGoldEarned = totalGoldEarned + (sale.price or 0)
        end
    end
    
    table.sort(GR._playerSales, function(a, b)
        return a.timeStamp > b.timeStamp
    end)
    
    for _, sale in ipairs(GR._playerSales) do
        local entry = ZO_ScrollList_CreateDataEntry(1, sale)
        table.insert(dataList, entry)
    end
    
    ZO_ScrollList_Commit(GR.ui.scrollList)

    local footerTextControl = GetControl("GR_MainWindowFooterTotalSalesText")
    if footerTextControl then
        footerTextControl:SetText(GR.FormatPriceFull(totalGoldEarned))
    end
end

function GR.FormatPriceFull(price)
    if not price or price == 0 then return "0" end
    local formatted = FormatIntegerWithDigitGrouping(math.floor(price), ",", 3)
    return formatted .. " |t16:16:EsoUI/Art/currency/currency_gold.dds|t"
end

function GR.NotifySale(sale)
    if not sale then return end

    local guildName = sale.guildName

    local msg = string.format(
        "%s: %dx %s %s |cFFC500→|r |cFFC500%s|r",
        GetString(SI_INVENTORY_SORT_TYPE_SELL_INFORMATION),
        sale.quantity,
        sale.itemLink,  
        GR.FormatPriceFull(sale.price),
        guildName
    )

    if GR.SV.enableSaleNotificationsChat ~= false then
        d(msg)
    end

    if GR.SV.enableSaleNotifications ~= false then
        CENTER_SCREEN_ANNOUNCE:AddMessage(
            nil,
            CSA_CATEGORY_SMALL_TEXT,
            SOUNDS.ITEM_MONEY_CHANGED,
            msg,
            nil,
            nil,
            nil,
            nil,
            nil,
            5000,
            nil,
            QUEUE_IMMEDIATELY,
            SHOW_IMMEDIATELY,
            REINSERT_STOMPED_MESSAGE
        )
    end
end

-- ============================================
-- Data Management
-- ============================================

function GR.CreateCleanSale(timestamp, guildName, buyer, quantity, itemLink, price, tax)
    local sale = {
        timeStamp = timestamp,
        guildName = guildName,
        buyerName = buyer,
        quantity = quantity or 1,
        itemLink = itemLink,
        price = price or 0,
        tax = tax or 0,
    }
    
    if sale.quantity and sale.quantity > 0 then
        sale.unitPrice = sale.price / sale.quantity
    else
        sale.unitPrice = sale.price
    end
    
    return sale
end

function GR.AddSale(eventId, timestamp, guildName, seller, buyer, quantity, itemLink, price, tax)
     if "@" .. seller ~= GR.displayName then return false end

    local normItemLink = GR.NormalizeItemLink(itemLink)
    if not normItemLink then return false end

    if GR.sales[eventId] then return false end

    local sale = GR.CreateCleanSale(timestamp, guildName, buyer, quantity, normItemLink, price, tax)
    GR.sales[eventId] = sale

    GR.SV.lifetimeGold = (GR.SV.lifetimeGold or 0) + (price or 0)

    GR.SaveSales()

    if GR.ui and GR.ui.initialized then
        GR.BuildSalesList()
    end

    if GR.SV.enableSaleNotifications ~= false then
        GR.NotifySale(sale)
    end

    return true
end

-- ============================================
-- Average Price Cache
-- ============================================

function GR.UpdateAvgPriceCache(itemLink)
    local dayBuckets = GR.SV.itemPriceHistory[itemLink]
    if not dayBuckets then
        GR.avgPriceCache[itemLink] = 0
        return
    end
    
    local totalGold = 0
    local totalQty = 0

    for dayId, data in pairs(dayBuckets) do
        totalGold = totalGold + data[1]
        totalQty = totalQty + data[2]
    end

    if totalQty > 0 then
        GR.avgPriceCache[itemLink] = totalGold / totalQty
    else
        GR.avgPriceCache[itemLink] = 0
    end
end

function GR.GetItemAveragePrice(itemLink)
    if GR.avgPriceCache[itemLink] == nil then
        GR.UpdateAvgPriceCache(itemLink)
    end
    return GR.avgPriceCache[itemLink]
end

function GR.RebuildAvgPriceCache()
    GR.avgPriceCache = {}
    for itemLink, _ in pairs(GR.SV.itemPriceHistory) do
        GR.UpdateAvgPriceCache(itemLink)
    end
end

-- ============================================
-- Tooltip Extension
-- ============================================

GR.tooltipControl = nil

function GR.CreateTooltipExtension()
    if GR.tooltipControl then return end

    GR.tooltipControl = CreateControl("GoldRushTooltipExtension", GuiRoot, CT_CONTROL)
    GR.tooltipControl:SetDimensions(350, 25) 
    GR.tooltipControl:SetHidden(true)

    local label = GR.tooltipControl:CreateControl("GoldRushTooltipPrice", CT_LABEL)
    label:SetFont("ZoFontGame")
    label:SetColor(1, 0.8, 0.2, 1) 
    label:SetAnchor(TOPLEFT, GR.tooltipControl, TOPLEFT, 0, 0)
    label:SetAnchor(TOPRIGHT, GR.tooltipControl, TOPRIGHT, 0, 0)
    label:SetHeight(25)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER) 
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetText("")

    GR.tooltipControl.label = label
end

function GR.FormatPricePouch(price)
    if not price or price == 0 then return "0" end
    
    local formatted
    if price < 100 then
        formatted = string.format("%.2f", price)
    else
        formatted = FormatIntegerWithDigitGrouping(math.floor(price), ",", 3)
    end
    
    return "|t25:25:/esoui/art/icons/item_generic_coinbag.dds|t " .. formatted
end

function GR.UpdateTooltip(tooltip, itemLink)
    if not itemLink or not GR.tooltipControl then return end

    local normItemLink = GR.NormalizeItemLink(itemLink)
    if not normItemLink then
        GR.tooltipControl:SetHidden(true)
        return
    end

    local avgPrice = GR.GetItemAveragePrice(normItemLink)
    if avgPrice and avgPrice > 0 then
        GR.tooltipControl.label:SetText(GR.FormatPricePouch(avgPrice))
        GR.tooltipControl:SetHidden(false)

        tooltip:AddControl(GR.tooltipControl, 0, false)
        GR.tooltipControl:ClearAnchors()
        -- GR.tooltipControl:SetAnchor(CENTER)
		GR.tooltipControl:SetAnchor(CENTER, nil, CENTER, 0, 5)

    else
        GR.tooltipControl:SetHidden(true)
    end
end

function GR.HideTooltipExtension()
    if GR.tooltipControl then
        GR.tooltipControl:SetHidden(true)
    end
end

function GR.SetupTooltipHooks()
    GR.CreateTooltipExtension()

    local function HookSetMethod(methodName, linkGetter)
        ZO_PostHook(ItemTooltip, methodName, function(tooltip, ...)
            local itemLink = linkGetter and linkGetter(...)
            if itemLink then
                GR.UpdateTooltip(tooltip, itemLink)
            end
        end)
    end

    HookSetMethod("SetLink", function(itemLink) return itemLink end)

    HookSetMethod("SetBagItem", function(bag, index)
        return GetItemLink(bag, index)
    end)

    HookSetMethod("SetLootItem", function(lootId)
        return GetLootItemLink(lootId)
    end)

    HookSetMethod("SetWornItem", function(index, bagId)
        return GetItemLink(bagId, index)
    end)

    HookSetMethod("SetAttachedMailItem", function(mailId, index)
        return GetAttachedItemLink(mailId, index)
    end)

    HookSetMethod("SetStoreItem", function(storeIndex)
        return GetStoreItemLink(storeIndex)
    end)

    HookSetMethod("SetTradeItem", function(tradeType, tradeIndex)
        return GetTradeItemLink(tradeType, tradeIndex)
    end)

    HookSetMethod("SetTradingHouseItem", function(tradingHouseIndex)
        return GetTradingHouseSearchResultItemLink(tradingHouseIndex)
    end)

    HookSetMethod("SetTradingHouseListing", function(listingIndex)
        return GetTradingHouseListingItemLink(listingIndex)
    end)

    HookSetMethod("SetProvisionerResultItem", function(recipeListIndex, recipeIndex)
        return GetRecipeResultItemLink(recipeListIndex, recipeIndex)
    end)

    ItemTooltip:SetHandler("OnMouseExit", function()
        GR.HideTooltipExtension()
    end)
end

function GR.IsItemLink(itemLink)
    if type(itemLink) ~= "string" then return false end
    return itemLink:match("|H%d:item:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+|h.*|h") ~= nil
end

function GR.NormalizeItemLink(itemLink)
    if not GR.IsItemLink(itemLink) then return nil end

    itemLink = itemLink:gsub("H1:", "H0:")

    local prefix = itemLink:match("|H%d:item:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:")
    local suffix = itemLink:match(":%d+:%d+:%d+:%d+|h.*|h")
    if prefix and suffix then
        suffix = suffix:gsub("|h.*|h", "|h|h")
        return prefix .. "0" .. suffix
    end
end
-- ============================================
-- LibHistoire Integration
-- ============================================

function GR.InitLibHistoire()
    LibHistoire:OnReady(function()
        GR.SetupGuildListeners()
        
        LibHistoire:RegisterCallback(LibHistoire.callback.MANAGED_RANGE_LOST, function(guildId, category)
			if category ~= GUILD_HISTORY_EVENT_CATEGORY_TRADER then
				return
			end

			local guildName = GetGuildName(guildId)
			if not guildName then return end
			if GR.SV.guildProcessorsEnabled[guildName] == false then return end

			d("GoldRush: Managed range lost for " .. guildName .. " – restarting processor...")
			GR.SV.lastEventIds[guildName] = nil
			GR.SetupGuildProcessor(guildId, guildName)
		end)
    end)
end

function GR.SetupGuildProcessor(guildId, guildName)
    local processor = LibHistoire:CreateGuildHistoryProcessor(
        guildId,
        GUILD_HISTORY_EVENT_CATEGORY_TRADER,
        "GoldRush"
    )
    if not processor then
        d("GoldRush: No cache for guild " .. guildName)
        return
    end

    local lastEventId = GR.SV.lastEventIds[guildName]

    if lastEventId then
        processor:SetAfterEventId(lastEventId)
    else
        local cutoffTime = GetTimeStamp() - (GR.SV.keepDays or 30) * SECONDS_IN_DAY
        processor:SetAfterEventTime(cutoffTime)
    end

    processor:SetNextEventCallback(function(event)
        local info = event:GetEventInfo()
        if info.eventType == GUILD_HISTORY_TRADER_EVENT_ITEM_SOLD then
            local eventId = event:GetEventId()
            local timestamp = event:GetEventTimestampS()
            local seller = info.sellerDisplayName
            local buyer = "@" .. info.buyerDisplayName
            local quantity = info.quantity
            local itemLink = info.itemLink
            local price = info.price
            local tax = info.tax or 0

            GR.AddPriceHistory(itemLink, price, quantity, timestamp)
            GR.SV.lastEventIds[guildName] = eventId

            if "@" .. seller == GR.displayName then
                GR.AddSale(eventId, timestamp, guildName, seller, buyer,
                           quantity, itemLink, price, tax)
            end
        end
    end)

    processor:Start()
end

function GR.SetupGuildListeners()
    for i = 1, GetNumGuilds() do
        local guildId = GetGuildId(i)
        local guildName = GetGuildName(guildId)
        if guildName and guildName ~= "" then
            if GR.SV.guildProcessorsEnabled[guildName] ~= false then
                GR.SetupGuildProcessor(guildId, guildName)
            end
        end
    end
end

function GR.SaveSales()
    if not GR.SV then return end

    local cutoffTime = GetTimeStamp() - (GR.SV.keepDays or 30) * SECONDS_IN_DAY
    ZO_ClearTable(GR._salesToSave)

    GR.SV.guildMapping = GR.SV.guildMapping or {}

    for eventId, sale in pairs(GR.sales) do
        if type(eventId) == "number" and sale.timeStamp > cutoffTime then
            local guildId = GR.SV.guildMapping[sale.guildName]
            if not guildId then
                local maxId = 0
                for _, existingId in pairs(GR.SV.guildMapping) do
                    if existingId > maxId then maxId = existingId end
                end
                guildId = maxId + 1
                GR.SV.guildMapping[sale.guildName] = guildId
            end

            GR._salesToSave[eventId] = {
                sale.timeStamp,
                guildId,
                sale.buyerName,
                sale.quantity,
                sale.itemLink,
                sale.price,
                sale.tax,
            }
        end
    end

    GR.SV.savedSales = GR._salesToSave
end

function GR.LoadSavedSales()
    if not GR.SV or not GR.SV.savedSales then return end

    local cutoffTime = GetTimeStamp() - (GR.SV.keepDays or 30) * SECONDS_IN_DAY

    local idToName = {}
    for name, id in pairs(GR.SV.guildMapping or {}) do
        idToName[id] = name
    end

    for eventId, sale in pairs(GR.SV.savedSales) do
        if type(eventId) == "number" and type(sale) == "table" and #sale >= 7 then
            local guildName = idToName[sale[2]]
            if guildName then
                local normItemLink = GR.NormalizeItemLink(sale[5])
                if normItemLink then
                    local cleanSale = {
                        timeStamp = sale[1],
                        guildName = guildName,
                        buyerName = sale[3],
                        quantity = sale[4],
                        itemLink = normItemLink,
                        price = sale[6],
                        tax = sale[7],
                        unitPrice = sale[6] / sale[4],
                    }
                    if cleanSale.timeStamp > cutoffTime then
                        GR.sales[eventId] = cleanSale
                    end
                end
            end
        end
    end
end

-- ============================================
-- Item Price History Management
-- ============================================

function GR.AddPriceHistory(itemLink, price, quantity, timestamp)
    local normLink = GR.NormalizeItemLink(itemLink)
    if not normLink or not price or price <= 0 or not quantity or quantity <= 0 then return end

    if not GR.SV.itemPriceHistory[normLink] then
        GR.SV.itemPriceHistory[normLink] = {}
    end

    local dayId = math.floor((timestamp or GetTimeStamp()) / 86400)
    local dayData = GR.SV.itemPriceHistory[normLink][dayId]

    if not dayData then
        GR.SV.itemPriceHistory[normLink][dayId] = { price, quantity }
    else
        dayData[1] = dayData[1] + price
        dayData[2] = dayData[2] + quantity
    end

    GR.avgPriceCache[normLink] = nil
end

function GR.CleanPriceHistory()
    local currentDay = math.floor(GetTimeStamp() / 86400)
    local cutoffDay = currentDay - (GR.SV.keepDays or 30)
    local cleanedCount = 0
    
    for itemLink, dayBuckets in pairs(GR.SV.itemPriceHistory) do
        for dayId, _ in pairs(dayBuckets) do
            if dayId < cutoffDay then
                dayBuckets[dayId] = nil
                cleanedCount = cleanedCount + 1
            end
        end
        
        if next(dayBuckets) == nil then
            GR.SV.itemPriceHistory[itemLink] = nil
        end
    end
    
    if cleanedCount > 0 then
        GR.RebuildAvgPriceCache()
    end
end

GR.selectedTimeWindow = 1

local DAYS_BACK_TO_TUESDAY = {
    [0] = 2, -- Thursday
    [1] = 3, -- Friday
    [2] = 4, -- Saturday
    [3] = 5, -- Sunday
    [4] = 6, -- Monday
    [5] = 0, -- Tuesday
    [6] = 1, -- Wednesday
}

function GR.GetStartOfTradingWeek(relativeWeek)
    relativeWeek = relativeWeek or 0
    local currentTimeStamp = GetTimeStamp()
    
    local days = math.floor(currentTimeStamp / SECONDS_IN_DAY)
    local today = days % 7

    local midnightCurrentDay = days * SECONDS_IN_DAY
    
    local targetTuesdayMidnight = midnightCurrentDay - (DAYS_BACK_TO_TUESDAY[today] * SECONDS_IN_DAY)
    
    local isEU = (GetWorldName() == "EU Megaserver")
    local flipHour = isEU and 14 or 19
    
    local flipTimeStamp = targetTuesdayMidnight + (flipHour * SECONDS_IN_HOUR)
    
    if currentTimeStamp < flipTimeStamp then
        flipTimeStamp = flipTimeStamp - SECONDS_IN_WEEK
    end
    
    return flipTimeStamp + (relativeWeek * SECONDS_IN_WEEK)
end

function GR.IsSaleInTimeWindow(saleTimestamp)
    local now = GetTimeStamp()
    if GR.selectedTimeWindow == 1 then
        return saleTimestamp >= GR.GetStartOfTradingWeek(0)
    elseif GR.selectedTimeWindow == 2 then
        return saleTimestamp >= (now - (30 * SECONDS_IN_DAY))
    end
    return true
end

function GR.ShowFooterTooltip(control)
    InitializeTooltip(InformationTooltip, control, BOTTOMLEFT, 0, -5, TOPLEFT)
    
    InformationTooltip:AddLine("|t32:32:/esoui/art/icons/item_generic_coinbag.dds|t")
    
    ZO_Tooltip_AddDivider(InformationTooltip)

    local localGuildTotals = {}
    for _, sale in pairs(GR.sales) do
        if GR.IsSaleInTimeWindow(sale.timeStamp) and sale.guildName then
            localGuildTotals[sale.guildName] = (localGuildTotals[sale.guildName] or 0) + (sale.price or 0)
        end
    end

    local activeGuildsFound = false 
    for guildName, gold in pairs(localGuildTotals) do
        if gold > 0 then
            activeGuildsFound = true
            local goldString = GR.FormatPriceFull(gold)
            
            InformationTooltip:AddLine(guildName .. ":  |cE6B84C" .. goldString .. "|r")
        end
    end

    if not activeGuildsFound then
        InformationTooltip:AddLine("|t32:32:/esoui/art/inventory/inventory_sell_forbidden_icon.dds|t")
    end

    ZO_Tooltip_AddDivider(InformationTooltip)
    
    local lifetimeGold = GR.SV and GR.SV.lifetimeGold or 0
    local lifetimeString = FormatIntegerWithDigitGrouping(math.floor(lifetimeGold), ",", 3)
    
    InformationTooltip:AddLine("|t20:20:/esoui/art/icons/item_generic_coinbag.dds|t  |cE6B84C" .. lifetimeString .. " |t16:16:EsoUI/Art/currency/currency_gold.dds|t|r")
end

function GR.InitializeFooterControls()
    local dropdownControl = GetControl("GR_MainWindowFooterTimeDropdown")
    if not dropdownControl then return end

    local comboBox = ZO_ComboBox_ObjectFromContainer(dropdownControl)
    comboBox:SetFont("ZoFontGame")
    comboBox:SetSpacing(4)

    local function OnWindowOptionSelected(_, selectionString, choiceEntry)
        GR.selectedTimeWindow = choiceEntry.windowId
        GR.BuildSalesList()
    end

    local orderedOptions = {
        {
            id = 1,
            text = FormatTimeSeconds(7 * 24 * 60 * 60, TIME_FORMAT_STYLE_DESCRIPTIVE, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING) -- "1 Week"
        },
        {
            id = 2,
            text = FormatTimeSeconds(30 * 24 * 60 * 60, TIME_FORMAT_STYLE_DESCRIPTIVE, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING) -- "30 Days"
        }
    }

    local defaultEntry = nil

    for _, option in ipairs(orderedOptions) do
        local entry = comboBox:CreateItemEntry(option.text, OnWindowOptionSelected)
        entry.windowId = option.id
        comboBox:AddItem(entry, ZO_COMBOBOX_SUPPRESS_UPDATE)
        
        if option.id == 1 then
            defaultEntry = entry
        end
    end

    if defaultEntry then
        comboBox:SelectItem(defaultEntry)
    else
        comboBox:SelectItemByIndex(1)
    end
end

function GR.CleanGuildData()
    if not GR.SV then return end

    local currentGuilds = {}
    for i = 1, GetNumGuilds() do
        local guildId = GetGuildId(i)
        local guildName = GetGuildName(guildId)
        if guildName and guildName ~= "" then
            currentGuilds[guildName] = true
        end
    end

    if GR.SV.lastEventIds then
        for guildName, _ in pairs(GR.SV.lastEventIds) do
            if not currentGuilds[guildName] then
                GR.SV.lastEventIds[guildName] = nil
            end
        end
    end

    if GR.SV.guildMapping then
        for guildName, _ in pairs(GR.SV.guildMapping) do
            if not currentGuilds[guildName] then
                local hasSales = false
                for _, sale in pairs(GR.sales) do
                    if sale.guildName == guildName then
                        hasSales = true
                        break
                    end
                end

                if not hasSales then
                    GR.SV.guildMapping[guildName] = nil
                end
            end
        end
    end
	
	if GR.SV.guildProcessorsEnabled then
        for guildName, _ in pairs(GR.SV.guildProcessorsEnabled) do
            if not currentGuilds[guildName] then
                GR.SV.guildProcessorsEnabled[guildName] = nil
            end
        end
    end
end

-- ============================================
-- On Load
-- ============================================

local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= "GoldRush" then return end
    
    EVENT_MANAGER:UnregisterForEvent("GoldRush", EVENT_ADD_ON_LOADED)
    
    GR.displayName = GetDisplayName()
    
    GR.SV = ZO_SavedVars:NewAccountWide("GoldRush_SV", 2, nil, defaultSV, GetWorldName())	
	
	GR.InitSettings()
    
    GR.LoadSavedSales()
    
    GR.CleanPriceHistory()
	
	GR.CleanGuildData()
	
	GR.RebuildAvgPriceCache()
	
	GR.SetupTooltipHooks()
	
	GR.SetupKioskRowInjections()
    
    if GR.ui and GR.ui.window then
        GR.ui.window:SetWidth(GR.SV.windowWidth)
        GR.ui.window:SetHeight(GR.SV.windowHeight)
        GR.ui.window:ClearAnchors()
        GR.ui.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, GR.SV.windowLeft, GR.SV.windowTop)
    end
    
    GR.InitLibHistoire()
    
    if GR.ui then
        if not GR.ui.initialized then
            ZO_ScrollList_AddDataType(GR.ui.scrollList, 1, "GR_SalesRowTemplate", ROW_HEIGHT, GR.SetupSaleRow)
            GR.ui.initialized = true
        end
    end
end

EVENT_MANAGER:RegisterForEvent("GoldRush", EVENT_ADD_ON_LOADED, OnAddOnLoaded)