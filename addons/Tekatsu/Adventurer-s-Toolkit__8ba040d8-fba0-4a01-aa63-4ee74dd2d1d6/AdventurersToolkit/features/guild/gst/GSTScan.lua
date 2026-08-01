-- ============================================
-- GST SCAN AND HISTORY REQUEST QUEUE
-- ============================================
-- Scan logic, history request queue, bank gold, init, clear.
-- Uses NWT.GSTConstants and NWT.GST for shared state.

local GC = NWT.GSTConstants
local TIME_PERIODS = GC.TIME_PERIODS
local itemTypeToCategory = GC.itemTypeToCategory
local math_floor = math.floor
local GetTimeStamp = GetTimeStamp
local GetDisplayName = GetDisplayName
local GetGuildName = GetGuildName
local GetItemLinkItemId = GetItemLinkItemId
local GetItemLinkName = GetItemLinkName
local GetItemLinkItemType = GetItemLinkItemType
local GetGameTimeMilliseconds = GetGameTimeMilliseconds
local string_format = string.format

local function AddSaleToPeriod(pd, sellerName, buyerName, itemId, itemName, quantity, price, tax, myName, itemType)
    pd.totalSales = pd.totalSales + 1
    pd.totalGold = pd.totalGold + price
    pd.totalTax = pd.totalTax + tax

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
        if #topItems < 20 then
            table.insert(topItems, { name = data.name, gold = data.totalGold, sold = data.totalSold })
        elseif data.totalGold > topItems[20].gold then
            topItems[20] = { name = data.name, gold = data.totalGold, sold = data.totalSold }
            table.sort(topItems, function(a, b) return a.gold > b.gold end)
        end
        if #quickSellers < 20 then
            table.insert(quickSellers, { name = data.name, gold = data.totalGold, sold = data.totalSold })
        elseif data.totalSold > quickSellers[20].sold then
            quickSellers[20] = { name = data.name, gold = data.totalGold, sold = data.totalSold }
            table.sort(quickSellers, function(a, b) return a.sold > b.sold end)
        end
    end
    table.sort(topItems, function(a, b) return a.gold > b.gold end)
    table.sort(quickSellers, function(a, b) return a.sold > b.sold end)

    for catName, catData in pairs(periodData.categories or {}) do
        uc = uc + 1
        table.insert(topCategories, { name = catName, gold = catData.gold, sales = catData.sales })
    end
    table.sort(topCategories, function(a, b) return a.gold > b.gold end)

    return topSellers, topBuyers, topItems, us, ui, ub, quickSellers, topCategories, uc
end

