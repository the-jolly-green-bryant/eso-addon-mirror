OCH = OCH or {}
local OCH = OCH

OCH.name     = "OsseinCageHelper"
OCH.version  = "0.6.0"
OCH.author   = "@Wondernuts"
OCH.active   = false

OCH.status = {
  testStatus = 0,
  inCombat = false,

  currentBoss = "",
  isJynorah = false,
  isShaperOfFlesh = false,
  isKazpian = false,
  isHMBoss = false,

  locked = true,

  unitDamageTaken = {}, -- unitDamageTaken[unitId] = all damage events for a given id.
  --[[ TODO: Damage events to track:
    ACTION_RESULT_DAMAGE,
    ACTION_RESULT_CRITICAL_DAMAGE,
    ACTION_RESULT_DOT_TICK,
    ACTION_RESULT_DOT_TICK_CRITICAL,
    ACTION_RESULT_BLOCK,
  ]]--
  debuffTracker = {},

  mainTankTag = "",
}
-- Default settings.
OCH.settings = {
  showHinderedIcon = true,
  showChannelerDone = true,
  showCausticCarrion = true,
  showDaedrothSpawn = true,
  showTitanicClash = true,
  showSplitBossHealth = true,
  showDragonBossHealth = true,
  showHeatRay = "RELEVANT",
  showReflectiveScales = true,
  showReflectiveScalesBorder = false,
  showTailSlam = false,
  showVileLeap = true,
  showDominatorsChains = "Self",
  showGiantSwords = false,
  showKazpianPortalDone = true,
  showKazpianPortalExitIcon = true,

  -- Misc
  uiCustomScale = 1,
}

OCH.charSettings = {
  enablePortalHelper = false,
  portalTeamType = "CHANNELER",
  startingBossSide = "",
  portalAssignmentLogic = "STATIC",
  enablePortalEndBossAlert = true,
}
OCH.units = {}
OCH.unitsTag = {}

function OCH.EffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
  OCH.IdentifyUnit(unitTag, unitName, unitId)
  -- EFFECT_RESULT_GAINED = 1
  -- EFFECT_RESULT_FADED = 2
  -- EFFECT_RESULT_UPDATED = 3

  if OCH.Common.constants.caustic_carrion_ids[abilityId] then
    OCH.Common.CausticCarrionEffect(abilityId, changeType, stackCount, unitTag, unitId)
  end
end

