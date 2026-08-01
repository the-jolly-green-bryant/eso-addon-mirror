local function Initialize()
    local State = ChatLogPreserver.State

    ChatLogPreserver.state = State.Create()
    ChatLogPreserver.state.savedVars = ZO_SavedVars:NewAccountWide(
        ChatLogPreserver.savedVarsName,
        ChatLogPreserver.savedVarsVersion,
        nil,
        ChatLogPreserver.state.savedVars
    )

    EVENT_MANAGER:RegisterForEvent(ChatLogPreserver.name, EVENT_PLAYER_ACTIVATED, function(_eventId, initial)
        ChatLogPreserver.Actions.OnPlayerActivated(initial)
    end)

    ChatLogPreserver.Actions.OnAddonLoaded()
    if ChatLogPreserver.Settings and ChatLogPreserver.Settings.Initialize then
        ChatLogPreserver.Settings.Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(ChatLogPreserver.name, EVENT_ADD_ON_LOADED, function(_eventId, addonName)
    if addonName == ChatLogPreserver.name then
        Initialize()
        EVENT_MANAGER:UnregisterForEvent(ChatLogPreserver.name, EVENT_ADD_ON_LOADED)
    end
end)
