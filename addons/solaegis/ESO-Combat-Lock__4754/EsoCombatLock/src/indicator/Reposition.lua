-- EsoCombatLock - indicator reposition mode

local ECL = EsoCombatLock
ECL.Indicator = ECL.Indicator or {}
local Indicator = ECL.Indicator
Indicator.Reposition = Indicator.Reposition or {}
local Reposition = Indicator.Reposition
local State = Indicator.State

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
            State.uiModeForReposition = true
            SetGameCameraUIMode(true)
        end
    elseif State.uiModeForReposition then
        State.uiModeForReposition = false
        SetGameCameraUIMode(false)
    end
end

local function onRepositionMouseDown(_, button)
    if State.repositionMode and button == MOUSE_BUTTON_INDEX_LEFT and State.frame then
        State.frame:StartMoving()
    end
end

local function onRepositionMouseUp()
    if State.repositionMode and State.frame then
        State.frame:StopMovingOrResizing()
    end
end

function Reposition.BindDragHandlers(control)
    if not control then
        return
    end
    control:SetHandler("OnMouseDown", onRepositionMouseDown)
    control:SetHandler("OnMouseUp", onRepositionMouseUp)
end

local function applyRepositionMouseTargets()
    if not State.frame then
        return
    end
    if State.repositionMode then
        State.frame:SetMovable(true)
        State.frame:SetMouseEnabled(true)
        if State.backdrop then
            State.backdrop:SetMouseEnabled(true)
        end
        if State.iconTexture then
            State.iconTexture:SetMouseEnabled(false)
        end
        if State.lockTexture then
            State.lockTexture:SetMouseEnabled(false)
        end
        if State.previewLabel then
            State.previewLabel:SetMouseEnabled(false)
        end
    else
        State.frame:SetMouseEnabled(false)
        if State.backdrop then
            State.backdrop:SetMouseEnabled(false)
        end
    end
end

function Reposition.ForceShow()
    if not State.frame or not State.repositionMode then
        return
    end
    State.frame:SetHidden(false)
    applyRepositionMouseTargets()
    if State.backdrop then
        State.backdrop:SetHidden(false)
    end
    if State.previewLabel then
        State.previewLabel:SetHidden(false)
    end
    if State.iconTexture then
        State.iconTexture:SetHidden(false)
    end
    if State.lockTexture then
        State.lockTexture:SetHidden(true)
    end
    Indicator.Halo.SetVisible(false)
    -- Visibility.Refresh returns early in reposition mode; refresh icons (including
    -- the park preview, which tracks indicator visibility) here instead.
    Indicator.Icon.Refresh()
end

function Reposition.Enter()
    State.repositionMode = true
    State.savedIndicatorAlwaysVisible = State.db().indicatorAlwaysVisible
    State.db().indicatorAlwaysVisible = true
    Indicator.Frame.ApplyDrawLayer()
end

function Reposition.Exit()
    if not State.repositionMode then
        return
    end
    State.repositionMode = false
    State.db().indicatorAlwaysVisible = State.savedIndicatorAlwaysVisible
    State.savedIndicatorAlwaysVisible = nil
    setRepositionCursor(false)
    Indicator.Frame.ApplyDrawLayer()
end

function Reposition.EnsureVisible(wasHidden)
    if not State.frame or not State.db() then
        return
    end
    -- Anchor/layout math is unreliable while the frame is hidden.
    State.frame:SetHidden(false)
    if wasHidden then
        State.frame:ClearAnchors()
        State.frame:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    else
        Indicator.Frame.RestorePosition()
        if not Indicator.Frame.IsOnScreen() then
            State.frame:ClearAnchors()
            State.frame:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
            ECL.Chat("Indicator was off-screen — centered on screen for reposition")
        end
    end
end

local function scheduleRepositionLayoutRefresh()
    zo_callLater(function()
        if not State.repositionMode or not State.frame then
            return
        end
        Reposition.EnsureVisible(State.frame:IsHidden())
        Reposition.ForceShow()
        Indicator.Visibility.Refresh()
    end, 0)
end

function Reposition.Toggle()
    if not State.db() then
        return
    end
    if State.repositionMode then
        Reposition.Exit()
    else
        local wasHidden = State.frame == nil or State.frame:IsHidden()
        Reposition.Enter()
        Indicator.Frame.Initialize()
        Indicator.Icon.Refresh()
        Reposition.EnsureVisible(wasHidden)
        Reposition.ForceShow()
        setRepositionCursor(true)
        scheduleRepositionLayoutRefresh()
    end
    Indicator.Visibility.Refresh()

    if State.repositionMode then
        ECL.Chat(
            string.format(
                "Indicator reposition mode — drag it, then /ecl move again (hidden=%s x=%d y=%d). /reloadui if you still see 'position unlocked'.",
                tostring(State.frame and State.frame:IsHidden()),
                zo_floor(State.db().indicatorX or 0),
                zo_floor(State.db().indicatorY or 0)
            )
        )
    else
        ECL.Chat("Indicator reposition mode ended")
    end
end
