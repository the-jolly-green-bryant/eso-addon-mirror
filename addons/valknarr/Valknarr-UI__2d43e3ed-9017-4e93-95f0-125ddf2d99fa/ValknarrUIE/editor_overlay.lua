-- Overlay drawing for the HUD editor: catalog, banner, selection box, and
-- grid guides. Session open/close stays in editor.lua — every guard there
-- is console-learned. Slash/diag and saved-layout reapply are sibling files.
-- These methods hang off the same ValknarrUIEEditor table (X = X or {}) so
-- Apply/Begin keep calling Editor:RefreshOverlay.

ValknarrUIEEditor = ValknarrUIEEditor or {}

local Editor = ValknarrUIEEditor
local Adapter = ValknarrUIEPlayerAttributes
local Grid = ValknarrUIEGrid
local Platform = ValknarrUIEPlatform
local Log = ValknarrUIELog
local Safe = ValknarrUIESafe

-- Shared with editor.lua (loaded first). Assigned there so both files
-- use one ElementIds/LabelOf rather than drifting copies.
local ElementIds = Editor.ElementIds
local AllElementIds = Editor.AllElementIds
local LabelOf = Editor.LabelOf
local StatusLabel = Editor.StatusLabel
local StatusColor = Editor.StatusColor
local CountFound = Editor.CountFound
local AxisLabel = Editor.AxisLabel
local SafeControlName = Editor.SafeControlName
local SetLabelFont = Editor.SetLabelFont
local PROXY_COLORS = Editor.PROXY_COLORS

