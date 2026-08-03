local PvPerformance = PvPerformance
local Analytics = PvPerformance.Modules.Analytics
local Dueling = PvPerformance.Modules.Dueling
local CreateLabel = PvPerformance.UI.CreateLabel
local FormatCombatNumber = PvPerformance.Utilities.FormatCombatNumber
local FormatDuration = PvPerformance.Utilities.FormatDuration

local BLUE = { 0.44, 0.78, 1, 1 }
local MUTED = { 0.70, 0.77, 0.85, 1 }
local WHITE = { 0.88, 0.90, 0.94, 1 }
local DAMAGE = { 1.00, 0.50, 0.46, 1 }
local HEALING = { 0.44, 0.94, 0.58, 1 }
local YELLOW = { 1.00, 0.84, 0.24, 1 }
local ROW_HEIGHT = 28
local VISIBLE_SOURCE_ROWS = 10
local VISIBLE_LOG_ROWS = 15
local VISIBLE_UPTIME_ROWS = 17
local VISIBLE_EMBEDDED_LOG_ROWS = 11
local VISIBLE_EMBEDDED_UPTIME_ROWS = 11
local CONTENT_TOP = 112
local SOURCE_SUMMARY_WIDTH = 400
local EMBEDDED_PANEL_HEIGHT = 440
local EMBEDDED_ROWS_TOP = 140
local SOURCE_HEADER_TOP = 40
local SOURCE_RULE_TOP = 64
local SOURCE_ROWS_TOP = 70
local SOURCE_VALUE_WIDTH = 84
local SOURCE_VALUE_GAP = 4
local SOURCE_RIGHT_PADDING = 22
local SOURCE_COLUMN_KEYS = { "max", "average", "min", "critPercent", "critHits", "total", "rate", "percent" }
local STAT_VALUE_WIDTH = 116
local STAT_VALUE_GAP = 28
local UPTIME_PANEL_WIDTH = 560

local function SetColor(control, color)
    control:SetColor(color[1], color[2], color[3], color[4])
end

local function FormatRate(total, duration)
    duration = tonumber(duration) or 0
    if duration <= 0 then
        return "N/A"
    end
    return FormatCombatNumber((tonumber(total) or 0) / duration)
end

local function AbilityIcon(abilityId)
    if abilityId and type(GetAbilityIcon) == "function" then
        local icon = GetAbilityIcon(abilityId)
        return icon and icon ~= "" and icon or nil
    end
end

local function Truncate(text, limit)
    text = tostring(text or "")
    if #text <= limit then
        return text
    end
    return text:sub(1, math.max(1, limit - 3)) .. "..."
end

local function CreatePanel(parent)
    local panel = WINDOW_MANAGER:CreateControl(nil, parent, CT_BACKDROP)
    panel:SetCenterColor(0.015, 0.020, 0.030, 1)
    panel:SetEdgeColor(0.22, 0.34, 0.48, 1)
    return panel
end

local function CreateClickableLabel(parent, text, width, onClick)
    local label = CreateLabel(parent, "ZoFontGameBold", MUTED[1], MUTED[2], MUTED[3])
    label:SetDimensions(width, 30)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetText(text)
    label.tabBorder = WINDOW_MANAGER:CreateControl(nil, label, CT_BACKDROP)
    label.tabBorder:SetAnchorFill(label)
    label.tabBorder:SetCenterColor(0, 0, 0, 0)
    label.tabBorder:SetEdgeColor(0.48, 0.52, 0.58, 1)
    label.tabBorder:SetDrawLayer(DL_BACKGROUND)
    label:SetMouseEnabled(true)
    label:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            onClick()
        end
    end)
    return label
end

local function SetTabSelected(label, selected)
    if not label then
        return
    end
    SetColor(label, selected and BLUE or MUTED)
    if label.tabBorder then
        label.tabBorder:SetCenterColor(
            selected and BLUE[1] or 0,
            selected and BLUE[2] or 0,
            selected and BLUE[3] or 0,
            selected and 0.18 or 0
        )
        label.tabBorder:SetEdgeColor(
            selected and BLUE[1] or 0.48,
            selected and BLUE[2] or 0.52,
            selected and BLUE[3] or 0.58,
            1
        )
    end
end

local function CreateActionButton(parent, text, onClick)
    local button = CreatePanel(parent)
    button:SetDimensions(140, 50)
    button:SetMouseEnabled(true)
    button.label = CreateLabel(button, "ZoFontGameBold", MUTED[1], MUTED[2], MUTED[3])
    button.label:SetAnchorFill(button)
    button.label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    button.label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    button.label:SetText(text)
    button.clickTarget = WINDOW_MANAGER:CreateControl(nil, button, CT_CONTROL)
    button.clickTarget:SetAnchorFill(button)
    button.clickTarget:SetMouseEnabled(true)
    button.clickTarget:SetHandler("OnMouseEnter", function()
        button:SetEdgeColor(BLUE[1], BLUE[2], BLUE[3], 1)
        SetColor(button.label, BLUE)
    end)
    button.clickTarget:SetHandler("OnMouseExit", function()
        button:SetEdgeColor(0.22, 0.34, 0.48, 1)
        SetColor(button.label, MUTED)
    end)
    button.clickTarget:SetHandler("OnMouseUp", function(_, mouseButton, upInside)
        if mouseButton == MOUSE_BUTTON_INDEX_LEFT and upInside ~= false then
            onClick()
        end
    end)
    return button
end

local function CreateSourceRow(parent, index)
    local row = WINDOW_MANAGER:CreateControl(nil, parent, CT_CONTROL)
    row:SetAnchor(TOPLEFT, parent, TOPLEFT, 10, SOURCE_ROWS_TOP + (index - 1) * ROW_HEIGHT)
    row:SetAnchor(TOPRIGHT, parent, TOPRIGHT, -10, SOURCE_ROWS_TOP + (index - 1) * ROW_HEIGHT)
    row:SetHeight(ROW_HEIGHT)
    row:SetMouseEnabled(true)
    row.highlight = WINDOW_MANAGER:CreateControl(nil, row, CT_BACKDROP)
    row.highlight:SetAnchorFill(row)
    row.highlight:SetCenterColor(0.12, 0.30, 0.46, 0.30)
    row.highlight:SetEdgeColor(0, 0, 0, 0)
    row.highlight:SetHidden(true)

    row.icon = WINDOW_MANAGER:CreateControl(nil, row, CT_TEXTURE)
    row.icon:SetAnchor(LEFT, row, LEFT, 0, 0)
    row.icon:SetDimensions(22, 22)

    row.name = CreateLabel(row, "ZoFontGame", WHITE[1], WHITE[2], WHITE[3])
    row.name:SetAnchor(LEFT, row.icon, RIGHT, 7, 0)
    row.name:SetDimensions(265, 26)
    row.name:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    row.name:SetScale(0.92)

    for columnIndex, key in ipairs(SOURCE_COLUMN_KEYS) do
        local label = CreateLabel(row, "ZoFontGame", WHITE[1], WHITE[2], WHITE[3])
        label:SetAnchor(
            RIGHT,
            row,
            RIGHT,
            -(SOURCE_RIGHT_PADDING + (columnIndex - 1) * (SOURCE_VALUE_WIDTH + SOURCE_VALUE_GAP)),
            0
        )
        label:SetDimensions(SOURCE_VALUE_WIDTH, 26)
        label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        label:SetScale(0.92)
        row[key] = label
    end
    row:SetHandler("OnMouseEnter", function()
        if row.source then
            row.highlight:SetHidden(false)
        end
    end)
    row:SetHandler("OnMouseExit", function()
        row.highlight:SetHidden(not row.selected)
    end)
    row:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and row.source then
            Analytics:SelectSkillForCombatLog(Analytics.activeTab, row.source)
        end
    end)
    return row
end

local function CreateEmbeddedLogRow(parent, index)
    local row = WINDOW_MANAGER:CreateControl(nil, parent, CT_CONTROL)
    row:SetAnchor(TOPLEFT, parent, TOPLEFT, 10, EMBEDDED_ROWS_TOP + (index - 1) * 26)
    row:SetAnchor(TOPRIGHT, parent, TOPRIGHT, -18, EMBEDDED_ROWS_TOP + (index - 1) * 26)
    row:SetHeight(26)
    local definitions = {
        { key = "time", x = 0, width = 78 },
        { key = "icon", x = 84, texture = true, width = 20 },
        { key = "ability", x = 110, width = 225 },
        { key = "source", x = 342, width = 160 },
        { key = "target", x = 510, width = 160 },
    }
    for _, definition in ipairs(definitions) do
        if definition.texture then
            row[definition.key] = WINDOW_MANAGER:CreateControl(nil, row, CT_TEXTURE)
            row[definition.key]:SetAnchor(LEFT, row, LEFT, definition.x, 0)
            row[definition.key]:SetDimensions(20, 20)
        else
            local label = CreateLabel(row, "ZoFontGame", WHITE[1], WHITE[2], WHITE[3])
            label:SetAnchor(LEFT, row, LEFT, definition.x, 0)
            label:SetDimensions(definition.width, 24)
            label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            label:SetScale(0.92)
            row[definition.key] = label
        end
    end
    row.amount = CreateLabel(row, "ZoFontGame", WHITE[1], WHITE[2], WHITE[3])
    row.amount:SetAnchor(RIGHT, row, RIGHT, 0, 0)
    row.amount:SetDimensions(170, 24)
    row.amount:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    row.amount:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    row.amount:SetScale(0.92)
    row.message = CreateLabel(row, "ZoFontGame", WHITE[1], WHITE[2], WHITE[3])
    row.message:SetAnchor(LEFT, row, LEFT, 84, 0)
    row.message:SetAnchor(RIGHT, row, RIGHT, 0, 0)
    row.message:SetHeight(24)
    row.message:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    row.message:SetScale(0.92)
    row.message:SetHidden(true)
    return row
end

local function CreateEmbeddedUptimeRow(parent, index)
    local row = WINDOW_MANAGER:CreateControl(nil, parent, CT_CONTROL)
    row:SetAnchor(TOPLEFT, parent, TOPLEFT, 10, EMBEDDED_ROWS_TOP + (index - 1) * 26)
    row:SetAnchor(TOPRIGHT, parent, TOPRIGHT, -18, EMBEDDED_ROWS_TOP + (index - 1) * 26)
    row:SetHeight(26)
    row.icon = WINDOW_MANAGER:CreateControl(nil, row, CT_TEXTURE)
    row.icon:SetAnchor(LEFT, row, LEFT, 0, 0)
    row.icon:SetDimensions(20, 20)
    row.effect = CreateLabel(row, "ZoFontGame", WHITE[1], WHITE[2], WHITE[3])
    row.effect:SetAnchor(LEFT, row.icon, RIGHT, 6, 0)
    row.effect:SetAnchor(RIGHT, row, RIGHT, -164, 0)
    row.effect:SetHeight(24)
    row.effect:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    row.effect:SetScale(0.92)
    row.uptime = CreateLabel(row, "ZoFontGame", WHITE[1], WHITE[2], WHITE[3])
    row.applications = CreateLabel(row, "ZoFontGame", WHITE[1], WHITE[2], WHITE[3])
    row.applications:SetAnchor(RIGHT, row, RIGHT, -82, 0)
    row.applications:SetDimensions(72, 24)
    row.applications:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    row.applications:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    row.applications:SetScale(0.92)
    row.uptime:SetAnchor(RIGHT, row, RIGHT, 0, 0)
    row.uptime:SetDimensions(72, 24)
    row.uptime:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    row.uptime:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    row.uptime:SetScale(0.92)
    return row
