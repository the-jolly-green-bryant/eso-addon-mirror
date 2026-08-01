OCH = OCH or {}
local OCH = OCH
OCH.Kazpian = {
  chainTargets = {},
  isSelfChainTarget = false,

  lastAgonizerBombs = 0,
  lastVileLeap = 0,
  lastSeethingVileLeap = 0,

  numPortalPhases = 0,
  numChannelersAlive = 0,

  numBitingBlazeTargets = 0,
  bitingBlazeSupports = {},

  portalExitIcon = nil,
  swordIcons = {},
}

OCH.Kazpian.constants = {
  heavy_shock_id = 235206, -- Molag Kena Heavy Shock
  storm_slam_id = 235201, -- Molag Kena Storm Slam
  storm_surge_id = 235205, -- Molag Kena Storm Surge

  dominators_chains_1_id = 232773,
  dominators_chains_2_id = 232775,

  dominators_chains_1_active_id = 232779,
  dominators_chains_2_active_id = 232780,

  torturous_chains_id = 236338, -- Debuff when players with chains are standing too close

  immolating_sphere_id = 237011, -- Incinerator Immolating Sphere

  stricken_id = 235594, -- Tank swap debuff

  giant_sword_kb_pulse_1_id = 235495,
  giant_sword_kb_pulse_2_id = 244937,
  giant_sword_cones_id = 232574,
  giant_sword_shock_spear_id = 235514,
  giant_sword_ids = {
    [232574] = true,
    [235495] = true,
    [244937] = true,
    [235514] = true,
  },

  agonizer_bombs_id = 237149, -- Bombs from Kazpian

  firebomb_debuff_id = 245264, -- Firebomb debuff indicating incoming firebomb
  tremor_shards_debuff_id = 245255, -- King Khrogo Tremor Shards debuff

  biting_blaze_cast_id = 235354, -- Kazpian Biting Blaze cast
  biting_blaze_cast_2_id = 246009, -- Kazpian Biting Blaze cast

  vile_leap_id = 235557, -- Kazpian Vile Leap
  seething_vile_leap_id = 245208, -- Kazpian Seething Vile Leap
  vile_teleport_id = 232969, -- Kazpian Teleport when jumping away to start portal phase

  ritual_buff_id = 234349, -- Pain Channeler Ritual buff when portal is active
}

function OCH.Kazpian.Init()
  OCH.Kazpian.lastAgonizerBombs = 0
  OCH.Kazpian.lastVileLeap = 0
  OCH.Kazpian.lastSeethingVileLeap = 0
  OCH.Kazpian.chainTargets = {
    [OCH.Kazpian.constants.dominators_chains_1_id] = nil,
    [OCH.Kazpian.constants.dominators_chains_2_id] = nil,
  }
  OCH.Kazpian.isSelfChainTarget = false
  OCH.Kazpian.numPortalPhases = 0
  OCH.Kazpian.numChannelersAlive = 0

  OCH.Kazpian.numBitingBlazeTargets = 0
  OCH.Kazpian.bitingBlazeSupports = {}
  
  OCH.Kazpian.ClearIcons()
  OCH.Kazpian.swordIcons = {}
end

function OCH.Kazpian.ClearIcons()
  OCH.DiscardPositionIconList(OCH.Kazpian.swordIcons)
  OCH.Kazpian.swordIcons = {}
  OCH.DiscardPositionIconList({OCH.Kazpian.portalExitIcon})
  OCH.Kazpian.portalExitIcon = nil
end

