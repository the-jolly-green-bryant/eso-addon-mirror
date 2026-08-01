AntiDK = AntiDK or {}
AntiDK.ControlCounter = 0

local DEFAULT_CENTER_OFFSET_X = 0
local DEFAULT_CENTER_OFFSET_Y = -90

local function Clamp(value, minValue, maxValue)
    if value < minValue then return minValue end
    if value > maxValue then return maxValue end
    return value
end

local function SanitizeControlName(value)
    return tostring(value):gsub("[^%w_]", "_")
end

local function GetConfiguredScale()
    local rawScale = (AntiDK.settings and AntiDK.settings.uiScale) or (AntiDK.settings and AntiDK.settings.scale) or 1
    return Clamp(rawScale, 0.7, 1.6)
end

local function IsBackdropEnabled()
    if not AntiDK.settings then return false end
    return AntiDK.settings.showBackdrop == true
end

local function GetBackdropOpacity()
    if not AntiDK.settings then return 0.6 end
    return Clamp(AntiDK.settings.backdropOpacity or 0.6, 0.1, 1)
end

local function IsAutoHideEnabled()
    if not AntiDK.settings then return true end
    return AntiDK.settings.autoHideEnabled ~= false
end

local function GetAutoHideDelay()
    if not AntiDK.settings then return 0 end
    return Clamp(AntiDK.settings.autoHideDelay or 0, 0, 30)
end

local function GetStunWarningColor()
    local stunColor = AntiDK.settings and AntiDK.settings.stunhex
    if stunColor and type(stunColor.r) == "number" and type(stunColor.g) == "number" and type(stunColor.b) == "number" then
        return stunColor.r, stunColor.g, stunColor.b
    end

    return 0.97, 0.83, 0.24
end

local function FormatPlayerName(playerName)
    if type(ZO_strformat) == "function" then
        return ZO_strformat("<<C:1>>", playerName)
    end
    if type(zo_strformat) == "function" then
        return zo_strformat("<<C:1>>", playerName)
    end
    return tostring(playerName or "Unknown")
end

local function GetConfiguredAnchorOffsets()
    local x = (AntiDK.settings and AntiDK.settings.posX)
    local y = (AntiDK.settings and AntiDK.settings.posY)

    if type(x) ~= "number" then x = DEFAULT_CENTER_OFFSET_X end
    if type(y) ~= "number" then y = DEFAULT_CENTER_OFFSET_Y end

    return x, y
end

local function ToHexChannel(value)
    local channel = math.floor(Clamp((value or 0) * 255, 0, 255) + 0.5)
    return string.format("%02X", channel)
end

local function ColorizeText(r, g, b, text)
    return string.format("|c%s%s%s%s|r", ToHexChannel(r), ToHexChannel(g), ToHexChannel(b), tostring(text or ""))
end

local SRUI_THEME = {
    frameBg = { 0.00, 0.00, 0.00, 0.00 },
    frameEdge = { 0.00, 0.00, 0.00, 0.00 },
    titleBg = { 0.00, 0.00, 0.00, 0.00 },
    titleEdge = { 0.00, 0.00, 0.00, 0.00 },
    panelBg = { 0.00, 0.00, 0.00, 0.00 },
    panelEdge = { 0.00, 0.00, 0.00, 0.00 },
    headerBg = { 0.00, 0.00, 0.00, 0.00 },
    headerEdge = { 0.00, 0.00, 0.00, 0.00 },
    rowBg = { 0.00, 0.00, 0.00, 0.00 },
    rowEdge = { 0.00, 0.00, 0.00, 0.00 },
}

local ABILITY_ICONS = {
    PowerLash = GetAbilityIcon(262658),
    MoltenWhip = GetAbilityIcon(262658),
    ShatteringRocks = GetAbilityIcon(32678),
    CorrosiveArmor = GetAbilityIcon(17878),
    Fossilize = GetAbilityIcon(32685),
}

