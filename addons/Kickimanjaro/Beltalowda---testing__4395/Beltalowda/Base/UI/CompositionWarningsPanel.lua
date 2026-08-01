-- Beltalowda Composition Warnings Panel
-- Moveable panel toggled by the Composition Warnings button.
-- Shows current composition warnings with severity colouring.

Beltalowda = Beltalowda or {}
Beltalowda.UI = Beltalowda.UI or {}
Beltalowda.UI.CompositionWarningsPanel = {}

local CWP = Beltalowda.UI.CompositionWarningsPanel
local wm = WINDOW_MANAGER

-- ============================================================================
-- Constants
-- ============================================================================

CWP.PANEL_WIDTH = 320
CWP.PADDING = 14
CWP.CONTENT_INSET = 8
CWP.TITLE_HEIGHT = 42
CWP.WARNING_ROW_HEIGHT = 18
CWP.ROLE_HEADER_HEIGHT = 22
CWP.SET_INDENT = 14
CWP.CLOSE_BUTTON_HEIGHT = 28
CWP.FOOTER_HEIGHT = 50
CWP.FONT_TITLE = "ZoFontWinH1"
CWP.FONT_HEADER = "ZoFontWinH4"
CWP.FONT_NORMAL = "ZoFontGameSmall"

-- ============================================================================
-- State
-- ============================================================================

CWP.state = {
    initialized = false,
    visible = false,
    menuHidden = false,
    pvpHidden = false,
}

-- UI controls
CWP.controls = {
    window = nil,
    backdrop = nil,
}

-- ============================================================================
-- Settings
-- ============================================================================

CWP.settings = {
    positionX = 200,
    positionY = 200,
}

function CWP.LoadSettings()
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.ui = BeltalowdaVars.ui or {}
    BeltalowdaVars.ui.compositionWarningsPanel = BeltalowdaVars.ui.compositionWarningsPanel or {}
    local saved = BeltalowdaVars.ui.compositionWarningsPanel
    CWP.settings.positionX = saved.positionX or 200
    CWP.settings.positionY = saved.positionY or 200
end

function CWP.SaveSettings()
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.ui = BeltalowdaVars.ui or {}
    BeltalowdaVars.ui.compositionWarningsPanel = {
        positionX = CWP.settings.positionX,
        positionY = CWP.settings.positionY,
    }
end

-- ============================================================================
-- Initialize
-- ============================================================================

function CWP.Initialize()
    if CWP.state.initialized then return end

    CWP.LoadSettings()
    CWP.CreatePanel()
    CWP.state.initialized = true
end

-- ============================================================================
-- Panel creation
-- ============================================================================

function CWP.CreatePanel()
    if CWP.controls.window then return end

    local win = wm:CreateTopLevelWindow("BeltalowdaCompositionWarningsPanel")
    win:SetDimensions(CWP.PANEL_WIDTH, 100)  -- Height recalculated dynamically
    win:SetClampedToScreen(true)
    win:SetMouseEnabled(true)
    win:SetMovable(true)
    win:SetHidden(true)
    win:SetDrawLayer(DL_OVERLAY)
    win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CWP.settings.positionX, CWP.settings.positionY)

    win:SetHandler("OnMoveStop", function(control)
        CWP.settings.positionX = control:GetLeft()
        CWP.settings.positionY = control:GetTop()
        CWP.SaveSettings()
    end)

    -- ── Main backdrop (ZO_InsetBackdrop — matching group composition panel)
    local bd = CreateControlFromVirtual("BeltalowdaCWPBackdrop", win, "ZO_InsetBackdrop")
    bd:SetAnchorFill(win)
    bd:SetCenterColor(0.06, 0.05, 0.05, 0.92)
    bd:SetEdgeColor(0, 0, 0, 0)

    -- ── Header divider ───────────────────────────────────────────────────
    local headerDivider = wm:CreateControl(nil, win, CT_TEXTURE)
    headerDivider:SetTexture("EsoUI/Art/Miscellaneous/horizontalDivider.dds")
    headerDivider:SetAnchor(TOPLEFT, win, TOPLEFT, 4, CWP.TITLE_HEIGHT - 2)
    headerDivider:SetAnchor(TOPRIGHT, win, TOPRIGHT, -4, CWP.TITLE_HEIGHT - 2)
    headerDivider:SetHeight(4)
    headerDivider:SetColor(0.85, 0.75, 0.5, 0.8)
    headerDivider:SetDrawLevel(2)

    -- ── Title label ──────────────────────────────────────────────────────
    local title = wm:CreateControl(nil, win, CT_LABEL)
    title:SetFont(CWP.FONT_TITLE)
    title:SetText("Group Warnings")
    title:SetColor(0.85, 0.75, 0.5, 1)
    title:SetAnchor(TOP, win, TOP, 0, 6)
    title:SetDimensions(CWP.PANEL_WIDTH - CWP.PADDING * 2, CWP.TITLE_HEIGHT - 10)
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    title:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    -- ── Close button (ZO_DefaultButton style) ────────────────────────────
    local closeBtn = CreateControlFromVirtual("BeltalowdaCWPCloseBtn", win, "ZO_DefaultButton")
    closeBtn:SetDimensions(130, CWP.CLOSE_BUTTON_HEIGHT)
    closeBtn:SetAnchor(BOTTOM, win, BOTTOM, 0, -15)
    closeBtn:SetText("Close")
    closeBtn:SetClickSound(SOUNDS.BOOK_ACQUIRED)
    closeBtn:SetHandler("OnClicked", function() CWP.Hide() end)

    CWP.controls.window = win
    CWP.controls.backdrop = bd
    CWP.controls.headerDivider = headerDivider
    CWP.controls.title = title
    CWP.controls.closeBtn = closeBtn
