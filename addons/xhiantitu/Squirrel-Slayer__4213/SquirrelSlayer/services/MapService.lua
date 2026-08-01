local addon = SquirrelSlayer
addon.Services.Map = addon.Services.Map or {}
local Map = addon.Services.Map

--- Raccourci SavedVariables.
--- @return table|nil
local function GetSavedVariables()
    return addon.State.GetSV()
end

local function Log(message, force) if addon.Internal.Log then addon.Internal.Log(message, force) end end
local function LogError(message) if addon.Internal.LogError then addon.Internal.LogError(message) end end

--- Construit une clé canonique basée sur un mapId.
function Map.BuildMapIdKey(mapId) return "mapId:" .. tostring(mapId) end
--- Construit une clé canonique basée sur un zoneId.
function Map.BuildZoneIdKey(zoneId) return "zoneId:" .. tostring(zoneId) end
--- Construit une clé canonique basée sur un regionId.
function Map.BuildRegionIdKey(regionId) return "regionId:" .. tostring(regionId) end

--- Extrait un mapId depuis une clé mapId:<id>.
function Map.ParseMapIdKey(key)
    if type(key) ~= "string" then return nil end
    local parsedId = key:match("^mapId:(%d+)$")
    return parsedId and tonumber(parsedId) or nil
end

--- Extrait un zoneId depuis une clé zoneId:<id>.
function Map.ParseZoneIdKey(key)
    if type(key) ~= "string" then return nil end
    local parsedId = key:match("^zoneId:(%d+)$")
    return parsedId and tonumber(parsedId) or nil
end

--- Extrait un regionId depuis une clé regionId:<id>.
function Map.ParseRegionIdKey(key)
    if type(key) ~= "string" then return nil end
    local parsedId = key:match("^regionId:(%d+)$")
    return parsedId and tonumber(parsedId) or nil
end

--- Remonte l'arbre des zones ESO pour trouver la région de plus haut niveau.
function Map.ComputeTopLevelRegionId(zoneId)
    if not zoneId or zoneId == 0 then return 0 end

    local visitedZoneIds, currentDepth, maxDepth = {}, 0, 32
    local currentZoneId = zoneId
    while true do
        if currentZoneId == 0 then return 0 end
        if visitedZoneIds[currentZoneId] then return currentZoneId end

        visitedZoneIds[currentZoneId] = true
        currentDepth = currentDepth + 1
        if currentDepth > maxDepth then return currentZoneId end

        local parentZoneId = GetParentZoneId and GetParentZoneId(currentZoneId) or 0
        if not parentZoneId or parentZoneId == 0 or parentZoneId == currentZoneId then return currentZoneId end
        currentZoneId = parentZoneId
    end
end

--- Convertit une ancienne mapKey texture en token attendu par LibMapData.
function Map.LegacyMapKeyToLibMapDataToken(mapKey)
    if type(mapKey) ~= "string" or mapKey == "" then return nil end
    if Map.ParseMapIdKey(mapKey) then return nil end

    local normalizedLegacyKey = mapKey:gsub("\\", "/"):lower()
    normalizedLegacyKey = normalizedLegacyKey:gsub("^.-/maps/", "")
    normalizedLegacyKey = normalizedLegacyKey:gsub("%.dds$", "")
    normalizedLegacyKey = normalizedLegacyKey:gsub("_0$", "")
    return normalizedLegacyKey .. "_0"
end

