QDRH = QDRH or {}
local QDRH = QDRH
QDRH.Taleria = {}

-- TODO: Remove if HM does not introduce more complex Deluge mechanics.
function QDRH.Taleria.UpdateRapidDeluge(changeType, unitTag, timeSec)
  if changeType == EFFECT_RESULT_GAINED then
    if timeSec - QDRH.status.lastDeluge > 1 then
      QDRH.status.lastDeluge = timeSec
      -- Triggers once per mechanic.
      -- Will explode after 6s, give the players 1.5s to react (they're already warned by CCA)
      -- Do not add a block, since players now SWIM.
      --[[EVENT_MANAGER:RegisterForUpdate(QDRH.name .. "RapidDelugeBlock", 4500, function() 
        EVENT_MANAGER:UnregisterForUpdate(QDRH.name .. "RapidDelugeBlock")
        CombatAlerts.Alert("", "Bubbles. BLOCK!", 0xFF0000FF, SOUNDS.CHAMPION_POINTS_COMMITTED, hitValue)
        end)--]]
      -- TODO: Add a count-down progress bar as optional.
    end

    if unitTag == "player" then
      QDRH.status.lastDelugeOnYou = timeSec
    else -- other players that are not yourself
      -- You will appear twice, as "player" and group member.
      QDRH.status.delugeTracker[unitTag] = timeSec
      -- Add arrow on top of bubble players
      if QDRH.savedVariables.showDelugeIcons then
        QDRH.AddIconForDuration(unitTag, "QcellDreadsailReefHelper/icons/qbubble.dds", 6000)
      else
        local displayName = GetUnitDisplayName(unitTag)
        if displayName ~= nil and displayName ~= "" then
          QDRH.IconFallback("Rapid Deluge: " .. displayName, 3000, SOUNDS.CHAMPION_POINTS_COMMITTED)
        end
      end
    end
  elseif changeType == EFFECT_RESULT_FADED then
    -- Not needed after AddIconForDuration
    -- QDRH.RemoveIcon(unitTag)
  end
end

function QDRH.Taleria.OpenPortalVenomEvoker()
  -- Aura debuff: nematocyst cloud
  -- Location: North
  -- Color: green
  QDRH.Taleria.OpenPortal("Venom Evoker", 0x65c966FF, QDRH.data.taleria_portal_type_green)
end

function QDRH.Taleria.OpenPortalSeaBoiler()
  -- Aura debuff: Sweltering Heat
  -- Location: South-east
  -- Color: yellow
  QDRH.Taleria.OpenPortal("Sea Boiler", 0xe8dd68FF, QDRH.data.taleria_portal_type_yellow)
end

function QDRH.Taleria.OpenPortalTidalMage()
  -- Aura debuff: suffocating waves
  -- Location: South-west
  -- Color: purple
  QDRH.Taleria.OpenPortal("Tidal Mage", 0xc15adbff, QDRH.data.taleria_portal_type_purple)
end

function QDRH.Taleria.OpenPortal(enemyName, color, portalType)
  if color == nil then
    color = 0x99CCFFFF
  end
  if portalType == nil then
    d("[QDRH] Error: opening a Bridge of unknown type.")
    portalType = 0
  end
  QDRH.status.taleriaPortalNum = QDRH.status.taleriaPortalNum + 1
  QDRH.status.taleriaPortalType[QDRH.status.taleriaPortalNum] = portalType
  QDRH.status.taleriaLastPlatformFallTime = GetGameTimeSeconds()
  if QDRH.savedVariables.showBridgeAlerts then
    CombatAlerts.Alert("", "Bridge " .. tostring(QDRH.status.taleriaPortalNum)
      .. " open: " .. enemyName, color, SOUNDS.CHAMPION_POINTS_COMMITTED, 6000)
  end
  QDRH.Taleria.AddBridgeIcon(portalType)
end

function QDRH.Taleria.StartPortal()
  -- Order: 
  -- 1) Open portal
  -- 2) (2-9s later) Start portal: here the 60s timer begins.
  -- Assumption: They will start in order, we will not have n+1 open before n started.
  -- Calls need to alternate: OpenPortal->StartPortal, OpenPortal->StartPortal, ...
  QDRH.status.taleriaPortalTime[QDRH.status.taleriaPortalNum] = GetGameTimeSeconds()
  if QDRH.status.isHMBoss then
    QDRH.Taleria.DelayedAddPortalPosIcon(QDRH.status.taleriaPortalType[QDRH.status.taleriaPortalNum])
  end
end

function QDRH.Taleria.PortalDone()
  -- There can be 3 open, but still the first unfinished.
  if QDRH.status.taleriaPortalFinishedNum >= QDRH.status.taleriaPortalNum then
    return
  end

  QDRH.status.taleriaPortalFinishedNum = QDRH.status.taleriaPortalFinishedNum + 1
  QDRH.status.taleriaPortalTime[QDRH.status.taleriaPortalFinishedNum] = 0
  QDRH.status.taleriaPortalType[QDRH.status.taleriaPortalFinishedNum] = 0
  QDRH.Taleria.RemoveOldestBridgeIcon()
  if QDRH.savedVariables.showBridgeAlerts then
    CombatAlerts.Alert("", "Bridge " .. tostring(QDRH.status.taleriaPortalFinishedNum) .. ": DONE", 0x99FFCCFF, SOUNDS.CHAMPION_POINTS_COMMITTED, 3000)
  end
