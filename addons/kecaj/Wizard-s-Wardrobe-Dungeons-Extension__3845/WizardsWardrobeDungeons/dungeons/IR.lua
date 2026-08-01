local WW = WizardsWardrobe
WW.zones["IR"] = {}
local IR = WW.zones["IR"]

IR.name = GetString(WWD_IR_NAME)
IR.tag = "IR"
IR.icon = "/esoui/art/icons/achievement_u25_dun1_vet_bosses.dds"
IR.priority = 114
IR.id = 1152
IR.node = 424
IR.category = WW.ACTIVITIES.DLC_DUNGEONS

IR.bosses = {
	[1] = {
		name = GetString(WWD_TRASH),
	},
	[2] = {
		name = GetString(WWD_IR_KJARG_THE_TUSKSCRAPER),
	},
	[3] = {
		name = GetString(WWD_IR_SISTER_SKELGA),
	},
	[4] = {
		name = GetString(WWD_IR_VEAROGH_THE_SHAMBLER),
	},
	[5] = {
		name = GetString(WWD_IR_STORMBOND_REVENANT),
	},
	[6] = {
		name = GetString(WWD_IR_ICEREACH_COVEN),
	},
}

function IR.Init()

end

function IR.Reset()

end

function IR.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
