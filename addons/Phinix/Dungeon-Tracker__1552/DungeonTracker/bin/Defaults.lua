local DTAddon = _G['DTAddon']
DTAddon.Strings = DTAddon:GetLanguage()

DTAddon.aOpts = {
	sDungeonHM = true,					-- show hard mode completion
	sDungeonTT = true,					-- show time trial completion
	sDungeonND = true,					-- show no death completion
	sDungeonFC = true,					-- dungeon faction completion
	sLFGcomp = true,					-- lfg: show dungeon completion
	sLFGdesc = true,					-- lfg: show dungeon description
	sDungeonNMap = true,				-- map: normal dungeon completion
	sDungeonVMap = true,				-- map: veteran dungeon completion
	sDelveGC = true,					-- map: delve group challenge completion
	sDelveBC = true,					-- map: delve boss completion
	sDelveFC = true,					-- map: delve faction completion
	cColorT = {0,1,0,1},				-- completed achievement name color
	cColorS = "00ff00",					-- completed achievement name color (text hex)
	iColorT = {0.48,0.48,0.48,1},		-- incomplete achievement name color
	iColorS = "7a7a7a",					-- incomplete achievement name color (text hex)
	kQuestMap = 2,						-- format for dungeon quest tooltip
	kSformat = 1,						-- format for completion text
	sortAlpha = true,					-- alphabetize completion lists
	highlightCC = true,					-- highlight the current character in name list
	vColorT = {0,1,1,1},				-- current character highlight color
	vColorS = "00ffff",					-- current character highlight color (text hex)
	dbVersion = 0,						-- used for database maintenance
	achievementDB = {},					-- database of all achievement completion values (see AchievementDB.lua)
	charEnabled = {},					-- database of character tracking status
}


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
