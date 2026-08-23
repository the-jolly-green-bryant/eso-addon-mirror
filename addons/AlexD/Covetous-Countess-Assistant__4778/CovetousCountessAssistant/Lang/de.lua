local strings = {
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS
        = "Gierige Gräfin verfolgen",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS_TOOLTIP
        = "Schätze markieren, die für die Gierige Gräfin geeignet sind.",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW
        = "Schatzmeister der Tribute verfolgen",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW_TOOLTIP
        = "Schätze markieren, die für den Schatzmeister der Tribute (Krähe) geeignet sind.",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_SETTINGS
        = "Einstellungen",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_COUNTESS_ON
        = "Gierige Gräfin verfolgen: AN",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_COUNTESS_OFF
        = "Gierige Gräfin verfolgen: AUS",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_CROW_ON
        = "Schatzmeister der Tribute verfolgen: AN",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_CROW_OFF
        = "Schatzmeister der Tribute verfolgen: AUS",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_HIGHLIGHT_QUEST_ITEMS
        = "Quest-Gegenstände hervorheben",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_HIGHLIGHT_QUEST_ITEMS_TOOLTIP
        = "Färbt passende Gegenstandssymbole grün, wenn sie zu den Tags der aktiven Quest passen.",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_HIGHLIGHT_ON
        = "Quest-Gegenstände hervorheben: EIN",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_HIGHLIGHT_OFF
        = "Quest-Gegenstände hervorheben: AUS",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD
        = "Auto-Überspringen: Pinnwand-Angebote",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD_TOOLTIP
        = "Schließt automatisch Pinnwand-Angebote, die nicht die Gierige Gräfin betreffen.",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD_WARNING
        = "Dies schließt automatisch Dialoge, die nicht die Gräfin betreffen.",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_AUTOSKIP_ON
        = "Pinnwand Auto-Überspringen: AN",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_AUTOSKIP_OFF
        = "Pinnwand Auto-Überspringen: AUS",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
