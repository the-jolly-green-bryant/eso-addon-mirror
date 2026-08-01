OpulentOrdealNavigator = OpulentOrdealNavigator or {}

local OON = OpulentOrdealNavigator

local ROLE_BY_ROOM_INDEX = {
    [1] = "pickup",
    [2] = "relay",
    [3] = "final",
}

local function Print(message)
    if OON.Print then
        OON.Print(message)
    end
end

local function NormalizeColor(value)
    value = value and string.lower(value) or nil
    if value == "yellow" then
        value = "orange"
    end
    if value and OON.ROOMS and OON.ROOMS[value] then
        return value
    end
    return nil
end

local function NormalizeAssignment(value)
    value = value and string.lower(value) or nil
    if value == "middle" or value == "center" or value == "colourless" or value == "colorless" or value == "none" then
        return "none"
    end
    return NormalizeColor(value)
end

local function BuildKey(orbColor, spawnRoom)
    if not orbColor or not spawnRoom then
        return nil
    end
    return string.format("%s:%s", orbColor, spawnRoom)
end

local function BuildPickupProfileKey(orbColor, spawnRoom, relayRoom)
    return string.format("pickup_%s_in_%s_hand_to_%s", orbColor, spawnRoom, relayRoom)
end

local function BuildRelayProfileKey(orbColor, spawnRoom, relayRoom)
    return string.format("%s_orb_from_%s_through_%s_hand_to_%s", orbColor, spawnRoom, relayRoom, orbColor)
end

local function BuildFinalProfileKey(orbColor, relayRoom)
    if orbColor == "orange" and relayRoom == "purple" then
        return "hand_in_orange_orb_from_purple"
    end
    return string.format("hand_in_%s_orb_from_%s_side", orbColor, relayRoom)
end

local function GetRouteDefinition(orbColor, spawnRoom)
    orbColor = NormalizeColor(orbColor)
    spawnRoom = NormalizeColor(spawnRoom)
    local rooms = OON.ORB_ROUTES and OON.ORB_ROUTES[BuildKey(orbColor, spawnRoom)]
    if not rooms then
        return nil, string.format("No automated route known for %s orb from %s.", tostring(orbColor), tostring(spawnRoom))
    end

    local pickupRoom = rooms[1]
    local relayRoom = rooms[2]
    local finalRoom = rooms[3]
    local profiles = {
        pickup = {
            room = pickupRoom,
            profileKey = BuildPickupProfileKey(orbColor, pickupRoom, relayRoom),
            label = "Pickup",
        },
        relay = {
            room = relayRoom,
            profileKey = BuildRelayProfileKey(orbColor, pickupRoom, relayRoom),
            label = "Relay",
        },
        final = {
            room = finalRoom,
            profileKey = BuildFinalProfileKey(orbColor, relayRoom),
            label = "Final",
        },
    }

    return {
        orbColor = orbColor,
        spawnRoom = spawnRoom,
        rooms = rooms,
        profiles = profiles,
    }
end

local function GetStageForRoom(route, room)
    for index, routeRoom in ipairs(route.rooms or {}) do
        if routeRoom == room then
            return ROLE_BY_ROOM_INDEX[index]
        end
    end
    return nil
end

local function Capitalize(value)
    if not value then
        return ""
    end
    return zo_strformat("<<C:1>>", value)
end

local function GetStageInstruction(stage, orbColor, owner, route)
    local pickupRoom = route.rooms[1]
    local relayRoom = route.rooms[2]
    local finalRoom = route.rooms[3]
    local orbName = Capitalize(orbColor)

    if stage == "pickup" then
        return string.format("Kill the pickup boss, take the %s orb, then carry it to %s.", orbName, Capitalize(relayRoom))
    end
    if stage == "relay" then
        return string.format("Kill the joined boss, meet the carrier, take the %s orb, then carry it to %s.", orbName, Capitalize(finalRoom))
    end
    if stage == "final" then
        return string.format("Kill the drop boss early, receive the %s orb, then place it in the final holder.", orbName)
    end

    return "Follow the highlighted markers."
