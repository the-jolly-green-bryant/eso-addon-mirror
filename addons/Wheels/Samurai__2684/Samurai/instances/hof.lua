SAMURAI = SAMURAI or { }
local sam = SAMURAI
--local EM = GetEventManager()
local EM = sam.EM

local spiderPulled = false

local function reset()
	spiderPulled = false
end

local hof = sam.Instance:New(975, nil, reset)

local function hotSpiderPull()
	if not sam.savedVars.bossTimers then return end
	if spiderPulled then
		sam.debug("spider trigger ignored")
		return
	end
	spiderPulled = true
	sam.debug("spider hot-pulled at %d", GetGameTimeMilliseconds())
	sam.spawnTimer(22.1)
end

local function spiderStun()
	sam.debug("spider stunned at %d", GetGameTimeMilliseconds())
end

local function registerSpiderPull()
	spiderPulled = false
	EM:RegisterForEvent(sam.name.."hotSpiderPull", EVENT_COMBAT_EVENT, hotSpiderPull)
	EM:AddFilterForEvent(sam.name.."hotSpiderPull", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 94805)

	EM:RegisterForEvent(sam.name.."spiderStun", EVENT_COMBAT_EVENT, spiderStun)
	EM:AddFilterForEvent(sam.name.."spiderStun", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 94341)
end

local function unregisterSpiderPull()
	EM:UnregisterForEvent(sam.name.."hotSpiderPull", EVENT_COMBAT_EVENT)
	EM:UnregisterForEvent(sam.name.."spiderStun", EVENT_COMBAT_EVENT)
end

hof:AddAlert(sam.ActiveNotification:New(registerSpiderPull, unregisterSpiderPull, "spiderPull"))
hof:AddAlert(sam.ActiveNotification:New(nil, nil, "ShockLash", "13daf0", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {91372}, "Shock Lash", 2000, false))

table.insert(sam.instances, hof)
