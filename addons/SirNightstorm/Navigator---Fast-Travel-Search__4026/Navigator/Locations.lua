local Nav = Navigator

--- @class Locations
local Locs = Nav.Locations or {
    nodes = nil,
    nodeMap = nil,
    zones = nil,
    mapIndices = nil,
    harborageIndex = nil,
    keepsDirty = false
}
local Utils = Nav.Utils

function Locs:IsZone(zoneId)
    if zoneId == GetParentZoneId(zoneId)
    or zoneId==267 -- Eyevea
    or zoneId==981 -- The Brass Fortress
    or zoneId==1027 -- Artaeum
    or zoneId==1413 -- Apocrypha
    or zoneId==1463 -- The Scholarium
    or zoneId==Nav.ZONE_ATOLLOFIMMOLATION
    or zoneId==Nav.ZONE_IMPERIALSEWERS
    or zoneId==Nav.ZONE_INFINITE_ARCHIVE
    then
        return true
    end
    return false
end

function Locs:ShouldCollapseCategories(zoneId)
    return zoneId <= 2 or (zoneId == Nav.ZONE_CYRODIIL and Nav.jumpState ~= Nav.JUMPSTATE_WAYSHRINE) or zoneId == Nav.ZONE_IMPERIALCITY or zoneId == Nav.ZONE_IMPERIALSEWERS
end

local function createNode(self, i, name, typePOI, icon, glowIcon, known, zone, poiIndex)
    if i >= 210 and i <= 212 then
        -- Save this character's alliance's Harborage
        self.harborageIndex = i
    end

    name = Utils.FormatSimpleName(name)

    local nodeInfo = {
        nodeIndex = i,
        name = Nav.DisplayName(name),
        originalName = name,
        type = typePOI,
        icon = icon,
        originalIcon = icon,
        known = known,
        zoneId = zone.zoneId,
        zoneIndex = zone.zoneIndex,
        poiIndex = poiIndex
    }

    local isHouse = false
    if typePOI == 6 then
        nodeInfo.poiType = Nav.POI_GROUP_DUNGEON
    elseif typePOI == 3 then
        nodeInfo.poiType = Nav.POI_TRIAL
        nodeInfo.icon = "esoui/art/tutorial/poi_raiddungeon_complete.dds"
    elseif typePOI == 7 then
        isHouse = true
        nodeInfo.houseId = GetFastTravelNodeHouseId(i)
        nodeInfo.collectibleId = GetCollectibleIdForHouse(nodeInfo.houseId)
        nodeInfo.freeRecall = true
        if Nav.saved.useHouseNicknames then
            nodeInfo.nickname = GetCollectibleNickname(nodeInfo.collectibleId)
            nodeInfo.suffix = zo_strformat(GetString(SI_TOOLTIP_COLLECTIBLE_NICKNAME), nodeInfo.nickname)
        end
    elseif typePOI == 1 then
        nodeInfo.poiType = Nav.POI_WAYSHRINE
        if icon:find("poi_wayshrine_complete") or icon == "/esoui/art/icons/icon_missing.dds" then
            nodeInfo.icon = "Navigator/media/icons/wayshrine.dds"
        end
    elseif glowIcon == "/esoui/art/icons/poi/poi_soloinstance_glow.dds" or
            glowIcon == "/esoui/art/icons/poi/poi_groupinstance_glow.dds" then
        nodeInfo.poiType = Nav.POI_ARENA
    else
        Nav.logWarning("Unknown POI " .. i .. " '" .. name .. "' type " .. typePOI .. " " .. (glowIcon or "-"))
    end

    if nodeInfo.icon == "/esoui/art/icons/icon_missing.dds" then
        nodeInfo.icon = "/esoui/art/crafting/crafting_smithing_notrait.dds"
    end

    if nodeInfo.zoneId == Nav.ZONE_CYRODIIL and nodeInfo.poiType == Nav.POI_WAYSHRINE then
        nodeInfo.icon = "/esoui/art/crafting/crafting_smithing_notrait.dds"
        nodeInfo.disabled = true
    end

    local traders = Nav.Data.traderCounts[i]
    if traders and traders > 0 then
        nodeInfo.traders = traders
    end

    local node = isHouse and Nav.HouseNode:New(nodeInfo) or Nav.FastTravelNode:New(nodeInfo)
    return node
