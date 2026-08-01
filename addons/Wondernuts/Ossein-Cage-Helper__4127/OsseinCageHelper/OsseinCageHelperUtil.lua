OCH = OCH or {}
local OCH = OCH

function OCH.IdentifyUnit(unitTag, unitName, unitId)
  if (not OCH.units[unitId] and 
    (string.sub(unitTag, 1, 5) == "group" or string.sub(unitTag, 1, 6) == "player" or string.sub(unitTag, 1, 4) == "boss")) then
    OCH.units[unitId] = {
      tag = unitTag,
      name = GetUnitDisplayName(unitTag) or unitName,
    }
    OCH.unitsTag[unitTag] = {
      id = unitId,
      name = GetUnitDisplayName(unitTag) or unitName,
    }
  end
end

function OCH.GetTagForId(targetUnitId)
  if OCH.units == nil or OCH.units[targetUnitId] == nil then
    return ""
  end
  return OCH.units[targetUnitId].tag
end

function OCH.GetNameForId(targetUnitId)
  if OCH.units == nil or OCH.units[targetUnitId] == nil then
    return ""
  end
  return OCH.units[targetUnitId].name
end

function OCH.GetDist(x1, y1, z1, x2, y2, z2)
  local dx = x1 - x2
  local dy = y1 - y2
  local dz = z1 - z2
  return dx*dx + dy*dy + dz*dz
end

function OCH.GetDistMeters(x1, y1, z1, x2, y2, z2)
  return math.sqrt(OCH.GetDist(x1, y1, z1, x2, y2, z2))/100
end

function OCH.GetPlayerDist(unitTag1, unitTag2)
  local pworld, px, py, pz = GetUnitWorldPosition(unitTag1)
  local tworld, tx, ty, tz = GetUnitWorldPosition(unitTag2)
  return OCH.GetDist(px, py, pz, tx, ty, tz)
end

function OCH.GetUnitToPlaceDist(unitTag, x, y, z)
  local pworld, px, py, pz = GetUnitWorldPosition(unitTag)
  return OCH.GetDist(px, py, pz, x, y, z)
end

function OCH.GetPlayerToPlaceDist(x, y, z)
  return OCH.GetUnitToPlaceDist("player", x, y, z)
end

function OCH.GetClosestGroupDist(x, y, z)
  local closest = 1000000000
  -- TODO: Check if I can detect group size, for the very niche case of smaller groups.
  -- TODO: Check if it works out of group.
  for i = 1, 12 do
    local tag = "group" .. tostring(i)
    local d = OCH.GetUnitToPlaceDist(tag, x, y, z)
    if d < closest then
      closest = d
    end
  end
  return closest
end

function OCH.IsPlayerInBox(xmin, xmax, zmin, zmax)
  local pworld, px, py, pz = GetUnitWorldPosition("player")
  return xmin < px and px < xmax and zmin < pz and pz < zmax
end

-- TODO: Make uppercase
function OCH.hasOSI()
  return OSI and OSI.CreatePositionIcon and OSI.SetMechanicIconForUnit
end

function OCH.AddIcon(unitTag, texture)
  OCH.AddIconDisplayName(GetUnitDisplayName(unitTag), texture)
end

function OCH.AddIconDisplayName(displayName, texture)
  if OCH.hasOSI() then
    OSI.SetMechanicIconForUnit(string.lower(displayName), texture, 1.5 * OSI.GetIconSize())
  end
end

function OCH.AddIconForDuration(unitTag, texture, durationMillisec)
  OCH.AddIcon(unitTag, texture)
  local name = OCH.name .. "AddIconForDuration" .. unitTag
  EVENT_MANAGER:RegisterForUpdate(name, durationMillisec, function() 
    EVENT_MANAGER:UnregisterForUpdate(name)
    OCH.RemoveIcon(unitTag)
    end )
end