--- Tente de résoudre un mapId moderne à partir d'une clé legacy.
function Map.ResolveMapIdFromLegacyKey(mapKey)
    local mapIdFromKey = Map.ParseMapIdKey(mapKey)
    if mapIdFromKey and mapIdFromKey > 0 then return mapIdFromKey end

    local savedVariables = GetSavedVariables()
    if savedVariables and savedVariables.legacyMapKeyToId and savedVariables.legacyMapKeyToId[mapKey] then
        return savedVariables.legacyMapKeyToId[mapKey]
    end

    local libMapData = _G["LibMapData"]
    if not (libMapData and libMapData.GetMapIdByTileTexture) then return nil end

    local textureToken = Map.LegacyMapKeyToLibMapDataToken(mapKey)
    if not textureToken then return nil end

    local candidateMapIds = libMapData:GetMapIdByTileTexture(textureToken) or {}
    if type(candidateMapIds) ~= "table" then candidateMapIds = { candidateMapIds } end

    local selectedMapId = nil
    for _, candidateMapId in ipairs(candidateMapIds) do
        if type(candidateMapId) == "number" and candidateMapId > 0 then
            if not selectedMapId or candidateMapId < selectedMapId then selectedMapId = candidateMapId end
        end
    end

    if selectedMapId and selectedMapId > 0 and savedVariables and savedVariables.legacyMapKeyToId then
        savedVariables.legacyMapKeyToId[mapKey] = selectedMapId
    end
    return selectedMapId
end

--- Retourne une mapKey canonique (mapId prioritaire si résoluble).
function Map.CanonicalizeMapKey(mapKey)
    if Map.ParseMapIdKey(mapKey) or Map.ParseZoneIdKey(mapKey) or Map.ParseRegionIdKey(mapKey) then
        return mapKey
    end

    local resolvedMapId = Map.ResolveMapIdFromLegacyKey(mapKey)
    if resolvedMapId and resolvedMapId > 0 then return Map.BuildMapIdKey(resolvedMapId) end
    return mapKey
end

--- Détermine la clé carte courante en privilégiant mapId puis zoneId puis regionId.
function Map.CurrentMapKey()
    local currentMapId = GetCurrentMapId and GetCurrentMapId() or nil
    if currentMapId and currentMapId > 0 then return Map.BuildMapIdKey(currentMapId) end

    local currentMapZoneIndex = GetCurrentMapZoneIndex and GetCurrentMapZoneIndex() or 0
    local currentZoneId = (currentMapZoneIndex ~= 0 and GetZoneId and GetZoneId(currentMapZoneIndex)) or 0
    if currentZoneId and currentZoneId > 0 then return Map.BuildZoneIdKey(currentZoneId) end

    local currentRegionId = Map.ComputeTopLevelRegionId(currentZoneId)
    if currentRegionId and currentRegionId > 0 then return Map.BuildRegionIdKey(currentRegionId) end
    return "regionId:0"
end

--- Retourne la clé région courante et son nom affichable.
function Map.CurrentRegionKeyAndName()
    local currentMapZoneIndex = GetCurrentMapZoneIndex and GetCurrentMapZoneIndex() or 0
    local currentZoneId = (currentMapZoneIndex ~= 0 and GetZoneId and GetZoneId(currentMapZoneIndex)) or 0
    local currentRegionId = Map.ComputeTopLevelRegionId(currentZoneId)

    if currentRegionId and currentRegionId > 0 then
        return Map.BuildRegionIdKey(currentRegionId), zo_strformat("<<C:1>>", GetZoneNameById(currentRegionId))
    end
    return Map.BuildRegionIdKey(0), zo_strformat("<<C:1>>", GetMapName())
end

--- Mémorise les relations map->nom/région/zone pour la map donnée.
function Map.MemorizeMapAndRegion(mapKey)
    local savedVariables = GetSavedVariables()
    if not savedVariables then return end

    if not savedVariables.mapNames[mapKey] then
        savedVariables.mapNames[mapKey] = zo_strformat("<<C:1>>", GetMapName())
    end

    if not savedVariables.mapToRegion[mapKey] then
        local regionKey, regionName = Map.CurrentRegionKeyAndName()
        savedVariables.mapToRegion[mapKey] = regionKey
        savedVariables.regionNames[regionKey] = savedVariables.regionNames[regionKey] or regionName
        savedVariables.knownRegions[regionKey] = true
    end

    if not savedVariables.mapToZone[mapKey] then
        local currentMapZoneIndex = GetCurrentMapZoneIndex and GetCurrentMapZoneIndex() or 0
        local currentZoneId = (currentMapZoneIndex ~= 0 and GetZoneId and GetZoneId(currentMapZoneIndex)) or 0
        savedVariables.mapToZone[mapKey] = Map.BuildZoneIdKey(currentZoneId or 0)
    end
