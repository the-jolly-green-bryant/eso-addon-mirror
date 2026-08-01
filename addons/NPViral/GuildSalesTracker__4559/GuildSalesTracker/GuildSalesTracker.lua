-- GuildSalesTracker.lua
-- Author:  @NPViral
-- Version: 1.1
--
-- Personal weekly guild sales tracker.
-- Shows your sales this week per guild vs weekly requirement.
-- Compact single-row display with progress bar and checkmark.

GuildSalesTracker = GuildSalesTracker or {}
local addon = GuildSalesTracker
addon.name    = "GuildSalesTracker"
addon.version = "1.1"

local EM = EVENT_MANAGER
local WM = GetWindowManager()

------------------------------------------------------------------------
-- Saved Variables
------------------------------------------------------------------------

local defaults = {
    version           = 1,
    lastEventId       = {},
    weeklySales       = {},
    requirements      = {},
    weekStartCache    = 0,
    panelX            = 353,
    panelY            = 288,
    panelWidth        = 380,
    locked            = false,
    showOnTraderOpen  = true,
    showRequirement   = true,
    showPercent       = true,
    showItems         = true,
    hideNoRequirement = false,
    hiddenGuilds      = {},
}

local sv

------------------------------------------------------------------------
-- In-memory state
------------------------------------------------------------------------

local weeklySales      = {}
local processors       = {}
local localDisplayName = nil
local weekStart        = nil

-- Layout constants
local PAD      = 8
local HEADER_H = 28
local FOOTER_H = 6
local ROW_H    = 28

-- ZO_ScrollList data type
local TYPE_ROW = 1

------------------------------------------------------------------------
-- EU Trading Week: Tuesday 14:00 UTC
------------------------------------------------------------------------

local function ComputeTraderWeekStart()
    local now = GetTimeStamp()
    local t   = os.date("!*t", now)
    local daysSinceTue     = (t.wday - 3) % 7
    local secSinceMidnight = daysSinceTue * 86400 + t.hour * 3600
                           + t.min * 60 + t.sec
    local secSinceReset = secSinceMidnight - (14 * 3600)
    if secSinceReset < 0 then secSinceReset = secSinceReset + 7 * 86400 end
    return now - secSinceReset
end

------------------------------------------------------------------------
-- Number formatting
------------------------------------------------------------------------

local function FormatGold(n)
    if n >= 1000000 then return string.format("%.2fM", n / 1000000)
    elseif n >= 1000 then return string.format("%.1fK", n / 1000)
    end
    return tostring(n)
end

------------------------------------------------------------------------
-- Queued panel update: defined before OnSaleEvent
------------------------------------------------------------------------

local panelDirty = false
local QUEUE_NS   = addon.name .. "_PanelQueue"

local function OnQueueTick()
    if panelDirty then
        panelDirty = false
        addon.UpdatePanel()
    else
        EM:UnregisterForUpdate(QUEUE_NS)
    end
end

local function QueuePanelUpdate()
    panelDirty = true
    EM:RegisterForUpdate(QUEUE_NS, 250, OnQueueTick)
end

------------------------------------------------------------------------
-- LibHistoire event processing
------------------------------------------------------------------------

local function OnSaleEvent(guildId, processorKey, event)
    local eventTime = event:GetEventTimestampS()
    local info      = event:GetEventInfo()

    sv.lastEventId[processorKey] = info.eventId

    if info.eventType ~= GUILD_HISTORY_TRADER_EVENT_ITEM_SOLD then return end
    if eventTime < weekStart then return end

    local seller = DecorateDisplayName(info.sellerDisplayName):lower()
    if seller ~= localDisplayName then return end

    local key     = tostring(guildId)
    local current = sv.weeklySales[key] or { gold = 0, items = 0 }
    if type(current) == "number" then
        current = { gold = current, items = 0 }
    end

    current.gold  = current.gold  + info.price
    current.items = current.items + (info.quantity or 1)

    sv.weeklySales[key] = current
    weeklySales[guildId] = current

    QueuePanelUpdate()
end

