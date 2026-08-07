-- EsoCombatLock - on-screen lock indicator (companion icon + lock overlay)

local ECL = EsoCombatLock
ECL.Indicator = ECL.Indicator or {}
local Indicator = ECL.Indicator

local FRAME_NAME = "EsoCombatLockIndicator"
local LOCK_TEXTURE = "/esoui/art/miscellaneous/locked_up.dds"
local FALLBACK_TEXTURE = "/esoui/art/icons/ability_undaunted_001.dds"
local EVENT_NAMESPACE = ECL.NAME .. "_Indicator"
--- A missing texture path renders nothing while the control still reports correct
--- size and position, so candidates are validated before use. Bundled art first;
--- one ESO fallback if the addon texture fails to load.
local COMBAT_HALO_TEXTURES = {
    "EsoCombatLock/textures/halo_ring.dds",
    "EsoUI/Art/Crafting/crafting_toolTip_glow_center.dds",
}
local COMBAT_HALO_STYLE_VERSION = 14
local COMBAT_HALO_OUTER_NAME = FRAME_NAME .. "HaloOuter"
local COMBAT_HALO_INNER_NAME = FRAME_NAME .. "HaloInner"
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
local COMBAT_HALO_PULSE_UPDATE = EVENT_NAMESPACE .. "_CombatHaloPulse"
-- Legacy GuiRoot glow names from prior builds (ESO cannot DestroyControl; hide + clear).
local COMBAT_GLOW_OUTER_NAME = FRAME_NAME .. "GlowOuter"
local COMBAT_GLOW_INNER_NAME = FRAME_NAME .. "GlowInner"
local RECONCILE_INTERVAL_MS = 500
local RECONCILE_UPDATE_NAME = EVENT_NAMESPACE .. "_Reconcile"
-- HUD overlays are suppressed in full UI mode; bump layer/tier while repositioning.
local DRAW_LAYER_NORMAL = DL_OVERLAY
local DRAW_LAYER_REPOSITION = DL_CONTROLS
local DRAW_TIER_NORMAL = DT_MEDIUM
local DRAW_TIER_REPOSITION = DT_HIGH

local frame = nil
local combatHighlightOuter = nil
local combatHighlightInner = nil
local backdrop = nil
local iconTexture = nil
local lockTexture = nil
local previewLabel = nil
local playerInCombat = false
local repositionMode = false
local savedIndicatorAlwaysVisible = nil
local uiModeForReposition = false
local combatHighlightPulsing = false
local combatHighlightStyleVersion = 0
local forceCombatHighlight = false
local haloTextureProbe = nil
local resolvedHaloTexture = nil
local haloTextureOverride = nil

local function db()
    return ECL.db
end

--- HUD frames cannot be clicked while the reticle is active, so reposition mode
--- shows a mouse cursor. Use SetGameCameraUIMode (not SCENE_MANAGER UI mode),
--- which keeps HUD overlays visible.
local function setRepositionCursor(enabled)
    if not SetGameCameraUIMode then
        return
    end
    if enabled then
        local alreadyActive = IsGameCameraUIModeActive and IsGameCameraUIModeActive()
        if not alreadyActive then
            uiModeForReposition = true
            SetGameCameraUIMode(true)
        end
    elseif uiModeForReposition then
        uiModeForReposition = false
        SetGameCameraUIMode(false)
    end
end

local function isGuardArmed()
    return ECL.Guard and ECL.Guard.IsArmed and ECL.Guard.IsArmed()
end

local function isInCombat()
    return playerInCombat
end

local function hasActiveCompanion()
    return HasActiveCompanion and HasActiveCompanion()
end

local function shouldShowLockOverlay()
    if repositionMode then
        return false
    end
    return isInCombat()
end

local function shouldShowCombatHalo()
    if repositionMode then
        return false
    end
    if forceCombatHighlight then
        return true
    end
    local d = db()
    if d and d.haloEnabled == false then
        return false
    end
    return isInCombat()
end

local function haloOuterRGB()
    local d = db()
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
    local d = db()
    local percent = d and d.haloIntensity or 100
    if percent < 25 then
        percent = 25
    elseif percent > 150 then
        percent = 150
    end
    return percent / 100
end

local function indicatorSize()
    if not db() then
        return ECL.defaults.indicatorSize or 64
    end
    return db().indicatorSize or ECL.defaults.indicatorSize or 64
