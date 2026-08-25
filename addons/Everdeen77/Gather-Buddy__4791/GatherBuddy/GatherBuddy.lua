GatherBuddy = GatherBuddy or {}

local GB = GatherBuddy

------------------------------------------------------------
-- ADDON INFORMATION
------------------------------------------------------------

GB.ADDON_NAME = "GatherBuddy"
GB.ADDON_VERSION = "1.1"

local ADDON_NAME = GB.ADDON_NAME
local ADDON_VERSION = GB.ADDON_VERSION

------------------------------------------------------------
-- WINDOW SETTINGS
------------------------------------------------------------

GB.DEFAULT_WIDTH = 300
GB.DEFAULT_HEIGHT = 300

GB.MIN_WIDTH = 300
GB.MIN_HEIGHT = 220

GB.MAX_WIDTH = 900
GB.MAX_HEIGHT = 900

------------------------------------------------------------
-- RUNTIME DATA
------------------------------------------------------------

GB.savedVariables = nil
GB.sessionItems = {}
GB.worldName = nil

------------------------------------------------------------
-- SAVED VARIABLES
------------------------------------------------------------

local defaults = {
    left = nil,
    top = nil,

    width = GB.DEFAULT_WIDTH,
    height = GB.DEFAULT_HEIGHT,

    statsLeft = nil,
    statsTop = nil,

    sessionItems = {},

    isHidden = false,
    isLocked = false,

    -- 0 = solid black
    -- 255 = fully transparent
    backgroundTransparency = 64,

    sessionStartTime = nil,
}

------------------------------------------------------------
-- SESSION TIME
------------------------------------------------------------

function GB.FormatSessionTime(totalSeconds)
    totalSeconds = math.max(0, math.floor(totalSeconds))

    local hours = math.floor(totalSeconds / 3600)
    local minutes = math.floor((totalSeconds % 3600) / 60)
    local seconds = totalSeconds % 60

    return string.format(
        "%02d:%02d:%02d",
        hours,
        minutes,
        seconds
    )
end

function GB.GetElapsedSessionTime()
    if GB.savedVariables == nil
        or GB.savedVariables.sessionStartTime == nil then
        return 0
    end

    return math.max(
        0,
        GetTimeStamp() - GB.savedVariables.sessionStartTime
    )
end

------------------------------------------------------------
-- CLEAR SESSION
------------------------------------------------------------

function GB.ClearSession()
    for itemId in pairs(GB.sessionItems) do
        GB.sessionItems[itemId] = nil
    end

    GB.savedVariables.sessionStartTime = GetTimeStamp()

    if GB.UpdateMaterialList then
        GB.UpdateMaterialList()
    end

    if GB.UpdateSessionTimer then
        GB.UpdateSessionTimer()
    end
end

------------------------------------------------------------
-- SLASH COMMANDS
------------------------------------------------------------

local function RegisterSlashCommands()
    SLASH_COMMANDS["/gbuddy"] = function(args)
        local command = string.lower(
            zo_strtrim(args or "")
        )

        if command == "" then
            if GB.ToggleWindow then
                GB.ToggleWindow()
            end

        elseif command == "lock" then
            if GB.LockWindow then
                GB.LockWindow()
            end

        elseif command == "unlock" then
            if GB.UnlockWindow then
                GB.UnlockWindow()
            end

        else
            CHAT_SYSTEM:AddMessage(
                "|c66CCFF[Gather Buddy]|r "
                    .. "Commands: /gbuddy, "
                    .. "/gbuddy lock, "
                    .. "/gbuddy unlock"
            )
        end
    end
end

------------------------------------------------------------
-- SAVED VARIABLE SAFETY
------------------------------------------------------------

local function ValidateSavedVariables()
    if GB.savedVariables.sessionItems == nil then
        GB.savedVariables.sessionItems = {}
    end

    if GB.savedVariables.isHidden == nil then
        GB.savedVariables.isHidden = false
    end

    if GB.savedVariables.isLocked == nil then
        GB.savedVariables.isLocked = false
    end

    if GB.savedVariables.backgroundTransparency == nil then
        GB.savedVariables.backgroundTransparency = 64
    end

    if GB.savedVariables.width == nil then
        GB.savedVariables.width = GB.DEFAULT_WIDTH
    end

    if GB.savedVariables.height == nil then
        GB.savedVariables.height = GB.DEFAULT_HEIGHT
    end
end

------------------------------------------------------------
-- PLAYER ACTIVATED
------------------------------------------------------------

local function OnPlayerActivated(eventCode, initial)
    EVENT_MANAGER:UnregisterForEvent(
        ADDON_NAME,
        EVENT_PLAYER_ACTIVATED
    )

    --------------------------------------------------------
    -- SESSION RESET / RESTORE
    --------------------------------------------------------

    if initial then
        GB.savedVariables.sessionItems = {}
        GB.savedVariables.sessionStartTime = GetTimeStamp()

    elseif GB.savedVariables.sessionStartTime == nil then
        GB.savedVariables.sessionStartTime = GetTimeStamp()
    end

    GB.sessionItems = GB.savedVariables.sessionItems

    --------------------------------------------------------
    -- CREATE UI
    --------------------------------------------------------

    if GB.CreateWindow then
        GB.CreateWindow()
    end

    if GB.CreateStatsWindow then
        GB.CreateStatsWindow()
    end

    --------------------------------------------------------
    -- SLASH COMMANDS
    --------------------------------------------------------

    RegisterSlashCommands()

    --------------------------------------------------------
    -- LOOT TRACKING
    --------------------------------------------------------

    if GB.RegisterTracking then
        GB.RegisterTracking()
    end

    --------------------------------------------------------
    -- SESSION TIMER
    --------------------------------------------------------

    EVENT_MANAGER:RegisterForUpdate(
        ADDON_NAME .. "_SessionTimer",
        1000,
        function()
            if GB.UpdateSessionTimer then
                GB.UpdateSessionTimer()
            end
        end
    )

    --------------------------------------------------------
    -- LOAD MESSAGE
    --------------------------------------------------------

    CHAT_SYSTEM:AddMessage(
        "|c66CCFF[Gather Buddy]|r "
            .. "Gather Buddy by "
            .. "|c66FF66@everdeen|r "
            .. "|cAAAAAAv"
            .. ADDON_VERSION
            .. "|r"
    )
end

------------------------------------------------------------
-- ADDON LOADED
------------------------------------------------------------

local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(
        ADDON_NAME,
        EVENT_ADD_ON_LOADED
    )

    --------------------------------------------------------
    -- SERVER-SPECIFIC SAVED VARIABLES
    --------------------------------------------------------

    GB.worldName = GetWorldName()

    GB.savedVariables =
        ZO_SavedVars:NewAccountWide(
            "GatherBuddySavedVariables",
            1,
            GB.worldName,
            defaults
        )

    ValidateSavedVariables()

    --------------------------------------------------------
    -- SETTINGS
    --------------------------------------------------------

    if GB.CreateSettingsPanel then
        GB.CreateSettingsPanel()
    end

    --------------------------------------------------------
    -- PLAYER ACTIVATED
    --------------------------------------------------------

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME,
        EVENT_PLAYER_ACTIVATED,
        OnPlayerActivated
    )
end

------------------------------------------------------------
-- INITIAL EVENT REGISTRATION
------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent(
    ADDON_NAME,
    EVENT_ADD_ON_LOADED,
    OnAddOnLoaded
)