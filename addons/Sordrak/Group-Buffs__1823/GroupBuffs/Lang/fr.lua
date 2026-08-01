-- GroupBuffs - Language (EN)
-- By @s0rdrak, @Graham82 (PC / EU)

--local LAM = LibStub("LibAddonMenu-2.0")

local GroupBuffs = _G['GroupBuffs']

GroupBuffs.config.constants.NAME_SORT_BY_NONE = "Aucun"
GroupBuffs.config.constants.NAME_SORT_BY_TIMER_DESC = "Par durée (Décroissant)"
GroupBuffs.config.constants.NAME_SORT_BY_TIMER_ASC = "Par durée (Croissant)"
GroupBuffs.config.constants.NAME_SORT_BY_NAME_DESC = "Par nom (Décroissant)"
GroupBuffs.config.constants.NAME_SORT_BY_NAME_ASC = "Par nom (Croissant)"
GroupBuffs.config.constants.NAME_SORT_BY_NAME_IN_POSITION_DESC = "Par nom (Positionné / Décroissant)"
GroupBuffs.config.constants.NAME_SORT_BY_NAME_IN_POSITION_ASC = "Par nom (Positionné / Croissant)"

GroupBuffs.config.constants.menu = {}
GroupBuffs.config.constants.menu.DISPLAY_NAME = "|c4592FFConfiguration de GroupBuffs|r"
GroupBuffs.config.constants.menu.AUTHOR = string.format("|cFF8174%s|r\r\nMerci à: |cFF8174%s|r\r\n", GroupBuffs.author, GroupBuffs.credits)
GroupBuffs.config.constants.menu.VERSION = string.format("|cFF8174%s|r", GroupBuffs.versionString)

GroupBuffs.config.constants.menu.ERROR_UNIQUE_FRAME_NAME = "|cFF8174Le cadre doit avoir un nom unique|r"
GroupBuffs.config.constants.menu.ERROR_NO_FRAME_NAME = "|cFF8174Aucun cadre sélectionné!|r"
GroupBuffs.config.constants.menu.ERROR_NO_BUFF_NAME = "|cFF8174Aucun buff spécifié!|r"
GroupBuffs.config.constants.menu.ERROR_BUFF_EFFECT_MINIMUM = "|cFF8174Il doit y avoir au moins un buff actif!|r"


