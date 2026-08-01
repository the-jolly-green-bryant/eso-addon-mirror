local WW = WizardsWardrobe
WW.zones["WRS2"] = {}
local WRS2 = WW.zones["WRS2"]

WRS2.name = GetString(WWE_WRS2_NAME)
WRS2.tag = "WRS2"
WRS2.icon = "esoui/art/icons/achievement_025"
WRS2.priority = 112
WRS2.id = 933
WRS2.node = 263
WRS2.category = WW.ACTIVITIES.DUNGEONS

WRS2.bosses = { [1] = {
		name = GetString(WWE_TRASH),
	}, [2] = {
		name = GetString(WWE_WRS2_BOSS1),
	}, [3] = {
		name = GetString(WWE_WRS2_BOSS2),
	}, [4] = {
		name = GetString(WWE_WRS2_BOSS3),
	}, [5] = {
		name = GetString(WWE_WRS2_BOSS4),
	}, [6] = {
		name = GetString(WWE_WRS2_BOSS5),
	}, [7] = {
		name = GetString(WWE_WRS2_BOSS6),
	},
}

function WRS2.Init()

end

function WRS2.Reset()

end

function WRS2.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
