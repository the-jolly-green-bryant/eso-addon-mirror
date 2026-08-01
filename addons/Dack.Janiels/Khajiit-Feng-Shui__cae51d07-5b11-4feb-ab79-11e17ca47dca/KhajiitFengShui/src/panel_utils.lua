---@alias KFS_Position { left: number?, top: number?, right: number?, bottom: number?, center: number?, mid: number? }

---@class KFS_PanelUtils
local PanelUtils = {};

---Creates a shallow copy of a position table
---@param position KFS_Position?
---@return KFS_Position?
function PanelUtils.copyPosition(position)
    if not position then
        return nil;
    end;

    local clone = {};
    for key, value in pairs(position) do
        clone[key] = value;
    end;

    return clone;
end;

---Rounds an offset to the nearest grid snap point
---@param offset number
---@param gridSize number?
---@return number
local function snapAnchorOffset(offset, gridSize)
    if not gridSize or gridSize <= 0 then
        return offset;
    end;
    return zo_roundToNearest(offset, gridSize);
end;

---Snaps all position values to the grid
---@param position KFS_Position?
---@param gridSize number?
---@return KFS_Position?
function PanelUtils.snapPositionToGrid(position, gridSize)
    if not position or not gridSize or gridSize <= 0 then
        return nil;
    end;

    local snapped = {};
    for key, value in pairs(position) do
        snapped[key] = snapAnchorOffset(value, gridSize);
    end;

    return snapped;
end;

---Calculates X offset for an anchor point
---@param point integer
---@param left number
---@param width number
---@param rootWidth number
---@return number
local function getAnchorPointX(point, left, width, rootWidth)
    if point == LEFT or point == TOPLEFT or point == BOTTOMLEFT then
        return left;
    elseif point == RIGHT or point == TOPRIGHT or point == BOTTOMRIGHT then
        return (left + width) - rootWidth;
    elseif point == CENTER or point == TOP or point == BOTTOM then
        return (left + (width * 0.5)) - (rootWidth * 0.5);
    end;
    return left;
end;

---Calculates Y offset for an anchor point
---@param point integer
---@param top number
---@param height number
---@param rootHeight number
---@return number
local function getAnchorPointY(point, top, height, rootHeight)
    if point == TOP or point == TOPLEFT or point == TOPRIGHT then
        return top;
    elseif point == BOTTOM or point == BOTTOMLEFT or point == BOTTOMRIGHT then
        return (top + height) - rootHeight;
    elseif point == CENTER or point == LEFT or point == RIGHT then
        return (top + (height * 0.5)) - (rootHeight * 0.5);
    end;
    return top;
end;

---Safely gets control owner object, returns nil for custom controls
---@param control userdata?
---@return userdata? owner
local function getControlOwnerSafe(control)
    if not control then
        return nil;
    end;

    -- Custom controls don't have owner objects, check by name
    local controlName = control:GetName();
    if controlName and (controlName:find("^KhajiitFengShui_") or controlName:find("^KhajiitFengShuiMover_")) then
        return nil;
    end;

    -- For game controls, try to get owner object
    -- Check if control has GetOwnerObject method first
    if control.GetOwnerObject then
        return control:GetOwnerObject();
    end;

    -- Fallback to global function if available
    if ZO_GetControlOwnerObject then
        local owner = ZO_GetControlOwnerObject(control);
        return owner;
    end;

    return nil;
end;

---Resolves layout width and height for a panel control
---@param control userdata
---@param definition KhajiitFengShuiPanelDefinition?
---@param widthOverride number?
---@param heightOverride number?
---@return number controlWidth
---@return number controlHeight
local function resolveControlDimensions(control, definition, widthOverride, heightOverride)
    local owner = getControlOwnerSafe(control);

    ---@param currentSize number?
    ---@param fallbackValue any
    ---@param override number?
    ---@return number
    local function resolveDimension(currentSize, fallbackValue, override)
        if override and override > 0 then
            return override;
        end;
        local size = currentSize;
        if size and size ~= 0 then
            return size;
        end;
        if definition then
            local evaluated = ZO_Eval(fallbackValue, control, owner);
            if evaluated then
                return evaluated;
            end;
        end;
        return 0;
    end;

    local controlWidth = resolveDimension(control.GetWidth and control:GetWidth(), definition and definition.width, widthOverride);
    local controlHeight = resolveDimension(control.GetHeight and control:GetHeight(), definition and definition.height, heightOverride);
    return controlWidth, controlHeight;
