local MP = Mephisto
MP.zones["GEN"] = {}
local GEN = MP.zones["GEN"]

GEN.name = GetString(MP_GENERAL)
GEN.tag = "GEN"
GEN.icon = "/esoui/art/icons/achievement_u26_skyrim_trial_flavor_2.dds"
GEN.priority = -2
GEN.id = -1
GEN.node = -1

GEN.bosses = {}

function GEN.Init()
	
end

function GEN.Reset()
	
end

function GEN.OnBossChange(bossName)
	MP.conditions.OnBossChange(bossName)
end