-- RealisticNeedsAndDiseases_StatusBar.lua
-- On-screen status display, REPLICATING Frostfall's own
-- TemperatureHUD.lua pattern: a draggable top-level window with a tooltip-
-- style backdrop, containing label+value row pairs where the value text is
-- large and colored by how good/bad that value currently is — rather than
-- icons.
--
-- Pattern (same as Frostfall's HUD, which itself credits this exact
-- structure to the RolePlayNeeds reference addon originally):
--   CreateTopLevelWindow → CT_BACKDROP background → per-row CT_LABEL pairs
--   (small label above, larger colored value below) → SetMovable with
--   OnMoveStop persisting position to SavedVariables.

RealisticNeeds = RealisticNeeds or {}
local RN = RealisticNeeds

local StatusBar = {}
RN.StatusBar = StatusBar

-- ============================================================
-- LAYOUT CONSTANTS
-- ============================================================
local WINDOW_WIDTH  = 220
local ROW_HEIGHT     = 36
local LABEL_FONT      = "$(BOLD_FONT)|11|outline"
local STATUS_FONT     = "$(BOLD_FONT)|15|outline"
local DISEASE_FONT    = "$(BOLD_FONT)|13|outline"
local PAD_LEFT        = 10
local PAD_TOP         = 8
local ROW_GAP         = 4

-- ============================================================
-- COLOR RAMP — 0 (empty, bad) -> 50 (warning) -> 100 (full, good)
-- ============================================================
local VALUE_COLORS = {
    [0]   = { r = 1.0, g = 0.13, b = 0.13 },  -- empty / critical
    [25]  = { r = 1.0, g = 0.55, b = 0.1  },  -- low
    [50]  = { r = 1.0, g = 0.85, b = 0.2  },  -- warning
    [75]  = { r = 0.6, g = 0.9,  b = 0.3  },  -- good
    [100] = { r = 0.2, g = 0.9,  b = 0.2  },  -- full
}
local VALUE_COLOR_KEYS = { 0, 25, 50, 75, 100 }

local function LerpColor(c1, c2, t)
    return { r = c1.r + (c2.r - c1.r) * t, g = c1.g + (c2.g - c1.g) * t, b = c1.b + (c2.b - c1.b) * t }
end

local function GetValueColor(value)
    value = math.max(0, math.min(100, value))
    for i = 1, #VALUE_COLOR_KEYS - 1 do
        local lo, hi = VALUE_COLOR_KEYS[i], VALUE_COLOR_KEYS[i + 1]
        if value <= hi then
            local t = (value - lo) / (hi - lo)
            return LerpColor(VALUE_COLORS[lo], VALUE_COLORS[hi], t)
        end
    end
    return VALUE_COLORS[100]
end

-- ============================================================
-- TOP-LEVEL WINDOW (file scope, created before Initialize — same as Frostfall's HUD)
-- ============================================================
local window = WINDOW_MANAGER:CreateTopLevelWindow("RealisticNeeds_StatusWindow")

local rows = {}        -- rows[needName] = { labelCtrl, valueCtrl }
local diseaseLines = {} -- pooled disease-line label controls, created on demand

function StatusBar.Initialize()
    local sv = RN.SavedVars
    sv.settings.statusBarPosition = sv.settings.statusBarPosition or { x = 16, y = 100 }

    window:SetDimensions(WINDOW_WIDTH, 220)  -- height grows dynamically for disease lines, see Refresh()
    window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.settings.statusBarPosition.x, sv.settings.statusBarPosition.y)
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetClampedToScreen(true)
    window:SetHandler("OnMoveStop", function()
        sv.settings.statusBarPosition.x = window:GetLeft()
        sv.settings.statusBarPosition.y = window:GetTop()
    end)
    window:SetHidden(true)

    local bg = WINDOW_MANAGER:CreateControl("RealisticNeeds_StatusWindowBG", window, CT_BACKDROP)
    bg:SetAnchorFill(window)
    bg:SetCenterColor(0.05, 0.05, 0.1, 0.82)
    bg:SetEdgeColor(0.2, 0.4, 0.8, 0.9)
    bg:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Tooltip-Border.dds", 128, 16, 16)
    bg:SetInsets(4, 4, -4, -4)

    local function MakeRow(needName, leftText, offsetY)
        local lbl = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
        lbl:SetFont(LABEL_FONT)
        lbl:SetAnchor(TOPLEFT, window, TOPLEFT, PAD_LEFT, offsetY)
        lbl:SetText(leftText)
        lbl:SetColor(0.7, 0.85, 1.0, 0.8)

        local status = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
        status:SetFont(STATUS_FONT)
        status:SetAnchor(TOPLEFT, window, TOPLEFT, PAD_LEFT, offsetY + 14)
        status:SetWidth(WINDOW_WIDTH - PAD_LEFT * 2)
        status:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        status:SetText("")
        status:SetColor(1, 1, 1, 1)

        rows[needName] = { label = lbl, status = status }
    end

    local row1Y = PAD_TOP
    local row2Y = row1Y + ROW_HEIGHT + ROW_GAP
    local row3Y = row2Y + ROW_HEIGHT + ROW_GAP
    local row4Y = row3Y + ROW_HEIGHT + ROW_GAP

    MakeRow("hunger",      "HUNGER",      row1Y)
    MakeRow("thirst",      "THIRST",      row2Y)
    MakeRow("fatigue",     "FATIGUE",     row3Y)
    MakeRow("drunkenness", "DRUNKENNESS", row4Y)

    local function MakeSep(offsetY)
        local sep = WINDOW_MANAGER:CreateControl(nil, window, CT_TEXTURE)
        sep:SetAnchor(TOPLEFT,  window, TOPLEFT,  PAD_LEFT, offsetY)
        sep:SetAnchor(TOPRIGHT, window, TOPRIGHT, -PAD_LEFT, offsetY)
        sep:SetHeight(1)
        sep:SetTexture("EsoUI/Art/miscellaneous/colorized_gradient_alpha.dds")
        sep:SetColor(0.3, 0.5, 0.8, 0.4)
    end
    MakeSep(row2Y - 2)
    MakeSep(row3Y - 2)
    MakeSep(row4Y - 2)

    -- "DISEASES" section header, just below the four need rows. Individual
    -- disease lines are created/destroyed on demand in Refresh() since the
    -- count varies (0 to 6 active at once).
    StatusBar._diseaseHeaderY = row4Y + ROW_HEIGHT + ROW_GAP
    local diseaseHeaderSep = WINDOW_MANAGER:CreateControl(nil, window, CT_TEXTURE)
    diseaseHeaderSep:SetAnchor(TOPLEFT,  window, TOPLEFT,  PAD_LEFT, StatusBar._diseaseHeaderY - 2)
    diseaseHeaderSep:SetAnchor(TOPRIGHT, window, TOPRIGHT, -PAD_LEFT, StatusBar._diseaseHeaderY - 2)
    diseaseHeaderSep:SetHeight(1)
    diseaseHeaderSep:SetTexture("EsoUI/Art/miscellaneous/colorized_gradient_alpha.dds")
    diseaseHeaderSep:SetColor(0.3, 0.5, 0.8, 0.4)

    StatusBar._initialized = true
