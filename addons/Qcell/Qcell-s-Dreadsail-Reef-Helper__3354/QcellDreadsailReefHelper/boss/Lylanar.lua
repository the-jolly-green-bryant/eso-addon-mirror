QDRH = QDRH or {}
local QDRH = QDRH
QDRH.Lylanar = {}

-- UpdateDestructiveEmber / UpdatePiercingHailstone do not toggle
-- hidden UI status, since the bubble can be taken outside combat.
function QDRH.Lylanar.UpdateDestructiveEmber(changeType, numStacks, unitTag)
  if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
    local displayName = GetUnitDisplayName(unitTag)
    
    local strValue = "0"
    local strName = QDRH.trimName(displayName)
    if numStacks ~= nil then 
      strValue = tostring(numStacks)
    end
    QDRHStatusLabel1Value:SetText(strValue .. "s " .. strName)
    if QDRH.savedVariables.showDomeIcon then
      QDRH.AddIcon(unitTag, "QcellDreadsailReefHelper/icons/kingfire.dds")
    end
  elseif changeType == EFFECT_RESULT_FADED then
    QDRHStatusLabel1Value:SetText("-")
    if QDRH.savedVariables.showDomeIcon then
      QDRH.RemoveIcon(unitTag)
    end
    if unitTag == "player" then
      QDRH.status.lastDestructiveEmber = GetGameTimeSeconds()
    end
  end
  
end

function QDRH.Lylanar.UpdatePiercingHailstone(changeType, numStacks, unitTag)
  if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
    local displayName = GetUnitDisplayName(unitTag)
    
    local strValue = "0"
    local strName = ""
    if numStacks ~= nil then 
      strValue = tostring(numStacks)
    end
    if displayName ~= nil then
      if string.len(displayName) > 6 then
        strName = string.sub(displayName, 1, 6)
      else
        strName = displayName
      end
    end

    QDRHStatusLabel1RightValue:SetText(strValue .. "s " .. strName)
    if QDRH.savedVariables.showDomeIcon then
      QDRH.AddIcon(unitTag, "QcellDreadsailReefHelper/icons/snowflake.dds")
    end
    
  elseif changeType == EFFECT_RESULT_FADED then
    QDRHStatusLabel1RightValue:SetText("-")
    if QDRH.savedVariables.showDomeIcon then
      QDRH.RemoveIcon(unitTag)
    end
    if unitTag == "player" then
      QDRH.status.lastPiercingHailstone = GetGameTimeSeconds()
    end
  end
end

function QDRH.Lylanar.ImminentBlister(result, targetUnitId)
  -- Note: If I plan to track faded , I should be using 168525 rather than 166522. Using a fixed 10s timer now.
  -- BEGIN: boss casts it -> ignore (2s before the debuff)
  -- EFFECT_GAINED_DURATION: Imminent Blister (166522) : [1000]",
  -- EFFECT_GAINED_DURATION: Imminent Blister (168525) : [10000],
  if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
    local isDPS, isHeal, isTank = GetPlayerRoles()
    -- Only relevant for tanks.
    if isTank then
      QDRH.status.lastFireImminentTime = GetGameTimeSeconds()
      QDRH.status.lastFireImminentPlayer = QDRH.GetNameForId(targetUnitId)
    end
  elseif result == ACTION_RESULT_EFFECT_FADED then
    QDRHMessage2:SetHidden(true)
    QDRHMessage2Label:SetHidden(true)
  end
end
--QDRH.Lylanar.ImminentChill(ACTION_RESULT_EFFECT_GAINED_DURATION, 36595)
function QDRH.Lylanar.ImminentChill(result, targetUnitId)
  if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
    local isDPS, isHeal, isTank = GetPlayerRoles()
    -- Only relevant for tanks.
    if isTank then
      QDRH.status.lastIceImminentTime = GetGameTimeSeconds()
      QDRH.status.lastIceImminentPlayer = QDRH.GetNameForId(targetUnitId)
    end
  elseif result == ACTION_RESULT_EFFECT_FADED then
    QDRHMessage2:SetHidden(true)
    QDRHMessage2Label:SetHidden(true)
  end
