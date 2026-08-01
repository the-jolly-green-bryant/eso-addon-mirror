--[[
-------------------------------------------------------------------------------
-- BankManager, by Ayantirgold
-- BankManager, by Ayantir
-------------------------------------------------------------------------------
This software is under : CreativeCommons CC BY-NC-SA 4.0
Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

You are free to:

    Share — copy and redistribute the material in any medium or format
    Adapt — remix, transform, and build upon the material
    The licensor cannot revoke these freedoms as long as you follow the license terms.


Under the following terms:

    Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
    NonCommercial — You may not use the material for commercial purposes.
    ShareAlike — If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
    No additional restrictions — You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.


Please read full licence at : 
http://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
]]

-- BMR rules definition
-- Once you declared them here, don't forget to declare them in LAMSubmenu(), and add optionally block definition in buildLAMPanel() if your rule need a whole submenu

-- addFiltersTaggedAll is intended to regroup multiple  filters, such as "all trait stones", "all armors", thoses rules are executed AFTER filters defined in addFilters() thanks to .position flag

BankManagerRules = {}
BankManagerRules.data = {}
BankManagerRules.defaults = {}

local ACTION_NOTSET = 1
local BMR_ITEMLINK = 1
local BMR_BAG_AND_SLOT = 2
local ruleName
local LR = LibResearch

local BMR_RULEWRITER_VALUE_OPTIONAL_KEYWORD = 1
local BMR_RULEWRITER_VALUE_WITH_OPERATOR = 2
local BMR_RULEWRITER_VALUE_WITHOUT_OPERATOR = 3

-- List of all things we cannot dynamically get
BankManagerRules.static = {}

-- Taken through the Crafts panels - it doesn't return correct values with itemLinkStyle, Quality and requiredLevel.
-- itemLink cannot be used, because GetItemLink() returns a link with the name hardcoded inside the link, so use the itemId.
-- /script d(GetItemLink(1, 19) .. " " .. BankManagerRules.static.refinedMaterial[1][10])
 BankManagerRules.static.refinedMaterial = {
	[CRAFTING_TYPE_BLACKSMITHING] = {
		[1] = "|H0:item:5413:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[2] = "|H0:item:4487:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[3] = "|H0:item:23107:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[4] = "|H0:item:6000:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[5] = "|H0:item:6001:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[6] = "|H0:item:46127:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[7] = "|H0:item:46128:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[8] = "|H0:item:46129:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[9] = "|H0:item:46130:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[10] = "|H0:item:64489:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	},
	[CRAFTING_TYPE_CLOTHIER] = {
		[1] = "|H0:item:811:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[2] = "|H0:item:4463:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[3] = "|H0:item:23125:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[4] = "|H0:item:23126:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[5] = "|H0:item:23127:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[6] = "|H0:item:46131:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[7] = "|H0:item:46132:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[8] = "|H0:item:46133:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[9] = "|H0:item:46134:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[10] = "|H0:item:64504:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	},
	[CRAFTING_TYPE_CLOTHIER * 100] = {
		[1] = "|H0:item:794:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[2] = "|H0:item:4447:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[3] = "|H0:item:23099:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[4] = "|H0:item:23100:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[5] = "|H0:item:23101:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[6] = "|H0:item:46135:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[7] = "|H0:item:46136:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[8] = "|H0:item:46137:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[9] = "|H0:item:46138:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[10] = "|H0:item:64506:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	},
	[CRAFTING_TYPE_WOODWORKING] = {
		[1] = "|H0:item:803:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[2] = "|H0:item:533:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[3] = "|H0:item:23121:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[4] = "|H0:item:23122:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[5] = "|H0:item:23123:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[6] = "|H0:item:46139:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[7] = "|H0:item:46140:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[8] = "|H0:item:46141:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[9] = "|H0:item:46142:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[10] = "|H0:item:64502:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	},	
	[CRAFTING_TYPE_JEWELRYCRAFTING] = {
		[1] = "|H1:item:135146:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[2] = "|H1:item:135144:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[3] = "|H1:item:135142:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[4] = "|H1:item:135140:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[5] = "|H1:item:135138:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	},
}

-- Thanks guild
BankManagerRules.static.rawMaterial = {
	[CRAFTING_TYPE_BLACKSMITHING] = {
		[1] = "|H0:item:808:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[2] = "|H0:item:5820:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[3] = "|H0:item:23103:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[4] = "|H0:item:23104:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[5] = "|H0:item:23105:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[6] = "|H0:item:4482:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[7] = "|H0:item:23133:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[8] = "|H0:item:23134:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[9] = "|H0:item:23135:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[10] = "|H0:item:71198:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	},
	[CRAFTING_TYPE_CLOTHIER] = {
		[1] = "|H0:item:812:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[2] = "|H0:item:4464:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[3] = "|H0:item:23129:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[4] = "|H0:item:23130:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[5] = "|H0:item:23131:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[6] = "|H0:item:33217:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[7] = "|H0:item:33218:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[8] = "|H0:item:33219:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[9] = "|H0:item:33220:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[10] = "|H0:item:71200:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	},
	[CRAFTING_TYPE_CLOTHIER * 100] = {
		[1] = "|H0:item:793:30:50:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[2] = "|H0:item:4448:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[3] = "|H0:item:23095:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[4] = "|H0:item:6020:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[5] = "|H0:item:23097:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[6] = "|H0:item:23142:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[7] = "|H0:item:23143:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[8] = "|H0:item:800:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[9] = "|H0:item:4478:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[10] = "|H0:item:71239:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	},
	[CRAFTING_TYPE_WOODWORKING] = {
		[1] = "|H0:item:802:30:50:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[2] = "|H0:item:521:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[3] = "|H0:item:23117:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[4] = "|H0:item:23118:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[5] = "|H0:item:23119:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[6] = "|H0:item:818:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[7] = "|H0:item:4439:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[8] = "|H0:item:23137:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[9] = "|H0:item:23138:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[10] = "|H0:item:71199:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	},
	[CRAFTING_TYPE_JEWELRYCRAFTING] = {
		[1] = "|H1:item:135137:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[2] = "|H1:item:135139:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[3] = "|H1:item:135141:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[4] = "|H1:item:135143:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		[5] = "|H1:item:135145:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	},
}

-- From Dustman. But maybe move to GetItemLinkFlavorText should be better if ZOS revamp cooking again
-- 1 is food, 2 is drink, 3 is special
BankManagerRules.static.rawIngredients = {
   --meat (health)
   ["28609"] = 1, --Game
   ["33752"] = 1, --Red Meat
   ["33753"] = 1, --Fish
   ["33754"] = 1, --White Meat
   ["33756"] = 1, --Small Game
   ["34321"] = 1, --Poultry
   --fruits (magicka)
   ["28603"] = 1, --Tomato
   ["28610"] = 1, --Jazbay Grapes
   ["33755"] = 1, --Bananas
   ["34308"] = 1, --Melon
   ["34311"] = 1, --Apples
   ["34305"] = 1, --Pumpkin
   --vegetables (stamina)
   ["28604"] = 1, --Greens
   ["33758"] = 1, --Potato
   ["34307"] = 1, --Radish
   ["34309"] = 1, --Beets
   ["34323"] = 1, --Corn
   ["34324"] = 1, --Carrots
   --dish additives
   ["26954"] = 1, --Garlic
   ["27057"] = 1, --Cheese
   ["27058"] = 1, --Seasoning
   ["27063"] = 1, --Saltrice
   ["27064"] = 1, --Millet
   ["27100"] = 1, --Flour
   --alcoholic (health)
   ["28639"] = 2, --Rye
   ["29030"] = 2, --Rice
   ["33774"] = 2, --Yeast
   ["34329"] = 2, --Barley
   ["34345"] = 2, --Surilie Grapes
   ["34348"] = 2, --Wheat
   --tea (magicka)
   ["28636"] = 2, --Rose
   ["33768"] = 2, --Comberry
   ["33771"] = 2, --Jasmine
   ["33773"] = 2, --Mint
   ["34330"] = 2, --Lotus
   ["34334"] = 2, --Bittergreen
   --tonic (stamina)
   ["33772"] = 2, --Coffee
   ["34333"] = 2, --Guarana
   ["34335"] = 2, --Yerba Mate
   ["34346"] = 2, --Gingko
   ["34347"] = 2, --Ginseng
   ["34349"] = 2, --Acai Berry
   --drink additives
   ["27035"] = 2, --Isinglass
   ["27043"] = 2, --Honey
   ["27048"] = 2, --Metheglin
   ["27049"] = 2, --Lemon
   ["27052"] = 2, --Ginger
   ["28666"] = 2, --Seaweed
   --rare dish additive
   ["26802"] = 3, --Frost Mirriam
   --rare drink additive
   ["27059"] = 3, --Bervez Juice
   --Caviar
   ["64222"] = 3, --Caviar
	
}

-- raw items are maybe linked to ITEMTYPE_RAW_MATERIAL, but they are not linked to GetItemLinkItemStyle, so no function and nothing to enumerate.
BankManagerRules.static.rawStyles = {
	[ITEMSTYLE_AREA_DWEMER] = "|H0:item:57665:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", 
	[ITEMSTYLE_GLASS] = "|H0:item:64690:33:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEMSTYLE_AREA_AKAVIRI] = "|H0:item:64688:33:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEMSTYLE_AREA_ANCIENT_ORC] = "|H0:item:69556:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEMSTYLE_AREA_XIVKYN] = "|H0:item:59923:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEMSTYLE_ORG_THIEVES_GUILD] = "|H0:item:75371:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEMSTYLE_ORG_ASSASSINS] = "|H0:item:76911:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEMSTYLE_ORG_ABAHS_WATCH] = "|H0:item:76915:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEMSTYLE_ORG_DARK_BROTHERHOOD] = "|H0:item:79306:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEMSTYLE_ORG_ORDINATOR] = "|H1:item:81997:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEMSTYLE_ENEMY_MINOTAUR] = "|H1:item:81995:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[ITEMSTYLE_ORG_BUOYANT_ARMIGER] = "|H1:item:121521:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
}

-- To display names nicely (even if level 1 got 2 solvents, only 1 is displayed here, but filter works, because not based on this array) itemLink here is not used by filter so it can be a little bit false
BankManagerRules.static.alchemySolventArray = {
	[1] = "|H1:item:883:30:2:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[2] = "|H1:item:4570:30:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[3] = "|H1:item:23265:30:34:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[4] = "|H1:item:23266:30:40:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[5] = "|H1:item:23267:125:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[6] = "|H1:item:23268:129:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[7] = "|H1:item:64500:134:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[8] = "|H1:item:64501:308:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
}

BankManagerRules.static.jewelrycraftingRawTraits = {
	[1] = "|H1:item:135159:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[2] = "|H1:item:135158:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[3] = "|H1:item:135160:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[4] = "|H1:item:139417:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[5] = "|H1:item:139415:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[6] = "|H1:item:139419:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[7] = "|H1:item:139418:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	[8] = "|H1:item:139416:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
}

-- List is built at each bank interaction
BankManagerRules.static.special = {}
BankManagerRules.static.special.writsQuests = {}

