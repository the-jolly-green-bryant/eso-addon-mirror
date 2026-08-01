local ESOMRL = _G['ESOMRL']
ESOMRL.DB.Strings = ESOMRL:GetLanguage()
--[[
Saved variable values:
0 = unknown untracked
1 = unknown tracked
2 = known tracked
3 = known untracked

/script SetCVar("Language.2", "en")
/script SetCVar("Language.2", "fr")
/script SetCVar("Language.2", "de")
/script d(GetAPIVersion())

Zgoo.CommandHandler(control:GetName())
--]]


-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Character-specific addon settings.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local CharacterDefaults = {
	pRecipeTrack = {},					-- database of food recipe tracking status for this character
	fRecipeTrack = {},					-- database of furniture recipe tracking status for this character
	cOpts = {
	-- Character Status
		trackChar=true,					-- enable tracking this character's recipe data

	--	FCO ItemSaver Support
		fcoitemsaverCO=false,			-- lock current character unknown recipes

	-- Track Character's Writs
		cWrit1=0,
		cWrit2=0,
		cW1Crafted=0,
		cW2Crafted=0,
	},
}

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Account-wide addon settings.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local AccountDefaults = {
	pRecipeKnown = {},					-- database of food recipes and known status of all tracking characters
	fRecipeKnown = {},					-- database of furniture recipes and known status of all tracking characters
	aIngTrack = {},						-- database of ingredient tracking status

	aOpts = {

	-- Database version tracking
		version=1.5675,						-- current running version
		APIversion=0,						-- tracks current running API version to only update database when client changes

	-- Inventory Icon Options
		inventoryicons=true,				-- enable inventory icons
		inventoryIT=true,					-- enable inventory icon tooltips
		inventoryTI=false,					-- enable icon text overlay
		inventoryT=true,					-- show recipe tracking icons
		inventoryW=true,					-- show writ status icons
		inventoryCK=true,					-- show current character's known recipes
		inventoryCU=false,					-- show current character's unknown recipes
		tchartK=false,                  	-- show tracking character's known recipes
		tchart=false,                   	-- enable tracking character
		foodtrackingchar="",            	-- food tracking character
		furntrackingchar="",            	-- furniture tracking character
		bagiconoffset=74,					-- inventory icon position
		storeiconoffset=24,					-- NPC vendor icon position
		gstoreiconoffset=125,           	-- guild store search result icon position
		glistingiconoffset=110,         	-- guild store listing icon position

	-- Item Tooltip Options
		known=true,							-- show 'known by' in tooltips
		sortAlpha=true,						-- alphabetize 'known by' list
		kSformat=4,							-- format for 'known by' text
		ttcolorkT={0.4,0.8,1,1},        	-- known recipe color
		ttcolork="66ccff",              	-- known recipe color (text hex)
		ttcoloruT={0.5,0.5,0.5,1},      	-- unknown recipe color
		ttcoloru="808080",              	-- unknown recipe color (text hex)
		ingrecs=true,						-- show detailed ingredients info on recipe items
		ingrecsgs=false,					-- no detailed ingredients on recipe items at guild store
		ingfood=false,						-- show detailed ingredients info on result items
		ingfoodgs=false,					-- no detailed ingredients on result items at guild store
		ingcolors=true,						-- color the ingredient list by quality
		furnCats=true,						-- show housing editor furniture category on furniture recipes and result items

	-- Auto Destroy Options
		destroyjunkrecipes=false,       	-- destroy junk recipes
		destroyjunkingredients=false,   	-- destroy junk ingredients
		ignorestolen=true,              	-- ignore Stolen Items
		debugmode=true,                 	-- enable debug mode
		maxjunkquality=2,               	-- color quality protection
		maxjunkstack=10,                	-- max amount to destroy

	-- Cooking Station Options
		opControls=true,					-- option to only show MRL controls at provisioning station
		noFilters=false,					-- clear filters on startup
		ingFilter=3,						-- override crafting station filter checkbox for "Have Ingredients"
		tabSelect=2,						-- override default cooking station tab
		skillFilter=3,						-- override crafting station filter checkbox for "Have Skill"
		questFilter=3,						-- override crafting station filter checkbox for "Quest Only"
		stationstats=true,					-- cooking station stat icons
		stationicons=1,						-- stat icon style
		autoWrits=false,					-- automatically craft provisioning writs without needing to click categories
		sortByLevel=true,					-- option to sort individual cooking recipes by level or alphabetically
		sortAscending=true,					-- allows toggle for sorting ascending or descending at the cooking station

	--	FCO ItemSaver Support
		fcoitemsaverU=false,            	-- lock tracking character unknown recipes
		fcoitemsaverT=false,            	-- lock tracked items

	-- GUI state variables
		xpos=0,                         	-- GUI horizontal offset (for remembering last position)
		ypos=0,                         	-- GUI vertical offset (for remembering last position)
		export_xpos=0,						-- Export window X position
		export_ypos=0,						-- Export window Y position
		sttx={},                         	-- Crafting station tooltip horizontal offset (for remembering last position)
		stty={},                         	-- Crafting station tooltip vertical offset (for remembering last position)
		kOnly=false,						-- Toggle only showing known recipes in the app recipe list display
		uOnly=false,						-- Toggle only showing unknown recipes in the app recipe list display
		lttshow=1,                      	-- enable/disable GUI popup tooltips
		sttshow=1,                      	-- enable/disable cooking station popup tooltips
		stmarked=1,                     	-- enable/disable highlighting tracked recipes at cooking station
		tooltipstyle=0,                 	-- switch between showing recipe or result item in GUI tooltips 
		recipeconfigpanel=0,            	-- show the GUI recipe tracking config panel
		previewicon=true,					-- show icon next to furniture recipes that can be right-click 3d-previewed
		junkunmarkedrecipes=0,          	-- pin toggle required to confirm junking unmarked recipes when enabled
		junkunmarkedingredients=0,      	-- pin toggle required to confirm junking unmarked ingredients when enabled
		destroyunmarkedrecipes=0,       	-- pin toggle required to confirm destroying unmarked recipes when enabled
		destroyunmarkedingredients=0,   	-- pin toggle required to confirm destroying unmarked ingredients when enabled
		stationCustomX=0,					-- variables for remembering custom station control x position
		stationCustomY=0,					-- variables for remembering custom station control y position
	},

	mRecipeList = {							-- all current recipes & ingredients for speed and auto-update
		Provisioning = {},
		Furniture = {},
		Ingredients = { -- starter table of base game ingredients for normal type food and drinks (all the old original ingredients from before furniture was added)
			[34349] =	"/esoui/art/icons/crafting_acai_berry.dds",					-- Acai Berry
			[34311] =	"/esoui/art/icons/provisioner_apple.dds",					-- Apples
			[33755] =	"/esoui/art/icons/crafting_bananas.dds",					-- Bananas
			[34329] =	"/esoui/art/icons/crafting_components_bread_006.dds",		-- Barley
			[34309] =	"/esoui/art/icons/crafting_beets.dds",						-- Beets
			[27059] =	"/esoui/art/icons/crafting_components_malt_003.dds",		-- Bervez Juice
			[34334] =	"/esoui/art/icons/crafting_components_veg_003.dds",			-- Bittergreen
			[34324] =	"/esoui/art/icons/crafting_carrots.dds",					-- Carrots
			[27057] =	"/esoui/art/icons/quest_trollfat_001.dds",					-- Cheese
			[33772] =	"/esoui/art/icons/crafting_coffee_beans.dds",				-- Coffee
			[33768] =	"/esoui/art/icons/crafting_comberries.dds",					-- Comberry
			[34323] =	"/esoui/art/icons/crafting_corn.dds",						-- Corn
			[33753] =	"/esoui/art/icons/crafting_cooking_fish_fillet.dds",		-- Fish
			[27100] =	"/esoui/art/icons/quest_dust_001.dds",						-- Flour
			[26802] =	"/esoui/art/icons/crafting_plant_creature_vines.dds",		-- Frost Mirriam
			[28609] =	"/esoui/art/icons/crafting_vendor_fuel_meat_001.dds",		-- Game
			[26954] =	"/esoui/art/icons/crafting_components_spice_003.dds",		-- Garlic
			[27052] =	"/esoui/art/icons/crafting_components_gin_002.dds",			-- Ginger
			[34346] =	"/esoui/art/icons/crafting_components_gin_005.dds",			-- Ginkgo
			[34347] =	"/esoui/art/icons/crafting_ginseng.dds",					-- Ginseng
			[28604] =	"/esoui/art/icons/crafting_cabbage.dds",					-- Greens
			[34333] =	"/esoui/art/icons/crafting_components_berry_002.dds",		-- Guarana
			[27043] =	"/esoui/art/icons/quest_honeycomb_001.dds",					-- Honey
			[27035] =	"/esoui/art/icons/crafting_wood_gum.dds",					-- Isinglass
			[33771] =	"/esoui/art/icons/crafting_smith_potion_vendor_003.dds",	-- Jasmine
			[28610] =	"/esoui/art/icons/crafting_grapes.dds",						-- Jazbay Grapes
			[27049] =	"/esoui/art/icons/crafting_lemons.dds",						-- Lemon
			[34330] =	"/esoui/art/icons/quest_flower_001.dds",					-- Lotus
			[34308] =	"/esoui/art/icons/crafting_melo.dds",						-- Melon
			[27048] =	"/esoui/art/icons/crafting_components_malt_004.dds",		-- Metheglin
			[27064] =	"/esoui/art/icons/crafting_components_bread_004.dds",		-- Millet
			[33773] =	"/esoui/art/icons/crafting_components_spice_004.dds",		-- Mint
			[33758] =	"/esoui/art/icons/crafting_components_veg_001.dds",			-- Potato
			[34321] =	"/esoui/art/icons/crafting_cooking_grilled_chicken.dds",	-- Poultry
			[34305] =	"/esoui/art/icons/crafting_pumpkin.dds",					-- Pumpkin
			[34307] =	"/esoui/art/icons/crafting_radish.dds",						-- Radish
			[33752] =	"/esoui/art/icons/quest_food_003.dds",						-- Red Meat
			[29030] =	"/esoui/art/icons/crafting_components_bread_001.dds",		-- Rice
			[28636] =	"/esoui/art/icons/crafting_flower_mountain_flower_r2.dds",	-- Rose
			[28639] =	"/esoui/art/icons/crafting_components_bread_005.dds",		-- Rye
			[27063] =	"/esoui/art/icons/monster_plant_creature_seeds_001.dds",	-- Saltrice
			[27058] =	"/esoui/art/icons/quest_dust_004.dds",						-- Seasoning
			[28666] =	"/esoui/art/icons/crafting_cloth_stems.dds",				-- Seaweed
			[33756] =	"/esoui/art/icons/crafting_critter_rodent_toes.dds",		-- Small Game
			[34345] =	"/esoui/art/icons/crafting_components_berry_004.dds",		-- Surilie Grapes
			[28603] =	"/esoui/art/icons/crafting_components_veg_005.dds",			-- Tomato
			[34348] =	"/esoui/art/icons/crafting_components_bread_002.dds",		-- Wheat
			[33754] =	"/esoui/art/icons/crafting_critter_dom_animal_fat.dds",		-- White Meat
			[33774] =	"/esoui/art/icons/crafting_components_bread_003.dds",		-- Yeast
			[34335] =	"/esoui/art/icons/quest_bandage_001.dds",					-- Yerba Mate
		},
	}
}

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Global Utility Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local extASCII = { -- Table of extended ASCII codes for conversion to standard ASCII equivalent where applicable
--	[194161] = nil,		-- ¡	INVERTED EXCLAMATION MARK
--	[194162] = nil,		-- ¢	CENT SIGN
--	[194163] = nil,		-- £	POUND SIGN
--	[194164] = nil,		-- ¤	CURRENCY SIGN
--	[194165] = nil,		-- ¥	YEN SIGN
--	[194166] = nil,		-- ¦	BROKEN BAR
--	[194167] = nil,		-- §	SECTION SIGN
--	[194168] = nil,		-- ¨	DIAERESIS
--	[194169] = nil,		-- ©	COPYRIGHT SIGN
--	[194170] = nil,		-- ª	FEMININE ORDINAL INDICATOR
--	[194171] = nil,		-- «	LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
--	[194172] = nil,		-- ¬	NOT SIGN
--	[194173] = nil,		-- ­	SOFT HYPHEN
--	[194174] = nil,		-- ®	REGISTERED SIGN
--	[194175] = nil,		-- ¯	MACRON
--	[194176] = nil,		-- °	DEGREE SIGN
--	[194177] = nil,		-- ±	PLUS-MINUS SIGN
--	[194178] = nil,		-- ²	SUPERSCRIPT TWO
--	[194179] = nil,		-- ³	SUPERSCRIPT THREE
--	[194180] = nil,		-- ´	ACUTE ACCENT
--	[194181] = nil,		-- µ	MICRO SIGN
--	[194182] = nil,		-- ¶	PILCROW SIGN
--	[194183] = nil,		-- ·	MIDDLE DOT
--	[194184] = nil,		-- ¸	CEDILLA
--	[194185] = nil,		-- ¹	SUPERSCRIPT ONE
--	[194186] = nil,		-- º	MASCULINE ORDINAL INDICATOR
--	[194187] = nil,		-- »	RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
--	[194188] = nil,		-- ¼	VULGAR FRACTION ONE QUARTER
--	[194189] = nil,		-- ½	VULGAR FRACTION ONE HALF
--	[194190] = nil,		-- ¾	VULGAR FRACTION THREE QUARTERS
--	[194191] = nil,		-- ¿	INVERTED QUESTION MARK
	[195128] = "A",		-- À	LATIN CAPITAL LETTER A WITH GRAVE
	[195129] = "A",		-- Á	LATIN CAPITAL LETTER A WITH ACUTE
	[195130] = "A",		-- Â	LATIN CAPITAL LETTER A WITH CIRCUMFLEX
	[195131] = "A",		-- Ã	LATIN CAPITAL LETTER A WITH TILDE
	[195132] = "A",		-- Ä	LATIN CAPITAL LETTER A WITH DIAERESIS
	[195133] = "A",		-- Å	LATIN CAPITAL LETTER A WITH RING ABOVE
	[195134] = "AE",	-- Æ	LATIN CAPITAL LETTER AE
	[195135] = "C",		-- Ç	LATIN CAPITAL LETTER C WITH CEDILLA
	[195136] = "E",		-- È	LATIN CAPITAL LETTER E WITH GRAVE
	[195137] = "E",		-- É	LATIN CAPITAL LETTER E WITH ACUTE
	[195138] = "E",		-- Ê	LATIN CAPITAL LETTER E WITH CIRCUMFLEX
	[195139] = "E",		-- Ë	LATIN CAPITAL LETTER E WITH DIAERESIS
	[195140] = "I",		-- Ì	LATIN CAPITAL LETTER I WITH GRAVE
	[195141] = "I",		-- Í	LATIN CAPITAL LETTER I WITH ACUTE
	[195142] = "I",		-- Î	LATIN CAPITAL LETTER I WITH CIRCUMFLEX
	[195143] = "I",		-- Ï	LATIN CAPITAL LETTER I WITH DIAERESIS
	[195144] = "ETH",	-- Ð	LATIN CAPITAL LETTER ETH
	[195145] = "N",		-- Ñ	LATIN CAPITAL LETTER N WITH TILDE
	[195146] = "O",		-- Ò	LATIN CAPITAL LETTER O WITH GRAVE
	[195147] = "O",		-- Ó	LATIN CAPITAL LETTER O WITH ACUTE
	[195148] = "O",		-- Ô	LATIN CAPITAL LETTER O WITH CIRCUMFLEX
	[195149] = "O",		-- Õ	LATIN CAPITAL LETTER O WITH TILDE
	[195150] = "O",		-- Ö	LATIN CAPITAL LETTER O WITH DIAERESIS
--	[195151] = nil,		-- ×	MULTIPLICATION SIGN
--	[195152] = nil,		-- Ø	LATIN CAPITAL LETTER O WITH STROKE
	[195153] = "U",		-- Ù	LATIN CAPITAL LETTER U WITH GRAVE
	[195154] = "U",		-- Ú	LATIN CAPITAL LETTER U WITH ACUTE
	[195155] = "U",		-- Û	LATIN CAPITAL LETTER U WITH CIRCUMFLEX
	[195156] = "U",		-- Ü	LATIN CAPITAL LETTER U WITH DIAERESIS
	[195157] = "Y",		-- Ý	LATIN CAPITAL LETTER Y WITH ACUTE
--	[195158] = nil,		-- Þ	LATIN CAPITAL LETTER THORN
--	[195159] = nil,		-- ß	LATIN SMALL LETTER SHARP S
	[195160] = "a",		-- à	LATIN SMALL LETTER A WITH GRAVE
	[195161] = "a",		-- á	LATIN SMALL LETTER A WITH ACUTE
	[195162] = "a",		-- â	LATIN SMALL LETTER A WITH CIRCUMFLEX
	[195163] = "a",		-- ã	LATIN SMALL LETTER A WITH TILDE
	[195164] = "a",		-- ä	LATIN SMALL LETTER A WITH DIAERESIS
	[195165] = "a",		-- å	LATIN SMALL LETTER A WITH RING ABOVE
	[195166] = "ae",	-- æ	LATIN SMALL LETTER AE
	[195167] = "c",		-- ç	LATIN SMALL LETTER C WITH CEDILLA
	[195168] = "e",		-- è	LATIN SMALL LETTER E WITH GRAVE
	[195169] = "e",		-- é	LATIN SMALL LETTER E WITH ACUTE
	[195170] = "e",		-- ê	LATIN SMALL LETTER E WITH CIRCUMFLEX
	[195171] = "e",		-- ë	LATIN SMALL LETTER E WITH DIAERESIS
	[195172] = "i",		-- ì	LATIN SMALL LETTER I WITH GRAVE
	[195173] = "i",		-- í	LATIN SMALL LETTER I WITH ACUTE
	[195174] = "i",		-- î	LATIN SMALL LETTER I WITH CIRCUMFLEX
	[195175] = "i",		-- ï	LATIN SMALL LETTER I WITH DIAERESIS
	[195176] = "eth",	-- ð	LATIN SMALL LETTER ETH
	[195177] = "n",		-- ñ	LATIN SMALL LETTER N WITH TILDE
	[195178] = "o",		-- ò	LATIN SMALL LETTER O WITH GRAVE
	[195179] = "o",		-- ó	LATIN SMALL LETTER O WITH ACUTE
	[195180] = "o",		-- ô	LATIN SMALL LETTER O WITH CIRCUMFLEX
	[195181] = "o",		-- õ	LATIN SMALL LETTER O WITH TILDE
	[195182] = "o",		-- ö	LATIN SMALL LETTER O WITH DIAERESIS
--	[195183] = nil,		-- ÷	DIVISION SIGN
	[195184] = "o",		-- ø	LATIN SMALL LETTER O WITH STROKE
	[195185] = "u",		-- ù	LATIN SMALL LETTER U WITH GRAVE
	[195186] = "u",		-- ú	LATIN SMALL LETTER U WITH ACUTE
	[195187] = "u",		-- û	LATIN SMALL LETTER U WITH CIRCUMFLEX
	[195188] = "u",		-- ü	LATIN SMALL LETTER U WITH DIAERESIS
	[195189] = "y",		-- ý	LATIN SMALL LETTER Y WITH ACUTE
--	[195190] = nil,		-- þ	LATIN SMALL LETTER THORN
	[195191] = "y",		-- ÿ	LATIN SMALL LETTER Y WITH DIAERESIS
}

