JoGroup = JoGroup or {}
local Jo = JoGroup

Jo.defaults = {
	position = {
		offsetX = 32,
		offsetY = 32,
	},
	opacity = {
		oorAlpha = 0.5,
		glossAlpha = 0,
		bgAlpha = 0.7,
	},
	text = {
		fontSize = 17,
		fontFam = "GAMEPAD_MEDIUM_FONT",
	},
	ordening = {
		sort = "role",
		padding = 3,
		unitsPerColumn = 6,
		directionX = "right",
		directionY = "down",
	},
	colours = {
		tankColour = "red",
		healerColour = "brightgreen",
		dpsColour = "blue",
		customColour = false,
		customTankColour = 0xFFFFFFFF,
		customHealerColour = 0xFFFFFFFF,
		customDpsColour = 0xFFFFFFFF,
		shield = 0xFF9933CC,
		trauma = 0xFF99FF99,
		warHorn = 0x33CC33FF,
		crShade = 0x6633CCCC,
	},
	show = {
		defaultFrames = false,
		notifications = true,
		healthValues = true,
		fullNumberHealth = false,
		foodBuffs = true,
		regen = true,
		acctName = true,
		warHorn = true,
		crShade = true,
		diffIndicator = true,
	},
	frameWidth = 145,
	compactMode = false,
}
Jo.barColour = {
	blue = ZO_POWER_BAR_GRADIENT_COLORS[POWERTYPE_MAGICKA],
	red = ZO_POWER_BAR_GRADIENT_COLORS[POWERTYPE_HEALTH],
	green = ZO_POWER_BAR_GRADIENT_COLORS[POWERTYPE_STAMINA],
	yellow = ZO_SKILL_XP_BAR_GRADIENT_COLORS,
	orange = ZO_CP_BAR_GRADIENT_COLORS[ATTRIBUTE_HEALTH],
	brightgreen = ZO_AVA_RANK_GRADIENT_COLORS,
	silverblue = ZO_CONDITION_GRADIENT_COLORS,
}
Jo.frameHeight = 60
Jo.leaderIconSize = 28
Jo.indicatorSize = 18
Jo.classIconSize = 18
Jo.champIconSize = 10
Jo.deadIconSize = 48
Jo.statusBarHeight = 20
Jo.innerBarHeight = 16
Jo.statusBorder = 2
Jo.arrowSize = 16