end

function QDRH.Lylanar.BlisteringFragility(result, targetUnitId)
  if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
    QDRH.status.lastFireFragilityTime = GetGameTimeSeconds()
    QDRH.status.lastFireFragilityPlayer = QDRH.GetNameForId(targetUnitId)
  elseif result == ACTION_RESULT_EFFECT_FADED then
    -- Remove the timer, because it can fade when a player dies.
    -- If no one dies, this line is not needed.
    QDRH.status.lastFireFragilityTime = 0
  end
end

function QDRH.Lylanar.ChillingFragility(result, targetUnitId)
  if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
    QDRH.status.lastIceFragilityTime = GetGameTimeSeconds()
    QDRH.status.lastIceFragilityPlayer = QDRH.GetNameForId(targetUnitId)
  elseif result == ACTION_RESULT_EFFECT_FADED then
    -- Remove the timer, because it can fade when a player dies.
    -- If no one dies, this line is not needed.
    QDRH.status.lastIceFragilityTime = 0
  end
end

--function QDRH.Lylanar.Frostbrand(unitTag, timeSec)
function QDRH.Lylanar.Frostbrand(targetUnitId, timeSec)
  if not QDRH.savedVariables.enableBrandFeature then
    return
  end

  -- This 10s check may not be needed.
  if timeSec - QDRH.status.lastRuneTime > 10 then
    QDRH.status.frostbrandTracker = {}
    QDRH.status.firebrandTracker = {}
  end
  QDRH.status.lastRuneTime = timeSec
  QDRH.status.lastFrostbrand = timeSec
  table.insert(QDRH.status.frostbrandTracker, QDRH.GetNameForId(targetUnitId))
  if QDRH.savedVariables.showRuneIcons and not QDRH.status.isHMBoss then
    QDRH.AddIconForDuration(
      QDRH.GetTagForId(targetUnitId),
      "QcellDreadsailReefHelper/icons/ice-pin.dds", 5000)
  end
  if #QDRH.status.frostbrandTracker == 2 and #QDRH.status.firebrandTracker == 2 then
    QDRH.Lylanar.MatchBrands()
  end
end

--function QDRH.Lylanar.Firebrand(unitTag, timeSec)
function QDRH.Lylanar.Firebrand(targetUnitId, timeSec)
  if not QDRH.savedVariables.enableBrandFeature then
    return
  end

  -- This 10s check may not be needed.
  if timeSec - QDRH.status.lastRuneTime > 10 then
    QDRH.status.frostbrandTracker = {}
    QDRH.status.firebrandTracker = {}
  end
  QDRH.status.lastRuneTime = timeSec
  QDRH.status.lastFirebrand = timeSec
  table.insert(QDRH.status.firebrandTracker, QDRH.GetNameForId(targetUnitId))
  if QDRH.savedVariables.showRuneIcons and not QDRH.status.isHMBoss then
    QDRH.AddIconForDuration(
      QDRH.GetTagForId(targetUnitId),
      "QcellDreadsailReefHelper/icons/fire-pin.dds", 5000)
  end
  if #QDRH.status.frostbrandTracker == 2 and #QDRH.status.firebrandTracker == 2 then
    QDRH.Lylanar.MatchBrands()
  end
