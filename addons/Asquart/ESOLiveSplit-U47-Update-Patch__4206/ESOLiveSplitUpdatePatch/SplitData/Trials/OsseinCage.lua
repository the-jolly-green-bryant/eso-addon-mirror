ESLUP = ESLUP or {}
local ESLUP = ESLUP

local startData = {
	x = 181950,
	y = 35399,
	z = 85491,
	r = 1.0,
}

local splits = {
	[1] = {
		name = "Trash 1",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[2] = {
		name = "Hall of Fleshcraft",
		icon = LIVE_SPLIT_ICON_BOSS,
		splitTrigger = LIVE_SPLIT_TRIGGER_EXIT_COMBAT,
	},
	[3] = {
		name = "Trash 2",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[4] = {
		name = "Jynorah & Skorkhif",
		icon = LIVE_SPLIT_ICON_BOSS,
		splitTrigger = LIVE_SPLIT_TRIGGER_EXIT_COMBAT,
	},
	[5] = {
		name = "Trash 3",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[6] = {
		name = "Overfiend Kazpian",
		icon = LIVE_SPLIT_ICON_ENDBOSS,
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_DEATH,
	},
}

local splitsWithSideBosses = {
	[1] = {
		name = "Trash 1",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[2] = {
		name = "Red Witch Gedna Relvel",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_DEATH,
	},
	[3] = {
		name = "Trash 2",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[4] = {
		name = "Hall of Fleshcraft",
		icon = LIVE_SPLIT_ICON_BOSS,
		splitTrigger = LIVE_SPLIT_TRIGGER_EXIT_COMBAT,
	},
	[5] = {
		name = "Trash 3",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[6] = {
		name = "Tortured Ranyu",
		splitTrigger = LIVE_SPLIT_TRIGGER_EXIT_COMBAT,
	},
	[7] = {
		name = "Trash 4",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[8] = {
		name = "Jynorah & Skorkhif",
		icon = LIVE_SPLIT_ICON_BOSS,
		splitTrigger = LIVE_SPLIT_TRIGGER_EXIT_COMBAT,
	},
	[9] = {
		name = "Trash 5",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[10] = {
		name = "Blood Drinker Thisa",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_DEATH,
	},
	[11] = {
		name = "Trash 6",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[12] = {
		name = "Overfiend Kazpian",
		icon = LIVE_SPLIT_ICON_ENDBOSS,
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_DEATH,
	},
}

function RegisterOCSplit()
	-------------------------- With Side Bosses
	SPLIT_MANAGER:RegisterSplit(1548, DUNGEON_DIFFICULTY_NORMAL, {
		id = "ESOLS_OsseinCage_Sidebosses",
		catName = "nOC",
		menuName = "Normal +Sideboss",
		startTrigger = LIVE_SPLIT_TRIGGER_LOCATION,
		startData = startData,
		par = LIVE_SPLIT_TIME_45_MINUTES,
		wr = 2700000,
		wrPlayer = "Zenimax",
		splits = splitsWithSideBosses,
	})

	SPLIT_MANAGER:RegisterSplit(1548, DUNGEON_DIFFICULTY_VETERAN, {
		id = "ESOLS_OsseinCage_Sidebosses_HM",
		catName = "vOC HM",
		menuName = "Veteran HM +Sideboss",
		startTrigger = LIVE_SPLIT_TRIGGER_BEGIN_TRIAL,
		par = LIVE_SPLIT_TIME_45_MINUTES,
		wr = 2700000,
		wrPlayer = "Zenimax",
		splits = splitsWithSideBosses,
	})

	SPLIT_MANAGER:RegisterSplit(1548, DUNGEON_DIFFICULTY_VETERAN, {
		id = "ESOLS_OsseinCage_Sidebosses",
		catName = "vOC",
		menuName = "Veteran +Sideboss",
		startTrigger = LIVE_SPLIT_TRIGGER_BEGIN_TRIAL,
		par = LIVE_SPLIT_TIME_45_MINUTES,
		wr = 2700000,
		wrPlayer = "Zenimax",
		splits = splitsWithSideBosses,
	})

	-------------------------- No Side Bosses
	SPLIT_MANAGER:RegisterSplit(1548, DUNGEON_DIFFICULTY_NORMAL, {
		id = "ESOLS_OsseinCage",
		catName = "nOC",
		menuName = "Normal",
		startTrigger = LIVE_SPLIT_TRIGGER_LOCATION,
		startData = startData,
		par = LIVE_SPLIT_TIME_45_MINUTES,
		wr = 2700000,
		wrPlayer = "Zenimax",
		splits = splits,
	})

	SPLIT_MANAGER:RegisterSplit(1548, DUNGEON_DIFFICULTY_VETERAN, {
		id = "ESOLS_OsseinCage_HM",
		catName = "vOC HM",
		menuName = "Veteran HM",
		startTrigger = LIVE_SPLIT_TRIGGER_BEGIN_TRIAL,
		par = LIVE_SPLIT_TIME_45_MINUTES,
		wr = 2700000,
		wrPlayer = "Zenimax",
		splits = splits,
	})

	SPLIT_MANAGER:RegisterSplit(1548, DUNGEON_DIFFICULTY_VETERAN, {
		id = "ESOLS_OsseinCage",
		catName = "vOC",
		menuName = "Veteran",
		startTrigger = LIVE_SPLIT_TRIGGER_BEGIN_TRIAL,
		par = LIVE_SPLIT_TIME_45_MINUTES,
		wr = 2700000,
		wrPlayer = "Zenimax",
		splits = splits,
	})

end

ESLUP.splitsToRegister["RegisterOCSplit"] = RegisterOCSplit