SpawnPoints = SpawnPoints or {}

local localization = {

    LOADED_STR = "%s %s %s",
    WAS_LOADED = "geladen",
    NOT_LOADED = "NICHT geladen",
    NAME_SUPPRESS = "Add-on-geladene Nachricht unterdrücken",
    TOOLTIP_SUPPRESS = "Unterdrücken Sie die Meldung im Chatfenster, die Ihnen mitteilt, dass das Add-on erfolgreich geladen wurde.",
    SETTINGS_GENERAL_OPTIONS_HEADER = "MAP PIN EINSTELLUNGEN",
    SETTINGS_MAP_PIN_ICON_LABEL = "Wähl das Symbol der Map Pins",
    SETTINGS_MAP_PIN_ICON_DESCRIPTION = "Wähl das Symbol der Map Pins",
    SETTINGS_MAP_PIN_SIZE_LABEL = "Pin Größe",
    SETTINGS_MAP_PIN_SIZE_DESCRIPTION = "Setze die Größe der Map Pins",
    SETTINGS_MAP_PIN_COLOR_LABEL = "Pin Farbe",
    SETTINGS_MAP_PIN_COLOR_DESCRIPTION = "Setze die Farbe der Map Pins",
    SETTINGS_CLICKABLE_LABEL = "Anklicken der SpawnPoints Map Pins, legt den Wegpunkt fest",
    SETTINGS_CLICKABLE_DESCRIPTION = "Soll das Anklicken des Map Pins erlaubt werden oder nicht, damit ein Wegpunkt auf Ihrer Karte gesetzt wird?",
    CLICK_HANDLER_NAME = "Wegpunkt zur Volendrung Spawnpunkte setzen",
    PIN_FILTER_NAME = "Volendrung Spawnpunkte",
}

if SpawnPoints.Localization and #localization == #SpawnPoints.Localization then
    ZO_ShallowTableCopy(localization, SpawnPoints.Localization)
end