-- RuleWriter Keywords
BankManagerRules.keywordConditionTable = {
	
	ARMOR = { -- keyword
		[BMR_RULEWRITER_VALUE_OPTIONAL_KEYWORD] = {
			LIGHT = {func = GetItemLinkArmorType, funcArgs = BMR_ITEMLINK, values = {ARMORTYPE_LIGHT}},
			MEDIUM = {func = GetItemLinkArmorType, funcArgs = BMR_ITEMLINK, values = {ARMORTYPE_MEDIUM}},
			HEAVY = {func = GetItemLinkArmorType, funcArgs = BMR_ITEMLINK, values = {ARMORTYPE_HEAVY}},
		},
		data = {
			func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_ARMOR}
		},
	},

	QUALITY = { -- keyword
		[BMR_RULEWRITER_VALUE_WITH_OPERATOR] = {
			GREY = {func = GetItemLinkQuality, funcArgs = BMR_ITEMLINK, values = {ITEM_QUALITY_TRASH}},
			WHITE = {func = GetItemLinkQuality, funcArgs = BMR_ITEMLINK, values = {ITEM_QUALITY_NORMAL}},
			GREEN = {func = GetItemLinkQuality, funcArgs = BMR_ITEMLINK, values = {ITEM_QUALITY_MAGIC}},
			BLUE = {func = GetItemLinkQuality, funcArgs = BMR_ITEMLINK, values = {ITEM_QUALITY_ARCANE}},
			PURPLE = {func = GetItemLinkQuality, funcArgs = BMR_ITEMLINK, values = {ITEM_QUALITY_ARTIFACT}},
			YELLOW = {func = GetItemLinkQuality, funcArgs = BMR_ITEMLINK, values = {ITEM_QUALITY_LEGENDARY}},
		},
		data = {
			func = GetItemLinkQuality, funcArgs = BMR_ITEMLINK
		},
	},

	MAXIMUM = { -- keyword
		[BMR_RULEWRITER_VALUE_WITHOUT_OPERATOR] = {
			func = BankManagerRules.MaxItemsMoved, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_ARMOR}, paramType = BMR_RULEWRITER_VALUE_NUMBER,
		},
	},
	
}


-- Local function for BankManagerRules.static
local function GetItemLinkItemId(itemLink)
	return select(4, ZO_LinkHandler_ParseLink(itemLink))
end

-- Local function for Recipes and Housing
local function GetItemLinkSpecializedItemType(itemLink)
	return select(2, GetItemLinkItemType(itemLink))
end

-- Local function for items Researchable
local function IsItemNeededForResearch(itemLink)

   --CraftStore 3.00 support
   if CS and CS.GetTrait and CS.account and CS.account.crafting then
      local craft, row, trait = CS.GetTrait(itemLink)
      -- Loop all chars known by CS
      for char, data in pairs(CS.account.crafting.studies) do
         --if a char study this item
         if data[craft] and data[craft][row] and (data[craft][row]) then
            -- If this char didn't yet researched this item
            if CS.account.crafting.research[char][craft] and CS.account.crafting.research[char][craft][row] and CS.account.crafting.research[char][craft][row][trait] == false then
               return true
            end
         end
      end
      return false
   end

   --libResearch
   local _, isResearchable = LR:GetItemTraitResearchabilityInfo(itemLink)
   return isResearchable
end

-- Local function for BankManagerRules.static.rawIngredients
local function GetItemLinkIngredientType(itemLink)
	local itemId = GetItemLinkItemId(itemLink)
	if BankManagerRules.static.rawIngredients[itemId] then
		return BankManagerRules.static.rawIngredients[itemId]
	end
	return false
end

local function Sanitize(value)
	return value:gsub("[-*+?^$().[%]%%]", "%%%0") -- escape meta characters
end

local function IsWritItem(itemLink)

	local itemName = " " .. zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(itemLink))
	
	for _, data in ipairs(BankManagerRules.static.special.writsQuests) do
		if string.find(data.text, Sanitize(itemName)) then
			BankManagerRules.static.special.writsQuests[itemLink] = data.qtyToMove
			BankManagerRules.static.special.writsQuestsGlyphs[itemLink] = data.qtyToMove -- Bit dirty, see how to improve
			BankManagerRules.static.special.writsQuestsPots[itemLink] = data.qtyToMove
			return true
		end
	end
	
	return false
	
end

local function IsCraftedPotion(itemLink)
	if GetItemLinkItemType(itemLink) == ITEMTYPE_POTION or GetItemLinkItemType(itemLink) == ITEMTYPE_POISON then
		if select(24, ZO_LinkHandler_ParseLink(itemLink)) ~= "0" then
			return true
		end
	end
	return false
end

local function GetNumberOfTraits(itemLink)

	local numberOfTraits = 0
	
	for i = 1, GetMaxTraits() do
		
		local hasTraitAbility = GetItemLinkTraitOnUseAbilityInfo(itemLink, i)
		
		if(hasTraitAbility) then
			numberOfTraits = numberOfTraits + 1
		end
		
	end
	
	return numberOfTraits
	
end

