--[[
	Compact craft constants that cannot be obtained without a crafting station.

	These are NOT a recipe database. They encode:
	  1) Material tier → refined material itemId (10 tiers × 4 crafts + leather)
	  2) Pattern → material quantity formulas (same math used by LibLazyCrafting / game)
	  3) Weapon/armor type → pattern index maps
	  4) Improvement booster counts by expertise rank
	  5) Fallback improvement material itemIds (API preferred when available)

	Everything else (style mats, trait mats, improvement links, level, trait, style,
	quality) is resolved dynamically from item links / ESO APIs.
]]

CraftCostCalculator = CraftCostCalculator or {}
local CCC = CraftCostCalculator

CCC.CraftData = CCC.CraftData or {}
local D = CCC.CraftData

-- Refined material item IDs by craft / tier (1=Iron/Jute/… … 10=Rubedite/…)
-- Leather is keyed as [3] because clothier medium armor uses leather, not cloth.
D.MATERIAL_ITEM_IDS = {
	[CRAFTING_TYPE_BLACKSMITHING] = {
		5413, 4487, 23107, 6000, 6001, 46127, 46128, 46129, 46130, 64489,
	},
	[CRAFTING_TYPE_CLOTHIER] = {
		811, 4463, 23125, 23126, 23127, 46131, 46132, 46133, 46134, 64504,
	},
	[3] = { -- Leather (medium armor)
		794, 4447, 23099, 23100, 23101, 46135, 46136, 46137, 46138, 64506,
	},
	[CRAFTING_TYPE_WOODWORKING] = {
		803, 533, 23121, 23122, 23123, 46139, 46140, 46141, 46142, 64502,
	},
	[CRAFTING_TYPE_JEWELRYCRAFTING] = {
		135138, 135140, 135142, 135144, 135146,
	},
}

-- Material indexes where the refined material tier changes.
D.REQUIREMENT_JUMPS = {
	[1] = 1, [2] = 8, [3] = 13, [4] = 18, [5] = 23,
	[6] = 26, [7] = 29, [8] = 32, [9] = 34, [10] = 40,
}

-- Extra mats added per pattern index (station-specific).
D.ADDITIONAL_REQUIREMENTS = {
	[CRAFTING_TYPE_BLACKSMITHING] = {
		2, 2, 2, 4, 4, 4, 1, 6, 4, 4, 4, 5, 4, 4,
	},
	[CRAFTING_TYPE_WOODWORKING] = {
		2, 5, 2, 2, 2, 2,
	},
	[CRAFTING_TYPE_CLOTHIER] = {
		6, 6, 4, 4, 4, 5, 4, 4, 6, 4, 4, 4, 5, 4, 4,
	},
}

-- Jewelry: [materialIndex] = { ringQty, necklaceQty, materialTierIndex }
D.JEWELRY_MAT_REQUIREMENT = {
	[1] = {2, 3, 1}, [2] = {3, 5, 1}, [3] = {4, 6, 1}, [4] = {5, 8, 1},
	[5] = {6, 9, 1}, [6] = {7, 11, 1}, [7] = {8, 12, 1}, [8] = {9, 14, 1},
	[9] = {10, 15, 1}, [10] = {11, 17, 1}, [11] = {12, 19, 1}, [12] = {13, 20, 1},
	[13] = {3, 5, 2}, [14] = {4, 6, 2}, [15] = {5, 8, 2}, [16] = {6, 9, 2},
	[17] = {7, 11, 2}, [18] = {8, 12, 2}, [19] = {9, 14, 2}, [20] = {10, 15, 2},
	[21] = {11, 17, 2}, [22] = {12, 18, 2}, [23] = {13, 20, 2}, [24] = {14, 21, 2},
	[25] = {15, 23, 2},
	[26] = {4, 6, 3}, [27] = {6, 9, 3}, [28] = {8, 12, 3}, [29] = {10, 15, 3},
	[30] = {12, 18, 3}, [31] = {14, 21, 3}, [32] = {16, 24, 3},
	[33] = {6, 8, 4}, [34] = {8, 12, 4}, [35] = {10, 16, 4}, [36] = {12, 20, 4},
	[37] = {14, 24, 4}, [38] = {16, 28, 4}, [39] = {18, 32, 4},
	[40] = {10, 15, 5}, [41] = {100, 150, 5},
}

-- Upper materialIndex bound for each refined tier (for tier lookup).
D.MAT_TIER_CEILINGS = {7, 12, 17, 22, 25, 28, 31, 33, 39, 41}

