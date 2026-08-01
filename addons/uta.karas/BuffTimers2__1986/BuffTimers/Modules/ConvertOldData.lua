function BuffTimers:ConvertOldData1to2()
  local profileName
  local src
  local dst
  if self.player.profiles then
    for i=1, #self.player.profiles.profileData do
      profileName = GetUnitName('player') .. ' ' .. tostring(i)
      BuffTimers:ProfileCreate(profileName, BuffTimers.defaultProfile)

      src = self.player.profiles.profileData[i]
      dst = self.profiles.profileData[profileName]

      if self.player.updateSpeed then
        dst.updateSpeed = self.player.updateSpeed
      end

      dst.notification.enable = true
      if src.announceColor then
        dst.notification.color = ZO_ShallowTableCopy(src.announceColor)
      end
      if src.announceDur then
        dst.notification.duration = src.announceDur
      end
      if src.announcePos then
        dst.notification.offset = ZO_ShallowTableCopy(src.announcePos)
      end

      if src.numberBars then
        dst.numberBars = src.numberBars
      end

      if src.buffNames then
        dst.buffNames = {}
        for k, v in pairs(src.buffNames) do
          dst.buffNames[self:ConvertOldDataFixBuffName(k)] = v
        end
      end

      if src.barData then
        dst.barData = {}
        for j=1, #src.barData do
          dst.barData[j] = ZO_DeepTableCopy(self.defaultBarData)
          if src.barData[j].buffName then
            dst.barData[j].buffName = self:ConvertOldDataFixBuffName(src.barData[j].buffName)
          end
          if src.barData[j].offset then
            dst.barData[j].offset = ZO_ShallowTableCopy(src.barData[j].offset)
          end
          if src.barData[j].locked ~= nil then
            dst.barData[j].locked = src.barData[j].locked
          end
          if src.barData[j].alwaysShow ~= nil then
            dst.barData[j].alwaysShow = src.barData[j].alwaysShow
          end
          if src.barData[j].width then
            dst.barData[j].width = src.barData[j].width
          end
          if src.barData[j].height then
            dst.barData[j].height = src.barData[j].height
          end
          if src.barData[j].textSize then
            dst.barData[j].textSize = src.barData[j].textSize
          end
          if src.barData[j].colorBar then
            dst.barData[j].colorBar = ZO_ShallowTableCopy(src.barData[j].colorBar)
          end
          if src.barData[j].colorEdge then
            dst.barData[j].colorEdge = ZO_ShallowTableCopy(src.barData[j].colorEdge)
          end
          if src.barData[j].colorBg then
            dst.barData[j].colorBackground = ZO_ShallowTableCopy(src.barData[j].colorBg)
          end
          if src.barData[j].showIcon ~= nil then
            dst.barData[j].icon.show = src.barData[j].showIcon
          end
          if src.barData[j].iconSize then
            dst.barData[j].icon.size = src.barData[j].iconSize
          end
          if src.barData[j].iconTexture then
            dst.barData[j].icon.texture = src.barData[j].iconTexture
          end
          if src.barData[j].customIcon ~= nil then
            dst.barData[j].icon.customIcon = src.barData[j].customIcon
          end
          if src.barData[j].customIconTex then
            dst.barData[j].icon.customIconTexture = src.barData[j].customIconTex
          end
          if src.barData[j].announcement then
            dst.barData[j].notification.threshold = src.barData[j].criticalTime
          else
            dst.barData[j].notification.threshold = 0
          end
          if src.barData[j].soundToPlay then
            dst.barData[j].notification.sound = src.barData[j].soundToPlay
          end
          if src.barData[j].notiText then
            dst.barData[j].notification.customText = src.barData[j].notiText
          end
        end
      end

      if self.player.activeProfile == i then
        self.player.activeProfile = profileName
      end
    end
    self.player.profiles = nil
  end
  self.player.customFilterXalsoY = nil
  self.player.needsCheckForNewFormat = nil
  self.player.updateSpeed = nil
end

function BuffTimers:ConvertOldDataFixBuffName(str)
  str = zo_strformat('<<z:1>>', str)
  str = zo_strformat('<<t:1>>', str)
  return str
end
