local WW = WizardsWardrobe
WW.zones["BGF"] = {}
local BGF = WW.zones["BGF"]

BGF.name = GetString(WWE_BGF_NAME)
BGF.tag = "BGF"
BGF.icon = "/esoui/art/icons/achievement_u47_dun1_vet_bosses.dds"
BGF.priority =  132
BGF.id = 1552
BGF.node = 605
BGF.category = WW.ACTIVITIES.DLC_DUNGEONS

BGF.bosses = {
	[1] = {
		name = GetString(WWE_TRASH),
	},
	[2] = {
		name = GetString(WWE_BGF_BOSS1),
	},
	[3] = {
		name = GetString(WWE_BGF_BOSS2),
	},
	[4] = {
		name = GetString(WWE_BGF_BOSS3),
	},
	[5] = {
		name = GetString(WWE_BGF_BOSS4),
	},
	[6] = {
		name = GetString(WWE_BGF_BOSS5),
	},
	[7] = {
		name = GetString(WWE_BGF_BOSS6),
	},
}

function BGF
.Init()

end

function BGF
.Reset()

end

function BGF
.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
