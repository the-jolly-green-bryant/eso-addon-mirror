local WW = WizardsWardrobe
WW.zones["MHK"] = {}
local MHK = WW.zones["MHK"]

MHK.name = GetString(WWE_MHK_NAME)
MHK.tag = "MHK"
MHK.icon = "/esoui/art/icons/vmh_vet_bosses.dds"
MHK.priority = 108
MHK.id = 1052
MHK.node = 371
MHK.category = WW.ACTIVITIES.DLC_DUNGEONS

MHK.bosses = {
	[1] = {
		name = GetString(WWE_TRASH),
	},
	[2] = {
		name = GetString(WWE_MHK_BOSS1),
	},
	[3] = {
		name = GetString(WWE_MHK_BOSS2),
	},
	[4] = {
		name = GetString(WWE_MHK_BOSS3),
	},
	[5] = {
		name = GetString(WWE_MHK_BOSS4),
	},
	[6] = {
		name = GetString(WWE_MHK_BOSS5),
	},
}

function MHK.Init()

end

function MHK.Reset()

end

function MHK.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
