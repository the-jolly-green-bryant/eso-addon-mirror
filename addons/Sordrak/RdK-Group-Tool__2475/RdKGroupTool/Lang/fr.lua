-- RdKGroupTool - Language - fr
-- By @s0rdrak (PC / EU)

local RdKGTool = _G['RdKGTool']
local RdKGToolMenu = RdKGTool.menu
local RdKGToolGroup = RdKGTool.group
local RdKGToolCrown = RdKGToolGroup.crown
local RdKGToolAI = RdKGToolGroup.ai
local RdKGToolFtcv = RdKGToolGroup.ftcv
local RdKGToolFtcw = RdKGToolGroup.ftcw
local RdKGToolBeam = RdKGToolGroup.ftcb
local RdKGToolOverview = RdKGToolGroup.ro
local RdKGToolGBeam = RdKGToolGroup.gb
local RdKGToolHdm = RdKGToolGroup.hdm
local RdKGToolDt = RdKGToolGroup.dt
local RdKGToolIsdp = RdKGToolGroup.isdp
local RdKGToolCompass = RdKGTool.compass
local RdKGToolYacs = RdKGToolCompass.yacs
local RdKGToolSC = RdKGToolCompass.sc
local RdKGToolUtil = RdKGTool.util
local RdKGToolUtilUI = RdKGToolUtil.ui
local RdKGToolUltimates = RdKGToolUtil.ultimates
local RdKGToolNetworking = RdKGToolUtil.networking
local RdKGToolUtilGroup = RdKGToolUtil.group
local RdKGToolVersioning = RdKGToolUtil.versioning
local RdKGToolGMenu = RdKGToolUtil.groupMenu
local RdKGToolBeams = RdKGToolUtil.beams
local RdKGToolToolbox = RdKGTool.toolbox
local RdKGToolSm = RdKGToolToolbox.sm
local RdKGToolRecharger = RdKGToolToolbox.recharger
local RdKGToolBft = RdKGToolToolbox.bft
local RdKGToolSiege = RdKGToolToolbox.siege
local RdKGToolCL = RdKGToolToolbox.cl
local RdKGToolEnhance = RdKGToolToolbox.enhancements
local RdKGToolRespawner = RdKGToolToolbox.respawner
local RdKGToolSP = RdKGToolToolbox.sp
local RdKGToolSO = RdKGToolToolbox.so
local RdKGToolAdmin = RdKGTool.admin
local RdKGToolConfig = RdKGTool.cfg

RdKGTool.config.constants.CMD_TEXT_MENU = RdKGTool.slashCmd .. " menu: ouvre le menu de configuration"
RdKGTool.config.constants.CMD_TEXT_MENU = RdKGTool.config.constants.CMD_TEXT_MENU .. "\r\n" .. RdKGTool.slashCmd .." admin: ouvre l'interface d'administration." 
RdKGTool.config.constants.CMD_TEXT_MENU = RdKGTool.config.constants.CMD_TEXT_MENU .. "\r\n" .. RdKGTool.slashCmd .." config: ouvre l'interface d'importation et exportation des configurations." 
RdKGTool.config.constants.CMD_TEXT_MENU = RdKGTool.config.constants.CMD_TEXT_MENU .. "\r\n" .. RdKGTool.slashCmd .." hdm clear: Resets the Healing Damage Meter" ---xxx
RdKGTool.config.constants.CMD_TEXT_MENU = RdKGTool.config.constants.CMD_TEXT_MENU .. "\r\n/ai: active l'invitation automatique (e.g. /ai rdk) - désactiver avec /ai" 

--Tool
RdKGTool.constants = RdKGTool.constants or {}
RdKGTool.constants.MISSING_LIBRARIES = "Librairies manquantes : RdK Group Tool nécessite les librairies suivantes : "

--Menu Constants
--Profile
RdKGToolMenu.constants = RdKGToolMenu.constants or {}
RdKGToolMenu.constants.PROFILE_HEADER = "Réglages du profil"
RdKGToolMenu.constants.PROFILE_SELECTED_PROFILE = "Profil sélectionné"
RdKGToolMenu.constants.PROFILE_SELECTED_PROFILE_TOOLTIP = "Sélectionnez le profil souhaité"
RdKGToolMenu.constants.PROFILE_NEW_PROFILE = "Nouveau profil"
RdKGToolMenu.constants.PROFILE_ADD_PROFILE = "Ajouter"
RdKGToolMenu.constants.PROFILE_CLONE_PROFILE = "Copier" 
RdKGToolMenu.constants.PROFILE_REMOVE_PROFILE = "Supprimer"
RdKGToolMenu.constants.PROFILE_EXISTS = "|cFF0000Ce profil existe déjà - Veuillez choisir un autre nom de profil|r"
RdKGToolMenu.constants.PROFILE_CANT_REMOVE_DEFAULT = "|cFF0000Ce profil ne peut être supprimé|r"

--Fixed Components
RdKGToolMenu.constants.POSITION_FIXED_SET = "Figer la position"
RdKGToolMenu.constants.POSITION_FIXED_UNSET = "Libérer la position"

--Donate
RdKGToolMenu.constants.FEEDBACK = "Retour"
RdKGToolMenu.constants.FEEDBACK_STRING = "Merci d'adresser vos retours et commentaires sur les forums ESO ou ESOUI. Je ne pourrai pas répondre à vos messages en jeu."
RdKGToolMenu.constants.DONATE = "Dons"
RdKGToolMenu.constants.DONATE_5K = "Donner 5000 gold"
RdKGToolMenu.constants.DONATE_50K = "Donner 50000 gold"
RdKGToolMenu.constants.DONATE_SERVER_ERROR = "Merci d'essayer de me transmettre un don. Malheureusement, nous ne jouons pas sur le même serveur, ce qui rend la chose impossible."
RdKGToolMenu.constants.DONATE_MAIL_SUBJECT = "RdK Group Tool - Don"

--Group
RdKGToolMenu.constants.GROUP_HEADER = "|cFF8174Réglages de groupe|r"

--Crown
RdKGToolMenu.constants.CROWN_HEADER = "|c4592FFChef de groupe|r"
RdKGToolMenu.constants.CROWN_CHK_GROUP_CROWN_ENABLED = "Mode \"chef de groupe personnalisé\" activé"
RdKGToolMenu.constants.CROWN_SELECTED_MODE = "Mode chef de groupe"
RdKGToolMenu.constants.CROWN_MODE = {}
RdKGToolMenu.constants.CROWN_MODE[1] = "Epingle"
RdKGToolMenu.constants.CROWN_SELECTED_CROWN = "Chef de groupe sélectionné"
RdKGToolMenu.constants.CROWN_SIZE = "Taille"
RdKGToolMenu.constants.CROWN_WARNING = "|cFF0000Only 1 L'add-on peut mettre en oeuvre cette fonctionnalité, mais attention, le jeu va crasher si deux add-ons l'utilisent en même temps.|r"
RdKGToolMenu.constants.CROWN_PVP_ONLY = "Uniquement en PvP"

--Auto Invite
RdKGToolMenu.constants.AI_HEADER = "|c4592FFInvitation automatique|r"
RdKGToolMenu.constants.AI_ENABLED = "Activé"
RdKGToolMenu.constants.AI_INVITE_TEXT = "Critère d'invitation"
RdKGToolMenu.constants.AI_GROUP_SIZE = "Taille maximale de groupe"
RdKGToolMenu.constants.AI_PVP_CHECK = "Uniquement en PvP"
RdKGToolMenu.constants.AI_SEND_CHAT_MESSAGES = "Envoyer les messages de chat"
RdKGToolMenu.constants.AI_AUTO_KICK = "Renvoi automatique"
RdKGToolMenu.constants.AI_AUTO_KICK_TIME = "Intervalle de renvoi automatique"
RdKGToolMenu.constants.AI_CHAT = "Chats autorisés"
RdKGToolMenu.constants.AI_CHAT_RESTRICTIONS = "Restrictions joueur"
RdKGToolMenu.constants.AI_CHAT_RESTRICTIONS_TOOLTIP = "Détermine à qui s'appliquent les restrictions d'invitation automatique"
RdKGToolMenu.constants.AI_CHAT_RESTRICTIONS_GUILD = "Guilde"
RdKGToolMenu.constants.AI_CHAT_RESTRICTIONS_GUILD_FRIEND = "Guilde et amis"
RdKGToolMenu.constants.AI_CHAT_RESTRICTIONS_FRIEND = "Amis"
RdKGToolMenu.constants.AI_CHAT_RESTRICTIONS_SPECIFIC_GUILD = "Guilde spécifique"
RdKGToolMenu.constants.AI_CHAT_RESTRICTIONS_SPECIFIC_GUILD_FRIEND = "Guildes et amis spécifiques"
RdKGToolMenu.constants.AI_CHAT_RESTRICTIONS_NONE = "Aucune restriction"
RdKGToolMenu.constants.AI_SHOW_MEMBER_LEFT = "Afficher tous les messages de départ/"

--Follow The Crown Visual
RdKGToolMenu.constants.FTCV_HEADER = "|c4592FFSuivre la couronne (Visuel)|r"
RdKGToolMenu.constants.FTCV_ENABLED = "Activé"
RdKGToolMenu.constants.FTCV_MODE = "Mode"
RdKGToolMenu.constants.FTCV_COLOR_MODE = "Mode couleurs"
RdKGToolMenu.constants.FTCV_COLOR_MODE_ORIENTATION = "Orientation (Devant, côté, arrière)"
RdKGToolMenu.constants.FTCV_COLOR_MODE_DISTANCE = "Distance (Proche, éloigné)"
RdKGToolMenu.constants.FTCV_COLOR_FRONT = "Couleur 1 (Devant / Proche)"
RdKGToolMenu.constants.FTCV_COLOR_SIDE = "Couleur 2 (Côté)"
RdKGToolMenu.constants.FTCV_COLOR_BACK = "Couleur (Arrière / éloigné)"
RdKGToolMenu.constants.FTCV_OPACITY_CLOSE = "Distance opacité proche"
RdKGToolMenu.constants.FTCV_OPACITY_FAR = "Distance opacité éloigné"
RdKGToolMenu.constants.FTCV_SIZE_CLOSE = "Taille Proche"
RdKGToolMenu.constants.FTCV_SIZE_FAR = "Taille éloigné"
RdKGToolMenu.constants.FTCV_PVP_ONLY = "Uniquement en PvP"
RdKGToolMenu.constants.FTCV_MODE_RETICLE = "Réticule"
RdKGToolMenu.constants.FTCV_MODE_FIXED = "Fixe"
RdKGToolMenu.constants.FTCV_POSITION = "Position"
RdKGToolMenu.constants.FTCV_MAX_DISTANCE = "Distance maximale autorisée"
RdKGToolMenu.constants.FTCV_MIN_DISTANCE = "Distance minimale"
RdKGToolMenu.constants.FTCV_TEXTURES = "Texture"

--Follow The Crown Warnings
RdKGToolMenu.constants.FTCW_HEADER = "|c4592FFSuivre la couronne (Avertissements)|r"
RdKGToolMenu.constants.FTCW_ENABLED = "Activé"
RdKGToolMenu.constants.FTCW_WARNINGS_ENABLED = "Avertissements activés"
RdKGToolMenu.constants.FTCW_DISTANCE_ENABLED = "Distance activée"
RdKGToolMenu.constants.FTCW_DISTANCE_BACKDROP_ENABLED = "Distance en arrière-plan activée"
RdKGToolMenu.constants.FTCW_POSITION_FIXED = "Position fixe"
RdKGToolMenu.constants.FTCW_DISTANCE = "Distance maximale autorisée"
RdKGToolMenu.constants.FTCW_IGNORE_DISTANCE = "Désactivation de la distance"
RdKGToolMenu.constants.FTCW_WARNING_COLOR = "Couleur d'avertissement"
RdKGToolMenu.constants.FTCW_DISTANCE_COLOR_NORMAL = "Couleur distance normale"
RdKGToolMenu.constants.FTCW_DISTANCE_COLOR_ALERT = "Couleur alterte distance"
RdKGToolMenu.constants.FTCW_PVP_ONLY = "Uniquement en PvP"

--Follow The Crown Audio
RdKGToolMenu.constants.FTCA_HEADER = "|c4592FFSuivre la couronne (Audio)|r"
RdKGToolMenu.constants.FTCA_ENABLED = "Activé"
RdKGToolMenu.constants.FTCA_DISTANCE = "Distance maximale autorisée"
RdKGToolMenu.constants.FTCA_IGNORE_DISTANCE = "Distance désactivée"
RdKGToolMenu.constants.FTCA_PVP_ONLY = "Uniquement en PvP"
RdKGToolMenu.constants.FTCA_UNMOUNTED_ONLY = "Seulement sans monture"
RdKGToolMenu.constants.FTCA_SOUND = "Audio"
RdKGToolMenu.constants.FTCA_INTERVAL = "Intervalle"
RdKGToolMenu.constants.FTCA_THRESHOLD = "Seuil"

--Follow The Crown Beam
RdKGToolMenu.constants.FTCB_HEADER = "|c4592FFSuivre la couronne (Faisceau)|r"
RdKGToolMenu.constants.FTCB_WARNING = "|cFF0000Ce module ne fonctionnera qu'avec un taux de sous-échantillonage (subsampling) élevé.|r"
RdKGToolMenu.constants.FTCB_ENABLED = "Activé"
RdKGToolMenu.constants.FTCB_PVP_ONLY = "Uniquement en PvP"
RdKGToolMenu.constants.FTCB_SELECTED_BEAM = "Choix du faisceau"
RdKGToolMenu.constants.FTCB_COLOR = "Couleur"

--Debuff Overview
RdKGToolMenu.constants.DBO_HEADER = "|c4592FFAperçu des débuffs|r"
RdKGToolMenu.constants.DBO_ENABLED = "Activé"
RdKGToolMenu.constants.DBO_PVP_ONLY = "Uniquement en PvP"
RdKGToolMenu.constants.DBO_CRITICAL_AMOUNT = "Nombre critique de débuffs"
RdKGToolMenu.constants.DBO_COLOR_OKAY = "Couleur OK [0]"
RdKGToolMenu.constants.DBO_COLOR_NOT_OKAY = "Couleur insuffisant  [1]"
RdKGToolMenu.constants.DBO_COLOR_CRITICAL = " Couleur critique"
RdKGToolMenu.constants.DBO_POSITION_FIXED = "Position fixe"
RdKGToolMenu.constants.DBO_COLOR_OUT_OF_RANGE = "Couleur hors de portée"
RdKGToolMenu.constants.DBO_DESCRIPTION = "Ce module requiert les marqueurs de carte d'autres modules (aperçu des ressources, aperçu des synergies, mesure des soins et des dégâts).Pour obtenir les meilleurs résultats, activez l'aperçu des ressoucres"
RdKGToolMenu.constants.DBO_SIZE = "Taille"

