OpulentOrdealNavigator = OpulentOrdealNavigator or {}

local OON = OpulentOrdealNavigator
local UPDATE_NAME = "OpulentOrdealNavigatorPathAnimator"

OON.markerStates = OON.markerStates or {}
OON.routeLineControls = OON.routeLineControls or {}

local ACTIVE_ROUTE_LINE_COLOR = { 1, 1, 1, 0.92 }
local ACTIVE_ROUTE_LINE_WIDTH = 0.34
local ROUTE_LINE_WIDTH = 0.22

local function GetPathSettings()
    local saved = OON.saved or {}
    return saved.pathAnimation or {}
end

local IMPORTANT_MARKER_KINDS = {
    pickup = true,
    join = true,
    drop = true,
    final = true,
    middle = true,
    tank = true,
}

local IMPORTANT_LABEL_PATTERNS = {
    "kill boss",
    "pick up",
    "pickup",
    "deliver orb",
    "place orb",
    "final holder",
}

local function IsImportantMarker(marker)
    if not marker then
        return false
    end
    if IMPORTANT_MARKER_KINDS[marker.kind] then
        return true
    end

    local text = string.lower(marker.renderLabel or "")
    for _, pattern in ipairs(IMPORTANT_LABEL_PATTERNS) do
        if string.find(text, pattern, 1, true) then
            return true
        end
    end
    return false
end

local function MarkImportantMarker(importantMarkers, markerId)
    if markerId then
        importantMarkers[markerId] = true
    end
end