end

--- ESO has no DestroyControl; hide and clear anchors to retire a control.
local function retireControl(control)
    if not control then
        return
    end
    control:SetHidden(true)
    control:ClearAnchors()
end

--- Returns whether the file exists; GetTextureFileDimensions reports 0x0 for a
--- path ESO could not load.
local function measureTexture(path)
    if not haloTextureProbe then
        haloTextureProbe = WINDOW_MANAGER:CreateControl(nil, GuiRoot, CT_TEXTURE)
        haloTextureProbe:SetHidden(true)
        haloTextureProbe:SetMouseEnabled(false)
    end
    haloTextureProbe:SetTexture(path)
    local width, height = haloTextureProbe:GetTextureFileDimensions()
    width = width or 0
    height = height or 0
    return width > 0 and height > 0, width, height
end

local function haloTexture()
    if haloTextureOverride then
        return haloTextureOverride
    end
    if resolvedHaloTexture then
        return resolvedHaloTexture
    end
    for _, path in ipairs(COMBAT_HALO_TEXTURES) do
        if measureTexture(path) then
            resolvedHaloTexture = path
            return path
        end
    end
    resolvedHaloTexture = COMBAT_HALO_TEXTURES[1]
    return resolvedHaloTexture
end

local function configureHaloTexture(control)
    control:SetTexture(haloTexture())
    control:SetBlendMode(TEX_BLEND_MODE_ADD)
    control:SetMouseEnabled(false)
end

--- Every halo control ever created, so strays can be retired. ESO has no
--- DestroyControl, so a control that stops being tracked keeps drawing forever.
local haloControlRegistry = {}

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
            retireControl(control)
            haloControlRegistry[control] = nil
        end
    end
end

local function getOrCreateHaloControl(name)
    local control = WINDOW_MANAGER:GetControlByName(name)
    if control then
        local parent = control:GetParent()
        if parent == frame then
            configureHaloTexture(control)
            return trackHaloControl(control)
        end
        if control.SetParent then
            control:SetParent(frame)
            if control:GetParent() == frame then
                configureHaloTexture(control)
                return trackHaloControl(control)
            end
        end
        -- Wrong parent and cannot reparent: retire the orphan. The name stays
        -- taken, so the replacement has to be unnamed.
        retireControl(control)
        haloControlRegistry[control] = nil
        control = WINDOW_MANAGER:CreateControl(nil, frame, CT_TEXTURE)
        configureHaloTexture(control)
        return trackHaloControl(control)
    end
    -- Create under the looked-up name so the next call reuses this control
    -- instead of orphaning it.
    control = WINDOW_MANAGER:CreateControl(name, frame, CT_TEXTURE)
    configureHaloTexture(control)
    return trackHaloControl(control)
end

local function haloDimension(baseScale)
    return zo_max(24, zo_floor(indicatorSize() * baseScale))
end

local function applyHaloLayout(glow)
    if not glow or not frame then
        return
    end
    glow:ClearAnchors()
    glow:SetAnchor(CENTER, frame, CENTER, 0, 0)
    glow:SetTexture(haloTexture())
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

local function refreshHaloGeometry()
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
local function destroyLegacyGuiRootGlows()
    local legacyNames = {
        COMBAT_GLOW_OUTER_NAME,
        COMBAT_GLOW_INNER_NAME,
    }
    for _, name in ipairs(legacyNames) do
        retireControl(WINDOW_MANAGER:GetControlByName(name))
    end
end

local function destroyCombatHighlight()
    stopCombatHighlightPulse()
    combatHighlightOuter = nil
    combatHighlightInner = nil
    retireStrayHaloControls()
    destroyLegacyGuiRootGlows()
end

local function ensureCombatHighlight()
    if not frame then
        return
    end
    if combatHighlightStyleVersion ~= COMBAT_HALO_STYLE_VERSION then
        destroyCombatHighlight()
        combatHighlightStyleVersion = COMBAT_HALO_STYLE_VERSION
    end
    combatHighlightOuter = getOrCreateHaloControl(COMBAT_HALO_OUTER_NAME)
    combatHighlightInner = getOrCreateHaloControl(COMBAT_HALO_INNER_NAME)
    retireStrayHaloControls()
    refreshHaloGeometry()
