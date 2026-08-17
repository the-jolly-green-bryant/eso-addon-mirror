local strings = {
    SI_QUICKEMOTEMENU_UNKNOWN_NAME          = "?",
    SI_QUICKEMOTEMENU_CATEGORIES            = "Catégories",
    SI_QUICKEMOTEMENU_FAVORITES             = "Favoris",
    SI_QUICKEMOTEMENU_NO_FAVORITES          = "(vide)",
    SI_QUICKEMOTEMENU_BINDING_TOGGLE        = "Basculer",
    SI_QUICKEMOTEMENU_OPTION_HOVER          = "Délai survol sous-menu (ms)",
    SI_QUICKEMOTEMENU_OPTION_HOVER_TOOLTIP  = "0 = ouvrir uniquement au clic",
    SI_QUICKEMOTEMENU_OPTION_UIMODE         = "Afficher le bouton uniquement en mode UI",
    SI_QUICKEMOTEMENU_OPTION_UIMODE_TOOLTIP =
    "Affiche le bouton principal uniquement lorsque le curseur de la souris est actif (mode UI). Il se masque en revenant au mode normal de jeu/interaction.",
    SI_QUICKEMOTEMENU_OPTION_DETACH         = "Détacher le bouton du chat",
    SI_QUICKEMOTEMENU_OPTION_DETACH_TOOLTIP =
    "Déplace le bouton hors de la fenêtre de chat. Le bouton devient flottant et déplaçable.",
    SI_QUICKEMOTEMENU_OPTION_SETTINGS       = "Paramètres",
    SI_QUICKEMOTEMENU_OPTION_ATTACH_BUTTON  = "Attacher le bouton",
    SI_QUICKEMOTEMENU_OPTION_DETACH_BUTTON  = "Détacher le bouton",
    SI_QUICKEMOTEMENU_OPTION_SHOW_PANEL     = "Afficher le panneau de paramètres",
    SI_QUICKEMOTEMENU_OPTION_CLOSE          = "Fermer le menu après emote (clic gauche)",
    SI_QUICKEMOTEMENU_OPTION_RESET          = "Réinitialiser position du bouton",
    SI_QUICKEMOTEMENU_OPTION_DESCRIPTION    = [[
|c3399FFFONCTIONNALITÉS|r
• Accès rapide aux emotes avec catégories et favoris
• Les catégories et les emotes sont chargés directement depuis les données du jeu
• Les nouveaux emotes ajoutés par le jeu apparaîtront automatiquement dans la liste

|c3399FFCONTRÔLES|r
• Clic gauche sur le bouton pour ouvrir ou fermer le menu
• Clic droit et glisser le bouton pour le déplacer
• Clic gauche sur une emote pour la jouer
• Clic droit sur une emote pour ajouter ou retirer des Favoris

|c3399FFMENUS|r
• Catégories — parcourir les emotes par catégorie
• Favoris — accès rapide aux emotes enregistrées
• Sous-menus s'ouvrent au survol ou clic (voir délai)
• Menus s'ouvrent haut/bas et gauche/droite selon position du bouton

|c3399FFASTUCES|r
• Utilisez le raccourci pour basculer le menu
• /qempanel ouvre ce panneau de paramètres
• Les Favoris sont sauvegardés sur tout le compte
]],
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
