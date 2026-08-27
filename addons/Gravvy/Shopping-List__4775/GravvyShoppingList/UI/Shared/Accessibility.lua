ShoppingListAccessibility = {
    fonts = setmetatable({}, { __mode = "k" }),
    backdrops = setmetatable({}, { __mode = "k" }),
    windows = setmetatable({}, { __mode = "k" }),
}

local Accessibility = ShoppingListAccessibility

function Accessibility:Initialize(owner)
    self.owner = owner
end

function Accessibility:GetSettings()
    return self.owner and self.owner.data:GetSettings() or {}
end

function Accessibility:SetFont(control, fontName)
    self.fonts[control] = fontName
    local root = control
    while root and root.GetParent and root:GetParent()
        and root:GetParent() ~= GuiRoot
    do
        root = root:GetParent()
    end
    local rootName = root and root.GetName and root:GetName() or ""
    if root and root.SetScale
        and string.find(rootName, "ShoppingList", 1, true) == 1
        and not string.find(rootName, "Gamepad", 1, true)
    then
        self.windows[root] = true
        root:SetScale(tonumber(self:GetSettings().fontScale) or 1)
    end
    self:ApplyFont(control, fontName)
end

function Accessibility:ApplyFont(control, fontName)
    control:SetFont(fontName)
end

function Accessibility:RegisterBackdrop(backdrop, center, edge)
    self.backdrops[backdrop] = {
        center = center or { 0.035, 0.035, 0.045, 0.98 },
        edge = edge or { 0.5, 0.42, 0.28, 0.95 },
    }
    self:ApplyBackdrop(backdrop, self.backdrops[backdrop])
end

function Accessibility:ApplyBackdrop(backdrop, colors)
    if self:GetSettings().highContrast then
        backdrop:SetCenterColor(0, 0, 0, 1)
        backdrop:SetEdgeColor(1, 0.82, 0.25, 1)
    else
        backdrop:SetCenterColor(unpack(colors.center))
        backdrop:SetEdgeColor(unpack(colors.edge))
    end
end

function Accessibility:Apply()
    for control, fontName in pairs(self.fonts) do
        self:ApplyFont(control, fontName)
    end
    for backdrop, colors in pairs(self.backdrops) do
        self:ApplyBackdrop(backdrop, colors)
    end
    local scale = tonumber(self:GetSettings().fontScale) or 1
    for window in pairs(self.windows) do
        window:SetScale(scale)
    end
end

function Accessibility:Refresh()
    self:Apply()
    if self.owner.ui then
        self.owner.ui:Refresh()
    end
    if self.owner.gamepad then
        self.owner.gamepad:Refresh(true)
    end
end

function Accessibility:FormatStatus(message, isError)
    if not message or message == "" or not self:GetSettings().nonColorIndicators then
        return message or ""
    end
    return zo_strformat(
        GetString(isError and SI_SHOPPING_LIST_ACCESSIBILITY_ERROR_PREFIX
            or SI_SHOPPING_LIST_ACCESSIBILITY_STATUS_PREFIX),
        message
    )
end

function Accessibility:UsesNonColorIndicators()
    return self:GetSettings().nonColorIndicators == true
end

function Accessibility:UsesHighContrast()
    return self:GetSettings().highContrast == true
end
