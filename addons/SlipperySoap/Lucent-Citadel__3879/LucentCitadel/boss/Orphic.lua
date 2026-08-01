LC = LC or {}
local LC = LC
LC.Orphic = {}

--[[
-- swimming in boss 2: 166794 (raging current) and stam regen=0
-- dying infestation 166639 (40s) debuff after going portal
-- 174835 volatile residue (stacks) poison flowers
-- the more you have the more damage per second you take (dot)
-- 6k per tick
]]--

function LC.Orphic.ThunderThrall()
  -- To-do
  LC.status.lastThunderThrall = GetGameTimeSeconds()
  LC.status.isInitialThunderThrall = false
end

function LC.Orphic.ThunderThrallUpdateAlert(bossPercentage)
  -- To-do
  if LC.status.isInitialThunderThrall then 
    LC.status.nextThunderThrall = LC.data.orphic_thunder_thrall_initial_cd + LC.status.orphicFightStartTime
  else
    LC.status.nextThunderThrall = LC.data.orphic_thunder_thrall_cd + LC.status.lastThunderThrall
  end
  
  local nextThunderThrallCountdown = LC.status.nextThunderThrall - GetGameTimeSeconds()
  if nextThunderThrallCountdown < 5 and nextThunderThrallCountdown > -5 then
    if bossPercentage > 0.25 and bossPercentage < 1 then
        nextThunderThrallTxt = tostring(string.format("%.1f", nextThunderThrallCountdown))
        LCMessage3Label:SetText("Xoryn Jump: " .. nextThunderThrallTxt)
        LCMessage3:SetHidden(false)
    end
  else
    LCMessage3:SetHidden(true)
  end
end

function LC.Orphic.DrawStratIcons()
  if LC.status.reefGuardianStratIcons == nil or #LC.status.reefGuardianStratIcons == 0 then
    for k,v in pairs(LC.data.guardian_strat_pos) do
      table.insert(LC.status.reefGuardianStratIcons,
        LC.AddGroundCustomIcon(
          v[1], v[2], v[3],
          "LucentCitadel/icons/arrow" .. tostring(k) ..".dds"))
    end
  end
end

function LC.Orphic.ClearStratIcons()
  for k, v in pairs(LC.status.reefGuardianStratIcons) do
    if LC.hasOSI() then
      OSI.DiscardPositionIcon(v)
    end
  end
  LC.status.reefGuardianStratIcons = {}
end

function LC.Orphic.AddOrphicClock()
  if not LC.hasOSI() or not LC.savedVariables.showOrphicClock2 then
    return
  end
  if LC.status.orphicClockIcons ~= nil and table.getn(LC.status.orphicClockIcons) == 8 then
    -- Already filled.
    return
  end
  for k, v in pairs(LC.data.orphic_clock_pos) do
    if v ~= nil and table.getn(v) == 4 then
      -- add icon
      table.insert(LC.status.orphicClockIcons, 
        OSI.CreatePositionIcon(
          v[1],
          v[2],
          v[3],
          "LucentCitadel/icons/" .. tostring(v[4]) .. ".dds",
          1.0 * OSI.GetIconSize()))
    end
  end
  LC.status.orphicClockActive = true
end

function LC.Orphic.AddOrphicClockCardinal()
  if not LC.hasOSI() or not LC.savedVariables.showOrphicClockCardinal then
    return
  end
  if LC.status.orphicClockIconsCardinal ~= nil and table.getn(LC.status.orphicClockIconsCardinal) == 8 then
    -- Already filled.
    return
  end
  for k, v in pairs(LC.data.orphic_clock_cardinal_pos) do
    if v ~= nil and table.getn(v) == 4 then
      -- add icon
      table.insert(LC.status.orphicClockIconsCardinal, 
        OSI.CreatePositionIcon(
          v[1],
          v[2],
          v[3],
          "LucentCitadel/icons/" .. v[4] .. ".dds",
          1.5 * OSI.GetIconSize()))
    end
  end
  LC.status.orphicClockCardinalActive = true
end

function LC.Orphic.DiscardOrphicClock()
  -- LC.status.taleriaClockIcons[1..24] = {}
  LC.DiscardPositionIconList(LC.status.orphicClockIcons)
  LC.status.orphicClockIcons = {}
  LC.status.orphicClockActive = false
end

function LC.Orphic.DiscardOrphicClockCardinal()
  -- LC.status.taleriaClockIcons[1..24] = {}
  LC.DiscardPositionIconList(LC.status.orphicClockIconsCardinal)
  LC.status.orphicClockIconsCardinal = {}
  LC.status.orphicClockCardinalActive = false
end

function LC.Orphic.DiscardAllPortalPosIcons()
  LC.Orphic.DiscardPortalPosIcons(1)
  LC.Orphic.DiscardPortalPosIcons(2)
  LC.Orphic.DiscardPortalPosIcons(3)
end

