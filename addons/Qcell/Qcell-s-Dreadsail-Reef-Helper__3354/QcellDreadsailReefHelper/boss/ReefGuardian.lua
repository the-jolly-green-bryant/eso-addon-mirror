QDRH = QDRH or {}
local QDRH = QDRH
QDRH.ReefGuardian = {}

--[[
-- swimming in boss 2: 166794 (raging current) and stam regen=0
-- dying infestation 166639 (40s) debuff after going portal
-- 174835 volatile residue (stacks) poison flowers
-- the more you have the more damage per second you take (dot)
-- 6k per tick
]]--

function QDRH.ReefGuardian.UpdateBuildingStatic(changeType, stackCount, endTime)
  if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
    QDRH.status.buildingStaticStacks = stackCount or 0
    QDRH.status.buildingStaticEndTime = endTime
  elseif changeType == EFFECT_RESULT_FADED then
    QDRH.status.buildingStaticStacks = 0
  end

  QDRH.ReefGuardian.UpdateStacks(GetGameTimeSeconds())
end

function QDRH.ReefGuardian.UpdateVolatileResidue(changeType, stackCount, endTime)
  if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
    QDRH.status.volatileResidueStacks = stackCount or 0
    QDRH.status.volatileResidueEndTime = endTime
  elseif changeType == EFFECT_RESULT_FADED then
    QDRH.status.volatileResidueStacks = 0
  end

  QDRH.ReefGuardian.UpdateStacks(GetGameTimeSeconds())
end

function QDRH.ReefGuardian.UpdateSheltered(result)
  if result == ACTION_RESULT_EFFECT_GAINED then
    QDRH.status.playerSheltered = true
  elseif result == ACTION_RESULT_EFFECT_FADED then
    QDRH.status.playerSheltered = false
  end
end

function QDRH.ReefGuardian.UpdateStacks(timeSec)
  local TOO_MANY_STACKS = 7

  -- TODO: Extract in a common function and pass the array. SetLightningColor(color)
  -- Building Static
  if QDRH.status.buildingStaticStacks < TOO_MANY_STACKS then
    QDRHStatusLabelLightningValue:SetColor(
      QDRH.data.color.orange[1],
      QDRH.data.color.orange[2],
      QDRH.data.color.orange[3])
  else
    QDRHStatusLabelLightningValue:SetColor(
      QDRH.data.color.red[1],
      QDRH.data.color.red[2],
      QDRH.data.color.red[3])
  end
  local lightningTimeLeft = QDRH.status.buildingStaticEndTime - timeSec
  local lightningMessage = tostring(QDRH.status.buildingStaticStacks) .. " stacks"
  if lightningTimeLeft > 0 then
    lightningMessage = lightningMessage .. " (" .. string.format("%.1f", lightningTimeLeft) .. "s)"
  end

  if timeSec - QDRH.status.lastShelterBuildingStaticCleanse < 3 or 
    (lightningTimeLeft > 0 and lightningTimeLeft < 3 and QDRH.status.playerSheltered) then
    -- Theoretically, we still have stacks, but lightning won't fall on us anymore.
    -- Even if the player leaves the shelter, if we displayed "CLEANSED" keep displaying it for 3s.
    if timeSec - QDRH.status.lastShelterBuildingStaticCleanse > 3 then
      QDRH.status.lastShelterBuildingStaticCleanse = timeSec
    end
    QDRHStatusLabelLightningValue:SetText("CLEANSED")
    QDRHStatusLabelLightningValue:SetColor(
      QDRH.data.color.green[1],
      QDRH.data.color.green[2],
      QDRH.data.color.green[3])
    -- No need to update the stacks to 0, there will be an event.
  else
    QDRHStatusLabelLightningValue:SetText(lightningMessage)
  end

  -- Volatile Residue
  if QDRH.status.volatileResidueStacks < TOO_MANY_STACKS then
    QDRHStatusLabelPoisonValue:SetColor(
      QDRH.data.color.orange[1],
      QDRH.data.color.orange[2],
      QDRH.data.color.orange[3])
  else
    QDRHStatusLabelPoisonValue:SetColor(
      QDRH.data.color.red[1],
      QDRH.data.color.red[2],
      QDRH.data.color.red[3])
  end
  local poisonTimeLeft = QDRH.status.volatileResidueEndTime - timeSec
  local poisonMessage = tostring(QDRH.status.volatileResidueStacks) .. " stacks"
  if poisonTimeLeft > 0 then
    poisonMessage = poisonMessage .. " (" .. string.format("%.1f", poisonTimeLeft) .. "s)"
  end
  QDRHStatusLabelPoisonValue:SetText(poisonMessage)

  -- If it's in combat, it's a boss fight and it should show even at 0.
  if not IsUnitInCombat("player") and QDRH.status.buildingStaticStacks == 0 and QDRH.status.volatileResidueStacks == 0 then
    QDRH.ReefGuardian.ShowLightningPoisonUI(false)
    QDRH.status.stacksUIEnabled = false
  else
    -- Display UI elements needed for the stack tracking.
    QDRH.ReefGuardian.ShowLightningPoisonUI(true)
    QDRH.status.stacksUIEnabled = true
  end