function OCH.Kazpian.MolagKenaHeavyShock(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN and hitValue > 1000 then
    if targetType == COMBAT_UNIT_TYPE_PLAYER then
      OCH.Alert("Molag Kena", "Heavy Shock", 0xFFD666FF, abilityId, SOUNDS.OBJECTIVE_DISCOVERED, 2000)
    end

    OCH.AddIconForDuration(
      OCH.GetTagForId(targetUnitId),
      "OsseinCageHelper/icons/electric-danger.dds",
      hitValue
    )
  end
end

function OCH.Kazpian.DominatorsChains(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
    local targetName = OCH.GetNameForId(targetUnitId)
    OCH.Kazpian.chainTargets[abilityId] = targetName
    if targetType == COMBAT_UNIT_TYPE_PLAYER then
      OCH.Kazpian.isSelfChainTarget = true
    end

    OCH.AddIconForDuration(
      OCH.GetTagForId(targetUnitId),
      "OsseinCageHelper/icons/chain.dds",
      hitValue
    )

    OCH.Kazpian.DominatorChainsAlert(abilityId)
  elseif result == ACTION_RESULT_EFFECT_FADED then
    OCH.Kazpian.chainTargets[abilityId] = nil
    OCH.Kazpian.isSelfChainTarget = false
  end
end

function OCH.Kazpian.DominatorChainsAlert(abilityId)
  local first_chain_target = OCH.Kazpian.chainTargets[OCH.Kazpian.constants.dominators_chains_1_id]
  local second_chain_target = OCH.Kazpian.chainTargets[OCH.Kazpian.constants.dominators_chains_2_id]

  if (first_chain_target ~= nil and second_chain_target ~= nil) then
    if OCH.savedVariables.showDominatorsChains == OCH.ALL or (OCH.savedVariables.showDominatorsChains == OCH.SELF and OCH.Kazpian.isSelfChainTarget) then
      local sound = SOUNDS.OBJECTIVE_DISCOVERED
      if OCH.Kazpian.isSelfChainTarget then
        sound = SOUNDS.DUEL_START
      end

      OCH.Alert("Dominator Chains", string.format("%s, %s", first_chain_target, second_chain_target), 0xD70040FF, abilityId, sound, 2000)
    end
  end
end

function OCH.Kazpian.DominatorsChainsActive(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
    OCH.AddIconForDuration(
      OCH.GetTagForId(targetUnitId),
      "OsseinCageHelper/icons/chain.dds",
      hitValue
    )

  elseif result == ACTION_RESULT_EFFECT_FADED then
    OCH.RemoveIcon(OCH.GetTagForId(targetUnitId))
  end
end

function OCH.Kazpian.TorturousChains(abilityId, result, targetType, targetUnitId, hitValue)
  local borderId = "torturousChains"

  if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
    if targetType == COMBAT_UNIT_TYPE_PLAYER then
      CombatAlerts.ScreenBorderEnable(0xD22B2BFF, hitValue, borderId)
    end

  elseif result == ACTION_RESULT_EFFECT_FADED then
    if targetType == COMBAT_UNIT_TYPE_PLAYER then
      CombatAlerts.ScreenBorderDisable(borderId)
    end
  end
end

function OCH.Kazpian.Stricken(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_EFFECT_GAINED_DURATION and LibCombatAlerts.isTank then
    local targetName = OCH.GetNameForId(targetUnitId)
    OCH.Alert("Stricken", targetName, 0xD70040FF, abilityId, SOUNDS.OBJECTIVE_DISCOVERED, 2000)
  end
end

function OCH.Kazpian.GiantSword(abilityId, result, targetType, targetUnitId, hitValue)
  if not OCH.savedVariables.showGiantSwords then
    return
  end

  if result == ACTION_RESULT_BEGIN and hitValue > 100 then
    if abilityId == OCH.Kazpian.constants.giant_sword_kb_pulse_1_id or abilityId == OCH.Kazpian.constants.giant_sword_kb_pulse_2_id then
      OCH.Alert("", "Giant Sword (Pulse)", 0x99CCFFFF, nil, SOUNDS.OBJECTIVE_DISCOVERED, 2000)
    elseif abilityId == OCH.Kazpian.constants.giant_sword_cones_id then
      OCH.Alert("", "Giant Sword (Cone)", 0x99CCFFFF, nil, SOUNDS.OBJECTIVE_DISCOVERED, 2000)
    elseif abilityId == OCH.Kazpian.constants.giant_sword_shock_spear_id then
      OCH.Alert("", "Giant Sword (Shock)", 0x99CCFFFF, nil, SOUNDS.OBJECTIVE_DISCOVERED, 2000)
    end

    if targetUnitId then
      OCH.Kazpian.GiantSwordGroundIcon(targetUnitId, hitValue)
    end
  end
end

function OCH.Kazpian.GiantSwordGroundIcon(targetUnitId, duration)
  local icon = OCH.AddGroundIconOnPlayerForDuration(OCH.GetTagForId(targetUnitId), "OsseinCageHelper/icons/diamond_sword.dds", duration)
  table.insert(OCH.Kazpian.swordIcons, icon)
end

function OCH.Kazpian.AgonizerBombs(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN and hitValue > 100 then
    local timeSinceLast = GetGameTimeSeconds() - OCH.Kazpian.lastAgonizerBombs
    if timeSinceLast > 5 then
      OCH.Alert("", "Agonizer Bombs", 0xFFD666FF, abilityId, SOUNDS.OBJECTIVE_DISCOVERED, 2000)
      OCH.Kazpian.lastAgonizerBombs = GetGameTimeSeconds()
    end
  end
end

function OCH.Kazpian.BitingBlaze(abilityId, result, targetType, targetUnitId, hitValue)
  local displayTargetName = GetUnitDisplayName(OCH.GetTagForId(targetUnitId)) or ""
  OCH:Trace(1, string.format("BitingBlaze, Result %d, HitValue: %d, TargetType: %d, TargetName: %s", result, hitValue, targetType, displayTargetName))

  -- LFG_ROLE_DPS, LFG_ROLE_TANK, LFG_ROLE_HEAL,LFG_ROLE_INVALID
  if result == ACTION_RESULT_BEGIN and hitValue > 100 then
    OCH.Kazpian.numBitingBlazeTargets = OCH.Kazpian.numBitingBlazeTargets + 1

    if GetGroupMemberSelectedRole(OCH.GetTagForId(targetUnitId)) ~= LFG_ROLE_DPS then
      local targetName = OCH.GetNameForId(targetUnitId)
      table.insert(OCH.Kazpian.bitingBlazeSupports, targetName)
    end

    if OCH.Kazpian.numBitingBlazeTargets == 6 then
      local bitingBlazeSupportsStr = table.concat(OCH.Kazpian.bitingBlazeSupports, ", ")
      OCH.Alert("Biting Blaze", bitingBlazeSupportsStr, 0xFF6600FF, abilityId, SOUNDS.OBJECTIVE_DISCOVERED, 2000)

      zo_callLater(function () OCH.Kazpian.ClearBitingBlazeTargets() end, 20000)
    end
    -- OCH.Alert("", "Agonizer Bombs", 0xFFD666FF, abilityId, SOUNDS.OBJECTIVE_DISCOVERED, 2000)
  end
end

function OCH.Kazpian.ClearBitingBlazeTargets()
  OCH.Kazpian.numBitingBlazeTargets = 0
  OCH.Kazpian.bitingBlazeSupports = {}
end

function OCH.Kazpian.Firebomb(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
    if targetType == COMBAT_UNIT_TYPE_PLAYER then
      OCH.Alert("King Khrogo", "Firebomb", 0xFF6600FF, abilityId, SOUNDS.DUEL_START, 1500)
      CombatAlerts.CastAlertsStart(OCH.Kazpian.constants.firebomb_debuff_id, "Firebomb", hitValue, nil, nil, nil)
    end
  end
end

function OCH.Kazpian.VileLeap(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN and hitValue > 100 then
    local timeSinceLast = GetGameTimeSeconds() - OCH.Kazpian.lastVileLeap

    if timeSinceLast > 5 then
      if OCH.savedVariables.showVileLeap then
        OCH.Alert("Overfiend Kazpian", "Vile Leap", 0xBF40BFFF, abilityId, SOUNDS.OBJECTIVE_DISCOVERED, 2000)
      end

      -- OCH.AddIconForDuration(OCH.GetTagForId(targetUnitId), "OsseinCageHelper/icons/meeting-point.dds", hitValue)
      CombatAlerts.AlertCast(abilityId, nil, hitValue + 1500, {-2, 0})
      -- CombatAlerts.CastAlertsStart(abilityId, "Vile Leap", hitValue + 1500, nil, nil, { 1000, nil, 1, 0.4, 0, 0.5, nil })
      OCH.Kazpian.lastVileLeap = GetGameTimeSeconds()
    end
  end
end

function OCH.Kazpian.SeethingVileLeap(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN and hitValue > 100 then
    local timeSinceLast = GetGameTimeSeconds() - OCH.Kazpian.lastSeethingVileLeap

    if timeSinceLast > 5 then
      OCH.Alert("Overfiend Kazpian", "Enraged Vile Leap", 0xD70040FF, abilityId, SOUNDS.BATTLEGROUND_CAPTURE_FLAG_TAKEN_OWN_TEAM, 2000)
      
      if targetUnitId then
        OCH.AddIconForDuration(OCH.GetTagForId(targetUnitId), "OsseinCageHelper/icons/meeting-point.dds", hitValue)
      end

      -- CombatAlerts.CastAlertsStart(abilityId, "Seething Vile Leap", hitValue, nil, nil, { 1000, "Dodge!", 1, 0.4, 0, 0.5, SOUNDS.DUEL_START })
      CombatAlerts.AlertCast(abilityId, nil, hitValue + 1500, {-2, 1})
      OCH.Kazpian.lastSeethingVileLeap = GetGameTimeSeconds()
    end
  end
end

function OCH.Kazpian.MolagKenaStormSlam(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN and hitValue > 500 then
    OCH.Alert("Molag Kena", "Storm Slam", 0xFFD666FF, abilityId, SOUNDS.OBJECTIVE_DISCOVERED, 2000)
    CombatAlerts.CastAlertsStart(OCH.Kazpian.constants.storm_slam_id, "Storm Slam", hitValue, nil, nil, { 1000, "Dodge!", 1, 0.4, 0, 0.5, SOUNDS.DUEL_START })
  end
end

function OCH.Kazpian.MolagKenaStormSurge(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN and hitValue > 500 then
    CombatAlerts.AlertCast(abilityId, nil, hitValue, {-2, 0})
  end
end

function OCH.Kazpian.ImmolatingSphere(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN and hitValue > 500 and targetType == COMBAT_UNIT_TYPE_PLAYER then
    OCH.Alert("Incinerator", "Immolating Sphere (you)", 0xFF6600FF, abilityId, SOUNDS.OBJECTIVE_DISCOVERED, 2000)
  end
end

function OCH.Kazpian.VileTeleport(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN and hitValue > 100 then
    OCH.Kazpian.numPortalPhases = OCH.Kazpian.numPortalPhases + 1
    -- The number of channelers for each portal phase increases by 1 each portal phase
    OCH.Kazpian.numChannelersAlive = OCH.Kazpian.numPortalPhases

    if OCH.savedVariables.showKazpianPortalDone then
      OCH.Alert("", string.format("Portal #%d: Starting", OCH.Kazpian.numPortalPhases), 0x99CCFFFF, nil, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
    end
  end
end

function OCH.Kazpian.PainChannelerRitualFaded(abilityId, result, targetType, targetUnitId, hitValue)
  -- This buff wearing off indicates the channeler has died
  if result == ACTION_RESULT_EFFECT_FADED then
    OCH.Kazpian.numChannelersAlive = OCH.Kazpian.numChannelersAlive - 1
    if OCH.Kazpian.numChannelersAlive <= 0 then
      if OCH.savedVariables.showKazpianPortalDone then
        OCH.Alert("", string.format("Portal #%d: DONE", OCH.Kazpian.numPortalPhases), 0x99CCFFFF, nil, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
      end
      OCH.Kazpian.AddPortalExitIcon()
    end
  end
end

function OCH.Kazpian.AddPortalExitIcon()
  if OCH.savedVariables.showKazpianPortalExitIcon and OCH.hasOSI() then

    if not OCH.Kazpian.portalExitIcon then
      OCH.Kazpian.portalExitIcon = OCH.AddGroundCustomIcon(
        57020, 35525, 199914,
        "OsseinCageHelper/icons/portal.dds"
      )
      
      local name = OCH.name .. "AddPortalExitIcon" .. tostring(GetGameTimeSeconds())
      
      EVENT_MANAGER:RegisterForUpdate(name, 10000, function() 
        EVENT_MANAGER:UnregisterForUpdate(name)
        OCH.DiscardPositionIconList({OCH.Kazpian.portalExitIcon})
        OCH.Kazpian.portalExitIcon = nil
      end )
    end
  end
end

function OCH.Kazpian.UpdateTick(timeSec)

end