function LC.Orphic.DiscardPortalPosIcons(numPortal)
  if LC.status.taleriaPortalPosIcons ~= nil and LC.status.taleriaPortalPosIcons[numPortal] ~= nil then
    LC.DiscardPositionIconList(LC.status.taleriaPortalPosIcons[numPortal])
    LC.status.taleriaPortalPosIcons[numPortal] = {}
  end
end

function LC.Orphic.AddPivotIcon()
  if LC.status.taleriaPivotIcon == nil and LC.hasOSI() then
    LC.status.taleriaPivotIcon =
      OSI.CreatePositionIcon(
        LC.data.taleria_pivot_icon_pos[1],
        LC.data.taleria_pivot_icon_pos[2],
        LC.data.taleria_pivot_icon_pos[3],
        "OdySupportIcons/icons/green_arrow.dds",
        2 * OSI.GetIconSize())
  end
end

function LC.Orphic.RemovePivotIcon()
  if LC.status.taleriaPivotIcon ~= nil then
    if LC.hasOSI() then
      OSI.DiscardPositionIcon(LC.status.taleriaPivotIcon)
    end
    LC.status.taleriaPivotIcon = nil
  end
end

function LC.Orphic.AddBridgeIcon(portalType)
  if not LC.savedVariables.showBridgePositionIcons then
    return
  end
  local colorString = "green"
  local pos = {}
  if portalType == LC.data.taleria_portal_type_green then
    colorString = "green"
    pos = LC.data.taleria_bridge_green_pos
  elseif portalType == LC.data.taleria_portal_type_yellow then
    colorString = "yellow"
    pos = LC.data.taleria_bridge_yellow_pos
  elseif portalType == LC.data.taleria_portal_type_purple then
    colorString = "purple"
    pos = LC.data.taleria_bridge_purple_pos
  else
    if portalType ~= nil then
      d("[LC] ERROR: AddBridgeIcon with wrong portalType=" .. tostring(portalType))
    else
      d("[LC] ERROR: AddBridgeIcon with nil portalType")
    end
  end

  local numberString = tostring(LC.status.taleriaPortalNum)
  local fileName = "LucentCitadel/icons/" .. colorString .. numberString .. ".dds"

  if LC.hasOSI() and #pos == 3 then
    table.insert(LC.status.taleriaBridgeIcons,
      OSI.CreatePositionIcon(
        pos[1],
        pos[2],
        pos[3],
        fileName,
        2 * OSI.GetIconSize()))
  end
end

function LC.Orphic.RemoveAllBridgeIcons()
  if not LC.savedVariables.showBridgePositionIcons then
    return
  end

  for k, v in pairs(LC.status.taleriaBridgeIcons) do
    if LC.hasOSI() then
      OSI.DiscardPositionIcon(v)
    end
  end
  LC.status.taleriaBridgeIcons = {}
end

function LC.Orphic.RemoveOldestBridgeIcon()
  if not LC.savedVariables.showBridgePositionIcons then
    return
  end

  if LC.status.taleriaBridgeIcons ~= nil and #LC.status.taleriaBridgeIcons > 0 then
    if LC.hasOSI() then
      OSI.DiscardPositionIcon(LC.status.taleriaBridgeIcons[1])
    end
    table.remove(LC.status.taleriaBridgeIcons, 1)
  end
end

function LC.Orphic.AddPortalPosIcon(portalType)
  if not LC.hasOSI() then
    return
  end
  local iconFile = "portalgreen.dds"
  local posOuter = LC.data.taleria_bridge_green_portal_outer
  local posInner = LC.data.taleria_bridge_green_portal_inner
  if portalType == LC.data.taleria_portal_type_green then
    -- set by default
  elseif portalType == LC.data.taleria_portal_type_yellow then
    posOuter = LC.data.taleria_bridge_yellow_portal_outer
    posInner = LC.data.taleria_bridge_yellow_portal_inner
    iconFile = "portalyellow.dds"
  elseif portalType == LC.data.taleria_portal_type_purple then
    posOuter = LC.data.taleria_bridge_purple_portal_outer
    posInner = LC.data.taleria_bridge_purple_portal_inner
    iconFile = "portalpurple.dds"
  else
    -- d
  end
  -- TODO: Store and remove those icons.
  local outerIcon = OSI.CreatePositionIcon(
        posOuter[1],
        posOuter[2],
        posOuter[3],
        "LucentCitadel/icons/" .. iconFile,
        2 * OSI.GetIconSize())

  --[[local innerIcon = OSI.CreatePositionIcon(
        posInner[1],
        posInner[2],
        posInner[3],
        "LucentCitadel/icons/" .. iconFile,
        2 * OSI.GetIconSize())--]]
  if LC.status.taleriaPortalPosIcons[LC.status.taleriaPortalPosIcons] == nil then
    LC.status.taleriaPortalPosIcons[LC.status.taleriaPortalPosIcons] = {}
  end
  --table.insert(LC.status.taleriaPortalPosIcons[LC.status.taleriaPortalNum], innerIcon)
  table.insert(LC.status.taleriaPortalPosIcons[LC.status.taleriaPortalNum], outerIcon)
