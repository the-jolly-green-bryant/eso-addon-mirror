local WW = WizardsWardrobe
WW.zones["VOM"] = {}
local VOM = WW.zones["VOM"]

VOM.name = GetString(WWE_VOM_NAME)
VOM.tag = "VOM"
VOM.icon = "esoui/art/icons/achievement_025"
VOM.priority = 124
VOM.id = 11
VOM.node = 184
VOM.category = WW.ACTIVITIES.DUNGEONS

VOM.bosses = { [1] = {
		name = GetString(WWE_TRASH),
	}, [2] = {
		name = GetString(WWE_VOM_BOSS1),
	}, [3] = {
		name = GetString(WWE_VOM_BOSS2),
	}, [4] = {
		name = GetString(WWE_VOM_BOSS3),
	}, [5] = {
		name = GetString(WWE_VOM_BOSS4),
	}, [6] = {
		name = GetString(WWE_VOM_BOSS5),
	}, [7] = {
		name = GetString(WWE_VOM_BOSS6),
	}, [8] = {
		name = GetString(WWE_VOM_BOSS7),
	}, [9] = {
		name = GetString(WWE_VOM_BOSS8),
	},
}

function VOM.Init()

end

function VOM.Reset()

end

function VOM.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
