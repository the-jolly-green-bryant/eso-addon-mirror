-- ====================
-- PlayTime by hamgatan
-- This Addon is Distributed under a MIT Licence
-- Please See Licence File for further Information
-- Concept adapted from the 'PlayedAll' Addon by Bombo / rockstarrem 
-- but completely reworked from the ground up as a new Addon
-- ====================

PlayTime = {}
PlayTime.name = "PlayTime"
PlayTime.version = "1.0.1"

local savedVariables
local window, scrollList, totalLabel

local currentSort = "name"
local sortAscending = true

-- =============================
-- SAVE DATA FROM LOGGED IN CHAR
-- =============================
local function SaveCurrentCharacterTime()
    if not savedVariables or not savedVariables.data then return end

    local name = GetUnitName("player")
    savedVariables.data[name] = GetSecondsPlayed()
end

-- ====================================
-- FUNCTION - EXPORT TOTAL TIME TO CHAT 
-- ====================================
function PlayTime.ExportTotalToChat()

    local total = 0

    for _, t in pairs(savedVariables.data or {}) do
        total = total + t
    end

    local formatted = ZO_FormatTime(
        total,
        TIME_FORMAT_STYLE_DESCRIPTIVE,
        TIME_FORMAT_PRECISION_SECONDS
    )

    local text = string.format(
        "|c00FF00[PlayTime]|r Accountwide Played Time: %s",
        formatted
    )

    if CHAT_SYSTEM and CHAT_SYSTEM.textEntry then
        CHAT_SYSTEM.textEntry:SetText(text)
        CHAT_SYSTEM.textEntry:Open()
    end
end

-- =====================
-- SORT ENTRIES IN TABLE
-- =====================
local function SortEntries(entries, total)
    table.sort(entries, function(a, b)

        local av, bv

        if currentSort == "name" then
            av, bv = a.name, b.name
        elseif currentSort == "time" then
            av, bv = a.time, b.time
        else
            av, bv = (a.time / total), (b.time / total)
        end

        if sortAscending then
            return av < bv
        else
            return av > bv
        end
    end)
end

