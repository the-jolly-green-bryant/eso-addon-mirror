-- PB's MailerExtension
-- Author: PinkBanther
--
-- The mail window has two boxes: the one letters arrive in, and the page you write on. This
-- add-on adds the two that are missing -- a drafts box now, a record of what you have sent
-- next -- and puts them in the same window rather than in one of its own.
--
-- ---------------------------------------------------------------------------------------
-- WHAT THE CLIENT WILL AND WILL NOT GIVE US
-- ---------------------------------------------------------------------------------------
--
-- Read from the mail API (ESOUIDocumentation, API 101050) before a line of this was written,
-- because the two boxes are not the same kind of problem at all:
--
--   * DRAFTS are entirely ours. Nothing about an unfinished letter has ever been near the
--     server, so there is nothing to ask for and nothing to be out of step with. We keep the
--     text, and we keep enough about each attached item to find it again.
--
--     The client already does exactly this, for the length of one screen change:
--     ZO_MailSend_Shared.SavePendingMail / RestorePendingMail take the queued attachments
--     off, remember bagId + slotIndex + itemInstanceId + stack, and put them back if the
--     slot still holds the same thing. This add-on is that idea, written to disk, with a
--     wider search for the item when the slot has moved.
--
--   * SENT MAIL does not exist as far as the API is concerned. Every mail function --
--     GetMailIdByIndex, GetMailItemInfo, ReadMail, GetAttachedItemInfo -- reads the INBOX.
--     There is no call that returns a copy of something you sent, because the server does
--     not keep one. So a sent box can only ever be a log this add-on writes at the moment
--     of sending, and it will only ever hold what was sent with the add-on installed. That
--     is worth saying out loud in the description rather than letting somebody discover it.
--
-- ---------------------------------------------------------------------------------------
-- WHAT THIS ADD-ON WILL NOT DO
-- ---------------------------------------------------------------------------------------
--
-- It does not call SendMail. Not from a draft, not from a command, not ever.
--
-- Two reasons, and the second is the one that matters. First, add-on Lua is insecure code:
-- a restricted function is unreachable from every calling context, so a design that leans on
-- one is a design that fails at the last step. SendMail carries no marker in the API dump,
-- but that dump has been wrong before, and finding out costs a whole test session.
--
-- Second, and regardless: sending is the irreversible act in this window. Gold and items
-- leave, and a wrong addressee is a wrong addressee. Restoring a draft fills the page in
-- front of you; you read it and press Send yourself, exactly as you do now.
-- ---------------------------------------------------------------------------------------

if PBS_MAILER_EXTENSION then
	return
end

local addon = {
	name = "PBsMailerExtension",
}

local em = EVENT_MANAGER

-- The display name is a Lua constant and the version comes from the manifest, the same way
-- every other PB's add-on does it.
--
-- TYPOGRAPHIC apostrophe (U+2019) here: with an ASCII ' the settings library eats the whole
-- "PB's " and shows "MailerExtension". The manifest keeps the ASCII form, which is what the
-- in-game add-on list wants. Written as the character itself rather than as "\u{2019}",
-- which is a Lua 5.3 escape and the client is 5.1.
local DISPLAY_NAME = "PB’s MailerExtension"
local AUTHOR = "PinkBanther"
local SLASH = "/pbmail"
local SHORT_SLASH = "/pbm"

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

-- ---------------------------------------------------------------------------------------
-- Output
--
-- Nothing is said unless it was asked for. No line at login, no line when a draft is saved
-- from a keybind rather than a command -- the window says that, not the chat window, which
-- is somebody's conversation.
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

local PREFIX = "|cFF69B4" .. DISPLAY_NAME .. "|r: "

local function Line(text, ...)
	if select("#", ...) > 0 then
		local ok, formatted = pcall(string.format, text, ...)
		Say(ok and formatted or text)
	else
		Say(text)
	end
end

local function Print(text, ...)
	if select("#", ...) > 0 then
		local ok, formatted = pcall(string.format, text, ...)
		Line(PREFIX .. (ok and formatted or text))
	else
		Line(PREFIX .. text)
	end
end

local function Format(stringId, ...)
	local ok, text = pcall(string.format, GetString(stringId), ...)
	return ok and text or GetString(stringId)
end

addon.Say = Say
addon.Line = Line
addon.Print = Print
addon.Format = Format

