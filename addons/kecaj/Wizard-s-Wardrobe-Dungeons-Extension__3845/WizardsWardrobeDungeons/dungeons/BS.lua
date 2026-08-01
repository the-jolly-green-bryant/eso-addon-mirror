local WW = WizardsWardrobe
WW.zones["BS"] = {}
local BS = WW.zones["BS"]

BS.name = GetString(WWD_BS_NAME)
BS.tag = "BS"
BS.icon = "/esoui/art/icons/achievement_u37_dun1_vet_bosses.dds"
BS.priority =  126
BS.id = 1389
BS.node = 531
BS.category = WW.ACTIVITIES.DLC_DUNGEONS

BS.bosses = {
	[1] = {
		name = GetString(WWD_TRASH),
	},
	[2] = {
		name = GetString(WWD_BS_B1),
	},
	[3] = {
		name = GetString(WWD_BS_B2),
	},
	[4] = {
		name = GetString(WWD_BS_B3),
	}
}

function BS.Init()

end

function BS.Reset()

end

function BS.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
