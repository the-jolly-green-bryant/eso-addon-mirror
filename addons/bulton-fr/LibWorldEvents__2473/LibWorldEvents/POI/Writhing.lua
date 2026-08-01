LibWorldEvents.POI.Writhing = {}

-- @var bool onMap To know if the user is on a map where Writhing world event can happen
LibWorldEvents.POI.Writhing.onMap = false

-- @var bool isGenerated To know if the list has been generated or not
LibWorldEvents.POI.Writhing.isGenerated = false

-- @var table List of all zone with Writhing world events
LibWorldEvents.POI.Writhing.list = {
    { -- solstice
        zoneId  = 1502,
        mapName = "solstice/solsticeoverland_base",
        list    = {
            title = {
                cp = {
                    [1] = GetString(SI_LIB_WORLD_EVENTS_CP_NORTH),
                    [2] = GetString(SI_LIB_WORLD_EVENTS_CP_NORTH_WEST),
                    [3] = GetString(SI_LIB_WORLD_EVENTS_CP_WEST),
                    [4] = GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH_WEST),
                    [5] = GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH),
                },
                ln = {} --generated in generateList()
            },
            poiIDs = {
                [1] = 2869, --North Siege Camp
                [2] = 2870, --Sunport Siege Camp
                [3] = 2871, --Central Siege Camp
                [4] = 2872, --Warm-Stone Siege Camp
                [5] = 2873, --South Siege Camp
            },
        },
    }
}

--[[
-- Obtain and add the location name of all POI to the list
-- To always have a updated value for the current language, I prefer to not save it myself
--]]
function LibWorldEvents.POI.Writhing:generateList()
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
-- To obtain the zone's list where a Writhing world event can happen
--]]
function LibWorldEvents.POI.Writhing:obtainList()
    if self.isGenerated == false then
        self:generateList()
    end

    return self.list
end