end;

---Returns visual top-left and size on screen (accounts for center-based transform scale)
---@param control userdata
---@param definition KhajiitFengShuiPanelDefinition?
---@param widthOverride number?
---@param heightOverride number?
---@return number visualLeft
---@return number visualTop
---@return number visualWidth
---@return number visualHeight
function PanelUtils.getVisualBounds(control, definition, widthOverride, heightOverride)
    local controlWidth, controlHeight = resolveControlDimensions(control, definition, widthOverride, heightOverride);
    local scale = control:GetTransformScale() or control:GetScale() or 1;
    local visualWidth = controlWidth * scale;
    local visualHeight = controlHeight * scale;

    local layoutLeft = control:GetLeft() or 0;
    local layoutTop = control:GetTop() or 0;

    if scale == 1 then
        return layoutLeft, layoutTop, visualWidth, visualHeight;
    end;

    local visualLeft = layoutLeft + (controlWidth - visualWidth) * 0.5;
    local visualTop = layoutTop + (controlHeight - visualHeight) * 0.5;
    return visualLeft, visualTop, visualWidth, visualHeight;
end;

---Computes relative offsets between control and GuiRoot
---@param control userdata
---@param point integer
---@param relativePoint integer
---@param left number
---@param top number
---@param definition KhajiitFengShuiPanelDefinition
---@return number offsetX
---@return number offsetY
local function computeRelativeOffsets(control, point, relativePoint, left, top, definition)
    local rootWidth = GuiRoot:GetWidth() or 0;
    local rootHeight = GuiRoot:GetHeight() or 0;

    local controlWidth, controlHeight = resolveControlDimensions(control, definition, nil, nil);

    -- Account for scale when computing visual dimensions for positioning
    local scale = control:GetTransformScale() or control:GetScale() or 1;
    local visualWidth = controlWidth * scale;
    local visualHeight = controlHeight * scale;

    -- In ESO, SetTransformScale scales around the control's center, not the anchor point
    -- So we need to adjust the anchor position to account for this
    -- If we want the visual edge at position 'left', and the anchor point is at the edge,
    -- the anchor point needs to be offset by half the difference between base and visual size
    local scaleOffsetX = 0;
    local scaleOffsetY = 0;

    if scale ~= 1 then
        -- Calculate how much the visual edge shifts from the anchor point due to center-based scaling
        -- For TOPLEFT anchor: visual left = anchor left + (baseWidth - visualWidth) / 2
        -- So: anchor left = visual left - (baseWidth - visualWidth) / 2
        if point == LEFT or point == TOPLEFT or point == BOTTOMLEFT then
            scaleOffsetX = (controlWidth - visualWidth) * 0.5;
        elseif point == RIGHT or point == TOPRIGHT or point == BOTTOMRIGHT then
            scaleOffsetX = -(controlWidth - visualWidth) * 0.5;
        elseif point == CENTER or point == TOP or point == BOTTOM then
            -- Center anchor doesn't shift horizontally
            scaleOffsetX = 0;
        end;

        if point == TOP or point == TOPLEFT or point == TOPRIGHT then
            scaleOffsetY = (controlHeight - visualHeight) * 0.5;
        elseif point == BOTTOM or point == BOTTOMLEFT or point == BOTTOMRIGHT then
            scaleOffsetY = -(controlHeight - visualHeight) * 0.5;
        elseif point == CENTER or point == LEFT or point == RIGHT then
            -- Center anchor doesn't shift vertically
            scaleOffsetY = 0;
        end;
    end;

    local controlAnchorX = getAnchorPointX(point, left - scaleOffsetX, visualWidth, rootWidth);
    local controlAnchorY = getAnchorPointY(point, top - scaleOffsetY, visualHeight, rootHeight);
    local targetAnchorX = getAnchorPointX(relativePoint, 0, rootWidth, rootWidth);
    local targetAnchorY = getAnchorPointY(relativePoint, 0, rootHeight, rootHeight);

    return controlAnchorX - targetAnchorX, controlAnchorY - targetAnchorY;