-- ========================
-- CREATE MAIN ADDON WINDOW
-- ========================
local function CreateWindow()

    local WIDTH = 936
    local HEIGHT = 560

    local COL1 = WIDTH * 0.29
    local COL2 = WIDTH * 0.55
    local COL3 = WIDTH * 0.1875

    local X1 = 10
    local X2 = X1 + COL1
    local X3 = X2 + COL2

    window = WINDOW_MANAGER:CreateTopLevelWindow("PlayTimeWindow")
    window:SetDimensions(WIDTH, HEIGHT)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetHidden(true)
    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetClampedToScreen(true)

    WINDOW_MANAGER:CreateControlFromVirtual(nil, window, "ZO_DefaultBackdrop"):SetAnchorFill()

    -- ====================
    -- SET WINDOW TITLE BAR
    -- ====================
    local title = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    title:SetFont("ZoFontWinH1")
    title:SetText("|cFFD700PlayTime Log|r")
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 10, 10)

    local credit = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    credit:SetFont("ZoFontGameBold")
    credit:SetText("|c66FF99by @hamgatan|r")
    credit:SetAnchor(LEFT, title, RIGHT, 20, 0)

    -- ==================
    -- SET COLUMN HEADERS
    -- ==================
    local header = WINDOW_MANAGER:CreateControl(nil, window, CT_CONTROL)
    header:SetAnchor(TOP, window, TOP, 0, 70)
    header:SetDimensions(WIDTH, 30)

    local function MakeHeader(text, x, w)

        local h = WINDOW_MANAGER:CreateControl(nil, header, CT_LABEL)
        h:SetFont("ZoFontGameBold")
        h:SetText("|cFF8800" .. text .. "|r")
        h:SetDimensions(w, 30)
        h:SetMouseEnabled(true)

        h:SetAnchor(LEFT, header, LEFT, x, 0)

        h:SetHandler("OnMouseUp", function()
            if currentSort == text then
                sortAscending = not sortAscending
            else
                currentSort = text
                sortAscending = true
            end
            PlayTime.Populate()
        end)
    end

    MakeHeader("Character Name", X1, COL1)
    MakeHeader("Played Time", X2, COL2)
    MakeHeader("% Total", X3, COL3)

    -- =========================
    -- SCROLL LIST FOR CHAR DATA
    -- =========================
    scrollList = WINDOW_MANAGER:CreateControlFromVirtual("PlayTimeList", window, "ZO_ScrollList")
    scrollList:SetAnchor(TOP, header, BOTTOM, 0, 10)
    scrollList:SetDimensions(WIDTH - 20, 400)

    ZO_ScrollList_AddDataType(scrollList, 1, "ZO_SelectableLabel", 22,
    function(control, data)

        control:SetHeight(22)

        if not control.bg then
            control.bg = WINDOW_MANAGER:CreateControl(nil, control, CT_BACKDROP)
            control.bg:SetAnchorFill()
            control.bg:SetCenterColor(0, 0, 0, 0)
            control.bg:SetEdgeColor(0, 0, 0, 0)
        end

        if not control.nameLabel then

            control.nameLabel = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
            control.nameLabel:SetFont("ZoFontGameBold")
            control.nameLabel:SetAnchor(LEFT, control, LEFT, X1, 0)
            control.nameLabel:SetDimensions(COL1, 22)

            control.timeLabel = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
            control.timeLabel:SetFont("ZoFontGame")
            control.timeLabel:SetAnchor(LEFT, control, LEFT, X2, 0)
            control.timeLabel:SetDimensions(COL2, 22)

            control.percentLabel = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
            control.percentLabel:SetFont("ZoFontGame")
            control.percentLabel:SetAnchor(LEFT, control, LEFT, X3, 0)
            control.percentLabel:SetDimensions(COL3, 22)
        end

        local player = GetUnitName("player")

        if data.name == player then
            control.nameLabel:SetText("|c00FF00" .. data.name .. "|r")
        else
            control.nameLabel:SetText(data.name or "")
        end

        control.timeLabel:SetText(data.timeText or "")
        control.percentLabel:SetText(data.percentText or "")

        local i = data.index or 0
        if i % 2 == 0 then
            control.bg:SetCenterColor(0, 0, 0, 0.10)
        else
            control.bg:SetCenterColor(0, 0, 0, 0.05)
        end

        if data.name == player then
            control.bg:SetCenterColor(0.10, 0.35, 0.10, 0.25)
        end
    end)

    -- =================
    -- SET WINDOW FOOTER
    -- =================
    local footer = WINDOW_MANAGER:CreateControl(nil, window, CT_CONTROL)
    footer:SetDimensions(WIDTH - 20, 40)
    footer:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 10, -10)

    local footerBg = WINDOW_MANAGER:CreateControl(nil, footer, CT_BACKDROP)
    footerBg:SetAnchorFill()
    footerBg:SetCenterColor(0, 0, 0, 0.25)
    footerBg:SetEdgeColor(0, 0, 0, 0.4)

    -- ==================
    -- DRAW EXPORT BUTTON
    -- ==================
    local exportBtn = WINDOW_MANAGER:CreateControl(nil, footer, CT_BUTTON)
    exportBtn:SetDimensions(220, 34)
    exportBtn:SetAnchor(LEFT, footer, LEFT, 0, 0)

    local bg = WINDOW_MANAGER:CreateControl(nil, exportBtn, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.08, 0.08, 0.08, 0.85)
    bg:SetEdgeColor(0.7, 0.6, 0.2, 1)

    local label = WINDOW_MANAGER:CreateControl(nil, exportBtn, CT_LABEL)
    label:SetFont("ZoFontGameBold")
    label:SetText("|cFFD700Export Total to Chat|r")
    label:SetAnchor(CENTER, exportBtn, CENTER, 0, 0)

    exportBtn:SetHandler("OnMouseUp", function()
        PlayTime.ExportTotalToChat()
    end)

    -- =================
    -- DRAW CLOSE BUTTON
    -- =================
    local closeBtn = WINDOW_MANAGER:CreateControl(nil, footer, CT_BUTTON)
    closeBtn:SetDimensions(34, 34)
    closeBtn:SetAnchor(RIGHT, footer, RIGHT, 0, 0)

    local closeBg = WINDOW_MANAGER:CreateControl(nil, closeBtn, CT_BACKDROP)
    closeBg:SetAnchorFill()
    closeBg:SetCenterColor(0.08, 0.08, 0.08, 0.85)
    closeBg:SetEdgeColor(0.7, 0.6, 0.2, 1)

    local closeLabel = WINDOW_MANAGER:CreateControl(nil, closeBtn, CT_LABEL)
    closeLabel:SetFont("ZoFontGameBold")
    closeLabel:SetText("|cFF4444X|r")
    closeLabel:SetAnchor(CENTER, closeBtn, CENTER, 0, 0)

    closeBtn:SetHandler("OnMouseUp", function()
        window:SetHidden(true)
    end)

    -- ===========
    -- TOTAL LABEL
    -- ===========
    totalLabel = WINDOW_MANAGER:CreateControl(nil, footer, CT_LABEL)
    totalLabel:SetFont("ZoFontWinH2")
    totalLabel:SetAnchor(LEFT, footer, LEFT, X2, 0)
    totalLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
