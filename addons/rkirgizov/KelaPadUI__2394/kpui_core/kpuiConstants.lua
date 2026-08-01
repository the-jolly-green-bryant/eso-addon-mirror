kpuiConst = {
	Name = "KelaPadUI",
	Version = "0.0.0.1",
}
kpuiConst.test = "test"	






kpuiConst.ItemFlags = { 
	ITEM_FLAG_TRAIT_RESEARCHABLE = 1, 
	ITEM_FLAG_TRAIT_DUPLICATED = 2, 
	ITEM_FLAG_TRAIT_KNOWN = 3, 
	ITEM_FLAG_TRAIT_RESEARCHING = 4, 
	ITEM_FLAG_TRAIT_INTRICATE = 5, 
	ITEM_FLAG_TRAIT_ORNATE = 6, 
	ITEM_FLAG_TCC_QUEST = 100, 
	ITEM_FLAG_TCC_USABLE = 101, 
	ITEM_FLAG_TCC_USELESS = 102, 
	ITEM_FLAG_NONE = -1,
}

kpuiConst.SmithingTypes = { 
	CRAFTING_TYPE_BLACKSMITHING, 
	CRAFTING_TYPE_CLOTHIER, 
	CRAFTING_TYPE_WOODWORKING, 
	CRAFTING_TYPE_JEWELRYCRAFTING,
}	

kpuiConst.stringDDS = {
	["horizontalDivider"] = "EsoUI/Art/Windows/Gamepad/gp_nav1_horDividerFlat.dds",
	["rightShoulderXBOne"] = "EsoUI/Art/Buttons/Gamepad/Xbox/Nav_XBone_RB.dds",
	["leftShoulderXBOne"] = "EsoUI/Art/Buttons/Gamepad/Xbox/Nav_XBone_LB.dds",
}



-- extra item groups
WEAPONTYPE_BLACKSMITHING = 501				
WEAPONTYPE_BOW = 502
WEAPONTYPE_STAFF = 503
JEWELRYTYPE_RING_NECK = 504		

kpuiConst.Bags = {
	["ALL_CRAFTING_INVENTORY_BAGS_AND_WORN"] = {
		BAG_BACKPACK,
		BAG_BANK,
		BAG_SUBSCRIBER_BANK,
		BAG_WORN,
	},
	["ALL_CRAFTING_INVENTORY_BAGS_WITHOUT_WORN"] = {
		BAG_BACKPACK, 
		BAG_BANK, 
		BAG_SUBSCRIBER_BANK,
	},
	["BAGS_ICONS"] = {
		[BAG_BACKPACK] = "|cFFFFFF|t32:32:EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_inventory.dds:inheritColor|t",
		[BAG_BANK] = "|cFFFFFF|t32:32:esoui/art/icons/servicemappins/servicepin_bank.dds:inheritColor|t",
		[BAG_SUBSCRIBER_BANK] = "|cFFFFFF|t32:32:esoui/art/icons/servicemappins/servicepin_bank.dds:inheritColor|t",
		[BAG_WORN] = "|cDC8122|t32:32:EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_character.dds:inheritColor|t",
		["LOCKED"] = "|cDC8122|t32:32:EsoUI/Art/Miscellaneous/Gamepad/gp_icon_locked32.dds:inheritColor|t",
	},	
	["BAGS_ICONS_24"] = {
		[BAG_BACKPACK] = "|cFFFFFF|t24:24:EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_inventory.dds:inheritColor|t",
		[BAG_BANK] = "|cFFFFFF|t24:24:esoui/art/icons/servicemappins/servicepin_bank.dds:inheritColor|t",
		[BAG_SUBSCRIBER_BANK] = "|cFFFFFF|t24:24:esoui/art/icons/servicemappins/servicepin_bank.dds:inheritColor|t",
		[BAG_WORN] = "|cDC8122|t24:24:EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_character.dds:inheritColor|t",
		["LOCKED"] = "|cDC8122|t24:24:EsoUI/Art/Miscellaneous/Gamepad/gp_icon_locked32.dds:inheritColor|t",
	},	
	["BAGS_STRINGS"] = {
		[BAG_BACKPACK] = GetString(KELA_ITEM_IN_BACKPACK),
		[BAG_BANK] = GetString(KELA_ITEM_IN_BANK),
		[BAG_SUBSCRIBER_BANK] = GetString(KELA_ITEM_IN_BANK),
		[BAG_WORN] = GetString(KELA_ITEM_WORN),
		["LOCKED"] = GetString(KELA_ITEM_LOCKED),
	},	
}

kpuiConst.Colors = {
	COLOR_ORANGE = ZO_ColorDef:New(220/255, 129/255, 34/255),
	COLOR_GOLD = ZO_ColorDef:New(254/255, 234/255, 2/255),			
	COLOR_RED = ZO_ColorDef:New(255/255, 25/255, 25/255),
	COLOR_WHITE = ZO_ColorDef:New(255/255, 255/255, 255/255),
	COLOR_BROWN = ZO_ColorDef:New(197/255, 194/255, 158/255),
	COLOR_GREEN = ZO_ColorDef:New(0/255, 136/255, 103/255),
	COLOR_BLUE = ZO_ColorDef:New(0/255, 80/255, 159/255),
	COLOR_GREY = ZO_ColorDef:New(162/255, 162/255, 162/255),
	COLOR_POISON = ZO_ColorDef:New(162/255, 192/255, 78/255),
	COLOR_SOON = ZO_ColorDef:New(16/255, 154/255, 184/255),
	COLOR_NOTSOON = ZO_ColorDef:New(238/255, 202/255, 42/255),
	COLOR_NEARLY = ZO_ColorDef:New(82/255, 167/255, 49/255),
	COLOR_QUEST = ZO_ColorDef:New(220/255, 216/255, 34/255),
	GENERAL_COLOR_WHITE = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1, 
	GENERAL_COLOR_GREY = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_2, 
	GENERAL_COLOR_OFF_WHITE = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_3, 
	GENERAL_COLOR_RED = GAMEPAD_TOOLTIP_COLOR_FAILED,
}

	 -- tooltips size
KELA_TOOLTIPS_WIDE_WIDTH = 900 --849
KELA_TOOLTIPS_WIDE_CONTENT_WIDTH = KELA_TOOLTIPS_WIDE_WIDTH - 2 * 40
KELA_TOOLTIPS_WIDE_CONTENT_WIDTH_PERCENT = 100
KELA_TOOLTIPS_WIDTH = 470 --650
KELA_TOOLTIPS_CONTENT_WIDTH = KELA_TOOLTIPS_WIDTH - 2 * 40
KELA_TOOLTIPS_CONTENT_WIDTH_PERCENT = 100
KELA_TOOLTIPS_FONT_BIG = 27
KELA_TOOLTIPS_FONT_MEDIUM = 22
KELA_TOOLTIPS_FONT_SMALL = 18

	
	-- Redefined
SI_ITEM_FORMAT_STR_SET_NAME = "<<1>> (<<2>>/<<3>>)" --"<<1>> set (<<2>>/<<3>> items)"


kpuiConst.UnknowableTraitTypes = {
	[ITEM_TRAIT_TYPE_NONE] = "none",
	[ITEM_TRAIT_TYPE_WEAPON_INTRICATE] = "weapon",
	[ITEM_TRAIT_TYPE_WEAPON_ORNATE] = "weapon",
	[ITEM_TRAIT_TYPE_ARMOR_INTRICATE] = "armor",
	[ITEM_TRAIT_TYPE_ARMOR_ORNATE] = "armor",
	[ITEM_TRAIT_TYPE_JEWELRY_ORNATE] = "jewelry",
	[ITEM_TRAIT_TYPE_JEWELRY_INTRICATE] = "jewelry",
}
kpuiConst.ItemLinkForTraitType = {
	[ITEM_TRAIT_TYPE_ARMOR_DIVINES] = "|H0:item:23173:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS] = "|H0:item:23171:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE] = "|H0:item:23219:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEM_TRAIT_TYPE_ARMOR_INFUSED] = "|H0:item:30219:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEM_TRAIT_TYPE_ARMOR_REINFORCED] = "|H0:item:30221:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEM_TRAIT_TYPE_ARMOR_STURDY] = "|H0:item:4456:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEM_TRAIT_TYPE_ARMOR_TRAINING] = "|H0:item:4442:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED] = "|H0:item:23221:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEM_TRAIT_TYPE_ARMOR_NIRNHONED] = "|H0:item:56862:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEM_TRAIT_TYPE_WEAPON_CHARGED] = "|H0:item:23204:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEM_TRAIT_TYPE_WEAPON_DEFENDING] = "|H0:item:813:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEM_TRAIT_TYPE_WEAPON_INFUSED] = "|H0:item:810:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEM_TRAIT_TYPE_WEAPON_POWERED] = "|H0:item:23203:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEM_TRAIT_TYPE_WEAPON_PRECISE] = "|H0:item:4486:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEM_TRAIT_TYPE_WEAPON_SHARPENED] = "|H0:item:23149:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEM_TRAIT_TYPE_WEAPON_TRAINING] = "|H0:item:23165:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEM_TRAIT_TYPE_WEAPON_DECISIVE] = "|H0:item:16291:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEM_TRAIT_TYPE_WEAPON_NIRNHONED] = "|H0:item:56863:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEM_TRAIT_TYPE_JEWELRY_ARCANE] = "|H0:item:135155:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY] = "|H0:item:139414:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEM_TRAIT_TYPE_JEWELRY_HARMONY] = "|H0:item:139413:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEM_TRAIT_TYPE_JEWELRY_HEALTHY] = "|H0:item:135156:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEM_TRAIT_TYPE_JEWELRY_INFUSED] = "|H0:item:139411:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE] = "|H0:item:139410:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEM_TRAIT_TYPE_JEWELRY_ROBUST] = "|H0:item:135157:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEM_TRAIT_TYPE_JEWELRY_SWIFT] = "|H0:item:139412:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEM_TRAIT_TYPE_JEWELRY_TRIUNE] = "|H0:item:139409:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEM_TRAIT_TYPE_NONE] = "ITEM_TRAIT_TYPE_NONE",
}