end

function QDRH.ReefGuardian.OpenReef()
  QDRH.status.reefGuardianPortalNum = QDRH.status.reefGuardianPortalNum + 1
  QDRH.status.reefGuardianPortalTimes[QDRH.status.reefGuardianPortalNum] = GetGameTimeSeconds()
  if QDRH.savedVariables.showReefAlerts then
    CombatAlerts.Alert("", "Reef " .. tostring(QDRH.status.reefGuardianPortalNum) .. ": OPEN", 0x99FFCCFF, SOUNDS.CHAMPION_POINTS_COMMITTED, 5000)
  end
end

function QDRH.ReefGuardian.ReefDone()
  -- This assumes they will be closed in order of opening.
  QDRH.status.reefGuardianClosedPortals = QDRH.status.reefGuardianClosedPortals + 1
  QDRH.status.reefGuardianPortalTimes[QDRH.status.reefGuardianClosedPortals] = 0
  if QDRH.savedVariables.showReefAlerts then
    CombatAlerts.Alert("", "Reef " .. tostring(QDRH.status.reefGuardianClosedPortals) .. ": DONE", 0x99CCFFFF, SOUNDS.CHAMPION_POINTS_COMMITTED, 3000)
  end
end

function QDRH.ReefGuardian.DrawStratIcons()
  if QDRH.status.reefGuardianStratIcons == nil or #QDRH.status.reefGuardianStratIcons == 0 then
    for k,v in pairs(QDRH.data.guardian_strat_pos) do
      table.insert(QDRH.status.reefGuardianStratIcons,
        QDRH.AddGroundCustomIcon(
          v[1], v[2], v[3],
          "QcellDreadsailReefHelper/icons/arrow" .. tostring(k) ..".dds"))
    end
  end
end

function QDRH.ReefGuardian.ClearStratIcons()
  for k, v in pairs(QDRH.status.reefGuardianStratIcons) do
    if QDRH.hasOSI() then
      OSI.DiscardPositionIcon(v)
    end
  end
  QDRH.status.reefGuardianStratIcons = {}
end

function QDRH.ReefGuardian.KingOrgnumFire(result, hitValue, targetUnitId)
  if QDRH.units == nil or QDRH.units[targetUnitId] == nil then
    return
  end
  if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
    QDRH.AddIconForDuration(QDRH.units[targetUnitId].tag, "QcellDreadsailReefHelper/icons/kingfire.dds", hitValue)
  elseif result == ACTION_RESULT_EFFECT_FADED then
    QDRH.RemoveIcon(QDRH.units[targetUnitId].tag)
  end
end

-- Returns a number 1-6 the closest heart to the player.
-- Returns 0 if there's any error.
function QDRH.ReefGuardian.GetClosestHeart(targetUnitId)
  if QDRH.units == nil or QDRH.units[targetUnitId] == nil then
    return 0
  end
  local heart = 1
  local bestDist = 1000000000
  -- TODO: Do a hard check for y to be < QDRH.data.guardian_portal_y_threshold
  -- to check if a player is in portal.

  for i=1,6 do
    local dist = QDRH.GetUnitToPlaceDist(
      QDRH.units[targetUnitId].tag,
      QDRH.data.guardian_heart_pos[i][1],
      QDRH.data.guardian_heart_pos[i][2],
      QDRH.data.guardian_heart_pos[i][3])
    if dist < bestDist then
      heart = i
      bestDist = dist
    end
  end
  return heart
end

