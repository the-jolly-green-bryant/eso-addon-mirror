TiradilTrader = {}
local TT = TiradilTrader

local function FormatGold(amount)
    local formatted = tostring(math.floor(math.abs(amount or 0)))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    if (amount or 0) < 0 then
        return "-" .. formatted .. " Gold"
    else
        return formatted .. " Gold"
    end
end

local function FormatCompactGold(amount)
    amount = math.abs(amount or 0)
    if amount >= 1000000 then
        return string.format("%.1fM", amount / 1000000)
    elseif amount >= 1000 then
        return string.format("%.0fK", amount / 1000)
    else
        return string.format("%.0f", amount)
    end
end

function TT.RefreshCurrentView()
    if TiradilTraderFrameDonationsPanel and not TiradilTraderFrameDonationsPanel:IsHidden() then
        TT.RefreshDonationsPanel()
    else
        TT.RefreshData()
    end
end

function TT.ToggleWindow()
    if TiradilTraderFrame:IsHidden() then
        TiradilTraderFrame:SetHidden(false)
        TT.RefreshDonationsPanel()
    else
        TiradilTraderFrame:SetHidden(true)
    end
end

local TEXT_ROW_TYPE = 1
local TEXT_ROW_HEIGHT = 20

local function SetupTextRow(control, data)
    control:GetNamedChild("Label"):SetText(data.text)
end

local function InitializeList(listControl, templateName, rowHeight)
    if not listControl then return end
    templateName = templateName or "GuildLedgerTextRowTemplate"
    rowHeight = rowHeight or TEXT_ROW_HEIGHT
    ZO_ScrollList_AddDataType(listControl, TEXT_ROW_TYPE, templateName, rowHeight, SetupTextRow)
end

local function PopulateList(listControl, lines)
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

local function ComputeTotalsForTimeframe(timeframe, guildIndexFilter)
    local minTime, maxTime = GuildLedger.GetTimeframeRangeFor(timeframe)
    local numGuilds = GetNumGuilds()
    local totalTax, totalCost = 0, 0
    local bidLines = {}

    for guildIndex = 1, numGuilds do
        if not guildIndexFilter or guildIndexFilter == guildIndex then
            local guildId = GetGuildId(guildIndex)
            if guildId and guildId ~= 0 then
                local guildName = GetGuildName(guildId) or "?"

                local tax, cost, wonBidsInPeriod, bidPlacementsInPeriod =
                    GuildLedger.ComputeTraderStatsForGuild(guildIndex, minTime, maxTime)
                totalTax = totalTax + tax
                totalCost = totalCost + cost

                for i = 1, #bidPlacementsInPeriod do
                    local e = bidPlacementsInPeriod[i]
                    table.insert(bidLines, {
                        time = e.time,
                        text = string.format("|cA0A0A0%s|r  %s - %s  |cFFFFFF%s|r",
                            os.date("%d.%m.%y", e.time), guildName, e.kioskName or "?", FormatGold(math.abs(e.amount))),
                    })
                end
            end
        end
    end

    return totalTax, totalCost, bidLines
end

-- Her kiosk'un TEK TEK bid gecmisini toplar (kazandi/kaybetti + tutar) -
-- ayni tradera FARKLI zamanlarda ne kadar verdigimizi karsilastirabilmek
-- icin. GL.ComputeTraderStatsForGuild'in won/lost listelerini kullanir -
-- ayri bir hesaplama YAZMAZ, tek dogruluk kaynagi.
local function ComputeBidTrends(minTime, maxTime, guildIndexFilter)
    local numGuilds = GetNumGuilds()
    local byKiosk = {}

    for guildIndex = 1, numGuilds do
        if not guildIndexFilter or guildIndexFilter == guildIndex then
            local guildId = GetGuildId(guildIndex)
            if guildId and guildId ~= 0 then
                local guildName = GetGuildName(guildId) or "?"
                local tax, cost, wonBidsInPeriod, bidPlacementsInPeriod, lostBidsInPeriod =
                    GuildLedger.ComputeTraderStatsForGuild(guildIndex, minTime, maxTime)

                for i = 1, #wonBidsInPeriod do
                    local b = wonBidsInPeriod[i]
                    local key = string.lower(b.kioskName or "?")
                    byKiosk[key] = byKiosk[key] or { displayName = b.kioskName or "?", entries = {} }
                    table.insert(byKiosk[key].entries, { time = b.time, amount = b.amount, status = "won", guildName = guildName })
                end
                for i = 1, #(lostBidsInPeriod or {}) do
                    local b = lostBidsInPeriod[i]
                    local key = string.lower(b.kioskName or "?")
                    byKiosk[key] = byKiosk[key] or { displayName = b.kioskName or "?", entries = {} }
                    table.insert(byKiosk[key].entries, { time = b.time, amount = b.amount, status = "lost", guildName = guildName })
                end

                local bankList = GuildLedger.bankEvents[guildIndex] or {}
                for i = 1, #bankList do
                    local e = bankList[i]
                    if e.time >= minTime and e.time < maxTime and e.type == GUILD_HISTORY_BANKED_CURRENCY_EVENT_KIOSK_PURCHASED then
                        local key = string.lower(e.kioskName or "?")
                        byKiosk[key] = byKiosk[key] or { displayName = e.kioskName or "?", entries = {} }
                        table.insert(byKiosk[key].entries, { time = e.time, amount = e.amount, status = "rented", guildName = guildName })
                    end
                end
            end
        end
    end

    return byKiosk
