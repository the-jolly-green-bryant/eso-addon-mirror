local MP = Mephisto
MP.zones["MOS"] = {}
local MOS = MP.zones["MOS"]

MOS.name = GetString(MP_MOS_NAME)
MOS.tag = "MOS"
MOS.icon = "/esoui/art/icons/vmos_vet_bosses.dds"
MOS.priority = 109
MOS.id = 1055
MOS.node = 370

MOS.bosses = {
	[1] = {
		name = GetString(MP_TRASH),
	},
	[2] = {
		name = GetString(MP_MOS_WYRESS_RANGIFER),
	},
	[3] = {
		name = GetString(MP_MOS_AGHAEDH_OF_THE_SOLSTICE),
	},
	[4] = {
		name = GetString(MP_MOS_DAGRUND_THE_BULKY),
	},
	[5] = {
		name = GetString(MP_MOS_TARCYR),
	},
	[6] = {
		name = GetString(MP_MOS_BALORGH),
	},
}

function MOS.Init()

end

function MOS.Reset()

end

function MOS.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(MP_TRASH)
	end

	local pageId = MP.selection.pageId
	local index = MOS.lookupBosses[bossName]
	MP.LoadSetup(MOS, pageId, index, true)
end
