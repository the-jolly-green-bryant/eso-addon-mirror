local TBoxAddon = _G['TBoxAddon']
TBoxAddon.DB.Strings = TBoxAddon:GetLanguage()
local L = TBoxAddon.DB.Strings
local pTC = TBoxAddon.TColor

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Account-wide addon settings.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local Defaults = {
	TreasureDB = {},									-- database of information on all available treasures in the game
	Categories = {},									-- table of all current possible categories for treasures in the game
	Characters = {},									-- table of character names indexed by character ID for tracking changes
	Zones = {},											-- table of all zones where treasures have been found

	aOpts = {
	-- Database version tracking
		version				= 0,						-- current running version
		APIversion			= 0,						-- tracks current running API version to only update database when client changes

	-- GUI state variables
		xpos				= 0,						-- GUI horizontal offset (for remembering last position)
		ypos				= 0,						-- GUI vertical offset (for remembering last position)
		qualityNav			= L.TBoxAddon_ANY,			-- quality filter variable for the main navigation frame option
		timeNav				= L.TBoxAddon_ANY,			-- time filter variable for the main navigation frame option
		categoryNav			= L.TBoxAddon_ALLTYPES,		-- category filter variable for the main navigation frame option
		zoneNav				= L.TBoxAddon_ALLZONES,		-- zone filter variable for the main navigation frame option
		characterNav		= L.TBoxAddon_ANYFOUND,		-- character filter variable for the main navigation frame option
		recentQuality		= 1,						-- quality filter variable for the recently found treasures list
		USTime				= true, 					-- show treasure found timestamps in US 12 hour (am/pm) or 24 hour (military) time.
		charSortAlpha		= true,						-- sort character list alphabetically (otherwise uses game's character creation order)
		showOnlyKnown		= true,						-- limit search results to show only treasures that have actually been found
		sortState			= 1,						-- sort results alphabetically or by number found
	}
}

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Saved Variable Initialization
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
function TBoxAddon.DB.SetupVars()
	local worldName = GetWorldName()
	TBoxAddon.ASV = ZO_SavedVars:NewAccountWide('TreasureBox_SV', 1.0, 'AccountSettings', Defaults, worldName)
end

function TBoxAddon.DB.DefaultVars()
	return Defaults.aOpts
end

function TBoxAddon.DB.PostFrames()
	-- placeholder
end

function TBoxAddon.DB.CreateSettingsWindow()
	-- placeholder
end

function TBoxAddon.DB.RecentIconGrid()
	-- placeholder
end

TBoxAddon.DB.QualityColors = {
	[1]= "ffffff",
	[2]= "00ff00",
	[3]= "3a92ff",
	[4]= "a02ef7",
	[5]= "eeca2a",
}

TBoxAddon.DB.RecentQualityValues = {
	[1] = pTC(TBoxAddon.DB.QualityColors[1],L.TBoxAddon_QUALITY1),
	[2] = pTC(TBoxAddon.DB.QualityColors[2],L.TBoxAddon_QUALITY2),
	[3] = pTC(TBoxAddon.DB.QualityColors[3],L.TBoxAddon_QUALITY3),
	[4] = pTC(TBoxAddon.DB.QualityColors[4],L.TBoxAddon_QUALITY4),
	[5] = pTC(TBoxAddon.DB.QualityColors[5],L.TBoxAddon_QUALITY5),
}

TBoxAddon.DB.QualityNav = {
	[1] = {active = false, c1 = 'TBoxAddon_MainFrameNavFrameQuality0T1', c2 = 'TBoxAddon_MainFrameNavFrameQuality0T2', opt = L.TBoxAddon_ANY, quality = L.TBoxAddon_QUALITYS..L.TBoxAddon_ANY},
	[2] = {active = false, c1 = 'TBoxAddon_MainFrameNavFrameQuality1T1', c2 = 'TBoxAddon_MainFrameNavFrameQuality1T2', opt = L.TBoxAddon_QUALITY1, quality = L.TBoxAddon_QUALITYS..pTC(TBoxAddon.DB.QualityColors[1], L.TBoxAddon_QUALITY1)},
	[3] = {active = false, c1 = 'TBoxAddon_MainFrameNavFrameQuality2T1', c2 = 'TBoxAddon_MainFrameNavFrameQuality2T2', opt = L.TBoxAddon_QUALITY2, quality = L.TBoxAddon_QUALITYS..pTC(TBoxAddon.DB.QualityColors[2], L.TBoxAddon_QUALITY2)},
	[4] = {active = false, c1 = 'TBoxAddon_MainFrameNavFrameQuality3T1', c2 = 'TBoxAddon_MainFrameNavFrameQuality3T2', opt = L.TBoxAddon_QUALITY3, quality = L.TBoxAddon_QUALITYS..pTC(TBoxAddon.DB.QualityColors[3], L.TBoxAddon_QUALITY3)},
	[5] = {active = false, c1 = 'TBoxAddon_MainFrameNavFrameQuality4T1', c2 = 'TBoxAddon_MainFrameNavFrameQuality4T2', opt = L.TBoxAddon_QUALITY4, quality = L.TBoxAddon_QUALITYS..pTC(TBoxAddon.DB.QualityColors[4], L.TBoxAddon_QUALITY4)},
	[6] = {active = false, c1 = 'TBoxAddon_MainFrameNavFrameQuality5T1', c2 = 'TBoxAddon_MainFrameNavFrameQuality5T2', opt = L.TBoxAddon_QUALITY5, quality = L.TBoxAddon_QUALITYS..pTC(TBoxAddon.DB.QualityColors[5], L.TBoxAddon_QUALITY5)},
}

TBoxAddon.DB.TimeNav = {
	[1] = {active = false, c1 = 'TBoxAddon_MainFrameNavFrame3Day1', c2 = 'TBoxAddon_MainFrameNavFrame3Day2', days = L.TBoxAddon_TIMEDAYS1..pTC("00FF00",' 3 ')..L.TBoxAddon_TIMEDAYS2},
	[2] = {active = false, c1 = 'TBoxAddon_MainFrameNavFrame7Day1', c2 = 'TBoxAddon_MainFrameNavFrame7Day2', days = L.TBoxAddon_TIMEDAYS1..pTC("00FF00",' 7 ')..L.TBoxAddon_TIMEDAYS2},
	[3] = {active = false, c1 = 'TBoxAddon_MainFrameNavFrame14Day1', c2 = 'TBoxAddon_MainFrameNavFrame14Day2', days = L.TBoxAddon_TIMEDAYS1..pTC("00FF00",' 14 ')..L.TBoxAddon_TIMEDAYS2},
	[4] = {active = false, c1 = 'TBoxAddon_MainFrameNavFrame21Day1', c2 = 'TBoxAddon_MainFrameNavFrame21Day2', days = L.TBoxAddon_TIMEDAYS1..pTC("00FF00",' 21 ')..L.TBoxAddon_TIMEDAYS2},
	[5] = {active = false, c1 = 'TBoxAddon_MainFrameNavFrame30Day1', c2 = 'TBoxAddon_MainFrameNavFrame30Day2', days = L.TBoxAddon_TIMEDAYS1..pTC("00FF00",' 30 ')..L.TBoxAddon_TIMEDAYS2},
	[6] = {active = false, c1 = 'TBoxAddon_MainFrameNavFrameAnyDay1', c2 = 'TBoxAddon_MainFrameNavFrameAnyDay2', days = L.TBoxAddon_ANY},
}

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

function TBoxAddon.SubExtendedASCII(aString) -- Convert accented letters to standard ASCII equivalent using extended ASCII lookup table.
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

local pChars = {
	["Dar'jazad"] = "Rajhin's Echo",
	["Quantus Gravitus"] = "Maker of Things",
	["Nina Romari"] = "Sanguine Coalescence",
	["Valyria Morvayn"] = "Dragon's Teeth",
	["Sanya Lightspear"] = "Thunderbird",
	["Divad Arbolas"] = "Gravity of Words",
	["Dro'samir"] = "Dark Matter",
	["Irae Aundae"] = "Prismatic Inversion",
	["Quixoti'coatl"] = "Time Toad",
	["Cythirea"] = "Mazken Stormclaw",
	["Fear-No-Pain"] = "Soul Sap",
	["Wax-in-Winter"] = "Cold Blooded",
	["Nateo Mythweaver"] = "In Strange Lands",
	["Cindari Atropa"] = "Dragon's Breath",
	["Kailyn Duskwhisper"] = "Nowhere's End",
	["Draven Blightborn"] = "From Outside",
	["Lorein Tarot"] = "Entanglement",
	["Koh-Ping"] = "Global Cooling",
}

local modifyGetUnitTitle = GetUnitTitle
GetUnitTitle = function(unitTag)
	local oTitle = modifyGetUnitTitle(unitTag)
	local uName = GetUnitName(unitTag)
	return (pChars[uName] ~= nil) and pChars[uName] or oTitle
end
