-- EsoCombatLock - indicator visibility reconciliation

local ECL = EsoCombatLock
ECL.Indicator = ECL.Indicator or {}
local Indicator = ECL.Indicator
Indicator.Visibility = Indicator.Visibility or {}
local Visibility = Indicator.Visibility
local State = Indicator.State

function Visibility.ShouldShowLockOverlay()
    if State.repositionMode then
        return false
    end
    return State.isInCombat()
end

function Visibility.ShouldShowCombatHalo()
    if State.repositionMode then
        return false
    end
    if State.forceCombatHighlight then
        return true
    end
    local d = State.db()
    if d and d.haloEnabled == false then
        return false
    end
    return State.isInCombat()
end

local function isEffectivelyLocked()
    if State.repositionMode then
        return false
    end
    return ECL.IsIndicatorLocked()
end

function Visibility.ShouldShow()
    if State.repositionMode then
        return true
    end
    if State.forceCombatHighlight then
        return true
    end
    if ECL.IsIndicatorAlwaysVisible() then
        return true
    end
    return State.isInCombat() and State.hasActiveCompanion()
end

function Visibility.Refresh()
    if not State.frame then
        return
    end
    if State.repositionMode then
        Indicator.Reposition.ForceShow()
        ECL.Debug(
            string.format("Indicator refresh: reposition forced show hiddenAfter=%s", tostring(State.frame:IsHidden()))
        )
        return
    end

    local show = Visibility.ShouldShow()
    local locked = isEffectivelyLocked()

    State.frame:SetHidden(not show)
    State.frame:SetMovable(show and not locked)
    State.frame:SetMouseEnabled(show and not locked)
    if State.backdrop then
        State.backdrop:SetMouseEnabled(false)
    end

    if State.backdrop then
        State.backdrop:SetHidden(not show or locked)
    end
    if State.previewLabel then
        State.previewLabel:SetHidden(true)
    end
    if State.iconTexture then
        State.iconTexture:SetHidden(not show)
    end
    if State.parkPreviewTexture then
        if not show then
            State.parkPreviewTexture:SetHidden(true)
        end
        -- When the indicator is shown, Icon.Refresh applies texture + unhide.
    end
    if State.lockTexture then
        local showLock = Visibility.ShouldShowLockOverlay()
        State.lockTexture:SetHidden(not showLock)
        if showLock then
            State.lockTexture:SetDrawLayer(DL_CONTROLS)
            State.lockTexture:SetDrawTier(DT_HIGH)
        else
            local layer = State.repositionMode and State.DRAW_LAYER_REPOSITION or State.DRAW_LAYER_NORMAL
            local tier = State.repositionMode and State.DRAW_TIER_REPOSITION or State.DRAW_TIER_NORMAL
            State.lockTexture:SetDrawLayer(layer)
            State.lockTexture:SetDrawTier(tier)
        end
    end
    Indicator.Halo.SetVisible(show and Visibility.ShouldShowCombatHalo())
    if show then
        Indicator.Icon.Refresh()
    end

    ECL.Debug(
        string.format(
            "Indicator refresh: show=%s armed=%s inCombat=%s always=%s reposition=%s hiddenAfter=%s",
            tostring(show),
            tostring(State.isGuardArmed()),
            tostring(State.playerInCombat),
            tostring(ECL.IsIndicatorAlwaysVisible()),
            tostring(State.repositionMode),
            tostring(State.frame:IsHidden())
        )
    )
end

local function reconcileVisibility()
    if not State.frame then
        return
    end
    -- Do not poll IsUnitInCombat for combat-end hide: it stays true during ESO's
    -- post-combat regen window. Guard.disarm (POST_COMBAT_DISARM_DELAY_MS) calls
    -- SetPlayerInCombat(false); combat enter is immediate from Guard.onCombatState.
    local show = Visibility.ShouldShow()
    if State.frame:IsHidden() ~= not show then
        Visibility.Refresh()
    elseif
        not ECL.IsIndicatorAlwaysVisible()
        and not State.repositionMode
        and not State.playerInCombat
        and not State.frame:IsHidden()
    then
        Visibility.Refresh()
    else
        local wantGlow = show and Visibility.ShouldShowCombatHalo()
        local outer = Indicator.Halo.GetOuter()
        local haveGlow = outer and not outer:IsHidden()
        if wantGlow ~= haveGlow then
            Visibility.Refresh()
        end
    end
end

local function onCompanionStateChanged()
    Indicator.Icon.Refresh()
    Visibility.Refresh()
end

local function onActiveQuickslotChanged()
    Indicator.Icon.Refresh()
end

local function onHotbarSlotStateUpdated(_, _actionSlotIndex, hotbarCategory)
    if hotbarCategory ~= HOTBAR_CATEGORY_QUICKSLOT_WHEEL then
        return
    end
    Indicator.Icon.Refresh()
end

local function onCollectibleUpdated()
    Indicator.Icon.Refresh()
end

local function onCollectibleUseResult()
    Indicator.Icon.Refresh()
end

function Visibility.Register()
    local ns = State.EVENT_NAMESPACE
    EVENT_MANAGER:RegisterForEvent(ns, EVENT_ACTIVE_COMPANION_STATE_CHANGED, onCompanionStateChanged)
    EVENT_MANAGER:RegisterForEvent(ns, EVENT_ACTIVE_QUICKSLOT_CHANGED, onActiveQuickslotChanged)
    EVENT_MANAGER:RegisterForEvent(ns, EVENT_HOTBAR_SLOT_STATE_UPDATED, onHotbarSlotStateUpdated)
    EVENT_MANAGER:RegisterForEvent(ns, EVENT_COLLECTIBLE_UPDATED, onCollectibleUpdated)
    EVENT_MANAGER:RegisterForEvent(ns, EVENT_COLLECTIBLE_USE_RESULT, onCollectibleUseResult)
    EVENT_MANAGER:UnregisterForUpdate(State.RECONCILE_UPDATE_NAME)
    EVENT_MANAGER:RegisterForUpdate(State.RECONCILE_UPDATE_NAME, State.RECONCILE_INTERVAL_MS, reconcileVisibility)
    Indicator.Icon.Refresh()
end
