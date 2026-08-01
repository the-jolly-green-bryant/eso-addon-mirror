-- This libray is currently only for internal use and its API might change a lot between versions
local lib = LibStub:NewLibrary("LibKillEvents", 1)

if not lib then
	return	-- already loaded and no upgrade necessary
end

local LIB_IDENTIFIER = "LibKillEvents"
local EVENT_MANAGER = EVENT_MANAGER
local EVENT_COMBAT_EVENT = EVENT_COMBAT_EVENT
local REGISTER_FILTER_COMBAT_RESULT = REGISTER_FILTER_COMBAT_RESULT

if(not lib.cm) then -- create the callback object early
	lib.cm = ZO_CallbackObject:New()
	lib.nextEventHandleIndex = 1
end

local function RegisterCombatResultEvent(result, callback)
	local eventHandleName = LIB_IDENTIFIER .. lib.nextEventHandleIndex
	lib.nextEventHandleIndex = lib.nextEventHandleIndex + 1
	EVENT_MANAGER:RegisterForEvent(eventHandleName, EVENT_COMBAT_EVENT, callback)
	EVENT_MANAGER:AddFilterForEvent(eventHandleName, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, result)
	return eventHandleName
end

EVENT_MANAGER:UnregisterForEvent(LIB_IDENTIFIER, EVENT_PLAYER_ACTIVATED)
EVENT_MANAGER:RegisterForEvent(LIB_IDENTIFIER, EVENT_PLAYER_ACTIVATED, function()
	EVENT_MANAGER:UnregisterForEvent(LIB_IDENTIFIER, EVENT_PLAYER_ACTIVATED)
	local cm = lib.cm
	local characterName = GetRawUnitName("player")

	-- collect recent AP
    local AP_GAIN_RECENT_THRESHOLD = 2000
    local AP_GAIN_PK_THRESHOLD = 2000
	local apGainIndex = 1
	local apGains = {}
	for i=1, 30 do apGains[i] = {time=0, amount=0} end
	local function StoreApGain(amount)
		if(amount > AP_GAIN_PK_THRESHOLD) then return end -- solo player kills shouldn't give more than this
		local gain = apGains[apGainIndex]
		gain.time = GetFrameTimeMilliseconds()
		gain.amount = amount
		apGainIndex = apGainIndex + 1
		if(apGainIndex >= #apGains) then apGainIndex = 1 end
	end

	local function GetRecentApGains()
		local now = GetFrameTimeMilliseconds()
		local ap = 0
		local index = apGainIndex
		local gain
		for i = 1, #apGains do
			index = index - 1
			if(index < 1) then index = #apGains end
			gain = apGains[index]
			if(now - gain.time < AP_GAIN_RECENT_THRESHOLD) then
				ap = ap + gain.amount
				gain.amount = 0
				gain.time = 0
			else
				break
			end
		end
		return ap
	end

	EVENT_MANAGER:RegisterForEvent(LIB_IDENTIFIER, EVENT_ALLIANCE_POINT_UPDATE, function(eventId, alliancePoints, playSound, difference)
		if(difference > 0) then StoreApGain(difference) end
	end)

	-- collect and handle killing blows
	local killingBlows = {}

	local function ProcessKillingBlows(targetName, alliancePoints)
		local targetKillingBlows = killingBlows[targetName]
		killingBlows[targetName] = nil
		cm:FireCallbacks("PlayerKill", targetName, targetKillingBlows, alliancePoints)
	end

	local function CollectKillingBlows(targetName, abilityName)
		local targetKillingBlows = killingBlows[targetName]
		if(not targetKillingBlows) then
			targetKillingBlows = {}
			killingBlows[targetName] = targetKillingBlows
			zo_callLater(function() ProcessKillingBlows(targetName, GetRecentApGains()) end, 0)
		end
		targetKillingBlows[#targetKillingBlows + 1] = abilityName
	end

	-- handle combat results
	RegisterCombatResultEvent(ACTION_RESULT_DIED, function(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log)
		if(targetName == characterName) then
			cm:FireCallbacks("PlayerDeath", sourceName, {}, {abilityName}) -- TODO: gather and pass assists (e.g knockback off a cliff)
		end
	end)
	RegisterCombatResultEvent(ACTION_RESULT_DIED_XP, function(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log)
		if(sourceName == characterName) then
			cm:FireCallbacks("NonPlayerKill", targetName, {abilityName}) -- TODO: gather proc effects (e.g. camo hunter) and xp gained
		end
	end)
	RegisterCombatResultEvent(ACTION_RESULT_KILLING_BLOW, function(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log)
		if(targetName == characterName) then
			cm:FireCallbacks("PlayerDeath", sourceName, {}, {abilityName}) -- TODO: gather and pass assists
		elseif(sourceName == characterName) then
			if(abilityName ~= "") then
				CollectKillingBlows(targetName, abilityName)
			else
				cm:FireCallbacks("PlayerKillAssist", targetName) -- TODO: AP gained
			end
		end
	end)
end)

function lib:RegisterForPlayerKill(callback)
	lib.cm:RegisterCallback("PlayerKill", callback)
end

function lib:UnregisterForPlayerKill(callback)
	lib.cm:UnregisterCallback("PlayerKill", callback)
end

function lib:RegisterForPlayerKillAssist(callback)
	lib.cm:RegisterCallback("PlayerKillAssist", callback)
end

function lib:UnregisterForPlayerKillAssist(callback)
	lib.cm:UnregisterCallback("PlayerKillAssist", callback)
end

function lib:RegisterForPlayerDeath(callback)
	lib.cm:RegisterCallback("PlayerDeath", callback)
end

function lib:UnregisterForPlayerDeath(callback)
	lib.cm:UnregisterCallback("PlayerDeath", callback)
end

function lib:RegisterForNonPlayerKill(callback)
	lib.cm:RegisterCallback("NonPlayerKill", callback)
end

function lib:UnregisterForNonPlayerKill(callback)
	lib.cm:UnregisterCallback("NonPlayerKill", callback)
end
