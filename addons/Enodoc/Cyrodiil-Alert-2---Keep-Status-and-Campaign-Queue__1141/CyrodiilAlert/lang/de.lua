-- This file is part of CyrodiilAlert
ZO_CreateStringId("SI_CYRODIIL_ALERT", "CyrodiilAlert")
ZO_CreateStringId("SI_CYRODIIL_ALERT_LANG", "de")

--- CyrodiilAlert.lua

-- InitKeeps
ZO_CreateStringId("SI_CYRODIIL_ALERT_INIT_TEXT", 			"Cyrodiil Alert Initialisierung")
ZO_CreateStringId("SI_CYRODIIL_ALERT_CAMP_WELCOME", 		"Willkommen in <<!AC:1>>!")
ZO_CreateStringId("SI_CYRODIIL_ALERT_CAMP_HOME", 			"Heimatkampagne: <<!AC:1>>")
ZO_CreateStringId("SI_CYRODIIL_ALERT_CURRENT_IMPERIAL", 	"Du hast Zugang zur Kaiserstadt")
ZO_CreateStringId("SI_CYRODIIL_ALERT_DO_NOT_HAVE_IMPERIAL", "Du hast keinen Zugang zur Kaiserstadt")
ZO_CreateStringId("SI_CYRODIIL_ALERT_OUTSIDE_CYRODIIL", 	"Meldungen ausserhalb Cyrodiil deaktiviert")
ZO_CreateStringId("SI_CYRODIIL_ALERT_CHAT_OUTPUT_ON", 		"Ausgabe in Chat ist aktiviert")
ZO_CreateStringId("SI_CYRODIIL_ALERT_CHAT_OUTPUT_OFF", 		"Ausgabe in Chat ist deaktiviert")
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_ON", 		"On-Screen Meldungen sind aktiviert")
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_OFF", 	"On-Screen Meldungen sind deaktiviert")

-- DumpChat
ZO_CreateStringId("SI_CYRODIIL_ALERT_STATUS_TEXT", 	"Cyrodiil Status:")
ZO_CreateStringId("SI_CYRODIIL_ALERT_UNDER_ATTACK", "Wird angegriffen!")
ZO_CreateStringId("SI_CYRODIIL_ALERT_NO_ATTACK", 	"Es wird keine Burg angegriffen")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SIEGES_A", 	" Belagerungswaffen Ang: ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SLASH_D", 		" / Ver: ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SIEGES_ATT", 	" Belagerungswaffen: Ang: ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SLASH_DEF", 	" / Ver: ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SIEGES_AD", 	" Belagerungswaffen AD: ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_DC", 			", DC: ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_EP", 			", EP: ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SIEGES_NONE", 	" keine Belagerungswaffen")

-- dumpImperial
ZO_CreateStringId("SI_CYRODIIL_ALERT_IMPERIAL_CITY", 				"Kaiserstadt:")
ZO_CreateStringId("SI_CYRODIIL_ALERT_NO_DISTRICT_UNDER_ATTACK", 	"     Es werden keine Bezirke angegriffen")
ZO_CreateStringId("SI_CYRODIIL_ALERT_AD_NAME", 						"Aldmeri Dominion ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_UNLOCKED", 					"geöffnet")
ZO_CreateStringId("SI_CYRODIIL_ALERT_KEEP_CONTROLLED", 				", kontrollierte Burgen: ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_OF", 							" von ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_LOCKED", 						"gesperrt")
ZO_CreateStringId("SI_CYRODIIL_ALERT_EP_NAME", 						"Ebenherz Pakt ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_DC_NAME", 						"Dolchsturz Bündnis ")

-- dumpDistricts
ZO_CreateStringId("SI_CYRODIIL_ALERT_IMPERIAL_DISTRICTS", 	"Kaiserliche Bezirke:")
ZO_CreateStringId("SI_CYRODIIL_ALERT_DISTRICTS", 			" Bezirke: ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_TEL_VAR_BONUS", 		"Tel Var Bonus")