function OCH.AddGroundIconOnPlayerForDuration(unitTag, texture, durationMillisec)
  local pworld, px, py, pz = GetUnitWorldPosition(unitTag)
  local name = OCH.name .. "AddGroundIconOnPlayerForDuration" .. unitTag .. tostring(GetGameTimeSeconds())

  local icon = OCH.AddGroundCustomIcon(px, py, pz, texture)
  EVENT_MANAGER:RegisterForUpdate(name, durationMillisec, function() 
    EVENT_MANAGER:UnregisterForUpdate(name)
    OCH.DiscardPositionIconList({icon})
    end )

  return icon
end

function OCH.AddIconForDurationDisplayName(displayName, texture, durationMillisec)
  OCH.AddIconDisplayName(displayName, texture)
  local name = OCH.name .. "AddIconForDurationDisplayName" .. displayName
  EVENT_MANAGER:RegisterForUpdate(name, durationMillisec, function() 
    EVENT_MANAGER:UnregisterForUpdate(name)
    OCH.RemoveIconDisplayName(displayName)
    end )
end

function OCH.RemoveIcon(unitTag)
  OCH.RemoveIconDisplayName(GetUnitDisplayName(unitTag))
end

function OCH.RemoveIconDisplayName(displayName)
  if OCH.hasOSI() then
    OSI.RemoveMechanicIconForUnit(string.lower(displayName))
  end
end

function OCH.AddGroundIcon(x, y, z)
  if OCH.hasOSI() then
      return OSI.CreatePositionIcon(x, y, z,
        "OdySupportIcons/icons/green_arrow.dds",
        2 * OSI.GetIconSize())
  end
  return nil
end

function OCH.AddGroundCustomIcon(x, y, z, filePath)
  if OCH.hasOSI() then
      return OSI.CreatePositionIcon(
        x, y, z,
        filePath,
        2 * OSI.GetIconSize())
  end
  return nil
end

function OCH.DiscardPositionIconList(iconList)
  if iconList == nil or not OCH.hasOSI() then
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

function OCH.ResetAllPlayerIcons()
  if OCH.hasOSI() then
    OSI.ResetMechanicIcons()
  end
end

function OCH.trimName(name)
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

function OCH.GetSecondsRemainingString(seconds)
  if seconds > 5 then 
    return string.format("%.0f", seconds) .. "s "
  elseif seconds > 0 then 
    return string.format("%.1f", seconds) .. "s "
  else
    return "INC"
  end
end

function OCH.GetSecondsString(seconds)
  return string.format("%.0f", seconds) .. "s "
end

function OCH.PlayLoudSound(sound)
  PlaySound(sound)
  PlaySound(sound)
  PlaySound(sound)
  PlaySound(sound)
  PlaySound(sound)
end

function OCH.ObnoxiousSound(sound, count)
  if count <= 0 or count == nil or count > 10 then
    return
  end
  OCH.PlayLoudSound(sound)
  -- only one ObnoxiousSound at a time, thus unique name.
  local name = OCH.name .. "ObnoxiousSound"
  EVENT_MANAGER:RegisterForUpdate(name, 1000, function() 
    EVENT_MANAGER:UnregisterForUpdate(name)
    OCH.ObnoxiousSound(sound, count - 1)
    end )
end

function OCH.Alert( textMinor, textMajor, color, icon, sound, duration )
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

function OCH.HasValue(table, val)
  for index, value in ipairs(table) do
    if value == val then
      return true
    end
  end

  return false
end

-- Debug functions

function OCH.GroupNames()
  for i=1,12 do
    local name = GetUnitDisplayName("group" .. tostring(i))
    if name ~= nil then 
      d("group" .. tostring(i) .. "=" .. name)
    end
  end
end

function OCH.UnpackRGBA( rgba )
	local a = rgba % 256
	rgba = (rgba - a) / 256
	local b = rgba % 256
	rgba = (rgba - b) / 256
	local g = rgba % 256
	rgba = (rgba - g) / 256
	local r = rgba % 256

	return r / 255, g / 255, b / 255, a / 255
end