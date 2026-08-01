LibWorldEvents.Dragons.ZoneInfo = {}

-- @var bool onMap To know if the user is on a map where dragons world event can happen
LibWorldEvents.Dragons.ZoneInfo.onMap = false

-- @var number repopTime The repop time of dragons
-- Need to see a kill/repop to get the value
LibWorldEvents.Dragons.ZoneInfo.repopTime = 0

-- @var table List of all zone with dragons world events
LibWorldEvents.Dragons.ZoneInfo.list = {
    { -- North Elsweyr
        zoneId  = 1086,
        mapName = "elsweyr/elsweyr_base",
        list    = {
            title = {
                cp = {
                    [1] = GetString(SI_LIB_WORLD_EVENTS_CP_NORTH),
                    [2] = GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH_EAST),
                    [3] = GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH_WEST)
                },
                ln = {
                    [1] = GetString(SI_LIB_WORLD_EVENTS_LN_PROWLS_EDGE),
                    [2] = GetString(SI_LIB_WORLD_EVENTS_LN_SANDBLOWN),
                    [3] = GetString(SI_LIB_WORLD_EVENTS_LN_SCAB_RIDGE)
                }
            },
            WEInstanceId = {
                [1] = 2,
                [2] = 1,
                [3] = 3,
            },
        },
    },
    { -- South Elsweyr
        zoneId  = 1133,
        mapName = "southernelsweyr/southernelsweyr_base",
        list    = {
            title = {
                cp = {
                    [1] = GetString(SI_LIB_WORLD_EVENTS_CP_NORTH),
                    [2] = GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH)
                },
                ln = {
                    --Not an copy/paste error, the in game name are really north/south
                    [1] = GetString(SI_LIB_WORLD_EVENTS_CP_NORTH),
                    [2] = GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH)
                },
            },
            WEInstanceId = {
                [1] = 12,
                [2] = 13,
            },
        },
    }
}

--[[
-- To obtain the zone's list where a dragon world event can happen
--]]
function LibWorldEvents.Dragons.ZoneInfo:obtainList()
    return self.list
end
