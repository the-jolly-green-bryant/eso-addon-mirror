CitizenMarker = {
    name = "CitizenMarker",
    placedIcons = {},
    clearLock = false,
    mechanicIcons = {},
    savedPositions = {}
}

--Place icon
local function PlaceIcon(zoneId, x, y, z, icon)
    local size = CitizenAddon.generalOptions.marker.OsiIconSize
    table.insert(CitizenMarker.placedIcons[zoneId], OSI.CreatePositionIcon(x, y, z, icon, size, nil, -0.3, nil))
end

--Create Confirg String
local function CreateConfigString()
    local zoneId, _, _, _ = GetUnitRawWorldPosition('player')
    local configString = ""
    if CitizenMarker.savedPositions[zoneId] then
        for _, iconInfo in pairs(CitizenMarker.savedPositions[zoneId]) do
            configString = configString .."/".. zoneId .."//".. iconInfo[1] ..",".. iconInfo[2] ..",".. iconInfo[3] ..",".. iconInfo[4] .."/"
        end
    end
    CitizenAddon.generalOptions.marker.configString = configString
end
--Import Config String
function CitizenMarker.ImportConfigString()
    for zoneId, x, y, z, icon in string.gmatch(CitizenAddon.generalOptions.marker.configString, "/(%d+)//(%d+),(%d+),(%d+),(%d+)/") do
        zoneId = tonumber(zoneId)
        x = tonumber(x)
        y = tonumber(y)
        z = tonumber(z)
        icon = tonumber(icon)
        if not CitizenMarker.savedPositions[zoneId] then
            CitizenMarker.savedPositions[zoneId] = {}
        end
        table.insert(CitizenMarker.savedPositions[zoneId], {x, y, z, icon})
    end
    CitizenMarker.PlayerActivated()
end

--Place saved icons in the zone
local function PlaceZoneIcons(positions, zoneId)
    if not CitizenMarker.placedIcons[zoneId] then
        CitizenMarker.placedIcons[zoneId] = {}
    end
    for _, iconInfo in pairs(positions) do
        if iconInfo then
            PlaceIcon(zoneId, iconInfo[1], iconInfo[2], iconInfo[3], CitizenMarker.iconData[iconInfo[4]])
        end
    end
end
--Remove zone icons
local function RemoveZoneIcons(zoneId)
    if CitizenMarker.placedIcons[zoneId] then
        for _, IconObject in pairs(CitizenMarker.placedIcons[zoneId]) do
            OSI.DiscardPositionIcon(IconObject)
        end
    end
    CitizenFunctions.RemoveKey(CitizenMarker.placedIcons, zoneId)
end

--Place icon at player position
function CitizenMarker.PlaceAtMe()
    local zoneId, x, y, z = GetUnitRawWorldPosition('player')

    d("|cffffff[CITI]|r Placed selected marker at |cffffffzoneID|r:".. zoneId ..", |cffffffx|r:".. x ..", |cffffffy|r:".. y ..", |cffffffz|r:".. z)

    if not CitizenMarker.savedPositions[zoneId] then
        CitizenMarker.savedPositions[zoneId] = {
            [1] = {x, y, z, CitizenAddon.generalOptions.marker.selectedIconTexture}
        }
    else
        table.insert(CitizenMarker.savedPositions[zoneId], {x, y, z, CitizenAddon.generalOptions.marker.selectedIconTexture})
    end
    if not CitizenMarker.placedIcons[zoneId] then
        CitizenMarker.placedIcons[zoneId] = {}
    end

    PlaceIcon(zoneId, x, y, z, CitizenMarker.iconData[CitizenAddon.generalOptions.marker.selectedIconTexture])
    CreateConfigString()

    return {x, y, z}
end

