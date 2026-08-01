-- RealisticNeedsAndDiseases_Overlay.lua
-- Renders up to 5 simultaneous screen-tint overlays, one per active disease,
-- each with its own color and an opacity that scales with severity tier.

RealisticNeeds = RealisticNeeds or {}
local RN = RealisticNeeds

local Overlay = {}
RN.Overlay = Overlay

-- UNVERIFIED PATH — confirm this resolves to a plain white/solid texture
-- in-game before relying on it, or replace with your own known-good texture.
Overlay.FALLBACK_OVERLAY_TEXTURE = "EsoUI/Art/miscellaneous/blank.dds"

-- Mild bumped from 0.20 to 0.25 per spec ("at least 20% opaque and visible
-- on screen") — 0.20 technically already met "at least 20%" exactly at the
-- boundary, but 0.25 gives clear headroom above that floor rather than
-- sitting exactly on it.
Overlay.MAX_ALPHA_BY_SEVERITY = {
    [RN.SEVERITY_MILD]     = 0.25,
    [RN.SEVERITY_MODERATE] = 0.45,
    [RN.SEVERITY_SEVERE]   = 0.75,
}

local windows = {}

local function CreateOverlayWindow(diseaseId)
    local def = RN.Diseases[diseaseId]
    local window = WINDOW_MANAGER:CreateTopLevelWindow("RealisticNeeds_Overlay_" .. diseaseId)
    window:SetAnchorFill()
    window:SetMouseEnabled(false)
    window:SetAlpha(0)
    window:SetHidden(true)
    window:SetDrawLayer(DL_BACKGROUND)

    local texture = WINDOW_MANAGER:CreateControl(nil, window, CT_TEXTURE)
    texture:SetAnchorFill()
    texture:SetTexture(Overlay.FALLBACK_OVERLAY_TEXTURE)
    if def and def.overlayColor then
        texture:SetColor(def.overlayColor[1], def.overlayColor[2], def.overlayColor[3], 1)
    end

    windows[diseaseId] = { window = window, texture = texture, currentTier = nil }
    return windows[diseaseId]
end

function Overlay.Initialize()
    for diseaseId in pairs(RN.Diseases) do
        CreateOverlayWindow(diseaseId)
    end
end

function Overlay.RefreshDisease(diseaseId, severity)
    local entry = windows[diseaseId]
    if not entry then return end
    local def = RN.Diseases[diseaseId]
    if not def then return end

    -- One texture per disease now (not one per severity tier) — severity is
    -- communicated purely by how opaque/transparent the overlay is
    -- (MAX_ALPHA_BY_SEVERITY above), not by swapping textures.
    local customTexture = def.overlayTexture
    if customTexture then
        entry.texture:SetTexture(customTexture)
        entry.texture:SetColor(1, 1, 1, 1)
    else
        entry.texture:SetTexture(Overlay.FALLBACK_OVERLAY_TEXTURE)
        if def.overlayColor then
            entry.texture:SetColor(def.overlayColor[1], def.overlayColor[2], def.overlayColor[3], 1)
        end
    end

    entry.currentTier = severity
    local alpha = Overlay.MAX_ALPHA_BY_SEVERITY[severity] or 0
    entry.window:SetAlpha(alpha)
    entry.window:SetHidden(false)
end

function Overlay.ClearDisease(diseaseId)
    local entry = windows[diseaseId]
    if not entry then return end
    entry.currentTier = nil
    entry.window:SetAlpha(0)
    entry.window:SetHidden(true)
end

function Overlay.RefreshAll(sv)
    for diseaseId, state in pairs(sv.diseaseState) do
        Overlay.RefreshDisease(diseaseId, state.severity)
    end
end
