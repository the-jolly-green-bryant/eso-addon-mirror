LibWorldEvents.POI.Geyser = {}

-- @var bool onMap To know if the user is on a map where geyser world event can happen
LibWorldEvents.POI.Geyser.onMap = false

-- @var bool isGenerated To know if the list has been generated or not
LibWorldEvents.POI.Geyser.isGenerated = false

-- @var table List of all zone with geyser world events
LibWorldEvents.POI.Geyser.list = {
    { -- Le couchant / Summerset
        zoneId  = 1011,
        mapName = "summerset/summerset_base",
        list    = {
            title = {
                cp = {
                    [1] = GetString(SI_LIB_WORLD_EVENTS_CP_NORTH_EAST),
                    [2] = GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH_EAST),
                    [3] = GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH_CENTER),
                    [4] = GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH_WEST),
                    [5] = GetString(SI_LIB_WORLD_EVENTS_CP_CENTER_WEST),
                    [6] = GetString(SI_LIB_WORLD_EVENTS_CP_NORTH_WEST)
                },
                ln = {} --generated in generateList()
            },
            poiIDs = {
                [1] = 2016, --Direnni Abyssal Geyser
                [2] = 2038, --Sil-Var-Woad Abyssal Geyser
                [3] = 2071, --Sunhold Abyssal Geyser
                [4] = 2059, --Welenkin Abyssal Geyser
                [5] = 2049, --Rellenthil Abyssal Geyser
                [6] = 2058, --Corgrad Abyssal Geyser
            },
        },
    }
}

--[[
-- Obtain and add the location name of all POI to the list
-- To always have a updated value for the current language, I prefer to not save it myself
--]]
function LibWorldEvents.POI.Geyser:generateList()
    for listIdx, zoneData in ipairs(self.list) do
        for poiListIdx, poiId in ipairs(zoneData.list.poiIDs) do
            local zoneIdx, poiIdx = GetPOIIndices(poiId)
            local poiTitle        = GetPOIInfo(zoneIdx, poiIdx)
            zoneData.list.title.ln[poiListIdx] = zo_strformat(poiTitle)
        end
    end

    self.isGenerated = true
end

--[[
-- To obtain the zone's list where a geyser world event can happen
--]]
function LibWorldEvents.POI.Geyser:obtainList()
    if self.isGenerated == false then
        self:generateList()
    end

    return self.list
end
