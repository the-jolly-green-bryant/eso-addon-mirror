--[[
================================================================================
 Hello Tamriel Travel Tools - Localization
 
 This file provides string localization for the addon.
 All text displayed to users should be defined here to support:
 1. Consistent terminology throughout the addon
 2. Potential future translations to other languages
 3. Proper integration with ESO's string system
 
 Last Updated: 2025-08-23 02:27:42
 By: House-of-Rahl
================================================================================
]]--

-- Define all UI strings in a single table for easy management
local strings =
{
    --[[ Core addon strings ]]--
    -- TODO: Add strings for main addon messages and UI elements

    --[[ Keybinding strings ]]--
    -- These appear in the Controls menu and should clearly describe the action

    -- Home teleport
    SI_BINDING_NAME_HTTT_JUMP_HOME_INSIDE = "Zum Hauptwohnsitz reisen (Innen)",
    SI_BINDING_NAME_HTTT_JUMP_HOME_OUTSIDE = "Zum Hauptwohnsitz reisen (Außen)",
    SI_BINDING_NAME_HTTT_JUMP_WAYSHRINE = "Intelligente Reise zu einem nahegelegenen Wegschrein",

    -- Favorite friend houses (1-10)
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_HOUSE_1 = "Zu Lieblingshaus #1 reisen",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_HOUSE_2 = "Zu Lieblingshaus #2 reisen",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_HOUSE_3 = "Zu Lieblingshaus #3 reisen",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_HOUSE_4 = "Zu Lieblingshaus #4 reisen",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_HOUSE_5 = "Zu Lieblingshaus #5 reisen",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_HOUSE_6 = "Zu Lieblingshaus #6 reisen",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_HOUSE_7 = "Zu Lieblingshaus #7 reisen",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_HOUSE_8 = "Zu Lieblingshaus #8 reisen",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_HOUSE_9 = "Zu Lieblingshaus #9 reisen",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_HOUSE_10 = "Zu Lieblingshaus #10 reisen",

    -- Favorite zones (1-10)
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_ZONE_1 = "Zu Lieblingszone #1 reisen",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_ZONE_2 = "Zu Lieblingszone #2 reisen",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_ZONE_3 = "Zu Lieblingszone #3 reisen",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_ZONE_4 = "Zu Lieblingszone #4 reisen",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_ZONE_5 = "Zu Lieblingszone #5 reisen",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_ZONE_6 = "Zu Lieblingszone #6 reisen",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_ZONE_7 = "Zu Lieblingszone #7 reisen",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_ZONE_8 = "Zu Lieblingszone #8 reisen",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_ZONE_9 = "Zu Lieblingszone #9 reisen",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_ZONE_10 = "Zu Lieblingszone #10 reisen",

    -- Favorite friends (1-10)
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_1 = "Zu Lieblingsfreund #1 reisen",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_2 = "Zu Lieblingsfreund #2 reisen",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_3 = "Zu Lieblingsfreund #3 reisen",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_4 = "Zu Lieblingsfreund #4 reisen",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_5 = "Zu Lieblingsfreund #5 reisen",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_6 = "Zu Lieblingsfreund #6 reisen",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_7 = "Zu Lieblingsfreund #7 reisen",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_8 = "Zu Lieblingsfreund #8 reisen",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_9 = "Zu Lieblingsfreund #9 reisen",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_10 = "Zu Lieblingsfreund #10 reisen",
}

-- Register all strings with ESO's string system
-- This makes them accessible throughout the game using GetString(SI_BINDING_NAME_...)
for id, value in pairs(strings) do
    SafeAddString(_G[id], value, 2)
end