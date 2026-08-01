--Translated by: Cisneros

Harvest.localizedStrings = {
	-- top level description
	esouidescription = "Para la descripción del addon y las preguntas frecuentes, visita la página del addon en esoui.com",
	openesoui = "Abrir ESOUI",
	exchangedescription2 = "Puedes descargar los datos más recientes de HarvestMap (ubicaciones de recursos) instalando el addon HarvestMap-Data. Para más información, consulta la descripción del addon en ESOUI.",
	
	notifications = "Notificaciones y Advertencias",
	notificationstooltip = "Muestra notificaciones y advertencias en la esquina superior derecha de la pantalla.",
	moduleerrorload = "El addon <<1>> está desactivado.\nNo hay datos disponibles para esta área.",
	moduleerrorsave = "El addon <<1>> está desactivado.\nLa ubicación del nodo no se guardó.",
	
	-- outdated data settings
	outdateddata = "Configuración de Datos Obsoletos",
	outdateddatainfo = "Estas configuraciones relacionadas con los datos se comparten entre todas las cuentas y personajes en esta computadora.",
	timedifference = "Mantener solo datos recientes",
	timedifferencetooltip = "HarvestMap solo mantendrá datos de los últimos X días.\nEsto evita mostrar datos antiguos que podrían estar obsoletos.\nEstablece en 0 para mantener todos los datos sin importar su antigüedad.",
	applywarning = "¡Una vez que se eliminen los datos antiguos, no se podrán recuperar!",
	
	-- account wide settings
	account = "Configuración Global de la Cuenta",
	accounttooltip = "Todas las configuraciones siguientes serán las mismas para todos tus personajes.",
	accountwarning = "Cambiar esta configuración recargará la interfaz de usuario.",
	
	-- map pin settings
	mapheader = "Configuración de Marcadores en el Mapa",
	mappins = "Mostrar marcadores en el mapa principal",
	minimappins = "Mostrar marcadores en el mini mapa",
	minimappinstooltip = "Minimapas compatibles: Votan, Fyrakin y AUI.",
	level = "Mostrar marcadores del mapa sobre los marcadores de PDI.",
	hasdrawdistance = "Mostrar solo marcadores cercanos en el mapa",
	hasdrawdistancetooltip = "Cuando está activado, HarvestMap solo creará marcadores para ubicaciones de recolección cercanas al jugador.\nEsta configuración solo afecta al mapa principal. ¡En los minimapas esta opción está automáticamente activada!",
	hasdrawdistancewarning = "¡Esta configuración solo afecta al mapa del juego. En los minimapas esta opción está automáticamente activada!",
	drawdistance = "Distancia de los marcadores en el mapa",
	drawdistancetooltip = "El umbral de distancia para el cual se dibujan los marcadores en el mapa. ¡Esta configuración también afecta a los minimapas!",
	drawdistancewarning = "¡Esta configuración también afecta a los minimapas!",
	
	visiblepintypes = "Tipos de marcadores visibles",
	custom_profile = "Personalizado",
	same_as_map = "Igual que en el mapa",
	
	-- compass settings
	compassheader = "Configuración de la Brújula",
	compass = "Mostrar marcadores en la brújula",
	compassdistance = "Distancia máxima de los marcadores",
	compassdistancetooltip = "La distancia máxima en metros para los marcadores que aparecen en la brújula.",
	
	-- 3d pin settings
	worldpinsheader = "Configuración de Marcadores 3D",
	worldpins = "Mostrar marcadores en el mundo 3D",
	worlddistance = "Distancia máxima de los marcadores 3D",
	worlddistancetooltip = "La distancia máxima en metros para las ubicaciones de recolección. Cuando una ubicación está más lejos, no se muestra un marcador 3D.",
	worldpinwidth = "Ancho de los marcadores 3D",
	worldpinwidthtooltip = "El ancho de los marcadores 3D en centímetros.",
	worldpinheight = "Altura de los marcadores 3D",
	worldpinheighttooltip = "La altura de los marcadores 3D en centímetros.",
	--worldpinsdepth = "Usar búfer de profundidad para los marcadores 3D",
	--worldpinsdepthtooltip = "Cuando está desactivado, los marcadores 3D serán visibles a través de paredes y otros objetos.",
	--worldpinsdepthwarning = "Debido a un error en ESO, esta opción no funciona cuando se selecciona una calidad de submuestreo media o baja en las opciones de video del juego.",
	worldpinsdepth = "Ver a través de paredes",
	worldpinsdepthtooltip = "Cuando está activado, los marcadores 3D serán visibles a través de paredes y otros objetos.",
	worldpinsdepthtext = "Desactivar \"ver a través de paredes\" solo funciona si\n1) La resolución del juego coincide con la resolución del monitor (en las opciones del juego o del controlador gráfico), y\n2) la calidad de submuestreo está configurada en alta en las opciones de video del juego.",
	
	
	-- respawn timer settings
	visitednodes = "Nodos Visitados y Ayuda para la Recolección",
	rangemultiplier = "Rango de los nodos visitados",
	rangemultipliertooltip = "Los nodos dentro de X metros se consideran como visitados por la ayuda de recolección y el temporizador de ocultación.",
	usehiddentime = "Ocultar nodos visitados recientemente",
	usehiddentimetooltip = "Los marcadores se ocultarán si visitaste su ubicación recientemente.",
	hiddentime = "Duración de la Ocultación",
	hiddentimetooltip = "Los nodos visitados recientemente se ocultarán durante X minutos.",
	hiddenonharvest = "Ocultar nodos solo después de recolectarlos",
	hiddenonharvesttooltip = "Activa esta opción para ocultar los marcadores solo cuando los recolectes. Cuando la opción está desactivada, los marcadores se ocultarán si los visitas.",
	
	-- spawn filter
	spawnfilter = "Filtros de Recursos Generados",
	nodedetectionmissing = "Estas opciones solo se pueden activar si la biblioteca 'NodeDetection' está habilitada.",
	spawnfilterdescription = [[Cuando está activado, HarvestMap ocultará los marcadores de recursos que aún no han reaparecido. Por ejemplo, si otro jugador ya recolectó el recurso, el marcador se ocultará hasta que el recurso esté disponible nuevamente.
- Esta opción solo funciona para materiales de elaboración recolectables.
- No funciona para contenedores como cofres, sacos pesados o portales psijic.
- El filtro no funciona si otro addon oculta o cambia la escala de la brújula.
- El addon no puede saber si un recurso reapareció en el otro lado del mapa. Por lo tanto, solo los recursos cercanos se mostrarán en el mapa.]],
	spawnfilter_map = "Usar filtro en el mapa principal",
	spawnfilter_minimap = "Usar filtro en el minimapa",
	spawnfilter_compass = "Usar filtro para los marcadores de la brújula",
	spawnfilter_world = "Usar filtro para los marcadores 3D",
	spawnfilter_pintype = "Activar filtro para tipos de marcadores:",
	
	-- pin type options
	pinoptions = "Opciones de Tipos de Marcadores",
	pinsize = "Tamaño del marcador",
	pinsizetooltip = "Establece el tamaño de los marcadores en el mapa.",
	pincolor = "Color del marcador",
	pincolortooltip = "Establece el color de los marcadores en el mapa y la brújula.",
	savepin = "Guardar ubicaciones",
	savetooltip = "Activa para guardar las ubicaciones de este recurso cuando las descubras.",
	pintexture = "Icono del marcador",
	
	-- pin type names
	pintype1 = "Herrería y Joyería",
	pintype2 = "Sastrería",
	pintype3 = "Runas y Portales Psijic",
	pintype4 = "Hongos",
	pintype13 = "Hierbas/Flores",
	pintype14 = "Hierbas acuáticas",
	pintype5 = "Madera",
	pintype6 = "Cofres",
	pintype7 = "Disolventes",
	pintype8 = "Puntos de pesca",
	pintype9 = "Sacos Pesados",
	pintype10 = "Tesoros de Ladrones",
	pintype11 = "Contenedores de Justicia",
	pintype12 = "Alijos Ocultos",
	pintype15 = "Almejas Gigantes",
	-- pin type 16, 17 solían ser joyería y portales psijic 
	-- pero las ubicaciones son las mismas que herrería y runas
	pintype18 = "Nodo desconocido",
	pintype19 = "Raíz de Nirn Carmesí",
	
	-- extra map filter buttons
	deletepinfilter = "Eliminar marcadores de HarvestMap",
	filterheatmap = "Modo mapa de calor",
	
	-- localization for the farming helper
	goldperminute = "Oro por minuto:",
	farmresult = "Resultado de HarvestFarm",
	farmnotour = "HarvestFarm no pudo calcular una buena ruta de recolección con la longitud mínima de ruta proporcionada.",
	farmerror = "Error de HarvestFarm",
	farmnoresources = "No se encontraron recursos.\nNo hay recursos en este mapa o no tienes seleccionado ningún tipo de recurso.",
	farmsuccess = "HarvestFarm calculó una ruta de recolección con <<1>> nodos por kilómetro.\n\nHaz clic en uno de los marcadores de la ruta para establecer el punto de inicio.",
	farmdescription = "HarvestFarm calculará una ruta con una relación muy alta de recursos por tiempo.\nDespués de generar una ruta, haz clic en uno de los recursos seleccionados para establecer el punto de inicio de la ruta.",
	farmminlength = "Longitud mínima",
	farmminlengthdescription = "Cuanto más larga sea la ruta, mayor será la probabilidad de que los recursos hayan reaparecido cuando comiences el siguiente ciclo.\nSin embargo, una ruta más corta tendrá una mejor relación de recursos por tiempo.\n(La longitud mínima se da en kilómetros).",
	tourpin = "Siguiente objetivo de tu ruta",
	calculatetour = "Calcular Ruta",
	showtourinterface = "Mostrar Interfaz de Ruta",
	canceltour = "Cancelar Ruta",
	reverttour = "Revertir Dirección de la Ruta",
	resourcetypes = "Tipos de Recursos",
	skiptarget = "Saltar objetivo actual",
	removetarget = "Eliminar objetivo actual",
	nodesperminute = "Nodos por minuto",
	distancetotarget = "Distancia al siguiente recurso",
	showarrow = "Mostrar dirección",
	removetour = "Eliminar Ruta",
	undo = "Deshacer último cambio",
	tourname = "Nombre de la ruta: ",
	defaultname = "Ruta sin nombre",
	savedtours = "Rutas guardadas para este mapa:",
	notourformap = "No hay una ruta guardada para este mapa.",
	load = "Cargar",
	delete = "Eliminar",
	saveexiststitle = "Por favor Confirma",
	saveexists = "Ya existe una ruta con el nombre <<1>> para este mapa. ¿Deseas sobrescribirla?",
	savenotour = "No hay ninguna ruta que se pueda guardar.",
	loaderror = "No se pudo cargar la ruta.",
	removepintype = "¿Deseas eliminar <<1>> de la ruta?",
	removepintypetitle = "Confirmar Eliminación",
	
	-- extra harvestmap menu
	farmmenu = "Editor de Rutas de Recolección",
	editordescription = [[En este menú, puedes crear y editar rutas.
Si actualmente no hay otra ruta activa, puedes crear una ruta haciendo clic en los marcadores del mapa.
Si hay una ruta activa, puedes editar la ruta reemplazando subsecciones:
- Primero, haz clic en un marcador de tu ruta (roja).
- Luego, haz clic en los marcadores que deseas agregar a tu ruta. (Aparecerá una ruta verde)
- Finalmente, haz clic en un marcador de tu ruta roja nuevamente.
La ruta verde se insertará en la ruta roja.]],
	editorstats = [[Número de nodos: <<1>>
Longitud: <<2>> m
Nodos por kilómetro: <<3>>]],

	-- filter profiles
	filterprofilebutton = "Abrir Menú de Perfiles de Filtro",
	filtertitle = "Menú de Perfiles de Filtro",
	filtermap = "Perfil de Filtro para Marcadores del Mapa",
	filtercompass = "Perfil de Filtro para Marcadores de la Brújula",
	filterworld = "Perfil de Filtro para Marcadores 3D",
	unnamedfilterprofile = "Perfil sin nombre",
	defaultprofilename = "Perfil de Filtro Predeterminado",
	
	-- SI names to fit with ZOS api
	SI_BINDING_NAME_SKIP_TARGET = "Saltar Objetivo",
	SI_BINDING_NAME_TOGGLE_WORLDPINS = "Alternar marcadores 3D",
	SI_BINDING_NAME_TOGGLE_MAPPINS = "Alternar marcadores del mapa",
	SI_BINDING_NAME_TOGGLE_MINIMAPPINS = "Alternar marcadores del minimapa",
	SI_BINDING_NAME_HARVEST_SHOW_PANEL = "Abrir Editor de Rutas de HarvestMap",
	SI_BINDING_NAME_HARVEST_SHOW_FILTER = "Abrir Menú de Filtro de HarvestMap",
	HARVESTFARM_GENERATOR = "Generar nueva ruta",
	HARVESTFARM_EDITOR = "Editar ruta",
	HARVESTFARM_SAVE = "Guardar/Cargar ruta",
}

-- these are the names of interactable objects that are displayed when the reticle/cursor hovers over them
-- this table assigns each such object a pin type
local interactableName2PinTypeId = {
	["saco pesado"] = Harvest.HEAVYSACK,
	-- special nodes in cold harbor with the same loot as heavy sacks
	["caja pesada"] = Harvest.HEAVYSACK,
	["Tesoro de los ladrones"] = Harvest.TROVE,
	["Panel suelto"] = Harvest.STASH,
	["Baldosa suelta"] = Harvest.STASH,
	["Piedra suelta"] = Harvest.STASH,
	["portal psijic"] = Harvest.PSIJIC,
	["almeja gigante"] = Harvest.CLAM,
	["bolsa de herborista"] = Harvest.HERBALIST,
}
-- convert to lower case. zos sometimes changes capitalization so it's safer to just do all the logic in lower case
Harvest.interactableName2PinTypeId = Harvest.interactableName2PinTypeId or {}
local globalList = Harvest.interactableName2PinTypeId
for name, pinTypeId in pairs(interactableName2PinTypeId) do
	globalList[zo_strlower(name)] = pinTypeId
end