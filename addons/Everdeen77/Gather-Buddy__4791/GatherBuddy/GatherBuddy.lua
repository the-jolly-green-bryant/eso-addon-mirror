GatherBuddy = GatherBuddy or {}

local GB = GatherBuddy

------------------------------------------------------------
-- ADDON INFORMATION
------------------------------------------------------------

GB.ADDON_NAME = "GatherBuddy"
GB.ADDON_VERSION = "1.3"

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

    -- Main window size
    width = GB.DEFAULT_WIDTH,
    height = GB.DEFAULT_HEIGHT,

    -- Stats window position
    statsLeft = nil,
    statsTop = nil,

    -- History window position
    historyLeft = nil,
    historyTop = nil,

    -- Rare Material Alert
    rareAlertEnabled = true,
    rareAlertDuration = 4,
    rareAlertLeft = nil,
    rareAlertTop = nil,

    -- Current session
    sessionItems = {},
    sessionStartTime = nil,

    -- Used to determine when the previous session actually ended.
    -- This prevents offline time from being counted.
    sessionLastSeenTime = nil,
    sessionLastDateText = nil,
    sessionLastClockText = nil,

    -- Last completed farming sessions
    sessionHistory = {},

    -- Main window visibility
    isHidden = false,

    -- Window movement / resizing lock
    isLocked = false,

    -- 0 = solid black
    -- 255 = fully transparent
    backgroundTransparency = 64,

    -- Independent font sizes
    mainFontSize = 13,
    statsFontSize = 13,
    historyFontSize = 13,
}

------------------------------------------------------------
-- SESSION TIME
------------------------------------------------------------

function GB.FormatSessionTime(totalSeconds)
    totalSeconds =
        math.max(
            0,
            math.floor(totalSeconds)
        )

    local hours =
        math.floor(
            totalSeconds / 3600
        )

    local minutes =
        math.floor(
            (totalSeconds % 3600) / 60
        )

    local seconds =
        totalSeconds % 60

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
        GetTimeStamp()
            - GB.savedVariables.sessionStartTime
    )
end

------------------------------------------------------------
-- START NEW SESSION
------------------------------------------------------------

local function StartNewSession()
    GB.savedVariables.sessionItems = {}

    GB.sessionItems =
        GB.savedVariables.sessionItems

    GB.savedVariables.sessionStartTime =
        GetTimeStamp()

    if GB.ResetSessionCheckpoint then
        GB.ResetSessionCheckpoint()
    end
end

------------------------------------------------------------
-- CLEAR SESSION
------------------------------------------------------------

function GB.ClearSession()
    --------------------------------------------------------
    -- ARCHIVE CURRENT SESSION FIRST
    --------------------------------------------------------

    if GB.ArchiveCurrentSession then
        GB.ArchiveCurrentSession(false)
    end

    --------------------------------------------------------
    -- START FRESH SESSION
    --------------------------------------------------------

    StartNewSession()

    if GB.UpdateMaterialList then
        GB.UpdateMaterialList()
    end

    if GB.UpdateSessionTimer then
        GB.UpdateSessionTimer()
    end
end

------------------------------------------------------------
-- RESET UI POSITION / SIZE
------------------------------------------------------------

function GB.ResetWindowPositionsAndSize()
    if GB.savedVariables == nil then
        return
    end

    --------------------------------------------------------
    -- RESET SAVED VALUES
    --------------------------------------------------------

    GB.savedVariables.left = nil
    GB.savedVariables.top = nil

    GB.savedVariables.width =
        GB.DEFAULT_WIDTH

    GB.savedVariables.height =
        GB.DEFAULT_HEIGHT

    GB.savedVariables.statsLeft = nil
    GB.savedVariables.statsTop = nil

    GB.savedVariables.historyLeft = nil
    GB.savedVariables.historyTop = nil

    GB.savedVariables.rareAlertLeft = nil
    GB.savedVariables.rareAlertTop = nil

    --------------------------------------------------------
    -- RESET MAIN WINDOW
    --------------------------------------------------------

    if GB.mainWindow then
        GB.mainWindow:ClearAnchors()

        GB.mainWindow:SetDimensions(
            GB.DEFAULT_WIDTH,
            GB.DEFAULT_HEIGHT
        )

        GB.mainWindow:SetAnchor(
            CENTER,
            GuiRoot,
            CENTER,
            0,
            0
        )
    end

    --------------------------------------------------------
    -- RESET STATS WINDOW
    --------------------------------------------------------

    if GB.statsWindow then
        GB.statsWindow:ClearAnchors()

        if GB.mainWindow then
            GB.statsWindow:SetAnchor(
                TOPLEFT,
                GB.mainWindow,
                TOPRIGHT,
                10,
                0
            )
        else
            GB.statsWindow:SetAnchor(
                CENTER,
                GuiRoot,
                CENTER,
                0,
                0
            )
        end
    end

    --------------------------------------------------------
    -- RESET HISTORY WINDOW
    --------------------------------------------------------

    if GB.historyWindow then
        GB.historyWindow:ClearAnchors()

        if GB.statsWindow then
            GB.historyWindow:SetAnchor(
                TOPLEFT,
                GB.statsWindow,
                TOPRIGHT,
                10,
                0
            )
        else
            GB.historyWindow:SetAnchor(
                CENTER,
                GuiRoot,
                CENTER,
                0,
                0
            )
        end
    end

    --------------------------------------------------------
    -- RESET RARE ALERT POSITION
    --------------------------------------------------------

    if GB.ResetRareAlertPosition then
        GB.ResetRareAlertPosition()
    end

    --------------------------------------------------------
    -- REFRESH MAIN WINDOW LAYOUT
    --------------------------------------------------------

    if GB.UpdateMaterialList then
        GB.UpdateMaterialList()
    end

    CHAT_SYSTEM:AddMessage(
        "|c66CCFF[Gather Buddy]|r "
            .. "Window positions and size reset."
    )
