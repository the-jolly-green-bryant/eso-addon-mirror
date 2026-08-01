	
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

function IsPlayerInPvP()
	-- IsPlayerInAvAWorld() will return 'true' if the player is in Cyrodiil, a Cyrodiil delve, Imperial City or the Imperial City sewers.
	-- IsActiveWorldBattleground() will return true if the player is in a Battleground.
	return IsPlayerInAvAWorld() or IsActiveWorldBattleground()
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
	local category = csaCategory or CSA_CATEGORY_LARGE_TEXT
	local theType = csaType or CENTER_SCREEN_ANNOUNCE_TYPE_SYSTEM_BROADCAST
	local lifespanMS = lifespanMillisecs or 3500
	local sound = soundToPlay or SOUNDS.BOOK_ACQUIRED
	if sound == -1 then sound = nil end -- Setting sound to -1 means don't play any sound

	local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(category, sound)
	
	messageParams:SetText(messageTitle, messageSubheading)
	messageParams:SetCSAType(theType)
	messageParams:SetLifespanMS(lifespanMS)		
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
	sound = nil -- no longer needed, we played it once
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