-- ChatLogPreserverActions.lua: Imperative actions

local ChatLogPreserverActions = {}

local MAX_RESTORE_ATTEMPTS = 10
local RESTORE_RETRY_DELAY_MS = 200

local function GetState()
    return ChatLogPreserver.state
end

local function GetSavedVars()
    local state = GetState()
    if not state then
        return nil
    end
    return state.savedVars
end

local function GetSettings()
    local savedVars = GetSavedVars()
    if not savedVars then
        return nil
    end
    return savedVars.settings
end

local function NotifyLogDialog(history)
    local logDialog = ChatLogPreserver.LogDialog
    if logDialog and logDialog.RefreshIfVisible then
        logDialog:RefreshIfVisible(history)
    end
end

local function ShouldCapture()
    local state = GetState()
    local settings = GetSettings()
    if not state or not settings then
        return false
    end
    if state.isRestoring then
        return false
    end
    return settings.enabled == true
end

local function AppendHistory(message, category)
    local savedVars = GetSavedVars()
    local settings = GetSettings()
    if not savedVars or not settings then
        return
    end

    if not savedVars.history then
        savedVars.history = {}
    end

    savedVars.history[#savedVars.history + 1] = {
        message = message,
        category = category,
    }

    ChatLogPreserver.Utils.TrimHistory(savedVars.history, settings.maxEntries or 0)
    NotifyLogDialog(savedVars.history)
end

local function OnFormattedChatMessage(message, category)
    if not message or not category then
        return
    end
    if not ShouldCapture() then
        return
    end
    AppendHistory(message, category)
end

local function ReprintFormattedMessage(message, category)
    if not message or not category then
        return
    end
    if CHAT_ROUTER and CHAT_ROUTER.FireCallbacks then
        CHAT_ROUTER:FireCallbacks("FormattedChatMessage", message, category, nil, nil, nil, nil, nil)
        return
    end

    local chatSystem = ZO_GetChatSystem()
    if chatSystem and chatSystem.OnFormattedChatMessage then
        chatSystem:OnFormattedChatMessage(message, category, nil, nil, nil, nil, nil)
    end
end

local function RestoreHistoryInternal(attempt)
    local state = GetState()
    local savedVars = GetSavedVars()
    local settings = GetSettings()
    if not state or not savedVars or not settings then
        return
    end
    if not settings.enabled then
        return
    end
    if state.didRestore then
        return
    end

    local history = savedVars.history
    if not history or #history == 0 then
        state.didRestore = true
        return
    end

    local chatSystem = ZO_GetChatSystem()
    if not chatSystem or not chatSystem.loaded then
        if attempt < MAX_RESTORE_ATTEMPTS then
            zo_callLater(function()
                RestoreHistoryInternal(attempt + 1)
            end, RESTORE_RETRY_DELAY_MS)
        end
        return
    end

    state.isRestoring = true
    for i = 1, #history do
        local entry = history[i]
        ReprintFormattedMessage(entry.message, entry.category)
    end
    state.isRestoring = false
    state.didRestore = true
end

function ChatLogPreserverActions.RegisterChatCallback()
    local state = GetState()
    if not state or state.isChatCallbackRegistered then
        return
    end
    CHAT_ROUTER:RegisterCallback("FormattedChatMessage", OnFormattedChatMessage)
    state.isChatCallbackRegistered = true
end

function ChatLogPreserverActions.RestoreHistory()
    RestoreHistoryInternal(1)
end

function ChatLogPreserverActions.EnforceMaxEntries()
    local savedVars = GetSavedVars()
    local settings = GetSettings()
    if not savedVars or not settings then
        return
    end
    ChatLogPreserver.Utils.TrimHistory(savedVars.history, settings.maxEntries or 0)
    NotifyLogDialog(savedVars.history)
end

function ChatLogPreserverActions.ClearHistory()
    local savedVars = GetSavedVars()
    if not savedVars then
        return
    end
    savedVars.history = {}
    NotifyLogDialog(savedVars.history)
end

function ChatLogPreserverActions.OnAddonLoaded()
    ChatLogPreserverActions.RegisterChatCallback()
end

---@param _initial boolean
function ChatLogPreserverActions.OnPlayerActivated(_initial)
    ChatLogPreserverActions.RestoreHistory()
end

ChatLogPreserver.Actions = ChatLogPreserverActions
