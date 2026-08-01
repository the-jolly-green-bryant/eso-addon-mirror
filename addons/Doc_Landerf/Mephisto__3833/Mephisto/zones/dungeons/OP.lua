local MP = Mephisto
MP.zones["OP"] = {}
local OP = MP.zones["OP"]

OP.name = GetString(MP_OP_NAME)
OP.tag = "OP"
OP.icon = "/esoui/art/icons/achievement_u41_dun1_vet_bosses.dds"
OP.priority =  129
OP.id = 1470
OP.node = 556

OP.bosses = {
	[1] = {
		name = GetString(MP_TRASH),
	},
	[2] = {
		name = GetString(MP_OP_B1),
	},
	[3] = {
		name = GetString(MP_OP_B2),
	},
	[4] = {
		name = GetString(MP_OP_B3),
	},
	[5] = {
		name = GetString(MP_OP_MB1),
	},[6] = {
		name = GetString(MP_OP_MB2),
	},[7] = {
		name = GetString(MP_OP_MB3),
	},
}

function OP.Init()

end

function OP.Reset()

end

function OP.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(MP_TRASH)
	end

	local pageId = MP.selection.pageId
	local index = OP.lookupBosses[bossName]
	MP.LoadSetup(OP, pageId, index, true)
end
