local TBoxAddon = _G['TBoxAddon']
local pTC = TBoxAddon.TColor
TBoxAddon.DB = {}
TBoxAddon.AT = {}
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Spanish
-- (Requires human translation and may not make sense!)
------------------------------------------------------------------------------------------------------------------

-- General
	L.TBoxAddon_SEARCHBOX				= "Busque el tesoro por su nombre."
	L.TBoxAddon_CLOSE					= "Cerrar Treasure Box"
	L.TBoxAddon_TITLE					= "Treasure Box"
	L.TBoxAddon_RECENT					= "Encontrado recientemente:"
	L.TBoxAddon_FAVZONE					= "Zona superior:"
	L.TBoxAddon_UPDATE1					= "[TBox]: Se actualizó la base de datos de Treasure Box."
	L.TBoxAddon_UPDATE2					= "[TBox]: Por favor /reloadui para completar."
	L.TBoxAddon_UPDATE3					= "[TBox]: Por favor espere..."
	L.TBoxAddon_NOCATEGORY				= "Sin categorizar"
	L.TBoxAddon_RESETSEARCH				= "Haga clic en el botón para restablecer la búsqueda de texto.\n\n"..pTC("FFFFFF", "NOTA: ").."Se mantienen otros filtros."
	L.TBoxAddon_TFOUNDOFF				= pTC("00FF00", "Mostrar solo encontrado").." es"..pTC("FFFFFF", " ON").."\n\nHaga clic para alternar la visualización de TODOS los tesoros, ya sea que los haya encontrado o no."
	L.TBoxAddon_TFOUNDON				= pTC("00FF00", "Mostrar solo encontrado").." es"..pTC("FFFFFF", " OFF").."\n\nHaz clic para mostrar solo los tesoros que hayas encontrado en uno de tus personajes."
	L.TBoxAddon_RESETFILTER				= "Restablecer filtros"
	L.TBoxAddon_RQUALITYS1				= "Solo mostrar "
	L.TBoxAddon_RQUALITYS2				= " y artículos de mayor calidad en la lista Recientemente encontrado."
	L.TBoxAddon_UPDATING				= "[TBox]: Treasure Box actualización de la base de datos, no reinicie..."

-- Navigation
	L.TBoxAddon_TFOUND					= "Tesoro encontrado:"
	L.TBoxAddon_QUALITYHEAD				= "Calidad del tesoro:"
	L.TBoxAddon_TIMEHEAD				= "Tiempo encontrado:"
	L.TBoxAddon_TIMEDAYS1				= "Últimos"
	L.TBoxAddon_TIMEDAYS2				= "días"
	L.TBoxAddon_ANY						= "Todos"
	L.TBoxAddon_ALLTYPES				= "Categoría: Todos"
	L.TBoxAddon_ALLZONES				= "Encontrado en: Todos"
	L.TBoxAddon_ANYFOUND				= "Encontrado por: Todos"
	L.TBoxAddon_QUALITYS				= "Mostrar calidad: "
	L.TBoxAddon_QUALITY1				= "Normal"
	L.TBoxAddon_QUALITY2				= "Fine"
	L.TBoxAddon_QUALITY3				= "Superior"
	L.TBoxAddon_QUALITY4				= "Epic"
	L.TBoxAddon_QUALITY5				= "Legendary"
	L.TBoxAddon_FINZONES				= "Encontrado en zonas:"
	L.TBoxAddon_LFOUNDIN				= "Último encontrado en: "
	L.TBoxAddon_LFOUNDBY				= "Último encontrado por: "
	L.TBoxAddon_FOUNDON					= "Último encontrado: "
	L.TBoxAddon_TOTALF					= "Total encontrado: "
	L.TBoxAddon_NEVER					= "Nunca"
	L.TBoxAddon_NONE					= "Ninguno"
	L.TBoxAddon_UNKNOWN					= "Desconocida"
	L.TBoxAddon_SALPHA					= "Ordenar alfabéticamente"
	L.TBoxAddon_SFOUND					= "Ordenar por número encontrado"

-- Settings
	L.TBoxAddon_GOPTS					= "Opciones generales"
	L.TBoxAddon_CHARALPHA				= "Ordenar lista de personajes"
	L.TBoxAddon_CHARALPHAT				= "Habilitado muestra la lista de caracteres alfabéticamente. De lo contrario, utiliza el orden de selección de personajes del juego.\n\n"..pTC("FFFFFF", "NOTA: ").."El juego solo devuelve el orden de CREACIÓN de personajes. No rastrea los caracteres reordenados manualmente."
	L.TBoxAddon_USTIME					= "12 horas Tiempo"
	L.TBoxAddon_USTIMET					= "Cuando está habilitado, las marcas de tiempo de los tesoros encontrados anteriormente se mostrarán en formato de 12 horas con am/pm después de la hora. Desactivar para mostrar en horario de 24 horas (militar)."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'es') then -- overwrite GetLanguage for new language
	for k, v in pairs(TBoxAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function TBoxAddon:GetLanguage() -- set new language return
		return L
	end
end
