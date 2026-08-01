-- CompanionRapport.lua
-- Companion Rapport
-- Author: Bankroll
-- Adds color-coded rapport action guidance into the Companion overview UI.

local ADDON_NAME = "CompanionRapport"
local DISPLAY_NAME = "Companion Rapport"
local CR = {}
_G.CompanionRapport = CR

CR.name = ADDON_NAME
CR.displayName = DISPLAY_NAME
CR.version = "2.1.1"
CR.defaults = {
    showMajorPositive = true,
    showLightPositive = true,
    showNegative = true,
    anchoredOverlay = true,
    showOnlyInCompanionMenu = true,
    onlyShowOnOverview = true,
    maxRowsPerSection = 24,
    overlayX = 80,
    overlayY = -70,
    overlayAlpha = 0.88,
    snapOverlayToOverview = false,
    useDefaultMenuBackdrop = true,
    gamepadRightStickScroll = true,
    companionSummonMessages = true,
    rapportChangeMessages = true,
    -- Fixed-size overlay: the box no longer grows/shrinks based on companion text.
    -- These values are controlled by LibAddonMenu sliders and do not change font size.
    autoSizeOverlay = false,
    overlayWidth = 540,
    overlayHeight = 900,
    overlayMinWidth = 360,
    overlayMaxWidth = 1000,
    overlayMinHeight = 260,
    overlayMaxHeight = 1200,
}
CR.sv = nil
CR.overlayPanel = nil
CR.activePanel = nil
CR.rows = {}
CR.refreshQueued = false
CR.overlayScrollOffset = 0

local COLOR_GOLD  = "|cFFD700"
local COLOR_GREEN = "|c3CFF3C"
local COLOR_ALLIED_GREEN = "|c1FA64A"
local COLOR_RED   = "|cFF4040"
local COLOR_WHITE = "|cFFFFFF"
local COLOR_GRAY  = "|cA0A0A0"
local COLOR_BLUE  = "|c66CCFF"
local COLOR_ORANGE = "|cFF8C00"
local COLOR_LIGHT_ORANGE = "|cFFCC66"
local COLOR_YELLOW = "|cEFFF66"
local COLOR_LIGHT_GREEN = "|c99FF99"
local COLOR_DARK_GREEN = "|c008A2E"
local COLOR_END   = "|r"

local function C(color, text)
    return color .. tostring(text or "") .. COLOR_END
end

local function Msg(text, bodyColor)
    if not d then return end
    local body = tostring(text or "")
    if bodyColor then body = C(bodyColor, body) end
    d(C(COLOR_BLUE, DISPLAY_NAME .. ":") .. " " .. body)
end

local function Lower(text)
    if not text then return "" end
    if zo_strlower then return zo_strlower(text) end
    return string.lower(text)
end

local function InGamepadMode()
    return IsInGamepadPreferredMode and IsInGamepadPreferredMode()
end

local function Font(size)
    if InGamepadMode() then
        if size == "title" then return "ZoFontGamepadBold27" end
        if size == "small" then return "ZoFontGamepad22" end
        return "ZoFontGamepad25"
    end
    if size == "title" then return "ZoFontWinH3" end
    if size == "small" then return "ZoFontGameSmall" end
    return "ZoFontGame"
end


local GetRapportRank

local function GetCurrentCompanionRapport()
    if GetActiveCompanionRapport then
        local ok, rapport = pcall(GetActiveCompanionRapport)
        if ok and type(rapport) == "number" then return rapport end
    end
    return nil
end

local function FormatCompanionRapport()
    local rapport = GetCurrentCompanionRapport()
    local rank = GetRapportRank and GetRapportRank(rapport) or { color = COLOR_GREEN }
    local current = rapport ~= nil and tostring(rapport) or "?"
    return C(rank.color or COLOR_GREEN, current) .. C(COLOR_GRAY, " / ") .. C(COLOR_DARK_GREEN, "5500 (Max)")
end


local RAPPORT_RANKS = {
    { min = -5000, max = -4000, name = "Disdainful", color = COLOR_RED, nextAt = -3999, nextName = "Irritated", nextColor = COLOR_ORANGE },
    { min = -3999, max = -2500, name = "Irritated", color = COLOR_ORANGE, nextAt = -2499, nextName = "Wary", nextColor = COLOR_LIGHT_ORANGE },
    { min = -2499, max = 749, name = "Wary", color = COLOR_LIGHT_ORANGE, nextAt = 750, nextName = "Cordial", nextColor = COLOR_YELLOW },
    { min = 750, max = 999, name = "Cordial", color = COLOR_YELLOW, nextAt = 1000, nextName = "Friendly", nextColor = COLOR_LIGHT_GREEN },
    { min = 1000, max = 1999, name = "Friendly", color = COLOR_LIGHT_GREEN, nextAt = 2000, nextName = "Close", nextColor = COLOR_GREEN },
    { min = 2000, max = 2999, name = "Close", color = COLOR_GREEN, nextAt = 3000, nextName = "Allied", nextColor = COLOR_ALLIED_GREEN },
    { min = 3000, max = 3999, name = "Allied", color = COLOR_ALLIED_GREEN, nextAt = 4000, nextName = "Companion", nextColor = COLOR_DARK_GREEN },
    { min = 4000, max = 5499, name = "Companion", color = COLOR_DARK_GREEN, nextAt = 5500, nextName = "Max Rapport", nextColor = COLOR_DARK_GREEN },
    { min = 5500, max = 5500, name = "Max Rapport", color = COLOR_DARK_GREEN, nextAt = 5500, nextName = "Max Rapport", nextColor = COLOR_DARK_GREEN },
}

