local WW = WizardsWardrobe
WW.zones["BS"] = {}
local BS = WW.zones["BS"]

BS.name = GetString(WWE_BS_NAME)
BS.tag = "BS"
BS.icon = "/esoui/art/icons/achievement_u37_dun1_vet_bosses.dds"
BS.priority =  126
BS.id = 1389
BS.node = 531
BS.category = WW.ACTIVITIES.DLC_DUNGEONS

BS.bosses = {
	[1] = {
		name = GetString(WWE_TRASH),
	},
	[2] = {
		name = GetString(WWE_BS_BOSS1),
	},
	[3] = {
		name = GetString(WWE_BS_BOSS2),
	},
	[4] = {
		name = GetString(WWE_BS_BOSS3),
	}
	
}

function BS.Init()

end

function BS.Reset()

end

function BS.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
