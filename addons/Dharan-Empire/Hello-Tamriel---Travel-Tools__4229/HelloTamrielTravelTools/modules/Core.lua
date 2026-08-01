--[[
================================================================================
 HTTT Core Module
 Contains core utility functions and global helpers used throughout the addon.
 
 This module provides:
 - Debug messaging functionality
 - Text formatting and manipulation utilities
 - Saved variable management helpers
 - Global constants and settings
================================================================================
]]--

HTTT = HTTT or {}
HTTT.Core = {}

-- Constants
HTTT.Core.PREFIX = "|c00FF00Travel Tools: |r" -- Chat message prefix with green color
HTTT.Core.DEBUG_SMART_TELEPORT = false         -- Default debug state

-- Initialize the core module
-- @ return nil
function HTTT.Core.Initialize()
    -- Currently nothing to initialize
    -- Reserved for future core initialization needs
end

-- Enables or disables debug messages for the Smart Teleport feature
-- @ param enabled boolean Whether debug messages should be displayed (true) or hidden (false)
-- @ usage HTTT.Core.SetSmartTeleportDebug(true) -- Enable debugging
-- @ usage HTTT.Core.SetSmartTeleportDebug(false) -- Disable debugging
function HTTT.Core.SetSmartTeleportDebug(enabled)
    HTTT.Core.DEBUG_SMART_TELEPORT = enabled and true or false
end

-- Outputs a debug message to the chat window if debugging is enabled
-- @ param message string The message format string (supports string.format syntax)
-- @ param ... any Additional arguments to format into the message string
-- @ usage HTTT.Core.DebugMessage("Player %s is at zone %s", playerName, zoneName)
function HTTT.Core.DebugMessage(message, ...)
    if HTTT.Core.DEBUG_SMART_TELEPORT then
        d(HTTT.Core.PREFIX .. string.format(message, ...))
    end
end

-- Helper to ensure favorites table exists in saved variables
-- @ param key string The key for the favorites collection in savedVars
-- @ return table The favorites table for the requested key
-- @ usage local friendFavorites = HTTT.Core.EnsureFavorites("FriendFavorites")
function HTTT.Core.EnsureFavorites(key)
    HTTT.savedVars[key] = HTTT.savedVars[key] or {}
    return HTTT.savedVars[key]
end

-- Capitalizes a nickname string while respecting intentional capitalization
-- @ param nickname string The nickname to capitalize
-- @ return string|nil The capitalized nickname, or nil if input was nil
-- @ usage local formattedName = HTTT.Core.CapitalizeNickname("bbc guildhall") -- Returns "Bbc Guildhall"
function HTTT.Core.CapitalizeNickname(nickname)
    if not nickname then return nil end
    nickname = zo_strtrim(nickname)
    
    -- Only capitalize if the nickname is completely lowercase
    if nickname:lower() == nickname then
        nickname = nickname:gsub("(%a)([%w_']*)", function(first, rest)
            return first:upper() .. rest:lower()
        end)
    end
    
    return nickname
end