OpulentOrdealNavigator = OpulentOrdealNavigator or {}

local OON = OpulentOrdealNavigator
local RENDERER_NAME = "OpulentOrdealNavigatorMarkerRenderer"

OON.activeMarkerControls = OON.activeMarkerControls or {}
OON.missingMarkerWarnings = OON.missingMarkerWarnings or {}

local DEFAULT_TEXTURE = "OpulentOrdealNavigator/assets/shape/diamond.dds"
local ACTIVE_ARROW_TEXTURE = "OpulentOrdealNavigator/assets/shape/triangle.dds"
local ROUTE_NUMBER_Y_OFFSET = 130
local ROUTE_NUMBER_LABEL_SIZE = 46
local ROUTE_NUMBER_COLOR = { 1, 0.96, 0.55, 1 }
local ROOM_TEXTURES = {
    red = "OpulentOrdealNavigator/assets/shape/side_red.dds",
    orange = "OpulentOrdealNavigator/assets/shape/side_orange.dds",
    purple = "OpulentOrdealNavigator/assets/shape/side_purple.dds",
    middle = "OpulentOrdealNavigator/assets/shape/diamond.dds",
}

local function GetRenderSettings()
    local saved = OON.saved or {}
    saved.markerRendering = saved.markerRendering or {}
    return saved.markerRendering
end

local function GetDrawingApi()
    if OON.WorldRenderer then
        return OON.WorldRenderer
    end
    if CrutchAlerts and CrutchAlerts.Drawing then
        return CrutchAlerts.Drawing
    end
    return nil
end

local function GetMarkerRoom(markerId, marker)
    return (OON.markerDisplayRooms and OON.markerDisplayRooms[markerId]) or (marker and marker.room)
end

local function GetMarkerColor(markerId, marker, active)
    if marker and marker.kind == "lamp" then
        return active and { 1, 0.95, 0.25, 1 } or { 1, 0.82, 0.12, 0.88 }
    end

    local room = GetMarkerRoom(markerId, marker)
    if room and OON.ROOMS and OON.ROOMS[room] and OON.ROOMS[room].color then
        local color = OON.ROOMS[room].color
        local alpha = active and 1 or 0.78
        return { color[1], color[2], color[3], alpha }
    end
    if room == "middle" then
        return active and { 0.95, 0.95, 0.95, 1 } or { 0.85, 0.85, 0.85, 0.78 }
    end

    if active then
        return { 1, 1, 1, 0.95 }
    end

    return { 0.4, 0.9, 1, 0.72 }
end

local function GetMarkerTexture(markerId, marker, settings)
    if marker and marker.texture then
        return marker.texture
    end

    local room = GetMarkerRoom(markerId, marker)
    if room and ROOM_TEXTURES[room] then
        return ROOM_TEXTURES[room]
    end

    return settings.texture or DEFAULT_TEXTURE
end

local function HasPosition(marker)
    return marker and marker.x and marker.y and marker.z
end

local function RemoveMarker(markerId)
    local entry = OON.activeMarkerControls[markerId]
    if not entry then
        return
    end

    local draw = GetDrawingApi()
    if draw then
        if entry.iconKey and draw.RemovePlacedPositionMarker then
            draw.RemovePlacedPositionMarker(entry.iconKey)
        elseif entry.iconKey and draw.RemoveWorldTexture then
            draw.RemoveWorldTexture(entry.iconKey)
        end

        if entry.labelKey and draw.ReleaseSpaceControl then
            draw.ReleaseSpaceControl(entry.labelKey)
        elseif entry.labelKey and draw.RemoveWorldTexture then
            draw.RemoveWorldTexture(entry.labelKey)
        end

        if entry.arrowKey and draw.RemovePlacedPositionMarker then
            draw.RemovePlacedPositionMarker(entry.arrowKey)
        elseif entry.arrowKey and draw.RemoveWorldTexture then
            draw.RemoveWorldTexture(entry.arrowKey)
        end
    end

    OON.activeMarkerControls[markerId] = nil
end

local function ShouldShowPersistentGroup(groupName)
    if groupName == "phase2_tanks" then
        local persistentSettings = OON.saved and OON.saved.persistentMarkers or {}
        return (OON.saved and (OON.saved.encounterPhase or 1) >= 2) and persistentSettings.showPhase2TankMarkers ~= false
    end

    if OON.playerColor ~= groupName then
        return false
    end

    if groupName == "purple" then
        local persistentSettings = OON.saved.persistentMarkers or {}
        return persistentSettings.showEclipseLamps ~= false
    end

    return true
end

local function CreateLabel(draw, marker, settings, color, groundMarker)
    if settings.labels == false or draw.supportsLabels == false or not draw.CreateSpaceLabel then
        return nil
    end

    local text = marker.renderLabel or marker.label
    if not text or text == "" then
        return nil
    end

    local fontSize = settings.labelSize or 85
    if draw == OON.WorldRenderer and not groundMarker then
        fontSize = 34
    end
    local labelYOffset = settings.labelYOffset or 130
    if draw == OON.WorldRenderer and not groundMarker then
        labelYOffset = 95
    end
    if marker.kind == "m0r_route" then
        labelYOffset = ROUTE_NUMBER_Y_OFFSET
        fontSize = ROUTE_NUMBER_LABEL_SIZE
        color = ROUTE_NUMBER_COLOR
    end
    local labelOptions = draw == OON.WorldRenderer and marker.kind == "m0r_route" and {
        labelScale = 5,
    } or { 0, 0, 0 }

    return draw.CreateSpaceLabel(
        text,
        marker.x,
        marker.y + labelYOffset,
        marker.z,
        fontSize,
        color,
        true,
        labelOptions
    )