-- ---------------------------------------------------------------------------------------
-- Limits
--
-- Both are settings, and these are only where they start. The ceiling is the same for both
-- and is a wall against a saved-variables file that grows for ever, not a judgement about how
-- many letters anybody needs: a thousand letters of text is still a small file, and a thousand
-- letters back is further than anybody looks.
--
-- The two start in different places because they fill at different rates. Drafts are put there
-- one at a time on purpose; the sent box fills by itself, so it starts with more room.
addon.DEFAULT_MAX_DRAFTS = 50
addon.DEFAULT_MAX_SENT = 100
addon.LIMIT_CEILING = 1000
addon.LIMIT_FLOOR = 1

-- What the slider moves by. A thousand stops is not a thing anybody can hit on a controller,
-- and a limit is a round number anyway; /pbmail max takes any exact figure for the cases where
-- a round one will not do.
addon.LIMIT_STEP = 10

local DEFAULTS = {
	nextId = 1,
	drafts = {},
	sent = {},
	limits = {
		drafts = 50,
		sent = 100,
	},
}

addon.DEFAULTS = DEFAULTS

addon.compose = {}

-- ---------------------------------------------------------------------------------------
-- Commands
--
-- The command route exists on its own account, not as scaffolding for a UI that has not
-- been written yet. It is the input that works identically in both interfaces, it is the
-- one proven to work on a console, and it is how anything here can be checked without a
-- screen change. The boxes in the mail window are next, and they will call the same
-- functions these commands call.
-- ---------------------------------------------------------------------------------------

local function OnOff(value)
	return GetString(value and SI_PBSMX_YES or SI_PBSMX_NO)
end