local function CalculateGuildHealth(week, prevWeek, month, guildId)
    local score = 0
    local totalMembers = GetNumGuildMembers(guildId) or 1

    if prevWeek and prevWeek.totalSales and prevWeek.totalSales > 0 then
        local salesChange = ((week.totalSales or 0) - prevWeek.totalSales) / prevWeek.totalSales
        if salesChange >= 0.10 then score = score + 10
        elseif salesChange >= 0 then score = score + 7
        elseif salesChange >= -0.10 then score = score + 4
        end
    else
        score = score + 5
    end
    if prevWeek and prevWeek.totalGold and prevWeek.totalGold > 0 then
        local goldChange = ((week.totalGold or 0) - prevWeek.totalGold) / prevWeek.totalGold
        if goldChange >= 0.10 then score = score + 10
        elseif goldChange >= 0 then score = score + 7
        elseif goldChange >= -0.10 then score = score + 4
        end
    else
        score = score + 5
    end
    if month and month.totalSales and month.totalSales > 0 then
        score = score + 5
    end

    local sellerPct = totalMembers > 0 and ((week.uniqueSellers or 0) / totalMembers) or 0
    if sellerPct >= 0.20 then score = score + 10
    elseif sellerPct >= 0.10 then score = score + 7
    elseif sellerPct >= 0.05 then score = score + 4
    elseif sellerPct > 0 then score = score + 2
    end
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
    local sellerGrowth = (prevWeek and prevWeek.uniqueSellers and prevWeek.uniqueSellers > 0)
        and ((week.uniqueSellers or 0) - prevWeek.uniqueSellers) / prevWeek.uniqueSellers or 0
    if sellerGrowth > 0 then score = score + 7
    elseif sellerGrowth == 0 then score = score + 4
    else score = score + 2 end

    local buyerPct = (week.totalSales or 0) > 0 and ((week.uniqueBuyers or 0) / week.totalSales) or 0
    if buyerPct >= 0.30 then score = score + 8
    elseif buyerPct >= 0.15 then score = score + 5
    elseif buyerPct > 0 then score = score + 2
    end
    local avgSale = (week.totalSales or 0) > 0 and ((week.totalGold or 0) / week.totalSales) or 0
    if avgSale >= 50000 then score = score + 7
    elseif avgSale >= 20000 then score = score + 5
    elseif avgSale >= 5000 then score = score + 3
    elseif avgSale > 0 then score = score + 1
    end
    local itemVariety = week.uniqueItems or 0
    if itemVariety >= 100 then score = score + 5
    elseif itemVariety >= 50 then score = score + 3
    elseif itemVariety > 0 then score = score + 1
    end
    local bigTickets = week.bigTicketCount or 0
    if bigTickets >= 10 then score = score + 5
    elseif bigTickets >= 5 then score = score + 3
    elseif bigTickets > 0 then score = score + 1
    end

    if prevWeek and prevWeek.totalTax and prevWeek.totalTax > 0 then
        local taxChange = ((week.totalTax or 0) - prevWeek.totalTax) / prevWeek.totalTax
        if taxChange >= 0 then score = score + 8
        elseif taxChange >= -0.20 then score = score + 4
        end
    else
        score = score + 4
    end
    local netBank = (week.deposits or 0) - (week.withdrawals or 0)
    if netBank > 0 then score = score + 7
    elseif netBank == 0 then score = score + 4
    else score = score + 2 end
    local traderCost = week.netTraderCost or 0
    local taxRevenue = week.totalTax or 0
    if traderCost == 0 or taxRevenue >= traderCost then score = score + 5
    elseif taxRevenue >= traderCost * 0.5 then score = score + 3
    else score = score + 1 end
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
    local gst = NWT.GST
    local sd = gst.scanData
    if not sd then return end

    local sv = NWT.savedVars
    local guildName = sv.gstGuildNames[guildId] or ("Guild " .. guildId)
    if not sv.gstGuildSnapshots then sv.gstGuildSnapshots = {} end

    local periodSnapshots = {}
    for _, period in ipairs(TIME_PERIODS) do
        local pd = sd[period.key]
        local ts, tb, ti, us, ui, ub, qs, tc, uc = BuildTopLists(pd)
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

    local weekSnap = periodSnapshots.week or {}
    local prevWeekSnap = periodSnapshots.prevWeek or {}
    local monthSnap = periodSnapshots.month or {}
    local healthScore = CalculateGuildHealth(weekSnap, prevWeekSnap, monthSnap, guildId)
    local healthLabel, healthColor = GetHealthLabel(healthScore)

    local kioskName = GetGuildOwnedKioskInfo(guildId) or gst.lastKioskName or ""

    sv.gstGuildSnapshots[guildId] = {
        guildName = guildName, scanTime = GetTimeStamp(),
        oldestSale = sd.oldestSale, newestSale = sd.newestSale,
        eventCount = gst.scanEventCount, kioskName = kioskName,
        healthScore = healthScore, healthLabel = healthLabel, healthColor = healthColor,
        month = periodSnapshots.month, prevWeek = periodSnapshots.prevWeek, week = periodSnapshots.week, day = periodSnapshots.day,
    }

    NWT.Debug("|c00FF00[GST]|r Snapshot saved for " .. guildName .. " (Health: " .. healthScore .. " - " .. healthLabel .. ")")
