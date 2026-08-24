-- Shared addon namespace.
Ultivite = Ultivite or {}

-- ZO_GetChatSystem is the current chat entry point. Retain the older globals for
-- compatibility with clients and chat replacements that still publish them.
function Ultivite.GetChatSystem()
    if type(ZO_GetChatSystem) == "function" then
        local ok, system = pcall(ZO_GetChatSystem)
        if ok and system then return system end
    end
    if KEYBOARD_CHAT_SYSTEM then return KEYBOARD_CHAT_SYSTEM end
    if CHAT_SYSTEM then return CHAT_SYSTEM end
    return nil
end

function Ultivite.GetChatTextEntry()
    local system = Ultivite.GetChatSystem()
    return system and system.textEntry or nil
end

-- Close ESO chat only for an explicit request to leave Ultivite editing and
-- return to gameplay. TextEntry:Close(keepText) is ESO's own public chat path,
-- so it fires the normal chat-input-end lifecycle and lets the scene manager
-- release UI mode. Ultivite never calls this during ordinary chat use, dragging
-- or native chat resizing. keepText=true preserves an unfinished draft.
function Ultivite.CloseChatTextEntryForGameplay()
    local system = Ultivite.GetChatSystem()
    local entry = system and system.textEntry or nil
    if not entry then return true end

    local function isOpen()
        if type(entry.IsOpen) ~= "function" then return nil end
        local ok, value = pcall(entry.IsOpen, entry)
        if not ok then return nil end
        return value == true
    end

    if isOpen() == false then return true end

    -- Prefer the TextEntry's own close path. If a chat replacement exposes only
    -- the parent chat-system close method, fall back to that. Both calls happen
    -- only for the explicit SAVE & LOCK / return-to-gameplay action.
    if type(entry.Close) == "function" then
        pcall(entry.Close, entry, true)
    end

    if isOpen() == true and system and type(system.CloseTextEntry) == "function" then
        pcall(system.CloseTextEntry, system)
    end

    local finalState = isOpen()
    return finalState ~= true
end

-- Return ESO's real primary keyboard chat container. Ultivite does not replace
-- the container or its native drag/resize handlers. These helpers are used only
-- by explicit user actions such as the Chat Width/Height sliders.
function Ultivite.GetPrimaryChatContainer()
    local system = Ultivite.GetChatSystem()
    if not system then return nil end
    if system.primaryContainer and system.primaryContainer.control then
        return system.primaryContainer
    end
    if type(system.containers) == "table" then
        local first = system.containers[1]
        if first and first.control then return first end
    end
    return nil
end

function Ultivite.GetChatDimensions()
    local container = Ultivite.GetPrimaryChatContainer()
    local control = container and container.control or nil
    if not control or type(control.GetDimensions) ~= "function" then return 445, 267 end
    local ok, width, height = pcall(control.GetDimensions, control)
    if not ok then return 445, 267 end
    return tonumber(width) or 445, tonumber(height) or 267
end

