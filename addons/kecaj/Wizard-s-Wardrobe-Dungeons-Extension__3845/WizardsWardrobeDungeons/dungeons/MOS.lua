local WW = WizardsWardrobe
WW.zones["MOS"] = {}
local MOS = WW.zones["MOS"]

MOS.name = GetString(WWD_MOS_NAME)
MOS.tag = "MOS"
MOS.icon = "/esoui/art/icons/vmos_vet_bosses.dds"
MOS.priority = 109
MOS.id = 1055
MOS.node = 370
MOS.category = WW.ACTIVITIES.DLC_DUNGEONS

MOS.bosses = {
	[1] = {
		name = GetString(WWD_TRASH),
	},
	[2] = {
		name = GetString(WWD_MOS_WYRESS_RANGIFER),
	},
	[3] = {
		name = GetString(WWD_MOS_AGHAEDH_OF_THE_SOLSTICE),
	},
	[4] = {
		name = GetString(WWD_MOS_DAGRUND_THE_BULKY),
	},
	[5] = {
		name = GetString(WWD_MOS_TARCYR),
	},
	[6] = {
		name = GetString(WWD_MOS_BALORGH),
	},
}

function MOS.Init()

end

function MOS.Reset()

end

function MOS.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
