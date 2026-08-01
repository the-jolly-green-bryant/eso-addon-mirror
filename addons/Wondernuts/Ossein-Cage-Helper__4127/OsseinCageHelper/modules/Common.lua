OCH = OCH or {}
local OCH = OCH
OCH.Common = {
  castSources = {},
  panelActive = false,

  lastToxicIreTime = 0,
}

OCH.Common.constants = {
  hindered_id = 165972,
  murderous_trauma_id = 245785, -- Tormented Carrion Reaper Heavy Heal Absorption
  second_boss_trauma_id = 245919, -- Trauma from 2nd Boss Heavies
  kazpian_trauma_id = 245165, -- Trauma from Kazpian Frenzy
  trauma_ids = {
    [165972] = true,
    [245785] = true,
    [245919] = true,
    [245165] = true,
  },

  spectral_revenge_id = 236569, -- Spectral Revenant Spectral Revenge
  skullstorm_id = 236631, -- Skullmancer Skullstorm
  aspect_of_terror_id = 245318, 
  toxic_ire_id = 160007, -- Spectral Revenant Toxic Ire

  corvid_swarm_id = 236947, -- Murder Corvid Swarm debuff
  cursed_terrain_id = 236571, -- Tormented Deadraiser Cursed Terrain debuff
  detonate_soul_debuff_id = 236778, -- Tormented Soul Devourer Detonate Soul debuff
  life_drain_id = 236751, -- Tromented Soul Devourer Life Drain

  thisa_blood_dive_id = 238847, -- Blood Drinker Thisa Blood Dive

  caustic_carrion_ids = {
    [240708] = true, -- Trash, Boss 1, Boss 3 Portals
    [241089] = true, -- Boss 2 Portals
  },
}

function OCH.Common.Init()
  OCH.Common.castSources = {}
  OCH.Common.panelActive = false
end

function OCH.Common.Hindered(abilityId, result, targetType, targetUnitId, hitValue)
  local isDPS, isHeal, isTank = GetPlayerRoles()
  if isDPS then
    return
  end
  if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
    OCH.AddIconForDuration(
      OCH.GetTagForId(targetUnitId),
      "OsseinCageHelper/icons/shattered.dds",
      hitValue)
  elseif result == ACTION_RESULT_HEAL_ABSORBED then
    -- TODO: Track how much healing is left.
  elseif result == ACTION_RESULT_EFFECT_FADED then
    OCH.RemoveIcon(OCH.GetTagForId(targetUnitId))
  end
end

function OCH.Common.Skullstorm(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN and hitValue > 1000 then
    -- OCH.Alert("Skullmancer", GetFormattedAbilityName(abilityId), 0xD70040FF, abilityId, SOUNDS.OBJECTIVE_DISCOVERED, 2000)
    CombatAlerts.CastAlertsStart(OCH.Common.constants.skullstorm_id, "Skullstorm", hitValue, hitValue, nil, nil)
  end
end

function OCH.Common.ToxicIre(abilityId, result, targetType, targetUnitId, hitValue)
  OCH:Trace(1, string.format("Toxic Ire, Result %d, HitValue: %d, TargetType: %d", result, hitValue, targetType))

  if result == ACTION_RESULT_BEGIN then
    if targetType == COMBAT_UNIT_TYPE_PLAYER then

      local currentTime = GetGameTimeSeconds()
      if currentTime - OCH.Common.lastToxicIreTime > 10 then
        OCH.Alert("Spectral Revenant", "Toxic Ire (you)", 0xD70040FF, abilityId, SOUNDS.OBJECTIVE_DISCOVERED, 2000)
        OCH.Common.lastToxicIreTime = currentTime
      end
    end
  end
end

function OCH.Common.CorvidSwarm(abilityId, result, targetType, targetUnitId, hitValue)
  local borderId = "corvidSwarm"

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

function OCH.Common.CursedTerrain(abilityId, result, targetType, targetUnitId, hitValue)
  local borderId = "cursedTerrain"

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

function OCH.Common.ThisaBloodDive(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN and hitValue > 100 then
    OCH.Alert("Blood Drinker Thisa", "Blood Dive", 0xD70040FF, nil, SOUNDS.OBJECTIVE_DISCOVERED, 1500)
  end
end

function OCH.Common.DetonateSoul(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_EFFECT_GAINED_DURATION and targetType == COMBAT_UNIT_TYPE_PLAYER and hitValue > 100 then
    OCH.Alert("", "Detonate Soul (you)", 0x99CCFFFF, nil, SOUNDS.OBJECTIVE_DISCOVERED, 1500)
    CombatAlerts.AlertCast(abilityId, nil, hitValue, {-2, 0})
  end
end

function OCH.Common.LifeDrain(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN and hitValue > 100 and targetType == COMBAT_UNIT_TYPE_PLAYER then
    OCH.Alert("Soul Devourer", "Life Drain (you)", 0xD70040FF, nil, SOUNDS.OBJECTIVE_DISCOVERED, 2000)
  end
end

function OCH.Common.CausticCarrionEffect(abilityId, changeType, stackCount, unitTag, unitId)
  if unitTag == "player" then
    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then

      local color = OCH.Common.getCausticCarrionColor(stackCount)
      OCHStatusLabelCausticCarrionValue:SetText(string.format("|c%06X%d|r", color, stackCount))

      if OCH.savedVariables.showCausticCarrion then
        OCHStatus:SetHidden(false)
      end
      OCHStatusLabelCausticCarrion:SetHidden(not OCH.savedVariables.showCausticCarrion)
      OCHStatusLabelCausticCarrionValue:SetHidden(not OCH.savedVariables.showCausticCarrion)

    elseif changeType == EFFECT_RESULT_FADED then
      OCHStatus:SetHidden(not OCH.Common.panelActive)

      OCHStatusLabelCausticCarrion:SetHidden(true)
      OCHStatusLabelCausticCarrionValue:SetHidden(true)
    end
  end
end

function OCH.Common.getCausticCarrionColor(stackCount)
  local maxDangerStacks = OCH.Common.getCausticCarrionMaxDangerStacks()

  local remaining = maxDangerStacks - stackCount
  local ratio = LibCombatAlerts.Clamp(remaining / maxDangerStacks, 0, 1)

  return LibCombatAlerts.PackRGB(LibCombatAlerts.HSLToRGB(ratio / 3, 1, 0.5, 1))
end

function OCH.Common.getCausticCarrionMaxDangerStacks()
  if OCH.status.isJynorah then
    return 6
  elseif OCH.status.isKazpian then
    return 8
  else
    return 10
  end
end