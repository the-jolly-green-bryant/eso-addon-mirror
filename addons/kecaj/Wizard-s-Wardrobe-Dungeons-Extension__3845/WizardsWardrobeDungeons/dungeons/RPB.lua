local WW = WizardsWardrobe
WW.zones["RPB"] = {}
local RPB = WW.zones["RPB"]

RPB.name = GetString(WWD_RPB_NAME)
RPB.tag = "RPB"
RPB.icon = "/esoui/art/icons/achievement_u31_dun1_vet_bosses.dds"
RPB.priority = 120
RPB.id = 1267
RPB.node = 470
RPB.category = WW.ACTIVITIES.DLC_DUNGEONS

RPB.bosses = {
	[1] = {
		name = GetString(WWD_TRASH),
	},
	[2] = {
		name = GetString(WWD_RPB_ROGERAIN_THE_SLY),
	},
	[3] = {
		name = GetString(WWD_RPB_ELIAM_MERICK),
	},
	[4] = {
		name = GetString(WWD_RPB_PRIOR_THIERRIC_SARAZEN),
	},
}

function RPB.Init()

end

function RPB.Reset()

end

function RPB.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
