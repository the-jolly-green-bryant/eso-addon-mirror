OCH = OCH or {}
local OCH = OCH
OCH.Jynorah = {
  lastTitanicClash = 0,
  titanicClashActive = false,
  numPortals = 0,
  lastPortal = 0,

  isFirstTitanicLeap = true,
  lastTitanicLeap = 0,
  numTitanicLeapsSinceClash = 0,

  lastJynHeatRay = 0,
  lastSkorHeatRay = 0,
  breathIcons = {},

  dragonTargetIds = {},
  bothDragonsIdentified = false,
  Dragons = {},

  firstCurseOnSelf = nil,
  lastCurseOnSelf = nil,
  numCurses = 0,
  lastCurseTime = 0,
}

OCH.VALNEER = "Valneer"
OCH.MYRINAX = "Myrinax"

OCH.Jynorah.constants = {
  coldflame_stomp_id = 234521, -- Stomp from Jynorah
  brimstone_stomp_id = 234524, -- Stomp from Skorkhif
  coldflame_surge_id = 234321, -- Fire walls from Jynorah
  brimstone_surge_id = 234330, -- Fire walls from Skorkhif

  blazing_curse_cast_id = 234276, -- Blazing Curse from Skorkhif
  sparking_curse_cast_id = 234000, -- Sparking Curse from Jynorah
  curse_cast_ids = {
    [234276] = true,
    [234000] = true,
  },

  sparking_curse_id = 234008, -- Sparking Curse Debuff
  blazing_curse_id = 234280, -- Blazing Curse Debuff
  curse_ids = {
    [234008] = true,
    [234280] = true,
  },

  jynorah_heat_ray_id = 234141, -- Heat Ray from Jynorah summon
  skorkhif_heat_ray_id = 234161, -- Heat Ray from Skorkhif summon

  incinerating_smash_id = 233594, -- Incinerating Smash
  swift_detonation_id = 234437,

  titanic_clash_id = 232375, -- Titanic Clash phase starts
  titanic_clash_duration = 37.5, -- Duration in seconds of Titanic clash phase

  titanic_clash_valneer_hit = 232460, -- Titanic Clash hit on Valneer
  titanic_clash_myrinax_hit = 232465, -- Titanic Clash hit on Myrinax
  titanic_clash_hits = {
    [232460] = "Valneer",
    [232465] = "Myrinax",
  },

  
  titanic_clash_start_leap_val = 233512, -- Leap at start of Titanic Clash
  titanic_clash_start_leap_myr = 233500, -- Leap at start of Titanic Clash
  titanic_clash_start_ids = {
    [233512] = true,
    [233500] = true,
  },

  myrinax_goaded_breath = 234548, -- Sparkstorm Myrinax Breath Attack
  valneer_goaded_breath = 234558, -- Blazeforged Valneer Breath Attack

  dragon_max_hp = 242176464, -- Dragon HP on vet HM

  myrinax_sparking_bolt = 232243,
  myrinax_monstrous_cleave = 232242,
  myrinax_backhand = 235806,
  valneer_blazing_flame_bolt = 232244,
  valneer_monstrous_cleave = 232254,
  valneer_backhand = 235807,
  -- Each dragon will only target the other dragon to start; e.g. assume a Valneer ability cast will be on Myrinax.
  dragon_ability_to_name = {
    [232243] = "Valneer",
    [232242] = "Valneer",
    [235806] = "Valneer",
    [232244] = "Myrinax",
    [232254] = "Myrinax",
    [235807] = "Myrinax",
  },

  myrinax_leap_upper_al = 233477, -- Myrinax Upper Leap
  myrinax_leap_exit_al = 234704, -- Myrinax Exit Leap
  myrinax_leap_al = 233452, -- Myrinax Middle Leap
  valneer_leap_upper_al = 233489, -- Valneer Upper Leap
  valneer_leap_exit_al = 234722, -- Valneer Exit Leap
  valneer_leap_al = 233466, -- Myrinax Middle Leap
  titanic_leap_ids = {
    [233477] = true,
    [234704] = true,
    [233452] = true,
    [233489] = true,
    [234722] = true,
    [233466] = true,
  },

  titanic_leap_cd = 48,
  titanic_leap_execute_cd = 48,
  titanic_leap_first_cd = 5,

  valneer_tail_slam = 235803,
  myrinax_tail_slam = 235800,
  tail_slam_ids = {
    [235803] = true,
    [235800] = true,
  },

  valneer_reflective_scales = 233330,
  myrinax_reflective_scales = 233321,
  reflective_scales_ids = {
    [233330] = true,
    [233321] = true,
  },

  portal_color_codes = {
    ["BLUE"] = 0x66CCFFFF,
    ["RED"] = 0xFF6600FF,
  },
}

