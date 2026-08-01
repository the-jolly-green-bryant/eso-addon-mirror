local WW = WizardsWardrobe
WW.zones["BC1"] = {}
local BC1 = WW.zones["BC1"]

BC1.name = GetString(WWE_BC1_NAME)
BC1.tag = "BC1"
BC1.icon = "esoui/art/icons/achievement_025"
BC1.priority = 105
BC1.id = 380
BC1.node = 194
BC1.category = WW.ACTIVITIES.DUNGEONS

BC1.bosses = { [1] = {
		name = GetString(WWE_TRASH),
	}, [2] = {
		name = GetString(WWE_BC1_BOSS1),
	}, [3] = {
		name = GetString(WWE_BC1_BOSS2),
	}, [4] = {
		name = GetString(WWE_BC1_BOSS3),
	}, [5] = {
		name = GetString(WWE_BC1_BOSS4),
	}, [6] = {
		name = GetString(WWE_BC1_BOSS5),
	},
}

function BC1.Init()

end

function BC1.Reset()

end

function BC1.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
