
local Settings = Harvest.settings

Settings.defaultGlobalSettings = {
	maxTimeDifference = 0,
	minGameVersion = 0,
}

assert(Harvest.GetLocalization("defaultprofilename"))
Settings.defaultFilterProfile = {
	name = Harvest.GetLocalization("defaultprofilename"),
	[Harvest.UNKNOWN]        = true,
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
	isSpawnFilterUsedForPinType = {
		[Harvest.BLACKSMITH]     = true,
		[Harvest.CLOTHING]       = true,
		[Harvest.ENCHANTING]     = true,
		[Harvest.MUSHROOM]       = true,
		[Harvest.FLOWER]         = true,
		[Harvest.WATERPLANT]     = true,
		[Harvest.WOODWORKING]    = true,
		[Harvest.WATER]          = true,
		[Harvest.CRIMSON]        = true,
		[Harvest.HERBALIST]      = true,
	},

	pinLayouts = {
		[Harvest.UNKNOWN]     = { texture = "esoui/art/icons/poi/poi_crafting_complete.dds", size = 20, tint = ZO_ColorDef:New(1.000, 1.000, 1.000) },
		[Harvest.BLACKSMITH]  = { texture = "HarvestMap/Textures/Map/mining.dds",            size = 20, tint = ZO_ColorDef:New(0.447, 0.490, 1.000) },
		[Harvest.CLOTHING]    = { texture = "HarvestMap/Textures/Map/clothing.dds",          size = 20, tint = ZO_ColorDef:New(0.588, 0.988, 1.000) },
		[Harvest.ENCHANTING]  = { texture = "HarvestMap/Textures/Map/enchanting.dds",        size = 20, tint = ZO_ColorDef:New(1.000, 0.455, 0.478) },
		[Harvest.MUSHROOM]    = { texture = "HarvestMap/Textures/Map/mushroom.dds",          size = 20, tint = ZO_ColorDef:New(0.451, 0.569, 0.424) },
		[Harvest.FLOWER]   	  = { texture = "HarvestMap/Textures/Map/flower.dds",            size = 20, tint = ZO_ColorDef:New(0.557, 1.000, 0.541) },
		[Harvest.WATERPLANT]  = { texture = "HarvestMap/Textures/Map/waterplant.dds",        size = 20, tint = ZO_ColorDef:New(0.439, 0.937, 0.808) },
		[Harvest.WOODWORKING] = { texture = "HarvestMap/Textures/Map/wood.dds",              size = 20, tint = ZO_ColorDef:New(1.000, 0.694, 0.494) },
		[Harvest.CHESTS]      = { texture = "HarvestMap/Textures/Map/chest.dds",             size = 20, tint = ZO_ColorDef:New(1.000, 0.937, 0.380) },
		[Harvest.WATER]       = { texture = "HarvestMap/Textures/Map/solvent.dds",           size = 20, tint = ZO_ColorDef:New(0.569, 0.827, 1.000) },
		[Harvest.FISHING]     = { texture = "HarvestMap/Textures/Map/fish.dds",              size = 20, tint = ZO_ColorDef:New(1.000, 1.000, 1.000) },
		[Harvest.HEAVYSACK]   = { texture = "HarvestMap/Textures/Map/heavysack.dds",         size = 20, tint = ZO_ColorDef:New(0.424, 0.690, 0.360) },
		[Harvest.TROVE]       = { texture = "HarvestMap/Textures/Map/trove.dds",             size = 20, tint = ZO_ColorDef:New(0.780, 0.404, 1.000) },
		[Harvest.JUSTICE]     = { texture = "HarvestMap/Textures/Map/justice.dds",           size = 20, tint = ZO_ColorDef:New(1.000, 1.000, 1.000) },
		[Harvest.STASH]       = { texture = "HarvestMap/Textures/Map/stash.dds",             size = 20, tint = ZO_ColorDef:New(1.000, 1.000, 1.000) },
		[Harvest.CLAM]        = { texture = "HarvestMap/Textures/Map/clam.dds",              size = 20, tint = ZO_ColorDef:New(1.000, 1.000, 1.000) },
		[Harvest.PSIJIC]      = { texture = "HarvestMap/Textures/Map/stash.dds",             size = 20, tint = ZO_ColorDef:New(1.000, 1.000, 1.000) },
		[Harvest.JEWELRY]     = { texture = "HarvestMap/Textures/Map/stash.dds",             size = 20, tint = ZO_ColorDef:New(1.000, 1.000, 1.000) },
		[Harvest.TOUR]        = { texture = "HarvestMap/Textures/Map/tour.dds",              size = 32, tint = ZO_ColorDef:New(1.000, 0.000, 0.000) },
		[Harvest.CRIMSON]     = { texture = "HarvestMap/Textures/Map/waterplant.dds",        size = 20, tint = ZO_ColorDef:New(0.933, 0.345, 0.537) },
		[Harvest.HERBALIST]   = { texture = "HarvestMap/Textures/Map/alchemy.dds",           size = 20, tint = ZO_ColorDef:New(0.557, 1.000, 0.541) },
		worldBase = { texture = "HarvestMap/Textures/worldMarker.dds" },
	},

	displayCompassPins = true,
	displayWorldPins = true,
	displayMapPins = true,
	displayMinimapPins = true,
	displayNotifications = true,
	
	compassFilterProfile = 1,
	mapFilterProfile = 1,
	worldFilterProfile = 1,
	
	compassSpawnFilter = false,
	worldSpawnFilter = false,
	mapSpawnFilter = false,
	minimapSpawnFilter = false,
	
	showDebugOutput = false,
	visitedRangeInMeters = 10,
	hiddenTime = 1,
	hiddenOnHarvest = true,
	useHiddenTime = false,
	maxVisibleDistanceInMeters = 300,
	hasMaxVisibleDistance = false,
	
	compassDistanceInMeters = 100,
	worldDistanceInMeters = 100,
	worldPinDepth = true,
	worldPinHeight = 200,
	worldPinWidth = 100,
	minimapPinSize = 20,
	pinsAbovePoi = false,
	heatmap = false,
	
	filterProfiles = {Settings.defaultFilterProfile},
}

