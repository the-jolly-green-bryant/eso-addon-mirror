local WW = WizardsWardrobe
WW.zones["FH"] = {}
local FH = WW.zones["FH"]

FH.name = GetString(WWE_FH_NAME)
FH.tag = "FH"
FH.icon = "/esoui/art/icons/achievement_update15_008.dds"
FH.priority = 104
FH.id = 974
FH.node = 332
FH.category = WW.ACTIVITIES.DLC_DUNGEONS

FH.bosses = {
	[1] = {
		name = GetString(WWE_TRASH),
	},
	[2] = {
		name = GetString(WWE_FH_BOSS1),
	},
	[3] = {
		name = GetString(WWE_FH_BOSS2),
	},
	[4] = {
		name = GetString(WWE_FH_BOSS3),
	},
	[5] = {
		name = GetString(WWE_FH_BOSS4),
	},
	[6] = {
		name = GetString(WWE_FH_BOSS5),
	},
}

function FH.Init()

end

function FH.Reset()

end

function FH.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
