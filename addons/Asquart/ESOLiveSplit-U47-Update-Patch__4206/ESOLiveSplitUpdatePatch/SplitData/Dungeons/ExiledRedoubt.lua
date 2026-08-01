ESLUP = ESLUP or {}
local ESLUP = ESLUP

local startData = {
	x = 95740,
	y = 33549,
	z = 114891,
	r = 3.7,
}

local splits = {
	[1] = {
		name = "Trash 1",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[2] = {
		name = "Garvin the Tracker",
		icon = LIVE_SPLIT_ICON_BOSS,
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_DEATH,
	},
	[3] = {
		name = "Trash 2",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[4] = {
		name = "Noriwen",
		icon = LIVE_SPLIT_ICON_BOSS,
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_DEATH,
	},
	[5] = {
		name = "Trash 3",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[6] = {
		name = "Orpheon the Tactician",
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
		name = "Guard Captain Paratius",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_DEATH,
	},
	[3] = {
		name = "Trash 2",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[4] = {
		name = "Executioner Jerensi",
		icon = LIVE_SPLIT_ICON_BOSS,
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_DEATH,
	},
	[5] = {
		name = "Trash 3",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[6] = {
		name = "Docent Domitius",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_DEATH,
	},
	[7] = {
		name = "Trash 4",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[8] = {
		name = "Prime Sorcerer Vandorallen",
		icon = LIVE_SPLIT_ICON_BOSS,
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_DEATH,
	},
	[9] = {
		name = "Trash 5",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[10] = {
		name = "Eliana Albus",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_DEATH,
	},
	[11] = {
		name = "Trash 6",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[12] = {
		name = "Squall of Retribution",
		icon = LIVE_SPLIT_ICON_ENDBOSS,
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_DEATH,
	},
}

function RegisterERSplit()
	-------------------------- With Side Bosses
	SPLIT_MANAGER:RegisterSplit(1496, DUNGEON_DIFFICULTY_NORMAL, {
		id = "ESOLS_ExiledRedoubt_Sidebosses",
		catName = "nER",
		menuName = "Normal +Sideboss",
		startTrigger = LIVE_SPLIT_TRIGGER_LOCATION,
		startData = startData,
		par = LIVE_SPLIT_TIME_25_MINUTES,
		wr = 1500000,
		wrPlayer = "Zenimax",
		splits = splitsWithSideBosses,
	})

	SPLIT_MANAGER:RegisterSplit(1496, DUNGEON_DIFFICULTY_VETERAN, {
		id = "ESOLS_ExiledRedoubt_Sidebosses_HM",
		catName = "vER HM",
		menuName = "Veteran HM +Sideboss",
		startTrigger = LIVE_SPLIT_TRIGGER_ENTER_COMBAT,
		par = LIVE_SPLIT_TIME_25_MINUTES,
		wr = 1500000,
		wrPlayer = "Zenimax",
		splits = splitsWithSideBosses,
	})

	SPLIT_MANAGER:RegisterSplit(1496, DUNGEON_DIFFICULTY_VETERAN, {
		id = "ESOLS_ExiledRedoubt_Sidebosses",
		catName = "vER",
		menuName = "Veteran +Sideboss",
		startTrigger = LIVE_SPLIT_TRIGGER_ENTER_COMBAT,
		par = LIVE_SPLIT_TIME_25_MINUTES,
		wr = 1500000,
		wrPlayer = "Zenimax",
		splits = splitsWithSideBosses,
	})

	-------------------------- No Side Bosses
	SPLIT_MANAGER:RegisterSplit(1496, DUNGEON_DIFFICULTY_NORMAL, {
		id = "ESOLS_ExiledRedoubt",
		catName = "nER",
		menuName = "Normal",
		startTrigger = LIVE_SPLIT_TRIGGER_LOCATION,
		startData = startData,
		par = LIVE_SPLIT_TIME_25_MINUTES,
		wr = 1500000,
		wrPlayer = "Zenimax",
		splits = splits,
	})

	SPLIT_MANAGER:RegisterSplit(1496, DUNGEON_DIFFICULTY_VETERAN, {
		id = "ESOLS_ExiledRedoubt_HM",
		catName = "vER HM",
		menuName = "Veteran HM",
		startTrigger = LIVE_SPLIT_TRIGGER_ENTER_COMBAT,
		par = LIVE_SPLIT_TIME_25_MINUTES,
		wr = 1500000,
		wrPlayer = "Zenimax",
		splits = splits,
	})

	SPLIT_MANAGER:RegisterSplit(1496, DUNGEON_DIFFICULTY_VETERAN, {
		id = "ESOLS_ExiledRedoubt",
		catName = "vER",
		menuName = "Veteran",
		startTrigger = LIVE_SPLIT_TRIGGER_ENTER_COMBAT,
		par = LIVE_SPLIT_TIME_25_MINUTES,
		wr = 1500000,
		wrPlayer = "Zenimax",
		splits = splits,
	})

end

ESLUP.splitsToRegister["RegisterERSplit"] = RegisterERSplit