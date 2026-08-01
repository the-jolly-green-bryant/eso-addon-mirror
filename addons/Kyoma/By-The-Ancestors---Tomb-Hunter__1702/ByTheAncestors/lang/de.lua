local Addon						= _G['ByTheAncestors'] -- grab addon table from global
local L							= {}

-- tooltips
L.Tooltip_Known 				= "Gesammelt" 
L.Tooltip_SetWaypoint 			= "Wegpunkt zum Ahnengrab setzen."

-- appearance
L.Appearance_PinSize 			= "Größe der Kartenmarkierung"
L.Appearance_PinSize_Desc 		= "Bestimmt die Größe der Kartenmarkierung auf der Karte."
L.Appearance_PinLayer 			= "Ebene der Kartenmarkierung"
L.Appearance_PinLayer_Desc		= "Bestimmt die Ebene der Kartenmarkierung."

-- compass
L.Compass_Unknown				= "Grabmale auf dem Kompass anzeigen."
L.Compass_Unknown_Desc 			= "Symbol für unbesuchte Gräber auf dem Kompass anzeigen/verbergen."
L.Compass_Dist					= "Maximale Markierungs-Entfernung."
L.Compass_Dist_Desc 			= "Die maximale Entfernung zum Anzeigen der Markierungen auf dem Kompass."

-- filters
L.Filters_Unknown 				= "Unbekannte Ahnengräber anzeigen/verbergen."
L.Filters_Unknown_Desc 			= "Symbol für unbesuchte Ahnengräber auf der Karte anzeigen/verbergen."
L.Filters_Collected				= "Bereits besuchte Ahnengräber auf dem Kompass anzeigen."
L.Filters_Collected_Desc		= "Symbol für bereits besuchte Gräber auf der Karte anzeigen/verbergen."

-- worldmap filters
L.MapFilters_Unknown 			= "Unbekannte Ahnengräber"
L.MapFilters_Collected 			= "Bekannte Ahnengräber"

if (GetCVar('language.2') == 'de') then -- overwrite GetLocale for new language
	for k, v in pairs(Addon:GetLocale()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function Addon:GetLocale() -- set new locale return
		return L
	end
end