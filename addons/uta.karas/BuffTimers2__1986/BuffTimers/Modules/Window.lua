function BuffTimers:WindowApplySettings(barNumber, settings)
  self.windows[barNumber]:SetWidth(settings.width + settings.icon.size + 1)
  if (settings.height > settings.icon.size) then
    self.windows[barNumber]:SetHeight(settings.height)
  else
    self.windows[barNumber]:SetHeight(settings.icon.size)
  end
  self.windows[barNumber]:ClearAnchors()
  self.windows[barNumber]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, settings.offset.x, settings.offset.y)
  self.windows[barNumber]:SetMouseEnabled(not settings.locked)
  self.windows[barNumber]:SetMovable(not settings.locked)
  self.windows[barNumber].container:SetHidden(not settings.alwaysShow)
  self.windows[barNumber].bar:SetWidth(settings.width)
  self.windows[barNumber].bar:SetHeight(settings.height)
  self.windows[barNumber].bar_back:SetEdgeColor(unpack(settings.colorEdge))
  self.windows[barNumber].bar_back:SetCenterColor(unpack(settings.colorBackground))
  self.windows[barNumber].bar_front:SetGradientColors(unpack(settings.colorBar))
  self.windows[barNumber].bar_label:SetFont('$(BOLD_FONT)|'..tostring(settings.textSize)..'|soft-shadow-thin')
  self.windows[barNumber].bar_label:SetColor(unpack(settings.colorLabel))
  self.windows[barNumber].icon:SetHidden(not settings.icon.show)
  self.windows[barNumber].icon:SetWidth(settings.icon.size)
  self.windows[barNumber].icon:SetHeight(settings.icon.size)
  self.windows[barNumber].icon:SetColor(unpack(settings.icon.color))
  if settings.reverse then
    self.windows[barNumber].bar:ClearAnchors()
    self.windows[barNumber].bar:SetAnchor(LEFT, self.windows[barNumber].container, LEFT, 0, 0)
    self.windows[barNumber].bar_front:SetBarAlignment(1)
    self.windows[barNumber].icon:ClearAnchors()
    self.windows[barNumber].icon:SetAnchor(RIGHT, self.windows[barNumber].container, RIGHT, 0, 0)
  else
    self.windows[barNumber].bar:ClearAnchors()
    self.windows[barNumber].bar:SetAnchor(RIGHT, self.windows[barNumber].container, RIGHT, 0, 0)
    self.windows[barNumber].bar_front:SetBarAlignment(0)
    self.windows[barNumber].icon:ClearAnchors()
    self.windows[barNumber].icon:SetAnchor(LEFT, self.windows[barNumber].container, LEFT, 0, 0)
  end
  if settings.icon.customIcon then
    self.windows[barNumber].icon:SetTexture(settings.icon.customIconTexture)
  else
    self.windows[barNumber].icon:SetTexture(settings.icon.texture)
  end
end

function BuffTimers:WindowCreate(barNumber)
  self.windows[barNumber] = WINDOW_MANAGER:CreateTopLevelWindow('BuffTimersWindow' .. barNumber)
  self.windows[barNumber]:SetHandler('OnMoveStop', function() self:WindowMoved(barNumber) end)
  self.windows[barNumber]:SetClampedToScreen(true)

  self.windows[barNumber].container = WINDOW_MANAGER:CreateControl('$(parent)Container', self.windows[barNumber], CT_CONTROL)
  self.windows[barNumber].container:SetAnchorFill()

  self.windows[barNumber].bar = WINDOW_MANAGER:CreateControl('$(parent)Bar', self.windows[barNumber].container, CT_CONTROL)

  self.windows[barNumber].bar_front = WINDOW_MANAGER:CreateControl('$(parent)Front', self.windows[barNumber].bar, CT_STATUSBAR)
  self.windows[barNumber].bar_front:SetAnchorFill()
  self.windows[barNumber].bar_front:SetMinMax(0, 1)

  self.windows[barNumber].bar_back = WINDOW_MANAGER:CreateControl('$(parent)Back', self.windows[barNumber].bar, CT_BACKDROP)
  self.windows[barNumber].bar_back:SetAnchorFill()
  self.windows[barNumber].bar_back:SetDrawLayer(1)
  self.windows[barNumber].bar_back:SetEdgeTexture(nil, 1, 1, 1, 1)

  self.windows[barNumber].bar_label = WINDOW_MANAGER:CreateControl('$(parent)Label', self.windows[barNumber].bar, CT_LABEL)
  self.windows[barNumber].bar_label:SetAnchorFill()
  self.windows[barNumber].bar_label:SetVerticalAlignment(1)
  self.windows[barNumber].bar_label:SetHorizontalAlignment(1)

  self.windows[barNumber].icon = WINDOW_MANAGER:CreateControl('$(parent)Icon', self.windows[barNumber].container, CT_TEXTURE)

  self:WindowSetValue(barNumber, 0)

  local fragment = ZO_SimpleSceneFragment:New(self.windows[barNumber])
  HUD_SCENE:AddFragment(fragment)
  HUD_UI_SCENE:AddFragment(fragment)
