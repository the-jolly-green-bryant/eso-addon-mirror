-- French Localization Strings for TorigaHUD
local strings = {
    BINDING_NAME_TORIGAHUD_TOGGLE_DRAG = "Verrouiller/Déverrouiller la position de l'HUD",
    
    TORIGAHUD_SETTINGS_DISPLAY_NAME = "Paramètres de |cFFD700TorigaHUD|r",
    TORIGAHUD_SETTINGS_GENERAL_HEADER = "Paramètres généraux",
    TORIGAHUD_SETTINGS_HIDE_OOC = "Masquer hors combat",
    TORIGAHUD_SETTINGS_HIDE_OOC_TT = "Masque les barres de ressources lorsque vous êtes hors combat et n'avez pas de cible active.",
    TORIGAHUD_SETTINGS_SHOW_SHIELDS = "Afficher le bouclier protecteur",
    TORIGAHUD_SETTINGS_SHOW_SHIELDS_TT = "Si activé, affiche une barre bleue semi-transparente au-dessus de la santé pour indiquer les boucliers actifs.",
    TORIGAHUD_SETTINGS_LERP_SPEED = "Vitesse d'animation des barres",
    TORIGAHUD_SETTINGS_LERP_SPEED_TT = "Ajuste la vitesse de glissement des barres. (1.00 = mise à jour instantanée, sans animation)",
    TORIGAHUD_SETTINGS_SEGMENT_SIZE = "Valeur par segment (Santé/Ressources)",
    TORIGAHUD_SETTINGS_SEGMENT_SIZE_TT = "Ajuste le nombre de points de ressource représentés par chaque bloc (Santé, Magie, Vigueur, Cible). Par ex. 2000 signifie que chaque bloc équivaut à 2000 points.",
    TORIGAHUD_SETTINGS_SCALE = "Échelle de l'HUD (Taille)",
    TORIGAHUD_SETTINGS_SCALE_TT = "Ajuste la taille globale de tous les éléments de l'HUD.",
    TORIGAHUD_SETTINGS_PRESETS_HEADER = "Préréglages et positionnement",
    TORIGAHUD_SETTINGS_PRESET = "Préréglage de disposition",
    TORIGAHUD_SETTINGS_PRESET_TT = "Sélectionnez une disposition prédéfinie pour réorganiser instantanément l'HUD.",
    TORIGAHUD_SETTINGS_PRESET_DEFAULT = "Par défaut",
    TORIGAHUD_SETTINGS_PRESET_VERTICAL = "Focus Combat (Vertical)",
    TORIGAHUD_SETTINGS_PRESET_HORIZONTAL = "Focus Combat (Horizontal)",
    TORIGAHUD_SETTINGS_PRESET_MINIMALIST = "Minimaliste (Compact)",
    TORIGAHUD_SETTINGS_UNLOCK = "Déverrouiller la position de l'HUD",
    TORIGAHUD_SETTINGS_UNLOCK_TT = "Activez cette option pour déverrouiller les cadres. Cela fermera le menu d'options et affichera une boîte de dialogue pour positionner les éléments à la souris.",
    TORIGAHUD_SETTINGS_RESET = "Réinitialiser les positions par défaut",
    TORIGAHUD_SETTINGS_RESET_TT = "Rétablit toutes les barres de l'HUD à leur position d'origine.",
    
    TORIGAHUD_DRAG_XP = "XP",
    TORIGAHUD_DRAG_TARGET = "CIBLE",
    
    TORIGAHUD_DIALOG_TITLE = "GLISSEZ LES BARRES OÙ VOUS LE SOUHAITEZ",
    TORIGAHUD_DIALOG_APPLY = "APPLIQUER",
    TORIGAHUD_DIALOG_CANCEL = "ANNULER",
    
    TORIGAHUD_TEXT_HEALTH = "SANTÉ",
    TORIGAHUD_TEXT_LEVEL = "NIVEAU",
    TORIGAHUD_TEXT_XP = "EXPÉRIENCE",
    TORIGAHUD_TEXT_MAGICKA = "MAGIE",
    TORIGAHUD_TEXT_STAMINA = "VIGUEUR",
    TORIGAHUD_TEXT_TARGET_TEST = "CIBLE D'ESSAI",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId("SI_" .. stringId, stringValue)
end
