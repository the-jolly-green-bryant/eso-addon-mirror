local WW = WizardsWardrobe
WW.zones["VF"] = {}
local VF = WW.zones["VF"]

VF.name = GetString(WWE_VF_NAME)
VF.tag = "VF"
VF.icon = "esoui/art/icons/achievement_025"
VF.priority = 120
VF.id = 22
VF.node = 196
VF.category = WW.ACTIVITIES.DUNGEONS

VF.bosses = { [1] = {
		name = GetString(WWE_TRASH),
	}, [2] = {
		name = GetString(WWE_VF_BOSS1),
	}, [3] = {
		name = GetString(WWE_VF_BOSS2),
	}, [4] = {
		name = GetString(WWE_VF_BOSS3),
	}, [5] = {
		name = GetString(WWE_VF_BOSS4),
	}, [6] = {
		name = GetString(WWE_VF_BOSS5),
	}, [7] = {
		name = GetString(WWE_VF_BOSS6),
	},
}

function VF.Init()

end

function VF.Reset()

end

function VF.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
