local Addon = NMGuildHall
local UI = Addon.UI

local function SafeCall(fn, ...)
    if type(fn) ~= "function" then
        return false
    end
    return pcall(fn, ...)
end

local function NormalizeSceneStateArgs(oldState, newState)
    if newState == nil then
        return nil, oldState
    end
    return oldState, newState
end

-- Transitional local UI primitives modeled after LibMisfit.
-- Future top-level modal/overlay controls should go through these helpers
-- instead of creating ad hoc fullscreen input layers.
-- Follow-up migration targets: ChatIcon should move to these movable helpers,
-- and QueueWidget should be normalized onto the same pattern later.

function UI:_CreateOverlay(opts)
    opts = opts or {}

    local controlPrefix = tostring(opts.controlPrefix or "")
    if controlPrefix == "" then
        return nil, nil
    end

    local overlay = WINDOW_MANAGER:CreateTopLevelWindow(controlPrefix .. "_Overlay")
    overlay:SetAnchorFill()
    overlay:SetDrawTier(opts.drawTier or DT_HIGH)
    overlay:SetHidden(true)
    overlay:SetMouseEnabled(true)
    overlay:SetKeyboardEnabled(true)
    overlay:SetClampedToScreen(true)

    local overlayBg = WINDOW_MANAGER:CreateControl(controlPrefix .. "_OverlayBG", overlay, CT_BACKDROP)
    overlayBg:SetAnchorFill()
    overlayBg:SetCenterColor(0, 0, 0, tonumber(opts.backdropAlpha) or 0.85)
    overlayBg:SetEdgeColor(0, 0, 0, 0)

    local function dismiss()
        SafeCall(opts.onDismiss)
    end

    overlay:SetHandler("OnKeyDown", function(_, key, ctrl, alt, shift)
        local handled = false
        local ok, result = SafeCall(opts.onKeyDown, key, ctrl, alt, shift)
        if ok and result == true then
            handled = true
        end

        if not handled and opts.dismissOnEscape ~= false and key == KEY_ESCAPE then
            dismiss()
        end
    end)

    overlay:SetHandler("OnMouseDown", function(_, mouseButton)
        local handled = false
        local ok, result = SafeCall(opts.onMouseDown, mouseButton)
        if ok and result == true then
            handled = true
        end

        if not handled and opts.dismissOnRightClick ~= false and mouseButton == MOUSE_BUTTON_INDEX_RIGHT then
            dismiss()
        end
    end)

    return overlay, overlayBg
end

function UI:_DetachOverlayScene(overlay)
    if not overlay or not overlay._nmghSceneAttachment then
        return false
    end

    local attachment = overlay._nmghSceneAttachment
    if attachment.scene and attachment.stateCallback and attachment.scene.UnregisterCallback then
        attachment.scene:UnregisterCallback("StateChange", attachment.stateCallback)
    end

    if attachment.scene and attachment.fragment then
        if attachment.attachMode == "temporary" and attachment.scene.RemoveTemporaryFragment then
            attachment.scene:RemoveTemporaryFragment(attachment.fragment)
        elseif attachment.scene.RemoveFragment then
            attachment.scene:RemoveFragment(attachment.fragment)
        end
    end

    overlay._nmghSceneAttachment = nil
    return true
end

function UI:_AttachOverlayScene(overlay, sceneOrName, opts)
    if not overlay then
        return nil, nil, nil
    end

    opts = opts or {}
    local scene = nil
    if type(sceneOrName) == "table" and type(sceneOrName.AddFragment) == "function" then
        scene = sceneOrName
    elseif type(sceneOrName) == "string" and sceneOrName ~= "" and SCENE_MANAGER then
        scene = SCENE_MANAGER:GetScene(sceneOrName)
        if not scene and opts.createIfMissing ~= false and ZO_Scene then
            scene = ZO_Scene:New(sceneOrName, SCENE_MANAGER)
        end
    end

    if not scene then
        return nil, nil, nil
    end

    local current = overlay._nmghSceneAttachment
    if current and current.scene == scene and opts.replace ~= true then
        return current.scene, current.fragment, current
    end

    if current then
        self:_DetachOverlayScene(overlay)
    end

    local fragment = opts.fragment
    if not fragment and ZO_SimpleSceneFragment then
        fragment = ZO_SimpleSceneFragment:New(overlay)
    end
    if not fragment then
        return scene, nil, nil
    end

    local attachMode = opts.attachMode == "temporary" and "temporary" or "fragment"
    if attachMode == "temporary" and scene.AddTemporaryFragment then
        scene:AddTemporaryFragment(fragment)
    else
        scene:AddFragment(fragment)
    end

    local attachment = {
        overlay = overlay,
        scene = scene,
        fragment = fragment,
        sceneName = type(sceneOrName) == "string" and sceneOrName or nil,
        attachMode = attachMode,
    }

    local stateCallback = function(oldState, newState)
        oldState, newState = NormalizeSceneStateArgs(oldState, newState)

        if newState == SCENE_SHOWN and opts.takeFocusOnShown ~= false and overlay.TakeFocus then
            overlay:TakeFocus()
        end

        if newState == SCENE_HIDDEN and opts.clearFocusOnHidden == true and overlay.LoseFocus then
            overlay:LoseFocus()
        end

        SafeCall(opts.onStateChange, scene, oldState, newState, attachment)
    end

    if scene.RegisterCallback then
        scene:RegisterCallback("StateChange", stateCallback)
        attachment.stateCallback = stateCallback
    end

    overlay._nmghSceneAttachment = attachment
    return scene, fragment, attachment
