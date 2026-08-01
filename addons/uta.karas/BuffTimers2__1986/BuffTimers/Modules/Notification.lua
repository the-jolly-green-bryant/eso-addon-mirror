BuffTimers.notifications = {}

function BuffTimers:NotificationAdd(barNumber, endTime)
  if self.settings.notification.enable then
    if self.notifications[barNumber] == nil then
      local nofiticationData
      if barNumber > self.settings.numberBars then
        nofiticationData = self.settings.groupBuffData[barNumber]
      else
        nofiticationData = self.settings.barData[barNumber]
      end
      local remainTime = endTime - GetFrameTimeSeconds()
      if ((nofiticationData.notification.threshold - 1.0) < remainTime) and (remainTime < nofiticationData.notification.threshold) then
        local notification = {
          sound       = nofiticationData.notification.sound,
          soundPlayed = false,
          text        = nil,
          endTime     = GetFrameTimeSeconds() + self.settings.notification.duration,
        }
        if nofiticationData.notification.text then
          if nofiticationData.notification.customText == "" then
            notification.text = nofiticationData.buffName
          else
            notification.text = nofiticationData.notification.customText
          end
        end
        self.notifications[barNumber] = notification
      end
    end
  end
end

function BuffTimers:NotificationApplySettings()
  if self.settings.notification.enable then
    self.notification:ClearAnchors()
    self.notification:SetAnchor(TOP, GuiRoot, TOPLEFT, self.settings.notification.offset.x, self.settings.notification.offset.y)
    self.notification:SetMovable(not self.settings.notification.locked)
    self.notification:SetMouseEnabled(not self.settings.notification.locked)
    self.notification.label:SetColor(unpack(self.settings.notification.color))
  end
end

function BuffTimers:NotificationCreate()
  if self.settings.notification.enable then
    self.notification = WINDOW_MANAGER:CreateTopLevelWindow('BuffTimersNotification')
    self.notification:SetHandler('OnMoveStop', function() self:NotificationMoved() end)
    if self.settings.notification.offset.x == 0 then
      self.notification:SetAnchor(CENTER, GuiRoot, CENTER, 0, -100)
      self.settings.notification.offset.x = self.notification:GetLeft()
      self.settings.notification.offset.y = self.notification:GetTop()
      self.notification:ClearAnchors()
    end
    self.notification:SetClampedToScreen(true)
    self.notification:SetResizeToFitDescendents(true)

    self.notification.label = WINDOW_MANAGER:CreateControl('$(parent)Label', self.notification, CT_LABEL)
    self.notification.label:SetAnchor(TOP, self.notification, TOP, 0,0)
    self.notification.label:SetVerticalAlignment(1)
    self.notification.label:SetHorizontalAlignment(1)
    self.notification.label:SetFont('ZoFontCallout3')
  end
end

function BuffTimers:NotificationInitialize()
  if self.settings.notification.enable then
    self:NotificationCreate()
    self:NotificationApplySettings()
  end
end

function BuffTimers:NotificationMoved()
  if self.settings.notification.enable then
    self.settings.notification.offset.x = self.notification:GetLeft() + (self.notification:GetWidth() / 2)
    self.settings.notification.offset.y = self.notification:GetTop()
  end
end

function BuffTimers:NotificationRefresh()
  if self.settings.notification.enable then
    local text = {}
    for barNumber, notification in pairs(self.notifications) do
      if notification.endTime < GetFrameTimeSeconds() then
        self:NotificationRemove(barNumber)
      else
        if not notification.soundPlayed then
          PlaySound(notification.sound)
          notification.soundPlayed = true
        end
        table.insert(text, notification.text)
      end
    end
    if #text > 0 then
      self.notification.label:SetText(table.concat(text, "\n"))
      self.notification:SetHidden(false)
    else
      self.notification:SetHidden(self.settings.notification.locked)
    end
  end
end

function BuffTimers:NotificationRemove(barNumber)
  if self.settings.notification.enable then
    self.notifications[barNumber] = nil
  end
end
