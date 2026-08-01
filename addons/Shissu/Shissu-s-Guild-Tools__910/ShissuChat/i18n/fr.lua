-- Automatische Generierung
ShissuLocalization = ShissuLocalization or {}

ShissuLocalization["ShissuChat"] = {       
  COLOR                 = "mise en évidence des couleurs",         
  COLOR2                = "Noms des guildes Couleur",                                                
  
  -- Settings
  GENERAL               = "Généralités",
  AUTO                  = "Changement automatique",
  SOUND                 = "Signal acoustique",                                                       
  SOUND_TT              = "Signal acoustique qui est émis lorsque l'on vous chuchote",        
  GUILDS                = "Adhésion à une guilde",
  RANG                  = GetString(SI_GAMEPAD_GUILD_ROSTER_RANK_HEADER),                        
  ALLIANCE              = GetString(SI_LEADERBOARDS_HEADER_ALLIANCE),                            
  LEVEL                 = "Level",                                                               
  WHISPER               = GetString(SI_CHAT_PLAYER_CONTEXT_WHISPER),                       
  PARTY                 = GetString(SI_CHAT_CHANNEL_NAME_PARTY),                                 
  GUILDCHAN             = GetString(SI_CHAT_OPTIONS_GUILD_CHANNELS),
  GUILDINFO             = "Informations sur les guildes",                                               
  GUILDWHICH            = "Sur quelles guildes l'information doit-elle être basée ?",              
  GUILDNAMES_1          = "Nom de la guilde",
  GUILDNAMES_2          = "Comment doivent s'appeler vos guildes dans le chat ?",
  BRACKETS              = "Supprimer les crochets autour des noms",                                              
  BRACKETS_TT           = "Supprime les crochets [] autour des noms des joueurs",                            
  NAME                  = "Nom d'affichage",                                                             
  NAME_2                = "Compte",                                                            
  NAME_3                = "Nom du personnage",                                                           
  NAME_4                = "Nom du personage@Compte",                                                
  WINDOW                = "Fenêtre de chat",                                                               
  HIDETEXT              = "cacher le texte",                                                          
  HIDETEXT_TT           = "Cacher automatiquement le texte du chat",                              
  REGISTER              = "Registre/tabulateur standard",                                                     
  REGISTER_TT           = "Sélection de l'onglet ouvert après la connexion/Reloadui",                             
  CHANNEL               = "Canal standard",                                                                                    
  CHANNEL_TT            = "Détermine quel canal de discussion est automatiquement utilisé en premier après l'enregistrement/la relance.",       
  URL                   = "Rendre les URL/liens cliquables",                                                              
  URL_TT                = "http(s) / www",                                                          
  PARTYSWITCH           = "Changement automatique : Groupe",                                            
  PARTYSWITCH_TT        = "Passe sur le canal de discussion : Groupe, une fois qu'un groupe est formé.",          
  PARTYLEAD             = GetString(SI_GROUP_LEADER_TOOLTIP) .. " de couleur.",               
  WARNINGCOLOR          = "Couleur de surlignage du texte pour les (nouveaux) chats chuchotés",                         
  TIMESTAMP             = "Horodatage",                                                             
  TIMESTAMP_TT          = "Ajoute un horodatage aux messages de chat.",     
  TIMESTAMPNPC          = "Horodatage des PNJ, des monstres",
  TIMESTAMPNPC_TT       = "Il affiche en outre un horodatage pour les SMS des PNJ, les monstres.",
  DATE                  = "Date",                                                                 
  TIME                  = "Heure",                                                                
  TIMESTAMP_FORMAT      = "Format d'horodatage",                                                     
  TIMESTAMP_FORMAT_TT   = "|ceeeeeeFORMAT|r:\n" ..                                                
                          "|cAFD3FFDate|r\n" ..
                          "|cAFD3FFDD|rJournée\n|cAFD3FFD|r: Jour(aucun préfixe 0)\n\|cAFD3FFMM|r: mois\n|cAFD3FFM|r: Mois (pas de 0 précédent)\n|cAFD3FFY|r: Année\n\n" ..
                          "|cAFD3FFHeure\n" ..
                          "|cAFD3FFHH|rheures (24)\n|cAFD3FFhh|r: heures (12)\n|cAFD3FFH|r: Heure (24, pas de 0 précédent)\n|cAFD3FFh|r: heure (12, pas de 0 précédent)\n" ..
                          "|cAFD3FFA|r: AM/PM\n|cAFD3FFa|r: am/pm\n|cAFD3FFm|r: procès-verbal\n|cAFD3FFs|r: secondes",
  USEGUILDCOLORS        = "Utilisez plutôt les couleurs du Chat de la guilde",
  USEGUILDCOLORS_TT     = "Au lieu d'une couleur personnalisée, la couleur du chat de la guilde est utilisée pour la présentation dans le chat [Paramètres -> Social].",
}