local MP = Mephisto
MP.zones["BS"] = {}
local BS = MP.zones["BS"]

BS.name = GetString(MP_BS_NAME)
BS.tag = "BS"
BS.icon = "/esoui/art/icons/achievement_u37_dun1_vet_bosses.dds"
BS.priority =  126
BS.id = 1389
BS.node = 531

BS.bosses = {
	[1] = {
		name = GetString(MP_TRASH),
	},
	[2] = {
		name = GetString(MP_BS_B1),
	},
	[3] = {
		name = GetString(MP_BS_B2),
	},
	[4] = {
		name = GetString(MP_BS_B3),
	},
	[5] = {
		name = GetString(MP_BS_SCB),
	},
}

function BS.Init()

end

function BS.Reset()

end

function BS.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(MP_TRASH)
	end

	local pageId = MP.selection.pageId
	local index = BS.lookupBosses[bossName]
	MP.LoadSetup(BS, pageId, index, true)
end
