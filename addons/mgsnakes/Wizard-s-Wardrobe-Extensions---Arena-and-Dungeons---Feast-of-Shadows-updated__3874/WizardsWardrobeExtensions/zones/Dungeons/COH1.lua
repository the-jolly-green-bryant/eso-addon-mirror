local WW = WizardsWardrobe
WW.zones["COH1"] = {}
local COH1 = WW.zones["COH1"]

COH1.name = GetString(WWE_COH1_NAME)
COH1.tag = "COH1"
COH1.icon = "esoui/art/icons/achievement_025"
COH1.priority = 116
COH1.id = 130
COH1.node = 190
COH1.category = WW.ACTIVITIES.DUNGEONS

COH1.bosses = { [1] = {
		name = GetString(WWE_TRASH),
	}, [2] = {
		name = GetString(WWE_COH1_BOSS1),
	}, [3] = {
		name = GetString(WWE_COH1_BOSS2),
	}, [4] = {
		name = GetString(WWE_COH1_BOSS3),
	}, [5] = {
		name = GetString(WWE_COH1_BOSS4),
	}, [6] = {
		name = GetString(WWE_COH1_BOSS5),
	}, [7] = {
		name = GetString(WWE_COH1_BOSS6),
	},
}

function COH1.Init()

end

function COH1.Reset()

end

function COH1.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
