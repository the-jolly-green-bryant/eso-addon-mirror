SEH= SEH or {}
local SEH = SEH

function SEH.IdentifyUnit(unitTag, unitName, unitId)
  if (not SEH.units[unitId] and 
    (string.sub(unitTag, 1, 5) == "group" or string.sub(unitTag, 1, 6) == "player" or string.sub(unitTag, 1, 4) == "boss")) then
    SEH.units[unitId] = {
      tag = unitTag,
      name = GetUnitDisplayName(unitTag) or unitName,
    }
    SEH.unitsTag[unitTag] = {
      id = unitId,
      name = GetUnitDisplayName(unitTag) or unitName,
    }
  end
end

function SEH.GetTagForId(targetUnitId)
  if SEH.units == nil or SEH.units[targetUnitId] == nil then
    return ""
  end
  return SEH.units[targetUnitId].tag
end

function SEH.GetNameForId(targetUnitId)
  if SEH.units == nil or SEH.units[targetUnitId] == nil then
    return ""
  end
  return SEH.units[targetUnitId].name
end

function SEH.GetDist(x1, y1, z1, x2, y2, z2)
  local dx = x1 - x2
  local dy = y1 - y2
  local dz = z1 - z2
  return dx*dx + dy*dy + dz*dz
end

function SEH.GetDistMeters(x1, y1, z1, x2, y2, z2)
  return math.sqrt(SEH.GetDist(x1, y1, z1, x2, y2, z2))/100
end

function SEH.GetPlayerDist(unitTag1, unitTag2)
  local pworld, px, py, pz = GetUnitWorldPosition(unitTag1)
  local tworld, tx, ty, tz = GetUnitWorldPosition(unitTag2)
  return SEH.GetDist(px, py, pz, tx, ty, tz)
end

function SEH.GetUnitToPlaceDist(unitTag, x, y, z)
  local pworld, px, py, pz = GetUnitWorldPosition(unitTag)
  return SEH.GetDist(px, py, pz, x, y, z)
end

function SEH.GetPlayerToPlaceDist(x, y, z)
  return SEH.GetUnitToPlaceDist("player", x, y, z)
end

function SEH.GetClosestGroupDist(x, y, z)
  local closest = 1000000000
  -- TODO: Check if I can detect group size, for the very niche case of smaller groups.
  -- TODO: Check if it works out of group.
  for i = 1, 12 do
    local tag = "group" .. tostring(i)
    local d = SEH.GetUnitToPlaceDist(tag, x, y, z)
    if d < closest then
      closest = d
    end
  end
  return closest
end

function SEH.IsPlayerInBox(xmin, xmax, zmin, zmax)
  local pworld, px, py, pz = GetUnitWorldPosition("player")
  return xmin < px and px < xmax and zmin < pz and pz < zmax
end

-- TODO: Make uppercase
function SEH.hasOSI()
  return OSI and OSI.CreatePositionIcon and OSI.SetMechanicIconForUnit
end

function SEH.AddIcon(unitTag, texture)
  SEH.AddIconDisplayName(GetUnitDisplayName(unitTag), texture)
end

function SEH.AddIconDisplayName(displayName, texture)
  if SEH.hasOSI() then
    OSI.SetMechanicIconForUnit(string.lower(displayName), texture, 1.5 * OSI.GetIconSize())
  end
end

function SEH.AddIconForDuration(unitTag, texture, durationMillisec)
  SEH.AddIcon(unitTag, texture)
  local name = SEH.name .. "AddIconForDuration" .. unitTag
  EVENT_MANAGER:RegisterForUpdate(name, durationMillisec, function() 
    EVENT_MANAGER:UnregisterForUpdate(name)
    SEH.RemoveIcon(unitTag)
    end )
end

function SEH.AddGroundIconOnPlayerForDuration(unitTag, texture, durationMillisec)
  local pworld, px, py, pz = GetUnitWorldPosition(unitTag)
  local name = SEH.name .. "AddGroundIconOnPlayerForDuration" .. unitTag .. tostring(GetGameTimeSeconds())

  local icon = SEH.AddGroundCustomIcon(px, py, pz, texture)
  EVENT_MANAGER:RegisterForUpdate(name, durationMillisec, function()
    EVENT_MANAGER:UnregisterForUpdate(name)
    SEH.DiscardPositionIconList({icon})
    end )

  return icon
