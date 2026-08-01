local WW = WizardsWardrobe
WW.zones["SCP"] = {}
local SCP = WW.zones["SCP"]

SCP.name = GetString(WWE_SCP_NAME)
SCP.tag = "SCP"
SCP.icon = "/esoui/art/icons/achievement_scalecaller_veteran.dds"
SCP.priority = 107
SCP.id = 1010
SCP.node = 363
SCP.category = WW.ACTIVITIES.DLC_DUNGEONS

SCP.bosses = {
	[1] = {
		name = GetString(WWE_TRASH),
	},
	[2] = {
		name = GetString(WWE_SCP_BOSS1),
	},
	[3] = {
		name = GetString(WWE_SCP_BOSS2),
	},
	[4] = {
		name = GetString(WWE_SCP_BOSS3),
	},
	[5] = {
		name = GetString(WWE_SCP_BOSS4),
	},
	[6] = {
		name = GetString(WWE_SCP_BOSS5),
	},
}

function SCP.Init()

end

function SCP.Reset()

end

function SCP.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
