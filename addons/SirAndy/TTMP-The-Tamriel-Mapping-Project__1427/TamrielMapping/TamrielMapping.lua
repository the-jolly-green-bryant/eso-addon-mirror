-- ----------------------------------------------
-- TTMP: The Tamriel Mapping Project
-- Author:			SirAndy
-- Last Updated:	2021/06/11
-- Contact:			http://thesidekickorder.com/bbs2/index.php
--
-- NOTE:
-- Best viewed with TABs set to 4
-- TODO items are marked with $$$
-- If you're editing this file, make sure your editor supports UTF-8 !!!
-- ----------------------------------------------

TTMP = {
	DisplayVersion		= "3.5.1",
	Author				= "SirAndy",
	SaveVersion			= 1,
	SavedVars			= {},
	sCurZone			= "",
	sCurMap				= "",
	sCurAction			= "",
	sCurNode			= "",
	iCurType			= 0,
	sCurLanguage		= "en",
	sCurUser			= "@Unknown",
	sCurChar			= "Player",
	dMinDistance		= 0.0000010000,
	isMerging			= false,
	isActive			= false,
	useAutoLoot			= false,
	isLoading			= true,
	hasOldData			= false,
	hasNewData			= false,
	ASSETS				= nil,
	iInteractMillis		= 0,
	supportedHMSave		= 17,
	is_viewing_map		= false
}

-- ----------------------------------------------
-- Load dependency Libs
-- ----------------------------------------------
local LMP = LibMapPins
local LAM = LibAddonMenu2
if not LMP then
	errPrint("LibMapPins not loaded! Shutting down TTMP ...")
	return
end
if not LAM then
	errPrint("LibAddonMenu2 not loaded! Shutting down TTMP ...")
	return
end

-- ----------------------------------------------
-- GLOBAL constants
-- ----------------------------------------------
TTMP_COL_WHITE			= ZO_ColorDef:New("FFFFFF")
TTMP_COL_RED			= ZO_ColorDef:New("FF0000")
TTMP_COL_GREEN			= ZO_ColorDef:New("00FF00")
TTMP_COL_BLUE			= ZO_ColorDef:New("0000FF")
TTMP_COL_LIGHT_BLUE		= ZO_ColorDef:New("828EFD")
TTMP_COL_MAGENTA		= ZO_ColorDef:New("FF0088")
TTMP_COL_YELLOW			= ZO_ColorDef:New("F0C300")

-- ----------------------------------------------
-- GLOBAL variables, declared local for speed
-- ----------------------------------------------
local TTMP_LAST_UPDATE			= 0
local TTMP_UPDATE_FREQUENCY		= 200
local TTMP_INTERACT_TIMEOUT		= 2000
local TTMP_CHAT_PREFIX			= "|cF0C300TTMP: |r"

local TTMP_ASSET_NAMES = {
	"ore", "wood", "cloth", "water", "rune", "reagent", "chest", "backpack", "heavysack",
	"treasuremap", "fissure", "fishing", "skyshard", "lorebook", "quest", "survey",
	"points", "trove", "safebox", "clam", "site"
}

local TTMP_ASSET_LABELS = {
	"Metalworking Pins", "Woodworking Pins", "Clothier Pins", "Solvent Pins", "Enchanting Pins",
	"Alchemy Pins", "Locked Chest Pins", "Backpack Pins", "Heavy Sack/Crate Pins", "Treasure Map Pins",
	"Dark Fissure Pins", "Fishing Hole Pins", "Skyshard Pins", "Lorebook Pins", "Quest Pins",
	"Crafting Survey Pins", "Point of Interest", "Thieves Trove", "Safebox", "Giant Clam", "Dig Site"
}

local TTMP_ASSET_TOOLTIP = {
	"Blacksmithing Node", "Woodworking Node", "Clothing Node", "Solvent Node", "Enchanting Rune",
	"Alchemy Node", "Treasure Chest", "Backpack", "Heavy Sack/Crate", "Treasure Map",
	"Dark Fissure", "Fishing Hole", "Skyshard", "Lorebook", "Quest", "Crafting Survey", "POI",
	"Thieves Trove", "Safebox", "Giant Clam", "Dig Site"
}

local TTMP_ASSET_NAMES_LANG = {
	["en"] = {
		"ore", "wood", "cloth", "water", "rune", "reagent", "chest", "backpack", "heavysack",
		"treasuremap", "fissure", "fishing", "skyshard", "lorebook", "quest", "survey",
		"points", "trove", "safebox", "clam", "site"
	},
	["de"] = {
		"ore", "wood", "cloth", "water", "rune", "reagent", "chest", "backpack", "heavysack",
		"treasuremap", "fissure", "fishing", "skyshard", "lorebook", "quest", "survey",
		"points", "trove", "safebox", "clam", "site"
	},
	["fr"] = {
		"ore", "wood", "cloth", "water", "rune", "reagent", "chest", "backpack", "heavysack",
		"treasuremap", "fissure", "fishing", "skyshard", "lorebook", "quest", "survey",
		"points", "trove", "safebox", "clam", "site"
	},
	["ru"] = {
		"руда", "древесина", "ткань", "вода", "руна", "реагент", "сундук", "рюкзак", "тяжелый мешок",
		"карта сокровищ", "разлом", "рыбалка", "небесный осколок", "книга знаний", "задание", "исследование",
		"точка", "тайник", "сейф", "clam", "site"
	},
	["jp"] = {
		"ore", "wood", "cloth", "water", "rune", "reagent", "chest", "backpack", "heavysack",
		"treasuremap", "fissure", "fishing", "skyshard", "lorebook", "quest", "survey",
		"points", "trove", "safebox", "clam", "site"
	},
}

local TTMP_ASSET_LABELS_LANG = {
	["en"] = {
		"Metalworking Pins", "Woodworking Pins", "Clothier Pins", "Solvent Pins", "Enchanting Pins",
		"Alchemy Pins", "Locked Chest Pins", "Backpack Pins", "Heavy Sack/Crate Pins", "Treasure Map Pins",
		"Dark Fissure Pins", "Fishing Hole Pins", "Skyshard Pins", "Lorebook Pins", "Quest Pins",
		"Crafting Survey Pins", "Point of Interest", "Thieves Trove", "Safebox", "Giant Clam", "Dig Site"
	},
	["de"] = {
		"Metalworking Pins", "Woodworking Pins", "Clothier Pins", "Solvent Pins", "Enchanting Pins",
		"Alchemy Pins", "Locked Chest Pins", "Backpack Pins", "Heavy Sack/Crate Pins", "Treasure Map Pins",
		"Dark Fissure Pins", "Fishing Hole Pins", "Skyshard Pins", "Lorebook Pins", "Quest Pins",
		"Crafting Survey Pins", "Point of Interest", "Thieves Trove", "Safebox", "Giant Clam", "Dig Site"
	},
	["fr"] = {
		"Metalworking Pins", "Woodworking Pins", "Clothier Pins", "Solvent Pins", "Enchanting Pins",
		"Alchemy Pins", "Locked Chest Pins", "Backpack Pins", "Heavy Sack/Crate Pins", "Treasure Map Pins",
		"Dark Fissure Pins", "Fishing Hole Pins", "Skyshard Pins", "Lorebook Pins", "Quest Pins",
		"Crafting Survey Pins", "Point of Interest", "Thieves Trove", "Safebox", "Giant Clam", "Dig Site"
	},
	["ru"] = {
		"Кузнечные значки", "Столярные значки", "Портняжные значки", "Значки растворителей", "Значки зачарования",
		"Алхимические значки", "Значки сундуков", "Значки рюкзаков", "Значки тяжёлых мешков/ящиков", "Значки карт сокровищ",
		"Значки темных разломов", "Значки рыбных мест", "Значки небесных осколков", "Значки книг знаний", "Значки заданий",
		"Значки ремесленных исследований", "Точки интереса", "Воровские тайники", "Сейфы", "Giant Clam", "Dig Site"
	},
	["jp"] = {
		"Metalworking Pins", "Woodworking Pins", "Clothier Pins", "Solvent Pins", "Enchanting Pins",
		"Alchemy Pins", "Locked Chest Pins", "Backpack Pins", "Heavy Sack/Crate Pins", "Treasure Map Pins",
		"Dark Fissure Pins", "Fishing Hole Pins", "Skyshard Pins", "Lorebook Pins", "Quest Pins",
		"Crafting Survey Pins", "Point of Interest", "Thieves Trove", "Safebox", "Giant Clam", "Dig Site"
	},
}

local TTMP_ASSET_TOOLTIP_LANG = {
	["en"] = {
		"Blacksmithing Node", "Woodworking Node", "Clothing Node", "Solvent Node", "Enchanting Rune",
		"Alchemy Node", "Treasure Chest", "Backpack", "Heavy Sack/Crate", "Treasure Map",
		"Dark Fissure", "Fishing Hole", "Skyshard", "Lorebook", "Quest", "Crafting Survey", "POI",
		"Thieves Trove", "Safebox", "Giant Clam", "Dig Site"
	},
	["de"] = {
		"Blacksmithing Node", "Woodworking Node", "Clothing Node", "Solvent Node", "Enchanting Rune",
		"Alchemy Node", "Treasure Chest", "Backpack", "Heavy Sack/Crate", "Treasure Map",
		"Dark Fissure", "Fishing Hole", "Skyshard", "Lorebook", "Quest", "Crafting Survey", "POI",
		"Thieves Trove", "Safebox", "Giant Clam", "Dig Site"
	},
	["fr"] = {
		"Blacksmithing Node", "Woodworking Node", "Clothing Node", "Solvent Node", "Enchanting Rune",
		"Alchemy Node", "Treasure Chest", "Backpack", "Heavy Sack/Crate", "Treasure Map",
		"Dark Fissure", "Fishing Hole", "Skyshard", "Lorebook", "Quest", "Crafting Survey", "POI",
		"Thieves Trove", "Safebox", "Giant Clam", "Dig Site"
	},
	["ru"] = {
		"Кузнечный ресурс", "Столярный ресурс", "Портняжный ресурс", "Ресурс растворителей", "Руна зачарования",
		"Алхимический ресурс", "Сундук сокровищ", "Рюкзак", "Тяжёлый мешок/Ящик", "Карта сокровищ",
		"Темный разлом", "Рыбное место", "Небесный осколок", "Книга знаний", "Задание", "Ремесленное исследование", "Точка интереса",
		"Воровской тайник", "Сейф", "Giant Clam", "Dig Site"
	},
	["jp"] = {
		"Blacksmithing Node", "Woodworking Node", "Clothing Node", "Solvent Node", "Enchanting Rune",
		"Alchemy Node", "Treasure Chest", "Backpack", "Heavy Sack/Crate", "Treasure Map",
		"Dark Fissure", "Fishing Hole", "Skyshard", "Lorebook", "Quest", "Crafting Survey", "POI",
		"Thieves Trove", "Safebox", "Giant Clam", "Dig Site"
	},
}

-- An Enum of sorts, easier to do this manually
local TTMP_ASSET_NONE		= 0
local TTMP_ASSET_ORE		= 1		-- Ore Nodes
local TTMP_ASSET_WOOD		= 2		-- Wood Nodes
local TTMP_ASSET_CLOTH		= 3		-- Cloth/Plant Nodes
local TTMP_ASSET_SOLVENT	= 4		-- Solvent/Water Nodes
local TTMP_ASSET_RUNE		= 5		-- Runestone Nodes
local TTMP_ASSET_REAGENT	= 6		-- Reagent/Herb Nodes
local TTMP_ASSET_CHEST		= 7		-- Tresure Chests
local TTMP_ASSET_BACKPACK	= 8		-- Backpacks
local TTMP_ASSET_HEAVYSACK	= 9		-- Heavy Sacks
local TTMP_ASSET_MAP		= 10	-- Treasure Maps
local TTMP_ASSET_FISSURE	= 11	-- Dark Fissures (Mini Anchors)
local TTMP_ASSET_FISHING	= 12	-- Fishing Spots
local TTMP_ASSET_SKYSHARD	= 13	-- Skyshards
local TTMP_ASSET_LOREBOOK	= 14	-- Lore Books
local TTMP_ASSET_QUEST		= 15	-- Quests
local TTMP_ASSET_SURVEY		= 16	-- Crafting Surveys
local TTMP_ASSET_POI		= 17	-- Point of Interest
local TTMP_ASSET_TROVE		= 18	-- Thieves Trove
local TTMP_ASSET_SAFEBOX	= 19	-- Safebox
local TTMP_ASSET_GIANT_CLAM	= 20	-- Giant Clam
local TTMP_ASSET_DIG_SITE	= 21	-- Dig Site
local TTMP_ASSET_COUNT		= 21

-- NOTE: "Collect" exists here twice because 2 different words are used in french!
local TTMP_ACTION_LANG = {
	["en"] = {
		"Mine", "Cut", "Collect", "Collect", "Steal", "Steal From", "Search", "Use", "Unlock",
		"Open", "Loot"
	},
	["de"] = {
		"Abbauen", "Hacken", "Nehmen", "Nehmen", "Stehlen", "Inhalt stehlen", "Durchsuchen",
		"Benutzen", "Aufschließen", "Öffnen", "Erbeuten"
	},
	["fr"] = {
		"Extraire", "Couper", "Ramasser", "Récolter", "Piller", "Piller", "Fouiller", "Utiliser",
		"Déverrouiller", "Ouvrir", "Ramasser"
	},
	["ru"] = {
		"Добывать", "Рубить", "Собрать", "Собрать", "Украсть", "Обшарить", "Обыскать", "Использовать",
		"Открыть замок", "Открыть", "Loot"
	},
	["jp"] = {
		"Mine", "Cut", "Collect", "Collect", "Steal", "Steal From", "Search", "Use", "Unlock",
		"Open", "Loot"
	},
}

-- Containers one can interact with
local TTMP_ASSET_LANG = {
	["en"] = {
		"Chest", "Backpack", "Heavy Sack", "Heavy Crate", "Thieves Trove", "Safebox",
		"Giant Clam", "Psijic Portal"
	},
	["de"] = {
		"Truhe", "Rucksack", "Schwerer Sack", "Schwere Kiste", "Diebesgut", "Wertkassette",
		"Giant Clam", "Psijik-Portal"
	},
	["fr"] = {
		"Coffre", "Sac à dos", "Sac lourd", "Caisse pesante", "Trésor des voleurs", "Cassette",
		"Giant Clam", "Portail psijique"
	},
	["ru"] = {
		"Сундук", "Рюкзак", "Тяжелый мешок", "Тяжелый ящик", "Воровской тайник", "Сейф",
		"Giant Clam", "Psijic Portal"
	},
	["jp"] = {
		"Chest", "Backpack", "Heavy Sack", "Heavy Crate", "Thieves Trove", "Safebox",
		"Giant Clam", "Psijic Portal"
	},
}