local function BuildFlatMarkerList(plan, teamColor)
    local markers = {}
    local markerRooms = {}
    local importantMarkers = {}
    local seen = {}
    local firstMarkerId = nil

    for _, segment in ipairs(plan.pathSegments or {}) do
        if not teamColor or segment.from == teamColor or segment.owner == teamColor then
            local segmentMarkers = segment.markers or {}
            MarkImportantMarker(importantMarkers, segmentMarkers[1])
            MarkImportantMarker(importantMarkers, segmentMarkers[#segmentMarkers])
            for _, markerId in ipairs(segment.markers or {}) do
                if not seen[markerId] then
                    markers[#markers + 1] = markerId
                    seen[markerId] = true
                    firstMarkerId = firstMarkerId or markerId
                end
                markerRooms[markerId] = segment.owner or teamColor or segment.from

                local marker = OON.MARKERS and OON.MARKERS[markerId]
                if IsImportantMarker(marker) then
                    MarkImportantMarker(importantMarkers, markerId)
                end
            end
        end
    end

    MarkImportantMarker(importantMarkers, firstMarkerId)
    return markers, markerRooms, importantMarkers
end

local function SetMarkerState(markerId, visible, active, showArrow)
    OON.markerStates[markerId] = {
        visible = visible,
        active = active,
        showArrow = showArrow == true,
    }

    -- Route profiles use this renderer regardless of whether the coordinates
    -- came from local route data, imported source data, or live test overrides.
    if OON.SetMarkerVisible then
        OON.SetMarkerVisible(markerId, visible, active, showArrow == true)
    end
end

local RefreshRouteLines

local function ShowStaticPath(markers)
    EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)

    for _, markerId in ipairs(markers or {}) do
        SetMarkerState(markerId, true, false)
    end
end

local function GetMarkerPosition(markerId)
    local marker = markerId and OON.MARKERS and OON.MARKERS[markerId]
    if marker and marker.x and marker.y and marker.z then
        return marker.x, marker.y, marker.z
    end
    return nil
end

local function RemoveRouteLine(index)
    local entry = OON.routeLineControls[index]
    if not entry then
        return
    end
    local key = type(entry) == "table" and entry.key or entry

    if OON.WorldRenderer and OON.WorldRenderer.RemoveLine then
        OON.WorldRenderer.RemoveLine(key)
    end
    OON.routeLineControls[index] = nil
end

local function ClearRouteLines()
    for index in pairs(OON.routeLineControls) do
        RemoveRouteLine(index)
    end
end

local function GetRouteLineColor(animation)
    local room = animation and animation.teamColor
    local roomColor = room and OON.ROOMS and OON.ROOMS[room] and OON.ROOMS[room].color
    if roomColor then
        return { roomColor[1], roomColor[2], roomColor[3], 0.5 }
    end
    return { 0.4, 0.9, 1, 0.45 }
end

local function IsActiveRouteLine(animation, settings, index)
    if not animation or animation.completed or settings.enabled ~= true then
        return false
    end
    local markerCount = #(animation.markers or {})
    if markerCount < 2 then
        return false
    end
    if animation.index >= markerCount then
        return index == markerCount - 1
    end
    return index == animation.index
end

RefreshRouteLines = function(animation, settings)
    if not animation
        or settings.showRouteLines == false
        or not OON.WorldRenderer
        or not OON.WorldRenderer.CreateLine
    then
        ClearRouteLines()
        return
    end

    local desired = {}
    local markers = animation.markers or {}
    local color = GetRouteLineColor(animation)
    for index = 1, #markers - 1 do
        local fromId = markers[index]
        local toId = markers[index + 1]
        local fromState = OON.markerStates[fromId]
        local toState = OON.markerStates[toId]
        if fromState and fromState.visible and toState and toState.visible then
            desired[index] = true
            local isActiveLine = IsActiveRouteLine(animation, settings, index)
            local existing = OON.routeLineControls[index]
            if existing and (type(existing) ~= "table" or existing.active ~= isActiveLine) then
                RemoveRouteLine(index)
                existing = nil
            end
            if not existing then
                local x1, y1, z1 = GetMarkerPosition(fromId)
                local x2, y2, z2 = GetMarkerPosition(toId)
                if x1 and x2 then
                    local lineKey = OON.WorldRenderer.CreateLine(
                        x1, y1, z1,
                        x2, y2, z2,
                        isActiveLine and ACTIVE_ROUTE_LINE_WIDTH or ROUTE_LINE_WIDTH,
                        isActiveLine and ACTIVE_ROUTE_LINE_COLOR or color
                    )
                    if lineKey then
                        OON.routeLineControls[index] = {
                            key = lineKey,
                            active = isActiveLine,
                        }
                    end
                end
            end
        end
    end

    for index in pairs(OON.routeLineControls) do
        if not desired[index] then
            RemoveRouteLine(index)
        end
    end
end

local function GetPlayerPosition()
    if GetUnitRawWorldPosition then
        local _, x, y, z = GetUnitRawWorldPosition("player")
        return x, y, z
    end
    return nil
end

local function GetSquaredHorizontalDistance(x1, z1, x2, z2)
    local dx = x1 - x2
    local dz = z1 - z2
    return dx * dx + dz * dz
end

local function AdvancePathIndex(animation)
    if animation.index >= #animation.markers then
        animation.index = 1
        animation.completed = true
        return true
    end

    animation.index = animation.index + 1
    return true
end

local function EnsureReachableMarker(animation)
    for _ = 1, #animation.markers do
        if GetMarkerPosition(animation.markers[animation.index]) then
            return true
        end
        AdvancePathIndex(animation)
    end
    return false
end

local function RenderFullPathWithActive(animation)
    for index, markerId in ipairs(animation.markers or {}) do
        local active = index == animation.index
        SetMarkerState(markerId, true, active, active and animation.navigationArrows)
    end
end

local function RenderProximityPath(animation, settings)
    RenderFullPathWithActive(animation)
end

local function IsCurrentMarkerReached(animation, settings)
    if not EnsureReachableMarker(animation) then
        return false
    end

    local playerX, _, playerZ = GetPlayerPosition()
    local markerX, _, markerZ = GetMarkerPosition(animation.markers[animation.index])
    if not playerX or not markerX then
        return false
    end

    local radius = tonumber(settings.proximityRadius) or 250
    return GetSquaredHorizontalDistance(playerX, playerZ, markerX, markerZ) <= radius * radius
end

function OON.RenderProximityPathStep()
    local animation = OON.pathAnimation
    if not animation then
        EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
        return
    end

    local settings = GetPathSettings()
    if settings.enabled == false then
        ShowStaticPath(animation.markers)
        RefreshRouteLines(animation, settings)
        return
    end

    if not animation.completed and IsCurrentMarkerReached(animation, settings) then
        AdvancePathIndex(animation)
    end

    RenderProximityPath(animation, settings)
    RefreshRouteLines(animation, settings)

    if animation.completed then
        EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
    end
end

function OON.RefreshPathRendering()
    local animation = OON.pathAnimation
    if not animation then
        ClearRouteLines()
        return
    end

    EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)

    local settings = GetPathSettings()
    if settings.enabled == false then
        ShowStaticPath(animation.markers)
        RefreshRouteLines(animation, settings)
        return
    end

    RenderProximityPath(animation, settings)
    RefreshRouteLines(animation, settings)
    EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, settings.intervalMs or 100, OON.RenderProximityPathStep)
end

function OON.HideAnimatedPath()
    EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
    ClearRouteLines()

    if not OON.pathAnimation then
        return
    end

    for _, markerId in ipairs(OON.pathAnimation.markers or {}) do
        SetMarkerState(markerId, false, false)
    end

    OON.markerDisplayRooms = nil
    OON.pathAnimation = nil
end

function OON.AnimatePlanPath(plan, teamColor)
    if not plan then
        return nil
    end

    local settings = (OON.saved and OON.saved.pathAnimation) or {}
    if settings.onlyOwnTeam ~= false then
        teamColor = teamColor or OON.playerColor
        if not teamColor then
            OON.HideAnimatedPath()
            if OON.Print then
                OON.Print("No path shown. Set your color first with /oon color red, orange, or purple.")
            end
            return nil
        end
    end

    local markers, markerRooms, importantMarkers = BuildFlatMarkerList(plan, teamColor)
    if #markers == 0 then
        OON.HideAnimatedPath()
        return nil
    end

    OON.HideAnimatedPath()
    OON.pathAnimation = {
        markers = markers,
        importantMarkers = importantMarkers,
        index = 1,
        completed = false,
        navigationArrows = not string.find(plan.task or "", "soak", 1, true),
        teamColor = teamColor,
    }
    OON.markerDisplayRooms = markerRooms

    OON.RefreshPathRendering()
    if OON.Print then
        OON.Print(string.format("Showing full route: %d markers.", #markers))
    end
    return markers
end
