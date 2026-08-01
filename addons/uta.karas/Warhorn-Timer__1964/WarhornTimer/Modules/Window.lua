function WarhornTimer:WindowApplySettings()
  self.window:SetWidth(self.settings.width + self.settings.iconSize + 1)
  if (self.settings.height > self.settings.iconSize) then
    self.window:SetHeight(self.settings.height)
  else
    self.window:SetHeight(self.settings.iconSize)
  end
  self.window:ClearAnchors()
  self.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.settings.offset.x, self.settings.offset.y)
  self.window:SetMouseEnabled(not self.settings.locked)
  self.window:SetMovable(not self.settings.locked)
  self.window.container:SetHidden(not self.settings.alwaysShow)
  self.window.bar:SetWidth(self.settings.width)
  self.window.bar:SetHeight(self.settings.height)
  self.window.bar_back:SetEdgeColor(unpack(self.settings.colorEdge))
  self.window.bar_back:SetCenterColor(unpack(self.settings.colorBackground))
  self.window.bar_front:SetGradientColors(unpack(self.settings.colorBar))
  self.window.bar_label:SetFont('$(BOLD_FONT)|'..tostring(self.settings.textSize)..'|soft-shadow-thin')
  self.window.bar_label:SetColor(unpack(self.settings.colorLabel))
  self.window.icon:SetHidden(not self.settings.showIcon)
  self.window.icon:SetWidth(self.settings.iconSize)
  self.window.icon:SetHeight(self.settings.iconSize)
  self.window.icon:SetColor(unpack(self.settings.iconColor))
  self.window.icon:SetTexture(self.settings.iconTexture)
  if self.settings.reverse then
    self.window.bar:ClearAnchors()
    self.window.bar:SetAnchor(LEFT, self.window.container, LEFT, 0, 0)
    self.window.bar_front:SetBarAlignment(1)
    self.window.icon:ClearAnchors()
    self.window.icon:SetAnchor(RIGHT, self.window.container, RIGHT, 0, 0)
  else
    self.window.bar:ClearAnchors()
    self.window.bar:SetAnchor(RIGHT, self.window.container, RIGHT, 0, 0)
    self.window.bar_front:SetBarAlignment(0)
    self.window.icon:ClearAnchors()
    self.window.icon:SetAnchor(LEFT, self.window.container, LEFT, 0, 0)
  end
end

function WarhornTimer:WindowCreate()
  self.window = WINDOW_MANAGER:CreateTopLevelWindow('WarhornTimerWindow')
  self.window:SetHandler('OnMoveStop', function() self:WindowMoved() end)
  self.window:SetClampedToScreen(true)

  self.window.container = WINDOW_MANAGER:CreateControl('$(parent)Container', self.window, CT_CONTROL)
  self.window.container:SetAnchorFill()

  self.window.bar = WINDOW_MANAGER:CreateControl('$(parent)Bar', self.window.container, CT_CONTROL)

  self.window.bar_front = WINDOW_MANAGER:CreateControl('$(parent)Front', self.window.bar, CT_STATUSBAR)
  self.window.bar_front:SetAnchorFill()
  self.window.bar_front:SetMinMax(0, 1)

  self.window.bar_back = WINDOW_MANAGER:CreateControl('$(parent)Back', self.window.bar, CT_BACKDROP)
  self.window.bar_back:SetAnchorFill()
  self.window.bar_back:SetDrawLayer(1)
  self.window.bar_back:SetEdgeTexture(nil, 1, 1, 1, 1)

  self.window.bar_label = WINDOW_MANAGER:CreateControl('$(parent)Label', self.window.bar, CT_LABEL)
  self.window.bar_label:SetAnchorFill()
  self.window.bar_label:SetVerticalAlignment(1)
  self.window.bar_label:SetHorizontalAlignment(1)

  self.window.icon = WINDOW_MANAGER:CreateControl('$(parent)Icon', self.window.container, CT_TEXTURE)

  self:WindowSetValue(0)

  local fragment = ZO_SimpleSceneFragment:New(self.window)
  HUD_SCENE:AddFragment(fragment)
  HUD_UI_SCENE:AddFragment(fragment)
end

function WarhornTimer:WindowInitialize()
  self:WindowCreate()
  self:WindowApplySettings()
end

function WarhornTimer:WindowMoved()
  self.settings.offset.x = self.window:GetLeft()
  self.settings.offset.y = self.window:GetTop()
end

function WarhornTimer:WindowRefresh()
  if self.endTime ~= nil then
    local remainTime = self.endTime - GetFrameTimeSeconds()
    if remainTime < 0 then
      self:WindowStop()
    else
      self:WindowSetValue(remainTime)
    end
  end
end

function WarhornTimer:WindowSetValue(remainTime)
  self.window.bar_front:SetValue(remainTime)
  if self.settings.updateSpeed < 500 then
    self.window.bar_label:SetText(('%02.01f'):format(remainTime))
  else
    self.window.bar_label:SetText(('%d'):format(remainTime))
  end
end

function WarhornTimer:WindowStart(beginTime, endTime, iconName)
  local remainTime = endTime - beginTime
  if (remainTime > 0) and (self.endTime == nil or self.endTime < endTime) then
    local update = (self.endTime == nil)
    self.endTime = endTime
    self.window.bar_front:SetMinMax(0, remainTime)
    self:WindowSetValue(remainTime)
    self.window.icon:SetTexture(iconName)
    self.window.container:SetHidden(false)
    if update then
      EVENT_MANAGER:RegisterForUpdate(self.name, self.settings.updateSpeed, self.EventUpdate)
    end
  end
end

function WarhornTimer:WindowStop()
  EVENT_MANAGER:UnregisterForUpdate(self.name)
  self.endTime = nil
  self:WindowSetValue(0)
  self.window.container:SetHidden(not self.settings.alwaysShow)
end
