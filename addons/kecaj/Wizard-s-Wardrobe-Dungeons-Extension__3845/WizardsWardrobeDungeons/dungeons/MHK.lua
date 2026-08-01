local WW = WizardsWardrobe
WW.zones["MHK"] = {}
local MHK = WW.zones["MHK"]

MHK.name = GetString(WWD_MHK_NAME)
MHK.tag = "MHK"
MHK.icon = "/esoui/art/icons/vmh_vet_bosses.dds"
MHK.priority = 108
MHK.id = 1052
MHK.node = 371
MHK.category = WW.ACTIVITIES.DLC_DUNGEONS

MHK.bosses = {
	[1] = {
		name = GetString(WWD_TRASH),
	},
	[2] = {
		name = GetString(WWD_MHK_JAILER_MELITUS),
	},
	[3] = {
		name = GetString(WWD_MHK_HEDGE_MAZE_GUARDIAN),
	},
	[4] = {
		name = GetString(WWD_MHK_MYLENNE_MOON_CALLER),
	},
	[5] = {
		name = GetString(WWD_MHK_ARCHIVIST_ERNADE),
	},
	[6] = {
		name = GetString(WWD_MHK_VYKOSA_THE_ASCENDANT),
	},
}

function MHK.Init()

end

function MHK.Reset()

end

function MHK.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
