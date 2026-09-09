
TiradilInactiveWatch = {}
local TIW = TiradilInactiveWatch

TIW.selectedGuildFilter = nil -- nil = tum guildler
TIW.currentThreshold = 30     -- gun
TIW.currentSearch = ""
TIW.cachedRows = {}           -- son hesaplanan satirlar (arama/filtre bunun uzerinde calisir)

local function HasRosterData()
    return TiradilRoster ~= nil and TiradilRoster.events ~= nil and TiradilRoster.events[3] ~= nil
end

local function HasLedgerData()
    return GuildLedger ~= nil and GuildLedger.bankEvents ~= nil and GuildLedger.traderEvents ~= nil
end

local function NormalizeName(name)
    if not name then return "" end
    if name:sub(1, 1) == "@" then
        return name:sub(2)
    end
    return name
end

local function GuildIdToIndex(guildId)
    local numGuilds = GetNumGuilds()
    for i = 1, numGuilds do
        if GetGuildId(i) == guildId then
            return i
        end
    end
    return nil
end

local function ApplyGuildColor(label, guildIndex)
    if not (label and guildIndex) then return end
    if TiradilRoster and TiradilRoster.GetGuildColor then
        local ok, r, g, b = pcall(TiradilRoster.GetGuildColor, guildIndex)
        if ok and r then
            label:SetColor(r, g, b, 1)
        end
    end
end

local function BuildJoinTimeIndex()
    local index = {}
    if not HasRosterData() then return index end
    local joinedList = TiradilRoster.events[3]
    for i = 1, #joinedList do
        local e = joinedList[i]
        local key = tostring(e.guildIndex) .. "|" .. NormalizeName(e.target)
        if not index[key] or e.time > index[key] then
            index[key] = e.time
        end
    end
    return index
end

local function BuildContributionIndex(sinceTime)
    local index = {}
    if not HasLedgerData() then return index end

    local function getEntry(guildIndex, name)
        local key = tostring(guildIndex) .. "|" .. NormalizeName(name)
        local entry = index[key]
        if not entry then
            entry = { donations = 0, sales = 0, lastContribTime = nil }
            index[key] = entry
        end
        return entry
    end

    for guildIndex, bankList in pairs(GuildLedger.bankEvents) do
        for i = 1, #bankList do
            local e = bankList[i]
            if e.type == GUILD_HISTORY_BANKED_CURRENCY_EVENT_DEPOSITED and e.displayName then
                local entry = getEntry(guildIndex, e.displayName)
                if not entry.lastContribTime or e.time > entry.lastContribTime then
                    entry.lastContribTime = e.time
                end
                if e.time >= sinceTime then
                    entry.donations = entry.donations + e.amount
                end
            end
        end
    end

    for guildIndex, traderList in pairs(GuildLedger.traderEvents) do
        for i = 1, #traderList do
            local e = traderList[i]
            if e.sellerDisplayName then
                local entry = getEntry(guildIndex, e.sellerDisplayName)
                if not entry.lastContribTime or e.time > entry.lastContribTime then
                    entry.lastContribTime = e.time
                end
                if e.time >= sinceTime then
                    entry.sales = entry.sales + e.price
                end
            end
        end
    end

    return index
end

local function FormatGold(amount)
    local formatted = tostring(math.floor(math.abs(amount or 0)))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted .. " Gold"
end

