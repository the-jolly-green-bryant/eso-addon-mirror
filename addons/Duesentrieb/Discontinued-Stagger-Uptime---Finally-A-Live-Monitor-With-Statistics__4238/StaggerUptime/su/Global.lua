StaggerUptime = {
	name = "StaggerUptime",
	author = "@Duesentrieb",
	version = "20250901-2358",
	chat = "[SU]",

	displayText = "↓[0] 0.0%",
	fontColor = {1, 0, 0, 1},
	isForceShow = false,

	isCombat = false,
	isEquipped = true,

	staggerTracer = {},
	staggerStacks = 0,
	staggerCounter = 0,
	staggerCast = false,

	fightStartTime = 0,
	fightUpdateTime = 0,
	buffEndTime = 0,
	staggerEndTime3X = 0,
	staggerEndTime2X = 0,
	staggerEndTime1X = 0,
	staggerTime3X = 0,
	staggerTime2X = 0,
	staggerTime1X = 0,
	percentage3X = 0,
	percentage2X = 0,
	percentage1X = 0,

	default = {
		isEnabled = true,
		isOnlyCombat = false,
		isOnlyTrackPlayer = true,
		isEnabledChat = true,
		minFightTime = 0,
		fontSize = 48,
		offsetX = 0,
		offsetY = 0,
	},

	STONEGIANT_DEBUFF_ID = 134336,
	STONEGIANT_BUFF_ID = 31816,
	SLOT_ID = 31816,
	SLOT_ID_PROJ = 133027,

	sVar = {},
	sVarVersion = 1,
	sVarName = "StaggerUptimeVariables",

	varAddonPanel = nil,
	isLoaded = false
}