end

local function CreateScrollIndicator(parent, top, bottom)
    local track = WINDOW_MANAGER:CreateControl(nil, parent, CT_BACKDROP)
    track:SetAnchor(TOPRIGHT, parent, TOPRIGHT, -7, top)
    track:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, -7, bottom)
    track:SetWidth(4)
    track:SetCenterColor(0.08, 0.13, 0.20, 0.90)
    track:SetEdgeColor(0, 0, 0, 0)
    local thumb = WINDOW_MANAGER:CreateControl(nil, track, CT_BACKDROP)
    thumb:SetAnchor(TOP, track, TOP, 0, 0)
    thumb:SetDimensions(4, 28)
    thumb:SetCenterColor(BLUE[1], BLUE[2], BLUE[3], 0.90)
    thumb:SetEdgeColor(0, 0, 0, 0)
    return track, thumb
end

local EMBEDDED_EFFECT_FILTERS = {
    { key = "all", label = "ALL" },
    { key = "incomingBuff", label = "INCOMING BUFF" },
    { key = "outgoingBuff", label = "OUTGOING BUFF" },
    { key = "incomingDebuff", label = "INCOMING DEBUFF" },
    { key = "outgoingDebuff", label = "OUTGOING DEBUFF" },
}

local function CreateSourceTable(parent)
    local board = CreatePanel(parent)
    board:SetAnchor(TOPLEFT, parent, TOPLEFT, 20, CONTENT_TOP)
    board:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, -20, -18)
    board:SetCenterColor(0, 0, 0, 0)
    board:SetEdgeColor(0, 0, 0, 0)
    board:SetMouseEnabled(false)

    -- Four synchronized panes: evidence timeline, effect uptime, compact
    -- target/totals, and the full clickable source table.
    board.logPanel = CreatePanel(board)
    board.logPanel:SetAnchor(TOPLEFT, board, TOPLEFT, 0, 0)
    board.logPanel:SetAnchor(TOPRIGHT, board, TOPRIGHT, -(UPTIME_PANEL_WIDTH + 10), 0)
    board.logPanel:SetHeight(EMBEDDED_PANEL_HEIGHT)
    board.logPanel:SetMouseEnabled(true)
    board.logTitle = CreateLabel(board.logPanel, "ZoFontWinH2", BLUE[1], BLUE[2], BLUE[3])
    board.logTitle:SetAnchor(TOPLEFT, board.logPanel, TOPLEFT, 10, 8)
    board.logTitle:SetAnchor(TOPRIGHT, board.logPanel, TOPRIGHT, -94, 8)
    board.logTitle:SetHeight(24)
    board.logTitle:SetText("COMBAT LOG - ALL")
    board.logTitle:SetScale(0.82)
    board.logClear = CreateClickableLabel(board.logPanel, "CLEAR", 72, function()
        Analytics:ClearSkillFilter(true)
    end)
    board.logClear:SetAnchor(TOPRIGHT, board.logPanel, TOPRIGHT, -10, 5)
    board.logClear:SetScale(0.88)
    board.logFilters = {}
    for index, definition in ipairs(Analytics.LOG_FILTER_DEFINITIONS) do
        local key = definition.key
        local filter = CreateClickableLabel(board.logPanel, definition.label, 170, function()
            Analytics:ToggleLogFilter(key)
        end)
        local column = (index - 1) % 7
        local line = math.floor((index - 1) / 7)
        filter:SetAnchor(TOPLEFT, board.logPanel, TOPLEFT, 10 + column * 176, 34 + line * 30)
        filter:SetScale(1.00)
        board.logFilters[key] = filter
    end
    local logHeaders = {
        { text = "TIME", x = 10, width = 70 },
        { text = "ABILITY", x = 110, width = 225 },
        { text = "SOURCE", x = 342, width = 160 },
        { text = "TARGET", x = 510, width = 160 },
    }
    for _, definition in ipairs(logHeaders) do
        local header = CreateLabel(board.logPanel, "ZoFontGameBold", MUTED[1], MUTED[2], MUTED[3])
        header:SetAnchor(TOPLEFT, board.logPanel, TOPLEFT, definition.x, 108)
        header:SetDimensions(definition.width, 18)
        header:SetScale(0.92)
        header:SetText(definition.text)
    end
    board.logValueHeader = CreateLabel(board.logPanel, "ZoFontGameBold", MUTED[1], MUTED[2], MUTED[3])
    board.logValueHeader:SetAnchor(TOPRIGHT, board.logPanel, TOPRIGHT, -18, 108)
    board.logValueHeader:SetDimensions(166, 18)
    board.logValueHeader:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    board.logValueHeader:SetScale(0.92)
    board.logValueHeader:SetText("VALUE")
    board.logFilterRule = WINDOW_MANAGER:CreateControl(nil, board.logPanel, CT_BACKDROP)
    board.logFilterRule:SetAnchor(TOPLEFT, board.logPanel, TOPLEFT, 10, 98)
    board.logFilterRule:SetAnchor(TOPRIGHT, board.logPanel, TOPRIGHT, -16, 98)
    board.logFilterRule:SetHeight(1)
    board.logFilterRule:SetCenterColor(0.22, 0.34, 0.48, 1)
    board.logFilterRule:SetEdgeColor(0, 0, 0, 0)
    board.logRule = WINDOW_MANAGER:CreateControl(nil, board.logPanel, CT_BACKDROP)
    board.logRule:SetAnchor(TOPLEFT, board.logPanel, TOPLEFT, 10, 134)
    board.logRule:SetAnchor(TOPRIGHT, board.logPanel, TOPRIGHT, -16, 134)
    board.logRule:SetHeight(1)
    board.logRule:SetCenterColor(0.22, 0.34, 0.48, 1)
    board.logRule:SetEdgeColor(0, 0, 0, 0)
    board.logRows = {}
    for index = 1, VISIBLE_EMBEDDED_LOG_ROWS do
        table.insert(board.logRows, CreateEmbeddedLogRow(board.logPanel, index))
    end
    board.logEmpty = CreateLabel(board.logPanel, "ZoFontGame", MUTED[1], MUTED[2], MUTED[3])
    board.logEmpty:SetAnchor(TOP, board.logPanel, TOP, 0, 216)
    board.logEmpty:SetDimensions(430, 28)
    board.logEmpty:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    board.logEmpty:SetText("No timestamps recorded for this category")
    board.logTrack, board.logThumb = CreateScrollIndicator(board.logPanel, EMBEDDED_ROWS_TOP, -10)
    board.logOffset = 0
    board.logPanel:SetHandler("OnMouseWheel", function(_, delta)
        board.logOffset = math.max(0, (board.logOffset or 0) - delta)
        Analytics.embeddedLogOffset = board.logOffset
        Analytics:RefreshSourceTable()
    end)

    board.uptimePanel = CreatePanel(board)
    board.uptimePanel:SetAnchor(TOPLEFT, board.logPanel, TOPRIGHT, 10, 0)
    board.uptimePanel:SetAnchor(TOPRIGHT, board, TOPRIGHT, 0, 0)
    board.uptimePanel:SetHeight(EMBEDDED_PANEL_HEIGHT)
    board.uptimePanel:SetMouseEnabled(true)
    board.uptimeTitle = CreateLabel(board.uptimePanel, "ZoFontWinH2", BLUE[1], BLUE[2], BLUE[3])
    board.uptimeTitle:SetAnchor(TOPLEFT, board.uptimePanel, TOPLEFT, 10, 8)
    board.uptimeTitle:SetAnchor(TOPRIGHT, board.uptimePanel, TOPRIGHT, -10, 8)
    board.uptimeTitle:SetHeight(24)
    board.uptimeTitle:SetText("BUFF / DEBUFF UPTIME")
    board.uptimeTitle:SetScale(0.82)
    board.uptimeFilters = {}
    for index, definition in ipairs(EMBEDDED_EFFECT_FILTERS) do
        local key = definition.key
        local filter = CreateClickableLabel(board.uptimePanel, definition.label, 174, function()
            Analytics:SetUptimeFilter(key)
        end)
        local column = (index - 1) % 3
        local line = math.floor((index - 1) / 3)
        filter:SetAnchor(TOPLEFT, board.uptimePanel, TOPLEFT, 8 + column * 180, 34 + line * 30)
        filter:SetScale(1.00)
        board.uptimeFilters[key] = filter
    end
    board.uptimeEffectHeader = CreateLabel(board.uptimePanel, "ZoFontGameBold", MUTED[1], MUTED[2], MUTED[3])
    board.uptimeEffectHeader:SetAnchor(TOPLEFT, board.uptimePanel, TOPLEFT, 36, 108)
    board.uptimeEffectHeader:SetDimensions(180, 18)
    board.uptimeEffectHeader:SetScale(0.92)
    board.uptimeEffectHeader:SetText("EFFECT")
    board.uptimeValueHeader = CreateLabel(board.uptimePanel, "ZoFontGameBold", MUTED[1], MUTED[2], MUTED[3])
    board.uptimeApplicationsHeader = CreateLabel(board.uptimePanel, "ZoFontGameBold", MUTED[1], MUTED[2], MUTED[3])
    board.uptimeApplicationsHeader:SetAnchor(TOPRIGHT, board.uptimePanel, TOPRIGHT, -90, 108)
    board.uptimeApplicationsHeader:SetDimensions(72, 18)
    board.uptimeApplicationsHeader:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    board.uptimeApplicationsHeader:SetScale(0.88)
    board.uptimeApplicationsHeader:SetText("# OF APPS")
    board.uptimeValueHeader:SetAnchor(TOPRIGHT, board.uptimePanel, TOPRIGHT, -18, 108)
    board.uptimeValueHeader:SetDimensions(66, 18)
    board.uptimeValueHeader:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    board.uptimeValueHeader:SetScale(0.88)
    board.uptimeValueHeader:SetText("UPTIME")
    board.uptimeFilterRule = WINDOW_MANAGER:CreateControl(nil, board.uptimePanel, CT_BACKDROP)
    board.uptimeFilterRule:SetAnchor(TOPLEFT, board.uptimePanel, TOPLEFT, 10, 98)
    board.uptimeFilterRule:SetAnchor(TOPRIGHT, board.uptimePanel, TOPRIGHT, -16, 98)
    board.uptimeFilterRule:SetHeight(1)
    board.uptimeFilterRule:SetCenterColor(0.22, 0.34, 0.48, 1)
    board.uptimeFilterRule:SetEdgeColor(0, 0, 0, 0)
    board.uptimeRule = WINDOW_MANAGER:CreateControl(nil, board.uptimePanel, CT_BACKDROP)
    board.uptimeRule:SetAnchor(TOPLEFT, board.uptimePanel, TOPLEFT, 10, 134)
    board.uptimeRule:SetAnchor(TOPRIGHT, board.uptimePanel, TOPRIGHT, -16, 134)
    board.uptimeRule:SetHeight(1)
    board.uptimeRule:SetCenterColor(0.22, 0.34, 0.48, 1)
    board.uptimeRule:SetEdgeColor(0, 0, 0, 0)
    board.uptimeRows = {}
    for index = 1, VISIBLE_EMBEDDED_UPTIME_ROWS do
        table.insert(board.uptimeRows, CreateEmbeddedUptimeRow(board.uptimePanel, index))
    end
    board.uptimeEmpty = CreateLabel(board.uptimePanel, "ZoFontGame", MUTED[1], MUTED[2], MUTED[3])
    board.uptimeEmpty:SetAnchor(TOP, board.uptimePanel, TOP, 0, 216)
    board.uptimeEmpty:SetDimensions(300, 28)
    board.uptimeEmpty:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    board.uptimeEmpty:SetScale(0.92)
    board.uptimeEmpty:SetText("No uptime data recorded")
    board.uptimeTrack, board.uptimeThumb = CreateScrollIndicator(board.uptimePanel, EMBEDDED_ROWS_TOP, -10)
    board.uptimeOffset = 0
    board.uptimePanel:SetHandler("OnMouseWheel", function(_, delta)
        board.uptimeOffset = math.max(0, (board.uptimeOffset or 0) - delta)
        Analytics.embeddedUptimeOffset = board.uptimeOffset
        Analytics:RefreshSourceTable()
    end)

    board.summaryBox = CreatePanel(board)
    board.summaryBox:SetAnchor(TOPLEFT, board.logPanel, BOTTOMLEFT, 0, 10)
    board.summaryBox:SetAnchor(BOTTOMLEFT, board, BOTTOMLEFT, 0, 0)
    board.summaryBox:SetWidth(SOURCE_SUMMARY_WIDTH)

    board.categoryTabs = {}
    for index, definition in ipairs(Analytics.SUB_TABS) do
        local key = definition.key
        local tabWidth = math.floor((SOURCE_SUMMARY_WIDTH - 34) / 2)
        local tab = CreateClickableLabel(board.summaryBox, definition.label, tabWidth, function()
            Analytics:SetActiveTab(key)
        end)
        local column = (index - 1) % 2
        local line = math.floor((index - 1) / 2)
        tab:SetAnchor(TOPLEFT, board.summaryBox, TOPLEFT, 12 + column * (tabWidth + 10), 8 + line * 34)
        tab:SetScale(1.00)
        board.categoryTabs[key] = tab
    end

    board.categoryRule = WINDOW_MANAGER:CreateControl(nil, board.summaryBox, CT_BACKDROP)
    board.categoryRule:SetAnchor(TOPLEFT, board.summaryBox, TOPLEFT, 10, 78)
    board.categoryRule:SetAnchor(TOPRIGHT, board.summaryBox, TOPRIGHT, -10, 78)
    board.categoryRule:SetHeight(1)
    board.categoryRule:SetCenterColor(0.22, 0.34, 0.48, 1)
    board.categoryRule:SetEdgeColor(0, 0, 0, 0)

    board.title = CreateLabel(board.summaryBox, "ZoFontGameBold", BLUE[1], BLUE[2], BLUE[3])
    board.title:SetAnchor(TOP, board.summaryBox, TOP, 0, 86)
    board.title:SetDimensions(SOURCE_SUMMARY_WIDTH - 20, 24)
    board.title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    board.title:SetScale(1.00)

    board.summaryTitleRule = WINDOW_MANAGER:CreateControl(nil, board.summaryBox, CT_BACKDROP)
    board.summaryTitleRule:SetAnchor(TOPLEFT, board.summaryBox, TOPLEFT, 10, 116)
    board.summaryTitleRule:SetAnchor(TOPRIGHT, board.summaryBox, TOPRIGHT, -10, 116)
    board.summaryTitleRule:SetHeight(1)
    board.summaryTitleRule:SetCenterColor(0.22, 0.34, 0.48, 1)
    board.summaryTitleRule:SetEdgeColor(0, 0, 0, 0)

    board.targetCaption = CreateLabel(board.summaryBox, "ZoFontGameBold", MUTED[1], MUTED[2], MUTED[3])
    board.targetCaption:SetAnchor(TOPLEFT, board.summaryBox, TOPLEFT, 14, 128)
    board.targetCaption:SetDimensions(SOURCE_SUMMARY_WIDTH - 28, 18)
    board.targetCaption:SetText("TARGET")
    board.targetValue = CreateLabel(board.summaryBox, "ZoFontGame", WHITE[1], WHITE[2], WHITE[3])
    board.targetValue:SetAnchor(TOPLEFT, board.summaryBox, TOPLEFT, 14, 147)
    board.targetValue:SetDimensions(SOURCE_SUMMARY_WIDTH - 28, 30)
    board.targetValue:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    board.targetDivider = WINDOW_MANAGER:CreateControl(nil, board.summaryBox, CT_BACKDROP)
    board.targetDivider:SetAnchor(TOPLEFT, board.summaryBox, TOPLEFT, 10, 178)
    board.targetDivider:SetAnchor(TOPRIGHT, board.summaryBox, TOPRIGHT, -10, 178)
    board.targetDivider:SetHeight(1)
    board.targetDivider:SetCenterColor(0.22, 0.34, 0.48, 1)
    board.targetDivider:SetEdgeColor(0, 0, 0, 0)

    board.totalCaption = CreateLabel(board.summaryBox, "ZoFontGameBold", MUTED[1], MUTED[2], MUTED[3])
    local metricWidth = math.floor((SOURCE_SUMMARY_WIDTH - 28) / 3)
    board.totalCaption:SetAnchor(TOPLEFT, board.summaryBox, TOPLEFT, 14, 192)
    board.totalCaption:SetDimensions(metricWidth, 18)
    board.totalCaption:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    board.totalCaption:SetScale(0.88)
    board.totalCaption:SetText("TOTAL")
    board.totalValue = CreateLabel(board.summaryBox, "ZoFontGameBold", BLUE[1], BLUE[2], BLUE[3])
    board.totalValue:SetAnchor(TOPLEFT, board.summaryBox, TOPLEFT, 14, 214)
    board.totalValue:SetDimensions(metricWidth, 26)
    board.totalValue:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    board.rateCaption = CreateLabel(board.summaryBox, "ZoFontGameBold", MUTED[1], MUTED[2], MUTED[3])
    board.rateCaption:SetAnchor(TOPLEFT, board.summaryBox, TOPLEFT, 14 + metricWidth, 192)
    board.rateCaption:SetDimensions(metricWidth, 18)
    board.rateCaption:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    board.rateCaption:SetScale(0.88)
    board.rateValue = CreateLabel(board.summaryBox, "ZoFontGameBold", BLUE[1], BLUE[2], BLUE[3])
    board.rateValue:SetAnchor(TOPLEFT, board.summaryBox, TOPLEFT, 14 + metricWidth, 214)
    board.rateValue:SetDimensions(metricWidth, 26)
    board.rateValue:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    board.duelRateCaption = CreateLabel(board.summaryBox, "ZoFontGameBold", MUTED[1], MUTED[2], MUTED[3])
    board.duelRateCaption:SetAnchor(TOPLEFT, board.summaryBox, TOPLEFT, 14 + metricWidth * 2, 192)
    board.duelRateCaption:SetDimensions(metricWidth, 18)
    board.duelRateCaption:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    board.duelRateCaption:SetScale(0.88)
    board.duelRateValue = CreateLabel(board.summaryBox, "ZoFontGameBold", BLUE[1], BLUE[2], BLUE[3])
    board.duelRateValue:SetAnchor(TOPLEFT, board.summaryBox, TOPLEFT, 14 + metricWidth * 2, 214)
    board.duelRateValue:SetDimensions(metricWidth, 26)
    board.duelRateValue:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    board.metricDividerOne = WINDOW_MANAGER:CreateControl(nil, board.summaryBox, CT_BACKDROP)
    board.metricDividerOne:SetAnchor(TOPLEFT, board.summaryBox, TOPLEFT, 14 + metricWidth, 190)
    board.metricDividerOne:SetDimensions(1, 54)
    board.metricDividerOne:SetCenterColor(0.22, 0.34, 0.48, 1)
    board.metricDividerOne:SetEdgeColor(0, 0, 0, 0)
    board.metricDividerTwo = WINDOW_MANAGER:CreateControl(nil, board.summaryBox, CT_BACKDROP)
    board.metricDividerTwo:SetAnchor(TOPLEFT, board.summaryBox, TOPLEFT, 14 + metricWidth * 2, 190)
    board.metricDividerTwo:SetDimensions(1, 54)
    board.metricDividerTwo:SetCenterColor(0.22, 0.34, 0.48, 1)
    board.metricDividerTwo:SetEdgeColor(0, 0, 0, 0)

    board.abilityPanel = CreatePanel(board)
    board.abilityPanel:SetAnchor(TOPLEFT, board.summaryBox, TOPRIGHT, 10, 0)
    board.abilityPanel:SetAnchor(BOTTOMRIGHT, board, BOTTOMRIGHT, 0, 0)
    board.abilityPanel:SetMouseEnabled(true)
    board.abilityTitle = CreateLabel(board.abilityPanel, "ZoFontWinH2", BLUE[1], BLUE[2], BLUE[3])
    board.abilityTitle:SetAnchor(TOPLEFT, board.abilityPanel, TOPLEFT, 10, 8)
    board.abilityTitle:SetAnchor(TOPRIGHT, board.abilityPanel, TOPRIGHT, -10, 8)
    board.abilityTitle:SetHeight(24)
    board.abilityTitle:SetText("ABILITY BREAKDOWN")
    board.abilityTitle:SetScale(0.82)

    local headers = {
        { text = "ABILITY", key = "ability" },
        { text = "MAX", key = "max", index = 1 },
        { text = "AVG", key = "average", index = 2 },
        { text = "MIN", key = "min", index = 3 },
        { text = "CRIT %", key = "critPercent", index = 4 },
        { text = "CRITS/HITS", key = "critHits", index = 5 },
        { text = "TOTAL", key = "total", index = 6 },
        { text = "DPS", key = "rate", index = 7 },
        { text = "%", key = "percent", index = 8 },
    }
    board.headers = {}
    for _, definition in ipairs(headers) do
        local header = CreateLabel(board.abilityPanel, "ZoFontGameBold", MUTED[1], MUTED[2], MUTED[3])
        header:SetDimensions(definition.key == "ability" and 265 or SOURCE_VALUE_WIDTH, 20)
        if definition.key == "ability" then
            header:SetAnchor(TOPLEFT, board.abilityPanel, TOPLEFT, 12, SOURCE_HEADER_TOP)
        else
            header:SetAnchor(
                TOPRIGHT,
                board.abilityPanel,
                TOPRIGHT,
                -(SOURCE_RIGHT_PADDING + (definition.index - 1) * (SOURCE_VALUE_WIDTH + SOURCE_VALUE_GAP)),
                SOURCE_HEADER_TOP
            )
            header:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        end
        header:SetScale(0.90)
        header:SetText(definition.text)
        table.insert(board.headers, header)
    end
    board.rule = WINDOW_MANAGER:CreateControl(nil, board.abilityPanel, CT_BACKDROP)
    board.rule:SetAnchor(TOPLEFT, board.abilityPanel, TOPLEFT, 10, SOURCE_RULE_TOP)
    board.rule:SetAnchor(TOPRIGHT, board.abilityPanel, TOPRIGHT, -10, SOURCE_RULE_TOP)
    board.rule:SetHeight(1)
    board.rule:SetCenterColor(0.22, 0.34, 0.48, 1)
    board.rule:SetEdgeColor(0, 0, 0, 0)

    board.rows = {}
    for index = 1, VISIBLE_SOURCE_ROWS do
        local row = CreateSourceRow(board.abilityPanel, index)
        row:SetHandler("OnMouseWheel", function(_, delta)
            board.offset = math.max(0, (board.offset or 0) - delta)
            Analytics:RefreshSourceTable()
        end)
        table.insert(board.rows, row)
    end
    board.empty = CreateLabel(board.abilityPanel, "ZoFontGame", MUTED[1], MUTED[2], MUTED[3])
    board.empty:SetAnchor(TOP, board.abilityPanel, TOP, 0, SOURCE_ROWS_TOP + 30)
    board.empty:SetDimensions(500, 30)
    board.empty:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    board.empty:SetText("No analytics recorded for this duel")
    board.offset = 0
    board.abilityTrack, board.abilityThumb = CreateScrollIndicator(board.abilityPanel, SOURCE_ROWS_TOP, -10)
    board.abilityPanel:SetHandler("OnMouseWheel", function(_, delta)
        board.offset = math.max(0, (board.offset or 0) - delta)
        Analytics:RefreshSourceTable()
    end)
    return board
