LC = LC or {}
local LC = LC

function LC.IdentifyUnit(unitTag, unitName, unitId)
  if (not LC.units[unitId] and 
    (string.sub(unitTag, 1, 5) == "group" or string.sub(unitTag, 1, 6) == "player" or string.sub(unitTag, 1, 4) == "boss")) then
    LC.units[unitId] = {
      tag = unitTag,
      name = GetUnitDisplayName(unitTag) or unitName,
    }
    LC.unitsTag[unitTag] = {
      id = unitId,
      name = GetUnitDisplayName(unitTag) or unitName,
    }
  end
end

function LC.GetTagForId(targetUnitId)
  if LC.units == nil or LC.units[targetUnitId] == nil then
    return ""
  end
  return LC.units[targetUnitId].tag
end

function LC.GetNameForId(targetUnitId)
  if LC.units == nil or LC.units[targetUnitId] == nil then
    return ""
  end
  return LC.units[targetUnitId].name
end

function LC.GetDist(x1, y1, z1, x2, y2, z2)
  local dx = x1 - x2
  local dy = y1 - y2
  local dz = z1 - z2
  return dx*dx + dy*dy + dz*dz
end

function LC.GetDistMeters(x1, y1, z1, x2, y2, z2)
  return math.sqrt(LC.GetDist(x1, y1, z1, x2, y2, z2))/100
end

function LC.GetPlayerDist(unitTag1, unitTag2)
  local pworld, px, py, pz = GetUnitWorldPosition(unitTag1)
  local tworld, tx, ty, tz = GetUnitWorldPosition(unitTag2)
  return LC.GetDist(px, py, pz, tx, ty, tz)
end

function LC.GetUnitToPlaceDist(unitTag, x, y, z)
  local pworld, px, py, pz = GetUnitWorldPosition(unitTag)
  return LC.GetDist(px, py, pz, x, y, z)
end

function LC.GetPlayerToPlaceDist(x, y, z)
  return LC.GetUnitToPlaceDist("player", x, y, z)
end

function LC.GetClosestGroupDist(x, y, z)
  local closest = 1000000000
  -- TODO: Check if I can detect group size, for the very niche case of smaller groups.
  -- TODO: Check if it works out of group.
  for i = 1, 12 do
    local tag = "group" .. tostring(i)
    local d = LC.GetUnitToPlaceDist(tag, x, y, z)
    if d < closest then
      closest = d
    end
  end
  return closest
end

function LC.IsPlayerInBox(xmin, xmax, zmin, zmax)
  local pworld, px, py, pz = GetUnitWorldPosition("player")
  return xmin < px and px < xmax and zmin < pz and pz < zmax
end

-- TODO: Make uppercase
function LC.hasOSI()
  return OSI and OSI.CreatePositionIcon and OSI.SetMechanicIconForUnit
end

function LC.AddIcon(unitTag, texture)
  LC.AddIconDisplayName(GetUnitDisplayName(unitTag), texture)
end

function LC.AddIconDisplayName(displayName, texture)
  if LC.hasOSI() then
    OSI.SetMechanicIconForUnit(string.lower(displayName), texture, 2 * OSI.GetIconSize())
  end
end

function LC.AddIconForDuration(unitTag, texture, durationMillisec)
  LC.AddIcon(unitTag, texture)
  local name = LC.name .. "AddIconForDuration" .. unitTag
  EVENT_MANAGER:RegisterForUpdate(name, durationMillisec, function() 
    EVENT_MANAGER:UnregisterForUpdate(name)
    LC.RemoveIcon(unitTag)
    end )
end

function LC.AddGroundIconOnPlayerForDuration(unitTag, texture, durationMillisec)
  local pworld, px, py, pz = GetUnitWorldPosition(unitTag)
  local name = LC.name .. "AddGroundIconOnPlayerForDuration" .. unitTag

  local icon = LC.AddGroundCustomIcon(px, py, pz, texture)
  EVENT_MANAGER:RegisterForUpdate(name, durationMillisec, function() 
    EVENT_MANAGER:UnregisterForUpdate(name)
    LC.DiscardPositionIconList({icon})
    end )
end

function LC.AddIconForDurationDisplayName(displayName, texture, durationMillisec)
  LC.AddIconDisplayName(displayName, texture)
  local name = LC.name .. "AddIconForDurationDisplayName" .. displayName
  EVENT_MANAGER:RegisterForUpdate(name, durationMillisec, function() 
    EVENT_MANAGER:UnregisterForUpdate(name)
    LC.RemoveIconDisplayName(displayName)
    end )
end

function LC.RemoveIcon(unitTag)
  LC.RemoveIconDisplayName(GetUnitDisplayName(unitTag))
end

function LC.RemoveIconDisplayName(displayName)
  if LC.hasOSI() then
    OSI.RemoveMechanicIconForUnit(string.lower(displayName))
  end
end

function LC.AddGroundIcon(x, y, z)
  if LC.hasOSI() then
      return OSI.CreatePositionIcon(x, y, z,
        "OdySupportIcons/icons/green_arrow.dds",
        2 * OSI.GetIconSize())
  end
  return nil
end

function LC.AddGroundCustomIcon(x, y, z, filePath)
  if LC.hasOSI() then
      return OSI.CreatePositionIcon(
        x, y, z,
        filePath,
        2 * OSI.GetIconSize())
  end
  return nil
end

function LC.DiscardPositionIconList(iconList)
  if iconList == nil or not LC.hasOSI() then
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

function LC.ResetAllPlayerIcons()
  if LC.hasOSI() then
    OSI.ResetMechanicIcons()
  end
end

function LC.trimName(name)
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

function LC.GetSecondsString(seconds)
  return string.format("%.0f", seconds) .. "s "
end

function LC.PlayLoudSound(sound)
  PlaySound(sound)
  PlaySound(sound)
  PlaySound(sound)
  PlaySound(sound)
  PlaySound(sound)
end

function LC.ObnoxiousSound(sound, count)
  if count <= 0 or count == nil or count > 10 then
    return
  end
  LC.PlayLoudSound(sound)
  -- only one ObnoxiousSound at a time, thus unique name.
  local name = LC.name .. "ObnoxiousSound"
  EVENT_MANAGER:RegisterForUpdate(name, 1000, function() 
    EVENT_MANAGER:UnregisterForUpdate(name)
    LC.ObnoxiousSound(sound, count - 1)
    end )
end

-- Debug functions

function LC.GroupNames()
  for i=1,12 do
    local name = GetUnitDisplayName("group" .. tostring(i))
    if name ~= nil then 
      d("group" .. tostring(i) .. "=" .. name)
    end
  end
end

function LC.GetTableLength(table)
  local count = 0
  for _ in pairs(table) do count = count + 1 end
  return count
end

