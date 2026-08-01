--[[

Map Tools
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]


-- Code from /esoui/ingame/map/worldmap.lua
local ZO_MapPanAndZoom = {MAX_OVER_ZOOM = 1.3}
function ZO_MapPanAndZoom:CanMapZoom()
    return GetMapContentType() ~= MAP_CONTENT_DUNGEON
end
function ZO_MapPanAndZoom:ComputeMinZoom()
    return 1
end
function ZO_MapPanAndZoom:ComputeMaxZoom()
    if(not self:CanMapZoom()) then
        return 1
    else
        local numTiles = GetMapNumTiles()
        local tilePixelWidth = ZO_WorldMapContainer1:GetTextureFileDimensions()
        local totalPixels = numTiles * tilePixelWidth
        local mapAreaUIUnits = ZO_WorldMapScroll:GetHeight()
        local mapAreaPixels = mapAreaUIUnits * GetUIGlobalScale()
        local maxZoomToStayBelowNative = totalPixels / mapAreaPixels
        return zo_max(maxZoomToStayBelowNative * ZO_MapPanAndZoom.MAX_OVER_ZOOM, 1)
    end
end

-- Custom limit
local function ChangeZoomLimit()
    -- Factor to normal zoom limit
    local FACTOR = 3
    -- Set new levels
    local minZoom = ZO_MapPanAndZoom:ComputeMinZoom()
    local maxZoom = ZO_MapPanAndZoom:ComputeMaxZoom()
    ZO_WorldMap_SetCustomZoomLevels(minZoom, maxZoom * FACTOR)
    -- d("Limit changed from "..tostring(maxZoom).." to "..tostring(maxZoom * FACTOR))
end

-- Overwrite map show function
local orig_ZO_WorldMap_ShowWorldMap = ZO_WorldMap_ShowWorldMap
ZO_WorldMap_ShowWorldMap = function()
    orig_ZO_WorldMap_ShowWorldMap()
    -- Clear old zoom levels
    ZO_WorldMap_ClearCustomZoomLevels()
    -- Set new zoom levels after 500 ms so the initial zoom that is set when opening the map stays the same
    zo_callLater(ChangeZoomLimit, 500)
end

-- Overwrite map update function
local orig_ZO_WorldMap_UpdateMap = ZO_WorldMap_UpdateMap
ZO_WorldMap_UpdateMap = function()
    orig_ZO_WorldMap_UpdateMap()
    -- Only continue if map is shown
    if ZO_WorldMap:IsHidden() then return end
    -- Clear old zoom levels
    ZO_WorldMap_ClearCustomZoomLevels()
    -- Set new zoom levels after 500 ms so the initial zoom that is set when opening the map stays the same
    zo_callLater(ChangeZoomLimit, 500)
end
