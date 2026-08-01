local WW = WizardsWardrobe
WW.zones["BF"] = {}
local BF = WW.zones["BF"]

BF.name = GetString(WWE_BF_NAME)
BF.tag = "BF"
BF.icon = "/esoui/art/icons/achievement_update15_002.dds"
BF.priority = 105
BF.id = 973
BF.node = 326
BF.category = WW.ACTIVITIES.DLC_DUNGEONS

BF.bosses = {
	[1] = {
		name = GetString(WWE_TRASH),
	},
	[2] = {
		name = GetString(WWE_BF_BOSS1),
	},
	[3] = {
		name = GetString(WWE_BF_BOSS2),
	},
	[4] = {
		name = GetString(WWE_BF_BOSS3),
	},
	[5] = {
		name = GetString(WWE_BF_BOSS4),
	},
	[6] = {
		name = GetString(WWE_BF_BOSS5),
	},
	[7] = {
		name = GetString(WWE_BF_BOSS6),
	},

}

function BF.Init()

end

function BF.Reset()

end

function BF.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end

