Greed_Addon = Greed_Addon or {}
local Greed = Greed_Addon
local Internal = Greed.Internal
local T = Internal.T
local GetClientLanguageCode = Internal.GetClientLanguageCode
local SLOT_SIZE = Internal.SLOT_SIZE
local SLOT_GAP = Internal.SLOT_GAP
local ROW_HEIGHT = Internal.ROW_HEIGHT
local SLOT_START_X = Internal.SLOT_START_X
local MAIN_WINDOW_DEFAULT_WIDTH = Internal.MAIN_WINDOW_DEFAULT_WIDTH
local MAIN_WINDOW_DEFAULT_HEIGHT = Internal.MAIN_WINDOW_DEFAULT_HEIGHT
local MAIN_WINDOW_ROWS_TOP = Internal.MAIN_WINDOW_ROWS_TOP
local MAIN_WINDOW_SLOT_HEADER_TOP = Internal.MAIN_WINDOW_SLOT_HEADER_TOP
local MAIN_WINDOW_FOOTER_HEIGHT = Internal.MAIN_WINDOW_FOOTER_HEIGHT
local MAIN_WINDOW_FOOTER_BOTTOM = Internal.MAIN_WINDOW_FOOTER_BOTTOM
local MAIN_WINDOW_TABS_Y = Internal.MAIN_WINDOW_TABS_Y
local MAIN_SCROLLBAR_WINDOW_RIGHT_INSET = Internal.MAIN_SCROLLBAR_WINDOW_RIGHT_INSET
local MAIN_ROWS_LEFT_INSET = Internal.MAIN_ROWS_LEFT_INSET
local MAIN_ROWS_RIGHT_INSET = Internal.MAIN_ROWS_RIGHT_INSET
local FOOTER_LEGEND_GROUP_WIDTH = Internal.FOOTER_LEGEND_GROUP_WIDTH
local FOOTER_LEGEND_ITEM_SPACING = Internal.FOOTER_LEGEND_ITEM_SPACING
local COLORS = Internal.COLORS
local CallControlMethod = Internal.CallControlMethod
local GetControlDimension = Internal.GetControlDimension
local SetBackdropStyle = Internal.SetBackdropStyle
local SetTransparentCheckBackdrop = Internal.SetTransparentCheckBackdrop
local SetButtonText = Internal.SetButtonText
local GetControlTextWidth = Internal.GetControlTextWidth
local SetSimpleTooltip = Internal.SetSimpleTooltip

function Greed:PositionTitleByline()
    local title = GreedWindowTitleBarTitle
    local byline = GreedWindowTitleBarByline

    if not title or not byline then return end

    title:SetText("GREED")
    title:SetFont("ZoFontWinH2")
    byline:SetText("by Previsible")
    byline:SetFont("ZoFontGameSmall")

    local titleWidth = 72
    if type(title.GetTextWidth) == "function" then
        titleWidth = title:GetTextWidth()
    end
    if type(titleWidth) ~= "number" or titleWidth <= 0 then
        titleWidth = 72
    end
    titleWidth = math.ceil(titleWidth)

    local titleControlWidth = math.max(86, titleWidth + 12)
    local titleHeight = 34
    local titleX = 18
    local titleY = 12
    local bylineOffsetX = 3
    local bylineOffsetY = 5
    local titleBar = GreedWindowTitleBar
    if not titleBar and type(title.GetParent) == "function" then
        titleBar = title:GetParent()
    end
    titleBar = titleBar or GreedWindow

    title:ClearAnchors()
    title:SetDimensions(titleControlWidth, titleHeight)
    byline:ClearAnchors()
    byline:SetDimensions(100, 20)

    local language = GetClientLanguageCode()
    if language == "zh" then
        local titleOffsetX = -17
        local titleOffsetY = -12
        local bylineOffsetYForLanguage = -14
        title:SetAnchor(TOPLEFT, titleBar, TOPLEFT, titleX + titleOffsetX, titleY + titleOffsetY)
        byline:SetAnchor(LEFT, titleBar, TOPLEFT,
            titleX + titleWidth + bylineOffsetX,
            titleY + (titleHeight / 2) + bylineOffsetY + bylineOffsetYForLanguage)
    else
        local sharedOffsetX = -20
        local sharedOffsetY = -20
        title:SetAnchor(TOPLEFT, titleBar, TOPLEFT, titleX + sharedOffsetX, titleY + sharedOffsetY)
        byline:SetAnchor(LEFT, title, LEFT, titleWidth + bylineOffsetX, bylineOffsetY)
    end