end

local function CreateLogRow(parent, index)
    local row = WINDOW_MANAGER:CreateControl(nil, parent, CT_CONTROL)
    row:SetAnchor(TOPLEFT, parent, TOPLEFT, 10, 144 + (index - 1) * ROW_HEIGHT)
    row:SetAnchor(TOPRIGHT, parent, TOPRIGHT, -10, 144 + (index - 1) * ROW_HEIGHT)
    row:SetHeight(ROW_HEIGHT)
    local definitions = {
        { key = "time", x = 0, width = 88 },
        { key = "icon", x = 96, texture = true, width = 24 },
        { key = "ability", x = 128, width = 320 },
        { key = "source", x = 462, width = 240 },
        { key = "target", x = 716, width = 240 },
    }
    for _, definition in ipairs(definitions) do
        if definition.texture then
            row[definition.key] = WINDOW_MANAGER:CreateControl(nil, row, CT_TEXTURE)
            row[definition.key]:SetAnchor(LEFT, row, LEFT, definition.x, 0)
            row[definition.key]:SetDimensions(24, 24)
        else
            row[definition.key] = CreateLabel(row, "ZoFontGame", WHITE[1], WHITE[2], WHITE[3])
            row[definition.key]:SetAnchor(LEFT, row, LEFT, definition.x, 0)
            row[definition.key]:SetDimensions(definition.width, 26)
            row[definition.key]:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        end
    end
    row.amount = CreateLabel(row, "ZoFontGame", WHITE[1], WHITE[2], WHITE[3])
    row.amount:SetAnchor(RIGHT, row, RIGHT, 0, 0)
    row.amount:SetDimensions(230, 26)
    row.amount:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    row.amount:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    row.message = CreateLabel(row, "ZoFontGame", WHITE[1], WHITE[2], WHITE[3])
    row.message:SetAnchor(LEFT, row, LEFT, 96, 0)
    row.message:SetAnchor(RIGHT, row, RIGHT, 0, 0)
    row.message:SetHeight(26)
    row.message:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    row.message:SetHidden(true)
    return row