end

local function BuildOwnedRouteProfilePlan(profileKey, owner, route, stage)
    local profile = profileKey and OON.M0R_ROUTE_PROFILES and OON.M0R_ROUTE_PROFILES[profileKey]
    if not profile then
        return nil, string.format("Missing route profile: %s.", tostring(profileKey))
    end

    local markerIds = {}
    for _, marker in ipairs(profile.markers or {}) do
        markerIds[#markerIds + 1] = marker.id
    end

    local roomLabels = {}
    for index, room in ipairs(route.rooms or {}) do
        roomLabels[index] = OON.ROOMS[room].label
    end

    return {
        task = "automated_route_profile",
        orbColor = route.orbColor,
        spawnRoom = route.spawnRoom,
        stage = stage,
        stageLabel = OON.ROOMS[owner] and OON.ROOMS[owner].label or Capitalize(owner),
        route = route.rooms,
        steps = {
            GetStageInstruction(stage, route.orbColor, owner, route),
        },
        routeLabel = table.concat(roomLabels, " > "),
        profileName = profile.profileName,
        pathSegments = {
            {
                id = "auto_" .. profileKey,
                owner = owner,
                from = owner,
                to = owner,
                purpose = "automated_route_profile",
                markers = markerIds,
            },
        },
    }
end

function OON.ResolveAutomatedRoute(orbColor, spawnRoom, requestedStage, playerColor)
    local route, err = GetRouteDefinition(orbColor, spawnRoom)
    if not route then
        return nil, err
    end

    playerColor = NormalizeAssignment(playerColor or OON.playerColor)
    if playerColor == "none" and not requestedStage then
        return nil, "No affinity assigned: stay in the center; no room route shown."
    end

    local stage = requestedStage and string.lower(requestedStage) or nil
    if stage == "middle" or stage == "handoff" then
        stage = "relay"
    end
    if stage == "place" or stage == "handin" or stage == "hand-in" then
        stage = "final"
    end
    stage = stage or GetStageForRoom(route, playerColor)

    if not stage or not route.profiles[stage] then
        return nil, "Set your color first, or pass pickup, relay, or final as the last argument."
    end

    local selected = route.profiles[stage]
    local plan, planErr = BuildOwnedRouteProfilePlan(selected.profileKey, selected.room, route, stage)
    if not plan then
        return nil, planErr
    end

    plan.selectedRoom = selected.room
    plan.selectedProfileKey = selected.profileKey
    plan.selectedStage = stage
    return plan
end

function OON.StartAutomatedRoute(orbColor, spawnRoom, requestedStage, source)
    source = source or "manual"
    local playerColor = NormalizeColor(OON.playerColor)
    if source == "detection" then
        Print(string.format(
            "Detected %s orb in %s.",
            tostring(orbColor),
            tostring(spawnRoom)
        ))
        if not requestedStage and not playerColor then
            Print("No route shown: set your starting color first with /oon color red, orange, or purple.")
        end
    end

    local plan, err = OON.ResolveAutomatedRoute(orbColor, spawnRoom, requestedStage)
    if not plan then
        Print(err)
        return
    end

    OON.currentPlan = plan
    if OON.ShowPlan then
        OON.ShowPlan(plan)
    else
        Print(plan.steps[1])
    end
    OON.AnimatePlanPath(plan, plan.selectedRoom)
    Print(string.format(
        "Auto %s: %s -> %s.",
        plan.selectedStage,
        plan.selectedProfileKey,
        plan.selectedRoom
    ))
    if source == "detection" then
        Print(string.format(
            "Detection route: player=%s stage=%s profile=%s.",
            playerColor or "unset",
            plan.selectedStage,
            plan.selectedProfileKey
        ))
    end
end
