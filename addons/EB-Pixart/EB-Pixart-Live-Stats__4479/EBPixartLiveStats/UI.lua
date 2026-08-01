local Addon = EBPixartLiveStats

Addon.UI = Addon.UI or {}

local UI = Addon.UI

local WINDOW_WIDTH = 320
local WINDOW_MIN_WIDTH = 170
local WINDOW_MAX_WIDTH = 560
local WINDOW_MIN_HEIGHT = 220
local WINDOW_MAX_HEIGHT = 900
local CONTENT_PADDING_X = 14
local CONTENT_PADDING_Y = 14
local SECTION_SPACING = 18
local ROW_SPACING = 6
local ROW_HEIGHT = 22
local VALUE_COLUMN_MIN_WIDTH = 70
local VALUE_COLUMN_MAX_WIDTH = 120
local RESIZE_HANDLE_SIZE = 16
local MAIN_ROW_MIN_HEIGHT = 22
local MAIN_ROW_INNER_PADDING_Y = 2
local MAIN_ROW_SHORT_LABELS = {
    spellCrit = "Crit. mag.",
    weaponCrit = "Crit. phys.",
    spellPower = "Degats mag.",
    weaponPower = "Degats phys.",
    spellPen = "Pene. mag.",
    weaponPen = "Pene. phys.",
    incomingHealingPercent = "Soins recus %",
    blockPercent = "Blocage %",
    blockCost = "Cout blocage",
    physicalResistance = "Resist. phys.",
    spellResistance = "Resist. mag.",
    criticalResistance = "Resist. crit.",
}

local function FormatNumber(value)
    local amount = tonumber(value) or 0

    if ZO_CommaDelimitNumber then
        return ZO_CommaDelimitNumber(amount)
    end

    return tostring(amount)
end

local function FormatPercent(value)
    local amount = tonumber(value) or 0
    return string.format("%.1f%%", amount)
end

local function FormatDps(value)
    local amount = zo_max(0, tonumber(value) or 0)
    if amount < 1000 then
        return tostring(zo_floor(amount + 0.5))
    end

    if amount < 1000000 then
        local displayValue = amount / 1000
        if displayValue >= 100 then
            return string.format("%.0fK", displayValue)
        end

        local text = string.format("%.1fK", displayValue)
        return text:gsub("%.0K$", "K")
    end

    local displayValue = amount / 1000000
    local text = string.format("%.1fM", displayValue)
    return text:gsub("%.0M$", "M")
end

local function BuildFont(baseFont, size)
    local resolvedSize = zo_max(8, zo_floor(tonumber(size) or 16))
    return string.format("%s|%d|soft-shadow-thin", baseFont, resolvedSize)
end

local function SetControlHidden(control, hidden)
    if control then
        control:SetHidden(hidden)
    end
end

local function GetSafeUIMouseX()
    if type(GetUIMousePosition) == "function" then
        local mouseX = GetUIMousePosition()
        return tonumber(mouseX) or 0
    end

    return 0
end

local function GetSafeUIMouseY()
    if type(GetUIMousePosition) == "function" then
        local _, mouseY = GetUIMousePosition()
        return tonumber(mouseY) or 0
    end

    return 0
end

local sceneVisibilityCallbacks = {}
local previewState = {
    active = false,
}

local function IsGameplaySceneVisible()
    if HUD_SCENE and HUD_SCENE.IsShowing and HUD_SCENE:IsShowing() then
        return true
    end

    if HUD_UI_SCENE and HUD_UI_SCENE.IsShowing and HUD_UI_SCENE:IsShowing() then
        return true
    end

    return false
end

local function RegisterGameplaySceneCallbacks(key, callback)
    if sceneVisibilityCallbacks[key] or type(callback) ~= "function" then
        return
    end

    local function Attach(scene)
        if scene and scene.RegisterCallback then
            scene:RegisterCallback("StateChange", function()
                callback()
            end)
        end
    end

    Attach(HUD_SCENE)
    Attach(HUD_UI_SCENE)
    sceneVisibilityCallbacks[key] = true
end

local function IsPreviewModeActive()
    return previewState.active == true
end

local function GetRootDimensions()
    local width = GuiRoot and GuiRoot.GetWidth and GuiRoot:GetWidth() or 0
    local height = GuiRoot and GuiRoot.GetHeight and GuiRoot:GetHeight() or 0
    return width, height
end

function UI:Initialize()
    self:CreateWindow()
    RegisterGameplaySceneCallbacks("main_window", function()
        self:UpdateSceneVisibility()
    end)
    self:ApplyAppearance()
    self:ApplySavedState()
    self:RefreshAll()
end

function UI:EnterPreviewMode()
    if IsPreviewModeActive() then
        self:UpdatePreviewLayout()
        return
    end

    previewState.active = true
    self:UpdatePreviewLayout()
end

function UI:ExitPreviewMode()
    if not IsPreviewModeActive() then
        return
    end

    previewState.active = false

    if self.window then
        self:ApplySavedState()
    end

    if Addon.HealUI and Addon.HealUI.ApplySavedState then
        Addon.HealUI:ApplySavedState()
    end
end

function UI:UpdatePreviewLayout()
    if not IsPreviewModeActive() then
        return
    end

    local rootWidth, rootHeight = GetRootDimensions()
    local marginRight = 24
    local marginTop = 120
    local panelSpacing = 24
    local spacing = 16
    local mainWindow = self.window
    local healWindow = Addon.HealUI and Addon.HealUI.window or nil
    local mainWidth = mainWindow and mainWindow.GetWidth and mainWindow:GetWidth() or 0
    local mainHeight = mainWindow and mainWindow.GetHeight and mainWindow:GetHeight() or 0
    local healWidth = healWindow and healWindow.GetWidth and healWindow:GetWidth() or 0
    local healHeight = healWindow and healWindow.GetHeight and healWindow:GetHeight() or 0
    local panel = Addon.Settings and Addon.Settings.panel or nil
    local panelContainer = panel and panel.container or nil
    local panelRight = 0

    if panel and panel.GetRight then
        panelRight = tonumber(panel:GetRight()) or panelRight
    end

    if panelContainer and panelContainer.GetRight then
        panelRight = zo_max(panelRight, tonumber(panelContainer:GetRight()) or 0)
    end

    local minPreviewX = zo_max(20, panelRight + panelSpacing)
    local maxPreviewRight = zo_max(minPreviewX, rootWidth - marginRight)
    local sideBySideWidth = mainWidth + (healWindow and (spacing + healWidth) or 0)
    local canPlaceSideBySide = mainWindow and healWindow and (minPreviewX + sideBySideWidth) <= maxPreviewRight
    local canStackWithoutOverlap = minPreviewX + zo_max(mainWidth, healWidth) <= maxPreviewRight

    local function PlaceWindow(window, x, y, resizeHandle)
        if not window then
            return
        end

        window:ClearAnchors()
        window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
        window:SetHidden(false)
        window:SetMovable(false)
        window:SetMouseEnabled(true)

        if resizeHandle then
            resizeHandle:SetMouseEnabled(false)
            if resizeHandle.grip then
                resizeHandle.grip:SetHidden(true)
            end
        end
    end

    if canPlaceSideBySide then
        local startX = zo_max(minPreviewX, maxPreviewRight - sideBySideWidth)

        PlaceWindow(mainWindow, startX, marginTop, self.resizeHandle)
        PlaceWindow(healWindow, startX + mainWidth + spacing, marginTop, Addon.HealUI and Addon.HealUI.resizeHandle or nil)
        return
    end

    local stackWidth = zo_max(mainWidth, healWidth)
    local startX = canStackWithoutOverlap and zo_max(minPreviewX, maxPreviewRight - stackWidth) or minPreviewX

    if mainWindow then
        PlaceWindow(mainWindow, startX, marginTop, self.resizeHandle)
    end

    if healWindow then
        local stackY = marginTop + (mainHeight > 0 and (mainHeight + spacing) or 0)
        local healY = zo_min(stackY, zo_max(marginTop, rootHeight - healHeight - 24))
        PlaceWindow(healWindow, startX, healY, Addon.HealUI and Addon.HealUI.resizeHandle or nil)
    end
end

function UI:GetMinWindowWidth()
    return WINDOW_MIN_WIDTH
end

function UI:GetMaxWindowWidth()
    return WINDOW_MAX_WIDTH
end

function UI:GetCurrentWindowWidth()
    local width = tonumber(Addon.sv.windowWidth) or tonumber(Addon.sv.ui.width) or WINDOW_WIDTH
    return zo_clamp(width, self:GetMinWindowWidth(), self:GetMaxWindowWidth())
end

function UI:GetCurrentWindowHeight()
    local height = tonumber(Addon.sv.windowHeight) or WINDOW_MIN_HEIGHT
    return zo_clamp(height, WINDOW_MIN_HEIGHT, WINDOW_MAX_HEIGHT)
end

