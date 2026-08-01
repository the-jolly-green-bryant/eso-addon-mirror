local _default = {
	SI_LE_EMOTEDATAMOD_ADD_BUTTON_TOOLTIP = "Add entry",
	SI_LE_EMOTEDATAMOD_APPLY_BUTTON_TOOLTIP = "Save changes and reload",
	SI_LE_EMOTEDATAMOD_CANCEL_BUTTON_TOOLTIP = "Discard changes",
	SI_LE_EMOTEDATAMOD_CLEAN_BUTTON_TOOLTIP = "Deletes all invalid and empty entries",

	SI_LE_EMOTEDATAMOD_CLEAN = "Clean",
	SI_LE_EMOTEDATAMOD_REPLACE_NAME = "Replace Name",
	SI_LE_EMOTEDATAMOD_SELECT_OR_ADD = "Select or add an entry",
}

for k, v in pairs(_default) do
	ZO_CreateStringId(k, v)
	SafeAddVersion(k, 1)
end
