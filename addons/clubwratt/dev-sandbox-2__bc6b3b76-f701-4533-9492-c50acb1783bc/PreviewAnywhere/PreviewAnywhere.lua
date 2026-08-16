-- PreviewAnywhere.lua: Root namespace
PreviewAnywhere = {
    name = "PreviewAnywhere",
    version = "0.1.1",
    savedVarsName = "PreviewAnywhereSavedVars",
    savedVarsVersion = 1,
    ---@type PreviewAnywhereState
    state = nil,
    ---In-memory record of what happened during load, dumped by "/pva debug".
    ---Lives here (first manifest file) so every later file can write to it.
    ---@type PreviewAnywhereDiagnostics
    diagnostics = {
        addonNames = {},
        initErrors = {},
        initialized = false,
        lateInit = false,
        linkInjections = 0,
        bankSceneShows = 0,
    },
}

---Log through LibConsoleLogger when available, otherwise to the chat router.
---@param message string
function PreviewAnywhere.Log(message)
    local line = string.format("[%s] %s", PreviewAnywhere.name, message)
    if LibConsoleLogger then
        LibConsoleLogger:Log(line)
    elseif CHAT_ROUTER then
        CHAT_ROUTER:AddSystemMessage(line)
    end
end
