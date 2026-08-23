local strings = {
    SI_HAA_PANEL_NAME               = "Heavy Attack Alerter",
    SI_HAA_COMBAT_ONLY_NAME         = "Afficher uniquement en combat",
    SI_HAA_COMBAT_ONLY_TIP          = "Masque le bouclier hors combat.",
    SI_HAA_SOUND_NAME               = "Son d'alerte",
    SI_HAA_SOUND_TIP                = "Son joué lorsqu'un ennemi prépare une attaque lourde.",
    SI_HAA_SOUND_CHAMPION           = "Carillon (Points de champion)",
    SI_HAA_SOUND_DUEL               = "Duel (Début de duel)",
    SI_HAA_SOUND_QUEST              = "Victoire (Quête terminée)",
    SI_HAA_SOUND_NONE               = "Aucun son",
    SI_HAA_ALPHA_NAME               = "Opacité du bouclier vert (%)",
    SI_HAA_ALPHA_TIP                = "Opacité du bouclier à l'état normal.",
    SI_HAA_ALERT_ALPHA_NAME         = "Opacité du bouclier rouge (%)",
    SI_HAA_ALERT_ALPHA_TIP          = "Opacité du bouclier lors d'une alerte.",
    SI_HAA_SIZE_NAME                = "Taille de l'icône (px)",
    SI_HAA_OFFSET_X_NAME            = "Décalage horizontal (X)",
    SI_HAA_OFFSET_Y_NAME            = "Décalage vertical (Y)",
    SI_HAA_TEST_BUTTON_NAME         = "Tester l'alerte",
    SI_HAA_TEST_BUTTON_TIP          = "Déclenche une alerte de test de 1,5 seconde avec du son pour vérifier vos paramètres.",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end