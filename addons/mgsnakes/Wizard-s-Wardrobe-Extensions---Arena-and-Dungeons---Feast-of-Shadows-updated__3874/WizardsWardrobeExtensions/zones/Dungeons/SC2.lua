local WW = WizardsWardrobe
WW.zones["SC2"] = {}
local SC2 = WW.zones["SC2"]

SC2.name = GetString(WWE_SC2_NAME)
SC2.tag = "SC2"
SC2.icon = "esoui/art/icons/achievement_025"
SC2.priority = 104
SC2.id = 936
SC2.node = 267
SC2.category = WW.ACTIVITIES.DUNGEONS

SC2.bosses = { [1] = {
		name = GetString(WWE_TRASH),
	}, [2] = {
		name = GetString(WWE_SC2_BOSS1),
	}, [3] = {
		name = GetString(WWE_SC2_BOSS2),
	}, [4] = {
		name = GetString(WWE_SC2_BOSS3),
	}, [5] = {
		name = GetString(WWE_SC2_BOSS4),
	}, [6] = {
		name = GetString(WWE_SC2_BOSS5),
	}, [7] = {
		name = GetString(WWE_SC2_BOSS6),
	},
}

function SC2.Init()

end

function SC2.Reset()

end

function SC2.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
