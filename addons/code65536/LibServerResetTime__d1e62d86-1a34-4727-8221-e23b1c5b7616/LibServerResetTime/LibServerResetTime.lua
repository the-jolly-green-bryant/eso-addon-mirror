LibServerResetTime = { }
local LSRT = LibServerResetTime


--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

local NAME = "LibServerResetTime"

local SECONDS_IN_DAY = 86400
local FALLBACK_ANCHOR_TIME = 1735639200 -- NA region

local REGION_NA = 1
local REGION_EU = 2
local REGION_DELTA = 25200 -- 7 hours
local REGION_CONVERSIONS = {
	[REGION_NA] = {
		["NA"] = 0,
		["EU"] = -REGION_DELTA,
		["PTS"] = 0,
	},
	[REGION_EU] = {
		["NA"] = REGION_DELTA,
		["EU"] = 0,
		["PTS"] = REGION_DELTA,
	},
}

local CURRENT_REGION = ({ ["EU Megaserver"] = true, ["XB1live-eu"] = true, ["PS4live-eu"] = true })[GetWorldName()] and REGION_EU or REGION_NA


--------------------------------------------------------------------------------
-- GetResetTimestamp
--------------------------------------------------------------------------------

function LSRT.GetResetTimestamp( previous, weekly, server, timestamp )
	local anchorTime = GetTimedActivityTypeResetTimeS(TIMED_ACTIVITY_TYPE_WEEKLY) or 0
	if (anchorTime == 0) then
		anchorTime = CURRENT_REGION == REGION_NA and FALLBACK_ANCHOR_TIME or FALLBACK_ANCHOR_TIME - REGION_DELTA
	end
	anchorTime = anchorTime + (server and REGION_CONVERSIONS[CURRENT_REGION][server] or 0)

	local interval = SECONDS_IN_DAY * (weekly and 7 or 1)
	local previousReset = anchorTime + zo_floor(((timestamp or GetTimeStamp()) - anchorTime) / interval) * interval

	return previous and previousReset or previousReset + interval
end


--------------------------------------------------------------------------------
-- GetSecondsUntilNextReset
--------------------------------------------------------------------------------

function LSRT.GetSecondsUntilNextReset( weekly, server, timestamp )
	return LSRT.GetResetTimestamp(false, weekly, server, timestamp) - (timestamp or GetTimeStamp())
end


--------------------------------------------------------------------------------
-- GetServerDate
--------------------------------------------------------------------------------

function LSRT.GetServerDate( server, timestamp )
	local date = os.date("!*t", LSRT.GetResetTimestamp(true, false, server, timestamp))
	return date.year, date.month, date.day
end


--------------------------------------------------------------------------------
-- RegisterForDailyResetCallback
--------------------------------------------------------------------------------

do
	local Callbacks = { }
	local Active = false
	local HandleReset

	local function ToggleUpdate( seconds )
		if (seconds) then
			Active = true
			EVENT_MANAGER:RegisterForUpdate(NAME, seconds * 1000, HandleReset)
		else
			Active = false
			EVENT_MANAGER:UnregisterForUpdate(NAME)
		end
	end

	local function CheckRegistrations( )
		if (not Active and next(Callbacks)) then
			ToggleUpdate(LSRT.GetSecondsUntilNextReset())
		elseif (Active and not next(Callbacks)) then
			ToggleUpdate(false)
		end
	end

	HandleReset = function( )
		ToggleUpdate(false)
		ToggleUpdate(SECONDS_IN_DAY)
		for _, fn in pairs(Callbacks) do fn() end
	end

	function LSRT.RegisterForDailyResetCallback( name, callback )
		if (type(name) == "string" and name ~= "" and (type(callback) == "function" or callback == nil)) then
			Callbacks[name] = callback
			CheckRegistrations()
		end
	end

	EVENT_MANAGER:RegisterForEvent(NAME, EVENT_PLAYER_ACTIVATED, CheckRegistrations, true)
end


--------------------------------------------------------------------------------
-- Compatibility layer for the deprecated LibDailyResetTime
--------------------------------------------------------------------------------

LibDailyResetTime = {
	GetSecondsUntilNextDailyReset = function() return LSRT.GetSecondsUntilNextReset() end,
	GetDailyResetTime = function(previous) return LSRT.GetResetTimestamp(previous) end,
	GetCurrentServerDate = function() return LSRT.GetServerDate() end,
	RegisterForCallback = LSRT.RegisterForDailyResetCallback,
}
