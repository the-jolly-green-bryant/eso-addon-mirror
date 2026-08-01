local localizationStrings = {
    VOLETTE_YES = "Sí",
    VOLETTE_NO = "No",

    VOLETTE_REQUIRES_RELOADUI = "Requiere recargar la interfaz de usuario.",
    VOLETTE_RELOADUI_DIALOG_TITLE = "Recargar la interfaz",
    VOLETTE_RELOADUI_DIALOG_DESCRIPTION = "El cambio surtirá efecto la próxima vez que recargues la interfaz de usuario. ¿Te gustaría hacerlo ahora?",

    VOLETTE_CONFIRM_DIALOG_TITLE = "Confirmación",
    VOLETTE_CONFIRM_DIALOG_DESCRIPTION = "¿Confirmas esta acción?",

    VOLETTE_HQ_OWNER_CRAFT = "Propietario del QG de artesanía",
    VOLETTE_HQ_OWNER_PARSE = "Propietario del QG de entrenamiento",
    VOLETTE_HQ_OWNER_MISSING = "Debe elegir al propietario del HQ en la configuración.",

    VOLETTE_CONTACTS_ENABLE = "Habilitar menú de Contactos",
    VOLETTE_CONTACTS_ENABLE_TOOLTIP = "Habilitar para obtener un menú de contactos adicional junto a tu lista de amigos",
    VOLETTE_CONTACTS_ADDED = "<<1>> fue añadido a los contactos.",
    VOLETTE_CONTACTS_REMOVED = "<<1>> fue eliminado de los contactos.",
    VOLETTE_CONTACTS_EXISTS = "<<1>> ya está en los contactos.",
    VOLETTE_CONTACTS_WAS_INVITED = "<<1>> fue invitado.",
    VOLETTE_CONTACTS_WHISPER_BUTTON_TOOLTIP = "Susurrar",
    VOLETTE_CONTACTS_INVITE_BUTTON_TOOLTIP = "Invitar",
    VOLETTE_CONTACTS_REMOVE_BUTTON_TOOLTIP = "Eliminar de la lista",
    VOLETTE_CONTACTS_PIN_BUTTON_TOOLTIP = "Fijar",
    VOLETTE_CONTACTS_UNPIN_BUTTON_TOOLTIP = "Desfijar",

    VOLETTE_TRAVEL_WAYSHRINE_CHOICE = "Seleccione una casa cerca de un santuario",
    VOLETTE_TRAVEL_WAYSHRINE_CHOICE_TOOLTIP = "Intenta teletransportarse fuera de esta casa al usar el comando |cffcc00/v-wayshrine|r. Si no posee esta casa, se usará otra.",
    VOLETTE_TRAVEL_AUTO = "Auto",
    VOLETTE_TRAVEL_WAYSHRINE_RECOMMENDATION = "Debe poseer una de las casas compatibles. Se recomienda \"<<1>>\".",
    VOLETTE_TRAVEL_WAYSHRINE_PORTING = "Transportando fuera de \"<<1>>\".",
    VOLETTE_TRAVEL_SEARCHING_ANOTHER_WAYSHRINE = "Debe poseer \"<<1>>\". Intentando encontrar otra casa...",

    VOLETTE_SAVINGS_SUBMENU_TITLE = "Ahorros",
    VOLETTE_SAVINGS_SUBMENU_DESCRIPTION = "¡No dejes que tu riqueza se quede en personajes alternativos! Deposita automáticamente tus monedas en el banco cuando empiecen a acumularse.",
    VOLETTE_SAVINGS_ENABLE = "|c66a3ffActivar|r",
    VOLETTE_SAVINGS_MINIMUM_AMOUNT = "Monto mínimo",
    VOLETTE_SAVINGS_MAXIMUM_AMOUNT = "Monto máximo",
    VOLETTE_SAVINGS_MINIMUM_AMOUNT_TOOLTIP = "Tus personajes siempre tendrán al menos esta cantidad en sus bolsas.",
    VOLETTE_SAVINGS_MAXIMUM_AMOUNT_TOOLTIP = "Tus personajes nunca guardarán más de esta cantidad en sus bolsas.",
    VOLETTE_SAVINGS_ENABLE_FOR_DESCRIPTION = "Activar para los siguientes personajes:",
    VOLETTE_SAVINGS_DEPOSIT = "Depósito: <<1>>",
    VOLETTE_SAVINGS_WITHDRAWAL = "Retiro: <<1>>",
    VOLETTE_SAVINGS_NOT_ENOUGH_CURRENCIES = "No se pudo encontrar <<1>> en el banco.",

    SI_BINDING_NAME_VOLETTE_KEYBIND_PORT_TO_HOME = "Teletransportarse a la residencia principal",
    SI_BINDING_NAME_VOLETTE_KEYBIND_PORT_TO_HQ_CRAFT = "Teletransportarse al HQ de artesanía",
    SI_BINDING_NAME_VOLETTE_KEYBIND_PORT_TO_HQ_PARSE = "Teletransportarse al HQ de entrenamiento",
    SI_BINDING_NAME_VOLETTE_KEYBIND_PORT_TO_WAYSHRINE = "Teletransportarse a un santuario",

}


for stringId, stringValue in pairs(localizationStrings) do
    SafeAddString(_G[stringId], stringValue, 3)
end