-- CampaignQueue
ZO_CreateStringId("SI_CYRODIIL_ALERT_IS_GROUP", 		" (Gruppe)")
ZO_CreateStringId("SI_CYRODIIL_ALERT_IS_SOLO", 			" (Alleine)")
ZO_CreateStringId("SI_CYRODIIL_ALERT_QUEUE_POSITION", 	"<<!AC:1>> Warteschlangen Position: <<!AC:2>> <<!AC:3>>")
ZO_CreateStringId("SI_CYRODIIL_ALERT_QUEUE_READY", 		"<<!AC:1>> Kampagne ist bereit <<!AC:2>>")

-- OnAllianceOwnerChanged
ZO_CreateStringId("SI_CYRODIIL_ALERT_HAS_CAPTURED", 		"<<!AC:2>> erobert <<!AC:1>>") -- hier nicht möglich
ZO_CreateStringId("SI_CYRODIIL_ALERT_IN_DISTRICTS_TOTAL", 	"<<!AC:1>> <<!AC:2>> |t16:16:<<X:3>>|t in Bezirk  (Total <<!AC:4>>)")
ZO_CreateStringId("SI_CYRODIIL_ALERT_IN_DISTRICTS_TOTAL2", 	"<<!AC:1>> <<!AC:2>> |t30:30:<<X:3>>|t in Bezirk  (Total <<!AC:4>>)")

-- OnKeepUnderAttackChanged
ZO_CreateStringId("SI_CYRODIIL_ALERT_IS_UNDER_ATTACK", 				"<<!AC:1>> wird angegriffen!")
ZO_CreateStringId("SI_CYRODIIL_ALERT_IS_NO_LONGER_UNDER_ATTACK", 	"<<!AC:1>> wird nicht länger angegriffen")

-- OnGateChanged
ZO_CreateStringId("SI_CYRODIIL_ALERT_THE", 			"Das ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_IS_OPEN", 		"Das <<!AC:1>> ist geöffnet!")
ZO_CreateStringId("SI_CYRODIIL_ALERT_IS_CLOSED", 	"Das <<!AC:1>> ist geschlossen!")

-- OnDeposeEmperor
ZO_CreateStringId("SI_CYRODIIL_ALERT_EMPEROR", 		"Kaiser ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ABDICATED", 	"<<!AC:1>> Kaiser <<!AC:3>> von <<!AC:2>> hat abgedankt!")
ZO_CreateStringId("SI_CYRODIIL_ALERT_DEPOSED", 		"<<!AC:1>> Kaiser <<!AC:3>> von <<!AC:2>> wurde gestürzt!")

-- OnCoronateEmperor
ZO_CreateStringId("SI_CYRODIIL_ALERT_CROWNED_EMPEROR", "<<!AC:1>> <<!AC:3>> von <<!AC:2>> wurde zum Kaiser gekrönt!")

-- OnArtifactControlState
ZO_CreateStringId("SI_CYRODIIL_ALERT_PICKED_UP", 		"<<!AC:1>> <<!AC:3>> von <<!AC:2>> hat <<!AC:4>> aufgenommen")
ZO_CreateStringId("SI_CYRODIIL_ALERT_HAS_TAKEN", 		"<<!AC:1>> <<!AC:3>> von <<!AC:2>> hat <<!AC:5>> von <<!AC:4>> aufgenommen")
ZO_CreateStringId("SI_CYRODIIL_ALERT_FROM", 			" von ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_HAS_DROPPED", 		"<<!AC:1>> <<!AC:3>> von <<!AC:2>> liess <<!AC:4>> fallen")
ZO_CreateStringId("SI_CYRODIIL_ALERT_HAS_SECURED", 		"<<!AC:1>> <<!AC:3>> von <<!AC:2>> hat <<!AC:5>> gesichtert bei <<!AC:4>>")
ZO_CreateStringId("SI_CYRODIIL_ALERT_AT", 				" bei ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_HAS_RETURNED", 	"<<!AC:1>> <<!AC:3>> von <<!AC:2>> hat <<!AC:4>> zu <<!AC:5>> zurückgebracht")
ZO_CreateStringId("SI_CYRODIIL_ALERT_TO", 				" zu ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_HAS_RETURNED_TO", 	" ging zurück an ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_TIMEOUT", 			"<<!AC:1>> <<!AC:2>> ging zurück an <<!AC:3>> (timed out)")