end

local function CreateCombatLog(parent)
    local board = CreatePanel(parent)
    board:SetAnchor(TOPLEFT, parent, TOPLEFT, 18, CONTENT_TOP)
    board:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, -18, -18)
    board:SetMouseEnabled(true)
    board.filters = {}
    for index, definition in ipairs(Analytics.LOG_FILTER_DEFINITIONS) do
        local key = definition.key
        local label = CreateClickableLabel(board, definition.label, 164, function()
            Analytics:ToggleLogFilter(key)
        end)
        local column = (index - 1) % 7
        local line = math.floor((index - 1) / 7)
        label:SetAnchor(TOPLEFT, board, TOPLEFT, 10 + column * 174, 5 + line * 31)
        board.filters[key] = label
    end
    board.filterDivider = WINDOW_MANAGER:CreateControl(nil, board, CT_BACKDROP)
    board.filterDivider:SetAnchor(TOPLEFT, board, TOPLEFT, 10, 70)
    board.filterDivider:SetAnchor(TOPRIGHT, board, TOPRIGHT, -10, 70)
    board.filterDivider:SetHeight(1)
    board.filterDivider:SetCenterColor(0.22, 0.34, 0.48, 1)
    board.filterDivider:SetEdgeColor(0, 0, 0, 0)
    board.skillFilter = CreateLabel(board, "ZoFontGameBold", BLUE[1], BLUE[2], BLUE[3])
    board.skillFilter:SetAnchor(TOPRIGHT, board, TOPRIGHT, -82, 76)
    board.skillFilter:SetDimensions(410, 24)
    board.skillFilter:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    board.skillFilter:SetHidden(true)
    board.clearSkill = CreateClickableLabel(board, "CLEAR", 66, function()
        Analytics:ClearSkillFilter(true)
    end)
    board.clearSkill:SetAnchor(TOPRIGHT, board, TOPRIGHT, -10, 72)
    board.clearSkill:SetHidden(true)
    local headers = {
        { text = "TIME", x = 10, width = 88 },
        { text = "ABILITY", x = 138, width = 320 },
        { text = "SOURCE", x = 472, width = 240 },
        { text = "TARGET", x = 726, width = 240 },
    }
    for _, definition in ipairs(headers) do
        local label = CreateLabel(board, "ZoFontGameBold", MUTED[1], MUTED[2], MUTED[3])
        label:SetAnchor(TOPLEFT, board, TOPLEFT, definition.x, 112)
        label:SetDimensions(definition.width, 20)
        label:SetText(definition.text)
    end
    local amount = CreateLabel(board, "ZoFontGameBold", MUTED[1], MUTED[2], MUTED[3])
    amount:SetAnchor(TOPRIGHT, board, TOPRIGHT, -10, 112)
    amount:SetDimensions(230, 20)
    amount:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    amount:SetText("VALUE")
    local rule = WINDOW_MANAGER:CreateControl(nil, board, CT_BACKDROP)
    rule:SetAnchor(TOPLEFT, board, TOPLEFT, 10, 136)
    rule:SetAnchor(TOPRIGHT, board, TOPRIGHT, -10, 136)
    rule:SetHeight(1)
    rule:SetCenterColor(0.22, 0.34, 0.48, 1)
    rule:SetEdgeColor(0, 0, 0, 0)
    board.rows = {}
    for index = 1, VISIBLE_LOG_ROWS do
        table.insert(board.rows, CreateLogRow(board, index))
    end
    board.empty = CreateLabel(board, "ZoFontGame", MUTED[1], MUTED[2], MUTED[3])
    board.empty:SetAnchor(TOP, board, TOP, 0, 176)
    board.empty:SetDimensions(520, 30)
    board.empty:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    board.empty:SetText("No events recorded in this category")
    board.offset = 0
    board:SetHandler("OnMouseWheel", function(_, delta)
        board.offset = math.max(0, (board.offset or 0) - delta)
        Analytics:RefreshCombatLog()
    end)
    return board
end

local EFFECT_FILTERS = {
    { key = "all", label = "ALL", width = 92 },
    { key = "incomingBuff", label = "INCOMING BUFF", width = 184 },
    { key = "outgoingBuff", label = "OUTGOING BUFF", width = 184 },
    { key = "incomingDebuff", label = "INCOMING DEBUFF", width = 198 },
    { key = "outgoingDebuff", label = "OUTGOING DEBUFF", width = 198 },
}

local function CreateEffectRow(parent, index)
    local row = WINDOW_MANAGER:CreateControl(nil, parent, CT_CONTROL)
    row:SetAnchor(TOPLEFT, parent, TOPLEFT, 10, 102 + (index - 1) * ROW_HEIGHT)
    row:SetAnchor(TOPRIGHT, parent, TOPRIGHT, -10, 102 + (index - 1) * ROW_HEIGHT)
    row:SetHeight(ROW_HEIGHT)
    local definitions = {
        { key = "icon", x = 0, texture = true, width = 24 },
        { key = "effect", x = 32, width = 330 },
        { key = "kind", x = 380, width = 120 },
        { key = "applications", x = 515, width = 90 },
        { key = "uptime", x = 620, width = 140 },
        { key = "source", x = 780, width = 230 },
        { key = "target", x = 1020, width = 250 },
    }
    for _, definition in ipairs(definitions) do
        if definition.texture then
            row[definition.key] = WINDOW_MANAGER:CreateControl(nil, row, CT_TEXTURE)
            row[definition.key]:SetAnchor(LEFT, row, LEFT, definition.x, 0)
            row[definition.key]:SetDimensions(24, 24)
        else
            row[definition.key] = CreateLabel(row, "ZoFontGame", WHITE[1], WHITE[2], WHITE[3])
            row[definition.key]:SetAnchor(LEFT, row, LEFT, definition.x, 0)
            row[definition.key]:SetDimensions(definition.width, 26)
            row[definition.key]:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        end
    end
    return row
end

local function CreateUptimeBoard(parent)
    local board = CreatePanel(parent)
    board:SetAnchor(TOPLEFT, parent, TOPLEFT, 18, CONTENT_TOP)
    board:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, -18, -18)
    board:SetMouseEnabled(true)
    board.filters = {}
    local previous
    for _, definition in ipairs(EFFECT_FILTERS) do
        local key = definition.key
        local label = CreateClickableLabel(board, definition.label, definition.width, function()
            Analytics:SetUptimeFilter(key)
        end)
        if previous then
            label:SetAnchor(TOPLEFT, previous, TOPRIGHT, 8, 0)
        else
            label:SetAnchor(TOPLEFT, board, TOPLEFT, 10, 8)
        end
        board.filters[key] = label
        previous = label
    end
    local headers = {
        { text = "EFFECT", x = 42, width = 330 },
        { text = "TYPE", x = 390, width = 120 },
        { text = "APPS", x = 525, width = 90 },
        { text = "UPTIME", x = 630, width = 140 },
        { text = "SOURCE", x = 790, width = 230 },
        { text = "TARGET", x = 1030, width = 250 },
    }
    for _, definition in ipairs(headers) do
        local label = CreateLabel(board, "ZoFontGameBold", MUTED[1], MUTED[2], MUTED[3])
        label:SetAnchor(TOPLEFT, board, TOPLEFT, definition.x, 70)
        label:SetDimensions(definition.width, 20)
        label:SetText(definition.text)
    end
    board.rule = WINDOW_MANAGER:CreateControl(nil, board, CT_BACKDROP)
    board.rule:SetAnchor(TOPLEFT, board, TOPLEFT, 10, 94)
    board.rule:SetAnchor(TOPRIGHT, board, TOPRIGHT, -10, 94)
    board.rule:SetHeight(1)
    board.rule:SetCenterColor(0.22, 0.34, 0.48, 1)
    board.rule:SetEdgeColor(0, 0, 0, 0)
    board.rows = {}
    for index = 1, VISIBLE_UPTIME_ROWS do
        table.insert(board.rows, CreateEffectRow(board, index))
    end
    board.empty = CreateLabel(board, "ZoFontGame", MUTED[1], MUTED[2], MUTED[3])
    board.empty:SetAnchor(TOP, board, TOP, 0, 132)
    board.empty:SetDimensions(620, 30)
    board.empty:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    board.empty:SetText("No buff or debuff uptime recorded")
    board.offset = 0
    board:SetHandler("OnMouseWheel", function(_, delta)
        board.offset = math.max(0, (board.offset or 0) - delta)
        Analytics:RefreshUptime()
    end)
    return board
end