function UI:GetCompactMetrics()
    local width = self:GetCurrentWindowWidth()

    if width <= 230 then
        return {
            paddingX = 8,
            paddingY = 8,
            titleGap = 10,
            sectionSpacing = 8,
            rowsTopGap = 6,
            rowSpacing = 2,
            rowMinHeight = 18,
            labelValueGap = 4,
            headerHeight = 18,
            labelFontDelta = -2,
            valueFontDelta = -2,
            titleFontExtra = 1,
            sectionFontExtra = -1,
            useShortLabels = true,
            valueColumnRatio = 0.42,
            valueColumnMin = 50,
            valueColumnMax = 96,
        }
    end

    if width <= 310 then
        return {
            paddingX = 10,
            paddingY = 10,
            titleGap = 14,
            sectionSpacing = 12,
            rowsTopGap = 8,
            rowSpacing = 4,
            rowMinHeight = 20,
            labelValueGap = 6,
            headerHeight = 20,
            labelFontDelta = -1,
            valueFontDelta = -1,
            titleFontExtra = 2,
            sectionFontExtra = 0,
            useShortLabels = true,
            valueColumnRatio = 0.37,
            valueColumnMin = 58,
            valueColumnMax = 108,
        }
    end

    return {
        paddingX = CONTENT_PADDING_X,
        paddingY = CONTENT_PADDING_Y,
        titleGap = 18,
        sectionSpacing = SECTION_SPACING,
        rowsTopGap = 10,
        rowSpacing = ROW_SPACING,
        rowMinHeight = MAIN_ROW_MIN_HEIGHT,
        labelValueGap = 8,
        headerHeight = 24,
        labelFontDelta = 0,
        valueFontDelta = 0,
        titleFontExtra = 4,
        sectionFontExtra = 1,
        useShortLabels = false,
        valueColumnRatio = 0.32,
        valueColumnMin = VALUE_COLUMN_MIN_WIDTH,
        valueColumnMax = VALUE_COLUMN_MAX_WIDTH,
    }
end

function UI:GetValueColumnWidth()
    local metrics = self:GetCompactMetrics()
    local contentWidth = self:GetCurrentWindowWidth() - (metrics.paddingX * 2)
    local preferredWidth = zo_floor(contentWidth * metrics.valueColumnRatio)
    return zo_clamp(preferredWidth, metrics.valueColumnMin, metrics.valueColumnMax)
end

function UI:ApplyWindowWidth(width)
    local resolvedWidth = zo_clamp(tonumber(width) or WINDOW_WIDTH, self:GetMinWindowWidth(), self:GetMaxWindowWidth())
    Addon.sv.windowWidth = resolvedWidth
    Addon.sv.ui.width = resolvedWidth

    if self.window then
        self.window:SetWidth(resolvedWidth)
    end

    return resolvedWidth
end

function UI:ApplyWindowHeight(height)
    local resolvedHeight = zo_clamp(tonumber(height) or WINDOW_MIN_HEIGHT, WINDOW_MIN_HEIGHT, WINDOW_MAX_HEIGHT)
    Addon.sv.windowHeight = resolvedHeight
    Addon.sv.ui.height = resolvedHeight

    if self.window then
        self.window:SetHeight(resolvedHeight)
    end

    return resolvedHeight
end

function UI:CreateWindow()
    if self.window then
        return
    end

    local window = WINDOW_MANAGER:CreateTopLevelWindow("EBPixartLiveStatsWindow")
    window:SetDimensions(self:GetCurrentWindowWidth(), self:GetCurrentWindowHeight())
    window:SetClampedToScreen(true)
    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetHidden(Addon.sv.ui.hidden)
    window:SetHandler("OnMoveStop", function(control)
        Addon.sv.ui.offsetX = control:GetLeft()
        Addon.sv.ui.offsetY = control:GetTop()
    end)
    window:SetHandler("OnMouseUp", function(_, button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT or not self.isResizing then
            return
        end

        self.isResizing = false
        self:ApplyWindowWidth(self:GetCurrentWindowWidth())
        self:ApplyWindowHeight(self:GetCurrentWindowHeight())
        self:UpdateResponsiveLayout()
        self:RefreshAll()
    end)
    window:SetHandler("OnUpdate", function()
        if not self.isResizing then
            return
        end

        local currentMouseX = GetSafeUIMouseX()
        local currentMouseY = GetSafeUIMouseY()
        local deltaX = currentMouseX - self.resizeStartMouseX
        local deltaY = currentMouseY - self.resizeStartMouseY
        self:ApplyWindowWidth(self.resizeStartWidth + deltaX)
        self:ApplyWindowHeight(self.resizeStartHeight + deltaY)
        self:UpdateResponsiveLayout()
        self:ReflowSections()
    end)

    local backdrop = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    backdrop:SetAnchorFill(window)
    backdrop:SetCenterColor(0.04, 0.04, 0.05, 0.82)
    backdrop:SetEdgeColor(1, 1, 1, 0.12)
    backdrop:SetEdgeTexture(nil, 1, 1, 1)
    backdrop:SetInsets(-1, -1, 1, 1)

    local content = WINDOW_MANAGER:CreateControl(nil, window, CT_CONTROL)
    content:SetAnchor(TOPLEFT, window, TOPLEFT, CONTENT_PADDING_X, CONTENT_PADDING_Y)
    content:SetAnchor(TOPRIGHT, window, TOPRIGHT, -CONTENT_PADDING_X, CONTENT_PADDING_Y)

    local resizeHandle = self:CreateResizeHandle(window)

    local title = WINDOW_MANAGER:CreateControl(nil, content, CT_LABEL)
    title:SetAnchor(TOPLEFT, content, TOPLEFT, 0, 0)
    title:SetAnchor(TOPRIGHT, content, TOPRIGHT, 0, 0)
    title:SetFont("ZoFontWinH3")
    title:SetColor(1, 1, 1, 0.95)
    title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    title:SetText(Addon.displayName)

    local emptyStateLabel = WINDOW_MANAGER:CreateControl(nil, content, CT_LABEL)
    emptyStateLabel:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 12)
    emptyStateLabel:SetAnchor(TOPRIGHT, title, BOTTOMRIGHT, 0, 12)
    emptyStateLabel:SetFont("ZoFontGame")
    emptyStateLabel:SetColor(0.86, 0.86, 0.86, 0.82)
    emptyStateLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    emptyStateLabel:SetText(GetString(EBPXLIVESTATS_UI_EMPTY))
    emptyStateLabel:SetHidden(true)

    local combatSection = self:CreateSection(content, GetString(EBPXLIVESTATS_UI_SECTION_COMBAT), title, BOTTOMLEFT, 0, 18)
    local pveSection = self:CreateSection(content, GetString(EBPXLIVESTATS_UI_SECTION_PVE), combatSection.container, BOTTOMLEFT, 0, SECTION_SPACING)
    local pvpSection = self:CreateSection(content, GetString(EBPXLIVESTATS_UI_SECTION_PVP), pveSection.container, BOTTOMLEFT, 0, SECTION_SPACING)

    self.window = window
    self.content = content
    self.backdrop = backdrop
    self.title = title
    self.emptyStateLabel = emptyStateLabel
    self.resizeHandle = resizeHandle
    self.rows = {}
    self.sections = {
        combat = combatSection,
        pveStats = pveSection,
        pvpStats = pvpSection,
    }

    local combatRowsOrdered = {
        self:CreateStatRow(combatSection.rowsContainer, "dps", GetString(EBPXLIVESTATS_LABEL_DPS)),
        self:CreateStatRow(combatSection.rowsContainer, "damage", GetString(EBPXLIVESTATS_LABEL_DAMAGE)),
        self:CreateStatRow(combatSection.rowsContainer, "healing", GetString(EBPXLIVESTATS_LABEL_HEALING)),
        self:CreateStatRow(combatSection.rowsContainer, "combat", GetString(EBPXLIVESTATS_LABEL_COMBAT)),
    }
    self.combatRows = {
        dps = combatRowsOrdered[1],
        damage = combatRowsOrdered[2],
        healing = combatRowsOrdered[3],
        combat = combatRowsOrdered[4],
    }
    combatSection.rows = combatRowsOrdered

    local pveRowsOrdered = {
        self:CreateStatRow(pveSection.rowsContainer, "spellCrit", GetString(EBPXLIVESTATS_LABEL_SPELL_CRIT)),
        self:CreateStatRow(pveSection.rowsContainer, "weaponCrit", GetString(EBPXLIVESTATS_LABEL_WEAPON_CRIT)),
        self:CreateStatRow(pveSection.rowsContainer, "spellPower", GetString(EBPXLIVESTATS_LABEL_SPELL_POWER)),
        self:CreateStatRow(pveSection.rowsContainer, "weaponPower", GetString(EBPXLIVESTATS_LABEL_WEAPON_POWER)),
    }
    self.pveRows = {
        spellCrit = pveRowsOrdered[1],
        weaponCrit = pveRowsOrdered[2],
        spellPower = pveRowsOrdered[3],
        weaponPower = pveRowsOrdered[4],
    }
    pveSection.rows = pveRowsOrdered

    local pvpRowsOrdered = {
        self:CreateStatRow(pvpSection.rowsContainer, "spellPen", GetString(EBPXLIVESTATS_LABEL_SPELL_PEN)),
        self:CreateStatRow(pvpSection.rowsContainer, "weaponPen", GetString(EBPXLIVESTATS_LABEL_WEAPON_PEN)),
        self:CreateStatRow(pvpSection.rowsContainer, "incomingHealingPercent", GetString(EBPXLIVESTATS_LABEL_INCOMING_HEALING_PERCENT)),
        self:CreateStatRow(pvpSection.rowsContainer, "blockPercent", GetString(EBPXLIVESTATS_LABEL_BLOCK_PERCENT)),
        self:CreateStatRow(pvpSection.rowsContainer, "blockCost", GetString(EBPXLIVESTATS_LABEL_BLOCK_COST)),
        self:CreateStatRow(pvpSection.rowsContainer, "physicalResistance", GetString(EBPXLIVESTATS_LABEL_PHYSICAL_RESISTANCE)),
        self:CreateStatRow(pvpSection.rowsContainer, "spellResistance", GetString(EBPXLIVESTATS_LABEL_SPELL_RESISTANCE)),
        self:CreateStatRow(pvpSection.rowsContainer, "criticalResistance", GetString(EBPXLIVESTATS_LABEL_CRITICAL_RESISTANCE)),
    }
    self.pvpRows = {
        spellPen = pvpRowsOrdered[1],
        weaponPen = pvpRowsOrdered[2],
        incomingHealingPercent = pvpRowsOrdered[3],
        blockPercent = pvpRowsOrdered[4],
        blockCost = pvpRowsOrdered[5],
        physicalResistance = pvpRowsOrdered[6],
        spellResistance = pvpRowsOrdered[7],
        criticalResistance = pvpRowsOrdered[8],
    }
    pvpSection.rows = pvpRowsOrdered

    self:ReflowSections()