end

-- ============================================================================
-- Toggle / Show / Hide
-- ============================================================================

function CWP.Toggle(anchorControl)
    if CWP.state.visible then
        CWP.Hide()
    else
        CWP.Show(anchorControl)
    end
end

function CWP.Show(anchorControl)
    if not CWP.controls.window then return end
    CWP.state.visible = true

    CWP.Refresh()
    CWP.controls.window:SetHidden(false)
end

function CWP.Hide()
    if CWP.controls.window then
        CWP.controls.window:SetHidden(true)
    end
    CWP.state.visible = false
end

function CWP.SetMenuHidden(hidden)
    CWP.state.menuHidden = hidden
    if not CWP.controls.window then return end
    if hidden then
        -- Temporarily hide the window but keep visible state so it restores
        CWP.controls.window:SetHidden(true)
    elseif CWP.state.visible and not CWP.state.pvpHidden then
        -- Menu layer cleared — restore the panel if it was logically open and in PvP
        CWP.controls.window:SetHidden(false)
    end
end

function CWP.SetPvPHidden(hidden)
    CWP.state.pvpHidden = hidden
    if not CWP.controls.window then return end
    if hidden then
        CWP.controls.window:SetHidden(true)
    elseif CWP.state.visible and not CWP.state.menuHidden then
        CWP.controls.window:SetHidden(false)
    end
end

-- ============================================================================
-- Refresh (rebuild all dynamic content)
-- ============================================================================

