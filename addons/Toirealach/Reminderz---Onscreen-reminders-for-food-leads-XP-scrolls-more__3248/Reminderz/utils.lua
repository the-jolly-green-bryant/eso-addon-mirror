	
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Utility functions
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function ConvertSecstoTime(n)

    local days = n / (24 * 3600)
    n = n % (24 * 3600)
    local hours = n / 3600
    n = n % 3600
    local minutes = n / 60
    n = n % 60
    local seconds = n
    
    return days, hours, minutes, seconds
end

function TimeUntilDailyReset()
	
	local minSecs = 60
	local hourSecs = 60 * minSecs
	local daySecs = hourSecs * 24
	local currHour = 0
	local hrsRemain = 0
	local currMin = 0
	local minRemain = 0
	local currTimeStamp = GetTimeStamp()
	local kDailyResetTime = 1451606400 -- daily UTC reset time constant

	currTimeStamp = currTimeStamp - kDailyResetTime
	currTimeStamp = currTimeStamp % daySecs -- remove days
	
	currHour = math.floor(currTimeStamp / hourSecs) -- get hours
	currTimeStamp = currTimeStamp % hourSecs -- remove hours
	
	currMin = math.floor(currTimeStamp / minSecs) -- get mins
	currTimeStamp = currTimeStamp % minSecs -- remove mins

	if currHour > 5 then 
		hrsRemain = 24 - currHour + 5
	else
		hrsRemain = 6 - currHour - 1
	end
	minRemain = 60 - currMin
	return hrsRemain, minRemain
end


function PlayerIsInPvP()
	
	local debug = false
	
	if IsInAvAZone() then return true end
	
	if IsActiveWorldBattleground()	then return true end	
	if IsPlayerInAvAWorld()	then return true end
	if InPvPMap() then return true end

	return false
end

function InPvPMap()
	-- The map can tell us what kind of zone the player is in.
	-- If in a battleground or an AvA zone then they are in a PvP Zone
	local mapContent = GetMapContentType()
	local inPvPZone = (mapContent == MAP_CONTENT_AVA or mapContent == MAP_CONTENT_BATTLEGROUND)
	return inPvPZone
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
--
-- copyDeep()
--
-- Lua contains no native function to make deep copies of tables and
-- since we use tables to store everything, we need a way to do deep copies
-- because we use tables as structs. If I were the language writer, I'd simply 
-- assign a new operator, something like ":=", to do a deep copy like this.
-- 
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function copyDeep(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[copyDeep(orig_key)] = copyDeep(orig_value)
        end
        setmetatable(copy, copyDeep(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
--
-- tablelength(T)
--
-- Lua tables where elements are indexed by strings may not return the correct value 
-- for #(table). So use this instead to always get the corect number of elements in
-- a lua table.
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- String utilities that should exist in lua but don't 
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function splitString(s, delimiter)
		delimiter = delimiter or " " -- default to spaces as the delimiter
    array = {}
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(array, match);
    end
    return array
end

function combineStrings(array, start, delimiter)
	assert(array ~= nil)
	assert(start > 0)
	delimiter = delimiter or " "
	local d = ""
	local s = ""
	for i = start, #array do
		if i == start then d = "" else d = delimiter end
		s = s..d..array[i]
	end
	return s
end

function boolStr(b) 
	if b == true then return "true" end
	return "false"
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Center Screen Announcements made much easier FFS
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

CSAnnounce = CSAnnounce or {}

function CSAnnounce.Make(messageTitle, messageSubheading, lifespanMillisecs, soundToPlay, csaCategory, csaType)

	assert(messageTitle ~= nil and messageTitle ~= "")	
	local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(csaCategory or CSA_CATEGORY_LARGE_TEXT, soundToPlay or SOUNDS.BOOK_ACQUIRED)
	
	messageParams:SetText(messageTitle, messageSubheading)
	messageParams:SetCSAType(csaType or CENTER_SCREEN_ANNOUNCE_TYPE_SYSTEM_BROADCAST)
	messageParams:SetLifespanMS(lifespanMillisecs or 3500)		
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
end

function CSAnnounce.System(messageTitle, messageSubheading, lifespanMillisecs, soundToPlay)

	local category = CSA_CATEGORY_MAJOR_TEXT
	if messageSubheading then category = CSA_CATEGORY_LARGE_TEXT end

	CSAnnounce.Make(messageTitle, messageSubheading, lifespanMillisecs, soundToPlay, 
					category, CENTER_SCREEN_ANNOUNCE_TYPE_SYSTEM_BROADCAST)
end

function CSAnnounce.Small(messageTitle, messageSubheading, lifespanMillisecs, soundToPlay)

	CSAnnounce.Make(messageTitle, messageSubheading, lifespanMillisecs, soundToPlay, 
					CSA_CATEGORY_SMALL_TEXT, 
					CENTER_SCREEN_ANNOUNCE_TYPE_SYSTEM_BROADCAST)
end

function CSAnnounce.Large(messageTitle, messageSubheading, lifespanMillisecs, soundToPlay)

	CSAnnounce.Make(messageTitle, messageSubheading, lifespanMillisecs, soundToPlay, 
					CSA_CATEGORY_LARGE_TEXT, 
					CENTER_SCREEN_ANNOUNCE_TYPE_SYSTEM_BROADCAST)
end

function CSAnnounce.RaidComplete(messageTitle, messageSubheading, lifespanMillisecs, soundToPlay) -- Requires some raid params so wil lfail

	CSAnnounce.Make(messageTitle, messageSubheading, lifespanMillisecs, soundToPlay, 
					CSA_CATEGORY_RAID_COMPLETE_TEXT, 
					CENTER_SCREEN_ANNOUNCE_TYPE_SYSTEM_BROADCAST)
end

function CSAnnounce.Major(messageTitle, messageSubheading, lifespanMillisecs, soundToPlay)

	CSAnnounce.Make(messageTitle, messageSubheading, lifespanMillisecs, soundToPlay, 
					CSA_CATEGORY_MAJOR_TEXT, 
					CENTER_SCREEN_ANNOUNCE_TYPE_SYSTEM_BROADCAST)
end

function CSAnnounce.Countdown(messageTitle, messageSubheading, lifespanMillisecs, soundToPlay)

	CSAnnounce.Make(messageTitle, messageSubheading, lifespanMillisecs, soundToPlay, 
					CSA_CATEGORY_COUNTDOWN_TEXT, 
					CENTER_SCREEN_ANNOUNCE_TYPE_SYSTEM_BROADCAST)
end