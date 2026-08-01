
local Settings = Harvest.settings

Settings.defaultGlobalSettings = {
	maxTimeDifference = 0,
	minGameVersion = 0,
}

assert(Harvest.GetLocalization("defaultprofilename"))
Settings.defaultFilterProfile = {
	name = Harvest.GetLocalization("defaultprofilename"),
	[Harvest.UNKNOWN]        = false,
	[Harvest.BLACKSMITH]     = true,
	[Harvest.CLOTHING]       = true,
	[Harvest.ENCHANTING]     = true,
	[Harvest.MUSHROOM]       = true,
	[Harvest.FLOWER]         = true,
	[Harvest.WATERPLANT]     = true,
	[Harvest.WOODWORKING]    = true,
	[Harvest.CHESTS]         = true,
	[Harvest.WATER]          = true,
	[Harvest.FISHING]        = true,
	[Harvest.HEAVYSACK]      = true,
	[Harvest.TROVE]          = true,
	[Harvest.JUSTICE]        = true,
	[Harvest.STASH]          = true,
	[Harvest.CLAM]           = true,
	[Harvest.PSIJIC]         = true,
	[Harvest.JEWELRY]        = true,
	[Harvest.CRIMSON]        = true,
	[Harvest.HERBALIST]      = true,
}

Settings.defaultSettings = {
	
	pinLayouts = {
		[Harvest.UNKNOWN]     = { texture = "esoui/art/icons/poi/poi_crafting_complete.dds", size = 20, tint = ZO_ColorDef:New(1.000, 1.000, 1.000) },
		[Harvest.BLACKSMITH]  = { texture = "HarvestMapConsole/Textures/Map/mining.dds",            size = 20, tint = ZO_ColorDef:New(0.447, 0.490, 1.000) },
		[Harvest.CLOTHING]    = { texture = "HarvestMapConsole/Textures/Map/clothing.dds",          size = 20, tint = ZO_ColorDef:New(0.588, 0.988, 1.000) },
		[Harvest.ENCHANTING]  = { texture = "HarvestMapConsole/Textures/Map/enchanting.dds",        size = 20, tint = ZO_ColorDef:New(1.000, 0.455, 0.478) },
		[Harvest.MUSHROOM]    = { texture = "HarvestMapConsole/Textures/Map/mushroom.dds",          size = 20, tint = ZO_ColorDef:New(0.451, 0.569, 0.424) },
		[Harvest.FLOWER]   	  = { texture = "HarvestMapConsole/Textures/Map/flower.dds",            size = 20, tint = ZO_ColorDef:New(0.557, 1.000, 0.541) },
		[Harvest.WATERPLANT]  = { texture = "HarvestMapConsole/Textures/Map/waterplant.dds",        size = 20, tint = ZO_ColorDef:New(0.439, 0.937, 0.808) },
		[Harvest.WOODWORKING] = { texture = "HarvestMapConsole/Textures/Map/wood.dds",              size = 20, tint = ZO_ColorDef:New(1.000, 0.694, 0.494) },
		[Harvest.CHESTS]      = { texture = "HarvestMapConsole/Textures/Map/chest.dds",             size = 20, tint = ZO_ColorDef:New(1.000, 0.937, 0.380) },
		[Harvest.WATER]       = { texture = "HarvestMapConsole/Textures/Map/solvent.dds",           size = 20, tint = ZO_ColorDef:New(0.569, 0.827, 1.000) },
		[Harvest.FISHING]     = { texture = "HarvestMapConsole/Textures/Map/fish.dds",              size = 20, tint = ZO_ColorDef:New(1.000, 1.000, 1.000) },
		[Harvest.HEAVYSACK]   = { texture = "HarvestMapConsole/Textures/Map/heavysack.dds",         size = 20, tint = ZO_ColorDef:New(0.424, 0.690, 0.360) },
		[Harvest.TROVE]       = { texture = "HarvestMapConsole/Textures/Map/trove.dds",             size = 20, tint = ZO_ColorDef:New(0.780, 0.404, 1.000) },
		[Harvest.JUSTICE]     = { texture = "HarvestMapConsole/Textures/Map/justice.dds",           size = 20, tint = ZO_ColorDef:New(1.000, 1.000, 1.000) },
		[Harvest.STASH]       = { texture = "HarvestMapConsole/Textures/Map/stash.dds",             size = 20, tint = ZO_ColorDef:New(1.000, 1.000, 1.000) },
		[Harvest.CLAM]        = { texture = "HarvestMapConsole/Textures/Map/clam.dds",              size = 20, tint = ZO_ColorDef:New(1.000, 1.000, 1.000) },
		[Harvest.PSIJIC]      = { texture = "HarvestMapConsole/Textures/Map/stash.dds",             size = 20, tint = ZO_ColorDef:New(1.000, 1.000, 1.000) },
		[Harvest.JEWELRY]     = { texture = "HarvestMapConsole/Textures/Map/stash.dds",             size = 20, tint = ZO_ColorDef:New(1.000, 1.000, 1.000) },
		[Harvest.TOUR]        = { texture = "HarvestMapConsole/Textures/Map/tour.dds",              size = 32, tint = ZO_ColorDef:New(1.000, 0.000, 0.000) },
		[Harvest.CRIMSON]     = { texture = "HarvestMapConsole/Textures/Map/waterplant.dds",        size = 20, tint = ZO_ColorDef:New(0.933, 0.345, 0.537) },
		[Harvest.HERBALIST]   = { texture = "HarvestMapConsole/Textures/Map/alchemy.dds",           size = 20, tint = ZO_ColorDef:New(0.557, 1.000, 0.541) },
	},
	worldBaseTexture = "HarvestMapConsole/Textures/worldMarker.dds",
	displayCompassPins = true,
	displayWorldPins = true,
	displayMapPins = true,
	displayMinimapPins = true,
	
	compassFilterProfile = 1,
	mapFilterProfile = 1,
	worldFilterProfile = 1,
	
	compassSpawnFilter = true,
	worldSpawnFilter = true,
	mapSpawnFilter = false,
	minimapSpawnFilter = true,
	
	maxVisibleDistanceInMeters = 300,
	hasMaxVisibleDistance = false,
	
	compassDistanceInMeters = 100,
	worldDistanceInMeters = 100,
	worldPinDepth = false,
	worldPinHeight = 200,
	worldPinWidth = 100,
	minimapPinSize = 20,
	
	filterProfiles = {Settings.defaultFilterProfile},
}

