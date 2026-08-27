-- RealisticNeedsAndDiseases_StatusBars.lua
-- A fourth status display option — mini health-bar-style bars, one per
-- need + one per currently-active disease, instead of icons or text rows.
-- Uses ESO's native CT_STATUSBAR control type (the same control type the
-- game's own health/magicka/stamina bars are built from) via SetMinMax/
-- SetValue/SetColor — a well-established, standard ESO UI pattern, though
-- this is its first use in THIS codebase specifically; worth a quick
-- in-game sanity check on first load.
--
-- Independent Settings toggle, can run alongside the text status window
-- and/or the transparency-based icon display.
--
-- DESIGN: hunger/thirst/fatigue bars are FULL = GOOD, EMPTY = CRITICAL,
-- matching a health bar's own metaphor directly, and are always shown (3
-- fixed rows). Drunkenness is handled differently on purpose: rather than
-- inverting it into an always-shown "Sobriety" bar, it's a DYNAMIC row —
-- hidden entirely at 0 (sober), appearing only once actually inebriated,
-- and filling UP as drunkenness increases (same direction as the raw
-- value, no inversion) — same shape as the disease rows below it, since
-- being drunk is something accumulating on top of a normal baseline, not
-- a resource being spent down. Disease bars are the same idea: full =
-- Severe, not full = cured, since a disease is something you're
-- accumulating, not spending.
--
-- Row order: hunger/thirst/fatigue (fixed, always shown) → drunkenness →
-- diseases (both dynamic, shown/hidden as they become relevant, appended
-- below the 3 fixed rows in that order).

RealisticNeeds = RealisticNeeds or {}
local RN = RealisticNeeds

local StatusBars = {}
RN.StatusBars = StatusBars

-- ============================================================
-- LAYOUT CONSTANTS
-- ============================================================
local BAR_WIDTH   = 120
local BAR_HEIGHT  = 12
local LABEL_WIDTH = 66
local ROW_HEIGHT  = BAR_HEIGHT + 6
local PAD         = 8

-- Always-shown rows, full = good.
local FIXED_NEEDS_ORDER = { "hunger", "thirst", "fatigue" }
local NEEDS_LABEL = { hunger = "Hunger", thirst = "Thirst", fatigue = "Fatigue", drunkenness = "Drunkenness" }

-- Band -> color, same green/yellow/orange/red ramp the other displays use.
local NEED_BAND_COLORS = {
    [1] = { r = 0.3, g = 0.9,  b = 0.3  },
    [2] = { r = 0.9, g = 0.85, b = 0.2  },
    [3] = { r = 1.0, g = 0.55, b = 0.1  },
    [4] = { r = 1.0, g = 0.15, b = 0.15 },
}
local DISEASE_SEVERITY_COLORS = {
    [1] = { r = 0.95, g = 0.85, b = 0.3  },
    [2] = { r = 1.0,  g = 0.55, b = 0.1  },
    [3] = { r = 1.0,  g = 0.15, b = 0.15 },
}

-- ============================================================
-- TOP-LEVEL WINDOW
-- ============================================================
local window = WINDOW_MANAGER:CreateTopLevelWindow("RealisticNeeds_StatusBarsWindow")

-- Pooled rows, keyed by need name / diseaseId: { container, label, bar, tooltipText }
local rows = {}

