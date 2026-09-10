-- PB's DiceExtension
-- Author: PinkBanther
--
-- The chat window already has a random roll. On a console it is the third keybind in the chat
-- screen, and it is /roll with no arguments -- one number out of 1 to 100, every time. The
-- command itself can do more than that if you type it (/roll 3d20 is a real thing the client
-- understands), but typing "3d20" on a controller keyboard every time you want to roll is not
-- a feature anybody uses twice.
--
-- So this add-on remembers the dice instead: how many, and how many sides, up to 10 dice of up
-- to 1000 sides. Set them once, roll them from /pbdice or from the settings panel.
--
-- ---------------------------------------------------------------------------------------
-- WHY THERE ARE TWO WAYS TO ROLL, AND WHY THE DEFAULT ONE IS LOCAL
-- ---------------------------------------------------------------------------------------
--
-- The client's roll API -- RandomDiceRoll and RandomRangeRoll -- is marked *private* in
-- ESOUIDocumentation.txt, and private means unreachable from an add-on: one add-on frame
-- anywhere on the callstack taints the call, whatever is underneath it. There is no calling
-- context that rescues it, and replacing ZO_RandomRollCommand to catch the chat screen's
-- keybind would only move our frame one step further down the same stack. So this add-on
-- cannot make the game roll. Nothing can, from here.
--
-- What it can do is two things, and it does both:
--
--   1. ROLL ITS OWN DICE (the default). /pbdice, the panel's button, or R3 in the chat screen
--      -- see Keybind.lua for why the dice get a button of their own instead of a long press
--      on the game's roll button. math.random, in this Lua state, printed in your chat
--      in the client's own wording so it reads exactly like the real one. Nobody else sees
--      it, which is why every line it prints carries a quiet marker saying so -- a dice roll
--      you think your group saw and they did not is worse than no dice roll at all.
--
--   2. PUT THE REAL COMMAND IN THE CHAT BOX (optional, off by default). When the chat screen
--      opens, the text box is filled with "/roll 3d20". You press Send. The roll is then the
--      game's own -- server-side, in the group's chat, seen by everybody -- because the whole
--      callstack from the Send keybind down is the client's, with nothing of ours in it. The
--      cost is that the box is occupied when you opened chat to say something instead, which
--      is why it ships off. See Prefill.lua.
--
-- Both roll the dice you configured. Only the second one is a roll other people can see.
--
-- ---------------------------------------------------------------------------------------
-- THE LIMITS
-- ---------------------------------------------------------------------------------------
--
-- 1 to 10 dice, 2 to 1000 sides, as asked for. The client has limits of its own for the real
-- command -- RANDOM_ROLL_MAX_NUM_ROLLS and RANDOM_ROLL_MAX_RESULT -- and if ours are the wider
-- ones, the text written into the chat box is clamped to the client's, because a /roll the
-- client rejects prints an error instead of a roll. The local dice are not clamped: they are
-- ours, and 10d1000 is a perfectly good thing to want.
--
-- /pbdice probe prints both of those constants and tries the private call once, so the day
-- somebody wants to know whether this is still true, it costs one command and not a theory.
-- ---------------------------------------------------------------------------------------

if PBS_DICE then
	return
end

local addon = {
	name = "PBsDiceExtension",
	dice = {},
}

local em = EVENT_MANAGER

-- TYPOGRAPHIC apostrophe (U+2019). With an ASCII ' here the settings panel eats the whole
-- "PB's " and shows "DiceExtension". The manifest keeps the ASCII form, because that is what
-- the in-game add-on list and the store listing want. Written as the character itself and not
-- as "\u{2019}": that escape is Lua 5.3 and the client is 5.1.
local DISPLAY_NAME = "PB’s DiceExtension"
local AUTHOR = "PinkBanther"
local SLASH = "/pbdice"
-- Claimed only if it is free. /dice is the name somebody else's add-on would reasonably want
-- too, and quietly taking it from them is how two add-ons end up half-working.
local FRIENDLY_SLASH = "/dice"

