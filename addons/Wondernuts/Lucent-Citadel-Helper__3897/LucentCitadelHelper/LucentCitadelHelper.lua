LCH = LCH or {}
local LCH = LCH

LCH.name     = "LucentCitadelHelper"
LCH.version  = "0.7.0"
LCH.author   = "@Wondernuts, @kabs12"
LCH.active   = false

LCH.status = {
  testStatus = 0,
  inCombat = false,

  currentBoss = "",
  isZilyesset = false,
  isOrphic = false,
  isXoryn = false,
  isHMBoss = false,

  locked = true,

  RyelazPadIconNumber1 = {},
  RyelazPadIconNumber2 = {},
  RyelazPadIconNumber3 = {},
  ZilyessetPadIconNumber1 = {},
  ZilyessetPadIconNumber2 = {},
  ZilyessetPadIconNumber3 = {},

  MirrorIconNumber1 = {},
  MirrorIconNumber2 = {},
  MirrorIconNumber3 = {},
  MirrorIconNumber4 = {},
  MirrorIconNumber5 = {},
  MirrorIconNumber6 = {},
  MirrorIconNumber7 = {},
  MirrorIconNumber8 = {},

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
LCH.settings = {
  showHinderedIcon = true,
  showPadIcons = true,

  -- Orphic
  showXorynJumpTimer = true,
  showXorynConeTimer = false,
  showMirrorIcons = true,

  -- Last Boss
  showFluctuatingCurrentHolder = true,
  showFluctuatingCurrentTimer = true,
  showOverloadedCurrentTimer = true,
  showOverloadedCurrentIcons = false,
  showXynizataBeamTimer = false,
  showXynizataChannelTimer = false,
  showNecroticBarrage = true,

  -- Misc
  uiCustomScale = 1,
}
LCH.units = {}
LCH.unitsTag = {}

function LCH.EffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
  LCH.IdentifyUnit(unitTag, unitName, unitId)
  -- EFFECT_RESULT_GAINED = 1
  -- EFFECT_RESULT_FADED = 2
  -- EFFECT_RESULT_UPDATED = 3
end

local DEBUG_EVENT = 3

function LCH.CombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
  -- Debug ability casts of NPCs (unit type None)
  if DEBUG_EVENT <= LCH.debugMode then
    if result == ACTION_RESULT_BEGIN and sourceType == COMBAT_UNIT_TYPE_NONE then
      local displaySourceName = sourceName or GetUnitDisplayName(LCH.GetTagForId(sourceUnitId)) or ""
      local displayTargetName = GetUnitDisplayName(LCH.GetTagForId(targetUnitId)) or ""
      LCH:Trace(DEBUG_EVENT, string.format(
        "Ability: %s, ID: %d, Hit Value: %d, Source name: %s, Target name: %s", 
        GetFormattedAbilityName(abilityId), abilityId, hitValue, displaySourceName, displayTargetName
      ))
    end
  end

  LCH.Common.ProcessInterrupts(result, targetUnitId) 

  if abilityId == LCH.Common.constants.hindered_id then
    LCH.Common.Hindered(result, targetType, targetUnitId, hitValue)
  elseif abilityId == LCH.Common.constants.radiance_debuff_id then
    LCH.Common.Radiance(result, targetType, targetUnitId, hitValue)
  elseif abilityId == LCH.Common.constants.solar_flare_id then
    LCH.Common.SolarFlare(abilityId, result, sourceName, sourceUnitId, targetType, targetUnitId, hitValue)

  elseif abilityId == LCH.Zilyesset.constants.brilliant_annihilation_id or abilityId == LCH.Zilyesset.constants.bleak_annihilation_id then
    LCH.Zilyesset.Annihilation(abilityId, result, targetType, targetUnitId, hitValue)
  -- elseif abilityId == LCH.Zilyesset.constants.summon_shardborn_lightweaver_id then
  --   LCH.Zilyesset.SummonLightweaver(result, targetType, targetUnitId, hitValue)
  -- elseif abilityId == LCH.Zilyesset.constants.summon_gloomy_blackguard_id then
  --   LCH.Zilyesset.SummonBlackguard(result, targetType, targetUnitId, hitValue)
  elseif abilityId == LCH.Zilyesset.constants.porcindark_id then
    LCH.Zilyesset.OnLightSide(result, targetType, targetUnitId, hitValue)
  elseif abilityId == LCH.Zilyesset.constants.porcinlight_id then
    LCH.Zilyesset.OnDarkSide(result, targetType, targetUnitId, hitValue)
  --elseif abilityId == LCH.Zilyesset.constants.bleak_lusterbeam_id or abilityId == LCH.Zilyesset.constants.brilliant_lusterbeam_id then
  --  LCH.Zilyesset.Lusterbeam(abilityId, result, targetType, targetUnitId, hitValue)

  elseif abilityId == LCH.Orphic.constants.color_change_id then
    LCH.Orphic.ColorChange(result, targetType, targetUnitId, hitValue)
  elseif abilityId == LCH.Orphic.constants.thunder_thrall_id then
    LCH.Orphic.ThunderThrall(result, targetType, targetUnitId, hitValue)
  elseif abilityId == LCH.Orphic.constants.lightning_flood_id then
    LCH.Orphic.LightningFlood(result, targetType, targetUnitId, hitValue)
  elseif abilityId == LCH.Orphic.constants.heavy_shock_id then
    LCH.Orphic.HeavyShock(result, targetType, targetUnitId, hitValue)
  elseif abilityId == LCH.Orphic.constants.fate_sealer_id then
    LCH.Orphic.FateSealer(result, targetType, targetUnitId, hitValue)
  elseif LCH.Orphic.constants.xoryn_immune_id[abilityId] then
    LCH.Orphic.XorynImmune(result, targetType, targetUnitId, hitValue)
  elseif abilityId == LCH.Orphic.constants.breakout_id then
    LCH.Orphic.Breakout(result, targetType, targetUnitId, hitValue)
  elseif abilityId == LCH.Orphic.constants.shield_throw_id then
    LCH.Orphic.ShieldThrow(result, targetType, targetUnitId, hitValue)

  elseif abilityId == LCH.Xoryn.constants.knot_carry_id then
    LCH.Xoryn.KnotCarry(result, targetType, targetUnitId, hitValue)
  elseif abilityId == LCH.Xoryn.constants.glass_stomp_id then
    LCH.Xoryn.SplinteredBurst(result, targetType, targetUnitId, hitValue)
  elseif abilityId == LCH.Xoryn.constants.arcane_conveyance_debuff_id then
    LCH.Xoryn.ArcaneConveyance(result, targetType, targetUnitId, hitValue)
  elseif abilityId == LCH.Xoryn.constants.necrotic_barrage_id then
    LCH.Xoryn.NecroticBarrage(result, targetType, targetUnitId, hitValue)
  elseif abilityId == LCH.Xoryn.constants.accelerating_charge_id then
    LCH.Xoryn.AcceleratingCharge(result, targetType, targetUnitId, hitValue)
  elseif abilityId == LCH.Xoryn.constants.tempest_id then
    LCH.Xoryn.Tempest(result, targetType, targetUnitId, hitValue)
  elseif abilityId == LCH.Xoryn.constants.fluctuating_current_id then
    LCH.Xoryn.FluctuatingCurrent(result, targetType, targetUnitId, hitValue)
  elseif abilityId == LCH.Xoryn.constants.overloaded_current_id then
    LCH.Xoryn.OverloadedCurrent(result, targetType, targetUnitId, hitValue)

  elseif abilityId == LCH.Xynizata.constants.crystal_bolt_id then
    LCH.Xynizata.CrystalBolt(result, targetType, targetUnitId, hitValue)
  elseif abilityId == LCH.Xynizata.constants.crystal_burst_id then
    LCH.Xynizata.CrystalBurst(result, targetType, targetUnitId, hitValue)
  elseif abilityId == LCH.Xynizata.constants.piercing_beam_id then
    LCH.Xynizata.PiercingBeam(result, targetType, targetUnitId, hitValue)
  elseif abilityId == LCH.Xynizata.constants.vitrify_id then
    LCH.Xynizata.Vitrify(result, targetType, targetUnitId, hitValue)

  elseif abilityId == LCH.Dariel.constants.powerful_throw_id then
    LCH.Dariel.PowerfulThrow(result, targetType, targetUnitId, hitValue, abilityId)

  end
end

function LCH.UpdateTick(gameTimeMs)
  local timeSec = GetGameTimeSeconds()

  LCH.Xynizata.UpdateTick(timeSec)

  if IsUnitInCombat("boss1") then
    if not LCH.status.inCombat then
      -- If it switched from non-combat to combat, re-check boss names.
      LCH.BossesChanged()
    end
    LCH.status.inCombat = true
  end

  if LCH.status.inCombat == false then
    return
  end
  
  -- Boss 1: Zilyesset
  if LCH.status.isZilyesset then
    LCH.Zilyesset.UpdateTick(timeSec)
  end

  -- Boss 2: Orphic
  if LCH.status.isOrphic then
    LCH.Orphic.UpdateTick(timeSec)
  end

  -- Boss 3: Xoryn
  if LCH.status.isXoryn then
    LCH.Xoryn.UpdateTick(timeSec)
  end

end

function LCH.DeathState(event, unitTag, isDead)
  if unitTag == "player" and not isDead and not IsUnitInCombat("boss1") then
    -- I just resurrected, and it was a wipe or we killed the boss.
    -- Remove all UI
    LCH.ClearUIOutOfCombat()
  end
end

function LCH.CombatState(eventCode, inCombat)
  local currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("boss1", POWERTYPE_HEALTH)
  -- Do not change combat state if you are dead, or the boss is not full.

  -- Do not do anything outside of boss fights.
  if maxTargetHP == 0 or maxTargetHP == nil then
    LCH.ClearUIOutOfCombat()
    return
  end
  if currentTargetHP < 0.99*maxTargetHP or IsUnitDead("player") then
    return
  end
  if inCombat then
    LCH.status.inCombat = true
    LCH.ResetStatus()
    LCH.BossesChanged()
  else
    LCH.ClearUIOutOfCombat()
  end
end

function LCH.ResetStatus()
  LCH.status.debuffTracker = {}
  LCH.status.unitDamageTaken = {}

  LCH.Common.Init()
  LCH.Zilyesset.Init()
  LCH.Orphic.Init()
  LCH.Xoryn.Init()

  LCH.status.mainTankTag = ""
end

function LCH.GetBossName()
  -- 1 to 6 so far
  for i = 1,MAX_BOSSES do
    local name = string.lower(GetUnitName("boss" .. tostring(i)))
    if name ~= nil and name ~= "" then
      return name
    end
  end
  return ""
end

function LCH.BossesChanged()
  local bossName = LCH.GetBossName()
  local lastBossName = LCH.status.currentBoss
  LCH:Trace(1, string.format(
    "Boss change. Name = " .. bossName .. ". Last boss name = " .. lastBossName
  ))
  if bossName ~= nil then
    LCH.status.currentBoss = bossName
    
    LCH.status.isZilyesset = false
    LCH.status.isOrphic = false
    LCH.status.isXoryn = false
    LCH.status.isHMBoss = false

    LCH.Zilyesset.RemovePadIcons()
    LCH.Orphic.RemoveMirrorIcons()

    local currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("boss1", POWERTYPE_HEALTH)
    local hardmodeHealth = {
      [LCH.data.zilyessetName] = 40000000, -- vet ?, HM 48.9M
      [LCH.data.orphicName] = 80000000,  -- vet ?, HM 97.8M
      [LCH.data.xorynName] = 100000000, -- vet: ?, HM 118.8M
    }

    -- Check for HM.
    if bossName ~= nil and maxTargetHP ~= nil and hardmodeHealth[bossName] ~= nil then
      if maxTargetHP > hardmodeHealth[bossName] then
        LCH.status.isHMBoss = true
      else
        LCH.status.isHMBoss = false
      end
    end

    if string.match(bossName, LCH.data.zilyessetName) then
      LCH.status.isZilyesset = true
      LCH.Zilyesset.AddPadIcons()
    elseif string.match(bossName, LCH.data.orphicName) then
      LCH.status.isOrphic = true
      LCH.Orphic.AddMirrorIcons()
    elseif string.match(bossName, LCH.data.xorynName) then
      LCH.status.isXoryn = true
    end
  end
end

function LCH.PlayerActivated()
  -- Disable all visible UI elements at startup.
  LCH.UnlockUI(false)

  if GetZoneId(GetUnitZoneIndex("player")) ~= LCH.data.lucentCitadelId then
    return
  else
    LCH.units = {}
    LCH.unitsTag = {}
  end

  if not LCH.active and not LCH.savedVariables.hideWelcome then
    d(GetString(LCH_InitMSG))
  end
  LCH.active = true
  LCHStatusLabelAddonName:SetText("Lucent Citadel Helper " .. LCH.version)

  EVENT_MANAGER:UnregisterForEvent(LCH.name .. "CombatEvent", EVENT_COMBAT_EVENT )
  EVENT_MANAGER:RegisterForEvent(LCH.name .. "CombatEvent", EVENT_COMBAT_EVENT, LCH.CombatEvent)
  
  -- Buffs/debuffs
  EVENT_MANAGER:UnregisterForEvent(LCH.name .. "Buffs", EVENT_EFFECT_CHANGED )
  EVENT_MANAGER:RegisterForEvent(LCH.name .. "Buffs", EVENT_EFFECT_CHANGED, LCH.EffectChanged)
  
  -- Boss change
  EVENT_MANAGER:UnregisterForEvent(LCH.name .. "BossChange", EVENT_BOSSES_CHANGED, LCH.BossesChanged)
  EVENT_MANAGER:RegisterForEvent(LCH.name .. "BossChange", EVENT_BOSSES_CHANGED, LCH.BossesChanged)
  
  -- Combat state
  EVENT_MANAGER:UnregisterForEvent(LCH.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE, LCH.CombatState)
  EVENT_MANAGER:RegisterForEvent(LCH.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE, LCH.CombatState)
  
  -- Death state
  EVENT_MANAGER:UnregisterForEvent(LCH.name .. "DeathState", EVENT_UNIT_DEATH_STATE_CHANGED, LCH.DeathState)
  EVENT_MANAGER:RegisterForEvent(LCH.name .. "DeathState", EVENT_UNIT_DEATH_STATE_CHANGED, LCH.DeathState)
  
  -- Ticks
  EVENT_MANAGER:UnregisterForUpdate(LCH.name.."UpdateTick")
  EVENT_MANAGER:RegisterForUpdate(LCH.name.."UpdateTick", 1000/10, LCH.UpdateTick)
end

function LCH.OnAddonLoaded(event, addonName)
	if addonName ~= LCH.name then
		return
	end

  LCH.savedVariables = ZO_SavedVars:NewAccountWide("LucentCitadelHelperSavedVariables", 2, nil, LCH.settings)
  LCH.RestorePosition()
  LCH.Menu.AddonMenu()
  SLASH_COMMANDS["/lch"] = LCH.CommandLine
  
	EVENT_MANAGER:UnregisterForEvent(LCH.name, EVENT_ADD_ON_LOADED )
	EVENT_MANAGER:RegisterForEvent(LCH.name .. "PlayerActive", EVENT_PLAYER_ACTIVATED,
    LCH.PlayerActivated)
end

EVENT_MANAGER:RegisterForEvent( LCH.name, EVENT_ADD_ON_LOADED, LCH.OnAddonLoaded )
