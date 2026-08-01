Containerz = Containerz or {}

local localization = {

    LOADED_STR = "%s %s %s",
    WAS_LOADED = "cargado",
    NOT_LOADED = "no cargado",

    OPEN_ALL_CONTAINERZ = "Abrir todos los contenedores",
    STOP_OPENING_CONTAINERZ = "Dejar de abrir contenedores",
    WILL_OPEN = "Abrirá un %s",
    WONT_OPEN = " NO abrirá un %s",

    TRANSMUTES_NAME = "No excedas el límite de Cristal de Transmutación",
    TRANSMUTES_TOOLTIP = "Si existe la posibilidad de que una geoda de transmutación supere el límite de 1000 cristales transmutados, no abras esa geoda automáticamente",
    GLADIATORS_NAME = "Abre sólo una mochila de Gladiador de Arena por día",
    GLADIATORS_TOOLTIP = "Solo una vez al día, cuando abras una Mochila de Gladiador de Arena obtendrás una Prueba de Gladiador de Arena, por lo que solo se abre automáticamente por día",
    SIEGEMASTERS_NAME = "Abre solo un cofre del maestro de asedio por día",
    SIEGEMASTERS_TOOLTIP = "Solo una vez al día, cuando abras un Cofre del Maestro de asedio obtendrás un Mérito de Asedio de Cyrodiil, por lo que solo abres automáticamente uno por día",
    SCROLLKEEPERS_NAME = "Abre sólo una Mochila de Pergamino por día",
    SCROLLKEEPERS_TOOLTIP = "Solo una vez al día, cuando abras una Mochila de Pergaminos, recibirás pergaminos, por lo que solo abres uno automáticamente por día",

    GLADIATORS_VERIFY = "¿Has abierto una mochila Gladiator hoy?\nSi no lo recuerdas, simplemente di 'Sí'.",
    SIEGEMASTERS_VERIFY = "¿Has abierto un cofre del maestro de asedio hoy?\nSi no lo recuerdas, simplemente di 'Sí'.",
}
    
if Containerz.Localization and #localization == #Containerz.Localization then
    ZO_ShallowTableCopy(localization, Containerz.Localization)
end