GroupBuffs.config.constants.menu.TITLE = "|c4592FFConfiguration globale|r"
GroupBuffs.config.constants.menu.DESCRIPTION = "Paramètres globaux de l'add-on"
GroupBuffs.config.constants.menu.ADDON_ENABLED = "Addon activé"
GroupBuffs.config.constants.menu.HEADER_FRAME_CONFIGURATION = "|c4592FFConfiguration des cadres|r"
GroupBuffs.config.constants.menu.FRAME_DESCRIPTION = "Un cadre correspond à une fenêtre distincte. Vous pouvez par exemple créer des cadres différents pour le PvE et le PvP."
GroupBuffs.config.constants.menu.NEW_FRAME = "Nom du nouveau cadre:"
GroupBuffs.config.constants.menu.ADD_FRAME = "Ajouter cadre"
GroupBuffs.config.constants.menu.ADD_FRAME_TOOLTIP = "Il faut au moins un cadre pour afficher les effets actifs d'un joueur."
GroupBuffs.config.constants.menu.SELECT_FRAME = "Sélectionnez un cadre pour le configurer"
GroupBuffs.config.constants.menu.FRAME = "Cadre"
GroupBuffs.config.constants.menu.SELECT_FRAME_TOOLTIP = "Sélectionnez le cadre que vous souhaitez configurer."
GroupBuffs.config.constants.menu.REMOVE_FRAME = "Supprimer le cadre"
GroupBuffs.config.constants.menu.REMOVE_FRAME_WARNING = "Ce bouton supprimera le cadre définitivement."
GroupBuffs.config.constants.menu.FRAME_ENABLED = "Cadre activé"
GroupBuffs.config.constants.menu.FRAME_FIXED_LOCATION = "Emplacement fixe"
GroupBuffs.config.constants.menu.ENABLED_IN_PVP = "Cadre actif en PvP"
GroupBuffs.config.constants.menu.ENABLED_IN_PVE = "Cadre actif en PvE"
GroupBuffs.config.constants.menu.NAME_DISPLAY_TYPE = "Type d'affichage" ---xxx
GroupBuffs.config.constants.menu.ROLE_TYPE = "Rôle" ---xxx
GroupBuffs.config.constants.menu.FRAME_BUFF_SPACING = "Espacement des buffs"
GroupBuffs.config.constants.menu.FRAME_BUFF_SPACING_TOOLTIP = "Largeur des espaces entre les buffs."
GroupBuffs.config.constants.menu.BUFF_HEADER_COLOR = "Couleur du titre"
GroupBuffs.config.constants.menu.BUFFS = "|c4592FFBuffs|r"
GroupBuffs.config.constants.menu.NEW_BUFF = "Nom du nouveau buff:"
GroupBuffs.config.constants.menu.ADD_BUFF = "Ajouter un buff"
GroupBuffs.config.constants.menu.ADD_BUFF_TOOLTIP = "Ajouter une colonne de buff."
GroupBuffs.config.constants.menu.SELECT_BUFF_TOOLTIP = "Sélectionner un buff pour le configurer"
GroupBuffs.config.constants.menu.BUFF = "Buff"
GroupBuffs.config.constants.menu.BUFF_TOOLTIP = "Selectionnez le buff que vous voulez configurer."
GroupBuffs.config.constants.menu.REMOVE_BUFF = "Supprimer le buff"
GroupBuffs.config.constants.menu.REMOVE_BUFF_WARNING = "Ce bouton supprimera le buff définitivement."
GroupBuffs.config.constants.menu.BUFF_SETTINGS = "|c4592FFParamètres globaux du buff|r"
GroupBuffs.config.constants.menu.BUFF_COLUMN_SIZE = "Largeur de colonne"
GroupBuffs.config.constants.menu.BUFF_COLUMN_SIZE_TOOLTIP = "Définit la largeur de la barre de progression du buff."
GroupBuffs.config.constants.menu.SORT_ORDER = "Ordre"
GroupBuffs.config.constants.menu.SORT_ORDER_TOOLTIP = "Choisir l'ordre d'affichage des joueurs"
GroupBuffs.config.constants.menu.BUFF_ALWAYS_SHOW_NAME = "Montre toujours le nom des joueurs"
GroupBuffs.config.constants.menu.BUFF_ALWAYS_SHOW_NAME_TOOLTIP = "Cela ne fonctionne qu'avec le tri des noms"
GroupBuffs.config.constants.menu.BUFF_SHOW_NAME = "Afficher le nom du buff"
GroupBuffs.config.constants.menu.BUFF_EFFECT_ID = "ID de l'effet du buff"
GroupBuffs.config.constants.menu.BUFF_SHOW_STACK = "Montrer le nombre de bonus actifs"
GroupBuffs.config.constants.menu.BUFF_SHOW_DIFFERENT_OFF_DEAD_COLOR = "Show different Offline / Dead Color"
GroupBuffs.config.constants.menu.BUFF_DIFFERENT_OFF_DEAD_COLOR = "Different Offline / Dead Color"
GroupBuffs.config.constants.menu.BUFF_EFFECT_ID_TOOLTIP = "Sélectionnez l'effet de buff que vous souhaitez configurer"
GroupBuffs.config.constants.menu.ADD_BUFF_EFFECT = "Ajouter un effet de buff"
GroupBuffs.config.constants.menu.ADD_BUFF_EFFECT_TOOLTIP = "Ce bouton ajoute un nouvel effet de buff."
GroupBuffs.config.constants.menu.REMOVE_BUFF_EFFECT = "Supprimer l'effet de buff"
GroupBuffs.config.constants.menu.REMOVE_BUFF_EFFECT_TOOLTIP = "Ce bouton supprimera l'effet de buff définitivement."
GroupBuffs.config.constants.menu.BUFF_EFFECT_COLOR = "Couleur de l'effet de buff"
GroupBuffs.config.constants.menu.BUFF_EFFECT_FONT_COLOR = "Couleur de l'ecriture des buffs"
GroupBuffs.config.constants.menu.SELECT_BUFF_EFFECT = "Effet de buff"
GroupBuffs.config.constants.menu.SELECT_BUFF_EFFECT_TOOLTIP = "Sélectionnez un effet de buff"
GroupBuffs.config.constants.menu.SUBMENU_EFFECTS_VISUALS = "Effets visuels"
GroupBuffs.config.constants.menu.VISUAL_EFFECTS_FADE_IN_SETTINGS = "|c4592FFParamètres des transitions (fade-in)|r"
GroupBuffs.config.constants.menu.VISUAL_EFFECTS_DURATION = "Durée"
GroupBuffs.config.constants.menu.VISUAL_EFFECTS_FADE_IN_DURATION_TOOLTIP = "Durée de transition (fade-in)"
GroupBuffs.config.constants.menu.VISUAL_EFFECTS_FADE_IN_COLOR = "Couleur de transition (fade-in)"
GroupBuffs.config.constants.menu.VISUAL_EFFECTS_FADE_OUT_SETTINGS =  "|c4592FFParamètres des fondus-enchaînés (fade-out)|r"
GroupBuffs.config.constants.menu.VISUAL_EFFECTS_FADE_OUT_DURATION_TOOLTIP = "Durée des fondus-enchaînés (fade-out)"
GroupBuffs.config.constants.menu.VISUAL_EFFECTS_FADE_OUT_COLOR = "Couleur des fondus-enchaînés (fade-out)"
GroupBuffs.config.constants.menu.SUBMENU_EFFECTS_AUDIO = "Effets sonores"
GroupBuffs.config.constants.menu.AUDIO_EFFECTS_ACTIVE_SOUND = "Effet sonore actif"
GroupBuffs.config.constants.menu.AUDIO_EFFECTS_INTERVAL = "Intervalle"
GroupBuffs.config.constants.menu.AUDIO_EFFECTS_INTERVAL_TOOLTIP = "Régler l'intervalle de déclenchement de l'effet sonore"
GroupBuffs.config.constants.menu.AUDIO_EFFECTS_AUDIO_EFFECT = "Effet sonore"
GroupBuffs.config.constants.menu.AUDIO_EFFECTS_AUDIO_EFFECT_TOOLTIP = "Sélectionnez l'effet sonore que vous souhaitez"

