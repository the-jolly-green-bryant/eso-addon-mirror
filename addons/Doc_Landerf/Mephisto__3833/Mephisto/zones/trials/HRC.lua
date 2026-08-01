local MP = Mephisto
MP.zones["HRC"] = {}
local HRC = MP.zones["HRC"]

HRC.name = GetString(MP_HRC_NAME)
HRC.tag = "HRC"
HRC.icon = "/esoui/art/icons/achievement_update11_dungeons_001.dds"
HRC.priority = 3
HRC.id = 636
HRC.node = 230

HRC.bosses = {
	[1] = {
		name = GetString(MP_TRASH),
	},
	[2] = {
		name = GetString(MP_HRC_RAKOTU),
	},
	[3] = {
		name = GetString(MP_HRC_LOWER),
	},
	[4] = {
		name = GetString(MP_HRC_UPPER),
	},
	[5] = {
		name = GetString(MP_HRC_WARRIOR),
	},
}

function HRC.Init()
	
end

function HRC.Reset()
	
end

function HRC.OnBossChange(bossName)
	MP.conditions.OnBossChange(bossName)
end