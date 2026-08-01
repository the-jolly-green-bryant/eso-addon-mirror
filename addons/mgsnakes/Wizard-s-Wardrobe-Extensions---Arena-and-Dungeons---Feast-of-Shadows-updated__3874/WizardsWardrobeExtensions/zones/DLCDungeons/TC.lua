local WW = WizardsWardrobe
WW.zones["TC"] = {}
local TC = WW.zones["TC"]

TC.name = GetString(WWE_TC_NAME)
TC.tag = "TC"
TC.icon = "/esoui/art/icons/achievement_u29_dun2_vet_bosses.dds"
TC.priority = 119
TC.id = 1229
TC.node = 454
TC.category = WW.ACTIVITIES.DLC_DUNGEONS

TC.bosses = {
	[1] = {
		name = GetString(WWE_TRASH),
	},
	[2] = {
		name = GetString(WWE_TC_BOSS1),
	},
	[3] = {
		name = GetString(WWE_TC_BOSS2),
	},
	[4] = {
		name = GetString(WWE_TC_BOSS3),
	},
	[5] = {
		name = GetString(WWE_TC_BOSS4),
	},
	[6] = {
		name = GetString(WWE_TC_BOSS5),
	},
}

function TC.Init()

end

function TC.Reset()

end

function TC.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
