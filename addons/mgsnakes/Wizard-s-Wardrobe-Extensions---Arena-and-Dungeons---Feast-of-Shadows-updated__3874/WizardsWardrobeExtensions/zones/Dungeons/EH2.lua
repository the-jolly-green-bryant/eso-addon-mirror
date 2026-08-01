local WW = WizardsWardrobe
WW.zones["EH2"] = {}
local EH2 = WW.zones["EH2"]

EH2.name = GetString(WWE_EH2_NAME)
EH2.tag = "EH2"
EH2.icon = "esoui/art/icons/achievement_025"
EH2.priority = 110
EH2.id = 931
EH2.node = 265
EH2.category = WW.ACTIVITIES.DUNGEONS

EH2.bosses = { [1] = {
		name = GetString(WWE_TRASH),
	}, [2] = {
		name = GetString(WWE_EH2_BOSS1),
	}, [3] = {
		name = GetString(WWE_EH2_BOSS2),
	}, [4] = {
		name = GetString(WWE_EH2_BOSS3),
	}, [5] = {
		name = GetString(WWE_EH2_BOSS4),
	}, [6] = {
		name = GetString(WWE_EH2_BOSS5),
	}, [7] = {
		name = GetString(WWE_EH2_BOSS6),
	},
}

function EH2.Init()

end

function EH2.Reset()

end

function EH2.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