end

local function combatHaloPulseWave()
    return (math.sin(GetGameTimeMilliseconds() / 1000 * math.pi * 2 / COMBAT_HALO_PULSE_PERIOD_S) + 1) / 2
end

local function applyCombatHaloPulse(wave)
    local mid = COMBAT_HALO_PULSE_SCALE_MIN
        + wave * (COMBAT_HALO_PULSE_SCALE_MAX - COMBAT_HALO_PULSE_SCALE_MIN)
    local spread = COMBAT_HALO_PULSE_SPREAD_MIN
        + wave * (COMBAT_HALO_PULSE_SPREAD_MAX - COMBAT_HALO_PULSE_SPREAD_MIN)
    local intensity = haloIntensityScale()
    local outerAlpha = (COMBAT_HALO_PULSE_MIN
        + wave * (COMBAT_HALO_PULSE_MAX - COMBAT_HALO_PULSE_MIN)) * intensity
    if outerAlpha > COMBAT_HALO_MAX_OUTER_ALPHA then
        outerAlpha = COMBAT_HALO_MAX_OUTER_ALPHA
    end
    local innerAlpha = outerAlpha * COMBAT_HALO_INNER_RATIO
    applyHaloPulseState(
        mid + spread / 2,
        mid - spread / 2,
        outerAlpha,
        innerAlpha
    )
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
        if not shouldShowCombatHalo()
            or (combatHighlightOuter and combatHighlightOuter:IsHidden())
            or (combatHighlightInner and combatHighlightInner:IsHidden()) then
            stopCombatHighlightPulse()
            return
        end
        local wave = combatHaloPulseWave()
        applyCombatHaloPulse(wave)
    end)
end

local function applyHighlightDrawLayer(layer)
    if combatHighlightOuter then
        combatHighlightOuter:SetDrawLayer(layer)
        combatHighlightOuter:SetDrawTier(DT_HIGH)
    end
    if combatHighlightInner then
        combatHighlightInner:SetDrawLayer(layer)
        combatHighlightInner:SetDrawTier(DT_HIGH)
    end
end

local function setCombatHighlightVisible(visible)
    ensureCombatHighlight()
    if combatHighlightOuter then
        combatHighlightOuter:SetHidden(not visible)
    end
    if combatHighlightInner then
        combatHighlightInner:SetHidden(not visible)
    end
    if visible then
        refreshHaloGeometry()
        applyHighlightDrawLayer(DRAW_LAYER_NORMAL)
        applyCombatHaloPulse(combatHaloPulseWave())
        startCombatHighlightPulse()
    else
        local layer = repositionMode and DRAW_LAYER_REPOSITION or DRAW_LAYER_NORMAL
        applyHighlightDrawLayer(layer)
        stopCombatHighlightPulse()
    end
end

local function isEffectivelyLocked()
    if repositionMode then
        return false
    end
    return ECL.IsIndicatorLocked()
end

local function shouldShow()
    if repositionMode then
        return true
    end
    if forceCombatHighlight then
        return true
    end
    if ECL.IsIndicatorAlwaysVisible() then
        return true
    end
    return isInCombat() and hasActiveCompanion()
end

local function applyDrawLayer()
    if not frame then
        return
    end
    local layer = repositionMode and DRAW_LAYER_REPOSITION or DRAW_LAYER_NORMAL
    local tier = repositionMode and DRAW_TIER_REPOSITION or DRAW_TIER_NORMAL
    frame:SetDrawLayer(layer)
    frame:SetDrawTier(tier)
    applyHighlightDrawLayer(layer)
    if backdrop then
        backdrop:SetDrawLayer(layer)
        backdrop:SetDrawTier(tier)
    end
    if iconTexture then
        iconTexture:SetDrawLayer(layer)
        iconTexture:SetDrawTier(tier)
    end
    if lockTexture then
        lockTexture:SetDrawLayer(layer)
        lockTexture:SetDrawTier(tier)
    end
    if previewLabel then
        previewLabel:SetDrawLayer(layer)
        previewLabel:SetDrawTier(tier)
    end
end

local function onRepositionMouseDown(_, button)
    if repositionMode and button == MOUSE_BUTTON_INDEX_LEFT and frame then
        frame:StartMoving()
    end
end