function OCH.CombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
  OCH.TraceEnemyCombatEvents(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)

  if OCH.Common.constants.trauma_ids[abilityId] then
    OCH.Common.Hindered(abilityId, result, targetType, targetUnitId, hitValue)

  -- elseif abilityId == OCH.Common.constants.toxic_ire_id then
  --   OCH.Common.ToxicIre(abilityId, result, targetType, targetUnitId, hitValue)
  elseif abilityId == OCH.Common.constants.corvid_swarm_id then
    OCH.Common.CorvidSwarm(abilityId, result, targetType, targetUnitId, hitValue)
  elseif abilityId == OCH.Common.constants.cursed_terrain_id then
    OCH.Common.CursedTerrain(abilityId, result, targetType, targetUnitId, hitValue)
  elseif abilityId == OCH.Common.constants.thisa_blood_dive_id then
    OCH.Common.ThisaBloodDive(abilityId, result, targetType, targetUnitId, hitValue)
  elseif abilityId == OCH.Common.constants.detonate_soul_debuff_id then
    OCH.Common.DetonateSoul(abilityId, result, targetType, targetUnitId, hitValue)
  -- elseif abilityId == OCH.Common.constants.life_drain_id then
  --   OCH.Common.LifeDrain(abilityId, result, targetType, targetUnitId, hitValue)

  elseif abilityId == OCH.ShaperOfFlesh.constants.charge_id then
    OCH.ShaperOfFlesh.OgrimCharge(abilityId, result, targetType, targetUnitId, hitValue)
  elseif abilityId == OCH.ShaperOfFlesh.constants.shaper_of_flesh_shield_id then
    OCH.ShaperOfFlesh.ShaperOfFleshShieldFaded(abilityId, result, targetType, targetUnitId, hitValue)
  elseif abilityId == OCH.ShaperOfFlesh.constants.shaper_alive_buff_id then
    OCH.ShaperOfFlesh.ShaperOfFleshKilled(abilityId, result, targetType, targetUnitId, hitValue)

  elseif abilityId == OCH.Jynorah.constants.coldflame_surge_id then
    OCH.Jynorah.ColdFlameSurge(abilityId, result, targetType, targetUnitId, hitValue)
  elseif abilityId == OCH.Jynorah.constants.brimstone_surge_id then
    OCH.Jynorah.BrimstoneSurge(abilityId, result, targetType, targetUnitId, hitValue)
  elseif OCH.Jynorah.constants.curse_cast_ids[abilityId] then
    OCH.Jynorah.Curse(abilityId, result, targetType, targetUnitId, hitValue)
  elseif abilityId == OCH.Jynorah.constants.jynorah_heat_ray_id then
    OCH.Jynorah.JynHeatRay(abilityId, result, targetType, targetUnitId, hitValue)
  elseif abilityId == OCH.Jynorah.constants.skorkhif_heat_ray_id then
    OCH.Jynorah.SkorHeatRay(abilityId, result, targetType, targetUnitId, hitValue)
  elseif abilityId == OCH.Jynorah.constants.myrinax_goaded_breath then
    OCH.Jynorah.MyrinaxGoadedBreath(abilityId, result, targetType, targetUnitId, hitValue)
  elseif abilityId == OCH.Jynorah.constants.valneer_goaded_breath then
    OCH.Jynorah.ValneerGoadedBreath(abilityId, result, targetType, targetUnitId, hitValue)
  elseif OCH.Jynorah.constants.reflective_scales_ids[abilityId] then
    OCH.Jynorah.ReflectiveScales(abilityId, result, targetType, targetUnitId, hitValue)
  elseif OCH.Jynorah.constants.tail_slam_ids[abilityId] then
    OCH.Jynorah.TailSlam(abilityId, result, targetType, targetUnitId, hitValue)
  elseif abilityId == OCH.Jynorah.constants.titanic_clash_id then
    OCH.Jynorah.TitanicClash(abilityId, result, targetType, targetUnitId, hitValue)
  elseif OCH.Jynorah.constants.dragon_ability_to_name[abilityId] then
    OCH.Jynorah.IdentifyDragonEnemyId(abilityId, result, sourceUnitId, targetUnitId, hitValue, powerType)
  elseif OCH.Jynorah.constants.titanic_clash_hits[abilityId] then
    OCH.Jynorah.TitanicClashHit(abilityId, result, targetType, targetUnitId, hitValue, powerType)
  elseif OCH.Jynorah.constants.titanic_leap_ids[abilityId] then
    OCH.Jynorah.TitanicLeap(abilityId, result, targetType, targetUnitId, hitValue)
  elseif OCH.Jynorah.constants.curse_ids[abilityId] then
    OCH.Jynorah.CurseDebuff(abilityId, result, targetType, targetUnitId, hitValue)
  elseif OCH.Jynorah.constants.titanic_clash_start_ids[abilityId] then
    OCH.Jynorah.PortalHelper(abilityId, result, targetType, targetUnitId, hitValue)

  elseif abilityId == OCH.Kazpian.constants.heavy_shock_id then
    OCH.Kazpian.MolagKenaHeavyShock(abilityId, result, targetType, targetUnitId, hitValue)
  elseif (abilityId == OCH.Kazpian.constants.dominators_chains_1_id or abilityId == OCH.Kazpian.constants.dominators_chains_2_id) then
    OCH.Kazpian.DominatorsChains(abilityId, result, targetType, targetUnitId, hitValue)
  elseif (abilityId == OCH.Kazpian.constants.dominators_chains_1_active_id or abilityId == OCH.Kazpian.constants.dominators_chains_2_active_id) then
    OCH.Kazpian.DominatorsChainsActive(abilityId, result, targetType, targetUnitId, hitValue)
  elseif abilityId == OCH.Kazpian.constants.torturous_chains_id then
    OCH.Kazpian.TorturousChains(abilityId, result, targetType, targetUnitId, hitValue)
  elseif abilityId == OCH.Kazpian.constants.stricken_id then
    OCH.Kazpian.Stricken(abilityId, result, targetType, targetUnitId, hitValue)
  elseif OCH.Kazpian.constants.giant_sword_ids[abilityId] then
    OCH.Kazpian.GiantSword(abilityId, result, targetType, targetUnitId, hitValue)
  elseif abilityId == OCH.Kazpian.constants.agonizer_bombs_id then
    OCH.Kazpian.AgonizerBombs(abilityId, result, targetType, targetUnitId, hitValue)
  -- elseif abilityId == OCH.Kazpian.constants.biting_blaze_cast_id or abilityId == OCH.Kazpian.constants.biting_blaze_cast_2_id then
  --   OCH.Kazpian.BitingBlaze(abilityId, result, targetType, targetUnitId, hitValue)
  -- elseif abilityId == OCH.Kazpian.constants.firebomb_debuff_id then
  --   OCH.Kazpian.Firebomb(abilityId, result, targetType, targetUnitId, hitValue)
  elseif abilityId == OCH.Kazpian.constants.vile_leap_id then
    OCH.Kazpian.VileLeap(abilityId, result, targetType, targetUnitId, hitValue)
  elseif abilityId == OCH.Kazpian.constants.seething_vile_leap_id then
    OCH.Kazpian.SeethingVileLeap(abilityId, result, targetType, targetUnitId, hitValue)
  elseif abilityId == OCH.Kazpian.constants.storm_slam_id then
    OCH.Kazpian.MolagKenaStormSlam(abilityId, result, targetType, targetUnitId, hitValue)
  elseif abilityId == OCH.Kazpian.constants.storm_surge_id then
    OCH.Kazpian.MolagKenaStormSurge(abilityId, result, targetType, targetUnitId, hitValue)
  elseif abilityId == OCH.Kazpian.constants.immolating_sphere_id then
    OCH.Kazpian.ImmolatingSphere(abilityId, result, targetType, targetUnitId, hitValue)
  elseif abilityId == OCH.Kazpian.constants.vile_teleport_id then
    OCH.Kazpian.VileTeleport(abilityId, result, targetType, targetUnitId, hitValue)
  elseif abilityId == OCH.Kazpian.constants.ritual_buff_id then
    OCH.Kazpian.PainChannelerRitualFaded(abilityId, result, targetType, targetUnitId, hitValue)
  end

  if OCH.status.isJynorah and OCH.status.isHMBoss then
    OCH.Jynorah.TrackCombatEventsToDragons(abilityId, result, targetUnitId, hitValue, powerType)
  end
