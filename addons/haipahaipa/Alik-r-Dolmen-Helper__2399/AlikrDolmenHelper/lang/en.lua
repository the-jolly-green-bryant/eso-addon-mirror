local strings = {
	SI_BINDING_NAME_ADH_TOGGLE_DIRECTION= "Toggle Fast Travel Direction",
	SI_BINDING_NAME_ADH_TOGGLE_AUTO_TRAVEL = "Toggle Automatic Fast Travel",
	SI_ALIKR_DOLMEN_HELPER_TOGGLE_AUTO_TRAVEL_ON = "Automatic fast travel is now enabled",
	SI_ALIKR_DOLMEN_HELPER_TOGGLE_AUTO_TRAVEL_OFF = "Automatic fast travel is now disabled",
	SI_ALIKR_DOLMEN_HELPER_DIRECTION_CLOCKWISE = "Fast travel direction is now clockwise",
	SI_ALIKR_DOLMEN_HELPER_DIRECTION_COUNTERCLOCKWISE = "Fast travel direction is now counterclockwise",
	SI_ALIKR_DOLMEN_HELPER_SLASH_HELP_0 = "Alik'r Dolmen Helper v",
	SI_ALIKR_DOLMEN_HELPER_SLASH_HELP_1 = "Use following chat commands or assign keybindings from the game settings",
	SI_ALIKR_DOLMEN_HELPER_SLASH_HELP_2 = "/adh toggle - Toggles the automatic fast travel on/off",
	SI_ALIKR_DOLMEN_HELPER_SLASH_HELP_3 = "/adh direction - Toggles the fast travel direction clockwise/counterclockwise",
	SI_ALIKR_DOLMEN_HELPER_SLASH_HELP_4 = "/adh help - Display this info",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
