LCH = LCH or {}
local LCH = LCH
LCH.Common = {
  castSources = {}
}

LCH.Common.constants = {
  hindered_id = 165972,
  radiance_debuff_id = 214675,
  solar_flare_id = 222475, -- Dremora Spellcaster Solar Flare
}

function LCH.Common.Init()
  LCH.Common.castSources = {}
end

function LCH.Common.Hindered(result, targetType, targetUnitId, hitValue)
  local isDPS, isHeal, isTank = GetPlayerRoles()
  if isDPS then
    return
  end
  if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
    LCH.AddIconForDuration(
      LCH.GetTagForId(targetUnitId),
      "LucentCitadelHelper/icons/shattered.dds",
      hitValue)
  elseif result == ACTION_RESULT_HEAL_ABSORBED then
    -- TODO: Track how much healing is left.
  elseif result == ACTION_RESULT_EFFECT_FADED then
    LCH.RemoveIcon(LCH.GetTagForId(targetUnitId))
  end
end

function LCH.Common.Radiance(result, targetType, targetUnitId, hitValue)
  local borderId = "radiance"

  if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
    if targetType == COMBAT_UNIT_TYPE_PLAYER then
      CombatAlerts.ScreenBorderEnable(0xBF40BF99, hitValue, borderId)
    end

  elseif result == ACTION_RESULT_EFFECT_FADED then
    if targetType == COMBAT_UNIT_TYPE_PLAYER then
      CombatAlerts.ScreenBorderDisable(borderId)
    end
  end
end

function LCH.Common.ProcessInterrupts(result, targetUnitId) 
  if (CombatAlertsData.dodge.interrupts[result] and LCH.Common.castSources[targetUnitId]) then
		CombatAlerts.CastAlertsStop(LCH.Common.castSources[targetUnitId])
  end
end

function LCH.Common.SolarFlare(abilityId, result, sourceName, sourceUnitId, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN then
    if (targetType == COMBAT_UNIT_TYPE_PLAYER or LibCombatAlerts.isTank) then
      local flareLandingTime = 500

      local id = CombatAlerts.AlertCast(abilityId, sourceName, hitValue + flareLandingTime,  { flareLandingTime, 0, false, { 1, 0.4, 0, 0.5 }})
      if (sourceUnitId and sourceUnitId ~= 0) then
        LCH.Common.castSources[sourceUnitId] = id
      end
    end
  end
end