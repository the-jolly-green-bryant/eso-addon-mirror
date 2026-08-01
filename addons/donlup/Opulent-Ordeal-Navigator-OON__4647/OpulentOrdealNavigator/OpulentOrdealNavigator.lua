OpulentOrdealNavigator = OpulentOrdealNavigator or {}

local OON = OpulentOrdealNavigator
local ADDON_NAME = "OpulentOrdealNavigator"
local SOAK_WARNING_UPDATE = ADDON_NAME .. "SoakWarningUpdate"
local RAID_LEAD_SOAK_UPDATE = ADDON_NAME .. "RaidLeadSoakUpdate"
local LAMP_TIMER_UPDATE = ADDON_NAME .. "LampTimerUpdate"
local DEFAULT_PROXIMITY_CHECK_MS = 100

local DEFAULTS = {
    enabled = true,
    debug = true,
    raidLead = {
        enabled = false,
    },
    preferredRoom = "red",
    rosterColors = {},
    assignedSoaker = nil,
    assignedSoaks = {},
    encounterPhase = 1,
    pathAnimation = {
        enabled = false,
        intervalMs = DEFAULT_PROXIMITY_CHECK_MS,
        proximityRadius = 250,
        markerWindow = 2,
        showFullPath = true,
        showRouteLines = true,
        loop = true,
        onlyOwnTeam = true,
        directionIndicatorInterval = 0,
    },
    markerRendering = {
        enabled = true,
        size = 105,
        activeSize = 145,
        labels = true,
        labelSize = 85,
        labelYOffset = 130,
    },
    persistentMarkers = {
        showEclipseLamps = true,
        showPhase2TankMarkers = true,
    },
    teammateMarkers = {
        enabled = true,
    },
    colorSync = {
        enabled = false,
    },
    infoWindow = {
        enabled = true,
        left = nil,
        top = nil,
    },
    lampTimer = {
        left = nil,
        top = nil,
    },
}

local function Print(message)
    d(string.format("|cFF7A1A%s|r %s", "OON", message))
end

OON.Print = Print

OON.active = false
OON.playerColor = nil
OON.assignmentSources = OON.assignmentSources or {}

function OON.IsActive()
    return OON.active == true
end

local function Capitalize(value)
    return value and zo_strformat("<<C:1>>", value) or ""
end

local function BuildRouteKey(orbColor, spawnRoom)
    if not orbColor or not spawnRoom then
        return nil
    end
    return string.format("%s:%s", orbColor, spawnRoom)
end

local function NormalizeColor(value)
    value = value and string.lower(value) or nil
    if value == "yellow" then
        value = "orange"
    end
    if value and OON.ROOMS[value] then
        return value
    end
    return nil
end

local function NormalizeAssignment(value)
    value = value and string.lower(value) or nil
    if value == "yellow" then
        value = "orange"
    end
    if value == "middle" or value == "center" or value == "colourless" or value == "colorless" or value == "none" then
        return "none"
    end
    return NormalizeColor(value)
end

local function GetAssignmentLabel(color)
    if color == "none" then
        return "None"
    end
    return Capitalize(color)
end

local function GetNonePrompt()
    return table.concat({
        "No affinity detected: stay in the center.",
        "To choose manually: /oon color red",
        "Options: red, orange, purple, or none.",
    }, "\n")
end

local function GetReadyPrompt(color)
    if color == "none" then
        return GetNonePrompt()
    end
    return string.format(
        "Go to the %s side.\nWait for your route or soak instruction.",
        GetAssignmentLabel(color)
    )
end

local function GetRoleScore(role)
    return OON.ROLE_PRIORITY[role] or 99
end

local function GetRoleName(role)
    if role == LFG_ROLE_DPS then
        return "DD"
    end
    if role == LFG_ROLE_HEAL then
        return "Healer"
    end
    if role == LFG_ROLE_TANK then
        return "Tank"
    end
    return "Unknown"
end

function OON.GetLongRoute(orbColor, spawnRoom)
    return OON.ORB_ROUTES[BuildRouteKey(orbColor, spawnRoom)]
end

function OON.GetPathBetween(fromRoom, toRoom)
    return OON.TEAM_ROUTE_CHUNKS[string.format("%s>%s", fromRoom, toRoom)]
end

function OON.BuildPathSegments(chunkIds, owner, fromRoom, toRoom)
    local segments = {}

    for _, chunkId in ipairs(chunkIds or {}) do
        local chunk = OON.PATH_CHUNKS[chunkId]
        if chunk then
            segments[#segments + 1] = {
                id = chunkId,
                owner = owner or chunk.owner,
                from = fromRoom or chunk.owner,
                to = toRoom,
                chunkFrom = chunk.from,
                chunkTo = chunk.to,
                purpose = chunk.purpose,
                movement = chunk.movement or "run",
                instruction = chunk.instruction,
                markers = chunk.markers or {},
            }
        end
    end

    return segments
end