Settings.defaultAccountSettings = {
	accountWideSettings = false,
}

for key, value in pairs(Settings.defaultSettings) do
	Settings.defaultAccountSettings[key] = value
end

Settings.availableTextures = {
	"esoui/art/icons/poi/poi_crafting_complete.dds",
	"HarvestMap/Textures/Map/circle.dds",
	"HarvestMap/Textures/Map/diamond.dds",
	"HarvestMap/Textures/Map/mining.dds",
	"HarvestMap/Textures/Map/clothing.dds",
	"HarvestMap/Textures/Map/enchanting.dds",
	"HarvestMap/Textures/Map/mushroom.dds",
	"HarvestMap/Textures/Map/flower.dds",
	"HarvestMap/Textures/Map/waterplant.dds",
	"HarvestMap/Textures/Map/alchemy.dds",
	"HarvestMap/Textures/Map/wood.dds",
	"HarvestMap/Textures/Map/chest.dds",
	"HarvestMap/Textures/Map/solvent.dds",
	"HarvestMap/Textures/Map/fish.dds",
	"HarvestMap/Textures/Map/heavysack.dds",
	"HarvestMap/Textures/Map/trove.dds",
	"HarvestMap/Textures/Map/justice.dds",
	"HarvestMap/Textures/Map/stash.dds",
	"HarvestMap/Textures/Map/clam.dds",
	"HarvestMap/Textures/Map/tour.dds",
}

Settings.availableWorldBaseTextures = {
	"HarvestMap/Textures/worldMarker.dds",
	"/esoui/art/ava/ava_rankicon64_tyro.dds",
	"nonexistingfile.dds", -- empty, in case someone doesnt want any base texture
}

Settings.presets = {{invalid = true}}
Settings.presets[2] = Settings.defaultSettings.pinLayouts
Settings.presetNames = {
	Harvest.GetLocalization("selectpreset"),
	GetString(SI_COLLECTIONS_INVENTORY_DIALOG_DEFAULT_NAME)
}