end

function QDRH.Taleria.RemovePivotIcon()
  if QDRH.status.taleriaPivotIcon ~= nil then
    if QDRH.hasOSI() then
      OSI.DiscardPositionIcon(QDRH.status.taleriaPivotIcon)
    end
    QDRH.status.taleriaPivotIcon = nil
  end
end

function QDRH.Taleria.AddPivotIcon()
  if QDRH.status.taleriaPivotIcon == nil and QDRH.hasOSI() then
    QDRH.status.taleriaPivotIcon =
      OSI.CreatePositionIcon(
        QDRH.data.taleria_pivot_icon_pos[1],
        QDRH.data.taleria_pivot_icon_pos[2],
        QDRH.data.taleria_pivot_icon_pos[3],
        "OdySupportIcons/icons/green_arrow.dds",
        2 * OSI.GetIconSize())
  end
end

function QDRH.Taleria.RemoveOppositePivotIcon()
  if QDRH.status.taleriaOppositePivotIcon ~= nil then
    if QDRH.hasOSI() then
      OSI.DiscardPositionIcon(QDRH.status.taleriaOppositePivotIcon)
    end
    QDRH.status.taleriaOppositePivotIcon = nil
  end
end

function QDRH.Taleria.AddOppositePivotIcon()
  if QDRH.status.taleriaOppositePivotIcon == nil and QDRH.hasOSI() then
    QDRH.status.taleriaOppositePivotIcon =
      OSI.CreatePositionIcon(
        QDRH.data.taleria_opposite_pivot_icon_pos[1],
        QDRH.data.taleria_opposite_pivot_icon_pos[2],
        QDRH.data.taleria_opposite_pivot_icon_pos[3],
        "QcellDreadsailReefHelper/icons/tornado.dds",
        2 * OSI.GetIconSize())
  end
end

function QDRH.Taleria.AddSlaughterFishIcons()
  if QDRH.savedVariables.showSlaughterfishIcons and table.getn(QDRH.status.taleriaSlaughterFishIcons) == 0 and not QDRH.hasOSI() then
    QDRH.IconFallback("Slaughterfish danger zones active", 5000, SOUNDS.CHAMPION_POINTS_COMMITTED)
    return
  end
  if QDRH.savedVariables.showSlaughterfishIcons and table.getn(QDRH.status.taleriaSlaughterFishIcons) == 0 and QDRH.hasOSI() then
    for i=1,4 do
      table.insert(QDRH.status.taleriaSlaughterFishIcons, 
        OSI.CreatePositionIcon(
          QDRH.data.slaughterfish_pos_list[i][1],
          QDRH.data.slaughterfish_pos_list[i][2],
          QDRH.data.slaughterfish_pos_list[i][3],
          "QcellDreadsailReefHelper/icons/slaughterfish.dds",
          2 * OSI.GetIconSize()))
    end
  end
end

function QDRH.Taleria.RemoveSlaughterFishIcons()
  QDRH.DiscardPositionIconList(QDRH.status.taleriaSlaughterFishIcons)
  QDRH.status.taleriaSlaughterFishIcons = {}
end

function QDRH.Taleria.AddBridgeIcon(portalType)
  if not QDRH.savedVariables.showBridgePositionIcons then
    return
  end
  local colorString = "green"
  local pos = {}
  if portalType == QDRH.data.taleria_portal_type_green then
    colorString = "green"
    pos = QDRH.data.taleria_bridge_green_pos
  elseif portalType == QDRH.data.taleria_portal_type_yellow then
    colorString = "yellow"
    pos = QDRH.data.taleria_bridge_yellow_pos
  elseif portalType == QDRH.data.taleria_portal_type_purple then
    colorString = "purple"
    pos = QDRH.data.taleria_bridge_purple_pos
  else
    if portalType ~= nil then
      d("[QDRH] ERROR: AddBridgeIcon with wrong portalType=" .. tostring(portalType))
    else
      d("[QDRH] ERROR: AddBridgeIcon with nil portalType")
    end
  end

  local numberString = tostring(QDRH.status.taleriaPortalNum)
  local fileName = "QcellDreadsailReefHelper/icons/" .. colorString .. numberString .. ".dds"

  if QDRH.hasOSI() and #pos == 3 then
    table.insert(QDRH.status.taleriaBridgeIcons,
      OSI.CreatePositionIcon(
        pos[1],
        pos[2],
        pos[3],
        fileName,
        2 * OSI.GetIconSize()))
  end
end

function QDRH.Taleria.RemoveOldestBridgeIcon()
  if not QDRH.savedVariables.showBridgePositionIcons then
    return
  end

  if QDRH.status.taleriaBridgeIcons ~= nil and #QDRH.status.taleriaBridgeIcons > 0 then
    if QDRH.hasOSI() then
      OSI.DiscardPositionIcon(QDRH.status.taleriaBridgeIcons[1])
    end
    table.remove(QDRH.status.taleriaBridgeIcons, 1)
  end
end


function QDRH.Taleria.RemoveAllBridgeIcons()
  if not QDRH.savedVariables.showBridgePositionIcons then
    return
  end

  for k, v in pairs(QDRH.status.taleriaBridgeIcons) do
    if QDRH.hasOSI() then
      OSI.DiscardPositionIcon(v)
    end
  end
  QDRH.status.taleriaBridgeIcons = {}
