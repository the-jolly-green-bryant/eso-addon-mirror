local WW = WizardsWardrobe
WW.zones["MGF"] = {}
local MGF = WW.zones["MGF"]

MGF.name = GetString(WWD_MGF_NAME)
MGF.tag = "MGF"
MGF.icon = "/esoui/art/icons/achievement_u23_dun1_meta.dds"
MGF.priority = 113
MGF.id = 1122
MGF.node = 391
MGF.category = WW.ACTIVITIES.DLC_DUNGEONS

MGF.bosses = {
	[1] = {
		name = GetString(WWD_TRASH),
	},
	[2] = {
		name = GetString(WWD_MGF_RISEN_RUINS),
	},
	[3] = {
		name = GetString(WWD_MGF_DRO_ZAKAR),
	},
	[4] = {
		name = GetString(WWD_MGF_KUJO_KETHBA),
	},
	[5] = {
		name = GetString(WWD_MGF_NISAAZDA),
	},
	[6] = {
		name = GetString(WWD_MGF_GRUNDWULF),
	},
}

function MGF.Init()

end

function MGF.Reset()

end

function MGF.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
