local DLAddon = _G['DLAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Spanish
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

-- General strings
L.DLAddon_UnitAdded			= "añadido a la Lista de Muertes."
L.DLAddon_ToAddPlayers		= "Debe habilitar la opción para agregar jugadores a la Lista de Muertes."
L.DLAddon_NotAttackable		= "Objetivo no atacable."
L.DLAddon_NoGuards			= "No se pueden agregar guardias invulnerables a la Lista de Muertes."
L.DLAddon_ListCleared		= "Todos los objetivos de la Lista de Muertes eliminados."
L.DLAddon_ListEmpty			= "No hay nombres en tu Lista de Muertes."
L.DLAddon_Removed			= "fue eliminado de tu Lista de Muertes."
L.DLAddon_NoExist			= "El objetivo no existe en tu Lista de Muertes."

-- Settings panel
L.DLAddon_ShowMarker		= "Mostrar carácter de marcado"
L.DLAddon_ShowMarkerTip		= "Muestra el nombre del personaje que agregó el objetivo a la Lista de muertes."
L.DLAddon_MarkPlayers		= "Permitir a los jugadores de marcado"
L.DLAddon_MarkPlayersTip	= "Te permite agregar otros jugadores a la Lista de Muertes."
L.DLAddon_ShowDebug			= "Mostrar depuración"
L.DLAddon_ShowDebugTip		= "Muestra notificaciones de chat al realizar funciones de Lista de Muertes."
L.DLAddon_MarkColor			= "Elegir icono de color"
L.DLAddon_MarkColorTip		= "Establecer el color para el icono de destino marcado Lista de Muertes."
L.DLAddon_TextColor			= "Elija el color del texto"
L.DLAddon_TextColorTip		= "Establece el color para el nombre del personaje que agregó el objetivo a la Lista de muertes."
L.DLAddon_MarkSize			= "Elija el tamaño del icono"
L.DLAddon_MarkSizeTip		= "Establezca el tamaño del icono de destino marcado de lista de muerte."
L.DLAddon_ChatCommants		= "Comandos de chat"
L.DLAddon_PrintList			= "Imprime el contenido de tu Lista de Muertes."
L.DLAddon_RemoveName		= "Eliminar el nombre especificado de la lista de fallecidos (sin comillas)."
L.DLAddon_ClearList			= "Borrar todos los objetivos de tu Lista de Muertes."
L.DLAddon_Name				= "Nombre"


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'es') then -- overwrite GetLanguage for new language
	for k,v in pairs(DLAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function DLAddon:GetLanguage() -- set new language return
		return L
	end
end