end

--- Ajoute la région courante aux régions connues.
function Map.RememberCurrentRegion()
    local savedVariables = GetSavedVariables()
    if not savedVariables then return end

    local regionKey, regionName = Map.CurrentRegionKeyAndName()
    if regionKey and regionKey ~= "" then
        savedVariables.knownRegions[regionKey] = true
        if regionName and regionName ~= "" then
            savedVariables.regionNames[regionKey] = savedVariables.regionNames[regionKey] or regionName
        end
    end
end

--- Copie une liste de spots dans une autre structure en conservant x/y/count.
local function MergeSpotLists(targetSpotList, sourceSpotList)
    if type(targetSpotList) ~= "table" or type(sourceSpotList) ~= "table" then return end
    for _, sourceSpot in ipairs(sourceSpotList) do
        targetSpotList[#targetSpotList + 1] = { x = sourceSpot.x, y = sourceSpot.y, count = sourceSpot.count or 1 }
    end
end

--- Migre les anciennes clés texture vers les nouvelles clés mapId:<id>.
function Map.MigrateLegacyMapKeysToMapId()
    local savedVariables = GetSavedVariables()
    if not savedVariables then return end

    savedVariables.migration = savedVariables.migration or {}
    savedVariables.legacyMapKeyToId = savedVariables.legacyMapKeyToId or {}
    if savedVariables.migration.mapKeyVersion == 2 and savedVariables.migration.done == true then return end

    local migratedSpotsByMapKey, migratedMapNames, migratedMapToRegion, migratedMapToZone = {}, {}, {}, {}
    local migratedCount, unresolvedCount = 0, 0

    for oldMapKey, legacySpotList in pairs(savedVariables.spots or {}) do
        local resolvedMapId = Map.ResolveMapIdFromLegacyKey(oldMapKey)
        if resolvedMapId and resolvedMapId > 0 then
            local newMapKey = Map.BuildMapIdKey(resolvedMapId)
            migratedSpotsByMapKey[newMapKey] = migratedSpotsByMapKey[newMapKey] or {}
            MergeSpotLists(migratedSpotsByMapKey[newMapKey], legacySpotList)

            if savedVariables.mapNames and savedVariables.mapNames[oldMapKey] and not migratedMapNames[newMapKey] then migratedMapNames[newMapKey] = savedVariables.mapNames[oldMapKey] end
            if savedVariables.mapToRegion and savedVariables.mapToRegion[oldMapKey] and not migratedMapToRegion[newMapKey] then migratedMapToRegion[newMapKey] = savedVariables.mapToRegion[oldMapKey] end
            if savedVariables.mapToZone and savedVariables.mapToZone[oldMapKey] and not migratedMapToZone[newMapKey] then migratedMapToZone[newMapKey] = savedVariables.mapToZone[oldMapKey] end
            migratedCount = migratedCount + 1
        else
            migratedSpotsByMapKey[oldMapKey] = migratedSpotsByMapKey[oldMapKey] or {}
            MergeSpotLists(migratedSpotsByMapKey[oldMapKey], legacySpotList)
            if savedVariables.mapNames and savedVariables.mapNames[oldMapKey] then migratedMapNames[oldMapKey] = savedVariables.mapNames[oldMapKey] end
            if savedVariables.mapToRegion and savedVariables.mapToRegion[oldMapKey] then migratedMapToRegion[oldMapKey] = savedVariables.mapToRegion[oldMapKey] end
            if savedVariables.mapToZone and savedVariables.mapToZone[oldMapKey] then migratedMapToZone[oldMapKey] = savedVariables.mapToZone[oldMapKey] end
            unresolvedCount = unresolvedCount + 1
        end
    end

    savedVariables.spots = migratedSpotsByMapKey
    savedVariables.mapNames = migratedMapNames
    savedVariables.mapToRegion = migratedMapToRegion
    savedVariables.mapToZone = migratedMapToZone
    savedVariables.migration.mapKeyVersion = 2
    savedVariables.migration.done = (unresolvedCount == 0)

    if SetMapToPlayerLocation then SetMapToPlayerLocation() end
    Log(string.format("[Migration] mapKey -> mapId terminé: migrated=%d unresolved=%d", migratedCount, unresolvedCount), true)
end

--- Retourne la position joueur sur la carte courante (x,y,mapKey).
function Map.GetPlayerMapPos()
    SetMapToPlayerLocation()
    local playerX, playerY = GetMapPlayerPosition("player")

    -- Certains états du worldmap renvoient 0/0: on force un rafraîchissement.
    if (not playerX or not playerY) or (playerX <= 0 and playerY <= 0) then
        local currentMapIndex = GetCurrentMapIndex()
        if currentMapIndex then ZO_WorldMap_SetMapByIndex(currentMapIndex) end
        playerX, playerY = GetMapPlayerPosition("player")
    end
    return playerX, playerY, Map.CurrentMapKey()
end

local topLevelRegionCache = {}

--- Variante cache de ComputeTopLevelRegionId pour utilisation intensive.
function Map.SafeGetTopLevelRegionId(zoneId)
    if not zoneId or zoneId == 0 then return 0 end

    local cachedRegionId = topLevelRegionCache[zoneId]
    if cachedRegionId ~= nil then return cachedRegionId end

    local visitedZoneIds, currentDepth, maxDepth = {}, 0, 32
    local currentZoneId = zoneId
    while true do
        if currentZoneId == 0 then topLevelRegionCache[zoneId] = 0; return 0 end
        if visitedZoneIds[currentZoneId] then topLevelRegionCache[zoneId] = currentZoneId; return currentZoneId end

        visitedZoneIds[currentZoneId] = true
        currentDepth = currentDepth + 1
        if currentDepth > maxDepth then topLevelRegionCache[zoneId] = currentZoneId; return currentZoneId end

        local parentZoneId = GetParentZoneId(currentZoneId)
        if not parentZoneId or parentZoneId == 0 or parentZoneId == currentZoneId then
            topLevelRegionCache[zoneId] = currentZoneId
            return currentZoneId
        end
        currentZoneId = parentZoneId
    end
end

--- Construit la liste des régions racines à partir du catalogue LibZone.
function Map.BuildAllRegionsWithLibZone()
    local libZone = _G["LibZone"]
    if not (libZone and libZone.data) then return {} end

    local rootRegionFlags = {}
    for zoneId, zoneEntry in pairs(libZone.data) do
        local parentZoneId = zoneEntry.parentZoneId or 0
        if parentZoneId == 0 or not libZone.data[parentZoneId] or parentZoneId == zoneId then
            rootRegionFlags[zoneId] = true
        end
    end

    local regions = {}
    for regionId in pairs(rootRegionFlags) do
        local regionName = (libZone.GetZoneName and libZone:GetZoneName(regionId)) or zo_strformat("<<C:1>>", GetZoneNameById(regionId))
        regions[#regions + 1] = { id = regionId, name = regionName }
    end

    table.sort(regions, function(leftRegion, rightRegion) return leftRegion.name < rightRegion.name end)
    return regions
end

-- Contrats internes réutilisés dans d'autres services.
addon.Internal.BuildAllRegionsWithLibZone = Map.BuildAllRegionsWithLibZone
addon.Internal.BuildRegionIdKey = Map.BuildRegionIdKey
addon.Internal.ParseRegionIdKey = Map.ParseRegionIdKey
addon.Internal.ParseMapIdKey = Map.ParseMapIdKey
addon.Internal.ParseZoneIdKey = Map.ParseZoneIdKey
addon.Internal.SafeGetTopLevelRegionId = Map.SafeGetTopLevelRegionId
addon.Internal.GetSavedVars = GetSavedVariables
addon.Internal.RememberCurrentRegion = Map.RememberCurrentRegion

local libZone = _G["LibZone"]
if not (libZone and libZone.data) then
    LogError(addon.GetString("libzone_required"))
    Log("Fallback: addon continue sans catalogue LibZone", true)
end