function Ultivite.SetChatDimensions(width, height)
    local container = Ultivite.GetPrimaryChatContainer()
    local control = container and container.control or nil
    if not control or type(control.SetDimensions) ~= "function" then return false end

    -- ESO clamps SetDimensions against the chat control's live dimension
    -- constraints. Earlier Ultivite builds raised only the ChatSystem extents,
    -- which can leave ZO_ChatWindow itself stuck at the stock 550 x 380 maximum.
    -- Keep geometry repair local here. Do not call RestoreNativeChatInteraction,
    -- because that would disable movement while Ultivite's explicit chat editor
    -- is active and would recreate the move/resize conflict we are avoiding.

    local currentWidth, currentHeight = Ultivite.GetChatDimensions()
    local rootWidth, rootHeight = 2350.7, 1322.3
    if Ultivite.GetLayoutRootDimensions then
        rootWidth, rootHeight = Ultivite.GetLayoutRootDimensions()
    elseif GuiRoot and type(GuiRoot.GetDimensions) == "function" then
        local ok, liveWidth, liveHeight = pcall(GuiRoot.GetDimensions, GuiRoot)
        if ok then rootWidth, rootHeight = liveWidth or rootWidth, liveHeight or rootHeight end
    end

    rootWidth = tonumber(rootWidth) or 2350.7
    rootHeight = tonumber(rootHeight) or 1322.3
    local minWidth, minHeight = 300, 170
    local maxWidth = math.max(550, math.floor(rootWidth - 40))
    local maxHeight = math.max(380, math.floor(rootHeight - 80))

    local chatSystem = Ultivite.GetChatSystem()
    if chatSystem then
        if type(chatSystem.SetContainerExtents) == "function" then
            pcall(chatSystem.SetContainerExtents, chatSystem, minWidth, maxWidth, minHeight, maxHeight)
        else
            chatSystem.minContainerWidth = minWidth
            chatSystem.maxContainerWidth = maxWidth
            chatSystem.minContainerHeight = minHeight
            chatSystem.maxContainerHeight = maxHeight
        end
    end

    if type(control.SetDimensionConstraints) == "function" then
        pcall(control.SetDimensionConstraints, control, minWidth, minHeight, maxWidth, maxHeight)
    end
    if type(container.CalculateConstraints) == "function" then
        pcall(container.CalculateConstraints, container)
    end

    width = math.min(maxWidth, math.max(minWidth, tonumber(width) or currentWidth))
    height = math.min(maxHeight, math.max(minHeight, tonumber(height) or currentHeight))

    -- Save through ESO's own SharedChatContainer path so size remains part of
    -- ZO_Ingame saved chat state rather than becoming another Ultivite setting.
    local ok = pcall(control.SetDimensions, control, width, height)
    if not ok then return false end
    if type(container.PerformLayout) == "function" then
        pcall(container.PerformLayout, container)
    end
    if type(container.SaveSettings) == "function" then
        pcall(container.SaveSettings, container)
    end

    -- Read back the actual live size. This makes Quick Menu buttons return false
    -- when ESO or another addon has immediately reimposed a conflicting limit.
    local liveWidth, liveHeight = Ultivite.GetChatDimensions()
    local success = math.abs((tonumber(liveWidth) or 0) - width) <= 2
        and math.abs((tonumber(liveHeight) or 0) - height) <= 2
    if not success and d then
        local cMinW, cMinH, cMaxW, cMaxH = nil, nil, nil, nil
        if type(control.GetDimensionConstraints) == "function" then
            local okConstraints, minW, minH, maxW, maxH = pcall(control.GetDimensionConstraints, control)
            if okConstraints then
                cMinW, cMinH, cMaxW, cMaxH = minW, minH, maxW, maxH
            end
        end
        d(string.format(
            "|c7FD4FF[Ultivite]|r Chat resize was clamped: requested=%.0fx%.0f actual=%.0fx%.0f constraints=%s/%s/%s/%s",
            width, height, tonumber(liveWidth) or 0, tonumber(liveHeight) or 0,
            tostring(cMinW), tostring(cMinH), tostring(cMaxW), tostring(cMaxH)))
    end
    return success
end


-- Direct chat edit fallback. This is deliberately opt in and exists only while
-- the user explicitly unlocks the chat window from Ultivite settings. Normal
-- gameplay leaves ESO's chat control and its native handlers completely alone.
function Ultivite.SavePrimaryChatContainerSettings()
    local container = Ultivite.GetPrimaryChatContainer()
    if not container then return false end
    if type(container.PerformLayout) == "function" then
        pcall(container.PerformLayout, container)
    end
    if type(container.SaveSettings) == "function" then
        pcall(container.SaveSettings, container)
    end
    return true
end

function Ultivite.GetChatPosition()
    local container = Ultivite.GetPrimaryChatContainer()
    local control = container and container.control or nil
    if not control then return 0, 0 end
    local left = type(control.GetLeft) == "function" and control:GetLeft() or 0
    local top = type(control.GetTop) == "function" and control:GetTop() or 0
    return tonumber(left) or 0, tonumber(top) or 0
end