end;

---Applies anchor to control at specified position
---@param panel KhajiitFengShuiPanel
---@param left number
---@param top number
function PanelUtils.applyControlAnchor(panel, left, top)
    if not panel then
        return;
    end;

    local control = panel.control;
    if not (control and control.SetAnchor) then
        return;
    end;

    -- Disable clamping to allow positioning at screen edges
    PanelUtils.disableClamping(control);

    local definition = panel.definition or {};
    local point = definition.anchorPoint or TOPLEFT;
    local relativePoint = definition.anchorRelativePoint or point;
    local applyAnchor = definition.anchorApply;

    if type(applyAnchor) == "function" then
        control:ClearAnchors();
        applyAnchor(panel, left, top);
        return;
    end;

    local offsetX, offsetY = computeRelativeOffsets(control, point, relativePoint, left, top, definition);

    local anchor = ZO_Anchor:New(point, GuiRoot, relativePoint, offsetX, offsetY);
    anchor:Set(control);
end;

---Applies width and height to control
---@param control userdata?
---@param width any
---@param height any
function PanelUtils.applySizing(control, width, height)
    if not control then
        return;
    end;

    local owner = getControlOwnerSafe(control);

    if width ~= nil then
        local resolvedWidth = ZO_Eval(width, control, owner);
        if resolvedWidth then
            control:SetWidth(resolvedWidth);
        end;
    end;

    if height ~= nil then
        local resolvedHeight = ZO_Eval(height, control, owner);
        if resolvedHeight then
            control:SetHeight(resolvedHeight);
        end;
    end;
end;

---Enables scale inheritance recursively for control and children
---@param control userdata?
function PanelUtils.enableInheritScaleRecursive(control)
    if not control then
        return;
    end;

    if not control:GetInheritsScale() then
        control:SetInheritScale(true);
    end;

    local numChildren = control:GetNumChildren();
    for i = 1, numChildren do
        local child = control:GetChild(i);
        if child then
            PanelUtils.enableInheritScaleRecursive(child);
        end;
    end;
end;

---Applies scale transform to panel control
---@param panel KhajiitFengShuiPanel?
---@param scale number?
function PanelUtils.applyScale(panel, scale)
    if not panel then
        return;
    end;

    local control = panel.control;
    local definition = panel.definition or {};
    local appliedScale = scale or 1;

    if type(definition.scaleApply) == "function" then
        definition.scaleApply(panel, appliedScale);
        return;
    end;

    if control then
        PanelUtils.enableInheritScaleRecursive(control);
        control:SetTransformScale(appliedScale);
    end;
end;

---Formats position and label into display string
---@param left number?
---@param top number?
---@param labelText string
---@return string
function PanelUtils.formatPositionMessage(left, top, labelText)
    return string.format("%d, %d | %s", left or 0, top or 0, labelText);
end;