local function BuildAbilityRows(abilities)
    local rows = {}
    local priority = {
        PowerLash = 1,
        MoltenWhip = 2,
        ShatteringRocks = 3,
        CorrosiveArmor = 4,
        Fossilize = 5,
    }

    if abilities.PowerLash then
        local duration = AntiDK:GetDurationRemaining(abilities.PowerLash)
        if duration > 0 then
            table.insert(rows, {
                key = "PowerLash",
                label = "Power Lash",
                duration = duration,
                maxDuration = abilities.PowerLash.duration or 20,
                stacks = abilities.PowerLash.stacks,
                color = { 0.90, 0.32, 0.30, 0.92 },
                icon = ABILITY_ICONS.PowerLash,
            })
        end
    end

    if abilities.MoltenWhip then
        local duration = AntiDK:GetDurationRemaining(abilities.MoltenWhip)
        if duration > 0 then
            table.insert(rows, {
                key = "MoltenWhip",
                label = "Molten Whip",
                duration = duration,
                maxDuration = abilities.MoltenWhip.duration or 10,
                stacks = abilities.MoltenWhip.stacks,
                color = { 0.88, 0.49, 0.25, 0.92 },
                icon = ABILITY_ICONS.MoltenWhip,
            })
        end
    end

    if abilities.ShatteringRocks then
        local delay = AntiDK:GetDelayRemaining(abilities.ShatteringRocks)
        local duration = delay > 0 and delay or AntiDK:GetDurationRemaining(abilities.ShatteringRocks)
        if duration > 0 then
            table.insert(rows, {
                key = "ShatteringRocks",
                label = "Shattering Rocks",
                duration = duration,
                maxDuration = delay > 0 and 1 or (abilities.ShatteringRocks.duration or 1),
                stacks = nil,
                color = { 0.83, 0.64, 0.34, 0.92 },
                icon = ABILITY_ICONS.ShatteringRocks,
            })
        end
    end

    if abilities.CorrosiveArmor then
        local duration = AntiDK:GetDurationRemaining(abilities.CorrosiveArmor)
        if duration > 0 then
            table.insert(rows, {
                key = "CorrosiveArmor",
                label = "Corrosive Armor",
                duration = duration,
                maxDuration = abilities.CorrosiveArmor.duration or 10,
                stacks = abilities.CorrosiveArmor.stacks,
                color = { 0.44, 0.78, 0.52, 0.92 },
                icon = ABILITY_ICONS.CorrosiveArmor,
            })
        end
    end

    if abilities.Fossilize then
        local duration = AntiDK:GetDurationRemaining(abilities.Fossilize)
        if duration > 0 then
            table.insert(rows, {
                key = "Fossilize",
                label = "Fossilize",
                duration = duration,
                maxDuration = abilities.Fossilize.duration or 1,
                stacks = nil,
                color = { 0.86, 0.75, 0.33, 0.92 },
                icon = ABILITY_ICONS.Fossilize,
            })
        end
    end

    table.sort(rows, function(a, b)
        return (priority[a.key] or 100) < (priority[b.key] or 100)
    end)

    return rows
end

local function BuildPlayerDebuffRows()
    local rows = {}
    local warningR, warningG, warningB = GetStunWarningColor()
    local now = GetGameTimeSeconds()

    for _, debuff in pairs(AntiDK.PlayerDebuffs or {}) do
        local duration = AntiDK:GetDurationRemaining(debuff)
        if duration > 0 then
            local rollReady = debuff.rollReadyTime and now >= debuff.rollReadyTime
            local rollRemaining = debuff.rollReadyTime and math.max(0, debuff.rollReadyTime - now) or 0
            local rollText = rollReady and "ROLL NOW" or string.format("ROLL IN %.1fs", rollRemaining)
            local rowLabel = ColorizeText(warningR, warningG, warningB, rollText)
            local timerText = string.format("%.1fs", duration)

            if AntiDK.settings and AntiDK.settings.showStunDodge == false then
                rowLabel = debuff.name
            end

            table.insert(rows, {
                key = debuff.key,
                label = rowLabel,
                labelIsRichText = true,
                sourceText = nil,
                duration = duration,
                maxDuration = debuff.duration or 1,
                stacks = nil,
                color = rollReady and { warningR, warningG, warningB, 0.95 } or (debuff.key == "ShatteringRocks" and { 0.83, 0.64, 0.34, 0.92 } or { 0.86, 0.75, 0.33, 0.92 }),
                icon = ABILITY_ICONS[debuff.key],
                statusText = timerText,
                statusColor = { 0.80, 0.89, 0.98, 0.95 },
            })
        end
    end

    table.sort(rows, function(a, b)
        local priority = {
            ShatteringRocks = 1,
            Fossilize = 2,
        }
        return (priority[a.key] or 100) < (priority[b.key] or 100)
    end)

    return rows
end