function Settings:RegisterPreset(name, preset)
	self.presets[#self.presets+1] = preset
	self.presetNames[#self.presetNames+1] = name
	
	local texture
	for _, pinTypeId in ipairs(Harvest.PINTYPES) do
		if not Harvest.HIDDEN_PINTYPES[pinTypeId] then
			if not preset[pinTypeId] then
				preset[pinTypeId] = {Settings.defaultSettings.pinLayouts[pinTypeId].texture}
			end
			texture = preset[pinTypeId].texture
			if not ZO_IsElementInNonContiguousTable(self.availableTextures, texture) then
				self.availableTextures[#self.availableTextures+1] = texture
			end
			if not preset[pinTypeId].tint then
				preset[pinTypeId].tint = Settings.defaultSettings.pinLayouts[pinTypeId].tint
			end
		end
	end
	if preset.worldBase then
		if not ZO_IsElementInNonContiguousTable(self.availableWorldBaseTextures, preset.worldBase.texture) then
			self.availableWorldBaseTextures[#self.availableWorldBaseTextures+1] = preset.worldBase.texture
		end
	end
end

Harvest.settings:RegisterPreset(
	Harvest.GetLocalization("white"),
	{
		[Harvest.UNKNOWN]     = { texture = "esoui/art/icons/poi/poi_crafting_complete.dds", tint = ZO_ColorDef:New(1.000, 1.000, 1.000) },
		[Harvest.BLACKSMITH]  = { texture = "HarvestMap/Textures/Map/mining.dds",            tint = ZO_ColorDef:New(1.000, 1.000, 1.000) },
		[Harvest.CLOTHING]    = { texture = "HarvestMap/Textures/Map/clothing.dds",          tint = ZO_ColorDef:New(1.000, 1.000, 1.000) },
		[Harvest.ENCHANTING]  = { texture = "HarvestMap/Textures/Map/enchanting.dds",        tint = ZO_ColorDef:New(1.000, 1.000, 1.000) },
		[Harvest.MUSHROOM]    = { texture = "HarvestMap/Textures/Map/mushroom.dds",          tint = ZO_ColorDef:New(1.000, 1.000, 1.000) },
		[Harvest.FLOWER]   	  = { texture = "HarvestMap/Textures/Map/flower.dds",            tint = ZO_ColorDef:New(1.000, 1.000, 1.000) },
		[Harvest.WATERPLANT]  = { texture = "HarvestMap/Textures/Map/waterplant.dds",        tint = ZO_ColorDef:New(1.000, 1.000, 1.000) },
		[Harvest.WOODWORKING] = { texture = "HarvestMap/Textures/Map/wood.dds",              tint = ZO_ColorDef:New(1.000, 1.000, 1.000) },
		[Harvest.CHESTS]      = { texture = "HarvestMap/Textures/Map/chest.dds",             tint = ZO_ColorDef:New(1.000, 1.000, 1.000) },
		[Harvest.WATER]       = { texture = "HarvestMap/Textures/Map/solvent.dds",           tint = ZO_ColorDef:New(1.000, 1.000, 1.000) },
		[Harvest.FISHING]     = { texture = "HarvestMap/Textures/Map/fish.dds",              tint = ZO_ColorDef:New(1.000, 1.000, 1.000) },
		[Harvest.HEAVYSACK]   = { texture = "HarvestMap/Textures/Map/heavysack.dds",         tint = ZO_ColorDef:New(1.000, 1.000, 1.000) },
		[Harvest.TROVE]       = { texture = "HarvestMap/Textures/Map/trove.dds",             tint = ZO_ColorDef:New(1.000, 1.000, 1.000) },
		[Harvest.JUSTICE]     = { texture = "HarvestMap/Textures/Map/justice.dds",           tint = ZO_ColorDef:New(1.000, 1.000, 1.000) },
		[Harvest.STASH]       = { texture = "HarvestMap/Textures/Map/stash.dds",             tint = ZO_ColorDef:New(1.000, 1.000, 1.000) },
		[Harvest.CLAM]        = { texture = "HarvestMap/Textures/Map/clam.dds",              tint = ZO_ColorDef:New(1.000, 1.000, 1.000) },
		[Harvest.CRIMSON]     = { texture = "HarvestMap/Textures/Map/waterplant.dds",        tint = ZO_ColorDef:New(1.000, 1.000, 1.000) },
		[Harvest.HERBALIST]   = { texture = "HarvestMap/Textures/Map/alchemy.dds",           tint = ZO_ColorDef:New(1.000, 1.000, 1.000) },
		worldBase = { texture = "HarvestMap/Textures/worldMarker.dds" },
	}
)