end

function SEH.AddIconForDurationDisplayName(displayName, texture, durationMillisec)
  SEH.AddIconDisplayName(displayName, texture)
  local name = SEH.name .. "AddIconForDurationDisplayName" .. displayName
  EVENT_MANAGER:RegisterForUpdate(name, durationMillisec, function() 
    EVENT_MANAGER:UnregisterForUpdate(name)
    SEH.RemoveIconDisplayName(displayName)
    end )
end

function SEH.RemoveIcon(unitTag)
  SEH.RemoveIconDisplayName(GetUnitDisplayName(unitTag))
end

function SEH.RemoveIconDisplayName(displayName)
  if SEH.hasOSI() then
    OSI.RemoveMechanicIconForUnit(string.lower(displayName))
  end
end

function SEH.AddGroundIcon(x, y, z)
  if SEH.hasOSI() then
      return OSI.CreatePositionIcon(x, y, z,
        "OdySupportIcons/icons/green_arrow.dds",
        2 * OSI.GetIconSize())
  end
  return nil
end

function SEH.AddGroundCustomIcon(x, y, z, filePath)
  if SEH.hasOSI() then
      return OSI.CreatePositionIcon(
        x, y, z,
        filePath,
        2 * OSI.GetIconSize())
  end
  return nil
end

function SEH.DiscardPositionIconList(iconList)
  if iconList == nil or not SEH.hasOSI() then
    return
  end
  for k, v in pairs(iconList) do
    if v ~= nil then
      OSI.DiscardPositionIcon(v)
    end
  end
  -- NOTE THIS WILL NOT UPDATE BY REFERENCE THE PASSED LIST.
  iconList = {}
end

function SEH.ResetAllPlayerIcons()
  if SEH.hasOSI() then
    OSI.ResetMechanicIcons()
  end
end

function SEH.trimName(name)
  local NAME_TRIM_LENGTH = 8
  if name ~= nil then
    if string.len(name) > NAME_TRIM_LENGTH then
      return string.sub(name, 1, NAME_TRIM_LENGTH)
    else
      return name
    end
  end
  return ""
end

function SEH.GetSecondsRemainingString(seconds)
  if seconds > 5 then 
    return string.format("%.0f", seconds) .. "s "
  elseif seconds > 0 then 
    return string.format("%.1f", seconds) .. "s "
  else
    return "INC"
  end
end

function SEH.GetSecondsString(seconds)
  return string.format("%.0f", seconds) .. "s "
end

function SEH.PlayLoudSound(sound)
  PlaySound(sound)
  PlaySound(sound)
  PlaySound(sound)
  PlaySound(sound)
  PlaySound(sound)
end

function SEH.ObnoxiousSound(sound, count)
  if count <= 0 or count == nil or count > 10 then
    return
  end
  SEH.PlayLoudSound(sound)
  -- only one ObnoxiousSound at a time, thus unique name.
  local name = SEH.name .. "ObnoxiousSound"
  EVENT_MANAGER:RegisterForUpdate(name, 1000, function() 
    EVENT_MANAGER:UnregisterForUpdate(name)
    SEH.ObnoxiousSound(sound, count - 1)
    end )
end

function SEH.Alert( textMinor, textMajor, color, icon, sound, duration )
	if (not duration) then duration = 2000 end

	local id = CombatAlerts.StartBanner(textMinor, textMajor, color, icon, true, sound)

	EVENT_MANAGER:UnregisterForUpdate(CombatAlerts.banners[id].name)
	EVENT_MANAGER:RegisterForUpdate(
		CombatAlerts.banners[id].name,
		duration,
		function( )
			CombatAlerts.DisableBanner(id)
		end
	)

	return(id)
end

function SEH.HasValue(table, val)
  for index, value in ipairs(table) do
    if value == val then
      return true
    end
  end

  return false
end

-- Debug functions

function SEH.GroupNames()
  for i=1,12 do
    local name = GetUnitDisplayName("group" .. tostring(i))
    if name ~= nil then 
      d("group" .. tostring(i) .. "=" .. name)
    end
  end
end