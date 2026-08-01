LC = LC or {}
local LC = LC

LC.name     = "LucentCitadel"
LC.version  = "1.4.3"
LC.author   = "@SlipperySoap, @AlekWithK"
LC.active   = false

LC.status = {

  killSwitch = false,

  testStatus = 0,
  inCombat = false,
  
  currentBoss = "",
  isZilyesset = false,
  isCavot = false,
  isOrphic = false,
  isBaron = false,
  isXoryn = false,
  isArcaneKnot = false, -- LC.status.isArcaneKnot
  isHMBoss = false,
  
  orphicIsCastingColorChange = false, -- LC.status.orphicIsCastingColorChange
  orphicColorChangeStartTime = 0, -- LC.status.orphicColorChangeStartTime
  orphicClockActive = false, -- LC.status.orphicClockActive
  orphicClockCardinalActive = false, -- LC.status.orphicClockCardinalActive
  baronSpotMarkersActive = false, -- LC.status.baronSpotMarkersActive
  nextThunderThrall = 100, -- LC.status.nextThunderThrall
  currentArcaneKnot = 0, -- LC.status.currentArcaneKnot
  fluctuatingActive = false, -- LC.status.fluctuatingActive

  nameOfArcaneKnotOrderProfile = "", -- LC.status.nameOfArcaneKnotOrderProfile

  locked = true,
  
  -- Menu
  groupsAtNames = {
    [1] = "@unknown",
    [2] = "@unknown",
    [3] = "@unknown",
    [4] = "@unknown",
    [5] = "@unknown",
    [6] = "@unknown",
    [7] = "@unknown",
    [8] = "@unknown",
    [9] = "@unknown",
    [10] = "@unknown",
    [11] = "@unknown",
    [12] = "@unknown",
    }, -- LC.status.groupsAtNames

  arcaneKnotHolders = {
    [1] = "none",
    [2] = "none",
    [3] = "none",
    [4] = "none",
    [5] = "none",
    [6] = "none",
    [7] = "none",
    [8] = "none",
    [9] = "none",
    [10] = "none",
    [11] = "none",
    [12] = "none",
  }, -- LC.status.arcaneKnotHolders
  illuminatiArcaneKnotHolders = {
    [1] = "@DarknoSyn",
    [2] = "@SeaUnicorn",
    [3] = "@Brangwynn",
    [4] = "@Jeesh2234",
    [5] = "@Haymez327",
    [6] = "@watervision",
    [7] = "@AngelofDeathGaming",
    [8] = "@Dracogenius",
    [9] = "@MrSnowyagi",
    [10] = "@HazeRiderz",
    [11] = "@HatchetHaro",
    [12] = "@SlipperySoap",
    }, -- LC.status.illuminatiArcaneKnotHolders
  kmpArcaneKnotHolders = {
    [1] = "@Dathrys",
    [2] = "@cicisch",
    [3] = "@chaoticbubbles",
    [4] = "@SCOTTIS1011",
    [5] = "@Spider.Heart",
    [6] = "@ScarrionCrow",
    [7] = "@Krymsyn_Panda",
    [8] = "@SlipperySoap",
    [9] = "@UnholyFrijole",
    [10] = "@Soulless921",
    [11] = "@nonuu",
    [12] = "@AlexRock77",
    }, -- LC.status.kmpArcaneKnotHolders

  viableArcaneKnotHolders = {}, -- LC.status.viableArcaneKnotHolders
  knotHoldersOnCooldown = {}, -- LC.status.knotHoldersOnCooldown

    -- @chaoticbubbles: 20, @ScarrionCrow: 16, @UnholyFrijole: 15, @SlipperySoap: 15, @nonuu: 15, @cicisch: 15, @SCOTTIS1011: 14, @Dathrys: 14, @Spider.Heart: 13, @Kieduss: 13, @fedemaniac: 13, @Krymsyn_Panda: 10, @Soulless921: 1, AlexRock77

  arcaneKnotCurrentArcaneKnotHolder = "@unknown", -- LC.status.arcaneKnotCurrentArcaneKnotHolder
  arcaneKnotNextArcaneKnotHolder = "@unknown", -- LC.status.arcaneKnotNextArcaneKnotHolder
  arcaneKnotBackupArcaneKnotHolder = "@unknown", -- LC.status.arcaneKnotBackupArcaneKnotHolder
  arcaneKnotPickupTime = 0, -- LC.status.arcaneKnotPickupTime

  viableFluctuatingHolders = {}, -- LC.status.viableFluctuatingHolders
  fluctuatingHoldersOnCooldown = {}, -- LC.status.fluctuatingHoldersOnCooldown

  -- Fluctuating Current
  fluctuatingHolders = {}, -- LC.status.fluctuatingHolders
  illuminatiFluctuatingHolders = {
    [1] = "@AngelofDeathGaming",
    [2] = "@watervision",
    [3] = "@SeaUnicorn",
    [4] = "@Brangwynn",
    [5] = "@MrSnowyagi",
    [6] = "@Dracogenius",
    [7] = "@HazeRiderz",
    [8] = "@HatchetHaro",
    [9] = "@SlipperySoap",
    [10] = "@Haymez327",
    }, -- LC.status.illuminatiFluctuatingHolders
  kmpFluctuatingHolders = {
    [1] = "@cicisch",
    [2] = "@Spider.Heart",
    [3] = "@SCOTTIS1011",
    [4] = "@chaoticbubbles",
    [5] = "@ScarrionCrow",
    [6] = "@SlipperySoap",
    [7] = "@UnholyFrijole",
    [8] = "@Soulless921",
    [9] = "@nonuu",
    [10] = "@AlexRock77",
    }, -- LC.status.kmpFluctuatingHolders

  xorynCurrentFluctuatingHolder = "@unknown", -- LC.status.xorynCurrentFluctuatingHolder
  xorynNextFluctuatingHolder = "@unknown", -- LC.status.xorynNextFluctuatingHolder
  xorynFluctuatingPickupTime = 0, -- LC.status.xorynFluctuatingPickupTime

  -- Orphic 
  lastThunderThrall = 0, -- LC.status.lastThunderThrall
  isInitialThunderThrall = true, -- LC.status.isInitialThunderThrall
  orphicFightStartTime = 0, -- LC.status.orphicFightStartTime
  orphicClockPositions = {
    [1] = 0,
    [2] = 0,
    [3] = 0,
    [4] = 0,
    [5] = 0,
    [6] = 0,
    [7] = 0,
    [8] = 0,
  },
  orphicClockIcons = {},
  orphicClockIconsCardinal = {},
  orphicEliteAddCount = 1, -- LC.status.orphicEliteAddCount
  
  -- Baron Rize
  baronSpotIcons = {},

  -- Xoryn
  xorynLastTempestAssault = 0, -- LC.status.xorynLastTempestAssault

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

  -- Slipperysoap's testing method
  testing = false, -- LC.status.testing
  overridezone = false, -- LC.status.overridezone
  testingBossHealth = 91, -- LC.status.testingBossHealth
}