local function CreateStatsBoard(parent, titleText, leftSide)
    local board = CreatePanel(parent)
    board.isDefensive = not leftSide
    if leftSide then
        board:SetAnchor(TOPLEFT, parent, TOPLEFT, 18, CONTENT_TOP)
        board:SetAnchor(BOTTOMRIGHT, parent, BOTTOM, -6, -18)
    else
        board:SetAnchor(TOPLEFT, parent, TOP, 6, CONTENT_TOP)
        board:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, -18, -18)
    end
    board.title = CreateLabel(board, "ZoFontWinH2", BLUE[1], BLUE[2], BLUE[3])
    board.title:SetAnchor(TOPLEFT, board, TOPLEFT, 12, 10)
    board.title:SetDimensions(300, 26)
    board.title:SetText(titleText)
    local headers = {
        { text = "STAT", key = "name" },
        { text = "LOW", key = "low", index = 3 },
        { text = "AVERAGE", key = "average", index = 2 },
        { text = "HIGH", key = "high", index = 1 },
    }
    for _, definition in ipairs(headers) do
        local label = CreateLabel(board, "ZoFontGameBold", MUTED[1], MUTED[2], MUTED[3])
        if definition.key ~= "name" then
            label:SetAnchor(
                TOPRIGHT,
                board,
                TOPRIGHT,
                -(10 + (definition.index - 1) * (STAT_VALUE_WIDTH + STAT_VALUE_GAP)),
                44
            )
            label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
            label:SetDimensions(STAT_VALUE_WIDTH, 20)
        else
            label:SetAnchor(TOPLEFT, board, TOPLEFT, 12, 44)
            label:SetDimensions(240, 20)
        end
        label:SetText(definition.text)
    end
    local rule = WINDOW_MANAGER:CreateControl(nil, board, CT_BACKDROP)
    rule:SetAnchor(TOPLEFT, board, TOPLEFT, 10, 68)
    rule:SetAnchor(TOPRIGHT, board, TOPRIGHT, -10, 68)
    rule:SetHeight(1)
    rule:SetCenterColor(0.22, 0.34, 0.48, 1)
    rule:SetEdgeColor(0, 0, 0, 0)
    board.rows = {}
    for index = 1, 12 do
        local row = WINDOW_MANAGER:CreateControl(nil, board, CT_CONTROL)
        row:SetAnchor(TOPLEFT, board, TOPLEFT, 12, 76 + (index - 1) * 34)
        row:SetAnchor(TOPRIGHT, board, TOPRIGHT, -10, 76 + (index - 1) * 34)
        row:SetHeight(32)
        row.name = CreateLabel(row, "ZoFontGame", WHITE[1], WHITE[2], WHITE[3])
        row.name:SetAnchor(LEFT, row, LEFT, 0, 0)
        row.name:SetDimensions(240, 28)
        for columnIndex, key in ipairs({ "high", "average", "low" }) do
            local cell = WINDOW_MANAGER:CreateControl(nil, row, CT_CONTROL)
            cell:SetAnchor(
                RIGHT,
                row,
                RIGHT,
                -((columnIndex - 1) * (STAT_VALUE_WIDTH + STAT_VALUE_GAP)),
                0
            )
            cell:SetDimensions(STAT_VALUE_WIDTH, 28)

            cell.percent = CreateLabel(cell, "ZoFontGame", WHITE[1], WHITE[2], WHITE[3])
            cell.percent:SetAnchor(LEFT, cell, LEFT, 0, 0)
            cell.percent:SetDimensions(46, 28)
            cell.percent:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
            cell.percent:SetVerticalAlignment(TEXT_ALIGN_CENTER)

            cell.divider = WINDOW_MANAGER:CreateControl(nil, cell, CT_BACKDROP)
            cell.divider:SetAnchor(CENTER, cell, CENTER, -6, 0)
            cell.divider:SetDimensions(1, 22)
            cell.divider:SetCenterColor(0.22, 0.34, 0.48, 1)
            cell.divider:SetEdgeColor(0, 0, 0, 0)

            cell.value = CreateLabel(cell, "ZoFontGame", WHITE[1], WHITE[2], WHITE[3])
            cell.value:SetAnchor(RIGHT, cell, RIGHT, 0, 0)
            cell.value:SetDimensions(58, 28)
            cell.value:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
            cell.value:SetVerticalAlignment(TEXT_ALIGN_CENTER)

            cell.full = CreateLabel(cell, "ZoFontGame", WHITE[1], WHITE[2], WHITE[3])
            cell.full:SetAnchorFill(cell)
            cell.full:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
            cell.full:SetVerticalAlignment(TEXT_ALIGN_CENTER)

            row[key] = cell
        end
        table.insert(board.rows, row)
    end
    board.empty = CreateLabel(board, "ZoFontGame", MUTED[1], MUTED[2], MUTED[3])
    board.empty:SetAnchor(TOP, board, TOP, 0, 100)
    board.empty:SetDimensions(360, 30)
    board.empty:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    board.empty:SetText("No fight-stat samples recorded")
    return board
end

local function CreateHelpSection(parent, titleText, bodyText, left, top, width, height)
    local section = WINDOW_MANAGER:CreateControl(nil, parent, CT_CONTROL)
    section:SetAnchor(TOPLEFT, parent, TOPLEFT, left, top)
    section:SetDimensions(width, height)

    section.title = CreateLabel(section, "ZoFontWinH2", BLUE[1], BLUE[2], BLUE[3])
    section.title:SetAnchor(TOPLEFT, section, TOPLEFT, 0, 0)
    section.title:SetDimensions(width, 26)
    section.title:SetText(titleText)

    section.rule = WINDOW_MANAGER:CreateControl(nil, section, CT_BACKDROP)
    section.rule:SetAnchor(TOPLEFT, section, TOPLEFT, 0, 29)
    section.rule:SetDimensions(width, 1)
    section.rule:SetCenterColor(0.22, 0.34, 0.48, 1)
    section.rule:SetEdgeColor(0, 0, 0, 0)

    section.body = CreateLabel(section, "ZoFontGame", WHITE[1], WHITE[2], WHITE[3])
    section.body:SetAnchor(TOPLEFT, section, TOPLEFT, 0, 38)
    section.body:SetDimensions(width, height - 38)
    section.body:SetVerticalAlignment(TEXT_ALIGN_TOP)
    section.body:SetText(bodyText)
    return section
end

local function CreateHelpPanel(parent)
    local panel = CreatePanel(parent)
    panel:SetAnchor(TOPLEFT, parent, TOPLEFT, 18, 50)
    panel:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, -18, -18)

    panel.heading = CreateLabel(panel, "ZoFontWinH1", BLUE[1], BLUE[2], BLUE[3])
    panel.heading:SetAnchor(TOPLEFT, panel, TOPLEFT, 18, 14)
    panel.heading:SetDimensions(620, 34)
    panel.heading:SetText("ANALYTICS HELP")

    panel.intro = CreateLabel(panel, "ZoFontGame", MUTED[1], MUTED[2], MUTED[3])
    panel.intro:SetAnchor(TOPLEFT, panel, TOPLEFT, 18, 50)
    panel.intro:SetAnchor(TOPRIGHT, panel, TOPRIGHT, -18, 50)
    panel.intro:SetHeight(48)
    panel.intro:SetText("Analytics reports are session-only by default and never replace the result, rating, or history owned by Dueling. Select a fight first, then save only the reports you want to keep.")

    local halfWidth = 590
    local rightLeft = 632
    panel.damageDone = CreateHelpSection(panel, "DAMAGE DONE", "Outgoing damage grouped by ability. TOTAL is health damage, DPS is the active-window pressure rate, and DUEL DPS uses the complete fight duration. Select an ability row to open Combat Log filtered to that exact ability.", 18, 108, halfWidth, 124)
    panel.damageTaken = CreateHelpSection(panel, "DAMAGE TAKEN", "Incoming damage grouped by the opponent's ability. Blocked and reliably associated absorbed pressure can contribute to active DPS without changing the saved health-damage total. Select any row to inspect its individual events.", 18, 242, halfWidth, 124)
    panel.healingDone = CreateHelpSection(panel, "HEALING DONE", "Healing produced by you, grouped by ability. HPS describes its active reporting window and DUEL HPS uses the full fight duration. Values depend on healing events reported by the ESO API.", 18, 376, halfWidth, 116)
    panel.healingReceived = CreateHelpSection(panel, "HEALING RECEIVED", "Healing received from yourself or another valid source, grouped by ability. Select an ability to see only that ability's timestamps in Combat Log.", 18, 502, halfWidth, 108)

    panel.combatLog = CreateHelpSection(panel, "COMBAT LOG", "The upper-left panel is a timestamped evidence stream with independent filters for damage, healing, effects, resources, used skills, stat changes, fight information, and performance samples. Enable several filters together or use ALL. Selecting an ability focuses its timestamps; selecting that ability again returns to the full log.", rightLeft, 108, halfWidth, 132)
    panel.effects = CreateHelpSection(panel, "BUFF / DEBUFF UPTIME", "The upper-right panel consolidates repeated buff and debuff applications into one row per effect, direction, source, and target. It shows application count and uptime. Stacked effects show their highest observed stack count.", rightLeft, 250, halfWidth, 124)
    panel.fightStats = CreateHelpSection(panel, "FIGHT STATS", "Open the dedicated FIGHT STATS tab beside DUELING. It shows the lowest, average, and highest offensive and defensive character stats sampled during the selected fight. Critical chance is converted with ESO's API; resistance percentages are CP160 approximations.", rightLeft, 384, halfWidth, 124)
    panel.selection = CreateHelpSection(panel, "SAVE AND DELETE", "New Analytics reports last only until logout or /reloadui. SAVE DUEL permanently keeps the selected report, including timestamps, effects, source tables, and Fight Stats. DELETE DUEL permanently removes only its Analytics report; the Dueling journal result and rating remain intact.", rightLeft, 518, halfWidth, 132)
    panel.availability = CreateHelpSection(panel, "DATA AVAILABILITY", "Use Select Opponent to choose a session report or a permanently saved report. Missing API data is shown as N/A rather than estimated. Unsaved reports disappear automatically when the UI reloads or the session ends.", rightLeft, 660, halfWidth, 104)
    return panel
end

local function SetTierEffectControlsHidden(card, hidden)
    if not card then
        return
    end
    for _, control in ipairs({ card.glowOuter, card.glowInner, card.rayBurst }) do
        if control then
            control:SetHidden(hidden)
        end
    end
    for _, collection in ipairs({ card.embers, card.sparkles, card.motes, card.cometTrail, card.pulseRings }) do
        for _, control in ipairs(collection or {}) do
            control:SetHidden(hidden)
        end
    end
end