--Rapid Tracker
RdKGToolMenu.constants.RT_HEADER = "|c4592FFAperçu manoeuvre rapide|r"
RdKGToolMenu.constants.RT_ENABLED = "Activé"
RdKGToolMenu.constants.RT_PVP_ONLY = "PvP Only"
RdKGToolMenu.constants.RT_POSITION_FIXED = "Position Fixed"
RdKGToolMenu.constants.RT_COLOR_LABEL_IN_RANGE = "Couleur du nom à portée"
RdKGToolMenu.constants.RT_COLOR_LABEL_NOT_IN_RANGE = "Couleur du nom hors de portée"
RdKGToolMenu.constants.RT_COLOR_LABEL_OUT_OF_RANGE = "Couleur du nom absent"
RdKGToolMenu.constants.RT_COLOR_RAPID_ON = "Couleur manoeuvre rapide activée"
RdKGToolMenu.constants.RT_COLOR_RAPID_OFF = "Couleur manoeuvre rapide inactive"

--Resource Overview
RdKGToolMenu.constants.RO_HEADER_ULTIMATES = "|c4592FFAperçu des ressources (Combinées)|r" 
RdKGToolMenu.constants.RO_ENABLED = "Activé"
RdKGToolMenu.constants.RO_PVP_ONLY = "Uniquement en PvP"
RdKGToolMenu.constants.RO_POSITION_FIXED = "Position fixe"
RdKGToolMenu.constants.RO_ULTIMATE_OVERVIEW_ENABLED = "Aperçu des ultis du groupe activé"
RdKGToolMenu.constants.RO_CLIENT_ULTIMATE_ENABLED = "Fenêtre individuelle activée"
RdKGToolMenu.constants.RO_GROUP_ULTIMATES_ENABLED = "Fenêtre de groupe activée"
RdKGToolMenu.constants.RO_SHOW_SOFT_RESOURCES = "Afficher stamina / magicka"
RdKGToolMenu.constants.RO_DISPLAYED_ULTIMATES = "Afficher le nombre des ultis"
RdKGToolMenu.constants.RO_COLOR_BACKGROUND = "Couleur de fond des ressources"
RdKGToolMenu.constants.RO_COLOR_MAGICKA = "Couleur des ressources en magicka"
RdKGToolMenu.constants.RO_COLOR_STAMINA = "Couleur des ressources en stamina"
RdKGToolMenu.constants.RO_COLOR_OUT_OF_RANGE = "Couleur des ressources hors de portée"
RdKGToolMenu.constants.RO_COLOR_DEAD = "Couleur des ressoucres mort"
RdKGToolMenu.constants.RO_COLOR_PROGRESS_NOT_FULL = "Couleur des ressources entamées"
RdKGToolMenu.constants.RO_COLOR_PROGRESS_FULL = "couleur des ressources pleines"
RdKGToolMenu.constants.RO_COLOR_LABEL_FULL = "Couleur d'étiquette de ressource \"Pleine\""
RdKGToolMenu.constants.RO_COLOR_LABEL_NOT_FULL = "Couleur d'étiquette de ressources \"Entamée\""
RdKGToolMenu.constants.RO_COLOR_LABEL_GROUP = "Couleur d'étiquette de ressources \"Groupe\""
RdKGToolMenu.constants.RO_COLOR_LABEL_ANNOUNCEMENT = "Couleur d'annonce"
RdKGToolMenu.constants.RO_ANNOUNCEMENT_SIZE = "Taille d'annonce"
RdKGToolMenu.constants.RO_IN_COMBAT_ENABLED = "In Combat State Enabled" ---xxx
RdKGToolMenu.constants.RO_IN_COMBAT_COLOR = "In Combat Color" ---xxx
RdKGToolMenu.constants.RO_OUT_OF_COMBAT_COLOR = "Out Of Combat Color" ---xxx
RdKGToolMenu.constants.RO_IN_STEALTH_ENABLED = "Afficher le statut furtif"
RdKGToolMenu.constants.RO_ULTIMATE_GROUPS_ENABLED = "Ultis de groupe activées" 
RdKGToolMenu.constants.RO_ULTIMATE_SORTING_MODE = "Mode de tri"
RdKGToolMenu.constants.RO_ULTIMATE_GROUP_SIZE_DESTRO = "Taille de groupe bâton de destruction"
RdKGToolMenu.constants.RO_ULTIMATE_GROUP_SIZE_STORM = "Taille de groupe tempête"
RdKGToolMenu.constants.RO_ULTIMATE_GROUP_SIZE_NORTHERNSTORM = "Taille de groupe tempête du nord"
RdKGToolMenu.constants.RO_ULTIMATE_GROUP_SIZE_PERMAFROST = "Taille de groupe permafrost"
RdKGToolMenu.constants.RO_ULTIMATE_GROUP_SIZE_NEGATE = "Taille de groupe négation de la magie"
RdKGToolMenu.constants.RO_ULTIMATE_GROUP_SIZE_NEGATE_OFFENSIVE = "Negate Off Group Size"
RdKGToolMenu.constants.RO_ULTIMATE_GROUP_SIZE_NEGATE_COUNTER = "Negate Counter Group Size"
RdKGToolMenu.constants.RO_ULTIMATE_GROUP_SIZE_NOVA = "Taille de groupe Nova"
RdKGToolMenu.constants.RO_ULTIMATE_DISPLAY_MODE = "Mode d'affichage" 
RdKGToolMenu.constants.RO_MAX_DISTANCE = "Distance maximale"
RdKGToolMenu.constants.RO_SOUND_ENABLED = "Son activé"
RdKGToolMenu.constants.RO_SELECTED_SOUND = "Sélection du son"
RdKGToolMenu.constants.RO_HEADER_GROUPS = "|c4592FFAperçu des ressources (Séparées)|r"
RdKGToolMenu.constants.RO_GROUPS_ENABLED = "Groupes activés" 
RdKGToolMenu.constants.RO_GROUPS_MODE = "Mode" 
RdKGToolMenu.constants.RO_GROUPS_1_NAME = "Groupe 1 Nom"
RdKGToolMenu.constants.RO_GROUPS_2_NAME = "Group 2 Nom"
RdKGToolMenu.constants.RO_GROUPS_3_NAME = "Group 3 Nom"
RdKGToolMenu.constants.RO_GROUPS_4_NAME = "Group 4 Nom"
RdKGToolMenu.constants.RO_GROUPS_5_NAME = "Group 5 Nom"
RdKGToolMenu.constants.RO_GROUPS_1_ENABLED = "Groupe 1 activé"
RdKGToolMenu.constants.RO_GROUPS_2_ENABLED = "Group 2 activé"
RdKGToolMenu.constants.RO_GROUPS_3_ENABLED = "Group 3 activé"
RdKGToolMenu.constants.RO_GROUPS_4_ENABLED = "Group 4 activé"
RdKGToolMenu.constants.RO_GROUPS_5_ENABLED = "Group 5 activé"
RdKGToolMenu.constants.RO_GROUPS_1_DEFAULT = "Dégâts"
RdKGToolMenu.constants.RO_GROUPS_2_DEFAULT = "Support"
RdKGToolMenu.constants.RO_GROUPS_3_DEFAULT = "Soin"
RdKGToolMenu.constants.RO_GROUPS_4_DEFAULT = "Synergie"
RdKGToolMenu.constants.RO_GROUPS_5_DEFAULT = "Indéfini"
RdKGToolMenu.constants.RO_GROUPS_PRIORITY = " Priorité:"
RdKGToolMenu.constants.RO_GROUPS_GROUP = " Groupe:"
RdKGToolMenu.constants.RO_COLOR_GROUPS_EDGE_OUT_OF_COMBAT = "Bordure hors combat"
RdKGToolMenu.constants.RO_COLOR_GROUPS_EDGE_IN_COMBAT = "Bordure en combat"
RdKGToolMenu.constants.RO_SIZE = "Taille"
RdKGToolMenu.constants.RO_SPACING = "Espacement"
RdKGToolMenu.constants.RO_SHARED_SETTING = "Ce réglage d'aperçu de ressources est partagé (Ultis / Groupes) Modifier cette valeur affectera les deux modules. Vous pouvez désactiver des modules en ajustant d'autres réglages (fenêtres)."

--HP Damage Meter
RdKGToolMenu.constants.HDM_HEADER = "|c4592FFMesure des dégâts de santé|r"
RdKGToolMenu.constants.HDM_ENABLED = "Activé"
RdKGToolMenu.constants.HDM_PVP_ONLY = "Uniquement en PvP"
RdKGToolMenu.constants.HDM_POSITION_FIXED = "Position fixe"
RdKGToolMenu.constants.HDM_WINDOW_ENABLED = "Fenêtre activée"
RdKGToolMenu.constants.HDM_USING_ALPHA = "Utilisation de l'Alpha"
RdKGToolMenu.constants.HDM_USING_COLORS = "Couleurs de fond"
RdKGToolMenu.constants.HDM_USING_HIGHLIGHT_APPLICANT = "Surbrillance candidat"
RdKGToolMenu.constants.HDM_AUTO_RESET = "Reset Counter Out Of Combat" ---xxx
RdKGToolMenu.constants.HDM_SELECTED_VIEWMODE = "Sélection du mode"
RdKGToolMenu.constants.HDM_ALIVE_COLOR = "Couleur vivant"
RdKGToolMenu.constants.HDM_DEAD_COLOR = "Couleur mort"
RdKGToolMenu.constants.HDM_BACKGROUND_COLOR_HEALER = "Couleur de fond soigneur"
RdKGToolMenu.constants.HDM_BACKGROUND_COLOR_DD = "Couleur de fond DPS"
RdKGToolMenu.constants.HDM_BACKGROUND_COLOR_TANK = "Couleur de fond tank"
RdKGToolMenu.constants.HDM_BACKGROUND_COLOR_APPLICANT = "Couleur de fond candidat"
RdKGToolMenu.constants.HDM_SIZE = "Taille"

--Potion Overview
RdKGToolMenu.constants.PO_HEADER = "|c4592FFAperçu des potions|r"
RdKGToolMenu.constants.PO_ENABLED = "Activé"
RdKGToolMenu.constants.PO_PVP_ONLY = "Uniquement en PvP"
RdKGToolMenu.constants.PO_POSITION_FIXED = "Position fixe"
RdKGToolMenu.constants.PO_COLOR_BACKGROUND_NO_IMMOVABLE = "Couleur de fond pas d'inamovible"
RdKGToolMenu.constants.PO_COLOR_BACKGROUND_IMMOVABLE_FULL = "Couleur de fond inamovible plein"
RdKGToolMenu.constants.PO_COLOR_BACKGROUND_IMMOVABLE_LOW = "Couleur de fond inamovible bas"
RdKGToolMenu.constants.PO_COLOR_PROGRESS_IMMOVABLE = "Couleur de fond inamovible"
-- U30+ Change (Temporary Fix)
--[[
RdKGToolMenu.constants.PO_COLOR_CRAFTED_PROGRESS_POTION = "Couleur de progression potions (fabriquée)"
RdKGToolMenu.constants.PO_COLOR_CROWN_PROGRESS_POTION = "Couleur de progression potions (couronnes)"
RdKGToolMenu.constants.PO_COLOR_NON_CRAFTED_PROGRESS_POTION = "Couleur de progression potion (non fabriquée)"
RdKGToolMenu.constants.PO_COLOR_ALLIANCE_PROGRESS_POTION = "Couleur de progression potion (Alliance)"
]]
RdKGToolMenu.constants.PO_COLOR_CRAFTED_PROGRESS_POTION = "Couleur de progression potions"
RdKGToolMenu.constants.PO_COLOR_LABEL_IMMOVABLE = "Couleur d'étiquette inamovible"
RdKGToolMenu.constants.PO_COLOR_LABEL_POTION = "Couleur d'étiquette potion"
RdKGToolMenu.constants.PO_COLOR_BACKDROP_IMMOVABLE = "Couleur de fond inamovible"
RdKGToolMenu.constants.PO_COLOR_BACKDROP_POTION = "Couleur de fond potion"
RdKGToolMenu.constants.PO_SOUND_ENABLED = "Son activé"
RdKGToolMenu.constants.PO_SELECTED_SOUND = "Sélection du son"

--Detonation Tracker
RdKGToolMenu.constants.DT_HEADER = "|c4592FFSuivi des détonations / shalks|r"
RdKGToolMenu.constants.DT_ENABLED = "Activé"
RdKGToolMenu.constants.DT_PVP_ONLY = "Uniquement en PvP"
RdKGToolMenu.constants.DT_POSITION_FIXED = "Position fixe"
RdKGToolMenu.constants.DT_FONT_COLOR_DETONATION = "Détonation: Couleur de police"
RdKGToolMenu.constants.DT_PROGRESS_COLOR_DETONATION = "Détonation: Couleur de progression"
RdKGToolMenu.constants.DT_FONT_COLOR_SUBTERRANEAN_ASSAULT = "Assaut: Couleur de police"
RdKGToolMenu.constants.DT_PROGRESS_COLOR_SUBTERRANEAN_ASSAULT = "Assaut: Couleur de progression"
RdKGToolMenu.constants.DT_FONT_COLOR_SUBTERRANEAN_ASSAULT2 = "Assaut 2: Couleur de police"
RdKGToolMenu.constants.DT_PROGRESS_COLOR_SUBTERRANEAN_ASSAULT2 = "Assaut 2: Couleur de progression"
RdKGToolMenu.constants.DT_FONT_COLOR_DEEP_FISSURE = "Fissure: Couleur de police"
RdKGToolMenu.constants.DT_PROGRESS_COLOR_DEEP_FISSURE = "Fissure: Couleur de progression"
RdKGToolMenu.constants.DT_FONT_COLOR_DEEP_FISSURE2 = "Fissure 2: Couleur de police"
RdKGToolMenu.constants.DT_PROGRESS_COLOR_DEEP_FISSURE2 = "Fissure 2: Couleur de progression"
RdKGToolMenu.constants.DT_FONT_COLOR_SOUL_OF_FLAME = "Soul Of Flame: Couleur de police" ---xxx
RdKGToolMenu.constants.DT_PROGRESS_COLOR_SOUL_OF_FLAME = "Soul Of Flame: Couleur de progression" ---xxx
RdKGToolMenu.constants.DT_SOUL_OF_FLAME_PROMPT_ENABLED = "Soul of Flame: Minuterie d'affichage activée" ---xxx
RdKGToolMenu.constants.DT_SOUL_OF_FLAME_TEXT = "Minuterie d'affichage texte" ---xxx
RdKGToolMenu.constants.DT_SIZE = "Taille"
RdKGToolMenu.constants.DT_MODE = "Mode"
RdKGToolMenu.constants.DT_SMOOTH_TRANSITION = "Transition douce"
RdKGToolMenu.constants.DT_SOUL_BETWEEN_DESC = "Afficher la fenêtre d'invite Soul Of Flame" ---xxx
RdKGToolMenu.constants.DT_SOUL_BETWEEN1 = "Entre" ---xxx
RdKGToolMenu.constants.DT_SOUL_BETWEEN2 = "Et" ---xxx

