TamrielRaces = TamrielRaces or {}
local TR = TamrielRaces

TR.RouteGenerator = TR.RouteGenerator or {}
local RouteGenerator = TR.RouteGenerator

local function NodeKey(node)
    if not node then return "" end
    return string.format(
        "%s:%s:%s",
        tostring(node.zoneIndex or ""),
        tostring(node.poiIndex or ""),
        tostring(node.nodeIndex or node.name or "")
    )
end

local function BuildNodeSet(routeKeys)
    local result = {}
    for _, key in ipairs(routeKeys or {}) do
        if type(key) == "string" and key ~= "" then
            result[key] = true
        end
    end
    return result
end

local function CountFreshNodes(route, previousSet)
    local fresh = 0
    for _, node in ipairs(route or {}) do
        if not previousSet[NodeKey(node)] then
            fresh = fresh + 1
        end
    end
    return fresh
end

local function RouteSignature(route)
    local parts = {}
    for index, node in ipairs(route or {}) do
        parts[index] = NodeKey(node)
    end
    return table.concat(parts, ">")
end

local function WeightedChoice(entries, weightFunction)
    if #entries == 0 then return nil end

    local totalWeight = 0
    local weights = {}
    for index, entry in ipairs(entries) do
        local weight = math.max(0.001, tonumber(weightFunction(entry, index)) or 0.001)
        weights[index] = weight
        totalWeight = totalWeight + weight
    end

    local roll = math.random() * totalWeight
    local running = 0
    for index, entry in ipairs(entries) do
        running = running + weights[index]
        if roll <= running then return entry end
    end

    return entries[#entries]
end

function RouteGenerator:GetWayshrinesForCurrentZone()
    local zoneIndex = GetUnitZoneIndex and GetUnitZoneIndex("player") or nil
    local zoneName = GetUnitZone and GetUnitZone("player") or "Unknown Zone"
    local nodes = {}

    if not zoneIndex or not GetNumFastTravelNodes or not GetFastTravelNodeInfo then
        return nodes, zoneIndex, zoneName
    end

    -- Preserve the map context already active when the route is created.
    -- Never force the world map to another context during route generation.
    local mapId = GetCurrentMapId and GetCurrentMapId() or nil
    TR.State.raceMapId = mapId

    for nodeIndex = 1, GetNumFastTravelNodes() do
        local known, name, x, y, icon, _, poiType, _, locked = GetFastTravelNodeInfo(nodeIndex)
        if known and not locked and poiType == POI_TYPE_WAYSHRINE then
            local nodeZoneIndex, poiIndex = GetFastTravelNodePOIIndicies(nodeIndex)
            if nodeZoneIndex == zoneIndex then
                local px, py, _, poiIcon, _, _, discovered = GetPOIMapInfo(nodeZoneIndex, poiIndex)
                local localX, localY = px or x, py or y
                local ux, uy = TR.Util.ToUniversal(mapId, localX, localY)
                nodes[#nodes + 1] = {
                    nodeIndex = nodeIndex,
                    zoneIndex = nodeZoneIndex,
                    poiIndex = poiIndex,
                    name = name,
                    x = localX,
                    y = localY,
                    ux = ux,
                    uy = uy,
                    mapId = mapId,
                    icon = poiIcon or icon,
                    discovered = discovered,
                }
            end
        end
    end

    return nodes, zoneIndex, zoneName
end

function RouteGenerator:BuildEndpointPairs(nodes, previousSet)
    local allPairs = {}
    local maxDistance = 0

    for i = 1, #nodes - 1 do
        for j = i + 1, #nodes do
            local distance = TR.Util.Distance2D(nodes[i].ux, nodes[i].uy, nodes[j].ux, nodes[j].uy)
            maxDistance = math.max(maxDistance, distance)
            allPairs[#allPairs + 1] = {
                first = nodes[i],
                second = nodes[j],
                distance = distance,
            }
        end
    end

    if #allPairs == 0 then return {}, 0 end

    local minimumRatio = tonumber(TR.Config.minimumEndpointDistanceRatio) or 0.55
    local minimumDistance = maxDistance * minimumRatio
    local eligible = {}

    for _, pair in ipairs(allPairs) do
        if pair.distance >= minimumDistance then
            local freshEndpoints = 0
            if not previousSet[NodeKey(pair.first)] then freshEndpoints = freshEndpoints + 1 end
            if not previousSet[NodeKey(pair.second)] then freshEndpoints = freshEndpoints + 1 end
            pair.freshEndpoints = freshEndpoints
            eligible[#eligible + 1] = pair
        end
    end

    if #eligible == 0 then eligible = allPairs end
    return eligible, maxDistance
end

function RouteGenerator:ChooseEndpointPair(endpointPairs, maxDistance, previousSet)
    return WeightedChoice(endpointPairs, function(pair)
        local distanceRatio = maxDistance > 0 and (pair.distance / maxDistance) or 1
        local freshEndpoints = pair.freshEndpoints
        if freshEndpoints == nil then
            freshEndpoints = 0
            if not previousSet[NodeKey(pair.first)] then freshEndpoints = freshEndpoints + 1 end
            if not previousSet[NodeKey(pair.second)] then freshEndpoints = freshEndpoints + 1 end
        end

        -- Keep Point-to-Point routes substantial while strongly favouring endpoints
        -- that were absent from the immediately previous route.
        local distanceWeight = 0.75 + (distanceRatio * distanceRatio * 2.25)
        local freshnessWeight = 1 + (freshEndpoints * 1.5)
        return distanceWeight * freshnessWeight
    end)
end

function RouteGenerator:ChooseBucketCandidate(options, previousSet)
    if #options == 0 then return nil end

    table.sort(options, function(a, b)
        if a.baseScore == b.baseScore then
            return tostring(a.node.name) < tostring(b.node.name)
        end
        return a.baseScore < b.baseScore
    end)

    -- Randomise only amongst the best-fitting corridor candidates. This preserves
    -- the straight-line character while preventing the same mathematically perfect
    -- wayshrine from winning every generation.
    local pool = {}
    local poolLimit = math.min(5, #options)
    for index = 1, poolLimit do pool[index] = options[index] end

    return WeightedChoice(pool, function(candidate, rank)
        local rankWeight = (poolLimit - rank) + 1
        local freshnessWeight = previousSet[NodeKey(candidate.node)] and 1 or 3.5
        return rankWeight * freshnessWeight
    end)
end

function RouteGenerator:BuildCandidateRoute(nodes, endpointPair, previousSet, targetIntermediate)
    if not endpointPair then return nil end

    local startNode, finishNode = endpointPair.first, endpointPair.second
    if math.random(2) == 2 then
        startNode, finishNode = finishNode, startNode
    end

    local sx, sy = startNode.ux, startNode.uy
    local fx, fy = finishNode.ux, finishNode.uy
    local vx, vy = fx - sx, fy - sy
    local lengthSquared = vx * vx + vy * vy
    local corridor = {}

    for _, node in ipairs(nodes) do
        if node ~= startNode and node ~= finishNode then
            local wx, wy = node.ux - sx, node.uy - sy
            local progress = 0
            if lengthSquared > 0 then
                progress = (wx * vx + wy * vy) / lengthSquared
            end

            if progress > 0.08 and progress < 0.92 then
                local projectedX = sx + progress * vx
                local projectedY = sy + progress * vy
                corridor[#corridor + 1] = {
                    node = node,
                    progress = progress,
                    lateral = TR.Util.Distance2D(node.ux, node.uy, projectedX, projectedY),
                }
            end
        end
    end

    targetIntermediate = math.min(targetIntermediate, #corridor)
    local selected = {}
    local used = {}

    if targetIntermediate > 0 then
        local bucketSize = 1 / (targetIntermediate + 1)
        for bucket = 1, targetIntermediate do
            local targetProgress = bucket * bucketSize
            local options = {}

            for _, candidate in ipairs(corridor) do
                local key = NodeKey(candidate.node)
                if not used[key] then
                    options[#options + 1] = {
                        node = candidate.node,
                        progress = candidate.progress,
                        lateral = candidate.lateral,
                        baseScore = math.abs(candidate.progress - targetProgress) + candidate.lateral * 1.75,
                    }
                end
            end

            local chosen = self:ChooseBucketCandidate(options, previousSet)
            if chosen then
                selected[#selected + 1] = chosen
                used[NodeKey(chosen.node)] = true
            end
        end
    end

    table.sort(selected, function(a, b) return a.progress < b.progress end)

    local route = { startNode }
    for _, selectedNode in ipairs(selected) do
        route[#route + 1] = selectedNode.node
    end
    route[#route + 1] = finishNode

    return route
end

function RouteGenerator:RememberGeneratedRoute(zoneKey, route)
    TR.sv.lastGeneratedRoutesByZone = TR.sv.lastGeneratedRoutesByZone or {}
    local routeKeys = {}
    for index, node in ipairs(route or {}) do
        routeKeys[index] = NodeKey(node)
    end
    TR.sv.lastGeneratedRoutesByZone[zoneKey] = routeKeys
end

function RouteGenerator:GenerateRoute()
    local state = TR.State
    if state.running then return false, "race already running" end

    local nodes, zoneIndex, zoneName = self:GetWayshrinesForCurrentZone()
    if #nodes < 2 then
        TR.Diagnostics:Warn("Create Race failed: only " .. tostring(#nodes) .. " known wayshrines found")
        return false, "not enough known wayshrines in this zone"
    end

    TR.sv.lastGeneratedRoutesByZone = TR.sv.lastGeneratedRoutesByZone or {}
    local zoneKey = tostring(zoneIndex or zoneName or "unknown")
    local previousRouteKeys = TR.sv.lastGeneratedRoutesByZone[zoneKey] or {}
    local previousSet = BuildNodeSet(previousRouteKeys)
    local hasPreviousRoute = #previousRouteKeys > 0

    local endpointPairs, maxDistance = self:BuildEndpointPairs(nodes, previousSet)
    if #endpointPairs == 0 then
        return false, "could not determine race endpoints"
    end

    local targetIntermediate = math.min(6, math.max(2, math.floor(#nodes / 2) - 1))
    local availableFresh = 0
    for _, node in ipairs(nodes) do
        if not previousSet[NodeKey(node)] then availableFresh = availableFresh + 1 end
    end

    local targetRouteSize = math.min(#nodes, targetIntermediate + 2)
    local requiredFresh = 0
    if hasPreviousRoute then
        requiredFresh = math.min(
            tonumber(TR.Config.minimumFreshWayshrines) or 4,
            availableFresh,
            targetRouteSize
        )
    end

    local attempts = math.max(1, tonumber(TR.Config.routeGenerationAttempts) or 48)
    local acceptable = {}
    local bestRoute, bestFresh, bestDistance = nil, -1, -1
    local seenSignatures = {}

    for _ = 1, attempts do
        local pair = self:ChooseEndpointPair(endpointPairs, maxDistance, previousSet)
        local route = self:BuildCandidateRoute(nodes, pair, previousSet, targetIntermediate)
        if route and #route >= 2 then
            local signature = RouteSignature(route)
            if not seenSignatures[signature] then
                seenSignatures[signature] = true
                local fresh = CountFreshNodes(route, previousSet)
                local endpointDistance = TR.Util.Distance2D(
                    route[1].ux, route[1].uy,
                    route[#route].ux, route[#route].uy
                )

                if fresh > bestFresh or (fresh == bestFresh and endpointDistance > bestDistance) then
                    bestRoute = route
                    bestFresh = fresh
                    bestDistance = endpointDistance
                end

                if fresh >= requiredFresh then
                    acceptable[#acceptable + 1] = route
                end
            end
        end
    end

    local route = nil
    if #acceptable > 0 then
        route = acceptable[math.random(#acceptable)]
    else
        route = bestRoute
    end

    if not route or #route < 2 then
        return false, "could not build a valid race route"
    end

    local freshCount = CountFreshNodes(route, previousSet)
    local startNode, finishNode = route[1], route[#route]
    self:RememberGeneratedRoute(zoneKey, route)

    state.route = route
    state.currentZoneIndex = zoneIndex
    state.currentZoneName = zoneName
    state.currentIndex = 1
    state.running = false
    state.waitingAtStart = true
    state.startReady = false
    state.countdownActive = false
    state.preRaceMapCountdown = false
    state.routeCreated = true
    state.routeInvalid = false
    state.startTimeMs = nil
    state.splitTimes = {}
    state.lastResult = nil

    TR.Controller:CallModules("OnRouteCreated", route)
    TR:NotifyChanged()
    TR.Diagnostics:Log(string.format(
        "Race created: %d checkpoints from %s to %s in %s; %d fresh vs previous route (required %d)",
        #route,
        tostring(startNode.name),
        tostring(finishNode.name),
        tostring(zoneName),
        freshCount,
        requiredFresh
    ), true)

    if hasPreviousRoute and freshCount < requiredFresh then
        TR.Diagnostics:Warn(string.format(
            "Route variety fallback: generated %d fresh wayshrines; requested %d but this corridor could not supply them",
            freshCount,
            requiredFresh
        ))
    end

    return true
end

function RouteGenerator:CancelRoute(reason)
    TR.Controller:ShutdownRace(reason or "race cancelled")
    TR:NotifyChanged()
    return true
end

TR.Controller:RegisterModule("RouteGenerator", RouteGenerator)
