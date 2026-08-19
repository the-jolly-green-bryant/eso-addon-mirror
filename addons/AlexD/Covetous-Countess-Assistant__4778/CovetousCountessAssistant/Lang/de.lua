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
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