function OCH.Jynorah.Init()
  OCH.Jynorah.lastTitanicClash = 0
  OCH.Jynorah.titanicClashActive = false
  OCH.Jynorah.lastTitanicLeap = GetGameTimeSeconds()
  OCH.Jynorah.isFirstTitanicLeap = true
  OCH.Jynorah.numTitanicLeapsSinceClash = 0

  OCH.Jynorah.numPortals = 0
  OCH.Jynorah.lastPortal = 0

  OCH.Jynorah.lastJynHeatRay = 0
  OCH.Jynorah.lastSkorHeatRay = 0
  OCH.Jynorah.breathIcons = {}
  OCH.Jynorah.dragonTargetIds = {}
  OCH.Jynorah.bothDragonsIdentified = false
  OCH.Jynorah.initializeDragons()

  OCH.Jynorah.firstCurseOnSelf = nil
  OCH.Jynorah.lastCurseOnSelf = nil
  OCH.Jynorah.numCurses = 0
  OCH.Jynorah.lastCurseTime = 0
end

function OCH.Jynorah.initializeDragons()
  OCH.Jynorah.Dragons = {
    ["Myrinax"] = {
      id = nil,
      percent = 100,
      hp = OCH.Jynorah.constants.dragon_max_hp,
      maxhp = OCH.Jynorah.constants.dragon_max_hp,
    },
    ["Valneer"] = {
      id = nil,
      percent = 100,
      hp = OCH.Jynorah.constants.dragon_max_hp,
      maxhp = OCH.Jynorah.constants.dragon_max_hp,
    },
  }
end

function OCH.Jynorah.ClearBreathIcons()
  OCH.DiscardPositionIconList(OCH.Jynorah.breathIcons)
  OCH.Jynorah.breathIcons = {}
end

