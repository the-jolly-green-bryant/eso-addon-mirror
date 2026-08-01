local WW = WizardsWardrobe
WW.zones["WRS1"] = {}
local WRS1 = WW.zones["WRS1"]

WRS1.name = GetString(WWE_WRS1_NAME)
WRS1.tag = "WRS1"
WRS1.icon = "esoui/art/icons/achievement_025"
WRS1.priority = 111
WRS1.id = 146
WRS1.node = 189
WRS1.category = WW.ACTIVITIES.DUNGEONS

WRS1.bosses = { [1] = {
		name = GetString(WWE_TRASH),
	}, [2] = {
		name = GetString(WWE_WRS1_BOSS1),
	}, [3] = {
		name = GetString(WWE_WRS1_BOSS2),
	}, [4] = {
		name = GetString(WWE_WRS1_BOSS3),
	}, [5] = {
		name = GetString(WWE_WRS1_BOSS4),
	}, [6] = {
		name = GetString(WWE_WRS1_BOSS5),
	}, [7] = {
		name = GetString(WWE_WRS1_BOSS6),
	},
}

function WRS1.Init()

end

function WRS1.Reset()

end

function WRS1.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