GetRapportRank = function(rapport)
    rapport = tonumber(rapport)
    if not rapport then
        return { name = "Unknown", color = COLOR_GRAY, nextAt = 5500, nextName = "Max Rapport", nextColor = COLOR_DARK_GREEN }
    end
    for _, rank in ipairs(RAPPORT_RANKS) do
        if rapport >= rank.min and rapport <= rank.max then return rank end
    end
    if rapport < -5000 then return RAPPORT_RANKS[1] end
    return RAPPORT_RANKS[#RAPPORT_RANKS]
end

local function FormatRelationshipLine()
    local rapport = GetCurrentCompanionRapport()
    local rank = GetRapportRank(rapport)
    local current = rapport ~= nil and tostring(rapport) or "?"
    local nextAt = rank.nextAt or 5500
    local nextName = rank.nextName or "Max Rapport"
    local nextColor = rank.nextColor or COLOR_DARK_GREEN
    return C(COLOR_GRAY, "Rapport status: ")
        .. C(rank.color, rank.name)
        .. C(COLOR_GRAY, " with a rapport of ")
        .. C(rank.color, current)
        .. C(COLOR_GRAY, " / ")
        .. C(rank.color, tostring(nextAt))
        .. C(COLOR_GRAY, " until ")
        .. C(nextColor, nextName)
end

local function GetRelationshipSummaryForMessage()
    local rapport = GetCurrentCompanionRapport()
    local rank = GetRapportRank(rapport)
    local current = rapport ~= nil and tostring(rapport) or "?"
    return rank, current, tostring(rank.nextAt or 5500), rank.nextName or "Max Rapport", rank.nextColor or COLOR_DARK_GREEN
end

local function GetRapportChangeColor(delta)
    delta = tonumber(delta) or 0
    if delta < 0 then return COLOR_RED end
    if delta >= 1 and delta <= 24 then return "|c7CFC00" end -- lime green
    if delta >= 25 then return COLOR_GOLD end
    return COLOR_GRAY
end

local function FormatRapportChangeAmount(delta)
    delta = tonumber(delta) or 0
    if delta > 0 then return "+" .. tostring(delta) end
    return tostring(delta)
end


local function GetCurrentCompanionName()
    if GetActiveCompanionDefId and GetCompanionName then
        local id = GetActiveCompanionDefId()
        if id and id ~= 0 then
            local name = GetCompanionName(id)
            if name and name ~= "" then return zo_strformat and zo_strformat("<<C:1>>", name) or name end
        end
    end
    return nil
end

local function FindDataByName(name)
    if not name or not CompanionRapport_Data then return nil end
    local key = Lower(name)
    if CompanionRapport_Data[key] then return CompanionRapport_Data[key], key end
    for dataKey, data in pairs(CompanionRapport_Data) do
        if key:find(dataKey, 1, true) or dataKey:find(key, 1, true) then return data, dataKey end
        for _, alias in ipairs(data.aliases or {}) do
            local a = Lower(alias)
            if key:find(a, 1, true) or a:find(key, 1, true) then return data, dataKey end
        end
    end
    return nil, key
end

local function FormatAmount(entry)
    if entry.amount == nil then return "" end
    if entry.amount > 0 then return "+" .. tostring(entry.amount) .. " " end
    return tostring(entry.amount) .. " "
end

local function FormatEntry(color, entry)
    local note = entry.note and (" " .. C(COLOR_GRAY, "(" .. entry.note .. ")")) or ""
    return C(color, "• " .. FormatAmount(entry) .. entry.action) .. note
end

local function ClearRows()
    for _, row in ipairs(CR.rows) do
        row:SetHidden(true)
        row:SetText("")
    end
end

local function Row(parent, index, y, text, font)
    local row = CR.rows[index]
    if not row then
        row = WINDOW_MANAGER:CreateControl("CompanionRapportOverviewRow" .. index, parent, CT_LABEL)
        CR.rows[index] = row
    end
    row:ClearAnchors()
    row:SetAnchor(TOPLEFT, parent, TOPLEFT, 18, y)
    row:SetDimensions(parent:GetWidth() - 36, 26)
    row:SetFont(font or Font("normal"))
    row:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    row:SetText(text)
    row:SetHidden(false)
    return row
end

local function IsControlUsable(control)
    return control and control.GetWidth and control:GetWidth() and control:GetWidth() > 0
end

function CR:GetOverviewParent()
    -- ESO's companion menu control names differ between keyboard/gamepad and have changed
    -- between game updates. Prefer known companion controls, but never fail to GuiRoot.
    local candidates = {
        _G.ZO_CompanionCharacterWindow_Keyboard,
        _G.ZO_CompanionCharacterWindow_Gamepad,
        _G.ZO_CompanionCharacterWindow,
        _G.ZO_Companion_Keyboard,
        _G.ZO_Companion_Gamepad,
        _G.COMPANION_CHARACTER_KEYBOARD and _G.COMPANION_CHARACTER_KEYBOARD.control,
        _G.COMPANION_CHARACTER_GAMEPAD and _G.COMPANION_CHARACTER_GAMEPAD.control,
        _G.COMPANION_CHARACTER_WINDOW and _G.COMPANION_CHARACTER_WINDOW.control,
        _G.COMPANION_OVERVIEW_KEYBOARD and _G.COMPANION_OVERVIEW_KEYBOARD.control,
        _G.COMPANION_OVERVIEW_GAMEPAD and _G.COMPANION_OVERVIEW_GAMEPAD.control,
    }
    for _, c in ipairs(candidates) do
        if IsControlUsable(c) then return c end
    end
    return GuiRoot
end

function CR:IsCompanionSceneActive()
    if not SCENE_MANAGER or not SCENE_MANAGER.GetCurrentScene then return false end
    local scene = SCENE_MANAGER:GetCurrentScene()
    if not scene or not scene.GetName then return false end
    local name = Lower(scene:GetName())
    return name:find("companion", 1, true) ~= nil
end

function CR:IsCompanionOverviewActive()
    if not self:IsCompanionSceneActive() then return false end
    if not SCENE_MANAGER or not SCENE_MANAGER.GetCurrentScene then return false end
    local scene = SCENE_MANAGER:GetCurrentScene()
    local name = scene and scene.GetName and Lower(scene:GetName()) or ""

    -- Prefer exact overview/character scenes. In many ESO builds, the companion
    -- overview tab lives inside companionCharacterKeyboard/Gamepad, while equipment
    -- and skills use separate scene names.
    if name:find("overview", 1, true) or name:find("character", 1, true) then return true end
    if name:find("skill", 1, true) or name:find("equipment", 1, true) or name:find("outfit", 1, true) or name:find("collection", 1, true) then return false end

    -- If the scene is simply named companion, allow it as the overview fallback.
    return name:find("companion", 1, true) ~= nil
end

local ApplyPanelRowVisibility

local function CreatePanelBase(name, parent, isOverlay)
    local panel
    if isOverlay then
        panel = WINDOW_MANAGER:CreateTopLevelWindow(name)
        panel:SetClampedToScreen(true)
        panel:SetMovable(true)
        panel:SetDrawLayer(DL_OVERLAY)
        panel:SetDrawTier(DT_HIGH)
    else
        panel = WINDOW_MANAGER:CreateControl(name, parent, CT_CONTROL)
        panel:SetDrawLayer(DL_CONTROLS)
    end

    panel:SetDimensions(620, 610)
    panel.baseWidth = 620
    panel.baseHeight = 610
    panel:SetHidden(true)
    panel:SetMouseEnabled(true)

    local bg = WINDOW_MANAGER:CreateControl("$(parent)Bg", panel, CT_BACKDROP)
    bg:SetAnchorFill(panel)
    -- Match ESO's default dark menu/tooltip box look instead of using a custom gold border.
    panel.bg = bg
    bg:SetCenterColor(0.02, 0.02, 0.02, isOverlay and ((CR.sv and CR.sv.overlayAlpha) or CR.defaults.overlayAlpha or 0.88) or 0.78)
    bg:SetEdgeColor(0.55, 0.55, 0.55, 0.85)
    bg:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16)

    local title = WINDOW_MANAGER:CreateControl("$(parent)Title", panel, CT_LABEL)
    panel.title = title
    title:SetAnchor(TOPLEFT, panel, TOPLEFT, 18, 12)
    title:SetDimensions(520, 30)
    title:SetFont(Font("title"))
    title:SetText(C(COLOR_WHITE, DISPLAY_NAME))

    local mode = WINDOW_MANAGER:CreateControl("$(parent)Mode", panel, CT_LABEL)
    panel.mode = mode
    mode:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 0)
    mode:SetDimensions(530, 24)
    mode:SetFont(Font("small"))
    mode:SetText(C(COLOR_GRAY, "Current equipped companion: ") .. C(COLOR_WHITE, "None"))

    local relationship = WINDOW_MANAGER:CreateControl("$(parent)Relationship", panel, CT_LABEL)
    panel.relationship = relationship
    relationship:SetAnchor(TOPLEFT, mode, BOTTOMLEFT, 0, 0)
    relationship:SetDimensions(530, 42)
    relationship:SetFont(Font("small"))
    relationship:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    relationship:SetText(C(COLOR_GRAY, "Current relationship status: ") .. C(COLOR_GRAY, "Unknown"))

    if isOverlay then
        -- No close icon by design. Use the AddOn Settings toggle or /crapportoverlay to hide the overlay.
        local scrollHint = WINDOW_MANAGER:CreateControl("$(parent)ScrollHint", panel, CT_LABEL)
        panel.scrollHint = scrollHint
        scrollHint:SetAnchor(TOPLEFT, panel, BOTTOMLEFT, 8, 4)
        scrollHint:SetDimensions(604, 22)
        scrollHint:SetFont(Font("small"))
        scrollHint:SetText(C(COLOR_GRAY, "Right Analog Stick / Mouse Wheel: Scroll for more actions"))
        scrollHint:SetHidden(false)

        panel:SetHandler("OnMoveStop", function(control)
            if not CR.sv then return end
            local _, _, _, x, y = control:GetAnchor(0)
            CR.sv.overlayX = x or 0
            CR.sv.overlayY = y or 0
        end)
    end

    local viewport = WINDOW_MANAGER:CreateControl("$(parent)Viewport", panel, CT_CONTROL)
    viewport:SetAnchor(TOPLEFT, panel, TOPLEFT, 12, 108)
    viewport:SetAnchor(BOTTOMRIGHT, panel, BOTTOMRIGHT, -12, -12)
    viewport:SetMouseEnabled(true)
    if viewport.SetClipsChildren then viewport:SetClipsChildren(true) end

    local content = WINDOW_MANAGER:CreateControl("$(parent)Content", viewport, CT_CONTROL)
    content:SetAnchor(TOPLEFT, viewport, TOPLEFT, 0, 0)
    content:SetDimensions(596, 3000)
    content:SetMouseEnabled(false)
    -- Also clip the content control itself. Some label controls can draw outside their
    -- own height after wrapping; clipping both the viewport and content prevents
    -- vertical bleed past the overlay box.
    if content.SetClipsChildren then content:SetClipsChildren(true) end

    panel.viewport = viewport
    panel.content = content
    panel.scrollOffset = 0
    panel.maxScroll = 0
    panel.isOverlay = isOverlay

    function panel:ScrollBy(deltaPixels)
        if not self.maxScroll or self.maxScroll <= 0 then return end
        self.scrollOffset = zo_clamp((self.scrollOffset or 0) + deltaPixels, 0, self.maxScroll)
        if ApplyPanelRowVisibility then ApplyPanelRowVisibility(self) end
    end

    function panel:ScrollWheel(delta)
        local step = InGamepadMode() and 84 or 54
        self:ScrollBy(-(delta or 0) * step)
    end

    viewport:SetHandler("OnMouseWheel", function(_, delta) panel:ScrollWheel(delta) end)
    panel:SetHandler("OnMouseWheel", function(_, delta) panel:ScrollWheel(delta) end)
    panel:SetHandler("OnMouseEnter", function() CR.gamepadScrollPanel = panel end)
    viewport:SetHandler("OnMouseEnter", function() CR.gamepadScrollPanel = panel end)

    return panel
