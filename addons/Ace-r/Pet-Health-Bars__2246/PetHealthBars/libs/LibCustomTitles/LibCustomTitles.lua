--[[
Author: Ayantir
Filename: LibCustomTitles.lua
Version: 10
]]--

--[[

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

]]--


--[[

Author: Kyoma
Version 18
Changes: Rewrote how custom titles are added and stored to help reduce conflict between authors
	- Moved table with custom titles into seperate section with register function
	- Use achievementId instead of raw title name to make it work with all languages
	- Make it default to english custom title if nothing is specified for the user's language
	- Support for LibTitleLocale to fix issues with title differences for males and females

	(Added the option to make a title hidden from the user itself) *mhuahahahaha*
	
	(v18) 
	- Added support for colors and even a simple gradient
	- Moved language check to title registration
]]--


local a = {
	{"@Ace'r",            nil,       92,      {en = "1234567890" },                {color="E70C0C"}},
	{"@Ace'r",            nil,       113,     {en = "almost good at eso" },        {color={"5ED4E5", "c37dff"}}},
	{"@Ace'r",            nil,       114,     {en = "almost good at eso" },        {color={"5ED4E5", "c37dff"}}},
	{"@Ace'r",            nil,       705,     {en = "almost good at eso" },        {color={"5ED4E5", "c37dff"}}},
	{"@Ace'r",            nil,       false,   {en = "dick tock tormenter" },       {color={"5ED4E5", "c37dff"}}},
	{"@Ace'r",            nil,       1538,    {en = "almost good at eso" },        {color={"5ED4E5", "c37dff"}}},
	{"@Ace'r",            nil,       1330,    {en = "almost good at eso" },        {color={"5ED4E5", "c37dff"}}},
	{"@Ace'r",            nil,       1391,    {en = "almost good at eso" },        {color={"5ED4E5", "c37dff"}}},
	--{"@Cloakedd",        nil,       1330,    {en = "Cinnir\'s Prinzessin" },  {color={"FF00E7", "15FF00"}}},
	--{"@Cloakedd",        nil,       2079,    {en = "Cinnir\'s Prinzessin" },  {color={"FF00E7", "15FF00"}}},
	{"@floridori91",      nil,       false,   {en = "Big German Sausage" },        {color="FDBD70"}},
	{"@Cinnir",           nil,       false,   {en = "The Fly" },                   {color={"00F1EA", "FF88C5"}}},
	{"@Cinnir",           nil,       2079,    {en = "The Fly" },                   {color={"00F1EA", "FF88C5"}}},
	{"@Cinnir",           nil,       1391,    {en = "The Fly" },                   {color={"00F1EA", "FF88C5"}}},
	{"@Cinnir",           nil,       1330,    {en = "The Fly" },                   {color={"00F1EA", "FF88C5"}}},
	{"@Cinnir",           nil,       111,     {en = "The Fly" },                   {color={"00F1EA", "FF88C5"}}},
	{"@Cinnir",           nil,       112,     {en = "The Fly" },                   {color={"00F1EA", "FF88C5"}}},
	{"@Cinnir",           nil,       113,     {en = "The Fly" },                   {color={"00F1EA", "FF88C5"}}},
	{"@Cinnir",           nil,       114,     {en = "The Fly" },                   {color={"00F1EA", "FF88C5"}}},
	{"@Cinnir",           nil,       705,     {en = "The Fly" },                   {color={"00F1EA", "FF88C5"}}},
	{"@gifere",           nil,       705,     {en = "hiroyeeto" },                 {color="87CEFF"}},
	{"@gifere",           nil,       935,     {en = "hiroyeeto" },                 {color="87CEFF"}},
    {"@gifere",           nil,       1330,    {en = "hiroyeeto" },                 {color="87CEFF"}},
	{"@BLACKBlRDBlGBOSS", nil,       108,     {en = "cutie xx" },                  {color="FF00A7"}},
	{"@BLACKBlRDBlGBOSS", nil,       109,     {en = "cutie xx" },                  {color="FF00A7"}},
	{"@GC0",              nil,       1921,    {en = "DC Scum" },                 {color="CE0000"}},
	{"@Jack215",          nil,       false,   {en = "The 215" },                   {color="22CECE"}},
	{"@Nafirian",         nil,       false,   {en = "chonky boy" },                {color="0CE727"}},
	{"@WamasuTaxidermist",nil,       false,   {en = "SUH DUUUDE" },                {color="298EFF"}},
	{"@Heresyall",        nil,       false,   {en = "french magblade" },           {color="DCBB04"}},
	{"@Hexiss",           nil,       false,   {en = "Grand Overlord x3" },         {color="AB31FF"}},
	{"@Hexiss",           nil,       705,     {en = "Grand Overlord x3" },         {color="AB31FF"}},
	{"@fake_remedy",      nil,       false,   {en = "Carried by Earthgore" },      {color={"E50202", "999999"}}},
	{"@fake_remedy",      nil,       92,      {en = "Carried by Earthgore" },      {color={"E50202", "999999"}}},
	
	}
	

