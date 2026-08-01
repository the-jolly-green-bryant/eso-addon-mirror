local WW = WizardsWardrobe
WW.zones["ROM"] = {}
local ROM = WW.zones["ROM"]

ROM.name = GetString(WWD_ROM_NAME)
ROM.tag = "ROM"
ROM.icon = "/esoui/art/icons/achievement_update11_dungeons_005.dds"
ROM.priority = 102
ROM.id = 843
ROM.node = 260
ROM.category = WW.ACTIVITIES.DLC_DUNGEONS

ROM.bosses = {
	[1] = {
		name = GetString(WWD_TRASH),
	},
	[2] = {
		name = GetString(WWD_ROM_MIGHTY_CHUDAN),
	},
	[3] = {
		name = GetString(WWD_ROM_XAL_NUR_THE_SLAVER),
	},
	[4] = {
		name = GetString(WWD_ROM_TREE_MINDER_NA_KESH),
	},
}

function ROM.Init()

end

function ROM.Reset()

end

function ROM.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