end

function CR:CreatePanels()
    if not self.overlayPanel then
        self.overlayPanel = CreatePanelBase("CompanionRapportOverlayPanel", GuiRoot, true)
    end
end

function CR:AnchorOverlay()
    local panel = self.overlayPanel
    if not panel then return end
    self:ApplyOverlayDimensions()
    panel:ClearAnchors()
    local x = (self.sv and self.sv.overlayX) or 0
    local y = (self.sv and self.sv.overlayY) or 0

    if self.sv and self.sv.snapOverlayToOverview then
        local parent = self:GetOverviewParent()
        if parent and parent ~= GuiRoot and IsControlUsable(parent) then
            -- Snap to the right side of ESO's Companion overview/menu control.
            panel:SetAnchor(TOPLEFT, parent, TOPRIGHT, 18 + x, 74 + y)
            return
        end
        panel:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -70 + x, 115 + y)
        return
    end

    -- Default/manual mode uses the top-right of the screen with X/Y offsets.
    panel:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -30 + x, 70 + y)
end

function CR:ApplyOverlayDimensions()
    local panel = self.overlayPanel
    if not panel then return end
    local width = zo_clamp(tonumber(self.sv and self.sv.overlayWidth) or CR.defaults.overlayWidth, CR.defaults.overlayMinWidth, CR.defaults.overlayMaxWidth)
    local height = zo_clamp(tonumber(self.sv and self.sv.overlayHeight) or CR.defaults.overlayHeight, CR.defaults.overlayMinHeight, CR.defaults.overlayMaxHeight)
    panel:SetDimensions(width, height)
    panel.baseWidth = width
    panel.baseHeight = height
    if panel.title then panel.title:SetDimensions(width - 100, 30) end
    if panel.mode then panel.mode:SetDimensions(width - 90, 24) end
    if panel.relationship then panel.relationship:SetDimensions(width - 90, 42) end
    if panel.scrollHint then panel.scrollHint:SetDimensions(width - 16, 22) end
    if panel.content and panel.viewport then
        panel.content:SetWidth(zo_max(1, panel.viewport:GetWidth()))
    end
