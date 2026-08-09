-- EsoCombatLock - indicator HUD frame creation and layout

local ECL = EsoCombatLock
ECL.Indicator = ECL.Indicator or {}
local Indicator = ECL.Indicator
Indicator.Frame = Indicator.Frame or {}
local Frame = Indicator.Frame
local State = Indicator.State

--- Park preview shares the indicator's layer and the halo's tier, and sits one draw
--- level above the halo so the additive ring cannot wash it out. Unlike the previous
--- DL_CONTROLS pinning, this does not depend on the control already being visible,
--- which ApplyDrawLayer cannot rely on (it runs during Create, while still hidden).
function Frame.ApplyParkPreviewDrawOrder()
    if not State.parkPreviewTexture then
        return
    end
    local layer = State.repositionMode and State.DRAW_LAYER_REPOSITION or State.DRAW_LAYER_NORMAL
    State.parkPreviewTexture:SetDrawLayer(layer)
    State.parkPreviewTexture:SetDrawTier(DT_HIGH)
    State.parkPreviewTexture:SetDrawLevel(State.PARK_PREVIEW_DRAW_LEVEL)
end

function Frame.ApplyDrawLayer()
    if not State.frame then
        return
    end
    local layer = State.repositionMode and State.DRAW_LAYER_REPOSITION or State.DRAW_LAYER_NORMAL
    local tier = State.repositionMode and State.DRAW_TIER_REPOSITION or State.DRAW_TIER_NORMAL
    State.frame:SetDrawLayer(layer)
    State.frame:SetDrawTier(tier)
    Indicator.Halo.ApplyDrawLayer(layer)
    if State.backdrop then
        State.backdrop:SetDrawLayer(layer)
        State.backdrop:SetDrawTier(tier)
    end
    if State.iconTexture then
        State.iconTexture:SetDrawLayer(layer)
        State.iconTexture:SetDrawTier(tier)
    end
    Frame.ApplyParkPreviewDrawOrder()
    if State.lockTexture then
        State.lockTexture:SetDrawLayer(layer)
        State.lockTexture:SetDrawTier(tier)
    end
    if State.previewLabel then
        State.previewLabel:SetDrawLayer(layer)
        State.previewLabel:SetDrawTier(tier)
    end
end

--- Whether the park preview fits to the right of the frame without leaving the screen.
--- Layout is unreliable while the frame is hidden, so an unresolved edge defaults to the
--- right-hand side; ApplySize re-runs from every Icon.Refresh once the frame is shown.
local function parkPreviewFitsRight(previewSize)
    local right = State.frame:GetRight()
    local screenWidth = GuiRoot:GetDimensions()
    if not right or right <= 0 or not screenWidth or screenWidth <= 0 then
        return true
    end
    return right + State.PARK_PREVIEW_GAP + previewSize <= screenWidth
end

function Frame.ApplySize()
    if not State.frame or not State.db() then
        return
    end
    local size = State.db().indicatorSize or ECL.defaults.indicatorSize or 64
    local previewSize = zo_max(16, zo_floor(size * State.PARK_PREVIEW_SCALE))
    -- The frame stays square around the companion face. The park preview is a child of
    -- the frame that deliberately overhangs it; ESO does not clip children to parent
    -- bounds unless SetAutoRectClipChildren(true), which Create sets to false.
    State.frame:SetDimensions(size, size)

    if State.iconTexture then
        State.iconTexture:ClearAnchors()
        State.iconTexture:SetAnchor(TOPLEFT, State.frame, TOPLEFT, 0, 0)
        State.iconTexture:SetDimensions(size, size)
    end
    if State.backdrop then
        State.backdrop:ClearAnchors()
        State.backdrop:SetAnchor(TOPLEFT, State.frame, TOPLEFT, 0, 0)
        State.backdrop:SetDimensions(size, size)
    end
    if State.lockTexture then
        local lockSize = zo_max(16, zo_floor(size / 3))
        State.lockTexture:ClearAnchors()
        State.lockTexture:SetAnchor(BOTTOMRIGHT, State.iconTexture or State.frame, BOTTOMRIGHT, -2, -2)
        State.lockTexture:SetDimensions(lockSize, lockSize)
    end
    if State.parkPreviewTexture then
        local anchorTarget = State.iconTexture or State.frame
        State.parkPreviewTexture:ClearAnchors()
        -- SetClampedToScreen clamps the frame, not the overhang, so an indicator dragged
        -- flush against the right edge would push the preview off-screen. Flip it to the
        -- left of the face when there is no room on the right.
        if parkPreviewFitsRight(previewSize) then
            State.parkPreviewTexture:SetAnchor(LEFT, anchorTarget, RIGHT, State.PARK_PREVIEW_GAP, 0)
        else
            State.parkPreviewTexture:SetAnchor(RIGHT, anchorTarget, LEFT, -State.PARK_PREVIEW_GAP, 0)
        end
        State.parkPreviewTexture:SetDimensions(previewSize, previewSize)
    end
    if State.previewLabel then
        State.previewLabel:ClearAnchors()
        State.previewLabel:SetAnchor(BOTTOM, State.iconTexture or State.frame, TOP, 0, -4)
    end
    Indicator.Halo.RefreshGeometry()
