local WW = WizardsWardrobe
WW.zones["DSA"] = {}
local DSA = WW.zones["DSA"]

DSA.name = GetString(WWE_DSA_NAME)
DSA.tag = "DSA"
DSA.icon = "esoui/art/icons/achievement_026"
DSA.priority = -100
DSA.id = 635
DSA.node = 270
DSA.category = WW.ACTIVITIES.ARENAS

DSA.bosses = { [1] = {
		name = GetString(WWE_TRASH),
	}, [2] = {
		name = GetString(WWE_DSA_BOSS1),
	}, [3] = {
		name = GetString(WWE_DSA_BOSS2),
	}, [4] = {
		name = GetString(WWE_DSA_BOSS3),
	}, [5] = {
		name = GetString(WWE_DSA_BOSS4),
	}, [6] = {
		name = GetString(WWE_DSA_BOSS5),
	}, [7] = {
		name = GetString(WWE_DSA_BOSS6),
	}, [8] = {
		name = GetString(WWE_DSA_BOSS7),
	}, [9] = {
		name = GetString(WWE_DSA_BOSS8),
	}, [10] = {
		name = GetString(WWE_DSA_BOSS9),
	}, [11] = {
		name = GetString(WWE_DSA_BOSS10),
	},
	
}

function DSA.Init()

end

function DSA.Reset()

end

function DSA.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