--Group Beams
RdKGToolMenu.constants.GB_HEADER = "|c4592FFFaisceaux de groupe|r"
RdKGToolMenu.constants.GB_DESCRIPTION = "Le rayon du joueur dépend du rôle qui lui a été assigné. Les rôles peuvent être répartis par le chef de groupe ou par le joueur."
RdKGToolMenu.constants.GB_ENABLED = "Activé"
RdKGToolMenu.constants.GB_PVP_ONLY = "Uniquement en PvP"
RdKGToolMenu.constants.GB_HIDE_WHEN_DEAD = "Cacher quand mort"
RdKGToolMenu.constants.GB_SIZE = "Taille"
RdKGToolMenu.constants.GB_SELECTED_BEAM = "Sélection du faisceau"
RdKGToolMenu.constants.GB_ROLE_RAPID_ENABLED = "Manoeuvre rapide activée"
RdKGToolMenu.constants.GB_ROLE_RAPID_COLOR = "Couleur de maoeuvre rapide"
RdKGToolMenu.constants.GB_ROLE_PURGE_ENABLED = "Purge activée"
RdKGToolMenu.constants.GB_ROLE_PURGE_COLOR = "Couleur de purge"
RdKGToolMenu.constants.GB_ROLE_HEAL_ENABLED = "Soin activé"
RdKGToolMenu.constants.GB_ROLE_HEAL_COLOR = "Couleur de soin"
RdKGToolMenu.constants.GB_ROLE_DD_ENABLED = "APS activé"
RdKGToolMenu.constants.GB_ROLE_DD_COLOR = "Couleur de DPS"
RdKGToolMenu.constants.GB_ROLE_SYNERGY_ENABLED = "Synergie activée"
RdKGToolMenu.constants.GB_ROLE_SYNERGY_COLOR = "Couleur synergie"
RdKGToolMenu.constants.GB_ROLE_CC_ENABLED = "CC activé"
RdKGToolMenu.constants.GB_ROLE_CC_COLOR = "Couleur de CC"
RdKGToolMenu.constants.GB_ROLE_SUPPORT_ENABLED = "Soutien activé"
RdKGToolMenu.constants.GB_ROLE_SUPPORT_COLOR = "Couleur de soutien"
RdKGToolMenu.constants.GB_ROLE_PLACEHOLDER_ENABLED = "Indéfini activé"
RdKGToolMenu.constants.GB_ROLE_PLACEHOLDER_COLOR = "Couleur d'indéfini"
RdKGToolMenu.constants.GB_ROLE_APPLICANT_ENABLED = "Candidat activé"
RdKGToolMenu.constants.GB_ROLE_APPLICANT_COLOR = "Couleur de candidat"

--I See Dead People
RdKGToolMenu.constants.ISDP_HEADER = "|c4592FFJe vois les morts|r"
RdKGToolMenu.constants.ISDP_ENABLED = "Activé"
RdKGToolMenu.constants.ISDP_PVP_ONLY = "Uniquement en PvP"
RdKGToolMenu.constants.ISDP_SIZE = "Taille"
RdKGToolMenu.constants.ISDP_SELECTED_BEAM = "Couleur de rayon - sélectionné"
RdKGToolMenu.constants.ISDP_COLOR_DEAD = "Couleur mort"
RdKGToolMenu.constants.ISDP_COLOR_BEING_RESURRECTED = "Couleur en cours de résurrection"
RdKGToolMenu.constants.ISDP_COLOR_RESURRECTED = "Couleur ressuscité"

--Compass
RdKGToolMenu.constants.COMPASS_HEADER = "|cFF8174Réglages de la boussole|r"
--YACS
RdKGToolMenu.constants.YACS_HEADER = "|c4592FFYet Another Compass|r"
RdKGToolMenu.constants.YACS_CHK_ADDON_ENABLED = "Activé"
RdKGToolMenu.constants.YACS_CHK_PVP = "Activé en PvP"
RdKGToolMenu.constants.YACS_CHK_PVE = "Activé en PvE"
RdKGToolMenu.constants.YACS_CHK_COMBAT = "Activé en combat"
RdKGToolMenu.constants.YACS_CHK_MOVABLE = "Boussole déplaçable"
RdKGToolMenu.constants.YACS_COLOR_COMPASS = "Couleur de la boussole"
RdKGToolMenu.constants.YACS_COMPASS_SIZE = "Taille de la boussole"
RdKGToolMenu.constants.YACS_COMPASS_SIZE_TOOLTIPE = "Règle la taille de la boussole"
RdKGToolMenu.constants.YACS_COMPASS_STYLE = "Style"
RdKGToolMenu.constants.YACS_COMPASS_STYLE_TOOLTIP = "Sélection du type de boussole"
RdKGToolMenu.constants.YACS_RESTORE_DEFAULTS = "Valeurs par défaut"

--SC
RdKGToolMenu.constants.COMPASS_SC_HEADER = "|c4592FFSimple Compass|r"
RdKGToolMenu.constants.COMPASS_SC_ENABLED = "Activé"
RdKGToolMenu.constants.COMPASS_SC_PVP = "Activé en PvP"
RdKGToolMenu.constants.COMPASS_SC_PVE = "Activé en PvE"
RdKGToolMenu.constants.COMPASS_SC_POSITION_FIXED = "Position fixe"
RdKGToolMenu.constants.COMPASS_SC_COLOR_BACKDROP = "Couleur de fond"
RdKGToolMenu.constants.COMPASS_SC_COLOR_DIRECTION_NORTH = "Couleur direction nord"
RdKGToolMenu.constants.COMPASS_SC_COLOR_DIRECTION_SOUTH = "Couleur direction sud"
RdKGToolMenu.constants.COMPASS_SC_COLOR_DIRECTION_WEST = "Couleur direction ouest"
RdKGToolMenu.constants.COMPASS_SC_COLOR_DIRECTION_EAST = "Couleur direction est"
RdKGToolMenu.constants.COMPASS_SC_COLOR_DIRECTION_OTHERS = "Couleur autres directions"
RdKGToolMenu.constants.COMPASS_SC_COLOR_MARKERS = "Couleur marqueurs"

--Toolbox
RdKGToolMenu.constants.TOOLBOX_HEADER = "|cFF8174Réglages de la boîte à outils|r"
--Siege Merchant
RdKGToolMenu.constants.SM_HEADER = "|c4592FFMarchand d'engins de siège|r"
RdKGToolMenu.constants.SM_ENABLED = "Activé"
RdKGToolMenu.constants.SM_SEND_CHAT_MESSAGES = "Envoyer les messages au chat"
RdKGToolMenu.constants.SM_ITEM_REPAIR_WALL = "Kit de réparation de murs de forteresse"
RdKGToolMenu.constants.SM_ITEM_REPAIR_DOOR = "Kit de réparation de portes de forteresse"
RdKGToolMenu.constants.SM_ITEM_REPAIR_SIEGE = "Kit de réparation d'engins de siège"
RdKGToolMenu.constants.SM_ITEM_BALLISTA_FIRE = "Balliste de feu"
RdKGToolMenu.constants.SM_ITEM_BALLISTA_STONE = "Balliste"
RdKGToolMenu.constants.SM_ITEM_BALLISTA_LIGHTNING = "Balliste de foudre"
RdKGToolMenu.constants.SM_ITEM_TREBUCHET_FIRE = "Trébuchet de feu"
RdKGToolMenu.constants.SM_ITEM_TREBUCHET_STONE = "Trébuchet de pierres"
RdKGToolMenu.constants.SM_ITEM_TREBUCHET_ICE = "Trébuchet de glace"
RdKGToolMenu.constants.SM_ITEM_CATAPULT_MEATBAG = "Trébuchet de sacs à viande"
RdKGToolMenu.constants.SM_ITEM_CATAPULT_OIL = "Catapulte à huile"
RdKGToolMenu.constants.SM_ITEM_CATAPULT_SCATTERSHOT = "Catapulte ??? "
RdKGToolMenu.constants.SM_ITEM_OIL = "Huile enflammée"
RdKGToolMenu.constants.SM_ITEM_CAMP = "Camp avancé"
RdKGToolMenu.constants.SM_ITEM_RAM = "Bélier"
RdKGToolMenu.constants.SM_ITEM_KEEP_RECALL = "Pierre de retour au fort"
RdKGToolMenu.constants.SM_ITEM_DESTRUCTIBLE_REPAIR = "Kit de réparation de pont et de passages"
RdKGToolMenu.constants.SM_MIN = "Minimum"
RdKGToolMenu.constants.SM_MAX = "Maximum"
RdKGToolMenu.constants.SM_PAYMENT_OPTIONS = "Options de paiement"
RdKGToolMenu.constants.SM_ITEM_REPAIR_ALL = "Nécessaire de réparation de Cyrodiil"
RdKGToolMenu.constants.SM_ITEM_POT_RED = "Lampée de Santé d'alliance"
RdKGToolMenu.constants.SM_ITEM_POT_GREEN = "Lampée de bataille d'alliance"
RdKGToolMenu.constants.SM_ITEM_POT_BLUE = "Lampée de sorts d'alliance"
RdKGToolMenu.constants.SM_ITEM_TRI_POT = "Potion de triple restauration liée" ---xxx
RdKGToolMenu.constants.SM_ITEM_CF_TACK = "biscuit de terrain cyrodiiliaque" ---xxx
RdKGToolMenu.constants.SM_ITEM_CF_TREAT = "fiandise de terrain cyrodiiliaque" ---xxx
RdKGToolMenu.constants.SM_ITEM_CF_BAR = "barre de terrain cyrodiiliaque" ---xxx
RdKGToolMenu.constants.SM_ITEM_CF_BREW = "bière de terrain cyrodiiliaque" ---xxx
RdKGToolMenu.constants.SM_ITEM_CF_TEA = "thé de terrain cyrodiiliaque" ---xxx
RdKGToolMenu.constants.SM_ITEM_CF_TONIC = "tonique de terrain cyrodiiliaque" ---xxx
RdKGToolMenu.constants.SM_ITEM_SOUL_GEM = "pierre d'âme" ---xxx
RdKGToolMenu.constants.SM_ITEM_SOUL_GEM_EMPTY = "pierre d'âme vide" ---xxx

--Rechargeur
RdKGToolMenu.constants.RECHARGER_HEADER = "|c4592FFRechargement des armes|r"
RdKGToolMenu.constants.RECHARGER_ENABLED = "Activé"
RdKGToolMenu.constants.RECHARGER_SEND_CHAT_MESSAGES = "Envoyer les messages au chat"
RdKGToolMenu.constants.RECHARGER_PERCENT = "Pourcentage minimum de recharge"
RdKGToolMenu.constants.RECHARGER_SOULGEMS_EMPTY_WARNING = "Alerte si stock de pierres d'âmes épuisé"
RdKGToolMenu.constants.RECHARGER_SOULGEMS_THRESHOLD_WARNING = "Alerte si  stock de pierres d'âmes bientôt épuisé"
RdKGToolMenu.constants.RECHARGER_SOULGEMS_THRESHOLD_SLIDER = "Seuil de pierres d'âmes"
RdKGToolMenu.constants.RECHARGER_SOULGEMS_EMPTY_LOGIN_WARNING = "Alerte de pierres d'âmes au chargement"
RdKGToolMenu.constants.RECHARGER_INTERVAL = "Intervalle de vérification"

--Keep Claimer
RdKGToolMenu.constants.KC_HEADER = "|c4592FFRevendication de forteresses|r"
RdKGToolMenu.constants.KC_ENABLED = "Activé"
RdKGToolMenu.constants.KC_GUILD_1 = "Priorité 1"
RdKGToolMenu.constants.KC_GUILD_2 = "Priorité 2"
RdKGToolMenu.constants.KC_GUILD_3 = "Priorité 3"
RdKGToolMenu.constants.KC_GUILD_4 = "Priorité 4"
RdKGToolMenu.constants.KC_GUILD_5 = "Priorité 5"
RdKGToolMenu.constants.KC_CLAIM_KEEPS = "Revendiquer les forts"
RdKGToolMenu.constants.KC_CLAIM_OUTPOSTS = "Revendiquer les avant-postes"
RdKGToolMenu.constants.KC_CLAIM_RESOURCES = "Revendiquer les ressources"

--Buff Food Tracker
RdKGToolMenu.constants.BFT_HEADER = "|c4592FFSuivi des buffs d'aliments|r"
RdKGToolMenu.constants.BFT_ENABLED = "Activé"
RdKGToolMenu.constants.BFT_PVP_ONLY = "Uniquemen en PvP"
RdKGToolMenu.constants.BFT_POSITION_FIXED = "Position fixe"
RdKGToolMenu.constants.BFT_SIZE = "Taille de l'alerte"
RdKGToolMenu.constants.BFT_COLOR = "Couleur de l'alerte"
RdKGToolMenu.constants.BFT_SOUND_ENABLED = "Son activé"
RdKGToolMenu.constants.BFT_SELECTED_SOUND = "Sélection du son"
RdKGToolMenu.constants.BFT_WARNING_TIMER = "Timer d'alerte"

--Journal de Cyrodiil
RdKGToolMenu.constants.CL_HEADER = "|c4592FFJournal de Cyrodiil|r"
RdKGToolMenu.constants.CL_ENABLED = "Activé"
RdKGToolMenu.constants.CL_GUILD_CLAIM_ENABLED = "Messages concernant les revendications de guilde"
RdKGToolMenu.constants.CL_GUILD_LOST_ENABLED = "Messages concernant les échecs de revendication"
RdKGToolMenu.constants.CL_UA_ENABLED = "Messages d'attaque"
RdKGToolMenu.constants.CL_UA_LOST_ENABLED = "Messages de fin d'attaque"
RdKGToolMenu.constants.CL_KEEP_ALLIANCE_CHANGED_ENABLED = "Messages de changement d'alliance"
RdKGToolMenu.constants.CL_TICK_DEFENSE = "Messages de ticks défensifs"
RdKGToolMenu.constants.CL_TICK_OFFENSE = "Messages de ticks offensifs"
RdKGToolMenu.constants.CL_SCROLL_NOTIFICATIONS = "Défilement des messages"
RdKGToolMenu.constants.CL_EMPEROR_ENABLED = "Messages concernant d'empereur"
RdKGToolMenu.constants.CL_QUEST_ENABLED = "Messages de quêtes"
RdKGToolMenu.constants.CL_BATTLEGROUND_ENABLED = "Messages de champs de bataille"
RdKGToolMenu.constants.CL_DAEDRIC_ARTIFACT_ENABLED = "Alertes artifacts daédriques"

