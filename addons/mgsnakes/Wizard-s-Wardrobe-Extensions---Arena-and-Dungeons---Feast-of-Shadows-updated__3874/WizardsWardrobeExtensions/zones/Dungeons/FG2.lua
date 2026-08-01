local WW = WizardsWardrobe
WW.zones["FG2"] = {}
local FG2 = WW.zones["FG2"]

FG2.name = GetString(WWE_FG2_NAME)
FG2.tag = "FG2"
FG2.icon = "esoui/art/icons/achievement_025"
FG2.priority = 102
FG2.id = 934
FG2.node = 266
FG2.category = WW.ACTIVITIES.DUNGEONS

FG2.bosses = { [1] = {
		name = GetString(WWE_TRASH),
	}, [2] = {
		name = GetString(WWE_FG2_BOSS1),
	}, [3] = {
		name = GetString(WWE_FG2_BOSS2),
	}, [4] = {
		name = GetString(WWE_FG2_BOSS3),
	}, [5] = {
		name = GetString(WWE_FG2_BOSS4),
	}, [6] = {
		name = GetString(WWE_FG2_BOSS5),
	}, [7] = {
		name = GetString(WWE_FG2_BOSS5),
	},
}

function FG2.Init()

end

function FG2.Reset()

end

function FG2.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