kpuiConst.TradeskillForItemType = {
	[ITEMTYPE_ARMOR] = {
		CRAFTING_TYPE_BLACKSMITHING,
		CRAFTING_TYPE_CLOTHIER,
		CRAFTING_TYPE_WOODWORKING,
		CRAFTING_TYPE_JEWELRYCRAFTING
	},
	[ITEMTYPE_WEAPON] = {
		CRAFTING_TYPE_BLACKSMITHING,
		CRAFTING_TYPE_WOODWORKING,
	},
}


kpuiConst.TradeskillForArmorType = {
	[ARMORTYPE_LIGHT] = CRAFTING_TYPE_CLOTHIER,
	[ARMORTYPE_MEDIUM] = CRAFTING_TYPE_CLOTHIER,
	[ARMORTYPE_HEAVY] = CRAFTING_TYPE_BLACKSMITHING,
	[ARMORTYPE_NONE] = CRAFTING_TYPE_JEWELRYCRAFTING,
}	

kpuiConst.ItemTypeToCraftType = {
	[WEAPONTYPE_AXE] = WEAPONTYPE_BLACKSMITHING,
	[WEAPONTYPE_HAMMER] = WEAPONTYPE_BLACKSMITHING,
	[WEAPONTYPE_SWORD] = WEAPONTYPE_BLACKSMITHING,
	[WEAPONTYPE_TWO_HANDED_SWORD] = WEAPONTYPE_BLACKSMITHING,
	[WEAPONTYPE_TWO_HANDED_AXE] = WEAPONTYPE_BLACKSMITHING,
	[WEAPONTYPE_TWO_HANDED_HAMMER] = WEAPONTYPE_BLACKSMITHING,
	[WEAPONTYPE_DAGGER] = WEAPONTYPE_BLACKSMITHING,
	[WEAPONTYPE_BOW] = WEAPONTYPE_BOW,
	[WEAPONTYPE_HEALING_STAFF] = WEAPONTYPE_STAFF,
	[WEAPONTYPE_FIRE_STAFF] = WEAPONTYPE_STAFF,
	[WEAPONTYPE_FROST_STAFF] = WEAPONTYPE_STAFF,
	[WEAPONTYPE_SHIELD] = WEAPONTYPE_SHIELD,
	[WEAPONTYPE_LIGHTNING_STAFF] = WEAPONTYPE_STAFF,
	[WEAPONTYPE_RUNE] = ITEM_TYPE_INVALID,
	[WEAPONTYPE_PROP] = ITEM_TYPE_INVALID,
}

kpuiConst.TradeskillForWeaponType = {
	[WEAPONTYPE_AXE] = CRAFTING_TYPE_BLACKSMITHING,
	[WEAPONTYPE_HAMMER] = CRAFTING_TYPE_BLACKSMITHING,
	[WEAPONTYPE_SWORD] = CRAFTING_TYPE_BLACKSMITHING,
	[WEAPONTYPE_TWO_HANDED_SWORD] = CRAFTING_TYPE_BLACKSMITHING,
	[WEAPONTYPE_TWO_HANDED_AXE] = CRAFTING_TYPE_BLACKSMITHING,
	[WEAPONTYPE_TWO_HANDED_HAMMER] = CRAFTING_TYPE_BLACKSMITHING,
	[WEAPONTYPE_PROP] = CRAFTING_TYPE_INVALID, --what's that?
	[WEAPONTYPE_BOW] = CRAFTING_TYPE_WOODWORKING,
	[WEAPONTYPE_HEALING_STAFF] = CRAFTING_TYPE_WOODWORKING,
	[WEAPONTYPE_RUNE] = CRAFTING_TYPE_INVALID,
	[WEAPONTYPE_DAGGER] = CRAFTING_TYPE_BLACKSMITHING,
	[WEAPONTYPE_FIRE_STAFF] = CRAFTING_TYPE_WOODWORKING,
	[WEAPONTYPE_FROST_STAFF] = CRAFTING_TYPE_WOODWORKING,
	[WEAPONTYPE_SHIELD] = CRAFTING_TYPE_WOODWORKING,
	[WEAPONTYPE_LIGHTNING_STAFF] = CRAFTING_TYPE_WOODWORKING,
}

kpuiConst.ArmorTypeAndEquipTypeToResearchLineIndex = {
	[ARMORTYPE_NONE] = {
		[EQUIP_TYPE_NECK] = 1,
		[EQUIP_TYPE_RING] = 2,
	},
	[ARMORTYPE_HEAVY] = {
		[EQUIP_TYPE_HEAD] = 11,
		[EQUIP_TYPE_CHEST] = 8,
		[EQUIP_TYPE_SHOULDERS] = 13,
		[EQUIP_TYPE_WAIST] = 14,
		[EQUIP_TYPE_LEGS] = 12,
		[EQUIP_TYPE_FEET] = 9,
		[EQUIP_TYPE_HAND] = 10,
	},
	[ARMORTYPE_LIGHT] = {
		[EQUIP_TYPE_HEAD] = 4,
		[EQUIP_TYPE_CHEST] = 1,
		[EQUIP_TYPE_SHOULDERS] = 6,
		[EQUIP_TYPE_WAIST] = 7,
		[EQUIP_TYPE_LEGS] = 5,
		[EQUIP_TYPE_FEET] = 2,
		[EQUIP_TYPE_HAND] = 3,
	},
	[ARMORTYPE_MEDIUM] = {
		[EQUIP_TYPE_HEAD] = 11,
		[EQUIP_TYPE_CHEST] = 8,
		[EQUIP_TYPE_SHOULDERS] = 13,
		[EQUIP_TYPE_WAIST] = 14,
		[EQUIP_TYPE_LEGS] = 12,
		[EQUIP_TYPE_FEET] = 9,
		[EQUIP_TYPE_HAND] = 10,
	},
}

kpuiConst.WeaponTypeToResearchLineIndex = {
		[WEAPONTYPE_AXE] = 1,
		[WEAPONTYPE_BOW] = 1,
		[WEAPONTYPE_DAGGER] = 7,
		[WEAPONTYPE_FIRE_STAFF] = 2,
		[WEAPONTYPE_FROST_STAFF] = 3,
		[WEAPONTYPE_HAMMER] = 2,
		[WEAPONTYPE_HEALING_STAFF] = 5,
		[WEAPONTYPE_LIGHTNING_STAFF] = 4,
		[WEAPONTYPE_PROP] = 0,
		[WEAPONTYPE_RUNE] = 0,
		[WEAPONTYPE_SHIELD] = 6,
		[WEAPONTYPE_SWORD] = 3,
		[WEAPONTYPE_TWO_HANDED_AXE] = 4,
		[WEAPONTYPE_TWO_HANDED_HAMMER] = 5,
		[WEAPONTYPE_TWO_HANDED_SWORD] = 6,
}

kpuiConst.SmithingTypeResearchLineTraitTypeToItemCraftType = {

	[CRAFTING_TYPE_BLACKSMITHING] = {
		-- metal weapon research lines
		[1] = WEAPONTYPE_BLACKSMITHING,
		[2] = WEAPONTYPE_BLACKSMITHING,
		[3] = WEAPONTYPE_BLACKSMITHING,
		[4] = WEAPONTYPE_BLACKSMITHING,
		[5] = WEAPONTYPE_BLACKSMITHING,
		[6] = WEAPONTYPE_BLACKSMITHING,
		[7] = WEAPONTYPE_BLACKSMITHING,
		-- heavy armor research lines
		[8] = ARMORTYPE_HEAVY,
		[9] = ARMORTYPE_HEAVY,
		[10] = ARMORTYPE_HEAVY,
		[11] = ARMORTYPE_HEAVY,
		[12] = ARMORTYPE_HEAVY,
		[13] = ARMORTYPE_HEAVY,
		[14] = ARMORTYPE_HEAVY,
	},
	[CRAFTING_TYPE_CLOTHIER] = {
		-- light armor research lines
		[1] = ARMORTYPE_LIGHT,
		[2] = ARMORTYPE_LIGHT,
		[3] = ARMORTYPE_LIGHT,
		[4] = ARMORTYPE_LIGHT,
		[5] = ARMORTYPE_LIGHT,
		[6] = ARMORTYPE_LIGHT,
		[7] = ARMORTYPE_LIGHT,
		-- medium armor research lines
		[8] = ARMORTYPE_MEDIUM,
		[9] = ARMORTYPE_MEDIUM,
		[10] = ARMORTYPE_MEDIUM,
		[11] = ARMORTYPE_MEDIUM,
		[12] = ARMORTYPE_MEDIUM,
		[13] = ARMORTYPE_MEDIUM,
		[14] = ARMORTYPE_MEDIUM,
	},
	[CRAFTING_TYPE_WOODWORKING] = {
		-- bow research lines
		[1] = WEAPONTYPE_BOW,
		-- staff research lines
		[2] = WEAPONTYPE_STAFF,
		[3] = WEAPONTYPE_STAFF,
		[4] = WEAPONTYPE_STAFF,
		[5] = WEAPONTYPE_STAFF,
		-- shield research lines
		[6] = WEAPONTYPE_SHIELD,
	},
	[CRAFTING_TYPE_JEWELRYCRAFTING] = {
		-- neck research lines
		[1] = JEWELRYTYPE_RING_NECK,
		-- ring research lines
		[2] = JEWELRYTYPE_RING_NECK,
	},
}



