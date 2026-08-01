--[[----------------------------------------
    Project:  	LibClockTST
    Author:     Arne Rantzen (Tyx)
    Created:    2020-01-20
    Updated:    2020-02-16
    License:    GPL-3.0
----------------------------------------]]--
------------
-- LibClock - Tamriel Standard Time
-- Public functions to get information about the in-game time, date and moon
-- You can call them directly or subscribe to updates.
-- Each function also gives the option to get information about a specific timestamp.
----

LibClockTST = {}
LibClockTST.__index = LibClockTST

-- -----------------
-- Constants
-- -----------------

local ID, MAJOR, MINOR = "LibClockTST", "LibClockTST-1.0", 1
local eventHandle = table.concat({MAJOR, MINOR}, "r")

local em = EVENT_MANAGER

--- Constants with all information about the time, date and moon
-- @field time information to calculate the Tamriel Standard Time
-- @field date information to calculate the Tamriel Standard Time date
-- @field moon information to calculate the moon position
-- @table CONSTANTS
function LibClockTST.CONSTANTS()
	--- Constant information to calculate the Tamriel Standard Time
	local time = {
		lengthOfDay = 20955, -- length of one day in s (default 5.75h right now)
		lengthOfNight = 7200, -- length of only the night in s (2h)
		lengthOfHour = 873.125, -- length of an in-game hour in s
		startTime = 1398033648.5, -- unix timestamp in s at in-game noon 1398044126 - 10477.5 (lengthOfDay/2)
	}

	--- Constant information to calculate the Tamriel Standard Time date
	-- Eso Release was the 04.04.2014 at UNIX 1396569600 real time
	-- 93 days after 1.1.582 in-game
	local date = {
		startTime = 1394617983.724, -- release - offset to midnight 2801.2760416667 - offset of days 1948815
		startWeekDay = 2, -- Start day Friday (5) - 93 days to 1.1. Therefore, the weekday is (4 - 93)%7
		startYear = 582, -- offset in years, because the game starts in 2E 582
		startEra = 2, -- era the world is in
		yearLength = 365, -- length of the in-game year in days
		leaps = 141, -- number of leaps in this era, assuming, that year 2E4 and 2E400 are leap years
	}

	--- Different length of month within the year in days
	date.monthLength = {
		[1] = 31, -- Januar
		[2] = 28, -- Februar
		[3] = 31, -- March
		[4] = 30, -- April
		[5] = 31, -- May
		[6] = 30, -- June
		[7] = 31, -- July
		[8] = 31, -- August
		[9] = 30, -- September
		[10] = 31, -- October
		[11] = 30, -- November
		[12] = 31, -- December
	}

	--- Constant information to calculate the moon position
	local moon = {
		startTime = 1436153095, -- start time calculated from https://esoclock.uesp.net/ values to be new moon
		phaseLength = 30, -- ingame days
		phaseLengthInSeconds = 628650, -- in s, phaseLength * dayLength
		singlePhaseLength = 3.75, -- in ingame days
		singlePhaseLengthInSeconds = 78581.25, -- in s, singlePhaseLength * dayLength
		phasesPercentageBetweenPhases = 0.125, -- length in percentage of whole phase of each single phase
	}

	--- Percentage until end of phase  from https://esoclock.uesp.net/
	moon.phasesPercentage = {
		[1] = {
			name = "new",
			endPercentage = 0.06,
		}, -- new moon phase
		[2] = {
			name = "waxingCrescent",
			endPercentage = 0.185,
		}, -- waxing crescent moon phase
		[3] = {
			name = "firstQuarter",
			endPercentage = 0.31,
		}, -- first quarter moon phase
		[4] = {
			name = "waxingGibbous",
			endPercentage = 0.435,
		}, -- waxing gibbous moon phase
		[5] = {
			name = "full",
			endPercentage = 0.56,
		}, -- full moon phase
		[6] = {
			name = "waningGibbous",
			endPercentage = 0.685,
		}, -- waning gibbous moon phase
		[7] = {
			name = "thirdQuarter",
			endPercentage = 0.81,
		}, -- third quarter moon phase
		[8] = {
			name = "waningCrescent",
			endPercentage = 0.935,
		}, -- waning crescent moon phase
	}

	return {
		time = time,
		date = date,
		moon = moon
	}
end

-- -----------------
-- Utility
-- -----------------

--- Check if string is nil or empty
-- @param obj string to be checked
-- @return bool if it is not nil or empty
function LibClockTST.IsNotNilOrEmpty(obj)
    return obj ~= nil and string.match(tostring(obj), "^%s*$") == nil
