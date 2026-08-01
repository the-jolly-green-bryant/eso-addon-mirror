EPT = EPT or {}
local EPT = EPT


function EPT.OnBloodlord(event, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
  local gui = EPT.guiList[521].primaryInd

  if result == 2240 then 
    if sourceUnitId == EPT.playerId then
      EPT.bloodlordTarget = targetUnitId
      gui.label:SetText("On")
      gui.label:SetColor(0,1,0,1)
      gui.edge:SetCenterColor(0,1,0,1)
    end
  elseif result == 2250 then
    if targetUnitId == EPT.bloodlordTarget then
      gui.label:SetText("Off")
      gui.label:SetColor(1,0,0,1)
      gui.edge:SetCenterColor(1,0,0,1)
    end
  end
end

function EPT.InitializeBloodlord(self, setId)
  self.bloodlordTarget = 1

  self.event:RegisterForEvent(self.name.."Bloodlord", EVENT_COMBAT_EVENT, self.OnBloodlord)
  self.event:AddFilterForEvent(self.name.."Bloodlord", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 139903)
end


function EPT.TerminateBloodlord(self, setId)
  self.event:UnregisterForEvent(self.name.."Bloodlord", EVENT_COMBAT_EVENT)
end