end

-- Rebuilds the disease-line labels to match the currently active diseases,
-- resizing the window to fit. Pools/reuses controls rather than recreating
-- them every refresh.
local function RefreshDiseaseLines(sv)
    local activeList = {}
    for diseaseId, state in pairs(sv.diseaseState) do
        local def = RN.Diseases[diseaseId]
        if def then
            table.insert(activeList, { def = def, severity = state.severity })
        end
    end

    for i, entry in ipairs(activeList) do
        local lbl = diseaseLines[i]
        if not lbl then
            lbl = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
            lbl:SetFont(DISEASE_FONT)
            lbl:SetAnchor(TOPLEFT, window, TOPLEFT, PAD_LEFT, StatusBar._diseaseHeaderY + 4 + (i - 1) * 18)
            diseaseLines[i] = lbl
        end
        local severityName = ({ "Mild", "Moderate", "Severe" })[entry.severity] or "?"
        lbl:SetText(string.format("%s (%s)", entry.def.name, severityName))
        if entry.def.overlayColor then
            lbl:SetColor(entry.def.overlayColor[1], entry.def.overlayColor[2], entry.def.overlayColor[3], 1)
        end
        lbl:SetHidden(false)
    end

    -- Hide any pooled lines beyond the current active count.
    for i = #activeList + 1, #diseaseLines do
        diseaseLines[i]:SetHidden(true)
    end

    if #activeList == 0 then
        local lbl = diseaseLines[1]
        if not lbl then
            lbl = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
            lbl:SetFont(DISEASE_FONT)
            lbl:SetAnchor(TOPLEFT, window, TOPLEFT, PAD_LEFT, StatusBar._diseaseHeaderY + 4)
            diseaseLines[1] = lbl
        end
        lbl:SetText("No active diseases")
        lbl:SetColor(0.6, 0.6, 0.6, 1)
        lbl:SetHidden(false)
    end

    local extraHeight = math.max(1, #activeList) * 18
    window:SetHeight(StatusBar._diseaseHeaderY + 10 + extraHeight)
end

function StatusBar.Refresh(sv)
    if not StatusBar._initialized then return end
    if not sv.settings.showStatusBar then return end

    for needName, row in pairs(rows) do
        local value = sv.needs[needName]
        -- Drunkenness is a buildup stat (high = bad), the opposite direction
        -- from hunger/thirst/fatigue (low = bad) — invert before color lookup.
        local colorValue = (needName == "drunkenness") and (100 - value) or value
        local col = GetValueColor(colorValue)

        if RN.Feedback and RN.Feedback.GetBandMessage then
            row.status:SetText(RN.Feedback.GetBandMessage(needName, value))
            row.status:SetColor(col.r, col.g, col.b, 1)
        end
    end

    RefreshDiseaseLines(sv)
end

function StatusBar.SetShown(shown)
    if not StatusBar._initialized then return end
    window:SetHidden(not shown)
end
