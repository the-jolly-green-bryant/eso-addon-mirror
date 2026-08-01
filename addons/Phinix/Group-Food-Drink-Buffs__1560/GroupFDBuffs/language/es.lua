local GroupFDB = _G['GroupFDB']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Spanish
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

-- Panel Strings.
L.GroupFDB_Title			= "Alimentos para grupos y bebidas"
L.GroupFDB_GOpts			= "Opciones globales"
L.GroupFDB_SGF				= "Monitoreo marcos de grupo"
L.GroupFDB_SGFD				= "Mostrar los iconos de alimentos de bebidas en los marcos de unidades de grupo."
L.GroupFDB_SRF				= "Monitoreo marcos de banda"
L.GroupFDB_SRFD				= "Mostrar la comida de los iconos de bebida en los marcos de unidades de ataque."
L.GroupFDB_SAB				= "Mostrar indicador de efecto activo"
L.GroupFDB_SABD				= "Muestre el ícono de la comida o bebida activa en los marcos de grupo y raid."
L.GroupFDB_SJB				= "Mostrar indicador desperdicio de basura"
L.GroupFDB_SJBD				= "Muestre el ícono de comida chatarra o bebida activa en los marcos de grupo y de raid."
L.GroupFDB_SNB				= "Mostrar indicador de falta faltante"
L.GroupFDB_SNBD				= "Muestre un ícono rojo en los marcos de grupo e incursión cuando un miembro no tiene comida o bebida activa."
L.GroupFDB_GMode			= "Modo Buff Grupo"
L.GroupFDB_GModeD			= "Seleccione el módulo de soporte para los marcos de unidades de grupo que utiliza actualmente. Por defecto son los cuadros normales del juego."
L.GroupFDB_RMode			= "Modo Buff de banda"
L.GroupFDB_RModeD			= "Seleccione el módulo de soporte para los marcos de unidad de raid que utiliza actualmente. Por defecto son los cuadros normales del juego."
L.GroupFDB_GIS				= "Tamaño de icono de grupo"
L.GroupFDB_GISD				= "Tamaño del ícono de comida/bebida cuando se muestra en marcos de grupo estándar, como un múltiplo de 8 píxeles."
L.GroupFDB_RIS				= "Tamaño del Icono de Raid"
L.GroupFDB_RISD				= "Tamaño del ícono de comida/bebida cuando se muestra en marcos de ataque estándar, como un múltiplo de 8 píxeles."
L.GroupFDB_GXIO				= "Grupo horizontal desplazamiento de iconos"
L.GroupFDB_GXIOD			= "Ajusta la posición del ícono de comida/bebida del marco grupal de izquierda a derecha"
L.GroupFDB_GYIO				= "Grupo vertical desplazamiento de iconos"
L.GroupFDB_GYIOD			= "Ajusta la posición del ícono de comida/bebida del marco de grupo hacia arriba y hacia abajo."
L.GroupFDB_RXIO				= "Raid horizontal desplazamiento de iconos"
L.GroupFDB_RXIOD			= "Ajusta la posición del ícono de comida/bebida del marco de banda de izquierda a derecha."
L.GroupFDB_RYIO				= "Raid vertical desplazamiento de iconos"
L.GroupFDB_RYIOD			= "Ajusta la posición del ícono de comida/bebida del marco de banda arriba y abajo."

-- Group frame support options
L.GroupFDB_Mode1			= "Defecto"
--L.GroupFDB_Mode2			= "Foundry Tactical Combat"
--L.GroupFDB_Mode3			= "Lui Extended"
--L.GroupFDB_Mode4			= "Bandits User Interface"


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'es') then -- overwrite GetLanguage for new language
	for k,v in pairs(GroupFDB:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function GroupFDB:GetLanguage() -- set new language return
		return L
	end
end