function TIW.ScanGuilds()
    local now = os.time()
    local thresholdSeconds = TIW.currentThreshold * 86400
    local sinceTime = now - thresholdSeconds

    local joinIndex = BuildJoinTimeIndex()
    local contribIndex = BuildContributionIndex(sinceTime)

    local rows = {}
    local numGuilds = GetNumGuilds()

    for guildIndex = 1, numGuilds do
        local guildId = GetGuildId(guildIndex)
        if guildId and guildId ~= 0 then
            local guildName = GetGuildName(guildId)
            local numMembers = GetNumGuildMembers(guildId)
            local hasContribData = HasLedgerData()

            for memberIndex = 1, numMembers do
                local displayName = GetGuildMemberInfo(guildId, memberIndex)
                if displayName and displayName ~= "" then
                    local key = tostring(guildIndex) .. "|" .. NormalizeName(displayName)
                    local joinTime = joinIndex[key]
                    local contrib = contribIndex[key]

                    local totalDonations = contrib and contrib.donations or 0
                    local totalSales = contrib and contrib.sales or 0
                    local lastContribTime = contrib and contrib.lastContribTime or nil

                    local daysInGuild = nil
                    local qualifiesbyTime = true -- varsayilan: dahil et (tarih bilinmiyorsa)
                    if joinTime then
                        daysInGuild = math.floor((now - joinTime) / 86400)
                        qualifiesbyTime = (now - joinTime) >= thresholdSeconds
                    end

                    local daysSinceContrib = nil
                    if lastContribTime then
                        daysSinceContrib = math.max(0, math.floor((now - lastContribTime) / 86400))
                    elseif daysInGuild then
                        daysSinceContrib = daysInGuild
                    end

                    if qualifiesbyTime then
                        local isFlagged = hasContribData and (totalDonations + totalSales) == 0

                        if isFlagged then
                            table.insert(rows, {
                                guildIndex = guildIndex,
                                guildName = guildName,
                                displayName = displayName,
                                daysInGuild = daysInGuild, -- nil ise bilinmiyor
                                lastContribTime = lastContribTime, -- nil ise hic kayit yok
                                daysSinceContrib = daysSinceContrib, -- nil ise bilinmiyor
                                totalDonations = totalDonations,
                                totalSales = totalSales,
                            })
                        end
                    end
                end
            end
        end
    end

    table.sort(rows, function(a, b)
        if a.daysInGuild == nil and b.daysInGuild == nil then return a.displayName < b.displayName end
        if a.daysInGuild == nil then return false end
        if b.daysInGuild == nil then return true end
        return a.daysInGuild > b.daysInGuild
    end)

    TIW.cachedRows = rows
    return rows
end

local ROW_TYPE = 1
local ROW_HEIGHT = 30
local KICK_ROW_TYPE = 2

local function ShowMemberNoteTooltip(control, displayName)
    if not (GuildLedger and GuildLedger.GetPersonalNote) then return end
    local note = GuildLedger.GetPersonalNote(displayName)
    if not note then return end
    ZO_Tooltips_ShowTextTooltip(control, TOP, "|cFFB800" .. TiradilIWL10n.Get("MEMBER_NOTE_TOOLTIP_TITLE") .. "|r\n" .. note)
end

local function HideMemberNoteTooltip()
    ZO_Tooltips_HideTextTooltip()
end

local function GetMemberRankIndex(guildId, displayName)
    local memberIndex = GetGuildMemberIndexFromDisplayName(guildId, displayName)
    if not memberIndex then return nil end
    local _, _, rankIndex = GetGuildMemberInfo(guildId, memberIndex)
    return rankIndex
end

local function CanKickMember(guildId, displayName)
    if not (guildId and displayName) then return false end
    if not (DoesPlayerHaveGuildPermission and DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_REMOVE)) then
        return false
    end

    local targetRank = GetMemberRankIndex(guildId, displayName)
    local selfRank = GetMemberRankIndex(guildId, GetDisplayName())
    if not (targetRank and selfRank) then return false end

    return targetRank > selfRank
end

local TIW_KICK_CONFIRM_DIALOG = "TIRADIL_IW_CONFIRM_KICK"

local function GetKickConfirmDialog()
    if not ESO_Dialogs[TIW_KICK_CONFIRM_DIALOG] then
        ESO_Dialogs[TIW_KICK_CONFIRM_DIALOG] = {
            canQueue = true,
            title = { text = "" },
            mainText = { text = "" },
            buttons = {
                [1] = { text = SI_DIALOG_CONFIRM, callback = function(dialog) end },
                [2] = { text = SI_DIALOG_CANCEL },
            },
        }
    end
    return ESO_Dialogs[TIW_KICK_CONFIRM_DIALOG]
