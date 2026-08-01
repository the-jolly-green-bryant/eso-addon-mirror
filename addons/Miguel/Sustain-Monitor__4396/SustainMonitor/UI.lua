SustainMonitor = SustainMonitor or {}
local SM = SustainMonitor

local GetGameTimeMilliseconds = GetGameTimeMilliseconds
local mathMax      = math.max
local mathMin      = math.min
local mathFloor    = math.floor
local stringFormat = string.format

---------------------------------------------------------------------------
local PADDING        = 8
local ROW_HEIGHT     = 20
local ROW_SPACING    = 3
local BAR_WIDTH      = 70
local BAR_HEIGHT     = 10
local GRAPH_HEIGHT   = 25
local GRAPH_BARS     = 60

local LABEL_W        = 60
local RATE_W         = 80
local TIME_W         = 70
local GAP            = 6

local CLABEL_W       = 22
local CRATE_W        = 70
local CTIME_W        = 55

local COMBAT_ROW_H   = 30
local COMBAT_FONT    = "$(BOLD_FONT)|$(KB_20)|soft-shadow-thick"
local COMBAT_LABEL_W = 70
local COMBAT_RATE_W  = 100
local COMBAT_TIME_W  = 80

-- Colors
local RESOURCE_COLORS = {}
local COLOR_GREEN   = { 0.2, 0.8, 0.2, 1 }
local COLOR_WHITE   = { 1,   1,   1,   1 }
local COLOR_DIM     = { 0.5, 0.5, 0.5, 1 }

local function GetColorYellow()
    local sv = SM.savedVars
    return (sv and sv.colorWarningYellow) or { 1, 0.84, 0, 1 }
end
local function GetColorOrange()
    local sv = SM.savedVars
    return (sv and sv.colorWarningOrange) or { 1, 0.55, 0, 1 }
end
local function GetColorRed()
    local sv = SM.savedVars
    return (sv and sv.colorWarningRed) or { 1, 0, 0, 1 }
end
local function GetColorPotion()
    local sv = SM.savedVars
    return (sv and sv.colorPotion) or { 0, 0.75, 1, 1 }
end
local function GetColorPotionReady()
    local sv = SM.savedVars
    return (sv and sv.colorPotionReady) or { 0.2, 0.8, 0.2, 1 }
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
local hudControl     = nil
local rows           = {}
local potionRow      = nil
local actionPrompt   = nil
local isHUDVisible   = false
local hudFragment    = nil
local hideTimestamp   = 0
local promptHideTime = 0
local promptBlinking = false
local promptBlinkState = true
local promptBlinkTimer = 0
local PROMPT_BLINK_MS  = 300
local historyTimer   = 0
local rebuildCount   = 0    -- incremented on each rebuild to create unique names