--Remove nearest marker
function CitizenMarker.RemoveNearestMarker()
    local zoneId, x, y, z = GetUnitRawWorldPosition('player')

    d("|cffffff[CITI]|r Removed the nearest marker at |cffffffzoneID|r:".. zoneId ..", |cffffffx|r:".. x ..", |cffffffy|r:".. y ..", |cffffffz|r:".. z)

    local zonePositions = CitizenMarker.placedIcons[zoneId]

    if not zonePositions then
        return
    end
    local closestMarker
    local closestMarkerIndex
    local shortestDistance = 9999
    local currentDistance

    for index, icon in pairs(zonePositions) do
        currentDistance = (zo_sqrt((icon.x - x) ^ 2 + (icon.z - z) ^ 2) / 100)
        if currentDistance < shortestDistance then
            shortestDistance = currentDistance
            closestMarker = icon
            closestMarkerIndex = index
        end
    end
    if closestMarker then
        OSI.DiscardPositionIcon(closestMarker)
        CitizenMarker.placedIcons[zoneId][closestMarkerIndex] = nil

        for zone, iconInfo in pairs(CitizenMarker.savedPositions[zoneId]) do
            if iconInfo[1]==closestMarker.x and iconInfo[2]==closestMarker.y and iconInfo[3]==closestMarker.z then
                closestMarkerIndex = zone
            end
        end
        CitizenFunctions.RemoveKey(CitizenMarker.savedPositions[zoneId], closestMarkerIndex)
    end

    local next = next
    if next(CitizenMarker.savedPositions[zoneId]) == nil then
        CitizenFunctions.RemoveKey(CitizenMarker.savedPositions, zoneId)
    end

    CreateConfigString()
end

--Clear all marks in the zone
function CitizenMarker.ClearZone()
    local zoneId, _, _, _ = GetUnitRawWorldPosition('player')

    d("|cffffff[CITI]|r All marks in zone |cffffffID|r:".. zoneId .." removed")

    for _, icon in pairs(CitizenMarker.placedIcons[zoneId]) do
        OSI.DiscardPositionIcon(icon)
    end

    CitizenFunctions.RemoveKey(CitizenMarker.placedIcons, zoneId)
    CitizenFunctions.RemoveKey(CitizenMarker.savedPositions, zoneId)
    CreateConfigString()
end

--Played Activated, check zone icon positions
function CitizenMarker.PlayerActivated()
    local zoneId, _, _, _ = GetUnitRawWorldPosition('player')

    for zone, _ in pairs(CitizenMarker.placedIcons) do
        RemoveZoneIcons(zone)
    end
    if CitizenMarker.savedPositions[zoneId] then
        PlaceZoneIcons(CitizenMarker.savedPositions[zoneId], zoneId)
    end
    CreateConfigString()
end