end

function OCH.UpdateTick(gameTimeMs)
  local timeSec = GetGameTimeSeconds()

  if IsUnitInCombat("boss1") then
    if not OCH.status.inCombat then
      -- If it switched from non-combat to combat, re-check boss names.
      OCH.BossesChanged()
    end
    OCH.status.inCombat = true
  end

  if OCH.status.inCombat == false then
    return
  end
  
  -- Boss 1: Shaper of Flesh
  if OCH.status.isShaperOfFlesh then

  end

  -- Boss 2: Jynorah
  if OCH.status.isJynorah then
    OCH.Jynorah.UpdateTick(timeSec)
  end

  -- Boss 3: Kazpian
  if OCH.status.isKazpian then

  end

end

function OCH.DeathState(event, unitTag, isDead)
  if unitTag == "player" and not isDead and not IsUnitInCombat("boss1") then
    -- I just resurrected, and it was a wipe or we killed the boss.
    -- Remove all UI
    OCH.ClearUIOutOfCombat()
  end

  if unitTag == "player" and isDead then
    OCH.PlayerDead()
  end
end

function OCH.PlayerDead()
  if OCH.status.isJynorah then
    OCH.Jynorah.PlayerDead()
  end
end

function OCH.CombatState(eventCode, inCombat)
  local currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("boss1", POWERTYPE_HEALTH)
  -- Do not change combat state if you are dead, or the boss is not full.

  -- Do not do anything outside of boss fights.
  if maxTargetHP == 0 or maxTargetHP == nil then
    OCH.ClearUIOutOfCombat()
    return
  end
  if currentTargetHP < 0.99*maxTargetHP or IsUnitDead("player") then
    return
  end
  if inCombat then
    OCH.status.inCombat = true
    OCH.ResetStatus()
    OCH.BossesChanged()
  else
    OCH.ClearUIOutOfCombat()
  end
end

function OCH.ResetStatus()
  OCH.status.debuffTracker = {}
  OCH.status.unitDamageTaken = {}

  OCH.Common.Init()
  OCH.ShaperOfFlesh.Init()
  OCH.Jynorah.Init()
  OCH.Kazpian.Init()

  OCH.status.mainTankTag = ""
end

function OCH.GetBossName()
  -- 1 to 6 so far
  for i = 1,MAX_BOSSES do
    local name = string.lower(GetUnitName("boss" .. tostring(i)))
    if name ~= nil and name ~= "" then
      return name
    end
  end
  return ""
end