-- OnObjectiveControlState
ZO_CreateStringId("SI_CYRODIIL_ALERT_HAS_RECAPTURED", "<<!AC:1>> wurde zurückerobert von <<!AC:2>>")
ZO_CreateStringId("SI_CYRODIIL_ALERT_HAS_FALLEN", "<<!AC:1>> gefallen und gehört neu <<!AC:2>>")
ZO_CreateStringId("SI_CYRODIIL_ALERT_NO_CONTROL", "Niemandem")

-- OnClaimKeep
ZO_CreateStringId("SI_CYRODIIL_ALERT_HAS_CLAIMED", "<<!AC:1>> <<!AC:2>> beanspruchte <<!AC:4>> für <<!AC:3>>")
ZO_CreateStringId("SI_CYRODIIL_ALERT_FOR", " für ")

-- OnImperialAccessGained
ZO_CreateStringId("SI_CYRODIIL_ALERT_IMPERIAL_CITY2", "Kaiserstadt")
ZO_CreateStringId("SI_CYRODIIL_ALERT_HAS_GAINED_ACCESS", "<<!AC:1>> <<!AC:2>> hat den Zugriff zu <<!AC:3>> bekommen!")

-- OnImperialAccessLost
ZO_CreateStringId("SI_CYRODIIL_ALERT_HAS_LOST_ACCESS", "<<!AC:1>> <<!AC:2>> hat den Zugriff zu <<!AC:3>> verloren")

-- CAslash
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_OUTSIDE_OFF", "Die Meldungen ausserhalb von Cyrodiil sind ausgeschalten.")
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_OUTSIDE_ON", "Die Meldungen ausserhalb von Cyrodiil sind eingeschalten.")
ZO_CreateStringId("SI_CYRODIIL_ALERT_HELP", "Verfügbare Slash-Befehle: show, hide, status, attacks, imperial, ic, init, out, clear, help\nz.B. /status")



--- CyrodiilAlertConfig.lua
ZO_CreateStringId("SI_CYRODIIL_ALERT_DISPLAY_NAME", "Cyrodiil Alert 2")
ZO_CreateStringId("SI_CYRODIIL_ALERT_CONFIG", "Einstellungen")
ZO_CreateStringId("SI_CYRODIIL_ALERT_GENERAL_OPTIONS", "Allgemeines")

-- Notification Delay
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_DELAY_NAME", "Meldungen Anzeige")
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_DELAY_TOOLTIP", "Gibt an, wieviele Sekunden die Meldung erscheint, bevor sie ausgeblendet wird")

-- Output to chat
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_OUTPUT_CHAT_NAME", "Chat Ausgabe")
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_OUTPUT_CHAT_TOOLTIP", "Wenn aktiv, werden die Meldungen auch im Chatfenster ausgegeben")

-- On-Screen Notifications
ZO_CreateStringId("SI_CYRODIIL_ALERT_ON_SCREEN_NOTIFICATION_NAME", "On-Screen Meldungen")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ON_SCREEN_NOTIFICATION_TOOLTIP", "Deaktiviert: Es erscheinen keine On-Screen Meldungen. In Kombination mit der \'Chat Ausgabe\' aktiv, können Meldungen nur im Chat angezeigt werden.\nESO UI: Zeigt die Meldungen in der originalen On-Screen Meldung\nCA UI: Zeigt die Meldungen im CyrodiilAlert's Fenster")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ON_SCREEN_NOTIFICATION_DISABLED", "deaktiviert")

-- Sound
ZO_CreateStringId("SI_CYRODIIL_ALERT_SOUND_NAME", "Audio Meldung")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SOUND_TOOLTIP", "Aktiviert die Audiomeldung sofern du die originale ESO UI verwendest")

