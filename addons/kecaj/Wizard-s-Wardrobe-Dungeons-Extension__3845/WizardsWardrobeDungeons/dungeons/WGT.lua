local WW = WizardsWardrobe
WW.zones["WGT"] = {}
local WGT = WW.zones["WGT"]

WGT.name = GetString(WWD_WGT_NAME)
WGT.tag = "WGT"
WGT.icon = "/esoui/art/icons/achievement_ic_027_heroic.dds"
WGT.priority = 100
WGT.id = 688
WGT.node = 247
WGT.category = WW.ACTIVITIES.DLC_DUNGEONS

WGT.bosses = {
	[1] = {
		name = GetString(WWD_TRASH),
	},
	[2] = {
		name = GetString(WWD_WGT_THE_ADJUDICATOR),
	},
	[3] = {
		name = GetString(WWD_WGT_TRIBOSS),
	},
	[4] = {
		name = GetString(WWD_WGT_THE_PLANAR_INHIBITOR),
	},
	[5] = {
		name = GetString(WWD_WGT_MOLAG_KENA),
	},
}

function WGT.Init()

end

function WGT.Reset()

end

function WGT.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