end

local function getOrCreateZone(self, zoneId, zoneName, zoneIndex, mapId, canJumpToPlayer)
    if not self.zones[zoneId] then
        if mapId and (zoneIndex == nil or zoneName == nil) then
            local n, _, _, i, _ = GetMapInfoById(mapId)
            zoneName = n
            if zoneIndex == nil then
                zoneIndex = i
            end
        end
        zoneName = Utils.FormatSimpleName(zoneName)
        if self:IsZone(zoneId) or mapId then
            if canJumpToPlayer == nil then
                canJumpToPlayer = CanJumpToPlayerInZone(zoneId) or zoneId == Nav.ZONE_ATOLLOFIMMOLATION
            end
            self.zones[zoneId] = Nav.ZoneNode:New({
                name = zoneName,
                zoneName = zoneName,
                zoneId = zoneId,
                zoneIndex = zoneIndex,
                index = zoneIndex,
                mapId = mapId,
                pois = {},
                canJumpToPlayer = canJumpToPlayer,
                known = true
            })
            if zoneId == 642 or zoneId == 572 then -- Hide The Earth Forge and old Stirk
                self.zones[zoneId].hidden = true
            end
        else
            Nav.log("getOrCreateZone: not zone: zoneId %d name %s", zoneId, zoneName)
        end
    end
    return self.zones[zoneId]
end

local function loadFastTravelNode(self, nodeIndex, nodeLookup, zoneLookup)
    local known, name, _, _, icon, glowIcon, typePOI, _, isLocked = GetFastTravelNodeInfo(nodeIndex)

    if not isLocked and name ~= "" and (typePOI == 1 or glowIcon ~= nil) then
        local zoneIndex, poiIndex = GetFastTravelNodePOIIndicies(nodeIndex)
        local zoneId = GetZoneId(zoneIndex)
        if not zoneLookup[zoneId] then
            zoneId = GetParentZoneId(zoneId)
        end
        if zoneLookup[zoneId] and
           (zoneId ~= Nav.ZONE_CYRODIIL or nodeIndex == 247 or nodeIndex == 236) -- Only allow WGT and ICP in Cyrodiil
           then
            local _, _, _, zone = unpack(zoneLookup[zoneId])
            local node = createNode(self, nodeIndex, name, typePOI, icon, glowIcon, known, zone, poiIndex)

            self.nodeMap[nodeIndex] = node

            local uid = string.format("%d:%d", zoneIndex, poiIndex) --uniqueName(0, name, x, z)
            if not nodeLookup[uid] then --nodeLookup[uid] then
                nodeLookup[uid] = node
                table.insert(self.nodes, node)
                zone.pois[poiIndex] = node

                node.nodeZoneIndex = zoneIndex
                node.nodePOIIndex = poiIndex
            elseif poiIndex ~= 26 then -- We already know about the Wyrd Tree duplicate
                Nav.log("loadFastTravelNode: duplicate %d/%d/%s vs %d/%d/%s", zoneIndex, poiIndex, name, zone.pois[poiIndex].zoneIndex or -1, zone.pois[poiIndex].poiIndex or -1, zone.pois[poiIndex].name or "?")
            end
        elseif zoneId ~= Nav.ZONE_CYRODIIL then -- Cyrodiil wayshrines are special
            Nav.log("loadFastTravelNode: nodeIndex %d '%s': no zone for zoneIndex %d zoneId %d", nodeIndex, name, zoneIndex or -1, zoneId or -1)
        end
    end
end