local function ReadManifestVersion()
	local manager = GetAddOnManager and GetAddOnManager()
	if not manager then
		return ""
	end
	for index = 1, manager:GetNumAddOns() do
		local name, title = manager:GetAddOnInfo(index)
		if name == addon.name and title then
			local plain = title:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
			return plain:match("([%d]+[%d%.]*)%s*$") or ""
		end
	end
	return ""
end

addon.author = AUTHOR
addon.baseTitle = DISPLAY_NAME
addon.version = ReadManifestVersion()
addon.title = addon.version ~= "" and (DISPLAY_NAME .. " " .. addon.version) or DISPLAY_NAME
addon.slash = SLASH
addon.friendlySlash = FRIENDLY_SLASH

-- ---------------------------------------------------------------------------------------
-- Output
-- ---------------------------------------------------------------------------------------

local function Say(text)
	if CHAT_ROUTER and CHAT_ROUTER.AddSystemMessage then
		CHAT_ROUTER:AddSystemMessage(text)
	elseif CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
		CHAT_SYSTEM:AddMessage(text)
	else
		d(text)
	end
end

local function Line(text, ...)
	if select("#", ...) > 0 then
		local ok, formatted = pcall(string.format, text, ...)
		Say(ok and formatted or text)
	else
		Say(text)
	end
end

local PREFIX = "|cFF69B4" .. DISPLAY_NAME .. "|r: "

local function Print(text, ...)
	if select("#", ...) > 0 then
		local ok, formatted = pcall(string.format, text, ...)
		Line(PREFIX .. (ok and formatted or text))
	else
		Line(PREFIX .. text)
	end
end

addon.Say = Say
addon.Line = Line
addon.Print = Print

local function Format(stringId, ...)
	local ok, text = pcall(string.format, GetString(stringId), ...)
	return ok and text or GetString(stringId)
end

addon.Format = Format

-- ---------------------------------------------------------------------------------------
-- Settings
--
-- The shipped numbers are 1d100 on purpose: that is exactly what the chat screen's Random
-- Roll does today, so an add-on freshly installed and never configured changes nothing about
-- what a roll means. Every other value is a decision the player made.
-- ---------------------------------------------------------------------------------------

local LIMITS = {
	minCount = 1,
	maxCount = 10,
	minSides = 2,
	maxSides = 1000,
}

addon.LIMITS = LIMITS

local DEFAULTS = {
	count = 1,
	sides = 100,
	showEach = true,
	showLocalTag = true,
	chatKeybind = true,
	prefill = false,
}

addon.DEFAULTS = DEFAULTS

local function ClampInteger(value, low, high, fallback)
	value = tonumber(value)
	if not value then
		return fallback
	end
	value = math.floor(value)
	if value < low then
		return low
	elseif value > high then
		return high
	end
	return value
end

addon.ClampInteger = ClampInteger

-- The other half of the pair, and the difference between them is who is asking. A slider
-- cannot leave its own range, and a saved-variables file from an older build might: those get
-- clamped, silently, because there is nothing to tell anybody. A player who typed "count 11"
-- gets nil and an error, because clamping that to 10 and answering "dice: 10" looks for all
-- the world like 11 dice were a thing you could have.
local function ValidInteger(value, low, high)
	value = tonumber(value)
	if not value then
		return nil
	end
	value = math.floor(value)
	if value < low or value > high then
		return nil
	end
	return value
end

-- Every read clamps. Saved variables outlive the code that wrote them -- a file from a build
-- whose maximum was different, or hand-edited, must not be able to ask for 400 dice.
function addon:Count()
	return ClampInteger(self.sv and self.sv.count, LIMITS.minCount, LIMITS.maxCount, DEFAULTS.count)
end

function addon:SetCount(value)
	local valid = ValidInteger(value, LIMITS.minCount, LIMITS.maxCount)
	if not valid then
		return nil
	end
	self.sv.count = valid
	return valid
end

function addon:Sides()
	return ClampInteger(self.sv and self.sv.sides, LIMITS.minSides, LIMITS.maxSides, DEFAULTS.sides)
end

function addon:SetSides(value)
	local valid = ValidInteger(value, LIMITS.minSides, LIMITS.maxSides)
	if not valid then
		return nil
	end
	self.sv.sides = valid
	return valid
