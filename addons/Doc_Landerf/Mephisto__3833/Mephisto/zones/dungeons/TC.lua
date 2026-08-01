local MP = Mephisto
MP.zones["TC"] = {}
local TC = MP.zones["TC"]

TC.name = GetString(MP_TC_NAME)
TC.tag = "TC"
TC.icon = "/esoui/art/icons/achievement_u29_dun2_vet_bosses.dds"
TC.priority = 119
TC.id = 1229
TC.node = 454

TC.bosses = {
	[1] = {
		name = GetString(MP_TRASH),
	},
	[2] = {
		name = GetString(MP_TC_OXBLOOD_THE_DEPRAVED),
	},
	[3] = {
		name = GetString(MP_TC_TASKMASTER_VICCIA),
	},
	[4] = {
		name = GetString(MP_TC_MOLTEN_GUARDIAN),
	},
	[5] = {
		name = GetString(MP_TC_DAEDRIC_SHIELD),
	},
	[6] = {
		name = GetString(MP_TC_BARON_ZAULDRUS),
	},
}

function TC.Init()

end

function TC.Reset()

end

function TC.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(MP_TRASH)
	end

	local pageId = MP.selection.pageId
	local index = TC.lookupBosses[bossName]
	MP.LoadSetup(TC, pageId, index, true)
end