end

function CR:GetVisiblePanels()
    local panels = {}
    if self.sv and self.sv.anchoredOverlay then table.insert(panels, self.overlayPanel) end
    return panels
end

local function ClearPanelRows(panel)
    if not panel or not panel.rows then return end
    for _, row in ipairs(panel.rows) do
        row:SetHidden(true)
        row.hasText = false
        row.logicalY = nil
        row.logicalH = nil
        if row.label then row.label:SetText("") end
    end
end

local function StripColorCodes(text)
    return tostring(text or ""):gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
end

function ApplyPanelRowVisibility(panel)
    if not panel or not panel.rows or not panel.viewport then return end
    local viewportHeight = panel.viewport:GetHeight() or 0
    local viewportWidth = panel.viewport:GetWidth() or (panel:GetWidth() - 24)
    local scrollOffset = panel.scrollOffset or 0

    for _, row in ipairs(panel.rows) do
        if row.logicalY and row.logicalH and row.label and row.hasText then
            local visibleY = row.logicalY - scrollOffset
            local rowHeight = row.logicalH

            -- Hard lock: rows are only drawn when the whole row fits inside the overlay
            -- viewport. Rows outside, above, below, or partly crossing the viewport edge
            -- are hidden instead of being clipped by the GPU. This prevents ESO label
            -- glyphs from bleeding outside the overlay boundary on clients where
            -- SetClipsChildren is unreliable.
            if visibleY >= 0 and (visibleY + rowHeight) <= viewportHeight then
                row:ClearAnchors()
                row:SetAnchor(TOPLEFT, panel.viewport, TOPLEFT, 12, visibleY)
                row:SetDimensions(viewportWidth - 24, rowHeight)
                row.label:SetDimensions(viewportWidth - 24, rowHeight)
                row:SetHidden(false)
            else
                row:SetHidden(true)
            end
        else
            row:SetHidden(true)
        end
    end
end

local function PanelRow(panel, index, y, text, font)
    panel.rows = panel.rows or {}
    local row = panel.rows[index]
    if not row then
        -- Parent rows directly to the visible viewport. Scrolling changes each row's
        -- viewport-relative anchor and hides rows that would cross the box boundary.
        row = WINDOW_MANAGER:CreateControl(panel:GetName() .. "Row" .. index, panel.viewport, CT_CONTROL)
        row.label = WINDOW_MANAGER:CreateControl("$(parent)Label", row, CT_LABEL)
        row.label:SetAnchorFill(row)
        row.label:SetVerticalAlignment(TEXT_ALIGN_TOP)
        row.label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        if row.SetClipsChildren then row:SetClipsChildren(true) end
        panel.rows[index] = row
    end

    local width = (panel.viewport and panel.viewport:GetWidth() or panel:GetWidth()) - 24
    local label = row.label
    row.hasText = true
    row.logicalY = y
    label:SetFont(font or Font("normal"))
    label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    label:SetText(text)

    local h = 26
    if label.GetTextHeight then
        local measured = label:GetTextHeight()
        if measured and measured > h then h = measured + 8 end
    else
        local plain = StripColorCodes(text)
        if string.len(plain) > 72 then h = 48 end
        if string.len(plain) > 140 then h = 72 end
        if string.len(plain) > 240 then h = 120 end
    end

    -- Never allow a single row to be taller than the viewport. If a row would be
    -- larger, it is constrained and ellipsized inside that row, preventing vertical
    -- bleed outside the overlay.
    local viewportHeight = panel.viewport and panel.viewport:GetHeight() or 500
    if viewportHeight and viewportHeight > 0 then h = zo_min(h, zo_max(24, viewportHeight - 8)) end
    row.logicalH = h
    row:SetDimensions(width, h)
    label:SetDimensions(width, h)
    row:SetHidden(true)
    return row, h
end

function CR:DrawSection(panel, rowIndex, y, title, color, entries, maxRows)
    local _, titleH = PanelRow(panel, rowIndex, y, C(color, title), Font("title")); rowIndex = rowIndex + 1; y = y + (titleH or 30) + 4
    local count = 0
    for _, entry in ipairs(entries or {}) do
        if count >= maxRows then
            local _, h = PanelRow(panel, rowIndex, y, C(COLOR_GRAY, "• More actions are listed in CompanionRapportData.lua"), Font("small"))
            rowIndex = rowIndex + 1; y = y + (h or 24) + 2
            break
        end
        local _, h = PanelRow(panel, rowIndex, y, FormatEntry(color, entry))
        rowIndex = rowIndex + 1; y = y + (h or 24) + 2
        count = count + 1
    end
    return rowIndex, y + 8
