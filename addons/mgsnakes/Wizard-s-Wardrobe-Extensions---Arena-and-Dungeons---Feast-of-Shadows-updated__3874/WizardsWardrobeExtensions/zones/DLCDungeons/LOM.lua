local WW = WizardsWardrobe
WW.zones["LOM"] = {}
local LOM = WW.zones["LOM"]

LOM.name = GetString(WWE_LOM_NAME)
LOM.tag = "LOM"
LOM.icon = "/esoui/art/icons/achievement_u23_dun2_flavorboss5b.dds"
LOM.priority = 112
LOM.id = 1123
LOM.node = 398
LOM.category = WW.ACTIVITIES.DLC_DUNGEONS

LOM.bosses = {
	[1] = {
		name = GetString(WWE_TRASH),
	},
	[2] = {
		name = GetString(WWE_LOM_BOSS1),
	},
	[3] = {
		name = GetString(WWE_LOM_BOSS2),
	},
	[4] = {
		name = GetString(WWE_LOM_BOSS3),
	},
	[5] = {
		name = GetString(WWE_LOM_BOSS4),
	},
	[6] = {
		name = GetString(WWE_LOM_BOSS5),
	},
}

function LOM.Init()

end

function LOM.Reset()

end


function LOM.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end