-- weaponType → { craftingType, patternIndex }
D.WEAPON_PATTERNS = {
	[WEAPONTYPE_AXE] = {CRAFTING_TYPE_BLACKSMITHING, 1},
	[WEAPONTYPE_HAMMER] = {CRAFTING_TYPE_BLACKSMITHING, 2},
	[WEAPONTYPE_SWORD] = {CRAFTING_TYPE_BLACKSMITHING, 3},
	[WEAPONTYPE_TWO_HANDED_AXE] = {CRAFTING_TYPE_BLACKSMITHING, 4},
	[WEAPONTYPE_TWO_HANDED_HAMMER] = {CRAFTING_TYPE_BLACKSMITHING, 5},
	[WEAPONTYPE_TWO_HANDED_SWORD] = {CRAFTING_TYPE_BLACKSMITHING, 6},
	[WEAPONTYPE_DAGGER] = {CRAFTING_TYPE_BLACKSMITHING, 7},
	[WEAPONTYPE_BOW] = {CRAFTING_TYPE_WOODWORKING, 1},
	[WEAPONTYPE_SHIELD] = {CRAFTING_TYPE_WOODWORKING, 2},
	[WEAPONTYPE_FIRE_STAFF] = {CRAFTING_TYPE_WOODWORKING, 3},
	[WEAPONTYPE_FROST_STAFF] = {CRAFTING_TYPE_WOODWORKING, 4},
	[WEAPONTYPE_LIGHTNING_STAFF] = {CRAFTING_TYPE_WOODWORKING, 5},
	[WEAPONTYPE_HEALING_STAFF] = {CRAFTING_TYPE_WOODWORKING, 6},
}

-- equipType → base pattern offset before armor-weight adjustment
D.EQUIP_PATTERN_BASE = {
	[EQUIP_TYPE_CHEST] = 1,
	[EQUIP_TYPE_FEET] = 2,
	[EQUIP_TYPE_HAND] = 3,
	[EQUIP_TYPE_HEAD] = 4,
	[EQUIP_TYPE_LEGS] = 5,
	[EQUIP_TYPE_SHOULDERS] = 6,
	[EQUIP_TYPE_WAIST] = 7,
	[EQUIP_TYPE_RING] = 1,
	[EQUIP_TYPE_NECK] = 2,
}

-- Boosters needed for 100% chance by improvement expertise rank (0–3)
-- Index = from-quality (ITEM_FUNCTIONAL_QUALITY_NORMAL=1 … EPIC=4)
D.IMPROVEMENT_COUNTS = {
	[0] = {5, 7, 10, 20},
	[1] = {4, 5, 7, 14},
	[2] = {3, 4, 5, 10},
	[3] = {2, 3, 4, 8},
}

-- Fallback improvement mat IDs if GetSmithingImprovementItemLink fails.
-- Order: white→green, green→blue, blue→purple, purple→gold
D.IMPROVEMENT_ITEM_IDS = {
	[CRAFTING_TYPE_BLACKSMITHING] = {54170, 54171, 54172, 54173},
	[CRAFTING_TYPE_CLOTHIER] = {54174, 54175, 54176, 54177},
	[CRAFTING_TYPE_WOODWORKING] = {54178, 54179, 54180, 54181},
	[CRAFTING_TYPE_JEWELRYCRAFTING] = {203631, 203632, 203633, 203634}, -- Terne → Chromium (post-U40 IDs)
}

-- Ability IDs for improvement expertise passives (to detect character rank).
D.IMPROVEMENT_ABILITY_IDS = {
	[CRAFTING_TYPE_BLACKSMITHING] = 48168,
	[CRAFTING_TYPE_CLOTHIER] = 48198,
	[CRAFTING_TYPE_WOODWORKING] = 48177,
	[CRAFTING_TYPE_JEWELRYCRAFTING] = 103648,
}

-- Lazily built base quantity curve (materialIndex 1–41).
local baseRequirements

function D:GetBaseRequirements()
	if baseRequirements then
		return baseRequirements
	end

	baseRequirements = {}
	local currentStep = 1
	for i = 1, 41 do
		if i == 41 then
			baseRequirements[i] = baseRequirements[40]
		elseif i == 40 then
			baseRequirements[i] = currentStep - 1
		elseif D.REQUIREMENT_JUMPS[currentStep] == i then
			currentStep = currentStep + 1
			baseRequirements[i] = currentStep - 1
		else
			baseRequirements[i] = (baseRequirements[i - 1] or 0) + 1
		end
	end
	return baseRequirements
end

function D:FindMatIndex(level, isChampion)
	if isChampion then
		return 25 + math.floor(level / 10)
	end
	if level < 3 then
		return 1
	end
	return math.floor(level / 2)
end

function D:FindMatTierByIndex(materialIndex)
	local ceilings = D.MAT_TIER_CEILINGS
	for i = 1, #ceilings do
		if materialIndex <= ceilings[i] then
			return i
		end
	end
	return #ceilings
end

function D:GetMaterialQuantity(station, pattern, materialIndex)
	if station == CRAFTING_TYPE_JEWELRYCRAFTING then
		local row = D.JEWELRY_MAT_REQUIREMENT[materialIndex]
		if not row then
			return nil
		end
		return row[pattern]
	end

	local base = D:GetBaseRequirements()[materialIndex]
	local extraTable = D.ADDITIONAL_REQUIREMENTS[station]
	if not base or not extraTable or not extraTable[pattern] then
		return nil
	end

	local mats = base + extraTable[pattern]

	-- Documented game/LLC exceptions
	if station == CRAFTING_TYPE_WOODWORKING and pattern ~= 2 and materialIndex >= 40 then
		mats = mats + 1
	end
	if station == CRAFTING_TYPE_BLACKSMITHING and pattern == 12 and materialIndex < 13 and materialIndex >= 8 then
		mats = mats - 1
	end
	if station == CRAFTING_TYPE_BLACKSMITHING and pattern >= 4 and pattern <= 6 and materialIndex >= 40 then
		mats = mats + 1
	end
	if materialIndex == 41 then
		mats = mats * 10
	end

	return mats
end
