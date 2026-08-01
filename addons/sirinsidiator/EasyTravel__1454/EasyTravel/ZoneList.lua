local ET = EasyTravel
local internal = ET.internal

local RegisterForEvent = internal.RegisterForEvent
local UnregisterForEvent = internal.UnregisterForEvent

local ZoneList = ZO_InitializingObject:Subclass()
ET.class.ZoneList = ZoneList

function ZoneList:Initialize()
    self.zoneById = {}
    self.zoneByIndex = {}
    self.zoneByName = {}
    self.zoneAutocompleteList = {}

    self.houseByName = {}
    self.houseAutocompleteList = {}

    -- CanJumpToPlayerInZone currently doesn't return the correct results, but should hopefully work in a future update
    --    local zoneIndex = 1
    --    while true do
    --        local zoneName = GetZoneNameByIndex(zoneIndex)
    --        if(zoneName == "") then break end
    --
    --        local zoneId = GetZoneId(zoneIndex)
    --        local canJump, result = CanJumpToPlayerInZone(zoneId)
    --        if(canJump) then
    --            zoneName = zo_strformat("<<1>>", GetZoneNameByIndex(zoneIndex))
    --            self:AddEntry(zoneId, zoneIndex, zoneName)
    --        end
    --        zoneIndex = zoneIndex + 1
    --    end

    -- for now we have to put the zoneIds in a list
    local zoneIds = {
        3, -- Glenumbra
        19, -- Stormhaven
        20, -- Rivenspire
        41, -- Stonefalls
        57, -- Deshaan
        58, -- Malabal Tor
        92, -- Bangkorai
        101, -- Eastmarch
        103, -- The Rift
        104, -- Alik'r Desert
        108, -- Greenshade
        117, -- Shadowfen
        280, -- Bleakrock Isle
        281, -- Bal Foyen
        347, -- Coldharbour
        381, -- Auridon
        382, -- Reaper's March
        383, -- Grahtwood
        534, -- Stros M'Kai
        535, -- Betnikh
        537, -- Khenarthi's Roost
        684, -- Wrothgar
        726, -- Murkmire
        816, -- Hew's Bane
        823, -- The Gold Coast
        849, -- Vvardenfell
        888, -- Craglorn
        980, -- The Clockwork City
        981, -- The Brass Fortress
        1011, -- Summerset
        1027, -- Artaeum
        1086, -- Northern Elsweyr
        1133, -- Southern Elsweyr
        1146, -- Tideholm
        1160, -- Western Skyrim
        1161, -- Blackreach: Greymoor Caverns
        1207, -- The Reach
        1208, -- Blackreach: Arkthzand Cavern
        1261, -- Blackwood
        1282, -- Fargrave City District
        1283, -- The Shambles
        1286, -- The Deadlands
        1318, -- High Isle and Amenos
        1383, -- Galen and Y'ffelon
        1413, -- Apocrypha
        1414, -- Telvanni Peninsula
        1443, -- West Weald,
        1502, -- Solstice,
    }

    -- some maplist entries have more than one jump target
    local subTargets = {
        [31] = { -- Clockwork City
            { id = 981 }, -- The Brass Fortress
            { id = 980 }, -- The Clockwork City
        },
        [36] = { -- Southern Elsweyr
            { id = 1133 }, -- Southern Elsweyr
            { id = 1146 }, -- Tideholm
        },
        [43] = { -- Fargrave
            { id = 1282 }, -- Fargrave City District
            { id = 1283 }, -- The Shambles
        },
    }

    if IsAdventureZoneActive() then
        zoneIds[#zoneIds + 1] = 1559 -- Night Market
        local fargraveSubTargets = subTargets[43]
        fargraveSubTargets[#fargraveSubTargets + 1] = { id = 1559 }
    end

    for i = 1, #zoneIds do
        local zoneId = zoneIds[i]
        local zoneIndex = GetZoneIndex(zoneId)
        local zoneName = zo_strformat("<<1>>", GetZoneNameByIndex(zoneIndex))
        self:AddEntry(zoneId, zoneIndex, zoneName)
    end

    for mapIndex, targets in pairs(subTargets) do
        for i = 1, #targets do
            targets[i].data = self:GetZoneByZoneId(targets[i].id)
        end
    end
    self.subTargets = subTargets

    WORLD_MAP_HOUSES_DATA:RefreshHouseList()
    local houses = WORLD_MAP_HOUSES_DATA:GetHouseList()
    for i = 1, #houses do
        local house = houses[i]
        local name = house.houseName
        self.houseByName[name] = house
        self.houseAutocompleteList[zo_strlower(name)] = name
    end
end

function ZoneList:AddEntry(zoneId, zoneIndex, zoneName)
    local zoneData = {
        id = zoneId,
        index = zoneIndex,
        name = zoneName
    }
    self.zoneById[zoneId] = zoneData
    self.zoneByIndex[zoneIndex] = zoneData
    self.zoneByName[zoneName] = zoneData
    self.zoneAutocompleteList[zo_strlower(zoneData.name)] = zoneData.name
end

function ZoneList:SetMapByIndex(mapIndex)
    ZO_WorldMap_SetMapByIndex(mapIndex)
    return self.zoneByIndex[GetCurrentMapZoneIndex()]
end

function ZoneList:GetSubTargets(mapIndex)
    return self.subTargets[mapIndex]
end

function ZoneList:GetCurrentZone()
    SetMapToPlayerLocation()
    while not(GetMapType() == MAPTYPE_ZONE and GetMapContentType() ~= MAP_CONTENT_DUNGEON) do
        if (MapZoomOut() ~= SET_MAP_RESULT_MAP_CHANGED) then break end
    end
    local currentIndex = GetCurrentMapZoneIndex()
    return self.zoneByIndex[currentIndex]
end

function ZoneList:GetZoneByZoneIndex(zoneIndex)
    return self.zoneByIndex[zoneIndex]
end

function ZoneList:GetZoneByZoneId(zoneId)
    return self.zoneById[zoneId]
end

function ZoneList:GetZoneByZoneName(zoneName)
    return self.zoneByName[zo_strformat("<<1>>", zoneName)]
end

function ZoneList:GetZoneForGroupMember(unitTag)
    local zoneIndex = GetUnitZoneIndex(unitTag)
    if(zoneIndex) then
        local zoneId = GetZoneId(zoneIndex)
        return {
            id = zoneId,
            index = zoneIndex,
            name = GetUnitZone(unitTag)
        }
    end
end

function ZoneList:HasZone(zoneName)
    return self.zoneByName[zo_strformat("<<1>>", zoneName)] ~= nil
end

function ZoneList:GetZoneList()
    return self.zoneByName
end

function ZoneList:GetZoneFromPartialName(partialZone)
    local results = GetTopMatchesByLevenshteinSubStringScore(self.zoneAutocompleteList, partialZone, 1, 1)
    if(#results == 0) then return end
    return self.zoneByName[results[1]]
end

function ZoneList:GetHouseByName(houseName)
    return self.houseByName[zo_strformat("<<1>>", houseName)]
end

function ZoneList:HasHouse(houseName)
    return self.houseByName[zo_strformat("<<1>>", houseName)] ~= nil
end

function ZoneList:GetHouseList()
    return self.houseByName
end

function ZoneList:GetHouseFromPartialName(partialHouseName)
    local results = GetTopMatchesByLevenshteinSubStringScore(self.houseAutocompleteList, partialHouseName, 1, 1)
    if(#results == 0) then return end
    return self.houseByName[results[1]]
end
