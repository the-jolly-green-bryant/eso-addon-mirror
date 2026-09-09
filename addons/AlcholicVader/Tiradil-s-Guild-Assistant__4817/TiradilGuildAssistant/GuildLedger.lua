
GuildLedger = GuildLedger or {}
local GL = GuildLedger
GL.name = "GuildLedger"

GL.selectedGuildIndex = 1
GL.selectedTimeframe = "week" -- 'week', 'last_week', 'week_before_last', '3_weeks_ago', '4_weeks_ago', 'last_month', '2_weeks', '30'

GL.bankEvents = {}   -- GL.bankEvents[guildIndex] = { {time=, type=, amount=, kioskName=}, ... }
GL.traderEvents = {} -- GL.traderEvents[guildIndex] = { {time=, price=, tax=}, ... }
GL.guildNames = {}   -- GL.guildNames[guildIndex] = "Guild Adi"

local REFUND_SYNC_GRACE = 45 * 60 -- reset sonrasi refund'un gelmesi icin guvenlik payi

local function GetNextResetAfterTime(t)
    local utc = os.date("!*t", t)
    local midnightUTC = t - (utc.hour * 3600 + utc.min * 60 + utc.sec)
    local daysSinceTuesday = (utc.wday - 3) % 7
    local tuesdayMidnightUTC = midnightUTC - daysSinceTuesday * 86400
    local resetEpoch = tuesdayMidnightUTC + 14 * 3600 -- Sali 14:00 UTC (17:00 TR)
    if resetEpoch <= t then
        resetEpoch = resetEpoch + 7 * 86400
    end
    return resetEpoch
end

local function GetPrevResetAtOrBeforeTime(t)
    return GetNextResetAfterTime(t) - 7 * 86400
end

local function GetConfirmedWonBids(bankList)
    local now = os.time()

    local positions = {} -- positions["<cycle>|<name>"] = { amount, firstBidTime, lastBidTime, cycle, name }
    local order = {}
    for i = 1, #bankList do
        local e = bankList[i]
        if e.type == GUILD_HISTORY_BANKED_CURRENCY_EVENT_KIOSK_BID then
            local name = e.kioskName or "?"
            local cycle = GetNextResetAfterTime(e.time)
            local key = cycle .. "|" .. name
            local pos = positions[key]
            if not pos then
                pos = { amount = 0, firstBidTime = e.time, lastBidTime = e.time, cycle = cycle, name = name }
                positions[key] = pos
                table.insert(order, key)
            end
            pos.amount = pos.amount + e.amount
            if e.time < pos.firstBidTime then pos.firstBidTime = e.time end
            if e.time > pos.lastBidTime then pos.lastBidTime = e.time end
        end
    end

    local refundedInCycle = {} -- refundedInCycle["<cycle>|<name>"] = true
    for i = 1, #bankList do
        local e = bankList[i]
        if e.type == GUILD_HISTORY_BANKED_CURRENCY_EVENT_KIOSK_BID_REFUND then
            local name = e.kioskName or "?"
            local cycle = GetPrevResetAtOrBeforeTime(e.time)
            refundedInCycle[cycle .. "|" .. name] = true
        end
    end

    local won = {}
    local pendingTotal = 0
    for _, key in ipairs(order) do
        local pos = positions[key]
        if not refundedInCycle[key] then
            local confirmedAt = pos.cycle + REFUND_SYNC_GRACE
            if now >= confirmedAt then
                table.insert(won, {
                    time = pos.firstBidTime,
                    amount = pos.amount,
                    kioskName = pos.name,
                    confirmedAt = confirmedAt,
                    periodTime = pos.cycle,
                })
            else
                -- Henuz reset+guvenlik payi gecmemis - kazanip kazanmadigi
                -- belli degil, halen guild bankasindan dusulmus durumda.
                pendingTotal = pendingTotal + pos.amount
            end
        end
    end

    return won, pendingTotal
end

local TEXT_ROW_TYPE = 1
local TEXT_ROW_HEIGHT = 20

local function SetupTextRow(control, data)
    control:GetNamedChild("Label"):SetText(data.text)
end

local function InitializeTextList(listControl, templateName, rowHeight)
    if not listControl then return end
    templateName = templateName or "GuildLedgerTextRowTemplate"
    rowHeight = rowHeight or TEXT_ROW_HEIGHT
    ZO_ScrollList_AddDataType(listControl, TEXT_ROW_TYPE, templateName, rowHeight, SetupTextRow)
end

local function PopulateTextList(listControl, lines)
    if not listControl then return end
    local dataList = ZO_ScrollList_GetDataList(listControl)
    for i = #dataList, 1, -1 do
        dataList[i] = nil
    end
    for i = 1, #lines do
        table.insert(dataList, ZO_ScrollList_CreateDataEntry(TEXT_ROW_TYPE, { text = lines[i] }))
    end
    ZO_ScrollList_Commit(listControl)
end

local RANK_TIERS = {
    { key = "Row1", name = "Legend",  color = "FF4444" },
    { key = "Row2", name = "Diamond", color = "66CCFF" },
    { key = "Row3", name = "Gold",    color = "FFB800" },
    { key = "Row4", name = "Silver",  color = "C0C0C0" },
    { key = "Row5", name = "Bronze",  color = "CD7F32" },
}
GL.rankTiers = RANK_TIERS

function GL.GetTierName(guildIndex, tierIndex)
    local settings = GL.savedVars and GL.savedVars.rankSettings and GL.savedVars.rankSettings[guildIndex]
    local custom = settings and settings[tierIndex] and settings[tierIndex].name
    if custom and custom ~= "" then
        return custom
    end
    return RANK_TIERS[tierIndex].name
end

local DEFAULT_RANK_SETTINGS = {
    { salesThreshold = 6000000, donationThreshold = 200000 }, -- Legend
    { salesThreshold = 5000000, donationThreshold = 100000 }, -- Diamond
    { salesThreshold = 1500000, donationThreshold = 60000 },  -- Gold
    { salesThreshold = 750000,  donationThreshold = 30000 },  -- Silver
    { salesThreshold = 400000,  donationThreshold = 15000 },  -- Bronze
}

local function NormalizeDisplayName(name)
    if not name then return "" end
    if name:sub(1, 1) == "@" then
        return name:sub(2)
    end
    return name
end

local function FormatGold(amount)
    local formatted = tostring(math.floor(math.abs(amount)))
    local k
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    if amount < 0 then
        return "-" .. formatted .. " Gold"
    else
        return formatted .. " Gold"
    end
end

local function FormatGoldSigned(amount)
    if amount > 0 then
        return "+" .. FormatGold(amount)
    else
        return FormatGold(amount)
    end
end

local function FormatGoldIcon(amount, iconSize)
    iconSize = iconSize or 14
    local formatted = tostring(math.floor(math.abs(amount)))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return "|cFFB800" .. formatted .. " |t" .. iconSize .. ":" .. iconSize .. ":EsoUI/Art/currency/currency_gold.dds|t|r"
end

local function GetThisWeekStartEpoch()
    local nowEpoch = os.time()
    local utc = os.date("!*t", nowEpoch)
    local midnightUTC = nowEpoch - (utc.hour * 3600 + utc.min * 60 + utc.sec)
    local daysSinceTuesday = (utc.wday - 3) % 7
    local tuesdayMidnightUTC = midnightUTC - daysSinceTuesday * 86400
    local resetEpoch = tuesdayMidnightUTC + 14 * 3600 -- 17:00 TR (UTC+3) = 14:00 UTC
    if resetEpoch > nowEpoch then
        resetEpoch = resetEpoch - 7 * 86400
    end
    return resetEpoch
end

function GL.GetPeriodLabelFor(timeframe)
    if timeframe == "week" then return TiradilL10n.Get("PERIOD_THIS_WEEK")
    elseif timeframe == "last_week" then return TiradilL10n.Get("PERIOD_LAST_WEEK")
    elseif timeframe == "week_before_last" then return TiradilL10n.Get("PERIOD_2_WEEKS_AGO")
    elseif timeframe == "3_weeks_ago" then return TiradilL10n.Get("PERIOD_3_WEEKS_AGO")
    elseif timeframe == "4_weeks_ago" then return TiradilL10n.Get("PERIOD_4_WEEKS_AGO")
    elseif timeframe == "last_month" then return TiradilL10n.Get("PERIOD_LAST_MONTH")
    elseif timeframe == "this_month" then return TiradilL10n.Get("PERIOD_THIS_MONTH")
    elseif timeframe == "last_30_days" then return TiradilL10n.Get("PERIOD_LAST_30_DAYS")
    elseif timeframe == "all_time" then return TiradilL10n.Get("PERIOD_ALL_TIME")
    else return TiradilL10n.Get("PERIOD_THIS_MONTH")
    end
end

local function GetPeriodLabel()
    return GL.GetPeriodLabelFor(GL.selectedTimeframe)
end

local function GetSelectedGuildLabel()
    local guildId = GetGuildId(GL.selectedGuildIndex)
    local name = guildId and GetGuildName(guildId)
    if not name or name == "" then
        return "Guild " .. tostring(GL.selectedGuildIndex)
    end
    return name
end

function GL.UpdatePanelTitles()
    local periodLabel = GetPeriodLabel()
    local guildLabel = GetSelectedGuildLabel()

    if GuildLedgerFrameBodyDonationsPanelTitle then
        if GL.searchFilter then
            GuildLedgerFrameBodyDonationsPanelTitle:SetText(
                string.format("%s: %s (%s)", TiradilL10n.Get("SEARCH_FILTER_ACTIVE"), GL.searchFilter, periodLabel))
        else
            GuildLedgerFrameBodyDonationsPanelTitle:SetText(
                string.format("%s (%s)", TiradilL10n.Get("PANEL_DONORS_SELLERS_BASE"), periodLabel))
        end
    end
    if GuildLedgerFrameBodyBidsPanelTitle then
        GuildLedgerFrameBodyBidsPanelTitle:SetText(
            string.format("%s (%s)", TiradilL10n.Get("PANEL_BIDS_BASE"), periodLabel))
    end
    if GuildLedgerFrameRanksPanelTitle then
        GuildLedgerFrameRanksPanelTitle:SetText(
            string.format("%s (%s, %s)", TiradilL10n.Get("PANEL_RANKS_BASE"), guildLabel, periodLabel))
    end
