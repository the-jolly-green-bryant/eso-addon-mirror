local WW = WizardsWardrobe
WW.zones["SW"] = {}
local SW = WW.zones["SW"]

SW.name = GetString(WWE_SW_NAME)
SW.tag = "SW"
SW.icon = "esoui/art/icons/achievement_025"
SW.priority = 123
SW.id = 31
SW.node = 185
SW.category = WW.ACTIVITIES.DUNGEONS

SW.bosses = { [1] = {
		name = GetString(WWE_TRASH),
	}, [2] = {
		name = GetString(WWE_SW_BOSS1),
	}, [3] = {
		name = GetString(WWE_SW_BOSS2),
	}, [4] = {
		name = GetString(WWE_SW_BOSS3),
	}, [5] = {
		name = GetString(WWE_SW_BOSS4),
	}, [6] = {
		name = GetString(WWE_SW_BOSS5),
	}, [7] = {
		name = GetString(WWE_SW_BOSS6),
	},
}

function SW.Init()

end

function SW.Reset()

end

function SW.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
