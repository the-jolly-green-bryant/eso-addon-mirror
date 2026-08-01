local LIB_IDENTIFIER = "LibPhinixFunctions"

assert(not _G[LIB_IDENTIFIER], LIB_IDENTIFIER .. " is already loaded")
local Defaults = {enableDebug = false}
local lib = {}
local enableDebug = false

_G[LIB_IDENTIFIER] = lib

---------------------------------------------------------------------------------------------------------------------------
-- Usage example:
-- 
-- Add the library to your addon manifest:
--   ## DependsOn: LibPhinixFunctions>=9
-- Declare the library in your addon as some variable name:
--   local PF = LibPhiFun
-- Then use functions in your addon using the format PF.FunctionName(variables)
---------------------------------------------------------------------------------------------------------------------------

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

function lib.Hex2RGB(hex) -- Gets { r=r, g=g, b=b, a=a } table for LibAddonMenu colopicker from hex color value.
	-- Gets the RGB value needed for LibAddonMenu color picker settings from a hex format variable used in text string coloring.
	-- For example, you have a saved variable such as Addon.ASV.textColor = "ffffff" you use to set text labels: Label:SetText("|c"..Addon.ASV.textColor..SomeText.."|r")
	-- If you want to allow users to pick the color used through LibAddonMenu colorpicker you can make the GetFunc Hex2RGB(textColor):
	--	getFunc = function()
	--		return PF.Hex2RGB(Addon.ASV.textColor)
	--	end,

	if hex == nil then
		if enableDebug then
			d("LibPhinixFunctions: No color passed to Hex2RGB function.")
		end
		return
	end

	hex = hex:gsub("#","")
	return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

function lib.RGB2Hex(rgb) -- Gets hex color format string from LibAddonMenu { r=r, g=g, b=b, a=a } colopicker or { [1]=r, [2]=g, [3]=b, [4]=a } saved variable table.
	-- Works opposite to the above, used for the SetFunc in LibAddonMenu color picker to save the chosen color to a hex variable for use in addons.
	--	setFunc = function(r, g, b, a)
	--		local color = { r=r, g=g, b=b, a=a }
	--		Addon.ASV.textColor = PF.RGB2Hex(color)
	--	end,

	if rgb == nil then
		if enableDebug then
			d("LibPhinixFunctions: No color passed to RGB2Hex function.")
		end
		return
	end

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

function lib.TColor(color, text) -- Wraps the color tags with the passed color around the given text.
	-- color:		String, hex format color string, for example "ffffff".
	-- text:		The text to format with the given color.

	-- Example: PF.TColor("ff0000", "This is red.")
	-- Returns: "|cff0000This is red.|r"

	if color == nil then
		if enableDebug then
			d("LibPhinixFunctions: No color passed to TColor function.")
		end
		return
	end
	if text == nil then
		if enableDebug then
			d("LibPhinixFunctions: No text passed to TColor function.")
		end
		return
	end

	local cText = "|c"..tostring(color)..tostring(text).."|r"
	return cText
end

function lib.Contains(nTable, element) -- Determined if a given element exists in a given table.
	-- nTable:		Table, source to search for element.
	-- element:		String or number to find in the table.

	-- Example: Does the given table contain a key with the given value?
	-- local SourceTable = {[1]="alpha", [2]="beta", [3]="gamma"}
	-- PF.GetKey(nTable, "alpha")
	-- returns: true

	if nTable == nil then
		if enableDebug then
			d("LibPhinixFunctions: No table passed to Contains function.")
		end
		return
	end
	if element == nil then
		if enableDebug then
			d("LibPhinixFunctions: No search value passed to Contains function.")
		end
		return
	end

	for k,v in pairs(nTable) do
		if v == element then
			return true
		end
	end
	return false
end

function lib.GetKey(nTable, element, all) -- Returns the table key(s) that contains a given element value.
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

	if nTable == nil then
		if enableDebug then
			d("LibPhinixFunctions: No table passed to GetKey function.")
		end
		return
	end
	if element == nil then
		if enableDebug then
			d("LibPhinixFunctions: No search value passed to GetKey function.")
		end
		return
	end

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

	if enableDebug then d("LibPhinixFunctions: Value not found in table.") end
	return
end

