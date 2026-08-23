local strings = {
    SI_HAA_PANEL_NAME               = "Heavy Attack Alerter",
    SI_HAA_COMBAT_ONLY_NAME         = "Nur im Kampf anzeigen",
    SI_HAA_COMBAT_ONLY_TIP          = "Versteckt das Schild-Symbol außerhalb des Kampfes.",
    SI_HAA_SOUND_NAME               = "Alarmton",
    SI_HAA_SOUND_TIP                = "Signalton, wenn ein Gegner einen schweren Angriff startet.",
    SI_HAA_SOUND_CHAMPION           = "Glocke (Championpunkte)",
    SI_HAA_SOUND_DUEL               = "Duell (Duellstart)",
    SI_HAA_SOUND_QUEST              = "Sieg (Quest abgeschlossen)",
    SI_HAA_SOUND_NONE               = "Kein Ton",
    SI_HAA_ALPHA_NAME               = "Transparenz des grünen Schilds (%)",
    SI_HAA_ALPHA_TIP                = "Deckkraft des Schildes im normalen Zustand.",
    SI_HAA_ALERT_ALPHA_NAME         = "Transparenz des roten Schilds (%)",
    SI_HAA_ALERT_ALPHA_TIP          = "Deckkraft des Schildes während des Alarms.",
    SI_HAA_SIZE_NAME                = "Symbolgröße (px)",
    SI_HAA_OFFSET_X_NAME            = "Horizontaler Versatz (X)",
    SI_HAA_OFFSET_Y_NAME            = "Vertikaler Versatz (Y)",
    SI_HAA_TEST_BUTTON_NAME         = "Alarm testen",
    SI_HAA_TEST_BUTTON_TIP          = "Löst einen 1,5-sekündigen Testalarm mit Ton aus, um die Einstellungen zu prüfen.",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end