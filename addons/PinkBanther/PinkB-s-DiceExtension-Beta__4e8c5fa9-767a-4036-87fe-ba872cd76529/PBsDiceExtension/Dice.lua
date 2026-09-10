-- PB's DiceExtension -- the dice themselves
--
-- Everything in this file is arithmetic and string building, which is the point: it is the
-- part that decides what a roll is, and it can all be checked on a laptop instead of on a
-- console (see test/run.lua). Nothing in here touches a control, a scene or the client's roll
-- API -- Prefill.lua is where the one contact with the client's UI lives.
--
-- PBS_DICE is nil if Main.lua bailed out early (e.g. already loaded).
if not PBS_DICE then
	return
end

local addon = PBS_DICE
local dice = addon.dice
local LIMITS = addon.LIMITS

-- The client's own icon and its own wording. Both are deliberate: a roll this add-on prints
-- should be the same object on screen as a roll the game prints, because it is describing the
-- same thing, and because SI_RANDOM_ROLL_DICE_RESULT is already translated into every
-- language the client ships -- including the pluralisation of "die/dice", which is not
-- something a string table of ours would get right for free.
--
-- zo_iconFormat is called with no dimensions on purpose: that is exactly how
-- slashcommands_shared.lua builds RANDOM_ROLL_TEXTURE, so ours renders the way the real one
-- does rather than the way we guessed it should.
local ICON_PATH = "EsoUI/Art/Miscellaneous/roll_dice.dds"

local function DiceIcon()
	if type(zo_iconFormat) == "function" then
		return zo_iconFormat(ICON_PATH)
	end
	return ""
end

local function Colorize(value)
	if ZO_SELECTED_TEXT and ZO_SELECTED_TEXT.Colorize then
		return ZO_SELECTED_TEXT:Colorize(value)
	end
	return tostring(value)
end

local function PlayerName()
	local characterName = GetUnitName and GetUnitName("player") or ""
	local displayName = GetDisplayName and GetDisplayName() or ""
	-- Honours the player's own "show account name or character name" setting, the same way
	-- every roll and every whisper in the game does.
	if type(ZO_GetPrimaryPlayerName) == "function" then
		local name = ZO_GetPrimaryPlayerName(displayName, characterName)
		if name and name ~= "" then
			return name
		end
	end
	if characterName ~= "" then
		return characterName
	end
	return displayName
end

-- ---------------------------------------------------------------------------------------
-- The random number
--
-- Lua 5.1's math.random is a deterministic sequence from a seed, and an unseeded state starts
-- from the same place every time. Seeding is therefore not a nicety here: without it the
-- first roll of every session is the same number, and that is the one bug in a dice add-on
-- that nobody forgives.
--
-- The seed mixes the wall clock (different every session), the millisecond clock (different
-- even for two clients started in the same second) and the character name (different for two
-- characters logged in at once on the same account). Then five draws are thrown away, because
-- Lua 5.1's first draw after a seed is a visible function of that seed on some platforms.
-- ---------------------------------------------------------------------------------------

local function NameHash(name)
	local hash = 0
	for index = 1, #name do
		hash = (hash * 31 + name:byte(index)) % 1000003
	end
	return hash
end

function dice:Init()
	local stamp = (GetTimeStamp and GetTimeStamp()) or 0
	local millis = (GetGameTimeMilliseconds and GetGameTimeMilliseconds()) or 0
	local seed = (stamp % 1000000) + (millis % 1000000) + NameHash(PlayerName() or "")
	math.randomseed(seed)
	for _ = 1, 5 do
		math.random()
	end
	self.seed = seed
end

-- ---------------------------------------------------------------------------------------
-- Reading a spec
--
-- Accepts what the game's own /roll accepts, minus the modifier: 3d20, d20, 3d, and a bare
-- number. A bare number is read as sides -- "/pbdice 20" is one twenty-sided die -- which
-- agrees with /roll 20 meaning a number out of 1 to 20.
--
-- The two half-written forms follow the client where the client has an answer and improve on
-- it where it does not. "d20" is one d20, because that is what d20 means everywhere and it is
-- what ZO_RandomRollCommand does with it. "3d" is three of YOUR dice, where the client would
-- have made them d6: it already knows how many sides you like, so guessing six would be
-- throwing that away.
--
-- Returns count, sides. On refusal returns nil plus which of "spec", "count", "sides" was
-- wrong, so the caller can say something more useful than "no".
-- ---------------------------------------------------------------------------------------