local libLoaded
local LIB_NAME, VERSION = "LibCustomTitlesAcer", 19
local LibCustomTitles, oldminor = LibStub:NewLibrary(LIB_NAME, VERSION)
if not LibCustomTitles then return end

local function RegisterTitle(module, ...)
	table.insert(module.titles, {...})
end

LibCustomTitlesModules = LibCustomTitlesModules or {}
function LibCustomTitles:RegisterModule(name, version)

	local module = LibCustomTitlesModules[name]
	if (module and module.version and module.version > version) then
		return nil
	end

	module = {}
	module.version = version
	module.titles = {}
	module.RegisterTitle = RegisterTitle

	--override any previous titles from an older version
	LibCustomTitlesModules[name] = module
	return module
end

function LibCustomTitles:InitTitles()
	for i=1,#a do
		self:RegisterTitle(unpack(a[i]))
	end
	LibCustomTitlesModules = nil --remove from global
end

local lang = GetCVar("Language.2")

local customTitles = {}
function LibCustomTitles:RegisterTitle(displayName, charName, override, title, extra)

	if type(title) == "table" then
		title = title[lang] or title["en"]
	end

	local hidden = (extra == true) --support old format
	if type(extra) == "table" then
		hidden = extra["hidden"]
		if extra["color"] then
			title = self:ApplyColor(title, extra["color"])
		end
	end

	if hidden and (displayName == GetUnitDisplayName("player") or charName == GetUnitName("player")) then
		return
	end

	local playerGender = GetUnitGender("player")
	local genderTitle

	if type(override) == "boolean" then --override all titles
		override = override and "-ALL-" or "-NONE-"
	elseif type(override) == "number" then --get override title from achievementId
		local hasRewardOfType, titleName = GetAchievementRewardTitle(override, playerGender) --gender is 1 or 2
		if hasRewardOfType and titleName then
			genderTitle = select(2, GetAchievementRewardTitle(override, 3 - playerGender))  -- cuz 3-2=1 and 3-1=2
			override = titleName
		end
	elseif type(override) == "table" then --use language table with strings
		override = override[lang] or override["en"]
	end

	if type(override) == "string" then 
		if not customTitles[displayName] then 
			customTitles[displayName] = {}
		end
		local charOrAccount = customTitles[displayName]
		if charName then
			if not customTitles[displayName][charName]  then 
				customTitles[displayName][charName] = {}
			end
			charOrAccount = customTitles[displayName][charName]
		end
		charOrAccount[override] = title
		if genderTitle and genderTitle ~= override then
			charOrAccount[genderTitle] = title
		end
	end
end

local MAX_GRADIENT_STEPS = 10 --after that text just starts to disappear

--[[   Sadly we cant make a nice rainbow with a max of only 10 steps
local function ApplyRainbow(text)

	d("Applying rainbow: " .. text)
	local len = string.len(text:gsub(" ", ""))
	local numSteps = zo_min(len, MAX_GRADIENT_STEPS)
	local stepSize = len / numSteps --we dont round this down directly

	local function FormatRainbow(step)
		local r, g, b
		local h, i, f, q
		h = step / numSteps
		i = zo_floor(h * 6)
		f = h * 6.0 - i
		q = 1 - f

		i = zo_mod(i, 6)
		if (i == 0) then
			r = 1
			g = f
			b = 0
		elseif (i == 1) then
			r = q
			g = 1
			b = 0
		elseif (i == 2) then
			r = 0
			g = 1
			b = f
		elseif (i == 3) then
			r = 0
			g = q
			b = 1
		elseif (i == 4) then
			r = f
			g = 0
			b = 1
		elseif (i == 5) then
			r = 1
			g = 0
			b = q
		else
			d("ERROR")
		end

		local str = ("%02X%02X%02X"):format(zo_floor(r*255), zo_floor(g*255), zo_floor(b*255))
		df("|c%s#%s|r", str, str)
		
		return "|c"..str
	end

	local step = 0
	local substep = 0
	local gradientText = FormatRainbow(step)
	for c in text:gmatch(".") do
		if c ~= " " then --ignore spaces
			substep = substep + 1
			if substep >= stepSize then
				substep = substep - stepSize
				step = step + 1
				gradientText = gradientText..FormatRainbow(step)
			end
		end
		gradientText = gradientText..c
	end
	gradientText = gradientText.."|r"
	
	d(gradientText)

	return gradientText
end
SLASH_COMMANDS["/testtitle"] = function(text)
	text = (text ~= "") and text or "Rainbow"
	ApplyRainbow(text)
end
--]]


