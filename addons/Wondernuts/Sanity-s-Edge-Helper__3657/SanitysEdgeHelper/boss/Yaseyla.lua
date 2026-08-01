SEH = SEH or {}
local SEH = SEH
SEH.Yaseyla = {
  chargeIcons = {},
}

function SEH.Yaseyla.Initialize() 
  SEH.Yaseyla.chargeIcons = {}
end

function SEH.Yaseyla.ClearChargeIcons()
  SEH.DiscardPositionIconList(SEH.Yaseyla.chargeIcons)
  SEH.Yaseyla.chargeIcons = {}
end

function SEH.Yaseyla.WamasuCharge(result, targetType, targetUnitId, hitValue, abilityId)
  if result == ACTION_RESULT_BEGIN  and hitValue > 200 then
    --SEH.Alert("Wamasu", string.format("Charge -> %s", SEH.GetNameForId(targetUnitId)), 0xFFD666FF, abilityId, SOUNDS.OBJECTIVE_DISCOVERED, hitValue)
    CombatAlerts.AlertCast(abilityId, "", hitValue, {-2, 1})

    if SEH.savedVariables.showWamasuChargeIcon and abilityId == SEH.data.yaseyla_wamasu_charge then
      local unitTag = SEH.GetTagForId(targetUnitId)
      local icon = SEH.AddGroundIconOnPlayerForDuration(unitTag, "SanitysEdgeHelper/icons/meeting-point.dds", hitValue + 1000)
      table.insert(SEH.Yaseyla.chargeIcons, icon)
    end
  end
end

function SEH.Yaseyla.Hindered(result, targetUnitId, hitValue)
  local isDPS, isHeal, isTank = GetPlayerRoles()
  if isDPS then
    return
  end
  if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
    SEH.AddIconForDuration(
      SEH.GetTagForId(targetUnitId),
      "SanitysEdgeHelper/icons/shattered.dds",
      hitValue)
  elseif result == ACTION_RESULT_HEAL_ABSORBED then
    -- TODO: Track how much healing is left.
  elseif result == ACTION_RESULT_EFFECT_FADED then
    SEH.RemoveIcon(SEH.GetTagForId(targetUnitId))
  end
end

function SEH.Yaseyla.FrostBombTarget(result, targetType, targetUnitId, hitValue)
  --if targetType == COMBAT_UNIT_TYPE_PLAYER then
    --SEH.Alert("", "Frost Bomb (self)", 0x66CCFFFF, SEH.data.yaseyla_frost_bomb_target, SOUNDS.OBJECTIVE_DISCOVERED, hitValue)
  --end
  if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
    SEH.AddIconForDuration(
      SEH.GetTagForId(targetUnitId),
      "SanitysEdgeHelper/icons/ice-pin.dds",
      hitValue)
  elseif result == ACTION_RESULT_EFFECT_FADED then
    SEH.RemoveIcon(SEH.GetTagForId(targetUnitId))
  end
end

function SEH.Yaseyla.FrostBombApplied(result, targetUnitId, hitValue)
  if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
    SEH.status.yaseylaLastFrostbombs = GetGameTimeSeconds()
    SEH.status.yaseylaIsFirstFrostbombs = false
    SEH.AddIconForDuration(
      SEH.GetTagForId(targetUnitId),
      "SanitysEdgeHelper/icons/ice.dds",
      hitValue)
  elseif result == ACTION_RESULT_EFFECT_FADED then
    SEH.RemoveIcon(SEH.GetTagForId(targetUnitId))
  end
end

function SEH.Yaseyla.Ignite(result, targetUnitId, hitValue)
  -- Ignite Blamer feature, check to see who gets the first ignite tick
  if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
    local timeSec = GetGameTimeSeconds()
    local igniteBlameDelta = timeSec - SEH.status.yaseylaLastIgniteBlame

    if igniteBlameDelta > SEH.data.yaseyla_ignite_blame_cd then
      SEH.status.yaseylaLastIgniteBlame = timeSec
      d(string.format("%s was first to catch fire", SEH.GetNameForId(targetUnitId)))
    end
  end
end

function SEH.Yaseyla.Shrapnel(result, hitValue)
  if result == ACTION_RESULT_BEGIN and hitValue > 1000 then
    SEH.status.yaseylaLastShrapnel = GetGameTimeSeconds()
    SEH.status.yaseylaShrapnelCount = SEH.status.yaseylaShrapnelCount + 1
    SEH.Alert("", "Shrapnel (STACK!)", 0xFF0033FF, SEH.data.yaseyla_deflect, SOUNDS.BATTLEGROUND_CAPTURE_FLAG_TAKEN_OWN_TEAM, hitValue)
  end
end

