-- ============================================
-- GUILD SALES TRACKER (GST) LOGIC
-- ============================================

-- Localize globals for performance
local GetItemLinkItemId = GetItemLinkItemId
local GetItemLinkName = GetItemLinkName
local GetItemLinkItemType = GetItemLinkItemType
local math_floor = math.floor
local GetTimeStamp = GetTimeStamp
local GetDisplayName = GetDisplayName
local GetGuildName = GetGuildName
local string_format = string.format
local tostring = tostring
local type = type
local GetGameTimeMilliseconds = GetGameTimeMilliseconds

-- Category lookup table for massive performance boost
local itemTypeToCategory = {
    [ITEMTYPE_REAGENT] = "Reagents",
    [ITEMTYPE_POISON_BASE] = "Solvents",
    [ITEMTYPE_POTION_BASE] = "Solvents",
    [ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = "Raw Metal",
    [ITEMTYPE_BLACKSMITHING_MATERIAL] = "Refined Metal",
    [ITEMTYPE_BLACKSMITHING_BOOSTER] = "Tempers",
    [ITEMTYPE_CLOTHIER_RAW_MATERIAL] = "Raw Cloth/Leather",
    [ITEMTYPE_CLOTHIER_MATERIAL] = "Refined Cloth",
    [ITEMTYPE_CLOTHIER_BOOSTER] = "Tannins",
    [ITEMTYPE_WOODWORKING_RAW_MATERIAL] = "Raw Wood",
    [ITEMTYPE_WOODWORKING_MATERIAL] = "Refined Wood",
    [ITEMTYPE_WOODWORKING_BOOSTER] = "Resins",
    [ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL] = "Raw Jewelry",
    [ITEMTYPE_JEWELRYCRAFTING_MATERIAL] = "Refined Jewelry",
    [ITEMTYPE_JEWELRYCRAFTING_BOOSTER] = "Jewelry Plating",
    [ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER] = "Jewelry Plating",
    [ITEMTYPE_ENCHANTING_RUNE_ASPECT] = "Aspect Runes",
    [ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = "Essence Runes",
    [ITEMTYPE_ENCHANTING_RUNE_POTENCY] = "Potency Runes",
    [ITEMTYPE_INGREDIENT] = "Ingredients",
    [ITEMTYPE_FOOD] = "Food",
    [ITEMTYPE_DRINK] = "Drinks",
    [ITEMTYPE_STYLE_MATERIAL] = "Style Mats",
    [ITEMTYPE_ARMOR_TRAIT] = "Trait Stones",
    [ITEMTYPE_WEAPON_TRAIT] = "Trait Stones",
    [ITEMTYPE_JEWELRY_TRAIT] = "Jewelry Traits",
    [ITEMTYPE_JEWELRY_RAW_TRAIT] = "Jewelry Traits",
    [ITEMTYPE_RAW_MATERIAL] = "Raw Mats",
    [ITEMTYPE_FURNISHING] = "Furnishings",
    [ITEMTYPE_FURNISHING_MATERIAL] = "Furnishing Mats",
    [ITEMTYPE_ARMOR] = "Armor",
    [ITEMTYPE_WEAPON] = "Weapons",
    [ITEMTYPE_GLYPH_ARMOR] = "Armor Glyphs",
    [ITEMTYPE_GLYPH_JEWELRY] = "Jewelry Glyphs",
    [ITEMTYPE_GLYPH_WEAPON] = "Weapon Glyphs",
    [ITEMTYPE_POTION] = "Potions",
    [ITEMTYPE_POISON] = "Poisons",
    [ITEMTYPE_RECIPE] = "Recipes",
    [ITEMTYPE_RACIAL_STYLE_MOTIF] = "Motifs",
    [ITEMTYPE_MASTER_WRIT] = "Master Writs",
    [ITEMTYPE_SOUL_GEM] = "Soul Gems",
    [ITEMTYPE_TREASURE] = "Treasure",
    [ITEMTYPE_TROPHY] = "Trophies",
    [ITEMTYPE_CONTAINER] = "Containers",
    [ITEMTYPE_FISH] = "Fish",
    [ITEMTYPE_SIEGE] = "Siege",
}

-- Module-level state
local gstScanning = false
local gstEventQueue = {}
local gstIsProcessingQueue = false
local gstRequestQueue = {}
local gstActiveRequest = nil
local gstLastRequestTime = 0
local gstScanGuildId = nil
local gstScanComplete = false
local gstScanEventCount = 0
local gstBankEventCount = 0
local gstLastKioskName = ""
local gstLoadingGuilds = false
local gstCategoryCallbackRegistered = false
local gstCurrentScanGuildId = nil

-- Time period constants (seconds)
local TIME_PERIODS = {
    { key = "month", seconds = 30 * 86400, name = "30 Days" },
    { key = "prevWeek", seconds = 14 * 86400, minAge = 7 * 86400, name = "Last Week" },
    { key = "week", seconds = 7 * 86400, name = "7 Days" },
    { key = "day", seconds = 86400, name = "24 Hours" },
}

-- Memory optimized temporary scan data
local gstScanData = {}

local function CreateEmptyPeriodData()
    return {
        sellers = {},
        buyers = {},
        items = {},
        categories = {},
        mySales = 0,
        myGold = 0,
        myTax = 0,
        myBestSale = 0,
        myBestItem = "",
        myItems = {},
        totalSales = 0,
        totalGold = 0,
        totalTax = 0,
        deposits = 0,
        withdrawals = 0,
        traderCost = 0,
        kioskBids = 0,
        kioskRefunds = 0,
        -- NEW: Health metrics
        bigTicketCount = 0,
        bigTicketGold = 0,
        depositorCount = 0,
        depositors = {},
    }
end

local function ClearScanData()
    gstScanData = {
        month = CreateEmptyPeriodData(),
        prevWeek = CreateEmptyPeriodData(),
        week = CreateEmptyPeriodData(),
        day = CreateEmptyPeriodData(),
        oldestSale = 0,
        newestSale = 0,
        kioskName = "",
    }
    gstScanEventCount = 0
end

-- Initialize GST (just load guild names, no auto-scan)
function NWT.InitGuildSalesTracker()
    local numGuilds = GetNumGuilds()
    local sv = NWT.savedVars
    
    for i = 1, numGuilds do
        local guildId = GetGuildId(i)
        local guildName = GetGuildName(guildId) or ("Guild " .. i)
        sv.gstGuildNames[guildId] = guildName
        
        -- Enable all guilds by default if not set
        if sv.gstGuildEnabled[guildId] == nil then
            sv.gstGuildEnabled[guildId] = true
        end
    end
    
    -- NOTE: Bank gold filter hooks are now deferred until filter is actually used
    -- This prevents interference with normal guild history display
end

-- Scan bank gold events using GUILD_HISTORY_EVENT_CATEGORY_BANKED_CURRENCY
function NWT.ScanGuildBankGold(guildIndex)
    local guildId = GetGuildId(guildIndex)
    local guildName = GetGuildName(guildId) or ("Guild " .. guildIndex)
    local sv = NWT.savedVars
    
    -- Initialize bank gold tracking
    if not sv.gstGuildBankGold then sv.gstGuildBankGold = {} end
    if not sv.gstGuildBankGold[guildId] then
        sv.gstGuildBankGold[guildId] = { deposits = 0, withdrawals = 0, depositCount = 0, withdrawalCount = 0, members = {} }
    end
    
    if not GUILD_HISTORY_EVENT_CATEGORY_BANKED_CURRENCY then return end
    
    local category = GUILD_HISTORY_EVENT_CATEGORY_BANKED_CURRENCY
    local success, numEvents = pcall(GetNumGuildHistoryEvents, guildId, category)
    
    if not success or not numEvents or numEvents == 0 then return end
    
    local bankData = sv.gstGuildBankGold[guildId]
    
    for eventIndex = 1, numEvents do
        local ok, eventId, timestampS = pcall(GetGuildHistoryEventBasicInfo, guildId, category, eventIndex)
        if ok and eventId then
            local infoOk, eventType, currencyType, amount, displayName = pcall(function()
                return GetGuildHistoryBankedCurrencyEventInfo(guildId, eventIndex)
            end)
            
            if infoOk and eventType and amount and amount > 0 then
                if not currencyType or currencyType == CURT_MONEY then
                    if displayName and displayName ~= "" then
                        if not bankData.members[displayName] then
                            bankData.members[displayName] = { deposits = 0, withdrawals = 0 }
                        end
                    end
                    
                    if eventType == GUILD_HISTORY_BANKED_CURRENCY_EVENT_DEPOSITED then
                        bankData.deposits = bankData.deposits + amount
                        bankData.depositCount = bankData.depositCount + 1
                        if displayName and bankData.members[displayName] then
                            bankData.members[displayName].deposits = bankData.members[displayName].deposits + amount
                        end
                    elseif eventType == GUILD_HISTORY_BANKED_CURRENCY_EVENT_WITHDRAWN then
                        bankData.withdrawals = bankData.withdrawals + amount
                        bankData.withdrawalCount = bankData.withdrawalCount + 1
                        if displayName and bankData.members[displayName] then
                            bankData.members[displayName].withdrawals = bankData.members[displayName].withdrawals + amount
                        end
                    end
                end
            end
        end
    end
end

-- Process data from a single event (shared by LibHistoire and manual scan)
local function InternalProcessEventData(guildId, event)
    if not event or type(event.GetEventId) ~= "function" then return end
    
    local eventId = event:GetEventId()
    if not eventId then return end
    
    local sv = NWT.savedVars
    local sd = NWT.sessionData
    if not sd then return end
    
    if type(event.GetEventType) ~= "function" or event:GetEventType() ~= GUILD_HISTORY_TRADER_EVENT_ITEM_SOLD then 
        return 
    end
    
    local timestampS, sellerName, buyerName, itemLink, quantity, price, tax = 0, "", "", "", 1, 0, 0
    
    if type(event.GetEventInfo) == "function" then
        local info = event:GetEventInfo()
        if info then
            sellerName = info.sellerDisplayName or ""
            buyerName = info.buyerDisplayName or ""
            itemLink = info.itemLink or ""
            quantity = info.quantity or 1
            price = info.price or 0
            tax = info.tax or 0
        end
    end
    
    if sellerName == "" and type(event.GetSellerDisplayName) == "function" then sellerName = event:GetSellerDisplayName() or "" end
    if buyerName == "" and type(event.GetBuyerDisplayName) == "function" then buyerName = event:GetBuyerDisplayName() or "" end
    if itemLink == "" and type(event.GetItemLink) == "function" then itemLink = event:GetItemLink() or "" end
    if quantity == 1 and type(event.GetQuantity) == "function" then quantity = event:GetQuantity() or 1 end
    if price == 0 and type(event.GetPrice) == "function" then price = event:GetPrice() or 0 end
    if tax == 0 and type(event.GetTax) == "function" then tax = event:GetTax() or 0 end
    
    if type(event.GetTimeStampS) == "function" then
        timestampS = event:GetTimeStampS() or 0
    elseif type(event.GetEventTimestampS) == "function" then
        timestampS = event:GetEventTimestampS() or 0
    end
    
    if not itemLink or itemLink == "" then return end
    
    sv.gstLastEventIds[guildId] = eventId
    if sv.gstOldestSale == 0 or timestampS < sv.gstOldestSale then sv.gstOldestSale = timestampS end
    if timestampS > sv.gstNewestSale then sv.gstNewestSale = timestampS end
    sv.gstTotalEvents = (sv.gstTotalEvents or 0) + 1
    
    local itemId = GetItemLinkItemId(itemLink)
    if not itemId or itemId == 0 then return end
    
    local pricePerUnit = math_floor(price / quantity)
    local itemName = GetItemLinkName(itemLink) or "Unknown"
    local now = GetTimeStamp()
    local isRecent = (timestampS >= (now - (7 * 86400)))
    
    if not sv.gstGuildStats[guildId] then
        sv.gstGuildStats[guildId] = { oldestSale = timestampS, newestSale = timestampS, totalSales = 0, totalGold = 0, totalTax = 0 }
    end
    local guildStats = sv.gstGuildStats[guildId]
    guildStats.totalSales = guildStats.totalSales + 1
    guildStats.totalGold = guildStats.totalGold + price
    guildStats.totalTax = guildStats.totalTax + tax
    if timestampS < guildStats.oldestSale then guildStats.oldestSale = timestampS end
    if timestampS > guildStats.newestSale then guildStats.newestSale = timestampS end
    
    local myDisplayName = GetDisplayName()
    if sellerName == myDisplayName then
        sv.gstMySales = (sv.gstMySales or 0) + 1
        sv.gstMyGold = (sv.gstMyGold or 0) + price
        sv.gstMyTax = (sv.gstMyTax or 0) + tax
    end
    
    if not isRecent then return end
    
    -- Detailed Session Data (7 Days)
    local gstSales = sd.gstSales
    if not gstSales[itemId] then
        gstSales[itemId] = { name = itemName, totalSold = 0, totalGold = 0, totalTax = 0, minPrice = pricePerUnit, maxPrice = pricePerUnit }
    end
    local itemData = gstSales[itemId]
    itemData.totalSold = itemData.totalSold + quantity
    itemData.totalGold = itemData.totalGold + price
    itemData.totalTax = itemData.totalTax + tax
    if pricePerUnit < itemData.minPrice then itemData.minPrice = pricePerUnit end
    if pricePerUnit > itemData.maxPrice then itemData.maxPrice = pricePerUnit end
    
    if not sd.gstGuildItems[guildId] then sd.gstGuildItems[guildId] = {} end
    local guildItems = sd.gstGuildItems[guildId]
    if not guildItems[itemId] then
        guildItems[itemId] = { name = itemName, totalSold = 0, totalGold = 0, totalTax = 0, minPrice = pricePerUnit, maxPrice = pricePerUnit }
    end
    local guildItemData = guildItems[itemId]
    guildItemData.totalSold = guildItemData.totalSold + quantity
    guildItemData.totalGold = guildItemData.totalGold + price
    guildItemData.totalTax = guildItemData.totalTax + tax
    if pricePerUnit < guildItemData.minPrice then guildItemData.minPrice = pricePerUnit end
    if pricePerUnit > guildItemData.maxPrice then guildItemData.maxPrice = pricePerUnit end
    
    if not sd.gstGuildSellers[guildId] then sd.gstGuildSellers[guildId] = {} end
    local guildSellers = sd.gstGuildSellers[guildId]
    if not guildSellers[sellerName] then
        guildSellers[sellerName] = { totalSales = 0, totalGold = 0, totalTax = 0, firstSale = timestampS, lastSale = timestampS }
    end
    local sellerData = guildSellers[sellerName]
    sellerData.totalSales = sellerData.totalSales + 1
    sellerData.totalGold = sellerData.totalGold + price
    sellerData.totalTax = sellerData.totalTax + tax
    if timestampS < (sellerData.firstSale or timestampS) then sellerData.firstSale = timestampS end
    if timestampS > (sellerData.lastSale or 0) then sellerData.lastSale = timestampS end
    
    -- Category Stats
    local itemType = GetItemLinkItemType(itemLink)
    local categoryName = itemTypeToCategory[itemType] or "Other"
    if not sd.gstItemCategories[guildId] then sd.gstItemCategories[guildId] = {} end
    local guildCats = sd.gstItemCategories[guildId]
    if not guildCats[categoryName] then guildCats[categoryName] = { sales = 0, gold = 0 } end
    guildCats[categoryName].sales = guildCats[categoryName].sales + 1
    guildCats[categoryName].gold = guildCats[categoryName].gold + price
    
    if not sellerData.categories then sellerData.categories = {} end
    if not sellerData.categories[categoryName] then sellerData.categories[categoryName] = { sales = 0, gold = 0 } end
    sellerData.categories[categoryName].sales = sellerData.categories[categoryName].sales + 1
    sellerData.categories[categoryName].gold = sellerData.categories[categoryName].gold + price
end

local function ProcessGSTQueue()
    if #gstEventQueue == 0 then
        EVENT_MANAGER:UnregisterForUpdate("ContainerHighlighter_GSTQueue")
        gstIsProcessingQueue = false
        return
    end
    
    local startTime = GetGameTimeMilliseconds()
    local maxTime = 15
    while #gstEventQueue > 0 do
        local data = table.remove(gstEventQueue, 1)
        InternalProcessEventData(data.guildId, data.event)
        if (GetGameTimeMilliseconds() - startTime) > maxTime then break end
    end
    
    if #gstEventQueue == 0 then
        EVENT_MANAGER:UnregisterForUpdate("ContainerHighlighter_GSTQueue")
        gstIsProcessingQueue = false
    end
end

function NWT.ProcessLibHistoireEvent(guildId, event)
    if not event then return end
    table.insert(gstEventQueue, { guildId = guildId, event = event })
    if not gstIsProcessingQueue then
        gstIsProcessingQueue = true
        EVENT_MANAGER:RegisterForUpdate("ContainerHighlighter_GSTQueue", 100, ProcessGSTQueue)
    end
end

local function AddSaleToPeriod(pd, sellerName, buyerName, itemId, itemName, quantity, price, tax, myName, itemType)
    pd.totalSales = pd.totalSales + 1
    pd.totalGold = pd.totalGold + price
    pd.totalTax = pd.totalTax + tax
    
    -- Track big ticket sales (100k+)
    if price >= 100000 then
        pd.bigTicketCount = (pd.bigTicketCount or 0) + 1
        pd.bigTicketGold = (pd.bigTicketGold or 0) + price
    end
    
    if sellerName and myName then
        local cleanMyName = myName:gsub("^@", ""):lower()
        local cleanSellerName = sellerName:gsub("^@", ""):lower()
        if cleanSellerName == cleanMyName then
            pd.mySales = pd.mySales + 1
            pd.myGold = pd.myGold + price
            pd.myTax = pd.myTax + tax
            if price > pd.myBestSale then
                pd.myBestSale = price
                pd.myBestItem = itemName
            end
            if not pd.myItems[itemId] then pd.myItems[itemId] = { name = itemName, gold = 0, sold = 0 } end
            pd.myItems[itemId].gold = pd.myItems[itemId].gold + price
            pd.myItems[itemId].sold = pd.myItems[itemId].sold + quantity
        end
    end
    
    if sellerName and sellerName ~= "" then
        if not pd.sellers[sellerName] then pd.sellers[sellerName] = { totalSales = 0, totalGold = 0, totalTax = 0 } end
        local s = pd.sellers[sellerName]
        s.totalSales = s.totalSales + 1
        s.totalGold = s.totalGold + price
        s.totalTax = s.totalTax + tax
    end
    
    if buyerName and buyerName ~= "" then
        if not pd.buyers[buyerName] then pd.buyers[buyerName] = { totalPurchases = 0, totalSpent = 0 } end
        local b = pd.buyers[buyerName]
        b.totalPurchases = b.totalPurchases + 1
        b.totalSpent = b.totalSpent + price
    end
    
    if itemId and itemId > 0 then
        if not pd.items[itemId] then pd.items[itemId] = { name = itemName, totalSold = 0, totalGold = 0 } end
        local item = pd.items[itemId]
        item.totalSold = item.totalSold + quantity
        item.totalGold = item.totalGold + price
    end
    
    -- Track category data
    if itemType then
        local categoryName = itemTypeToCategory[itemType] or "Other"
        if not pd.categories[categoryName] then pd.categories[categoryName] = { sales = 0, gold = 0, items = {} } end
        local cat = pd.categories[categoryName]
        cat.sales = cat.sales + 1
        cat.gold = cat.gold + price
        if itemId and itemId > 0 then
            if not cat.items[itemId] then cat.items[itemId] = { name = itemName, sold = 0, gold = 0 } end
            cat.items[itemId].sold = cat.items[itemId].sold + quantity
            cat.items[itemId].gold = cat.items[itemId].gold + price
        end
    end
end

local function BuildTopLists(periodData)
    -- Count and build lists in single pass - keep top 20
    local topSellers, topBuyers, topItems, quickSellers, topCategories = {}, {}, {}, {}, {}
    local us, ui, ub, uc = 0, 0, 0, 0
    
    for name, data in pairs(periodData.sellers) do
        us = us + 1
        if #topSellers < 20 then
            table.insert(topSellers, { name = name, gold = data.totalGold, sales = data.totalSales })
        elseif data.totalGold > topSellers[20].gold then
            topSellers[20] = { name = name, gold = data.totalGold, sales = data.totalSales }
            table.sort(topSellers, function(a, b) return a.gold > b.gold end)
        end
    end
    table.sort(topSellers, function(a, b) return a.gold > b.gold end)
    
    for name, data in pairs(periodData.buyers or {}) do
        ub = ub + 1
        if #topBuyers < 20 then
            table.insert(topBuyers, { name = name, gold = data.totalSpent, purchases = data.totalPurchases })
        elseif data.totalSpent > topBuyers[20].gold then
            topBuyers[20] = { name = name, gold = data.totalSpent, purchases = data.totalPurchases }
            table.sort(topBuyers, function(a, b) return a.gold > b.gold end)
        end
    end
    table.sort(topBuyers, function(a, b) return a.gold > b.gold end)
    
    for id, data in pairs(periodData.items) do
        ui = ui + 1
        -- Top items by gold
        if #topItems < 20 then
            table.insert(topItems, { name = data.name, gold = data.totalGold, sold = data.totalSold })
        elseif data.totalGold > topItems[20].gold then
            topItems[20] = { name = data.name, gold = data.totalGold, sold = data.totalSold }
            table.sort(topItems, function(a, b) return a.gold > b.gold end)
        end
        -- Quick sellers by sale count (velocity)
        if #quickSellers < 20 then
            table.insert(quickSellers, { name = data.name, gold = data.totalGold, sold = data.totalSold })
        elseif data.totalSold > quickSellers[20].sold then
            quickSellers[20] = { name = data.name, gold = data.totalGold, sold = data.totalSold }
            table.sort(quickSellers, function(a, b) return a.sold > b.sold end)
        end
    end
    table.sort(topItems, function(a, b) return a.gold > b.gold end)
    table.sort(quickSellers, function(a, b) return a.sold > b.sold end)
    
    -- Build category list
    for catName, catData in pairs(periodData.categories or {}) do
        uc = uc + 1
        table.insert(topCategories, { name = catName, gold = catData.gold, sales = catData.sales })
    end
    table.sort(topCategories, function(a, b) return a.gold > b.gold end)
    
    return topSellers, topBuyers, topItems, us, ui, ub, quickSellers, topCategories, uc
end

-- Comprehensive Guild Health Score (0-100)
local function CalculateGuildHealth(week, prevWeek, month, guildId)
    local score = 0
    local totalMembers = GetNumGuildMembers(guildId) or 1
    
    -- VOLUME & GROWTH (25 points max)
    -- Sales trend vs last week (10 pts)
    if prevWeek and prevWeek.totalSales and prevWeek.totalSales > 0 then
        local salesChange = ((week.totalSales or 0) - prevWeek.totalSales) / prevWeek.totalSales
        if salesChange >= 0.10 then score = score + 10
        elseif salesChange >= 0 then score = score + 7
        elseif salesChange >= -0.10 then score = score + 4
        end
    else
        score = score + 5 -- No prior data, neutral
    end
    -- Gold volume trend (10 pts)
    if prevWeek and prevWeek.totalGold and prevWeek.totalGold > 0 then
        local goldChange = ((week.totalGold or 0) - prevWeek.totalGold) / prevWeek.totalGold
        if goldChange >= 0.10 then score = score + 10
        elseif goldChange >= 0 then score = score + 7
        elseif goldChange >= -0.10 then score = score + 4
        end
    else
        score = score + 5
    end
    -- Consistency (5 pts) - month activity exists
    if month and month.totalSales and month.totalSales > 0 then
        score = score + 5
    end
    
    -- PARTICIPATION (25 points max)
    -- Seller % of members (10 pts)
    local sellerPct = totalMembers > 0 and ((week.uniqueSellers or 0) / totalMembers) or 0
    if sellerPct >= 0.20 then score = score + 10
    elseif sellerPct >= 0.10 then score = score + 7
    elseif sellerPct >= 0.05 then score = score + 4
    elseif sellerPct > 0 then score = score + 2
    end
    -- Seller diversity - top 3 sellers not too dominant (8 pts)
    local top3Gold = 0
    if week.topSellers then
        for i = 1, math.min(3, #week.topSellers) do
            top3Gold = top3Gold + (week.topSellers[i].gold or 0)
        end
    end
    local top3Share = (week.totalGold or 0) > 0 and (top3Gold / week.totalGold) or 1
    if top3Share <= 0.50 then score = score + 8
    elseif top3Share <= 0.70 then score = score + 5
    elseif top3Share <= 0.85 then score = score + 2
    end
    -- New sellers this week vs last (7 pts)
    local sellerGrowth = (prevWeek and prevWeek.uniqueSellers and prevWeek.uniqueSellers > 0) 
        and ((week.uniqueSellers or 0) - prevWeek.uniqueSellers) / prevWeek.uniqueSellers or 0
    if sellerGrowth > 0 then score = score + 7
    elseif sellerGrowth == 0 then score = score + 4
    else score = score + 2 end
    
    -- MARKET HEALTH (25 points max)
    -- Buyer diversity (8 pts)
    local buyerPct = (week.totalSales or 0) > 0 and ((week.uniqueBuyers or 0) / week.totalSales) or 0
    if buyerPct >= 0.30 then score = score + 8
    elseif buyerPct >= 0.15 then score = score + 5
    elseif buyerPct > 0 then score = score + 2
    end
    -- Average sale price (7 pts) - higher avg = premium trader
    local avgSale = (week.totalSales or 0) > 0 and ((week.totalGold or 0) / week.totalSales) or 0
    if avgSale >= 50000 then score = score + 7
    elseif avgSale >= 20000 then score = score + 5
    elseif avgSale >= 5000 then score = score + 3
    elseif avgSale > 0 then score = score + 1
    end
    -- Item variety (5 pts)
    local itemVariety = week.uniqueItems or 0
    if itemVariety >= 100 then score = score + 5
    elseif itemVariety >= 50 then score = score + 3
    elseif itemVariety > 0 then score = score + 1
    end
    -- Big ticket sales (5 pts)
    local bigTickets = week.bigTicketCount or 0
    if bigTickets >= 10 then score = score + 5
    elseif bigTickets >= 5 then score = score + 3
    elseif bigTickets > 0 then score = score + 1
    end
    
    -- FINANCIAL HEALTH (25 points max)
    -- Tax revenue trend (8 pts)
    if prevWeek and prevWeek.totalTax and prevWeek.totalTax > 0 then
        local taxChange = ((week.totalTax or 0) - prevWeek.totalTax) / prevWeek.totalTax
        if taxChange >= 0 then score = score + 8
        elseif taxChange >= -0.20 then score = score + 4
        end
    else
        score = score + 4
    end
    -- Bank flow (7 pts)
    local netBank = (week.deposits or 0) - (week.withdrawals or 0)
    if netBank > 0 then score = score + 7
    elseif netBank == 0 then score = score + 4
    else score = score + 2 end
    -- Trader cost coverage (5 pts)
    local traderCost = week.netTraderCost or 0
    local taxRevenue = week.totalTax or 0
    if traderCost == 0 or taxRevenue >= traderCost then score = score + 5
    elseif taxRevenue >= traderCost * 0.5 then score = score + 3
    else score = score + 1 end
    -- Depositor count (5 pts)
    local depositors = week.depositorCount or 0
    if depositors >= 10 then score = score + 5
    elseif depositors >= 5 then score = score + 3
    elseif depositors > 0 then score = score + 1
    end
    
    return math.min(100, math.max(0, score))
end

local function GetHealthLabel(score)
    if score >= 80 then return "Thriving", "00FF00"
    elseif score >= 60 then return "Healthy", "88FF88"
    elseif score >= 40 then return "Stable", "FFFF00"
    elseif score >= 20 then return "Building", "FFAA00"
    else return "New/Quiet", "888888" end
end

local function CreateGuildSnapshot(guildId)
    local sv = NWT.savedVars
    local guildName = sv.gstGuildNames[guildId] or ("Guild " .. guildId)
    if not sv.gstGuildSnapshots then sv.gstGuildSnapshots = {} end
    
    local periodSnapshots = {}
    for _, period in ipairs(TIME_PERIODS) do
        local pd = gstScanData[period.key]
        local ts, tb, ti, us, ui, ub, qs, tc, uc = BuildTopLists(pd)
        -- Find my top selling items (top 20)
        local myTopItem, myTopItemGold = "", 0
        local myTopItems = {}
        for itemId, item in pairs(pd.myItems or {}) do
            if item.gold > myTopItemGold then myTopItemGold = item.gold myTopItem = item.name end
            table.insert(myTopItems, { name = item.name, gold = item.gold, sold = item.sold })
        end
        table.sort(myTopItems, function(a, b) return a.gold > b.gold end)
        while #myTopItems > 20 do table.remove(myTopItems) end
        
        periodSnapshots[period.key] = {
            totalSales = pd.totalSales, totalGold = pd.totalGold, totalTax = pd.totalTax,
            uniqueSellers = us, uniqueItems = ui, uniqueBuyers = ub, uniqueCategories = uc,
            topSellers = ts, topBuyers = tb, topItems = ti,
            quickSellers = qs, topCategories = tc,
            mySales = pd.mySales, myGold = pd.myGold, myTax = pd.myTax,
            myBestSale = pd.myBestSale, myBestItem = pd.myBestItem,
            myTopItem = myTopItem, myTopItemGold = myTopItemGold, myTopItems = myTopItems,
            deposits = pd.deposits, withdrawals = pd.withdrawals, 
            netTraderCost = (pd.kioskBids or 0) - (pd.kioskRefunds or 0),
            bigTicketCount = pd.bigTicketCount or 0, bigTicketGold = pd.bigTicketGold or 0,
            depositorCount = pd.depositorCount or 0,
        }
    end
    
    -- Calculate health score using week data
    local weekSnap = periodSnapshots.week or {}
    local prevWeekSnap = periodSnapshots.prevWeek or {}
    local monthSnap = periodSnapshots.month or {}
    local healthScore = CalculateGuildHealth(weekSnap, prevWeekSnap, monthSnap, guildId)
    local healthLabel, healthColor = GetHealthLabel(healthScore)
    
    -- Get kiosk name directly from API (more reliable than parsing bank events)
    local kioskName = GetGuildOwnedKioskInfo(guildId) or gstLastKioskName or ""
    
    sv.gstGuildSnapshots[guildId] = {
        guildName = guildName, scanTime = GetTimeStamp(),
        oldestSale = gstScanData.oldestSale, newestSale = gstScanData.newestSale,
        eventCount = gstScanEventCount, kioskName = kioskName,
        healthScore = healthScore, healthLabel = healthLabel, healthColor = healthColor,
        month = periodSnapshots.month, prevWeek = periodSnapshots.prevWeek, week = periodSnapshots.week, day = periodSnapshots.day,
    }
    
NWT.Debug("|c00FF00[GST]|r Snapshot saved for " .. guildName .. " (Health: " .. healthScore .. " - " .. healthLabel .. ")")
end

local function GST_SendNextRequest()
    if #gstRequestQueue == 0 or gstActiveRequest then return end
    
    local cooldownMs = GetGuildHistoryRequestMinCooldownMs() or 2000
    local now = GetGameTimeMilliseconds()
    if (now - gstLastRequestTime) < cooldownMs then
        zo_callLater(GST_SendNextRequest, cooldownMs - (now - gstLastRequestTime) + 100)
        return
    end
    
    gstActiveRequest = table.remove(gstRequestQueue, 1)
    if not gstActiveRequest or not gstActiveRequest.request:IsValid() then
        gstActiveRequest = nil
        GST_SendNextRequest()
        return
    end
    
    local state = gstActiveRequest.request:RequestMoreEvents(false)
    gstLastRequestTime = GetGameTimeMilliseconds()
    
    if state == GUILD_HISTORY_DATA_READY_STATE_READY then
        gstActiveRequest.complete = true
        gstActiveRequest = nil
        GST_SendNextRequest()
    elseif state == GUILD_HISTORY_DATA_READY_STATE_ON_COOLDOWN then
        table.insert(gstRequestQueue, 1, gstActiveRequest)
        gstActiveRequest = nil
        zo_callLater(GST_SendNextRequest, cooldownMs + 100)
    end
end

function NWT.ScanGuild(guildId)
    if gstScanGuildId then
        NWT.Debug("|cFFFF00[GST]|r Already scanning. Please wait.")
        return
    end
    
    local sv = NWT.savedVars
    local guildName = sv.gstGuildNames[guildId] or GetGuildName(guildId) or ("Guild " .. guildId)
    sv.gstGuildNames[guildId] = guildName
    
    ClearScanData()
    gstScanGuildId = guildId
    gstCurrentScanGuildId = guildId
    gstScanComplete = false
    gstBankEventCount = 0
    gstRequestQueue = {}
    gstActiveRequest = nil
    
    NWT.Debug("|cFFFF00[GST]|r Scanning " .. guildName .. "...")
    
    local now = GetTimeStamp()
    local traderRequest = ZO_GuildHistoryRequest:New(guildId, GUILD_HISTORY_EVENT_CATEGORY_TRADER, now, 0)
    local bankRequest = ZO_GuildHistoryRequest:New(guildId, GUILD_HISTORY_EVENT_CATEGORY_BANKED_CURRENCY, now, 0)
    
    local traderData = { request = traderRequest, complete = false, category = GUILD_HISTORY_EVENT_CATEGORY_TRADER }
    local bankData = { request = bankRequest, complete = false, category = GUILD_HISTORY_EVENT_CATEGORY_BANKED_CURRENCY }
    
    table.insert(gstRequestQueue, traderData)
    table.insert(gstRequestQueue, bankData)
    
    local lastTraderCount = GetNumGuildHistoryEvents(guildId, GUILD_HISTORY_EVENT_CATEGORY_TRADER)
    local lastBankCount = GetNumGuildHistoryEvents(guildId, GUILD_HISTORY_EVENT_CATEGORY_BANKED_CURRENCY)
    local stableCount, requestAttempts = 0, 0
    
    -- Register callback only once globally
    if not gstCategoryCallbackRegistered then
        gstCategoryCallbackRegistered = true
        GUILD_HISTORY_MANAGER:RegisterCallback("CategoryUpdated", function(categoryData)
            if not gstCurrentScanGuildId then return end
            if categoryData:GetGuildData():GetId() ~= gstCurrentScanGuildId then return end
            stableCount = 0
            if gstActiveRequest then
                if not gstActiveRequest.request:IsComplete() then table.insert(gstRequestQueue, gstActiveRequest)
                else gstActiveRequest.complete = true end
                gstActiveRequest = nil
            end
            zo_callLater(GST_SendNextRequest, 100)
        end)
    end
    
    GST_SendNextRequest()
    
    EVENT_MANAGER:RegisterForUpdate("ATK_WaitForHistory_" .. guildId, 2500, function()
        requestAttempts = requestAttempts + 1
        local numT = GetNumGuildHistoryEvents(guildId, GUILD_HISTORY_EVENT_CATEGORY_TRADER)
        local numB = GetNumGuildHistoryEvents(guildId, GUILD_HISTORY_EVENT_CATEGORY_BANKED_CURRENCY)
        
        if numT ~= lastTraderCount or numB ~= lastBankCount then
            stableCount = 0
            lastTraderCount, lastBankCount = numT, numB
        else
            stableCount = stableCount + 1
        end
        
        if not gstActiveRequest and #gstRequestQueue > 0 then GST_SendNextRequest() end
        
        local isDone = (traderData.complete and bankData.complete) or (numT > 0 and stableCount >= 10) or (requestAttempts >= 120)
        if isDone then
            EVENT_MANAGER:UnregisterForUpdate("ATK_WaitForHistory_" .. guildId)
            pcall(function() DestroyGuildHistoryRequest(traderRequest:GetRequestId()) end)
            pcall(function() DestroyGuildHistoryRequest(bankRequest:GetRequestId()) end)
            
            local processIndex = 1
            EVENT_MANAGER:RegisterForUpdate("ATK_DirectScan_" .. guildId, 1, function()
                local processed = 0
                while processIndex <= numT and processed < 100 do
                    local _, ts, redacted, _, seller, buyer, link, qty, price, tax = GetGuildHistoryTraderEventInfo(guildId, processIndex)
                    if not redacted and seller and price then
                        local age = GetTimeStamp() - (ts or GetTimeStamp())
                        local itemId = link and GetItemLinkItemId(link) or 0
                        local itemName = link and GetItemLinkName(link) or "Unknown"
                        local itemType = link and GetItemLinkItemType(link) or nil
                        for _, p in ipairs(TIME_PERIODS) do
                            local minAge = p.minAge or 0
                            if age <= p.seconds and age >= minAge then AddSaleToPeriod(gstScanData[p.key], seller, buyer, itemId, itemName, qty or 1, price, tax or 0, GetDisplayName(), itemType) end
                        end
                        gstScanEventCount = gstScanEventCount + 1
                    end
                    processIndex, processed = processIndex + 1, processed + 1
                end
                
                if processIndex > numT then
                    local bankIdx = processIndex - numT
                    while bankIdx <= numB and processed < 100 do
                        local _, ts, redacted, type, depositor, _, amt, kiosk = GetGuildHistoryBankedCurrencyEventInfo(guildId, bankIdx)
                        if not redacted and amt and amt > 0 then
                            local age = GetTimeStamp() - (ts or GetTimeStamp())
                            if kiosk and kiosk ~= "" then gstLastKioskName = kiosk end
                            for _, p in ipairs(TIME_PERIODS) do
                                local minAge = p.minAge or 0
                                if age <= p.seconds and age >= minAge then
                                    local pd = gstScanData[p.key]
                                    if type == GUILD_HISTORY_BANKED_CURRENCY_EVENT_DEPOSITED then 
                                        pd.deposits = (pd.deposits or 0) + amt
                                        -- Track unique depositors
                                        if depositor and depositor ~= "" then
                                            if not pd.depositors then pd.depositors = {} end
                                            if not pd.depositors[depositor] then
                                                pd.depositors[depositor] = 0
                                                pd.depositorCount = (pd.depositorCount or 0) + 1
                                            end
                                            pd.depositors[depositor] = pd.depositors[depositor] + amt
                                        end
                                    elseif type == GUILD_HISTORY_BANKED_CURRENCY_EVENT_WITHDRAWN then pd.withdrawals = (pd.withdrawals or 0) + amt
                                    elseif type == GUILD_HISTORY_BANKED_CURRENCY_EVENT_KIOSK_BID then pd.kioskBids = (pd.kioskBids or 0) + amt
                                    end
                                end
                            end
                            gstBankEventCount = gstBankEventCount + 1
                        end
                        bankIdx, processIndex, processed = bankIdx + 1, processIndex + 1, processed + 1
                    end
                end
                
                if processIndex > numT + numB then
                    EVENT_MANAGER:UnregisterForUpdate("ATK_DirectScan_" .. guildId)
                    CreateGuildSnapshot(guildId)
                    ClearScanData()
                    gstScanGuildId = nil
                    gstCurrentScanGuildId = nil
                    if NWT.UpdateGuildSalesUI then NWT.UpdateGuildSalesUI() end
                    if NWT.ShowReloadUIDialog then NWT.ShowReloadUIDialog(gstScanEventCount) end
                end
            end)
        end
    end)
end

function NWT.ClearGuildSalesData()
    local sv = NWT.savedVars
    sv.gstGuildSnapshots = {}
    sv.gstGuildNames = {}
    sv.gstGuildEnabled = {}
    sv.gstMySales, sv.gstMyGold, sv.gstMyTax = 0, 0, 0
    sv.gstOldestSale, sv.gstNewestSale, sv.gstTotalEvents = 0, 0, 0
NWT.Debug("|cFF0000[GST]|r All sales data cleared!")
end

-- ============================================
-- CHAT REPORT FUNCTIONS
-- ============================================

function NWT.ShowGuildSummary()
NWT.Debug("|c00FF00========== GUILD TRADER REPORT ==========|r")
    local format = NWT.FormatGold
    local oldest = NWT.FormatTimestamp(NWT.savedVars.gstOldestSale)
    local newest = NWT.FormatTimestamp(NWT.savedVars.gstNewestSale)
NWT.Debug("|cAAAAAAData Range: " .. oldest .. " to " .. newest .. " (" .. (NWT.savedVars.gstTotalEvents or 0) .. " total sales)|r")
    
    for guildId, guildSellers in pairs(NWT.sessionData.gstGuildSellers or {}) do
        local guildName = NWT.savedVars.gstGuildNames[guildId] or ("Guild " .. guildId)
        local guildStats = NWT.savedVars.gstGuildStats and NWT.savedVars.gstGuildStats[guildId]
        
        local totalSales, totalGold, totalTax = 0, 0, 0
        if guildStats then
            totalSales, totalGold, totalTax = guildStats.totalSales or 0, guildStats.totalGold or 0, guildStats.totalTax or 0
        else
            for _, data in pairs(guildSellers) do
                totalSales, totalGold, totalTax = totalSales + data.totalSales, totalGold + data.totalGold, totalTax + data.totalTax
            end
        end
        
        local days = 1
        if guildStats and guildStats.oldestSale and guildStats.newestSale and guildStats.newestSale > guildStats.oldestSale then
            days = math.max(1, math_floor((guildStats.newestSale - guildStats.oldestSale) / 86400))
        end
        
        local finance = NWT.savedVars.gstGuildFinances and NWT.savedVars.gstGuildFinances[guildId]
        local kiosk = finance and finance.kioskName or ""
        local netTrader = (finance and finance.totalBids or 0) - (finance and finance.totalRefunds or 0)
        local deposits = NWT.savedVars.gstGuildDeposits and NWT.savedVars.gstGuildDeposits[guildId] and NWT.savedVars.gstGuildDeposits[guildId].totalDeposits or 0
        local withdrawals = finance and finance.totalWithdrawals or 0
        local netProfit = totalTax + deposits - netTrader - withdrawals
        
        local colors = NWT.GetColors()
        local profitColor = netProfit >= 0 and ("|c" .. colors.positive) or ("|c" .. colors.negative)
        
NWT.Debug("|c00BFFF=============== " .. guildName .. " ===============|r")
        if kiosk ~= "" then NWT.Debug("|cFFAA00Trader:|r " .. kiosk) end
NWT.Debug("|cFFFFAASales:|r " .. totalSales .. " (" .. math_floor(totalSales/days) .. "/day)")
NWT.Debug("|cFFFFAAVolume:|r " .. format(totalGold) .. "g (" .. format(totalGold/days) .. "g/day)")
        NWT.Debug(profitColor .. "Net Flow:|r " .. (netProfit >= 0 and "+" or "") .. format(netProfit) .. "g")
    end
NWT.Debug("|c00FF00==========================================|r")
end

function NWT.ShowWeeklyComparison()
NWT.Debug("|c00FF00========== WEEK OVER WEEK ==========|r")
    local format = NWT.FormatGold
    for guildId, weeklyStats in pairs(NWT.savedVars.gstWeeklyStats or {}) do
        local guildName = NWT.savedVars.gstGuildNames[guildId] or ("Guild " .. guildId)
        local thisW, lastW = weeklyStats.thisWeek or { sales = 0, gold = 0 }, weeklyStats.lastWeek or { sales = 0, gold = 0 }
        local salesChange = lastW.sales > 0 and ((thisW.sales - lastW.sales) / lastW.sales) * 100 or 0
        local goldChange = lastW.gold > 0 and ((thisW.gold - lastW.gold) / lastW.gold) * 100 or 0
        local colors = NWT.GetColors()
        local sCol = salesChange >= 0 and ("|c" .. colors.positive) or ("|c" .. colors.negative)
        local gCol = goldChange >= 0 and ("|c" .. colors.positive) or ("|c" .. colors.negative)
NWT.Debug("|c00BFFF--- " .. guildName .. " ---|r")
NWT.Debug("|cFFFFAAThis Week:|r " .. thisW.sales .. " sales, " .. format(thisW.gold) .. "g")
NWT.Debug("|cFFFFAALast Week:|r " .. lastW.sales .. " sales, " .. format(lastW.gold) .. "g")
        if lastW.sales > 0 then
            NWT.Debug(sCol .. "Sales: " .. (salesChange >= 0 and "â†‘" or "â†“") .. " " .. string_format("%.1f%%", math.abs(salesChange)) .. "|r")
            NWT.Debug(gCol .. "Volume: " .. (goldChange >= 0 and "â†‘" or "â†“") .. " " .. string_format("%.1f%%", math.abs(goldChange)) .. "|r")
        end
    end
NWT.Debug("|c00FF00======================================|r")
end

function NWT.ShowCategories()
NWT.Debug("|c00FF00========== ITEM CATEGORIES ==========|r")
    local format = NWT.FormatGold
    for guildId, categories in pairs(NWT.savedVars.gstItemCategories or {}) do
        local guildName = NWT.savedVars.gstGuildNames[guildId] or ("Guild " .. guildId)
        local sorted = {}
        for name, data in pairs(categories) do table.insert(sorted, { name = name, gold = data.gold, sales = data.sales }) end
        table.sort(sorted, function(a, b) return a.gold > b.gold end)
        local total = 0 for _, cat in ipairs(sorted) do total = total + cat.gold end
NWT.Debug("|c00BFFF--- " .. guildName .. " ---|r")
        for i = 1, math.min(10, #sorted) do
            local cat = sorted[i]
            local pct = total > 0 and string_format("%.1f%%", (cat.gold/total)*100) or "0%"
NWT.Debug("|cFFFFAA" .. cat.name .. ":|r " .. format(cat.gold) .. "g (" .. pct .. ") - " .. cat.sales .. " sales")
        end
    end
NWT.Debug("|c00FF00======================================|r")
end

function NWT.ShowInactive()
NWT.Debug("|c00FF00========== INACTIVE MEMBERS ==========|r")
    for guildId, guildSellers in pairs(NWT.sessionData.gstGuildSellers or {}) do
        local guildName = NWT.savedVars.gstGuildNames[guildId] or ("Guild " .. guildId)
        local total = GetNumGuildMembers(guildId)
        local members = {}
        for i = 1, total do local name = GetGuildMemberInfo(guildId, i) if name then members[name:gsub("^@", "")] = true end end
        local active = 0
        for name, _ in pairs(guildSellers) do if members[name] then active = active + 1 end end
NWT.Debug("|c00BFFF--- " .. guildName .. " ---|r")
NWT.Debug("|c88FF88Active Sellers:|r " .. active .. " of " .. total .. " members (" .. string_format("%.1f%%", (active/total)*100) .. ")")
NWT.Debug("|cFF8888Not Selling:|r " .. (total - active) .. " members")
    end
NWT.Debug("|c00FF00======================================|r")
end

function NWT.ShowNewSellers()
NWT.Debug("|c00FF00========== NEW SELLERS ==========|r")
    local cutoff = GetTimeStamp() - (7 * 86400)
    local format = NWT.FormatGold
    for guildId, guildSellers in pairs(NWT.sessionData.gstGuildSellers or {}) do
        local guildName = NWT.savedVars.gstGuildNames[guildId] or ("Guild " .. guildId)
        local new = {}
        for name, data in pairs(guildSellers) do if data.firstSale and data.firstSale >= cutoff then table.insert(new, { name = name, gold = data.totalGold, sales = data.totalSales }) end end
        table.sort(new, function(a, b) return a.gold > b.gold end)
NWT.Debug("|c00BFFF--- " .. guildName .. " ---|r")
        if #new > 0 then
            for i = 1, math.min(10, #new) do NWT.Debug("  " .. new[i].name .. " - " .. format(new[i].gold) .. "g (" .. new[i].sales .. " sales)") end
        else NWT.Debug("  No new sellers this week") end
    end
NWT.Debug("|c00FF00======================================|r")
end

function NWT.ShowPriceAlerts()
NWT.Debug("|c00FF00========== PRICE ALERTS ==========|r")
    local format = NWT.FormatGold
    for guildId, alerts in pairs(NWT.savedVars.gstPriceAlerts or {}) do
        local guildName = NWT.savedVars.gstGuildNames[guildId] or ("Guild " .. guildId)
        local filtered = {}
        for _, a in ipairs(alerts) do if not a.itemName:lower():find("writ") then table.insert(filtered, a) end end
        if #filtered > 0 then
NWT.Debug("|c00BFFF--- " .. guildName .. " ---|r")
            for i = 1, math.min(10, #filtered) do
                local a = filtered[i]
NWT.Debug("|cFF8888" .. a.itemName .. "|r - " .. format(a.price) .. "g (max: " .. format(a.maxPrice) .. "g)")
NWT.Debug("  Seller: " .. a.seller)
            end
        end
    end
NWT.Debug("|c00FF00======================================|r")
end

function NWT.ShowConsistentSellers()
NWT.Debug("|c00FF00========== SELLER CONSISTENCY ==========|r")
    local format = NWT.FormatGold
    local now = GetTimeStamp()
    for guildId, guildSellers in pairs(NWT.sessionData.gstGuildSellers or {}) do
        local guildName = NWT.savedVars.gstGuildNames[guildId] or ("Guild " .. guildId)
        local consistent = {}
        for sellerName, data in pairs(guildSellers) do
            local days = math.max(1, math_floor(((data.lastSale or 0) - (data.firstSale or 0)) / 86400))
            if (data.totalSales / days) >= 1 and days >= 7 and (now - (data.lastSale or 0)) < (7 * 86400) then
                table.insert(consistent, { name = sellerName, gold = data.totalGold, spd = data.totalSales / days })
            end
        end
        table.sort(consistent, function(a, b) return a.gold > b.gold end)
NWT.Debug("|c00BFFF--- " .. guildName .. " ---|r")
        if #consistent > 0 then
            for i = 1, math.min(5, #consistent) do NWT.Debug("  " .. consistent[i].name .. " - " .. format(consistent[i].gold) .. "g (" .. string_format("%.1f", consistent[i].spd) .. " sales/day)") end
        else NWT.Debug("  None found") end
    end
NWT.Debug("|c00FF00======================================|r")
end

local gstDisplayQueue = {}
local gstDisplayIndex = 1
local function ProcessStatsDisplay()
    if gstDisplayIndex > #gstDisplayQueue then return end
    for _ = 1, 3 do
        if gstDisplayIndex <= #gstDisplayQueue then NWT.Debug(gstDisplayQueue[gstDisplayIndex]) gstDisplayIndex = gstDisplayIndex + 1 end
    end
    if gstDisplayIndex <= #gstDisplayQueue then zo_callLater(ProcessStatsDisplay, 10) end
end

function NWT.ShowGuildSalesStats()
    gstDisplayQueue, gstDisplayIndex = {}, 1
    table.insert(gstDisplayQueue, "|c00FF00========== GUILD SALES TRACKER ==========|r")
    local format = NWT.FormatGold
    local oldest = NWT.FormatTimestamp(NWT.savedVars.gstOldestSale)
    local newest = NWT.FormatTimestamp(NWT.savedVars.gstNewestSale)
    table.insert(gstDisplayQueue, "|cAAAAAAData: " .. oldest .. " to " .. newest .. " (" .. (NWT.savedVars.gstTotalEvents or 0) .. " sales)|r")
    table.insert(gstDisplayQueue, "|cFFFF00MY SALES:|r " .. (NWT.savedVars.gstMySales or 0) .. " sales | " .. format(NWT.savedVars.gstMyGold or 0) .. "g earned")
    
    local topItems = {}
    for _, data in pairs(NWT.sessionData.gstSales or {}) do
        table.insert(topItems, { name = data.name, sold = data.totalSold, gold = data.totalGold })
    end
    table.sort(topItems, function(a, b) return a.gold > b.gold end)
    table.insert(gstDisplayQueue, "|cFFFF00TOP ITEMS (all guilds):|r")
    for i = 1, math.min(5, #topItems) do
        local it = topItems[i]
        table.insert(gstDisplayQueue, "  " .. i .. ". " .. it.name .. " x" .. it.sold .. " = " .. format(it.gold) .. "g")
    end
    table.insert(gstDisplayQueue, "|c00FF00==========================================|r")
    zo_callLater(ProcessStatsDisplay, 10)
end

function NWT.ShowTopItems()
    local topItems = {}
    for _, data in pairs(NWT.sessionData.gstSales or {}) do table.insert(topItems, data) end
    table.sort(topItems, function(a, b) return (a.totalGold or 0) > (b.totalGold or 0) end)
NWT.Debug("|c00FF00========== TOP ITEMS ==========|r")
    for i = 1, math.min(10, #topItems) do NWT.Debug(i .. ". " .. topItems[i].name .. " x" .. topItems[i].totalSold .. " = " .. NWT.FormatGold(topItems[i].totalGold) .. "g") end
NWT.Debug("|c00FF00==================================|r")
end

function NWT.GSTCommand(args)
    local cmd = string.lower(args or "")
    
    -- Check for "scan X" where X is a guild number
    local scanNum = string.match(cmd, "^scan%s+(%d+)$")
    if scanNum then
        NWT.ScanGuild(GetGuildId(tonumber(scanNum)))
        return
    end
    
    if cmd == "scan" then
        NWT.ListGuildsForScan()
    elseif cmd == "load" then
        NWT.LoadMoreHistory()
    elseif cmd == "clear" then
        NWT.ClearGuildSalesData()
    elseif cmd == "summary" or cmd == "" then
        NWT.ShowGuildSummary()
    elseif cmd == "items" then
        NWT.ShowTopItems()
    elseif cmd == "all" then
        NWT.ShowGuildSalesStats()
    elseif cmd == "weekly" or cmd == "week" then
        NWT.ShowWeeklyComparison()
    elseif cmd == "categories" or cmd == "cats" then
        NWT.ShowCategories()
    elseif cmd == "inactive" then
        NWT.ShowInactive()
    elseif cmd == "new" then
        NWT.ShowNewSellers()
    elseif cmd == "alerts" or cmd == "prices" then
        NWT.ShowPriceAlerts()
    elseif cmd == "consistent" or cmd == "reliable" then
        NWT.ShowConsistentSellers()
    elseif cmd == "help" then
NWT.Debug("|cFFFF00[GST]|r === Guild Sales Tracker Commands ===")
NWT.Debug("|cFFFFAA/gst|r - Summary with profit/loss")
NWT.Debug("|cFFFFAA/gst weekly|r - Week-over-week comparison")
NWT.Debug("|cFFFFAA/gst categories|r - Sales by item type")
NWT.Debug("|cFFFFAA/gst items|r - Top selling items")
NWT.Debug("|cFFFFAA/gst sellers|r - Top sellers by guild")
NWT.Debug("|cFFFFAA/gst consistent|r - Reliable vs one-time sellers")
NWT.Debug("|cFFFFAA/gst new|r - New sellers this week")
NWT.Debug("|cFFFFAA/gst inactive|r - Members not selling")
NWT.Debug("|cFFFFAA/gst alerts|r - Low price warnings")
NWT.Debug("|cFFFFAA/gst scan|r - Scan guild sales")
NWT.Debug("|cFFFFAA/gst load|r - Load more history")
NWT.Debug("|cFFFFAA/gst clear|r - Clear all data")
    else
NWT.Debug("|cFFFF00[GST]|r Type /gst help for all commands")
    end
end

function NWT.ListGuildsForScan()
NWT.Debug("|c00FF00========== YOUR GUILDS ==========|r")
    for i = 1, GetNumGuilds() do
        local gId = GetGuildId(i)
        NWT.Debug(i .. ". " .. (GetGuildName(gId) or ("Guild " .. i)) .. " (" .. GetNumGuildHistoryEvents(gId, GUILD_HISTORY_EVENT_CATEGORY_TRADER) .. " events)")
    end
NWT.Debug("|cAAAAAAUse /gst scan 1 to scan guild 1, etc.|r")
end

-- Show top bank gold contributors across all guilds
function NWT.ShowBankGoldLeaders()
    local members = {}
    
    for i = 1, GetNumGuilds() do
        local guildId = GetGuildId(i)
        local category = GUILD_HISTORY_EVENT_CATEGORY_BANKED_CURRENCY
        local numEvents = GetNumGuildHistoryEvents(guildId, category) or 0
        
        for eventIndex = 1, numEvents do
            local ok, eventId, timestampS, isRedacted, eventType, displayName, currencyType, amount = pcall(function()
                return GetGuildHistoryBankedCurrencyEventInfo(guildId, eventIndex)
            end)
            
            if ok and displayName and (currencyType == CURT_MONEY or not currencyType) then
                if not members[displayName] then
                    members[displayName] = { deposits = 0, withdrawals = 0 }
                end
                
                if eventType == GUILD_HISTORY_BANKED_CURRENCY_EVENT_DEPOSITED then
                    members[displayName].deposits = members[displayName].deposits + (amount or 0)
                elseif eventType == GUILD_HISTORY_BANKED_CURRENCY_EVENT_WITHDRAWN then
                    members[displayName].withdrawals = members[displayName].withdrawals + (amount or 0)
                end
            end
        end
    end
    
    -- Sort by net contribution
    local sorted = {}
    for name, data in pairs(members) do
        table.insert(sorted, { name = name, deposits = data.deposits, withdrawals = data.withdrawals, net = data.deposits - data.withdrawals })
    end
    table.sort(sorted, function(a, b) return a.net > b.net end)
    
NWT.Debug("|c00FF00========== TOP BANK GOLD CONTRIBUTORS ==========|r")
    for i = 1, math.min(15, #sorted) do
        local m = sorted[i]
        local netColor = m.net >= 0 and "00FF00" or "FF6666"
        NWT.Debug(string.format("%d. |cFFFFFF%s|r - |c%sNet: %s%sg|r (D: +%sg, W: -%sg)", 
            i, m.name, netColor, m.net >= 0 and "+" or "", NWT.FormatGold(m.net),
            NWT.FormatGold(m.deposits), NWT.FormatGold(m.withdrawals)))
    end
    
    if #sorted > 15 then
NWT.Debug("|cAAAAAAShowing top 15 of " .. #sorted .. " members|r")
    end
NWT.Debug("|c00FF00================================================|r")
end

function NWT.LoadMoreHistory()
    if gstLoadingGuilds then NWT.Debug("|cFFFF00[GST]|r Already loading history...") return end
    gstLoadingGuilds = true
    local num = GetNumGuilds()
    NWT.Debug("|c00FF00[GST]|r Requesting 30 days of history from " .. num .. " guild(s)...")
    local now = GetTimeStamp()
    local requests = {}
    for i = 1, num do
        local gId = GetGuildId(i)
        local rId = CreateGuildHistoryRequest(gId, GUILD_HISTORY_EVENT_CATEGORY_TRADER, now, now - (30 * 86400))
        if rId then 
            table.insert(requests, rId)
            RequestMoreGuildHistoryEvents(rId, true, nil, nil) 
        end
    end
    -- Clean up requests after a delay
    zo_callLater(function()
        for _, rId in ipairs(requests) do
            pcall(function() DestroyGuildHistoryRequest(rId) end)
        end
        gstLoadingGuilds = false
        NWT.Debug("|c00FF00[GST]|r History requests completed and cleaned up!")
    end, 5000)
end

-- ============================================
-- GUILD SALES DASHBOARD UI
-- ============================================

NWT.GuildSalesDashboard = { 
    isOpen = false, 
    sceneInitialized = false,
    viewMode = 1,
    viewModes = {"Overview", "Top Sellers", "Top Items", "Quick Sellers", "Categories", "Week Compare", "My Activity", "Buyers"},
    timeFilter = 1,
    timeFilters = {"30 Days", "7 Days", "24 Hours"},
    timeFilterKeys = {"month", "week", "day"},
    selectedGuildIndex = 1,
}

local ATK_HiddenGuildSalesListScreen = ZO_Gamepad_ParametricList_Screen:Subclass()
function ATK_HiddenGuildSalesListScreen:New(control) return ZO_Gamepad_ParametricList_Screen.New(self, control) end
function ATK_HiddenGuildSalesListScreen:Initialize(control) ZO_Gamepad_ParametricList_Screen.Initialize(self, control, false, true, GUILD_SALES_DASHBOARD_SCENE) end
function ATK_HiddenGuildSalesListScreen:PerformUpdate() end

function ATK_HiddenGuildSalesListScreen:InitializeKeybindStripDescriptors()
    self.keybindStripDescriptor = {
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "Scan Guild", keybind = "UI_SHORTCUT_PRIMARY", 
          callback = function() NWT.GuildSalesScanSelected() end },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "Refresh", keybind = "UI_SHORTCUT_SECONDARY", 
          callback = function() NWT.UpdateGuildSalesDashboard() PlaySound(SOUNDS.POSITIVE_CLICK) end },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, 
          name = function() return "Filter: " .. (NWT.GuildSalesDashboard.timeFilters[NWT.GuildSalesDashboard.timeFilter] or "30 Days") end, 
          keybind = "UI_SHORTCUT_TERTIARY", 
          callback = function() NWT.GuildSalesCycleTimeFilter() end },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "Prev View", keybind = "UI_SHORTCUT_LEFT_SHOULDER", 
          callback = function() NWT.GuildSalesCycleView("left") end },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "Next View", keybind = "UI_SHORTCUT_RIGHT_SHOULDER", 
          callback = function() NWT.GuildSalesCycleView("right") end },
    }
    ZO_Gamepad_AddBackNavigationKeybindDescriptors(self.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON, 
        function() NWT.CloseGuildSalesDashboard() end)
end

function NWT.SyncHiddenGuildSalesList()
    if not NWT.HiddenGuildSalesList then return end
    local num = GetNumGuilds()
    if num == 0 then return end
    NWT.HiddenGuildSalesList:Clear()
    for i = 1, num do
        local gId = GetGuildId(i)
        local ed = ZO_GamepadEntryData:New(GetGuildName(gId) or ("Guild " .. i))
        ed.index, ed.guildId = i, gId
        NWT.HiddenGuildSalesList:AddEntry("ZO_GamepadItemEntryTemplate", ed)
    end
    NWT.HiddenGuildSalesList:Commit()
    local idx = NWT.GuildSalesDashboard.selectedGuildIndex or 1
    if idx > num then idx = 1 end
    if idx >= 1 then
        pcall(function() NWT.HiddenGuildSalesList:SetSelectedIndexWithoutAnimation(idx) end)
    end
end

function NWT.InitGuildSalesDashboardScene()
    if NWT.GuildSalesDashboard.sceneInitialized then return end
    local ui = ATK_GST_UI
    if not ui then return end
    local hc = WINDOW_MANAGER:CreateControlFromVirtual("ATK_HiddenGuildSalesList", GuiRoot, "ATK_HouseList_Screen")
    hc:SetHidden(true) hc:SetAlpha(0)
    GUILD_SALES_DASHBOARD_SCENE = ZO_Scene:New("guildSalesDashboardScene", SCENE_MANAGER)
    GUILD_SALES_DASHBOARD_SCENE:AddFragment(ZO_SimpleSceneFragment:New(ui))
    GUILD_SALES_DASHBOARD_SCENE:AddFragment(ZO_SimpleSceneFragment:New(hc))
    GUILD_SALES_DASHBOARD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    GUILD_SALES_DASHBOARD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
    NWT.HiddenGuildSalesListScreen = ATK_HiddenGuildSalesListScreen:New(hc)
    NWT.HiddenGuildSalesList = NWT.HiddenGuildSalesListScreen:GetMainList()
    NWT.HiddenGuildSalesList:AddDataTemplate("ZO_GamepadItemEntryTemplate", function(c, d) local l = c:GetNamedChild("Label") if l then l:SetText(d.name or "") end end, ZO_GamepadMenuEntryTemplateParametricListFunction)
    NWT.HiddenGuildSalesList:SetOnSelectedDataChangedCallback(function(list, sd) 
        if sd and sd.index then 
            NWT.GuildSalesDashboard.selectedGuildIndex = sd.index 
            NWT.UpdateGuildSalesDashboard()
        end 
    end)
    GUILD_SALES_DASHBOARD_SCENE:RegisterCallback("StateChange", function(os, ns) if ns == SCENE_SHOWING then NWT.GuildSalesDashboard.isOpen = true NWT.SyncHiddenGuildSalesList() elseif ns == SCENE_HIDDEN then NWT.GuildSalesDashboard.isOpen = false end end)
    NWT.GuildSalesDashboard.sceneInitialized = true
end

function NWT.GuildSalesScanSelected()
    local idx = NWT.GuildSalesDashboard.selectedGuildIndex
    if idx >= 1 and idx <= GetNumGuilds() then NWT.ScanGuild(GetGuildId(idx)) PlaySound(SOUNDS.POSITIVE_CLICK) end
end

-- Get selected guild's snapshot data (must be before UpdateGuildSalesLeftPanel)
local function GetSelectedGuildData()
    local gsd = NWT.GuildSalesDashboard
    local idx = gsd.selectedGuildIndex or 1
    if idx < 1 or idx > GetNumGuilds() then idx = 1 end
    local guildId = GetGuildId(idx)
    local snap = NWT.savedVars.gstGuildSnapshots and NWT.savedVars.gstGuildSnapshots[guildId]
    local name = GetGuildName(guildId) or ("Guild " .. idx)
    return { id = guildId, snap = snap or {}, name = name }
end

function NWT.UpdateGuildSalesLeftPanel()
    local ui = ATK_GST_UI
    if not ui then return end
    local lp = ui:GetNamedChild("LeftPanel")
    if not lp then return end
    local gsd = NWT.GuildSalesDashboard
    local num = GetNumGuilds()
    
    -- Update guild labels
    for i = 1, 5 do
        local lbl = lp:GetNamedChild("Guild" .. i)
        if lbl then
            if i <= num then
                local gId = GetGuildId(i)
                local snap = NWT.savedVars.gstGuildSnapshots and NWT.savedVars.gstGuildSnapshots[gId]
                local age = ""
                if snap and snap.scanTime then
                    local elapsed = GetTimeStamp() - snap.scanTime
                    if elapsed < 3600 then age = "|c00FF00NEW|r"
                    elseif elapsed < 86400 then age = "|cFFFF00" .. math_floor(elapsed/3600) .. "h|r"
                    else age = "|cFF8888" .. math_floor(elapsed/86400) .. "d|r" end
                else age = "|cFF0000--|r" end
                local name = GetGuildName(gId) or ("Guild " .. i)
                local isSelected = i == gsd.selectedGuildIndex
                lbl:SetText(isSelected and string_format("|cFFD700> %s|r %s", name, age) or string_format("  |c888888%s|r %s", name, age))
            else lbl:SetText("") end
        end
    end
    
    -- Update instructions
    local instr = lp:GetNamedChild("Instructions")
    if instr then instr:SetText("|c888888[A] Scan|r") end
    
    -- Update StatsCard with quick stats for selected guild
    local statsCard = lp:GetNamedChild("StatsCard")
    if statsCard then
        local g = GetSelectedGuildData()
        local p = g.snap.month or {}
        local week = g.snap.week or {}
        local totalSales = statsCard:GetNamedChild("TotalSales")
        if totalSales then totalSales:SetText(string_format("|cFFFFAASales:|r %d", p.totalSales or 0)) end
        local totalVolume = statsCard:GetNamedChild("TotalVolume")
        if totalVolume then totalVolume:SetText(string_format("|cFFFFAAVolume:|r |c00FF00%sg|r", NWT.FormatGold(p.totalGold or 0))) end
        local totalTax = statsCard:GetNamedChild("TotalTax")
        if totalTax then totalTax:SetText(string_format("|cFF8888Tax:|r %sg", NWT.FormatGold(p.totalTax or 0))) end
        local totalProfit = statsCard:GetNamedChild("TotalProfit")
        local net = (p.totalTax or 0) + (p.deposits or 0) - (p.netTraderCost or 0) - (p.withdrawals or 0)
        if totalProfit then totalProfit:SetText(string_format("|c00FF00Bank:|r %s%sg|r", net >= 0 and "+" or "", NWT.FormatGold(net))) end
        local weeklySales = statsCard:GetNamedChild("WeeklySales")
        if weeklySales then weeklySales:SetText(string_format("%d sales this week", week.totalSales or 0)) end
        local weeklyProfit = statsCard:GetNamedChild("WeeklyProfit")
        if weeklyProfit then weeklyProfit:SetText(string_format("|c00FF00%sg|r this week", NWT.FormatGold(week.totalGold or 0))) end
    end
end

function NWT.GuildSalesCycleView(dir)
    local gsd = NWT.GuildSalesDashboard
    gsd.viewMode = (dir == "left") and (gsd.viewMode == 1 and #gsd.viewModes or gsd.viewMode - 1) or (gsd.viewMode == #gsd.viewModes and 1 or gsd.viewMode + 1)
    PlaySound(SOUNDS.POSITIVE_CLICK) NWT.UpdateGuildSalesDashboard()
end

function NWT.GuildSalesCycleTimeFilter()
    local gsd = NWT.GuildSalesDashboard
    gsd.timeFilter = (gsd.timeFilter % #gsd.timeFilters) + 1
    PlaySound(SOUNDS.POSITIVE_CLICK)
    if KEYBIND_STRIP and NWT.HiddenGuildSalesListScreen then KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenGuildSalesListScreen.keybindStripDescriptor) end
    NWT.UpdateGuildSalesDashboard()
end

function NWT.UpdateGuildSalesDashboard()
    local ui = ATK_GST_UI
    if not ui then return end
    local gsd = NWT.GuildSalesDashboard
    NWT.UpdateGuildSalesLeftPanel()
    ui:GetNamedChild("Title"):SetText("|cFFD700GUILD SALES - " .. gsd.viewModes[gsd.viewMode]:upper() .. "|r")
    ui:GetNamedChild("DataRange"):SetText("|c888888[X]|r |cFFFFAA" .. (gsd.timeFilters[gsd.timeFilter] or "30 Days") .. "|r")
    local colors = NWT.GetColors()
    for i = 1, 4 do local card = ui:GetNamedChild("Guild" .. i) if card then card:SetHidden(true) end end
    if gsd.viewMode == 1 then NWT.UpdateGuildSalesOverview(ui, colors)
    elseif gsd.viewMode == 2 then NWT.UpdateGuildSalesTopSellers(ui, colors)
    elseif gsd.viewMode == 3 then NWT.UpdateGuildSalesTopItems(ui, colors)
    elseif gsd.viewMode == 4 then NWT.UpdateGuildSalesQuickSellers(ui, colors)
    elseif gsd.viewMode == 5 then NWT.UpdateGuildSalesCategories(ui, colors)
    elseif gsd.viewMode == 6 then NWT.UpdateGuildSalesWeekCompare(ui, colors)
    elseif gsd.viewMode == 7 then NWT.UpdateGuildSalesActivity(ui, colors)
    elseif gsd.viewMode == 8 then NWT.UpdateGuildSalesBuyers(ui, colors)
    end
end

local function ClearGuildCard(card)
    local fields = {"Sales", "Volume", "Members", "Sellers", "Left5", "Left6", "Left7", "Left8", "Left9", "Left10", "Tax", "WeeklyTax", "TraderCost", "Extra", "Right5", "Right6", "Right7", "Right8", "Right9", "Right10", "Profit", "WeeklyProfit", "Velocity"}
    for _, f in ipairs(fields) do local l = card:GetNamedChild(f) if l then l:SetText("") end end
end

local function GetCurrentPeriodKey()
    local gsd = NWT.GuildSalesDashboard
    return gsd.timeFilterKeys[gsd.timeFilter] or "month"
end

local function GetSortedGuilds()
    local sv = NWT.savedVars
    local guilds = {}
    for id, snap in pairs(sv.gstGuildSnapshots or {}) do table.insert(guilds, {id = id, snap = snap, name = snap.guildName or "Guild"}) end
    table.sort(guilds, function(a, b) return a.name:lower() < b.name:lower() end)
    return guilds
end

-- Analytics helper: Get change indicator and color
local function GetTrendIndicator(current, previous)
    if not previous or previous == 0 then return "-", "888888", 0 end
    local change = current - previous
    local pct = (change / previous) * 100
    if pct > 5 then return "+", "00FF00", pct
    elseif pct < -5 then return "-", "FF0000", pct
    else return "=", "FFFF00", pct end
end

-- Analytics helper: Format change with color
local function FormatChange(current, previous, isGold)
    local arrow, color, pct = GetTrendIndicator(current, previous)
    local val = isGold and NWT.FormatGold(current) .. "g" or tostring(current)
    if previous and previous > 0 then
        return string_format("|c%s%s|r %s (|c%s%+.0f%%|r)", "00FF00", val, arrow, color, pct)
    end
    return "|c00FF00" .. val .. "|r"
end


-- Truncate text to max characters
local function TruncateText(text, maxLen)
    if not text then return "" end
    if #text <= maxLen then return text end
    return text:sub(1, maxLen - 2) .. ".."
end

-- Format seller/buyer name for list display (truncate to fit in half-width column)
local function FormatListEntry(rank, name, gold, count, countLabel, pct)
    local truncName = TruncateText(name or "Unknown", 16)
    return string_format("|cFFFFFF%2d.|r %-16s |c00FF00%sg|r", 
        rank, truncName, NWT.FormatGold(gold or 0))
end

-- Update the list section header based on view mode
local function UpdateListHeader(center, headerText)
    local header = center:GetNamedChild("SellersHeader")
    if header then header:SetText(headerText) end
end

function NWT.UpdateGuildSalesOverview(container, colors)
    local g = GetSelectedGuildData()
    local pKey = GetCurrentPeriodKey()
    local periodName = pKey == "day" and "24hr" or (pKey == "week" and "7 Day" or "30 Day")
    local daysOfData = pKey == "day" and 1 or (pKey == "week" and 7 or 30)
    for i = 1, 4 do local c = container:GetNamedChild("Guild" .. i) if c then c:SetHidden(true) end end
    local center = container:GetNamedChild("CenterCol")
    if center then
        center:SetHidden(false)
        local p = g.snap[pKey] or g.snap.month or {}
        local week = g.snap.week or {}
        local prevWeek = g.snap.prevWeek or {}
        local guildId = g.id
        -- Use pre-calculated health from snapshot
        local health = g.snap.healthScore or 50
        local healthLabel = g.snap.healthLabel or "Stable"
        local healthColor = g.snap.healthColor or "FFFF00"
        local kioskName = g.snap.kioskName or ""
        local totalMembers = GetNumGuildMembers(guildId) or 0
        local uniqueSellers = p.uniqueSellers or 0
        local sellerPct = totalMembers > 0 and string_format("%.0f%%", (uniqueSellers / totalMembers) * 100) or "0%"
        local net = (p.totalTax or 0) + (p.deposits or 0) - (p.netTraderCost or 0) - (p.withdrawals or 0)
        local avgSale = (p.totalSales or 0) > 0 and math_floor((p.totalGold or 0) / p.totalSales) or 0
        local dailySales = daysOfData > 0 and math_floor((p.totalSales or 0) / daysOfData) or 0
        local dailyGold = daysOfData > 0 and math_floor((p.totalGold or 0) / daysOfData) or 0
        -- Week trends
        local salesTrend, goldTrend, sellerTrend = "", "", ""
        if prevWeek.totalSales and prevWeek.totalSales > 0 then
            local pct = ((week.totalSales or 0) - prevWeek.totalSales) / prevWeek.totalSales * 100
            salesTrend = pct >= 0 and string_format("|c00FF00+%.0f%%|r", pct) or string_format("|cFF0000%.0f%%|r", pct)
        end
        if prevWeek.totalGold and prevWeek.totalGold > 0 then
            local pct = ((week.totalGold or 0) - prevWeek.totalGold) / prevWeek.totalGold * 100
            goldTrend = pct >= 0 and string_format("|c00FF00+%.0f%%|r", pct) or string_format("|cFF0000%.0f%%|r", pct)
        end
        if prevWeek.uniqueSellers and prevWeek.uniqueSellers > 0 then
            local pct = ((week.uniqueSellers or 0) - prevWeek.uniqueSellers) / prevWeek.uniqueSellers * 100
            sellerTrend = pct >= 0 and string_format("|c00FF00+%.0f%%|r", pct) or string_format("|cFF0000%.0f%%|r", pct)
        end
        -- Top category
        local topCatName = "None"
        local topCats = p.topCategories or {}
        if topCats[1] then topCatName = topCats[1].name or "Unknown" end
        -- Best seller name
        local bestSellerName = "None"
        local topSellers = p.topSellers or {}
        if topSellers[1] then bestSellerName = topSellers[1].name or "Unknown" end
        -- Header with guild name and trader location
        local guildName = TruncateText(g.name, 30)
        local nameLabel = center:GetNamedChild("GuildName")
        if nameLabel then 
            if kioskName ~= "" then
                nameLabel:SetText("|c00BFFF" .. guildName .. "|r |cFFAA00@ " .. kioskName .. "|r")
            else
                nameLabel:SetText("|c00BFFF" .. guildName .. "|r")
            end
        end
        local traderLabel = center:GetNamedChild("TraderLocation")
        if traderLabel then traderLabel:SetText(string_format("|c%s%s|r | %s | |cFFFFAA%d members|r", healthColor, healthLabel, periodName, totalMembers)) end
        -- Stats Grid - comprehensive overview
        local grid = center:GetNamedChild("StatsGrid")
        if grid then
            -- Row 1: Volume
            local sales = grid:GetNamedChild("Sales") if sales then sales:SetText(string_format("|cFFD700VOLUME|r")) end
            local volume = grid:GetNamedChild("Volume") if volume then volume:SetText(string_format("|cFFFFFF%d|r sales", p.totalSales or 0)) end
            local members = grid:GetNamedChild("Members") if members then members:SetText(string_format("|c00FF00%sg|r total", NWT.FormatGold(p.totalGold or 0))) end
            -- Row 2: Averages
            local sellers = grid:GetNamedChild("Sellers") if sellers then sellers:SetText(string_format("|cFFD700AVERAGES|r")) end
            local avgPrice = grid:GetNamedChild("AvgPrice") if avgPrice then avgPrice:SetText(string_format("|c00FF00%sg|r/sale", NWT.FormatGold(avgSale))) end
            local velocity = grid:GetNamedChild("Velocity") if velocity then velocity:SetText(string_format("|cFFFFFF%d|r sales/day", dailySales)) end
            -- Row 3: Participation
            local tax = grid:GetNamedChild("Tax") if tax then tax:SetText(string_format("|cFFD700PARTICIPATION|r")) end
            local weeklyTax = grid:GetNamedChild("WeeklyTax") if weeklyTax then weeklyTax:SetText(string_format("|c88FF88%d|r sellers (%s)", uniqueSellers, sellerPct)) end
            local traderCost = grid:GetNamedChild("TraderCost") if traderCost then traderCost:SetText(string_format("|c88FF88%d|r buyers", p.uniqueBuyers or 0)) end
            -- Row 4: Financials
            local profit = grid:GetNamedChild("Profit") if profit then profit:SetText(string_format("|cFFD700FINANCIALS|r")) end
            local weeklyProfit = grid:GetNamedChild("WeeklyProfit") if weeklyProfit then weeklyProfit:SetText(string_format("|c00FF00%sg|r tax", NWT.FormatGold(p.totalTax or 0))) end
            local change = grid:GetNamedChild("Change") if change then change:SetText(string_format("%s%sg|r bank", net >= 0 and "|c00FF00+" or "|cFF0000", NWT.FormatGold(net))) end
        end
        -- Use sellers list for additional overview data instead of top sellers
        UpdateListHeader(center, "|cFFD700GUILD OVERVIEW|r")
        local sellersList = center:GetNamedChild("SellersList")
        if sellersList then
            -- Left column (1-10), Right column (11-20) - must align by row
            local lines = {
                -- Left Column (1-10)
                [1] = "|cFFD700=== WEEKLY TRENDS ===|r",
                [2] = string_format("Sales: %s vs last week", salesTrend ~= "" and salesTrend or "|c888888N/A|r"),
                [3] = string_format("Gold: %s vs last week", goldTrend ~= "" and goldTrend or "|c888888N/A|r"),
                [4] = string_format("Sellers: %s vs last week", sellerTrend ~= "" and sellerTrend or "|c888888N/A|r"),
                [5] = "",
                [6] = "|cFFD700=== MARKET MIX ===|r",
                [7] = string_format("Top Category: |cFFFFAA%s|r", TruncateText(topCatName, 18)),
                [8] = string_format("Categories: |cFFFFFF%d|r active", p.uniqueCategories or 0),
                [9] = string_format("Unique Items: |cFFFFFF%d|r", p.uniqueItems or 0),
                [10] = string_format("Big Tickets: |c00FF00%d|r (100k+)", p.bigTicketCount or 0),
                -- Right Column (11-20) - aligns with left column rows
                [11] = "|cFFD700=== TOP PERFORMERS ===|r",
                [12] = string_format("#1 Seller: |c00FF00%s|r", TruncateText(bestSellerName, 18)),
                [13] = string_format("Top Item: |cFFFFAA%s|r", TruncateText((p.topItems and p.topItems[1] and p.topItems[1].name) or "None", 18)),
                [14] = "",
                [15] = "",
                [16] = "|cFFD700=== BANK ACTIVITY ===|r",
                [17] = string_format("Deposits: |c00FF00+%sg|r", NWT.FormatGold(p.deposits or 0)),
                [18] = string_format("Withdrawals: |cFF8888-%sg|r", NWT.FormatGold(p.withdrawals or 0)),
                [19] = string_format("Trader Cost: |cFFAA00%sg|r", NWT.FormatGold(p.netTraderCost or 0)),
                [20] = string_format("Depositors: |cFFFFFF%d|r members", p.depositorCount or 0),
            }
            for j = 1, 20 do
                local sellerLabel = sellersList:GetNamedChild("Seller" .. j)
                if sellerLabel then
                    sellerLabel:SetText(lines[j] or "")
                end
            end
        end
    end
    -- Update right panel
    NWT.UpdateGSTRightPanel(container, "overview", g)
end

-- Populate right panel based on current view
function NWT.UpdateGSTRightPanel(container, viewType, guildData)
    local rightCol = container:GetNamedChild("RightCol")
    if not rightCol then return end
    
    local actionsCard = rightCol:GetNamedChild("ActionsCard")
    local rangeCard = rightCol:GetNamedChild("RangeCard")
    local recentCard = rightCol:GetNamedChild("RecentCard")
    
    local g = guildData or GetSelectedGuildData()
    local pKey = GetCurrentPeriodKey()
    local p = g.snap[pKey] or g.snap.month or {}
    local week = g.snap.week or {}
    local prevWeek = g.snap.prevWeek or {}
    
    -- Card 1 (Actions) - Top performers / highlights
    if actionsCard then
        local header = actionsCard:GetNamedChild("Header")
        local a1 = actionsCard:GetNamedChild("Action1")
        local a2 = actionsCard:GetNamedChild("Action2")
        local a3 = actionsCard:GetNamedChild("Action3")
        local a4 = actionsCard:GetNamedChild("Action4")
        
        if viewType == "overview" then
            if header then header:SetText("|cFFD700TOP PERFORMERS|r") end
            local ts = p.topSellers or {}
            local ti = p.topItems or {}
            if a1 then a1:SetText(ts[1] and string_format("|c00FF00#1|r %s", TruncateText(ts[1].name, 14)) or "") end
            if a2 then a2:SetText(string_format("   |c888888%sg|r", ts[1] and NWT.FormatGold(ts[1].gold) or "0")) end
            if a3 then a3:SetText(ti[1] and string_format("|cFFAA00Top:|r %s", TruncateText(ti[1].name, 12)) or "") end
            if a4 then a4:SetText(string_format("   |c888888%sg|r", ti[1] and NWT.FormatGold(ti[1].gold) or "0")) end
        elseif viewType == "sellers" then
            if header then header:SetText("|cFFD700TOP 5 SELLERS|r") end
            local ts = p.topSellers or {}
            local total = p.totalGold or 1
            if a1 then a1:SetText(ts[1] and string_format("|cFFD7001.|r %s", TruncateText(ts[1].name, 13)) or "") end
            if a2 then a2:SetText(ts[2] and string_format("|cC0C0C02.|r %s", TruncateText(ts[2].name, 13)) or "") end
            if a3 then a3:SetText(ts[3] and string_format("|cCD7F323.|r %s", TruncateText(ts[3].name, 13)) or "") end
            if a4 then a4:SetText(ts[4] and string_format("|c8888884.|r %s", TruncateText(ts[4].name, 13)) or "") end
        elseif viewType == "items" then
            if header then header:SetText("|cFFD700TOP 5 ITEMS|r") end
            local ti = p.topItems or {}
            if a1 then a1:SetText(ti[1] and string_format("|cFFD7001.|r %s", TruncateText(ti[1].name, 13)) or "") end
            if a2 then a2:SetText(ti[2] and string_format("|cC0C0C02.|r %s", TruncateText(ti[2].name, 13)) or "") end
            if a3 then a3:SetText(ti[3] and string_format("|cCD7F323.|r %s", TruncateText(ti[3].name, 13)) or "") end
            if a4 then a4:SetText(ti[4] and string_format("|c8888884.|r %s", TruncateText(ti[4].name, 13)) or "") end
        elseif viewType == "quick" then
            if header then header:SetText("|c88FF88FARM THESE!|r") end
            local qs = p.quickSellers or {}
            if a1 then a1:SetText(qs[1] and string_format("|c00FF001.|r %s", TruncateText(qs[1].name, 13)) or "") end
            if a2 then a2:SetText(qs[2] and string_format("|c00FF002.|r %s", TruncateText(qs[2].name, 13)) or "") end
            if a3 then a3:SetText(qs[3] and string_format("|c00FF003.|r %s", TruncateText(qs[3].name, 13)) or "") end
            if a4 then a4:SetText(qs[4] and string_format("|c00FF004.|r %s", TruncateText(qs[4].name, 13)) or "") end
        elseif viewType == "categories" then
            if header then header:SetText("|cFFAA00TOP CATEGORIES|r") end
            local cats = p.topCategories or {}
            local total = p.totalGold or 1
            if a1 then a1:SetText(cats[1] and string_format("|cFFD7001.|r %s", TruncateText(cats[1].name, 13)) or "") end
            if a2 then a2:SetText(cats[1] and string_format("   |c00FF00%.0f%%|r of sales", (cats[1].gold/total)*100) or "") end
            if a3 then a3:SetText(cats[2] and string_format("|cC0C0C02.|r %s", TruncateText(cats[2].name, 13)) or "") end
            if a4 then a4:SetText(cats[2] and string_format("   |c888888%.0f%%|r of sales", (cats[2].gold/total)*100) or "") end
        elseif viewType == "compare" then
            if header then header:SetText("|cFFD700THIS WEEK|r") end
            if a1 then a1:SetText(string_format("|cFFFFAASales:|r |c00FF00%d|r", week.totalSales or 0)) end
            if a2 then a2:SetText(string_format("|cFFFFAAGold:|r |c00FF00%sg|r", NWT.FormatGold(week.totalGold or 0))) end
            if a3 then a3:SetText(string_format("|cFFFFAASellers:|r %d", week.uniqueSellers or 0)) end
            if a4 then a4:SetText(string_format("|cFFFFAABuyers:|r %d", week.uniqueBuyers or 0)) end
        elseif viewType == "activity" then
            if header then header:SetText("|cFFD700YOUR BEST ITEMS|r") end
            local mi = p.myTopItems or {}
            if a1 then a1:SetText(mi[1] and string_format("|cFFD7001.|r %s", TruncateText(mi[1].name, 13)) or "|c888888No sales|r") end
            if a2 then a2:SetText(mi[2] and string_format("|cC0C0C02.|r %s", TruncateText(mi[2].name, 13)) or "") end
            if a3 then a3:SetText(mi[3] and string_format("|cCD7F323.|r %s", TruncateText(mi[3].name, 13)) or "") end
            if a4 then a4:SetText(mi[4] and string_format("|c8888884.|r %s", TruncateText(mi[4].name, 13)) or "") end
        elseif viewType == "buyers" then
            if header then header:SetText("|cFFD700TOP 5 BUYERS|r") end
            local tb = p.topBuyers or {}
            if a1 then a1:SetText(tb[1] and string_format("|cFFD7001.|r %s", TruncateText(tb[1].name, 13)) or "") end
            if a2 then a2:SetText(tb[2] and string_format("|cC0C0C02.|r %s", TruncateText(tb[2].name, 13)) or "") end
            if a3 then a3:SetText(tb[3] and string_format("|cCD7F323.|r %s", TruncateText(tb[3].name, 13)) or "") end
            if a4 then a4:SetText(tb[4] and string_format("|c8888884.|r %s", TruncateText(tb[4].name, 13)) or "") end
        end
    end
    
    -- Card 2 (Range) - Stats / Numbers
    if rangeCard then
        local header = rangeCard:GetNamedChild("Header")
        local range = rangeCard:GetNamedChild("Range")
        local lastScan = rangeCard:GetNamedChild("LastScan")
        
        if viewType == "overview" then
            if header then header:SetText("|c00FFFFWEEKLY CHANGE|r") end
            local salesPct = prevWeek.totalSales and prevWeek.totalSales > 0 and ((week.totalSales or 0) - prevWeek.totalSales) / prevWeek.totalSales * 100 or 0
            local goldPct = prevWeek.totalGold and prevWeek.totalGold > 0 and ((week.totalGold or 0) - prevWeek.totalGold) / prevWeek.totalGold * 100 or 0
            if range then range:SetText(string_format("Sales: %s%.0f%%|r", salesPct >= 0 and "|c00FF00+" or "|cFF0000", salesPct)) end
            if lastScan then lastScan:SetText(string_format("Gold: %s%.0f%%|r", goldPct >= 0 and "|c00FF00+" or "|cFF0000", goldPct)) end
        elseif viewType == "sellers" then
            if header then header:SetText("|c00FFFFSELLER STATS|r") end
            local avgPerSeller = (p.uniqueSellers or 0) > 0 and math_floor((p.totalGold or 0) / p.uniqueSellers) or 0
            if range then range:SetText(string_format("Avg: |c00FF00%sg|r/seller", NWT.FormatGold(avgPerSeller))) end
            local top3Gold = 0
            local ts = p.topSellers or {}
            for i = 1, 3 do if ts[i] then top3Gold = top3Gold + ts[i].gold end end
            local top3Pct = (p.totalGold or 0) > 0 and (top3Gold / p.totalGold) * 100 or 0
            if lastScan then lastScan:SetText(string_format("Top 3: |cFFFFAA%.0f%%|r volume", top3Pct)) end
        elseif viewType == "items" then
            if header then header:SetText("|c00FFFFITEM STATS|r") end
            local avgPerItem = (p.uniqueItems or 0) > 0 and math_floor((p.totalGold or 0) / p.uniqueItems) or 0
            if range then range:SetText(string_format("Avg: |c00FF00%sg|r/item", NWT.FormatGold(avgPerItem))) end
            if lastScan then lastScan:SetText(string_format("|cFFFFAA%d|r unique items", p.uniqueItems or 0)) end
        elseif viewType == "quick" then
            if header then header:SetText("|c00FFFFQUICK STATS|r") end
            local qs = p.quickSellers or {}
            local topSold = qs[1] and qs[1].sold or 0
            local topAvg = qs[1] and qs[1].sold > 0 and math_floor(qs[1].gold / qs[1].sold) or 0
            if range then range:SetText(string_format("#1 sold |c00FF00%dx|r", topSold)) end
            if lastScan then lastScan:SetText(string_format("@ |cFFFFAA%sg|r each", NWT.FormatGold(topAvg))) end
        elseif viewType == "categories" then
            if header then header:SetText("|c00FFFFCATEGORY STATS|r") end
            if range then range:SetText(string_format("|cFFFFAA%d|r categories", p.uniqueCategories or 0)) end
            local cats = p.topCategories or {}
            local topSales = cats[1] and cats[1].sales or 0
            if lastScan then lastScan:SetText(string_format("Top: |c00FF00%d|r sales", topSales)) end
        elseif viewType == "compare" then
            if header then header:SetText("|c888888LAST WEEK|r") end
            if range then range:SetText(string_format("|c888888%d sales|r", prevWeek.totalSales or 0)) end
            if lastScan then lastScan:SetText(string_format("|c888888%sg|r", NWT.FormatGold(prevWeek.totalGold or 0))) end
        elseif viewType == "activity" then
            if header then header:SetText("|c00FFFFYOUR STATS|r") end
            local myShare = (p.totalGold or 0) > 0 and ((p.myGold or 0) / p.totalGold) * 100 or 0
            if range then range:SetText(string_format("Share: |c00FF00%.1f%%|r", myShare)) end
            if lastScan then lastScan:SetText(string_format("Profit: |c00FF00%sg|r", NWT.FormatGold((p.myGold or 0) - (p.myTax or 0)))) end
        elseif viewType == "buyers" then
            if header then header:SetText("|c00FFFFBUYER STATS|r") end
            local avgPerBuyer = (p.uniqueBuyers or 0) > 0 and math_floor((p.totalGold or 0) / p.uniqueBuyers) or 0
            if range then range:SetText(string_format("Avg: |c00FF00%sg|r/buyer", NWT.FormatGold(avgPerBuyer))) end
            if lastScan then lastScan:SetText(string_format("|cFFFFAA%d|r unique buyers", p.uniqueBuyers or 0)) end
        end
    end
    
    -- Card 3 (Recent) - Insights / Tips
    if recentCard then
        local header = recentCard:GetNamedChild("Header")
        local lines = {}
        
        if viewType == "overview" then
            if header then header:SetText(string_format("|c%sHEALTH: %s|r", g.snap.healthColor or "FFFF00", g.snap.healthLabel or "Stable")) end
            local healthScore = g.snap.healthScore or 50
            lines = {
                string_format("Score: |c%s%d|r / 100", g.snap.healthColor or "FFFF00", healthScore),
                "",
                string_format("Big Tickets: |c00FF00%d|r", p.bigTicketCount or 0),
                string_format("Depositors: |cFFFFAA%d|r", p.depositorCount or 0),
                string_format("Bank Net: %s%sg|r", ((p.deposits or 0) - (p.withdrawals or 0)) >= 0 and "|c00FF00+" or "|cFF0000", NWT.FormatGold(math.abs((p.deposits or 0) - (p.withdrawals or 0)))),
                "",
                "|c888888Scan to refresh|r",
            }
        elseif viewType == "sellers" then
            if header then header:SetText("|c88FF88INSIGHTS|r") end
            local ts = p.topSellers or {}
            local totalMembers = GetNumGuildMembers(g.id) or 1
            local sellerPct = totalMembers > 0 and ((p.uniqueSellers or 0) / totalMembers) * 100 or 0
            lines = {
                string_format("|cFFFFAA%.0f%%|r of members sell", sellerPct),
                "",
                ts[1] and string_format("#1: |c00FF00%sg|r", NWT.FormatGold(ts[1].gold)) or "",
                ts[2] and string_format("#2: |cFFFFAA%sg|r", NWT.FormatGold(ts[2].gold)) or "",
                ts[3] and string_format("#3: |c888888%sg|r", NWT.FormatGold(ts[3].gold)) or "",
                "",
                string_format("|cFFFFAA%d|r active sellers", p.uniqueSellers or 0),
            }
        elseif viewType == "items" then
            if header then header:SetText("|c88FF88INSIGHTS|r") end
            local ti = p.topItems or {}
            lines = {
                ti[1] and string_format("#1: |c00FF00%sg|r", NWT.FormatGold(ti[1].gold)) or "",
                ti[2] and string_format("#2: |cFFFFAA%sg|r", NWT.FormatGold(ti[2].gold)) or "",
                ti[3] and string_format("#3: |c888888%sg|r", NWT.FormatGold(ti[3].gold)) or "",
                "",
                "Top items = highest",
                "total gold earned",
                "",
            }
        elseif viewType == "quick" then
            if header then header:SetText("|c88FF88WHY FARM THESE?|r") end
            lines = {
                "Quick sellers move",
                "|c00FF00FAST|r - high volume!",
                "",
                "Stock these for",
                "steady income.",
                "",
                "Easy gold!",
            }
        elseif viewType == "categories" then
            if header then header:SetText("|c88FF88INSIGHTS|r") end
            local cats = p.topCategories or {}
            local total = p.totalGold or 1
            lines = {
                cats[1] and string_format("|cFFD700%s|r", cats[1].name) or "",
                cats[1] and string_format("|c00FF00%.0f%%|r of all gold", (cats[1].gold/total)*100) or "",
                "",
                "Focus your farming",
                "on top categories",
                "for best returns!",
                "",
            }
        elseif viewType == "compare" then
            if header then header:SetText("|c88FF88TREND|r") end
            local salesPct = prevWeek.totalSales and prevWeek.totalSales > 0 and ((week.totalSales or 0) - prevWeek.totalSales) / prevWeek.totalSales * 100 or 0
            local status = salesPct > 10 and "|c00FF00GROWING|r" or (salesPct < -10 and "|cFF0000DECLINING|r" or "|cFFFF00STABLE|r")
            lines = {
                "Guild is " .. status,
                "",
                string_format("Sales: %s%.0f%%|r", salesPct >= 0 and "|c00FF00+" or "|cFF0000", salesPct),
                "",
                "Compare week over",
                "week to spot trends",
                "",
            }
        elseif viewType == "activity" then
            if header then header:SetText("|c88FF88YOUR RANK|r") end
            local myRank = 0
            for r, seller in ipairs(p.topSellers or {}) do if (p.myGold or 0) >= seller.gold then myRank = r break end end
            local rankText = myRank == 1 and "|cFFD700#1 SELLER!|r" or (myRank > 0 and string_format("Rank |c00FF00#%d|r", myRank) or "|c888888Not ranked|r")
            lines = {
                rankText,
                "",
                string_format("Sales: |cFFFFAA%d|r", p.mySales or 0),
                string_format("Gold: |c00FF00%sg|r", NWT.FormatGold(p.myGold or 0)),
                string_format("Tax: |cFF8888%sg|r", NWT.FormatGold(p.myTax or 0)),
                "",
                "Keep selling!",
            }
        elseif viewType == "buyers" then
            if header then header:SetText("|c88FF88INSIGHTS|r") end
            local tb = p.topBuyers or {}
            lines = {
                tb[1] and string_format("#1: |c00FF00%sg|r", NWT.FormatGold(tb[1].gold)) or "",
                tb[2] and string_format("#2: |cFFFFAA%sg|r", NWT.FormatGold(tb[2].gold)) or "",
                tb[3] and string_format("#3: |c888888%sg|r", NWT.FormatGold(tb[3].gold)) or "",
                "",
                "Top buyers keep",
                "your guild alive!",
                "",
            }
        end
        
        for i = 1, 7 do
            local sale = recentCard:GetNamedChild("Sale" .. i)
            if sale then sale:SetText(lines[i] or "") end
        end
    end
end

function NWT.UpdateGuildSalesTopSellers(container, colors)
    local g = GetSelectedGuildData()
    local pKey = GetCurrentPeriodKey()
    local periodName = pKey == "day" and "24hr" or (pKey == "week" and "7 Day" or "30 Day")
    for i = 1, 4 do local c = container:GetNamedChild("Guild" .. i) if c then c:SetHidden(true) end end
    local center = container:GetNamedChild("CenterCol")
    if center then
        center:SetHidden(false)
        local p = g.snap[pKey] or g.snap.month or {}
        local totalGold = p.totalGold or 0
        local uniqueSellers = p.uniqueSellers or 0
        local guildName = TruncateText(g.name, 30)
        local nameLabel = center:GetNamedChild("GuildName")
        if nameLabel then nameLabel:SetText("|c00BFFF" .. guildName .. "|r") end
        local traderLabel = center:GetNamedChild("TraderLocation")
        if traderLabel then traderLabel:SetText(string_format("|cFFD700TOP SELLERS|r | %d active | %s", uniqueSellers, periodName)) end
        -- Show summary stats in grid
        local grid = center:GetNamedChild("StatsGrid")
        if grid then
            local avgPerSeller = uniqueSellers > 0 and math_floor(totalGold / uniqueSellers) or 0
            local sales = grid:GetNamedChild("Sales") if sales then sales:SetText(string_format("|cFFFFAATotal Volume:|r |c00FF00%sg|r", NWT.FormatGold(totalGold))) end
            local volume = grid:GetNamedChild("Volume") if volume then volume:SetText(string_format("|cFFFFAASellers:|r %d", uniqueSellers)) end
            local members = grid:GetNamedChild("Members") if members then members:SetText(string_format("|cFFFFAAAvg/Seller:|r |c00FF00%sg|r", NWT.FormatGold(avgPerSeller))) end
            for _, f in ipairs({"Sellers","AvgPrice","Velocity","Tax","WeeklyTax","TraderCost","Profit","WeeklyProfit","Change"}) do local l = grid:GetNamedChild(f) if l then l:SetText("") end end
        end
        UpdateListHeader(center, "|cFFD700TOP 20 SELLERS|r")
        local sellersList = center:GetNamedChild("SellersList")
        if sellersList then
            local top = p.topSellers or {}
            for j = 1, 20 do
                local sellerLabel = sellersList:GetNamedChild("Seller" .. j)
                if sellerLabel then
                    local s = top[j]
                    if s then
                        local pct = totalGold > 0 and string_format("|c888888%.0f%%|r", (s.gold / totalGold) * 100) or ""
                        sellerLabel:SetText(FormatListEntry(j, s.name, s.gold, s.sales, "sales", pct))
                    else sellerLabel:SetText("") end
                end
            end
        end
    end
    NWT.UpdateGSTRightPanel(container, "sellers", g)
end

function NWT.UpdateGuildSalesTopItems(container, colors)
    local g = GetSelectedGuildData()
    local pKey = GetCurrentPeriodKey()
    local periodName = pKey == "day" and "24hr" or (pKey == "week" and "7 Day" or "30 Day")
    for i = 1, 4 do local c = container:GetNamedChild("Guild" .. i) if c then c:SetHidden(true) end end
    local center = container:GetNamedChild("CenterCol")
    if center then
        center:SetHidden(false)
        local p = g.snap[pKey] or g.snap.month or {}
        local totalGold = p.totalGold or 0
        local uniqueItems = p.uniqueItems or 0
        local guildName = TruncateText(g.name, 30)
        local nameLabel = center:GetNamedChild("GuildName")
        if nameLabel then nameLabel:SetText("|c00BFFF" .. guildName .. "|r") end
        local traderLabel = center:GetNamedChild("TraderLocation")
        if traderLabel then traderLabel:SetText(string_format("|cFFD700TOP ITEMS|r | %d unique | %s", uniqueItems, periodName)) end
        -- Show summary stats
        local grid = center:GetNamedChild("StatsGrid")
        if grid then
            local avgPerItem = uniqueItems > 0 and math_floor(totalGold / uniqueItems) or 0
            local sales = grid:GetNamedChild("Sales") if sales then sales:SetText(string_format("|cFFFFAATotal Volume:|r |c00FF00%sg|r", NWT.FormatGold(totalGold))) end
            local volume = grid:GetNamedChild("Volume") if volume then volume:SetText(string_format("|cFFFFAAUnique Items:|r %d", uniqueItems)) end
            local members = grid:GetNamedChild("Members") if members then members:SetText(string_format("|cFFFFAAAvg/Item:|r |c00FF00%sg|r", NWT.FormatGold(avgPerItem))) end
            for _, f in ipairs({"Sellers","AvgPrice","Velocity","Tax","WeeklyTax","TraderCost","Profit","WeeklyProfit","Change"}) do local l = grid:GetNamedChild(f) if l then l:SetText("") end end
        end
        UpdateListHeader(center, "|cFFD700TOP 20 ITEMS|r")
        local sellersList = center:GetNamedChild("SellersList")
        if sellersList then
            local top = p.topItems or {}
            for j = 1, 20 do
                local label = sellersList:GetNamedChild("Seller" .. j)
                if label then
                    local it = top[j]
                    if it then
                        local itemName = TruncateText(it.name or "Unknown", 16)
                        label:SetText(string_format("|cFFFFFF%2d.|r %-16s |c00FF00%sg|r", j, itemName, NWT.FormatGold(it.gold or 0)))
                    else label:SetText("") end
                end
            end
        end
    end
    NWT.UpdateGSTRightPanel(container, "items", g)
end

function NWT.UpdateGuildSalesQuickSellers(container, colors)
    local g = GetSelectedGuildData()
    local pKey = GetCurrentPeriodKey()
    local periodName = pKey == "day" and "24hr" or (pKey == "week" and "7 Day" or "30 Day")
    for i = 1, 4 do local c = container:GetNamedChild("Guild" .. i) if c then c:SetHidden(true) end end
    local center = container:GetNamedChild("CenterCol")
    if center then
        center:SetHidden(false)
        local p = g.snap[pKey] or g.snap.month or {}
        local totalSales = p.totalSales or 0
        local guildName = TruncateText(g.name, 30)
        local nameLabel = center:GetNamedChild("GuildName")
        if nameLabel then nameLabel:SetText("|c00BFFF" .. guildName .. "|r") end
        local traderLabel = center:GetNamedChild("TraderLocation")
        if traderLabel then traderLabel:SetText(string_format("|c88FF88QUICK SELLERS|r | Fast turnover items | %s", periodName)) end
        local grid = center:GetNamedChild("StatsGrid")
        if grid then
            local quickSellers = p.quickSellers or {}
            local topSold = quickSellers[1] and quickSellers[1].sold or 0
            local sales = grid:GetNamedChild("Sales") if sales then sales:SetText(string_format("|cFFFFAATotal Sales:|r |cFFFFFF%d|r", totalSales)) end
            local volume = grid:GetNamedChild("Volume") if volume then volume:SetText(string_format("|cFFFFAATop Item:|r |c00FF00%dx sold|r", topSold)) end
            local members = grid:GetNamedChild("Members") if members then members:SetText("|c88FF88Easy gold - high volume!|r") end
            for _, f in ipairs({"Sellers","AvgPrice","Velocity","Tax","WeeklyTax","TraderCost","Profit","WeeklyProfit","Change"}) do local l = grid:GetNamedChild(f) if l then l:SetText("") end end
        end
        UpdateListHeader(center, "|c88FF88TOP 20 QUICK SELLERS (by sale count)|r")
        local sellersList = center:GetNamedChild("SellersList")
        if sellersList then
            local qs = p.quickSellers or {}
            for j = 1, 20 do
                local label = sellersList:GetNamedChild("Seller" .. j)
                if label then
                    local it = qs[j]
                    if it then
                        local itemName = TruncateText(it.name or "Unknown", 14)
                        local avgPrice = it.sold > 0 and math_floor(it.gold / it.sold) or 0
                        label:SetText(string_format("|cFFFFFF%2d.|r %-14s |c88FF88%dx|r |c888888@%sg|r", j, itemName, it.sold, NWT.FormatGold(avgPrice)))
                    else label:SetText("") end
                end
            end
        end
    end
    NWT.UpdateGSTRightPanel(container, "quick", g)
end

function NWT.UpdateGuildSalesCategories(container, colors)
    local g = GetSelectedGuildData()
    local pKey = GetCurrentPeriodKey()
    local periodName = pKey == "day" and "24hr" or (pKey == "week" and "7 Day" or "30 Day")
    for i = 1, 4 do local c = container:GetNamedChild("Guild" .. i) if c then c:SetHidden(true) end end
    local center = container:GetNamedChild("CenterCol")
    if center then
        center:SetHidden(false)
        local p = g.snap[pKey] or g.snap.month or {}
        local totalGold = p.totalGold or 0
        local uniqueCategories = p.uniqueCategories or 0
        local guildName = TruncateText(g.name, 30)
        local nameLabel = center:GetNamedChild("GuildName")
        if nameLabel then nameLabel:SetText("|c00BFFF" .. guildName .. "|r") end
        local traderLabel = center:GetNamedChild("TraderLocation")
        if traderLabel then traderLabel:SetText(string_format("|cFFAA00CATEGORIES|r | %d categories | %s", uniqueCategories, periodName)) end
        local grid = center:GetNamedChild("StatsGrid")
        if grid then
            local topCats = p.topCategories or {}
            local topCatName = topCats[1] and topCats[1].name or "None"
            local topCatGold = topCats[1] and topCats[1].gold or 0
            local sales = grid:GetNamedChild("Sales") if sales then sales:SetText(string_format("|cFFFFAATotal Volume:|r |c00FF00%sg|r", NWT.FormatGold(totalGold))) end
            local volume = grid:GetNamedChild("Volume") if volume then volume:SetText(string_format("|cFFFFAACategories:|r %d", uniqueCategories)) end
            local members = grid:GetNamedChild("Members") if members then members:SetText(string_format("|cFFFFAATop:|r %s", topCatName)) end
            for _, f in ipairs({"Sellers","AvgPrice","Velocity","Tax","WeeklyTax","TraderCost","Profit","WeeklyProfit","Change"}) do local l = grid:GetNamedChild(f) if l then l:SetText("") end end
        end
        UpdateListHeader(center, "|cFFAA00CATEGORY BREAKDOWN|r")
        local sellersList = center:GetNamedChild("SellersList")
        if sellersList then
            local cats = p.topCategories or {}
            for j = 1, 20 do
                local label = sellersList:GetNamedChild("Seller" .. j)
                if label then
                    local cat = cats[j]
                    if cat then
                        local catName = TruncateText(cat.name or "Unknown", 14)
                        local pct = totalGold > 0 and (cat.gold / totalGold) * 100 or 0
                        label:SetText(string_format("|cFFFFFF%2d.|r %-14s |c00FF00%sg|r |c888888%.0f%%|r", j, catName, NWT.FormatGold(cat.gold or 0), pct))
                    else label:SetText("") end
                end
            end
        end
    end
    NWT.UpdateGSTRightPanel(container, "categories", g)
end

function NWT.UpdateGuildSalesWeekCompare(container, colors)
    local g = GetSelectedGuildData()
    for i = 1, 4 do local c = container:GetNamedChild("Guild" .. i) if c then c:SetHidden(true) end end
    local center = container:GetNamedChild("CenterCol")
    if center then
        center:SetHidden(false)
        local week = g.snap.week or {}
        local prevWeek = g.snap.prevWeek or {}
        local wSales, pwSales = week.totalSales or 0, prevWeek.totalSales or 0
        local wGold, pwGold = week.totalGold or 0, prevWeek.totalGold or 0
        local wSellers, pwSellers = week.uniqueSellers or 0, prevWeek.uniqueSellers or 0
        local wBuyers, pwBuyers = week.uniqueBuyers or 0, prevWeek.uniqueBuyers or 0
        local salesChange = pwSales > 0 and ((wSales - pwSales) / pwSales) * 100 or 0
        local goldChange = pwGold > 0 and ((wGold - pwGold) / pwGold) * 100 or 0
        local sArrow, sColor = GetTrendIndicator(wSales, pwSales)
        local gArrow, gColor = GetTrendIndicator(wGold, pwGold)
        local status = salesChange > 10 and "|c00FF00GROWING|r" or (salesChange < -10 and "|cFF0000DECLINING|r" or "|cFFFF00STABLE|r")
        local guildName = TruncateText(g.name, 30)
        local nameLabel = center:GetNamedChild("GuildName")
        if nameLabel then nameLabel:SetText("|c00BFFF" .. guildName .. "|r") end
        local traderLabel = center:GetNamedChild("TraderLocation")
        if traderLabel then traderLabel:SetText("|cFFD700WEEK COMPARISON|r " .. status) end
        local grid = center:GetNamedChild("StatsGrid")
        if grid then
            -- This Week row
            local sales = grid:GetNamedChild("Sales") if sales then sales:SetText(string_format("|c00FF00THIS WEEK|r")) end
            local volume = grid:GetNamedChild("Volume") if volume then volume:SetText(string_format("|cFFFFAA%d sales|r", wSales)) end
            local members = grid:GetNamedChild("Members") if members then members:SetText(string_format("|c00FF00%sg|r", NWT.FormatGold(wGold))) end
            -- Last Week row
            local sellers = grid:GetNamedChild("Sellers") if sellers then sellers:SetText(string_format("|c888888LAST WEEK|r")) end
            local avgPrice = grid:GetNamedChild("AvgPrice") if avgPrice then avgPrice:SetText(string_format("|c888888%d sales|r", pwSales)) end
            local velocity = grid:GetNamedChild("Velocity") if velocity then velocity:SetText(string_format("|c888888%sg|r", NWT.FormatGold(pwGold))) end
            -- Change row
            local tax = grid:GetNamedChild("Tax") if tax then tax:SetText(string_format("|cFFFFAACHANGE|r")) end
            local weeklyTax = grid:GetNamedChild("WeeklyTax") if weeklyTax then weeklyTax:SetText(string_format("|c%s%s %.0f%% sales|r", sColor, sArrow, salesChange)) end
            local traderCost = grid:GetNamedChild("TraderCost") if traderCost then traderCost:SetText(string_format("|c%s%s %.0f%% gold|r", gColor, gArrow, goldChange)) end
            -- Participation row
            local profit = grid:GetNamedChild("Profit") if profit then profit:SetText(string_format("|c88FF88Sellers:|r %d vs %d", wSellers, pwSellers)) end
            local weeklyProfit = grid:GetNamedChild("WeeklyProfit") if weeklyProfit then weeklyProfit:SetText(string_format("|c88FF88Buyers:|r %d vs %d", wBuyers, pwBuyers)) end
            local change = grid:GetNamedChild("Change") if change then change:SetText("") end
        end
        UpdateListHeader(center, "")
        local sellersList = center:GetNamedChild("SellersList")
        if sellersList then for j = 1, 20 do local l = sellersList:GetNamedChild("Seller" .. j) if l then l:SetText("") end end end
    end
    NWT.UpdateGSTRightPanel(container, "compare", g)
end

function NWT.UpdateGuildSalesActivity(container, colors)
    local g = GetSelectedGuildData()
    local pKey = GetCurrentPeriodKey()
    local periodName = pKey == "day" and "24hr" or (pKey == "week" and "7 Day" or "30 Day")
    for i = 1, 4 do local c = container:GetNamedChild("Guild" .. i) if c then c:SetHidden(true) end end
    local center = container:GetNamedChild("CenterCol")
    if center then
        center:SetHidden(false)
        local p = g.snap[pKey] or g.snap.month or {}
        local mySales, myGold, myTax = p.mySales or 0, p.myGold or 0, p.myTax or 0
        local myProfit = myGold - myTax
        local myAvg = mySales > 0 and math_floor(myGold / mySales) or 0
        local myRank, totalSellers = 0, p.uniqueSellers or 0
        for r, seller in ipairs(p.topSellers or {}) do if seller.gold <= myGold then myRank = r break end end
        local rankText = myRank == 1 and "|cFFD700#1 SELLER|r" or (myRank > 0 and string_format("|c00FF00Rank #%d|r", myRank) or "|cFF6666No Sales|r")
        local guildName = TruncateText(g.name, 30)
        local nameLabel = center:GetNamedChild("GuildName")
        if nameLabel then nameLabel:SetText("|c00BFFF" .. guildName .. "|r") end
        local traderLabel = center:GetNamedChild("TraderLocation")
        if traderLabel then traderLabel:SetText("|cFFD700MY ACTIVITY|r | " .. rankText .. " | " .. periodName) end
        local grid = center:GetNamedChild("StatsGrid")
        if grid then
            local sales = grid:GetNamedChild("Sales") if sales then sales:SetText(string_format("|cFFFFAAMy Sales:|r |cFFFFFF%d|r", mySales)) end
            local volume = grid:GetNamedChild("Volume") if volume then volume:SetText(string_format("|cFFFFAAMy Gold:|r |c00FF00%sg|r", NWT.FormatGold(myGold))) end
            local members = grid:GetNamedChild("Members") if members then members:SetText(string_format("|cFFFFAAMy Avg:|r |c00FF00%sg|r", NWT.FormatGold(myAvg))) end
            local sellers = grid:GetNamedChild("Sellers") if sellers then sellers:SetText(string_format("|cFF8888Tax Paid:|r %sg", NWT.FormatGold(myTax))) end
            local avgPrice = grid:GetNamedChild("AvgPrice") if avgPrice then avgPrice:SetText(string_format("|c00FF00Net Profit:|r %sg", NWT.FormatGold(myProfit))) end
            local velocity = grid:GetNamedChild("Velocity") if velocity then velocity:SetText(myRank > 0 and string_format("|c888888%d of %d sellers|r", myRank, totalSellers) or "") end
            -- Guild comparison
            local guildGold = p.totalGold or 0
            local myShare = guildGold > 0 and (myGold / guildGold) * 100 or 0
            local tax = grid:GetNamedChild("Tax") if tax then tax:SetText(string_format("|cFFFFAAGuild Total:|r |c00FF00%sg|r", NWT.FormatGold(guildGold))) end
            local weeklyTax = grid:GetNamedChild("WeeklyTax") if weeklyTax then weeklyTax:SetText(string_format("|cFFFFAAMy Share:|r |c00FF00%.1f%%|r", myShare)) end
            local traderCost = grid:GetNamedChild("TraderCost") if traderCost then traderCost:SetText(string_format("|cFFFFAAGuild Sales:|r %d", p.totalSales or 0)) end
            for _, f in ipairs({"Profit","WeeklyProfit","Change"}) do local l = grid:GetNamedChild(f) if l then l:SetText("") end end
        end
        UpdateListHeader(center, "|cFFD700MY TOP 20 ITEMS|r")
        local sellersList = center:GetNamedChild("SellersList")
        if sellersList then
            local myItems = p.myTopItems or {}
            for j = 1, 20 do
                local label = sellersList:GetNamedChild("Seller" .. j)
                if label then
                    local it = myItems[j]
                    if it then
                        local itemName = TruncateText(it.name or "Unknown", 14)
                        label:SetText(string_format("|cFFFFFF%2d.|r %-14s |c00FF00%sg|r |c888888x%d|r", j, itemName, NWT.FormatGold(it.gold or 0), it.sold or 0))
                    else label:SetText("") end
                end
            end
        end
    end
    NWT.UpdateGSTRightPanel(container, "activity", g)
end

function NWT.UpdateGuildSalesBuyers(container, colors)
    local g = GetSelectedGuildData()
    local pKey = GetCurrentPeriodKey()
    local periodName = pKey == "day" and "24hr" or (pKey == "week" and "7 Day" or "30 Day")
    for i = 1, 4 do local c = container:GetNamedChild("Guild" .. i) if c then c:SetHidden(true) end end
    local center = container:GetNamedChild("CenterCol")
    if center then
        center:SetHidden(false)
        local p = g.snap[pKey] or g.snap.month or {}
        local totalGold = p.totalGold or 0
        local uniqueBuyers = p.uniqueBuyers or 0
        local guildName = TruncateText(g.name, 30)
        local nameLabel = center:GetNamedChild("GuildName")
        if nameLabel then nameLabel:SetText("|c00BFFF" .. guildName .. "|r") end
        local traderLabel = center:GetNamedChild("TraderLocation")
        if traderLabel then traderLabel:SetText(string_format("|cFFD700TOP BUYERS|r | %d buyers | %s", uniqueBuyers, periodName)) end
        -- Show summary stats
        local grid = center:GetNamedChild("StatsGrid")
        if grid then
            local avgPerBuyer = uniqueBuyers > 0 and math_floor(totalGold / uniqueBuyers) or 0
            local sales = grid:GetNamedChild("Sales") if sales then sales:SetText(string_format("|cFFFFAATotal Spent:|r |c00FF00%sg|r", NWT.FormatGold(totalGold))) end
            local volume = grid:GetNamedChild("Volume") if volume then volume:SetText(string_format("|cFFFFAABuyers:|r %d", uniqueBuyers)) end
            local members = grid:GetNamedChild("Members") if members then members:SetText(string_format("|cFFFFAAAvg/Buyer:|r |c00FF00%sg|r", NWT.FormatGold(avgPerBuyer))) end
            for _, f in ipairs({"Sellers","AvgPrice","Velocity","Tax","WeeklyTax","TraderCost","Profit","WeeklyProfit","Change"}) do local l = grid:GetNamedChild(f) if l then l:SetText("") end end
        end
        UpdateListHeader(center, "|cFFD700TOP 20 BUYERS|r")
        local sellersList = center:GetNamedChild("SellersList")
        if sellersList then
            local topBuyers = p.topBuyers or {}
            for j = 1, 20 do
                local label = sellersList:GetNamedChild("Seller" .. j)
                if label then
                    local b = topBuyers[j]
                    if b and b.gold > 0 then
                        local pct = totalGold > 0 and string_format("|c888888%.0f%%|r", (b.gold / totalGold) * 100) or ""
                        label:SetText(FormatListEntry(j, b.name, b.gold, b.purchases, "buys", pct))
                    else label:SetText("") end
                end
            end
        end
    end
    NWT.UpdateGSTRightPanel(container, "buyers", g)
end

function NWT.UpdateGuildSalesUI() if NWT.GuildSalesDashboard and NWT.GuildSalesDashboard.isOpen then NWT.UpdateGuildSalesDashboard() NWT.UpdateGuildSalesLeftPanel() end end
function NWT.OpenGuildSalesDashboard() if NWT.GuildSalesDashboard.isOpen then return end NWT.InitGuildSalesDashboardScene() if not GUILD_SALES_DASHBOARD_SCENE then return end NWT.UpdateGuildSalesDashboard() SCENE_MANAGER:Push("guildSalesDashboardScene") end
function NWT.CloseGuildSalesDashboard() if GUILD_SALES_DASHBOARD_SCENE then SCENE_MANAGER:Hide("guildSalesDashboardScene") end end
