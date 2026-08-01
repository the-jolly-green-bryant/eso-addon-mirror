JoGroup = JoGroup or {}
local Jo = JoGroup

Jo.defaults = {
	position = {
		offsetX = 32,
		offsetY = 32,
	},
	opacity = {
		oorAlpha = 0.5,
		glossAlpha = 1,
		bgAlpha = 0.8,
	},
	text = {
		fontSize = 13,
		fontFam = "BOLD_FONT",
	},
	ordening = {
		sort = "index",
		padding = 5,
		unitsPerColumn = 6,
		directionX = "right",
		directionY = "down",
	},
	colours = {
		tankColour = "red",
		healerColour = "brightgreen",
		dpsColour = "blue",
		customColour = false,
		customTankColour = {1, 1, 1, 1},
		customHealerColour = {1, 1, 1, 1},
		customDpsColour = {1, 1, 1, 1},
		shield = {1, 0.49, 0.13, 0.88},
		warHorn = {0.2, 0.75, 0.15, 1},
		crShade = {0.36, 0.13, 0.75, .8},
	},
	show = {
		defaultFrames = false,
		notifications = true,
		healthValues = false,
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