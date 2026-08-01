local MP = Mephisto
MP.zones["BRP"] = {}
local BRP = MP.zones["BRP"]

BRP.name = GetString(MP_BRP_NAME)
BRP.tag = "BRP"
BRP.icon = "/esoui/art/icons/achievement_blackrose_veteran.dds"
BRP.priority = 51
BRP.id = 1082
BRP.node = 378

BRP.bosses = {
	[1] = {
		name = GetString(MP_TRASH),
	},
	[2] = {
		name = GetString(MP_BRP_FIRST),
	},
	[3] = {
		name = GetString(MP_BRP_SECOND),
	},
	[4] = {
		name = GetString(MP_BRP_THIRD),
	},
	[5] = {
		name = GetString(MP_BRP_FOURTH),
	},
	[6] = {
		name = GetString(MP_BRP_FIFTH),
	},
}

BRP.LOCATIONS = {
	FIRST = {
		x1 = 100908,
		x2 = 106042,
		z1 = 65900,
		z2 = 71000,
	},
	SECOND = {
		x1 = 88100,
		x2 = 93100,
		z1 = 60911,
		z2 = 66032,
	},
	THIRD = {
		x1 = 94504,
		x2 = 99517,
		z1 = 46800,
		z2 = 51900,
	},
	FORTH = {
		x1 = 105900,
		x2 = 111100,
		z1 = 35255,
		z2 = 40383,
	},
	FIFTH = {
		x1 = 93800,
		x2 = 98281,
		z1 = 28200,
		z2 = 33300,
	},
}

BRP.PORTALID = 114578

function BRP.Init()
	BRP.lastArena = 0
	
	BRP.lastPortalSpawn = 0
	BRP.currentRound = 0
	BRP.currentWave = 0
	
	EVENT_MANAGER:UnregisterForEvent(MP.name, EVENT_BOSSES_CHANGED)
	EVENT_MANAGER:RegisterForUpdate(MP.name .. BRP.tag .. "MovementLoop", 2000, BRP.OnMovement)
	EVENT_MANAGER:RegisterForEvent(MP.name .. BRP.tag, EVENT_PLAYER_COMBAT_STATE, BRP.OnCombatChange)
	
	EVENT_MANAGER:RegisterForEvent(MP.name  .. BRP.tag.. "PortalSpawn", EVENT_COMBAT_EVENT, BRP.OnPortalSpawn)
	EVENT_MANAGER:AddFilterForEvent(MP.name  .. BRP.tag.. "PortalSpawn", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, BRP.PORTALID)
	EVENT_MANAGER:RegisterForEvent(MP.name .. BRP.tag .. "LastWave", EVENT_DISPLAY_ANNOUNCEMENT, BRP.OnLastWave)
end

function BRP.Reset()
	EVENT_MANAGER:UnregisterForEvent(MP.name .. BRP.tag, EVENT_PLAYER_COMBAT_STATE)
	EVENT_MANAGER:UnregisterForUpdate(MP.name .. BRP.tag .. "MovementLoop")
	EVENT_MANAGER:RegisterForEvent(MP.name, EVENT_BOSSES_CHANGED, MP.OnBossChange)
	
	EVENT_MANAGER:UnregisterForEvent(MP.name  .. BRP.tag.. "PortalSpawn")
	EVENT_MANAGER:UnregisterForEvent(MP.name .. BRP.tag .. "LastWave")
end

function BRP.OnBossChange(bossName)
	MP.conditions.OnBossChange(bossName)
end

function BRP.OnCombatChange(_, inCombat)
	if inCombat == true then
		EVENT_MANAGER:UnregisterForUpdate(MP.name .. BRP.tag .. "MovementLoop")
	else
		EVENT_MANAGER:RegisterForUpdate(MP.name .. BRP.tag .. "MovementLoop", 2000, BRP.OnMovement)
	end
end

function BRP.OnMovement()
	local arena = BRP.GetStageByLocation()
	--d("Arena " .. tostring(arena) .. " / Last arena " .. BRP.lastArena)
	if arena == 0 and BRP.lastArena > 0 then
		--d("Trash!")
		MP.OnBossChange(_, true, "")
	end
	BRP.lastArena = arena
end

function BRP.GetStageByLocation()
	local zone, x, y, z = GetUnitWorldPosition("player")
	
	if x > BRP.LOCATIONS.FIRST.x1 and x < BRP.LOCATIONS.FIRST.x2
		and z > BRP.LOCATIONS.FIRST.z1 and z < BRP.LOCATIONS.FIRST.z2 then
		
		return 1
		
	elseif x > BRP.LOCATIONS.SECOND.x1 and x < BRP.LOCATIONS.SECOND.x2
		and z > BRP.LOCATIONS.SECOND.z1 and z < BRP.LOCATIONS.SECOND.z2 then
		
		return 2
	
	elseif x > BRP.LOCATIONS.THIRD.x1 and x < BRP.LOCATIONS.THIRD.x2
		and z > BRP.LOCATIONS.THIRD.z1 and z < BRP.LOCATIONS.THIRD.z2 then
		
		return 3
		
	elseif x > BRP.LOCATIONS.FORTH.x1 and x < BRP.LOCATIONS.FORTH.x2
		and z > BRP.LOCATIONS.FORTH.z1 and z < BRP.LOCATIONS.FORTH.z2 then
		
		return 4
		
	elseif x > BRP.LOCATIONS.FIFTH.x1 and x < BRP.LOCATIONS.FIFTH.x2
		and z > BRP.LOCATIONS.FIFTH.z1 and z < BRP.LOCATIONS.FIFTH.z2 then
		
		return 5
	
	else
	
		return 0
		
	end
end

function BRP.OnLastWave(_, title)
	if title == GetString(MP_BRP_FINALROUND) then
		BRP.currentRound = 5
		BRP.currentWave = 0
	else
		local round = string.match(title, '^.+%s(%d)$')
		if round then
			BRP.currentRound = tonumber(round)
			BRP.currentWave = 0
		end
	end
end

function BRP.Wave()
	local stage = BRP.GetStageByLocation()
	local round = BRP.currentRound
	local wave = BRP.currentWave
	
	-- STAGE 1
	if stage == 1 then
		if round == 4 and wave == 3 then MP.OnBossChange(_, true, GetString(MP_BRP_FIRST)) end
		
	-- STAGE 2
	elseif stage == 2 then
		if round == 4 and wave == 2 then MP.OnBossChange(_, true, GetString(MP_BRP_SECOND)) end
		
	-- STAGE 3
	elseif stage == 3 then
		if round == 4 and wave == 3 then MP.OnBossChange(_, true, GetString(MP_BRP_THIRD)) end
		
	-- STAGE 4
	elseif stage == 4 then
		if round == 4 and wave == 3 then MP.OnBossChange(_, true, GetString(MP_BRP_FOURTH)) end
		
	-- STAGE 5
	elseif stage == 5 then
		if round == 4 and wave == 3 then MP.OnBossChange(_, true, GetString(MP_BRP_FIFTH)) end
	end
end

function BRP.OnPortalSpawn(_, result, _, _, _, _, _, _, _, _, _, _, _, _, _, _, abilityId)
	if result == ACTION_RESULT_EFFECT_GAINED then
		local spawnTime = GetGameTimeMilliseconds()
		if spawnTime - BRP.lastPortalSpawn > 2000 then
			BRP.currentWave = BRP.currentWave + 1
			BRP.Wave()
		end
		BRP.lastPortalSpawn = spawnTime
	end
end