end

local function GST_SendNextRequest()
    local gst = NWT.GST
    if #gst.requestQueue == 0 or gst.activeRequest then return end

    local cooldownMs = GetGuildHistoryRequestMinCooldownMs() or 2000
    local now = GetGameTimeMilliseconds()
    if (now - gst.lastRequestTime) < cooldownMs then
        zo_callLater(GST_SendNextRequest, cooldownMs - (now - gst.lastRequestTime) + 100)
        return
    end

    gst.activeRequest = table.remove(gst.requestQueue, 1)
    if not gst.activeRequest or not gst.activeRequest.request:IsValid() then
        gst.activeRequest = nil
        GST_SendNextRequest()
        return
    end

    local state = gst.activeRequest.request:RequestMoreEvents(false)
    gst.lastRequestTime = GetGameTimeMilliseconds()

    if state == GUILD_HISTORY_DATA_READY_STATE_READY then
        gst.activeRequest.complete = true
        gst.activeRequest = nil
        GST_SendNextRequest()
    elseif state == GUILD_HISTORY_DATA_READY_STATE_ON_COOLDOWN then
        table.insert(gst.requestQueue, 1, gst.activeRequest)
        gst.activeRequest = nil
        zo_callLater(GST_SendNextRequest, cooldownMs + 100)
    end
end

function NWT.InitGuildSalesTracker()
    local numGuilds = GetNumGuilds()
    local sv = NWT.savedVars

    for i = 1, numGuilds do
        local guildId = GetGuildId(i)
        local guildName = GetGuildName(guildId) or ("Guild " .. i)
        sv.gstGuildNames[guildId] = guildName

        if sv.gstGuildEnabled[guildId] == nil then
            sv.gstGuildEnabled[guildId] = true
        end
    end
end

function NWT.ScanGuildBankGold(guildIndex)
    local guildId = GetGuildId(guildIndex)
    local guildName = GetGuildName(guildId) or ("Guild " .. guildIndex)
    local sv = NWT.savedVars

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

