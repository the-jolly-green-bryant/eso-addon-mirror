local strings = {
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS
        = "Traccia la Contessa Avida",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS_TOOLTIP
        = "Segna i tesori utilizzabili per le cacce della Contessa Avida.",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW
        = "Traccia il Tesoriere dei Tributi",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW_TOOLTIP
        = "Segna i tesori utilizzabili per le cacce del Tesoriere dei Tributi (Corvo).",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_SETTINGS
        = "Impostazioni",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_COUNTESS_ON
        = "Tracciamento Contessa Avida: ATTIVO",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_COUNTESS_OFF
        = "Tracciamento Contessa Avida: DISATTIVO",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_CROW_ON
        = "Tracciamento Tesoriere dei Tributi: ATTIVO",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_CROW_OFF
        = "Tracciamento Tesoriere dei Tributi: DISATTIVO",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
