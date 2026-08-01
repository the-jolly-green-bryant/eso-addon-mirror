local WW = WizardsWardrobe
WW.zones["DSC2"] = {}
local DSC2 = WW.zones["DSC2"]

DSC2.name = GetString(WWE_DSC2_NAME)
DSC2.tag = "DSC2"
DSC2.icon = "esoui/art/icons/achievement_025"
DSC2.priority = 108
DSC2.id = 930
DSC2.node = 264
DSC2.category = WW.ACTIVITIES.DUNGEONS

DSC2.bosses = { [1] = {
		name = GetString(WWE_TRASH),
	}, [2] = {
		name = GetString(WWE_DSC2_BOSS1),
	}, [3] = {
		name = GetString(WWE_DSC2_BOSS2),
	}, [4] = {
		name = GetString(WWE_DSC2_BOSS3),
	}, [5] = {
		name = GetString(WWE_DSC2_BOSS4),
	}, [6] = {
		name = GetString(WWE_DSC2_BOSS5),
	}, [7] = {
		name = GetString(WWE_DSC2_BOSS6),
	},
}

function DSC2.Init()

end

function DSC2.Reset()

end

function DSC2.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
