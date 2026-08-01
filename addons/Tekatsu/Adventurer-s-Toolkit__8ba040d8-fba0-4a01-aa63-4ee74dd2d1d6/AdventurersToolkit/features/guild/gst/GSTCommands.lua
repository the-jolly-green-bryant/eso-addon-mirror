-- ============================================
-- GST CHAT / SLASH COMMAND HANDLERS
-- ============================================
-- All /gst subcommands and chat report functions.

local math_floor = math.floor
local string_format = string.format
local GetTimeStamp = GetTimeStamp
local GetNumGuildMembers = GetNumGuildMembers
local GetGuildMemberInfo = GetGuildMemberInfo
local GetNumGuilds = GetNumGuilds
local GetGuildId = GetGuildId
local GetGuildName = GetGuildName

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
            NWT.Debug(sCol .. "Sales: " .. (salesChange >= 0 and "↑" or "↓") .. " " .. string_format("%.1f%%", math.abs(salesChange)) .. "|r")
            NWT.Debug(gCol .. "Volume: " .. (goldChange >= 0 and "↑" or "↓") .. " " .. string_format("%.1f%%", math.abs(goldChange)) .. "|r")
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

local function ProcessStatsDisplay()
    local gst = NWT.GST
    if gst.displayIndex > #gst.displayQueue then return end
    for _ = 1, 3 do
        if gst.displayIndex <= #gst.displayQueue then NWT.Debug(gst.displayQueue[gst.displayIndex]) gst.displayIndex = gst.displayIndex + 1 end
    end
    if gst.displayIndex <= #gst.displayQueue then zo_callLater(ProcessStatsDisplay, 10) end
end

function NWT.ShowGuildSalesStats()
    local gst = NWT.GST
    gst.displayQueue, gst.displayIndex = {}, 1
    table.insert(gst.displayQueue, "|c00FF00========== GUILD SALES TRACKER ==========|r")
    local format = NWT.FormatGold
    local oldest = NWT.FormatTimestamp(NWT.savedVars.gstOldestSale)
    local newest = NWT.FormatTimestamp(NWT.savedVars.gstNewestSale)
    table.insert(gst.displayQueue, "|cAAAAAAData: " .. oldest .. " to " .. newest .. " (" .. (NWT.savedVars.gstTotalEvents or 0) .. " sales)|r")
    table.insert(gst.displayQueue, "|cFFFF00MY SALES:|r " .. (NWT.savedVars.gstMySales or 0) .. " sales | " .. format(NWT.savedVars.gstMyGold or 0) .. "g earned")

    local topItems = {}
    for _, data in pairs(NWT.sessionData.gstSales or {}) do
        table.insert(topItems, { name = data.name, sold = data.totalSold, gold = data.totalGold })
    end
    table.sort(topItems, function(a, b) return a.gold > b.gold end)
    table.insert(gst.displayQueue, "|cFFFF00TOP ITEMS (all guilds):|r")
    for i = 1, math.min(5, #topItems) do
        local it = topItems[i]
        table.insert(gst.displayQueue, "  " .. i .. ". " .. it.name .. " x" .. it.sold .. " = " .. format(it.gold) .. "g")
    end
    table.insert(gst.displayQueue, "|c00FF00==========================================|r")
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
    local gst = NWT.GST
    if gst.loadingGuilds then NWT.Debug("|cFFFF00[GST]|r Already loading history...") return end
    gst.loadingGuilds = true
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
    zo_callLater(function()
        for _, rId in ipairs(requests) do
            pcall(function() DestroyGuildHistoryRequest(rId) end)
        end
        gst.loadingGuilds = false
        NWT.Debug("|c00FF00[GST]|r History requests completed and cleaned up!")
    end, 5000)
end