end

local function ConfirmKickMember(guildId, displayName, guildName)
    local L = TiradilIWL10n.Get
    local dialog = GetKickConfirmDialog()
    dialog.title.text = L("KICK_CONFIRM_TITLE")
    dialog.mainText.text = zo_strformat(L("KICK_CONFIRM_TEXT"), displayName, guildName or "")
    dialog.buttons[1].callback = function()
        GuildRemove(guildId, displayName)
        if TiradilRosterColumn and TiradilRosterColumn.RemoveFromKickReview then
            TiradilRosterColumn.RemoveFromKickReview(guildId, displayName)
        end
        zo_callLater(function() TIW.RefreshKickList() end, 500)
    end
    ZO_Dialogs_ShowDialog(TIW_KICK_CONFIRM_DIALOG)
end

local function SetupRow(control, data)
    control.data = data
    local L = TiradilIWL10n.Get

    local memberLabel = control:GetNamedChild("Member")
    memberLabel:SetText(data.displayName)
    memberLabel:SetHandler("OnMouseEnter", function(self) ShowMemberNoteTooltip(self, data.displayName) end)
    memberLabel:SetHandler("OnMouseExit", HideMemberNoteTooltip)
    local guildLabel = control:GetNamedChild("Guild")
    guildLabel:SetText(data.guildName or "")
    guildLabel:SetColor(1, 1, 1, 1) -- varsayilana sifirla (renk uygulanamazsa beyaz kalsin)
    ApplyGuildColor(guildLabel, data.guildIndex)

    local daysLabel = control:GetNamedChild("Days")
    if data.daysInGuild then
        daysLabel:SetText(tostring(data.daysInGuild))
        daysLabel:SetColor(0.72, 0.72, 0.75, 1)
    else
        daysLabel:SetText("?")
        daysLabel:SetColor(0.48, 0.48, 0.52, 1)
    end

    local lastLabel = control:GetNamedChild("LastContrib")
    if data.lastContribTime then
        local daysAgoText = ""
        if data.daysSinceContrib then
            daysAgoText = " " .. zo_strformat(L("DAYS_AGO_FORMAT"), tostring(data.daysSinceContrib))
        end
        lastLabel:SetText(os.date("%d.%m.%y", data.lastContribTime) .. daysAgoText)
        lastLabel:SetColor(0.878, 0.6, 0.373, 1)
    else
        lastLabel:SetText(L("STATUS_NEVER"))
        lastLabel:SetColor(0.878, 0.439, 0.373, 1)
    end

    local totalLabel = control:GetNamedChild("Total")
    if data.daysSinceContrib then
        totalLabel:SetText(tostring(data.daysSinceContrib))
        if data.daysSinceContrib >= 60 then
            totalLabel:SetColor(0.878, 0.439, 0.373, 1) -- kirmizimsi: cok uzun suredir katkisiz
        elseif data.daysSinceContrib >= 30 then
            totalLabel:SetColor(0.929, 0.761, 0.365, 1) -- sarimsi: orta
        else
            totalLabel:SetColor(0.72, 0.72, 0.75, 1)
        end
    else
        totalLabel:SetText(L("DAYS_INACTIVE_UNKNOWN"))
        totalLabel:SetColor(0.48, 0.48, 0.52, 1)
    end
end

