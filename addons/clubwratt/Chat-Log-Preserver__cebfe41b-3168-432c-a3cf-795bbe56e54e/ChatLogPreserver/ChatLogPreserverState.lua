-- ChatLogPreserverState.lua: Pure data initialization
-- Creates the initial state structure (defaults).

local ChatLogPreserverState = {}

function ChatLogPreserverState.Create()
    ---@type ChatLogPreserverSettingsData
    local settingsDefaults = {
        enabled = true,
        maxEntries = 200,
    }

    ---@type ChatLogPreserverSavedVars
    local savedVars = {
        settings = {
            enabled = settingsDefaults.enabled,
            maxEntries = settingsDefaults.maxEntries,
        },
        history = {},
    }

    ---@type ChatLogPreserverStateData
    return {
        settingsDefaults = settingsDefaults,
        savedVars = savedVars,
        isRestoring = false,
        didRestore = false,
        isChatCallbackRegistered = false,
    }
end

ChatLogPreserver.State = ChatLogPreserverState
