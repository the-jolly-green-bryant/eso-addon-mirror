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
    SI_BINDING_NAME_HTTT_JUMP_HOME_INSIDE = "Aller à la résidence principale (intérieur)",
    SI_BINDING_NAME_HTTT_JUMP_HOME_OUTSIDE = "Aller à la résidence principale (extérieur)",
    SI_BINDING_NAME_HTTT_JUMP_WAYSHRINE = "Voyage intelligent vers un autel de proximité",

    -- Favorite friend houses (1-10)
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_HOUSE_1 = "Aller à la maison favorite #1",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_HOUSE_2 = "Aller à la maison favorite #2",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_HOUSE_3 = "Aller à la maison favorite #3",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_HOUSE_4 = "Aller à la maison favorite #4",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_HOUSE_5 = "Aller à la maison favorite #5",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_HOUSE_6 = "Aller à la maison favorite #6",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_HOUSE_7 = "Aller à la maison favorite #7",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_HOUSE_8 = "Aller à la maison favorite #8",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_HOUSE_9 = "Aller à la maison favorite #9",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_HOUSE_10 = "Aller à la maison favorite #10",

    -- Favorite zones (1-10)
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_ZONE_1 = "Aller à la zone favorite #1",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_ZONE_2 = "Aller à la zone favorite #2",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_ZONE_3 = "Aller à la zone favorite #3",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_ZONE_4 = "Aller à la zone favorite #4",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_ZONE_5 = "Aller à la zone favorite #5",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_ZONE_6 = "Aller à la zone favorite #6",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_ZONE_7 = "Aller à la zone favorite #7",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_ZONE_8 = "Aller à la zone favorite #8",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_ZONE_9 = "Aller à la zone favorite #9",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_ZONE_10 = "Aller à la zone favorite #10",

    -- Favorite friends (1-10)
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_1 = "Aller à l'ami favori #1",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_2 = "Aller à l'ami favori #2",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_3 = "Aller à l'ami favori #3",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_4 = "Aller à l'ami favori #4",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_5 = "Aller à l'ami favori #5",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_6 = "Aller à l'ami favori #6",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_7 = "Aller à l'ami favori #7",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_8 = "Aller à l'ami favori #8",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_9 = "Aller à l'ami favori #9",
    SI_BINDING_NAME_HTTT_JUMP_FAVORITE_FRIEND_10 = "Aller à l'ami favori #10",
}

-- Register all strings with ESO's string system
-- This makes them accessible throughout the game using GetString(SI_BINDING_NAME_...)
for id, value in pairs(strings) do
    SafeAddString(_G[id], value, 2)
end