-------------------------- СЕТЫ -----------------------------------------------------

-- ID локаций
ID_GLENUMBRA = 3
ID_STORMHAVEN = 19
ID_RIVENSPIRE = 20
ID_STONEFALLS = 41
ID_DESHAAN = 57
ID_MALABALTOR = 58
ID_BANGKORAI = 92
ID_EASTMARCH = 101
ID_THERIFT = 103
ID_ALIKRDESERT = 104
ID_GREENSHADE = 108
ID_SHADOWFEN = 117
ID_CYRODIIL = 181
ID_EYEVEA = 267
ID_BLEAKROCKISLE = 280
ID_BALFOYEN = 281
ID_COLDHARBOUR = 347
ID_AURIDON = 381
ID_REAPERSMARCH = 382
ID_GRAHTWOOD = 383
ID_STROSMKAI = 534
ID_BETNIKH = 535
ID_KHENARTHISROOST = 537
ID_IMPERIALCITY = 584
ID_EARTHFORGE = 642
ID_WROTHGAR = 684
ID_MURKMIRE = 726
ID_HEWSBANE = 816
ID_GOLDCOAST = 823
ID_VVARDENFELL = 849
ID_CRAGLORN = 888
ID_CLOCKWORK = 980
ID_BRASSFORT = 981
ID_SUMMERSET = 1011
ID_ARTAEUM = 1027
ID_ELSWEYR_NORTH = 1086
ID_LOCATION_NONE = 0

-- Билды сетов
KPUI_SET_BUILD_TANK = 1
KPUI_SET_BUILD_DDS = 2
KPUI_SET_BUILD_DDS_STAMINA = 3
KPUI_SET_BUILD_DDS_MAGICKA = 4
KPUI_SET_BUILD_HEALER = 5
KPUI_SET_BUILD_PVP = 6
KPUI_SET_BUILD_PVE = 7
KPUI_SET_BUILD_WEREWOLF = 8
KPUI_SET_BUILD_VAMPIRE = 9
KPUI_SET_BUILD_NONE = 0

-- Билды сетов
KPUI_SET_ITEMS_ARMOR_LIGHT = 1
KPUI_SET_ITEMS_ARMOR_MEDIUM = 2
KPUI_SET_ITEMS_ARMOR_HEAVY = 3
KPUI_SET_ITEMS_WEAPONS = 4
KPUI_SET_ITEMS_JEWELRY = 5


-- рекомендуемые роли взяты с http://wiki.tesonline.org/Ремесленные_комплекты
-- https://altarofgaming.com/all-eso-sets-health-magicka-stamina/
-- https://eso-sets.com
kpuiConst.SetsCrafting = {
    [176] 	= {itemId=59946, traits=5, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_PVP}, locations={[1]={zoneId=ID_IMPERIALCITY}}},     	--Noble's Conquest
    [82]    = {itemId=44019, traits=5, build={[1]=KPUI_SET_BUILD_TANK}, locations={[1]={zoneId=ID_EASTMARCH},[2]={zoneId=ID_ALIKRDESERT},[3]={zoneId=ID_MALABALTOR}}},     	--Alessia's Bulwark
    [54]    = {itemId=43871, traits=2, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_DDS_STAMINA}, locations={[1]={zoneId=ID_STONEFALLS},[2]={zoneId=ID_GLENUMBRA},[3]={zoneId=ID_AURIDON}}},     	--Ashen Grip
    [323]   = {itemId=121551, traits=3, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_DDS_MAGICKA}, locations={[1]={zoneId=ID_VVARDENFELL}}},     	--Assassin's Guile
    [87]    = {itemId=44049, traits=8, build={[1]=KPUI_SET_BUILD_HEALER}, locations={[1]={zoneId=ID_EYEVEA}}},     	--Eyes of Mara
    [51]    = {itemId=43859, traits=6, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_PVE}, locations={[1]={zoneId=ID_THERIFT},[2]={zoneId=ID_BANGKORAI},[3]={zoneId=ID_REAPERSMARCH}}},    	--Night Mother's Gaze
    [324]   = {itemId=121901, traits=8, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_PVP}, locations={[1]={zoneId=ID_VVARDENFELL}}},     	--Daedric Trickery
    [161]   = {itemId=58153, traits=9, build={[1]=KPUI_SET_BUILD_NONE}, locations={[1]={zoneId=ID_CRAGLORN}}},     	--Twice-Born Star
    [73]    = {itemId=43965, traits=8, build={[1]=KPUI_SET_BUILD_NONE}, locations={[1]={zoneId=ID_COLDHARBOUR}}},     	--Oblivion's Foe
    [226]   = {itemId=72491, traits=9, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_PVP}, locations={[1]={zoneId=ID_HEWSBANE}}},     	--Eternal Hunt
    [208]   = {itemId=69927, traits=3, build={[1]=KPUI_SET_BUILD_TANK}, locations={[1]={zoneId=ID_WROTHGAR}}},   	  	--Trial by Fire
    [207]   = {itemId=69577, traits=6, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA, [2]=KPUI_SET_BUILD_PVE, [3]=KPUI_SET_BUILD_PVP}, locations={[1]={zoneId=ID_WROTHGAR}}},     	--LAw of Julianos
    [240]   = {itemId=75386, traits=5, build={[1]=KPUI_SET_BUILD_DDS_STAMINA}, locations={[1]={zoneId=ID_GOLDCOAST}}},     	--Kvatch Gladiator
    [408]   = {itemId=142791, traits=7, build={[1]=KPUI_SET_BUILD_TANK}, locations={[1]={zoneId=ID_MURKMIRE}}},     	--Grave-Stake Collector
    [78]    = {itemId=43995, traits=4, build={[1]=KPUI_SET_BUILD_TANK}, locations={[1]={zoneId=ID_SHADOWFEN},[2]={zoneId=ID_RIVENSPIRE},[3]={zoneId=ID_GREENSHADE}}},     	--Hist Bark
    [80]    = {itemId=44007, traits=6, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_PVE}, locations={[1]={zoneId=ID_THERIFT},[2]={zoneId=ID_BANGKORAI},[3]={zoneId=ID_REAPERSMARCH}}},     	--Hunding's Rage
    [92]    = {itemId=44079, traits=8, build={[1]=KPUI_SET_BUILD_HEALER, [2]=KPUI_SET_BUILD_PVE, [3]=KPUI_SET_BUILD_PVP}, locations={[1]={zoneId=ID_EARTHFORGE}}},     	--Kagrenac's Hope
    [351]   = {itemId=130370, traits=2, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_DDS_MAGICKA}, locations={[1]={zoneId=ID_CLOCKWORK}}},     	--Innate Axiom
    [325]   = {itemId=122251, traits=6, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_DDS_MAGICKA, [3]=KPUI_SET_BUILD_PVP}, locations={[1]={zoneId=ID_VVARDENFELL}}},     	--Shacklebreaker
    [386]   = {itemId=136067, traits=6, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA, [2]=KPUI_SET_BUILD_PVP}, locations={[1]={zoneId=ID_ARTAEUM}}},     	--Sload's Semblance
    [44]    = {itemId=43831, traits=5, build={[1]=KPUI_SET_BUILD_TANK}, locations={[1]={zoneId=ID_EASTMARCH},[2]={zoneId=ID_ALIKRDESERT},[3]={zoneId=ID_MALABALTOR}}},     	--Vampire's Kiss
    [81]    = {itemId=44013, traits=5, build={[1]=KPUI_SET_BUILD_TANK}, locations={[1]={zoneId=ID_EASTMARCH},[2]={zoneId=ID_ALIKRDESERT},[3]={zoneId=ID_MALABALTOR}}},     	--Song of Lamae
    [410]   = {itemId=143531, traits=4, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_DDS_MAGICKA}, locations={[1]={zoneId=ID_MURKMIRE}}},     	--Might of the Lost Legion
    [48]    = {itemId=43847, traits=4, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA, [2]=KPUI_SET_BUILD_PVE}, locations={[1]={zoneId=ID_SHADOWFEN},[2]={zoneId=ID_RIVENSPIRE},[3]={zoneId=ID_GREENSHADE}}},     	--Magnu's Gift
    [353]   = {itemId=131070, traits=6, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_DDS_MAGICKA}, locations={[1]={zoneId=ID_CLOCKWORK}}},     	--Mechanical Acuity
    [352]   = {itemId=130720, traits=4, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_PVE}, locations={[1]={zoneId=ID_BRASSFORT}}},     	--Fortified Brass
    [219]   = {itemId=70627, traits=9, build={[1]=KPUI_SET_BUILD_DDS_STAMINA}, locations={[1]={zoneId=ID_WROTHGAR}}},     	--Morkuldin
    [409]   = {itemId=143161, traits=2, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_HEALER}, locations={[1]={zoneId=ID_MURKMIRE}}},     	--Naga Shaman
    [387]   = {itemId=136417, traits=9, build={[1]=KPUI_SET_BUILD_TANK}, locations={[1]={zoneId=ID_SUMMERSET}}},     	--Nocturnal's Favor
    [84]    = {itemId=44031, traits=8, build={[1]=KPUI_SET_BUILD_TANK}, locations={[1]={zoneId=ID_EARTHFORGE}}},     	--Orgnum's Scales
    [242]   = {itemId=76086, traits=9, build={[1]=KPUI_SET_BUILD_DDS}, locations={[1]={zoneId=ID_GOLDCOAST}}},     	--Pelinal's Aptitude
    [43]    = {itemId=43827, traits=3, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_HEALER}, locations={[1]={zoneId=ID_DESHAAN},[2]={zoneId=ID_STORMHAVEN},[3]={zoneId=ID_GRAHTWOOD}}},     	--Armor of the Seducer
    [178]   = {itemId=60646, traits=9, build={[1]=KPUI_SET_BUILD_TANK}, locations={[1]={zoneId=ID_IMPERIALCITY}}},     	--Armor Master
    [74]    = {itemId=43971, traits=8, build={[1]=KPUI_SET_BUILD_TANK}, locations={[1]={zoneId=ID_COLDHARBOUR}}},     	--Spectre's Eye
    [225]   = {itemId=72141, traits=7, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_DDS_STAMINA, [3]=KPUI_SET_BUILD_DDS_MAGICKA}, locations={[1]={zoneId=ID_HEWSBANE}}},     	--Clever Alchemist
    [95]    = {itemId=40259, traits=8, build={[1]=KPUI_SET_BUILD_TANK}, locations={[1]={zoneId=ID_EYEVEA}}},     	--Shalidor's Curse
    [40]    = {itemId=43815, traits=2, build={[1]=KPUI_SET_BUILD_DDS_STAMINA}, locations={[1]={zoneId=ID_STONEFALLS},[2]={zoneId=ID_GLENUMBRA},[3]={zoneId=ID_AURIDON}}},     	--Night's Silence
    [224]   = {itemId=71791, traits=5, build={[1]=KPUI_SET_BUILD_PVE}, locations={[1]={zoneId=ID_HEWSBANE}}},     	--Tava's Favor
    [37]    = {itemId=43803, traits=2, build={[1]=KPUI_SET_BUILD_TANK}, locations={[1]={zoneId=ID_STONEFALLS},[2]={zoneId=ID_GLENUMBRA},[3]={zoneId=ID_AURIDON}}},     	--Death's Wind
    [75]    = {itemId=43977, traits=3, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_DDS_MAGICKA, [3]=KPUI_SET_BUILD_PVE, [4]=KPUI_SET_BUILD_PVP}, locations={[1]={zoneId=ID_DESHAAN},[2]={zoneId=ID_STORMHAVEN},[3]={zoneId=ID_GRAHTWOOD}}},     	--Torug's Pact
    [177]   = {itemId=60296, traits=7, build={[1]=KPUI_SET_BUILD_PVP}, locations={[1]={zoneId=ID_IMPERIALCITY}}},     	--Redistributor
    [241]   = {itemId=75736, traits=7, build={[1]=KPUI_SET_BUILD_TANK}, locations={[1]={zoneId=ID_GOLDCOAST}}},     	--Varen's Legacy
    [385]   = {itemId=135717, traits=3, build={[1]=KPUI_SET_BUILD_TANK}, locations={[1]={zoneId=ID_SUMMERSET}}},		--Adept Rider
    [148]   = {itemId=54787, traits=8, build={[1]=KPUI_SET_BUILD_NONE}, locations={[1]={zoneId=ID_CRAGLORN}}},     	--Way of the Arena
    [79]    = {itemId=44001, traits=6, build={[1]=KPUI_SET_BUILD_DDS}, locations={[1]={zoneId=ID_THERIFT},[2]={zoneId=ID_BANGKORAI},[3]={zoneId=ID_REAPERSMARCH}}},     	--Willow's Path
    [41]    = {itemId=43819, traits=4, build={[1]=KPUI_SET_BUILD_TANK}, locations={[1]={zoneId=ID_SHADOWFEN},[2]={zoneId=ID_RIVENSPIRE},[3]={zoneId=ID_GREENSHADE}}},     	--Whitestrake's Retribution
    [38]    = {itemId=43807, traits=3, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_DDS_MAGICKA}, locations={[1]={zoneId=ID_DESHAAN},[2]={zoneId=ID_STORMHAVEN},[3]={zoneId=ID_GRAHTWOOD}}},     	--Twilight's Embrace
	[439] 	= {itemId=148688, traits=3, build={[1]=KPUI_SET_BUILD_NONE}, locations={[1]={zoneId=ID_ELSWEYR_NORTH}}},     --Vastarie's Tutelage
	[438] 	= {itemId=148318, traits=5, build={[1]=KPUI_SET_BUILD_TANK}, locations={[1]={zoneId=ID_ELSWEYR_NORTH}}},     --Senche-raht's Grit
	[437] 	= {itemId=147948, traits=8, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_DDS_MAGICKA}, locations={[1]={zoneId=ID_ELSWEYR_NORTH}}},     --Coldharbour's Favorite
}