function ESOMRL.SubExtendedASCII(aString) -- Convert accented letters to standard ASCII equivalent using extended ASCII lookup table.
	local cLang = GetCVar('Language.2')
	if cLang ~= 'ru' and cLang ~= 'ja' and cLang ~= 'jp' then -- not currently supported
		local s = ""
		for i = 1, zo_strlen(aString) do -- for each 'letter' in the input string replace accented (extended ASCII) letters with standard ASCII
			local extIndex = aString:byte(i) -- get the ASCII decimal value for the character (may have multiple bytes)
			if extIndex >= 32 and extIndex <= 126 then -- standard ASCII character so add to rebuild string
				s = s .. aString:sub(i,i)
			elseif extIndex == 194 or extIndex == 195 then -- extended ASCII is coded in 2 bytes but the 1st is always 194 or 195
				local sIndex = aString:byte(i+1) -- so get 2nd if one of these and use to look up replacement
				local tstring = tostring(extIndex)..tostring(sIndex)
				local subVal = ""
	
				if extASCII[tonumber(tstring)] ~= nil then
					subVal = extASCII[tonumber(tstring)]
				end
				if subVal ~= "" then
					s = s .. subVal -- if an accented character is found add its standard ASCII equivalent to the rebuild string
				end
			end
		end
		return s -- return the completed rebuild string
	else
		return aString
	end
