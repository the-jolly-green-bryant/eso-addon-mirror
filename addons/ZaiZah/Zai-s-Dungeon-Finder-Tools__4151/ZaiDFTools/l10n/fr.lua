------------------------------------------------------------------------------------------------------------------
-- French (fr)
-- Format and phrasing by ZaiZah
-- French is not my native language, this is largely done with what i know, Google Translate and ChatGPT
-- so please let me know if you have any suggestions.
-- version 1.0
------------------------------------------------------------------------------------------------------------------
-- Every variable must start with this addon's unique ID, as each is a global. 
-- BGMT_
local strings = {
    -- Addon name
    ["ZDFT_NAME"] = "Outils de Recherche de Donjon de Zai",

    -- Error Strings
    ["ZDFT_INVALID_DUNGEON_DATA"] = "Données de Donjon Invalides",
    ["ZDFT_INVALID_DUNGEON_DATA_TEXT"] = "Données de donjon invalides",
    ["ZDFT_COULD_NOT_FIND_FILTER"] = "Impossible de trouver le menu déroulant de filtrage",
    ["ZDFT_COULD_NOT_ACCESS_DROPDOWN"] = "Impossible d'accéder aux éléments du menu déroulant",

    -- Dungeon Types
    ["ZDFT_DLC_DUNGEON_TEXT"] = "Donjon DLC",
    ["ZDFT_BASE_GAME_TEXT"] = "Jeu de Base",
    
    -- Difficulty Types
    ["ZDFT_NORMAL_VETERAN"] = "Normal et Vétéran",

    -- Achievement Categories
    ["ZDFT_VETERAN_ACHIEVEMENTS_TEXT"] = "Succès Vétéran",
    ["ZDFT_TRIFECTA_TEXT"] = "Trifecta",
    ["ZDFT_HARDMODE_TEXT"] = "Mode Difficile",
    ["ZDFT_SPEEDRUN_TEXT"] = "Speedrun",
    ["ZDFT_NODEATH_TEXT"] = "Pas de Mort",
    ["ZDFT_ALL_3_VETERAN"] = "Les 3 succès Vétéran",
    
    -- Pledge Givers
    ["ZDFT_MAJ_AL_RAGATH"] = "Maj al-Ragath",
    ["ZDFT_GLIRION_REDBEARD"] = "Glirion Barbe-Rouge",
    ["ZDFT_URGARLAG_CHIEF"] = "Urgarlag Fléau-des-Chefs",
    
    -- Pledge Quest Status
    ["ZDFT_DAILY_PLEDGE"] = "Serment Quotidien",
    ["ZDFT_TODAYS_PLEDGE_QUESTS"] = "Quêtes de Serment d'Aujourd'hui",
    ["ZDFT_TODAYS_PLEDGE_STATUS"] = "Statut des Serments d'Aujourd'hui",
    ["ZDFT_READY_TO_TURN_IN"] = "Prêt à Rendre",
    ["ZDFT_QUEST_IN_PROGRESS"] = "Quête en Cours",
    ["ZDFT_ALREADY_COMPLETED_TODAY"] = "Déjà Terminé Aujourd'hui",
    ["ZDFT_AVAILABLE_TO_ACCEPT"] = "Disponible à Accepter",
    ["ZDFT_NO_ACTIVE_QUEST"] = "Aucune quête active",
    
    -- Pledge Actions & Results
    ["ZDFT_SELECT_PLEDGES_BUTTON"] = "Sélectionner les Serments d'Aujourd'hui",
    ["ZDFT_NO_PLEDGES_FOUND"] = "Aucun serment trouvé pour la difficulté sélectionnée.",
    ["ZDFT_NO_PLEDGES_FOUND_TEXT"] = "Aucun serment trouvé pour la difficulté sélectionnée.",
    ["ZDFT_SELECTED_PLEDGES_FORMAT"] = "%d serments %s sélectionnés",
    ["ZDFT_DESELECTED_PLEDGES_TEXT"] = "%d serments désélectionnés",

    -- Collections
    ["ZDFT_SETTINGS_COLLECTIONS"] = "Collections",
    ["ZDFT_SETTINGS_SHOW_COLLECTION_BUTTON"] = "Afficher le Bouton de Collection",
    ["ZDFT_SETTINGS_SHOW_COLLECTION_BUTTON_TT"] = "Afficher un bouton pour sélectionner rapidement les donjons avec des pièces d'ensemble ou des collections de motifs incomplètes",
    ["ZDFT_SETTINGS_COLLECTION_TYPE"] = "Type de Collection",
    ["ZDFT_SETTINGS_COLLECTION_TYPE_TT"] = "Choisissez le type de collections à vérifier lors de la sélection des donjons",
    ["ZDFT_SETTINGS_COLLECTION_SETS"] = "Pièces d'Ensemble",
    ["ZDFT_SETTINGS_COLLECTION_MOTIFS"] = "Styles de Motif", 
    ["ZDFT_SETTINGS_COLLECTION_BOTH"] = "Les Deux",
    ["ZDFT_SETTINGS_COLLECTION_DIFFICULTY"] = "Difficulté du Bouton de Collection",
    ["ZDFT_SETTINGS_COLLECTION_DIFFICULTY_TT"] = "Choisissez quelle difficulté des donjons sélectionner pour les collections",

    -- Collection Button Text and Messages
    ["ZDFT_SELECT_COLLECTIONS_BUTTON"] = "Sélectionner les Collections",
    ["ZDFT_SELECT_COLLECTIONS_BUTTON_FORMAT"] = "Sélectionner %s",
    ["ZDFT_SETS_TEXT"] = "Ensembles",
    ["ZDFT_MOTIFS_TEXT"] = "Motifs",

    -- Collection Button Alert Messages
    ["ZDFT_NO_COLLECTIONS_FOUND_TEXT"] = "Aucun donjon trouvé avec des %s incomplètes",
    ["ZDFT_DESELECTED_COLLECTIONS_TEXT"] = "Désélectionné %d collections",
    ["ZDFT_SELECTED_COLLECTIONS_FORMAT"] = "Sélectionné %d donjons %s avec des collections incomplètes",
    ["ZDFT_SELECTED_COLLECTIONS_FORMAT_NO_DIFFICULTY"] = "Sélectionné %d donjons avec des %s incomplètes",

    -- Color Legend
    ["ZDFT_COLOR_LEGEND_TITLE"] = "Légende des Couleurs de Serment",
    ["ZDFT_COLOR_LEGEND_BLUE"] = "Bleu : Disponible à Accepter",
    ["ZDFT_COLOR_LEGEND_ORANGE"] = "Orange : Quête en Cours",
    ["ZDFT_COLOR_LEGEND_GREEN"] = "Vert : Prêt à Rendre",
    ["ZDFT_COLOR_LEGEND_GREY"] = "Gris : Déjà Terminé Aujourd'hui",
    
    -- Settings - Achievement Icons
    ["ZDFT_SETTINGS_ACHIEVEMENT_ICONS"] = "Icônes de Succès",
    ["ZDFT_SETTINGS_SHOW_TRIFECTA"] = "Afficher l'Icône Trifecta",
    ["ZDFT_SETTINGS_SHOW_TRIFECTA_TT"] = "Afficher l'icône de succès trifecta",
    ["ZDFT_SETTINGS_SHOW_HARDMODE"] = "Afficher l'Icône Mode Difficile",
    ["ZDFT_SETTINGS_SHOW_HARDMODE_TT"] = "Afficher l'icône de succès mode difficile",
    ["ZDFT_SETTINGS_SHOW_NODEATH"] = "Afficher l'Icône Sans Mort",
    ["ZDFT_SETTINGS_SHOW_NODEATH_TT"] = "Afficher l'icône de succès sans mort",
    ["ZDFT_SETTINGS_SHOW_SPEEDRUN"] = "Afficher l'Icône Course Rapide",
    ["ZDFT_SETTINGS_SHOW_SPEEDRUN_TT"] = "Afficher l'icône de succès course rapide",
    ["ZDFT_SETTINGS_SHOW_CLEARED"] = "Afficher l'Icône Terminé",
    ["ZDFT_SETTINGS_SHOW_CLEARED_TT"] = "Afficher l'icône de donjon terminé",
    ["ZDFT_SETTINGS_SHOW_MOTIF"] = "Afficher l'Icône de Motif",
    ["ZDFT_SETTINGS_SHOW_MOTIF_TT"] = "Afficher l'icône de succès de motif",
    ["ZDFT_SETTINGS_SHOW_SET"] = "Afficher l'Icône de Collection d'Ensemble",
    ["ZDFT_SETTINGS_SHOW_SET_TT"] = "Afficher l'icône de collection d'ensemble",

    -- Settings - Pledge
    ["ZDFT_SETTINGS_PLEDGE"] = "Paramètres de Serment",
    ["ZDFT_SETTINGS_HIGHLIGHT_PLEDGES"] = "Surligner les Donjons de Serment",
    ["ZDFT_SETTINGS_HIGHLIGHT_PLEDGES_TT"] = "Colorer les noms des donjons de serment pour indiquer leur statut",
    ["ZDFT_SETTINGS_SHOW_PLEDGE_ICON"] = "Afficher l'Icône de Serment",
    ["ZDFT_SETTINGS_SHOW_PLEDGE_ICON_TT"] = "Afficher l'icône de clé Intrépide à côté des donjons de serment",
    
    -- Settings - UI
    ["ZDFT_SETTINGS_UI"] = "Paramètres d'Interface",
    ["ZDFT_SETTINGS_SHOW_BUTTON"] = "Afficher le Bouton 'Sélectionner les Serments d'Aujourd'hui'",
    ["ZDFT_SETTINGS_SHOW_BUTTON_TT"] = "Afficher le bouton pour sélectionner automatiquement les serments d'aujourd'hui",
    ["ZDFT_SETTINGS_PLEDGE_DIFFICULTY"] = "Difficulté de Serment",
    ["ZDFT_SETTINGS_PLEDGE_DIFFICULTY_TT"] = "Quelle difficulté utiliser lors de la sélection des serments",
    ["ZDFT_SETTINGS_FOLLOW_FINDER"] = "Suivre le Chercheur de Groupe",
    ["ZDFT_SETTINGS_ALWAYS_NORMAL"] = "Toujours Normal",
    ["ZDFT_SETTINGS_ALWAYS_VETERAN"] = "Toujours Vétéran",
    ["ZDFT_SETTINGS_BOTH_DIFFICULTIES"] = "Les Deux Difficultés",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(stringId, stringValue, 1)
end