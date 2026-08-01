LCH = LCH or {}
local LCH = LCH

function LCH.IdentifyUnit(unitTag, unitName, unitId)
  if (not LCH.units[unitId] and 
    (string.sub(unitTag, 1, 5) == "group" or string.sub(unitTag, 1, 6) == "player" or string.sub(unitTag, 1, 4) == "boss")) then
    LCH.units[unitId] = {
      tag = unitTag,
      name = GetUnitDisplayName(unitTag) or unitName,
    }
    LCH.unitsTag[unitTag] = {
      id = unitId,
      name = GetUnitDisplayName(unitTag) or unitName,
    }
  end
end

function LCH.GetTagForId(targetUnitId)
  if LCH.units == nil or LCH.units[targetUnitId] == nil then
    return ""
  end
  return LCH.units[targetUnitId].tag
end

function LCH.GetNameForId(targetUnitId)
  if LCH.units == nil or LCH.units[targetUnitId] == nil then
    return ""
  end
  return LCH.units[targetUnitId].name
end

function LCH.GetDist(x1, y1, z1, x2, y2, z2)
  local dx = x1 - x2
  local dy = y1 - y2
  local dz = z1 - z2
  return dx*dx + dy*dy + dz*dz
end

function LCH.GetDistMeters(x1, y1, z1, x2, y2, z2)
  return math.sqrt(LCH.GetDist(x1, y1, z1, x2, y2, z2))/100
end

function LCH.GetPlayerDist(unitTag1, unitTag2)
  local pworld, px, py, pz = GetUnitWorldPosition(unitTag1)
  local tworld, tx, ty, tz = GetUnitWorldPosition(unitTag2)
  return LCH.GetDist(px, py, pz, tx, ty, tz)
end

function LCH.GetUnitToPlaceDist(unitTag, x, y, z)
  local pworld, px, py, pz = GetUnitWorldPosition(unitTag)
  return LCH.GetDist(px, py, pz, x, y, z)
end

function LCH.GetPlayerToPlaceDist(x, y, z)
  return LCH.GetUnitToPlaceDist("player", x, y, z)
end

function LCH.GetClosestGroupDist(x, y, z)
  local closest = 1000000000
  -- TODO: Check if I can detect group size, for the very niche case of smaller groups.
  -- TODO: Check if it works out of group.
  for i = 1, 12 do
    local tag = "group" .. tostring(i)
    local d = LCH.GetUnitToPlaceDist(tag, x, y, z)
    if d < closest then
      closest = d
    end
  end
  return closest
end

function LCH.IsPlayerInBox(xmin, xmax, zmin, zmax)
  local pworld, px, py, pz = GetUnitWorldPosition("player")
  return xmin < px and px < xmax and zmin < pz and pz < zmax
end

-- TODO: Make uppercase
function LCH.hasOSI()
  return OSI and OSI.CreatePositionIcon and OSI.SetMechanicIconForUnit
end

function LCH.AddIcon(unitTag, texture)
  LCH.AddIconDisplayName(GetUnitDisplayName(unitTag), texture)
end

function LCH.AddIconDisplayName(displayName, texture)
  if LCH.hasOSI() then
    OSI.SetMechanicIconForUnit(string.lower(displayName), texture, 1.5 * OSI.GetIconSize())
  end
end

function LCH.AddIconForDuration(unitTag, texture, durationMillisec)
  LCH.AddIcon(unitTag, texture)
  local name = LCH.name .. "AddIconForDuration" .. unitTag
  EVENT_MANAGER:RegisterForUpdate(name, durationMillisec, function() 
    EVENT_MANAGER:UnregisterForUpdate(name)
    LCH.RemoveIcon(unitTag)
    end )
end

