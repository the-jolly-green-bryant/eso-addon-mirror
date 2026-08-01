-- German Localization Strings for TorigaHUD
local strings = {
    BINDING_NAME_TORIGAHUD_TOGGLE_DRAG = "HUD-Position entsperren/sperren",
    
    TORIGAHUD_SETTINGS_DISPLAY_NAME = "|cFFD700TorigaHUD|r-Einstellungen",
    TORIGAHUD_SETTINGS_GENERAL_HEADER = "Allgemeine Einstellungen",
    TORIGAHUD_SETTINGS_HIDE_OOC = "Außerhalb des Kampfes ausblenden",
    TORIGAHUD_SETTINGS_HIDE_OOC_TT = "Blendet die Ressourcenleisten aus, wenn Ihr Euch außerhalb des Kampfes befindet und kein aktives Ziel habt.",
    TORIGAHUD_SETTINGS_SHOW_SHIELDS = "Schutzschild anzeigen",
    TORIGAHUD_SETTINGS_SHOW_SHIELDS_TT = "Zeigt eine halbtransparente blaue Leiste über dem Leben an, um aktive Schilde anzuzeigen.",
    TORIGAHUD_SETTINGS_LERP_SPEED = "Leisten-Animationsgeschwindigkeit",
    TORIGAHUD_SETTINGS_LERP_SPEED_TT = "Regelt, wie schnell die Ressourcenleisten gleiten. (1.00 = sofortige Aktualisierung, keine Animation)",
    TORIGAHUD_SETTINGS_SEGMENT_SIZE = "Wert pro Segment (Leben/Ressourcen)",
    TORIGAHUD_SETTINGS_SEGMENT_SIZE_TT = "Regelt, wie viele Ressourcenpunkte jeder Block darstellt (Leben, Magicka, Ausdauer, Ziel). Z.B. 2000 bedeutet, dass jeder Block 2000 Punkten entspricht.",
    TORIGAHUD_SETTINGS_SCALE = "HUD-Skalierung (Größe)",
    TORIGAHUD_SETTINGS_SCALE_TT = "Regelt die globale Größe aller HUD-Elemente.",
    TORIGAHUD_SETTINGS_PRESETS_HEADER = "Voreinstellungen & Positionierung",
    TORIGAHUD_SETTINGS_PRESET = "Layout-Voreinstellung",
    TORIGAHUD_SETTINGS_PRESET_TT = "Wählt ein vordefiniertes Layout aus, um das HUD sofort neu anzuordnen.",
    TORIGAHUD_SETTINGS_PRESET_DEFAULT = "Standard",
    TORIGAHUD_SETTINGS_PRESET_VERTICAL = "Fokus Kampf (Vertikal)",
    TORIGAHUD_SETTINGS_PRESET_HORIZONTAL = "Fokus Kampf (Horizontal)",
    TORIGAHUD_SETTINGS_PRESET_MINIMALIST = "Minimalistisch (Kompakt)",
    TORIGAHUD_SETTINGS_UNLOCK = "HUD-Position entsperren",
    TORIGAHUD_SETTINGS_UNLOCK_TT = "Aktiviert diese Option, um die Rahmen freizugeben. Dies schließt das Optionsmenü und zeigt einen Dialog an, um die Elemente mit der Maus zu positionieren.",
    TORIGAHUD_SETTINGS_RESET = "Standardpositionen zurücksetzen",
    TORIGAHUD_SETTINGS_RESET_TT = "Setzt alle HUD-Leisten auf ihre Standardpositionen zurück.",
    
    TORIGAHUD_DRAG_XP = "EP",
    TORIGAHUD_DRAG_TARGET = "ZIEL",
    
    TORIGAHUD_DIALOG_TITLE = "LEISTEN BELIEBIG VERSCHIEBEN",
    TORIGAHUD_DIALOG_APPLY = "ANWENDEN",
    TORIGAHUD_DIALOG_CANCEL = "ABBRECHEN",
    
    TORIGAHUD_TEXT_HEALTH = "LEBEN",
    TORIGAHUD_TEXT_LEVEL = "STUFE",
    TORIGAHUD_TEXT_XP = "ERFAHRUNG",
    TORIGAHUD_TEXT_MAGICKA = "MAGICKA",
    TORIGAHUD_TEXT_STAMINA = "AUSDAUER",
    TORIGAHUD_TEXT_TARGET_TEST = "TESTZIEL",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId("SI_" .. stringId, stringValue)
end