end

function QDRH.Taleria.AddPortalPosIcon(portalType)
  if not QDRH.hasOSI() then
    QDRH.IconFallback("Bridge position icon unavailable", 3000, nil)
    return
  end
  local iconFile = "portalgreen.dds"
  local posOuter = QDRH.data.taleria_bridge_green_portal_outer
  local posInner = QDRH.data.taleria_bridge_green_portal_inner
  if portalType == QDRH.data.taleria_portal_type_green then
    -- set by default
  elseif portalType == QDRH.data.taleria_portal_type_yellow then
    posOuter = QDRH.data.taleria_bridge_yellow_portal_outer
    posInner = QDRH.data.taleria_bridge_yellow_portal_inner
    iconFile = "portalyellow.dds"
  elseif portalType == QDRH.data.taleria_portal_type_purple then
    posOuter = QDRH.data.taleria_bridge_purple_portal_outer
    posInner = QDRH.data.taleria_bridge_purple_portal_inner
    iconFile = "portalpurple.dds"
  else
    -- d
  end
  -- TODO: Store and remove those icons.
  local outerIcon = OSI.CreatePositionIcon(
        posOuter[1],
        posOuter[2],
        posOuter[3],
        "QcellDreadsailReefHelper/icons/" .. iconFile,
        2 * OSI.GetIconSize())

  --[[local innerIcon = OSI.CreatePositionIcon(
        posInner[1],
        posInner[2],
        posInner[3],
        "QcellDreadsailReefHelper/icons/" .. iconFile,
        2 * OSI.GetIconSize())--]]
  if QDRH.status.taleriaPortalPosIcons[QDRH.status.taleriaPortalNum] == nil then
    QDRH.status.taleriaPortalPosIcons[QDRH.status.taleriaPortalNum] = {}
  end
  --table.insert(QDRH.status.taleriaPortalPosIcons[QDRH.status.taleriaPortalNum], innerIcon)
  table.insert(QDRH.status.taleriaPortalPosIcons[QDRH.status.taleriaPortalNum], outerIcon)
end

