-- PB's Omikuji
-- Author: PinkBanther
--
-- An omikuji is the paper fortune slip you draw at a Japanese shrine. You get a rank -- from
-- 大吉 (great blessing) down to 大凶 (great curse) -- and a line of advice underneath it. This
-- add-on draws one in chat when you log in, and the advice is about Tamriel.
--
-- ---------------------------------------------------------------------------------------
-- THE ONE RULE THIS ADD-ON IS BUILT AROUND
-- ---------------------------------------------------------------------------------------
--
-- A fortune that changes when you look at it is not a fortune, it is a random number. So the
-- draw is a pure function of two things and nothing else:
--
--     * which day it is, where you are sitting
--     * who is drawing
--
-- Same character, same day, same slip -- through a zone change, a /reloadui, a crash, a
-- reinstall, a lost SavedVariables file. Different character, same day: a different slip,
-- because each of your characters gets to have its own day. That is Draw.lua, and it is
-- worked out arithmetically rather than rolled, so all of it can be tested on a laptop.
--
-- ---------------------------------------------------------------------------------------
-- WHY THE DATE IS COMPUTED AND NOT ASKED FOR
-- ---------------------------------------------------------------------------------------
--
-- The client has no GetDate(). It has two clocks:
--
--     GetTimeStamp()            a UNIX timestamp, the server's clock, UTC
--     GetSecondsSinceMidnight() seconds since midnight on the machine, local time
--                               (this is what the in-game clock is drawn from)
--
-- Subtracting the second from the first gives the instant your local midnight happened, which
-- is the only thing here that deserves to be called "today". A fortune that rolls over at
-- 09:00 because the server is in another timezone would be a bug you would have to explain to
-- people, so it is worth the two lines.
--
-- The calendar date that gets printed is then worked out from that number in Lua. os.date is
-- not in the client's Lua and there is no client call that returns a day and a month, so the
-- civil-from-days arithmetic lives in Draw.lua. It is exact, and it is tested.
--
-- ---------------------------------------------------------------------------------------
-- WHAT GOES IN CHAT, AND WHEN
-- ---------------------------------------------------------------------------------------
--
-- Two lines, at the first activation of a UI session -- a login, or a /reloadui -- and never
-- at a zone change. EVENT_PLAYER_ACTIVATED fires on every loading screen; a local flag is what
-- separates the login from the eleven zone changes after it. That flag is reliable for free:
-- the Lua state is thrown away and rebuilt on every login and every /reloadui, so a local that
-- starts false is true-once-per-session by construction, with no event argument to trust.
--
-- Nothing else this add-on does writes to chat unless you asked it a question.
--
-- ---------------------------------------------------------------------------------------
-- LANGUAGE
-- ---------------------------------------------------------------------------------------
--
-- The 365 fortunes are Japanese, and so are the rank names. That is not an oversight: an
-- omikuji in English is a different object, and 大吉 is not "Great Blessing", it is 大吉. The
-- chrome around them -- the settings panel, the slash command, the errors -- is in the string
-- table and translated the usual way, so a Japanese client gets a Japanese panel.
--
-- Adding a second language of fortunes means adding a parallel table to Fortunes.lua and
-- picking between them at load; the index arithmetic does not care what the strings say.
-- ---------------------------------------------------------------------------------------

if PBS_OMIKUJI then
	return
end

local addon = {
	name = "PBsOmikuji",
	draw = {},
}

local em = EVENT_MANAGER

-- TYPOGRAPHIC apostrophe (U+2019). With an ASCII ' here the settings panel eats the whole
-- "PB's " and shows "Omikuji". The manifest keeps the ASCII form, because that is what the
-- in-game add-on list and the store listing want. Written as the character itself and not as
-- "\u{2019}": that escape is Lua 5.3 and the client is 5.1.
local DISPLAY_NAME = "PB’s Omikuji"
local AUTHOR = "PinkBanther"
local SLASH = "/omikuji"
local SHORT_SLASH = "/pbomi"

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
addon.shortSlash = SHORT_SLASH

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
-- Who is drawing
--
-- CHARACTER is the default because the fun of an omikuji is that it is yours: your main can
-- have 大吉 while the alt you log in to do writs on has 大凶, and both are true all day.
-- ACCOUNT is for people who want one fortune for the day and are annoyed by eight.
-- ---------------------------------------------------------------------------------------