end

--- Check if input is a timestamp
-- @param timestamp object to be checked
-- @return bool if it matches the condition
function LibClockTST.IsTimestamp(timestamp)
    timestamp = math.floor(tonumber(timestamp) or 0)
    return string.match(tostring(timestamp), "^%d%d%d%d%d%d%d%d%d%d$") ~= nil
end

--- Test if the current year is a leap year
--@param year has to be an integer with the full year length
--@return bool if year is a leap year
function LibClockTST.IsLeapYear(year)
	return year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0)
end

--- Calculate the week day based on a given year, month and day
-- https://en.wikipedia.org/wiki/Determination_of_the_day_of_the_week#Gauss's_algorithm
--@param table like {year = 2020, month = 2, day = 16}
--@return week day as a number from 1 (Monday) to 7 (Sunday)
function LibClockTST.GetWeekDay(table)
	assert(
			type(table.year) == "number" and type(table.month) == "number" and type(table.day) == "number",
			"Please provide a table like {year = 2020, month = 2, day = 16}"
	)

	-- modified method of deriving time/date values from epoch time stamp (Phinix)
	local epochTime = os.time(table)
--	local dayName = zo_strformat("<<t:1>>", os.date('%A', epochTime))
	local dayNumber = tonumber(os.date('%w', epochTime))
	local rw = (dayNumber == 0) and 7 or dayNumber
	return rw

--[[ -- shows LUA table index discrepency due to zero value requiring offset (Phinix)
/script d(os.date('%w', os.time({year = 2021, month = 12, day = 11})))

os.time days:
	Monday:		1
	Tuesday:	2
	Wednesday:	3
	Thursday:	4
	Friday:		5
	Saturday:	6
	Sunday:		0

clocktst days:
	Monday:		1
	Tuesday:	2
	Wednesday:	3
	Thursday:	4
	Friday:		5
	Saturday:	6
	Sunday:		7
]]


--[[ -- old method calculates incorrectly for Dec. 2021 (off by 1 day) and probably others (Phinix)
	-- Calculate
	--@param year has to be an integer with the full year length
	--@return number of leaps since year 0
	local function GetDaysFromZero(y)
		local leaps = math.floor(y / 4) - math.floor( y / 100) + math.floor(y / 400)
		return 365 * y + leaps
	end

	local mm = (table.month % 12 + 9) % 12 -- End is February (11), start is March (0)
	local dd = GetDaysFromZero(table.year + math.floor(table.month / 12) - math.floor(mm / 10))
	local totalDays = dd + math.floor(( mm * 306 + 5) / 10) + table.day - 307
	return totalDays % 7 + 1 -- shift Monday to 1st and Sunday to 7th
--]]
end

-- -----------------
-- Instance
-- -----------------

