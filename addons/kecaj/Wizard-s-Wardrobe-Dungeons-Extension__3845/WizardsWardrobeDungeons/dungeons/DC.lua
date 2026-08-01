local WW = WizardsWardrobe
WW.zones["DC"] = {}
local DC = WW.zones["DC"]

DC.name = GetString(WWD_DC_NAME)
DC.tag = "DC"
DC.icon = "/esoui/art/icons/achievement_u31_dun2_vet_bosses.dds"
DC.priority = 121
DC.id = 1268
DC.node = 469
DC.category = WW.ACTIVITIES.DLC_DUNGEONS

DC.bosses = {
	[1] = {
		name = GetString(WWD_TRASH),
	},
	[2] = {
		name = GetString(WWD_DC_SCORION_BROODLORD),
	},
	[3] = {
		name = GetString(WWD_DC_CYRONIN_ARTELLIAN),
	},
	[4] = {
		name = GetString(WWD_DC_MAGMA_INCARNATE),
	},
}

function DC.Init()

end

function DC.Reset()

end

function DC.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