end
-- Add a check for last match to nto do 2x
-- HM only. Assumes we have 2 frostbrands and 2 firebrands.
function QDRH.Lylanar.MatchBrands()
  local timeSec = GetGameTimeSeconds()
  if timeSec - QDRH.status.lastBrandMatch < 1 then
    return
  end
  QDRH.status.lastBrandMatch = timeSec
  if QDRH.status.isHMBoss then
    local myDisplayName = GetUnitDisplayName("player")
    local affectedByBrand = false
    local brandPartner = ""
    local affectedIndex = 0
    table.sort(QDRH.status.frostbrandTracker)
    table.sort(QDRH.status.firebrandTracker)
    for i=1,2 do
      if QDRH.status.frostbrandTracker[i] == myDisplayName then
        affectedByBrand = true
        brandPartner = QDRH.status.firebrandTracker[i]
        affectedIndex = i
      elseif QDRH.status.firebrandTracker[i] == myDisplayName then
        affectedByBrand = true
        brandPartner = QDRH.status.frostbrandTracker[i]
        affectedIndex = i
      end
    end
    -- 1 = far (entrance)
    -- 2 = close (middle)

    if affectedByBrand then
      -- Only show me what I have to do.
      if affectedIndex == 1 then
        CombatAlerts.Alert("", "STACK ON:  " .. brandPartner .. " (far)", 0x00FF00FF, SOUNDS.LEVEL_UP, 5000)
      elseif affectedIndex == 2 then
        CombatAlerts.Alert("", "STACK ON:  " .. brandPartner .. " (close)", 0x00FF00FF, SOUNDS.LEVEL_UP, 5000)
      end
      if QDRH.savedVariables.showMyRuneStack then
        QDRH.AddIconForDurationDisplayName(brandPartner, "QcellDreadsailReefHelper/icons/explosion.dds", 5000)
        if QDRH.hasOSI() then
          table.insert(QDRH.status.lylanarGroundMeetingIcon, OSI.CreatePositionIcon(
              QDRH.data.lylanar_brand_meeting_point[affectedIndex][1],
              QDRH.data.lylanar_brand_meeting_point[affectedIndex][2],
              QDRH.data.lylanar_brand_meeting_point[affectedIndex][3],
              "QcellDreadsailReefHelper/icons/meeting-point.dds",
              2 * OSI.GetIconSize()))

          EVENT_MANAGER:RegisterForUpdate(QDRH.name .. "MatchBrands", 5000, function()
            EVENT_MANAGER:UnregisterForUpdate(QDRH.name .. "MatchBrands")
            if QDRH.status.lylanarGroundMeetingIcon ~= nil then
              for k,v in pairs(QDRH.status.lylanarGroundMeetingIcon) do
                OSI.DiscardPositionIcon(v)
              end
              QDRH.status.lylanarGroundMeetingIcon = {}
            end
          end)
        end
      end
    else
      -- Show me all the info, for VOD review / raid leading. May remove this as a default option in the future.
      if QDRH.savedVariables.showRuneIcons then
        for i=1,2 do
          QDRH.AddIconForDurationDisplayName(QDRH.status.frostbrandTracker[i], "QcellDreadsailReefHelper/icons/ice-pin.dds", 5000)
          QDRH.AddIconForDurationDisplayName(QDRH.status.firebrandTracker[i], "QcellDreadsailReefHelper/icons/fire-pin.dds", 5000)
        end
      end
    end
    --[[local runeDebug = "[BRAND]: "
    for i=1,2 do
      local a = QDRH.status.firebrandTracker[i] or ""
      local b = QDRH.status.frostbrandTracker[i] or ""
      runeDebug = runeDebug .. a .. "+" .. b .. ".."
    end
    d(runeDebug)--]]
  end
  QDRH.status.frostbrandTracker = {}
  QDRH.status.firebrandTracker = {}
end


function QDRH.Lylanar.IncendiaryAxe()
  -- Weapon spawn.
  -- Alert added in CCA.
  -- CombatAlerts.Alert("", "Incendiary Axe", 0xFF5733FF, SOUNDS.CHAMPION_POINTS_COMMITTED, 3000)
  QDRH.status.lastIncendiaryAxe = GetGameTimeSeconds()
end

function QDRH.Lylanar.CalamitousSword()
  -- Weapon spawn
  -- Alert added in CCA.
  --CombatAlerts.Alert("", "Calamitous Sword", 0x99CCFFFF, SOUNDS.CHAMPION_POINTS_COMMITTED, 3000)
  QDRH.status.lastCalamitousSword = GetGameTimeSeconds()
end