function QDRH.ReefGuardian.CheckPortalPresence(timeSec)
  local activeHeart = {}
  for k,v in pairs(QDRH.status.lastCrabCast) do
    if timeSec - v < 15 then -- crab doesnt do stuff for 10-12s sometimes
      local heart = QDRH.ReefGuardian.GetClosestHeart(k)
      if heart > 0 then
        activeHeart[heart] = true
      end
    end
  end

  local mapControls = {
    QDRHMapLabel1,
    QDRHMapLabel2,
    QDRHMapLabel3,
    QDRHMapLabel4,
    QDRHMapLabel5,
    QDRHMapLabel6,
  }

  for i=1,6 do
    -- activeHeart can be nil or false
    if activeHeart[i] then
      if timeSec - QDRH.status.heartActiveLastTime[i] > 60 then
        QDRH.status.heartActiveLastTime[i] = timeSec
      end
    else
      QDRH.status.heartActiveLastTime[i] = 0
    end
    local heartTime = timeSec - QDRH.status.heartActiveLastTime[i]
    mapControls[i]:SetText(string.format("%.0f", heartTime))
    mapControls[i]:SetHidden(QDRH.status.heartActiveLastTime[i] == 0)
  end

  -- TODO: Match QDRH.status.heartActiveLastTime based on the timers left for wipe, assuming the first portal is always reached first.
  -- And keep the timer counting based on the portal wipe timer.
  -- TODO: once the matching is done, show a floating icon with countdown (like Oaxiltso pools) with the time left on that reef.
  -- TODO: once a reef is closed (based on matching), show a floating icon with the "cooldown" for a Guardian to re-use the hole.
end

function QDRH.ReefGuardian.UpdateTick(timeSec)
  -- Update the last 4 reefs only
  for i=0, 3 do
    local numReef = QDRH.status.reefGuardianPortalNum - i
    if numReef > 0 then
      QDRH.ReefGuardian.UpdateReefWipeTracker(numReef, timeSec)
    end
  end

  if QDRH.status.reefGuardianStartTime == 0 then
    QDRH.status.reefGuardianStartTime = GetGameTimeSeconds()
  end

  QDRH.ReefGuardian.CheckPortalPresence(timeSec)


  -- Update Reef Guardian(s) HPs.
  -- TODO: Remove other HP data if logging is not needed. We only need percentage rendered.
  local bossHealth = {
    currentHP = {},
    maxHP = {},
    percentage = {},
    labels = {
      QDRHStatusLabelGuardian1Value,
      QDRHStatusLabelGuardian2Value,
      QDRHStatusLabelGuardian3Value,
      QDRHStatusLabelGuardian4Value,
      QDRHStatusLabelGuardian5Value,
      QDRHStatusLabelGuardian6Value},
    hide = {},
  }
  -- MAX_BOSSES = 6 as of PTS 8.0.3
  for i=1, 6 do
    local bossTag = "boss" .. tostring(i)
    bossHealth.currentHP[i], bossHealth.maxHP[i] = GetUnitPower(bossTag, POWERTYPE_HEALTH)
    --bossHealth.currentHP[i], bossHealth.maxHP[i] = QDRH.ReefGuardian.GetBossHPForTesting()
    if bossHealth.currentHP[i] ~= nil and bossHealth.maxHP[i] ~= nil and bossHealth.maxHP[i] ~= 0 then
      bossHealth.percentage[i] = bossHealth.currentHP[i] / bossHealth.maxHP[i] * 100
      bossHealth.labels[i]:SetText(string.format("%.2f", bossHealth.percentage[i]) .. " %")
      bossHealth.hide[i] = false
    else
      bossHealth.labels[i]:SetText("-")
      bossHealth.hide[i] = true
    end
  end

  -- TODO: Add a label for "Num. Players in Portal: X"
  -- Implementation: Check all groupX positions and compare y < QDRH.data.guardian_portal_y_threshold

  local acidicVulnerabilityDelta = GetGameTimeSeconds() - QDRH.status.acidicVulnerabilityLast
  if acidicVulnerabilityDelta < 5 then
    local acidicLeft = 5 - acidicVulnerabilityDelta
    QDRHDebuffTime:SetText(string.format("%.1f", acidicLeft) .. "s")
  else
    QDRHDebuffTime:SetText("0")
    QDRHDebuffStacks:SetText("0")
  end

  QDRHDebuff:SetHidden(not QDRH.savedVariables.showAcidicVulnerabilityDebuff)
  QDRHDebuffTexture:SetHidden(not QDRH.savedVariables.showAcidicVulnerabilityDebuff)
  QDRHDebuffStacks:SetHidden(not QDRH.savedVariables.showAcidicVulnerabilityDebuff)
  QDRHDebuffTime:SetHidden(not QDRH.savedVariables.showAcidicVulnerabilityDebuff)

  QDRHStatus:SetHidden(false)
  QDRHStatusLabelGuardian1:SetHidden(bossHealth.hide[1] or not QDRH.savedVariables.showGuardiansHP)
  QDRHStatusLabelGuardian1Value:SetHidden(bossHealth.hide[1] or not QDRH.savedVariables.showGuardiansHP)
  QDRHStatusLabelGuardian2:SetHidden(bossHealth.hide[2] or not QDRH.savedVariables.showGuardiansHP)
  QDRHStatusLabelGuardian2Value:SetHidden(bossHealth.hide[2] or not QDRH.savedVariables.showGuardiansHP)
  QDRHStatusLabelGuardian3:SetHidden(bossHealth.hide[3] or not QDRH.savedVariables.showGuardiansHP)
  QDRHStatusLabelGuardian3Value:SetHidden(bossHealth.hide[3] or not QDRH.savedVariables.showGuardiansHP)
  QDRHStatusLabelGuardian4:SetHidden(bossHealth.hide[4] or not QDRH.savedVariables.showGuardiansHP)
  QDRHStatusLabelGuardian4Value:SetHidden(bossHealth.hide[4] or not QDRH.savedVariables.showGuardiansHP)
  QDRHStatusLabelGuardian5:SetHidden(bossHealth.hide[5] or not QDRH.savedVariables.showGuardiansHP)
  QDRHStatusLabelGuardian5Value:SetHidden(bossHealth.hide[5] or not QDRH.savedVariables.showGuardiansHP)
  QDRHStatusLabelGuardian6:SetHidden(bossHealth.hide[6] or not QDRH.savedVariables.showGuardiansHP)
  QDRHStatusLabelGuardian6Value:SetHidden(bossHealth.hide[6] or not QDRH.savedVariables.showGuardiansHP)

  QDRHMap:SetHidden(not QDRH.savedVariables.showMiniMap)
  QDRHMapTexture:SetHidden(not QDRH.savedVariables.showMiniMap)