-- Enable Notifications inside IC
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_NOTIFICATION_INSIDE_IC_NAME", "Aktiviere Meldungen innerhalb der Kaiserstadt")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_NOTIFICATION_INSIDE_IC_TOOLTIP", "Du wirst innerhalb der Kaiserstadt Meldungen bekommen")

-- Enable Notifications outside Cyrodiil
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_NOTIFICATION_OUTSIDE_CY_NAME", "Aktiviere Meldungen ausserhalb Cyrodiil")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_NOTIFICATION_OUTSIDE_CY_TOOLTIP", "Du wirst auch ausserhalb von Cyrodiil Meldungen bekommen")

-- Disable default eso notifications
ZO_CreateStringId("SI_CYRODIIL_ALERT_DISABLE_DEFAULT_NOTIFICATION_NAME", "Deaktiviere Standard ESO Meldungen")
ZO_CreateStringId("SI_CYRODIIL_ALERT_DISABLE_DEFAULT_NOTIFICATION_TOOLTIP", "Du wirst die Standard Einblendung von Toren, Kaiserkrönung, etc. nicht bekommen.  Sie werden stattdessen im CA Stil angezeigt.")
ZO_CreateStringId("SI_CYRODIIL_ALERT_DISABLE_DEFAULT_NOTIFICATION_WARNING", "Überschreibt die individuellen Einstellung für diese Meldungen wenn \'AUS\'")
ZO_CreateStringId("SI_CYRODIIL_ALERT_DISABLE_DEFAULT_NOTIFICATION_OVERRIDE", "Überschreibt mit den Standard Einstellungen, sofern diese nicht deaktiviert sind.")

-- Disable default notification outside cyrodiil
ZO_CreateStringId("SI_CYRODIIL_ALERT_DISABLE_DEFAULT_NOTIFICATION_OUTSIDE_CY_NAME", "     Standard Meldungen ausserhalb Cyrodiil")
ZO_CreateStringId("SI_CYRODIIL_ALERT_DISABLE_DEFAULT_NOTIFICATION_OUTSIDE_CY_TOOLTIP", "Deaktiviert die Standard Meldungen ausserhalb von Cyrodiil, auch wenn die CA Meldungen deaktiviert sind")

-- Redirect default notification to chat
ZO_CreateStringId("SI_CYRODIIL_ALERT_REDIRECT_DEFAULT_NOTIFICATION_TO_CHAT_NAME", "     Leitet die Standard Meldungen zum Chat um")
ZO_CreateStringId("SI_CYRODIIL_ALERT_REDIRECT_DEFAULT_NOTIFICATION_TO_CHAT_TOOLTIP", "Die Standard Meldungen werden im Chat angezeigt")

-- Show initialization message
ZO_CreateStringId("SI_CYRODIIL_ALERT_REDIRECT_SHOW_INIT_MESSAGE_NAME", "Zeige Initialisierungsnachricht")
ZO_CreateStringId("SI_CYRODIIL_ALERT_REDIRECT_SHOW_INIT_MESSAGE_TOOLTIP", "Wenn du Cyrodiil betritts, zeigt es dir den Kampagnenname, aktuelle besitzende Burgen, Zugang zur Kaiserstadt und den Status der Bezirke in der Kaiserstadt an.")

-- Show keep status initialization message
ZO_CreateStringId("SI_CYRODIIL_ALERT_REDIRECT_SHOW_INIT_KEEPS_NAME", "     On-Screen Meldung wenn Burgen attackiert")
ZO_CreateStringId("SI_CYRODIIL_ALERT_REDIRECT_SHOW_INIT_KEEPS_TOOLTIP", "Beim Verwenden der ESO UI werden hier alle Burgen die attackiert werden in der On-Screen Meldung aufgelistet. (Burgen die attackiert werden werden immer im Chat ausgegeben)")

