local WW = WizardsWardrobe
WW.zones["ICP"] = {}
local ICP = WW.zones["ICP"]

ICP.name = GetString(WWD_ICP_NAME)
ICP.tag = "ICP"
ICP.icon = "/esoui/art/icons/achievement_ic_025_heroic.dds"
ICP.priority = 101
ICP.id = 678
ICP.node = 236
ICP.category = WW.ACTIVITIES.DLC_DUNGEONS

ICP.bosses = {
	[1] = {
		name = GetString(WWD_TRASH),
	},
	[2] = {
		name = GetString(WWD_ICP_IBOMEZ_THE_FLESH_SCULPTOR),
	},
	[3] = {
		name = GetString(WWD_ICP_FLESH_ABOMINATION),
	},
	[4] = {
		name = GetString(WWD_ICP_LORD_WARDEN_DUSK),
	},
}

function ICP.Init()

end

function ICP.Reset()

end

function ICP.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