local TTMP_LANG_ACTION_MINE			= 1
local TTMP_LANG_ACTION_CUT			= 2
local TTMP_LANG_ACTION_COLLECT		= 3
local TTMP_LANG_ACTION_COLLECT_FR	= 4
local TTMP_LANG_ACTION_STEAL		= 5
local TTMP_LANG_ACTION_STEAL_FROM	= 6
local TTMP_LANG_ACTION_SEARCH		= 7
local TTMP_LANG_ACTION_USE			= 8
local TTMP_LANG_ACTION_UNLOCK		= 9
local TTMP_LANG_ACTION_OPEN			= 10
local TTMP_LANG_ACTION_LOOT			= 11

local TTMP_LANG_ASSET_CHEST			= 1
local TTMP_LANG_ASSET_BACKPACK		= 2
local TTMP_LANG_ASSET_HEAVY_SACK	= 3
local TTMP_LANG_ASSET_HEAVY_CRATE	= 4
local TTMP_LANG_ASSET_THIEVES_TROVE	= 5
local TTMP_LANG_ASSET_SAFEBOX		= 6
local TTMP_LANG_ASSET_GIANT_CLAM	= 7
local TTMP_LANG_ASSET_PSIJIC_PORTAL	= 8

local TTMP_PIN_TYPE_TTMP			= 1
local TTMP_PIN_TYPE_ESO				= 2
local TTMP_CUR_PIN_TYPE				= TTMP_PIN_TYPE_ESO

local TTMP_MAP_MIN_DIST_AVA			= 0.0000010000
local TTMP_MAP_MIN_DIST_ZONE		= 0.0000020000
local TTMP_MAP_MIN_DIST_SUBZONE		= 0.0000400000
local TTMP_MAP_MIN_DIST_DUNGEON		= 0.0002000000
local TTMP_MAP_MIN_DIST_BATTLEG		= 0.0002000000

local TTMP_ASSET_PINS = {
	[TTMP_PIN_TYPE_TTMP] = {
		 [1] = { level = 200, texture = "TamrielMapping/icons/ore.dds",				size = 16, tint = TTMP_COL_WHITE },
		 [2] = { level = 200, texture = "TamrielMapping/icons/wood.dds",			size = 16, tint = TTMP_COL_WHITE },
		 [3] = { level = 200, texture = "TamrielMapping/icons/cloth.dds",			size = 16, tint = TTMP_COL_WHITE },
		 [4] = { level = 200, texture = "TamrielMapping/icons/water.dds",			size = 16, tint = TTMP_COL_WHITE },
		 [5] = { level = 201, texture = "TamrielMapping/icons/rune.dds",			size = 16, tint = TTMP_COL_WHITE },
		 [6] = { level = 200, texture = "TamrielMapping/icons/reagent.dds",			size = 16, tint = TTMP_COL_WHITE },
		 [7] = { level = 230, texture = "TamrielMapping/icons/chest.dds",			size = 16, tint = TTMP_COL_WHITE },
		 [8] = { level = 201, texture = "TamrielMapping/icons/backpack.dds",		size = 16, tint = TTMP_COL_WHITE },
		 [9] = { level = 201, texture = "TamrielMapping/icons/heavysack.dds",		size = 16, tint = TTMP_COL_WHITE },
		[10] = { level = 202, texture = "TamrielMapping/icons/treasuremap.dds",		size = 16, tint = TTMP_COL_WHITE },
		[11] = { level = 202, texture = "TamrielMapping/icons/fissure.dds",			size = 16, tint = TTMP_COL_WHITE },
		[12] = { level = 200, texture = "TamrielMapping/icons/fishing.dds",			size = 16, tint = TTMP_COL_WHITE },
		[13] = { level = 205, texture = "TamrielMapping/icons/skyshard.dds",		size = 16, tint = TTMP_COL_WHITE },
		[14] = { level = 210, texture = "TamrielMapping/icons/lorebook.dds",		size = 16, tint = TTMP_COL_WHITE },
		[15] = { level = 215, texture = "TamrielMapping/icons/quest.dds",			size = 16, tint = TTMP_COL_WHITE },
		[16] = { level = 202, texture = "TamrielMapping/icons/survey.dds",			size = 16, tint = TTMP_COL_WHITE },
		[17] = { level = 211, texture = "TamrielMapping/icons/point.dds",			size = 16, tint = TTMP_COL_WHITE },
		[18] = { level = 230, texture = "TamrielMapping/icons/chest.dds",			size = 16, tint = TTMP_COL_WHITE },
		[19] = { level = 230, texture = "TamrielMapping/icons/chest.dds",			size = 16, tint = TTMP_COL_WHITE },
		[20] = { level = 211, texture = "TamrielMapping/icons/clam.dds",			size = 16, tint = TTMP_COL_WHITE },
		[20] = { level = 211, texture = "TamrielMapping/icons/clam.dds",			size = 16, tint = TTMP_COL_WHITE },
		[21] = { level = 202, texture = "TamrielMapping/icons/survey.dds",			size = 16, tint = TTMP_COL_WHITE },
	},
	-- NOTE: index is misspelled on Icon [12]!!!
	[TTMP_PIN_TYPE_ESO] = {
		 [1] = { level = 200, texture = "/esoui/art/inventory/inventory_tabicon_crafting_down.dds",			size = 24, tint = TTMP_COL_WHITE },
		 [2] = { level = 200, texture = "/esoui/art/inventory/inventory_tabicon_crafting_down.dds",			size = 24, tint = TTMP_COL_WHITE },
		 [3] = { level = 200, texture = "/esoui/art/inventory/inventory_tabicon_crafting_down.dds",			size = 24, tint = TTMP_COL_WHITE },
		 [4] = { level = 200, texture = "/esoui/art/inventory/inventory_tabicon_consumables_down.dds",		size = 24, tint = TTMP_COL_WHITE },
		 [5] = { level = 201, texture = "/esoui/art/inventory/inventory_tabicon_crafting_down.dds",			size = 24, tint = TTMP_COL_WHITE },
		 [6] = { level = 200, texture = "/esoui/art/inventory/inventory_tabicon_consumables_down.dds",		size = 24, tint = TTMP_COL_WHITE },
		 [7] = { level = 230, texture = "/esoui/art/guild/guild_tradinghouseaccess.dds",					size = 16, tint = TTMP_COL_WHITE },
		 [8] = { level = 201, texture = "/esoui/art/mainmenu/menubar_inventory_down.dds",					size = 24, tint = TTMP_COL_WHITE },
		 [9] = { level = 201, texture = "/esoui/art/mainmenu/menubar_inventory_down.dds",					size = 24, tint = TTMP_COL_WHITE },
		[10] = { level = 202, texture = "/esoui/art/journal/journal_tabicon_cadwell_down.dds",				size = 24, tint = TTMP_COL_WHITE },
		[11] = { level = 202, texture = "/esoui/art/inventory/inventory_tabicon_weapons_down.dds",			size = 24, tint = TTMP_COL_WHITE },
		[12] = { level = 200, texture = "/esoui/art/treeicons/tutorial_idexicon_fishing_down.dds",			size = 24, tint = TTMP_COL_WHITE },
		[13] = { level = 205, texture = "/esoui/art/treeicons/achievements_indexicon_skyshards_down.dds",	size = 24, tint = TTMP_COL_WHITE },
		[14] = { level = 210, texture = "/esoui/art/mainmenu/menubar_journal_down.dds",						size = 24, tint = TTMP_COL_WHITE },
		[15] = { level = 215, texture = "/esoui/art/mainmenu/menubar_notifications_down.dds",				size = 24, tint = TTMP_COL_WHITE },
		[16] = { level = 202, texture = "/esoui/art/journal/journal_tabicon_cadwell_down.dds",				size = 24, tint = TTMP_COL_WHITE },
		[17] = { level = 211, texture = "/esoui/art/inventory/newitem_icon.dds",							size = 24, tint = TTMP_COL_WHITE },
		[18] = { level = 230, texture = "/esoui/art/guild/guild_tradinghouseaccess.dds",					size = 16, tint = TTMP_COL_WHITE },
		[19] = { level = 230, texture = "/esoui/art/guild/guild_tradinghouseaccess.dds",					size = 16, tint = TTMP_COL_WHITE },
		[20] = { level = 211, texture = "/esoui/art/treeicons/store_indexicon_vanitypets_up.dds",			size = 32, tint = TTMP_COL_WHITE },
		[21] = { level = 202, texture = "/esoui/art/journal/journal_tabicon_cadwell_down.dds",				size = 24, tint = TTMP_COL_WHITE },
	},
}

-- Default options and icon colors
local TTMP_MENU_OPTIONS = {
	["ShowItems"] = true,
	["ShowLoot"] = false,
	["ShowGroupLoot"] = false,
	["ShowLootIDs"] = false,
	["ShowLootCount"] = false,
	["ShowLootTrait"] = false,
	["ShowDebug"] = false,
	["DeleteAssets"] = false,
	["IconsToUse"] = "ESO Built-In Icons",
	["IconColors"] = {
		 [1] = "0.741176|0.596078|0.200000|",
		 [2] = "0.647059|0.368627|0.094118|",
		 [3] = "0.258824|0.631373|0.243137|",
		 [4] = "0.286275|0.462745|1.000000|",
		 [5] = "1.000000|0.372549|0.000000|",
		 [6] = "0.415686|1.000000|0.325490|",
		 [7] = "1.000000|0.000000|0.427451|",
		 [8] = "0.749020|0.400000|0.000000|",
		 [9] = "0.039216|0.588235|0.003922|",
		[10] = "1.000000|0.933333|0.003922|",
		[11] = "1.000000|0.015686|0.000000|",
		[12] = "0.345098|0.329412|1.000000|",
		[13] = "0.000000|0.854902|1.000000|",
		[14] = "0.603922|0.000000|1.000000|",
		[15] = "1.000000|0.835294|0.000000|",
		[16] = "0.098039|0.733333|0.000000|",
		[17] = "1.000000|1.000000|1.000000|",
		[18] = "1.000000|0.882353|0.000000|",
		[19] = "0.164706|1.000000|0.000000|",
		[20] = "0.000000|0.976471|1.000000|",
		[21] = "0.286275|0.462745|1.000000|",
	},
}

-- Default map icon filters
local TTMP_MAP_FILTERS = {
	["TTMP_Pin1"] = false,
	["TTMP_Pin2"] = false,
	["TTMP_Pin3"] = false,
	["TTMP_Pin4"] = false,
	["TTMP_Pin5"] = false,
	["TTMP_Pin6"] = false,
	["TTMP_Pin7"] = true,
	["TTMP_Pin8"] = true,
	["TTMP_Pin9"] = true,
	["TTMP_Pin10"] = true,
	["TTMP_Pin11"] = true,
	["TTMP_Pin12"] = true,
	["TTMP_Pin13"] = true,
	["TTMP_Pin14"] = true,
	["TTMP_Pin15"] = true,
	["TTMP_Pin16"] = true,
	["TTMP_Pin17"] = true,
	["TTMP_Pin18"] = true,
	["TTMP_Pin19"] = true,
	["TTMP_Pin20"] = true,
	["TTMP_Pin21"] = false,
}

local TTMP_MAP_TYPES = {
	[0] = "MAPTYPE_NONE",
	[1] = "MAPTYPE_SUBZONE",
	[2] = "MAPTYPE_ZONE",
	[3] = "MAPTYPE_WORLD",
	[4] = "MAPTYPE_DEPRECATED_1",
	[5] = "MAPTYPE_COSMIC",
}

local TTMP_MAP_CONTENT_TYPES = {
	[0] = "MAP_CONTENT_NONE",
	[1] = "MAP_CONTENT_AVA",
	[2] = "MAP_CONTENT_DUNGEON",
	[3] = "MAP_CONTENT_BATTLEGROUND",
}

local TTMP_ASSET_IDS = {
	[1] = {																	-- "Mine"		Ore
		  808,   4482,   5820,  23103,  23104,  23105,  23133,  23134,  23135,
		71198, 114889, 135137, 135139, 135141, 135143, 135145, 135161, 139416
	},
	[2] = {																	-- "Cut"		Wood
		  521,    802,    818,   4439,  23117,  23118,  23119,  23137,  23138,
		71199, 114895
	},
	[3] = {																	-- "Collect"	Cloth
		  812,   4464,  23129,  23130,  23131,  33217,  33218,  33219,  33220,
		71200, 114890
	},
	[4] = {																	-- "Collect"	Water/Solvent
		  883,   1187,   4570,  23265,  23266,  23267,  23268,  64500,  64501
	},
	[5] = {																	-- "Collect"	Runes
		45806,  45807,  45808,  45809,  45810,  45811,  45812,  45813,  45814,
		45815,  45816,  45817,  45818,  45819,  45820,  45821,  45822,  45823,
		45824,  45825,  45826,  45827,  45828,  45829,  45830,  45831,  45832,
		45833,  45834,  45835,  45836,  45837,  45838,  45839,  45840,  45841,
		45842,  45843,  45844,  45845,  45846,  45847,  45848,  45849,  45850,
		45851,  45852,  45853,  45854,  45855,  45856,  45857,  64508,  64509,
		68340,  68341,  68342, 114892
	},
	[6] = {																	-- "Collect"	Alchemy/Reagent
		30148,  30149,  30151,  30152,  30153,  30154,  30155,  30156,  30157,
		30158,  30159,  30160,  30161,  30162,  30163,  30164,  30165,  30166,
		77590, 114893, 150672
	},
}

local TTMP_HARVEST_MAP = {
	  [1] = TTMP_ASSET_ORE,			 [2] = TTMP_ASSET_CLOTH,		  [3] = TTMP_ASSET_RUNE,
	  [4] = TTMP_ASSET_REAGENT,		 [5] = TTMP_ASSET_WOOD,			  [6] = TTMP_ASSET_CHEST,
	  [7] = TTMP_ASSET_SOLVENT,		 [8] = TTMP_ASSET_NONE,			  [9] = TTMP_ASSET_HEAVYSACK,
	 [10] = TTMP_ASSET_TROVE,		[11] = TTMP_ASSET_SAFEBOX,		 [12] = TTMP_ASSET_NONE,
	 [13] = TTMP_ASSET_REAGENT,		[14] = TTMP_ASSET_REAGENT,		 [15] = TTMP_ASSET_GIANT_CLAM,
	 [16] = TTMP_ASSET_RUNE,		[17] = TTMP_ASSET_ORE,
	[100] = TTMP_ASSET_NONE,
}