-- Default settings.
LC.settings = {
  -- General
  illuminatiCoreMode = false,
  kmpCoreMode = false,
  -- Common
  showCommonHinderedAlertForHealers2 = true,

  -- Zilyesset 
  --showThunderThrallAlerts = false,
  showZilyessetPadTime = false,
  showZilyessetPadTimeAlert = false,

  -- Baron
  showBaronSpots2 = true,

  -- Orphic 
  orphicAutoMarkXoryn2 = false, 
  orphicEliteAddMarker2 = true,
  showThunderThrallPanel = false,
  showThunderThrallAlerts2 = true,
  showOrphicClock2 = true,
  showOrphicClockCardinal = true,
  showOrphicMirrorMechPanel = false,
  showOrphicMirrorMechAlerts2 = 3,
  orphic90Mirror = 0,
  orphic60Mirror = 0,
  orphic40Mirror = 0,
  orphic15Mirror = 0,
  debugOrphicMirrorMechArrow = false,
  orphicMarkersGroupLeadOverride = false,

  -- Xoryn 
  showXorynArcaneKnotPanel = false,
  showXorynArcaneKnotAlerts = false,
  xorynRefreshArcaneKnotDropdowns = false,
  xorynArcaneKnotHolder1 = "@unknown",
  xorynArcaneKnotHolder2 = "@unknown",
  xorynArcaneKnotHolder3 = "@unknown",
  xorynArcaneKnotHolder4 = "@unknown",
  xorynArcaneKnotHolder5 = "@unknown",
  xorynArcaneKnotHolder6 = "@unknown",
  xorynArcaneKnotHolder7 = "@unknown",
  xorynArcaneKnotHolder8 = "@unknown",
  xorynArcaneKnotHolder9 = "@unknown",
  xorynArcaneKnotHolder10 = "@unknown",
  xorynArcaneKnotHolder11 = "@unknown",
  xorynArcaneKnotHolder12 = "@unknown",
  showXorynMirrorPanel = false,
  showXorynMirrorAlert = true,
  showXorynFluxPanel = false,
  showXorynFluctuatingAlert = false,

  orphic60MirrorDirections = "None",

  -- Misc
  dropdownChoiceValues = { 
      [1] = 1, 
      [2] = 2, 
      [3] = 3, 
      [4] = 4, 
      [5] = 5, 
      [6] = 6, 
      [7] = 7, 
      [8] = 8, 
      [9] = 9, 
      [10] = 10, 
      [11] = 11, 
      [12] = 12, 
  }, -- LC.settings.dropdownChoiceValues
  dropdownChoiceValues9 = { 
      [1] = 1, 
      [2] = 2, 
      [3] = 3, 
      [4] = 4, 
      [5] = 5, 
      [6] = 6, 
      [7] = 7, 
      [8] = 8, 
      [9] = 9, 
  }, -- LC.settings.dropdownChoiceValues
  dropdownChoiceTooltips = { 
      [1] = "Group Member", 
      [2] = "Group Member", 
      [3] = "Group Member", 
      [4] = "Group Member", 
      [5] = "Group Member", 
      [6] = "Group Member", 
      [7] = "Group Member", 
      [8] = "Group Member", 
      [9] = "Group Member", 
      [10] = "Group Member", 
      [11] = "Group Member", 
      [12] = "Group Member", 
  }, -- LC.settings.dropdownChoiceTooltips
 dropdownChoiceTooltipsDirections = { 
      [1] = "None",
      [2] = "North", 
      [3] = "North East", 
      [4] = "East", 
      [5] = "South East", 
      [6] = "South", 
      [7] = "South West", 
      [8] = "West", 
      [9] = "North West", 
  }, -- LC.settings.dropdownChoiceTooltipsDirections
  panelUICustomScale = 1,
  alertUICustomScale = 1,
}
LC.units = {}
LC.unitsTag = {}

