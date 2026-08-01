local MP = Mephisto
MP.zones["UHG"] = {}
local UHG = MP.zones["UHG"]

UHG.name = GetString(MP_UHG_NAME)
UHG.tag = "UHG"
UHG.icon = "/esoui/art/icons/achievement_u25_dun2_bosses.dds"
UHG.priority = 115
UHG.id = 1153
UHG.node = 425

UHG.bosses = {
	[1] = {
		name = GetString(MP_TRASH),
	},
	[2] = {
		name = GetString(MP_UHG_HAKGRYM_THE_HOWLER),
	},
	[3] = {
		name = GetString(MP_UHG_KEEPER_OF_THE_KILN),
	},
	[4] = {
		name = GetString(MP_UHG_ETERNAL_AEGIS),
	},
	[5] = {
		name = GetString(MP_UHG_ONDAGORE_THE_MAD),
	},
	[6] = {
		name = GetString(MP_UHG_KJALNAR_TOMBSKALD),
	},
	[7] = {
		name = GetString(MP_UHG_NABOR_THE_FORGOTTEN),
	},
	[8] = {
		name = GetString(MP_UHG_VORIA_THE_HEARTH_THIEF),
	},
	[9] = {
		name = GetString(MP_UHG_VORIAS_MASTERPIECE),
	},
}

function UHG.Init()

end

function UHG.Reset()

end

function UHG.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(MP_TRASH)
	end

	local pageId = MP.selection.pageId
	local index = UHG.lookupBosses[bossName]
	MP.LoadSetup(UHG, pageId, index, true)
end
