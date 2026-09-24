local SlashCommandActions = {}

---@param enabled boolean
local function SetEnabled(enabled)
    PreviewAnywhere.state.savedVars.enabled = enabled
    PreviewAnywhere.Log(string.format("Preview keybinds %s", enabled and "enabled" or "disabled"))
end

---Dump the load-time diagnostics to chat so failures on console are visible.
local function PrintDebugReport()
    local Log = PreviewAnywhere.Log
    local diagnostics = PreviewAnywhere.diagnostics

    Log(string.format("v%s | initialized=%s lateInit=%s", PreviewAnywhere.version, tostring(diagnostics.initialized), tostring(diagnostics.lateInit)))
    Log(string.format("state=%s | linkInjections=%d bankSceneShows=%d", PreviewAnywhere.state and "ok" or "nil", diagnostics.linkInjections, diagnostics.bankSceneShows))

    if #diagnostics.initErrors == 0 then
        Log("initErrors: none")
    else
        for _, err in ipairs(diagnostics.initErrors) do
            Log("initError: " .. err)
        end
    end

    Log(string.format("addonNames seen (%d): %s", #diagnostics.addonNames, table.concat(diagnostics.addonNames, ", ")))
end

---@param args string Raw command arguments
function SlashCommandActions.HandleCommand(args)
    local command = PreviewAnywhere.SlashCommandUtils.ParseCommand(args)

    if command == "debug" then
        PrintDebugReport()
        return
    end

    if not PreviewAnywhere.state then
        PreviewAnywhere.Log("Not initialized yet - run /pva debug for details")
        return
    end

    if command == "on" then
        SetEnabled(true)
    elseif command == "off" then
        SetEnabled(false)
    elseif command == "" then
        SetEnabled(not PreviewAnywhere.state.savedVars.enabled)
    else
        PreviewAnywhere.Log(string.format("Unknown command: %s (usage: /pva [on|off|debug])", command))
    end
end

PreviewAnywhere.SlashCommandActions = SlashCommandActions