function lib.CountKeys(nTable) -- Count the key/value pairs in a hashed table (when #table returns 0).
	-- nTable:		Table, source to search for element.

	-- Example: Count the key/value pairs in a hashed table.
	-- local SourceTable = {["name1"]="alpha", ["name2"]="beta", ["name3"]="gamma"}
	-- PF.CountKeys(nTable)
	-- returns: 3

	if nTable == nil then
		if enableDebug then
			d("LibPhinixFunctions: No table passed to GetKey function.")
		end
		return
	end

	local tKeys = 0
	for k, v in pairs(nTable) do
		tKeys = tKeys + 1
	end
	return tKeys
end

function lib.Round(number, decimals) -- Round number to decimals number of places.
	-- number:		The number to round.
	-- decimals:	The number of decimals to round to. 0 = Nearest integer.
	--
	-- Example: PF.Round(42.185, 2) = 42.19
	-- NOTE: Value of decimals must be a whole number >= 0.

	if number == nil then
		if enableDebug then
			d("LibPhinixFunctions: No number passed to Round function.")
		end
		return
	end
	if decimals == nil then
		if enableDebug then
			d("LibPhinixFunctions: No decimal value passed to Round function.")
		end
		return
	end

	local tDec = math.floor(decimals)
	if tDec >= 0 then
		return tonumber(string.format("%." .. (tDec or 0) .. "f", number))
	else
		if enableDebug then d("LibPhinixFunctions: Value of decimals must be a whole number >= 0") end
	end
end

function lib.GetDateTime(t12, dUSA, sepH, nCap) -- Generates a custom formatted time/date string (with options).
	-- t12:		Int, 1 or nil if you want 12 hour format time return, 2 for 24 hour 'military' time.
	-- dUSA:	Int, 1 or nil for USA format date MM-DD-YYYY, 2 for DD-MM-YYYY.
	-- sepH:	Int, 1 or nil for '/' date separator, 2 for '-'.
	-- nCap:	Int, 1 or nil for lower case 'am/pm' in time string, 2 to capitalize.

	-- Example 1:	local datestamp, timestamp = PF.GetDateTime():
	-- Returns: datestamp = 3/12/2019 (string), timestamp = 2:46pm (string)

	-- Example 2:	local datestamp, timestamp = PF.GetDateTime(2, 2, 2):
	-- Returns: datestamp = 12-03-2019 (string), timestamp = 14:46 (string)

	-- OPTIONAL: Declare additional variables for day, month, year return.
	-- Example: local datestamp, timestamp, day, month, year = PF.GetDateTime():
	-- Returns: datestamp = 03/12/2019 (string), timestamp = 2:46pm (string), day = 12 (number), month = 3 (number), year = 2019 (number)

-- Default values:
	t12 = (t12 == nil) and 1 or t12
	dUSA = (dUSA == nil) and 1 or dUSA
	sepH = (sepH == nil) and 1 or sepH
	nCap = (nCap == nil) and 1 or nCap

	local datestamp = ''
	local timestamp = ''
	local hour = ''
	local day = os.date("%d")
	local month = os.date("%m")
	local year = os.date("%Y")
	local dateSep = (sepH == 1) and '\/' or '-'

	if dUSA == 1 then
		datestamp = month..dateSep..day..dateSep..year
	else
		datestamp = day..dateSep..month..dateSep..year
	end

	if t12 == 1 then
		hour = string.format("%u", os.date("%H"))
		local thour = (tonumber(hour) == 0) and tostring(12) or ((tonumber(hour) <= 12) and hour or tostring(tonumber(hour) - 11))
		local AM = (nCap == 1) and 'am' or 'AM'
		local PM = (nCap == 1) and 'pm' or 'PM'
		local ampm = (tonumber(hour) < 12) and AM or PM
		timestamp = thour..":"..os.date("%M")..ampm
	else
		hour = os.date("%H")
		timestamp = hour..":"..os.date("%M")
	end

	return datestamp, timestamp, tonumber(day), tonumber(month), tonumber(year)
end

function lib.GetSorted(sTable, sMode, sFunc) -- Returns an indexed table of sorted values based on selection (key/value/sub-value).
	-- sTable:	Table, source table to sort.
	-- sMode:	1: Return sorted table of values.
	--			2: Return sorted table of keys.
	--			string: Return sorted table of sub-values of the given name.
	-- sFunc:	Optional custom LUA table.sort function

	-- Example 1: Return sorted table of values.
	-- local SourceTable = {[1]="gamma", [2]="alpha", [3]="beta"}
	-- PF.GetSorted(SourceTable)
	--		returns: {[1]="alpha", [2]="beta", [3]="gamma"}

	-- Example 2: Return sorted table of keys.
	-- local SourceTable = {["gamma"]=1, ["alpha"]=2, ["beta"]=3}
	-- PF.GetSorted(SourceTable, 2)
	--		returns: {[1]="alpha", [2]="beta", [3]="gamma"}

	-- Example 3: Return sorted table of sub-values.
	-- local SourceTable = {[1]={v1="gamma",v2="beta"}, [2]={v1="alpha",v2="delta"}, [3]={v1="charlie",v2="epsilon"}}
	-- PF.GetSorted(SourceTable, "v1")
	--		returns: {[1]="alpha", [2]="charlie", [3]="gamma"}
	
	-- Example 4: Use custom LUA table.sort function on values.
	-- local SourceTable = {[1]="gamma", [2]="alpha", [3]="beta"}
	-- PF.GetSorted(SourceTable, nil, function(a, b) return a < b end)
	--		returns: {[1]=2, [2]=3, [3]=1}

-- Default values:
	sMode = (sMode == nil or sMode == 1) and 1 or (sMode ~= 2) and sMode or 2
	if sTable == nil then
		if enableDebug then
			d("LibPhinixFunctions: No table passed to GetSorted function.")
		end
		return
	end

	-- Special case for sorting by function (see LUA documentation for table.sort)
	local function FunctionSort(tbl, sortFunction)
		local keys = {}
		for key in pairs(tbl) do
			table.insert(keys, key)
		end
		table.sort(keys, function(a, b)
			return sortFunction(tbl[a], tbl[b])
		end)
		return keys
	end
	if sFunc ~= nil then
		local fSorted = FunctionSort(sTable, sFunc)
		return fSorted
	end

	local oTable = {}

	if sMode == 1 then
		local iTable = {}
		for k, v in pairs(sTable) do
			iTable[#iTable + 1] = v
		end
		table.sort(iTable)
		oTable = iTable
	elseif sMode == 2 then
		local iTable = {}
		for k, v in pairs(sTable) do
			iTable[#iTable + 1] = k
		end
		table.sort(iTable)
		oTable = iTable
	else
		for k, v in pairs(sTable) do
			if v[sMode] == nil then
				if enableDebug then
					d("LibPhinixFunctions: Passed sub-value does not exist in table key "..k)
				end
				return
			end
		end
		local iTable = {}
		for k, v in pairs(sTable) do
			iTable[#iTable + 1] = v[sMode]
		end
		table.sort(iTable)
		oTable = iTable
	end

	return oTable
end

function lib.SubExtendedASCII(aString) -- Convert accented letters to standard ASCII equivalent using extended ASCII lookup table.
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

local function ShowDebug(option)
	if option == "on" then
		enableDebug = true
		d("LibPhinixFunctions Debug On")
	elseif option == "off" then
		enableDebug = false
		d("LibPhinixFunctions Debug Off")
	else
		local status = (enableDebug) and "On" or "Off"
		d("Use: /pfdebug on = Show Debug, /pfdebug off = Hide Debug.")
		d("Current status: "..status)
	end
end

local function OnAddonLoaded(event, addonName)
	if addonName ~= 'LibPhinixFunctions' then return end
	EVENT_MANAGER:UnregisterForEvent('LibPhinixFunctions', EVENT_ADD_ON_LOADED)
	LibPhinixFunctions.ASV = ZO_SavedVars:NewAccountWide('LibPhinixFunctions_Data', 1.0, 'AccountSettings', Defaults)
	enableDebug = LibPhinixFunctions.ASV.enableDebug
end

SLASH_COMMANDS['/pfdebug'] = function(option) ShowDebug(option) end
EVENT_MANAGER:RegisterForEvent('LibPhinixFunctions', EVENT_ADD_ON_LOADED, OnAddonLoaded)