function AntiDK:GetPlayerPanel(index)
    AntiDK.PlayerPanels = AntiDK.PlayerPanels or {}
    local panel = AntiDK.PlayerPanels[index]
    if panel then
        return panel
    end

    local panelRoot = WINDOW_MANAGER:CreateControl("AntiDK_PlayerPanel_" .. index, AntiDK.ContentArea, CT_CONTROL)

    local playerLabel = WINDOW_MANAGER:CreateControl("AntiDK_PlayerLabel_" .. index, panelRoot, CT_LABEL)
    playerLabel:SetAnchor(TOPLEFT, panelRoot, TOPLEFT, 2, 0)

    local statusLabel = WINDOW_MANAGER:CreateControl("AntiDK_PlayerStatus_" .. index, panelRoot, CT_LABEL)
    statusLabel:SetAnchor(TOPRIGHT, panelRoot, TOPRIGHT, -2, 0)
    statusLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    panel = {
        root = panelRoot,
        playerLabel = playerLabel,
        statusLabel = statusLabel,
        rows = {},
    }

    AntiDK.PlayerPanels[index] = panel
    return panel
end

function AntiDK:GetOrCreateRowControl(panelIndex, rowIndex, parent)
    local panel = AntiDK:GetPlayerPanel(panelIndex)
    local row = panel.rows[rowIndex]
    if row then
        return row
    end

    local token = panelIndex .. "_" .. rowIndex
    local rowRoot = WINDOW_MANAGER:CreateControl("AntiDK_RowRoot_" .. token, parent, CT_CONTROL)

    local icon = WINDOW_MANAGER:CreateControl("AntiDK_RowIcon_" .. token, rowRoot, CT_TEXTURE)
    icon:SetAnchor(LEFT, rowRoot, LEFT, 0, 0)
    icon:SetDimensions(16, 16)
    icon:SetColor(1, 1, 1, 0.85)

    local rowBg = WINDOW_MANAGER:CreateControl("AntiDK_RowBg_" .. token, rowRoot, CT_BACKDROP)
    rowBg:SetAnchor(TOPLEFT, rowRoot, TOPLEFT, 20, 0)
    rowBg:SetAnchor(BOTTOMRIGHT, rowRoot, BOTTOMRIGHT, 0, 0)
    rowBg:SetCenterColor(SRUI_THEME.rowBg[1], SRUI_THEME.rowBg[2], SRUI_THEME.rowBg[3], SRUI_THEME.rowBg[4])
    rowBg:SetEdgeColor(SRUI_THEME.rowEdge[1], SRUI_THEME.rowEdge[2], SRUI_THEME.rowEdge[3], SRUI_THEME.rowEdge[4])
    rowBg:SetEdgeTexture("EsoUI/Art/Miscellaneous/progressbar_genericfill_slot.dds", 1, 1, 1)

    local fillBackdrop = WINDOW_MANAGER:CreateControl("AntiDK_RowFill_" .. token, rowRoot, CT_BACKDROP)
    fillBackdrop:SetAnchor(TOPLEFT, rowBg, TOPLEFT, 1, 1)
    fillBackdrop:SetAnchor(BOTTOMLEFT, rowBg, BOTTOMLEFT, 1, -1)
    fillBackdrop:SetEdgeTexture("EsoUI/Art/Miscellaneous/progressbar_genericfill_slot.dds", 1, 1, 1)

    local label = WINDOW_MANAGER:CreateControl("AntiDK_RowLabel_" .. token, rowRoot, CT_LABEL)
    label:SetAnchor(LEFT, rowBg, LEFT, 6, 0)

    local sourceLabel = WINDOW_MANAGER:CreateControl("AntiDK_RowSource_" .. token, rowRoot, CT_LABEL)
    sourceLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    local timer = WINDOW_MANAGER:CreateControl("AntiDK_RowTimer_" .. token, rowRoot, CT_LABEL)
    timer:SetAnchor(RIGHT, rowBg, RIGHT, -7, 0)
    timer:SetColor(0.80, 0.89, 0.98, 0.95)
    timer:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    row = {
        root = rowRoot,
        icon = icon,
        rowBg = rowBg,
        fillBackdrop = fillBackdrop,
        label = label,
        sourceLabel = sourceLabel,
        timer = timer,
    }

    panel.rows[rowIndex] = row
    return row
end

