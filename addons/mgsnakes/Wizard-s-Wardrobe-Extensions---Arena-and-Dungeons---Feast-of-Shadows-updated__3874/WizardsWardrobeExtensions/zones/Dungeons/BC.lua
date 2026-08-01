local WW = WizardsWardrobe
WW.zones["BC"] = {}
local BC = WW.zones["BC"]

BC.name = GetString(WWE_BC_NAME)
BC.tag = "BC"
BC.icon = "esoui/art/icons/achievement_025"
BC.priority = 122
BC.id = 64
BC.node = 187
BC.category = WW.ACTIVITIES.DUNGEONS

BC.bosses = { [1] = {
		name = GetString(WWE_TRASH),
	}, [2] = {
		name = GetString(WWE_BC_BOSS1),
	}, [3] = {
		name = GetString(WWE_BC_BOSS2),
	}, [4] = {
		name = GetString(WWE_BC_BOSS3),
	}, [5] = {
		name = GetString(WWE_BC_BOSS4),
	}, [6] = {
		name = GetString(WWE_BC_BOSS5),
	}, [7] = {
		name = GetString(WWE_BC_BOSS6),
	},
}

function BC.Init()

end

function BC.Reset()

end

function BC.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
