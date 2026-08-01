EPT = EPT or {}
local EPT = EPT

-- grouplist



--


function EPT.InitializeOpportunist(self, setId)
  self.group.opportunist = 0
  self.group.opportunistPerf = 0
  self.group.opportunistCounter = 0

  if self.store.special.opportunist.showDuration then
    self.event:RegisterForUpdate(self.name.."OpportunistUpdate"..tostring(setId), 500, self.OpportunistUpdate)
  end

  self.event:RegisterForEvent(self.name..tostring(setId), EVENT_COMBAT_EVENT, EPT.OnCombatEvent)
  self.event:AddFilterForEvent(self.name..tostring(setId), EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, self.procSets[setId].abilityId)
  self.event:AddFilterForEvent(self.name..tostring(setId), EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE , COMBAT_UNIT_TYPE_PLAYER)

  if self.store.special.opportunist.showAffected then
    self.event:RegisterForEvent(self.name.."OpportunistGain"..tostring(setId), EVENT_COMBAT_EVENT, EPT.NewOpportunistGain) --EPT.OpportunistGain)
    self.event:AddFilterForEvent(self.name.."OpportunistGain"..tostring(setId), EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, self.procSets[setId].debuff)
    self.event:AddFilterForEvent(self.name.."OpportunistGain"..tostring(setId), EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)

    --self.event:RegisterForEvent(self.name.."OpportunistFade"..tostring(setId), EVENT_COMBAT_EVENT, EPT.OpportunistFade)
    --self.event:AddFilterForEvent(self.name.."OpportunistFade"..tostring(setId), EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, self.procSets[setId].debuff)
    --self.event:AddFilterForEvent(self.name.."OpportunistFade"..tostring(setId), EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_FADED)
  end
end

function EPT.NewOpportunistGain()
  EPT.group.opportunistCounter = EPT.group.opportunistCounter + 1
  zo_callLater(function() EPT.group.opportunistCounter = EPT.group.opportunistCounter - 1 end, 22000)
end

function EPT.TerminateOpportunist(self, setId)
  self.event:UnregisterForEvent(self.name..tostring(setId), EVENT_COMBAT_EVENT)

  if self.store.special.opportunist.showDuration then
    self.event:UnregisterForUpdate(self.name.."OpportunistUpdate"..tostring(setId))
  end

  if self.store.special.opportunist.showAffected then
    self.event:UnregisterForEvent(self.name.."OpportunistGain"..tostring(setId), EVENT_COMBAT_EVENT)
    --self.event:UnregisterForEvent(self.name.."OpportunistFade"..tostring(setId), EVENT_COMBAT_EVENT)
  end
end



function EPT.OpportunistUpdate()
  local self = EPT
  local maxDuration = 16800

  local function Update(setId)
    local duration = GetAbilityDuration(self.procSets[setId].abilityId)
    local gui = self.guiList[setId].secondaryInd

    local output = ""

    if duration >= maxDuration then
      gui.label:SetColor(0,1,0,1)
      output = "max"
    else
      gui.label:SetColor(0,1,1,1)
      output = string.format( "%.1f", duration/1000)
    end

    --local multiplier = 1
    --if self.jorvuld then
    --  multiplier = 1.4
    --end
    --local effectiveDuration = duration*multiplier

    --gui.label:SetText(string.format( "%.1f", effectiveDuration/1000))
      gui.label:SetText(output)
-- WARNING jorvulds does not effect duration in "GetAbilityDuration" anymore. so it needs to be added manually
--    if self.jorvuld then maxDuration = 12000*1.4 end
--    if duration >= maxDuration then
--      gui.label:SetText("MAX")
--      gui.label:SetColor(0,1,0,1)
--    else
--      gui.label:SetText(string.format( "%.1f", duration/1000))
--      gui.label:SetColor(0,1,1,1)
--    end
    if EPT.group.opportunistCounter < 0 then
      EPT.group.opportunistCounter = 0
    end
    self.guiList[setId].tertiaryInd.label:SetText(tostring(EPT.group.opportunistCounter))
  end

  if self.completeSets[496] then
    Update(496)
  end
  if self.completeSets[497] then
    Update(497)
  end

end

function EPT:DisplayEffectedOpportunist(setId, num)
    self.guiList[setId].tertiaryInd.label:SetText(tostring(num))
end

function EPT.OpportunistGain(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, targetUnitId, abilityId)
  local self = EPT
  if abilityId == 135924 then
    self.group.opportunist = self.group.opportunist + 1
    self:DisplayEffectedOpportunist(496, self.group.opportunist)
  elseif abilityId == 137985 then
    self.group.opportunistPerf = self.group.opportunistPerf + 1
    self:DisplayEffectedOpportunist(497, self.group.opportunistPerf)
  end
  zo_callLater(function() EPT.OpportunistFadeWorkaround(abilityId) end, 22000)
end

function EPT.OpportunistFadeWorkaround(abilityId)
  local self = EPT
  if abilityId == 135924 then
    self.group.opportunist = self.group.opportunist - 1
    if self.group.opportunist < 0 then self.group.opportunist = 0 end
    self:DisplayEffectedOpportunist(496, self.group.opportunist)
  elseif abilityId == 137985 then
    self.group.opportunistPerf = self.group.opportunistPerf - 1
    if self.group.opportunistPerf < 0 then self.group.opportunistPerf = 0 end
    self:DisplayEffectedOpportunist(497, self.group.opportunistPerf)
  end
