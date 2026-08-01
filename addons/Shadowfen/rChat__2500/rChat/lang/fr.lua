--[[
Author: Ayantir
Filename: fr.lua
Version: 5
]]--

--base language is english, so the file en.lua provides fallback strings.
rChat_localization_strings = rChat_localization_strings  or {}

rChat_localization_strings["fr"] = {
    -- ************************************************
    -- Chat tab selector Bindings
    -- ************************************************
    RCHAT_Tab1 = "Select Chat Tab 1",
    RCHAT_Tab2 = "Select Chat Tab 2",
    RCHAT_Tab3 = "Select Chat Tab 3",
    RCHAT_Tab4 = "Select Chat Tab 4",
    RCHAT_Tab5 = "Select Chat Tab 5",
    RCHAT_Tab6 = "Select Chat Tab 6",
    RCHAT_Tab7 = "Select Chat Tab 7",
    RCHAT_Tab8 = "Select Chat Tab 8",
    RCHAT_Tab9 = "Select Chat Tab 9",
    RCHAT_Tab10 = "Select Chat Tab 10",
    RCHAT_Tab11 = "Select Chat Tab 11",
    RCHAT_Tab12 = "Select Chat Tab 12",

    -- 9.3.6.24 Additions
    RCHAT_RCHAT_CHATTABH = "Chat Tab Settings",
    RCHAT_enableChatTabChannel = "Enable Chat Tab Last Used Channel",
    RCHAT_enableChatTabChannelT = "Enable chat tabs to remember the last used channel, it will become the default until you opt to use a different one in that tab.",
    RCHAT_enableWhisperTab = "Enable Redirect Whisper",
    RCHAT_enableWhisperTabT = "Enable Redirect Whisper to a specific tab.",



-- New Need Translations

    RCHAT_OPTIONSH = "Personnalisation des discussions",

    RCHAT_GUILDNUMBERS = "Numéros de Guilde",
    RCHAT_GUILDNUMBERSTT = "Affiche le numéro de la Guilde à côté de son tag",

    RCHAT_ALLGUILDSSAMECOLOUR = "Même couleur pour toutes les guildes",
    RCHAT_ALLGUILDSSAMECOLOURTT = "Utiliser la couleur de la Guilde 1 pour toutes les guildes",

    RCHAT_ALLZONESSAMECOLOUR = "Même couleur pour toutes les zones",
    RCHAT_ALLZONESSAMECOLOURTT = "Utiliser la couleur de zone pour les canaux de zone localisées",

    RCHAT_ALLNPCSAMECOLOUR = "Même couleurs pour les PNJ",
    RCHAT_ALLNPCSAMECOLOURTT = "Utiliser uniquement la couleur de base pour tous les discours de PNJ",

    RCHAT_DELZONETAGS = "Supprimer les tags de zone",
    RCHAT_DELZONETAGSTT = "Supprime les tags de zone tel que [Parler] ou [Zone] en début de message",

    RCHAT_ZONETAGSAY = "dit",
    RCHAT_ZONETAGYELL = "crie",
    RCHAT_ZONETAGPARTY = "Groupe",
    RCHAT_ZONETAGZONE = "zone",

    RCHAT_CARRIAGERETURN = "Retour à la ligne avant le message",
    RCHAT_CARRIAGERETURNTT = "Ajouter un retour à la ligne entre le nom du joueur et son message",

    RCHAT_USEESOCOLORS = "Utiliser les couleurs ESO",
    RCHAT_USEESOCOLORSTT = "Utiliser les couleurs définies dans les options Sociales",

    RCHAT_DIFFFORESOCOLORS = "Différence entre couleurs ESO",
    RCHAT_DIFFFORESOCOLORSTT = "En utilisant les couleurs ESO et l'option Utiliser plusieurs couleurs, plus la différence sera grande, plus les couleurs tireront sur le clair / sombre",

    RCHAT_REMOVECOLORSFROMMESSAGES = "Désactiver les couleurs dans les canaux",
    RCHAT_REMOVECOLORSFROMMESSAGESTT = "Empêche les joueurs d'utiliser les couleurs dans les messages",

    RCHAT_PREVENTCHATTEXTFADING = "Désactiver la disparition graduelle des messages",
    RCHAT_PREVENTCHATTEXTFADINGTT = "Désactive la disparition graduelle des messages (Vous pouvez désactiver la disparition de l'interface dans les options sociales)",

    RCHAT_AUGMENTHISTORYBUFFER = "Augmenter le # de lignes affichées dans le Chat",
    RCHAT_AUGMENTHISTORYBUFFERTT = "Par défaut, seules les 200 dernières lignes sont affichées dans le Chat. Cette option monte cette valeur à 1000 lignes",

    RCHAT_USEONECOLORFORLINES = "Utiliser une seule couleur",
    RCHAT_USEONECOLORFORLINESTT = "Utiliser uniquement la couleur du joueur à la place des couleurs joueur/message",

    RCHAT_GUILDTAGSNEXTTOENTRYBOX = "Acronyme dans la zone de saisie",
    RCHAT_GUILDTAGSNEXTTOENTRYBOXTT = "Affiche l'acronyme de guilde à la place de son nom dans la zone de saisie",

    RCHAT_DISABLEBRACKETS = "Supprimer les crochets autour des noms",
    RCHAT_DISABLEBRACKETSTT = "Supprime les crochets [] autour des noms de joueur",

    RCHAT_DEFAULTCHANNEL = "Canal par défaut",
    RCHAT_DEFAULTCHANNELTT = "Sélectionner le canal à utiliser à la connexion",

    RCHAT_DEFAULTCHANNELCHOICE99 = "Ne pas modifier",
    RCHAT_DEFAULTCHANNELCHOICE31 = "/zone",
    RCHAT_DEFAULTCHANNELCHOICE0 = "/parler",
    RCHAT_DEFAULTCHANNELCHOICE12 = "/guild1",
    RCHAT_DEFAULTCHANNELCHOICE13 = "/guild2",
    RCHAT_DEFAULTCHANNELCHOICE14 = "/guild3",
    RCHAT_DEFAULTCHANNELCHOICE15 = "/guild4",
    RCHAT_DEFAULTCHANNELCHOICE16 = "/guild5",
    RCHAT_DEFAULTCHANNELCHOICE17 = "/officer1",
    RCHAT_DEFAULTCHANNELCHOICE18 = "/officer2",
    RCHAT_DEFAULTCHANNELCHOICE19 = "/officer3",
    RCHAT_DEFAULTCHANNELCHOICE20 = "/officer4",
    RCHAT_DEFAULTCHANNELCHOICE21 = "/officer5",

    RCHAT_GEOCHANNELSFORMAT = "Format des noms",
    RCHAT_GEOCHANNELSFORMATTT = "Format des noms pour les canaux régionaux (dire, zone, tell)",

    RCHAT_DEFAULTTAB = "Onglet par défaut",
    RCHAT_DEFAULTTABTT = "Sélectionner l'onglet par défaut au lancement du jeu",

    RCHAT_ADDCHANNELANDTARGETTOHISTORY = "Switcher de canal avec l'historique",
    RCHAT_ADDCHANNELANDTARGETTOHISTORYTT = "Switcher de canal automatiquement lors de l'utilisation des flèches haut/bas du clavier pour faire correspondre les messages au canal précédemment utilisé.",

    RCHAT_URLHANDLING = "Détecter et rendre les URL cliquables",
    RCHAT_URLHANDLINGTT = "Si une URL commençant par http(s):// est linkée dans le Chat, rChat la détectera et cliquer sur celle-ci lancera votre navigateur internet sur la page en question",

    RCHAT_ENABLECOPY = "Activer la copie",
    RCHAT_ENABLECOPYTT = "Active la copie du chat par clic droit sur le texte - Active également le changement d'un canal en cliquant sur le message. Vous pouvez désactiver cette option si vous rencontrez des problèmes pour afficher les liens dans le chat",

-- Group Settings

    RCHAT_GROUPH = "Option de canal de groupe",

    RCHAT_ENABLEPARTYSWITCH = "Canal de groupe automatique",
    RCHAT_ENABLEPARTYSWITCHTT = "Activer le canal de groupe automatique changera votre canal à celui du groupe lorsque vous rejoignez un groupe et repasse au canal par défaut lorsque vous quittez un groupe",

    RCHAT_GROUPLEADER = "Couleurs des messages du chef de groupe",
    RCHAT_GROUPLEADERTT = "Activer cette option vous permettra de personnaliser la couleur des message du chef de groupe à celle définie ci-dessous",

    RCHAT_GROUPLEADERCOLOR = "Couleur du chef de groupe",
    RCHAT_GROUPLEADERCOLORTT = "Couleur des messages du chef de groupe. La 2nde couleur à définir n'est utile que si l'option \"Utiliser les couleurs ESO\" est désactivée",

    RCHAT_GROUPLEADERCOLOR1 = "Couleur des messages du chef de groupe",
    RCHAT_GROUPLEADERCOLOR1TT = "Couleur des messages du chef de groupe. Si \"Utiliser les couleurs ESO\" est désactivée cette option sera disponible. La couleur du nom du chef sera celle définie ci-dessus et celle des messages sera celle-ci.",

    RCHAT_GROUPNAMES = "Format des noms pour le groupe",
    RCHAT_GROUPNAMESTT = "Format des noms des membres de votre groupe sur le canal groupe",

    RCHAT_GROUPNAMESCHOICE1 = "@UserID",
    RCHAT_GROUPNAMESCHOICE2 = "Nom du personnage",
    RCHAT_GROUPNAMESCHOICE3 = "Nom du personnage@UserID",
    RCHAT_GROUPNAMESCHOICE4 = "Nom du personnage(@UserID)",

-- Sync settings

    RCHAT_SYNCH = "Synchronisation des paramètres",

    RCHAT_CHATSYNCCONFIG = "Synchroniser les paramètres du chat",
    RCHAT_CHATSYNCCONFIGTT = "Si la synchronisation est activée, tous vos personnages auront la même configuration de chat (couleurs, position, taille de la fenêtre, onglets)\nPS: Activez cette option une fois votre chat correctement configuré !",

    RCHAT_CHATSYNCCONFIGIMPORTFROM = "Importer les paramètres du Chat de",
    RCHAT_CHATSYNCCONFIGIMPORTFROMTT = "Vous pouvez à tout moment importer les paramètres de Chat d'un autre personnage (couleurs, position, taille de la fenêtre, onglets)",

-- Apparence

    RCHAT_APPEARANCEMH = "Apparence de la fenêtre de chat",

    RCHAT_WINDOWDARKNESS = "Transparence de la fenêtre de chat",
    RCHAT_WINDOWDARKNESSTT = "Augmenter l'assombrissement de la fenêtre de chat",

    RCHAT_CHATMINIMIZEDATLAUNCH = "Minimiser le chat au lancement du jeu",
    RCHAT_CHATMINIMIZEDATLAUNCHTT = "Minimiser la fenêtre de chat sur la gauche au lancement du jeu",

    RCHAT_CHATMINIMIZEDINMENUS = "Minimiser le chat dans les menus",
    RCHAT_CHATMINIMIZEDINMENUSTT = "Minimiser la fenêtre de chat sur la gauche lorsque vous entrez dans les menus (Guilde, Stats, Artisanat, etc)",

    RCHAT_CHATMAXIMIZEDAFTERMENUS = "Rétablir le chat en sortant des menus",
    RCHAT_CHATMAXIMIZEDAFTERMENUSTT = "Toujours rétablir la fenêtre de chat après avoir quitté les menus",

    RCHAT_FONTCHANGE = "Police du Chat",
    RCHAT_FONTCHANGETT = "Définir la police du Chat",

    RCHAT_TABWARNING = "Avertissement nouveau message",
    RCHAT_TABWARNINGTT = "Définir la couleur de l'avertissement de nouveau message dans le nom de l'onglet",

-- Whisper settings

    RCHAT_IMH = "Chuchotements",

	RCHAT_WHISPSOUND_ENABLED = "Activer les sons pour les messages chuchotés",
    RCHAT_SOUNDFORINCWHISPS = "Son pour les chuchotements reçus",
    RCHAT_SOUNDFORINCWHISPSTT = "Choisir le son qui sera joué lors des chuchotements reçus",

    RCHAT_NOTIFYIM = "Notifier visuellement",
    RCHAT_NOTIFYIMTT = "Si vous manquez un chuchottement, une notification apparaitra dans le coin supérieur droit du chat vous permettant d'accéder rapidement à celui-ci. De plus si votre chat est minimisé à ce moment, une notification dans la barre réduite apparaîtra",

-- Restore chat settings

    RCHAT_RESTORECHATH = "Restaurer le chat",

    RCHAT_RESTOREONRELOADUI = "Après un ReloadUI",
    RCHAT_RESTOREONRELOADUITT = "Après avoir rechargé le jeu par la commande ReloadUI(), rChat restaurera le chat et son historique",

    RCHAT_RESTOREONLOGOUT = "Après une déconnexion",
    RCHAT_RESTOREONLOGOUTTT = "Après avoir déconnecté son personnage, rChat restaurera le chat et son historique",

    RCHAT_RESTOREONAFK = "Après un éjection du jeu",
    RCHAT_RESTOREONAFKTT = "Après avoir été déconnecté suite à une inactivité, rChat restaurera le chat et son historique si vous vous reconnectez dans le laps de temps défini ci-dessous",

    RCHAT_RESTOREONQUIT = "Après avoir quitté le jeu",
    RCHAT_RESTOREONQUITTT = "Après avoir quitté le jeu, rChat restaurera le chat et son historique",

    RCHAT_TIMEBEFORERESTORE = "Temps maximum pour la restauration du chat",
    RCHAT_TIMEBEFORERESTORETT = "Passé ce délai (en heures), rChat ne tentera pas de restaurer le chat",

    RCHAT_RESTORESYSTEM = "Restaurer les messages système",
    RCHAT_RESTORESYSTEMTT = "Restaurer les msssages système (notifications de connexions et messages d'addon) lorsque le chat est rechargé",

    RCHAT_RESTORESYSTEMONLY = "Restaurer les messages système uniquement",
    RCHAT_RESTORESYSTEMONLYTT = "Restaurer les msssages système uniquement (notifications de connexions et messages d'addon) lorsque le chat est rechargé",

    RCHAT_RESTOREWHISPS = "Restaurer les Chuchotements",
    RCHAT_RESTOREWHISPSTT = "Restaurer les chuchotements reçus et envoyés lors d'un changement de personnage, d'une deconnexion ou après avoir quitté le jeu. Les chuchotements sont toujuors restaurés après un ReloadUI()",

    RCHAT_RESTORETEXTENTRYHISTORYATLOGOUTQUIT = "Restaurer l'historique de saisie",
    RCHAT_RESTORETEXTENTRYHISTORYATLOGOUTQUITTT = "Restaurer l'historique disponible avec les flèches directionelles haut et bas après un changement de personnage, d'une deconnexion ou après avoir quitté le jeu. L'historique est toujours restauré après un ReloadUI()",

-- Anti Spam settings

    RCHAT_ANTISPAMH = "Anti-Spam",

    RCHAT_FLOODPROTECT = "Activer l'anti-flood",
    RCHAT_FLOODPROTECTTT = "Empêche les joueurs proches de vous de vous inonder de messages identiques et répétés",
    RCHAT_FLOODPROTECTDD = "Cette option est désactivée car l'option \"Activer l'anti-flood\" est actuellement désactivée",

    RCHAT_FLOODGRACEPERIOD = "Durée du bannissement anti-flood",
    RCHAT_FLOODGRACEPERIODTT = "Nombre de secondes pendant lesquelles tout message identique au précédent sera ignoré",

    RCHAT_LOOKINGFORPROTECT = "Ignorer les messages de groupage",
    RCHAT_LOOKINGFORPROTECTTT = "Ignorer les messages des joueurs cherchant à constituer / rejoindre un groupe",

    RCHAT_WANTTOPROTECT = "Ignorer les messages de commerce",
    RCHAT_WANTTOPROTECTTT = "Ignorer les messages de joueurs cherchant à acheter, vendre ou échanger",

	RCHAT_GUILDPROTECT = "Ignore Guild Recruiting messages",
	RCHAT_GUILDPROTECTTT = "Ignore messages from players promoting Guild memberships",

    RCHAT_SPAMGRACEPERIOD = "Arrêt temporaire de l'anti-spam",
    RCHAT_SPAMGRACEPERIODTT = "Lorsque vous effectuez vous-même un message de recherche de groupe, ou de commerce, l'anti-spam désactive temporairement la fonction que vous avez outrepassée le temps d'avoir une réponse. Il se réactive automatiquement au bout d'un délai que vous pouvez fixer (en minutes)",

-- Nicknames settings

    RCHAT_NICKNAMESH = "Surnoms",
    RCHAT_NICKNAMESD = "Vous pouvez ajouter des surnoms aux personnes que vous voulez. Saisissez simplement Ancien Nom = Nouveau Nom",

    RCHAT_NICKNAMES = "Liste de surnoms",
    RCHAT_NICKNAMESTT = "Vous pouvez ajouter des surnoms aux personnes que vous voulez. Saisissez simplement Ancien Nom = Nouveau Nom,\n\nEx : @Ayantir = Petite Blonde\n\nCela modifiera tous les noms des personnages de la personne si l'ancien nom est un @UserID ou simpement le personnage indiqué si l'ancien nom est un nom de personnage.",

-- Timestamp settings

    RCHAT_TIMESTAMPH = "Horodatage",

    RCHAT_ENABLETIMESTAMP = "Activer l'horodatage",
    RCHAT_ENABLETIMESTAMPTT = "Ajoute un horodatage aux messages",
    RCHAT_ENABLETIMESTAMPDD = "Cette option est désactivée car l'option \"Activer l'horodatage\" est actuellement désactivée",

    RCHAT_TIMESTAMPCOLORISLCOL = "Même couleur que le nom du joueur",
    RCHAT_TIMESTAMPCOLORISLCOLTT = "Ignore la couleur de l'horodatage et colorie celui-ci de la même couleur que le nom du joueur / NPC",

    RCHAT_TIMESTAMPFORMAT = "Format de l'horodatage",
    RCHAT_TIMESTAMPFORMATTT = "FORMAT:\nHH: 24h\nhh: 12h\nH: 24h, sans les zéros initiaux\nh: 12h, sans les zéros initiaux\nA: AM/PM\na: am/pm\nm: minutes\ns: secondes",

    RCHAT_TIMESTAMP = "Horodatage",
    RCHAT_TIMESTAMPTT = "Définir les couleurs pour l'horodatage",

-- Guild settings

    RCHAT_NICKNAMEFOR = "Acronyme",
    RCHAT_NICKNAMEFORTT = "Acronyme pour",

    RCHAT_OFFICERTAG = "Tag du canal officiers",
    RCHAT_OFFICERTAGTT = "Préfixe ajouté au canal officier des guildes",

    RCHAT_SWITCHFOR = "Commutateur pour le canal",
    RCHAT_SWITCHFORTT = "Nouveau commutateur pour le canal. Ex: /maguilde",

    RCHAT_OFFICERSWITCHFOR = "Commutateur pour le canal officier",
    RCHAT_OFFICERSWITCHFORTT = "Nouveau commutateur pour le canal officier. Ex: /offs",

    RCHAT_NAMEFORMAT = "Format du nom",
    RCHAT_NAMEFORMATTT = "Sélectionnez de quelle manière sont formatés les noms",

    RCHAT_FORMATCHOICE1 = "@UserID",
    RCHAT_FORMATCHOICE2 = "Nom du personnage",
    RCHAT_FORMATCHOICE3 = "Nom du personnage@UserID",
    RCHAT_FORMATCHOICE4 = "Nom du personnage(@UserID)",

    RCHAT_SETCOLORSFORTT = "Définir les couleurs pour les membres de ",
    RCHAT_SETCOLORSFORCHATTT = "Définir les couleurs pour les messages de ",

    RCHAT_SETCOLORSFOROFFICIERSTT = "Définir les couleurs pour les membres du canal Officier de ",
    RCHAT_SETCOLORSFOROFFICIERSCHATTT = "Définir les couleurs pour les messages du canal Officier de ",

    RCHAT_MEMBERS = "<<1>> - Joueurs",
    RCHAT_CHAT = "<<1>> - Messages",

    RCHAT_OFFICERSTT = " Officiers",

-- Channel colors settings

    RCHAT_CHATCOLORSH = "Couleurs des canaux",

    RCHAT_SAY = "Dire - Joueur",
    RCHAT_SAYTT = "Définir la couleur du joueur pour le canal dire",

    RCHAT_SAYCHAT = "Dire - Message",
    RCHAT_SAYCHATTT = "Définir la couleur du message pour le canal dire",

    RCHAT_ZONE = "Zone - Joueur",
    RCHAT_ZONETT = "Définir la couleur du joueur pour le canal zone",

    RCHAT_ZONECHAT = "Zone - Message",
    RCHAT_ZONECHATTT = "Définir la couleur du message pour le canal zone",

    RCHAT_YELL = "Crier - Joueur",
    RCHAT_YELLTT = "Définir la couleur du joueur pour le canal crier",

    RCHAT_YELLCHAT = "Crier - Message",
    RCHAT_YELLCHATTT = "Définir la couleur du message pour le canal crier",

    RCHAT_INCOMINGWHISPERS = "Chuchotements reçus - Joueur",
    RCHAT_INCOMINGWHISPERSTT = "Définir la couleur du joueur pour les messages privés reçus",

    RCHAT_INCOMINGWHISPERSCHAT = "Chuchotements reçus - Message",
    RCHAT_INCOMINGWHISPERSCHATTT = "Définir la couleur du message pour les messages privés reçus",

    RCHAT_OUTGOINGWHISPERS = "Chuchotements envoyés - Joueur",
    RCHAT_OUTGOINGWHISPERSTT = "Définir la couleur du joueur pour les messages privés envoyés",

    RCHAT_OUTGOINGWHISPERSCHAT = "Chuchotements envoyés - Message",
    RCHAT_OUTGOINGWHISPERSCHATTT = "Définir la couleur du message pour les messages privés envoyés",

    RCHAT_GROUP = "Groupe - Joueur",
    RCHAT_GROUPTT = "Définir la couleur du joueur pour le canal groupe",

    RCHAT_GROURCHAT = "Groupe - Message",
    RCHAT_GROURCHATTT = "Définir la couleur du message pour le canal groupe",

-- Other colors

    RCHAT_OTHERCOLORSH = "Autres couleurs",

    RCHAT_EMOTES = "Emotes - Joueur",
    RCHAT_EMOTESTT = "Définir la couleur du joueur pour les emotes",

    RCHAT_EMOTESCHAT = "Emotes - Message",
    RCHAT_EMOTESCHATTT = "Définir la couleur du message pour les emotes",

    RCHAT_ENZONE = "EN Zone - Joueur",
    RCHAT_ENZONETT = "Définir la couleur du joueur pour le canal de zone Anglais",

    RCHAT_ENZONECHAT = "EN Zone - Message",
    RCHAT_ENZONECHATTT = "Définir la couleur du message pour le canal de zone Anglais",

    RCHAT_FRZONE = "FR Zone - Joueur",
    RCHAT_FRZONETT = "Définir la couleur du joueur pour le canal de zone Français",

    RCHAT_FRZONECHAT = "FR Zone - Message",
    RCHAT_FRZONECHATTT = "Définir la couleur du message pour le canal de zone Français",

    RCHAT_DEZONE = "DE Zone - Joueur",
    RCHAT_DEZONETT = "Définir la couleur du joueur couleurs pour le canal de zone Allemand",

    RCHAT_DEZONECHAT = "DE Zone - Message",
    RCHAT_DEZONECHATTT = "Définir la couleur du message pour le canal de zone Allemand",

    RCHAT_JPZONE = "JP Zone - Joueur",
    RCHAT_JPZONETT = "Définir la couleur du joueur couleurs pour le canal de zone Japonais",

    RCHAT_JPZONECHAT = "JP Zone - Message",
    RCHAT_JPZONECHATTT = "Définir la couleur du message pour le canal de zone Japonais",

    RCHAT_RUZONE = "RU Zone - Joueur",
    RCHAT_RUZONETT = "Définir la couleur du joueur couleurs pour le canal de zone Russe",

    RCHAT_RUZONECHAT = "RU Zone - Message",
    RCHAT_RUZONECHATTT = "Définir la couleur du message pour le canal de zone Russe",

    RCHAT_NPCSAY = "Discussions de PNJ - PNJ",
    RCHAT_NPCSAYTT = "Définir la couleur du PNJ pour les discussions de PNJ",

    RCHAT_NPCSAYCHAT = "Discussions de PNJ - Message",
    RCHAT_NPCSAYCHATTT = "Définir la couleur du message pour les discussions de PNJ",

    RCHAT_NPCYELL = "Cris de PNJ - PNJ",
    RCHAT_NPCYELLTT = "Définir la couleur du PNJ pour les cris de PNJ",

    RCHAT_NPCYELLCHAT = "Cris de PNJ - Message",
    RCHAT_NPCYELLCHATTT = "Définir la couleur du message pour les cris de PNJ",

    RCHAT_NPCWHISPER = "Chuchotements de PNJ - PNJ",
    RCHAT_NPCWHISPERTT = "Définir la couleur du PNJ pour les chuchotements de PNJ",

    RCHAT_NPCWHISPERCHAT = "Chuchotements de PNJ - Message",
    RCHAT_NPCWHISPERCHATTT = "Définir la couleur du message pour les chuchotements de PNJ",

    RCHAT_NPCEMOTES = "Emotes de PNJ - PNJ",
    RCHAT_NPCEMOTESTT = "Définir la couleur du PNJ pour les emotes de PNJ",

    RCHAT_NPCEMOTESCHAT = "Emotes de PNJ - Message",
    RCHAT_NPCEMOTESCHATTT = "Définir la couleur du message pour les emotes de PNJ",

-- Various strings not in panel settings

    RCHAT_COPYMESSAGECT = "Copier le message",
    RCHAT_COPYLINECT = "Copier la ligne",
    RCHAT_COPYDISCUSSIONCT = "Copier la discussion",
    RCHAT_ALLCT = "Copier tout le chat",

    RCHAT_COPYXMLTITLE = "Copier le texte avec Ctrl+C",
    RCHAT_COPYXMLLABEL = "Copier le texte avec Ctrl+C",
    RCHAT_COPYXMLTOOLONG = "Le texte est trop long et à été découpé",
    RCHAT_COPYXMLNEXT = "Suivant",

    RCHAT_SWITCHTONEXTTABBINDING = "Passer à l'onglet suivant",
    RCHAT_TOGGLECHATBINDING = "Afficher/Masquer le chat",
    RCHAT_WHISPMYTARGETBINDING = "Chuchotter à la personne ciblée",

    RCHAT_SAVMSGERRALREADYEXISTS = "Impossible de sauvegarder votre message, celui-ci existe déjà",
    RCHAT_RCHAT_AUTOMSG_NAME_DEFAULT_TEXT = "Exemple : ts3",
    RCHAT_RCHAT_AUTOMSG_MESSAGE_DEFAULT_TEXT = "Saisissez ici le texte qui sera envoyé lorsque vous utiliserez la fonction de message automatique",
    RCHAT_RCHAT_AUTOMSG_MESSAGE_TIP1_TEXT = "Les retours à la ligne sont automatiquement supprimés",
    RCHAT_RCHAT_AUTOMSG_MESSAGE_TIP2_TEXT = "Ce message sera envoyé lorsque vous validerez le message \"!nomDuMessage\". (ex: |cFFFFFF!ts3|r)",
    RCHAT_RCHAT_AUTOMSG_MESSAGE_TIP3_TEXT = "Pour envoyer le message dans un canal précis, rajoutez le switch du canal au début du message (ex: |cFFFFFF/g1|r)",
    RCHAT_RCHAT_AUTOMSG_NAME_HEADER = "Abréviation de votre message",
    RCHAT_RCHAT_AUTOMSG_MESSAGE_HEADER = "Message de substitution",
    RCHAT_RCHAT_AUTOMSG_ADD_TITLE_HEADER = "Nouveau message automatique",
    RCHAT_RCHAT_AUTOMSG_EDIT_TITLE_HEADER = "Modifier message automatique",
    RCHAT_RCHAT_AUTOMSG_ADD_AUTO_MSG = "Ajouter",
    RCHAT_RCHAT_AUTOMSG_EDIT_AUTO_MSG = "Modifier",
    RCHAT_SI_BINDING_NAME_RCHAT_SHOW_AUTO_MSG = "Messages automatiques",
    RCHAT_RCHAT_AUTOMSG_REMOVE_AUTO_MSG = "Supprimer",

    RCHAT_CLEARBUFFER = "Effacer le chat",
	RCHAT_CLEARCACHE = "Effacer l'historique du chat",
	RCHAT_CLEARCACHE_TT = "Vider l'historique de chat afin qu'il ne peut pas être restauré avant ce point.",

    RCHAT_MENTION_NM = "Notification de mention",
    RCHAT_MENTION_ENABLED = "Activer la détection des mentions dans le chat",
    RCHAT_MENTIONSTR = "Texte à rechercher dans le chat",
    RCHAT_SOUND_ENABLED = "Activer la notification avec le son",
    RCHAT_SOUND_INDEX = "Quel son jouer",
    RCHAT_COLOR_ENABLED = "Activer la surbrillance avec la couleur",
    RCHAT_MENTIONCOLOR = "Couleur à utiliser pour la mise en évidence",
    RCHAT_SOUND_NAME = "Nom du son actuel",

	RCHAT_DISABLELOGGER = "Désactiver LibDebugLogger blocage de chat",
	RCHAT_DISABLELOGGERTT = "Désactivez le blocage par LibDebugLogger des messages SYSTEM dans le chat.",
}