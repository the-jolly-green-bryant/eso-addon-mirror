local WW = WizardsWardrobe
WW.zones["FL"] = {}
local FL = WW.zones["FL"]

FL.name = GetString(WWE_FL_NAME)
FL.tag = "FL"
FL.icon = "/esoui/art/icons/achievement_fanglairpeak_veteran.dds"
FL.priority = 106
FL.id = 1009
FL.node = 341
FL.category = WW.ACTIVITIES.DLC_DUNGEONS

FL.bosses = {
	[1] = {
		name = GetString(WWE_TRASH),
	},
	[2] = {
		name = GetString(WWE_FL_BOSS1),
	},
	[3] = {
		name = GetString(WWE_FL_BOSS2),
	},
	[4] = {
		name = GetString(WWE_FL_BOSS3),
	},
	[5] = {
		name = GetString(WWE_FL_BOSS4),
	},
	[6] = {
		name = GetString(WWE_FL_BOSS5),
	},
}

function FL.Init()

end

function FL.Reset()

end

function FL.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
