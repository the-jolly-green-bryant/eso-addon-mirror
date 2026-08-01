function PJD.OnCombatState(_, inCombat)
  if not inCombat then
    if PJD.SV.showOnlyInCombat then
      PJD.RemoveFromHUD(true)
    else
      PJD.SetToDefault()
    end
    EVENT_MANAGER:UnregisterForUpdate(PJD.name .. "BossUpdate")
  else
    if PJD.SV.showOnlyInCombat then
      PJD.AddToHUD(false)
    end
    EVENT_MANAGER:RegisterForUpdate(PJD.name.."BossUpdate", 100, PJD.UpdateLoop)
  end
end

function PJD.UpdateLoop()
  if not DoesUnitExist("reticleover") then return PJD.SetToDefault() end

  for i = 1, GetNumBuffs("reticleover") do
    local _, _, finish, _, _, _, _, _, _, _, abilityId, _, castByPlayer = GetUnitBuffInfo("reticleover", i)
    
    local controlName = PJD.abilityIdLookup[abilityId]

    if controlName then
      PJD.UpdateText(controlName, finish)
    end
  end
end

function PJD.UpdateText(controlName, finish)
  local remainingTime = PJD.CalcTime(finish)
  local formattedTime = string.format("%.1f", remainingTime)

  if remainingTime <= 0.1 then
    PJD.SetDebuffToDefault(controlName)
  else
    PJD_Grid:GetNamedChild(controlName):SetText(formattedTime)
  end
end

function PJD.SetDebuffToDefault(controlName)
  if controlName == "Taunt" then
    PJD_Grid:GetNamedChild(controlName):SetText("0")
  else
    PJD_Grid:GetNamedChild(controlName):SetText(controlName)
  end
end

function PJD.SetToDefault()
  for _, v in ipairs(PJD.debuffTrackers) do
    if PJD.SV.trackers[v.shortCode] then
      PJD.SetDebuffToDefault(v.shortCode)
    end
  end
  if PJD.SV.trackers["Taunt"] then
    PJD.SetDebuffToDefault("Taunt")
  end
end

function PJD.CalcTime(finish)
  return math.floor((finish - GetGameTimeMilliseconds()/1000) * 10 + 0.5)/10
end
