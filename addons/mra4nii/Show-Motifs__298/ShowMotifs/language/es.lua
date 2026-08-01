local ShowMotifs = _G['ShowMotifs']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Spanish
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

-- Addon Setting Strings
L.GENERAL					= "General"
L.ICON_THEME				= "Tema de los iconos"
L.ICON_THEME_TOOLTIP		= "Elija Tema para los iconos.\n\nNota para los usuarios del complemento de Inventory Grid View: Los iconos no se muestran en el modo 'grid.'"
L.ICON_SIZE					= "Icono de Motivo Racial Tamaño"
L.ICON_SIZE_TOOLTIP			= "Establecer el tamaño de los iconos de motivos raciales"
L.ARMOR_ICON_SIZE			= "Tipo de armadura Tamaño del icono"
L.ARMOR_ICON_SIZE_TOOLTIP	= "Establecer el tamaño de los iconos de tipo de armadura"
L.II_POSITION				= "Posición icono de inventario"
L.II_POSITION_TOOLTIP		= "Establecer la posición de los iconos en relación con el borde izquierdo de la lista de inventario"
L.GSS_POSITION				= "Posición icono tienda gremio"
L.GSS_POSITION_TOOLTIP		= "Establezca la Posición para los iconos en relación con el borde izquierdo de la lista de resultados de búsqueda de tienda del gremio"
L.GSL_POSITION				= "Ícono de Listado de Gremio Posición"
L.GSL_POSITION_TOOLTIP		= "Establezca la Posición para los iconos en relación con el borde izquierdo del panel de listado de tiendas de gremio"
L.RACIAL					= "Mostrar icono de motivo racial"
L.RACIAL_TOOLTIP			= "Mostrar icono de motivo racial.\n\nNota para los usuarios del complemento de Inventory Grid View: los iconos no se muestran en el modo 'grid'"
L.ARMOR						= "Mostrar icono de tipo armadura"
L.ARMOR_TOOLTIP				= "Mostrar icono de tipo de armadura.\n\nNota para los usuarios del complemento de Inventory Grid View: los iconos no se muestran en el modo 'grid'"
L.LETTER					= "Utilizar letras"
L.LETTER_TOOLTIP			= "Mostrar letra en lugar de símbolos gráficos para el tipo de armadura"
L.COLOR						= "Usa color de calidad"
L.COLOR_TOOLTIP				= "Establecer el color de los iconos según la calidad del artículo."
L.TOOLTIP					= "Mostrar información herramientas"
L.TOOLTIP_TOOLTIP			= "Mostrar información sobre herramientas para los iconos en el mouse.\n\nNota para los usuarios del complemento de Inventory Grid View: los iconos no se muestran en el modo 'grid'"

------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'es') then -- overwrite GetLanguage for new language
	for k, v in pairs(ShowMotifs:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function ShowMotifs:GetLanguage() -- set new language return
		return L
	end
end