end

-- Could be used for Orphic ball spawn
function LC.Orphic.SummonSeaBehemoth()
  -- Track that it started and start counting for the next
  -- First one spawns at 0:15
  -- Subsequent ones at +60s
  local timeSec = GetGameTimeSeconds()
  LC.status.taleriaLastSummonBehemoth = timeSec
  LC.status.taleriaBehemothSlam[LC.status.taleriaBehemothSlamId] = timeSec + LC.data.taleria_behemoth_arctic_annihilation_cd_after_spawn
  LC.status.taleriaBehemothSlamId = (LC.status.taleriaBehemothSlamId + 1)%2
end

function LC.Orphic.OrphicMirrorMechPanelUpdate(bossPercentage)
    if (GetGameTimeSeconds() < (LC.status.orphicColorChangeStartTime + 13)) or LC.status.orphicIsCastingColorChange then
        showOrphicMirrorAlert = true
    else
        showOrphicMirrorAlert = false
        LC.status.orphicIsCastingColorChange = false
    end

    if (GetGameTimeSeconds() > (LC.status.orphicColorChangeStartTime + 13)) then
        showOrphicMirrorAlert = false
        LC.status.orphicIsCastingColorChange = false
    end

    if 0.805 < bossPercentage and bossPercentage < 1  then
        if 0.905 < bossPercentage and bossPercentage < 1  then
            mirrorPercent = (bossPercentage - 0.905) * 100
            mirrorPercentTxt = tostring(string.format("%.1f", mirrorPercent))
            LCStatusLabel1:SetText("Mirrors: ")
            LCStatusLabel1Value:SetText(mirrorPercentTxt .. "%")
            LCStatusLabel1:SetHidden(not LC.savedVariables.showOrphicMirrorMechPanel)
            LCStatusLabel1Value:SetHidden(not LC.savedVariables.showOrphicMirrorMechPanel)
        end

        if LC.savedVariables.showOrphicMirrorMechAlerts2 > 0 and showOrphicMirrorAlert then
            if LC.savedVariables.orphic90Mirror > 0 and bossPercentage < 0.93 then
                if LC.savedVariables.showOrphicMirrorMechAlerts2 == 1 then
                    mirrorToFlipTxt = tostring(LC.savedVariables.orphic90Mirror)
                    LCMessage1Label:SetText("90% Mirrors - Flip " .. mirrorToFlipTxt)
                elseif LC.savedVariables.showOrphicMirrorMechAlerts2 == 2 then
                    cardinalMirrorToFlipTxt = LC.data.orphicNumbersToCardinalDirections[LC.savedVariables.orphic90Mirror]
                    LCMessage1Label:SetText("90% Mirrors - Flip " .. cardinalMirrorToFlipTxt)
                elseif LC.savedVariables.showOrphicMirrorMechAlerts2 == 3 then
                    mirrorToFlipTxt = tostring(LC.savedVariables.orphic90Mirror)
                    cardinalMirrorToFlipTxt = LC.data.orphicNumbersToCardinalDirections[LC.savedVariables.orphic90Mirror]
                    LCMessage1Label:SetText("90% Mirrors - Flip " .. mirrorToFlipTxt .. " / " .. cardinalMirrorToFlipTxt)
                end
                LCMessage1:SetHidden(false)
            end
        else
            LCMessage1:SetHidden(true)
        end
    end
    if 0.505 < bossPercentage and bossPercentage < 0.90 then
        if 0.605 < bossPercentage and bossPercentage < 0.90 then
            mirrorPercent = (bossPercentage - 0.605) * 100
            mirrorPercentTxt = tostring(string.format("%.1f", mirrorPercent))
            LCStatusLabel1:SetText("Mirrors: ")
            LCStatusLabel1Value:SetText(mirrorPercentTxt .. "%")
            LCStatusLabel1:SetHidden(not LC.savedVariables.showOrphicMirrorMechPanel)
            LCStatusLabel1Value:SetHidden(not LC.savedVariables.showOrphicMirrorMechPanel)
        end
        --if LC.savedVariables.orphic60Mirror > 0 and bossPercentage < 0.63 then
        --mirrorToFlipTxt = tostring(LC.savedVariables.orphic60Mirror)
        --LCMessage1Label:SetText("60% Mirrors - Flip " .. mirrorToFlipTxt)
        --LCMessage1:SetHidden(false)
        --end

        if LC.savedVariables.showOrphicMirrorMechAlerts2 > 0 and showOrphicMirrorAlert then
            if LC.savedVariables.orphic60Mirror > 0 and bossPercentage < 0.63 then
                if LC.savedVariables.showOrphicMirrorMechAlerts2 == 1 then
                    mirrorToFlipTxt = tostring(LC.savedVariables.orphic60Mirror)
                    LCMessage1Label:SetText("60% Mirrors - Flip " .. mirrorToFlipTxt)
                elseif LC.savedVariables.showOrphicMirrorMechAlerts2 == 2 then
                    cardinalMirrorToFlipTxt = LC.data.orphicNumbersToCardinalDirections[LC.savedVariables.orphic60Mirror]
                    LCMessage1Label:SetText("60% Mirrors - Flip " .. cardinalMirrorToFlipTxt)
                elseif LC.savedVariables.showOrphicMirrorMechAlerts2 == 3 then
                    mirrorToFlipTxt = tostring(LC.savedVariables.orphic60Mirror)
                    cardinalMirrorToFlipTxt = LC.data.orphicNumbersToCardinalDirections[LC.savedVariables.orphic60Mirror]
                    LCMessage1Label:SetText("60% Mirrors - Flip " .. mirrorToFlipTxt .. " / " .. cardinalMirrorToFlipTxt)
                end
                LCMessage1:SetHidden(false)
            end
        else
            LCMessage1:SetHidden(true)
        end
    end
    if 0.305 < bossPercentage and bossPercentage < 0.60 then
        if 0.405 < bossPercentage and bossPercentage < 0.60 then
            mirrorPercent = (bossPercentage - 0.405) * 100
            mirrorPercentTxt = tostring(string.format("%.1f", mirrorPercent))
            LCStatusLabel1:SetText("Mirrors: ")
            LCStatusLabel1Value:SetText(mirrorPercentTxt .. "%")
            LCStatusLabel1:SetHidden(not LC.savedVariables.showOrphicMirrorMechPanel)
            LCStatusLabel1Value:SetHidden(not LC.savedVariables.showOrphicMirrorMechPanel)
        end
        --if LC.savedVariables.orphic40Mirror > 0 and bossPercentage < 0.43 then
        --mirrorToFlipTxt = tostring(LC.savedVariables.orphic40Mirror)
        --LCMessage1Label:SetText("40% Mirrors - Flip " .. mirrorToFlipTxt)
        --LCMessage1:SetHidden(false)
        --end

        if LC.savedVariables.showOrphicMirrorMechAlerts2 > 0 and showOrphicMirrorAlert then
            if LC.savedVariables.orphic40Mirror > 0 and bossPercentage < 0.43 then
                if LC.savedVariables.showOrphicMirrorMechAlerts2 == 1 then
                    mirrorToFlipTxt = tostring(LC.savedVariables.orphic40Mirror)
                    LCMessage1Label:SetText("40% Mirrors - Flip " .. mirrorToFlipTxt)
                elseif LC.savedVariables.showOrphicMirrorMechAlerts2 == 2 then
                    cardinalMirrorToFlipTxt = LC.data.orphicNumbersToCardinalDirections[LC.savedVariables.orphic40Mirror]
                    LCMessage1Label:SetText("40% Mirrors - Flip " .. cardinalMirrorToFlipTxt)
                elseif LC.savedVariables.showOrphicMirrorMechAlerts2 == 3 then
                    mirrorToFlipTxt = tostring(LC.savedVariables.orphic40Mirror)
                    cardinalMirrorToFlipTxt = LC.data.orphicNumbersToCardinalDirections[LC.savedVariables.orphic40Mirror]
                    LCMessage1Label:SetText("40% Mirrors - Flip " .. mirrorToFlipTxt .. " / " .. cardinalMirrorToFlipTxt)
                end
                LCMessage1:SetHidden(false)
            end
        else
            LCMessage1:SetHidden(true)
        end
    end
    if 0.055 < bossPercentage and bossPercentage < 0.40 then
        if 0.155 < bossPercentage and bossPercentage < 0.40 then
            mirrorPercent = (bossPercentage - 0.155) * 100
            mirrorPercentTxt = tostring(string.format("%.1f", mirrorPercent))
            LCStatusLabel1:SetText("Mirrors: ")
            LCStatusLabel1Value:SetText(mirrorPercentTxt .. "%")
            LCStatusLabel1:SetHidden(not LC.savedVariables.showOrphicMirrorMechPanel)
            LCStatusLabel1Value:SetHidden(not LC.savedVariables.showOrphicMirrorMechPanel)
        end
        --if LC.savedVariables.orphic15Mirror > 0 and bossPercentage < 0.18 then
        --mirrorToFlipTxt = tostring(LC.savedVariables.orphic15Mirror)
        --LCMessage1Label:SetText("15% Mirrors - Flip " .. mirrorToFlipTxt)
        --LCMessage1:SetHidden(false)
        --end

        if LC.savedVariables.showOrphicMirrorMechAlerts2 > 0 and showOrphicMirrorAlert then
            if LC.savedVariables.orphic15Mirror > 0 and bossPercentage < 0.18 then
                if LC.savedVariables.showOrphicMirrorMechAlerts2 == 1 then
                    mirrorToFlipTxt = tostring(LC.savedVariables.orphic15Mirror)
                    LCMessage1Label:SetText("15% Mirrors - Flip " .. mirrorToFlipTxt)
                elseif LC.savedVariables.showOrphicMirrorMechAlerts2 == 2 then
                    cardinalMirrorToFlipTxt = LC.data.orphicNumbersToCardinalDirections[LC.savedVariables.orphic15Mirror]
                    LCMessage1Label:SetText("15% Mirrors - Flip " .. cardinalMirrorToFlipTxt)
                elseif LC.savedVariables.showOrphicMirrorMechAlerts2 == 3 then
                    mirrorToFlipTxt = tostring(LC.savedVariables.orphic15Mirror)
                    cardinalMirrorToFlipTxt = LC.data.orphicNumbersToCardinalDirections[LC.savedVariables.orphic15Mirror]
                    LCMessage1Label:SetText("15% Mirrors - Flip " .. mirrorToFlipTxt .. " / " .. cardinalMirrorToFlipTxt)
                end
                LCMessage1:SetHidden(false)
            end
        else
            LCMessage1:SetHidden(true)
        end
    end
    if bossPercentage == 0 or bossPercentage > 1 then
        LCStatusLabel1:SetText("Mirrors: ")
        LCStatusLabel1Value:SetText(" ")
        LCStatusLabel1:SetHidden(not LC.savedVariables.showOrphicMirrorMechPanel)
        LCStatusLabel1Value:SetHidden(not LC.savedVariables.showOrphicMirrorMechPanel)
        LCMessage1:SetHidden(true)
    end
    