local function loadPopulatedZones(self, zoneLookup)
    -- Iterate through zones to find correct zones for nodes
    local zoneIdLimit = 1446 -- The Scholarium
    local zoneId = 1
    while zoneId <= zoneIdLimit do --for zoneId = 1, zoneIdLimit do
        if self:IsZone(zoneId) then
            local zoneName = GetZoneNameById(zoneId)
            if zoneName ~= nil and zoneName ~= ""
            then
                zoneIdLimit = math.max(zoneIdLimit, zoneId + 50)
                zoneName = Utils.FormatSimpleName(zoneName)
                local zoneIndex = GetZoneIndex(zoneId)
                local numPOIs = GetNumPOIs(zoneIndex)
                if numPOIs > 0 then
                    local zone = getOrCreateZone(self, zoneId, zoneName, zoneIndex)
                    zoneLookup[zoneId] = { zoneName, zoneIndex, numPOIs, zone }
                end
            end
        end
        zoneId = zoneId + 1
    end

    getOrCreateZone(self, Nav.ZONE_TAMRIEL, nil, nil, 27, false) -- Sort of true, but called 'Clean Test'
    getOrCreateZone(self, 1, nil, nil, 439, false) -- Fake!
    getOrCreateZone(self, Nav.ZONE_ATOLLOFIMMOLATION, nil, 844, 2000, true)
    getOrCreateZone(self, Nav.ZONE_BLACKREACH, nil, nil, 1782, false)
end

local function loadZonePOIs(self, zoneId, zoneIndex, zoneName, numPOIs)
    for poiIndex = 1, numPOIs do
        local nodeZoneId = zoneId
        local poiName = Utils.FormatSimpleName(GetPOIInfo(zoneIndex, poiIndex)) -- might be wrong - "X" instead of "Dungeon: X"!
        local zone = getOrCreateZone(self, nodeZoneId, zoneName, zoneIndex)
        if zone and not zone.pois[poiIndex] and poiName ~= nil and poiName ~= "" then
            local _, _, pinType, icon, _, _, isDiscovered, _ = GetPOIMapInfo(zoneIndex, poiIndex)
            if not icon:find("wayshrine") then -- Remove Cyrodiil's unusable wayshrines
                local node = Nav.POINode:New({
                    poiIndex = poiIndex,
                    name = Nav.DisplayName(poiName),
                    originalName = poiName,
                    zoneId = nodeZoneId,
                    zoneIndex = zoneIndex,
                    icon = icon,
                    originalIcon = icon,
                    known = isDiscovered,
                    pinType = pinType
                })
                if icon:find("poi_mundus") then
                    node.zoneSuffix = zoneName
                end

                table.insert(self.nodes, node)
                zone.pois[poiIndex] = node
            end
        end
    end
end

local function loadKeep(self, bgContext, ktnnIndex, zone)
    local keepId, accessible, _,  _ = GetKeepTravelNetworkNodeInfo(ktnnIndex, bgContext)

    local pinType, _, _  = GetKeepPinInfo(keepId, bgContext)
    local name = Utils.FormatSimpleName(GetKeepName(keepId))
    local icon = "EsoUI/Art/MapPins/AvA_largeKeep_neutral.dds"

    if pinType > 0 then
        icon = ZO_MapPin.PIN_DATA[pinType].texture or "/esoui/art/crafting/crafting_smithing_notrait.dds"
    end

    -- Replace strange default keep icon
    --Nav.log("loadKeep: icon %d '%s'", pinType, icon or "-")
    --if icon:find("UI-WorldMapPlayerPip") then icon = "EsoUI/Art/MapPins/AvA_largeKeep_neutral.dds" end

    local node = Nav.KeepNode:New({
        bgContext = bgContext,
        ktnnIndex = ktnnIndex,
        keepId = keepId,
        name = Nav.DisplayName(name),
        originalName = name,
        zoneId = Nav.ZONE_CYRODIIL,
        icon = icon,
        known = true,
        accessible = Nav.jumpState == Nav.JUMPSTATE_TRANSITUS and accessible,
        pinType = pinType,
        alliance = GetKeepAlliance(keepId, bgContext),
        bgContext = bgContext
    })

    table.insert(self.nodes, node)
    table.insert(zone.keeps, node)