local function onRepositionMouseUp()
    if repositionMode and frame then
        frame:StopMovingOrResizing()
    end
end

local function bindRepositionDragHandlers(control)
    if not control then
        return
    end
    control:SetHandler("OnMouseDown", onRepositionMouseDown)
    control:SetHandler("OnMouseUp", onRepositionMouseUp)
end

local function applyRepositionMouseTargets()
    if not frame then
        return
    end
    if repositionMode then
        frame:SetMovable(true)
        frame:SetMouseEnabled(true)
        if backdrop then
            backdrop:SetMouseEnabled(true)
        end
        if iconTexture then
            iconTexture:SetMouseEnabled(false)
        end
        if lockTexture then
            lockTexture:SetMouseEnabled(false)
        end
        if previewLabel then
            previewLabel:SetMouseEnabled(false)
        end
    else
        frame:SetMouseEnabled(false)
        if backdrop then
            backdrop:SetMouseEnabled(false)
        end
    end
end

local function forceShowForReposition()
    if not frame or not repositionMode then
        return
    end
    frame:SetHidden(false)
    applyRepositionMouseTargets()
    if backdrop then
        backdrop:SetHidden(false)
    end
    if previewLabel then
        previewLabel:SetHidden(false)
    end
    if iconTexture then
        iconTexture:SetHidden(false)
    end
    if lockTexture then
        lockTexture:SetHidden(true)
    end
    setCombatHighlightVisible(false)
end

local function enterRepositionMode()
    repositionMode = true
    savedIndicatorAlwaysVisible = db().indicatorAlwaysVisible
    db().indicatorAlwaysVisible = true
    applyDrawLayer()
end

local function exitRepositionMode()
    if not repositionMode then
        return
    end
    repositionMode = false
    db().indicatorAlwaysVisible = savedIndicatorAlwaysVisible
    savedIndicatorAlwaysVisible = nil
    setRepositionCursor(false)
    applyDrawLayer()
end

local function applySize()
    if not frame or not db() then
        return
    end
    local size = db().indicatorSize or ECL.defaults.indicatorSize or 64
    frame:SetDimensions(size, size)
    if lockTexture then
        local lockSize = zo_max(16, zo_floor(size / 3))
        lockTexture:SetDimensions(lockSize, lockSize)
    end
    refreshHaloGeometry()
end

local function savePosition()
    if not frame or not db() then
        return
    end
    local left = frame:GetLeft()
    local top = frame:GetTop()
    local cx, cy = GuiRoot:GetCenter()
    db().indicatorX = left - cx
    db().indicatorY = top - cy
end

local function restorePosition()
    if not frame or not db() then
        return
    end
    local x = db().indicatorX or 0
    local y = db().indicatorY or -200
    frame:ClearAnchors()
    frame:SetAnchor(TOPLEFT, GuiRoot, CENTER, x, y)
end

local function isFrameOnScreen()
    if not frame then
        return true
    end
    local left, top, right, bottom = frame:GetLeft(), frame:GetTop(), frame:GetRight(), frame:GetBottom()
    if not left or not top or not right or not bottom then
        return false
    end
    local gw, gh = GuiRoot:GetDimensions()
    return right > 0 and bottom > 0 and left < gw and top < gh
end

local function ensureVisibleForReposition(wasHidden)
    if not frame or not db() then
        return
    end
    -- Anchor/layout math is unreliable while the frame is hidden.
    frame:SetHidden(false)
    if wasHidden then
        frame:ClearAnchors()
        frame:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    else
        restorePosition()
        if not isFrameOnScreen() then
            frame:ClearAnchors()
            frame:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
            ECL.Chat("Indicator was off-screen — centered on screen for reposition")
        end
    end
end

local function setIndicatorTexture(texture)
    if not iconTexture then
        return
    end
    iconTexture:SetTexture(texture or FALLBACK_TEXTURE)
end

local function resolveIndicatorCollectibleId()
    if ECL.Slots and ECL.Slots.GetActiveCompanionCollectibleId then
        local companionId = ECL.Slots.GetActiveCompanionCollectibleId()
        if companionId then
            return companionId
        end
    end
    if ECL.Slots and ECL.Slots.GetActiveRiskyCollectibleId then
        local activeRiskyId = ECL.Slots.GetActiveRiskyCollectibleId()
        if activeRiskyId then
            return activeRiskyId
        end
    end
    if isGuardArmed() and ECL.Guard.GetState then
        return ECL.Guard.GetState().companionCollectibleId
    end
    return nil
