local WW = WizardsWardrobe
WW.zones["FG1"] = {}
local FG1 = WW.zones["FG1"]

FG1.name = GetString(WWE_FG1_NAME)
FG1.tag = "FG1"
FG1.icon = "esoui/art/icons/quest_head_monster_002"
FG1.priority = 101
FG1.id = 283
FG1.node = 98
FG1.category = WW.ACTIVITIES.DUNGEONS

FG1.bosses = { [1] = {
		name = GetString(WWE_TRASH),
	}, [2] = {
		name = GetString(WWE_FG1_BOSS1),
	}, [3] = {
		name = GetString(WWE_FG1_BOSS2),
	}, [4] = {
		name = GetString(WWE_FG1_BOSS3),
	}, [5] = {
		name = GetString(WWE_FG1_BOSS4),
	}, [6] = {
		name = GetString(WWE_FG1_BOSS5),
	},
}

function FG1.Init()

end

function FG1.Reset()

end

function FG1.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
