DragonNextLocation.Zone = {}

-- @var table All possition position for each dragons in Elsweyr zones
DragonNextLocation.Zone.positionList = {
    [1086] = { -- North Elsweyr
        dragons = {
            [1] = { -- South
                [1] = {0.5558, 0.5507},
                [2] = {0.5835, 0.5258},
                [3] = {0.5176, 0.5508},
                [4] = {0.5441, 0.5889},
                [5] = {0.5265, 0.6118}
            },
            [2] = { -- North
                [6] = {0.4667, 0.3279},
                [7] = {0.4355, 0.2716},
                [8] = {0.4237, 0.3131},
                [9] = {0.4416, 0.3812},
            },
            [3] = { -- West
                [10] = {0.2712, 0.6111},
                [11] = {0.2985, 0.5784},
                [12] = {0.3134, 0.6281},
                [13] = {0.2572, 0.6403},
            }
        }
    },
    [1133] = { -- South Elsweyr
        dragons = {
            [12] = { -- North
                [22] = {0.4345, 0.3343},
                [23] = {0.3252, 0.3894},
                [24] = {0.3067, 0.2914},
                [28] = {0.3702, 0.3206},
            },
            [13] = { -- South
                [25] = {0.5042, 0.6478},
                [26] = {0.6001, 0.5716},
                [27] = {0.6507, 0.5914},
                [29] = {0.5734, 0.6105},
            }
        }
    }
}

--[[
-- To transform a dragon and locationId to a x/y normalized position.
--
-- @param Dragon dragon The dragon intance concerned by the locationId
-- @param number locationId The locationId
--
-- @return nil|table
--]]
function DragonNextLocation.Zone:obtainPosition(dragon, locationId)
    local currentZoneId = LibWorldEvents.Zone.info.zoneId
    local WEInstanceId  = dragon.WEInstanceId

    return self.positionList[currentZoneId].dragons[WEInstanceId][locationId]
end