end

local function resolveCollectibleTexture(collectibleId)
    if collectibleId and collectibleId > 0 and GetCollectibleIcon then
        local icon = GetCollectibleIcon(collectibleId)
        if icon and icon ~= "" then
            return icon
        end
    end
    return nil
end

local function shouldUseQuickslotIcon()
    return isGuardArmed() and isInCombat()
end

local function resolveIndicatorTexture()
    if shouldUseQuickslotIcon() and ECL.Slots then
        local Slots = ECL.Slots
        local current = Slots.GetCurrent()
        if not Slots.IsRisky(current) then
            local texture = Slots.GetSlotTexture(current)
            if texture then
                return texture
            end
        end
        local activeRiskyId = Slots.GetActiveRiskyCollectibleId()
        if activeRiskyId then
            local activeTexture = resolveCollectibleTexture(activeRiskyId)
            if activeTexture then
                return activeTexture
            end
        end
        local texture = Slots.GetSlotTexture(current)
        if texture then
            return texture
        end
    end
    return resolveCollectibleTexture(resolveIndicatorCollectibleId()) or FALLBACK_TEXTURE
end

local function refreshIndicatorIcon()
    setIndicatorTexture(resolveIndicatorTexture())
end

local function refreshVisibility()
    if not frame then
        return
    end
    if repositionMode then
        forceShowForReposition()
        ECL.Debug(string.format(
            "Indicator refresh: reposition forced show hiddenAfter=%s",
            tostring(frame:IsHidden())
        ))
        return
    end

    local show = shouldShow()
    local locked = isEffectivelyLocked()

    frame:SetHidden(not show)
    frame:SetMovable(show and not locked)
    frame:SetMouseEnabled(show and not locked)
    if backdrop then
        backdrop:SetMouseEnabled(false)
    end

    if backdrop then
        backdrop:SetHidden(not show or locked)
    end
    if previewLabel then
        previewLabel:SetHidden(true)
    end
    if iconTexture then
        iconTexture:SetHidden(not show)
    end
    if lockTexture then
        local showLock = shouldShowLockOverlay()
        lockTexture:SetHidden(not showLock)
        if showLock then
            lockTexture:SetDrawLayer(DL_CONTROLS)
            lockTexture:SetDrawTier(DT_HIGH)
        else
            local layer = repositionMode and DRAW_LAYER_REPOSITION or DRAW_LAYER_NORMAL
            local tier = repositionMode and DRAW_TIER_REPOSITION or DRAW_TIER_NORMAL
            lockTexture:SetDrawLayer(layer)
            lockTexture:SetDrawTier(tier)
        end
    end
    setCombatHighlightVisible(show and shouldShowCombatHalo())

    ECL.Debug(string.format(
        "Indicator refresh: show=%s armed=%s inCombat=%s always=%s reposition=%s hiddenAfter=%s",
        tostring(show),
        tostring(isGuardArmed()),
        tostring(playerInCombat),
        tostring(ECL.IsIndicatorAlwaysVisible()),
        tostring(repositionMode),
        tostring(frame:IsHidden())
    ))
end

local function scheduleRepositionLayoutRefresh()
    zo_callLater(function()
        if not repositionMode or not frame then
            return
        end
        ensureVisibleForReposition(frame:IsHidden())
        forceShowForReposition()
        refreshVisibility()
    end, 0)
end

local function reconcileVisibility()
    if not frame then
        return
    end
    -- Do not poll IsUnitInCombat for combat-end hide: it stays true during ESO's
    -- post-combat regen window. Guard.disarm (POST_COMBAT_DISARM_DELAY_MS) calls
    -- SetPlayerInCombat(false); combat enter is immediate from Guard.onCombatState.
    local show = shouldShow()
    if frame:IsHidden() ~= (not show) then
        refreshVisibility()
    elseif not ECL.IsIndicatorAlwaysVisible() and not repositionMode and not playerInCombat and not frame:IsHidden() then
        refreshVisibility()
    else
        local wantGlow = show and shouldShowCombatHalo()
        local haveGlow = combatHighlightOuter and not combatHighlightOuter:IsHidden()
        if wantGlow ~= haveGlow then
            refreshVisibility()
        end
    end
