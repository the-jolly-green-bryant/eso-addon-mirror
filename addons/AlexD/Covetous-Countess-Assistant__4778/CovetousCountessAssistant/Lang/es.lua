local strings = {
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS
        = "Seguir a la Condesa Codiciosa",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS_TOOLTIP
        = "Marcar tesoros útiles para las cacerías de la Condesa Codiciosa.",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW
        = "Seguir al Tesorero de Tributos",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW_TOOLTIP
        = "Marcar tesoros útiles para las cacerías del Tesorero de Tributos (Cuervo).",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_SETTINGS
        = "Ajustes",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_COUNTESS_ON
        = "Seguimiento Condesa Codiciosa: ACTIVADO",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_COUNTESS_OFF
        = "Seguimiento Condesa Codiciosa: DESACTIVADO",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_CROW_ON
        = "Seguimiento Tesorero de Tributos: ACTIVADO",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_CROW_OFF
        = "Seguimiento Tesorero de Tributos: DESACTIVADO",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