end

------------------------------------------------------------
-- SLASH COMMANDS
------------------------------------------------------------

local function RegisterSlashCommands()
    SLASH_COMMANDS["/gbuddy"] =
        function(args)
            local command =
                string.lower(
                    zo_strtrim(
                        args or ""
                    )
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

            elseif command == "reset" then
                if GB.ResetWindowPositionsAndSize then
                    GB.ResetWindowPositionsAndSize()
                end

            else
                CHAT_SYSTEM:AddMessage(
                    "|c66CCFF[Gather Buddy]|r "
                        .. "Commands: "
                        .. "/gbuddy, "
                        .. "/gbuddy lock, "
                        .. "/gbuddy unlock, "
                        .. "/gbuddy reset"
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

    if GB.savedVariables.sessionHistory == nil then
        GB.savedVariables.sessionHistory = {}
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

    if GB.savedVariables.mainFontSize == nil then
        GB.savedVariables.mainFontSize = 13
    end

    if GB.savedVariables.statsFontSize == nil then
        GB.savedVariables.statsFontSize = 13
    end

    if GB.savedVariables.historyFontSize == nil then
        GB.savedVariables.historyFontSize = 13
    end

    if GB.savedVariables.rareAlertEnabled == nil then
        GB.savedVariables.rareAlertEnabled = true
    end

    if GB.savedVariables.rareAlertDuration == nil then
        GB.savedVariables.rareAlertDuration = 4
    end

    if GB.savedVariables.width == nil then
        GB.savedVariables.width =
            GB.DEFAULT_WIDTH
    end

    if GB.savedVariables.height == nil then
        GB.savedVariables.height =
            GB.DEFAULT_HEIGHT
    end
end

------------------------------------------------------------
-- RESTORE OR START SESSION
------------------------------------------------------------

local function PrepareSession(initial)
    --------------------------------------------------------
    -- MAKE SAVED SESSION AVAILABLE TO HISTORY MODULE
    --------------------------------------------------------

    GB.sessionItems =
        GB.savedVariables.sessionItems

    --------------------------------------------------------
    -- FULL LOGIN
    --------------------------------------------------------

    if initial then
        -- Archive the session that was active when the player
        -- last logged out. Empty sessions are ignored.
        if GB.ArchiveCurrentSession then
            GB.ArchiveCurrentSession(true)
        end

        StartNewSession()
        return
    end

    --------------------------------------------------------
    -- /RELOADUI
    --------------------------------------------------------

    -- A UI reload must continue the existing session.
    if GB.savedVariables.sessionStartTime == nil then
        GB.savedVariables.sessionStartTime =
            GetTimeStamp()
    end

    GB.sessionItems =
        GB.savedVariables.sessionItems

    if GB.ResetSessionCheckpoint then
        GB.ResetSessionCheckpoint()
    end
end

------------------------------------------------------------
-- PLAYER ACTIVATED
------------------------------------------------------------

local function OnPlayerActivated(
    eventCode,
    initial
)
    EVENT_MANAGER:UnregisterForEvent(
        ADDON_NAME,
        EVENT_PLAYER_ACTIVATED
    )

    --------------------------------------------------------
    -- SESSION
    --------------------------------------------------------

    PrepareSession(initial)

    --------------------------------------------------------
    -- CREATE WINDOWS
    --------------------------------------------------------

    if GB.CreateWindow then
        GB.CreateWindow()
    end

    if GB.CreateStatsWindow then
        GB.CreateStatsWindow()
    end

    if GB.CreateHistoryWindow then
        GB.CreateHistoryWindow()
    end

    if GB.CreateRareAlertWindow then
        GB.CreateRareAlertWindow()
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
    -- SESSION TIMER / CHECKPOINT
    --------------------------------------------------------

    EVENT_MANAGER:RegisterForUpdate(
        ADDON_NAME .. "_SessionTimer",
        1000,
        function()
            if GB.UpdateSessionTimer then
                GB.UpdateSessionTimer()
            end

            if GB.UpdateSessionCheckpoint then
                GB.UpdateSessionCheckpoint()
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

local function OnAddOnLoaded(
    eventCode,
    addonName
)
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

    GB.worldName =
        GetWorldName()

    GB.savedVariables =
        ZO_SavedVars:NewAccountWide(
            "GatherBuddySavedVariables",
            1,
            GB.worldName,
            defaults
        )

    ValidateSavedVariables()

    --------------------------------------------------------
    -- HISTORY
    --------------------------------------------------------

    if GB.InitializeHistory then
        GB.InitializeHistory()
    end

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