
Harvest.defaultLocalizedStrings = {
	mappins = "Display pins on main map",
	minimappins = "Display pins on mini map",
	minimappinstooltip2 = "This setting affects minimap addons, such as Votan's minimap.\nFor example, you can show pins on the minimap to see nearby resources, while turning pins off on the main map.",
	compass = "Display pins on compass",
	worldpins = "Display pins in 3D world",
	seethroughwalls = "See through walls",
	seethroughwallstooltip = "When enabled, the 3D pins will be visible through walls and other objects.",
	
	spawnfilter = "Spawned Resource Filters",
	nodedetectionmissing = "These options can only be enabled, if the 'NodeDetection' library is enabled.",
	spawnfilterdescription = [[When enabled, HarvestMap will hide pins for resources that have not respawned yet. For example if another player already harvested the resource, then the pin will be hidden until the resource is available again.
- This option works only for harvestable resources. HarvestMap cannot detect containers such as chests, heavy sacks, or psijic portals.
- HarvestMap can only detect nearby resources within ~100m.]],
	spawnfilter_map = "Use filter on main map",
	spawnfilter_minimap = "Use filter on minimap",
	spawnfilter_compass = "Use filter for compass pins",
	spawnfilter_world = "Use filter for 3D pins",
	
	worldBaseTexture = "Base of 3D pins",
	pinoptions = "Pin Type Options",
	pinsize = "Pin size",
	pincolor = "Pin color",
	pintexture = "Pin icon",
	
	pintype1 = "Smithing and Jewelry",
	pintype2 = "Clothing",
	pintype3 = "Runes and Psijic Portals",
	pintype4 = "Mushrooms",
	pintype13 = "Herbs/Flowers",
	pintype14 = "Water herbs",
	pintype5 = "Wood",
	pintype6 = "Chests",
	pintype7 = "Solvents",
	pintype8 = "Fishing spots",
	pintype9 = "Heavy Sacks",
	pintype10 = "Thieves Troves",
	pintype11 = "Justice Containers",
	pintype12 = "Hidden Stashes",
	pintype15 = "Giant Clams",
	-- pin type 16, 17 used to be jewlry and psijic portals 
	-- but the locations are the same as smithing and runes
	pintype18 = "Unknown node",
	pintype19 = "Crimson Nirnroot",
	pintype20 = "Herbalist's Satchel"
}

local default = Harvest.defaultLocalizedStrings
local current = Harvest.localizedStrings or {}

function Harvest.GetLocalization(tag)
	-- return the localization for the given tag,
	-- if the localization is missing, use the english string instead
	-- if the english string is missing, something went wrong.
	-- return the tag so that at least some string is returned to prevent the addon from crashing
	return (current[ tag ] or default[ tag ]) or tag
end
