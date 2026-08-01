local WW = WizardsWardrobe
WW.zones["DSC1"] = {}
local DSC1 = WW.zones["DSC1"]

DSC1.name = GetString(WWE_DSC1_NAME)
DSC1.tag = "DSC1"
DSC1.icon = "esoui/art/icons/achievement_025"
DSC1.priority = 107
DSC1.id = 63
DSC1.node = 198
DSC1.category = WW.ACTIVITIES.DUNGEONS

DSC1.bosses = { [1] = {
		name = GetString(WWE_TRASH),
	}, [2] = {
		name = GetString(WWE_DSC1_BOSS1),
	}, [3] = {
		name = GetString(WWE_DSC1_BOSS2),
	}, [4] = {
		name = GetString(WWE_DSC1_BOSS3),
	}, [5] = {
		name = GetString(WWE_DSC1_BOSS4),
	}, [6] = {
		name = GetString(WWE_DSC1_BOSS5),
	}, [7] = {
		name = GetString(WWE_DSC1_BOSS6),
	},
}

function DSC1.Init()

end

function DSC1.Reset()

end

function DSC1.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