local function Words(argumentString)
	local words = {}
	for word in (argumentString or ""):gmatch("%S+") do
		words[#words + 1] = word
	end
	return words
end

function addon:PrintLimits()
	Print(Format(SI_PBSMX_LIMIT_STATUS, self.drafts:Title(), #self.drafts:All(), self.drafts:Max()))
	Print(Format(SI_PBSMX_LIMIT_STATUS, self.sent:Title(), #self.sent:All(), self.sent:Max()))
end

function addon:PrintHelp()
	Line(PREFIX .. self.title)
	Line(GetString(SI_PBSMX_HELP_SAVE))
	Line(GetString(SI_PBSMX_HELP_LIST))
	Line(GetString(SI_PBSMX_HELP_LOAD))
	Line(GetString(SI_PBSMX_HELP_DELETE))
	Line(GetString(SI_PBSMX_HELP_SENT))
	Line(GetString(SI_PBSMX_HELP_MAX))
	Line(GetString(SI_PBSMX_HELP_WHERE))
end

function addon:PrintList(box, emptyStringId)
	local all = box:All()
	if #all == 0 then
		Print(GetString(emptyStringId))
		return
	end
	Print(Format(SI_PBSMX_LIST_HEADER, box:Title(), #all, box:Max()))
	for index, entry in ipairs(all) do
		Line(string.format("  %d. %s", index, box:Describe(entry)))
	end
end

-- One place decides what a number typed at a command means, so "load 3" and "delete 3" can
-- never disagree about which letter that is.
function addon:Pick(box, word)
	local index = tonumber(word or "")
	if not index then
		return nil, GetString(SI_PBSMX_ERROR_NEED_NUMBER)
	end
	if not box:At(index) then
		return nil, Format(SI_PBSMX_ERROR_NO_SUCH, box:Noun(), index)
	end
	return index, nil
end

-- load and delete read the same for both boxes, so they are written once. Only which box is
-- meant changes, and that is decided by the caller.
function addon:BoxCommand(box, command, words, first)
	if command == "load" then
		local index, problem = self:Pick(box, words[first])
		if not index then
			Print(problem)
			return true
		end
		self.ui:RequestLoad(box, index)
		return true
	end

	if command == "delete" then
		if (words[first] or ""):lower() == "all" then
			local removed = box:DeleteAll()
			Print(Format(SI_PBSMX_DELETED_ALL, box:Title(), removed))
			return true
		end
		local index, problem = self:Pick(box, words[first])
		if not index then
			Print(problem)
			return true
		end
		local entry = box:Delete(index)
		Print(Format(SI_PBSMX_DELETED, box:Noun(), index, box:Describe(entry)))
		return true
	end

	return false
end

function addon:HandleCommand(argumentString)
	local words = Words(argumentString)
	local command = (words[1] or ""):lower()

	if command == "" or command == "help" then
		self:PrintHelp()
		return
	end

	-- Save and load go through the same code the buttons in the mail window use, so a command
	-- and a button cannot drift apart -- and so somebody who typed the command with the chat
	-- window closed still sees the answer.
	--
	-- Checked rather than assumed: a client that failed to load one file should say so once,
	-- not throw an error every time somebody types a command.
	if (command == "save" or command == "load" or command == "sent") and not self.ui then
		Print(GetString(SI_PBSMX_ERROR_NOT_LOADED))
		return
	end

	if command == "save" then
		self.ui:Save(table.concat(words, " ", 2))
		return
	end

	if command == "list" then
		self:PrintList(self.drafts, SI_PBSMX_LIST_EMPTY)
		return
	end

	-- Everything about the sent box hangs off one word, so the drafts commands keep the
	-- shapes they already had and nobody has to learn a second set.
	if command == "sent" then
		local sub = (words[2] or ""):lower()
		if sub == "" or sub == "list" then
			self:PrintList(self.sent, SI_PBSMX_SENT_EMPTY)
			return
		end
		if not self:BoxCommand(self.sent, sub, words, 3) then
			Print(Format(SI_PBSMX_ERROR_UNKNOWN, sub))
			self:PrintHelp()
		end
		return
	end

	if self:BoxCommand(self.drafts, command, words, 2) then
		return
	end

	-- The panel is the comfortable way to move these, and this is the exact one -- and the
	-- only one at all on a client without the settings library.
	if command == "max" then
		local which = (words[2] or ""):lower()
		if which == "" then
			self:PrintLimits()
			return
		end

		local box = (which == "drafts" and self.drafts) or (which == "sent" and self.sent)
		if not box then
			Print(GetString(SI_PBSMX_ERROR_WHICH_BOX))
			return
		end

		local value = tonumber(words[3] or "")
		if not value then
			Print(Format(SI_PBSMX_ERROR_NEED_LIMIT, self.LIMIT_FLOOR, self.LIMIT_CEILING))
			return
		end

		local applied, over = box:SetMax(value)
		Print(Format(SI_PBSMX_LIMIT_SET, box:Title(), applied))
		if over > 0 then
			-- What happens next is not the same in the two boxes, so neither is the sentence
			-- about it: one will trim itself, the other will simply not take any more.
			Print(Format(box.rolling and SI_PBSMX_LIMIT_OVER_ROLLING or SI_PBSMX_LIMIT_OVER_KEPT,
				#box:All(), applied))
		end
		return
	end

	if command == "where" then
		Print(self.compose:Describe())
		Line("  " .. Format(SI_PBSMX_WHERE_TABS,
			OnOff(self.keyboardReady), OnOff(self.gamepadReady)))
		if self.keyboardError then
			Line("  " .. tostring(self.keyboardError))
		end
		if self.gamepadError then
			Line("  " .. tostring(self.gamepadError))
		end
		return
	end

	Print(Format(SI_PBSMX_ERROR_UNKNOWN, command))
	self:PrintHelp()
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

-- The two mail interfaces are wired up at the first activation rather than at load. Both are
-- wired, not just the one in use: the player can change interface without logging out, and
-- both sets of objects exist either way.
--
-- Guarded one at a time, and a failure in one is not allowed to take the other -- or the
-- commands -- with it. A drafts box reachable only from /pbmail is a lesser add-on; an
-- add-on that errors during someone's login is a broken one.
local function OnPlayerActivated()
	if addon.interfacesWired then
		return
	end
	addon.interfacesWired = true

	-- The recorder first: it is what makes the sent box exist at all, and it does not depend
	-- on either interface having been wired.
	if addon.sent then
		pcall(function() return addon.sent:Initialize() end)
	end

	if addon.gamepadUI then
		local ok, err = pcall(function() return addon.gamepadUI:Initialize() end)
		addon.gamepadReady = ok and err or false
		if not ok then
			addon.gamepadError = err
		end
	end

	if addon.keyboardUI then
		local ok, err = pcall(function() return addon.keyboardUI:Initialize() end)
		addon.keyboardReady = ok and err or false
		if not ok then
			addon.keyboardError = err
		end
	end

	-- Last, and allowed to fail without taking anything with it: the panel is a convenience
	-- over /pbmail max, not the way the add-on is configured.
	if addon.InitSettings then
		pcall(function() addon:InitSettings() end)
	end
end

local function OnAddOnLoaded(_, name)
	if name ~= addon.name then
		return
	end
	em:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)

	-- Account-wide: a draft is a letter you have not finished, not a possession of the
	-- character who happened to start it, and the addressee is an account name anyway.
	addon.sv = ZO_SavedVars:NewAccountWide("PBsMailerExtension_Data", 1, nil, DEFAULTS)

	addon:InitSlashCommand()

	em:RegisterForEvent(addon.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

em:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

PBS_MAILER_EXTENSION = addon
