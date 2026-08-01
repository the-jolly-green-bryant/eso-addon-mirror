local MP = Mephisto
MP.zones["ROM"] = {}
local ROM = MP.zones["ROM"]

ROM.name = GetString(MP_ROM_NAME)
ROM.tag = "ROM"
ROM.icon = "/esoui/art/icons/achievement_u30_groupboss6.dss"
ROM.priority = 102
ROM.id = 843
ROM.node = 260

ROM.bosses = {
	[1] = {
		name = GetString(MP_TRASH),
	},
	[2] = {
		name = GetString(MP_ROM_MIGHTY_CHUDAN),
	},
	[3] = {
		name = GetString(MP_ROM_XAL_NUR_THE_SLAVER),
	},
	[4] = {
		name = GetString(MP_ROM_TREE_MINDER_NA_KESH),
	},
}

function ROM.Init()

end

function ROM.Reset()

end

function ROM.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(MP_TRASH)
	end

	local pageId = MP.selection.pageId
	local index = ROM.lookupBosses[bossName]
	MP.LoadSetup(ROM, pageId, index, true)
end
