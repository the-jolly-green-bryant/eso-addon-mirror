EPT = EPT or {}
local EPT = EPT

function EPT.InitializeMartial(self, setId)
  if self.store.special.martial.showStamina then
    self.event:RegisterForEvent(self.name.."StaminaUpdate", EVENT_POWER_UPDATE, EPT.OnStaminaUpdate)
    self.event:AddFilterForEvent(self.name.."StaminaUpdate", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
    self.event:AddFilterForEvent(self.name.."StaminaUpdate", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_STAMINA)
  end

  self.event:RegisterForEvent(self.name..tostring(setId), EVENT_COMBAT_EVENT, EPT.OnCombatEvent)
  self.event:AddFilterForEvent(self.name..tostring(setId), EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, self.procSets[setId].abilityId)
  self.event:AddFilterForEvent(self.name..tostring(setId), EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE , COMBAT_UNIT_TYPE_PLAYER)
end

function EPT.TerminateMartial(self, setId)
  if self.store.special.martial.showStamina then
      self.event:UnregisterForEvent(self.name.."StaminaUpdate", EVENT_POWER_UPDATE)
  end
  self.event:UnregisterForEvent(self.name..tostring(setId), EVENT_COMBAT_EVENT)
end


function EPT.OnStaminaUpdate(_, _, _, _, current, _, max)
  local stamina = math.ceil(100*current/max)
  local gui = EPT.guiList[147].secondaryInd
  gui.label:SetText(tostring(stamina).."%")
  if stamina >= 50 then
    gui.back:SetCenterColor(0.5,0,0,0.7)
  else
    gui.back:SetCenterColor(0,0.5,0,0.7)
  end
  --gui.bar:SetDimensions()
end


function EPT:SecondaryIndicatorMartial(win)
  if self.store.special.martial.showStamina then
    local data = self:GetGuiData(147)

    local ctrl = self.window:CreateControl(data.name.."MartialControl2", win, CT_CONTROL )
    local offSet = data.nameOffSet

    ctrl:SetAnchor(LEFT, win, RIGHT, offSet+10, 0 )
    ctrl:SetHidden(false)

    local back = self.window:CreateControl(data.name.."MartialBackground2", ctrl, CT_BACKDROP )
    back:SetAnchor( CENTER, ctrl, CENTER, 0, 0 )
    back:SetEdgeColor( 0, 0, 0, 1)
    back:SetCenterColor(0.5,0,0,0.7)
    --back:SetDimensions()
    back:SetEdgeTexture( nil , data.edgeLine, data.edgeLine, data.edgeLine)
    back:SetHidden(false)

    local bar = self.window:CreateControl(data.name.."MartialBar2", ctrl, CT_BACKDROP )
    bar:SetAnchor( CENTER, ctrl, CENTER, 0, 0 )
    bar:SetEdgeColor( 0, 0, 0, 1)
    bar:SetCenterColor(0, 0, 0, 1)
    bar:SetEdgeTexture( nil , data.edgeLine, data.edgeLine, data.edgeLine)
    bar:SetHidden(true)

    local label = self.window:CreateControl(data.name.."MartialLabel2", ctrl, CT_LABEL )
    label:SetAnchor(CENTER, ctrl, CENTER, 0, 0 )
    label:SetColor( 1, 1, 1, 0.7 )
    label:SetFont(self:GetFont(data.design.indicator.font).."|"..math.floor(data.iconSize * 0.5 ).."|soft-shadow-thick")
    label:SetVerticalAlignment( TEXT_ALIGN_CENTER )
    label:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
    label:SetText("100%")

    local width = label:GetTextWidth()
    local height = label:GetTextHeight()

    ctrl:SetDimensions( width+10, height )
    back:SetDimensions( width+10, height)
    bar:SetDimensions( width, height)
    label:SetDimensions( width+10, height)

    return {
      ["ctrl"] = ctrl,
      ["back"] = back,
      --["bar"] = bar,
      ["label"] = label,
    }
  else
    return nil
  end
end


function EPT:SettingsMartial()
  return {
    {
          type = "checkbox",
          name = EPT_SETTINGS_SPECIAL_MARTIAL_STAMINA_NAME,	--(optional)
          tooltip = "",	--(optional)
          getFunc = function() return self.store.special.martial.showStamina end,
          setFunc = function(bool)
            self.store.special.martial.showStamina = bool
          end,
          width = "full",	--or "half" (optional)
          warning = "Reloadui needed"
      },
      {
            type = "description",
            --title = "My Title",	--(optional)
            title = nil,	--(optional)
            text = EPT_SETTINGS_SPECIAL_MARTIAL_STAMINA_NOTE,
            width = "full",	--or "half" (optional)
        },

  }
end
