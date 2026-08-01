local WW = WizardsWardrobe
WW.zones["ERE"] = {}
local ERE = WW.zones["ERE"]

ERE.name = GetString(WWE_ERE_NAME)
ERE.tag = "ERE"
ERE.icon = "/esoui/art/icons/achievement_u35_dun1_vet_bosses.dds"
ERE.priority =  124
ERE.id = 1360
ERE.node = 520
ERE.category = WW.ACTIVITIES.DLC_DUNGEONS

ERE.bosses = { [1] = {
		name = GetString(WWE_TRASH),
	}, [2] = {
		name = GetString(WWE_ERE_BOSS1),
	}, [3] = {
		name = GetString(WWE_ERE_BOSS2),
	}, [4] = {
		name = GetString(WWE_ERE_BOSS3),
	},
}

function ERE.Init()

end

function ERE.Reset()

end

function ERE.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
