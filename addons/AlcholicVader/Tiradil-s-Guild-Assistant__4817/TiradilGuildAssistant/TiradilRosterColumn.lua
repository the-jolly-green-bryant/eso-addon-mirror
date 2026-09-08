-- Title: Tiradil's Guild Assistant
-- Author: Tiradil
-- Copyright: © 2026 Tiradil


local TRC = {}
TiradilRosterColumn = TRC

TRC.selectedTimeframe = "week" -- varsayilan: This Week (Ledger'daki varsayilanla ayni) - KATKI kolonu icin
TRC.selectedRankTimeframe = "this_month" -- RANK kolonu icin AYRI, bagimsiz donem secimi

local function GuildIdToIndex(guildId)
    local numGuilds = GetNumGuilds()
    for i = 1, numGuilds do
        if GetGuildId(i) == guildId then
            return i
        end
    end
    return nil
end

local function NormalizeName(name)
    if not name then return "" end
    if name:sub(1, 1) == "@" then
        return name:sub(2)
    end
    return name
end

local contributionCache = {}      -- contributionCache[guildIndex] = { index = {...}, builtAt = time }
local CACHE_TTL_SECONDS = 15

local function BuildContributionIndexForGuild(guildIndex)
    local index = {}
    if not (GuildLedger and GuildLedger.bankEvents and GuildLedger.traderEvents) then
        return index
    end

    local function getEntry(name)
        local key = NormalizeName(name)
        local entry = index[key]
        if not entry then
            entry = {
                donationHistory = {}, -- { {time, amount}, ... } - TUM gecmis
                saleHistory = {},
                purchaseHistory = {}, -- uyenin guild trader'dan YAPTIGI alisverisler
            }
            index[key] = entry
        end
        return entry
    end

    local bankList = GuildLedger.bankEvents[guildIndex]
    if bankList then
        for i = 1, #bankList do
            local e = bankList[i]
            if e.type == GUILD_HISTORY_BANKED_CURRENCY_EVENT_DEPOSITED and e.displayName then
                table.insert(getEntry(e.displayName).donationHistory, { time = e.time, amount = e.amount })
            end
        end
    end

    local traderList = GuildLedger.traderEvents[guildIndex]
    if traderList then
        for i = 1, #traderList do
            local e = traderList[i]
            if e.sellerDisplayName then
                table.insert(getEntry(e.sellerDisplayName).saleHistory, { time = e.time, amount = e.price })
            end
            if e.buyerDisplayName then
                table.insert(getEntry(e.buyerDisplayName).purchaseHistory, { time = e.time, amount = e.price })
            end
        end
    end

    for _, entry in pairs(index) do
        table.sort(entry.donationHistory, function(a, b) return a.time > b.time end)
        table.sort(entry.saleHistory, function(a, b) return a.time > b.time end)
        table.sort(entry.purchaseHistory, function(a, b) return a.time > b.time end)
    end

    return index
end

local function GetContributionIndex(guildIndex)
    local now = os.time()
    local cached = contributionCache[guildIndex]
    if cached and (now - cached.builtAt) < CACHE_TTL_SECONDS then
        return cached.index
    end

    local newIndex = BuildContributionIndexForGuild(guildIndex)
    contributionCache[guildIndex] = { index = newIndex, builtAt = now }
    return newIndex
end

local function FormatGoldShort(amount)
    local formatted = tostring(math.floor(math.abs(amount or 0)))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

local mythicColorHex = nil
local function GetMythicColorHex()
    if not mythicColorHex then
        local ok, color = pcall(GetItemQualityColor, 5)
        if ok and type(color) == "table" and color.r then
            mythicColorHex = string.format("%02X%02X%02X",
                math.floor(color.r * 255 + 0.5), math.floor(color.g * 255 + 0.5), math.floor(color.b * 255 + 0.5))
        else
            mythicColorHex = "E6A319" -- guvenlik: API beklenmedik sekilde basarisiz olursa dusecek yedek renk
        end
    end
    return mythicColorHex
end

local function GetEntryFor(guildId, displayName)
    if not displayName then return nil end
    local guildIndex = GuildIdToIndex(guildId)
    if not guildIndex then return nil end
    local index = GetContributionIndex(guildIndex)
    return index[NormalizeName(displayName)]
end

local function SumHistoryForSelectedPeriod(history)
    if not history or #history == 0 then return 0 end
    if not (GuildLedger and GuildLedger.GetTimeframeRangeFor) then
        local total = 0
        for i = 1, #history do total = total + history[i].amount end
        return total
    end

    local minTime, maxTime = GuildLedger.GetTimeframeRangeFor(TRC.selectedTimeframe)
    local total = 0
    for i = 1, #history do
        local h = history[i]
        if h.time >= minTime and h.time < maxTime then
            total = total + h.amount
        end
    end
    return total
end

local function BuildHistoryTooltipText(history, label)
    if not history or #history == 0 then
        return nil
    end

    local now = os.time()
    local thisWeekStart, lastWeekStart, todayStart
    if GuildLedger and GuildLedger.GetTimeframeRangeFor then
        thisWeekStart = select(1, GuildLedger.GetTimeframeRangeFor("week"))
        lastWeekStart = select(1, GuildLedger.GetTimeframeRangeFor("last_week"))
    else
        thisWeekStart = now - (now % 86400)
        lastWeekStart = thisWeekStart - 7 * 86400
    end
    todayStart = now - (now % 86400)

    local periodMin, periodMax = 0, now + 86400
    if GuildLedger and GuildLedger.GetTimeframeRangeFor then
        periodMin, periodMax = GuildLedger.GetTimeframeRangeFor(TRC.selectedTimeframe)
    end

    local todayTotal, thisWeekTotal, lastWeekTotal, grandTotal = 0, 0, 0, 0
    local lines = {}
    local shownCount = 0

    for i = 1, #history do
        local h = history[i]
        grandTotal = grandTotal + h.amount
        if h.time >= thisWeekStart then thisWeekTotal = thisWeekTotal + h.amount end
        if h.time >= lastWeekStart and h.time < thisWeekStart then lastWeekTotal = lastWeekTotal + h.amount end
        if h.time >= todayStart then todayTotal = todayTotal + h.amount end

        if h.time >= periodMin and h.time < periodMax and shownCount < 10 then
            shownCount = shownCount + 1
            table.insert(lines, string.format("%s : %s", os.date("%d.%m.%Y %H:%M", h.time), FormatGoldShort(h.amount)))
        end
    end

    if shownCount == 0 then
        local L = TiradilIWL10n and TiradilIWL10n.Get or function(k) return k end
        table.insert(lines, "|cA0A0A0" .. L("STATUS_NEVER") .. "|r")
    end

    local labelColorCode = label:match("^|c(%x%x%x%x%x%x)") or "A0A0A0"

    table.insert(lines, "")
    table.insert(lines, string.format("|c%sToday: %s|r", labelColorCode, FormatGoldShort(todayTotal)))
    table.insert(lines, string.format("|c%sThis Week: %s|r", labelColorCode, FormatGoldShort(thisWeekTotal)))
    table.insert(lines, string.format("|c%sLast Week: %s|r", labelColorCode, FormatGoldShort(lastWeekTotal)))
    table.insert(lines, string.format("|c%sTotal: %s|r", GetMythicColorHex(), FormatGoldShort(grandTotal)))

    return label .. "\n" .. table.concat(lines, "\n")
end

local logoffCache = {} -- logoffCache[guildId] = { index = { [normalizedName] = secsSinceLogoff }, builtAt = time }
local LOGOFF_CACHE_TTL_SECONDS = 30

local function GetSecsSinceLogoff(guildId, displayName)
    local now = os.time()
    local cached = logoffCache[guildId]
    if not cached or (now - cached.builtAt) >= LOGOFF_CACHE_TTL_SECONDS then
        local index = {}
        local numMembers = GetNumGuildMembers(guildId) or 0
        for i = 1, numMembers do
            local ok, name, note, rankIndex, playerStatus, secsSinceLogoff = pcall(GetGuildMemberInfo, guildId, i)
            if ok and name then
                index[NormalizeName(name)] = secsSinceLogoff
            end
        end
        cached = { index = index, builtAt = now }
        logoffCache[guildId] = cached
    end
    return cached.index[NormalizeName(displayName)]
end

local joinTimeCache = {} -- joinTimeCache[guildIndex] = { index = { [normalizedName] = latestJoinTime }, builtAt = time }
local JOIN_TIME_CACHE_TTL_SECONDS = 30

local function BuildJoinTimeIndexForGuild(guildIndex)
    local index = {}
    if not (TiradilRoster and TiradilRoster.events and TiradilRoster.events[3]) then
        return index -- TiradilRoster yuklu degil/veri yok - bos index
    end
    local joinedList = TiradilRoster.events[3]
    for i = 1, #joinedList do
        local e = joinedList[i]
        if e.guildIndex == guildIndex then
            local key = NormalizeName(e.target)
            if not index[key] or e.time > index[key] then
                index[key] = e.time
            end
        end
    end
    return index
end

local function GetJoinTime(guildIndex, displayName)
    local now = os.time()
    local cached = joinTimeCache[guildIndex]
    if not cached or (now - cached.builtAt) >= JOIN_TIME_CACHE_TTL_SECONDS then
        cached = { index = BuildJoinTimeIndexForGuild(guildIndex), builtAt = now }
        joinTimeCache[guildIndex] = cached
    end
    return cached.index[NormalizeName(displayName)]
end

local DEFAULT_KICK_THRESHOLD_DAYS = 14

local function GetKickThresholdSeconds(guildIndex)
    local settings = GuildLedger and GuildLedger.savedVars and GuildLedger.savedVars.rankSettings and GuildLedger.savedVars.rankSettings[guildIndex]
    local days = (settings and settings.kickThresholdDays) or DEFAULT_KICK_THRESHOLD_DAYS
    return days * 86400
end

local function IsEligibleForKick(guildId, displayName)
    local guildIndex = GuildIdToIndex(guildId)
    if not guildIndex then return false end

    local kickThresholdSeconds = GetKickThresholdSeconds(guildIndex)

    local joinTime = GetJoinTime(guildIndex, displayName)
    if not joinTime then return false end
    if (os.time() - joinTime) < kickThresholdSeconds then return false end

    local secsSinceLogoff = GetSecsSinceLogoff(guildId, displayName)
    if not secsSinceLogoff then return false end
    if secsSinceLogoff < kickThresholdSeconds then return false end

    local entry = GetEntryFor(guildId, displayName)
    if entry then
        local hasAnyDonation = entry.donationHistory and #entry.donationHistory > 0
        local hasAnySale = entry.saleHistory and #entry.saleHistory > 0
        local hasAnyPurchase = entry.purchaseHistory and #entry.purchaseHistory > 0
        if hasAnyDonation or hasAnySale or hasAnyPurchase then return false end
    end

    return true
end
TRC.IsEligibleForKick = IsEligibleForKick

function TRC.MarkForKickReview(guildId, displayName)
    TRC.savedVars = TRC.savedVars or (TiradilRosterColumn_SavedVars or {})
    TRC.savedVars.kickReviewList = TRC.savedVars.kickReviewList or {}
    TiradilRosterColumn_SavedVars = TRC.savedVars

    local guildIndex = GuildIdToIndex(guildId)
    local guildName = guildIndex and GetGuildName(GetGuildId(guildIndex)) or "?"
    local normalizedName = NormalizeName(displayName)

    for _, entry in ipairs(TRC.savedVars.kickReviewList) do
        if NormalizeName(entry.displayName) == normalizedName and entry.guildId == guildId then
            entry.markedAt = os.time()
            return
        end
    end

    table.insert(TRC.savedVars.kickReviewList, {
        displayName = displayName,
        guildId = guildId,
        guildName = guildName,
        markedAt = os.time(),
    })
end

function TRC.RemoveFromKickReview(guildId, displayName)
    if not (TRC.savedVars and TRC.savedVars.kickReviewList) then return end
    local normalizedName = NormalizeName(displayName)
    for i = #TRC.savedVars.kickReviewList, 1, -1 do
        local entry = TRC.savedVars.kickReviewList[i]
        if NormalizeName(entry.displayName) == normalizedName and entry.guildId == guildId then
            table.remove(TRC.savedVars.kickReviewList, i)
        end
    end
end

local function GetContributionValue(guildId, data, rowIndex)
    local displayName = data.displayName or ""
    local entry = GetEntryFor(guildId, displayName)
    local total = 0
    if entry then
        total = SumHistoryForSelectedPeriod(entry.donationHistory)
            + SumHistoryForSelectedPeriod(entry.saleHistory)
            + SumHistoryForSelectedPeriod(entry.purchaseHistory)
    end
    local sortPrefix = string.format("%010d", math.min(total, 9999999999))
    return sortPrefix .. "|" .. displayName .. "|" .. tostring(guildId)
end

local function FormatContributionValue(value)
    local L = TiradilIWL10n and TiradilIWL10n.Get or function(k) return k end

    local sortPrefix, displayName, guildId = value:match("^(%d+)|(.-)|(%-?%d+)$")
    if not displayName or displayName == "" then
        return "|cFF6B6B" .. L("STATUS_NEVER") .. "|r"
    end
    guildId = tonumber(guildId)

    local entry = GetEntryFor(guildId, displayName)
    if not entry then
        local kickOk, kickEligible = pcall(IsEligibleForKick, guildId, displayName)
        if kickOk and kickEligible then
            return "|cFF6B6BKICK|r"
        end
        return "|cFF6B6B" .. L("STATUS_NEVER") .. "|r"
    end

    local donationSum = SumHistoryForSelectedPeriod(entry.donationHistory)
    local saleSum = SumHistoryForSelectedPeriod(entry.saleHistory)
    local purchaseSum = SumHistoryForSelectedPeriod(entry.purchaseHistory)

    if donationSum == 0 and saleSum == 0 and purchaseSum == 0 then
        local kickOk, kickEligible = pcall(IsEligibleForKick, guildId, displayName)
        if kickOk and kickEligible then
            return "|cFF6B6BKICK|r"
        end
        return "|cFF6B6B" .. L("STATUS_NEVER") .. "|r"
    end

    local parts = {}
    if donationSum > 0 then
        table.insert(parts, string.format("|c4DDB4D%s: %s|r", L("TOOLTIP_DONATIONS"), FormatGoldShort(donationSum)))
    end
    if saleSum > 0 then
        table.insert(parts, string.format("|cFFB800%s: %s|r", L("TOOLTIP_SALES"), FormatGoldShort(saleSum)))
    end
    if purchaseSum > 0 then
        table.insert(parts, string.format("|cB366F0%s: %s|r", L("TOOLTIP_PURCHASES"), FormatGoldShort(purchaseSum)))
    end

    return table.concat(parts, "  ")
end

local function BuildContributionTooltipText(guildId, displayName)
    if not displayName then return nil end

    local entry = GetEntryFor(guildId, displayName)
    if not entry then return nil end

    local L = TiradilIWL10n and TiradilIWL10n.Get or function(k) return k end
    local sections = {}

    local donationText = BuildHistoryTooltipText(entry.donationHistory, "|c4DDB4D" .. L("TOOLTIP_DONATIONS") .. "|r")
    if donationText then table.insert(sections, donationText) end

    local saleText = BuildHistoryTooltipText(entry.saleHistory, "|cFFB800" .. L("TOOLTIP_SALES") .. "|r")
    if saleText then table.insert(sections, saleText) end

    local purchaseText = BuildHistoryTooltipText(entry.purchaseHistory, "|cB366F0" .. L("TOOLTIP_PURCHASES") .. "|r")
    if purchaseText then table.insert(sections, purchaseText) end

    if #sections == 0 then return nil end

    local function SumAll(history)
        local t = 0
        for i = 1, #(history or {}) do t = t + history[i].amount end
        return t
    end
    local GUILD_STORE_TAX_RATE = 0.035
    local donationTotal = SumAll(entry.donationHistory)
    local saleTaxContribution = SumAll(entry.saleHistory) * GUILD_STORE_TAX_RATE
    local overallTotal = donationTotal + saleTaxContribution
    table.insert(sections, string.format("|c%s%s: %s|r", GetMythicColorHex(), L("TOOLTIP_GRAND_TOTAL"), FormatGoldShort(overallTotal)))

    return table.concat(sections, "\n\n")
end

local function FormatRelativeTime(seconds)
    if not seconds or seconds < 0 then return "?" end
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    if days > 0 then
        return string.format("%dg %dh", days, hours)
    elseif hours > 0 then
        return string.format("%dh %ddk", hours, minutes)
    else
        return string.format("%ddk", minutes)
    end
end

local function BuildNativeTooltipSummary(guildId, displayName)
    if not displayName then return nil end

    local L = TiradilIWL10n and TiradilIWL10n.Get or function(k) return k end
    local entry = GetEntryFor(guildId, displayName)

    local function TotalAndLast(history)
        if not history or #history == 0 then return 0, nil, nil end
        local total, lastTime, lastAmount = 0, 0, 0
        for i = 1, #history do
            total = total + history[i].amount
            if history[i].time > lastTime then
                lastTime = history[i].time
                lastAmount = history[i].amount
            end
        end
        return total, lastTime, lastAmount
    end

    local lines = {}
    local now = os.time()

    table.insert(lines, "|cFFB800Tiradil's Guild Assistant|r")

    local guildIndex = GuildIdToIndex(guildId)
    local joinTime = guildIndex and GetJoinTime(guildIndex, displayName)
    if joinTime then
        table.insert(lines, "|cA0A0A0" .. zo_strformat(L("NATIVE_TOOLTIP_MEMBERSHIP"), FormatRelativeTime(now - joinTime)) .. "|r")
    end

    local secsSinceLogoff = GetSecsSinceLogoff(guildId, displayName)
    if secsSinceLogoff then
        if secsSinceLogoff <= 60 then
            table.insert(lines, "|c72FF80" .. L("NATIVE_TOOLTIP_ONLINE") .. "|r")
        else
            table.insert(lines, "|cA0A0A0" .. zo_strformat(L("NATIVE_TOOLTIP_LAST_ACTIVE"), FormatRelativeTime(secsSinceLogoff)) .. "|r")
        end
    end

    local donationTotal, donationLastTime, donationLastAmount = 0, nil, nil
    if entry then
        donationTotal, donationLastTime, donationLastAmount = TotalAndLast(entry.donationHistory)
    end
    table.insert(lines, "|c4DDB4D" .. zo_strformat(L("NATIVE_TOOLTIP_DONATION_TOTAL"), FormatGoldShort(donationTotal)) .. "|r")
    if donationLastTime then
        table.insert(lines, "|c4DDB4D  " .. zo_strformat(L("NATIVE_TOOLTIP_LAST_LINE"), FormatGoldShort(donationLastAmount), FormatRelativeTime(now - donationLastTime)) .. "|r")
    end

    local saleTotal, saleLastTime, saleLastAmount = 0, nil, nil
    if entry then
        saleTotal, saleLastTime, saleLastAmount = TotalAndLast(entry.saleHistory)
    end
    table.insert(lines, "|cFFB800" .. zo_strformat(L("NATIVE_TOOLTIP_SALE_TOTAL"), FormatGoldShort(saleTotal)) .. "|r")
    if saleLastTime then
        table.insert(lines, "|cFFB800  " .. zo_strformat(L("NATIVE_TOOLTIP_LAST_LINE"), FormatGoldShort(saleLastAmount), FormatRelativeTime(now - saleLastTime)) .. "|r")
    end

    return table.concat(lines, "\n")
end

local function OnCellMouseEnter(guildId, data, ctx)
    local displayName = data and data.displayName
    if not displayName then return end

    local text = BuildContributionTooltipText(guildId, displayName)
    if not text then return end

    ZO_Tooltips_ShowTextTooltip(ctx, LEFT, text)
end

local function OnCellMouseExit(guildId, data, ctx)
    ZO_Tooltips_HideTextTooltip()
end

local function TryHookNativeRosterTooltip()
    if not ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter then return end
    if TRC.nativeTooltipHooked then return end
    TRC.nativeTooltipHooked = true

    local previousHandler = ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter

    ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter = function(control)
        previousHandler(control)

        pcall(function()
            if TiradilRosterColumn_SavedVars and TiradilRosterColumn_SavedVars.enabled == false then
                return
            end
            local parent = control:GetParent()
            local data = ZO_ScrollList_GetData(parent)
            if not (data and data.displayName) then return end
            local guildId = GUILD_ROSTER_MANAGER and GUILD_ROSTER_MANAGER:GetGuildId()
            if not guildId then return end

            local text = BuildNativeTooltipSummary(guildId, data.displayName)
            if text and InformationTooltip then
                InformationTooltip:AddLine("\n" .. text)
            end
        end)
    end
end

function TRC.SetTimeframe(timeframe)
    TRC.selectedTimeframe = timeframe
    if TRC.savedVars then
        TRC.savedVars.selectedTimeframe = timeframe
    end
    if LibGuildRoster and LibGuildRoster.Refresh then
        LibGuildRoster:Refresh()
    end
    pcall(TRC.RefreshSummaryLabels)
end

local function ComputeGuildContributionSummary(guildId)
    local guildIndex = GuildIdToIndex(guildId)
    if not guildIndex then return nil end

    local index = GetContributionIndex(guildIndex)
    local numMembers = GetNumGuildMembers(guildId) or 0
    if numMembers == 0 then return nil end

    local totalDonations, totalSales = 0, 0
    local donorCount, sellerCount = 0, 0

    for _, entry in pairs(index) do
        local donationSum = SumHistoryForSelectedPeriod(entry.donationHistory)
        local saleSum = SumHistoryForSelectedPeriod(entry.saleHistory)
        if donationSum > 0 then
            totalDonations = totalDonations + donationSum
            donorCount = donorCount + 1
        end
        if saleSum > 0 then
            totalSales = totalSales + saleSum
            sellerCount = sellerCount + 1
        end
    end

    local donorPct = (donorCount / numMembers) * 100
    local sellerPct = (sellerCount / numMembers) * 100

    return totalDonations, donorPct, sellerPct, numMembers, totalSales, donorCount, sellerCount
end

function TRC.RefreshSummaryLabels()
    if not (TiradilRosterColumnDonationSummary and TiradilRosterColumnSellerSummary) then
        return
    end
    local guildId = GUILD_ROSTER_MANAGER and GUILD_ROSTER_MANAGER.guildId
    if not guildId then return end

    local totalDonations, donorPct, sellerPct, numMembers, totalSales, donorCount, sellerCount = ComputeGuildContributionSummary(guildId)
    local L = TiradilIWL10n and TiradilIWL10n.Get or function(k) return k end

    if not totalDonations then
        TiradilRosterColumnDonationSummary:SetText("")
        TiradilRosterColumnSellerSummary:SetText("")
        return
    end

    TiradilRosterColumnDonationSummary:SetText(string.format(
        "|c4DDB4D%s: %s  (%.0f%% - %d/%d %s)|r",
        L("TOOLTIP_DONATIONS"), FormatGoldShort(totalDonations), donorPct, donorCount, numMembers, L("COL_MEMBER")
    ))
    TiradilRosterColumnSellerSummary:SetText(string.format(
        "|cFFB800%s: %s  (%.0f%% - %d/%d %s)|r",
        L("TOOLTIP_SALES"), FormatGoldShort(totalSales), sellerPct, sellerCount, numMembers, L("COL_MEMBER")
    ))
end

local function TryAddPeriodCombo(columnControl)
    if TiradilRosterColumnPeriodCombo then
        return -- zaten eklenmis (ornegin reloadui sonrasi tekrar cagrilmis olabilir)
    end
    if not (columnControl and columnControl.GetHeader) then
        return
    end

    local header = columnControl:GetHeader()
    if not header then return end

    local combo = CreateControlFromVirtual("TiradilRosterColumnPeriodCombo", ZO_GuildRoster, "ZO_ComboBox")
    combo:SetDimensions(225, 33)
    combo:ClearAnchors()
    combo:SetAnchor(TOPLEFT, header, BOTTOMLEFT, 0, ZO_GuildRosterListContents:GetHeight())

    local comboObj = ZO_ComboBox_ObjectFromContainer(combo)
    comboObj:SetSortsItems(false)

    local L = TiradilL10n and TiradilL10n.Get or function(k) return k end
    local options = {
        { name = L("PERIOD_THIS_WEEK"), value = "week" },
        { name = L("PERIOD_LAST_WEEK"), value = "last_week" },
        { name = L("PERIOD_2_WEEKS_AGO"), value = "week_before_last" },
        { name = L("PERIOD_3_WEEKS_AGO"), value = "3_weeks_ago" },
        { name = L("PERIOD_4_WEEKS_AGO"), value = "4_weeks_ago" },
        { name = L("PERIOD_LAST_MONTH"), value = "last_month" },
        { name = L("PERIOD_THIS_MONTH"), value = "this_month" },
        { name = L("PERIOD_LAST_30_DAYS"), value = "last_30_days" },
        { name = L("PERIOD_ALL_TIME"), value = "all_time" },
    }

    local selectedEntry = nil
    for _, opt in ipairs(options) do
        local entry = comboObj:CreateItemEntry(opt.name, function()
            TRC.SetTimeframe(opt.value)
        end)
        comboObj:AddItem(entry)
        if opt.value == TRC.selectedTimeframe then
            selectedEntry = entry
        end
    end

    if selectedEntry then
        comboObj:SelectItem(selectedEntry, false)
    end

    local donationSummary = CreateControlFromVirtual("TiradilRosterColumnDonationSummary", ZO_GuildRoster, "ZO_KeyboardGuildRosterRowLabel")
    donationSummary:SetFont("ZoFontGameSmall")
    donationSummary:SetDimensions(225, 18)
    donationSummary:ClearAnchors()
    donationSummary:SetAnchor(TOPLEFT, combo, BOTTOMLEFT, 0, 4)
    donationSummary:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

    local sellerSummary = CreateControlFromVirtual("TiradilRosterColumnSellerSummary", ZO_GuildRoster, "ZO_KeyboardGuildRosterRowLabel")
    sellerSummary:SetFont("ZoFontGameSmall")
    sellerSummary:SetDimensions(225, 18)
    sellerSummary:ClearAnchors()
    sellerSummary:SetAnchor(TOPLEFT, donationSummary, BOTTOMLEFT, 0, 2)
    sellerSummary:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

    TRC.RefreshSummaryLabels()

    if not TRC.guildChangeHookInstalled then
        TRC.guildChangeHookInstalled = true
        ZO_PreHook(GUILD_ROSTER_MANAGER, "OnGuildIdChanged", function()
            pcall(TRC.RefreshSummaryLabels)
        end)
    end
end

local function TryAddRankPeriodCombo(columnControl)
    if TiradilRosterColumnRankPeriodCombo then
        return -- zaten eklenmis
    end
    if not (columnControl and columnControl.GetHeader) then
        return
    end

    local header = columnControl:GetHeader()
    if not header then return end

    local combo = CreateControlFromVirtual("TiradilRosterColumnRankPeriodCombo", ZO_GuildRoster, "ZO_ComboBox")
    combo:SetDimensions(110, 26)
    combo:ClearAnchors()
    combo:SetAnchor(TOP, header, BOTTOM, 0, ZO_GuildRosterListContents:GetHeight())

    local comboObj = ZO_ComboBox_ObjectFromContainer(combo)
    comboObj:SetSortsItems(false)

    local L = TiradilL10n and TiradilL10n.Get or function(k) return k end
    local options = {
        { name = L("PERIOD_THIS_WEEK"), value = "week" },
        { name = L("PERIOD_LAST_WEEK"), value = "last_week" },
        { name = L("PERIOD_2_WEEKS_AGO"), value = "week_before_last" },
        { name = L("PERIOD_3_WEEKS_AGO"), value = "3_weeks_ago" },
        { name = L("PERIOD_4_WEEKS_AGO"), value = "4_weeks_ago" },
        { name = L("PERIOD_LAST_MONTH"), value = "last_month" },
        { name = L("PERIOD_THIS_MONTH"), value = "this_month" },
        { name = L("PERIOD_LAST_30_DAYS"), value = "last_30_days" },
    }

    local selectedEntry = nil
    for _, opt in ipairs(options) do
        local entry = comboObj:CreateItemEntry(opt.name, function()
            TRC.SetRankTimeframe(opt.value)
        end)
        comboObj:AddItem(entry)
        if opt.value == TRC.selectedRankTimeframe then
            selectedEntry = entry
        end
    end

    if selectedEntry then
        comboObj:SelectItem(selectedEntry, false)
    end
end

local rankCache = {}      -- rankCache[guildIndex] = { salesByMember = {}, donationsByMember = {}, builtAt = time }
local RANK_CACHE_TTL_SECONDS = 15

function TRC.SetRankTimeframe(timeframe)
    TRC.selectedRankTimeframe = timeframe
    if TRC.savedVars then
        TRC.savedVars.selectedRankTimeframe = timeframe
    end
    rankCache = {}
    if LibGuildRoster and LibGuildRoster.Refresh then
        LibGuildRoster:Refresh()
    end
end

local function BuildRankTotalsForGuild(guildIndex)
    local sales, donations = {}, {}
    if not (GuildLedger and GuildLedger.bankEvents and GuildLedger.traderEvents and GuildLedger.GetTimeframeRangeFor) then
        return sales, donations
    end

    local minTime, maxTime = GuildLedger.GetTimeframeRangeFor(TRC.selectedRankTimeframe or "this_month")

    local traderList = GuildLedger.traderEvents[guildIndex]
    if traderList then
        for i = 1, #traderList do
            local e = traderList[i]
            if e.time >= minTime and e.time < maxTime and e.sellerDisplayName then
                local key = NormalizeName(e.sellerDisplayName)
                sales[key] = (sales[key] or 0) + e.price
            end
        end
    end

    local bankList = GuildLedger.bankEvents[guildIndex]
    if bankList then
        for i = 1, #bankList do
            local e = bankList[i]
            if e.type == GUILD_HISTORY_BANKED_CURRENCY_EVENT_DEPOSITED and e.time >= minTime and e.time < maxTime and e.displayName then
                local key = NormalizeName(e.displayName)
                donations[key] = (donations[key] or 0) + e.amount
            end
        end
    end

    return sales, donations
end

local function GetRankTotals(guildIndex)
    local now = os.time()
    local cached = rankCache[guildIndex]
    if cached and (now - cached.builtAt) < RANK_CACHE_TTL_SECONDS then
        return cached.sales, cached.donations
    end

    local sales, donations = BuildRankTotalsForGuild(guildIndex)
    rankCache[guildIndex] = { sales = sales, donations = donations, builtAt = now }
    return sales, donations
end

local function GetMemberRank(guildId, displayName)
    if not (GuildLedger and GuildLedger.rankTiers and GuildLedger.savedVars and GuildLedger.savedVars.rankSettings) then
        return nil
    end
    local guildIndex = GuildIdToIndex(guildId)
    if not guildIndex then return nil end

    local rankSettingsForGuild = GuildLedger.savedVars.rankSettings[guildIndex]
    if not rankSettingsForGuild then return nil end

    local key = NormalizeName(displayName)

    local legendSettings = rankSettingsForGuild[1]
    if legendSettings and legendSettings.legendMode == "top3" and GuildLedger.GetLegendTop3Set then
        local legendSet = GuildLedger.GetLegendTop3Set(guildIndex, TRC.selectedRankTimeframe)
        if legendSet[key] then
            return GuildLedger.rankTiers[1], 1
        end
    end

    local sales, donations = GetRankTotals(guildIndex)
    local memberSales = sales[key] or 0
    local memberDonations = donations[key] or 0

    local startTier = (legendSettings and legendSettings.legendMode == "top3") and 2 or 1
    for i = startTier, #GuildLedger.rankTiers do
        local tier = GuildLedger.rankTiers[i]
        local settings = rankSettingsForGuild[i]
        if settings and (memberSales >= (settings.salesThreshold or math.huge) or memberDonations >= (settings.donationThreshold or math.huge)) then
            return tier, i
        end
    end
    return nil, nil
end

local function GetRankValue(guildId, data, rowIndex)
    local displayName = data.displayName or ""
    local tier, tierIndex = GetMemberRank(guildId, displayName)
    local numTiers = (GuildLedger and GuildLedger.rankTiers and #GuildLedger.rankTiers) or 5
    local sortPrefix
    if tierIndex then
        sortPrefix = string.format("%02d", (numTiers - tierIndex) + 1) -- tier 1 (Legend) -> en buyuk sayi
    else
        sortPrefix = "00" -- rutbesiz -> en kucuk sayi, listenin dibine duser
    end
    return sortPrefix .. "|" .. displayName .. "|" .. tostring(guildId)
end

local function FormatRankValue(value)
    local sortPrefix, displayName, guildId = value:match("^(%d+)|(.-)|(%-?%d+)$")
    if not displayName or displayName == "" then
        return ""
    end
    guildId = tonumber(guildId)

    local tier, tierIndex = GetMemberRank(guildId, displayName)
    if not tier then
        return "" -- rutbesi olmayan uyeler icin bos - "yok" yazisi yerine sessizce bos birak
    end

    local guildIndex = GuildIdToIndex(guildId)
    local tierName = (GuildLedger and GuildLedger.GetTierName and guildIndex and GuildLedger.GetTierName(guildIndex, tierIndex)) or tier.name
    return string.format("|c%s[%s]|r", tier.color, tierName)
end

local function TryAddColumn()
    if not LibGuildRoster then
        return
    end

    TiradilRosterColumn_SavedVars = TiradilRosterColumn_SavedVars or { selectedTimeframe = "week", enabled = true }
    TRC.savedVars = TiradilRosterColumn_SavedVars
    TRC.selectedTimeframe = TRC.savedVars.selectedTimeframe or "week"
    TRC.selectedRankTimeframe = TRC.savedVars.selectedRankTimeframe or "this_month"
    if TRC.selectedTimeframe == 30 or TRC.selectedTimeframe == "30" then
        TRC.selectedTimeframe = "this_month"
        TRC.savedVars.selectedTimeframe = "this_month"
    elseif TRC.selectedTimeframe == "2_weeks" then
        TRC.selectedTimeframe = "week"
        TRC.savedVars.selectedTimeframe = "week"
    end
    if TRC.savedVars.enabled == nil then
        TRC.savedVars.enabled = true -- eski kayitlarda alan yoksa varsayilan: acik
    end
    if TRC.savedVars.rankColumnEnabled == nil then
        TRC.savedVars.rankColumnEnabled = true
    end

    local rankColumn = LibGuildRoster:AddColumn({
        key = "TiradilRank",
        width = 120,
        priority = 1,
        header = {
            align = TEXT_ALIGN_LEFT,
            title = (TiradilIWL10n and TiradilIWL10n.Get("COL_RANK")) or "Rank",
            tooltip = false,
        },
        disabled = not TRC.savedVars.rankColumnEnabled,
        row = {
            align = TEXT_ALIGN_LEFT,
            data = GetRankValue,
            format = FormatRankValue,
        },
    })
    TRC.rankColumn = rankColumn

    local column = LibGuildRoster:AddColumn({
        key = "TiradilContribution",
        width = 220,
        header = {
            align = TEXT_ALIGN_LEFT,
            title = (TiradilIWL10n and TiradilIWL10n.Get("COL_LAST_CONTRIB")) or "Contribution",
            tooltip = false,
        },
        disabled = not TRC.savedVars.enabled, -- Ayarlar panelindeki ac/kapa anahtari
        row = {
            align = TEXT_ALIGN_LEFT,
            data = GetContributionValue,
            format = FormatContributionValue,
            mouseEnabled = function() return true end, -- OnMouseEnter/Exit icin SART
            OnMouseEnter = OnCellMouseEnter,
            OnMouseExit = OnCellMouseExit,
        },
    })

    TRC.contributionColumn = column -- Ayarlar panelinden acip kapatabilmek icin sakla

    if LibGuildRoster.OnRosterReady then
        LibGuildRoster:OnRosterReady(function()
            pcall(TryAddPeriodCombo, column)
            pcall(TryAddRankPeriodCombo, rankColumn)
        end)
    end
end

function TRC.SetColumnEnabled(enabled)
    TRC.savedVars = TRC.savedVars or (TiradilRosterColumn_SavedVars or { selectedTimeframe = "week" })
    TRC.savedVars.enabled = enabled
    TiradilRosterColumn_SavedVars = TRC.savedVars

    if TRC.contributionColumn and TRC.contributionColumn.IsDisabled then
        TRC.contributionColumn:IsDisabled(not enabled)
    end
    if LibGuildRoster and LibGuildRoster.Refresh then
        LibGuildRoster:Refresh()
    end
end

function TRC.SetRankColumnEnabled(enabled)
    TRC.savedVars = TRC.savedVars or (TiradilRosterColumn_SavedVars or { selectedTimeframe = "week" })
    TRC.savedVars.rankColumnEnabled = enabled
    TiradilRosterColumn_SavedVars = TRC.savedVars

    if TRC.rankColumn and TRC.rankColumn.IsDisabled then
        TRC.rankColumn:IsDisabled(not enabled)
    end
    if LibGuildRoster and LibGuildRoster.Refresh then
        LibGuildRoster:Refresh()
    end
end

local function SubstitutePlaceholders(text, userID)
    if not text then return "" end
    text = string.gsub(text, "@@", userID)
    local nameOnly = string.gsub(userID, "@", "")
    return string.gsub(text, "@", nameOnly)
end

local function OpenTemplateMail(guildIndex, displayName)
    if not (GuildLedger and GuildLedger.savedVars) then return end
    local template = GuildLedger.savedVars.mailTemplates and GuildLedger.savedVars.mailTemplates[guildIndex]
    local subject = template and SubstitutePlaceholders(template.subject, displayName) or ""
    local body = template and SubstitutePlaceholders(template.body, displayName) or ""

    SCENE_MANAGER:Show("mailSend")
    zo_callLater(function()
        if ZO_MailSendToField then ZO_MailSendToField:SetText(displayName) end
        if ZO_MailSendSubjectField then ZO_MailSendSubjectField:SetText(subject) end
        if ZO_MailSendBodyField then
            ZO_MailSendBodyField:SetText(body)
            ZO_MailSendBodyField:TakeFocus()
        end
    end, 200)
end

local function TryAddContextMenu()
    if not LibCustomMenu then
        return
    end

    local L = TiradilIWL10n and TiradilIWL10n.Get or function(k) return k end

    LibCustomMenu:RegisterGuildRosterContextMenu(function(rowData)
        if not (rowData and rowData.displayName) then return end
        local displayName = rowData.displayName
        local guildId = GUILD_ROSTER_MANAGER and GUILD_ROSTER_MANAGER.guildId

        AddCustomMenuItem(L("CONTEXT_SEARCH_LEDGER"), function()
            local guildIndex = GuildIdToIndex(guildId)
            if GuildLedger and GuildLedger.OpenSearchPanelFor then
                GuildLedger.OpenSearchPanelFor(guildIndex, displayName)
            end
        end)

        AddCustomMenuItem(L("CONTEXT_MARK_KICK"), function()
            if TRC.MarkForKickReview and guildId then
                TRC.MarkForKickReview(guildId, displayName)
            end
        end)

        AddCustomMenuItem(L("CONTEXT_SEND_MAIL"), function()
            local guildIndex = GuildIdToIndex(guildId)
            if guildIndex then
                pcall(OpenTemplateMail, guildIndex, displayName)
            end
        end)

        AddCustomMenuItem(L("CONTEXT_EDIT_NOTE"), function()
            if GuildLedger and GuildLedger.OpenEditNoteDialog then
                GuildLedger.OpenEditNoteDialog(displayName)
            end
        end)
    end, LibCustomMenu.CATEGORY_LATE)
end

function TiradilRosterColumn_TryInitialize()
    pcall(TryAddColumn)
    pcall(TryAddContextMenu)
    pcall(TryHookNativeRosterTooltip)
end