kpuiConst.SetsOverland = {
	[20] 	= {itemId=10973, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_THERIFT}}},     --Witchman Armor
	[21] 	= {itemId=7664, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_EASTMARCH}}},     --Akaviri Dragonguard
	[22] 	= {itemId=2503, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_STORMHAVEN}}},     --Dreamer's Mantle
	[23] 	= {itemId=43761, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CRAGLORN}}},     --Archer's Mind
	[24] 	= {itemId=43764, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CRAGLORN}}},     --Footman's Fortune
	[281] 	= {itemId=1115, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT, [4]=KPUI_SET_ITEMS_WEAPONS, [5]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_BALFOYEN}, [2]={zoneId=ID_BETNIKH}, [3]={zoneId=ID_BLEAKROCKISLE}, [4]={zoneId=ID_KHENARTHISROOST}, [5]={zoneId=ID_STROSMKAI}}},     --Armor of the Trainee
	[282] 	= {itemId=7294, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_RIVENSPIRE}}},     --Vampire Cloak
	[283] 	= {itemId=7508, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_ALIKRDESERT}}},     --Sword-Singer
	[284] 	= {itemId=7520, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_ALIKRDESERT}}},     --Order of Diagna
	[285] 	= {itemId=15599, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_BANGKORAI}}},     --Vampire Lord
	[286] 	= {itemId=15594, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_BANGKORAI}}},     --Spriggan's Thorns
	[287] 	= {itemId=1674, build={[1]=KPUI_SET_BUILD_WEREWOLF}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_GRAHTWOOD}}},     --Green Pact
	[288] 	= {itemId=10848, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_GREENSHADE}}},     --Beekeeper's Gear
	[289] 	= {itemId=15524, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA, [2]=KPUI_SET_BUILD_PVE, [3]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_MALABALTOR}}},     --Spinner's Garments
	[290] 	= {itemId=10921, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_REAPERSMARCH}}},     --Skooma Smuggler
	[291] 	= {itemId=6900, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_STONEFALLS}}},     --Shalk Exoskeleton
	[292] 	= {itemId=4308, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_DESHAAN}}},     --Mother's Sorrow
	[293] 	= {itemId=4305, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_DESHAAN}}},     --Plague Doctor
	[294] 	= {itemId=10150, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_THERIFT}}},     --Ysgramor's Birthright
	[39] 	= {itemId=43811, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Alessian Order
	[47] 	= {itemId=7514, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_ALIKRDESERT}}},     --Robes of the Withered Hand
	[49] 	= {itemId=70, build={[1]=KPUI_SET_BUILD_DDS_STAMINA}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_STONEFALLS}}},     --Shadow of the Red Mountain
	[50] 	= {itemId=43855, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --The Morag Tong
	[52] 	= {itemId=43863, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Beckoning Steel
	[56] 	= {itemId=7668, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_EASTMARCH}}},     --Stendarr's Embrace
	[57] 	= {itemId=1672, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_GRAHTWOOD}}},     --Syrabane's Grip
	[58] 	= {itemId=1088, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_GLENUMBRA}}},     --Hide of the Werewolf
	[59] 	= {itemId=43895, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Kyne's Kiss
	[60] 	= {itemId=7295, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_RIVENSPIRE}}},     --Darkstride
	[62] 	= {itemId=7440, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_SHADOWFEN}}},     --Hatchling's Shell
	[63] 	= {itemId=43915, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --The Juggernaut
	[64] 	= {itemId=10878, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_GREENSHADE}}},     --Shadow Dancer's Raiment
	[65] 	= {itemId=471, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_GLENUMBRA}}},     --Bloodthorn's Touch
	[66] 	= {itemId=7445, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_SHADOWFEN}}},     --Robes of the Hist
	[67] 	= {itemId=43935, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Shadow Walker
	[68] 	= {itemId=10861, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_COLDHARBOUR}}},     --Stygian
	[69] 	= {itemId=1662, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_GRAHTWOOD}}},     --Ranger's Gait
	[70] 	= {itemId=15600, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_BANGKORAI}}},     --Seventh Legion Brute
	[327] 	= {itemId=123348, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_LOCATION_NONE}}},     --Coward's Gear
	[328] 	= {itemId=123530, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_LOCATION_NONE}}},     --Knight Slayer
	[329] 	= {itemId=123721, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA, [2]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_LOCATION_NONE}}},     --Wizard's Riposte
	[76] 	= {itemId=43983, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Robes of Alteration Mastery
	[334] 	= {itemId=125689, build={[1]=KPUI_SET_BUILD_WEREWOLF, [2]=KPUI_SET_BUILD_HEALER, [3]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT, [4]=KPUI_SET_ITEMS_WEAPONS, [5]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_LOCATION_NONE}}},     --Impregnable Armor
	[83] 	= {itemId=44025, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Elf Bane
	[85] 	= {itemId=44037, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Almalexia's Mercy
	[86] 	= {itemId=7598, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_AURIDON}}},     --Queen's Elegance
	[88] 	= {itemId=44055, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CRAGLORN}}},     --Robes of Destruction Mastery
	[89] 	= {itemId=44061, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Sentry
	[90] 	= {itemId=10239, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_REAPERSMARCH}}},     --Senche's Bite
	[93] 	= {itemId=2474, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_STORMHAVEN}}},     --Storm Knight's Plate
	[94] 	= {itemId=15732, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_COLDHARBOUR}}},     --Meridia's Blessed Armor
	[97] 	= {itemId=44111, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --The Arch-Mage
	[98] 	= {itemId=7292, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA, [2]=KPUI_SET_BUILD_PVE, [3]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_RIVENSPIRE}}},     --Necropotence
	[99] 	= {itemId=15527, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_MALABALTOR}}},     --Salvation
	[100] 	= {itemId=44132, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Hawk's Eye
	[101] 	= {itemId=44139, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Affliction
	[104] 	= {itemId=44160, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Curse Eater
	[105] 	= {itemId=3158, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_AURIDON}}},     --Twin Sisters
	[106] 	= {itemId=10847, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_GREENSHADE}}},     --Wilderqueen's Arch
	[107] 	= {itemId=317, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_GLENUMBRA}}},     --Wyrd Tree's Blessing
	[108] 	= {itemId=44188, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Ravager
	[109] 	= {itemId=44195, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Light of Cyrodiil
	[111] 	= {itemId=44209, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Ward of Cyrodiil
	[112] 	= {itemId=2501, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_STORMHAVEN}}},     --Night Terror
	[113] 	= {itemId=44223, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Crest of Cyrodiil
	[114] 	= {itemId=10914, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_REAPERSMARCH}}},     --Soulshine
	[380] 	= {itemId=134799, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_LOCATION_NONE}}},     --Prophet's
	[125] 	= {itemId=54287, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_WEAPONS, [2]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Wrath of the Imperium
	[126] 	= {itemId=54295, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_WEAPONS, [2]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Grace of the Ancients
	[127] 	= {itemId=54296, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Deadly Strike
	[384] 	= {itemId=134696, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_SUMMERSET}}},     --Wisdom of Vanus
	[129] 	= {itemId=54303, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_WEAPONS, [2]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Vengeance Leech
	[130] 	= {itemId=54328, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_WEAPONS, [2]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Eagle Eye
	[131] 	= {itemId=54321, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Bastion of the Heartland
	[132] 	= {itemId=54307, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Shield of the Valiant
	[133] 	= {itemId=54314, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Buffer of the Swift
	[135] 	= {itemId=10972, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_THERIFT}}},     --Draugr's Heritage
	[145] 	= {itemId=54921, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CRAGLORN}}},     --Way of Fire
	[146] 	= {itemId=54928, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CRAGLORN}}},     --Way of Air
	[147] 	= {itemId=54935, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CRAGLORN}}},     --Way of Martial Knowledge
	[405] 	= {itemId=142600, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA, [2]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_MURKMIRE}}},     --Bright-Throat's Boast
	[406] 	= {itemId=142418, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_MURKMIRE}}},     --Dead-Water's Guile
	[407] 	= {itemId=142236, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_MURKMIRE}}},     --Champion of the Hist
	[417] 	= {itemId=143901, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Indomitable Fury
	[418] 	= {itemId=144092, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Spell Strategist
	[419] 	= {itemId=144283, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Battlefield Acrobat
	[420] 	= {itemId=144465, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Soldier of Anguish
	[421] 	= {itemId=144647, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Steadfast Hero
	[422] 	= {itemId=144829, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Battalion Defender
	[179] 	= {itemId=68432, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_IMPERIALCITY}}},     --Black Rose
	[180] 	= {itemId=68535, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_IMPERIALCITY}}},     --Powerful Assault
	[181] 	= {itemId=68615, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_IMPERIALCITY}}},     --Meritorious Service
	[440] 	= {itemId=149240, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_ELSWEYR_NORTH}}},     --Crafty Alfiq
	[441] 	= {itemId=149431, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_ELSWEYR_NORTH}}},     --Vesture of Darloc Brae
	[442] 	= {itemId=149058, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_ELSWEYR_NORTH}}},     --Call of the Undertaker
	[187] 	= {itemId=7476, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_SHADOWFEN}}},     --Swamp Raider
	[199] 	= {itemId=68711, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_IMPERIALCITY}}},     --Shield Breaker
	[200] 	= {itemId=68791, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_IMPERIALCITY}}},     --Phoenix
	[201] 	= {itemId=68872, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_IMPERIALCITY}}},     --Reactive Armor
	[206] 	= {itemId=69281, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_PVE, [3]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_WEAPONS, [2]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_IMPERIALCITY}}},     --Agility
	[209] 	= {itemId=137543, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=ID_NONE}, locations={[1]={zoneId=ID_LOCATION_NONE}}},     --Armor of the Code
	[210] 	= {itemId=68608, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_WROTHGAR}}},     --Mark of the Pariah
	[212] 	= {itemId=68447, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_WROTHGAR}}},     --Briarheart
	[218] 	= {itemId=68439, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_WROTHGAR}}},     --Trinimac's Valor
	[315] 	= {itemId=55936, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_PVE, [3]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_CRAGLORN}}},     --Stinging Slashes
	[320] 	= {itemId=122792, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA, [2]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_VVARDENFELL}}},     --War Maiden
	[383] 	= {itemId=134701, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_SUMMERSET}}},     --Gryphon's Ferocity
	[321] 	= {itemId=122983, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_VVARDENFELL}}},     --Defiler
	[322] 	= {itemId=122610, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_VVARDENFELL}}},     --Warrior-Poet
	[326] 	= {itemId=123166, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_LOCATION_NONE}}},     --Vanguard's Challenge
	[36] 	= {itemId=1373, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_AURIDON}}},     --Armor of the Veiled Heritance
	[227] 	= {itemId=72841, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT, [4]=KPUI_SET_ITEMS_WEAPONS, [5]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_HEWSBANE}}},     --Bahraha's Curse
	[228] 	= {itemId=72913, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT, [4]=KPUI_SET_ITEMS_WEAPONS, [5]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_HEWSBANE}}},     --Syvarra's Scales
	[354] 	= {itemId=132848, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CLOCKWORK}}},     --Mad Tinkerer
	[25] 	= {itemId=43767,  build={[1]=KPUI_SET_BUILD_HEALER, [2]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Desert Rose
	[26] 	= {itemId=15728, build={[1]=KPUI_SET_BUILD_WEREWOLF}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_COLDHARBOUR}}},     --Prisoner's Rags
	[27] 	= {itemId=7661, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_EASTMARCH}}},     --Fiord's Legacy
	[30] 	= {itemId=10885, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_MALABALTOR}}},     --Thunderbug's Carapace
	[234] 	= {itemId=73873,  build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Marksman's Crest
	[235] 	= {itemId=74222, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA, [2]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Robes of Transmutation
	[236] 	= {itemId=74149, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA, [2]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Vicious Death
	[237] 	= {itemId=73935, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Leki's Focus
	[238] 	= {itemId=73997, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Fasalla's Guile
	[239] 	= {itemId=74080, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Warrior's Fury
	[31] 	= {itemId=1530, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_STONEFALLS}}},     --Silks of the Sun
	[34] 	= {itemId=4289, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_DESHAAN}}},     --Night Mother's Embrace
	[32] 	= {itemId=43788, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CRAGLORN}}},     --Healer's Habit
	[243] 	= {itemId=76916, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_GOLDCOAST}}},     --Hide of Morihaus
	[244] 	= {itemId=77076, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_GOLDCOAST}}},     --Flanking Strategist
	[245] 	= {itemId=77236, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT, [4]=KPUI_SET_ITEMS_WEAPONS, [5]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_GOLDCOAST}}},     --Sithis' Touch
	[246] 	= {itemId=78048, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_IMPERIALCITY}}},     --Galerion's Revenge
	[247] 	= {itemId=78328, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_IMPERIALCITY}}},     --Vicecanon of Venom
	[248] 	= {itemId=78608, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_IMPERIALCITY}}},     --Thews of the Harbinger
	[355] 	= {itemId=133039, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CLOCKWORK}}},     --Unfathomable Darkness
	[356] 	= {itemId=132666, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CLOCKWORK}}},     --Livewire
	[381] 	= {itemId=134955, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_LOCATION_NONE}}},     --Broken Soul
	[382] 	= {itemId=134692, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_SUMMERSET}}},     --Grace of Gloom
	[253] 	= {itemId=78906, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_DDS_MAGICKA, [3]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT, [4]=KPUI_SET_ITEMS_WEAPONS, [5]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_IMPERIALCITY}}},     --Imperial Physique
	[128] 	= {itemId=54300, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_WEAPONS, [2]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CYRODIIL}}},     --Blessing of the Potentates
}	