function AntiDK:UpdateStyledRow(row, xOffset, yOffset, width, rowData, fontSize)
    row.root:ClearAnchors()
    row.root:SetAnchor(TOPLEFT, row.root:GetParent(), TOPLEFT, xOffset, yOffset)
    row.root:SetDimensions(width, 20)
    row.root:SetHidden(false)

    row.icon:SetTexture(rowData.icon or "/esoui/art/icons/icon_missing.dds")

    local ratio = Clamp(rowData.duration / math.max(0.01, rowData.maxDuration), 0, 1)
    row.fillBackdrop:SetWidth(math.floor((width - 22) * ratio))
    row.fillBackdrop:SetCenterColor(rowData.color[1], rowData.color[2], rowData.color[3], 0.34)
    row.fillBackdrop:SetEdgeColor(rowData.color[1], rowData.color[2], rowData.color[3], 0.52)

    row.timer:SetDimensions(58, 20)
    row.sourceLabel:ClearAnchors()
    row.sourceLabel:SetAnchor(RIGHT, row.timer, LEFT, -8, 0)
    row.sourceLabel:SetDimensions(110, 20)
    row.sourceLabel:SetFont(string.format("$(MEDIUM_FONT)|%d|soft-shadow-thin", math.max(10, fontSize - 5)))
    row.sourceLabel:SetColor(0.72, 0.80, 0.90, 0.82)
    row.sourceLabel:SetHidden(not rowData.sourceText)
    row.sourceLabel:SetText(rowData.sourceText or "")

    local labelRightMargin = rowData.sourceText and 180 or 74
    row.label:SetDimensions(math.max(80, width - labelRightMargin), 20)

    row.label:SetFont(string.format("$(MEDIUM_FONT)|%d|soft-shadow-thin", math.max(11, fontSize - 3)))
    local stackText = rowData.stacks and (" x" .. rowData.stacks) or ""
    if rowData.labelIsRichText then
        row.label:SetText(string.format("%s%s", rowData.label, stackText))
    else
        row.label:SetText(string.format("|cFFD2DB%s%s|r", rowData.label, stackText))
    end

    row.timer:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thin", math.max(11, fontSize - 2)))
    if rowData.statusColor then
        row.timer:SetColor(rowData.statusColor[1], rowData.statusColor[2], rowData.statusColor[3], rowData.statusColor[4])
    else
        row.timer:SetColor(0.80, 0.89, 0.98, 0.95)
    end
    row.timer:SetText(rowData.statusText or string.format("%.1fs", rowData.duration))
end

function AntiDK:HideUnusedRows(panel, usedCount)
    for rowIndex = usedCount + 1, #panel.rows do
        local row = panel.rows[rowIndex]
        if row and row.root then
            row.root:SetHidden(true)
        end
    end
end

function AntiDK:EnsureEmptyStateControls()
    if AntiDK.EmptyStateControls then
        return
    end

    local emptyLabel = WINDOW_MANAGER:CreateControl("AntiDK_EmptyState", AntiDK.ContentArea, CT_LABEL)
    emptyLabel:SetAnchor(TOP, AntiDK.ContentArea, TOP, 0, 48)
    emptyLabel:SetColor(0.84, 0.90, 0.98, 0.94)

    local subLabel = WINDOW_MANAGER:CreateControl("AntiDK_EmptyStateSub", AntiDK.ContentArea, CT_LABEL)
    subLabel:SetAnchor(TOP, emptyLabel, BOTTOM, 0, 8)
    subLabel:SetColor(0.66, 0.73, 0.82, 0.88)

    local previewRow = WINDOW_MANAGER:CreateControl("AntiDK_EmptyPreview", AntiDK.ContentArea, CT_BACKDROP)
    previewRow:SetAnchor(TOPLEFT, AntiDK.ContentArea, TOPLEFT, 20, 92)
    previewRow:SetCenterColor(0.00, 0.00, 0.00, 0.00)
    previewRow:SetEdgeColor(0.00, 0.00, 0.00, 0.00)
    previewRow:SetEdgeTexture("EsoUI/Art/Miscellaneous/progressbar_genericfill_slot.dds", 1, 1, 1)

    local previewFill = WINDOW_MANAGER:CreateControl("AntiDK_EmptyPreviewFill", previewRow, CT_BACKDROP)
    previewFill:SetAnchor(TOPLEFT, previewRow, TOPLEFT, 1, 1)
    previewFill:SetAnchor(BOTTOMLEFT, previewRow, BOTTOMLEFT, 1, -1)
    previewFill:SetCenterColor(0.58, 0.74, 0.98, 0.34)
    previewFill:SetEdgeColor(0.58, 0.74, 0.98, 0.54)
    previewFill:SetEdgeTexture("EsoUI/Art/Miscellaneous/progressbar_genericfill_slot.dds", 1, 1, 1)

    local previewText = WINDOW_MANAGER:CreateControl("AntiDK_EmptyPreviewText", previewRow, CT_LABEL)
    previewText:SetAnchor(LEFT, previewRow, LEFT, 8, 0)

    local previewTimer = WINDOW_MANAGER:CreateControl("AntiDK_EmptyPreviewTimer", previewRow, CT_LABEL)
    previewTimer:SetAnchor(RIGHT, previewRow, RIGHT, -8, 0)
    previewTimer:SetColor(0.80, 0.89, 0.98, 0.95)
    previewTimer:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    previewTimer:SetText("6.5s")

    AntiDK.EmptyStateControls = {
        emptyLabel = emptyLabel,
        subLabel = subLabel,
        previewRow = previewRow,
        previewFill = previewFill,
        previewText = previewText,
        previewTimer = previewTimer,
    }