end

function Greed:BuildTabs()
    local favoritesButton = self.controls.tabs.favorites
    if favoritesButton then
        favoritesButton:SetHidden(true)
        favoritesButton:SetMouseEnabled(false)
        favoritesButton:SetHandler("OnClicked", nil)
    end

    if GreedWindowTabs then
        GreedWindowTabs:SetDimensions(292, 34)
    end

    local logButton = self.controls.tabs.statistics
    if logButton then
        logButton:SetHidden(false)
        logButton:SetMouseEnabled(true)
        logButton:ClearAnchors()
        logButton:SetDimensions(84, 30)
        logButton:SetAnchor(LEFT, GreedWindowTabs, LEFT, 0, 0)
        SetButtonText(logButton, T("Log"))
        logButton:SetHandler("OnClicked", function()
            self:SelectTab("statistics")
        end)
    end

    local listButton = self.controls.tabs.sets
    if listButton then
        listButton:SetHidden(false)
        listButton:SetMouseEnabled(true)
        listButton:ClearAnchors()
        listButton:SetDimensions(84, 30)
        listButton:SetAnchor(LEFT, logButton or GreedWindowTabs, RIGHT, 8, 0)
        SetButtonText(listButton, T("List"))
        SetSimpleTooltip(listButton, T("Sources to Farm"))
        listButton:SetHandler("OnClicked", function()
            self:SelectTab("sets")
        end)
    end

    local optionsButton = self.controls.tabs.options
    if optionsButton then
        optionsButton:SetHidden(false)
        optionsButton:SetMouseEnabled(true)
        optionsButton:ClearAnchors()
        optionsButton:SetDimensions(108, 30)
        optionsButton:SetAnchor(LEFT, listButton or logButton or GreedWindowTabs, RIGHT, 8, 0)
        SetButtonText(optionsButton, T("Options"))
        optionsButton:SetHandler("OnClicked", function()
            self:SelectTab("options")
        end)
    end

    self.activeTab = "grid"
    for key, button in pairs(self.controls.tabs) do
        local color = key == self.activeTab and COLORS.activeTab or COLORS.inactiveTab
        button:SetNormalFontColor(color[1], color[2], color[3], color[4])
    end
    self:LiftMainTopControls()
end