local function SetupProcessors(lib)
    for i = 1, GetNumGuilds() do
        local guildId   = GetGuildId(i)
        local guildName = GetGuildName(guildId)
        local processor = lib:CreateGuildHistoryProcessor(
            guildId, GUILD_HISTORY_EVENT_CATEGORY_TRADER, addon.name)

        if not processor then
            CHAT_SYSTEM:AddMessage(
                "|cFFAA00[GuildSalesTracker]|r Could not create processor for " .. guildName)
        else
            processors[guildId] = processor
            local key    = processor:GetKey()
            local lastId = sv.lastEventId[key]
            local started = processor:StartStreaming(lastId, function(event)
                OnSaleEvent(guildId, key, event)
            end)
            if not started then
                CHAT_SYSTEM:AddMessage(
                    "|cFFAA00[GuildSalesTracker]|r Processor failed to start for " .. guildName)
            end
        end
    end
end

------------------------------------------------------------------------
-- Bar colors: muted ESO palette
------------------------------------------------------------------------

local BAR_GREEN = { r = 0.42, g = 0.63, b = 0.33 }
local BAR_AMBER = { r = 0.85, g = 0.65, b = 0.22 }
local BAR_RED   = { r = 0.76, g = 0.26, b = 0.22 }

local function GetBarColor(pct)
    if pct >= 1.0 then return BAR_GREEN end
    if pct >= 0.5 then return BAR_AMBER end
    return BAR_RED
end

------------------------------------------------------------------------
-- Stats text builder
------------------------------------------------------------------------

local function BuildStatsText(gold, items, req)
    local s = FormatGold(gold)
    if sv.showRequirement and req and req > 0 then
        s = s .. " / " .. FormatGold(req)
    end
    if sv.showItems then
        s = s .. "  |cAAAAAA" .. items .. " items|r"
    end
    if sv.showPercent and req and req > 0 then
        local pct = math.floor((gold / req) * 100)
        s = s .. "  |cAAAAAA" .. pct .. "%|r"
    end
    return s
end

------------------------------------------------------------------------
-- Startup readiness flags
-- UpdatePanel runs only after both EVENT_PLAYER_ACTIVATED and
-- LibHistoire:OnReady have fired, regardless of order.
------------------------------------------------------------------------

local uiReady   = false
local histReady = false

local function TryFirstUpdate()
    if uiReady and histReady then
        addon.UpdatePanel()
    end
end

------------------------------------------------------------------------
-- ZO_ScrollList row setup callback
--
-- Every property must be set explicitly on every call.
-- ZO_ScrollList recycles row controls: old values persist between reuse.
------------------------------------------------------------------------

local function SetupRow(ctrl, data)
    local trackCtrl = ctrl:GetNamedChild("Track")
    local fillCtrl  = ctrl:GetNamedChild("Fill")
    local nameCtrl  = ctrl:GetNamedChild("Name")
    local statsCtrl = ctrl:GetNamedChild("Stats")
    local checkCtrl = ctrl:GetNamedChild("Check")
    local divCtrl   = ctrl:GetNamedChild("Divider")

    local gold  = data.gold  or 0
    local items = data.items or 0
    local req   = data.req

    -- Track: slightly lighter for active guild
    if data.isActive then
        trackCtrl:SetColor(0.15, 0.15, 0.28, 1)
    else
        trackCtrl:SetColor(0.05, 0.05, 0.05, 1)
    end

    -- Fill bar: always set all properties explicitly
    local rowWidth = ctrl:GetWidth()
    if rowWidth <= 0 then rowWidth = sv.panelWidth or 380 end
    local availW = rowWidth - 8

    if req and req > 0 then
        local pct   = math.min(gold / req, 1.0)
        local fillW = math.max(10, math.floor(availW * pct))
        local c     = GetBarColor(pct)
        fillCtrl:SetWidth(fillW)
        fillCtrl:SetGradientColors(
            ORIENTATION_HORIZONTAL,
            c.r * 0.55, c.g * 0.55, c.b * 0.55, 0.90,
            c.r,        c.g,        c.b,        0.90)
        fillCtrl:SetHidden(false)
    else
        fillCtrl:SetWidth(10)
        fillCtrl:SetGradientColors(
            ORIENTATION_HORIZONTAL,
            0.20, 0.20, 0.20, 0.60,
            0.25, 0.25, 0.25, 0.60)
        fillCtrl:SetHidden(false)
    end

    -- Name: left portion of row
    local nameW = math.floor(rowWidth * 0.45)
    nameCtrl:SetWidth(nameW)
    nameCtrl:SetText(data.name)
    nameCtrl:SetColor(1.00, 0.96, 0.86, 1)
    nameCtrl:SetWrapMode(TEXT_WRAP_MODE_NONE)

    -- Stats
    statsCtrl:SetText(BuildStatsText(gold, items, req))
    statsCtrl:SetColor(0.80, 0.77, 0.70, 1)

    -- Checkmark: shown green when requirement met
    if req and req > 0 and gold >= req then
        checkCtrl:SetColor(BAR_GREEN.r, BAR_GREEN.g, BAR_GREEN.b, 1)
        checkCtrl:SetHidden(false)
    else
        checkCtrl:SetHidden(true)
    end

    -- Divider: hidden on last row
    if data.isLast then
        divCtrl:SetHidden(true)
    else
        divCtrl:SetColor(0.90, 0.76, 0.38, 0.25)
        divCtrl:SetHidden(false)
    end