function CWP.Refresh()
    if not CWP.controls.window then return end

    CWP.DestroyDynamicControls()

    local parent = CWP.controls.window
    local y = CWP.TITLE_HEIGHT + CWP.CONTENT_INSET

    local warnings = {}
    if Beltalowda.Composition then
        warnings = Beltalowda.Composition.GetWarnings()
    end

    if GetGroupSize() == 0 then
        y = CWP.CreateTextRow(parent, y, "Not in a group", 0.6, 0.6, 0.6)
    else
        -- Group warnings by category
        local categories = { "buffs", "sets", "synergies", "consumables" }
        local categoryLabels = {
            buffs        = "Buffs",
            sets         = "Sets",
            synergies    = "Synergies",
            consumables  = "Consumables",
        }
        local noWarningLabels = {
            buffs        = "No buff warnings",
            sets         = "No set warnings",
            synergies    = "No synergy warnings",
            consumables  = "No consumable warnings",
        }

        -- Bucket warnings by category
        local buckets = {}
        for _, cat in ipairs(categories) do buckets[cat] = {} end
        for _, w in ipairs(warnings) do
            local cat = w.category or "buffs"
            if not buckets[cat] then buckets[cat] = {} end
            table.insert(buckets[cat], w)
        end

        for _, cat in ipairs(categories) do
            -- Sub-header
            y = CWP.CreateSectionHeader(parent, y, categoryLabels[cat])

            if #buckets[cat] == 0 then
                y = CWP.CreateTextRow(parent, y, noWarningLabels[cat], 0, 1, 0)
            else
                for _, w in ipairs(buckets[cat]) do
                    local r, g, b = 1, 1, 0
                    if w.severity == "high" then
                        r, g, b = 1, 0, 0
                    elseif w.severity == "medium" then
                        r, g, b = 1, 0.5, 0
                    end
                    local displayMsg = CWP.AddBuffIcon(w.message)
                    y = CWP.CreateTextRow(parent, y, displayMsg, r, g, b)
                    if w.children then
                        for _, child in ipairs(w.children) do
                            local displayText = CWP.AddBuffIcon(child)
                            y = CWP.CreateTextRow(parent, y, displayText, r, g, b, CWP.WARNING_ROW_HEIGHT, CWP.SET_INDENT)
                        end
                    end
                end
            end
        end
    end

    local totalHeight = y + CWP.FOOTER_HEIGHT
    CWP.controls.window:SetDimensions(CWP.PANEL_WIDTH, totalHeight)
end

-- ============================================================================
-- Dynamic control helpers
-- ============================================================================

CWP.dynamicControls = {}

function CWP.DestroyDynamicControls()
    for _, ctrl in ipairs(CWP.dynamicControls) do
        ctrl:SetHidden(true)
        ctrl:ClearAnchors()
        ctrl:SetParent(nil)
    end
    CWP.dynamicControls = {}
end

function CWP.CreateSectionHeader(parent, y, text, r, g, b)
    r = r or 0.85; g = g or 0.75; b = b or 0.5

    local lbl = wm:CreateControl(nil, parent, CT_LABEL)
    lbl:SetFont(CWP.FONT_HEADER)
    lbl:SetText(text)
    lbl:SetColor(r, g, b, 1)
    lbl:SetAnchor(TOP, parent, TOPLEFT, CWP.PANEL_WIDTH / 2, y)
    lbl:SetDimensions(CWP.PANEL_WIDTH - CWP.PADDING * 2, CWP.ROLE_HEADER_HEIGHT)
    lbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    table.insert(CWP.dynamicControls, lbl)
    return y + CWP.ROLE_HEADER_HEIGHT
end

function CWP.CreateTextRow(parent, y, text, r, g, b, height, indent)
    height = height or CWP.WARNING_ROW_HEIGHT
    indent = indent or 0
    r = r or 1; g = g or 1; b = b or 1

    local lbl = wm:CreateControl(nil, parent, CT_LABEL)
    lbl:SetFont(CWP.FONT_NORMAL)
    lbl:SetText(text)
    lbl:SetColor(r, g, b, 1)
    lbl:SetAnchor(TOP, parent, TOPLEFT, CWP.PANEL_WIDTH / 2, y)
    lbl:SetDimensions(CWP.PANEL_WIDTH - CWP.PADDING * 2, height)
    lbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    table.insert(CWP.dynamicControls, lbl)
    return y + height
end

-- ============================================================================
-- Buff icon helper
-- ============================================================================

-- Representative ability IDs for known buff names (icon lookup)
local BUFF_ICON_ABILITIES = {
    ["Major Courage"]    = 109966,  -- Olorime / SPC
    ["Major Resolve"]    = 86126,   -- Expansive Frost Cloak
    ["Major Evasion"]    = 29556,   -- Evasion
    ["Minor Toughness"]  = 86127,   -- Minor Toughness
    ["Immunity to Snares and Immobilizations"] = 63569,  -- Unstoppable
}

--[[
    If 'text' matches a known buff name, return the text with an inline
    icon prepended using ESO's |t formatting.  Otherwise return unchanged.
]]
function CWP.AddBuffIcon(text)
    local abilityId = BUFF_ICON_ABILITIES[text]
    if abilityId then
        local icon = GetAbilityIcon(abilityId)
        if icon and icon ~= "" then
            return string.format("|t16:16:%s|t %s", icon, text)
        end
    end
    return text
end