end


function EPT.OpportunistFade(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, targetUnitId, abilityId)
  local self = EPT
  if abilityId == 135924 then
    self.group.opportunist = self.group.opportunist - 1
    if self.group.opportunist < 0 then self.group.opportunist = 0 end
    self:DisplayEffectedOpportunist(496, self.group.opportunist)
  elseif abilityId == 137985 then
    self.group.opportunistPerf = self.group.opportunistPerf - 1
    if self.group.opportunistPerf < 0 then self.group.opportunistPerf = 0 end
    self:DisplayEffectedOpportunist(497, self.group.opportunistPerf)
  end
end

function EPT:SettingsOpportunist()
  return {
    {
          type = "checkbox",
          name = EPT_SETTINGS_SPECIAL_OPPORTUNIST_SLAYER,	--(optional)
          tooltip = "",	--(optional)
          getFunc = function() return self.store.special.opportunist.showDuration end,
          setFunc = function(bool)
            self.store.special.opportunist.showDuration = bool
          end,
          width = "full",	--or "half" (optional)
          warning = "Reloadui needed"
      },
    {
          type = "checkbox",
          name = EPT_SETTINGS_SPECIAL_OPPORTUNIST_AFFECTED,	--(optional)
          tooltip = "",	--(optional)
          getFunc = function() return self.store.special.opportunist.showAffected end,
          setFunc = function(bool)
            self.store.special.opportunist.showAffected = bool
          end,
          width = "full",	--or "half" (optional)
          warning = "Reloadui needed"
    },
  }
end

function EPT:SecondaryIndicatorOpportunist(setId, win)
    local data = self:GetGuiData(setId)

    local ctrl = self.window:CreateControl(data.name.."OpportunistControl2", win, CT_CONTROL )
    local offSet = data.nameOffSet

    ctrl:SetAnchor(LEFT, win, TOPRIGHT, offSet, offSet+5 )
    ctrl:SetHidden(not self.store.special.opportunist.showDuration)

    local back = self.window:CreateControl(data.name.."OpportunistBackground2", ctrl, CT_BACKDROP )
    back:SetAnchor( CENTER, ctrl, CENTER, 0, 0 )
    back:SetEdgeColor( 0, 0, 0, 1)
    back:SetCenterColor(0, 0, 0, 1)
    back:SetEdgeTexture( nil , data.edgeLine, data.edgeLine, data.edgeLine)
    back:SetHidden(true)

    local label = self.window:CreateControl(data.name.."OpportunistLabel2", ctrl, CT_LABEL )
    label:SetAnchor(CENTER, ctrl, CENTER, 4, 0 )
    label:SetColor( 1, 1, 1, 0.7 )
    label:SetFont(self:GetFont(data.design.indicator.font).."|"..math.floor(data.iconSize * 0.5 ).."|soft-shadow-thick")
    label:SetVerticalAlignment( TEXT_ALIGN_CENTER )
    label:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
    label:SetText("00.0")

    local width = label:GetTextWidth()
    local height = label:GetTextHeight()

    ctrl:SetDimensions( width+20, height+12 )
    back:SetDimensions( width+15, height+7 )
    label:SetDimensions( width+15, height+7)

    return {
      ["ctrl"] = ctrl,
      ["back"] = back,
      ["label"] = label,
    }
end

function EPT:TertiaryIndicatorOpportunist(setId, win)
    local data = self:GetGuiData(setId)

    local ctrl = self.window:CreateControl(data.name.."OpportunistControl3", win, CT_CONTROL )
    local offSet = data.nameOffSet

    ctrl:SetAnchor(LEFT, win, BOTTOMRIGHT, offSet+10,  0)
    ctrl:SetHidden(not self.store.special.opportunist.showAffected)

    local back = self.window:CreateControl(data.name.."OpportunistBackground3", ctrl, CT_BACKDROP )
    back:SetAnchor( CENTER, ctrl, CENTER, 0, 0 )
    back:SetEdgeColor( 0, 0, 0, 1)
    back:SetCenterColor(0, 0, 0, 1)
    back:SetEdgeTexture( nil , data.edgeLine, data.edgeLine, data.edgeLine)
    back:SetHidden(true)

    local label = self.window:CreateControl(data.name.."OpportunistLabel3", ctrl, CT_LABEL )
    label:SetAnchor(CENTER, ctrl, CENTER, 4, 0 )
    label:SetColor( 1, 1, 1, 0.7 )
    label:SetFont(self:GetFont(data.design.indicator.font).."|"..math.floor(data.iconSize * 0.5 ).."|soft-shadow-thick")
    label:SetVerticalAlignment( TEXT_ALIGN_CENTER )
    label:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
    label:SetText("0")

    local width = label:GetTextWidth()
    local height = label:GetTextHeight()

    ctrl:SetDimensions( width+20, height+12 )
    back:SetDimensions( width+15, height+7 )
    label:SetDimensions( width+15, height+7)

    return {
      ["ctrl"] = ctrl,
      ["back"] = back,
      ["label"] = label,
    }
end
