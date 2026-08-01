local strings = {
    HELLOTAMRIEL_HELLO = "Hallo, {name}! Willkommen bei The Elder Scrolls Online.",
    HELLOTAMRIEL_ZONE_WELCOME = "Willkommen in {zone}, {name}!",
    HELLOTAMRIEL_GUILD_GREETING_EXAMPLE = "Guten Abend Gildenmitglieder, wie geht es euch heute?",
    HELLOTAMRIEL_RECRUITER_EXAMPLE = "Sucht ihr eine Gilde? Schreibt mir für eine Einladung!",
    HELLOTAMRIEL_CUSTOM1_EXAMPLE = "Hallo von Benutzerdefinierte Gildennachricht 1!",
    HELLOTAMRIEL_CUSTOM2_EXAMPLE = "Hallo von Benutzerdefinierte Gildennachricht 2!",
    HELLOTAMRIEL_CUSTOM3_EXAMPLE = "Hallo von Benutzerdefinierte Gildennachricht 3!",

    HELLOTAMRIEL_USE_CHARACTER = "Charakterspezifische Einstellungen verwenden",
    HELLOTAMRIEL_USE_CHARACTER_TIP = "Aktivieren, um Einstellungen nur für diesen Charakter zu verwenden. Deaktivieren, um kontoweite Einstellungen zu verwenden.",
    HELLOTAMRIEL_ENABLE_GREETING = "Begrüßung aktivieren",
    HELLOTAMRIEL_ENABLE_GREETING_TIP = "Die Begrüßungsnachricht beim Einloggen an- oder ausschalten.",
    HELLOTAMRIEL_WELCOME_MSG = "Begrüßungsnachricht",
    HELLOTAMRIEL_WELCOME_MSG_TIP = "Stellen Sie Ihre benutzerdefinierte Begrüßungsnachricht ein. Verwenden Sie {name} für den Charakternamen und {zone} für die aktuelle Zone.",
    HELLOTAMRIEL_ENABLE_ZONE_WELCOME = "Zonenbegrüßung aktivieren",
    HELLOTAMRIEL_ENABLE_ZONE_WELCOME_TIP = "Die Begrüßungsnachricht beim Betreten einer neuen Zone an- oder ausschalten.",
    HELLOTAMRIEL_ZONE_WELCOME_MSG = "Zonen-Begrüßungsnachricht",
    HELLOTAMRIEL_ZONE_WELCOME_MSG_TIP = "Stellen Sie Ihre benutzerdefinierte Begrüßungsnachricht für die Zone ein. Verwenden Sie {name} für den Charakternamen und {zone} für die neue Zone.",

    HELLOTAMRIEL_AUTO_FILL_GREETING = "Automatische Gildengrüße",
    HELLOTAMRIEL_ENABLE_AUTO_FILL_GREETING = "Automatische Gildengrüße aktivieren",
    HELLOTAMRIEL_ENABLE_AUTO_FILL_GREETING_TIP = "Wenn aktiviert, wird beim Einloggen nach Ablauf des Intervalls die Chateingabe mit einer konfigurierbaren Nachricht an die gewählte Gilde gefüllt.",
    HELLOTAMRIEL_AUTO_FILL_GREETING_MSG = "Nachricht für automatische Gildengrüße",
    HELLOTAMRIEL_AUTO_FILL_GREETING_MSG_TIP = "Nachricht, die automatisch im Chat ausgefüllt wird. Beispiel: Guten Abend Gildenmitglieder, wie geht es euch heute?",
    HELLOTAMRIEL_AUTO_FILL_MINUTES = "Minimale Minuten zwischen automatischen Grüßen",
    HELLOTAMRIEL_AUTO_FILL_MINUTES_TIP = "Minimales Intervall in Minuten, bevor das automatische Grußfeld erneut ausgefüllt wird (Standard: 1440 = 24 Stunden).",
    HELLOTAMRIEL_SELECT_GUILD_AUTO_FILL = "Gilde für automatische Grüße auswählen",
    HELLOTAMRIEL_SELECT_GUILD_AUTO_FILL_TIP = "Wählen Sie die Gilde, für die Sie automatisch begrüßen möchten. Dies greift nur bei der ersten ausgewählten Gilde beim Login oder /reloadui. Nutzen Sie den Pfeil nach oben im Chat, um die Nachricht schnell an weitere Gilden zu senden.",

    HELLOTAMRIEL_GUILD_SLOT = "Gildenslot",

    HELLOTAMRIEL_GUILD_RECRUITER = "Gildenrekrutierer",
    HELLOTAMRIEL_ENABLE_RECRUITER = "Gildenrekrutierer-Modus aktivieren",
    HELLOTAMRIEL_ENABLE_RECRUITER_TIP = "Wenn aktiviert (oder mit /guildrecruiter), wird Ihre Rekrutierungsnachricht bei jedem Zonenwechsel automatisch im Zonenchat ausgefüllt.",
    HELLOTAMRIEL_RECRUITER_MSG = "Rekrutierungsnachricht",
    HELLOTAMRIEL_RECRUITER_MSG_TIP = "Nachricht, die beim Betreten einer Zone automatisch ausgefüllt wird. Beispiel: Sucht ihr eine Gilde? Schreibt mir für eine Einladung!",
    HELLOTAMRIEL_RECRUITER_ENABLED = "Gildenrekrutierer-Modus AKTIVIERT. Ihre Rekrutierungsnachricht wird bei jedem Zonenwechsel automatisch ausgefüllt.",
    HELLOTAMRIEL_RECRUITER_DISABLED = "Gildenrekrutierer-Modus DEAKTIVIERT.",

    HELLOTAMRIEL_CUSTOM_GUILD_MESSAGES = "Benutzerdefinierte Gildenflüsternachrichten",
    HELLOTAMRIEL_SELECT_GUILD_CUSTOM = "Gilde für benutzerdefinierte Flüsternachrichten auswählen",
    HELLOTAMRIEL_SELECT_GUILD_CUSTOM_TIP = "Nur Mitglieder dieser Gilde lösen benutzerdefinierte Flüsternachrichten aus, wenn Sie sie über das Gildenverzeichnis anschreiben.",

    HELLOTAMRIEL_ENABLE_CUSTOM1 = "Benutzerdefinierte Gildennachricht 1 aktivieren",
    HELLOTAMRIEL_ENABLE_CUSTOM1_TIP = "Aktivieren, um beim Flüstern eines Gildenmitglieds diese Nachricht automatisch auszufüllen. Umschalten mit /guildcustom1.",
    HELLOTAMRIEL_CUSTOM1_MSG = "Benutzerdefinierte Gildennachricht 1",
    HELLOTAMRIEL_CUSTOM1_MSG_TIP = "Die Nachricht, die automatisch ausgefüllt werden soll (1).",
    HELLOTAMRIEL_CUSTOM1_STATUS = "Benutzerdefinierte Gildennachricht 1 %s",

    HELLOTAMRIEL_ENABLE_CUSTOM2 = "Benutzerdefinierte Gildennachricht 2 aktivieren",
    HELLOTAMRIEL_ENABLE_CUSTOM2_TIP = "Aktivieren, um beim Flüstern eines Gildenmitglieds diese Nachricht automatisch auszufüllen. Umschalten mit /guildcustom2.",
    HELLOTAMRIEL_CUSTOM2_MSG = "Benutzerdefinierte Gildennachricht 2",
    HELLOTAMRIEL_CUSTOM2_MSG_TIP = "Die Nachricht, die automatisch vorgeschlagen werden soll (2).",
    HELLOTAMRIEL_CUSTOM2_STATUS = "Benutzerdefinierte Gildennachricht 2 %s",

    HELLOTAMRIEL_ENABLE_CUSTOM3 = "Benutzerdefinierte Gildennachricht 3 aktivieren",
    HELLOTAMRIEL_ENABLE_CUSTOM3_TIP = "Aktivieren, um beim Flüstern eines Gildenmitglieds diese Nachricht automatisch auszufüllen. Umschalten mit /guildcustom3.",
    HELLOTAMRIEL_CUSTOM3_MSG = "Benutzerdefinierte Gildennachricht 3",
    HELLOTAMRIEL_CUSTOM3_MSG_TIP = "Die Nachricht, die automatisch vorgeschlagen werden soll (3).",
    HELLOTAMRIEL_CUSTOM3_STATUS = "Benutzerdefinierte Gildennachricht 3 %s",

    HELLOTAMRIEL_ENABLED = "AKTIVIERT",
    HELLOTAMRIEL_DISABLED = "DEAKTIVIERT",
}
for id, value in pairs(strings) do
    SafeAddString(_G[id], value, 2)
end