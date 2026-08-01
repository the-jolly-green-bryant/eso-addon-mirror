CCSentinelFloats = CCSentinelFloats or {}

function CCSentinelFloats:Initialize()
    self.container = _G["CCSentinelContainer"]
    self.icon = _G["CCSentinelIcon"]
    if not self.container or not self.icon then
        return
    end

    self.container:SetHidden(false)
    self.icon:SetHidden(false)

    self.container:SetDrawLayer(DL_OVERLAY)
    self.container:SetDrawTier(DT_HIGH)
    self.container:SetDrawLevel(10000)
    self.container:SetAlpha(1.0)
    self.container:SetInheritAlpha(false)
    self.container:SetClampedToScreen(true)

    self.icon:SetDrawLayer(DL_OVERLAY)
    self.icon:SetDrawTier(DT_HIGH)
    self.icon:SetDrawLevel(10001)
    self.icon:SetAlpha(1.0)
    self.icon:SetInheritAlpha(false)
    self.icon:SetClampedToScreen(true)

    self:UpdateIconPositions()
    EVENT_MANAGER:RegisterForUpdate("CCSentinelFloatsUpdate", 50, function() self:UpdateVisibility() end)
end

function CCSentinelFloats:UpdateVisibility()
    local isActive = CCSentinel and CCSentinel.timerActive or false
    self.container:SetHidden(not isActive)
end

function CCSentinelFloats:UpdateIconPositions()
    local SV = CCSentinelSettings and CCSentinelSettings.savedVars or { baseX = 500, baseY = 520, iconScale = 1.0 }
    local baseX = SV.baseX or 500
    local baseY = SV.baseY or 520
    local scale = SV.iconScale or 1.0
    local spacingX = 0
    local spacingY = 0

    if not self.container or not self.icon then
        return
    end

    local iconGrid = { ["Immunity"] = { col = 1, row = 1 } }
    local indicators = { ["Immunity"] = { control = self.icon } }

    local gridPos = iconGrid["Immunity"]
    if gridPos and indicators["Immunity"].control then
        local col = gridPos.col
        local row = gridPos.row
        local xOffset = baseX + (col - 1) * spacingX
        local yOffset = baseY + (row - 1) * spacingY
        indicators["Immunity"].control:SetDimensions(64 * scale, 64 * scale)
        indicators["Immunity"].control:ClearAnchors()
        indicators["Immunity"].control:SetAnchor(TOPLEFT, self.container, TOPLEFT, xOffset, yOffset)
    end
end

function CCSentinelFloats:RefreshSettings()
    self:UpdateIconPositions()
end
