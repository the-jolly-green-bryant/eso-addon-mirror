local RideAlong = RideAlong

local function Initialize()
    local State = RideAlong.State

    RideAlong.state = State.Create()
    RideAlong.state.savedVars = ZO_SavedVars:NewAccountWide(
        RideAlong.savedVarsName,
        RideAlong.savedVarsVersion,
        nil,
        RideAlong.state.savedVars
    )

    SLASH_COMMANDS["/ral"] = RideAlong.SlashCommandActions.HandleCommand
    SLASH_COMMANDS["/ridealong"] = RideAlong.SlashCommandActions.HandleCommand

    RideAlong.RideActions.Initialize()

    RideAlong.Log(string.format("Loaded v%s", RideAlong.version))
end

EVENT_MANAGER:RegisterForEvent(RideAlong.name, EVENT_ADD_ON_LOADED, function(_eventId, addonName)
    if addonName == RideAlong.name then
        Initialize()
        EVENT_MANAGER:UnregisterForEvent(RideAlong.name, EVENT_ADD_ON_LOADED)
    end
end)
