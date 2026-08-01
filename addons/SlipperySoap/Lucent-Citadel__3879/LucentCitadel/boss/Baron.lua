LC = LC or {}
local LC = LC
LC.Baron = {}

function LC.Baron.AddBaronSpots()
  if not LC.hasOSI() or not LC.savedVariables.showBaronSpots2 then
    return
  end
  if LC.status.baronSpotIcons ~= nil and table.getn(LC.status.baronSpotIcons) == 8 then
    -- Already filled.
    return
  end
  for k, v in pairs(LC.data.baron_spot_pos) do
    if v ~= nil and table.getn(v) == 4 then
      -- add icon
      table.insert(LC.status.baronSpotIcons, 
        OSI.CreatePositionIcon(
          v[1],
          v[2],
          v[3],
          "LucentCitadel/icons/" .. tostring(v[4]) .. ".dds",
          1.0 * OSI.GetIconSize()))
    end
  end
  LC.status.baronSpotMarkersActive = true
end

function LC.Baron.DiscardBaronSpots()
  -- LC.status.taleriaClockIcons[1..24] = {}
  LC.DiscardPositionIconList(LC.status.baronSpotIcons)
  LC.status.baronSpotIcons = {}
  LC.status.baronSpotMarkersActive = false
end

function LC.Baron.UpdateTick(timeSec)
    if LC.savedVariables.showBaronSpots2 and not LC.status.baronSpotMarkersActive then
        LC.Baron.AddBaronSpots()
    elseif not LC.savedVariables.showBaronSpots2 and LC.status.baronSpotMarkersActive then
        LC.Baron.DiscardBaronSpots()
    end
end

-- LC.savedVariables.showBaronSpots2