--Cyrodiil Status
RdKGToolMenu.constants.CS_HEADER = "|c4592FFStatut de Cyrodiil|r"
RdKGToolMenu.constants.CS_ENABLED = "Activé"
RdKGToolMenu.constants.CS_POSITION_FIXED = "Position fixe"
RdKGToolMenu.constants.CS_HIDE_ON_WORLDMAP = "Cacher sur la carte"
RdKGToolMenu.constants.CS_SHOW_FLAGS = "Afficher les drapeaux"
RdKGToolMenu.constants.CS_SHOW_SIEGES = "Afficher les sièges"
RdKGToolMenu.constants.CS_SHOW_OWNER_CHANGES = "Afficher les timers de changements de bannières"
RdKGToolMenu.constants.CS_SHOW_ACTION_TIMERS = "Afficher les timers d'actions"
RdKGToolMenu.constants.CS_COLOR_DEFAULT = "Couleur par défaut"
RdKGToolMenu.constants.CS_COLOR_COOLDOWN = "Couleur de temps de recharge"
RdKGToolMenu.constants.CS_COLOR_FLIPS_POSITIVE = "Couleur de changement de drapeau positif"
RdKGToolMenu.constants.CS_COLOR_FLIPS_NEGATIVE = "Couleur de changement de drapeau négatif"
RdKGToolMenu.constants.CS_SHOW_KEEPS = "Montrer les forts"
RdKGToolMenu.constants.CS_SHOW_OUTPOSTS = "Montrer les avant-postes"
RdKGToolMenu.constants.CS_SHOW_RESOURCES = "Montrer les ressources"
RdKGToolMenu.constants.CS_SHOW_VILLAGES = "Montrer les villages"
RdKGToolMenu.constants.CS_SHOW_TEMPLES = "Montrer les temples"
RdKGToolMenu.constants.CS_SHOW_DESTRUCTIBLES = "Montrer destructible"

--Enhancements
RdKGToolMenu.constants.ENHANCE_HEADER = "|c4592FFAméliorations|r"
RdKGToolMenu.constants.ENHANCE_QUEST_TRACKER_ENABLED = "Désactiver le suivi de quêtes"
RdKGToolMenu.constants.ENHANCE_QUEST_TRACKER_PVP_ONLY = "Suivi de quêtes uniquement en PvP"
RdKGToolMenu.constants.ENHANCE_COMPASS_TWEAKS_ENABLED = "Activer les améliorations de boussole"
RdKGToolMenu.constants.ENHANCE_COMPASS_PVP_ONLY = "Boussole uniquement en PvP"
RdKGToolMenu.constants.ENHANCE_COMPASS_HIDDEN = "Cacher la boussole"
RdKGToolMenu.constants.ENHANCE_COMPASS_WIDTH = "Largeur de la boussole"
RdKGToolMenu.constants.ENHANCE_ALERTS_TWEAKS_ENABLED = "Amélioration des alertes activée"
RdKGToolMenu.constants.ENHANCE_ALERTS_PVP_ONLY = "Alertes uniqiuement en PvP"
RdKGToolMenu.constants.ENHANCE_ALERTS_HIDDEN = "Cacher les alertes"
RdKGToolMenu.constants.ENHANCE_ALERTS_POSITION = "Position des alertes"
RdKGToolMenu.constants.ENHANCE_ALERTS_COLOR = "Couleur des alertes"
RdKGToolMenu.constants.ENHANCE_RESPAWN_TIMER_ENABLED = "Désactiver le chronomètre de résurrection"

--Respawner
RdKGToolMenu.constants.RESPAWNER_HEADER = "|c4592FFRésurrection|r"
RdKGToolMenu.constants.RESPAWNER_ENABLED = "Activé"
RdKGToolMenu.constants.RESPAWNER_RESTRICTED_PORT = "Distance limitée"

--Camp Preview
RdKGToolMenu.constants.CP_HEADER = "|c4592FFPrévisualisation du camp|r"
RdKGToolMenu.constants.CP_ENABLED = "Activé"

--Synergy Prevention
RdKGToolMenu.constants.SP_HEADER = "|c4592FFPrévention des synergies|r"
RdKGToolMenu.constants.SP_ENABLED = "Activé"
RdKGToolMenu.constants.SP_PVP_ONLY = "Seulement en PvP"
RdKGToolMenu.constants.SP_WINDOW_ENABLED = "Fenêtre activée"
RdKGToolMenu.constants.SP_POSITION_FIXED = "Position fixe"
RdKGToolMenu.constants.SP_MODE = "Mode"
RdKGToolMenu.constants.SP_MAX_DISTANCE = "Distance maximale"
RdKGToolMenu.constants.SP_SYNERGY_COMBUSTION_SHARD = "Empêcher Combustion / Eclats"
RdKGToolMenu.constants.SP_SYNERGY_TALONS = "Empêcher Serres"
RdKGToolMenu.constants.SP_SYNERGY_NOVA = "Empêcher Nova"
RdKGToolMenu.constants.SP_SYNERGY_BLOOD_ALTAR = "Empêcher Entonnoir de sang"
RdKGToolMenu.constants.SP_SYNERGY_STANDARD = "Empêcher Etendard"
RdKGToolMenu.constants.SP_SYNERGY_PURGE = "Empêcher Rituel"
RdKGToolMenu.constants.SP_SYNERGY_BONE_SHIELD = "Empêcher bouclier d'os"
RdKGToolMenu.constants.SP_SYNERGY_FLOOD_CONDUIT = "Empêcher canalisation"
RdKGToolMenu.constants.SP_SYNERGY_ATRONACH = "Empêcher Atronach"
RdKGToolMenu.constants.SP_SYNERGY_TRAPPING_WEBS = "Empêcher toiles entravantes"
RdKGToolMenu.constants.SP_SYNERGY_RADIATE = "Empêcher Faisceau"
RdKGToolMenu.constants.SP_SYNERGY_CONSUMING_DARKNESS = "Empêcher Ténèbres dévorantes"
RdKGToolMenu.constants.SP_SYNERGY_SOUL_LEECH = "Empêcher absorption d'âme"
RdKGToolMenu.constants.SP_SYNERGY_WARDEN_HEALING = "Empêcher graine curative"
RdKGToolMenu.constants.SP_SYNERGY_GRAVE_ROBBER = "Empêcher tombe"
RdKGToolMenu.constants.SP_SYNERGY_PURE_AGONY = "Empêcher agonie pure"
RdKGToolMenu.constants.SP_SYNERGY_ICY_ESCAPE = "Empêcher Évasion glacée"
RdKGToolMenu.constants.SP_SYNERGY_SANGUINE_BURST = "Empêcher Détonation sanguine"
RdKGToolMenu.constants.SP_SYNERGY_HEED_THE_CALL = "Empêcher Répondez à l'appel"
RdKGToolMenu.constants.SP_SYNERGY_URSUS = "Empêcher Bouclier d'Ursus" ---xxx
RdKGToolMenu.constants.SP_SYNERGY_GRYPHON = "Empêcher Représailles du griffon" ---xxx
RdKGToolMenu.constants.SP_SYNERGY_RUNEBREAK = "Empêcher Brusire de rune" ---xxx
RdKGToolMenu.constants.SP_SYNERGY_PASSAGE = "Empêcher Passage" ---xxx
RdKGToolMenu.constants.SP_SYNERGY_RECOVERY = "Empêcher Libération de convergence" ---xxx

--Aperçu des synergies
RdKGToolMenu.constants.SO_HEADER = "|c4592FFAperçu des synergies|r"
RdKGToolMenu.constants.SO_ENABLED = "Activé"
RdKGToolMenu.constants.SO_WINDOW_ENABLED = "Fenâtre activée"
RdKGToolMenu.constants.SO_PVP_ONLY = "Seulement en PvP"
RdKGToolMenu.constants.SO_POSITION_FIXED = "Position fixe"
RdKGToolMenu.constants.SO_DISPLAY_MODE = "Mode d'affichage"
RdKGToolMenu.constants.SO_TABLE_MODE = "Mode tableau"
RdKGToolMenu.constants.SO_SIZE = "Taille"
RdKGToolMenu.constants.SO_COLOR_SYNERGY_BACKDROP = "Couleur de fond synergies"
RdKGToolMenu.constants.SO_COLOR_SYNERGY_PROGRESS = "Couleur de progression synergies"
RdKGToolMenu.constants.SO_COLOR_SYNERGY = "Couleur de synergie"
RdKGToolMenu.constants.SO_COLOR_BACKGROUND = "Couleur de fond"
RdKGToolMenu.constants.SO_COLOR_TEXT = "Couleur du texte"
RdKGToolMenu.constants.SO_SYNERGY_COMBUSTION_SHARD = "Afficher combustion / éclats"
RdKGToolMenu.constants.SO_SYNERGY_TALONS = "Afficher Serres"
RdKGToolMenu.constants.SO_SYNERGY_NOVA = "Afficher Nova"
RdKGToolMenu.constants.SO_SYNERGY_BLOOD_ALTAR = "Afficher Autel"
RdKGToolMenu.constants.SO_SYNERGY_STANDARD = "Afficher Etendard"
RdKGToolMenu.constants.SO_SYNERGY_PURGE = "Afficher Rituel"
RdKGToolMenu.constants.SO_SYNERGY_BONE_SHIELD = "Afficher Bouclier d'os"
RdKGToolMenu.constants.SO_SYNERGY_FLOOD_CONDUIT = "Afficher Canalisation"
RdKGToolMenu.constants.SO_SYNERGY_ATRONACH = "Afficher Atronach"
RdKGToolMenu.constants.SO_SYNERGY_TRAPPING_WEBS = "Afficher Toiles entravantes"
RdKGToolMenu.constants.SO_SYNERGY_RADIATE = "Afficher Faisceau"
RdKGToolMenu.constants.SO_SYNERGY_CONSUMING_DARKNESS = "Afficher Ténèbres dévorantes"
RdKGToolMenu.constants.SO_SYNERGY_SOUL_LEECH = "Afficher absorption d'âme"
RdKGToolMenu.constants.SO_SYNERGY_WARDEN_HEALING = "Afficher graine curative"
RdKGToolMenu.constants.SO_SYNERGY_GRAVE_ROBBER = "Afficher tomber"
RdKGToolMenu.constants.SO_SYNERGY_PURE_AGONY = "Afficher agonie pure"
RdKGToolMenu.constants.SO_SYNERGY_ICY_ESCAPE = "Afficher Évasion glacée"
RdKGToolMenu.constants.SO_SYNERGY_SANGUINE_BURST = "Afficher Détonation sanguine"
RdKGToolMenu.constants.SO_SYNERGY_HEED_THE_CALL = "Afficher Répondez à l'appel"
RdKGToolMenu.constants.SO_SYNERGY_URSUS = "Afficher Bouclier d'Ursus" ---xxx
RdKGToolMenu.constants.SO_SYNERGY_GRYPHON = "Afficher Représailles du griffon" ---xxx
RdKGToolMenu.constants.SO_SYNERGY_RUNEBREAK = "Afficher Brusire de rune" ---xxx
RdKGToolMenu.constants.SO_SYNERGY_PASSAGE = "Réduite Passage" ---xxx
RdKGToolMenu.constants.SO_SYNERGY_RECOVERY = "Réduite Libération de convergence" ---xxx
RdKGToolMenu.constants.SO_REDUCED_SPACING = "Réduite Espacement" ---xxx

--Role Assignment
RdKGToolMenu.constants.RA_HEADER = "|c4592FFRépartition des rôles|r"
RdKGToolMenu.constants.RA_ENABLED = "Activé"
RdKGToolMenu.constants.RA_OVERRIDE_ALLOWED = "Autoriser l'écrasement"
RdKGToolMenu.constants.RA_ROLE = "Rôle du personnage"

--Campaign Joiner
RdKGToolMenu.constants.CAJ_HEADER = "|c4592FFRejoindre automatiquement la campagne|r"
RdKGToolMenu.constants.CAJ_ENABLED = "Activé"

--AvA Messages
RdKGToolMenu.constants.AM_HEADER = "|c4592FFAvA Messages|r"
RdKGToolMenu.constants.AM_PVP_ONLY = "Seulement en PvP"
RdKGToolMenu.constants.AM_CORONATE_EMPEROR = "Messages de couronnement d'empereur"
RdKGToolMenu.constants.AM_DEPOSE_EMPEROR = "Messages de chute d'empereur"
RdKGToolMenu.constants.AM_KEEP_GATE = "Messages de fermeture de portes de forteresses"
RdKGToolMenu.constants.AM_ARTIFACT_CONTROL = "Messages d'artefacts"
RdKGToolMenu.constants.AM_REVENGE_KILL = "Messages de revanches"
RdKGToolMenu.constants.AM_AVENGE_KILL = "Messages de vengeance"
RdKGToolMenu.constants.AM_QUEST_ADDED = "Messages de nouvelles quêtes"
RdKGToolMenu.constants.AM_QUEST_COMPLETE = "Messages de quêtes terminées"
RdKGToolMenu.constants.AM_QUEST_CONDITION_COUNTER_CHANGED = "Messages de compteurs de quêtes"
RdKGToolMenu.constants.AM_QUEST_CONDITION_CHANGED = "Messages de ocnditions de quêtes"
RdKGToolMenu.constants.AM_DAEDRIC_ARTIFACT_OBJECTIVE_SPAWNED_BUT_NOT_REVEALED = "Messages d'apparition d'artefacts daédriques"
RdKGToolMenu.constants.AM_DAEDRIC_ARTIFACT_OBJECTIVE_STATE_CHANGED = "Message dd'état des artéfacts daédriques"

--Push Timer
RdKGToolMenu.constants.PT_HEADER = "|c4592FFPush Timer|r"
RdKGToolMenu.constants.PT_ENABLED = "Activé"
RdKGToolMenu.constants.PT_POSITION_FIXED = "Position fixe"
RdKGToolMenu.constants.PT_PVP_ONLY = "Seulement en PvP"
RdKGToolMenu.constants.PT_FONT_COLOR = "Couleur d'écriture" ---xxx
RdKGToolMenu.constants.PT_LEAD_COLOR = "Couleur Chef" ---xxx
RdKGToolMenu.constants.PT_SHALK_COLOR = "Couleur Fissure" ---xxx
RdKGToolMenu.constants.PT_SOUL_COLOR = "Couleur Soul of Flame" ---xxx
RdKGToolMenu.constants.PT_DETO_COLOR = "Couleur Détonation" ---xxx
RdKGToolMenu.constants.PT_SIZE = "Taille"
RdKGToolMenu.constants.PT_SMOOTH_TRANSITION = "Transition douce"
RdKGToolMenu.constants.PT_LEAD_LINE_COLOR = "Couleur de la ligne de chef" ---xxx
RdKGToolMenu.constants.PT_TIMER_ENABLED = "Fenêtre de minuterie activée" ---xxx
RdKGToolMenu.constants.PT_TIMER_TEXT_ENABLED = "Texte du minuteur activé" ---xxx
RdKGToolMenu.constants.PT_TIMER_SHOW_ALL_ENABLED = "Afficher tout" ---xxx
RdKGToolMenu.constants.PT_OVERVIEW_ENABLED = "Aperçu Minuteur activé" ---xxx
RdKGToolMenu.constants.PT_OVERVIEW_SIZE = "Taille" ---xxx
RdKGToolMenu.constants.PT_OVERVIEW_COLOR = "Couleur" ---xxx
RdKGToolMenu.constants.PT_REACTION_ENABLED = "Réaction du minuteur activée" ---xxx
RdKGToolMenu.constants.PT_REACTION_SIZE = "Taille" ---xxx
RdKGToolMenu.constants.PT_REACTION_COLOR = "Couleur" ---xxx
RdKGToolMenu.constants.PT_REACTION_TEXT = "Afficher le texte" ---xxx
RdKGToolMenu.constants.PT_REACTION_TIME = "Temps d'afficher le texte" ---xxx

