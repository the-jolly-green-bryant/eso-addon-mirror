CarrionBlocker = {
	name = "CarrionBlocker",
	author = "@Duesentrieb",
	version = "20250827-1519",
	chat = "[CB]",

	osseinCageId = 1548,

	playerStacks = 0,
	isCarrionShield = false,

	isForceShow = false,
	colorHex 	= 0x00ff005f,
	colorHex0 	= 0x00ff001f,
	colorHex25 	= 0x7fff003f,
	colorHex50 	= 0xffff005f,
	colorHex75 	= 0xff7f007f,
	colorHex100 = 0xff00009f,

	default = {
		isEnabled = true,
		isEnabledChat = true,
		threshold = 4,
		isSnapToGrid = true,
		isShowBorderColor = true,
		displayText = "CarrionBlocker",
		fontColor = {1, 0, 0, 1},
		fontSize = 48,
		offsetX = 0,
		offsetY = 0,
	},

	CAUSTIC_CARRION_ABILITY_ID_1 = 240708,
	CAUSTIC_CARRION_ABILITY_ID_2 = 241089,

	synergyNames = {
		["de"] = "Aasschild",
		["en"] = "Carrion Shield",
		["es"] = "Escudo de carroña",
		["fr"] = "Bouclier de charogne",
		["ru"] = "Щит падальщиков",
	},

	sVar = {},
	sVarVersion = 1,
	sVarName = "CarrionBlockerVariables",

	varAddonPanel = nil,
	isLoaded = false
}