function Greed:UpdateMainWindowLayout()
    if not self.controls then return end

    local minRowsWidth = self:GetDynamicRowsWidth()
    local minWidth, maxWidth, minHeight, maxHeight = self:GetMainWindowSizeBounds(minRowsWidth)
    local currentWidth = self.controls.window and GetControlDimension(self.controls.window, "GetWidth", MAIN_WINDOW_DEFAULT_WIDTH) or MAIN_WINDOW_DEFAULT_WIDTH
    local currentHeight = self.controls.window and GetControlDimension(self.controls.window, "GetHeight", MAIN_WINDOW_DEFAULT_HEIGHT) or MAIN_WINDOW_DEFAULT_HEIGHT
    local windowWidth = math.max(minWidth, math.min(maxWidth, currentWidth))
    local windowHeight = math.max(minHeight, math.min(maxHeight, currentHeight))
    local rowsWidth = math.max(minRowsWidth, windowWidth - MAIN_ROWS_LEFT_INSET - MAIN_ROWS_RIGHT_INSET)
    local rowContentWidth = self:GetMainRowsContentWidth(rowsWidth)
    local rowsHeight = self:GetMainRowsViewportHeight(windowHeight)

    if self.controls.window then
        self.controls.window:SetDimensions(windowWidth, windowHeight)
    end

    if self.controls.titleBar then
        self.controls.titleBar:SetDimensions(windowWidth, 48)
    end

    if GreedWindowTabs then
        GreedWindowTabs:ClearAnchors()
        GreedWindowTabs:SetAnchor(TOPLEFT, self.controls.window, TOPLEFT, 18, MAIN_WINDOW_TABS_Y)
    end
    if self.controls.newPage then
        self.controls.newPage:ClearAnchors()
        self.controls.newPage:SetAnchor(TOPRIGHT, self.controls.window, TOPRIGHT, -20, MAIN_WINDOW_TABS_Y)
    end
    if self.controls.pageDropdown then
        self.controls.pageDropdown:ClearAnchors()
        self.controls.pageDropdown:SetAnchor(TOPRIGHT, self.controls.window, TOPRIGHT, -150, MAIN_WINDOW_TABS_Y)
    end

    if self.controls.rows then
        self.controls.rows:ClearAnchors()
        self.controls.rows:SetAnchor(TOPLEFT, self.controls.window, TOPLEFT, MAIN_ROWS_LEFT_INSET, MAIN_WINDOW_ROWS_TOP)
        self.controls.rows:SetDimensions(rowsWidth, rowsHeight)
    end

    if self.controls.footer then
        self.controls.footer:ClearAnchors()
        self.controls.footer:SetAnchor(BOTTOMLEFT, self.controls.window, BOTTOMLEFT, MAIN_ROWS_LEFT_INSET, -MAIN_WINDOW_FOOTER_BOTTOM)
        self.controls.footer:SetDimensions(rowsWidth, MAIN_WINDOW_FOOTER_HEIGHT)
    end
    self:LayoutFooterLegend()

    if self.controls.slotHeader then
        self.controls.slotHeader:ClearAnchors()
        self.controls.slotHeader:SetAnchor(TOPLEFT, self.controls.window, TOPLEFT, MAIN_ROWS_LEFT_INSET + SLOT_START_X, MAIN_WINDOW_SLOT_HEADER_TOP)
        self.controls.slotHeader:SetDimensions(math.max(0, rowContentWidth - SLOT_START_X), GetControlDimension(self.controls.slotHeader, "GetHeight", 22))
    end

    for _, row in ipairs(self.favoriteRows or {}) do
        if row then
            row:SetDimensions(rowContentWidth, ROW_HEIGHT)
        end
    end

    if self.controls.scrollTrack and self.controls.rows then
        self.controls.scrollTrack:ClearAnchors()
        self.controls.scrollTrack:SetAnchor(TOPRIGHT, self.controls.window or self.controls.rows, TOPRIGHT, -MAIN_SCROLLBAR_WINDOW_RIGHT_INSET, MAIN_WINDOW_ROWS_TOP)
    end
    if self.controls.rowsContent then
        self:UpdateRowsScrollLimits(#(self.displayFavorites or {}))
    end
    self:LayoutMainWindowResizeControls()
    self:LiftMainTopControls()
end

function Greed:BuildSlotHeader()
    for _, label in ipairs(self.slotHeaderLabels or {}) do
        label:SetHidden(true)
    end

    self.slotHeaderLabels = {}
    self.slotHeaderBuildId = (self.slotHeaderBuildId or 0) + 1

    for index, slot in ipairs(self.visibleColumns) do
        local label = WINDOW_MANAGER:CreateControl("GreedSlotHeader" .. self.slotHeaderBuildId .. "_" .. index, self.controls.slotHeader, CT_LABEL)
        self.slotHeaderLabels[index] = label
        label:SetDimensions(SLOT_SIZE, 18)
        label:SetAnchor(TOPLEFT, self.controls.slotHeader, TOPLEFT, (index - 1) * (SLOT_SIZE + SLOT_GAP), 0)
        label:SetFont("ZoFontGameSmall")
        label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        label:SetColor(COLORS.mutedText[1], COLORS.mutedText[2], COLORS.mutedText[3], COLORS.mutedText[4])
        label:SetText(slot.shortLabel or slot.label)
    end
end

function Greed:GetFooterLegendVisualWidth()
    local controls = self.footerLegendControls
    if controls and controls.stickerBookLabel then
        local stickerTextWidth = GetControlTextWidth(controls.stickerBookLabel, 118)
        return FOOTER_LEGEND_ITEM_SPACING + 28 + 8 + stickerTextWidth
    end

    return FOOTER_LEGEND_GROUP_WIDTH
end

function Greed:GetFooterLegendStartX()
    local footerWidth = GetControlDimension(self.controls and self.controls.footer, "GetWidth", 944)
    local groupWidth = self:GetFooterLegendVisualWidth()
    return math.max(56, math.floor((footerWidth - groupWidth) / 2))
end

function Greed:LayoutFooterLegend()
    local controls = self.footerLegendControls
    if not controls or not self.controls or not self.controls.footer then return end

    local startX = self:GetFooterLegendStartX()
    if controls.collectedSwatch then
        controls.collectedSwatch:ClearAnchors()
        controls.collectedSwatch:SetAnchor(BOTTOMLEFT, self.controls.footer, BOTTOMLEFT, startX, -2)
    end
    if controls.collectedLabel and controls.collectedSwatch then
        controls.collectedLabel:ClearAnchors()
        controls.collectedLabel:SetAnchor(LEFT, controls.collectedSwatch, RIGHT, 8, 0)
    end
    if controls.stickerBookSwatch then
        controls.stickerBookSwatch:ClearAnchors()
        controls.stickerBookSwatch:SetAnchor(BOTTOMLEFT, self.controls.footer, BOTTOMLEFT, startX + FOOTER_LEGEND_ITEM_SPACING, -2)
    end
    if controls.stickerBookLabel and controls.stickerBookSwatch then
        controls.stickerBookLabel:ClearAnchors()
        controls.stickerBookLabel:SetAnchor(LEFT, controls.stickerBookSwatch, RIGHT, 8, 0)
    end
end

function Greed:BuildFooter()
    self.legendGoldBorder = nil
    local startX = self:GetFooterLegendStartX()
    local collectedSwatch, collectedLabel = self:CreateCollectedLegendItem("GreedLegendCollected", startX, T("= Collected"))
    local stickerBookSwatch, stickerBookLabel = self:CreateStickerBookLegendItem("GreedLegendStickerBook", startX + FOOTER_LEGEND_ITEM_SPACING, T("= Sticker Book"))
    self.footerLegendControls = {
        collectedSwatch = collectedSwatch,
        collectedLabel = collectedLabel,
        stickerBookSwatch = stickerBookSwatch,
        stickerBookLabel = stickerBookLabel,
    }
    self:LayoutFooterLegend()
end

function Greed:CreateCollectedLegendItem(name, x, labelText)
    local swatch = WINDOW_MANAGER:CreateControl(name .. "Swatch", self.controls.footer, CT_BACKDROP)
    swatch:SetDimensions(28, 28)
    swatch:SetAnchor(LEFT, self.controls.footer, LEFT, x, 0)
    SetTransparentCheckBackdrop(swatch, COLORS.collected)
    self:CreateTransparentCheckmark(swatch, name, COLORS.collected, 24, 20)

    local label = WINDOW_MANAGER:CreateControl(name .. "Label", self.controls.footer, CT_LABEL)
    label:SetDimensions(180, 22)
    label:SetAnchor(LEFT, swatch, RIGHT, 8, 0)
    label:SetFont("ZoFontGame")
    label:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
    label:SetText(labelText)

    return swatch, label
end

function Greed:CreateStickerBookLegendItem(name, x, labelText)
    local swatch = WINDOW_MANAGER:CreateControl(name .. "Swatch", self.controls.footer, CT_BACKDROP)
    swatch:SetDimensions(28, 28)
    swatch:SetAnchor(LEFT, self.controls.footer, LEFT, x, 0)
    SetTransparentCheckBackdrop(swatch, COLORS.stickerBook)
    self:CreateTransparentCheckmark(swatch, name, COLORS.stickerBook, 24, 20)

    local label = WINDOW_MANAGER:CreateControl(name .. "Label", self.controls.footer, CT_LABEL)
    label:SetDimensions(180, 22)
    label:SetAnchor(LEFT, swatch, RIGHT, 8, 0)
    label:SetFont("ZoFontGame")
    label:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
    label:SetText(labelText)

    return swatch, label
end

function Greed:CreateLegendItem(name, x, fillColor, labelText, edgeColor, markerText, markerColor, showGoldBorder)
    local swatch = WINDOW_MANAGER:CreateControl(name .. "Swatch", self.controls.footer, CT_BACKDROP)
    swatch:SetDimensions(28, 28)
    swatch:SetAnchor(LEFT, self.controls.footer, LEFT, x, 0)
    SetBackdropStyle(swatch, fillColor, edgeColor or COLORS.mutedEdge)

    if showGoldBorder then
        self:CreateLegendGoldBorder(name, swatch)
    end

    if markerText then
        local marker = WINDOW_MANAGER:CreateControl(name .. "Marker", swatch, CT_LABEL)
        marker:SetDimensions(28, 28)
        marker:SetAnchor(CENTER, swatch, CENTER, 0, 0)
        marker:SetFont("ZoFontWinH3")
        marker:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        CallControlMethod(marker, "SetVerticalAlignment", TEXT_ALIGN_CENTER)
        local color = markerColor or COLORS.text
        marker:SetColor(color[1], color[2], color[3], color[4])
        CallControlMethod(marker, "SetDrawLayer", DL_TEXT)
        CallControlMethod(marker, "SetDrawTier", DT_HIGH)
        CallControlMethod(marker, "SetDrawLevel", 20)
        marker:SetMouseEnabled(false)
        marker:SetText(markerText)
    end

    local label = WINDOW_MANAGER:CreateControl(name .. "Label", self.controls.footer, CT_LABEL)
    label:SetDimensions(230, 22)
    label:SetAnchor(LEFT, swatch, RIGHT, 8, 0)
    label:SetFont("ZoFontGame")
    label:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
    label:SetText(labelText)
end

function Greed:CreateLegendGoldBorder(baseName, parent)
    local width = 28
    local height = GetControlDimension(parent, "GetHeight", 28)
    local borderContainer = WINDOW_MANAGER:CreateControl(baseName .. "GoldContainer", parent, CT_CONTROL)
    borderContainer:SetDimensions(width, height)
    borderContainer:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
    borderContainer:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, 0, 0)
    borderContainer:SetMouseEnabled(false)

    self.legendGoldBorder = {
        parent = parent,
        container = borderContainer,
        width = width,
        height = height,
        top = self:CreateLegendGoldBorderSegment(baseName .. "GoldTop", borderContainer),
        bottom = self:CreateLegendGoldBorderSegment(baseName .. "GoldBottom", borderContainer),
        left = self:CreateLegendGoldBorderSegment(baseName .. "GoldLeft", borderContainer),
        right = self:CreateLegendGoldBorderSegment(baseName .. "GoldRight", borderContainer),
    }

    self:RefreshLegendGoldBorder()