function LibCustomTitles:ApplyColor(text, color)

	if type(color) == "string" then 	-- just a simple color
		--if zo_strlower(color) == "rainbow" then
		--	return ApplyRainbow(text)
		--else
			return "|c"..color:gsub("#","")..text.."|r"
		--end
	elseif type(color) ~= "table" then --wrong format??
		return text
	end
	
	local function hex2rgb(hex)
		hex = hex:gsub("#","")
		return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
	end
	
	local gStart = {hex2rgb(color[1])}
	local gEnd   = {hex2rgb(color[2])}

	local len = string.len(text:gsub(" ", ""))
	local numSteps = zo_min(len, MAX_GRADIENT_STEPS)
	local stepSize = len / numSteps --we dont round this down directly

	local gSteps = {
		(gEnd[1]-gStart[1])/numSteps, 
		(gEnd[2]-gStart[2])/numSteps, 
		(gEnd[3]-gStart[3])/numSteps
	}

	local function FormatGradient(step)
		return ("|c%02X%02X%02X"):format(zo_floor(gStart[1] + gSteps[1] * step), zo_floor(gStart[2] + gSteps[2] * step), zo_floor(gStart[3] + gSteps[3] * step))
	end

	local step = 0
	local substep = 0
	local gradientText = FormatGradient(step)
	for c in text:gmatch(".") do
		if c ~= " " then --ignore spaces
			substep = substep + 1
			if substep >= stepSize then
				substep = substep - stepSize
				step = step + 1
				gradientText = gradientText..FormatGradient(step)
			end
		end
		gradientText = gradientText..c
	end
	gradientText = gradientText.."|r"

	return gradientText
end

function LibCustomTitles:Init()

	self:InitTitles()

	local CT_NO_TITLE = 0
	local CT_TITLE_ACCOUNT = 1
	local CT_TITLE_CHARACTER = 2

	local function GetCustomTitleType(displayName, unitName)
		if customTitles[displayName] then
			if customTitles[displayName][unitName] then
				return CT_TITLE_CHARACTER
			end
			return CT_TITLE_ACCOUNT
		end
		return CT_NO_TITLE
	end

	local function GetCustomTitle(originalTitle, customTitle)
		if customTitle[originalTitle] then
			return customTitle[originalTitle]
		elseif originalTitle == "" and customTitle["-NONE-"] then
			return customTitle["-NONE-"]
		elseif customTitle["-ALL-"] then
			return customTitle["-ALL-"]
		end
	end

	local function GetModifiedTitle(originalTitle, displayName, unitName, registerType)
		if registerType == CT_TITLE_CHARACTER then
			return GetCustomTitle(originalTitle, customTitles[displayName][unitName]) or originalTitle
		elseif registerType == CT_TITLE_ACCOUNT then
			return GetCustomTitle(originalTitle, customTitles[displayName]) or originalTitle
		end
		return originalTitle
	end

	local GetUnitTitle_original = GetUnitTitle
	GetUnitTitle = function(unitTag)
		local unitTitleOriginal = GetUnitTitle_original(unitTag)
		local unitDisplayName = GetUnitDisplayName(unitTag)
		local unitCharacterName = GetUnitName(unitTag)
		local registerType = GetCustomTitleType(unitDisplayName, unitCharacterName)
		if registerType ~= CT_NO_TITLE then
			return GetModifiedTitle(unitTitleOriginal, unitDisplayName, unitCharacterName, registerType)
		end
		return unitTitleOriginal
	end

	local GetTitle_original = GetTitle
	GetTitle = function(index)
		local titleOriginal = GetTitle_original(index)
		local displayName = GetDisplayName()
		local characterName = GetUnitName("player")
		local registerType = GetCustomTitleType(displayName, characterName)
		if registerType ~= CT_NO_TITLE then
			return GetModifiedTitle(titleOriginal, displayName, characterName, registerType)
		end
		return titleOriginal
	end

end

