--[[
================================================================================
 Hello Tamriel Travel Tools - Localization
 
 This file provides string localization for the addon.
 All text displayed to users should be defined here to support:
 1. Consistent terminology throughout the addon
 2. Potential future translations to other languages
 3. Proper integration with ESO's string system
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
    SI_BINDING_NAME_HTTT_JUMP_HOME_INSIDE = "Travel to primary residence (Inside)",
    SI_BINDING_NAME_HTTT_JUMP_HOME_OUTSIDE = "Travel to primary residence (Outside)",
    SI_BINDING_NAME_HTTT_JUMP_WAYSHRINE = "Smart Travel to a nearby wayshrine",
    
    -- Favorite friend houses (1-10)
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_HOUSE_1 = "Travel to Favorite House #1",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_HOUSE_2 = "Travel to Favorite House #2",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_HOUSE_3 = "Travel to Favorite House #3",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_HOUSE_4 = "Travel to Favorite House #4",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_HOUSE_5 = "Travel to Favorite House #5",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_HOUSE_6 = "Travel to Favorite House #6",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_HOUSE_7 = "Travel to Favorite House #7",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_HOUSE_8 = "Travel to Favorite House #8",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_HOUSE_9 = "Travel to Favorite House #9",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_HOUSE_10 = "Travel to Favorite House #10",
    
    -- Favorite zones (1-10)
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_ZONE_1 = "Travel to Favorite Zone #1",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_ZONE_2 = "Travel to Favorite Zone #2",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_ZONE_3 = "Travel to Favorite Zone #3",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_ZONE_4 = "Travel to Favorite Zone #4",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_ZONE_5 = "Travel to Favorite Zone #5",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_ZONE_6 = "Travel to Favorite Zone #6",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_ZONE_7 = "Travel to Favorite Zone #7",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_ZONE_8 = "Travel to Favorite Zone #8",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_ZONE_9 = "Travel to Favorite Zone #9",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_ZONE_10 = "Travel to Favorite Zone #10",
    
    -- Favorite friends (1-10)
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_1 = "Travel to favorite friend #1",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_2 = "Travel to favorite friend #2",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_3 = "Travel to favorite friend #3",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_4 = "Travel to favorite friend #4",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_5 = "Travel to favorite friend #5",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_6 = "Travel to favorite friend #6",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_7 = "Travel to favorite friend #7",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_8 = "Travel to favorite friend #8",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_9 = "Travel to favorite friend #9",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_10 = "Travel to favorite friend #10",
}

-- Register all strings with ESO's string system
-- This makes them accessible throughout the game using GetString(SI_BINDING_NAME_...)
for id, value in pairs(strings) do
    ZO_CreateStringId(id, value)
end