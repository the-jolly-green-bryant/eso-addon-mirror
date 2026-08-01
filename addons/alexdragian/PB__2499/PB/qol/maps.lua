PB.hideTamriel = false

local original = GetFastTravelNodeInfo

GetFastTravelNodeInfo = function(nodeIndex, ...)

  local known, name, normalizedX, normalizedY, icon, glowIcon, poiType, isShownInCurrentMap, linkedCollectibleIsLocked = original(nodeIndex, ...)

  if GetMapType() == MAPTYPE_WORLD then
    if poiType == POI_TYPE_HOUSE and PB.db.default.options.mapFlags.homePreviews ~= true and icon == "/esoui/art/icons/poi/poi_group_house_unowned.dds" then
      return known, name, normalizedX, normalizedY, icon, glowIcon, poiType, false, linkedCollectibleIsLocked
    end
    if poiType == POI_TYPE_HOUSE and PB.db.default.options.mapFlags.ownedHomes ~= true and icon == "/esoui/art/icons/poi/poi_group_house_owned.dds" then
      return known, name, normalizedX, normalizedY, icon, glowIcon, poiType, false, linkedCollectibleIsLocked
    end

    if poiType == 1 and PB.db.default.options.mapFlags.waypoints ~= true then
      return known, name, normalizedX, normalizedY, icon, glowIcon, poiType, false, linkedCollectibleIsLocked
    end
    if poiType == 3 and PB.db.default.options.mapFlags.trials ~= true then
      return known, name, normalizedX, normalizedY, icon, glowIcon, poiType, false, linkedCollectibleIsLocked
    end
    if poiType == 6 and PB.db.default.options.mapFlags.dungeons ~= true then
      return known, name, normalizedX, normalizedY, icon, glowIcon, poiType, false, linkedCollectibleIsLocked
    end
    --if PB.hideTamriel then -- Everything
    --  return false, name, normalizedX, normalizedY, icon, glowIcon, poiType, isShownInCurrentMap, linkedCollectibleIsLocked
    --end

    return known, name, normalizedX, normalizedY, icon, glowIcon, poiType, isShownInCurrentMap, linkedCollectibleIsLocked

  end

  return known, name, normalizedX, normalizedY, icon, glowIcon, poiType, isShownInCurrentMap, linkedCollectibleIsLocked

end

function PB.HideMapClutter()
  if PB.hideTamriel then
    PB.hideTamriel = false
    ZO_WorldMap_UpdateMap()
  else
    PB.hideTamriel = true
    ZO_WorldMap_UpdateMap()
  end
end