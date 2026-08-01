local WW = WizardsWardrobe
WW.zones["SH"] = {}
local SH = WW.zones["SH"]

SH.name = GetString(WWE_SH_NAME)
SH.tag = "SH"
SH.icon = "/esoui/art/icons/u37_dun2_vet_bosses.dds"
SH.priority =  127
SH.id = 1390
SH.node = 532
SH.category = WW.ACTIVITIES.DLC_DUNGEONS

SH.bosses = {
	[1] = {
		name = GetString(WWE_TRASH),
	},
	[2] = {
		name = GetString(WWE_SH_BOSS1),
	},
	[3] = {
		name = GetString(WWE_SH_BOSS2),
	},
	[4] = {
		name = GetString(WWE_SH_BOSS3),
	},
}

function SH.Init()

end

function SH.Reset()

end

function SH.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
