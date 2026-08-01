
function PUIAddon.HarvestMap()
	local db = Harvest_SavedVars.account[GetDisplayName():gsub('@','')]

----------------------------------------------------------------------------------------------------------------
-- Configure Addon Settings
----------------------------------------------------------------------------------------------------------------


	pinLayouts = {
		[1] = {
			level = 55,
			tint = {
				a = 1,
				r = 1,
				b = 0,
				g = 0.1882352978,
			},
			texture = "HarvestMap/Textures/Map/mining.dds",
			currentPinSize = 16,
			size = 20,
		},
		[2] = {
			level = 55,
			tint = {
				a = 1,
				r = 1,
				b = 0.7921568751,
				g = 0.3490196168,
			},
			texture = "HarvestMap/Textures/Map/clothing.dds",
			currentPinSize = 16,
			size = 20,
		},
		[3] = {
			level = 55,
			tint = {
				a = 1,
				r = 1,
				b = 0.9960784316,
				g = 0.0156862754,
			},
			texture = "HarvestMap/Textures/Map/enchanting.dds",
			currentPinSize = 16,
			size = 20,
		},
		[4] = {
			level = 55,
			tint = {
				a = 1,
				r = 0.4510000000,
				b = 0.4240000000,
				g = 0.5690000000,
			},
			texture = "HarvestMap/Textures/Map/mushroom.dds",
			currentPinSize = 16,
			size = 20,
		},
		[5] = {
			level = 55,
			tint = {
				a = 1,
				r = 0.8196078539,
				b = 0.0941176489,
				g = 0.4823529422,
			},
			texture = "HarvestMap/Textures/Map/wood.dds",
			currentPinSize = 16,
			size = 20,
		},
		[6] = {
			level = 55,
			tint = {
				a = 1,
				r = 1,
				b = 0,
				g = 0.9764705896,
			},
			texture = "HarvestMap/Textures/Map/chest.dds",
			currentPinSize = 16,
			size = 20,
		},
		[7] = {
			level = 55,
			tint = {
				a = 1,
				r = 0.0549019612,
				b = 0.7215686440,
				g = 0.8941176534,
			},
			texture = "HarvestMap/Textures/Map/solvent.dds",
			currentPinSize = 16,
			size = 20,
		},
		[8] = {
			level = 55,
			tint = {
				a = 1,
				r = 0,
				b = 1,
				g = 0.7607843137,
			},
			texture = "/esoui/art/treeicons/achievements_indexicon_fishing_down.dds",
			currentPinSize = 16,
			size = 20,
		},
		[9] = {
			level = 55,
			tint = {
				a = 1,
				r = 0.1490196139,
				b = 0.0823529437,
				g = 0.9647058845,
			},
			texture = "HarvestMap/Textures/Map/heavysack.dds",
			currentPinSize = 16,
			size = 20,
		},
		[10] = {
			level = 55,
			tint = {
				a = 1,
				r = 0,
				b = 1,
				g = 0.6392157078,
			},
			texture = "HarvestMap/Textures/Map/trove.dds",
			currentPinSize = 16,
			size = 20,
		},
		[11] = {
			level = 55,
			tint = {
				a = 1,
				r = 0,
				b = 1,
				g = 0.6392157078,
			},
			texture = "HarvestMap/Textures/Map/justice.dds",
			currentPinSize = 16,
			size = 20,
		},
		[12] = {
			level = 55,
			tint = {
				a = 1,
				r = 0,
				b = 1,
				g = 0.6392157078,
			},
			texture = "HarvestMap/Textures/Map/stash.dds",
			currentPinSize = 16,
			size = 20,
		},
		[13] = {
			level = 55,
			tint = {
				a = 1,
				r = 0.5570000000,
				b = 0.5410000000,
				g = 1,
			},
			texture = "HarvestMap/Textures/Map/flower.dds",
			currentPinSize = 16,
			size = 20,
		},
		[14] = {
			level = 55,
			tint = {
				a = 1,
				r = 0.4390000000,
				b = 0.8080000000,
				g = 0.9370000000,
			},
			texture = "HarvestMap/Textures/Map/waterplant.dds",
			currentPinSize = 16,
			size = 20,
		},
		[15] = {
			level = 55,
			tint = {
				a = 1,
				r = 1,
				b = 1,
				g = 1,
			},
			texture = "HarvestMap/Textures/Map/clam.dds",
			currentPinSize = 16,
			size = 20,
		},
		[16] = {
			tint = {
				a = 1,
				r = 1,
				b = 1,
				g = 1,
			},
			texture = "HarvestMap/Textures/Map/stash.dds",
			size = 20,
			level = 55,
		},
		[17] = {
			tint = {
				a = 1,
				r = 1,
				b = 1,
				g = 1,
			},
			texture = "HarvestMap/Textures/Map/stash.dds",
			size = 20,
			level = 55,
		},
		[18] = {
			level = 55,
			tint = {
				a = 1,
				r = 1,
				b = 1,
				g = 1,
			},
			texture = "esoui/art/icons/poi/poi_crafting_complete.dds",
			currentPinSize = 16,
			size = 20,
		},
		[19] = {
			level = 55,
			tint = {
				a = 1,
				r = 0.9330000000,
				b = 0.5370000000,
				g = 0.3450000000,
			},
			texture = "HarvestMap/Textures/Map/waterplant.dds",
			currentPinSize = 16,
			size = 20,
		},
		[100] = {
			tint = {
				a = 1,
				r = 1,
				b = 0,
				g = 0,
			},
			texture = "HarvestMap/Textures/Map/tour.dds",
			size = 32,
			level = 55,
		},
	}
	filterProfiles = {
		[2] = {
			[1] = true,
			[2] = true,
			[3] = true,
			[4] = true,
			[5] = true,
			[6] = true,
			[7] = true,
			[8] = true,
			[9] = true,
			[10] = true,
			[11] = true,
			[12] = true,
			[13] = true,
			[14] = true,
			[15] = true,
			[16] = true,
			[17] = true,
			[18] = false,
			[19] = true,
			name = "3D Profile",
		},
		[1] = {
			[1] = true,
			[2] = true,
			[3] = false,
			[4] = false,
			[5] = true,
			[6] = true,
			[7] = false,
			[8] = false,
			[9] = true,
			[10] = true,
			[11] = false,
			[12] = false,
			[13] = false,
			[14] = false,
			[15] = true,
			[16] = true,
			[17] = true,
			[18] = false,
			[19] = false,
			name = "Default Filter Profile",
		},
	}
	isPinTypeVisible = {
		[1] = false,
		[2] = false,
		[3] = false,
		[4] = false,
		[5] = false,
		[6] = true,
		[7] = false,
		[8] = false,
		[9] = true,
		[10] = true,
		[11] = true,
		[12] = false,
		[13] = false,
		[14] = false,
		[15] = false,
		[16] = true,
		[17] = true,
		HrvstPinDebug = false,
		[100] = true,
	}
	isPinTypeSavedOnGather = {
		[1] = true,
		[2] = true,
		[3] = true,
		[4] = true,
		[5] = true,
		[6] = true,
		[7] = true,
		[8] = true,
		[9] = true,
		[10] = true,
		[11] = true,
		[12] = true,
		[13] = true,
		[14] = true,
		[15] = true,
		[16] = true,
		[17] = true,
		[18] = true,
		[19] = true,
	}
	isSpawnFilterUsedForPinType = {
		[1] = true,
		[2] = true,
		[3] = true,
		[4] = true,
		[5] = true,
		[7] = true,
		[13] = true,
		[14] = true,
		[19] = true,
	}
	isCompassPinTypeVisible = {
		[1] = false,
		[2] = false,
		[3] = false,
		[4] = false,
		[5] = false,
		[6] = false,
		[7] = false,
		[8] = false,
		[9] = false,
		[10] = false,
		[11] = false,
		[12] = false,
		[13] = false,
		[14] = false,
		[15] = false,
		[16] = false,
		[17] = false,
		HrvstPinDebug = false,
		[100] = false,
	}
	isWorldPinTypeVisible = {
		[1] = false,
		[2] = false,
		[3] = false,
		[4] = false,
		[5] = false,
		[6] = false,
		[7] = false,
		[8] = false,
		[9] = false,
		[10] = false,
		[11] = false,
		[12] = false,
		[13] = false,
		[14] = false,
		[15] = false,
		[16] = false,
		[17] = false,
		HrvstPinDebug = false,
		[100] = false,
	}

	pinsAbovePoi = true
	maxVisibleDistanceInMeters = 300
	compassDistanceInMeters = 100
	worldSpawnFilter = true
	worldPinDepth = true
	worldPinHeight = 200
	compassFilterProfile = 1
	displaySpeed = 500
	accountWideSettings = true
	displayNotifications = true
	heatmap = false
	useHiddenTime = false
	rangeMuliplier = 0.2500000000
	displayMinimapPins = true
	mapFilterProfile = 1
	worldFilterProfile = 1
	visitedRangeInMeters = 10
	displayMapPins = true
	minimapOnly = false
	worldDistance = 0.0040620192
	delayWhenInFight = true
	showDebugOutput = false
	worldDistanceInMeters = 100
	mapPinMinSize = 8
	compassSpawnFilter = true
	displayWorldPins = true
	worldPinWidth = 100
	compassDistance = 0.0040000000
	isWorldFilterActive = false
	displayCompassPins = true
	mapSpawnFilter = true
	isCompassFilterActive = false
	minimapPinSize = 18
	maxVisibleDistance = 0.0200000000
	hiddenOnHarvest = true
	minimapCompatibility = false
	minimapSpawnFilter = true
	hasMaxVisibleDistance = false
	delayUntilMapOpen = false
	hiddenTime = 2

end
