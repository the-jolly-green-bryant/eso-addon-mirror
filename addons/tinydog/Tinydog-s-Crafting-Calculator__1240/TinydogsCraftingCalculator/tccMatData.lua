-- TinydogsCraftingCalculator Item Data LUA File
-- Last Updated June 29, 2024 by @tinydog
-- Created September 2015 by @tinydog - tinydog1234@hotmail.com

function tcc_InitItemData()
	-- Using an ordered list of quality names, so that I can reference the unordered list of quality objects in the correct order.
	tcc.ItemQualityNames = { "White", "Green", "Blue", "Purple", "Gold" }	
	tcc.ItemQuality = {
		-- tcc_IconObj(iconType, key, name, shortName, materialName, itemLink, normalTexture, mouseOverTexture, selectedTexture)
		["White"] = tcc_IconObj("Quality", "White", "Normal (White) Quality", nil, nil, nil, "TinydogsCraftingCalculator/images/quality/white_up.dds", "TinydogsCraftingCalculator/images/quality/over.dds", "TinydogsCraftingCalculator/images/quality/white_down.dds"),
		["Green"] = tcc_IconObj("Quality", "Green", "Fine (Green) Quality", nil, nil, nil, "TinydogsCraftingCalculator/images/quality/green_up.dds", "TinydogsCraftingCalculator/images/quality/over.dds", "TinydogsCraftingCalculator/images/quality/green_down.dds"),
		["Blue"] = tcc_IconObj("Quality", "Blue", "Superior (Blue) Quality", nil, nil, nil, "TinydogsCraftingCalculator/images/quality/blue_up.dds", "TinydogsCraftingCalculator/images/quality/over.dds", "TinydogsCraftingCalculator/images/quality/blue_down.dds"),
		["Purple"] = tcc_IconObj("Quality", "Purple", "Epic (Purple) Quality", nil, nil, nil, "TinydogsCraftingCalculator/images/quality/purple_up.dds", "TinydogsCraftingCalculator/images/quality/over.dds", "TinydogsCraftingCalculator/images/quality/purple_down.dds"),
		["Gold"] = tcc_IconObj("Quality", "Gold", "Legendary (Gold) Quality", nil, nil, nil, "TinydogsCraftingCalculator/images/quality/gold_up.dds", "TinydogsCraftingCalculator/images/quality/over.dds", "TinydogsCraftingCalculator/images/quality/gold_down.dds"),
	}
	-- tcc_ItemQualityExtraProperties(qualityIconObj, index, colorCode, upgradeMatQtyPerImprovementPassiveRank)
	tcc.ItemQuality.White = tcc_ItemQualityExtraProperties(tcc.ItemQuality.White, 1, "FFFFFF", 		{ 0, 0, 0, 0 });
	tcc.ItemQuality.Green = tcc_ItemQualityExtraProperties(tcc.ItemQuality.Green, 2, "00FF00", 		{ 5, 4, 3, 2 });
	tcc.ItemQuality.Blue = tcc_ItemQualityExtraProperties(tcc.ItemQuality.Blue, 3, "6666FF", 		{ 7, 5, 4, 3 });
	tcc.ItemQuality.Purple = tcc_ItemQualityExtraProperties(tcc.ItemQuality.Purple, 4, "FF00FF", 	{ 10, 7, 5, 4 });
	tcc.ItemQuality.Gold = tcc_ItemQualityExtraProperties(tcc.ItemQuality.Gold, 5, "FFFF00", 		{ 20, 14, 10, 8 });
	
	tcc_InitQualityMats()
	
	tcc.TexturePaths = {
		-- % will be replaced with "up" (normal), "down" (rollover), "over" (selected), or "disabled"
		ArmorCategories = {
			["Heavy"] = "/esoui/art/inventory/inventory_tabicon_armor_%.dds",
			["Medium"] = "TinydogsCraftingCalculator/images/armor/medium_%.dds",
			["Light"] = "TinydogsCraftingCalculator/images/armor/light_%.dds",
		},
		BodyParts = {
			["Chest"] = "TinydogsCraftingCalculator/images/armor/chest_%.dds",
			["Shirt"] = "TinydogsCraftingCalculator/images/armor/chest_%.dds",
			["Feet"] = "TinydogsCraftingCalculator/images/armor/feet_%.dds",
			["Hands"] = "TinydogsCraftingCalculator/images/armor/hands_%.dds",
			["Head"] = "/esoui/art/inventory/inventory_tabicon_armor_%.dds",
			["Legs"] = "TinydogsCraftingCalculator/images/armor/legs_%.dds",
			["Shoulders"] = "TinydogsCraftingCalculator/images/armor/shoulders_%.dds",
			["Waist"] = "TinydogsCraftingCalculator/images/armor/belt_%.dds",
		},
		OtherItemTypes = {
			["Shield"] = "TinydogsCraftingCalculator/images/armor/shield_%.dds",
			["Axe"] = "TinydogsCraftingCalculator/images/weapon/axe_%.dds",
			["Mace"] = "TinydogsCraftingCalculator/images/weapon/mace_%.dds",
			["Sword"] = "TinydogsCraftingCalculator/images/weapon/sword_%.dds",
			["Dagger"] = "TinydogsCraftingCalculator/images/weapon/dagger_%.dds",
			["BattleAxe"] = "TinydogsCraftingCalculator/images/weapon/battleaxe_%.dds",
			["Maul"] = "TinydogsCraftingCalculator/images/weapon/mace_%.dds",
			["Greatsword"] = "TinydogsCraftingCalculator/images/weapon/greatsword_%.dds",
			["Bow"] = "TinydogsCraftingCalculator/images/weapon/bow_%.dds",
			["Fire"] = "TinydogsCraftingCalculator/images/weapon/fire_%.dds",
			["Ice"] = "TinydogsCraftingCalculator/images/weapon/ice_%.dds",
			["Lightning"] = "TinydogsCraftingCalculator/images/weapon/lightning_%.dds",
			["Resto"] = "TinydogsCraftingCalculator/images/weapon/restoration_%.dds",
		},
		JewelryTypes = {
			["Ring"] = "TinydogsCraftingCalculator/images/armor/ring_%.dds",
			["Necklace"] = "TinydogsCraftingCalculator/images/armor/necklace_%.dds",
		},
	}

	-- Item Materials
	tcc.ItemMaterials = {
		-- ["SkillTier"], ["MinimumLevel"],
		-- ["MaterialNameCloth"], ["MaterialNameLeather"], ["MaterialNameMetal"], ["MaterialNameWood"], 
		-- ["MaterialLinkCloth"], ["MaterialLinkLeather"], ["MaterialLinkMetal"], ["MaterialLinkWood"],
		-- ["MaterialTextureCloth"], ["MaterialTextureLeather"], ["MaterialTextureMetal"], ["MaterialTextureWood"]
		[1] = tcc_ItemMaterialObj(1, "1", "Jute", "Rawhide", "Iron", "Maple", "|H1:item:811:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:794:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:5413:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:803:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_light_armor_standard_r_001.dds", "/esoui/art/icons/crafting_medium_armor_standard_f_001.dds", "/esoui/art/icons/crafting_ore_base_iron_r2.dds", "/esoui/art/icons/crafting_forester_weapon_component_006.dds"),
		[2] = tcc_ItemMaterialObj(2, "16", "Flax", "Hide", "Steel", "Oak", "|H1:item:4463:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:4447:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:4487:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:533:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_cloth_base_flax_r3.dds", "/esoui/art/icons/crafting_leather_base_boiled_leather_r3.dds", "/esoui/art/icons/crafting_ore_base_high_iron_r3.dds", "/esoui/art/icons/crafting_wood_base_oak_r3.dds"),
		[3] = tcc_ItemMaterialObj(3, "26", "Cotton", "Leather", "Orichalcum", "Beech", "|H1:item:23125:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:23099:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:23107:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:23121:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_cloth_base_cotton_r2.dds", "/esoui/art/icons/crafting_leather_base_boiled_leather_r2.dds", "/esoui/art/icons/crafting_ore_base_iron_r3.dds", "/esoui/art/icons/crafting_wood_base_beech_r3.dds"),
		[4] = tcc_ItemMaterialObj(4, "36", "Spidersilk", "Thick Leather", "Dwarven", "Hickory", "|H1:item:23126:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:23100:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:6000:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:23122:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_cloth_base_spidersilk_r2.dds", "/esoui/art/icons/crafting_leather_base_topgrain_r3.dds", "/esoui/art/icons/crafting_smith_plug_standard_r_001.dds", "/esoui/art/icons/crafting_wood_base_hickory_r3.dds"),
		[5] = tcc_ItemMaterialObj(5, "46", "Ebonthread", "Fell Hide", "Ebony", "Yew", "|H1:item:23127:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:23101:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:6001:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:23123:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_cloth_base_ebonthread_r2.dds", "/esoui/art/icons/crafting_leather_base_topgrain_r2.dds", "/esoui/art/icons/crafting_ore_base_ebony_r3.dds", "/esoui/art/icons/crafting_wood_base_yew_r3.dds"	),
		[6] = tcc_ItemMaterialObj(6, "CP10", "Kresh Fiber", "Topgrain Hide", "Calcinium", "Birch", "|H1:item:46131:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:46135:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:46127:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:46139:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_cloth_famin.dds", "/esoui/art/icons/crafting_hide_fell.dds", "/esoui/art/icons/crafting_ingot_calcinium.dds", "/esoui/art/icons/crafting_wood_sanded_birch.dds"),
		[7] = tcc_ItemMaterialObj(7, "CP40", "Ironthread", "Iron Hide", "Galatite", "Ash", "|H1:item:46132:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:46136:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:46128:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:46140:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_cloth_ironthread.dds", "/esoui/art/icons/crafting_hide_iron.dds", "/esoui/art/icons/crafting_ingot_galatite.dds", "/esoui/art/icons/crafting_wood_sanded_ash.dds"),
		[8] = tcc_ItemMaterialObj(8, "CP70", "Silverweave", "Superb Hide", "Quicksilver", "Mahogany", "|H1:item:46133:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:46137:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:46129:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:46141:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_cloth_silverweave.dds", "/esoui/art/icons/crafting_hide_scaled.dds", "/esoui/art/icons/crafting_ingot_moonstone.dds", "/esoui/art/icons/crafting_wood_sanded_mahogany.dds"),
		[9] = tcc_ItemMaterialObj(9, "CP90", "Void Cloth", "Shadowhide", "Voidstone", "Nightwood", "|H1:item:46134:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:46138:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:46130:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:46142:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_cloth_void.dds", "/esoui/art/icons/crafting_leather_base_leather_r2.dds", "/esoui/art/icons/crafting_ingot_voidstone.dds", "/esoui/art/icons/crafting_wood_sanded_nightwood.dds"),
		[10] = tcc_ItemMaterialObj(10, "CP150", "Ancestor Silk", "Rubedo Leather", "Rubedite", "Ruby Ash", "|H1:item:64504:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:64506:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:64489:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H1:item:64502:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_cloth_base_harvestersilk.dds", "/esoui/art/icons/crafting_daedric_skin.dds", "/esoui/art/icons/crafting_colossus_iron.dds", "/esoui/art/icons/crafting_wood_ruddy_ash.dds"),
	}

	tcc.JewelryItemMaterials = {
		-- ["SkillTier"], ["MinimumLevel"], ["MaterialNameJewelry"], ["MaterialLinkJewelry"], ["MaterialTextureJewelry"]
		[1] = tcc_JewelryItemMaterialObj(1, "1", "Pewter", "|H1:item:135138:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_pewter_refined.dds"),
		[2] = tcc_JewelryItemMaterialObj(2, "26", "Copper", "|H1:item:135140:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_copper_refined.dds"),
		[3] = tcc_JewelryItemMaterialObj(3, "CP10", "Silver", "|H1:item:135142:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_silver_refined.dds"),
		[4] = tcc_JewelryItemMaterialObj(4, "CP80", "Electrum", "|H1:item:135144:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_electrum_refined.dds"),
		[5] = tcc_JewelryItemMaterialObj(5, "CP150", "Platinum", "|H1:item:135146:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_platinum_refined.dds"),
	}
	
	-- Item Levels
	tcc.ItemLevels = {
		-- ["ItemLevel"], ["SkillTier"], ["SkillTierJewelry"], ["QtyModifierType"], ["BaseQtyCloth"], ["BaseQtyLeather"], ["BaseQtyMetal"], ["BaseQtyWood"], ["BaseQtyRing"], ["BaseQtyNecklace"]
		-- Numeric array index number corresponds to the Level Slider value.
		-- To look up a level by the actual level name, use tcc_ItemLevelByName().
		[1] = tcc_ItemLevelObj("1", 1, 1, "QtyModifier", 5, 5, 2, 3, 					2,	3),
		[2] = tcc_ItemLevelObj("4", 1, 1, "QtyModifier", 6, 6, 3, 4, 					3,	5),
		[3] = tcc_ItemLevelObj("6", 1, 1, "QtyModifier", 7, 7, 4, 5, 					4,	6),
		[4] = tcc_ItemLevelObj("8", 1, 1, "QtyModifier", 8, 8, 5, 6, 					5,	8),
		[5] = tcc_ItemLevelObj("10", 1, 1, "QtyModifier", 9, 9, 6, 7, 					6,	9),
		[6] = tcc_ItemLevelObj("12", 1, 1, "QtyModifier", 10, 10, 7, 8, 				7,	11),
		[7] = tcc_ItemLevelObj("14", 1, 1, "QtyModifier", 11, 11, 8, 9, 				8,	12),
		[8] = tcc_ItemLevelObj("16", 2, 1, "QtyModifier", 6, 6, 3, 4, 					9,	14),
		[9] = tcc_ItemLevelObj("18", 2, 1, "QtyModifier", 7, 7, 4, 5, 					10,	15),
		[10] = tcc_ItemLevelObj("20", 2, 1, "QtyModifier", 8, 8, 5, 6, 					11,	17),
		[11] = tcc_ItemLevelObj("22", 2, 1, "QtyModifier", 9, 9, 6, 7, 					12,	19),
		[12] = tcc_ItemLevelObj("24", 2, 1, "QtyModifier", 10, 10, 7, 8, 				13,	20),
		[13] = tcc_ItemLevelObj("26", 3, 2, "QtyModifier", 7, 7, 4, 5, 					3,	5),
		[14] = tcc_ItemLevelObj("28", 3, 2, "QtyModifier", 8, 8, 5, 6, 					4,	6),
		[15] = tcc_ItemLevelObj("30", 3, 2, "QtyModifier", 9, 9, 6, 7, 					5,	8),
		[16] = tcc_ItemLevelObj("32", 3, 2, "QtyModifier", 10, 10, 7, 8, 				6,	9),
		[17] = tcc_ItemLevelObj("34", 3, 2, "QtyModifier", 11, 11, 8, 9, 				7,	11),
		[18] = tcc_ItemLevelObj("36", 4, 2, "QtyModifier", 8, 8, 5, 6, 					8,	12),
		[19] = tcc_ItemLevelObj("38", 4, 2, "QtyModifier", 9, 9, 6, 7, 					8,	14),
		[20] = tcc_ItemLevelObj("40", 4, 2, "QtyModifier", 10, 10, 7, 8, 				10,	15),
		[21] = tcc_ItemLevelObj("42", 4, 2, "QtyModifier", 11, 11, 8, 9, 				11,	17),
		[22] = tcc_ItemLevelObj("44", 4, 2, "QtyModifier", 12, 12, 9, 10, 				12,	18),
		[23] = tcc_ItemLevelObj("46", 5, 2, "QtyModifier", 9, 9, 6, 7, 					13,	20),
		[24] = tcc_ItemLevelObj("48", 5, 2, "QtyModifier", 10, 10, 7, 8, 				14,	21),
		[25] = tcc_ItemLevelObj("50", 5, 2, "QtyModifier", 11, 11, 8, 9, 				15,	23),
		[26] = tcc_ItemLevelObj("CP10", 6, 3, "QtyModifier", 10, 10, 7, 8, 				4,	6),
		[27] = tcc_ItemLevelObj("CP20", 6, 3, "QtyModifier", 11, 11, 8, 9, 				6,	9),
		[28] = tcc_ItemLevelObj("CP30", 6, 3, "QtyModifier", 12, 12, 9, 10, 			8,	12),
		[29] = tcc_ItemLevelObj("CP40", 7, 3, "QtyModifier", 11, 11, 8, 9, 				10,	15),
		[30] = tcc_ItemLevelObj("CP50", 7, 3, "QtyModifier", 12, 12, 9, 10, 			12,	18),
		[31] = tcc_ItemLevelObj("CP60", 7, 3, "QtyModifier", 13, 13, 10, 11, 			14,	21),
		[32] = tcc_ItemLevelObj("CP70", 8, 3, "QtyModifier", 12, 12, 9, 10, 			16,	24),
		[33] = tcc_ItemLevelObj("CP80", 8, 4, "QtyModifier", 13, 13, 10, 11, 			6,	8),
		[34] = tcc_ItemLevelObj("CP90", 9, 4, "QtyModifier", 13, 13, 10, 11, 			8,	12),
		[35] = tcc_ItemLevelObj("CP100", 9, 4, "QtyModifier", 14, 14, 11, 12, 			10,	16),
		[36] = tcc_ItemLevelObj("CP110", 9, 4, "QtyModifier", 15, 15, 12, 13, 			12,	20),
		[37] = tcc_ItemLevelObj("CP120", 9, 4, "QtyModifier", 16, 16, 13, 14, 			14,	24),
		[38] = tcc_ItemLevelObj("CP130", 9, 4, "QtyModifier", 17, 17, 14, 15, 			16,	28),
		[39] = tcc_ItemLevelObj("CP140", 9, 4, "QtyModifier", 18, 18, 15, 16, 			18,	32),
		[40] = tcc_ItemLevelObj("CP150", 10, 5, "QtyModifierCP150", 13, 13, 10, 12, 	10,	15),
		[41] = tcc_ItemLevelObj("CP160", 10, 5, "QtyModifierCP160", 130, 130, 100, 120, 100,150),
	}

	-- Item Types
	tcc.ItemTypes = {
		-- ["Key"], ["CraftName"], ["ItemCategory"], ["BodyPart"], ["TraitType"], ["ItemName"], ["MaterialCategory"], 
		-- ["QtyModifier"], ["QtyModifierCP150"], ["QtyModifierCP160"]
		["Light"] = {},
		["Medium"] = {},
		["Heavy"] = {},
		["Robe"] = tcc_ItemTypeObj(		"Robe", "Clothing", "Light", "Chest", "Armor", "Robe", "Cloth", 2, 2, 20),
		["Shirt"] = tcc_ItemTypeObj(	"Shirt", "Clothing", "Light", "Chest", "Armor", "Shirt", "Cloth", 2, 2, 20),
		["Shoes"] = tcc_ItemTypeObj(	"Shoes", "Clothing", "Light", "Feet", "Armor", "Shoes", "Cloth", 0, 0, 0),
		["Gloves"] = tcc_ItemTypeObj(	"Gloves", "Clothing", "Light", "Hands", "Armor", "Gloves", "Cloth", 0, 0, 0),
		["Hat"] = tcc_ItemTypeObj(		"Hat", "Clothing", "Light", "Head", "Armor", "Hat", "Cloth", 0, 0, 0),
		["Breeches"] = tcc_ItemTypeObj(	"Breeches", "Clothing", "Light", "Legs", "Armor", "Breeches", "Cloth", 1, 1, 10),
		["Epaulets"] = tcc_ItemTypeObj(	"Epaulets", "Clothing", "Light", "Shoulders", "Armor", "Epaulets", "Cloth", 0, 0, 0),
		["Sash"] = tcc_ItemTypeObj(		"Sash", "Clothing", "Light", "Waist", "Armor", "Sash", "Cloth", 0, 0, 0),
		["Jack"] = tcc_ItemTypeObj(		"Jack", "Clothing", "Medium", "Chest", "Armor", "Jack", "Leather", 2, 2, 20),
		["Boots"] = tcc_ItemTypeObj(	"Boots", "Clothing", "Medium", "Feet", "Armor", "Boots", "Leather", 0, 0, 0),
		["Bracers"] = tcc_ItemTypeObj(	"Bracers", "Clothing", "Medium", "Hands", "Armor", "Bracers", "Leather", 0, 0, 0),
		["Helmet"] = tcc_ItemTypeObj(	"Helmet", "Clothing", "Medium", "Head", "Armor", "Helmet", "Leather", 0, 0, 0),
		["Guards"] = tcc_ItemTypeObj(	"Guards", "Clothing", "Medium", "Legs", "Armor", "Guards", "Leather", 1, 1, 10),
		["ArmCops"] = tcc_ItemTypeObj(	"ArmCops", "Clothing", "Medium", "Shoulders", "Armor", "Arm Cops", "Leather", 0, 0, 0),
		["Belt"] = tcc_ItemTypeObj(		"Belt", "Clothing", "Medium", "Waist", "Armor", "Belt", "Leather", 0, 0, 0),
		["Cuirass"] = tcc_ItemTypeObj(	"Cuirass", "Blacksmithing", "Heavy", "Chest", "Armor", "Cuirass", "Metal", 5, 5, 50),
		["Sabatons"] = tcc_ItemTypeObj(	"Sabatons", "Blacksmithing", "Heavy", "Feet", "Armor", "Sabatons", "Metal", 3, 3, 30),
		["Gauntlets"] = tcc_ItemTypeObj("Gauntlets", "Blacksmithing", "Heavy", "Hands", "Armor", "Gauntlets", "Metal", 3, 3, 30),
		["Helm"] = tcc_ItemTypeObj(		"Helm", "Blacksmithing", "Heavy", "Head", "Armor", "Helm", "Metal", 3, 3, 30),
		["Greaves"] = tcc_ItemTypeObj(	"Greaves", "Blacksmithing", "Heavy", "Legs", "Armor", "Greaves", "Metal", 4, 4, 40),
		["Pauldrons"] = tcc_ItemTypeObj("Pauldrons", "Blacksmithing", "Heavy", "Shoulders", "Armor", "Pauldrons", "Metal", 3, 3, 30),
		["Girdle"] = tcc_ItemTypeObj(	"Girdle", "Blacksmithing", "Heavy", "Waist", "Armor", "Girdle", "Metal", 3, 3, 30),
		["Axe"] = tcc_ItemTypeObj(		"Axe", "Blacksmithing", "1H", "", "Weapon", "Axe", "Metal", 1, 1, 10),
		["Mace"] = tcc_ItemTypeObj(		"Mace", "Blacksmithing", "1H", "", "Weapon", "Mace", "Metal", 1, 1, 10),
		["Sword"] = tcc_ItemTypeObj(	"Sword", "Blacksmithing", "1H", "", "Weapon", "Sword", "Metal", 1, 1, 10),
		["Dagger"] = tcc_ItemTypeObj(	"Dagger", "Blacksmithing", "1H", "", "Weapon", "Dagger", "Metal", 0, 0, 0),
		["BattleAxe"] = tcc_ItemTypeObj("BattleAxe", "Blacksmithing", "2H", "", "Weapon", "Battle Axe", "Metal", 3, 4, 40),
		["Maul"] = tcc_ItemTypeObj(		"Maul", "Blacksmithing", "2H", "", "Weapon", "Maul", "Metal", 3, 4, 40),
		["Greatsword"] = tcc_ItemTypeObj("Greatsword", "Blacksmithing", "2H", "", "Weapon", "Greatsword", "Metal", 3, 4, 40),
		["Bow"] = tcc_ItemTypeObj(		"Bow", "Woodworking", "", "", "Weapon", "Bow", "Wood", 0, 0, 0),
		["Fire"] = tcc_ItemTypeObj(		"Fire", "Woodworking", "", "", "Weapon", "Fire Staff", "Wood", 0, 0, 0),
		["Ice"] = tcc_ItemTypeObj(		"Ice", "Woodworking", "", "", "Weapon", "Ice Staff", "Wood", 0, 0, 0),
		["Lightning"] = tcc_ItemTypeObj("Lightning", "Woodworking", "", "", "Weapon", "Lightning Staff", "Wood", 0, 0, 0),
		["Resto"] = tcc_ItemTypeObj(	"Resto", "Woodworking", "", "", "Weapon", "Restoration Staff", "Wood", 0, 0, 0),
		["Shield"] = tcc_ItemTypeObj(	"Shield", "Woodworking", "", "", "Armor", "Shield", "Wood", 3, 2, 20),
		["Necklace"] = tcc_ItemTypeObj(	"Necklace", "Jewelry", "", "", "Jewelry", "Necklace", "Jewelry", 0, 0, 0),
		["Ring"] = tcc_ItemTypeObj(		"Ring", "Jewelry", "", "", "Jewelry", "Ring", "Jewelry", 0, 0, 0),
	}
	tcc.ItemTypes["Light"] = {
		["Chest"] = tcc.ItemTypes["Robe"],
		["Shirt"] = tcc.ItemTypes["Shirt"],
		["Feet"] = tcc.ItemTypes["Shoes"],
		["Hands"] = tcc.ItemTypes["Gloves"],
		["Head"] = tcc.ItemTypes["Hat"],
		["Legs"] = tcc.ItemTypes["Breeches"],
		["Shoulders"] = tcc.ItemTypes["Epaulets"],
		["Waist"] = tcc.ItemTypes["Sash"],
	}
	tcc.ItemTypes["Medium"] = {
		["Chest"] = tcc.ItemTypes["Jack"],
		["Feet"] = tcc.ItemTypes["Boots"],
		["Hands"] = tcc.ItemTypes["Bracers"],
		["Head"] = tcc.ItemTypes["Helmet"],
		["Legs"] = tcc.ItemTypes["Guards"],
		["Shoulders"] = tcc.ItemTypes["ArmCops"],
		["Waist"] = tcc.ItemTypes["Belt"],
	}
	tcc.ItemTypes["Heavy"] = {
		["Chest"] = tcc.ItemTypes["Cuirass"],
		["Feet"] = tcc.ItemTypes["Sabatons"],
		["Hands"] = tcc.ItemTypes["Gauntlets"],
		["Head"] = tcc.ItemTypes["Helm"],
		["Legs"] = tcc.ItemTypes["Greaves"],
		["Shoulders"] = tcc.ItemTypes["Pauldrons"],
		["Waist"] = tcc.ItemTypes["Girdle"],
	}

	-- tcc_IconObj(iconType, key, name, shortName, materialName, itemLink, normalTexture, [mouseOverTexture], [selectedTexture])
	tcc.ItemTraits = {
		["None"] = tcc_IconObj("Trait", "None", "None", nil, nil, nil, "/esoui/art/hud/radialicon_cancel_up.dds", "/esoui/art/hud/radialicon_cancel_over.dds", "/esoui/art/hud/radialicon_cancel_over.dds"),
		["Armor"] = {
			tcc_IconObj("Trait", "Sturdy", 		"Sturdy", 		nil, "Quartz", "|H1:item:4456:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_runecrafter_plug_component_002.dds"),
			tcc_IconObj("Trait", "Impenetrable", "Impenetrable", nil, "Diamond", "|H1:item:23219:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_jewelry_base_diamond_r3.dds"),
			tcc_IconObj("Trait", "Reinforced", 	"Reinforced", 	nil, "Sardonyx", "|H1:item:30221:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_enchantment_base_sardonyx_r2.dds"),
			tcc_IconObj("Trait", "WellFitted", 	"Well-Fitted", 	nil, "Almandine", "|H1:item:23221:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_accessory_sp_names_002.dds"),
			tcc_IconObj("Trait", "Training", 	"Training", 	nil, "Emerald", "|H1:item:4442:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_jewelry_base_emerald_r2.dds"),
			tcc_IconObj("Trait", "Infused", 	"Infused", 		nil, "Bloodstone", "|H1:item:30219:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_enchantment_baxe_bloodstone_r2.dds"),
			tcc_IconObj("Trait", "Invigorating", "Invigorating",nil, "Garnet", "|H1:item:23171:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_jewelry_base_garnet_r3.dds"),
			tcc_IconObj("Trait", "Divines", 	"Divines", 		nil, "Sapphire", "|H1:item:23173:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_accessory_sp_names_001.dds"),
			tcc_IconObj("Trait", "NirnhonedFortified", 	"Nirnhoned",  nil, "Fortified Nirncrux", "|H1:item:56862:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_potent_nirncrux_stone.dds"),
		},
		["Weapon"] = {
			tcc_IconObj("Trait", "Powered", 	"Powered", 	 nil, "Chysolite", "|H1:item:23203:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_runecrafter_potion_008.dds"),
			tcc_IconObj("Trait", "Charged", 	"Charged", 	 nil, "Amethyst", "|H1:item:23204:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_jewelry_base_amethyst_r3.dds"),
			tcc_IconObj("Trait", "Precise", 	"Precise", 	 nil, "Ruby", "|H1:item:4486:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_jewelry_base_ruby_r3.dds"),
			tcc_IconObj("Trait", "Infused", 	"Infused", 	 nil, "Jade", "|H1:item:810:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_enchantment_base_jade_r3.dds"),
			tcc_IconObj("Trait", "Defending", 	"Defending", nil, "Turquoise", "|H1:item:813:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_jewelry_base_turquoise_r3.dds"),
			tcc_IconObj("Trait", "Training", 	"Training",  nil, "Carnelian", "|H1:item:23165:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_runecrafter_armor_component_004.dds"),
			tcc_IconObj("Trait", "Sharpened", 	"Sharpened", nil, "Fire Opal", "|H1:item:23149:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_enchantment_base_fire_opal_r3.dds"),
			tcc_IconObj("Trait", "Decisive", 	"Decisive",  nil, "Citrine", "|H1:item:16291:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_smith_potion__sp_names_003.dds"),
			tcc_IconObj("Trait", "NirnhonedPotent", "Nirnhoned", nil, "Potent Nirncrux", "|H1:item:56863:30:46:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_potent_nirncrux_dust.dds"),
		},
		["Jewelry"] = {
			tcc_IconObj("Trait", "Arcane", 		"Arcane", 	 nil, "Cobalt", "|H1:item:135155:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/jewelrycrafting_trait_refined_cobalt.dds"),
			tcc_IconObj("Trait", "Healthy", 	"Healthy", 	 nil, "Antimony", "|H1:item:135156:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/jewelrycrafting_trait_refined_antimony.dds"),
			tcc_IconObj("Trait", "Robust", 		"Robust", 	 nil, "Zinc", "|H1:item:135157:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/jewelrycrafting_trait_refined_zinc.dds"),
			tcc_IconObj("Trait", "Triune", 		"Triune", 	 nil, "Dawn-Prism", "|H1:item:139409:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/jewelrycrafting_trait_refined_dawnprism.dds"),
			tcc_IconObj("Trait", "InfusedJewelry", 	"Infused", 	 nil, "Aurbic Amber", "|H1:item:139411:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_enchantment_base_jade_r1.dds"),
			tcc_IconObj("Trait", "Protective", 	"Protective",nil, "Titanium", "|H1:item:139410:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_runecrafter_armor_component_006.dds"),
			tcc_IconObj("Trait", "Swift", 		"Swift",	 nil, "Gilding Wax", "|H1:item:139412:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_outfitter_plug_component_002.dds"),
			tcc_IconObj("Trait", "Harmony", 	"Harmony", 	 nil, "Dibellium", "|H1:item:139413:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_metals_tin.dds"),
			tcc_IconObj("Trait", "Bloodthirsty", "Bloodthirsty", nil, "Slaughterstone", "|H1:item:139414:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_enchantment_baxe_bloodstone_r1.dds"),
		},
	}
	
	-- tcc_IconObj(iconType, key, name, shortName, materialName, itemLink, normalTexture, [mouseOverTexture], [selectedTexture])
	tcc.RacialStyles = {
		tcc_IconObj("Style", "Any", "Any", "Any", nil, nil, "/esoui/art/inventory/inventory_tabicon_all_up.dds", "/esoui/art/inventory/inventory_tabicon_all_over.dds", "/esoui/art/inventory/inventory_tabicon_all_down.dds"),
		tcc_IconObj("Style", "AbahsWatch",			"Abah's Watch",			"Abah's Watch",			"Polished Shilling", "|H1:item:76914:0:1:0:0:0:0:0:0:0:0:0:0:0:0:41:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_abahs_watch_r2.dds"),
		tcc_IconObj("Style", "Akaviri", 			"Akaviri", 				"Akaviri", 				"Goldscale", "|H1:item:64687:0:1:0:0:0:0:0:0:0:0:0:0:0:0:33:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_medium_armor_vendor_003.dds"),
		tcc_IconObj("Style", "AldmeriDominion",		"Aldmeri Dominion",		"Aldmeri",				"Eagle Feather", "|H1:item:71738:0:1:0:0:0:0:0:0:0:0:0:0:0:0:25:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_aldmeri_dominion.dds"),
		tcc_IconObj("Style", "Altmer", 				"Altmer (High Elf)",	"Altmer", 				"Adamantite", "|H1:item:33252:30:1:0:0:0:0:0:0:0:0:0:0:0:0:7:0:0:0:0:0|h|h", "/esoui/art/icons/grafting_gems_adamantine.dds"),
		tcc_IconObj("Style", "AncestralAkaviri",	"Ancestral Akaviri",	"Ancstr Akaviri",		"Burnished Goldscale", "|H1:item:167189:0:0:0:0:0:0:0:0:0:0:0:0:0:0:108:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_burnishedgoldscale.dds"),
		tcc_IconObj("Style", "AncestralBreton",		"Ancestral Breton",		"Ancestr Breton",		"Etched Molybdenum", "|H1:item:167206:0:0:0:0:0:0:0:0:0:0:0:0:0:0:109:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_ancestral_breton.dds"),
		tcc_IconObj("Style", "AncestralHighElf", 	"Ancestral High Elf", 	"Ances High Elf", 		"Etched Adamantite", "|H1:item:160609:1:1:0:0:0:0:0:0:0:0:0:0:0:0:104:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_antiquities_altmer.dds"),
		tcc_IconObj("Style", "AncestralNord", 		"Ancestral Nord", 		"Ancestral Nord", 		"Etched Corundum", "|H1:item:160592:1:1:0:0:0:0:0:0:0:0:0:0:0:0:103:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_antiquities_nord.dds"),
		tcc_IconObj("Style", "AncestralOrc", 		"Ancestral Orc", 		"Ancestral Orc", 		"Etched Manganese", "|H1:item:160626:1:1:0:0:0:0:0:0:0:0:0:0:0:0:105:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_antiquities_orc.dds"),
		tcc_IconObj("Style", "AncestralReach", 		"Ancestral Reach", 		"Ancestral Reach", 		"Etched Bronze", "|H1:item:167286:1:1:0:0:0:0:0:0:0:0:0:0:0:0:110:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_ancestral_reach.dds"),
		tcc_IconObj("Style", "AncientDaedric",		"Ancient Daedric",		"Ancient Daedric",		"Pristine Daedric Heart", "|H1:item:171874:0:0:0:0:0:0:0:0:0:0:0:0:0:0:119:0:0:0:0:0|h|h", "/esoui/art/icons/style_item_ancientdaedric.dds"),
		tcc_IconObj("Style", "AncientElf", 			"Ancient Elf", 			"Ancient Elf", 			"Palladium", "|H1:item:46152:30:1:0:0:0:0:0:0:0:0:0:0:0:0:15:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_ore_palladium.dds"),
		tcc_IconObj("Style", "AncientOrc", 			"Ancient Orc", 			"Ancient Orc", 			"Cassiterite", "|H1:item:69555:0:1:0:0:0:0:0:0:0:0:0:0:0:0:22:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_smith_plug_standard_f_001.dds"),
		tcc_IconObj("Style", "Anequina", 			"Anequina", 			"Anequina", 			"Shimmering Sand", "|H1:item:151621:0:0:0:0:0:0:0:0:0:0:0:0:0:0:84:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_shimmering_sand.dds"),
		tcc_IconObj("Style", "AnnihilarchsChosen",	"Annihilarch's Chosen",	"Annihilarch's",		"Blaze-Veined Prism", "|H1:item:178544:0:0:0:0:0:0:0:0:0:0:0:0:0:0:125:0:0:0:0:0|h|h", "/esoui/art/icons/styleitem_motif_annihlarch_chosen.dds"),
		tcc_IconObj("Style", "Apostle", 			"Apostle", 				"Apostle", 				"Tempered Brass", "|H1:item:132617:0:0:0:0:0:0:0:0:0:0:0:0:0:0:65:0:0:0:0:0|h|h", "/esoui/art/icons/justice_stolen_prop_sesnits_paperweight.dds"),
		tcc_IconObj("Style", "Argonian", 			"Argonian", 			"Argonian", 			"Flint", "|H1:item:33150:30:1:0:0:0:0:0:0:0:0:0:0:0:0:6:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_smith_potion_standard_f_002.dds"),
		tcc_IconObj("Style", "ArkthzandArmory", 	"Arkthzand Armory", 	"Arkthzand Armory", 	"Arkthzand Sprocket", "|H1:item:167976:1:1:0:0:0:0:0:0:0:0:0:0:0:0:112:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_arkthzand_armory.dds"),
		tcc_IconObj("Style", "AscendantOrder",		"Ascendant Order",		"Ascendant Ordr",		"Bone Pyre Ash", "|H1:item:181694:0:0:0:0:0:0:0:0:0:0:0:0:0:0:129:0:0:0:0:0|h|h", "/esoui/art/icons/style_item_ascendantorder.dds"),
		tcc_IconObj("Style", "Ashlander",			"Ashlander",			"Ashlander",			"Ash Canvas", "|H1:item:125476:0:1:0:0:0:0:0:0:0:0:0:0:0:0:54:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_ashlander_r2.dds"),
		tcc_IconObj("Style", "AssassinsLeague",		"Assassin's League",	"Assassin League",		"Tainted Blood", "|H1:item:76910:0:1:0:0:0:0:0:0:0:0:0:0:0:0:46:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_assassins_league_r2.dds"),
		tcc_IconObj("Style", "Barbaric", 			"Barbaric", 			"Barbaric", 			"Copper", "|H1:item:46149:30:1:0:0:0:0:0:0:0:0:0:0:0:0:17:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_smith_potion_standard_f_001.dds"),
		tcc_IconObj("Style", "BlackFinLegion",		"Black Fin Legion",		"Black Fin Legion",		"Marsh Nettle Sprig", "|H1:item:171894:0:0:0:0:0:0:0:0:0:0:0:0:0:0:120:0:0:0:0:0|h|h", "/esoui/art/icons/style_item_blackfin.dds"),
		tcc_IconObj("Style", "BlackreachVanguard", 	"Blackreach Vanguard", 	"Blackreach Vanguard", 	"Gloomspore Chitin", "|H0:item:160509:1:1:0:0:0:0:0:0:0:0:0:0:0:0:100:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_blackreach_vanguard.dds"),
		tcc_IconObj("Style", "BlessedInheritor",	"Blessed Inheritor",	"Blessd Inheritr",		"Necrom Incense", "|H1:item:190922:0:0:0:0:0:0:0:0:0:0:0:0:0:0:141:0:0:0:0:0|h|h", "/esoui/art/icons/u37_crafting_style_item_necromincense.dds"),
		tcc_IconObj("Style", "BlindPathCultist",	"Blind Path Cultist",	"Blind Path Cultst",	"Splinters of Mirrormoor", "|H1:item:203230:0:0:0:0:0:0:0:0:0:0:0:0:0:0:146:0:0:0:0:0|h|h", "/esoui/art/icons/u41_crafting_style_item_blindpathcultist.dds"),
		tcc_IconObj("Style", "Bloodforge", 			"Bloodforge", 			"Bloodforge", 			"Bloodroot Flux", "|H1:item:132620:0:0:0:0:0:0:0:0:0:0:0:0:0:0:61:0:0:0:0:0|h|h", "/esoui/art/icons/quest_dragonfire_dust.dds"),
		tcc_IconObj("Style", "Bosmer", 				"Bosmer (Wood Elf)",	"Bosmer", 				"Bone", "|H1:item:33194:30:1:0:0:0:0:0:0:0:0:0:0:0:0:8:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_gems_daedra_skull.dds"),
		tcc_IconObj("Style", "Breton", 				"Breton", 				"Breton", 				"Molybdenum", "|H1:item:33251:30:1:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_metals_molybdenum.dds"),
		tcc_IconObj("Style", "BuoyantArmiger",		"Buoyant Armiger",		"Armiger",				"Volcanic Veridian", "|H1:item:121518:0:1:0:0:0:0:0:0:0:0:0:0:0:0:52:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_buoyant_armiger_r2.dds"),
		tcc_IconObj("Style", "Celestial",			"Celestial",			"Celestial",			"Star Sapphire", "|H1:item:81998:0:1:0:0:0:0:0:0:0:0:0:0:0:0:27:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_celestial_r2.dds"),
		tcc_IconObj("Style", "ClanDreamcarver",		"Clan Dreamcarver",		"Clan Dreamcrvr",		"Terror Oil", "|H1:item:194508:0:0:0:0:0:0:0:0:0:0:0:0:0:0:142:0:0:0:0:0|h|h", "/esoui/art/icons/style_icon_terror_oil.dds"),
		tcc_IconObj("Style", "Coldsnap",			"Coldsnap",				"Coldsnap",				"Goblin-Cloth Scrap", "|H1:item:151907:0:1:0:0:0:0:0:0:0:0:0:0:0:0:82:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_goblin-cloth_scrap.dds"),
		tcc_IconObj("Style", "CrimsonOath",			"Crimson Oath",			"Crimson Oath",			"Filed Barbs", "|H1:item:176073:0:0:0:0:0:0:0:0:0:0:0:0:0:0:123:0:0:0:0:0|h|h", "/esoui/art/icons/style_item_blackiron.dds"),
		tcc_IconObj("Style", "Daedric", 			"Daedric", 				"Daedric", 				"Daedra Heart", "|H1:item:46151:30:1:0:0:0:0:0:0:0:0:0:0:0:0:20:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_walking_dead_mort_heart.dds"),
		tcc_IconObj("Style", "DaggerfallCovenant",	"Daggerfall Covenant",	"Daggerfall",			"Lion Fang", "|H1:item:71742:0:1:0:0:0:0:0:0:0:0:0:0:0:0:23:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_daggerfall_covenant.dds"),
		tcc_IconObj("Style", "DarkBrotherhood",		"Dark Brotherhood",		"Dark Brotherhd",		"Black Beeswax", "|H1:item:79304:0:1:0:0:0:0:0:0:0:0:0:0:0:0:12:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_dark_brotherhood_r2.dds"),
		tcc_IconObj("Style", "DeadKeeper",			"Dead Keeper",			"Dead Keeper",			"Funerary Wrappings", "|H1:item:194529:0:0:0:0:0:0:0:0:0:0:0:0:0:0:143:0:0:0:0:0|h|h", "/esoui/art/icons/style_icon_funerary_wrappings.dds"),
		tcc_IconObj("Style", "DeadWater",			"Dead-Water",			"Dead-Water",			"Crocodile Leather", "|H1:item:145532:30:1:0:0:0:0:0:0:0:0:0:0:0:0:79:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_deadwater_r1.dds"),
		tcc_IconObj("Style", "Dragonguard",			"Dragonguard",			"Dragonguard",			"Gilding Salts", "|H1:item:156571:30:1:0:0:0:0:0:0:0:0:0:0:0:0:92:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_humanoid_daedra_fire_salts.dds"),
		tcc_IconObj("Style", "Draugr",				"Draugr",				"Draugr",				"Pristine Shroud", "|H1:item:75373:0:1:0:0:0:0:0:0:0:0:0:0:0:0:31:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_draugr_r2.dds"),
		tcc_IconObj("Style", "Dreadhorn",			"Dreadhorn",			"Dreadhorn",			"Minotaur Bezoar", "|H1:item:132619:0:0:0:0:0:0:0:0:0:0:0:0:0:0:62:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_dreadhorn_r2.dds"),
		tcc_IconObj("Style", "Dreadsails",			"Dreadsails",			"Dreadsails",			"Squid Ink", "|H1:item:181677:0:0:0:0:0:0:0:0:0:0:0:0:0:0:128:0:0:0:0:0|h|h", "/esoui/art/icons/style_item_dreadsail.dds"),
		tcc_IconObj("Style", "Dremora",				"Dremora",				"Dremora",				"Warrior's Heart Ashes", "|H1:item:137957:30:1:0:0:0:0:0:0:0:0:0:0:0:0:74:0:0:0:0:0|h|h", "/esoui/art/icons/item_warriorsheartashes.dds"),
		tcc_IconObj("Style", "DromAthra",			"Dro-m'Athra",			"Dro-m'Athra",			"Defiled Whiskers", "|H1:item:79672:0:1:0:0:0:0:0:0:0:0:0:0:0:0:45:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_dromothra_r2.dds"),
		tcc_IconObj("Style", "DrownedMariner",		"Drowned Mariner",		"Drownd Marinr",		"Preserving Saltwater", "|H1:item:187778:0:0:0:0:0:0:0:0:0:0:0:0:0:0:136:0:0:0:0:0|h|h", "/esoui/art/icons/u36_crafting_style_item_drowned_mariner.dds"),
		tcc_IconObj("Style", "Dunmer", 				"Dunmer (Dark Elf)",	"Dunmer", 				"Obsidian", "|H1:item:33253:30:1:0:0:0:0:0:0:0:0:0:0:0:0:4:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_metals_graphite.dds"),
		tcc_IconObj("Style", "Dwemer", 				"Dwemer", 				"Dwemer", 				"Dwemer Frame", "|H1:item:57587:30:1:0:0:0:0:0:0:0:0:0:0:0:0:14:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_dwemer_shiny_tube.dds"),
		tcc_IconObj("Style", "EbonheartPact",		"Ebonheart Pact",		"Ebonheart",			"Dragon Scute", "|H1:item:71740:0:1:0:0:0:0:0:0:0:0:0:0:0:0:24:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_ebonheart_pact.dds"),
		tcc_IconObj("Style", "Ebonshadow",			"Ebonshadow",			"Ebonshadow",			"Tenebrous Cord", "|H1:item:132618:0:0:0:0:0:0:0:0:0:0:0:0:0:0:66:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_ebonshadow_r2.dds"),
		tcc_IconObj("Style", "Ebony",				"Ebony",				"Ebony",				"Night Pumice", "|H1:item:82004:0:1:0:0:0:0:0:0:0:0:0:0:0:0:40:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_ebony_r2.dds"),
		tcc_IconObj("Style", "ElderArgonian",		"Elder Argonian",		"Elder Argonian",		"Hackwing Plumage", "|H1:item:145533:30:1:0:0:0:0:0:0:0:0:0:0:0:0:81:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_elderargonian_r2.dds"),
		tcc_IconObj("Style", "FangLair", 			"Fang Lair",			"Fang Lair",			"Dragon Bone", "|H1:item:137958:30:1:0:0:0:0:0:0:0:0:0:0:0:0:69:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_ore_base_dragonbone_r2.dds"),
		tcc_IconObj("Style", "FargraveGuardian",	"Fargrave Guardian",	"Fargrave Guard",		"Indigo Lucent", "|H1:item:178722:0:0:0:0:0:0:0:0:0:0:0:0:0:0:126:0:0:0:0:0|h|h", "/esoui/art/icons/styleitem_motif_fargrave_gaurdian.dds"),
		tcc_IconObj("Style", "Firesong",			"Firesong",				"Firesong",				"Firesong Skarn", "|H1:item:188323:0:0:0:0:0:0:0:0:0:0:0:0:0:0:138:0:0:0:0:0|h|h", "/esoui/art/icons/u37_crafting_style_item_firesongskarn.dds"),
		tcc_IconObj("Style", "Frostcaster", 		"Frostcaster",			"Frostcaster",			"Stahlrim Shard", "|H1:item:114283:30:1:0:0:0:0:0:0:0:0:0:0:0:0:53:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_stalhrim_r2.dds"),
		tcc_IconObj("Style", "Glass", 				"Glass", 				"Glass", 				"Malachite", "|H1:item:64689:6:1:0:0:0:0:0:0:0:0:0:0:0:0:28:0:1:0:0:0|h|h", "/esoui/art/icons/crafting_ore_base_malachite_r2.dds"),
		tcc_IconObj("Style", "Greymoor", 			"Greymoor", 			"Greymoor", 			"Bat Oil", "|H1:item:160558:1:1:0:0:0:0:0:0:0:0:0:0:0:0:101:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_batoil.dds"),
		tcc_IconObj("Style", "GrimHarlequin",		"Grim Harlequin",		"Grim Harlequin",		"Grinstones", "|H1:item:82002:30:1:0:0:0:0:0:0:0:0:0:0:0:0:58:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_grim_harlequin_r2.dds"),
		tcc_IconObj("Style", "HazardousAlchemy", 	"Hazardous Alchemy", 	"Haz Alchemy", 			"Viridian Phial", "|H1:item:167005:1:1:0:0:0:0:0:0:0:0:0:0:0:0:107:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_hazardous_academy.dds"),
		tcc_IconObj("Style", "Hlaalu",				"Hlaalu",				"Hlaalu",				"Refined Bonemold Resin", "|H1:item:130059:0:0:0:0:0:0:0:0:0:0:0:0:0:0:49:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_hlaalu_r2.dds"),
		tcc_IconObj("Style", "Hollowjack",			"Hollowjack",			"Hollowjack",			"Amber Marble", "|H1:item:82000:0:1:0:0:0:0:0:0:0:0:0:0:0:0:59:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_hollowjack_r2.dds"),
		tcc_IconObj("Style", "HonorGuard",			"Honor Guard",			"Honor Guard",			"Red Diamond Seal", "|H1:item:147288:2:1:0:0:0:0:0:0:0:0:0:0:0:0:80:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_honorguard.dds"),
		tcc_IconObj("Style", "HouseHexos",			"House Hexos",			"House Hexos",			"Etched Nickel", "|H1:item:170147:0:0:0:0:0:0:0:0:0:0:0:0:0:0:114:0:0:0:0:0|h|h", "/esoui/art/icons/style_item_ancientimperial.dds"),
		tcc_IconObj("Style", "HouseMornard",		"House Mornard",		"House Mornard",		"Vibrant Tumeric", "|H1:item:188340:0:0:0:0:0:0:0:0:0:0:0:0:0:0:139:0:0:0:0:0|h|h", "/esoui/art/icons/u37_crafting_style_item_vibranttumeric.dds"),
		tcc_IconObj("Style", "Huntsman",			"Huntsman",				"Huntsman",				"Bloodscent Dew", "|H1:item:141820:30:1:0:0:0:0:0:0:0:0:0:0:0:0:77:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_moonhunter_r2.dds"),
		tcc_IconObj("Style", "IcereachCoven", 		"Icereach Coven", 		"Icereach Coven", 		"Fryse Willow", "|H1:item:157533:1:1:0:0:0:0:0:0:0:0:0:0:0:0:97:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_icereach_coven.dds"),
		tcc_IconObj("Style", "Imperial", 			"Imperial", 			"Imperial", 			"Nickel", "|H1:item:33254:30:1:0:0:0:0:0:0:0:0:0:0:0:0:34:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_heavy_armor_sp_names_001.dds"),
		tcc_IconObj("Style", "IvoryBrigade",		"Ivory Brigade",		"Ivory Brigade",		"Ivory Brigade Clasp", "|H1:item:171911:0:0:0:0:0:0:0:0:0:0:0:0:0:0:121:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_ivory_brigade.dds"),
		tcc_IconObj("Style", "Khajiit", 			"Khajiit", 				"Khajiit", 				"Moonstone", "|H1:item:33255:30:1:0:0:0:0:0:0:0:0:0:0:0:0:9:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_smith_plug_sp_names_001.dds"),
		tcc_IconObj("Style", "KindredsConcord",		"Kindred's Concord",	"Kindrd's Concrd",		"Festering Dreamcloth", "|H1:item:194556:0:0:0:0:0:0:0:0:0:0:0:0:0:0:144:0:0:0:0:0|h|h", "/esoui/art/icons/style_icon_festering_dreamcloth.dds"),
		tcc_IconObj("Style", "Malacath",			"Malacath",				"Malacath",				"Potash", "|H1:item:71584:0:1:0:0:0:0:0:0:0:0:0:0:0:0:13:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_malacath.dds"),
		tcc_IconObj("Style", "Mazzatun",			"Mazzatun",				"Mazzatun",				"Leviathan Scrimshaw", "|H1:item:114984:0:1:0:0:0:0:0:0:0:0:0:0:0:0:57:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_mazzatun_r2.dds"),
		tcc_IconObj("Style", "Mercenary", 			"Mercenary", 			"Mercenary", 			"Laurel", "|H1:item:64713:0:1:0:0:0:0:0:0:0:0:0:0:0:0:26:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_laurel.dds"),
		tcc_IconObj("Style", "Meridian", 			"Meridian", 			"Meridian", 			"Auroran Dust", "|H1:item:151908:0:1:0:0:0:0:0:0:0:0:0:0:0:0:83:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_auroran_dust.dds"),
		tcc_IconObj("Style", "MilitantOrdinator",	"Militant Ordinator",	"Ordinator",			"Lustrous Sphalerite", "|H1:item:121520:0:1:0:0:0:0:0:0:0:0:0:0:0:0:50:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_militant_ordinator_r2.dds"),
		tcc_IconObj("Style", "Minotaur",			"Minotaur",				"Minotaur",				"Oxblood Fungus", "|H1:item:81994:0:1:0:0:0:0:0:0:0:0:0:0:0:0:39:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_minotaur_r2.dds"),
		tcc_IconObj("Style", "MoongraveFane",		"Moongrave Fane",		"Moongrave Fane",		"Blood of Sahrotnax", "|H1:item:156606:0:0:0:0:0:0:0:0:0:0:0:0:0:0:93:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_critter_vertebrate_cold_blood.dds"),
		tcc_IconObj("Style", "MoragTong",			"Morag Tong",			"Morag Tong",			"Boiled Carapace", "|H1:item:79305:0:1:0:0:0:0:0:0:0:0:0:0:0:0:43:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_morag_tong_r2.dds"),
		tcc_IconObj("Style", "NewMoonPriest",		"New Moon Priest",		"New Moon Prst",		"Aeonstone Shard", "|H1:item:156624:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/item_u25_aeonstoneshard.dds"),
		tcc_IconObj("Style", "Nighthollow", 		"Nighthollow",			"Nighthollow", 			"Umbral Droplet", "|H0:item:167959:1:1:0:0:0:0:0:0:0:0:0:0:0:0:111:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_nighthollow.dds"),
		tcc_IconObj("Style", "Nord", 				"Nord", 				"Nord", 				"Corundum", "|H1:item:33256:30:1:0:0:0:0:0:0:0:0:0:0:0:0:5:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_metals_corundum.dds"),
		tcc_IconObj("Style", "Orc", 				"Orc", 					"Orc", 					"Manganese", "|H1:item:33257:30:1:0:0:0:0:0:0:0:0:0:0:0:0:3:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_metals_manganese.dds"),
		tcc_IconObj("Style", "OrderOfTheHour",		"Order of the Hour",	"Order Hour",			"Pearl Sand", "|H1:item:81996:0:1:0:0:0:0:0:0:0:0:0:0:0:0:16:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_orderoth_r2.dds"),
		tcc_IconObj("Style", "Outlaw",				"Outlaw",				"Outlaw",				"Rogue's Soot", "|H1:item:71538:0:1:0:0:0:0:0:0:0:0:0:0:0:0:47:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_outlaw_styleitem.dds"),
		tcc_IconObj("Style", "Pellitine",			"Pellitine",			"Pellitine",			"Dragonthread", "|H1:item:151622:0:1:0:0:0:0:0:0:0:0:0:0:0:0:85:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_dragonthread.dds"),
		tcc_IconObj("Style", "Primal", 				"Primal", 				"Primal", 				"Argentum", "|H1:item:46150:30:1:0:0:0:0:0:0:0:0:0:0:0:0:19:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_metals_argentum.dds"),
		tcc_IconObj("Style", "PsijicOrder",			"Psijic Order",			"Psijic Order",			"Vitrified Malondo", "|H1:item:137951:30:1:0:0:0:0:0:0:0:0:0:0:0:0:71:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_leather_nitre.dds"),
		tcc_IconObj("Style", "Pyandonean",			"Pyandonean",			"Pyandonean",			"Sea Serpent Hide", "|H1:item:140267:30:1:0:0:0:0:0:0:0:0:0:0:0:0:75:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_leather_base_horkerskin_r2.dds"),
		tcc_IconObj("Style", "PyreWatch", 			"Pyre Watch", 			"Pyre Watch", 			"Consecrated Myrrh", "|H1:item:158307:30:1:0:0:0:0:0:0:0:0:0:0:0:0:98:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_pyre_watch.dds"),
		tcc_IconObj("Style", "RaGada",				"Ra Gada",				"Ra Gada",				"Ancient Sandstone", "|H1:item:71736:0:1:0:0:0:0:0:0:0:0:0:0:0:0:44:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_ragada_r2.dds"),
		tcc_IconObj("Style", "Recollection",		"Recollection",			"Recollection",			"Wildburn Withers", "|H1:item:203198:0:0:0:0:0:0:0:0:0:0:0:0:0:0:145:0:0:0:0:0|h|h", "/esoui/art/icons/u41_crafting_style_item_remembrance.dds"),
		tcc_IconObj("Style", "Redguard", 			"Redguard", 			"Redguard", 			"Starmetal", "|H1:item:33258:30:1:0:0:0:0:0:0:0:0:0:0:0:0:2:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_medium_armor_sp_names_002.dds"),
		tcc_IconObj("Style", "Redoran", 			"Redoran", 				"Redoran", 				"Polished Scarab Elytra", "|H1:item:130060:0:0:0:0:0:0:0:0:0:0:0:0:0:0:48:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_redoran_r2.dds"),
		tcc_IconObj("Style", "Refabricated",		"Refabricated", 		"Refabricated", 		"Polished Rivets", "|H1:item:130061:30:1:0:0:0:0:0:0:0:0:0:0:0:0:60:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_fabricant_r2.dds"),
		tcc_IconObj("Style", "Sapiarch",			"Sapiarch",				"Sapiarch",				"Culanda Lacquer", "|H1:item:137953:30:1:0:0:0:0:0:0:0:0:0:0:0:0:72:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_leather_phlegm.dds"),
		tcc_IconObj("Style", "Scalecaller",			"Scalecaller",			"Scalecaller",			"Infected Flesh", "|H1:item:137961:30:1:0:0:0:0:0:0:0:0:0:0:0:0:70:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_outfitter_potion_002.dds"),
		tcc_IconObj("Style", "ScribesOfMora",		"Scribes of Mora",		"Scribes of Mora",		"Glass Eye of Mora", "|H1:item:190905:0:0:0:0:0:0:0:0:0:0:0:0:0:0:140:0:0:0:0:0|h|h", "/esoui/art/icons/u37_crafting_style_item_glasseyeofmora.dds"),
		tcc_IconObj("Style", "SeaGiant", 			"Sea Giant", 			"Sea Giant", 			"Sea Snake Fang", "|H1:item:160575:1:1:0:0:0:0:0:0:0:0:0:0:0:0:102:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_seaserpentfang.dds"),
		tcc_IconObj("Style", "Shardborn",			"Shardborn",			"Shardborn",			"Obliviate Lacquer", "|H1:item:203376:0:0:0:0:0:0:0:0:0:0:0:0:0:0:147:0:0:0:0:0|h|h", "/esoui/art/icons/u42_crafting_style_item_shardknight.dds"),
		tcc_IconObj("Style", "ShieldOfSenchal",		"Shield of Senchal",	"Shield Senchal", 		"Carmine Shieldsilk", "|H1:item:156643:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/item_u25_carmineshieldsilk.dds"),
		tcc_IconObj("Style", "SilkenRing",			"Silken Ring",			"Silken Ring",			"Distilled Slowsilver", "|H1:item:114983:0:1:0:0:0:0:0:0:0:0:0:0:0:0:56:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_mirrorsheen_r2.dds"),
		tcc_IconObj("Style", "SilverDawn",			"Silver Dawn",			"Silver Dawn",			"Argent Pelt", "|H1:item:141821:30:1:0:0:0:0:0:0:0:0:0:0:0:0:78:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_silverdawn_r2.dds"),
		tcc_IconObj("Style", "SilverRose",			"Silver Rose",			"Silver Rose",			"Rose Engraving", "|H1:item:178520:0:0:0:0:0:0:0:0:0:0:0:0:0:0:124:0:0:0:0:0|h|h", "/esoui/art/icons/style_item_silverrose.dds"),
		tcc_IconObj("Style", "Skinchanger",			"Skinchanger",			"Skinchanger",			"Wolfsbane Incense", "|H1:item:96388:0:1:0:0:0:0:0:0:0:0:0:0:0:0:42:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_wolfsbane_r2.dds"),
		tcc_IconObj("Style", "SoulShriven",			"Soul Shriven",			"Soul Shriven",			"Azure Plasm", "|H1:item:71766:0:1:0:0:0:0:0:0:0:0:0:0:0:0:30:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_runecrafter_plug_component_005.dds"),
		tcc_IconObj("Style", "SteadfastSociety",	"Steadfast Society",	"Steadfst Socty",		"Stendarr Stamp", "|H1:item:182553:0:0:0:0:0:0:0:0:0:0:0:0:0:0:131:0:0:0:0:0|h|h", "/esoui/art/icons/u34_crafting_style_item_steadfast_society.dds"),
		tcc_IconObj("Style", "SulXan",				"Sul-Xan",				"Sul-Xan",				"Death Hopper Vocal Sac", "|H1:item:171928:0:0:0:0:0:0:0:0:0:0:0:0:0:0:122:0:0:0:0:0|h|h", "/esoui/art/icons/style_item_sul-xan.dds"),
		tcc_IconObj("Style", "Sunspire",			"Sunspire",				"Sunspire",				"Frost Embers", "|H1:item:152235:30:1:0:0:0:0:0:0:0:0:0:0:0:0:86:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_celestial_r1.dds"),
		tcc_IconObj("Style", "SyrabanicMarine",		"Syrabanic Marine",		"Syrabanic Mrn",		"Scalloped Frog-Metal", "|H1:item:182536:0:0:0:0:0:0:0:0:0:0:0:0:0:0:130:0:0:0:0:0|h|h", "/esoui/art/icons/u34_crafting_style_item_sybranic_marine.dds"),
		tcc_IconObj("Style", "SystresGuardian",		"Systres Guardian",		"Systres Guardn",		"High Isle Filigree", "|H1:item:182570:0:0:0:0:0:0:0:0:0:0:0:0:0:0:132:0:0:0:0:0|h|h", "/esoui/art/icons/u34_crafting_style_item_sytres_guard.dds"),
		tcc_IconObj("Style", "Telvanni", 			"Telvanni", 			"Telvanni", 			"Wrought Ferrofungus", "|H1:item:121519:0:0:0:0:0:0:0:0:0:0:0:0:0:0:51:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_telvanni_r2.dds"),
		tcc_IconObj("Style", "ThievesGuild",		"Thieves Guild",		"Thieves Guild",		"Fine Chalk", "|H1:item:75370:0:1:0:0:0:0:0:0:0:0:0:0:0:0:11:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_thieves_guild_r2.dds"),
		tcc_IconObj("Style", "ThornLegion", 		"Thorn Legion", 		"Thorn Legion", 		"Thorn Sigil", "|H1:item:166988:1:1:0:0:0:0:0:0:0:0:0:0:0:0:106:0:0:0:0:0|h|h", "/esoui/art/icons/item_u27_greyhost_sigil.dds"),
		tcc_IconObj("Style", "Trinimac",			"Trinimac",				"Trinimac",				"Auric Tusk", "|H1:item:71582:0:1:0:0:0:0:0:0:0:0:0:0:0:0:21:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_trinimac.dds"),
		tcc_IconObj("Style", "TrueSworn",			"True-Sworn",			"True-Sworn",			"Fulgid Epidote", "|H1:item:171567:0:0:0:0:0:0:0:0:0:0:0:0:0:0:116:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_fulgid_epidote.dds"),
		tcc_IconObj("Style", "Tsaesci", 			"Tsaesci", 				"Tsaesci", 				"Snake Fang", "|H1:item:134687:1:1:0:0:0:0:0:0:0:0:0:0:0:0:38:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_lizard_fangs.dds"),
		tcc_IconObj("Style", "WakingFlame",			"Waking Flame",			"Waking Flame",			"Chokeberry Extract", "|H1:item:171596:0:0:0:0:0:0:0:0:0:0:0:0:0:0:117:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_chokeberry_extract.dds"),
		tcc_IconObj("Style", "WaywardGuardian", 	"Wayward Guardian", 	"Wayward Guard",		"Hawk Skull", "|H1:item:167993:1:1:0:0:0:0:0:0:0:0:0:0:0:0:113:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_wayward_guardian.dds"),
		tcc_IconObj("Style", "Welkynar",			"Welkynar",				"Welkynar",				"Gryphon Plume", "|H1:item:141740:30:1:0:0:0:0:0:0:0:0:0:0:0:0:73:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_welkynar_r2.dds"),
		tcc_IconObj("Style", "WormCult",			"Worm Cult",			"Worm Cult",			"Desecrated Grave Soil", "|H1:item:134798:0:0:0:0:0:0:0:0:0:0:0:0:0:0:55:0:0:0:0:0|h|h", "/esoui/art/icons/quest_monster_ash_001.dds"),
		tcc_IconObj("Style", "Xivkyn", 				"Xivkyn", 				"Xivkyn", 				"Charcoal of Remorse", "|H1:item:59922:30:1:0:0:0:0:0:0:0:0:0:0:0:0:29:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_smith_potion_008.dds"),
		tcc_IconObj("Style", "YffresWill",			"Y'ffre's Will",		"Y'ffre's Will",		"Engraved Leaves", "|H1:item:187744:0:0:0:0:0:0:0:0:0:0:0:0:0:0:135:0:0:0:0:0|h|h", "/esoui/art/icons/u36_crafting_style_item_yffres_will.dds"),
		tcc_IconObj("Style", "Yokudan",				"Yokudan",				"Yokudan",				"Ferrous Salts", "|H1:item:64685:0:1:0:0:0:0:0:0:0:0:0:0:0:0:35:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_humanoid_daedra_void_salts.dds"),
	}
	
	-- tcc_MaterialSubComponentObj(componentMaterialKey, componentMaterialName, componentMaterialQuantity, componentMaterialLink, componentMaterialTexture)
	tcc.MaterialSubComponents = {
		["Dwemer"] = tcc_MaterialSubComponentObj("Dwemer", "Dwemer Scrap", 10, "|H1:item:57665:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_metals_dwarven_scrap.dds"),
		["AncientOrc"] = tcc_MaterialSubComponentObj("AncientOrc", "Cassiterite Sand", 10, "|H1:item:69556:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_ghost_inert_glow_dust.dds"),
		["Glass"] = tcc_MaterialSubComponentObj("Glass", "Malachite Shard", 10, "|H1:item:64690:33:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_ore_base_malachite_r1.dds"),
		["Akaviri"] = tcc_MaterialSubComponentObj("Akaviri", "Ancient Scale", 10, "|H1:item:64688:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_medium_armor_vendor_001.dds"),
		["ThievesGuild"] = tcc_MaterialSubComponentObj("ThievesGuild", "Coarse Chalk", 10, "|H1:item:75371:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_thieves_guild_r1.dds"),
		["OrderOfTheHour"] = tcc_MaterialSubComponentObj("OrderOfTheHour", "Grain of Pearl Sand", 10, "|H1:item:81997:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_orderoth_r1.dds"),
		["Minotaur"] = tcc_MaterialSubComponentObj("Minotaur", "Oxblood Fungus Spore", 10, "|H1:item:81995:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_minotaur_r1.dds"),
		["AssassinsLeague"] = tcc_MaterialSubComponentObj("AssassinsLeague", "Dried Blood", 10, "|H1:item:76911:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_style_item_assassins_league_r1.dds"),
		["Pewter"] = tcc_MaterialSubComponentObj("Pewter", "Pewter Dust", 10, "|H1:item:135137:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_pewter_dust.dds"),
		["Copper"] = tcc_MaterialSubComponentObj("Copper", "Copper Dust", 10, "|H1:item:135139:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_copper_dust.dds"),
		["Silver"] = tcc_MaterialSubComponentObj("Silver", "Silver Dust", 10, "|H1:item:135141:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_silver_dust.dds"),
		["Electrum"] = tcc_MaterialSubComponentObj("Electrum", "Electrum Dust", 10, "|H1:item:135143:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_electrum_dust.dds"),
		["Platinum"] = tcc_MaterialSubComponentObj("Platinum", "Platinum Dust", 10, "|H1:item:135145:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_platinum_dust.dds"),
		["Arcane"] = tcc_MaterialSubComponentObj("Arcane", "Pulverized Cobalt", 10, "|H1:item:135158:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/jewelrycrafting_trait_raw_cobalt.dds"),
		["Healthy"] = tcc_MaterialSubComponentObj("Healthy", "Pulverized Antimony", 10, "|H1:item:135159:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/jewelrycrafting_trait_raw_antimony.dds"),
		["Robust"] = tcc_MaterialSubComponentObj("Robust", "Pulverized Zinc", 10, "|H1:item:135160:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/jewelrycrafting_trait_raw_zinc.dds"),
		["InfusedJewelry"] = tcc_MaterialSubComponentObj("InfusedJewelry", "Pulverized Aurbic Amber", 10, "|H1:item:139417:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_flower_wormwood_r3.dds"),
		["Protective"] = tcc_MaterialSubComponentObj("Protective", "Pulverized Titanium", 10, "|H1:item:139416:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_runecrafter_armor_component_005.dds"),
		["Harmony"] = tcc_MaterialSubComponentObj("Harmony", "Pulverized Dibellium", 10, "|H1:item:139419:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_smith_potion_014.dds"),
	}

	-- Syntax: tcc_ItemSetObj(longname, shortname)
	-- Grab set names, then sort, then add to tcc.ItemSets.
	local SET_COL_LIMIT = 20
	tcc.ItemSets = { tcc_ItemSetObj("None", "None") }
	local craftedSetNames = { }
	for i, craftedSet in pairs(LibSets.craftedSets) do
		table.insert(craftedSetNames, craftedSet.setNames[LibSets.clientLang])
	end
	table.sort(craftedSetNames)
	for i, craftedSetName in pairs(craftedSetNames) do
		table.insert(tcc.ItemSets, 
			tcc_ItemSetObj(craftedSetName, string.sub(craftedSetName, 0, SET_COL_LIMIT))
		)
	end
