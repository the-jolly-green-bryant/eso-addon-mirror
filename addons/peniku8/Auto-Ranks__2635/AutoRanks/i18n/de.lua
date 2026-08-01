local localization =
{	
	-- Translation by @peniku8
  -- Settings menu
    
  -- PresetManager submenu
    AR_STR_NEW_PRESET               = "Neues Preset erstellen",                                                                                                                                                                                                                                                                                                                                               
    AR_STR_NEW_PRESET_TT            = "Speichert die aktuellen Einstellungen unter einem Preset Namen ab",
    AR_STR_NEW_PRESET_ERROR         = "|cFFFFFFGib einen Namen ein, wenn du ein neues Preset erstellen möchtest.",
    AR_STR_RELOADUI_WARNING         = "Wird die Benutzeroberfläche neu laden",
    AR_STR_PRESET_NAME              = "Preset Name:",
    AR_STR_PRESET_NAME_TT           = "Gib den neuen Preset Namen hier ein",
    AR_STR_DELETE_PRESET            = "Aktuelles Preset löschen",
    
  -- Rank submenu
    AR_STR_ENABLED                  = "Aktiviert",
    AR_STR_ENABLED_TT               = "Mitglieder von und zu diesem Rang bewegen",
    AR_STR_NEW_MEMBER               = "Rang für neue Mitglieder",
    AR_STR_NEW_MEMBER_TT            = "Degradiert keine Spieler zurück zu diesem Rang",
    AR_STR_RANK_PERIOD              = "Rang-Zeitfenster",
    AR_STR_RANK_PERIOD_TT           = "Befördert Spieler nach einer bestimmten Anzahl an Tagen von diesem zum nächsten Rang.\nFunktioniert nur, solange 'Rang für neue Mitglieder' und der nächste Rang aktiviert sind.",
    AR_STR_PERMANENT_RANK           = "Permanenter Rang",
    AR_STR_PERMANENT_RANK_TT        = "Degradiert keine Spieler von diesem Rang",
    AR_STR_SALES_REQUIREMENT        = "Verkaufsvoraussetzung",
    AR_STR_SALES_REQUIREMENT_TT     = "Setzt das Minimum an Verkäufen fest, was erreicht werden muss, um Mitglieder diesem Rang zuzuweisen.\nNicht ausgefüllt=Mitglieder werden nur von diesem Rang entfernt\n0=niedrigster Rang für eine Degradierung",
    AR_STR_DONATION_REQUIREMENT     = "Spendenvoraussetzung",
    AR_STR_DONATION_REQUIREMENT_TT  = "Setzt das Minimum an Spenden fest, was erreicht werden muss, um Mitglieder diesem Rang zuzuweisen.\nNicht ausgefüllt=Mitglieder werden nur von diesem Rang entfernt\n0=niedrigster Rang für eine Degradierung",
    AR_STR_MEET_BOTH						    = "Beide nutzen",
    AR_STR_MEET_BOTH_TT 						= "Spieler müssen Verkaufs- *und* Spendenvoraussetzungen erfüllen, um zu diesem Rang befördert zu werden.\nIst diese Option ausgeschaltet, muss nur eine der beiden Voraussetzungen erfüllt werden.",
    
  -- Message submenu
    AR_STR_DESC_1                   = "Der Nachricht können dynamische Ausdrücke hinzugefügt werden:\n#SALES - fügt die Verkäufe des Spielers ein\n#DONATIONS - fügt die Spenden des Spielers ein",
    AR_STR_DESC_2                   = "Die Nachrichteneinstellungen sind nicht von Presets betroffen.\nHinweis: Die Nachrichtenvorschauen werden erst aktualisiert, wenn die Benutzeroberfläche neu geladen wurde.",
    AR_STR_MAIL                     = " mail",
    AR_STR_MAIL_TT_1                = "Sendet eine Nachricht an jeden Spieler, der von ",
    AR_STR_MAIL_TT_2                = "|r zu ",
    AR_STR_MAIL_TT_3                = "|r befördert wurde",
    AR_STR_SUBJECT                  = "Betreff",
    AR_STR_MESSAGE_TEXT             = "Nachrichtentext",
    AR_STR_SEND_DEMOTE_MAIL_TT      = "Sendet eine Nachricht an jeden Spieler, der zu ",
    AR_STR_SEND_DEMOTE_MAIL_TT_2    = "|r degradiert wurde",
    
  -- Advanced submenu
    AR_STR_ADVANCED_SETTINGS        = "Erweiterte Einstellungen",
    AR_STR_NOTE_IMMUNITY            = "Notizimmunität",
    AR_STR_NOTE_IMMUNITY_TT         = "Ignoriert Spieler, falls ein Suchwort in ihrer Notiz gefunden wurde.\nFalls kein Suchwort unten angegeben ist, werden alle Spieler ignoriert, die eine Notiz haben.",
    AR_STR_NOTE_KEY                 = "Notiz-Suchwort",
    AR_STR_DEMOTE_CAP               = "Degradierungungslimit",
    AR_STR_DEMOTE_CAP_TT            = "Legt ein Limit fest, wie viele Ränge ein Mitglied auf einmal degradiert werden kann",
    AR_STR_RESTORE_RANK             = "Rang wiederherstellen",
    AR_STR_RESTORE_RANK_TT          = "Stellt den ursprünglichen Rang eines Spielers wieder her, wenn dieser auf der Liste von Auto Kick gespeicherter Spieler gefunden wird (z.B. ein lifetime member, der nach längerer Inaktivität zurückkehrt)",
    
  -- Main menu
    AR_STR_PROCESS                  = "Gilden verarbeiten",
    AR_STR_PROCESS_TT               = "Startet die Beförderungen/Degradierungen für alle aktivierten Gilden",
    AR_STR_CHAT_NOTIF               = "Chathinweise anzeigen",
    AR_STR_LOAD_PRESET              = "Preset laden",
    AR_STR_LOAD_PRESET_TT           = "Läd ein Einstellungspreset aus dem Dropdownmenü",
    AR_STR_LOAD_PRESET_HINT         = "|cFFFFFFWähle zunächst ein Preset aus, was du laden möchtest.",
    AR_STR_PRESET_MANAGER           = "Preset Manager",
    
  -- Guild menu
    AR_STR_MM_INFO                  = "Der angepasste Zeitraum kann in den Einstellungen von MM eingestellt werden",
    AR_STR_SALES_TIME               = "Verkaufszeitraum",
    AR_STR_CUSTOM_SALES             = "Angepasster Verkaufszeitraum",
    AR_STR_CUSTOM_SALES_TT          = "Nur für ATT. MM's Zeitraum wird in MM's Einstellungen geändert.",
    AR_STR_CUSTOM_DONATIONS         = "Spendenzeitraum",
    AR_STR_TRACK_LAST               = "Letzte Spende miteinbeziehen",
    AR_STR_TRACK_LAST_TT            = "Berechnet einen theoretischen Spendenwert für die aktuelle Woche, um es Mitgliedern zu ermöglichen, für mehrere Wochen im Voraus zu bezahlen",
    AR_STR_TRACK_LAST_TIME          = "Zeitraum für die letzte Spende",
    AR_STR_TRACK_LAST_TIME_TT       = "Zeitraum bis wann die letzte Spende berücksichtigt werden soll",
    AR_STR_RANK_SETTINGS            = "Rangeinstellungen",
    AR_STR_MESSAGE_SETTINGS         = "Nachrichteneinstellungen",
    AR_STR_PROCESS_RANKS            = "Ränge verarbeiten",
    AR_STR_GUILD_ACTIVATE           = "Aktiviert Auto Ranks für ",
    AR_STR_PROMOTIONS_ONLY          = "Nur Beförderungen",
    AR_STR_NOGUILDS                 = "|cff4848Keine passenden Gilden gefunden.",
  
  
  -- Chat notifications and other strings:
    
  -- Time frames
    AR_STR_THIS_WEEK                = "Diese Woche",
    AR_STR_LAST_WEEK                = "Letzte Woche",
    AR_STR_CUSTOM                   = "Angepasst",
    AR_STR_TWO_WEEKS                = "Diese+Letzte Woche",
    AR_STR_ALL                      = "Alles",
    
  -- Chat notifications
    AR_STR_CHAT_PRESET_ACTION       = "|c6C00FFAuto Ranks - |cFFFFFFPreset '",
    AR_STR_CHAT_PRESET_SAVED        = "'|cFFFFFF abgespeichert.",
    AR_STR_CHAT_PRESET_OVERWR       = "'|cFFFFFF überschrieben.",
    AR_STR_CHAT_PRESET_ACTIVE       = "'|cFFFFFF wird bereits verwendet.",
    AR_STR_CHAT_PRESET_LOADED       = "'|cFFFFFF geladen.",
    AR_STR_CHAT_PRESET_DELETED      = "'|cFFFFFF gelöscht.",
    AR_STR_CHAT_RELOADUI            = "|cFFFFFFBenutzeroberfläche neu laden...",
    AR_STR_CHAT_RELOADUI2           = "|cFFFFFFEin Update wurde festgestellt und dieses Preset muss neu initialisiert werden. Benutzeroberfläche neu laden...",
    AR_STR_AR                       = "|c6C00FFAuto Ranks - |cFFFFFF",
    AR_STR_CHAT_DELETE_WARNING      = "|cFFFFFFDu musst ein Preset laden, damit es gelöscht werden kann.",
    AR_STR_CHAT_PROCESSING          = "Verarbeitet ",
    AR_STR_CHAT_AMOUNT_PRESET       = " Rangänderungen auf Preset '",
    AR_STR_CHAT_SINGLE_PRESET       = " Rangänderung auf Preset '",
    AR_STR_CHAT_ZERO_PRESET         = "Nichts zu tun auf Preset '",
    AR_STR_CHAT_RANK_MANY           = " Rangänderungen...",
    AR_STR_CHAT_RANK_ONE            = " Rangänderung...",
    AR_STR_CHAT_NOTHING             = "Nichts zu tun...",
    AR_STR_CHAT_PROMOTED            = " befördert von ",
    AR_STR_CHAT_DEMOTED             = " degradiert von ",
    AR_STR_CHAT_TO                  = "|cFFFFFF zu ",
    AR_STR_CHAT_IN                  = "|cFFFFFF in ",
    AR_STR_CHAT_PM_SENT             = "|c82fa58 - Nachricht gesendet",
    AR_STR_CHAT_DONE                = "FERTIG!",
    AR_STR_CHAT_PM_ALTERT           = "|cFFFFFFLeere Nachrichten können nicht verschickt werden - überprüfe deine Einstellungen.",
    AR_STR_CHAT_MM_ATT_MISSING      = "|c6C00FFAuto Ranks |cFFFFFFbenötigt MM oder ATT!",
    AR_STR_CHAT_AMT_ITT_MISSING     = "|c6C00FFAuto Ranks |cFFFFFFbenötigt AMT oder ITT!",
    AR_STR_CHAT_IGNORE              = " ignoriert dich.",
    AR_STR_CHAT_FULLINBOX           = "'s Mailbox ist voll.",
    AR_STR_CHAT_MAILFAIL            = "Konnte keine Mail senden an: ",
    AR_STR_CHAT_PLAYER              = " Spieler.",
    AR_STR_CHAT_PLAYERS             = " Spieler.",
    AR_STR_CHAT_IGNORELIST          = "|cFFFFFFDie folgenden Spieler ignorieren dich:",
    AR_STR_CHAT_FULLINBOXLIST       = "|cFFFFFFDie folgenden Spieler hatten eine volle Mailbox:",
    AR_STR_CHAT_IDK                 = "|cFFFFFFDie folgenden Spieler konnten wegen eines unerwarteten Fehlers nicht kontaktiert werden:",
    AR_STR_CHAT_WAITMM              = "Bitte warte, bis MM fertig geladen ist...",
    
  -- Other
    AR_STR_KEYBIND                  = "Startet das Verarbeiten der Ränge",
    
}

ZO_ShallowTableCopy(localization, AutoRanks.Localization)