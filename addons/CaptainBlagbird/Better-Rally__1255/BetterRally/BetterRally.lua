--[[

Better Rally
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

-- Addon info
BetterRally = {}
local AddonName = "BetterRally"
ZO_CreateStringId("SI_BINDING_NAME_BETTER_RALLY", "Better Rally")


-- Copied from 100013/src/ingame/map/worldmap.lua
local function IsNormalizedPointInsideMapBounds(x, y)
    -- At some point this could take a size as well to determine if an icon/pin would hang off the edge of the map, even though the center of the pin is inside the map.
    -- NOTE: This will NEVER show a point on the edge, assuming that icons displayed there would always hang outside the map.
    return (x > 0 and x < 1 and y > 0 and y < 1)
end
-- Copied from 100013/src/ingame/map/worldmap.lua
local function NormalizePreferredMousePositionToMap()
    if(IsInGamepadPreferredMode()) then
        local x, y = ZO_WorldMapScroll:GetCenter()
        return NormalizePointToControl(x, y, ZO_WorldMapContainer)
    else
        return NormalizeMousePositionToControl(ZO_WorldMapContainer)
    end
end

-- Function that is called from key binding
function BetterRally:PingMap()
    -- Assign pin type and ping functions according to player group status
    local pinType, getPoint, removePoint
    if IsUnitGrouped("player") then
        if IsUnitGroupLeader("player") then
            pinType = MAP_PIN_TYPE_RALLY_POINT
            getPoint = GetMapRallyPoint
            removePoint = RemoveRallyPoint
        else  -- Normal group member
            pinType = MAP_PIN_TYPE_PING
            getPoint = function() return 0, 0; end  -- Return null point (instead of GetMapPing("player")) so there will always be a new point set instead of trying to remove it.
            removePoint = function() end  -- No function available, point will be removed automatically
        end
    else  -- Not grouped
        pinType = MAP_PIN_TYPE_PLAYER_WAYPOINT
        getPoint = GetMapPlayerWaypoint
        removePoint = ZO_WorldMap_RemovePlayerWaypoint
    end
    
    -- Check if point set
    if IsNormalizedPointInsideMapBounds(getPoint()) then
        removePoint()
    else  -- Point not set yet
        -- Set map point if mouse within map
        local x, y = NormalizePreferredMousePositionToMap()
        if(IsNormalizedPointInsideMapBounds(x, y)) then
            PingMap(pinType, MAP_TYPE_LOCATION_CENTERED, x, y)
        end
    end
end