end

------------------------------------------------------------------------
-- Panel UI
------------------------------------------------------------------------

local panelWindow = nil
local listControl = nil
local panelFrag   = nil
local headerLabel = nil

local function BuildPanel()
    panelWindow = GuildSalesTrackerPanel
    panelWindow:SetDimensions(sv.panelWidth or 380, HEADER_H + ROW_H + FOOTER_H)
    panelWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.panelX, sv.panelY)
    panelWindow:SetMovable(not sv.locked)
    panelWindow:SetHidden(true)
    panelWindow:SetHandler("OnMoveStop", function()
        sv.panelX = panelWindow:GetLeft()
        sv.panelY = panelWindow:GetTop()
    end)

    local bg = panelWindow:GetNamedChild("BG")
    if bg then
        bg:SetCenterColor(0, 0, 0, 0.88)
        bg:SetEdgeColor(0.90, 0.76, 0.38, 0.90)
    end

    headerLabel = WM:CreateControl(
        "GuildSalesTrackerHeader", panelWindow, CT_LABEL)
    headerLabel:SetAnchor(TOPLEFT, panelWindow, TOPLEFT, PAD + 2, 6)
    headerLabel:SetFont("EsoUI/Common/Fonts/ProseAntiquePSMT.otf|16")
    headerLabel:SetColor(0.90, 0.76, 0.38, 1)
    headerLabel:SetText("Weekly Guild Sales")

    listControl = WM:CreateControlFromVirtual(
        "GuildSalesTrackerList", panelWindow, "ZO_ScrollList")
    listControl:SetAnchor(TOPLEFT,  panelWindow, TOPLEFT,  0, HEADER_H)
    listControl:SetAnchor(TOPRIGHT, panelWindow, TOPRIGHT, 0, HEADER_H)
    listControl:SetHeight(ROW_H)
    listControl:GetNamedChild("Contents"):SetMouseEnabled(false)
    ZO_ScrollList_SetHideScrollbarOnDisable(listControl, true)
    ZO_ScrollList_SetUseScrollbar(listControl, false)

    ZO_ScrollList_AddDataType(listControl, TYPE_ROW,
        "GuildSalesTracker_CompactRow", ROW_H, SetupRow)

    panelFrag = ZO_SimpleSceneFragment:New(panelWindow)
    panelFrag:SetConditional(function() return sv.showOnTraderOpen end)
    panelFrag:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_FRAGMENT_SHOWN then
            addon.UpdatePanel()
        end
    end)
    TRADING_HOUSE_SCENE:AddFragment(panelFrag)
end

-- Debounce flag prevents multiple rapid resize calls from stacking
local resizePending = false