--- Instance of library
-- You can either get a singleton instance,
-- or create your custom instance with your specific delays.
-- @return LibClockTST object
function LibClockTST:Instance()
	if self._instance then
		return self._instance
	end

	self._instance = LibClockTST:New(200, 36000000, true)
	if self._instance.ctor then
		self._instance:ctor()
	end
	-- -----------------
	-- Commands
	-- -----------------

	-- Event to update the time and date and its listeners
	local function PrintHelp()
		d("Welcome to the |cFFD700LibClock|r - LibClockTST by |c5175ea@Tyx|r [EU] help menu\n"
				.. "To show the current time, write:\n"
				.. "\t\\LibClockTST time\n"
				.. "To show a specific time at a given UNIX timestamp in seconds, write:\n"
				.. "\t\\LibClockTST time [timestamp]\n"
				.. "To show the current date, write:\n"
				.. "\t\\LibClockTST date\n"
				.. "To show a specific date at a given UNIX timestamp in seconds, write:\n"
				.. "\t\\LibClockTST date [timestamp]\n"
				.. "To show the current moon phase, write:\n"
				.. "\t\\LibClockTST moon\n"
				.. "To show a specific moon phase at a given UNIX timestamp in seconds, write:\n"
				.. "\t\\LibClockTST moon [timestamp]\n")
	end

	-- Handel a given command
	-- If time is given, the time table will be printed.
	-- If date is given, the date table will be printed.
	-- If moon is given, the moon table will be printed.
	-- If the second argument is a timestamp, it will be the basis for the calculations.
	-- @param options table of arguments
	local function CommandHandler(options)
		if options[1] == "help" or #options > 2 then
			PrintHelp()
		else
			local timestamp = GetTimeStamp()
			local tNeedToUpdateDate = self._instance.needToUpdateDate
			if #options == 2 then
				if not LibClockTST.IsTimestamp(options[2]) then
					d("Please give only a 10 digit long timestamp as your seconds argument!")
					return
				else
					timestamp = tonumber(options[2])
				end
			end
			if #options == 0 or options[1] == "time" then
				d(self._instance:GetTime(timestamp))
			elseif options[1] == "date" then
				d(self._instance:GetDate(timestamp))
			elseif options[1] == "moon" then
				d(self._instance:GetMoon(timestamp))
			else
				PrintHelp()
			end
			self._instance.needToUpdateDate = tNeedToUpdateDate
		end
	end

	-- Register the slash command 'LibClockTST'
	local function RegisterCommands()
		SLASH_COMMANDS["/tst"] = function (extra)
			local options = {}
			if extra then
				local searchResult = { string.match(extra,"^(%S*)%s*(.-)$") }
				for i,v in pairs(searchResult) do
					if (v ~= nil and v ~= "") then
						options[i] = string.lower(v)
					end
				end
			end
			CommandHandler(options)
		end
	end

	-- -----------------
	-- Initialize
	-- -----------------

	-- Event to be called on Load
	local function OnLoad(_, addonName)
		if addonName ~= ID then return end
		-- wait for the first loaded event
		em:UnregisterForEvent(eventHandle, EVENT_ADD_ON_LOADED)
		RegisterCommands()
	end
	em:RegisterForEvent(eventHandle, EVENT_ADD_ON_LOADED, OnLoad)

	return self._instance
end