end

function AntiDK:SetEmptyStateVisible(isVisible, now, fontSize)
    AntiDK:EnsureEmptyStateControls()
    local controls = AntiDK.EmptyStateControls
    if not controls then return end

    controls.emptyLabel:SetHidden(not isVisible)
    controls.subLabel:SetHidden(not isVisible)
    controls.previewRow:SetHidden(not isVisible)

    if not isVisible then
        return
    end

    controls.emptyLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thin", math.max(13, fontSize)))
    if IsAutoHideEnabled() then
        local hideRemaining = math.max(0, GetAutoHideDelay() - (now - AntiDK.LastActiveAbilityTime))
        controls.emptyLabel:SetText(string.format("Tracker online - hiding in %.1fs", hideRemaining))
    else
        controls.emptyLabel:SetText("Tracker online - no active DK auras")
    end

    controls.subLabel:SetFont(string.format("$(MEDIUM_FONT)|%d|soft-shadow-thin", math.max(11, fontSize - 3)))
    controls.subLabel:SetText("Use /antidk test to preview status bars immediately")

    controls.previewRow:SetDimensions(math.max(280, AntiDK.ContentArea:GetWidth() - 40), 20)
    controls.previewFill:SetWidth(math.floor((controls.previewRow:GetWidth() - 2) * 0.65))
    controls.previewText:SetFont(string.format("$(MEDIUM_FONT)|%d|soft-shadow-thin", math.max(11, fontSize - 3)))
    controls.previewText:SetText("Preview Aura Bar")
    controls.previewTimer:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thin", math.max(11, fontSize - 2)))
end

function AntiDK:EnsureRollNotificationControls()
    if AntiDK.RollNotificationLabel then
        return
    end

    local rollNotificationLabel = WINDOW_MANAGER:CreateControl("AntiDK_RollNotification", AntiDK.CenterWindow, CT_LABEL)
    rollNotificationLabel:SetAnchor(TOP, AntiDK.CenterWindow, TOP, 0, 6)
    rollNotificationLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    rollNotificationLabel:SetHidden(true)
    AntiDK.RollNotificationLabel = rollNotificationLabel
end

function AntiDK:UpdateRollNotification(fontSize)
    AntiDK:EnsureRollNotificationControls()
    if not AntiDK.RollNotificationLabel then return end
    AntiDK.RollNotificationLabel:SetHidden(false)
end

