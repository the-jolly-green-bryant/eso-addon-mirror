NineResourcez = NineResourcez or {}

local localization = {
    
    LOADED_STR = "%s %s %s",
    WAS_LOADED = "geladen",
    NOT_LOADED = "NICHT geladen",
    
    SETTINGS_GENERAL_OPTIONS_HEADER = "MAP PIN EINSTELLUNGEN",
    SETTINGS_SUPPRESS_MSGS_LABEL = "Ressourcenerfassung und andere Meldungen unterdrücken",
    SETTINGS_SUPPRESS_MSGS_DESCRIPTION = "Unterdrückung der Ressourcenerfassung und anderer Meldungen im Chatfenster",
    SETTINGS_MAP_PIN_ICON_LABEL = "Wähl das Symbol der Map Pins",
    SETTINGS_MAP_PIN_ICON_DESCRIPTION = "Wähl das Symbol der Map Pins",
    SETTINGS_MAP_PIN_SIZE_LABEL = "Pin Größe",
    SETTINGS_MAP_PIN_SIZE_DESCRIPTION = "Setze die Größe der Map Pins",
    SETTINGS_MAP_PIN_COLOR_LABEL = "Pin Farbe",
    SETTINGS_MAP_PIN_COLOR_DESCRIPTION = "Setze die Farbe der Map Pins",
    SETTINGS_MAP_PIN_LEVEL_LABEL = "Pin Ebene",
    SETTINGS_MAP_PIN_LEVEL_DESCRIPTION = "Setze die Ebene der Map Pins",
    CLICK_HANDLER_NAME = "Wegpunkt zum eroberten Ziel setzen",
    PIN_FILTER_NAME = "Erobere neun Ressourcen oder drei Burgen",
    NOW_TRACKING = "Verfolge jetzt: %s",
    YOU_CAPTURED = "Eingenommen",
    QUEST_COMPLETED = "%s Quest erledigt!",
    QUEST_ABANDONED = "%s Quest abgebrochen.",
    NEITHER_QUEST = "Weder %s noch %s steht in deinem Questtagebuch.",
}

if NineResourcez.Localization and #localization == #NineResourcez.Localization then
    ZO_ShallowTableCopy(localization, NineResourcez.Localization)
end