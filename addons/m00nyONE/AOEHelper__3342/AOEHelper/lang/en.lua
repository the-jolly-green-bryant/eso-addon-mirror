local strings = {
	AOEHELPER_LOADED_COLORS = "loaded custom colors for <<1>>",

    AOEHELPER_MENU_DESCRIPTION = "AOEColor allows you to customize enemy and ally AOE colors specific for each zone. YOu can customize every Trial and Dungeon.",
	AOEHELPER_MENU_CURRENT_HEADER_DESCRIPTION = "current colors",
	AOEHELPER_MENU_GENERAL_ENEMY_COLOR_TEXT = "enemy color",
	AOEHELPER_MENU_GENERAL_ENEMY_COLOR_TOOLTIP = "The color of the AoEs that come from enemys",
	AOEHELPER_MENU_GENERAL_ENEMY_BRIGHTNESS_TEXT = "enemy brightness",
	AOEHELPER_MENU_GENERAL_ENEMY_BRIGHTNESS_TOOLTIP = "the brightness of enemy AoEs",
	AOEHELPER_MENU_GENERAL_ALLY_COLOR_TEXT = "friendly color",
	AOEHELPER_MENU_GENERAL_ALLY_COLOR_TOOLTIP = "the color of the friendly AoEs",
	AOEHELPER_MENU_GENERAL_ALLY_BRIGHTNESS_TEXT = "friendly brightness",
	AOEHELPER_MENU_GENERAL_ALLY_BRIGHTNESS_TOOLTIP = "the brightness of friendly AOEs",
	AOEHELPER_MENU_GENERAL_BUTTON_SETFORCURRENTZONE_TEXT = "set for Zone",
	AOEHELPER_MENU_GENERAL_BUTTON_SETFORCURRENTZONE_TOOLTIP = "set the defined colors for the current zone you are in",
	AOEHELPER_MENU_GENERAL_BUTTON_SETFORCURRENTBOSS_TEXT = "set for boss",
	AOEHELPER_MENU_GENERAL_BUTTON_SETFORCURRENTBOSS_TOOLTIP = "set the defined colors for the current boss you are facing - deactivated when no boss in range",

	AOEHELPER_MENU_CURRENTZONE_SUBMENU_TEXT = "current zone colors (<<1>>)",
	AOEHELPER_MENU_CURRENTZONE_SUBMENU_TOOLTIP = "colors for this zone",
	AOEHELPER_MENU_CURRENTZONE_BUTTON_LOAD_TEXT = "load",
	AOEHELPER_MENU_CURRENTZONE_BUTTON_LOAD_TOOLTIP = "load the currently saved settings for this zone",
	AOEHELPER_MENU_CURRENTZONE_BUTTON_DELETE_TEXT = "delete",
	AOEHELPER_MENU_CURRENTZONE_BUTTON_DELETE_TOOLTIP = "delete saved settings for this zone",
	AOEHELPER_MENU_CURRENTZONE_BUTTON_DELETE_WARNING = "this deletes your saved settings for this zone and they will fallback to default",

	AOEHELPER_MENU_CURRENTBOSS_SUBMENU_TEXT = "current boss colors <<1>>",
	AOEHELPER_MENU_CURRENTBOSS_SUBMENU_TOOLTIP = "colors for the boss you are currently facing",
	AOEHELPER_MENU_CURRENTBOSS_BUTTON_LOAD_TEXT = "load",
	AOEHELPER_MENU_CURRENTBOSS_BUTTON_LOAD_TOOLTIP = "load the currently saved settings for the boss you are currently facing",
	AOEHELPER_MENU_CURRENTBOSS_BUTTON_DELETE_TEXT = "delete",
	AOEHELPER_MENU_CURRENTBOSS_BUTTON_DELETE_TOOLTIP = "delete saved colors for this boss",
	AOEHELPER_MENU_CURRENTBOSS_BUTTON_DELETE_WARNING = "this deletes your saved settings for this boss and they will fallback to default.",

	AOEHELPER_MENU_DEFAULT_SUBMENU_TEXT = "Default Colors",
	AOEHELPER_MENU_DEFAULT_SUBMENU_TOOLTIP = "Default Colors",
	AOEHELPER_MENU_DEFAULT_BUTTON_LOAD_TEXT = "load",
	AOEHELPER_MENU_DEFAULT_BUTTON_LOAD_TOOLTIP = "load the default colors",
	AOEHELPER_MENU_DEFAULT_BUTTON_SAVE_TEXT = "save current",
	AOEHELPER_MENU_DEFAULT_BUTTON_SAVE_TOOLTIP = "save the current colors globally as default",
	AOEHELPER_MENU_DEFAULT_BUTTON_SAVE_WARNING = "this overwrites you default colors with the current loaded ones globally",

}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end