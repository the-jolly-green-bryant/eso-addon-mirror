-- TinydogsCraftingCalculator Crafting XP Data LUA File
-- Last Updated June 27, 2024 by @tinydog
-- Created October 2015 by @tinydog - tinydog1234@hotmail.com

local skillType
skillType, TCC_SKILL_INDEX_BLACKSMITHING = tcc_GetCraftingSkillLineIndices(CRAFTING_TYPE_BLACKSMITHING)
skillType, TCC_SKILL_INDEX_CLOTHING = tcc_GetCraftingSkillLineIndices(CRAFTING_TYPE_CLOTHIER)
skillType, TCC_SKILL_INDEX_ENCHANTING = tcc_GetCraftingSkillLineIndices(CRAFTING_TYPE_ENCHANTING)
skillType, TCC_SKILL_INDEX_WOODWORKING = tcc_GetCraftingSkillLineIndices(CRAFTING_TYPE_WOODWORKING)
skillType, TCC_SKILL_INDEX_JEWELRY = tcc_GetCraftingSkillLineIndices(CRAFTING_TYPE_JEWELRYCRAFTING)
-- skillType, TCC_SKILL_INDEX_ALCHEMY = tcc_GetCraftingSkillLineIndices(CRAFTING_TYPE_ALCHEMY)
-- skillType, TCC_SKILL_INDEX_PROVISIONING = tcc_GetCraftingSkillLineIndices(CRAFTING_TYPE_PROVISIONING)
skillType = nil

