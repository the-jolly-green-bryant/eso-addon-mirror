local WW = WizardsWardrobe
WW.zones["BF"] = {}
local BF = WW.zones["BF"]

BF.name = GetString(WWD_BF_NAME)
BF.tag = "BF"
BF.icon = "/esoui/art/icons/achievement_update15_002.dds"
BF.priority = 105
BF.id = 973
BF.node = 326
BF.category = WW.ACTIVITIES.DLC_DUNGEONS

BF.bosses = {
	[1] = {
		name = GetString(WWD_TRASH),
	},
	[2] = {
		name = GetString(WWD_BF_MATHGAMAIN),
	},
	[3] = {
		name = GetString(WWD_BF_CAILLAOIFE),
	},
	[4] = {
		name = GetString(WWD_BF_STONEHEARTH),
	},
	[5] = {
		name = GetString(WWD_BF_GALCHOBHAR),
	},
	[6] = {
		name = GetString(WWD_BF_GHERIG_BULLBLOOD),
	},
	[7] = {
		name = GetString(WWD_BF_EARTHGORE_AMALGAM),
	},
}

function BF.Init()

end

function BF.Reset()

end

function BF.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
