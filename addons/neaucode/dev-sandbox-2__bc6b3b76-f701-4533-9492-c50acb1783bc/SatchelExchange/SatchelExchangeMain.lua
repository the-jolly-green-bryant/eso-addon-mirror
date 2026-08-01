-- SatchelExchangeMain.lua: Entry point; wires state, saved vars, and the store keybind.

---@type LibConsoleLogger
local CL = LibConsoleLogger

local SatchelExchange = SatchelExchange

local function Initialize()
    local State = SatchelExchange.State

    SatchelExchange.state = State.Create()
    SatchelExchange.state.savedVars = ZO_SavedVars:NewAccountWide(
        SatchelExchange.savedVarsName,
        SatchelExchange.savedVarsVersion,
        nil,
        SatchelExchange.state.savedVars
    )

    SatchelExchange.KeybindActions.Initialize()
    SatchelExchange.StoreActions.InitializeSessionHandlers()
    SatchelExchange.UnboxActions.InitializePersistentHandlers()
    SatchelExchange.SettingsActions.Initialize()

    CL:Log(string.format("[%s] Loaded v%s", SatchelExchange.name, SatchelExchange.version))
end

EVENT_MANAGER:RegisterForEvent(SatchelExchange.name, EVENT_ADD_ON_LOADED, function(_eventId, addonName)
    if addonName == SatchelExchange.name then
        Initialize()
        EVENT_MANAGER:UnregisterForEvent(SatchelExchange.name, EVENT_ADD_ON_LOADED)
    end
end)