function NWT.ScanGuild(guildId)
    local gst = NWT.GST
    if gst.scanGuildId then
        NWT.Debug("|cFFFF00[GST]|r Already scanning. Please wait.")
        return
    end

    local sv = NWT.savedVars
    local guildName = sv.gstGuildNames[guildId] or GetGuildName(guildId) or ("Guild " .. guildId)
    sv.gstGuildNames[guildId] = guildName

    GC.ClearScanData()
    gst.scanGuildId = guildId
    gst.currentScanGuildId = guildId
    gst.scanComplete = false
    gst.bankEventCount = 0
    gst.requestQueue = {}
    gst.activeRequest = nil

    NWT.Debug("|cFFFF00[GST]|r Scanning " .. guildName .. "...")

    local now = GetTimeStamp()
    local traderRequest = ZO_GuildHistoryRequest:New(guildId, GUILD_HISTORY_EVENT_CATEGORY_TRADER, now, 0)
    local bankRequest = ZO_GuildHistoryRequest:New(guildId, GUILD_HISTORY_EVENT_CATEGORY_BANKED_CURRENCY, now, 0)

    local traderData = { request = traderRequest, complete = false, category = GUILD_HISTORY_EVENT_CATEGORY_TRADER }
    local bankData = { request = bankRequest, complete = false, category = GUILD_HISTORY_EVENT_CATEGORY_BANKED_CURRENCY }

    table.insert(gst.requestQueue, traderData)
    table.insert(gst.requestQueue, bankData)

    local lastTraderCount = GetNumGuildHistoryEvents(guildId, GUILD_HISTORY_EVENT_CATEGORY_TRADER)
    local lastBankCount = GetNumGuildHistoryEvents(guildId, GUILD_HISTORY_EVENT_CATEGORY_BANKED_CURRENCY)
    local stableCount, requestAttempts = 0, 0

    if not gst.categoryCallbackRegistered then
        gst.categoryCallbackRegistered = true
        GUILD_HISTORY_MANAGER:RegisterCallback("CategoryUpdated", function(categoryData)
            if not gst.currentScanGuildId then return end
            if categoryData:GetGuildData():GetId() ~= gst.currentScanGuildId then return end
            stableCount = 0
            if gst.activeRequest then
                if not gst.activeRequest.request:IsComplete() then table.insert(gst.requestQueue, gst.activeRequest)
                else gst.activeRequest.complete = true end
                gst.activeRequest = nil
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

        if not gst.activeRequest and #gst.requestQueue > 0 then GST_SendNextRequest() end

        local isDone = (traderData.complete and bankData.complete) or (numT > 0 and stableCount >= 10) or (requestAttempts >= 120)
        if isDone then
            EVENT_MANAGER:UnregisterForUpdate("ATK_WaitForHistory_" .. guildId)
            pcall(function() DestroyGuildHistoryRequest(traderRequest:GetRequestId()) end)
            pcall(function() DestroyGuildHistoryRequest(bankRequest:GetRequestId()) end)

            local processIndex = 1
            local sd = gst.scanData
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
                            if age <= p.seconds and age >= minAge then AddSaleToPeriod(sd[p.key], seller, buyer, itemId, itemName, qty or 1, price, tax or 0, GetDisplayName(), itemType) end
                        end
                        gst.scanEventCount = gst.scanEventCount + 1
                    end
                    processIndex, processed = processIndex + 1, processed + 1
                end

                if processIndex > numT then
                    local bankIdx = processIndex - numT
                    while bankIdx <= numB and processed < 100 do
                        local _, ts, redacted, evtType, depositor, _, amt, kiosk = GetGuildHistoryBankedCurrencyEventInfo(guildId, bankIdx)
                        if not redacted and amt and amt > 0 then
                            local age = GetTimeStamp() - (ts or GetTimeStamp())
                            if kiosk and kiosk ~= "" then gst.lastKioskName = kiosk end
                            for _, p in ipairs(TIME_PERIODS) do
                                local minAge = p.minAge or 0
                                if age <= p.seconds and age >= minAge then
                                    local pd = sd[p.key]
                                    if evtType == GUILD_HISTORY_BANKED_CURRENCY_EVENT_DEPOSITED then
                                        pd.deposits = (pd.deposits or 0) + amt
                                        if depositor and depositor ~= "" then
                                            if not pd.depositors then pd.depositors = {} end
                                            if not pd.depositors[depositor] then
                                                pd.depositors[depositor] = 0
                                                pd.depositorCount = (pd.depositorCount or 0) + 1
                                            end
                                            pd.depositors[depositor] = pd.depositors[depositor] + amt
                                        end
                                    elseif evtType == GUILD_HISTORY_BANKED_CURRENCY_EVENT_WITHDRAWN then pd.withdrawals = (pd.withdrawals or 0) + amt
                                    elseif evtType == GUILD_HISTORY_BANKED_CURRENCY_EVENT_KIOSK_BID then pd.kioskBids = (pd.kioskBids or 0) + amt
                                    end
                                end
                            end
                            gst.bankEventCount = gst.bankEventCount + 1
                        end
                        bankIdx, processIndex, processed = bankIdx + 1, processIndex + 1, processed + 1
                    end
                end

                if processIndex > numT + numB then
                    EVENT_MANAGER:UnregisterForUpdate("ATK_DirectScan_" .. guildId)
                    CreateGuildSnapshot(guildId)
                    GC.ClearScanData()
                    gst.scanGuildId = nil
                    gst.currentScanGuildId = nil
                    if NWT.UpdateGuildSalesUI then NWT.UpdateGuildSalesUI() end
                    if NWT.ShowReloadUIDialog then NWT.ShowReloadUIDialog(gst.scanEventCount) end
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