end

function LC.Orphic.DebugOrphicMirrorMechArrowUpdate(bossPercentage)

    i = LC.savedVariables.orphic90Mirror

    if i == 1 then
        LibSimpleArrowSlip.SetTargetXY(85435,149324)
        LibSimpleArrowSlip.ShowArrow()
    elseif i == 2 then
        LibSimpleArrowSlip.SetTargetXY(86191,151104)
        LibSimpleArrowSlip.ShowArrow()
    elseif i == 3 then
        LibSimpleArrowSlip.SetTargetXY(87951,151845)
        LibSimpleArrowSlip.ShowArrow()
    elseif i == 4 then
        LibSimpleArrowSlip.SetTargetXY(89806,151089)
        LibSimpleArrowSlip.ShowArrow()
    elseif i == 5 then
        LibSimpleArrowSlip.SetTargetXY(90562,149282)
        LibSimpleArrowSlip.ShowArrow()
    elseif i == 6 then
        LibSimpleArrowSlip.SetTargetXY(89778,147493)
        LibSimpleArrowSlip.ShowArrow()
    elseif i == 7 then
        LibSimpleArrowSlip.SetTargetXY(87933,146689)
        LibSimpleArrowSlip.ShowArrow()
    elseif i == 8 then
        LibSimpleArrowSlip.SetTargetXY(86137,147468)
        LibSimpleArrowSlip.ShowArrow()
    else
        LibSimpleArrowSlip.HideArrow()
    end
