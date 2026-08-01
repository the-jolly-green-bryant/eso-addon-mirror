-- SwissArmyKnife German Localization File
-- Last Updated 23-09-2017
-- Written Decembre 2016 by Tristan Carron (@homeopatix)
-- Released under terms in license accompanying this file.

-- Options Menu
ZO_CreateStringId("KF_KEY_TO_SEARCH", "SwissArmyKnife")

-- KeyBindings
ZO_CreateStringId("SI_BINDING_NAME_SwissArmyKnifeTEXT", "Zeigt SwissArmyKnife")
ZO_CreateStringId("SI_BINDING_NAME_SwissArmyKnifeJUMP", "Reisen ins Haupthaus")
ZO_CreateStringId("SI_BINDING_NAME_SwissArmyKnifeJUNK", "Stellen Sie Junk ein")
ZO_CreateStringId("SI_BINDING_NAME_SwissArmyKnifeLOCK", "Sperren oder Entsperren")
ZO_CreateStringId("SI_BINDING_NAME_SwissArmyKnifeBAND", "Ändern Sie die Bandanzeige")
ZO_CreateStringId("SI_BINDING_NAME_SwissArmyKnifeHELMET", "Helm anzeigen oder ausblenden")

-- Slash commande
SAK.lang = {
		KF_SLASH_1 = "Slash-Befehl fur ",
		KF_SLASH_2 = ": Zeigt Slash-Befehl",
		KF_SLASH_3 = ": Zeigt die grafische addon",
		KF_SLASH_4 = ": Maske die grafische addon",
		KF_SLASH_5 = ": zeigt alle ",
		KF_SLASH_5_2 = " Unterhaltung",
		KF_SLASH_7 = ": Zeige nichts Chat (Standard)",

		KF_SLASH_8 = "Zeige alle ",
		KF_SLASH_8_2 = " gepflückt aktiviert",
		KF_SLASH_10 = "Anzeigen ",
		KF_SLASH_10_2 = " und die ",
		KF_SLASH_10_3 = " untauglich",
		KF_GOOD = "************ gute farming !!! *************",

		KF_INITIALIZED = "initialisiert !!",
				-- money deposit
		KF_RAD = "Deposed in der Bank ",
		KF_RAD_1 = "Nichts in der Bank",
		KF_RAD_2 = "Überreste : ",
		KF_RAD_3 = " und ",
		KF_RAD_4 = " Auf den Charakter",
		KF_SLASH_18 = ": Geld min, um auf Sie zu halten",
		KF_SLASH_19 = ": Tel Var steine ​​min auf Sie zu halten",

		KF_SLASH_20 = "Geld zu halten in der Tasche definiert auf ",
		KF_SLASH_21 = "Tel Var min zu halten in der Tasche definiert auf ",
		KF_SLASH_22 = "Slash-Befehl eine Gruppe zu verlassen",
		KF_SLASH_23 = "Sie ist nicht gruppiert !!!!",
		KF_SLASH_24 = "Sie verlassen die Gruppe !!!!",

		KF_SETTINGS_1 = "Zeigt",
		KF_SETTINGS_2 = "Money Bank",
		KF_SETTINGS_21 = "Einstellungen für die automatische Einzahlung",
		KF_SETTINGS_3 = "Zeigt Settings",

		KF_COST_REPAIR = "Reparaturkosten :",
		KF_SEUIL_REP_1 = "Reparatur",
		KF_SEUIL_REP_2 = "Threshold",
		KF_SEUIL_REP_3 = "Threshold Reparatur Rüstung oder Waffen aufladen",
		KF_SEUIL_REP_4 = "Definierte Reparaturschwelle",
		KF_SEUIL_REP_5 = "Reparatur threshold definiert auf ",

		KF_SEUIL_REP_6 = "Bordürenfarbe",
		KF_SEUIL_REP_6_2 = "Anzeigefarbe der Border-Haltbarkeit",
		KF_SEUIL_REP_7 = "Text-Hervorhebungsfarbe",
		KF_SEUIL_REP_7_2 = "Textfarbe der Haltbarkeit",

		KF_SEUIL_REPA_1 = "Gebühren",
		KF_SEUIL_REPA_2 = "Schwelle Gebühren",
		KF_SEUIL_REPA_3 = "Schwellenwert der Waffenladung",
		KF_SEUIL_REPA_4 = "Definieren Sie den Ladeschwellenwert",
		KF_SEUIL_REPA_5 = "Gebühren Schwelle definieren auf ",
		
		KF_SEUIL_REPA_6 = "Bordürenfarbe",
		KF_SEUIL_REPA_6_2 = "Anzeigefarbe des Rahmens für Ladung",
		KF_SEUIL_REPA_7 = "Text-Hervorhebungsfarbe",
		KF_SEUIL_REPA_7_2 = "Textfarbe der Ladung",
		KF_REPAIR_1 = "Ausrüstung repariert für",
		KF_REPAIR_2 = "Nicht genug Geld, um es zu reparieren",
		KF_AUTO_REPA_1 = "Autoreparatur",
		KF_AUTO_REPA_2 = "Verwenden Sie die automatische Reparatur",
		KF_AUTO_REPA_4 = "Zeigen Sie die automatische Reparatur im Chat an",
		KF_AUTO_REPA_6 = "Automatisches Nachladen",
		KF_AUTO_REPA_7 = "Verwendung von automatischem Neuladen",
		KF_AUTO_REPA_9 = "Zeigt automatisches Neuladen im Chat an",
		KF_AUTO_REPA_10 = "Definieren Sie den Schwellenwert für das automatische Neuladen",
		KF_AUTO_REPA_11 = "Schwellenwert für automatisches Neuladen wird aktiviert",
		KF_AUTO_REPA_12 = "Reloaded mit",
		KF_AUTO_REPA_13 = "Aktiviert",
		KF_AUTO_REPA_14 = "Deaktiviert",

		KF_GENERAL_ST_1 = "General",
		KF_GENERAL_ST_2 = "Mehrfachkonto",
		KF_GENERAL_ST_2_1 = "Einstellungen für alle Zeichen speichern",
		KF_GENERAL_ST_3 = "Durch diese Änderung wird die Benutzeroberfläche neu geladen",
		KF_GENERAL_ST_4 = "Erlebnis anzeigen",
		KF_GENERAL_ST_4_1 = "Erfahrung und Niveau anzeigen",
		KF_GENERAL_ST_8 = "Zeigen Sie den erleuchteten Pool an",
		KF_GENERAL_ST_8_1 = "Zeigt den erleuchteten Pool oder die benötigte xp an",
		KF_GENERAL_ST_8_2 = "Anzeige der Erhebungsleiste",
		KF_GENERAL_ST_8_3 = "Anzeige der Erhebungsleiste oder nicht",

		KF_LANG_1 = "Sagen Sie hallo zu gruppieren",
		KF_LANG_2 = "Sagen Danke und tschüss zur Gruppe",
		KF_LANG_3 = "Beantworten Sie einen Freund",
		KF_LANG_4 = "Sag Hallo zur Gilde1",
		KF_LANG_5 = "Sag Hallo zur Gilde2",
		KF_LANG_6 = "Sag Hallo zur Gilde3",
		KF_LANG_7 = "Sag Hallo zur Gilde4",
		KF_LANG_8 = "Sag Hallo zur Gilde5",
		KF_LANG_10 = "Anzeigen des Schrägstrichbefehls für die Sprache",
		KF_SLASH_11 = "Slash - Befehlssprache für ",

		KF_SETTINGS_1_1 = "Reparatur und Gebühren",
		KF_SETTINGS_2_1 = "Automatischer Text",
		KF_SETTINGS_3_1 = "!!!! WIR KÖNNEN NICHT SENDEN DIREKT CHAT MELDUNG, SO DIE BOTSCHAFT IST FÜR SIE IN DER CHAT SCHRIFTLICH, UND SIE MÜSSEN GERADE ZU PRESSEN !!!!",
		KF_SETTINGS_4 = "Gruppe",
		KF_SETTINGS_5 = "Begrüßungstext               /kh =",
		KF_SETTINGS_6 = "Tschüss Text               /kt =",
		KF_SETTINGS_7 = "Freunde",
		KF_SETTINGS_8 = "FrieAnswer für friendsnds               /kr =",
		KF_SETTINGS_9 = "Gilde",
		KF_SETTINGS_10 = "Gilde 1               /kg1 =",
		KF_SETTINGS_11 = "Gilde 2               /kg2 =",
		KF_SETTINGS_12 = "Gilde 3               /kg3 =",
		KF_SETTINGS_13 = "Gilde 4               /kg4 =",
		KF_SETTINGS_14 = "Gilde 5               /kg5 =",
		KF_SETTINGS_15 = "Drücken Sie die Taste, um Ihre Auswahl zu bestätigen",
		KF_SETTINGS_16 = "Bestätigen",
		KF_SETTINGS_17 = "Mail-Symbol anzeigen",
		KF_TRAVEL_1 = "Anzeige der Reisekosten",
		KF_TRAVEL_2 = "Anzeige der Reisekosten oder nicht",
		KF_STATS_4 = "Erfahrung",
	
		KF_TIME_PLAYED_1 = "Gespielte Zeit anzeigen",
		KF_TIME_PLAYED_2 = "Zeigen Sie Ihre Gesamtzeit an",
		KF_TIME_PLAYED_3 = " tag(s)",
		KF_TIME_PLAYED_4 = " stunde(n)",
		KF_TIME_PLAYED_5 = " minute(n)",
		KF_TIME_PLAYED_6 = " sekunde(n)",
		KF_TIME_PLAYED_7 = "Gold gewonnen anzeigen",
		KF_TIME_PLAYED_8 = "Gold gewann für die Session und Gold pro Stunde",

		KF_TIME_PLAYED_9_1 = "Gold pro Stunde",
		KF_TIME_PLAYED_9 = "Reparatur inbegriffen",
		KF_TIME_PLAYED_10 = "Inklusiv Reparaturkosten in Gold pro Stunde Gewinn",
		KF_TIME_PLAYED_11 = "Zeige den Champion Lvl",
		KF_TIME_PLAYED_12 = "Zeige den Champion Lvl oder nicht",

		KF_STATS_1 = "Statistiken",
		KF_STATS_2 = "Zurücksetzen",
		KF_STATS_3 = "Reset des Goldes pro Stunde Gewinn und Zeit gespielt",

		KF_HOUSE_1 = "Gehäuse",
		KF_HOUSE_2 = "Haupthaus",
		KF_HOUSE_3 = "Reise zum Haus",
		KF_HOUSE_4 = "Vorbereitung der Reise nach ",
		KF_HOUSE_5 = "Kann nicht nach Hause von Cyrodiil reisen",
		KF_HOUSE_6 = "ändere das Band",

		KF_SMALL_ADDON_1 = "Zaubertränkeanzeige",
		KF_SMALL_ADDON_2 = "Zeigen Sie Tränke oder Seelen außerhalb der Kaiserstadt",

		KF_THIEF_1 = "Dieb",
		KF_THIEF_2 = "Ändern Sie Ihren Namen in blinkende Warnung, wenn Gardes für Sie suchen",
		KF_THIEF_3 = "Zeigen Sie nicht die Warnung an",
		KF_THIEF_4 = "Addon Dieb",
		KF_THIEF_5 = "Schalte das Dieb-Addon ab",
		KF_THIEF_6 = "Hitze anzeigen",
		KF_THIEF_7 = "Anzeige der Bounty lvl",

		KF_DIS_START_1 = "Vollanzeige",
		KF_DIS_START_2 = "Vollständige Anzeige beim Spielstart",

		KF_DONATE_1 = "Du kannst mir kommentieren oder im Spiel Gold direkt, danke, danke !!!!",
		KF_DONATE_2 = "Spenden Sie Post",
		KF_DONATE_3 = "Geben 100 Gold",
		KF_DONATE_4 = "Geben 1000 Gold",
		KF_DONATE_5 = "Geben 10000 Gold",
		KF_DONATE_6 = "Geben 100000 Gold",
		KF_DONATE_7 = "Senden Sie einen Kommentar",

		KF_BAG_1 ="Beutelgrößenschwelle",
		KF_BAG_2 ="Platz bleibt in der Tasche für Alarm",

		KF_REPAIRCOST_1 = "Zeigen Sie die Reparaturkosten an",
		KF_REPAIRCOST_2 = "Anzeige oder nicht die Reparaturkosten",

		KF_BAGBANK_1 = "Zeigen Sie die Größe von Tasche und Bank an",
		KF_BAGBANK_2 = "Anzeige oder nicht die Größe von Tasche und Bank",

		KF_COMBAT_1 = "Anzeige im Kampf",
		KF_COMBAT_2 = "Anzeige im Kampf oder nicht",

		KF_TELVAR = "TelVar Stone Alarm",
		KF_TELVAR_1 = "Aktivierter Alarm für TelVar-Stein",
		KF_TELVAR_2 = "TelVar Stein max vor Alarm",
		KF_TELVAR_3 = "Alarmschwelle festlegen",
		KF_TELVAR_4 = "Schwellwertalarm definieren am",
		KF_ALLI_1 = "Allianz Punkte min in die Tasche zu halten",
		KF_ALLI_2 = "Allianz Punkte min in der Tasche zu halten definiert auf",
		KF_ALLI_3 = "Gutschein einlösen min in der Tasche zu behalten",
		KF_ALLI_4 = "Writ Voucher min um in der definierten Tasche zu bleiben",

		KF_MONEY_1 = "Zeigen Sie das Geld gewonnen",
		KF_MONEY_2 = "Zeige den TelVar Stein gewonnen",
		KF_MONEY_3 = "Zeige die Punkte der Allianz, die gewonnen wurden",

		KF_MOUNT_1 = "Zeigt den Stall-Timer an",
		KF_MOUNT_2 = "Zeigt die verbleibende Zeit vor dem Training an",
		KF_MOUNT_3 = "Verfügbar",
		KF_VAMP_1 = "Vampire Bite verfügbar",
		KF_VAMP_2 = "Vampire Bite verfügbar in",
		KF_VAMP_3 = "WereWolf Bite verfügbar",
		KF_VAMP_4 = "WereWolf Bite verfügbar in",

		KF_CRYSTAL_1 = "Zeige Crystal transmute",
		KF_CRYSTAL_2 = "Gutschein anzeigen",

		KF_JUNK_1 = "Items Junk verkauft",
		KF_JUNK_2 = "Keine zu verkaufenden Gegenstände",
		KF_JUNK_3 = "Junk-Artikel in der Tasche",
		KF_JUNK_4 = "Auto verkauft Junk-Artikel",
		KF_JUNK_5 = "Zeigen Sie Junk-Artikel",
		KF_JUNK_6 = "Junk-Artikel anzeigen oder nicht",
		KF_JUNK_7 = "JUNK & LOCK",
		KF_JUNK_8 = "Junk im Chat anzeigen",
		KF_JUNK_9 = "Anzeige Sperre im Chat",
		KF_JUNK_10 = "Auto-Set-Junk anzeigen",
		KF_JUNK_11 = "Anzeige loot im chat",
		KF_JUNK_12 = "wurde auf Junk UnSet gesetzt",
		KF_JUNK_13 = "wurde auf Junk gesetzt",
		KF_JUNK_14 = "wurde verschlossen",
		KF_JUNK_15 = "wurde entsperrt",

		KF_BANDEAU_1 = "Bandanzeige",
		KF_BANDEAU_2 = "DeadricAmbers anzeigen",
		KF_BANDEAU_3 = "Tränke anzeigen",
		KF_BANDEAU_4 = "Zeige SoulGems an",
		KF_BANDEAU_5 = "Zeigt WriteCrafting an",
		KF_BANDEAU_6 = "Auswahlanzeige",
		KF_BANDEAU_7 = "Zeigt Kampftränke an",
		KF_BANDEAU_8 = "Anzeige Stehlhelfer",

		KF_WRIT_HELPER_1 = "Helper-Fenster anzeigen",
		KF_WRIT_HELPER_2 = "Helper-Fenster anzeigen oder nicht anzeigen",
		KF_WRIT_HELPER_3 = "Display Write-Hilfefenster wenn Dieb-Warnung",
		KF_WRIT_HELPER_4 = "Display Write-Hilfsfenster wenn Dieb warnt oder nicht",
		KF_WRIT_HELPER_5 = "Zeigen Sie bei der Suche nach Gruppen das Hilfsfenster Write an",
		KF_WRIT_HELPER_6 = "Zeigen Sie bei der Suche nach Gruppen das Hilfsfenster Write an oder nicht",
		KF_WRIT_HELPER_7 = "Suche nach Gruppe",
		KF_WRIT_HELPER_8 = "Geschätzt",
		KF_WRIT_HELPER_9 = "Echt",

		KF_USE_BANK = "Verwenden Sie die automatische Einzahlung",

		KF_DEPOSIT_MONEY = "Automatische Einzahlung für Geld",
		KF_DEPOSIT_TELVAR = "Automatische Einzahlung für Tel Var Stone",
		KF_DEPOSIT_ALLIANCE = "Automatische Einzahlung für Allianzpunkte",
		KF_DEPOSIT_WRIT = "Automatische Einzahlung für Writ Voucher",

}