end

local function CreateMarker(markerId, marker, active, showArrow, forceGround)
    local settings = GetRenderSettings()
    if settings.enabled == false then
        return
    end

    local draw = GetDrawingApi()
    if not draw or not draw.CreatePlacedPositionMarker then
        if OON.Print and not OON.rendererMissingWarningShown then
            OON.Print("World marker renderer is not loaded. Path state is still tracked.")
            OON.rendererMissingWarningShown = true
        end
        return
    end

    if not HasPosition(marker) then
        if OON.Print and not OON.missingMarkerWarnings[markerId] then
            OON.Print(string.format("Marker %s has no coordinates yet.", markerId))
            OON.missingMarkerWarnings[markerId] = true
        end
        return
    end

    local groundMarker = forceGround == true or marker.kind == "soak" or marker.kind == "tank"
    local color = GetMarkerColor(markerId, marker, active)
    local size = active and (settings.activeSize or 145) or (settings.size or 105)
    if draw == OON.WorldRenderer and not groundMarker then
        size = active and 90 or 65
    end
    local texture = GetMarkerTexture(markerId, marker, settings)
    local iconKey
    if groundMarker and draw.CreateGroundPositionMarker then
        iconKey = draw.CreateGroundPositionMarker(texture, marker.x, marker.y, marker.z, size, color, marker.yaw)
    else
        iconKey = draw.CreatePlacedPositionMarker(texture, marker.x, marker.y + 15, marker.z, size, color)
    end
    local labelKey = CreateLabel(draw, marker, settings, color, groundMarker)
    local arrowKey
    if showArrow then
        local arrowSize = draw == OON.WorldRenderer and 85 or 135
        arrowKey = draw.CreatePlacedPositionMarker(ACTIVE_ARROW_TEXTURE, marker.x, marker.y + 280, marker.z, arrowSize, { 1, 1, 1, 0.98 })
    end

    OON.activeMarkerControls[markerId] = {
        iconKey = iconKey,
        labelKey = labelKey,
        arrowKey = arrowKey,
        active = active,
        showArrow = showArrow == true,
        groundMarker = groundMarker,
        persistent = marker.persistent == true,
    }
end

function OON.SetMarkerVisible(markerId, visible, active, showArrow, forceGround)
    local marker = markerId and OON.MARKERS and OON.MARKERS[markerId]
    if not marker then
        return
    end

    local existing = OON.activeMarkerControls[markerId]
    if not visible or (OON.IsActive and not OON.IsActive()) then
        RemoveMarker(markerId)
        return
    end

    local groundMarker = forceGround == true or marker.kind == "soak" or marker.kind == "tank"
    if existing
        and existing.active == active
        and existing.showArrow == (showArrow == true)
        and existing.groundMarker == groundMarker
    then
        return
    end

    RemoveMarker(markerId)
    CreateMarker(markerId, marker, active == true, showArrow == true, forceGround == true)
end

function OON.SetPersistentMarkerVisible(markerId, visible)
    local marker = markerId and OON.MARKERS and OON.MARKERS[markerId]
    if marker then
        marker.persistent = visible == true
    end
    OON.SetMarkerVisible(markerId, visible, false)
end

function OON.HideAllMarkers(includePersistent)
    for markerId in pairs(OON.activeMarkerControls) do
        if includePersistent ~= false or not OON.activeMarkerControls[markerId].persistent then
            RemoveMarker(markerId)
        end
    end
end

function OON.RefreshPersistentMarkers()
    if OON.IsActive and not OON.IsActive() then
        OON.HideAllMarkers(true)
        return
    end

    local groups = OON.PERSISTENT_MARKER_GROUPS or {}
    local shown = {}

    for groupName, markerIds in pairs(groups) do
        local shouldShow = ShouldShowPersistentGroup(groupName)
        for _, markerId in ipairs(markerIds) do
            shown[markerId] = shouldShow
            OON.SetPersistentMarkerVisible(markerId, shouldShow)
        end
    end

    for markerId, entry in pairs(OON.activeMarkerControls) do
        if entry.persistent and not shown[markerId] then
            RemoveMarker(markerId)
        end
    end
end

function OON.ShowMarker(markerId, active)
    OON.SetMarkerVisible(markerId, true, active == true)
end

function OON.TestMarker(markerId)
    markerId = markerId or "center_middle"
    OON.HideAllMarkers(true)
    OON.ShowMarker(markerId, true)
    if OON.Print then
        OON.Print("Showing marker " .. markerId .. ".")
    end
end

function OON.PreviewSoakPositions(room)
    room = room and string.lower(room) or "all"
    local rooms = room == "all" and { "red", "orange", "purple" } or { room }

    if room ~= "all" and not (OON.SOAK_MARKERS and OON.SOAK_MARKERS[room]) then
        if OON.Print then
            OON.Print("Use /oon soakpositions red, orange, purple, or all.")
        end
        return
    end

    OON.HideAllMarkers(true)

    for _, roomKey in ipairs(rooms) do
        local markerData = OON.SOAK_MARKERS and OON.SOAK_MARKERS[roomKey]
        if markerData then
            OON.ShowMarker(markerData.left, false)
            OON.ShowMarker(markerData.right, false)
        end
    end

    if OON.Print then
        OON.Print(string.format("Showing %s dual-soak positions. Use /oon markers clear when finished.", room))
    end
end

EVENT_MANAGER:RegisterForEvent(RENDERER_NAME, EVENT_PLAYER_DEACTIVATED, function()
    OON.HideAllMarkers(true)
end)