end

function LC.Orphic.DebugOrphicMirrorMechArrowUpdate2(bossPercentage)

    i = LC.savedVariables.orphic90Mirror

    if i == 1 then
        LibSimpleArrowSlip.SetTargetXY(149324,85435)
        LibSimpleArrowSlip.ShowArrow()
    elseif i == 2 then
        LibSimpleArrowSlip.SetTargetXY(151104,86191)
        LibSimpleArrowSlip.ShowArrow()
    elseif i == 3 then
        LibSimpleArrowSlip.SetTargetXY(151845,87951)
        LibSimpleArrowSlip.ShowArrow()
    elseif i == 4 then
        LibSimpleArrowSlip.SetTargetXY(151089,89806)
        LibSimpleArrowSlip.ShowArrow()
    elseif i == 5 then
        LibSimpleArrowSlip.SetTargetXY(149282,90562)
        LibSimpleArrowSlip.ShowArrow()
    elseif i == 6 then
        LibSimpleArrowSlip.SetTargetXY(147493,89778)
        LibSimpleArrowSlip.ShowArrow()
    elseif i == 7 then
        LibSimpleArrowSlip.SetTargetXY(146689,87933)
        LibSimpleArrowSlip.ShowArrow()
    elseif i == 8 then
        LibSimpleArrowSlip.SetTargetXY(147468,86137)
        LibSimpleArrowSlip.ShowArrow()
    else
        LibSimpleArrowSlip.HideArrow()
    end
end