-- Rules definitions
function BankManagerRules.addFiltersTaggedAll()
	
	-- "All" will be executed after standard rules to do not interfere
	-- If you want to write a OnlyIfNotFullStack option look at rulename improvementXX
	
	ruleName = "traitAll"
	BankManagerRules.data[ruleName] = {
		-- params which will define if the item analized match the rule. if multiple params, it will be a logical "and"
		params = {
			{
				func = GetItemLinkItemType, -- func to use to check if item will match
				funcArgs = BMR_ITEMLINK,    -- args of function, if BMR_ITEMLINK, BMR will send itemLink, if BMR_BAG_AND_SLOT, BMR will send bagId and slotId
				values = {
					ITEMTYPE_ARMOR_TRAIT,    -- if multiple args, it will be a logical "or"
					ITEMTYPE_WEAPON_TRAIT,
					ITEMTYPE_JEWELRY_TRAIT,
				},
			},
		},
		position = 1, -- rules with the position flag are executed after, then first 1, then 2, then 3.
		name = GetString(SI_ITEMFILTERTYPE0), -- used by LAM, name of the dropdown
		tooltip = zo_strformat("<<1>> & <<2>> & <<3>>", GetString("SI_ITEMTYPE", ITEMTYPE_ARMOR_TRAIT), GetString("SI_ITEMTYPE", ITEMTYPE_WEAPON_TRAIT), GetString("SI_ITEMTYPE", ITEMTYPE_JEWELRY_TRAIT)), -- used by LAM, tooltip of the dropdown
	}
	
	-- Styles All
	ruleName = "styleAll"
	BankManagerRules.data[ruleName] = {
		params = {
			{
				func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_STYLE_MATERIAL, ITEMTYPE_RAW_MATERIAL},
			},
		},
		position = 1,
		name = GetString(SI_ITEMFILTERTYPE0),
		tooltip = zo_strformat("<<1>>", GetString("SI_ITEMTYPE", ITEMTYPE_STYLE_MATERIAL)),
	}
	
	-- Material All Blacksmithing
	ruleName = "MaterialAll" .. CRAFTING_TYPE_BLACKSMITHING
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_BLACKSMITHING_MATERIAL, ITEMTYPE_BLACKSMITHING_RAW_MATERIAL}},
		},
		position = 2,
		name = GetString(SI_ITEMFILTERTYPE0),
		tooltip = zo_strformat("<<1>> & <<2>>", GetString("SI_ITEMTYPE", ITEMTYPE_BLACKSMITHING_MATERIAL), GetString("SI_ITEMTYPE", ITEMTYPE_BLACKSMITHING_RAW_MATERIAL)),
	}
	
	-- Material All Clothier
	ruleName = "MaterialAll" .. CRAFTING_TYPE_CLOTHIER
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_CLOTHIER_MATERIAL, ITEMTYPE_CLOTHIER_RAW_MATERIAL}},
		},
		position = 2,
		name = GetString(SI_ITEMFILTERTYPE0),
		tooltip = zo_strformat("<<1>> & <<2>>", GetString("SI_ITEMTYPE", ITEMTYPE_CLOTHIER_MATERIAL), GetString("SI_ITEMTYPE", ITEMTYPE_CLOTHIER_RAW_MATERIAL)),
	}
	
	-- Material All Woodworking
	ruleName = "MaterialAll" .. CRAFTING_TYPE_WOODWORKING
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_WOODWORKING_MATERIAL, ITEMTYPE_WOODWORKING_RAW_MATERIAL}},
		},
		position = 2,
		name = GetString(SI_ITEMFILTERTYPE0),
		tooltip = zo_strformat("<<1>> & <<2>>", GetString("SI_ITEMTYPE", ITEMTYPE_WOODWORKING_MATERIAL), GetString("SI_ITEMTYPE", ITEMTYPE_WOODWORKING_RAW_MATERIAL)),
	}
	
	-- Material All Jewelcrafting
	ruleName = "MaterialAll" .. CRAFTING_TYPE_JEWELRYCRAFTING
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_JEWELRYCRAFTING_MATERIAL, ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL}},
		},
		position = 2,
		name = GetString(SI_ITEMFILTERTYPE0),
		tooltip = zo_strformat("<<1>> & <<2>>", GetString("SI_ITEMTYPE", ITEMTYPE_JEWELRYCRAFTING_MATERIAL), GetString("SI_ITEMTYPE", ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL)),
	}
	
	-- Refined All Blacksmithing
	ruleName = "refinedMaterialAll" .. CRAFTING_TYPE_BLACKSMITHING
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_BLACKSMITHING_MATERIAL}},
		},
		position = 1,
		name = zo_strformat("<<1>>", GetString("SI_ITEMTYPE", ITEMTYPE_BLACKSMITHING_MATERIAL)),
		tooltip = zo_strformat("<<1>>", GetString("SI_ITEMTYPE", ITEMTYPE_BLACKSMITHING_MATERIAL)),
	}
	
	-- Raw All Blacksmithing
	ruleName = "rawMaterialAll" .. CRAFTING_TYPE_BLACKSMITHING
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_BLACKSMITHING_RAW_MATERIAL}},
		},
		position = 1,
		name = zo_strformat("<<1>>", GetString("SI_ITEMTYPE", ITEMTYPE_BLACKSMITHING_RAW_MATERIAL)),
		tooltip = zo_strformat("<<1>>", GetString("SI_ITEMTYPE", ITEMTYPE_BLACKSMITHING_RAW_MATERIAL)),
	}
	
	-- Refined All Clothier
	ruleName = "refinedMaterialAll" .. CRAFTING_TYPE_CLOTHIER
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_CLOTHIER_MATERIAL}},
		},
		position = 1,
		name = zo_strformat("<<1>>", GetString("SI_ITEMTYPE", ITEMTYPE_CLOTHIER_MATERIAL)),
		tooltip = zo_strformat("<<1>>", GetString("SI_ITEMTYPE", ITEMTYPE_CLOTHIER_MATERIAL)),
	}
	
	-- Raw All Clothier
	ruleName = "rawMaterialAll" .. CRAFTING_TYPE_CLOTHIER
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_CLOTHIER_RAW_MATERIAL}},
		},
		position = 1,
		name = zo_strformat("<<1>>", GetString("SI_ITEMTYPE", ITEMTYPE_CLOTHIER_RAW_MATERIAL)),
		tooltip = zo_strformat("<<1>>", GetString("SI_ITEMTYPE", ITEMTYPE_CLOTHIER_RAW_MATERIAL)),
	}
	
	-- Refined All Woodworking
	ruleName = "refinedMaterialAll" .. CRAFTING_TYPE_WOODWORKING
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_WOODWORKING_MATERIAL}},
		},
		position = 1,
		name = zo_strformat("<<1>>", GetString("SI_ITEMTYPE", ITEMTYPE_WOODWORKING_MATERIAL)),
		tooltip = zo_strformat("<<1>>", GetString("SI_ITEMTYPE", ITEMTYPE_WOODWORKING_MATERIAL)),
	}
	
	-- Refined All Jewelcrafting
	ruleName = "refinedMaterialAll" .. CRAFTING_TYPE_JEWELRYCRAFTING
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_JEWELRYCRAFTING_MATERIAL}},
		},
		position = 1,
		name = zo_strformat("<<1>>", GetString("SI_ITEMTYPE", ITEMTYPE_JEWELRYCRAFTING_MATERIAL)),
		tooltip = zo_strformat("<<1>>", GetString("SI_ITEMTYPE", ITEMTYPE_JEWELRYCRAFTING_MATERIAL)),
	}
	
	-- Raw All Woodworking
	ruleName = "rawMaterialAll" .. CRAFTING_TYPE_WOODWORKING
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_WOODWORKING_RAW_MATERIAL}},
		},
		position = 1,
		name = zo_strformat("<<1>>", GetString("SI_ITEMTYPE", ITEMTYPE_WOODWORKING_RAW_MATERIAL)),
		tooltip = zo_strformat("<<1>>", GetString("SI_ITEMTYPE", ITEMTYPE_WOODWORKING_RAW_MATERIAL)),
	}
	
	-- Raw All Jewelcrafting
	ruleName = "rawMaterialAll" .. CRAFTING_TYPE_JEWELRYCRAFTING
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL}},
		},
		position = 1,
		name = zo_strformat("<<1>>", GetString("SI_ITEMTYPE", ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL)),
		tooltip = zo_strformat("<<1>>", GetString("SI_ITEMTYPE", ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL)),
	}
	
	-- Enchanting All
	ruleName = "enchantingAll"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_ENCHANTING_RUNE_ESSENCE, ITEMTYPE_ENCHANTING_RUNE_POTENCY, ITEMTYPE_ENCHANTING_RUNE_ASPECT}},
		},
		position = 1,
		name = GetString(SI_ITEMFILTERTYPE0),
		tooltip = zo_strformat("<<1>>, <<2>>, <<3>>", GetString("SI_ITEMTYPE", ITEMTYPE_ENCHANTING_RUNE_ESSENCE), GetString("SI_ITEMTYPE", ITEMTYPE_ENCHANTING_RUNE_POTENCY), GetString("SI_ITEMTYPE", ITEMTYPE_ENCHANTING_RUNE_ASPECT)),
	}
	
	-- Alchemy All
	ruleName = "alchemyAll"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_POTION_BASE, ITEMTYPE_POISON_BASE, ITEMTYPE_REAGENT}},
		},
		position = 1,
		name = GetString(SI_ITEMFILTERTYPE0),
		tooltip = zo_strformat("<<1>>, <<2>> & <<3>>", GetString("SI_ITEMTYPE", ITEMTYPE_POTION_BASE), GetString("SI_ITEMTYPE", ITEMTYPE_POISON_BASE), GetString("SI_ITEMTYPE", ITEMTYPE_REAGENT)),
	}
	
	-- This rule won't be executed, it's a placeholder for the OnlyIfNotFullStack
	-- CRAFTING_TYPE_BLACKSMITHING Improvement All
	ruleName = "improvementAll" .. CRAFTING_TYPE_BLACKSMITHING
	BankManagerRules.data[ruleName] = {
		true, -- Don't write params section or rule will be executed. ruleName will be the Lua var to store the value
	}
	
	-- no .action here, it's unneeded, there is no rule behind this filter definition
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].onlyIfNotFullStack = true
	
	-- improvementStacks CRAFTING_TYPE_BLACKSMITHING
	ruleName = "improvementStacks" .. CRAFTING_TYPE_BLACKSMITHING
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].onlyStacks = 1
	
	-- improvementStacks CRAFTING_TYPE_BLACKSMITHING GBank
	ruleName = "improvementGBank" .. CRAFTING_TYPE_BLACKSMITHING
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].associatedGuild = GetString(BMR_ACTION_NOTSET)
	
	-- CRAFTING_TYPE_CLOTHIER Improvement All
	ruleName = "improvementAll" .. CRAFTING_TYPE_CLOTHIER
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].onlyIfNotFullStack = true
	
	-- improvementStacks CRAFTING_TYPE_CLOTHIER
	ruleName = "improvementStacks" .. CRAFTING_TYPE_CLOTHIER
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].onlyStacks = 1
	
	-- improvementStacks CRAFTING_TYPE_CLOTHIER GBank
	ruleName = "improvementGBank" .. CRAFTING_TYPE_CLOTHIER
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].associatedGuild = GetString(BMR_ACTION_NOTSET)
	
	-- CRAFTING_TYPE_WOODWORKING Improvement All
	ruleName = "improvementAll" .. CRAFTING_TYPE_WOODWORKING
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].onlyIfNotFullStack = true
	
	-- improvementStacks CRAFTING_TYPE_WOODWORKING
	ruleName = "improvementStacks" .. CRAFTING_TYPE_WOODWORKING
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].onlyStacks = 1
	
	-- improvementStacks CRAFTING_TYPE_WOODWORKING GBank
	ruleName = "improvementGBank" .. CRAFTING_TYPE_WOODWORKING
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].associatedGuild = GetString(BMR_ACTION_NOTSET)
	
	-- CRAFTING_TYPE_JEWELRYCRAFTING Improvement All
	ruleName = "improvementAll" .. CRAFTING_TYPE_JEWELRYCRAFTING
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].onlyIfNotFullStack = true
	
	-- improvementStacks CRAFTING_TYPE_JEWELRYCRAFTING
	ruleName = "improvementStacks" .. CRAFTING_TYPE_JEWELRYCRAFTING
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].onlyStacks = 1
	
	-- improvementStacks CRAFTING_TYPE_JEWELRYCRAFTING GBank
	ruleName = "improvementGBank" .. CRAFTING_TYPE_JEWELRYCRAFTING
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].associatedGuild = GetString(BMR_ACTION_NOTSET)
	
	-- (CRAFTING_TYPE_JEWELRYCRAFTING * 100) Improvement All
	ruleName = "improvementAll" .. (CRAFTING_TYPE_JEWELRYCRAFTING * 100)
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].onlyIfNotFullStack = true
	
	-- improvementStacks (CRAFTING_TYPE_JEWELRYCRAFTING * 100)
	ruleName = "improvementStacks" .. (CRAFTING_TYPE_JEWELRYCRAFTING * 100)
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].onlyStacks = 1
	
	-- improvementStacks (CRAFTING_TYPE_JEWELRYCRAFTING * 100) GBank
	ruleName = "improvementGBank" .. (CRAFTING_TYPE_JEWELRYCRAFTING * 100)
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].associatedGuild = GetString(BMR_ACTION_NOTSET)
	
	-- CRAFTING_TYPE_BLACKSMITHING Material Stacks
	ruleName = "MaterialStacks" .. CRAFTING_TYPE_BLACKSMITHING
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].onlyStacks = 1
	
	-- CRAFTING_TYPE_BLACKSMITHING Material GBank
	ruleName = "MaterialGBank" .. CRAFTING_TYPE_BLACKSMITHING
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].associatedGuild = GetString(BMR_ACTION_NOTSET)
	
	-- CRAFTING_TYPE_CLOTHIER Material Stacks
	ruleName = "MaterialStacks" .. CRAFTING_TYPE_CLOTHIER
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].onlyStacks = 1
	
	-- CRAFTING_TYPE_CLOTHIER Material GBank
	ruleName = "MaterialGBank" .. CRAFTING_TYPE_CLOTHIER
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].associatedGuild = GetString(BMR_ACTION_NOTSET)
	
	-- CRAFTING_TYPE_WOODWORKING Material Stacks
	ruleName = "MaterialStacks" .. CRAFTING_TYPE_WOODWORKING
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].onlyStacks = 1
	
	-- CRAFTING_TYPE_WOODWORKING Material GBank
	ruleName = "MaterialGBank" .. CRAFTING_TYPE_WOODWORKING
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].associatedGuild = GetString(BMR_ACTION_NOTSET)
	
	-- CRAFTING_TYPE_JEWELRYCRAFTING Material Stacks
	ruleName = "MaterialStacks" .. CRAFTING_TYPE_JEWELRYCRAFTING
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].onlyStacks = 1
	
	-- CRAFTING_TYPE_JEWELRYCRAFTING Material GBank
	ruleName = "MaterialGBank" .. CRAFTING_TYPE_JEWELRYCRAFTING
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].associatedGuild = GetString(BMR_ACTION_NOTSET)
	
	-- CookingIngredients All
	ruleName = "cookingIngredientsAll"
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].onlyIfNotFullStack = true
	
	-- CookingIngredients Stacks
	ruleName = "cookingIngredientsStacks"
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].onlyStacks = 1
	
	-- CookingIngredients GBank
	ruleName = "cookingIngredientsGBank"
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].associatedGuild = GetString(BMR_ACTION_NOTSET)
	
	-- cookingRecipeGBank GBank
	ruleName = "cookingRecipeGBank"
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].associatedGuild = GetString(BMR_ACTION_NOTSET)
	
	-- enchantingStacks
	ruleName = "enchantingStacks"
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].onlyStacks = 1
	
	-- enchanting GBank
	ruleName = "enchantingGBank"
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].associatedGuild = GetString(BMR_ACTION_NOTSET)
	
	-- enchantingGlyphs GBank
	ruleName = "enchantingGlyphsGBank"
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].associatedGuild = GetString(BMR_ACTION_NOTSET)
	
	-- alchemy Stacks
	ruleName = "alchemyStacks"
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].onlyStacks = 1
	
	-- alchemy GBank
	ruleName = "alchemyGBank"
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].associatedGuild = GetString(BMR_ACTION_NOTSET)
	
	-- trait Stacks
	ruleName = "traitStacks"
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].onlyStacks = 1
	
	-- trait GBank
	ruleName = "traitGBank"
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].associatedGuild = GetString(BMR_ACTION_NOTSET)
	
	-- style Stacks
	ruleName = "styleStacks"
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].onlyStacks = 1
	
	-- style GBank
	ruleName = "styleGBank"
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].associatedGuild = GetString(BMR_ACTION_NOTSET)
	
	-- Trophy All
	ruleName = "trophyAll"
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].onlyIfNotFullStack = true
	
	-- Trophy Stacks
	ruleName = "trophyStacks"
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].onlyStacks = 1
	
	-- Trophy GBank
	ruleName = "trophyGBank"
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].associatedGuild = GetString(BMR_ACTION_NOTSET)
	
	-- Misc All
	ruleName = "MiscAll"
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].onlyIfNotFullStack = true
	
	-- Misc Stacks
	ruleName = "MiscStacks"
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].onlyStacks = 1
	
	-- Misc GBank
	ruleName = "MiscGBank"
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].associatedGuild = GetString(BMR_ACTION_NOTSET)
	
	-- Housing All
	ruleName = "HousingAll"
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].onlyIfNotFullStack = true
	
	-- Housing Stacks
	ruleName = "HousingStacks"
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].onlyStacks = 1
	
	-- Housing GBank
	ruleName = "HousingGBank"
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].associatedGuild = GetString(BMR_ACTION_NOTSET)
	
	-- Writ Quests
	ruleName = "writsQuests"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_POTION_BASE, ITEMTYPE_REAGENT, ITEMTYPE_ENCHANTING_RUNE_ASPECT, ITEMTYPE_ENCHANTING_RUNE_ESSENCE, ITEMTYPE_ENCHANTING_RUNE_POTENCY, ITEMTYPE_FOOD, ITEMTYPE_DRINK}},
			{func = IsWritItem, funcArgs = BMR_ITEMLINK, values = {true}},
		},
		name = GetString(BMR_WRIT_QUESTS),
		tooltip = GetString(BMR_WRIT_QUESTS_TOOLTIP),
		isSpecial = true,
	}
	
	-- Writ defaults
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].specialEnabled = false
	
	-- Writ Quests
	ruleName = "writsQuestsGlyphs"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_GLYPH_ARMOR}},
			{func = GetItemLinkQuality, funcArgs = BMR_ITEMLINK, values = {ITEM_QUALITY_NORMAL}},
			{func = IsItemLinkCrafted, funcArgs = BMR_ITEMLINK, values = {true}},
			{func = GetItemCreatorName, funcArgs = BMR_BAG_AND_SLOT, values = {GetUnitName("player")}},
			{func = IsWritItem, funcArgs = BMR_ITEMLINK, values = {true}},
		},
		name = GetString(BMR_WRIT_QUESTS),
		tooltip = GetString(BMR_WRIT_QUESTS_TOOLTIP),
		isSpecial = true,
	}
	
	-- Writ defaults
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].specialEnabled = false
	
	-- Writ Quests
	ruleName = "writsQuestsPots"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_POTION}},
			{func = IsCraftedPotion, funcArgs = BMR_ITEMLINK, values = {true}},
			{func = GetNumberOfTraits, funcArgs = BMR_ITEMLINK, values = {1}},
			{func = IsWritItem, funcArgs = BMR_ITEMLINK, values = {true}},
		},
		name = GetString(BMR_WRIT_QUESTS),
		tooltip = GetString(BMR_WRIT_QUESTS_TOOLTIP),
		isSpecial = true,
	}
	
	-- Writ defaults
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].specialEnabled = false	
	
	--MasterWrit All
	ruleName = "questAll"
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].onlyIfNotFullStack = true
	
	-- MasterWrit Stacks
	ruleName = "questStacks"
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].onlyStacks = 1
	
	-- MasterWrit GBank
	ruleName = "questGBank"
	BankManagerRules.data[ruleName] = {true}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].associatedGuild = GetString(BMR_ACTION_NOTSET)
	
	-- To help sorting array
	for ruleName, ruleData in pairs(BankManagerRules.data) do
		ruleData.ruleName = ruleName
	end
	
