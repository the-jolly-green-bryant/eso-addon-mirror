SSEA = SSEA or {}
local SSEA = SSEA

-- TODO: Move to util.
-- [!] adjust label scale and draw order
local function AdjustLabelForIcon(icon)
    local order = icon.ctrl:GetDrawLevel() + 1
    icon.myLabel:SetDrawLevel( order )
end

function SSEA.IdentifyUnit(unitTag, unitName, unitId)
  if (not SSEA.units[unitId] and 
    (string.sub(unitTag, 1, 5) == "group" or string.sub(unitTag, 1, 6) == "player" or string.sub(unitTag, 1, 4) == "boss")) then
    SSEA.units[unitId] = {
      tag = unitTag,
      name = GetUnitDisplayName(unitTag) or unitName,
    }
    SSEA.unitsTag[unitTag] = {
      id = unitId,
      name = GetUnitDisplayName(unitTag) or unitName,
    }
  end
end

function SSEA.GetTagForId(targetUnitId)
  if SSEA.units == nil or SSEA.units[targetUnitId] == nil then
    return ""
  end
  return SSEA.units[targetUnitId].tag
end

function SSEA.GetNameForId(targetUnitId)
  if SSEA.units == nil or SSEA.units[targetUnitId] == nil then
    return ""
  end
  return SSEA.units[targetUnitId].name
end

function SSEA.GetDist(x1, y1, z1, x2, y2, z2)
  local dx = x1 - x2
  local dy = y1 - y2
  local dz = z1 - z2
  return dx*dx + dy*dy + dz*dz
end

function SSEA.GetDistMeters(x1, y1, z1, x2, y2, z2)
  return math.sqrt(SSEA.GetDist(x1, y1, z1, x2, y2, z2))/100
end

function SSEA.GetPlayerDist(unitTag1, unitTag2)
  local pworld, px, py, pz = GetUnitWorldPosition(unitTag1)
  local tworld, tx, ty, tz = GetUnitWorldPosition(unitTag2)
  return SSEA.GetDist(px, py, pz, tx, ty, tz)
end

function SSEA.GetUnitToPlaceDist(unitTag, x, y, z)
  local pworld, px, py, pz = GetUnitWorldPosition(unitTag)
  return SSEA.GetDist(px, py, pz, x, y, z)
end

function SSEA.GetPlayerToPlaceDist(x, y, z)
  return SSEA.GetUnitToPlaceDist("player", x, y, z)
end

function SSEA.GetClosestGroupDist(x, y, z)
  local closest = 1000000000
  -- TODO: Check if I can detect group size, for the very niche case of smaller groups.
  -- TODO: Check if it works out of group.
  for i = 1, 12 do
    local tag = "group" .. tostring(i)
    local d = SSEA.GetUnitToPlaceDist(tag, x, y, z)
    if d < closest then
      closest = d
    end
  end
  return closest
end

function SSEA.IsPlayerInBox(xmin, xmax, zmin, zmax)
  local pworld, px, py, pz = GetUnitWorldPosition("player")
  return xmin < px and px < xmax and zmin < pz and pz < zmax
end

-- TODO: Make uppercase
function SSEA.hasOSI()
  return OSI and OSI.CreatePositionIcon and OSI.SetMechanicIconForUnit
end

function SSEA.AddIcon(unitTag, texture)
  SSEA.AddIconDisplayName(GetUnitDisplayName(unitTag), texture)
end

function SSEA.AddIconDisplayName(displayName, texture)
  if SSEA.hasOSI() then
    OSI.SetMechanicIconForUnit(string.lower(displayName), texture, 2 * OSI.GetIconSize())
  end
end

function SSEA.AddIconForDuration(unitTag, texture, durationMillisec)
  SSEA.AddIcon(unitTag, texture)
  local name = SSEA.name .. "AddIconForDuration" .. unitTag
  EVENT_MANAGER:RegisterForUpdate(name, durationMillisec, function() 
    EVENT_MANAGER:UnregisterForUpdate(name)
    SSEA.RemoveIcon(unitTag)
    end )
end

function SSEA.AddGroundIconOnPlayerForDuration(unitTag, texture, durationMillisec)
  local pworld, px, py, pz = GetUnitWorldPosition(unitTag)
  local name = SSEA.name .. "AddGroundIconOnPlayerForDuration" .. unitTag

  local icon = SSEA.AddGroundCustomIcon(px, py, pz, texture)
  EVENT_MANAGER:RegisterForUpdate(name, durationMillisec, function() 
    EVENT_MANAGER:UnregisterForUpdate(name)
    SSEA.DiscardPositionIconList({icon})
    end )
end

function SSEA.AddIconForDurationDisplayName(displayName, texture, durationMillisec)
  SSEA.AddIconDisplayName(displayName, texture)
  local name = SSEA.name .. "AddIconForDurationDisplayName" .. displayName
  EVENT_MANAGER:RegisterForUpdate(name, durationMillisec, function() 
    EVENT_MANAGER:UnregisterForUpdate(name)
    SSEA.RemoveIconDisplayName(displayName)
    end )
end

function SSEA.RemoveIcon(unitTag)
  SSEA.RemoveIconDisplayName(GetUnitDisplayName(unitTag))
end

function SSEA.RemoveIconDisplayName(displayName)
  if SSEA.hasOSI() then
    OSI.RemoveMechanicIconForUnit(string.lower(displayName))
  end
end

function SSEA.AddGroundIcon(x, y, z)
  if SSEA.hasOSI() then
      return OSI.CreatePositionIcon(x, y, z,
        "OdySupportIcons/icons/green_arrow.dds",
        2 * OSI.GetIconSize())
  end
  return nil
end

function SSEA.AddGroundCustomIcon(x, y, z, filePath)
  if SSEA.hasOSI() then
      return OSI.CreatePositionIcon(
        x, y, z,
        filePath,
        2 * OSI.GetIconSize())
  end
  return nil
end

function SSEA.DiscardPositionIconList(iconList)
  if iconList == nil or not SSEA.hasOSI() then
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

function SSEA.ResetAllPlayerIcons()
  if SSEA.hasOSI() then
    OSI.ResetMechanicIcons()
  end
end

function SSEA.trimName(name)
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

function SSEA.GetSecondsString(seconds)
  return string.format("%.0f", seconds) .. "s "
end

function SSEA.PlayLoudSound(sound)
  PlaySound(sound)
  PlaySound(sound)
  PlaySound(sound)
  PlaySound(sound)
  PlaySound(sound)
end

function SSEA.ObnoxiousSound(sound, count)
  if count <= 0 or count == nil or count > 10 then
    return
  end
  SSEA.PlayLoudSound(sound)
  -- only one ObnoxiousSound at a time, thus unique name.
  local name = SSEA.name .. "ObnoxiousSound"
  EVENT_MANAGER:RegisterForUpdate(name, 1000, function() 
    EVENT_MANAGER:UnregisterForUpdate(name)
    SSEA.ObnoxiousSound(sound, count - 1)
    end )
end

-- Debug functions

function SSEA.GroupNames()
  for i=1,12 do
    local name = GetUnitDisplayName("group" .. tostring(i))
    if name ~= nil then 
      d("group" .. tostring(i) .. "=" .. name)
    end
  end
end