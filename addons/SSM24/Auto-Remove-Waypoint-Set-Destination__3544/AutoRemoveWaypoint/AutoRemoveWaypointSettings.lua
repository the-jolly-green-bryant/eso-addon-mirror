AutoRemoveWaypoint = AutoRemoveWaypoint or {}

AutoRemoveWaypoint.defaults = {
    enabled = true,
    distance = 30,
    showNotification = true, -- name is for backwards compatibility
    showChatNotification = false
}

local panelName = "AutoRemoveWaypoint_Settings"
local LAM = LibAddonMenu2

function AutoRemoveWaypoint.InitSettings()
    local saveData = AutoRemoveWaypoint.savedVars
    local panelData = {
        type = "panel",
        name = "Auto Remove Waypoint",
        displayName = "|cfabbffAuto Remove Waypoint|r",
        author = "SSM24",
        version = "1.1.0",
        slashCommand = "/arw"
    }
    
    local optionsTable = {
        {
            type = "checkbox",
            name = "Enabled",
            getFunc = function() return saveData.enabled end,
            setFunc = function(val) saveData.enabled = val end,
        },
        {
            type = "header",
            name = "Settings"
        },
        {
            type = "slider",
            name = "Distance (meters)",
            tooltip = "Distance at which waypoints will be removed, in meters",
            min = 1,
            max = 200,
            step = 1,
            clampFunction = function(value, min, max) return math.max(value, min) end, -- only clamp to min
            getFunc = function() return saveData.distance end,
            setFunc = function(val) saveData.distance = val end,
        },
        {
            type = "checkbox",
            name = "Show alert",
            tooltip = "Shows alert in top-right when the waypoint is reached",
            getFunc = function() return saveData.showNotification end,
            setFunc = function(val) saveData.showNotification = val end,
        },
        {
            type = "checkbox",
            name = "Show chat message",
            tooltip = "Shows chat message when the waypoint is reached",
            getFunc = function() return saveData.showChatNotification end,
            setFunc = function(val) saveData.showChatNotification = val end,
        }
    }

    LAM:RegisterAddonPanel(panelName, panelData)
    LAM:RegisterOptionControls(panelName, optionsTable)
end