end

function CR:EstimatePanelWidth(panel, data)
    -- Fixed-size overlay. Width is controlled only by the Overlay Width slider.
    if not panel then return CR.defaults.overlayWidth end
    if panel.isOverlay then
        return zo_clamp(tonumber(self.sv and self.sv.overlayWidth) or CR.defaults.overlayWidth, CR.defaults.overlayMinWidth, CR.defaults.overlayMaxWidth)
    end
    return panel.baseWidth or CR.defaults.overlayWidth
end

function CR:ResizePanelToContent(panel, contentHeight)
    if not panel then return end
    if panel.isOverlay then
        -- The overlay is intentionally fixed-size. Do not scale it to text.
        self:ApplyOverlayDimensions()
    end
    if panel.viewport then
        panel.viewport:ClearAnchors()
        panel.viewport:SetAnchor(TOPLEFT, panel, TOPLEFT, 12, 108)
        panel.viewport:SetAnchor(BOTTOMRIGHT, panel, BOTTOMRIGHT, -12, -12)
    end
end

function CR:RenderPanel(panel, companionName, data, lookupKey)
    if not panel then return end
    if panel.bg and panel.isOverlay then
        panel.bg:SetCenterColor(0.02, 0.02, 0.02, tonumber(self.sv.overlayAlpha) or CR.defaults.overlayAlpha or 0.88)
        panel.bg:SetEdgeColor(0.55, 0.55, 0.55, zo_min((tonumber(self.sv.overlayAlpha) or 0.88) + 0.05, 1))
    end
    if panel.isOverlay then
        self:ApplyOverlayDimensions()
    end

    if panel.mode then
        local currentLabel
        if companionName then
            currentLabel = C(COLOR_GRAY, "Current equipped companion: ") .. C(COLOR_WHITE, companionName) .. "  " .. FormatCompanionRapport()
        else
            currentLabel = C(COLOR_GRAY, "Current equipped companion: ") .. C(COLOR_RED, "None")
        end
        panel.mode:SetText(currentLabel)
    end
    if panel.relationship then
        if companionName then
            panel.relationship:SetText(FormatRelationshipLine())
        else
            panel.relationship:SetText(C(COLOR_GRAY, "Rapport status: ") .. C(COLOR_RED, "None"))
        end
    end

    ClearPanelRows(panel)
    panel:SetHidden(false)
    panel.scrollOffset = 0

    local y = 0
    local rowIndex = 1

    if not companionName then
        PanelRow(panel, rowIndex, y, C(COLOR_RED, "No active companion detected.")); rowIndex = rowIndex + 1
        PanelRow(panel, rowIndex, y + 26, C(COLOR_GRAY, "Summon a companion and open the Companion overview."), Font("small"))
        self:ResizePanelToContent(panel, 68)
        panel.maxScroll = 0
        ApplyPanelRowVisibility(panel)
        return
    end

    if not data then
        PanelRow(panel, rowIndex, y, C(COLOR_RED, "No rapport data found for: " .. companionName)); rowIndex = rowIndex + 1
        PanelRow(panel, rowIndex, y + 26, C(COLOR_GRAY, "Data lookup key: " .. tostring(lookupKey)), Font("small"))
        self:ResizePanelToContent(panel, 72)
        panel.maxScroll = 0
        ApplyPanelRowVisibility(panel)
        return
    end

    local maxRows = tonumber(self.sv.maxRowsPerSection) or 24
    if self.sv.showMajorPositive then
        rowIndex, y = self:DrawSection(panel, rowIndex, y, "Greatly positive rapport", COLOR_GOLD, data.majorPositive, maxRows)
    end
    if self.sv.showLightPositive then
        rowIndex, y = self:DrawSection(panel, rowIndex, y, "Light positive rapport", COLOR_GREEN, data.lightPositive, maxRows)
    end
    if self.sv.showNegative then
        rowIndex, y = self:DrawSection(panel, rowIndex, y, "Negative rapport", COLOR_RED, data.negative, maxRows)
    end

    panel.content:SetHeight(y + 16)
    self:ResizePanelToContent(panel, y + 16)
    local viewportHeight = panel.viewport and panel.viewport:GetHeight() or 500
    if panel.scrollHint then
        panel.scrollHint:SetHidden(false)
        panel.scrollHint:SetText(C(COLOR_GRAY, "Right Analog Stick / Mouse Wheel: Scroll for more actions"))
    end
    panel.maxScroll = zo_max(0, (panel.content:GetHeight() or (y + 16)) - viewportHeight)
    ApplyPanelRowVisibility(panel)
end

function CR:Refresh()
    self:CreatePanels()
    self:AnchorOverlay()
    if self.overlayPanel then self.overlayPanel:SetHidden(true) end

    if self.sv.showOnlyInCompanionMenu and not self:IsCompanionSceneActive() then return end
    if self.sv.onlyShowOnOverview and not self:IsCompanionOverviewActive() then return end

    local panels = self:GetVisiblePanels()
    if #panels == 0 then return end

    local companionName = GetCurrentCompanionName()
    local data, lookupKey = FindDataByName(companionName)
    for _, panel in ipairs(panels) do
        self:RenderPanel(panel, companionName, data, lookupKey)
    end
end

function CR:Hide()
    if self.overlayPanel then self.overlayPanel:SetHidden(true) end
end

function CR:QueueRefresh()
    if self.refreshQueued then return end
    self.refreshQueued = true
    zo_callLater(function()
        self.refreshQueued = false
        self:Refresh()
    end, 250)
end

