ElsweyrMuralMender = ElsweyrMuralMender or {}
local L							= {}

-- tooltips
L.Tooltip_Known					= "Collected"
L.Tooltip_SetWaypoint			= "Set waypoint to museum piece"
L.Tooltip_Kill					= "Kill"
L.Tooltip_TurnedIn				= "Delivered"
-- appearance
L.Appearance_PinSize			= "Pin size"
L.Appearance_PinSize_Desc		= "Set the size of the map pins."
L.Appearance_PinLayer			= "Pin layer"
L.Appearance_PinLayer_Desc		= "Set the layer of the map pins when they are at same coordinates than others"
-- compass
L.Compass_Unknown				= "Show locations on the compass."
L.Compass_Unknown_Desc			= "Show/hide icons for uncollected murals on the compass."
L.Compass_Dist					= "Max pin distance"
L.Compass_Dist_Desc				= "The maximum distance for pins to appear on the compass."
-- filters
L.Filters_Collected				= "Always show collected"
L.Filters_Collected_Desc		= "Will show already collected murals along side the uncollected ones. The pin tooltip will show its current status."
-- worldmap filters
L.MapFilters_All				= "Elsweyr: Mural Fragments"


function ElsweyrMuralMender:GetLocale() -- default locale, will be the return unless overwritten
	return L
end