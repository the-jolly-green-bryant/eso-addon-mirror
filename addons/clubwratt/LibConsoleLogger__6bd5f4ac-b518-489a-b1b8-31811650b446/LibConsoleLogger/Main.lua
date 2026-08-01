-- Main.lua: entry point (events)

LibConsoleLogger = LibConsoleLogger or {}

local function OnAddonLoaded(_eventId, addonName)
    if addonName ~= LibConsoleLogger.name then
        return
    end

    LibConsoleLogger:_EnsureSavedVars()
    local sv = LibConsoleLogger.savedVars
    local enabled = (sv and sv.enabled) == true

    if LibConsoleLogger.State then
        LibConsoleLogger.State.runtimeEnabled = enabled
    end

    if LibConsoleLogger.Settings and LibConsoleLogger.Settings.Initialize then
        LibConsoleLogger.Settings.Initialize()
    end

    if EVENT_MANAGER and EVENT_MANAGER.UnregisterForEvent then
        EVENT_MANAGER:UnregisterForEvent(LibConsoleLogger.name, EVENT_ADD_ON_LOADED)
    end
end

if EVENT_MANAGER and EVENT_MANAGER.RegisterForEvent then
    EVENT_MANAGER:RegisterForEvent(LibConsoleLogger.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
end
