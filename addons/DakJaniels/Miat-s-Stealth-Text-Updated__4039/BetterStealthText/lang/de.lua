local strings =
{
    -- Main state strings
    BETTERSTEALTHTEXT_INVISIBLE = "Unsichtbar",
    BETTERSTEALTHTEXT_REVEALED = "Aufgedeckt",
    BETTERSTEALTHTEXT_HIDING = "Verstecken",

    -- Addon menu and option strings
    BETTERSTEALTHTEXT_ADDON_NAME = "Miats Schleichtext",
    BETTERSTEALTHTEXT_ADDON_OPTIONS = "Miats Schleichtext Optionen",
    BETTERSTEALTHTEXT_ADDON_ENABLED = "ADDON AKTIVIERT",
    BETTERSTEALTHTEXT_ADDON_ENABLED_TOOLTIP = "EIN - aktiviert, AUS - deaktiviert",
    BETTERSTEALTHTEXT_ACCOUNTWIDE = "Gleiche Einstellungen für alle Charaktere",
    BETTERSTEALTHTEXT_ACCOUNTWIDE_TOOLTIP = "EIN - Jeder Charakter hat die gleichen Einstellungen, AUS - Separate Einstellungen für jeden Charakter",
    BETTERSTEALTHTEXT_ACCOUNTWIDE_WARNING = "Diese Option zu aktivieren lädt das UI neu",
    BETTERSTEALTHTEXT_DISPLAY_OPTIONS = "Anzeigeoptionen",
    BETTERSTEALTHTEXT_SCALE = "Schleichtext-Skalierung festlegen (%)",
    BETTERSTEALTHTEXT_SCALE_TOOLTIP = "Symbol- und Textskalierung reicht von 50% bis 400% der Originalgröße",
    BETTERSTEALTHTEXT_STEALTH_COLORS_OPTIONS = "Schleichfarbenoptionen",
    BETTERSTEALTHTEXT_SAME_HIDDEN_INVISIBLE = "Gleiche Farbe für VERSTECKT und UNSICHTBAR Schleichzustände",
    BETTERSTEALTHTEXT_SAME_HIDDEN_INVISIBLE_TOOLTIP = "EIN - aktiviert (VERSTECKT-Farbe gilt für UNSICHTBAR), AUS - deaktiviert (separate Einstellungen für VERSTECKT und UNSICHTBAR)",
    BETTERSTEALTHTEXT_HIDDEN_COLOR = "Farbe für VERSTECKT-Zustand wählen",
    BETTERSTEALTHTEXT_HIDDEN_COLOR_TOOLTIP = "Wähle die Textfarbe für den VERSTECKT-Schleichzustand",
    BETTERSTEALTHTEXT_INVISIBLE_COLOR = "Farbe für UNSICHTBAR-Zustand wählen",
    BETTERSTEALTHTEXT_INVISIBLE_COLOR_TOOLTIP = "Wähle die Textfarbe für den UNSICHTBAR-Schleichzustand",
    BETTERSTEALTHTEXT_SAME_ALMOST_HIDDEN_INVISIBLE = "Gleiche Farbe für VERSTECKT und UNSICHTBAR fast entdeckte Schleichzustände",
    BETTERSTEALTHTEXT_SAME_ALMOST_HIDDEN_INVISIBLE_TOOLTIP = "EIN - aktiviert (VERSTECKT-Farbe gilt für UNSICHTBAR) für fast entdeckte Zustände, AUS - deaktiviert (separate Einstellungen für VERSTECKT und UNSICHTBAR) für fast entdeckte Zustände",
    BETTERSTEALTHTEXT_HIDDEN_ALMOST_COLOR = "Farbe für VERSTECKT FAST ENTDECKT-Zustand wählen",
    BETTERSTEALTHTEXT_HIDDEN_ALMOST_COLOR_TOOLTIP = "Wähle die Textfarbe für den VERSTECKT FAST ENTDECKT-Schleichzustand",
    BETTERSTEALTHTEXT_INVISIBLE_ALMOST_COLOR = "Farbe für UNSICHTBAR FAST ENTDECKT-Zustand wählen",
    BETTERSTEALTHTEXT_INVISIBLE_ALMOST_COLOR_TOOLTIP = "Wähle die Textfarbe für den UNSICHTBAR FAST ENTDECKT-Schleichzustand",
    BETTERSTEALTHTEXT_ENABLE_HIDING = "VERSTECKEN-Text aktivieren",
    BETTERSTEALTHTEXT_ENABLE_HIDING_TOOLTIP = "EIN - aktiviert, AUS - deaktiviert",
    BETTERSTEALTHTEXT_HIDING_COLOR = "Farbe für VERSTECKEN-Zustand wählen",
    BETTERSTEALTHTEXT_HIDING_COLOR_TOOLTIP = "Wähle die Textfarbe für den VERSTECKEN-Schleichzustand",
    BETTERSTEALTHTEXT_DETECTED_COLOR = "Farbe für ENTDECKT-Zustand wählen",
    BETTERSTEALTHTEXT_DETECTED_COLOR_TOOLTIP = "Wähle die Textfarbe für den ENTDECKT-Schleichzustand",
    BETTERSTEALTHTEXT_REVEALED_COLOR = "Farbe für AUFGEDECKT-Zustand wählen",
    BETTERSTEALTHTEXT_REVEALED_COLOR_TOOLTIP = "Wähle die Textfarbe für den AUFGEDECKT-Schleichzustand",
    BETTERSTEALTHTEXT_DISGUISE_COLORS_OPTIONS = "Verkleidungsfarbenoptionen",
    BETTERSTEALTHTEXT_DISGUISED_COLOR = "Farbe für VERKLEIDET-Zustand wählen",
    BETTERSTEALTHTEXT_DISGUISED_COLOR_TOOLTIP = "Wähle die Textfarbe für den VERKLEIDET-Verkleidungszustand",
    BETTERSTEALTHTEXT_SUSPICIOUS_COLOR = "Farbe für VERDÄCHTIG-Zustand wählen",
    BETTERSTEALTHTEXT_SUSPICIOUS_COLOR_TOOLTIP = "Wähle die Textfarbe für den VERDÄCHTIG-Verkleidungszustand",
    BETTERSTEALTHTEXT_DANGER_COLOR = "Farbe für GEFAHR-Zustand wählen",
    BETTERSTEALTHTEXT_DANGER_COLOR_TOOLTIP = "Wähle die Textfarbe für den GEFAHR-Verkleidungszustand",
    BETTERSTEALTHTEXT_DISCOVERED_COLOR = "Farbe für ENTLARVT-Zustand wählen",
    BETTERSTEALTHTEXT_DISCOVERED_COLOR_TOOLTIP = "Wähle die Textfarbe für den ENTLARVT-Verkleidungszustand"
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