end

local function applyLockState()
    refreshVisibility()
end

function Indicator.SetPlayerInCombat(inCombat)
    playerInCombat = inCombat == true
    if playerInCombat then
        exitRepositionMode()
    end
    refreshVisibility()
    refreshIndicatorIcon()
end

function Indicator.Initialize()
    if frame then
        destroyLegacyGuiRootGlows()
        ensureCombatHighlight()
        applySize()
        if not repositionMode then
            restorePosition()
        end
        applyDrawLayer()
        applyLockState()
        return
    end

    frame = WINDOW_MANAGER:CreateTopLevelWindow(FRAME_NAME)
    frame:SetClampedToScreen(true)
    frame:SetHidden(true)
    if frame.SetAutoRectClipChildren then
        frame:SetAutoRectClipChildren(false)
    end

    backdrop = WINDOW_MANAGER:CreateControl(nil, frame, CT_BACKDROP)
    backdrop:SetAnchorFill()
    backdrop:SetCenterColor(0.1, 0.15, 0.2, 0.55)
    backdrop:SetEdgeTexture("/esoui/art/chatwindow/chat_bg_edge.dds", 256, 256, 32)

    iconTexture = WINDOW_MANAGER:CreateControl(nil, frame, CT_TEXTURE)
    iconTexture:SetAnchor(CENTER)
    iconTexture:SetDimensions(1, 1)
    iconTexture:SetAnchorFill()
    iconTexture:SetMouseEnabled(false)

    lockTexture = WINDOW_MANAGER:CreateControl(nil, frame, CT_TEXTURE)
    lockTexture:SetTexture(LOCK_TEXTURE)
    lockTexture:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, -2, -2)
    lockTexture:SetMouseEnabled(false)

    previewLabel = WINDOW_MANAGER:CreateControl(nil, frame, CT_LABEL)
    previewLabel:SetFont("$(MEDIUM_FONT)|$(KB_14)|soft-shadow-thin")
    previewLabel:SetColor(0.9, 0.9, 0.7, 1)
    previewLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    previewLabel:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
    previewLabel:SetAnchor(BOTTOM, frame, TOP, 0, -4)
    previewLabel:SetText("Drag to position")
    previewLabel:SetMouseEnabled(false)

    destroyLegacyGuiRootGlows()
    ensureCombatHighlight()

    applyDrawLayer()

    bindRepositionDragHandlers(frame)
    bindRepositionDragHandlers(backdrop)
    frame:SetHandler("OnMoveStop", function()
        savePosition()
        ECL.Debug("Indicator position saved")
    end)

    applySize()
    restorePosition()
    refreshIndicatorIcon()
    applyLockState()
end

local function onCompanionStateChanged()
    refreshIndicatorIcon()
    refreshVisibility()
end

local function onActiveQuickslotChanged()
    refreshIndicatorIcon()
end

local function onHotbarSlotStateUpdated(_, _actionSlotIndex, hotbarCategory)
    if hotbarCategory ~= HOTBAR_CATEGORY_QUICKSLOT_WHEEL then
        return
    end
    refreshIndicatorIcon()
end

local function onCollectibleUpdated()
    refreshIndicatorIcon()
end

local function onCollectibleUseResult()
    refreshIndicatorIcon()
end

function Indicator.Register()
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ACTIVE_COMPANION_STATE_CHANGED, onCompanionStateChanged)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ACTIVE_QUICKSLOT_CHANGED, onActiveQuickslotChanged)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_HOTBAR_SLOT_STATE_UPDATED, onHotbarSlotStateUpdated)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_COLLECTIBLE_UPDATED, onCollectibleUpdated)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_COLLECTIBLE_USE_RESULT, onCollectibleUseResult)
    EVENT_MANAGER:UnregisterForUpdate(RECONCILE_UPDATE_NAME)
    EVENT_MANAGER:RegisterForUpdate(RECONCILE_UPDATE_NAME, RECONCILE_INTERVAL_MS, reconcileVisibility)
    refreshIndicatorIcon()
end

function Indicator.OnArmed(_collectibleId)
    refreshIndicatorIcon()
    refreshVisibility()
end

function Indicator.OnDisarmed()
    refreshVisibility()
    refreshIndicatorIcon()