----------------------
--Icon's Data Tables--
----------------------
CitizenMarker.iconData = {
    [1]  = "CitizenAddon/Textures/1.dds",
    [2]  = "CitizenAddon/Textures/2.dds",
    [3]  = "CitizenAddon/Textures/3.dds",
    [4]  = "CitizenAddon/Textures/4.dds",
    [5]  = "CitizenAddon/Textures/5.dds",
    [6]  = "CitizenAddon/Textures/6.dds",
    [7]  = "CitizenAddon/Textures/7.dds",
    [8]  = "CitizenAddon/Textures/8.dds",
    [9]  = "CitizenAddon/Textures/9.dds",
    [10] = "CitizenAddon/Textures/10.dds",
    [11] = "CitizenAddon/Textures/11.dds",
    [12] = "CitizenAddon/Textures/12.dds",
    [13] = "OdySupportIcons/icons/arrow.dds",
    [14] = "OdySupportIcons/icons/squares/marker_lightblue.dds",
    [15] = "OdySupportIcons/icons/squares/square_blue.dds",
    [16] = "OdySupportIcons/icons/squares/square_green.dds",
    [17] = "OdySupportIcons/icons/squares/square_orange.dds",
    [18] = "OdySupportIcons/icons/squares/square_orange_OT.dds",
    [19] = "OdySupportIcons/icons/squares/square_pink.dds",
    [20] = "OdySupportIcons/icons/squares/square_red.dds",
    [21] = "OdySupportIcons/icons/squares/square_red_MT.dds",
    [22] = "OdySupportIcons/icons/squares/square_yellow.dds",
    [23] = "OdySupportIcons/icons/squares/squaretwo_blue.dds",
    [24] = "OdySupportIcons/icons/squares/squaretwo_blue_one.dds",
    [25] = "OdySupportIcons/icons/squares/squaretwo_blue_two.dds",
    [26] = "OdySupportIcons/icons/squares/squaretwo_blue_three.dds",
    [27] = "OdySupportIcons/icons/squares/squaretwo_blue_four.dds",
    [28] = "OdySupportIcons/icons/squares/squaretwo_green.dds",
    [29] = "OdySupportIcons/icons/squares/squaretwo_green_one.dds",
    [30] = "OdySupportIcons/icons/squares/squaretwo_green_two.dds",
    [31] = "OdySupportIcons/icons/squares/squaretwo_green_three.dds",
    [32] = "OdySupportIcons/icons/squares/squaretwo_green_four.dds",
    [33] = "OdySupportIcons/icons/squares/squaretwo_orange.dds",
    [34] = "OdySupportIcons/icons/squares/squaretwo_orange_one.dds",
    [35] = "OdySupportIcons/icons/squares/squaretwo_orange_two.dds",
    [36] = "OdySupportIcons/icons/squares/squaretwo_orange_three.dds",
    [37] = "OdySupportIcons/icons/squares/squaretwo_orange_four.dds",
    [38] = "OdySupportIcons/icons/squares/squaretwo_pink.dds",
    [39] = "OdySupportIcons/icons/squares/squaretwo_red.dds",
    [40] = "OdySupportIcons/icons/squares/squaretwo_red_one.dds",
    [41] = "OdySupportIcons/icons/squares/squaretwo_red_two.dds",
    [42] = "OdySupportIcons/icons/squares/squaretwo_red_three.dds",
    [43] = "OdySupportIcons/icons/squares/squaretwo_red_four.dds",
    [44] = "OdySupportIcons/icons/squares/squaretwo_yellow.dds",
    [45] = "CitizenAddon/Textures/a.dds",
    [46] = "CitizenAddon/Textures/b.dds",
    [47] = "CitizenAddon/Textures/c.dds",
    [48] = "CitizenAddon/Textures/d.dds",
    [49] = "CitizenAddon/Textures/e.dds",
    [50] = "CitizenAddon/Textures/f.dds",
    [51] = "CitizenAddon/Textures/g.dds",
    [52] = "CitizenAddon/Textures/h.dds",
    [53] = "CitizenAddon/Textures/i.dds",
    [54] = "CitizenAddon/Textures/j.dds",
    [55] = "CitizenAddon/Textures/k.dds",
    [56] = "CitizenAddon/Textures/l.dds",
    [57] = "CitizenAddon/Textures/m.dds",
    [58] = "CitizenAddon/Textures/n.dds",
    [59] = "CitizenAddon/Textures/o.dds",
    [60] = "CitizenAddon/Textures/p.dds",
    [61] = "CitizenAddon/Textures/q.dds",
    [62] = "CitizenAddon/Textures/r.dds",
    [63] = "CitizenAddon/Textures/s.dds",
    [64] = "CitizenAddon/Textures/t.dds",
    [65] = "CitizenAddon/Textures/u.dds",
    [66] = "CitizenAddon/Textures/v.dds",
    [67] = "CitizenAddon/Textures/w.dds",
    [68] = "CitizenAddon/Textures/x.dds",
    [69] = "CitizenAddon/Textures/y.dds",
    [70] = "CitizenAddon/Textures/z.dds",
    -------------
    --Citizen's--
    -------------
    [71] = "CitizenAddon/Textures/x_mark.dds",
    [72] = "OdySupportIcons/icons/cross.dds",
    [73] = "OdySupportIcons/icons/lightning-bolt.dds",
    [74] = "OdySupportIcons/icons/green_arrow.dds",
    [75] = "CitizenAddon/Textures/yellow_arrow.dds",
    [76] = "OdySupportIcons/icons/squares/squaretwo_green_five.dds",
    [77] = "OdySupportIcons/icons/squares/squaretwo_green_six.dds",
    [78] = "CitizenAddon/Textures/squaretwo_green7.dds",
    [79] = "CitizenAddon/Textures/squaretwo_green8.dds",
    [80] = "CitizenAddon/Textures/squaretwo_green9.dds",
    [81] = "CitizenAddon/Textures/squaretwo_green10.dds",
    [82] = "CitizenAddon/Textures/squaretwo_green11.dds",
    [83] = "CitizenAddon/Textures/squaretwo_green12.dds",
    [84] = "CitizenAddon/Textures/squaretwo_yellow1.dds",
    [85] = "CitizenAddon/Textures/squaretwo_yellow2.dds",
    [86] = "CitizenAddon/Textures/squaretwo_yellow3.dds",
    [87] = "CitizenAddon/Textures/squaretwo_yellow4.dds",
    [88] = "CitizenAddon/Textures/squaretwo_yellow5.dds",
    [89] = "CitizenAddon/Textures/squaretwo_yellow6.dds",
    [90] = "CitizenAddon/Textures/squaretwo_yellow7.dds",
    [91] = "CitizenAddon/Textures/squaretwo_yellow8.dds",
    [92] = "CitizenAddon/Textures/squaretwo_yellow9.dds",
    [93] = "CitizenAddon/Textures/squaretwo_yellow10.dds",
    [94] = "CitizenAddon/Textures/squaretwo_yellow11.dds",
    [95] = "CitizenAddon/Textures/squaretwo_yellow12.dds",
    [96] = "CitizenAddon/Textures/squaretwo_purple1.dds",
    [97] = "CitizenAddon/Textures/squaretwo_purple2.dds",
    [98] = "CitizenAddon/Textures/squaretwo_purple3.dds",
    [99] = "CitizenAddon/Textures/squaretwo_purple4.dds",
    [100] = "CitizenAddon/Textures/squaretwo_purple5.dds",
    [101] = "CitizenAddon/Textures/squaretwo_purple6.dds",
    [102] = "CitizenAddon/Textures/squaretwo_purple7.dds",
    [103] = "CitizenAddon/Textures/squaretwo_purple8.dds",
    [104] = "CitizenAddon/Textures/squaretwo_purple9.dds",
    [105] = "CitizenAddon/Textures/squaretwo_purple10.dds",
    [106] = "CitizenAddon/Textures/squaretwo_purple11.dds",
    [107] = "CitizenAddon/Textures/squaretwo_purple12.dds",
    [108] = "OdySupportIcons/icons/squares/squaretwo_red_five.dds",
    [109] = "OdySupportIcons/icons/squares/squaretwo_red_six.dds",
    [110] = "OdySupportIcons/icons/squares/squaretwo_red_seven.dds",
    [111] = "OdySupportIcons/icons/squares/squaretwo_red_eight.dds",
    [112] = "CitizenAddon/Textures/squaretwo_red9.dds",
    [113] = "CitizenAddon/Textures/bat_white_glow.dds",
    [114] = "CitizenAddon/Textures/cartoklept_map_damaged_glow.dds",
    [115] = "CitizenAddon/Textures/cartoklept_map_glow.dds",
    [116] = "CitizenAddon/Textures/crocodile_white_glow.dds",
    [117] = "CitizenAddon/Textures/buildicon_44_white_glow.dds",
    [118] = "CitizenAddon/Textures/hoarvor_white_glow.dds",
    [119] = "CitizenAddon/Textures/pet_hajmota_slateback_glow.dds",
    [120] = "CitizenAddon/Textures/pet_spidermephala_white_glow.dds",
    [121] = "CitizenAddon/Textures/pet_wamasuhatchling_glow.dds",
}
CitizenMarker.reverseIconData = {}
for k, v in ipairs(CitizenMarker.iconData) do
    CitizenMarker.reverseIconData[v]=k
end
