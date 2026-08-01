local WW = WizardsWardrobe
WW.zones["MGF"] = {}
local MGF = WW.zones["MGF"]

MGF.name = GetString(WWE_MGF_NAME)
MGF.tag = "MGF"
MGF.icon = "/esoui/art/icons/achievement_u23_dun1_meta.dds"
MGF.priority = 113
MGF.id = 1122
MGF.node = 391
MGF.category = WW.ACTIVITIES.DLC_DUNGEONS

MGF.bosses = {
	[1] = {
		name = GetString(WWE_TRASH),
	},
	[2] = {
		name = GetString(WWE_MGF_BOSS1),
	},
	[3] = {
		name = GetString(WWE_MGF_BOSS2),
	},
	[4] = {
		name = GetString(WWE_MGF_BOSS3),
	},
	[5] = {
		name = GetString(WWE_MGF_BOSS4),
	},
	[6] = {
		name = GetString(WWE_MGF_BOSS5),
	},
}

function MGF.Init()

end

function MGF.Reset()

end

function MGF.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