---------------------------------------------------------------------------
---------------------------------------------------------------------------
local function TopLevelName(base)
    if rebuildCount > 0 then
        return base .. rebuildCount
    end
    return base
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
local function CreateLabel(parent, width, height, align, font)
    local label = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    label:SetFont(font or "ZoFontGame")
    label:SetColor(1, 1, 1, 1)
    label:SetDimensions(width, height or ROW_HEIGHT)
    label:SetHorizontalAlignment(align or TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetText("")
    return label
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
local function ComputeDimensions(sv)
    local style   = sv.displayStyle or "simple"
    local compact = sv.compactMode and style == "simple"

    local rowCount = 0
    if sv.showMagicka then rowCount = rowCount + 1 end
    if sv.showStamina then rowCount = rowCount + 1 end
    if sv.showHealth  then rowCount = rowCount + 1 end
    local potionRows = sv.showPotion and 1 or 0
    if rowCount == 0 then rowCount = 1 end

    local width, height

    if style == "combat" then
        height = PADDING * 2 + (rowCount + potionRows) * COMBAT_ROW_H + (rowCount + potionRows - 1) * ROW_SPACING
        width  = PADDING * 2 + COMBAT_LABEL_W + GAP + COMBAT_RATE_W + GAP + COMBAT_TIME_W
    elseif style == "analytical" then
        local graphRows = sv.showGraph and rowCount or 0
        local totalRows = rowCount + potionRows
        height = PADDING * 2 + totalRows * ROW_HEIGHT + (totalRows - 1) * ROW_SPACING
        if sv.showGraph then
            height = height + graphRows * (GRAPH_HEIGHT + ROW_SPACING)
        end
        local barExtra = sv.showBars and (GAP + BAR_WIDTH) or 0
        local timeExtra = sv.showRestzeit and (GAP + TIME_W) or 0
        local graphWidth = sv.showGraph and (GRAPH_BARS * 2 + GAP) or 0
        width = PADDING * 2 + LABEL_W + GAP + RATE_W + timeExtra + barExtra
        if graphWidth + PADDING * 2 > width then
            width = graphWidth + PADDING * 2
        end
    elseif compact then
        height = PADDING * 2 + (rowCount + potionRows) * ROW_HEIGHT + (rowCount + potionRows - 1) * ROW_SPACING
        width  = PADDING * 2 + CLABEL_W + GAP + CRATE_W + GAP + CTIME_W
    else
        height = PADDING * 2 + (rowCount + potionRows) * ROW_HEIGHT + (rowCount + potionRows - 1) * ROW_SPACING
        local barExtra = sv.showBars and (GAP + BAR_WIDTH) or 0
        local timeExtra = sv.showRestzeit and (GAP + TIME_W) or 0
        width = PADDING * 2 + LABEL_W + GAP + RATE_W + timeExtra + barExtra
    end

    return width, height
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
function SM.CreateHUD()
    if hudControl then return end

    local sv = SM.savedVars
    local L  = SM.L

    RESOURCE_COLORS[POWERTYPE_MAGICKA] = { 0.4, 0.5, 1, 1 }
    RESOURCE_COLORS[POWERTYPE_STAMINA] = { 0.2, 0.8, 0.2, 1 }
    RESOURCE_COLORS[POWERTYPE_HEALTH]  = { 0.8, 0.2, 0.2, 1 }

    local width, height = ComputeDimensions(sv)
    local style = sv.displayStyle or "simple"

    -- Top-level window (unique name per rebuild)
    hudControl = WINDOW_MANAGER:CreateTopLevelWindow(TopLevelName("SustainMonitorHUD"))
    hudControl:SetDimensions(width, height)
    hudControl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.posX, sv.posY)
    hudControl:SetMovable(not sv.locked)
    hudControl:SetMouseEnabled(not sv.locked)
    hudControl:SetClampedToScreen(true)
    hudControl:SetDrawLayer(DL_OVERLAY)
    hudControl:SetDrawTier(DT_LOW)

    hudControl:SetHandler("OnMoveStop", function(self)
        sv.posX = self:GetLeft()
        sv.posY = self:GetTop()
    end)

    -- Background (anonymous)
    local bg = WINDOW_MANAGER:CreateControl(nil, hudControl, CT_BACKDROP)
    bg:SetAnchor(TOPLEFT, hudControl, TOPLEFT, 0, 0)
    bg:SetAnchor(BOTTOMRIGHT, hudControl, BOTTOMRIGHT, 0, 0)
    bg:SetCenterColor(0, 0, 0, 0.7)
    bg:SetEdgeColor(0, 0, 0, 0)

    -- Create resource rows
    local yOffset = PADDING
    local rowOrder = { POWERTYPE_MAGICKA, POWERTYPE_STAMINA, POWERTYPE_HEALTH }
    local showFlags = {
        [POWERTYPE_MAGICKA] = sv.showMagicka,
        [POWERTYPE_STAMINA] = sv.showStamina,
        [POWERTYPE_HEALTH]  = sv.showHealth,
    }
    local names = {
        [POWERTYPE_MAGICKA] = (sv.compactMode and style == "simple") and L.MAGICKA_SHORT or L.MAGICKA,
        [POWERTYPE_STAMINA] = (sv.compactMode and style == "simple") and L.STAMINA_SHORT or L.STAMINA,
        [POWERTYPE_HEALTH]  = (sv.compactMode and style == "simple") and L.HEALTH_SHORT  or L.HEALTH,
    }

    for _, powerType in ipairs(rowOrder) do
        if showFlags[powerType] then
            local rowData
            if style == "combat" then
                rowData = SM.CreateCombatRow(powerType, yOffset, names[powerType])
                yOffset = yOffset + COMBAT_ROW_H + ROW_SPACING
            else
                rowData = SM.CreateResourceRow(powerType, yOffset, names[powerType], sv)
                yOffset = yOffset + ROW_HEIGHT + ROW_SPACING
                if style == "analytical" and sv.showGraph then
                    rowData.graph = SM.CreateGraph(powerType, yOffset, RESOURCE_COLORS[powerType])
                    yOffset = yOffset + GRAPH_HEIGHT + ROW_SPACING
                end
            end
            rows[powerType] = rowData
        end
    end

    if sv.showPotion then
        if style == "combat" then
            potionRow = SM.CreateCombatPotionRow(yOffset)
        else
            potionRow = SM.CreatePotionRow(yOffset, sv)
        end
    end

    hudControl:SetScale(sv.scale or 1.0)

    hudFragment = ZO_HUDFadeSceneFragment:New(hudControl)
    HUD_SCENE:AddFragment(hudFragment)
    HUD_UI_SCENE:AddFragment(hudFragment)

    local originalShow = hudFragment.Show
    hudFragment.Show = function(self, ...)
        originalShow(self, ...)
        if not isHUDVisible then
            hudControl:SetHidden(true)
        end
    end

    SM.CreateActionPrompt(style)

    if sv.hideOutOfCombat and not SM.IsInCombat() then
        hudControl:SetHidden(true)
        isHUDVisible = false
    else
        hudControl:SetHidden(false)
        isHUDVisible = true
    end

    EVENT_MANAGER:RegisterForUpdate(SM.name .. "UIUpdate", 100, SM.OnPeriodicUpdate)
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
function SM.CreateResourceRow(powerType, yOffset, labelText, sv)
    local compact = sv.compactMode and (sv.displayStyle or "simple") == "simple"
    local color   = RESOURCE_COLORS[powerType] or COLOR_WHITE

    local row = WINDOW_MANAGER:CreateControl(nil, hudControl, CT_CONTROL)
    row:SetDimensions(hudControl:GetWidth() - PADDING * 2, ROW_HEIGHT)
    row:SetAnchor(TOPLEFT, hudControl, TOPLEFT, PADDING, yOffset)

    local labelW = compact and CLABEL_W or LABEL_W
    local nameLabel = CreateLabel(row, labelW, ROW_HEIGHT, TEXT_ALIGN_LEFT, "ZoFontGameSmall")
    nameLabel:SetAnchor(LEFT, row, LEFT, 0, 0)
    nameLabel:SetColor(unpack(color))
    nameLabel:SetText(labelText)

    local rateW = compact and CRATE_W or RATE_W
    local rateLabel = CreateLabel(row, rateW, ROW_HEIGHT, TEXT_ALIGN_RIGHT, "ZoFontGameSmall")
    rateLabel:SetAnchor(LEFT, nameLabel, RIGHT, GAP, 0)
    rateLabel:SetText(SM.L.NO_DATA)

    local timeLabel = nil
    local lastAnchor = rateLabel
    if sv.showRestzeit then
        local timeW = compact and CTIME_W or TIME_W
        timeLabel = CreateLabel(row, timeW, ROW_HEIGHT, TEXT_ALIGN_RIGHT, "ZoFontGameSmall")
        timeLabel:SetAnchor(LEFT, rateLabel, RIGHT, GAP, 0)
        lastAnchor = timeLabel
    end

    local barBG, barFill = nil, nil
    if sv.showBars and not compact then
        barBG = WINDOW_MANAGER:CreateControl(nil, row, CT_BACKDROP)
        barBG:SetDimensions(BAR_WIDTH, BAR_HEIGHT)
        barBG:SetAnchor(LEFT, lastAnchor, RIGHT, GAP, 0)
        barBG:SetCenterColor(0.12, 0.12, 0.12, 0.8)
        barBG:SetEdgeColor(0.3, 0.3, 0.3, 0.6)

        barFill = WINDOW_MANAGER:CreateControl(nil, barBG, CT_BACKDROP)
        barFill:SetAnchor(TOPLEFT, barBG, TOPLEFT, 1, 1)
        barFill:SetDimensions(BAR_WIDTH - 2, BAR_HEIGHT - 2)
        barFill:SetCenterColor(unpack(color))
        barFill:SetEdgeColor(0, 0, 0, 0)
    end

    return {
        row = row, name = nameLabel, rate = rateLabel, time = timeLabel,
        barBG = barBG, barFill = barFill, graph = nil, color = color,
    }
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
function SM.CreateCombatRow(powerType, yOffset, labelText)
    local color = RESOURCE_COLORS[powerType] or COLOR_WHITE

    local row = WINDOW_MANAGER:CreateControl(nil, hudControl, CT_CONTROL)
    row:SetDimensions(hudControl:GetWidth() - PADDING * 2, COMBAT_ROW_H)
    row:SetAnchor(TOPLEFT, hudControl, TOPLEFT, PADDING, yOffset)

    local nameLabel = CreateLabel(row, COMBAT_LABEL_W, COMBAT_ROW_H, TEXT_ALIGN_LEFT, COMBAT_FONT)
    nameLabel:SetAnchor(LEFT, row, LEFT, 0, 0)
    nameLabel:SetColor(unpack(color))
    nameLabel:SetText(labelText)

    local rateLabel = CreateLabel(row, COMBAT_RATE_W, COMBAT_ROW_H, TEXT_ALIGN_RIGHT, COMBAT_FONT)
    rateLabel:SetAnchor(LEFT, nameLabel, RIGHT, GAP, 0)
    rateLabel:SetText(SM.L.NO_DATA)

    local timeLabel = CreateLabel(row, COMBAT_TIME_W, COMBAT_ROW_H, TEXT_ALIGN_RIGHT, COMBAT_FONT)
    timeLabel:SetAnchor(LEFT, rateLabel, RIGHT, GAP, 0)

    return {
        row = row, name = nameLabel, rate = rateLabel, time = timeLabel,
        barBG = nil, barFill = nil, graph = nil, color = color,
    }
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
function SM.CreatePotionRow(yOffset, sv)
    local compact = sv.compactMode and (sv.displayStyle or "simple") == "simple"
    local potionSize = sv.potionFontSize or 22
    local potionFont = stringFormat("$(BOLD_FONT)|%d|soft-shadow-thick", potionSize)

    local row = WINDOW_MANAGER:CreateControl(nil, hudControl, CT_CONTROL)
    row:SetDimensions(hudControl:GetWidth() - PADDING * 2, ROW_HEIGHT)
    row:SetAnchor(TOPLEFT, hudControl, TOPLEFT, PADDING, yOffset)

    local labelW = compact and CLABEL_W or LABEL_W
    local label = CreateLabel(row, labelW, ROW_HEIGHT, TEXT_ALIGN_LEFT, potionFont)
    label:SetAnchor(LEFT, row, LEFT, 0, 0)
    label:SetColor(unpack(GetColorPotion()))
    label:SetText(SM.L.POTION)

    local timerW = compact and CRATE_W or RATE_W
    local timer = CreateLabel(row, timerW, ROW_HEIGHT, TEXT_ALIGN_RIGHT, potionFont)
    timer:SetAnchor(LEFT, label, RIGHT, GAP, 0)

    return { row = row, label = label, timer = timer }
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
function SM.CreateCombatPotionRow(yOffset)
    local sv = SM.savedVars
    local potionSize = (sv and sv.potionFontSize) or 22
    local potionFont = stringFormat("$(BOLD_FONT)|%d|soft-shadow-thick", potionSize)

    local row = WINDOW_MANAGER:CreateControl(nil, hudControl, CT_CONTROL)
    row:SetDimensions(hudControl:GetWidth() - PADDING * 2, COMBAT_ROW_H)
    row:SetAnchor(TOPLEFT, hudControl, TOPLEFT, PADDING, yOffset)

    local label = CreateLabel(row, COMBAT_LABEL_W, COMBAT_ROW_H, TEXT_ALIGN_LEFT, potionFont)
    label:SetAnchor(LEFT, row, LEFT, 0, 0)
    label:SetColor(unpack(GetColorPotion()))
    label:SetText(SM.L.POTION)

    local timer = CreateLabel(row, COMBAT_RATE_W, COMBAT_ROW_H, TEXT_ALIGN_RIGHT, potionFont)
    timer:SetAnchor(LEFT, label, RIGHT, GAP, 0)

    return { row = row, label = label, timer = timer }
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
function SM.CreateGraph(powerType, yOffset, color)
    local wm     = WINDOW_MANAGER
    local graphW = GRAPH_BARS * 2
    local barW   = 2

    local container = wm:CreateControl(nil, hudControl, CT_CONTROL)
    container:SetDimensions(graphW, GRAPH_HEIGHT)
    container:SetAnchor(TOPLEFT, hudControl, TOPLEFT, PADDING, yOffset)

    local bg = wm:CreateControl(nil, container, CT_BACKDROP)
    bg:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
    bg:SetAnchor(BOTTOMRIGHT, container, BOTTOMRIGHT, 0, 0)
    bg:SetCenterColor(0.05, 0.05, 0.05, 0.5)
    bg:SetEdgeColor(0.2, 0.2, 0.2, 0.3)

    local bars = {}
    for i = 1, GRAPH_BARS do
        local bar = wm:CreateControl(nil, container, CT_BACKDROP)
        bar:SetDimensions(barW - 1, 1)
        bar:SetAnchor(BOTTOMLEFT, container, BOTTOMLEFT, (i - 1) * barW, 0)
        bar:SetCenterColor(color[1], color[2], color[3], 0.7)
        bar:SetEdgeColor(0, 0, 0, 0)
        bar:SetHidden(true)
        bars[i] = bar
    end

    local fillColumns = {}
    for i = 1, GRAPH_BARS do
        local fillTop = wm:CreateControl(nil, container, CT_BACKDROP)
        fillTop:SetDimensions(barW, 1)
        fillTop:SetAnchor(BOTTOMLEFT, container, BOTTOMLEFT, (i - 1) * barW, 0)
        fillTop:SetCenterColor(color[1], color[2], color[3], 0.4)
        fillTop:SetEdgeColor(0, 0, 0, 0)
        fillTop:SetHidden(true)

        local fillBot = wm:CreateControl(nil, container, CT_BACKDROP)
        fillBot:SetDimensions(barW, 1)
        fillBot:SetAnchor(BOTTOMLEFT, container, BOTTOMLEFT, (i - 1) * barW, 0)
        fillBot:SetCenterColor(color[1], color[2], color[3], 0.12)
        fillBot:SetEdgeColor(0, 0, 0, 0)
        fillBot:SetHidden(true)

        fillColumns[i] = { top = fillTop, bot = fillBot }
    end

    local lineDots = {}
    for i = 1, GRAPH_BARS do
        local dot = wm:CreateControl(nil, container, CT_BACKDROP)
        dot:SetDimensions(barW, 2)
        dot:SetAnchor(BOTTOMLEFT, container, BOTTOMLEFT, (i - 1) * barW, 0)
        dot:SetCenterColor(color[1], color[2], color[3], 1)
        dot:SetEdgeColor(0, 0, 0, 0)
        dot:SetDrawLevel(2)
        dot:SetHidden(true)
        lineDots[i] = dot
    end

    return {
        container    = container,
        bg           = bg,
        color        = color,
        bars         = bars,
        lineDots     = lineDots,
        fillColumns  = fillColumns,
    }
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
function SM.CreateActionPrompt(style)
    if actionPrompt then return end

    local sv = SM.savedVars
    local fontSize = (sv and sv.alertFontSize) or 28
    local promptFont = stringFormat("$(BOLD_FONT)|%d|soft-shadow-thick", fontSize)

    local prompt = WINDOW_MANAGER:CreateTopLevelWindow(TopLevelName("SustainMonitorPrompt"))
    prompt:SetDimensions(400, 50)
    prompt:SetAnchor(CENTER, GuiRoot, CENTER, 0, 180)
    prompt:SetDrawLayer(DL_OVERLAY)
    prompt:SetDrawTier(DT_LOW)
    prompt:SetHidden(true)

    local label = WINDOW_MANAGER:CreateControl(nil, prompt, CT_LABEL)
    label:SetFont(promptFont)
    label:SetColor(1, 1, 0, 1)
    label:SetDimensions(400, 50)
    label:SetAnchor(CENTER, prompt, CENTER, 0, 0)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    actionPrompt = { control = prompt, label = label }
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
function SM.ShowActionPrompt(text, color, duration, blink)
    if not actionPrompt then return end
    actionPrompt.label:SetText(text)
    actionPrompt.label:SetColor(unpack(color))
    actionPrompt.control:SetAlpha(1)
    actionPrompt.control:SetHidden(false)
    promptHideTime = GetGameTimeMilliseconds() + (duration or 2000)
    promptBlinking = blink or false
    promptBlinkState = true
    promptBlinkTimer = GetGameTimeMilliseconds()
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
function SM.GetRowControl(powerType)
    local rowData = rows[powerType]
    return rowData and rowData.row
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
function SM.UpdateResourceUI(powerType)
    local rowData = rows[powerType]
    if not rowData then return end
    if not hudControl or hudControl:IsHidden() then return end

    local sv  = SM.savedVars
    local res = SM.GetResourceData(powerType)
    if not res then return end

    local style   = sv.displayStyle or "simple"
    local compact = sv.compactMode and style == "simple"
    local color   = SM.GetWarningColor(res.timeToEmpty, res.burnRate)

    if res.lastTime > 0 then
        rowData.rate:SetText(SM.FormatRate(res.burnRate, compact))
        rowData.rate:SetColor(unpack(color))
    else
        rowData.rate:SetText(SM.L.NO_DATA)
        rowData.rate:SetColor(unpack(COLOR_DIM))
    end

    if rowData.time then
        if res.lastTime > 0 then
            local casts = sv.showCastsRemaining and res.castsRemaining or nil
            rowData.time:SetText(SM.FormatTime(res.timeToEmpty, casts))
            rowData.time:SetColor(unpack(color))
        else
            rowData.time:SetText("")
        end
    end

    if rowData.barFill and rowData.barBG then
        local pct = mathMax(0, mathMin(1, res.currentPercent / 100))
        rowData.barFill:SetDimensions(mathMax(0, (BAR_WIDTH - 2) * pct), BAR_HEIGHT - 2)
    end
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
function SM.UpdateGraphs()
    local sv = SM.savedVars
    if not sv or (sv.displayStyle or "simple") ~= "analytical" then return end
    if not sv.showGraph then return end

    local graphStyle = sv.graphStyle or "line"
    local barW = 2

    for powerType, rowData in pairs(rows) do
        local g = rowData.graph
        local history = g and SM.GetHistory(powerType)
        if g and history then
            local count = #history
            local graphH = GRAPH_HEIGHT

            if graphStyle == "line" then
                for _, bar in ipairs(g.bars or {}) do bar:SetHidden(true) end

                for i = 1, GRAPH_BARS do
                    local vi = count - GRAPH_BARS + i
                    local pct = 0
                    if vi > 0 and vi <= count then
                        pct = mathMax(0, mathMin(100, history[vi])) / 100
                    end

                    local totalH = mathMax(0, pct * (graphH - 2))
                    local fc = g.fillColumns and g.fillColumns[i]
                    local dot = g.lineDots and g.lineDots[i]

                    if pct > 0 and totalH >= 1 then
                        local halfH = mathMax(1, totalH / 2)
                        if fc then
                            fc.top:ClearAnchors()
                            fc.top:SetAnchor(BOTTOMLEFT, g.container, BOTTOMLEFT, (i - 1) * barW, -halfH)
                            fc.top:SetDimensions(barW, halfH)
                            fc.top:SetHidden(false)

                            fc.bot:ClearAnchors()
                            fc.bot:SetAnchor(BOTTOMLEFT, g.container, BOTTOMLEFT, (i - 1) * barW, 0)
                            fc.bot:SetDimensions(barW, halfH)
                            fc.bot:SetHidden(false)
                        end
                        if dot then
                            dot:ClearAnchors()
                            dot:SetAnchor(BOTTOMLEFT, g.container, BOTTOMLEFT, (i - 1) * barW, -totalH)
                            dot:SetDimensions(barW, 2)
                            dot:SetHidden(false)
                        end
                    else
                        if fc then
                            fc.top:SetHidden(true)
                            fc.bot:SetHidden(true)
                        end
                        if dot then dot:SetHidden(true) end
                    end
                end
            else
                for _, dot in ipairs(g.lineDots or {}) do dot:SetHidden(true) end
                for _, fc in ipairs(g.fillColumns or {}) do
                    if fc.top then fc.top:SetHidden(true) end
                    if fc.bot then fc.bot:SetHidden(true) end
                end

                for i = 1, GRAPH_BARS do
                    local bar = g.bars and g.bars[i]
                    if bar then
                        local vi = count - GRAPH_BARS + i
                        if vi > 0 and vi <= count then
                            local pct = mathMax(0, mathMin(100, history[vi])) / 100
                            bar:SetDimensions(1, mathMax(1, pct * (graphH - 2)))
                            bar:SetHidden(false)
                        else
                            bar:SetHidden(true)
                        end
                    end
                end
            end
        end
    end
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
function SM.GetWarningColor(timeToEmpty, burnRate)
    if burnRate >= 0 then return COLOR_GREEN end

    local sv = SM.savedVars
    if not sv or not sv.warningEnabled then return COLOR_WHITE end

    if timeToEmpty >= 0 then
        if timeToEmpty < sv.warningThreshold3 then return GetColorRed()
        elseif timeToEmpty < sv.warningThreshold2 then return GetColorOrange()
        elseif timeToEmpty < sv.warningThreshold1 then return GetColorYellow()
        end
    end

    return COLOR_WHITE
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
function SM.UpdatePotionUI(remaining)
    if not potionRow then return end

    remaining = remaining or SM.GetPotionCooldownRemaining()

    if remaining and remaining > 0 then
        potionRow.timer:SetText(stringFormat("%.1fs", remaining / 1000))
        potionRow.timer:SetColor(unpack(COLOR_WHITE))
        potionRow.label:SetColor(unpack(COLOR_DIM))
    else
        local sv = SM.savedVars
        local focusSetting = sv and sv.resourceFocus or "auto"
        local focusMismatch = false

        if focusSetting ~= "auto" and focusSetting ~= "all" then
            local focusPT = SM.GetFocusedResource and SM.GetFocusedResource()
            if focusPT and SM.PotionRestoresResource then
                local restores = SM.PotionRestoresResource(focusPT)
                if restores == nil then
                    focusMismatch = true
                end
            end
        end

        if focusMismatch then
            potionRow.timer:SetText(SM.L.FOCUS_MISMATCH or "Fokus!")
            potionRow.timer:SetColor(1, 0.2, 0.2, 1)
            potionRow.label:SetColor(1, 0.2, 0.2, 1)
        else
            potionRow.timer:SetText(SM.L.READY)
            local highlight = false
            for _, pt in ipairs({POWERTYPE_MAGICKA, POWERTYPE_STAMINA, POWERTYPE_HEALTH}) do
                if SM.ShouldAlertPotion and SM.ShouldAlertPotion(pt) then
                    highlight = true
                    break
                end
            end
            if highlight then
                potionRow.timer:SetColor(unpack(GetColorPotion()))
                potionRow.label:SetColor(unpack(GetColorPotion()))
            else
                potionRow.timer:SetColor(unpack(GetColorPotionReady()))
                potionRow.label:SetColor(unpack(GetColorPotion()))
            end
        end
    end
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
function SM.ShowHUD()
    if not hudControl then return end
    local sv = SM.savedVars
    if not sv or not sv.enabled then return end
    hideTimestamp = 0
    hudControl:SetAlpha(1)
    hudControl:SetHidden(false)
    isHUDVisible = true
