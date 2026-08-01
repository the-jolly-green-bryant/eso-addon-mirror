EPT = EPT or {}
local EPT = EPT

function EPT.InitializeMania(self, setId)
    self.event:RegisterForEvent(self.name.."MagickaUpdate", EVENT_POWER_UPDATE, EPT.OnMagickaUpdate)
    self.event:AddFilterForEvent(self.name.."MagickaUpdate", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
    self.event:AddFilterForEvent(self.name.."MagickaUpdate", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_MAGICKA)
end

function EPT.TerminateMania(self, setId)
  self.event:UnregisterForEvent(self.name.."MagickaUpdate", EVENT_POWER_UPDATE)
end

function EPT.OnMagickaUpdate(_, _, _, _, current, _, max)
  local setId = 0
  if EPT.completeSets[587] then
    setId = 587
  elseif EPT.completeSets[591] then
    setId = 591
  end

  --local descr = GetAbilityDescription(154691)
  --Increases your damage done to non-player enemies by up to 15% based on your missing Magicka. Current value: 0%
  --local boni = string.sub(descr, 128, 130)

  --/script d(string.sub(GetAbilityDescription(154691), 115, 125))



  --

  local magicka = 100*current/max
  local calc = math.floor( (100-magicka)*12/100 )
  local calc2 =  (100-magicka)*12/100

  --d(GetAbilityDescription(154691))
  --d("calculated: "..tostring(calc))
  --d("calculated: "..tostring(calc2))
  --d("-----")

  local gui = EPT.guiList[setId].primaryInd
  gui.label:SetText(tostring(calc))

  --[[
  Fehler bei 10,95 ; 5,91
  ]]
end