end

function ESOMRL.Round(number, decimals) -- Round number to decimals number of places.
	-- number:		The number to round.
	-- decimals:	The number of decimals to round to. 0 = Nearest integer.
	--
	-- Example: PF.Round(42.185, 2) = 42.19
	-- NOTE: Value of decimals must be a whole number >= 0.

	local tDec = math.floor(decimals)
	return tonumber(string.format("%." .. (tDec or 0) .. "f", number))
end

function ESOMRL.GetKey(nTable, element, all) -- Returns the table key(s) that contains a given element value.
	-- nTable:		Table, source to search for element.
	-- element:		String or number to find in the table.
	-- all:			Int, 1 to return first match or 2 for table.

	-- Example 1: Return the key that contains the string (only returns first match of multiple if all = 1 or nil.
	-- local SourceTable = {[1]="alpha", [2]="beta", [3]="gamma"}
	-- PF.GetKey(nTable, "alpha")
	-- returns: 1

	-- Example 2: Return table of keys that contain the value.
	-- local SourceTable = {[1]=3, [2]=2, [3]=1, [4]=3}
	-- PF.GetKey(nTable, 3, 2)
	-- returns: {[1]=true, [4]=true}

	-- Possible use:
	--	local SourceTable = {[1]=3, [2]=2, [3]=1, [4]=3}
	--	local checkKeys = PF.GetKey(SourceTable, 3, 2)
	--		for k, v in pairs(SourceTable) do
	--		if checkKeys[k] then
	--			d("Key "..k.." contains value 3")
	--		end
	--	end
	--
	--	Prints:
	--		Key 4 contains value 3
	--		Key 1 contains value 3

-- Default values:
	all = (all == nil or all ~= 1) and 2 or 1

	local matches = {}
	for k,v in pairs(nTable) do
		if v == element then
			if all ~= 1 then
				return k
			else
				matches[k] = true
			end
		end
	end
	if all ~= 1 then
		return 0
	else
		if #matches > 0 then
			return matches
		end
	end

	return
end

function ESOMRL.TColor(color, text) -- Wraps the color tags with the passed color around the given text.
	-- color:		String, hex format color string, for example "ffffff".
	-- text:		The text to format with the given color.

	-- Example: PF.TColor("ff0000", "This is red.")
	-- Returns: "|cff0000This is red.|r"

	local cText = "|c"..tostring(color)..tostring(text).."|r"
	return cText
end

function ESOMRL.Contains(nTable, element) -- Determined if a given element exists in a given table.
	-- nTable:		Table, source to search for element.
	-- element:		String or number to find in the table.

	-- Example: Does the given table contain a key with the given value?
	-- local SourceTable = {[1]="alpha", [2]="beta", [3]="gamma"}
	-- PF.GetKey(nTable, "alpha")
	-- returns: true

	for k,v in pairs(nTable) do
		if v == element then
			return true
		end
	end
	return false
end

function ESOMRL.RGB2Hex(rgb) -- Gets hex color format string from LibAddonMenu { r=r, g=g, b=b, a=a } colopicker or { [1]=r, [2]=g, [3]=b, [4]=a } saved variable table.
	-- Works opposite to the above, used for the SetFunc in LibAddonMenu color picker to save the chosen color to a hex variable for use in addons.
	--	setFunc = function(r, g, b, a)
	--		local color = { r=r, g=g, b=b, a=a }
	--		Addon.ASV.textColor = PF.RGB2Hex(color)
	--	end,

	-- account for different format input
	local r = (rgb['r']) and rgb['r'] or rgb[1]
	local g = (rgb['g']) and rgb['g'] or rgb[2]
	local b = (rgb['b']) and rgb['b'] or rgb[3]

	local cstring = ""
	local function cProc(val)
		local colornum = val * 255
		local hexstr = "0123456789abcdef"
		local s = ""
		while colornum > 0 do
			local mod = math.fmod(colornum, 16)
			s = string.sub(hexstr, mod+1, mod+1) .. s
			colornum = math.floor(colornum / 16)
		end
		if #s == 1 then s = "0" .. s end
		if s == "" then s = "00" end
		return s
	end
	cstring = cProc(r)..cProc(g)..cProc(b)
	return cstring
end

function ESOMRL.CountKeys(nTable) -- Count the key/value pairs in a hashed table (when #table returns 0).
	-- nTable:		Table, source to search for element.

	-- Example: Count the key/value pairs in a hashed table.
	-- local SourceTable = {["name1"]="alpha", ["name2"]="beta", ["name3"]="gamma"}
	-- PF.CountKeys(nTable)
	-- returns: 3

	local tKeys = 0
	for k, v in pairs(nTable) do
		tKeys = tKeys + 1
	end
	return tKeys
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Saved Variable Initialization
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ESOMRL.DB.SetupVars()
	local worldName = GetWorldName()
	local displayName = GetDisplayName()

	if MasterRecipeList then
		if MasterRecipeList.Default ~= nil then -- remove the old non-Megaserver specific variables table
			MasterRecipeList.Default = nil
		end
		if MasterRecipeList[worldName] and MasterRecipeList[worldName][displayName] then -- clear out old obsolete saved variables for new ID-based
			local version = MasterRecipeList[worldName][displayName]["$AccountWide"]["AccountSettings"].aOpts.version
			if version and version < 1.5635 then
				MasterRecipeList = {}
			end
		end	
	end

	ESOMRL.CSV = ZO_SavedVars:NewCharacterIdSettings('MasterRecipeList', 1.5635, 'CharacterSettings', CharacterDefaults, worldName)
	ESOMRL.ASV = ZO_SavedVars:NewAccountWide('MasterRecipeList', 1.5635, 'AccountSettings', AccountDefaults, worldName)

end

function ESOMRL.DB.DefaultVars(opt)
	if opt == 1 then
		return AccountDefaults.mRecipeList.Ingredients
	else
		return CharacterDefaults.cOpts, AccountDefaults.aOpts
	end
end
