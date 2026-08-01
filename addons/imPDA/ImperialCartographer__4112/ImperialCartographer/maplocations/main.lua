local EVENT_NAMESPACE = 'IMPERIAL_CARTOGRAPHER_MAP_LOCATIONS_MAIN_EVENT_NAMESPACE'

local Log = ImperialCartographer_Logger('IMP_CART_MapLocations')
local MM = ImperialCartographer.MarksManager

--  ---------------------------------------------------------------------------

local MAP_LOCATIONS = {
    -- Cyrodiil, AD side
    [3356] = {
        ["3022411757800006"] = {1, 0.302241, 0.578000, "Merchant", "/esoui/art/icons/servicemappins/servicepin_vendor.dds",             376977.78, 26195, 893377.76},
        ["5600510262252956"] = {2, 0.560051, 0.622530, "Armory Merchants", "/esoui/art/icons/servicemappins/servicepin_armory.dds",     388660.01, 25755, 895395.54},
        ["4880094239434063"] = {3, 0.488009, 0.394341, "Stablemaster", "/esoui/art/icons/servicemappins/servicepin_stable.dds",         385395.56, 25297, 885055.54},
        ["3423569248899024"] = {4, 0.342357, 0.488990, "Smithy", "/esoui/art/icons/servicemappins/servicepin_smithy.dds",               378795.56, 25711, 889344.43},
        ["5309205058712178"] = {5, 0.530921, 0.587122, "Siege Merchant", "/esoui/art/icons/servicemappins/servicepin_woodworking.dds",  387340.00, 25600, 893791.10},
        ["4556912440213820"] = {6, 0.455691, 0.402138, "Victory Tavern", "/esoui/art/icons/servicemappins/servicepin_inn.dds",          383931.12, 25476, 885408.88},
        ["7088421536128684"] = {7, 0.708842, 0.361287, "Bank", "/esoui/art/icons/servicemappins/servicepin_bank.dds",                   395402.23, 24820, 883557.77},
        ["4207248346751016"] = {8, 0.420725, 0.467510, "Armory Station", "/esoui/art/icons/servicemappins/servicepin_buildstation.dds", 382346.67, 25729, 888371.10},
        ["3752636039595898"] = {9, 0.375264, 0.395959, "Scribing Station", "/esoui/art/icons/servicemappins/servicepin_magesguild.dds", 380286.67, 25952, 885128.88}
    },
    [3357] = {
        ["3675151448420974"] = {1, 0.367515, 0.484210, "Armory Merchants", "/esoui/art/icons/servicemappins/servicepin_armory.dds",     599544.44, 24574, 887904.44},
        ["4815841336011230"] = {2, 0.481584, 0.360112, "Siege Merchant", "/esoui/art/icons/servicemappins/servicepin_woodworking.dds",  606495.55, 24323, 880342.22},
        ["5497410837225586"] = {3, 0.549741, 0.372256, "Stablemaster", "/esoui/art/icons/servicemappins/servicepin_stable.dds",         610648.88, 24591, 881082.22},
        -- ["3687914943333819"] = {4, 0.368791, 0.433338, "Whitestrake's Mayhem Celebration", "/esoui/art/icons/servicemappins/servicepin_event.dds", 599622.21, 24408, 884804.44}
    },
    -- Cyrodiil, EP side
    [3358] = {
        ["5719688556512969"] = {1, 0.57196885347366, 0.56512969732285, "Merchant", "/esoui/art/icons/servicemappins/servicepin_vendor.dds",                             930757.78, 40984, 312697.79},
        ["5159002561684894"] = {2, 0.51590025424957, 0.61684894561768, "Smithy", "/esoui/art/icons/servicemappins/servicepin_smithy.dds",                               926804.45, 41296, 316344.46},
        ["5962684162450754"] = {3, 0.59626841545105, 0.62450754642487, "Mystic Emporium", "/esoui/art/icons/servicemappins/servicepin_enchanting.dds",                  932471.12, 41172, 316884.45},
        ["4958555435601499"] = {4, 0.49585554003716, 0.35601499676704, "Warrior's Rest", "/esoui/art/icons/servicemappins/servicepin_inn.dds",                          925391.11, 42144, 297953.34},
        ["6194963439137697"] = {5, 0.61949634552002, 0.39137697219849, "Stablemaster", "/esoui/art/icons/servicemappins/servicepin_stable.dds",                         934108.89, 40697, 300446.68},
        ["5407986633546596"] = {6, 0.54079866409302, 0.33546596765518, "Siege Merchant", "/esoui/art/icons/servicemappins/servicepin_vendor.dds",                       928560.00, 41961, 296504.45},
        ["5559582757181125"] = {7, 0.55595827102661, 0.57181125879288, "Bank", "/esoui/art/icons/servicemappins/servicepin_bank.dds",                                   929628.89, 40984, 313168.90},
        ["4846355057521510"] = {8, 0.48463550209999, 0.57521510124207, "Armory and Scribing Stations", "/esoui/art/icons/servicemappins/servicepin_buildstation.dds",   924600.00, 41160, 313408.90},
    },
    [3359] = {
	    ["3823631451857924"] = {1, 0.38236314058304, 0.51857924461365, "Siege Merchant", "/esoui/art/icons/servicemappins/servicepin_vendor.dds",                       830475.54, 42181, 113126.66},
	    ["5864036063326925"] = {2, 0.58640360832214, 0.63326925039291, "Stablemaster", "/esoui/art/icons/servicemappins/servicepin_stable.dds",                         844862.21, 42368, 121213.33},
	    ["5940937357515203"] = {3, 0.59409373998642, 0.57515203952789, "Merchant House", "/esoui/art/icons/servicemappins/servicepin_armory.dds",                       845404.43, 42428, 117115.55},
        -- ["5266790356812381"] = {4, 0.52667903900146, 0.56812381744385, "Whitestrake's Mayhem Celebration", "/esoui/art/icons/servicemappins/servicepin_event.dds",      840651.10, 41801, 116619.99},

    },
    -- Cyrodiil, DC side
    [3360] = {
        ["4993816648425263"] = {1, 0.499382, 0.484253, "Armory Merchants", "/esoui/art/icons/servicemappins/servicepin_vendor.dds",                     157388.88, 34951, 93486.66},
        ["4304971660248166"] = {2, 0.430497, 0.602482, "Highlands Glory Inn", "/esoui/art/icons/servicemappins/servicepin_inn.dds",                     153675.55, 35264, 99859.99},
        ["6747464558129274"] = {3, 0.674746, 0.581293, "Blacksmith", "/esoui/art/icons/servicemappins/servicepin_smithy.dds",                           166842.21, 34993, 98717.77},
        ["7676642567548847"] = {4, 0.767664, 0.675488, "Alchemist", "/esoui/art/icons/servicemappins/servicepin_alchemy.dds",                           171851.10, 35408, 103795.55},
        ["4878390780060184"] = {5, 0.487839, 0.800602, "Stablemaster", "/esoui/art/icons/servicemappins/servicepin_stable.dds",                         156766.66, 34594, 110539.99},
        ["4441009169787287"] = {6, 0.444101, 0.697873, "Siege Merchant", "/esoui/art/icons/servicemappins/servicepin_vendor.dds",                       154408.88, 34578, 105002.22},
        ["3215433973427325"] = {7, 0.321543, 0.734273, "Enchanter", "/esoui/art/icons/servicemappins/servicepin_enchanting.dds",                        147802.21, 35176, 106964.44},
        ["6607304876461374"] = {8, 0.660730, 0.764614, "Stablemaster", "/esoui/art/icons/servicemappins/servicepin_stable.dds",                         166086.66, 34600, 108599.99},
        ["5303404946170336"] = {9, 0.530340, 0.461703, "Bank", "/esoui/art/icons/servicemappins/servicepin_bank.dds",                                   159057.77, 34992, 92271.11},
        -- ["3713949911027619743"] = {10, 3.713950, 10.276197, "Mercenary Merchant", "/esoui/art/icons/servicemappins/servicepin_vendor.dds", 330675.54, 0, 621337.76},
        ["7036029153392696"] = {11, 0.703603, 0.533927, "Armory and Scribing Stations", "/esoui/art/icons/servicemappins/servicepin_buildstation.dds",  168397.77, 34825, 96164.44}
    },
    [3361] = {
        ["5691593833776548"] = {1, 0.569159, 0.337765, "Merchant House", "/esoui/art/icons/servicemappins/servicepin_armory.dds",                   64675.55, 38334, 277368.88},
        ["8334374451316261"] = {2, 0.833437, 0.513163, "Stablemaster", "/esoui/art/icons/servicemappins/servicepin_stable.dds",                     77837.78, 37973, 286104.44},
        ["6767356957933247"] = {3, 0.676736, 0.579332, "Siege Merchant", "/esoui/art/icons/servicemappins/servicepin_vendor.dds",                   70033.33, 37975, 289399.99},
        -- ["5812065045502409"] = {4, 0.581207, 0.455024, "Whitestrake's Mayhem Celebration", "/esoui/art/icons/servicemappins/servicepin_event.dds",  65275.55, 38443, 283208.88}
    }
}

