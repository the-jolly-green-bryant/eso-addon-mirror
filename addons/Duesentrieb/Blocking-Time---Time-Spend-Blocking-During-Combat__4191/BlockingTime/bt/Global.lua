BlockingTime = {
	name = "BlockingTime",
	author = "@Duesentrieb",
	version = "20260220-0002",
	chat = "[Blocking Time]",

	blockedTime = 0,
	fightStartTime = 0,
	fightUpdateTime = 0,

	colorGradient = "|c00ff00",

	groupRole = 0,
	isCombat = false,
	isBlocking = false,

	penaltyTime = 0,
	penaltyStacks = 0,
	penaltyQueue = 0,

	default = {
		enableAddon = true,
		isEnabledSolo = true,
		isEnabledTank = true,
		isEnabledHeal = false,
		isEnabledDPS = false,
		timeFightMin = 30,
		volumePenaltyClick = 5,
	},

	COL = {
		OG = "|cff7f00",
		WH = "|cffffff",
		GN = "|c00ff00",
		RD = "|cff0000",
		END = "|r"
	},

	SV = {},
	SVVersion = 1,
	SVName = "BlockingTimeVariables",

	varAddonPanel = nil,
	isLoaded = false
}