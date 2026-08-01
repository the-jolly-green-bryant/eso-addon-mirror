local MP = Mephisto
MP.zones["DC"] = {}
local DC = MP.zones["DC"]

DC.name = GetString(MP_DC_NAME)
DC.tag = "DC"
DC.icon = "/esoui/art/icons/achievement_u31_dun2_vet_bosses.dds"
DC.priority = 121
DC.id = 1268
DC.node = 469

DC.bosses = {
	[1] = {
		name = GetString(MP_TRASH),
	},
	[2] = {
		name = GetString(MP_DC_SCORION_BROODLORD),
	},
	[3] = {
		name = GetString(MP_DC_CYRONIN_ARTELLIAN),
	},
	[4] = {
		name = GetString(MP_DC_MAGMA_INCARNATE),
	},
	[5] = {
		name = GetString(MP_DC_PURGATOR),
	},
	[6] = {
		name = GetString(MP_DC_UNDERTAKER),
	},
	[7] = {
		name = GetString(MP_DC_GRIM_WARDEN),
	},
}

function DC.Init()

end

function DC.Reset()

end

function DC.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(MP_TRASH)
	end

	local pageId = MP.selection.pageId
	local index = DC.lookupBosses[bossName]
	MP.LoadSetup(DC, pageId, index, true)
end
