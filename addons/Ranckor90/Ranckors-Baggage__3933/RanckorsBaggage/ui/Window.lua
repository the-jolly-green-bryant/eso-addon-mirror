local RB = RanckorsBaggage
local ICONS = RB.ICONS

function RB:SaveSize()
    if not self:IsValidWindow() then return end
    local w, h = RanckorsBaggageWindow:GetDimensions()
    self.saved.size = { w = w, h = h }
end

function RB:RestoreSize()
    if not self:IsValidWindow() then return end

    local size = self.saved.size
    if size and size.w and size.h then
        -- Manual size wins
        RanckorsBaggageWindow:SetDimensions(size.w, size.h)
    else
        local pct = tonumber(self.saved.uiScale) or 100
        pct = math.max(50, math.min(200, pct))

        local bw = self.baseWidth or select(1, self:GetWindowSize())
        local bh = self.baseHeight or select(2, self:GetWindowSize())
        RanckorsBaggageWindow:SetDimensions(bw * pct / 100, bh * pct / 100)
    end

    self:ApplyContentScale()
end

function RB:ResetToDefaultSize()
    self.saved.size = nil
    self.saved.uiScale = nil

    if self:IsValidWindow() then
        local w, h = self:GetWindowSize()
        RanckorsBaggageWindow:SetDimensions(w, h)
        self:ApplyContentScale()
    end
end

function RB:ApplyContentScale()
    if not (self.ui and self.ui.content and self:IsValidWindow()) then return end

    local winW, winH = RanckorsBaggageWindow:GetDimensions()
    local bw, bh = self.baseWidth, self.baseHeight
    if not (bw and bh and bw > 0 and bh > 0) then return end

    local scaleX = winW / bw
    local scaleY = winH / bh
    local scale = math.max(0.5, math.min(3.0, math.min(scaleX, scaleY)))

    self.ui.content:SetScale(scale)
    self.ui.content:ClearAnchors()
    self.ui.content:SetAnchor(TOPLEFT, RanckorsBaggageWindow, TOPLEFT, 0, 0)
end

function RB:ApplyBackgroundStyle(background)
    if not background then return end

    if (self.saved.backgroundStyle or "clear") == "clear" then
        background:SetCenterColor(0, 0, 0, 0)
        background:SetEdgeColor(0, 0, 0, 0)
    else
        background:SetCenterColor(0.1, 0.1, 0.1, 0.7)
        background:SetEdgeColor(0.1, 0.1, 0.1, 1)
    end
end

function RB:SetBackgroundStyle(style)
    self.saved.backgroundStyle = (style == "dark") and "dark" or "clear"

    if self:IsValidWindow() then
        local bg = RanckorsBaggageWindow:GetNamedChild("BG")
        if bg then
            self:ApplyBackgroundStyle(bg)
        end
        d(self.name .. ": Background style set to " .. self.saved.backgroundStyle)
    end
end

function RB:RestorePosition()
    if not self:IsValidWindow() then return end

    local pos = self.saved.position or self.defaults.position
    RanckorsBaggageWindow:ClearAnchors()
    RanckorsBaggageWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, pos.x, pos.y)
end

function RB:SavePosition()
    if not self:IsValidWindow() then return end

    self.saved.position = self.saved.position or { x = 0, y = 100 }
    self.saved.position.x = RanckorsBaggageWindow:GetLeft()
    self.saved.position.y = RanckorsBaggageWindow:GetTop()
end

function RB:ToggleWindow()
    if not self:IsValidWindow() then return end
    RanckorsBaggageWindow:SetHidden(not RanckorsBaggageWindow:IsHidden())
end

function RB:CreateUI()
    if self:IsValidWindow() then return end

    local width, height = self:GetWindowSize()
    self.baseWidth, self.baseHeight = width, height

    RanckorsBaggageWindow = WINDOW_MANAGER:CreateTopLevelWindow("RanckorsBaggageWindow")
    RanckorsBaggageWindow:SetDimensions(width, height)
    RanckorsBaggageWindow:SetMovable(true)
    RanckorsBaggageWindow:SetMouseEnabled(true)
    RanckorsBaggageWindow:SetClampedToScreen(true)
    RanckorsBaggageWindow:SetResizeHandleSize(12)

    local background = WINDOW_MANAGER:CreateControl("$(parent)BG", RanckorsBaggageWindow, CT_BACKDROP)
    background:SetAnchorFill(RanckorsBaggageWindow)
    self:ApplyBackgroundStyle(background)

    self.ui = {}

    self.ui.content = WINDOW_MANAGER:CreateControl("$(parent)Content", RanckorsBaggageWindow, CT_CONTROL)
    self.ui.content:SetDimensions(width, height)
    self.ui.content:SetAnchor(TOPLEFT, RanckorsBaggageWindow, TOPLEFT, 0, 0)

    self.ui.link = WINDOW_MANAGER:CreateControl("$(parent)Link", self.ui.content, CT_LABEL)
    self.ui.link:SetDimensions(width - 20, 24)
    self.ui.link:SetAnchor(TOPLEFT, self.ui.content, TOPLEFT, 10, 10)
    self.ui.link:SetFont(self:GetFont("value"))
    self.ui.link:SetColor(0, 0.7, 1, 1)
    self.ui.link:SetText(zo_strformat("|t20:20:<<1>>|t |u1:0::RanckorsBaggage|u", ICONS.LINK))
    self.ui.link:SetMouseEnabled(true)
    self.ui.link:SetHandler("OnMouseUp", function()
        RequestOpenUnsafeURL(self.devURL)
    end)

    self.ui.version = WINDOW_MANAGER:CreateControl("$(parent)Version", self.ui.content, CT_LABEL)
    self.ui.version:SetDimensions(width - 20, 20)
    self.ui.version:SetAnchor(TOPLEFT, self.ui.content, TOPLEFT, 25, 28)
    self.ui.version:SetFont(self:GetFont("button"))
    self.ui.version:SetColor(0.8, 0.8, 0.8, 1)
    self.ui.version:SetText(self.version)

    self.ui.label = WINDOW_MANAGER:CreateControl("$(parent)Label", self.ui.content, CT_LABEL)
    self.ui.label:SetDimensions(width - 20, height - 40)
    self.ui.label:SetAnchor(TOPLEFT, self.ui.content, TOPLEFT, 10, 35)
    self.ui.label:SetFont(self:GetFont("value"))
    self.ui.label:SetColor(1, 1, 1, 1)
    self.ui.label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    self.ui.label:SetVerticalAlignment(TEXT_ALIGN_TOP)

    RanckorsBaggageWindow:SetHandler("OnMoveStop", function()
        self:SavePosition()
    end)

    RanckorsBaggageWindow:SetHandler("OnSizeChanged", function()
        self:ApplyContentScale()
    end)

    RanckorsBaggageWindow:SetHandler("OnResizeStop", function()
        self:SaveSize()
        self:ApplyContentScale()
    end)

    self:ApplyContentScale()
end