--- Constructor
-- Create a object to use custom delays between updates.
-- Warning: Could lead to performance issues if you overdue this!
-- @param updateDelay delays between two updates in ms to calculate the time and date
-- @param moonUpdateDelay delays between two updates in ms to calculate the moon
-- @param[opt] countFullPhaseAsFull is default false.
-- It decides, if the whole full moon phase is counted as full (100%) or the phase is treated as any other.
-- @return LibClockTST object
function LibClockTST:New(updateDelay, moonUpdateDelay, countFullPhaseAsFull)
    local const = LibClockTST.CONSTANTS()
	local LibClockTST = {}

	setmetatable(LibClockTST, _G.LibClockTST)
	LibClockTST.__index = LibClockTST

	-- -----------------
	-- Initialize
	-- -----------------

	assert(
			type(updateDelay) == "number" and type(moonUpdateDelay) == "number",
			"You want to call LibClockTST:Instance() instead, if you don't need specific delays."
	)

	LibClockTST.dateListener = {}
	LibClockTST.moonListener = {}
	LibClockTST.timeListener = {}
	LibClockTST.listener = {}
	LibClockTST.needToUpdateDate = true
	LibClockTST.updateDelay = tonumber(updateDelay)
	LibClockTST.moonUpdateDelay = tonumber(moonUpdateDelay)
	LibClockTST.countFullPhaseAsFull = countFullPhaseAsFull or false

	-- -----------------
	-- Calculation
	-- -----------------

	--- Get the lore time
	-- If a parameter is given, the lore date of the UNIX timestamp will be returned,
	-- otherwise it will be the current time.
	-- @param[opt] timestamp UNIX timestamp in s
	-- @return time table
	--		{ hour, minute, second }
	local function CalculateTST(timestamp)
		local timeSinceStart = timestamp - const.time.startTime
		local secondsSinceMidnight = timeSinceStart % const.time.lengthOfDay
		local tst = 24 * secondsSinceMidnight / const.time.lengthOfDay

		local h = math.floor(tst)
		tst = (tst - h) * 60
		local m = math.floor(tst)
		tst = (tst - m) * 60
		local s = math.floor(tst)

		if h == 0 and h ~= LibClockTST.lastCalculatedHour then
			LibClockTST.needToUpdateDate = true
		end

		LibClockTST.lastCalculatedHour = h

		return { hour = h, minute = m, second = s }
	end

	--- Get the lore date
	-- If a parameter is given, the lore date of the UNIX timestamp will be returned,
	-- otherwise it will be calculated from the current time.
	-- @param[opt] timestamp UNIX timestamp in s
	-- @return date table
	--		{ era, year, month, day, weekDay }
	local function CalculateTSTDate(timestamp)
		local timeSinceStart = timestamp - const.date.startTime
		local daysPast = math.floor(timeSinceStart / const.time.lengthOfDay)

		-- Week day
		local w = (daysPast + const.date.startWeekDay) % 7 + 1

		-- Year
		local yearsSinceStart = math.floor(daysPast / const.date.yearLength)
		local y = yearsSinceStart + const.date.startYear

		-- Leap day
		-- Every fourth year if it can not be divided by 100 or can be divided by 400 is a leap year
		local ly = y - 1
		local leapsSinceStart = math.floor(ly / 4)
				- math.floor(ly / 100) + math.floor(ly / 400) - const.date.leaps

		-- Year and leap adjustment
		daysPast = daysPast - yearsSinceStart * const.date.yearLength - leapsSinceStart
		while daysPast < 0 do
			y = y - 1
			daysPast = daysPast + const.date.yearLength
		end

		-- Month
		local m = 1
		while daysPast >= const.date.monthLength[m] do
			daysPast = daysPast - const.date.monthLength[m]
			if m == 2 and self.IsLeapYear(y) then
				daysPast = daysPast - 1
			end
			m = m + 1
		end

		-- Day
		local d = daysPast + 1

		LibClockTST.needToUpdateDate = false

		return {era = const.date.startEra, year = y, month = m, day = d, weekDay = w }
	end

	--- Get the name of the current moon phase
	-- @param phasePercentage percentage already pased in the current phase
	-- @return current moon phase string
	local function GetCurrentPhaseName(phasePercentage)
		for _, phase in ipairs(const.moon.phasesPercentage) do
			if phasePercentage < phase.endPercentage then return phase.name end
		end
	end

	--- Calculate the seconds until the moon is full again
	-- returns 0 if the moon is already full
	-- @param phasePercentage percentage already pased in the current phase
	-- @return number of seconds until the moon is full again
	local function GetSecondsUntilFullMoon(phasePercentage)
		local secondsOffset = -phasePercentage * const.moon.phaseLengthInSeconds
		if phasePercentage > const.moon.phasesPercentage[5].endPercentage then
			secondsOffset = secondsOffset + const.moon.phaseLengthInSeconds
		end
		local secondsUntilFull = const.moon.phasesPercentage[4].endPercentage
            * const.moon.phaseLengthInSeconds + secondsOffset
		return secondsUntilFull
	end

	--- Calculate the lore moon
	-- @param timestamp UNIX to be calculated from
	-- @return moon table
	--		{ percentageOfPhaseDone, currentPhaseName, isWaxing, isFull,
	--      percentageOfCurrentPhaseDone, secondsUntilNextPhase, daysUntilNextPhase,
	--      secondsUntilFullMoon, daysUntilFullMoon, percentageOfFullMoon }
	local function CalculateMoon(timestamp)
		local timeSinceStart = timestamp - const.moon.startTime
		local secondsSinceNewMoon = timeSinceStart % const.moon.phaseLengthInSeconds
		local phasePercentage = secondsSinceNewMoon / const.moon.phaseLengthInSeconds
		local isWaxing = phasePercentage <= const.moon.phasesPercentage[4].endPercentage
		local isFull = not isWaxing and phasePercentage <= const.moon.phasesPercentage[5].endPercentage
		local currentPhaseName = GetCurrentPhaseName(phasePercentage)
		local percentageOfNextPhase = phasePercentage % const.moon.phasesPercentageBetweenPhases
		local secondsUntilNextPhase = percentageOfNextPhase * const.moon.singlePhaseLengthInSeconds
		local daysUntilNextPhase = percentageOfNextPhase * const.moon.singlePhaseLength
		local secondsUntilFullMoon = GetSecondsUntilFullMoon(phasePercentage)
		local daysUntilFullMoon = secondsUntilFullMoon / const.time.lengthOfDay
		local percentageOfFullMoon
		if LibClockTST.countFullPhaseAsFull then
			if phasePercentage < const.moon.phasesPercentage[4].endPercentage then
				percentageOfFullMoon = phasePercentage * 2
			elseif phasePercentage < const.moon.phasesPercentage[5].endPercentage then
				percentageOfFullMoon = 1
			else
				percentageOfFullMoon = 1 - (phasePercentage - 0.5) * 2
			end

			percentageOfFullMoon = math.min(1,
					percentageOfFullMoon + percentageOfFullMoon * const.moon.phasesPercentageBetweenPhases)
		else
			if phasePercentage < 0.5 then
				percentageOfFullMoon = phasePercentage * 2
			else
				percentageOfFullMoon = 1 - (phasePercentage - 0.5) * 2
			end
		end

		return {
			percentageOfPhaseDone = phasePercentage,
			currentPhaseName = currentPhaseName,
			isWaxing = isWaxing,
			isFull = isFull,
			percentageOfCurrentPhaseDone = percentageOfNextPhase,
			secondsUntilNextPhase = secondsUntilNextPhase,
			daysUntilNextPhase = daysUntilNextPhase,
			secondsUntilFullMoon = secondsUntilFullMoon,
			daysUntilFullMoon = daysUntilFullMoon,
			percentageOfFullMoon = percentageOfFullMoon
		}
	end

	-- -----------------
	-- Update
	-- -----------------

	-- Update the time with the current timestamp and store it in the time variable
	-- If neccessary, update the date and store in also
	local function Update()
		local systemTime = GetTimeStamp()
		LibClockTST.time = CalculateTST(systemTime)
		if not LibClockTST.date or LibClockTST.needToUpdateDate then
			LibClockTST.date = CalculateTSTDate(systemTime)
		end
	end

	-- Update the moon with the current timestamp and store it in the moon variable
	local function MoonUpdate()
		local systemTime = GetTimeStamp()
		LibClockTST.moon = CalculateMoon(systemTime)
	end

	-- Event to update the time and date and its listeners
	local function OnUpdate()
		Update()
		assert(LibClockTST.time, "Time object is empty")
		assert(LibClockTST.date, "Date object is empty")

		for _, f in pairs(LibClockTST.listener) do
			f(LibClockTST.time, LibClockTST.date)
		end

		for _, f in pairs(LibClockTST.timeListener) do
			f(LibClockTST.time)
		end

		for _, f in pairs(LibClockTST.dateListener) do
			f(LibClockTST.date)
		end
	end

	-- Event to update the moon and its listeners
	local function OnMoonUpdate()
		MoonUpdate(LibClockTST)
		assert(LibClockTST.moon, "Moon object is empty")
		for _, f in pairs(LibClockTST.moonListener) do
			f(LibClockTST.moon)
		end
	end

	-- -----------------
	-- Public
	-- -----------------

	--- Get the lore time
	-- If a parameter is given, the lore time of the UNIX timestamp will be returned,
	-- otherwise it will be the current time.
	-- @param[opt] timestamp UNIX timestamp in s
	-- @return time table
	--		{ hour, minute, second }
	-- @see CalculateTST
	function LibClockTST:GetTime(timestamp)
		if timestamp then
			assert(self.IsTimestamp(timestamp), "Please provide nil or a valid timestamp as an argument")
			timestamp = tonumber(timestamp)
			local tNeedToUpdateDate = self.needToUpdateDate
			local t = CalculateTST(timestamp)
			self.needToUpdateDate = tNeedToUpdateDate
			return t
		else
			Update()
			return self.time
		end
	end

	--- Get the lore date
	-- If a parameter is given, the lore date of the UNIX timestamp will be returned,
	-- otherwise it will be calculated from the current time.
	-- @param[opt] timestamp UNIX timestamp in s
	-- @return date table
	-- 		{ era, year, month, day, weekDay }
	-- @see CalculateTSTDate
	function LibClockTST:GetDate(timestamp)
		if timestamp then
			assert(self.IsTimestamp(timestamp), "Please provide nil or a valid timestamp as an argument")
			timestamp = tonumber(timestamp)
			local tNeedToUpdateDate = self.needToUpdateDate
			local d = CalculateTSTDate(timestamp)
			self.needToUpdateDate = tNeedToUpdateDate
			return d
		else
			Update()
			return self.date
		end
	end

	--- Get the lore moon
	-- If a parameter is given, the lore moon of the UNIX timestamp will be returned,
	-- otherwise it will be calculated from the current time.
	-- @param[opt] timestamp UNIX timestamp in s
	-- @return moon table
	--		{ percentageOfPhaseDone, currentPhaseName, isWaxing, isFull,
	--      percentageOfCurrentPhaseDone, secondsUntilNextPhase, daysUntilNextPhase,
	--      secondsUntilFullMoon, daysUntilFullMoon, percentageOfFullMoon }
	-- @see CalculateMoon
	function LibClockTST:GetMoon(timestamp)
		if timestamp then
			assert(self.IsTimestamp(timestamp), "Please provide nil or a valid timestamp as an argument")
			timestamp = tonumber(timestamp)
			return CalculateMoon(timestamp)
		else
			MoonUpdate()
			return self.moon
		end
	end

	--- Register an addon to subscribe to date and time updates.
	-- @param addonId Id of the addon to be registered
	-- @param func function with two parameters for time and date to be called
	-- @see GetTime
	-- @see GetDate
	function LibClockTST:Register(addonId, func)
		assert(self.IsNotNilOrEmpty(addonId),
				"Please provide an ID for the addon. Store it to cancel the subscription later.")
		assert(func, "Please provide a function: func(time, date) to be called every second for a time update.")
		self.listener[addonId] = func
		em:RegisterForUpdate(eventHandle, self.updateDelay, OnUpdate)
	end

	--- Cancel a subscription for the date and time updates.
	-- Will also stop background calculations if no addon is subscribing anymore.
	-- @param addonId Id of the addon previous registered
	function LibClockTST:CancelSubscription(addonId)
		assert(self.IsNotNilOrEmpty(addonId),
				"Please provide an ID to cancel the subscription.")
		self.listener[addonId] = nil
		if #self.listener == 0 then
			em:UnregisterForUpdate(eventHandle)
		end
	end

	--- Register an addon to subscribe to time updates.
	-- @param addonId Id of the addon to be registered
	-- @param func function with a parameter for time to be called
	-- @see LibClockTST:Register
	-- @see GetTime
	function LibClockTST:RegisterForTime(addonId, func)
		assert(self.IsNotNilOrEmpty(addonId),
				"Please provide an ID for the addon. Store it to cancel the subscription later.")
		assert(func, "Please provide a function: func(time) to be called every second for a time update.")
		self.timeListener[addonId] = func
		em:RegisterForUpdate(eventHandle, self.updateDelay, OnUpdate)
	end

	--- Cancel a subscription for the time updates.
	-- @param addonId Id of the addon previous registered
	-- @see LibClockTST:CancelSubscription
	function LibClockTST:CancelSubscriptionForTime(addonId)
		assert(self.IsNotNilOrEmpty(addonId),
				"Please provide an ID to cancel the subscription.")
		self.timeListener[addonId] = nil
		if #self.timeListener == 0 then
			em:UnregisterForUpdate(eventHandle.."-Time")
		end
	end

	--- Register an addon to subscribe to date updates.
	-- @param addonId Id of the addon to be registered
	-- @param func function with a parameter for date to be called
	-- @see LibClockTST:Register
	-- @see GetDate
	function LibClockTST:RegisterForDate(addonId, func)
		assert(self.IsNotNilOrEmpty(addonId),
				"Please provide an ID for the addon. Store it to cancel the subscription later.")
		assert(func, "Please provide a function: func(date) to be called every second for a time update.")
		self.dateListener[addonId] = func
		em:RegisterForUpdate(eventHandle, self.updateDelay, OnUpdate)
	end

	--- Cancel a subscription for the date updates.
	-- @param addonId Id of the addon previous registered
	-- @see LibClockTST:CancelSubscription
	function LibClockTST:CancelSubscriptionForDate(addonId)
		assert(self.IsNotNilOrEmpty(addonId), "Please provide an ID to cancel the subscription.")
		self.dateListener[addonId] = nil
		if #self.dateListener == 0 then
			em:UnregisterForUpdate(eventHandle.."-Date")
		end
	end

	--- Register an addon to subscribe to moon updates.
	-- @param addonId Id of the addon to be registered
	-- @param func function with a parameter for moon to be called
	-- @see LibClockTST:Register
	-- @see GetMoon
	function LibClockTST:RegisterForMoon(addonId, func)
		assert(self.IsNotNilOrEmpty(addonId),
				"Please provide an ID for the addon. Store it to cancel the subscription later.")
		assert(func, "Please provide a function: func(moon) to be called every second for a time update.")
		self.moonListener[addonId] = func
		em:RegisterForUpdate(eventHandle.."-Moon", self.moonUpdateDelay, OnMoonUpdate) -- once per hour should be enough

		-- Update once
		MoonUpdate()
		func(self.moon)
	end

	--- Cancel a subscription for the moon updates.
	-- @param addonId Id of the addon previous registered
	-- @see LibClockTST:CancelSubscription
	function LibClockTST:CancelSubscriptionForMoon(addonId)
		assert(self.IsNotNilOrEmpty(addonId), "Please provide an ID to cancel the subscription.")
		self.moonListener[addonId] = nil
		if #self.moonListener == 0  then
			em:UnregisterForUpdate(eventHandle.."-Moon")
		end
	end

	return LibClockTST
end