end

local function BuildBidTrendLines(byKiosk)
    local lines = {}
    for _, kiosk in pairs(byKiosk) do
        table.sort(kiosk.entries, function(a, b) return a.time > b.time end)
    end

    local keys = {}
    for key in pairs(byKiosk) do table.insert(keys, key) end
    table.sort(keys, function(a, b) return byKiosk[a].entries[1].time > byKiosk[b].entries[1].time end)

    for _, key in ipairs(keys) do
        local kiosk = byKiosk[key]
        local latest = kiosk.entries[1]
        local wins, losses, rents = 0, 0, 0
        for _, e in ipairs(kiosk.entries) do
            if e.status == "won" then wins = wins + 1
            elseif e.status == "lost" then losses = losses + 1
            else rents = rents + 1 end
        end

        local statusColor, statusText
        if latest.status == "won" then
            statusColor, statusText = "4DDB4D", TiradilL10n.Get("TRADER_BID_WON")
        elseif latest.status == "lost" then
            statusColor, statusText = "FF6B6B", TiradilL10n.Get("TRADER_BID_LOST")
        else
            statusColor, statusText = "4A9EFF", TiradilL10n.Get("TRADER_BID_RENTED")
        end

        local trendText = ""
        local previous = kiosk.entries[2]
        if previous and previous.amount > 0 then
            local pctChange = ((latest.amount - previous.amount) / previous.amount) * 100
            if math.abs(pctChange) >= 1 then
                local sign = pctChange >= 0 and "+" or ""
                local trendColor = pctChange >= 0 and "FF6B6B" or "4DDB4D"
                trendText = string.format("  |c%s(%s%.0f%% %s)|r", trendColor, sign, pctChange, TiradilL10n.Get("TRADER_VS_LAST_BID"))
            end
        end

        table.insert(lines, {
            time = latest.time,
            text = string.format("|cFFB800%s|r (%s)  %s  |c%s%s: %s|r%s",
                kiosk.displayName, latest.guildName, os.date("%d.%m.%y", latest.time),
                statusColor, statusText, FormatGold(latest.amount), trendText),
        })
    end

    return lines
end

local PREVIOUS_PERIOD = {
    week = "last_week",
    last_week = "week_before_last",
    this_month = "last_month",
}

local function FormatPercentChange(current, previous)
    if not previous or previous == 0 then return nil end
    local pct = ((current - previous) / math.abs(previous)) * 100
    if pct >= 0 then
        return string.format("|c4DDB4D+%.0f%%|r", pct)
    else
        return string.format("|cFF6B6B%.0f%%|r", pct)
    end
end

