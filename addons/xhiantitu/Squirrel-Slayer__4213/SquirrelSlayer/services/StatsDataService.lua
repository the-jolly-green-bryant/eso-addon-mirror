local addon = SquirrelSlayer

local function Log(message, force) if addon.Internal.Log then addon.Internal.Log(message, force) end end
local function LogError(message) if addon.Internal.LogError then addon.Internal.LogError(message) end end

--- Affiche une liste de régions dans les logs, par blocs pour éviter les lignes trop longues.
local function DumpRegionList(title, regionList)
    Log(string.format("[SquirrelSlayer] %s (%d)", title, #regionList), true)

    local lineBatch = {}
    for _, regionData in ipairs(regionList) do
        lineBatch[#lineBatch + 1] = string.format("%s (id=%d)", regionData.name, regionData.id)
        if #lineBatch >= 30 then
            Log(table.concat(lineBatch, " ; "), true)
            lineBatch = {}
        end
    end

    if #lineBatch > 0 then Log(table.concat(lineBatch, " ; "), true) end
    Log(string.format("[SquirrelSlayer] --- fin (%d lignes) ---", #regionList), true)
end

-- Commandes slash orientées diagnostic / maintenance des données.
SLASH_COMMANDS["/sqregionsapi"] = function()
    Log("/sqregionsapi: API ESO désactivée, utilisation LibZone.", true)
    local hasSuccess, regionListOrError = pcall(addon.Services.Map.BuildAllRegionsWithLibZone)
    if hasSuccess and regionListOrError then
        DumpRegionList("Regions via LibZone", regionListOrError)
    else
        LogError(string.format("[SquirrelSlayer] Erreur LibZone: %s", tostring(regionListOrError)))
    end
end

SLASH_COMMANDS["/sqregionslib"] = function()
    local hasSuccess, regionListOrError = pcall(addon.Services.Map.BuildAllRegionsWithLibZone)
    if hasSuccess and regionListOrError then
        DumpRegionList("Regions via LibZone", regionListOrError)
    else
        LogError(string.format("[SquirrelSlayer] Erreur LibZone: %s", tostring(regionListOrError)))
    end
end

SLASH_COMMANDS["/sqtexture"] = function()
    SetMapToPlayerLocation()
    local mapTexture = GetMapTileTexture()
    Log(string.format("[SquirrelSlayer] texture = %s", tostring(mapTexture)), true)
end

SLASH_COMMANDS["/sqlistkeys"] = function()
    local savedVariables = addon.State.GetSV()
    if not savedVariables or not savedVariables.spots then
        Log("[SquirrelSlayer] /sqlistkeys : SV.spots introuvable.", true)
        return
    end

    Log("[SquirrelSlayer] ===== MapKey -> IDs zone/région =====", true)
    for mapKey in pairs(savedVariables.spots) do
        local mapIdFromKey = addon.Services.Map.ParseMapIdKey(mapKey)
        if mapIdFromKey and mapIdFromKey > 0 then
            local mapZoneIndex, zoneId, regionId = 0, 0, 0
            if SetMapToMapId and SetMapToMapId(mapIdFromKey) then
                mapZoneIndex = GetCurrentMapZoneIndex() or 0
                zoneId = (mapZoneIndex ~= 0) and GetZoneId(mapZoneIndex) or 0
                regionId = (zoneId ~= 0) and addon.Services.Map.SafeGetTopLevelRegionId(zoneId) or 0
            end
            Log(string.format("mapKey=%s type=mapId mapId=%d zoneId=%d regionId=%d", mapKey, mapIdFromKey, zoneId, regionId), true)
        else
            local zoneIdFromKey = addon.Services.Map.ParseZoneIdKey(mapKey)
            local regionIdFromKey = addon.Services.Map.ParseRegionIdKey(mapKey)
            if zoneIdFromKey and zoneIdFromKey > 0 then
                Log(string.format("mapKey=%s type=zoneId zoneId=%d regionId=%d", mapKey, zoneIdFromKey, addon.Services.Map.SafeGetTopLevelRegionId(zoneIdFromKey)), true)
            elseif regionIdFromKey and regionIdFromKey > 0 then
                Log(string.format("mapKey=%s type=regionId regionId=%d", mapKey, regionIdFromKey), true)
            else
                Log(string.format("mapKey=%s type=legacy canonical=%s", mapKey, tostring(addon.Services.Map.CanonicalizeMapKey(mapKey))), true)
            end
        end
    end

    Log("[SquirrelSlayer] ===== fin =====", true)
    if SetMapToPlayerLocation then SetMapToPlayerLocation() end
end

SLASH_COMMANDS["/sqbuildkills"] = function()
    local savedVariables = addon.State.GetSV()
    if not savedVariables or not savedVariables.spots then
        Log("[SquirrelSlayer] /sqbuildkills : SV.spots introuvable.", true)
        return
    end

    -- Reconstruction d'une structure Kills historisée par zone et sous-carte.
    savedVariables.Kills = {}
    for mapKey, spotList in pairs(savedVariables.spots) do
        local zoneId, regionId = 0, 0
        local mapBucket = mapKey
        local mapName = (savedVariables.mapNames and savedVariables.mapNames[mapKey]) or tostring(mapKey)

        local parsedMapId = addon.Services.Map.ParseMapIdKey(mapKey)
        if parsedMapId and parsedMapId > 0 and SetMapToMapId and SetMapToMapId(parsedMapId) then
            local mapZoneIndex = GetCurrentMapZoneIndex() or 0
            zoneId = (mapZoneIndex ~= 0) and GetZoneId(mapZoneIndex) or 0
            regionId = (zoneId ~= 0) and addon.Services.Map.SafeGetTopLevelRegionId(zoneId) or 0
            mapBucket = parsedMapId
            mapName = GetMapName() or mapName
        end

        if zoneId == 0 then
            local zoneIdCandidate = addon.Services.Map.ParseZoneIdKey(mapKey)
            local regionIdCandidate = addon.Services.Map.ParseRegionIdKey(mapKey)
            zoneId = zoneIdCandidate or 0
            regionId = regionIdCandidate or 0
        end

        if zoneId > 0 then
            savedVariables.Kills[zoneId] = savedVariables.Kills[zoneId] or {}
            savedVariables.Kills[zoneId][mapBucket] = savedVariables.Kills[zoneId][mapBucket] or {}
            savedVariables.Kills[zoneId][mapBucket]._mapName = mapName

            for spotIndex, spot in pairs(spotList) do
                savedVariables.Kills[zoneId][mapBucket][spotIndex] = { count = spot.count, x = spot.x, y = spot.y }
            end
        end
    end

    if SetMapToPlayerLocation then SetMapToPlayerLocation() end
    if RequestAddOnSavedVariablesSave then RequestAddOnSavedVariablesSave() end
    Log("[SquirrelSlayer] /sqbuildkills terminé.", true)
end
