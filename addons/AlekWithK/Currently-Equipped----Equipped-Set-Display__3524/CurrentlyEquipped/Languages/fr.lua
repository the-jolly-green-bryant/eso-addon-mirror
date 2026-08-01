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
CE_BINDING_RESET = "Réinitialiser l'affichage"
CE_DISPLAY_NAME = "Actuellement équipé"

--Menu Strings
CE_MENU_DESCRIPTION = "Affiche vos ensembles actuellement équipés, avec des couleurs indiquant leur statut."

CE_MENU_OPTIONS_HEADER = "Options"

CE_MENU_UNLOCK_UI = "Déverrouiller l'IU"
CE_MENU_UNLOCK_UI_TIP = "Basculer sur 'Oui' pour déplacer l'affichage sur la position de l'écran."

CE_MENU_SHOW_IN_TRIAL_ARENA = "Afficher uniquement dans les épreuves/arènes"
CE_MENU_SHOW_IN_TRIAL_ARENA_TIP = "L'affichage ne s'affichera que dans les instances d'épreuve et d'arène."
CE_MENU_SHOW_IN_TRIAL_ARENA_WARN = "Mise à jour lors du prochain changement de zone !"

CE_MENU_HIDE_IN_COMBAT = "Masquer en combat"
CE_MENU_HIDE_IN_COMBAT_TIP = "Masque l'affichage pendant le combat."

CE_MENU_HIDE_IN_COMBAT_DELAY = "Masquer en combat avec un délai"
CE_MENU_HIDE_IN_COMBAT_DELAY_TIP = "Détermine le nombre de secondes à attendre avant de masquer l'affichage lorsque le combat commence."

CE_MENU_HIDE_IN_MENU = "Masquer en Menu"
CE_MENU_HIDE_IN_MENU_TIP = "Masque l'affichage lorsque un menu est ouvert"

CE_MENU_COLORS_HEADER = "Couleurs"

CE_MENU_HEADER_COLOR = "Couleur de l'en-tête"
CE_MENU_HEADER_COLOR_TIP = "Détermine la couleur de \"Actuellement équipé\""

CE_MENU_COMPLETE_SET_COLOR = "Ensembles complétés"
CE_MENU_COMPLETE_SET_COLOR_TIP = "Détermine la couleur des ensembles complétés qui sont affichés."

CE_MENU_INCOMPLETE_SET_COLOR = "Ensembles non complétés"
CE_MENU_INCOMPLETE_SET_COLOR_TIP = "Détermine la couleur des ensembles non complétés qui sont affichés."

CE_MENU_WARNING_COLOR = "Couleur d'avertissement"
CE_MENU_WARNING_COLOR_TIP = "Détermine la couleur des ensembles de monstres 1cp et surcomplétés qui sont affichés."

CE_MENU_DEBUG_HEADER = "Déboguer"

CE_MENU_FORCE_UPDATE = "Forcer la mise à jour"
CE_MENU_FORCE_UPDATE_TIP = "Met à jour manuellement l'interface utilisateur si une erreur se produit."