function TT.RefreshData()
    if not (TiradilTraderFrame and not TiradilTraderFrame:IsHidden()) then return end
    if not GuildLedger then return end

    local timeframe = TT.selectedTimeframe or "week"
    local guildFilter = TT.selectedGuildIndex
    local totalTax, totalCost, bidLines = ComputeTotalsForTimeframe(timeframe, guildFilter)

    local minTime, maxTime = GuildLedger.GetTimeframeRangeFor(timeframe)
    local byKiosk = ComputeBidTrends(minTime, maxTime, guildFilter)
    local historyLines = BuildBidTrendLines(byKiosk)

    table.sort(historyLines, function(a, b) return a.time > b.time end)
    table.sort(bidLines, function(a, b) return a.time > b.time end)

    local MAX_ROWS = 40
    local historyTextLines = {}
    for i = 1, math.min(#historyLines, MAX_ROWS) do
        table.insert(historyTextLines, historyLines[i].text)
    end
    local bidTextLines = {}
    for i = 1, math.min(#bidLines, MAX_ROWS) do
        table.insert(bidTextLines, bidLines[i].text)
    end

    TiradilTraderFrameBodyRoiColumnRow1Value:SetText(FormatGold(totalTax))
    TiradilTraderFrameBodyRoiColumnRow2Value:SetText(FormatGold(totalCost))

    local net = totalTax - totalCost
    local netLabel = TiradilTraderFrameBodyRoiColumnNetValue
    if net >= 0 then
        netLabel:SetText("|c4DDB4D+" .. FormatGold(net) .. "|r")
    else
        netLabel:SetText("|cFF6B6B" .. FormatGold(net) .. "|r")
    end

    local previousTimeframe = PREVIOUS_PERIOD[timeframe]
    local periodLabel = GuildLedger.GetPeriodLabelFor(timeframe)
    local subtitleText = zo_strformat(TiradilL10n.Get("TRADER_ROI_SUBTITLE"), periodLabel)
    if previousTimeframe then
        local prevTax, prevCost = ComputeTotalsForTimeframe(previousTimeframe, guildFilter)
        local revenueChange = FormatPercentChange(totalTax, prevTax)
        local costChange = FormatPercentChange(totalCost, prevCost)
        if revenueChange or costChange then
            subtitleText = subtitleText .. "  |  " ..
                TiradilL10n.Get("TRADER_REVENUE_SHORT") .. " " .. (revenueChange or "-") .. "  " ..
                TiradilL10n.Get("TRADER_COST_SHORT") .. " " .. (costChange or "-") .. "  " ..
                TiradilL10n.Get("TRADER_VS_PREVIOUS")
        end
    end
    TiradilTraderFrameBodyRoiColumnSubtitleLabel:SetText(subtitleText)

    zo_callLater(function()
        local roiColumn = TiradilTraderFrameBodyRoiColumn
        local subtitleLabel = TiradilTraderFrameBodyRoiColumnSubtitleLabel
        if roiColumn and subtitleLabel then
            local contentHeight = (subtitleLabel:GetBottom() or 0) - (roiColumn:GetTop() or 0) + 16
            if contentHeight > 0 then
                roiColumn:SetHeight(contentHeight)
            end
        end
    end, 0)

    PopulateList(TiradilTraderFrameBodyHistoryColumnList, historyTextLines)
    TiradilTraderFrameBodyHistoryColumnNone:SetText(#historyTextLines == 0 and TiradilL10n.Get("TRADER_HISTORY_NONE") or "")

    PopulateList(TiradilTraderFrameBodyBidsColumnList, bidTextLines)
    TiradilTraderFrameBodyBidsColumnNone:SetText(#bidTextLines == 0 and TiradilL10n.Get("TRADER_BIDS_NONE") or "")

    if guildFilter then
        local guildId = GetGuildId(guildFilter)
        TiradilTraderFrameFooterStatus:SetText(zo_strformat(TiradilL10n.Get("TRADER_STATUS_ONE_GUILD"), GetGuildName(guildId) or "?"))
    else
        TiradilTraderFrameFooterStatus:SetText(TiradilL10n.Get("TRADER_STATUS_ALL_GUILDS"))
    end
end

local function GetGuildChoices()
    local choices = {}
    local numGuilds = GetNumGuilds()
    for i = 1, numGuilds do
        local guildId = GetGuildId(i)
        if guildId and guildId ~= 0 then
            table.insert(choices, { name = GetGuildName(guildId), guildIndex = i })
        end
    end
    return choices
end

function TT.Initialize()
    InitializeList(TiradilTraderFrameBodyHistoryColumnList)
    InitializeList(TiradilTraderFrameBodyBidsColumnList)

    TT.selectedTimeframe = "week"
    TT.selectedGuildIndex = nil

    TT.BuildPeriodCombo()
    TT.BuildGuildCombo()
    TT.BuildChartTypeCombo()
    TT.BuildChartMetricCombo()
    TT.BuildChartGuildCombo()
    TT.BuildContribPeriodCombo()
    TT.BuildContribMetricCombo()
    TT.BuildContribGuildCombo()
    TiradilTraderFrameDonationsPanelChartControlsRowChartMetricLabel:SetHidden(TT.chartMode ~= "guild")
    TiradilTraderFrameDonationsPanelChartControlsRowChartMetricCombo:SetHidden(TT.chartMode ~= "guild")
    TiradilTraderFrameDonationsPanelChartControlsRowChartGuildLabel:SetHidden(TT.chartMode == "guild")
    TiradilTraderFrameDonationsPanelChartControlsRowChartGuildCombo:SetHidden(TT.chartMode == "guild")

    InitializeList(TiradilTraderFrameDonationsPanelDonorsList, "GuildLedgerTextRowTemplateLarge", 26)
end


function TT.ToggleDonationsPanel()
    local body = TiradilTraderFrameBody
    local donations = TiradilTraderFrameDonationsPanel
    local filterArea = TiradilTraderFrameFilterArea
    if not (body and donations) then return end

    if donations:IsHidden() then
        body:SetHidden(true)
        donations:SetHidden(false)
        if filterArea then filterArea:SetHidden(true) end
        TT.RefreshDonationsPanel()
    else
        body:SetHidden(false)
        donations:SetHidden(true)
        if filterArea then filterArea:SetHidden(false) end
        TT.RefreshData()
    end
end

local function ComputeDonationTotals(minTime, maxTime, guildIndexFilter)
    local total = 0
    local byDonor = {}
    local numGuilds = GetNumGuilds()
    for guildIndex = 1, numGuilds do
        if not guildIndexFilter or guildIndexFilter == guildIndex then
            local bankList = GuildLedger.bankEvents[guildIndex] or {}
            for i = 1, #bankList do
                local e = bankList[i]
                if e.type == GUILD_HISTORY_BANKED_CURRENCY_EVENT_DEPOSITED
                    and e.time >= minTime and e.time < maxTime and e.displayName then
                    total = total + e.amount
                    byDonor[e.displayName] = (byDonor[e.displayName] or 0) + e.amount
                end
            end
        end
    end
    return total, byDonor
end

local function ComputeSalesTotals(minTime, maxTime, guildIndexFilter)
    local total = 0
    local bySeller = {}
    local numGuilds = GetNumGuilds()
    for guildIndex = 1, numGuilds do
        if not guildIndexFilter or guildIndexFilter == guildIndex then
            local traderList = GuildLedger.traderEvents[guildIndex] or {}
            for i = 1, #traderList do
                local e = traderList[i]
                if e.time >= minTime and e.time < maxTime and e.sellerDisplayName then
                    total = total + (e.price or 0)
                    bySeller[e.sellerDisplayName] = (bySeller[e.sellerDisplayName] or 0) + (e.price or 0)
                end
            end
        end
    end
    return total, bySeller
end

local function ComputeWeeklyTaxAndProfitLoss(minTime, maxTime, guildIndexFilter)
    local numGuilds = GetNumGuilds()
    local totalTax, totalCost = 0, 0
    local totalDeposits, totalWithdrawals = 0, 0
    for guildIndex = 1, numGuilds do
        if not guildIndexFilter or guildIndexFilter == guildIndex then
            local tax, cost = GuildLedger.ComputeTraderStatsForGuild(guildIndex, minTime, maxTime)
            totalTax = totalTax + tax
            totalCost = totalCost + cost
            local bankList = GuildLedger.bankEvents[guildIndex] or {}
            for i = 1, #bankList do
                local e = bankList[i]
                if e.time >= minTime and e.time < maxTime then
                    if e.type == GUILD_HISTORY_BANKED_CURRENCY_EVENT_DEPOSITED then
                        totalDeposits = totalDeposits + e.amount
                    elseif e.type == GUILD_HISTORY_BANKED_CURRENCY_EVENT_WITHDRAWN then
                        totalWithdrawals = totalWithdrawals + e.amount
                    end
                end
            end
        end
    end
    local profitLoss = (totalDeposits + totalTax) - (totalWithdrawals + totalCost)
    return totalTax, profitLoss, totalCost
end

local METRIC_COLOR = {
    Income = "4DDB4D",
    Donations = "FFB800",
    ProfitLoss = "4A9EFF",
    TraderCost = "FF4444",
}
local METRIC_KEY_ORDER = { "Income", "Donations", "ProfitLoss", "TraderCost" }

TT.chartMode = TT.chartMode or "metric"
TT.chartGuildMetric = TT.chartGuildMetric or "Donations"
TT.chartMetricEnabled = TT.chartMetricEnabled or { Income = true, Donations = true, ProfitLoss = true, TraderCost = true }
TT.chartGuildEnabled = TT.chartGuildEnabled or {}
TT.chartGuildFilter = TT.chartGuildFilter

TT.contribPeriod = TT.contribPeriod or "week"
TT.contribMetric = TT.contribMetric or "Donations"
TT.contribGuildFilter = TT.contribGuildFilter

function TT.SetChartMode(mode)
    TT.chartMode = mode
    TiradilTraderFrameDonationsPanelChartControlsRowChartMetricLabel:SetHidden(mode ~= "guild")
    TiradilTraderFrameDonationsPanelChartControlsRowChartMetricCombo:SetHidden(mode ~= "guild")
    TiradilTraderFrameDonationsPanelChartControlsRowChartGuildLabel:SetHidden(mode == "guild")
    TiradilTraderFrameDonationsPanelChartControlsRowChartGuildCombo:SetHidden(mode == "guild")
    TT.RefreshDonationsPanel()
end

function TT.SetChartGuildFilter(guildIndex)
    TT.chartGuildFilter = guildIndex
    TT.RefreshDonationsPanel()
end

function TT.SetChartGuildMetric(metric)
    TT.chartGuildMetric = metric
    TT.RefreshDonationsPanel()
end

function TT.SetContribPeriod(timeframe)
    TT.contribPeriod = timeframe
    TT.RefreshDonationsPanel()
end

function TT.SetContribMetric(metric)
    TT.contribMetric = metric
    TT.RefreshDonationsPanel()
end

function TT.SetContribGuildFilter(guildIndex)
    TT.contribGuildFilter = guildIndex
    TT.RefreshDonationsPanel()
end

function TT.ToggleChartLegendItem(index)
    if TT.chartMode == "guild" then
        local guilds = TT.GetGuildChoicesCached and TT.GetGuildChoicesCached() or {}
        local g = guilds[index]
        if g then
            local key = g.guildIndex
            if TT.chartGuildEnabled[key] == nil then TT.chartGuildEnabled[key] = true end
            TT.chartGuildEnabled[key] = not TT.chartGuildEnabled[key]
        end
    else
        local metricKey = METRIC_KEY_ORDER[index]
        if metricKey then
            TT.chartMetricEnabled[metricKey] = not TT.chartMetricEnabled[metricKey]
        end
    end
    TT.RefreshDonationsPanel()
end

function TT.GetGuildChoicesCached()
    return GetGuildChoices()
end

local function ComputeWeekSeries(weekStart, weekEnd)
    local series = {}
    if TT.chartMode == "guild" then
        for _, g in ipairs(GetGuildChoices()) do
            local value
            if TT.chartGuildMetric == "Income" then
                value = select(1, ComputeWeeklyTaxAndProfitLoss(weekStart, weekEnd, g.guildIndex))
            elseif TT.chartGuildMetric == "ProfitLoss" then
                value = select(2, ComputeWeeklyTaxAndProfitLoss(weekStart, weekEnd, g.guildIndex))
            else
                value = select(1, ComputeDonationTotals(weekStart, weekEnd, g.guildIndex))
            end
            series[g.guildIndex] = value
        end
    else
        local guildFilter = TT.chartGuildFilter
        local tax, profitLoss, traderCost = ComputeWeeklyTaxAndProfitLoss(weekStart, weekEnd, guildFilter)
        local donations = select(1, ComputeDonationTotals(weekStart, weekEnd, guildFilter))
        series.Income = tax
        series.Donations = donations
        series.ProfitLoss = profitLoss
        series.TraderCost = -math.abs(traderCost or 0)
    end
    return series
end

local MAX_BAR_HEIGHT = 100

local function SetBarValue(bar, value, maxScale)
    if not bar then return end
    bar:ClearAnchors()
    local height = 2
    if maxScale > 0 then
        height = math.max(2, math.floor((math.abs(value) / maxScale) * MAX_BAR_HEIGHT))
    end
    local baseline = TiradilTraderFrameDonationsPanelChartAreaBaseline
    local point = value >= 0 and BOTTOM or TOP
    local offsetX = bar.tiradilOffsetX or 0
    bar:SetAnchor(point, baseline, CENTER, offsetX, 0)
    bar:SetHeight(height)
end

function TT.RefreshDonationsPanel()
    if not (TiradilTraderFrameDonationsPanel and not TiradilTraderFrameDonationsPanel:IsHidden()) then return end
    if not GuildLedger then return end

    local contribMinTime, contribMaxTime = GuildLedger.GetTimeframeRangeFor(TT.contribPeriod)
    local total, byName
    if TT.contribMetric == "Sales" then
        total, byName = ComputeSalesTotals(contribMinTime, contribMaxTime, TT.contribGuildFilter)
        TiradilTraderFrameDonationsPanelTotalLabel:SetText(TiradilL10n.Get("TRADER_SALES_TOTAL_LABEL"))
        TiradilTraderFrameDonationsPanelDonorsTitle:SetText(TiradilL10n.Get("TRADER_TOP_SELLERS_TITLE"))
        TiradilTraderFrameDonationsPanelDonorsNone:SetText(TiradilL10n.Get("TRADER_SALES_NONE"))
    else
        total, byName = ComputeDonationTotals(contribMinTime, contribMaxTime, TT.contribGuildFilter)
        TiradilTraderFrameDonationsPanelTotalLabel:SetText(TiradilL10n.Get("TRADER_DONATIONS_TOTAL_LABEL"))
        TiradilTraderFrameDonationsPanelDonorsTitle:SetText(TiradilL10n.Get("TRADER_TOP_DONORS_TITLE"))
        TiradilTraderFrameDonationsPanelDonorsNone:SetText(TiradilL10n.Get("TRADER_DONATIONS_NONE"))
    end
    TiradilTraderFrameDonationsPanelTotalValue:SetText(FormatGold(total))

    local sorted = {}
    for name, amount in pairs(byName) do
        table.insert(sorted, { name = name, amount = amount })
    end
    table.sort(sorted, function(a, b) return a.amount > b.amount end)

    local donorLines = {}
    for i = 1, math.min(#sorted, 30) do
        table.insert(donorLines, string.format("|cFFB800%s|r  |cFFFFFF%s|r", sorted[i].name, FormatGold(sorted[i].amount)))
    end
    PopulateList(TiradilTraderFrameDonationsPanelDonorsList, donorLines)
    if #donorLines > 0 then
        TiradilTraderFrameDonationsPanelDonorsNone:SetText("")
    end

    local thisWeekStart = GuildLedger.GetTimeframeRangeFor("week")
    local weeklySeries = {}
    local maxScale = 0

    local activeKeys = {}
    if TT.chartMode == "guild" then
        for _, g in ipairs(GetGuildChoices()) do
            table.insert(activeKeys, g.guildIndex)
        end
    else
        activeKeys = METRIC_KEY_ORDER
    end

    for w = 0, 7 do
        local weekStart = thisWeekStart - (7 - w) * 7 * 86400
        local weekEnd = weekStart + 7 * 86400
        local series = ComputeWeekSeries(weekStart, weekEnd)
        weeklySeries[w + 1] = series
        for _, key in ipairs(activeKeys) do
            local enabled
            if TT.chartMode == "guild" then
                enabled = TT.chartGuildEnabled[key] ~= false
            else
                enabled = TT.chartMetricEnabled[key]
            end
            if enabled and series[key] and math.abs(series[key]) > maxScale then
                maxScale = math.abs(series[key])
            end
        end
    end

    local SLOT_OFFSETS = { -32, -16, 0, 16, 32 }
    local WEEK_CENTERS = { -350, -250, -150, -50, 50, 150, 250, 350 }

    for i = 1, 4 do
        local fraction = i * 0.25
        local value = maxScale * fraction
        local text = maxScale > 0 and FormatCompactGold(value) or ""
        local upLabel = _G["TiradilTraderFrameDonationsPanelChartAreaGridUp" .. i .. "Label"]
        local downLabel = _G["TiradilTraderFrameDonationsPanelChartAreaGridDown" .. i .. "Label"]
        if upLabel then upLabel:SetText(text) end
        if downLabel then downLabel:SetText(maxScale > 0 and ("-" .. text) or "") end
    end

    for w = 1, 8 do
        local center = WEEK_CENTERS[w]
        for s = 1, 5 do
            local bar = _G["TiradilTraderFrameDonationsPanelChartAreaWeek" .. w .. "Slot" .. s .. "Bar"]
            if bar then
                bar.tiradilOffsetX = center + SLOT_OFFSETS[s]
                local key = activeKeys[s]
                local enabled
                if TT.chartMode == "guild" then
                    enabled = key and (TT.chartGuildEnabled[key] ~= false)
                else
                    enabled = key and TT.chartMetricEnabled[key]
                end
                if key and enabled then
                    bar:SetHidden(false)
                    local value = weeklySeries[w][key] or 0
                    local color
                    if TT.chartMode == "guild" then
                        local r, g, b = TiradilRoster.GetGuildColor(key)
                        color = string.format("%02X%02X%02X", math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
                    else
                        color = METRIC_COLOR[key]
                    end
                    bar:SetCenterColor(tonumber(color:sub(1, 2), 16) / 255, tonumber(color:sub(3, 4), 16) / 255, tonumber(color:sub(5, 6), 16) / 255, 0.8)
                    SetBarValue(bar, value, maxScale)
                else
                    bar:SetHidden(true)
                end
            end
        end
        local label = _G["TiradilTraderFrameDonationsPanelChartAreaWeek" .. w .. "Label"]
        if label then
            if w == 8 then
                label:SetText(TiradilL10n.Get("TRADER_CHART_THIS_WEEK"))
            else
                label:SetText(string.format("-%d", 8 - w))
            end
        end
    end

    for i = 1, 5 do
        local btn = _G["TiradilTraderFrameDonationsPanelChartLegendLegend" .. i]
        if btn then
            if TT.chartMode == "guild" then
                local g = (GetGuildChoices())[i]
                if g then
                    btn:SetHidden(false)
                    local r, gr, b = TiradilRoster.GetGuildColor(g.guildIndex)
                    local hex = string.format("%02X%02X%02X", math.floor(r * 255), math.floor(gr * 255), math.floor(b * 255))
                    local enabled = TT.chartGuildEnabled[g.guildIndex] ~= false
                    btn:SetText("|c" .. hex .. g.name .. "|r")
                    btn:SetAlpha(enabled and 1 or 0.35)
                else
                    btn:SetHidden(true)
                end
            else
                local metricKey = METRIC_KEY_ORDER[i]
                if metricKey then
                    btn:SetHidden(false)
                    local nameKey = metricKey == "Income" and "TRADER_CHART_INCOME"
                        or metricKey == "Donations" and "TRADER_CHART_DONATIONS"
                        or metricKey == "ProfitLoss" and "TRADER_CHART_PROFIT_LOSS"
                        or "TRADER_CHART_TRADER_COST"
                    btn:SetText("|c" .. METRIC_COLOR[metricKey] .. TiradilL10n.Get(nameKey) .. "|r")
                    btn:SetAlpha(TT.chartMetricEnabled[metricKey] and 1 or 0.35)
                else
                    btn:SetHidden(true)
                end
            end
        end
    end
end

function TT.BuildPeriodCombo()
    local periodCombo = TiradilTraderFrameFilterAreaPeriodCombo
    if not periodCombo then return end
    local comboObj = ZO_ComboBox_ObjectFromContainer(periodCombo)
    local currentValue = TT.selectedTimeframe or "week"
    comboObj:ClearItems()
    comboObj:SetSortsItems(false)
    local options = {
        { name = TiradilL10n.Get("PERIOD_THIS_WEEK"), value = "week" },
        { name = TiradilL10n.Get("PERIOD_LAST_WEEK"), value = "last_week" },
        { name = TiradilL10n.Get("PERIOD_THIS_MONTH"), value = "this_month" },
        { name = TiradilL10n.Get("PERIOD_LAST_MONTH"), value = "last_month" },
        { name = TiradilL10n.Get("PERIOD_LAST_30_DAYS"), value = "last_30_days" },
        { name = TiradilL10n.Get("PERIOD_ALL_TIME"), value = "all_time" },
    }
    local selectIndex = 1
    for i, opt in ipairs(options) do
        local entry = comboObj:CreateItemEntry(opt.name, function()
            TT.selectedTimeframe = opt.value
            TT.RefreshCurrentView()
        end)
        comboObj:AddItem(entry)
        if opt.value == currentValue then selectIndex = i end
    end
    comboObj:SelectItemByIndex(selectIndex)
end

function TT.BuildGuildCombo()
    local guildCombo = TiradilTraderFrameFilterAreaGuildCombo
    if not guildCombo then return end
    local comboObj = ZO_ComboBox_ObjectFromContainer(guildCombo)
    local currentValue = TT.selectedGuildIndex
    comboObj:ClearItems()
    comboObj:SetSortsItems(false)

    local selectIndex = 1
    local allEntry = comboObj:CreateItemEntry(TiradilL10n.Get("TRADER_ALL_GUILDS_OPTION"), function()
        TT.selectedGuildIndex = nil
        TT.RefreshCurrentView()
    end)
    comboObj:AddItem(allEntry)

    local i = 1
    for _, g in ipairs(GetGuildChoices()) do
        i = i + 1
        local entry = comboObj:CreateItemEntry(g.name, function()
            TT.selectedGuildIndex = g.guildIndex
            TT.RefreshCurrentView()
        end)
        comboObj:AddItem(entry)
        if currentValue == g.guildIndex then selectIndex = i end
    end
    comboObj:SelectItemByIndex(selectIndex)
end

function TT.BuildChartTypeCombo()
    local combo = TiradilTraderFrameDonationsPanelChartControlsRowChartTypeCombo
    if not combo then return end
    local comboObj = ZO_ComboBox_ObjectFromContainer(combo)
    comboObj:ClearItems()
    comboObj:SetSortsItems(false)
    local options = {
        { name = TiradilL10n.Get("TRADER_CHART_MODE_METRIC"), value = "metric" },
        { name = TiradilL10n.Get("TRADER_CHART_MODE_GUILD"), value = "guild" },
    }
    local selectIndex = 1
    for i, opt in ipairs(options) do
        local entry = comboObj:CreateItemEntry(opt.name, function()
            TT.SetChartMode(opt.value)
        end)
        comboObj:AddItem(entry)
        if opt.value == TT.chartMode then selectIndex = i end
    end
    comboObj:SelectItemByIndex(selectIndex)
end

function TT.BuildChartMetricCombo()
    local combo = TiradilTraderFrameDonationsPanelChartControlsRowChartMetricCombo
    if not combo then return end
    local comboObj = ZO_ComboBox_ObjectFromContainer(combo)
    comboObj:ClearItems()
    comboObj:SetSortsItems(false)
    local options = {
        { name = TiradilL10n.Get("TRADER_CHART_DONATIONS"), value = "Donations" },
        { name = TiradilL10n.Get("TRADER_CHART_INCOME"), value = "Income" },
        { name = TiradilL10n.Get("TRADER_CHART_PROFIT_LOSS"), value = "ProfitLoss" },
    }
    local selectIndex = 1
    for i, opt in ipairs(options) do
        local entry = comboObj:CreateItemEntry(opt.name, function()
            TT.SetChartGuildMetric(opt.value)
        end)
        comboObj:AddItem(entry)
        if opt.value == TT.chartGuildMetric then selectIndex = i end
    end
    comboObj:SelectItemByIndex(selectIndex)
end

local function BuildGuildFilterCombo(comboControl, currentValue, setterFunc)
    if not comboControl then return end
    local comboObj = ZO_ComboBox_ObjectFromContainer(comboControl)
    comboObj:ClearItems()
    comboObj:SetSortsItems(false)
    local selectIndex = 1
    local allEntry = comboObj:CreateItemEntry(TiradilL10n.Get("TRADER_ALL_GUILDS_OPTION"), function()
        setterFunc(nil)
    end)
    comboObj:AddItem(allEntry)
    local i = 1
    for _, g in ipairs(GetGuildChoices()) do
        i = i + 1
        local entry = comboObj:CreateItemEntry(g.name, function()
            setterFunc(g.guildIndex)
        end)
        comboObj:AddItem(entry)
        if currentValue == g.guildIndex then selectIndex = i end
    end
    comboObj:SelectItemByIndex(selectIndex)
end

local function BuildPeriodFilterCombo(comboControl, currentValue, setterFunc)
    if not comboControl then return end
    local comboObj = ZO_ComboBox_ObjectFromContainer(comboControl)
    comboObj:ClearItems()
    comboObj:SetSortsItems(false)
    local options = {
        { name = TiradilL10n.Get("PERIOD_THIS_WEEK"), value = "week" },
        { name = TiradilL10n.Get("PERIOD_LAST_WEEK"), value = "last_week" },
        { name = TiradilL10n.Get("PERIOD_THIS_MONTH"), value = "this_month" },
        { name = TiradilL10n.Get("PERIOD_LAST_MONTH"), value = "last_month" },
        { name = TiradilL10n.Get("PERIOD_LAST_30_DAYS"), value = "last_30_days" },
        { name = TiradilL10n.Get("PERIOD_ALL_TIME"), value = "all_time" },
    }
    local selectIndex = 1
    for i, opt in ipairs(options) do
        local entry = comboObj:CreateItemEntry(opt.name, function()
            setterFunc(opt.value)
        end)
        comboObj:AddItem(entry)
        if opt.value == currentValue then selectIndex = i end
    end
    comboObj:SelectItemByIndex(selectIndex)
end

function TT.BuildChartGuildCombo()
    BuildGuildFilterCombo(TiradilTraderFrameDonationsPanelChartControlsRowChartGuildCombo, TT.chartGuildFilter, TT.SetChartGuildFilter)
end

function TT.BuildContribPeriodCombo()
    BuildPeriodFilterCombo(TiradilTraderFrameDonationsPanelContributorsControlsRowPeriodCombo, TT.contribPeriod, TT.SetContribPeriod)
end

function TT.BuildContribMetricCombo()
    local combo = TiradilTraderFrameDonationsPanelContributorsControlsRowMetricCombo
    if not combo then return end
    local comboObj = ZO_ComboBox_ObjectFromContainer(combo)
    comboObj:ClearItems()
    comboObj:SetSortsItems(false)
    local options = {
        { name = TiradilL10n.Get("TRADER_CHART_DONATIONS"), value = "Donations" },
        { name = TiradilL10n.Get("TRADER_CHART_SALES_OPTION"), value = "Sales" },
    }
    local selectIndex = 1
    for i, opt in ipairs(options) do
        local entry = comboObj:CreateItemEntry(opt.name, function()
            TT.SetContribMetric(opt.value)
        end)
        comboObj:AddItem(entry)
        if opt.value == TT.contribMetric then selectIndex = i end
    end
    comboObj:SelectItemByIndex(selectIndex)
end

function TT.BuildContribGuildCombo()
    BuildGuildFilterCombo(TiradilTraderFrameDonationsPanelContributorsControlsRowGuildCombo, TT.contribGuildFilter, TT.SetContribGuildFilter)
end

function TT.RefreshLanguageDependentUI()
    if not TiradilTraderFrame then return end
    TT.BuildPeriodCombo()
    TT.BuildGuildCombo()
    TT.BuildChartTypeCombo()
    TT.BuildChartMetricCombo()
    TT.BuildChartGuildCombo()
    TT.BuildContribPeriodCombo()
    TT.BuildContribMetricCombo()
    TT.BuildContribGuildCombo()
end
