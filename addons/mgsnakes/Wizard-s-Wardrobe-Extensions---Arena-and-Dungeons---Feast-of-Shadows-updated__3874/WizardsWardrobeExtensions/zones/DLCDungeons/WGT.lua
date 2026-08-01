local WW = WizardsWardrobe
WW.zones["WGT"] = {}
local WGT = WW.zones["WGT"]

WGT.name = GetString(WWE_WGT_NAME)
WGT.tag = "WGT"
WGT.icon = "/esoui/art/icons/achievement_ic_027_heroic.dds"
WGT.priority = 100
WGT.id = 688
WGT.node = 247
WGT.category = WW.ACTIVITIES.DLC_DUNGEONS

WGT.bosses = {
	[1] = {
		name = GetString(WWE_TRASH),
	},
	[2] = {
		name = GetString(WWE_WGT_BOSS1),
	},
	[3] = {
		name = GetString(WWE_WGT_BOSS2),
	},
	[4] = {
		name = GetString(WWE_WGT_BOSS3),
	},
	[5] = {
		name = GetString(WWE_WGT_BOSS4),
	},
}

function WGT.Init()

end

function WGT.Reset()

end

function WGT.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
