local WW = WizardsWardrobe
WW.zones["COA1"] = {}
local COA1 = WW.zones["COA1"]

COA1.name = GetString(WWE_COA1_NAME)
COA1.tag = "COA1"
COA1.icon = "esoui/art/icons/achievement_025"
COA1.priority = 114
COA1.id = 176
COA1.node = 197
COA1.category = WW.ACTIVITIES.DUNGEONS

COA1.bosses = { [1] = {
		name = GetString(WWE_TRASH),
	}, [2] = {
		name = GetString(WWE_COA1_BOSS1),
	}, [3] = {
		name = GetString(WWE_COA1_BOSS2),
	}, [4] = {
		name = GetString(WWE_COA1_BOSS3),
	}, [5] = {
		name = GetString(WWE_COA1_BOSS4),
	}, [6] = {
		name = GetString(WWE_COA1_BOSS5),
	}, [7] = {
		name = GetString(WWE_COA1_BOSS6),
	},
}

function COA1.Init()

end

function COA1.Reset()

end

function COA1.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
