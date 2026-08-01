local WW = WizardsWardrobe
WW.zones["UHG"] = {}
local UHG = WW.zones["UHG"]

UHG.name = GetString(WWE_UHG_NAME)
UHG.tag = "UHG"
UHG.icon = "/esoui/art/icons/achievement_u25_dun2_bosses.dds"
UHG.priority = 115
UHG.id = 1153
UHG.node = 425
UHG.category = WW.ACTIVITIES.DLC_DUNGEONS

UHG.bosses = {
	[1] = {
		name = GetString(WWE_TRASH),
	},
	[2] = {
		name = GetString(WWE_UHG_BOSS1),
	},
	[3] = {
		name = GetString(WWE_UHG_BOSS2),
	},
	[4] = {
		name = GetString(WWE_UHG_BOSS3),
	},
	[5] = {
		name = GetString(WWE_UHG_BOSS4),
	},
	[6] = {
		name = GetString(WWE_UHG_BOSS5),
	},
}

function UHG.Init()

end

function UHG.Reset()

end

function UHG.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