function QDRH.Lylanar.ScaldingSwell()
  -- Start of shockwave.
  -- It takes somewhere between 5.5 and 12s. In 7 seconds it covered most of the area.
  -- TODO: Shorten this alert?
  -- TODO: store it and remove it once you've taken damage or {DODGED} it. It already went through you.
  CombatAlerts.Alert("", "~~ Fire wave ~~", 0xFF5733FF, SOUNDS.BATTLEGROUND_CAPTURE_FLAG_TAKEN_OWN_TEAM, 5500)
  -- TODO: Add a setting for this madness.
  QDRH.ObnoxiousSound(SOUNDS.BATTLEGROUND_CAPTURE_FLAG_TAKEN_OWN_TEAM, 1)
end

function QDRH.Lylanar.BitingBillow()
  -- Start of shockwave.
  CombatAlerts.Alert("", "~~ Ice wave ~~", 0x99CCFFFF, SOUNDS.BATTLEGROUND_CAPTURE_FLAG_TAKEN_OWN_TEAM, 5500)
  QDRH.ObnoxiousSound(SOUNDS.BATTLEGROUND_CAPTURE_FLAG_TAKEN_OWN_TEAM, 1)
end

function QDRH.Lylanar.Frigidarium()
  -- 1s before the spikes are cast by the other boss
  CombatAlerts.Alert("", "Frigidarium (jump)", 0x99CCFFFF, SOUNDS.CHAMPION_POINTS_COMMITTED, 2500)
  if QDRH.savedVariables.soundAlertOnSpikes then
    QDRH.ObnoxiousSound(SOUNDS.TELVAR_MULTIPLIERMAX, 6)
  end
end

function QDRH.Lylanar.MagmaSpike()
  QDRH.status.lastMagmaSpike = GetGameTimeSeconds()
end

function QDRH.Lylanar.CharredConstriction()
  -- 1s before the spikes are cast by the other boss
  CombatAlerts.Alert("", "Charred Constriction (jump)", 0xFF5733FF, SOUNDS.CHAMPION_POINTS_COMMITTED, 2500)
  if QDRH.savedVariables.soundAlertOnSpikes then
    QDRH.ObnoxiousSound(SOUNDS.TELVAR_MULTIPLIERMAX, 6)
  end
end

function QDRH.Lylanar.GlacialSpike()
  QDRH.status.lastGlacialSpike = GetGameTimeSeconds()
end

function QDRH.Lylanar.MultiLoc()
  if not QDRH.savedVariables.showTeleportIcons then
    return
  end
  local timeSec = GetGameTimeSeconds()
  if timeSec - QDRH.status.lastMultiLoc > 10 then
    QDRH.status.lastMultiLoc = timeSec
    QDRH.Lylanar.ShowTeleportIcons()

    EVENT_MANAGER:RegisterForUpdate(QDRH.name .. "MultiLocIcons", 25000, function() 
      EVENT_MANAGER:UnregisterForUpdate(QDRH.name .. "MultiLocIcons")
      QDRH.Lylanar.HideTeleportIcons()
    end)
  end
end

function QDRH.Lylanar.ShowTeleportIcons()
  if QDRH.status.lylanarTeleportIcons ~= nil and #QDRH.status.lylanarTeleportIcons > 0 then
    QDRH.Lylanar.HideTeleportIcons()
  end
  if QDRH.hasOSI() then
    for i=1,8 do
      table.insert(
        QDRH.status.lylanarTeleportIcons,
        OSI.CreatePositionIcon(
          QDRH.data.lylanar_teleport_positions[i][1],
          QDRH.data.lylanar_teleport_positions[i][2],
          QDRH.data.lylanar_teleport_positions[i][3],
          "QcellDreadsailReefHelper/icons/arrow" .. tostring(i) ..".dds",
          2 * OSI.GetIconSize()))
    end
  end
end

function QDRH.Lylanar.HideTeleportIcons()
  for k, v in pairs(QDRH.status.lylanarTeleportIcons) do
    if QDRH.hasOSI() then
      OSI.DiscardPositionIcon(v)
    end
  end
  QDRH.status.lylanarTeleportIcons = {}