--Util
RdKGToolMenu.constants.UTIL_HEADER = "|cFF8174Réglage des outils|r"

--Util Networking
RdKGToolMenu.constants.NET_HEADER = "|c4592FFRéseau|r"
RdKGToolMenu.constants.NET_ENABLED = "Activé"
RdKGToolMenu.constants.NET_URGENT_MODE = "Mode urgent"
RdKGToolMenu.constants.NET_INTERVAL = "Update Interval" ---xxx

--Util Group
RdKGToolMenu.constants.UTIL_GROUP_HEADER = "|c4592FFGroupe|r"
RdKGToolMenu.constants.UTIL_GROUP_DISPLAY_TYPE = "Type d'affichage"

--Util Alliance Color
RdKGToolMenu.constants.AC_HEADER = "|c4592FFCouleurs d'alliance|r"
RdKGToolMenu.constants.AC_DC_COLOR = "Couleur Daguefilante"
RdKGToolMenu.constants.AC_EP_COLOR = "Couleur Pacte"
RdKGToolMenu.constants.AC_AD_COLOR = "Couleur Domaine"
RdKGToolMenu.constants.AC_NO_ALLIANCE_COLOR = "Pas de couleur d'alliances"

--Chat System
RdKGToolMenu.constants.CHAT_HEADER = "|c4592FFSystème de chat|r"
RdKGToolMenu.constants.CHAT_ENABLED = "Activé"
RdKGToolMenu.constants.CHAT_SELECTED_TAB = "Onglet sélectionné"
RdKGToolMenu.constants.CHAT_REFRESH = "Rafraîchir"
RdKGToolMenu.constants.CHAT_WARNINGS_ONLY = "Afficher les alertes"
RdKGToolMenu.constants.CHAT_DEBUG_ONLY = "Afficher les infos de débogage"
RdKGToolMenu.constants.CHAT_NORMAL_ONLY = "Affichage normal"
RdKGToolMenu.constants.CHAT_PREFIX_ENABLED = "Préfixe activé"
RdKGToolMenu.constants.CHAT_RDK_PREFIX_ENABLED = "Préfixe RdK activé"
RdKGToolMenu.constants.CHAT_COLOR_PREFIX = "Couleur de préfixe"
RdKGToolMenu.constants.CHAT_COLOR_BODY = "Couleur de police - texte principal"
RdKGToolMenu.constants.CHAT_COLOR_WARNING = "Couleur d'alerte"
RdKGToolMenu.constants.CHAT_COLOR_DEBUG = "Couleur de débogage"
RdKGToolMenu.constants.CHAT_COLOR_PLAYER = "Couleur de joueur"
RdKGToolMenu.constants.CHAT_ADD_TIMESTAMP = "Ajouter heure"
RdKGToolMenu.constants.CHAT_HIDE_SECONDS = "Masquer les secondes"
RdKGToolMenu.constants.CHAT_COLOR_TIMESTAMP = "Couleur de l'heure"

--Class Role
RdKGToolMenu.constants.CR_HEADER = "|cFF8174Classe / Rôle|r"

--BG Templar Heal
RdKGToolMenu.constants.CRBG_TPHEAL_HEADER = "|c4592FFSoigneur templier (Groupe)|r"
RdKGToolMenu.constants.CRBG_TPHEAL_ENABLED = "Activé"
RdKGToolMenu.constants.CRBG_TPHEAL_PVP_ONLY = "Seulement en PvP"
RdKGToolMenu.constants.CRBG_TPHEAL_POSITION_FIXED = "Position fixe"
RdKGToolMenu.constants.CRBG_TPHEAL_COLOR_PROGRESS_DAMAGE = "Progression des dégâts"
RdKGToolMenu.constants.CRBG_TPHEAL_COLOR_LABEL_DAMAGE = "Etiquette des dégâts"
RdKGToolMenu.constants.CRBG_TPHEAL_COLOR_PROGRESS_HEALING = "Progression des soins"
RdKGToolMenu.constants.CRBG_TPHEAL_COLOR_LABEL_HEALING = "Etiquette des soins"
RdKGToolMenu.constants.CRBG_TPHEAL_COLOR_PROGRESS_RECOVERY = "Progression des récupérations"
RdKGToolMenu.constants.CRBG_TPHEAL_COLOR_LABEL_RECOVERY = "Etiquette des récupérations"
RdKGToolMenu.constants.CRBG_TPHEAL_COLOR_LABEL_COOLDOWN = "Etiquette du temps de recharge"

--AddOn Integration
RdKGToolMenu.constants.ADDON_INTEGRATION_HEADER = "|cFF8174Réglage de l'intégration des add-ons|r"
--Miats Pvp Alerts
RdKGToolMenu.constants.MPAI_HEADER = "|c4592FFMiat Pvp Alerts|r"
RdKGToolMenu.constants.MPAI_ENABLED = "Effacer après login (Activé)"
RdKGToolMenu.constants.MPAI_ONPLAYERACTIVATION = "Effacer après écran de chargement"
RdKGToolMenu.constants.MPAI_CLEAR_VARS = "Effacer les variables"

--Admin
RdKGToolMenu.constants.ADMIN_HEADER = "|cFF8174Réglages administrateur|r"
--Group Share
RdKGToolMenu.constants.ADMIN_GROUP_SHARE_HEADER = "|c4592FFPartage de groupe|r"
RdKGToolMenu.constants.ADMIN_GROUP_SHARE_ENABLED = "Activé"
RdKGToolMenu.constants.ADMIN_GROUP_SHARE_WARNING = "|cFF0000Activer cette fonction permettra à n'importe quel membre de votre guilde disposant du rang 1 à 3 d'appeler les configurations autorisées|r"
RdKGToolMenu.constants.ADMIN_GROUP_SHARE_ALLOW_CLIENT_CONFIGURATION = "Permettre la configuration du client"
RdKGToolMenu.constants.ADMIN_GROUP_SHARE_ALLOW_ADDON_CONFIGURATION = "Permettre la configuration de l'add-on"
RdKGToolMenu.constants.ADMIN_GROUP_SHARE_ALLOW_STATS = "Permettre les stats"
RdKGToolMenu.constants.ADMIN_GROUP_SHARE_ALLOW_SKILLS = "Permettre les compétences"
RdKGToolMenu.constants.ADMIN_GROUP_SHARE_ALLOW_EQUIPMENT = "Permettre l'équipement"
RdKGToolMenu.constants.ADMIN_GROUP_SHARE_ALLOW_CP = "Permettre les points de champion"

--Base
--Couronne
RdKGToolCrown.constants = RdKGToolCrown.constants or {}
RdKGToolCrown.constants.PAPA_CROWN_DETECTED = "Papa Crown détecté. Les réglages de couronne seront ignorés."
RdKGToolCrown.constants.SANCTS_ULTIMATE_ORGANIZER_DETECTED = "Sancts Ultimate Organizer détecté. Les réglages de couronnes seront ignorés."
RdKGToolCrown.constants.CROWN_OF_CYRODIIL_DETECTED = "Crown of Cyrodiil détecté. Les réglages de couronnes seront ignorés."
RdKGToolCrown.config.crowns[1].name = "Couronne: Standard"
RdKGToolCrown.config.crowns[2].name = "Flèche: Blanc"
RdKGToolCrown.config.crowns[3].name = "Flèche: Bleu"
RdKGToolCrown.config.crowns[4].name = "Flèche: Bleu clair"
RdKGToolCrown.config.crowns[5].name = "Flèche: Jaune"
RdKGToolCrown.config.crowns[6].name = "Flèche: Vert clair"
RdKGToolCrown.config.crowns[7].name = "Flèche: Rouge"
RdKGToolCrown.config.crowns[8].name = "Flèche: Rose"
RdKGToolCrown.config.crowns[9].name = "Couronne: Blanc"
RdKGToolCrown.config.crowns[10].name = "RdK: Blanc"

--Auto Invite
RdKGToolAI.constants = RdKGToolAI.constants or {}
RdKGToolAI.constants.AI_MENU_NAME = "Auto Invite"
RdKGToolAI.constants.AI_ENABLED = "Activé"
RdKGToolAI.constants.AI_INVITE_TEXT = "Texte d'invitation"
RdKGToolAI.constants.AI_SENT_INVITE_TO = "Invitation envoyée à|c%s%s|c%s.|r"
RdKGToolAI.constants.AI_NOT_LEADER_SEND_TO = "L'invitation n'a pas été envoyée à|r |c%s%s|c%s. You don't have the crown.|r"
RdKGToolAI.constants.AI_FULL_GROUP = "Aucune invitation n'a été envoyée. Le groupe est déjà complet." ---xxx
RdKGToolAI.constants.AI_REQUIREMENTS_NOT_MET = "L'invitation n'a pas été envoyée à|r |c%s%s |c%s. Critères non remplis.|r"
RdKGToolAI.constants.AI_AUTO_KICK_MESSAGE = "Le membre du groupe|r |c%s%s|r |c%swill sera retiré du groupe.|r"
RdKGToolAI.constants.TOGGLE_AI = "Enclencher Auto Invite"
RdKGToolAI.constants.AI_ENABLED_TRUE = "Auto Invite activé."
RdKGToolAI.constants.AI_ENABLED_FALSE = "Auto Invite désactivé."
RdKGToolAI.constants.AI_MEMBER_LEFT = "Le membre|r |c%s%s|r |c%sa quitté le groupe."

--Follow The Crown Visual
RdKGToolFtcv.textures[1].name = "Flèche 1"
RdKGToolFtcv.textures[2].name = "Flèche 2"
RdKGToolFtcv.textures[3].name = "Flèche 3"
RdKGToolFtcv.textures[4].name = "Flèche 4"
RdKGToolFtcv.textures[5].name = "Flèche 5"
RdKGToolFtcv.textures[6].name = "Flèche 6"
RdKGToolFtcv.textures[7].name = "Flèche 7"
RdKGToolFtcv.textures[8].name = "Flèche 8"

--Follow The Crown Warnings
RdKGToolFtcw.constants = RdKGToolFtcw.constants or {}
RdKGToolFtcw.constants.FTCW_MAX_DISTANCE ="Distance maximale atteinte!!!"

--Resource Overview
RdKGToolOverview.config.ultimateModes = RdKGToolOverview.config.ultimateModes or {}
--RdKGToolOverview.config.ultimateModes[RdKGToolOverview.constants.ultimateModes.ORDER_BY_GROUP] = "Consignes de groupe"
RdKGToolOverview.config.ultimateModes[RdKGToolOverview.constants.ultimateModes.ORDER_BY_READINESS] = "Prêt"
RdKGToolOverview.config.ultimateModes[RdKGToolOverview.constants.ultimateModes.ORDER_BY_NAME] = "Nom"
RdKGToolOverview.constants.BOOM = "BOUM"
RdKGToolOverview.constants.TOGGLE_BOOM = "Envoyer BOUM"
RdKGToolOverview.constants.IDENENTIFIER_DESTRUCTION = "Destro"
RdKGToolOverview.constants.IDENENTIFIER_STORM = "Tempête"
RdKGToolOverview.constants.IDENENTIFIER_NEGATE = "Neg."
RdKGToolOverview.constants.IDENENTIFIER_NOVA = "Nova"
RdKGToolOverview.config.groupsModes = RdKGToolOverview.config.groupsModes or {}
RdKGToolOverview.config.groupsModes[RdKGToolOverview.constants.groupsModes.MODE_PRIORITY_NAME] = "Priorité - Nom"
RdKGToolOverview.config.groupsModes[RdKGToolOverview.constants.groupsModes.MODE_PRIORITY_PERCENT] = "Priorité - Pourcentage"
RdKGToolOverview.config.groupsModes[RdKGToolOverview.constants.groupsModes.MODE_PERCENT] = "Pourcentage"
RdKGToolOverview.config.displayModes = RdKGToolOverview.config.displayModes or {}
RdKGToolOverview.config.displayModes[RdKGToolOverview.constants.displayModes.CLASSIC] = "Classique"
RdKGToolOverview.config.displayModes[RdKGToolOverview.constants.displayModes.SWIMLANES] = "lignes de nage"

--Healing / Damage Meter
RdKGToolHdm.constants = RdKGToolHdm.constants or {}
RdKGToolHdm.constants.TITLE_HEALING = "Soins"
RdKGToolHdm.constants.TITLE_DAMAGE = "Dégâts"
RdKGToolHdm.constants.viewModes = RdKGToolHdm.constants.viewModes or {}
RdKGToolHdm.constants.viewModes[RdKGToolHdm.constants.VIEWMODE_BOTH] = "Les deux"
RdKGToolHdm.constants.viewModes[RdKGToolHdm.constants.VIEWMODE_HEALING] = "Soins"
RdKGToolHdm.constants.viewModes[RdKGToolHdm.constants.VIEWMODE_DAMAGE] = "Dégâts"
RdKGToolHdm.constants.viewModes[RdKGToolHdm.constants.VIEWMODE_BOTH_ON_TOP] = "Les deux (Verticalement)"
RdKGToolHdm.constants.RESET_COUNTER = "Reset Counter" ---xxx

--Detonation Tracker
RdKGToolDt.constants.modes = RdKGToolDt.constants.modes or {}
RdKGToolDt.constants.modes[RdKGToolDt.constants.MODE_ALL] = "Tous"
RdKGToolDt.constants.modes[RdKGToolDt.constants.MODE_DETONATION] = "Détonation"
RdKGToolDt.constants.modes[RdKGToolDt.constants.MODE_SHALK] = "Shalks"
RdKGToolDt.constants.modes[RdKGToolDt.constants.MODE_SOUL_OF_FLAME] = "Soul of Flame"
RdKGToolDt.constants.DT_SOUL_OF_FLAME_TEXT = "Lancer Soul of Flame!"

