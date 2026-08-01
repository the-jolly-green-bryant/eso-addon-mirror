local WW = WizardsWardrobe
WW.zones["TC"] = {}
local TC = WW.zones["TC"]

TC.name = GetString(WWD_TC_NAME)
TC.tag = "TC"
TC.icon = "/esoui/art/icons/achievement_u29_dun2_vet_bosses.dds"
TC.priority = 119
TC.id = 1229
TC.node = 454
TC.category = WW.ACTIVITIES.DLC_DUNGEONS

TC.bosses = {
	[1] = {
		name = GetString(WWD_TRASH),
	},
	[2] = {
		name = GetString(WWD_TC_OXBLOOD_THE_DEPRAVED),
	},
	[3] = {
		name = GetString(WWD_TC_TASKMASTER_VICCIA),
	},
	[4] = {
		name = GetString(WWD_TC_MOLTEN_GUARDIAN),
	},
	[5] = {
		name = GetString(WWD_TC_DAEDRIC_SHIELD),
	},
	[6] = {
		name = GetString(WWD_TC_BARON_ZAULDRUS),
	},
}

function TC.Init()

end

function TC.Reset()

end

function TC.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