function LC.Orphic.OrphicMirrorMechArrowUpdate(bossPercentage)
    if (GetGameTimeSeconds() < (LC.status.orphicColorChangeStartTime + 13)) or LC.status.orphicIsCastingColorChange then
        local showOrphicMirrorAlert = true
    else
        local showOrphicMirrorAlert = false
        LC.status.orphicIsCastingColorChange = false
    end
    -- Notes:
    -- might need to convert the menu's slider value to a different data type

    --bossPercentage = bossPercentage

    -- LibSimpleArrowSlip.SetTarget(xy)
	-- LibSimpleArrowSlip.ShowArrow()

    if 0.801 < bossPercentage and bossPercentage < 1 and showOrphicMirrorAlert then
        if LC.savedVariables.orphic90Mirror > 0 and bossPercentage < 0.93 then
            i = LC.savedVariables.orphic90Mirror
            --xy = LC.data.orphic_clock_pos_xy[i]
            --LibSimpleArrowSlip.SetTarget(xy)
	        --LibSimpleArrowSlip.ShowArrow()
        --else
           -- LibSimpleArrowSlip.HideArrow()
        --end
            -- method 2

            if i == 1 then
                LibSimpleArrowSlip.SetTargetXY(149324,85435)
                LibSimpleArrowSlip.ShowArrow()
            elseif i == 2 then
                LibSimpleArrowSlip.SetTargetXY(151104,86191)
                LibSimpleArrowSlip.ShowArrow()
            elseif i == 3 then
                LibSimpleArrowSlip.SetTargetXY(151845,87951)
                LibSimpleArrowSlip.ShowArrow()
            elseif i == 4 then
                LibSimpleArrowSlip.SetTargetXY(151089,89806)
                LibSimpleArrowSlip.ShowArrow()
            elseif i == 5 then
                LibSimpleArrowSlip.SetTargetXY(149282,90562)
                LibSimpleArrowSlip.ShowArrow()
            elseif i == 6 then
                LibSimpleArrowSlip.SetTargetXY(147493,89778)
                LibSimpleArrowSlip.ShowArrow()
            elseif i == 7 then
                LibSimpleArrowSlip.SetTargetXY(146689,87933)
                LibSimpleArrowSlip.ShowArrow()
            elseif i == 8 then
                LibSimpleArrowSlip.SetTargetXY(147468,86137)
                LibSimpleArrowSlip.ShowArrow()
            else
                LibSimpleArrowSlip.HideArrow()
            end

            -- Old stuff
            --if i == 1 then
                --LibSimpleArrowSlip.SetTargetXY(149163,85371)
                --LibSimpleArrowSlip.ShowArrow()
            --elseif i == 2 then
                --LibSimpleArrowSlip.SetTargetXY(150892,86036)
                --LibSimpleArrowSlip.ShowArrow()
            --elseif i == 3 then
                --LibSimpleArrowSlip.SetTargetXY(151913,87801)
                --LibSimpleArrowSlip.ShowArrow()
            --elseif i == 4 then
                --LibSimpleArrowSlip.SetTargetXY(151297,89587)
                --LibSimpleArrowSlip.ShowArrow()
            --elseif i == 5 then
                --LibSimpleArrowSlip.SetTargetXY(149433,90570)
                --LibSimpleArrowSlip.ShowArrow()
            --elseif i == 6 then
                --LibSimpleArrowSlip.SetTargetXY(147586,89867)
                --LibSimpleArrowSlip.ShowArrow()
            --elseif i == 7 then
                --LibSimpleArrowSlip.SetTargetXY(146650,87983)
                --LibSimpleArrowSlip.ShowArrow()
            --elseif i == 8 then
                --LibSimpleArrowSlip.SetTargetXY(147400,86295)
                --LibSimpleArrowSlip.ShowArrow()
            --else
                --LibSimpleArrowSlip.HideArrow()
            --end

            -- old stuff v2
            --if i == 1 then
                --LibSimpleArrowSlip.SetTargetXY(149348,85334)
                --LibSimpleArrowSlip.ShowArrow()
            --elseif i == 2 then
                --LibSimpleArrowSlip.SetTargetXY(151041,86169)
                --LibSimpleArrowSlip.ShowArrow()
            --elseif i == 3 then
                --LibSimpleArrowSlip.SetTargetXY(151956,87950)
                --LibSimpleArrowSlip.ShowArrow()
            --elseif i == 4 then
                --LibSimpleArrowSlip.SetTargetXY(151169,89708)
                --LibSimpleArrowSlip.ShowArrow()
            --elseif i == 5 then
                --LibSimpleArrowSlip.SetTargetXY(149272,90657)
                --LibSimpleArrowSlip.ShowArrow()
            --elseif i == 6 then
                --LibSimpleArrowSlip.SetTargetXY(147477,89756)
                --LibSimpleArrowSlip.ShowArrow()
            --elseif i == 7 then
                --LibSimpleArrowSlip.SetTargetXY(146628,87851)
                --LibSimpleArrowSlip.ShowArrow()
            --elseif i == 8 then
                --LibSimpleArrowSlip.SetTargetXY(147488,86178)
                --LibSimpleArrowSlip.ShowArrow()
            --else
                --LibSimpleArrowSlip.HideArrow()
            --end

        else
            LibSimpleArrowSlip.HideArrow()
        end


    elseif 0.501 < bossPercentage and bossPercentage < 0.80 and showOrphicMirrorAlert then
        if LC.savedVariables.orphic60Mirror > 0 and bossPercentage < 0.63 then
            i = LC.savedVariables.orphic60Mirror
            -- method 1 commented out
            --xy = LC.data.orphic_clock_pos_xy[i]
            --LibSimpleArrowSlip.SetTarget(xy)
	        --LibSimpleArrowSlip.ShowArrow()

            -- method 2
            if i == 1 then
                LibSimpleArrowSlip.SetTargetXY(149324,85435)
                LibSimpleArrowSlip.ShowArrow()
            elseif i == 2 then
                LibSimpleArrowSlip.SetTargetXY(151104,86191)
                LibSimpleArrowSlip.ShowArrow()
            elseif i == 3 then
                LibSimpleArrowSlip.SetTargetXY(151845,87951)
                LibSimpleArrowSlip.ShowArrow()
            elseif i == 4 then
                LibSimpleArrowSlip.SetTargetXY(151089,89806)
                LibSimpleArrowSlip.ShowArrow()
            elseif i == 5 then
                LibSimpleArrowSlip.SetTargetXY(149282,90562)
                LibSimpleArrowSlip.ShowArrow()
            elseif i == 6 then
                LibSimpleArrowSlip.SetTargetXY(147493,89778)
                LibSimpleArrowSlip.ShowArrow()
            elseif i == 7 then
                LibSimpleArrowSlip.SetTargetXY(146689,87933)
                LibSimpleArrowSlip.ShowArrow()
            elseif i == 8 then
                LibSimpleArrowSlip.SetTargetXY(147468,86137)
                LibSimpleArrowSlip.ShowArrow()
            else
                LibSimpleArrowSlip.HideArrow()
            end

        else
            LibSimpleArrowSlip.HideArrow()
        end
    elseif 0.301 < bossPercentage and bossPercentage < 0.50 and showOrphicMirrorAlert then
        if LC.savedVariables.orphic40Mirror > 0 and bossPercentage < 0.43 then
            i = LC.savedVariables.orphic40Mirror
            --xy = LC.data.orphic_clock_pos_xy[i]
            --LibSimpleArrowSlip.SetTarget(xy)
	        --LibSimpleArrowSlip.ShowArrow()
        --else
            --LibSimpleArrowSlip.HideArrow()
        --end

        -- method 2

            if i == 1 then
                LibSimpleArrowSlip.SetTargetXY(149324,85435)
                LibSimpleArrowSlip.ShowArrow()
            elseif i == 2 then
                LibSimpleArrowSlip.SetTargetXY(151104,86191)
                LibSimpleArrowSlip.ShowArrow()
            elseif i == 3 then
                LibSimpleArrowSlip.SetTargetXY(151845,87951)
                LibSimpleArrowSlip.ShowArrow()
            elseif i == 4 then
                LibSimpleArrowSlip.SetTargetXY(151089,89806)
                LibSimpleArrowSlip.ShowArrow()
            elseif i == 5 then
                LibSimpleArrowSlip.SetTargetXY(149282,90562)
                LibSimpleArrowSlip.ShowArrow()
            elseif i == 6 then
                LibSimpleArrowSlip.SetTargetXY(147493,89778)
                LibSimpleArrowSlip.ShowArrow()
            elseif i == 7 then
                LibSimpleArrowSlip.SetTargetXY(146689,87933)
                LibSimpleArrowSlip.ShowArrow()
            elseif i == 8 then
                LibSimpleArrowSlip.SetTargetXY(147468,86137)
                LibSimpleArrowSlip.ShowArrow()
            else
                LibSimpleArrowSlip.HideArrow()
            end

        else
            LibSimpleArrowSlip.HideArrow()
        end
    elseif 0.051 < bossPercentage and bossPercentage < 0.30 then
        if LC.savedVariables.orphic15Mirror > 0 and bossPercentage < 0.18 then
            i = LC.savedVariables.orphic15Mirror
            --xy = LC.data.orphic_clock_pos_xy[i]
            --LibSimpleArrowSlip.SetTarget(xy)
	        --LibSimpleArrowSlip.ShowArrow()
        --else
            --LibSimpleArrowSlip.HideArrow()
        --end
            -- method 2

            if i == 1 then
                LibSimpleArrowSlip.SetTargetXY(149324,85435)
                LibSimpleArrowSlip.ShowArrow()
            elseif i == 2 then
                LibSimpleArrowSlip.SetTargetXY(151104,86191)
                LibSimpleArrowSlip.ShowArrow()
            elseif i == 3 then
                LibSimpleArrowSlip.SetTargetXY(151845,87951)
                LibSimpleArrowSlip.ShowArrow()
            elseif i == 4 then
                LibSimpleArrowSlip.SetTargetXY(151089,89806)
                LibSimpleArrowSlip.ShowArrow()
            elseif i == 5 then
                LibSimpleArrowSlip.SetTargetXY(149282,90562)
                LibSimpleArrowSlip.ShowArrow()
            elseif i == 6 then
                LibSimpleArrowSlip.SetTargetXY(147493,89778)
                LibSimpleArrowSlip.ShowArrow()
            elseif i == 7 then
                LibSimpleArrowSlip.SetTargetXY(146689,87933)
                LibSimpleArrowSlip.ShowArrow()
            elseif i == 8 then
                LibSimpleArrowSlip.SetTargetXY(147468,86137)
                LibSimpleArrowSlip.ShowArrow()
            else
                LibSimpleArrowSlip.HideArrow()
            end

        else
            LibSimpleArrowSlip.HideArrow()
        end

    else
        LibSimpleArrowSlip.HideArrow()
    end