end

function Frame.SavePosition()
    if not State.frame or not State.db() then
        return
    end
    local left = State.frame:GetLeft()
    local top = State.frame:GetTop()
    local cx, cy = GuiRoot:GetCenter()
    State.db().indicatorX = left - cx
    State.db().indicatorY = top - cy
end

function Frame.RestorePosition()
    if not State.frame or not State.db() then
        return
    end
    local x = State.db().indicatorX or 0
    local y = State.db().indicatorY or -200
    State.frame:ClearAnchors()
    State.frame:SetAnchor(TOPLEFT, GuiRoot, CENTER, x, y)
end

function Frame.IsOnScreen()
    if not State.frame then
        return true
    end
    local left, top, right, bottom =
        State.frame:GetLeft(), State.frame:GetTop(), State.frame:GetRight(), State.frame:GetBottom()
    if not left or not top or not right or not bottom then
        return false
    end
    local gw, gh = GuiRoot:GetDimensions()
    return right > 0 and bottom > 0 and left < gw and top < gh
end

function Frame.Create()
    State.frame = WINDOW_MANAGER:CreateTopLevelWindow(State.FRAME_NAME)
    State.frame:SetClampedToScreen(true)
    State.frame:SetHidden(true)
    if State.frame.SetAutoRectClipChildren then
        State.frame:SetAutoRectClipChildren(false)
    end

    State.backdrop = WINDOW_MANAGER:CreateControl(nil, State.frame, CT_BACKDROP)
    State.backdrop:SetCenterColor(0.1, 0.15, 0.2, 0.55)
    State.backdrop:SetEdgeTexture("/esoui/art/chatwindow/chat_bg_edge.dds", 256, 256, 32)

    State.iconTexture = WINDOW_MANAGER:CreateControl(nil, State.frame, CT_TEXTURE)
    State.iconTexture:SetMouseEnabled(false)

    -- Combat Q park target preview. This MUST be a child of the indicator top-level
    -- window: ESO does not draw a non-top-level control parented to GuiRoot, which is
    -- why earlier builds of this icon were never visible on screen. Overhanging the
    -- frame is fine (SetAutoRectClipChildren is false above); the halo already draws
    -- well outside these same bounds. AdoptOrCreateControl reparents the stray GuiRoot
    -- control left behind by those builds, since ESO has no DestroyControl.
    State.parkPreviewTexture = State.AdoptOrCreateControl("EsoCombatLockParkPreview", State.frame, CT_TEXTURE)
    State.parkPreviewTexture:SetMouseEnabled(false)
    State.parkPreviewTexture:SetHidden(true)
    -- An adopted control also carries stale color/alpha from the earlier build.
    State.parkPreviewTexture:SetColor(1, 1, 1, 1)
    Frame.ApplyParkPreviewDrawOrder()

    State.lockTexture = WINDOW_MANAGER:CreateControl(nil, State.frame, CT_TEXTURE)
    State.lockTexture:SetTexture(State.LOCK_TEXTURE)
    State.lockTexture:SetMouseEnabled(false)

    State.previewLabel = WINDOW_MANAGER:CreateControl(nil, State.frame, CT_LABEL)
    State.previewLabel:SetFont("$(MEDIUM_FONT)|$(KB_14)|soft-shadow-thin")
    State.previewLabel:SetColor(0.9, 0.9, 0.7, 1)
    State.previewLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    State.previewLabel:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
    State.previewLabel:SetText("Drag to position")
    State.previewLabel:SetMouseEnabled(false)

    Indicator.Halo.DestroyLegacyGuiRootGlows()
    Indicator.Halo.Ensure()

    Frame.ApplyDrawLayer()

    Indicator.Reposition.BindDragHandlers(State.frame)
    Indicator.Reposition.BindDragHandlers(State.backdrop)
    State.frame:SetHandler("OnMoveStop", function()
        Frame.SavePosition()
        ECL.Debug("Indicator position saved")
    end)

    Frame.ApplySize()
    Frame.RestorePosition()
    Indicator.Icon.Refresh()
    Indicator.Visibility.Refresh()
end

function Frame.Initialize()
    if State.frame then
        Indicator.Halo.DestroyLegacyGuiRootGlows()
        Indicator.Halo.Ensure()
        Frame.ApplySize()
        if not State.repositionMode then
            Frame.RestorePosition()
        end
        Frame.ApplyDrawLayer()
        Indicator.Visibility.Refresh()
        return
    end
    Frame.Create()
end
