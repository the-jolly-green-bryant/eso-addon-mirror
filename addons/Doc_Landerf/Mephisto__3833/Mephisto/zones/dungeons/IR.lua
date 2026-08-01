local MP = Mephisto
MP.zones["IR"] = {}
local IR = MP.zones["IR"]

IR.name = GetString(MP_IR_NAME)
IR.tag = "IR"
IR.icon = "/esoui/art/icons/achievement_u25_dun1_vet_bosses.dds"
IR.priority = 114
IR.id = 1152
IR.node = 424

IR.bosses = {
	[1] = {
		name = GetString(MP_TRASH),
	},
	[2] = {
		name = GetString(MP_IR_KJARG_THE_TUSKSCRAPER),
	},
	[3] = {
		name = GetString(MP_IR_SISTER_SKELGA),
	},
	[4] = {
		name = GetString(MP_IR_VEAROGH_THE_SHAMBLER),
	},
	[5] = {
		name = GetString(MP_IR_STORMBOND_REVENANT),
	},
	[6] = {
		name = GetString(MP_IR_ICEREACH_COVEN),
	},
}

function IR.Init()

end

function IR.Reset()

end

function IR.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(MP_TRASH)
	end

	local pageId = MP.selection.pageId
	local index = IR.lookupBosses[bossName]
	MP.LoadSetup(IR, pageId, index, true)
end
