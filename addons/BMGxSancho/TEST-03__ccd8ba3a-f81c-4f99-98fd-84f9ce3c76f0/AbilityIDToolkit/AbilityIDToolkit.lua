AbilityIDToolkit = AbilityIDToolkit or {}
local AIT = AbilityIDToolkit

AIT.name = "AbilityIDToolkit"
AIT.displayName = "Ability ID Toolkit"
AIT.version = "0.0.05"

local defaults = {
    captureEffectEvents = true,
    captureCombatEvents = true,
    localPlayerOnly = false,
    maxLog = 250,
    lookupQuery = "",
    known = {},
    sessions = {},
}

function AIT:Initialize()
    self.sv = ZO_SavedVars:NewAccountWide("AbilityIDToolkitSavedVars", 1, nil, defaults)
    self:InitializeDatabase()
    self:InitializeCapture()
    self:CreateReadout()
    self:RegisterCaptureEvents()
    self:InitializeSettings()
end

local function OnAddonLoaded(eventCode, addonName)
    if addonName ~= AIT.name then return end
    EVENT_MANAGER:UnregisterForEvent(AIT.name, EVENT_ADD_ON_LOADED)
    AIT:Initialize()
end

EVENT_MANAGER:RegisterForEvent(AIT.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