-- Use alliance colors
ZO_CreateStringId("SI_CYRODIIL_ALERT_USE_ALLIANCE_COLORS_NAME", "Benutze Allianzfarben")
ZO_CreateStringId("SI_CYRODIIL_ALERT_USE_ALLIANCE_COLORS_TOOLTIP", "Allianznamen werden in deren Farbe angezeigt; ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_USE_ALLIANCE_COLORS_AD_NAME", "Aldmeri Dominion")
ZO_CreateStringId("SI_CYRODIIL_ALERT_USE_ALLIANCE_COLORS_DC_NAME", "Dolchsturz Bündnis")
ZO_CreateStringId("SI_CYRODIIL_ALERT_USE_ALLIANCE_COLORS_EP_NAME", "Ebenherz Pakt")

-- Lock/Unlock
ZO_CreateStringId("SI_CYRODIIL_ALERT_LOCK_UNLOCK_NAME", "Sperren/Entsperren")
ZO_CreateStringId("SI_CYRODIIL_ALERT_LOCK_UNLOCK_TOOLTIP", "Sperren/Entsperren des CA Fensters")

-- Keep status
ZO_CreateStringId("SI_CYRODIIL_ALERT_KEEP_STATUS", "Status der Burg")

-- Reinitialize
ZO_CreateStringId("SI_CYRODIIL_ALERT_REINITIALIZE_TITLE", "Neuinitialisierung")
ZO_CreateStringId("SI_CYRODIIL_ALERT_REINITIALIZE_TEXT", "Auch über den Befehl \'/ca init\' möglich")

-- Update Status
ZO_CreateStringId("SI_CYRODIIL_ALERT_UPDATE_STATUS_NAME", "Aktualisiere Status")
ZO_CreateStringId("SI_CYRODIIL_ALERT_UPDATE_STATUS_TOOLTIP", "\nAktualisiere das Add-On und den Status der Burgen und Ressourcen in der aktuellen Kampagne")
ZO_CreateStringId("SI_CYRODIIL_ALERT_DUBIOUS_OUTSIDE_CY_WARNING", "verzwickte Sache ausserhalb von Cyrodiil")

-- Output status to chat
ZO_CreateStringId("SI_CYRODIIL_ALERT_OUTPUT_STATUS_TO_CHAT_TITLE", "Status Chatausgabe")
ZO_CreateStringId("SI_CYRODIIL_ALERT_OUTPUT_STATUS_TO_CHAT_TEXT", "Auch über den Befehl \'/ca attacks\' und \'/ca status\' möglich")

-- List attacks
ZO_CreateStringId("SI_CYRODIIL_ALERT_LIST_ATTACKS_NAME", "Liste Angreifer")
ZO_CreateStringId("SI_CYRODIIL_ALERT_LIST_ATTACKS_TOOLTIP", "Listet die Burgen und Ressourcen auf, die gerade angegriffen werden.")

-- List status
ZO_CreateStringId("SI_CYRODIIL_ALERT_LIST_STATUS_NAME", "Liste Status")
ZO_CreateStringId("SI_CYRODIIL_ALERT_LIST_STATUS_TOOLTIP", "Listet die Besitzer und den Angriffsstatus aller Burgen und Ressourcen auf.")

-- Imperial City
ZO_CreateStringId("SI_CYRODIIL_ALERT_IMPERIAL_CITY_TITLE", "Kaiserstadt")
ZO_CreateStringId("SI_CYRODIIL_ALERT_IMPERIAL_CITY_TEXT", "Auch verfügbar mit \'/ca ic\', \'/ca ic all\', \'/ca ic access\', oder \'/ca ic districts\'")

-- Access & Districts
ZO_CreateStringId("SI_CYRODIIL_ALERT_ACCESS_DISTRICTS_NAME", "Zugang & Bezirke")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ACCESS_DISTRICTS_TOOLTIP", "Gibt den Status zum Zugriff der Kaiserstadt aus, sowie die gerade kontrollierten Bezirke.")

-- Notification Options
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_OPTIONS_NAME", "Meldungen Einstellungen")