end

-- Add a filter to BMR rules
function BankManagerRules.addFilters()

	-- Special rule (currency)
	ruleName = "currency" .. CURT_MONEY
	BankManagerRules.data[ruleName] = {
		currencyType = CURT_MONEY, -- Currency to move
		min = 0, -- Used by LAM
		max = 1000000,
		step = 250,
	}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].qtyToPull = 0
	BankManagerRules.defaults[ruleName].qtyToPush = 0
	BankManagerRules.defaults[ruleName].keepNothing = false -- If slider is 0, is action to pull all at bank or it's just unset ?
	BankManagerRules.defaults[ruleName].keepInBank = false -- If user prefer to Keep the desired amount in bank
	
	-- Special rule (currency)
	ruleName = "currency" .. CURT_TELVAR_STONES
	BankManagerRules.data[ruleName] = {
		currencyType = CURT_TELVAR_STONES,
		min = 0,
		max = 100000,
		step = 100,
	}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].qtyToPull = 0
	BankManagerRules.defaults[ruleName].qtyToPush = 0
	BankManagerRules.defaults[ruleName].keepNothing = false
	BankManagerRules.defaults[ruleName].keepInBank = false
	
	-- Special rule (currency)
	ruleName = "currency" .. CURT_ALLIANCE_POINTS
	BankManagerRules.data[ruleName] = {
		currencyType = CURT_ALLIANCE_POINTS, -- Currency to move
		min = 0, -- Used by LAM
		max = 1000000,
		step = 250,
	}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].qtyToPull = 0
	BankManagerRules.defaults[ruleName].qtyToPush = 0
	BankManagerRules.defaults[ruleName].keepNothing = false -- If slider is 0, is action to pull all at bank or it's just unset ?
	BankManagerRules.defaults[ruleName].keepInBank = false -- If user prefer to Keep the desired amount in bank
	
	-- Special rule (currency)
	ruleName = "currency" .. CURT_WRIT_VOUCHERS
	BankManagerRules.data[ruleName] = {
		currencyType = CURT_WRIT_VOUCHERS, -- Currency to move
		min = 0, -- Used by LAM
		max = 5000,
		step = 25,
	}
	
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].qtyToPull = 0
	BankManagerRules.defaults[ruleName].qtyToPush = 0
	BankManagerRules.defaults[ruleName].keepNothing = false -- If slider is 0, is action to pull all at bank or it's just unset ?
	BankManagerRules.defaults[ruleName].keepInBank = false -- If user prefer to Keep the desired amount in bank
	
	-- To get an exemple of correct definition, please look at addFiltersTaggedAll()

	-- Traits
   for traitItemIndex = 1, GetNumSmithingTraitItems() do
	
      local traitType, itemName = GetSmithingTraitItemInfo(traitItemIndex)
      local itemLink = GetSmithingTraitItemLink(traitItemIndex, LINK_STYLE_DEFAULT)
      local itemType = GetItemLinkItemType(itemLink)
	  
      if itemType ~= ITEMTYPE_NONE and traitType ~= ITEM_TRAIT_TYPE_NONE then 
			
			ruleName = "trait" .. traitType
			BankManagerRules.data[ruleName] = {
				params = {
					{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_ARMOR_TRAIT, ITEMTYPE_WEAPON_TRAIT, ITEMTYPE_JEWELRY_TRAIT}},
					{func = GetItemLinkTraitInfo, funcArgs = BMR_ITEMLINK, values = {traitType}},
				},
				name = zo_strformat(SI_TOOLTIP_ITEM_NAME, itemLink),
				tooltip = zo_strformat("<<1>>: <<2>>", GetString("SI_ITEMTYPE", itemType), GetString("SI_ITEMTRAITTYPE", traitType)),
			}
			
      end
   end
	
	-- Styles
	
	-- Raw Sytles
	
	for styleItemIndex, data in pairs(BankManagerRules.static.rawStyles) do
	
		ruleName = "styleRaw" .. styleItemIndex
		BankManagerRules.data[ruleName] = {
			params = {
				{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_RAW_MATERIAL}},
				{func = GetItemLinkItemId, funcArgs = BMR_ITEMLINK, values = {GetItemLinkItemId(data)}},
			},
			name = zo_strformat("<<1>> (<<2>>)", GetItemStyleName(styleItemIndex), GetItemLinkName(data)),
			tooltip = zo_strformat("<<1>> (<<2>>)", GetItemStyleName(styleItemIndex), GetItemLinkName(data)),
		}
	
	end
	-- Raw Traits
	
	for rawItemIndex, data in pairs(BankManagerRules.static.jewelrycraftingRawTraits) do
	
		ruleName = "jewelTraitRaw" .. rawItemIndex
		BankManagerRules.data[ruleName] = {
			params = {
				{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_JEWELRY_RAW_TRAIT}},
				{func = GetItemLinkItemId, funcArgs = BMR_ITEMLINK, values = {GetItemLinkItemId(data)}},
			},
			name = zo_strformat("<<1>>", GetItemLinkName(data)),
			tooltip = zo_strformat("<<1>>", GetItemLinkName(data)),
		}
	
	end
	
	-- Refined Styles
   for styleItemIndex = 1, GetHighestItemStyleId() do
	
		local styleItemLink = GetItemStyleMaterialLink(styleItemIndex)
		local itemName = GetItemLinkName(styleItemLink)
		local _, _, meetsUsageRequirement = GetItemLinkInfo(styleItemLink)
		
      if meetsUsageRequirement then
			
			ruleName = "style" .. styleItemIndex
			
			BankManagerRules.data[ruleName] = {
				params = {
					{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_STYLE_MATERIAL}},
					{func = GetItemLinkItemStyle, funcArgs = BMR_ITEMLINK, values = {styleItemIndex}},
				},
				name = zo_strformat("<<1>> (<<2>>)", GetItemStyleName(styleItemIndex), zo_strformat(SI_TOOLTIP_ITEM_NAME, itemName)),
				tooltip = zo_strformat("<<1>> (<<2>>)", GetItemStyleName(styleItemIndex), zo_strformat(SI_TOOLTIP_ITEM_NAME, itemName)),
			}
			
		end
	end
	
	-- Booster Items
	local function addBoosters(craftId, craftBooster, sub, prefix)
	
		for improvementItemIndex = 1, GetNumSmithingImprovementItems() do
		
			local itemName, _, _, _, _, _, _, quality = GetSmithingImprovementItemInfo(craftId, improvementItemIndex)
			sub = sub or 1
			prefix = prefix or ''
			ruleName = "improvement" .. (craftId * sub) .. improvementItemIndex
			local color = GetItemQualityColor(quality)
			
			BankManagerRules.data[ruleName] = {
				params = {
					{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {craftBooster}},
					{func = GetItemLinkQuality, funcArgs = BMR_ITEMLINK, values = {quality}},
				},
				name = zo_strformat("<<1>>", color:Colorize(zo_strformat(SI_TOOLTIP_ITEM_NAME, prefix .. itemName))),
				tooltip = zo_strformat("<<2>> (<<1>>)", GetString("SI_ITEMTYPE", craftBooster), zo_strformat(SI_TOOLTIP_ITEM_NAME, prefix .. itemName)),
			}
				
		end
	end
	
	addBoosters(CRAFTING_TYPE_BLACKSMITHING, ITEMTYPE_BLACKSMITHING_BOOSTER)
	addBoosters(CRAFTING_TYPE_CLOTHIER, ITEMTYPE_CLOTHIER_BOOSTER)
	addBoosters(CRAFTING_TYPE_WOODWORKING, ITEMTYPE_WOODWORKING_BOOSTER)
	addBoosters(CRAFTING_TYPE_JEWELRYCRAFTING, ITEMTYPE_JEWELRYCRAFTING_BOOSTER)
	addBoosters(CRAFTING_TYPE_JEWELRYCRAFTING, ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER, 100, 'Raw ')
	
	-- Raw material - Impossible without interacting with a crafting station.
	-- Refined material - Impossible without interacting with a crafting station.
	local function addMaterial(craftId, refinedMaterialType, rawMaterialType, refinedMaterialArray, rawMaterialArray)
		
		for materialIndex = 1, #refinedMaterialArray do
			
			if refinedMaterialArray[materialIndex] ~= "" then
				
				ruleName = "refinedMaterial" .. craftId .. materialIndex
				BankManagerRules.data[ruleName] = {
					params = {
						{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {refinedMaterialType}},
						{func = GetItemLinkItemId, funcArgs = BMR_ITEMLINK, values = {GetItemLinkItemId(refinedMaterialArray[materialIndex])}},
					},
					name = zo_strformat("<<1>>", zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(refinedMaterialArray[materialIndex]))),
					tooltip = zo_strformat("<<1>>", zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(refinedMaterialArray[materialIndex]))),
				}
				
			end
			
			if rawMaterialArray[materialIndex] ~= "" then
			
				ruleName = "rawMaterial" .. craftId .. materialIndex
				BankManagerRules.data[ruleName] = {
					params = {
						{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {rawMaterialType}},
						{func = GetItemLinkItemId, funcArgs = BMR_ITEMLINK, values = {GetItemLinkItemId(rawMaterialArray[materialIndex])}},
					},
					name = zo_strformat("<<1>>", zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(rawMaterialArray[materialIndex]))),
					tooltip = zo_strformat("<<1>>", zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(rawMaterialArray[materialIndex]))),
				}
					
			end
		end
	end
	
	addMaterial(CRAFTING_TYPE_BLACKSMITHING, ITEMTYPE_BLACKSMITHING_MATERIAL, ITEMTYPE_BLACKSMITHING_RAW_MATERIAL, BankManagerRules.static.refinedMaterial[CRAFTING_TYPE_BLACKSMITHING], BankManagerRules.static.rawMaterial[CRAFTING_TYPE_BLACKSMITHING])
	addMaterial(CRAFTING_TYPE_CLOTHIER, ITEMTYPE_CLOTHIER_MATERIAL, ITEMTYPE_CLOTHIER_RAW_MATERIAL, BankManagerRules.static.refinedMaterial[CRAFTING_TYPE_CLOTHIER], BankManagerRules.static.rawMaterial[CRAFTING_TYPE_CLOTHIER])
	addMaterial(CRAFTING_TYPE_CLOTHIER * 100, ITEMTYPE_CLOTHIER_MATERIAL, ITEMTYPE_CLOTHIER_RAW_MATERIAL, BankManagerRules.static.refinedMaterial[CRAFTING_TYPE_CLOTHIER * 100], BankManagerRules.static.rawMaterial[CRAFTING_TYPE_CLOTHIER * 100])
	addMaterial(CRAFTING_TYPE_WOODWORKING, ITEMTYPE_WOODWORKING_MATERIAL, ITEMTYPE_WOODWORKING_RAW_MATERIAL, BankManagerRules.static.refinedMaterial[CRAFTING_TYPE_WOODWORKING], BankManagerRules.static.rawMaterial[CRAFTING_TYPE_WOODWORKING])
	-- jewelcraft
	addMaterial(CRAFTING_TYPE_JEWELRYCRAFTING, ITEMTYPE_JEWELRYCRAFTING_MATERIAL, ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL, BankManagerRules.static.refinedMaterial[CRAFTING_TYPE_JEWELRYCRAFTING], BankManagerRules.static.rawMaterial[CRAFTING_TYPE_JEWELRYCRAFTING])
	
	-- Jewelry
	ruleName = "jewelry" -- is not complete or wrong standalone
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {EQUIP_TYPE_NECK, EQUIP_TYPE_RING}},
		},
		name = EsoStrings[1673], -- there's no ItemType for Jewelry
		tooltip = EsoStrings[1673],
	}
	
	-- JewelryGBank
	ruleName = "jewelryGBank"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {EQUIP_TYPE_NECK, EQUIP_TYPE_RING}},
		},
		name = EsoStrings[1673], -- there's no ItemType for Jewelry
		tooltip = EsoStrings[1673],
	}

	-- JewelryAll
	ruleName = "jewelryAll"  -- is not complete or wrong standalone
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {EQUIP_TYPE_NECK, EQUIP_TYPE_RING}},
		},
		name = EsoStrings[1673], -- there's no ItemType for Jewelry
		tooltip = EsoStrings[1673],
	}

	-- JewelryStacks
	ruleName = "jewelryStacks"-- .. CRAFTING_TYPE_JEWELRYCRAFTING
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {EQUIP_TYPE_NECK, EQUIP_TYPE_RING}},
		},
		name = EsoStrings[1673], -- there's no ItemType for Jewelry
		tooltip = EsoStrings[1673],
	}
	BankManagerRules.defaults[ruleName] = {}
	BankManagerRules.defaults[ruleName].onlyStacks = 1

	-- Intricate Jewelry
	ruleName = "jewelryIntricate"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {EQUIP_TYPE_NECK, EQUIP_TYPE_RING}},
			{func = GetItemLinkSetInfo, funcArgs = BMR_ITEMLINK, values = {false}},
			{func = IsItemJunk, funcArgs = BMR_BAG_AND_SLOT, values = {false}},
			{func = GetItemLinkTraitInfo, funcArgs = BMR_ITEMLINK, values = {ITEM_TRAIT_TYPE_JEWELRY_INTRICATE}},
		},
		name = zo_strformat("<<1>> (<<2>>)", EsoStrings[1673], GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_JEWELRY_INTRICATE)),
		tooltip = zo_strformat("<<1>> (<<2>>)", EsoStrings[1673], GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_JEWELRY_INTRICATE)),
	}

	-- Researchable Jewelry
	ruleName = "jewelryResearchable" -- might be wrong because it takes out all armor you are able to research
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {EQUIP_TYPE_NECK, EQUIP_TYPE_RING}},
			{func = GetItemLinkSetInfo, funcArgs = BMR_ITEMLINK, values = {false}},
			{func = IsItemJunk, funcArgs = BMR_BAG_AND_SLOT, values = {false}},
			{func = IsItemNeededForResearch, funcArgs = BMR_ITEMLINK, values = {true}},
		},
		name = zo_strformat("<<1>> (<<2>>)", EsoStrings[1673], GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)),
		tooltip = zo_strformat("<<1>> (<<2>>)", EsoStrings[1673], GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)),
	}
	
	-- Heavy Armors
	ruleName = "armorTypeWeight" .. ARMORTYPE_HEAVY
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_ARMOR}},
			{func = GetItemLinkArmorType, funcArgs = BMR_ITEMLINK, values = {ARMORTYPE_HEAVY}},
			{func = GetItemLinkSetInfo, funcArgs = BMR_ITEMLINK, values = {false}},
			{func = IsItemJunk, funcArgs = BMR_BAG_AND_SLOT, values = {false}},
		},
		name = zo_strformat("<<1>> : <<2>>", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetString("SI_ARMORTYPE", ARMORTYPE_HEAVY)),
		tooltip = zo_strformat("<<1>> : <<2>>", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetString("SI_ARMORTYPE", ARMORTYPE_HEAVY)),
	}
	
	-- Medium Armors
	ruleName = "armorTypeWeight" .. ARMORTYPE_MEDIUM
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_ARMOR}},
			{func = GetItemLinkArmorType, funcArgs = BMR_ITEMLINK, values = {ARMORTYPE_MEDIUM}},
			{func = GetItemLinkSetInfo, funcArgs = BMR_ITEMLINK, values = {false}},
			{func = IsItemJunk, funcArgs = BMR_BAG_AND_SLOT, values = {false}},
		},
		name = zo_strformat("<<1>> : <<2>>", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetString("SI_ARMORTYPE", ARMORTYPE_MEDIUM)),
		tooltip = zo_strformat("<<1>> : <<2>>", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetString("SI_ARMORTYPE", ARMORTYPE_MEDIUM)),
	}
	
	-- Light Armors
	ruleName = "armorTypeWeight" .. ARMORTYPE_LIGHT
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_ARMOR}},
			{func = GetItemLinkArmorType, funcArgs = BMR_ITEMLINK, values = {ARMORTYPE_LIGHT}},
			{func = GetItemLinkSetInfo, funcArgs = BMR_ITEMLINK, values = {false}},
			{func = IsItemJunk, funcArgs = BMR_BAG_AND_SLOT, values = {false}},
		},
		name = zo_strformat("<<1>> : <<2>>", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetString("SI_ARMORTYPE", ARMORTYPE_LIGHT)),
		tooltip = zo_strformat("<<1>> : <<2>>", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetString("SI_ARMORTYPE", ARMORTYPE_LIGHT)),
	}
	
	-- Light Armors
	ruleName = "armorQuality" .. ARMORTYPE_LIGHT
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_ARMOR}},
			{func = GetItemLinkArmorType, funcArgs = BMR_ITEMLINK, values = {ARMORTYPE_LIGHT}},
			{func = GetItemLinkSetInfo, funcArgs = BMR_ITEMLINK, values = {false}},
			{func = IsItemJunk, funcArgs = BMR_BAG_AND_SLOT, values = {false}},
		},
		name = zo_strformat("<<1>> : <<2>>", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetString("SI_ARMORTYPE", ARMORTYPE_LIGHT)),
		tooltip = zo_strformat("<<1>> : <<2>>", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetString("SI_ARMORTYPE", ARMORTYPE_LIGHT)),
	}
	
	-- Intricate Heavy Armors
	ruleName = "armorTypeTrait" .. ITEM_TRAIT_TYPE_ARMOR_INTRICATE .. "Weight" .. ARMORTYPE_HEAVY
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_ARMOR}},
			{func = GetItemLinkArmorType, funcArgs = BMR_ITEMLINK, values = {ARMORTYPE_HEAVY}},
			{func = GetItemLinkSetInfo, funcArgs = BMR_ITEMLINK, values = {false}},
			{func = IsItemJunk, funcArgs = BMR_BAG_AND_SLOT, values = {false}},
			{func = GetItemLinkTraitInfo, funcArgs = BMR_ITEMLINK, values = {ITEM_TRAIT_TYPE_ARMOR_INTRICATE}},
		},
		name = zo_strformat("<<1>> : <<2>> (<<3>>)", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetString("SI_ARMORTYPE", ARMORTYPE_HEAVY), GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_INTRICATE)),
		tooltip = zo_strformat("<<1>> : <<2>> (<<3>>)", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetString("SI_ARMORTYPE", ARMORTYPE_HEAVY), GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_INTRICATE)),
	}
	
	-- Intricate Medium Armors
	ruleName = "armorTypeTrait" .. ITEM_TRAIT_TYPE_ARMOR_INTRICATE .. "Weight" .. ARMORTYPE_MEDIUM
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_ARMOR}},
			{func = GetItemLinkArmorType, funcArgs = BMR_ITEMLINK, values = {ARMORTYPE_MEDIUM}},
			{func = GetItemLinkSetInfo, funcArgs = BMR_ITEMLINK, values = {false}},
			{func = IsItemJunk, funcArgs = BMR_BAG_AND_SLOT, values = {false}},
			{func = GetItemLinkTraitInfo, funcArgs = BMR_ITEMLINK, values = {ITEM_TRAIT_TYPE_ARMOR_INTRICATE}},
		},
		name = zo_strformat("<<1>> : <<2>> (<<3>>)", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetString("SI_ARMORTYPE", ARMORTYPE_MEDIUM), GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_INTRICATE)),
		tooltip = zo_strformat("<<1>> : <<2>> (<<3>>)", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetString("SI_ARMORTYPE", ARMORTYPE_MEDIUM), GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_INTRICATE)),
	}

	-- Intricate Light Armors
	ruleName = "armorTypeTrait" .. ITEM_TRAIT_TYPE_ARMOR_INTRICATE .. "Weight" .. ARMORTYPE_LIGHT
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_ARMOR}},
			{func = GetItemLinkArmorType, funcArgs = BMR_ITEMLINK, values = {ARMORTYPE_LIGHT}},
			{func = GetItemLinkSetInfo, funcArgs = BMR_ITEMLINK, values = {false}},
			{func = IsItemJunk, funcArgs = BMR_BAG_AND_SLOT, values = {false}},
			{func = GetItemLinkTraitInfo, funcArgs = BMR_ITEMLINK, values = {ITEM_TRAIT_TYPE_ARMOR_INTRICATE}},
		},
		name = zo_strformat("<<1>> : <<2>> (<<3>>)", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetString("SI_ARMORTYPE", ARMORTYPE_LIGHT), GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_INTRICATE)),
		tooltip = zo_strformat("<<1>> : <<2>> (<<3>>)", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetString("SI_ARMORTYPE", ARMORTYPE_LIGHT), GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_INTRICATE)),
	}
	
	-- Weapons (smithing)
	ruleName = "weaponType" .. CRAFTING_TYPE_BLACKSMITHING
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_WEAPON}},
			{func = GetItemLinkWeaponType, funcArgs = BMR_ITEMLINK, values = {WEAPONTYPE_AXE, WEAPONTYPE_DAGGER, WEAPONTYPE_HAMMER, WEAPONTYPE_SWORD, WEAPONTYPE_TWO_HANDED_AXE, WEAPONTYPE_TWO_HANDED_HAMMER, WEAPONTYPE_TWO_HANDED_SWORD}},
			{func = GetItemLinkSetInfo, funcArgs = BMR_ITEMLINK, values = {false}},
			{func = IsItemJunk, funcArgs = BMR_BAG_AND_SLOT, values = {false}},
		},
		name = zo_strformat("<<1>> : <<2>>", GetString("SI_ITEMTYPE", ITEMTYPE_WEAPON), GetString(BMR_TRADESKILL_BLACKSMITHING)),
		tooltip = zo_strformat("<<1>> : <<2>>", GetString("SI_ITEMTYPE", ITEMTYPE_WEAPON), GetString(BMR_TRADESKILL_BLACKSMITHING)),
	}
	
	-- Weapons (Woodworking)
	ruleName = "weaponType" .. CRAFTING_TYPE_WOODWORKING
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_WEAPON}},
			{func = GetItemLinkWeaponType, funcArgs = BMR_ITEMLINK, values = {WEAPONTYPE_BOW, WEAPONTYPE_FIRE_STAFF, WEAPONTYPE_FROST_STAFF, WEAPONTYPE_LIGHTNING_STAFF, WEAPONTYPE_HEALING_STAFF, WEAPONTYPE_SHIELD}},
			{func = GetItemLinkSetInfo, funcArgs = BMR_ITEMLINK, values = {false}},
			{func = IsItemJunk, funcArgs = BMR_BAG_AND_SLOT, values = {false}},
		},
		name = zo_strformat("<<1>> & <<2>> : <<3>>", GetString("SI_ITEMTYPE", ITEMTYPE_WEAPON), GetString("SI_WEAPONTYPE", WEAPONTYPE_SHIELD), GetString(BMR_TRADESKILL_WOODWORKING)),
		tooltip = zo_strformat("<<1>> & <<2>> : <<3>>", GetString("SI_ITEMTYPE", ITEMTYPE_WEAPON), GetString("SI_WEAPONTYPE", WEAPONTYPE_SHIELD), GetString(BMR_TRADESKILL_WOODWORKING)),
	}
	
	-- Intricate Weapons (smithing)
	ruleName = "weaponType" .. CRAFTING_TYPE_BLACKSMITHING .. "Trait" .. ITEM_TRAIT_TYPE_WEAPON_INTRICATE
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_WEAPON}},
			{func = GetItemLinkWeaponType, funcArgs = BMR_ITEMLINK, values = {WEAPONTYPE_AXE, WEAPONTYPE_DAGGER, WEAPONTYPE_HAMMER, WEAPONTYPE_SWORD, WEAPONTYPE_TWO_HANDED_AXE, WEAPONTYPE_TWO_HANDED_HAMMER, WEAPONTYPE_TWO_HANDED_SWORD}},
			{func = GetItemLinkSetInfo, funcArgs = BMR_ITEMLINK, values = {false}},
			{func = IsItemJunk, funcArgs = BMR_BAG_AND_SLOT, values = {false}},
			{func = GetItemLinkTraitInfo, funcArgs = BMR_ITEMLINK, values = {ITEM_TRAIT_TYPE_WEAPON_INTRICATE}},
		},
		name = zo_strformat("<<1>> : <<2>> (<<3>>)", GetString("SI_ITEMTYPE", ITEMTYPE_WEAPON), GetString(BMR_TRADESKILL_BLACKSMITHING), GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_INTRICATE)),
		tooltip = zo_strformat("<<1>> : <<2>> (<<3>>)", GetString("SI_ITEMTYPE", ITEMTYPE_WEAPON), GetString(BMR_TRADESKILL_BLACKSMITHING), GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_INTRICATE)),
	}
	
	-- Intricate (Woodworking)
	ruleName = "weaponType" .. CRAFTING_TYPE_WOODWORKING .. "Trait" .. ITEM_TRAIT_TYPE_ARMOR_INTRICATE
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_WEAPON}},
			{func = GetItemLinkWeaponType, funcArgs = BMR_ITEMLINK, values = {WEAPONTYPE_BOW, WEAPONTYPE_FIRE_STAFF, WEAPONTYPE_FROST_STAFF, WEAPONTYPE_LIGHTNING_STAFF, WEAPONTYPE_HEALING_STAFF, WEAPONTYPE_SHIELD}},
			{func = GetItemLinkSetInfo, funcArgs = BMR_ITEMLINK, values = {false}},
			{func = IsItemJunk, funcArgs = BMR_BAG_AND_SLOT, values = {false}},
			{func = GetItemLinkTraitInfo, funcArgs = BMR_ITEMLINK, values = {ITEM_TRAIT_TYPE_ARMOR_INTRICATE, ITEM_TRAIT_TYPE_WEAPON_INTRICATE}},
		},
		name = zo_strformat("<<1>> & <<2>> : <<3>> (<<4>>)", GetString("SI_ITEMTYPE", ITEMTYPE_WEAPON), GetString("SI_WEAPONTYPE", WEAPONTYPE_SHIELD), GetString(BMR_TRADESKILL_WOODWORKING), GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_INTRICATE)),
		tooltip = zo_strformat("<<1>> & <<2>> : <<3>> (<<4>>)", GetString("SI_ITEMTYPE", ITEMTYPE_WEAPON), GetString("SI_WEAPONTYPE", WEAPONTYPE_SHIELD), GetString(BMR_TRADESKILL_WOODWORKING), GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_INTRICATE)),
	}
	
	-- Researchable Armor (heavy)
	ruleName = "armorTypeResearchableWeight" .. ARMORTYPE_HEAVY
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_ARMOR}},
			{func = GetItemLinkArmorType, funcArgs = BMR_ITEMLINK, values = {ARMORTYPE_HEAVY}},
			{func = GetItemLinkSetInfo, funcArgs = BMR_ITEMLINK, values = {false}},
			{func = IsItemNeededForResearch, funcArgs = BMR_ITEMLINK, values = {true}},
			{func = IsItemJunk, funcArgs = BMR_BAG_AND_SLOT, values = {false}},
		},
		name = zo_strformat("<<1>> : <<2>> (<<3>>)", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetString("SI_ARMORTYPE", ARMORTYPE_HEAVY), GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)),
		tooltip = zo_strformat("<<1>> : <<2>> (<<3>>)", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetString("SI_ARMORTYPE", ARMORTYPE_HEAVY), GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)),
	}
	
	-- Researchable Armor (medium)
	ruleName = "armorTypeResearchableWeight" .. ARMORTYPE_MEDIUM
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_MEDIUM}},
			{func = GetItemLinkArmorType, funcArgs = BMR_ITEMLINK, values = {ARMORTYPE_MEDIUM}},
			{func = GetItemLinkSetInfo, funcArgs = BMR_ITEMLINK, values = {false}},
			{func = IsItemNeededForResearch, funcArgs = BMR_ITEMLINK, values = {true}},
			{func = IsItemJunk, funcArgs = BMR_BAG_AND_SLOT, values = {false}},
		},
		name = zo_strformat("<<1>> : <<2>> (<<3>>)", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetString("SI_ARMORTYPE", ARMORTYPE_MEDIUM), GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)),
		tooltip = zo_strformat("<<1>> : <<2>> (<<3>>)", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetString("SI_ARMORTYPE", ARMORTYPE_MEDIUM), GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)),
	}

	-- Researchable Armor (light)
	ruleName = "armorTypeResearchableWeight" .. ARMORTYPE_LIGHT
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_ARMOR}},
			{func = GetItemLinkArmorType, funcArgs = BMR_ITEMLINK, values = {ARMORTYPE_LIGHT}},
			{func = GetItemLinkSetInfo, funcArgs = BMR_ITEMLINK, values = {false}},
			{func = IsItemNeededForResearch, funcArgs = BMR_ITEMLINK, values = {true}},
			{func = IsItemJunk, funcArgs = BMR_BAG_AND_SLOT, values = {false}},
		},
		name = zo_strformat("<<1>> : <<2>> (<<3>>)", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetString("SI_ARMORTYPE", ARMORTYPE_LIGHT), GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)),
		tooltip = zo_strformat("<<1>> : <<2>> (<<3>>)", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetString("SI_ARMORTYPE", ARMORTYPE_LIGHT), GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)),
	}

	--[[ ClothierAll										-- not working so far
	ruleName = "clothierAll" .. CRAFTING_TYPE_CLOTHIER
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_MEDIUM}},
			{func = GetItemLinkArmorType, funcArgs = BMR_ITEMLINK, values = {ARMORTYPE_MEDIUM}},
			{func = GetItemLinkSetInfo, funcArgs = BMR_ITEMLINK, values = {false}},
			{func = IsItemNeededForResearch, funcArgs = BMR_ITEMLINK, values = {true}},
			{func = IsItemJunk, funcArgs = BMR_BAG_AND_SLOT, values = {false}},
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_ARMOR}},
			{func = GetItemLinkArmorType, funcArgs = BMR_ITEMLINK, values = {ARMORTYPE_LIGHT}},
			{func = GetItemLinkSetInfo, funcArgs = BMR_ITEMLINK, values = {false}},
			{func = IsItemNeededForResearch, funcArgs = BMR_ITEMLINK, values = {true}},
			{func = IsItemJunk, funcArgs = BMR_BAG_AND_SLOT, values = {false}},
		},
		name = zo_strformat("<<1>> : <<2>> (<<3>>)", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetString("SI_ARMORTYPE", ARMORTYPE_LIGHT), GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)),
		tooltip = zo_strformat("<<1>> : <<2>> (<<3>>)", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetString("SI_ARMORTYPE", ARMORTYPE_LIGHT), GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)),
		name = zo_strformat("<<1>> : <<2>> (<<3>>)", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetString("SI_ARMORTYPE", ARMORTYPE_MEDIUM), GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)),
		tooltip = zo_strformat("<<1>> : <<2>> (<<3>>)", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetString("SI_ARMORTYPE", ARMORTYPE_MEDIUM), GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)),
	}
	
	-- ClothierGBank
	ruleName = "clothierGBank" .. CRAFTING_TYPE_CLOTHIER
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_MEDIUM}},
			{func = GetItemLinkArmorType, funcArgs = BMR_ITEMLINK, values = {ARMORTYPE_MEDIUM}},
			{func = GetItemLinkSetInfo, funcArgs = BMR_ITEMLINK, values = {false}},
			{func = IsItemNeededForResearch, funcArgs = BMR_ITEMLINK, values = {true}},
			{func = IsItemJunk, funcArgs = BMR_BAG_AND_SLOT, values = {false}},
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_ARMOR}},
			{func = GetItemLinkArmorType, funcArgs = BMR_ITEMLINK, values = {ARMORTYPE_LIGHT}},
			{func = GetItemLinkSetInfo, funcArgs = BMR_ITEMLINK, values = {false}},
			{func = IsItemNeededForResearch, funcArgs = BMR_ITEMLINK, values = {true}},
			{func = IsItemJunk, funcArgs = BMR_BAG_AND_SLOT, values = {false}},
		},
		name = zo_strformat("<<1>> : <<2>> (<<3>>)", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetString("SI_ARMORTYPE", ARMORTYPE_LIGHT), GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)),
		tooltip = zo_strformat("<<1>> : <<2>> (<<3>>)", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetString("SI_ARMORTYPE", ARMORTYPE_LIGHT), GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)),
		name = zo_strformat("<<1>> : <<2>> (<<3>>)", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetString("SI_ARMORTYPE", ARMORTYPE_MEDIUM), GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)),
		tooltip = zo_strformat("<<1>> : <<2>> (<<3>>)", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetString("SI_ARMORTYPE", ARMORTYPE_MEDIUM), GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)),
	}
	
		-- ClothierStacks
	ruleName = "clothierStacks" .. CRAFTING_TYPE_CLOTHIER
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_MEDIUM}},
			{func = GetItemLinkArmorType, funcArgs = BMR_ITEMLINK, values = {ARMORTYPE_MEDIUM}},
			{func = GetItemLinkSetInfo, funcArgs = BMR_ITEMLINK, values = {false}},
			{func = IsItemNeededForResearch, funcArgs = BMR_ITEMLINK, values = {true}},
			{func = IsItemJunk, funcArgs = BMR_BAG_AND_SLOT, values = {false}},
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_ARMOR}},
			{func = GetItemLinkArmorType, funcArgs = BMR_ITEMLINK, values = {ARMORTYPE_LIGHT}},
			{func = GetItemLinkSetInfo, funcArgs = BMR_ITEMLINK, values = {false}},
			{func = IsItemNeededForResearch, funcArgs = BMR_ITEMLINK, values = {true}},
			{func = IsItemJunk, funcArgs = BMR_BAG_AND_SLOT, values = {false}},
		},
		name = zo_strformat("<<1>> : <<2>> (<<3>>)", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetString("SI_ARMORTYPE", ARMORTYPE_LIGHT), GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)),
		tooltip = zo_strformat("<<1>> : <<2>> (<<3>>)", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetString("SI_ARMORTYPE", ARMORTYPE_LIGHT), GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)),
		name = zo_strformat("<<1>> : <<2>> (<<3>>)", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetString("SI_ARMORTYPE", ARMORTYPE_MEDIUM), GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)),
		tooltip = zo_strformat("<<1>> : <<2>> (<<3>>)", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetString("SI_ARMORTYPE", ARMORTYPE_MEDIUM), GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)),
	}]]   -- not working so far

	-- Researchable Weapons (smithing)
	ruleName = "weaponTypeResearchable" .. CRAFTING_TYPE_BLACKSMITHING
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_WEAPON}},
			{func = GetItemLinkWeaponType, funcArgs = BMR_ITEMLINK, values = {WEAPONTYPE_AXE, WEAPONTYPE_DAGGER, WEAPONTYPE_HAMMER, WEAPONTYPE_SWORD, WEAPONTYPE_TWO_HANDED_AXE, WEAPONTYPE_TWO_HANDED_HAMMER, WEAPONTYPE_TWO_HANDED_SWORD}},
			{func = GetItemLinkSetInfo, funcArgs = BMR_ITEMLINK, values = {false}},
			{func = IsItemNeededForResearch, funcArgs = BMR_ITEMLINK, values = {true}},
			{func = IsItemJunk, funcArgs = BMR_BAG_AND_SLOT, values = {false}},
		},
		name = zo_strformat("<<1>> : <<2>> (<<3>>)", GetString("SI_ITEMTYPE", ITEMTYPE_WEAPON), GetString(BMR_TRADESKILL_BLACKSMITHING), GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)),
		tooltip = zo_strformat("<<1>> : <<2>> (<<3>>)", GetString("SI_ITEMTYPE", ITEMTYPE_WEAPON), GetString(BMR_TRADESKILL_BLACKSMITHING), GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)),
	}
	
	-- Researchable Weapons (Woodworking)
	ruleName = "weaponTypeResearchable" .. CRAFTING_TYPE_WOODWORKING
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_WEAPON}},
			{func = GetItemLinkWeaponType, funcArgs = BMR_ITEMLINK, values = {WEAPONTYPE_BOW, WEAPONTYPE_FIRE_STAFF, WEAPONTYPE_FROST_STAFF, WEAPONTYPE_LIGHTNING_STAFF, WEAPONTYPE_HEALING_STAFF, WEAPONTYPE_SHIELD}},
			{func = GetItemLinkSetInfo, funcArgs = BMR_ITEMLINK, values = {false}},
			{func = IsItemNeededForResearch, funcArgs = BMR_ITEMLINK, values = {true}},
			{func = IsItemJunk, funcArgs = BMR_BAG_AND_SLOT, values = {false}},
		},
		name = zo_strformat("<<1>> & <<2>> : <<3>> (<<4>>)", GetString("SI_ITEMTYPE", ITEMTYPE_WEAPON), GetString("SI_WEAPONTYPE", WEAPONTYPE_SHIELD), GetString(BMR_TRADESKILL_WOODWORKING), GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)),
		tooltip = zo_strformat("<<1>> & <<2>> : <<3>> (<<4>>)", GetString("SI_ITEMTYPE", ITEMTYPE_WEAPON), GetString("SI_WEAPONTYPE", WEAPONTYPE_SHIELD), GetString(BMR_TRADESKILL_WOODWORKING), GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)),
	}
	
	-- WoodworkingAll
	ruleName = "woodworkingAll" .. CRAFTING_TYPE_WOODWORKING
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_WEAPON}},
			{func = GetItemLinkWeaponType, funcArgs = BMR_ITEMLINK, values = {WEAPONTYPE_BOW, WEAPONTYPE_FIRE_STAFF, WEAPONTYPE_FROST_STAFF, WEAPONTYPE_LIGHTNING_STAFF, WEAPONTYPE_HEALING_STAFF, WEAPONTYPE_SHIELD}},
			{func = GetItemLinkSetInfo, funcArgs = BMR_ITEMLINK, values = {true}},
			{func = IsItemNeededForResearch, funcArgs = BMR_ITEMLINK, values = {true}},
			{func = IsItemJunk, funcArgs = BMR_BAG_AND_SLOT, values = {true}},
		},
		name = zo_strformat("<<1>> & <<2>> : <<3>> (<<4>>)", GetString("SI_ITEMTYPE", ITEMTYPE_WEAPON), GetString("SI_WEAPONTYPE", WEAPONTYPE_SHIELD), GetString(BMR_TRADESKILL_WOODWORKING), GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)),
		tooltip = zo_strformat("<<1>> & <<2>> : <<3>> (<<4>>)", GetString("SI_ITEMTYPE", ITEMTYPE_WEAPON), GetString("SI_WEAPONTYPE", WEAPONTYPE_SHIELD), GetString(BMR_TRADESKILL_WOODWORKING), GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)),
	}
	
	-- WoodworkingGBank
	ruleName = "woodworkingGBank" .. CRAFTING_TYPE_WOODWORKING
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_WEAPON}},
			{func = GetItemLinkWeaponType, funcArgs = BMR_ITEMLINK, values = {WEAPONTYPE_BOW, WEAPONTYPE_FIRE_STAFF, WEAPONTYPE_FROST_STAFF, WEAPONTYPE_LIGHTNING_STAFF, WEAPONTYPE_HEALING_STAFF, WEAPONTYPE_SHIELD}},
			{func = GetItemLinkSetInfo, funcArgs = BMR_ITEMLINK, values = {true}},
			{func = IsItemNeededForResearch, funcArgs = BMR_ITEMLINK, values = {true}},
			{func = IsItemJunk, funcArgs = BMR_BAG_AND_SLOT, values = {true}},
		},
		name = zo_strformat("<<1>> & <<2>> : <<3>> (<<4>>)", GetString("SI_ITEMTYPE", ITEMTYPE_WEAPON), GetString("SI_WEAPONTYPE", WEAPONTYPE_SHIELD), GetString(BMR_TRADESKILL_WOODWORKING), GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)),
		tooltip = zo_strformat("<<1>> & <<2>> : <<3>> (<<4>>)", GetString("SI_ITEMTYPE", ITEMTYPE_WEAPON), GetString("SI_WEAPONTYPE", WEAPONTYPE_SHIELD), GetString(BMR_TRADESKILL_WOODWORKING), GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)),
	}
	
		-- WoodworkingStacks
	ruleName = "woodworkingStacks" .. CRAFTING_TYPE_WOODWORKING
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_WEAPON}},
			{func = GetItemLinkWeaponType, funcArgs = BMR_ITEMLINK, values = {WEAPONTYPE_BOW, WEAPONTYPE_FIRE_STAFF, WEAPONTYPE_FROST_STAFF, WEAPONTYPE_LIGHTNING_STAFF, WEAPONTYPE_HEALING_STAFF, WEAPONTYPE_SHIELD}},
			{func = GetItemLinkSetInfo, funcArgs = BMR_ITEMLINK, values = {true}},
			{func = IsItemNeededForResearch, funcArgs = BMR_ITEMLINK, values = {true}},
			{func = IsItemJunk, funcArgs = BMR_BAG_AND_SLOT, values = {true}},
		},
		name = zo_strformat("<<1>> & <<2>> : <<3>> (<<4>>)", GetString("SI_ITEMTYPE", ITEMTYPE_WEAPON), GetString("SI_WEAPONTYPE", WEAPONTYPE_SHIELD), GetString(BMR_TRADESKILL_WOODWORKING), GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)),
		tooltip = zo_strformat("<<1>> & <<2>> : <<3>> (<<4>>)", GetString("SI_ITEMTYPE", ITEMTYPE_WEAPON), GetString("SI_WEAPONTYPE", WEAPONTYPE_SHIELD), GetString(BMR_TRADESKILL_WOODWORKING), GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)),
	}
	
	-- Cooking
	
	-- Ingredients for food
	ruleName = "cookingIngredientsFood"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_INGREDIENT}},
			{func = GetItemLinkIngredientType, funcArgs = BMR_ITEMLINK, values = {1}},
		},
		name = zo_strformat("<<1>> - <<2>>", GetString("SI_ITEMTYPE", ITEMTYPE_INGREDIENT), GetString("SI_ITEMTYPE", ITEMTYPE_FOOD)),
		tooltip = zo_strformat("<<1>> - <<2>>", GetString("SI_ITEMTYPE", ITEMTYPE_INGREDIENT), GetString("SI_ITEMTYPE", ITEMTYPE_FOOD)),
	}
	
	-- Ingredients for drink
	ruleName = "cookingIngredientsDrink"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_INGREDIENT}},
			{func = GetItemLinkIngredientType, funcArgs = BMR_ITEMLINK, values = {2}},
		},
		name = zo_strformat("<<1>> - <<2>>", GetString("SI_ITEMTYPE", ITEMTYPE_INGREDIENT), GetString("SI_ITEMTYPE", ITEMTYPE_DRINK)),
		tooltip = zo_strformat("<<1>> - <<2>>", GetString("SI_ITEMTYPE", ITEMTYPE_INGREDIENT), GetString("SI_ITEMTYPE", ITEMTYPE_DRINK)),
	}
	
	-- Ingredients rare
	ruleName = "cookingIngredientsRare"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_INGREDIENT}},
			{func = GetItemLinkQuality, funcArgs = BMR_ITEMLINK, values = {ITEM_QUALITY_ARTIFACT, ITEM_QUALITY_LEGENDARY}},
		},
		name = zo_strformat(GetString(BMR_RARE_INGREDIENTS), "|H0:item:26802:28:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H0:item:27059:28:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H0:item:64222:29:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
		tooltip = zo_strformat(GetString(BMR_RARE_INGREDIENTS), "|H0:item:26802:28:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H0:item:27059:28:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", "|H0:item:64222:29:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
	}
	
	-- Ingredients rare
	ruleName = "cookingAmbrosia"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_DRINK}},
			{func = GetItemLinkQuality, funcArgs = BMR_ITEMLINK, values = {ITEM_QUALITY_LEGENDARY}},
		},
		name = "|H0:item:64221:124:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h & |H0:item:115027:124:1:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h",
		tooltip = "|H0:item:64221:124:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h & |H0:item:115027:124:1:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h",
	}
	
	-- Recipes known
	ruleName = "cookingRecipeKnown"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_RECIPE}},
			{func = GetItemLinkSpecializedItemType, funcArgs = BMR_ITEMLINK, values = {SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD, SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK}},
			{func = IsItemLinkRecipeKnown, funcArgs = BMR_ITEMLINK, values = {true}},
		},
		name = GetString(SI_RECIPE_ALREADY_KNOWN),
		tooltip = GetString(SI_RECIPE_ALREADY_KNOWN),
	}
	
	-- Recipes Unknown
	ruleName = "cookingRecipeUnknown"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_RECIPE}},
			{func = GetItemLinkSpecializedItemType, funcArgs = BMR_ITEMLINK, values = {SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD, SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK}},
			{func = IsItemLinkRecipeKnown, funcArgs = BMR_ITEMLINK, values = {false}},
		},
		name = GetString(SI_ITEM_FORMAT_STR_UNKNOWN_RECIPE),
		tooltip = GetString(SI_ITEM_FORMAT_STR_UNKNOWN_RECIPE),
	}
	
	-- Enchanting 
	ruleName = "enchantingEssence"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_ENCHANTING_RUNE_ESSENCE}},
		},
		name = GetString("SI_ITEMTYPE", ITEMTYPE_ENCHANTING_RUNE_ESSENCE),
		tooltip = GetString("SI_ITEMTYPE", ITEMTYPE_ENCHANTING_RUNE_ESSENCE),
	}
	
