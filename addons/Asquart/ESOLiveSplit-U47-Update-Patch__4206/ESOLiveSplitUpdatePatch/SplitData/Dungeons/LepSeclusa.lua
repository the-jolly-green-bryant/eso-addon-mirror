ESLUP = ESLUP or {}
local ESLUP = ESLUP

local startData = {
	x = 121089,
	y = 34673,
	z = 159055,
	r = 5.0,
}

local splitsWithSideBosses = {
	[1] = {
		name = "Trash 1",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[2] = {
		name = "Lewin Frey",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_DEATH,
	},
	[3] = {
		name = "Trash 2",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[4] = {
		name = "Garvin the Tracker",
		icon = LIVE_SPLIT_ICON_BOSS,
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_DEATH,
	},
	[5] = {
		name = "Trash 3",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[6] = {
		name = "Deserter Knight",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_DEATH,
	},
	[7] = {
		name = "Trash 4",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[8] = {
		name = "Noriwen",
		icon = LIVE_SPLIT_ICON_BOSS,
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_DEATH,
	},
	[9] = {
		name = "Trash 5",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[10] = {
		name = "Flamedancer Ajim-Rei",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_DEATH,
	},
	[11] = {
		name = "Trash 6",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[12] = {
		name = "Orpheon the Tactician",
		icon = LIVE_SPLIT_ICON_ENDBOSS,
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_DEATH,
	},
}

function RegisterLSSplit()
	-------------------------- With Side Bosses
	SPLIT_MANAGER:RegisterSplit(1497, DUNGEON_DIFFICULTY_NORMAL, {
		id = "ESOLS_LepSeclusa",
		catName = "nLS",
		menuName = "Normal +Sideboss",
		startTrigger = LIVE_SPLIT_TRIGGER_LOCATION,
		startData = startData,
		par = LIVE_SPLIT_TIME_25_MINUTES,
		wr = 1500000,
		wrPlayer = "Zenimax",
		splits = splitsWithSideBosses,
	})

	SPLIT_MANAGER:RegisterSplit(1497, DUNGEON_DIFFICULTY_VETERAN, {
		id = "ESOLS_LepSeclusa_HM",
		catName = "vLS HM",
		menuName = "Veteran HM",
		startTrigger = LIVE_SPLIT_TRIGGER_ENTER_COMBAT,
		par = LIVE_SPLIT_TIME_25_MINUTES,
		wr = 1500000,
		wrPlayer = "Zenimax",
		splits = splitsWithSideBosses,
	})

	SPLIT_MANAGER:RegisterSplit(1497, DUNGEON_DIFFICULTY_VETERAN, {
		id = "ESOLS_LepSeclusa",
		catName = "vLS",
		menuName = "Veteran",
		startTrigger = LIVE_SPLIT_TRIGGER_ENTER_COMBAT,
		par = LIVE_SPLIT_TIME_25_MINUTES,
		wr = 1500000,
		wrPlayer = "Zenimax",
		splits = splitsWithSideBosses,
	})

end

ESLUP.splitsToRegister["RegisterLSSplit"] = RegisterLSSplit