local function CreateRow(key, labelText, offsetY)
    local container = WINDOW_MANAGER:CreateControl(nil, window, CT_CONTROL)
    container:SetDimensions(LABEL_WIDTH + BAR_WIDTH + 4, ROW_HEIGHT)
    container:SetAnchor(TOPLEFT, window, TOPLEFT, PAD, offsetY)

    local label = WINDOW_MANAGER:CreateControl(nil, container, CT_LABEL)
    label:SetFont("$(BOLD_FONT)|11|outline")
    label:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 1)
    label:SetDimensions(LABEL_WIDTH, ROW_HEIGHT)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetColor(0.85, 0.85, 0.9, 1)
    label:SetText(labelText)

    -- Dark backdrop behind the bar so the fill has a visible track/frame,
    -- same way the game's own health bar has a background under the fill.
    local backdrop = WINDOW_MANAGER:CreateControl(nil, container, CT_BACKDROP)
    backdrop:SetDimensions(BAR_WIDTH, BAR_HEIGHT)
    backdrop:SetAnchor(TOPLEFT, container, TOPLEFT, LABEL_WIDTH + 4, 2)
    backdrop:SetCenterColor(0.05, 0.05, 0.08, 0.9)
    backdrop:SetEdgeColor(0, 0, 0, 0.9)
    backdrop:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Tooltip-Border.dds", 32, 4, 4)
    backdrop:SetInsets(1, 1, -1, -1)

    local bar = WINDOW_MANAGER:CreateControl(nil, backdrop, CT_STATUSBAR)
    bar:SetDimensions(BAR_WIDTH - 2, BAR_HEIGHT - 2)
    bar:SetAnchor(CENTER, backdrop, CENTER, 0, 0)
    bar:SetMinMax(0, 100)
    bar:SetValue(100)

    backdrop:SetMouseEnabled(true)
    backdrop:SetHandler("OnMouseEnter", function(self)
        InitializeTooltip(ZO_Tooltip, self, TOPLEFT, 0, BAR_HEIGHT + 4)
        local text = rows[key] and rows[key].tooltipText
        ZO_Tooltip:AddLine(text or "", "", 1, 1, 1)
    end)
    backdrop:SetHandler("OnMouseExit", function()
        ClearTooltip(ZO_Tooltip)
    end)

    return { container = container, label = label, bar = bar, tooltipText = "" }
end

function StatusBars.Initialize()
    local sv = RN.SavedVars
    sv.settings.statusBarsPosition = sv.settings.statusBarsPosition or { x = 16, y = 220 }

    window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.settings.statusBarsPosition.x, sv.settings.statusBarsPosition.y)
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetClampedToScreen(true)
    window:SetHandler("OnMoveStop", function()
        sv.settings.statusBarsPosition.x = window:GetLeft()
        sv.settings.statusBarsPosition.y = window:GetTop()
    end)
    window:SetHidden(true)

    -- Background created first so it draws behind the rows by default
    -- creation-order z-stacking (same pattern as the other display files).
    local bg = WINDOW_MANAGER:CreateControl("RealisticNeeds_StatusBarsBG", window, CT_BACKDROP)
    bg:SetCenterColor(0.05, 0.05, 0.1, 0.55)
    bg:SetEdgeColor(0.2, 0.4, 0.8, 0.7)
    bg:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Tooltip-Border.dds", 128, 16, 16)
    bg:SetInsets(4, 4, -4, -4)

    local offsetY = PAD
    for _, needName in ipairs(FIXED_NEEDS_ORDER) do
        rows[needName] = CreateRow(needName, NEEDS_LABEL[needName], offsetY)
        offsetY = offsetY + ROW_HEIGHT
    end
    StatusBars._dynamicStartY = offsetY

    window:SetDimensions(LABEL_WIDTH + BAR_WIDTH + PAD * 2 + 4, offsetY + PAD)
    bg:SetAnchorFill(window)

    StatusBars.ApplyDisplaySettings(sv)
    StatusBars._initialized = true
end

