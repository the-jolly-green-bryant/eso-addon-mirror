local Log = ImperialCartographer_Logger()

local IC = ImperialCartographer

-- ----------------------------------------------------------------------------

local function addWaypointTexture(marker)
    IMP_CART_Waypoint:SetAnchor(BOTTOM, marker.control, TOP)
    IMP_CART_Waypoint:SetHidden(false)

    local EM = LibImplex.EVENT_MANAGER
    pcall(EM.RegisterForEvent, 'ImperialCartographerWaypoint', EM.EVENT_AFTER_UPDATE, function()
        IMP_CART_Waypoint:SetHidden(marker:IsHidden())
    end)  -- TODO: refactor :D
end

local WAYPOINT_MARKER

local function removeExistingWaypointMarker()
    if not WAYPOINT_MARKER then return end

    local markerIndex = IC.poiIdToMarkerIndex[WAYPOINT_MARKER]
    if not markerIndex then return end

    IMP_CART_Waypoint:ClearAnchors()
    IMP_CART_Waypoint:SetHidden(true)

    local EM = LibImplex.EVENT_MANAGER
    EM.UnregisterForEvent('ImperialCartographerWaypoint', EM.EVENT_AFTER_UPDATE)

    IC.activeMarkers[markerIndex]:SetClampedToScreen(false)
    IC.activeMarkers[markerIndex]:Delete()
    IC.activeMarkers[markerIndex] = IC:Place(WAYPOINT_MARKER)

    WAYPOINT_MARKER = nil
end

local function handleNewWaypoint(wpnX, wpnY)
    local zoneIndex = GetCurrentMapZoneIndex()
    -- local mnX, mnY = NormalizeMousePositionToControl(ZO_WorldMapContainer)

    local closestPOIId
    local minimalDistance = math.huge

    for i = 1, GetNumPOIs(zoneIndex) do
        local nX, nY = GetPOIMapInfo(zoneIndex, i)
        local dX, dY = nX - wpnX, nY - wpnY
        local distance = math.sqrt(dX * dX + dY * dY)

        if distance < minimalDistance then
            closestPOIId = IC.GetPOIId(zoneIndex, i)
            minimalDistance = distance
        end
    end

    if minimalDistance > 0.015 then return end

    Log('Waypoint close to poiId: %d', closestPOIId)

    local markerIndex = IC.poiIdToMarkerIndex[closestPOIId]
    if not markerIndex then return end

    IC.DefaultPOI.Manager:Add(closestPOIId, IC.ALWAYS_VISIBLE)

    WAYPOINT_MARKER = closestPOIId
end

local function onPlayerActivated()
    local wpnX, wpnY = GetMapPlayerWaypoint()

    if wpnX ~= 0 or wpnY ~= 0 then
        handleNewWaypoint(wpnX, wpnY)
    end
end

-- ----------------------------------------------------------------------------

local function setupWaypointHandling()
    ZO_PostHook(ZO_WorldMap_GetPinManager(), 'CreatePin', function(pinManager, pinType, pinTag, xLoc, yLoc, radius, borderInformation, isSymbolicLoc)
        if pinType ~= MAP_PIN_TYPE_PLAYER_WAYPOINT then return end

        Log('Waypoint created: x:%.4f y:%.4f', xLoc, yLoc)

        removeExistingWaypointMarker()
        handleNewWaypoint(xLoc, yLoc)
    end)

    ZO_PostHook(_G, 'ZO_WorldMap_RemovePlayerWaypoint', removeExistingWaypointMarker)
    ZO_PostHook(_G, 'RemovePlayerWaypoint', removeExistingWaypointMarker)

    EVENT_MANAGER:RegisterForEvent('ImperialCartographer_Waypoint', EVENT_PLAYER_ACTIVATED, onPlayerActivated)
end

setupWaypointHandling()
