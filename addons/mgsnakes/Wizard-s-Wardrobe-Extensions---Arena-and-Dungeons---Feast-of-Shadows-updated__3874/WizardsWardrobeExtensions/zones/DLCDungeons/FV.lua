local WW = WizardsWardrobe
WW.zones["FV"] = {}
local FV = WW.zones["FV"]

FV.name = GetString(WWE_FV_NAME)
FV.tag = "FV"
FV.icon = "/esoui/art/icons/achievement_frostvault_vet_bosses.dds"
FV.priority = 110
FV.id = 1080
FV.node = 389
FV.category = WW.ACTIVITIES.DLC_DUNGEONS

FV.bosses = {
	[1] = {
		name = GetString(WWE_TRASH),
	},
	[2] = {
		name = GetString(WWE_FV_BOSS1),
	},
	[3] = {
		name = GetString(WWE_FV_BOSS2),
	},
	[4] = {
		name = GetString(WWE_FV_BOSS3),
	},
	[5] = {
		name = GetString(WWE_FV_BOSS4),
	},
	[6] = {
		name = GetString(WWE_FV_BOSS5),
	},
}

function FV.Init()

end

function FV.Reset()

end

function FV.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
