local WW = WizardsWardrobe
WW.zones["NC"] = {}
local NC = WW.zones["NC"]

NC.name = GetString(WWE_NC_NAME)
NC.tag = "NC"
NC.icon = "/esoui/art/icons/achievement_u47_dun1_vet_bosses.dds"
NC.priority =  133
NC.id = 1551
NC.node = 606
NC.category = WW.ACTIVITIES.DLC_DUNGEONS

NC.bosses = {
	[1] = {
		name = GetString(WWE_TRASH),
	},
	[2] = {
		name = GetString(WWE_NC_BOSS1),
	},
	[3] = {
		name = GetString(WWE_NC_BOSS2),
	},
	[4] = {
		name = GetString(WWE_NC_BOSS3),
	},
}

function NC.Init()

end

function NC.Reset()

end

function NC.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
