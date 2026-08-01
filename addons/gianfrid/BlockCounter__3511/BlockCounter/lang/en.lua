local strings = {
	SI_BLOCKCOUNTER_LANG = "en",

	-- Menu --
	SI_BLOCKCOUNTER_MENU_ACCOUNTWIDE = "Use Accountwide Settings",
	SI_BLOCKCOUNTER_MENU_ACCOUNTWIDE_TOOLTIP = "If chosen all characters on this account will have the same Settings",
	SI_BLOCKCOUNTER_MENU_LOCK = "Locked",
	SI_BLOCKCOUNTER_MENU_LOCK_TOOLTIP = "Uncheck this to permanently show the control, to move it around. When locked, the control can't be moved",
	SI_BLOCKCOUNTER_MENU_WINDOW_WIDTH = "Width",
	SI_BLOCKCOUNTER_MENU_WINDOW_WIDTH_TOOLTIP = "Sets the width of the bars",
	SI_BLOCKCOUNTER_MENU_WINDOW_HEIGHT = "Height",
	SI_BLOCKCOUNTER_MENU_WINDOW_HEIGHT_TOOLTIP = "Sets the height of the bars and the size of the label",
	SI_BLOCKCOUNTER_MENU_BG_OPACITY = "Background Opacity",
	SI_BLOCKCOUNTER_MENU_BG_OPACITY_TOOLTIP = "Adjusts opacity of the control's background",
	SI_BLOCKCOUNTER_MENU_SHOW_STAMINABLOCKS = "Show remaining stamina blocks",
	SI_BLOCKCOUNTER_MENU_SHOW_STAMINABLOCKS_TOOLTIP = "Select to show the stamina blocks counter",
	SI_BLOCKCOUNTER_MENU_SHOW_MAGICKABLOCKS = "Show remaining magicka blocks",
	SI_BLOCKCOUNTER_MENU_SHOW_MAGICKABLOCKS_TOOLTIP = "Select to show the magicka blocks counter",
	SI_BLOCKCOUNTER_MENU_ALERT = "Display in red when less than",
	SI_BLOCKCOUNTER_MENU_ALERT_TOOLTIP = "Set at 0 to disable",
	SI_BLOCKCOUNTER_REFRESH_DELAY = "Refresh interval",
	SI_BLOCKCOUNTER_REFRESH_DELAY_TOOLTIP = "After how many milliseconds values should be recalculated (needs /reloadui)",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end