function SEH.Yaseyla.FireBombs(result, targetType, hitValue)
  if result == ACTION_RESULT_BEGIN then
    SEH.status.yaseylaLastFirebombs = GetGameTimeSeconds()
    SEH.status.yaseylaIsFirstFirebombs = false
    --SEH.Alert("", "Fire Bombs", 0xFF6600FF, SEH.data.yaseyla_fire_bombs, SOUNDS.OBJECTIVE_DISCOVERED, 1500)

    if targetType == COMBAT_UNIT_TYPE_PLAYER then
      CombatAlerts.AlertCast(SEH.data.yaseyla_fire_bombs, "Fire Bombs", hitValue, {-2, 0})
    end
  end
end

function SEH.Yaseyla.ChainPull(result, targetType, hitValue)
  if result == ACTION_RESULT_BEGIN then
    SEH.status.yaseylaLastChains = GetGameTimeSeconds()
    SEH.status.yaseylaIsFirstChains = false
  end
end

function SEH.Yaseyla.CurrentHealthPercentage()
  currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("boss1", POWERTYPE_HEALTH)
  return currentTargetHP / maxTargetHP * 100
end

function SEH.Yaseyla.UpdateTick(timeSec)
  SEHStatus:SetHidden(not (SEH.savedVariables.showShrapnel or SEH.savedVariables.showFirebombs or SEH.savedVariables.showFrostbombs or SEH.savedVariables.showChains))

  local percentageToNextShrapnel = nil
  if SEH.status.isHMBoss then
    percentageToNextShrapnel = SEH.Yaseyla.UpdateShrapnelTick(timeSec)
  end
  SEH.Yaseyla.UpdateFirebombsTick(timeSec, percentageToNextShrapnel)
  SEH.Yaseyla.UpdateFrostbombsTick(timeSec)
  SEH.Yaseyla.UpdateChainsTick(timeSec)
end

function SEH.Yaseyla.UpdateShrapnelTick(timeSec)
  -- Shrapnel on HM is cast at Boss health percentages of 81%, 55%, 25% and every ~52s after 25%.
  SEHStatusLabelYaseyla1:SetHidden(not SEH.savedVariables.showShrapnel)
  SEHStatusLabelYaseyla1Value:SetHidden(not SEH.savedVariables.showShrapnel)

  -- Shrapnel
  local shrapnelDelta = timeSec - SEH.status.yaseylaLastShrapnel
  -- Time left for next cast
  local shrapnelTimeLeft = SEH.data.yaseyla_shrapnel_cd - shrapnelDelta
  -- Time left of damage
  local shrapnelDamageTimeLeft = SEH.data.yaseyla_shrapnel_duration - shrapnelDelta
  
  local percentageToNextShrapnel = nil
  local currentHealthPercentage = SEH.Yaseyla.CurrentHealthPercentage()

  if shrapnelDamageTimeLeft > 0 then
    SEHStatusLabelYaseyla1Value:SetColor(
      SEH.data.color.green[1],
      SEH.data.color.green[2],
      SEH.data.color.green[3])
    if shrapnelDamageTimeLeft > 3 then
      SEHStatusLabelYaseyla1Value:SetText("ACTIVE: " .. string.format("%.0f", shrapnelDamageTimeLeft) .. "s ")
    else
      -- Add a decimal when it approaches 0.
      SEHStatusLabelYaseyla1Value:SetText("ACTIVE: " .. string.format("%.1f", shrapnelDamageTimeLeft) .. "s ")
    end
  
  elseif SEH.status.yaseylaShrapnelCount < 3 then
    local nextShrapnelPercentage = SEH.data.yaseyla_shrapnel_thresholds[SEH.status.yaseylaShrapnelCount + 1]
    percentageToNextShrapnel = currentHealthPercentage - nextShrapnelPercentage
    local displayText = string.format("%.1f", percentageToNextShrapnel) .. "% "
    if percentageToNextShrapnel <= 0 then
      displayText = "INC"
    end

    if shrapnelTimeLeft > 0 then
      displayText = displayText .. " / " .. SEH.GetSecondsRemainingString(shrapnelTimeLeft)
    end

    SEHStatusLabelYaseyla1Value:SetColor(
      SEH.data.color.orange[1],
      SEH.data.color.orange[2],
      SEH.data.color.orange[3])
    SEHStatusLabelYaseyla1Value:SetText(displayText)

  else
    -- If you wipe during green, it would stay green without this color re-set.
    SEHStatusLabelYaseyla1Value:SetColor(
      SEH.data.color.orange[1],
      SEH.data.color.orange[2],
      SEH.data.color.orange[3])
    SEHStatusLabelYaseyla1Value:SetText(SEH.GetSecondsRemainingString(shrapnelTimeLeft))
  end

  return percentageToNextShrapnel
