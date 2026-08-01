local _fr = {
	SI_LE_EMOTEDATAMOD_ADD_BUTTON_TOOLTIP = "Ajouter une entrée",
	SI_LE_EMOTEDATAMOD_APPLY_BUTTON_TOOLTIP = "Enregistrer les modifications et recharger",
	SI_LE_EMOTEDATAMOD_CANCEL_BUTTON_TOOLTIP = "Annuler les modifications",
	SI_LE_EMOTEDATAMOD_CLEAN_BUTTON_TOOLTIP = "Supprime toutes les entrées invalides et vides",

	SI_LE_EMOTEDATAMOD_CLEAN = "Nettoyer",
	SI_LE_EMOTEDATAMOD_REPLACE_NAME = "Remplacer le nom",
	SI_LE_EMOTEDATAMOD_SELECT_OR_ADD = "Sélectionner ou ajouter une entrée",
}

for k, v in pairs(_fr) do
	SafeAddString(_G[k], v, 1)
end
