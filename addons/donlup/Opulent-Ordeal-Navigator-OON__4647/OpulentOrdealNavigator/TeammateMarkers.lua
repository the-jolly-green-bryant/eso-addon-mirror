OpulentOrdealNavigator = OpulentOrdealNavigator or {}

local OON = OpulentOrdealNavigator
local UPDATE_NAME = "OpulentOrdealNavigatorTeammateMarkers"
local GROUP_UPDATE_NAME = "OpulentOrdealNavigatorTeammateMarkersGroup"
local UNIQUE_NAME = "OpulentOrdealNavigatorColor"

local ROOM_TEXTURES = {
    red = "OpulentOrdealNavigator/assets/shape/triangle.dds",
    orange = "OpulentOrdealNavigator/assets/shape/circle.dds",
    purple = "OpulentOrdealNavigator/assets/shape/square.dds",
}

local MARKER_SIZE = 55
local activeMarkers = {}

local function UnregisterRefreshHandlers()
    EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
    EVENT_MANAGER:UnregisterForEvent(GROUP_UPDATE_NAME, EVENT_GROUP_UPDATE)
end

local function RegisterRefreshHandlers()
    UnregisterRefreshHandlers()
    EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, 500, OON.RefreshTeammateMarkers)
    EVENT_MANAGER:RegisterForEvent(GROUP_UPDATE_NAME, EVENT_GROUP_UPDATE, function()
        OON.RefreshTeammateMarkers()
    end)
end

local function GetRosterKey(name)
    return name and string.lower(name) or nil
end

local function GetDisplayName(unitTag)
    local accountName = GetUnitDisplayName(unitTag)
    if accountName and accountName ~= "" then
        return accountName
    end
    return GetUnitName(unitTag)
end

local function IsSelf(unitTag)
    return unitTag == "player" or (AreUnitsEqual and AreUnitsEqual("player", unitTag))
end

local function GetColorForUnit(unitTag)
    local name = GetDisplayName(unitTag)
    if not name then
        return nil
    end

    local assigned = OON.GetAssignedColor and OON.GetAssignedColor(name)
    if assigned then
        return assigned
    end

    if IsSelf(unitTag) then
        return OON.playerColor
    end

    return nil
end

local function GetRoomColor(room)
    if room and OON.ROOMS and OON.ROOMS[room] and OON.ROOMS[room].color then
        local color = OON.ROOMS[room].color
        return { color[1], color[2], color[3], 0.95 }
    end
    if room == "none" then
        return { 0.92, 0.92, 0.92, 0.9 }
    end
    return { 1, 1, 1, 0.9 }
end

local function RemoveUnitMarker(unitTag)
    local entry = activeMarkers[unitTag]
    if not entry then
        return
    end

    if entry.backend == "crutch" and CrutchAlerts and CrutchAlerts.RemoveAttachedIconForUnit then
        CrutchAlerts.RemoveAttachedIconForUnit(unitTag, UNIQUE_NAME)
    elseif entry.key and OON.WorldRenderer and OON.WorldRenderer.RemoveAttachedUnitMarker then
        OON.WorldRenderer.RemoveAttachedUnitMarker(entry.key)
    end

    activeMarkers[unitTag] = nil
end

function OON.HideTeammateMarkers()
    UnregisterRefreshHandlers()

    for unitTag in pairs(activeMarkers) do
        RemoveUnitMarker(unitTag)
    end
end

local function SetUnitMarker(unitTag, room)
    local texture = ROOM_TEXTURES[room]
    if not texture then
        RemoveUnitMarker(unitTag)
        return
    end

    local entry = activeMarkers[unitTag]
    if entry and entry.room == room then
        return
    end

    RemoveUnitMarker(unitTag)

    local color = GetRoomColor(room)
    if CrutchAlerts and CrutchAlerts.SetAttachedIconForUnit then
        CrutchAlerts.SetAttachedIconForUnit(unitTag, UNIQUE_NAME, 160, texture, MARKER_SIZE, color, true)
        activeMarkers[unitTag] = {
            backend = "crutch",
            room = room,
        }
        return
    end

    if OON.WorldRenderer and OON.WorldRenderer.CreateAttachedUnitMarker then
        local key = OON.WorldRenderer.CreateAttachedUnitMarker(unitTag, texture, MARKER_SIZE, color, 320)
        if key then
            activeMarkers[unitTag] = {
                backend = "world",
                key = key,
                room = room,
            }
        end
    end
end

local function RefreshUnit(unitTag, seen)
    if not unitTag or not DoesUnitExist(unitTag) or IsSelf(unitTag) then
        return
    end

    seen[unitTag] = true

    local room = GetColorForUnit(unitTag)
    if room and ROOM_TEXTURES[room] then
        SetUnitMarker(unitTag, room)
    else
        RemoveUnitMarker(unitTag)
    end
end

function OON.RefreshTeammateMarkers()
    if not OON.IsActive or not OON.IsActive() then
        OON.HideTeammateMarkers()
        return
    end

    OON.saved.teammateMarkers = OON.saved.teammateMarkers or {}
    if OON.saved.teammateMarkers.enabled == false then
        OON.HideTeammateMarkers()
        return
    end

    local seen = {}
    local groupSize = GetGroupSize()
    for index = 1, groupSize do
        RefreshUnit(GetGroupUnitTagByIndex(index), seen)
    end

    for unitTag in pairs(activeMarkers) do
        if not seen[unitTag] then
            RemoveUnitMarker(unitTag)
        end
    end
end

function OON.SetTeammateMarkersEnabled(enabled)
    OON.saved.teammateMarkers = OON.saved.teammateMarkers or {}
    OON.saved.teammateMarkers.enabled = enabled == true

    if OON.saved.teammateMarkers.enabled then
        RegisterRefreshHandlers()
        OON.RefreshTeammateMarkers()
        if OON.Print then
            OON.Print("Teammate color markers enabled.")
        end
    else
        OON.HideTeammateMarkers()
        if OON.Print then
            OON.Print("Teammate color markers disabled.")
        end
    end
end

function OON.StartTeammateMarkerUpdates()
    OON.saved.teammateMarkers = OON.saved.teammateMarkers or {}
    if OON.saved.teammateMarkers.enabled == false then
        OON.HideTeammateMarkers()
        return
    end

    RegisterRefreshHandlers()
    OON.RefreshTeammateMarkers()
end

EVENT_MANAGER:RegisterForEvent(UPDATE_NAME, EVENT_PLAYER_DEACTIVATED, function()
    OON.HideTeammateMarkers()
end)
