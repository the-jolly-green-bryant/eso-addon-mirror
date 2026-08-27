ShoppingListControls = {
    nextBackdropId = 1,
}

local Controls = ShoppingListControls

function Controls:CreateBackdrop(parent)
    local name = "GravvyShoppingListBackdrop" .. tostring(self.nextBackdropId)
    self.nextBackdropId = self.nextBackdropId + 1
    return WINDOW_MANAGER:CreateControlFromVirtual(name, parent, "ZO_DefaultBackdrop")
end
