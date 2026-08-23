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
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_HIGHLIGHT_QUEST_ITEMS
        = "Evidenzia oggetti missione corrispondenti",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_HIGHLIGHT_QUEST_ITEMS_TOOLTIP
        = "Colora di verde le icone degli oggetti che corrispondono ai tag della missione attiva.",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_HIGHLIGHT_ON
        = "Evidenziazione oggetti missione: ATTIVA",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_HIGHLIGHT_OFF
        = "Evidenziazione oggetti missione: DISATTIVA",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD
        = "Salta offerte della Bacheca Indizi",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD_TOOLTIP
        = "Chiude automaticamente le offerte della Bacheca Indizi che non riguardano la Contessa Avida.",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD_WARNING
        = "Questo chiuderà automaticamente i dialoghi che non riguardano la Contessa.",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_AUTOSKIP_ON
        = "Salto Bacheca Indizi: ATTIVO",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_AUTOSKIP_OFF
        = "Salto Bacheca Indizi: DISATTIVO",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