addon.SCOPES = {
	{ token = "CHARACTER", label = "SI_PBSOMI_SCOPE_CHARACTER" },
	{ token = "ACCOUNT", label = "SI_PBSOMI_SCOPE_ACCOUNT" },
}

local SCOPE_VALID = {}
for _, scope in ipairs(addon.SCOPES) do
	SCOPE_VALID[scope.token] = true
end
addon.SCOPE_VALID = SCOPE_VALID

-- ---------------------------------------------------------------------------------------
-- Settings
--
-- "records" is not a setting, it is the memory: what was drawn, keyed by whoever drew it. It
-- is kept so that the line can say "you have already seen this today" rather than silently
-- printing the same thing twice, and so that oncePerDay has something to check. Losing it
-- costs nothing -- the draw is recomputed from the date and the name and comes out the same.
-- ---------------------------------------------------------------------------------------

local DEFAULTS = {
	enabled = true,
	scope = "CHARACTER",
	oncePerDay = false,
	showDate = true,
	records = {},
}

addon.DEFAULTS = DEFAULTS

function addon:Enabled()
	return self.sv and self.sv.enabled ~= false
end

function addon:SetEnabled(value)
	self.sv.enabled = value and true or false
end

function addon:Scope()
	local scope = self.sv and self.sv.scope
	return SCOPE_VALID[scope] and scope or DEFAULTS.scope
end

function addon:SetScope(token)
	if SCOPE_VALID[token] then
		self.sv.scope = token
		return true
	end
	return false
end

function addon:OncePerDay()
	return self.sv and self.sv.oncePerDay == true
end

function addon:SetOncePerDay(value)
	self.sv.oncePerDay = value and true or false
end

function addon:ShowDate()
	return self.sv and self.sv.showDate ~= false
end

function addon:SetShowDate(value)
	self.sv.showDate = value and true or false
end

function addon:ScopeLabel()
	for _, scope in ipairs(self.SCOPES) do
		if scope.token == self:Scope() then
			return GetString(_G[scope.label])
		end
	end
	return self:Scope()
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
	return GetString(value and SI_PBSOMI_ON or SI_PBSOMI_OFF)
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

function addon:PrintFortune(force)
	local slip = self.draw:Today()
	if not slip then
		Print(GetString(SI_PBSOMI_ERROR_NO_DATA))
		return false
	end
	-- oncePerDay is the only reason the record exists, and force is every route that came
	-- from somebody typing or clicking -- those are answers to a question and are never
	-- suppressed.
	if not force and self:OncePerDay() and self.draw:SeenToday(slip) then
		return false
	end
	self.draw:Record(slip)
	for _, line in ipairs(self.draw:Compose(slip)) do
		Say(line)
	end
	return true
end

function addon:PrintStatus()
	local slip = self.draw:Today()
	Print(GetString(SI_PBSOMI_STATUS_HEADER))
	Line("  " .. Format(SI_PBSOMI_STATUS_ENABLED, OnOff(self:Enabled())))
	Line("  " .. Format(SI_PBSOMI_STATUS_SCOPE, self:ScopeLabel()))
	Line("  " .. Format(SI_PBSOMI_STATUS_ONCE, OnOff(self:OncePerDay())))
	Line("  " .. Format(SI_PBSOMI_STATUS_TOTAL, self.draw:PatternCount()))
	if slip then
		Line("  " .. Format(SI_PBSOMI_STATUS_TODAY, slip.index, self.draw:PatternCount()))
	end
end

