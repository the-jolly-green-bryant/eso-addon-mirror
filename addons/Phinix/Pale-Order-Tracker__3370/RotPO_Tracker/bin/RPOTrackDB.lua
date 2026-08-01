local RPOTracker = _G['RPOTracker']

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

RPOTracker.AccountDefaults = {
-- personal tracker settings
	showTracker = true,
	trackerLock = false,
	showGrouped = true,
	showBG = false,
	showLabel = true,
	trackerScale = 1,
	labelScale = 1,
	labelX = 2,
	labelY = -8,
	trackerX = 0,
	trackerY = 0,
	trackerPoint = TOPLEFT,
-- group tracker settings
	groupTable = {},
	groupMode = 1,
	raidMode = 1,
	showGroup = true,
	showRaid = true,
	groupSize = 24,
	raidSize = 16,
	gXO = 0,
	gYO = -28,
	rXO = 0,
	rYO = 0,
}
