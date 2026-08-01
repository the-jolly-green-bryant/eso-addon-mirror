
-- constants/enums for the pin types
Harvest.BLACKSMITH = 1 -- also jewelry
Harvest.CLOTHING = 2
Harvest.ENCHANTING = 3 -- also psijic portals
Harvest.MUSHROOM = 4 -- used to be alchemy
Harvest.WOODWORKING = 5
Harvest.CHESTS = 6
Harvest.WATER = 7
Harvest.FISHING = 8
Harvest.HEAVYSACK = 9
Harvest.TROVE = 10
Harvest.JUSTICE = 11
Harvest.STASH = 12 -- loose panels etc
Harvest.FLOWER = 13
Harvest.WATERPLANT = 14
Harvest.CLAM = 15
-- psijic portals spawn at runestone locations
Harvest.PSIJIC = 16
-- jewelry material spawns at blacksmithing location
Harvest.JEWELRY = 17
Harvest.UNKNOWN = 18
Harvest.CRIMSON = 19
Harvest.HERBALIST = 20

Harvest.TOUR = 100 -- pin which displays the next resource of the farming tour

-- order in which pins are displayed in the filters etc
Harvest.PINTYPES = {
	Harvest.BLACKSMITH, Harvest.CLOTHING,
	Harvest.WOODWORKING, Harvest.ENCHANTING,
	Harvest.MUSHROOM, Harvest.FLOWER, Harvest.WATERPLANT, 
	Harvest.HERBALIST, Harvest.CRIMSON, 
	Harvest.WATER, 
	Harvest.CLAM,
	Harvest.CHESTS,
	Harvest.HEAVYSACK,
	Harvest.TROVE, Harvest.JUSTICE, Harvest.STASH,
	--Harvest.FISHING, Harvest.TOUR,
}

-- pinTypes that can be detected via eso's MAP_PIN_TYPE_HARVEST_NODE api
Harvest.HARVEST_NODES = {
	[Harvest.BLACKSMITH] = true,
	[Harvest.CLOTHING] = true,
	[Harvest.WOODWORKING] = true,
	[Harvest.ENCHANTING] = true,
	[Harvest.MUSHROOM] = true,
	[Harvest.FLOWER] = true,
	[Harvest.WATERPLANT] = true,
	[Harvest.HERBALIST] = true,
	[Harvest.WATER] = true,
	[Harvest.CRIMSON] = true,
}

-- translates pintypes, e.g. LibNodeDetection.pinTypes.BLACKSMITH to Harvest.BLACKSMITH
Harvest.DETECTION_TO_HARVEST_PINTYPE = {}
if LibNodeDetection then
	for key, value in pairs(LibNodeDetection.pinTypes) do
		if type(key) == "string" and type(value) == "number" then
			Harvest.DETECTION_TO_HARVEST_PINTYPE[value] = Harvest[key]
		end
	end
end

-- pisjic portals are saved as enchanting/runestones
Harvest.PINTYPE_ALIAS = {
	[Harvest.PSIJIC] = Harvest.ENCHANTING,
	[Harvest.JEWELRY] = Harvest.BLACKSMITH,
}

-- herbalist bags contain multiple other resource types
Harvest.COMBINED_PINTYPE = {
	[Harvest.HERBALIST] = {
		[Harvest.WATERPLANT] = true,
		[Harvest.FLOWER] = true,
		[Harvest.MUSHROOM] = true,
		[Harvest.CRIMSON] = true,
	},
}

-- pin types that are not displayed
Harvest.HIDDEN_PINTYPES = {
	[Harvest.TOUR] = true,
	[Harvest.PSIJIC] = true,
	[Harvest.JEWELRY] = true,
	[Harvest.UNKNOWN] = true,
}

Harvest.FILTER_ONLY_IF_NODE_EXISTS = {
	[Harvest.CRIMSON] = true,
	[Harvest.CLAM] = true,
	[Harvest.STASH] = true,
	[Harvest.HERBALIST] = true,
}
