local MP = Mephisto
MP.zones["DSA"] = {}
local DSA = MP.zones["DSA"]

DSA.name = GetString(MP_DSA_NAME)
DSA.tag = "DSA"
DSA.icon = "/esoui/art/icons/achievement_026.dds"
DSA.priority = 50
DSA.id = 635
DSA.node = 270

DSA.bosses = {
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

function DSA.Init()

end

function DSA.Reset()

end

function DSA.OnBossChange(bossName)

end
