local WW = WizardsWardrobe
WW.zones["LS"] = {}
local LS = WW.zones["LS"]

LS.name = GetString(WWE_LS_NAME)
LS.tag = "LS"
LS.icon = "/esoui/art/icons/achievement_u45_dun2_vet_bosses.dds"
LS.priority =  131
LS.id = 1497
LS.node = 582
LS.category = WW.ACTIVITIES.DLC_DUNGEONS

LS.bosses = {
	[1] = {
		name = GetString(WWE_TRASH),
	},
	[2] = {
		name = GetString(WWE_LS_BOSS1),
	},
	[3] = {
		name = GetString(WWE_LS_BOSS2),
	},
	[4] = {
		name = GetString(WWE_LS_BOSS3),
	},
	[5] = {
		name = GetString(WWE_LS_BOSS4),
	},
	[6] = {
		name = GetString(WWE_LS_BOSS5),
	},
	[7] = {
		name = GetString(WWE_LS_BOSS6),
	},
}

function LS.Init()

end

function LS.Reset()

end

function LS.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
