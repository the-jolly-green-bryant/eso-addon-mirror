local strings = {

    -----------
    -- Menu
    GG_MENU_LE_HEADER = "Recordatorios de caducidad de pistas",
    GG_MENU_LE_DESC = "Los recordatorios se activan cuando el jugador cambia de zona. Las pistas que caducan dentro del número de días establecido activarán recordatorios. Los recordatorios se pausarán durante el intervalo configurado después de mostrarse uno.",
    GG_MENU_LE_ENABLED = "Activado",
    GG_MENU_LE_ENABLED_TT = "¿Activar los recordatorios de caducidad de pistas?",
    GG_MENU_LE_ANNOUNCE_REMINDERS = "Anunciar recordatorios",
    GG_MENU_LE_ANNOUNCE_REMINDERS_TT = "¿Mostrar un anuncio en pantalla para los recordatorios de caducidad de pistas?",
    GG_MENU_LE_CHAT_REMINDERS = "Mostrar recordatorios en el chat",
    GG_MENU_LE_CHAT_REMINDERS_TT = "¿Mostrar recordatorios en la ventana de chat?",
    GG_MENU_LE_WARNING_PERIOD = "Antelación del recordatorio (días) [1-20]",
    GG_MENU_LE_WARNING_PERIOD_TT = "Cuántos días antes de que caduque la pista debe comenzar a recordarse.",
    GG_MENU_LE_NO_WARNING_PERIOD = "Intervalo sin recordatorio (minutos) [1-120]",
    GG_MENU_LE_NO_WARNING_PERIOD_TT = "El intervalo en segundos entre recordatorios.",
    GG_MENU_GF_HEADER = "Notificaciones de anuncios del Buscador de Grupo",
    GG_MENU_GF_ENABLED = "Activado",
    GG_MENU_GF_ENABLED_TT = "¿Activar las notificaciones del Buscador de Grupo en la ventana de chat?",
    GG_MENU_GF_CHECK_INTERVAL = "Intervalo de comprobación del Buscador de Grupo (segundos) [5-60]",
    GG_MENU_GF_CHECK_INTERVAL_TT = "El intervalo en segundos para comprobar el Buscador de Grupo en busca de nuevos anuncios de Pruebas. Mínimo 5 segundos, máximo 60 segundos.",
    GG_MENU_GF_TRIAL_HEADER = "Pruebas para notificar desde el Buscador de Grupo",
    GG_MENU_GF_TRIAL_DESC = "Ten en cuenta que los anuncios creados con la opción \"Cualquier Prueba\" también se incluirán en las notificaciones.",
    GG_MENU_GF_TRIAL_TT = "¿Incluir los anuncios de %s del Buscador de Grupo?",
    GG_MENU_PA_HEADER = "Integración con Personal Assistant",
    GG_MENU_PA_DESC = "Requisitos:\n- Addons: LibCharacterKnowledge, LibPrice (y una fuente de precios activa como TamrielTradeCentre, Master Merchant o Arkadius' Trade Tools)\n- Un perfil LOOT dedicado de Personal Assistant para tu Comerciante, para que los objetos sobrantes y destinados a la venta NO se aprendan automáticamente al retirarlos del banco.\n\nReglas de enrutamiento:\n1. Objetos desconocidos por el Artesano → enviar al Artesano\n2. Objetos de bajo valor se envían al siguiente personaje según LibCharacterKnowledge\n3. Objetos sobrantes y de alto valor se envían al Comerciante (si está habilitado), de lo contrario permanecen en el banco.",
    GG_MENU_PA_ENABLED = "¿Activado?",
    GG_MENU_PA_ENABLED_TT = "¿Está activada la anulación de Personal Assistant? Desactivarla requiere recargar la interfaz.",
    GG_MENU_PA_SALE_VALUE_THRESHOLD = "Umbral de valor de venta",
    GG_MENU_PA_SALE_VALUE_THRESHOLD_TT = "Los objetos con un valor de venta menor o igual a este umbral se consideran de bajo valor.",
    GG_MENU_PA_CRAFTER_CHARACTER_NAME = "Nombre del Artesano",
    GG_MENU_PA_CRAFTER_CHARACTER_NAME_TT = "Nombre del personaje que actúa como Artesano.",
    GG_MENU_PA_TRADER_CHARACTER_NAME = "Nombre del Comerciante",
    GG_MENU_PA_TRADER_CHARACTER_NAME_TT = "Nombre del personaje que actúa como Comerciante.",
    GG_MENU_PA_WITHDRAW_TO_TRADER_ENABLED = "¿Retirar al Comerciante?",
    GG_MENU_PA_WITHDRAW_TO_TRADER_ENABLED_TT = "Los objetos sobrantes se retiran del banco al Comerciante.",

    -----------
    -- core
    GG_LAM_NOT_FOUND = "LibAddonMenu2 no encontrado, no se puede construir el menú.",
    GG_CHARACTERS = "Personajes",
    GG_SHOW_WINDOW = "Mostrar ventana",
    GG_TOGGLE_LOCATION_TRACKER = "Alternar rastreador de cambio de ubicación",
    GG_REMAINING = " Restante",
    GG_ELAPSED = " Transcurrido",

    -----------
    -- Lead Expiry
    GG_LE_NEW_LEAD = "Pista nueva/no descubierta",
    GG_LE_LEAD = "Pista",
    GG_LE_LORE_LEAD = "Pista de códice/lore incompleta",
    GG_LE_EXPIRY_IN = " Caduca en ",
    GG_LE_EXPIRING_IN = "Pista caducando en ",
    GG_LE_FOUND_IN = " encontrada en ",
    GG_LE_UNKNOWN_NAME = "Pista desconocida",
    GG_LE_UNKNOWN_ZONE = "Zona desconocida",
    GG_LE_REMIND = "REC.", 
    GG_LE_IGNORE = "IGN.",
    GG_LE_DISABLE_REMINDER = "Desactivar recordatorio",
    GG_LE_ENABLE_REMINDER = "Activar recordatorio",
    GG_LE_TOGGLE_REMINDER = "Alternar recordatorio",

    -----------
    -- Group Finder
    GG_GF_NEW_LISTING = "Nuevo anuncio",
    GG_GF_UPDATED_LISTING = "Anuncio actualizado",
    GG_GF_REMOVED_LISTING = "Anuncio eliminado",
    GG_GF_NO_LISTING = "Buscador de grupo: |cff0000No se encontraron anuncios.|r Se notificará cuando aparezca uno.",

    -----------
    -- Location Change
    GG_LOCATION_CHANGED = "Ubicación cambiada",
    GG_LOCATION_ENABLED = "Rastreador de cambio de ubicación activado",
    GG_LOCATION_DISABLED = "Rastreador de cambio de ubicación desactivado",

    -----------
    -- Night Market
    GG_NM_MENU_ELMS_GUIDANCE_HEADER = "Guía de objetivos de misiones del Mercado Nocturno",
    GG_NM_MENU_BLUE_MARKERS = "Los marcadores azules indican una posible ubicación de inicio de misión.",
    GG_NM_MENU_GREEN_MARKERS = "Los marcadores verdes muestran una posible ubicación del objetivo de la misión.",
    GG_NM_MENU_NOTE_ON_ELMS = "Nota: Debes tener ElmsMarkers instalado y habilitado para que aparezcan estos marcadores.",
    GG_NM_MENU_QUEST_LIST_HDR = "Los números se corresponden con las siguientes misiones.",
    GG_NM_MENU_HIDE_TRACKER = "Ocultar rastreador de puntuación de facción",
    GG_NM_MENU_HIDE_TRACKER_TT = "Oculta las puntuaciones de facción del Mercado Nocturno en pantalla.",
    GG_NM_MENU_ELMS_ENABLE = "¿Habilitar la inyección de marcadores de ElmsMarkers?",
    GG_NM_MENU_ELMS_ENABLE_TT = "Añade marcadores 3D en ElmsMarkers para las misiones del Mercado Nocturno.",
    GG_NM_GROUP_AUTO = "Automatización de grupo de Argent",
    GG_NM_GROUP_AUTO_OFF = "APAGADO",
    GG_NM_GROUP_AUTO_ON = "ENCENDIDO",
    GG_NM_GROUP_AUTO_ERROR_NOTINZONE = "No estás en la zona del evento",
    GG_NM_GROUP_AUTO_ERROR_ZONENOTACTIVE = "La zona del evento no está activa",
    GG_NM_GROUP_AUTO_ERROR_FAILEDTWICE = "La creación en el Buscador de Grupo falló dos veces",
    GG_NM_GROUP_AUTO_ALLDONE = "Todas las llaves obtenidas",
    GG_NM_GROUP_AUTO_LISTINGREMOVED = "Anuncio eliminado",
    GG_NM_GROUP_AUTO_QUESTSHARE1 = "Compartidas",
    GG_NM_GROUP_AUTO_QUESTSHARE2 = "misión(es) con el grupo.",
    GG_NM_GROUP_AUTOMATION_KEYBIND = "Alternar automatización de grupo de Argent",


    -----------
    -- Time
    GG_TIME_SECONDS = "segundos",
    GG_TIME_MINUTES = "minutos",
    GG_TIME_HOURS = "horas",
    GG_TIME_DAYS = "días",
    GG_TIME_NONE = "Ninguno",

}

for id, val in pairs(strings) do
   ZO_CreateStringId(id, val)
   SafeAddVersion(id, 1)
end