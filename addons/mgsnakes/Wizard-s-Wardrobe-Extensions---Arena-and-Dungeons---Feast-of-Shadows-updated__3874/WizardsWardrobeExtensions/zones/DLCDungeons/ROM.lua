local WW = WizardsWardrobe
WW.zones["ROM"] = {}
local ROM = WW.zones["ROM"]

ROM.name = GetString(WWE_ROM_NAME)
ROM.tag = "ROM"
ROM.icon = "/esoui/art/icons/achievement_update11_dungeons_005.dds"
ROM.priority = 102
ROM.id = 843
ROM.node = 260
ROM.category = WW.ACTIVITIES.DLC_DUNGEONS

ROM.bosses = {
	[1] = {
		name = GetString(WWE_TRASH),
	},
	[2] = {
		name = GetString(WWE_ROM_BOSS1),
	},
	[3] = {
		name = GetString(WWE_ROM_BOSS2),
	},
	[4] = {
		name = GetString(WWE_ROM_BOSS3),
	},
}

function ROM.Init()

end

function ROM.Reset()

end

function ROM.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
