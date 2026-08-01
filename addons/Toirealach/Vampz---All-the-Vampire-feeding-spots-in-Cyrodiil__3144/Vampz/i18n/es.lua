Vampz = Vampz or {}

local localization = {

    LOADED_STR = "%s %s %s",
    WAS_LOADED = "cargado",
    NOT_LOADED = "NO cargado",
    NAME_SUPPRESS = "Suprimir mensaje cargado del complemento",
    TOOLTIP_SUPPRESS = "Suprime el mensaje en la ventana de chat que te indica que el complemento se cargó correctamente.",
    SETTINGS_GENERAL_OPTIONS_HEADER = "CONFIGURACIÓN DEL PIN DEL MAPA",
    SETTINGS_MAP_PIN_ICON_LABEL = "Seleccione el icono de marcador del mapa",
    SETTINGS_MAP_PIN_ICON_DESCRIPTION = "Seleccione el icono de marcador del mapa",
    SETTINGS_MAP_PIN_SIZE_LABEL = "Tamaño del pin",
    SETTINGS_MAP_PIN_SIZE_DESCRIPTION = "Establecer el tamaño de los pines del mapa",
    SETTINGS_MAP_PIN_COLOR_LABEL = "Color del pin",
    SETTINGS_MAP_PIN_COLOR_DESCRIPTION = "Establecer el color de los pines del mapa",
    SETTINGS_CLICKABLE_LABEL = "Al hacer clic en los pines del mapa de Vampz se establece el punto de ruta",
    SETTINGS_CLICKABLE_DESCRIPTION = "¿Debería permitir o no hacer clic en el pin del mapa para colocar un waypoint en su mapa?",
    CLICK_HANDLER_NAME = "Establecer punto de referencia al sitio de alimentación de vampiros",
    PIN_FILTER_NAME = "Lugar de alimentación de vampiros",
}

if Vampz.Localization and #localization == #Vampz.Localization then
    ZO_ShallowTableCopy(localization, Vampz.Localization)
end