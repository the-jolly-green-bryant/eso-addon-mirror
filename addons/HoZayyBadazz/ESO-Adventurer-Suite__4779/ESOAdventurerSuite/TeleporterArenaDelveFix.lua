-- ESO Adventurer Suite
-- v0.29.643 - Teleporter arena + delve destination bridge.
-- Adds ESO POI/activity-backed Delves and Arenas to the same shared Teleporter
-- dataset used by the World Map panel and hotkey window. Direct instance nodes
-- are preferred; otherwise the entry routes through the nearest known wayshrine.
-- Static POI/activity discovery is cached for the session; route-node matching is
-- rebuilt only after player activation so repeated Teleporter refreshes stay cheap.

local EPC = ESOProgressionCoach
if not EPC or not EPC.Travel then return end
local T = EPC.Travel

local function num(v, fallback)
    v = tonumber(v)
    if v == nil then return fallback or 0 end
    return v
end

local function clean(v, fallback)
    v = tostring(v or "")
    v = v:gsub("[%c]+", " "):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    if v == "" then return fallback or "" end
    return v
end

local function lower(v)
    return string.lower(clean(v, ""))
end

local function call1(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a = pcall(fn, ...)
    if not ok or a == nil then return fallback end
    return a
end

local function zoneIndexForId(zoneId)
    zoneId = num(zoneId, 0)
    if zoneId <= 0 or type(GetZoneIndex) ~= "function" then return 0 end
    return num(call1(GetZoneIndex, 0, zoneId), 0)
end

local function zoneIdForIndex(zoneIndex)
    zoneIndex = num(zoneIndex, 0)
    if zoneIndex <= 0 or type(GetZoneId) ~= "function" then return 0 end
    return num(call1(GetZoneId, 0, zoneIndex), 0)
end

local function parentZoneId(zoneId)
    zoneId = num(zoneId, 0)
    if zoneId <= 0 or type(GetParentZoneId) ~= "function" then return zoneId end
    local parent = num(call1(GetParentZoneId, 0, zoneId), 0)
    if parent <= 0 or parent == zoneId then return zoneId end
    return parent
end

local function poiTypeEquals(value, constantName)
    local constant = rawget(_G, constantName)
    return constant ~= nil and value == constant
end

local function getNodeZoneIndex(nodeIndex)
    local fn = rawget(_G, "GetFastTravelNodePOIIndicies") or rawget(_G, "GetFastTravelNodePOIIndices")
    if type(fn) ~= "function" then return 0 end
    local ok, zoneIndex = pcall(fn, nodeIndex)
    return ok and num(zoneIndex, 0) or 0
end

function T:InvalidateArenaDelveRouteCache029643()
    self._arenaDelveRouteNodes029643 = nil
    self._arenaDelveExtraEntries029643 = nil
end

function T:BuildArenaDelveStaticDestinations029643()
    if self._arenaDelveStaticDestinations029643 then
        return self._arenaDelveStaticDestinations029643
    end

    local rows, seen = {}, {}
    local function add(kind, name, zoneIndex, zoneId, x, y, poiIndex, activityId)
        name = clean(name, kind == "ARENA" and "Arena" or "Delve")
        zoneIndex = num(zoneIndex, 0)
        zoneId = num(zoneId, 0)
        if zoneId <= 0 and zoneIndex > 0 then zoneId = zoneIdForIndex(zoneIndex) end
        if zoneIndex <= 0 and zoneId > 0 then zoneIndex = zoneIndexForId(zoneId) end
        if zoneId <= 0 and zoneIndex <= 0 then return end

        local key = kind .. ":" .. tostring(zoneId) .. ":" .. lower(name)
        if seen[key] then
            -- Prefer a POI-backed record because it has real map coordinates.
            local existing = seen[key]
            if (not existing.x or not existing.y) and x and y then
                existing.x, existing.y = tonumber(x), tonumber(y)
                existing.poiIndex = poiIndex
            end
            if activityId and not existing.activityId then existing.activityId = activityId end
            return
        end

        local zoneName = ""
        if zoneIndex > 0 and type(GetZoneNameByIndex) == "function" then
            zoneName = clean(call1(GetZoneNameByIndex, "", zoneIndex), "")
        end
        if zoneName == "" and zoneId > 0 and type(GetZoneNameById) == "function" then
            zoneName = clean(call1(GetZoneNameById, "", zoneId), "")
        end

        local row = {
            instanceCategory = kind,
            name = name,
            zoneName = zoneName ~= "" and zoneName or "Tamriel",
            zoneIndex = zoneIndex,
            zoneId = zoneId,
            parentZoneId = parentZoneId(zoneId),
            x = tonumber(x), y = tonumber(y),
            poiIndex = poiIndex,
            activityId = activityId,
        }
        rows[#rows + 1] = row
        seen[key] = row
    end

    -- POIs are authoritative for Delves and useful for Arenas because they give
    -- us the exact map position needed to pick the nearest wayshrine.
    if type(GetNumZones) == "function" and type(GetNumPOIs) == "function" and type(GetPOIType) == "function" then
        local zoneCount = num(call1(GetNumZones, 0), 0)
        for zoneIndex = 1, zoneCount do
            local zoneId = zoneIdForIndex(zoneIndex)
            local poiCount = num(call1(GetNumPOIs, 0, zoneIndex), 0)
            for poiIndex = 1, poiCount do
                local poiType = call1(GetPOIType, nil, zoneIndex, poiIndex)
                local kind = nil
                if poiTypeEquals(poiType, "POI_TYPE_DELVE") then kind = "DELVE"
                elseif poiTypeEquals(poiType, "POI_TYPE_ARENA") then kind = "ARENA" end

                if kind then
                    local name = ""
                    if type(GetPOIInfo) == "function" then
                        name = clean(call1(GetPOIInfo, "", zoneIndex, poiIndex), "")
                    end
                    local x, y, shown, locked
                    if type(GetPOIMapInfo) == "function" then
                        local ok, px, py, _, _, isShown, collectibleLocked = pcall(GetPOIMapInfo, zoneIndex, poiIndex)
                        if ok then x, y, shown, locked = tonumber(px), tonumber(py), isShown, collectibleLocked end
                    end
                    -- Keep discovered/unlocked POIs and also named POIs that ESO
                    -- exposes even when their current-map visibility is false.
                    if name ~= "" and locked ~= true then
                        add(kind, name, zoneIndex, zoneId, x, y, poiIndex, nil)
                    end
                end
            end
        end
    end

    -- Activity Finder/Group Finder data fills Arena gaps that do not expose a
    -- normal map POI or fast-travel node. LFG_ACTIVITY_ARENA is the native type.
    local arenaType = rawget(_G, "LFG_ACTIVITY_ARENA")
    if arenaType ~= nil and type(GetNumActivitiesByType) == "function" and type(GetActivityIdByTypeAndIndex) == "function" then
        local count = num(call1(GetNumActivitiesByType, 0, arenaType), 0)
        for i = 1, count do
            local activityId = num(call1(GetActivityIdByTypeAndIndex, 0, arenaType, i), 0)
            if activityId > 0 then
                local name = ""
                if type(GetActivityInfo) == "function" then
                    name = clean(call1(GetActivityInfo, "", activityId), "")
                end
                local zoneId = 0
                if type(GetActivityZoneId) == "function" then
                    zoneId = num(call1(GetActivityZoneId, 0, activityId), 0)
                end
                if name ~= "" and zoneId > 0 then
                    add("ARENA", name, zoneIndexForId(zoneId), zoneId, nil, nil, nil, activityId)
                end
            end
        end
    end

    table.sort(rows, function(a, b)
        if a.instanceCategory ~= b.instanceCategory then return a.instanceCategory < b.instanceCategory end
        if lower(a.zoneName) ~= lower(b.zoneName) then return lower(a.zoneName) < lower(b.zoneName) end
        return lower(a.name) < lower(b.name)
    end)

    self._arenaDelveStaticDestinations029643 = rows
    return rows
end

function T:BuildArenaDelveRouteNodes029643()
    if self._arenaDelveRouteNodes029643 then return self._arenaDelveRouteNodes029643 end

    local nodes = {}
    local count = type(GetNumFastTravelNodes) == "function" and num(call1(GetNumFastTravelNodes, 0), 0) or 0
    for nodeIndex = 1, count do
        local ok, known, name, x, y, _, _, poiType, _, locked = pcall(GetFastTravelNodeInfo, nodeIndex)
        if ok and known == true and locked ~= true then
            local zoneIndex = getNodeZoneIndex(nodeIndex)
            local zoneId = zoneIdForIndex(zoneIndex)
            local houseId = 0
            if type(GetFastTravelNodeHouseId) == "function" then
                houseId = num(call1(GetFastTravelNodeHouseId, 0, nodeIndex), 0)
            end
            if houseId <= 0 then
                nodes[#nodes + 1] = {
                    nodeIndex = nodeIndex,
                    name = clean(name, "Travel Node"),
                    x = tonumber(x), y = tonumber(y),
                    zoneIndex = zoneIndex,
                    zoneId = zoneId,
                    parentZoneId = parentZoneId(zoneId),
                    poiType = poiType,
                    isWayshrine = rawget(_G, "POI_TYPE_WAYSHRINE") ~= nil and poiType == POI_TYPE_WAYSHRINE,
                }
            end
        end
    end
    self._arenaDelveRouteNodes029643 = nodes
    return nodes
end

local function routeScore(destination, node)
    local exactZone = destination.zoneId > 0 and node.zoneId == destination.zoneId
    local parentMatch = destination.parentZoneId > 0
        and (node.zoneId == destination.parentZoneId or node.parentZoneId == destination.parentZoneId)
    if not exactZone and not parentMatch then return nil end

    local score = exactZone and 0 or 100
    if node.isWayshrine then score = score + 10 end
    if destination.x and destination.y and node.x and node.y then
        local dx, dy = destination.x - node.x, destination.y - node.y
        score = score + (dx * dx + dy * dy)
    else
        score = score + 1
    end
    return score
end

function T:FindArenaDelveRouteNode029643(destination)
    local nodes = self:BuildArenaDelveRouteNodes029643()
    local best, bestScore = nil, nil

    -- Prefer a direct Arena/Delve node for the same destination when ESO exposes
    -- one. Name matching is only used as a preference, never as the sole route.
    local wanted = lower(destination.name)
    for _, node in ipairs(nodes) do
        local score = routeScore(destination, node)
        if score then
            local nodeName = lower(node.name)
            local directType = (destination.instanceCategory == "ARENA" and poiTypeEquals(node.poiType, "POI_TYPE_ARENA"))
                or (destination.instanceCategory == "DELVE" and poiTypeEquals(node.poiType, "POI_TYPE_DELVE"))
            if directType then score = score - 50 end
            if wanted ~= "" and nodeName ~= "" and (nodeName == wanted or nodeName:find(wanted, 1, true) or wanted:find(nodeName, 1, true)) then
                score = score - 25
            end
            if bestScore == nil or score < bestScore then best, bestScore = node, score end
        end
    end
    return best
end

function T:GetArenaDelveExtraEntries029643()
    if self._arenaDelveExtraEntries029643 then return self._arenaDelveExtraEntries029643 end

    local out = {}
    for _, destination in ipairs(self:BuildArenaDelveStaticDestinations029643()) do
        local route = self:FindArenaDelveRouteNode029643(destination)
        local cost = 0
        if route and type(self.GetLiveWayshrineTravelCost) == "function" then
            local ok, value = pcall(self.GetLiveWayshrineTravelCost, self, route.nodeIndex)
            if ok then cost = num(value, 0) end
        end
        out[#out + 1] = {
            kind = "INSTANCE",
            key = "I:EAS643:" .. destination.instanceCategory .. ":" .. tostring(destination.zoneId) .. ":" .. lower(destination.name),
            nodeIndex = route and route.nodeIndex or nil,
            name = destination.name,
            displayName = destination.name,
            zoneName = destination.zoneName,
            zoneId = destination.zoneId,
            zoneIndex = destination.zoneIndex,
            parentZoneId = destination.parentZoneId,
            normalizedX = destination.x or (route and route.x),
            normalizedY = destination.y or (route and route.y),
            poiType = destination.instanceCategory == "DELVE" and rawget(_G, "POI_TYPE_DELVE") or rawget(_G, "POI_TYPE_ARENA"),
            instanceCategory = destination.instanceCategory,
            activityId = destination.activityId,
            routeViaWayshrine029643 = route and route.isWayshrine == true or false,
            routeNodeName029643 = route and route.name or "",
            canTravel = route ~= nil,
            statusText = route and nil or "No discovered travel node is currently available near this destination.",
            costText = cost <= 0 and "Free" or (tostring(math.floor(cost + 0.5)) .. " gold"),
        }
    end

    self._arenaDelveExtraEntries029643 = out
    return out
end

-- One shared source feeds ALL / DELVES / DUNGEONS / INSTANCES in both the big
-- World Map panel and hotkey Teleporter, so fixing the instance source fixes both.
if type(T.GetMapTeleporterInstanceEntries) == "function" and not T._easArenaDelveWrapped029643 then
    T._easArenaDelveWrapped029643 = true
    local baseInstances = T.GetMapTeleporterInstanceEntries
    function T:GetMapTeleporterInstanceEntries(...)
        local rows = baseInstances(self, ...) or {}
        local seen = {}
        for _, entry in ipairs(rows) do
            local key = lower(entry and entry.name or "") .. ":" .. tostring(num(entry and entry.zoneId, 0))
            seen[key] = true
        end
        for _, entry in ipairs(self:GetArenaDelveExtraEntries029643()) do
            local key = lower(entry.name) .. ":" .. tostring(num(entry.zoneId, 0))
            if not seen[key] then
                rows[#rows + 1] = entry
                seen[key] = true
            end
        end
        table.sort(rows, function(a, b)
            local ca, cb = tostring(a.instanceCategory or "INSTANCE"), tostring(b.instanceCategory or "INSTANCE")
            if ca ~= cb then return ca < cb end
            if lower(a.zoneName) ~= lower(b.zoneName) then return lower(a.zoneName) < lower(b.zoneName) end
            return lower(a.name) < lower(b.name)
        end)
        return rows
    end
end

-- Make routed entries explicit in chat so a Delve/Arena entry never pretends a
-- nearby wayshrine is the instance door itself.
if type(T.TravelMapTeleporterEntry) == "function" and not T._easArenaDelveTravelWrapped029643 then
    T._easArenaDelveTravelWrapped029643 = true
    local baseTravel = T.TravelMapTeleporterEntry
    function T:TravelMapTeleporterEntry(entry, ...)
        if entry and entry.routeViaWayshrine029643 and entry.routeNodeName029643 ~= "" and EPC.Print then
            EPC:Print("Routing to " .. clean(entry.name, "destination") .. " via " .. entry.routeNodeName029643 .. ".")
        end
        return baseTravel(self, entry, ...)
    end
end

if EVENT_MANAGER and EVENT_PLAYER_ACTIVATED then
    EVENT_MANAGER:RegisterForEvent("ESOAdventurerSuite_ArenaDelveRoutes029643", EVENT_PLAYER_ACTIVATED, function()
        if EPC.Travel and EPC.Travel.InvalidateArenaDelveRouteCache029643 then
            EPC.Travel:InvalidateArenaDelveRouteCache029643()
        end
    end)
end

SLASH_COMMANDS = SLASH_COMMANDS or {}
SLASH_COMMANDS["/easdestinations"] = function()
    local static = T:BuildArenaDelveStaticDestinations029643()
    local delves, arenas = 0, 0
    for _, d in ipairs(static) do
        if d.instanceCategory == "DELVE" then delves = delves + 1
        elseif d.instanceCategory == "ARENA" then arenas = arenas + 1 end
    end
    local extras = T:GetArenaDelveExtraEntries029643()
    local routable = 0
    for _, e in ipairs(extras) do if e.canTravel ~= false then routable = routable + 1 end end
    local text = string.format("EAS Teleporter destinations | delves=%d arenas=%d routable=%d/%d", delves, arenas, routable, #extras)
    if type(d) == "function" then d(text) elseif EPC.Print then EPC:Print(text) end
end
