EPT = EPT or {}
local EPT = EPT

function EPT.OnSpaulder(event, result)
  local gui = EPT.guiList[627].primaryInd
  if result == ACTION_RESULT_EFFECT_GAINED then
    gui.label:SetText("On")
    gui.label:SetColor(0,1,0,1)
    gui.edge:SetCenterColor(0,1,0,1)
    EPT.store.spaulder = true
  elseif result == ACTION_RESULT_EFFECT_FADED then
    gui.label:SetText("Off")
    gui.label:SetColor(1,0,0,1)
    gui.edge:SetCenterColor(1,0,0,1)
    EPT.store.spaulder = false
  end
end

function EPT.InitializeSpaulder(self, setId)
  local function OnZoneCheck()
    newZone = GetZoneId(GetUnitZoneIndex("player"))
    if newZone == EPT.lastZone then
      return
    else
      EPT.OnSpaulder(_, ACTION_RESULT_EFFECT_FADED)
      EPT.lastZone = newZone
    end
  end

  self.event:RegisterForEvent(self.name.."OnZoneCheck", EVENT_PLAYER_ACTIVATED, OnZoneCheck)

  self.event:RegisterForEvent(self.name.."SpaulderToggle", EVENT_COMBAT_EVENT, self.OnSpaulder)
  self.event:AddFilterForEvent(self.name.."SpaulderToggle", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 163359)
  self.event:AddFilterForEvent(self.name.."SpaulderToggle", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
end

function EPT.TerminateSpaulder(self, setId)
  EPT.OnSpaulder(_, ACTION_RESULT_EFFECT_FADED)
  self.event:UnregisterForEvent(self.name.."SpaulderToggle", EVENT_COMBAT_EVENT)
  self.event:UnregisterForEvent(self.name.."OnZoneCheck", EVENT_PLAYER_ACTIVATED)
end