-- Applies the "Bar Size" and "Bar Opacity" sliders (Settings.lua) to the
-- whole display in one shot. SetScale/SetAlpha on the TOP-LEVEL window
-- cascade to every child (background, every row's label/backdrop/bar)
-- automatically — no per-row layout math needed. Called from Initialize()
-- and directly from the Settings sliders' setFunc.
function StatusBars.ApplyDisplaySettings(sv)
    window:SetScale(sv.settings.statusBarsScale or 1.0)
    window:SetAlpha(sv.settings.statusBarsOpacity or 1.0)
end

function StatusBars.Refresh(sv)
    if not StatusBars._initialized then return end
    if not sv.settings.statusBarsEnabled then return end

    for _, needName in ipairs(FIXED_NEEDS_ORDER) do
        local row = rows[needName]
        local value = sv.needs[needName]
        local band = RN.Feedback.GetBand(needName, value)
        row.bar:SetValue(value)
        row.bar:SetColor(NEED_BAND_COLORS[band].r, NEED_BAND_COLORS[band].g, NEED_BAND_COLORS[band].b, 1)
        row.tooltipText = string.format(
            "%s: %d\n%s",
            needName:sub(1, 1):upper() .. needName:sub(2), math.floor(value), RN.Feedback.GetBandMessage(needName, value)
        )
    end

    local offsetY = StatusBars._dynamicStartY

    -- Drunkenness: dynamic row, hidden entirely while sober (value 0),
    -- appearing only once actually inebriated and filling UP as it
    -- increases — same raw-value direction, no inversion. See the file
    -- header comment for why this one isn't a fixed always-shown row like
    -- the 3 above.
    do
        local value = sv.needs.drunkenness
        local row = rows.drunkenness
        if value > 0 then
            if not row then
                row = CreateRow("drunkenness", NEEDS_LABEL.drunkenness, offsetY)
                rows.drunkenness = row
            end
            row.container:ClearAnchors()
            row.container:SetAnchor(TOPLEFT, window, TOPLEFT, PAD, offsetY)
            row.container:SetHidden(false)
            offsetY = offsetY + ROW_HEIGHT

            local band = RN.Feedback.GetBand("drunkenness", value)
            row.bar:SetValue(value)
            row.bar:SetColor(NEED_BAND_COLORS[band].r, NEED_BAND_COLORS[band].g, NEED_BAND_COLORS[band].b, 1)
            row.tooltipText = string.format(
                "Drunkenness: %d\n%s", math.floor(value), RN.Feedback.GetBandMessage("drunkenness", value)
            )
        elseif row then
            row.container:SetHidden(true)
        end
    end

    for _, diseaseId in ipairs(RN.DISEASE_ORDER) do
        local state = sv.diseaseState[diseaseId]
        local row = rows[diseaseId]
        if state then
            if not row then
                row = CreateRow(diseaseId, RN.Diseases[diseaseId] and RN.Diseases[diseaseId].name or diseaseId, offsetY)
                rows[diseaseId] = row
            end
            row.container:ClearAnchors()
            row.container:SetAnchor(TOPLEFT, window, TOPLEFT, PAD, offsetY)
            row.container:SetHidden(false)
            offsetY = offsetY + ROW_HEIGHT

            -- Disease bars fill UP as severity worsens (full = Severe) —
            -- the opposite direction from the fixed needs bars above. See
            -- the file header comment for why: a disease is something
            -- you're accumulating, not a resource you're spending down.
            row.bar:SetValue((state.severity / RN.SEVERITY_SEVERE) * 100)
            local color = DISEASE_SEVERITY_COLORS[state.severity] or DISEASE_SEVERITY_COLORS[1]
            row.bar:SetColor(color.r, color.g, color.b, 1)

            local def = RN.Diseases[diseaseId]
            local severityName = ({ "Mild", "Moderate", "Severe" })[state.severity] or "?"
            local hint = RN.Feedback.GetCureHintText(diseaseId, state.severity)
            row.tooltipText = string.format(
                "%s (%s)%s",
                def and def.name or diseaseId, severityName, hint and ("\n" .. hint) or ""
            )
        elseif row then
            row.container:SetHidden(true)
        end
    end

    window:SetHeight(math.max(StatusBars._dynamicStartY, offsetY) + PAD)
end

function StatusBars.SetShown(shown)
    if not StatusBars._initialized then return end
    window:SetHidden(not shown)
end