function LC.EffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType )
  LC.IdentifyUnit(unitTag, unitName, unitId)
  local timeSec = GetGameTimeSeconds()
  -- EFFECT_RESULT_GAINED = 1
  -- EFFECT_RESULT_FADED = 2
  -- EFFECT_RESULT_UPDATED = 3

  -- All Trash effect changed events are handled separately.
  LC.Trash.EffectChanged(changeType, abilityId, unitTag, beginTime, endTime)

  -- Arcane Knot
  if abilityId == LC.data.arcane_knot then
    if not LC.status.isArcaneKnot then
        LC.status.isArcaneKnot = true
        LC.ArcaneKnot.InitializeKnotOrder()
    end
    if changeType ~= nil and unitTag ~= nil then
        LC.ArcaneKnot.UpdateArcaneKnot(changeType, unitTag)
    -- there are various ways that this can be accomplished. i could also use the unitName and match it with the unitTag to get the @name
    -- here, a bug can be solved for not detecting when the knot is active
    end
  end

  -- Destructive ember
  if abilityId == LC.data.destructive_ember or abilityId == LC.data.pre_destructive_ember then
    LC.Lylanar.UpdateDestructiveEmber(changeType, stackCount, unitTag)
  end

  -- Reef Guardian Building Static
  if (abilityId == LC.data.guardian_building_static_boss or abilityId == LC.data.guardian_building_static_side_boss) and unitTag == "player" then
    LC.ReefGuardian.UpdateBuildingStatic(changeType, stackCount, endTime)
  end
end

