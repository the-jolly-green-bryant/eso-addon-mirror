local strings = {

	-- Menu --

	SI_TAUNTLESS_LANG = "en", 	-- "en"
	SI_TAUNTLESS_FONT = "$(MEDIUM_FONT)",

	SI_TAUNTLESS_MENU_AW_NAME = "Use Accountwide Settings", 	-- "Use Accountwide Settings"
	SI_TAUNTLESS_MENU_AW_NAME_TOOLTIP = "If chosen all characters on this account will have the same Settings", 	-- "If chosen all characters on this account will have the same Settings"
	SI_TAUNTLESS_MENU_MOVE_BUTTON = "Move", 	-- "Move"
	SI_TAUNTLESS_MENU_MOVE_BUTTON_TOOLTIP = "Move the taunt frames", 	-- "Move the taunt frames"
	SI_TAUNTLESS_MENU_WINDOW_WIDTH = "Width", 	-- "Width"
	SI_TAUNTLESS_MENU_WINDOW_WIDTH_TOOLTIP = "Sets the width of the taunt frames", 	-- "Sets the width of the taunt frames"
	SI_TAUNTLESS_MENU_WINDOW_HEIGHT = "Height", 	-- "Height"
	SI_TAUNTLESS_MENU_WINDOW_HEIGHT_TOOLTIP = "Sets the height of the taunt frames", 	-- "Sets the height of the taunt frames"
	SI_TAUNTLESS_MENU_GROWTH_DIRECTION = "Add Frames Upwards", 	-- "Add Frames Upwards"
	SI_TAUNTLESS_MENU_GROWTH_DIRECTION_TOOLTIP = "When selected, new frames are added above the previous ones", 	-- "When selected, new frames are added above the previous ones"
	SI_TAUNTLESS_MENU_MAX_BARS = "Maximum Rows", 	-- "Maximum Rows"
	SI_TAUNTLESS_MENU_MAX_BARS_TOOLTIP = "Maximum number of rows to show", 	-- "Maximum number of rows to show"
	SI_TAUNTLESS_MENU_BAR_DIRECTION = "Invert Timer Bar", 	-- "Invert Timer Bar"
	SI_TAUNTLESS_MENU_BAR_DIRECTION_TOOLTIP = "When selected, the timer bar gets reduced to the right", 	-- "When selected, the timer bar gets reduced to the right"
	SI_TAUNTLESS_MENU_SHOWMARKER = "Show Enemy Markers", 	-- "Show Enemy Markers"
	SI_TAUNTLESS_MENU_SHOWMARKER_TOOLTIP = "Show markers (like group pins) over enemies you are engaged with in combat", 	-- "Show markers (like group pins) over enemies you engaged in combat"
	SI_TAUNTLESS_MENU_MARKERSIZE = "Size of Enemy Markers", 	-- "Size of Enemy Markers"
	SI_TAUNTLESS_MENU_MARKERSIZE_TOOLTIP = "Size of the markers over enemies you are engaged with in combat", 	-- "Size of the markers over enemies you are engaged with in combat"
	SI_TAUNTLESS_MENU_TRACKONLYPLAYER = "Only Player Effects", 	-- "Only Player Effects"
	SI_TAUNTLESS_MENU_TRACKONLYPLAYER_TOOLTIP = "Select to track only Player Effects", 	-- "Select to track only Player Effects"
	SI_TAUNTLESS_MENU_TRACK = "Track %s", 	-- e.g. "Track Taunt"
	SI_TAUNTLESS_MENU_TRACK_TOOLTIP = "Select to track %s", 	-- e.g. "Select to track Taunt"
	SI_TAUNTLESS_MENU_CUSTOM = "Custom Abilities", 	-- "Custom Abilities"
	SI_TAUNTLESS_MENU_CUSTOM_TOOLTIP = 'Allows you to add custom ability IDs as a comma separated list (e.g. "12345, 23456, 99999")', 	-- "Allows you to add custom ability IDs"
	SI_TAUNTLESS_MENU_WINDOW_X = "Horizontal Position",
	SI_TAUNTLESS_MENU_WINDOW_X_TOOLTIP = "Adjust the horizontal position of the Tauntless window.",
	SI_TAUNTLESS_MENU_WINDOW_Y = "Vertical Position",
	SI_TAUNTLESS_MENU_WINDOW_Y_TOOLTIP = "Adjust the vertical position of the Tauntless window.",
	SI_TAUNTLESS_MENU_SHOWWINDOW = "Show Tauntless in menu",
	SI_TAUNTLESS_MENU_SHOWWINDOW_TOOLTIP = "Show the Tauntless window while the addon menu is open"

}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end