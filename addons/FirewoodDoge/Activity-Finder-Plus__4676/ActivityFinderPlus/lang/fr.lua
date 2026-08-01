local strings = {
    SI_ACTIVITY_FINDER_PLUS_LANG            = "fr",

    SI_ACTIVITY_FINDER_PLUS_HEADER_LFG    = "Vérification de préparation",
    SI_ACTIVITY_FINDER_PLUS_HEADER_FINDER = "Recherche d'activité",
    SI_ACTIVITY_FINDER_PLUS_HEADER_OTHER  = "Autre",

    SI_ACTIVITY_FINDER_PLUS_SOUND           = "Son amélioré",
    SI_ACTIVITY_FINDER_PLUS_SCREEN          = "Visuel amélioré",
    SI_ACTIVITY_FINDER_PLUS_ENHANCE         = "Recherche d'activité améliorée",
    SI_ACTIVITY_FINDER_PLUS_ACCEPT          = "Accepter automatiquement les vérifications de préparation",
    SI_ACTIVITY_FINDER_PLUS_RELEASE         = "Libération automatique dans les champs de bataille",
    SI_ACTIVITY_FINDER_PLUS_DELAY           = "Délai de notification sonore",

    SI_ACTIVITY_FINDER_PLUS_LFG_CHAT        = "Vérification de préparation !",
    SI_ACTIVITY_FINDER_PLUS_LFG_CHAT_A      = "Vérification de préparation acceptée automatiquement !",
    SI_ACTIVITY_FINDER_PLUS_LFG_SCREEN      = "Vérification de préparation du groupe !",

    SI_ACTIVITY_FINDER_PLUS_SOUND_TT        = "Jouer un son plus fort et répété lors d'une vérification de préparation.",
    SI_ACTIVITY_FINDER_PLUS_SCREEN_TT       = "Afficher une grande alerte à l'écran lors d'une vérification de préparation.",
    SI_ACTIVITY_FINDER_PLUS_ENHANCE_TT      = "Affiche l'état des serments et des quêtes, la progression des collections et les icônes de hauts faits. Ajoute des boutons de sélection rapide pour les serments, les quêtes de points de compétence et les ensembles incomplets.",
    SI_ACTIVITY_FINDER_PLUS_SET_COLLECTION  = "Progression des collections d'ensembles",
    SI_ACTIVITY_FINDER_PLUS_SET_COLLECTION_TT = "Afficher les pièces de collection débloquées et totales par donjon. Nécessite LibSets.",
    SI_ACTIVITY_FINDER_PLUS_KEYBOARD_TOOLTIP_MODE = "Infos de hauts faits dans une fenêtre séparée",
    SI_ACTIVITY_FINDER_PLUS_KEYBOARD_TOOLTIP_MODE_TT = "Mode clavier uniquement. Si coché, les infos de hauts faits du donjon s'affichent dans une fenêtre séparée sous l'infobulle du jeu, évitant tout chevauchement avec d'autres addons. Si décoché, elles sont écrites directement dans l'infobulle du jeu, ce qui peut se chevaucher avec d'autres addons qui la personnalisent aussi (par ex. DungeonTracker).",
    SI_ACTIVITY_FINDER_PLUS_ACCEPT_TT       = "Accepter automatiquement la vérification de préparation lorsqu'un groupe est trouvé.",
    SI_ACTIVITY_FINDER_PLUS_RELEASE_TT      = "Se libérer automatiquement après la mort dans un champ de bataille.",
    SI_ACTIVITY_FINDER_PLUS_SLASH_TT        = "Commandes textuelles :\nParamètres  /afp\nSerments journaliers  /pl  /pledge\nQuitter le groupe  /lv  /leave",
    SI_ACTIVITY_FINDER_PLUS_DELAY_TT        = "Secondes entre les notifications sonores répétées pendant une vérification de préparation.",

    SI_ACTIVITY_FINDER_PLUS_PLEDGE_DAILY    = "Serment",
    SI_ACTIVITY_FINDER_PLUS_PLEDGE_QUEST    = "Quête",
    SI_ACTIVITY_FINDER_PLUS_PLEDGE_DONE     = "Fait",
    SI_ACTIVITY_FINDER_PLUS_PLEDGE_SLASH    = "SERMENTS JOURNALIERS",
    SI_ACTIVITY_FINDER_PLUS_PLEDGE_NPC1     = "Maj al-Ragath",
    SI_ACTIVITY_FINDER_PLUS_PLEDGE_NPC2     = "Glirion Barbe-Rousse",
    SI_ACTIVITY_FINDER_PLUS_PLEDGE_NPC3     = "Urgarlag l'Émasculatrice",
    SI_ACTIVITY_FINDER_PLUS_CHECK_QUESTS    = "Vérifier les quêtes actives",
    SI_ACTIVITY_FINDER_PLUS_CHECK_SETS      = "Vérifier les ensembles incomplets",
    SI_ACTIVITY_FINDER_PLUS_CHECK_SKILL_QUESTS = "Sélectionner les quêtes incomplètes",
    SI_ACTIVITY_FINDER_PLUS_CHECK_SKILL_QUESTS_TT = "Sélectionne les donjons dont le personnage actuel n'a pas encore terminé la quête de point de compétence.",
    SI_ACTIVITY_FINDER_PLUS_QUICK_SELECT    = "Sélection rapide",
    SI_ACTIVITY_FINDER_PLUS_VETERAN_MODE_LABEL = "Mode vétéran",
    SI_ACTIVITY_FINDER_PLUS_VETERAN_MODE    = "Mode vétéran :",
    SI_ACTIVITY_FINDER_PLUS_VETERAN_MODE_TT = "Si coché, les boutons de sélection rapide ciblent les donjons vétéran au lieu des donjons normaux.",
    SI_ACTIVITY_FINDER_PLUS_ACHIEVEMENTS_HEADER = "Défis vétéran",
    SI_ACTIVITY_FINDER_PLUS_VET_CLEAR       = "Terminé en vétéran",
    SI_ACTIVITY_FINDER_PLUS_NORMAL_CLEAR    = "Terminé en normal",

    SI_BINDING_NAME_ACTIVITY_FINDER_PLUS_QUICK_SELECT = "Sélection rapide",
    SI_KEYBINDINGS_LAYER_ACTIVITY_FINDER_PLUS       = "Chercheur d'activités",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