end

function UI:CreateSection(parent, titleText, anchorTarget, anchorPoint, offsetX, offsetY)
    local section = WINDOW_MANAGER:CreateControl(nil, parent, CT_CONTROL)
    section:SetAnchor(TOPLEFT, anchorTarget, anchorPoint, offsetX or 0, offsetY or 0)
    section:SetAnchor(TOPRIGHT, anchorTarget, anchorPoint == BOTTOMLEFT and BOTTOMRIGHT or TOPRIGHT, 0, offsetY or 0)

    local headerContainer = WINDOW_MANAGER:CreateControl(nil, section, CT_CONTROL)
    headerContainer:SetAnchor(TOPLEFT, section, TOPLEFT, 0, 0)
    headerContainer:SetAnchor(TOPRIGHT, section, TOPRIGHT, 0, 0)
    headerContainer:SetHeight(24)

    local header = WINDOW_MANAGER:CreateControl(nil, section, CT_LABEL)
    header:SetAnchor(CENTER, headerContainer, CENTER, 0, 0)
    header:SetFont("ZoFontHeader2")
    header:SetColor(0.84, 0.84, 0.84, 0.92)
    header:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    header:SetText(titleText)

    local dividerLeft = WINDOW_MANAGER:CreateControl(nil, headerContainer, CT_BACKDROP)
    dividerLeft:SetAnchor(LEFT, headerContainer, LEFT, 0, 0)
    dividerLeft:SetAnchor(RIGHT, header, LEFT, -10, 0)
    dividerLeft:SetHeight(1)
    dividerLeft:SetCenterColor(1, 1, 1, 0.08)
    dividerLeft:SetEdgeColor(0, 0, 0, 0)

    local dividerRight = WINDOW_MANAGER:CreateControl(nil, headerContainer, CT_BACKDROP)
    dividerRight:SetAnchor(LEFT, header, RIGHT, 10, 0)
    dividerRight:SetAnchor(RIGHT, headerContainer, RIGHT, 0, 0)
    dividerRight:SetHeight(1)
    dividerRight:SetCenterColor(1, 1, 1, 0.08)
    dividerRight:SetEdgeColor(0, 0, 0, 0)

    local rowsContainer = WINDOW_MANAGER:CreateControl(nil, section, CT_CONTROL)
    rowsContainer:SetAnchor(TOPLEFT, headerContainer, BOTTOMLEFT, 0, 10)
    rowsContainer:SetAnchor(TOPRIGHT, headerContainer, BOTTOMRIGHT, 0, 10)

    section.headerContainer = headerContainer
    section.header = header
    section.dividerLeft = dividerLeft
    section.dividerRight = dividerRight
    section.rowsContainer = rowsContainer
    section.container = section
    section.rows = {}
    return section
end

function UI:CreateStatRow(parent, rowKey, labelText)
    local container = WINDOW_MANAGER:CreateControl(nil, parent, CT_CONTROL)
    container:SetHeight(ROW_HEIGHT)
    local initialValueWidth = self:GetValueColumnWidth()

    local label = WINDOW_MANAGER:CreateControl(nil, container, CT_LABEL)
    label:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
    label:SetAnchor(TOPRIGHT, container, TOPRIGHT, -(initialValueWidth + 8), 0)
    label:SetFont("ZoFontGame")
    label:SetColor(0.82, 0.82, 0.82, 0.95)
    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_TOP)
    label:SetText(labelText)

    local value = WINDOW_MANAGER:CreateControl(nil, container, CT_LABEL)
    value:SetAnchor(TOPRIGHT, container, TOPRIGHT, 0, 0)
    value:SetDimensions(initialValueWidth, ROW_HEIGHT)
    value:SetFont("ZoFontGameBold")
    value:SetColor(1, 1, 1, 1)
    value:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    value:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    value:SetText("-")

    local row = {
        key = rowKey,
        container = container,
        label = label,
        value = value,
        desiredVisible = true,
        fullLabelText = labelText,
        shortLabelText = MAIN_ROW_SHORT_LABELS[rowKey] or labelText,
    }

    self.rows[rowKey] = row
    return row
end

