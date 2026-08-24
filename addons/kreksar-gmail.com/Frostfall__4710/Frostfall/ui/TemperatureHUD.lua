-- Frostfall: Temperature HUD  (v2.7.0)
--
-- Layout: three equal-sized rows, all the same font size.
--   Row 1 — Zone temperature  (ambient from LibZoneTemp)
--   Row 2 — Player temperature (felt temperature after drift)
--   Row 3 — Insulation value  (from LibArmorInsulation)
--
-- Temperatures are displayed in °C or °F depending on FV.SV.useFahrenheit.
--
-- CRITICAL: Container must be a TopLevelWindow (not a child of GuiRoot).
-- Pattern confirmed by RolePlayNeeds reference addon.

Frostfall_HUD = Frostfall_HUD or {}
local HUD = Frostfall_HUD

local FV = Frostfall

-- ============================================================
-- LAYOUT CONSTANTS
-- ============================================================
local HUD_WIDTH   = 220
local HUD_HEIGHT  = 110
local ROW_HEIGHT  = 30      -- height of each data row
local ROW_FONT    = "$(BOLD_FONT)|20|outline"
local LABEL_FONT  = "$(BOLD_FONT)|11|outline"
local PAD_LEFT    = 10
local PAD_TOP     = 8
local ROW_GAP     = 4       -- extra gap between rows

-- ============================================================
-- COLOR RAMP  (maps comfort 0–100 to a colour for the player temp)
-- ============================================================
-- Keys are °C values matching FV.TEMP thresholds
local TEMP_COLORS = {
    [-20] = { r=0.2,  g=0.4,  b=1.0 },  -- extreme cold
    [ -5] = { r=0.4,  g=0.6,  b=1.0 },  -- very cold
    [ 10] = { r=0.3,  g=0.8,  b=0.9 },  -- cold
    [ 20] = { r=0.3,  g=0.9,  b=0.3 },  -- comfortable
    [ 30] = { r=0.9,  g=0.85, b=0.2 },  -- warm
    [ 38] = { r=1.0,  g=0.5,  b=0.1 },  -- hot (100°F)
    [ 55] = { r=1.0,  g=0.15, b=0.1 },  -- extreme heat
}
local TEMP_COLOR_KEYS = { -20, -5, 10, 20, 30, 38, 55 }

local function LerpColor(c1, c2, t)
    return { r=c1.r+(c2.r-c1.r)*t, g=c1.g+(c2.g-c1.g)*t, b=c1.b+(c2.b-c1.b)*t }
end

-- temp is in °C
local function GetTempColor(temp)
    temp = math.max(-20, math.min(60, temp))
    for i = 1, #TEMP_COLOR_KEYS - 1 do
        local lo = TEMP_COLOR_KEYS[i]
        local hi = TEMP_COLOR_KEYS[i+1]
        if temp <= hi then
            local t = (temp - lo) / (hi - lo)
            return LerpColor(TEMP_COLORS[lo], TEMP_COLORS[hi], t)
        end
    end
    return TEMP_COLORS[60]
end

-- ============================================================
-- STATUS LABEL  (for the status bar at the bottom)
-- ============================================================
-- Thresholds in °C, matching FV.TEMP constants
local TEMP_LABELS = {
    { threshold = -10, label = "FREEZING",    color = "4488FF" },
    { threshold =   0, label = "VERY COLD",   color = "66AAFF" },
    { threshold =  10, label = "COLD",        color = "88CCFF" },
    { threshold =  16, label = "COOL",        color = "AADDEE" },
    { threshold =  27, label = "COMFORTABLE", color = "55DD55" },
    { threshold =  38, label = "HOT",         color = "FF9933" },
    { threshold =  60, label = "VERY HOT",    color = "FF6611" },
    { threshold = 999, label = "OVERHEATING", color = "FF2211" },
}

local function GetTempLabel(temp)
    for _, e in ipairs(TEMP_LABELS) do
        if temp < e.threshold then return e.label, e.color end
    end
    return "OVERHEATING", "FF2211"
end

-- ============================================================
-- TOP-LEVEL WINDOW  (file scope — created before Initialize)
-- ============================================================
local hudWindow = WINDOW_MANAGER:CreateTopLevelWindow("FrostfallHUDWindow")

-- ============================================================
-- CONTROL CREATION
-- ============================================================

