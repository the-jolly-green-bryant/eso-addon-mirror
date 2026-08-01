local MP = Mephisto
MP.zones["MHK"] = {}
local MHK = MP.zones["MHK"]

MHK.name = GetString(MP_MHK_NAME)
MHK.tag = "MHK"
MHK.icon = "/esoui/art/icons/vmh_vet_bosses.dds"
MHK.priority = 108
MHK.id = 1052
MHK.node = 371

MHK.bosses = {
	[1] = {
		name = GetString(MP_TRASH),
	},
	[2] = {
		name = GetString(MP_MHK_JAILER_MELITUS),
	},
	[3] = {
		name = GetString(MP_MHK_HEDGE_MAZE_GUARDIAN),
	},
	[4] = {
		name = GetString(MP_MHK_MYLENNE_MOON_CALLER),
	},
	[5] = {
		name = GetString(MP_MHK_ARCHIVIST_ERNADE),
	},
	[6] = {
		name = GetString(MP_MHK_VYKOSA_THE_ASCENDANT),
	},
}

function MHK.Init()

end

function MHK.Reset()

end

function MHK.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(MP_TRASH)
	end

	local pageId = MP.selection.pageId
	local index = MHK.lookupBosses[bossName]
	MP.LoadSetup(MHK, pageId, index, true)
end