function UI:CreateResizeHandle(parent)
    local handle = WINDOW_MANAGER:CreateControl(nil, parent, CT_CONTROL)
    handle:SetDimensions(RESIZE_HANDLE_SIZE, RESIZE_HANDLE_SIZE)
    handle:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, -4, -4)
    handle:SetMouseEnabled(true)
    handle:SetHandler("OnMouseDown", function(_, button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT or not Addon.sv.unlocked then
            return
        end

        self.isResizing = true
        self.resizeStartMouseX = GetSafeUIMouseX()
        self.resizeStartMouseY = GetSafeUIMouseY()
        self.resizeStartWidth = self:GetCurrentWindowWidth()
        self.resizeStartHeight = self:GetCurrentWindowHeight()
    end)
    handle:SetHandler("OnMouseUp", function(_, button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT or not self.isResizing then
            return
        end

        self.isResizing = false
        self:ApplyWindowWidth(self:GetCurrentWindowWidth())
        self:ApplyWindowHeight(self:GetCurrentWindowHeight())
        self:UpdateResponsiveLayout()
        self:RefreshAll()
    end)

    local grip = WINDOW_MANAGER:CreateControl(nil, handle, CT_LABEL)
    grip:SetAnchor(BOTTOMRIGHT, handle, BOTTOMRIGHT, 0, 0)
    grip:SetFont("ZoFontGameSmall")
    grip:SetColor(1, 1, 1, 0.35)
    grip:SetText("//")

    handle.grip = grip
    return handle
end

function UI:GetRowHeight(row)
    if not row or not row.container then
        return MAIN_ROW_MIN_HEIGHT
    end

    local metrics = self:GetCompactMetrics()

    local labelHeight = metrics.rowMinHeight
    local valueHeight = metrics.rowMinHeight

    if row.label and row.label.GetTextHeight then
        labelHeight = zo_max(metrics.rowMinHeight, zo_ceil((row.label:GetTextHeight() or 0) + MAIN_ROW_INNER_PADDING_Y))
    end

    if row.value and row.value.GetTextHeight then
        valueHeight = zo_max(metrics.rowMinHeight, zo_ceil((row.value:GetTextHeight() or 0) + MAIN_ROW_INNER_PADDING_Y))
    end

    return zo_max(labelHeight, valueHeight)
end

function UI:UpdateResponsiveLayout()
    if not self.window then
        return
    end

    local metrics = self:GetCompactMetrics()
    local valueColumnWidth = self:GetValueColumnWidth()

    if self.content then
        self.content:ClearAnchors()
        self.content:SetAnchor(TOPLEFT, self.window, TOPLEFT, metrics.paddingX, metrics.paddingY)
        self.content:SetAnchor(TOPRIGHT, self.window, TOPRIGHT, -metrics.paddingX, metrics.paddingY)
    end

    if self.emptyStateLabel then
        self.emptyStateLabel:ClearAnchors()
        self.emptyStateLabel:SetAnchor(TOPLEFT, self.title, BOTTOMLEFT, 0, zo_max(6, metrics.titleGap - 6))
        self.emptyStateLabel:SetAnchor(TOPRIGHT, self.title, BOTTOMRIGHT, 0, zo_max(6, metrics.titleGap - 6))
    end

    for _, section in pairs(self.sections or {}) do
        if section.headerContainer then
            section.headerContainer:SetHeight(metrics.headerHeight)
        end

        if section.rowsContainer then
            section.rowsContainer:ClearAnchors()
            section.rowsContainer:SetAnchor(TOPLEFT, section.headerContainer, BOTTOMLEFT, 0, metrics.rowsTopGap)
            section.rowsContainer:SetAnchor(TOPRIGHT, section.headerContainer, BOTTOMRIGHT, 0, metrics.rowsTopGap)
        end
    end

    for _, row in pairs(self.rows or {}) do
        local rowHeight = self:GetRowHeight(row)

        if row.label then
            row.label:SetText(metrics.useShortLabels and row.shortLabelText or row.fullLabelText)
            row.label:ClearAnchors()
            row.label:SetAnchor(TOPLEFT, row.container, TOPLEFT, 0, 0)
            row.label:SetAnchor(TOPRIGHT, row.container, TOPRIGHT, -(valueColumnWidth + metrics.labelValueGap), 0)
        end

        if row.value then
            row.value:ClearAnchors()
            row.value:SetAnchor(TOPRIGHT, row.container, TOPRIGHT, 0, 0)
            row.value:SetDimensions(valueColumnWidth, rowHeight)
        end
    end
end

function UI:ApplyAppearance()
    if not self.window then
        return
    end

    local metrics = self:GetCompactMetrics()
    local labelFont = BuildFont("ZoFontGame", Addon.sv.fontSizeLabels + metrics.labelFontDelta)
    local valueFont = BuildFont("ZoFontGameBold", Addon.sv.fontSizeValues + metrics.valueFontDelta)

    self.title:SetFont(BuildFont("ZoFontWinH3", Addon.sv.fontSizeValues + metrics.titleFontExtra))
    self.title:SetColor(Addon.sv.titleColorR, Addon.sv.titleColorG, Addon.sv.titleColorB, Addon.sv.titleColorA)
    self.emptyStateLabel:SetFont(labelFont)
    self.emptyStateLabel:SetColor(Addon.sv.labelColorR, Addon.sv.labelColorG, Addon.sv.labelColorB, Addon.sv.labelColorA)

    for _, section in pairs(self.sections or {}) do
        if section.header then
            section.header:SetFont(BuildFont("ZoFontHeader2", Addon.sv.fontSizeLabels + metrics.sectionFontExtra))
            section.header:SetColor(Addon.sv.labelColorR, Addon.sv.labelColorG, Addon.sv.labelColorB, Addon.sv.labelColorA)
        end

        if section.dividerLeft then
            section.dividerLeft:SetCenterColor(Addon.sv.labelColorR, Addon.sv.labelColorG, Addon.sv.labelColorB, 0.18)
        end

        if section.dividerRight then
            section.dividerRight:SetCenterColor(Addon.sv.labelColorR, Addon.sv.labelColorG, Addon.sv.labelColorB, 0.18)
        end
    end

    for _, row in pairs(self.rows or {}) do
        if row.label then
            row.label:SetFont(labelFont)
            row.label:SetColor(Addon.sv.labelColorR, Addon.sv.labelColorG, Addon.sv.labelColorB, Addon.sv.labelColorA)
        end

        if row.value then
            row.value:SetFont(valueFont)
            row.value:SetColor(Addon.sv.valueColorR, Addon.sv.valueColorG, Addon.sv.valueColorB, Addon.sv.valueColorA)
        end
    end

    self:ApplyWindowWidth(self:GetCurrentWindowWidth())
    self:ApplyWindowHeight(self:GetCurrentWindowHeight())
    self:UpdateResponsiveLayout()

    if self.resizeHandle then
        self.resizeHandle:SetMouseEnabled(Addon.sv.unlocked)
        if self.resizeHandle.grip then
            self.resizeHandle.grip:SetHidden(not Addon.sv.unlocked)
        end
    end
end

function UI:ResetAppearance()
    local defaults = Addon.defaultAppearance
    Addon.sv.fontSizeLabels = defaults.fontSizeLabels
    Addon.sv.fontSizeValues = defaults.fontSizeValues
    Addon.sv.windowWidth = defaults.windowWidth
    Addon.sv.windowHeight = defaults.windowHeight
    Addon.sv.labelColorR = defaults.labelColorR
    Addon.sv.labelColorG = defaults.labelColorG
    Addon.sv.labelColorB = defaults.labelColorB
    Addon.sv.labelColorA = defaults.labelColorA
    Addon.sv.valueColorR = defaults.valueColorR
    Addon.sv.valueColorG = defaults.valueColorG
    Addon.sv.valueColorB = defaults.valueColorB
    Addon.sv.valueColorA = defaults.valueColorA
    Addon.sv.titleColorR = defaults.titleColorR
    Addon.sv.titleColorG = defaults.titleColorG
    Addon.sv.titleColorB = defaults.titleColorB
    Addon.sv.titleColorA = defaults.titleColorA
    self:ApplyAppearance()
    self:RefreshAll()
end

function UI:LayoutRows(parent, rows)
    local metrics = self:GetCompactMetrics()
    local previousVisibleRow = nil
    local visibleCount = 0
    local totalHeight = 0

    for _, row in ipairs(rows) do
        row.container:ClearAnchors()

        if row.desiredVisible ~= true then
            row.container:SetHidden(true)
            row.container:SetHeight(0)
        else
            row.container:SetHidden(false)
            local rowHeight = self:GetRowHeight(row)
            row.container:SetHeight(rowHeight)

            if not previousVisibleRow then
                row.container:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
                row.container:SetAnchor(TOPRIGHT, parent, TOPRIGHT, 0, 0)
            else
                row.container:SetAnchor(TOPLEFT, previousVisibleRow.container, BOTTOMLEFT, 0, metrics.rowSpacing)
                row.container:SetAnchor(TOPRIGHT, previousVisibleRow.container, BOTTOMRIGHT, 0, metrics.rowSpacing)
            end

            previousVisibleRow = row
            visibleCount = visibleCount + 1
            totalHeight = totalHeight + rowHeight + (visibleCount > 1 and metrics.rowSpacing or 0)
        end
    end

    if visibleCount == 0 then
        parent:SetHeight(0)
        return 0
    end

    parent:SetHeight(totalHeight)
    return visibleCount
end

function UI:SetRowVisible(rowKey, isVisible)
    local row = self.rows and self.rows[rowKey]
    if not row then
        return
    end

    row.desiredVisible = (isVisible == true)

    if row.container then
        row.container:SetHidden(not row.desiredVisible)
    end
end

function UI:GetDesiredVisibilityState()
    return {
        dps = Addon.sv.showDps == true,
        damage = Addon.sv.showDamage == true,
        healing = Addon.sv.showHealing == true,
        combat = Addon.sv.showCombatState == true,
        spellCrit = Addon.sv.showSpellCrit == true,
        weaponCrit = Addon.sv.showWeaponCrit == true,
        spellPower = Addon.sv.showSpellPower == true,
        weaponPower = Addon.sv.showWeaponPower == true,
        spellPen = Addon.sv.showSpellPen == true,
        weaponPen = Addon.sv.showWeaponPen == true,
        incomingHealingPercent = Addon.sv.showIncomingHealingPercent == true,
        blockPercent = Addon.sv.showBlockPercent == true,
        blockCost = Addon.sv.showBlockCost == true,
        physicalResistance = Addon.sv.showPhysicalResistance == true,
        spellResistance = Addon.sv.showSpellResistance == true,
        criticalResistance = Addon.sv.showCriticalResistance == true,
    }
end

function UI:HasAnyVisibleRow()
    local visibility = self:GetDesiredVisibilityState()
    for _, isVisible in pairs(visibility) do
        if isVisible then
            return true
        end
    end

    return false
end

function UI:UpdateSectionLayout(section, previousAnchorTarget, topOffset)
    local metrics = self:GetCompactMetrics()
    section:ClearAnchors()
    section:SetAnchor(TOPLEFT, previousAnchorTarget, BOTTOMLEFT, 0, topOffset)
    section:SetAnchor(TOPRIGHT, previousAnchorTarget, BOTTOMRIGHT, 0, topOffset)

    local visibleCount = 0
    for _, row in ipairs(section.rows or {}) do
        if row.desiredVisible == true then
            visibleCount = visibleCount + 1
        end
    end

    local hasVisibleRows = visibleCount > 0

    SetControlHidden(section.headerContainer, not hasVisibleRows)
    SetControlHidden(section.header, not hasVisibleRows)
    SetControlHidden(section.dividerLeft, not hasVisibleRows)
    SetControlHidden(section.dividerRight, not hasVisibleRows)
    SetControlHidden(section.rowsContainer, not hasVisibleRows)
    SetControlHidden(section, not hasVisibleRows)

    if not hasVisibleRows then
        section:SetHeight(0)
        return false
    end

    section:SetHidden(false)
    section:SetHeight(section.headerContainer:GetHeight() + metrics.rowsTopGap + section.rowsContainer:GetHeight())
    return true
end

function UI:UpdateWindowLayout()
    local metrics = self:GetCompactMetrics()
    local totalHeight = metrics.paddingY + self.title:GetHeight() + metrics.paddingY
    local previousAnchorTarget = self.title
    local nextOffset = metrics.titleGap
    local hasAnyVisibleRow = self:HasAnyVisibleRow()

    if not hasAnyVisibleRow then
        totalHeight = totalHeight + zo_max(6, metrics.titleGap - 6) + self.emptyStateLabel:GetHeight()
    end

    local combatVisible = self:UpdateSectionLayout(self.sections.combat, previousAnchorTarget, nextOffset)
    if combatVisible then
        previousAnchorTarget = self.sections.combat
        totalHeight = totalHeight + metrics.titleGap + self.sections.combat:GetHeight()
        nextOffset = metrics.sectionSpacing
    end

    local pveVisible = self:UpdateSectionLayout(self.sections.pveStats, previousAnchorTarget, nextOffset)
    if pveVisible then
        local spacer = combatVisible and metrics.sectionSpacing or metrics.titleGap
        previousAnchorTarget = self.sections.pveStats
        totalHeight = totalHeight + spacer + self.sections.pveStats:GetHeight()
        nextOffset = metrics.sectionSpacing
    end

    local pvpVisible = self:UpdateSectionLayout(self.sections.pvpStats, previousAnchorTarget, nextOffset)
    if pvpVisible then
        local hasPreviousVisible = combatVisible or pveVisible
        local spacer = hasPreviousVisible and metrics.sectionSpacing or metrics.titleGap
        totalHeight = totalHeight + spacer + self.sections.pvpStats:GetHeight()
    end

    local windowWidth = self:GetCurrentWindowWidth()
    local windowHeight = zo_max(self:GetCurrentWindowHeight(), totalHeight)
    self.window:SetDimensions(windowWidth, windowHeight)
    Addon.sv.ui.width = windowWidth
    Addon.sv.ui.height = windowHeight
end

function UI:ReflowSections()
    self:LayoutRows(self.sections.combat.rowsContainer, self.sections.combat.rows)
    self:LayoutRows(self.sections.pveStats.rowsContainer, self.sections.pveStats.rows)
    self:LayoutRows(self.sections.pvpStats.rowsContainer, self.sections.pvpStats.rows)
    self:UpdateWindowLayout()
end

function UI:ApplySavedState()
    if not self.window then
        return
    end

    if IsPreviewModeActive() then
        self:UpdatePreviewLayout()
        return
    end

    self.window:ClearAnchors()
    self.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, Addon.sv.ui.offsetX, Addon.sv.ui.offsetY)
    self.window:SetMovable(Addon.sv.unlocked)
    self.window:SetMouseEnabled(Addon.sv.unlocked)
    self:UpdateSceneVisibility()

    if self.resizeHandle then
        self.resizeHandle:SetMouseEnabled(Addon.sv.unlocked)
        if self.resizeHandle.grip then
            self.resizeHandle.grip:SetHidden(not Addon.sv.unlocked)
        end
    end
end

function UI:SetWindowHidden(hidden)
    Addon.sv.ui.hidden = hidden

    self:UpdateSceneVisibility()

    if not hidden then
        self:RefreshAll()
    end
end

function UI:UpdateSceneVisibility()
    if not self.window then
        return
    end

    if IsPreviewModeActive() then
        self.window:SetHidden(false)
        return
    end

    local shouldShow = (Addon.sv.ui.hidden ~= true) and IsGameplaySceneVisible()
    self.window:SetHidden(not shouldShow)
end

function UI:ResetPosition()
    Addon.sv.ui.offsetX = Addon.sv.defaultOffsetX or Addon.defaultOffsetX
    Addon.sv.ui.offsetY = Addon.sv.defaultOffsetY or Addon.defaultOffsetY
    self:ApplySavedState()
end

function UI:SetRowValue(row, value)
    if row and row.value then
        row.value:SetText(value)
    end
end

function UI:RefreshCombatSection(data)
    local damageTotal = tonumber(data.totalDamage) or 0
    local dpsValue = 0

    if damageTotal > 0 and Addon.sv and Addon.sv.stats then
        local combatStartAt = tonumber(Addon.sv.stats.combatStartAt) or 0
        local combatEndAt = data.inCombat and GetFrameTimeMilliseconds() or (tonumber(Addon.sv.stats.lastCombatEndAt) or 0)
        local durationMs = combatEndAt - combatStartAt

        if combatStartAt > 0 and durationMs > 0 then
            dpsValue = damageTotal / zo_max(durationMs / 1000, 0.001)
        end
    end

    self:SetRowValue(self.combatRows.dps, FormatDps(dpsValue))
    self:SetRowValue(self.combatRows.damage, FormatNumber(data.totalDamage))
    self:SetRowValue(self.combatRows.healing, FormatNumber(data.sessionHealingTotal or data.totalHealing))
    self:SetRowValue(self.combatRows.combat, data.inCombat and GetString(SI_YES) or GetString(SI_NO))
end

function UI:RefreshPveStatsSection(liveStats)
    self:SetRowValue(self.pveRows.spellCrit, FormatPercent(liveStats.spellCritPercent))
    self:SetRowValue(self.pveRows.weaponCrit, FormatPercent(liveStats.weaponCritPercent))
    self:SetRowValue(self.pveRows.spellPower, FormatNumber(liveStats.spellPower))
    self:SetRowValue(self.pveRows.weaponPower, FormatNumber(liveStats.weaponPower))
end

function UI:RefreshPvpStatsSection(liveStats)
    self:SetRowValue(self.pvpRows.spellPen, FormatNumber(liveStats.spellPen))
    self:SetRowValue(self.pvpRows.weaponPen, FormatNumber(liveStats.weaponPen))
    self:SetRowValue(self.pvpRows.incomingHealingPercent, FormatPercent(liveStats.incomingHealingPercent))
    self:SetRowValue(self.pvpRows.blockPercent, FormatPercent(liveStats.blockPercent))
    self:SetRowValue(self.pvpRows.blockCost, FormatNumber(liveStats.blockCost))
    self:SetRowValue(self.pvpRows.physicalResistance, FormatNumber(liveStats.physicalResistance))
    self:SetRowValue(self.pvpRows.spellResistance, FormatNumber(liveStats.spellResistance))
    self:SetRowValue(self.pvpRows.criticalResistance, FormatNumber(liveStats.criticalResistance))
end

function UI:ApplyDesiredVisibility(desiredVisibility)
    self:SetRowVisible("dps", desiredVisibility.dps)
    self:SetRowVisible("damage", desiredVisibility.damage)
    self:SetRowVisible("healing", desiredVisibility.healing)
    self:SetRowVisible("combat", desiredVisibility.combat)
    self:SetRowVisible("spellCrit", desiredVisibility.spellCrit)
    self:SetRowVisible("weaponCrit", desiredVisibility.weaponCrit)
    self:SetRowVisible("spellPower", desiredVisibility.spellPower)
    self:SetRowVisible("weaponPower", desiredVisibility.weaponPower)
    self:SetRowVisible("spellPen", desiredVisibility.spellPen)
    self:SetRowVisible("weaponPen", desiredVisibility.weaponPen)
    self:SetRowVisible("incomingHealingPercent", desiredVisibility.incomingHealingPercent)
    self:SetRowVisible("blockPercent", desiredVisibility.blockPercent)
    self:SetRowVisible("blockCost", desiredVisibility.blockCost)
    self:SetRowVisible("physicalResistance", desiredVisibility.physicalResistance)
    self:SetRowVisible("spellResistance", desiredVisibility.spellResistance)
    self:SetRowVisible("criticalResistance", desiredVisibility.criticalResistance)
end

function UI:RefreshAll()
    if not self.window then
        return
    end

    self:ApplyAppearance()

    local combatData = {
        sessionHealingTotal = 0,
        totalDamage = 0,
        totalHealing = 0,
        inCombat = false,
    }

    if Addon.Combat and Addon.Combat.GetCurrentTotals then
        combatData = Addon.Combat:GetCurrentTotals()
    end

    local liveStats = {
        spellCritPercent = 0,
        weaponCritPercent = 0,
        spellPower = 0,
        weaponPower = 0,
        spellPen = 0,
        weaponPen = 0,
        incomingHealingPercent = 0,
        blockPercent = 0,
        blockCost = 0,
        physicalResistance = 0,
        spellResistance = 0,
        criticalResistance = 0,
    }

    if Addon.Stats and Addon.Stats.GetLiveStats then
        liveStats = Addon.Stats.GetLiveStats()
    end

    local desiredVisibility = self:GetDesiredVisibilityState()
    self:RefreshCombatSection(combatData)
    self:RefreshPveStatsSection(liveStats)
    self:RefreshPvpStatsSection(liveStats)
    self:ApplyDesiredVisibility(desiredVisibility)
    self:ReflowSections()

    self.emptyStateLabel:SetText(GetString(EBPXLIVESTATS_UI_EMPTY))
    self.emptyStateLabel:SetHidden(self:HasAnyVisibleRow())
end

function UI:Refresh()
    self:RefreshAll()
end

function UI:ToggleVisibility()
    if not self.window then
        return
    end

    Addon.sv.ui.hidden = not Addon.sv.ui.hidden
    self:UpdateSceneVisibility()

    if not Addon.sv.ui.hidden then
        self:ApplySavedState()
        self:RefreshAll()
    end
end

function UI:SetUnlocked(unlocked)
    Addon.sv.unlocked = unlocked
    self:ApplySavedState()
end

Addon.HealUI = Addon.HealUI or {}

local HealUI = Addon.HealUI
local HEAL_WINDOW_DEFAULT_WIDTH = 420
local HEAL_WINDOW_DEFAULT_HEIGHT = 360
local HEAL_WINDOW_MIN_WIDTH = 250
local HEAL_WINDOW_MAX_WIDTH = 620
local HEAL_WINDOW_MIN_HEIGHT = 210
local HEAL_WINDOW_MAX_HEIGHT = 720
local HEAL_TOTAL_ROW_HEIGHT = 24
local HEAL_LIST_TOP_OFFSET = 12
local HEAL_LIST_BOTTOM_PADDING = 8
local HEAL_LIST_ROW_HEIGHT = 26
local HEAL_LIST_ROW_SPACING = 4
local HEAL_LIST_ICON_SIZE = 20
local HEAL_LIST_DEFAULT_ICON = "/esoui/art/icons/icon_missing.dds"
local HEAL_VALUE_COLUMN_MIN_WIDTH = 100
local HEAL_VALUE_COLUMN_MAX_WIDTH = 150
local HEAL_ROW_MIN_HEIGHT = 26
local HEAL_ROW_INNER_PADDING_Y = 2

function HealUI:GetCompactMetrics()
    local width = self:GetWindowWidth()

    if width <= 290 then
        return {
            paddingX = 8,
            paddingY = 8,
            trackingGap = 6,
            totalGap = 6,
            dividerGap = 4,
            listTopOffset = 6,
            rowSpacing = 2,
            rowMinHeight = 20,
            totalRowHeight = 20,
            iconSize = 16,
            iconTextGap = 4,
            labelValueGap = 6,
            labelFontDelta = -2,
            valueFontDelta = -2,
            titleFontExtra = 0,
            valueColumnRatio = 0.40,
            valueColumnMin = 64,
            valueColumnMax = 100,
        }
    end

    if width <= 360 then
        return {
            paddingX = 10,
            paddingY = 10,
            trackingGap = 8,
            totalGap = 8,
            dividerGap = 4,
            listTopOffset = 8,
            rowSpacing = 3,
            rowMinHeight = 22,
            totalRowHeight = 22,
            iconSize = 18,
            iconTextGap = 6,
            labelValueGap = 8,
            labelFontDelta = -1,
            valueFontDelta = -1,
            titleFontExtra = 1,
            valueColumnRatio = 0.37,
            valueColumnMin = 72,
            valueColumnMax = 120,
        }
    end

    return {
        paddingX = CONTENT_PADDING_X,
        paddingY = CONTENT_PADDING_Y,
        trackingGap = 10,
        totalGap = 10,
        dividerGap = 6,
        listTopOffset = HEAL_LIST_TOP_OFFSET,
        rowSpacing = HEAL_LIST_ROW_SPACING,
        rowMinHeight = HEAL_ROW_MIN_HEIGHT,
        totalRowHeight = HEAL_TOTAL_ROW_HEIGHT,
        iconSize = HEAL_LIST_ICON_SIZE,
        iconTextGap = 8,
        labelValueGap = 10,
        labelFontDelta = 0,
        valueFontDelta = 0,
        titleFontExtra = 2,
        valueColumnRatio = 0.34,
        valueColumnMin = HEAL_VALUE_COLUMN_MIN_WIDTH,
        valueColumnMax = HEAL_VALUE_COLUMN_MAX_WIDTH,
    }
end

function HealUI:GetSavedState()
    local state = Addon.sv.healWindow or {}
    local defaults = Addon.defaults.healWindow or {}

    Addon.sv.healWindow = state

    for key, value in pairs(defaults) do
        if state[key] == nil then
            state[key] = value
        end
    end

    return state
end

function HealUI:GetWindowWidth()
    local state = self:GetSavedState()
    return zo_clamp(tonumber(state.width) or HEAL_WINDOW_DEFAULT_WIDTH, HEAL_WINDOW_MIN_WIDTH, HEAL_WINDOW_MAX_WIDTH)
end

function HealUI:GetWindowHeight()
    local state = self:GetSavedState()
    return zo_clamp(tonumber(state.height) or HEAL_WINDOW_DEFAULT_HEIGHT, HEAL_WINDOW_MIN_HEIGHT, HEAL_WINDOW_MAX_HEIGHT)
end

function HealUI:ApplyWindowWidth(width)
    local state = self:GetSavedState()
    local resolvedWidth = zo_clamp(tonumber(width) or HEAL_WINDOW_DEFAULT_WIDTH, HEAL_WINDOW_MIN_WIDTH, HEAL_WINDOW_MAX_WIDTH)
    state.width = resolvedWidth

    if self.window then
        self.window:SetWidth(resolvedWidth)
    end

    return resolvedWidth
end

function HealUI:ApplyWindowHeight(height)
    local state = self:GetSavedState()
    local resolvedHeight = zo_clamp(tonumber(height) or HEAL_WINDOW_DEFAULT_HEIGHT, HEAL_WINDOW_MIN_HEIGHT, HEAL_WINDOW_MAX_HEIGHT)
    state.height = resolvedHeight

    if self.window then
        self.window:SetHeight(resolvedHeight)
    end

    return resolvedHeight
end

function HealUI:GetLabelFontSize()
    local state = self:GetSavedState()
    return zo_max(8, zo_floor(tonumber(state.fontSizeLabels) or Addon.defaultHealWindowAppearance.fontSizeLabels))
end

function HealUI:GetValueFontSize()
    local state = self:GetSavedState()
    return zo_max(8, zo_floor(tonumber(state.fontSizeValues) or Addon.defaultHealWindowAppearance.fontSizeValues))
end

function HealUI:GetValueColumnWidth()
    local metrics = self:GetCompactMetrics()
    local contentWidth = self:GetWindowWidth() - (metrics.paddingX * 2)
    local preferredWidth = zo_floor(contentWidth * metrics.valueColumnRatio)
    return zo_clamp(preferredWidth, metrics.valueColumnMin, metrics.valueColumnMax)
end

function HealUI:GetVisibleRowCount()
    if not self.window then
        return 1
    end

    local availableHeight = self:GetAvailableListHeight()
    local metrics = self:GetCompactMetrics()
    local rowFullHeight = metrics.rowMinHeight + metrics.rowSpacing
    return zo_max(1, zo_floor((availableHeight + metrics.rowSpacing) / rowFullHeight))
end

function HealUI:GetAvailableListHeight()
    local metrics = self:GetCompactMetrics()
    local availableHeight = self:GetWindowHeight()
    availableHeight = availableHeight - (metrics.paddingY * 2)
    availableHeight = availableHeight - (self.title and self.title:GetHeight() or 24)
    availableHeight = availableHeight - (self.trackingLabel and self.trackingLabel:GetHeight() or 20)
    availableHeight = availableHeight - metrics.totalRowHeight
    availableHeight = availableHeight - metrics.trackingGap
    availableHeight = availableHeight - metrics.totalGap
    availableHeight = availableHeight - metrics.dividerGap
    availableHeight = availableHeight - metrics.listTopOffset
    availableHeight = availableHeight - HEAL_LIST_BOTTOM_PADDING
    return zo_max(metrics.rowMinHeight, availableHeight)
end

function HealUI:EnsureRowPool(requiredCount)
    local count = zo_max(1, tonumber(requiredCount) or 1)

    while #(self.rows or {}) < count do
        local index = #(self.rows or {}) + 1
        local row = self:CreateBreakdownRow(self.listContainer, index)
        self.rows[index] = row
    end
end

function HealUI:CreateResizeHandle(parent)
    local handle = WINDOW_MANAGER:CreateControl(nil, parent, CT_CONTROL)
    handle:SetDimensions(RESIZE_HANDLE_SIZE, RESIZE_HANDLE_SIZE)
    handle:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, -4, -4)
    handle:SetMouseEnabled(true)
    handle:SetHandler("OnMouseDown", function(_, button)
        local state = self:GetSavedState()
        if button ~= MOUSE_BUTTON_INDEX_LEFT or state.unlocked ~= true then
            return
        end

        self.isResizing = true
        self.resizeStartMouseX = GetSafeUIMouseX()
        self.resizeStartMouseY = GetSafeUIMouseY()
        self.resizeStartWidth = self:GetWindowWidth()
        self.resizeStartHeight = self:GetWindowHeight()
    end)
    handle:SetHandler("OnMouseUp", function(_, button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT or not self.isResizing then
            return
        end

        self.isResizing = false
        self:ApplyWindowWidth(self:GetWindowWidth())
        self:ApplyWindowHeight(self:GetWindowHeight())
        self:RefreshAll()
    end)

    local grip = WINDOW_MANAGER:CreateControl(nil, handle, CT_LABEL)
    grip:SetAnchor(BOTTOMRIGHT, handle, BOTTOMRIGHT, 0, 0)
    grip:SetFont("ZoFontGameSmall")
    grip:SetColor(1, 1, 1, 0.35)
    grip:SetText("//")

    handle.grip = grip
    return handle
end

function HealUI:GetBreakdownData()
    if Addon.Combat and Addon.Combat.GetGroupedHealingBreakdown then
        return Addon.Combat:GetGroupedHealingBreakdown()
    end

    return {
        totalHeal = 0,
        entries = {},
    }
end

function HealUI:Initialize()
    self.scrollOffset = 0
    self:CreateWindow()
    RegisterGameplaySceneCallbacks("heal_window", function()
        self:UpdateSceneVisibility()
    end)
    self:ApplyAppearance()
    self:ApplySavedState()
    self:RefreshAll()
end

function HealUI:CreateWindow()
    if self.window then
        return
    end

    local state = self:GetSavedState()
    local window = WINDOW_MANAGER:CreateTopLevelWindow("EBPixartLiveStatsHealWindow")
    window:SetDimensions(self:GetWindowWidth(), self:GetWindowHeight())
    window:SetClampedToScreen(true)
    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetHidden(state.hidden)
    window:SetHandler("OnMoveStop", function(control)
        local savedState = self:GetSavedState()
        savedState.offsetX = control:GetLeft()
        savedState.offsetY = control:GetTop()
    end)
    window:SetHandler("OnMouseUp", function(_, button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT or not self.isResizing then
            return
        end

        self.isResizing = false
        self:ApplyWindowWidth(self:GetWindowWidth())
        self:ApplyWindowHeight(self:GetWindowHeight())
        self:RefreshAll()
    end)
    window:SetHandler("OnUpdate", function()
        if not self.isResizing then
            return
        end

        local currentMouseX = GetSafeUIMouseX()
        local currentMouseY = GetSafeUIMouseY()
        local deltaX = currentMouseX - self.resizeStartMouseX
        local deltaY = currentMouseY - self.resizeStartMouseY
        self:ApplyWindowWidth(self.resizeStartWidth + deltaX)
        self:ApplyWindowHeight(self.resizeStartHeight + deltaY)
        self:RefreshLayout()
        self:RefreshRows(self.currentEntries or {})
    end)

    local backdrop = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    backdrop:SetAnchorFill(window)
    backdrop:SetCenterColor(0.04, 0.04, 0.05, 0.82)
    backdrop:SetEdgeColor(1, 1, 1, 0.12)
    backdrop:SetEdgeTexture(nil, 1, 1, 1)
    backdrop:SetInsets(-1, -1, 1, 1)

    local content = WINDOW_MANAGER:CreateControl(nil, window, CT_CONTROL)
    content:ClearAnchors()
    content:SetAnchor(TOPLEFT, window, TOPLEFT, CONTENT_PADDING_X, CONTENT_PADDING_Y)
    content:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -CONTENT_PADDING_X, -CONTENT_PADDING_Y)

    local title = WINDOW_MANAGER:CreateControl(nil, content, CT_LABEL)
    title:SetAnchor(TOPLEFT, content, TOPLEFT, 0, 0)
    title:SetAnchor(TOPRIGHT, content, TOPRIGHT, 0, 0)
    title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    title:SetText("EBPixart Analyse des soins")

    local trackingLabel = WINDOW_MANAGER:CreateControl(nil, content, CT_LABEL)
    trackingLabel:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 10)
    trackingLabel:SetAnchor(TOPRIGHT, title, BOTTOMRIGHT, 0, 10)
    trackingLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    trackingLabel:SetText("Suivi : OFF")

    local totalRow = WINDOW_MANAGER:CreateControl(nil, content, CT_CONTROL)
    totalRow:SetAnchor(TOPLEFT, trackingLabel, BOTTOMLEFT, 0, 10)
    totalRow:SetAnchor(TOPRIGHT, trackingLabel, BOTTOMRIGHT, 0, 10)
    totalRow:SetHeight(HEAL_TOTAL_ROW_HEIGHT)

    local totalLabel = WINDOW_MANAGER:CreateControl(nil, totalRow, CT_LABEL)
    totalLabel:SetAnchor(LEFT, totalRow, LEFT, 0, 0)
    totalLabel:SetAnchor(RIGHT, totalRow, RIGHT, -120, 0)
    totalLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    totalLabel:SetText("Heal total")

    local totalValue = WINDOW_MANAGER:CreateControl(nil, totalRow, CT_LABEL)
    totalValue:SetAnchor(TOPRIGHT, totalRow, TOPRIGHT, 0, 0)
    totalValue:SetDimensions(120, HEAL_TOTAL_ROW_HEIGHT)
    totalValue:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    totalValue:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    totalValue:SetText("0")

    local divider = WINDOW_MANAGER:CreateControl(nil, content, CT_BACKDROP)
    divider:SetAnchor(TOPLEFT, totalRow, BOTTOMLEFT, 0, 6)
    divider:SetAnchor(TOPRIGHT, totalRow, BOTTOMRIGHT, 0, 6)
    divider:SetHeight(1)
    divider:SetCenterColor(1, 1, 1, 0.08)
    divider:SetEdgeColor(0, 0, 0, 0)

    local listContainer = WINDOW_MANAGER:CreateControl(nil, content, CT_CONTROL)
    listContainer:ClearAnchors()
    listContainer:SetAnchor(TOPLEFT, divider, BOTTOMLEFT, 0, HEAL_LIST_TOP_OFFSET)
    listContainer:SetAnchor(BOTTOMRIGHT, content, BOTTOMRIGHT, 0, 0)
    listContainer:SetMouseEnabled(true)

    local emptyLabel = WINDOW_MANAGER:CreateControl(nil, listContainer, CT_LABEL)
    emptyLabel:SetAnchor(TOPLEFT, listContainer, TOPLEFT, 0, 0)
    emptyLabel:SetAnchor(TOPRIGHT, listContainer, TOPRIGHT, 0, 0)
    emptyLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    emptyLabel:SetHidden(true)

    local resizeHandle = self:CreateResizeHandle(window)

    self.window = window
    self.backdrop = backdrop
    self.content = content
    self.title = title
    self.trackingLabel = trackingLabel
    self.totalRow = totalRow
    self.totalLabel = totalLabel
    self.totalValue = totalValue
    self.divider = divider
    self.listContainer = listContainer
    self.emptyLabel = emptyLabel
    self.resizeHandle = resizeHandle
    self.rows = {}
    self:EnsureRowPool(self:GetVisibleRowCount())

    listContainer:SetHandler("OnMouseWheel", function(_, delta)
        self:OnMouseWheel(delta)
    end)