--I See Dead People
RdKGToolIsdp.constants = RdKGToolIsdp.constants or {}
RdKGToolIsdp.constants.BEAM_SKULL_USING_BUFFER = "Crâne"
RdKGToolIsdp.constants.BEAM_SKULL_NOT_USING_BUFFER = "Crâne (Sans buffer)"

--Compass
--YACS
RdKGToolYacs.compasses[1].name = "Standard"
RdKGToolYacs.compasses[2].name = "Nordique épais"
RdKGToolYacs.compasses[3].name = "Lignes fines"
RdKGToolYacs.compasses[4].name = "Nordique extravagant souligné"
RdKGToolYacs.compasses[5].name = "Nordique épais souligné"
RdKGToolYacs.compasses[6].name = "Gribouillis"
RdKGToolYacs.compasses[7].name = "Cercle 1"
RdKGToolYacs.compasses[8].name = "Cercle 2"
RdKGToolYacs.compasses[9].name = "Diamant 1"
RdKGToolYacs.compasses[10].name = "Diamant 2"
RdKGToolYacs.compasses[11].name = "Points 1"
RdKGToolYacs.compasses[12].name = "Points 2"
RdKGToolYacs.compasses[13].name = "E-Alphabet 1"
RdKGToolYacs.compasses[14].name = "E-Alphabet 2"
RdKGToolYacs.compasses[15].name = "Flèche pleine 1"
RdKGToolYacs.compasses[16].name = "Flèche pleine 2"
RdKGToolYacs.compasses[17].name = "Aiguille 1"
RdKGToolYacs.compasses[18].name = "Aiguille 2"
RdKGToolYacs.compasses[19].name = "Petite flèche 1"
RdKGToolYacs.compasses[20].name = "Petite flèche 2"
RdKGToolYacs.compasses[21].name = "Boussole Fr. 1" 
RdKGToolYacs.compasses[22].name = "Boussole Fr. 2" 
RdKGToolYacs.compasses[23].name = "Boussole Fr. 3" 
RdKGToolYacs.compasses[24].name = "Boussole Fr. 4"
RdKGToolYacs.config.constants.TOGGLE_YACS = "Enclencher la boussole"

--SC
RdKGToolSC.constants = RdKGToolSC.constants or {}
RdKGToolSC.constants.NORTH = "N"
RdKGToolSC.constants.NORTH_EAST = "NE"
RdKGToolSC.constants.EAST = "E"
RdKGToolSC.constants.SOUTH_EAST = "SE"
RdKGToolSC.constants.SOUTH = "S"
RdKGToolSC.constants.SOUTH_WEST = "SO"
RdKGToolSC.constants.WEST = "O"
RdKGToolSC.constants.NORTH_WEST = "NO"

--Toolbox
--Siege Merchant
RdKGToolSm.paymentOptions = RdKGToolSm.paymentOptions or {}
RdKGToolSm.paymentOptions[1] = "Points d'Alliance seulement"
RdKGToolSm.paymentOptions[2] = "Pièces d'or seulement"
RdKGToolSm.paymentOptions[3] = "PA d'abord, puis PO"
RdKGToolSm.paymentOptions[4] = "PO d'abord, puis PA"
RdKGToolSm.constants = RdKGToolSm.constants or {}
RdKGToolSm.constants.ERROR_UNKNOWN = "Une erreur inconnue est survenue."
RdKGToolSm.constants.ERROR_UNKNOWN_PAYMENT_OPTION = "La méthode de paiment choisie est inconnue."
RdKGToolSm.constants.ERROR_PAYMENT_NOT_ENOUGH_GOLD = "Pas assez d'or pour poursuivre les achats."
RdKGToolSm.constants.ERROR_PAYMENT_NOT_ENOUGH_AP = "Pas asez de points d'alliance pour poursuivre les achats."
RdKGToolSm.constants.ERROR_PAYMENT_NOT_ENOUGH_AP_OR_GOLD = "Pas assez de points d'alliance ni d'or pour poursuivre les achats."
RdKGToolSm.constants.ERROR_PAYMENT_NOT_ENOUGH_INVENTORY_SLOTS = "Pas assez d'espace d'inventaire pour poursuivre les achats."
RdKGToolSm.constants.SUCCESS_MESSAGE = "Achat terminé."

--Recharger
RdKGToolRecharger.constants = RdKGToolRecharger.constants or {}
RdKGToolRecharger.constants.MESSAGE_SUCCESS = "%s (%d%%) a été rechargée."
RdKGToolRecharger.constants.MESSAGE_WARNING_LOW_SOULGEMS = "Il reste moins de %d de pierres d'âme."
RdKGToolRecharger.constants.MESSAGE_WARNING_NO_SOULGEMS = "Plus de pierres d'âmes."

--Buff Food Tracking
RdKGToolBft.constants = RdKGToolBft.constants or {}
RdKGToolBft.constants.BUFF_FOOD_STRING = "Nourriture: %s"

--Siege
RdKGToolSiege.constants = RdKGToolSiege.constants or {}
RdKGToolSiege.constants.TOGGLE_SIEGE = "|c4592FFRdK: Modifier la vue|r"

--Cyrodiil Log
RdKGToolCL.constants = RdKGToolCL.constants or {}
RdKGToolCL.constants.MESSAGE_KEEP_GUILD_CLAIM = "%s|c%s a revendiqué %s|c%s for %s"
RdKGToolCL.constants.MESSAGE_KEEP_GUILD_LOST = "%s|c%s a perdu %s"
RdKGToolCL.constants.MESSAGE_KEEP_STATUS_UA = "%s|c%s est assiégé(e)"
RdKGToolCL.constants.MESSAGE_KEEP_STATUS_UA_LOST = "%s|c%s n'est plus assiég(e)"
RdKGToolCL.constants.MESSAGE_KEEP_OWNER_CHANGED = "%s|c%s appartient désormais à %s"
RdKGToolCL.constants.MESSAGE_TICK_DEFENSE = "|c%s%s|t16:16:/esoui/art/currency/alliancepoints.dds|t|c%s points de défense %s"
RdKGToolCL.constants.MESSAGE_TICK_OFFENSE = "|c%s%s|t16:16:/esoui/art/currency/alliancepoints.dds|t|c%s points de capture %s"
RdKGToolCL.constants.MESSAGE_SCROLL_PICKED_UP = "%s|c%s s'est emparé du the %s"
RdKGToolCL.constants.MESSAGE_SCROLL_DROPPED = "%s|c%s a lâché le %s"
RdKGToolCL.constants.MESSAGE_SCROLL_RETURNED = "%s|c%s a replacé le %s"
RdKGToolCL.constants.MESSAGE_SCROLL_RETURNED_BY_TIMER = "%s|c%s a été remis en place"
RdKGToolCL.constants.MESSAGE_SCROLL_CAPTURED = "%s|c%s a capturé %s|c%s at %s"
RdKGToolCL.constants.MESSAGE_EMPEROR_CORONATED = "%s|c%s a été couronné empereur."
RdKGToolCL.constants.MESSAGE_EMPEROR_DEPOSED = "%s|c%s a été révoqué comme empereur."
RdKGToolCL.constants.MESSAGE_QUEST_REWARD = "|c%s%s|t16:16:/esoui/art/currency/alliancepoints.dds|t|c%s gagnés pour la quête."
RdKGToolCL.constants.MESSAGE_BATTLEGROUND_REWARD = "|c%s%s|t16:16:/esoui/art/currency/alliancepoints.dds|t|c%s gagnés pour le champ de bataille."
RdKGToolCL.constants.MESSAGE_BATTLEGROUND_MEDAL_REWARD = "|c%s%s|t16:16:/esoui/art/currency/alliancepoints.dds|t|c%s gagnés pour l'obtention d'une médaille."
RdKGToolCL.constants.MESSAGE_DAEDRIC_ARTIFACT_SPAWNED = "|c%s%s est apparu"
RdKGToolCL.constants.MESSAGE_DAEDRIC_ARTIFACT_REVEALED = "|c%s%s est révélé"
RdKGToolCL.constants.MESSAGE_DAEDRIC_ARTIFACT_DROPPED = "|c%s%s a été lâché par %s|c%s"
RdKGToolCL.constants.MESSAGE_DAEDRIC_ARTIFACT_TAKEN = "|c%s%s a été pris par %s|c%s"
RdKGToolCL.constants.MESSAGE_DAEDRIC_ARTIFACT_DESPAWNED = "|c%s%s est retourné en Oblivion"

--Respawner
RdKGToolRespawner.constants = RdKGToolRespawner.constants or {}
RdKGToolRespawner.constants.KEYBINDING_RESPAWN_CAMP = "Ressusciter au campement."
RdKGToolRespawner.constants.KEYBINDING_RESPAWN_KEEP = "ressusciter au fort"
RdKGToolRespawner.constants.RESPAWN_CAMP = "Campement"
RdKGToolRespawner.constants.RESPAWN_KEEP = "Fort"

--Synergy Prevention
RdKGToolSP.constants = RdKGToolSP.constants or {}
RdKGToolSP.constants.ON = "ON"
RdKGToolSP.constants.OFF = "OFF"
RdKGToolSP.constants.KEYBINDING = "Enclencher la prévention de synergies"
RdKGToolSP.constants.SYNERGY_COMBUSTION = "Combustion"
RdKGToolSP.constants.SYNERGY_HEALING_COMBUSTION = "Combustion curative"
RdKGToolSP.constants.SYNERGY_SHARDS_BLESSED = "Éclats bénis"
RdKGToolSP.constants.SYNERGY_SHARDS_HOLY = "Éclats sacrés"
RdKGToolSP.constants.SYNERGY_BLOOD_FEAST = "Festin sanglant"
RdKGToolSP.constants.SYNERGY_BLOOD_FUNNEL = "Entonnoir de sang"
RdKGToolSP.constants.SYNERGY_SUPERNOVA = "Supernova"
RdKGToolSP.constants.SYNERGY_GRAVITY_CRUSH = "Anéantissement de gravité"
RdKGToolSP.constants.SYNERGY_SHACKLE = "Chaîne"
RdKGToolSP.constants.SYNERGY_PURIFY = "Purification"
RdKGToolSP.constants.SYNERGY_BONE_WALL = "Mur d'os"
RdKGToolSP.constants.SYNERGY_SPINAL_SURGE = "Surcharge élémentaire"
RdKGToolSP.constants.SYNERGY_IGNITE = "Empalement"
RdKGToolSP.constants.SYNERGY_RADIATE = "Faisceau"
RdKGToolSP.constants.SYNERGY_CONDUIT = "Canalisation"
RdKGToolSP.constants.SYNERGY_SPAWN_BROODLINGS = "Nuée de jeunes"
RdKGToolSP.constants.SYNERGY_BLACK_WIDOWS = "Veuve noire"
RdKGToolSP.constants.SYNERGY_ARACHNOPHOBIA = "Arachnophobie"
RdKGToolSP.constants.SYNERGY_HIDDEN_REFRESH = "Rafraîchissement dissimulé"
RdKGToolSP.constants.SYNERGY_SOUL_LEECH = "Absorption d'âme"
RdKGToolSP.constants.SYNERGY_HARVEST = "Graine curative"
RdKGToolSP.constants.SYNERGY_ATRONACH = "Éclair chargé"
RdKGToolSP.constants.SYNERGY_GRAVE_ROBBER = "Tombe"
RdKGToolSP.constants.SYNERGY_PURE_AGONY = "Agonie pure"
RdKGToolSP.constants.SYNERGY_ICY_ESCAPE = "Évasion glacée"
RdKGToolSP.constants.SYNERGY_SANGUINE_BURST = "Détonation sanguine"
RdKGToolSP.constants.SYNERGY_HEED_THE_CALL = "Répondez à l'appel"
RdKGToolSP.constants.SYNERGY_URSUS = "Bouclier d'Ursus"
--RdKGToolSP.constants.blacklist = RdKGToolSP.constants.blacklist or {}
--RdKGToolSP.constants.blacklist[RdKGToolSP.constants.SYNERGY_COMBUSTION] = true
--RdKGToolSP.constants.blacklist[RdKGToolSP.constants.SYNERGY_SUPERNOVA] = true
--RdKGToolSP.constants.blacklist[RdKGToolSP.constants.SYNERGY_GRAVITY_CRUSH] = true
--RdKGToolSP.constants.blacklist[RdKGToolSP.constants.SYNERGY_SHACKLE] = true
--RdKGToolSP.constants.blacklist[RdKGToolSP.constants.SYNERGY_IGNITE] = true
--RdKGToolSP.constants.blacklist[RdKGToolSP.constants.SYNERGY_RADIATE] = true
--RdKGToolSP.constants.blacklist[RdKGToolSP.constants.SYNERGY_CONDUIT] = true
--RdKGToolSP.constants.blacklist[RdKGToolSP.constants.SYNERGY_GRAVE_ROBBER] = true
--RdKGToolSP.constants.blacklist[RdKGToolSP.constants.SYNERGY_PURE_AGONY] = true
RdKGToolSP.constants.MODES = RdKGToolSP.constants.MODES or {}
RdKGToolSP.constants.MODES[RdKGToolSP.constants.MODE_BLOCK_ALL] = "Tous"
RdKGToolSP.constants.MODES[RdKGToolSP.constants.MODE_BLOCK_IF_SYNERGY_ROLE] = "Synergie de rôle"

--Synergy Overview
RdKGToolSO.constants.DISPLAY_MODES = RdKGToolSO.constants.DISPLAY_MODES or {}
RdKGToolSO.constants.DISPLAY_MODES[RdKGToolSO.constants.DISPLAYMODE_ALL] = "Tous"
RdKGToolSO.constants.DISPLAY_MODES[RdKGToolSO.constants.DISPLAYMODE_SYNERGY] = "Synergie de rôle"
RdKGToolSO.constants.TABLE_MODES = RdKGToolSO.constants.TABLE_MODES or {}
RdKGToolSO.constants.TABLE_MODES[RdKGToolSO.constants.MODES.TABLE_FULL] = "Pleine"
RdKGToolSO.constants.TABLE_MODES[RdKGToolSO.constants.MODES.TABLE_REDUCED] = "Réduite"