function Editor:CreateOverlay()
    if self.root or not WINDOW_MANAGER or not GuiRoot then
        if Log and not self.root then
            Log:Warn("CreateOverlay skipped (WINDOW_MANAGER/GuiRoot missing)")
        end
        return
    end

    local root
    if type(WINDOW_MANAGER.CreateTopLevelWindow) == "function" then
        local ok, created = pcall(WINDOW_MANAGER.CreateTopLevelWindow, WINDOW_MANAGER, "ValknarrUIERoot")
        if ok then
            root = created
        end
    end
    if not root then
        root = WINDOW_MANAGER:CreateControl("ValknarrUIERoot", GuiRoot, CT_CONTROL)
    end
    if not root then
        if Log then
            Log:Warn("Failed to create editor root")
        end
        return
    end
    self.root = root
    Safe.Call(self.root, "SetAnchor", TOPLEFT, GuiRoot, TOPLEFT, 0, 0)
    Safe.Call(self.root, "SetAnchor", BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, 0, 0)
    Safe.Call(self.root, "SetMouseEnabled", false)
    if Platform and Platform.NeverMovable then
        Platform:NeverMovable(self.root)
    end
    self.root:SetHidden(true)

    self.dimmer = WINDOW_MANAGER:CreateControl("ValknarrUIEDimmer", self.root, CT_BACKDROP)
    self.dimmer:SetAnchor(TOPLEFT, self.root, TOPLEFT, 0, 0)
    self.dimmer:SetAnchor(BOTTOMRIGHT, self.root, BOTTOMRIGHT, 0, 0)
    self.dimmer:SetCenterColor(0, 0, 0, 0.28)
    self.dimmer:SetEdgeColor(0, 0, 0, 0)
    self.dimmer:SetDrawLayer(DL_BACKGROUND)
    self.dimmer:SetMouseEnabled(false)

    -- Screen center so top (compass/target) and bottom (action bar / keybinds)
    -- stay clear while editing. Plain control — no backdrop/edge (status text only).
    self.banner = WINDOW_MANAGER:CreateControl("ValknarrUIEBanner", self.root, CT_CONTROL)
    self.banner:SetAnchor(CENTER, self.root, CENTER, 0, 0)
    self.banner:SetDimensions(980, 96)
    self.banner:SetDrawLayer(DL_OVERLAY)
    self.banner:SetDrawTier(DT_HIGH)
    self.banner:SetMouseEnabled(false)

    self.bannerTitle = WINDOW_MANAGER:CreateControl("ValknarrUIEBannerTitle", self.banner, CT_LABEL)
    self.bannerTitle:SetAnchor(TOP, self.banner, TOP, 0, 6)
    SetLabelFont(self.bannerTitle, "ZoFontGamepad34")
    self.bannerTitle:SetColor(1, 0.85, 0.25, 1)
    self.bannerTitle:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.bannerTitle:SetText("Valknarr UI")

    self.bannerStatus = WINDOW_MANAGER:CreateControl("ValknarrUIEBannerStatus", self.banner, CT_LABEL)
    self.bannerStatus:SetAnchor(TOP, self.bannerTitle, BOTTOM, 0, 2)
    self.bannerStatus:SetDimensions(940, 28)
    SetLabelFont(self.bannerStatus, "ZoFontGamepad27")
    self.bannerStatus:SetColor(1, 1, 1, 1)
    self.bannerStatus:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    self.bannerHelp = WINDOW_MANAGER:CreateControl("ValknarrUIEBannerHelp", self.banner, CT_LABEL)
    self.bannerHelp:SetAnchor(TOP, self.bannerStatus, BOTTOM, 0, 0)
    self.bannerHelp:SetDimensions(940, 28)
    SetLabelFont(self.bannerHelp, "ZoFontGamepad27")
    self.bannerHelp:SetColor(0.85, 0.85, 0.85, 1)
    self.bannerHelp:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    -- Help text is set once by UpdateBanner; a placeholder here was overwritten
    -- immediately and still counted as a SetText on every overlay create.

    self.catalog = WINDOW_MANAGER:CreateControl("ValknarrUIECatalog", self.root, CT_BACKDROP)
    local ids = (AllElementIds and AllElementIds()) or ElementIds()
    local rowH = 30
    local rowTop = 14
    self.catalogRowHeight = rowH
    self.catalogRowTop = rowTop
    local catalogH = math.max(214, 72 + (#ids * rowH))
    -- Mid-left: clear of top compass and bottom action bar.
    self.catalog:SetAnchor(LEFT, self.root, LEFT, 28, 0)
    self.catalog:SetDimensions(400, catalogH)
    self.catalog:SetCenterColor(0.015, 0.02, 0.035, 0.86)
    -- Keep the frame quiet so the active row, not the whole panel, owns the
    -- selection color.
    self.catalog:SetEdgeColor(0.58, 0.43, 0.10, 0.9)
    self.catalog:SetEdgeTexture(nil, 1, 1, 1, 0)
    self.catalog:SetDrawLayer(DL_OVERLAY)
    self.catalog:SetDrawTier(DT_HIGH)

    self.catalogSelection = WINDOW_MANAGER:CreateControl(
        "ValknarrUIECatalogSelection", self.catalog, CT_BACKDROP
    )
    self.catalogSelection:SetDimensions(384, rowH)
    self.catalogSelection:SetCenterColor(1, 0.72, 0.10, 0.20)
    self.catalogSelection:SetEdgeColor(1, 0.84, 0.28, 0.98)
    self.catalogSelection:SetEdgeTexture(nil, 1, 1, 1, 0)
    self.catalogSelection:SetDrawLayer(DL_OVERLAY)
    self.catalogSelection:SetDrawTier(DT_MEDIUM)
    self.catalogSelection:SetHidden(true)
    self.catalogSelection:SetMouseEnabled(false)

    self.catalogSelectionBar = WINDOW_MANAGER:CreateControl(
        "ValknarrUIECatalogSelectionBar", self.catalog, CT_BACKDROP
    )
    self.catalogSelectionBar:SetDimensions(5, rowH - 6)
    self.catalogSelectionBar:SetCenterColor(1, 0.78, 0.12, 1)
    self.catalogSelectionBar:SetEdgeColor(1, 0.92, 0.48, 1)
    self.catalogSelectionBar:SetDrawLayer(DL_OVERLAY)
    self.catalogSelectionBar:SetDrawTier(DT_HIGH)
    self.catalogSelectionBar:SetHidden(true)
    self.catalogSelectionBar:SetMouseEnabled(false)

    self.catalogTitle = WINDOW_MANAGER:CreateControl("ValknarrUIECatalogTitle", self.catalog, CT_LABEL)
    self.catalogTitle:SetAnchor(TOPLEFT, self.catalog, TOPLEFT, 12, 6)
    SetLabelFont(self.catalogTitle, "ZoFontGamepad27")
    self.catalogTitle:SetColor(1, 0.85, 0.25, 1)
    self.catalogTitle:SetText("Editable HUD")

    self.catalogRows = {}
    for index, name in ipairs(ids) do
        local row = WINDOW_MANAGER:CreateControl("ValknarrUIECatalogRow" .. SafeControlName(name), self.catalog, CT_LABEL)
        row:SetAnchor(TOPLEFT, self.catalog, TOPLEFT, 18, rowTop + (index * rowH))
        row:SetDimensions(370, 28)
        SetLabelFont(row, "ZoFontGamepad27")
        row:SetDrawLayer(DL_OVERLAY)
        row:SetDrawTier(DT_HIGH)
        row:SetColor(1, 1, 1, 1)
        self.catalogRows[name] = row
    end

    self.catalogLegend = WINDOW_MANAGER:CreateControl("ValknarrUIECatalogLegend", self.catalog, CT_LABEL)
    self.catalogLegend:SetAnchor(BOTTOMLEFT, self.catalog, BOTTOMLEFT, 12, -10)
    self.catalogLegend:SetDimensions(376, 28)
    SetLabelFont(self.catalogLegend, "ZoFontGamepad27")
    self.catalogLegend:SetColor(0.78, 0.78, 0.78, 1)
    self.catalogLegend:SetText("LIVE = real HUD  ·  FALLBACK = silhouette")

    Grid:CreateOverlay(self.root)

    self.overlay = WINDOW_MANAGER:CreateControl("ValknarrUIEOverlay", self.root, CT_BACKDROP)
    self.overlay:SetCenterColor(1, 0.75, 0.15, 0.08)
    self.overlay:SetEdgeColor(1, 0.75, 0.15, 1)
    self.overlay:SetEdgeTexture(nil, 2, 2, 2, 0)
    self.overlay:SetDrawLayer(DL_OVERLAY)
    self.overlay:SetDrawTier(DT_HIGH)
    self.overlay:SetHidden(true)
    self.overlay:SetMouseEnabled(false)
    if Platform and Platform.NeverMovable then
        Platform:NeverMovable(self.overlay)
    end

    self.labels = {}
    self.proxies = {}
    local overlayIds = (AllElementIds and AllElementIds()) or ElementIds()
    for _, name in ipairs(overlayIds) do
        local proxy = WINDOW_MANAGER:CreateControl("ValknarrUIEProxy" .. SafeControlName(name), self.root, CT_BACKDROP)
        local color = PROXY_COLORS[name] or { 0.70, 0.70, 0.70, 0.45 }
        proxy:SetCenterColor(color[1], color[2], color[3], color[4])
        proxy:SetEdgeColor(1, 1, 1, 0.9)
        proxy:SetEdgeTexture(nil, 1, 1, 1, 0)
        proxy:SetDimensions(220, 36)
        proxy:SetDrawLayer(DL_CONTROLS)
        proxy:SetDrawTier(DT_MEDIUM)
        proxy:SetHidden(true)
        proxy:SetMouseEnabled(false)
        if Platform and Platform.NeverMovable then
            Platform:NeverMovable(proxy)
        end
        self.proxies[name] = proxy

        local label = WINDOW_MANAGER:CreateControl("ValknarrUIELabel" .. SafeControlName(name), self.root, CT_LABEL)
        SetLabelFont(label, "ZoFontGamepad27")
        label:SetColor(1, 0.85, 0.25, 1)
        label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        label:SetDrawLayer(DL_OVERLAY)
        label:SetDrawTier(DT_HIGH)
        label:SetHidden(true)
        self.labels[name] = label
    end

    -- Stick repeat hits RefreshOverlay ~11 times a second. These caches skip
    -- SetText/SetColor when the string has not changed, and reuse the guide
    -- list so we do not allocate a new table every poll.
    self.catalogTextCache = {}
    self.catalogColorCache = {}
    self.labelTextCache = {}
    self.catalogSelectionIndex = nil
    self.bannerStatusText = nil
    self.bannerHelpSet = false
    self.guideBuffer = {}

    if Log then
        Log:Debug("Editor overlay controls created")
    end
end

function Editor:SetChromeVisible(visible)
    local hide = not visible
    if self.dimmer then
        self.dimmer:SetHidden(hide)
    end
    if self.banner then
        self.banner:SetHidden(hide)
    end
    if self.catalog then
        self.catalog:SetHidden(hide)
    end
    Grid:SetVisible(visible)
    local listed = {}
    for _, name in ipairs(ElementIds()) do
        listed[name] = true
        local label = self.labels and self.labels[name]
        if label then
            label:SetHidden(hide)
        end
    end
    if self.labels then
        for name, label in pairs(self.labels) do
            if not listed[name] then
                label:SetHidden(true)
            end
        end
    end
    if self.overlay then
        self.overlay:SetHidden(hide)
    end
end

function Editor:UpdateCatalog()
    local texts = self.catalogTextCache or {}
    local colors = self.catalogColorCache or {}
    self.catalogTextCache = texts
    self.catalogColorCache = colors
    local listed = {}
    for _, name in ipairs(ElementIds()) do
        listed[name] = true
    end
    if self.catalogRows then
        for name, row in pairs(self.catalogRows) do
            row:SetHidden(not listed[name])
        end
    end
    local selectedIndex
    local visIndex = 0
    for _, name in ipairs(ElementIds()) do
        visIndex = visIndex + 1
        local row = self.catalogRows and self.catalogRows[name]
        if row then
            local selected = name == self.selected
            if selected then
                selectedIndex = visIndex
            end
            local marker = selected and "> " or "  "
            local status = self.status and self.status[name]
            local text = marker .. LabelOf(name) .. "   " .. StatusLabel(status)
            if texts[name] ~= text then
                texts[name] = text
                row:SetText(text)
            end
            local colorKey = selected and "sel" or (status or "")
            if colors[name] ~= colorKey then
                colors[name] = colorKey
                if selected then
                    row:SetColor(1, 1, 1, 1)
                else
                    row:SetColor(StatusColor(status))
                end
            end
            local rowTop = (self.catalogRowTop or 14) + (visIndex * (self.catalogRowHeight or 30))
            row:SetAnchor(TOPLEFT, self.catalog, TOPLEFT, 18, rowTop)
        end
    end
    if self.catalog then
        local catalogH = math.max(214, 72 + (visIndex * (self.catalogRowHeight or 30)))
        self.catalog:SetDimensions(400, catalogH)
    end

    if self.catalogSelection and self.catalogSelectionIndex ~= selectedIndex then
        self.catalogSelectionIndex = selectedIndex
        if selectedIndex then
            local rowTop = (self.catalogRowTop or 14) + (selectedIndex * (self.catalogRowHeight or 30))
            self.catalogSelection:SetAnchor(TOPLEFT, self.catalog, TOPLEFT, 8, rowTop)
            self.catalogSelection:SetHidden(false)
            if self.catalogSelectionBar then
                self.catalogSelectionBar:SetAnchor(TOPLEFT, self.catalog, TOPLEFT, 8, rowTop + 3)
                self.catalogSelectionBar:SetHidden(false)
            end
        else
            self.catalogSelection:SetHidden(true)
            if self.catalogSelectionBar then
                self.catalogSelectionBar:SetHidden(true)
            end
        end
    end
end

function Editor:UpdateBanner()
    if not self.bannerStatus then
        return
    end
    local pending = self.pending and self.pending[self.selected]
    local x = pending and pending.x or 0
    local y = pending and pending.y or 0
    local col, row = 0, 0
    if Grid and Grid.CellSize then
        local cellX, cellY = Grid:CellSize()
        if cellX and cellX > 0 then
            col = math.floor((x / cellX) + 0.5)
        end
        if cellY and cellY > 0 then
            row = math.floor((y / cellY) + 0.5)
        end
    end
    local mode = self.precision and "PRECISION" or "GRID"
    local axes = "move " .. AxisLabel(self.moveAxis)
    if self:IsResizable(self.selected) then
        axes = axes .. "  size " .. AxisLabel(self.resizeAxis)
    end
    local preview = self.cleanPreview and "CLEAN" or "EDIT"
    local found, total = CountFound(self.controls)
    local platform = (Platform and Platform.ModeLabel and Platform:ModeLabel()) or "?"
    local sizeText = ""
    if pending and pending.w and pending.h then
        local width, height = Adapter:GetScreenSize()
        if width and height then
            sizeText = string.format("  ·  %.0fx%.0f", pending.w * width, pending.h * height)
        end
    end
    local text = string.format(
        "%s  ·  cell %d,%d%s  ·  %s  ·  %s  ·  %s  ·  native %d/%d  ·  %s",
        LabelOf(self.selected),
        col,
        row,
        sizeText,
        mode,
        axes,
        preview,
        found,
        total,
        platform
    )
    if self.bannerStatusText ~= text then
        self.bannerStatusText = text
        self.bannerStatus:SetText(text)
    end
    if self.bannerHelp then
        local help
        if self:IsResizable(self.selected) then
            help = "LS move  ·  RS resize  ·  L3/R3 lock axis  ·  Y hides buttons  ·  A save  ·  B exit"
        else
            help = "LS move  ·  L3 lock axis  ·  Y hides buttons  ·  A save  ·  B exit"
        end
        if self.bannerHelpText ~= help then
            self.bannerHelpText = help
            self.bannerHelp:SetText(help)
        end
    end
end

function Editor:RefreshOverlay()
    if not self.root then
        return
    end
    self.overlayDirty = false

    if self.selected and LibValknarrUIE and LibValknarrUIE.IsReplaced and LibValknarrUIE:IsReplaced(self.selected) then
        self.selected = ElementIds()[1] or self.selected
    end

    local width, height = Adapter:GetScreenSize()
    Grid:LayoutLines(width, height)

    local others = self.guideBuffer
    if not others then
        others = {}
        self.guideBuffer = others
    end
    for index = #others, 1, -1 do
        others[index] = nil
    end
    for _, name in ipairs(ElementIds()) do
        if name ~= self.selected and self.pending and self.pending[name] then
            others[#others + 1] = self.pending[name]
        end
    end
    Grid:UpdateGuides(
        self.pending and self.pending[self.selected],
        others,
        width,
        height,
        not self.cleanPreview
    )

    local labelTexts = self.labelTextCache
    if not labelTexts then
        labelTexts = {}
        self.labelTextCache = labelTexts
    end

    for _, name in ipairs(ElementIds()) do
        local pending = self.pending and self.pending[name]
        local proxy = self.proxies[name]
        local label = self.labels[name]
        local control = self.controls and self.controls[name]
        local live = self.status and self.status[name] == "live"
        local showProxy = pending and width and not live

        if proxy then
            if showProxy then
                if pending.w and pending.h then
                    proxy:SetDimensions(math.max(40, pending.w * width), math.max(24, pending.h * height))
                end
                Safe.Call(proxy, "ClearAnchors")
                Safe.Call(proxy, "SetAnchor", CENTER, GuiRoot, TOPLEFT, pending.x * width, pending.y * height)
                proxy:SetHidden(self.cleanPreview)
            else
                proxy:SetHidden(true)
            end
        end

        if label and pending and width then
            Safe.Call(label, "ClearAnchors")
            if live and control then
                Safe.Call(label, "SetAnchor", BOTTOM, control, TOP, 0, -4)
            elseif proxy then
                Safe.Call(label, "SetAnchor", BOTTOM, proxy, TOP, 0, -4)
            end
            local labelText = LabelOf(name) .. (name == self.selected and " *" or "")
            if labelTexts[name] ~= labelText then
                labelTexts[name] = labelText
                label:SetText(labelText)
            end
            label:SetHidden(self.cleanPreview)
        end
    end

    local listed = {}
    for _, name in ipairs(ElementIds()) do
        listed[name] = true
    end
    if self.labels then
        for name, label in pairs(self.labels) do
            if not listed[name] then
                label:SetHidden(true)
            end
        end
    end
    if self.proxies then
        for name, proxy in pairs(self.proxies) do
            if not listed[name] then
                proxy:SetHidden(true)
            end
        end
    end

    local selectedControl = self.controls and self.controls[self.selected]
    local selectedProxy = self.proxies and self.proxies[self.selected]
    local live = self.status and self.status[self.selected] == "live"
    local target = (live and selectedControl) or selectedProxy
    if target and self.overlay then
        local okW, targetWidth = pcall(target.GetWidth, target)
        local okH, targetHeight = pcall(target.GetHeight, target)
        if okW and okH and type(targetWidth) == "number" and type(targetHeight) == "number" then
            Safe.Call(self.overlay, "ClearAnchors")
            Safe.Call(self.overlay, "SetAnchor", TOPLEFT, target, TOPLEFT, -8, -8)
            Safe.Call(self.overlay, "SetDimensions", math.max(1, targetWidth + 16), math.max(1, targetHeight + 16))
            self.overlay:SetHidden(self.cleanPreview)
        end
    end

    self:UpdateCatalog()
    self:UpdateBanner()
    if self.cleanPreview then
        self:SetChromeVisible(false)
        if self.overlay then
            self.overlay:SetHidden(false)
        end
    else
        self:SetChromeVisible(true)
    end
end

-- Applying a layout used to refresh the whole overlay per element, so opening
-- with a saved layout redrew all 14 elements 14 times. Callers that apply more
-- than one element wrap the loop in a batch and get a single redraw.
function Editor:BeginBatch()
    self.batchDepth = (self.batchDepth or 0) + 1
end

function Editor:EndBatch()
    local depth = (self.batchDepth or 0) - 1
    if depth < 0 then
        depth = 0
    end
    self.batchDepth = depth
    if depth == 0 and self.overlayDirty then
        self:RefreshOverlay()
    end
end

function Editor:InvalidateOverlay()
    self.overlayDirty = true
    if (self.batchDepth or 0) == 0 then
        self:RefreshOverlay()
    end
end

return Editor