end

function addon:ShowEach()
	return self.sv and self.sv.showEach ~= false
end

function addon:SetShowEach(value)
	self.sv.showEach = value and true or false
end

function addon:ShowLocalTag()
	return self.sv and self.sv.showLocalTag ~= false
end

function addon:SetShowLocalTag(value)
	self.sv.showLocalTag = value and true or false
end

function addon:ChatKeybind()
	return self.sv and self.sv.chatKeybind ~= false
end

function addon:SetChatKeybind(value)
	self.sv.chatKeybind = value and true or false
end

function addon:Prefill()
	return self.sv and self.sv.prefill == true
end

function addon:SetPrefill(value)
	self.sv.prefill = value and true or false
end

-- ---------------------------------------------------------------------------------------
-- Rolling
-- ---------------------------------------------------------------------------------------

function addon:RollAndPrint(count, sides)
	count = count or self:Count()
	sides = sides or self:Sides()
	local result = self.dice:Roll(count, sides)
	for _, line in ipairs(self.dice:Compose(result, self:ShowEach(), self:ShowLocalTag())) do
		Say(line)
	end
	return result
end

-- ---------------------------------------------------------------------------------------
-- Commands
-- ---------------------------------------------------------------------------------------

local function Words(text)
	local words = {}
	for word in tostring(text or ""):gmatch("%S+") do
		words[#words + 1] = word
	end
	return words
end

local function OnOff(value)
	return GetString(value and SI_PBSDICE_ON or SI_PBSDICE_OFF)
end

local function ParseSwitch(word)
	word = tostring(word or ""):lower()
	if word == "on" or word == "1" or word == "true" then
		return true
	elseif word == "off" or word == "0" or word == "false" then
		return false
	end
	return nil
end

function addon:PrintStatus()
	Print(Format(SI_PBSDICE_STATUS_HEADER, self.version))
	Line("  " .. Format(SI_PBSDICE_STATUS_DICE, self:Count(), self:Sides()))
	Line("  " .. Format(SI_PBSDICE_STATUS_EACH, OnOff(self:ShowEach())))
	Line("  " .. Format(SI_PBSDICE_STATUS_TAG, OnOff(self:ShowLocalTag())))
	Line("  " .. Format(SI_PBSDICE_STATUS_KEYBIND, OnOff(self:ChatKeybind())))
	if self.chatKeybindState == self.KEYBIND_TAKEN then
		Line(GetString(SI_PBSDICE_STATUS_KEYBIND_TAKEN))
	elseif self.chatKeybindState == self.KEYBIND_UNAVAILABLE then
		Line(GetString(SI_PBSDICE_STATUS_KEYBIND_NA))
	elseif self.chatKeybindState ~= self.KEYBIND_ADDED then
		Line(GetString(SI_PBSDICE_STATUS_KEYBIND_PENDING))
	end
	Line("  " .. Format(SI_PBSDICE_STATUS_PREFILL, OnOff(self:Prefill())))
	-- Said out loud rather than left to be discovered: a checkbox that is on and does nothing
	-- is the kind of thing somebody spends an evening testing.
	if self.prefillAvailable == false then
		Line(GetString(SI_PBSDICE_STATUS_PREFILL_NA))
	end

	-- The command line is worth printing even with prefill off: it is the thing to type by
	-- hand when you want a roll the group can see, and it is already clamped to what the
	-- client will accept, so what is printed here is what would actually work.
	local command, clamped, maxCount, maxSides = self.dice:CommandText(self:Count(), self:Sides())
	Line("  " .. Format(SI_PBSDICE_STATUS_COMMAND, command))
	if clamped then
		Line("  " .. Format(SI_PBSDICE_STATUS_CLAMPED, maxCount, maxSides))
	end
end

function addon:PrintHelp()
	Print(GetString(SI_PBSDICE_HELP_HEADER))
	Line("  " .. GetString(SI_PBSDICE_HELP_ROLL))
	Line("  " .. GetString(SI_PBSDICE_HELP_SPEC))
	Line("  " .. GetString(SI_PBSDICE_HELP_COUNT))
	Line("  " .. GetString(SI_PBSDICE_HELP_SIDES))
	Line("  " .. GetString(SI_PBSDICE_HELP_EACH))
	Line("  " .. GetString(SI_PBSDICE_HELP_TAG))
	Line("  " .. GetString(SI_PBSDICE_HELP_KEYBIND))
	Line("  " .. GetString(SI_PBSDICE_HELP_PREFILL))
	Line("  " .. GetString(SI_PBSDICE_HELP_STATUS))
	Line("  " .. GetString(SI_PBSDICE_HELP_RESET))
end

-- One command, one measurement. If the client's answer here ever changes, the whole shape of
-- this add-on changes with it, so it is worth being able to ask without shipping a build.
function addon:PrintProbe()
	Print(GetString(SI_PBSDICE_PROBE_HEADER))
	Line("  " .. Format(SI_PBSDICE_PROBE_CONSTANT, "RANDOM_ROLL_MAX_NUM_ROLLS", tostring(RANDOM_ROLL_MAX_NUM_ROLLS)))
	Line("  " .. Format(SI_PBSDICE_PROBE_CONSTANT, "RANDOM_ROLL_MAX_RESULT", tostring(RANDOM_ROLL_MAX_RESULT)))
	Line("  " .. Format(SI_PBSDICE_PROBE_CONSTANT, "RANDOM_ROLL_MIN_RESULT", tostring(RANDOM_ROLL_MIN_RESULT)))
	Line("  " .. Format(SI_PBSDICE_PROBE_CONSTANT, "RandomDiceRoll", type(RandomDiceRoll)))

	if type(RandomDiceRoll) ~= "function" then
		Line("  " .. GetString(SI_PBSDICE_PROBE_MISSING))
		return
	end

	-- 1d6 with no modifier: the smallest real roll there is. If the call is allowed, this is
	-- an ordinary roll and the group sees a six-sided die, which is a fair price for knowing.
	local ok, result = pcall(RandomDiceRoll, 6, 1, 0)
	Line("  " .. Format(SI_PBSDICE_PROBE_CALL, tostring(ok), tostring(result)))
	if ok and result == RANDOM_ROLL_RESULT_SUCCESS then
		Line("  " .. GetString(SI_PBSDICE_PROBE_ALLOWED))
	else
		Line("  " .. GetString(SI_PBSDICE_PROBE_REFUSED))
	end
end

function addon:HandleCommand(argumentString)
	local words = Words(argumentString)
	local verb = (words[1] or ""):lower()

	-- Bare /pbdice rolls. That is what the add-on is for, and it is the thing that has to be
	-- one word long on a controller.
	if verb == "" or verb == "roll" then
		self:RollAndPrint()
		return
	end

	-- A spec typed straight after the command -- /pbdice 3d20 -- is a one-off. It rolls and
	-- does not touch the settings, because "roll two dice just this once" is a different
	-- sentence from "from now on I roll two dice", and only the second one is a setting.
	local count, sides, problem = self.dice:Parse(verb, self:Sides())
	if count then
		self:RollAndPrint(count, sides)
		return
	elseif problem == "count" then
		Print(Format(SI_PBSDICE_ERROR_COUNT, LIMITS.minCount, LIMITS.maxCount))
		return
	elseif problem == "sides" then
		Print(Format(SI_PBSDICE_ERROR_SIDES, LIMITS.minSides, LIMITS.maxSides))
		return
	end

	if verb == "count" or verb == "dice" or verb == "n" then
		local set = self:SetCount(words[2])
		if set then
			Print(Format(SI_PBSDICE_REPLY_COUNT, set))
		else
			Print(Format(SI_PBSDICE_ERROR_COUNT, LIMITS.minCount, LIMITS.maxCount))
		end
	elseif verb == "sides" or verb == "faces" or verb == "d" then
		local set = self:SetSides(words[2])
		if set then
			Print(Format(SI_PBSDICE_REPLY_SIDES, set))
		else
			Print(Format(SI_PBSDICE_ERROR_SIDES, LIMITS.minSides, LIMITS.maxSides))
		end
	elseif verb == "each" then
		local value = ParseSwitch(words[2])
		if value == nil then
			Print(GetString(SI_PBSDICE_ERROR_ON_OR_OFF))
		else
			self:SetShowEach(value)
			Print(Format(SI_PBSDICE_REPLY_EACH, OnOff(value)))
		end
	elseif verb == "tag" then
		local value = ParseSwitch(words[2])
		if value == nil then
			Print(GetString(SI_PBSDICE_ERROR_ON_OR_OFF))
		else
			self:SetShowLocalTag(value)
			Print(Format(SI_PBSDICE_REPLY_TAG, OnOff(value)))
		end
	elseif verb == "keybind" or verb == "r3" then
		local value = ParseSwitch(words[2])
		if value == nil then
			Print(GetString(SI_PBSDICE_ERROR_ON_OR_OFF))
		else
			self:SetChatKeybind(value)
			Print(Format(SI_PBSDICE_REPLY_KEYBIND, OnOff(value)))
		end
	elseif verb == "prefill" or verb == "chat" then
		local value = ParseSwitch(words[2])
		if value == nil then
			Print(GetString(SI_PBSDICE_ERROR_ON_OR_OFF))
		else
			self:SetPrefill(value)
			Print(Format(SI_PBSDICE_REPLY_PREFILL, OnOff(value)))
			if value then
				Line("  " .. Format(SI_PBSDICE_REPLY_PREFILL_HINT, (self.dice:CommandText(self:Count(), self:Sides()))))
			end
		end
	elseif verb == "status" then
		self:PrintStatus()
	elseif verb == "probe" then
		self:PrintProbe()
	elseif verb == "reset" then
		self:Reset()
		Print(GetString(SI_PBSDICE_REPLY_RESET))
	elseif verb == "help" or verb == "?" then
		self:PrintHelp()
	else
		Print(Format(SI_PBSDICE_ERROR_UNKNOWN, verb))
		self:PrintHelp()
	end

	if self.RefreshPanel then
		self:RefreshPanel()
	end
end

function addon:Reset()
	for key, value in pairs(DEFAULTS) do
		self.sv[key] = value
	end
end

function addon:RefreshPanel()
	if self.settingsControls and self.settingsControls.UpdateControls then
		self.settingsControls:UpdateControls()
	end
end

function addon:InitSlashCommand()
	local handler = function(argumentString)
		self:HandleCommand(argumentString)
	end
	SLASH_COMMANDS[SLASH] = handler
	if not SLASH_COMMANDS[FRIENDLY_SLASH] then
		SLASH_COMMANDS[FRIENDLY_SLASH] = handler
		self.friendlySlashTaken = false
	else
		self.friendlySlashTaken = true
	end
end

-- ---------------------------------------------------------------------------------------
-- Load
-- ---------------------------------------------------------------------------------------

local function OnPlayerActivated()
	-- Both of these want a client that has finished building itself: the settings library
	-- wants its panel list, and the prefill wants the gamepad chat scene to exist. Neither is
	-- true at EVENT_ADD_ON_LOADED, and one loading screen is not a cost anybody notices.
	if addon.wired then
		return
	end
	addon.wired = true

	if addon.InitSettings then
		addon:InitSettings()
	end
	if addon.InitChatKeybindWatch then
		-- Not InitChatKeybind: the table it wants does not exist until the chat screen is
		-- first opened. See the note at the top of Keybind.lua.
		addon:InitChatKeybindWatch()
	end
	if addon.InitPrefill then
		addon:InitPrefill()
	end
end

local function OnAddOnLoaded(_, name)
	if name ~= addon.name then
		return
	end
	em:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)

	-- Account-wide. Dice are a preference, not a property of a character: nobody wants their
	-- d20 back on 1d100 because they logged in on the crafting alt.
	addon.sv = ZO_SavedVars:NewAccountWide("PBsDiceExtension_Data", 1, nil, DEFAULTS)

	addon.dice:Init()
	addon:InitSlashCommand()

	em:RegisterForEvent(addon.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

em:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

PBS_DICE = addon