--util
--util
RdKGToolUtil.constants = RdKGToolUtil.constants or {}
RdKGToolUtil.constants.G1 = "Guilde 1"
RdKGToolUtil.constants.O1 = "Officier 1"
RdKGToolUtil.constants.G2 = "Guilde 2"
RdKGToolUtil.constants.O2 = "Officier 2"
RdKGToolUtil.constants.G3 = "Guilde 3"
RdKGToolUtil.constants.O3 = "Officier 3"
RdKGToolUtil.constants.G4 = "Guilde 4"
RdKGToolUtil.constants.O4 = "Officier 4"
RdKGToolUtil.constants.G5 = "Guilde 5"
RdKGToolUtil.constants.O5 = "Officier 5"
RdKGToolUtil.constants.EMOTE = "Emote"
RdKGToolUtil.constants.SAY = "Dire"
RdKGToolUtil.constants.YELL = "Crier"
RdKGToolUtil.constants.GROUP = "Groupe"
RdKGToolUtil.constants.TELL = "Parler"
RdKGToolUtil.constants.ZONE = "Zone"
RdKGToolUtil.constants.ENZONE = "Zone - Anglais"
RdKGToolUtil.constants.FRZONE = "Zone - Français"
RdKGToolUtil.constants.DEZONE = "Zone - Allemand"
RdKGToolUtil.constants.JPZONE = "Zone - Japonais"

--ui
RdKGToolUtilUI.constants = RdKGToolUtilUI.constants or {}
RdKGToolUtilUI.constants.ON = "MARCHE"
RdKGToolUtilUI.constants.OFF = "ARRÊT"

--Ultimates
RdKGToolUltimates.constants = RdKGToolUltimates.constants or {}
RdKGToolUltimates.constants.NEGATE = "Sorcier - Négation de la magie"
RdKGToolUltimates.constants.NEGATE_OFFENSIVE = "Sorcier - Négation de la magie (offensif)"
RdKGToolUltimates.constants.NEGATE_COUNTER = "Sorcier - Négation de la magie (défensif)"
RdKGToolUltimates.constants.ATRONACH = "Sorcier - Atronach"
RdKGToolUltimates.constants.OVERLOAD = "Sorcier - Surcharge"
RdKGToolUltimates.constants.SWEEP = "Templier - Balayage"
RdKGToolUltimates.constants.NOVA = "Templier - Nova"
RdKGToolUltimates.constants.T_HEAL = "Templier - Ulti de soin"
RdKGToolUltimates.constants.STANDARD = "Chevalier-Dragon - Etendard"
RdKGToolUltimates.constants.LEAP = "Chevalier-Dragon - Bond de dragon"
RdKGToolUltimates.constants.MAGMA = "Chevalier-Dragon - Armure de magma"
RdKGToolUltimates.constants.STROKE = "Lame-Noire - Coup fatal"
RdKGToolUltimates.constants.DARKNESS = "Lame-Noire - Ténèbres dévorantes"
RdKGToolUltimates.constants.SOUL = "Lame-Noire - Lacération d'âmes"
RdKGToolUltimates.constants.SOUL_SIPHON = "Lame-Noire - Siphon d'âmes"
RdKGToolUltimates.constants.SOUL_TETHER = "Lame-Noire - Amarre spirituelle"
RdKGToolUltimates.constants.STORM = "Gardien - Tempête"
RdKGToolUltimates.constants.NORTHERN_STORM = "Gardien - Tempête du nord"
RdKGToolUltimates.constants.PERMAFROST = "Gardien - Permafrost"
RdKGToolUltimates.constants.W_HEAL = "Gardien - Bosquet isolé (soin)"
RdKGToolUltimates.constants.GUARDIAN = "Gardien - Ours gardien"
RdKGToolUltimates.constants.COLOSSUS = "Nécromancien - Colosse de chair"
RdKGToolUltimates.constants.GOLIATH = "Nécromancien - Colosse d'os"
RdKGToolUltimates.constants.REANIMATE = "Nécromancien - Réanimation"
RdKGToolUltimates.constants.UNBLINKING_EYE = "Arcaniste - L'Œil fixe"
RdKGToolUltimates.constants.GIBBERING_SHIELD = "Arcaniste - Bouclier ricanant"
RdKGToolUltimates.constants.VITALIZING_GLYPHIC = "Arcaniste - Glyphique vitalisant"
RdKGToolUltimates.constants.DESTRUCTION = "Arme - Bâton de destruction"
RdKGToolUltimates.constants.RESTORATION = "Arme - Bâton de rétablissement"
RdKGToolUltimates.constants.TWO_HANDED = "Arme - Arme à deux mains"
RdKGToolUltimates.constants.SHIELD = "Arme - Une main et un bouclier"
RdKGToolUltimates.constants.DUAL_WIELD = "Arme - Deux armes"
RdKGToolUltimates.constants.BOW = "Arme - Arc"
RdKGToolUltimates.constants.SOUL_MAGIC = "Monde - Frappe à l'âme"
RdKGToolUltimates.constants.WEREWOLF = "Monde (Loup-garou) - Loup-garou"
RdKGToolUltimates.constants.VAMPIRE = "Monde (Vampire) - Nuée de chauves-souris"
RdKGToolUltimates.constants.MAGES = "Guilde (Mages) - Météore"
RdKGToolUltimates.constants.FIGHTERS = "Guilde (Guerriers) - Aubéclat"
RdKGToolUltimates.constants.PSIJIC = "Guilde (Psijique) - Annulation"
RdKGToolUltimates.constants.ALLIANCE_SUPPORT = "Alliance War (Soutien) - Barrière"
RdKGToolUltimates.constants.ALLIANCE_ASSAULT = "Alliance War (Assaut) - Cor de guerre"

--Networking
RdKGToolNetworking.constants.urgentSelection[RdKGToolNetworking.constants.urgentMode.DIRECT] = "Direct"
RdKGToolNetworking.constants.urgentSelection[RdKGToolNetworking.constants.urgentMode.CRITICAL] = "Queue (Critique)"

--Util Group
RdKGToolUtilGroup.constants.displayTypes[RdKGToolUtilGroup.constants.BY_CHAR_NAME] = "Par nom"
RdKGToolUtilGroup.constants.displayTypes[RdKGToolUtilGroup.constants.BY_DISPLAY_NAME] = "Par @Compte"

RdKGToolUtilGroup.constants.ROLE_RAPID = "Manoeuvre rapide"
RdKGToolUtilGroup.constants.ROLE_PURGE = "Purge"
RdKGToolUtilGroup.constants.ROLE_HEAL = "Soigneur"
RdKGToolUtilGroup.constants.ROLE_DD = "DPS"
RdKGToolUtilGroup.constants.ROLE_SYNERGY = "Synergie"
RdKGToolUtilGroup.constants.ROLE_CC = "Contrôle"
RdKGToolUtilGroup.constants.ROLE_SUPPORT = "Soutien"
RdKGToolUtilGroup.constants.ROLE_PLACEHOLDER = "Indéfini"
RdKGToolUtilGroup.constants.ROLE_APPLICANT = "Candidat"

--Util Versioning
RdKGToolVersioning.constants = RdKGToolVersioning.constants or {}
RdKGToolVersioning.constants.CLIENT_OUT_OF_DATE = "|cFF0000[RdK Group Tool] Le client n'est pas à jour|r"

--Util Enhancements
RdKGToolEnhance.constants = RdKGToolEnhance.constants or {}
RdKGToolEnhance.constants.positionNames = RdKGToolEnhance.constants.positionNames or {}
RdKGToolEnhance.constants.positionNames[RdKGToolEnhance.constants.TOPRIGHT] = "En haut à droite"
RdKGToolEnhance.constants.positionNames[RdKGToolEnhance.constants.BOTTOMRIGHT] = "En bas à droite"
RdKGToolEnhance.constants.positionNames[RdKGToolEnhance.constants.TOPLEFT] = "En haut à gauche"
RdKGToolEnhance.constants.positionNames[RdKGToolEnhance.constants.BOTTOMLEFT] = "En bas à gauche"
RdKGToolEnhance.constants.CAMP_RESPAWN = "Campement : "

--Util Group Menu
RdKGToolGMenu.constants = RdKGToolGMenu.constants or {}
RdKGToolGMenu.constants.BG_LEADER_ADD_CROWN = "Marquer comme couronne"
RdKGToolGMenu.constants.BG_LEADER_REMOVE_CROWN = "Enlever la couronne"
RdKGToolGMenu.constants.ROLE_MENU_ENTRY = "Rôle"
RdKGToolGMenu.constants.ROLE_SUBMENU_SET = "Définir"
RdKGToolGMenu.constants.ROLE_SUBMENU_REMOVE = "Supprimer"
RdKGToolGMenu.constants.ROLE_SUBMENU_RAPID = RdKGToolUtilGroup.constants.ROLE_RAPID
RdKGToolGMenu.constants.ROLE_SUBMENU_PURGE = RdKGToolUtilGroup.constants.ROLE_PURGE
RdKGToolGMenu.constants.ROLE_SUBMENU_HEAL = RdKGToolUtilGroup.constants.ROLE_HEAL
RdKGToolGMenu.constants.ROLE_SUBMENU_DD = RdKGToolUtilGroup.constants.ROLE_DD
RdKGToolGMenu.constants.ROLE_SUBMENU_SYNERGY = RdKGToolUtilGroup.constants.ROLE_SYNERGY
RdKGToolGMenu.constants.ROLE_SUBMENU_CC = RdKGToolUtilGroup.constants.ROLE_CC
RdKGToolGMenu.constants.ROLE_SUBMENU_SUPPORT = RdKGToolUtilGroup.constants.ROLE_SUPPORT
RdKGToolGMenu.constants.ROLE_SUBMENU_PLACEHOLDER = RdKGToolUtilGroup.constants.ROLE_PLACEHOLDER
RdKGToolGMenu.constants.ROLE_SUBMENU_APPLICANT = RdKGToolUtilGroup.constants.ROLE_APPLICANT

--Util Beams
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_1].name = "Faisceau 1"
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_2].name = "Faisceau 2"
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_3].name = "Faisceau 3"
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_4].name = "Faisceau 4"
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_5].name = "Cercle 1"
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_6].name = "Cercle 1 (w/o Buffer)"
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_7].name = "Cercle 2"
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_8].name = "Cercle 2 (w/o Buffer)"
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_9].name = "Flèche 1"
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_10].name = "Flèche 2"