end

function GL.GetTimeframeRangeFor(timeframe)
    local now = os.time()
    local minTime, maxTime = 0, now + 86400 -- Guvenlik icin yarin

    if timeframe == "week" then
        minTime = GetThisWeekStartEpoch()

    elseif timeframe == "last_week" then
        local thisWeekStart = GetThisWeekStartEpoch()
        minTime = thisWeekStart - (7 * 86400)
        maxTime = thisWeekStart

    elseif timeframe == "week_before_last" then
        local thisWeekStart = GetThisWeekStartEpoch()
        minTime = thisWeekStart - (14 * 86400)
        maxTime = thisWeekStart - (7 * 86400)

    elseif timeframe == "3_weeks_ago" then
        local thisWeekStart = GetThisWeekStartEpoch()
        minTime = thisWeekStart - (21 * 86400)
        maxTime = thisWeekStart - (14 * 86400)

    elseif timeframe == "4_weeks_ago" then
        local thisWeekStart = GetThisWeekStartEpoch()
        minTime = thisWeekStart - (28 * 86400)
        maxTime = thisWeekStart - (21 * 86400)

    elseif timeframe == "last_month" then
        local dateTbl = os.date("!*t", now) -- Mevcut UTC tarihi
        local currentYear = dateTbl.year
        local currentMonth = dateTbl.month

        local prevMonth = currentMonth - 1
        local prevYear = currentYear
        if prevMonth == 0 then
            prevMonth = 12
            prevYear = currentYear - 1
        end

        local secondsIntoCurrentMonth = ((dateTbl.day - 1) * 86400) + (dateTbl.hour * 3600) + (dateTbl.min * 60) + dateTbl.sec
        local startOfCurrentMonth = now - secondsIntoCurrentMonth

        local daysInPrevMonth = 31
        if prevMonth == 4 or prevMonth == 6 or prevMonth == 9 or prevMonth == 11 then
            daysInPrevMonth = 30
        elseif prevMonth == 2 then
            local isLeap = (prevYear % 4 == 0 and prevYear % 100 ~= 0) or (prevYear % 400 == 0)
            daysInPrevMonth = isLeap and 29 or 28
        end

        minTime = startOfCurrentMonth - (daysInPrevMonth * 86400)
        maxTime = startOfCurrentMonth

    elseif timeframe == "this_month" then
        local dateTbl = os.date("!*t", now) -- Mevcut UTC tarihi
        local secondsIntoCurrentMonth = ((dateTbl.day - 1) * 86400) + (dateTbl.hour * 3600) + (dateTbl.min * 60) + dateTbl.sec
        minTime = now - secondsIntoCurrentMonth

    elseif timeframe == "last_30_days" then
        minTime = now - (30 * 86400)

    elseif timeframe == "all_time" then
        minTime = 0

    else
        local days = tonumber(timeframe) or 30
        minTime = now - (days * 86400)
    end

    return minTime, maxTime
end

local function GetTimeframeRange()
    return GL.GetTimeframeRangeFor(GL.selectedTimeframe)
end

local function GetEUDstInfo()
    local now = os.time()
    local utc = os.date("!*t", now)
    local midnightUTC = now - (utc.hour * 3600 + utc.min * 60 + utc.sec)
    local year = utc.year

    local function DaysInMonth(m, y)
        local d = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
        if m == 2 and ((y % 4 == 0 and y % 100 ~= 0) or y % 400 == 0) then
            return 29
        end
        return d[m]
    end

    local function EpochForMonthDay(m, d)
        local daysFromJan1 = 0
        for mm = 1, m - 1 do
            daysFromJan1 = daysFromJan1 + DaysInMonth(mm, year)
        end
        daysFromJan1 = daysFromJan1 + (d - 1)
        local currentDaysFromJan1 = utc.yday - 1
        local dayDiff = daysFromJan1 - currentDaysFromJan1
        return midnightUTC + dayDiff * 86400
    end

    local marchLast = EpochForMonthDay(3, 31)
    local marchLastWday = tonumber(os.date("!%w", marchLast)) -- 0=Pazar
    local dstStart = marchLast - (marchLastWday * 86400) + 3600 -- o Pazar 01:00 UTC

    local octLast = EpochForMonthDay(10, 31)
    local octLastWday = tonumber(os.date("!%w", octLast))
    local dstEnd = octLast - (octLastWday * 86400) + 3600 -- o Pazar 01:00 UTC

    if now >= dstStart and now < dstEnd then
        return 2, "CEST" -- yaz saati
    else
        return 1, "CET" -- kis saati
    end
end

local function GetResetTimeLabel()
    local lang = (GuildLedger_SavedVars and GuildLedger_SavedVars.language) or "en"
    if lang == "tr" then
        return "17:00 TR"
    end
    local offsetHours, zoneName = GetEUDstInfo()
    local resetHourUTC = 14
    local localHour = (resetHourUTC + offsetHours) % 24
    return string.format("%02d:00 %s", localHour, zoneName)
end

function GL.Initialize()
    GuildLedger_SavedVars = GuildLedger_SavedVars or {
        selectedGuildIndex = 1,
        selectedTimeframe = "week",
        bankCache = {}
    }
    GL.savedVars = GuildLedger_SavedVars
    GL.savedVars.bankCache = GL.savedVars.bankCache or {}
    GL.savedVars.personalNotes = GL.savedVars.personalNotes or {}
    GL.selectedGuildIndex = GL.savedVars.selectedGuildIndex or 1
    GL.selectedTimeframe = GL.savedVars.selectedTimeframe or "week"
    GL.trackingStartedAt = os.time()
    if GL.savedVars.screenNotifications == nil then
        GL.savedVars.screenNotifications = true -- varsayilan: acik
    end
    if GL.selectedTimeframe == 7 or GL.selectedTimeframe == "7" then
        GL.selectedTimeframe = "week"
    elseif GL.selectedTimeframe == 14 or GL.selectedTimeframe == "14" then
        GL.selectedTimeframe = "week_before_last"
    elseif GL.selectedTimeframe == 30 or GL.selectedTimeframe == "30" then
        GL.selectedTimeframe = "this_month"
    elseif GL.selectedTimeframe == "2_weeks" then
        GL.selectedTimeframe = "week"
    end
    GL.savedVars.selectedTimeframe = GL.selectedTimeframe

    if GL.savedVars.rankSettings and GL.savedVars.rankSettings[1] and GL.savedVars.rankSettings[1].salesThreshold ~= nil then
        GL.savedVars.rankSettings = { [1] = GL.savedVars.rankSettings }
    end
    GL.savedVars.rankSettings = GL.savedVars.rankSettings or {}
    for g = 1, 5 do
        if not GL.savedVars.rankSettings[g] then
            GL.savedVars.rankSettings[g] = {}
            for i = 1, 5 do
                GL.savedVars.rankSettings[g][i] = {
                    salesThreshold = DEFAULT_RANK_SETTINGS[i].salesThreshold,
                    donationThreshold = DEFAULT_RANK_SETTINGS[i].donationThreshold,
                }
            end
        end
        if GL.savedVars.rankSettings[g][1] and GL.savedVars.rankSettings[g][1].legendMode == nil then
            GL.savedVars.rankSettings[g][1].legendMode = "threshold"
        end
        if GL.savedVars.rankSettings[g][1] and GL.savedVars.rankSettings[g][1].legendTopSellersCount == nil then
            GL.savedVars.rankSettings[g][1].legendTopSellersCount = 3
        end
        if GL.savedVars.rankSettings[g][1] and GL.savedVars.rankSettings[g][1].legendTopDonorsCount == nil then
            GL.savedVars.rankSettings[g][1].legendTopDonorsCount = 3
        end
        for i = 1, 5 do
            if GL.savedVars.rankSettings[g][i] and GL.savedVars.rankSettings[g][i].name == nil then
                GL.savedVars.rankSettings[g][i].name = RANK_TIERS[i].name
            end
        end
        if GL.savedVars.rankSettings[g].kickThresholdDays == nil then
            GL.savedVars.rankSettings[g].kickThresholdDays = 14
        end
    end
    GL.settingsGuildIndex = GL.settingsGuildIndex or 1
    if GL.savedVars.language == nil then
        local ok, clientLang = pcall(GetCVar, "Language.2")
        if ok and (clientLang == "de" or clientLang == "ru") then
            GL.savedVars.language = clientLang
        else
            GL.savedVars.language = "en"
        end
    end

    GL.SetupUI()
    GL.RegisterLAMSettings()
    
    SLASH_COMMANDS["/ledger"] = function() GL.ToggleUI() end
    SLASH_COMMANDS["/gl"] = function() GL.ToggleUI() end
    SLASH_COMMANDS["/guildledger"] = function() GL.ToggleUI() end

    GL.TryStartTracking()
end

