--[[

Find POI
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]


local function IsMapPointSet(x,y)
    if x==0 and y==0 then
        return false
    else
        return true
    end
end

local function FindPOI(text)
    if text == "" then
        local isWpSet = IsMapPointSet(GetMapPlayerWaypoint())
        RemovePlayerWaypoint()
        if isWpSet then d("Waypoint removed") end
    else
        local found, objectiveName, x, y
        -- Try to find POI
        local zoneIndex = GetCurrentMapZoneIndex()
        for poiIndex=1, GetNumPOIs(zoneIndex) do
            objectiveName = GetPOIInfo(zoneIndex, poiIndex)
            if string.match(string.lower(objectiveName), string.lower(text)) ~= nil then
                ZO_WorldMap_ShowWorldMap()
                zo_callLater(function() ZO_WorldMapZoom_OnMouseWheel(-25) end, 20)
                -- Get POI info and add waypoint on the location
                x, y = GetPOIMapInfo(zoneIndex, poiIndex)
                PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, x, y)
                found = true
                break
            end
        end
        if found then
            -- Normalise and round coordinates to format XX.XX
            x, y = math.floor(x*10000+0.5)/100, math.floor(y*10000+0.5)/100
            d("POI \"|cFFFFFF"..objectiveName.."|r\" found at |cFFFFFF"..tostring(x).."|rx|cFFFFFF"..tostring(y))
        else
            d("No matching POI found in current map")
        end
    end
end
SLASH_COMMANDS["/findpoi"] = FindPOI