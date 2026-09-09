TiradilRoster = {}

local ROW_TYPE = 1
local ROW_HEIGHT = 26

local tabNames = {
    "Approved",
    "Invited",
    "Joined",
    "Rejected",
    "Kicked",
    "Left",
    "Promoted",
    "Demoted",
}

local TAB_EVENT_TYPE = {
    GUILD_HISTORY_ROSTER_EVENT_APPLICATION_ACCEPTED,
    GUILD_HISTORY_ROSTER_EVENT_INVITE,
    GUILD_HISTORY_ROSTER_EVENT_JOIN,
    GUILD_HISTORY_ROSTER_EVENT_APPLICATION_DECLINED,
    GUILD_HISTORY_ROSTER_EVENT_KICKED,
    GUILD_HISTORY_ROSTER_EVENT_LEAVE,
    GUILD_HISTORY_ROSTER_EVENT_PROMOTE,
    GUILD_HISTORY_ROSTER_EVENT_DEMOTE,
}

local FALLBACK_GUILD_COLORS = {
    { 0.40, 0.70, 1.00 },
    { 1.00, 0.55, 0.55 },
    { 0.55, 1.00, 0.55 },
    { 1.00, 0.80, 0.40 },
    { 0.80, 0.55, 1.00 },
}

local function GetGuildColor(guildIndex)
    local chatCategoryName = "CHAT_CATEGORY_GUILD_" .. tostring(guildIndex)
    local chatCategory = _G[chatCategoryName]
    if chatCategory and GetChatCategoryColor then
        local ok, r, g, b = pcall(GetChatCategoryColor, chatCategory)
        if ok and r then
            return r, g, b
        end
    end
    local fallback = FALLBACK_GUILD_COLORS[((guildIndex - 1) % #FALLBACK_GUILD_COLORS) + 1]
    return fallback[1], fallback[2], fallback[3]
end
TiradilRoster.GetGuildColor = GetGuildColor

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

local function GetDateFilterCutoff()
    local filter = TiradilRoster.currentDateFilter
    if filter == nil or filter == "All" then
        return nil
    elseif filter == "Week" then
        return GetThisWeekStartEpoch()
    elseif filter == "D7" then
        return os.time() - 7 * 86400
    elseif filter == "D30" then
        return os.time() - 30 * 86400
    end
    return nil
end

TiradilRoster.events = { {}, {}, {}, {}, {}, {}, {}, {} }
TiradilRoster.currentTab = 1
TiradilRoster.currentSearch = ""
TiradilRoster.currentGuildFilter = nil -- nil = All
TiradilRoster.currentDateFilter = "All"
TiradilRoster.statsMode = false

function TiradilRoster.ShowListView()
    TiradilRoster.statsMode = false
    TiradilRosterWindowList:SetHidden(false)
    TiradilRosterWindowStatsDisplay:SetHidden(true)
    TiradilRoster.RefreshList()
end

function TiradilRoster.ShowStatsView()
    TiradilRoster.statsMode = true
    TiradilRosterWindowList:SetHidden(true)
    TiradilRosterWindowStatsDisplay:SetHidden(false)
    TiradilRoster.RefreshStats()
end

function TiradilRoster.ToggleStats()
    if TiradilRoster.statsMode then
        TiradilRoster.ShowListView()
    else
        TiradilRoster.ShowStatsView()
    end
end

function TiradilRoster.RefreshCurrentView()
    if TiradilRoster.statsMode then
        TiradilRoster.RefreshStats()
    else
        TiradilRoster.RefreshList()
    end
end

function TiradilRoster.RefreshStats()
    local search = (TiradilRoster.currentSearch or ""):lower()
    local guildFilter = TiradilRoster.currentGuildFilter
    local dateCutoff = GetDateFilterCutoff()

    local stats = {}
    local order = {}

    for tabIndex = 1, 8 do
        local events = TiradilRoster.events[tabIndex]
        for i = 1, #events do
            local e = events[i]
            if e.acting and e.acting ~= "" then
                local include = true
                if guildFilter ~= nil and e.guildIndex ~= guildFilter then include = false end
                if dateCutoff ~= nil and e.time < dateCutoff then include = false end
                if search ~= "" and not e.acting:lower():find(search, 1, true) then include = false end

                if include then
                    if not stats[e.acting] then
                        stats[e.acting] = { total = 0 }
                        table.insert(order, e.acting)
                    end
                    stats[e.acting][tabIndex] = (stats[e.acting][tabIndex] or 0) + 1
                    stats[e.acting].total = stats[e.acting].total + 1
                end
            end
        end
    end

    table.sort(order, function(a, b)
        return stats[a].total > stats[b].total
    end)

    local lines = {}
    table.insert(lines, "|cFFB800" .. TiradilL10n.Get("ROSTER_STATS_TITLE") .. "|r")
    table.insert(lines, "")

    if #order == 0 then
        table.insert(lines, TiradilL10n.Get("ROSTER_STATS_NO_DATA"))
    else
        for _, name in ipairs(order) do
            local s = stats[name]
            local parts = {}
            for tabIndex, label in ipairs(tabNames) do
                local c = s[tabIndex]
                if c and c > 0 then
                    table.insert(parts, label .. ": " .. c)
                end
            end
            table.insert(lines, string.format("|c4DDB4D%s|r  -  Total: %d  (%s)", name, s.total, table.concat(parts, ", ")))
        end
    end

    TiradilRosterWindowStatsDisplay:SetText(table.concat(lines, "\n"))
end

local function SetupRow(control, data)
    control.data = data
    control:GetNamedChild("Time"):SetText(data.timeStr)

    local guildLabel = control:GetNamedChild("Guild")
    guildLabel:SetText(data.guildName or "")
    if data.guildColor then
        guildLabel:SetColor(data.guildColor[1], data.guildColor[2], data.guildColor[3], 1)
    else
        guildLabel:SetColor(0.75, 0.75, 0.75, 1)
    end

    control:GetNamedChild("From"):SetText(data.acting or "")
    control:GetNamedChild("To"):SetText(data.target or "")
end

local function InitializeList()
    local list = TiradilRosterWindowList
    ZO_ScrollList_AddDataType(list, ROW_TYPE, "TiradilRosterRowTemplate", ROW_HEIGHT, SetupRow)
end

function TiradilRoster.RefreshList()
    local list = TiradilRosterWindowList
    local dataList = ZO_ScrollList_GetDataList(list)
    for i = #dataList, 1, -1 do
        dataList[i] = nil
    end

    local search = (TiradilRoster.currentSearch or ""):lower()
    local guildFilter = TiradilRoster.currentGuildFilter
    local dateCutoff = GetDateFilterCutoff()
    local events = TiradilRoster.events[TiradilRoster.currentTab]

    local filtered = {}
    for i = 1, #events do
        local e = events[i]
        local include = true

        if search ~= "" then
            local haystack = ((e.acting or "") .. " " .. (e.target or "")):lower()
            include = haystack:find(search, 1, true) ~= nil
        end
        if include and guildFilter ~= nil and e.guildIndex ~= guildFilter then
            include = false
        end
        if include and dateCutoff ~= nil and e.time < dateCutoff then
            include = false
        end

        if include then
            table.insert(filtered, e)
        end
    end

    table.sort(filtered, function(a, b)
        return a.time > b.time
    end)

    for i = 1, #filtered do
        local e = filtered[i]
        local r, g, b = GetGuildColor(e.guildIndex or 1)
        local rowData = {
            timeStr = os.date("%d.%m.%y %H:%M", e.time),
            guildName = e.guildName,
            guildColor = { r, g, b },
            acting = e.acting,
            target = e.target,
        }
        table.insert(dataList, ZO_ScrollList_CreateDataEntry(ROW_TYPE, rowData))
    end

    ZO_ScrollList_Commit(list)
end

function TiradilRoster.SelectTab(tabIndex)
    TiradilRoster.currentTab = tabIndex
    TiradilRoster.ShowListView()

    for i = 1, 8 do
        local btn = _G["TiradilRosterWindowTab" .. i]
        if btn then
            btn:SetState(i == tabIndex and BSTATE_PRESSED or BSTATE_NORMAL, false)
        end
    end
end

function TiradilRoster.SelectGuildFilter(guildIndex, control)
    if guildIndex == 0 then
        TiradilRoster.currentGuildFilter = nil
    else
        TiradilRoster.currentGuildFilter = guildIndex
    end

    for i = 0, 5 do
        local btn = _G["TiradilRosterWindowGF" .. i]
        if btn then
            btn:SetState(BSTATE_NORMAL, false)
        end
    end
    control:SetState(BSTATE_PRESSED, false)

    TiradilRoster.RefreshCurrentView()
end

function TiradilRoster.SelectDateFilter(filterName, control)
    TiradilRoster.currentDateFilter = filterName

    local names = { "Week", "D7", "D30", "All" }
    for _, n in ipairs(names) do
        local btn = _G["TiradilRosterWindowDF" .. n]
        if btn then
            btn:SetState(BSTATE_NORMAL, false)
        end
    end
    control:SetState(BSTATE_PRESSED, false)

    TiradilRoster.RefreshCurrentView()
end

function TiradilRoster.OnSearchTextChanged(editControl)
    TiradilRoster.currentSearch = editControl:GetText()
    TiradilRoster.RefreshCurrentView()
end

function TiradilRoster.ToggleWindow()
    if TiradilRosterWindow:IsHidden() then
        TiradilRosterWindow:SetHidden(false)
        TiradilRoster.RefreshCurrentView()
    else
        TiradilRosterWindow:SetHidden(true)
    end
end

local function OnHistoryEvent(event, guildName, guildIndex)
    local eventType = event:GetEventType()
    local info = event:GetEventInfo()
    local timestamp = event:GetEventTimestampS()

    for tabIndex, wantedType in ipairs(TAB_EVENT_TYPE) do
        if eventType == wantedType then
            local acting = info.actingDisplayName
            local target = info.targetDisplayName
            if target == nil or target == "" then
                target = acting
                acting = nil
            end
            if (eventType == GUILD_HISTORY_ROSTER_EVENT_PROMOTE or eventType == GUILD_HISTORY_ROSTER_EVENT_DEMOTE) and info.rankName then
                target = target .. "  (" .. info.rankName .. ")"
            end

            table.insert(TiradilRoster.events[tabIndex], {
                time = timestamp,
                acting = acting,
                target = target,
                guildName = guildName,
                guildIndex = guildIndex,
            })

            if timestamp >= TiradilRoster.trackingStartedAt then
                local label = tabNames[tabIndex]
                local msg
                if acting then
                    msg = string.format("|cFFB800[Roster]|r %s (%s): |c4DDB4D%s|r -> |cFFB800%s|r",
                        label, guildName or "?", acting, target or "")
                else
                    msg = string.format("|cFFB800[Roster]|r %s (%s): |cFFB800%s|r",
                        label, guildName or "?", target or "")
                end
                d(msg)
            end

            if not TiradilRosterWindow:IsHidden() then
                if TiradilRoster.statsMode then
                    TiradilRoster.RefreshStats()
                elseif TiradilRoster.currentTab == tabIndex then
                    TiradilRoster.RefreshList()
                end
            end
        end
    end
end

local function TryStartTracking()
    if LibHistoire == nil then
        d("|cFF6B6BTiradilRoster:|r " .. TiradilL10n.Get("CHAT_LIBHISTOIRE_MISSING"))
        return
    end

    if not LibHistoire:IsReady() then
        zo_callLater(TryStartTracking, 2000)
        return
    end

    local numGuilds = GetNumGuilds()
    for i = 1, numGuilds do
        local guildId = GetGuildId(i)
        local guildName = GetGuildName(guildId)
        local processor = LibHistoire:CreateGuildHistoryProcessor(guildId, GUILD_HISTORY_EVENT_CATEGORY_ROSTER, "TiradilRoster")
        if processor then
            processor:StartStreaming(nil, function(event)
                OnHistoryEvent(event, guildName, i)
            end)
        end
    end

    d("|c4DDB4DTiradilRoster:|r " .. zo_strformat(TiradilL10n.Get("CHAT_TRACKING_STARTED"), tostring(numGuilds)))
end

local function SlashCommand_Roster()
    TiradilRoster.ToggleWindow()
end

local function ConfigureGuildFilterButtons()
    local numGuilds = GetNumGuilds()
    for i = 1, 5 do
        local btn = _G["TiradilRosterWindowGF" .. i]
        if btn then
            btn:SetHidden(i > numGuilds)
        end
    end
end

function TiradilRoster.Initialize()
    TiradilRoster_SavedVariables = TiradilRoster_SavedVariables or {}
    TiradilRoster.savedVars = TiradilRoster_SavedVariables

    InitializeList()
    ConfigureGuildFilterButtons()
    SLASH_COMMANDS["/roster"] = SlashCommand_Roster

    TiradilRosterWindow:SetMovable(true)

    TiradilRosterWindowTab1:SetState(BSTATE_PRESSED, false)

    TiradilRoster.trackingStartedAt = os.time()
    TryStartTracking()
end
