local WW = WizardsWardrobe
WW.zones["TI"] = {}
local TI = WW.zones["TI"]

TI.name = GetString(WWE_TI_NAME)
TI.tag = "TI"
TI.icon = "esoui/art/icons/achievement_025"
TI.priority = 119
TI.id = 131
TI.node = 188
TI.category = WW.ACTIVITIES.DUNGEONS

TI.bosses = { [1] = {
		name = GetString(WWE_TRASH),
	}, [2] = {
		name = GetString(WWE_TI_BOSS1),
	}, [3] = {
		name = GetString(WWE_TI_BOSS2),
	}, [4] = {
		name = GetString(WWE_TI_BOSS3),
	}, [5] = {
		name = GetString(WWE_TI_BOSS4),
	}, [6] = {
		name = GetString(WWE_TI_BOSS5),
	}, [7] = {
		name = GetString(WWE_TI_BOSS6),
	},
}

function TI.Init()

end

function TI.Reset()

end

function TI.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
