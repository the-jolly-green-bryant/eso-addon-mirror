local MP = Mephisto
MP.zones["AA"] = {}
local AA = MP.zones["AA"]

AA.name = GetString(MP_AA_NAME)
AA.tag = "AA"
AA.icon = "/esoui/art/icons/achievement_update11_dungeons_002.dds"
AA.priority = 1
AA.id = 638
AA.node = 231

AA.bosses = {
	[1] = {
		name = GetString(MP_TRASH),
	},
	[2] = {
		name = GetString(MP_AA_STORMATRO),
	},
	[3] = {
		name = GetString(MP_AA_STONEATRO),
	},
	[4] = {
		name = GetString(MP_AA_VARLARIEL),
	},
	[5] = {
		name = GetString(MP_AA_MAGE),
	},
}

function AA.Init()

end

function AA.Reset()

end

function AA.OnBossChange(bossName)
	MP.conditions.OnBossChange(bossName)
end