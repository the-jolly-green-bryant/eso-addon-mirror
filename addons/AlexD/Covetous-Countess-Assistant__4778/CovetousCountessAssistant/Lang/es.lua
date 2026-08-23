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
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_HIGHLIGHT_QUEST_ITEMS
        = "Resaltar objetos de misión",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_HIGHLIGHT_QUEST_ITEMS_TOOLTIP
        = "Colorea de verde los iconos de los objetos que coincidan con las etiquetas de la misión activa.",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_HIGHLIGHT_ON
        = "Resaltado de objetos de misión: ACTIVADO",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_HIGHLIGHT_OFF
        = "Resaltado de objetos de misión: DESACTIVADO",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD
        = "Omitir ofertas del Tablón de Consejos",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD_TOOLTIP
        = "Cerrar automáticamente las ofertas del Tablón de Consejos que no sean la Condesa Codiciosa.",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD_WARNING
        = "Esto cerrará automáticamente los diálogos que no sean de la Condesa.",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_AUTOSKIP_ON
        = "Omisión Tablón de Consejos: ACTIVADA",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_AUTOSKIP_OFF
        = "Omisión Tablón de Consejos: DESACTIVADA",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