end

local function loadKeeps(self)
    ZO_WorldMap_RefreshKeeps()

    local zone = self.zones[Nav.ZONE_CYRODIIL]
    zone.keeps = {}

    local bgContext = ZO_WorldMap_GetBattlegroundQueryType() --BGQUERY_ASSIGNED_CAMPAIGN

    local count = GetNumKeepTravelNetworkNodes(bgContext)
    Nav.log("loadKeeps: GetNumKeepTravelNetworkNodes=%d, GetNumKeeps=%d", count, GetNumKeeps())
    for ktnnIndex = 1, count do
        loadKeep(self, bgContext, ktnnIndex, zone)
    end
end

function Locs:SetupNodes()
    self.nodes = {}
    self.nodeMap = {}
    self.zones = {}
    self.zoneIndices = {}
    self.locMap = {}

    local beginTime = GetGameTimeMilliseconds()
    local zoneLookup = {}
    loadPopulatedZones(self, zoneLookup)
    self.zoneLookup = zoneLookup
    local endTime_zones = GetGameTimeMilliseconds()

    local nodeLookup = {}
    local totalNodes = GetNumFastTravelNodes()
    for i = 1, totalNodes do
        loadFastTravelNode(self, i, nodeLookup, zoneLookup)
    end
    local endTime_ft  = GetGameTimeMilliseconds()

    -- Iterate through zones to find correct zones for nodes
    for zoneId, zoneData in pairs(zoneLookup) do
        local zoneName, zoneIndex, numPOIs = unpack(zoneData)
        loadZonePOIs(self, zoneId, zoneIndex, zoneName, numPOIs)
    end
    local endTime_pois = GetGameTimeMilliseconds()

    loadKeeps(self)
    local endTime_keeps = GetGameTimeMilliseconds()

    for i = 1, #self.nodes do
        if not self.nodes[i].poiIndex and self.nodes[i].zoneId ~= Nav.ZONE_CYRODIIL then
            Nav.log(" x %s - nodeIndex %d no poiIndex", self.nodes[i].name, self.nodes[i].nodeIndex)
        end
        if not self.nodes[i].zoneId then
            Nav.log(" x %s - nodeIndex %d no zoneId", self.nodes[i].name, self.nodes[i].nodeIndex)
        end
    end

    Nav.log("Locations:SetupNodes: %dms (zones %dms, ft %dms, pois %dms, keeps %dms)",
            endTime_keeps-beginTime, endTime_zones-beginTime, endTime_ft-endTime_zones,
            endTime_pois-endTime_ft, endTime_keeps-endTime_pois)
end

function Locs:clearKnownNodes()
    if self.nodes then
        Nav.log("clearKnownNodes")
        for i = 1, #self.nodes do
            if not self.nodes[i].known then -- unknown nodes may become known, but not vice versa
                self.nodes[i].known = nil
            end
        end
    end
end

function Locs:SetKeepsDirty()
    self.keepsDirty = true
end

function Locs:UpdateKeeps()
    if self.zones == nil then
        self:SetupNodes()
    end

    local zone = self.zones[Nav.ZONE_CYRODIIL]

    if not zone.keeps or #zone.keeps == 0 then
        loadKeeps(self)
    end

    ZO_WorldMap_RefreshKeeps()

    local bgContext = ZO_WorldMap_GetBattlegroundQueryType()

    for i = 1, #zone.keeps do
        local keep = zone.keeps[i]
        keep.bgContext = bgContext
        keep.accessible = Nav.jumpState == Nav.JUMPSTATE_TRANSITUS and GetKeepAccessible(keep.keepId, bgContext)
        keep.alliance = GetKeepAlliance(keep.keepId, bgContext)
        local pinType = GetKeepPinInfo(keep.keepId, bgContext)
        if pinType > 0 then
            keep.pinType  = pinType
            keep.icon = ZO_MapPin.PIN_DATA[pinType].texture or "/esoui/art/crafting/crafting_smithing_notrait.dds"
            --Nav.log("UpdateKeeps: icon %d '%s'", pinType, keep.icon or "-")
        end
    end

    self.keepsDirty = false
