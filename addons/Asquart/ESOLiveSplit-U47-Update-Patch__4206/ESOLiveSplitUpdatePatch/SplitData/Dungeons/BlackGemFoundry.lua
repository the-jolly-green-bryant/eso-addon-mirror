ESLUP = ESLUP or {}
local ESLUP = ESLUP

local startData = {
	x = 51129,
	y = 35395,
	z = 61195,
	r = 1.0,
}

local splits = {
	[1] = {
		name = "Trash 1",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[2] = {
		name = "Quarrymaster Saldezaar",
		icon = LIVE_SPLIT_ICON_BOSS,
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_DEATH,
	},
	[3] = {
		name = "Trash 2",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[4] = {
		name = "Black Gem Monstrosity",
		icon = LIVE_SPLIT_ICON_BOSS,
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_DEATH,
	},
	[5] = {
		name = "Trash 3",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[6] = {
		name = "High Soulbinder Vykand",
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
		name = "Prospector Lyrakta",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_DEATH,
	},
	[3] = {
		name = "Trash 2",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[4] = {
		name = "Quarrymaster Saldezaar",
		icon = LIVE_SPLIT_ICON_BOSS,
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_DEATH,
	},
	[5] = {
		name = "Trash 3",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[6] = {
		name = "Gemcarver Hynax",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_DEATH,
	},
	[7] = {
		name = "Trash 4",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[8] = {
		name = "Black Gem Monstrosity",
		icon = LIVE_SPLIT_ICON_BOSS,
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_DEATH,
	},
	[9] = {
		name = "Trash 5",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[10] = {
		name = "Misura, Assistant to the High Soulbinder",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_DEATH,
	},
	[11] = {
		name = "Trash 6",
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_ENTER,
	},
	[12] = {
		name = "High Soulbinder Vykand",
		icon = LIVE_SPLIT_ICON_ENDBOSS,
		splitTrigger = LIVE_SPLIT_TRIGGER_BOSS_DEATH,
	},
}

function RegisterBGFSplit()
	-------------------------- With Side Bosses
	SPLIT_MANAGER:RegisterSplit(1552, DUNGEON_DIFFICULTY_NORMAL, {
		id = "ESOLS_BlackGemFoundry_Sidebosses",
		catName = "nBGF",
		menuName = "Normal +Sideboss",
		startTrigger = LIVE_SPLIT_TRIGGER_LOCATION,
		startData = startData,
		par = LIVE_SPLIT_TIME_25_MINUTES,
		wr = 1500000,
		wrPlayer = "Zenimax",
		splits = splitsWithSideBosses,
	})

	SPLIT_MANAGER:RegisterSplit(1552, DUNGEON_DIFFICULTY_VETERAN, {
		id = "ESOLS_BlackGemFoundry_Sidebosses_HM",
		catName = "vBGF HM",
		menuName = "Veteran HM +Sideboss",
		startTrigger = LIVE_SPLIT_TRIGGER_ENTER_COMBAT,
		par = LIVE_SPLIT_TIME_25_MINUTES,
		wr = 1500000,
		wrPlayer = "Zenimax",
		splits = splitsWithSideBosses,
	})

	SPLIT_MANAGER:RegisterSplit(1552, DUNGEON_DIFFICULTY_VETERAN, {
		id = "ESOLS_BlackGemFoundry_Sidebosses",
		catName = "vBGF",
		menuName = "Veteran +Sideboss",
		startTrigger = LIVE_SPLIT_TRIGGER_ENTER_COMBAT,
		par = LIVE_SPLIT_TIME_25_MINUTES,
		wr = 1500000,
		wrPlayer = "Zenimax",
		splits = splitsWithSideBosses,
	})

	-------------------------- No Side Bosses
	SPLIT_MANAGER:RegisterSplit(1552, DUNGEON_DIFFICULTY_NORMAL, {
		id = "ESOLS_BlackGemFoundry",
		catName = "nBGF",
		menuName = "Normal",
		startTrigger = LIVE_SPLIT_TRIGGER_LOCATION,
		startData = startData,
		par = LIVE_SPLIT_TIME_25_MINUTES,
		wr = 1500000,
		wrPlayer = "Zenimax",
		splits = splits,
	})

	SPLIT_MANAGER:RegisterSplit(1552, DUNGEON_DIFFICULTY_VETERAN, {
		id = "ESOLS_BlackGemFoundry_HM",
		catName = "vBGF HM",
		menuName = "Veteran HM",
		startTrigger = LIVE_SPLIT_TRIGGER_ENTER_COMBAT,
		par = LIVE_SPLIT_TIME_25_MINUTES,
		wr = 1500000,
		wrPlayer = "Zenimax",
		splits = splits,
	})

	SPLIT_MANAGER:RegisterSplit(1552, DUNGEON_DIFFICULTY_VETERAN, {
		id = "ESOLS_BlackGemFoundry",
		catName = "vBGF",
		menuName = "Veteran",
		startTrigger = LIVE_SPLIT_TRIGGER_ENTER_COMBAT,
		par = LIVE_SPLIT_TIME_25_MINUTES,
		wr = 1500000,
		wrPlayer = "Zenimax",
		splits = splits,
	})

end

ESLUP.splitsToRegister["RegisterBGFSplit"] = RegisterBGFSplit
