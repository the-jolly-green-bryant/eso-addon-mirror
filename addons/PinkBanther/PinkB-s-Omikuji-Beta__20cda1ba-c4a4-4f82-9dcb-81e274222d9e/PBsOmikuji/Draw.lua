-- PB's Omikuji -- the draw
--
-- Everything that decides WHICH slip lives here. Nothing in this file rolls a die.
--
-- ---------------------------------------------------------------------------------------
-- WHY THERE IS NO RANDOM NUMBER IN AN ADD-ON THAT DRAWS FORTUNES
-- ---------------------------------------------------------------------------------------
--
-- math.random would give a different slip on every /reloadui, and a fortune you can reroll is
-- not a fortune. So the slip is a hash of (which day, who is drawing) and nothing else. The
-- consequences are all the ones you want:
--
--     * the same character sees the same slip all day, through zone changes and crashes
--     * each of your characters gets its own slip on the same day
--     * losing SavedVariables loses nothing -- the same inputs recompute the same slip
--     * the whole thing can be tested on a laptop, because there is nothing to observe
--
-- SavedVariables still records what was drawn, but only to answer "has this character already
-- seen today's?" for the oncePerDay setting. It is never the source of truth for the slip.
--
-- ---------------------------------------------------------------------------------------
-- WHICH DAY IT IS
-- ---------------------------------------------------------------------------------------
--
-- There is no GetDate() in this client -- it does not exist, in any API version. There are two
-- clocks, and they are not the same clock:
--
--     GetTimeStamp()            UNIX seconds, the server's clock, UTC
--     GetSecondsSinceMidnight() seconds since midnight on this machine, local time
--
-- The second is what the in-game clock is drawn from, so it is local wall time by definition.
-- Subtracting it from the first gives the UTC instant at which YOUR midnight happened, and
-- that is the only defensible "today" for somebody sitting in Japan playing on a server in
-- Germany. Doing it the lazy way -- floor(GetTimeStamp() / 86400) -- would roll the fortune
-- over at 09:00 JST, in the middle of an evening's play, which is exactly the bug you would
-- then have to explain to everyone who noticed.
--
-- The recovery is not a subtraction. stamp - sinceMidnight is the UTC instant of your local
-- midnight, which in Japan is three o'clock the PREVIOUS UTC afternoon -- dividing that by
-- 86400 gives yesterday. What is worked out instead is the day NUMBER directly: take the UTC
-- day, ask what timezone offset that would imply given the wall clock, and step the day up or
-- down until the implied offset is one somebody could actually live in.
--
-- Choosing the day rather than building a corrected timestamp also puts the clock drift where
-- it can do no harm. The two clocks disagree by a few seconds, and a login at 23:59:52 has a
-- UTC day one behind the local one; snapping the implied offset to the nearest quarter hour
-- (every real zone offset is a whole quarter hour) turns that disagreement into exactly the
-- day step that undoes it. Nothing is ever floor-divided near a boundary.
--
-- The band of allowed offsets is (-11h, +13h], which is a real decision and not an arbitrary
-- one. Candidate offsets are always exactly 24 hours apart, so a wall clock reading is
-- ambiguous between UTC-11 and UTC+13 -- and nothing in these two numbers can separate them:
-- the client has no timezone call, at any API version. UTC+13 is New Zealand and Tonga in
-- summer, several million people; UTC-11 is American Samoa and Niue, about fifty thousand. The
-- band is set for the larger side, which means a player at UTC-11, +13:45 or +14 sees the
-- neighbouring day's date and rolls over at the neighbouring day's midnight. That is a whole
-- day out for those zones, not an hour -- the ambiguity is total, not partial -- and the tests
-- assert it so that anyone moving the band finds out what they are trading away.
--
-- ---------------------------------------------------------------------------------------
-- WHY THE CALENDAR DATE IS DONE BY HAND
-- ---------------------------------------------------------------------------------------
--
-- The header wants to say 2026年9月10日（木）. os.date is not in the client's Lua, and no
-- client call returns a day and a month, so the day number is turned into a civil date here
-- with Howard Hinnant's days-from-civil inverse. It is exact for every date the game will ever
-- see, it is thirty lines, and test/run.lua checks it against known dates including leap days
-- and century boundaries.
--
-- PBS_OMIKUJI is nil if Main.lua bailed out early (e.g. already loaded).
if not PBS_OMIKUJI then
	return
end

local addon = PBS_OMIKUJI
local draw = addon.draw

local SECONDS_PER_DAY = 86400
local SNAP = 900
local OFFSET_MAX = 13 * 3600
local OFFSET_MIN = -11 * 3600