function Analytics:SetDuelingContentHidden(hidden)
    local ui = Dueling.ui
    if not ui then
        return
    end

    -- These controls are the fixed Dueling chrome. Restore them before the
    -- normal Dueling refresh runs; that refresh then applies its own per-tab
    -- visibility to rows, panels, search, sorting, and pagination.
    for _, control in ipairs({
        ui.overallTierCard and ui.overallTierCard.box,
        ui.classTierCard and ui.classTierCard.box,
        ui.classTierSelector,
        ui.winRateBox,
        ui.recordBox,
        ui.summaryRailDivider,
    }) do
        if control then
            control:SetHidden(hidden)
        end
    end
    for _, tab in pairs(ui.tabs or {}) do
        tab:SetHidden(hidden)
    end

    if not hidden then
        return
    end

    SetTierEffectControlsHidden(ui.overallTierCard, true)
    SetTierEffectControlsHidden(ui.classTierCard, true)
    SetTierEffectControlsHidden(ui.winRateEffectCard, true)
    if Dueling.HideRankingInfoPanel then
        Dueling:HideRankingInfoPanel()
    end

    for _, control in ipairs({
        ui.detailBack,
        ui.searchLabel,
        ui.searchBackdrop,
        ui.searchInput,
        ui.aggregateSortBackdrop,
        ui.statisticsPanel,
        ui.settingsPanel,
        ui.commandsPanel,
        ui.opponentPerformancePanel,
        ui.duelDetailPanel,
        ui.pageLabel,
        ui.newer,
        ui.older,
    }) do
        if control then
            control:SetHidden(true)
        end
    end
    if ui.aggregateSortClickTarget then
        ui.aggregateSortClickTarget:SetMouseEnabled(false)
    end
    for _, row in ipairs(ui.rows or {}) do
        row:SetHidden(true)
        row:SetMouseEnabled(false)
        if row.clickTarget then
            row.clickTarget:SetMouseEnabled(false)
        end
    end
end

function Analytics:CreateUI()
    if self.ui then
        return
    end
    Dueling:CreateUI()
    local window = Dueling.ui.window
    local analyticsTab = CreateClickableLabel(window, "ANALYTICS", 112, function()
        Analytics:SelectModule()
    end)
    analyticsTab:SetAnchor(RIGHT, Dueling.ui.moduleTab, LEFT, -18, 0)
    local analyticsTabBorder = analyticsTab.tabBorder
    local analyticsUnderline = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    analyticsUnderline:SetAnchor(BOTTOM, analyticsTab, BOTTOM, 0, 0)
    analyticsUnderline:SetDimensions(96, 2)
    analyticsUnderline:SetCenterColor(BLUE[1], BLUE[2], BLUE[3], 1)
    analyticsUnderline:SetEdgeColor(0, 0, 0, 0)
    analyticsUnderline:SetHidden(true)

    local panel = WINDOW_MANAGER:CreateControl(nil, window, CT_CONTROL)
    panel:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 62)
    panel:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, 0, 0)
    -- The full-size module panel must not consume the top-level window's
    -- resize hit area. Mouse-enabled child boards and buttons remain fully
    -- interactive, while every exposed outer edge can resize the journal.
    panel:SetMouseEnabled(false)
    local background = WINDOW_MANAGER:CreateControl(nil, panel, CT_BACKDROP)
    background:SetAnchorFill(panel)
    background:SetCenterColor(0.012, 0.016, 0.024, 1)
    -- The Analytics workspace uses the journal itself as its outer frame.
    -- Individual panes retain their borders, but no extra container box is
    -- drawn around the four-pane layout.
    background:SetEdgeColor(0.36, 0.74, 1, 1)

    local scopeTab = CreateClickableLabel(panel, "DUELING", 124, function()
        Analytics:SetActiveScope("dueling")
    end)
    scopeTab:SetAnchor(TOPLEFT, panel, TOPLEFT, 20, 10)
    SetTabSelected(scopeTab, true)

    local fightStatsTab = CreateClickableLabel(panel, "FIGHT STATS", 132, function()
        Analytics:SetActiveScope("fightStats")
    end)
    fightStatsTab:SetAnchor(TOPLEFT, scopeTab, TOPRIGHT, 8, 0)

    local helpTab = CreateClickableLabel(panel, "HELP", 82, function()
        Analytics:SetActiveScope("help")
    end)
    helpTab:SetAnchor(TOPLEFT, fightStatsTab, TOPRIGHT, 8, 0)

    local opponentSelector = CreatePanel(panel)
    opponentSelector:SetAnchor(TOPLEFT, panel, TOPLEFT, 20, 45)
    opponentSelector:SetAnchor(TOPRIGHT, panel, TOPRIGHT, -320, 45)
    opponentSelector:SetHeight(50)
    opponentSelector:SetMouseEnabled(true)
    local opponentSelectorCaption = CreateLabel(opponentSelector, "ZoFontGameBold", BLUE[1], BLUE[2], BLUE[3])
    opponentSelectorCaption:SetAnchor(TOPLEFT, opponentSelector, TOPLEFT, 12, 4)
    opponentSelectorCaption:SetDimensions(190, 18)
    opponentSelectorCaption:SetText("SELECT OPPONENT")
    local opponentSelectorValue = CreateLabel(opponentSelector, "ZoFontGame", WHITE[1], WHITE[2], WHITE[3])
    opponentSelectorValue:SetAnchor(TOPLEFT, opponentSelector, TOPLEFT, 12, 23)
    opponentSelectorValue:SetAnchor(TOPRIGHT, opponentSelector, TOPRIGHT, -42, 23)
    opponentSelectorValue:SetHeight(22)
    opponentSelectorValue:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    local opponentSelectorArrow = CreateLabel(opponentSelector, "ZoFontGameBold", MUTED[1], MUTED[2], MUTED[3])
    opponentSelectorArrow:SetAnchor(RIGHT, opponentSelector, RIGHT, -13, 6)
    opponentSelectorArrow:SetDimensions(22, 22)
    opponentSelectorArrow:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    opponentSelectorArrow:SetText("v")
    local opponentSelectorClickTarget = WINDOW_MANAGER:CreateControl(nil, opponentSelector, CT_CONTROL)
    opponentSelectorClickTarget:SetAnchorFill(opponentSelector)
    opponentSelectorClickTarget:SetMouseEnabled(true)
    opponentSelectorClickTarget:SetHandler("OnMouseEnter", function()
        opponentSelector:SetEdgeColor(BLUE[1], BLUE[2], BLUE[3], 1)
    end)
    opponentSelectorClickTarget:SetHandler("OnMouseExit", function()
        opponentSelector:SetEdgeColor(0.22, 0.34, 0.48, 1)
    end)
    opponentSelectorClickTarget:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            Analytics:ShowOpponentSelectorMenu(opponentSelector)
        end
    end)

    local saveDuelButton = CreateActionButton(panel, "SAVE DUEL", function()
        Analytics:SaveSelectedDuel()
    end)
    saveDuelButton:SetAnchor(TOPLEFT, opponentSelector, TOPRIGHT, 10, 0)
    local deleteDuelButton = CreateActionButton(panel, "DELETE DUEL", function()
        Analytics:DeleteSelectedDuel()
    end)
    deleteDuelButton:SetAnchor(TOPLEFT, saveDuelButton, TOPRIGHT, 10, 0)

    local sourceTable = CreateSourceTable(panel)
    local offensiveStats = CreateStatsBoard(panel, "OFFENSIVE STATS", true)
    local defensiveStats = CreateStatsBoard(panel, "DEFENSIVE STATS", false)
    local helpPanel = CreateHelpPanel(panel)
    panel:SetHidden(true)
    self.ui = {
        analyticsTab = analyticsTab,
        analyticsTabBorder = analyticsTabBorder,
        analyticsUnderline = analyticsUnderline,
        panel = panel,
        scopeTab = scopeTab,
        fightStatsTab = fightStatsTab,
        helpTab = helpTab,
        opponentSelector = opponentSelector,
        opponentSelectorValue = opponentSelectorValue,
        saveDuelButton = saveDuelButton,
        deleteDuelButton = deleteDuelButton,
        sourceTable = sourceTable,
        offensiveStats = offensiveStats,
        defensiveStats = defensiveStats,
        helpPanel = helpPanel,
    }
end

local function FormatEmbeddedLogTime(offsetMS)
    offsetMS = math.max(0, tonumber(offsetMS) or 0)
    local seconds = math.floor(offsetMS / 1000)
    return string.format("%d:%02d.%03d", math.floor(seconds / 60), seconds % 60, offsetMS % 1000)
end

local function UpdateScrollIndicator(track, thumb, offset, total, visible)
    local maximumOffset = math.max(0, total - visible)
    local trackHeight = math.max(1, tonumber(track:GetHeight()) or 1)
    local thumbHeight = maximumOffset == 0
        and trackHeight
        or math.max(28, math.floor(trackHeight * math.min(1, visible / math.max(1, total))))
    local travel = math.max(0, trackHeight - thumbHeight)
    local top = maximumOffset > 0 and math.floor(travel * offset / maximumOffset) or 0
    thumb:ClearAnchors()
    thumb:SetAnchor(TOP, track, TOP, 0, top)
    thumb:SetDimensions(4, thumbHeight)
    track:SetHidden(maximumOffset == 0)
    thumb:SetHidden(maximumOffset == 0)
end

local function MatchSelectedSkill(event, skillFilter)
    if not skillFilter then
        return true
    end
    if skillFilter.category ~= event.category then
        return false
    end
    if skillFilter.abilityId and skillFilter.abilityId > 0 then
        return tonumber(event.abilityId) == skillFilter.abilityId
    end
    return zo_strlower(tostring(event.name or "")) == zo_strlower(skillFilter.name)
end

local function EmbeddedEventAmount(event)
    local absorbed = math.max(0, tonumber(event.absorbed) or 0)
    if event.shielded then
        return absorbed > 0 and ("ABSORBED " .. FormatCombatNumber(absorbed)) or "SHIELDED"
    elseif absorbed > 0 then
        return string.format(
            "%s%s (+%s ABS)",
            event.critical and "CRIT " or "",
            FormatCombatNumber(event.amount),
            FormatCombatNumber(absorbed)
        )
    elseif event.blocked then
        return (event.critical and "CRIT " or "") .. "BLOCKED " .. FormatCombatNumber(event.amount)
    end
    return (event.critical and "CRIT " or "") .. FormatCombatNumber(event.amount)
end

local function CollectAnalyticsLogEntries(analytics, enabled, skillFilter)
    local entries = {}
    enabled = enabled or {}
    for _, event in ipairs(analytics and analytics.combatLog or {}) do
        if enabled[event.category] and MatchSelectedSkill(event, skillFilter) then
            local entry = {}
            for key, value in pairs(event) do
                entry[key] = value
            end
            entry.displayType = "combat"
            table.insert(entries, entry)
        end
    end
    if not skillFilter then
        for _, effect in ipairs(analytics and analytics.effects or {}) do
            local include = (effect.effectKind == "buff" and effect.incoming and enabled.incomingBuff)
                or (effect.effectKind == "buff" and effect.outgoing and enabled.outgoingBuff)
                or (effect.effectKind == "debuff" and effect.incoming and enabled.incomingDebuff)
                or (effect.effectKind == "debuff" and effect.outgoing and enabled.outgoingDebuff)
            if include then
                table.insert(entries, {
                    displayType = "effect",
                    offsetMS = effect.offsetMS,
                    sequence = effect.sequence,
                    abilityId = effect.abilityId,
                    name = effect.name,
                    icon = effect.icon,
                    sourceName = effect.sourceName,
                    targetName = effect.targetName,
                    effectKind = effect.effectKind,
                    stacks = effect.stacks,
                })
            end
        end
        for _, event in ipairs(analytics and analytics.systemLog or {}) do
            if enabled[event.category] then
                table.insert(entries, {
                    displayType = "message",
                    offsetMS = event.offsetMS,
                    sequence = event.sequence,
                    category = event.category,
                    message = event.message,
                    abilityId = event.abilityId,
                })
            end
        end
    end
    table.sort(entries, function(left, right)
        if (left.offsetMS or 0) ~= (right.offsetMS or 0) then
            return (left.offsetMS or 0) < (right.offsetMS or 0)
        end
        return (left.sequence or 0) < (right.sequence or 0)
    end)
    return entries
