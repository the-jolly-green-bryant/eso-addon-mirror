local DTAddon = _G['DTAddon']
local L = {}

--------------------------------------------------------------------------------------------------------------------
-- Spanish (Needs human translation!)
--------------------------------------------------------------------------------------------------------------------

-- General Strings
--	L.DTAddon_Title			= "Rastreador Mazmorra"
	L.DTAddon_CNorm			= "Completado Normal: "
	L.DTAddon_CVet			= "Veterano completado: "
	L.DTAddon_CNormI		= "Completado Normal I: "
	L.DTAddon_CNormII		= "Completado Normal II: "
	L.DTAddon_CVetI			= "Veterano completado I: "
	L.DTAddon_CVetII		= "Veterano completado II: "
L.DTAddon_CGChal		= "Punto de habilidad del desafío del grupo"
	L.DTAddon_CDBoss		= "Todos los jefes derrotados: "
	L.DTAddon_Unlock		= "Desbloquea a nivel: "
L.DTAddon_True			= "Cierto"
L.DTAddon_False			= "Falso"
L.DTAddon_None			= "Ninguno"
L.DTAddon_MQOPT1		= "Todos los personajes"
L.DTAddon_MQOPT2		= "Carácter Actual"
L.DTAddon_MQOPT3		= "No mostrar"
	L.DTAddon_CTOPT1		= "Mostrar ambos"
	L.DTAddon_CTOPT2		= "Solo completado"
	L.DTAddon_CTOPT3		= "Solo incompleto"
L.DTAddon_QComp			= "Misión Completado: "
L.DTAddon_QCompI		= "Misión I Completado: "
L.DTAddon_QCompII		= "Misión II Completado: "
L.DTAddon_AWide			= " (Toda la cuenta)"
L.DTAddon_QMQ			= "Seleccione misiones incompletas"
L.DTAddon_QMQTip		= "Seleccione mazmorras para las cuales el personaje actual aún no ha completado la búsqueda de puntos de habilidad."
L.DTAddon_QMQVTip		= "Si se verifica, la versión veterana de las mazmorras se selecciona para completar misiones de punto de habilidad (no recomendado).\n\n|cffffffNOTA|r: La búsqueda del punto de habilidad es la misma en modo normal y veterano y solo se puede completar una vez."

-- Account Options
	L.DTAddon_SHMComp		= "Mostrar finalización de modo difícil"
L.DTAddon_SHMCompD		= "Muestra un icono si ha completado el veterano seleccionado o el logro del modo difícil de prueba."
	L.DTAddon_STTComp		= "Mostrar finalización de prueba cronometrada"
L.DTAddon_STTCompD		= "Muestre un icono si ha completado el veterano seleccionado o el logro cronometrado de prueba."
	L.DTAddon_SNDComp		= "No mostrar la muerte completa"
L.DTAddon_SNDCompD		= "Muestre un icono si ha completado la mazmorra veterana seleccionada o la prueba sin logro de muerte."
	L.DTAddon_SGFComp		= "Finalización de facción de mazmorra grupal"
L.DTAddon_SGFCompD		= "Muestra el progreso actual hacia la completación de todas las mazmorras del grupo en la facción de la mazmorra resaltada."
	L.DTAddon_SLFGt			= "LFG: Mostrar Finalización de Mazmorra"
L.DTAddon_SLFGtD		= "Mostrar información de logros en el Grupo Finder ToolTip."
	L.DTAddon_SLFGd			= "LFG: Mostrar Descripción de la Mazmorra"
	L.DTAddon_SLFGdD		= "Muestra la descripción del juego de la mazmorra en la información sobre herramientas de LFG. Esto normalmente está oculto."
	L.DTAddon_SNComp		= "MAPA: Grupo normal finalización de mazmorras"
L.DTAddon_SNCompD		= "Mostrar si ha completado la mazmorra o la prueba en modo normal en la información sobre herramientas."
	L.DTAddon_SVComp		= "MAPA: Grupo veterano finalización de mazmorras"
L.DTAddon_SVCompD		= "Mostrar si ha completado la mazmorra o la prueba en el modo de veterano en la información sobre herramientas."
L.DTAddon_SGCCompM		= "MAPA: "
L.DTAddon_SGCComp		= "Punto de habilidad de mazmorra pública"
L.DTAddon_SGCCompD		= "Mostrar si su carácter actual ha completado el desafío del Grupo de Skillpoint Dungeon Public en la información sobre herramientas."
L.DTAddon_SDBComp		= "MAPA: Finalización jefe de mazmorra pública"
L.DTAddon_SDBCompD		= "Mostrar si ha derrotado a todos los jefes de la mazmorra pública en la ToolTip."
L.DTAddon_SDFComp		= "MAPA: Terminación pública mazmorra de facción"
L.DTAddon_SDFCompD		= "Muestra el progreso actual para completar todas las mazmorras públicas en el logro de la facción."
L.DTAddon_CNColor		= "Color Completado:"
L.DTAddon_CNColorD		= "Seleccione el color para el estado de finalización o los nombres de los personajes que han completado la búsqueda de puntos de habilidad de la mazmorra."
L.DTAddon_NNColor		= "Color Incompleto:"
L.DTAddon_NNColorD		= "Seleccione el color para el estado de finalización o los nombres de los personajes que NO han completado la misión de puntos de habilidad de la mazmorra."
L.DTAddon_QCompHead		= "Finalización de la misión de mazmorra"
L.DTAddon_QCompS		= "Mostrar misiones de mazmorra"
L.DTAddon_QCompSD		= "Elija si desea mostrar el estado de finalización de la misión de la mazmorra. Seleccione si desea mostrar el estado de todos los personajes o solo el actual.\n\nNOTA: Deberá iniciar sesión en cada personaje al menos una vez para que aparezcan en la lista de todos los personajes."
L.DTAddon_CTDROPDOWN	= "Formato de texto de finalización"
L.DTAddon_CTDROPDOWND	= "Si se muestran todos los personajes, elige si mostrar solo aquellos que han completado la búsqueda de puntos de habilidad de la mazmorra, solo aquellos que no la han completado o ambos (predeterminado)."
L.DTAddon_ALPHAN		= "Lista alfabética de nombres"
L.DTAddon_ALPHAND		= "Cuando está habilitado, las listas de finalización de información sobre herramientas se ordenarán alfabéticamente. De lo contrario, el orden de la lista coincide con el orden de creación de tus personajes."
L.DTAddon_CHighlight	= "Resaltar caracteres actual"
L.DTAddon_CHighlightD	= "Muestre un asterisco (*) y use el color de logros de caracteres actual para resaltar la finalización de Dungeon Quest para su carácter de registro actual al mostrar la lista."
L.DTAddon_HColor		= "Color de caracteres actual"
L.DTAddon_HColorD		= "Cambie el color para resaltar su carácter actual en la lista de nombres para la finalización de Dungeon Quest."

-- Character Tracking
L.DTAddon_CharTracking	= "Seguimiento de personajes"
L.DTAddon_TrackChar		= "Seguir el personaje actual"
L.DTAddon_TrackCharD	= "Incluir el personaje que inició sesión actualmente en el resumen de finalización de misión cuando "..L.DTAddon_QCompS.." esté configurado en "..L.DTAddon_MQOPT1..". Volver a habilitar mientras está conectado para volver a agregarlos."
L.DTAddon_TrackWarn		= "ADVERTENCIA: ¡Se recargará automáticamente la interfaz de usuario!"


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'es') then -- overwrite GetLanguage for new language
	for k,v in pairs(DTAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function DTAddon:GetLanguage() -- set new language return
		return L
	end
end