---Creates movable overlay window and label for panel
---@param panelId string
---@param control userdata
---@return userdata overlay
---@return userdata label
function PanelUtils.createOverlay(panelId, control)
    local windowManager = GetWindowManager();
    local overlayName = string.format("KhajiitFengShuiMover_%s", panelId);
    local overlay = _G[overlayName];
    local created = false;
    if not overlay then
        overlay = windowManager:CreateTopLevelWindow(overlayName);
        created = true;
    end;

    overlay:SetMouseEnabled(true);
    overlay:SetMovable(true);
    overlay:SetClampedToScreen(true);
    overlay:SetHidden(true);
    overlay:SetDrawLayer(DL_OVERLAY);
    overlay:SetDrawTier(DT_HIGH);
    overlay:SetDrawLevel(5);
    overlay:ClearAnchors();
    overlay:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, control:GetLeft(), control:GetTop());

    local backdrop = overlay.backdrop;
    if not backdrop then
        backdrop = windowManager:CreateControl(nil, overlay, CT_BACKDROP);
        overlay.backdrop = backdrop;
    end;
    backdrop:SetAnchorFill();
    backdrop:SetCenterColor(0.05, 0.6, 0.9, 0.25);
    backdrop:SetEdgeColor(0.05, 0.6, 0.9, 0.9);
    backdrop:SetEdgeTexture("", 2, 1, 1, 1);
    backdrop:SetDrawLayer(DL_OVERLAY);
    backdrop:SetDrawLevel(2);
    backdrop:SetDrawTier(DT_LOW);

    local label = overlay.label;
    if not label then
        label = windowManager:CreateControl(nil, overlay, CT_LABEL);
        overlay.label = label;
    end;
    label:SetFont("ZoFontGamepadBold27");
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER);
    label:SetVerticalAlignment(TEXT_ALIGN_BOTTOM);
    label:ClearAnchors();
    label:SetAnchor(BOTTOM, overlay, BOTTOM, 0, -4);
    label:SetColor(1, 1, 0, 1);
    label:SetDrawLayer(DL_OVERLAY);
    label:SetDrawLevel(6);
    label:SetDrawTier(DT_HIGH);
    label:SetMouseEnabled(false);
    if created then
        label:SetText("0, 0");
    end;

    local labelBackground = overlay.labelBackground;
    if not labelBackground then
        labelBackground = windowManager:CreateControl(nil, label, CT_BACKDROP);
        overlay.labelBackground = labelBackground;
    end;
    labelBackground:SetAnchorFill();
    labelBackground:SetCenterColor(0, 0, 0, 0.85);
    labelBackground:SetEdgeColor(0, 0, 0, 0);
    labelBackground:SetDrawLayer(DL_OVERLAY);
    labelBackground:SetDrawLevel(5);
    labelBackground:SetDrawTier(DT_MEDIUM);
    labelBackground:SetMouseEnabled(false);

    return overlay, label;
end;

---Syncs overlay dimensions to match control visual bounds (optional width/height overrides)
---@param panel KhajiitFengShuiPanel
---@param widthOverride number?
---@param heightOverride number?
function PanelUtils.syncOverlaySize(panel, widthOverride, heightOverride)
    local control = panel.control;
    local overlay = panel.overlay;
    if not (control and overlay) then
        return;
    end;

    local definition = panel.definition;
    local visualLeft, visualTop, visualWidth, visualHeight = PanelUtils.getVisualBounds(
        control,
        definition,
        widthOverride,
        heightOverride
    );

    overlay:SetDimensions(visualWidth, visualHeight);
    overlay:ClearAnchors();
    overlay:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, visualLeft, visualTop);
end;

---Sets overlay highlight color based on active state
---@param panel KhajiitFengShuiPanel
---@param isActive boolean
function PanelUtils.setOverlayHighlight(panel, isActive)
    if not (panel and panel.overlay and panel.overlay.backdrop) then
        return;
    end;

    local backdrop = panel.overlay.backdrop;
    if isActive then
        backdrop:SetCenterColor(0.2, 0.8, 0.2, 0.35);
        backdrop:SetEdgeColor(0.2, 0.9, 0.2, 1.0);
    else
        backdrop:SetCenterColor(0.05, 0.6, 0.9, 0.25);
        backdrop:SetEdgeColor(0.05, 0.6, 0.9, 0.9);
    end;
end;

---Updates overlay label text
---@param labelControl userdata?
---@param message string
function PanelUtils.updateOverlayLabel(labelControl, message)
    if labelControl then
        labelControl:SetText(message);
    end;
end;

---Gets left and top position from handler
---Note: LCA MoveableControl handles snapping, so we just get the position directly
---@param handler any
---@return number left
---@return number top
function PanelUtils.getAnchorPosition(handler)
    local position = handler:GetLeftTopPosition();
    return position.left or 0, position.top or 0;
end;

