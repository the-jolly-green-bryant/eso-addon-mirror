-- EsoCombatLock - indicator combat halo (additive pulse ring)

local ECL = EsoCombatLock
ECL.Indicator = ECL.Indicator or {}
local Indicator = ECL.Indicator
Indicator.Halo = Indicator.Halo or {}
local Halo = Indicator.Halo
local State = Indicator.State

--- A missing texture path renders nothing while the control still reports correct
--- size and position, so candidates are validated before use. Bundled art first;
--- one ESO fallback if the addon texture fails to load.
local COMBAT_HALO_TEXTURES = {
    "EsoCombatLock/textures/halo_ring.dds",
    "EsoUI/Art/Crafting/crafting_toolTip_glow_center.dds",
}
local COMBAT_HALO_STYLE_VERSION = 14
local COMBAT_HALO_OUTER_NAME = State.FRAME_NAME .. "HaloOuter"
local COMBAT_HALO_INNER_NAME = State.FRAME_NAME .. "HaloInner"
local COMBAT_HALO_PULSE_MS = 40
local COMBAT_HALO_PULSE_PERIOD_S = 0.9
-- Both halos blend additively, so their alphas stack; keep the combined peak well
-- under 1.0 or the ring saturates into a solid disc.
local COMBAT_HALO_PULSE_MIN = 0.26
local COMBAT_HALO_PULSE_MAX = 0.46
-- Apparent ring thickness comes from the gap between the two halo controls:
-- nearly coincident reads as a thin line, spread apart as a thick band. The
-- pulse drives diameter and thickness together so the ring swells and constricts.
local COMBAT_HALO_PULSE_SCALE_MIN = 1.12
local COMBAT_HALO_PULSE_SCALE_MAX = 1.30
local COMBAT_HALO_PULSE_SPREAD_MIN = 0.02
local COMBAT_HALO_PULSE_SPREAD_MAX = 0.18
local COMBAT_HALO_INNER_RATIO = 0.6
-- Max outer alpha so outer + inner (additive) stay under 1.0 at peak intensity.
local COMBAT_HALO_MAX_OUTER_ALPHA = 0.95 / (1 + COMBAT_HALO_INNER_RATIO)
local COMBAT_HALO_PULSE_UPDATE = State.EVENT_NAMESPACE .. "_CombatHaloPulse"
-- Legacy GuiRoot glow names from prior builds (ESO cannot DestroyControl; hide + clear).
local COMBAT_GLOW_OUTER_NAME = State.FRAME_NAME .. "GlowOuter"
local COMBAT_GLOW_INNER_NAME = State.FRAME_NAME .. "GlowInner"

local combatHighlightOuter = nil
local combatHighlightInner = nil
local combatHighlightPulsing = false
local combatHighlightStyleVersion = 0
local resolvedHaloTexture = nil
local haloTextureOverride = nil

--- Every halo control ever created, so strays can be retired. ESO has no
--- DestroyControl, so a control that stops being tracked keeps drawing forever.
local haloControlRegistry = {}

function Halo.GetOuter()
    return combatHighlightOuter
end

function Halo.GetInner()
    return combatHighlightInner
end

function Halo.IsPulsing()
    return combatHighlightPulsing
end

function Halo.GetTextureList()
    return COMBAT_HALO_TEXTURES
end

local function haloOuterRGB()
    local d = State.db()
    if not d then
        return 1.0, 0.88, 0.38
    end
    return d.haloColorR or 1.0, d.haloColorG or 0.88, d.haloColorB or 0.38
end

--- Inner ring is the outer color lerped ~33% toward white.
local function haloInnerRGB()
    local r, g, b = haloOuterRGB()
    return r + (1 - r) * 0.33, g + (1 - g) * 0.33, b + (1 - b) * 0.33
end

local function haloIntensityScale()
    local d = State.db()
    local percent = d and d.haloIntensity or 100
    if percent < 25 then
        percent = 25
    elseif percent > 150 then
        percent = 150
    end
    return percent / 100
end

--- Returns whether the file exists. Shared with the park preview, which needs the
--- same check for the same reason.
function Halo.MeasureTexture(path)
    return State.MeasureTexture(path)
end

