local MP = Mephisto
MP.zones["CR"] = {}
local CR = MP.zones["CR"]

CR.name = GetString(MP_CR_NAME)
CR.tag = "CR"
CR.icon = "/esoui/art/icons/achievement_su_karnwasten_groupevent.dds"
CR.priority = 7
CR.id = 1051
CR.node = 364

CR.bosses = {
	[1] = {
		name = GetString(MP_CR_ZMAJA),
	},
	[2] = {
		name = GetString(MP_CR_GALENWE),
	},
	[3] = {
		name = GetString(MP_CR_SIRORIA),
	},
	[4] = {
		name = GetString(MP_CR_RELEQUEN),
	},
}

function CR.Init()
	CR.lastBoss1 = ""
	CR.lastBoss2 = ""
	CR.lastBoss3 = ""
end

function CR.Reset()
	
end

function CR.OnBossChange(bossName)
	CR.lastBoss3 = CR.lastBoss2
	CR.lastBoss2 = CR.lastBoss1
	CR.lastBoss1 = bossName
	
	-- dont change if boss - trash - boss
	if CR.lastBoss1 == CR.lastBoss3 and CR.lastBoss2 == "" then
		return
	end
	
	-- no trash setup in CR
	if #bossName == 0 then
		return
	end
	
	MP.conditions.OnBossChange(bossName)
end