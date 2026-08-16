local strings = {
    SI_QUICKEMOTEMENU_UNKNOWN_NAME          = "?",
    SI_QUICKEMOTEMENU_CATEGORIES            = "Kategorien",
    SI_QUICKEMOTEMENU_FAVORITES             = "Favoriten",
    SI_QUICKEMOTEMENU_NO_FAVORITES          = "(leer)",
    SI_QUICKEMOTEMENU_BINDING_TOGGLE        = "Umschalten",
    SI_QUICKEMOTEMENU_OPTION_HOVER          = "Untermenü-Hover-Verzögerung (ms)",
    SI_QUICKEMOTEMENU_OPTION_HOVER_TOOLTIP  = "0 = nur per Klick öffnen",
    SI_QUICKEMOTEMENU_OPTION_UIMODE         = "Button nur im UI-Modus anzeigen",
    SI_QUICKEMOTEMENU_OPTION_UIMODE_TOOLTIP =
    "Zeigt die Hauptschaltfläche nur an, wenn der Mauszeiger aktiv ist (UI-Modus). Sie wird im normalen Spiel-/Interaktionsmodus wieder ausgeblendet.",
    SI_QUICKEMOTEMENU_OPTION_CLOSE          = "Menü nach Emote schließen (Linksklick)",
    SI_QUICKEMOTEMENU_OPTION_RESET          = "Button-Position zurücksetzen",
    SI_QUICKEMOTEMENU_OPTION_DESCRIPTION    = [[
|c3399FFFUNKTIONEN|r
• Schneller Zugriff auf Emotes mit Kategorien und Favoriten
• Kategorien und Emotes werden direkt aus den Spieldaten geladen
• Neue Emotes werden automatisch zur Liste hinzugefügt

|c3399FFSTEUERUNG|r
• Linksklick auf den Button zum Öffnen/Schließen
• Rechtsklick und ziehen zum Verschieben
• Linksklick auf Emote zum Abspielen
• Rechtsklick auf Emote zu Favoriten hinzufügen/entfernen

|c3399FFMENÜS|r
• Kategorien — Emotes nach Kategorie durchsuchen
• Favoriten — schneller Zugriff auf gespeicherte Emotes
• Untermenüs öffnen bei Hover oder Klick (siehe Verzögerung)
• Menüs öffnen oben/unten und links/rechts je nach Button-Position

|c3399FFTIPPS|r
• Tastenbelegung zum Umschalten nutzen
• /qempanel öffnet dieses Einstellungsfenster
• Favoriten werden kontoweit gespeichert
]],
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