function tcc_InitCraftingData()
	tcc.TexturePaths["Create"] = "/esoui/art/crafting/smithing_tabicon_creation_%.dds"
	tcc.TexturePaths["Deconstruct"] = "/esoui/art/crafting/enchantment_tabicon_deconstruction_%.dds"

	-- Same for all crafts (NOT QUITE)
	tcc.CraftingXpNeededForSkillLevel = {
		["Blacksmithing"] = { -- validated 4/15/2020
			0, 640, 3995, 6920, 8900, 10560, 13040, 16360, 17960, 21880,                    -- 1 - 10
			24400, 26900, 29400, 30200, 31000, 32600, 34200, 35800, 39610, 43420,           -- 11 - 20
			45750, 48080, 50500, 52920, 55560, 58200, 61280, 64360, 67660, 70960,           -- 21 - 30
			74700, 78440, 82400, 86360, 90980, 95600, 100440, 105280, 116280, 128600,       -- 31 - 40
			135200, 141800, 149280, 156760, 164680, 173040, 181840, 191080, 200760, 211320  -- 41 - 50
		},
		["Clothing"] = { -- validated 4/16/2020
			0, 640, 3995, 6920, 8900, 10560, 13040, 16360, 17960, 21880,                    -- 1 - 10
			24400, 26900, 29400, 30200, 31000, 32600, 34200, 35800, 39610, 43420,           -- 11 - 20
			45750, 48080, 50500, 52920, 55560, 58200, 61280, 64360, 67660, 70960,           -- 21 - 30
			74700, 78440, 82400, 86360, 90980, 95600, 100440, 105280, 116280, 128600,       -- 31 - 40
			135200, 141800, 149280, 156760, 164680, 173040, 181840, 191080, 200760, 211320  -- 41 - 50
		},
		["Leatherworking"] = { -- same as clothing
			0, 640, 3995, 6920, 8900, 10560, 13040, 16360, 17960, 21880,                    -- 1 - 10
			24400, 26900, 29400, 30200, 31000, 32600, 34200, 35800, 39610, 43420,           -- 11 - 20
			45750, 48080, 50500, 52920, 55560, 58200, 61280, 64360, 67660, 70960,           -- 21 - 30
			74700, 78440, 82400, 86360, 90980, 95600, 100440, 105280, 116280, 128600,       -- 31 - 40
			135200, 141800, 149280, 156760, 164680, 173040, 181840, 191080, 200760, 211320  -- 41 - 50
		},
		["Woodworking"] = { -- validated 4/15/2020
			0, 640, 3995, 6920, 8900, 10560, 13040, 16360, 17960, 21880,                    -- 1 - 10
			24400, 26900, 29400, 30200, 31000, 32600, 34200, 35800, 39610, 43420,           -- 11 - 20
			45750, 48080, 50500, 52920, 55560, 58200, 61280, 64360, 67660, 70960,           -- 21 - 30
			74700, 78440, 82400, 86360, 90980, 95600, 100440, 105280, 116280, 128600,       -- 31 - 40
			135200, 141800, 149280, 156760, 164680, 173040, 181840, 191080, 200760, 211320  -- 41 - 50
		},
		["Enchanting"] = { -- validated 4/15/2020
			0, 640, 3995, 6920, 8900, 10560, 13040, 16360, 17960, 21880,                    -- 1 - 10
			24311, 26989, 29400, 30200, 31000, 32600, 34200, 35800, 39610, 43420,           -- 11 - 20
-- DIFFERENT  *      *                                                       
			45750, 48080, 50500, 52920, 55560, 58200, 61280, 64360, 67660, 70960,           -- 21 - 30
			74700, 78440, 82400, 86360, 90980, 95600, 100440, 105280, 116280, 128600,       -- 31 - 40
			135200, 141800, 149280, 156760, 164647, 173073, 181840, 191080, 200760, 211320  -- 41 - 50
-- DIFFERENT                                   *       *
		},
		-- ["Alchemy"] = { -- validated 4/15/2020
			-- 0, 640, 3995, 6920, 8900, 10560, 13040, 16360, 17960, 21880,                    -- 1 - 10
			-- 24400, 26900, 29400, 30200, 31000, 32600, 34200, 35800, 39610, 43420,           -- 11 - 20
			-- 45750, 48080, 50500, 52920, 55560, 58200, 61280, 64360, 67660, 70960,           -- 21 - 30
			-- 74700, 78440, 82400, 86360, 90980, 95600, 100440, 105280, 116280, 128600,       -- 31 - 40
			-- 135200, 141800, 149280, 156760, 164680, 173040, 181840, 191080, 200760, 211320  -- 41 - 50
		-- },
		-- ["Provisioning"] = { -- validated 4/14/2020
			-- 0, 640, 3995, 6920, 8900, 10560, 13040, 16360, 17960, 21880,                    -- 1 - 10
			-- 24400, 26900, 29400, 30200, 31000, 32600, 34200, 35800, 39610, 43320,           -- 11 - 20
-- -- DIFFERENT                                                                 *
			-- 45850, 48080, 50500, 52920, 55560, 58200, 61280, 64360, 67660, 70960,           -- 21 - 30
-- -- DIFFERENT  *
			-- 73700, 79440, 82400, 86360, 90980, 95600, 100440, 105280, 116280, 128600,       -- 31 - 40
-- -- DIFFERENT  *      *
			-- 135200, 141800, 149280, 156760, 164680, 173040, 181840, 191080, 200760, 211320  -- 41 - 50
		-- },
		["Jewelry"] = { -- validated 4/15/2020
			0, 640, 3995, 6920, 8900, 10560, 13040, 16360, 17960, 21880,                    -- 1 - 10
			24400, 26900, 29400, 30200, 31000, 32600, 34200, 35800, 39610, 43420,           -- 11 - 20
			45750, 48080, 50500, 52920, 55560, 58200, 61280, 64360, 67660, 70960,           -- 21 - 30
			74700, 78440, 82400, 86360, 90980, 95600, 100440, 105280, 116280, 128600,       -- 31 - 40
			135200, 141800, 149280, 156760, 164680, 173040, 181840, 191080, 200760, 211320  -- 41 - 50
		},
	}
	
	-- tcc_CraftObj(craftName, craftType, optimalItemType, skillIndex)
	tcc.Crafts = {
		["Blacksmithing"] = tcc_CraftObj("Blacksmithing", "Equipment", "Dagger", TCC_SKILL_INDEX_BLACKSMITHING),
		["Clothing"] = tcc_CraftObj("Clothing", "Equipment", "Shoes", TCC_SKILL_INDEX_CLOTHING),
		["Leatherworking"] = tcc_CraftObj("Leatherworking", "Equipment", "Boots", TCC_SKILL_INDEX_CLOTHING),
		["Woodworking"] = tcc_CraftObj("Woodworking", "Equipment", "Bow", TCC_SKILL_INDEX_WOODWORKING),
		["Enchanting"] = tcc_CraftObj("Enchanting", "Consumables", "", TCC_SKILL_INDEX_ENCHANTING),
		["Jewelry"] = tcc_CraftObj("Jewelry", "Equipment", "Ring", TCC_SKILL_INDEX_JEWELRY),
		-- ["Alchemy"] = tcc_CraftObj("Alchemy", "Consumables", "", TCC_SKILL_INDEX_ALCHEMY),
		-- ["Provisioning"] = tcc_CraftObj("Provisioning", "Consumables", "", TCC_SKILL_INDEX_PROVISIONING),
	}
	
	-- (nameGeneric, name, description, texture, rankAvailableAtSkillLevelArray)
	tcc.Crafts["Blacksmithing"].Passives = {
		tcc_CraftingPassiveObj("Proficiency", "Metalworking", "", "/esoui/art/icons/ability_smith_007.dds", 
			{1, 5, 10, 15, 20, 25, 30, 35, 40, 50}),
		tcc_CraftingPassiveObj("Keen Eye", "Keen Eye: Ore", "", "/esoui/art/icons/ability_smith_002.dds", 
			{2, 9, 30}),
		tcc_CraftingPassiveObj("Hireling", "Miner Hireling", "", "/esoui/art/icons/ability_smith_006.dds", 
			{3, 12, 32}),
		tcc_CraftingPassiveObj("Extraction", "Metal Extraction", "", "/esoui/art/icons/ability_smith_003.dds", 
			{4, 22, 32}),
		tcc_CraftingPassiveObj("Research", "Metallurgy", "", "/esoui/art/icons/crafting_runecrafter_armor_vendor_component_002.dds", 
			{8, 18, 28, 42}), -- Verify 42 vs. 45
		tcc_CraftingPassiveObj("Improvement", "Temper Expertise", "", "/esoui/art/icons/ability_smith_004.dds", 
			{10, 25, 40}),
	}
	tcc.Crafts["Clothing"].Passives = {
		tcc_CraftingPassiveObj("Proficiency", "Tailoring", "", "/esoui/art/icons/ability_tradecraft_008.dds", 
			{1, 5, 10, 15, 20, 25, 30, 35, 40, 50}),
		tcc_CraftingPassiveObj("Keen Eye", "Keen Eye: Cloth", "", "/esoui/art/icons/ability_smith_002.dds", 
			{2, 9, 30}),
		tcc_CraftingPassiveObj("Hireling", "Outfitter Hireling", "", "/esoui/art/icons/ability_tradecraft_007.dds", 
			{3, 12, 32}),
		tcc_CraftingPassiveObj("Extraction", "Unraveling", "", "/esoui/art/icons/ability_tradecraft_005.dds", 
			{4, 22, 32}),
		tcc_CraftingPassiveObj("Research", "Stitching", "", "/esoui/art/icons/crafting_light_armor_component_004.dds", 
			{8, 18, 28, 45}),
		tcc_CraftingPassiveObj("Improvement", "Tannin Expertise", "", "/esoui/art/icons/ability_tradecraft_004.dds", 
			{10, 25, 40}),
	}
	tcc.Crafts["Leatherworking"].Passives = tcc.Crafts["Clothing"].Passives
	tcc.Crafts["Woodworking"].Passives = {
		tcc_CraftingPassiveObj("Proficiency", "Woodworking", "", "/esoui/art/icons/ability_tradecraft_009.dds", 
			{1, 5, 10, 15, 20, 25, 30, 35, 40, 50}),
		tcc_CraftingPassiveObj("Keen Eye", "Keen Eye: Wood", "", "/esoui/art/icons/ability_smith_002.dds", 
			{2, 9, 30}),
		tcc_CraftingPassiveObj("Hireling", "Lumberjack Hireling", "", "/esoui/art/icons/ability_tradecraft_007.dds", 
			{3, 12, 32}),
		tcc_CraftingPassiveObj("Extraction", "Wood Extraction", "", "/esoui/art/icons/ability_tradecraft_006.dds", 
			{4, 22, 32}),
		tcc_CraftingPassiveObj("Research", "Carpentry", "", "/esoui/art/icons/crafting_forester_plug_component_002.dds", 
			{8, 18, 28, 45}), -- 45 vs. 42
		tcc_CraftingPassiveObj("Improvement", "Resin Expertise", "", "/esoui/art/icons/ability_tradecraft_001.dds", 
			{10, 25, 40}),
	}
	tcc.Crafts["Enchanting"].Passives = {
		tcc_CraftingPassiveObj("Research", "Aspect Improvement", "", "/esoui/art/icons/ability_enchanter_002b.dds", 
			{1, 6, 16, 31}),
		tcc_CraftingPassiveObj("Proficiency", "Potency Improvement", "", "/esoui/art/icons/ability_enchanter_001b.dds", 
			{1, 5, 10, 15, 20, 25, 30, 35, 40, 50}),
		tcc_CraftingPassiveObj("Keen Eye", "Keen Eye: Rune Stones", "", "/esoui/art/icons/ability_smith_002.dds", 
			{2, 7, 14}),
		tcc_CraftingPassiveObj("Hireling", "Hireling", "", "/esoui/art/icons/ability_enchanter_008.dds", 
			{3, 12, 32}),
		tcc_CraftingPassiveObj("Extraction", "Runestone Extraction", "", "/esoui/art/icons/ability_enchanter_004.dds", 
			{4, 19, 29}),
	}
	tcc.Crafts["Jewelry"].Passives = {
		tcc_CraftingPassiveObj("Proficiency", "Engraver", "", "/esoui/art/icons/passive_jewelerengraver.dds", 
			{1, 14, 27, 40, 50}),
		tcc_CraftingPassiveObj("Keen Eye", "Keen Eye: Jewelry", "", "/esoui/art/icons/ability_smith_002.dds", 
			{2, 9, 30}),
		tcc_CraftingPassiveObj("Extraction", "Jewelry Extraction", "", "/esoui/art/icons/passive_jewelryextraction.dds", 
			{4, 22, 32}),
		tcc_CraftingPassiveObj("Research", "Lapidary Research", "", "/esoui/art/icons/passive_lapidaryresearch.dds", 
			{8, 18, 28, 45}),
		tcc_CraftingPassiveObj("Improvement", "Platings Expertise", "", "/esoui/art/icons/passive_platingexpertise.dds", 
			{10, 25, 40}),
	}
	-- tcc.Crafts["Alchemy"].Passives = {
		-- tcc_CraftingPassiveObj("Proficiency", "Solvent Proficiency", "", "/esoui/art/icons/ability_alchemy_001.dds", 
			-- {1, 10, 20, 30, 40, 48, 49, 50}),
		-- tcc_CraftingPassiveObj("Keen Eye", "Keen Eye: Reagents", "", "/esoui/art/icons/ability_smith_002.dds", 
			-- {2, 6, 17}),
		-- tcc_CraftingPassiveObj("Medicinal Use", "Medicinal Use", "", "/esoui/art/icons/ability_alchemy_004.dds", 
			-- {8, 35, 50}),
		-- tcc_CraftingPassiveObj("Chemistry", "Chemistry", "", "/esoui/art/icons/ability_alchemy_006.dds", 
			-- {12, 30, 47}),
		-- tcc_CraftingPassiveObj("Laboratory Use", "Laboratory Use", "", "/esoui/art/icons/ability_alchemy_002.dds", 
			-- {15}),
		-- tcc_CraftingPassiveObj("Snakeblood", "Snakeblood", "", "/esoui/art/icons/ability_alchemy_005.dds", 
			-- {23, 33, 43}),
	-- }
	-- tcc.Crafts["Provisioning"].Passives = {
		-- tcc_CraftingPassiveObj("Improvement", "Recipe Quality", "", "/esoui/art/icons/ability_provisioner_006.dds", 
			-- {1, 10, 35, 50}),
		-- tcc_CraftingPassiveObj("Proficiency", "Recipe Improvement", "", "/esoui/art/icons/ability_provisioner_001.dds", 
			-- {1, 20, 30, 40, 50, 50}),
		-- tcc_CraftingPassiveObj("Gourmand", "Gourmand", "", "/esoui/art/icons/ability_provisioner_004.dds", 
			-- {3, 14, 43}),
		-- tcc_CraftingPassiveObj("Connoisseur", "Connoisseur", "", "/esoui/art/icons/ability_provisioner_005.dds", 
			-- {5, 25, 47}),
		-- tcc_CraftingPassiveObj("Chef", "Chef", "", "/esoui/art/icons/ability_provisioner_002.dds", 
			-- {7, 23, 33}),
		-- tcc_CraftingPassiveObj("Brewer", "Brewer", "", "/esoui/art/icons/ability_provisioner_003.dds", 
			-- {9, 25, 36}),
		-- tcc_CraftingPassiveObj("Hireling", "Hireling", "", "/esoui/art/icons/ability_provisioner_007.dds", 
			-- {28, 38, 48}),
	-- }

	-- skillTier, optimalItemLvl, createXp, deconstructXpWhite, deconstructXpGreen, deconstructXpBlue, deconstructXpPurple, 
	--   itemLinkWhite, itemLinkGreen, itemLinkBlue, itemLinkPurple
	tcc.Crafts["Blacksmithing"].CraftingXp = {
		[1] =  tcc_CraftingXpObj(1, "6", 127, 272, 347,     435, 	531, 	"|H1:item:43535:20:6:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h",   "|H1:item:43535:21:6:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h"	, "|H1:item:43535:22:6:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", 	"|H1:item:43535:23:6:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h"),
		[2] =  tcc_CraftingXpObj(2, "16", 258, 553, 674,    752, 	918, 	"|H1:item:43535:20:16:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h",  "|H1:item:43535:21:16:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h"	, "|H1:item:43535:22:16:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", 	"|H1:item:43535:23:16:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h"),
		[3] =  tcc_CraftingXpObj(3, "26", 445, 955, 1065,   1189, 	1330, 	"|H1:item:43535:20:26:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h",  "|H1:item:43535:21:26:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h"	, "|H1:item:43535:22:26:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", 	"|H1:item:43535:23:26:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h"),
		[4] =  tcc_CraftingXpObj(4, "36", 646, 1384, 1548,  1743, 	1957, 	"|H1:item:43535:20:36:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h",  "|H1:item:43535:21:36:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h"	, "|H1:item:43535:22:36:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", 	"|H1:item:43535:23:36:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h"),
		[5] =  tcc_CraftingXpObj(5, "46", 951, 2040, 2293,  2588, 	2919, 	"|H1:item:43535:20:46:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h",  "|H1:item:43535:21:46:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h"	, "|H1:item:43535:22:46:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", 	"|H1:item:43535:23:46:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h"),
		[6] =  tcc_CraftingXpObj(6, "CP10", 1116, 2391, 2713, 3039, 	3310, 	"|H1:item:43535:125:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", "|H1:item:43535:135:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", "|H1:item:43535:145:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", 	"|H1:item:43535:155:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h"),
		[7] =  tcc_CraftingXpObj(7, "CP40", 1362, 2919, 3310, 3764, 	4100, 	"|H1:item:43535:128:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", "|H1:item:43535:138:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", "|H1:item:43535:148:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", 	"|H1:item:43535:158:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h"),
		[8] =  tcc_CraftingXpObj(8, "CP70", 1612, 3455, 3928, 4466, 	4865, 	"|H1:item:43535:131:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", "|H1:item:43535:141:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", "|H1:item:43535:151:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", 	"|H1:item:43535:161:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h"),
		[9] =  tcc_CraftingXpObj(9, "CP90", 1833, 3928, 4466, 5078, 	5532, 	"|H1:item:43535:133:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", "|H1:item:43535:143:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", "|H1:item:43535:153:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", 	"|H1:item:43535:163:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h"),
		[10] = tcc_CraftingXpObj(10, "CP150", 0, 5773, 6564,  7462, 	8130, 	"|H1:item:43535:308:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", "|H1:item:43535:309:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", "|H1:item:43535:310:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", 	"|H1:item:43535:311:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h"),
	}
	tcc.Crafts["Clothing"].CraftingXp = {
		[1] =  tcc_CraftingXpObj(1, "14", 268, 576, 670,     811, 	895, 	"|H1:item:43544:20:6:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h",   "|H1:item:43544:21:6:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h"	, "|H1:item:43544:22:6:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h",   "|H1:item:43544:23:6:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h"   ),
		[2] =  tcc_CraftingXpObj(2, "16", 301, 646, 782,     867, 	1053, 	"|H1:item:43544:20:16:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h",  "|H1:item:43544:21:16:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h"	, "|H1:item:43544:22:16:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h",  "|H1:item:43544:23:16:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h"  ),
		[3] =  tcc_CraftingXpObj(3, "26", 510, 1094, 1212,   1347, 	1500, 	"|H1:item:43544:20:26:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h",  "|H1:item:43544:21:26:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h"	, "|H1:item:43544:22:26:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h",  "|H1:item:43544:23:26:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h"  ),
		[4] =  tcc_CraftingXpObj(4, "36", 727, 1559, 1737,   1948, 	2180, 	"|H1:item:43544:20:36:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h",  "|H1:item:43544:21:36:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h"	, "|H1:item:43544:22:36:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h",  "|H1:item:43544:23:36:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h"  ),
		[5] =  tcc_CraftingXpObj(5, "46", 1059, 2269, 2543,  2860, 	3217, 	"|H1:item:43544:20:46:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h",  "|H1:item:43544:21:46:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h"	, "|H1:item:43544:22:46:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h",  "|H1:item:43544:23:46:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h"  ),
		[6] =  tcc_CraftingXpObj(6, "CP10", 1235, 2648, 2974,  3346, 	3632, 	"|H1:item:43544:125:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "|H1:item:43544:135:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h", "|H1:item:43544:145:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "|H1:item:43544:155:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" ),
		[7] =  tcc_CraftingXpObj(7, "CP40", 1501, 3217, 3632,  4108, 	4461, 	"|H1:item:43544:128:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "|H1:item:43544:138:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h", "|H1:item:43544:148:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "|H1:item:43544:158:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" ),
		[8] =  tcc_CraftingXpObj(8, "CP80", 1917, 4108, 4647,  5256, 	5706, 	"|H1:item:43544:132:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "|H1:item:43544:141:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h", "|H1:item:43544:152:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "|H1:item:43544:162:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" ),
		[9] =  tcc_CraftingXpObj(9, "CP100", 2168, 4647, 5256, 5946, 	6454, 	"|H1:item:43544:134:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "|H1:item:43544:143:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h", "|H1:item:43544:154:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "|H1:item:43544:164:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" ),
		[10] = tcc_CraftingXpObj(10, "CP150", 0, 6195, 7006,   7925, 	8604, 	"|H1:item:43544:308:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "|H1:item:43544:309:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h", "|H1:item:43544:310:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "|H1:item:43544:311:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" ),
	}
	tcc.Crafts["Leatherworking"].CraftingXp = {
		[1] =  tcc_CraftingXpObj(1, "14", 268, 576, 670,     811, 	895, 	"|H1:item:43551:20:6:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h",   "|H1:item:43551:21:6:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h"	, "|H1:item:43551:22:6:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h"	 , "|H1:item:43551:23:6:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h"),
		[2] =  tcc_CraftingXpObj(2, "16", 301, 646, 782,     867, 	1053, 	"|H1:item:43551:20:16:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h",  "|H1:item:43551:21:16:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h"	, "|H1:item:43551:22:16:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" , "|H1:item:43551:23:16:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h"),
		[3] =  tcc_CraftingXpObj(3, "26", 510, 1094, 1212,   1347, 	1500, 	"|H1:item:43551:20:26:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h",  "|H1:item:43551:21:26:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h"	, "|H1:item:43551:22:26:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" , "|H1:item:43551:23:26:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h"),
		[4] =  tcc_CraftingXpObj(4, "36", 727, 1559, 1737,   1948, 	2180, 	"|H1:item:43551:20:36:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h",  "|H1:item:43551:21:36:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h"	, "|H1:item:43551:22:36:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" , "|H1:item:43551:23:36:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h"),
		[5] =  tcc_CraftingXpObj(5, "46", 1059, 2269, 2543,  2860, 	3217, 	"|H1:item:43551:20:46:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h",  "|H1:item:43551:21:46:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h"	, "|H1:item:43551:22:46:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" , "|H1:item:43551:23:46:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h"),
		[6] =  tcc_CraftingXpObj(6, "CP10", 1235, 2648, 2974,  3346, 	3632, 	"|H1:item:43551:125:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "|H1:item:43551:135:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h", "|H1:item:43551:145:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h", "|H1:item:43551:155:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h"),
		[7] =  tcc_CraftingXpObj(7, "CP40", 1501, 3217, 3632,  4108, 	4461, 	"|H1:item:43551:128:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "|H1:item:43551:138:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h", "|H1:item:43551:148:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h", "|H1:item:43551:158:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h"),
		[8] =  tcc_CraftingXpObj(8, "CP80", 1917, 4108, 4647,  5256, 	5706, 	"|H1:item:43551:132:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "|H1:item:43551:141:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h", "|H1:item:43551:151:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h", "|H1:item:43551:161:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h"),
		[9] =  tcc_CraftingXpObj(9, "CP100", 2168, 4647, 5256, 5946, 	6454, 	"|H1:item:43551:134:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "|H1:item:43551:143:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h", "|H1:item:43551:153:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h", "|H1:item:43551:163:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h"),
		[10] = tcc_CraftingXpObj(10, "CP150", 0, 6195, 7006,   7925, 	8604, 	"|H1:item:43551:308:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "|H1:item:43551:309:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h", "|H1:item:43551:310:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h", "|H1:item:43551:311:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h"),
	}
	tcc.Crafts["Woodworking"].CraftingXp = {
		[1] =  tcc_CraftingXpObj(1, "4", 214, 459, 548,     702, 	845, 	"|H1:item:43549:25:4:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h",   "|H1:item:43549:26:4:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h"	, "|H1:item:43549:27:4:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h",   "|H1:item:43549:28:4:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h"   ),
		[2] =  tcc_CraftingXpObj(2, "16", 477, 1023, 1207,  1311, 	1560, 	"|H1:item:43549:20:16:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h",  "|H1:item:43549:21:16:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h"	, "|H1:item:43549:22:16:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h",  "|H1:item:43549:23:16:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h"  ),
		[3] =  tcc_CraftingXpObj(3, "26", 751, 1609, 1755,  1921, 	2110, 	"|H1:item:43549:20:26:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h",  "|H1:item:43549:21:26:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h"	, "|H1:item:43549:22:26:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h",  "|H1:item:43549:23:26:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h"  ),
		[4] =  tcc_CraftingXpObj(4, "36", 1018, 2183, 2403, 2664, 	2949, 	"|H1:item:43549:20:36:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h",  "|H1:item:43549:21:36:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h"	, "|H1:item:43549:22:36:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h",  "|H1:item:43549:23:36:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h"  ),
		[5] =  tcc_CraftingXpObj(5, "46", 1427, 3059, 3397, 3787, 	4225, 	"|H1:item:43549:20:46:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h",  "|H1:item:43549:21:46:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h"	, "|H1:item:43549:22:46:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h",  "|H1:item:43549:23:46:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h"  ),
		[6] =  tcc_CraftingXpObj(6, "CP10", 1646, 3528, 3927, 4383, 	4736, 	"|H1:item:43549:125:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", "|H1:item:43549:135:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", "|H1:item:43549:145:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", "|H1:item:43549:155:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h" ),
		[7] =  tcc_CraftingXpObj(7, "CP40", 1971, 4225, 4736, 5317, 	5744, 	"|H1:item:43549:128:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", "|H1:item:43549:138:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", "|H1:item:43549:148:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", "|H1:item:43549:158:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h" ),
		[8] =  tcc_CraftingXpObj(8, "CP70", 2297, 4922, 5526, 6204, 	6729, 	"|H1:item:43549:131:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", "|H1:item:43549:141:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", "|H1:item:43549:151:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", "|H1:item:43549:161:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h" ),
		[9] =  tcc_CraftingXpObj(9, "CP90", 2578, 5526, 6204, 6966, 	7525, 	"|H1:item:43549:133:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", "|H1:item:43549:143:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", "|H1:item:43549:153:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", "|H1:item:43549:163:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h" ),
		[10] = tcc_CraftingXpObj(10, "CP150", 0, 7821, 8781,  9859, 	10651, 	"|H1:item:43549:308:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", "|H1:item:43549:309:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", "|H1:item:43549:310:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", "|H1:item:43549:311:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h" ),
	}
	-- skillTier, description, potencyAdditiveName, potencySubtractiveName, levelMin, levelMax, createXpWhite, deconstructXpWhite,
	-- createXpGreen, deconstructXpGreen, createXpBlue, deconstructXpBlue, createXpPurple, deconstructXpPurple, 
	-- potencyAdditiveLink, potencySubtractiveLink, itemLinkWhite, itemLinkGreen, itemLinkBlue, itemLinkPurple,
	-- potencyAdditiveTexture, potencySubtractiveTexture
	tcc.Crafts["Enchanting"].CraftingXp = {
		tcc_EnchantingXpObj(1,  "Trifling", "Jora", "Jode",     "1", "10",    164,  312,  329 , 625,  549,  1043,  986,  1874,  "|H1:item:45855:20:5:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:45817:20:13:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:20:5:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:21:5:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:22:5:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:23:5:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_050.dds", "/esoui/art/icons/crafting_components_runestones_035.dds"),
		tcc_EnchantingXpObj(1,  "Inferior", "Porade", "Notade", "5", "15",    232,  441,  464 , 882,  774,  1472,  1390, 2645,  "|H1:item:45856:20:11:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:45818:20:14:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:20:10:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:21:10:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:22:10:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:23:10:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_046.dds", "/esoui/art/icons/crafting_components_runestones_027.dds"),
		tcc_EnchantingXpObj(2,  "Petty", "Jera", "Ode",      "10", "20",   307,  584,  615 , 1172, 1027, 1957,  1845, 3516,  "|H1:item:45857:20:14:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:45819:20:14:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:20:15:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:21:15:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:22:15:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:23:15:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_040.dds", "/esoui/art/icons/crafting_components_runestones_033.dds"),
		tcc_EnchantingXpObj(2,  "Slight", "Jejora", "Tade",   "15", "25",   403,  768,  807 , 1536, 1347, 2565,  2420, 4609,  "|H1:item:45806:20:14:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:45820:20:14:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:20:20:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:21:20:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:22:20:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:23:20:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_041.dds", "/esoui/art/icons/crafting_components_runestones_028.dds"),
		tcc_EnchantingXpObj(3,  "Minor", "Odra", "Jayde",    "20", "30",   487,  928,  975 , 1857, 1628, 3101,  2925, 5572,  "|H1:item:45807:20:25:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:45821:20:25:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:20:25:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:21:25:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:22:25:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:23:25:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_049.dds", "/esoui/art/icons/crafting_components_runestones_036.dds"),
		tcc_EnchantingXpObj(3,  "Lesser", "Pojora", "Edode",  "25", "35",   592,  1127, 1184, 2254, 1977, 3764,  3552, 6763,  "|H1:item:45808:20:24:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:45822:20:14:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:20:30:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:21:30:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:22:30:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:23:30:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_048.dds", "/esoui/art/icons/crafting_components_runestones_026.dds"),
		tcc_EnchantingXpObj(4,  "Moderate", "Edora", "Pojode",  "30", "40",   692,  1318, 1385, 2636, 2312, 4402,  4154, 7910,  "|H1:item:45809:20:35:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:45823:20:35:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:20:35:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:21:35:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:22:35:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:23:35:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_043.dds", "/esoui/art/icons/crafting_components_runestones_031.dds"),
		tcc_EnchantingXpObj(4,  "Average", "Jaera", "Rekude",  "35", "45",   814,  1552, 1629, 3104, 2720, 5183,  4887, 9313,  "|H1:item:45810:20:30:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:45824:20:30:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:20:40:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:21:40:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:22:40:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:23:40:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_042.dds", "/esoui/art/icons/crafting_components_runestones_030.dds"),
		tcc_EnchantingXpObj(5,  "Strong", "Pora", "Hade",     "40", "50",   969,  1845, 1938, 3690, 3236, 6161,  5815, 11071, "|H1:item:45811:20:45:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:45825:20:18:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:20:45:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:21:45:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:22:45:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:23:45:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_047.dds", "/esoui/art/icons/crafting_components_runestones_037.dds"),
		tcc_EnchantingXpObj(5,  "Major", "Denara", "Idode",  "CP10", "CP30",   1200, 2284, 2400, 4568, 4008, 7628,  7200, 13704, "|H1:item:45812:125:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:45826:125:18:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:125:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:135:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:145:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:155:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_044.dds", "/esoui/art/icons/crafting_components_runestones_025.dds"),
		tcc_EnchantingXpObj(6,  "Greater", "Rera", "Pode",     "CP30", "CP50",   1281, 2437, 2562, 4875, 4278, 8141,  7686, 14625, "|H1:item:45813:127:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:45827:127:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:127:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:137:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:147:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:157:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_045.dds", "/esoui/art/icons/crafting_components_runestones_032.dds"),
		tcc_EnchantingXpObj(7,  "Grand", "Derado", "Kedeko", "CP50", "CP70",   1362, 2591, 2724, 5182, 4549, 8653,  8172, 15546, "|H1:item:45814:129:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:45828:129:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:129:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:139:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:149:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:159:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_051.dds", "/esoui/art/icons/crafting_components_runestones_052.dds"),
		tcc_EnchantingXpObj(8,  "Splendid", "Rekura", "Rede",   "CP70", "CP90",   1483, 2744, 2967, 5489, 4954, 9166,  8901, 16467, "|H1:item:45815:131:16:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:45829:131:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:131:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:141:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:151:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:161:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_029.dds", "/esoui/art/icons/crafting_components_runestones_038.dds"),
		tcc_EnchantingXpObj(9,  "Monumental", "Kura", "Kude",     "CP100", "CP140", 1605, 3282, 3210, 6564, 5360, 10961, 9630, 19692, "|H1:item:45816:134:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:45830:134:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:272:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:273:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:274:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:275:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_034.dds", "/esoui/art/icons/crafting_components_runestones_039.dds"),
		tcc_EnchantingXpObj(10, "Superb", "Rejera", "Jehade", "CP150", "CP150", 0,    3654, 0,    7308, 0,    12204, 0,    21930, "|H1:item:64509:308:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:64508:308:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:308:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:309:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:310:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_053.dds", "/esoui/art/icons/crafting_components_runestones_055.dds"),
		tcc_EnchantingXpObj(10, "Truly Superb", "Repora", "Itade",  "CP160", "CP160", 0,    3808, 0,    7616, 0,    12718, 0,    22854, "|H1:item:68341:366:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:68340:366:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:366:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:367:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:368:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5365:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_054.dds", "/esoui/art/icons/crafting_components_runestones_056.dds"),
	}
	tcc.Crafts["Jewelry"].CraftingXp = {
		[1] =  tcc_CraftingXpObj(1, "6", 127, 272, 326, 506, 638, "|H1:item:43536:20:6:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:43536:21:6:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:43536:22:6:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:43536:23:6:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
		[2] =  tcc_CraftingXpObj(2, "26", 525, 955, 2130, 2378, 2660, "|H1:item:43536:20:26:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:43536:21:26:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:43536:22:26:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:43536:23:26:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
		[3] =  tcc_CraftingXpObj(3, "CP10", 1115, 2391, 5426, 6078, 6620, "|H1:item:43536:125:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:43536:135:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:43536:145:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:43536:155:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
		[4] =  tcc_CraftingXpObj(4, "CP80", 2075, 3764, 8558, 9730, 10598, "|H1:item:43536:132:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:43536:142:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:43536:152:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:43536:162:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
		[5] =  tcc_CraftingXpObj(5, "CP150", 0, 5773, 13128, 14924, 16260, "|H1:item:43536:308:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:43536:309:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:43536:310:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:43536:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
	}
	-- skillTier, itemLevel, createXp, potionSolventName, potionDescription, poisonSolventName, poisonDescription, potionSolventLink, poisonSolventLink, 
	--   itemLinkPotion, itemLinkPoison, potionSolventTexture, poisonSolventTexture
	-- tcc.Crafts["Alchemy"].CraftingXp = {
		-- [1] =  tcc_AlchemyXpObj(1, "3", 	1500, 	"Natural Water", 	"Sip", 			"Grease", 		"Poison I", 	"|H1:item:883:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:75357:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:54339:30:3:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:65536|h|h", "|H1:item:76826:30:3:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:65536|h|h", "/esoui/art/icons/crafting_forester_potion_vendor_001.dds", "/esoui/art/icons/crafting_potion_base_water_1_r1.dds"),
		-- [2] =  tcc_AlchemyXpObj(1, "10", 	5000, 	"Clear Water", 		"Tincture", 	"Ichor", 		"Poison II", 	"|H1:item:1187:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:75358:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:54339:30:10:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:65536|h|h", "|H1:item:76826:30:10:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:65536|h|h", "/esoui/art/icons/crafting_potion_base_water_2_r2.dds", "/esoui/art/icons/crafting_potion_base_oil_2_r2.dds"),
		-- [3] =  tcc_AlchemyXpObj(2, "20", 	8000, 	"Pristine Water", 	"Dram", 		"Slime", 		"Poison III", 	"|H1:item:4570:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:75359:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:54339:30:20:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:65536|h|h", "|H1:item:76826:30:20:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:65536|h|h", "/esoui/art/icons/crafting_potion_base_water_2_r3.dds", "/esoui/art/icons/crafting_potion_base_oil_2_r3.dds"),
		-- [4] =  tcc_AlchemyXpObj(3, "30", 	12000, 	"Cleansed Water", 	"Potion", 		"Gall", 		"Poison IV", 	"|H1:item:23265:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:75360:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:54339:30:30:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:65536|h|h", "|H1:item:76826:30:30:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:65536|h|h", "/esoui/art/icons/crafting_potion_base_water_3_r1.dds", "/esoui/art/icons/crafting_potion_base_oil_3_r1.dds"),
		-- [5] =  tcc_AlchemyXpObj(4, "40", 	16000, 	"Filtereed Water", 	"Solution", 	"Terebinthine", "Poison V", 	"|H1:item:23266:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:75361:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:54339:30:40:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:65536|h|h", "|H1:item:76826:30:40:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:65536|h|h", "/esoui/art/icons/crafting_potion_base_water_3_r2.dds", "/esoui/art/icons/crafting_potion_base_oil_3_r2.dds"),
		-- [6] =  tcc_AlchemyXpObj(5, "CP10", 	20000, 	"Purified Water", 	"Elixir", 		"Pitch-Bile", 	"Poison VI", 	"|H1:item:23267:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:75362:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:54339:125:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:65536|h|h", "|H1:item:76826:125:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:65536|h|h", "/esoui/art/icons/crafting_potion_base_water_3_r3.dds", "/esoui/art/icons/crafting_potion_base_oil_3_r3.dds"),
		-- [7] =  tcc_AlchemyXpObj(6, "CP50", 	20000, 	"Cloud Mist", 		"Panacea", 		"Tarblack", 	"Poison VII", 	"|H1:item:23268:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:75363:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:54339:129:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:65536|h|h", "|H1:item:76826:129:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:65536|h|h", "/esoui/art/icons/crafting_potion_base_water_4_r1.dds", "/esoui/art/icons/crafting_potion_base_oil_4_r1.dds"),
		-- [8] =  tcc_AlchemyXpObj(7, "CP100", 20000, 	"Star Dew", 		"Distillate", 	"Night-Oil", 	"Poison VIII", 	"|H1:item:64500:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:75364:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:54339:134:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:65536|h|h", "|H1:item:76826:134:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:65536|h|h", "/esoui/art/icons/crafting_stardew.dds", "/esoui/art/icons/crafting_potion_base_oil_4_r2.dds"),
		-- --[9] =  tcc_AlchemyXpObj(8, "CP150", 0, 		"Lorkhan's Tears", 	"Essence", 		"Alkahest", 	"Poison IX", 	"|H1:item:64501:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:75365:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:54339:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:65536|h|h", "|H1:item:76826:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:65536|h|h", "/esoui/art/icons/crafting_lorkhanstears.dds", "/esoui/art/icons/crafting_potion_base_oil_4_r3.dds"),
	-- }
	-- -- skillTier, itemLevel, createXp, itemLinkExample, ingredientLinkArray, ingredientTextureArray
	-- tcc.Crafts["Provisioning"].CraftingXp = {
		-- [1] =  tcc_ProvisioningXpObj(1, "1", 250, 		"|H1:item:28358:3:1:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h", {"|H1:item:33754:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, {"/esoui/art/icons/crafting_critter_dom_animal_fat.dds"}),
		-- [2] =  tcc_ProvisioningXpObj(1, "5", 1500, 		"|H1:item:33606:3:5:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h", {"|H1:item:29030:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, {"/esoui/art/icons/crafting_components_bread_001.dds"}),
		-- [3] =  tcc_ProvisioningXpObj(1, "10", 3000, 	"|H1:item:33612:3:10:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h", {"|H1:item:34348:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:28666:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, {"/esoui/art/icons/crafting_components_bread_002.dds", "/esoui/art/icons/crafting_cloth_stems.dds"}),
		-- [4] =  tcc_ProvisioningXpObj(1, "15", 4500, 	"|H1:item:33999:3:15:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h", {"|H1:item:28636:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:27052:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, {"/esoui/art/icons/crafting_flower_mountain_flower_r2.dds", "/esoui/art/icons/crafting_components_gin_002.dds"}),
		-- [5] =  tcc_ProvisioningXpObj(2, "20", 6000, 	"|H1:item:33624:3:20:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h", {"|H1:item:34329:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:27043:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, {"/esoui/art/icons/crafting_components_bread_006.dds", "/esoui/art/icons/quest_honeycomb_001.dds"}),
		-- [6] =  tcc_ProvisioningXpObj(2, "25", 7500, 	"|H1:item:28501:3:25:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h", {"|H1:item:33772:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:27048:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, {"/esoui/art/icons/crafting_coffee_beans.dds", "/esoui/art/icons/crafting_components_malt_004.dds"}),
		-- [7] =  tcc_ProvisioningXpObj(3, "30", 9000, 	"|H1:item:34065:3:30:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h", {"|H1:item:34346:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:27035:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, {"/esoui/art/icons/crafting_components_gin_005.dds", "/esoui/art/icons/crafting_wood_gum.dds"}),
		-- [8] =  tcc_ProvisioningXpObj(3, "35", 10500, 	"|H1:item:34071:3:35:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h", {"|H1:item:34347:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:27035:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, {"/esoui/art/icons/crafting_ginseng.dds", "/esoui/art/icons/crafting_wood_gum.dds"}),
		-- [9] =  tcc_ProvisioningXpObj(4, "40", 12000, 	"|H1:item:57163:3:40:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h", {"|H1:item:34347:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:27052:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, {"/esoui/art/icons/crafting_ginseng.dds", "/esoui/art/icons/crafting_components_gin_002.dds"}),
		-- [10] =  tcc_ProvisioningXpObj(4, "45", 13500, 	"|H1:item:57175:3:45:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h", {"|H1:item:34347:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:28666:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, {"/esoui/art/icons/crafting_ginseng.dds", "/esoui/art/icons/crafting_cloth_stems.dds"}),
		-- --[11] =  tcc_ProvisioningXpObj(5, "CP10", 0, 	"", {"", ""}, {"", ""}),
		-- --[12] =  tcc_ProvisioningXpObj(5, "CP50", 0, 	"", {"", ""}, {"", ""}),
		-- --[13] =  tcc_ProvisioningXpObj(6, "CP100", 0, 	"", {"", ""}, {"", ""}),
		-- --[14] =  tcc_ProvisioningXpObj(6, "CP150", 0, 	"", {"", ""}, {"", ""}),
	-- }

	-- MAX INSPIRATION PER DECONSTRUCTION (note: this is affected by ESO Plus XP boost, and presumably the other boosts also)
	tcc.Crafts["Blacksmithing"].MaxXpPerDecon = {
		[1] =  1016,
		[2] =  1112,
		[3] =  1208,
		[4] =  1304,
		[5] =  1744,
		[6] =  2176,
		[7] =  2440,
		[8] =  2704,
		[9] =  2904,
		[10] = 3096,
		[11] = 3408,
		[12] = 3704,
		[13] = 4104,
		[14] = 4496,
		[15] = 4648,
		[16] = 4784,
		[17] = 5224,
		[18] = 5664,
		[19] = 5904,
		[20] = 6136,
		[21] = 6664,
		[22] = 7192,
		[23] = 7472, --?
		[24] = 7752, -- 8527 w/+10%
		[25] = 8023, -- 8826 w/+10%
		[26] = 8287, -- 9116 w/+10%
		[27] = 9047, -- 9952 w/+10%
		[28] = 9791, -- 10771 w/+10%
		[29] = 10191, -- 11211 w/+10%
	}
	tcc.Crafts["Clothing"].MaxXpPerDecon = {
		[1] =  1240,
		[2] =  1352,
		[3] =  1472,
		[4] =  1600,
		[5] =  2128,
		[6] =  2648,
		[7] =  2960,
		[8] =  3264,
		[9] =  3496,
		[10] = 3712,
		[11] = 4064,
		[12] = 4416,
		[13] = 4872,
		[14] = 5256, --?
		[15] = 5488,
		[16] = 5640,
		[17] = 6144,
		[18] = 6632,
		[19] = 6896,
		[20] = 7152,
		[21] = 7752,
		[22] = 8344,
		[23] = 8655, -- 9521 w/+10%
		[24] = 8967, -- 9864 w/+10%
		--[30] = -- 17517 w/+40% (verified 4/20/2020)
		--[31] = -- 16923 w/+40% (verified 4/20/2020)
		--[31] = -- 13763 w/+10%
		--[32] = -- 18110 w/+40% (verified 4/20/2020)
		--[32] = -- 14229 w/+10%
		--[33] = -- 14731 w/+10%
		--[34] = -- 15224 w/+10%
		--[36] = -- 16394 w/+10%
		--[37] = -- 17010 w/+10%
		--[38] = -- 17608 w/+10%
		--[39] = -- 18295 w/+10%
	}
	tcc.Crafts["Leatherworking"].MaxXpPerDecon = {
		[1] =  1240,
		[2] =  1352,
		[3] =  1472,
		[4] =  1600,
		[5] =  2128,
		[6] =  2648,
		[7] =  2960,
		[8] =  3264,
		[9] =  3496,
		[10] = 3712,
		[11] = 4064,
		[12] = 4416,
		[13] = 4872,
		[14] = 5256, --?
		[15] = 5488,
		[16] = 5640,
		[17] = 6144,
		[18] = 6632,
		[19] = 6896,
		[20] = 7152,
		[21] = 7752,
		[22] = 8344,
		[23] = 8655, -- 9521 w/+10%
		[24] = 8967, -- 9864 w/+10%
		--[31] = -- 13763 w/+10%
		--[32] = -- 14229 w/+10%
		--[33] = -- 14731 w/+10%
		--[34] = -- 15224 w/+10%
	}
	tcc.Crafts["Woodworking"].MaxXpPerDecon = {
		[1] =  2384,
		[2] =  2592,
		[3] =  2816,
		[4] =  3064,
		[5] =  3984, -- 4382 w/+10%
		[6] =  4895, -- 5385 w/+10%
		[7] =  5135, -- 5649 w/+10%
		[8] =  5375, -- 5913 w/+10%
		[9] =  5847, -- 6432 w/+10%
		[10] = 6480, -- 7128 w/+10%
		[11] = 6992, -- 7691 w/+10%
		[12] = 7495, -- 8245 w/+10%
		[13] = 8175, -- 8993 w/+10%
		[14] = 8847, -- 9732 w/+10%
		[15] = 9015, -- 9917 w/+10%
		[16] = 9184, -- 10102 w/+10%	-- 12858 w/+40%
		[17] = 9887, -- 10876 w/+10%	-- 13843 w/+40%
		[18] = 10600, -- 11660 w/+10%	-- 14840 w/+40%
		--[19] = 						-- 15277 w/+40%
	}
	tcc.Crafts["Enchanting"].MaxXpPerDecon = {
		[1] =  426, -- 469   w/+10%
		[2] =  2457, -- 2703  w/+10%
		[3] =  2457, -- 2703  w/+10%
		[4] =  3953, -- 4349  w/+10%
		[5] =  3953, -- 4349  w/+10%
		[6] =  4746, -- 5221  w/+10%
		[7] =  4746, -- 5221  w/+10%
		[8] =  5280, -- 5808  w/+10%
		[9] =  6335, -- 6969  w/+10%
		[10] = 7362, -- 8099  w/+10%
		[11] = 7362, -- 8099  w/+10%
		[12] = 8724, -- 9597  w/+10%
		[13] = 8724, -- 9597  w/+10%
		[14] = 9073, -- 9981  w/+10%
		[15] = 9073, -- 9981  w/+10%
		[16] = 10501, -- 11552  w/+10%
		[17] = 10501, -- 11552  w/+10%
		[18] = 11153, -- 12269  w/+10%
		[19] = 11153, -- 12269  w/+10%
		[20] = 12828, -- 14111  w/+10%
		[21] = 12828, -- 14111  w/+10%
		[22] = 13605, -- 14966  w/+10%
		[23] = 13605, -- 14966  w/+10%
		[24] = 14318, -- 15750  w/+10%
		[25] = 14318, -- 15750  w/+10%
		[26] = 16671, -- 18339  w/+10%
		[27] = 16671, -- 18339  w/+10%
		[28] = 17751, -- 19527  w/+10%
		[29] = 17751, -- 19527  w/+10%
		[30] = 18815, -- 20697  w/+10%
		[31] = 19691, -- 21661  w/+10% --?
		[32] = 19691, -- 21661  w/+10% --?
		[33] = 19691, -- 21661  w/+10% --?
		[34] = 21303, -- 23434  w/+10% --?
		[35] = 21303, -- 23434  w/+10% --?
		[36] = 21926, -- 24119  w/+10% --?
		[37] = 21926, -- 24119  w/+10% --?
	}
	tcc.Crafts["Jewelry"].MaxXpPerDecon = {
		[1] =  1016,
		[2] =  1112,
		[3] =  1208,
		[4] =  1304,
		[5] =  1744,
		[6] =  2176,
		[7] =  2440,
		[8] =  2704,	-- 3786 w/+40% (verified 4/20/2020)
		[9] =  2904,
		[10] = 3096,
		[11] = 3408,
		[12] = 3704,
		[13] = 4104,	-- confirmed
		[14] = 4496,
		[15] = 4648,	-- confirmed
		[16] = 4784,	-- confirmed
		[17] = 5224,	-- confirmed
		[18] = 5664,
		[19] = 5904,
		[20] = 6136,
		[21] = 6664,
		[22] = 7192,
		[23] = 7472,
		[24] = 7752,
		[25] = 8023,
		[26] = 8287,
		[27] = 9047,
		[28] = 9791,
		[29] = 10191,
	}
	
	--/esoui/art/icons/crafting_components_runestones_010.dds??? ...012, 019
	-- tcc_EssenceRuneObj(name, translation, additiveEffect, subtractiveEffect, itemLink, itemTexture)
	tcc.EssenceRunes = {
		["Dekeipa"] = tcc_EssenceRuneObj("Dekeipa", "Frost", "(W) Frost Damage", "(J) Frost Resistance", "|H1:item:45839:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_017.dds"),
		["Deni"] = tcc_EssenceRuneObj("Deni", "Stamina", "(A) Increase Max Stamina", "(W) Magic Damage + Restore Stamina", "|H1:item:45833:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_016.dds"),
		["Denima"] = tcc_EssenceRuneObj("Denima", "Stamina Regen", "(J) Stamina Recovery", "(J) Reduce cost of Stamina abilities", "|H1:item:45836:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_015.dds"),
		["Deteri"] = tcc_EssenceRuneObj("Deteri", "Armor", "(A) Damage Shield 5 sec", "(W) Reduce target's Armor", "|H1:item:45842:20:30:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_014.dds"),
		["Haoko"] = tcc_EssenceRuneObj("Haoko", "Disease", "(W) Disease Damage", "(J) Disease Resistance", "|H1:item:45841:20:14:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_013.dds"),
		["Kaderi"] = tcc_EssenceRuneObj("Kaderi", "Shield", "(J) Increase Bash Damage", "(J) Reduce cost of Bash and Blocking", "|H1:item:45849:20:16:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_011.dds"),
		["Kuoko"] = tcc_EssenceRuneObj("Kuoko", "Poison", "(W) Poison Damage", "(J) Poison Resistance", "|H1:item:45837:20:14:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_024.dds"),
		["Makderi"] = tcc_EssenceRuneObj("Makderi", "Spell Harm", "(J) Spell Damage", "(J) Spell Resistance", "|H1:item:45848:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_009.dds"),
		["Makko"] = tcc_EssenceRuneObj("Makko", "Magicka", "(A) Increase Max Magicka", "(W) Magic Damage + Restore Magicka", "|H1:item:45832:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_023.dds"),
		["Makkoma"] = tcc_EssenceRuneObj("Makkoma", "Magicka Regen", "(J) Magicka Recovery", "(J) Reduce Magicka cost of spells", "|H1:item:45835:20:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_022.dds"),
		["Meip"] = tcc_EssenceRuneObj("Meip", "Shock", "(W) Shock Damage", "(J) Shock Resistance", "|H1:item:45840:20:24:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_021.dds"),
		["Oko"] = tcc_EssenceRuneObj("Oko", "Health", "(A) Increase Max Health", "(W) Magic Damage + Restore Health", "|H1:item:45831:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_020.dds"),
		["Okoma"] = tcc_EssenceRuneObj("Okoma", "Health Regen", "(J) Health Recovery", "(W) Unresistable Damage", "|H1:item:45834:20:18:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", ""),
		["Okori"] = tcc_EssenceRuneObj("Okori", "Power", "(W) Increase Weapon Damage 5 sec", "(W) Reduce target weapon damage 5 sec", "|H1:item:45843:20:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_008.dds"),
		["Oru"] = tcc_EssenceRuneObj("Oru", "Alchemist", "(J) Increase effect of restoration potions", "(J) Reduce cooldown of potions", "|H1:item:45846:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_007.dds"),
		["Rakeipa"] = tcc_EssenceRuneObj("Rakeipa", "Fire", "(W) Flame Damage", "(J) Flame Resistance", "|H1:item:45838:20:30:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_018.dds"),
		["Taderi"] = tcc_EssenceRuneObj("Taderi", "Physical Harm", "(J) Weapon Damage", "(J) Armor", "|H1:item:45847:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_006.dds"),
		["Hakeijo"] = tcc_EssenceRuneObj("Hakeijo", "(Prismatic)", "??? +Dmg to Daedra and Undead ???", "??? Health, Stamina, Magicka ???", "|H1:item:68342:20:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_058.dds"),
	}
end


--[[ Object Functions ]]--

function tcc_CraftObj(craftName, craftType, optimalItemType, skillIndex)
	--tccTestLabel:SetText(tccTestLabel:GetText() .. "Creating craft " .. craftName .. ", type " .. craftType .. ", optimal item type " .. optimalItemType .. ", skillIndex " .. skillIndex .. "\r\n")
	return {
		CraftName = craftName,
		CraftType = craftType,
		OptimalItemType = optimalItemType,
		SkillIndex = skillIndex,
	}
end

function tcc_CraftingPassiveObj(nameGeneric, name, description, texture, rankAvailableAtSkillLevelArray)
	return {
		NameGeneric = nameGeneric,
		Name = name,
		Description = description,
		Texture = texture,
		RankAvailableAtSkillLevelArray = rankAvailableAtSkillLevelArray,
	}
end

function tcc_CraftingXpObj(skillTier, optimalItemLvl, createXp, deconstructXpWhite, deconstructXpGreen, deconstructXpBlue, deconstructXpPurple, itemLinkWhite, itemLinkGreen, itemLinkBlue, itemLinkPurple)
	return {
		SkillTier = skillTier,
		OptimalItemLvl = optimalItemLvl,
		CreateXp = createXp,
		DeconstructXpWhite = deconstructXpWhite,
		DeconstructXpGreen = deconstructXpGreen,
		DeconstructXpBlue = deconstructXpBlue,
		DeconstructXpPurple = deconstructXpPurple,
		ItemLinkWhite = itemLinkWhite,
		ItemLinkGreen = itemLinkGreen,
		ItemLinkBlue = itemLinkBlue,
		ItemLinkPurple = itemLinkPurple,
	}
end

function tcc_EnchantingXpObj(skillTier, description, potencyAdditiveName, potencySubtractiveName, levelMin, levelMax, createXpWhite, deconstructXpWhite, createXpGreen, deconstructXpGreen, createXpBlue, deconstructXpBlue, createXpPurple, deconstructXpPurple, potencyAdditiveLink, potencySubtractiveLink, itemLinkWhite, itemLinkGreen, itemLinkBlue, itemLinkPurple, potencyAdditiveTexture, potencySubtractiveTexture)
	return {
		SkillTier = skillTier,
		Description = description,
		PotencyAdditiveName = potencyAdditiveName,
		PotencySubtractiveName = potencySubtractiveName,
		LevelMin = levelMin,
		LevelMax = levelMax,
		CreateXpWhite = createXpWhite,
		DeconstructXpWhite = deconstructXpWhite,
		CreateXpGreen = createXpGreen,
		DeconstructXpGreen = deconstructXpGreen,
		CreateXpBlue = createXpBlue,
		DeconstructXpBlue = deconstructXpBlue,
		CreateXpPurple = createXpPurple,
		DeconstructXpPurple = deconstructXpPurple,
		PotencyAdditiveLink = potencyAdditiveLink,
		PotencySubtractiveLink = potencySubtractiveLink,
		ItemLinkWhite = itemLinkWhite,
		ItemLinkGreen = itemLinkGreen,
		ItemLinkBlue = itemLinkBlue,
		ItemLinkPurple = itemLinkPurple,
		PotencyAdditiveTexture = potencyAdditiveTexture,
		PotencySubtractiveTexture = potencySubtractiveTexture,
	}
end

-- skillTier, itemLevel, createXp, potionSolventName, potionDescription, poisonSolventName, poisonDescription, potionSolventLink, poisonSolventLink, 
--   itemLinkPotion, itemLinkPoison, potionSolventTexture, poisonSolventTexture
-- function tcc_AlchemyXpObj(skillTier, itemLevel, createXp, potionSolventName, potionDescription, poisonSolventName, poisonDescription, potionSolventLink, poisonSolventLink, itemLinkPotion, itemLinkPoison, potionSolventTexture, poisonSolventTexture)
	-- return {
		-- SkillTier = skillTier,
		-- ItemLevel = itemLevel,
		-- CreateXp = createXp,
		-- PotionSolventName = potionSolventName,
		-- PotionDescription = potionDescription,
		-- PoisonSolventName = poisonSolventName,
		-- PoisonDescription = poisonDescription,
		-- PotionSolventLink = potionSolventLink,
		-- PoisonSolventLink = poisonSolventLink,
		-- ItemLinkPotion = itemLinkPotion,
		-- ItemLinkPoison = itemLinkPoison,
		-- PotionSolventTexture = potionSolventTexture,
		-- PoisonSolventTexture = poisonSolventTexture,
	-- }
-- end

-- -- skillTier, itemLevel, createXp, itemLinkExample, ingredientLinkArray, ingredientTextureArray
-- -- NOTE: Normal recipes only use 1 of each ingredient. Some exotic recipes may use multiple.
-- function tcc_ProvisioningXpObj(skillTier, itemLevel, createXp, itemLinkExample, ingredientLinkArray, ingredientTextureArray)
	-- return {
		-- SkillTier = skillTier,
		-- ItemLevel = itemLevel,
		-- CreateXp = createXp,
		-- ItemLinkExample = itemLinkExample,
		-- IngredientLinkArray = ingredientLinkArray,
		-- IngredientTextureArray = ingredientTextureArray,
	-- }
-- end

function tcc_EssenceRuneObj(name, translation, additiveEffect, subtractiveEffect, itemLink, itemTexture)
	return {
		Name = name, 
		Translation = translation, 
		AdditiveEffect = additiveEffect, 
		SubtractiveEffect = subtractiveEffect, 
		ItemLink = itemLink,
		ItemTexture = itemTexture,
	}
end