function OON.AppendPathSegments(target, chunkIds, owner, fromRoom, toRoom)
    local segments = OON.BuildPathSegments(chunkIds, owner, fromRoom, toRoom)
    for _, segment in ipairs(segments) do
        target[#target + 1] = segment
    end
end

function OON.BuildReturnPlan(room, origin)
    room = NormalizeColor(room)
    origin = origin or "join"
    local chunkIds = room and OON.RETURN_CHUNKS[room] and OON.RETURN_CHUNKS[room][origin]
    if not chunkIds then
        return nil, string.format("No return path known for %s from %s.", tostring(room), tostring(origin))
    end

    return {
        task = "return_middle",
        route = { room, "center" },
        steps = { "Return to the center." },
        pathSegments = OON.BuildPathSegments(chunkIds, room, room, "center"),
    }
end

function OON.BuildMarkerPlan(room, markerId, task)
    room = NormalizeColor(room)
    local marker = markerId and OON.MARKERS[markerId]
    if not room or not marker then
        return nil
    end

    local instruction = string.format("Go to %s.", marker.label)
    if task and string.find(task, "soak", 1, true) then
        instruction = string.format("Go to %s and hold block.", marker.label)
    end

    return {
        task = task or "marker",
        route = { room },
        steps = { instruction },
        pathSegments = {
            {
                id = task or "marker",
                owner = room,
                from = room,
                to = room,
                purpose = task or "marker",
                markers = { markerId },
            },
        },
    }
end

function OON.BuildActionPlan(orbColor, spawnRoom)
    local route = OON.GetLongRoute(orbColor, spawnRoom)
    if not route then
        return nil, string.format("No route known for %s orb from %s.", tostring(orbColor), tostring(spawnRoom))
    end

    local steps = {}
    for index = 1, #route do
        local room = OON.ROOMS[route[index]]
        if index == 1 then
            local nextRoom = OON.ROOMS[route[index + 1]]
            steps[#steps + 1] = string.format("Kill the pickup boss, take the orb, then follow markers to %s.", nextRoom.label)
        elseif index == #route then
            steps[#steps + 1] = "Kill the drop boss early, receive the orb, then place it in the final holder."
        else
            local nextRoom = OON.ROOMS[route[index + 1]]
            steps[#steps + 1] = string.format("Kill the joined boss, meet the carrier, take the orb, then follow markers to %s.", nextRoom.label)
        end
    end

    local pathSegments = {}
    local teamTasks = {}
    for index = 1, #route - 1 do
        local fromRoom = route[index]
        local toRoom = route[index + 1]
        local chunkIds = OON.GetPathBetween(fromRoom, toRoom) or {}
        local taskSegments = OON.BuildPathSegments(chunkIds, fromRoom, fromRoom, toRoom)
        teamTasks[fromRoom] = {
            task = "handoff",
            from = fromRoom,
            to = toRoom,
            pathSegments = taskSegments,
        }
        for _, segment in ipairs(taskSegments) do
            pathSegments[#pathSegments + 1] = segment
        end
    end

    local finalRoom = route[#route]
    local finalChunkIds = OON.FINAL_SETUP_CHUNKS[finalRoom] or {}
    local finalSegments = OON.BuildPathSegments(finalChunkIds, finalRoom, finalRoom, finalRoom)
    teamTasks[finalRoom] = {
        task = "final_setup",
        from = finalRoom,
        to = finalRoom,
        pathSegments = finalSegments,
    }
    for _, segment in ipairs(finalSegments) do
        pathSegments[#pathSegments + 1] = segment
    end

    return {
        orbColor = orbColor,
        spawnRoom = spawnRoom,
        route = route,
        steps = steps,
        pathSegments = pathSegments,
        teamTasks = teamTasks,
    }
end

local function GetUnitRole(unitTag)
    if GetGroupMemberSelectedRole then
        return GetGroupMemberSelectedRole(unitTag)
    end
    if GetSelectedLFGRole then
        return GetSelectedLFGRole()
    end
    return LFG_ROLE_INVALID
end

local function GetDisplayName(unitTag)
    local accountName = GetUnitDisplayName(unitTag)
    if accountName and accountName ~= "" then
        return accountName
    end
    return GetUnitName(unitTag)
end

local function GetRosterKey(name)
    return name and string.lower(name) or nil
end

local function IsPlayerName(name)
    return GetRosterKey(name) == GetRosterKey(GetDisplayName("player"))
end

local function IsKnownDead(unitTag)
    if IsUnitDead then
        return IsUnitDead(unitTag)
    end
    return false
end

local function IsKnownOnline(unitTag)
    if IsUnitOnline then
        return IsUnitOnline(unitTag)
    end
    return true
end

local function IsEligibleSoakUnit(unitTag)
    return unitTag
        and DoesUnitExist(unitTag)
        and IsKnownOnline(unitTag)
        and not IsKnownDead(unitTag)
end

function OON.SetPlayerColor(color)
    color = NormalizeAssignment(color)
    if not color then
        Print("Use /oon color red, orange, purple, or none.")
        return nil
    end

    local name = GetDisplayName("player")
    local rosterKey = GetRosterKey(name)
    OON.playerColor = color
    OON.assignmentSources[rosterKey] = "manual"
    if color ~= "none" then
        OON.saved.preferredRoom = color
    end
    OON.saved.rosterColors[rosterKey] = nil
    Print(string.format("You are assigned to %s.", GetAssignmentLabel(color)))
    if OON.body and not OON.currentPlan then
        OON.body:SetText(GetReadyPrompt(color))
    end
    if OON.RefreshPersistentMarkers then
        OON.RefreshPersistentMarkers()
    end
    if OON.RefreshTeammateMarkers then
        OON.RefreshTeammateMarkers()
    end
    if OON.BroadcastColorAssignment then
        OON.BroadcastColorAssignment(name, color, "auto")
    end
    if OON.RefreshInfoWindowVisibility then
        OON.RefreshInfoWindowVisibility()
    end
    return color
end

function OON.SetRosterColor(displayName, color)
    color = NormalizeAssignment(color)
    if not displayName or displayName == "" or not color then
        Print("Use /oon assign @name red, orange, purple, or none.")
        return nil
    end

    local isPlayer = IsPlayerName(displayName)
    local rosterKey = GetRosterKey(displayName)
    OON.assignmentSources[rosterKey] = "manual"
    if isPlayer then
        OON.playerColor = color
        OON.saved.rosterColors[rosterKey] = nil
        if OON.body and not OON.currentPlan then
            OON.body:SetText(GetReadyPrompt(color))
        end
    else
        OON.saved.rosterColors[rosterKey] = color
    end
    Print(string.format("%s assigned to %s.", displayName, GetAssignmentLabel(color)))
    if OON.RefreshTeammateMarkers then
        OON.RefreshTeammateMarkers()
    end
    if isPlayer and OON.RefreshInfoWindowVisibility then
        OON.RefreshInfoWindowVisibility()
    end
    return color
end

function OON.SetRosterColorSilent(displayName, color, source)
    color = NormalizeAssignment(color)
    if not displayName or displayName == "" or not color then
        return nil
    end

    local isPlayer = IsPlayerName(displayName)
    local rosterKey = GetRosterKey(displayName)
    local currentColor = isPlayer and OON.playerColor or OON.saved.rosterColors[rosterKey]
    local currentSource = OON.assignmentSources[rosterKey]
    if source == "affinity"
        and currentColor
        and currentColor ~= "none"
        and currentSource
        and currentSource ~= "affinity"
    then
        return currentColor
    end

    OON.assignmentSources[rosterKey] = source or "automatic"
    if isPlayer then
        OON.playerColor = color
        OON.saved.rosterColors[rosterKey] = nil
        if OON.body and not OON.currentPlan then
            OON.body:SetText(GetReadyPrompt(color))
        end
    else
        OON.saved.rosterColors[rosterKey] = color
    end
    if OON.RefreshTeammateMarkers then
        OON.RefreshTeammateMarkers()
    end
    if isPlayer and OON.RefreshInfoWindowVisibility then
        OON.RefreshInfoWindowVisibility()
    end
    return color
end

function OON.GetAssignedColor(name)
    if not name then
        return nil
    end
    if IsPlayerName(name) then
        return OON.playerColor
    end
    if not OON.saved or not OON.saved.rosterColors then
        return "none"
    end
    return OON.saved.rosterColors[GetRosterKey(name)] or "none"
end

function OON.ClearPlayerColor()
    OON.playerColor = nil
    if OON.saved then
        OON.saved.playerColor = nil
        OON.saved.rosterColors = OON.saved.rosterColors or {}
        OON.saved.rosterColors[GetRosterKey(GetDisplayName("player"))] = nil
    end
    OON.assignmentSources[GetRosterKey(GetDisplayName("player"))] = nil
end

function OON.GetSoakCandidates(room)
    room = NormalizeColor(room)
    local candidates = {}
    local groupSize = GetGroupSize()

    if groupSize == 0 then
        if not IsEligibleSoakUnit("player") then
            return candidates
        end
        local role = GetUnitRole("player")
        local name = GetDisplayName("player")
        local assignedColor = OON.GetAssignedColor(name) or OON.playerColor
        if room and assignedColor ~= room then
            return candidates
        end
        candidates[#candidates + 1] = {
            unitTag = "player",
            name = name,
            role = role,
            color = assignedColor,
            score = GetRoleScore(role),
        }
        return candidates
    end

    for index = 1, groupSize do
        local unitTag = GetGroupUnitTagByIndex(index)
        if IsEligibleSoakUnit(unitTag) then
            local role = GetUnitRole(unitTag)
            local name = GetDisplayName(unitTag)
            local assignedColor = OON.GetAssignedColor(name)
            if not room or assignedColor == room then
                candidates[#candidates + 1] = {
                    unitTag = unitTag,
                    name = name,
                    role = role,
                    color = assignedColor,
                    score = GetRoleScore(role),
                    room = room,
                }
            end
        end
    end

    table.sort(candidates, function(left, right)
        if left.score == right.score then
            return left.name < right.name
        end
        return left.score < right.score
    end)

    return candidates
end

function OON.AssignSoaker(room)
    room = NormalizeColor(room)
    if not room then
        Print("Use /oon soak red, /oon soak orange, or /oon soak purple.")
        return nil
    end

    local candidates = OON.GetSoakCandidates(room)
    local selected = candidates[1]
    if selected then
        OON.saved.assignedSoaker = selected.name
        Print(string.format("%s soak: %s go hold block.", Capitalize(room), selected.name))
    else
        OON.saved.assignedSoaker = nil
        Print("No soak candidate found.")
    end
    return selected
end

function OON.AssignDualSoaks(room, durationMs)
    room = NormalizeColor(room)
    if not room then
        Print("Use /oon doublesoak red, /oon doublesoak orange, or /oon doublesoak purple.")
        return nil
    end

    local candidates = OON.GetSoakCandidates(room)
    local left = candidates[1]
    local right = candidates[2]

    OON.saved.assignedSoaks = OON.saved.assignedSoaks or {}
    OON.saved.assignedSoaks[room] = {
        left = left and left.name or nil,
        right = right and right.name or nil,
    }

    if left and right then
        Print(string.format("%s dual soak: LEFT %s, RIGHT %s. Both hold block.", Capitalize(room), left.name, right.name))
    elseif left then
        Print(string.format("%s dual soak: only %s found. Need one more assigned %s player.", Capitalize(room), left.name, Capitalize(room)))
    else
        Print(string.format("%s dual soak: no assigned players found.", Capitalize(room)))
    end

    OON.ShowRaidLeadDualSoak(room, left, right, durationMs)
    local side
    if left and IsPlayerName(left.name) then
        side = "left"
    elseif right and IsPlayerName(right.name) then
        side = "right"
    end

    if side then
        local markerData = OON.SOAK_MARKERS and OON.SOAK_MARKERS[room]
        local markerId = markerData and markerData[side]
        OON.ShowTemporarySoakMarker(markerId)
        OON.ShowPersonalSoakWarning(
            string.format("%s SOAK - %s - HOLD BLOCK", OON.ROOMS[room].label, string.upper(side)),
            durationMs
        )
    end

    return left, right
end

function OON.AssignSoloSoak(room, durationMs, source)
    room = NormalizeColor(room)
    if not room then
        return nil
    end

    local now = GetGameTimeMilliseconds()
    OON.lastSoloSoakAt = OON.lastSoloSoakAt or {}
    if OON.lastSoloSoakAt[room] and now - OON.lastSoloSoakAt[room] < 1500 then
        return nil
    end
    OON.lastSoloSoakAt[room] = now

    local selected = OON.AssignSoaker(room)
    OON.ShowRaidLeadSoloSoak(room, selected, durationMs)
    if selected and IsPlayerName(selected.name) then
        local markerData = OON.SOAK_MARKERS and OON.SOAK_MARKERS[room]
        OON.ShowTemporarySoakMarker(markerData and markerData.single)
        OON.ShowPersonalSoakWarning(string.format("%s SOAK - HOLD BLOCK", OON.ROOMS[room].label), durationMs)
    end

    return selected
end

function OON.HideTemporarySoakMarker()
    if OON.activeTemporarySoakMarkerId and OON.SetMarkerVisible then
        OON.SetMarkerVisible(OON.activeTemporarySoakMarkerId, false, false)
    end
    OON.activeTemporarySoakMarkerId = nil
end

function OON.ShowTemporarySoakMarker(markerId)
    if not markerId then
        return
    end

    OON.HideTemporarySoakMarker()
    OON.activeTemporarySoakMarkerId = markerId
    if OON.SetMarkerVisible then
        OON.SetMarkerVisible(markerId, true, true, false, true)
    end
end

local function EnsureSoakWarningWindow()
    if OON.soakWarningWindow then
        return
    end

    local wm = WINDOW_MANAGER
    local window = wm:CreateTopLevelWindow("OpulentOrdealNavigatorSoakWarning")
    window:SetDimensions(560, 155)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, -190)
    window:SetHidden(true)

    local bg = wm:CreateControl(nil, window, CT_BACKDROP)
    bg:SetAnchorFill(window)
    bg:SetCenterColor(0.08, 0.02, 0.02, 0.92)
    bg:SetEdgeColor(1, 0.08, 0.04, 1)
    bg:SetEdgeTexture(nil, 4, 4, 4)

    local title = wm:CreateControl(nil, window, CT_LABEL)
    title:SetAnchor(TOP, window, TOP, 0, 18)
    title:SetDimensions(530, 45)
    title:SetFont("ZoFontWinH1")
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    local countdown = wm:CreateControl(nil, window, CT_LABEL)
    countdown:SetAnchor(TOP, title, BOTTOM, 0, 6)
    countdown:SetDimensions(530, 54)
    countdown:SetFont("ZoFontAnnounceLarge")
    countdown:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    OON.soakWarningWindow = window
    OON.soakWarningTitle = title
    OON.soakWarningCountdown = countdown
end

function OON.ShowPersonalSoakWarning(title, durationMs)
    durationMs = durationMs or 6000
    EnsureSoakWarningWindow()

    OON.soakWarningEndsAt = GetGameTimeMilliseconds() + durationMs
    OON.soakWarningTitle:SetText(title)
    OON.soakWarningWindow:SetHidden(false)

    EVENT_MANAGER:UnregisterForUpdate(SOAK_WARNING_UPDATE)
    EVENT_MANAGER:RegisterForUpdate(SOAK_WARNING_UPDATE, 100, function()
        local remainingMs = (OON.soakWarningEndsAt or 0) - GetGameTimeMilliseconds()
        if remainingMs <= 0 then
            EVENT_MANAGER:UnregisterForUpdate(SOAK_WARNING_UPDATE)
            OON.soakWarningWindow:SetHidden(true)
            OON.HideTemporarySoakMarker()
            return
        end

        OON.soakWarningCountdown:SetText(string.format("%.1f", remainingMs / 1000))
    end)
end

function OON.HidePersonalSoakWarning()
    EVENT_MANAGER:UnregisterForUpdate(SOAK_WARNING_UPDATE)
    if OON.soakWarningWindow then
        OON.soakWarningWindow:SetHidden(true)
    end
    if OON.HideTemporarySoakMarker then
        OON.HideTemporarySoakMarker()
    end
end

local function EnsureLampTimerWindow()
    if OON.lampTimerWindow then
        return
    end

    local wm = WINDOW_MANAGER
    local window = wm:CreateTopLevelWindow("OpulentOrdealNavigatorLampTimer")
    window:SetDimensions(300, 90)
    local lampTimer = OON.saved and OON.saved.lampTimer or nil
    if lampTimer and lampTimer.left ~= nil and lampTimer.top ~= nil then
        window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, lampTimer.left, lampTimer.top)
    else
        window:SetAnchor(RIGHT, GuiRoot, RIGHT, -80, 170)
    end
    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetClampedToScreen(true)
    window:SetHidden(true)
    window:SetHandler("OnMoveStop", function(control)
        if not OON.saved then
            return
        end
        OON.saved.lampTimer = OON.saved.lampTimer or {}
        OON.saved.lampTimer.left = control:GetLeft()
        OON.saved.lampTimer.top = control:GetTop()
    end)

    local bg = wm:CreateControl(nil, window, CT_BACKDROP)
    bg:SetAnchorFill(window)
    bg:SetCenterColor(0.035, 0.02, 0.055, 0.92)
    bg:SetEdgeColor(0.72, 0.34, 1, 1)
    bg:SetEdgeTexture(nil, 2, 2, 2)

    local label = wm:CreateControl(nil, window, CT_LABEL)
    label:SetAnchor(TOP, window, TOP, 0, 8)
    label:SetDimensions(280, 28)
    label:SetFont("ZoFontWinH3")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetText("PURPLE LAMP BUFF")

    local countdown = wm:CreateControl(nil, window, CT_LABEL)
    countdown:SetAnchor(TOP, label, BOTTOM, 0, 0)
    countdown:SetDimensions(280, 42)
    countdown:SetFont("ZoFontAnnounceLarge")
    countdown:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    OON.lampTimerWindow = window
    OON.lampTimerCountdown = countdown
end

function OON.HideLampBuffTimer()
    EVENT_MANAGER:UnregisterForUpdate(LAMP_TIMER_UPDATE)
    OON.lampTimerEndsAt = nil
    if OON.lampTimerWindow then
        OON.lampTimerWindow:SetHidden(true)
    end
end

function OON.ShowLampBuffTimer(endTime)
    endTime = tonumber(endTime)
    if not endTime or endTime <= GetFrameTimeSeconds() then
        OON.HideLampBuffTimer()
        return
    end

    EnsureLampTimerWindow()
    OON.lampTimerEndsAt = endTime
    OON.lampTimerWindow:SetHidden(false)

    EVENT_MANAGER:UnregisterForUpdate(LAMP_TIMER_UPDATE)
    EVENT_MANAGER:RegisterForUpdate(LAMP_TIMER_UPDATE, 100, function()
        local remaining = (OON.lampTimerEndsAt or 0) - GetFrameTimeSeconds()
        if remaining <= 0 then
            OON.HideLampBuffTimer()
            return
        end
        OON.lampTimerCountdown:SetText(string.format("%.1f", remaining))
    end)
end

function OON.TestLampBuffTimer(durationSeconds)
    durationSeconds = tonumber(durationSeconds) or 15
    OON.ShowLampBuffTimer(GetFrameTimeSeconds() + durationSeconds)
    Print(string.format("Testing purple lamp buff timer for %d seconds.", durationSeconds))
end

local function EnsureRaidLeadSoakWindow()
    if OON.raidLeadSoakWindow then
        return
    end

    local wm = WINDOW_MANAGER
    local window = wm:CreateTopLevelWindow("OpulentOrdealNavigatorRaidLeadSoakWindow")
    window:SetDimensions(620, 220)
    window:SetAnchor(RIGHT, GuiRoot, RIGHT, -80, -80)
    window:SetHidden(true)

    local bg = wm:CreateControl(nil, window, CT_BACKDROP)
    bg:SetAnchorFill(window)
    bg:SetCenterColor(0.025, 0.025, 0.025, 0.94)
    bg:SetEdgeColor(1, 0.48, 0.08, 1)
    bg:SetEdgeTexture(nil, 2, 2, 2)

    local title = wm:CreateControl(nil, window, CT_LABEL)
    title:SetAnchor(TOP, window, TOP, 0, 14)
    title:SetDimensions(590, 38)
    title:SetFont("ZoFontWinH2")
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    local assignments = wm:CreateControl(nil, window, CT_LABEL)
    assignments:SetAnchor(TOP, title, BOTTOM, 0, 4)
    assignments:SetDimensions(590, 105)
    assignments:SetFont("ZoFontWinH3")
    assignments:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    assignments:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local countdown = wm:CreateControl(nil, window, CT_LABEL)
    countdown:SetAnchor(BOTTOM, window, BOTTOM, 0, -12)
    countdown:SetDimensions(590, 42)
    countdown:SetFont("ZoFontAnnounceLarge")
    countdown:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    OON.raidLeadSoakWindow = window
    OON.raidLeadSoakTitle = title
    OON.raidLeadSoakAssignments = assignments
    OON.raidLeadSoakCountdown = countdown
end

function OON.IsRaidLeadModeEnabled()
    return OON.saved
        and OON.saved.raidLead
        and OON.saved.raidLead.enabled == true
end

function OON.HideRaidLeadSoakWindow()
    EVENT_MANAGER:UnregisterForUpdate(RAID_LEAD_SOAK_UPDATE)
    OON.raidLeadSoloAssignments = nil
    if OON.raidLeadSoakWindow then
        OON.raidLeadSoakWindow:SetHidden(true)
    end
end

function OON.SetRaidLeadModeEnabled(enabled)
    OON.saved.raidLead = OON.saved.raidLead or {}
    OON.saved.raidLead.enabled = enabled == true
    if not OON.saved.raidLead.enabled then
        OON.HideRaidLeadSoakWindow()
    end
    Print(string.format("Raid lead soak display %s.", OON.saved.raidLead.enabled and "enabled" or "disabled"))
end

local function ShowRaidLeadSoakWindow(title, assignments, durationMs)
    if not OON.IsRaidLeadModeEnabled() then
        return
    end

    durationMs = durationMs or 6000
    EnsureRaidLeadSoakWindow()

    OON.raidLeadSoakEndsAt = GetGameTimeMilliseconds() + durationMs
    OON.raidLeadSoakTitle:SetText(title)
    OON.raidLeadSoakAssignments:SetText(assignments)
    OON.raidLeadSoakCountdown:SetText(string.format("%.1f", durationMs / 1000))
    OON.raidLeadSoakWindow:SetHidden(false)

    EVENT_MANAGER:UnregisterForUpdate(RAID_LEAD_SOAK_UPDATE)
    EVENT_MANAGER:RegisterForUpdate(RAID_LEAD_SOAK_UPDATE, 100, function()
        local remainingMs = (OON.raidLeadSoakEndsAt or 0) - GetGameTimeMilliseconds()
        if remainingMs <= 0 then
            OON.HideRaidLeadSoakWindow()
            return
        end
        OON.raidLeadSoakCountdown:SetText(string.format("%.1f", remainingMs / 1000))
    end)
end

function OON.ShowRaidLeadSoloSoak(room, selected, durationMs)
    if not OON.IsRaidLeadModeEnabled() then
        return
    end

    local now = GetGameTimeMilliseconds()
    if not OON.raidLeadSoloAssignments or now >= (OON.raidLeadSoakEndsAt or 0) then
        OON.raidLeadSoloAssignments = {}
    end
    OON.raidLeadSoloAssignments[room] = selected and selected.name or "UNASSIGNED"

    local lines = {}
    for _, color in ipairs({ "red", "orange", "purple" }) do
        local name = OON.raidLeadSoloAssignments[color]
        if name then
            lines[#lines + 1] = string.format("%s: %s", string.upper(color), name)
        end
    end
    lines[#lines + 1] = "Selected players: go to your soak and hold block."

    ShowRaidLeadSoakWindow(
        #lines > 2 and "SOLO SOAK ASSIGNMENTS" or string.format("%s - SOLO SOAK", OON.ROOMS[room].label),
        table.concat(lines, "\n"),
        durationMs
    )
end

function OON.ShowRaidLeadDualSoak(room, left, right, durationMs)
    OON.raidLeadSoloAssignments = nil
    local leftName = left and left.name or "UNASSIGNED"
    local rightName = right and right.name or "UNASSIGNED"
    ShowRaidLeadSoakWindow(
        string.format("%s - DUAL SOAK", OON.ROOMS[room].label),
        string.format("LEFT: %s\nRIGHT: %s\nGo to your side and hold block.", leftName, rightName),
        durationMs
    )
end

function OON.ClearRouteState(reason, silent)
    OON.currentPlan = nil
    OON.pendingEssenceColor = nil

    if OON.HidePersonalSoakWarning then
        OON.HidePersonalSoakWarning()
    end
    if OON.HideRaidLeadSoakWindow then
        OON.HideRaidLeadSoakWindow()
    end
    if OON.HideAnimatedPath then
        OON.HideAnimatedPath()
    end
    if OON.HideAllMarkers then
        OON.HideAllMarkers(false)
    end
    if OON.RefreshPersistentMarkers then
        OON.RefreshPersistentMarkers()
    end

    if OON.body then
        if OON.playerColor then
            OON.body:SetText(GetReadyPrompt(OON.playerColor))
        else
            OON.body:SetText(GetNonePrompt())
        end
    end
    if not silent then
        Print(reason or "Route cleared.")
    end
end

function OON.HandleSoakCall(room, durationMs, isDualCall)
    room = NormalizeColor(room)
    if not room then
        return
    end

    if isDualCall == true or (isDualCall == nil and (OON.saved.encounterPhase or 1) >= 2) then
        OON.AssignDualSoaks(room, durationMs)
        return
    end

    OON.AssignSoloSoak(room, durationMs, "combat")
end

function OON.ShowSoloSoakSoon(rooms)
    local upcoming = {}
    local playerIncluded = false

    for _, room in ipairs(rooms or {}) do
        room = NormalizeColor(room)
        if room then
            upcoming[#upcoming + 1] = OON.ROOMS[room].label
            if OON.playerColor == room then
                playerIncluded = true
            end
        end
    end

    if #upcoming == 0 then
        return
    end

    local roomText = table.concat(upcoming, ", ")
    if OON.body then
        if playerIncluded then
            OON.body:SetText(string.format(
                "Solo soak soon for %s.\nWait for your assignment.",
                roomText
            ))
        else
            OON.body:SetText(string.format(
                "Solo soak soon for %s.\nContinue your current role.",
                roomText
            ))
        end
    end

    Print(string.format("Solo soak soon: %s. Assignment starts when the bomb appears.", roomText))
end

function OON.HandleOrbSoakSequence(rooms)
    OON.ShowSoloSoakSoon(rooms)
end

function OON.BuildRosterText()
    local lines = {}
    local groupSize = GetGroupSize()

    if groupSize == 0 then
        local name = GetDisplayName("player")
        lines[#lines + 1] = string.format("%s: %s", name, GetAssignmentLabel(OON.GetAssignedColor(name) or OON.playerColor or "none"))
        return table.concat(lines, "\n")
    end

    for index = 1, groupSize do
        local unitTag = GetGroupUnitTagByIndex(index)
        if unitTag and DoesUnitExist(unitTag) then
            local name = GetDisplayName(unitTag)
            local role = GetUnitRole(unitTag)
            local color = OON.GetAssignedColor(name) or "none"
            lines[#lines + 1] = string.format("%s: %s (%s)", name, GetAssignmentLabel(color), GetRoleName(role))
        end
    end

    table.sort(lines)
    return table.concat(lines, "\n")
end

local function EnsureWindow()
    if OON.window then
        return
    end

    local wm = WINDOW_MANAGER
    local window = wm:CreateTopLevelWindow("OpulentOrdealNavigatorWindow")
    window:SetDimensions(460, 205)
    local infoWindow = OON.saved and OON.saved.infoWindow or nil
    if infoWindow and infoWindow.left ~= nil and infoWindow.top ~= nil then
        window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, infoWindow.left, infoWindow.top)
    else
        window:SetAnchor(TOP, GuiRoot, TOP, 0, 80)
    end
    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetClampedToScreen(true)
    window:SetHidden(true)
    window:SetHandler("OnMoveStop", function(control)
        if not OON.saved then
            return
        end
        OON.saved.infoWindow = OON.saved.infoWindow or {}
        OON.saved.infoWindow.left = control:GetLeft()
        OON.saved.infoWindow.top = control:GetTop()
    end)

    local bg = wm:CreateControl(nil, window, CT_BACKDROP)
    bg:SetAnchorFill(window)
    bg:SetCenterColor(0.03, 0.03, 0.03, 0.82)
    bg:SetEdgeColor(1, 0.48, 0.08, 0.95)
    bg:SetEdgeTexture(nil, 2, 2, 2)

    local title = wm:CreateControl(nil, window, CT_LABEL)
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 14, 12)
    title:SetFont("ZoFontWinH3")
    title:SetText("Opulent Ordeal Navigator")

    local body = wm:CreateControl(nil, window, CT_LABEL)
    body:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 12)
    body:SetDimensions(430, 150)
    body:SetFont("ZoFontGame")
    body:SetVerticalAlignment(TEXT_ALIGN_TOP)
    body:SetText("Choose your assignment.")

    OON.window = window
    OON.body = body
end

local function HideWindow()
    if OON.window then
        OON.window:SetHidden(true)
    end
end

local function ShouldShowInfoWindow()
    if not OON.IsActive() then
        return false
    end
    return OON.saved.infoWindow.enabled ~= false
end

local function ShowWindow(force)
    EnsureWindow()
    OON.window:SetHidden(not force and not ShouldShowInfoWindow())
end

function OON.RefreshInfoWindowVisibility()
    if not OON.IsActive() then
        HideWindow()
        return
    end
    ShowWindow()
end

function OON.SetInfoWindowEnabled(enabled)
    OON.saved.infoWindow = OON.saved.infoWindow or {}
    OON.saved.infoWindow.enabled = enabled == true
    if OON.body and not OON.currentPlan then
        OON.body:SetText(GetReadyPrompt(OON.playerColor or "none"))
    end
    OON.RefreshInfoWindowVisibility()

    Print(string.format("Info box %s.", enabled and "enabled" or "disabled"))
end

local function ShowPlan(plan)
    ShowWindow()

    local actions = {}
    local seen = {}
    local function AddAction(text)
        if text and text ~= "" and not seen[text] then
            seen[text] = true
            actions[#actions + 1] = text
        end
    end

    if plan.task == "automated_route_profile" or plan.task == "automated_m0r_profile" then
        for _, step in ipairs(plan.steps or {}) do
            AddAction(step)
        end
    elseif plan.teamTasks and OON.playerColor and plan.teamTasks[OON.playerColor] then
        for index, room in ipairs(plan.route or {}) do
            if room == OON.playerColor then
                AddAction(plan.steps and plan.steps[index])
                break
            end
        end
    else
        for _, step in ipairs(plan.steps or {}) do
            AddAction(step)
        end
    end

    if plan.teamTasks and OON.playerColor and plan.teamTasks[OON.playerColor] then
        local task = plan.teamTasks[OON.playerColor]
        for _, segment in ipairs(task.pathSegments or {}) do
            AddAction(segment.instruction)
        end
    end

    if plan.pathSegments and #plan.pathSegments > 0 then
        AddAction("Follow the highlighted markers.")
    end

    OON.body:SetText(table.concat(actions, "\n"))
end

OON.ShowPlan = ShowPlan

function OON.StartManualRoute(orbColor, spawnRoom)
    orbColor = NormalizeColor(orbColor)
    spawnRoom = NormalizeColor(spawnRoom)
    local plan, err = OON.BuildActionPlan(orbColor, spawnRoom)
    if not plan then
        Print(err)
        return
    end

    OON.currentPlan = plan
    ShowPlan(plan)
    OON.AnimatePlanPath(plan, OON.playerColor)
    Print(string.format("%s orb: %s", Capitalize(orbColor), table.concat(plan.route, " > ")))
end

function OON.StartReturnPath(origin)
    local plan, err = OON.BuildReturnPlan(OON.playerColor, origin)
    if not plan then
        Print(err)
        return
    end

    OON.currentPlan = plan
    EnsureWindow()
    OON.body:SetText(table.concat(plan.steps, "\n"))
    OON.AnimatePlanPath(plan, OON.playerColor)
    Print(plan.steps[1])
end

function OON.StartTestPath()
    local teamColor = OON.playerColor or "red"
    local plan = {
        task = "test_middle_path",
        route = { "red", "center" },
        steps = { "Follow the markers from the Red joined area to the center." },
        pathSegments = OON.BuildPathSegments({ "red_join_to_middle" }, teamColor, teamColor, "center"),
    }

    OON.currentPlan = plan
    EnsureWindow()
    OON.body:SetText(table.concat(plan.steps, "\n"))
    OON.AnimatePlanPath(plan, teamColor)
    Print(plan.steps[1])
end

function OON.BuildRouteProfilePlan(profileKey)
    profileKey = profileKey and string.lower(profileKey) or nil
    local profile = profileKey and OON.M0R_ROUTE_PROFILES and OON.M0R_ROUTE_PROFILES[profileKey]
    if not profile then
        return nil
    end

    local markerIds = {}
    for _, marker in ipairs(profile.markers or {}) do
        markerIds[#markerIds + 1] = marker.id
    end

    local owner = OON.playerColor or "imported"
    return {
        task = "route_profile",
        route = { owner },
        steps = { "Follow the displayed route markers." },
        pathSegments = {
            {
                id = "route_profile_" .. profileKey,
                owner = owner,
                from = owner,
                to = owner,
                purpose = "route_profile",
                markers = markerIds,
            },
        },
    }
end

OON.BuildM0RProfilePlan = OON.BuildRouteProfilePlan

function OON.StartRouteProfile(profileKey)
    local plan = OON.BuildRouteProfilePlan(profileKey)
    if not plan then
        Print("Unknown route profile key. Use /oon profiles.")
        return
    end

    OON.currentPlan = plan
    EnsureWindow()
    OON.body:SetText(table.concat(plan.steps, "\n"))
    OON.AnimatePlanPath(plan, OON.playerColor or "imported")
    Print(plan.steps[1])
end

OON.StartM0RProfile = OON.StartRouteProfile

local function ParseOnOff(value)
    value = value and string.lower(value) or nil
    if value == "on" or value == "true" or value == "1" then
        return true
    end
    if value == "off" or value == "false" or value == "0" then
        return false
    end
    return nil
end

function OON.IsDebugEnabled()
    return OON.saved and OON.saved.debug == true
end

function OON.SetDebugEnabled(enabled)
    OON.saved.debug = enabled == true
    Print(string.format("Debug commands %s.", OON.saved.debug and "enabled" or "disabled"))
end

function OON.SetRouteDisplayMode(mode)
    mode = mode and string.lower(mode) or "full"
    OON.saved.pathAnimation = OON.saved.pathAnimation or {}
    if mode == "proximity" or mode == "window" then
        OON.saved.pathAnimation.enabled = true
        OON.saved.pathAnimation.showFullPath = false
    else
        OON.saved.pathAnimation.enabled = false
        OON.saved.pathAnimation.showFullPath = true
        mode = "full"
    end

    if OON.RefreshPathRendering then
        OON.RefreshPathRendering()
    end

    if mode == "proximity" then
        Print("Route display mode: proximity full route.")
    else
        Print("Route display mode: full route.")
    end
end

function OON.SetProximityGuidanceEnabled(enabled)
    OON.SetRouteDisplayMode(enabled and "proximity" or "full")
end

function OON.SetFullRouteVisible(enabled)
    OON.SetRouteDisplayMode(enabled and "full" or "proximity")
end

function OON.SetProximityRadius(radius)
    radius = tonumber(radius)
    if not radius or radius < 50 then
        Print("Use /oon proximity <radius>. Example: /oon proximity 250.")
        return
    end

    OON.saved.pathAnimation = OON.saved.pathAnimation or {}
    OON.saved.pathAnimation.proximityRadius = radius

    if OON.RefreshPathRendering then
        OON.RefreshPathRendering()
    end

    Print(string.format("Proximity radius set to %d.", radius))
end

function OON.SetRouteLinesEnabled(enabled)
    OON.saved.pathAnimation = OON.saved.pathAnimation or {}
    OON.saved.pathAnimation.showRouteLines = enabled == true
    if OON.RefreshPathRendering then
        OON.RefreshPathRendering()
    end
    Print(OON.saved.pathAnimation.showRouteLines and "Route lines enabled." or "Route lines disabled.")
end

function OON.SetEncounterPhase(phase, reason)
    phase = tonumber(phase) or 1
    if phase < 2 then
        phase = 1
    else
        phase = 2
    end

    OON.saved.encounterPhase = phase
    if OON.RefreshPersistentMarkers then
        OON.RefreshPersistentMarkers()
    end
    if reason then
        Print(reason)
    end
end

local function RegisterSettingsPanel()
    if OON.settingsPanelRegistered or not LibAddonMenu2 then
        return
    end

    local LAM = LibAddonMenu2
    local panelName = ADDON_NAME .. "SettingsPanel"
    LAM:RegisterAddonPanel(panelName, {
        type = "panel",
        name = "Opulent Ordeal Navigator",
        displayName = "Opulent Ordeal Navigator",
        author = "Opulent Ordeal Navigator Team",
        version = "0.1.0",
        registerForRefresh = true,
        registerForDefaults = true,
    })

    LAM:RegisterOptionControls(panelName, {
        {
            type = "description",
            title = "Credits",
            text = "Route source data was seeded from MoreMarkers by Mor exports. Mechanic references were cross-checked against CrutchAlerts and Code's Combat Alerts. This addon bundles its own marker assets and does not require those addons at runtime.",
        },
        {
            type = "checkbox",
            name = "Show information box",
            tooltip = "Show the movable action panel. With no detected affinity, it tells the player to stay in the center.",
            getFunc = function()
                OON.saved.infoWindow = OON.saved.infoWindow or {}
                return OON.saved.infoWindow.enabled ~= false
            end,
            setFunc = function(value)
                OON.SetInfoWindowEnabled(value)
            end,
            default = DEFAULTS.infoWindow.enabled,
        },
        {
            type = "checkbox",
            name = "Raid lead soak display",
            tooltip = "Show the selected solo soaker or the left and right dual soakers on screen. World markers remain personal to assigned soakers.",
            getFunc = function()
                return OON.IsRaidLeadModeEnabled()
            end,
            setFunc = function(value)
                OON.SetRaidLeadModeEnabled(value)
            end,
            default = DEFAULTS.raidLead.enabled,
        },
        {
            type = "checkbox",
            name = "Enable debug commands",
            tooltip = "Allow manual route, soak, marker, profile, phase, lamp, and path-testing commands.",
            getFunc = function()
                return OON.saved.debug == true
            end,
            setFunc = function(value)
                OON.SetDebugEnabled(value)
            end,
            default = DEFAULTS.debug,
        },
        {
            type = "checkbox",
            name = "Proximity route mode",
            tooltip = "Show the full route while proximity advances the active white segment.",
            getFunc = function()
                OON.saved.pathAnimation = OON.saved.pathAnimation or {}
                return OON.saved.pathAnimation.enabled == true and OON.saved.pathAnimation.showFullPath == false
            end,
            setFunc = function(value)
                OON.SetRouteDisplayMode(value and "proximity" or "full")
            end,
            default = DEFAULTS.pathAnimation.enabled,
        },
        {
            type = "slider",
            name = "Proximity radius",
            tooltip = "Distance from the current route marker needed to advance to the next marker.",
            min = 50,
            max = 1000,
            step = 25,
            getFunc = function()
                OON.saved.pathAnimation = OON.saved.pathAnimation or {}
                return OON.saved.pathAnimation.proximityRadius or DEFAULTS.pathAnimation.proximityRadius
            end,
            setFunc = function(value)
                OON.SetProximityRadius(value)
            end,
            default = DEFAULTS.pathAnimation.proximityRadius,
        },
        {
            type = "checkbox",
            name = "Show route lines",
            tooltip = "Draw colored connections between consecutive visible route markers.",
            getFunc = function()
                return OON.saved.pathAnimation.showRouteLines ~= false
            end,
            setFunc = OON.SetRouteLinesEnabled,
            default = DEFAULTS.pathAnimation.showRouteLines,
        },
        {
            type = "checkbox",
            name = "Show Eclipse lamp markers",
            tooltip = "Show the persistent lamp markers for players assigned to Purple/Eclipse.",
            getFunc = function()
                OON.saved.persistentMarkers = OON.saved.persistentMarkers or {}
                return OON.saved.persistentMarkers.showEclipseLamps ~= false
            end,
            setFunc = function(value)
                OON.saved.persistentMarkers = OON.saved.persistentMarkers or {}
                OON.saved.persistentMarkers.showEclipseLamps = value == true
                if OON.RefreshPersistentMarkers then
                    OON.RefreshPersistentMarkers()
                end
            end,
            default = DEFAULTS.persistentMarkers.showEclipseLamps,
        },
        {
            type = "checkbox",
            name = "Show phase 2 tank markers",
            tooltip = "Show boss tank positions once the addon has detected phase 2.",
            getFunc = function()
                OON.saved.persistentMarkers = OON.saved.persistentMarkers or {}
                return OON.saved.persistentMarkers.showPhase2TankMarkers ~= false
            end,
            setFunc = function(value)
                OON.saved.persistentMarkers = OON.saved.persistentMarkers or {}
                OON.saved.persistentMarkers.showPhase2TankMarkers = value == true
                if OON.RefreshPersistentMarkers then
                    OON.RefreshPersistentMarkers()
                end
            end,
            default = DEFAULTS.persistentMarkers.showPhase2TankMarkers,
        },
        {
            type = "checkbox",
            name = "Show teammate color markers",
            tooltip = "Show Red/Orange/Purple shape icons above assigned teammates.",
            getFunc = function()
                OON.saved.teammateMarkers = OON.saved.teammateMarkers or {}
                return OON.saved.teammateMarkers.enabled ~= false
            end,
            setFunc = function(value)
                if OON.SetTeammateMarkersEnabled then
                    OON.SetTeammateMarkersEnabled(value)
                end
            end,
            default = DEFAULTS.teammateMarkers.enabled,
        },
        {
            type = "checkbox",
            name = "Color sync test",
            tooltip = "Listen for OON color packets in party chat. Use /oon share to prepare your own packet; ESO requires you to submit it manually.",
            getFunc = function()
                OON.saved.colorSync = OON.saved.colorSync or {}
                return OON.saved.colorSync.enabled == true
            end,
            setFunc = function(value)
                if OON.SetColorSyncEnabled then
                    OON.SetColorSyncEnabled(value)
                end
            end,
            default = DEFAULTS.colorSync.enabled,
        },
    })

    OON.settingsPanelRegistered = true
end

local function EnsureStandaloneSettingsWindow()
    if OON.standaloneSettingsWindow then
        return
    end

    local wm = WINDOW_MANAGER
    local window = wm:CreateTopLevelWindow("OpulentOrdealNavigatorStandaloneSettings")
    window:SetDimensions(520, 470)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetClampedToScreen(true)
    window:SetHidden(true)

    local bg = wm:CreateControl(nil, window, CT_BACKDROP)
    bg:SetAnchorFill(window)
    bg:SetCenterColor(0.025, 0.025, 0.025, 0.96)
    bg:SetEdgeColor(1, 0.48, 0.08, 1)
    bg:SetEdgeTexture(nil, 2, 2, 2)

    local title = wm:CreateControl(nil, window, CT_LABEL)
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 16, 12)
    title:SetFont("ZoFontWinH2")
    title:SetText("Opulent Ordeal Navigator Settings")

    local close = wm:CreateControl(nil, window, CT_BUTTON)
    close:SetAnchor(TOPRIGHT, window, TOPRIGHT, -12, 10)
    close:SetDimensions(34, 34)
    close:SetFont("ZoFontWinH3")
    close:SetText("X")
    close:SetHandler("OnClicked", function()
        window:SetHidden(true)
    end)

    local rows = {}
    local function AddToggleRow(labelText, getter, setter)
        local button = wm:CreateControl(nil, window, CT_BUTTON)
        button:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 58 + (#rows * 38))
        button:SetDimensions(480, 32)
        button:SetFont("ZoFontGame")
        button:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        button:SetHandler("OnClicked", function()
            setter(not getter())
            OON.RefreshStandaloneSettingsWindow()
        end)
        rows[#rows + 1] = {
            button = button,
            label = labelText,
            getter = getter,
        }
    end

    AddToggleRow("Show information box", function()
        return OON.saved.infoWindow.enabled ~= false
    end, OON.SetInfoWindowEnabled)
    AddToggleRow("Raid lead soak display", OON.IsRaidLeadModeEnabled, OON.SetRaidLeadModeEnabled)
    AddToggleRow("Enable debug commands", OON.IsDebugEnabled, OON.SetDebugEnabled)
    AddToggleRow("Proximity route mode", function()
        return OON.saved.pathAnimation.enabled == true
    end, OON.SetProximityGuidanceEnabled)
    AddToggleRow("Show route lines", function()
        return OON.saved.pathAnimation.showRouteLines ~= false
    end, OON.SetRouteLinesEnabled)
    AddToggleRow("Show Eclipse lamp markers", function()
        return OON.saved.persistentMarkers.showEclipseLamps ~= false
    end, function(value)
        OON.saved.persistentMarkers.showEclipseLamps = value == true
        OON.RefreshPersistentMarkers()
    end)
    AddToggleRow("Show phase 2 tank markers", function()
        return OON.saved.persistentMarkers.showPhase2TankMarkers ~= false
    end, function(value)
        OON.saved.persistentMarkers.showPhase2TankMarkers = value == true
        OON.RefreshPersistentMarkers()
    end)
    AddToggleRow("Show teammate color markers", function()
        return OON.saved.teammateMarkers.enabled ~= false
    end, OON.SetTeammateMarkersEnabled)
    AddToggleRow("Color sync", function()
        return OON.saved.colorSync.enabled == true
    end, OON.SetColorSyncEnabled)

    local radiusLabel = wm:CreateControl(nil, window, CT_LABEL)
    radiusLabel:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 18, -16)
    radiusLabel:SetDimensions(300, 32)
    radiusLabel:SetFont("ZoFontGame")

    local minus = wm:CreateControl(nil, window, CT_BUTTON)
    minus:SetAnchor(LEFT, radiusLabel, RIGHT, 12, 0)
    minus:SetDimensions(48, 32)
    minus:SetFont("ZoFontWinH3")
    minus:SetText("-")
    minus:SetHandler("OnClicked", function()
        OON.SetProximityRadius(math.max(50, (OON.saved.pathAnimation.proximityRadius or 250) - 25))
        OON.RefreshStandaloneSettingsWindow()
    end)

    local plus = wm:CreateControl(nil, window, CT_BUTTON)
    plus:SetAnchor(LEFT, minus, RIGHT, 8, 0)
    plus:SetDimensions(48, 32)
    plus:SetFont("ZoFontWinH3")
    plus:SetText("+")
    plus:SetHandler("OnClicked", function()
        OON.SetProximityRadius(math.min(1000, (OON.saved.pathAnimation.proximityRadius or 250) + 25))
        OON.RefreshStandaloneSettingsWindow()
    end)

    OON.standaloneSettingsWindow = window
    OON.standaloneSettingsRows = rows
    OON.standaloneSettingsRadiusLabel = radiusLabel
end

function OON.RefreshStandaloneSettingsWindow()
    for _, row in ipairs(OON.standaloneSettingsRows or {}) do
        row.button:SetText(string.format("[%s] %s", row.getter() and "X" or " ", row.label))
    end
    if OON.standaloneSettingsRadiusLabel then
        OON.standaloneSettingsRadiusLabel:SetText(string.format(
            "Proximity radius: %d",
            OON.saved.pathAnimation.proximityRadius or DEFAULTS.pathAnimation.proximityRadius
        ))
    end
end

function OON.ToggleStandaloneSettingsWindow()
    EnsureStandaloneSettingsWindow()
    OON.RefreshStandaloneSettingsWindow()
    OON.standaloneSettingsWindow:SetHidden(not OON.standaloneSettingsWindow:IsHidden())
end

function OON.BuildRouteProfileList()
    local lines = {}
    for profileKey, profile in pairs(OON.M0R_ROUTE_PROFILES or {}) do
        lines[#lines + 1] = string.format("%s: %s (%d)", profileKey, profile.profileName, #(profile.markers or {}))
    end
    table.sort(lines)
    return table.concat(lines, "\n")
end

OON.BuildM0RProfileList = OON.BuildRouteProfileList

local function SlashCommand(argument)
    local args = {}
    for value in string.gmatch(argument or "", "%S+") do
        args[#args + 1] = value
    end
    local command = args[1] and string.lower(args[1]) or nil

    if command == "debug" then
        local value = args[2] and string.lower(args[2]) or "toggle"
        local enabled
        if value == "toggle" then
            enabled = not OON.IsDebugEnabled()
        else
            enabled = ParseOnOff(value)
        end
        if enabled == nil then
            Print("Use /oon debug on, /oon debug off, or /oon debug toggle.")
            return
        end
        OON.SetDebugEnabled(enabled)
        return
    end

    if command == "raidlead" or command == "raidleader" or command == "lead" then
        local value = args[2] and string.lower(args[2]) or "toggle"
        local enabled
        if value == "toggle" then
            enabled = not OON.IsRaidLeadModeEnabled()
        else
            enabled = ParseOnOff(value)
        end
        if enabled == nil then
            Print("Use /oon raidlead on, /oon raidlead off, or /oon raidlead toggle.")
            return
        end
        OON.SetRaidLeadModeEnabled(enabled)
        return
    end

    if command == "settings" or command == "options" then
        OON.ToggleStandaloneSettingsWindow()
        return
    end

    if not OON.IsActive() then
        Print("Inactive outside Opulent Ordeal (zone 1565). Waiting for zone check.")
        return
    end

    local debugCommands = {
        route = true,
        auto = true,
        soak = true,
        doublesoak = true,
        dual = true,
        soakpositions = true,
        soakmarkers = true,
        marker = true,
        profile = true,
        routeprofile = true,
        mor = true,
        profiles = true,
        profilelist = true,
        morlist = true,
        phase = true,
        lamps = true,
        lamptimer = true,
        testpath = true,
    }
    if command and debugCommands[command] and not OON.IsDebugEnabled() then
        Print("That command requires debug mode. Use /oon debug on.")
        return
    end

    if command == "route" and args[2] and args[3] then
        OON.StartManualRoute(args[2], args[3])
        return
    end

    if command == "auto" and args[2] and args[3] then
        OON.StartAutomatedRoute(args[2], args[3], args[4])
        return
    end

    if command == "color" then
        OON.SetPlayerColor(args[2])
        return
    end

    if command == "assign" then
        OON.SetRosterColor(args[2], args[3])
        return
    end

    if command == "soak" then
        OON.AssignSoloSoak(args[2] or OON.saved.preferredRoom, 8000, "manual")
        return
    end

    if command == "doublesoak" or command == "dual" then
        OON.AssignDualSoaks(args[2] or OON.saved.preferredRoom, 8000)
        return
    end

    if command == "soakpositions" or command == "soakmarkers" then
        if OON.PreviewSoakPositions then
            OON.PreviewSoakPositions(args[2] or "all")
        else
            Print("Marker renderer is not loaded.")
        end
        return
    end

    if command == "roster" then
        ShowWindow(true)
        OON.body:SetText(OON.BuildRosterText())
        Print("Showing color roster.")
        return
    end

    if command == "info" or command == "infobox" then
        local value = args[2] and string.lower(args[2]) or "toggle"
        local enabled
        if value == "toggle" then
            enabled = OON.saved.infoWindow.enabled == false
        else
            enabled = ParseOnOff(value)
        end
        if enabled == nil then
            Print("Use /oon info on, /oon info off, or /oon info toggle.")
            return
        end
        OON.SetInfoWindowEnabled(enabled)
        return
    end

    if command == "stop" or (command == "animate" and args[2] == "stop") then
        OON.ClearRouteState("Path animation stopped.")
        return
    end

    if command == "marker" and args[2] then
        if OON.TestMarker then
            OON.TestMarker(args[2])
        else
            Print("Marker renderer is not loaded.")
        end
        return
    end

    if command == "markers" and args[2] == "clear" then
        if OON.HideAllMarkers then
            OON.HideAllMarkers(true)
        end
        Print("Markers cleared.")
        return
    end

    if (command == "profile" or command == "routeprofile" or command == "mor") and args[2] then
        OON.StartRouteProfile(args[2])
        return
    end

    if command == "profiles" or command == "profilelist" or command == "morlist" then
        ShowWindow(true)
        OON.body:SetText(OON.BuildRouteProfileList())
        Print("Showing imported route profile keys.")
        return
    end

    if command == "display" or command == "mode" then
        local mode = args[2] and string.lower(args[2]) or nil
        if mode ~= "full" and mode ~= "fullroute" and mode ~= "proximity" and mode ~= "window" then
            Print("Use /oon display full or /oon display proximity.")
            return
        end
        OON.SetRouteDisplayMode(mode == "fullroute" and "full" or mode)
        return
    end

    if command == "proximity" or command == "radius" then
        local enabled = ParseOnOff(args[2])
        if command == "radius" or enabled == nil and args[2] then
            OON.SetProximityRadius(args[2])
        else
            OON.SetRouteDisplayMode(enabled == false and "full" or "proximity")
        end
        return
    end

    if command == "fullroute" or command == "fullpath" then
        OON.SetRouteDisplayMode("full")
        return
    end

    if command == "phase" then
        if args[2] ~= "1" and args[2] ~= "2" then
            Print("Use /oon phase 1 or /oon phase 2.")
            return
        end
        OON.SetEncounterPhase(args[2], "Encounter phase set to " .. args[2] .. ".")
        return
    end

    if command == "teammates" or command == "teammarkers" then
        local enabled = ParseOnOff(args[2])
        if enabled == nil then
            Print("Use /oon teammates on or /oon teammates off.")
            return
        end
        if OON.SetTeammateMarkersEnabled then
            OON.SetTeammateMarkersEnabled(enabled)
        end
        return
    end

    if command == "sync" then
        local enabled = ParseOnOff(args[2])
        if enabled == nil then
            Print("Use /oon sync on or /oon sync off.")
            return
        end
        if OON.SetColorSyncEnabled then
            OON.SetColorSyncEnabled(enabled)
        end
        return
    end

    if command == "share" then
        local color = args[2] or OON.playerColor
        if OON.ShareColorAssignment then
            OON.ShareColorAssignment(GetDisplayName("player"), color)
        end
        return
    end

    if command == "lamps" then
        OON.SetPlayerColor("purple")
        if OON.RefreshPersistentMarkers then
            OON.RefreshPersistentMarkers()
        end
        Print("Purple lamp markers enabled for this player.")
        return
    end

    if command == "lamptimer" then
        OON.TestLampBuffTimer(args[2])
        return
    end

    if command == "return" then
        OON.StartReturnPath(args[2] or "join")
        return
    end

    if command == "testpath" then
        OON.StartTestPath()
        return
    end

    Print("Commands: /oon settings, /oon color <red|orange|purple|none>, /oon info <on|off|toggle>, /oon raidlead <on|off|toggle>, /oon debug <on|off|toggle>, /oon assign <@name> <color|none>, /oon roster, /oon return <join|final>, /oon markers clear, /oon display <full|proximity>, /oon proximity [radius], /oon fullroute, /oon teammates <on|off>, /oon sync <on|off>, /oon share [color], /oon stop")
    if OON.IsDebugEnabled() then
        Print("Debug: /oon route, /oon auto, /oon soak, /oon doublesoak, /oon soakpositions, /oon marker, /oon profile, /oon profiles, /oon phase, /oon lamps, /oon lamptimer [seconds], /oon testpath")
    end
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    OON.saved = ZO_SavedVars:NewAccountWide("OpulentOrdealNavigator_SavedVariables", 1, nil, DEFAULTS)
    OON.saved.rosterColors = OON.saved.rosterColors or {}
    OON.saved.assignedSoaks = OON.saved.assignedSoaks or {}
    OON.saved.encounterPhase = 1
    OON.saved.pathAnimation = OON.saved.pathAnimation or {}
    OON.saved.persistentMarkers = OON.saved.persistentMarkers or {}
    OON.saved.teammateMarkers = OON.saved.teammateMarkers or {}
    OON.saved.colorSync = OON.saved.colorSync or {}
    OON.saved.infoWindow = OON.saved.infoWindow or {}
    OON.saved.raidLead = OON.saved.raidLead or {}
    OON.saved.lampTimer = OON.saved.lampTimer or {}
    OON.ClearPlayerColor()
    if OON.saved.debug == nil then
        OON.saved.debug = DEFAULTS.debug
    end
    OON.saved.pathAnimation.intervalMs = DEFAULTS.pathAnimation.intervalMs
    if OON.saved.pathAnimation.enabled == nil then
        OON.saved.pathAnimation.enabled = DEFAULTS.pathAnimation.enabled
    end
    if OON.saved.pathAnimation.showFullPath == nil then
        OON.saved.pathAnimation.showFullPath = DEFAULTS.pathAnimation.showFullPath
    end
    if OON.saved.pathAnimation.showRouteLines == nil then
        OON.saved.pathAnimation.showRouteLines = DEFAULTS.pathAnimation.showRouteLines
    end
    if OON.saved.pathAnimation.enabled == true and OON.saved.pathAnimation.showFullPath ~= false then
        OON.saved.pathAnimation.showFullPath = false
    elseif OON.saved.pathAnimation.enabled ~= true then
        OON.saved.pathAnimation.showFullPath = true
    end
    if not OON.saved.pathAnimation.proximityRadius or OON.saved.pathAnimation.proximityRadius < 50 then
        OON.saved.pathAnimation.proximityRadius = DEFAULTS.pathAnimation.proximityRadius
    end
    if OON.saved.teammateMarkers.enabled == nil then
        OON.saved.teammateMarkers.enabled = DEFAULTS.teammateMarkers.enabled
    end
    if OON.saved.colorSync.enabled == nil then
        OON.saved.colorSync.enabled = DEFAULTS.colorSync.enabled
    end
    if OON.saved.infoWindow.enabled == nil then
        OON.saved.infoWindow.enabled = DEFAULTS.infoWindow.enabled
    end
    if OON.saved.raidLead.enabled == nil then
        OON.saved.raidLead.enabled = DEFAULTS.raidLead.enabled
    end
    OON.saved.pathAnimation.directionIndicatorInterval = DEFAULTS.pathAnimation.directionIndicatorInterval
    SLASH_COMMANDS["/oon"] = SlashCommand
    if OON.RegisterColorSync then
        OON.RegisterColorSync()
    end
    RegisterSettingsPanel()
    Print("Loaded in stasis. It will activate inside Opulent Ordeal (zone 1565).")
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)

local function EnterActiveMode()
    local wasActive = OON.IsActive()
    if not wasActive then
        OON.ClearPlayerColor()
        OON.assignmentSources = {}
        OON.saved.rosterColors = {}
        OON.saved.assignedSoaker = nil
        OON.saved.assignedSoaks = {}
        OON.saved.encounterPhase = 1
        OON.lastSoakCallAt = {}
        OON.lastSoloSoakAt = {}
        OON.playerColor = "none"
    end
    OON.active = true

    if OON.RegisterOpulentDetection then
        OON.RegisterOpulentDetection()
    end
    EnsureWindow()
    if OON.body then
        if not OON.currentPlan then
            OON.body:SetText(GetReadyPrompt(OON.playerColor))
        end
    end
    OON.RefreshInfoWindowVisibility()
    if OON.RefreshPersistentMarkers then
        OON.RefreshPersistentMarkers()
    end
    if OON.StartTeammateMarkerUpdates then
        OON.StartTeammateMarkerUpdates()
    end
    if OON.RefreshPathRendering then
        OON.RefreshPathRendering()
    end
    if not wasActive then
        Print("Active in Opulent Ordeal.")
    end
end

local function EnterStasis()
    local wasActive = OON.IsActive()
    OON.active = false
    OON.ClearPlayerColor()
    OON.saved.rosterColors = {}

    if OON.UnregisterOpulentDetection then
        OON.UnregisterOpulentDetection()
    end
    if OON.HidePersonalSoakWarning then
        OON.HidePersonalSoakWarning()
    end
    if OON.HideRaidLeadSoakWindow then
        OON.HideRaidLeadSoakWindow()
    end
    if OON.HideLampBuffTimer then
        OON.HideLampBuffTimer()
    end
    if OON.HideAnimatedPath then
        OON.HideAnimatedPath()
    end
    if OON.HideAllMarkers then
        OON.HideAllMarkers(true)
    end
    if OON.HideTeammateMarkers then
        OON.HideTeammateMarkers()
    end
    HideWindow()

    if wasActive then
        Print("Leaving Opulent Ordeal. Addon is back in stasis.")
    end
end

local function OnPlayerActivated()
    if OON.IsInOpulentOrdeal and OON.IsInOpulentOrdeal() then
        EnterActiveMode()
    else
        EnterStasis()
    end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "ZoneCheck", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