end

function Locs:SetKeepsInaccessible()
    if not self.zones then
        return
    end

    local zone = self.zones[Nav.ZONE_CYRODIIL]
    for i = 1, #zone.keeps do
        zone.keeps[i].accessible = false
    end
end

function Locs:GetNode(nodeIndex, includeUnknown)
    if not self.nodeMap then
        self:SetupNodes()
    end

    local node = self.nodeMap[nodeIndex]
    if not node or (not includeUnknown and not node:IsKnown()) then
        return nil
    end

    return self.nodeMap[nodeIndex]
end

function Locs:GetPOI(zoneId, poiIndex, includeUnknown)
    if self.zones == nil then
        self:SetupNodes()
    end

    local zone = self.zones[zoneId]
    if zone and zone.pois[poiIndex] then
        return zone.pois[poiIndex]
    end

    return nil
end

local function createHouseAlias(node)
    local alias = Nav.HouseNode:New(Utils.shallowCopy(node))
    alias.name = node.nickname
    alias.suffix = node.name
    alias.originalName = nil
    alias.isAlias = true
    return alias
end

---GetNodeList
---@param zoneId number
---@param includeAliases boolean
---@return table Node List
function Locs:GetNodeList(zoneId, includeAliases, includePOIs)
    if self.nodes == nil then
        self:SetupNodes()
    end

    if includePOIs == nil then
        includePOIs = true
    end -- Default includePOIs to true

    if zoneId == Nav.ZONE_BLACKREACH then
        local nodes1 = self:GetNodeList(Nav.ZONE_BLACKREACH_ARKTHZANDCAVERN, includeAliases)
        local nodes2 = self:GetNodeList(Nav.ZONE_BLACKREACH_GREYMOORCAVERNS, includeAliases)
        return Utils.tableConcat(nodes1, nodes2)
    end

    local nodes = {}
    for i = 1, #self.nodes do
        local node = self.nodes[i]
        if (not zoneId or node.zoneId == zoneId) and (includePOIs or not node:IsPOI()) then
            table.insert(nodes, node)

            if includeAliases and node:IsHouse() and Nav.saved.useHouseNicknames then
                table.insert(nodes, createHouseAlias(node))
            end
        end
    end
    return nodes
end

function Locs:GetHouseList(includeAliases)
    if self.nodes == nil then
        self:SetupNodes()
    end

    local nodes = {}
    for i = 1, #self.nodes do
        if self.nodes[i]:IsHouse() then
            local node = self.nodes[i]
            table.insert(nodes, node)

            if includeAliases and node:IsOwned() and Nav.saved.useHouseNicknames then
                table.insert(nodes, createHouseAlias(node))
            end
        end
    end
    return nodes
end

function Locs:GetTraderNodeList()
    local nodeList = self:GetNodeList(nil, false, false)
    local filteredList = {}

    for i = 1, #nodeList do
        local node = nodeList[i]
        if node.traders and node.traders > 0 then
            table.insert(filteredList, node)
        end
    end

    table.sort(filteredList, Nav.Node.TradersComparison)

    return filteredList
end

function Locs:GetZones()
    if not self.zones then
        self:SetupNodes()
    end
    return self.zones
end