end

function HealUI:CreateBreakdownRow(parent, index)
    local container = WINDOW_MANAGER:CreateControl(nil, parent, CT_CONTROL)
    container:SetHeight(HEAL_LIST_ROW_HEIGHT)

    if index == 1 then
        container:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
        container:SetAnchor(TOPRIGHT, parent, TOPRIGHT, 0, 0)
    else
        container:SetAnchor(TOPLEFT, self.rows[index - 1].container, BOTTOMLEFT, 0, HEAL_LIST_ROW_SPACING)
        container:SetAnchor(TOPRIGHT, self.rows[index - 1].container, BOTTOMRIGHT, 0, HEAL_LIST_ROW_SPACING)
    end

    local icon = WINDOW_MANAGER:CreateControl(nil, container, CT_TEXTURE)
    icon:SetAnchor(LEFT, container, LEFT, 0, 0)
    icon:SetDimensions(HEAL_LIST_ICON_SIZE, HEAL_LIST_ICON_SIZE)
    icon:SetTexture(HEAL_LIST_DEFAULT_ICON)

    local value = WINDOW_MANAGER:CreateControl(nil, container, CT_LABEL)
    value:SetAnchor(TOPRIGHT, container, TOPRIGHT, 0, 0)
    value:SetDimensions(120, HEAL_LIST_ROW_HEIGHT)
    value:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    value:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    value:SetText("0")

    local name = WINDOW_MANAGER:CreateControl(nil, container, CT_LABEL)
    name:SetAnchor(TOPLEFT, icon, TOPRIGHT, 8, 0)
    name:SetAnchor(TOPRIGHT, value, TOPLEFT, -10, 0)
    name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    name:SetVerticalAlignment(TEXT_ALIGN_TOP)
    name:SetText("-")

    return {
        container = container,
        icon = icon,
        name = name,
        value = value,
    }
