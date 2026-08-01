-- Frostfall: Overlay Effects
-- Screen vignette overlay for cold and heat conditions.
--
-- Design:
--   • One window for cold (blue), one for heat (red).
--   • Alpha is a pure linear ramp driven by playerTemp (in °C):
--       Cold: alpha 0 at FV.TEMP.COLD (10°C), MAX_ALPHA at FV.TEMP.FREEZE_DANGER (-10°C)
--       Hot:  alpha 0 at FV.TEMP.HOT  (35°C), MAX_ALPHA at FV.TEMP.HEAT_DANGER   (41°C)
--   • Both overlays are fully hidden between COLD (10°C) and HOT (35°C) — the
--     same thresholds that gate the emote system.
--   • No layered windows, no warning text, no pulse.
--
-- Window pattern (from RolePlayNeeds reference):
--   CreateTopLevelWindow → SetAnchorFill() → SetMouseEnabled(false)
--   → child CT_TEXTURE with SetAnchorFill() → alpha on the WINDOW.

Frostfall_Overlay = Frostfall_Overlay or {}
local OVL = Frostfall_Overlay

local FV = Frostfall

-- Maximum alpha at the temperature extremes.
-- Kept below 1.0 so the world remains visible.
local MAX_ALPHA = 0.75

-- ============================================================
-- TOP-LEVEL WINDOWS  (file scope — created before Initialize)
-- ============================================================

local coldWindow = WINDOW_MANAGER:CreateTopLevelWindow("FrostfallColdWindow")
local hotWindow  = WINDOW_MANAGER:CreateTopLevelWindow("FrostfallHotWindow")

-- ============================================================
-- ALPHA CALCULATION
-- ============================================================

-- Cold ramp: alpha 0 at COLD threshold (10°C), MAX_ALPHA at FREEZE_DANGER (-10°C).
-- playerTemp below FREEZE_DANGER stays clamped at MAX_ALPHA.
local function ColdAlpha(playerTemp)
    local T = FV.TEMP
    if playerTemp >= T.COLD then return 0 end
    if playerTemp <= T.FREEZE_DANGER then return MAX_ALPHA end
    -- Linear interpolation between COLD (alpha 0) and FREEZE_DANGER (alpha MAX_ALPHA)
    local frac = (T.COLD - playerTemp) / (T.COLD - T.FREEZE_DANGER)
    return frac * MAX_ALPHA
end

-- Hot ramp: alpha 0 at HOT threshold (35°C), MAX_ALPHA at HEAT_DANGER (41°C).
-- playerTemp above HEAT_DANGER stays clamped at MAX_ALPHA.
local function HotAlpha(playerTemp)
    local T = FV.TEMP
    if playerTemp <= T.HOT then return 0 end
    if playerTemp >= T.HEAT_DANGER then return MAX_ALPHA end
    -- Linear interpolation between HOT (alpha 0) and HEAT_DANGER (alpha MAX_ALPHA)
    local frac = (playerTemp - T.HOT) / (T.HEAT_DANGER - T.HOT)
    return frac * MAX_ALPHA
end

-- ============================================================
-- CONTROL CREATION
-- ============================================================

function OVL:CreateControls()
    -- Cold (blue) overlay
    coldWindow:SetAnchorFill()
    coldWindow:SetMouseEnabled(false)
    coldWindow:SetAlpha(0)
    coldWindow:SetHidden(true)
    local coldTex = WINDOW_MANAGER:CreateControl(nil, coldWindow, CT_TEXTURE)
    coldTex:SetAnchorFill()
    coldTex:SetTexture("Frostfall/ui/COLD_OVERLAY.dds")
    self.coldWindow = coldWindow

    -- Hot (red) overlay
    hotWindow:SetAnchorFill()
    hotWindow:SetMouseEnabled(false)
    hotWindow:SetAlpha(0)
    hotWindow:SetHidden(true)
    local hotTex = WINDOW_MANAGER:CreateControl(nil, hotWindow, CT_TEXTURE)
    hotTex:SetAnchorFill()
    hotTex:SetTexture("Frostfall/ui/HOT_OVERLAY.dds")
    self.hotWindow = hotWindow

    self.controls_created = true
end

-- ============================================================
-- UPDATE
-- ============================================================

function OVL:Update(playerTemp, state)
    if not self.controls_created then return end

    if not FV.SV.enableOverlay then
        self.coldWindow:SetHidden(true)
        self.hotWindow:SetHidden(true)
        return
    end

    -- Evaluate both alphas first, then apply — avoids preemptive cross-hiding
    -- that could mask the hot overlay if the cold check ran first and set it hidden.
    -- Cold and hot are mutually exclusive by temperature (ColdAlpha returns 0 at ≥10°C,
    -- HotAlpha returns 0 at ≤35°C) so at most one will ever be > 0 at a time.
    local ca = ColdAlpha(playerTemp)
    local ha = HotAlpha(playerTemp)

    -- ── Cold overlay ─────────────────────────────────────────────────────────
    if ca > 0 then
        self.coldWindow:SetAlpha(ca)
        self.coldWindow:SetHidden(false)
    else
        self.coldWindow:SetHidden(true)
    end

    -- ── Hot overlay ──────────────────────────────────────────────────────────
    if ha > 0 then
        self.hotWindow:SetAlpha(ha)
        self.hotWindow:SetHidden(false)
    else
        self.hotWindow:SetHidden(true)
    end

    -- Between COLD (10°C) and HOT (35°C) both functions return 0,
    -- so both windows end up hidden — the dead zone.
end

-- ============================================================
-- INITIALIZE
-- ============================================================

function OVL:Initialize()
    self:CreateControls()
end