function GL.SetupUI()
    local frame = GuildLedgerFrame
    if not frame then return end

    InitializeTextList(GuildLedgerFrameBodyDonationsPanelDonorsList, "GuildLedgerTextRowTemplateLarge", 26)
    InitializeTextList(GuildLedgerFrameBodyDonationsPanelSellersList, "GuildLedgerTextRowTemplateLarge", 26)
    InitializeTextList(GuildLedgerFrameBodyBidsPanelList)
    InitializeTextList(GuildLedgerFrameKiosksPanelList)
    InitializeTextList(GuildLedgerFrameRanksPanelList, "GuildLedgerTextRowTemplateLarge", 26)
    InitializeTextList(GuildLedgerFrameSearchPanelList, "GuildLedgerTextRowTemplateLarge", 22)

    local headerClose = GuildLedgerFrameHeaderCloseBtn
    if headerClose then
        headerClose:SetHandler("OnClicked", function() GL.ToggleUI() end)
    end

    GL.BuildPeriodCombo()
    GL.BuildGuildCombo()

    local refreshBtn = GuildLedgerFrameFooterRefreshBtn
    if refreshBtn then
        refreshBtn:SetHandler("OnClicked", function() GL.RefreshData() end)
    end

    local kiosksBtn = GuildLedgerFrameFooterKiosksBtn
    if kiosksBtn then
        kiosksBtn:SetHandler("OnClicked", function() GL.ToggleKiosks() end)
    end

    local ranksBtn = GuildLedgerFrameFooterRanksBtn
    if ranksBtn then
        ranksBtn:SetHandler("OnClicked", function() GL.ToggleRanks() end)
    end

    local searchBtn = GuildLedgerFrameFooterSearchBtn
    if searchBtn then
        searchBtn:SetHandler("OnClicked", function() GL.ToggleSearchPanel() end)
    end
    GL.BuildSearchPanelControls()
end

function GuildLedger.RebuildCombos()
    if GuildLedgerFrameFilterAreaPeriodCombo then
        GL.BuildPeriodCombo()
    end
end

function GL.BuildPeriodCombo()
    local parent = GuildLedgerFrameFilterArea
    if not parent then return end

    local combo = GetControl("GuildLedgerFrameFilterAreaPeriodCombo")
    if not combo then
        combo = CreateControlFromVirtual("GuildLedgerFrameFilterAreaPeriodCombo", parent, "ZO_ComboBox")
    end
    combo:SetDimensions(160, 28)
    combo:ClearAnchors()
    combo:SetAnchor(TOPLEFT, parent, TOPLEFT, 505, 2)

    local comboObj = ZO_ComboBox_ObjectFromContainer(combo)
    comboObj:SetSortsItems(false)
    comboObj:ClearItems()

    local options = {
        { name = TiradilL10n.Get("PERIOD_THIS_WEEK"), value = "week" },
        { name = TiradilL10n.Get("PERIOD_LAST_WEEK"), value = "last_week" },
        { name = TiradilL10n.Get("PERIOD_2_WEEKS_AGO"), value = "week_before_last" },
        { name = TiradilL10n.Get("PERIOD_3_WEEKS_AGO"), value = "3_weeks_ago" },
        { name = TiradilL10n.Get("PERIOD_4_WEEKS_AGO"), value = "4_weeks_ago" },
        { name = TiradilL10n.Get("PERIOD_LAST_MONTH"), value = "last_month" },
        { name = TiradilL10n.Get("PERIOD_THIS_MONTH"), value = "this_month" },
        { name = TiradilL10n.Get("PERIOD_LAST_30_DAYS"), value = "last_30_days" },
    }

    local selectedEntry = nil
    for _, opt in ipairs(options) do
        local entry = comboObj:CreateItemEntry(opt.name, function()
            GL.SetTimeframe(opt.value)
        end)
        comboObj:AddItem(entry)
        if opt.value == GL.selectedTimeframe then
            selectedEntry = entry
        end
    end

    if selectedEntry then
        comboObj:SelectItem(selectedEntry, false)
    end
end

function GL.BuildGuildCombo()
    local parent = GuildLedgerFrameFilterArea
    if not parent then return end

    local combo = GetControl("GuildLedgerFrameFilterAreaGuildCombo")
    if not combo then
        combo = CreateControlFromVirtual("GuildLedgerFrameFilterAreaGuildCombo", parent, "ZO_ComboBox")
    end
    combo:SetDimensions(230, 28)
    combo:ClearAnchors()
    combo:SetAnchor(TOPLEFT, parent, TOPLEFT, 255, 2)

    local comboObj = ZO_ComboBox_ObjectFromContainer(combo)
    comboObj:SetSortsItems(false)
    comboObj:ClearItems()

    local numGuilds = GetNumGuilds()
    local selectedEntry = nil
    for i = 1, numGuilds do
        local guildId = GetGuildId(i)
        local guildName = GetGuildName(guildId)
        if not guildName or guildName == "" then
            guildName = "Guild " .. i
        end

        local entry = comboObj:CreateItemEntry(guildName, function()
            GL.SelectGuild(i)
        end)
        comboObj:AddItem(entry)
        if i == GL.selectedGuildIndex then
            selectedEntry = entry
        end
    end

    if selectedEntry then
        comboObj:SelectItem(selectedEntry, false)
    end
end

function GL.ShowPanel(panelName)
    local body = GuildLedgerFrameBody
    local kiosks = GuildLedgerFrameKiosksPanel
    local ranks = GuildLedgerFrameRanksPanel
    local search = GuildLedgerFrameSearchPanel
    if not body or not kiosks or not ranks then return end

    body:SetHidden(panelName ~= "body")
    kiosks:SetHidden(panelName ~= "kiosks")
    ranks:SetHidden(panelName ~= "ranks")
    if search then search:SetHidden(panelName ~= "search") end

    if panelName == "kiosks" then
        GL.RefreshKiosks()
    elseif panelName == "ranks" then
        GL.RefreshRanks()
    elseif panelName == "search" then
        GL.RefreshSearchPanel()
    end
end

function GL.ToggleKiosks()
    if GuildLedgerFrameKiosksPanel:IsHidden() then
        GL.ShowPanel("kiosks")
    else
        GL.ShowPanel("body")
    end
end

function GL.ToggleRanks()
    if GuildLedgerFrameRanksPanel:IsHidden() then
        GL.ShowPanel("ranks")
    else
        GL.ShowPanel("body")
    end
end

function GL.ToggleSearchPanel()
    if not GuildLedgerFrameSearchPanel then return end
    if GuildLedgerFrameSearchPanel:IsHidden() then
        GL.ShowPanel("search")
    else
        GL.ShowPanel("body")
    end
end

function GL.OpenSearchPanelFor(guildIndex, displayName)
    if GuildLedgerFrame and GuildLedgerFrame:IsHidden() then
        GL.ToggleUI()
    end
    if guildIndex then
        GL.searchPanelGuildIndex = guildIndex
    end
    GL.searchPanelQuery = NormalizeDisplayName(displayName or "")
    GL.ShowPanel("search")

    zo_callLater(function()
        if GuildLedgerFrameSearchPanelSearchBgBox then
            GuildLedgerFrameSearchPanelSearchBgBox:SetText(GL.searchPanelQuery or "")
        end
        pcall(GL.BuildSearchPanelGuildCombo)
        GL.RefreshSearchPanel()
    end, 10)
end

function GL.BuildSearchPanelGuildCombo()
    local parent = GuildLedgerFrameSearchPanel
    local anchor = GuildLedgerFrameSearchPanelSearchBg
    if not (parent and anchor) then return end

    local combo = GetControl("GuildLedgerFrameSearchPanelGuildCombo")
    if not combo then
        combo = CreateControlFromVirtual("GuildLedgerFrameSearchPanelGuildCombo", parent, "ZO_ComboBox")
    end
    combo:SetDimensions(200, 30)
    combo:ClearAnchors()
    combo:SetAnchor(RIGHT, anchor, LEFT, -14, 0)

    local comboObj = ZO_ComboBox_ObjectFromContainer(combo)
    comboObj:SetSortsItems(false)
    comboObj:ClearItems()

    GL.searchPanelGuildIndex = GL.searchPanelGuildIndex or GL.selectedGuildIndex or 1

    local numGuilds = GetNumGuilds()
    local selectedEntry = nil
    for i = 1, numGuilds do
        local guildId = GetGuildId(i)
        local guildName = GetGuildName(guildId)
        if not guildName or guildName == "" then
            guildName = "Guild " .. i
        end
        local entry = comboObj:CreateItemEntry(guildName, function()
            GL.searchPanelGuildIndex = i
            GL.RefreshSearchPanel()
        end)
        comboObj:AddItem(entry)
        if i == GL.searchPanelGuildIndex then
            selectedEntry = entry
        end
    end
    if selectedEntry then
        comboObj:SelectItem(selectedEntry, false)
    end
end

function GL.BuildSearchPanelPeriodCombo()
    local parent = GuildLedgerFrameSearchPanel
    local anchor = GuildLedgerFrameSearchPanelSearchBg
    if not (parent and anchor) then return end

    local combo = GetControl("GuildLedgerFrameSearchPanelPeriodCombo")
    if not combo then
        combo = CreateControlFromVirtual("GuildLedgerFrameSearchPanelPeriodCombo", parent, "ZO_ComboBox")
    end
    combo:SetDimensions(200, 30)
    combo:ClearAnchors()
    combo:SetAnchor(LEFT, anchor, RIGHT, 14, 0)

    local comboObj = ZO_ComboBox_ObjectFromContainer(combo)
    comboObj:SetSortsItems(false)
    comboObj:ClearItems()

    GL.searchPanelTimeframe = GL.searchPanelTimeframe or "week"

    local options = {
        { name = TiradilL10n.Get("PERIOD_THIS_WEEK"), value = "week" },
        { name = TiradilL10n.Get("PERIOD_LAST_WEEK"), value = "last_week" },
        { name = TiradilL10n.Get("PERIOD_2_WEEKS_AGO"), value = "week_before_last" },
        { name = TiradilL10n.Get("PERIOD_3_WEEKS_AGO"), value = "3_weeks_ago" },
        { name = TiradilL10n.Get("PERIOD_4_WEEKS_AGO"), value = "4_weeks_ago" },
        { name = TiradilL10n.Get("PERIOD_LAST_MONTH"), value = "last_month" },
        { name = TiradilL10n.Get("PERIOD_THIS_MONTH"), value = "this_month" },
        { name = TiradilL10n.Get("PERIOD_LAST_30_DAYS"), value = "last_30_days" },
        { name = TiradilL10n.Get("PERIOD_ALL_TIME"), value = "all_time" },
    }

    local selectedEntry = nil
    for _, opt in ipairs(options) do
        local entry = comboObj:CreateItemEntry(opt.name, function()
            GL.searchPanelTimeframe = opt.value
            GL.RefreshSearchPanel()
        end)
        comboObj:AddItem(entry)
        if opt.value == GL.searchPanelTimeframe then
            selectedEntry = entry
        end
    end
    if selectedEntry then
        comboObj:SelectItem(selectedEntry, false)
    end
