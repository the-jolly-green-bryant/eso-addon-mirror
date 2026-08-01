--[[ Copyrigt
    Translated into German by Ypselon from ESOUI;
--]]

-- Every variable must start with this addon's unique ID, as each is a global.
local localization_strings = {
    --Main Window
    --Labels
    SI_SGL_MW_CURRECTGOLD = "Aktuelles Gold: %s",
    SI_SGL_MW_SESSIONGOLD = "Sitzungs-Gold: %s",
    SI_SGL_MW_DAYGOLD = "Tages-Gold: %s",
    SI_SGL_MW_LASTUPDTIME = "Letzte Aktualisierung: %s",
	SI_SGL_MW_SWITCH_TLOG = "Protokolle",
    SI_SGL_MW_SWITCH_DAYS = "Tage",
    SI_SGL_MW_BUTTON_BANK = "Bank",
    -- Settings
    SI_SGL_SETTINGS_CATEGORY_GENERAL = "ALLGEMEIN",
    SI_SGL_SETTINGS_CATEGORY_LIMITS = "Transaktionslimits",
    SI_SGL_SETTINGS_CATEGORY_LIMITS_TP = "Transaktionsprotokollgrenzen festlegen",
    SI_SGL_SETTINGS_WARNING_UNSTABLE = "Diese Funktion ist instabil!",


    SI_SGL_SETTINGS_OPTIONS_UNDEFINED_MSG = "Über unbekannte Gründe im Chat benachrichtigen.",
    SI_SGL_SETTINGS_OPTIONS_UNDEFINED_MSG_TP = "Empfohlen! \nMeldet im Chat, wenn der Grund für die Transaktion dem Addon unbekannt ist. Wir empfehlen, diese Option zu aktivieren. Dies wird helfen, unbekannte Ursachen zu finden und das Addon zu verbessern. Wenn Sie einen solchen Grund finden, dann teilen Sie dem Autor die Grundnummer mit und was den Grund verursacht hat.",

    SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION = "Letzte Transaktion stapeln",
    SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION_TP = "Staple die Transaktion mit der letzten, wenn der Grund derselbe ist",
    SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION_TIMECHECK = "Erzeuge einen neuen Eintrag in der Zeit darunter",
    SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION_TIMECHECK_TP = "Der Datensatz stapelt nicht, wenn die unten angegebene Zeit abgelaufen ist.",
    SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION_TIMECHECK_SLIDERNAME = "Datensatz-Alterungszeit (in Sekunden)",
    SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION_TIMECHECK_SLIDERNAME_TP = "Die Zeit, nach der die Aufzeichnung veraltet und eine neue anstelle des Stapels der alten Aufzeichnung angelegt wird.",
    SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION_TIMECHECK_COUNTTIME = "Zeit nur ab dem Zeitpunkt der Erstellung zählen",
    SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION_TIMECHECK_COUNTTIME_TP = "Ab welchem Moment soll die Zeit gezählt werden, die der Datensatz abgelaufen ist: \nON - Nur ab dem Zeitpunkt der Erstellung des Datensatzes \nOFF - Nach jeder Datensatzaktualisierung",

    SI_SGL_SETTINGS_OPTIONS_HIDECURGOLD = "Aktuelles Gold ausblenden",
    SI_SGL_SETTINGS_OPTIONS_HIDECURGOLD_TP = "Blendet die Goldmenge aus dem Addon-Fenster aus.",

    SI_SGL_SETTINGS_OPTIONS_HIDEBANKBUTTON = "Bank-Schaltfläche ausblenden",
    SI_SGL_SETTINGS_OPTIONS_HIDEBANKBUTTON_TP = "Blenden Sie die Bank-Schaltfläche aus dem Addon-Fenster aus.\nHinweis: Aktivieren Sie diese Option, wenn Sie keine tagesgenaue Statistik in der Bank verwenden.\nBeachten Sie, dass die tagesgenaue Statistik in der Bank weiterhin funktioniert!",
    
    SI_SGL_SETTINGS_OPTIONS_AUTOOPENINBANK = "Automatisch das Addon-Fenster in der Bank öffnen", 
    SI_SGL_SETTINGS_OPTIONS_AUTOOPENINBANK_TP = "Öffnet automatisch ein Fenster in der Bank auf der Bankstatistikseite nach Tagen.",

    SI_SGL_SETTINGS_OPTIONS_SAVETRANSACTIONS = "Transaktionen sichern",
    SI_SGL_SETTINGS_OPTIONS_SAVETRANSACTIONS_TP = "Unstabil! \nSpeichert ein Protokoll Ihrer Transaktionen nach dem Neustart.",
    SI_SGL_SETTINGS_OPTIONS_SAVETRANSACTIONS_SLIDERNAME = "Letzte Transaktionen speichern",
    SI_SGL_SETTINGS_OPTIONS_SAVETRANSACTIONS_SLIDERNAME_TP = "Gibt an, wie viele aktuelle Transaktionen aufbewahrt werden sollen. Es wird nicht empfohlen, mehr als 20 Transaktionen zu speichern.",

    SI_SGL_SETTINGS_OPTIONS_TLIMITS_ENABLE = "Transaktionslimits einschalten",
    SI_SGL_SETTINGS_OPTIONS_TLIMITS_SLIDERNAME = "Mindestbetrag für das Protokoll",
    SI_SGL_SETTINGS_OPTIONS_TLIMITS_SLIDERNAME_TP = "Wenn der Transaktionswert kleiner als der angegebene Betrag ist, dann wird die Transaktion nicht protokolliert. \n(Nur für gewinnbringende Transaktionen. Verluste werden ebenfalls berücksichtigt)",

    SI_SGL_SETTINGS_CATEGORY_DEBUG = "DEBUG",
    SI_SGL_SETTINGS_CATEGORY_DEBUG_TP = "Diverse Einstellungen, die der Benutzer nicht benötigt.",

    -- Settings - DEBUG
    SI_SGL_SETTINGS_CATEGORY_DEBUG_MESSAGES = "Debug-Meldungen einschalten",
    SI_SGL_SETTINGS_CATEGORY_DEBUG_MESSAGES_TP = "Debug-Addon-Meldungen im Chat einbeziehen",
    SI_SGL_SETTINGS_CATEGORY_DEBUG_GREETING = "Willkommensnachricht im Chat beim Start",
    SI_SGL_SETTINGS_CATEGORY_DEBUG_GREETING_TP = "Soll ich eine Nachricht über den erfolgreichen Upload des Addons an den Chat senden?",
    SI_SGL_SETTINGS_CATEGORY_DEBUG_AOGUI = "Öffnen des Addon-Fensters beim Starten",
    SI_SGL_SETTINGS_CATEGORY_DEBUG_AOGUI_TP = "Beim Laden der Oberfläche automatisch das Addon-Fenster öffnen",

    --Legacy
    SI_SGL_SETTINGS_CATEGORY_DEBUG_LEGACY_OLDBUTTONS = "Alte Art der Navigation",
    SI_SGL_SETTINGS_CATEGORY_DEBUG_LEGACY_OLDBUTTONS_TP = "Alte Art der Schaltflächendarstellung aktivieren (Nicht stabil!)\n\nBenötigt ein Neuladen der UI!",
    -- Keybindings.
    SI_BINDING_NAME_SteelswordGoldLogger_DISPLAY = "Zeige Steelsword Gold Logger",

    --Warning Messages
    SI_SGL_WARNINGMESSAGE_BANKUPD = "Einzahlung/Abhebung von Gold bei der Bank zur Aktualisierung",
    
    -- DEBUG
    SI_SGL_DEBUG_MESSAGE = "Aktive DEBUG-Meldungen Addon Steelsword Gold Logger. Sie können sie in den Addon-Einstellungen ausschalten.",
	
    -- GOLD REASON
    SI_SGL_GUPD_REASON_UNDEFINED = "Undefinierter Grund",
    SI_SGL_GUPD_REASON_UNDEFINED_MSG = "Grund %s undefiniert. Bitte informieren Sie den Autor!",
    SI_SGL_GUPD_REASON_0 = "Aus Truhe geplündert",
    SI_SGL_GUPD_REASON_1 = "Händler",
    SI_SGL_GUPD_REASON_2 = "Post",
    SI_SGL_GUPD_REASON_3 = "Handel",
    SI_SGL_GUPD_REASON_4 = "Questbelohnung",
    SI_SGL_GUPD_REASON_5 = "Bezahlter NPC",
    SI_SGL_GUPD_REASON_8 = "Rucksack erweitern",
    SI_SGL_GUPD_REASON_9 = "Bank erweitern",
    SI_SGL_GUPD_REASON_11 = "Beute aus Ausgrabung",
    SI_SGL_GUPD_REASON_13 = "Von Feinden geplündert",
    SI_SGL_GUPD_REASON_19 = "Wegschrein-Reisen",
    SI_SGL_GUPD_REASON_21 = "Schlachtfelder",
    SI_SGL_GUPD_REASON_24 = "Ausrüstungsstation",
    SI_SGL_GUPD_REASON_27 = "Level-Belohnung",
    SI_SGL_GUPD_REASON_28 = "Reittier-Aufrüstung",
    SI_SGL_GUPD_REASON_29 = "Gegenstände reparieren",
    SI_SGL_GUPD_REASON_31 = "Im Gildenladen kaufen",
    SI_SGL_GUPD_REASON_32 = "Im Gildenladen kaufen (Rückerstattung)",
    SI_SGL_GUPD_REASON_33 = "Gildenladen-Beitrag",
    SI_SGL_GUPD_REASON_42 = "In die Bank eingezahlt",
    SI_SGL_GUPD_REASON_43 = "Von der Bank abgehoben",
    SI_SGL_GUPD_REASON_44 = "Fähigkeiten zurückgesetzt",
    SI_SGL_GUPD_REASON_45 = "Eigenschaftspunkte zurückgesetzt",
    SI_SGL_GUPD_REASON_47 = "Zahlung der Strafe",
    SI_SGL_GUPD_REASON_50 = "Kauf eines Gildenwappens",
    SI_SGL_GUPD_REASON_51 = "In die Gildenbank eingezahlt",
    SI_SGL_GUPD_REASON_52 = "Von der Gildenbank abgehoben",
    SI_SGL_GUPD_REASON_55 = "Skills Respec",
    SI_SGL_GUPD_REASON_56 = "Zahlung der Strafe (Zuflucht)",
    SI_SGL_GUPD_REASON_57 = "Zahlung der Strafe (Tot)",
    SI_SGL_GUPD_REASON_60 = "Gegenstände (Hehler)",
    SI_SGL_GUPD_REASON_61 = "CP zurücksetzen",
    SI_SGL_GUPD_REASON_62 = "Aus Diebestruhe geplündert",
    SI_SGL_GUPD_REASON_63 = "Verkauf von Gestohlenem",
    SI_SGL_GUPD_REASON_64 = "Aufkauf im Handel",

    --Other
    SI_SGL_INFO_WEBSITE = "https://www.esoui.com/downloads/info2668-SteelswordGoldLogger.html",
}

for stringId, stringValue in pairs(localization_strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end