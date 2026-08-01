local WW = WizardsWardrobe
WW.zones["SH"] = {}
local SH = WW.zones["SH"]

SH.name = GetString(WWD_SH_NAME)
SH.tag = "SH"
SH.icon = "/esoui/art/icons/u37_dun2_vet_bosses.dds"
SH.priority =  127
SH.id = 1390
SH.node = 532
SH.category = WW.ACTIVITIES.DLC_DUNGEONS

SH.bosses = {
	[1] = {
		name = GetString(WWD_TRASH),
	},
	[2] = {
		name = GetString(WWD_SH_B1),
	},
	[3] = {
		name = GetString(WWD_SH_B2),
	},
	[4] = {
		name = GetString(WWD_SH_B3),
	},
}

function SH.Init()

end

function SH.Reset()

end

function SH.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