end

function QDRH.ReefGuardian.UpdateReefWipeTracker(numReef, timeSec)
  -- numReef any positive value
  -- The position [1,4] on the UI to render
  -- TODO: Increase up to 6 UI elements if there are typically >4 reefs open.
  local numReefPos = (numReef-1)%4 + 1
  local timeLeft = QDRH.data.guardian_heartburn_wipe_time - (timeSec - QDRH.status.reefGuardianPortalTimes[numReef])
  if timeLeft > 0 then
    local messageTimeLeft = string.format("%.0f", timeLeft) .. "s "
    if numReefPos == 1 then
      QDRHStatusLabelGuardianReef1:SetText("Reef Wipe (" .. numReef .. "):")
      QDRHStatusLabelGuardianReef1Value:SetText(messageTimeLeft)
      QDRHStatusLabelGuardianReef1:SetHidden(not QDRH.savedVariables.showReefTracker)
      QDRHStatusLabelGuardianReef1Value:SetHidden(not QDRH.savedVariables.showReefTracker)
    elseif numReefPos == 2 then
      QDRHStatusLabelGuardianReef2:SetText("Reef Wipe (" .. numReef .. "):")
      QDRHStatusLabelGuardianReef2Value:SetText(messageTimeLeft)
      QDRHStatusLabelGuardianReef2:SetHidden(not QDRH.savedVariables.showReefTracker)
      QDRHStatusLabelGuardianReef2Value:SetHidden(not QDRH.savedVariables.showReefTracker)
    elseif numReefPos == 3 then
      QDRHStatusLabelGuardianReef3:SetText("Reef Wipe (" .. numReef .. "):")
      QDRHStatusLabelGuardianReef3Value:SetText(messageTimeLeft)
      QDRHStatusLabelGuardianReef3:SetHidden(not QDRH.savedVariables.showReefTracker)
      QDRHStatusLabelGuardianReef3Value:SetHidden(not QDRH.savedVariables.showReefTracker)
    elseif numReefPos == 4 then
      QDRHStatusLabelGuardianReef4:SetText("Reef Wipe (" .. numReef .. "):")
      QDRHStatusLabelGuardianReef4Value:SetText(messageTimeLeft)
      QDRHStatusLabelGuardianReef4:SetHidden(not QDRH.savedVariables.showReefTracker)
      QDRHStatusLabelGuardianReef4Value:SetHidden(not QDRH.savedVariables.showReefTracker)
    else
      -- Never
    end
  else
    if numReefPos == 1 then
      QDRHStatusLabelGuardianReef1:SetHidden(true)
      QDRHStatusLabelGuardianReef1Value:SetHidden(true)
    elseif numReefPos == 2 then
      QDRHStatusLabelGuardianReef2:SetHidden(true)
      QDRHStatusLabelGuardianReef2Value:SetHidden(true)
    elseif numReefPos == 3 then
      QDRHStatusLabelGuardianReef3:SetHidden(true)
      QDRHStatusLabelGuardianReef3Value:SetHidden(true)
    elseif numReefPos == 4 then
      QDRHStatusLabelGuardianReef4:SetHidden(true)
      QDRHStatusLabelGuardianReef4Value:SetHidden(true)
    else
      -- Never
    end
  end
