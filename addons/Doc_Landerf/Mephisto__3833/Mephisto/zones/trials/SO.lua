local MP = Mephisto
MP.zones["SO"] = {}
local SO = MP.zones["SO"]

SO.name = GetString(MP_SO_NAME)
SO.tag = "SO"
SO.icon = "/esoui/art/icons/achievement_darkbrotherhood_038.dds"
SO.priority = 2
SO.id = 639
SO.node = 232

SO.bosses = {
	[1] = {
		name = GetString(MP_TRASH),
	},
	[2] = {
		name = GetString(MP_SO_MANTIKORA),
	},
	[3] = {
		name = GetString(MP_SO_TROLL),
	},
	[4] = {
		name = GetString(MP_SO_OZARA),
	},
	[5] = {
		name = GetString(MP_SO_SERPENT),
	},
}

function SO.Init()
	
end

function SO.Reset()
	
end

function SO.OnBossChange(bossName)
	MP.conditions.OnBossChange(bossName)
end