end

function HealUI:GetBreakdownRowHeight(row)
    if not row or not row.container then
        return HEAL_ROW_MIN_HEIGHT
    end

    local metrics = self:GetCompactMetrics()

    local iconHeight = metrics.iconSize
    local nameHeight = metrics.rowMinHeight
    local valueHeight = metrics.rowMinHeight

    if row.name and row.name.GetTextHeight then
        nameHeight = zo_max(metrics.rowMinHeight, zo_ceil((row.name:GetTextHeight() or 0) + HEAL_ROW_INNER_PADDING_Y))
    end

    if row.value and row.value.GetTextHeight then
        valueHeight = zo_max(metrics.rowMinHeight, zo_ceil((row.value:GetTextHeight() or 0) + HEAL_ROW_INNER_PADDING_Y))
    end

    return zo_max(iconHeight, nameHeight, valueHeight)
end

function HealUI:RefreshLayout()
    if not self.window then
        return
    end

    local metrics = self:GetCompactMetrics()
    self.window:SetDimensions(self:GetWindowWidth(), self:GetWindowHeight())
    self:EnsureRowPool(self:GetVisibleRowCount())

    local valueColumnWidth = self:GetValueColumnWidth()

    if self.content then
        self.content:ClearAnchors()
        self.content:SetAnchor(TOPLEFT, self.window, TOPLEFT, metrics.paddingX, metrics.paddingY)
        self.content:SetAnchor(BOTTOMRIGHT, self.window, BOTTOMRIGHT, -metrics.paddingX, -metrics.paddingY)
    end

    if self.trackingLabel then
        self.trackingLabel:ClearAnchors()
        self.trackingLabel:SetAnchor(TOPLEFT, self.title, BOTTOMLEFT, 0, metrics.trackingGap)
        self.trackingLabel:SetAnchor(TOPRIGHT, self.title, BOTTOMRIGHT, 0, metrics.trackingGap)
    end

    if self.totalRow then
        self.totalRow:ClearAnchors()
        self.totalRow:SetAnchor(TOPLEFT, self.trackingLabel, BOTTOMLEFT, 0, metrics.totalGap)
        self.totalRow:SetAnchor(TOPRIGHT, self.trackingLabel, BOTTOMRIGHT, 0, metrics.totalGap)
        self.totalRow:SetHeight(metrics.totalRowHeight)
    end

    if self.listContainer then
        self.listContainer:ClearAnchors()
        self.listContainer:SetAnchor(TOPLEFT, self.divider, BOTTOMLEFT, 0, metrics.listTopOffset)
        self.listContainer:SetAnchor(BOTTOMRIGHT, self.content, BOTTOMRIGHT, 0, 0)
    end

    self.totalLabel:ClearAnchors()
    self.totalLabel:SetAnchor(LEFT, self.totalRow, LEFT, 0, 0)
    self.totalLabel:SetAnchor(RIGHT, self.totalRow, RIGHT, -(valueColumnWidth + metrics.labelValueGap), 0)

    self.totalValue:ClearAnchors()
    self.totalValue:SetAnchor(TOPRIGHT, self.totalRow, TOPRIGHT, 0, 0)
    self.totalValue:SetDimensions(valueColumnWidth, metrics.totalRowHeight)

    for index, row in ipairs(self.rows or {}) do
        row.container:ClearAnchors()
        row.container:SetHeight(metrics.rowMinHeight)

        if index == 1 then
            row.container:SetAnchor(TOPLEFT, self.listContainer, TOPLEFT, 0, 0)
            row.container:SetAnchor(TOPRIGHT, self.listContainer, TOPRIGHT, 0, 0)
        else
            row.container:SetAnchor(TOPLEFT, self.rows[index - 1].container, BOTTOMLEFT, 0, metrics.rowSpacing)
            row.container:SetAnchor(TOPRIGHT, self.rows[index - 1].container, BOTTOMRIGHT, 0, metrics.rowSpacing)
        end

        row.icon:SetDimensions(metrics.iconSize, metrics.iconSize)

        row.value:ClearAnchors()
        row.value:SetAnchor(TOPRIGHT, row.container, TOPRIGHT, 0, 0)
        row.value:SetDimensions(valueColumnWidth, zo_max(metrics.rowMinHeight, row.container:GetHeight()))

        row.name:ClearAnchors()
        row.name:SetAnchor(TOPLEFT, row.icon, TOPRIGHT, metrics.iconTextGap, 0)
        row.name:SetAnchor(TOPRIGHT, row.value, TOPLEFT, -metrics.labelValueGap, 0)
    end
