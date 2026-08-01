if FCOGL == nil then FCOGL = {} end
local FCOGuildLottery = FCOGL

local preFix = "[FCOGL]"

FCOGuildLottery.lang["de"] = {
    --Entries in the search dropdown
    [FCOGL_SEARCHDROP_PREFIX .."1"]             = "Name / Rang",
    [FCOGL_SEARCHDROP_PREFIX .."2"]             = "Datum Beitritt",

    --Entries in the history search dropdown
    [FCOGL_HISTORY_SEARCHDROP_PREFIX .."1"]     = "Name / #",

    --The sort headers
    FCOGL_HEADER_RANK                           = "Rang",
    FCOGL_HEADER_NAME                           = "Verkäufer",
    FCOGL_HEADER_DATE                           = "Datum",
    FCOGL_HEADER_ITEM                           = "Gegenstand",
    FCOGL_HEADER_AMOUNT                         = "Anzahl",
    FCOGL_HEADER_PRICE                          = "Preis",
    FCOGL_HEADER_TAX                            = "Steuer",
    FCOGL_HEADER_INFO                           = "Info",
    FCOGL_HEADER_NO                             = "#",
    FCOGL_HEADER_ROLL                           = "|t28:28:/esoui/art/loot/dice_disabled.dds|t(Wurf)",
    FCOGL_HEADER_MEMBER_NAME                    = "Mitglied Name",
    FCOGL_HEADER_INVITEDBY                      = "Eingeladen durch",
    FCOGL_HEADER_JOINEDINFO                     = "Beitritt am [Noch dabei?/Index]",
    FCOGL_NO_GUILD                              = "-> Keine Gilde <-",

    FCOGL_DICE_TYPE_STRING_RANDOM               = "Zufall",
    FCOGL_DICE_TYPE_STRING_GUILD                = "Gilde \'%s\' Mitglieder Index ",
    FCOGL_DICE_TYPE_STRING_GUILDSALESLOTTERY    = "Gilden \'%s\' Verkaufs-Lotterie Rang ",
    FCOGL_DICE_TYPE_STRING_GUILDMEMBERJOINED    = "Gilden \'%s\' Mitglieder Beitritt Liste ",

    FCOGL_DICE_HISTORY_NORMAL                   = "Normale Würfe Historie",
    FCOGL_DICE_HISTORY_GUILD                    = "Gilden Würfe Historie",

    FCOGL_LASTROLLED_DICE_CHAT_OUTPUT           = "%s Würfel Wurf (W%s) =   %s",
    FCOGL_LASTROLLED_DICE_FOUND_MEMBER_SOLD_CHAT_OUTPUT = ">>Mitglied \'%s\' gefunden auf Rang: %s, Verkaufssumme: %s",
    FCOGL_LASTROLLED_DICE_FOUND_MEMBER_JOINED_CHAT_OUTPUT = ">>Beigetretenes Mitglied \'%s\' gefunden an Position: %s",
    FCOGL_LASTROLLED_DICE_FOUND_MEMBER_CHAT_OUTPUT = ">>Mitglied \'%s\' gefunden",

    FCOGL_DICE_SIDES                            = "# der Würfelseiten",
    FCOGL_START_NEW_GUILD_SALES_LOTTERY         = "Neue Gilden Verkaufs-Lotterie starten",
    FCOGL_ROLL_THE_DICE                         = "Würfel werfen",
    FCOGL_REFRESH                               = "Auffrischen",
    FCOGL_STOP_GUILDSALESLOTTERY                = "Stoppe Gilden Verkaufs-Lotterie",
    FCOGL_SETTINGS                              = "Öffne die Einstellungen",
    FCOGL_CLOSE                                 = "Schließen",
    FCOGL_TOGGLE_DICE_ROLL_HISTORY              = "Zeigen/Verstecken der Würfel Wurf Historie",
    FCOGL_GUILD_SALES_LOTTERY                   = "Gilden Verkaufs-Lotterie",
    FCOGL_GUILD_SALES_LOTTERY_HISTORY           = "Gilden Verkaufs-Lotterie Historie",
    FCOGL_GUILD_MEMBER_JOINED_LIST              = "Gilden Mitglieder Beitritt",
    FCOGL_GUILD_MEMBER_JOINED_LIST_HISTORY      = "Gilden Mitglieder Beitritt Historie",

    FCOGL_START_NEW_GUILD_MEMBER_JOINED_LIST    = "Neue Gilden Mitglieder Beitritts-Liste",
    FCOGL_STOP_GUILD_MEMBER_JOINED_LIST         = "Stoppe Gilden Mitglieder Beitritts-Liste",

    FCOGL_DICE_PREFIX                           = "W",

    FCOGL_CURRENTGUILSALESLOTTERY_TEXT              = "Start: %s / Ende: %s (%s Tage)",
    FCOGL_CURRENTGUILSALESLOTTERY_DICEHISTORY_TEXT  = "Von: %s / -%s Tage",
    FCOGL_GUILDSALESLOTTERY_HISTORY_DROP_TT         = "Wähle eine gespeicherte Gilden Verkaufs-Lotterie Historie.\nDie gewählte Historie wird für neue Würfel Würfe erneut geöffnet.\nEine aktuell aktive Gilden Verkaufs-Lotterie wird dabei gestoppt!!",
    FCOGL_GUILDSALESLOTTERY_DELETE_HISTORY_DROP_TT  = "Wähle gespeicherte Gilden Verkaufs-Lotterie Historien Einträge, welche du löschen möchtest. Klicke danach auf den Löschen Knopf rechts neben dieser Mehrfach-Auswahl Dropdown-Box.",
    FCOGL_GUILDSALESLOTTERY_DELETE_SELECTED         = "Lösche ausgewählte Gilden Verkaufs-Lotterie Historien Einträge",

    FCOGL_GUILDMEMBERSJOINEDDATE_HISTORY_DROP_TT         = "Wähle eine gespeicherte Gilden Mitglieder Beitritts-Liste Historie.\nDie gewählte Historie wird für neue Würfel Würfe erneut geöffnet.\nEine aktuell aktive Gilden Mitglieder Beitritts-Liste wird dabei gestoppt!!",
    FCOGL_GUILDMEMBERSJOINEDDATE_DELETE_HISTORY_DROP_TT  = "Wähle gespeicherte Gilden Mitglieder Beitritts-Liste Historien Einträge, welche du löschen möchtest. Klicke danach auf den Löschen Knopf rechts neben dieser Mehrfach-Auswahl Dropdown-Box.",
    FCOGL_GUILDMEMBERSJOINEDDATE_DELETE_SELECTED         = "Lösche ausgewählte Gilden Mitglieder Beitritts-Liste Historien Einträge",

    FCOGL_DELETE_HISTORY_NONE_SELECTED              = "",
    FCOGL_DELETE_HISTORY_SOME_SELECTED              = "<<1>> gewählt, drücke nun|t24:24:/esoui/art/tutorial/inventory_tabicon_junk_up.dds|t ->",

    FCOGL_RESET_GUILD_SALES_LOTTERY_DIALOG_TITLE    = "Gilden Verkaufs-Lotterie zurücksetzen",
    FCOGL_RESET_GUILD_SALES_LOTTERY_DIALOG_QUESTION = "Willst du die aktive Gilden Verkaufs-Lotterie\nzurücksetzen? Dies startet eine neue Lotterie!",
    FCOGL_STOP_GUILD_SALES_LOTTERY_DIALOG_TITLE     = "Stoppe Gilden Verkaufs-Lotterie",
    FCOGL_STOP_GUILD_SALES_LOTTERY_DIALOG_QUESTION  = "Wilslt du die aktive Gilden Verkaufs-Lotterie stoppen?\nDies ermöglicht wieder Würfel Würfe für die\nausgewählte Gilde.",

    FCOGL_RESET_GUILD_MEMBER_JOINED_LIST_DIALOG_TITLE    = "Gilden Mitglieder Beitritts-Liste zurücksetzen",
    FCOGL_RESET_GUILD_MEMBER_JOINED_LIST_DIALOG_QUESTION = "Willst du die aktive Gilden Mitglieder Beitritts-Liste\n zurücksetzen? Dies startet eine neue Liste!",
    FCOGL_STOP_GUILD_MEMBER_JOINED_LIST_DIALOG_TITLE= "Stoppe Gilden Mitglied Beitritt Liste",
    FCOGL_STOP_GUILD_MEMBER_JOINED_LIST_DIALOG_QUESTION  = "Willst du die aktive Gilden Mitglied Beitritt\n Liste stoppen?\nDies ermöglicht wieder Würfel Würfe für die\nausgewählte Gilde.",

    FCOGL_CLEAR_HISTORY                             = "Leere die angezeigte Historien Liste",
    FCOGL_CLEAR_HISTORY_DIALOG_TITLE                = "Historien Liste leeren?",
    FCOGL_CLEAR_HISTORY_DIALOG_QUESTION             = "Willst du die \'%s\' Historien \nListe leeren? Dies wird alle Einträge löschen!",
    FCOGL_DELETE_HISTORY_ENTRIES_DIALOG_TITLE       = "Lösche ausgewählte Historien Einträge",
    FCOGL_DELETE_HISTORY_ENTRIES_DIALOG_QUESTION    = "Willst du die ausgewählten #\'%s\' Historien\nEinträge/Listen löschen?",

    FCOGL_HISTORY                               = "Normaler Wurf",
    FCOGL_GUILD_HISTORY                         = "Gilden Wurf",
    FCOGL_GUILD_SALES_LOTTERY_HISTORY           = "Gilden Verkaufs-Lotterie Wurf",
    FCOGL_GUILD_MEMBER_JOINED_LIST_HISTORY      = "Gilden Mitglieder Beitritt Wurf",

    FCOGL_CLEARED_HISTORY_COUNT                 = preFix .. " \'%s\' Historien Einträge wurden gelöscht",

    FCOGL_TOGGLE_WINDOW_DRAW_LAYER              = "Verändere die Darstellungsebene (über allen anderen/normal)",

    FCOGL_DELETE_HEADER                         = "Löschen",
    FCOGL_DELETE_ENTRY                          = "Eintrag #%s löschen",

    --LAM settings menu
    --Description
    FCOGL_LAM_DESCRIPTION                       = 'AddOn für Gilden Verkaufs-Lotterien/Mitglieder Beitritt Listen/Mitglieder & normale Würfel Würfe.',
    FCOGL_LAM_HEADER_CHAT_COMMANDS              = 'Chat Kommandos',
    FCOGL_LAM_CHAT_COMMANDS                     = 'Chat Kommandos sind:\n/fcogl   Zeige/Verstecke die Oberfläche.\n'..
            '/fcogls   Öffene das Einstellungsmenü.\n'..
            '/dice <Nummer>   Wirft einen Würfel mit der <number> Anzahl Seiten. Wird die Nummer leer gelassen, so wird die Standard Anzahl aus den Einstellungen verwendet!\n'..
            '/diceG1 - /diceG5  Wirft einen Würfel für die entsprechende Gilde (der bis zu 5 Gilden) mit der Anzahl Seiten = Gilden Mitglieder.\n\n'..
            '/gslnew <GildenIndex 1 bis 5> wird die aktive Gilden Verkaufs-Lottery zurücksetzen und eine neue starten.\n'..
            '/gsl wirft einen Würfel für die aktuelle Gilden Verkaufs-Lotterie.\n'..
            '/gslstop stoppt die aktuelle Gilden Verkaufs-Lotterie.\n\n'..
            '/gmjnew <GildenIndex 1 bis 5> wird die aktive Gilden Mitglieder Beitritts-Liste zurücksetzen und eine neue starten.\n'..
            '/gmj wirft einen Würfel für die aktuelle Gilden Mitglieder Beitritts-Liste.\n'..
            '/gmjstop stoppt die aktuelle Gilden Mitglieder Beitritts-Liste.\n\n'..
            '/gsllast bzw. /gmjlast bzw. /dicelast zeigt das letzte Würfelergebnis im Chat noch einmal an (oder falls akiviert: in der \'DebugLogViewer\' UI).',


    --Headlines
    FCOGL_LAM_FORMAT_OPTIONS                    = "Ausgabe Format",
    FCOGL_LAM_DICE_OPTIONS                      = 'Würfel Einstellungen',
    FCOGL_LAM_GUILD_ROLL_OPTIONS                = 'Gilden Wurf Einstellungen',
    FCOGL_LAM_GUILD_LOTTERY_OPTIONS             = 'Gilden Verkaufs-Lotterie Einstellungen',
    FCOGL_LAM_GUILD_MEMBERS_JOINED_OPTIONS      = 'Gilden Mitglieder Beitritts-Liste Einstellungen',
    FCOGL_LAM_DEBUG_OPTIONS                     = 'Debug',

    FCOGL_LAM_SAVE_TYPE                         = 'Einstellungen - Speicher Modus',
    FCOGL_LAM_SAVE_TYPE_TT                      = 'Nutze Account weite Einstellungen für alle Charaktere, oder speichere die Einstellungen unterschiedliche für jeden Charakter.',
    FCOGL_LAM_SAVE_TYPE_PER_CHARACTER           = 'Jeder Charakter einzeln',
    FCOGL_LAM_SAVE_TYPE_PER_ACCOUNT             = 'Account weit',

    --Options
    FCOGL_LAM_DEFAULT_DICE_SIDES                            = "Standard Würfel Seiten",
    FCOGL_LAM_DEFAULT_DICE_SIDES_TT                         = "Die Standard Anzahl an Würfel Seiten, welche beim \'/dice\' Chat , oder bei der Tastenkombination \'Würfel mit Standard Seiten werfen\'",
    FCOGL_LAM_GUILD_DICE_ROLL_RESULT_TO_CHAT_EDIT           = "Chat Text Box: Würfel Wurf Ergebnis",
    FCOGL_LAM_GUILD_DICE_ROLL_RESULT_TO_CHAT_EDIT_TT        = "Definiere den Text der im Chat angezeigt werden soll, nachdem ein normaler Würfel geworfen wurde.\n\nDu kannst die folgenden Platzhalter verwenden:\n<<1>>   Wurf Ergebnis #\n<<2>>   @AccountName des Gilden Mitglieds (nur wenn es ein Gilden Wurf war).",
    FCOGL_LAM_GUILD_LOTTERY_DICE_ROLL_RESULT_TO_CHAT_EDIT_TT= "Definiere den Text der im Chat angezeigt werden soll, nachdem ein Gilden Verkaufs-Lotterie Wurf gewürfelt wurde, und ein Mitglieds-Name ermittelt wurde.\n\nDu kannst die folgenden Platzhalter verwenden:\n<<1>>   Wurf Ergebnis #\n<<2>>   @AccountName des Verkäufers.",
    FCOGL_LAM_GUILD_MEMBER_JOIN_DATE_DICE_ROLL_RESULT_TO_CHAT_EDIT_TT = "Definiere den Text der im Chat angezeigt werden soll, nachdem ein Gilden Mitglieder Beitritts-Liste Wurf gewürfelt wurde, und ein Mitglieds-Name ermittelt wurde.\n\nDu kannst die folgenden Platzhalter verwenden:\n<<1>>   Wurf Ergebnis #\n<<2>>   @AccountName des beigetretenen Mitglieds.",


    FCOGL_LAM_GUILD_LOTTERY_CUT_OFF_AT_MIDNIGHT     = "Abschneiden um 00:00 des aktuellen Tages",
    FCOGL_LAM_GUILD_LOTTERY_CUT_OFF_AT_MIDNIGHT_TT  = "Um 00:00 am aktuellen Tag abschneiden.\nEs werden keine Gilden-Events von LibHistoire in das Ranking einfließen, die nach 00:00 Uhr liegen!\nIst diese Option deaktiviert (standard Einstellung) verwendet das Ranking (Gilden Lotterie) dieselben Werte wie z.B. Master Merchant: 7 Tage Verkaufs Ranking.",
    FCOGL_LAM_GUILD_LOTTERY_SHOW_UI_ON_DICE_ROLL    = "Zeige die Oberfläche nach Würfel Wurf",
    FCOGL_LAM_GUILD_LOTTERY_SHOW_UI_ON_DICE_ROLL_TT = "Zeige die Oberfläche automatisch an, wenn ein Würfel Wurf per Chat Kommando ausgeführt wurde.\n\nDie Würfel Wurf Historie wird dabei ebenfalls ausgeklappt.\nInfo: Die Würfel Historie wird jedoch nicht den Historientyp ändern (/diceg1 soll z.B. zur Gilde 1 Würfel Wurf Historie wechseln), wenn gerade eine Gilden Verkaufs-Lotterie aktiv ist!!",
    FCOGL_LAM_GUILD_LOTTERY_DAYS_BEFORE             = "Tage rückwärts, von heute an",
    FCOGL_LAM_GUILD_LOTTERY_DAYS_BEFORE_TT          = "Die Anzahl Tage die die Gilden Verkaufs-Lotterie rückwärts lesen soll (von heute an), um das Raking aufzubauen. Der Standard Wert sind 7 Tage.\n\nAchtung: Je mehr Tage hier selektiert werden, desto mehr Gilden Historien Daten müssen gelesen werden. Stelle bitte sicher, dass diese Daten in der Gilden Historie der entsprechenden Gilde ermittelt wurde, prüfe den Gilden Historien Reiter und die \'LibHistoire\' Daten, ob diese aktualisiert und verbunden sind! Ansonsten musst du sehr wahrscheinlich per \'Benutzen\' Taste auf dem Historien Reiter die Daten manuell aktualisieren! Andernfalls erhältst du sehr wahrscheinlich falsche oder gar keine Werte!",
    FCOGL_LAM_GUILD_LOTTERY_DATE_FROM               = "Datum von",
    FCOGL_LAM_GUILD_LOTTERY_DATE_FROM_TT            = "Das Start Datum der Gilden Verkaufs-Lotterie. Der Standard Wert ist heute - 7 Tage (bis Mitternacht).",
    FCOGL_LAM_GUILD_MEMBERS_JOINED_DATE_LIST_DAYS_BEFORE_TT = "Die Anzahl Tage die die Gilden Mitglieder Beitritts-Liste rückwärts lesen soll (von heute an), um das Raking aufzubauen. Der Standard Wert sind 31 Tage.\n\nAchtung: Je mehr Tage hier selektiert werden, desto mehr Gilden Historien Daten müssen gelesen werden. Stelle bitte sicher, dass diese Daten in der Gilden Historie der entsprechenden Gilde ermittelt wurde, prüfe den Gilden Historien Reiter und die \'LibHistoire\' Daten, ob diese aktualisiert und verbunden sind! Ansonsten musst du sehr wahrscheinlich per \'Benutzen\' Taste auf dem Historien Reiter die Daten manuell aktualisieren! Andernfalls erhältst du sehr wahrscheinlich falsche oder gar keine Werte!",

    FCOGL_LAM_GUILD_MEMBERS_JOINED_DATE_LIST_SHOW_UI_ON_DICE_ROLL_TT = "Zeige die Oberfläche automatisch an, wenn ein Würfel Wurf per Chat Kommando ausgeführt wurde.\n\nDie Würfel Wurf Historie wird dabei ebenfalls ausgeklappt.\nInfo: Die Würfel Historie wird jedoch nicht den Historientyp ändern (/diceg1 soll z.B. zur Gilde 1 Würfel Wurf Historie wechseln), wenn gerade eine Gilden Mitglieder Beitritts-Liste aktiv ist!!",
    FCOGL_LAM_GUILD_MEMBERS_JOINED_DATE_LIST_FILTER_ALREADY_LEFT = "Verstecke ausgetretene Mitglieder",
    FCOGL_LAM_GUILD_MEMBERS_JOINED_DATE_LIST_FILTER_ALREADY_LEFT_TT = "Verstecke/Filtere die Mitglieder welche bereits wieder aus der Gilde ausgetreten sind",


    FCOGL_LAM_USE_24h_FORMAT                    = "Nutze 24 Stunden Format",
    FCOGL_LAM_USE_24h_FORMAT_TT                 = "Nutze das 24 Stunden Format für Datum und Uhrzeit",
    FCOGL_LAM_USE_CUSTOM_DATETIME_FORMAT        = "Eigenes Datum & Zeit Format",
    FCOGL_LAM_USE_CUSTOM_DATETIME_FORMAT_TT     = "Spezifiziere dein eigenes Datum & Zeit Format.\nLAsse das Editfeld leer, um das Standard Format zu verwenden.\nDie möglichen Platzhalter sind in der lua Sprache bereits vordefiniert wie folgt:\n\n%a	abbreviated weekday name (e.g., Wed)\n%A	full weekday name (e.g., Wednesday)\n%b	abbreviated month name (e.g., Sep)\n%B	full month name (e.g., September)\n%c	date and time (e.g., 09/16/98 23:48:10)\n%d	day of the month (16) [01-31]\n%H	hour, using a 24-hour clock (23) [00-23]\n%I	hour, using a 12-hour clock (11) [01-12]\n%M	minute (48) [00-59]\n%m	month (09) [01-12]\n%p	either \"am\" or \"pm\" (pm)\n%S	second (10) [00-61]\n%w	weekday (3) [0-6 = Sunday-Saturday]\n%x	date (e.g., 09/16/98)\n%X	time (e.g., 23:48:10)\n%Y	full year (1998)\n%y	two-digit year (98) [00-99]\n%%	the character `%´",

    FCOGL_LAM_CLEAR_SAVEDVARIABLES_OPTIONS          = "SavedVariables bereinigen",
    FCOGL_LAM_CLEAR_SAVEDVARIABLES_DAYS_BEFORE      = "'Tage rückwärts' auswählen",
    FCOGL_LAM_CLEAR_SAVEDVARIABLES_DAYS_BEFORE_TT   = "Wähle die bereits gespeicherten 'Tage rückwärts' aus, welche du löschen möchtest.\n\nDu kannst hier auch einfach nachgucken welche Tage schon einmal zuvor gespeichert wurden und dann entsprechend den Schieberegler wieder auf diese Tage-Einstellung verändern und die Benutzeroberfläche neuladen. Danach kannst du in der FCOGuildLottery Historien Oberfläche die gespeicherten Daten einsehen und einzelne Datensätze, oder die gesamten gespeicherten Daten zu dieser Tage-Einstellung, über die Knöpfe oder Kontextmenüs der Historien UI löschen.",
    FCOGL_LAM_CLEAR_SAVEDVARIABLES_DELETE      = "Löschen",
    FCOGL_LAM_CLEAR_SAVEDVARIABLES_DELETE_TT   = "Die ausgewählten Einträge löschen",
    FCOGL_LAM_NONE                             = "-Keiner-",

    FCOGL_LAM_DEBUG_CHAT_OUTPUT_TOO             = "Chat Ausgabe ebenfalls aktivieren (LibDebugLogger)",
    FCOGL_LAM_DEBUG_CHAT_OUTPUT_TOO_TT          = "Wenn LibDebugLogger aktiv ist wird der Log nur in der DebugLogViewer Oberfläche (falls aktiv), oder in der SavedVariables file LibDebugLogger.lua ausgegeben.\nWenn du diese Option aktivierst wird zusätzlich im Chat der Text ausgegben, aber nur wenn\n|c5F5F5F\'LibDebugLogger\' geladen ist UND \'DebugLogViewer\' aktuell nicht aktiv ist!|r.",

    FCOGL_CHAT_EDITBOX_TEXT_TEMPLATE_DEFAULT    = "#<<1>>, Glückwunsch an \'<<C:2>>\'",
    FCOGL_GUILD_NAME_SHORT                      = "Gilden Name: %s",
    FCOGL_GUILD_NAME_LONG                       = "Gilden Name der Gilde Nr. %s (Server-weite eindeutige ID: %s): %s",
    FCOGL_GUILD_INFO_ROW_1                      = "Gilden Info über deine Gilde Nr. %s (Server-weite eindeutige ID: %s), Name: %s",
    FCOGL_GUILD_INFO_ROW_2                      = ">Anführer Name: %s / Offene Einladungen: %s",
    FCOGL_GUILD_INFO_ROW_3                      = ">Mitglieder Anzahl: %s / Aktuell Online: %s",

    --Date & time formats
    FCOGL_DATTIME_FORMAT_24HOURS                = "%d.%m.%y, %H:%M:%S",
    FCOGL_DATTIME_FORMAT_12HOURS                = "%y-%m-%d, %I:%M:%S %p",

    --Errors
    FCOGL_ERROR_SELECTED_GUILD_INVALID          = "Die ausgewählte Gilde scheint nicht valide zu sein. Bitte wähle eine Gilde aus der Gilden Auswahl Box aus.",
    FCOGL_ERROR_NO_GUILD_ONLY_GENERIC_DICE_THROW= "Bitte wähle eine Gilde aus der Gilden Auswahl Box aus!\nSonst kannst du nur einen normalen Würfel Wurf per Knopf/Chat Kommando /dice mit der Anzahl der Würfel-Seiten durchführen, die neben dem Würfeln Knopf in dem Editfeld geändert werden kann.",
    FCOGL_ERROR_GUILD_SALES_LOTTERY_PARAMETERS_MISSING = "Bitte nutze das Chat Kommando /gslnew <GildenIndex> <TageForDemAktuellen> um eine neue Gilden Verkaufs-Lotterie zu starten.\nErsetze <GildenIndex> mit dem Index 1 bis 5 deiner Gilden, und optional <TageForDemAktuellen> mit der Anzahl an Tagen die die Gilden Verkaufs-Lotterie das Ranking in die Vergangenheit berücksichtigen soll.\nwird der 2. Parameter leer gelassen, so werden \'%s days\' als Standard Wert verwendet.\n\nNach dem Starten einer neuen Gilden Verkaufs-Lotterie via /gslnew kannst du /gsl für den nächsten Würfen Wurf verwenden.",
    FCOGL_ERROR_GUILD_MEMBERS_JOIN_DATE_LIST_PARAMETERS_MISSING = "Bitte nutze das Chat Kommando /gmjnew <GildenIndex> <TageForDemAktuellen> um eine neue Gilden Mitglieder Beitritts-Liste zu starten.\nErsetze <GildenIndex> mit dem Index 1 bis 5 deiner Gilden, und optional <TageForDemAktuellen> mit der Anzahl an Tagen die die Gilden Mitglieder Beitritts-Liste in die Vergangenheit berücksichtigen soll.\nwird der 2. Parameter leer gelassen, so werden \'%s days\' als Standard Wert verwendet.\n\nNach dem Starten einer neuen Gilden Mitglieder Beitritts-Liste via /gmjnew kannst du /gmj für den nächsten Würfen Wurf verwenden.",

    FCOGL_ERROR_GUILD_GOT_NO_TRADER             = "Entweder du bist kein Mitglied der Gilde \'%s\', oder diese Gilde besitzt keinen Verkäufer..",
    FCOGL_ERROR_GUILD_MEMBER_COUNT              = "Die Anzahl der Gilden Mitglieder der Gilde #%s \'%s\' (ID: %s), welche etwas verkauft haben, ist 0.\nEntweder es wurden keine Gegenstände im gewählten Zeitrahmen verkauft, oder es gab einen Fehler!\nBitte versuche die Gilden Historien Daten manuell zu aktualisieren mit Hilfe des \'Mehr\' Knopfes (Tastenkombination) auf dem Gilden Historien Reiter. Prüfe dort auch, ob die LibHistoire Daten alle geladen wurden und synchron sind, oder ob noch etwas aktuell geladen wird.",
    FCOGL_ERROR_GUILD_MEMBER_JOINED_COUNT       = "Die Anzahl der Gilden Mitglieder der Gilde #%s \'%s\' (ID: %s), welche im selektierten Zeitraum der Gilde beigetreten sind, ist 0.\nBitte versuche die Gilden Historien Daten manuell zu aktualisieren mit Hilfe des \'Mehr\' Knopfes (Tastenkombination) auf dem Gilden Historien Reiter. Prüfe dort auch, ob die LibHistoire Daten alle geladen wurden und synchron sind, oder ob noch etwas aktuell geladen wird.",
    FCOGL_ERROR_GUILD_LISTENER_STILL_FETCHING_EVENTS = "Der Gilden Historien Datensammler der Gilde #%s \'%s\' (ID: %s) sammelt noch Events...\nBitte warten (kann Minuten, oder länger dauern), oder öffne die Gilden Historie der Gilde und aktualisiere diese manuell per \'Mehr\' Knopf (Tastenkombination) um neue Events einzulesen. Es müssen alle Events gelesen werden bis LibHistoire anzeigt, dass alles synchron und aktualisiert ist!",

    --Keybindings
    SI_BINDING_NAME_FCOGL_TOGGLE                = "Zeige/Verstecke FCO GuildLottery Oberfläche",
    SI_BINDING_NAME_FCOGL_ROLL_THE_DICE         = "Würfel mit Standard Seiten werfen",
    SI_BINDING_NAME_FCOGL_ROLL_THE_DICE_FOR_GUILD_SALES = "Starte Lotterie/Werfe Lotterie Würfel",
    SI_BINDING_NAME_FCOGL_RESET_GUILD_SALES     = "Gilden Verkaufs-Lotterie zurücksetzen",
    SI_BINDING_NAME_FCOGL_STOP_GUILD_SALES      = "Gilden Verkaufs-Lotterie stoppen",

    FCOGL_RELOADUI_WARNING_WITH_TEXT            = "<<========== FEHLER ==========>>\nDu hast keinen /reloadui (Benutzeroberfläche neuladen) durchgeführt nach dem Verändern %s in den Einstellungen/per Chat Kommando!\nBitte lade die Benutzeroberfläche nun neu!",
    FCOGL_RELOADUI_DAYSBEFORE                   = " des \'Tage rückwärts, von heute an\' Wertes"
}
local lang = FCOGuildLottery.lang["de"]

for stringId, stringValue in pairs(lang) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end