-- ----------------------------------------------------------------------------

local MARK_TYPE_MAP_LOCATION

local _zoneId, _subzoneId
local function update()
    Log('Update called, _zoneId: %d, _subzoneId: %d', _zoneId, _subzoneId)

    if not _zoneId or _zoneId == 0 then return end
    if not _subzoneId or _subzoneId == 0 then return end

    local mapLocations = MAP_LOCATIONS[_subzoneId]
    if not mapLocations then return end

    for _, location in pairs(mapLocations) do
        -- local index = location[1]
        -- local nX, nZ = location[2], location[3]
        local name = location[4]
        local texture = location[5]

        local rwX, rwY, rwZ = location[6], location[7], location[8]
        MM:AddMark(MARK_TYPE_MAP_LOCATION, name, {rwX, rwY, rwZ}, texture, 36)

        -- local unknownY = rwY == 0

        -- local mark = MM:AddMark(MARK_TYPE_MAP_LOCATION, nil, {rwX, rwY, rwZ}, texture, 36)
        -- MM:SetTag(mark, ('[%d] %s'):format(markIndex, name))

        -- if unknownY then
        --     mark:AddSystem(LibImplex.Systems.KeepOnPlayersHeight)
        -- end
    end
end

-- weird, but zoneId can be 0
local function onZoneChanged(_, zoneName, subZoneName, newSubzone, zoneId, subZoneId)
    if not IMP_GetCurrentSubzoneId then
        Log('IMP_GetCurrentSubzoneId not loaded yet, but subzone ID: %d', subZoneId)
    end
    Log('EVENT_ZONE_CHANGED: %s, %s', tostring(zoneId), tostring(subZoneId))

    _zoneId = GetZoneId(GetUnitZoneIndex('player'))
    _subzoneId = IMP_GetCurrentSubzoneId()

    Log('Zone changed: %d, %d', _zoneId, _subzoneId)

    MM:UpdateMarks(MARK_TYPE_MAP_LOCATION)