function CR:RegisterSceneHooks()
    local function OnMaybeCompanionScene(newState)
        if newState == SCENE_SHOWING or newState == SCENE_SHOWN or newState == nil then
            if CR:IsCompanionSceneActive() then
                CR:QueueRefresh()
            end
        elseif newState == SCENE_HIDDEN and CR:IsCompanionSceneActive() == false then
            CR:Hide()
        end
    end

    -- Exact hooks for known names.
    local function HookScene(sceneName)
        local scene = SCENE_MANAGER and SCENE_MANAGER:GetScene(sceneName)
        if not scene then return end
        scene:RegisterCallback("StateChange", function(_, newState) OnMaybeCompanionScene(newState) end)
    end

    HookScene("companionCharacterKeyboard")
    HookScene("companionCharacterGamepad")
    HookScene("companionOverviewKeyboard")
    HookScene("companionOverviewGamepad")
    HookScene("companionKeyboard")
    HookScene("companionGamepad")

    -- Global scene callback catches renamed companion scenes.
    if SCENE_MANAGER and SCENE_MANAGER.RegisterCallback then
        SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, oldState, newState)
            local sceneName = scene and scene.GetName and Lower(scene:GetName()) or ""
            if sceneName:find("companion", 1, true) then
                if newState == SCENE_SHOWING or newState == SCENE_SHOWN then
                    CR:QueueRefresh()
                elseif newState == SCENE_HIDDEN then
                    CR:Hide()
                end
            end
        end)
    end

    -- Last-resort watchdog. If ZOS uses a new scene callback/name, this still shows the
    -- panel whenever the active scene name contains "companion".
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "SceneWatch", 1000, function()
        if CR:IsCompanionSceneActive() then
            if (not CR.sv.onlyShowOnOverview or CR:IsCompanionOverviewActive()) and (not CR.overlayPanel or CR.overlayPanel:IsHidden()) then CR:QueueRefresh() end
        elseif ((CR.overlayPanel and not CR.overlayPanel:IsHidden())) then
            CR:Hide()
        end
    end)

    if EVENT_COMPANION_ACTIVATED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_COMPANION_ACTIVATED, function()
            CR:QueueRefresh()
            zo_callLater(function() CR:UpdateRapportBaseline(); CR:ShowCompanionSummonedMessage() end, 800)
        end)
    end
    if EVENT_COMPANION_DEACTIVATED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_COMPANION_DEACTIVATED, function() CR:Hide(); CR:UpdateRapportBaseline() end)
    end

end

function CR:Debug()
    local companionName = GetCurrentCompanionName() or "none"
    local sceneName = "none"
    if SCENE_MANAGER and SCENE_MANAGER.GetCurrentScene then
        local scene = SCENE_MANAGER:GetCurrentScene()
        sceneName = scene and scene.GetName and scene:GetName() or "unknown"
    end
    local parent = self:GetOverviewParent()
    Msg("debug: companion=" .. companionName .. ", scene=" .. sceneName .. ", parent=" .. tostring(parent and parent.GetName and parent:GetName() or parent) .. ", overlay=" .. tostring(CR.sv and CR.sv.anchoredOverlay))
end


function CR:GetRightStickY()
    -- ESO's exact gamepad directional APIs have changed over time, so this is guarded.
    if not InGamepadMode() then return 0 end
    if DIRECTIONAL_INPUT and DIRECTIONAL_INPUT.GetY and ZO_DI_RIGHT_STICK then
        local ok, value = pcall(function() return DIRECTIONAL_INPUT:GetY(ZO_DI_RIGHT_STICK) end)
        if ok and type(value) == "number" then return value end
    end
    if GetGamepadRightStickY then
        local ok, value = pcall(GetGamepadRightStickY)
        if ok and type(value) == "number" then return value end
    end
    return 0
end

function CR:RegisterGamepadScroll()
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "RightStickScroll", 16, function()
        if not InGamepadMode() then return end
        local panel = CR.gamepadScrollPanel
        if not panel or panel:IsHidden() or not panel.ScrollBy then
            if CR.overlayPanel and not CR.overlayPanel:IsHidden() then panel = CR.overlayPanel
            else return end
        end
        local y = CR:GetRightStickY()
        if y and zo_abs(y) > 0.18 then
            -- Positive stick input scrolls down; negative scrolls up.
            panel:ScrollBy(y * 18)
        end
    end)
end

function CR:PreviewOverlayForAdjustment()
    self.sv.anchoredOverlay = true
    self:CreatePanels()
    self:AnchorOverlay()
    local companionName = GetCurrentCompanionName()
    local data, lookupKey = FindDataByName(companionName)
    self:RenderPanel(self.overlayPanel, companionName, data, lookupKey)
end

