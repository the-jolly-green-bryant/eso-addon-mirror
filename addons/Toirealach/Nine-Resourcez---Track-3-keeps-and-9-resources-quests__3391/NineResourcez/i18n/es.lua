NineResourcez = NineResourcez or {}

local localization = {

    LOADED_STR = "%s %s %s",
    WAS_LOADED = "cargado",
    NOT_LOADED = "NO cargado",
   
    SETTINGS_GENERAL_OPTIONS_HEADER = "CONFIGURACIÓN DEL PIN DEL MAPA",
    SETTINGS_SUPPRESS_MSGS_LABEL = "Suprimir la recopilación de recursos y otros mensajes",
    SETTINGS_SUPPRESS_MSGS_DESCRIPTION = "Suprimir la recopilación de recursos y otros mensajes en la ventana de chat",
    SETTINGS_MAP_PIN_ICON_LABEL = "Seleccione el icono de marcador del mapa",
    SETTINGS_MAP_PIN_ICON_DESCRIPTION = "Seleccione el icono de marcador del mapa",
    SETTINGS_MAP_PIN_SIZE_LABEL = "Tamaño del pin",
    SETTINGS_MAP_PIN_SIZE_DESCRIPTION = "Establecer el tamaño de los pines del mapa",
    SETTINGS_MAP_PIN_COLOR_LABEL = "Color del pin",
    SETTINGS_MAP_PIN_COLOR_DESCRIPTION = "Establecer el color de los pines del mapa",
    SETTINGS_MAP_PIN_LEVEL_LABEL = "Nivel de PIN",
    SETTINGS_MAP_PIN_LEVEL_DESCRIPTION = "Establecer el nivel del pin del mapa",
    CLICK_HANDLER_NAME = "Establecer punto de ruta al objetivo capturado",
    PIN_FILTER_NAME = "Captura nueve recursos o tres castillos",
    NOW_TRACKING = "Tarea de seguimiento actual: %s",
    YOU_CAPTURED = "Capturado",
    QUEST_COMPLETED = "¡%s misión completada!",
    QUEST_ABANDONED = "%s misión abortada.",
    NEITHER_QUEST = "Ni %s ni %s están en tu diario de misiones.",
}

if NineResourcez.Localization and #localization == #NineResourcez.Localization then
    ZO_ShallowTableCopy(localization, NineResourcez.Localization)
end