local WW = WizardsWardrobe
WW.zones["DFK"] = {}
local DFK = WW.zones["DFK"]

DFK.name = GetString(WWE_DFK_NAME)
DFK.tag = "DFK"
DFK.icon = "esoui/art/icons/achievement_025"
DFK.priority = 118
DFK.id = 449
DFK.node = 195
DFK.category = WW.ACTIVITIES.DUNGEONS

DFK.bosses = { [1] = {
		name = GetString(WWE_TRASH),
	}, [2] = {
		name = GetString(WWE_DFK_BOSS1),
	}, [3] = {
		name = GetString(WWE_DFK_BOSS2),
	}, [4] = {
		name = GetString(WWE_DFK_BOSS3),
	}, [5] = {
		name = GetString(WWE_DFK_BOSS4),
	}, [6] = {
		name = GetString(WWE_DFK_BOSS5),
	}, [7] = {
		name = GetString(WWE_DFK_BOSS6),
	},
}

function DFK.Init()

end

function DFK.Reset()

end

function DFK.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