function Halo.Texture()
    if haloTextureOverride then
        return haloTextureOverride
    end
    if resolvedHaloTexture then
        return resolvedHaloTexture
    end
    for _, path in ipairs(COMBAT_HALO_TEXTURES) do
        if Halo.MeasureTexture(path) then
            resolvedHaloTexture = path
            return path
        end
    end
    resolvedHaloTexture = COMBAT_HALO_TEXTURES[1]
    return resolvedHaloTexture
end

local function configureHaloTexture(control)
    control:SetTexture(Halo.Texture())
    control:SetBlendMode(TEX_BLEND_MODE_ADD)
    control:SetMouseEnabled(false)
end

local function trackHaloControl(control)
    if control then
        haloControlRegistry[control] = true
    end
    return control
end

--- Retires every halo control except the two currently in use. Without this a
--- leaked control keeps blending additively even when the tracked halos are hidden.
local function retireStrayHaloControls()
    for control in pairs(haloControlRegistry) do
        if control ~= combatHighlightOuter and control ~= combatHighlightInner then
            State.retireControl(control)
            haloControlRegistry[control] = nil
        end
    end
end

local function getOrCreateHaloControl(name)
    local existing = WINDOW_MANAGER:GetControlByName(name)
    local control = State.AdoptOrCreateControl(name, State.frame, CT_TEXTURE)
    if existing and control ~= existing then
        -- The orphan was retired in favour of an unnamed replacement; stop tracking it.
        haloControlRegistry[existing] = nil
    end
    configureHaloTexture(control)
    return trackHaloControl(control)
end

local function haloDimension(baseScale)
    return zo_max(24, zo_floor(State.indicatorSize() * baseScale))
end

local function applyHaloLayout(glow)
    if not glow or not State.frame then
        return
    end
    -- Center on the companion face itself, so the ring stays concentric with the icon
    -- rather than with anything else anchored off it (such as the park preview).
    local anchorTarget = State.iconTexture or State.frame
    glow:ClearAnchors()
    glow:SetAnchor(CENTER, anchorTarget, CENTER, 0, 0)
    glow:SetTexture(Halo.Texture())
    glow:SetBlendMode(TEX_BLEND_MODE_ADD)
    glow:SetDrawLayer(DL_OVERLAY)
    glow:SetDrawTier(DT_HIGH)
end

local function applyHaloPulseState(outerScale, innerScale, outerAlpha, innerAlpha)
    local or_, og, ob = haloOuterRGB()
    local ir, ig, ib = haloInnerRGB()
    if combatHighlightOuter then
        local dim = haloDimension(outerScale)
        combatHighlightOuter:SetDimensions(dim, dim)
        combatHighlightOuter:SetColor(or_, og, ob, outerAlpha)
    end
    if combatHighlightInner then
        local dim = haloDimension(innerScale)
        combatHighlightInner:SetDimensions(dim, dim)
        combatHighlightInner:SetColor(ir, ig, ib, innerAlpha)
    end
end

function Halo.RefreshGeometry()
    if combatHighlightOuter then
        applyHaloLayout(combatHighlightOuter)
    end
    if combatHighlightInner then
        applyHaloLayout(combatHighlightInner)
    end
end

local function stopCombatHighlightPulse()
    EVENT_MANAGER:UnregisterForUpdate(COMBAT_HALO_PULSE_UPDATE)
    combatHighlightPulsing = false
end

--- Hide orphaned GuiRoot glows from prior builds only (not live COMBAT_HALO_*).
function Halo.DestroyLegacyGuiRootGlows()
    local legacyNames = {
        COMBAT_GLOW_OUTER_NAME,
        COMBAT_GLOW_INNER_NAME,
    }
    for _, name in ipairs(legacyNames) do
        State.retireControl(WINDOW_MANAGER:GetControlByName(name))
    end
end

function Halo.Destroy()
    stopCombatHighlightPulse()
    combatHighlightOuter = nil
    combatHighlightInner = nil
    retireStrayHaloControls()
    Halo.DestroyLegacyGuiRootGlows()
end