end

function Greed:CreateLegendGoldBorderSegment(name, parent)
    local segment = WINDOW_MANAGER:CreateControl(name, parent, CT_TEXTURE)
    segment:SetMouseEnabled(false)
    CallControlMethod(segment, "SetDrawLayer", DL_TEXT)
    CallControlMethod(segment, "SetDrawTier", DT_HIGH)
    CallControlMethod(segment, "SetDrawLevel", 10)

    return segment
end

function Greed:RefreshLegendGoldBorder()
    local borderData = self.legendGoldBorder
    if not borderData or not borderData.container then return end

    local style = self:GetActiveBorderStyle()
    local topBottomThickness = self:GetBorderThickness(style, "topThickness", "debugTopThickness")
    local sideThickness = self:GetBorderThickness(style, "sideThickness", "debugSideThickness")
    local width = borderData.width or 28
    local height = borderData.height or 28
    local sideOverhang = self:GetBorderSideOverhang()
    local sideOffset = sideOverhang / 2
    local sideHeight = height + sideOverhang
    local container = borderData.container
    local parent = borderData.parent

    container:ClearAnchors()
    container:SetDimensions(width, height)
    if parent then
        container:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
        container:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, 0, 0)
    end

    self:StyleBorderTexture(borderData.top, style.topTexture, style.textureCoords, 10)
    borderData.top:SetDimensions(width, topBottomThickness)
    borderData.top:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)

    self:StyleBorderTexture(borderData.bottom, style.topTexture, style.textureCoords, 10)
    borderData.bottom:SetDimensions(width, topBottomThickness)
    borderData.bottom:SetAnchor(BOTTOMLEFT, container, BOTTOMLEFT, 0, 0)

    self:StyleBorderTexture(borderData.left, style.sideTexture, style.sideTextureCoords, 10)
    borderData.left:SetDimensions(sideThickness, sideHeight)
    borderData.left:SetAnchor(TOPLEFT, container, TOPLEFT, 0, -sideOffset)

    self:StyleBorderTexture(borderData.right, style.sideTexture, style.sideTextureCoords, 10)
    borderData.right:SetDimensions(sideThickness, sideHeight)
    borderData.right:SetAnchor(TOPRIGHT, container, TOPRIGHT, 0, -sideOffset)
end