local TTMP_INTERACTION_TYPES = {
	 [0] = "INTERACTION_NONE",				 [1] = "INTERACTION_STORE",					 [2] = "INTERACTION_LOOT",
	 [3] = "INTERACTION_QUEST",				 [4] = "INTERACTION_KEEP_INSPECT",			 [5] = "INTERACTION_KEEP_GUILD_CLAIM",
	 [6] = "INTERACTION_BANK",				 [7] = "INTERACTION_MAIL",					 [8] = "INTERACTION_FAST_TRAVEL_KEEP",
	 [9] = "INTERACTION_9",					[10] = "INTERACTION_10",					[11] = "INTERACTION_FAST_TRAVEL",
	[12] = "INTERACTION_BOOK",				[13] = "INTERACTION_13",					[14] = "INTERACTION_CONVERSATION",
	[15] = "INTERACTION_VENDOR",			[16] = "INTERACTION_AVA_HOOK_POINT",		[17] = "INTERACTION_STONE_MASON",
	[18] = "INTERACTION_GUILDKIOSK_BID",	[19] = "INTERACTION_BUY_BAG_SPACE",			[20] = "INTERACTION_LOCKPICK",
	[21] = "INTERACTION_KEEP_PIECE",		[22] = "INTERACTION_SIEGE",					[23] = "INTERACTION_CRAFT",
	[24] = "INTERACTION_FISH",				[25] = "INTERACTION_GUILDBANK",				[26] = "INTERACTION_TRADINGHOUSE",
	[27] = "INTERACTION_STABLE",			[28] = "INTERACTION_HARVEST",				[29] = "INTERACTION_KEEP_GUILD_RELEASE",
	[30] = "INTERACTION_PAY_BOUNTY",		[31] = "INTERACTION_DYE_STATION",			[32] = "INTERACTION_GUILDKIOSK_PURCHASE",
	[33] = "INTERACTION_PICKPOCKET",		[34] = "INTERACTION_HIDEYHOLE",				[35] = "INTERACTION_FURNITURE",
	[36] = "INTERACTION_RETRAIT",			[37] = "INTERACTION_SKILL_RESPEC",			[38] = "INTERACTION_ATTRIBUTE_RESPEC",
	[39] = "INTERACTION_TREASURE_MAP",		[40] = "INTERACTION_ANTIQUITY_DIG_SPOT",	[41] = "INTERACTION_ANTIQUITY_SCRYING",
}

-- ----------------------------------------------
-- Trim() whitespaces from a String
-- ----------------------------------------------
local function trim(s)
	local a = s:match('^%s*()')
	local b = s:match('()%s*$', a)
	return s:sub(a,b-1)
end

