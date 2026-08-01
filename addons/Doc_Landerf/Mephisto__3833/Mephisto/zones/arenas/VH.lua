local MP = Mephisto
MP.zones["VH"] = {}
local VH = MP.zones["VH"]

VH.name = GetString(MP_VH_NAME)
VH.tag = "VH"
VH.icon = "/esoui/art/icons/achievement_u28_varena_veteran.dds"
VH.priority = 53
VH.id = 1227
VH.node = 457

VH.bosses = {
	[1] = {
		name = GetString(MP_EMPTY),
	},
	[2] = {
		name = GetString(MP_EMPTY),
	},
	[3] = {
		name = GetString(MP_EMPTY),
	},
	[4] = {
		name = GetString(MP_EMPTY),
	},
	[5] = {
		name = GetString(MP_EMPTY),
	},
	[6] = {
		name = GetString(MP_EMPTY),
	},
	[7] = {
		name = GetString(MP_EMPTY),
	},
	[8] = {
		name = GetString(MP_EMPTY),
	},
}

function VH.Init()

end

function VH.Reset()

end

function VH.OnBossChange(bossName)

end
