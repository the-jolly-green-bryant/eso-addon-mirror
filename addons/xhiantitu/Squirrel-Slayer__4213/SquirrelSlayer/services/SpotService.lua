local addon = SquirrelSlayer
addon.Services.Spots = addon.Services.Spots or {}
local Spots = addon.Services.Spots

local MERGE_RADIUS_METERS = 50
local gpsLibrary = rawget(_G, "LibGPS3")
    or rawget(_G, "LibGPS2")
    or rawget(_G, "LibGPS")
    or (LibStub and (LibStub("LibGPS3", true) or LibStub("LibGPS2", true) or LibStub("LibGPS", true)))
    or nil

--- Raccourci SavedVariables.
--- @return table|nil
local function GetSavedVariables()
    return addon.State.GetSV()
end

--- Proxy de log.
--- @param message string
--- @param force boolean|nil
local function Log(message, force)
    if addon.Internal.Log then addon.Internal.Log(message, force) end
end

--- Calcule la distance locale en mètres entre deux points de carte.
--- @return number|nil
local function DistanceMeters(pointAX, pointAY, pointBX, pointBY)
    if not (gpsLibrary and gpsLibrary.GetLocalDistanceInMeters) then return nil end
    return gpsLibrary:GetLocalDistanceInMeters(pointAX, pointAY, pointBX, pointBY)
end

--- Récupère les indices de spots voisins d'un centre donné.
local function CollectNeighborIndices(spotList, centerX, centerY, radiusMeters)
    local neighborIndices = {}
    for spotIndex, spot in ipairs(spotList) do
        local distanceMeters = DistanceMeters(centerX, centerY, spot.x, spot.y)
        if distanceMeters ~= nil and distanceMeters <= radiusMeters then
            neighborIndices[spotIndex] = true
        end
    end
    return neighborIndices
end

--- Calcule le barycentre pondéré d'un ensemble de spots.
local function ComputeWeightedCenter(spotList, selectedIndices, anchorX, anchorY, anchorWeight)
    local weightedSumX, weightedSumY, weightedCount = 0, 0, 0
    for spotIndex, spot in ipairs(spotList) do
        if selectedIndices[spotIndex] then
            local spotCount = spot.count or 1
            weightedSumX = weightedSumX + spot.x * spotCount
            weightedSumY = weightedSumY + spot.y * spotCount
            weightedCount = weightedCount + spotCount
        end
    end

    if anchorX and anchorY and anchorWeight and anchorWeight > 0 then
        weightedSumX = weightedSumX + anchorX * anchorWeight
        weightedSumY = weightedSumY + anchorY * anchorWeight
        weightedCount = weightedCount + anchorWeight
    end

    if weightedCount == 0 then return nil, nil, 0 end
    return weightedSumX / weightedCount, weightedSumY / weightedCount, weightedCount
end

--- Étend un groupe de voisins via plusieurs itérations de recentrage.
local function ExpandNeighborhood(spotList, startX, startY, radiusMeters, iterationCount)
    local currentCenterX, currentCenterY = startX, startY
    local mergedIndices = {}

    for _ = 1, iterationCount do
        local neighboringIndices = CollectNeighborIndices(spotList, currentCenterX, currentCenterY, radiusMeters)
        for spotIndex in pairs(neighboringIndices) do mergedIndices[spotIndex] = true end

        local recenteredX, recenteredY = ComputeWeightedCenter(spotList, neighboringIndices, currentCenterX, currentCenterY, 1)
        if recenteredX and recenteredY then
            currentCenterX, currentCenterY = recenteredX, recenteredY
        end
    end

    return mergedIndices
end