function Ultivite.SetChatPosition(left, top)
    local container = Ultivite.GetPrimaryChatContainer()
    local control = container and container.control or nil
    if not control or not GuiRoot then return false end

    local rootWidth, rootHeight = 2350.7, 1322.3
    if Ultivite.GetLayoutRootDimensions then
        rootWidth, rootHeight = Ultivite.GetLayoutRootDimensions()
    elseif GuiRoot and type(GuiRoot.GetDimensions) == "function" then
        local ok, liveWidth, liveHeight = pcall(GuiRoot.GetDimensions, GuiRoot)
        if ok then
            rootWidth = tonumber(liveWidth) or rootWidth
            rootHeight = tonumber(liveHeight) or rootHeight
        end
    end
    local width, height = Ultivite.GetChatDimensions()
    left = zo_clamp(tonumber(left) or 0, 0, math.max(0, rootWidth - width))
    top = zo_clamp(tonumber(top) or 0, 0, math.max(0, rootHeight - height))

    if type(control.ClearAnchors) ~= "function" or type(control.SetAnchor) ~= "function" then return false end
    control:ClearAnchors()
    control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    Ultivite.SavePrimaryChatContainerSettings()
    return true
end

function Ultivite.BeginChatWindowEditing()
    local container = Ultivite.GetPrimaryChatContainer()
    local control = container and container.control or nil
    if not control or not WINDOW_MANAGER or not GuiRoot then return false end

    -- This is an explicit Ultivite editor. Do not run any background/native
    -- chat repair first; only the real primary chat control is temporarily
    -- unlocked for this edit session.
    Ultivite.chatEditSnapshot = Ultivite.chatEditSnapshot or {}
    local snapshot = Ultivite.chatEditSnapshot
    snapshot.wasHidden = type(control.IsHidden) == "function" and control:IsHidden() or false
    snapshot.control = control
    snapshot.container = container

    if type(control.SetHidden) == "function" then control:SetHidden(false) end
    if type(control.SetMovable) == "function" then control:SetMovable(true) end
    if type(control.SetClampedToScreen) == "function" then control:SetClampedToScreen(true) end

    local overlay = Ultivite.chatEditOverlay
    if not overlay then
        overlay = WINDOW_MANAGER:CreateTopLevelWindow("UltiviteChatWindowEditOverlay")
        overlay:SetMouseEnabled(true)
        overlay:SetClampedToScreen(true)
        overlay:SetDrawTier(DT_HIGH)
        overlay:SetDrawLayer(DL_OVERLAY)
        overlay:SetDrawLevel(9999)

        local bg = WINDOW_MANAGER:CreateControl(nil, overlay, CT_BACKDROP)
        bg:SetAnchorFill()
        bg:SetCenterColor(0.04, 0.04, 0.04, 0.18)
        bg:SetMouseEnabled(false)
        overlay.bg = bg

        local label = WINDOW_MANAGER:CreateControl(nil, overlay, CT_LABEL)
        label:SetAnchor(TOP, overlay, TOP, 0, 8)
        label:SetDimensions(520, 28)
        label:SetFont("ZoFontWinH4")
        label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        label:SetText("CHAT WINDOW  |  DRAG TO MOVE  |  MOUSE WHEEL TO RESIZE")
        label:SetColor(1, 0.82, 0.25, 1)
        label:SetMouseEnabled(false)
        overlay.label = label

        overlay:SetHandler("OnMouseDown", function(_, button)
            if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
            local active = Ultivite.chatEditSnapshot
            local target = active and active.control or nil
            if not target then return end
            if type(target.SetMovable) == "function" then target:SetMovable(true) end
            if type(target.StartMoving) == "function" then target:StartMoving() end
        end)
        overlay:SetHandler("OnMouseUp", function(_, button)
            if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
            local active = Ultivite.chatEditSnapshot
            local target = active and active.control or nil
            if target and type(target.StopMovingOrResizing) == "function" then
                pcall(target.StopMovingOrResizing, target)
            end
            Ultivite.SavePrimaryChatContainerSettings()
        end)
        overlay:SetHandler("OnMouseWheel", function(_, delta)
            if delta == 0 then return end
            local width, height = Ultivite.GetChatDimensions()
            local direction = delta > 0 and 1 or -1
            Ultivite.SetChatDimensions(width + (40 * direction), height + (24 * direction))
        end)
        Ultivite.chatEditOverlay = overlay
    end

    overlay:ClearAnchors()
    overlay:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
    overlay:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, 0, 0)
    overlay:SetMouseEnabled(true)
    overlay:SetHidden(false)
    Ultivite.chatWindowEditing = true
    return true
