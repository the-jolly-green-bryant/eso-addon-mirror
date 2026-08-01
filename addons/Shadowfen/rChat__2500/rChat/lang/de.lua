--[[
Author: Ayantir
Filename: de.lua
Version: 5

Ä = \195\132
ä = \195\164
Ö = \195\150
ö = \195\182
Ü = \195\156
ü = \195\188
ß = \195\159

Many Thanks to Phidias & Baetram for their work

]]--

-- All the texts that need a translation. As this is being used as the
-- default (fallback) language, all strings that the addon uses MUST
-- be defined here.

--base language is english, so the file en.lua provides fallback strings.
rChat_localization_strings = rChat_localization_strings  or {}

rChat_localization_strings["de"] = {

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
    RCHAT_CHATTABH = "Einstellungen der Registerkarte Chat",
    RCHAT_enableChatTabChannel = "Aktiviere Chat Tab Letzter verwendeter Kanal",
    RCHAT_enableChatTabChannelT = "Wenn Sie die Chat-Registerkarten aktivieren, um den zuletzt verwendeten Kanal zu speichern, wird dies zur Standardeinstellung, bis Sie sich dafür entscheiden, einen anderen in dieser Registerkarte zu verwenden.",
    RCHAT_enableWhisperTab = "Enable Redirect Whisper",
    RCHAT_enableWhisperTabT = "Enable Redirect Whisper to a specific tab.",



-- New Need Translations

    RCHAT_OPTIONSH = "Nachrichtenoptionen",

    RCHAT_GUILDNUMBERS = "Gildennummer",
    RCHAT_GUILDNUMBERSTT = "Zeigt die Gildennummer neben dem Gildenkürzel an.",

    RCHAT_ALLGUILDSSAMECOLOUR = "Nutze eine Farbe für alle Gilden",
    RCHAT_ALLGUILDSSAMECOLOURTT = "Für alle 'Gildenchats' gilt die gleiche Farbeinstellung wie für die erste Gilde (/g1).",

    RCHAT_ALLZONESSAMECOLOUR = "Nutze eine Farbe für alle 'Zonenchats'",
    RCHAT_ALLZONESSAMECOLOURTT = "Für alle 'Zonenchats' gilt die gleiche Farbeinstellung wie für (/zone).",

    RCHAT_ALLNPCSAMECOLOUR = "Nutze eine Farbe für alle NSCs",
    RCHAT_ALLNPCSAMECOLOURTT = "Füe alle Texte von Nicht-Spieler-Charakteren (NSCs / NPCs) gilt die Farbeinstellung für 'NSC Sagen'.",

    RCHAT_DELZONETAGS = "Bezeichnung entfernen",
    RCHAT_DELZONETAGSTT = "Bezeichnungen ('tags') wie Schreien oder Zone am Anfang der Nachrichten entfernen.",

    RCHAT_ZONETAGSAY = "Sagen",
    RCHAT_ZONETAGYELL = "Schreien",
    RCHAT_ZONETAGPARTY = "Gruppe",
    RCHAT_ZONETAGZONE = "Zone",

    RCHAT_CARRIAGERETURN = "Spielernamen und Chattexte in eigenen Zeilen",
    RCHAT_CARRIAGERETURNTT = "Spielernamen und Chattexte werden durch einen Zeilenvorschub getrennt.",

    RCHAT_USEESOCOLORS = "ESO Standardfarben",
    RCHAT_USEESOCOLORSTT = "Verwendet statt der pchat Vorgabe die The Elder Scrolls Online Standard-Chat-Farben.",

    RCHAT_DIFFFORESOCOLORS = "Namen farbig absetzen",
    RCHAT_DIFFFORESOCOLORSTT = "Bestimmt den Helligkeitsunterschied zwischen Charakternamen / Chat-Kanal und Nachrichtentext.",

    RCHAT_REMOVECOLORSFROMMESSAGES = "Entferne Farbe aus Nachrichten",
    RCHAT_REMOVECOLORSFROMMESSAGESTT = "Verhindert die Anzeige von Farben in Nachrichten (z.B. Regenbogentext von Mitspielern).",

    RCHAT_AUGMENTHISTORYBUFFER = "Anzahl Zeilen im Chat anzeigen",
    RCHAT_AUGMENTHISTORYBUFFERTT = "Standardmässig werden nur 200 Zeilen im Chat dargestellt. Hiermit kannst du diese bis 1000 erhöhen.",

    RCHAT_PREVENTCHATTEXTFADING = "Textausblenden unterbinden",
    RCHAT_PREVENTCHATTEXTFADINGTT = "Verhindert,daß der Chat-Text ausgeblendet wird (Einstellungen zum Chat-Hintergrund finden sich unter Einstellungen: Soziales - Minimale Transparenz)",

    RCHAT_USEONECOLORFORLINES = "Einfarbige Zeilen",
    RCHAT_USEONECOLORFORLINESTT = "Verwendet nur eine Farbe pro Chat-Kanal, anstatt zwei Farben nur die Erste.",

    RCHAT_GUILDTAGSNEXTTOENTRYBOX = "Gildenkürzel neben der Eingabe",
    RCHAT_GUILDTAGSNEXTTOENTRYBOXTT = "Zeigt das Gildenkürzel anstelle des Gildennamens neben der Eingabezeile an.",

    RCHAT_DISABLEBRACKETS = "Klammern um Namen entfernen",
    RCHAT_DISABLEBRACKETSTT = "Entfernt Klammern [] um die Namen der Spieler",

    RCHAT_DEFAULTCHANNEL = "Standardkanal",
    RCHAT_DEFAULTCHANNELTT = "Bestimmt welcher Chat-Kanal nach der Anmeldung automatisch zuerst verwendet wird.",

    RCHAT_DEFAULTCHANNELCHOICE99 = "nicht ändern",
    RCHAT_DEFAULTCHANNELCHOICE31 = "/zone",
    RCHAT_DEFAULTCHANNELCHOICE0 = "/sagen",
    RCHAT_DEFAULTCHANNELCHOICE12 = "/gilde1",
    RCHAT_DEFAULTCHANNELCHOICE13 = "/gilde2",
    RCHAT_DEFAULTCHANNELCHOICE14 = "/gilde3",
    RCHAT_DEFAULTCHANNELCHOICE15 = "/gilde4",
    RCHAT_DEFAULTCHANNELCHOICE16 = "/gilde5",
    RCHAT_DEFAULTCHANNELCHOICE17 = "/offizier1",
    RCHAT_DEFAULTCHANNELCHOICE18 = "/offizier2",
    RCHAT_DEFAULTCHANNELCHOICE19 = "/offizier3",
    RCHAT_DEFAULTCHANNELCHOICE20 = "/offizier4",
    RCHAT_DEFAULTCHANNELCHOICE21 = "/offizier5",

    RCHAT_GEOCHANNELSFORMAT = "Namen Darstellung",
    RCHAT_GEOCHANNELSFORMATTT = "Darstellung der Namensanzeige für die lokalen Kanäle (sagen, Zone, schreien).",

    RCHAT_DEFAULTTAB = "Standard Reiter",
    RCHAT_DEFAULTTABTT = "Welcher Reiter soll als Standard gewählt werden?",

    RCHAT_ADDCHANNELANDTARGETTOHISTORY = "Kanal wechseln beim Benutzen der Historie",
    RCHAT_ADDCHANNELANDTARGETTOHISTORYTT = "Der Kanal wird beim Verwenden der Pfeiltasten zum zuletzt gewählten Reiter wechseln.",

    RCHAT_URLHANDLING = "Erkenne URL\'s und mache sie verwendbar",
    RCHAT_URLHANDLINGTT = "Wenn eine URL mit http(s):// anfängt, wird rChat diese Links erkennen. Klicke auf diese Links um die Adresse in deinem Browser aufzurufen.",

    RCHAT_ENABLECOPY = "Kopie/Chat Kanal Wechsel aktivieren",
    RCHAT_ENABLECOPYTT = "Aktivieren Sie das Kopieren von Text mit einem Rechtsklick.\nDies ermöglicht ebenfalls den Chat Kanal-Wechsel mit einem Linksklick.\n\nDeaktivieren Sie diese Option, wenn Sie Probleme mit der Anzeige von Links im Chat haben.",

-- Group Settings

    RCHAT_GROUPH = "Gruppen Kanal Einstellungen",

    RCHAT_ENABLEPARTYSWITCH = "automatischer Gruppenkanal Wechsel",
    RCHAT_ENABLEPARTYSWITCHTT = "Wenn du einer Gruppe beitrittst, wechselt der Kanal automatisch. Beim verlassen der Gruppe entsprechend zurück zum zuletzt verwendeten Kanal.",

    RCHAT_GROUPLEADER = "Sonderfarben für Gruppenleiter",
    RCHAT_GROUPLEADERTT = "Die Gruppenleiter werden eine spezielle Farbe bekommen.",

    RCHAT_GROUPLEADERCOLOR = "Sonderfarbe Name des Gruppenleiters",
    RCHAT_GROUPLEADERCOLORTT = "Farbe des Gruppenleiters. Diese Farbe ist nur aktiv, wenn \"ESO Standardfarben\" deaktiviert ist.",

    RCHAT_GROUPLEADERCOLOR1 = "Sonderfarbe Nachricht des Gruppenleiters",
    RCHAT_GROUPLEADERCOLOR1TT = "Farbe der Nachrichten des Gruppenleiters. Wenn \"ESO Standardfarben\" deaktiviert ist, ist entsprechend diese Funktion auch deaktiviert. Es wird entsprechend die obere Farbe des Gruppenleiters gewählt.",

    RCHAT_GROUPNAMES = "Namen Darstellung in Gruppen",
    RCHAT_GROUPNAMESTT = "Darstellung der Gruppen-Namensanzeige.",

    RCHAT_GROUPNAMESCHOICE1 = "@Accountname",
    RCHAT_GROUPNAMESCHOICE2 = "Charaktername",
    RCHAT_GROUPNAMESCHOICE3 = "Charaktername@Accountname",
    RCHAT_GROUPNAMESCHOICE4 = "Charaktername(@Accountname)",

-- Sync settings

    RCHAT_SYNCH =     "Synchronisierungseinstellungen",

    RCHAT_CHATSYNCCONFIG = "Chat-Konfiguration synchronisieren",
    RCHAT_CHATSYNCCONFIGTT = "Wenn die Synchronisierung aktiviert ist, werden alle Charaktere die gleiche Chat-Konfiguration (Farben, Position, Fensterabmessungen, Reiter) bekommen:\nAktivieren Sie diese Option, nachdem Sie Ihren Chat vollständig angepasst haben, und er wird für alle anderen Charaktere gleich eingestellt!",

    RCHAT_CHATSYNCCONFIGIMPORTFROM = "Chat Einstellungen übernehmen von",
    RCHAT_CHATSYNCCONFIGIMPORTFROMTT = "Sie können jederzeit die Chat-Einstellungen von einem anderen Charakter importieren (Farbe, Ausrichtung, Fenstergröße, Reiter).\nWählen Sie hier Ihren 'Vorlage Charakter' aus.",

-- Apparence

    RCHAT_APPEARANCEMH = "Chatfenster Aussehen",

    RCHAT_TABWARNING = "Neue Nachricht Warnung",
    RCHAT_TABWARNINGTT = "Legen Sie die Farbe für die Warnmeldung im Chat Reiter fest.",

    RCHAT_WINDOWDARKNESS = "Transparenz des Chat-Fensters",
    RCHAT_WINDOWDARKNESSTT = "Erhöhen Sie die Verdunkelung des Chat-Fensters",

    RCHAT_CHATMINIMIZEDATLAUNCH = "Chat beim Start minimiert",
    RCHAT_CHATMINIMIZEDATLAUNCHTT = "Chat-Fenster auf der linken Seite des Bildschirms minimieren, wenn das Spiel startet",

    RCHAT_CHATMINIMIZEDINMENUS = "Chat in Menüs minimiert",
    RCHAT_CHATMINIMIZEDINMENUSTT = "Chat-Fenster auf der linken Seite des Bildschirms minimieren, wenn Menüs (Gilde, Charakter, Handwerk, etc.) geöffnet werden",

    RCHAT_CHATMAXIMIZEDAFTERMENUS = "Chat nach Menüs wieder herstellen",
    RCHAT_CHATMAXIMIZEDAFTERMENUSTT = "Zeigt das Chat Fenster, nach dem Verlassen von Menüs, wieder an",

    RCHAT_FONTCHANGE = "Schriftart",
    RCHAT_FONTCHANGETT = "Wählen Sie die Schriftart für den Chat aus.\nStandard: 'ESO Standard Font'",

-- Whisper settings

    RCHAT_IMH = "Flüstern",

	RCHAT_WHISPSOUND_ENABLED = "Aktivieren Sie Sounds für geflüsterte Nachrichten",
    RCHAT_SOUNDFORINCWHISPS = "Ton für eingehende Flüsternachricht",
    RCHAT_SOUNDFORINCWHISPSTT = "Wählen Sie Sound, der abgespielt wird, wenn Sie ein Flüstern erhalten",

    RCHAT_NOTIFYIM = "Visuelle Hinweise anzeigen",
    RCHAT_NOTIFYIMTT = "Wenn Sie eine Flüsternachricht verpassen, wird eine Meldung in der oberen rechten Ecke des Chat-Fenster angezeigt. Wenn Sie auf diese Meldung klicken werden Sie direkt zur Flüsternachricht im Chat gebracht.\nWar Ihr Chat zum Zeitpunkt des Nachrichteneinganges minimiert, wird in der Chat Mini-Leiste ebenfalls eine Benachrichtigung angezeigt.",

-- Restore chat settings

    RCHAT_RESTORECHATH = "Chat wiederherstellen",

    RCHAT_RESTOREONRELOADUI = "Nach ReloadUI",
    RCHAT_RESTOREONRELOADUITT = "Nach dem Neuladen der Benutzeroberfläche (/reloadui) wird rChat den vorherigen Chat + Historie wieder herstellen. Sie können somit Ihre vorherige Konversation wieder aufnehmen.",

    RCHAT_RESTOREONLOGOUT = "Nach LogOut",
    RCHAT_RESTOREONLOGOUTTT = "Nach dem Ausloggen wird rChat den vorherigen Chat + Historie wieder herstellen. Sie können somit Ihre vorherige Konversation wieder aufnehmen.\nAchtung: Dies wird nur passieren, wenn Sie sich in der unten eingestellten 'Maximale Zeit für Wiederherstellung' erneut anmelden!",

    RCHAT_RESTOREONAFK = "Nach Kick (z.B. Inaktivität)",
    RCHAT_RESTOREONAFKTT = "Nachdem Sie vom Spiel rausgeschmissen wurden, z.B. durch Inaktivität, Senden zuvieler Nachrichten oder einer Netzwerk Trennung, wird rChat den Chat + Historie wieder herstellen. Sie können somit Ihre vorherige Konversation wieder aufnehmen.\nAchtung: Dies wird nur passieren, wenn Sie sich in der unten eingestellten 'Maximale Zeit für Wiederherstellung' erneut anmelden!",

    RCHAT_RESTOREONQUIT = "Nach dem Verlassen",
    RCHAT_RESTOREONQUITTT = "Wenn Sie das Spiel selbstständig verlassen, wird rChat den Chat + Historie wieder herstellen. Sie können somit Ihre vorherige Konversation wieder aufnehmen.\nAchtung: Dies wird nur passieren, wenn Sie sich in der unten eingestellten 'Maximale Zeit für Wiederherstellung' erneut anmelden!",

    RCHAT_TIMEBEFORERESTORE = "Maximale Zeit für Wiederherstellung",
    RCHAT_TIMEBEFORERESTORETT = "NACH dieser Zeit (in Stunden), wird rChat nicht mehr versuchen, den Chat wieder herzustellen",

    RCHAT_RESTORESYSTEM = "Systemnachrichten wiederherstellen",
    RCHAT_RESTORESYSTEMTT = "Stelle auch Systemnachrichten wieder her (z.B. Login Nachrichten, Addon Nachrichten) wenn der Chat + Historie wiederhergestellt werden",

    RCHAT_RESTORESYSTEMONLY = "Nur Systemnachrichten wiederherstellen",
    RCHAT_RESTORESYSTEMONLYTT = "Stellt nur Systemnachrichten wieder her (z.B. Anmelde- und Addon-Nachrichten).",

    RCHAT_RESTOREWHISPS = "Flüsternachricht wiederherstellen",
    RCHAT_RESTOREWHISPSTT = "Stellt Flüsternachrichten wieder her. Flüsternachrichten sind nach einem /ReloadUI immer wiederhergestellt.",

    RCHAT_RESTORETEXTENTRYHISTORYATLOGOUTQUIT = "Text wiederherstellen bei Historie",
    RCHAT_RESTORETEXTENTRYHISTORYATLOGOUTQUITTT = "Stellt die Historie wieder her beim verwenden der Pfeiltasten. Die Historie ist nach einem /ReloadUI immer wiederhergestellt.",

-- Anti Spam settings

    RCHAT_ANTISPAMH = "Anti-Spam",

    RCHAT_FLOODPROTECT = "Aktiviere Anti-Flood",
    RCHAT_FLOODPROTECTTT = "Verhindert, dass Ihnen sich wiederholende, identische Nachrichten von Spielern angezeigt werden",

    RCHAT_FLOODGRACEPERIOD = "Dauer Anti-Flood Verbannung",
    RCHAT_FLOODGRACEPERIODTT = "Anzahl der Sekunden in denen sich wiederholende, identische Nachrichten ignoriert werden",

    RCHAT_LOOKINGFORPROTECT = "Ignoriere Gruppen(suche)nachrichten",
    RCHAT_LOOKINGFORPROTECTTT = "Ignoriert Nachrichten, mit denen nach Gruppen/Gruppenmitgliedern gesucht wird",

    RCHAT_WANTTOPROTECT = "Ignoriere Handelsnachrichten ",
    RCHAT_WANTTOPROTECTTT = "Ignoriert Nachrichten von Spielern, die etwas handeln oder ver-/kaufen möchten",

	RCHAT_GUILDPROTECT = "Ignore Guild Recruiting messages",
	RCHAT_GUILDPROTECTTT = "Ignore messages from players promoting Guild memberships",

    RCHAT_SPAMGRACEPERIOD = "Anti-Flood temporär deaktivieren",
    RCHAT_SPAMGRACEPERIODTT = "Wenn Sie selber eine Gruppe suchen, einen Handel oder Ver-/Kauf über den Chat kommunizieren, wird der Anti-Flood Schutz temporär aufgehoben.\nDiese Einstellung legt die Minuten fest, nachdem der Anti-Flood Schutz wieder aktiviert wird.",

-- Nicknames settings

    RCHAT_NICKNAMESH = "Spitzname",
    RCHAT_NICKNAMESD = "Du kannst an gewissen Spielern separate Spitznamen vergeben.\nBeispiel ganzer Account: @Ayantir = Blondschopf\nBeispiel nur einen Charakter: Der-gern-kaut = Blondschopf",
    RCHAT_NICKNAMES = "Liste der Spitznamen",
    RCHAT_NICKNAMESTT = "Du kannst an gewissen Spielern separate Spitznamen vergeben.\nBeispiel ganzer Account: @Ayantir = Blondschopf\nBeispiel nur einen Charakter: Der-gern-kaut = Blondschopf",

-- Timestamp settings

    RCHAT_TIMESTAMPH = "Zeitstempel",

    RCHAT_ENABLETIMESTAMP = "Aktiviere Zeitstempel",
    RCHAT_ENABLETIMESTAMPTT = "Fügt Chat-Nachrichten einen Zeitstempel hinzu.",

    RCHAT_TIMESTAMPCOLORISLCOL = "Zeitstempel und Spielernamen gleich färben",
    RCHAT_TIMESTAMPCOLORISLCOLTT = "Für den Zeitstempel gilt die gleiche Farbeinstellung wie für den Spielernamen, oder Nicht-Spieler-Charakter (NSC / NPC)",

    RCHAT_TIMESTAMPFORMAT = "Zeitstempelformat",
    RCHAT_TIMESTAMPFORMATTT = "FORMAT:\nHH: Stunden (24)\nhh: Stunden (12)\nH: Stunde (24, keine vorangestellte 0)\nh: Stunde (12, keine vorangestellte 0)\nA: AM/PM\na: am/pm\nm: Minuten\ns: Sekunden",

    RCHAT_TIMESTAMP = "Zeitstempel",
    RCHAT_TIMESTAMPTT = "Legt die Farbe des Zeitstempels fest.",

-- Guild settings

    RCHAT_NICKNAMEFOR = "Spitzname",
    RCHAT_NICKNAMEFORTT = "Spitzname für ",

    RCHAT_OFFICERTAG = "Offizierskanal",
    RCHAT_OFFICERTAGTT = "Seperates Präfix für den Offizierskanal verwenden.",

    RCHAT_SWITCHFOR = "Wechsel zum Kanal",
    RCHAT_SWITCHFORTT = "Neuer Wechsel zu Kanal. Beispiel: /myguild",

    RCHAT_OFFICERSWITCHFOR = "Wechsel zu Offizierskanal",
    RCHAT_OFFICERSWITCHFORTT = "Neuer Wechsel zu Offizierskanal. Beispiel /offs",

    RCHAT_NAMEFORMAT = "Namensformat",
    RCHAT_NAMEFORMATTT = "Legt die Formatierung für die Namensanzeige von Gildenmitgliedern fest.",

    RCHAT_FORMATCHOICE1 = "@Accountname",
    RCHAT_FORMATCHOICE2 = "Charaktername",
    RCHAT_FORMATCHOICE3 = "Charaktername@Accountname",
    RCHAT_FORMATCHOICE4 = "Charaktername(@Accountname)",

    RCHAT_SETCOLORSFORTT = "Farbe für Mitglieder von ",
    RCHAT_SETCOLORSFORCHATTT = "Farbe für Nachrichten von ",

    RCHAT_SETCOLORSFOROFFICIERSTT = "Farbe für Mitglieder des 'Offiziers-Chats' von ",
    RCHAT_SETCOLORSFOROFFICIERSCHATTT = "Farbe für Nachrichten des 'Offiziers-Chats' von ",

    RCHAT_MEMBERS = "<<1>> - Spieler",
    RCHAT_CHAT =     "<<1>> - Nachrichten",

    RCHAT_OFFICERSTT = " Offiziere",

-- Channel colors settings

    RCHAT_CHATCOLORSH = "Chat-Farben",

    RCHAT_SAY = "Sagen - Spieler",
    RCHAT_SAYTT = "Legt die Farbe für vom Spieler verfasste Nachrichten im Chat-Kanal: Sagen fest.",

    RCHAT_SAYCHAT = "Sagen - Chat",
    RCHAT_SAYCHATTT = "Legt die Farbe der Nachrichten im Chat-Kanal: Sagen fest.",

    RCHAT_ZONE =     "Zone - Spieler",
    RCHAT_ZONETT =     "Legt die Farbe für vom Spieler verfasste Nachrichten im Chat-Kanal: Zone fest.",

    RCHAT_ZONECHAT = "Zone - Chat",
    RCHAT_ZONECHATTT = "Legt die Farbe der Nachrichten im Chat-Kanal: Zone fest.",

    RCHAT_YELL =     "Schreien - Spieler",
    RCHAT_YELLTT=     "Legt die Farbe für vom Spieler verfasste Nachrichten im Chat-Kanal: Schreien fest.",

    RCHAT_YELLCHAT = "Schreien - Chat",
    RCHAT_YELLCHATTT = "Legt die Farbe der Nachrichten im Chat-Kanal: Schreien fest.",

    RCHAT_INCOMINGWHISPERS = "Eingehendes Flüstern - Spieler",
    RCHAT_INCOMINGWHISPERSTT = "Legt die Farbe für vom Spieler verfasste Nachrichten im Chat-Kanal: eingehendes Flüstern fest.",

    RCHAT_INCOMINGWHISPERSCHAT = "Eingehendes Flüstern - Chat",
    RCHAT_INCOMINGWHISPERSCHATTT = "Legt die Farbe der Nachrichten im Chat-Kanal: eingehendes Flüstern fest.",

    RCHAT_OUTGOINGWHISPERS = "Ausgehendes Flüstern - Spieler",
    RCHAT_OUTGOINGWHISPERSTT = "Legt die Farbe für vom Spieler verfasste Nachrichten im Chat-Kanal: ausgehendes Flüstern fest.",

    RCHAT_OUTGOINGWHISPERSCHAT = "Ausgehendes Flüstern - Chat",
    RCHAT_OUTGOINGWHISPERSCHATTT = "Legt die Farbe der Nachrichten im Chat-Kanal: ausgehendes Flüstern fest.",

    RCHAT_GROUP =     "Gruppe - Spieler",
    RCHAT_GROUPTT = "Legt die Farbe für vom Spieler verfasste Nachrichten im Chat-Kanal: Gruppe fest.",

    RCHAT_GROURCHAT = "Gruppe - Chat",
    RCHAT_GROURCHATTT = "Legt die Farbe der Nachrichten im Chat-Kanal: Gruppe fest.",

-- Other colors

    RCHAT_OTHERCOLORSH = "Sonstige Farben",

    RCHAT_EMOTES =     "'Emotes' - Spieler",
    RCHAT_EMOTESTT = "Legt die Farbe für vom Spieler ausgeführte 'Emotes' fest.",

    RCHAT_EMOTESCHAT = "Emotes - Chat",
    RCHAT_EMOTESCHATTT = "Legt die Farbe von 'Emotes' im Chat fest.",

    RCHAT_ENZONE =     "EN Zone - Spieler",
    RCHAT_ENZONETT = "Legt die Farbe für vom Spieler verfasste Nachrichten im englischsprachigen Chat-Kanal fest.",

    RCHAT_ENZONECHAT = "EN Zone - Chat",
    RCHAT_ENZONECHATTT = "Legt die Farbe der Nachrichten im englischsprachigen Chat-Kanal fest.",

    RCHAT_FRZONE =     "FR Zone - Spieler",
    RCHAT_FRZONETT = "Legt die Farbe für vom Spieler verfasste Nachrichten im französischsprachigen Chat-Kanal fest.",

    RCHAT_FRZONECHAT = "FR Zone - Chat",
    RCHAT_FRZONECHATTT = "Legt die Farbe der Nachrichten im französischsprachigen Chat-Kanal fest.",

    RCHAT_DEZONE =     "DE Zone - Spieler",
    RCHAT_DEZONETT = "Legt die Farbe für vom Spieler verfasste Nachrichten im deutschsprachigen Chat-Kanal fest.",

    RCHAT_DEZONECHAT = "DE Zone - Chat",
    RCHAT_DEZONECHATTT = "Legt die Farbe der Nachrichten im deutschsprachigen Chat-Kanal fest.",

    RCHAT_JPZONE =     "JP Zone - Spieler",
    RCHAT_JPZONETT = "Legt die Farbe für vom Spieler verfasste Nachrichten im japanisch Chat-Kanal fest.",

    RCHAT_JPZONECHAT = "JP Zone - Chat",
    RCHAT_JPZONECHATTT = "Legt die Farbe der Nachrichten im japanisch Chat-Kanal fest.",

    RCHAT_RUZONE =     "RU Zone - Spieler",
    RCHAT_RUZONETT = "Legt die Farbe für vom Spieler verfasste Nachrichten im russischen Chat-Kanal fest.",

    RCHAT_RUZONECHAT = "RU Zone - Chat",
    RCHAT_RUZONECHATTT = "Legt die Farbe der Nachrichten im russischen Chat-Kanal fest.",

    RCHAT_NPCSAY =     "NSC Sagen - NSC Name",
    RCHAT_NPCSAYTT = "Legt die Farbe des Namens des Nicht-Spieler-Charakters (NSC - NPC) in NSC-Texten fest.",

    RCHAT_NPCSAYCHAT = "NSC Sagen - Chat",
    RCHAT_NPCSAYCHATTT = "Legt die Farbe für Nicht-Spieler-Charaktertexte fest.",

    RCHAT_NPCYELL = "NSC Schreien - NSC Name",
    RCHAT_NPCYELLTT = "Legt die Farbe des Namens des Nicht-Spieler-Charakters (NSC - NPC) in geschrienen NSC-Texten fest.",

    RCHAT_NPCYELLCHAT = "NSC Schreien - Chat",
    RCHAT_NPCYELLCHATTT = "Legt die Farbe für geschriene Nicht-Spieler-Charaktertexte fest.",

    RCHAT_NPCWHISPER = "NSC Flüstern - NSC Name",
    RCHAT_NPCWHISPERTT = "Legt die Farbe des Namens des Nicht-Spieler-Charakters (NSC - NPC) in geflüsterten NSC-Texten fest.",

    RCHAT_NPCWHISPERCHAT = "NSC Flüstern - Chat",
    RCHAT_NPCWHISPERCHATTT = "Legt die Farbe für geflüsterte Nicht-Spieler-Charaktertexte fest.",

    RCHAT_NPCEMOTES = "NSC 'Emote' - NSC Name",
    RCHAT_NPCEMOTESTT = "Legt die Farbe des Namens des Nicht-Spieler-Charakters (NSC - NPC) der ein 'Emote' ausführt fest.",

    RCHAT_NPCEMOTESCHAT = "NSC 'Emote' - Chat",
    RCHAT_NPCEMOTESCHATTT = "Legt die Farbe für 'Nicht-Spieler-Charakter-Emotes' im Chat fest.",

-- Various strings not in panel settings

    RCHAT_COPYMESSAGECT = "Nachricht kopieren",
    RCHAT_COPYLINECT = "Zeile kopieren",
    RCHAT_COPYDISCUSSIONCT = "Diskussion kopieren",
    RCHAT_ALLCT = "Ganzes Plaudern kopieren",

    RCHAT_COPYXMLTITLE = "Kopiere Text mit STRG+C",
    RCHAT_COPYXMLLABEL = "Kopiere Text mit STRG+C",
    RCHAT_COPYXMLTOOLONG = "Text ist uzu lang und wurde aufgeteilt",
    RCHAT_COPYXMLNEXT = "Nächster",

    RCHAT_SWITCHTONEXTTABBINDING = "Zur nächsten Registerkarte",
    RCHAT_TOGGLECHATBINDING = "Toggle Chat-Fenster",
    RCHAT_WHISPMYTARGETBINDING = "Flüsternachricht an Zielperson",

    RCHAT_SAVMSGERRALREADYEXISTS = "Kann die Nachricht nicht speichern, da sie schon existiert!",
    RCHAT_RCHAT_AUTOMSG_NAME_DEFAULT_TEXT = "Beispiel: ts3",
    RCHAT_RCHAT_AUTOMSG_MESSAGE_DEFAULT_TEXT = "Schreibe hier deine Nachricht, die bei der Sendefunktion geschickt werden sollte.",
    RCHAT_RCHAT_AUTOMSG_MESSAGE_TIP1_TEXT = "Neue Zeilen werden automatisch gelöscht.",
    RCHAT_RCHAT_AUTOMSG_MESSAGE_TIP2_TEXT = "Die Nachricht wird gesendet, sobald du sie bestätigt hast: \"!nameOfMessage\". (Bsp: |cFFFFFF!ts3|r)",
    RCHAT_RCHAT_AUTOMSG_MESSAGE_TIP3_TEXT = "Um eine Nachricht in einem bestimmten Kanal zu senden, füge am Anfang der Nachricht den Kanal ein (Bsp: |cFFFFFF/g1|r)",
    RCHAT_RCHAT_AUTOMSG_NAME_HEADER = "Akronym deiner Nachricht",
    RCHAT_RCHAT_AUTOMSG_MESSAGE_HEADER = "Nachricht",
    RCHAT_RCHAT_AUTOMSG_ADD_TITLE_HEADER = "Neue automatische Nachricht",
    RCHAT_RCHAT_AUTOMSG_EDIT_TITLE_HEADER = "Ändere automatische Nachricht",
    RCHAT_RCHAT_AUTOMSG_ADD_AUTO_MSG = "Hinzufügen",
    RCHAT_RCHAT_AUTOMSG_EDIT_AUTO_MSG = "Ändern",
    RCHAT_SI_BINDING_NAME_RCHAT_SHOW_AUTO_MSG = "Automatische Nachricht",
    RCHAT_RCHAT_AUTOMSG_REMOVE_AUTO_MSG = "Löschen",

    RCHAT_CLEARBUFFER = "Klar Chatfenster",
	RCHAT_CLEARCACHE = "Chatverlauf löschen",
	RCHAT_CLEARCACHE_TT = "Leeren Sie den Chatverlauf, damit er nicht vor diesem Zeitpunkt wiederhergestellt werden kann.",


    RCHAT_MENTION_NM = "Erwähnungen Benachrichtigung",
    RCHAT_MENTION_ENABLED = "Aktivieren Sie die Erwähnung Anerkennung im Chat",
    RCHAT_MENTIONSTR = "Zeichenfolge, nach der im Chat gesucht werden soll",
    RCHAT_SOUND_ENABLED = "Aktivieren Sie die Tonbenachrichtigung",
    RCHAT_SOUND_INDEX = "Welchen Sound soll ich spielen?",
    RCHAT_COLOR_ENABLED = "Aktivieren Sie Hervorhebung mit Farbe",
    RCHAT_MENTIONCOLOR = "Hervorheben mit welcher Farbe",
    RCHAT_SOUND_NAME = "Name des aktuellen Sounds",

	RCHAT_DISABLELOGGER = "Deaktivieren Sie die LibDebugLogger-Chat-Blockierung",
	RCHAT_DISABLELOGGERTT = "Deaktivieren Sie die LibDebugLogger-Blockierung von SYSTEM-Nachrichten im Chat.",
}