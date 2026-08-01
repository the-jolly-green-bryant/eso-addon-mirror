local WW = WizardsWardrobe
WW.zones["CT"] = {}
local CT = WW.zones["CT"]

CT.name = GetString(WWE_CT_NAME)
CT.tag = "CT"
CT.icon = "/esoui/art/icons/achievement_u27_dun2_vetbosses.dds"
CT.priority = 117
CT.id = 1201
CT.node = 436
CT.category = WW.ACTIVITIES.DLC_DUNGEONS

CT.bosses = {
	[1] = {
		name = GetString(WWE_TRASH),
	},
	[2] = {
		name = GetString(WWE_CT_BOSS1),
	},
	[3] = {
		name = GetString(WWE_CT_BOSS2),
	},
	[4] = {
		name = GetString(WWE_CT_BOSS3),
	},
	[5] = {
		name = GetString(WWE_CT_BOSS4),
	},
	[6] = {
		name = GetString(WWE_CT_BOSS5),
	},
}

function CT.Init()

end

function CT.Reset()

end

function CT.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
