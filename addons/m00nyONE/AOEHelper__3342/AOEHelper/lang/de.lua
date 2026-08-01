local strings = {
	AOEHELPER_LOADED_COLORS = "Farben für <<1>> erfolgreich geladen",

	AOEHELPER_MENU_DESCRIPTION = "AOEColor ermöglich das Speichern einzelner Farben für Gegner- und Verbündeten AOEs pro Zone. Dies gilt für Prüfungen und Dungeons",
	AOEHELPER_MENU_CURRENT_HEADER_DESCRIPTION = "aktuelle Farben",
	AOEHELPER_MENU_GENERAL_ENEMY_COLOR_TEXT = "Farbe von Feinden",
	AOEHELPER_MENU_GENERAL_ENEMY_COLOR_TOOLTIP = "Die Farbe der feindlichen AOEs",
	AOEHELPER_MENU_GENERAL_ENEMY_BRIGHTNESS_TEXT = "Helligkeit von Feinden",
	AOEHELPER_MENU_GENERAL_ENEMY_BRIGHTNESS_TOOLTIP = "Die Helligkeit der feindlichen AOEs",
	AOEHELPER_MENU_GENERAL_ALLY_COLOR_TEXT = "Farbe von Verbündeten",
	AOEHELPER_MENU_GENERAL_ALLY_COLOR_TOOLTIP = "Die Farbe der verbündeten AOEs",
	AOEHELPER_MENU_GENERAL_ALLY_BRIGHTNESS_TEXT = "Helligkeit von Verbündeten",
	AOEHELPER_MENU_GENERAL_ALLY_BRIGHTNESS_TOOLTIP = "Die Helligkeit der verbündeten AOEs",
	AOEHELPER_MENU_GENERAL_BUTTON_SETFORCURRENTZONE_TEXT = "für Zone festlegen",
	AOEHELPER_MENU_GENERAL_BUTTON_SETFORCURRENTZONE_TOOLTIP = "setzt die ausgewählen Farben für die aktuelle Zone fest und speichert diese",
	AOEHELPER_MENU_GENERAL_BUTTON_SETFORCURRENTBOSS_TEXT = "für boss festlegen",
	AOEHELPER_MENU_GENERAL_BUTTON_SETFORCURRENTBOSS_TOOLTIP = "Setzt die ausgewählten Farben für den aktuell Boss fest - Deaktiviert wenn kein Boss in Reichweite ist",

	AOEHELPER_MENU_CURRENTZONE_SUBMENU_TEXT = "Farben für <<1>>",
	AOEHELPER_MENU_CURRENTZONE_SUBMENU_TOOLTIP = "Farben für die aktuelle Zone in der du dich befindest",
	AOEHELPER_MENU_CURRENTZONE_BUTTON_LOAD_TEXT = "laden",
	AOEHELPER_MENU_CURRENTZONE_BUTTON_LOAD_TOOLTIP = "lädt die Farben, die für die Zone gespeichert sind",
	AOEHELPER_MENU_CURRENTZONE_BUTTON_DELETE_TEXT = "löschen",
	AOEHELPER_MENU_CURRENTZONE_BUTTON_DELETE_TOOLTIP = "löscht alle gespeicherten Farben für die aktuelle Zone",
	AOEHELPER_MENU_CURRENTZONE_BUTTON_DELETE_WARNING = "dies löscht jegliche Einstellung der Farben für diese Zone. Danach werden die Standardfarben verwendet.",

	AOEHELPER_MENU_CURRENTBOSS_SUBMENU_TEXT = "Farben für <<1>>",
	AOEHELPER_MENU_CURRENTBOSS_SUBMENU_TOOLTIP = "Farben für den aktuellen Boss dem du gegenüberstehst",
	AOEHELPER_MENU_CURRENTBOSS_BUTTON_LOAD_TEXT = "laden",
	AOEHELPER_MENU_CURRENTBOSS_BUTTON_LOAD_TOOLTIP = "lädt die Farben, die für diesen Boss gespeichert sind",
	AOEHELPER_MENU_CURRENTBOSS_BUTTON_DELETE_TEXT = "löschen",
	AOEHELPER_MENU_CURRENTBOSS_BUTTON_DELETE_TOOLTIP = "löscht alle gespeicherten Farben für den aktuellen Boss",
	AOEHELPER_MENU_CURRENTBOSS_BUTTON_DELETE_WARNING = "dies löscht jegliche Einstellung der Farben für diesen Boss. Danach werden die Standardfarben verwendet.",

	AOEHELPER_MENU_DEFAULT_SUBMENU_TEXT = "Standard Farben",
	AOEHELPER_MENU_DEFAULT_SUBMENU_TOOLTIP = "Die Farben die Standardmäßig laden wenn keine speziellen für eine Zone gesetzt wurden.",
	AOEHELPER_MENU_DEFAULT_BUTTON_LOAD_TEXT = "laden",
	AOEHELPER_MENU_DEFAULT_BUTTON_LOAD_TOOLTIP = "Läd die Standardfarben",
	AOEHELPER_MENU_DEFAULT_BUTTON_SAVE_TEXT = "aktuelle Farben speichern",
	AOEHELPER_MENU_DEFAULT_BUTTON_SAVE_TOOLTIP = "Speichert die aktuellen Farben als Standardwerte",
	AOEHELPER_MENU_DEFAULT_BUTTON_SAVE_WARNING = "dies überschreibt deine Standardfarben global mit denen die momentan aktiv sind",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end