function addon.UpdatePanel()
    if not listControl then return end

    local visibleGuilds = {}
    for i = 1, GetNumGuilds() do
        local guildId   = GetGuildId(i)
        local guildName = GetGuildName(guildId)
        local req       = sv.requirements[guildName]
        if not sv.hiddenGuilds[guildName]
        and not (sv.hideNoRequirement and (not req or req == 0)) then
            visibleGuilds[#visibleGuilds + 1] = {
                id = guildId, name = guildName, req = req }
        end
    end

    local count = #visibleGuilds

    local pw = sv.panelWidth or 380
    panelWindow:SetWidth(pw)
    listControl:SetWidth(pw)

    local activeGuildId = nil
    local detailId = GetCurrentTradingHouseGuildDetails()
    if detailId and detailId ~= 0 then activeGuildId = detailId end

    ZO_ScrollList_Clear(listControl)
    local dataList = ZO_ScrollList_GetDataList(listControl)

    for i, g in ipairs(visibleGuilds) do
        local salesData = weeklySales[g.id] or { gold = 0, items = 0 }
        table.insert(dataList, ZO_ScrollList_CreateDataEntry(TYPE_ROW, {
            name     = g.name,
            req      = g.req,
            gold     = salesData.gold  or 0,
            items    = salesData.items or 0,
            isActive = (g.id == activeGuildId),
            isLast   = (i == count),
        }))
    end

    ZO_ScrollList_Commit(listControl)

    local finalCount = count
    if not resizePending then
        resizePending = true
        zo_callLater(function()
            resizePending = false
            local listH = finalCount * ROW_H
            listControl:SetHeight(math.max(listH, 1))
            panelWindow:SetHeight(HEADER_H + listH + FOOTER_H)
        end, 0)
    end
end

------------------------------------------------------------------------
-- LAM Settings
------------------------------------------------------------------------

