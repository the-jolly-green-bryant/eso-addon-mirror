-- ============================================
-- GUILD SALES DASHBOARD UI
-- ============================================
-- UI/scene/view rendering split out of GSTEventProcessing.lua.

local math_floor = math.floor
local string_format = string.format

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
                    elseif elapsed < 86400 then age = "|cFFFF00" .. math_floor(elapsed / 3600) .. "h|r"
                    else age = "|cFF8888" .. math_floor(elapsed / 86400) .. "d|r" end
                else age = "|cFF0000--|r" end
                local name = GetGuildName(gId) or ("Guild " .. i)
                local isSelected = i == gsd.selectedGuildIndex
                lbl:SetText(isSelected and string_format("|cFFD700> %s|r %s", name, age) or string_format("  |c888888%s|r %s", name, age))
            else lbl:SetText("") end
        end
    end

    local instr = lp:GetNamedChild("Instructions")
    if instr then instr:SetText("|c888888[A] Scan|r") end

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

local function GetTrendIndicator(current, previous)
    if not previous or previous == 0 then return "-", "888888", 0 end
    local change = current - previous
    local pct = (change / previous) * 100
    if pct > 5 then return "+", "00FF00", pct
    elseif pct < -5 then return "-", "FF0000", pct
    else return "=", "FFFF00", pct end
end

local function FormatChange(current, previous, isGold)
    local arrow, color, pct = GetTrendIndicator(current, previous)
    local val = isGold and NWT.FormatGold(current) .. "g" or tostring(current)
    if previous and previous > 0 then
        return string_format("|c%s%s|r %s (|c%s%+.0f%%|r)", "00FF00", val, arrow, color, pct)
    end
    return "|c00FF00" .. val .. "|r"
end

local function TruncateText(text, maxLen)
    if not text then return "" end
    if #text <= maxLen then return text end
    return text:sub(1, maxLen - 2) .. ".."
end

local function FormatListEntry(rank, name, gold, count, countLabel, pct)
    local truncName = TruncateText(name or "Unknown", 16)
    return string_format("|cFFFFFF%2d.|r %-16s |c00FF00%sg|r",
        rank, truncName, NWT.FormatGold(gold or 0))