--	local MAX_ENCHANTING_SKILL = 10 -- No UI function for that
--	for enchantingSkill=1, MAX_ENCHANTING_SKILL do
		ruleName = "enchantingPotency" --.. enchantingSkill
		BankManagerRules.data[ruleName] = {
			params = {
				{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_ENCHANTING_RUNE_POTENCY}},
			--	{func = GetItemLinkRequiredCraftingSkillRank, funcArgs = BMR_ITEMLINK, values = {enchantingSkill}},
			},
			name = GetString("SI_ITEMTYPE", ITEMTYPE_ENCHANTING_RUNE_POTENCY), -- .. " " .. zo_strformat(SI_QUEST_JOURNAL_QUEST_LEVEL, enchantingSkill),
			tooltip = GetString("SI_ITEMTYPE", ITEMTYPE_ENCHANTING_RUNE_POTENCY), -- .. " " .. zo_strformat(SI_QUEST_JOURNAL_QUEST_LEVEL, enchantingSkill),
		}
		
--	end
	
	ruleName = "enchantingTa"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_ENCHANTING_RUNE_ASPECT}},
			{func = GetItemLinkQuality, funcArgs = BMR_ITEMLINK, values = {ITEM_QUALITY_NORMAL}},
		},
		name = "|H0:item:45850:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", -- "Ta" item
		tooltip = "|H0:item:45850:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	}
	
	ruleName = "enchantingAspect"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_ENCHANTING_RUNE_ASPECT}},
			{func = GetItemLinkQuality, funcArgs = BMR_ITEMLINK, values = {ITEM_QUALITY_MAGIC, ITEM_QUALITY_ARCANE, ITEM_QUALITY_ARTIFACT, ITEM_QUALITY_LEGENDARY}},
		},
		name = GetString("SI_ITEMTYPE", ITEMTYPE_ENCHANTING_RUNE_ASPECT),
		tooltip = GetString("SI_ITEMTYPE", ITEMTYPE_ENCHANTING_RUNE_ASPECT),
	}
	
	ruleName = "enchantingGlyphs"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_GLYPH_ARMOR, ITEMTYPE_GLYPH_JEWELRY, ITEMTYPE_GLYPH_WEAPON}},
		},
		name = GetString(SI_GAMEPADITEMCATEGORY13),
		tooltip = GetString(SI_GAMEPADITEMCATEGORY13),
	}
	
	ruleName = "alchemyReagent"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_REAGENT}},
		},
		name = GetString("SI_ITEMTYPE", ITEMTYPE_REAGENT),
		tooltip = GetString("SI_ITEMTYPE", ITEMTYPE_REAGENT),
	}
	
	local MAX_ALCHEMY_SKILL = 8 -- No UI function for that
	for alchemySkill=1, MAX_ALCHEMY_SKILL do
		ruleName = "alchemySolvent" .. alchemySkill
		BankManagerRules.data[ruleName] = {
			params = {
				{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_POTION_BASE}},
				{func = GetItemLinkRequiredCraftingSkillRank, funcArgs = BMR_ITEMLINK, values = {alchemySkill}},
			},
			name = GetString(SI_GROUP_LIST_PANEL_LEVEL_HEADER) .. alchemySkill .. " - " .. zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(BankManagerRules.static.alchemySolventArray[alchemySkill])),
			tooltip = GetString(SI_GROUP_LIST_PANEL_LEVEL_HEADER) .. alchemySkill .. " - " .. zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(BankManagerRules.static.alchemySolventArray[alchemySkill])),
		}
		
			ruleName = "alchemyPoisonSolvent"
		BankManagerRules.data[ruleName] = {
			params = {
				{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_POISON_BASE}},
			},
			name = GetString("SI_ITEMTYPE", ITEMTYPE_POISON_BASE),
			tooltip = GetString("SI_ITEMTYPE", ITEMTYPE_POISON_BASE),
		}
	
	end
	
	-- Misc
	
	--AvA Repair (Stone/Wood)
	ruleName = "MiscAvaRepair"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_AVA_REPAIR}},
		},
		name = GetString("SI_ITEMTYPE", ITEMTYPE_AVA_REPAIR),
		tooltip = GetString("SI_ITEMTYPE", ITEMTYPE_AVA_REPAIR),
	}
	
	-- Disguises
	ruleName = "MiscDisguises"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_DISGUISE}},
		},
		name = zo_strformat("<<1>>", GetString("SI_ITEMTYPE", ITEMTYPE_DISGUISE)),
		tooltip = zo_strformat("<<1>>", GetString("SI_ITEMTYPE", ITEMTYPE_DISGUISE)),
	}
	
	-- Lockpics
	ruleName = "MiscLockpick"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_TOOL}},
			{func = GetItemLinkQuality, funcArgs = BMR_ITEMLINK, values = {ITEM_QUALITY_NORMAL}},
		},
		name = GetString("SI_ITEMTYPE", ITEMTYPE_LOCKPICK),
		tooltip = GetString("SI_ITEMTYPE", ITEMTYPE_LOCKPICK),
	}
	
	-- Lures
	ruleName = "MiscLure"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_LURE}},
		},
		name = GetString("SI_ITEMTYPE", ITEMTYPE_LURE),
		tooltip = GetString("SI_ITEMTYPE", ITEMTYPE_LURE),
	}
	
	-- Potions
	ruleName = "MiscPotion"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_POTION}},
		},
		name = zo_strformat("<<1>>", GetString("SI_ITEMTYPE", ITEMTYPE_POTION)),
		tooltip = zo_strformat("<<1>>", GetString("SI_ITEMTYPE", ITEMTYPE_POTION)),
	}
	
	-- Poisons
	ruleName = "MiscPoison"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_POISON}},
		},
		name = zo_strformat("<<1>>", GetString("SI_ITEMTYPE", ITEMTYPE_POISON)),
		tooltip = zo_strformat("<<1>>", GetString("SI_ITEMTYPE", ITEMTYPE_POISON)),
	}
	
	-- Racial books
	ruleName = "MiscRacial"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_RACIAL_STYLE_MOTIF}},
		},
		name = GetString("SI_ITEMTYPE", ITEMTYPE_RACIAL_STYLE_MOTIF),
		tooltip = GetString("SI_ITEMTYPE", ITEMTYPE_RACIAL_STYLE_MOTIF),
	}
	
	-- Containers
	ruleName = "MiscContainer"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_CONTAINER}},
		},
		name = GetString("SI_ITEMTYPE", ITEMTYPE_CONTAINER),
		tooltip = GetString("SI_ITEMTYPE", ITEMTYPE_CONTAINER),
	}
	
	-- Repair kits & Crown Repair kits
	ruleName = "MiscRepair"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_TOOL, ITEMTYPE_CROWN_REPAIR}},
			{func = GetItemLinkQuality, funcArgs = BMR_ITEMLINK, values = {ITEM_QUALITY_ARCANE, ITEM_QUALITY_MAGIC}},
		},
		name = zo_strformat("<<1>> & <<2>>", GetString(SI_REPAIR_KIT_CONFIRM), GetString("SI_ITEMTYPE", ITEMTYPE_CROWN_REPAIR)),
		tooltip = zo_strformat("<<1>> & <<2>>", GetString(SI_REPAIR_KIT_CONFIRM), GetString("SI_ITEMTYPE", ITEMTYPE_CROWN_REPAIR)),
	}
	
	-- Soul Gems Little restriction here GetSoulGemItemInfo returns tier as first result instead of soulGemType, so use quality instead
	ruleName = "MiscSoulGemsEmpty"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_SOUL_GEM}},
			{func = GetItemLinkQuality, funcArgs = BMR_ITEMLINK, values = {ITEM_QUALITY_NORMAL}},
		},
		name = zo_strformat("<<1>> - <<2>>", GetString("SI_ITEMTYPE", ITEMTYPE_SOUL_GEM), GetString(SI_GAME_CAMERA_ACTION_EMPTY)),
		tooltip = zo_strformat("<<1>> - <<2>>", GetString("SI_ITEMTYPE", ITEMTYPE_SOUL_GEM), GetString(SI_GAME_CAMERA_ACTION_EMPTY)),
	}
	
	-- Soul Gems Fulfilled
	ruleName = "MiscSoulGemsFulfilled"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_SOUL_GEM}},
			{func = GetItemLinkQuality, funcArgs = BMR_ITEMLINK, values = {ITEM_QUALITY_MAGIC, ITEM_QUALITY_ARCANE}},
		},
		name = zo_strformat("<<1>>", GetItemQualityColor(ITEM_QUALITY_MAGIC):Colorize(GetString("SI_ITEMTYPE", ITEMTYPE_SOUL_GEM))),
		tooltip = zo_strformat("<<1>>", GetItemQualityColor(ITEM_QUALITY_MAGIC):Colorize(GetString("SI_ITEMTYPE", ITEMTYPE_SOUL_GEM))),
	}
	
	--[[ Master Writs
	ruleName = "MiscMasterWrit"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_MASTER_WRIT}},
		},
		name = GetString("SI_ITEMTYPE", ITEMTYPE_MASTER_WRIT),
		tooltip = GetString("SI_ITEMTYPE", ITEMTYPE_MASTER_WRIT),
	}]]
	
	-- Master Writs
	ruleName = "questMasterWrit"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_MASTER_WRIT}},
		},
		name = GetString("SI_ITEMTYPE", ITEMTYPE_MASTER_WRIT),
		tooltip = GetString("SI_ITEMTYPE", ITEMTYPE_MASTER_WRIT),
	}
	
	-- Treasure Maps
	ruleName = "trophyTreasureMaps"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_TROPHY}},
			{func = GetItemLinkQuality, funcArgs = BMR_ITEMLINK, values = {ITEM_QUALITY_ARCANE}},
			{func = GetItemLinkBindType, funcArgs = BMR_ITEMLINK, values = {BIND_TYPE_NONE}},
			{func = IsItemLinkConsumable, funcArgs = BMR_ITEMLINK, values = {false}},
		},
		name = GetString(BMR_TROPHY_TREASURE_MAP),
		tooltip = GetString(BMR_TROPHY_TREASURE_MAP),
	}
	
	-- Craft Surveys
	ruleName = "trophySurveys"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_TROPHY}},
			{func = GetItemLinkSpecializedItemType, funcArgs = BMR_ITEMLINK, values = {SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT}},
		},
		name = GetString(BMR_TROPHY_SURVEY_MAP),
		tooltip = GetString(BMR_TROPHY_SURVEY_MAP),
	}
	
	-- Frag motifs
	ruleName = "trophyFragMotifs"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_RACIAL_STYLE_MOTIF}},
			{func = GetItemLinkSpecializedItemType, funcArgs = BMR_ITEMLINK, values = {SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_CHAPTER }},
		},
		name = GetString(BMR_TROPHY_MOTIF_FRAGMENT),
		tooltip = GetString(BMR_TROPHY_MOTIF_FRAGMENT),
	}
	
	-- Recipe Fragments -- share same rules as IC trophies (sewers & exterior)
	ruleName = "trophyFragRecipe"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_TROPHY}},
			{func = GetItemLinkSpecializedItemType, funcArgs = BMR_ITEMLINK, values = {SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT}},
		},
		name = GetString(BMR_TROPHY_RECIPE_FRAGMENT),
		tooltip = GetString(BMR_TROPHY_RECIPE_FRAGMENT),
	}
	
	-- IC Trophies (dungeons)
	ruleName = "trophyICPVE"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_TROPHY}},
			{func = GetItemLinkSpecializedItemType, funcArgs = BMR_ITEMLINK, values = {SPECIALIZED_ITEMTYPE_TROPHY_KEY_FRAGMENT}},
		},
		name = GetString(BMR_TROPHY_IMPERIALCITY_PVE),
		tooltip = GetString(BMR_TROPHY_IMPERIALCITY_PVE),
	}
	
	-- Recipes known
	ruleName = "HousingRecipeKnown"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_RECIPE}},
			{func = GetItemLinkSpecializedItemType, funcArgs = BMR_ITEMLINK, values = {SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING, SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING, SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING, SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING, SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING, SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING}},
			{func = IsItemLinkRecipeKnown, funcArgs = BMR_ITEMLINK, values = {true}},
		},
		name = GetString(SI_RECIPE_ALREADY_KNOWN),
		tooltip = GetString(SI_RECIPE_ALREADY_KNOWN),
	}
	
	-- Recipes Unknown
	ruleName = "HousingRecipeUnknown"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_RECIPE}},
			{func = GetItemLinkSpecializedItemType, funcArgs = BMR_ITEMLINK, values = {SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING, SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING, SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING, SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING, SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING, SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING}},
			{func = IsItemLinkRecipeKnown, funcArgs = BMR_ITEMLINK, values = {false}},
		},
		name = GetString(SI_ITEM_FORMAT_STR_UNKNOWN_RECIPE),
		tooltip = GetString(SI_ITEM_FORMAT_STR_UNKNOWN_RECIPE),
	}
	
	-- Furnitures
	ruleName = "HousingFurnitures"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_FURNISHING}},
		},
		name = GetString("SI_ITEMTYPE", ITEMTYPE_FURNISHING),
		tooltip = GetString("SI_ITEMTYPE", ITEMTYPE_FURNISHING),
	}
	
	-- Housing Ingredients
	ruleName = "HousingIngredients"
	BankManagerRules.data[ruleName] = {
		params = {
			{func = GetItemLinkItemType, funcArgs = BMR_ITEMLINK, values = {ITEMTYPE_FURNISHING_MATERIAL}},
		},
		name = GetString("SI_ITEMTYPE", ITEMTYPE_FURNISHING_MATERIAL),
		tooltip = GetString("SI_ITEMTYPE", ITEMTYPE_FURNISHING_MATERIAL),
	}
	
end


function BankManagerRules.addDefaultFilters(rulesArray, defaultsArray)

	for ruleName, data in pairs(rulesArray) do
		if data.params then
			defaultsArray[ruleName] = {} -- To dynamically build the defaults array for the SV.
			defaultsArray[ruleName].action = ACTION_NOTSET -- Action per default
			defaultsArray[ruleName].onlyIfNotFullStack = true -- Value per default, even if the value is not configurable, it is present and checked
			defaultsArray[ruleName].onlyStacks = 1 -- Same as onlyIfNotFullStack, but checked only if onlyIfNotFullStack = false
			defaultsArray[ruleName].associatedGuild = GetString(BMR_ACTION_NOTSET) -- Default value
		end
	end
	
	return defaultsArray
	
end