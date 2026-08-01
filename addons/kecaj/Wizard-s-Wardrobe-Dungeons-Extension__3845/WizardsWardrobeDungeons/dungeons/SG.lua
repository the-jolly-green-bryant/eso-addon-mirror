local WW = WizardsWardrobe
WW.zones["SG"] = {}
local SG = WW.zones["SG"]

SG.name = GetString(WWD_SG_NAME)
SG.tag = "SG"
SG.icon = "/esoui/art/icons/achievement_u27_dun1_vetbosses.dds"
SG.priority = 116
SG.id = 1197
SG.node = 433
SG.category = WW.ACTIVITIES.DLC_DUNGEONS

SG.bosses = {
	[1] = {
		name = GetString(WWD_TRASH),
	},
	[2] = {
		name = GetString(WWD_SG_EXARCH_KRAGLEN),
	},
	[3] = {
		name = GetString(WWD_SG_STONE_BEHEMOTH),
	},
	[4] = {
		name = GetString(WWD_SG_ARKASIS_THE_MAD_ALCHEMIST),
	},
}

function SG.Init()

end

function SG.Reset()

end

function SG.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