Settings.defaultAccountSettings = {
	accountWideSettings = false,
}

for key, value in pairs(Settings.defaultSettings) do
	Settings.defaultAccountSettings[key] = value
end

Settings.availableTextures = {
	"HarvestMapConsole/Textures/Map/mining.dds",
	"/esoui/art/worldmap/map_ava_tabicon_oremine_down.dds",
	"HarvestMapConsole/Textures/Map/clothing.dds",
	"/esoui/art/tradinghouse/tradinghouse_materials_tailoring_mats_down.dds",
	"HarvestMapConsole/Textures/Map/enchanting.dds",
	"/esoui/art/crafting/enchantment_tabicon_essence_down.dds",
	"HarvestMapConsole/Textures/Map/mushroom.dds",
	"HarvestMapConsole/Textures/Map/flower.dds",
	"HarvestMapConsole/Textures/Map/waterplant.dds",
	"/esoui/art/crafting/alchemy_tabicon_reagent_down.dds",
	"HarvestMapConsole/Textures/Map/wood.dds",
	"/esoui/art/worldmap/map_ava_tabicon_woodmill_down.dds",
	"HarvestMapConsole/Textures/Map/chest.dds",
	"/esoui/art/inventory/inventory_tabicon_container_down.dds",
	"HarvestMapConsole/Textures/Map/solvent.dds",
	"/esoui/art/crafting/alchemy_tabicon_solvent_down.dds",
	"HarvestMapConsole/Textures/Map/heavysack.dds",
	"/esoui/art/tutorial/tutorial_idexicon_items_down.dds",
	"HarvestMapConsole/Textures/Map/trove.dds",
	"HarvestMapConsole/Textures/Map/justice.dds",
	"HarvestMapConsole/Textures/Map/stash.dds",
	"/esoui/art/inventory/inventory_icon_hiddenby.dds",
	"HarvestMapConsole/Textures/Map/clam.dds",
	"/esoui/art/ava/ava_rankicon64_brigadier.dds",
	"esoui/art/icons/poi/poi_crafting_complete.dds",
}

Settings.availableWorldBaseTextures = {
	"HarvestMapConsole/Textures/worldMarker.dds",
	"/esoui/art/ava/ava_rankicon64_tyro.dds",
	"nonexistingfile.dds", -- empty, in case someone doesnt want any base texture
}