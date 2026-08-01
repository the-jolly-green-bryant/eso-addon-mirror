Reminderz = Reminderz or {}

local localization = {

    LOADED_STR = "%s %s %s",
    WAS_LOADED = "geladen",
    NOT_LOADED = "nicht geladen",

    DAILY_RESET = "Die tägliche Rückstellung ist in %s",
    TURN_IN = "Gebt PvP-Quests ab, erledigt Eure Aufgaben und Schriebe.",
    RESET_IS_NOW = "Die tägliche Rückstellung ist soeben erfolgt",
    NO_FOOD_1 = "Keine Buff-Nahrung aktiv!",
    NO_FOOD_2 = "Esst etwas!",
    FOOD_RUNNING_OUT = "%s wird in %s aufgebraucht sein",
    NO_MAYHEM = "%s ist beendet. Verwendet die Schriftrolle erneut!",
    LOW_BAG_SPACE = "Euer Inventar ist nahezu voll!",
    NO_BAG_SPACE = "Euer Inventar ist voll!",
    GEAR_MISSING = "Überprüft Eure Rüstung und Waffen! Es fehlt etwas!",
    ARMOR_MISSING = "Mindestens ein Rüstungsteil ist nicht ausgerüstet!",
    JEWELRY_MISSING = "Mindestens ein Schmuckstück ist nicht ausgerüstet!",
    WEAPON_MISSING = " fehlt eine Waffe!",
    MAIN_HAND = "Eurer Haupthand",
    OFF_HAND = "Eurer Nebenhand",
    BACKUP = " Backup",
    IS_ENDING = "%s endet in %s",
    GO_FEED = "Ihr befindet Euch auf %s. Nährt Euch!",
    VAMP_TOO_HIGH = "Vampirismus-Erinnerung: aktuelle Stufe > gewünschte Stufe",
    NO_XP_SCROLL = "Es ist keine EP-Schriftrolle aktiv!",
    XP_SCROLL_ENDING = "Eure EP-Schriftrolle endet in %s",
    TELVAR_CAP_REACHED = "Ihr tragt %d Tel'Var-Steine bei euch. Ihr solltet sie in die Bank legen!",
    RESERVE_TOO_HIGH = "Tel'Var-Reserveanzahl zu hoch. Automatische Deponierung aller mitgeführten Tel'Var-Steine.",
    TELVAR_DEPOSITED = "%d Tel'Var-Steine automatisch in die Bank eingezahlt.",
    WAR_TORTES_MISSING = "Es ist keine Kriegstorte aktiv!",
    WAR_TORTES_RUNNING_OUT = "Eure Kriegstorte endet in %s",
    ACHIEVEMENT_PROGRESS = "Fortschritt: (%s/%s)",
    ACHIEVEMENT_AWARDED = "Erfolg ABGESCHLOSSEN!",
    NO_MUNDUS = "Du hast keinen aktiven Mundusstein!",

    WARNING_RELOADUI = "Warnung: Die Benutzeroberfläche wird bei Änderungen automatisch neu geladen.",
    
    ACCTWIDE_NAME = "Kontoweite Einstellungen verwenden",
    ACCTWIDE_TOOLTIP = "Wenn diese Funktion ausgeschaltet ist, hat jeder Charakter seine eigenen Erinnerungen.",

    ALWAYS = "Immer",
    NEVER = "Niemals",
    IN_PVP = "Nur im PvP",

    REMIND_INTERVAL_NAME = "Intervall zwischen den Erinnerungen:",
    REMIND_INTERVAL_TOOLTIP = "Intervall zwischen den Erinnerungen",
    FIRST_REMINDER_NAME = "Verbleibende Zeit bis zur ersten Erinnerung:",
    FIRST_REMINDER_TOOLTIP = "Verbleibende Zeit bis zur ersten Erinnerung",
    REMIND_COLOR_NAME = "Farbe des Erinnerungstextes:",
    REMIND_COLOR_TOOLTIP = "Die Farbe dieser Erinnerungen im Chat und auf dem Bildschirm",
    REMIND_OFF_IN_HOUSES_NAME = "Keine Erinnerung während Aufenthalt in Häusern:",
    REMIND_OFF_IN_HOUSES_TOOLTIP = "Setzt diese Option auf EIN, wenn Ihr diese Erinnerung nicht wünscht, während Ihr Euch in einem Eurer Häuser aufhaltet.",
    REMIND_ONLY_IN_DUNGEONS_NAME = "PvE-Erinnerungen nur in Dungeons, Raids usw.",
    REMIND_ONLY_IN_DUNGEONS_TOOLTIP = "Auf EIN setzen, wenn du nur PvE-Erinnerungen in Dungeons, Raids usw. haben möchtest.",
    
    HEADER_GENERAL = "Allgemein",
    NAME_CHATBOX = "Erinnerungen auch im Chat-Fenster ausgeben",
    TOOLTIP_CHATBOX = "Zeigt Erinnerungen im Haupt-Chat-Tab und auf dem Bildschirm an.",
    NAME_OFFLINE = "Erinnerung bei Flüstern im Offline-Modus",
    TOOLTIP_OFFLINE = "Wenn Ihr Euren Spielerstatus auf 'Offline' setzt, werdet Ihr daran erinnert, dass die Person, mit der Ihr gerade geflüstert habt, Euch nicht antworten kann, solange Ihr Euren Status nicht ändert.",
    NAME_SUPPRESS = "Meldung 'Addon geladen' unterdrücken",
    TOOLTIP_SUPPRESS = "Unterdrückt die Meldung im Chatfenster, dass das Addon erfolgreich geladen wurde.",
    NAME_DAILY_REWARD = "Die tägliche Belohnung automatisch abholen",
    TOOLTIP_DAILY_REWARD = "Die tägliche Login-Belohnung automatisch abholen, wenn sie verfügbar ist",
    NAME_FREE_BAG_SLOTS = "Erinnerung, wenn freie Inventarplätze unter:",
    TOOLTIP_FREE_BAG_SLOTS = "Anzahl der freien Inventarplätze, bei deren Unterschreitung Ihr an den geringen Inventarplatz erinnert werdet. Null bedeutet, dass die Inventar-Erinnerung ausgeschaltet wird.",
    NAME_MISSING_GEAR = "Erinnerung bei fehlender Rüstung oder Waffen",
    TOOLTIP_MISSING_GEAR = "Erinnern wenn nicht alle Rüstungsteile und Waffen ausgerüstet sind..",
    NAME_ACHIEVEMENTS = "Alle Erfolgsfortschrittsaktualisierungen im Chatfenster anzeigen",
    TOOLTIP_ACHIEVEMENTS = "Alle Erfolgsfortschrittsaktualisierungen im Chatfenster anzeigen",
    
    HEADER_FOOD = "Nahrung",
    NAME_REMIND_FOOD = "Erinnerung aktivieren:",
    TOOLTIP_REMIND_FOOD = "Erinnern, wenn die Nahrung aufgebraucht ist, oder wann sie aufgebraucht sein wird.",
    
    HEADER_LEADS = "Antiquitäts-Spuren",
    NAME_REMIND_LEADS = "Erinnerung, wenn eine Spur in X Tagen abläuft:",
    TOOLTIP_REMIND_LEADS = "Erinnern, wenn eine Antiquitäts-Spur in X Tagen abläuft. (0 = AUS)",
    LEADS_EXPIRING_FMT_MULTI = "Mehrere Antiquitäten-Spuren",
    LEADS_EXPIRING_FMT_MULTI2 = "laufen in %s ab!",
    LEADS_EXPIRING_DAYS = "Tage",
    LEADS_EXPIRING_HOURS = "Stunden",

    HEADER_VAMPIRE = "Vampirismus Stufe",
    NAME_REMIND_VAMPIRE = "Erinnerung aktivieren:",
    TOOLTIP_REMIND_VAMPIRE = "Erinnern, wann sich die Vampirismus-Stufe ändern wird, und nachdem sie sich geändert hat.",
    NAME_REMIND_VAMP_IN_PVP = "Nur im PvP:",
    TOOLTIP_REMIND_VAMP_IN_PVP = "Wenn EIN, werden Erinnerungen nur im PvP angezeigt. Wenn AUS, werden Erinnerungen auch im PvE angezeigt..",
    
    HEADER_XP_SCROLLS = "EP-Schriftrollen & Tränke",
    NAME_XP_SCROLLS = "Erinnerung aktivieren:",
    TOOLTIP_XP_SCROLLS = "Erinnern, wenn die EP-Schriftrolle oder der Trank aufgebraucht sind, oder wann sie aufgebraucht sein werden.",
    
    HEADER_TELVAR = "Tel'Var-Steine",
    NAME_TELVAR = "Erinnerung bei dieser Anzahl an Tel'Var-Steinen:",
    TOOLTIP_TELVAR = "Erinnern, wenn Ihr mehr als die angegebene Anzahl an Tel'Var-Steinen mit Euch führt.",
    NAME_TELVAR_AUTODEPOSIT = "Tel'Var-Steine automatisch einzahlen:",
    TOOLTIP_TELVAR_AUTODEPOSIT = "Automatische Einzahlung der Tel'Var-Steine, die Ihr bei Euch tragt, wenn sie die angegebene Anzahl überschreiten und Ihr einen Bankier aufsucht",
    NAME_TELVAR_RESERVE_AMT = "Diese Anzahl an Tel'Var-Steinen behalten:",
    TOOLTIP_TELVAR_RESERVE_AMT = "Wenn Ihr Tel'Var-Steine automatisch einzahlt, behaltet Ihr diese Anzahl für Bonusmultiplikatoren bei Euch.",
    
    HEADER_AP_SCROLLS = "AP-Schriftrollen & Kriegstorten",
    NAME_AP_SCROLLS =  "Erinnerung aktivieren:",
    TOOLTIP_AP_SCROLLS = "Erinnern, wenn die Kriegstorte oder die AP-Schriftrolle aufgebraucht sind, oder wann sie aufgebraucht sein werden.",
    
}

if Reminderz.Localization and #localization == #Reminderz.Localization then
    ZO_ShallowTableCopy(localization, Reminderz.Localization)
end