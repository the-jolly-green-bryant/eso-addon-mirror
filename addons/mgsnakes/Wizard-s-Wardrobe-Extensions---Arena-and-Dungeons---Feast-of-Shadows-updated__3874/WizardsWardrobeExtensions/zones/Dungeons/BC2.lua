local WW = WizardsWardrobe
WW.zones["BC2"] = {}
local BC2 = WW.zones["BC2"]

BC2.name = GetString(WWE_BC2_NAME)
BC2.tag = "BC2"
BC2.icon = "esoui/art/icons/achievement_025"
BC2.priority = 106
BC2.id = 935
BC2.node = 262
BC2.category = WW.ACTIVITIES.DUNGEONS

BC2.bosses = { [1] = {
		name = GetString(WWE_TRASH),
	}, [2] = {
		name = GetString(WWE_BC2_BOSS1),
	}, [3] = {
		name = GetString(WWE_BC2_BOSS2),
	}, [4] = {
		name = GetString(WWE_BC2_BOSS3),
	}, [5] = {
		name = GetString(WWE_BC2_BOSS4),
	}, [6] = {
		name = GetString(WWE_BC2_BOSS5),
	}, [7] = {
		name = GetString(WWE_BC2_BOSS6),
	},
}

function BC2.Init()

end

function BC2.Reset()

end

function BC2.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
