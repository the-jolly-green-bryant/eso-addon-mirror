QDRH = QDRH or {}
local QDRH = QDRH

function QDRH.IdentifyUnit(unitTag, unitName, unitId)
  if (not QDRH.units[unitId] and 
    (string.sub(unitTag, 1, 5) == "group" or string.sub(unitTag, 1, 6) == "player" or string.sub(unitTag, 1, 4) == "boss")) then
    QDRH.units[unitId] = {
      tag = unitTag,
      name = GetUnitDisplayName(unitTag) or unitName,
    }
    QDRH.unitsTag[unitTag] = {
      id = unitId,
      name = GetUnitDisplayName(unitTag) or unitName,
    }
  end
end

function QDRH.GetTagForId(targetUnitId)
  if QDRH.units == nil or QDRH.units[targetUnitId] == nil then
    return ""
  end
  return QDRH.units[targetUnitId].tag
end

function QDRH.GetNameForId(targetUnitId)
  if QDRH.units == nil or QDRH.units[targetUnitId] == nil then
    return ""
  end
  return QDRH.units[targetUnitId].name
end

function QDRH.GetDist(x1, y1, z1, x2, y2, z2)
  local dx = x1 - x2
  local dy = y1 - y2
  local dz = z1 - z2
  return dx*dx + dy*dy + dz*dz
end

function QDRH.GetDistMeters(x1, y1, z1, x2, y2, z2)
  return math.sqrt(QDRH.GetDist(x1, y1, z1, x2, y2, z2))/100
end

function QDRH.GetPlayerDist(unitTag1, unitTag2)
  local pworld, px, py, pz = GetUnitWorldPosition(unitTag1)
  local tworld, tx, ty, tz = GetUnitWorldPosition(unitTag2)
  return QDRH.GetDist(px, py, pz, tx, ty, tz)
end

function QDRH.GetUnitToPlaceDist(unitTag, x, y, z)
  local pworld, px, py, pz = GetUnitWorldPosition(unitTag)
  return QDRH.GetDist(px, py, pz, x, y, z)
end

function QDRH.GetPlayerToPlaceDist(x, y, z)
  return QDRH.GetUnitToPlaceDist("player", x, y, z)
end

function QDRH.GetClosestGroupDist(x, y, z)
  local closest = 1000000000
  -- TODO: Check if I can detect group size, for the very niche case of smaller groups.
  -- TODO: Check if it works out of group.
  for i = 1, 12 do
    local tag = "group" .. tostring(i)
    local d = QDRH.GetUnitToPlaceDist(tag, x, y, z)
    if d < closest then
      closest = d
    end
  end
  return closest
end

function QDRH.IsPlayerInBox(xmin, xmax, zmin, zmax)
  local pworld, px, py, pz = GetUnitWorldPosition("player")
  return xmin < px and px < xmax and zmin < pz and pz < zmax
end

-- TODO: Make uppercase
function QDRH.hasOSI()
  return OSI and OSI.CreatePositionIcon and OSI.SetMechanicIconForUnit
end

function QDRH.AddIcon(unitTag, texture)
  QDRH.AddIconDisplayName(GetUnitDisplayName(unitTag), texture)
end

function QDRH.AddIconDisplayName(displayName, texture)
  if QDRH.hasOSI() then
    OSI.SetMechanicIconForUnit(string.lower(displayName), texture, 2 * OSI.GetIconSize())
  end
end

function QDRH.AddIconForDuration(unitTag, texture, durationMillisec)
  QDRH.AddIcon(unitTag, texture)
  local name = QDRH.name .. "AddIconForDuration" .. unitTag
  EVENT_MANAGER:RegisterForUpdate(name, durationMillisec, function() 
    EVENT_MANAGER:UnregisterForUpdate(name)
    QDRH.RemoveIcon(unitTag)
    end )
end

function QDRH.AddGroundIconOnPlayerForDuration(unitTag, texture, durationMillisec)
  local pworld, px, py, pz = GetUnitWorldPosition(unitTag)
  local name = QDRH.name .. "AddGroundIconOnPlayerForDuration" .. unitTag

  local icon = QDRH.AddGroundCustomIcon(px, py, pz, texture)
  EVENT_MANAGER:RegisterForUpdate(name, durationMillisec, function() 
    EVENT_MANAGER:UnregisterForUpdate(name)
    QDRH.DiscardPositionIconList({icon})
    end )
end

function QDRH.AddIconForDurationDisplayName(displayName, texture, durationMillisec)
  QDRH.AddIconDisplayName(displayName, texture)
  local name = QDRH.name .. "AddIconForDurationDisplayName" .. displayName
  EVENT_MANAGER:RegisterForUpdate(name, durationMillisec, function() 
    EVENT_MANAGER:UnregisterForUpdate(name)
    QDRH.RemoveIconDisplayName(displayName)
    end )
end

function QDRH.RemoveIcon(unitTag)
  QDRH.RemoveIconDisplayName(GetUnitDisplayName(unitTag))
end

function QDRH.RemoveIconDisplayName(displayName)
  if QDRH.hasOSI() then
    OSI.RemoveMechanicIconForUnit(string.lower(displayName))
  end
end

function QDRH.AddGroundIcon(x, y, z)
  if QDRH.hasOSI() then
      return OSI.CreatePositionIcon(x, y, z,
        "OdySupportIcons/icons/green_arrow.dds",
        2 * OSI.GetIconSize())
  end
  return nil
end

function QDRH.AddGroundCustomIcon(x, y, z, filePath)
  if QDRH.hasOSI() then
      return OSI.CreatePositionIcon(
        x, y, z,
        filePath,
        2 * OSI.GetIconSize())
  end
  return nil
end

function QDRH.DiscardPositionIconList(iconList)
  if iconList == nil or not QDRH.hasOSI() then
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

function QDRH.ResetAllPlayerIcons()
  if QDRH.hasOSI() then
    OSI.ResetMechanicIcons()
  end
end

function QDRH.trimName(name)
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

function QDRH.GetSecondsString(seconds)
  return string.format("%.0f", seconds) .. "s "
end

function QDRH.PlayLoudSound(sound)
  PlaySound(sound)
  PlaySound(sound)
  PlaySound(sound)
  PlaySound(sound)
  PlaySound(sound)
end

function QDRH.ObnoxiousSound(sound, count)
  if count <= 0 or count == nil or count > 10 then
    return
  end
  QDRH.PlayLoudSound(sound)
  -- only one ObnoxiousSound at a time, thus unique name.
  local name = QDRH.name .. "ObnoxiousSound"
  EVENT_MANAGER:RegisterForUpdate(name, 1000, function() 
    EVENT_MANAGER:UnregisterForUpdate(name)
    QDRH.ObnoxiousSound(sound, count - 1)
    end )
end

-- Debug functions

function QDRH.GroupNames()
  for i=1,12 do
    local name = GetUnitDisplayName("group" .. tostring(i))
    if name ~= nil then 
      d("group" .. tostring(i) .. "=" .. name)
    end
  end
end