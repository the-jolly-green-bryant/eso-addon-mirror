ESLUP = ESLUP or {}
local ESLUP = ESLUP

local startData = {
	x = 45062,
	y = 37747,
	z = 65543,
	r = 3.5,
}

local splits = {
	[1] = {
		name = "Trash 1",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[2] = {
		name = "Poxito",
		icon = LIVE_SPLIT_ICON_BOSS,
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_DEATH,
	},
	[3] = {
		name = "Trash 2",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[4] = {
		name = "Voskrona Stonehulk Poxito",
		icon = LIVE_SPLIT_ICON_BOSS,
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_DEATH,
	},
	[5] = {
		name = "Trash 3",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[6] = {
		name = "Talen-Lah",
		icon = LIVE_SPLIT_ICON_ENDBOSS,
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_DEATH,
	},
}

function RegisterNCSplit()
	-------------------------- No Side Bosses
	SPLIT_MANAGER:RegisterSplit(1551, DUNGEON_DIFFICULTY_NORMAL, {
		id = "ESOLS_NajCaldeesh",
		catName = "nNC",
		menuName = "Normal",
		startTrigger = LIVE_SPLIT_TRIGGER_LOCATION,
		startData = startData,
		par = LIVE_SPLIT_TIME_25_MINUTES,
		wr = 1500000,
		wrPlayer = "Zenimax",
		splits = splits,
	})

	SPLIT_MANAGER:RegisterSplit(1551, DUNGEON_DIFFICULTY_VETERAN, {
		id = "ESOLS_NajCaldeesh_HM",
		catName = "vNC HM",
		menuName = "Veteran HM",
		startTrigger = LIVE_SPLIT_TRIGGER_ENTER_COMBAT,
		par = LIVE_SPLIT_TIME_25_MINUTES,
		wr = 1500000,
		wrPlayer = "Zenimax",
		splits = splits,
	})

	SPLIT_MANAGER:RegisterSplit(1551, DUNGEON_DIFFICULTY_VETERAN, {
		id = "ESOLS_NajCaldeesh",
		catName = "vNC",
		menuName = "Veteran",
		startTrigger = LIVE_SPLIT_TRIGGER_ENTER_COMBAT,
		par = LIVE_SPLIT_TIME_25_MINUTES,
		wr = 1500000,
		wrPlayer = "Zenimax",
		splits = splits,
	})

end

ESLUP.splitsToRegister["RegisterNCSplit"] = RegisterNCSplit