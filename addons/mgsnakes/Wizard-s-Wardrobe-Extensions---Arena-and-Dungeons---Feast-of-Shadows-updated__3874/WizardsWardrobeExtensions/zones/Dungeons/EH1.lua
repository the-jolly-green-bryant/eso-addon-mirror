local WW = WizardsWardrobe
WW.zones["EH1"] = {}
local EH1 = WW.zones["EH1"]

EH1.name = GetString(WWE_EH1_NAME)
EH1.tag = "EH1"
EH1.icon = "esoui/art/icons/achievement_025"
EH1.priority = 109
EH1.id = 126
EH1.node = 191
EH1.category = WW.ACTIVITIES.DUNGEONS

EH1.bosses = { [1] = {
		name = GetString(WWE_TRASH),
	}, [2] = {
		name = GetString(WWE_EH1_BOSS1),
	}, [3] = {
		name = GetString(WWE_EH1_BOSS2),
	}, [4] = {
		name = GetString(WWE_EH1_BOSS3),
	}, [5] = {
		name = GetString(WWE_EH1_BOSS4),
	}, [6] = {
		name = GetString(WWE_EH1_BOSS5),
	}, [7] = {
		name = GetString(WWE_EH1_BOSS6),
	},
}

function EH1.Init()

end

function EH1.Reset()

end

function EH1.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
