local _de = {
	SI_LE_EMOTEDATAMOD_ADD_BUTTON_TOOLTIP = "Eintrag hinzufügen",
	SI_LE_EMOTEDATAMOD_APPLY_BUTTON_TOOLTIP = "Änderungen anwenden und neu laden",
	SI_LE_EMOTEDATAMOD_CANCEL_BUTTON_TOOLTIP = "Änderungen verwerfen",
	SI_LE_EMOTEDATAMOD_CLEAN_BUTTON_TOOLTIP = "Löscht alle ungültigen und leeren Einträge",

	SI_LE_EMOTEDATAMOD_CLEAN = "Reinigen",
	SI_LE_EMOTEDATAMOD_REPLACE_NAME = "Namen ersetzen",
	SI_LE_EMOTEDATAMOD_SELECT_OR_ADD = "Eintrag auswählen oder hinzufügen",
}

for k, v in pairs(_de) do
	SafeAddString(_G[k], v, 1)
end