function Halo.Ensure()
    if not State.frame then
        return
    end
    if combatHighlightStyleVersion ~= COMBAT_HALO_STYLE_VERSION then
        Halo.Destroy()
        combatHighlightStyleVersion = COMBAT_HALO_STYLE_VERSION
    end
    combatHighlightOuter = getOrCreateHaloControl(COMBAT_HALO_OUTER_NAME)
    combatHighlightInner = getOrCreateHaloControl(COMBAT_HALO_INNER_NAME)
    retireStrayHaloControls()
    Halo.RefreshGeometry()
end

local function combatHaloPulseWave()
    return (math.sin(GetGameTimeMilliseconds() / 1000 * math.pi * 2 / COMBAT_HALO_PULSE_PERIOD_S) + 1) / 2
end

function Halo.ApplyPulse(wave)
    local mid = COMBAT_HALO_PULSE_SCALE_MIN + wave * (COMBAT_HALO_PULSE_SCALE_MAX - COMBAT_HALO_PULSE_SCALE_MIN)
    local spread = COMBAT_HALO_PULSE_SPREAD_MIN + wave * (COMBAT_HALO_PULSE_SPREAD_MAX - COMBAT_HALO_PULSE_SPREAD_MIN)
    local intensity = haloIntensityScale()
    local outerAlpha = (COMBAT_HALO_PULSE_MIN + wave * (COMBAT_HALO_PULSE_MAX - COMBAT_HALO_PULSE_MIN)) * intensity
    if outerAlpha > COMBAT_HALO_MAX_OUTER_ALPHA then
        outerAlpha = COMBAT_HALO_MAX_OUTER_ALPHA
    end
    local innerAlpha = outerAlpha * COMBAT_HALO_INNER_RATIO
    applyHaloPulseState(mid + spread / 2, mid - spread / 2, outerAlpha, innerAlpha)
end

local function startCombatHighlightPulse()
    if not combatHighlightOuter and not combatHighlightInner then
        return
    end
    if combatHighlightPulsing then
        return
    end
    combatHighlightPulsing = true
    EVENT_MANAGER:RegisterForUpdate(COMBAT_HALO_PULSE_UPDATE, COMBAT_HALO_PULSE_MS, function()
        if
            not Indicator.Visibility.ShouldShowCombatHalo()
            or (combatHighlightOuter and combatHighlightOuter:IsHidden())
            or (combatHighlightInner and combatHighlightInner:IsHidden())
        then
            stopCombatHighlightPulse()
            return
        end
        Halo.ApplyPulse(combatHaloPulseWave())
    end)
end

function Halo.ApplyDrawLayer(layer)
    if combatHighlightOuter then
        combatHighlightOuter:SetDrawLayer(layer)
        combatHighlightOuter:SetDrawTier(DT_HIGH)
    end
    if combatHighlightInner then
        combatHighlightInner:SetDrawLayer(layer)
        combatHighlightInner:SetDrawTier(DT_HIGH)
    end
end

function Halo.SetVisible(visible)
    Halo.Ensure()
    if combatHighlightOuter then
        combatHighlightOuter:SetHidden(not visible)
    end
    if combatHighlightInner then
        combatHighlightInner:SetHidden(not visible)
    end
    if visible then
        Halo.RefreshGeometry()
        Halo.ApplyDrawLayer(State.DRAW_LAYER_NORMAL)
        Halo.ApplyPulse(combatHaloPulseWave())
        startCombatHighlightPulse()
    else
        local layer = State.repositionMode and State.DRAW_LAYER_REPOSITION or State.DRAW_LAYER_NORMAL
        Halo.ApplyDrawLayer(layer)
        stopCombatHighlightPulse()
    end
end

--- Swaps the halo art in place so candidates can be compared without a reload.
function Halo.SetTextureIndex(index)
    local path = COMBAT_HALO_TEXTURES[index]
    if not path then
        return nil
    end
    haloTextureOverride = path
    Halo.RefreshGeometry()
    if Indicator.Visibility.ShouldShowCombatHalo() then
        Halo.ApplyPulse(combatHaloPulseWave())
    end
    return path
end

function Halo.ClearTextureOverride()
    if not haloTextureOverride then
        return false
    end
    haloTextureOverride = nil
    resolvedHaloTexture = nil
    Halo.RefreshGeometry()
    if Indicator.Visibility.ShouldShowCombatHalo() then
        Halo.ApplyPulse(combatHaloPulseWave())
    end
    return true
end
