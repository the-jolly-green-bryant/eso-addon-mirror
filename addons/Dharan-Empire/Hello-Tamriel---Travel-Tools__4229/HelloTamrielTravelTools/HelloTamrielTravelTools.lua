--[[
================================================================================
 HelloTamrielTravelTools (HTTT)
 Author: Dharan-Empire
 Version: 1.0
 Last Updated: 2025-08-22
 
 A lightweight teleportation utility addon for The Elder Scrolls Online
 
 Features:
 - Smart teleport to zones with friends/guildmates
 - Favorite zones, friends, and friend houses
 - Command-based and keybind travel options
 - Zone name fuzzy matching
 
 Modules:
 - Core: Essential utility functions and settings
 - Data: Zone information and location data
 - Favorites: Management of user favorites
 - Commands: Slash commands and UI integration
 - Teleport: Teleportation logic and functions
================================================================================
]]--

-- Create global addon namespace
HTTT = HTTT or {}
HTTT.name = "HelloTamrielTravelTools"
HTTT.version = "1.0"

-- Initialize the addon when loaded
local function OnAddOnLoaded(event, addonName)
    if addonName ~= HTTT.name then return end
    
    -- Initialize saved variables (stores favorites, settings, and custom data)
    HTTT.savedVars = ZO_SavedVars:NewAccountWide("HelloTamrielTravelToolsSavedVars", 1, nil, {})
    
    -- Initialize modules in dependency order:
    -- 1. Data (contains zone info needed by other modules)
    -- 2. Core (utility functions and settings)
    -- 3. Favorites (depends on Core and Data)
    -- 4. Commands (depends on all other modules)
    HTTT.Data.Initialize()
    HTTT.Core.Initialize()
    HTTT.Favorites.Initialize()
    HTTT.Commands.Initialize()
    
    -- Unregister event handler once addon is loaded
    EVENT_MANAGER:UnregisterForEvent(HTTT.name, EVENT_ADD_ON_LOADED)
end

-- Register event handler for addon loading
EVENT_MANAGER:RegisterForEvent(HTTT.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)