end

function SEH.Yaseyla.UpdateFirebombsTick(timeSec, percentageToNextShrapnel)
  -- Firebombs on HM is cast at every ~24s before execute, and every ~12s in execute.
  SEHStatusLabelYaseyla2:SetHidden(not SEH.savedVariables.showFirebombs)
  SEHStatusLabelYaseyla2Value:SetHidden(not SEH.savedVariables.showFirebombs)
  
  local firebombsDelta = timeSec - SEH.status.yaseylaLastFirebombs

  local currentHealthPercentage = SEH.Yaseyla.CurrentHealthPercentage()

  local firebombsTimeLeft = 0
  if SEH.status.yaseylaIsFirstFirebombs then
    firebombsTimeLeft = SEH.data.yaseyla_firebombs_first_cd - firebombsDelta
  elseif currentHealthPercentage > SEH.data.yaseyla_firebombs_execute_threshold then
    firebombsTimeLeft = SEH.data.yaseyla_firebombs_preexecute_cd - firebombsDelta
  else
    firebombsTimeLeft = SEH.data.yaseyla_firebombs_execute_cd - firebombsDelta
  end

  local secondsRemaining = SEH.GetSecondsRemainingString(firebombsTimeLeft)
  local firebombsPanelStr = secondsRemaining
  local largeFirebombsStr = secondsRemaining

  local percentageToExecute = currentHealthPercentage - SEH.data.yaseyla_firebombs_execute_threshold
  local closeToExecuteThreshold = false

  if percentageToExecute > 0 and percentageToExecute < 5 then
    firebombsPanelStr = string.format("%s [%.1f%%]", secondsRemaining, percentageToExecute)

    local secondsRemainingColor = "E8540B"
    if firebombsTimeLeft > (SEH.data.yaseyla_firebombs_preexecute_cd - SEH.data.yaseyla_firebombs_execute_cd) then
      secondsRemainingColor = "B2E80B"
    end
    largeFirebombsStr = string.format("|c%s%s|r [%.1f%%]", secondsRemainingColor, secondsRemaining, percentageToExecute)

    if currentHealthPercentage < (SEH.data.yaseyla_firebombs_execute_threshold + 3.5) then
      closeToExecuteThreshold = true
    end
  end

  local showLargeFirebombs = SEH.savedVariables.showFirebombsLarge and (firebombsTimeLeft < 5 or closeToExecuteThreshold)

  SEHMessage1:SetHidden(not showLargeFirebombs)
  SEHMessage1Label:SetHidden(not showLargeFirebombs)

  SEHStatusLabelYaseyla2Value:SetText(firebombsPanelStr)
  SEHMessage1Label:SetText(string.format("FIREBOMBS: %s", largeFirebombsStr))
end

function SEH.Yaseyla.UpdateFrostbombsTick(timeSec)
  -- Frostbombs on HM is cast every ~30s. 
  -- We want to show the timer for when frostbombs targets go out, but we only have a reliable way to
  -- track when they explode, so we need to adjust/reduce the cooldown time by about -5s accordingly.
  SEHStatusLabelYaseyla3:SetHidden(not SEH.savedVariables.showFrostbombs)
  SEHStatusLabelYaseyla3Value:SetHidden(not SEH.savedVariables.showFrostbombs)

  local frostbombsDelta = timeSec - SEH.status.yaseylaLastFrostbombs

  local frostbombsTimeLeft = 0
  if SEH.status.yaseylaIsFirstFrostbombs then
    frostbombsTimeLeft = SEH.data.yaseyla_frostbombs_first_cd - frostbombsDelta
  else
    frostbombsTimeLeft = SEH.data.yaseyla_frostbombs_cd - frostbombsDelta
  end

  SEHStatusLabelYaseyla3Value:SetText(SEH.GetSecondsRemainingString(frostbombsTimeLeft))
end

function SEH.Yaseyla.UpdateChainsTick(timeSec)
  -- Chains on HM is cast every ~32s, but sometimes a lot longer in between.
  SEHStatusLabelYaseyla4:SetHidden(not SEH.savedVariables.showChains)
  SEHStatusLabelYaseyla4Value:SetHidden(not SEH.savedVariables.showChains)

  local chainsDelta = timeSec - SEH.status.yaseylaLastChains

  local chainsTimeLeft = 0
  if SEH.status.yaseylaIsFirstChains then
    chainsTimeLeft = SEH.data.yaseyla_chains_first_cd - chainsDelta
  else
    chainsTimeLeft = SEH.data.yaseyla_chains_cd - chainsDelta
  end

  SEHStatusLabelYaseyla4Value:SetText(SEH.GetSecondsRemainingString(chainsTimeLeft))
end
