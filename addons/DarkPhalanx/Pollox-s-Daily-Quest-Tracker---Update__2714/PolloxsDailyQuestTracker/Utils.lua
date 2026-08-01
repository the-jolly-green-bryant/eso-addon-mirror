--[[
	Useful standalone functions
--]]

local Utils = {}
DQT.Utils = Utils

--[[ Get a table of characters, sorted alphabetically by display name

	 @return list of {id=character id, name = character display name, rawName = character raw name}
-]]
function Utils:getCharacters()
	if not self.characters then
		local characters = {}
		
		for i = 1, GetNumCharacters() do
			local characterRawName, _, _, _, _, _, characterId = GetCharacterInfo(i)
			
			characters[#characters + 1] = {
				id = characterId,
				name = zo_strformat("<<1>>", characterRawName),
				rawName = characterRawName
			}
		end
		
		-- sort table alphabetically
		table.sort(characters, function(a, b) return a.name < b.name end)
		
		self.characters = characters
	end
	
	return self.characters
end

-- get current time in UTC seconds
function Utils:getCurrentTime()
	return os.time(os.date("!*t"))
end

--[[Calculates time of next daily quest reset in UTC.
    
	Reset is at 6am UTC. If your computer clock is off, this will be off.
	
	@return reset time in UTC seconds
--]]
function Utils:getResetTime()
	local currentDate = os.date("!*t")
	local resetTime = os.time({year=currentDate.year, month=currentDate.month, day=currentDate.day,
		hour=6, minute=0, second=0, isdst=currentDate.isdst})
	local currentTime = os.time(currentDate)
	
	-- if reset time has already happened today, increment to tomorrow's reset time
	if resetTime < currentTime then
		resetTime = resetTime + 86400
	end
	
	return resetTime
end

--[[
	If the string starts with any of the given prefixes, remove that prefix.
	e.g.
	
	stripPrefixes("foo_hello", {"foo", "bar"}) returns "_hello"
--]]
function Utils:stripPrefixes(string, prefixes)
	for _, prefix in ipairs(prefixes) do
		if string:sub(1, #prefix) == prefix then
			return string:sub(#prefix + 1, #string)
		end
	end
	
	return string
end