end

function QDRH.Lylanar.Hindered(result, targetUnitId, hitValue)
  -- EFFECT_GAINED_DURATION 12000
  local isDPS, isHeal, isTank = GetPlayerRoles()
  if isDPS then
    return
  end
  if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
    QDRH.AddIconForDuration(
      QDRH.GetTagForId(targetUnitId),
      "QcellDreadsailReefHelper/icons/shattered.dds",
      hitValue)
  elseif result == ACTION_RESULT_HEAL_ABSORBED then
    -- TODO: Track how much healing is left.
  elseif result == ACTION_RESULT_EFFECT_FADED then
    QDRH.RemoveIcon(QDRH.GetTagForId(targetUnitId))
  end
end

function QDRH.Lylanar.SummonFlameHound(targetUnitId)
  -- Implement
  -- Called 3x for each dog spawned, targetUnitId is the new dog id.
  QDRH.status.lylanarFlameHounds = QDRH.status.lylanarFlameHounds + 1
  QDRH.status.lylanarFlameHoundIds[targetUnitId] = true
end

function QDRH.Lylanar.SummonFrostHound(targetUnitId)
  -- Implement
  QDRH.status.lylanarFrostHounds = QDRH.status.lylanarFrostHounds + 1
  QDRH.status.lylanarFrostHoundIds[targetUnitId] = true
end

-- Called on death on every single unit.
function QDRH.Lylanar.HoundDied(targetUnitId)
  -- TODO: Keep the tables updated and just check the tables size. Removing values in lua is slow.
  if QDRH.status.lylanarFlameHoundIds[targetUnitId] and QDRH.status.lylanarFlameHounds > 0 then
    QDRH.status.lylanarFlameHounds = QDRH.status.lylanarFlameHounds - 1
  elseif QDRH.status.lylanarFrostHoundIds[targetUnitId] and QDRH.status.lylanarFrostHounds > 0 then
    QDRH.status.lylanarFrostHounds = QDRH.status.lylanarFrostHounds - 1
  end
end

function QDRH.Lylanar.CinderSurge(result)
  if result == ACTION_RESULT_EFFECT_GAINED then
    QDRH.status.lylanarCinderSurgeActive = true
    -- TODO: Replace id for the cinder surge one.
    EVENT_MANAGER:RegisterForUpdate(QDRH.name .. "CinderSurge", 500, function()
      EVENT_MANAGER:UnregisterForUpdate(QDRH.name .. "CinderSurge")
      -- Only show if it has not been interrupted in 500ms.
      if QDRH.status.lylanarCinderSurgeActive then
        QDRH.status.lylanarCinderSurgeBanner = CombatAlerts.StartBanner(
          "INTERRUPT! |c99CCFF(Ice dome)|r", GetAbilityName(QDRH.data.lylanar_cinder_surge), 0xFF5733FF, QDRH.data.lylanar_cinder_surge, true, nil)
      end
    end)
  elseif result == ACTION_RESULT_EFFECT_FADED then
    QDRH.status.lylanarCinderSurgeActive = false
    if QDRH.status.lylanarCinderSurgeBanner ~= 0 then
      CombatAlerts.DisableBanner(QDRH.status.lylanarCinderSurgeBanner)
      QDRH.status.lylanarCinderSurgeBanner = 0
    end
  end
end

