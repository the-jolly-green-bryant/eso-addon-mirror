ShissuLocalization = ShissuLocalization or {}

ShissuLocalization["ShissuChat"] = {       
  COLOR                 = "farbig hervorheben",         
  COLOR2                = "Gildennamen Farbe",                                                
  
  -- Settings
  AUTO                  = "Automatischer Wechsel",
  SOUND                 = "Akustischer Signalton",                                                       
  SOUND_TT              = "Akustischer Signalton, der abgespielt wird, wenn man angeflüstert wird",        
  GUILDS                = "Gildenzugehörigkeit",
  RANG                  = GetString(SI_GAMEPAD_GUILD_ROSTER_RANK_HEADER),                        
  ALLIANCE              = GetString(SI_LEADERBOARDS_HEADER_ALLIANCE),                            
  LEVEL                 = "Level",                                                               
  WHISPER               = GetString(SI_CHAT_PLAYER_CONTEXT_WHISPER),                       
  PARTY                 = GetString(SI_CHAT_CHANNEL_NAME_PARTY),                                 
  GUILDCHAN             = GetString(SI_CHAT_OPTIONS_GUILD_CHANNELS),
  GUILDINFO             = "Gilden Informationen",                                               
  GUILDWHICH            = "Auf welchen Gilden sollen die Informationen basieren?",              
  GUILDNAMES_1          = "Gildenbezeichnung",
  GUILDNAMES_2          = "Wie sollen Ihre Gilden im Chat lauten?",
  BRACKETS              = "Klammern um Namen entfernen",                                              
  BRACKETS_TT           = "Entfernt Klammern [] um die Namen der Spieler",                            
  NAME                  = "Anzeigename",                                                             
  NAME_2                = "Accountname",                                                            
  NAME_3                = "Charaktername",                                                           
  NAME_4                = "Charaktername@Accountname",                                                
  WINDOW                = "Chatfenster",                                                               
  HIDETEXT              = "Text ausblenden",                                                          
  HIDETEXT_TT           = "Chat-Text automatisch ausblenden lassen",                              
  REGISTER              = "Standard Register/Tab",                                                     
  REGISTER_TT           = "Auswahl des geöffneten Tab nach dem Einloggen/Reloadui",                             
  CHANNEL               = "Standardkanal",                                                                                    
  CHANNEL_TT            = "Bestimmt welcher Chat-Kanal nach der Anmeldung/Reloadui automatisch zuerst verwendet wird.",       
  URL                   = "URLs/Links anklickbar machen",                                                              
  URL_TT                = "http(s) / www",                                                          
  PARTYSWITCH           = "Automatischer Wechsel: Gruppe",                                            
  PARTYSWITCH_TT        = "Wechselt in den Chatkanal: Gruppe, sobald eine Gruppe gebildet.",          
  PARTYLEAD             = GetString(SI_GROUP_LEADER_TOOLTIP) .. " farbig hervorheben.",               
  WARNINGCOLOR          = "Texthervorhebungfarbe für (neue) Flüster-Chats",                         
  TIMESTAMP             = "Zeitstempel",                                                             
  TIMESTAMP_TT          = "Fügt Chat-Nachrichten einen Zeitstempel hinzu.",                        
  DATE                  = "Datum",                                                                 
  TIME                  = "Uhrzeit",                                                                
  TIMESTAMP_FORMAT      = "Zeitstempelformat",                                                     
  TIMESTAMP_FORMAT_TT   = "|ceeeeeeFORMAT|r:\n" ..                                                
                          "|cAFD3FFDDDatum|r\n" ..
                          "|cAFD3FFDD|rTag\n|cAFD3FFD|r: Tag(keine vorangestellte 0)\n\|cAFD3FFMM|r: Monat\n|cAFD3FFM|r: Monat (keine vorangestellte 0)\n|cAFD3FFY|r: Jahr\n\n" ..
                          "|cAFD3FFDDUhrzeit\n" ..
                          "|cAFD3FFHH|rStunden (24)\n|cAFD3FFhh|r: Stunden (12)\n|cAFD3FFH|r: Stunde (24, keine vorangestellte 0)\n|cAFD3FFh|r: Stunde (12, keine vorangestellte 0)\n" ..
                          "|cAFD3FFA|r: AM/PM\n|cAFD3FFa|r: am/pm\n|cAFD3FFm|r: Minuten\n|cAFD3FFs|r: Sekunden",
}