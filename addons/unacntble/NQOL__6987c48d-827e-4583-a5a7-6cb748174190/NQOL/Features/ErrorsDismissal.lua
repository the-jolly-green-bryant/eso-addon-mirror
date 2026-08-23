NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local ErrorsDismissal = {}

local MODE_ON = "on"
local MODE_ON_AND_LOG = "onAndLog"
local MODE_OFF = "off"
local VALID_MODES = {
    [MODE_ON] = true,
    [MODE_ON_AND_LOG] = true,
    [MODE_OFF] = true,
}
local ERROR_EVENT_NAMESPACE = "NQOL_ErrorsDismissal"
local CHAT_KEYBIND_RETRY_NAMESPACE = "NQOL_ErrorsDismissal_ChatKeybind"
local CHAT_KEYBIND_MARKER = "nqolErrorsDismissal"
local CHAT_ENTRY_ERROR_ID = "nqolErrorsDismissalId"
local MAX_QUEUED_ERRORS = 5

local FEATURE_NAME = NQOL.L("features.errors_dismissal.feature_name")
NQOL.Lexicon.RegisterRefreshCallback(function()
    FEATURE_NAME = NQOL.L("features.errors_dismissal.feature_name")
end)

local defaults = {
    utility = {
        errorsDismissal = MODE_OFF,
    },
}

local savedVariables
local initialized = false
local listenerRegistered = false
local nativeListenerRemoved = false
local ownsNativeSuppression = false
local previousNativeSuppression
local chatKeybindRetryRegistered = false
local handlingError = false
local nextErrorId = 0
local queuedErrors = {}
local errorsById = {}

local function GetSettings()
    local settings = NQOL.Settings.GetSection(savedVariables, defaults, "utility")
    NQOL.Settings.Choice(settings, defaults.utility, "errorsDismissal", VALID_MODES)
    return settings
end

local function GetMode()
    return GetSettings().errorsDismissal
end

local function IsEnabled()
    return GetMode() ~= MODE_OFF
end

local function ForwardToNativeErrorFrame(_, ...)
    if ZO_ERROR_FRAME and type(ZO_ERROR_FRAME.OnUIError) == "function" then
        ZO_ERROR_FRAME:OnUIError(...)
    end
end

local function RemoveNativeErrorListener()
    if nativeListenerRemoved or not EVENT_MANAGER or not EVENT_LUA_ERROR then
        return
    end

    EVENT_MANAGER:UnregisterForEvent("ErrorFrame", EVENT_LUA_ERROR)
    nativeListenerRemoved = true
end

local function RestoreNativeErrorListener()
    if not nativeListenerRemoved or not EVENT_MANAGER or not EVENT_LUA_ERROR then
        return
    end

    EVENT_MANAGER:RegisterForEvent("ErrorFrame", EVENT_LUA_ERROR, ForwardToNativeErrorFrame)
    nativeListenerRemoved = false
end

local function SetNativeFrameUnsuppressed(enabled)
    if not ZO_ERROR_FRAME then
        return
    end

    if enabled then
        if not ownsNativeSuppression then
            previousNativeSuppression = ZO_ERROR_FRAME.suppressErrorDialog == true
            ownsNativeSuppression = true

            if ZO_ERROR_FRAME.displayingError and type(ZO_ERROR_FRAME.HideErrorFrame) == "function" then
                ZO_ERROR_FRAME:HideErrorFrame(false)
            end
        end

        ZO_ERROR_FRAME.suppressErrorDialog = false
    elseif ownsNativeSuppression then
        if ZO_ERROR_FRAME.suppressErrorDialog == false then
            ZO_ERROR_FRAME.suppressErrorDialog = previousNativeSuppression
        end

        previousNativeSuppression = nil
        ownsNativeSuppression = false
    end
end

local function FormatErrorTitle(errorCode)
    local errorHexCode = ""
    if tonumber(errorCode) then
        errorHexCode = string.format("%X", tonumber(errorCode))
    end

    if ZO_SELECTED_TEXT and type(ZO_SELECTED_TEXT.Colorize) == "function" then
        errorHexCode = ZO_SELECTED_TEXT:Colorize(errorHexCode)
    end

    if zo_strformat and SI_WINDOW_TITLE_UI_ERROR then
        return zo_strformat(SI_WINDOW_TITLE_UI_ERROR, errorHexCode)
    end

    return FEATURE_NAME
end

