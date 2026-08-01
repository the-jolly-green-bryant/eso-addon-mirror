-- SAFE MODULE INIT
QDRH = QDRH or {}

-- 🚫 OSI KOMPLETT AUS
if not GetPlayerRoles then
  function GetPlayerRoles()
    local role = nil
    if GetSelectedLFGRole then
      role = GetSelectedLFGRole()
    elseif GetGroupMemberSelectedRole then
      role = GetGroupMemberSelectedRole("player")
    end

    local isDPS = role ~= nil and LFG_ROLE_DPS ~= nil and role == LFG_ROLE_DPS
    local isHeal = role ~= nil and LFG_ROLE_HEAL ~= nil and role == LFG_ROLE_HEAL
    local isTank = role ~= nil and LFG_ROLE_TANK ~= nil and role == LFG_ROLE_TANK
    return isDPS, isHeal, isTank
  end
end
QDRH.Trash = QDRH.Trash or {}
QDRH.Boss = QDRH.Boss or {}
QDRH.Lylanar = QDRH.Lylanar or {}
QDRH.ReefGuardian = QDRH.ReefGuardian or {}
local QDRH = QDRH

QDRH.name     = "QcellDreadsailReefHelper"
QDRH.version  = "2.0.3"
QDRH.author   = "@Qcell"
QDRH.active   = false
QDRH.disableOSIconsByDefault = true

if not CombatAlerts then
  CombatAlerts = {}
  CombatAlerts.__QDRHFallback = true

  function CombatAlerts.Alert(_, message, color, sound, duration)
    if sound then
      PlaySound(sound)
    end
    if d and message ~= nil and message ~= "" then
      d("[QDRH] " .. tostring(message))
    end
  end

  function CombatAlerts.AlertCast(abilityId, sourceName, hitValue, offsets)
    local abilityName = GetAbilityName and GetAbilityName(abilityId) or tostring(abilityId)
    CombatAlerts.Alert("", abilityName, nil, SOUNDS.CHAMPION_POINTS_COMMITTED, hitValue)
  end

  function CombatAlerts.CastAlertsStart(abilityId, message, duration, ...)
    CombatAlerts.Alert("", message or abilityId, nil, nil, duration)
    return 0
  end

  function CombatAlerts.StartBanner(message, abilityName, color, abilityId, ...)
    CombatAlerts.Alert("", message or abilityName or abilityId, color, nil, nil)
    return 0
  end

  function CombatAlerts.DisableBanner(bannerId) end
end

QDRH.status = {
  testStatus = 0,
  inCombat = false,
  
  currentBoss = "",
  isLylanar = false,
  isTurlassil = false,
  isReefGuardian = false,
  isTaleria = false,
  isHMBoss = false,
  hardmodeDetectionComplete = false,
  
  locked = true,
  
  -- Lylanar + Turlassil
  lastDestructiveEmber = 0,
  lastDestructiveEmberPlayer = "@unknown",
  lastPiercingHailstone = 0,
  lastPiercingHailstonePlayer = "@unknown",
  lastBrandMatch = 0,

  lastFireFragilityTime = 0,
  lastFireFragilityPlayer = "@unknown",
  lastIceFragilityTime = 0,
  lastIceFragilityPlayer = "@unknown",

  lastFireImminentTime = 0,
  lastFireImminentPlayer = "@unknown",
  lastIceImminentTime = 0,
  lastIceImminentPlayer = "@unknown",
  lastIncendiaryAxe = 0,
  lastCalamitousSword = 0,
  lastMagmaSpike = 0,
  lastGlacialSpike = 0,
  lylanarGroundMeetingIcon = {},
  lylanarFlameHounds = 0,
  lylanarFrostHounds = 0,
  lylanarFlameHoundIds = {},
  lylanarFrostHoundIds = {},
  lylanarAtronachSummonLast = {},
  lylanarCinderSurgeActive = false,
  turlassilNumbingShardsActive = false,
  lylanarCinderSurgeBanner = 0,
  turlassilNumbingShardsBanner = 0,
  lylanarPhase3StackIcons = {},
  lylanarPhase3HasBegun = false,

  -- TODO: Make use of it if the HM version requires it.
  frostbrandTracker = {},
  firebrandTracker = {},
  lastRuneTime = 0,
  lastFirebrand = 0,
  lastFrostbrand = 0,
  runePlayer1 = "@unknown",
  runePlayer2 = "@unknown",
  
  -- Reef Guardian
  buildingStaticStacks = 0,
  buildingStaticEndTime = 0,
  volatileResidueStacks = 0,
  volatileResidueEndTime = 0,
  stacksUIEnabled = false,
  reefGuardianPortalNum = 0,
  reefGuardianClosedPortals = 0,
  reefGuardianStartTime = 0,
  reefGuardianLastOpenTime = 0,
  reefGuardianLastDoneTime = 0,
  acidicVulnerabilityLast = 0,
  playerSheltered = false,
  lastShelterBuildingStaticCleanse = 0,
  reefGuardianLastHP = {},

  -- It can contain more than 4 values, initialization like this for legacy reasons.
  reefGuardianPortalTimes = {
    [1] = 0,
    [2] = 0,
    [3] = 0,
    [4] = 0,
  }, -- portalTimes[1] = timeSec, time they opened. portalTimes[n%4] -- not more than 4 at a time
  leverIcons = {},
  lastBestGroup = -1,
  reefGuardianStratIcons = {},
  lastCrabCast = {}, -- lastCrabCast[targetUnitId] = time
  heartActiveLastTime = {  -- heartActiveLastTime[1] = time if delta > 60
    [1] = 0,
    [2] = 0,
    [3] = 0,
    [4] = 0,
    [5] = 0,
    [6] = 0,
  },
  heartSuppressUntil = {
    [1] = 0,
    [2] = 0,
    [3] = 0,
    [4] = 0,
    [5] = 0,
    [6] = 0,
  },

  -- Taleria
  lastDeluge = 0, -- global Deluge on anyone
  lastDelugeOnYou = 0,
  delugeTracker = {},
  taleriaPortalNum = 0,
  taleriaLastPlatformFallTime = 0,
  taleriaPortalFinishedNum = 0,
  taleriaPortalTime = {
    [1] = 0,
    [2] = 0,
    [3] = 0,
  },
  taleriaPortalType = {
    [1] = 0,
    [2] = 0,
    [3] = 0,
  },
  taleriaPivotIcon = nil,
  taleriaOppositePivotIcon = nil,
  taleriaSlaughterFishIcons = {},
  taleriaStaticPortalStackIcons = {},
  taleriaBridgeIcons = {},
  taleriaPortalPosIcons = {
    [0] = {}, -- unused
    [1] = {},
    [2] = {},
    [3] = {},
  },
  taleriaClockIcons = {},
  taleriaLastMaelstrom = 0,
  taleriaLastSummonBehemoth = 0,
  taleriaLastStormWall = 0,
  taleriaLastStormWallClockwise = true,
  taleriaBehemothSlamId = 0,
  taleriaBehemothSlam = {
    [0] = 0,
    [1] = 0,
  },
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
QDRH.settings = {
  -- Lylanar
  showImminentCountdown = true,
  showBubbleStacks = true,
  showBubbleCooldown = true,
  showFragilityCountdown = true,
  showRuneIcons = false,
  enableBrandFeature = true,
  showNextAxeSword = true,
  showSpikesCountdown = true,
  soundAlertOnSpikes = true,
  showHinderedIcon = false,
  showMyRuneStack = false,
  showDomeIcon = false,
  showHoundsAlive = false,
  showAtronachSummonAlerts = true,

  -- Reef Guardian
  showPoisonLightningStacks = true,
  showReefTracker = true,
  showReefAlerts = true,
  showGuardiansHP = true,
  showGuardiansGroundIcons = false,
  showKingFireIcon = false,
  showMiniMap = true,
  showAcidRefluxFivePools = false,
  showAcidicVulnerabilityDebuff = false,

  -- Taleria
  showMaelstrom = true,
  showBehemoth = true,
  showWinterStorm = true,
  showNextBridge = true,
  showBridgeTracker = true,
  showBridgeAlerts = true,
  showBubbleBlockAlert = true,
  showDelugeIcons = false,
  showCrashingWave = true,
  showTaleriaInCleave = false, -- false
  showLureOfTheSea = true,
  showLureOfTheSeaIcon = false,
  showBridgePositionIcons = false,
  showMaelstromDodge = true,
  showSlaughterfishIcons = false,
  showTaleriaStaticPortalStackIcons = false,
  showLylanarPhase3StackIcons = false,
  showTaleriaClockIcons = false,
  showSeaBehemothSlams = false,

  -- Trash
  showSwashbucklerTargeted = true,
  showSwashbucklerOnUser = true,
  showSwashbucklerTargetIcon = false,
  showSwashbucklerLoose = true,
  showSwashbucklerAperture = true,
  showLeversPanel = true,
  showLeversIcons = false,
  showBrewmasterPotions = false,

  -- Misc
  uiCustomScale = 1,
  showConsoleIconFallbacks = true,
  enableOSIcons = false,
}
QDRH.units = {}
QDRH.unitsTag = {}
QDRH.bossHealthCache = {}

function QDRH.DisableOSIconSettings()
  if not QDRH.savedVariables or QDRH.savedVariables.enableOSIcons == true then
    return
  end

  QDRH.savedVariables.showRuneIcons = false
  QDRH.savedVariables.showHinderedIcon = false
  QDRH.savedVariables.showMyRuneStack = false
  QDRH.savedVariables.showDomeIcon = false
  QDRH.savedVariables.showGuardiansGroundIcons = false
  QDRH.savedVariables.showKingFireIcon = false
  QDRH.savedVariables.showDelugeIcons = false
  QDRH.savedVariables.showLureOfTheSeaIcon = false
  QDRH.savedVariables.showBridgePositionIcons = false
  QDRH.savedVariables.showSlaughterfishIcons = false
  QDRH.savedVariables.showTaleriaStaticPortalStackIcons = false
  QDRH.savedVariables.showLylanarPhase3StackIcons = false
  QDRH.savedVariables.showTaleriaClockIcons = false
  QDRH.savedVariables.showSwashbucklerTargetIcon = false
  QDRH.savedVariables.showLeversIcons = false
  QDRH.savedVariables.showBrewmasterPotions = false
end

function QDRH.ApplyConsoleDefaults()
  if not QDRH.savedVariables then
    return
  end

  if not QDRH.savedVariables.consoleMiniMapDefaultApplied then
    QDRH.savedVariables.showMiniMap = true
    QDRH.savedVariables.consoleMiniMapDefaultApplied = true
  end
end

function QDRH.EffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType )
  QDRH.IdentifyUnit(unitTag, unitName, unitId)
  local timeSec = GetGameTimeSeconds()
  -- EFFECT_RESULT_GAINED = 1
  -- EFFECT_RESULT_FADED = 2
  -- EFFECT_RESULT_UPDATED = 3

  -- All Trash effect changed events are handled separately.
  QDRH.Trash.EffectChanged(changeType, abilityId, unitTag, beginTime, endTime)

  -- Destructive ember
  if abilityId == QDRH.data.destructive_ember or abilityId == QDRH.data.pre_destructive_ember then
    QDRH.Lylanar.UpdateDestructiveEmber(changeType, stackCount, unitTag)
  end

  -- Piercing Hailstone
  if abilityId == QDRH.data.piercing_hailstone or abilityId == QDRH.data.pre_piercing_hailstone then
    QDRH.Lylanar.UpdatePiercingHailstone(changeType, stackCount, unitTag)
  end

  -- Reef Guardian Building Static
  if (abilityId == QDRH.data.guardian_building_static_boss or abilityId == QDRH.data.guardian_building_static_side_boss) and unitTag == "player" then
    QDRH.ReefGuardian.UpdateBuildingStatic(changeType, stackCount, endTime)
  end

  if (abilityId == QDRH.data.guardian_volatile_residue_boss or abilityId == QDRH.data.guardian_volatile_residue_side_boss) and unitTag == "player" then
    QDRH.ReefGuardian.UpdateVolatileResidue(changeType, stackCount, endTime)
  end

  -- Taleria Deluge
  -- TODO: Move this to CombatEvent, this may be triggering a few times. It's fine for icon updating.
  if abilityId == QDRH.data.taleria_rapid_deluge or abilityId == QDRH.data.taleria_rapid_deluge_hm or abilityId == QDRH.data.taleria_rapid_deluge_normal then
    -- Happens at the start 10s, then 1:36, 2:25, 3:11 ~45s?
    QDRH.Taleria.UpdateRapidDeluge(changeType, unitTag, timeSec)
  end
