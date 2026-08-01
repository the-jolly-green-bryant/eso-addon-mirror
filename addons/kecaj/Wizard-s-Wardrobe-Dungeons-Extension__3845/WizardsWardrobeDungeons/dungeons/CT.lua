local WW = WizardsWardrobe
WW.zones["CT"] = {}
local CT = WW.zones["CT"]

CT.name = GetString(WWD_CT_NAME)
CT.tag = "CT"
CT.icon = "/esoui/art/icons/achievement_u27_dun2_vetbosses.dds"
CT.priority = 117
CT.id = 1201
CT.node = 436
CT.category = WW.ACTIVITIES.DLC_DUNGEONS

CT.bosses = {
	[1] = {
		name = GetString(WWD_TRASH),
	},
	[2] = {
		name = GetString(WWD_CT_DREAD_TINDULRA),
	},
	[3] = {
		name = GetString(WWD_CT_BLOOD_TWILIGHT),
	},
	[4] = {
		name = GetString(WWD_CT_VADUROTH),
	},
	[5] = {
		name = GetString(WWD_CT_TALFYG),
	},
	[6] = {
		name = GetString(WWD_CT_LADY_THORN),
	},
}

function CT.Init()

end

function CT.Reset()

end

function CT.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
