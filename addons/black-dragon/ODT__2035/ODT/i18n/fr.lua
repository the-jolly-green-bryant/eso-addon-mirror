--[[
Author: @blackdragon06
Filename: fr.lua
Version: 2.66
]]--

local strings = {

	-- Général
	submenu_globals	= "Général",
	submenu_ODT_LOCKWINDOWS = "Verrouiller l'emplacement des fenêtres",
	
	-- BackGround
	submenu_background = "Fenêtre de fond (background)",
	submenu_ODT_BG_Show = "Afficher une fenêtre de fond [ODT]",
	submenu_ODT_BGX = "Taille horizontale",
	submenu_ODT_BGY = "Taille verticale",

	-- Hide in combat
	submenu_HideCombat = "Masquer en combat",
	submenu_HideCombat_GLOBAL = "Masquer toutes les fenêtres",
	submenu_HideCombat_BG = "Fenêtre de fond (background)",
	submenu_HideCombat_CLOCK = "Horloge",
	submenu_HideCombat_CHRONO = "Chronomètre",
	submenu_HideCombat_TIMER = "Compte à rebours",
	submenu_HideCombat_PERF = "Performances",
	submenu_HideCombat_INVENTORY = "Inventaire",
	submenu_HideCombat_STATS = "Statistiques armes et armures",
	submenu_HideCombat_HORSE = "Monture",
	submenu_HideCombat_STOLEN = "Vol",
	
	-- Horloge
	submenu_clock = "Horloge",
	submenu_ODT_ShowClock = "Afficher l'horloge",
	submenu_ODT_ShowClockFontSize = "Taille de la police",
	submenu_ODT_ShowClockFontColor = "Couleur de la pocile",
	submenu_ODT_ShowClockBG = "Fond transparent",

	-- Chronomètre
	submenu_chrono = "Chronomètre",
	submenu_ODT_ShowChrono = "Afficher le chronomètre",
	submenu_ODT_ShowChronoFontSize = "Taille de la police",
	submenu_ODT_ShowChronoFontColor = "Couleur de la police",
	submenu_ODT_ShowChronoBG = "Fond transparent",

	-- Timer
	submenu_timer = "Compte à rebours",
	submenu_ODT_ShowTimer = "Afficher le timer",
	submenu_ODT_ShowTimerFontSize = "Taille de la police",
	submenu_ODT_ShowTimerFontColor = "Couleur de la pocile",
	submenu_ODT_ShowTimerBG = "Fond transparent",
	submenu_ODT_Timer_Seconds = "Durée en secondes",
	submenu_ODT_Timer_SOUND = "Son",
	submenu_ODT_Timer_SOUND_TOOLTIP ="Joue un son quand le compte à rebours est terminé",

	-- Performances
	submenu_perf = "performances",
	submenu_ODT_ShowPERF = "Afficher les performances (FPS/PING)",
	submenu_ODT_ShowPERFBG = "Fond transparent",
	
	-- Inventaire
	submenu_inventory = "inventaire",
	submenu_ODT_ShowBag = "Afficher le taux de remplissage de l'inventaire", 
	submenu_ODT_ShowBagBG = "Fond transparent", 
	
	-- Armes & armures
	submenu_WA_STATS = "Statistiques armes et armures",
	submenu_WA_STATS_TOOLTIP = "|cFFFFFFAffiche le % de charge d'enchantement des armes, le % de l'armure et coût de réparation",
	submenu_ODT_WA_ONOFF = "Afficher les statistiques des armes et armure",
	submenu_ODT_WABG = "Fond transparent",
	submenu_ODT_WA_ATX = "Message armure < 10%",
	submenu_ODT_WA_ATX_TOOLTIP = "Afficher un message si une pièce d'armure est à moins de 10%",
	submenu_ODT_WA_SOUND_ARMOR = "Son",
	submenu_ODT_WA_WTX = "Message enchantement < 3%",
	submenu_ODT_WA_WTX_TOOLTIP = "Afficher un message si l'enchantement d'une arme est à moins de 3%",
	submenu_ODT_WA_SOUND_WEAPON = "Son",
	submenu_ODT_WA_Recharge = "Recharge automatique de l'arme",
	submenu_ODT_WA_Recharge_TOOLTIP = "Recharger l'arme automatiquement quand la charge est à 0%",
	weaponcharged = "\na été rechargé(e)",
	nosoulgem = "\pas de pierre d'âme chargée",
	weaponwarning1 = "\nLa charge de l'arme #1 est à moins de 3%",
	weaponwarning2 = "\nLa charge de l'arme #2 est à moins de 3%",
	weaponwarning3 = "\nLa charge de l'arme #3 est à moins de 3%",
	weaponwarning4 = "\nLa charge de l'arme #4 est à moins de 3%",
	armorwarning = "Une pièce d'armure est à moins de 10%",
	
	-- Parchemin d'XP
	submenu_XPScroll = "Parchemin d'expérience",
	submenu_ODT_XPScroll = "Avertir quand le parchemin d'expérience est terminé",
	submenu_ODT_XPScroll_POPDURATION = "Délai d'affichage",
	submenu_ODT_XPScroll_POPDURATION_TOOLTIP = "Délai d'affichage du message (0=la fenêtre ne disparaîtra qu'en cliquant dessus)",
	submenu_ODT_XPScroll_SOUND = "Son",
	XPScroll_timer_msg = "parchemin d'XP terminé ",
	XPScroll_timer_print = " |cE6F702Parchemin d'XP terminé ",
	XPScroll_ended_msg = "parchemin d'Expérience terminé ",


	-- Monture
	submenu_horse = "monture",
	submenu_ODT_HORSE = "Avertir quand l'entraînement est terminé",
	submenu_ODT_HORSE_SHOWPERMA = "Affichage permanent",
	submenu_ODT_HORSE_SHOWPERMA_TOOLTIP = "Affiche en permanence le temps d'entraînement restant",
	submenu_ODT_HORSE_SHOWBG = "Fond transparent",
	submenu_ODT_HORSE_SHOWTIME = "Délai d'affichage",
	submenu_ODT_HORSE_SHOWTIME_TOOLTIP = "Délai d'affichage du message (0=la fenêtre ne disparaîtra qu'en cliquant dessus)",
	submenu_ODT_HORSE_SOUND = "Son",
	submenu_ODT_HORSE_CHECKONLOAD = "Avertir au chargement",
	submenu_ODT_HORSE_CHECKONLOAD_TOOLTIP = "Avertir au démarrage/ReloadUI si la monture doit être entraînée",
	
	
	-- MAILBOX
	submenu_mail = "mail",
	submenu_ODT_MailRTS_ONOFF = "RTS (Return to Sender)",
	submenu_ODT_MailRTS_ONOFF_TOOLTIP =  "|cFFFFFFLes mails reçus dont le sujet est |cF2AE04RTS |cFFFFFFou |cF2AE04rts|cFFFFFF en sujet seront renvoyés automatiquement à l'expéditeur.",
	submenu_ODT_MailRTS_SOUND1 = "Son si un mail est retourné (succès)",
	submenu_ODT_MailRTS_SOUND2 = "Son si un mail n'est pas retourné (échec)",
	btnraz = "|cFFFFFFRemettre à zéro",
	btnerase = "|cFFFFFFEffacer",
	btninserthouseicon = "|cFFFFFFInsérer l'icône maison",
	btninsertraidicon = "|cFFFFFFInsérer l'icône raid",
	btninsertpvpicon = "|cFFFFFFInsérer l'icône PvP",
	btninsertbdgicon = "|cFFFFFFInsérer l'icône banque de guilde",
	btninsertsign = "|cFFFFFFInsérer la signature",
	btnloadsave = "clic gauche pour charger / clic droit pour enregistrer",
	btnsend = "Envoyer",
	mailsenderror = "|cFF6909Mail ODT : |cC80F14mail non envoyé (",
	mailsendsuccess = " envoyés",
	mailrtssender = "|cFF6909ODT RTS : mail retourné à |cEDFF00",
	mailrtsobjects = "|cFF6909  --  Nombre d'objets : |cEDFF00",
	mailrtsnil = "|cFF6909ODT RTS : Mail sans item à supprimer manuellement |cEDFF00",
	mailsenderrorself = "|cFF6909Mail ODT : |cC80F14impossible d'envoyer un mail à soi-même",
	mailsenderrorfull = "|cFF6909Mail ODT : |cC80F14la boîte du destinataire est pleine (",
	mailsenderrorclosed = "|cFF6909Mail ODT : |cC80F14MailBox fermée",

	-- GUILDES : Notifications status membres"
	submenu_guildsnotifications = "GUILDES : Notifs changement status des membres",
	submenu_ODT_GMHeure = "Message : afficher l'heure",
	submenu_ODT_GuildName = "Message : afficher le nom de la guilde",
	submenu_ODT_GMCharacterName = "Message : afficher le nom du personnage",
	submenu_ODT_GMAlliance = "Message : afficher l'alliance du personnage",
	submenu_ODT_GMSound = "Son",
	status_online = " |c04D631s'est connecté(e)",
	status_with = "|cE6F702 avec ",
	status_afk = " |cE6F702- Absent -",
	status_npd = " |cf81e1e- Ne pas déranger -",
	status_offline = " |c848484s'est déconnecté(e)",
	
	-- CHAT Notifications
	submenu_chat_notifications	= "notifications de chat",
	submenu_ODT_Notif_Say = "Dire",
	submenu_ODT_Notif_Yell = "Crier",
	submenu_ODT_Notif_Tell = "Chuchoter",
	submenu_ODT_Notif_Party = "Groupe",
	submenu_ODT_Notif_Z = "Zone",
	submenu_ODT_Notif_ZEN = "Zone : Anglais",
	submenu_ODT_Notif_ZFR = "Zone : Français",
	submenu_ODT_Notif_ZDE = "Zone : Allemand",
	
	-- CHAT Personnalisé
	submenu_customchat	= "Chat personnalisé",
	submenu_ODT_CustomChatPerma = "Affichage permanent de la fenêtre de chat",
	submenu_ODT_CustomChatPerma_TOOLTIP = "|cFFFFFFLe changement de cette valeur nécessite un ReloadUI pour être prise en compte",
	submenu_ODT_CustomChatDate = "Date",
	submenu_ODT_CustomChatTime = "Heure",
	submenu_ODT_CustomChatChan = "Canal",
	submenu_ODT_CustomChatAccount = "@nom du compte",
	submenu_ODT_CustomChatPersoInfos = "Informations personnage",
	submenu_ODT_CustomChatPersoInfos_TOOLTIP = "(uniquement en canal guilde)", 	
	submenu_ODT_CustomChatName = "Nom du personnage",
	submenu_ODT_CustomChatLvl = "Niveau du personnage",
	submenu_ODT_CustomChatAlliance = "Alliance du personnage",
	submenu_ODT_CustomChatClasse = "Classe du personnage",
	CustomChatChan0 = " dire ",
	CustomChatChan1 = " crier ",
	CustomChatChan2 = " chuchoter ",
	CustomChatChan3 = " groupe ",
	CustomChatChan4 = " chuchoter à ",
	CustomChatChan7 = " PNJ ",
	CustomChatChan8 = " PNJ ",
	CustomChatChan9 = " PNJ ",
	CustomChatChan31 = " zone ",
	CustomChatChan32 = " zone EN ",
	CustomChatChan33 = " zone FR ",
	CustomChatChan34 = " zone DE ",
	CustomChatChan35 = " zone JP ",
	
	-- Save Settings
    submenu_ODT_Apply = "Appliquer",
	submenu_ODT_Apply_TOOLTIP = "Applique les changements de paramètres sans reload UI (les changements ne sont pas enregistrés)",
	submenu_ODT_Save = "Enregistrer",
	submenu_ODT_Save_TOOLTIP = "Enregistre les paramètres et effectue un reload UI",

	-- Chronomètre
	chrono_title = "Chronomètre [ODT]",
	chrono_start = "Démarrer le chronomètre",
	chrono_stop = "Arrêter le chronomètre",

	-- Timer
	timer_title = "Timer [ODT]",
	timer_start = "Démarrer le timer",
	timer_stop = "Arrêter le timer",
	timer_ended = "Le compte à rebours est terminé",
	
	-- Horse
	horse_msg_ended = "L'entraînement de la monture est terminé.",
	horse_timer_ended = "terminé ",

	-- Food
	food_timer_msg = " se termine dans ",
	food_timer_print = " |cE6F702se termine dans ",
	food_ended_msg = "aucune nourriture/boisson active",
	submenu_food = "Nourriture",
	submenu_ODT_ShowFOOD = "Avertir quand la nourritre /  boissons se termine",
	submenu_ODT_ShowFOOD_TIME = "Temps en minutes",
	submenu_ODT_ShowFOOD_TIME_TOOLTIP = "Avertir quand le buff va se terminer dans x minutes ...",
	submenu_ODT_ShowFOOD_POPDURATION = "Délai d'affichage",
	submenu_ODT_ShowFOOD_POPDURATION_TOOLTIP = "Délai d'affichage du message (0=la fenêtre ne disparaîtra qu'en cliquant dessus)",
	submenu_ODT_ShowFOOD_SOUND = "Son",
	submenu_ODT_ShowFOOD_CHECKONLOAD = "Avertir au chargement",
	submenu_ODT_ShowFOOD_CHECKONLOAD_TOOLTIP = "Avertir quand il n'y a pas de nourriture / boisson au chargement du personnage / reloadUI",


	-- Fish
	submenu_FISH_Title = "Pêche",
	submenu_ODT_Fish = "Affiche le type d'eau et les appâts",
	fish_ocean = "|c6699ff[Océan]  |cCCFFFF(Vers/Chevesne)",
	fish_river = "|c6699ff[Rivière]  |cCCFFFF(Morceaux d'insectes/Shad)",
	fish_lake = "|c6699ff[Lac]  |cCCFFFF(Boyaux/Méné)",
	fish_foul = "|c6699ff[Marécages]  |cCCFFFF(Rampants/Oeufs de poissons)",

	-- Vol
	submenu_Stolen_Title = "Vol",
	submenu_ODT_Stolen = "Affiche les informations sur le vol",
	submenu_ODT_StolenTOOLTIP = "Argent récolté dans la journée \nMontant des objets volés en inventaire \nNombre d'objets vendus \nNombre d'objets blanchis \nTemps restant",
	submenu_ODT_ShowStolenBG = "Fond transparent", 
	
	-- Annonce des morts
	submenu_ShowDeath_Title = "Annonce des morts",
	submenu_ShowDeath = "Annoncer les morts",
	submenu_ShowDeath_Msg = "Message d'alerte quand un joueur meurt",
	submenu_ShowDeath_Chat = "Message dans le chat",
	submenu_ShowDeath_List = "Afficher la liste des morts", 
	submenu_ShowDeath_rez = "Message de résurrection", 
	submenu_ShowDeath_Snd = "Son", 

	-- Bindings
	lng_SI_BINDING_NAME_ODT_Clock = "Afficher/Masquer l'horloge",
	lng_SI_BINDING_NAME_ODT_Chrono = "Afficher/Masquer le chronomètre",
	lng_SI_BINDING_NAME_ODT_ChronoONOFF = "Démarrer/Arrêter le chronomètre",
	lng_SI_BINDING_NAME_ODT_Timer = "Afficher/Masquer le timer",
	lng_SI_BINDING_NAME_ODT_TimerONOFF = "Démarrer/Arrêter le timer",
	lng_SI_BINDING_NAME_ODT_PERF = "Afficher/Masquer les performances",
	lng_SI_BINDING_NAME_ODT_STATS = "Afficher/Masquer les statistiques armes & armure",
	lng_SI_BINDING_NAME_ODT_RLUI = "|cffff0dReload UI",
	lng_SI_BINDING_NAME_ODT_FREN = "Changer le langage FR/EN",
	lng_SI_BINDING_NAME_ODT_SACK = "|cCCFFFFAnnoncer [Sac lourd]",
	lng_SI_BINDING_NAME_ODT_CHEST = "|cCCFFFFAnnoncer [Coffre]",
	
	-- Divers	
	ODT_notif_officers = " : Officiers",
	closewindow = "|cFFFFFFFermer la fenêtre",
	addonloaded = ") chargé. \n|cEDFF00/odt |cFF6909pour voir les commandes \n|cEDFF00Réglages→Extensions |cFF6909pour régler les paramètres \nCommandes |cFF6909pour les raccourcis",
	dailiesupdated = "|cFF6909addon ODT : |cEDFF00dailies mises à jour en message de guilde.",
	btnchan_officers = "|c94DE23[Orbe du Temps] \n|c00D7FFclic gauche : |cEDFF00Serments des indomptables \n|c00D7FF[maj]+clic gauche : |cFFB04DListe des commandes \n|c00D7FF[CTRL]+clic gauche : |cf81e1eReload UI \n\n|c00D7FFclic centre : |cEDFF00message de recrutement \n|c00D7FF[maj]+clic centre : |cEDFF00message de bienvenue \n\n|c00D7FFclic droit : |cEDFF00Aller en maison de guilde\n|c00D7FF[maj]+clic droit : |cEDFF00Mail de guilde",
	btnchan = "|c94DE23[Orbe du Temps] \n|c00D7FFclic gauche : |cEDFF00Serments des indomptables \n|c00D7FF[maj]+clic gauche : |cFFB04DListe des commandes \n|c00D7FF[CTRL]+clic gauche : |cf81e1eReload UI \n\n|c00D7FFclic droit : |cEDFF00Aller en maison de guilde",
	btnexecute = "|cFFFFFFExécuter la commande",
	btnexecuteoptions = "|cFFFFFFAjoute l'option |c00D7FF-c |cFFFFFFen exécutant une commande ci-dessous",
	savecolors = "Sauvegarde les couleurs du chat configurées sur ce personnage (social)",
	loadcolors = "Charge les couleurs du chat sauvegardées (social)",
	
	cmd_pledges_today = "|cFFB04D• Serments du jour",
	cmd_pledges_before_yesterday = "|cFFB04D• Serments d'avant-hier",
	cmd_pledges_yesterday = "|cFFB04D• Serments d'hier",
	cmd_pledges_tomorrow = "|cFFB04D• Serments de demain",
	cmd_pledges_after_tomorrow = "|cFFB04D• Serments d'après-demain",
	pledges_today = "Serments du jour -> ",
	pledges_before_yesterday = "Serments d'avant-hier -> ",
	pledges_yesterday = "Serments d'hier -> ",
	pledges_tomorrow = "Serments de demain -> ",
	pledges_after_tomorrow = "Serments d'après-demain -> ",
	
}
	
for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end