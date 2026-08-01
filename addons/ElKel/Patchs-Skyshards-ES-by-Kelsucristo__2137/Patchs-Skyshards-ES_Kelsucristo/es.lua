local strings = {
    -- tooltips
    SKYS_KNOWN = "Recogido",

    SKYS_MOREINFO1 = "Ciudad",
    SKYS_MOREINFO2 = "Estancia",
    SKYS_MOREINFO3 = "Mazmorra pública",
    SKYS_MOREINFO4 = "Subterráneo",
    SKYS_MOREINFO5 = "Estancia grupal",

    SKYS_SET_WAYPOINT = "Establecer waypoint a fragmento del cielo",

    -- settings menu header
    SKYS_TITLE = "SkyShards",

    -- appearance
    SKYS_PIN_TEXTURE = "Seleccionar íconos de pin del mapa",
    SKYS_PIN_TEXTURE_DESC = "Seleccione los iconos de los marcadores del mapa.",
    SKYS_PIN_SIZE = "Tamaño de pin",
    SKYS_PIN_SIZE_DESC = "Establecer el tamaño de los pines del mapa",
    SKYS_PIN_LAYER = "Capa de pines",
    SKYS_PIN_LAYER_DESC = "Establecer la capa de los marcadores del mapa cuando estén en las mismas coordenadas que otros",

    -- compass
    SKYS_COMPASS_UNKNOWN = "Mostrar fragmentos de cielo en la brújula",
    SKYS_COMPASS_UNKNOWN_DESC = "Mostrar/Ocultar iconos de fragmentos de cielo no recopilados en la brújula",
    SKYS_COMPASS_DIST = "Distancia máxima del pin",
    SKYS_COMPASS_DIST_DESC = "La distancia máxima para que aparezcan los pines en la brújula",

    SKYS_MAINWORLD = "Pin de color para fragmentos del cielo en el otro mundo",
    SKYS_MAINWORLD_DESC = "El color de los pines para fragmentos del cielo directamente disponible en el mundo",

    -- skill panel
    SKYS_SKILLS = "Resumen del panel de habilidades",
    SKYS_SKILLS_DESC = "Seleccione el formato de visualización del recuento de fragmentos del cielo en el panel de habilidades",
    SKYS_SKILLS_OPTION1 = "Básico",
    SKYS_SKILLS_OPTION3 = "Avanzado",
    SKYS_SKILLS_OPTION2 = "Detallado",

    -- filters
    SKYS_UNKNOWN = "Mostrar fragmentos de cielo desconocidos",
    SKYS_UNKNOWN_DESC = "Mostrar/Ocultar iconos de fragmentos del cielo desconocidos en el mapa",
    SKYS_COLLECTED = "Mostrar fragmentos del cielo recopilados",
    SKYS_COLLECTED_DESC = "Mostrar/Ocultar iconos de fragmentos de cielo ya recopilados en el mapa",

    -- worldmap filters
    SKYS_FILTER_UNKNOWN = "Fragmentos del cielo desconocidos",
    SKYS_FILTER_COLLECTED = "Fragmentos del cielo recopilados",

    -- Immersive Mode
    SKYS_IMMERSIVE = "Habilitar el modo inmersivo basado en",
    SKYS_IMMERSIVE_DESC = "Los fragmentos del cielo desconocidos no se mostrarán en función de la finalización del siguiente objetivo en la zona actual que está viendo",

    SKYS_IMMERSIVE_CHOICE1 = "Deshabilitado",
    SKYS_IMMERSIVE_CHOICE2 = "Misión principal de la zona",
    SKYS_IMMERSIVE_CHOICE3 = GetString(SI_MAPFILTER8),
    SKYS_IMMERSIVE_CHOICE4 = GetAchievementCategoryInfo(6),
    SKYS_IMMERSIVE_CHOICE5 = "Misiones de la zona"

}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end