end

function GL.BuildSearchPanelControls()
    GL.BuildSearchPanelGuildCombo()
    GL.BuildSearchPanelPeriodCombo()
end

function GL.GetPersonalNote(displayName)
    if not displayName or displayName == "" then return nil end
    GL.savedVars.personalNotes = GL.savedVars.personalNotes or {}
    local key = NormalizeDisplayName(displayName)
    local note = GL.savedVars.personalNotes[key]
    if note and note ~= "" then return note end
    return nil
end

function GL.SetPersonalNote(displayName, text)
    if not displayName or displayName == "" then return end
    GL.savedVars.personalNotes = GL.savedVars.personalNotes or {}
    local key = NormalizeDisplayName(displayName)
    if text == nil or text == "" then
        GL.savedVars.personalNotes[key] = nil
    else
        GL.savedVars.personalNotes[key] = text
    end
end

function GL.OpenEditNoteDialog(displayName)
    if not displayName then return end
    if not TGA_EditNoteWindow then
        d("|cFF6B6B[Tiradil's Guild Assistant]|r " .. TiradilL10n.Get("EDIT_NOTE_XML_OUTDATED"))
        return
    end
    GL.editNoteTarget = displayName

    local L = TiradilL10n.Get
    if TGA_EditNoteWindowTitle then
        TGA_EditNoteWindowTitle:SetText(L("EDIT_NOTE_TITLE"))
    end
    if TGA_EditNoteWindowSubTitle then
        TGA_EditNoteWindowSubTitle:SetText(zo_strformat(L("EDIT_NOTE_SUBTITLE"), displayName))
    end
    if TGA_EditNoteWindowInputBgBox then
        TGA_EditNoteWindowInputBgBox:SetText(GL.GetPersonalNote(displayName) or "")
    end
    TGA_EditNoteWindow:SetHidden(false)
end

function GL.SaveEditNoteDialog()
    if not (GL.editNoteTarget and TGA_EditNoteWindowInputBgBox) then return end
    GL.SetPersonalNote(GL.editNoteTarget, TGA_EditNoteWindowInputBgBox:GetText())
    TGA_EditNoteWindow:SetHidden(true)
    if GuildLedgerFrameSearchPanel and not GuildLedgerFrameSearchPanel:IsHidden() then
        GL.RefreshSearchPanel()
    end
end

function GL.OnSearchPanelTextChanged(editControl)
    GL.searchPanelQuery = editControl:GetText()
    GL.searchPanelQueryGeneration = (GL.searchPanelQueryGeneration or 0) + 1
    local myGeneration = GL.searchPanelQueryGeneration
    zo_callLater(function()
        if GL.searchPanelQueryGeneration == myGeneration then
            GL.RefreshSearchPanel()
        end
    end, 200)
end

