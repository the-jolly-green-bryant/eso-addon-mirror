local WW = WizardsWardrobe
WW.zones["COH2"] = {}
local COH2 = WW.zones["COH2"]

COH2.name = GetString(WWE_COH2_NAME)
COH2.tag = "COH2"
COH2.icon = "esoui/art/icons/achievement_025"
COH2.priority = 117
COH2.id = 932
COH2.node = 269
COH2.category = WW.ACTIVITIES.DUNGEONS

COH2.bosses = { [1] = {
		name = GetString(WWE_TRASH),
	}, [2] = {
		name = GetString(WWE_COH2_BOSS1),
	}, [3] = {
		name = GetString(WWE_COH2_BOSS2),
	}, [4] = {
		name = GetString(WWE_COH2_BOSS3),
	}, [5] = {
		name = GetString(WWE_COH2_BOSS4),
	}, [6] = {
		name = GetString(WWE_COH2_BOSS5),
	}, [7] = {
		name = GetString(WWE_COH2_BOSS6),
	},
}

function COH2.Init()

end

function COH2.Reset()

end

function COH2.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