function OCH.Jynorah.ColdFlameSurge(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER and hitValue > 200 then
    OCH.Alert("", "Surge (you)", 0x66CCFFFF, abilityId, SOUNDS.OBJECTIVE_DISCOVERED, 2000)
  end
end

function OCH.Jynorah.BrimstoneSurge(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER and hitValue > 200 then
    OCH.Alert("", "Surge (you)", 0xFF6600FF, abilityId, SOUNDS.OBJECTIVE_DISCOVERED, 2000)
  end
end

function OCH.Jynorah.Curse(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN and hitValue > 200 then
    local timeSinceLast = GetGameTimeSeconds() - OCH.Jynorah.lastCurseTime
    if timeSinceLast > 10 then
      OCH.Alert("", "Curse", 0xFF0033FF, abilityId, SOUNDS.BATTLEGROUND_CAPTURE_FLAG_TAKEN_OWN_TEAM, 2500)
      OCH.Jynorah.numCurses = OCH.Jynorah.numCurses + 1
      OCH.Jynorah.lastCurseTime = GetGameTimeSeconds()
    end
  end
end

function OCH.Jynorah.ColdflameStomp(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN and hitValue > 100 then
    OCH.Alert("Jynorah", "Coldflame Stomp", 0x66CCFFFF, nil, SOUNDS.DUEL_START, 1500)
  end
end

function OCH.Jynorah.BrimstoneStomp(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN and hitValue > 100 then
    OCH.Alert("Skorkhif", "Brimstone Stomp", 0xFF6600FF, nil, SOUNDS.DUEL_START, 1500)
  end
end

function OCH.Jynorah.JynHeatRay(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN and hitValue > 100 then
    local timeSinceLast = GetGameTimeSeconds() - OCH.Jynorah.lastJynHeatRay
    if timeSinceLast > 10 then
      if OCH.Jynorah.showHeatRay(abilityId) then
        OCH.Alert("Jynorah Summon", "Heat Ray", 0x66CCFFFF, abilityId, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
      end
      OCH.Jynorah.lastJynHeatRay = GetGameTimeSeconds()
    end
  end
end

function OCH.Jynorah.SkorHeatRay(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN and hitValue > 100 then
    local timeSinceLast = GetGameTimeSeconds() - OCH.Jynorah.lastSkorHeatRay
    if timeSinceLast > 10 then
      if OCH.Jynorah.showHeatRay(abilityId) then
        OCH.Alert("Skorkhif Summon", "Heat Ray", 0xFF6600FF, abilityId, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
      end
      OCH.Jynorah.lastSkorHeatRay = GetGameTimeSeconds()
    end
  end
end

function OCH.Jynorah.showHeatRay(abilityId)
  if OCH.savedVariables.showHeatRay == "ALL" then
    return true
  elseif OCH.savedVariables.showHeatRay == "RELEVANT" then
    if abilityId == OCH.Jynorah.constants.jynorah_heat_ray_id and OCH.Jynorah.lastCurseOnSelf == OCH.Jynorah.constants.blazing_curse_id then
      return true
    elseif abilityId == OCH.Jynorah.constants.skorkhif_heat_ray_id and OCH.Jynorah.lastCurseOnSelf == OCH.Jynorah.constants.sparking_curse_id then
      return true
    elseif not OCH.Jynorah.lastCurseOnSelf then
      return true
    end
  end

  return false
end

function OCH.Jynorah.SwiftDetonation(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN and hitValue > 100 then
    OCH.Alert("Jynorah", "Swift Detonation", 0x66CCFFFF, nil, SOUNDS.OBJECTIVE_DISCOVERED, 2000)
  end
end

function OCH.Jynorah.MyrinaxGoadedBreath(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN and hitValue > 100 and hitValue < 3000 then
    OCH.Alert("Myrinax Breath", OCH.GetNameForId(targetUnitId), 0x66CCFFFF, abilityId, SOUNDS.DUEL_START, 2000)

    local icon = OCH.AddGroundIconOnPlayerForDuration(OCH.GetTagForId(targetUnitId), "OsseinCageHelper/icons/meeting-point.dds", hitValue + 1000)
    table.insert(OCH.Jynorah.breathIcons, icon)
  end
end

function OCH.Jynorah.ValneerGoadedBreath(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN and hitValue > 100 and hitValue < 3000 then
    OCH.Alert("Valneer Breath", OCH.GetNameForId(targetUnitId), 0xFF6600FF, abilityId, SOUNDS.DUEL_START, 2000)

    local icon = OCH.AddGroundIconOnPlayerForDuration(OCH.GetTagForId(targetUnitId), "OsseinCageHelper/icons/meeting-point.dds", hitValue + 1000)
    table.insert(OCH.Jynorah.breathIcons, icon)
  end
end

function OCH.Jynorah.ReflectiveScales(abilityId, result, targetType, targetUnitId, hitValue)
  if targetType == COMBAT_UNIT_TYPE_PLAYER and result == ACTION_RESULT_EFFECT_GAINED and hitValue > 100 then
    if OCH.savedVariables.showReflectiveScalesBorder then
      local borderId = "reflectiveScales"
      CombatAlerts.ScreenBorderEnable(0xD22B2BFF, hitValue + 400, borderId)
    end
    
    if OCH.savedVariables.showReflectiveScales then
      CombatAlerts.AlertCast(abilityId, nil, hitValue, {-2, 0})
    end
  end
end

function OCH.Jynorah.TailSlam(abilityId, result, targetType, targetUnitId, hitValue)
  if OCH.savedVariables.showTailSlam and result == ACTION_RESULT_EFFECT_GAINED then
    CombatAlerts.AlertCast(abilityId, nil, 1000, {-2, 0})
  end
end

function OCH.Jynorah.TitanicClash(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN and hitValue > 100 then
    OCH.Jynorah.lastTitanicClash = GetGameTimeSeconds()
    OCH.Jynorah.titanicClashActive = true
    OCH.Jynorah.isFirstTitanicLeap = true
    OCH.Jynorah.numTitanicLeapsSinceClash = 0
  end
end

function OCH.Jynorah.TitanicLeap(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN and hitValue > 100 then
    local timeSinceLast = GetGameTimeSeconds() - OCH.Jynorah.lastTitanicLeap
    if timeSinceLast > 5 then
      OCH.Alert("Titans", "Titanic Leap", 0xCC8747FF, nil, SOUNDS.OBJECTIVE_DISCOVERED, 2000)
      OCH.Jynorah.lastTitanicLeap = GetGameTimeSeconds()
      OCH.Jynorah.isFirstTitanicLeap = false
      OCH.Jynorah.numTitanicLeapsSinceClash = OCH.Jynorah.numTitanicLeapsSinceClash + 1
    end
  end
end

function OCH.Jynorah.UpdateTick(timeSec)
  OCH.Common.panelActive = (
    OCH.savedVariables.showTitanicClash or 
    OCH.savedVariables.showSplitBossHealth or 
    OCH.savedVariables.showDragonBossHealth or 
    OCH.savedVariables.showCausticCarrion
  )
  OCHStatus:SetHidden(not OCH.Common.panelActive)

  OCH.Jynorah.UpdateTitanicClashAndLeapTick(timeSec)
  OCH.Jynorah.UpdateBossHealthTick(timeSec)

  if OCH.status.isHMBoss then
    OCH.Jynorah.UpdateDragonHealthTick(timeSec)
  end
end

function OCH.Jynorah.UpdateTitanicClashAndLeapTick(timeSec)
  OCHStatusLabelJynorah1:SetHidden(not OCH.savedVariables.showTitanicClash)
  OCHStatusLabelJynorah1Value:SetHidden(not OCH.savedVariables.showTitanicClash)

  if OCH.Jynorah.titanicClashActive then
    local delta = timeSec - OCH.Jynorah.lastTitanicClash
    local timeLeft = OCH.Jynorah.constants.titanic_clash_duration - delta

    OCHStatusLabelJynorah1:SetText("Titanic Clash:")
    OCHStatusLabelJynorah1:SetColor(OCH.UnpackRGBA(0xFFD666FF))
    OCHStatusLabelJynorah1Value:SetText(OCH.Jynorah.getTitanicClashSecondsRemainingString(timeLeft))

    if timeLeft <= -5 then
      OCH.Jynorah.titanicClashActive = false
    end
  else
    -- If Titanic Clash is not active, track Titanic Leap
    local delta = timeSec - OCH.Jynorah.lastTitanicLeap
    local titanic_leap_cd = OCH.Jynorah.getTitanicLeapCooldown()
    local timeLeft = titanic_leap_cd - delta

    OCHStatusLabelJynorah1:SetText("Titanic Leap:")
    OCHStatusLabelJynorah1:SetColor(OCH.UnpackRGBA(0xCC8747FF))
    OCHStatusLabelJynorah1Value:SetText(OCH.GetSecondsRemainingString(timeLeft))
  end
end

function OCH.Jynorah.getTitanicLeapCooldown()
  local titanic_leap_cd = nil
  if OCH.Jynorah.isFirstTitanicLeap then
    if OCH.Jynorah.numPortals == 0 then
      titanic_leap_cd = OCH.Jynorah.constants.titanic_leap_first_cd
    else
      -- Cooldown calculation from Titanic Clash hit event on dragon after portal
      titanic_leap_cd = OCH.Jynorah.constants.titanic_leap_first_cd + 3
    end
  else
    titanic_leap_cd = OCH.Jynorah.constants.titanic_leap_cd
    if OCH.Jynorah.numPortals >= 2 then
      titanic_leap_cd = OCH.Jynorah.constants.titanic_leap_execute_cd
    end
    if OCH.Jynorah.numTitanicLeapsSinceClash > 1 then
      titanic_leap_cd = titanic_leap_cd - 5
    end
  end

  return titanic_leap_cd
end

function OCH.Jynorah.getTitanicClashSecondsRemainingString(seconds)
  if seconds > 5 then 
    return string.format("%.0f", seconds) .. "s "
  elseif seconds > 0 then 
    return string.format("%.1f", seconds) .. "s "
  else
    return "-"
  end
end

function OCH.Jynorah.UpdateBossHealthTick(timeSec)
  OCHStatusLabelJynorah2:SetHidden(not OCH.savedVariables.showSplitBossHealth)
  OCHStatusLabelJynorah2Value:SetHidden(not OCH.savedVariables.showSplitBossHealth)

  local jynorahCurrentHP, jynorahMaxHP, jynorahEffmaxHP = GetUnitPower("boss1", POWERTYPE_HEALTH)
  local skorkhifCurrentHP, skorkhifMaxHP, skorkhifEffmaxHP = GetUnitPower("boss2", POWERTYPE_HEALTH)

  local jynorachHpPercentage = jynorahCurrentHP / jynorahMaxHP * 100
  local skorkhifHpPercentage = skorkhifCurrentHP / skorkhifMaxHP * 100

  OCHStatusLabelJynorah2Value:SetText(string.format("|c66CCFF%.1f%%|r / |cFF6600%.1f%%|r", jynorachHpPercentage, skorkhifHpPercentage))
end

-------------------------------------------
-- Dragon HP Tracking specific logic below
-------------------------------------------
function OCH.Jynorah.IdentifyDragonEnemyId(abilityId, result, sourceUnitId, targetUnitId, hitValue, powerType)
  -- Dragons are non-bosses, so we have to check their casts to identify their IDs
  if OCH.Jynorah.bothDragonsIdentified then
    return
  end

  if result == ACTION_RESULT_BEGIN and hitValue > 100 then
    -- Each dragon will only target the other dragon to start; e.g. assume a Valneer ability cast will be on Myrinax.
    local dragonName = OCH.Jynorah.constants.dragon_ability_to_name[abilityId]

    -- If Dragon ID has already been found, return
    if OCH.Jynorah.Dragons[dragonName].id then
      return
    end

    OCH.Jynorah.dragonTargetIds[targetUnitId] = dragonName
    OCH.Jynorah.Dragons[dragonName].id = targetUnitId

    if OCH.Jynorah.Dragons["Myrinax"].id and OCH.Jynorah.Dragons["Valneer"].id then
      OCH.Jynorah.bothDragonsIdentified = true
    end
  end
end

function OCH.Jynorah.TrackCombatEventsToDragons(abilityId, result, targetUnitId, hitValue, powerType)
  if not OCH.savedVariables.showDragonBossHealth then return end

  local targetDragonName = OCH.Jynorah.dragonTargetIds[targetUnitId]

  if targetDragonName then
    if hitValue > 1 then
      -- OCH:Trace(1, string.format("applyHitToDragon, dragonName: %s, ability: %s, abilityId: %d, HitValue: %d, powerType: %d", targetDragonName, GetFormattedAbilityName(abilityId), abilityId, hitValue, powerType))
    end

    OCH.Jynorah.applyHitToDragon(targetDragonName, targetUnitId, hitValue, powerType)
  else
    if not OCH.Jynorah.bothDragonsIdentified then
      OCH.Jynorah.processHitFromOtherDragon(abilityId, targetUnitId, hitValue, powerType)
    end
  end
end

function OCH.Jynorah.applyHitToDragon(dragonName, targetUnitId, hitValue, powerType)
  if OCH.Jynorah.Dragons[dragonName] and hitValue > 1 and powerType ~= 0 then
    OCH.Jynorah.Dragons[dragonName].hp = OCH.Jynorah.Dragons[dragonName].hp - hitValue
    if OCH.Jynorah.Dragons[dragonName].hp < 0 then 
      OCH.Jynorah.Dragons[dragonName].hp = 0 
    end
    OCH.Jynorah.Dragons[dragonName].percent = OCH.Jynorah.Dragons[dragonName].hp / OCH.Jynorah.Dragons[dragonName].maxhp * 100
  end
end

function OCH.Jynorah.TitanicClashHit(abilityId, result, targetType, targetUnitId, hitValue, powerType)
  -- When Titanic Clash hits, reset last titanic leap timer
  OCH.Jynorah.lastTitanicLeap = GetGameTimeSeconds()

  local targetDragonName = OCH.Jynorah.constants.titanic_clash_hits[abilityId]

  if targetDragonName then
    OCH.Jynorah.applyTitanicClashHitToDragon(targetDragonName, targetUnitId, hitValue, powerType)
  end
end

function OCH.Jynorah.applyTitanicClashHitToDragon(dragonName, targetUnitId, hitValue, powerType)
  -- Unfortunately Titanic Clash cannot be tracked by OCH.Jynorah.applyHitToDragon() because the powerType is 0.
  if OCH.Jynorah.Dragons[dragonName] and hitValue > 1000000 then
    OCH.Jynorah.Dragons[dragonName].hp = OCH.Jynorah.Dragons[dragonName].hp - hitValue
    if OCH.Jynorah.Dragons[dragonName].hp < 0 then 
      OCH.Jynorah.Dragons[dragonName].hp = 0 
    end
    OCH.Jynorah.Dragons[dragonName].percent = OCH.Jynorah.Dragons[dragonName].hp / OCH.Jynorah.Dragons[dragonName].maxhp * 100

    zo_callLater(function () OCH.Jynorah.PortalEndBossAssignmentAlert() end, 2250)
  end
end

function OCH.Jynorah.processHitFromOtherDragon(abilityId, targetUnitId, hitValue, powerType)
  -- If a dragon ID has not been determined because they haven't performed an identifying cast yet, we can more accurately
  -- track damage done to that unidentified dragon by assuming both dragons only attack each other to start the fight.

  local targetDragonName = OCH.Jynorah.constants.dragon_ability_to_name[abilityId]

  if targetDragonName then
    OCH.Jynorah.applyHitToDragon(targetDragonName, targetUnitId, hitValue, powerType)
  end
end

function OCH.Jynorah.UpdateDragonHealthTick(timeSec)
  OCHStatusLabelJynorah3:SetHidden(not OCH.savedVariables.showDragonBossHealth)
  OCHStatusLabelJynorah3Value:SetHidden(not OCH.savedVariables.showDragonBossHealth)

  local myrinaxPercent = OCH.Jynorah.Dragons["Myrinax"].percent
  local valneerPercent = OCH.Jynorah.Dragons["Valneer"].percent

  OCHStatusLabelJynorah3Value:SetText(string.format("|c66CCBB%.1f%%|r / |cDD6600%.1f%%|r", myrinaxPercent, valneerPercent))
end

-------------------------------------------
-- Portal Helper logic below
-------------------------------------------
function OCH.Jynorah.CurseDebuff(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_EFFECT_GAINED_DURATION and targetType == COMBAT_UNIT_TYPE_PLAYER then
    if not OCH.Jynorah.firstCurseOnSelf then
      OCH.Jynorah.firstCurseOnSelf = abilityId
    end
    OCH.Jynorah.lastCurseOnSelf = abilityId
  end
end

function OCH.Jynorah.PortalHelper(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN and hitValue > 100 then
    local timeSinceLast = GetGameTimeSeconds() - OCH.Jynorah.lastPortal
    if timeSinceLast > 10 then
      OCH.Jynorah.lastPortal = GetGameTimeSeconds()
      OCH.Jynorah.numPortals = OCH.Jynorah.numPortals + 1

      if OCH.savedVariablesChar.enablePortalHelper then
        local portalColorName = OCH.Jynorah.AssignPortalColor()
        local portalNum = OCH.Jynorah.AssignPortalNum()

        OCH.Alert("Portal Phase", string.format("%s %d", portalColorName, portalNum), 
                  OCH.Jynorah.constants.portal_color_codes[portalColorName], nil, SOUNDS.OBJECTIVE_DISCOVERED, 5000)
      else
        OCH.Alert("Portal Phase", "", nil, nil, SOUNDS.OBJECTIVE_DISCOVERED, 5000)
      end
    end
  end
end

function OCH.Jynorah.AssignPortalColor()
  local portalColor = nil

  if LibCombatAlerts.isTank then
    portalColor = OCH.Jynorah.assignPortalColorToTank()
  else
    if OCH.savedVariablesChar.portalAssignmentLogic == "STATIC" then
      portalColor = OCH.Jynorah.assignPortalColorStatic()
    else
      portalColor = OCH.Jynorah.assignPortalColorDynamic()
    end
  end

  return portalColor
end

function OCH.Jynorah.assignPortalColorStatic()
  -- The portal assignment logic here is based on the color of the first curse the player gets, and then assuming the
  -- player swaps curse debuffs every curse phase. This allows for players to experience "intended" portals despite
  -- deaths and wrong curses during the fight, but players may go in portals with the "wrong" debuff if they catch
  -- wrong curses.
  local even_curse_portals = nil
  if not OCH.Jynorah.firstCurseOnSelf then
    -- Assume is a tank if no curse on self and tank role is not set
    even_curse_portals = OCH.savedVariablesChar.startingBossSide
  else
    if OCH.Jynorah.firstCurseOnSelf == OCH.Jynorah.constants.blazing_curse_id then
      even_curse_portals = "RED"
    else
      even_curse_portals = "BLUE"
    end
  end

  local odd_curse_portals = "RED"
  if even_curse_portals == "RED" then
    odd_curse_portals = "BLUE"
  end

  local portals = {
    [0] = even_curse_portals,
    [1] = odd_curse_portals,
  }
  
  local portalIndex = math.fmod(OCH.Jynorah.numCurses, 2)
  return portals[portalIndex]
end

function OCH.Jynorah.assignPortalColorDynamic()
  -- The portal assignment logic here is based on the color of the last curse the player gets.
  if not OCH.Jynorah.lastCurseOnSelf then
    -- If player has died and currently has no curse debuff, use the static portal assignment logic
    return OCH.Jynorah.assignPortalColorStatic()
  elseif OCH.Jynorah.lastCurseOnSelf == OCH.Jynorah.constants.blazing_curse_id then
    return "BLUE"
  else
    return "RED"
  end
end

function OCH.Jynorah.assignPortalColorToTank()
  -- The portal assignment logic here is for a player with a role set to tank, and relies on the "For Tanks: Starting Boss Side"
  -- setting being set by the user properly.
  local even_curse_portals = OCH.savedVariablesChar.startingBossSide

  local odd_curse_portals = nil
  if even_curse_portals == "RED" then
    odd_curse_portals = "BLUE"
  else
    odd_curse_portals = "RED"
  end

  local portals = {
    [0] = even_curse_portals,
    [1] = odd_curse_portals,
  }
  
  local portalIndex = math.fmod(OCH.Jynorah.numCurses, 2)
  return portals[portalIndex]
end

function OCH.Jynorah.AssignPortalNum()
  local portalNum = 1
  if OCH.savedVariablesChar.portalTeamType == "DRAGON" then
    portalNum = 2
  end

  return portalNum
end

function OCH.Jynorah.PlayerDead()
  OCH.Jynorah.lastCurseOnSelf = nil
end

function OCH.Jynorah.PortalEndBossAssignmentAlert()
  if OCH.savedVariablesChar.enablePortalEndBossAlert and OCH.savedVariablesChar.enablePortalHelper and not LibCombatAlerts.isTank then
    local portalColorName = OCH.Jynorah.AssignPortalColor()

    if portalColorName == "BLUE" then
      OCH.Alert("Ground Phase", "Jynorah Side", 0x66CCFFFF, nil, SOUNDS.OBJECTIVE_DISCOVERED, 3000)
    elseif portalColorName == "RED" then
      OCH.Alert("Ground Phase", "Skorkhif Side", 0xFF6600FF, nil, SOUNDS.OBJECTIVE_DISCOVERED, 3000)
    end
  else
    OCH.Alert("Ground Phase", "", 0x66CCFFFF, nil, SOUNDS.OBJECTIVE_DISCOVERED, 3000)
  end
end