function AntiDK:DisplayPlayerDebuffs(yOffset)
    local rows = BuildPlayerDebuffRows()
    local panel = AntiDK:GetPlayerPanel("SelfDebuffs")
    if #rows == 0 then
        if panel and panel.root then
            panel.root:SetHidden(true)
            AntiDK:HideUnusedRows(panel, 0)
        end
        return yOffset, 0
    end

    local contentWidth = math.max(360, AntiDK.ContentArea:GetWidth())
    local panelWidth = contentWidth - 6
    local headerHeight = 14
    local rowHeight = 20
    local spacing = 2
    local panelHeight = headerHeight + (#rows * rowHeight) + ((#rows - 1) * spacing) + 4
    local fontSize = (AntiDK.settings and AntiDK.settings.fontSize) or AntiDK.Defaults.fontSize or 16

    panel.root:SetHidden(false)
    panel.root:ClearAnchors()
    panel.root:SetAnchor(TOPLEFT, AntiDK.ContentArea, TOPLEFT, 2, yOffset)
    panel.root:SetDimensions(panelWidth, panelHeight)

    panel.playerLabel:SetAnchor(TOPLEFT, panel.root, TOPLEFT, 2, 0)
    panel.playerLabel:SetFont(string.format("$(MEDIUM_FONT)|%d|soft-shadow-thin", math.max(11, fontSize - 3)))
    panel.playerLabel:SetColor(0.96, 0.82, 0.30, 0.95)
    panel.playerLabel:SetText("On You:")

    panel.statusLabel:SetAnchor(TOPRIGHT, panel.root, TOPRIGHT, -2, 0)
    panel.statusLabel:SetFont(string.format("$(MEDIUM_FONT)|%d|soft-shadow-thin", math.max(10, fontSize - 4)))
    panel.statusLabel:SetColor(0.90, 0.78, 0.32, 0.88)
    panel.statusLabel:SetText(string.format("%d debuff%s", #rows, #rows == 1 and "" or "s"))

    local rowY = headerHeight
    for rowIndex, rowData in ipairs(rows) do
        local row = AntiDK:GetOrCreateRowControl("SelfDebuffs", rowIndex, panel.root)
        AntiDK:UpdateStyledRow(row, 2, rowY, panelWidth - 4, rowData, fontSize)
        rowY = rowY + rowHeight + spacing
    end
    AntiDK:HideUnusedRows(panel, #rows)

    return yOffset + panelHeight + 8, #rows
end

function AntiDK:CreateUI()
    -- Create center-screen display for enemy abilities
    AntiDK.CenterWindow = WINDOW_MANAGER:CreateTopLevelWindow("AntiDK_CenterWindow")
    AntiDK.CenterWindow:SetMovable(true)
    AntiDK.CenterWindow:SetMouseEnabled(true)
    AntiDK.CenterWindow:SetClampedToScreen(true)
    AntiDK.CenterWindow:SetDimensions(410, 430)
    AntiDK:ApplyPositionSettings()
    AntiDK.CenterWindow:SetScale(GetConfiguredScale())
    AntiDK.CenterWindow:SetAlpha(1)
    AntiDK.CenterWindow:SetHidden(false)
    AntiDK.CenterWindow:SetDrawLayer(DL_OVERLAY)
    AntiDK.CenterWindow:SetDrawTier(DT_HIGH)
    AntiDK.CenterWindow:SetHandler("OnMoveStop", function(self)
        local _, _, _, offsetX, offsetY = self:GetAnchor(0)
        if AntiDK.settings then
            AntiDK.settings.posX = offsetX
            AntiDK.settings.posY = offsetY
        end
    end)
    AntiDK.CenterWindow:SetHandler("OnMouseDown", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:StartMoving()
        end
    end)
    AntiDK.CenterWindow:SetHandler("OnMouseUp", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:StopMovingOrResizing()
        end
    end)

    local frame = WINDOW_MANAGER:CreateControl("AntiDK_CenterFrame", AntiDK.CenterWindow, CT_BACKDROP)
    frame:SetAnchorFill(AntiDK.CenterWindow)
    frame:SetCenterColor(SRUI_THEME.frameBg[1], SRUI_THEME.frameBg[2], SRUI_THEME.frameBg[3], SRUI_THEME.frameBg[4])
    frame:SetEdgeColor(SRUI_THEME.frameEdge[1], SRUI_THEME.frameEdge[2], SRUI_THEME.frameEdge[3], SRUI_THEME.frameEdge[4])
    frame:SetEdgeTexture("EsoUI/Art/Miscellaneous/progressbar_frame.dds", 2, 2, 2)
    AntiDK.CenterFrame = frame

    local titleBand = WINDOW_MANAGER:CreateControl("AntiDK_TitleBand", AntiDK.CenterWindow, CT_BACKDROP)
    titleBand:SetAnchor(TOPLEFT, AntiDK.CenterWindow, TOPLEFT, 8, 8)
    titleBand:SetAnchor(TOPRIGHT, AntiDK.CenterWindow, TOPRIGHT, -8, 8)
    titleBand:SetHeight(22)
    titleBand:SetCenterColor(SRUI_THEME.titleBg[1], SRUI_THEME.titleBg[2], SRUI_THEME.titleBg[3], SRUI_THEME.titleBg[4])
    titleBand:SetEdgeColor(SRUI_THEME.titleEdge[1], SRUI_THEME.titleEdge[2], SRUI_THEME.titleEdge[3], SRUI_THEME.titleEdge[4])
    titleBand:SetEdgeTexture("EsoUI/Art/Miscellaneous/progressbar_genericfill_slot.dds", 1, 1, 1)
    AntiDK.TitleBand = titleBand

    local titleLabel = WINDOW_MANAGER:CreateControl("AntiDK_TitleLabel", AntiDK.CenterWindow, CT_LABEL)
    titleLabel:SetAnchor(CENTER, titleBand, CENTER, 0, 0)
    titleLabel:SetFont("$(MEDIUM_FONT)|14|soft-shadow-thin")
    titleLabel:SetColor(0.84, 0.91, 0.99, 0.95)
    titleLabel:SetText("AntiDK Auras")
    AntiDK.TitleLabel = titleLabel

    -- Content area for enemy abilities
    AntiDK.ContentArea = WINDOW_MANAGER:CreateControl("AntiDK_ContentArea", AntiDK.CenterWindow, CT_CONTROL)
    AntiDK.ContentArea:SetAnchor(TOPLEFT, AntiDK.CenterWindow, TOPLEFT, 8, 34)
    AntiDK.ContentArea:SetAnchor(BOTTOMRIGHT, AntiDK.CenterWindow, BOTTOMRIGHT, -10, -10)

    AntiDK:ApplyBackdropSettings()
    AntiDK:EnsureEmptyStateControls()
    AntiDK:EnsureRollNotificationControls()
    AntiDK:SetEmptyStateVisible(false, GetGameTimeSeconds(), (AntiDK.settings and AntiDK.settings.fontSize) or AntiDK.Defaults.fontSize or 16)
    if AntiDK.CenterWindow and IsAutoHideEnabled() and (not AntiDK.ActiveAbilities or next(AntiDK.ActiveAbilities) == nil) then
        AntiDK.CenterWindow:SetHidden(true)
    end

    -- Keep compatibility with slash command toggle behavior.
    AntiDK.UIWindow = AntiDK.CenterWindow
end

function AntiDK:ApplyPositionSettings()
    if not AntiDK.CenterWindow then return end

    local anchorX, anchorY = GetConfiguredAnchorOffsets()
    AntiDK.CenterWindow:ClearAnchors()
    AntiDK.CenterWindow:SetAnchor(CENTER, GuiRoot, CENTER, anchorX, anchorY)
end

function AntiDK:ApplyBackdropSettings()
    if not AntiDK.CenterWindow or not AntiDK.ContentArea then return end

    local showBackdrop = IsBackdropEnabled()
    local backdropOpacity = GetBackdropOpacity()

    if AntiDK.CenterFrame then
        AntiDK.CenterFrame:SetHidden(not showBackdrop)
        AntiDK.CenterFrame:SetCenterColor(
            SRUI_THEME.frameBg[1],
            SRUI_THEME.frameBg[2],
            SRUI_THEME.frameBg[3],
            SRUI_THEME.frameBg[4] * backdropOpacity
        )
        AntiDK.CenterFrame:SetEdgeColor(
            SRUI_THEME.frameEdge[1],
            SRUI_THEME.frameEdge[2],
            SRUI_THEME.frameEdge[3],
            SRUI_THEME.frameEdge[4] * backdropOpacity
        )
    end

    if AntiDK.TitleBand then
        AntiDK.TitleBand:SetHidden(not showBackdrop)
        AntiDK.TitleBand:SetCenterColor(
            SRUI_THEME.titleBg[1],
            SRUI_THEME.titleBg[2],
            SRUI_THEME.titleBg[3],
            SRUI_THEME.titleBg[4] * backdropOpacity
        )
        AntiDK.TitleBand:SetEdgeColor(
            SRUI_THEME.titleEdge[1],
            SRUI_THEME.titleEdge[2],
            SRUI_THEME.titleEdge[3],
            SRUI_THEME.titleEdge[4] * backdropOpacity
        )
    end

    if AntiDK.TitleLabel then
        AntiDK.TitleLabel:SetHidden(not showBackdrop)
    end

    AntiDK.ContentArea:ClearAnchors()
    if showBackdrop then
        AntiDK.ContentArea:SetAnchor(TOPLEFT, AntiDK.CenterWindow, TOPLEFT, 8, 34)
    else
        AntiDK.ContentArea:SetAnchor(TOPLEFT, AntiDK.CenterWindow, TOPLEFT, 8, 8)
    end
    AntiDK.ContentArea:SetAnchor(BOTTOMRIGHT, AntiDK.CenterWindow, BOTTOMRIGHT, -10, -10)
end

function AntiDK:UpdateUI()
    if not AntiDK.ContentArea then return end
    if AntiDK.CenterWindow then
        AntiDK.CenterWindow:SetScale(GetConfiguredScale())
    end
    
    -- Update active abilities first (clear expired ones)
    AntiDK:UpdateActiveAbilities()
    
    local yOffset = 0
    local fontSize = (AntiDK.settings and AntiDK.settings.fontSize) or AntiDK.Defaults.fontSize or 16
    local playerDebuffCount = 0

    yOffset, playerDebuffCount = AntiDK:DisplayPlayerDebuffs(yOffset)

    local enemyCount = 0
    local sortedPlayers = {}
    for playerName, abilities in pairs(AntiDK.ActiveAbilities) do
        if next(abilities) ~= nil then
            table.insert(sortedPlayers, playerName)
        end
    end
    table.sort(sortedPlayers)

    local panelIndex = 0
    for _, playerName in ipairs(sortedPlayers) do
        local abilities = AntiDK.ActiveAbilities[playerName]
        if next(abilities) ~= nil then
            panelIndex = panelIndex + 1
            local nextYOffset, wasRendered = AntiDK:DisplayEnemyAbilities(playerName, abilities, yOffset, panelIndex)
            yOffset = nextYOffset
            if wasRendered then
                enemyCount = enemyCount + 1
            end
        end
    end

    AntiDK.PlayerPanels = AntiDK.PlayerPanels or {}
    for i = panelIndex + 1, #AntiDK.PlayerPanels do
        local panel = AntiDK.PlayerPanels[i]
        if panel and panel.root then
            panel.root:SetHidden(true)
            AntiDK:HideUnusedRows(panel, 0)
        end
    end

    local now = GetGameTimeSeconds()
    local hasVisibleTrackerContent = enemyCount > 0 or playerDebuffCount > 0

    AntiDK:UpdateRollNotification(fontSize)

    if hasVisibleTrackerContent then
        AntiDK.LastActiveAbilityTime = now
        if AntiDK.CenterWindow and AntiDK.CenterWindow:IsHidden() then
            AntiDK.CenterWindow:SetHidden(false)
        end
        AntiDK:SetEmptyStateVisible(false, now, fontSize)
    else
        AntiDK.LastActiveAbilityTime = AntiDK.LastActiveAbilityTime or now
        AntiDK:SetEmptyStateVisible(false, now, fontSize)
        if IsAutoHideEnabled() and AntiDK.CenterWindow then
            local hideAfter = GetAutoHideDelay()
            if (now - AntiDK.LastActiveAbilityTime) >= hideAfter then
                AntiDK.CenterWindow:SetHidden(true)
                return
            end
        elseif AntiDK.CenterWindow and AntiDK.CenterWindow:IsHidden() then
            AntiDK.CenterWindow:SetHidden(false)
        end
    end

    if not hasVisibleTrackerContent then
        if not IsAutoHideEnabled() then
            if AntiDK.CenterWindow and AntiDK.CenterWindow:IsHidden() then
                AntiDK.CenterWindow:SetHidden(false)
            end
            AntiDK:SetEmptyStateVisible(true, now, fontSize)
        end
    end

end

function AntiDK:DisplayEnemyAbilities(playerName, abilities, yOffset, panelIndex)
    local rows = BuildAbilityRows(abilities)
    if #rows == 0 then
        local panel = AntiDK.PlayerPanels and AntiDK.PlayerPanels[panelIndex]
        if panel and panel.root then
            panel.root:SetHidden(true)
            AntiDK:HideUnusedRows(panel, 0)
        end
        return yOffset, false
    end

    local contentWidth = math.max(360, AntiDK.ContentArea:GetWidth())
    local panelWidth = contentWidth - 6
    local headerHeight = 14
    local rowHeight = 20
    local spacing = 2
    local panelHeight = headerHeight + (#rows * rowHeight) + ((#rows - 1) * spacing) + 4
    local fontSize = (AntiDK.settings and AntiDK.settings.fontSize) or AntiDK.Defaults.fontSize or 16

    local panel = AntiDK:GetPlayerPanel(panelIndex)
    local panelRoot = panel.root
    panelRoot:SetHidden(false)
    panelRoot:ClearAnchors()
    panelRoot:SetAnchor(TOPLEFT, AntiDK.ContentArea, TOPLEFT, 2, yOffset)
    panelRoot:SetDimensions(panelWidth, panelHeight)

    local formattedName = FormatPlayerName(playerName)
    local playerLabel = panel.playerLabel
    playerLabel:SetAnchor(TOPLEFT, panelRoot, TOPLEFT, 2, 0)
    playerLabel:SetFont(string.format("$(MEDIUM_FONT)|%d|soft-shadow-thin", math.max(11, fontSize - 3)))
    playerLabel:SetColor(0.70, 0.80, 0.93, 0.88)
    playerLabel:SetText(string.format("%s:", formattedName))

    local statusLabel = panel.statusLabel
    statusLabel:SetAnchor(TOPRIGHT, panelRoot, TOPRIGHT, -2, 0)
    statusLabel:SetFont(string.format("$(MEDIUM_FONT)|%d|soft-shadow-thin", math.max(10, fontSize - 4)))
    statusLabel:SetColor(0.56, 0.66, 0.80, 0.82)
    statusLabel:SetText(string.format("%d tracked", #rows))

    local rowY = headerHeight
    for rowIndex, rowData in ipairs(rows) do
        local row = AntiDK:GetOrCreateRowControl(panelIndex, rowIndex, panelRoot)
        AntiDK:UpdateStyledRow(row, 2, rowY, panelWidth - 4, rowData, fontSize)
        rowY = rowY + rowHeight + spacing
    end
    AntiDK:HideUnusedRows(panel, #rows)

    return yOffset + panelHeight + 8, true
end
