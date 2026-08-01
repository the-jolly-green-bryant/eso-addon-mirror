
TrueExplor = TrueExplor or {}
TrueExplor.lang = TrueExplor.lang or {}

local language = {
	-- map menu
	discoverMap = "Discover entire map",
	clearMap = "Reset map exploration",
	debugCheckbox = "TrueExploration Debug Mode",
	
	-- dialog boxes
	newMapTitle = "Start fully hidden?",
	newMapBody = "Do you want to start with a completely hidden map?\nOr should areas near completed point of interests (quests, wayshrines, etc.) be discovered?",
	filled = "Discover near POI",
	empty = "Fully Hidden",
	
	clearTitle = "Confirm Reset",
	clearBody = "Do you want to reset exploration data for this map?\nThis can NOT be undone.",
	
	init = "Initialization",
	initBody = "The 'True Exploration' Add-On cannot know which areas you explored before the Add-On was installed.\nYou have two options how to initialize the addon:\nA) Completely hide all maps until you explore them again.\nB) Let the Add-On guess which areas you explored already by using your completed point of interests (quests, skyshards, wayshrines, etc.)",
	guessExploration = "Guess exploration",
	
	-- settings menu
	radiusSetting = "Radius Settings",
	dungeonRadius = "Dungeon Radius",
	dungeonRadiusDesc = "View distance in dungeons and delves.",
	townRadius = "Town Radius",
	townRadiusDesc = "View distance in towns.",
	islandRadius = "Island Radius",
	islandRadiusDesc = "View distance on starter island maps and in large cities.",
	zoneRadius = "Zone Radius",
	zoneRadiusDesc = "View distance on zone maps.",
	cyrodiilRadius = "Cyrodiil Radius",
	cyrodiilRadiusDesc = "View distance in Cyrodiil.",
	
	mapTypes = "Map Types",
	zone = "Enable Addon on zone maps",
	subzone = "Enable Addon on subzone maps",
	
	graphicSettings = "Graphical Settings",
	discovered = "Discovered Opacity",
	discoveredDesc = "0 = map completely visible,\n255 = map completely hidden.",
	undiscovered = "Undiscovered Opacity",
	undiscoveredDesc = "0 = map completely visible,\n255 = map completely hidden.",
	
	retroactive = "Guess explored areas",
	retroactiveDec = "The Add-On cannot know which areas your explored before the Add-On was installed. When viewing a map for the first time, there are two options:\n(*) 'Guess explored areas' = ON\nLet the Add-On guess which areas you explored already by using your completed quests, skyshards, wayshrines, etc.\n(*) 'Guess explored areas' = OFF\nNo guessing. The Add-On completely hides all maps until you explore them again.",
	resetLabel = "This setting affects maps that are viewed for the first time. If you want to reset an already viewed map:\n1) Open the map you want to reset,\n2) Open the map's filter tab ('Options' => 'Filters'),\n3) Select 'Reset map exploration'.",
}

for type, str in pairs(language) do
	TrueExplor.lang[type] = str
end