function CR:RegisterLAM()
    local LAM = LibAddonMenu2
    if not LAM then return end

    self.optionsPanel = LAM:RegisterAddonPanel("CompanionRapportOptions", {
        type = "panel",
        name = DISPLAY_NAME,
        displayName = DISPLAY_NAME,
        author = "Bankroll",
        version = self.version,
        registerForRefresh = true,
        registerForDefaults = true,
    })

    LAM:RegisterOptionControls("CompanionRapportOptions", {
        {
            type = "checkbox",
            name = "Show current companion overlay",
            tooltip = "Shows the Companion Rapport overlay for the currently equipped companion whenever the Companion overview is open. You can also toggle this with /crapportoverlay.",
            getFunc = function() return CR.sv.anchoredOverlay end,
            setFunc = function(value) CR.sv.anchoredOverlay = value; CR:Refresh() end,
            default = CR.defaults.anchoredOverlay,
        },
        {
            type = "checkbox",
            name = "Snap overlay to the right of overview",
            tooltip = "Anchors the Companion Rapport overlay to the right side of ESO's Companion overview/menu panel. Off by default; when disabled, the overlay snaps to the top-right of the screen. The X/Y sliders become fine-tune offsets.",
            getFunc = function() return CR.sv.snapOverlayToOverview end,
            setFunc = function(value) CR.sv.snapOverlayToOverview = value; CR:Refresh() end,
            default = CR.defaults.snapOverlayToOverview,
        },
        {
            type = "slider",
            name = "Overlay width / X size",
            tooltip = "Expand or shrink the overlay box horizontally. Text size stays the same; wider boxes just give the text more room before wrapping.",
            min = CR.defaults.overlayMinWidth,
            max = CR.defaults.overlayMaxWidth,
            step = 10,
            getFunc = function() return CR.sv.overlayWidth end,
            setFunc = function(value) CR.sv.overlayWidth = value; CR:PreviewOverlayForAdjustment() end,
            default = CR.defaults.overlayWidth,
        },
        {
            type = "slider",
            name = "Overlay height / Y size",
            tooltip = "Expand or shrink the overlay box vertically. Text size stays the same; overflow remains locked inside the box and scrolls.",
            min = CR.defaults.overlayMinHeight,
            max = CR.defaults.overlayMaxHeight,
            step = 10,
            getFunc = function() return CR.sv.overlayHeight end,
            setFunc = function(value) CR.sv.overlayHeight = value; CR:PreviewOverlayForAdjustment() end,
            default = CR.defaults.overlayHeight,
        },
        {
            type = "slider",
            name = "Overlay X position",
            tooltip = "Move the overlay left or right. In snapped mode, this is a fine-tune offset from the right side of the overview menu.",
            min = -900,
            max = 900,
            step = 10,
            getFunc = function() return CR.sv.overlayX end,
            setFunc = function(value) CR.sv.overlayX = value; CR:PreviewOverlayForAdjustment() end,
            default = CR.defaults.overlayX,
        },
        {
            type = "slider",
            name = "Overlay Y position",
            tooltip = "Move the overlay up or down. In snapped mode, this is a fine-tune offset from the overview menu anchor.",
            min = -500,
            max = 500,
            step = 10,
            getFunc = function() return CR.sv.overlayY end,
            setFunc = function(value) CR.sv.overlayY = value; CR:PreviewOverlayForAdjustment() end,
            default = CR.defaults.overlayY,
        },
        {
            type = "slider",
            name = "Overlay transparency",
            tooltip = "Adjust the overlay background transparency. Lower values are more transparent.",
            min = 0.20,
            max = 1.00,
            step = 0.05,
            decimals = 2,
            getFunc = function() return CR.sv.overlayAlpha end,
            setFunc = function(value) CR.sv.overlayAlpha = value; CR:PreviewOverlayForAdjustment() end,
            default = CR.defaults.overlayAlpha,
        },
        {
            type = "checkbox",
            name = "Only show in Companion menu",
            tooltip = "When enabled, the overlay/panel hides outside Companion scenes. Turn this off if you want /companionrapport to show it anywhere.",
            getFunc = function() return CR.sv.showOnlyInCompanionMenu end,
            setFunc = function(value) CR.sv.showOnlyInCompanionMenu = value; CR:Refresh() end,
            default = CR.defaults.showOnlyInCompanionMenu,
        },
        {
            type = "checkbox",
            name = "Only show on Companion overview tab",
            tooltip = "When enabled, the overlay/panel only appears while the Overview/Character tab of the in-game Companion menu is selected.",
            getFunc = function() return CR.sv.onlyShowOnOverview end,
            setFunc = function(value) CR.sv.onlyShowOnOverview = value; CR:Refresh() end,
            default = CR.defaults.onlyShowOnOverview,
        },
        {
            type = "checkbox",
            name = "Show greatly positive actions",
            getFunc = function() return CR.sv.showMajorPositive end,
            setFunc = function(value) CR.sv.showMajorPositive = value; CR:Refresh() end,
            default = CR.defaults.showMajorPositive,
        },
        {
            type = "checkbox",
            name = "Show light positive actions",
            getFunc = function() return CR.sv.showLightPositive end,
            setFunc = function(value) CR.sv.showLightPositive = value; CR:Refresh() end,
            default = CR.defaults.showLightPositive,
        },
        {
            type = "checkbox",
            name = "Show negative actions",
            getFunc = function() return CR.sv.showNegative end,
            setFunc = function(value) CR.sv.showNegative = value; CR:Refresh() end,
            default = CR.defaults.showNegative,
        },
        {
            type = "slider",
            name = "Max rows per section",
            min = 4,
            max = 24,
            step = 1,
            getFunc = function() return CR.sv.maxRowsPerSection end,
            setFunc = function(value) CR.sv.maxRowsPerSection = value; CR:Refresh() end,
            default = CR.defaults.maxRowsPerSection,
        },
        {
            type = "checkbox",
            name = "Show companion summon system messages",
            tooltip = "Shows a Companion Rapport system message with relationship status and rapport progress whenever you summon a companion.",
            getFunc = function() return CR.sv.companionSummonMessages end,
            setFunc = function(value) CR.sv.companionSummonMessages = value end,
            default = CR.defaults.companionSummonMessages,
        },
        {
            type = "checkbox",
            name = "Show rapport change system messages",
            tooltip = "Shows a Companion Rapport system message when companion rapport goes up or down, including current progress toward the next rapport rank.",
            getFunc = function() return CR.sv.rapportChangeMessages end,
            setFunc = function(value) CR.sv.rapportChangeMessages = value end,
            default = CR.defaults.rapportChangeMessages,
        },
        {
            type = "button",
            name = "Reset panel position",
            func = function()
                CR.sv.overlayX = CR.defaults.overlayX
                CR.sv.overlayY = CR.defaults.overlayY
                CR:Refresh()
            end,
        },
    })
end

function CR:OpenSettingsMenu()
    local LAM = LibAddonMenu2
    if LAM and LAM.OpenToPanel and self.optionsPanel then
        local ok = pcall(function() LAM:OpenToPanel(self.optionsPanel) end)
        if ok then return end
        pcall(function() LAM.OpenToPanel(self.optionsPanel) end)
        return
    end
    Msg("settings menu is available from Start > Add-ons > Companion Rapport once LibAddonMenu-2.0 is loaded.")
end

function CR:UpdateRapportBaseline()
    self.lastRapportValue = GetCurrentCompanionRapport()
    self.lastRapportCompanion = GetCurrentCompanionName()
end