-- Enable Alliance Capture Notification
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_ALLIANCE_OWNER_NOTIFICATION_NAME", "Aktiviere Allianz Eroberungsnachricht")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_ALLIANCE_OWNER_NOTIFICATION_TOOLTIP", "Gibt eine Meldung aus, sobald eine Allianz ein Objekt erobert")

-- Notification Importance
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_IMPORTANCE_NAME", "     Wichtige Meldungen ESO UI")
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_IMPORTANCE_TOOLTIP", "Major: Allianz Eigentumswechsel wird als grosses Event behandelt\nMinor: Allianz Eigentumswechsel wird als kleines Event behandelt")

-- Enable Attack Notification
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_ATTACK_NOTIFICATION_NAME", "Angriffsmeldungen")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_ATTACK_NOTIFICATION_TOOLTIP", "Es erscheint eine Meldung wenn etwas angegriffen wird.")

-- Show Attack/Defence Sieges
ZO_CreateStringId("SI_CYRODIIL_ALERT_ATTACK_DEFENCE_NAME", "Belagerungswaffen Angriff/Verteidigung")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ATTACK_DEFENCE_TOOLTIP", "Zeigt die Anzahl Belagerungswaffen (Angreifer/Verteidiger)")

-- Show Sieges by Alliance
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_SIEGES_BY_ALLIANCE_NAME", "Belagerungswaffen der Allianz")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_SIEGES_BY_ALLIANCE_TOOLTIP", "Zeigt die Anzahl Belagerungswaffen der Allianz")

-- Enable Attack Ending Notifications
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_ATTACK_ENDING_NOTIFICATIONS_NAME", "Angriff Ende Meldung")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_ATTACK_ENDING_NOTIFICATIONS_TOOLTIP", "Zeigt dir an, wenn ein Angriff endet.")

-- Enable Guild Claim Notification
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_CLAIM_NOTIFICATION_NAME", "Gildenanspruch Meldung")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_CLAIM_NOTIFICATION_TOOLTIP", "Soll dir angezeigt werden, wenn jemand ein Objekt beantsprucht?")

-- Enable Emperor Notification
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_EMPEROR_NOTIFICATION_NAME", "Aktiviere Kaiser Meldungen")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_EMPEROR_NOTIFICATION_TOOLTIP", "Meldungen über den Kaiser werden angezeigt")

-- Enable Imperial City Notification
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_IC_NOTIFICATION_NAME", "Kaiserstadt Zugriff Meldungen")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_IC_NOTIFICATION_TOOLTIP", "Gibt dir Meldungen bezüglich Zugriff zur Kaiserstadt")

-- Enable Queue Notification
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_QUEUE_NOTIFICATION_NAME", "Warteschlangen Position Meldungen")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_QUEUE_NOTIFICATION_TOOLTIP", "Gibt dir eine Meldung, sobald sich dein Status in der Warteschlange ändert.")

-- Queue Ready
ZO_CreateStringId("SI_CYRODIIL_ALERT_QUEUE_READY_NAME", "Warteschlangen Status Meldungen")
ZO_CreateStringId("SI_CYRODIIL_ALERT_QUEUE_READY_TOOLTIP", "Zeigt dir eine Meldung, sobald eine Kampagne zum Beitritt bereit ist:\nMajor: Kampagne bereit wird als grosses Event angezeigt\nMinor: Kampagne bereit wird als kleines Event angezeigt\nOff: Warteschlangen Position wird nicht angezeigt")

-- Show Only My Alliance
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_ONLY_MY_ALLIANCE_NAME", "Zeige nur meine Allianz")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_ONLY_MY_ALLIANCE_TOOLTIP", "Zeigt nur die Meldungen für <<!AC:1>>")

-- Objective Options
ZO_CreateStringId("SI_CYRODIIL_ALERT_OBJECTIVE_OPTIONS_NAME", "Objekt Einstellungen")

-- Enable Town Capture Notifications
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_TOWN_CAPTURE_NOTIFICATION_NAME", "Stadt Beanspruchung Meldung aktivieren")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_TOWN_CAPTURE_NOTIFICATION_TOOLTIP", "Gibt dir eine Meldung über die Beanspruchung der Stadt.")

