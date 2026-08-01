local WW = WizardsWardrobe
WW.zones["IR"] = {}
local IR = WW.zones["IR"]

IR.name = GetString(WWE_IR_NAME)
IR.tag = "IR"
IR.icon = "/esoui/art/icons/achievement_u25_dun1_vet_bosses.dds"
IR.priority = 114
IR.id = 1152
IR.node = 424
IR.category = WW.ACTIVITIES.DLC_DUNGEONS

IR.bosses = {
	[1] = {
		name = GetString(WWE_TRASH),
	},
	[2] = {
		name = GetString(WWE_IR_BOSS1),
	},
	[3] = {
		name = GetString(WWE_IR_BOSS2),
	},
	[4] = {
		name = GetString(WWE_IR_BOSS3),
	},
	[5] = {
		name = GetString(WWE_IR_BOSS4),
	},
	[6] = {
		name = GetString(WWE_IR_BOSS5),
	},
}

function IR.Init()

end

function IR.Reset()

end

function IR.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