end

function QDRH.ReefGuardian.ShowLightningPoisonUI(show)
  QDRHStatus:SetHidden(not show)

  local showFeature = show and QDRH.savedVariables.showPoisonLightningStacks
  QDRHStatusLabelLightning:SetHidden(not showFeature)
  QDRHStatusLabelLightningValue:SetHidden(not showFeature)
  QDRHStatusLabelPoison:SetHidden(not showFeature)
  QDRHStatusLabelPoisonValue:SetHidden(not showFeature)
end

function QDRH.ReefGuardian.AcidReflux()
  CombatAlerts.CastAlertsStart(QDRH.data.guardian_acid_reflux, "Acid Reflux", 10000, nil, nil, nil)

  if QDRH.savedVariables.showAcidRefluxFivePools then
    local methodName = QDRH.name .. "AcidReflux " .. GetGameTimeSeconds()
    QDRH.ReefGuardian.DropAcidPools(methodName, 5)
  end
end

function QDRH.ReefGuardian.DropAcidPools(methodName, numberPools)
  if numberPools <= 0 then
    return
  end
  local poolNum = 6 - numberPools
  -- Duration is 1750, slightly shorter so they don't cast overlapping alerts.
  CombatAlerts.CastAlertsStart(QDRH.data.guardian_acid_pool, "Acid Pool " .. poolNum .. "/5", 1750, nil, nil, nil)
  EVENT_MANAGER:RegisterForUpdate(methodName, 1750, function()
    EVENT_MANAGER:UnregisterForUpdate(methodName)
    QDRH.ReefGuardian.DropAcidPools(methodName, numberPools - 1)
  end)
end

function QDRH.ReefGuardian.UpdateAcidicVulnerability(result, hitValue)
  if result == ACTION_RESULT_EFFECT_GAINED then
    QDRH.status.acidicVulnerabilityLast = GetGameTimeSeconds()
    QDRHDebuffStacks:SetText(tostring(hitValue))
  elseif result == ACTION_RESULT_EFFECT_FADED then
    QDRH.status.acidicVulnerabilityLast = 0
    QDRHDebuffStacks:SetText("0")
  end
end

-- Test
function QDRH.ReefGuardian.TestShowAllReefWipes()
  QDRHStatus:SetHidden(false)
  QDRHStatusLabelGuardianReef1:SetHidden(false)
  QDRHStatusLabelGuardianReef1Value:SetHidden(false)
  QDRHStatusLabelGuardianReef2:SetHidden(false)
  QDRHStatusLabelGuardianReef2Value:SetHidden(false)
  QDRHStatusLabelGuardianReef3:SetHidden(false)
  QDRHStatusLabelGuardianReef3Value:SetHidden(false)
  QDRHStatusLabelGuardianReef4:SetHidden(false)
  QDRHStatusLabelGuardianReef4Value:SetHidden(false)
end

function QDRH.ReefGuardian.GetBossHPForTesting()
  local b = math.random(1,10000) -- max
  local a = math.random(1,b) -- current < max
  local c = math.random(1,10000) -- unused

  if math.random(1,10) < 2 then
    a = nil
  end
  if math.random(1,10) < 2 then
    b = nil
  end
  if math.random(1,10) < 2 then
    c = nil
  end
  return a, b, c
end