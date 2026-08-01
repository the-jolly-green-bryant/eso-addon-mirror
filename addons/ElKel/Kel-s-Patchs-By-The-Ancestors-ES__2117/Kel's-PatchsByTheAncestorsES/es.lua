local Addon						= _G['ByTheAncestors'] -- grab addon table from global
local L							= {}

-- tooltips
L.Tooltip_Known					= "Recogido"
L.Tooltip_SetWaypoint			= "Establecer waypoint a la tumba ancestral"
-- appearance
L.Appearance_PinSize			= "Tamaño del pin"
L.Appearance_PinSize_Desc		= "Establecer el tamaño de los pines del mapa."
L.Appearance_PinLayer			= "Capa del pin"
L.Appearance_PinLayer_Desc		= "Establecer la capa de los pines del mapa cuando están en las mismas coordenadas que otros"
-- compass
L.Compass_Unknown				= "Mostrar tumbas en la brújula."
L.Compass_Unknown_Desc			= "Mostrar/ocultar iconos para tumbas no recogidas en la brújula."
L.Compass_Dist					= "Distancia máxima de pin"
L.Compass_Dist_Desc				= "La distancia máxima para que aparezcan los pines en la brújula."
-- filters
L.Filters_Unknown				= "Mostrar tumbas ancestrales desconocidas"
L.Filters_Unknown_Desc			= "Mostrar/ocultar iconos de tumbas ancestrales desconocidas en el mapa."
L.Filters_Collected				= "Mostrar tumbas ancestrales recogidas"
L.Filters_Collected_Desc		= "Mostrar/ocultar iconos de tumbas ancestrales ya recogidas en el mapa."
-- worldmap filters
L.MapFilters_Unknown			= "Tumbas ancestrales desconocidas"
L.MapFilters_Collected			= "Tumbas ancestrales recogidas"


function Addon:GetLocale() -- default locale, will be the return unless overwritten
	return L
end


if (GetCVar('language.2') == 'es') then -- overwrite GetLocale for new language
	for k, v in pairs(Addon:GetLocale()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function Addon:GetLocale() -- set new locale return
		return L
	end
end