function Locs:GetZoneList(includeAliases)
    local nodes = {}

    if not self.zones then
        self:SetupNodes()
    end

    for zoneId, zone in pairs(self.zones) do
        if includeAliases or not zone.hidden then
            table.insert(nodes, zone)
            if includeAliases and zoneId == Nav.ZONE_ATOLLOFIMMOLATION then
                table.insert(nodes, Nav.ZoneNode:New({
                    name = GetString(NAVIGATOR_LOCATION_OBLIVIONPORTAL),
                    zoneId = zone.zoneId,
                    canJumpToPlayer = zone.canJumpToPlayer,
                    index = zone.index,
                    mapId = zone.mapId,
                    known = true
                }))
            end
        end
    end

    return nodes
end

function Locs:getZone(zoneId)
    if not self.zones then
        self:SetupNodes()
    end

    return self.zones[zoneId]
end

function Locs:getCurrentMapZoneId()
    local mapId = GetCurrentMapId()
    local _, mapType, _, zoneIndex, _ = GetMapInfoById(mapId)
    local zoneId = GetZoneId(zoneIndex)
    -- Nav.log("Locs:getCurrentMapZone zoneId = "..zoneId.." type "..mapType)
    if mapId == 2119 then
        zoneId = Nav.ZONE_FARGRAVE
    elseif mapId == Nav.MAPID_BLACKREACH then
        return Nav.ZONE_BLACKREACH
    elseif mapType == MAPTYPE_SUBZONE and not self:IsZone(zoneId) then
        zoneId = GetParentZoneId(zoneId)
        -- Nav.log("Locs:getCurrentMapZone parent zoneId = "..zoneId)
    end

    return zoneId
end

function Locs:getCurrentMapZone()
    if self.zones == nil then
        self:SetupNodes()
    end

    local mapId = GetCurrentMapId()
    local _, mapType, _, zoneIndex, _ = GetMapInfoById(mapId)
    local zoneId = GetZoneId(zoneIndex)
    --Nav.log("Locs:getCurrentMapZone zoneId=%d mapId=%d mapType=%d", zoneId, mapId, mapType)

    if mapId == 2000 then
        zoneId = Nav.ZONE_ATOLLOFIMMOLATION
    elseif mapId == 2119 then
        zoneId = Nav.ZONE_FARGRAVE
    elseif mapId == Nav.MAPID_BLACKREACH then
        return self.zones[Nav.ZONE_BLACKREACH]
    end
    if zoneId == Nav.ZONE_TAMRIEL then
        return {
            zoneId = 2
        }
    elseif not self:IsZone(zoneId) then -- mapType == MAPTYPE_SUBZONE
        zoneId = GetParentZoneId(zoneId)
         --Nav.log("Locs:getCurrentMapZone parent zoneId = "..zoneId)
    end
    if not self.zones[zoneId] then
        Nav.log("Locs:getCurrentMapZone no info on zoneId %d", zoneId)
    end
    return self.zones[zoneId]
end

function Locs:IsHarborage(nodeIndex)
	return nodeIndex >= 210 and nodeIndex <= 212
end

function Locs:GetHarborage()
    for i = 210, 212 do
        if self:GetNode(i) then
            return i
        end
    end
    Nav.log("Locs:GetHarborage failed to find harborage")
    return 210
end

function Locs.GetMapIdByZoneId(zoneId)
    if zoneId == Nav.ZONE_TAMRIEL then
        return 27
    elseif zoneId == 981 then -- Brass Fortress
        return 1348
    elseif zoneId == 1463 then -- The Scholarium
        return 2515
    else
        return GetMapIdByZoneId(zoneId)
    end
end

local function getSurveyType(texture)
    local i = 1

    for word in string.gmatch(texture, "[^_]+") do
        if i == 3 then
            return word
        end
        i = i + 1
    end
    return nil
end

function Locs:SetTreasureData()
    if not LibTreasure_GetItemIdData then -- Check if LibTreasure is available
        return
    end
    if self.zones == nil then
        self:SetupNodes()
    end

    Nav.Treasure.Load(self.zones)
end

Nav.Locations = Locs
