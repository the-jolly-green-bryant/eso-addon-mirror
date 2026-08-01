local WW = WizardsWardrobe
WW.zones["SCP"] = {}
local SCP = WW.zones["SCP"]

SCP.name = GetString(WWD_SCP_NAME)
SCP.tag = "SCP"
SCP.icon = "/esoui/art/icons/achievement_scalecaller_veteran.dds"
SCP.priority = 107
SCP.id = 1010
SCP.node = 363
SCP.category = WW.ACTIVITIES.DLC_DUNGEONS

SCP.bosses = {
	[1] = {
		name = GetString(WWD_TRASH),
	},
	[2] = {
		name = GetString(WWD_SCP_ORZUN_THE_FOUL_SMELLING),
	},
	[3] = {
		name = GetString(WWD_SCP_DOYLEMISH_IRONHEARTH),
	},
	[4] = {
		name = GetString(WWD_SCP_MATRIACH_ALDIS),
	},
	[5] = {
		name = GetString(WWD_SCP_PLAGUE_CONCOCTER_MORTIEU),
	},
	[6] = {
		name = GetString(WWD_SCP_ZAAN_THE_SCALECALLER),
	},
}

function SCP.Init()

end

function SCP.Reset()

end

function SCP.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