--- Fusionne les spots sélectionnés en un seul spot barycentrique.
local function ApplyFusion(spotList, indicesToMerge, anchorX, anchorY, includeAnchor)
    local indicesToRemove = {}
    local weightedSumX = includeAnchor and anchorX or 0
    local weightedSumY = includeAnchor and anchorY or 0
    local weightedCount = includeAnchor and 1 or 0

    for spotIndex, spot in ipairs(spotList) do
        if indicesToMerge[spotIndex] then
            local spotCount = spot.count or 1
            weightedSumX = weightedSumX + spot.x * spotCount
            weightedSumY = weightedSumY + spot.y * spotCount
            weightedCount = weightedCount + spotCount
            table.insert(indicesToRemove, 1, spotIndex)
        end
    end

    for _, spotIndex in ipairs(indicesToRemove) do table.remove(spotList, spotIndex) end

    local mergedX = weightedSumX / weightedCount
    local mergedY = weightedSumY / weightedCount
    table.insert(spotList, { x = mergedX, y = mergedY, count = weightedCount })
    return mergedX, mergedY, weightedCount
end

--- Retourne l'identifiant de pin consommé par LibMapPins.
function Spots.GetPinType()
    return "SquirrelSlayer_SpotPin"
end

--- Ajoute un spot d'écureuil et le fusionne si nécessaire avec les spots voisins.
function Spots.AddSquirrelSpot(mapKey, x, y)
    local savedVariables = GetSavedVariables()
    if not savedVariables or not mapKey or x == nil or y == nil then return end

    local mapService = addon.Services.Map
    local canonicalMapKey = mapService.CanonicalizeMapKey(mapKey)
    if canonicalMapKey == "mapId:0" or canonicalMapKey == "zoneId:0" or canonicalMapKey == "regionId:0" then return end

    savedVariables.spots[canonicalMapKey] = savedVariables.spots[canonicalMapKey] or {}
    mapService.MemorizeMapAndRegion(canonicalMapKey)
    SetMapToPlayerLocation()

    local spotList = savedVariables.spots[canonicalMapKey]
    local indicesToMerge = ExpandNeighborhood(spotList, x, y, MERGE_RADIUS_METERS, 3)

    local neighborsCount = 0
    for _ in pairs(indicesToMerge) do neighborsCount = neighborsCount + 1 end

    if neighborsCount > 0 then
        ApplyFusion(spotList, indicesToMerge, x, y, true)
    else
        table.insert(spotList, { x = x, y = y, count = 1 })
    end

    if addon.Services.Pins then addon.Services.Pins.RefreshPins() end
    if addon.Services.Events and addon.Services.Events.Emit then
        addon.Services.Events.Emit(addon.Services.Events.Channels.SPOTS_UPDATED, { mapKey = canonicalMapKey })
    end
end

--- Fusionne les spots proches de la position demandée (commande debug).
function Spots.MergeAroundPosition(mapKey, positionX, positionY)
    local savedVariables = GetSavedVariables()
    if not savedVariables then return nil end

    local mapService = addon.Services.Map
    local canonicalMapKey = mapService.CanonicalizeMapKey(mapKey)
    savedVariables.spots[canonicalMapKey] = savedVariables.spots[canonicalMapKey] or {}
    local spotList = savedVariables.spots[canonicalMapKey]
    if #spotList == 0 then return nil end

    local indicesToMerge = ExpandNeighborhood(spotList, positionX, positionY, MERGE_RADIUS_METERS, 3)
    local neighborsCount = 0
    for _ in pairs(indicesToMerge) do neighborsCount = neighborsCount + 1 end
    if neighborsCount <= 1 then return false, neighborsCount end

    local mergedX, mergedY, mergedTotalCount = ApplyFusion(spotList, indicesToMerge, positionX, positionY, false)
    if addon.Services.Pins then addon.Services.Pins.RefreshPins() end
    if addon.Services.Events and addon.Services.Events.Emit then
        addon.Services.Events.Emit(addon.Services.Events.Channels.SPOTS_UPDATED, { mapKey = canonicalMapKey })
    end
    return true, neighborsCount, mergedX, mergedY, mergedTotalCount
end

if not (gpsLibrary and gpsLibrary.GetLocalDistanceInMeters) then
    if addon.Internal.LogError then addon.Internal.LogError(addon.GetString("lgps_required")) end
    Log("Fallback: addon continue sans fusion métrique (LGPS absent)", true)
end
