local MP = Mephisto
MP.zones["AS"] = {}
local AS = MP.zones["AS"]

AS.name = GetString(MP_AS_NAME)
AS.tag = "AS"
AS.icon = "/esoui/art/icons/achievement_update16_029.dds"
AS.priority = 6
AS.id = 1000
AS.node = 346

AS.bosses = {
	[1] = {
		name = GetString(MP_AS_OLMS),
	},
	[2] = {
		name = GetString(MP_AS_FELMS),
	},
	[3] = {
		name = GetString(MP_AS_LLOTHIS),
	},
}

function AS.Init()
	EVENT_MANAGER:UnregisterForEvent(MP.name, EVENT_BOSSES_CHANGED)
	EVENT_MANAGER:RegisterForUpdate(MP.name .. AS.tag .. "MovementLoop", 2000, AS.OnMovement)
	EVENT_MANAGER:RegisterForEvent(MP.name .. AS.tag, EVENT_PLAYER_COMBAT_STATE, AS.OnCombatChange)
end

function AS.Reset()
	EVENT_MANAGER:UnregisterForEvent(MP.name .. AS.tag, EVENT_PLAYER_COMBAT_STATE)
	EVENT_MANAGER:UnregisterForUpdate(MP.name .. AS.tag .. "MovementLoop")
	EVENT_MANAGER:RegisterForEvent(MP.name, EVENT_BOSSES_CHANGED, MP.OnBossChange)
end

function AS.OnCombatChange(_, inCombat)
	if inCombat then
		EVENT_MANAGER:UnregisterForUpdate(MP.name .. AS.tag .. "MovementLoop")
	else
		EVENT_MANAGER:RegisterForUpdate(MP.name .. AS.tag .. "MovementLoop", 2000, AS.OnMovement)
	end
end

function AS.OnMovement()
	local _, x, y, z = GetUnitWorldPosition("player")
	local bossName = GetString(MP_AS_OLMS)
	if y > 65000 then -- upper part of AS
		bossName = GetString(MP_AS_LLOTHIS)
		if z > 100000 then
			bossName = GetString(MP_AS_FELMS)
		end
	end
	MP.OnBossChange(_, true, bossName)
end

function AS.OnBossChange(bossName)
	-- no trash setup in AS
	if #bossName == 0 then
		return
	end
	
	MP.conditions.OnBossChange(bossName)
end