end

function BuffTimers:WindowInitialize()
  self.windows = {}
  for i=1, self.settings.numberBars do
    self:WindowCreate(i)
    self:WindowApplySettings(i, self.settings.barData[i])
  end
  for i=1, #self.groupBuffs do
    local barNumber = self.groupBuffs[i].barNumber
    if self.settings.groupBuffData[barNumber].track then
      self:WindowCreate(barNumber)
      self:WindowApplySettings(barNumber, self.settings.groupBuffData[barNumber])
    end
  end
end

function BuffTimers:WindowMoved(barNumber)
  if barNumber > self.settings.numberBars then
    self.settings.groupBuffData[barNumber].offset.x = self.windows[barNumber]:GetLeft()
    self.settings.groupBuffData[barNumber].offset.y = self.windows[barNumber]:GetTop()
  else
    self.settings.barData[barNumber].offset.x = self.windows[barNumber]:GetLeft()
    self.settings.barData[barNumber].offset.y = self.windows[barNumber]:GetTop()
  end
end

function BuffTimers:WindowRefresh(barNumber, endTime)
  local remainTime = endTime - GetFrameTimeSeconds()
  if remainTime < 0 then
    self:WindowStop(barNumber)
  else
    self:WindowSetValue(barNumber, remainTime)
    self:NotificationAdd(barNumber, endTime)
  end
end

function BuffTimers:WindowSetIcon(barNumber, iconName)
  if iconName then
    if self.settings.barData[barNumber].icon.customIcon then
      self.windows[barNumber].icon:SetTexture(self.settings.barData[barNumber].icon.customIconTexture)
    else
      self.settings.barData[barNumber].icon.texture = iconName
      self.windows[barNumber].icon:SetTexture(iconName)
    end
  end
end

function BuffTimers:WindowSetValue(barNumber, remainTime)
  self.windows[barNumber].bar_front:SetValue(remainTime)
  if self.settings.updateSpeed < 500 then
    self.windows[barNumber].bar_label:SetText(('%02.01f'):format(remainTime))
  else
    self.windows[barNumber].bar_label:SetText(('%d'):format(remainTime))
  end
end

function BuffTimers:WindowStart(barNumber, beginTime, endTime, iconName)
  local remainTime = endTime - beginTime
  if (remainTime > 0) and (self.activeBars[barNumber] == nil or self.activeBars[barNumber] < endTime) then
    self:NotificationRemove(barNumber)
    self.windows[barNumber].bar_front:SetMinMax(0, remainTime)
    self:WindowSetValue(barNumber, remainTime)
    self:WindowSetIcon(barNumber, iconName)
    self.windows[barNumber].container:SetHidden(false)
    self.activeBars[barNumber] = endTime
    if not self.eventUpdateActive then
      self.eventUpdateActive = true
      EVENT_MANAGER:RegisterForUpdate(self.name, self.settings.updateSpeed, self.EventUpdate)
    end
  end
end

function BuffTimers:WindowStartGroupBuff(barNumber, beginTime, endTime)
  if self.settings.groupBuffData[barNumber].track then
    self:WindowStart(barNumber, beginTime, endTime)
  end
end

function BuffTimers:WindowStop(barNumber)
  self:WindowSetValue(barNumber, 0)
  if barNumber > self.settings.numberBars then
    self.windows[barNumber].container:SetHidden(not self.settings.groupBuffData[barNumber].alwaysShow)
  else
    self.windows[barNumber].container:SetHidden(not self.settings.barData[barNumber].alwaysShow)
  end
  self.activeBars[barNumber] = nil
end

function BuffTimers:WindowStopByFade(barNumber)
  self:WindowStop(barNumber)
  self:NotificationAdd(barNumber, GetFrameTimeSeconds())
end
