local Addon						= _G['ByTheAncestors'] -- grab addon table from global
local L							= {}

-- tooltips
L.Tooltip_Known					= "Collected"
L.Tooltip_SetWaypoint			= "Set waypoint to ancestral tomb"
-- appearance
L.Appearance_PinSize			= "Pin size"
L.Appearance_PinSize_Desc		= "Set the size of the map pins."
L.Appearance_PinLayer			= "Pin layer"
L.Appearance_PinLayer_Desc		= "Set the layer of the map pins when they are at same coordinates than others"
-- compass
L.Compass_Unknown				= "Show tombs on the compass."
L.Compass_Unknown_Desc			= "Show/hide icons for uncollected tombs on the compass."
L.Compass_Dist					= "Max pin distance"
L.Compass_Dist_Desc				= "The maximum distance for pins to appear on the compass."
-- filters
L.Filters_Unknown				= "Show unknown ancestral tombs"
L.Filters_Unknown_Desc			= "Show/hide icons for unknown ancestral tombs on the map."
L.Filters_Collected				= "Show collected ancestral tombs"
L.Filters_Collected_Desc		= "Show/hide icons for already collected ancestral tombs on the map."
-- worldmap filters
L.MapFilters_Unknown			= "Unknown Ancestral Tombs"
L.MapFilters_Collected			= "Collected Ancestral Tombs"


function Addon:GetLocale() -- default locale, will be the return unless overwritten
	return L
end


--if (GetCVar('language.2') == 'de') then -- overwrite GetLocale for new language
--	for k, v in pairs(Addon:GetLocale()) do
--		if (not L[k]) then -- no translation for this string, use default
--			L[k] = v
--		end
--	end
--
--	function Addon:GetLocale() -- set new locale return
--		return L
--	end
--end