function QDRH.Lylanar.NumbingShards(result)
  if result == ACTION_RESULT_EFFECT_GAINED then
    QDRH.status.turlassilNumbingShardsActive = true
    -- CombatAlerts.StartBanner("INTERRUPT! |cFF5733(Fire dome)|r", "Numbing Shards", 0x99CCFFFF, 166735, true, nil)
    EVENT_MANAGER:RegisterForUpdate(QDRH.name .. "CinderSurge", 500, function()
      EVENT_MANAGER:UnregisterForUpdate(QDRH.name .. "CinderSurge")
      -- Only show if it has not been interrupted in 500ms.
      if QDRH.status.turlassilNumbingShardsActive then
        QDRH.status.turlassilNumbingShardsBanner = CombatAlerts.StartBanner(
          "INTERRUPT! |cFF5733(Fire dome)|r", GetAbilityName(QDRH.data.turlassil_numbing_shards), 0x99CCFFFF, QDRH.data.turlassil_numbing_shards, true, nil)
      end
    end)
  elseif result == ACTION_RESULT_EFFECT_FADED then
    QDRH.status.turlassilNumbingShardsActive = false
    if QDRH.status.turlassilNumbingShardsBanner ~= 0 then
      CombatAlerts.DisableBanner(QDRH.status.turlassilNumbingShardsBanner)
      QDRH.status.turlassilNumbingShardsBanner = 0
    end
  end
end

function QDRH.Lylanar.RemoveLylanarPhase3StackIcons()
  QDRH.DiscardPositionIconList(QDRH.status.lylanarPhase3StackIcons)
  QDRH.status.lylanarPhase3StackIcons = {}
end

function QDRH.Lylanar.ShowLylanarPhase3StackIcons()
  -- TODO: Do not add innner icons on the method above.
  if QDRH.savedVariables.showLylanarPhase3StackIcons and table.getn(QDRH.status.lylanarPhase3StackIcons) == 0 and QDRH.hasOSI() then
    table.insert(QDRH.status.lylanarPhase3StackIcons,
      OSI.CreatePositionIcon(
        QDRH.data.lylanar_phase3_left[1],
        QDRH.data.lylanar_phase3_left[2],
        QDRH.data.lylanar_phase3_left[3],
        "QcellDreadsailReefHelper/icons/arrow.dds",
        0.5 * OSI.GetIconSize()))

    table.insert(QDRH.status.lylanarPhase3StackIcons,
      OSI.CreatePositionIcon(
        QDRH.data.lylanar_phase3_right[1],
        QDRH.data.lylanar_phase3_right[2],
        QDRH.data.lylanar_phase3_right[3],
        "QcellDreadsailReefHelper/icons/arrow.dds",
        0.5 * OSI.GetIconSize()))
  end
end

function QDRH.Lylanar.IsItPhase3()
  -- Phase 3: both Lylanar and Turlassil are in the arena.
  local bossPercentage = {100, 100}
  for i=1, 2 do
    local bossTag = "boss" .. tostring(i)
    local currentHP, maxHP = GetUnitPower(bossTag, POWERTYPE_HEALTH)
    if currentHP ~= nil and maxHP ~= nil and maxHP ~= 0 then
      bossPercentage[i] = currentHP / maxHP * 100
    end
  end
  return bossPercentage[1] < 70 and bossPercentage[2] < 70
end

