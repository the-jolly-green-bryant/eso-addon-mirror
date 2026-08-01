----------------------------
----### KEYBINDINGS ###-----
----------------------------
local loc_strings = {
    SI_BINDING_NAME_REFRESH_UI = CE_BINDING_RESET,
}

for str_id, str in pairs(loc_strings) do
    ZO_CreateStringId(str_id, str)
    SafeAddVersion(str_id, 1)
end

----------------------------
-------### STRINGS ###------
----------------------------
CE_BINDING_RESET = "Reset Display"
CE_DISPLAY_NAME = "Currently Equipped"

--Menu Strings
CE_MENU_DESCRIPTION = "Displays your currently equipped sets, with colors indicating their status."

CE_MENU_OPTIONS_HEADER = "Options"

CE_MENU_UNLOCK_UI = "Unlock UI"
CE_MENU_UNLOCK_UI_TIP = "Toggle 'On' to move display's on screen position"

CE_MENU_SHOW_IN_TRIAL_ARENA = "Only Show in Trials/Arenas"
CE_MENU_SHOW_IN_TRIAL_ARENA_TIP = "Display will only show in trial and arena instances"
CE_MENU_SHOW_IN_TRIAL_ARENA_WARN = "Will update on next zone change!"

CE_MENU_HIDE_IN_COMBAT = "Hide in Combat"
CE_MENU_HIDE_IN_COMBAT_TIP = "Hides display while in combat"

CE_MENU_HIDE_IN_COMBAT_DELAY = "Hide In Combat Delay"
CE_MENU_HIDE_IN_COMBAT_DELAY_TIP = "Set number of seconds to wait before hiding display when combat starts"

CE_MENU_HIDE_IN_MENU = "Hide in Menu"
CE_MENU_HIDE_IN_MENU_TIP = "Hides the display when in menu (inventory, map, etc)"

CE_MENU_COLORS_HEADER = "Colors"

CE_MENU_HEADER_COLOR = "Header Color"
CE_MENU_HEADER_COLOR_TIP = "Set the color of \"Currently Equipped\""

CE_MENU_COMPLETE_SET_COLOR = "Completed Sets"
CE_MENU_COMPLETE_SET_COLOR_TIP = "Set the color completed sets are shown in"

CE_MENU_INCOMPLETE_SET_COLOR = "Incomplete Sets"
CE_MENU_INCOMPLETE_SET_COLOR_TIP = "Set the color incomplete sets are shown in"

CE_MENU_WARNING_COLOR = "Warning Color"
CE_MENU_WARNING_COLOR_TIP = "Set the color overcompleted and 1pc Monster sets are shown in"

CE_MENU_DEBUG_HEADER = "Debug"

CE_MENU_FORCE_UPDATE = "Force Update"
CE_MENU_FORCE_UPDATE_TIP = "Manually update the UI if an error occurs"