end

function QDRH.ActivateFirstBossFromEvent(bossName)
  QDRH.status.inCombat = true
  QDRH.status.isLylanar = false
  QDRH.status.isTurlassil = false
  QDRH.status.isReefGuardian = false
  QDRH.status.isTaleria = false

  if bossName == QDRH.data.turlassilName then
    QDRH.status.isTurlassil = true
    QDRH.status.currentBoss = QDRH.data.turlassilName
  else
    QDRH.status.isLylanar = true
    QDRH.status.currentBoss = QDRH.data.lylanarName
  end
end

function QDRH.ActivateTaleriaFromEvent()
  QDRH.status.inCombat = true
  QDRH.status.currentBoss = QDRH.data.taleriaName
  QDRH.status.isLylanar = false
  QDRH.status.isTurlassil = false
  QDRH.status.isReefGuardian = false
  QDRH.status.isTaleria = true
end

function QDRH.CombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)

  if abilityId == QDRH.data.lylanar_imminent_blister then
    QDRH.ActivateFirstBossFromEvent(QDRH.data.lylanarName)
    QDRH.Lylanar.ImminentBlister(result, targetUnitId, targetName)
  end

  if abilityId == QDRH.data.turlassil_imminent_chill then
    QDRH.ActivateFirstBossFromEvent(QDRH.data.turlassilName)
    QDRH.Lylanar.ImminentChill(result, targetUnitId, targetName)
  end
  -- Blistering Fragility
  if abilityId == QDRH.data.lylanar_blistering_fragility then
    QDRH.ActivateFirstBossFromEvent(QDRH.data.lylanarName)
    QDRH.Lylanar.BlisteringFragility(result, targetUnitId, targetName)
  end

  -- Chilling Fragility
  if abilityId == QDRH.data.turlassil_chilling_fragility then
    QDRH.ActivateFirstBossFromEvent(QDRH.data.turlassilName)
    QDRH.Lylanar.ChillingFragility(result, targetUnitId, targetName)
  end

  -- Frigidarium + Magma Spike.
  if result == ACTION_RESULT_BEGIN and abilityId == QDRH.data.turlassil_frigidarium then
    QDRH.Lylanar.Frigidarium()
  end

  if result == ACTION_RESULT_BEGIN and abilityId == QDRH.data.lylanar_magma_spike then
    QDRH.Lylanar.MagmaSpike()
  end

  if abilityId == QDRH.data.lylanar_hindered_effect then
    QDRH.Lylanar.Hindered(result, targetUnitId, hitValue)
  end

  -- Charred Constriction + Glacial Spike
  -- Note this is only the Charred Constriction casted during execute, not the one during the single-boss teleports.
  if result == ACTION_RESULT_BEGIN and abilityId == QDRH.data.lylanar_charred_constriction then
    QDRH.Lylanar.CharredConstriction()
  end

  if result == ACTION_RESULT_BEGIN and abilityId == QDRH.data.turlassil_glacial_spike then
    QDRH.Lylanar.GlacialSpike()
  end

  -- Firebrand/Frostbrand
  if result == ACTION_RESULT_EFFECT_GAINED_DURATION and abilityId == QDRH.data.lylanar_firebrand_player_debuff and hitValue == 5000 then
    QDRH.Lylanar.Firebrand(targetUnitId, targetName, GetGameTimeSeconds())
  end

  if result == ACTION_RESULT_EFFECT_GAINED_DURATION and abilityId == QDRH.data.turlassil_frostbrand_player_debuff and hitValue == 5000 then
    QDRH.Lylanar.Frostbrand(targetUnitId, targetName, GetGameTimeSeconds())
  end

  if result == ACTION_RESULT_BEGIN and abilityId == QDRH.data.lylanar_incendiary_axe then
    QDRH.Lylanar.IncendiaryAxe()
  end

  if result == ACTION_RESULT_BEGIN and abilityId == QDRH.data.turlassil_calamitous_sword then
    QDRH.Lylanar.CalamitousSword()
  end

  if result == ACTION_RESULT_EFFECT_GAINED_DURATION and abilityId == QDRH.data.lylanar_scalding_swell then
    QDRH.Lylanar.ScaldingSwell()
  end

  if result == ACTION_RESULT_EFFECT_GAINED_DURATION and abilityId == QDRH.data.turlassil_biting_billow then
    QDRH.Lylanar.BitingBillow()
  end

  -- This event triggers 3x when spawning 3 dogs.
  if result == ACTION_RESULT_EFFECT_GAINED_DURATION and abilityId == QDRH.data.summon_flame_hound then
    QDRH.ActivateFirstBossFromEvent(QDRH.data.lylanarName)
    QDRH.Lylanar.SummonFlameHound(targetUnitId)
  end

  if result == ACTION_RESULT_EFFECT_GAINED_DURATION and abilityId == QDRH.data.summon_frost_hound then
    QDRH.ActivateFirstBossFromEvent(QDRH.data.turlassilName)
    QDRH.Lylanar.SummonFrostHound(targetUnitId)
  end

  if (result == ACTION_RESULT_EFFECT_GAINED or result == ACTION_RESULT_BEGIN) then
    if QDRH.data.lylanar_summon_iron_atronach[abilityId] then
      QDRH.ActivateFirstBossFromEvent(QDRH.data.lylanarName)
      QDRH.Lylanar.SummonAtronach("iron", abilityId, abilityName, result, sourceName, targetName, hitValue)
    elseif QDRH.data.lylanar_summon_frost_atronach[abilityId] then
      QDRH.ActivateFirstBossFromEvent(QDRH.data.turlassilName)
      QDRH.Lylanar.SummonAtronach("frost", abilityId, abilityName, result, sourceName, targetName, hitValue)
    end
  end

  if result == ACTION_RESULT_DIED then
    QDRH.Lylanar.HoundDied(targetUnitId)
  end

  if abilityId == QDRH.data.lylanar_cinder_surge then
    QDRH.Lylanar.CinderSurge(result)
  end

  if abilityId == QDRH.data.turlassil_numbing_shards then
    QDRH.Lylanar.NumbingShards(result)
  end

  -- Reef Guardian
  -- Reef Guardian casting Heartburn on Reef Heart
  if result == ACTION_RESULT_BEGIN and abilityId == QDRH.data.guardian_heartburn then
    QDRH.ReefGuardian.OpenReef()
  end

  if result == ACTION_RESULT_EFFECT_FADED and abilityId == QDRH.data.guardian_heartburn then
    QDRH.ReefGuardian.ReefDone()
  end

  if abilityId == QDRH.data.guardian_acidic_vulnerability and targetType == COMBAT_UNIT_TYPE_PLAYER then
    QDRH.ReefGuardian.UpdateAcidicVulnerability(result, hitValue)
  end

  if abilityId == QDRH.data.guardian_sheltered and targetType == COMBAT_UNIT_TYPE_PLAYER then
    QDRH.ReefGuardian.UpdateSheltered(result)
  end

  if result == ACTION_RESULT_BEGIN and (
    abilityId == QDRH.data.guardian_crab_monstrous_claw or 
    abilityId == QDRH.data.guardian_crab_swipe or 
    abilityId == QDRH.data.guardian_crab_water_jet) then
    QDRH.status.lastCrabCast[targetUnitId] = GetGameTimeSeconds()
  end

  -- Taleria identify tank, only if it's someone else.
  if result == ACTION_RESULT_BEGIN and (
    abilityId == QDRH.data.taleria_barnacle_blade
    or abilityId == QDRH.data.taleria_coral_slam
    or abilityId == QDRH.data.olms_swipe) then
    if abilityId ~= QDRH.data.olms_swipe then
      QDRH.ActivateTaleriaFromEvent()
    end
    if targetUnitId ~= nil and QDRH.units[targetUnitId] ~= nil then
      QDRH.status.mainTankTag = QDRH.units[targetUnitId].tag
      --d("[QDRH] Tank updated to " .. QDRH.units[targetUnitId].name .. "(tag = " .. QDRH.status.mainTankTag .. ")")
    end
  end

  -- Taleria Maelstrom
  if result == ACTION_RESULT_BEGIN and abilityId == QDRH.data.taleria_maelstrom_ability and hitValue > 1000 then
    QDRH.ActivateTaleriaFromEvent()
    -- 0s,   BEGIN         Maelstrom (166292) [500] (a)
    -- 0.5s, EFFECT_GAINED Maelstrom (166292) [1]   (b)
    -- 0.5s, BEGIN         Maelstrom (166292) [6000](c)
    -- Note: We start tracking 0.5s late (c) intentionally, when the damage actually begins.
    -- The CCA alert is thrown 0.5s before. (a)
    -- It is cast 3x second when it starts, for 20 ticks. Just consider it if previous cast > 10s
    -- Note that crashing waves may delay next Maelstrom.
    QDRH.status.taleriaLastMaelstrom = GetGameTimeSeconds()
  end

  -- Not tracking Bridge fails anymore, what's the point if we're wiping anyway.

  if result == ACTION_RESULT_BEGIN and abilityId == QDRH.data.taleria_summon_behemoth then
    QDRH.ActivateTaleriaFromEvent()
    QDRH.Taleria.SummonSeaBehemoth()
  end

  if result == ACTION_RESULT_BEGIN and abilityId == QDRH.data.taleria_behemoth_arctic_annihilation then
    QDRH.ActivateTaleriaFromEvent()
    QDRH.Taleria.ArcticAnnihilation()
  end

  if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER and (abilityId == QDRH.data.taleria_behemoth_crush or abilityId == QDRH.data.taleria_behemoth_hack or abilityId == QDRH.data.taleria_behemoth_strike) then
    CombatAlerts.AlertCast(abilityId, sourceName, hitValue, {-2, 1})
  end

  -- Taleria Winter Storm (wall)
  if result == ACTION_RESULT_EFFECT_GAINED and abilityId == QDRH.data.taleria_storm_wall_cw then
      QDRH.ActivateTaleriaFromEvent()
      -- Winter storm (wall) cast. Update direction icon.
      QDRH.status.taleriaLastStormWall = GetGameTimeSeconds()
      QDRH.status.taleriaLastStormWallClockwise = true
  end

  if result == ACTION_RESULT_EFFECT_GAINED and abilityId == QDRH.data.taleria_storm_wall_ccw then
      QDRH.ActivateTaleriaFromEvent()
      QDRH.status.taleriaLastStormWall = GetGameTimeSeconds()
      QDRH.status.taleriaLastStormWallClockwise = false
  end

  -- Taleria Portal
  -- Death Trigger (it's called like that, nothing to do with death)
  -- Triggers once with hitValue = 0 and once with hitValue=1. Both times ACTION_RESULT_EFFECT_GAINED.

  -- Open portal. Timer has not started yet.
  if abilityId == QDRH.data.taleria_dreadsail_venom_evoker and hitValue == 1 then
    QDRH.ActivateTaleriaFromEvent()
    QDRH.Taleria.OpenPortalVenomEvoker()
  end

  if abilityId == QDRH.data.taleria_dreadsail_sea_boiler and hitValue == 1 then
    QDRH.ActivateTaleriaFromEvent()
    QDRH.Taleria.OpenPortalSeaBoiler()
  end

  if abilityId == QDRH.data.taleria_dreadsail_tidal_mage and hitValue == 1 then
    QDRH.ActivateTaleriaFromEvent()
    QDRH.Taleria.OpenPortalTidalMage()
  end

  -- Start portal. Debuff and timer start now.
  -- TODO: Check if duration is 60s in every difficulty.
  if(
    abilityId == QDRH.data.taleria_dreadsail_venom_evoker_nematocyst_cloud or
    abilityId == QDRH.data.taleria_dreadsail_sea_boiler_sweltering_heat or
    abilityId == QDRH.data.taleria_dreadsail_tidal_mage_suffocating_waves
    )then

      if result == ACTION_RESULT_BEGIN then
        QDRH.ActivateTaleriaFromEvent()
        QDRH.Taleria.StartPortal()
      elseif result == ACTION_RESULT_EFFECT_FADED then
        -- I could tell exactly which portal closed, in case they do not close in order.
        QDRH.Taleria.PortalDone()
      end
  end

  -- Buffs from people in portal or people in the island staying in the circle.
  if hitValue == 0 and targetType == COMBAT_UNIT_TYPE_PLAYER and (
    abilityId == QDRH.data.taleria_dreadsail_venom_evoker_nematocyst_cloud_portal or
    abilityId == QDRH.data.taleria_dreadsail_venom_evoker_nematocyst_cloud_aoe or
    abilityId == QDRH.data.taleria_dreadsail_sea_boiler_sweltering_heat_portal or
    abilityId == QDRH.data.taleria_dreadsail_sea_boiler_sweltering_heat_aoe or
    abilityId == QDRH.data.taleria_dreadsail_tidal_mage_suffocating_waves_portal or
    abilityId == QDRH.data.taleria_dreadsail_tidal_mage_suffocating_waves_aoe) then
    -- GAINED -> true. FADED -> false.
    QDRH.status.debuffTracker[abilityId] = (result == ACTION_RESULT_EFFECT_GAINED)
  end

  -- TODO: Track individual people's debuff rather than Island/Landed boss debuffs.
  -- TODO: Better approach: debuff[abilityId] = true
  --       When rendering check that debuff[ability_debuff_1] or debuff[ability_debuff_3] or debuff[ability_debuff_3]

  -- TODO: Delete old PortalDone() logic using icy escape (event 2s after the actual closure)
  -- Note: This also triggers when there's a portal fail. Technically, it is "done".
  --[[if result == ACTION_RESULT_EFFECT_GAINED and abilityId == QDRH.data.taleria_portal_done then
    QDRH.Taleria.PortalDone()
  end--]]

  -- For PLAYER CCA already shows it (on MT)
  if abilityId == QDRH.data.taleria_crashing_wave_boss and targetType ~= COMBAT_UNIT_TYPE_PLAYER then
    QDRH.Taleria.CrashingWave(abilityId, sourceName, hitValue)
  end

  if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER and abilityId == QDRH.data.taleria_matron_lure_of_the_sea then
    QDRH.Taleria.LureOfTheSea()
  end

  if result == ACTION_RESULT_BEGIN and abilityId == QDRH.data.taleria_matron_lure_of_the_sea then
    QDRH.Taleria.LureOfTheSeaIcon(targetUnitId)
  end

  if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER and abilityId == QDRH.data.taleria_sea_boiler_aspect_of_terror then
    QDRH.Taleria.AspectOfTerror(sourceName, hitValue)
  end

  -- TODO: Remove duplicates from code's. bear will be added soon
  -- Player targetted melee heavy attacks
  -- Various heavy attacks (list cleared after Combat Alerts CCA has them)
  if targetType == COMBAT_UNIT_TYPE_PLAYER and abilityId == QDRH.data.bow_breaker_horn_strike_1 then
    -- -2: melee alert
    -- 2: only do ping alert on DDs to dodge it
    CombatAlerts.AlertCast(abilityId, sourceName, hitValue, {-2, 2})
  end

  -- King Orgnum's Fire: Reef Guardian HM projectile health debuff.
  --[[if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER and abilityId == QDRH.data.guardian_king_orgnum_fire then
    -- real hitValue is 200 + EFFECT_GAINED 1250 and {DAMAGE} after 1450
    CombatAlerts.AlertCast(abilityId, sourceName, 1500, {-3, 1})
  end--]]

  if abilityId == QDRH.data.guardian_king_orgnum_fire_debuff then
    -- hitValue is 20000
    if QDRH.savedVariables.showKingFireIcon or not QDRH.hasOSI() then
      QDRH.ReefGuardian.KingOrgnumFire(result, hitValue, targetUnitId)
    end
  end

  -- Progress bar for Acid Reflux.
  if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER and abilityId == QDRH.data.guardian_acid_reflux and hitValue == 10000 then
    -- CombatAlerts.CastAlertsStart(abilityId, abilityName, hitValue, nil, nil, nil)
    QDRH.ReefGuardian.AcidReflux()
  end

  -- Light/heavy attacks (1.5s windup) alert for non-tanks.
  if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER and (
    abilityId == QDRH.data.guardian_crush or 
    abilityId == QDRH.data.guardian_claw) then
    local isDPS, isHeal, isTank = GetPlayerRoles()
    if not isTank then
      CombatAlerts.AlertCast(abilityId, sourceName, hitValue, {-2, 2})
    end
  end
  
--[[  -- Bombard. Light attacks from the Reef Guardian HM mage.
  if targetType == COMBAT_UNIT_TYPE_PLAYER and abilityId == 175834 then
    CombatAlerts.AlertCast(abilityId, sourceName, hitValue, {-3, 1})
  end--]]

  -- Player targetted ranged heavy attacks
  if targetType == COMBAT_UNIT_TYPE_PLAYER and abilityId == QDRH.data.bow_breaker_toxic_mucus then
    -- -3: ranged alert
    CombatAlerts.AlertCast(abilityId, sourceName, hitValue, {-3, 2})
  end

  if targetType == COMBAT_UNIT_TYPE_PLAYER and result == ACTION_RESULT_EFFECT_GAINED and abilityId == QDRH.data.sail_ripper_storm_cell then
    -- lasts forever. do NOT use hitValue
    -- May fire twice, needs testing.
    CombatAlerts.Alert("", abilityName .. " (you)", 0xFFD666FF, SOUNDS.CHAMPION_POINTS_COMMITTED, 5000)
  end
end

function QDRH.UpdateSlowTick(gameTimeMs)
  if IsUnitInCombat("player") then return end
  if not QDRH or not QDRH.Trash then return end

  local timeSec = GetGameTimeSeconds()
  local reefPortalActive = QDRH.status.isReefGuardian and
    QDRH.ReefGuardian.HasActivePortalTimer ~= nil and
    QDRH.ReefGuardian.HasActivePortalTimer(timeSec)
  if reefPortalActive then
    return
  end

  local trash = QDRH.Trash

  if type(trash.ShouldDisplayLevers) == "function" and trash.ShouldDisplayLevers() then
    if type(trash.RenderLevers) == "function" then
      trash.RenderLevers()
    end
  else
    if type(trash.ResetLeversState) == "function" then
      trash.ResetLeversState()
    end

    if QDRHStatus and QDRHStatus.SetHidden and QDRH.status 
       and not QDRH.status.stacksUIEnabled and QDRH.status.locked then
      QDRHStatus:SetHidden(true)
    end
  end
end

function QDRH.AnyBossInCombat()
  if IsUnitInCombat == nil then
    return false
  end

  for i = 1, (BOSS_RANK_ITERATION_END or MAX_BOSSES or 6) do
    if IsUnitInCombat("boss" .. tostring(i)) then
      return true
    end
  end

  return false
end

function QDRH.IsFirstBossName(unitName)
  if unitName == nil or unitName == "" then
    return false
  end

  local lowerName = string.lower(unitName)
  return string.find(lowerName, "lylanar", 1, true) ~= nil or
    string.find(lowerName, "turlassil", 1, true) ~= nil
end

function QDRH.IsFirstBossUnit(unitTag)
  if unitTag == nil or string.sub(unitTag, 1, 4) ~= "boss" then
    return false
  end

  local unitName = GetUnitName(unitTag)
  if (unitName == nil or unitName == "") and
    QDRH.bossHealthCache ~= nil and QDRH.bossHealthCache[unitTag] ~= nil then
    unitName = QDRH.bossHealthCache[unitTag].name
  end

  if QDRH.IsFirstBossName(unitName) then
    return true
  end

  return (QDRH.status.isLylanar or QDRH.status.isTurlassil) and
    (unitTag == "boss1" or unitTag == "boss2")
end

function QDRH.FirstBossStillActive()
  for i = 1, (BOSS_RANK_ITERATION_END or MAX_BOSSES or 6) do
    local unitTag = "boss" .. tostring(i)
    if QDRH.IsFirstBossUnit(unitTag) then
      local currentHP, maxHP = GetUnitPower(unitTag, POWERTYPE_HEALTH)
      if IsUnitDead ~= nil and IsUnitDead(unitTag) then
        -- dead boss tag, ignore it
      elseif IsUnitInCombat ~= nil and IsUnitInCombat(unitTag) then
        return true
      elseif currentHP ~= nil and maxHP ~= nil and maxHP > 0 and currentHP > 0 then
        return true
      end
    end
  end

  return false
end

function QDRH.UpdateTick(gameTimeMs)
  local timeSec = GetGameTimeSeconds()

  if IsUnitInCombat("boss1") or IsUnitInCombat("player") then
    if not QDRH.status.inCombat then
      -- If it switched from non-combat to combat, re-check boss names.
    end
    QDRH.status.inCombat = true
  end
  
  -- First boss comes a bit after the adds. Dreadsail specific logic.
  if IsUnitInCombat("player") and QDRH.status.isLylanar then
    QDRH.status.inCombat = true
  end

  -- Refresh the Lightning/Poison panel even out of combat, if it has any stacks.
  if QDRH.status.stacksUIEnabled then
    QDRH.ReefGuardian.UpdateStacks(timeSec)
  end
  
  if QDRH.status.inCombat == false then
    return
  end

  -- Boss HP can arrive after EVENT_BOSSES_CHANGED. Retry HM detection until
  -- a usable maximum health value is available.
  if QDRH.status.currentBoss ~= "" and not QDRH.status.hardmodeDetectionComplete then
    QDRH.UpdateHardmodeStatus(QDRH.status.currentBoss)
  end

  local reefPortalActive = QDRH.ReefGuardian.HasActivePortalTimer ~= nil and
    QDRH.ReefGuardian.HasActivePortalTimer(timeSec)

  if (QDRH.status.isReefGuardian or QDRH.status.isTaleria) and
    not reefPortalActive and not IsUnitInCombat("player") and not QDRH.AnyBossInCombat() then
    QDRH.ClearUIOutOfCombat()
    return
  end

  if not QDRH.status.isLylanar and not QDRH.status.isTurlassil and
    not QDRH.status.isReefGuardian and not QDRH.status.isTaleria then
    local bossName = QDRH.GetBossName()
    if bossName ~= nil and bossName ~= "" then
      QDRH.BossesChanged()
    end
  end
  
  local lylanarTimerActive = QDRH.Lylanar ~= nil and QDRH.Lylanar.HasActiveTimer ~= nil and
    QDRH.Lylanar.HasActiveTimer(timeSec)

  if (QDRH.status.isLylanar or QDRH.status.isTurlassil) and
    not IsUnitInCombat("player") and not QDRH.FirstBossStillActive() then
    QDRH.ClearUIOutOfCombat()
    return
  end

  -- Boss 1: Lylanar + Turlassil
  if QDRH.status.isLylanar or QDRH.status.isTurlassil or
    (lylanarTimerActive and not QDRH.status.isReefGuardian and not QDRH.status.isTaleria) then
    QDRH.HideBossSpecificUI("lylanar")
    QDRH.Lylanar.UpdateTick(timeSec)
  end
  
  -- Boss 2: The Reef Guardian
  if QDRH.status.isReefGuardian then
    QDRH.HideBossSpecificUI("reef")
    QDRH.ReefGuardian.UpdateTick(timeSec)
  end
  
  -- Boss 3: Tideborn Taleria
  if QDRH.status.isTaleria then
    QDRH.HideBossSpecificUI("taleria")
    QDRH.Taleria.UpdateTick(timeSec)
  end
end

function QDRH.ScheduleClearUIWhen(updateName, shouldClear)
  local startMs = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or (GetGameTimeSeconds() * 1000)
  EVENT_MANAGER:UnregisterForUpdate(updateName)
  EVENT_MANAGER:RegisterForUpdate(updateName, 500, function()
    local nowMs = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or (GetGameTimeSeconds() * 1000)
    if shouldClear() then
      EVENT_MANAGER:UnregisterForUpdate(updateName)
      QDRH.ClearUIOutOfCombat()
      return
    end

    if nowMs - startMs > 6000 then
      EVENT_MANAGER:UnregisterForUpdate(updateName)
    end
  end)
end

function QDRH.DeathState(event, unitTag, isDead)
  if isDead and (QDRH.status.isLylanar or QDRH.status.isTurlassil) and
    QDRH.IsFirstBossUnit(unitTag) then
    QDRH.ScheduleClearUIWhen(QDRH.name .. "FirstBossDeathClear", function()
      return (QDRH.status.isLylanar or QDRH.status.isTurlassil) and
        not QDRH.FirstBossStillActive()
    end)
    return
  end

  if isDead and QDRH.status.isReefGuardian and unitTag ~= nil and
    string.sub(unitTag, 1, 4) == "boss" then
    QDRH.ScheduleClearUIWhen(QDRH.name .. "ReefGuardianDeathClear", function()
      local timeSec = GetGameTimeSeconds()
      local reefPortalActive = QDRH.ReefGuardian.HasActivePortalTimer ~= nil and
        QDRH.ReefGuardian.HasActivePortalTimer(timeSec)
      return QDRH.status.isReefGuardian and not reefPortalActive and
        not QDRH.AnyBossInCombat()
    end)
    return
  end

  if isDead and QDRH.status.isTaleria and unitTag ~= nil and
    string.sub(unitTag, 1, 4) == "boss" then
    local unitName = GetUnitName(unitTag)
    if (unitName == nil or unitName == "") and
      QDRH.bossHealthCache ~= nil and QDRH.bossHealthCache[unitTag] ~= nil then
      unitName = QDRH.bossHealthCache[unitTag].name
    end

    local lowerName = unitName ~= nil and string.lower(unitName) or ""
    if unitTag == "boss1" or string.find(lowerName, "taleria", 1, true) ~= nil then
      QDRH.ClearUIOutOfCombat()
      return
    end
  end

  if unitTag == "player" and not isDead and not IsUnitInCombat("boss1") then
    -- I just resurrected, and it was a wipe or we killed the boss.
    -- Remove all UI
    QDRH.ClearUIOutOfCombat()
  end
  -- TODO: Remove from the list of "players in portal" in boss 1 and boss 2.
end

function QDRH.BossPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
  if unitTag == nil or string.sub(unitTag, 1, 4) ~= "boss" then
    return
  end

  QDRH.bossHealthCache = QDRH.bossHealthCache or {}
  QDRH.bossHealthCache[unitTag] = {
    current = powerValue,
    max = powerMax,
    effectiveMax = powerEffectiveMax,
    name = GetUnitName(unitTag),
    time = GetGameTimeSeconds(),
  }

  if QDRH.status.currentBoss ~= "" and not QDRH.status.hardmodeDetectionComplete then
    QDRH.UpdateHardmodeStatus(QDRH.status.currentBoss)
  end

end

function QDRH.CombatState(eventCode, inCombat)
  local timeSec = GetGameTimeSeconds()
  local reefPortalActive = QDRH.status.isReefGuardian and
    QDRH.ReefGuardian.HasActivePortalTimer ~= nil and
    QDRH.ReefGuardian.HasActivePortalTimer(timeSec)

  if not inCombat and not QDRH.AnyBossInCombat() then
    if reefPortalActive then
      QDRH.status.inCombat = true
      return
    end
    QDRH.ClearUIOutOfCombat()
    return
  end

  local bossPercent = QDRH.GetBossHealthPercentByName(nil)
  -- Do not change combat state if you are dead, or the boss is not full.

  -- Do not do anything outside of boss fights.
  if bossPercent == nil then
    if reefPortalActive then
      QDRH.status.inCombat = true
      return
    end
    QDRH.ClearUIOutOfCombat()
    return
  end
  if bossPercent < 0.99 or IsUnitDead("player") then
    return
  end
  if inCombat then
    QDRH.status.inCombat = true
    QDRH.ResetStatus()
  elseif reefPortalActive then
    QDRH.status.inCombat = true
  else
    QDRH.ClearUIOutOfCombat()
  end
end

function QDRH.ResetStatus()
  -- Boss 1
  EVENT_MANAGER:UnregisterForUpdate(QDRH.name .. "CinderSurge")
  EVENT_MANAGER:UnregisterForUpdate(QDRH.name .. "MatchBrands")
  if QDRH.Lylanar ~= nil then
    if QDRH.Lylanar.RemoveLylanarPhase3StackIcons ~= nil then
      QDRH.Lylanar.RemoveLylanarPhase3StackIcons()
    end
  end
  QDRH.status.lastDestructiveEmber = 0
  QDRH.status.lastPiercingHailstone = 0
  QDRH.status.lastBrandMatch = 0
  QDRH.status.lastFireFragilityTime = 0
  QDRH.status.lastIceFragilityTime = 0
  QDRH.status.lastFireImminentTime = 0
  QDRH.status.lastIceImminentTime = 0
  QDRH.status.lastIncendiaryAxe = 0
  QDRH.status.lastCalamitousSword = 0
  QDRH.status.lastMagmaSpike = 0
  QDRH.status.lastGlacialSpike = 0
  QDRH.status.lastRuneTime = 0
  QDRH.status.lastFirebrand = 0
  QDRH.status.lastFrostbrand = 0
  QDRH.status.lastFireFragilityPlayer = "@unknown"
  QDRH.status.lastIceFragilityPlayer = "@unknown"
  QDRH.status.lastFireImminentPlayer = "@unknown"
  QDRH.status.lastIceImminentPlayer = "@unknown"
  QDRH.status.frostbrandTracker = {}
  QDRH.status.firebrandTracker = {}
  QDRH.status.lylanarFlameHounds = 0
  QDRH.status.lylanarFrostHounds = 0
  QDRH.status.lylanarFlameHoundIds = {}
  QDRH.status.lylanarFrostHoundIds = {}
  QDRH.status.lylanarAtronachSummonLast = {}
  QDRH.bossHealthCache = {}
  QDRH.status.lylanarCinderSurgeActive = false
  QDRH.status.turlassilNumbingShardsActive = false
  QDRH.status.lylanarPhase3HasBegun = false
  -- TODO: Move to a method.
  if CombatAlerts.DisableBanner then
    if QDRH.status.lylanarCinderSurgeBanner ~= 0 then
      CombatAlerts.DisableBanner(QDRH.status.lylanarCinderSurgeBanner)
    end
    if QDRH.status.turlassilNumbingShardsBanner ~= 0 then
      CombatAlerts.DisableBanner(QDRH.status.turlassilNumbingShardsBanner)
    end
  end
  QDRH.status.lylanarCinderSurgeBanner = 0
  QDRH.status.turlassilNumbingShardsBanner = 0

  -- Boss 2
  QDRH.status.buildingStaticStacks = 0
  QDRH.status.buildingStaticEndTime = 0
  QDRH.status.volatileResidueStacks = 0
  QDRH.status.volatileResidueEndTime = 0
  QDRH.status.stacksUIEnabled = false
  QDRH.status.reefGuardianPortalNum = 0
  QDRH.status.reefGuardianClosedPortals = 0
  QDRH.status.reefGuardianLastOpenTime = 0
  QDRH.status.reefGuardianLastDoneTime = 0
  QDRH.status.acidicVulnerabilityLast = 0
  QDRH.status.playerSheltered = false
  QDRH.status.lastShelterBuildingStaticCleanse = 0
  QDRH.status.reefGuardianLastHP = {}
  QDRH.status.reefGuardianPortalTimes = {
    [1] = 0,
    [2] = 0,
    [3] = 0,
    [4] = 0,
  }
  QDRH.status.lastBestGroup = -1 -- no best group
  QDRH.status.reefGuardianStartTime = 0
  QDRH.status.lastCrabCast = {}
  QDRH.status.heartActiveLastTime = {
    [1] = 0,
    [2] = 0,
    [3] = 0,
    [4] = 0,
    [5] = 0,
    [6] = 0,
  }
  QDRH.status.heartSuppressUntil = {
    [1] = 0,
    [2] = 0,
    [3] = 0,
    [4] = 0,
    [5] = 0,
    [6] = 0,
  }

  -- Boss 3
  QDRH.status.taleriaPortalNum = 0
  QDRH.status.taleriaLastPlatformFallTime = 0
  QDRH.status.taleriaPortalFinishedNum = 0
  QDRH.status.taleriaLastMaelstrom = 0
  QDRH.status.taleriaLastSummonBehemoth = 0
  QDRH.status.taleriaLastStormWall = 0
  QDRH.status.taleriaBehemothSlamId = 0
  QDRH.status.taleriaBehemothSlam = {
    [0] = 0,
    [1] = 0,
  }
  QDRH.status.taleriaPortalTime = {
    [1] = 0,
    [2] = 0,
    [3] = 0,
  }
  QDRH.status.taleriaPortalType = {
    [1] = 0,
    [2] = 0,
    [3] = 0,
  }
  QDRH.status.debuffTracker = {}
  --QDRH.Taleria.RemoveAllBridgeIcons() -- already resets QDRH.status.taleriaBridgeIcons = {},
  --QDRH.Taleria.DiscardAllPortalPosIcons() -- already resets QDRH.status.taleriaPortalPosIcons = {}
  QDRH.Taleria.DiscardTaleriaClock() -- already resets QDRH.status.taleriaClockIcons = {}
  QDRH.status.unitDamageTaken = {}

  QDRH.status.mainTankTag = ""
  QDRH.status.lastDeluge = 0
end

function QDRH.GetBossName()

  QDRH.lastBossName = QDRH.lastBossName or ""

  local function getKnownBossName(rawName)
    if rawName == nil or rawName == "" then
      return nil
    end

    local name = string.lower(rawName)
    if name:find("lylanar") then
      return QDRH.data.lylanarName
    end
    if name:find("turlassil") then
      return QDRH.data.turlassilName
    end
    if name:find("reef") or name:find("guardian") or name:find("riff") then
      return QDRH.data.reefGuardianName
    end
    if name:find("taleria") then
      return QDRH.data.taleriaName
    end

    return nil
  end

  for i = 1, (BOSS_RANK_ITERATION_END or MAX_BOSSES or 6) do
    local bossTag = "boss" .. tostring(i)
    local rawName = GetUnitName(bossTag)
    if (rawName == nil or rawName == "") and
      QDRH.bossHealthCache ~= nil and QDRH.bossHealthCache[bossTag] ~= nil then
      rawName = QDRH.bossHealthCache[bossTag].name
    end
    local bossName = getKnownBossName(rawName)
    if bossName ~= nil then
      QDRH.lastBossName = bossName
      return QDRH.lastBossName
    end
  end

  -- No active boss tag is visible. Returning empty lets add phases clear old boss UI.
  return ""
end

function QDRH.UpdateHardmodeStatus(bossName)
  local hardmodeHealth = {
    [QDRH.data.lylanarName] = 50000000,
    [QDRH.data.turlassilName] = 50000000,
    [QDRH.data.reefGuardianName] = 40000000,
    [QDRH.data.taleriaName] = 150000000,
  }

  local threshold = hardmodeHealth[bossName]
  if threshold == nil then
    return false
  end

  local _, bossTag, _, _, maxTargetHP = QDRH.GetBossHealthPercentByName(bossName)
  if bossTag ~= nil then
    local _, unitMaxHP = GetUnitPower(bossTag, POWERTYPE_HEALTH)
    if unitMaxHP ~= nil and unitMaxHP > 0 then
      maxTargetHP = unitMaxHP
    end
  end

  if (maxTargetHP == nil or maxTargetHP <= 0) and bossTag ~= nil and
    QDRH.bossHealthCache ~= nil and QDRH.bossHealthCache[bossTag] ~= nil then
    maxTargetHP = QDRH.bossHealthCache[bossTag].max
  end

  if maxTargetHP == nil or maxTargetHP <= 0 then
    return false
  end

  QDRH.status.isHMBoss = maxTargetHP > threshold
  QDRH.status.hardmodeDetectionComplete = true
  return true
end

function QDRH.BossesChanged()
  --local bossName = string.lower(GetUnitName("boss1"))
  local bossName = QDRH.GetBossName()
  local previousBossName = QDRH.status.currentBoss

  if bossName ~= nil then
    if QDRH.status.currentBoss == QDRH.data.taleriaName and bossName == "" then
      -- Taleria drops out of boss tags during bridge moments; keep her UI active.
      bossName = QDRH.data.taleriaName
    elseif QDRH.status.currentBoss == QDRH.data.reefGuardianName and bossName == "" and
      (IsUnitInCombat("player") or QDRH.AnyBossInCombat()) then
      -- Reef Guardian boss tags can flicker during portal/add moments; keep UI stable mid-fight.
      bossName = QDRH.data.reefGuardianName
    else
      if bossName ~= QDRH.status.currentBoss then
        --d("[QDRH] Boss change. Name = " .. bossName)
      end
      QDRH.status.currentBoss = bossName
    end
    if bossName ~= previousBossName then
      QDRH.HideBossSpecificUI(nil)
    end
    
    QDRH.status.isLylanar = false
    QDRH.status.isTurlassil = false
    QDRH.status.isReefGuardian = false
    QDRH.status.isTaleria = false
    QDRH.status.isHMBoss = false
    QDRH.status.hardmodeDetectionComplete = false

    --QDRH.Lylanar.RemoveLylanarPhase3StackIcons()

    --QDRH.Taleria.RemovePivotIcon()
    --QDRH.Taleria.RemoveOppositePivotIcon()
    --QDRH.Taleria.RemoveSlaughterFishIcons()
    --QDRH.Taleria.RemoveStaticPortalStackIcons()
    --QDRH.Taleria.DiscardTaleriaClock()

    -- Check for HM. Boss HP may not be available on the first boss-change event.
    QDRH.UpdateHardmodeStatus(bossName)

    if string.match(bossName, QDRH.data.lylanarName) then
      QDRH.status.isLylanar = true
    end
    if string.match(bossName, QDRH.data.turlassilName) then
      QDRH.status.isTurlassil = true
    end
    if string.match(bossName, QDRH.data.reefGuardianName) then
      QDRH.status.isReefGuardian = true
      -- Only draw if the boss changed, or it keeps re-drawing in the Reef Guardian fight.
      if QDRH.status.isHMBoss then 
        --QDRH.ReefGuardian.DrawStratIcons()
      end
    else
      --QDRH.ReefGuardian.ClearStratIcons()
    end
    if string.match(bossName, QDRH.data.taleriaName) then
      QDRH.status.isTaleria = true
      --QDRH.Taleria.AddPivotIcon()
      -- TODO: Move to HM-only?
      --QDRH.Taleria.AddSlaughterFishIcons()
      if QDRH.status.isHMBoss then
        --QDRH.Taleria.AddOppositePivotIcon()
        --QDRH.Taleria.ShowStaticPortalStackIcons()
        --QDRH.Taleria.AddTaleriaClock()
      end
    end
  end
end

function QDRH.PlayerActivated()
  -- Disable all visible UI elements at startup.
  --QDRH.HideAllUI(true)
  QDRH.UnlockUI(false)

  if GetZoneId(GetUnitZoneIndex("player")) ~= QDRH.data.dreadsailReefId then
    return
  else
    QDRH.units = {}
    QDRH.unitsTag = {}
    QDRH.bossHealthCache = {}
  end

  -- Fix for stacks when PTEing with stacks
  QDRH.status.volatileResidueStacks = 0
  QDRH.status.volatileResidueEndTime = 0
  QDRH.status.buildingStaticStacks = 0
  QDRH.status.buildingStaticEndTime = 0
  QDRH.status.stacksUIEnabled = false

  if not QDRH.active and not QDRH.savedVariables.hideWelcome then
    d("|cFF6200[QDRH] Thanks for using Qcell's Dreadsail Reef Helper " .. QDRH.version ..".|r Please send issues on discord Qcell#0001")
  end
  QDRH.active = true
  QDRHStatusLabelAddonName:SetText("Dreadsail Reef Helper " .. QDRH.version)
  if QDRH.WarmupConsoleMarkerTextures then
    QDRH.WarmupConsoleMarkerTextures()
  end

  EVENT_MANAGER:UnregisterForEvent(QDRH.name .. "CombatEvent", EVENT_COMBAT_EVENT )
  EVENT_MANAGER:RegisterForEvent(QDRH.name .. "CombatEvent", EVENT_COMBAT_EVENT, QDRH.CombatEvent)
  
  -- Bufs/debuffs
  EVENT_MANAGER:UnregisterForEvent(QDRH.name .. "Buffs", EVENT_EFFECT_CHANGED )
  EVENT_MANAGER:RegisterForEvent(QDRH.name .. "Buffs", EVENT_EFFECT_CHANGED, QDRH.EffectChanged)
  
  -- Boss change
  EVENT_MANAGER:UnregisterForEvent(QDRH.name .. "BossChange", EVENT_BOSSES_CHANGED, QDRH.BossesChanged)
  EVENT_MANAGER:RegisterForEvent(QDRH.name .. "BossChange", EVENT_BOSSES_CHANGED, QDRH.BossesChanged)

  EVENT_MANAGER:UnregisterForEvent(QDRH.name .. "BossPowerUpdate", EVENT_POWER_UPDATE)
  EVENT_MANAGER:RegisterForEvent(QDRH.name .. "BossPowerUpdate", EVENT_POWER_UPDATE, QDRH.BossPowerUpdate)
  EVENT_MANAGER:AddFilterForEvent(QDRH.name .. "BossPowerUpdate", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG_PREFIX, "boss")
  EVENT_MANAGER:AddFilterForEvent(QDRH.name .. "BossPowerUpdate", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_HEALTH)
  
  -- Combat state
  EVENT_MANAGER:UnregisterForEvent(QDRH.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE , QDRH.CombatState)
  EVENT_MANAGER:RegisterForEvent(QDRH.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE , QDRH.CombatState)
  
  -- Death state
  EVENT_MANAGER:UnregisterForEvent(QDRH.name .. "DeathState", EVENT_UNIT_DEATH_STATE_CHANGED , QDRH.DeathState)
  EVENT_MANAGER:RegisterForEvent(QDRH.name .. "DeathState", EVENT_UNIT_DEATH_STATE_CHANGED , QDRH.DeathState)

  EVENT_MANAGER:UnregisterForUpdate(QDRH.name.."UpdateTick")
  EVENT_MANAGER:RegisterForUpdate(QDRH.name.."UpdateTick", 
    1000/10, function(gameTimeMs) QDRH.UpdateTick(gameTimeMs) end)
  EVENT_MANAGER:UnregisterForUpdate(QDRH.name.."UpdateSlowTick")
  EVENT_MANAGER:RegisterForUpdate(QDRH.name.."UpdateSlowTick", 
    1000, function(gameTimeMs) QDRH.UpdateSlowTick(gameTimeMs) end)
end

function QDRH.OnAddonLoaded(event, addonName)
	if addonName ~= QDRH.name then
		return
	end

  QDRH.savedVariables = ZO_SavedVars:NewAccountWide("QcellDreadsailReefHelperSavedVariables", 2, nil, QDRH.settings)
  QDRH.ApplyConsoleDefaults()
  QDRH.DisableOSIconSettings()
  QDRH.RestorePosition()
  if QDRH.Menu and QDRH.Menu.AddonMenu then
    QDRH.Menu.AddonMenu()
  end
  if SLASH_COMMANDS then
    SLASH_COMMANDS["/qdrh"] = QDRH.CommandLine
  end
  
	EVENT_MANAGER:UnregisterForEvent(QDRH.name, EVENT_ADD_ON_LOADED )
	EVENT_MANAGER:RegisterForEvent(QDRH.name .. "PlayerActive", EVENT_PLAYER_ACTIVATED,
    QDRH.PlayerActivated)
end

EVENT_MANAGER:RegisterForEvent( QDRH.name, EVENT_ADD_ON_LOADED, QDRH.OnAddonLoaded )

function QDRH.ApplyPosition()
    if not QDRH.savedVariables then return end
    local x = QDRH.savedVariables.posX or 0
    local y = QDRH.savedVariables.posY or 0
    if QDRHStatus then
        QDRHStatus:ClearAnchors()
        QDRHStatus:SetAnchor(CENTER, GuiRoot, CENTER, x, y)
    end
end

function QDRH.ApplyMessagePositions()
    if not QDRH.savedVariables then return end
    if QDRHMessage1 then
        QDRHMessage1:ClearAnchors()
        QDRHMessage1:SetAnchor(CENTER, GuiRoot, CENTER, QDRH.savedVariables.msg1X or 0, QDRH.savedVariables.msg1Y or -200)
    end
    if QDRHMessage2 then
        QDRHMessage2:ClearAnchors()
        QDRHMessage2:SetAnchor(CENTER, GuiRoot, CENTER, QDRH.savedVariables.msg2X or 0, QDRH.savedVariables.msg2Y or -60)
    end
    if QDRHMessage3 then
        QDRHMessage3:ClearAnchors()
        QDRHMessage3:SetAnchor(CENTER, GuiRoot, CENTER, QDRH.savedVariables.msg3X or 0, QDRH.savedVariables.msg3Y or 80)
    end
end

zo_callLater(function()
    if QDRH.ApplyPosition then QDRH.ApplyPosition() end
    if QDRH.ApplyMessagePositions then QDRH.ApplyMessagePositions() end
end,1500)

-- ===== CLAMP WITH SCALE =====
local function ClampToScreen(control, x, y)
    if not control then return x, y end

    local screenW, screenH = GuiRoot:GetDimensions()
    local scale = control:GetScale() or 1
    local w, h = control:GetDimensions()

    w = w * scale
    h = h * scale

    local minX = -screenW/2 + w/2
    local maxX = screenW/2 - w/2
    local minY = -screenH/2 + h/2
    local maxY = screenH/2 - h/2

    if x < minX then x = minX end
    if x > maxX then x = maxX end
    if y < minY then y = minY end
    if y > maxY then y = maxY end

    return x, y
end

zo_callLater(function()
    if QDRH.ApplyMapPosition then QDRH.ApplyMapPosition() end
    if QDRH.ApplyDebuffPosition then QDRH.ApplyDebuffPosition() end
end,1500)

-- ===== CENTER CLAMP FINAL =====
local function ClampCenter(control, x, y)
    if not control then return x, y end

    local screenW, screenH = GuiRoot:GetDimensions()

    local scale = control:GetScale() or 1
    local w, h = control:GetDimensions()

    w = w * scale
    h = h * scale

    local minX = -screenW/2 + w/2
    local maxX = screenW/2 - w/2

    local minY = -screenH/2 + h/2
    local maxY = screenH/2 - h/2

    if x < minX then x = minX end
    if x > maxX then x = maxX end
    if y < minY then y = minY end
    if y > maxY then y = maxY end

    return x, y
end

function QDRH.ApplyMapPosition()
    if not QDRH.savedVariables or not QDRHMap then return end
    local scale = QDRH.savedVariables.mapScale or 1
    local x = QDRH.savedVariables.mapLeft or 0
    local y = QDRH.savedVariables.mapTop or 0
    QDRHMap:SetScale(scale)
    QDRHMap:ClearAnchors()
    QDRHMap:SetAnchor(CENTER, GuiRoot, CENTER, x, y)
end

function QDRH.ApplyDebuffPosition()
    if not QDRH.savedVariables or not QDRHDebuff then return end
    local scale = QDRH.savedVariables.debuffScale or 1
    local x = QDRH.savedVariables.debuffLeft or 0
    local y = QDRH.savedVariables.debuffTop or 0
    QDRHDebuff:SetScale(scale)
    QDRHDebuff:ClearAnchors()
    QDRHDebuff:SetAnchor(CENTER, GuiRoot, CENTER, x, y)
end

-- ===== MAIN UI SCALE (SAFE ADD) =====
function QDRH.SetMainScale(value)
    QDRH.savedVariables.mainScale = value
    if QDRHStatus then
        QDRHStatus:SetScale(value)
    end
end
