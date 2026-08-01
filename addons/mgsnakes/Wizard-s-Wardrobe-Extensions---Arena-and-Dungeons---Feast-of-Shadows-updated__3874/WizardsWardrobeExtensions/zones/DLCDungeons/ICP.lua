local WW = WizardsWardrobe
WW.zones["ICP"] = {}
local ICP = WW.zones["ICP"]

ICP.name = GetString(WWE_ICP_NAME)
ICP.tag = "ICP"
ICP.icon = "/esoui/art/icons/achievement_ic_025_heroic.dds"
ICP.priority = 101
ICP.id = 678
ICP.node = 236
ICP.category = WW.ACTIVITIES.DLC_DUNGEONS

ICP.bosses = {
	[1] = {
		name = GetString(WWE_TRASH),
	},
	[2] = {
		name = GetString(WWE_ICP_BOSS1),
	},
	[3] = {
		name = GetString(WWE_ICP_BOSS2),
	},
	[4] = {
		name = GetString(WWE_ICP_BOSS3),
	},
}

function ICP.Init()

end

function ICP.Reset()

end

function ICP.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
