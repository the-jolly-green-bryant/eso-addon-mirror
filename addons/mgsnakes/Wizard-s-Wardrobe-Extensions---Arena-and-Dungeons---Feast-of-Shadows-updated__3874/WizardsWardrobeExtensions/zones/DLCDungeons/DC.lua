local WW = WizardsWardrobe
WW.zones["DC"] = {}
local DC = WW.zones["DC"]

DC.name = GetString(WWE_DC_NAME)
DC.tag = "DC"
DC.icon = "/esoui/art/icons/achievement_u31_dun2_vet_bosses.dds"
DC.priority = 121
DC.id = 1268
DC.node = 469
DC.category = WW.ACTIVITIES.DLC_DUNGEONS

DC.bosses = {
	[1] = {
		name = GetString(WWE_TRASH),
	},
	[2] = {
		name = GetString(WWE_DC_BOSS1),
	},
	[3] = {
		name = GetString(WWE_DC_BOSS2),
	},
	[4] = {
		name = GetString(WWE_DC_BOSS3),
	},
}

function DC.Init()

end

function DC.Reset()

end

function DC.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
