local strings = {

    -----------
    -- Menu
    GG_MENU_LE_HEADER = "Hinweise zum Ablauf von Spuren",
    GG_MENU_LE_DESC = "Hinweise werden ausgelöst, wenn der Spieler die Zone wechselt. Spuren, die innerhalb der eingestellten Anzahl von Tagen ablaufen, lösen Erinnerungen aus. Nach einer Erinnerung wird für das eingestellte Intervall pausiert.",
    GG_MENU_LE_ENABLED = "Aktiviert",
    GG_MENU_LE_ENABLED_TT = "Hinweise zum Ablauf von Spuren aktivieren?",
    GG_MENU_LE_ANNOUNCE_REMINDERS = "Erinnerungen ankündigen",
    GG_MENU_LE_ANNOUNCE_REMINDERS_TT = "Bildschirmankündigungen für Spurenablauf anzeigen?",
    GG_MENU_LE_CHAT_REMINDERS = "Chat-Erinnerungen anzeigen",
    GG_MENU_LE_CHAT_REMINDERS_TT = "Erinnerungen im Chatfenster anzeigen?",
    GG_MENU_LE_WARNING_PERIOD = "Ablaufwarnung (Tage) [1-20]",
    GG_MENU_LE_WARNING_PERIOD_TT = "Wie viele Tage vor Ablauf der Spur soll erinnert werden?",
    GG_MENU_LE_NO_WARNING_PERIOD = "Intervall ohne Erinnerung (Minuten) [1-120]",
    GG_MENU_LE_NO_WARNING_PERIOD_TT = "Das Intervall in Sekunden zwischen Erinnerungen.",
    GG_MENU_GF_HEADER = "Benachrichtigungen für Gruppensuche-Einträge",
    GG_MENU_GF_ENABLED = "Aktiviert",
    GG_MENU_GF_ENABLED_TT = "Benachrichtigungen der Gruppensuche im Chatfenster aktivieren?",
    GG_MENU_GF_CHECK_INTERVAL = "Prüfintervall der Gruppensuche (Sekunden) [5-60]",
    GG_MENU_GF_CHECK_INTERVAL_TT = "Das Intervall in Sekunden, um die Gruppensuche nach neuen Prüfungs-Einträgen zu prüfen. Minimum 5 Sekunden, Maximum 60 Sekunden.",
    GG_MENU_GF_TRIAL_HEADER = "Prüfungen für Gruppensuche-Benachrichtigungen",
    GG_MENU_GF_TRIAL_DESC = "Bitte beachten: Einträge der Gruppensuche, die mit der Option „Beliebige Prüfung“ erstellt wurden, werden ebenfalls berücksichtigt.",
    GG_MENU_GF_TRIAL_TT = "%s-Einträge der Gruppensuche einbeziehen?",
    GG_MENU_PA_HEADER = "Personal Assistant Integration",
    GG_MENU_PA_DESC = "Voraussetzungen:\n- Addons: LibCharacterKnowledge, LibPrice (und eine aktivierte Preisquelle wie TamrielTradeCentre, Master Merchant oder Arkadius' Trade Tools)\n- Ein dediziertes Personal Assistant LOOT-Profil für deinen Händler, damit überschüssige Gegenstände und Verkaufsware beim Abheben aus der Bank NICHT automatisch gelernt werden.\n\nWeiterleitungsregeln:\n1. Vom Handwerker unbekannte Gegenstände → an den Handwerker senden\n2. Gegenstände mit geringem Wert werden gemäß LibCharacterKnowledge an den nächsten Charakter zum Lernen weitergeleitet\n3. Überschüssige und hochwertige Verkaufsgegenstände werden an den Händler gesendet (falls aktiviert), andernfalls verbleiben sie in der Bank.",
    GG_MENU_PA_ENABLED = "Aktiviert?",
    GG_MENU_PA_ENABLED_TT = "Ist die Personal Assistant-Übersteuerung aktiviert? Das Deaktivieren erfordert ein Neuladen der Benutzeroberfläche.",
    GG_MENU_PA_SALE_VALUE_THRESHOLD = "Verkaufswert-Schwelle",
    GG_MENU_PA_SALE_VALUE_THRESHOLD_TT = "Gegenstände mit einem Verkaufswert unter oder gleich dieser Schwelle gelten als geringwertig.",
    GG_MENU_PA_CRAFTER_CHARACTER_NAME = "Name des Handwerkers",
    GG_MENU_PA_CRAFTER_CHARACTER_NAME_TT = "Name des Charakters, der als Handwerker fungiert.",
    GG_MENU_PA_TRADER_CHARACTER_NAME = "Name des Händlers",
    GG_MENU_PA_TRADER_CHARACTER_NAME_TT = "Name des Charakters, der als Händler fungiert.",
    GG_MENU_PA_WITHDRAW_TO_TRADER_ENABLED = "An Händler abheben aktiviert?",
    GG_MENU_PA_WITHDRAW_TO_TRADER_ENABLED_TT = "Überschüssige Gegenstände werden aus der Bank an den Händler übertragen.",

    -----------
    -- core
    GG_LAM_NOT_FOUND = "LibAddonMenu2 nicht gefunden, Menü kann nicht erstellt werden.",
    GG_CHARACTERS = "Charaktere",
    GG_SHOW_WINDOW = "Fenster anzeigen",
    GG_TOGGLE_LOCATION_TRACKER = "Standortwechsel-Tracker umschalten",
    GG_REMAINING = " Verbleibend",
    GG_ELAPSED = " Vergangen",

    -----------
    -- Lead Expiry
    GG_LE_NEW_LEAD = "Unentdeckte/Neue Spur",
    GG_LE_LEAD = "Spur",
    GG_LE_LORE_LEAD = "Unvollständige Kodex-/Lore-Spur",
    GG_LE_EXPIRY_IN = " Ablauf in ",
    GG_LE_EXPIRING_IN = "Spur läuft ab in ",
    GG_LE_FOUND_IN = " gefunden in ",
    GG_LE_UNKNOWN_NAME = "Unbekannte Spur",
    GG_LE_UNKNOWN_ZONE = "Unbekannte Zone",
    GG_LE_REMIND = "ERIN.",
    GG_LE_IGNORE = "IGN.",
    GG_LE_DISABLE_REMINDER = "Erinnerung deaktivieren",
    GG_LE_ENABLE_REMINDER = "Erinnerung aktivieren",
    GG_LE_TOGGLE_REMINDER = "Erinnerung umschalten",

    -----------
    -- Group Finder
    GG_GF_NEW_LISTING = "Neuer Eintrag",
    GG_GF_UPDATED_LISTING = "Aktualisierter Eintrag",
    GG_GF_REMOVED_LISTING = "Entfernter Eintrag",
    GG_GF_NO_LISTING = "Gruppensuche: |cff0000Keine Einträge gefunden.|r Es wird benachrichtigt, sobald einer gefunden wird.",

    -----------
    -- Location Change
    GG_LOCATION_CHANGED = "Standort geändert",
    GG_LOCATION_ENABLED = "Standortwechsel-Tracker aktiviert",
    GG_LOCATION_DISABLED = "Standortwechsel-Tracker deaktiviert",

    -----------
    -- Night Market
    GG_NM_MENU_ELMS_GUIDANCE_HEADER = "Questziel-Hinweise (Nachtmarkt)",
    GG_NM_MENU_BLUE_MARKERS = "Blaue Marker zeigen einen möglichen Queststart-Ort an.",
    GG_NM_MENU_GREEN_MARKERS = "Grüne Marker zeigen einen möglichen Questziel-Ort an.",
    GG_NM_MENU_NOTE_ON_ELMS = "Hinweis: Du musst ElmsMarkers installiert und aktiviert haben, damit diese Marker erscheinen.",
    GG_NM_MENU_QUEST_LIST_HDR = "Die Zahlen entsprechen folgenden Quests.",
    GG_NM_MENU_HIDE_TRACKER = "Fraktionspunkte-Tracker ausblenden",
    GG_NM_MENU_HIDE_TRACKER_TT = "Blendet die Fraktionspunkte des Nachtmarkts auf dem Bildschirm aus.",
    GG_NM_MENU_ELMS_ENABLE = "ElmsMarkers-Injektion aktivieren?",
    GG_NM_MENU_ELMS_ENABLE_TT = "Fügt 3D-Marker in ElmsMarkers für die Nachtmarkt-Quests hinzu.",
    GG_NM_GROUP_AUTO = "Argent-Gruppenautomation",
    GG_NM_GROUP_AUTO_OFF = "AUS",
    GG_NM_GROUP_AUTO_ON = "AN",
    GG_NM_GROUP_AUTO_ERROR_NOTINZONE = "Nicht in der Event-Zone",
    GG_NM_GROUP_AUTO_ERROR_ZONENOTACTIVE = "Event-Zone nicht aktiv",
    GG_NM_GROUP_AUTO_ERROR_FAILEDTWICE = "Gruppensuche-Erstellung zweimal fehlgeschlagen",
    GG_NM_GROUP_AUTO_ALLDONE = "Alle Schlüssel erhalten",
    GG_NM_GROUP_AUTO_LISTINGREMOVED = "Eintrag entfernt",
    GG_NM_GROUP_AUTO_QUESTSHARE1 = "Geteilt",
    GG_NM_GROUP_AUTO_QUESTSHARE2 = "Quest(s) mit der Gruppe.",
    GG_NM_GROUP_AUTOMATION_KEYBIND = "Argent-Gruppenautomation umschalten",


    -----------
    -- Time
    GG_TIME_SECONDS = "Sekunden",
    GG_TIME_MINUTES = "Minuten",
    GG_TIME_HOURS = "Stunden",
    GG_TIME_DAYS = "Tage",
    GG_TIME_NONE = "Keine",

}

for id, val in pairs(strings) do
   ZO_CreateStringId(id, val)
   SafeAddVersion(id, 1)
end