local function OnAddonLoaded()
	if not libLoaded then
		libLoaded = true
		local LCC = LibStub('LibCustomTitlesAcer')
		LCC:Init()
		EVENT_MANAGER:UnregisterForEvent(LIB_NAME, EVENT_ADD_ON_LOADED)
	end
end

EVENT_MANAGER:RegisterForEvent(LIB_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)



--[[
public static String Rainbow(Int32 numOfSteps, Int32 step)
{
	var r = 0.0;
	var g = 0.0;
	var b = 0.0;
	var h = (Double)step / numOfSteps;
	var i = (Int32)(h * 6);
	var f = h * 6.0 - i;
	var q = 1 - f;

	switch (i % 6)
	{
		case 0:
			r = 1;
			g = f;
			b = 0;
			break;
		case 1:
			r = q;
			g = 1;
			b = 0;
			break;
		case 2:
			r = 0;
			g = 1;
			b = f;
			break;
		case 3:
			r = 0;
			g = q;
			b = 1;
			break;
		case 4:
			r = f;
			g = 0;
			b = 1;
			break;
		case 5:
			r = 1;
			g = 0;
			b = q;
			break;
	}
	return "#" + ((Int32)(r * 255)).ToString("X2") + ((Int32)(g * 255)).ToString("X2") + ((Int32)(b * 255)).ToString("X2");
}

--]]








			-- [100] = "Captain",
			-- [101] = "Major",
			-- [102] = "Centurion",
			-- [103] = "Colonel",
			-- [104] = "Tribune",
			-- [105] = "Brigadier",
			-- [106] = "Prefect",
			-- [107] = "Praetorian",
			-- [108] = "Palatine",
			-- [109] = "August Palatine",
			-- [110] = "Legate",
			-- [111] = "General",
			-- [112] = "Warlord",
			-- [113] = "Grand Warlord",
			-- [1140] = "Boethiah's Scythe",
			-- [114] = "Overlord",
			-- [1159] = "Deadlands Adept",
			-- [1248] = "Hero of Wrothgar",
			-- [1260] = "Kingmaker",
			-- [1304] = "Maelstrom Arena Champion",
			-- [1305] = "Stormproof",
			-- [1330] = "The Flawless Conqueror",
			-- [1383] = "Master Thief",
			-- [1391] = "Dro-m'Athra Destroyer",
			-- [1410] = "Executioner",
			-- [1434] = "Bane of the Gold Coast",
			-- [1444] = "Silencer",
			-- [1462] = "Ophidian Overlord",
			-- [1474] = "Shehai Shatterer",
			-- [1503] = "Mageslayer",
			-- [1538] = "Hist-Shadow",
			-- [1546] = "Sun's Dusk Reaper",
			-- [1677] = "Magnanimous",
			-- [1712] = "Librarian",
			-- [1716] = "Lady of Misrule",
			-- [1723] = "Royal Jester",
			-- [1727] = "Clan Mother",
			-- [1728] = "Lady",
			-- [1729] = "Councilor",
			-- [1730] = "Countess",
			-- [1808] = "Clockwork Confounder",
			-- [1810] = "Divayth Fyr's Coadjutor",
			-- [1836] = "The Dynamo",
			-- [1837] = "Disassembly General",
			-- [1838] = "Tick-Tock Tormentor",
			-- [1852] = "Champion of Vivec",
			-- [1868] = "Savior of Morrowind",
			-- [1879] = "Clanfriend",
			-- [1892] = "Star-Made Knight",
			-- [1915] = "Battleground Butcher",
			-- [1916] = "Tactician",
			-- [1918] = "Paragon",
			-- [1919] = "Relic Runner",
			-- [1921] = "The Merciless",
			-- [318] = "Daedric Lord Slayer",
			-- [494] = "Master Angler",
			-- [51] = "Monster Hunter",
			-- [587] = "Savior of Nirn",
			-- [617] = "Pact Hero",
			-- [618] = "Dominion Hero",
			-- [61] = "Covenant Hero",
			-- [621] = "Enemy of Coldharbour",
			-- [627] = "Explorer",
			-- [628] = "Tamriel Hero",
			-- [702] = "Master Wizard",
			-- [703] = "Fighters Guild Victor",
			-- [705] = "Grand Overlord",
			-- [706] = "First Sergeant",
			-- [92] = "Volunteer",
			-- [93] = "Recruit",
			-- [94] = "Tyro",
			-- [95] = "Legionary",
			-- [96] = "Veteran",
			-- [97] = "Corporal",
			-- [98] = "Sergeant",
			-- [992] = "Dragonstar Arena Champion",
			-- [99] = "Lieutenant",