end

function Ultivite.IsChatWindowEditing()
    return Ultivite.chatWindowEditing == true
end

function Ultivite.ToggleChatWindowEditing()
    if Ultivite.chatWindowEditing == true then
        return Ultivite.EndChatWindowEditing(true)
    end
    return Ultivite.BeginChatWindowEditing()
end

function Ultivite.EndChatWindowEditing(save)
    local overlay = Ultivite.chatEditOverlay
    if overlay then
        overlay:SetMouseEnabled(false)
        overlay:SetHidden(true)
    end

    local snapshot = Ultivite.chatEditSnapshot
    local control = snapshot and snapshot.control or nil
    if control and type(control.StopMovingOrResizing) == "function" then
        pcall(control.StopMovingOrResizing, control)
    end
    if save ~= false then Ultivite.SavePrimaryChatContainerSettings() end

    local frames = Ultivite.Frames
    if frames and type(frames.RestoreNativeChatInteraction) == "function" then
        pcall(frames.RestoreNativeChatInteraction)
    end

    if control and snapshot and snapshot.wasHidden == true and type(control.SetHidden) == "function" then
        control:SetHidden(true)
    end

    Ultivite.chatWindowEditing = false
    Ultivite.chatEditSnapshot = nil
    return true
end

-- Built-in layout references are captured from a 4K client whose logical GuiRoot
-- measured 2350.7 x 1322.3. Presets scale from that logical root rather than
-- assuming physical pixels, so ESO UI scale and lower resolutions are respected.
Ultivite.LAYOUT_REFERENCE_WIDTH = 2350.7
Ultivite.LAYOUT_REFERENCE_HEIGHT = 1322.3

function Ultivite.GetLayoutRootDimensions()
    local width = Ultivite.LAYOUT_REFERENCE_WIDTH
    local height = Ultivite.LAYOUT_REFERENCE_HEIGHT
    if GuiRoot and type(GuiRoot.GetDimensions) == "function" then
        local ok, liveWidth, liveHeight = pcall(GuiRoot.GetDimensions, GuiRoot)
        if ok then
            width = tonumber(liveWidth) or width
            height = tonumber(liveHeight) or height
        end
    end
    return width, height
end

function Ultivite.GetLayoutScale()
    local width, height = Ultivite.GetLayoutRootDimensions()
    local xScale = width / Ultivite.LAYOUT_REFERENCE_WIDTH
    local yScale = height / Ultivite.LAYOUT_REFERENCE_HEIGHT
    local uniformScale = math.min(xScale, yScale)
    return xScale, yScale, uniformScale
end

function Ultivite.ScaleLayoutX(value)
    local _, _, uniformScale = Ultivite.GetLayoutScale()
    return (tonumber(value) or 0) * uniformScale
end

function Ultivite.ScaleLayoutY(value)
    local _, _, uniformScale = Ultivite.GetLayoutScale()
    return (tonumber(value) or 0) * uniformScale
end

function Ultivite.ScaleLayoutSize(value)
    local _, _, uniformScale = Ultivite.GetLayoutScale()
    return (tonumber(value) or 0) * uniformScale
end

-- Absolute coordinates such as Fancy Action Bar TOPLEFT anchors are transformed
-- around the canvas centre. This keeps centred 4K layouts centred on ultrawide
-- and other aspect ratios instead of stretching them sideways.
function Ultivite.ScaleLayoutAbsoluteX(value)
    local width = Ultivite.GetLayoutRootDimensions()
    local _, _, uniformScale = Ultivite.GetLayoutScale()
    local referenceCenter = Ultivite.LAYOUT_REFERENCE_WIDTH / 2
    return (width / 2) + (((tonumber(value) or 0) - referenceCenter) * uniformScale)
end

function Ultivite.ScaleLayoutAbsoluteY(value)
    local _, height = Ultivite.GetLayoutRootDimensions()
    local _, _, uniformScale = Ultivite.GetLayoutScale()
    local referenceCenter = Ultivite.LAYOUT_REFERENCE_HEIGHT / 2
    return (height / 2) + (((tonumber(value) or 0) - referenceCenter) * uniformScale)
end

