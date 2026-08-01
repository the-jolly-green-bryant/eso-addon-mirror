AutoRemoveWaypoint = AutoRemoveWaypoint or {}

AutoRemoveWaypoint.name = "AutoRemoveWaypoint"

function AutoRemoveWaypoint.OnAddOnLoaded(event, addonName)
    if addonName ~= AutoRemoveWaypoint.name then return end
    
    EVENT_MANAGER:UnregisterForEvent(AutoRemoveWaypoint.name, EVENT_ADD_ON_LOADED)

    AutoRemoveWaypoint.savedVars = ZO_SavedVars:NewAccountWide(
        "AutoRemoveWaypoint_SavedVariables", 1, nil, AutoRemoveWaypoint.defaults, nil)
    AutoRemoveWaypoint.InitSettings()
end

function AutoRemoveWaypoint.Update()
    local saveData = AutoRemoveWaypoint.savedVars
    if not saveData.enabled then return end

    local mapWaypointX, mapWaypointY = GetMapPlayerWaypoint()
    if (mapWaypointX == 0 and mapWaypointY == 0) then return end

    local gps = LibGPS3

    local playerX, playerY = gps:LocalToGlobal(GetMapPlayerPosition("player"))
    local waypointX, waypointY = gps:LocalToGlobal(mapWaypointX, mapWaypointY)
    local distance = gps:GetGlobalDistanceInMeters(playerX, playerY, waypointX, waypointY) * gps:GetWorldGlobalRatio()

    if distance < saveData.distance then
        RemovePlayerWaypoint()
        if saveData.showNotification then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "Destination reached.")
        end
        if saveData.showChatNotification then
            AutoRemoveWaypoint.PrintChatMessage()
        end
    end
end

function AutoRemoveWaypoint.PrintChatMessage()
    if LibChatMessage then
        local chat = LibChatMessage("AutoRemoveWaypoint", "ARW")
        chat:SetTagColor("fabbff")
        chat:Print("Destination reached.")
    else
        d("Destination reached.")
    end
end


EVENT_MANAGER:RegisterForEvent(AutoRemoveWaypoint.name, EVENT_ADD_ON_LOADED, AutoRemoveWaypoint.OnAddOnLoaded)
EVENT_MANAGER:RegisterForUpdate(AutoRemoveWaypoint.name, 250, AutoRemoveWaypoint.Update)

--[[SLASH_COMMANDS["/wp"] = function()
    local mapWaypointX, mapWaypointY = GetMapPlayerWaypoint()
    if (mapWaypointX == 0 and mapWaypointY == 0) then
        d("Waypoint not set")
        return
    end
    local gps = LibGPS3
    local waypointX, waypointY = gps:LocalToGlobal(mapWaypointX, mapWaypointY)
    local playerX, playerY = gps:LocalToGlobal(GetMapPlayerPosition("player"))
    local distance = gps:GetGlobalDistanceInMeters(playerX, playerY, waypointX, waypointY)
    df("distance: %s", distance)
end]]