end

function Indicator.GetDebugState()
    return {
        hidden = frame and frame:IsHidden(),
        show = shouldShow(),
        playerInCombat = playerInCombat,
        apiInCombat = IsUnitInCombat and IsUnitInCombat("player"),
        armed = isGuardArmed(),
        hasActiveCompanion = hasActiveCompanion(),
        repositionMode = repositionMode,
        savedAlwaysVisible = savedIndicatorAlwaysVisible,
        combatHighlightVisible = combatHighlightOuter and not combatHighlightOuter:IsHidden(),
        combatHighlightPulsing = combatHighlightPulsing,
        forceCombatHighlight = forceCombatHighlight,
    }
end

--- Forces the combat highlight on outside of combat so a missing effect can be
--- diagnosed as a draw problem rather than a combat-state problem.
function Indicator.ToggleForcedCombatHighlight()
    forceCombatHighlight = not forceCombatHighlight
    refreshVisibility()
    return forceCombatHighlight
end

local function describeControl(label, control)
    if not control then
        return label .. "=nil"
    end
    return string.format(
        "%s{hidden=%s w=%s h=%s left=%s top=%s tier=%s layer=%s}",
        label,
        tostring(control:IsHidden()),
        tostring(zo_floor(control:GetWidth() or 0)),
        tostring(zo_floor(control:GetHeight() or 0)),
        tostring(zo_floor(control:GetLeft() or 0)),
        tostring(zo_floor(control:GetTop() or 0)),
        tostring(control:GetDrawTier()),
        tostring(control:GetDrawLayer())
    )
end

function Indicator.DescribeHighlightControls()
    return {
        describeControl("frame", frame),
        describeControl("icon", iconTexture),
        describeControl("outer", combatHighlightOuter),
        describeControl("inner", combatHighlightInner),
        "texture=" .. tostring(haloTexture()),
    }
end

function Indicator.DescribeHaloTextures()
    local active = haloTexture()
    local lines = {}
    for index, path in ipairs(COMBAT_HALO_TEXTURES) do
        local ok, width, height = measureTexture(path)
        table.insert(lines, string.format(
            "%d%s %s (%s)",
            index,
            path == active and "*" or ".",
            path,
            ok and string.format("%dx%d", width, height) or "MISSING"
        ))
    end
    return lines
end

--- Swaps the halo art in place so candidates can be compared without a reload.
function Indicator.SetHaloTextureIndex(index)
    local path = COMBAT_HALO_TEXTURES[index]
    if not path then
        return nil
    end
    haloTextureOverride = path
    refreshHaloGeometry()
    if shouldShowCombatHalo() then
        applyCombatHaloPulse(combatHaloPulseWave())
    end
    return path
end

function Indicator.ClearHaloTextureOverride()
    if not haloTextureOverride then
        return false
    end
    haloTextureOverride = nil
    resolvedHaloTexture = nil
    refreshHaloGeometry()
    if shouldShowCombatHalo() then
        applyCombatHaloPulse(combatHaloPulseWave())
    end
    return true
end

function Indicator.Refresh()
    applyLockState()
end

function Indicator.ResetPosition()
    if not db() then
        return
    end
    db().indicatorX = ECL.defaults.indicatorX
    db().indicatorY = ECL.defaults.indicatorY
    restorePosition()
    ECL.Chat("Indicator location reset to default")
    refreshVisibility()
end

function Indicator.TogglePositionLock()
    if not db() then
        return
    end
    if repositionMode then
        exitRepositionMode()
    else
        local wasHidden = frame == nil or frame:IsHidden()
        enterRepositionMode()
        Indicator.Initialize()
        refreshIndicatorIcon()
        ensureVisibleForReposition(wasHidden)
        forceShowForReposition()
        setRepositionCursor(true)
        scheduleRepositionLayoutRefresh()
    end
    refreshVisibility()

    if repositionMode then
        ECL.Chat(string.format(
            "Indicator reposition mode — drag it, then /ecl move again (hidden=%s x=%d y=%d). /reloadui if you still see 'position unlocked'.",
            tostring(frame and frame:IsHidden()),
            zo_floor(db().indicatorX or 0),
            zo_floor(db().indicatorY or 0)
        ))
    else
        ECL.Chat("Indicator reposition mode ended")
    end
end