GroupBuffs.config.constants.DISPLAY_MODE_NAME = "Name" ---xxx
GroupBuffs.config.constants.DISPLAY_MODE_DISPLAY = "@Account" ---xxx
GroupBuffs.config.constants.ROLE_MODE_ALL = "All" ---xxx
GroupBuffs.config.constants.ROLE_MODE_TANK = "Tank" ---xxx
GroupBuffs.config.constants.ROLE_MODE_HEALER = "Healer" ---xxx
GroupBuffs.config.constants.ROLE_MODE_DD = "DD" ---xxx

GroupBuffs.config.constants.GB_SLASH_CMD_GB_1 = "/gb - Affiche toutes les lignes de commande de GroupBuffs"
GroupBuffs.config.constants.GB_SLASH_CMD_GB_2 = "/gb menu - Affiche le menu de configuration de GroupBuffs"
GroupBuffs.config.constants.GB_SLASH_CMD_GB_3 = "/gb debug - Affiche les options de débogage"

GroupBuffs.config.constants.GB_SLASH_CMD_DEBUG_1 = "/gb debug show - affiche les buffs actifs avec leur ID de compétence"
GroupBuffs.config.constants.GB_SLASH_CMD_DEBUG_2 = "/gb debug show players - affiche tous les joueurs du groupe et leur ID"
GroupBuffs.config.constants.GB_SLASH_CMD_DEBUG_3 = "/gb debug show player <ID> - affiche les buffs du joueur sélectionné"
GroupBuffs.config.constants.GB_SLASH_CMD_DEBUG_4 = "/gb debug show ability <PlayerID> <AbilityID> - affiche l'information de l'ID de compétence sélectionnée"
GroupBuffs.config.constants.GB_SLASH_CMD_DEBUG_5 = "/gb debug cbl - débogage de la liste de buff"
GroupBuffs.config.constants.GB_SLASH_CMD_DEBUG_6 = "/gb debug clear - efface les données de débogage dans le fichier de sauvegarde (données créées par la commande cbl)"

GroupBuffs.config.constants.GB_SLASH_CMD_ERROR_GROUP = "Rejoignez un groupe avant d'utiliser cette méthode de débogage"
GroupBuffs.config.constants.GB_SLASH_CMD_ERROR_PLAYER_ID = "ID de joueur invalide"
GroupBuffs.config.constants.GB_SLASH_CMD_ERROR_ABILITY_IDENTIFICATION = "Buff non identifiable"
GroupBuffs.config.constants.GB_SLASH_CMD_ERROR_ABILITY_DOESNT_EXIST = "Cette compétence n'existe pas"

GroupBuffs.config.constants.GB_SLASH_CMD_CBL_CLEARING = "Effacer les informations de débogage"
GroupBuffs.config.constants.GB_SLASH_CMD_CBL_RELOADUI = "Utilisez /reloadui pour terminer ce processus"
GroupBuffs.config.constants.GB_SLASH_CMD_CBL_CREATING = "Créer la liste de buffs"
GroupBuffs.config.constants.GB_SLASH_CMD_CBL_STARTING = "Processus commencé à: %s"
GroupBuffs.config.constants.GB_SLASH_CMD_CBL_FINISHED = "Processus terminé à: %s"
GroupBuffs.config.constants.GB_SLASH_CMD_CBL_TIME = "Durée totale: %s"
GroupBuffs.config.constants.GB_SLASH_CMD_CBL_RELOADUI_CREATED = "taper /reloadui pour sauvegarder les données"