function QDRH.Taleria.DelayedAddPortalPosIcon(portalType)
  -- Called exactly when the portal timer starts at 60s. (on PortalStart, not PortalOpen!)
  if QDRH.status.taleriaPortalNum == 1 or QDRH.status.taleriaPortalNum == 2 then
    -- If both portals overlap that much, bad luck. But this will not happen until they 
    -- powercreep DPS by 50% more, so a couple more patches at least.

    -- in 30s, call QDRH.Taleria.AddPortalPosIcon(portalType)
    -- in 70s,  call QDRH.Taleria.DiscardPortalPosIcons()
    local callAddName = QDRH.name .. "AddPortalPosIcon" .. tostring(portalType)
    local callDiscardName = QDRH.name .. "DiscardPortalPosIcons" .. tostring(portalType)
    --EVENT_MANAGER:RegisterForUpdate(callAddName , 20000, function() -- Original value, to move there when it matters.
    EVENT_MANAGER:RegisterForUpdate(callAddName , 500, function()
        EVENT_MANAGER:UnregisterForUpdate(callAddName)
        QDRH.Taleria.AddPortalPosIcon(portalType)
      end)
    local localPortalNum = QDRH.status.taleriaPortalNum
    EVENT_MANAGER:RegisterForUpdate(callDiscardName , 70000, function()
        EVENT_MANAGER:UnregisterForUpdate(callDiscardName)
        QDRH.Taleria.DiscardPortalPosIcons(localPortalNum)
      end)
  end
end

function QDRH.Taleria.RemoveStaticPortalStackIcons()
  QDRH.DiscardPositionIconList(QDRH.status.taleriaStaticPortalStackIcons)
  QDRH.status.taleriaStaticPortalStackIcons = {}
end

function QDRH.Taleria.ShowStaticPortalStackIcons()
  -- TODO: Do not add innner icons on the method above.
  if QDRH.savedVariables.showTaleriaStaticPortalStackIcons and table.getn(QDRH.status.taleriaStaticPortalStackIcons) == 0 and not QDRH.hasOSI() then
    QDRH.IconFallback("Static portal stack positions active", 5000, SOUNDS.CHAMPION_POINTS_COMMITTED)
    return
  end
  if QDRH.savedVariables.showTaleriaStaticPortalStackIcons and table.getn(QDRH.status.taleriaStaticPortalStackIcons) == 0 and QDRH.hasOSI() then
    table.insert(QDRH.status.taleriaStaticPortalStackIcons,
      OSI.CreatePositionIcon(
      QDRH.data.taleria_bridge_green_portal_inner[1],
      QDRH.data.taleria_bridge_green_portal_inner[2]-100,
      QDRH.data.taleria_bridge_green_portal_inner[3],
      "QcellDreadsailReefHelper/icons/portalgreen.dds",
      OSI.GetIconSize()))

    table.insert(QDRH.status.taleriaStaticPortalStackIcons,
      OSI.CreatePositionIcon(
        QDRH.data.taleria_bridge_yellow_portal_inner[1],
        QDRH.data.taleria_bridge_yellow_portal_inner[2]-100,
        QDRH.data.taleria_bridge_yellow_portal_inner[3],
        "QcellDreadsailReefHelper/icons/portalyellow.dds",
        OSI.GetIconSize()))

    table.insert(QDRH.status.taleriaStaticPortalStackIcons,
      OSI.CreatePositionIcon(
        QDRH.data.taleria_bridge_purple_portal_inner[1],
        QDRH.data.taleria_bridge_purple_portal_inner[2]-100,
        QDRH.data.taleria_bridge_purple_portal_inner[3],
        "QcellDreadsailReefHelper/icons/portalpurple.dds",
        OSI.GetIconSize()))
  end
end

function QDRH.Taleria.DiscardPortalPosIcons(numPortal)
  if QDRH.status.taleriaPortalPosIcons ~= nil and QDRH.status.taleriaPortalPosIcons[numPortal] ~= nil then
    QDRH.DiscardPositionIconList(QDRH.status.taleriaPortalPosIcons[numPortal])
    QDRH.status.taleriaPortalPosIcons[numPortal] = {}
  end
end

function QDRH.Taleria.DiscardAllPortalPosIcons()
  QDRH.Taleria.DiscardPortalPosIcons(1)
  QDRH.Taleria.DiscardPortalPosIcons(2)
  QDRH.Taleria.DiscardPortalPosIcons(3)
end

function QDRH.Taleria.AddTaleriaClock()
  if not QDRH.hasOSI() or not QDRH.savedVariables.showTaleriaClockIcons then
    return
  end
  if QDRH.status.taleriaClockIcons ~= nil and table.getn(QDRH.status.taleriaClockIcons) == 24 then
    -- Already filled.
    return
  end
  for k, v in pairs(QDRH.data.taleria_clock_pos) do
    if v ~= nil and table.getn(v) == 4 then
      -- add icon
      table.insert(QDRH.status.taleriaClockIcons, 
        OSI.CreatePositionIcon(
          v[1],
          v[2],
          v[3],
          "QcellDreadsailReefHelper/icons/" .. tostring(v[4]) .. ".dds",
          0.5 * OSI.GetIconSize()))
    end
  end
end

function QDRH.Taleria.DiscardTaleriaClock()
  -- QDRH.status.taleriaClockIcons[1..24] = {}
  QDRH.DiscardPositionIconList(QDRH.status.taleriaClockIcons)
  QDRH.status.taleriaClockIcons = {}
end

function QDRH.Taleria.SummonSeaBehemoth()
  -- Track that it started and start counting for the next
  -- First one spawns at 0:15
  -- Subsequent ones at +60s
  local timeSec = GetGameTimeSeconds()
  QDRH.status.taleriaLastSummonBehemoth = timeSec
  QDRH.status.taleriaBehemothSlam[QDRH.status.taleriaBehemothSlamId] = timeSec + QDRH.data.taleria_behemoth_arctic_annihilation_cd_after_spawn
  QDRH.status.taleriaBehemothSlamId = (QDRH.status.taleriaBehemothSlamId + 1)%2
end

function QDRH.Taleria.ArcticAnnihilation()
  -- I can't tell which Sea Behemoth slammed, we pick the one closest to the existing cooldown.
  local timeSec = GetGameTimeSeconds()
  local d0 = math.abs(timeSec - QDRH.status.taleriaBehemothSlam[0])
  local d1 = math.abs(timeSec - QDRH.status.taleriaBehemothSlam[1])
  local slamId = 0
  if d0 <= d1 then
    slamId = 0
  else
    slamId = 1
  end
  QDRH.status.taleriaBehemothSlam[slamId] = timeSec + QDRH.data.taleria_behemoth_arctic_annihilation_cd
end

function QDRH.Taleria.InCleave()
  if not QDRH.savedVariables.showTaleriaInCleave then
    return false
  end
  if QDRH.status.mainTankTag ~= ""
    and QDRH.unitsTag[QDRH.status.mainTankTag] ~= nil
    and QDRH.unitsTag["player"] ~= nil 
    and QDRH.unitsTag[QDRH.status.mainTankTag].id ~= QDRH.unitsTag["player"].id then

    -- Do not calculate for myself.
    local centerDist2 = QDRH.GetPlayerToPlaceDist(
      QDRH.data.taleria_center_pos[1],
      QDRH.data.taleria_center_pos[2],
      QDRH.data.taleria_center_pos[3])
    local tankDist2 = QDRH.GetPlayerDist("player", QDRH.status.mainTankTag)
    if centerDist2 == nil or tankDist2 == nil then
      return false
    end
    -- Current implementation assumes (or simplifies) that you and the tank are at similar distance from the center.
    -- TODO: Increase accuracy. Measure the position to the tank if it was next to you.
    -- Version 0.2: Get vector Center->Tank and change its length to be the same as centerDist (projectedTankPos)
    -- From that point, measure distance projectedTankPos to player and do the check with the same logic.
    -- Version 2b(!): measure angle delta from tank (negative or positive)
    -- (P)layer, (C)enter, (T)ank. Check: {abs_angle(PCT) < X and |PC|<ISLAND_RADIUS}
    if math.sqrt(tankDist2) < math.sqrt(centerDist2)/2 then
      return true
    end
  end
  return false
end

function QDRH.Taleria.AnyBossInCombat()
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

function QDRH.Taleria.FightEnded(bossPercentage, bossTag, currentHP, maxHP)
  if IsUnitDead ~= nil and IsUnitDead("player") then
    return false
  end

  if currentHP ~= nil and maxHP ~= nil and maxHP > 0 and currentHP <= 0 then
    return true
  end
  if bossPercentage ~= nil and bossPercentage <= 0 then
    return true
  end
  if bossTag ~= nil and IsUnitDead ~= nil and IsUnitDead(bossTag) then
    return true
  end

  if IsUnitInCombat ~= nil and
    not IsUnitInCombat("player") and
    not QDRH.Taleria.AnyBossInCombat() then
    return true
  end

  return false
end

function QDRH.Taleria.ShowNextBridgeInc()
  local nextBridge = QDRH.status.taleriaPortalNum + 1
  if nextBridge > 3 then
    QDRHStatusLabelTaleria4:SetHidden(true)
    QDRHStatusLabelTaleria4Value:SetHidden(true)
    return
  end

  QDRHStatusLabelTaleria4:SetText("Next Bridge (" .. nextBridge .. "):")
  QDRHStatusLabelTaleria4Value:SetText("INC")
  QDRHStatusLabelTaleria4:SetHidden(not QDRH.savedVariables.showNextBridge)
  QDRHStatusLabelTaleria4Value:SetHidden(not QDRH.savedVariables.showNextBridge)
end

function QDRH.Taleria.UpdateTick(timeSec)
  -- Cleave range
  if QDRH.Taleria.InCleave() then
    QDRHScreenBorder:SetHidden(false)
    QDRHMessage2Label:SetColor(
      QDRH.data.color.cleave[1],
      QDRH.data.color.cleave[2],
      QDRH.data.color.cleave[3])
    QDRHMessage2Label:SetText("IN CLEAVE")
    QDRHMessage2:SetHidden(false)
    QDRHMessage2Label:SetHidden(false)
  else
    QDRHScreenBorder:SetHidden(true)
    QDRHMessage2:SetHidden(true)
    QDRHMessage2Label:SetHidden(true)
  end

  local showMaelstromDodgeHelper = false
  -- Maelstrom
  local maelstromDelta = timeSec - QDRH.status.taleriaLastMaelstrom
  -- Time left for next cast
  local maelstromTimeLeft = QDRH.data.taleria_maelstrom_cd - maelstromDelta
  -- Time left of damage
  local maelstromDamageTimeLeft = QDRH.data.taleria_maelstrom_duration - maelstromDelta
  if maelstromDamageTimeLeft > 0 then
    QDRHStatusLabelTaleria1Value:SetColor(
      QDRH.data.color.green[1],
      QDRH.data.color.green[2],
      QDRH.data.color.green[3])
    if maelstromDamageTimeLeft > 3 then
      QDRHStatusLabelTaleria1Value:SetText("HEAL: " .. string.format("%.0f", maelstromDamageTimeLeft) .. "s ")
    else
      -- Add a decimal when it approaches 0.
      QDRHStatusLabelTaleria1Value:SetText("HEAL: " .. string.format("%.1f", maelstromDamageTimeLeft) .. "s ")
    end

    showMaelstromDodgeHelper = true
    local dodgeTimeLeft = maelstromDamageTimeLeft - 1.5
    if dodgeTimeLeft > 0 then
      QDRHMessage3Label:SetText("MAELSTROM DODGE IN: |cCCCC66" .. string.format("%.1f", dodgeTimeLeft) .. "s|r")
    else
      QDRHMessage3Label:SetText("MAELSTROM DODGE |cFF0000NOW!|r")
    end
  elseif maelstromTimeLeft > 0 then 
    QDRHStatusLabelTaleria1Value:SetColor(
      QDRH.data.color.orange[1],
      QDRH.data.color.orange[2],
      QDRH.data.color.orange[3])
    QDRHStatusLabelTaleria1Value:SetText(string.format("%.0f", maelstromTimeLeft) .. "s ")
  else
    -- If you wipe during green, it would stay green without this color re-set.
    QDRHStatusLabelTaleria1Value:SetColor(
      QDRH.data.color.orange[1],
      QDRH.data.color.orange[2],
      QDRH.data.color.orange[3])
    QDRHStatusLabelTaleria1Value:SetText("INC")
  end

  local showMessage3 = showMaelstromDodgeHelper and QDRH.savedVariables.showMaelstromDodge and QDRH.status.isHMBoss
  QDRHMessage3:SetHidden(not showMessage3)
  QDRHMessage3Label:SetHidden(not showMessage3)

  local behemoth_cd = QDRH.status.isHMBoss and QDRH.data.taleria_summon_behemoth_cd_hm or QDRH.data.taleria_summon_behemoth_cd
  -- Summon Behemoth
  local summonBehemothTimeLeft = behemoth_cd - (timeSec - QDRH.status.taleriaLastSummonBehemoth)
  if summonBehemothTimeLeft > 0 then
    QDRHStatusLabelTaleria2Value:SetText(string.format("%.0f", summonBehemothTimeLeft) .. "s ")
  else
    QDRHStatusLabelTaleria2Value:SetText("INC")
  end

  if QDRH.savedVariables.showSeaBehemothSlams then
    local slam0Delta = QDRH.status.taleriaBehemothSlam[0] - timeSec
    local slam1Delta = QDRH.status.taleriaBehemothSlam[1] - timeSec
    local numSlamsShown = 0
    local slamString = ""
    -- Show INC at most for 10s.
    if slam0Delta > -10 then
      numSlamsShown = numSlamsShown + 1
      if slam0Delta > 0 then
        slamString = slamString .. string.format("%.0f", slam0Delta) .. "s "
      else 
        slamString = slamString .. "INC"
      end
    end
    if slam1Delta > -10 then
      numSlamsShown = numSlamsShown + 1
      if numSlamsShown == 2 then
        slamString = slamString .. " / "
      end
      if slam1Delta > 0 then
        slamString = slamString .. string.format("%.0f", slam1Delta) .. "s "
      else
        slamString = slamString .. "INC"
      end
    end
    QDRHStatusLabelTop:SetText("Arctic Annihilation: " .. slamString)
    QDRHStatusLabelTop:SetColor(
      QDRH.data.color.teal[1],
      QDRH.data.color.teal[2],
      QDRH.data.color.teal[3])
  end

  -- Storm Wall
  local stormWallDelta = timeSec - QDRH.status.taleriaLastStormWall
  local stormWallTimeLeft = QDRH.data.taleria_storm_wall_cd - stormWallDelta
  local stormWallSpinTimeLeft = QDRH.data.taleria_storm_wall_duration - stormWallDelta
  local timeSinceLastPlatformFall = timeSec - QDRH.status.taleriaLastPlatformFallTime
  local lastPlatformFallGraceTimeLeft = QDRH.data.taleria_platform_fall_storm_wall_grace_period - timeSinceLastPlatformFall
  -- Platform fall stops Winter Storm from spinning.
  if stormWallSpinTimeLeft > 0 and lastPlatformFallGraceTimeLeft < 0  then
    QDRHStatusLabelTaleria3Value:SetColor(
      QDRH.data.color.pink[1],
      QDRH.data.color.pink[2],
      QDRH.data.color.pink[3])
    local directionIcon = "CW"
    if CombatAlerts and not CombatAlerts.__QDRHFallback then
      directionIcon = zo_iconFormatInheritColor("CombatAlerts/art/arrow-cw.dds", 48, 48)
    end
    if not QDRH.status.taleriaLastStormWallClockwise then
      directionIcon = "CCW"
      if CombatAlerts and not CombatAlerts.__QDRHFallback then
        directionIcon = zo_iconFormatInheritColor("CombatAlerts/art/arrow-ccw.dds", 48, 48)
      end
    end

    -- TODO: This overlaps with bridge wipe 3, but I believe there can not be a storm wall and bridge 3 open at the same time.
    -- There may be a corner case of extreme damage where the spin is still happening.
    -- Impact is small, slight UI overlapping for a few seconds.
    QDRHStatusLabelTaleria3Value:SetText("RUN: " .. string.format("%.0f", stormWallSpinTimeLeft) .. "s " .. directionIcon)
  elseif stormWallTimeLeft > 0 or lastPlatformFallGraceTimeLeft > 0 then
    if lastPlatformFallGraceTimeLeft > stormWallTimeLeft then
      stormWallTimeLeft = lastPlatformFallGraceTimeLeft
    end
    QDRHStatusLabelTaleria3Value:SetColor(
      QDRH.data.color.orange[1],
      QDRH.data.color.orange[2],
      QDRH.data.color.orange[3])
    QDRHStatusLabelTaleria3Value:SetText(string.format("%.0f", stormWallTimeLeft) .. "s ")
  else
    QDRHStatusLabelTaleria3Value:SetColor(
      QDRH.data.color.orange[1],
      QDRH.data.color.orange[2],
      QDRH.data.color.orange[3])
    QDRHStatusLabelTaleria3Value:SetText("INC")
  end

  -- 50.9% p1
  -- p2 26%  (southeast) sea boiler yellow

  -- Taleria Next Bridge
  local bossPercentage, bossTag, bossName, currentHP, maxHP, hpSource, effectiveMaxHP =
    QDRH.GetBossHealthPercentByName(QDRH.data.taleriaName)
  -- Safety: wenn nix da → abbrechen
  if QDRH.Taleria.FightEnded(bossPercentage, bossTag, currentHP, maxHP) then
    QDRH.ClearUIOutOfCombat()
    return
  end

  if not bossPercentage then
    QDRH.Taleria.ShowNextBridgeInc()
  else
    -- Thresholds:
  -- Normal 50.9%, 25.9% (yes, I know, it's not 50/25%. Weird)

  -- Vet: 50%, 35%, 20% (+0.9% bad rounding it seems)
    local t1 = 0.51
    local t2 = 0.36
    local t3 = 0.21

    if QDRH.status.taleriaPortalNum == 0 then
      QDRH.Taleria.UpdateNextBridgeTracker(bossPercentage, t1)
    elseif QDRH.status.taleriaPortalNum == 1 then
      QDRH.Taleria.UpdateNextBridgeTracker(bossPercentage, t2)
    elseif QDRH.status.taleriaPortalNum == 2 then
      QDRH.Taleria.UpdateNextBridgeTracker(bossPercentage, t3)
    else
      -- All portals have been open.
      QDRHStatusLabelTaleria4:SetHidden(true)
      QDRHStatusLabelTaleria4Value:SetHidden(true)
    end
  end

  -- Taleria Bridge wipe time
  -- TODO: Make use of Bridge2/Bridge2 to always update those.
  QDRH.Taleria.UpdateBridgeWipeTracker(1, timeSec)
  QDRH.Taleria.UpdateBridgeWipeTracker(2, timeSec)
  QDRH.Taleria.UpdateBridgeWipeTracker(3, timeSec)

  QDRHStatus:SetHidden(false)
  
  QDRHStatusLabelTop:SetHidden(not QDRH.savedVariables.showSeaBehemothSlams)
  QDRHStatusLabelTaleria1:SetHidden(not QDRH.savedVariables.showMaelstrom)
  QDRHStatusLabelTaleria1Value:SetHidden(not QDRH.savedVariables.showMaelstrom)
  QDRHStatusLabelTaleria2:SetHidden(not QDRH.savedVariables.showBehemoth)
  QDRHStatusLabelTaleria2Value:SetHidden(not QDRH.savedVariables.showBehemoth)
  QDRHStatusLabelTaleria3:SetHidden(not QDRH.savedVariables.showWinterStorm)
  QDRHStatusLabelTaleria3Value:SetHidden(not QDRH.savedVariables.showWinterStorm)

  QDRHStatusLabelTaleriaDebuff1:SetHidden(not QDRH.Taleria.MangleDebuffActive())
  QDRHStatusLabelTaleriaDebuff2:SetHidden(not QDRH.Taleria.DefileDebuffActive())
  QDRHStatusLabelTaleriaDebuff3:SetHidden(not QDRH.Taleria.SnareDebuffActive())
end

function QDRH.Taleria.GetBridgeString(numBridge, bridgeType)
  local bridgeString = "Bridge " .. tostring(numBridge) .. " "
  -- Explicitly write the color name for accessibility, so colorblind people can also use it.
  if bridgeType == QDRH.data.taleria_portal_type_green then
    bridgeString = bridgeString .. "Green"
  elseif bridgeType == QDRH.data.taleria_portal_type_yellow then
    bridgeString = bridgeString .. "Yellow"
  elseif bridgeType == QDRH.data.taleria_portal_type_purple then
    bridgeString = bridgeString .. "Purple"
  end
  bridgeString = bridgeString .. ":"
  return bridgeString
end

function QDRH.Taleria.GetBridgeRGB(bridgeType)
  if bridgeType == QDRH.data.taleria_portal_type_green then
    return QDRH.data.color.taleria_green
  elseif bridgeType == QDRH.data.taleria_portal_type_yellow then
    return QDRH.data.color.taleria_yellow
  elseif bridgeType == QDRH.data.taleria_portal_type_purple then
    return QDRH.data.color.taleria_purple
  end
  return QDRH.data.color.ice
end

function QDRH.Taleria.UpdateBridgeWipeTracker(numBridge, timeSec)
  -- Note it uses PortalDone() because it sets type and time to 0.
  local bridgeTimeLeft = QDRH.data.taleria_portal_enrage_time - (timeSec - QDRH.status.taleriaPortalTime[numBridge])
  local bridgeType = QDRH.status.taleriaPortalType[numBridge]
  if bridgeType > 0 then
    --QDRHStatusLabelTaleriaBridge1:SetText("Bridge Wipe (" .. numBridge .. "):") -- this label doesn't change
    local color = QDRH.Taleria.GetBridgeRGB(bridgeType)

    local messageTimeLeft = "-"
    if bridgeTimeLeft > 0 then
      messageTimeLeft = QDRH.GetSecondsString(bridgeTimeLeft)
    end
    if numBridge == 1 then
      QDRHStatusLabelTaleriaBridge1:SetColor(color[1], color[2], color[3])
      QDRHStatusLabelTaleriaBridge1:SetText(QDRH.Taleria.GetBridgeString(numBridge, bridgeType))
      QDRHStatusLabelTaleriaBridge1Value:SetText(messageTimeLeft)
      QDRHStatusLabelTaleriaBridge1:SetHidden(not QDRH.savedVariables.showBridgeTracker)
      QDRHStatusLabelTaleriaBridge1Value:SetHidden(not QDRH.savedVariables.showBridgeTracker)
    elseif numBridge == 2 then
      QDRHStatusLabelTaleriaBridge2:SetColor(color[1], color[2], color[3])
      QDRHStatusLabelTaleriaBridge2:SetText(QDRH.Taleria.GetBridgeString(numBridge, bridgeType))
      QDRHStatusLabelTaleriaBridge2Value:SetText(messageTimeLeft)
      QDRHStatusLabelTaleriaBridge2:SetHidden(not QDRH.savedVariables.showBridgeTracker)
      QDRHStatusLabelTaleriaBridge2Value:SetHidden(not QDRH.savedVariables.showBridgeTracker)
    elseif numBridge == 3 then
      QDRHStatusLabelTaleriaBridge3:SetColor(color[1], color[2], color[3])
      QDRHStatusLabelTaleriaBridge3:SetText(QDRH.Taleria.GetBridgeString(numBridge, bridgeType))
      QDRHStatusLabelTaleriaBridge3Value:SetText(messageTimeLeft)
      QDRHStatusLabelTaleriaBridge3:SetHidden(not QDRH.savedVariables.showBridgeTracker)
      QDRHStatusLabelTaleriaBridge3Value:SetHidden(not QDRH.savedVariables.showBridgeTracker)
    else
      d("[QDRH] UpdateBridgeWipeTracker(" .. numBridge .. ",_): too many open bridges. Send a screenshot/vod to Qcell.")
    end
  else
    if numBridge == 1 then
      QDRHStatusLabelTaleriaBridge1:SetHidden(true)
      QDRHStatusLabelTaleriaBridge1Value:SetHidden(true)
      QDRHStatusLabelTaleriaBridge1Value:SetText("-")
    elseif numBridge == 2 then
      QDRHStatusLabelTaleriaBridge2:SetHidden(true)
      QDRHStatusLabelTaleriaBridge2Value:SetHidden(true)
      QDRHStatusLabelTaleriaBridge2Value:SetText("-")
    elseif numBridge == 3 then
      QDRHStatusLabelTaleriaBridge3:SetHidden(true)
      QDRHStatusLabelTaleriaBridge3Value:SetHidden(true)
      QDRHStatusLabelTaleriaBridge3Value:SetText("-")
    else
      -- Nothing
    end
  end
end

function QDRH.Taleria.UpdateNextBridgeTracker(bossPercentage, threshold)
  local percentageLeft = (bossPercentage - threshold) * 100
  if (percentageLeft > 0) then
    QDRHStatusLabelTaleria4:SetText("Next Bridge (" .. QDRH.status.taleriaPortalNum + 1 .. "):")
    QDRHStatusLabelTaleria4Value:SetText(string.format("%.1f", percentageLeft) .. "% ")
    QDRHStatusLabelTaleria4:SetHidden(not QDRH.savedVariables.showNextBridge)
    QDRHStatusLabelTaleria4Value:SetHidden(not QDRH.savedVariables.showNextBridge)
  else
    -- Past threshold, waiting to open.
    QDRHStatusLabelTaleria4:SetText("Next Bridge (" .. QDRH.status.taleriaPortalNum+1 .. "):")
    QDRHStatusLabelTaleria4Value:SetText("INC")
    QDRHStatusLabelTaleria4:SetHidden(not QDRH.savedVariables.showNextBridge)
    QDRHStatusLabelTaleria4Value:SetHidden(not QDRH.savedVariables.showNextBridge)
  end
end

function QDRH.Taleria.CrashingWave(abilityId, sourceName, hitValue)
  -- Do not show the alert for players far on the bridge or on portal.
  if QDRH.savedVariables.showCrashingWave then
    -- Do not show the alert to people in portal.
    --[[if QDRH.GetPlayerToPlaceDist(
      QDRH.data.taleria_center_pos[1],
          QDRH.data.taleria_center_pos[2],
          QDRH.data.taleria_center_pos[3]) < QDRH.data.taleria_crashing_wave_alert_radius then
      CombatAlerts.AlertCast(abilityId, sourceName, hitValue, {-2, 2})
    end--]]
    CombatAlerts.AlertCast(abilityId, sourceName, hitValue, {-2, 2})
  end
end

function QDRH.Taleria.LureOfTheSea()
  if QDRH.savedVariables.showLureOfTheSea then
    CombatAlerts.CastAlertsStart(
      QDRH.data.taleria_matron_lure_of_the_sea,
      "Lure of the Sea", 3000+1000, nil,
      {0.5, 0, 0.5, 0.6},
      {1000, "Break free!", 1, 0, 1, 1, nil})
    PlaySound(SOUNDS.DUEL_FORFEIT)
  end
end

function QDRH.Taleria.LureOfTheSeaIcon(targetUnitId)
  if QDRH.savedVariables.showLureOfTheSeaIcon then
    if targetUnitId ~= nil and QDRH.units[targetUnitId] ~= nil then
      QDRH.AddIconForDuration(QDRH.units[targetUnitId].tag, "QcellDreadsailReefHelper/icons/lemon.dds", 3000)
    end
  end
end

function QDRH.Taleria.AspectOfTerror(sourceName, hitValue)
  -- {BEGIN} Aspect of Terror (174697) : [1667]",
  CombatAlerts.AlertCast(QDRH.data.taleria_sea_boiler_aspect_of_terror, sourceName, hitValue, {-3, 1})
end

-- These 3 ..Active() methods can (and will) return nil when debuffs are unset.
function QDRH.Taleria.MangleDebuffActive()
  return (QDRH.status.debuffTracker[QDRH.data.taleria_dreadsail_venom_evoker_nematocyst_cloud_portal]
    or QDRH.status.debuffTracker[QDRH.data.taleria_dreadsail_venom_evoker_nematocyst_cloud_aoe])
end

function QDRH.Taleria.SnareDebuffActive()
  return (QDRH.status.debuffTracker[QDRH.data.taleria_dreadsail_sea_boiler_sweltering_heat_portal]
    or QDRH.status.debuffTracker[QDRH.data.taleria_dreadsail_sea_boiler_sweltering_heat_aoe])
end

function QDRH.Taleria.DefileDebuffActive()
  return (QDRH.status.debuffTracker[QDRH.data.taleria_dreadsail_tidal_mage_suffocating_waves_portal]
    or QDRH.status.debuffTracker[QDRH.data.taleria_dreadsail_tidal_mage_suffocating_waves_aoe])
end

function QDRH.Taleria.TestShowAllBridgeWipes()
  QDRHStatus:SetHidden(false)
  QDRHStatusLabelTaleriaBridge1:SetHidden(false)
  QDRHStatusLabelTaleriaBridge1Value:SetHidden(false)
  QDRHStatusLabelTaleriaBridge2:SetHidden(false)
  QDRHStatusLabelTaleriaBridge2Value:SetHidden(false)
  QDRHStatusLabelTaleriaBridge3:SetHidden(false)
  QDRHStatusLabelTaleriaBridge3Value:SetHidden(false)
end