end

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
        local topCatName = "None"
        local topCats = p.topCategories or {}
        if topCats[1] then topCatName = topCats[1].name or "Unknown" end
        local bestSellerName = "None"
        local topSellers = p.topSellers or {}
        if topSellers[1] then bestSellerName = topSellers[1].name or "Unknown" end
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
        local grid = center:GetNamedChild("StatsGrid")
        if grid then
            local sales = grid:GetNamedChild("Sales") if sales then sales:SetText(string_format("|cFFD700VOLUME|r")) end
            local volume = grid:GetNamedChild("Volume") if volume then volume:SetText(string_format("|cFFFFFF%d|r sales", p.totalSales or 0)) end
            local members = grid:GetNamedChild("Members") if members then members:SetText(string_format("|c00FF00%sg|r total", NWT.FormatGold(p.totalGold or 0))) end
            local sellers = grid:GetNamedChild("Sellers") if sellers then sellers:SetText(string_format("|cFFD700AVERAGES|r")) end
            local avgPrice = grid:GetNamedChild("AvgPrice") if avgPrice then avgPrice:SetText(string_format("|c00FF00%sg|r/sale", NWT.FormatGold(avgSale))) end
            local velocity = grid:GetNamedChild("Velocity") if velocity then velocity:SetText(string_format("|cFFFFFF%d|r sales/day", dailySales)) end
            local tax = grid:GetNamedChild("Tax") if tax then tax:SetText(string_format("|cFFD700PARTICIPATION|r")) end
            local weeklyTax = grid:GetNamedChild("WeeklyTax") if weeklyTax then weeklyTax:SetText(string_format("|c88FF88%d|r sellers (%s)", uniqueSellers, sellerPct)) end
            local traderCost = grid:GetNamedChild("TraderCost") if traderCost then traderCost:SetText(string_format("|c88FF88%d|r buyers", p.uniqueBuyers or 0)) end
            local profit = grid:GetNamedChild("Profit") if profit then profit:SetText(string_format("|cFFD700FINANCIALS|r")) end
            local weeklyProfit = grid:GetNamedChild("WeeklyProfit") if weeklyProfit then weeklyProfit:SetText(string_format("|c00FF00%sg|r tax", NWT.FormatGold(p.totalTax or 0))) end
            local change = grid:GetNamedChild("Change") if change then change:SetText(string_format("%s%sg|r bank", net >= 0 and "|c00FF00+" or "|cFF0000", NWT.FormatGold(net))) end
        end
        UpdateListHeader(center, "|cFFD700GUILD OVERVIEW|r")
        local sellersList = center:GetNamedChild("SellersList")
        if sellersList then
            local lines = {
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
                if sellerLabel then sellerLabel:SetText(lines[j] or "") end
            end
        end
    end
    NWT.UpdateGSTRightPanel(container, "overview", g)
end

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
            if a2 then a2:SetText(cats[1] and string_format("   |c00FF00%.0f%%|r of sales", (cats[1].gold / total) * 100) or "") end
            if a3 then a3:SetText(cats[2] and string_format("|cC0C0C02.|r %s", TruncateText(cats[2].name, 13)) or "") end
            if a4 then a4:SetText(cats[2] and string_format("   |c888888%.0f%%|r of sales", (cats[2].gold / total) * 100) or "") end
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
                cats[1] and string_format("|c00FF00%.0f%%|r of all gold", (cats[1].gold / total) * 100) or "",
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
        local grid = center:GetNamedChild("StatsGrid")
        if grid then
            local avgPerSeller = uniqueSellers > 0 and math_floor(totalGold / uniqueSellers) or 0
            local sales = grid:GetNamedChild("Sales") if sales then sales:SetText(string_format("|cFFFFAATotal Volume:|r |c00FF00%sg|r", NWT.FormatGold(totalGold))) end
            local volume = grid:GetNamedChild("Volume") if volume then volume:SetText(string_format("|cFFFFAASellers:|r %d", uniqueSellers)) end
            local members = grid:GetNamedChild("Members") if members then members:SetText(string_format("|cFFFFAAAvg/Seller:|r |c00FF00%sg|r", NWT.FormatGold(avgPerSeller))) end
            for _, f in ipairs({"Sellers", "AvgPrice", "Velocity", "Tax", "WeeklyTax", "TraderCost", "Profit", "WeeklyProfit", "Change"}) do local l = grid:GetNamedChild(f) if l then l:SetText("") end end
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
        local grid = center:GetNamedChild("StatsGrid")
        if grid then
            local avgPerItem = uniqueItems > 0 and math_floor(totalGold / uniqueItems) or 0
            local sales = grid:GetNamedChild("Sales") if sales then sales:SetText(string_format("|cFFFFAATotal Volume:|r |c00FF00%sg|r", NWT.FormatGold(totalGold))) end
            local volume = grid:GetNamedChild("Volume") if volume then volume:SetText(string_format("|cFFFFAAUnique Items:|r %d", uniqueItems)) end
            local members = grid:GetNamedChild("Members") if members then members:SetText(string_format("|cFFFFAAAvg/Item:|r |c00FF00%sg|r", NWT.FormatGold(avgPerItem))) end
            for _, f in ipairs({"Sellers", "AvgPrice", "Velocity", "Tax", "WeeklyTax", "TraderCost", "Profit", "WeeklyProfit", "Change"}) do local l = grid:GetNamedChild(f) if l then l:SetText("") end end
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
            for _, f in ipairs({"Sellers", "AvgPrice", "Velocity", "Tax", "WeeklyTax", "TraderCost", "Profit", "WeeklyProfit", "Change"}) do local l = grid:GetNamedChild(f) if l then l:SetText("") end end
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
            local sales = grid:GetNamedChild("Sales") if sales then sales:SetText(string_format("|cFFFFAATotal Volume:|r |c00FF00%sg|r", NWT.FormatGold(totalGold))) end
            local volume = grid:GetNamedChild("Volume") if volume then volume:SetText(string_format("|cFFFFAACategories:|r %d", uniqueCategories)) end
            local members = grid:GetNamedChild("Members") if members then members:SetText(string_format("|cFFFFAATop:|r %s", topCatName)) end
            for _, f in ipairs({"Sellers", "AvgPrice", "Velocity", "Tax", "WeeklyTax", "TraderCost", "Profit", "WeeklyProfit", "Change"}) do local l = grid:GetNamedChild(f) if l then l:SetText("") end end
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
            local sales = grid:GetNamedChild("Sales") if sales then sales:SetText(string_format("|c00FF00THIS WEEK|r")) end
            local volume = grid:GetNamedChild("Volume") if volume then volume:SetText(string_format("|cFFFFAA%d sales|r", wSales)) end
            local members = grid:GetNamedChild("Members") if members then members:SetText(string_format("|c00FF00%sg|r", NWT.FormatGold(wGold))) end
            local sellers = grid:GetNamedChild("Sellers") if sellers then sellers:SetText(string_format("|c888888LAST WEEK|r")) end
            local avgPrice = grid:GetNamedChild("AvgPrice") if avgPrice then avgPrice:SetText(string_format("|c888888%d sales|r", pwSales)) end
            local velocity = grid:GetNamedChild("Velocity") if velocity then velocity:SetText(string_format("|c888888%sg|r", NWT.FormatGold(pwGold))) end
            local tax = grid:GetNamedChild("Tax") if tax then tax:SetText(string_format("|cFFFFAACHANGE|r")) end
            local weeklyTax = grid:GetNamedChild("WeeklyTax") if weeklyTax then weeklyTax:SetText(string_format("|c%s%s %.0f%% sales|r", sColor, sArrow, salesChange)) end
            local traderCost = grid:GetNamedChild("TraderCost") if traderCost then traderCost:SetText(string_format("|c%s%s %.0f%% gold|r", gColor, gArrow, goldChange)) end
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
            local guildGold = p.totalGold or 0
            local myShare = guildGold > 0 and (myGold / guildGold) * 100 or 0
            local tax = grid:GetNamedChild("Tax") if tax then tax:SetText(string_format("|cFFFFAAGuild Total:|r |c00FF00%sg|r", NWT.FormatGold(guildGold))) end
            local weeklyTax = grid:GetNamedChild("WeeklyTax") if weeklyTax then weeklyTax:SetText(string_format("|cFFFFAAMy Share:|r |c00FF00%.1f%%|r", myShare)) end
            local traderCost = grid:GetNamedChild("TraderCost") if traderCost then traderCost:SetText(string_format("|cFFFFAAGuild Sales:|r %d", p.totalSales or 0)) end
            for _, f in ipairs({"Profit", "WeeklyProfit", "Change"}) do local l = grid:GetNamedChild(f) if l then l:SetText("") end end
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
        local grid = center:GetNamedChild("StatsGrid")
        if grid then
            local avgPerBuyer = uniqueBuyers > 0 and math_floor(totalGold / uniqueBuyers) or 0
            local sales = grid:GetNamedChild("Sales") if sales then sales:SetText(string_format("|cFFFFAATotal Spent:|r |c00FF00%sg|r", NWT.FormatGold(totalGold))) end
            local volume = grid:GetNamedChild("Volume") if volume then volume:SetText(string_format("|cFFFFAABuyers:|r %d", uniqueBuyers)) end
            local members = grid:GetNamedChild("Members") if members then members:SetText(string_format("|cFFFFAAAvg/Buyer:|r |c00FF00%sg|r", NWT.FormatGold(avgPerBuyer))) end
            for _, f in ipairs({"Sellers", "AvgPrice", "Velocity", "Tax", "WeeklyTax", "TraderCost", "Profit", "WeeklyProfit", "Change"}) do local l = grid:GetNamedChild(f) if l then l:SetText("") end end
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