local function BuildSettings()
    local LAM = LibAddonMenu2

    local panelData = {
        type               = "panel",
        name               = "GuildSalesTracker",
        displayName        = "Guild Sales Tracker",
        author             = "@NPViral",
        version            = addon.version,
        slashCommand       = "/gst settings",
        registerForRefresh = true,
    }

    local function BuildOptions()
        local opts = {
            { type = "header", name = "Display" },
            {
                type    = "checkbox",
                name    = "Show panel when guild store opens",
                tooltip = "Display the panel automatically when you open any guild store.",
                getFunc = function() return sv.showOnTraderOpen end,
                setFunc = function(v)
                    sv.showOnTraderOpen = v
                    if panelWindow then
                        panelWindow:SetHidden(
                            not (v and TRADING_HOUSE_SCENE:IsShowing()))
                    end
                end,
            },
            {
                type    = "slider",
                name    = "Panel width",
                tooltip = "Adjust the panel width to fit your guild names.",
                min     = 200,
                max     = 600,
                step    = 10,
                getFunc = function() return sv.panelWidth or 380 end,
                setFunc = function(v)
                    sv.panelWidth = v
                    if panelWindow then
                        panelWindow:SetWidth(v)
                        listControl:SetWidth(v)
                    end
                    addon.UpdatePanel()
                end,
            },
            {
                type    = "checkbox",
                name    = "Show requirement threshold",
                tooltip = "Show your weekly requirement next to your total.",
                getFunc = function() return sv.showRequirement end,
                setFunc = function(v) sv.showRequirement = v addon.UpdatePanel() end,
            },
            {
                type    = "checkbox",
                name    = "Show item count",
                tooltip = "Show how many items you sold this week.",
                getFunc = function() return sv.showItems end,
                setFunc = function(v) sv.showItems = v addon.UpdatePanel() end,
            },
            {
                type    = "checkbox",
                name    = "Show percentage of requirement",
                tooltip = "Show your progress toward the weekly requirement.",
                getFunc = function() return sv.showPercent end,
                setFunc = function(v) sv.showPercent = v addon.UpdatePanel() end,
            },
            { type = "header", name = "Guild Requirements" },
            { type = "description",
              text = "Set your weekly sales requirement per guild (0 = no requirement)." },
        }

        for i = 1, GetNumGuilds() do
            local guildName = GetGuildName(GetGuildId(i))
            opts[#opts + 1] = {
                type    = "slider",
                name    = guildName,
                tooltip = "Weekly requirement for " .. guildName .. " (gold).",
                min     = 0, max = 2000000, step = 10000,
                getFunc = function() return sv.requirements[guildName] or 0 end,
                setFunc = function(v)
                    sv.requirements[guildName] = (v > 0) and v or nil
                    addon.UpdatePanel()
                end,
            }
        end

        opts[#opts + 1] = { type = "header", name = "Guild Visibility" }
        opts[#opts + 1] = {
            type    = "checkbox",
            name    = "Hide guilds with no requirement set",
            tooltip = "Only show guilds where you have set a requirement.",
            getFunc = function() return sv.hideNoRequirement end,
            setFunc = function(v) sv.hideNoRequirement = v addon.UpdatePanel() end,
        }
        opts[#opts + 1] = {
            type = "description",
            text = "Manually show or hide specific guilds." }

        for i = 1, GetNumGuilds() do
            local guildName = GetGuildName(GetGuildId(i))
            opts[#opts + 1] = {
                type    = "checkbox",
                name    = "Show: " .. guildName,
                getFunc = function() return not sv.hiddenGuilds[guildName] end,
                setFunc = function(v)
                    sv.hiddenGuilds[guildName] = v and nil or true
                    addon.UpdatePanel()
                end,
            }
        end

        opts[#opts + 1] = { type = "header", name = "Panel" }
        opts[#opts + 1] = {
            type    = "checkbox",
            name    = "Lock panel position",
            getFunc = function() return sv.locked end,
            setFunc = function(v)
                sv.locked = v
                if panelWindow then panelWindow:SetMovable(not v) end
            end,
        }
        opts[#opts + 1] = {
            type    = "button",
            name    = "Reset weekly totals",
            tooltip = "Clear all sales totals and rescan from this week's start.",
            func    = function()
                ZO_ClearTable(weeklySales)
                ZO_ClearTable(sv.weeklySales)
                ZO_ClearTable(sv.lastEventId)
                for _, p in pairs(processors) do p:Stop() end
                ZO_ClearTable(processors)
                LibHistoire:OnReady(function(lib) SetupProcessors(lib) end)
                addon.UpdatePanel()
                CHAT_SYSTEM:AddMessage("|c88CCFF[GuildSalesTracker]|r Totals reset.")
            end,
            width = "half",
        }
        opts[#opts + 1] = {
            type    = "button",
            name    = "Feeling generous?",
            tooltip = "Donations keep the skooma flowing.",
            func    = function()
                local ok = pcall(function()
                    if MAIN_MENU_KEYBOARD and type(MAIN_MENU_KEYBOARD.ShowScene) == "function" then
                        MAIN_MENU_KEYBOARD:ShowScene("mailSend")
                    end
                    if ZO_MailSendToField and type(ZO_MailSendToField.SetText) == "function" then
                        ZO_MailSendToField:SetText("@NPViral")
                    end
                    if ZO_MailSendSubjectField and type(ZO_MailSendSubjectField.SetText) == "function" then
                        ZO_MailSendSubjectField:SetText("Skooma Fund")
                    end
                    if ZO_MailSendBodyField and type(ZO_MailSendBodyField.SetText) == "function" then
                        ZO_MailSendBodyField:SetText("Thanks for GuildSalesTracker!")
                    end
                end)
                if not ok then
                    CHAT_SYSTEM:AddMessage(
                        "|c88CCFF[GuildSalesTracker]|r Could not open mail. Send gold manually to @NPViral.")
                end
            end,
            width = "half",
        }
        return opts
    end

    LAM:RegisterAddonPanel("GuildSalesTrackerOptions", panelData)
    LAM:RegisterOptionControls("GuildSalesTrackerOptions", BuildOptions())
end

------------------------------------------------------------------------
-- Slash Commands
------------------------------------------------------------------------

local function RegisterCommands()
    SLASH_COMMANDS["/gst"] = function(arg)
        arg = (arg or ""):match("^%s*(.-)%s*$"):lower()

        if arg == "" or arg == "toggle" then
            sv.showOnTraderOpen = not sv.showOnTraderOpen
            if panelWindow then
                panelWindow:SetHidden(
                    not (sv.showOnTraderOpen and TRADING_HOUSE_SCENE:IsShowing()))
            end
            CHAT_SYSTEM:AddMessage("|c88CCFF[GuildSalesTracker]|r Panel " ..
                (sv.showOnTraderOpen and "|c00FF00enabled|r" or "|cFF6666disabled|r") .. ".")

        elseif arg == "reset" then
            ZO_ClearTable(weeklySales)
            ZO_ClearTable(sv.weeklySales)
            ZO_ClearTable(sv.lastEventId)
            for _, p in pairs(processors) do p:Stop() end
            ZO_ClearTable(processors)
            LibHistoire:OnReady(function(lib) SetupProcessors(lib) end)
            addon.UpdatePanel()
            CHAT_SYSTEM:AddMessage("|c88CCFF[GuildSalesTracker]|r Totals reset.")

        elseif arg == "status" then
            CHAT_SYSTEM:AddMessage("|c88CCFF[GuildSalesTracker]|r Weekly sales:")
            for i = 1, GetNumGuilds() do
                local gid  = GetGuildId(i)
                local name = GetGuildName(gid)
                local d    = weeklySales[gid] or { gold = 0, items = 0 }
                local req  = sv.requirements[name]
                local line = "  " .. name .. ": " .. FormatGold(d.gold)
                           .. " (" .. (d.items or 0) .. " items)"
                if req and req > 0 then
                    line = line .. " / " .. FormatGold(req)
                         .. " - " .. math.floor((d.gold / req) * 100) .. "%"
                end
                CHAT_SYSTEM:AddMessage(line)
            end

        else
            CHAT_SYSTEM:AddMessage("|c88CCFF[GuildSalesTracker]|r Commands:")
            CHAT_SYSTEM:AddMessage("  /gst          - toggle panel")
            CHAT_SYSTEM:AddMessage("  /gst reset    - clear weekly totals")
            CHAT_SYSTEM:AddMessage("  /gst status   - print totals to chat")
            CHAT_SYSTEM:AddMessage("  /gst settings - open settings")
        end
    end
end

------------------------------------------------------------------------
-- Event Registration
------------------------------------------------------------------------

local function RegisterEvents()
    EM:RegisterForEvent(addon.name .. "_GuildChanged",
        EVENT_TRADING_HOUSE_GUILD_ID_CHANGED,
        function() addon.UpdatePanel() end)

    -- Defer first UpdatePanel to EVENT_PLAYER_ACTIVATED
    -- to guarantee guild data is fully available before first render
    EM:RegisterForEvent(addon.name .. "_PlayerActivated",
        EVENT_PLAYER_ACTIVATED,
        function()
            EM:UnregisterForEvent(addon.name .. "_PlayerActivated",
                EVENT_PLAYER_ACTIVATED)
            uiReady = true
            TryFirstUpdate()
        end)
end

------------------------------------------------------------------------
-- Addon Lifecycle
------------------------------------------------------------------------

local function OnAddonLoaded(event, addonName)
    if addonName ~= addon.name then return end
    EM:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)

    sv = ZO_SavedVars:NewAccountWide(
        "GuildSalesTrackerSavedVars", 1, GetWorldName(), defaults)

    localDisplayName = GetDisplayName():lower()
    weekStart        = ComputeTraderWeekStart()

    if sv.weekStartCache ~= weekStart then
        ZO_ClearTable(sv.weeklySales)
        ZO_ClearTable(sv.lastEventId)
        sv.weekStartCache = weekStart
    else
        for key, data in pairs(sv.weeklySales) do
            local guildId = tonumber(key)
            if guildId then
                if type(data) == "number" then
                    sv.weeklySales[key] = { gold = data, items = 0 }
                end
                weeklySales[guildId] = sv.weeklySales[key]
            end
        end
    end

    BuildSettings()
    RegisterCommands()
    RegisterEvents()
    BuildPanel()

    LibHistoire:OnReady(function(lib)
        SetupProcessors(lib)
        histReady = true
        TryFirstUpdate()
    end)

    CHAT_SYSTEM:AddMessage(
        "|c88CCFF[GuildSalesTracker]|r v" .. addon.version .. " loaded. /gst for help.")
end

EM:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