end

function Analytics:RefreshSourceTable()
    local duel = self:GetSelectedDuel()
    local analytics = self:GetAnalyticsForDuel(duel)
    local category = analytics and analytics[self.activeTab]
    local sources = category and category.sources or {}
    local board = self.ui.sourceTable
    local maximumOffset = math.max(0, #sources - #board.rows)
    board.offset = math.max(0, math.min(board.offset or 0, maximumOffset))
    local duration = duel and tonumber(duel.durationSeconds) or 0
    local categoryDefinition = self.CATEGORIES[self.activeTab]
    local categoryTotal = tonumber(category and category.total) or 0
    local pressureTotal = tonumber(category and category.pressureTotal) or categoryTotal
    local activeDuration = tonumber(category and category.activeDurationSeconds) or duration
    board.title:SetText(categoryDefinition.label)
    for key, tab in pairs(board.categoryTabs or {}) do
        SetTabSelected(tab, key == self.activeTab)
    end
    local playerDisplayName = type(GetDisplayName) == "function" and GetDisplayName() or "Player"
    local opponentDisplayName = duel and duel.opponent and duel.opponent.displayName or "Opponent"
    local targetName = self.activeTab == "damageDone" and opponentDisplayName or playerDisplayName
    board.targetValue:SetText(Truncate(targetName, 28))
    board.totalValue:SetText(FormatCombatNumber(categoryTotal))
    board.rateCaption:SetText(categoryDefinition.rateLabel)
    board.rateValue:SetText(FormatRate(pressureTotal, activeDuration))
    board.duelRateCaption:SetText(categoryDefinition.duelRateLabel)
    board.duelRateValue:SetText(FormatRate(categoryTotal, duration))
    for rowIndex, row in ipairs(board.rows) do
        local source = sources[board.offset + rowIndex]
        if source then
            row:SetHidden(false)
            row.source = source
            local selected = self.selectedSkillFilter
                and self.selectedSkillFilter.category == self.activeTab
                and ((tonumber(source.abilityId) or 0) > 0
                    and self.selectedSkillFilter.abilityId == tonumber(source.abilityId)
                    or ((tonumber(source.abilityId) or 0) <= 0
                        and zo_strlower(tostring(self.selectedSkillFilter.name or ""))
                            == zo_strlower(tostring(source.name or ""))))
            row.selected = selected and true or false
            row.highlight:SetHidden(not row.selected)
            local icon = AbilityIcon(source.abilityId)
            row.icon:SetTexture(icon or "")
            row.icon:SetHidden(icon == nil)
            row.name:SetText(Truncate(source.name, 46))
            local total = tonumber(source.total) or 0
            local sourcePressureTotal = tonumber(source.pressureTotal)
                or (total + math.max(0, tonumber(source.absorbed) or 0))
            local hits = math.max(0, math.floor((tonumber(source.hitCount) or 0) + 0.5))
            local crits = math.max(0, math.floor((tonumber(source.critCount) or 0) + 0.5))
            row.percent:SetText(categoryTotal > 0 and string.format("%.1f%%", total / categoryTotal * 100) or "0.0%")
            row.rate:SetText(FormatRate(sourcePressureTotal, activeDuration))
            row.total:SetText(FormatCombatNumber(total))
            row.critHits:SetText(string.format("%d/%d", crits, hits))
            row.critPercent:SetText(hits > 0 and string.format("%.1f%%", crits / hits * 100) or "0.0%")
            row.min:SetText(source.minHit and FormatCombatNumber(source.minHit) or "N/A")
            row.average:SetText(hits > 0 and FormatCombatNumber(total / hits) or "N/A")
            row.max:SetText(source.maxHit and FormatCombatNumber(source.maxHit) or "N/A")
            local color = self.activeTab == "damageTaken" and DAMAGE
                or ((self.activeTab == "healingDone" or self.activeTab == "healingReceived") and HEALING or WHITE)
            for _, label in ipairs({ row.name, row.percent, row.rate, row.total, row.critHits, row.critPercent, row.min, row.average, row.max }) do
                SetColor(label, color)
            end
        else
            row.source = nil
            row.selected = false
            row.highlight:SetHidden(true)
            row:SetHidden(true)
        end
    end
    board.empty:SetHidden(#sources > 0)
    UpdateScrollIndicator(board.abilityTrack, board.abilityThumb, board.offset, #sources, #board.rows)

    local skillFilter = self.selectedSkillFilter
    local enabled = self.logFilters or {}
    local embeddedEvents = CollectAnalyticsLogEntries(analytics, enabled, skillFilter)
    for key, filter in pairs(board.logFilters or {}) do
        local selected = key == "all" and self:IsEveryLogFilterEnabled() or enabled[key]
        SetTabSelected(filter, selected and true or false)
    end
    local maximumLogOffset = math.max(0, #embeddedEvents - #board.logRows)
    board.logOffset = math.max(0, math.min(
        board.logOffset or self.embeddedLogOffset or 0,
        maximumLogOffset
    ))
    self.embeddedLogOffset = board.logOffset
    local hasSkillFilter = skillFilter and skillFilter.category == self.activeTab
    board.logTitle:SetText(hasSkillFilter
        and ("COMBAT LOG - " .. string.upper(Truncate(skillFilter.name, 34)))
        or (self:IsEveryLogFilterEnabled() and "COMBAT LOG - ALL" or "COMBAT LOG - FILTERED"))
    for rowIndex, row in ipairs(board.logRows) do
        local event = embeddedEvents[board.logOffset + rowIndex]
        if event then
            row:SetHidden(false)
            row.time:SetText(FormatEmbeddedLogTime(event.offsetMS))
            local regularControls = { row.icon, row.ability, row.source, row.target, row.amount }
            if event.displayType == "message" then
                for _, control in ipairs(regularControls) do
                    control:SetHidden(true)
                end
                row.message:SetHidden(false)
                row.message:SetText(Truncate(event.message, 145))
                SetColor(row.message, event.category == "performanceInfo" and YELLOW or MUTED)
            else
                row.message:SetHidden(true)
                for _, control in ipairs(regularControls) do
                    control:SetHidden(false)
                end
                local icon = event.icon or AbilityIcon(event.abilityId)
                row.icon:SetTexture(icon or "")
                row.icon:SetHidden(icon == nil)
                row.ability:SetText(Truncate(event.name, 31))
                row.source:SetText(Truncate(event.sourceName, 22))
                row.target:SetText(Truncate(event.targetName, 22))
                row.amount:SetText(event.displayType == "effect"
                    and (string.upper(event.effectKind or "effect")
                        .. (((tonumber(event.stacks) or 0) > 1) and (" " .. math.floor(event.stacks) .. "x") or ""))
                    or EmbeddedEventAmount(event))
            end
            local color = event.displayType == "effect"
                    and (event.effectKind == "debuff" and DAMAGE or HEALING)
                or (event.category == "damageTaken" and DAMAGE
                    or ((event.category == "healingDone" or event.category == "healingReceived") and HEALING or WHITE))
            SetColor(row.amount, color)
        else
            row.message:SetHidden(true)
            row:SetHidden(true)
        end
    end
    board.logEmpty:SetHidden(#embeddedEvents > 0)
    UpdateScrollIndicator(
        board.logTrack,
        board.logThumb,
        board.logOffset,
        #embeddedEvents,
        #board.logRows
    )

    local uptimes = {}
    local uptimeFilter = self.uptimeFilter or "all"
    for _, effect in ipairs(analytics and analytics.effectUptimes or {}) do
        local matches = uptimeFilter == "all"
            or (uptimeFilter == "incomingBuff" and effect.effectKind == "buff" and effect.incoming)
            or (uptimeFilter == "outgoingBuff" and effect.effectKind == "buff" and effect.outgoing)
            or (uptimeFilter == "incomingDebuff" and effect.effectKind == "debuff" and effect.incoming)
            or (uptimeFilter == "outgoingDebuff" and effect.effectKind == "debuff" and effect.outgoing)
        if matches then
            table.insert(uptimes, effect)
        end
    end
    for key, filter in pairs(board.uptimeFilters or {}) do
        SetTabSelected(filter, key == uptimeFilter)
    end
    local maximumUptimeOffset = math.max(0, #uptimes - #board.uptimeRows)
    board.uptimeOffset = math.max(0, math.min(
        board.uptimeOffset or self.embeddedUptimeOffset or 0,
        maximumUptimeOffset
    ))
    self.embeddedUptimeOffset = board.uptimeOffset
    for rowIndex, row in ipairs(board.uptimeRows) do
        local effect = uptimes[board.uptimeOffset + rowIndex]
        if effect then
            row:SetHidden(false)
            local icon = effect.icon or AbilityIcon(effect.abilityId)
            row.icon:SetTexture(icon or "")
            row.icon:SetHidden(icon == nil)
            local stackPrefix = (tonumber(effect.maxStacks) or 0) > 1
                and (tostring(math.floor(effect.maxStacks)) .. "x ") or ""
            row.effect:SetText(Truncate(stackPrefix .. tostring(effect.name or "Unknown effect"), 31))
            row.applications:SetText(tostring(math.floor(tonumber(effect.applications) or 0)))
            row.uptime:SetText(string.format("%.1f%%", tonumber(effect.uptimePercent) or 0))
            local color = effect.effectKind == "debuff" and DAMAGE or HEALING
            SetColor(row.effect, color)
            SetColor(row.applications, color)
            SetColor(row.uptime, color)
        else
            row:SetHidden(true)
        end
    end
    board.uptimeEmpty:SetHidden(#uptimes > 0)
    UpdateScrollIndicator(
        board.uptimeTrack,
        board.uptimeThumb,
        board.uptimeOffset,
        #uptimes,
        #board.uptimeRows
    )
end

local function FormatLogTime(offsetMS)
    offsetMS = math.max(0, tonumber(offsetMS) or 0)
    local seconds = math.floor(offsetMS / 1000)
    return string.format("%d:%02d.%03d", math.floor(seconds / 60), seconds % 60, offsetMS % 1000)
end

function Analytics:RefreshCombatLog()
    local duel = self:GetSelectedDuel()
    local analytics = self:GetAnalyticsForDuel(duel)
    local filtered = {}
    local skillFilter = self.selectedSkillFilter
    local enabled = self.logFilters or {}
    for _, event in ipairs(analytics and analytics.combatLog or {}) do
        local matchesSkill = true
        if skillFilter and skillFilter.category == event.category then
            if skillFilter.abilityId and skillFilter.abilityId > 0 then
                matchesSkill = tonumber(event.abilityId) == skillFilter.abilityId
            else
                matchesSkill = zo_strlower(tostring(event.name or "")) == zo_strlower(skillFilter.name)
            end
        end
        if enabled[event.category] and matchesSkill then
            local entry = {}
            for key, value in pairs(event) do
                entry[key] = value
            end
            entry.displayType = "combat"
            table.insert(filtered, entry)
        end
    end
    for _, effect in ipairs(analytics and analytics.effects or {}) do
        local include = (effect.effectKind == "buff" and effect.incoming and enabled.incomingBuff)
            or (effect.effectKind == "buff" and effect.outgoing and enabled.outgoingBuff)
            or (effect.effectKind == "debuff" and effect.incoming and enabled.incomingDebuff)
            or (effect.effectKind == "debuff" and effect.outgoing and enabled.outgoingDebuff)
        if include then
            table.insert(filtered, {
                displayType = "effect",
                offsetMS = effect.offsetMS,
                abilityId = effect.abilityId,
                name = effect.name,
                icon = effect.icon,
                sourceName = effect.sourceName,
                targetName = effect.targetName,
                effectKind = effect.effectKind,
                incoming = effect.incoming,
                outgoing = effect.outgoing,
                stacks = effect.stacks,
            })
        end
    end
    for _, event in ipairs(analytics and analytics.systemLog or {}) do
        if enabled[event.category] then
            table.insert(filtered, {
                displayType = "message",
                offsetMS = event.offsetMS,
                sequence = event.sequence,
                category = event.category,
                message = event.message,
                abilityId = event.abilityId,
            })
        end
    end
    table.sort(filtered, function(left, right)
        if (left.offsetMS or 0) ~= (right.offsetMS or 0) then
            return (left.offsetMS or 0) < (right.offsetMS or 0)
        end
        return (left.sequence or 0) < (right.sequence or 0)
    end)
    local board = self.ui.combatLog
    local maximumOffset = math.max(0, #filtered - #board.rows)
    board.offset = math.max(0, math.min(board.offset or 0, maximumOffset))
    for key, filter in pairs(board.filters) do
        local selected = key == "all" and self:IsEveryLogFilterEnabled() or enabled[key]
        SetColor(filter, selected and BLUE or MUTED)
    end
    local hasSkillFilter = skillFilter ~= nil and enabled[skillFilter.category] == true
    board.skillFilter:SetHidden(not hasSkillFilter)
    board.clearSkill:SetHidden(not hasSkillFilter)
    if hasSkillFilter then
        board.skillFilter:SetText("SKILL: " .. Truncate(skillFilter.name, 38))
    end
    board.empty:SetText("No events match the enabled Combat Log filters")
    for rowIndex, row in ipairs(board.rows) do
        local event = filtered[board.offset + rowIndex]
        if event then
            row:SetHidden(false)
            row.time:SetText(FormatLogTime(event.offsetMS))
            local regularControls = { row.icon, row.ability, row.source, row.target, row.amount }
            if event.displayType == "message" then
                for _, control in ipairs(regularControls) do
                    control:SetHidden(true)
                end
                row.message:SetHidden(false)
                row.message:SetText(Truncate(event.message, 150))
                SetColor(row.message, event.category == "performanceInfo" and YELLOW or MUTED)
            else
                row.message:SetHidden(true)
                for _, control in ipairs(regularControls) do
                    control:SetHidden(false)
                end
                local icon = event.icon or AbilityIcon(event.abilityId)
                row.icon:SetTexture(icon or "")
                row.icon:SetHidden(icon == nil)
                row.ability:SetText(Truncate(event.name, 38))
                row.source:SetText(Truncate(event.sourceName, 28))
                row.target:SetText(Truncate(event.targetName, 28))
                local amountText
                local color
                if event.displayType == "effect" then
                    local stackText = (tonumber(event.stacks) or 0) > 1
                        and (" " .. tostring(math.floor(event.stacks)) .. "x") or ""
                    amountText = string.upper(event.effectKind or "effect") .. stackText
                    color = event.effectKind == "debuff" and DAMAGE or HEALING
                else
                    local absorbed = math.max(0, tonumber(event.absorbed) or 0)
                    if event.shielded then
                        amountText = absorbed > 0 and ("ABSORBED " .. FormatCombatNumber(absorbed)) or "SHIELDED"
                    elseif absorbed > 0 then
                        amountText = string.format(
                            "%s%s (%s ABSORBED)",
                            event.critical and "CRIT " or "",
                            FormatCombatNumber(event.amount),
                            FormatCombatNumber(absorbed)
                        )
                    elseif event.blocked then
                        amountText = (event.critical and "CRIT " or "") .. "BLOCKED " .. FormatCombatNumber(event.amount)
                    else
                        amountText = (event.critical and "CRIT  " or "") .. FormatCombatNumber(event.amount)
                    end
                    color = (event.category == "damageTaken") and DAMAGE
                        or ((event.category == "healingDone" or event.category == "healingReceived") and HEALING or WHITE)
                end
                row.amount:SetText(amountText)
                SetColor(row.amount, color)
            end
        else
            row.message:SetHidden(true)
            row:SetHidden(true)
        end
    end
    board.empty:SetHidden(#filtered > 0)
end

function Analytics:RefreshUptime()
    local duel = self:GetSelectedDuel()
    local analytics = self:GetAnalyticsForDuel(duel)
    local filterName = self.uptimeFilter or "all"
    local filtered = {}
    for _, effect in ipairs(analytics and analytics.effectUptimes or {}) do
        local matches = filterName == "all"
            or (filterName == "incomingBuff" and effect.effectKind == "buff" and effect.incoming)
            or (filterName == "outgoingBuff" and effect.effectKind == "buff" and effect.outgoing)
            or (filterName == "incomingDebuff" and effect.effectKind == "debuff" and effect.incoming)
            or (filterName == "outgoingDebuff" and effect.effectKind == "debuff" and effect.outgoing)
        if matches then
            table.insert(filtered, effect)
        end
    end
    local board = self.ui.uptime
    local maximumOffset = math.max(0, #filtered - #board.rows)
    board.offset = math.max(0, math.min(board.offset or self.uptimeOffset or 0, maximumOffset))
    self.uptimeOffset = board.offset
    for key, filter in pairs(board.filters) do
        SetColor(filter, key == filterName and BLUE or MUTED)
    end
    for rowIndex, row in ipairs(board.rows) do
        local effect = filtered[board.offset + rowIndex]
        if effect then
            row:SetHidden(false)
            local icon = effect.icon or AbilityIcon(effect.abilityId)
            row.icon:SetTexture(icon or "")
            row.icon:SetHidden(icon == nil)
            local stackPrefix = (tonumber(effect.maxStacks) or 0) > 1
                and (tostring(math.floor(effect.maxStacks)) .. "x ") or ""
            row.effect:SetText(Truncate(stackPrefix .. tostring(effect.name or "Unknown effect"), 42))
            row.kind:SetText(effect.effectKind == "debuff" and "DEBUFF" or "BUFF")
            row.applications:SetText(tostring(math.floor(tonumber(effect.applications) or 0)))
            row.uptime:SetText(string.format(
                "%s  %.1f%%",
                FormatDuration((tonumber(effect.uptimeMS) or 0) / 1000),
                tonumber(effect.uptimePercent) or 0
            ))
            row.source:SetText(Truncate(effect.sourceName, 32))
            row.target:SetText(Truncate(effect.targetName, 40))
            local color = effect.effectKind == "debuff" and DAMAGE or HEALING
            for _, label in ipairs({ row.effect, row.kind, row.applications, row.uptime, row.source, row.target }) do
                SetColor(label, color)
            end
        else
            row:SetHidden(true)
        end
    end
    board.empty:SetHidden(#filtered > 0)
end

local STAT_COLORS = {
    weaponDamage = HEALING,
    weaponCritical = HEALING,
    physicalPenetration = HEALING,
    maximumStamina = HEALING,
    spellDamage = BLUE,
    spellCritical = BLUE,
    spellPenetration = BLUE,
    maximumMagicka = BLUE,
    healthRecovery = DAMAGE,
    magickaRecovery = BLUE,
    staminaRecovery = HEALING,
}

local function FormatFightStatValue(key, value)
    value = tonumber(value) or 0
    local percentage
    if key == "weaponCritical" or key == "spellCritical" then
        if type(GetCriticalStrikeChance) == "function" then
            local ok, result = pcall(GetCriticalStrikeChance, math.floor(value + 0.5))
            percentage = ok and tonumber(result) or nil
        end
    elseif key == "physicalResistance" or key == "spellResistance" then
        -- At level 50/CP160, 660 resistance is approximately one percentage
        -- point of mitigation, capped at the normal 50% resistance ceiling.
        percentage = math.min(50, math.max(0, value / 660))
    elseif key == "criticalResistance" then
        -- Critical Resistance is exposed as rating. The live conversion is
        -- approximately 68 rating per percentage point of crit-damage reduction.
        percentage = math.max(0, value / 68)
    end
    if percentage then
        return string.format("%.1f%%", percentage), FormatCombatNumber(value)
    end
    return nil, FormatCombatNumber(value)
end

local function RefreshStatsBoard(board, entries)
    entries = type(entries) == "table" and entries or {}
    for index, row in ipairs(board.rows) do
        local entry = entries[index]
        if entry then
            row:SetHidden(false)
            row.name:SetText(entry.label or entry.key or "Unknown stat")
            local color = STAT_COLORS[entry.key] or (board.isDefensive and YELLOW or WHITE)
            SetColor(row.name, color)
            for _, key in ipairs({ "low", "average", "high" }) do
                local cell = row[key]
                local percentText, valueText = FormatFightStatValue(entry.key, entry[key])
                local hasPercentage = percentText ~= nil
                cell.percent:SetHidden(not hasPercentage)
                cell.divider:SetHidden(not hasPercentage)
                cell.value:SetHidden(not hasPercentage)
                cell.full:SetHidden(hasPercentage)
                if hasPercentage then
                    cell.percent:SetText(percentText)
                    cell.value:SetText(valueText)
                    SetColor(cell.percent, color)
                    SetColor(cell.value, color)
                else
                    cell.full:SetText(valueText)
                    SetColor(cell.full, color)
                end
            end
        else
            row:SetHidden(true)
        end
    end
    board.empty:SetHidden(#entries > 0)
end

function Analytics:RefreshUI()
    if not self.ui or PvPerformance.activeModule ~= "analytics" then
        return
    end
    self:SetVisible(true)
    local showDuelingScope = self.activeScope == "dueling"
    local showFightStats = self.activeScope == "fightStats"
    local showHelp = self.activeScope == "help"
    SetTabSelected(self.ui.scopeTab, showDuelingScope)
    SetTabSelected(self.ui.fightStatsTab, showFightStats)
    SetTabSelected(self.ui.helpTab, showHelp)
    self.ui.helpPanel:SetHidden(not showHelp)
    local showDuelSelection = not showHelp
    self.ui.opponentSelector:SetHidden(not showDuelSelection)
    self.ui.saveDuelButton:SetHidden(not showDuelSelection)
    self.ui.deleteDuelButton:SetHidden(not showDuelSelection)
    local duel = self:GetSelectedDuel()
    if duel then
        self.ui.opponentSelectorValue:SetText(self:FormatDuelSelectorText(duel))
    else
        self.ui.opponentSelectorValue:SetText("No recorded duels")
    end
    local analytics = self:GetAnalyticsForDuel(duel)
    local permanentlySaved = duel and duel.analyticsSaved == true and duel.analytics ~= nil
    self.ui.saveDuelButton.label:SetText("SAVE DUEL")
    SetColor(self.ui.saveDuelButton.label, permanentlySaved and HEALING or MUTED)
    local showSources = showDuelingScope and self.CATEGORIES[self.activeTab] ~= nil
    local showStats = showFightStats
    self.ui.sourceTable:SetHidden(not showSources)
    self.ui.offensiveStats:SetHidden(not showStats)
    self.ui.defensiveStats:SetHidden(not showStats)
    if showSources then
        self:RefreshSourceTable()
    elseif showStats then
        local stats = analytics and analytics.buildStats
        RefreshStatsBoard(self.ui.offensiveStats, stats and stats.offensive)
        RefreshStatsBoard(self.ui.defensiveStats, stats and stats.defensive)
    end
end