-- ---------------------------------------------------------------------------------------
-- The day
-- ---------------------------------------------------------------------------------------

-- Days since 1970-01-01, on your clock. This is the day half of the seed and the input to the
-- printed date, and it is the only place the two clocks are read.
function draw:DayKey()
	local stamp = GetTimeStamp and GetTimeStamp() or 0
	local sinceMidnight = GetSecondsSinceMidnight and GetSecondsSinceMidnight() or 0
	if type(stamp) ~= "number" or type(sinceMidnight) ~= "number" then
		return 0
	end

	-- If the local day were the UTC day, this is the timezone offset that would imply.
	local day = math.floor(stamp / SECONDS_PER_DAY)
	local offset = sinceMidnight - (stamp % SECONDS_PER_DAY)
	offset = math.floor(offset / SNAP + 0.5) * SNAP

	-- Stepping the day by one moves the implied offset by a whole day, and the band is exactly
	-- one day wide and half open, so exactly one step lands in it and one step is always
	-- enough. A server clock that is already local implies an offset of zero and takes neither
	-- branch, which is why the add-on does not depend on GetTimeStamp() being UTC.
	if offset <= OFFSET_MIN then
		day = day + 1
	elseif offset > OFFSET_MAX then
		day = day - 1
	end
	return day
end

-- Howard Hinnant's civil-from-days. z is days since 1970-01-01; returns year, month, day.
function draw:CivilFromDays(z)
	z = math.floor(z) + 719468
	local era = math.floor(z / 146097)
	local dayOfEra = z - era * 146097
	local yearOfEra = math.floor((dayOfEra
		- math.floor(dayOfEra / 1460)
		+ math.floor(dayOfEra / 36524)
		- math.floor(dayOfEra / 146096)) / 365)
	local year = yearOfEra + era * 400
	local dayOfYear = dayOfEra - (365 * yearOfEra
		+ math.floor(yearOfEra / 4)
		- math.floor(yearOfEra / 100))
	local monthPrime = math.floor((5 * dayOfYear + 2) / 153)
	local day = dayOfYear - math.floor((153 * monthPrime + 2) / 5) + 1
	local month = monthPrime + (monthPrime < 10 and 3 or -9)
	if month <= 2 then
		year = year + 1
	end
	return year, month, day
end

-- 1970-01-01 was a Thursday, so day 0 is index 4 counting Sunday as 0.
function draw:WeekdayIndex(dayKey)
	return (math.floor(dayKey) + 4) % 7
end

