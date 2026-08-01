local ADDON_NAME = "DebugLogViewer"
DebugLogViewer = {
    internal = {
        class = {},
        gettext = LibGetText(ADDON_NAME).gettext,
        callbackObject = ZO_CallbackObject:New(),
        FireCallbacks = function(self, ...)
            self.callbackObject:FireCallbacks(...)
        end,
        LOG_DATA = 1,
        TIME_FILTER_SESSION = 1,
        TIME_FILTER_UI_LOAD = 2,
        TIME_FILTER_ALL = 3,
        LEVEL_TO_LOCALIZED_STRING = {},
        callback = {
            OPEN_LOG_DETAILS = "OpenLogDetails",
            OPEN_SETTINGS = "OpenSettings",
            REFRESH_QUICK_LOG = "RefreshQuickLog",
            REFRESH_LOG_VIEWER = "RefreshLogViewer",
        },
    },
    RegisterCallback = function(self, ...)
        self.internal.callbackObject:RegisterCallback(...)
    end,
}

local DLV = DebugLogViewer
local LDL = LibDebugLogger
local ZO_ERROR_FRAME = ZO_ERROR_FRAME
local EscapeMarkup = EscapeMarkup
local ALLOW_MARKUP_TYPE_NONE = ALLOW_MARKUP_TYPE_NONE

local internal = DLV.internal
local class = internal.class
local gettext = internal.gettext
local CombineSplitStringIfNeeded = LDL.CombineSplitStringIfNeeded

local LEVEL_TO_LOCALIZED_STRING = internal.LEVEL_TO_LOCALIZED_STRING
local LOG_DETAIL_MESSAGE_TEMPLATE = "%s\n|r%s"
local LOG_DETAIL_TITLE_TEMPLATE = "%s %s: %s"

local nextEventHandleIndex = 1

local function RegisterForEvent(event, callback, eventHandleName)
    if(not eventHandleName) then
        eventHandleName = ADDON_NAME .. nextEventHandleIndex
        nextEventHandleIndex = nextEventHandleIndex + 1
    end
    EVENT_MANAGER:RegisterForEvent(eventHandleName, event, callback)
    return eventHandleName
end

local function UnregisterForEvent(event, name)
    EVENT_MANAGER:UnregisterForEvent(name, event)
end

local function PrepareOutput(output)
    output = CombineSplitStringIfNeeded(output)
    if(output) then
        -- escape tags so we can see them
        return EscapeMarkup(output, ALLOW_MARKUP_TYPE_NONE)
    end
end
internal.PrepareOutput = PrepareOutput

local function OnAddonLoaded(callback)
    local eventHandle = ""
    eventHandle = RegisterForEvent(EVENT_ADD_ON_LOADED, function(event, name)
        if(name ~= ADDON_NAME) then return end
        callback()
        UnregisterForEvent(event, eventHandle)
    end)
end

-- some preparations that should happen as early as possible
LDL:SetBlockChatOutputEnabled(true)
EVENT_MANAGER:UnregisterForEvent("ErrorFrame", EVENT_LUA_ERROR)

OnAddonLoaded(function()
    -- TRANSLATORS: Translation of the "verbose" log level used in various title texts
    LEVEL_TO_LOCALIZED_STRING[LDL.LOG_LEVEL_VERBOSE] = gettext("Verbose")
    -- TRANSLATORS: Translation of the "debug" log level used in various title texts
    LEVEL_TO_LOCALIZED_STRING[LDL.LOG_LEVEL_DEBUG] = gettext("Debug")
    -- TRANSLATORS: Translation of the "info" log level used in various title texts
    LEVEL_TO_LOCALIZED_STRING[LDL.LOG_LEVEL_INFO] = gettext("Info")
    -- TRANSLATORS: Translation of the "warning" log level used in various title texts
    LEVEL_TO_LOCALIZED_STRING[LDL.LOG_LEVEL_WARNING] = gettext("Warning")
    -- TRANSLATORS: Translation of the "error" log level used in various title texts
    LEVEL_TO_LOCALIZED_STRING[LDL.LOG_LEVEL_ERROR] = gettext("Error")
    -- TRANSLATORS: Label for the toggle key bind in the controls menu
    ZO_CreateStringId("SI_BINDING_NAME_DLV_TOGGLE_WINDOW", gettext("Toggle Log Viewer"))

    local saveData = internal.LoadSettings("DebugLogViewer_Data")

    if GetAPIVersion() < 101038 then
        -- TRANSLATORS: Label for the dismiss button on the log entry detail window
        ZO_ERROR_FRAME.dismissControl:SetText(gettext("Dismiss"))
    else
        -- have to replace it, because the original calls a private function when we open the errorframe
        function ZO_IsPregameUI() return false end
    end

    local quickLog = class.QuickLog:New(saveData)
    local logViewer = class.LogViewer:New(saveData)
    local logManager = class.LogManager:New(quickLog, logViewer)

    internal.quickLog = quickLog
    internal.logViewer = logViewer
    internal.logManager = logManager

    local lastLogId
    DLV:RegisterCallback(internal.callback.OPEN_LOG_DETAILS, function(logId)
        if(lastLogId == logId and not ZO_ERROR_FRAME.control:IsHidden()) then
            ZO_ERROR_FRAME:HideAllErrors()
            return
        end

        local entry = logManager:GetLogData(logId)
        if(entry) then
            lastLogId = logId

            local _, _, _, level, tag, message, trace, errorCode = unpack(entry.log)
            if(not message) then return end

            message = PrepareOutput(message)
            if(trace and trace ~= "") then
                message = LOG_DETAIL_MESSAGE_TEMPLATE:format(message, CombineSplitStringIfNeeded(trace))
            end

            ZO_ERROR_FRAME.suppressErrorDialog = false
            ZO_ERROR_FRAME:HideAllErrors()
            ZO_ERROR_FRAME:OnUIError(message, errorCode)
            local colorizedErrorHexCode = ZO_SELECTED_TEXT:Colorize(ZO_ERROR_FRAME.errorHexCode or "")
            ZO_ERROR_FRAME.titleControl:SetText(LOG_DETAIL_TITLE_TEMPLATE:format(tag, LEVEL_TO_LOCALIZED_STRING[level], colorizedErrorHexCode))
            if GetAPIVersion() >= 101038 then
                ZO_ERROR_FRAME.suppressKeybind:SetHidden(true) -- always hide it, otherwise we cannot show the error frame again
                ZO_ERROR_FRAME.copyErrorCodeButton:SetHidden(ZO_ERROR_FRAME.errorHexCode == "")
            end
        end
    end)

    -- public api

    function DLV.ToggleWindow()
        logViewer:Toggle()
    end

    function DLV.ShowWindow()
        logViewer:Show()
    end

    function DLV.HideWindow()
        logViewer:Hide()
    end

    function DLV.IsWindowShowing()
        return logViewer:IsShowing()
    end

    function DLV.IsQuickLogShowing()
        return quickLog:IsShowing()
    end

    SLASH_COMMANDS["/logviewer"] = DLV.ToggleWindow
end)