end

function UI:_GetSceneState(sceneName)
    if not SCENE_MANAGER or not SCENE_MANAGER.GetScene then
        return nil
    end

    local scene = SCENE_MANAGER:GetScene(sceneName)
    if not scene or not scene.GetState then
        return nil
    end

    local ok, state = pcall(scene.GetState, scene)
    if ok then
        return state
    end
    return nil
end

function UI:_ApplySavedAnchor(window, db, xKey, yKey, defaultAnchorFn, opts)
    if not window then
        return
    end

    opts = opts or {}
    local hasSaved = false
    if type(opts.hasSavedFn) == "function" then
        local ok, result = pcall(opts.hasSavedFn, db, xKey, yKey)
        hasSaved = ok and result == true
    else
        hasSaved = db and db[xKey] ~= nil and db[yKey] ~= nil
    end

    if hasSaved then
        local x = db and db[xKey] or 0
        local y = db and db[yKey] or 0

        if opts.clampToScreen ~= false and type(x) == "number" and type(y) == "number"
            and window.GetDimensions and GuiRoot and GuiRoot.GetDimensions then
            local width, height = window:GetDimensions()
            local screenWidth, screenHeight = GuiRoot:GetDimensions()
            x = math.max(0, math.min(screenWidth - width, x))
            y = math.max(0, math.min(screenHeight - height, y))
        end

        window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
        return
    end

    if type(defaultAnchorFn) == "function" then
        defaultAnchorFn(window)
    else
        window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end
end

function UI:_AttachPersistedMoveStop(window, db, xKey, yKey, afterSaveFn)
    if not (window and window.SetHandler) then
        return
    end

    window:SetHandler("OnMoveStop", function(control)
        if db then
            local x, y = control:GetLeft(), control:GetTop()
            db[xKey] = x
            db[yKey] = y
            control:ClearAnchors()
            control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
        end

        SafeCall(afterSaveFn, control, db)
    end)
end

function UI:_AttachClickOrDrag(window, mouseControl, opts)
    if not (window and mouseControl and mouseControl.SetHandler) then
        return
    end

    opts = opts or {}
    local dragThreshold = tonumber(opts.dragThreshold) or 4
    local mouseDownX = nil
    local mouseDownY = nil

    mouseControl:SetMouseEnabled(true)
    mouseControl:SetHandler("OnMouseDown", function(_, button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT then
            return
        end

        if type(opts.canDrag) == "function" then
            local ok, allowed = pcall(opts.canDrag)
            if not ok or allowed ~= true then
                return
            end
        end

        SafeCall(opts.beforeStartDrag, window)
        mouseDownX, mouseDownY = GetUIMousePosition()
        window:StartMoving()
    end)

    mouseControl:SetHandler("OnMouseUp", function(_, button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT or not mouseDownX then
            return
        end

        local mx, my = GetUIMousePosition()
        local isClick = math.abs(mx - mouseDownX) < dragThreshold and math.abs(my - mouseDownY) < dragThreshold
        mouseDownX, mouseDownY = nil, nil

        if window.StopMovingOrResizing then
            pcall(window.StopMovingOrResizing, window)
        end

        SafeCall(opts.afterStopDrag, window, isClick)

        if isClick then
            SafeCall(opts.onClick)
        end
    end)
end
