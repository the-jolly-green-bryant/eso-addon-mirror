LibDailyReset = {}
LibDailyReset.name = "LibDailyReset"

local LDR = LibDailyReset
local EM = EVENT_MANAGER

LDR.callbacks = {}

local WORLD_NAME = GetWorldName()

local SERVER_RESET_HOURS = {
	["EU Megaserver"] = 3,
	["NA Megaserver"] = 10,
	["PTS"] = 10,
}

local defaultSV = {
	lastKnownDay = 0,
}

-- ================================
-- Core
-- ================================
local function GetServerResetHourUTC()
	return SERVER_RESET_HOURS[WORLD_NAME]
end

local function GetServerDayNumber()
	local now = GetTimeStamp()
	local resetHour = GetServerResetHourUTC()

	local dateTable = os.date("!*t", now)

	if dateTable.hour < resetHour then
		now = now - 86400
	end

	return math.floor(now / 86400)
end

function LDR.IsNewDay()
	local currentDay = GetServerDayNumber()
	return currentDay ~= LDR.SV.lastKnownDay
end

function LDR.GetCurrentServerDay()
	return GetServerDayNumber()
end

function LDR.GetSecondsUntilReset()
	return GetTimeUntilNextDailyLoginRewardClaimS()
end

-- ================================
-- Callbacks
-- ================================
function LDR.RegisterCallback(name, func)
	LDR.callbacks[name] = LDR.callbacks[name] or {}
	table.insert(LDR.callbacks[name], func)
end

function LDR.UnregisterCallback(name, func)
	if not LDR.callbacks[name] then return end

	for i, f in ipairs(LDR.callbacks[name]) do
		if f == func then
			table.remove(LDR.callbacks[name], i)
			return
		end
	end
end

local function FireCallbacks(name)
	if not LDR.callbacks[name] then return end
	for _, func in ipairs(LDR.callbacks[name]) do
		func()
	end
end

-- ================================
-- Hot Reset Timer
-- ================================
local function ScheduleNextReset()
	local secondsUntilReset = GetTimeUntilNextDailyLoginRewardClaimS()

	EM:UnregisterForUpdate(LDR.name)

	EM:RegisterForUpdate(
		LDR.name,
		secondsUntilReset * 1000,
		function()
			FireCallbacks("OnDailyReset")

			local currentDay = GetServerDayNumber()
			if currentDay <= LDR.SV.lastKnownDay then
				LDR.SV.lastKnownDay = LDR.SV.lastKnownDay + 1
			else
				LDR.SV.lastKnownDay = currentDay
			end

			ScheduleNextReset()
		end
	)
end

-- ================================
-- Commands
-- ================================
SLASH_COMMANDS["/ldrdebug"] = function()
	local server = GetWorldName()
	local now = GetTimeStamp()
	local dateTableUTC = os.date("!*t", now)
	local dateStr = string.format("%04d-%02d-%02d %02d:%02d:%02d UTC",
		dateTableUTC.year, dateTableUTC.month, dateTableUTC.day,
		dateTableUTC.hour, dateTableUTC.min, dateTableUTC.sec
	)

	local serverDay = LDR.GetCurrentServerDay()
	local secondsUntilReset = LDR.GetSecondsUntilReset()

	d("=== LibDailyReset Debug ===")
	d("Server: " .. server)
	d("UTC Date/Time: " .. dateStr)
	d("Server Day Number: " .. serverDay)
	d("Saved Last Known Day: " .. tostring(LDR.SV.lastKnownDay))
	d("Seconds Until Next Reset (API): " .. tostring(secondsUntilReset))
	d("==========================")
end

SLASH_COMMANDS["/ldrtestreset"] = function()
	LDR.SV.lastKnownDay = LDR.GetCurrentServerDay() - 1
	if LDR.IsNewDay() then
		LDR.SV.lastKnownDay = LDR.GetCurrentServerDay()
		d("LibDailyReset: Forced reset triggered!")
		FireCallbacks("OnDailyReset")
	end
end

-- ================================
-- Init
-- ================================
function LDR.Initialize()
	EM:UnregisterForEvent(LDR.name, EVENT_ADD_ON_LOADED)

	LDR.SV = ZO_SavedVars:NewAccountWide("LibDailyReset_SavedVariables", 1, nil, defaultSV)

	EM:RegisterForEvent(LDR.name, EVENT_PLAYER_ACTIVATED, function()
		EM:UnregisterForEvent(LDR.name, EVENT_PLAYER_ACTIVATED)

		local currentDay = GetServerDayNumber()

		if currentDay ~= LDR.SV.lastKnownDay then
			LDR.SV.lastKnownDay = currentDay
			FireCallbacks("OnDailyReset")
		end

		ScheduleNextReset()
	end)
end

EM:RegisterForEvent(LDR.name, EVENT_ADD_ON_LOADED, function(_, addonName)
	if addonName == LDR.name then
		LDR.Initialize()
	end
end)