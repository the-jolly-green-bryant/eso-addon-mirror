local MP = Mephisto
MP.zones["RPB"] = {}
local RPB = MP.zones["RPB"]

RPB.name = GetString(MP_RPB_NAME)
RPB.tag = "RPB"
RPB.icon = "/esoui/art/icons/achievement_u31_dun1_vet_bosses.dds"
RPB.priority = 120
RPB.id = 1267
RPB.node = 470

RPB.bosses = {
	[1] = {
		name = GetString(MP_TRASH),
	},
	[2] = {
		name = GetString(MP_RPB_ROGERAIN_THE_SLY),
	},
	[3] = {
		name = GetString(MP_RPB_ELIAM_MERICK),
	},
	[4] = {
		name = GetString(MP_RPB_PRIOR_THIERRIC_SARAZEN),
	},
	[5] = {
		name = GetString(MP_RPB_WRAITH_OF_CROWS),
	},
	[6] = {
		name = GetString(MP_RPB_SPIDER_DEADRA),
	},
	[7] = {
		name = GetString(MP_RPB_GRIEVIOUS_TWILIGHT),
	},
}

function RPB.Init()

end

function RPB.Reset()

end

function RPB.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(MP_TRASH)
	end

	local pageId = MP.selection.pageId
	local index = RPB.lookupBosses[bossName]
	MP.LoadSetup(RPB, pageId, index, true)
end