--Admin [General]
RdKGToolAdmin.constants = RdKGToolAdmin.constants or {}
RdKGToolAdmin.constants.TOGGLE_ADMIN = "Utiliser l'interface d'administrateur"
RdKGToolAdmin.constants.HEADER_TITLE = "Administrateur"
RdKGToolAdmin.constants.PLAYERS_ALL = "Tous"
--Admin UI [Player]
RdKGToolAdmin.constants.player = RdKGToolAdmin.constants.player or {}
RdKGToolAdmin.constants.player.REQUEST_ALL = "Requête à tous"
RdKGToolAdmin.constants.player.REQUEST_VERSION = "Requête version"
RdKGToolAdmin.constants.player.REQUEST_CLIENT_CONFIGURATION = "Requête configuration client"
RdKGToolAdmin.constants.player.REQUEST_ADDON_CONFIGURATION = "Requête configuration d'add-on"
RdKGToolAdmin.constants.player.REQUEST_EQUIPMENT_INFORMATION = "Requête information équipement"
RdKGToolAdmin.constants.player.REQUEST_STATS_INFORMATION = "Requête information statistiques"
RdKGToolAdmin.constants.player.REQUEST_MUNDUS_INFORMATION = "Requête information pierre de mundus"
RdKGToolAdmin.constants.player.REQUEST_SKILLS_INFORMATION = "Requête information compétences"
RdKGToolAdmin.constants.player.REQUEST_QUICKSLOTS_INFORMATION = "Requêtes information raccourcis rapides"
RdKGToolAdmin.constants.player.REQUEST_CHAMPION_INFORMATION = "Requête information CP"
--Admin UI [Config]
RdKGToolAdmin.constants = RdKGToolAdmin.constants or {}
RdKGToolAdmin.constants.defaults = RdKGToolAdmin.constants.defaults or {}
RdKGToolAdmin.constants.defaults.ENABLED = "MARCHE"
RdKGToolAdmin.constants.defaults.DISABLED = "Arrêt"
RdKGToolAdmin.constants.defaults.UNDEFINED = "Indisponible"
RdKGToolAdmin.constants.defaults.UNDEFINED_LINE = "-"
RdKGToolAdmin.constants.defaults.UNDEFINED_VERSION = "Indisponible (Version)"
RdKGToolAdmin.constants.defaults.viewModes = RdKGToolAdmin.constants.defaults.viewModes or {}
RdKGToolAdmin.constants.defaults.viewModes[0] = "Fenêtré"
RdKGToolAdmin.constants.defaults.viewModes[1] = "Fenêtré (Plein écran)"
RdKGToolAdmin.constants.defaults.viewModes[2] = "Plein écran"
RdKGToolAdmin.constants.defaults.qualitySelection = RdKGToolAdmin.constants.defaults.qualitySelection or {}
RdKGToolAdmin.constants.defaults.qualitySelection[0] = "Arrêt"
RdKGToolAdmin.constants.defaults.qualitySelection[1] = "Bas"
RdKGToolAdmin.constants.defaults.qualitySelection[2] = "Moyen"
RdKGToolAdmin.constants.defaults.qualitySelection[3] = "Haut"
RdKGToolAdmin.constants.defaults.qualitySelection[4] = "Ultra"
RdKGToolAdmin.constants.defaults.graphicPresets = RdKGToolAdmin.constants.defaults.graphicPresets or {}
RdKGToolAdmin.constants.defaults.graphicPresets[0] = "Minumum"
RdKGToolAdmin.constants.defaults.graphicPresets[1] = "Bas"
RdKGToolAdmin.constants.defaults.graphicPresets[2] = "Moyen"
RdKGToolAdmin.constants.defaults.graphicPresets[3] = "Haut"
RdKGToolAdmin.constants.defaults.graphicPresets[4] = "Ultra"
RdKGToolAdmin.constants.defaults.graphicPresets[7] = "Sur mesure"
RdKGToolAdmin.constants.config = RdKGToolAdmin.constants.config or {}
RdKGToolAdmin.constants.config.PLAYER_TITLE = "Information Joueur"
RdKGToolAdmin.constants.config.PLAYER_DISPLAYNAME_STRING = "Nom affiché: |c%s%s|r"
RdKGToolAdmin.constants.config.PLAYER_CHARNAME_STRING = "Nom du personnage: |c%s%s|r"
RdKGToolAdmin.constants.config.PLAYER_VERSION_STRING = "Version: |c%s%s.%s.%s|r"
RdKGToolAdmin.constants.config.CLIENT_TITLE = "Information client"
RdKGToolAdmin.constants.config.CLIENT_AOE_SUBTITLE = "AOE"
RdKGToolAdmin.constants.config.CLIENT_AOE_TELLS_ENABLED_STRING = "Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_AOE_CUSTOM_COLOR_ENABLED_STRING = "Couleurs sur mesure activées: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_AOE_CUSTOM_COLOR_FRIENDLY_BRIGHTNESS = "Luminosité allié: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_AOE_CUSTOM_COLOR_ENEMY_BRIGHTNESS = "Luminosité ennemi: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_SOUND_SUBTITLE = "Son"
RdKGToolAdmin.constants.config.CLIENT_SOUND_ENABLED_STRING = "Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_SOUND_AUDIO_VOLUME = "Volume audio: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_SFX_AUDIO_VOLUME = "Volume effets: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_UI_AUDIO_VOLUME = "Volume interface: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_SUBTITLE = "Graphismes"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_RESOLUTION_STRING = "Resolution: |c%s%sx%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_WINDOW_MODE_STRING = "Mode d'affichage: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_VSYNC_STRING = "Synchronisation verticale: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_ANTI_ALIASING_STRING = "Anti-Aliasing: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_AMBIENT_STRING = "Occlusion ambiante: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_BLOOM_STRING = "Bloom: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_DEPTH_OF_FIELD_STRING = "Profondeur de champ: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_DISTORTION_STRING = "Distortion: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_SUNLIGHT_STRING = "Rayons de soleil Rays: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_ALLY_EFFECTS_STRING = "Effets supplémentaires alliés: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_VIEW_DISTANCE_STRING = "Distance de vue: ~|c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_PARTICLE_SUPRESSION_DISTANCE_STRING = "Distance de suppression des particules: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_PARTICLE_MAXIMUM_STRING = "Système de particules max: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_REFLECTION_QUALITY_STRING = "Qualité des reflets sur l'eau: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_SHADOW_QUALITY_STRING = "Qualité des ombres: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_SUBSAMPLING_QUALITY_STRING = "Qualité de sous-échantillonnage: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_GRAPHIC_PRESETS_STRING = "Qualité des graphiques: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_TITLE = "Configuration de l'add-on"
RdKGToolAdmin.constants.config.ADDON_CROWN_SUBTITLE = "Couronne"
RdKGToolAdmin.constants.config.ADDON_CROWN_ENABLED_STRING = "Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_CROWN_SIZE_STRING = "Taille: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_CROWN_SELECTED_CROWN_STRING = "Couronne sélectionnée: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCV_SUBTITLE = "Suivre la couronne (Visuel)"
RdKGToolAdmin.constants.config.ADDON_FTCV_ENABLED_STRING = "Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCV_SIZE_FAR_STRING = "Taille (loin): |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCV_SIZE_CLOSE_STRING = "Taille (proche): |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCV_MIN_DISTANCE_STRING = "Distance minimale: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCV_MAX_DISTANCE_STRING = "Distance maximale: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCV_OPACITY_FAR_STRING = "Opacité (loin): |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCV_OPACITY_CLOSE_STRING = "Opacité (proche): |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCW_SUBTITLE = "Suivre la couronne (Alertes)"
RdKGToolAdmin.constants.config.ADDON_FTCW_ENABLED_STRING = "Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCW_DISTANCE_ENABLED_STRING = "Distance activée: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCW_WARNINGS_ENABLED_STRING = "Alertes activées: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCW_MAX_DISTANCE_STRING = "Distance maximale: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCA_SUBTITLE = "Suivre la couronne (Audio)"
RdKGToolAdmin.constants.config.ADDON_FTCA_ENABLED_STRING = "Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCA_MAX_DISTANCE_STRING = "Distance maximale: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCA_INTERVAL_STRING = "Intervalle: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCA_THRESHOLD_STRING = "Seuil: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCB_SUBTITLE = "Suivre la couronne (Faisceau)"
RdKGToolAdmin.constants.config.ADDON_FTCB_ENABLED_STRING = "Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCB_SELECTED_BEAM_STRING = "Faisceau sélectionné: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCB_ALPHA_STRING = "Alpha: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_DBO_SUBTITLE = "Aperçu des débuffs"
RdKGToolAdmin.constants.config.ADDON_DBO_ENABLED_STRING = "Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RT_SUBTITLE = "Aperçu manoeuvre rapide"
RdKGToolAdmin.constants.config.ADDON_RT_ENABLED_STRING = "Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RO_SUBTITLE = "Aperçu des ressources"
RdKGToolAdmin.constants.config.ADDON_RO_ENABLED_STRING = "Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RO_ULTIMATE_OVERVIEW_ENABLED_STRING = "Aperçu des ultis de groupes Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RO_CLIENT_GROUP_ENABLED_STRING = "Client Window Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RO_GROUP_ULTIMATE_ENABLED_STRING = "Fenêtre de groupe activée: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RO_SHOW_SOFT_RESOURCES_STRING = "Stamina / Magicka: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RO_SOUND_ENABLED_STRING = "Son Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RO_MAX_DISTANCE_STRING = "Distance maximale: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RO_GROUP_SIZE_DESTRO_STRING = "Taille de groupe destro: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RO_GROUP_SIZE_STORM_STRING = "Taille de groupe tempête: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RO_GROUP_SIZE_NORTHERNSTORM_STRING = "Taille de groupe Tempête du Nord: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RO_GROUP_SIZE_PERMAFROST_STRING = "Taille de groupe Permafrost: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RO_GROUP_SIZE_NEGATE_STRING = "Taille de groupe négation: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RO_GROUP_SIZE_NEGATE_OFFENSIVE_STRING = "Taille de groupe négation offensive: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RO_GROUP_SIZE_NEGATE_COUNTER_STRING = "Taille de groupe négation défensive: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RO_GROUP_SIZE_NOVA_STRING = "Taille de groupe Nova: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RO_GROUPS_ENABLED_STRING = "Groupes activés: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_HDM_SUBTITLE = "Mesure des dégâts de vie"
RdKGToolAdmin.constants.config.ADDON_HDM_ENABLED_STRING = "Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_HDM_WINDOW_ENABLED_STRING = "Fenêtre Activée: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_HDM_VIEW_MODE_STRING = "Mode sélectionné: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_PO_SUBTITLE = "Aperçu des potions"
RdKGToolAdmin.constants.config.ADDON_PO_ENABLED_STRING = "Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_PO_SOUND_ENABLED_STRING = "Son Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_DT_SUBTITLE = "Suivi détonation"
RdKGToolAdmin.constants.config.ADDON_DT_ENABLED_STRING = "Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_GB_SUBTITLE = "Faiseaux de groupe"
RdKGToolAdmin.constants.config.ADDON_GB_ENABLED_STRING = "Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_ISDP_SUBTITLE = "Je vois les morts"
RdKGToolAdmin.constants.config.ADDON_ISDP_ENABLED_STRING = "Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_YACS_SUBTITLE = "Yet Another Compass"
RdKGToolAdmin.constants.config.ADDON_YACS_ENABLED_STRING = "Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_YACS_PVP_ENABLED_STRING = "Activé en PVP: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_YACS_COMBAT_ENABLED_STRING = "Activé en combat: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_SC_SUBTITLE = "Simple Compass"
RdKGToolAdmin.constants.config.ADDON_SC_ENABLED_STRING = "Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_SM_SUBTITLE = "Marchand d'engins de siège"
RdKGToolAdmin.constants.config.ADDON_SM_ENABLED_STRING = "Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RECHARGER_SUBTITLE = "Recharger"
RdKGToolAdmin.constants.config.ADDON_RECHARGER_ENABLED_STRING = "Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_KC_SUBTITLE = "Revendication de forts"
RdKGToolAdmin.constants.config.ADDON_KC_ENABLED_STRING = "Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_BFT_SUBTITLE = "Suivi des buffs repas"
RdKGToolAdmin.constants.config.ADDON_BFT_ENABLED_STRING = "Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_BFT_SOUND_ENABLED_STRING = "Son Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_BFT_SIZE_STRING = "Size: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_CL_SUBTITLE = "Journal Cyrodiil"
RdKGToolAdmin.constants.config.ADDON_CL_ENABLED_STRING = "Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_CS_SUBTITLE = "Statut Cyrodiil"
RdKGToolAdmin.constants.config.ADDON_CS_ENABLED_STRING = "Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RESPAWNER_SUBTITLE = "Respawner"
RdKGToolAdmin.constants.config.ADDON_RESPAWNER_ENABLED_STRING = "Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_CAMP_SUBTITLE = "Aperçu du campement"
RdKGToolAdmin.constants.config.ADDON_CAMP_ENABLED_STRING = "Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_SP_SUBTITLE = "Prévention des synergies"
RdKGToolAdmin.constants.config.ADDON_SP_ENABLED_STRING = "Aperçu: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_SP_MODE_STRING = "Mode: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_SP_PREVENT_STRING = "%s: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_SO_SUBTITLE = "Aperçu des synergies"
RdKGToolAdmin.constants.config.ADDON_SO_ENABLED_STRING = "Aperçu: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_SO_TABLE_MODE_STRING = "Mode table: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_SO_DISPLAY_MODE_STRING = "Mode d'affichage: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RA_SUBTITLE = "Répartition des rôles"
RdKGToolAdmin.constants.config.ADDON_RA_ENABLED_STRING = "Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RA_ALLOW_OVERRIDE_STRING = "Autoriser l'écrasement: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_CAJ_SUBTITLE = "Rejoindre campagne automatiquement"
RdKGToolAdmin.constants.config.ADDON_CAJ_ENABLED_STRING = "Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_CRBGTP_SUBTITLE = "CR - BG - Templier soigneur (BG)"
RdKGToolAdmin.constants.config.ADDON_CRBGTP_ENABLED_STRING = "Activé: |c%s%s|r"
RdKGToolAdmin.constants.config.STATS_TITLE = "Stats"
RdKGToolAdmin.constants.config.STATS_MAGICKA_STRING = "Magicka: |c%s%s|r"
RdKGToolAdmin.constants.config.STATS_HEALTH_STRING = "Santé: |c%s%s|r"
RdKGToolAdmin.constants.config.STATS_STAMINA_STRING = "Stamina: |c%s%s|r"
RdKGToolAdmin.constants.config.STATS_MAGICKA_RECOVERY_STRING = "Récupération de magie: |c%s%s|r"
RdKGToolAdmin.constants.config.STATS_HEALTH_RECOVERY_STRING = "Récupération de santé: |c%s%s|r"
RdKGToolAdmin.constants.config.STATS_STAMINA_RECOVERY_STRING = "Récupération de stamina: |c%s%s|r"
RdKGToolAdmin.constants.config.STATS_SPELL_DAMAGE_STRING = "Dégâts des sorts: |c%s%s|r"
RdKGToolAdmin.constants.config.STATS_WEAPON_DAMAGE_STRING = "Dégâts des armes: |c%s%s|r"
RdKGToolAdmin.constants.config.STATS_SPELL_PENETRATION_STRING = "Pénétration des sorts: |c%s%s|r"
RdKGToolAdmin.constants.config.STATS_WEAPON_PENETRATION_STRING = "Pénétration des armes: |c%s%s|r"
RdKGToolAdmin.constants.config.STATS_SPELL_CRITICAL_STRING = "Critique de sorts: |c%s%s|r"
RdKGToolAdmin.constants.config.STATS_WEAPON_CRITICAL_STRING = "Critique des armes: |c%s%s|r"
RdKGToolAdmin.constants.config.STATS_SPELL_RESISTANCE_STRING = "Résistance aux sorts: |c%s%s|r"
RdKGToolAdmin.constants.config.STATS_PHYSICAL_RESISTANCE_STRING = "résistance physique: |c%s%s|r"
RdKGToolAdmin.constants.config.STATS_CRITICAL_RESISTANCE_STRING = "Résistance critique: |c%s%s|r"
RdKGToolAdmin.constants.config.MUNDUS_TITLE = "Pierre de Mundus"
RdKGToolAdmin.constants.config.MUNDUS_STONE_1_STRING = "Pierre dde mundus 1: |c%s%s|r"
RdKGToolAdmin.constants.config.MUNDUS_STONE_2_STRING = "Pierre de mundus 2: |c%s%s|r"
RdKGToolAdmin.constants.config.MUNDUS_FILTER = "Bénédiction: "
RdKGToolAdmin.constants.config.CHAMPION_TITLE = "Points de champion"
RdKGToolAdmin.constants.config.SKILLS_TITLE = "Compétences"
RdKGToolAdmin.constants.config.EQUIPMENT_TITLE = "Equipement"
RdKGToolAdmin.constants.config.EQUIPMENT_CONTEXT_REQUEST = "Demander item"
RdKGToolAdmin.constants.config.EQUIPMENT_CONTEXT_LINK_IN_CHAT = "Lien dans le chat"
RdKGToolAdmin.constants.config.QUICKSLOT_TITLE = "Raccourcis rapides"

--Config
RdKGToolConfig.constants = RdKGToolConfig.constants or {}
RdKGToolConfig.constants.TOGGLE_CONFIG = "Choix de configuration de l'interface"
RdKGToolConfig.constants.HEADER_TITLE = "Configuration Import / Export"
RdKGToolConfig.constants.TAB_IMPORT_TITLE = "Import"
RdKGToolConfig.constants.TAB_EXPORT_TITLE = "Export"
RdKGToolConfig.constants.EXPORT_SELECT_ALL = "Tout sélectionner"
RdKGToolConfig.constants.EXPORT_PROFILE = "Profil"
RdKGToolConfig.constants.EXPORT_STRING_LENGTH_ERROR = "Le nom de la configuration est trop long - Merci de rapporter ce bug!"
RdKGToolConfig.constants.IMPORT_PROFILE = "Nom du nouveau profil"
RdKGToolConfig.constants.IMPORT = "Import"
RdKGToolConfig.constants.IMPORT_STATUS = "Statut: "
RdKGToolConfig.constants.IMPORT_ADD_ALL = "Ajouter toutes les valeurs (par ex. la position des fenêtres)"
RdKGToolConfig.constants.IMPORT_STATUS_STARTED = "Import en cours"
RdKGToolConfig.constants.IMPORT_STATUS_FAILED = "Import échoué"
RdKGToolConfig.constants.IMPORT_STATUS_FINISHED = "Import terminé"
RdKGToolConfig.constants.IMPORT_STATUS_FINISHED_DIFFERENT_VERSION = "Import terminé (des versions différentes peuvent causer des problèmes)"
RdKGToolConfig.constants.IMPORT_STATUS_PROFILE_INVALID_NAME = "Echec de l'importation - Nom de profil invalide"
RdKGToolConfig.constants.IMPORT_STATUS_PROFILE_DUPLICATE = "Echec de l'importation - Le nom de profil existe déjà"
RdKGToolConfig.constants.IMPORT_STATUS_NO_CONTENT = "Echec de l'importation - Pas de contenu"
RdKGToolConfig.constants.IMPORT_CONFIG_LINE_COUNT = "Lignes de configuration: %s"
RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON = "Import failed at line %s. Reason: %s"
RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_NIL = "Nil value"
RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_TYPE_BOOLEAN = "Boolean expected"
RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_TYPE_NUMBER = "Number expected"
RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_TYPE_INVALID = "Invalid type"
RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_LAYER_1_INVALID = "Layer1 invalid"
RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_LAYER_2_INVALID = "Layer2 invalid"
RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_LAYER_1_2_INVALID = "Layer1 or Layer2 invalid"
RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_LAYER_X_INVALID = "LayerX invalid"