local function QueueError(errorString, errorCode)
    nextErrorId = nextErrorId + 1
    local errorData = {
        id = nextErrorId,
        errorString = tostring(errorString),
        errorCode = errorCode,
    }

    queuedErrors[#queuedErrors + 1] = errorData
    errorsById[errorData.id] = errorData

    if #queuedErrors > MAX_QUEUED_ERRORS then
        local expiredError = table.remove(queuedErrors, 1)
        errorsById[expiredError.id] = nil
    end

    return errorData
end

local function GetSelectedError(chatMenu)
    if not IsEnabled()
        or not chatMenu
        or not chatMenu.list
        or type(chatMenu.list.GetTargetData) ~= "function"
    then
        return nil
    end

    local targetData = chatMenu.list:GetTargetData()
    local entryData = targetData and targetData.data
    local errorId = entryData and entryData[CHAT_ENTRY_ERROR_ID]
    return errorId and errorsById[errorId] or nil
end

local function ShowSelectedError(chatMenu)
    local errorData = GetSelectedError(chatMenu)
    local errorFrame = ZO_ERROR_FRAME
    if not errorData or not errorFrame or type(errorFrame.OnUIError) ~= "function" then
        return
    end

    errorFrame.suppressErrorDialog = false

    local errorCode = errorData.errorCode
    local wasErrorCodeSuppressed = false
    if errorCode ~= nil and type(errorFrame.suppressedErrors) == "table" then
        wasErrorCodeSuppressed = errorFrame.suppressedErrors[errorCode] == true
        errorFrame.suppressedErrors[errorCode] = nil
    end

    errorFrame:OnUIError(errorData.errorString, errorCode)

    if wasErrorCodeSuppressed then
        errorFrame.suppressedErrors[errorCode] = true
    end
end

local function ResolveKeybindValue(value, ...)
    if type(value) == "function" then
        return value(...)
    end

    return value
end

local function RestoreChatKeybind(chatMenu)
    local descriptor = chatMenu and chatMenu.chatEntryListKeybindDescriptor
    if type(descriptor) ~= "table" then
        return
    end

    for _, keybindDescriptor in ipairs(descriptor) do
        local original = keybindDescriptor[CHAT_KEYBIND_MARKER]
        if type(original) == "table" then
            if keybindDescriptor.name == original.wrappedName then
                keybindDescriptor.name = original.name
            end
            if keybindDescriptor.callback == original.wrappedCallback then
                keybindDescriptor.callback = original.callback
            end
            if keybindDescriptor.enabled == original.wrappedEnabled then
                keybindDescriptor.enabled = original.enabled
            end
            if keybindDescriptor.visible == original.wrappedVisible then
                keybindDescriptor.visible = original.visible
            end

            keybindDescriptor[CHAT_KEYBIND_MARKER] = nil
        end
    end

    if chatMenu.chatEntryPanelFocalArea and chatMenu.chatEntryPanelFocalArea.SetKeybindDescriptor then
        chatMenu.chatEntryPanelFocalArea:SetKeybindDescriptor(descriptor)
    end
end

local function WrapChatKeybind(chatMenu)
    local descriptor = chatMenu and chatMenu.chatEntryListKeybindDescriptor
    if type(descriptor) ~= "table" then
        return false
    end

    for _, keybindDescriptor in ipairs(descriptor) do
        if keybindDescriptor[CHAT_KEYBIND_MARKER] then
            return true
        end

        if keybindDescriptor.keybind == "UI_SHORTCUT_PRIMARY" then
            local original = {
                name = keybindDescriptor.name,
                callback = keybindDescriptor.callback,
                enabled = keybindDescriptor.enabled,
                visible = keybindDescriptor.visible,
            }

            original.wrappedName = function(...)
                if GetSelectedError(chatMenu) then
                    return NQOL.L("features.errors_dismissal.show_error_keybind")
                end

                return ResolveKeybindValue(original.name, ...)
            end
            original.wrappedCallback = function(...)
                if GetSelectedError(chatMenu) then
                    return ShowSelectedError(chatMenu)
                end

                if original.callback then
                    return original.callback(...)
                end
            end
            original.wrappedEnabled = function(...)
                if GetSelectedError(chatMenu) then
                    return true
                end

                if type(original.enabled) == "function" then
                    return original.enabled(...)
                end

                return original.enabled == nil or original.enabled
            end
            original.wrappedVisible = function(...)
                if GetSelectedError(chatMenu) then
                    return true
                end

                local visible = ResolveKeybindValue(original.visible, ...)
                return visible == nil or visible
            end

            keybindDescriptor.name = original.wrappedName
            keybindDescriptor.callback = original.wrappedCallback
            keybindDescriptor.enabled = original.wrappedEnabled
            keybindDescriptor.visible = original.wrappedVisible
            keybindDescriptor[CHAT_KEYBIND_MARKER] = original

            if chatMenu.chatEntryPanelFocalArea and chatMenu.chatEntryPanelFocalArea.SetKeybindDescriptor then
                chatMenu.chatEntryPanelFocalArea:SetKeybindDescriptor(descriptor)
            end

            return true
        end
    end

    return false
end

local function StopChatKeybindRetry()
    if chatKeybindRetryRegistered and EVENT_MANAGER and EVENT_MANAGER.UnregisterForUpdate then
        EVENT_MANAGER:UnregisterForUpdate(CHAT_KEYBIND_RETRY_NAMESPACE)
    end

    chatKeybindRetryRegistered = false
end

local function EnsureChatKeybind()
    if not IsEnabled() then
        StopChatKeybindRetry()
        return
    end

    if WrapChatKeybind(CHAT_MENU_GAMEPAD) then
        StopChatKeybindRetry()
        return
    end

    if not chatKeybindRetryRegistered
        and EVENT_MANAGER
        and type(EVENT_MANAGER.RegisterForUpdate) == "function"
    then
        EVENT_MANAGER:RegisterForUpdate(CHAT_KEYBIND_RETRY_NAMESPACE, 1000, EnsureChatKeybind)
        chatKeybindRetryRegistered = true
    end
end

local function GetLatestChatEntry()
    local messageEntries = CHAT_MENU_GAMEPAD and CHAT_MENU_GAMEPAD.messageEntries
    return type(messageEntries) == "table" and messageEntries[#messageEntries] or nil
end

local function TagLatestChatEntry(errorData, previousChatEntry)
    local messageEntry = GetLatestChatEntry()
    if messageEntry ~= previousChatEntry and messageEntry and type(messageEntry.data) == "table" then
        messageEntry.data[CHAT_ENTRY_ERROR_ID] = errorData.id
    end
end

local function HandleLuaError(errorString, errorCode)
    local mode = GetMode()
    if mode == MODE_OFF or handlingError or not errorString then
        return
    end

    if errorCode ~= nil
        and ZO_ERROR_FRAME
        and type(ZO_ERROR_FRAME.suppressedErrors) == "table"
        and ZO_ERROR_FRAME.suppressedErrors[errorCode]
    then
        return
    end

    handlingError = true
    if mode == MODE_ON_AND_LOG then
        local errorData = QueueError(errorString, errorCode)
        local previousChatEntry = GetLatestChatEntry()
        local logged = pcall(NQOL.Chat.Message, FormatErrorTitle(errorCode), FEATURE_NAME)
        if logged then
            TagLatestChatEntry(errorData, previousChatEntry)
            EnsureChatKeybind()
        end
    end

    handlingError = false
end

local function RegisterErrorListener()
    if listenerRegistered or not EVENT_MANAGER or not EVENT_LUA_ERROR then
        return
    end

    EVENT_MANAGER:RegisterForEvent(ERROR_EVENT_NAMESPACE, EVENT_LUA_ERROR, function(_, errorString, errorCode)
        HandleLuaError(errorString, errorCode)
    end)
    listenerRegistered = true
end

local function UnregisterErrorListener()
    if not listenerRegistered or not EVENT_MANAGER or not EVENT_LUA_ERROR then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ERROR_EVENT_NAMESPACE, EVENT_LUA_ERROR)
    listenerRegistered = false
end

local function RefreshListener()
    if not initialized then
        return
    end

    if IsEnabled() then
        RemoveNativeErrorListener()
        SetNativeFrameUnsuppressed(true)
        RegisterErrorListener()
        EnsureChatKeybind()
    else
        UnregisterErrorListener()
        StopChatKeybindRetry()
        RestoreChatKeybind(CHAT_MENU_GAMEPAD)
        SetNativeFrameUnsuppressed(false)
        RestoreNativeErrorListener()
    end
end

function ErrorsDismissal.InitializeSavedVariables()
    savedVariables = NQOL.Settings.NewAccountWide(defaults)
    GetSettings()
end

function ErrorsDismissal.Initialize()
    if initialized then
        return
    end

    initialized = true
    RefreshListener()
end

function ErrorsDismissal.GetMode()
    return GetMode()
end

function ErrorsDismissal.GetModeDefault()
    return defaults.utility.errorsDismissal
end

function ErrorsDismissal.SetMode(value)
    GetSettings().errorsDismissal = VALID_MODES[value] and value or defaults.utility.errorsDismissal
    RefreshListener()
end

function ErrorsDismissal.GetModeChoices()
    return { MODE_ON, MODE_ON_AND_LOG, MODE_OFF }
end

function ErrorsDismissal.GetModeChoiceNames()
    return {
        NQOL.L("features.errors_dismissal.choice.on"),
        NQOL.L("features.errors_dismissal.choice.on_and_log"),
        NQOL.L("features.errors_dismissal.choice.off"),
    }
end

function ErrorsDismissal.GetModeLabel()
    return FEATURE_NAME
end

function ErrorsDismissal.GetModeTooltip()
    return NQOL.L("features.errors_dismissal.tooltip")
end

NQOL.Features.ErrorsDismissal = ErrorsDismissal