local function SetupKickRow(control, data)
    control.data = data
    local L = TiradilIWL10n.Get

    control:GetNamedChild("Member"):SetText(data.displayName)
    local memberLabel = control:GetNamedChild("Member")
    memberLabel:SetHandler("OnMouseEnter", function(self) ShowMemberNoteTooltip(self, data.displayName) end)
    memberLabel:SetHandler("OnMouseExit", HideMemberNoteTooltip)
    local guildLabel = control:GetNamedChild("Guild")
    guildLabel:SetText(data.guildName or "")
    guildLabel:SetColor(1, 1, 1, 1)
    ApplyGuildColor(guildLabel, GuildIdToIndex(data.guildId))

    local reasonLabel = control:GetNamedChild("Reason")
    if data.reason == "auto" then
        reasonLabel:SetText(L("KICK_REASON_AUTO"))
        reasonLabel:SetColor(0.878, 0.439, 0.373, 1)
    else
        reasonLabel:SetText(L("KICK_REASON_MANUAL"))
        reasonLabel:SetColor(0.929, 0.761, 0.365, 1)
    end

    local removeBtn = control:GetNamedChild("RemoveBtn")
    if data.reason == "manual" then
        removeBtn:SetHidden(false)
        removeBtn:SetHandler("OnClicked", function()
            if TiradilRosterColumn and TiradilRosterColumn.RemoveFromKickReview then
                TiradilRosterColumn.RemoveFromKickReview(data.guildId, data.displayName)
            end
            TIW.RefreshKickList()
        end)
    else
        removeBtn:SetHidden(true)
    end

    local kickBtn = control:GetNamedChild("KickBtn")
    if kickBtn then
        local canKick = CanKickMember(data.guildId, data.displayName)
        kickBtn:SetHidden(not canKick)
        if canKick then
            kickBtn:SetHandler("OnClicked", function()
                ConfirmKickMember(data.guildId, data.displayName, data.guildName)
            end)
        end
    end
end

local function InitializeList()
    local list = TiradilInactiveWatchWindowList
    if not list then return end
    ZO_ScrollList_AddDataType(list, ROW_TYPE, "TiradilIWRowTemplate", ROW_HEIGHT, SetupRow)
    ZO_ScrollList_AddDataType(list, KICK_ROW_TYPE, "TiradilIWKickRowTemplate", ROW_HEIGHT, SetupKickRow)
end

function TIW.RefreshDisplay()
    local list = TiradilInactiveWatchWindowList
    if not list then return end

    local dataList = ZO_ScrollList_GetDataList(list)
    for i = #dataList, 1, -1 do
        dataList[i] = nil
    end

    local search = (TIW.currentSearch or ""):lower()
    local flaggedCount = 0
    local guildsSeen = {}

    for i = 1, #TIW.cachedRows do
        local row = TIW.cachedRows[i]
        local include = true

        if TIW.selectedGuildFilter ~= nil and row.guildIndex ~= TIW.selectedGuildFilter then
            include = false
        end
        if include and search ~= "" then
            include = row.displayName:lower():find(search, 1, true) ~= nil
        end

        if include then
            table.insert(dataList, ZO_ScrollList_CreateDataEntry(ROW_TYPE, row))
            flaggedCount = flaggedCount + 1
            guildsSeen[row.guildIndex] = true
        end
    end

    ZO_ScrollList_Commit(list)

    local numGuildsSeen = 0
    for _ in pairs(guildsSeen) do numGuildsSeen = numGuildsSeen + 1 end

    local L = TiradilIWL10n.Get
    local summaryText = zo_strformat(L("SUMMARY_FORMAT"), tostring(flaggedCount), tostring(numGuildsSeen))

    if TiradilInactiveWatchWindowStatus then
        if not HasRosterData() then
            summaryText = L("STATUS_NO_ROSTER") .. "  |  " .. summaryText
        elseif not HasLedgerData() then
            summaryText = L("STATUS_NO_LEDGER") .. "  |  " .. summaryText
        end
        TiradilInactiveWatchWindowStatus:SetText(summaryText)
    end
end

