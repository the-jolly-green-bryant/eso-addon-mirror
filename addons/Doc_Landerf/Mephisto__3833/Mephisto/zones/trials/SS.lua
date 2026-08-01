local MP = Mephisto
MP.zones["SS"] = {}
local SS = MP.zones["SS"]

SS.name = GetString(MP_SS_NAME)
SS.tag = "SS"
SS.icon = "/esoui/art/icons/achievement_els_sunspire_hardmode_all.dds"
SS.priority = 8
SS.id = 1121
SS.node = 399

SS.bosses = {
	[1] = {
		name = GetString(MP_TRASH),
	},
	[2] = {
		name = GetString(MP_SS_LOKKESTIIZ),
	},
	[3] = {
		name = GetString(MP_SS_YOLNAHKRIIN),
	},
	[4] = {
		name = GetString(MP_SS_NAHVIINTAAS),
	},
}

SS.LOCATIONS = {
	LOKKESTIIZ = {
		x1 = 112000,
		x2 = 118000,
		y1 = 55500, -- z INGAME IS Y
		y2 = 57000, -- z INGAME IS Y old is 56500
		z1 = 100700, -- y INGAME IS Z
		z2 = 108600, -- y INGAME IS Z OLD IS 109900
	},
	YOLNAHKRIIN = {
		x1 = 93500,
		x2 = 101500,
		y1 = 49000, -- z INGAME IS Y
		y2 = 52000, -- z INGAME IS Y old is 50500
		z1 = 107000, -- y INGAME IS Z OLD IS 103500
		z2 = 115600, -- y INGAME IS Z
	},
	NAHVIINTAAS = {
		x1 = 102200,
		x2 = 109300,
		y1 = 63000,
		y2 = 64800,
		z1 = 84700,
		z2 = 96700,
	},
}

function SS.Init()
	EVENT_MANAGER:UnregisterForEvent(MP.name, EVENT_BOSSES_CHANGED)
	EVENT_MANAGER:RegisterForUpdate(MP.name .. SS.tag .. "MovementLoop", 2000, SS.OnMovement)
	EVENT_MANAGER:RegisterForEvent(MP.name .. SS.tag, EVENT_PLAYER_COMBAT_STATE, SS.OnCombatChange)
end

function SS.Reset()
	EVENT_MANAGER:UnregisterForEvent(MP.name .. SS.tag, EVENT_PLAYER_COMBAT_STATE)
	EVENT_MANAGER:UnregisterForUpdate(MP.name .. SS.tag .. "MovementLoop")
	EVENT_MANAGER:RegisterForEvent(MP.name, EVENT_BOSSES_CHANGED, MP.OnBossChange)
end

function SS.OnCombatChange(_, inCombat)
	if inCombat then
		EVENT_MANAGER:UnregisterForUpdate(MP.name .. SS.tag .. "MovementLoop")
	else
		EVENT_MANAGER:RegisterForUpdate(MP.name .. SS.tag .. "MovementLoop", 2000, SS.OnMovement)
	end
end

function SS.OnMovement()
	local bossName = SS.GetBossByLocation()
	if not bossName then return end
	MP.OnBossChange(_, true, bossName)
end

function SS.GetBossByLocation()
	local zone, x, y, z = GetUnitWorldPosition("player")
	
	if zone ~= SS.id then return nil end
	
	if x > SS.LOCATIONS.LOKKESTIIZ.x1 and x < SS.LOCATIONS.LOKKESTIIZ.x2
		and y > SS.LOCATIONS.LOKKESTIIZ.y1 and y < SS.LOCATIONS.LOKKESTIIZ.y2
		and z > SS.LOCATIONS.LOKKESTIIZ.z1 and z < SS.LOCATIONS.LOKKESTIIZ.z2 then
		
		return GetString(MP_SS_LOKKESTIIZ)
		
	elseif x > SS.LOCATIONS.YOLNAHKRIIN.x1 and x < SS.LOCATIONS.YOLNAHKRIIN.x2
		and y > SS.LOCATIONS.YOLNAHKRIIN.y1 and y < SS.LOCATIONS.YOLNAHKRIIN.y2
		and z > SS.LOCATIONS.YOLNAHKRIIN.z1 and z < SS.LOCATIONS.YOLNAHKRIIN.z2 then
		
		return GetString(MP_SS_YOLNAHKRIIN)
	
	elseif x > SS.LOCATIONS.NAHVIINTAAS.x1 and x < SS.LOCATIONS.NAHVIINTAAS.x2
		and y > SS.LOCATIONS.NAHVIINTAAS.y1 and y < SS.LOCATIONS.NAHVIINTAAS.y2
		and z > SS.LOCATIONS.NAHVIINTAAS.z1 and z < SS.LOCATIONS.NAHVIINTAAS.z2 then
		
		return GetString(MP_SS_NAHVIINTAAS)
	
	else
		return GetString(MP_TRASH)
	end
end

function SS.OnBossChange(bossName)
	MP.conditions.OnBossChange(bossName)
end