function OCH.BossesChanged()
  local bossName = OCH.GetBossName()
  local lastBossName = OCH.status.currentBoss

  if bossName ~= nil then
    OCH.status.currentBoss = bossName

    OCH.status.isShaperOfFlesh = false
    OCH.status.isJynorah = false
    OCH.status.isKazpian = false
    OCH.status.isHMBoss = false

    local currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("boss1", POWERTYPE_HEALTH)
    local hardmodeHealth = {
      [OCH.data.shaperOfFleshName] = 7000000,  -- vet ?, HM 8.3M
      [OCH.data.jynorahName] = 60000000, -- vet ?, HM 74.5M
      [OCH.data.kazpianName] = 100000000, -- vet: ?, HM 116.4M
    }

    -- Check for HM.
    if bossName ~= nil and maxTargetHP ~= nil and hardmodeHealth[bossName] ~= nil then
      if maxTargetHP > hardmodeHealth[bossName] then
        OCH.status.isHMBoss = true
      else
        OCH.status.isHMBoss = false
      end
    end

    if string.match(bossName, OCH.data.jynorahName) then
      OCH.status.isJynorah = true
    elseif string.match(bossName, OCH.data.shaperOfFleshName) then
      OCH.status.isShaperOfFlesh = true
    elseif string.match(bossName, OCH.data.kazpianName) then
      OCH.status.isKazpian = true
    end
  end
end

function OCH.PlayerActivated()
  -- Disable all visible UI elements at startup.
  OCH.UnlockUI(false)

  if GetZoneId(GetUnitZoneIndex("player")) ~= OCH.data.osseinCageId then
    return
  else
    OCH.units = {}
    OCH.unitsTag = {}
  end

  if not OCH.active and not OCH.savedVariables.hideWelcome then
    d(GetString(OCH_InitMSG))
  end
  OCH.active = true
  OCHStatusLabelAddonName:SetText("Ossein Cage Helper " .. OCH.version)

  EVENT_MANAGER:UnregisterForEvent(OCH.name .. "CombatEvent", EVENT_COMBAT_EVENT )
  EVENT_MANAGER:RegisterForEvent(OCH.name .. "CombatEvent", EVENT_COMBAT_EVENT, OCH.CombatEvent)
  
  -- Buffs/debuffs
  EVENT_MANAGER:UnregisterForEvent(OCH.name .. "Buffs", EVENT_EFFECT_CHANGED )
  EVENT_MANAGER:RegisterForEvent(OCH.name .. "Buffs", EVENT_EFFECT_CHANGED, OCH.EffectChanged)
  
  -- Boss change
  EVENT_MANAGER:UnregisterForEvent(OCH.name .. "BossChange", EVENT_BOSSES_CHANGED, OCH.BossesChanged)
  EVENT_MANAGER:RegisterForEvent(OCH.name .. "BossChange", EVENT_BOSSES_CHANGED, OCH.BossesChanged)
  
  -- Combat state
  EVENT_MANAGER:UnregisterForEvent(OCH.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE, OCH.CombatState)
  EVENT_MANAGER:RegisterForEvent(OCH.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE, OCH.CombatState)
  
  -- Death state
  EVENT_MANAGER:UnregisterForEvent(OCH.name .. "DeathState", EVENT_UNIT_DEATH_STATE_CHANGED, OCH.DeathState)
  EVENT_MANAGER:RegisterForEvent(OCH.name .. "DeathState", EVENT_UNIT_DEATH_STATE_CHANGED, OCH.DeathState)
  
  -- Ticks
  EVENT_MANAGER:UnregisterForUpdate(OCH.name.."UpdateTick")
  EVENT_MANAGER:RegisterForUpdate(OCH.name.."UpdateTick", 1000/10, OCH.UpdateTick)
end

function OCH.OnAddonLoaded(event, addonName)
	if addonName ~= OCH.name then
		return
	end

  OCH.savedVariables = ZO_SavedVars:NewAccountWide("OsseinCageHelperSavedVariables", 2, nil, OCH.settings)
  OCH.savedVariablesChar = ZO_SavedVars:NewCharacterIdSettings("OsseinCageHelperSavedVariables", 2, nil, OCH.charSettings)
  OCH.RestorePosition()
  OCH.Menu.AddonMenu()
  SLASH_COMMANDS["/och"] = OCH.CommandLine
  
	EVENT_MANAGER:UnregisterForEvent(OCH.name, EVENT_ADD_ON_LOADED )
	EVENT_MANAGER:RegisterForEvent(OCH.name .. "PlayerActive", EVENT_PLAYER_ACTIVATED,
    OCH.PlayerActivated)
end

EVENT_MANAGER:RegisterForEvent( OCH.name, EVENT_ADD_ON_LOADED, OCH.OnAddonLoaded )