function TIW.RefreshKickList()
    local list = TiradilInactiveWatchWindowList
    if not list then return end

    local dataList = ZO_ScrollList_GetDataList(list)
    for i = #dataList, 1, -1 do
        dataList[i] = nil
    end

    local search = (TIW.currentSearch or ""):lower()
    local autoCount, manualCount = 0, 0

    local manualEntries = {}
    if TiradilRosterColumn_SavedVars and TiradilRosterColumn_SavedVars.kickReviewList then
        for _, entry in ipairs(TiradilRosterColumn_SavedVars.kickReviewList) do
            local passesGuildFilter = (TIW.selectedGuildFilter == nil) or (GuildIdToIndex(entry.guildId) == TIW.selectedGuildFilter)
            local passesSearch = (search == "") or entry.displayName:lower():find(search, 1, true)
            if passesGuildFilter and passesSearch then
                table.insert(manualEntries, entry)
            end
        end
    end
    table.sort(manualEntries, function(a, b) return (a.markedAt or 0) > (b.markedAt or 0) end)

    for _, entry in ipairs(manualEntries) do
        table.insert(dataList, ZO_ScrollList_CreateDataEntry(KICK_ROW_TYPE, {
            displayName = entry.displayName,
            guildName = entry.guildName,
            guildId = entry.guildId,
            reason = "manual",
        }))
        manualCount = manualCount + 1
    end

    if TiradilRosterColumn and TiradilRosterColumn.IsEligibleForKick and TIW.cachedRows then
        for i = 1, #TIW.cachedRows do
            local row = TIW.cachedRows[i]
            local passesGuildFilter = (TIW.selectedGuildFilter == nil) or (row.guildIndex == TIW.selectedGuildFilter)
            local passesSearch = (search == "") or row.displayName:lower():find(search, 1, true)
            if passesGuildFilter and passesSearch then
                local guildId = GetGuildId(row.guildIndex)
                local ok, eligible = pcall(TiradilRosterColumn.IsEligibleForKick, guildId, row.displayName)
                if ok and eligible then
                    table.insert(dataList, ZO_ScrollList_CreateDataEntry(KICK_ROW_TYPE, {
                        displayName = row.displayName,
                        guildName = row.guildName,
                        guildId = guildId,
                        reason = "auto",
                    }))
                    autoCount = autoCount + 1
                end
            end
        end
    end

    ZO_ScrollList_Commit(list)

    if TiradilInactiveWatchWindowStatus then
        local L = TiradilIWL10n.Get
        TiradilInactiveWatchWindowStatus:SetText(
            zo_strformat(L("KICK_LIST_SUMMARY"), tostring(autoCount), tostring(manualCount)))
    end
end

function TIW.SelectTab(tab)
    TIW.currentTab = tab
    local isKick = (tab == "kick")

    if TiradilInactiveWatchWindowTabWatch then
        TiradilInactiveWatchWindowTabWatch:SetState(isKick and BSTATE_NORMAL or BSTATE_PRESSED, false)
    end
    if TiradilInactiveWatchWindowTabKick then
        TiradilInactiveWatchWindowTabKick:SetState(isKick and BSTATE_PRESSED or BSTATE_NORMAL, false)
    end

    local watchOnlyControls = {
        TiradilInactiveWatchWindowThresholdLabel,
        TiradilInactiveWatchWindowT14,
        TiradilInactiveWatchWindowT30,
        TiradilInactiveWatchWindowT60,
        TiradilInactiveWatchWindowColDays,
        TiradilInactiveWatchWindowColLastContrib,
        TiradilInactiveWatchWindowColTotal,
    }
    for _, ctrl in ipairs(watchOnlyControls) do
        if ctrl then ctrl:SetHidden(isKick) end
    end

    if isKick then
        TIW.RefreshKickList()
    else
        TIW.RefreshDisplay()
    end
end

function TIW.Refresh()
    if TiradilInactiveWatchWindowStatus then
        TiradilInactiveWatchWindowStatus:SetText(TiradilIWL10n.Get("STATUS_LOADING"))
    end
    TIW.ScanGuilds()
    if TIW.currentTab == "kick" then
        TIW.RefreshKickList()
    else
        TIW.RefreshDisplay()
    end
