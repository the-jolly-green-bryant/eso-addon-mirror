local strings = {
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS
        = "Rastrear a Condessa Cobiçosa",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS_TOOLTIP
        = "Marcar tesouros utilizáveis nas caçadas da Condessa Cobiçosa.",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW
        = "Rastrear o Tesoureiro de Tributos",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW_TOOLTIP
        = "Marcar tesouros utilizáveis nas caçadas do Tesoureiro de Tributos (Corvo).",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_SETTINGS
        = "Configurações",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_COUNTESS_ON
        = "Rastreamento Condessa Cobiçosa: LIGADO",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_COUNTESS_OFF
        = "Rastreamento Condessa Cobiçosa: DESLIGADO",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_CROW_ON
        = "Rastreamento Tesoureiro de Tributos: LIGADO",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_CROW_OFF
        = "Rastreamento Tesoureiro de Tributos: DESLIGADO",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