function GL.RefreshSearchPanel()
    local list = GuildLedgerFrameSearchPanelList
    local hint = GuildLedgerFrameSearchPanelHint
    if not list then return end

    local guildIndex = GL.searchPanelGuildIndex or GL.selectedGuildIndex or 1
    local guildId = GetGuildId(guildIndex)
    local query = (GL.searchPanelQuery or ""):lower()

    if hint then hint:SetText("") end

    if not guildId or guildId == 0 then
        PopulateTextList(list, { "|cFF6B6B" .. TiradilL10n.Get("STATUS_NO_VALID_GUILD") .. "|r" })
        return
    end

    if query == "" then
        if hint then hint:SetText(TiradilL10n.Get("SEARCH_PANEL_HINT")) end
        PopulateTextList(list, {})
        return
    end

    local minTime, maxTime = GL.GetTimeframeRangeFor(GL.searchPanelTimeframe or "week")
    local bankList = GL.bankEvents[guildIndex] or {}
    local traderList = GL.traderEvents[guildIndex] or {}

    local members = {}
    local order = {}
    local function getMember(name)
        local key = NormalizeDisplayName(name)
        local m = members[key]
        if not m then
            m = {
                displayName = name,
                donationTotal = 0, donationEntries = {},
                salesTotal = 0, salesEntries = {},
                purchaseTotal = 0, purchaseEntries = {},
            }
            members[key] = m
            table.insert(order, key)
        end
        return m
    end

    for i = 1, #bankList do
        local e = bankList[i]
        if e.type == GUILD_HISTORY_BANKED_CURRENCY_EVENT_DEPOSITED and e.time >= minTime and e.time < maxTime and e.displayName then
            if e.displayName:lower():find(query, 1, true) then
                local m = getMember(e.displayName)
                m.donationTotal = m.donationTotal + e.amount
                table.insert(m.donationEntries, { time = e.time, amount = e.amount })
            end
        end
    end
    for i = 1, #traderList do
        local e = traderList[i]
        if e.time >= minTime and e.time < maxTime then
            if e.sellerDisplayName and e.sellerDisplayName:lower():find(query, 1, true) then
                local m = getMember(e.sellerDisplayName)
                m.salesTotal = m.salesTotal + e.price
                table.insert(m.salesEntries, { time = e.time, amount = e.price })
            end
            if e.buyerDisplayName and e.buyerDisplayName:lower():find(query, 1, true) then
                local m = getMember(e.buyerDisplayName)
                m.purchaseTotal = m.purchaseTotal + e.price
                table.insert(m.purchaseEntries, { time = e.time, amount = e.price })
            end
        end
    end

    table.sort(order, function(a, b)
        local ma, mb = members[a], members[b]
        return (ma.donationTotal + ma.salesTotal) > (mb.donationTotal + mb.salesTotal)
    end)

    local lines = {}
    if #order == 0 then
        table.insert(lines, "|cA0A0A0" .. TiradilL10n.Get("SEARCH_PANEL_NONE") .. "|r")
    else
        local shown = 0
        for _, key in ipairs(order) do
            shown = shown + 1
            if shown > 20 then break end
            local m = members[key]

            table.sort(m.donationEntries, function(a, b) return a.time > b.time end)
            table.sort(m.salesEntries, function(a, b) return a.time > b.time end)
            table.sort(m.purchaseEntries, function(a, b) return a.time > b.time end)

            table.insert(lines, string.format("|cFFB800%s|r", m.displayName))

            local note = GL.GetPersonalNote(m.displayName)
            if note then
                table.insert(lines, "    |cA0A0A0" .. TiradilL10n.Get("LEDGER_NOTE_PREFIX") .. "|r " .. note)
            end

            if m.donationTotal > 0 then
                table.insert(lines, string.format("    |c4DDB4D%s: %s|r", TiradilL10n.Get("LEDGER_LABEL_DONATIONS"), FormatGoldIcon(m.donationTotal, 14)))
                for i = 1, math.min(5, #m.donationEntries) do
                    local e = m.donationEntries[i]
                    table.insert(lines, string.format("        |cA0A0A0%s|r: %s", os.date("%d.%m.%y %H:%M", e.time), FormatGoldIcon(e.amount, 12)))
                end
            end
            if m.salesTotal > 0 then
                table.insert(lines, string.format("    |cFFB800%s: %s|r", TiradilL10n.Get("LEDGER_LABEL_SALES"), FormatGoldIcon(m.salesTotal, 14)))
                for i = 1, math.min(5, #m.salesEntries) do
                    local e = m.salesEntries[i]
                    table.insert(lines, string.format("        |cA0A0A0%s|r: %s", os.date("%d.%m.%y %H:%M", e.time), FormatGoldIcon(e.amount, 12)))
                end
            end
            if m.purchaseTotal > 0 then
                table.insert(lines, string.format("    |cB366F0%s: %s|r", TiradilL10n.Get("LEDGER_LABEL_PURCHASES"), FormatGoldIcon(m.purchaseTotal, 14)))
                for i = 1, math.min(5, #m.purchaseEntries) do
                    local e = m.purchaseEntries[i]
                    table.insert(lines, string.format("        |cA0A0A0%s|r: %s", os.date("%d.%m.%y %H:%M", e.time), FormatGoldIcon(e.amount, 12)))
                end
            end
            table.insert(lines, "")
        end
    end

    PopulateTextList(list, lines)
end

function GL.RegisterLAMSettings()
    if LibAddonMenu2 == nil then
        return
    end

    local LAM = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = TiradilL10n.Get("SUITE_TITLE"),
        displayName = TiradilL10n.Get("SUITE_TITLE"),
        author = "@AlcholicVader",
        version = "1.0",
        registerForRefresh = true,
    }
    LAM:RegisterAddonPanel("TiradilSuiteRankSettingsPanel", panelData)

    local function GetGuildChoices()
        local choices = {}
        local numGuilds = GetNumGuilds()
        for i = 1, numGuilds do
            local name = GetGuildName(GetGuildId(i))
            table.insert(choices, (name and name ~= "") and name or ("Guild " .. i))
        end
        return choices
    end

    local optionsData = {
        {
            type = "header",
            name = function() return TiradilL10n.Get("LAM_HEADER_DISPLAY") end,
            width = "full",
        },
        {
            type = "dropdown",
            reference = "TGA_LAM_LanguageDropdown",
            name = function() return TiradilL10n.Get("LAM_LANGUAGE_NAME") end,
            tooltip = function() return TiradilL10n.Get("LAM_LANGUAGE_TOOLTIP") end,
            choices = { TiradilL10n.Get("LANG_EN"), TiradilL10n.Get("LANG_TR"), TiradilL10n.Get("LANG_DE"), TiradilL10n.Get("LANG_ES"), TiradilL10n.Get("LANG_PL"), TiradilL10n.Get("LANG_RU"), TiradilL10n.Get("LANG_IT"), TiradilL10n.Get("LANG_PT") },
            choicesValues = { "en", "tr", "de", "es", "pl", "ru", "it", "pt" },
            getFunc = function() return GL.savedVars.language or "en" end,
            setFunc = function(value)
                GL.savedVars.language = value
                if TiradilL10n and TiradilL10n.RefreshAll then
                    TiradilL10n.RefreshAll()
                end
            end,
            width = "full",
        },
        {
            type = "header",
            name = function() return TiradilL10n.Get("LAM_HEADER_ROSTER_INTEGRATION") end,
            width = "full",
        },
        {
            type = "checkbox",
            reference = "TGA_LAM_ShowContribColumn",
            name = function() return TiradilL10n.Get("LAM_SHOW_CONTRIB_COLUMN_NAME") end,
            tooltip = function() return TiradilL10n.Get("LAM_SHOW_CONTRIB_COLUMN_TOOLTIP") end,
            getFunc = function()
                return TiradilRosterColumn_SavedVars == nil or TiradilRosterColumn_SavedVars.enabled ~= false
            end,
            setFunc = function(value)
                if TiradilRosterColumn and TiradilRosterColumn.SetColumnEnabled then
                    TiradilRosterColumn.SetColumnEnabled(value)
                else
                    TiradilRosterColumn_SavedVars = TiradilRosterColumn_SavedVars or { selectedTimeframe = "week" }
                    TiradilRosterColumn_SavedVars.enabled = value
                end
            end,
            width = "full",
        },
        {
            type = "checkbox",
            reference = "TGA_LAM_ShowRankColumn",
            name = function() return TiradilL10n.Get("LAM_SHOW_RANK_COLUMN_NAME") end,
            tooltip = function() return TiradilL10n.Get("LAM_SHOW_RANK_COLUMN_TOOLTIP") end,
            getFunc = function()
                return TiradilRosterColumn_SavedVars == nil or TiradilRosterColumn_SavedVars.rankColumnEnabled ~= false
            end,
            setFunc = function(value)
                if TiradilRosterColumn and TiradilRosterColumn.SetRankColumnEnabled then
                    TiradilRosterColumn.SetRankColumnEnabled(value)
                else
                    TiradilRosterColumn_SavedVars = TiradilRosterColumn_SavedVars or { selectedTimeframe = "week" }
                    TiradilRosterColumn_SavedVars.rankColumnEnabled = value
                end
            end,
            width = "full",
        },
        {
            type = "header",
            name = function() return TiradilL10n.Get("LAM_HEADER_NOTIFICATIONS") end,
            width = "full",
        },
        {
            type = "checkbox",
            reference = "TGA_LAM_ScreenNotif",
            name = function() return TiradilL10n.Get("LAM_SCREEN_NOTIF_NAME") end,
            tooltip = function() return TiradilL10n.Get("LAM_SCREEN_NOTIF_TOOLTIP") end,
            getFunc = function()
                return GL.savedVars.screenNotifications ~= false
            end,
            setFunc = function(value)
                GL.savedVars.screenNotifications = value
            end,
            width = "full",
        },
        {
            type = "header",
            name = function() return TiradilL10n.Get("LAM_HEADER_MAIL_TEMPLATE") end,
            width = "full",
        },
        {
            type = "description",
            text = function() return TiradilL10n.Get("LAM_MAIL_TEMPLATE_DESC") end,
            width = "full",
        },
        {
            type = "editbox",
            reference = "TGA_LAM_MailSubject",
            name = function() return TiradilL10n.Get("LAM_MAIL_SUBJECT_NAME") end,
            tooltip = function() return TiradilL10n.Get("LAM_MAIL_SUBJECT_TOOLTIP") end,
            getFunc = function()
                GL.savedVars.mailTemplates = GL.savedVars.mailTemplates or {}
                local t = GL.savedVars.mailTemplates[GL.settingsGuildIndex]
                return t and t.subject or ""
            end,
            setFunc = function(value)
                GL.savedVars.mailTemplates = GL.savedVars.mailTemplates or {}
                GL.savedVars.mailTemplates[GL.settingsGuildIndex] = GL.savedVars.mailTemplates[GL.settingsGuildIndex] or {}
                GL.savedVars.mailTemplates[GL.settingsGuildIndex].subject = value
            end,
            isMultiline = false,
            isExtraWide = true,
            width = "full",
        },
        {
            type = "editbox",
            reference = "TGA_LAM_MailBody",
            name = function() return TiradilL10n.Get("LAM_MAIL_BODY_NAME") end,
            tooltip = function() return TiradilL10n.Get("LAM_MAIL_BODY_TOOLTIP") end,
            getFunc = function()
                GL.savedVars.mailTemplates = GL.savedVars.mailTemplates or {}
                local t = GL.savedVars.mailTemplates[GL.settingsGuildIndex]
                return t and t.body or ""
            end,
            setFunc = function(value)
                GL.savedVars.mailTemplates = GL.savedVars.mailTemplates or {}
                GL.savedVars.mailTemplates[GL.settingsGuildIndex] = GL.savedVars.mailTemplates[GL.settingsGuildIndex] or {}
                GL.savedVars.mailTemplates[GL.settingsGuildIndex].body = value
            end,
            isMultiline = true,
            isExtraWide = true,
            width = "full",
        },
        {
            type = "header",
            name = function() return TiradilL10n.Get("LAM_HEADER_RANK_THRESHOLDS") end,
            width = "full",
        },
        {
            type = "description",
            text = function() return TiradilL10n.Get("LAM_RANK_DESCRIPTION") end,
            width = "full",
        },
        {
            type = "dropdown",
            reference = "TGA_LAM_GuildDropdown",
            name = function() return TiradilL10n.Get("LAM_GUILD_NAME") end,
            tooltip = function() return TiradilL10n.Get("LAM_GUILD_TOOLTIP") end,
            choices = GetGuildChoices(),
            getFunc = function()
                local choices = GetGuildChoices()
                return choices[GL.settingsGuildIndex] or choices[1]
            end,
            setFunc = function(value)
                local choices = GetGuildChoices()
                for i, name in ipairs(choices) do
                    if name == value then
                        GL.settingsGuildIndex = i
                        break
                    end
                end
            end,
            width = "full",
        },
        {
            type = "slider",
            reference = "TGA_LAM_KickThresholdSlider",
            name = function() return TiradilL10n.Get("LAM_KICK_THRESHOLD_NAME") end,
            tooltip = function() return TiradilL10n.Get("LAM_KICK_THRESHOLD_TOOLTIP") end,
            min = 3,
            max = 60,
            step = 1,
            getFunc = function()
                return GL.savedVars.rankSettings[GL.settingsGuildIndex].kickThresholdDays or 14
            end,
            setFunc = function(value)
                GL.savedVars.rankSettings[GL.settingsGuildIndex].kickThresholdDays = value
            end,
            width = "full",
        },
    }

    for i, tier in ipairs(RANK_TIERS) do
        table.insert(optionsData, {
            type = "header",
            name = function() return GL.GetTierName(GL.settingsGuildIndex, i) end,
            width = "full",
        })
        table.insert(optionsData, {
            type = "editbox",
            reference = "TGA_LAM_TierName_" .. i,
            name = function() return TiradilL10n.Get("LAM_TIER_NAME_NAME") end,
            tooltip = function() return TiradilL10n.Get("LAM_TIER_NAME_TOOLTIP") end,
            getFunc = function()
                return GL.savedVars.rankSettings[GL.settingsGuildIndex][i].name or tier.name
            end,
            setFunc = function(value)
                GL.savedVars.rankSettings[GL.settingsGuildIndex][i].name = (value ~= "" and value) or tier.name
                GL.RefreshRanks()
            end,
            width = "full",
        })

        if i == 1 then
            table.insert(optionsData, {
                type = "dropdown",
                reference = "TGA_LAM_LegendModeDropdown",
                name = function() return TiradilL10n.Get("LAM_LEGEND_MODE_NAME") end,
                tooltip = function() return TiradilL10n.Get("LAM_LEGEND_MODE_TOOLTIP") end,
                choices = {
                    TiradilL10n.Get("LAM_LEGEND_MODE_THRESHOLD"),
                    TiradilL10n.Get("LAM_LEGEND_MODE_TOP3"),
                },
                choicesValues = { "threshold", "top3" },
                getFunc = function()
                    return GL.savedVars.rankSettings[GL.settingsGuildIndex][1].legendMode or "threshold"
                end,
                setFunc = function(value)
                    GL.savedVars.rankSettings[GL.settingsGuildIndex][1].legendMode = value
                    GL.RefreshRanks()
                end,
                width = "full",
            })
            table.insert(optionsData, {
                type = "description",
                text = function() return TiradilL10n.Get("LAM_LEGEND_TOP3_DESC") end,
                width = "full",
            })
            table.insert(optionsData, {
                type = "slider",
                reference = "TGA_LAM_TopSellersSlider",
                name = function() return TiradilL10n.Get("LAM_LEGEND_TOP_SELLERS_COUNT_NAME") end,
                tooltip = function() return TiradilL10n.Get("LAM_LEGEND_TOP_SELLERS_COUNT_TOOLTIP") end,
                min = 1,
                max = 10,
                step = 1,
                disabled = function()
                    return GL.savedVars.rankSettings[GL.settingsGuildIndex][1].legendMode ~= "top3"
                end,
                getFunc = function()
                    return GL.savedVars.rankSettings[GL.settingsGuildIndex][1].legendTopSellersCount or 3
                end,
                setFunc = function(value)
                    GL.savedVars.rankSettings[GL.settingsGuildIndex][1].legendTopSellersCount = value
                    GL.RefreshRanks()
                end,
                width = "half",
            })
            table.insert(optionsData, {
                type = "slider",
                reference = "TGA_LAM_TopDonorsSlider",
                name = function() return TiradilL10n.Get("LAM_LEGEND_TOP_DONORS_COUNT_NAME") end,
                tooltip = function() return TiradilL10n.Get("LAM_LEGEND_TOP_DONORS_COUNT_TOOLTIP") end,
                min = 1,
                max = 10,
                step = 1,
                disabled = function()
                    return GL.savedVars.rankSettings[GL.settingsGuildIndex][1].legendMode ~= "top3"
                end,
                getFunc = function()
                    return GL.savedVars.rankSettings[GL.settingsGuildIndex][1].legendTopDonorsCount or 3
                end,
                setFunc = function(value)
                    GL.savedVars.rankSettings[GL.settingsGuildIndex][1].legendTopDonorsCount = value
                    GL.RefreshRanks()
                end,
                width = "half",
            })
        end

        table.insert(optionsData, {
            type = "editbox",
            reference = "TGA_LAM_SalesThreshold_" .. i,
            name = function() return TiradilL10n.Get("LAM_SALES_THRESHOLD_NAME") end,
            tooltip = function() return TiradilL10n.Get("LAM_SALES_THRESHOLD_TOOLTIP") .. GL.GetTierName(GL.settingsGuildIndex, i) end,
            disabled = function()
                return i == 1 and GL.savedVars.rankSettings[GL.settingsGuildIndex][1].legendMode == "top3"
            end,
            getFunc = function()
                return tostring(GL.savedVars.rankSettings[GL.settingsGuildIndex][i].salesThreshold or 0)
            end,
            setFunc = function(value)
                GL.savedVars.rankSettings[GL.settingsGuildIndex][i].salesThreshold = tonumber(value) or 0
            end,
            width = "half",
        })
        table.insert(optionsData, {
            type = "editbox",
            reference = "TGA_LAM_DonationThreshold_" .. i,
            name = function() return TiradilL10n.Get("LAM_DONATION_THRESHOLD_NAME") end,
            tooltip = function() return TiradilL10n.Get("LAM_DONATION_THRESHOLD_TOOLTIP") .. GL.GetTierName(GL.settingsGuildIndex, i) end,
            disabled = function()
                return i == 1 and GL.savedVars.rankSettings[GL.settingsGuildIndex][1].legendMode == "top3"
            end,
            getFunc = function()
                return tostring(GL.savedVars.rankSettings[GL.settingsGuildIndex][i].donationThreshold or 0)
            end,
            setFunc = function(value)
                GL.savedVars.rankSettings[GL.settingsGuildIndex][i].donationThreshold = tonumber(value) or 0
            end,
            width = "half",
        })
    end

    LAM:RegisterOptionControls("TiradilSuiteRankSettingsPanel", optionsData)
end

local legendTop3Cache = {} -- legendTop3Cache["guildIndex|timeframe|sellersN|donorsN"] = { set=, sales=, donations=, builtAt= }
local LEGEND_TOP3_CACHE_TTL_SECONDS = 15

local function ComputeTopNNames(amountMap, n)
    local list = {}
    for name, amount in pairs(amountMap) do
        if amount and amount > 0 then
            table.insert(list, { name = name, amount = amount })
        end
    end
    table.sort(list, function(a, b) return a.amount > b.amount end)
    local top = {}
    for i = 1, math.min(n, #list) do
        top[list[i].name] = true
    end
    return top
end

function GL.GetLegendTop3Set(guildIndex, timeframe)
    timeframe = timeframe or "this_month"

    local sellersN, donorsN = 3, 3
    local settingsForGuild = GL.savedVars and GL.savedVars.rankSettings and GL.savedVars.rankSettings[guildIndex]
    if settingsForGuild and settingsForGuild[1] then
        sellersN = settingsForGuild[1].legendTopSellersCount or 3
        donorsN = settingsForGuild[1].legendTopDonorsCount or 3
    end

    local cacheKey = tostring(guildIndex) .. "|" .. timeframe .. "|" .. sellersN .. "|" .. donorsN
    local now = os.time()
    local cached = legendTop3Cache[cacheKey]
    if cached and (now - cached.builtAt) < LEGEND_TOP3_CACHE_TTL_SECONDS then
        return cached.set, cached.sales, cached.donations
    end

    local sales, donations = {}, {}
    local minTime, maxTime = GL.GetTimeframeRangeFor(timeframe)

    local traderList = GL.traderEvents[guildIndex] or {}
    for i = 1, #traderList do
        local e = traderList[i]
        if e.time >= minTime and e.time < maxTime and e.sellerDisplayName then
            local key = NormalizeDisplayName(e.sellerDisplayName)
            sales[key] = (sales[key] or 0) + e.price
        end
    end

    local bankList = GL.bankEvents[guildIndex] or {}
    for i = 1, #bankList do
        local e = bankList[i]
        if e.type == GUILD_HISTORY_BANKED_CURRENCY_EVENT_DEPOSITED and e.time >= minTime and e.time < maxTime and e.displayName then
            local key = NormalizeDisplayName(e.displayName)
            donations[key] = (donations[key] or 0) + e.amount
        end
    end

    local topSellers = ComputeTopNNames(sales, sellersN)
    local topDonors = ComputeTopNNames(donations, donorsN)

    local set = {}
    for name in pairs(topSellers) do set[name] = true end
    for name in pairs(topDonors) do set[name] = true end

    legendTop3Cache[cacheKey] = { set = set, sales = sales, donations = donations, builtAt = now }
    return set, sales, donations
end

function GL.RefreshRanks()
    local guildId = GetGuildId(GL.selectedGuildIndex)
    if not guildId or guildId == 0 then return end

    local now = os.time()
    local minTime, maxTime = GetTimeframeRange()

    local memberSales, memberDonations = {}, {}
    local traderList = GL.traderEvents[GL.selectedGuildIndex] or {}
    for i = 1, #traderList do
        local e = traderList[i]
        if e.time >= minTime and e.time < maxTime then
            local name = e.sellerDisplayName or "?"
            memberSales[name] = (memberSales[name] or 0) + e.price
        end
    end
    local bankList = GL.bankEvents[GL.selectedGuildIndex] or {}
    for i = 1, #bankList do
        local e = bankList[i]
        if e.type == GUILD_HISTORY_BANKED_CURRENCY_EVENT_DEPOSITED and e.time >= minTime and e.time < maxTime then
            local name = e.displayName or "?"
            memberDonations[name] = (memberDonations[name] or 0) + e.amount
        end
    end

    local allMembers = {}
    for name in pairs(memberSales) do allMembers[name] = true end
    for name in pairs(memberDonations) do allMembers[name] = true end

    local legendSettings = GL.savedVars.rankSettings[GL.selectedGuildIndex][1]
    local legendTop3Set, legendSales, legendDonations = nil, nil, nil
    if legendSettings and legendSettings.legendMode == "top3" then
        legendTop3Set, legendSales, legendDonations = GL.GetLegendTop3Set(GL.selectedGuildIndex, GL.selectedTimeframe)
        for name in pairs(legendTop3Set) do
            allMembers[name] = true
        end
    end

    local tierMembers = { {}, {}, {}, {}, {} }
    for name in pairs(allMembers) do
        local sales = memberSales[name] or 0
        local donations = memberDonations[name] or 0

        if legendTop3Set and legendTop3Set[name] then
            table.insert(tierMembers[1], {
                name = name,
                sales = legendSales[name] or 0,
                donations = legendDonations[name] or 0,
            })
        else
            local startTier = legendTop3Set and 2 or 1
            for i = startTier, #RANK_TIERS do
                local tier = RANK_TIERS[i]
                local settings = GL.savedVars.rankSettings[GL.selectedGuildIndex][i]
                if sales >= (settings.salesThreshold or math.huge) or donations >= (settings.donationThreshold or math.huge) then
                    table.insert(tierMembers[i], { name = name, sales = sales, donations = donations })
                    break
                end
            end
        end
    end

    local lines = {}
    local anyMembers = false
    for i, tier in ipairs(RANK_TIERS) do
        local members = tierMembers[i]
        if #members > 0 then
            anyMembers = true
            table.sort(members, function(a, b) return (a.sales + a.donations) > (b.sales + b.donations) end)
            table.insert(lines, string.format("|c%s%s|r", tier.color, GL.GetTierName(GL.selectedGuildIndex, i)))
            for _, m in ipairs(members) do
                table.insert(lines, string.format("    |c4DDB4D%s|r  -  Sales: %s   Donations: %s",
                    m.name, FormatGoldIcon(m.sales, 12), FormatGoldIcon(m.donations, 12)))
            end
        end
    end

    if not anyMembers then
        table.insert(lines, "|cA0A0A0" .. TiradilL10n.Get("RANKS_NONE_QUALIFY") .. "|r")
    end

    PopulateTextList(GuildLedgerFrameRanksPanelList, lines)
    GL.UpdatePanelTitles()
end

function GL.SetSearchFilter(displayName)
    GL.searchFilter = displayName
    if GuildLedgerFrameFooterClearFilterBtn then
        GuildLedgerFrameFooterClearFilterBtn:SetHidden(false)
    end
    GL.RefreshData()
end

function GL.ClearSearchFilter()
    GL.searchFilter = nil
    if GuildLedgerFrameFooterClearFilterBtn then
        GuildLedgerFrameFooterClearFilterBtn:SetHidden(true)
    end
    GL.RefreshData()
end

function GL.SelectGuild(index)
    GL.selectedGuildIndex = index
    GL.savedVars.selectedGuildIndex = index
    GL.RefreshData()
    if not GuildLedgerFrameRanksPanel:IsHidden() then
        GL.RefreshRanks()
    end
end

function GL.SetTimeframe(tf)
    GL.selectedTimeframe = tf
    GL.savedVars.selectedTimeframe = tf
    GL.RefreshData()
    if not GuildLedgerFrameRanksPanel:IsHidden() then
        GL.RefreshRanks()
    end
end

function GL.ToggleUI()
    local frame = GuildLedgerFrame
    if frame then
        local isHidden = frame:IsHidden()
        frame:SetHidden(not isHidden)
        if isHidden then
            GL.RefreshData()
        end
    end
end

function GL.OnBankEvent(event, guildIndex)
    local info = event:GetEventInfo()
    if info.currencyType ~= nil and info.currencyType ~= CURT_MONEY then
        return
    end

    local eventTime = event:GetEventTimestampS()

    table.insert(GL.bankEvents[guildIndex], {
        time = eventTime,
        type = event:GetEventType(),
        amount = info.amount or 0,
        kioskName = info.kioskName,
        displayName = info.displayName,
    })

    if event:GetEventType() == GUILD_HISTORY_BANKED_CURRENCY_EVENT_DEPOSITED
        and eventTime >= (GL.trackingStartedAt or 0)
        and GL.savedVars and GL.savedVars.screenNotifications
        and CENTER_SCREEN_ANNOUNCE and CSA_CATEGORY_SMALL_TEXT then
        local ok = pcall(function()
            local guildName = GetGuildName(GetGuildId(guildIndex)) or TiradilL10n.Get("BTN_GUILD_LEDGER")
            local text = zo_strformat(TiradilL10n.Get("DONATION_ANNOUNCE_FORMAT"),
                info.displayName or "?", FormatGold(info.amount or 0), guildName)
            CENTER_SCREEN_ANNOUNCE:AddMessage(
                nil,
                CSA_CATEGORY_SMALL_TEXT,
                SOUNDS.TELVAR_TRANSACT,
                text,
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
        end)
    end

    if guildIndex == GL.selectedGuildIndex then
        GL.RefreshData()
    end
end

function GL.OnTraderEvent(event, guildIndex)
    if event:GetEventType() ~= GUILD_HISTORY_TRADER_EVENT_ITEM_SOLD then
        return
    end
    local info = event:GetEventInfo()

    table.insert(GL.traderEvents[guildIndex], {
        time = event:GetEventTimestampS(),
        price = info.price or 0,
        tax = info.tax or 0,
        sellerDisplayName = info.sellerDisplayName,
        buyerDisplayName = info.buyerDisplayName,
    })

    if guildIndex == GL.selectedGuildIndex then
        GL.RefreshData()
    end
end

function GL.TryStartTracking()
    if LibHistoire == nil then
        d("|cFF6B6BGuildLedger:|r " .. TiradilL10n.Get("CHAT_LIBHISTOIRE_MISSING"))
        return
    end

    if not LibHistoire:IsReady() then
        zo_callLater(GL.TryStartTracking, 2000)
        return
    end

    local numGuilds = GetNumGuilds()
    for i = 1, numGuilds do
        GL.bankEvents[i] = GL.bankEvents[i] or {}
        GL.traderEvents[i] = GL.traderEvents[i] or {}

        local guildId = GetGuildId(i)
        GL.guildNames[i] = GetGuildName(guildId)
        local bankProcessor = LibHistoire:CreateGuildHistoryProcessor(guildId, GUILD_HISTORY_EVENT_CATEGORY_BANKED_CURRENCY, "GuildLedger")
        if bankProcessor then
            bankProcessor:StartStreaming(nil, function(event)
                GL.OnBankEvent(event, i)
            end)
        end

        local traderProcessor = LibHistoire:CreateGuildHistoryProcessor(guildId, GUILD_HISTORY_EVENT_CATEGORY_TRADER, "GuildLedger")
        if traderProcessor then
            traderProcessor:StartStreaming(nil, function(event)
                GL.OnTraderEvent(event, i)
            end)
        end
    end

    d("|c4DDB4DGuildLedger:|r " .. zo_strformat(TiradilL10n.Get("CHAT_TRACKING_STARTED"), tostring(numGuilds)))
end

function GL.RefreshKiosks()
    local all = {}
    for guildIndex = 1, 5 do
        local list = GL.bankEvents[guildIndex]
        if list then
            local guildName = GL.guildNames[guildIndex] or ("Guild " .. guildIndex)

            for i = 1, #list do
                local e = list[i]
                if e.type == GUILD_HISTORY_BANKED_CURRENCY_EVENT_KIOSK_PURCHASED then
                    table.insert(all, {
                        time = e.time,
                        amount = e.amount,
                        kioskName = e.kioskName,
                        guildIndex = guildIndex,
                        guildName = guildName,
                    })
                end
            end

            local wonBids = GetConfirmedWonBids(list)
            for i = 1, #wonBids do
                local b = wonBids[i]
                table.insert(all, {
                    time = b.time,
                    amount = b.amount,
                    kioskName = b.kioskName,
                    guildIndex = guildIndex,
                    guildName = guildName,
                })
            end
        end
    end

    table.sort(all, function(a, b) return a.time > b.time end)

    local currentMarked = {}

    local lines = {}
    if #all == 0 then
        table.insert(lines, TiradilL10n.Get("KIOSKS_NONE_YET"))
    else
        local count = 0
        for i = 1, #all do
            count = count + 1
            if count > 40 then break end
            local e = all[i]
            local dateStr = os.date("%d.%m.%y %H:%M", e.time)

            local isCurrent = not currentMarked[e.guildIndex]
            currentMarked[e.guildIndex] = true

            if isCurrent then
                table.insert(lines, string.format("|cA0A0A0%s|r  |cFFB800%s|r  -  %s  -  %s  |c4DDB4D[%s]|r",
                    dateStr, e.guildName, e.kioskName or "?", FormatGold(e.amount), TiradilL10n.Get("KIOSK_CURRENT_TAG")))
            else
                table.insert(lines, string.format("|cA0A0A0%s|r  |cFFB800%s|r  -  %s  -  %s",
                    dateStr, e.guildName, e.kioskName or "?", FormatGold(e.amount)))
            end
        end
    end

    PopulateTextList(GuildLedgerFrameKiosksPanelList, lines)
end

function GL.RefreshData()
    local frame = GuildLedgerFrame
    if not frame or frame:IsHidden() then return end

    local guildId = GetGuildId(GL.selectedGuildIndex)
    if not guildId or guildId == 0 then
        GuildLedgerFrameFooterStatus:SetText("|cFF6B6B" .. TiradilL10n.Get("STATUS_NO_VALID_GUILD") .. "|r")
        return
    end

    local guildName = GetGuildName(guildId)

    local bankGoldText
    local knownBankGold = nil -- canli veya cache'den bilinen en son deger (yoksa nil)
    local bankGoldSuffix = "" -- "(last seen X)" gibi ek bilgi, Available Guild Funds'a da eklenir
    local bankOk, bankGold = pcall(GetGuildBankedMoney, guildId)
    if bankOk and bankGold and bankGold > 0 then
        bankGoldText = FormatGold(bankGold)
        knownBankGold = bankGold
        GL.savedVars.bankCache[tostring(guildId)] = {
            amount = bankGold,
            time = os.time(),
        }
    else
        local cached = GL.savedVars.bankCache[tostring(guildId)]
        if cached then
            local dateStr = os.date("%d.%m %H:%M", cached.time)
            bankGoldSuffix = string.format(" (%s %s)", TiradilL10n.Get("BANK_GOLD_LAST_SEEN"), dateStr)
            bankGoldText = FormatGold(cached.amount) .. bankGoldSuffix
            knownBankGold = cached.amount
        else
            bankGoldText = TiradilL10n.Get("BANK_GOLD_UNAVAILABLE")
        end
    end

    local now = os.time()
    local minTime, maxTime = GetTimeframeRange()

    local totalSalesVolume = 0
    local totalGuildTax = 0
    local totalDeposits = 0
    local totalWithdrawals = 0
    local totalTraderBidsNet = 0

    local bankList = GL.bankEvents[GL.selectedGuildIndex] or {}
    for i = 1, #bankList do
        local e = bankList[i]
        if e.time >= minTime and e.time < maxTime then
            if e.type == GUILD_HISTORY_BANKED_CURRENCY_EVENT_DEPOSITED then
                totalDeposits = totalDeposits + e.amount
            elseif e.type == GUILD_HISTORY_BANKED_CURRENCY_EVENT_WITHDRAWN then
                totalWithdrawals = totalWithdrawals + e.amount
            elseif e.type == GUILD_HISTORY_BANKED_CURRENCY_EVENT_KIOSK_PURCHASED then
                totalTraderBidsNet = totalTraderBidsNet + e.amount
            end
        end
    end

    local wonBids, currentTraderBidsTotal = GetConfirmedWonBids(bankList)
    for i = 1, #wonBids do
        local b = wonBids[i]
        if b.periodTime >= minTime and b.periodTime < maxTime then
            totalTraderBidsNet = totalTraderBidsNet + b.amount
        end
    end

    local traderList = GL.traderEvents[GL.selectedGuildIndex] or {}
    for i = 1, #traderList do
        local e = traderList[i]
        if e.time >= minTime and e.time < maxTime then
            totalSalesVolume = totalSalesVolume + e.price
            totalGuildTax = totalGuildTax + e.tax
        end
    end

    local totalInflow = totalDeposits + totalGuildTax
    local totalOutflow = totalWithdrawals + totalTraderBidsNet
    local netProfit = totalInflow - totalOutflow

    GuildLedgerFrameBodyStatsColumnRow1Value:SetText(bankGoldText)
    GuildLedgerFrameBodyStatsColumnRow2Value:SetText(FormatGoldIcon(totalSalesVolume, 18))
    GuildLedgerFrameBodyStatsColumnRow3Value:SetText(FormatGoldSigned(totalGuildTax))
    GuildLedgerFrameBodyStatsColumnRow4Value:SetText(FormatGoldSigned(totalDeposits))

    if totalWithdrawals > 0 then
        GuildLedgerFrameBodyStatsColumnRow5Value:SetText("|cFF6B6B-" .. FormatGold(totalWithdrawals) .. "|r")
    else
        GuildLedgerFrameBodyStatsColumnRow5Value:SetText("0 Gold")
    end

    if totalTraderBidsNet > 0 then
        GuildLedgerFrameBodyStatsColumnRow6Value:SetText("|cFF6B6B-" .. FormatGold(totalTraderBidsNet) .. "|r")
    elseif totalTraderBidsNet < 0 then
        GuildLedgerFrameBodyStatsColumnRow6Value:SetText("|c4DDB4D+" .. FormatGold(-totalTraderBidsNet) .. "|r")
    else
        GuildLedgerFrameBodyStatsColumnRow6Value:SetText("0 Gold")
    end

    -- "Current Trader Bids": HENUZ SONUCLANMAMIS (reset+guvenlik payi gecmemis)
    -- bid'lerin toplami - bunlar bankadan dusulmus ama kaybederse iade
    -- edilecek, kazanirsa kalici gidere donusecek. Net Kar/Zarar'a KATILMAZ,
    -- sadece bilgi amacli gosterilir.
    GuildLedgerFrameBodyStatsColumnRow7Value:SetText(FormatGold(currentTraderBidsTotal or 0))

    -- "Available Guild Funds" = Bank Gold + Current Trader Bids - SADECE Bank
    -- Gold CANLI okunduysa hesaplanir. Bank Gold cache'den (bayat) geliyorsa,
    -- iki farkli zaman noktasini karistirmamak icin Bank Gold ile AYNI metni
    -- gosterir (yanlis bir toplam UYDURULMAZ).
    if knownBankGold then
        GuildLedgerFrameBodyStatsColumnRow8Value:SetText(FormatGold(knownBankGold + (currentTraderBidsTotal or 0)) .. bankGoldSuffix)
    else
        GuildLedgerFrameBodyStatsColumnRow8Value:SetText(bankGoldText)
    end

    local netLabel = GuildLedgerFrameBodyStatsColumnNetValue
    local netIcon = "|t18:18:esoui/art/bank/bank_tabicon_gold_up.dds|t "
    if netProfit >= 0 then
        netLabel:SetText(netIcon .. "|c4DDB4D+" .. FormatGold(netProfit) .. " (" .. TiradilL10n.Get("NET_PROFIT_LABEL") .. ")|r")
    else
        netLabel:SetText(netIcon .. "|cFF6B6B" .. FormatGold(netProfit) .. " (" .. TiradilL10n.Get("NET_LOSS_LABEL") .. ")|r")
    end

    if GL.selectedTimeframe == "week" then
        GuildLedgerFrameFooterStatus:SetText(string.format("[%s] - This Week's data (since Tuesday %s) calculated.", guildName, GetResetTimeLabel()))
    elseif GL.selectedTimeframe == "last_week" then
        GuildLedgerFrameFooterStatus:SetText(string.format("[%s] - Last Week's data calculated.", guildName))
    elseif GL.selectedTimeframe == "week_before_last" then
        GuildLedgerFrameFooterStatus:SetText(string.format("[%s] - 2 Weeks Ago's data calculated.", guildName))
    elseif GL.selectedTimeframe == "3_weeks_ago" then
        GuildLedgerFrameFooterStatus:SetText(string.format("[%s] - 3 Weeks Ago's data calculated.", guildName))
    elseif GL.selectedTimeframe == "4_weeks_ago" then
        GuildLedgerFrameFooterStatus:SetText(string.format("[%s] - 4 Weeks Ago's data calculated.", guildName))
    elseif GL.selectedTimeframe == "last_month" then
        GuildLedgerFrameFooterStatus:SetText(string.format("[%s] - Last month's full financial data calculated.", guildName))
    elseif GL.selectedTimeframe == "this_month" then
        GuildLedgerFrameFooterStatus:SetText(string.format("[%s] - This Month's data (since the 1st, UTC) calculated.", guildName))
    elseif GL.selectedTimeframe == "last_30_days" then
        GuildLedgerFrameFooterStatus:SetText(string.format("[%s] - Last 30 Days' data (rolling window) calculated.", guildName))
    else
        GuildLedgerFrameFooterStatus:SetText(string.format("[%s] - This Month's data calculated.", guildName))
    end

    GL.RefreshDonorsPanel(bankList, minTime, maxTime)
    GL.RefreshSellersPanel(traderList, minTime, maxTime)
    GL.RefreshBidsPanel(bankList, minTime, maxTime)
    GL.UpdatePanelTitles()
end

function GL.RefreshDonorsPanel(bankList, minTime, maxTime)
    local donorData = {}
    local order = {}
    local filterName = GL.searchFilter and NormalizeDisplayName(GL.searchFilter)

    for i = 1, #bankList do
        local e = bankList[i]
        if e.type == GUILD_HISTORY_BANKED_CURRENCY_EVENT_DEPOSITED and e.time >= minTime and e.time < maxTime then
            local name = e.displayName or "?"
            if not filterName or NormalizeDisplayName(name) == filterName then
                if not donorData[name] then
                    donorData[name] = { total = 0, entries = {} }
                    table.insert(order, name)
                end
                donorData[name].total = donorData[name].total + e.amount
                table.insert(donorData[name].entries, { time = e.time, amount = e.amount })
            end
        end
    end

    table.sort(order, function(a, b) return donorData[a].total > donorData[b].total end)
    for _, name in ipairs(order) do
        table.sort(donorData[name].entries, function(a, b) return a.time > b.time end)
    end

    local lines = {}
    if #order == 0 then
        table.insert(lines, "|cA0A0A0" .. TiradilL10n.Get("DONORS_NONE") .. "|r")
    else
        local donorCount = 0
        for _, name in ipairs(order) do
            donorCount = donorCount + 1
            if donorCount > 15 then break end
            local d = donorData[name]

            table.insert(lines, string.format("|cFFA500%s|r  -  %s", name, FormatGoldIcon(d.total, 16)))

            for _, entry in ipairs(d.entries) do
                local dateStr = os.date("%d.%m.%y %H:%M", entry.time)
                table.insert(lines, string.format("    |cA0A0A0%s|r: %s", dateStr, FormatGoldIcon(entry.amount, 12)))
            end
        end
    end

    PopulateTextList(GuildLedgerFrameBodyDonationsPanelDonorsList, lines)
end

function GL.RefreshSellersPanel(traderList, minTime, maxTime)
    local sellerData = {}
    local order = {}
    local filterName = GL.searchFilter and NormalizeDisplayName(GL.searchFilter)

    for i = 1, #traderList do
        local e = traderList[i]
        if e.time >= minTime and e.time < maxTime then
            local name = e.sellerDisplayName or "?"
            if not filterName or NormalizeDisplayName(name) == filterName then
                if not sellerData[name] then
                    sellerData[name] = { total = 0, entries = {} }
                    table.insert(order, name)
                end
                sellerData[name].total = sellerData[name].total + e.price
                table.insert(sellerData[name].entries, { time = e.time, amount = e.price })
            end
        end
    end

    table.sort(order, function(a, b) return sellerData[a].total > sellerData[b].total end)

    local sellerColorHex = "B366F0" -- guvenli fallback (eski mor), TiradilRoster yuklenemediyse kullanilir
    if TiradilRoster and TiradilRoster.GetGuildColor then
        local ok, r, g, b = pcall(TiradilRoster.GetGuildColor, GL.selectedGuildIndex)
        if ok and r then
            sellerColorHex = string.format("%02X%02X%02X", math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
        end
    end

    local lines = {}
    if #order == 0 then
        table.insert(lines, "|cA0A0A0" .. TiradilL10n.Get("SELLERS_NONE") .. "|r")
    else
        for _, name in ipairs(order) do
            local d = sellerData[name]
            table.insert(lines, string.format("|c%s%s|r  -  %s", sellerColorHex, name, FormatGoldIcon(d.total, 16)))
        end
    end

    PopulateTextList(GuildLedgerFrameBodyDonationsPanelSellersList, lines)
end

function GL.RefreshBidsPanel(bankList, minTime, maxTime)
    local bids = {}
    for i = 1, #bankList do
        local e = bankList[i]
        if e.type == GUILD_HISTORY_BANKED_CURRENCY_EVENT_KIOSK_BID and e.time >= minTime and e.time < maxTime then
            table.insert(bids, e)
        end
    end

    table.sort(bids, function(a, b) return a.amount > b.amount end)

    local lines = {}
    if #bids == 0 then
        table.insert(lines, "|cA0A0A0" .. TiradilL10n.Get("BIDS_NONE") .. "|r")
    else
        local count = 0
        for i = 1, #bids do
            count = count + 1
            if count > 10 then break end
            local e = bids[i]
            local dateStr = os.date("%d.%m.%y", e.time)
            table.insert(lines, string.format("|cA0A0A0%d. %s|r  %s: %s",
                count, dateStr, e.kioskName or "?", FormatGold(e.amount)))
        end
    end

    local confirmedInPeriod = {}
    for i = 1, #bankList do
        local e = bankList[i]
        if e.type == GUILD_HISTORY_BANKED_CURRENCY_EVENT_KIOSK_PURCHASED and e.time >= minTime and e.time < maxTime then
            table.insert(confirmedInPeriod, e)
        end
    end
    local wonBidsForPanel = GetConfirmedWonBids(bankList)
    for i = 1, #wonBidsForPanel do
        local b = wonBidsForPanel[i]
        if b.periodTime >= minTime and b.periodTime < maxTime then
            table.insert(confirmedInPeriod, b)
        end
    end
    table.sort(confirmedInPeriod, function(a, b) return a.time > b.time end)

    table.insert(lines, "")
    table.insert(lines, "|cFF6B6B" .. TiradilL10n.Get("CONFIRMED_EXPENSES_TITLE") .. "|r")
    if #confirmedInPeriod == 0 then
        table.insert(lines, "|cA0A0A0" .. TiradilL10n.Get("CONFIRMED_EXPENSES_NONE") .. "|r")
    else
        for i = 1, #confirmedInPeriod do
            local b = confirmedInPeriod[i]
            local dateStr = os.date("%d.%m.%y", b.time)
            table.insert(lines, string.format("|cA0A0A0%s|r  %s: %s",
                dateStr, b.kioskName or "?", FormatGold(b.amount)))
        end
    end

    PopulateTextList(GuildLedgerFrameBodyBidsPanelList, lines)
end