end

-- Credits to andy.s for this feature from Infinite Archive Helper
-- Mark dangerous foes (group leader only)
-- EVENT_TARGET_MARKER_UPDATE
function LC.ReticleChanged()
    if LC.savedVariables.orphicEliteAddMarker2 or LC.savedVariables.orphicAutoMarkXoryn2 then
	    -- if not LC.savedVariables.orphicEliteAddMarker then return end
	    if IsUnitAttackable('reticleover') then
		    -- Mark attackable units in the list, but only as a group leader
		    if IsUnitSoloOrGroupLeader('player') or LC.savedVariables.orphicMarkersGroupLeadOverride then
			    local name = zo_strformat('<<1>>', GetUnitName('reticleover'))
			    if LC.data.orphicEliteAdds[name] then
                    --for i=1, 9 do
                    if GetUnitTargetMarkerType('reticleover') ~= LC.data.markers[1]
                    and GetUnitTargetMarkerType('reticleover') ~= LC.data.markers[2]
                    and GetUnitTargetMarkerType('reticleover') ~= LC.data.markers[3]
                    and GetUnitTargetMarkerType('reticleover') ~= LC.data.markers[4]
                    and GetUnitTargetMarkerType('reticleover') ~= LC.data.markers[5]
                    and GetUnitTargetMarkerType('reticleover') ~= LC.data.markers[6]
                    and GetUnitTargetMarkerType('reticleover') ~= LC.data.markers[7]
                    and GetUnitTargetMarkerType('reticleover') ~= LC.data.markers[8] then
                        if LC.savedVariables.orphicEliteAddMarker2 then
				            AssignTargetMarkerToReticleTarget(LC.data.markers[LC.status.orphicEliteAddCount])
                        end

                        if LC.status.orphicEliteAddCount == 7 then
                            LC.status.orphicEliteAddCount = 1
                        else
                            LC.status.orphicEliteAddCount = LC.status.orphicEliteAddCount + 1
                        end
                    end
                elseif name == LC.data.xorynName then
                    if LC.savedVariables.orphicAutoMarkXoryn2 then
                        AssignTargetMarkerToReticleTarget(LC.data.xorynMarker)
                    end
			    end
            end
	    elseif GetUnitTargetMarkerType('reticleover') ~= TARGET_MARKER_TYPE_NONE then
		    -- Remove marker if it's on a wrong target (can happen to companions or group members)
		    AssignTargetMarkerToReticleTarget(GetUnitTargetMarkerType('reticleover'))
	    end
    end
