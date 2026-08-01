-- cChat_Global.lua
-- Creates the addon namespace and initializes core data structures
-- This file is always loaded first

cChat = {
    name = "cChat",
    version = "1.1.0",
    author = "tzammy_",
    savedvar = "CCHAT_SETTINGS",
    history_savedvar = "CCHAT_HISTORY",
    sv_version = 1,
}

-- Default settings
cChat.defaults = {
    -- Timestamp settings
    showTimestamps = true,
    use24HourFormat = true,  -- false = 12 hour (AM/PM), true = 24 hour

    -- History settings
    enableHistory = true,
    maxHistoryLines = 500,   -- Maximum number of lines to store
}

-- Runtime data (not saved)
cChat.data = {
    historyRestored = false,
}

-- Settings reference (will be set in OnAddonLoaded)
cChat.settings = nil

-- History reference (will be set in OnAddonLoaded)
cChat.history = nil
