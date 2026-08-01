local WW = WizardsWardrobe
WW.zones["SC1"] = {}
local SC1 = WW.zones["SC1"]

SC1.name = GetString(WWE_SC1_NAME)
SC1.tag = "SC1"
SC1.icon = "esoui/art/icons/achievement_025"
SC1.priority = 103
SC1.id = 144
SC1.node = 193
SC1.category = WW.ACTIVITIES.DUNGEONS

SC1.bosses = { [1] = {
		name = GetString(WWE_TRASH),
	}, [2] = {
		name = GetString(WWE_SC1_BOSS1),
	}, [3] = {
		name = GetString(WWE_SC1_BOSS2),
	}, [4] = {
		name = GetString(WWE_SC1_BOSS3),
	}, [5] = {
		name = GetString(WWE_SC1_BOSS4),
	}, [6] = {
		name = GetString(WWE_SC1_BOSS5),
	},
}

function SC1.Init()

end

function SC1.Reset()

end

function SC1.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
