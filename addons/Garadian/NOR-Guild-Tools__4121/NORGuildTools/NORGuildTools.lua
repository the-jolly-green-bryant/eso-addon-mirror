-- NORGuildTools.lua
NORGuildTools = NORGuildTools or {}
local Addon = NORGuildTools

Addon.name = "NORGuildTools"
Addon.version = "3.01"

local function OnAddOnLoaded(event, addonName)
    if addonName ~= Addon.name then return end

    -- Initialize SavedVariables
    Addon.saved = ZO_SavedVars:NewAccountWide(
        "NORGuildTools_Saved",
        1,
        nil,
        {},
        GetWorldName()
    )

    EVENT_MANAGER:UnregisterForEvent(Addon.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(Addon.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