function draw:WeekdayName(dayKey)
	local names = {}
	for name in tostring(GetString(SI_PBSOMI_WEEKDAYS)):gmatch("[^,]+") do
		names[#names + 1] = name
	end
	return names[self:WeekdayIndex(dayKey) + 1] or ""
end

function draw:DateText(dayKey)
	local year, month, day = self:CivilFromDays(dayKey)
	return addon.Format(SI_PBSOMI_DATE_FORMAT, year, month, day, self:WeekdayName(dayKey))
end

-- ---------------------------------------------------------------------------------------
-- Who is drawing
--
-- The character id rather than the character name, so a rename does not hand somebody a
-- different fortune for a day they have already seen. The name is the fallback for the case
-- where the id is not up yet, which should not happen at activation but costs one line.
-- ---------------------------------------------------------------------------------------

function draw:Identity()
	if addon:Scope() == "ACCOUNT" then
		return tostring((GetDisplayName and GetDisplayName()) or "@account")
	end
	local id = GetCurrentCharacterId and GetCurrentCharacterId()
	if id and id ~= "" and id ~= 0 then
		return tostring(id)
	end
	return tostring((GetUnitName and GetUnitName("player")) or "player")
end

function draw:WhoText()
	if addon:Scope() == "ACCOUNT" then
		return tostring((GetDisplayName and GetDisplayName()) or "")
	end
	return tostring((GetUnitName and GetUnitName("player")) or "")
end

-- ---------------------------------------------------------------------------------------
-- The hash
--
-- A 24-bit LCG stepped once per input byte. 2^24 and a multiplier under 2^16 keep every
-- product below 2^53, which is where a double stops being able to hold an integer exactly --
-- the client is Lua 5.1 and has no integers and no bitwise operators, so a hash written the
-- usual 32-bit way would silently start rounding and stop being reproducible.
--
-- MULTIPLIER is 1 mod 4 and INCREMENT is odd, which is the condition for the generator to
-- have full period. The index is taken from the TOP of the value, not with a modulo: in any
-- power-of-two LCG bit k repeats every 2^(k+1) steps, so the low bits are near-worthless and a
-- modulo reads exactly those, whatever the divisor happens to factorise into. The top bits are
-- the ones with the full period, and taking the index from them is the same one line.
-- ---------------------------------------------------------------------------------------

local MODULUS = 16777216
local MULTIPLIER = 40501
local INCREMENT = 1013904223

local function Step(seed, value)
	return (seed * MULTIPLIER + value * 12347 + INCREMENT) % MODULUS
end

function draw:HashText(seed, text)
	text = tostring(text or "")
	for index = 1, #text do
		seed = Step(seed, text:byte(index))
	end
	return seed
end

function draw:HashNumber(seed, number)
	number = math.floor(number or 0)
	-- Base 251 rather than 256: a prime base spreads consecutive days across the whole state
	-- instead of only touching the bottom byte, which matters because consecutive days are the
	-- one input that is guaranteed to be nearly identical every time.
	for _ = 1, 5 do
		seed = Step(seed, number % 251)
		number = math.floor(number / 251)
	end
	return seed
end

function draw:IndexFor(dayKey, identity)
	local seed = self:HashText(0, identity)
	seed = self:HashNumber(seed, dayKey)
	-- Two more steps with nothing new in them, so that the last byte of the identity is not
	-- sitting in the high bits the index is about to be read from.
	seed = Step(Step(seed, 0), 0)
	local count = self:PatternCount()
	return math.floor(seed / MODULUS * count) + 1
end

-- ---------------------------------------------------------------------------------------
-- The slips, flattened
--
-- One list of 365, best rank first. The draw is uniform over this list rather than over the
-- seven ranks, so a rank's share of the days is its share of the lines -- see the table at
-- the top of Fortunes.lua.
-- ---------------------------------------------------------------------------------------

function draw:Init()
	if self.patterns then
		return
	end
	local patterns = {}
	for rankIndex, rank in ipairs(addon.RANKS) do
		for _, message in ipairs(addon.MESSAGES[rank.key] or {}) do
			patterns[#patterns + 1] = {
				rank = rank,
				rankIndex = rankIndex,
				message = message,
			}
		end
	end
	self.patterns = patterns
end

function draw:PatternCount()
	self:Init()
	return #self.patterns
end

function draw:PatternAt(index)
	self:Init()
	return self.patterns[index]
end

-- ---------------------------------------------------------------------------------------
-- Today's slip
--
-- Today() reads two clocks and a name and returns a slip. It writes nothing -- asking what
-- today's fortune is must not be able to change whether it counts as already seen, or
-- /omikuji status would quietly silence the next login.
--
-- Whether it has been shown is a separate question with a separate answer, and recording it
-- is a third, explicit call made only by the thing that actually put it in chat.
-- ---------------------------------------------------------------------------------------

function draw:Today()
	local dayKey = self:DayKey()
	local identity = self:Identity()
	local index = self:IndexFor(dayKey, identity)
	local pattern = self:PatternAt(index)
	if not pattern then
		return nil
	end

	return {
		index = index,
		rank = pattern.rank,
		rankIndex = pattern.rankIndex,
		message = pattern.message,
		dayKey = dayKey,
		identity = identity,
	}
end

function draw:SeenToday(slip)
	local records = addon.sv and addon.sv.records
	if type(records) ~= "table" then
		return false
	end
	local record = records[slip.identity]
	return type(record) == "table" and record.day == slip.dayKey
end

function draw:Record(slip)
	local records = addon.sv and addon.sv.records
	if type(records) == "table" then
		records[slip.identity] = { day = slip.dayKey, index = slip.index }
	end
end

-- ---------------------------------------------------------------------------------------
-- The two lines that go in chat
-- ---------------------------------------------------------------------------------------

function draw:Compose(slip)
	local lines = {}
	local who = self:WhoText()

	if addon:ShowDate() then
		lines[#lines + 1] = "|cFF69B4" .. addon.baseTitle .. "|r: "
			.. addon.Format(SI_PBSOMI_HEADER_DATED, who, self:DateText(slip.dayKey))
	else
		lines[#lines + 1] = "|cFF69B4" .. addon.baseTitle .. "|r: "
			.. addon.Format(SI_PBSOMI_HEADER_PLAIN, who)
	end

	lines[#lines + 1] = "  |c" .. slip.rank.colour
		.. addon.Format(SI_PBSOMI_FORTUNE_RANK, slip.rank.name) .. "|r "
		.. slip.message

	return lines
end
