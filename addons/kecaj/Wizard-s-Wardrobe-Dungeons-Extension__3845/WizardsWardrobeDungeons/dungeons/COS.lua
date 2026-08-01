local WW = WizardsWardrobe
WW.zones["COS"] = {}
local COS = WW.zones["COS"]

COS.name = GetString(WWD_COS_NAME)
COS.tag = "COS"
COS.icon = "/esoui/art/icons/achievement_update11_dungeons_034.dds"
COS.priority = 103
COS.id = 848
COS.node = 261
COS.category = WW.ACTIVITIES.DLC_DUNGEONS

COS.bosses = {
	[1] = {
		name = GetString(WWD_TRASH),
	},
	[2] = {
		name = GetString(WWD_COS_KHEPHIDAEN),
	},
	[3] = {
		name = GetString(WWD_COS_DRANOS_VELEADOR),
	},
	[4] = {
		name = GetString(WWD_COS_VELIDRETH),
	},
}

function COS.Init()

end

function COS.Reset()

end

function COS.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