-- ----------------------------------------------
-- Split String by separator and return an array
-- ----------------------------------------------
local function split(s, sep)

	if (s == nil) then return nil end
	if (sep == nil) then sep = "%s" end

	s = trim(s)
	if (s == "") then return nil end

	local t = {}
	local i = 1
	for str in string.gmatch(s, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end

	return t
end

-- ----------------------------------------------
-- Print an info String to the console
-- ----------------------------------------------
local function infPrint(s)

	-- $$$ Check for the pChat AddOn
	-- If present, do *NOT* use nested chat color coding, otherwise ESO will crash and burn!
	if (not pChat) then
		d(TTMP_COL_LIGHT_BLUE:Colorize(s))
	else
		d(s)
	end
end

-- ----------------------------------------------
-- Print an error String to the console
-- ----------------------------------------------
local function errPrint(s)

	-- $$$ Check for the pChat AddOn
	-- If present, do *NOT* use nested chat color coding, otherwise ESO will crash and burn!
	if (not pChat) then
		d(TTMP_COL_RED:Colorize(string.format("TTMP.ERROR: %s",s)))
	else
		d(string.format("|cFF0000TTMP.ERROR:|r %s",s))
	end
end

-- ----------------------------------------------
-- Print a debug String to the console
-- ----------------------------------------------
local function dbgPrint(s)

	-- $$$ Check for the pChat AddOn
	-- If present, do *NOT* use nested chat color coding, otherwise ESO will crash and burn!
	if (not pChat) then
		d(TTMP_COL_YELLOW:Colorize(s))
	else
		d(s)
	end
end

-- ----------------------------------------------
-- Copy (shallow) all key,value pairs from one table to another
-- ----------------------------------------------
local function copyTable(t1, t2)

	if ((type(t1) ~= "table") or (type(t2) ~= "table")) then return end

	for k,v in pairs(t1) do
		t2[k] = v
	end
end

-- ----------------------------------------------
-- Delete all key,value pairs from a table
-- ----------------------------------------------
local function deleteTable(t1)

	if (type(t1) ~= "table") then return end

	for k,v in pairs(t1) do
		t1[k] = nil
	end
end

-- ----------------------------------------------
-- Dump a table to the console
-- ----------------------------------------------
local function dumpTable(t)

	d("> ")

	sType = string.format("(%s): ",type(t))
	sVals = string.format("%s",tostring(t))
	d(string.format("%s%s",sType,sVals))

	if type(t) == "table" then
		for k,v in pairs(t) do
			sType = string.format("(%s)(%s)k,v: ",type(k),type(v))
			sVals = string.format("%s = %s",tostring(k),tostring(v))
			d(string.format("%s%s",sType,sVals))
		end
	end
end

-- ----------------------------------------------
-- OnLoad()
-- ----------------------------------------------
function TTMP.OnLoad(eventCode, addOnName)
local iType, defaults, oNewColor
local r, g, b

	if addOnName ~= "TamrielMapping" then return end
	EVENT_MANAGER:UnregisterForEvent("TTMP_StartUp", EVENT_ADD_ON_LOADED)
	TTMP.isLoading = true

	defaults = {
		DisplayVersion = TTMP.DisplayVersion, SaveVersion = TTMP.SaveVersion,
		Author = TTMP.Author, MapFilters = TTMP_MAP_FILTERS, MenuOptions = TTMP_MENU_OPTIONS,
		Pintype = TTMP_CUR_PIN_TYPE, utf8 = "ŠîrÄñdÿ"
	}

	TTMP.sCurLanguage	= GetCVar("Language.2")
	TTMP.sCurUser		= GetDisplayName()
	TTMP.sCurChar		= GetUnitName("player")

	-- This ensures that our SavedVariables data tree is created if it doesn't already exists.
	-- The 'settings' section keeps settings on a per account basis.
	TTMP.SavedVars["settings"] = ZO_SavedVars:NewAccountWide("TamrielMapping_Vars", TTMP.SaveVersion, "settings", defaults)
	TTMP.SavedVars.settings.DisplayVersion = TTMP.DisplayVersion

	-- Check for older saved data and convert if needed
	-- NOTE:
	-- A user can have multiple accounts on the same PC which will create separate trees in the SavedVariables file
	-- which means we need to make sure we don't delete any other old trees until the user logs in with that account!

	-- Do we still have an old tree for the current user?
	if (_G["TamrielMapping_Vars"]["Default"][TTMP.sCurUser]["$AccountWide"]["assets"] ~= nil) then
		TTMP.hasOldData = true

		-- Try to load the old data
		TTMP.SavedVars["assets"] = _G["TamrielMapping_Vars"]["Default"][TTMP.sCurUser]["$AccountWide"]["assets"]
	end

	-- Do we have new data?
	if (_G["TamrielMapping_Vars"]["global_assets"] ~= nil) then
		TTMP.hasNewData = true

		-- Try to load the new data
		TTMP.SavedVars["global_assets"] = _G["TamrielMapping_Vars"]["global_assets"]
		TTMP.ASSETS = TTMP.SavedVars["global_assets"]
	end

	-- If we only have new data, nothing to see here, carry on
	if (TTMP.hasOldData) then

		-- If we have old and new data, we need to run a merge
		-- Moved to OnPlayerActivated()!
		if (TTMP.hasNewData) then

		-- If we only have old data, we simply copy it to the new location
		-- and then delete the old data
		else

			_G["TamrielMapping_Vars"]["global_assets"] = {}
			TTMP.SavedVars["global_assets"] = _G["TamrielMapping_Vars"]["global_assets"]
			TTMP.ASSETS = TTMP.SavedVars["global_assets"]
			copyTable(TTMP.SavedVars["assets"], TTMP.SavedVars["global_assets"])
		end
	end

	-- If we have neither, create empty asset store
	if ((not TTMP.hasOldData) and (not TTMP.hasNewData)) then
		_G["TamrielMapping_Vars"]["global_assets"] = {}
		TTMP.SavedVars["global_assets"] = _G["TamrielMapping_Vars"]["global_assets"]
		TTMP.ASSETS = TTMP.SavedVars["global_assets"]
	end

	-- Check if we have the meta data field, if not, create it
	if (nil == _G["TamrielMapping_Vars"]["ttmp_meta_data"]) then
		_G["TamrielMapping_Vars"]["ttmp_meta_data"] = {}
	end

	TTMP.OnMapChanged()
	CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", TTMP.OnMapChanged)

	-- Set the display options
	TTMP_CUR_PIN_TYPE				= TTMP.SavedVars.settings.Pintype
	TTMP_MENU_OPTIONS.ShowDebug		= TTMP.SavedVars.settings.MenuOptions.ShowDebug
	TTMP_MENU_OPTIONS.ShowItems		= TTMP.SavedVars.settings.MenuOptions.ShowItems
	TTMP_MENU_OPTIONS.ShowLoot		= TTMP.SavedVars.settings.MenuOptions.ShowLoot
	if not TTMP.SavedVars.settings.MenuOptions.ShowGroupLoot then
		TTMP.SavedVars.settings.MenuOptions["ShowGroupLoot"] = false
	end
	TTMP_MENU_OPTIONS.ShowGroupLoot	= TTMP.SavedVars.settings.MenuOptions.ShowGroupLoot
	if not TTMP.SavedVars.settings.MenuOptions.ShowLootIDs then
		TTMP.SavedVars.settings.MenuOptions["ShowLootIDs"] = false
	end
	TTMP_MENU_OPTIONS.ShowLootIDs	= TTMP.SavedVars.settings.MenuOptions.ShowLootIDs
	if not TTMP.SavedVars.settings.MenuOptions.ShowLootCount then
		TTMP.SavedVars.settings.MenuOptions["ShowLootCount"] = false
	end
	TTMP_MENU_OPTIONS.ShowLootCount	= TTMP.SavedVars.settings.MenuOptions.ShowLootCount
	if not TTMP.SavedVars.settings.MenuOptions.ShowLootTrait then
		TTMP.SavedVars.settings.MenuOptions["ShowLootTrait"] = false
	end
	TTMP_MENU_OPTIONS.ShowLootTrait	= TTMP.SavedVars.settings.MenuOptions.ShowLootTrait
	if not TTMP.SavedVars.settings.MenuOptions.DeleteAssets then
		TTMP.SavedVars.settings.MenuOptions["DeleteAssets"] = false
	end
	TTMP_MENU_OPTIONS.DeleteAssets	= TTMP.SavedVars.settings.MenuOptions.DeleteAssets
	TTMP_MENU_OPTIONS.IconsToUse	= TTMP.SavedVars.settings.MenuOptions.IconsToUse
	TTMP_MENU_OPTIONS.IconColors	= TTMP.SavedVars.settings.MenuOptions.IconColors

	for iType = 1, TTMP_ASSET_COUNT do
		r, g, b = TTMP_MENU_OPTIONS.IconColors[iType]:match("([^|]+)|([^|]+)|([^|]+)|")
		TTMP_ASSET_PINS[TTMP_PIN_TYPE_TTMP][iType].tint	= ZO_ColorDef:New(tonumber(r),tonumber(g),tonumber(b))
		TTMP_ASSET_PINS[TTMP_PIN_TYPE_ESO][iType].tint	= TTMP_ASSET_PINS[TTMP_PIN_TYPE_TTMP][iType].tint
	end

	EVENT_MANAGER:RegisterForEvent("TTMP_LootReceived",			EVENT_LOOT_RECEIVED,		TTMP.OnLootReceived)
	EVENT_MANAGER:RegisterForEvent("TTMP_LootMoneyReceived",	EVENT_MONEY_UPDATE,			TTMP.OnMoneyUpdate)
	EVENT_MANAGER:RegisterForEvent("TTMP_LootUpdate",			EVENT_LOOT_UPDATED,			TTMP.OnLootUpdate)
	EVENT_MANAGER:RegisterForEvent("TTMP_LootClosed",			EVENT_LOOT_CLOSED,			TTMP.OnLootClosed)
	EVENT_MANAGER:RegisterForEvent("TTMP_PlayerActivated",		EVENT_PLAYER_ACTIVATED,		TTMP.OnPlayerActivated)
	EVENT_MANAGER:RegisterForEvent("TTMP_PlayerDeactivated",	EVENT_PLAYER_DEACTIVATED,	TTMP.OnPlayerDeactivated)

	TTMP.InitMapPins()
	TTMP.InitMenu()
	TTMP.isLoading = false
end

-- ----------------------------------------------
-- OnLootClosed()
-- ----------------------------------------------
function TTMP.OnLootClosed()

	if TTMP_MENU_OPTIONS.ShowDebug then
		infPrint(string.format("TTMP.OnLootClosed(): %d, %s",TTMP.iCurType,TTMP_INTERACTION_TYPES[TTMP.iCurType]))
	end
	TTMP.InteractReset()
end

-- ----------------------------------------------
-- OnPlayerDeactivated()
-- ----------------------------------------------
function TTMP.OnPlayerDeactivated(eventCode)

	if TTMP_MENU_OPTIONS.ShowDebug then
		dbgPrint("TTMP.OnPlayerDeactivated(): Updating Asset counts ...")
	end

	-- Every time the player changes zones or logs out, we update the total counts in ttmp_meta_data
	local asset_count, zone_count = TTMP.CountAllAssets()

	if TTMP_MENU_OPTIONS.ShowDebug then
		dbgPrint("TTMP.CountAllAssets(): asset_count = " .. asset_count)
		dbgPrint("TTMP.CountAllAssets(): zone_count = " .. zone_count)
	end

	ttmp_meta = _G["TamrielMapping_Vars"]["ttmp_meta_data"]
	ttmp_meta["ttmp_asset_count"] = asset_count
	ttmp_meta["ttmp_zone_count"] = zone_count

end

-- ----------------------------------------------
-- OnPlayerActivated()
-- ----------------------------------------------
function TTMP.OnPlayerActivated(eventCode)

	if (TTMP.isLoading or TTMP.isActive) then return end
	TTMP.isActive = true

	-- Say hello ...
	infPrint(string.format(
		"%sAddOn loaded for |cFF0088%s|r",
		TTMP_CHAT_PREFIX,
		TTMP.sCurChar
	))

	infPrint(string.format(
		"%sType |cFFFFFF/ttmp|r for more info ...",
		TTMP_CHAT_PREFIX
	))

	-- Check language, default to "en" if not supported by TTMP
	if TTMP_ACTION_LANG[TTMP.sCurLanguage] == nil then
		errPrint(string.format(
			"%sLanguage '%s' not supported!",
			TTMP_CHAT_PREFIX,
			TTMP.sCurLanguage
		))
		errPrint(string.format(
			"%sAutomatic node mapping has been disabled due to lack of language support!",
			TTMP_CHAT_PREFIX
		))
		TTMP.sCurLanguage = "en"
	end

	if (TTMP.hasOldData) then
		local didProcess = false
		if (TTMP.hasNewData) then
			infPrint(TTMP_CHAT_PREFIX .. "> UPDATE: Merging saved data ...")
			didProcess = TTMP.MergeAssets(TTMP.SavedVars["assets"], "")
		else
			infPrint(TTMP_CHAT_PREFIX .. "> UPDATE: Converting saved data ...")
			didProcess = true
		end

		-- The merging/conversion is already done at this point, we proceed to delete the old "asset" table
		if (didProcess) then
			deleteTable(TTMP.SavedVars["assets"])

			local k,v,i,t
			t = _G["TamrielMapping_Vars"]["Default"][TTMP.sCurUser]["$AccountWide"]
			i = 1
			for k,v in pairs(t) do
				if (tostring(k) == "assets") then
					t[k] = nil
					table.remove(t, i)
					break
				end
				i = i + 1
			end

			infPrint(TTMP_CHAT_PREFIX .. "> Done!")
		else
			infPrint(TTMP_CHAT_PREFIX .. "> Had problems!")
		end
	end
end

-- ----------------------------------------------
-- OnUpdate()
-- ----------------------------------------------
function TTMP.OnUpdate(iTime)
local iNowMillis = GetFrameTimeMilliseconds()

	-- Update every TTMP_UPDATE_FREQUENCY milliseconds
	if ((iNowMillis - TTMP_LAST_UPDATE) < TTMP_UPDATE_FREQUENCY) then return end
	TTMP_LAST_UPDATE = iNowMillis

	-- Bail if we're still loading or if we're currently running a merge
	if (TTMP.isLoading) then return end
	if (TTMP.isMerging) then return end

	-- Get the current player to World/UI interaction
	TTMP.GetInteractionType()

	-- If we don't get any interaction within the timeout period, we force reset the interaction
	if (TTMP.iInteractMillis > 0) then
		if (TTMP.iCurType == INTERACTION_NONE) then
			if ((iNowMillis - TTMP.iInteractMillis) > TTMP_INTERACT_TIMEOUT) then
				TTMP.InteractReset()
			end
		end
	end

	TTMP.CheckMapChange()

end

-- ----------------------------------------------
-- GetInteractionType()
-- ----------------------------------------------
function TTMP.GetInteractionType()

	-- Get the current player to World/UI interaction
	local iInteractionType = GetInteractionType()

	-- Interaction types we're currently interested in
	-- INTERACTION_LOOT					2
	-- INTERACTION_LOCKPICK				20
	-- INTERACTION_HARVEST				28
	-- INTERACTION_ANTIQUITY_DIG_SPOT	40

	if (iInteractionType > INTERACTION_NONE) then
		if (TTMP.iCurType ~= iInteractionType) then
			TTMP.iCurType = iInteractionType
			if TTMP_MENU_OPTIONS.ShowDebug then
				infPrint(string.format("TTMP.GetInteractionType(): %d, %s",TTMP.iCurType,TTMP_INTERACTION_TYPES[TTMP.iCurType]))
			end

			-- Are we digging for treasure?
			if TTMP.iCurType == INTERACTION_ANTIQUITY_DIG_SPOT then
				TTMP.AddAsset(TTMP_ASSET_DIG_SITE)
			end
		end
	end

end

-- ----------------------------------------------
-- Check if the map has changed and update the current player zone location
-- ----------------------------------------------
function TTMP.CheckMapChange()

	local does_match = DoesCurrentMapMatchMapForPlayerLocation()
	if not does_match then
		TTMP.is_viewing_map = ZO_WorldMap_DidPlayerChooseCurrentMap()
		if not TTMP.is_viewing_map then
			SetMapToPlayerLocation()
			CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
		end
	end

end

-- ----------------------------------------------
-- OnMapChanged()
-- ----------------------------------------------
function TTMP.OnMapChanged()
local iMapType,iMapContentType,sTempZone,sMapName

	TTMP.is_viewing_map = ZO_WorldMap_DidPlayerChooseCurrentMap()
	-- infPrint(string.format("TTMP.is_viewing_map = %s", tostring(TTMP.is_viewing_map)))

	TTMP.sCurrentZone = TTMP.GetZoneName()
	if TTMP_MENU_OPTIONS.ShowDebug then
		dbgPrint("TTMP:OnMapChanged(): "..TTMP.sCurrentZone)
	end

	sMapName = GetMapName()
	iMapType = GetMapType()
	iMapContentType = GetMapContentType()
	TTMP.sCurMap = sMapName
	TTMP.dMinDistance = TTMP_MAP_MIN_DIST_ZONE

	-- Minimum distance to recognize assets as duplicates
	if (iMapType == MAPTYPE_SUBZONE) then
		TTMP.dMinDistance = TTMP_MAP_MIN_DIST_SUBZONE
	end
	if (iMapContentType == MAP_CONTENT_DUNGEON) then
		TTMP.dMinDistance = TTMP_MAP_MIN_DIST_DUNGEON
	end
	if (iMapContentType == MAP_CONTENT_AVA) then
		TTMP.dMinDistance = TTMP_MAP_MIN_DIST_AVA
	end
	if (iMapContentType == MAP_CONTENT_BATTLEGROUND) then
		TTMP.dMinDistance = TTMP_MAP_MIN_DIST_BATTLEG
	end

	if TTMP_MENU_OPTIONS.ShowDebug then
		dbgPrint(string.format("TTMP: sMapName = %s", sMapName))
		dbgPrint(string.format("TTMP: iMapType = %s", TTMP_MAP_TYPES[iMapType]))
		dbgPrint(string.format("TTMP: iMapContentType = %s", TTMP_MAP_CONTENT_TYPES[iMapContentType]))
		dbgPrint(string.format("TTMP: dMinDistance = %f", TTMP.dMinDistance))
	end

	-- No zone scaling info yet?
	if not TTMP.ASSETS[TTMP.sCurrentZone] then
		TTMP.ASSETS[TTMP.sCurrentZone] = {}
	end
	if not TTMP.ASSETS[TTMP.sCurrentZone]["MinDistance"] then
		TTMP.ASSETS[TTMP.sCurrentZone]["MinDistance"] = TTMP.dMinDistance
		if TTMP_MENU_OPTIONS.ShowDebug then
			dbgPrint(string.format("TTMP: Zone dMinDistance added!"))
		end
	end

end

-- ----------------------------------------------
-- OnMoneyUpdate()
-- ----------------------------------------------
function TTMP.OnMoneyUpdate(...)
local oArgs = {...}

	if TTMP_MENU_OPTIONS.ShowDebug then
		dbgPrint("TTMP:OnMoneyUpdate(): ")
	end

	local goldId = ""
	if (TTMP_MENU_OPTIONS.ShowLootIDs and (oArgs[1] ~= nil)) then
		goldId = string.format("%d, ", oArgs[1])
	end

	if (oArgs[2] ~= nil and oArgs[3] ~= nil) then
		local iNewGold = oArgs[2] - oArgs[3]

		if (TTMP_MENU_OPTIONS.ShowLoot or TTMP_MENU_OPTIONS.ShowDebug) then
			infPrint(string.format("TTMP.Loot():|cF0C300 |r%s%s%d", goldId, "Gold, ", iNewGold))
		end

		-- Need to check this here again because sometimes chests only have gold in them
		-- and don't trigger the OnLootUpdate() callback

		-- "Unlock" or "Use" Chest?
		if (TTMP.sCurNode == TTMP_ASSET_LANG[TTMP.sCurLanguage][TTMP_LANG_ASSET_CHEST]) then
			if (
				TTMP.sCurAction == TTMP_ACTION_LANG[TTMP.sCurLanguage][TTMP_LANG_ACTION_UNLOCK] or
				TTMP.sCurAction == TTMP_ACTION_LANG[TTMP.sCurLanguage][TTMP_LANG_ACTION_USE] or
				TTMP.sCurAction == TTMP_ACTION_LANG[TTMP.sCurLanguage][TTMP_LANG_ACTION_SEARCH]
			) then
				TTMP.AddAsset(TTMP_ASSET_CHEST)
			end
		end
	end

end

-- ----------------------------------------------
-- OnLootReceived()
--
-- This function is called for each individual piece of loot
-- ----------------------------------------------
function TTMP.OnLootReceived(eventCode,receivedBy,objectName,stackCount,soundCategory,lootType,lootedBySelf,isPickpocketLoot,questItemIcon,itemId)

	if TTMP_MENU_OPTIONS.ShowDebug then
		dbgPrint("TTMP:OnLootReceived(): ")
	end

	TTMP.GetInteractionType()

	local showPlayerloot	= TTMP_MENU_OPTIONS.ShowLoot
	local showGroupLoot		= TTMP_MENU_OPTIONS.ShowGroupLoot

	-- Always show loot when debugging
	if TTMP_MENU_OPTIONS.ShowDebug then
		showPlayerloot	= true
		showGroupLoot	= true
	end

	if showPlayerloot or showGroupLoot then

		local formattedPlayer	= ""
		local formattedTrait	= ""
		local lootID			= ""
		local lootCount			= ""

		-- Get the item trait if present
		if TTMP_MENU_OPTIONS.ShowLootTrait then
			local traitType = GetItemLinkTraitInfo(objectName)
			if (traitType ~= ITEM_TRAIT_TYPE_NONE) then
				formattedTrait = string.format(" |cFFFFFF(%s)|r", GetString("SI_ITEMTRAITTYPE", traitType))
			end
		end

		if TTMP_MENU_OPTIONS.ShowLootIDs then
			lootID = string.format("%d, ", itemId)
		end
		if TTMP_MENU_OPTIONS.ShowLootCount then
			lootCount = string.format(", %d", stackCount)
		end

		-- Looted by yourself?
		if lootedBySelf then
			if showPlayerloot then
				infPrint(string.format("TTMP.Loot():|cF0C300 |r%s%s%s%s", lootID, objectName, formattedTrait, lootCount))
			end

		-- Looted by your group members?
		else
			if showGroupLoot then
				local charName = LocalizeString("<<1>>", receivedBy)
				formattedPlayer = string.format(" |c828EFD[|H0:character:%s|h%s|h]|r", receivedBy, charName)
				infPrint(string.format("TTMP.Loot():|cF0C300 |r%s%s%s%s%s", lootID, objectName, formattedTrait, lootCount, formattedPlayer))
			end
		end

		if TTMP_MENU_OPTIONS.ShowDebug then
			dbgPrint(string.format("TTMP.Loot(): Action, Node = %s, %s",TTMP.sCurAction,TTMP.sCurNode))
			dbgPrint(string.format("TTMP.Loot(): Type = %d, %s", TTMP.iCurType, TTMP_INTERACTION_TYPES[TTMP.iCurType]))
		end
	end

	if (TTMP.sCurAction ~= "") then
		local didAdd = TTMP.InteractWithContainer()
		if not didAdd then
			didAdd = TTMP.InteractWithNode(itemId)
		end
	end

end

-- ----------------------------------------------
-- OnLootUpdate()
-- This is only called if auto-loot is turned OFF
-- ----------------------------------------------
function TTMP.OnLootUpdate()
local iNumItems

	if TTMP_MENU_OPTIONS.ShowDebug then
		dbgPrint("TTMP:OnLootUpdate(): ")
	end

	TTMP.GetInteractionType()

	iNumItems = GetNumLootItems()
	if TTMP_MENU_OPTIONS.ShowDebug then
		dbgPrint("> iNumItems = " .. iNumItems)
		dbgPrint(string.format("> iCurType = %d, %s",TTMP.iCurType,TTMP_INTERACTION_TYPES[TTMP.iCurType]))
	end

	if (TTMP.iCurType ~= INTERACTION_LOOT) then
		local didAdd = TTMP.InteractWithContainer()
		if not didAdd then
			if (iNumItems > 0) then
				local iLootIdx, iItemIdx
				for iLootIdx = 1, iNumItems do
					iItemIdx = GetLootItemInfo(iLootIdx)
					local sItemName, _, _, iItemID = ZO_LinkHandler_ParseLink( GetLootItemLink(iItemIdx) )
					iItemID = tonumber(iItemID)
					didAdd = TTMP.InteractWithNode(iItemID)
					if (didAdd) then break end
				end
			end
		end
	end
end

-- ----------------------------------------------
-- InteractReset()
-- ----------------------------------------------
function TTMP.InteractReset()

	TTMP.sCurAction			= ""
	TTMP.sCurNode			= ""
	TTMP.iCurType			= INTERACTION_NONE
	TTMP.iInteractMillis	= 0

	if TTMP_MENU_OPTIONS.ShowDebug then
		infPrint(string.format("TTMP.InteractReset(): %d, %s",TTMP.iCurType,TTMP_INTERACTION_TYPES[TTMP.iCurType]))
	end
end

-- ----------------------------------------------
-- InteractWithContainer()
-- ----------------------------------------------
function TTMP.InteractWithContainer()

	if TTMP_MENU_OPTIONS.ShowDebug then
		dbgPrint(string.format("TTMP.InteractWithContainer(): %s, %s",TTMP.sCurAction,TTMP.sCurNode))
		dbgPrint(string.format("TTMP.InteractWithContainer(): %d, %s",TTMP.iCurType,TTMP_INTERACTION_TYPES[TTMP.iCurType]))
	end

	-- "Chest"?
	if (TTMP.sCurNode == TTMP_ASSET_LANG[TTMP.sCurLanguage][TTMP_LANG_ASSET_CHEST]) then
		if (
			TTMP.sCurAction == TTMP_ACTION_LANG[TTMP.sCurLanguage][TTMP_LANG_ACTION_UNLOCK] or
			TTMP.sCurAction == TTMP_ACTION_LANG[TTMP.sCurLanguage][TTMP_LANG_ACTION_USE] or
			TTMP.sCurAction == TTMP_ACTION_LANG[TTMP.sCurLanguage][TTMP_LANG_ACTION_SEARCH]
		) then
			return TTMP.AddAsset(TTMP_ASSET_CHEST)
		end

	-- "Backpack"?
	elseif (TTMP.sCurNode == TTMP_ASSET_LANG[TTMP.sCurLanguage][TTMP_LANG_ASSET_BACKPACK]) then
		if (
			TTMP.sCurAction == TTMP_ACTION_LANG[TTMP.sCurLanguage][TTMP_LANG_ACTION_SEARCH] or
			TTMP.sCurAction == TTMP_ACTION_LANG[TTMP.sCurLanguage][TTMP_LANG_ACTION_STEAL] or
			TTMP.sCurAction == TTMP_ACTION_LANG[TTMP.sCurLanguage][TTMP_LANG_ACTION_STEAL_FROM]
		) then
			return TTMP.AddAsset(TTMP_ASSET_BACKPACK)
		end

	-- "Heavy Sack", "Heavy Crate"?
	elseif (
		(TTMP.sCurNode == TTMP_ASSET_LANG[TTMP.sCurLanguage][TTMP_LANG_ASSET_HEAVY_SACK]) or
		(TTMP.sCurNode == TTMP_ASSET_LANG[TTMP.sCurLanguage][TTMP_LANG_ASSET_HEAVY_CRATE])
	) then
		if (
			TTMP.sCurAction == TTMP_ACTION_LANG[TTMP.sCurLanguage][TTMP_LANG_ACTION_SEARCH] or
			TTMP.sCurAction == TTMP_ACTION_LANG[TTMP.sCurLanguage][TTMP_LANG_ACTION_STEAL] or
			TTMP.sCurAction == TTMP_ACTION_LANG[TTMP.sCurLanguage][TTMP_LANG_ACTION_STEAL_FROM] or
			TTMP.sCurAction == TTMP_ACTION_LANG[TTMP.sCurLanguage][TTMP_LANG_ACTION_OPEN]
		) then
			return TTMP.AddAsset(TTMP_ASSET_HEAVYSACK)
		end

	-- "Thieves Trove"?
	 elseif (TTMP.sCurNode == TTMP_ASSET_LANG[TTMP.sCurLanguage][TTMP_LANG_ASSET_THIEVES_TROVE]) then
		if (
			TTMP.sCurAction == TTMP_ACTION_LANG[TTMP.sCurLanguage][TTMP_LANG_ACTION_STEAL] or
			TTMP.sCurAction == TTMP_ACTION_LANG[TTMP.sCurLanguage][TTMP_LANG_ACTION_STEAL_FROM]
		) then
			return TTMP.AddAsset(TTMP_ASSET_TROVE)
		end

	-- "Safebox"?
	elseif (TTMP.sCurNode == TTMP_ASSET_LANG[TTMP.sCurLanguage][TTMP_LANG_ASSET_SAFEBOX]) then
		if (
			TTMP.sCurAction == TTMP_ACTION_LANG[TTMP.sCurLanguage][TTMP_LANG_ACTION_STEAL] or
			TTMP.sCurAction == TTMP_ACTION_LANG[TTMP.sCurLanguage][TTMP_LANG_ACTION_STEAL_FROM]
		) then
			return TTMP.AddAsset(TTMP_ASSET_SAFEBOX)
		end

	-- "Giant Clam"?
	elseif (TTMP.sCurNode == TTMP_ASSET_LANG[TTMP.sCurLanguage][TTMP_LANG_ASSET_GIANT_CLAM]) then
		if (
			TTMP.sCurAction == TTMP_ACTION_LANG[TTMP.sCurLanguage][TTMP_LANG_ACTION_USE]
		) then
			return TTMP.AddAsset(TTMP_ASSET_GIANT_CLAM)
		end

	-- "Psijic Portal"?
	-- NOTE: Psijic Portals share their spawn points with rune nodes!
	elseif (TTMP.sCurNode == TTMP_ASSET_LANG[TTMP.sCurLanguage][TTMP_LANG_ASSET_PSIJIC_PORTAL]) then
		if (
			TTMP.sCurAction == TTMP_ACTION_LANG[TTMP.sCurLanguage][TTMP_LANG_ACTION_LOOT]
		) then
			return TTMP.AddAsset(TTMP_ASSET_RUNE)
		end

	end

	return false
end

-- ----------------------------------------------
-- InteractWithNode()
-- ----------------------------------------------
function TTMP.InteractWithNode(iItemID)

	if TTMP_MENU_OPTIONS.ShowDebug then
		dbgPrint(string.format("TTMP.InteractWithNode(): %s, %s, %d",TTMP.sCurAction,TTMP.sCurNode,iItemID))
		dbgPrint(string.format("TTMP.InteractWithNode(): %d, %s",TTMP.iCurType,TTMP_INTERACTION_TYPES[TTMP.iCurType]))
	end

	-- "Mine" Ore?
	if (TTMP.sCurAction == TTMP_ACTION_LANG[TTMP.sCurLanguage][TTMP_LANG_ACTION_MINE]) then
		for i, id in ipairs(TTMP_ASSET_IDS[TTMP_ASSET_ORE]) do
			if (id == iItemID) then
				return TTMP.AddAsset(TTMP_ASSET_ORE)
			end
		end

	-- "Cut" Wood?
	elseif (TTMP.sCurAction == TTMP_ACTION_LANG[TTMP.sCurLanguage][TTMP_LANG_ACTION_CUT]) then
		for i, id in ipairs(TTMP_ASSET_IDS[TTMP_ASSET_WOOD]) do
			if (id == iItemID) then
				return TTMP.AddAsset(TTMP_ASSET_WOOD)
			end
		end

	-- "Collect" Cloth, Water/Solvent, Rune, Alchemy/Reagent?
	elseif (
		TTMP.sCurAction == TTMP_ACTION_LANG[TTMP.sCurLanguage][TTMP_LANG_ACTION_COLLECT] or
		TTMP.sCurAction == TTMP_ACTION_LANG[TTMP.sCurLanguage][TTMP_LANG_ACTION_COLLECT_FR]
	) then

		-- Cloth
		for i, id in ipairs(TTMP_ASSET_IDS[TTMP_ASSET_CLOTH]) do
			if (id == iItemID) then
				return TTMP.AddAsset(TTMP_ASSET_CLOTH)
			end
		end

		-- Alchemy/Reagent
		for i, id in ipairs(TTMP_ASSET_IDS[TTMP_ASSET_REAGENT]) do
			if (id == iItemID) then
				return TTMP.AddAsset(TTMP_ASSET_REAGENT)
			end
		end

		-- Rune
		for i, id in ipairs(TTMP_ASSET_IDS[TTMP_ASSET_RUNE]) do
			if (id == iItemID) then
				return TTMP.AddAsset(TTMP_ASSET_RUNE)
			end
		end

		-- Water/Solvent
		for i, id in ipairs(TTMP_ASSET_IDS[TTMP_ASSET_SOLVENT]) do
			if (id == iItemID) then
				return TTMP.AddAsset(TTMP_ASSET_SOLVENT)
			end
		end

	end

	return false
end

-- ----------------------------------------------
-- Remove all matches from the DELETED table
-- ----------------------------------------------
function TTMP.RemoveDeleted(sZone, px, py, iType)

	local oAssets = TTMP.ASSETS[sZone]["DELETED"]
	if (oAssets) then

		-- We need a larger radius for fishing holes and POIs
		local dScale = 1.0
		if ((iType == TTMP_ASSET_FISHING) or (iType == TTMP_ASSET_POI) or (iType == TTMP_ASSET_DIG_SITE)) then
			dScale = 4.0
		end
		local ttmpmin = TTMP.dMinDistance * dScale
		local oNewAssets = {}

		for key, item in ipairs(oAssets) do
			local x, y, t = item:match("([^|]+)|([^|]+)|?(.*)")

			if (iType == tonumber(t)) then
				local dx = tonumber(x) - px
				local dy = tonumber(y) - py
				local dist = (dx * dx) + (dy * dy)

				if (dist < ttmpmin) then
					if TTMP_MENU_OPTIONS.ShowDebug then
						dbgPrint(string.format("Remove Deleted Item dx,dy,dist = %f,%f,%f", dx, dy, dist))
					end
				else
					table.insert(oNewAssets, item)
				end
			else
				table.insert(oNewAssets, item)
			end
		end

		TTMP.ASSETS[sZone]["DELETED"] = oNewAssets
	end
end

-- ----------------------------------------------
-- Checks if the supplied node already exists in the table
-- ----------------------------------------------
function TTMP.IsDuplicate(oAssets, px, py, itp)
local x, y, o, dx, dy, dist, dScale, dmin, ttmpmin

	if TTMP_MENU_OPTIONS.ShowDebug then
		dbgPrint(string.format("TTMP.IsDuplicate(): px,py = %f,%f",px,py))
	end

	if (oAssets == nil) then return false, nil end

	-- We need a larger radius for fishing holes and POIs
	dScale = 1.0
	if ((itp == TTMP_ASSET_FISHING) or (itp == TTMP_ASSET_POI) or (iType == TTMP_ASSET_DIG_SITE)) then
		dScale = 4.0
	end
	ttmpmin = TTMP.dMinDistance * dScale

	dmin = 999999
	for key, item in ipairs(oAssets) do

		x, y, o = item:match("([^|]+)|([^|]+)|?(.*)")
		dx = tonumber(x) - px
		dy = tonumber(y) - py
		dist = (dx * dx) + (dy * dy)

		if (dist < dmin) then dmin = dist end

		if (dist < ttmpmin) then
			if TTMP_MENU_OPTIONS.ShowDebug then
				dbgPrint(string.format("Item dx,dy,dist = %f,%f,%f",dx,dy,dist))
			end
			return true, key
		end
	end

	if TTMP_MENU_OPTIONS.ShowDebug then
		dbgPrint(string.format("dmin = %f", dmin))
	end

	return false, nil
end

-- ----------------------------------------------
-- Checks if the supplied node already exists in the table
-- ----------------------------------------------
function TTMP.IsMergeDuplicate(oAssets,px,py,itp,mindist)
local x,y,o,dx,dy,dist,dScale,ttmpmin

	if (oAssets == nil) then return false, nil, "" end

	-- We need a larger radius for fishing holes and POIs
	dScale = 1.0
	if ((itp == TTMP_ASSET_FISHING) or (itp == TTMP_ASSET_POI) or (iType == TTMP_ASSET_DIG_SITE)) then
		dScale = 4.0
	end
	ttmpmin = mindist * dScale

	for key, item in ipairs(oAssets) do

		x, y, o = item:match("([^|]+)|([^|]+)|?(.*)")
		dx = tonumber(x) - px
		dy = tonumber(y) - py
		dist = (dx * dx) + (dy * dy)

		if (dist < ttmpmin) then
			o = o or ""
			return true, key, o
		end
	end

	return false, nil, ""
end

-- ----------------------------------------------
-- Get the name of the current zone
-- ----------------------------------------------
function TTMP.GetZoneName()
local sZoneName, sWorldName

	sZoneName = GetMapTileTexture()
	sZoneName = string.lower(sZoneName)
	sZoneName = string.gsub(sZoneName, "^.*maps/", "")
	sZoneName = string.gsub(sZoneName, "_%d+%.dds$", "")

	return sZoneName
end

-- ----------------------------------------------
-- Get the player zone and location
-- ----------------------------------------------
function TTMP.GetLocation()
local x, y

	if (TTMP.sCurrentZone == "") then
		TTMP.sCurrentZone = TTMP.GetZoneName()
	end
	x, y = GetMapPlayerPosition("player")
	return TTMP.sCurrentZone, x, y
end

-- ----------------------------------------------
-- Find the Asset type from a supplied name
-- ----------------------------------------------
function TTMP.AssetTypeFromName(sName)
local iType

	for iType = 1, TTMP_ASSET_COUNT do
		if (TTMP_ASSET_NAMES[iType] == sName) then
			return iType
		end
	end

	return 0
end

-- ----------------------------------------------
-- Find the Asset type from a supplied user input
-- ----------------------------------------------
function TTMP.AssetTypeFromInput(sNameIn)
local sName

	-- Map possible inputs to Asset Strings
	sName = string.lower(sNameIn)

	if (sName == "plant") then
		sName = "reagent"
	elseif (sName == "pack") then
		sName = "backpack"
	elseif ((sName == "sack") or (sName == "crate")) then
		sName = "heavysack"
	elseif (sName == "map") then
		sName = "treasuremap"
	elseif (sName == "fish") then
		sName = "fishing"
	elseif (sName == "shard") then
		sName = "skyshard"
	elseif (sName == "book") then
		sName = "lorebook"
	elseif ((sName == "poi") or (sName == "point")) then
		sName = "points"
	elseif (sName == "box") then
		sName = "safebox"
	elseif (sName == "clam") then
		sName = "clam"
	elseif (sName == "site") then
		sName = "site"
	end

	return TTMP.AssetTypeFromName(sName)
end

-- ----------------------------------------------
-- Add an asset to the current map at the current player location
-- ----------------------------------------------
function TTMP.AddAsset(iType, ...)
local sZone, x, y
local oArgs, sInfo, doReplace

	oArgs		= {...}
	sInfo		= oArgs[1]
	doReplace	= oArgs[2]
	sInfo		= sInfo or ""
	doReplace	= doReplace or false
	sZone, x, y	= TTMP.GetLocation()

	return TTMP.AddAssetZXY(iType, sZone, x, y, sInfo, doReplace, false)
end

-- ----------------------------------------------
-- Add an asset to the specified Zone at XY
-- ----------------------------------------------
function TTMP.AddAssetZXY(iType, sZone, x, y, ...)
local xyo, isNew, isDuplicate, sPinType
local oArgs, sInfo, doReplace, doForce, dupKey

	oArgs		= {...}
	sInfo		= oArgs[1]
	doReplace	= oArgs[2]
	doForce		= oArgs[3]

	sInfo		= sInfo or ""
	doReplace	= doReplace or false
	doForce		= doForce or false

	isNew		= false
	isDuplicate	= false

	-- New zone?
	if not TTMP.ASSETS[sZone] then
		TTMP.ASSETS[sZone] = {}
		isNew = true
	end

	-- No scaling info yet?
	if not TTMP.ASSETS[sZone]["MinDistance"] then
		TTMP.ASSETS[sZone]["MinDistance"] = TTMP.dMinDistance
	end

	-- New type for this zone?
	if not TTMP.ASSETS[sZone][TTMP_ASSET_NAMES[iType]] then
		TTMP.ASSETS[sZone][TTMP_ASSET_NAMES[iType]] = {}
		isNew = true
	end

	-- Check for duplicates
	if not isNew then
		isDuplicate, dupKey = TTMP.IsDuplicate(TTMP.ASSETS[sZone][TTMP_ASSET_NAMES[iType]], x, y, iType)
	end

	if not isDuplicate then

		-- Not a duplicate? Add it to the table ...
		xyo = string.format("%f|%f|%s", x, y, sInfo)
		table.insert(TTMP.ASSETS[sZone][TTMP_ASSET_NAMES[iType]], xyo)
		sPinType = "TTMP_Pin" .. iType
		LMP:RefreshPins(sPinType)

		if TTMP_MENU_OPTIONS.ShowItems then
			infPrint(string.format("TTMP:AddAsset(): [%s][%s]", sZone, TTMP_ASSET_NAMES[iType]))
		end

		-- Check against the deleted table and remove any matching entries for this new Asset
		TTMP.RemoveDeleted(sZone, x, y, iType)

	else

		-- Duplicate that needs to be replaced? Update the table ...
		if doReplace then
			if (dupKey ~= nil) then
				if (doForce) then

					xyo = string.format("%f|%f|%s", x, y, sInfo)
					TTMP.ASSETS[sZone][TTMP_ASSET_NAMES[iType]][dupKey] = xyo
					sPinType = "TTMP_Pin" .. iType
					LMP:RefreshPins(sPinType)

					if TTMP_MENU_OPTIONS.ShowItems then
						infPrint(string.format("TTMP:UpdateAsset(): [%s][%s]", sZone, TTMP_ASSET_NAMES[iType]))
					end

				else

					-- Only update if the new entry has additional info!
					if (sInfo ~= "") then
						xyo = string.format("%f|%f|%s", x, y, sInfo)
						TTMP.ASSETS[sZone][TTMP_ASSET_NAMES[iType]][dupKey] = xyo
						sPinType = "TTMP_Pin" .. iType
						LMP:RefreshPins(sPinType)

						if TTMP_MENU_OPTIONS.ShowItems then
							infPrint(string.format("TTMP:UpdateAsset(): [%s][%s]", sZone, TTMP_ASSET_NAMES[iType]))
						end
					else
						if TTMP_MENU_OPTIONS.ShowDebug then
							dbgPrint("TTMP:AddAsset(): Duplicate entry ignored! No new info ...")
						end
					end
				end
			end
		else
			if TTMP_MENU_OPTIONS.ShowDebug then
				dbgPrint("TTMP:AddAsset(): Duplicate entry ignored!")
			end
		end
	end

	return true
end

-- ----------------------------------------------
-- Parse the /ttmp slash commands
-- TTMP commands can either be complete words or two letter abbreviations
-- ----------------------------------------------
SLASH_COMMANDS["/ttmp"] = function(sCmdLine)
local didProcess, idx, sCmd, opt1
local iAssetType

	if TTMP_MENU_OPTIONS.ShowDebug then
		dbgPrint("TTMP: CMD(): "..sCmdLine)
	end

	-- Parse the command string and tokenize it
	-- NOTE: Doing this without split() allows for free text comments!
	sCmd	= ""
	opt1	= ""
	idx		= string.find(sCmdLine, " ")
	if (idx ~= nil) then
		sCmd = string.sub(sCmdLine, 0, (idx-1))
		opt1 = string.sub(sCmdLine, (idx+1))
	else
		sCmd = sCmdLine
	end
	didProcess = false

	if (sCmd ~= "") then

		sCmd = string.lower(sCmd)

		-- Try the Asset related commands first
		iAssetType = TTMP.AssetTypeFromInput(sCmd)
		if (iAssetType > 0) then
			didProcess = TTMP.AddAsset(iAssetType,opt1,true)
		end

		-- If that fails, try all the remaining commands
		if not didProcess then

			-- Print the current player location
			if (sCmd == "pos") then
				local oZone, x, y = TTMP.GetLocation()
				infPrint(string.format("TTMP: Player.xy = %f,%f",x,y))
				didProcess = true

			-- Save all TTMP assets to file
			elseif (sCmd == "save") then
				ReloadUI()
				didProcess = true

			-- Delete Asset
			elseif (sCmd == "del") then
				if (opt1 ~= "") then
					local iAssetType = TTMP.AssetTypeFromInput(opt1)
					TTMP.DeleteAssetAtPlayer(iAssetType)
				else
					errPrint("del: Missing Asset type!")
				end
				didProcess = true

			-- List Assets counts
			elseif (sCmd == "list") then
				TTMP.ListAssets(opt1)
				didProcess = true

			-- Merging assets from a updated SavedVariables file?
			elseif (sCmd == "merge") then

				if (TTMPMerge) then
					local oMa = nil

					infPrint("TTMP: TTMPMerge AddOn found!")

					-- Look for new file format first
					if (_G["TTMPMerge_Vars"]["global_assets"] ~= nil) then
						oMa = _G["TTMPMerge_Vars"]["global_assets"]

					-- If that fails, try to load old style assets
					else
						if (_G["TTMPMerge_Vars"]["Default"] ~= nil) then
							if (_G["TTMPMerge_Vars"]["Default"][TTMP.sCurUser] ~= nil) then
								if (_G["TTMPMerge_Vars"]["Default"][TTMP.sCurUser]["$AccountWide"]["assets"] ~= nil) then
									oMa = _G["TTMPMerge_Vars"]["Default"][TTMP.sCurUser]["$AccountWide"]["assets"]
								end
							end
						end
					end

					if (oMa ~= nil) then
						TTMP.MergeAssets(oMa, opt1)
					else
						errPrint("TTMPMerge Error: No assets found! The file 'SavedVariables/TTMPMerge.lua' contains no assets ...")
					end
				else
					errPrint("TTMPMerge not found! Please install the TTMPMerge AddOn!")
				end
				didProcess = true

			-- Import HarvestMap SavedVariables files?
			elseif (sCmd == "importhm") then

				local foundHM = false

				if (Harvest) then
					infPrint("TTMP: Found HarvestMap Addon!")
					foundHM = true
				end

				if foundHM then
					TTMP.ImportHM(opt1)
				else
					errPrint("HarvestMap not found! No HarvestMap AddOns found!")
				end
				didProcess = true

			end
		end
	end

	if not didProcess then
		infPrint("_________________")
		infPrint("TTMP Usage:")
		infPrint(" /ttmp cmd (comment)")
		infPrint("_")
		infPrint("TTMP Commands to add Assets:")
		infPrint(" ore wood cloth water rune reagent plant chest")
		infPrint(" backpack pack sack crate map fish fissure")
		infPrint(" shard book quest survey poi(nt) trove box clam site")
		infPrint("_")
		infPrint("Commands can be followed by an optional comment, for example 'shard 6' or 'book Manual of Spellcraft'.")
		infPrint("_")
		infPrint("Other TTMP Commands:")
		infPrint("_")
		infPrint(" save -> Saves all your newly found Assets to disk. Note that this will also reload the UI.")
		infPrint("By default newly found Assets are only saved to disk when you logout to the character select screen!")
		infPrint("_")
		infPrint(" del xxx -> Deletes Asset xxx at your current position where xxx is the type. For example 'del backpack'")
		infPrint("_")
		infPrint(" pos -> Lists your current position on the map.")
		infPrint("_")
		infPrint(" list (all) -> List a count of all Assets in the current zone.")
		infPrint("If you specify 'all', Assets are counted for all zones!")
		infPrint("_")
		infPrint(" merge (test) (all) -> Merge new Assets from a merge file.")
		infPrint("By default only Assets that don't already exist in your local file are imported.")
		infPrint("If you specify 'test', info about the merger is displayed but nothing is actually imported.")
		infPrint("If you specify 'all', everything is imported and your existing Assets may be overwritten!")
		infPrint("Note: This requires the TTMPMerge AddOn to be installed.")
		infPrint("_")
		infPrint(" importhm (test) -> Experimental HarvestMap importer.")
		infPrint("This will try to import assets from your HarvestMap AddOn install.")
		infPrint("If you specify 'test', info about the merger is displayed but nothing is actually imported.")
		infPrint("_")
		infPrint("_________________")
		infPrint("TTMP Configuration:")
		infPrint(" /ttmpcfg -> Shows the TTMP Config menu.")
		infPrint("_")
		infPrint("_________________")
		infPrint("NOTE:")
		infPrint("By default certain nodes are *NOT* shown on your map!")
		infPrint("Please go to your Map Filters (the funnel looking icon between the key and the pin) and select what icons you want to see on the map!")
	end
end

-- ----------------------------------------------
-- Merge assets from a TTMPMerge.lua SavedVariables file
-- ----------------------------------------------
function TTMP.ImportHM(sOpt)
local doTest
local oHM = nil

	doTest = false
	if (sOpt == "test") then doTest = true end

	-- Look for HarvestAD nodes
	oHM = TTMP.ImportHM_FindData("HarvestAD_SavedVars")
	if (oHM ~= nil) then
		infPrint("ImportHM: Processing AD zones ...")
		TTMP.ImportHM_ProcessData(oHM, sOpt)
	else
		infPrint("ImportHM: No assets found for HarvestAD, skipping ...")
	end

	-- Look for HarvestDC nodes
	oHM = TTMP.ImportHM_FindData("HarvestDC_SavedVars")
	if (oHM ~= nil) then
		infPrint("ImportHM: Processing DC zones ...")
		TTMP.ImportHM_ProcessData(oHM, sOpt)
	else
		infPrint("ImportHM: No assets found for HarvestDC, skipping ...")
	end

	-- Look for HarvestEP nodes
	oHM = TTMP.ImportHM_FindData("HarvestEP_SavedVars")
	if (oHM ~= nil) then
		infPrint("ImportHM: Processing EP zones ...")
		TTMP.ImportHM_ProcessData(oHM, sOpt)
	else
		infPrint("ImportHM: No assets found for HarvestEP, skipping ...")
	end

	-- Look for HarvestDLC nodes
	oHM = TTMP.ImportHM_FindData("HarvestDLC_SavedVars")
	if (oHM ~= nil) then
		infPrint("ImportHM: Processing DLC zones ...")
		TTMP.ImportHM_ProcessData(oHM, sOpt)
	else
		infPrint("ImportHM: No assets found for HarvestDLC, skipping ...")
	end

	-- Look for HarvestNF nodes
	oHM = TTMP.ImportHM_FindData("HarvestNF_SavedVars")
	if (oHM ~= nil) then
		infPrint("ImportHM: Processing NF zones ...")
		TTMP.ImportHM_ProcessData(oHM, sOpt)
	else
		infPrint("ImportHM: No assets found for HarvestNF, skipping ...")
	end

	if not doTest then
		infPrint("Now would be a good time to save your new Assets!")
		infPrint("Use: /ttmp save")
		infPrint("_")
	end
end

-- ----------------------------------------------
function TTMP.ImportHM_FindData(oSavedVar)
local oHMs = nil

	if (_G[oSavedVar] ~= nil) then
		if (_G[oSavedVar]["dataVersion"] ~= nil) then
			local hm_saved_version = tonumber(_G[oSavedVar]["dataVersion"])
			if (hm_saved_version == TTMP.supportedHMSave) then
				oHMs = _G[oSavedVar]["data"]
			else
				errPrint(string.format(
					"ImportHM: Unsupported version! Is %d, should be %d ...", hm_saved_version, TTMP.supportedHMSave
				))
			end
		else
			errPrint(string.format("ImportHM: 'dataVersion' not found for [%s]!", oSavedVar))
		end
	else
		errPrint(string.format("ImportHM: 'SavedVars' not found for [%s]!", oSavedVar))
	end
	return oHMs
end

-- ----------------------------------------------
function TTMP.ImportHM_ProcessData(oData, sOpt)
local zone, data, assets, items, asset, value, isDuplicate, dupKey, dupO
local asset_type, x, y, o, sZone, oZone, doTest, oZoneScaling, curdbg, curinf
local iNumZones, iNumZonesNew, iNumAssets, iNumAssetsNew, iNumAssetsDup, iNumAssetsInv

	TTMP.isMerging = true

	iNumZones			= 0
	iNumZonesNew		= 0
	iNumAssets			= 0
	iNumAssetsNew		= 0
	iNumAssetsDup		= 0
	iNumAssetsInv		= 0
	o = ""

	-- Temporarily suppress debugging and info output
	curdbg = TTMP_MENU_OPTIONS.ShowDebug
	TTMP_MENU_OPTIONS.ShowDebug = false
	curinf = TTMP_MENU_OPTIONS.ShowItems
	TTMP_MENU_OPTIONS.ShowItems = false

	doTest = false
	if (sOpt == "test") then doTest = true end

	-- Loop through all zones
	for zone, data in pairs(oData) do
		sZone = tostring(zone)

		-- Check if zone already exists
		iNumZones = iNumZones + 1
		oZoneScaling = 0.0
		oZone = TTMP.ASSETS[sZone]
		if (oZone ~= nil) then
			oZoneScaling = oZone["MinDistance"]
		else
			iNumZonesNew = iNumZonesNew + 1
			oZoneScaling = TTMP_MAP_MIN_DIST_DUNGEON		-- New zone, we assume this is a dungeon ...
			if not doTest then
				TTMP.ASSETS[sZone] = {}
				oZone = TTMP.ASSETS[sZone]
				oZone["MinDistance"] = oZoneScaling
			end
		end

		-- Loop through all asset types in this zone
		for assets, items in pairs(data) do
			for asset,value in pairs(items) do
				iNumAssets = iNumAssets + 1
				asset_type = TTMP_HARVEST_MAP[assets]
				if (asset_type > TTMP_ASSET_NONE) then

					-- Get Asset Coordinates
					x, y = TTMP.ImportHM_GetPos(value)

					-- Check if valid, we reject anything with negative coordinates
					if (x >= 0 and y >= 0) then

						-- Check for duplicates
						isDuplicate = false
						if (oZone ~= nil) then
							isDuplicate, dupKey, dupO = TTMP.IsMergeDuplicate(oZone[TTMP_ASSET_NAMES[asset_type]],x,y,asset_type,oZoneScaling)
						end
						if not isDuplicate then
							iNumAssetsNew = iNumAssetsNew + 1

							-- Add new local asset!
							if not doTest then
								TTMP.AddAssetZXY(asset_type,sZone,x,y,o,true,true)
							end
						else
							iNumAssetsDup = iNumAssetsDup + 1
						end
					else
						iNumAssetsInv = iNumAssetsInv + 1
					end
				else
					iNumAssetsInv = iNumAssetsInv + 1
				end
			end
		end
	end

	-- Enable info output again
	TTMP_MENU_OPTIONS.ShowItems = curinf

	infPrint("_")
	infPrint("> Zones processed: " .. iNumZones)
	infPrint("> New Zones added: " .. iNumZonesNew)
	infPrint("> Assets processed: " .. iNumAssets)
	infPrint("> New Assets added: " .. iNumAssetsNew)
	infPrint("> Duplicate Assets ignored: " .. iNumAssetsDup)
	infPrint("> Invalid Assets ignored: " .. iNumAssetsInv)
	infPrint("_")

	-- Enable debugging output again
	TTMP_MENU_OPTIONS.ShowDebug = curdbg

	TTMP.isMerging = false
end

-- ----------------------------------------------
function TTMP.ImportHM_GetPos(oItem)
local x, y, idx1, idx2, idx3

	x = "-1.0"
	y = "-1.0"
	values = split(oItem, ",")
	if (values ~= nil) then
		if (values[1] ~= nil) then
			x = values[1]
		end
		if (values[2] ~= nil) then
			y = values[2]
		end
	end
	return tonumber(x), tonumber(y)
end

-- ----------------------------------------------
-- Merge assets from a TTMPMerge.lua SavedVariables file
-- ----------------------------------------------
function TTMP.MergeAssets(oMergeAssets, sOpt)
local iNumZoneDistMissing, doAll, doTest
local iNumZones, iNumZonesNew, iNumAssets, iNumAssetsNew, iNumAssetsUpd, iNumAssetsDup, iNumAssetsInv
local curdbg, curinf, oMergeZoneAssets
local oZone, iAssetType, oZoneScaling, oMergeZone, sZone
local x, y, o, isDuplicate, dupKey
local didMerge = false

	TTMP.isMerging = true

	infPrint("TTMPMerge: Merging assets, please wait ...")

	doAll = false
	if (sOpt == "all") then doAll = true end

	doTest = false
	if (sOpt == "test") then doTest = true end

	if (oMergeAssets ~= nil) then

		iNumZones			= 0
		iNumZonesNew		= 0
		iNumAssets			= 0
		iNumAssetsNew		= 0
		iNumAssetsUpd		= 0
		iNumAssetsDup		= 0
		iNumAssetsInv		= 0
		iNumZoneDistMissing	= 0

		-- Temporarily suppress debugging and info output
		curdbg = TTMP_MENU_OPTIONS.ShowDebug
		TTMP_MENU_OPTIONS.ShowDebug = false
		curinf = TTMP_MENU_OPTIONS.ShowItems
		TTMP_MENU_OPTIONS.ShowItems = false

		-- Loop through all zones
		for k,v in pairs(oMergeAssets) do
			if type(v) == "table" then

				oMergeZone = v
				sZone = tostring(k)

				-- Check if zone already exists
				iNumZones = iNumZones + 1
				oZone = TTMP.ASSETS[sZone]
				if (oZone == nil) then
					iNumZonesNew = iNumZonesNew + 1
					if not doTest then
						TTMP.ASSETS[sZone] = {}
						oZone = TTMP.ASSETS[sZone]
					end
				end

				-- Do we have zone scaling info?
				-- If not, we assume this is a dungeon ...
				oZoneScaling = 0.0
				if (oZone ~= nil) then
					if (oZone["MinDistance"] ~= nil) then
						oZoneScaling = oZone["MinDistance"]
					end
				end
				if (oZoneScaling == 0.0) then
					if (oMergeZone["MinDistance"] ~= nil) then
						oZoneScaling = oMergeZone["MinDistance"]
					end
				end
				if (oZoneScaling == 0.0) then
					oZoneScaling = TTMP_MAP_MIN_DIST_DUNGEON
					iNumZoneDistMissing = iNumZoneDistMissing + 1
				end

				if (oZone ~= nil) then
					if (oZone["MinDistance"] == nil) then
						if not doTest then
							oZone["MinDistance"] = oZoneScaling
						end
					end
				end

				-- Loop through all asset types in this zone
				for iAssetType = 1, TTMP_ASSET_COUNT do

					oMergeZoneAssets = oMergeZone[TTMP_ASSET_NAMES[iAssetType]]
					if (oMergeZoneAssets ~= nil) then

						for key, item in ipairs( oMergeZoneAssets ) do
							iNumAssets = iNumAssets + 1

							-- Get Asset Coordinates
							local xs, ys, os = item:match("([^|]+)|([^|]+)|?(.*)")
							o = os or ""
							x = tonumber(xs)
							y = tonumber(ys)

							-- Check if valid, we reject anything with negative coordinates
							if (x >= 0 and y >= 0) then

								-- Check for duplicates
								isDuplicate = false
								if (oZone ~= nil) then
									isDuplicate, dupKey, dupO = TTMP.IsMergeDuplicate(oZone[TTMP_ASSET_NAMES[iAssetType]],x,y,iAssetType,oZoneScaling)
								end
								if (isDuplicate) then
									iNumAssetsDup = iNumAssetsDup + 1

									if not doAll then

										-- If this is a duplicate
										-- and we don't overwrite all local assets
										-- and the new one does have a comment
										-- but the local one does not have a comment
										-- or the new comment is longer than the old comment and the old comment is < 3 characters
										-- we update the local asset with the new comment
										if (o ~= "") then
											if (dupO == "") then
												iNumAssetsUpd = iNumAssetsUpd + 1

												-- Update local asset!
												if not doTest then
													TTMP.AddAssetZXY(iAssetType,sZone,x,y,o,true,true)
												end
											else
												if (string.len(dupO) < 3) then
													if (string.len(o) > 2) then
														iNumAssetsUpd = iNumAssetsUpd + 1

														-- Update local asset!
														if not doTest then
															TTMP.AddAssetZXY(iAssetType,sZone,x,y,o,true,true)
														end
													end
												end
											end
										end
									else

										-- Update local asset!
										if not doTest then
											TTMP.AddAssetZXY(iAssetType,sZone,x,y,o,true,true)
										end

									end
								else
									iNumAssetsNew = iNumAssetsNew + 1

									-- Add new local asset!
									if not doTest then
										TTMP.AddAssetZXY(iAssetType,sZone,x,y,o,true,true)
									end

								end
							else
								iNumAssetsInv = iNumAssetsInv + 1
							end
						end
					end
				end
			end
		end

		-- Enable info output again
		TTMP_MENU_OPTIONS.ShowItems = curinf

		infPrint("_")
		infPrint("> Zones processed: " .. iNumZones)
		infPrint("> New Zones added: " .. iNumZonesNew)
		infPrint("> Assets processed: " .. iNumAssets)
		infPrint("> New Assets added: " .. iNumAssetsNew)
		infPrint("> Existing Assets updated: " .. iNumAssetsUpd)
		infPrint("> Duplicate Assets ignored: " .. iNumAssetsDup)
		infPrint("> Invalid Assets ignored: " .. iNumAssetsInv)
		infPrint("> Missing Zone scaling: " .. iNumZoneDistMissing)
		infPrint("_")
		if not doTest then
			infPrint("Now would be a good time to save your new Assets!")
			infPrint("Use: /ttmp save")
			infPrint("_")
		end
		didMerge = true

		-- Enable debugging output again
		TTMP_MENU_OPTIONS.ShowDebug = curdbg

	else
		errPrint("No assets found! Aborting ...")
	end

	TTMP.isMerging = false

	return didMerge
end

-- ----------------------------------------------
-- Get a total count of all assets tracked
-- ----------------------------------------------
function TTMP.CountAllAssets()

	-- Note: This forces to load the "global_assets" table as such, otherwise it'll be a overloaded function!
	local oAssetList = _G["TamrielMapping_Vars"]["global_assets"]
	local oZone, sZone
	local iNumZones = 0
	local iNumAssets = 0

	if (oAssetList ~= nil) then
		for k,v in pairs(oAssetList) do
			if type(v) == "table" then
				sZone = tostring(k)
				oZone = TTMP.ASSETS[sZone]
				if (oZone ~= nil) then
					iNumZones = iNumZones + 1
					for iAssetType = 1, TTMP_ASSET_COUNT do
						local oAssets = TTMP.ASSETS[sZone][TTMP_ASSET_NAMES[iAssetType]]
						if (oAssets ~= nil) then
							for key, item in ipairs( oAssets ) do
								iNumAssets = iNumAssets + 1
							end
						end
					end
				end
			end
		end
	end

	return iNumAssets, iNumZones
end

-- ----------------------------------------------
-- List all Assets in current zone or all zones
-- ----------------------------------------------
function TTMP.ListAssets(sOpt)
local iAssetType, iNumZones, iNumAssets, sListZone
local oAssetListCounts = { }

	-- Clear Asset counts
	for iAssetType = 1, TTMP_ASSET_COUNT do
		oAssetListCounts[iAssetType] = 0
	end
	iNumZones	= 0
	iNumAssets	= 0
	sListZone	= "All Zones"

	-- Count all Assets in all zones?
	if (sOpt == "all") then

		-- Note: This forces to load the "global_assets" table as such, otherwise it'll be a overloaded function!
		local oAssetList = _G["TamrielMapping_Vars"]["global_assets"]
		local oZone, sZone

		if (oAssetList ~= nil) then
			for k,v in pairs(oAssetList) do
				if type(v) == "table" then
					sZone = tostring(k)
					oZone = TTMP.ASSETS[sZone]
					if (oZone ~= nil) then
						iNumZones = iNumZones + 1
						for iAssetType = 1, TTMP_ASSET_COUNT do
							local oAssets = TTMP.ASSETS[sZone][TTMP_ASSET_NAMES[iAssetType]]
							if (oAssets ~= nil) then
								for key, item in ipairs( oAssets ) do
									oAssetListCounts[iAssetType] = oAssetListCounts[iAssetType] + 1
									iNumAssets = iNumAssets + 1
								end
							end
						end
					end
				end
			end
		end

	-- Count only Assets for the current zone?
	else

		local oZone, x, y = TTMP.GetLocation()
		iNumZones = 1
		sListZone = oZone

		for iAssetType = 1, TTMP_ASSET_COUNT do
			local oAssets = TTMP.ASSETS[oZone][TTMP_ASSET_NAMES[iAssetType]]
			if (oAssets ~= nil) then
				for key, item in ipairs( oAssets ) do
					oAssetListCounts[iAssetType] = oAssetListCounts[iAssetType] + 1
					iNumAssets = iNumAssets + 1
				end
			end
		end
	end

	-- Print results
	infPrint("_")
	infPrint("TTMP.ListAssets(".. sListZone .. "):")
	infPrint("Number of Zones  = " .. iNumZones)
	infPrint("Number of Assets = " .. iNumAssets)
	for iAssetType = 1, TTMP_ASSET_COUNT do
		infPrint(string.format("TTMP.%s = %d", TTMP_ASSET_NAMES[iAssetType], oAssetListCounts[iAssetType]))
	end
end

-- ----------------------------------------------
-- Delete Asset at the current player position
-- ----------------------------------------------
function TTMP.DeleteAssetAtPlayer(iAssetType)

	local oZone, x, y = TTMP.GetLocation()
	TTMP.DeleteAssetAtPos(iAssetType, oZone, x, y, nil)
end

-- ----------------------------------------------
-- Delete Asset at the specified zone position
-- AS: We now also add the Asset to the "DELETED" section for this zone
-- ----------------------------------------------
function TTMP.DeleteAssetAtPos(iAssetType, oZone, x, y, iCount)

	if (iAssetType > 0) then
		local sAsset = TTMP_ASSET_NAMES[iAssetType]
		local isDuplicate, dupKey = TTMP.IsDuplicate(TTMP.ASSETS[oZone][sAsset], x, y, iAssetType)
		if (dupKey ~= nil) then

			-- Remove Asset
			table.remove(TTMP.ASSETS[oZone][sAsset], dupKey)

			-- Add Asset to the DELETED section
			ixy = string.format("%f|%f|%d", x, y, iAssetType)
			if not TTMP.ASSETS[oZone]["DELETED"] then
				TTMP.ASSETS[oZone]["DELETED"] = {}
			end
			table.insert(TTMP.ASSETS[oZone]["DELETED"], ixy)

			-- Refresh pins
			local sPinType = "TTMP_Pin" .. iAssetType
			LMP:RefreshPins(sPinType)

			-- Show info in chat window
			local sCount = ""
			if iCount then
				sCount = string.format("[%d] ", iCount)
			end
			infPrint(string.format("TTMP.del: Asset '%s%s' deleted at %f,%f!", sCount, sAsset, x, y))
		else
			errPrint(string.format("TTMP.del: Asset '%s' not found here!", sAsset))
		end
	else
		errPrint(string.format("TTMP.del: Unknown Asset type! %d", iAssetType))
	end
end

-- ----------------------------------------------
-- Called every time the map changes
-- ----------------------------------------------
function TTMP.PinCallback(iAsset)
local oZone, oAssets

	oZone = TTMP.GetZoneName()
	if (TTMP.ASSETS[oZone]) then

		oAssets = TTMP.ASSETS[oZone][TTMP_ASSET_NAMES[iAsset]]
		if oAssets then
			local n, x, y, o, sPinType, sPinName, key, item

			sPinType = "TTMP_Pin"..iAsset
			n = 1
			for key, item in ipairs( oAssets ) do
				x, y, o = item:match("([^|]+)|([^|]+)|?(.*)")
				o = o or ""
				sPinName = string.format("%s/%s.%d",oZone,TTMP_ASSET_NAMES[iAsset],n)
				LMP:CreatePin(sPinType, sPinName, tonumber(x) , tonumber(y))
				n = n + 1
			end
		end
	end

end

-- ----------------------------------------------
-- Get a Asset from the supplied Pin tag
-- ----------------------------------------------
function TTMP.GetAssetFromPinTag(pinTag)
local idx1,idx2,idx3
local sZone,sAsset,iCount,oAsset

	oAsset	= nil
	sAsset	= ""
	sZone	= ""
	iCount	= 0

	-- Parse the pin tag and tokenize it
	idx1 = string.find(pinTag, "/")
	if (idx1 ~= nil) then
		idx2 = string.find(pinTag, "/", (idx1+1))
		if (idx2 ~= nil) then
			sZone	= string.sub(pinTag,0,(idx2-1))
			idx3	= string.find(pinTag,"%.",(idx2+1))
			if (idx3 ~= nil) then
				sAsset = string.sub(pinTag,(idx2+1),(idx3-1))
				iCount = tonumber(string.sub(pinTag,(idx3+1)))
			end
		end
	end

	if (iCount > 0) then
		oAsset = TTMP.ASSETS[sZone][sAsset][iCount]
	end

	return oAsset, sAsset, iCount
end

-- ----------------------------------------------
-- Creates a tooltip for an icon
-- ----------------------------------------------
local TTMP_PinTooltipCreator = {

	creator = function(pin)

		local oAsset, sAsset, iCount = TTMP.GetAssetFromPinTag(pin.m_PinTag)
		if oAsset then
			local iType = TTMP.AssetTypeFromName(sAsset)
			if (iType > 0) then
				local sToolTip = TTMP_ASSET_TOOLTIP[iType]
				local x, y, o = oAsset:match("([^|]+)|([^|]+)|?(.*)")
				o = o or ""
				if (o ~= "") then
					sToolTip = sToolTip .. " '" .. o .. "'"
				end

				-- Add x and y for debugging
				if (TTMP_MENU_OPTIONS.ShowDebug) then
					sToolTip = string.format("%s [%d] %f,%f", sToolTip, iCount, tonumber(x), tonumber(y))
				end

				-- Add node id when deleting is enabled
				if (TTMP_MENU_OPTIONS.DeleteAssets) then
					sToolTip = string.format("[%d] %s", iCount, sToolTip)
				end

				InformationTooltip:AddLine(sToolTip)
			end
		end

	end,
	tooltip = 1,
}

-- ----------------------------------------------
-- Get the correct pin title for the context menu
-- NOTE: The menu is only shown if there are two or more icons close together
-- ----------------------------------------------
local TTMP_RMB_Name_Function = function(pin)
	local oAsset, sAsset, iCount = TTMP.GetAssetFromPinTag(pin.m_PinTag)
	local sFullName = sAsset
	if oAsset then
		local iType = TTMP.AssetTypeFromName(sAsset)
		if (iType > 0) then
			sFullName = TTMP_ASSET_TOOLTIP[iType]
		end
	end
	return string.format("DELETE '[%d] %s'", iCount, sFullName)
end

-- ----------------------------------------------
-- Right mouse button click on icon handler
-- ----------------------------------------------
local TTMP_RMB_Handler = {
	{
		name = TTMP_RMB_Name_Function,
		callback = function(pin)
			local oAsset, sAsset, iCount = TTMP.GetAssetFromPinTag(pin.m_PinTag)
			if oAsset then
				local iType = TTMP.AssetTypeFromName(sAsset)
				if (iType > 0) then
					local x, y, o	= oAsset:match("([^|]+)|([^|]+)|?(.*)")
					local oZone		= TTMP.GetLocation()
					TTMP.DeleteAssetAtPos(iType, oZone, tonumber(x), tonumber(y), iCount)
				end
			end
		end,
	},
}

-- ----------------------------------------------
-- Create the Map Pin type objects and filters
-- ----------------------------------------------
function TTMP.InitMapPins()
local iType, sPinType

	if TTMP_MENU_OPTIONS.ShowDebug then
		dbgPrint("TTMP.InitMapPins()")
	end

	for iType = 1, TTMP_ASSET_COUNT do

		sPinType = "TTMP_Pin" .. iType

		-- Add PinType definition and callback
		LMP:AddPinType(
			sPinType,
			function( g_mapPinManager )
				TTMP.PinCallback(iType)
			end,
			nil,
			TTMP_ASSET_PINS[TTMP_CUR_PIN_TYPE][iType],
			TTMP_PinTooltipCreator
		)

		-- Add PinType mouse click handler(s)
		if (TTMP_MENU_OPTIONS.DeleteAssets) then
			LMP:SetClickHandlers(
				sPinType,
				nil,
				TTMP_RMB_Handler
			)
		else
			LMP:SetClickHandlers(
				sPinType,
				nil,
				nil
			)
		end

		-- Add PinType map filter
		LMP:AddPinFilter(
			sPinType,
			"TTMP_" .. TTMP_ASSET_LABELS[iType],
			false,
			TTMP.SavedVars["settings"]["MapFilters"],nil,nil
		)

	end

end

-- ----------------------------------------------
-- Remove all Map Pins
-- ----------------------------------------------
function TTMP.RemoveMapPins()
local iType, sPinType

	if TTMP_MENU_OPTIONS.ShowDebug then
		dbgPrint("TTMP.RemoveMapPins()")
	end

	for iType = 1, TTMP_ASSET_COUNT do
		sPinType = "TTMP_Pin" .. iType
		LMP:RemoveCustomPin(sPinType,nil)
	end

end

-- ----------------------------------------------
-- Build the settings menu
-- ----------------------------------------------
function TTMP.InitMenu()

	local panelData = {
		type = "panel",
		name = "TTMP",
		displayName = TTMP_COL_YELLOW:Colorize("The Tamriel Mapping Project"),
		author = TTMP_COL_YELLOW:Colorize(TTMP.Author),
		version = TTMP_COL_YELLOW:Colorize(TTMP.DisplayVersion),
		registerForRefresh = true,
		slashCommand = "/ttmpcfg",
	}
	LAM:RegisterAddonPanel("TTMP_Settings", panelData)

	local optionsMenu = { }
	table.insert(optionsMenu, {
		type = "header",
		name = TTMP_COL_YELLOW:Colorize("Display Options"),
		width = "full",
	})
	table.insert(optionsMenu, {
		type = "checkbox",
		name = "Show Asset Info in Chat",
		tooltip = "Show/Hide asset info in chat",
		getFunc = function() return TTMP_MENU_OPTIONS.ShowItems end,
		setFunc = function(value)
			TTMP_MENU_OPTIONS.ShowItems = value
			TTMP.SavedVars.settings.MenuOptions.ShowItems = TTMP_MENU_OPTIONS.ShowItems
		end,
		width = "full",
		default = TTMP_MENU_OPTIONS.ShowItems,
	})
	table.insert(optionsMenu, {
		type = "checkbox",
		name = "Show Player Loot Info in Chat",
		tooltip = "Show/Hide player loot info in chat",
		getFunc = function() return TTMP_MENU_OPTIONS.ShowLoot end,
		setFunc = function(value)
			TTMP_MENU_OPTIONS.ShowLoot = value
			TTMP.SavedVars.settings.MenuOptions.ShowLoot = TTMP_MENU_OPTIONS.ShowLoot
		end,
		width = "full",
		default = TTMP_MENU_OPTIONS.ShowLoot,
	})
	table.insert(optionsMenu, {
		type = "checkbox",
		name = "Show Group Loot Info in Chat",
		tooltip = "Show/Hide group loot info in chat",
		getFunc = function() return TTMP_MENU_OPTIONS.ShowGroupLoot end,
		setFunc = function(value)
			TTMP_MENU_OPTIONS.ShowGroupLoot = value
			TTMP.SavedVars.settings.MenuOptions.ShowGroupLoot = TTMP_MENU_OPTIONS.ShowGroupLoot
		end,
		width = "full",
		default = TTMP_MENU_OPTIONS.ShowGroupLoot,
	})
	table.insert(optionsMenu, {
		type = "checkbox",
		name = "Show Loot Item IDs",
		tooltip = "Show/Hide internal IDs for loot items",
		getFunc = function() return TTMP_MENU_OPTIONS.ShowLootIDs end,
		setFunc = function(value)
			TTMP_MENU_OPTIONS.ShowLootIDs = value
			TTMP.SavedVars.settings.MenuOptions.ShowLootIDs = TTMP_MENU_OPTIONS.ShowLootIDs
		end,
		width = "full",
		default = TTMP_MENU_OPTIONS.ShowLootIDs,
	})
	table.insert(optionsMenu, {
		type = "checkbox",
		name = "Show Loot Item Count",
		tooltip = "Show/Hide loot item count when multiples are looted",
		getFunc = function() return TTMP_MENU_OPTIONS.ShowLootCount end,
		setFunc = function(value)
			TTMP_MENU_OPTIONS.ShowLootCount = value
			TTMP.SavedVars.settings.MenuOptions.ShowLootCount = TTMP_MENU_OPTIONS.ShowLootCount
		end,
		width = "full",
		default = TTMP_MENU_OPTIONS.ShowLootCount,
	})
	table.insert(optionsMenu, {
		type = "checkbox",
		name = "Show Loot Item Trait",
		tooltip = "Show/Hide loot item trait info",
		getFunc = function() return TTMP_MENU_OPTIONS.ShowLootTrait end,
		setFunc = function(value)
			TTMP_MENU_OPTIONS.ShowLootTrait = value
			TTMP.SavedVars.settings.MenuOptions.ShowLootTrait = TTMP_MENU_OPTIONS.ShowLootTrait
		end,
		width = "full",
		default = TTMP_MENU_OPTIONS.ShowLootTrait,
	})
	table.insert(optionsMenu, {
		type = "checkbox",
		name = "Show Debug Info in Chat",
		tooltip = "Show/Hide debug info in chat",
		getFunc = function() return TTMP_MENU_OPTIONS.ShowDebug end,
		setFunc = function(value)
			TTMP_MENU_OPTIONS.ShowDebug = value
			TTMP.SavedVars.settings.MenuOptions.ShowDebug = TTMP_MENU_OPTIONS.ShowDebug
		end,
		width = "full",
		default = TTMP_MENU_OPTIONS.ShowDebug,
	})
	table.insert(optionsMenu, {
		type = "checkbox",
		name = "Manually Delete Assets",
		tooltip = "Delete assets by right-clicking on them on the map",
		warning = "Changing this setting requires to reload the UI!",
		getFunc = function() return TTMP_MENU_OPTIONS.DeleteAssets end,
		setFunc = function(value)
			TTMP_MENU_OPTIONS.DeleteAssets = value
			TTMP.SavedVars.settings.MenuOptions.DeleteAssets = TTMP_MENU_OPTIONS.DeleteAssets
			ReloadUI()
		end,
		width = "full",
		default = TTMP_MENU_OPTIONS.DeleteAssets,
	})
	table.insert(optionsMenu, {
		type = "dropdown",
		name = "Map Icon Set",
		tooltip = "Choose which map icon set to use",
		warning = "Changing this setting requires to reload the UI!",
		choices = {"ESO Built-In Icons", "TTMP Icons"},
		getFunc = function() return TTMP_MENU_OPTIONS.IconsToUse end,
		setFunc = function(value)
			TTMP_MENU_OPTIONS.IconsToUse = value
			if (value == "TTMP Icons") then
				TTMP_CUR_PIN_TYPE = TTMP_PIN_TYPE_TTMP
			else
				TTMP_CUR_PIN_TYPE = TTMP_PIN_TYPE_ESO
			end
			TTMP.SavedVars.settings.Pintype = TTMP_CUR_PIN_TYPE
			TTMP.SavedVars.settings.MenuOptions.IconsToUse = TTMP_MENU_OPTIONS.IconsToUse
		end,
		width = "full",
		default = TTMP_MENU_OPTIONS.IconsToUse,
	})
	for iType = 1, TTMP_ASSET_COUNT do
		table.insert(optionsMenu, {
			type = "colorpicker",
			name = string.format("Icon Color - %s",TTMP_ASSET_LABELS[iType]),
			tooltip = "Choose the map icon color for this asset",
			warning = "Changing this setting requires a UI reload! Use the [Reload UI] button below ...]",
			getFunc = function()
				local r, g, b = TTMP_MENU_OPTIONS.IconColors[iType]:match("([^|]+)|([^|]+)|([^|]+)|")
				return tonumber(r),tonumber(g),tonumber(b)
			end,
			setFunc = function(r,g,b)
				TTMP_MENU_OPTIONS.IconColors[iType] = string.format("%f|%f|%f|",r,g,b)
				TTMP_ASSET_PINS[TTMP_PIN_TYPE_TTMP][iType].tint	= ZO_ColorDef:New(tonumber(r),tonumber(g),tonumber(b))
				TTMP_ASSET_PINS[TTMP_PIN_TYPE_ESO][iType].tint	= TTMP_ASSET_PINS[TTMP_PIN_TYPE_TTMP][iType].tint
			end,
			width = "full",
		})
	end
	table.insert(optionsMenu, {
		type = "header",
		name = "",
		width = "full",
	})
	table.insert(optionsMenu, {
		type = "button",
		name = "Reload UI",
		tooltip = "Reload the UI to show changes made in the settings",
		func = function() ReloadUI() end,
	})
	LAM:RegisterOptionControls("TTMP_Settings", optionsMenu)

end

-- ----------------------------------------------
-- Holy mother of function overload hacks!!!
-- This gets the info of the last object we interacted with
-- ----------------------------------------------
local oldInteract = FISHING_MANAGER.StartInteraction
FISHING_MANAGER.StartInteraction = function(...)

	local sAction, sName, isBlocked, isOwned, additionalInfo, context, contextLink, isCriminal = GetGameCameraInteractableActionInfo()
	if (sAction ~= nil) then
		TTMP.InteractReset()
		TTMP.iInteractMillis	= GetFrameTimeMilliseconds()
		TTMP.sCurAction			= tostring(sAction)
		TTMP.sCurNode			= tostring(sName)
		if TTMP_MENU_OPTIONS.ShowDebug then
			infPrint(string.format("TTMP.StartInteraction: %s, %s",TTMP.sCurAction,TTMP.sCurNode))
		end
	end

	return oldInteract(...)
end

-- ----------------------------------------------
-- Initial Event Manager Hooks
-- ----------------------------------------------
EVENT_MANAGER:RegisterForEvent("TTMP_StartUp", EVENT_ADD_ON_LOADED, TTMP.OnLoad)