end

-- ====================
-- POPULATE DATA FIELDS
-- ====================
function PlayTime.Populate()

    ZO_ScrollList_Clear(scrollList)
    local dataList = ZO_ScrollList_GetDataList(scrollList)

    local entries = {}
    local total = 0
    local i = 0

    for _, t in pairs(savedVariables.data or {}) do
        total = total + t
    end

    for name, time in pairs(savedVariables.data or {}) do
        i = i + 1

        table.insert(entries, {
            index = i,
            name = name,
            time = time,
            timeText = ZO_FormatTime(time, TIME_FORMAT_STYLE_DESCRIPTIVE, TIME_FORMAT_PRECISION_SECONDS),
            percentText = string.format("%.1f%%", (total > 0 and (time / total * 100) or 0))
        })
    end

    SortEntries(entries, total)

    for _, e in ipairs(entries) do
        table.insert(dataList, ZO_ScrollList_CreateDataEntry(1, e))
    end

    ZO_ScrollList_Commit(scrollList)

    totalLabel:SetText("|c00FF00TOTAL: " ..
        ZO_FormatTime(total, TIME_FORMAT_STYLE_DESCRIPTIVE, TIME_FORMAT_PRECISION_SECONDS) ..
        "|r")
end

-- =============
-- TOGGLE WINDOW
-- =============
function PlayTime.Toggle()
    if window:IsHidden() then
        PlayTime.Populate()
        window:SetHidden(false)
    else
        window:SetHidden(true)
    end
end

ZO_CreateStringId("SI_BINDING_NAME_PLAYTIME_TOGGLE", "Toggle PlayTime Log")

-- ==================
-- INIT MAIN FUNCTION
-- ==================
local function OnAddonLoaded(_, addonName)
    if addonName ~= "PlayTime" then return end

    savedVariables = ZO_SavedVars:NewAccountWide("PlayTimeVars", 1, nil, {
        data = {}
    })

    CreateWindow()

    EVENT_MANAGER:RegisterForEvent("PlayTime", EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(function()
            SaveCurrentCharacterTime()
        end, 500)
    end)

    SLASH_COMMANDS["/playtime"] = function()
        PlayTime.Toggle()
    end

    EVENT_MANAGER:UnregisterForEvent("PlayTime", EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent("PlayTime", EVENT_ADD_ON_LOADED, OnAddonLoaded)