function LC.CombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
  -- All Trash combat events are handled separately.
  LC.Trash.CombatEvent(result, abilityId, targetType, targetUnitId, sourceName, hitValue)

  -- Hindered 
  if abilityId == LC.Common.data.hindered_effect then
    LC.Common.Hindered(result, targetType, targetUnitId, hitValue)
  end

  -- Orphic Thunder Thrall
  if result == ACTION_RESULT_BEGIN and abilityId == LC.data.orphic_thunder_thrall then
    LC.Orphic.ThunderThrall()
  end

  -- LC.status.orphicIsCastingColorChange
  -- Orphic Color Change
  if abilityId == LC.data.orphic_color_change then
    if result == ACTION_RESULT_BEGIN or result == ACTION_RESULT_BEGIN_CHANNEL then
        --LC.Lylanar.IncendiaryAxe()
        if LC.status.orphicIsCastingColorChange == false then
            LC.status.orphicColorChangeStartTime = GetGameTimeSeconds()
            LC.status.orphicIsCastingColorChange = true
        end
    elseif result == ACTION_RESULT_COMPLETE then
        if LC.status.orphicIsCastingColorChange == true then
            LC.status.orphicIsCastingColorChange = false
        end
    end
  end

  -- Orphic New Mirror Spawns 
  if abilityId == LC.data.orphic_new_mirror_spawns then
    --LC.Orphic.NewMirrorSpawn(result)
  end

  -- Orphic Encounter's Xoryn Heavy Shock
  if abilityId == LC.data.orphic_xoryn_heavy_shock then
    --LC.Orphic.HeavyShock(result, targetType, targetUnitId, hitValue)
  end

  -- Xoryn Mirror Mech
  if abilityId == LC.data.xoryn_tempest_assault then
    LC.Xoryn.UpdateMirrorMechTracker()
  end

  -- Xoryn Fluctuating Current Mech
  if abilityId == LC.data.fluctuating_start then
    LC.status.fluctuatingActive = true
    LC.Xoryn.UpdateFluctuating(result, targetType, hitValue, targetUnitId)
  end

  -- Xoryn Fluctuating Current Mech: Overloaded debuff
  if abilityId == LC.data.xoryn_overloaded_current then
    LC.Xoryn.HandleOverloaded(result, targetType, hitValue, targetUnitId)
  end

  if result == ACTION_RESULT_EFFECT_GAINED_DURATION and abilityId == LC.data.turlassil_frostbrand_player_debuff and hitValue == 5000 then
    LC.Lylanar.Frostbrand(targetUnitId, GetGameTimeSeconds())
  end

  if result == ACTION_RESULT_BEGIN and abilityId == LC.data.lylanar_incendiary_axe then
    LC.Lylanar.IncendiaryAxe()
  end

  if result == ACTION_RESULT_EFFECT_GAINED and (
    abilityId == LC.data.lylanar_multiloc or 
    abilityId == LC.data.turlassil_multiloc) then
    LC.Lylanar.MultiLoc()
  end

  if result == ACTION_RESULT_EFFECT_GAINED_DURATION and abilityId == LC.data.summon_frost_hound then
    LC.Lylanar.SummonFrostHound(targetUnitId)
  end

  if result == ACTION_RESULT_DIED then
    --LC.Lylanar.HoundDied(targetUnitId)
  end

  -- This also triggers for failed reefs.
  if result == ACTION_RESULT_EFFECT_FADED and abilityId == LC.data.guardian_heartburn then
    LC.ReefGuardian.ReefDone()
  end

  if abilityId == LC.data.guardian_sheltered and targetType == COMBAT_UNIT_TYPE_PLAYER then
    LC.ReefGuardian.UpdateSheltered(result)
  end

  if result == ACTION_RESULT_BEGIN and (
    abilityId == LC.data.guardian_crab_monstrous_claw or 
    abilityId == LC.data.guardian_crab_swipe or 
    abilityId == LC.data.guardian_crab_water_jet) then
    LC.status.lastCrabCast[targetUnitId] = GetGameTimeSeconds()
  end

  if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER and (abilityId == LC.data.taleria_behemoth_crush or abilityId == LC.data.taleria_behemoth_hack or abilityId == LC.data.taleria_behemoth_strike) then
    CombatAlerts.AlertCast(abilityId, sourceName, hitValue, {-2, 1})
  end

  -- Taleria Winter Storm (wall)
  if result == ACTION_RESULT_EFFECT_GAINED and abilityId == LC.data.taleria_storm_wall_cw then
      -- Winter storm (wall) cast. Update direction icon.
      LC.status.taleriaLastStormWall = GetGameTimeSeconds()
      LC.status.taleriaLastStormWallClockwise = true
  end

  -- Taleria Portal
  -- Death Trigger (it's called like that, nothing to do with death)
  -- Triggers once with hitValue = 0 and once with hitValue=1. Both times ACTION_RESULT_EFFECT_GAINED.

  -- Open portal. Timer has not started yet.
  if abilityId == LC.data.taleria_dreadsail_venom_evoker and hitValue == 1 then
    LC.Taleria.OpenPortalVenomEvoker()
  end

  if abilityId == LC.data.taleria_dreadsail_sea_boiler and hitValue == 1 then
    LC.Taleria.OpenPortalSeaBoiler()
  end

  if abilityId == LC.data.taleria_dreadsail_tidal_mage and hitValue == 1 then
    LC.Taleria.OpenPortalTidalMage()
  end

  -- Start portal. Debuff and timer start now.
  -- TODO: Check if duration is 60s in every difficulty.
  if hitValue == 60000 and (
    abilityId == LC.data.taleria_dreadsail_venom_evoker_nematocyst_cloud or
    abilityId == LC.data.taleria_dreadsail_sea_boiler_sweltering_heat or
    abilityId == LC.data.taleria_dreadsail_tidal_mage_suffocating_waves)
    then

      if result == ACTION_RESULT_BEGIN then
        LC.Taleria.StartPortal()
      elseif result == ACTION_RESULT_EFFECT_FADED then
        -- I could tell exactly which portal closed, in case they do not close in order.
        LC.Taleria.PortalDone()
      end
  end

  -- Buffs from people in portal or people in the island staying in the circle.
  --if hitValue == 0 and targetType == COMBAT_UNIT_TYPE_PLAYER and (
    --abilityId == LC.data.taleria_dreadsail_venom_evoker_nematocyst_cloud_portal or
    --abilityId == LC.data.taleria_dreadsail_venom_evoker_nematocyst_cloud_aoe or
    --abilityId == LC.data.taleria_dreadsail_sea_boiler_sweltering_heat_portal or
    --abilityId == LC.data.taleria_dreadsail_sea_boiler_sweltering_heat_aoe or
    --abilityId == LC.data.taleria_dreadsail_tidal_mage_suffocating_waves_portal or
    --abilityId == LC.data.taleria_dreadsail_tidal_mage_suffocating_waves_aoe) then
    -- GAINED -> true. FADED -> false.
    --LC.status.debuffTracker[abilityId] = (result == ACTION_RESULT_EFFECT_GAINED)
  --end

  -- TODO: Track individual people's debuff rather than Island/Landed boss debuffs.
  -- TODO: Better approach: debuff[abilityId] = true
  --       When rendering check that debuff[ability_debuff_1] or debuff[ability_debuff_3] or debuff[ability_debuff_3]

  -- TODO: Delete old PortalDone() logic using icy escape (event 2s after the actual closure)
  -- Note: This also triggers when there's a portal fail. Technically, it is "done".
  --[[if result == ACTION_RESULT_EFFECT_GAINED and abilityId == LC.data.taleria_portal_done then
    LC.Taleria.PortalDone()
  end--]]

  -- For PLAYER CCA already shows it (on MT)
  if abilityId == LC.data.taleria_crashing_wave_boss and targetType ~= COMBAT_UNIT_TYPE_PLAYER then
    LC.Taleria.CrashingWave(abilityId, sourceName, hitValue)
  end

  -- TODO: Remove duplicates from code's. bear will be added soon
  -- Player targetted melee heavy attacks
  -- Various heavy attacks (list cleared after Combat Alerts CCA has them)
  if targetType == COMBAT_UNIT_TYPE_PLAYER and abilityId == LC.data.bow_breaker_horn_strike_1 then
    -- -2: melee alert
    -- 2: only do ping alert on DDs to dodge it
    CombatAlerts.AlertCast(abilityId, sourceName, hitValue, {-2, 2})
  end

  -- Progress bar for Acid Reflux.
  if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER and abilityId == LC.data.guardian_acid_reflux and hitValue == 10000 then
    -- CombatAlerts.CastAlertsStart(abilityId, abilityName, hitValue, nil, nil, nil)
    LC.ReefGuardian.AcidReflux()
  end

  -- Slip: Medium Attacks can be tracked for Lion, Gryphon, and Wamasu of Sanity's Edge
  -- Light/heavy attacks (1.5s windup) alert for non-tanks.
  if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER and (
    abilityId == LC.data.guardian_crush or 
    abilityId == LC.data.guardian_claw) then
    local isDPS, isHeal, isTank = GetPlayerRoles()
    if not isTank then
      CombatAlerts.AlertCast(abilityId, sourceName, hitValue, {-2, 2})
    end
  end

  if targetType == COMBAT_UNIT_TYPE_PLAYER and result == ACTION_RESULT_EFFECT_GAINED and abilityId == LC.data.sail_ripper_storm_cell then
    -- lasts forever. do NOT use hitValue
    -- May fire twice, needs testing.
    CombatAlerts.Alert("", abilityName .. " (you)", 0xFFD666FF, SOUNDS.CHAMPION_POINTS_COMMITTED, 5000)
  end
end

function LC.UpdateGroupAtNamesForArcaneKnotDropdownMenus()
    -- to-do
    -- LC.GetNameForId(targetUnitId)
    for i=1, 12 do
        local unitTag = "group" .. tostring(i)
        local atName = GetUnitDisplayName(unitTag)
        if atName ~= nil then
            LC.status.groupsAtNames[i] = atName
        end
    end
end

function LC.RefreshArcaneKnotDropdownMenus()
    -- need to update LC.status.groupsAtNames here
    LC.UpdateGroupAtNamesForArcaneKnotDropdownMenus()

    -- updating menu dropdowns here
    LC_ArcaneKnotHolder1_Dropdown:UpdateChoices(LC.status.groupsAtNames)
    LC_ArcaneKnotHolder2_Dropdown:UpdateChoices(LC.status.groupsAtNames, LC.settings.dropdownChoiceValues, LC.settings.dropdownChoiceTooltips)
    LC_ArcaneKnotHolder3_Dropdown:UpdateChoices(LC.status.groupsAtNames, LC.settings.dropdownChoiceValues, LC.settings.dropdownChoiceTooltips)
    LC_ArcaneKnotHolder4_Dropdown:UpdateChoices(LC.status.groupsAtNames, LC.settings.dropdownChoiceValues, LC.settings.dropdownChoiceTooltips)
    LC_ArcaneKnotHolder5_Dropdown:UpdateChoices(LC.status.groupsAtNames, LC.settings.dropdownChoiceValues, LC.settings.dropdownChoiceTooltips)
    LC_ArcaneKnotHolder6_Dropdown:UpdateChoices(LC.status.groupsAtNames, LC.settings.dropdownChoiceValues, LC.settings.dropdownChoiceTooltips)
    LC_ArcaneKnotHolder7_Dropdown:UpdateChoices(LC.status.groupsAtNames, LC.settings.dropdownChoiceValues, LC.settings.dropdownChoiceTooltips)
    LC_ArcaneKnotHolder8_Dropdown:UpdateChoices(LC.status.groupsAtNames, LC.settings.dropdownChoiceValues, LC.settings.dropdownChoiceTooltips)
    LC_ArcaneKnotHolder9_Dropdown:UpdateChoices(LC.status.groupsAtNames, LC.settings.dropdownChoiceValues, LC.settings.dropdownChoiceTooltips)
    LC_ArcaneKnotHolder10_Dropdown:UpdateChoices(LC.status.groupsAtNames, LC.settings.dropdownChoiceValues, LC.settings.dropdownChoiceTooltips)
    LC_ArcaneKnotHolder11_Dropdown:UpdateChoices(LC.status.groupsAtNames, LC.settings.dropdownChoiceValues, LC.settings.dropdownChoiceTooltips)
    LC_ArcaneKnotHolder12_Dropdown:UpdateChoices(LC.status.groupsAtNames, LC.settings.dropdownChoiceValues, LC.settings.dropdownChoiceTooltips)
    LC.savedVariables.xorynRefreshArcaneKnotDropdowns = false
    -- Might have to update the menu checkbox here
end

function LC.UpdateSlowTick(gameTimeMs)
  if IsUnitInCombat("player") then
    --if LC.savedVariables.debugOrphicMirrorMechArrow ~= nil then
        --if LC.savedVariables.debugOrphicMirrorMechArrow then
            --LC.Orphic.DebugOrphicMirrorMechArrowUpdate(91)
        --else
            --LibSimpleArrowSlip.HideArrow()
        --end
    --end
    return
  end

  --if LC.savedVariables.xorynRefreshArcaneKnotDropdowns then
    --LC.RefreshArcaneKnotDropdownMenus()
  --end
  if not LC.status.killSwitch then
      -- Boss 2: Orphic
      -- ~= nil
      if LC.savedVariables.showOrphicClock2 ~= nil and LC.status.orphicClockActive ~= nil then
          if LC.savedVariables.showOrphicClock2 and not LC.status.orphicClockActive then
            LC.Orphic.AddOrphicClock()
          elseif not LC.savedVariables.showOrphicClock2 and LC.status.orphicClockActive then
            LC.Orphic.DiscardOrphicClock()
          end
      end
      if LC.savedVariables.showOrphicClockCardinal ~= nil and LC.status.orphicClockCardinalActive ~= nil then
          if LC.savedVariables.showOrphicClockCardinal and not LC.status.orphicClockCardinalActive then
            LC.Orphic.AddOrphicClockCardinal()
          elseif not LC.savedVariables.showOrphicClockCardinal and LC.status.orphicClockCardinalActive then
            LC.Orphic.DiscardOrphicClockCardinal()
          end
      end
      if LC.savedVariables.debugOrphicMirrorMechArrow ~= nil then
          if LC.savedVariables.debugOrphicMirrorMechArrow then
            LC.Orphic.DebugOrphicMirrorMechArrowUpdate(91)
          else
            LibSimpleArrowSlip.HideArrow()
          end
      end

  end
end

function LC.UpdateTick(gameTimeMs)
  local timeSec = GetGameTimeSeconds()

  if IsUnitInCombat("boss1") then
    if not LC.status.inCombat then
      -- If it switched from non-combat to combat, re-check boss names.
    end
    LC.status.inCombat = true
  end
  
  -- Second boss comes a bit after the adds. Lucent Citadel specific logic.
  if IsUnitInCombat("player") and LC.status.isOrphic then
    LC.status.inCombat = true
  end

  -- Refresh the Lightning/Poison panel even out of combat, if it has any stacks.
  --if LC.status.stacksUIEnabled then
    --LC.ReefGuardian.UpdateStacks(timeSec)
  --end
  
  if LC.status.inCombat == false then
    if LC.savedVariables.debugOrphicMirrorMechArrow ~= nil then
        if LC.savedVariables.debugOrphicMirrorMechArrow then
            LC.Orphic.DebugOrphicMirrorMechArrowUpdate(91)
        else
            LibSimpleArrowSlip.HideArrow()
        end
    end
    return
  end
  
  --if LC.savedVariables.debugOrphicMirrorMechArrow ~= nil then
        --if LC.savedVariables.debugOrphicMirrorMechArrow then
            --LC.Orphic.DebugOrphicMirrorMechArrowUpdate(91)
        --end
    --end

  if not LC.status.killSwitch then
      -- Boss 1: Zilyesset
      if LC.status.isZilyesset then
        LC.Zilyesset.UpdateTick(timeSec)
      end

      -- Boss 2: Orphic
      if LC.status.isOrphic then
        LC.Orphic.UpdateTick(timeSec)
      end

      -- Arcane Knot
      if LC.status.isArcaneKnot then
        LC.ArcaneKnot.UpdateTick(timeSec)
      end

      -- Mini Boss 2: Baron
      if LC.status.isBaron then
        LC.Baron.UpdateTick(timeSec)
      end

      -- Boss 3: Xoryn
      if LC.status.isXoryn or LC.status.fluctuatingActive then
        LC.Xoryn.UpdateTick(timeSec)
      end


  end

end

function LC.DeathState(event, unitTag, isDead)
  if unitTag == "player" and not isDead and not IsUnitInCombat("boss1") then
    -- I just resurrected, and it was a wipe or we killed the boss.
    -- Remove all UI
    LC.ClearUIOutOfCombat()
  end
  -- TODO: Remove from the list of "players in portal" in boss 1 and boss 2.
end

function LC.CombatState(eventCode, inCombat)
  local currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("boss1", POWERTYPE_HEALTH)
  -- Do not change combat state if you are dead, or the boss is not full.

  -- Do not do anything outside of boss fights.
  if maxTargetHP == 0 or maxTargetHP == nil then
    LC.ClearUIOutOfCombat()
    return
  end
  if currentTargetHP < 0.99*maxTargetHP or IsUnitDead("player") then
    return
  end
  if inCombat then
    LC.status.inCombat = true
    LC.ResetStatus()
  else
    -- Orphic 
    LC.status.lastThunderThrall = 0
    LC.status.orphicEliteAddCount = 1
    LC.status.orphicIsCastingColorChange = false -- LC.status.orphicIsCastingColorChange
    LC.status.orphicColorChangeStartTime = 0
    LC.status.lastThunderThrall = 0
    LC.status.nextThunderThrall = 1000
    LC.status.isInitialThunderThrall = true
    LC.status.orphicFightStartTime = 0
    LC.status.currentArcaneKnot = 0
    LC.status.fluctuatingActive = false

    -- Baron
    LC.Baron.DiscardBaronSpots()

    -- Arcane Knot
    LC.status.isArcaneKnot = false

    -- Xoryn
    LC.status.xorynLastTempestAssault = 0

    LC.ClearUIOutOfCombat()
  end
end

function LC.ResetStatus()
  
    -- Menu
    --LC.status.groupsAtNames = {
    --[1] = "@unknown",
    --[2] = "@unknown",
    --[3] = "@unknown",
    --[4] = "@unknown",
    --[5] = "@unknown",
    --[6] = "@unknown",
    --[7] = "@unknown",
    --[8] = "@unknown",
    --[9] = "@unknown",
    --[10] = "@unknown",
    --[11] = "@unknown",
    --[12] = "@unknown",
    --}

end

function LC.GetBossName()
  -- 1 to 6 so far
  for i = 1,MAX_BOSSES do
    local name = string.lower(GetUnitName("boss" .. tostring(i)))
    if name ~= nil and name ~= "" then
      return name
    end
  end
  return ""
end

function LC.BossesChanged()
	--local bossName = string.lower(GetUnitName("boss1"))
  local bossName = LC.GetBossName()
  local lastBossName = LC.status.currentBoss
  if bossName ~= nil then
    -- Slip: I wonder if I need to do this for any bosses in Lucent Citadel
    if LC.status.currentBoss == LC.data.taleriaName and bossName == "" then
      -- Do not reset Taleria for empty, this helps the clearing on wipes.
      -- TODO: Remove UI after killing Taleria.
    else
      if bossName ~= LC.status.currentBoss then
        --d("[LC] Boss change. Name = " .. bossName)
      end
      LC.status.currentBoss = bossName
    end
    
    LC.status.isZilyesset = false
    LC.status.isCavot = false
    LC.status.isOrphic = false
    LC.status.isBaron = false
    LC.status.isXoryn = false
    LC.status.isHMBoss = false

    -- Can remove boss specific icons here
    --LC.Lylanar.RemoveLylanarPhase3StackIcons()

    --LC.Taleria.RemovePivotIcon()
    --LC.Taleria.RemoveOppositePivotIcon()
    --LC.Taleria.RemoveSlaughterFishIcons()
    --LC.Taleria.RemoveStaticPortalStackIcons()
    --LC.Taleria.DiscardTaleriaClock()

    -- LC.Orphic.DiscardOrphicClock()

    local currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("boss1", POWERTYPE_HEALTH)
    local hardmodeHealth = {
      [LC.data.zilyessetName] = 48000000, -- vet M, HM 48.9M
      [LC.data.cavotName] = 100000000,  
      [LC.data.orphicName] = 97000000, -- vet M, HM 97.8M
      [LC.data.baronName] = 23000000, 
      [LC.data.xorynName] = 69000000, -- vet: M, HM 69.8M
    }

    -- Check for HM.
    -- TODO: Check if this works for Reef Guardian since "boss1" disappears, but then hp is nil so it shouldn't update.
    if bossName ~= nil and maxTargetHP ~= nil and hardmodeHealth[bossName] ~= nil then
      if maxTargetHP > hardmodeHealth[bossName] then
        LC.status.isHMBoss = true
      else
        LC.status.isHMBoss = false
      end
    end

    if string.match(bossName, LC.data.zilyessetName) then
      LC.status.isZilyesset = true
    end
    if string.match(bossName, LC.data.cavotName) then
      LC.status.isCavot = true
    end
    if string.match(bossName, LC.data.orphicName) then
      LC.status.isOrphic = true
      
      -- LC.Orphic.AddOrphicClock()
      -- dealing with the Orphic Clock in updateTick
      -- Only draw if the boss changed, or it keeps re-drawing in the Reef Guardian fight.
      --if LC.status.isHMBoss then 
        --LC.ReefGuardian.DrawStratIcons()
      --end
    --else
      --LC.ReefGuardian.ClearStratIcons()
    end
    if string.match(bossName, LC.data.baronName) then
      LC.status.isBaron = true
    end
    if string.match(bossName, LC.data.xorynName) then
      if not LC.status.isXoryn then
        LC.Xoryn.InitializeFluctuatingOrder()
      end
      LC.status.isXoryn = true
    end
    --if string.match(bossName, LC.data.taleriaName) then
      --LC.status.isTaleria = true
      --LC.Taleria.AddPivotIcon()
      -- TODO: Move to HM-only?
      --LC.Taleria.AddSlaughterFishIcons()
      --if LC.status.isHMBoss then
        --LC.Taleria.AddOppositePivotIcon()
        --LC.Taleria.ShowStaticPortalStackIcons()
        --LC.Taleria.AddTaleriaClock()
      --end
    --end
  end
end

function LC.GetCoreAtNames()
    if LC.savedVariables.illuminatiCoreMode then
        LC.status.arcaneKnotHolders = LC.status.illuminatiArcaneKnotHolders
    end
    if LC.savedVariables.kmpCoreMode then
        LC.status.arcaneKnotHolders = LC.status.kmpArcaneKnotHolders
    end
end

function LC.SaveKnotProfile()
    -- todo
end

function LC.RefreshAtNameDropdowns()
    -- todo
end

function LC.SaveManualKnotProfile()
    LC.savedVariables.arcaneKnotHolders = LC.status.arcaneKnotHolders
end

function LC.LoadSavedKnotProfile()
    if LC.savedVariables.arcaneKnotHolders ~= nil then
        LC.status.arcaneKnotHolders = LC.savedVariables.arcaneKnotHolders
    end
end

function LC.PlayerActivated()
  -- Disable all visible UI elements at startup.
  --LC.HideAllUI(true)
  LC.UnlockUI(false)

  if GetZoneId(GetUnitZoneIndex("player")) ~= LC.data.lucentCitadelId and not LC.status.overridezone then
    return
  else
    LC.units = {}
    LC.unitsTag = {}
  end

  -- Fix for stacks when PTEing with stacks
  --LC.status.volatileResidueStacks = 0
  --LC.status.buildingStaticStacks = 0

  
  if LC.active and not LC.savedVariables.hideWelcome then
    d("|cff71f9[LC] Thanks for using Lucent Citadel " .. LC.version .. ". Please send issues through Discord to .slipperysoap|r")
  end
  LC.active = true
  LCStatusLabelAddonName:SetText("Lucent Citadel " .. LC.version)

  EVENT_MANAGER:UnregisterForEvent(LC.name .. "CombatEvent", EVENT_COMBAT_EVENT )
  EVENT_MANAGER:RegisterForEvent(LC.name .. "CombatEvent", EVENT_COMBAT_EVENT, LC.CombatEvent)
  
  -- Bufs/debuffs
  EVENT_MANAGER:UnregisterForEvent(LC.name .. "Buffs", EVENT_EFFECT_CHANGED )
  EVENT_MANAGER:RegisterForEvent(LC.name .. "Buffs", EVENT_EFFECT_CHANGED, LC.EffectChanged)
  
  -- Boss change
  EVENT_MANAGER:UnregisterForEvent(LC.name .. "BossChange", EVENT_BOSSES_CHANGED, LC.BossesChanged)
  EVENT_MANAGER:RegisterForEvent(LC.name .. "BossChange", EVENT_BOSSES_CHANGED, LC.BossesChanged)
  
  -- Combat state
  EVENT_MANAGER:UnregisterForEvent(LC.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE , LC.CombatState)
  EVENT_MANAGER:RegisterForEvent(LC.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE , LC.CombatState)
  
  -- Death state
  EVENT_MANAGER:UnregisterForEvent(LC.name .. "DeathState", EVENT_UNIT_DEATH_STATE_CHANGED , LC.DeathState)
  EVENT_MANAGER:RegisterForEvent(LC.name .. "DeathState", EVENT_UNIT_DEATH_STATE_CHANGED , LC.DeathState)

  -- Reticle change
  EVENT_MANAGER:UnregisterForEvent(LC.name .. "ReticleChanged", EVENT_RETICLE_TARGET_CHANGED)
  EVENT_MANAGER:RegisterForEvent(LC.name .. "ReticleChanged", EVENT_RETICLE_TARGET_CHANGED, LC.ReticleChanged)
  
  -- Only updates ticks if killswitch is off
  -- if not LC.status.killSwitch and not LC.status.overridezone then
    -- Ticks
    EVENT_MANAGER:RegisterForUpdate(LC.name.."UpdateTick", 
    1000/10, function(gameTimeMs) LC.UpdateTick(gameTimeMs) end)
    EVENT_MANAGER:RegisterForUpdate(LC.name.."UpdateSlowTick", 
    1000, function(gameTimeMs) LC.UpdateSlowTick(gameTimeMs) end)
  --end
end

function LC.OnAddonLoaded(event, addonName)
	if addonName ~= LC.name then
		return
	end
  
  LC.savedVariables = ZO_SavedVars:NewAccountWide("LucentCitadelSavedVariables", 2, nil, LC.settings)
  LC.RestorePosition()
  LC.Menu.AddonMenu()
  LC.Common.InitializeSimpleArrow()

  SLASH_COMMANDS["/lc"] = LC.CommandLine
  
	EVENT_MANAGER:UnregisterForEvent(LC.name, EVENT_ADD_ON_LOADED )
	EVENT_MANAGER:RegisterForEvent(LC.name .. "PlayerActive", EVENT_PLAYER_ACTIVATED,
    LC.PlayerActivated)
end

EVENT_MANAGER:RegisterForEvent( LC.name, EVENT_ADD_ON_LOADED, LC.OnAddonLoaded )
