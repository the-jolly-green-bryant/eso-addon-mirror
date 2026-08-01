local WW = WizardsWardrobe
WW.zones["COA2"] = {}
local COA2 = WW.zones["COA2"]

COA2.name = GetString(WWE_COA2_NAME)
COA2.tag = "COA2"
COA2.icon = "esoui/art/icons/achievement_025"
COA2.priority = 115
COA2.id = 681
COA2.node = 268
COA2.category = WW.ACTIVITIES.DUNGEONS

COA2.bosses = { [1] = {
		name = GetString(WWE_TRASH),
	}, [2] = {
		name = GetString(WWE_COA2_BOSS1),
	}, [3] = {
		name = GetString(WWE_COA2_BOSS2),
	}, [4] = {
		name = GetString(WWE_COA2_BOSS3),
	}, [5] = {
		name = GetString(WWE_COA2_BOSS4),
	}, [6] = {
		name = GetString(WWE_COA2_BOSS5),
	}, [7] = {
		name = GetString(WWE_COA2_BOSS6),
	}, [8] = {
		name = GetString(WWE_COA2_BOSS7),
	},
}

function COA2.Init()

end

function COA2.Reset()

end

function COA2.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