end
-- for now, only the group lead can mark elites. later, with data share, everyone will be able to mark

function LC.Orphic.HeavyShock(result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN then
    LC.AddIconForDuration(
      LC.GetTagForId(targetUnitId),
      "LucentCitadel/icons/lightning.dds",
      3000)
  end
  --elseif result == ACTION_RESULT_HEAL_ABSORBED then
    -- TODO: Track how much healing is left.
  --elseif result == ACTION_RESULT_EFFECT_FADED then
    --LC.RemoveIcon(LC.GetTagForId(targetUnitId))
  --end
end

function LC.Orphic.UpdateTick(timeSec)
  local currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("boss1", POWERTYPE_HEALTH)
  local bossPercentage = currentTargetHP / maxTargetHP

  -- Need to set the xml label to the appropriate one
  local mirrorPercent = 0
  local mirrorPercentTxt = ""
  local mirrorToFlipTxt = ""

  if LC.status.testing then
    bossPercentage = LC.status.testingBossHealth
  end
  if LC.savedVariables.showOrphicMirrorMechPanel or LC.savedVariables.showOrphicMirrorMechAlerts2 then
    LC.Orphic.OrphicMirrorMechPanelUpdate(bossPercentage)
  end

  if LC.savedVariables.showOrphicMirrorMechArrow then
    LC.Orphic.OrphicMirrorMechArrowUpdate(bossPercentage)
  end

  if LC.savedVariables.showThunderThrallAlerts2 and bossPercentage < 100 then
    if LC.status.orphicFightStartTime == 0 then
        LC.status.orphicFightStartTime = GetGameTimeSeconds()
    end
    LC.Orphic.ThunderThrallUpdateAlert(bossPercentage)
  end

end

function LC.Orphic.PrintPositionForArrowTarget()
    local _, playerX, playerY, playerZ = GetUnitWorldPosition("player")
    d("-------------------------------")
    d("Player X: " .. playerX)
    d("Player Y: " .. playerY)
    d("Player Z: " .. playerZ)

end

