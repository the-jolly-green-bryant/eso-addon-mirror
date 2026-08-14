local strings = {
    SI_QUICKEMOTEMENU_UNKNOWN_NAME         = "?",
    SI_QUICKEMOTEMENU_CATEGORIES           = "Categorías",
    SI_QUICKEMOTEMENU_FAVORITES            = "Favoritos",
    SI_QUICKEMOTEMENU_NO_FAVORITES         = "(vacío)",
    SI_QUICKEMOTEMENU_BINDING_TOGGLE       = "Alternar",
    SI_QUICKEMOTEMENU_OPTION_HOVER         = "Retraso hover submenú (ms)",
    SI_QUICKEMOTEMENU_OPTION_HOVER_TOOLTIP = "0 = abrir solo al clic",
    SI_QUICKEMOTEMENU_OPTION_CLOSE         = "Cerrar menú tras emote (clic izquierdo)",
    SI_QUICKEMOTEMENU_OPTION_RESET         = "Restablecer posición del botón",
    SI_QUICKEMOTEMENU_OPTION_DESCRIPTION   = [[|c3399FFCONTROLES|r
• Clic izquierdo en el botón para abrir o cerrar el menú
• Clic derecho y arrastrar el botón para moverlo
• Clic izquierdo en un emote para reproducirlo
• Clic derecho en un emote para añadir o quitar de Favoritos

|c3399FFMENÚS|r
• Categorías — explorar emotes por categoría
• Favoritos — acceso rápido a emotes guardados
• Submenús se abren al pasar o clic (ver retraso)
• Menús se abren arriba/abajo e izq./der. según posición del botón

|c3399FFCONSEJOS|r
• Usa la tecla de acceso rápido para alternar el menú
• /qempanel abre este panel de ajustes
• Los Favoritos se guardan en toda la cuenta]],
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
