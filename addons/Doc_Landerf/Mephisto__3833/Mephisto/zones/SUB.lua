local MP = Mephisto
MP.zones["SUB"] = {}
local SUB = MP.zones["SUB"]

SUB.name = GetString(MP_SUB_NAME)
SUB.tag = "SUB"
SUB.icon = "/esoui/art/icons/achievement_u23_skillmaster_darkbrotherhood.dds"
SUB.priority = -1
SUB.id = -1
SUB.node = -1

SUB.bosses = {
	[1] = {
		name = GetString(MP_SUB_TRASH),
	},
	[2] = {
		name = GetString(MP_SUB_BOSS),
	},
}

function SUB.Init()
	
end

function SUB.Reset()
	
end

function SUB.OnBossChange(bossName)
	MP.conditions.OnBossChange(bossName)
end