end

function SM.HideHUD()
    if not hudControl then return end
    hudControl:SetHidden(true)
    isHUDVisible = false
    if actionPrompt then actionPrompt.control:SetHidden(true) end
end

function SM.HideHUDDelayed()
    if not hudControl then return end
    local sv = SM.savedVars
    if not sv or not sv.hideOutOfCombat then return end
    hideTimestamp = GetGameTimeMilliseconds() + (sv.fadeDelay or 3) * 1000
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
function SM.OnPeriodicUpdate()
    local sv = SM.savedVars
    if not sv or not sv.enabled then return end

    local now = GetGameTimeMilliseconds()

    local potionRemaining = SM.GetPotionCooldownRemaining and SM.GetPotionCooldownRemaining() or 0
    if potionRow and isHUDVisible then SM.UpdatePotionUI(potionRemaining) end
    if SM.UpdatePotionState then SM.UpdatePotionState(potionRemaining) end
    if SM.CheckPotionAlert then SM.CheckPotionAlert(potionRemaining) end
    if SM.CheckHeavyAttack then SM.CheckHeavyAttack(potionRemaining) end
    if SM.UpdateFlash then SM.UpdateFlash() end

    if now - historyTimer >= 500 then
        historyTimer = now
        SM.RecordHistory()
        SM.UpdateGraphs()
    end

    if promptBlinking and actionPrompt and not actionPrompt.control:IsHidden() then
        if now - promptBlinkTimer >= PROMPT_BLINK_MS then
            promptBlinkState = not promptBlinkState
            promptBlinkTimer = now
            actionPrompt.control:SetAlpha(promptBlinkState and 1 or 0.15)
        end
    end

    if promptHideTime > 0 and now >= promptHideTime then
        promptHideTime = 0
        promptBlinking = false
        if actionPrompt then actionPrompt.control:SetHidden(true) end
    end

    if hideTimestamp > 0 and now >= hideTimestamp then
        hideTimestamp = 0
        SM.HideHUD()
    end
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
function SM.RebuildHUD()
    if hudControl then
        EVENT_MANAGER:UnregisterForUpdate(SM.name .. "UIUpdate")
        if hudFragment then
            HUD_SCENE:RemoveFragment(hudFragment)
            HUD_UI_SCENE:RemoveFragment(hudFragment)
            hudFragment = nil
        end
        hudControl:SetHidden(true)
        hudControl = nil
        rows = {}
        potionRow = nil
    end
    if actionPrompt then
        actionPrompt.control:SetHidden(true)
        actionPrompt = nil
    end
    rebuildCount = rebuildCount + 1
    SM.CreateHUD()
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
function SM.SetHUDScale(scale)
    if hudControl then hudControl:SetScale(scale) end
end

function SM.SetHUDLocked(locked)
    if hudControl then
        hudControl:SetMovable(not locked)
        hudControl:SetMouseEnabled(not locked)
    end
end

function SM.ResetHUDPosition()
    local sv = SM.savedVars
    if not sv then return end
    sv.posX = 400
    sv.posY = 800
    if hudControl then
        hudControl:ClearAnchors()
        hudControl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.posX, sv.posY)
    end
end

function SM.ToggleHUD()
    if not hudControl then return end
    if hudControl:IsHidden() then SM.ShowHUD() else SM.HideHUD() end
end