function dice:Parse(text, currentSides)
	text = tostring(text or ""):lower():gsub("%s+", "")
	if text == "" then
		return nil, nil, "spec"
	end

	local count, sides
	local countPart, sidesPart = text:match("^(%d*)d(%d*)$")
	if countPart then
		-- A bare "d" is not a spec, it is the word the "sides" command is spelled with. Left
		-- unguarded, "/pbdice d 20" would roll instead of setting anything.
		if countPart == "" and sidesPart == "" then
			return nil, nil, "spec"
		end
		count = tonumber(countPart) or 1
		sides = tonumber(sidesPart) or currentSides or addon.DEFAULTS.sides
	else
		local bare = text:match("^(%d+)$")
		if not bare then
			return nil, nil, "spec"
		end
		count = 1
		sides = tonumber(bare)
	end

	-- Refused rather than clamped. A player who typed 3d2000 asked for something the add-on
	-- does not do, and rolling 3d1000 without saying so would look like it worked.
	if count < LIMITS.minCount or count > LIMITS.maxCount then
		return nil, nil, "count"
	end
	if sides < LIMITS.minSides or sides > LIMITS.maxSides then
		return nil, nil, "sides"
	end

	return count, sides
end

-- ---------------------------------------------------------------------------------------
-- Rolling
-- ---------------------------------------------------------------------------------------

function dice:Roll(count, sides)
	count = addon.ClampInteger(count, LIMITS.minCount, LIMITS.maxCount, addon.DEFAULTS.count)
	sides = addon.ClampInteger(sides, LIMITS.minSides, LIMITS.maxSides, addon.DEFAULTS.sides)

	local rolls = {}
	local total = 0
	for index = 1, count do
		local value = math.random(1, sides)
		rolls[index] = value
		total = total + value
	end

	return {
		count = count,
		sides = sides,
		rolls = rolls,
		total = total,
	}
end

-- ---------------------------------------------------------------------------------------
-- Saying what was rolled
--
-- Line one is the client's own sentence, so it matches a real roll word for word. Line two is
-- the part a real roll cannot show: with 3d20 the total is the only number the game reports,
-- and the three numbers behind it are usually the interesting ones.
-- ---------------------------------------------------------------------------------------

local function ResultSentence(result)
	local name = PlayerName()
	local total = Colorize(result.total)
	local count = Colorize(result.count)
	local sides = Colorize(result.sides)

	if type(zo_strformat) == "function" and SI_RANDOM_ROLL_DICE_RESULT then
		return zo_strformat(SI_RANDOM_ROLL_DICE_RESULT, name, total, count, sides)
	end
	-- Only reached if the client stops shipping that string, which would mean the roll it
	-- describes has changed shape too. Our own wording keeps the line readable until then.
	return addon.Format(SI_PBSDICE_RESULT_FALLBACK, name, total, count, sides)
end

function dice:Compose(result, showEach, showLocalTag)
	local lines = {}

	local sentence = ResultSentence(result)
	if showLocalTag then
		sentence = sentence .. GetString(SI_PBSDICE_LOCAL_TAG)
	end
	lines[1] = string.format("%s %s", DiceIcon(), sentence)

	-- One die is its own breakdown, so there is nothing to add.
	if showEach and result.count > 1 then
		local parts = {}
		for index, value in ipairs(result.rolls) do
			parts[index] = tostring(value)
		end
		lines[2] = "  " .. addon.Format(SI_PBSDICE_BREAKDOWN,
			table.concat(parts, " + "), tostring(result.total))
	end

	return lines
end

-- ---------------------------------------------------------------------------------------
-- The real command
--
-- What to type -- or what Prefill.lua puts in the chat box -- to have the game roll these
-- dice itself. Clamped to the client's limits and not ours: a /roll the client refuses prints
-- an error where a roll should have been, and the player would have no idea why.
--
-- The command word comes out of the string table rather than being written "/roll" here,
-- because it is a translated string. Every client ships /roll today; that is not a promise.
-- ---------------------------------------------------------------------------------------

function dice:CommandText(count, sides)
	local maxCount = tonumber(RANDOM_ROLL_MAX_NUM_ROLLS) or LIMITS.maxCount
	local maxSides = tonumber(RANDOM_ROLL_MAX_RESULT) or LIMITS.maxSides

	local useCount = count > maxCount and maxCount or count
	local useSides = sides > maxSides and maxSides or sides

	local command = SI_SLASH_ROLL and GetString(SI_SLASH_ROLL) or ""
	if command == "" then
		command = "/roll"
	end

	return string.format("%s %dd%d", command, useCount, useSides),
		(useCount ~= count or useSides ~= sides),
		maxCount,
		maxSides
end