kpuiConst.SetsDungeon = {
	[91] 	= {itemId=44073, build={[1]=KPUI_SET_BUILD_DDS_STAMINA}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_COLDHARBOUR}}},     --Oblivion's Edge
	[258] 	= {itemId=82411, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA, [2]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_SHADOWFEN}}},     --Amber Plasm
	[259] 	= {itemId=82602, build={[1]=KPUI_SET_BUILD_DDS_STAMINA}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_SHADOWFEN}}},     --Heem-Jas' Retribution
	[260] 	= {itemId=82229, build={[1]=KPUI_SET_BUILD_WEREWOLF}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_SHADOWFEN}}},     --Aspect of Mazzatun
	[261] 	= {itemId=82966, build={[1]=KPUI_SET_BUILD_HEALER, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_SHADOWFEN}}},     --Gossamer
	[262] 	= {itemId=83157, build={[1]=KPUI_SET_BUILD_DDS_STAMINA}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_SHADOWFEN}}},     --Widowmaker
	[263] 	= {itemId=82784, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_SHADOWFEN}}},     --Hand of Mephala
	[19] 	= {itemId=22200, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_REAPERSMARCH}}},     --Vestments of the Warlock
	[28] 	= {itemId=15767, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_GRAHTWOOD}}},     --Barkskin
	[29] 	= {itemId=16228, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_STORMHAVEN}}},     --Sergeant's Mail
	[33] 	= {itemId=10961, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_STONEFALLS}}},     --Viper's Sting
	[35] 	= {itemId=29065, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_GLENUMBRA}}},     --Knightmare
	[295] 	= {itemId=29071, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_AURIDON}}},     --Jailbreaker
	[296] 	= {itemId=29097, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_GLENUMBRA}}},     --Spelunker
	[297] 	= {itemId=28122, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_STONEFALLS}}},     --Spider Cultist Cowl
	[298] 	= {itemId=15546, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_GRAHTWOOD}}},     --Light Speaker
	[299] 	= {itemId=7666, build={[1]=KPUI_SET_BUILD_DDS_STAMINA}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_STORMHAVEN}}},     --Toothrow
	[300] 	= {itemId=15679, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_DESHAAN}}},     --Netch's Touch
	[301] 	= {itemId=5921, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_DESHAAN}}},     --Strength of the Automaton
	[46] 	= {itemId=22161, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_THERIFT}}},     --Noble Duelist's Silks
	[303] 	= {itemId=16046, build={[1]=KPUI_SET_BUILD_HEALER}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_SHADOWFEN}}},     --Lamia's Song
	[304] 	= {itemId=16044, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_SHADOWFEN}}},     --Medusa
	[305] 	= {itemId=33153, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_ALIKRDESERT}}},     --Treasure Hunter
	[307] 	= {itemId=33283, build={[1]=KPUI_SET_BUILD_WEREWOLF}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_EASTMARCH}}},     --Draugr Hulk
	[308] 	= {itemId=22156, build={[1]=KPUI_SET_BUILD_WEREWOLF, [2]=KPUI_SET_BUILD_DDS_STAMINA}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_BANGKORAI}}},     --Bone Pirate's Tatters
	[53] 	= {itemId=33159, build={[1]=KPUI_SET_BUILD_DDS}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_EASTMARCH}}},     --The Ice Furnace
	[310] 	= {itemId=22169, build={[1]=KPUI_SET_BUILD_DDS_STAMINA}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_THERIFT}}},     --Sword Dancer
	[55] 	= {itemId=10067, build={[1]=KPUI_SET_BUILD_HEALER}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_GLENUMBRA}}},     --Prayer Shawl
	[313] 	= {itemId=55934, build={[1]=KPUI_SET_BUILD_DDS, [2]=KPUI_SET_BUILD_PVE, [3]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_CRAGLORN}}},     --Titanic Cleave
	[314] 	= {itemId=55935, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_CRAGLORN}}},     --Puncturing Remedy
	[316] 	= {itemId=55937, build={[1]=KPUI_SET_BUILD_DDS, [2]=KPUI_SET_BUILD_PVE, [3]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_CRAGLORN}}},     --Caustic Arrow
	[317] 	= {itemId=55938, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_CRAGLORN}}},     --Destructive Impact
	[318] 	= {itemId=55939, build={[1]=KPUI_SET_BUILD_HEALER, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_CRAGLORN}}},     --Grand Rejuvenation
	[71] 	= {itemId=22182, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_REAPERSMARCH}}},     --Durok's Bane
	[72] 	= {itemId=22162, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_THERIFT}}},     --Nikulas' Heavy Armor
	[330] 	= {itemId=123912, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_VVARDENFELL}}},     --Automated Defense
	[331] 	= {itemId=124094, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_VVARDENFELL}}},     --War Machine
	[332] 	= {itemId=124276, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_VVARDENFELL}}},     --Master Architect
	[77] 	= {itemId=33155, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_ALIKRDESERT}}},     --Crusader
	[335] 	= {itemId=127332, build={[1]=KPUI_SET_BUILD_HEALER}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CRAGLORN}}},     --Draugr's Rest
	[336] 	= {itemId=127523, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CRAGLORN}}},     --Pillar of Nirn
	[337] 	= {itemId=127150, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CRAGLORN}}},     --Ironblood
	[338] 	= {itemId=127935, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CRAGLORN}}},     --Flame Blossom
	[339] 	= {itemId=128126, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CRAGLORN}}},     --Blooddrinker
	[340] 	= {itemId=127753, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CRAGLORN}}},     --Hagraven's Garden
	[343] 	= {itemId=128554, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_BANGKORAI}}},     --Caluurion's Legacy
	[344] 	= {itemId=128745, build={[1]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_BANGKORAI}}},     --Trappings of Invigoration
	[345] 	= {itemId=128372, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_BANGKORAI}}},     --Ulfnor's Favor
	[346] 	= {itemId=129109, build={[1]=KPUI_SET_BUILD_HEALER, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_STORMHAVEN}}},     --Jorvuld's Guidance
	[347] 	= {itemId=129300, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_STORMHAVEN}}},     --Plague Slinger
	[348] 	= {itemId=128927, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_STORMHAVEN}}},     --Curse of Doylemish
	[96] 	= {itemId=7690, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_DDS_STAMINA}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_DESHAAN}}},     --Armor of Truth
	[357] 	= {itemId=133251, build={[1]=KPUI_SET_BUILD_PVE, [2]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_CLOCKWORK}}},     --Disciplined Slash (Perfected)
	[102] 	= {itemId=33273, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_ALIKRDESERT}}},     --Duneripper's Scales
	[103] 	= {itemId=33160, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_EASTMARCH}}},     --Magicka Furnace
	[360] 	= {itemId=133254, build={[1]=KPUI_SET_BUILD_DDS_STAMINA}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_CLOCKWORK}}},     --Piercing Spray (Perfected)
	[361] 	= {itemId=133255, build={[1]=KPUI_SET_BUILD_DDS, [2]=KPUI_SET_BUILD_PVE, [3]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_CLOCKWORK}}},     --Concentrated Force (Perfected)
	[362] 	= {itemId=133258, build={[1]=KPUI_SET_BUILD_HEALER, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_CLOCKWORK}}},     --Timeless Blessing (Perfected)
	[363] 	= {itemId=133404, build={[1]=KPUI_SET_BUILD_PVE, [2]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_CLOCKWORK}}},     --Disciplined Slash
	[364] 	= {itemId=133396, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_CLOCKWORK}}},     --Defensive Position
	[365] 	= {itemId=133400, build={[1]=KPUI_SET_BUILD_DDS}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_CLOCKWORK}}},     --Chaotic Whirlwind
	[110] 	= {itemId=7717, build={[1]=KPUI_SET_BUILD_HEALER, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_AURIDON}}},     --Sanctuary
	[367] 	= {itemId=133408, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_CLOCKWORK}}},     --Concentrated Force
	[368] 	= {itemId=133411, build={[1]=KPUI_SET_BUILD_HEALER, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_CLOCKWORK}}},     --Timeless Blessing
	[369] 	= {itemId=71118, build={[1]=KPUI_SET_BUILD_DDS, [2]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_WROTHGAR}}},     --Merciless Charge
	[370] 	= {itemId=71106, build={[1]=KPUI_SET_BUILD_DDS}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_WROTHGAR}}},     --Rampaging Slash
	[371] 	= {itemId=71100, build={[1]=KPUI_SET_BUILD_DDS}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_WROTHGAR}}},     --Cruel Flurry
	[116] 	= {itemId=54257, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_WEAPONS, [2]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_AURIDON}, [2]={zoneId=ID_GLENUMBRA}, [3]={zoneId=ID_STONEFALLS}, [4]={zoneId=ID_STORMHAVEN}, [5]={zoneId=ID_GRAHTWOOD}, [6]={zoneId=ID_DESHAAN}}},     --The Destruction Suite
	[117] 	= {itemId=55379, build={[1]=KPUI_SET_BUILD_HEALER}, items={[1]=KPUI_SET_ITEMS_WEAPONS, [2]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_AURIDON}, [2]={zoneId=ID_GLENUMBRA}, [3]={zoneId=ID_STONEFALLS}, [4]={zoneId=ID_STORMHAVEN}, [5]={zoneId=ID_GRAHTWOOD}, [6]={zoneId=ID_DESHAAN}}},     --Relics of the Physician, Ansur
	[118] 	= {itemId=55365, build={[1]=KPUI_SET_BUILD_DDS}, items={[1]=KPUI_SET_ITEMS_WEAPONS, [2]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_AURIDON}, [2]={zoneId=ID_GLENUMBRA}, [3]={zoneId=ID_STONEFALLS}, [4]={zoneId=ID_STORMHAVEN}, [5]={zoneId=ID_GRAHTWOOD}, [6]={zoneId=ID_DESHAAN}}},     --Treasures of the Earthforge
	[119] 	= {itemId=55367, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_WEAPONS, [2]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_AURIDON}, [2]={zoneId=ID_GLENUMBRA}, [3]={zoneId=ID_STONEFALLS}, [4]={zoneId=ID_STORMHAVEN}, [5]={zoneId=ID_GRAHTWOOD}, [6]={zoneId=ID_DESHAAN}}},     --Relics of the Rebellion
	[120] 	= {itemId=54267, build={[1]=KPUI_SET_BUILD_DDS}, items={[1]=KPUI_SET_ITEMS_WEAPONS, [2]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_AURIDON}, [2]={zoneId=ID_GLENUMBRA}, [3]={zoneId=ID_STONEFALLS}, [4]={zoneId=ID_STORMHAVEN}, [5]={zoneId=ID_GRAHTWOOD}, [6]={zoneId=ID_DESHAAN}}},     --Arms of Infernace
	[121] 	= {itemId=55368, build={[1]=KPUI_SET_BUILD_DDS}, items={[1]=KPUI_SET_ITEMS_WEAPONS, [2]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_AURIDON}, [2]={zoneId=ID_GLENUMBRA}, [3]={zoneId=ID_STONEFALLS}, [4]={zoneId=ID_STORMHAVEN}, [5]={zoneId=ID_GRAHTWOOD}, [6]={zoneId=ID_DESHAAN}}},     --Arms of the Ancestors
	[122] 	= {itemId=16047, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_RIVENSPIRE}}},     --Ebon Armory
	[123] 	= {itemId=23666, build={[1]=KPUI_SET_BUILD_DDS_STAMINA}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_REAPERSMARCH}}},     --Hircine's Veneer
	[124] 	= {itemId=34384, build={[1]=KPUI_SET_BUILD_HEALER, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_COLDHARBOUR}}},     --The Worm's Raiment
	[388] 	= {itemId=136767, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_SUMMERSET}}},     --Aegis of Galenwe
	[389] 	= {itemId=136949, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_SUMMERSET}}},     --Arms of Relequen
	[134] 	= {itemId=16144, build={[1]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_RIVENSPIRE}}},     --Shroud of the Lich
	[391] 	= {itemId=137322, build={[1]=KPUI_SET_BUILD_HEALER, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_SUMMERSET}}},     --Vestment of Olorime
	[136] 	= {itemId=54874, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CRAGLORN}}},     --Immortal Warrior
	[137] 	= {itemId=54881, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CRAGLORN}}},     --Berserking Warrior
	[138] 	= {itemId=54885, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CRAGLORN}}},     --Defending Warrior
	[139] 	= {itemId=54889, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CRAGLORN}}},     --Wise Mage
	[140] 	= {itemId=54896, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CRAGLORN}}},     --Destructive Mage
	[141] 	= {itemId=54902, build={[1]=KPUI_SET_BUILD_HEALER, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CRAGLORN}}},     --Healing Mage
	[142] 	= {itemId=54906, build={[1]=KPUI_SET_BUILD_DDS_STAMINA}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CRAGLORN}}},     --Quick Serpent
	[143] 	= {itemId=54913, build={[1]=KPUI_SET_BUILD_DDS_STAMINA}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CRAGLORN}}},     --Poisonous Serpent
	[144] 	= {itemId=54917, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CRAGLORN}}},     --Twice-Fanged Serpent
	[401] 	= {itemId=140512, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_GREENSHADE}}},     --Haven of Ursus
	[402] 	= {itemId=141249, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_REAPERSMARCH}}},     --Moon Hunter
	[403] 	= {itemId=141440, build={[1]=KPUI_SET_BUILD_DDS_STAMINA}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_REAPERSMARCH}}},     --Savage Werewolf
	[404] 	= {itemId=141067, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_REAPERSMARCH}}},     --Jailer's Tenacity
	[155] 	= {itemId=16213, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_GRAHTWOOD}}},     --Undaunted Bastion
	[156] 	= {itemId=23731, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_SHADOWFEN}}},     --Undaunted Infiltrator
	[157] 	= {itemId=22157, build={[1]=KPUI_SET_BUILD_DDS_STAMINA}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_BANGKORAI}}},     --Undaunted Unweaver
	[158] 	= {itemId=5832, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_GREENSHADE}}},     --Embershield
	[159] 	= {itemId=5831, build={[1]=KPUI_SET_BUILD_DDS_STAMINA}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_GREENSHADE}}},     --Sunderflame
	[160] 	= {itemId=23710, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA, [2]=KPUI_SET_BUILD_PVE, [3]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_GREENSHADE}}},     --Burning Spellweave
	[423] 	= {itemId=145164, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_MURKMIRE}}},     --Perfect Gallant Charge
	[424] 	= {itemId=145172, build={[1]=KPUI_SET_BUILD_DDS}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_MURKMIRE}}},     --Perfect Radial Uppercut
	[425] 	= {itemId=145168, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_MURKMIRE}}},     --Perfect Spectral Cloak
	[426] 	= {itemId=145175, build={[1]=KPUI_SET_BUILD_DDS_STAMINA}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_MURKMIRE}}},     --Perfect Virulent Shot
	[171] 	= {itemId=59738, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CRAGLORN}}},     --Eternal Warrior
	[172] 	= {itemId=59752, build={[1]=KPUI_SET_BUILD_HEALER, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CRAGLORN}}},     --Infallible Mage
	[173] 	= {itemId=59745, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_CRAGLORN}}},     --Vicious Serpent
	[430] 	= {itemId=146259, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_EASTMARCH}}},     --Tzogvin's Warband
	[431] 	= {itemId=146441, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_EASTMARCH}}},     --Icy Conjuror
	[433] 	= {itemId=146680, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_GOLDCOAST}}},    --Frozen Watcher
	[434] 	= {itemId=146862, build={[1]=KPUI_SET_BUILD_DDS_STAMINA}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_GOLDCOAST}}},     --Scavenging Demise
	[435] 	= {itemId=147044, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_GOLDCOAST}}},     --Auroran's Thunder
	[184] 	= {itemId=64760, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_IMPERIALCITY}}},     --Brands of Imperium
	[185] 	= {itemId=66167, build={[1]=KPUI_SET_BUILD_HEALER, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_IMPERIALCITY}}},     --Spell Power Cure
	[186] 	= {itemId=33167, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_MALABALTOR}}},     --Jolting Arms
	[188] 	= {itemId=33276, build={[1]=KPUI_SET_BUILD_DDS_STAMINA}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_MALABALTOR}}},     --Storm Master
	[445] 	= {itemId=149795, build={[1]=KPUI_SET_BUILD_DDS_STAMINA}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_ELSWEYR_NORTH}}},     --Tooth of Lokkestiiz
	[190] 	= {itemId=67567, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_IMPERIALCITY}}},     --Scathing Mage
	[193] 	= {itemId=33176, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_MALABALTOR}}},     --Overwhelming Surge
	[194] 	= {itemId=16219, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_STORMHAVEN}}},     --Combat Physician
	[195] 	= {itemId=67015, build={[1]=KPUI_SET_BUILD_DDS_STAMINA}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_IMPERIALCITY}}},     --Sheer Veno
	[196] 	= {itemId=66440, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_DDS_STAMINA}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_IMPERIALCITY}}},     --Leeching Plate
	[197] 	= {itemId=28112, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_AURIDON}}},     --Tormentor
	[198] 	= {itemId=65335, build={[1]=KPUI_SET_BUILD_DDS_STAMINA}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_IMPERIALCITY}}},     --Essence Thief
	[204] 	= {itemId=55963, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_DDS_STAMINA}, items={[1]=KPUI_SET_ITEMS_WEAPONS, [2]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_IMPERIALCITY}}},     --Endurance
	[205] 	= {itemId=64488, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_WEAPONS, [2]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_IMPERIALCITY}}},     --Willpower
	[211] 	= {itemId=68784, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_WROTHGAR}}},     --Permafrost
	[213] 	= {itemId=68696, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_DDS_STAMINA}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_WROTHGAR}}},     --Glorious Defender
	[214] 	= {itemId=68623, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_DDS_STAMINA}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_WROTHGAR}}},     --Para Bellum
	[215] 	= {itemId=68703, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_WROTHGAR}}},     --Elemental Succession
	[216] 	= {itemId=68799, build={[1]=KPUI_SET_BUILD_DDS_STAMINA}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_WROTHGAR}}},     --Hunt Leader
	[217] 	= {itemId=68527, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_WROTHGAR}}},     --Winterborn
	[333] 	= {itemId=124467, build={[1]=KPUI_SET_BUILD_HEALER}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_VVARDENFELL}}},     --Inventor's Guard
	[61] 	= {itemId=139, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_DDS_STAMINA}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_STONEFALLS}}},     --Dreugh King Slayer
	[358] 	= {itemId=133243, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_CLOCKWORK}}},     --Defensive Position (Perfected)
	[359] 	= {itemId=133247, build={[1]=KPUI_SET_BUILD_DDS}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_CLOCKWORK}}},     --Chaotic Whirlwind (Perfected)
	[311] 	= {itemId=44728, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_DDS_MAGICKA}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_COLDHARBOUR}}},     --Rattlecage
	[309] 	= {itemId=22196, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_BANGKORAI}}},     --Knight-errant's Mail
	[229] 	= {itemId=73011, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_REAPERSMARCH}}},     --Twilight Remedy
	[230] 	= {itemId=72985, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_REAPERSMARCH}}},     --Moondancer
	[231] 	= {itemId=73060, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_REAPERSMARCH}}},     --Lunar Bastion
	[232] 	= {itemId=73037, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_REAPERSMARCH}}},     --Roar of Alkosh
	[302] 	= {itemId=16042, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_RIVENSPIRE}}},     --Leviathan
	[366] 	= {itemId=133407, build={[1]=KPUI_SET_BUILD_DDS}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_CLOCKWORK}}},     --Piercing Spray
	[372] 	= {itemId=71142, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_WROTHGAR}}},     --Thunderous Volley
	[373] 	= {itemId=71152, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_WROTHGAR}}},     --Crushing Wall
	[374] 	= {itemId=71170, build={[1]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_WROTHGAR}}},     --Precise Regeneration
	[390] 	= {itemId=137131, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_SUMMERSET}}},     --Mantle of Siroria
	[392] 	= {itemId=137964, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_SUMMERSET}}},     --Perfect Aegis of Galenwe
	[393] 	= {itemId=138146, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_WEREWOLF, [3]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_SUMMERSET}}},     --Perfect Arms of Relequen
	[394] 	= {itemId=138328, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_SUMMERSET}}},     --Perfect Mantle of Siroria
	[395] 	= {itemId=138519, build={[1]=KPUI_SET_BUILD_HEALER, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_SUMMERSET}}},     --Perfect Vestment of Olorime
	[399] 	= {itemId=140694, build={[1]=KPUI_SET_BUILD_HEALER}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_GREENSHADE}}},     --Hanu's Compassion
	[400] 	= {itemId=140885, build={[1]=KPUI_SET_BUILD_WEREWOLF}, items={[1]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_GREENSHADE}}},     --Blood Moon
	[411] 	= {itemId=145011, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_MURKMIRE}}},     --Gallant Charge
	[412] 	= {itemId=145019, build={[1]=KPUI_SET_BUILD_DDS}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_MURKMIRE}}},     --Radial Uppercut
	[413] 	= {itemId=145015, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_MURKMIRE}}},     --Spectral Cloak
	[414] 	= {itemId=145022, build={[1]=KPUI_SET_BUILD_DDS}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_MURKMIRE}}},     --Virulent Shot
	[415] 	= {itemId=145023, build={[1]=KPUI_SET_BUILD_DDS}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_MURKMIRE}}},     --Wild Impulse
	[416] 	= {itemId=145026, build={[1]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_MURKMIRE}}},     --Mender's Ward
	[427] 	= {itemId=145176, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_MURKMIRE}}},     --Perfect Wild Impulse
	[428] 	= {itemId=145179, build={[1]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_WEAPONS}, locations={[1]={zoneId=ID_MURKMIRE}}},     --Perfect Mender's Ward
	[429] 	= {itemId=146077, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_EASTMARCH}}},     --Mighty Glacier
	[444] 	= {itemId=149977, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA}, items={[1]=KPUI_SET_ITEMS_ARMOR_LIGHT, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_ELSWEYR_NORTH}}},     --False God's Devotion
	[446] 	= {itemId=149613, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_WEAPONS, [3]=KPUI_SET_ITEMS_JEWELRY}, locations={[1]={zoneId=ID_ELSWEYR_NORTH}}},     --Claw of Yolnahkriin
}

