-- Traducido por @ElKel
Harvest.localizedStrings = {
	-- conflict message for settings that don't work with Fyrakin's minimap
	["minimapconflict"] = "Esta opción es incompatible con Fyrakin's minimap.",
	-- top level description
	["esouidescription"] = "Para obtener la descripción del complemento y las preguntas frecuentes, visite la página del complemento en esoui.com",
	["openesoui"] = "Abrir ESOUI",
	["exchangedescription"] = "Puede descargar los datos más recientes de HarvestMap (posiciones de recursos) ejecutando 'DownloadNewData.command' (MacOS) 'o' DownloadNewData.bat '(Windows) en la carpeta HarvestMap. Más información con respecto a esto está disponible en la descripción del complemento de ESOUI.",
	["debuginfodescription"] = "Si desea informar un error en la página de comentarios de esoui.com, también agregue la siguiente información de depuración:",
	["printdebuginfo"] = "Copiar información de depuración",
	
	-- outdated data settings
	["outdateddata"] = "Configuraciones anticuadas de datos",
	["outdateddatainfo"] = "Estas configuraciones relacionadas con los datos se comparten entre todas las cuentas y caracteres en esta computadora.",
	["mingameversion"] = "Versión mínima del juego",
	["mingameversiontooltip"] = "HarvestMap solo conservará datos de esta y otras versiones de ESO.",
	["timedifference"] = "Guardar solo datos recientes",
	["timedifferencetooltip"] = "HarvestMap solo conservará los datos de los últimos X días.\nEsto evita mostrar datos antiguos que pueden estar desactualizados.\nEstablézcalo en 0 para guardar cualquier dato independientemente de su edad.",
	["applywarning"] = "Una vez que se eliminan los datos antiguos, ¡no se puede restaurar!",
	
	-- account wide settings
	["account"] = "Configuración de toda la cuenta",
	["accounttooltip"] = "Todos los ajustes a continuación serán los mismos para cada uno de tus personajes.",
	["accountwarning"] = "Al cambiar esta configuración, se volverá a cargar la IU.",
	
	-- map pin settings
	["mapheader"] = "Configuración de los pines del mapa",
	["mappins"] = "Habilitar los pines en el mapa principal",
	["mappinstooltip"] = "Habilitar la visualización de los pines en el mapa principal. Se puede desactivar para aumentar el rendimiento.",
	["minimappins"] = "Habilitar pines en mini mapa",
	["minimappinstooltip"] = [[Habilite la visualización de pines en el mini mapa, si tiene instalado un complemento de minimapa. Se puede deshabilitar para aumentar el rendimiento.
	Minimapas admitidos: Votan, Fyrakin y AUI]],
	--["minimaponly"] = "Mostrar pines solo en el minimapa",
	--["minimaponlytooltip"] = "Cuando esta opción está habilitada, no habrá pines en el mapa predeterminado. Los pines solo se mostrarán en el minimapa.",
	["level"] = "Mostrar los pines del mapa por encima de los pines POI.",
	["leveltooltip"] = "Habilite para mostrar los pines de HarvestMap por encima de los pines de POI en el mapa.",
	["hasdrawdistance"] = "Mostrar solo los pines del mapa cercanos",
	["hasdrawdistancetooltip"] = "Cuando está habilitado, HarvestMap solo creará pines de mapa para las ubicaciones de cosecha que están cerca del jugador.\nEsta configuración solo afecta al mapa del juego. En minimapas esta opción se habilita automáticamente!",
	["hasdrawdistancewarning"] = "Esta configuración solo afecta al mapa del juego. En minimapas esta opción se habilita automáticamente!",
	["drawdistance"] = "Distancia del pin",
	["drawdistancetooltip"] = "El umbral de distancia para el que se dibujan los pines del mapa. ¡Este ajuste también afecta a los minimapas!",
	["drawdistancewarning"] = "¡Este ajuste también afecta a los minimapas!",
	["rotatingcompatibility"] = "Compatibilidad con minimapa rotativo",
	["minimapcompatibilitymodedescription"] = "Para mejorar el rendimiento al mostrar miles de ubicaciones de recursos en el mapa, HarvestMap crea su propia variante ligera de pines del mapa. Estos pines de mapas livianos no son compatibles con los minimapas rotativos.\nSi usa un minimapa rotativo, puede habilitar el 'Modo de compatibilidad de minimapas'. Cuando este modo está habilitado, HarvestMap utilizará los pines del mapa por defecto en lugar de los pines ligeros. Estos pines predeterminados funcionarán con minimapas rotativos, pero pueden provocar FPS bajos y el juego se congelará durante varios segundos, siempre que se muestre un mapa con muchas ubicaciones de recursos conocidas.",
	["minimapcompatibilitymode"] = "Modo de compatibilidad de minimapas",
	["minimapcompatibilitymodewarning"] = "Habilitar esta opción tendrá un impacto negativo en el rendimiento del juego, cuando se muestran muchos pines en el mapa.\n\nCambiar la configuración volverá a cargar la interfaz de usuario!",
	
	-- compass settings
	["compassheader"] = "Configuración de la brújula",
	["compass"] = "Habilitar brújula",
	["compasstooltip"] = "Habilita la visualización de los pines en la brújula. Se puede desactivar para aumentar el rendimiento.",
	["compassdistance"] = "Distancia máxima del pin",
	["compassdistancetooltip"] = "La distancia máxima para los pines, en metros que aparecen en la brújula.",
	
	-- 3d pin settings
	["worldpinsheader"] = "Configuración del pin 3D",
	["worldpins"] = "Habilitar pines 3D",
	["worldpinstooltip"] = "Habilite la visualización de ubicaciones de recursos cercanas en el mundo de juegos en 3D. Se puede desactivar para mejorar el rendimiento.",
	["worlddistance"] = "Distancia máxima del pin 3D",
	["worlddistancetooltip"] = "La distancia máxima para ubicaciones de cosecha, en metros. Cuando una ubicación está más lejos, no se muestra ningún pin 3D.",
	["worldpinwidth"] = "Ancho del pin 3D",
	["worldpinwidthtooltip"] = "El ancho de los pines 3D en centímetros.",
	["worldpinheight"] = "Altura del pin 3D",
	["worldpinheighttooltip"] = "La altura de los pines 3D en centímetros.",
	["worldpinsdepth"] = "Utilice profundidad de búfer para pines 3D",
	["worldpinsdepthtooltip"] = "Cuando está deshabilitado, los pines 3d no se ocultarán detrás de otros objetos.",
	["worldpinsdepthwarning"] = "Debido a un error en el juego, esta opción no funciona, cuando se selecciona una calidad, media o baja, en las opciones de video del juego.",
	
	
	-- respawn timer settings
	["farmandrespawn"] = "Temporizador de Respawn y Ayuda de Farmeo",
	["rangemultiplier"] = "Rango de nodos recorridodos",
	["rangemultipliertooltip"] = "Los nodos dentro de X metros se consideran recorridodos por el temporizador de reaparición y el ayudante de Farmeo.",
	["hiddentime"] = "Temporizador de Respawn",
	["hiddentimetooltip"] = "Los pines recientemente recorridodos estarán ocultos por X minutos.",
	["hiddenonharvestwarning"] = "Desactivar esta opción podría afectar negativamente el rendimiento del juego.",
	["hiddenonharvest"] = "Use el temporizador Respawn solo en el Farmeo",
	["hiddenonharvesttooltip"] = "Habilite para ocultar los pines solo, cuando los cosechó. Cuando los pines desactivados también estarán ocultos si los recorridos.",
	

	-- pin type options
	["pinoptions"] = "Opciones de tipo del pin",
	["pinsize"] = "Tamaño del pin",
	["pinsizetooltip"] = "Establecer el tamaño de los pines en el mapa.",
	["pinminsize"] = "Tamaño mínimo del pin del mapa",
	["pinminsizetooltip"] = "Al alejarse del mapa, los pines también se harán más pequeños. Puede utilizar esta opción para establecer un mínimo para el tamaño de los pines. El uso de valores pequeños evita que el mapa se oculte detrás de los pines, pero los pines pueden ser más difíciles de ver.",
	["extendedpinoptions"] = "Por lo general, los pines en el mapa, la brújula y en el mundo 3D están sincronizados. Por lo tanto, si oculta cierto tipo de recurso en el mapa, también eliminará la brújula y los pines del mundo. Sin embargo, en el menú de filtro de pines extendido puede configurar los pines de la brújula y del mundo para que sean independientes de los pines del mapa.",
	["extendedpinoptionsbutton"] = "Abrir filtro extendido de pines",
	["override"] = "Anular filtro de pines",
	
	["pincolor"] = "Color de pines",
	["pincolortooltip"] = "Establecer el color de los pines en el mapa y la brújula.",
	["savepin"] = "Guardar ubicaciones",
	["savetooltip"] = "Habilite para guardar las ubicaciones de este recurso.",
	["pintexture"] = "Icono del pin",
	
	-- debug output setting
	["debugoptions"] = "Depurar",
	["debug"] = "Mostrar mensajes de depuración",
	["debugtooltip"] = "Habilite para mostrar mensajes de depuración en el chat.",
	
	-- pin type names
	["pintype1"] = "Herrería y joyería",
	["pintypetooltip1"] = "Muestra mineral y polvo en el mapa y la brújula.",
	["pintype2"] = "Plantas fibrosas",
	["pintypetooltip2"] = "Muestra el material de sastrería en el mapa y la brújula.",
	["pintype3"] = "Piedras rúnicas y portales Psijic",
	["pintypetooltip3"] = "Muestra las piedras rúnicas y los portales Psijic en el mapa y la brújula.",
	["pintype4"] = "Hongos",
	["pintypetooltip4"] = "Mostrar hongos en el mapa y la brújula.",
	["pintype13"] = "Hierbas/Flores",
	["pintypetooltip13"] = "Muestra hierbas y flores en el mapa y la brújula.",
	["pintype14"] = "Hierbas acuáticas",
	["pintypetooltip14"] = "Mostrar hierbas acuáticas en el mapa y la brújula.",
	["pintype5"] = "Madera",
	["pintypetooltip5"] = "Muestra madera en el mapa y la brújula.",
	["pintype6"] = "Cofres",
	["pintypetooltip6"] = "Muestra los cofres en el mapa y la brújula.",
	["pintype7"] = "Solventes",
	["pintypetooltip7"] = "Muestra los solventes en el mapa y la brújula.",
	["pintype8"] = "Ubicaciones de pesca",
	["pintypetooltip8"] = "Mostrar ubicaciones de pesca en el mapa y la brújula.",
	["pintype9"] = "Sacos pesados",
	["pintypetooltip9"] = "Muestra sacos pesados en el mapa y la brújula.",
	["pintype10"] = "Arcas de Ladrón",
	["pintypetooltip10"] = "Mostrar Arcas de Ladrón en el mapa y la brújula.",
	["pintype11"] = "Contenedores de justicia",
	["pintypetooltip11"] = "Muestre los Contenedores de Justicia como Safeboxes o los objetivos de Heist en el mapa y la brújula.",
	["pintype12"] = "Alijos ocultos",
	["pintypetooltip12"] = "Muestre Alijos ocultos como 'Paneles perdidos' en el mapa y la brújula.",
	["pintype15"] = "Almejas gigantes",
	["pintypetooltip15"] = "Muestra almejas gigantes en el mapa y la brújula.",

	-- extra map filter buttons
	["deletepinfilter"] = "Eliminar los pines de HarvestMap",
	["filterheatmap"] = "Modo de mapa de calor",
	
	-- localization for the farming helper
	["goldperminute"] = "Oro por minuto:",
	["farmresult"] = "Resultado HarvestFarm",
	["farmnotour"] = "HarvestFarm no pudo calcular una buena ruta de cultivo con la longitud mínima de ruta dada.",
	["farmerror"] = "Error HarvestFarm",
	["farmnoresources"] = "No se encontraron recursos.\nNo hay recursos en este mapa o no tiene ningún tipo de recurso seleccionado.",
	["farminvalidmap"] = "La herramienta auxiliar agrícola no se puede usar en este mapa.",
	["farmsuccess"] = "Harvest Farm calculó un recorrido de cultivo con <<1>> nodos por kilómetro.\n\nHaga clic en uno de los pines del recorrido para establecer el punto de partida de la excursión..",
	["farmdescription"] = "HarvestFarm calculará un recorrido con una relación muy alta de recursos por tiempo.\nDespués de generar un recorrido, haga clic en uno de los recursos seleccionados para establecer el punto de inicio de la excursión.",
	["farmminlength"] = "Longitud mínima de ruta",
	["farmminlengthtooltip"] = "La duración mínima de la excursión en kilómetros.",
	["farmminlengthdescription"] = "Mientras más largo sea el recorrido, mayores serán las posibilidades de que los recursos hayan reaparecido cuando comiences el próximo ciclo.\nSin embargo, un recorrido más corto tendrá una mejor relación de recursos por tiempo.",
	["tourpin"] = "Siguiente objetivo de tu recorrido",
	["calculatetour"] = "Calcular recorrido",
	["showtourinterface"] = "Mostrar interfaz de recorrido",
	["canceltour"] = "Cancelar recorrido",
	["reverttour"] = "Revertir la dirección del recorrido",
	["resourcetypes"] = "Tipos de recursos",
	["skiptarget"] = "Saltar el objetivo actual",
	["removetarget"] = "Eliminar objetivo actual",
	["nodesperminute"] = "Nodos por minuto",
	["distancetotarget"] = "Distancia al próximo recurso",
	["showarrow"] = "Dirección de visualización",
	["removetour"] = "Eliminar recorrido",
	["undo"] = "Deshacer el último cambio",
	["tourname"] = "Nombre del recorrido:",
	["defaultname"] = "Recorrido sin nombre",
	["savedtours"] = "Recorrido guardados para este mapa:",
	["notourformap"] = "No hay recorrido guardado para este mapa.",
	["load"] = "Cargar",
	["delete"] = "Borrar",
	["saveexiststitle"] = "Por favor confirma",
	["saveexists"] = "Ya hay un recorridocon el nombre <<1>> para este mapa. ¿Quieres sobreescribirlo?",
	["savenotour"] = "No hay recorrido que pueda ser guardado.",
	["loaderror"] = "El recorrido no pudo ser cargada.",
	["removepintype"] = "¿Quieres eliminar <<1>> del recorrido?",
	["removepintypetitle"] = "Confirmar la eliminación",
	
	-- extra harvestmap menu
	["pinvisibilitymenu"] = "Menú de filtro del pin extendido",
	["menu"] = "Menú de HarvestMap",
	["farmmenu"] = "Editor de recorrido de Farmeo",
	["editordescription"] = [[En este menú, puedes crear y editar recorridos.
Si actualmente no hay otro recorrido activo, puede crear un recorrido haciendo clic en los pines del mapa.
Si hay un recorrido activo, puede editar el recorrido reemplazando subsecciones:
- Primero haz clic en un pin de tu recorrido (rojo).
- Luego, haz clic en los pines que quieras agregar a tu recorrido. (Aparecerá un recorrido verde)
- Finalmente, haz clic en un pin de tu recorrido rojo otra vez.
El recorrido verde ahora se insertará en el recorrido rojo.]],
	["editorstats"] = [[Número de nodos: <<1>>
Longitud: <<2>> m
Nodos por kilómetro: <<3>>]],
	
	-- SI names to fit with ZOS api
	["SI_BINDING_NAME_SKIP_TARGET"] = "Saltar objetivo",
	["SI_BINDING_NAME_TOGGLE_WORLDPINS"] = "Alternar pines 3D",
	["SI_BINDING_NAME_TOGGLE_MAPPINS"] = "Alternar los pines del mapa",
	["SI_BINDING_NAME_HARVEST_SHOW_PANEL"] = "Alternar el menú Pin de HarvestMap",
	["SI_HARVEST_CTRLC"] = "Presione CTRL+C para copiar el texto",
	["HARVESTFARM_GENERATOR"] = "Generar nuevo recorrido",
	["HARVESTFARM_EDITOR"] = "Editar recorrido",
	["HARVESTFARM_SAVE"] = "Guardar/Cargar recorrido",
}

local default = Harvest.defaultLocalizedStrings
local current = Harvest.localizedStrings or {}

function Harvest.GetLocalization(tag)
	-- return the localization for the given tag,
	-- if the localization is missing, use the english string instead
	-- if the english string is missing, something went wrong.
	-- return the tag so that at least some string is returned to prevent the addon from crashing
	return (current[ tag ] or default[ tag ]) or tag
end

local UIStrings = {"SI_BINDING_NAME_SKIP_TARGET", "SI_BINDING_NAME_TOGGLE_WORLDPINS", "SI_BINDING_NAME_TOGGLE_MAPPINS", "SI_BINDING_NAME_HARVEST_SHOW_PANEL",
		"SI_HARVEST_CTRLC", "HARVESTFARM_GENERATOR","HARVESTFARM_EDITOR","HARVESTFARM_SAVE"}
for _, str in pairs(UIStrings) do
	ZO_CreateStringId(str, Harvest.GetLocalization(str))
end