---Converts moveable position to anchor points and offsets
---@param position KFS_Position?
---@param gridSize number?
---@return integer point
---@return integer relativePoint
---@return number offsetX
---@return number offsetY
local function convertMoveablePositionToAnchor(position, gridSize)
    if not position then
        return TOPLEFT, TOPLEFT, 0, 0;
    end;

    local horizontalAnchor = nil;
    local verticalAnchor = nil;
    local offsetX = 0;
    local offsetY = 0;

    if position.left ~= nil then
        horizontalAnchor = LEFT;
        offsetX = snapAnchorOffset(position.left, gridSize);
    elseif position.center ~= nil then
        horizontalAnchor = CENTER;
        offsetX = snapAnchorOffset(position.center, gridSize);
    elseif position.right ~= nil then
        horizontalAnchor = RIGHT;
        offsetX = snapAnchorOffset(position.right, gridSize);
    end;

    if position.top ~= nil then
        verticalAnchor = TOP;
        offsetY = snapAnchorOffset(position.top, gridSize);
    elseif position.mid ~= nil then
        verticalAnchor = CENTER;
        offsetY = snapAnchorOffset(position.mid, gridSize);
    elseif position.bottom ~= nil then
        verticalAnchor = BOTTOM;
        offsetY = snapAnchorOffset(position.bottom, gridSize);
    end;

    local point = TOPLEFT;
    if horizontalAnchor == LEFT and verticalAnchor == TOP then
        point = TOPLEFT;
    elseif horizontalAnchor == LEFT and verticalAnchor == CENTER then
        point = LEFT;
    elseif horizontalAnchor == LEFT and verticalAnchor == BOTTOM then
        point = BOTTOMLEFT;
    elseif horizontalAnchor == CENTER and verticalAnchor == TOP then
        point = TOP;
    elseif horizontalAnchor == CENTER and verticalAnchor == CENTER then
        point = CENTER;
    elseif horizontalAnchor == CENTER and verticalAnchor == BOTTOM then
        point = BOTTOM;
    elseif horizontalAnchor == RIGHT and verticalAnchor == TOP then
        point = TOPRIGHT;
    elseif horizontalAnchor == RIGHT and verticalAnchor == CENTER then
        point = RIGHT;
    elseif horizontalAnchor == RIGHT and verticalAnchor == BOTTOM then
        point = BOTTOMRIGHT;
    end;

    return point, point, offsetX, offsetY;
end;

---Disables screen clamping for a control to allow edge positioning
---@param control userdata?
function PanelUtils.disableClamping(control)
    if not control then
        return;
    end;
    -- Disable clamping to allow positioning at screen edges
    if control.SetClampedToScreen then
        control:SetClampedToScreen(false);
    end;
end;

---Applies control anchor from moveable position data
---@param panel KhajiitFengShuiPanel?
---@param position KFS_Position?
---@param gridSize number?
function PanelUtils.applyControlAnchorFromPosition(panel, position, gridSize)
    if not panel or not position then
        return;
    end;

    local control = panel.control;
    if not (control and control.SetAnchor) then
        return;
    end;

    -- Disable clamping to allow positioning at screen edges
    PanelUtils.disableClamping(control);

    local definition = panel.definition or {};
    local applyAnchor = definition.anchorApply;

    if type(applyAnchor) == "function" then
        control:ClearAnchors();
        local left, top = PanelUtils.getAnchorPosition(panel.handler);
        applyAnchor(panel, left, top);
        return;
    end;

    local point, relativePoint = convertMoveablePositionToAnchor(position, gridSize);

    local definitionPoint = definition.anchorPoint;
    local definitionRelativePoint = definition.anchorRelativePoint or definitionPoint;

    -- Always use computeRelativeOffsets to account for scale, even when there's no definitionPoint
    -- The handler position represents the visual position, so we need to compute offsets correctly
    if definitionPoint then
        point = definitionPoint;
        relativePoint = definitionRelativePoint;
    end;

    local left, top = PanelUtils.getAnchorPosition(panel.handler);
    local offsetX, offsetY = computeRelativeOffsets(control, point, relativePoint, left, top, definition);

    local anchor = ZO_Anchor:New(point, GuiRoot, relativePoint, offsetX, offsetY);
    anchor:Set(control);
end;

KhajiitFengShui.PanelUtils = PanelUtils;
