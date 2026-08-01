if not TrueExplor then
	TrueExplor = {}
	TrueExplor.lang = TrueExplor.lang or {}
end

local language = {
	chatCommands = "Chat Commands",
	chatCommandsDesc = "/discover, /undiscover, /clearmap, /tedebug [0,1]",
	radiusSetting = "Radius Settings",
	dungeonRadius = "Dungeon Radius",
	dungeonRadiusDesc = "Number of tiles that can be discovered at once on a dungeon map (map size <= 768)",
	townRadius = "Town Radius",
	townRadiusDesc = "Number of tiles that can be discovered at once on a town map (map size <= 1280)",
	islandRadius = "Island Radius",
	islandRadiusDesc = "Number of tiles that can be discovered at once on a island map (or large city) (map size <= 1536)",
	zoneRadius = "Zone Radius",
	zoneRadiusDesc = "Number of tiles that can be discovered at once on a zone map (map size <= 2048)",
	cyrodiilRadius = "Cyrodiil Radius",
	cyrodiilRadiusDesc = "Number of tiles that can be discovered at once on the Cyrodiil map (map size = 5120)",
	mapTypes = "Map Types",
		
	zone = "Enable Addon on zone maps",
	zoneDesc = "If NOT checked, zone maps will always be discovered.",
	subzone = "Enable Addon on subzone maps",
	subzoneDesc = "If NOT checked, subzone maps (dungeons, towns) will always be discovered.",
	graphicSettings = "Graphical Settings",
	discovered = "Discovered Opacity",
	discoveredDesc = "0 ~ map completely visible, 255 ~ map completely hidden.",
	undiscovered = "Undiscovered Opacity",
	undiscoveredDesc = "0 ~ map completely visible, 255 ~ map completely hidden.",
	
}

for type, string in pairs(language) do
	TrueExplor.lang[type] = string
end
