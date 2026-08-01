--------------------------------------------------
-- ShibUI - A modern and minimalistic UI.
-- Copyright (C) 2025 Shownie & Ai
--------------------------------------------------
SUI = SUI or {}

--------------------------------------------------
-- Global metadata for ShibUI.
-- DO NOT MODIFY. Except for version updates.
-- Version format: MAJOR.MINOR.ESOAPI/0 for private use.
--------------------------------------------------
SUI.name        = "ShibUI"
SUI.menuName    = "ShibUI Settings"
SUI.displayName = "Shibui User Interface"
SUI.version     = "1.10.48" 
SUI.author      = "Shownie & Ai"
SUI.description = "ShibUI is a modern and minimalistic UI."

--------------------------------------------------
-- Main entry point for initializing ShibUI.
-- Add new modules to the initializers table below.
--------------------------------------------------
function SUI:InitializeModules()
    local initializers = {
        function() self.Settings:Initialize() end,      -- Keep Settings first as other modules depend on it.
        function() self.ReloadUI:Initialize() end,      -- Rest is independent or can be loaded in any order.
        function() self.Debug:Initialize() end,
        function() self.Miscellaneous:Initialize() end,
        function() self.GroupUnitFrame:Initialize() end,
        function() self.PlayerProgressBar:Initialize() end,
        function() self.Compass:Initialize() end,
        function() self.ActionBar:Initialize() end,
        function() self.AttributeBar:Initialize() end,
        function() self.TargetBar:Initialize() end,
        function() self.ChatWindow:Initialize() end,
    }
    for _, init in ipairs(initializers) do
        if type(init) == "function" then
            init()
        end
    end
end

--------------------------------------------------
-- Initialization function called when the addon is loaded.
-- This function sets up saved variables and initializes all modules.
--------------------------------------------------
function SUI:InitializeAddon(eventCode, addonName)
    if addonName ~= self.name then return end
    self.SavedVars:Initialize() -- Saved Vars must be initialized first.
    self:InitializeModules()    -- Initialize all other modules.
    self.Debug:Log("Core", string.format("Initialized %s v%s by %s", self.displayName, self.version, self.author))
    -- Unregister the event to prevent re-initialization.
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(SUI.name, EVENT_ADD_ON_LOADED, function(...) SUI:InitializeAddon(...) end)