function addon:PrintRanks()
	Print(GetString(SI_PBSOMI_RANKS_HEADER))
	for _, rank in ipairs(self.RANKS) do
		Line(string.format("  |c%s%s|r  %s",
			rank.colour, rank.name, Format(SI_PBSOMI_RANKS_COUNT, #self.MESSAGES[rank.key])))
	end
end

function addon:PrintHelp()
	Print(GetString(SI_PBSOMI_HELP_HEADER))
	Line("  " .. GetString(SI_PBSOMI_HELP_DRAW))
	Line("  " .. GetString(SI_PBSOMI_HELP_STATUS))
	Line("  " .. GetString(SI_PBSOMI_HELP_SCOPE))
	Line("  " .. GetString(SI_PBSOMI_HELP_ONCE))
	Line("  " .. GetString(SI_PBSOMI_HELP_DATE))
	Line("  " .. GetString(SI_PBSOMI_HELP_RANKS))
	Line("  " .. GetString(SI_PBSOMI_HELP_MASTER))
	Line("  " .. GetString(SI_PBSOMI_HELP_RESET))
end

function addon:HandleCommand(argumentString)
	local words = Words(argumentString)
	local verb = (words[1] or ""):lower()

	-- Bare /omikuji is the common case and it is the whole point of the add-on: say today's
	-- fortune again, whatever the oncePerDay setting is. Somebody who typed the command asked.
	if verb == "" then
		self:PrintFortune(true)
		return
	end

	if verb == "status" then
		self:PrintStatus()
	elseif verb == "ranks" or verb == "list" then
		self:PrintRanks()
	elseif verb == "scope" then
		local token = (words[2] or ""):upper()
		if self:SetScope(token) then
			Print(Format(SI_PBSOMI_REPLY_SCOPE, self:ScopeLabel()))
			self:PrintFortune(true)
		else
			Print(GetString(SI_PBSOMI_ERROR_SCOPE))
		end
	elseif verb == "once" then
		local value = ParseSwitch(words[2])
		if value == nil then
			Print(GetString(SI_PBSOMI_ERROR_ON_OR_OFF))
		else
			self:SetOncePerDay(value)
			Print(Format(SI_PBSOMI_REPLY_ONCE, OnOff(value)))
		end
	elseif verb == "date" then
		local value = ParseSwitch(words[2])
		if value == nil then
			Print(GetString(SI_PBSOMI_ERROR_ON_OR_OFF))
		else
			self:SetShowDate(value)
			Print(Format(SI_PBSOMI_REPLY_DATE, OnOff(value)))
		end
	elseif verb == "on" or verb == "off" then
		self:SetEnabled(verb == "on")
		Print(Format(SI_PBSOMI_REPLY_MASTER, OnOff(self:Enabled())))
	elseif verb == "reset" then
		self:Reset()
		Print(GetString(SI_PBSOMI_REPLY_RESET))
	elseif verb == "help" or verb == "?" then
		self:PrintHelp()
	else
		Print(Format(SI_PBSOMI_ERROR_UNKNOWN, verb))
		self:PrintHelp()
	end

	if self.RefreshPanel then
		self:RefreshPanel()
	end
end

function addon:Reset()
	for key, value in pairs(DEFAULTS) do
		if type(value) == "table" then
			self.sv[key] = {}
		else
			self.sv[key] = value
		end
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
	SLASH_COMMANDS[SHORT_SLASH] = handler
end

-- ---------------------------------------------------------------------------------------
-- Load
-- ---------------------------------------------------------------------------------------

-- A fresh Lua state per login and per /reloadui is what makes this reliable: false here means
-- "no activation has happened in this UI session yet", which is exactly the login the fortune
-- belongs to. A zone change is any activation after it, and gets nothing.
local firstActivationDone = false

local function OnPlayerActivated()
	if not addon.panelBuilt then
		addon.panelBuilt = true
		if addon.InitSettings then
			addon:InitSettings()
		end
	end

	if firstActivationDone then
		return
	end
	firstActivationDone = true

	if addon:Enabled() then
		addon:PrintFortune(false)
	end
end

local function OnAddOnLoaded(_, name)
	if name ~= addon.name then
		return
	end
	em:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)

	-- Account-wide, and the per-character part is a key inside it rather than a separate
	-- profile. One file, settings shared, and "what did this character draw today" is a lookup
	-- rather than a second saved-variables object that only exists to hold two numbers.
	addon.sv = ZO_SavedVars:NewAccountWide("PBsOmikuji_Data", 1, nil, DEFAULTS)
	if type(addon.sv.records) ~= "table" then
		addon.sv.records = {}
	end

	addon:InitSlashCommand()
	addon.draw:Init()

	em:RegisterForEvent(addon.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

em:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

PBS_OMIKUJI = addon
