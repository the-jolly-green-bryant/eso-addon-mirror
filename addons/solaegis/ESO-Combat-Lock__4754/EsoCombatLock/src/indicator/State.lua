-- EsoCombatLock - indicator shared state and helpers

local ECL = EsoCombatLock
ECL.Indicator = ECL.Indicator or {}
local Indicator = ECL.Indicator
Indicator.State = Indicator.State or {}
local State = Indicator.State

State.FRAME_NAME = "EsoCombatLockIndicator"
State.LOCK_TEXTURE = "/esoui/art/miscellaneous/locked_up.dds"
State.FALLBACK_TEXTURE = "/esoui/art/icons/ability_undaunted_001.dds"
-- Shown for empty park targets so the HUD preview is still visible.
State.EMPTY_PARK_TEXTURE = "EsoUI/Art/Quickslots/quickslot_emptySlot.dds"
State.EVENT_NAMESPACE = ECL.NAME .. "_Indicator"
State.RECONCILE_INTERVAL_MS = 500
State.RECONCILE_UPDATE_NAME = State.EVENT_NAMESPACE .. "_Reconcile"
State.DRAW_LAYER_NORMAL = DL_OVERLAY
State.DRAW_LAYER_REPOSITION = DL_CONTROLS
State.DRAW_TIER_NORMAL = DT_MEDIUM
State.DRAW_TIER_REPOSITION = DT_HIGH

State.frame = nil
State.backdrop = nil
State.iconTexture = nil
State.lockTexture = nil
State.parkPreviewTexture = nil
State.previewLabel = nil
State.playerInCombat = false
State.repositionMode = false
State.savedIndicatorAlwaysVisible = nil
State.forceCombatHighlight = false
State.uiModeForReposition = false
-- Collectible id captured when the guard arms (companion or nil for assistant-only).
State.armedCollectibleId = nil

--- Gap between main indicator and combat Q park-preview icon (pixels).
State.PARK_PREVIEW_GAP = 6
--- Park preview size as a fraction of indicatorSize.
State.PARK_PREVIEW_SCALE = 0.75
--- Draw level above the halo (which never sets one, so defaults to 0) so the park
--- preview is not washed out by the additive ring at the same layer and tier.
State.PARK_PREVIEW_DRAW_LEVEL = 1

function State.db()
    return ECL.db
end

function State.retireControl(control)
    if not control then
        return
    end
    control:SetHidden(true)
    control:ClearAnchors()
end

--- Returns a control named `name` guaranteed to be parented to `parent`.
---
--- ESO has no DestroyControl, so a named control created by an earlier build of this
--- addon outlives it and keeps whatever parent it was first given. That parent is
--- load-bearing, not cosmetic: a non-top-level control parented to GuiRoot is never
--- drawn, so a stray has to be adopted rather than worked around. Reparent it if we
--- can; otherwise retire the orphan and fall back to an unnamed replacement, because
--- the name itself stays taken for the rest of the session.
function State.AdoptOrCreateControl(name, parent, controlType)
    local existing = name and WINDOW_MANAGER:GetControlByName(name) or nil
    if not existing then
        -- Create under the looked-up name so the next call adopts this control
        -- instead of orphaning it.
        return WINDOW_MANAGER:CreateControl(name, parent, controlType)
    end
    if existing:GetParent() == parent then
        return existing
    end
    if existing.SetParent then
        existing:SetParent(parent)
        if existing:GetParent() == parent then
            return existing
        end
    end
    State.retireControl(existing)
    return WINDOW_MANAGER:CreateControl(nil, parent, controlType)
end

local textureProbe = nil

--- Returns whether the file exists; GetTextureFileDimensions reports 0x0 for a path
--- ESO could not load, while a control set to a missing path still reports correct
--- size and position. The probe is measurement-only and never shown, which is the
--- one legitimate use for a GuiRoot-parented texture.
function State.MeasureTexture(path)
    if not textureProbe then
        textureProbe = WINDOW_MANAGER:CreateControl(nil, GuiRoot, CT_TEXTURE)
        textureProbe:SetHidden(true)
        textureProbe:SetMouseEnabled(false)
    end
    textureProbe:SetTexture(path)
    local width, height = textureProbe:GetTextureFileDimensions()
    width = width or 0
    height = height or 0
    return width > 0 and height > 0, width, height
end

function State.indicatorSize()
    if not State.db() then
        return ECL.defaults.indicatorSize or 64
    end
    return State.db().indicatorSize or ECL.defaults.indicatorSize or 64
end

function State.isGuardArmed()
    return ECL.Guard and ECL.Guard.IsArmed and ECL.Guard.IsArmed()
end

function State.isInCombat()
    return State.playerInCombat
end

function State.hasActiveCompanion()
    return HasActiveCompanion and HasActiveCompanion()
end
