local imperialData = {
    [1] = {
        x = 0.73,
        y = 0.43,
        label = "arena",
        size = 128,
        path = "PvDoor/Icons/arena.dds"
    },
    [2] = {
        x = 0.5,
        y = 0.32,
        label = "memorial",
        size = 192,
        path = "PvDoor/Icons/memorial.dds"
    },
    [3] = {
        x = 0.504,
        y = 0.775,
        label = "temple",
        size = 140,
        path = "PvDoor/Icons/temple.dds"
    },
    [4] = {
        x = 0.27,
        y = 0.45,
        label = "elven",
        size = 180,
        path = "PvDoor/Icons/elven.dds"
    },
    [5] = {
        x = 0.265,
        y = 0.63,
        label = "nobles",
        size = 148,
        path = "PvDoor/Icons/nobles.dds"
    },
    [6] = {
        x = 0.73,
        y = 0.63,
        label = "arboretum",
        size = 140,
        path = "PvDoor/Icons/arbor.dds"
    },
    [7] = { -- left
        x = 0.1605,
        y = 0.48,
        label = "dc_sewer",
        size = 140,
        path = "PvDoor/Icons/dc.dds"
    },
    [8] = { -- bottom
        x = 0.4895,
        y = 0.865,
        label = "ad_sewer",
        size = 140,
        path = "PvDoor/Icons/ad.dds"
    },
    [9] = { -- upper right
        x = 0.8238,
        y = 0.295,
        label = "ep_sewer",
        size = 140,
        path = "PvDoor/Icons/ep.dds"
    }
}

local doorsData = {

    ["cyrodiil"] = {
        ["ava_whole"] = {
            [1] = {
                [1] = 0.8455044627,
                [2] = 0.3380022347,
                [3] = 0.5320097208
            },
            [2] = {
                [1] = 0.7024089098,
                [2] = 0.3124800026,
                [3] = 3.0897350311
            },
            [3] = {
                [1] = 0.7224110961,
                [2] = 0.1905666739,
                [3] = 5.8178100586
            },
            [4] = {
                [1] = 0.7673510909,
                [2] = 0.5829333067,
                [3] = 5.4115839005
            },
            [5] = {
                [1] = 0.2352599949,
                [2] = 0.5677355528,
                [3] = 3.2988455296
            },
            [6] = {
                [1] = 0.4123266637,
                [2] = 0.5631800294,
                [3] = 0.6109078526
            },
            [7] = {
                [1] = 0.5709666610,
                [2] = 0.5568000078,
                [3] = 5.6897263527
            },
            [8] = {
                [1] = 0.4995822310,
                [2] = 0.6752133369,
                [3] = 5.4803380966
            },
            [9] = {
                [1] = 0.4077133238,
                [2] = 0.7657377720,
                [3] = 6.2657361031
            },
            [10] = {
                [1] = 0.5747689009,
                [2] = 0.7611644268,
                [3] = 6.2308382988
            },
            [11] = {
                [1] = 0.3394133449,
                [2] = 0.4276199937,
                [3] = 0.8433250189
            },
            [12] = {
                [1] = 0.4910866618,
                [2] = 0.1185777783,
                [3] = 2.8798570633
            },
            [13] = {
                [1] = 0.2742666602,
                [2] = 0.2849222124,
                [3] = 3.0892455578
            },
            [14] = {
                [1] = 0.1851488948,
                [2] = 0.3273977637,
                [3] = -1.9197771549
            },
            [15] = {
                [1] = 0.2315355539,
                [2] = 0.1645911038,
                [3] = 0.0523470938
            },
            [16] = {
                [1] = 0.4056800008,
                [2] = 0.2840755582,
                [3] = 2.7051751614
            },
            [17] = {
                [1] = 0.5807555318,
                [2] = 0.2886866629,
                [3] = 6.2421379089
            },
            [18] = {
                [1] = 0.6529822350,
                [2] = 0.4291044474,
                [3] = 2.4526646137
            }
        }
    }
}

function PvDoors_GetLocalData(zone, subzone)
    if type(zone) == "string" and type(subzone) == "string" and doorsData[zone] and doorsData[zone][subzone] then
        return doorsData[zone][subzone]
    end
end

function PvDoors_SetLocalData(manifest, zone, subzone, data)
    if type(zone) == "string" and type(subzone) == "string" and type(data) == "table" then
        manifest[zone] = manifest[zone] or {}
        manifest[zone][subzone] = manifest[zone][subzone] or {}
        table.insert(manifest[zone][subzone], data)
    end

    return manifest
end

function PvDoors_GetImperialData()
    return imperialData
end