kpuiConst.SetsMonster = {
	[256] 	= {itemId=82176, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_SHADOWFEN}}},     	--Mighty Chudan
	[257] 	= {itemId=82128, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_SHADOWFEN}}},     	--Velidreth
	[264] 	= {itemId=94452, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_LOCATION_NONE}}},     	--Giant Spider
	[265] 	= {itemId=94460, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_AURIDON}}},     	--Shadowrend
	[266] 	= {itemId=94468, build={[1]=KPUI_SET_BUILD_DDS}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_STONEFALLS}}},     	--Kra'gh
	[267] 	= {itemId=94476, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_GLENUMBRA}}},     	--Swarm Mother
	[268] 	= {itemId=94484, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_DESHAAN}}},     	--Sentinel of Rkugamz
	[269] 	= {itemId=94492, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_HEALER}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_GRAHTWOOD}}},     	--Chokethorn
	[270] 	= {itemId=94500, build={[1]=KPUI_SET_BUILD_DDS, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_STORMHAVEN}}},     	--Slimecraw
	[271] 	= {itemId=94508, build={[1]=KPUI_SET_BUILD_DDS_STAMINA}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_SHADOWFEN}}},     	--Sellistrix
	[272] 	= {itemId=94516, build={[1]=KPUI_SET_BUILD_NONE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_GREENSHADE}}},     	--Infernal Guardian
	[273] 	= {itemId=94524, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA, [2]=KPUI_SET_BUILD_PVE, [3]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_RIVENSPIRE}}},     	--Ilambris
	[274] 	= {itemId=94532, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_DDS_MAGICKA}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_EASTMARCH}}},     	--Iceheart
	[275] 	= {itemId=94540, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_MALABALTOR}}},     	--Stormfist
	[276] 	= {itemId=94548, build={[1]=KPUI_SET_BUILD_DDS_STAMINA}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_ALIKRDESERT}}},     	--Tremorscale
	[341] 	= {itemId=127705, build={[1]=KPUI_SET_BUILD_HEALER, [2]=KPUI_SET_BUILD_WEREWOLF, [3]=KPUI_SET_BUILD_PVE, [4]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_CRAGLORN}}},    	--Earthgore
	[342] 	= {itemId=128308, build={[1]=KPUI_SET_BUILD_DDS, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_CRAGLORN}}},     	--Domihaus
	[279] 	= {itemId=94572, build={[1]=KPUI_SET_BUILD_DDS, [2]=KPUI_SET_BUILD_WEREWOLF, [3]=KPUI_SET_BUILD_PVE, [4]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_REAPERSMARCH}}},     	--Selene
	[280] 	= {itemId=94580, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_COLDHARBOUR}}},     	--Grothdarr
	[349] 	= {itemId=129482, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_BANGKORAI}}},     	--Thurvokun
	[350] 	= {itemId=129530, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA, [2]=KPUI_SET_BUILD_PVE, [3]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_STORMHAVEN}}},     	--Zaan
	[162] 	= {itemId=59380, build={[1]=KPUI_SET_BUILD_DDS_STAMINA, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_STONEFALLS}}},     	--Spawn of Mephala
	[163] 	= {itemId=59416, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_PVE, [3]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_GLENUMBRA}}},     	--Bloodspawn
	[164] 	= {itemId=59452, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_IMPERIALCITY}}},     	--Lord Warden
	[165] 	= {itemId=59488, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_STORMHAVEN}}},     	--Scourge Harvester
	[166] 	= {itemId=59524, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_DESHAAN}}},     	--Engine Guardian
	[167] 	= {itemId=59560, build={[1]=KPUI_SET_BUILD_HEALER, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_GRAHTWOOD}}},     	--Nightflame
	[168] 	= {itemId=59596, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_RIVENSPIRE}}},     	--Nerien'eth
	[169] 	= {itemId=59632, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA, [2]=KPUI_SET_BUILD_PVE, [3]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_GREENSHADE}}},     	--Valkyn Skoria
	[170] 	= {itemId=59668, build={[1]=KPUI_SET_BUILD_TANK, [2]=KPUI_SET_BUILD_DDS}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_AURIDON}}},     	--Maw of the Infernal
	[432] 	= {itemId=146632, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_EASTMARCH}}},     	--Stonekeeper
	[436] 	= {itemId=147235, build={[1]=KPUI_SET_BUILD_HEALER, [2]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_GOLDCOAST}}},     	--Symphony of Blades
	[183] 	= {itemId=68107, build={[1]=KPUI_SET_BUILD_DDS_MAGICKA, [2]=KPUI_SET_BUILD_WEREWOLF, [3]=KPUI_SET_BUILD_PVE}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_IMPERIALCITY}}},     	--Molag Kena
	[278] 	= {itemId=94564, build={[1]=KPUI_SET_BUILD_WEREWOLF, [2]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_THERIFT}}},     	--The Troll King
	[277] 	= {itemId=94556, build={[1]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_BANGKORAI}}},     	--Pirate Skeleton
	[397] 	= {itemId=141622, build={[1]=KPUI_SET_BUILD_WEREWOLF, [2]=KPUI_SET_BUILD_PVP}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_GREENSHADE}}},     	--Balorgh
	[398] 	= {itemId=141670, build={[1]=KPUI_SET_BUILD_TANK}, items={[1]=KPUI_SET_ITEMS_ARMOR_HEAVY, [2]=KPUI_SET_ITEMS_ARMOR_MEDIUM, [3]=KPUI_SET_ITEMS_ARMOR_LIGHT}, locations={[1]={zoneId=ID_REAPERSMARCH}}},     	--Vykosa
}