end

assert(ImperialCartographer, 'ImperaialCartographer main.lua is not initialized')
ImperialCartographer.MapLocations = {
    Initialize = function(self, parent)
        local fontSize = ImperialCartographer.sv.defaultPois.fontSize
        MARK_TYPE_MAP_LOCATION = MM:AddMarkType(update, true, true, function(self_) return MM:GetMarkTag(self_) end, fontSize)

        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ZONE_CHANGED, onZoneChanged)
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, onZoneChanged)
    end
}

-- ----------------------------------------------------------------------------

--[[
local P = 100000000
local function hashPosition(x, z)
    return ('%08d%08d'):format(x * P, z * P)
end

function IMP_ImperialCartographer_GetMapLocations()
    local locations = {}
    local strings = {}

    ImperialCartographer.Calculations.ClearCalibrations()
    local calibration = {ImperialCartographer.Coordinates.GetCalibration(_zoneId)}

    for i = 1, GetNumMapLocations() do
        local header = GetMapLocationTooltipHeader(i)
        local icon, nX, nZ = GetMapLocationIcon(i)
        local rwX, rwZ = ImperialCartographer.Coordinates.ConvertNormalizedToWorld(nX, nZ, calibration)
        local hash = hashPosition(nX, nZ)
        locations[hash] = {i, nX, nZ, header, icon, zo_roundToZero(rwX, 0.01), 0, zo_roundToZero(rwZ, 0.01)}
        strings[#strings+1] = ('["%s"] = {%d, %f, %f, "%s", "%s", %.2f, %d, %.2f}'):format(hash, i, nX, nZ, header, icon, zo_roundToZero(rwX, 0.01), 0, zo_roundToZero(rwZ, 0.01))
    end

    -- d(table.concat(strings, ',\n'))
    return locations
end
--]]
