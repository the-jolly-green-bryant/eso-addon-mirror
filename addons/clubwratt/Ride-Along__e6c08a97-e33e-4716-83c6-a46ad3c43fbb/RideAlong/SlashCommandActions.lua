local SlashCommandActions = {}

---@param enabled boolean
local function SetEnabled(enabled)
    RideAlong.state.savedVars.enabled = enabled
    RideAlong.Log(string.format("Ride prompt %s", enabled and "enabled" or "disabled"))
end

---@param args string Raw command arguments
function SlashCommandActions.HandleCommand(args)
    local command = RideAlong.SlashCommandUtils.ParseCommand(args)

    if command == "on" then
        SetEnabled(true)
    elseif command == "off" then
        SetEnabled(false)
    elseif command == "" then
        SetEnabled(not RideAlong.state.savedVars.enabled)
    else
        RideAlong.Log(string.format("Unknown command: %s (usage: /ral [on|off])", command))
    end
end

RideAlong.SlashCommandActions = SlashCommandActions
