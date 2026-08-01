local WW = WizardsWardrobe
WW.zones["MOS"] = {}
local MOS = WW.zones["MOS"]

MOS.name = GetString(WWE_MOS_NAME)
MOS.tag = "MOS"
MOS.icon = "/esoui/art/icons/vmos_vet_bosses.dds"
MOS.priority = 109
MOS.id = 1055
MOS.node = 370
MOS.category = WW.ACTIVITIES.DLC_DUNGEONS

MOS.bosses = {
	[1] = {
		name = GetString(WWE_TRASH),
	},
	[2] = {
		name = GetString(WWE_MOS_BOSS1),
	},
	[3] = {
		name = GetString(WWE_MOS_BOSS2),
	},
	[4] = {
		name = GetString(WWE_MOS_BOSS3),
	},
	[5] = {
		name = GetString(WWE_MOS_BOSS4),
	},
	[6] = {
		name = GetString(WWE_MOS_BOSS5),
	},
}

function MOS.Init()

end

function MOS.Reset()

end

function MOS.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