end

-- Separate function so we can call it again, in case the user ranked up in quality improvement passive.
function tcc_InitQualityMats()
	--tcc_GetCurrentAbilityRank(skillType, skillIndex, abilityIndex)
	local smithImprovementMatQtyIndex = 1 + tcc_GetCurrentAbilityRank(SKILL_TYPE_TRADESKILL, TCC_SKILL_INDEX_BLACKSMITHING, 6)
	local clothImprovementMatQtyIndex = 1 + tcc_GetCurrentAbilityRank(SKILL_TYPE_TRADESKILL, TCC_SKILL_INDEX_CLOTHING, 6)
	local woodImprovementMatQtyIndex = 1 + tcc_GetCurrentAbilityRank(SKILL_TYPE_TRADESKILL, TCC_SKILL_INDEX_WOODWORKING, 6)
	local jewelryImprovementMatQtyIndex = 1 + tcc_GetCurrentAbilityRank(SKILL_TYPE_TRADESKILL, TCC_SKILL_INDEX_JEWELRY, 5)
	
	-- tcc_MaterialObj(materialKey, materialName, craftName, materialQuantity, materialLink, materialTexture)
	tcc.QualityMats = {
		["Blacksmithing"] = {
			["Green"] = tcc_MaterialObj(	"Honing Stone", 	"Honing Stone", 	"Blacksmithing", tcc.ItemQuality.Green.UpgradeMatQtyPerImprovementPassiveRank[smithImprovementMatQtyIndex], "|H1:item:54170:31:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_ores_lazurite.dds"),
			["Blue"] = tcc_MaterialObj(		"Dwarven Oil", 		"Dwarven Oil", 		"Blacksmithing", tcc.ItemQuality.Blue.UpgradeMatQtyPerImprovementPassiveRank[smithImprovementMatQtyIndex], "|H1:item:54171:32:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_forester_weapon_vendor_component_002.dds"),
			["Purple"] = tcc_MaterialObj(	"Grain Solvent", 	"Grain Solvent", 	"Blacksmithing", tcc.ItemQuality.Purple.UpgradeMatQtyPerImprovementPassiveRank[smithImprovementMatQtyIndex], "|H1:item:54172:33:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_forester_potion_vendor_001.dds"),
			["Gold"] = tcc_MaterialObj(		"Tempering Alloy", 	"Tempering Alloy", 	"Blacksmithing", tcc.ItemQuality.Gold.UpgradeMatQtyPerImprovementPassiveRank[smithImprovementMatQtyIndex], "|H1:item:54173:34:11:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_tempering_alloy.dds"),
		},                                  
		["Clothing"] = {                    
			["Green"] = tcc_MaterialObj(	"Hemming", 			"Hemming", 			"Clothing", tcc.ItemQuality.Green.UpgradeMatQtyPerImprovementPassiveRank[clothImprovementMatQtyIndex], "|H1:item:54174:31:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_light_armor_vendor_001.dds"),
			["Blue"] = tcc_MaterialObj(		"Embroidery", 		"Embroidery", 		"Clothing", tcc.ItemQuality.Blue.UpgradeMatQtyPerImprovementPassiveRank[clothImprovementMatQtyIndex], "|H1:item:54175:32:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_light_armor_vendor_component_002.dds"),
			["Purple"] = tcc_MaterialObj(	"Elegant Lining", 	"Elegant Lining", 	"Clothing", tcc.ItemQuality.Purple.UpgradeMatQtyPerImprovementPassiveRank[clothImprovementMatQtyIndex], "|H1:item:54176:33:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_runecrafter_potion_sp_name_001.dds"),
			["Gold"] = tcc_MaterialObj(		"Dreugh Wax", 		"Dreugh Wax", 		"Clothing", tcc.ItemQuality.Gold.UpgradeMatQtyPerImprovementPassiveRank[clothImprovementMatQtyIndex], "|H1:item:54177:34:14:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_outfitter_potion_014.dds"),
		},                                  
		["Leatherworking"] = {              
			["Green"] = tcc_MaterialObj(	"Hemming", 			"Hemming", 			"Clothing", tcc.ItemQuality.Green.UpgradeMatQtyPerImprovementPassiveRank[clothImprovementMatQtyIndex], "|H1:item:54174:31:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_light_armor_vendor_001.dds"),
			["Blue"] = tcc_MaterialObj(		"Embroidery", 		"Embroidery", 		"Clothing", tcc.ItemQuality.Blue.UpgradeMatQtyPerImprovementPassiveRank[clothImprovementMatQtyIndex], "|H1:item:54175:32:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_light_armor_vendor_component_002.dds"),
			["Purple"] = tcc_MaterialObj(	"Elegant Lining", 	"Elegant Lining", 	"Clothing", tcc.ItemQuality.Purple.UpgradeMatQtyPerImprovementPassiveRank[clothImprovementMatQtyIndex], "|H1:item:54176:33:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_runecrafter_potion_sp_name_001.dds"),
			["Gold"] = tcc_MaterialObj(		"Dreugh Wax", 		"Dreugh Wax", 		"Clothing", tcc.ItemQuality.Gold.UpgradeMatQtyPerImprovementPassiveRank[clothImprovementMatQtyIndex], "|H1:item:54177:34:14:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_outfitter_potion_014.dds"),
		},                                  
		["Woodworking"] = {                 
			["Green"] = tcc_MaterialObj(	"Pitch", 			"Pitch", 			"Woodworking", tcc.ItemQuality.Green.UpgradeMatQtyPerImprovementPassiveRank[woodImprovementMatQtyIndex], "|H1:item:54178:31:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_forester_weapon_vendor_component_002.dds"),
			["Blue"] = tcc_MaterialObj(		"Turpen", 			"Turpen", 			"Woodworking", tcc.ItemQuality.Blue.UpgradeMatQtyPerImprovementPassiveRank[woodImprovementMatQtyIndex], "|H1:item:54179:32:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_wood_turpen.dds"),
			["Purple"] = tcc_MaterialObj(	"Mastic", 			"Mastic", 			"Woodworking", tcc.ItemQuality.Purple.UpgradeMatQtyPerImprovementPassiveRank[woodImprovementMatQtyIndex], "|H1:item:54180:33:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_wood_mastic.dds"),
			["Gold"] = tcc_MaterialObj(		"Rosin", 			"Rosin", 			"Woodworking", tcc.ItemQuality.Gold.UpgradeMatQtyPerImprovementPassiveRank[woodImprovementMatQtyIndex], "|H1:item:54181:34:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_wood_rosin.dds"),
		},                                  
		["Enchanting"] = {                  
			["White"] = tcc_MaterialObj(	"Ta", 				"Ta", 				"Enchanting", 1, "|H1:item:45850:20:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_003.dds"),
			["Green"] = tcc_MaterialObj(	"Jejota", 			"Jejota", 			"Enchanting", 1, "|H1:item:45851:21:14:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_005.dds"),
			["Blue"] = tcc_MaterialObj(		"Denata", 			"Denata", 			"Enchanting", 1, "|H1:item:45852:22:14:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_004.dds"),
			["Purple"] = tcc_MaterialObj(	"Rekuta", 			"Rekuta", 			"Enchanting", 1, "|H1:item:45853:23:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_002.dds"),
			["Gold"] = tcc_MaterialObj(		"Kuta", 			"Kuta", 			"Enchanting", 1, "|H1:item:45854:24:6:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/crafting_components_runestones_001.dds"),
		},
		["Jewelry"] = {                 
			["Green"] = tcc_MaterialObj(	"Terne Plating",	"Terne Plating", 	"Jewelry", tcc.ItemQuality.Green.UpgradeMatQtyPerImprovementPassiveRank[jewelryImprovementMatQtyIndex], "|H1:item:203631:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/jewelrycrafting_booster_refined_terne.dds"),
			["Blue"] = tcc_MaterialObj(		"Iridium Plating", 	"Iridium Plating", 	"Jewelry", tcc.ItemQuality.Blue.UpgradeMatQtyPerImprovementPassiveRank[jewelryImprovementMatQtyIndex], "|H1:item:203632:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/jewelrycrafting_booster_refined_iridium.dds"),
			["Purple"] = tcc_MaterialObj(	"Zircon Plating", 	"Zircon Plating", 	"Jewelry", tcc.ItemQuality.Purple.UpgradeMatQtyPerImprovementPassiveRank[jewelryImprovementMatQtyIndex], "|H1:item:203633:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/jewelrycrafting_booster_refined_zircon.dds"),
			["Gold"] = tcc_MaterialObj(		"Chromium Plating", "Chromium Plating", "Jewelry", tcc.ItemQuality.Gold.UpgradeMatQtyPerImprovementPassiveRank[jewelryImprovementMatQtyIndex], "|H1:item:203634:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "/esoui/art/icons/jewelrycrafting_booster_refined_chromium.dds"),
		},
	}
end


--[[ Object Functions ]]--

function tcc_ItemMaterialObj(skillTier, minimumLevel, materialNameCloth, materialNameLeather, materialNameMetal, materialNameWood, materialLinkCloth, materialLinkLeather, materialLinkMetal, materialLinkWood, materialTextureCloth, materialTextureLeather, materialTextureMetal, materialTextureWood)
	return {
		["SkillTier"] = skillTier,
		["MinimumLevel"] = minimumLevel,
		["MaterialNameCloth"] = materialNameCloth,
		["MaterialNameLeather"] = materialNameLeather,
		["MaterialNameMetal"] = materialNameMetal,
		["MaterialNameWood"] = materialNameWood,
		["MaterialLinkCloth"] = materialLinkCloth,
		["MaterialLinkLeather"] = materialLinkLeather,
		["MaterialLinkMetal"] = materialLinkMetal,
		["MaterialLinkWood"] = materialLinkWood,
		["MaterialTextureCloth"] = materialTextureCloth,
		["MaterialTextureLeather"] = materialTextureLeather,
		["MaterialTextureMetal"] = materialTextureMetal,
		["MaterialTextureWood"] = materialTextureWood,
	}
end

function tcc_JewelryItemMaterialObj(skillTier, minimumLevel, materialNameJewelry, materialLinkJewelry, materialTextureJewelry)
	return {
		["SkillTier"] = skillTier,
		["MinimumLevel"] = minimumLevel,
		["MaterialNameJewelry"] = materialNameJewelry,
		["MaterialLinkJewelry"] = materialLinkJewelry,
		["MaterialTextureJewelry"] = materialTextureJewelry,
	}
end

function tcc_ItemLevelObj(itemLevel, skillTier, skillTierJewelry, qtyModifierType, baseQtyCloth, baseQtyLeather, baseQtyMetal, baseQtyWood, baseQtyRing, baseQtyNecklace)
	return {
		["ItemLevel"] = itemLevel,
		["SkillTier"] = skillTier,
		["SkillTierJewelry"] = skillTierJewelry,
		["QtyModifierType"] = qtyModifierType,
		["BaseQtyCloth"] = baseQtyCloth,
		["BaseQtyLeather"] = baseQtyLeather,
		["BaseQtyMetal"] = baseQtyMetal,
		["BaseQtyWood"] = baseQtyWood,
		["BaseQtyRing"] = baseQtyRing,
		["BaseQtyNecklace"] = baseQtyNecklace,
	}
end

function tcc_ItemTypeObj(key, craftName, itemCategory, bodyPart, traitType, itemName, materialCategory, qtyModifier, qtyModifierCP150, qtyModifierCP160)
	return {
		["Key"] = key,
		["CraftName"] = craftName,
		["ItemCategory"] = itemCategory,
		["BodyPart"] = bodyPart,
		["TraitType"] = traitType,
		["ItemName"] = itemName,
		["MaterialCategory"] = materialCategory,
		["QtyModifier"] = qtyModifier,
		["QtyModifierCP150"] = qtyModifierCP150,
		["QtyModifierCP160"] = qtyModifierCP160,
	}
end

-- upgradeMatQtyPerImprovementPassiveRank is an array.
function tcc_ItemQualityExtraProperties(qualityIconObj, index, colorCode, upgradeMatQtyPerImprovementPassiveRank)
	qualityIconObj.Index = index
	qualityIconObj.ColorCode = colorCode
	qualityIconObj.UpgradeMatQtyPerImprovementPassiveRank = upgradeMatQtyPerImprovementPassiveRank
	return qualityIconObj
end

function tcc_IconObj(iconType, key, name, shortName, materialName, itemLink, normalTexture, mouseOverTexture, selectedTexture)
	return {
		IconType = iconType,
		Key = key, 
		Name = name,
		ShortName = shortName,
		MaterialName = materialName,
		ItemLink = itemLink,
		NormalTexture = normalTexture,
		MouseOverTexture = mouseOverTexture,
		SelectedTexture = selectedTexture,
	}
end

function tcc_MaterialObj(materialKey, materialName, craftName, materialQuantity, materialLink, materialTexture)
	return {
		MaterialKey = materialKey,
		MaterialName = materialName, 
		CraftName = craftName, 
		MaterialQuantity = materialQuantity, 
		MaterialTotalQuantity = materialQuantity, 
		MaterialLink = materialLink, 
		MaterialTexture = materialTexture,
	}
end

function tcc_MaterialSubComponentObj(componentMaterialKey, componentMaterialName, componentMaterialQuantity, componentMaterialLink, componentMaterialTexture)
	return {
		ComponentMaterialKey = componentMaterialKey, 
		ComponentMaterialName = componentMaterialName,
		ComponentMaterialQuantity = componentMaterialQuantity, 
		ComponentMaterialLink = componentMaterialLink, 
		ComponentMaterialTexture = componentMaterialTexture,
	}
end

function tcc_ItemSetObj(longName, shortName)
	return {
		LongName = longName,
		ShortName = shortName,
	}
end