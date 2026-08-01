local WW = WizardsWardrobe
WW.zones["OP"] = {}
local OP = WW.zones["OP"]

OP.name = GetString(WWD_OP_NAME)
OP.tag = "OP"
OP.icon = "/esoui/art/icons/achievement_u41_dun1_vet_bosses.dds"
OP.priority =  129
OP.id = 1470
OP.node = 556
OP.category = WW.ACTIVITIES.DLC_DUNGEONS

OP.bosses = {
	[1] = {
		name = GetString(WWD_TRASH),
	},
	[2] = {
		name = GetString(WWD_OP_B1),
	},
	[3] = {
		name = GetString(WWD_OP_B2),
	},
	[4] = {
		name = GetString(WWD_OP_B3),
	},
}

function OP.Init()

end

function OP.Reset()

end

function OP.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