function CR:ShowRapportChangeMessage(delta, currentRapport)
    if self.sv and self.sv.rapportChangeMessages == false then return end
    delta = tonumber(delta) or 0
    if delta == 0 then return end
    local rank = GetRapportRank(currentRapport)
    local nextAt = tostring(rank.nextAt or 5500)
    local nextName = rank.nextName or "Max Rapport"
    local nextColor = rank.nextColor or COLOR_DARK_GREEN
    local changeColor = GetRapportChangeColor(delta)
    local currentText = currentRapport ~= nil and tostring(currentRapport) or "?"

    if d then
        d(C(changeColor, FormatRapportChangeAmount(delta) .. " Rapport:")
            .. " " .. C(rank.color, currentText)
            .. C(COLOR_GRAY, " / ")
            .. C(rank.color, nextAt)
            .. " " .. C(COLOR_GRAY, "until")
            .. " " .. C(nextColor, nextName))
    end
end

function CR:RegisterRapportChangeWatcher()
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "RapportChangeWatch", 1000, function()
        local companionName = GetCurrentCompanionName()
        local rapport = GetCurrentCompanionRapport()
        if not companionName or rapport == nil then
            self.lastRapportValue = nil
            self.lastRapportCompanion = nil
            return
        end

        -- A newly summoned or swapped companion establishes a baseline only.
        if self.lastRapportCompanion ~= companionName or self.lastRapportValue == nil then
            self.lastRapportCompanion = companionName
            self.lastRapportValue = rapport
            return
        end

        if rapport ~= self.lastRapportValue then
            local delta = rapport - self.lastRapportValue
            self.lastRapportValue = rapport
            self.lastRapportCompanion = companionName
            self:ShowRapportChangeMessage(delta, rapport)
            self:QueueRefresh()
        end
    end)
end


function CR:ShowCompanionSummonedMessage()
    if self.sv and self.sv.companionSummonMessages == false then return end
    local companionName = GetCurrentCompanionName()
    if not companionName then return end
    local rank, current, nextAt, nextName, nextColor = GetRelationshipSummaryForMessage()
    Msg(C(COLOR_WHITE, companionName)
        .. C(COLOR_GOLD, " has been summoned to join your party. ")
        .. C(COLOR_GOLD, "Your relationship status is currently ")
        .. C(rank.color, rank.name)
        .. C(COLOR_GOLD, ", with rapport of ")
        .. C(rank.color, current)
        .. C(COLOR_GOLD, " / ")
        .. C(rank.color, nextAt)
        .. C(COLOR_GOLD, " until you progress to ")
        .. C(nextColor, nextName)
        .. C(COLOR_GOLD, "."))
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    CR.sv = ZO_SavedVars:NewAccountWide("CompanionRapportSavedVars", 1, nil, CR.defaults)
    -- Migrate users from older builds that used embedInOverview/panelX/panelY.
    if CR.sv.anchoredOverlay == nil then CR.sv.anchoredOverlay = true end
    if CR.sv.showOnlyInCompanionMenu == nil then CR.sv.showOnlyInCompanionMenu = true end
    if CR.sv.onlyShowOnOverview == nil then CR.sv.onlyShowOnOverview = true end
    if CR.sv.autoSizeOverlay == nil then CR.sv.autoSizeOverlay = false end
    if CR.sv.overlayWidth == nil then CR.sv.overlayWidth = CR.defaults.overlayWidth end
    if CR.sv.overlayHeight == nil then CR.sv.overlayHeight = CR.defaults.overlayHeight end
    CR.sv.autoSizeOverlay = false
    if CR.sv.snapOverlayToOverview == nil then CR.sv.snapOverlayToOverview = false end
    if CR.sv.useDefaultMenuBackdrop == nil then CR.sv.useDefaultMenuBackdrop = true end
    if CR.sv.overlayAlpha == nil then CR.sv.overlayAlpha = 0.88 end
    CR.sv.gamepadRightStickScroll = true
    if CR.sv.companionSummonMessages == nil then CR.sv.companionSummonMessages = CR.defaults.companionSummonMessages end
    if CR.sv.rapportChangeMessages == nil then CR.sv.rapportChangeMessages = CR.defaults.rapportChangeMessages end

    -- One-time 2.0.2 layout migration requested by Bankroll: Companion-menu only,
    -- overview-tab only, fixed 540x900 overlay, and default X/Y position 80/-70.
    if (tonumber(CR.sv.migrationVersion) or 0) < 21 then
        CR.sv.showOnlyInCompanionMenu = true
        CR.sv.onlyShowOnOverview = true
        CR.sv.snapOverlayToOverview = false
        CR.sv.overlayX = CR.defaults.overlayX
        CR.sv.overlayY = CR.defaults.overlayY
        CR.sv.overlayAlpha = 0.88
        CR.sv.autoSizeOverlay = false
        CR.sv.overlayWidth = CR.defaults.overlayWidth
        CR.sv.overlayHeight = CR.defaults.overlayHeight
        CR.sv.migrationVersion = 21
    end
    CR:RegisterLAM()
    CR:RegisterSceneHooks()
    CR:RegisterGamepadScroll()
    CR:RegisterRapportChangeWatcher()
    SLASH_COMMANDS["/crapport"] = function() CR:Refresh() end
    SLASH_COMMANDS["/companionrapport"] = function() CR:Refresh() end
    SLASH_COMMANDS["/crmenu"] = function() CR:OpenSettingsMenu() end
    SLASH_COMMANDS["/crapportdebug"] = function() CR:Debug(); CR:Refresh() end
    SLASH_COMMANDS["/crapportoverlay"] = function() CR.sv.anchoredOverlay = not CR.sv.anchoredOverlay; CR:Refresh(); Msg("current companion overlay " .. (CR.sv.anchoredOverlay and "enabled" or "disabled") .. ".") end
    SLASH_COMMANDS["/crapportreset"] = function()
        CR.sv.overlayX = CR.defaults.overlayX
        CR.sv.overlayY = CR.defaults.overlayY
        CR:Refresh()
        Msg("panel position reset.")
    end

    Msg("loaded. Use /crmenu or press start and navigate to Add-ons, then select 'Companion Rapport', for additional settings and customization.", COLOR_GOLD)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