end

function HealUI:ApplyAppearance()
    if not self.window then
        return
    end

    local state = self:GetSavedState()
    local metrics = self:GetCompactMetrics()
    local labelFont = BuildFont("ZoFontGame", self:GetLabelFontSize() + metrics.labelFontDelta)
    local valueFont = BuildFont("ZoFontGameBold", self:GetValueFontSize() + metrics.valueFontDelta)

    self.title:SetFont(BuildFont("ZoFontWinH3", self:GetValueFontSize() + metrics.titleFontExtra))
    self.title:SetColor(state.titleColorR, state.titleColorG, state.titleColorB, state.titleColorA)

    self.trackingLabel:SetFont(labelFont)
    self.trackingLabel:SetColor(state.labelColorR, state.labelColorG, state.labelColorB, state.labelColorA)
    self.totalLabel:SetFont(labelFont)
    self.totalLabel:SetColor(state.labelColorR, state.labelColorG, state.labelColorB, state.labelColorA)
    self.totalValue:SetFont(valueFont)
    self.totalValue:SetColor(state.valueColorR, state.valueColorG, state.valueColorB, state.valueColorA)
    self.emptyLabel:SetFont(labelFont)
    self.emptyLabel:SetColor(state.labelColorR, state.labelColorG, state.labelColorB, state.labelColorA)

    for _, row in ipairs(self.rows or {}) do
        row.name:SetFont(labelFont)
        row.name:SetColor(state.labelColorR, state.labelColorG, state.labelColorB, state.labelColorA)
        row.value:SetFont(valueFont)
        row.value:SetColor(state.valueColorR, state.valueColorG, state.valueColorB, state.valueColorA)
    end

    if self.resizeHandle then
        self.resizeHandle:SetMouseEnabled(state.unlocked == true)
        if self.resizeHandle.grip then
            self.resizeHandle.grip:SetHidden(state.unlocked ~= true)
        end
    end

    self:RefreshLayout()