-- Enable District Capture Notifications
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_DISTRICT_CAPTURE_NOTIFICATION_NAME", "Bezirk Beanspruchung Meldungen aktivieren")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_DISTRICT_CAPTURE_NOTIFICATION_TOOLTIP", "Soll die Meldung einer Beanspruchung für die Bezirke aktiviert werden?")

-- Show District Capture in Cyrodiil
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_DISTRICT_CAPTURE_IN_CY_NAME", "     Zeige Meldung Bezirk Beanspruchung")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_DISTRICT_CAPTURE_IN_CY_TOOLTIP", "Gibt dir eine Meldung über die Beanspruchung eines Bezirks.")

-- Show Tel Var Capture Bonus
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_TEL_VAR_CAPTURE_BONUS_NAME", "Zeige Tel Var Bonus")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_TEL_VAR_CAPTURE_BONUS_TOOLTIP", "Zeigt die Änderung im Bezirk")

-- Enable Indiviual Flag Notifications
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_INDIVIUAL_FLAG_NOTIFICATION_NAME", "Individuelle Fahnen Meldungen aktivieren")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_INDIVIUAL_FLAG_NOTIFICATION_TOOLTIP", "Erhalte eine Meldung wenn eine Allianz eine Fahne gesichert hat.")

-- Show Resource Flags
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_RESOURCE_FLAGS_NAME", "     Fahnen Meldung Ressourcen")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_RESOURCE_FLAGS_TOOLTIP", "Fahnen Meldung über Bauernhöfe, Minen und Holzfäller Lager")

-- Show Town Flags
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_TOWN_FLAGS_NAME", "     Fahnen Meldung Stadt")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_TOWN_FLAGS_TOOLTIP", "Fahnen Meldung in der Stadt")

-- Show District Flags
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_DISTRICT_FLAGS_NAME", "     Fahnen Meldung Bezirke")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_DISTRICT_FLAGS_TOOLTIP", "Fahnen Meldung der Bezirke in der Kaiserstadt")

-- Show Flags at Neutral
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_FLAGS_AS_NEUTRAL_NAME", "     Fahnen Meldung Neutral")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_FLAGS_AS_NEUTRAL_TOOLTIP", "Fahnen Meldung wenn\n<<!AC:1>>")

-- Enable Gate Notifications
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_GATE_NOTIFICATION_NAME", "Tor Meldungen anzeigen")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_GATE_NOTIFICATION_TOOLTIP", "Meldung über Tore")

-- Enable Scroll Notifications
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_SCROLL_NOTIFICATION_NAME", "Schriftrolle Meldungen")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_SCROLL_NOTIFICATION_TOOLTIP", "Zeigt dir Meldungen über den Status der Tore")

-- Imperial City DLC
ZO_CreateStringId("SI_CYRODIIL_ALERT_IMPERIAL_CITY_STATUS", "Folgende Optionen sind nicht verfügbar. Du benötigst das DLC:")
ZO_CreateStringId("SI_CYRODIIL_ALERT_IMPERIAL_CITY_DLC_NAME", "DLC-Spielerweiterung zur Kaiserstadt")
ZO_CreateStringId("SI_CYRODIIL_ALERT_IMPERIAL_CITY_DLC_TOOLTIP", "Gibt die an, ob du das DLC zur Kaiserstadt freigeschaltet hast.")

-- Imperial City Override
ZO_CreateStringId("SI_CYRODIIL_ALERT_IMPERIAL_CITY_OVERRIDE_NAME", "ausser Kraft setzen")
ZO_CreateStringId("SI_CYRODIIL_ALERT_IMPERIAL_CITY_OVERRIDE_TOOLTIP", "Deaktiviert temporär den Status zum Kaiserstadt DLC, damit du die Optionen anpassen kannst. Dieses bleibt bestehen, bis die Benutzeroberfläche neu geladen wird.")