function LCH.AddGroundIconOnPlayerForDuration(unitTag, texture, durationMillisec)
  local pworld, px, py, pz = GetUnitWorldPosition(unitTag)
  local name = LCH.name .. "AddGroundIconOnPlayerForDuration" .. unitTag .. tostring(GetGameTimeSeconds())

  local icon = LCH.AddGroundCustomIcon(px, py, pz, texture)
  EVENT_MANAGER:RegisterForUpdate(name, durationMillisec, function() 
    EVENT_MANAGER:UnregisterForUpdate(name)
    LCH.DiscardPositionIconList({icon})
    end )

  return icon
end

function LCH.AddIconForDurationDisplayName(displayName, texture, durationMillisec)
  LCH.AddIconDisplayName(displayName, texture)
  local name = LCH.name .. "AddIconForDurationDisplayName" .. displayName
  EVENT_MANAGER:RegisterForUpdate(name, durationMillisec, function() 
    EVENT_MANAGER:UnregisterForUpdate(name)
    LCH.RemoveIconDisplayName(displayName)
    end )
end

function LCH.RemoveIcon(unitTag)
  LCH.RemoveIconDisplayName(GetUnitDisplayName(unitTag))
end

function LCH.RemoveIconDisplayName(displayName)
  if LCH.hasOSI() then
    OSI.RemoveMechanicIconForUnit(string.lower(displayName))
  end
end

function LCH.AddGroundIcon(x, y, z)
  if LCH.hasOSI() then
      return OSI.CreatePositionIcon(x, y, z,
        "OdySupportIcons/icons/green_arrow.dds",
        2 * OSI.GetIconSize())
  end
  return nil
end

function LCH.AddGroundCustomIcon(x, y, z, filePath)
  if LCH.hasOSI() then
      return OSI.CreatePositionIcon(
        x, y, z,
        filePath,
        2 * OSI.GetIconSize())
  end
  return nil
end

function LCH.DiscardPositionIconList(iconList)
  if iconList == nil or not LCH.hasOSI() then
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

function LCH.ResetAllPlayerIcons()
  if LCH.hasOSI() then
    OSI.ResetMechanicIcons()
  end
end

function LCH.trimName(name)
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

function LCH.GetSecondsRemainingString(seconds)
  if seconds > 5 then 
    return string.format("%.0f", seconds) .. "s "
  elseif seconds > 0 then 
    return string.format("%.1f", seconds) .. "s "
  else
    return "INC"
  end
end

function LCH.GetSecondsString(seconds)
  return string.format("%.0f", seconds) .. "s "
end

function LCH.PlayLoudSound(sound)
  PlaySound(sound)
  PlaySound(sound)
  PlaySound(sound)
  PlaySound(sound)
  PlaySound(sound)
end

function LCH.ObnoxiousSound(sound, count)
  if count <= 0 or count == nil or count > 10 then
    return
  end
  LCH.PlayLoudSound(sound)
  -- only one ObnoxiousSound at a time, thus unique name.
  local name = LCH.name .. "ObnoxiousSound"
  EVENT_MANAGER:RegisterForUpdate(name, 1000, function() 
    EVENT_MANAGER:UnregisterForUpdate(name)
    LCH.ObnoxiousSound(sound, count - 1)
    end )
end

function LCH.Alert( textMinor, textMajor, color, icon, sound, duration )
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

function LCH.HasValue(table, val)
  for index, value in ipairs(table) do
    if value == val then
      return true
    end
  end

  return false
end

-- Debug functions

function LCH.GroupNames()
  for i=1,12 do
    local name = GetUnitDisplayName("group" .. tostring(i))
    if name ~= nil then 
      d("group" .. tostring(i) .. "=" .. name)
    end
  end
end

function LCH.UnpackRGBA( rgba )
	local a = rgba % 256
	rgba = (rgba - a) / 256
	local b = rgba % 256
	rgba = (rgba - b) / 256
	local g = rgba % 256
	rgba = (rgba - g) / 256
	local r = rgba % 256

	return r / 255, g / 255, b / 255, a / 255
end