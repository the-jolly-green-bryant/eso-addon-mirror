local WW = WizardsWardrobe
WW.zones["UHG"] = {}
local UHG = WW.zones["UHG"]

UHG.name = GetString(WWD_UHG_NAME)
UHG.tag = "UHG"
UHG.icon = "/esoui/art/icons/achievement_u25_dun2_bosses.dds"
UHG.priority = 115
UHG.id = 1153
UHG.node = 425
UHG.category = WW.ACTIVITIES.DLC_DUNGEONS

UHG.bosses = {
	[1] = {
		name = GetString(WWD_TRASH),
	},
	[2] = {
		name = GetString(WWD_UHG_HAKGRYM_THE_HOWLER),
	},
	[3] = {
		name = GetString(WWD_UHG_KEEPER_OF_THE_KILN),
	},
	[4] = {
		name = GetString(WWD_UHG_ETERNAL_AEGIS),
	},
	[5] = {
		name = GetString(WWD_UHG_ONDAGORE_THE_MAD),
	},
	[6] = {
		name = GetString(WWD_UHG_KJALNAR_TOMBSKALD),
	},
	[7] = {
		name = GetString(WWD_UHG_NABOR_THE_FORGOTTEN),
	},
	[8] = {
		name = GetString(WWD_UHG_VORIA_THE_HEARTH_THIEF),
	},
	[9] = {
		name = GetString(WWD_UHG_VORIAS_MASTERPIECE),
	},
}

function UHG.Init()

end

function UHG.Reset()

end

function UHG.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