end

function HealUI:ResetAppearance()
    local state = self:GetSavedState()
    local defaults = Addon.defaultHealWindowAppearance

    state.fontSizeLabels = defaults.fontSizeLabels
    state.fontSizeValues = defaults.fontSizeValues
    state.width = defaults.width
    state.height = defaults.height
    state.labelColorR = defaults.labelColorR
    state.labelColorG = defaults.labelColorG
    state.labelColorB = defaults.labelColorB
    state.labelColorA = defaults.labelColorA
    state.valueColorR = defaults.valueColorR
    state.valueColorG = defaults.valueColorG
    state.valueColorB = defaults.valueColorB
    state.valueColorA = defaults.valueColorA
    state.titleColorR = defaults.titleColorR
    state.titleColorG = defaults.titleColorG
    state.titleColorB = defaults.titleColorB
    state.titleColorA = defaults.titleColorA

    self:RefreshAll()
end

function HealUI:ApplySavedState()
    if not self.window then
        return
    end

    if IsPreviewModeActive() then
        if Addon.UI and Addon.UI.UpdatePreviewLayout then
            Addon.UI:UpdatePreviewLayout()
        end
        return
    end

    local state = self:GetSavedState()
    self.window:ClearAnchors()
    self.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, state.offsetX, state.offsetY)
    self.window:SetMovable(state.unlocked == true)
    self:UpdateSceneVisibility()

    if self.resizeHandle then
        self.resizeHandle:SetMouseEnabled(state.unlocked == true)
        if self.resizeHandle.grip then
            self.resizeHandle.grip:SetHidden(state.unlocked ~= true)
        end
    end
end

function HealUI:ResetPosition()
    local state = self:GetSavedState()
    state.offsetX = Addon.defaultHealWindowOffsetX
    state.offsetY = Addon.defaultHealWindowOffsetY
    self:ApplySavedState()
end

function HealUI:SetUnlocked(unlocked)
    local state = self:GetSavedState()
    state.unlocked = unlocked == true
    self:ApplySavedState()
end

function HealUI:SetWindowHidden(hidden)
    local state = self:GetSavedState()
    state.hidden = hidden == true

    self:UpdateSceneVisibility()

    if not state.hidden then
        self:RefreshAll()
    end
end

function HealUI:UpdateSceneVisibility()
    if not self.window then
        return
    end

    if IsPreviewModeActive() then
        self.window:SetHidden(false)
        return
    end

    local state = self:GetSavedState()
    local shouldShow = (state.hidden ~= true) and IsGameplaySceneVisible()
    self.window:SetHidden(not shouldShow)
end

function HealUI:ToggleVisibility()
    local state = self:GetSavedState()
    self:SetWindowHidden(not state.hidden)
end

function HealUI:OnMouseWheel(delta)
    local entries = self.currentEntries or {}
    local visibleRowCount = self.lastVisibleRowCount or self:GetVisibleRowCount()
    local maxOffset = zo_max(#entries - visibleRowCount, 0)

    if maxOffset <= 0 then
        self.scrollOffset = 0
        return
    end

    local nextOffset = (self.scrollOffset or 0) - (delta or 0)
    self.scrollOffset = zo_clamp(nextOffset, 0, maxOffset)
    self:RefreshRows(entries)
end

function HealUI:RefreshRows(entries)
    local metrics = self:GetCompactMetrics()
    local visibleRowCount = self:GetVisibleRowCount()
    self:EnsureRowPool(visibleRowCount)
    local maxOffset = zo_max(#entries - visibleRowCount, 0)
    self.scrollOffset = zo_clamp(self.scrollOffset or 0, 0, maxOffset)

    local previousVisibleRow = nil
    local consumedHeight = 0
    local availableHeight = self:GetAvailableListHeight()
    local shownCount = 0

    for index, row in ipairs(self.rows or {}) do
        local entry = entries[index + self.scrollOffset]

        if entry then
            row.icon:SetTexture((entry.icon and entry.icon ~= "") and entry.icon or HEAL_LIST_DEFAULT_ICON)
            row.name:SetText(entry.displayName or string.format("Ability #%s", tostring(entry.abilityId or 0)))
            row.value:SetText(FormatNumber(entry.totalHeal))

            local rowHeight = self:GetBreakdownRowHeight(row)
            local nextHeight = consumedHeight + (shownCount > 0 and metrics.rowSpacing or 0) + rowHeight

            if shownCount == 0 or nextHeight <= availableHeight then
                row.container:SetHidden(false)
                row.container:ClearAnchors()
                row.container:SetHeight(rowHeight)

                if not previousVisibleRow then
                    row.container:SetAnchor(TOPLEFT, self.listContainer, TOPLEFT, 0, 0)
                    row.container:SetAnchor(TOPRIGHT, self.listContainer, TOPRIGHT, 0, 0)
                else
                    row.container:SetAnchor(TOPLEFT, previousVisibleRow.container, BOTTOMLEFT, 0, metrics.rowSpacing)
                    row.container:SetAnchor(TOPRIGHT, previousVisibleRow.container, BOTTOMRIGHT, 0, metrics.rowSpacing)
                end

                row.value:ClearAnchors()
                row.value:SetAnchor(TOPRIGHT, row.container, TOPRIGHT, 0, 0)
                row.value:SetDimensions(self:GetValueColumnWidth(), rowHeight)

                row.name:ClearAnchors()
                row.name:SetAnchor(TOPLEFT, row.icon, TOPRIGHT, metrics.iconTextGap, 0)
                row.name:SetAnchor(TOPRIGHT, row.value, TOPLEFT, -metrics.labelValueGap, 0)

                previousVisibleRow = row
                shownCount = shownCount + 1
                consumedHeight = nextHeight
            else
                row.container:SetHidden(true)
            end
        else
            row.container:SetHidden(true)
        end
    end

    self.lastVisibleRowCount = zo_max(1, shownCount)

    self.emptyLabel:SetHidden(true)
end

function HealUI:RefreshAll()
    if not self.window then
        return
    end

    self:ApplyAppearance()

    local breakdown = self:GetBreakdownData()
    local entries = breakdown.entries or {}
    local isTracking = Addon.Combat and Addon.Combat.IsHealAnalysisTracking and Addon.Combat:IsHealAnalysisTracking()

    self.currentEntries = entries
    self.trackingLabel:SetText(string.format("Suivi : %s", isTracking and "ON" or "OFF"))
    self.totalValue:SetText(FormatNumber(breakdown.totalHeal or 0))
    self:RefreshRows(entries)
end