end

function TIW.UpdateTotalColumnHeader()
    if not TiradilInactiveWatchWindowColTotal then return end
    TiradilInactiveWatchWindowColTotal:SetText(TiradilIWL10n.Get("COL_TOTAL"))
end

function TIW.SetThreshold(days, control)
    TIW.currentThreshold = days
    TIW.savedVars.threshold = days

    local names = { "T14", "T30", "T60" }
    for _, n in ipairs(names) do
        local btn = _G["TiradilInactiveWatchWindow" .. n]
        if btn then
            btn:SetState(BSTATE_NORMAL, false)
        end
    end
    if control then
        control:SetState(BSTATE_PRESSED, false)
    end

    TIW.UpdateTotalColumnHeader()
    TIW.Refresh()
end

function TIW.SetGuildFilter(guildIndex, control)
    TIW.selectedGuildFilter = guildIndex

    if TiradilInactiveWatchWindowGF0 then
        TiradilInactiveWatchWindowGF0:SetState(BSTATE_NORMAL, false)
    end
    for i = 1, 5 do
        local btn = _G["TiradilInactiveWatchWindowGF" .. i]
        if btn then
            btn:SetState(BSTATE_NORMAL, false)
        end
    end
    if control then
        control:SetState(BSTATE_PRESSED, false)
    end

    if TIW.currentTab == "kick" then
        TIW.RefreshKickList()
    else
        TIW.RefreshDisplay()
    end
end

function TIW.OnSearchTextChanged(editControl)
    TIW.currentSearch = editControl:GetText()
    TIW.searchGeneration = (TIW.searchGeneration or 0) + 1
    local myGeneration = TIW.searchGeneration
    zo_callLater(function()
        if TIW.searchGeneration ~= myGeneration then return end
        if TIW.currentTab == "kick" then
            TIW.RefreshKickList()
        else
            TIW.RefreshDisplay()
        end
    end, 200)
end

local function ConfigureGuildFilterButtons()
    local numGuilds = GetNumGuilds()
    for i = 1, 5 do
        local btn = _G["TiradilInactiveWatchWindowGF" .. i]
        if btn then
            btn:SetHidden(i > numGuilds)
        end
    end
end

function TIW.ToggleWindow()
    if TiradilInactiveWatchWindow:IsHidden() then
        TiradilInactiveWatchWindow:SetHidden(false)
        TIW.Refresh()
        EVENT_MANAGER:RegisterForUpdate("TiradilInactiveWatchAutoRefresh", 20000, function()
            if TiradilInactiveWatchWindow:IsHidden() then
                EVENT_MANAGER:UnregisterForUpdate("TiradilInactiveWatchAutoRefresh")
                return
            end
            TIW.Refresh()
        end)
    else
        TiradilInactiveWatchWindow:SetHidden(true)
        EVENT_MANAGER:UnregisterForUpdate("TiradilInactiveWatchAutoRefresh")
    end
end

function TIW.Initialize()
    TiradilInactiveWatch_SavedVars = TiradilInactiveWatch_SavedVars or {
        threshold = 30,
    }
    TIW.savedVars = TiradilInactiveWatch_SavedVars
    TIW.currentThreshold = TIW.savedVars.threshold or 30

    InitializeList()
    ConfigureGuildFilterButtons()

    TiradilInactiveWatchWindow:SetMovable(true)

    local thresholdControlName = "TiradilInactiveWatchWindowT" .. tostring(TIW.currentThreshold)
    local btn = _G[thresholdControlName]
    if btn then
        btn:SetState(BSTATE_PRESSED, false)
    end
    if TiradilInactiveWatchWindowGF0 then
        TiradilInactiveWatchWindowGF0:SetState(BSTATE_PRESSED, false)
    end
    TIW.UpdateTotalColumnHeader()
    TIW.currentTab = "watch" -- varsayilan sekme; ilk RefreshDisplay/RefreshKickList cagrisinda kullanilir
end