function HUD:CreateControls()
    local w = hudWindow

    w:SetDimensions(HUD_WIDTH, HUD_HEIGHT)
    w:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, FV.SV.hudPosition.x, FV.SV.hudPosition.y)
    w:SetMouseEnabled(true)
    w:SetMovable(true)
    w:SetClampedToScreen(true)
    w:SetHandler("OnMoveStop", function()
        FV.SV.hudPosition.x = w:GetLeft()
        FV.SV.hudPosition.y = w:GetTop()
    end)
    w:SetHidden(true)
    self.container = w

    -- Background
    self.bg = WINDOW_MANAGER:CreateControl("FrostfallHUDBG", w, CT_BACKDROP)
    self.bg:SetAnchorFill(w)
    self.bg:SetCenterColor(0.05, 0.05, 0.1, 0.82)
    self.bg:SetEdgeColor(0.2, 0.4, 0.8, 0.9)
    self.bg:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Tooltip-Border.dds", 128, 16, 16)
    self.bg:SetInsets(4, 4, -4, -4)

    -- ── Row helper: creates a left label + right value label pair ────────────
    -- offsetY is the top of the row relative to the window.
    local function MakeRow(suffix, leftText, offsetY)
        local lbl = WINDOW_MANAGER:CreateControl("FrostfallHUD" .. suffix .. "Lbl", w, CT_LABEL)
        lbl:SetFont(LABEL_FONT)
        lbl:SetAnchor(TOPLEFT, w, TOPLEFT, PAD_LEFT, offsetY)
        lbl:SetText(leftText)
        lbl:SetColor(0.7, 0.85, 1.0, 0.8)

        local val = WINDOW_MANAGER:CreateControl("FrostfallHUD" .. suffix .. "Val", w, CT_LABEL)
        val:SetFont(ROW_FONT)
        val:SetAnchor(TOPLEFT, w, TOPLEFT, PAD_LEFT, offsetY + 12)
        val:SetText("--")
        val:SetColor(1, 1, 1, 1)

        return lbl, val
    end

    local row1Y = PAD_TOP
    local row2Y = row1Y + ROW_HEIGHT + ROW_GAP
    local row3Y = row2Y + ROW_HEIGHT + ROW_GAP

    _, self.zoneTempVal        = MakeRow("ZoneTemp",  "ZONE",       row1Y)
    self.playerTempLbl, self.playerTempVal = MakeRow("PlayerTemp","FEELS LIKE", row2Y)
    _, self.insulationVal      = MakeRow("Insulation","INSULATION", row3Y)

    -- Thin separator line between rows (decorative CT_TEXTURE)
    local function MakeSep(offsetY)
        local sep = WINDOW_MANAGER:CreateControl(nil, w, CT_TEXTURE)
        sep:SetAnchor(TOPLEFT,  w, TOPLEFT,  PAD_LEFT, offsetY)
        sep:SetAnchor(TOPRIGHT, w, TOPRIGHT, -PAD_LEFT, offsetY)
        sep:SetHeight(1)
        sep:SetTexture("EsoUI/Art/miscellaneous/colorized_gradient_alpha.dds")
        sep:SetColor(0.3, 0.5, 0.8, 0.4)
    end
    MakeSep(row2Y - 2)
    MakeSep(row3Y - 2)

    w:SetScale(FV.SV.hudScale)
    w:SetAlpha(FV.SV.hudAlpha)

    self.controls_created = true
end

-- ============================================================
-- SPELL-RESIST REAGENT BUFF INDICATOR
--
-- Row 2 ("FEELS LIKE") is exactly what the spell-resist reagent buff
-- (FV:ApplySpellResistReagent in Frostfall.lua) shifts, so the indicator
-- lives on that row's own label rather than as a separate badge/icon —
-- no new control or art asset needed, and it reads naturally as "this
-- number is currently being steadied." FV.State.spellResistEndTime is
-- this session's game-time expiry (see Frostfall.lua for how it's kept in
-- sync with the persisted FV.SV.spellResistEndTimestamp across a relog);
-- nil/absent means the buff isn't active, which is the only thing this
-- indicator needs to know.
-- ============================================================
local PLAYER_TEMP_LABEL_BASE  = "FEELS LIKE"
local PLAYER_TEMP_LABEL_BUFFED_COLOR = { r = 0.85, g = 0.65, b = 1.0 }  -- soft violet, distinct from the plain label color below
local PLAYER_TEMP_LABEL_BASE_COLOR   = { r = 0.7,  g = 0.85, b = 1.0 }  -- matches MakeRow's default label color

local function UpdateSpellResistIndicator(lbl, state)
    if not state.spellResistEndTime then
        lbl:SetText(PLAYER_TEMP_LABEL_BASE)
        lbl:SetColor(PLAYER_TEMP_LABEL_BASE_COLOR.r, PLAYER_TEMP_LABEL_BASE_COLOR.g, PLAYER_TEMP_LABEL_BASE_COLOR.b, 0.8)
        return
    end

    local remainingSeconds = state.spellResistEndTime - (GetGameTimeMilliseconds() / 1000)
    local remainingMinutes = math.max(0, math.ceil(remainingSeconds / 60))
    -- Kept short (vs. e.g. "(STEADIED, 12m)") since this label has no fixed
    -- width/wrap and sits inside a 220px-wide HUD — the color shift is the
    -- primary "buff active" signal, this is just the bonus detail.
    lbl:SetText(string.format("%s (%dm)", PLAYER_TEMP_LABEL_BASE, remainingMinutes))
    lbl:SetColor(PLAYER_TEMP_LABEL_BUFFED_COLOR.r, PLAYER_TEMP_LABEL_BUFFED_COLOR.g, PLAYER_TEMP_LABEL_BUFFED_COLOR.b, 1.0)
end

-- ============================================================
-- UPDATE
-- ============================================================

function HUD:Update(playerTemp, state)
    if not self.controls_created then return end
    if not FV.SV.showHUD then
        self.container:SetHidden(true)
        return
    end
    self.container:SetHidden(false)

    -- Row 1: zone (ambient) temperature
    self.zoneTempVal:SetText(FV.FormatAmbientTemp())
    self.zoneTempVal:SetColor(0.7, 0.85, 1.0, 1.0)

    -- Row 2: player felt temperature, coloured by comfort level
    local col = GetTempColor(playerTemp)
    self.playerTempVal:SetText(FV.FormatTemp(playerTemp))
    self.playerTempVal:SetColor(col.r, col.g, col.b, 1.0)
    UpdateSpellResistIndicator(self.playerTempLbl, state)

    -- Row 3: insulation value and source
    self.insulationVal:SetText(
        string.format("%d  (%s)", math.floor(state.insulation), state.insulationSource)
    )
    -- Colour: green when well-insulated, grey when naked
    local ins = state.insulation / 100
    self.insulationVal:SetColor(0.4 + ins * 0.5, 0.6 + ins * 0.3, 0.4, 1.0)
end

-- ============================================================
-- INITIALIZE
-- ============================================================

function HUD:Initialize()
    self:CreateControls()
    self.container:SetHidden(not FV.SV.showHUD)
end
