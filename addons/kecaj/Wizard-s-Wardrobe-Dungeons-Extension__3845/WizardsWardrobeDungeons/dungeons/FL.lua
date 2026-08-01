local WW = WizardsWardrobe
WW.zones["FL"] = {}
local FL = WW.zones["FL"]

FL.name = GetString(WWD_FL_NAME)
FL.tag = "FL"
FL.icon = "/esoui/art/icons/achievement_fanglairpeak_veteran.dds"
FL.priority = 106
FL.id = 1009
FL.node = 341
FL.category = WW.ACTIVITIES.DLC_DUNGEONS

FL.bosses = {
	[1] = {
		name = GetString(WWD_TRASH),
	},
	[2] = {
		name = GetString(WWD_FL_LIZABET_CHARNIS),
	},
	[3] = {
		name = GetString(WWD_FL_CADAVEROUS_BEAR),
	},
	[4] = {
		name = GetString(WWD_FL_CALUURION),
	},
	[5] = {
		name = GetString(WWD_FL_ULFNOR),
	},
	[6] = {
		name = GetString(WWD_FL_THURVOKUN),
	},
}

function FL.Init()

end

function FL.Reset()

end

function FL.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