function QDRH.Lylanar.UpdateTick(timeSec)
  -- Check whether we should display ground arrows.
  if not QDRH.status.lylanarPhase3HasBegun and QDRH.Lylanar.IsItPhase3() then
    QDRH.status.lylanarPhase3HasBegun = true
    QDRH.Lylanar.ShowLylanarPhase3StackIcons()
  end

  -- Fire/Ice Cooldown (self only)
  local cd = QDRH.data.bubble_drop_cooldown
  if QDRH.status.isHMBoss then
    cd = QDRH.data.bubble_drop_cooldown_hm
  end
  local fireDropTime = cd - (timeSec - QDRH.status.lastDestructiveEmber)
  local iceDropTime = cd - (timeSec - QDRH.status.lastPiercingHailstone)
  if fireDropTime > 0 then
    QDRHStatusLabel2Value:SetText(string.format("%.0f", fireDropTime) .. "s")
    QDRHStatusLabel2:SetHidden(not QDRH.savedVariables.showBubbleCooldown)
    QDRHStatusLabel2Value:SetHidden(not QDRH.savedVariables.showBubbleCooldown)
  else
    QDRHStatusLabel2:SetHidden(true)
    QDRHStatusLabel2Value:SetHidden(true)
    QDRHStatusLabel2Value:SetText("-")
  end
  if iceDropTime > 0 then
    QDRHStatusLabel2RightValue:SetText(string.format("%.0f", iceDropTime) .. "s")
    QDRHStatusLabel2Right:SetHidden(not QDRH.savedVariables.showBubbleCooldown)
    QDRHStatusLabel2RightValue:SetHidden(not QDRH.savedVariables.showBubbleCooldown)
  else
    QDRHStatusLabel2Right:SetHidden(true)
    QDRHStatusLabel2RightValue:SetHidden(true)
    QDRHStatusLabel2RightValue:SetText("-")
  end

  local fireImminentTimeLeft = QDRH.data.lylanar_imminent_duration - (timeSec - QDRH.status.lastFireImminentTime)
  if fireImminentTimeLeft > 0 then
    QDRHMessage2Label:SetColor(
      QDRH.data.color.fire[1],
      QDRH.data.color.fire[2],
      QDRH.data.color.fire[3])
    QDRHMessage2Label:SetText(
      "Fire Fragility "
      .. QDRH.trimName(QDRH.status.lastFireImminentPlayer) .. ": "
      .. string.format("%.1f", fireImminentTimeLeft) .. "s")
    QDRHMessage2:SetHidden(not QDRH.savedVariables.showImminentCountdown)
    QDRHMessage2Label:SetHidden(not QDRH.savedVariables.showImminentCountdown)
  else
    QDRHMessage2:SetHidden(true)
    QDRHMessage2Label:SetHidden(true)
  end

  local iceImminentTimeLeft = QDRH.data.lylanar_imminent_duration - (timeSec - QDRH.status.lastIceImminentTime)
  if iceImminentTimeLeft > 0 then
    QDRHMessage1Label:SetText(
      "Ice Fragility "
      .. QDRH.trimName(QDRH.status.lastIceImminentPlayer) .. ": "
      .. string.format("%.1f", iceImminentTimeLeft) .. "s")
    QDRHMessage1Label:SetColor(
      QDRH.data.color.ice[1],
      QDRH.data.color.ice[2],
      QDRH.data.color.ice[3])
    QDRHMessage1:SetHidden(not QDRH.savedVariables.showImminentCountdown)
    QDRHMessage1Label:SetHidden(not QDRH.savedVariables.showImminentCountdown)
  else
    QDRHMessage1:SetHidden(true)
    QDRHMessage1Label:SetHidden(true)
  end

  -- Fire/Ice Fragility
  local fireFragilityTimeLeft = QDRH.data.lylanar_fragility_duration - (timeSec - QDRH.status.lastFireFragilityTime)
  if fireFragilityTimeLeft > 0 then
    QDRHStatusLabel3Value:SetText(
      string.format("%.0f", fireFragilityTimeLeft) .. "s "
      .. QDRH.trimName(QDRH.status.lastFireFragilityPlayer))
    QDRHStatusLabel3:SetHidden(not QDRH.savedVariables.showFragilityCountdown)
    QDRHStatusLabel3Value:SetHidden(not QDRH.savedVariables.showFragilityCountdown)
  else
    QDRHStatusLabel3:SetHidden(true)
    QDRHStatusLabel3Value:SetHidden(true)
  end

  local iceFragilityTimeLeft = QDRH.data.lylanar_fragility_duration - (timeSec - QDRH.status.lastIceFragilityTime)
  if iceFragilityTimeLeft > 0 then 
    QDRHStatusLabel3RightValue:SetText(
      string.format("%.0f", iceFragilityTimeLeft) .. "s "
      .. QDRH.trimName(QDRH.status.lastIceFragilityPlayer))
    QDRHStatusLabel3Right:SetHidden(not QDRH.savedVariables.showFragilityCountdown)
    QDRHStatusLabel3RightValue:SetHidden(not QDRH.savedVariables.showFragilityCountdown)
  else
    QDRHStatusLabel3Right:SetHidden(true)
    QDRHStatusLabel3RightValue:SetHidden(true)
  end

  -- TODO: Add settings.

  if QDRH.status.isHMBoss and QDRH.savedVariables.showNextAxeSword then
    local axeTimeLeft = QDRH.data.lylanar_weapon_cd - (timeSec - QDRH.status.lastIncendiaryAxe)
    if axeTimeLeft > 0 then
      QDRHStatusLabel4Value:SetText(string.format("%.0f", axeTimeLeft) .." s")
    else
      QDRHStatusLabel4Value:SetText("INC")
    end

    local swordTimeLeft = QDRH.data.lylanar_weapon_cd - (timeSec - QDRH.status.lastCalamitousSword)
    if swordTimeLeft > 0 then
      QDRHStatusLabel4RightValue:SetText(string.format("%.0f", swordTimeLeft) .." s")
    else
      QDRHStatusLabel4RightValue:SetText("INC")
    end
  end

  -- Stop the timer as soon as everyone has been freed. (would need to track _GAINED and _FADED events)
  if QDRH.savedVariables.showSpikesCountdown then
    local magmaSpikeTimeLeft   = QDRH.data.lylanar_spike_duration - (timeSec - QDRH.status.lastMagmaSpike)
    local glacialSpikeTimeLeft = QDRH.data.lylanar_spike_duration - (timeSec - QDRH.status.lastGlacialSpike)

    if magmaSpikeTimeLeft > 0 then
      QDRHMessage3Label:SetColor(QDRH.data.color.fire[1], QDRH.data.color.fire[2], QDRH.data.color.fire[3])
      QDRHMessage3Label:SetText("Need Fire Dome: " .. string.format("%.1f", magmaSpikeTimeLeft) .." s")
      QDRHMessage3:SetHidden(false)
      QDRHMessage3Label:SetHidden(false)
    elseif glacialSpikeTimeLeft > 0 then
      QDRHMessage3Label:SetColor(QDRH.data.color.ice[1], QDRH.data.color.ice[2], QDRH.data.color.ice[3])
      QDRHMessage3Label:SetText("Need Ice Dome: " .. string.format("%.1f", glacialSpikeTimeLeft) .." s")
      QDRHMessage3:SetHidden(false)
      QDRHMessage3Label:SetHidden(false)
    else
      QDRHMessage3:SetHidden(true)
      QDRHMessage3Label:SetHidden(true)
    end
  end

  if QDRH.savedVariables.showHoundsAlive then
    QDRHStatusLabel5Value:SetText(tostring(QDRH.status.lylanarFlameHounds))
    QDRHStatusLabel5RightValue:SetText(tostring(QDRH.status.lylanarFrostHounds))
  end
  
  -- Display UI elements needed for this boss.
  QDRHStatus:SetHidden(false)
  QDRHStatusLabel1:SetHidden(not QDRH.savedVariables.showBubbleStacks)
  QDRHStatusLabel1Value:SetHidden(not QDRH.savedVariables.showBubbleStacks)
  QDRHStatusLabel1Right:SetHidden(not QDRH.savedVariables.showBubbleStacks)
  QDRHStatusLabel1RightValue:SetHidden(not QDRH.savedVariables.showBubbleStacks)
  QDRHStatusLabel4:SetHidden(not QDRH.status.isHMBoss)
  QDRHStatusLabel4Value:SetHidden(not QDRH.status.isHMBoss)
  QDRHStatusLabel4Right:SetHidden(not QDRH.status.isHMBoss)
  QDRHStatusLabel4RightValue:SetHidden(not QDRH.status.isHMBoss)
  QDRHStatusLabel5:SetHidden(not QDRH.savedVariables.showHoundsAlive)
  QDRHStatusLabel5Value:SetHidden(not QDRH.savedVariables.showHoundsAlive)
  QDRHStatusLabel5Right:SetHidden(not QDRH.savedVariables.showHoundsAlive)
  QDRHStatusLabel5RightValue:SetHidden(not QDRH.savedVariables.showHoundsAlive)
end
