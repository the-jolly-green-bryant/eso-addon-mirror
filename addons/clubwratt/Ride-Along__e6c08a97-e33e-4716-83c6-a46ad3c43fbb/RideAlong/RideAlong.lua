-- RideAlong.lua: Root namespace
RideAlong = {
    name = "RideAlong",
    version = "0.1.0",
    savedVarsName = "RideAlongSavedVars",
    savedVarsVersion = 1,
    ---@type RideAlongState
    state = nil,
}

---Log through LibConsoleLogger when available, otherwise to the chat router.
---@param message string
function RideAlong.Log(message)
    local line = string.format("[%s] %s", RideAlong.name, message)
    if LibConsoleLogger then
        LibConsoleLogger:Log(line)
    elseif CHAT_ROUTER then
        CHAT_ROUTER:AddSystemMessage(line)
    end
end
