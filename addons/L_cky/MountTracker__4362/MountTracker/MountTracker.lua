local MountTracker = {}
MountTracker.name    = "MountTracker"
MountTracker.version = "0.3.0"
MountTracker.authors = "@L_cky"
MountTracker.chat    = nil
MountTracker.isReady = false

-- Color constants for consistent UI
local COLOR_MAIN   = "BBFFFF" -- Cyan-ish

MountTracker.defaults = {
    totalTimeOnMount = 0,
    sessionNotificationThreshold = 60,
    sessionNotification = "You were riding your mount for <<1>>.",
    mountedNotification = "You have spent <<1>> riding on a mount."
}

-- Localize ZOS functions for performance
local zo_strf = zo_strformat
local math_floor = math.floor

-----------------------------------------------------------------------
-- HELPER FUNCTIONS
-----------------------------------------------------------------------

local function PrintMessage(message)
    if MountTracker.chat then
        MountTracker.chat:SetTagColor(COLOR_MAIN)
        MountTracker.chat:Print(message)
    else
        CHAT_ROUTER:AddSystemMessage(message)
    end
end

local function FormatTime(seconds)
    local units = {
        {label = SI_TIME_FORMAT_DAYS_DESC,    value = math_floor(seconds / 86400)},
        {label = SI_TIME_FORMAT_HOURS_DESC,   value = math_floor((seconds % 86400) / 3600)},
        {label = SI_TIME_FORMAT_MINUTES_DESC, value = math_floor((seconds % 3600) / 60)},
        {label = SI_TIME_FORMAT_SECONDS_DESC, value = math_floor(seconds % 60)}
    }

    local parts = {}
    for _, unit in ipairs(units) do
        if unit.value > 0 then
            table.insert(parts, zo_strf(GetString(unit.label), unit.value))
        end
    end
    
    return ZO_GenerateCommaSeparatedList(parts)
end

local function ResetMountTime()
    MountTracker.savedVars.totalTimeOnMount = 0

    if MountTracker.startTime then
        MountTracker.startTime = GetFrameTimeSeconds()
    end

    PrintMessage("Total time tracked has been reset.")
end

-----------------------------------------------------------------------
-- EVENT HANDLERS
-----------------------------------------------------------------------

local function OnMountStateChanged(eventCode, isMounted)
    if not MountTracker.isReady then return end

    local currentTime = GetFrameTimeSeconds()

    if isMounted then
        MountTracker.startTime = currentTime
    elseif MountTracker.startTime then
        local sessionDuration = currentTime - MountTracker.startTime
        MountTracker.savedVars.totalTimeOnMount = MountTracker.savedVars.totalTimeOnMount + sessionDuration
        MountTracker.startTime = nil

        local threshold = MountTracker.savedVars.sessionNotificationThreshold
        if threshold > 0 and sessionDuration > threshold then
            local timeString = zo_strf(MountTracker.savedVars.sessionNotification, FormatTime(sessionDuration))
            PrintMessage(timeString)
        end
    end
end

local function OnPlayerActivated()
    if IsMounted() then
        MountTracker.startTime = GetFrameTimeSeconds()
    end
    MountTracker.isReady = true
end

local function OnPlayerDeactivated()
    MountTracker.isReady = false
end

-----------------------------------------------------------------------
-- SLASH COMMANDS
-----------------------------------------------------------------------

local function MountedCommand(args)
    if string.lower(args or "") == "reset" then
        ResetMountTime()
        return
    end

    local total = MountTracker.savedVars.totalTimeOnMount
    if MountTracker.startTime then
        total = total + (GetFrameTimeSeconds() - MountTracker.startTime)
    end

    PrintMessage(zo_strf(MountTracker.savedVars.mountedNotification, FormatTime(total)))
end

-----------------------------------------------------------------------
-- INITIALIZATION
-----------------------------------------------------------------------

local function registerChat()
    if LibChatMessage then
        MountTracker.chat = LibChatMessage(MountTracker.name, "MT")
    end
end

local function registerLAM()
    if not LibAddonMenu2 then return end

    local LAM = LibAddonMenu2
    local panelName = MountTracker.name .. "Panel"
    local panel = LAM:RegisterAddonPanel(panelName, {
        type = "panel",
        name = MountTracker.name,
        author = MountTracker.authors,
        version = MountTracker.version
    })

    local optionsData = {
        {
            type = "slider",
            name = "Dismount Notification Threshold (seconds)",
            getFunc = function() return MountTracker.savedVars.sessionNotificationThreshold end,
            setFunc = function(value) MountTracker.savedVars.sessionNotificationThreshold = value end,
            tooltip = "Duration in seconds. Set to '0' to disable notifications.",
            min = 0, max = 3000,
            default = MountTracker.defaults.sessionNotificationThreshold,
        },
        {
            type = "editbox",
            name = "Session Notification",
            tooltip = "Message format for session notifications. Use <<1>> for the duration.",
            getFunc = function() return MountTracker.savedVars.sessionNotification end,
            setFunc = function(text) MountTracker.savedVars.sessionNotification = text end,
            isMultiline = true,
            width = "full",
            default = MountTracker.defaults.sessionNotification,
        },
        {
            type = "editbox",
            name = "Mounted Notification",
            tooltip = "Message format for the /mounted command. Use <<1>> for the duration.",
            getFunc = function() return MountTracker.savedVars.mountedNotification end,
            setFunc = function(text) MountTracker.savedVars.mountedNotification = text end,
            isMultiline = true,
            width = "full",
            default = MountTracker.defaults.mountedNotification,
        },
        {
            type = "button",
            name = "Reset Total Time",
            tooltip = "Resets the account-wide total time to zero.",
            func = ResetMountTime,
            width = "half",
            isDangerous = true,
        },
    }
    LAM:RegisterOptionControls(panelName, optionsData)
end

local function Initialize(eventCode, addOnName)
    if addOnName ~= MountTracker.name then return end

    MountTracker.savedVars = ZO_SavedVars:NewAccountWide("MountTrackerVars", 1, GetWorldName(), MountTracker.defaults)

    EVENT_MANAGER:RegisterForEvent(MountTracker.name, EVENT_MOUNTED_STATE_CHANGED, OnMountStateChanged)
    EVENT_MANAGER:RegisterForEvent(MountTracker.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(MountTracker.name, EVENT_PLAYER_DEACTIVATED, OnPlayerDeactivated)

    registerLAM()
    registerChat()

    SLASH_COMMANDS["/mounted"] = MountedCommand
end

EVENT_MANAGER:RegisterForEvent(MountTracker.name, EVENT_ADD_ON_LOADED, Initialize)