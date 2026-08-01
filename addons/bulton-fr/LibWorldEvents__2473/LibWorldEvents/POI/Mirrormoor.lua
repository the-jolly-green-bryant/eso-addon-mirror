LibWorldEvents.POI.Mirrormoor = {}

-- @var bool onMap To know if the user is on a map where Mirrormoor world event can happen
LibWorldEvents.POI.Mirrormoor.onMap = false

-- @var bool isGenerated To know if the list has been generated or not
LibWorldEvents.POI.Mirrormoor.isGenerated = false

-- @var table List of all zone with Mirrormoor world events
LibWorldEvents.POI.Mirrormoor.list = {
    { -- West Weald
        zoneId  = 1443,
        mapName = "westweald/westwealdoverland_base",
        list    = {
            title = {
                cp = {
                    [1] = GetString(SI_LIB_WORLD_EVENTS_CP_NORTH),
                    [2] = GetString(SI_LIB_WORLD_EVENTS_CP_EAST),
                    [3] = GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH),
                    [4] = GetString(SI_LIB_WORLD_EVENTS_CP_WEST),
                },
                ln = {} --generated in generateList()
            },
            poiIDs = {
                [1] = 2783, --Colovie   
                [2] = 2784, --Silorn
                [3] = 2780, --Ostumir
                [4] = 2782, --Sutch
            },
        },
    }
}

--[[
-- Obtain and add the location name of all POI to the list
-- To always have a updated value for the current language, I prefer to not save it myself
--]]
function LibWorldEvents.POI.Mirrormoor:generateList()
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
-- To obtain the zone's list where a Mirrormoor world event can happen
--]]
function LibWorldEvents.POI.Mirrormoor:obtainList()
    if self.isGenerated == false then
        self:generateList()
    end

    return self.list
end
