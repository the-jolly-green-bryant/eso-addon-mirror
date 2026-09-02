ShoppingListControls = {
    nextBackdropId = 1,
}

local Controls = ShoppingListControls

function Controls:CreateBackdrop(parent)
    local name = "GravvyShoppingListBackdrop" .. tostring(self.nextBackdropId)
    self.nextBackdropId = self.nextBackdropId + 1
    return WINDOW_MANAGER:CreateControlFromVirtual(name, parent, "ZO_DefaultBackdrop")
end

function Controls:MakeWindowMovable(window, handle, data, positionKey)
    if not window or not handle then
        return
    end
    window:SetClampedToScreen(true)
    window:SetMouseEnabled(true)
    window:SetMovable(true)

    local position = data and data.GetWindowPosition
        and data:GetWindowPosition(positionKey) or nil
    if type(position) == "table"
        and type(position.left) == "number"
        and type(position.top) == "number"
    then
        window:ClearAnchors()
        window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, position.left, position.top)
    end

    local function savePosition()
        if data and data.SetWindowPosition then
            data:SetWindowPosition(positionKey, window:GetLeft(), window:GetTop())
        end
    end

    handle:SetMouseEnabled(true)
    handle:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            window:StartMoving()
        end
    end)
    handle:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            window:StopMovingOrResizing()
            savePosition()
        end
    end)
    window:SetHandler("OnMoveStop", savePosition)
end
