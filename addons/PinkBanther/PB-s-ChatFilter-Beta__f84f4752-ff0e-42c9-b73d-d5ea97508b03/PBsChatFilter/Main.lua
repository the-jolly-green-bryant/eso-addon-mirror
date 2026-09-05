-- PB's ChatFilter
-- Author: PinkBanther
--
-- Guild chat, from the guilds you asked for.
--
-- A player in five guilds gets five guild channels and five officer channels landing in one
-- chat window, and on console there is nothing to sort them out: no tabs, no per-category
-- filters. The client says so itself in chatdata.lua, above the block that builds the extra
-- zone channels -- "TODO: Allow these in console when we implement tabs and filters". This
-- add-on is that filter, for the guild channels and nothing else.
--
-- Every other channel is left exactly as it was. Zone, say, yell, whisper, group, emote, the
-- monster channels, every system message, every add-on's own output: the filter looks at the
-- channel, sees it is not a guild channel, and hands the message straight on. There is no
-- second code path for them to fall down.
--
-- ---------------------------------------------------------------------------------------
-- THE ONE THING IT DOES OUTSIDE GUILD CHAT: RECRUITMENT LINKS
-- ---------------------------------------------------------------------------------------
--
-- Guild recruitment is advertised in zone chat by linking the guild: the Guild Finder's
-- "Link in Chat" calls GetGuildRecruitmentLink(guildId, LINK_STYLE_BRACKETS) and submits it,
-- and it arrives in the message text as an ordinary chat link --
--
--     |H<style>:guild:<guildId>|h[Guild Name]|h
--
-- -- the same GUILD_LINK_TYPE ("guild", zo_linkhandler.lua) the client's own link handlers
-- pick out of chat. Finding that in a message is what "this is a recruitment advert" means
-- here. It is an exact test on a link the game itself puts there, not a guess about wording,
-- which is why it works in every language.
--
-- It ships OFF, and it has three exemptions, each of them there so the switch cannot cost you
-- something you wanted:
--
--   guild channels   Never touched by this rule. Your guild linking a guild is your guild
--                    talking; whether you read that channel at all is already the per-guild
--                    switch's business, and having two rules argue over the same message
--                    would only make it unpredictable.
--   whispers         Exempt unless /pbfilter recruit whisper on. Whisper recruitment is real,
--                    but a whisper is a person addressing you directly, and losing one
--                    silently is a worse outcome than reading an advert.
--   your own         Covered by keepOwn, like everywhere else.
--
-- What it cannot catch: an advert typed as plain text with no link in it. There is nothing in
-- such a message that distinguishes it from ordinary chat except its wording, and matching on
-- wording is how a filter starts eating conversations.
--
-- ---------------------------------------------------------------------------------------
-- HOW A MESSAGE IS STOPPED
-- ---------------------------------------------------------------------------------------
--
-- CHAT_ROUTER (esoui/ingame/chatsystem/chathandlers.lua) holds one message formatter per chat
-- event, and FormatAndAddChatMessage only publishes a message if that formatter returned text:
--
--     local formattedEventText, ... = messageFormatter(...)
--     if formattedEventText then
--         self:FireCallbacks("FormattedChatMessage", ...)
--     end
--
-- "FormattedChatMessage" is the one callback both chat systems listen on -- the keyboard one
-- in sharedchatsystem.lua and the gamepad one in chatmenu_gamepad.lua -- so a formatter that
-- returns nil ends the message for both. It is never added to a window, never scrolled past,
-- and never reaches the transcript.
--
-- So the whole mechanism is: read the live formatter out of
-- CHAT_ROUTER:GetRegisteredMessageFormatters(), put ours in its place through
-- RegisterMessageFormatter, and either return nil or pass the arguments to the one we
-- replaced. Both of those are public methods -- nothing here is a suspected-private call, and
-- there is no reimplementation of the client's formatting: when a message is kept, the game's
-- own formatter formats it, exactly as if this add-on were not installed.
--
-- Wrapping rather than replacing also means another add-on that wraps the same formatter --
-- before us or after us -- keeps working. Ours calls what it found; whoever wraps later calls
-- ours.
--
-- ---------------------------------------------------------------------------------------
-- WHICH GUILD A CHANNEL IS
-- ---------------------------------------------------------------------------------------
--
-- Guild channels are numbered by the player's guild INDEX, 1 to 5, not by guild id:
-- CHAT_CHANNEL_GUILD_2 is the second guild in your list, and CHAT_CHANNEL_OFFICER_2 is that
-- same guild's officer channel. chatdata.lua is the evidence -- CHAT_CHANNEL_GUILD_2 carries
-- GetGuildChannelErrorFunction(2), which looks the guild up with GetGuildId(2).
--
-- The channel-to-index table below is written out by hand instead of doing arithmetic on
-- CHAT_CHANNEL_GUILD_1. The numeric values of the ChannelType enum are not documented, and a
-- client that ever renumbers them would turn an offset calculation into silently filtering the
-- wrong guild -- the kind of bug that costs a console test round to even notice.
--
-- Settings are stored per guild ID, though, not per index. The index is a position in a list
-- that reorders itself when you join or leave a guild; the id belongs to the guild.
--
-- ---------------------------------------------------------------------------------------
-- WHAT IT DOES WHEN IT IS NOT SURE
-- ---------------------------------------------------------------------------------------
--
-- It shows the message. Every uncertainty resolves that way:
--
--   * a guild whose id cannot be read yet (guild data not loaded) -> shown
--   * a guild that has never been configured                      -> shown
--   * the master switch off                                       -> shown
--   * the formatter missing, or the chat system unavailable       -> the hook is not installed
--
-- A filter that hides too little is a filter you notice and fix. A filter that hides too much
-- loses a guild invite you were waiting for and never tells you. So a fresh install behaves
-- exactly like no add-on at all until a guild is switched off, and it can never end up hiding
-- a channel it failed to identify.
--
-- ---------------------------------------------------------------------------------------

if PBS_CHAT_FILTER then
	return
end

local addon = {
	name = "PBsChatFilter",
}

local em = EVENT_MANAGER

-- The display name is a Lua constant and the version comes from the manifest, the same way
-- PB's QuestTrackerFontChanger does it -- reading the name back out of "## Title" mangles the
-- "PB's " prefix in the settings library. Typographic apostrophe (U+2019), not ASCII '.
local DISPLAY_NAME = "PB’s ChatFilter"
local AUTHOR = "PinkBanther"
local SLASH = "/pbfilter"
local SHORT_SLASH = "/pbcf"

local MAX_GUILDS = 5

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
-- CHAT_ROUTER:AddSystemMessage goes through the "AddSystemMessage" formatter, which is a
-- different entry in the same table from the one this add-on wraps. The filter can never eat
-- its own status output, however many guilds are switched off.
--
-- A message printed at EVENT_ADD_ON_LOADED is thrown away because chat is not up yet, so
-- anything user-facing is either a command response or fires on EVENT_PLAYER_ACTIVATED.
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

addon.Line = Line
addon.Print = Print

-- ---------------------------------------------------------------------------------------
-- The guild channels
--
-- Written out rather than derived. See the header.
-- ---------------------------------------------------------------------------------------

local GUILD_CHANNELS = {}

local function DeclareChannel(channel, guildIndex, isOfficer)
	-- A client that ever drops one of these constants leaves the entry out instead of writing
	-- a nil key, and that channel is then simply never filtered.
	if type(channel) == "number" then
		GUILD_CHANNELS[channel] = { guildIndex = guildIndex, officer = isOfficer }
	end
end

DeclareChannel(CHAT_CHANNEL_GUILD_1, 1, false)
DeclareChannel(CHAT_CHANNEL_GUILD_2, 2, false)
DeclareChannel(CHAT_CHANNEL_GUILD_3, 3, false)
DeclareChannel(CHAT_CHANNEL_GUILD_4, 4, false)
DeclareChannel(CHAT_CHANNEL_GUILD_5, 5, false)
DeclareChannel(CHAT_CHANNEL_OFFICER_1, 1, true)
DeclareChannel(CHAT_CHANNEL_OFFICER_2, 2, true)
DeclareChannel(CHAT_CHANNEL_OFFICER_3, 3, true)
DeclareChannel(CHAT_CHANNEL_OFFICER_4, 4, true)
DeclareChannel(CHAT_CHANNEL_OFFICER_5, 5, true)

addon.guildChannels = GUILD_CHANNELS

-- The channels the recruitment rule leaves alone unless it is told not to. WHISPER_SENT is
-- your own outgoing whisper: it belongs with the incoming one, not with zone chat.
local WHISPER_CHANNELS = {}

local function DeclareWhisperChannel(channel)
	if type(channel) == "number" then
		WHISPER_CHANNELS[channel] = true
	end
end

DeclareWhisperChannel(CHAT_CHANNEL_WHISPER)
DeclareWhisperChannel(CHAT_CHANNEL_WHISPER_SENT)

-- ---------------------------------------------------------------------------------------
-- Guild links
--
-- The link type name comes from the client's own constant rather than being spelled out, so
-- a client that ever renames it renames this with it. "guild" is the fallback for a stripped
-- environment where the constant is missing.
--
-- Only the head of the link is matched -- |H<style>:guild: -- because that is the part whose
-- shape is fixed by ZO_LinkHandler_CreateLink. What follows it is the guild id and the
-- display text, and neither is any of this add-on's business.
-- ---------------------------------------------------------------------------------------

local GUILD_LINK_PATTERN = "|H%d+:" ..
	((type(GUILD_LINK_TYPE) == "string" and GUILD_LINK_TYPE) or "guild") .. ":"

local function ContainsGuildLink(text)
	if type(text) ~= "string" then
		return false
	end
	return text:find(GUILD_LINK_PATTERN) ~= nil
end

addon.ContainsGuildLink = ContainsGuildLink

-- ---------------------------------------------------------------------------------------
-- Settings
--
-- enabled  the master switch. Off means every guild channel passes, whatever the per-guild
--          switches say, and it is how you look at everything for a minute without losing
--          the choices you made.
--
-- keepOwn  your own messages are shown even in a guild you have switched off. Without it,
--          typing into a hidden guild channel prints nothing at all and looks like the game
--          swallowed the message. Hiding a channel is about not reading it; it should not
--          make your own guild chat feel broken.
--
-- guilds   [tostring(guildId)] = { name = "...", guild = bool, officer = bool }
--          Keyed by string because a saved-variables file round-trips string keys with no
--          argument about number formatting. name is only ever used for display, so a guild
--          you have left can still be named in the status line.
--
-- An absent entry, or an absent field, means shown. Nothing is written until a switch is
-- actually thrown, so an untouched install has an empty guilds table.
-- ---------------------------------------------------------------------------------------

local DEFAULTS = {
	enabled = true,
	keepOwn = true,
	-- The recruitment rule, and whether it reaches into whispers. Both off: the add-on's
	-- reach stops at the guild channels until you say otherwise.
	recruit = false,
	recruitWhisper = false,
	-- No login banner. It is here because a build behaving unlike its code is the hardest
	-- thing to diagnose from inside the game, and one line at EVENT_PLAYER_ACTIVATED settles
	-- which build is actually running. Off by default: /pbfilter says the same thing on
	-- demand.
	banner = false,
	guilds = {},
}

addon.DEFAULTS = DEFAULTS

-- Hidden-message counters, session only. They are the measurement that answers "is it
-- working?" without a guildmate having to be asked to say something twice.
addon.hidden = {}
addon.hiddenRecruit = 0

local function GuildKey(guildId)
	return tostring(guildId)
end

-- The guild id for a channel's guild index, or nil if it cannot be established right now.
-- Guild data is not loaded at the moment the add-on loads, and a player can be in fewer than
-- five guilds, so nil is an ordinary answer and not an error.
local function GuildIdForIndex(guildIndex)
	if type(GetNumGuilds) ~= "function" or type(GetGuildId) ~= "function" then
		return nil
	end
	if guildIndex > GetNumGuilds() then
		return nil
	end
	local guildId = GetGuildId(guildIndex)
	if not guildId or guildId == 0 then
		return nil
	end
	return guildId
end

local function GuildNameForId(guildId)
	if type(GetGuildName) == "function" then
		local name = GetGuildName(guildId)
		if name and name ~= "" then
			return name
		end
	end
	return nil
end

addon.GuildIdForIndex = GuildIdForIndex

-- The player's guilds, in channel order. Index n in this list is CHAT_CHANNEL_GUILD_n.
function addon:GuildList()
	local list = {}
	for guildIndex = 1, MAX_GUILDS do
		local guildId = GuildIdForIndex(guildIndex)
		if guildId then
			list[#list + 1] = {
				guildIndex = guildIndex,
				guildId = guildId,
				name = GuildNameForId(guildId) or ("#" .. tostring(guildId)),
			}
		end
	end
	return list
end

-- Read-only: nil for a guild that has never been configured.
function addon:GuildSettings(guildId)
	return self.sv and self.sv.guilds[GuildKey(guildId)]
end

-- Read-write: creates the entry, so only call it when a switch is actually being thrown.
function addon:GuildSettingsForWrite(guildId)
	local key = GuildKey(guildId)
	local entry = self.sv.guilds[key]
	if not entry then
		entry = { guild = true, officer = true }
		self.sv.guilds[key] = entry
	end
	entry.name = GuildNameForId(guildId) or entry.name
	return entry
end

-- The stored switch for one channel of one guild. Absent means shown.
function addon:IsChannelShown(guildId, isOfficer)
	local entry = self:GuildSettings(guildId)
	if not entry then
		return true
	end
	if isOfficer then
		return entry.officer ~= false
	end
	return entry.guild ~= false
end

function addon:SetChannelShown(guildId, isOfficer, shown)
	local entry = self:GuildSettingsForWrite(guildId)
	if isOfficer then
		entry.officer = shown and true or false
	else
		entry.guild = shown and true or false
	end
end

-- ---------------------------------------------------------------------------------------
-- Is this message mine?
--
-- Guild chat echoes back to the sender through the same channel event, so without this a
-- message you just typed into a switched-off guild would vanish along with everyone else's.
--
-- fromName is a character name in some cases and a decorated display name in others -- the
-- client's own formatter checks IsDecoratedDisplayName for exactly that reason -- so both are
-- compared, with the leading @ ignored.
-- ---------------------------------------------------------------------------------------

local function SameAccount(a, b)
	if type(a) ~= "string" or type(b) ~= "string" or a == "" or b == "" then
		return false
	end
	if a == b then
		return true
	end
	return (a:gsub("^@", "")) == (b:gsub("^@", ""))
end

local function IsFromPlayer(fromName, fromDisplayName)
	local myDisplayName = type(GetDisplayName) == "function" and GetDisplayName() or nil
	if SameAccount(fromDisplayName, myDisplayName) or SameAccount(fromName, myDisplayName) then
		return true
	end
	local myCharacterName = type(GetUnitName) == "function" and GetUnitName("player") or nil
	return SameAccount(fromName, myCharacterName)
end

addon.IsFromPlayer = IsFromPlayer

-- ---------------------------------------------------------------------------------------
-- The decision
--
-- One function, called once per chat message, and it returns true for anything that is not a
-- guild channel before it has looked at a single setting.
-- ---------------------------------------------------------------------------------------

function addon:NoteHidden(guildId, isOfficer)
	local key = GuildKey(guildId) .. (isOfficer and ":officer" or ":guild")
	self.hidden[key] = (self.hidden[key] or 0) + 1
end

function addon:HiddenCount(guildId, isOfficer)
	return self.hidden[GuildKey(guildId) .. (isOfficer and ":officer" or ":guild")] or 0
end

function addon:ShouldShow(channel, fromName, text, fromDisplayName)
	if not self.sv or not self.sv.enabled then
		return true
	end

	local channelInfo = GUILD_CHANNELS[channel]
	if channelInfo then
		-- A guild channel. The per-guild switches decide it and the recruitment rule stays out
		-- of it entirely -- see the header.
		local guildId = GuildIdForIndex(channelInfo.guildIndex)
		if not guildId then
			-- The channel says guild 3 and the client cannot yet say which guild that is.
			return true
		end

		if self:IsChannelShown(guildId, channelInfo.officer) then
			return true
		end

		if self.sv.keepOwn and IsFromPlayer(fromName, fromDisplayName) then
			return true
		end

		self:NoteHidden(guildId, channelInfo.officer)
		return false
	end

	-- Everything else. Ordered cheapest test first: the switch, then the string search, and
	-- only then the two exemptions, so a message on a quiet install is one table lookup and a
	-- boolean.
	if not self.sv.recruit then
		return true
	end

	if not ContainsGuildLink(text) then
		return true
	end

	if WHISPER_CHANNELS[channel] and not self.sv.recruitWhisper then
		return true
	end

	if self.sv.keepOwn and IsFromPlayer(fromName, fromDisplayName) then
		return true
	end

	self.hiddenRecruit = self.hiddenRecruit + 1
	return false
end

-- ---------------------------------------------------------------------------------------
-- The hook
--
-- Installed once, at load, and never taken out again. With the master switch off the wrapper
-- still runs -- it just says yes to everything and calls straight through -- which is a great
-- deal cheaper than putting a formatter in and out of CHAT_ROUTER at runtime and hoping no
-- other add-on wrapped it in between.
--
-- Two events carry guild-channel traffic:
--
--   EVENT_CHAT_MESSAGE_CHANNEL      what people say. The channel is the first argument.
--   EVENT_GUILD_KEEP_ATTACK_UPDATE  the AvA keep notices the game posts INTO a guild channel,
--                                   with no sender. They follow that guild's switch, because
--                                   a guild you have muted should not still be shouting about
--                                   a keep. The game's own setting for these lives in
--                                   Settings > Combat, and turning them off there is still the
--                                   way to be rid of them everywhere.
-- ---------------------------------------------------------------------------------------

function addon:InstallFilter()
	if self.installed then
		return true
	end

	if type(CHAT_ROUTER) ~= "table" then
		return false
	end
	if type(CHAT_ROUTER.RegisterMessageFormatter) ~= "function" then
		return false
	end
	if type(CHAT_ROUTER.GetRegisteredMessageFormatters) ~= "function" then
		return false
	end

	-- Empty on a platform where IsChatSystemAvailableForCurrentPlatform() is false: the router
	-- returns from Initialize before it registers anything. Nothing to wrap, nothing to do.
	local formatters = CHAT_ROUTER:GetRegisteredMessageFormatters()
	if type(formatters) ~= "table" then
		return false
	end

	local channelFormatter = formatters[EVENT_CHAT_MESSAGE_CHANNEL]
	if type(channelFormatter) ~= "function" then
		return false
	end

	-- Named arguments up to the ones that are read, then ... for anything a future client adds,
	-- so the pass-through stays faithful even if the signature grows.
	CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL,
		function(channel, fromName, text, isCustomerService, fromDisplayName, ...)
			if not self:ShouldShow(channel, fromName, text, fromDisplayName) then
				return nil
			end
			return channelFormatter(channel, fromName, text, isCustomerService, fromDisplayName, ...)
		end)

	local keepFormatter = formatters[EVENT_GUILD_KEEP_ATTACK_UPDATE]
	if type(keepFormatter) == "function" then
		CHAT_ROUTER:RegisterMessageFormatter(EVENT_GUILD_KEEP_ATTACK_UPDATE, function(channel, ...)
			-- No sender and no message text, so neither keepOwn nor the recruitment rule can
			-- apply: nil for all three.
			if not self:ShouldShow(channel, nil, nil, nil) then
				return nil
			end
			return keepFormatter(channel, ...)
		end)
		self.hookedKeepAttack = true
	end

	self.installed = true
	return true
end

-- ---------------------------------------------------------------------------------------
-- Status
-- ---------------------------------------------------------------------------------------

local function OnOff(value)
	return value and GetString(SI_PBSCF_ON) or GetString(SI_PBSCF_OFF)
end

function addon:PrintStatus()
	Print("%s -- %s", self.version ~= "" and self.version or "?",
		self.sv.enabled and GetString(SI_PBSCF_STATE_FILTERING) or GetString(SI_PBSCF_STATE_PASSING))

	if not self.installed then
		Print(GetString(SI_PBSCF_STATUS_NOT_INSTALLED))
	end

	Print(GetString(SI_PBSCF_STATUS_OWN), OnOff(self.sv.keepOwn))
	Print(GetString(SI_PBSCF_STATUS_RECRUIT), OnOff(self.sv.recruit), OnOff(self.sv.recruitWhisper),
		self.hiddenRecruit)

	local guilds = self:GuildList()
	if #guilds == 0 then
		Print(GetString(SI_PBSCF_STATUS_NO_GUILDS))
		return
	end

	for _, guild in ipairs(guilds) do
		local guildShown = self:IsChannelShown(guild.guildId, false)
		local officerShown = self:IsChannelShown(guild.guildId, true)
		local hiddenGuild = self:HiddenCount(guild.guildId, false)
		local hiddenOfficer = self:HiddenCount(guild.guildId, true)

		Print(GetString(SI_PBSCF_STATUS_GUILD_LINE), guild.guildIndex, guild.name,
			OnOff(guildShown), OnOff(officerShown))

		if hiddenGuild > 0 or hiddenOfficer > 0 then
			Print(GetString(SI_PBSCF_STATUS_HIDDEN_LINE), hiddenGuild, hiddenOfficer)
		end
	end
end

function addon:PrintHelp()
	Print("%s", self.title)
	for _, stringId in ipairs({
		SI_PBSCF_HELP_STATUS,
		SI_PBSCF_HELP_MASTER,
		SI_PBSCF_HELP_GUILD,
		SI_PBSCF_HELP_CHANNEL,
		SI_PBSCF_HELP_ONLY,
		SI_PBSCF_HELP_ALL,
		SI_PBSCF_HELP_NONE,
		SI_PBSCF_HELP_OWN,
		SI_PBSCF_HELP_RECRUIT,
		SI_PBSCF_HELP_RECRUIT_WHISPER,
		SI_PBSCF_HELP_BANNER,
		SI_PBSCF_HELP_RESET,
	}) do
		Line(GetString(stringId))
	end
end

-- ---------------------------------------------------------------------------------------
-- Bulk operations
--
-- These write an entry for every guild you are currently in, on purpose: "only 2" has to say
-- something about guilds 1, 3, 4 and 5, and the way it says it is by switching them off.
-- ---------------------------------------------------------------------------------------

function addon:SetAllGuilds(shown)
	for _, guild in ipairs(self:GuildList()) do
		self:SetChannelShown(guild.guildId, false, shown)
		self:SetChannelShown(guild.guildId, true, shown)
	end
end

function addon:ShowOnly(indices)
	local wanted = {}
	for _, index in ipairs(indices) do
		wanted[index] = true
	end
	for _, guild in ipairs(self:GuildList()) do
		local shown = wanted[guild.guildIndex] and true or false
		self:SetChannelShown(guild.guildId, false, shown)
		self:SetChannelShown(guild.guildId, true, shown)
	end
end

function addon:ResetSettings()
	self.sv.guilds = {}
	self.sv.enabled = DEFAULTS.enabled
	self.sv.keepOwn = DEFAULTS.keepOwn
	self.sv.recruit = DEFAULTS.recruit
	self.sv.recruitWhisper = DEFAULTS.recruitWhisper
end

-- The guild sitting at a channel index right now, or nil with a complaint already printed.
function addon:GuildAtIndex(guildIndex)
	local guildId = GuildIdForIndex(guildIndex)
	if not guildId then
		Print(GetString(SI_PBSCF_ERROR_NO_SUCH_GUILD), guildIndex)
		return nil
	end
	return guildId, GuildNameForId(guildId) or ("#" .. tostring(guildId))
end

function addon:ReportGuild(guildIndex)
	local guildId, name = self:GuildAtIndex(guildIndex)
	if not guildId then
		return
	end
	Print(GetString(SI_PBSCF_STATUS_GUILD_LINE), guildIndex, name,
		OnOff(self:IsChannelShown(guildId, false)), OnOff(self:IsChannelShown(guildId, true)))
end

-- ---------------------------------------------------------------------------------------
-- The command
--
-- Typing on a console is the expensive part, so every form is short and the bare command is
-- the status. The settings panel is the same set of switches with nothing to type.
-- ---------------------------------------------------------------------------------------

local ON_WORDS = { on = true, ["true"] = true, show = true, yes = true, ["1"] = true }
local OFF_WORDS = { off = true, ["false"] = true, hide = true, no = true, ["0"] = true }

local function ParseSwitch(word)
	if ON_WORDS[word] then
		return true
	end
	if OFF_WORDS[word] then
		return false
	end
	return nil
end

function addon:HandleCommand(argumentString)
	local words = {}
	for word in tostring(argumentString or ""):gmatch("%S+") do
		words[#words + 1] = word:lower()
	end

	local command = words[1]

	if not command or command == "status" or command == "list" then
		self:PrintStatus()
		return
	end

	if command == "help" or command == "?" then
		self:PrintHelp()
		return
	end

	if command == "reset" then
		self:ResetSettings()
		self:RefreshPanel()
		Print(GetString(SI_PBSCF_REPLY_RESET))
		return
	end

	if command == "all" then
		self:SetAllGuilds(true)
		self:RefreshPanel()
		Print(GetString(SI_PBSCF_REPLY_ALL))
		return
	end

	if command == "none" then
		self:SetAllGuilds(false)
		self:RefreshPanel()
		Print(GetString(SI_PBSCF_REPLY_NONE))
		return
	end

	if command == "only" then
		local indices = {}
		for position = 2, #words do
			local index = tonumber(words[position])
			if index and index >= 1 and index <= MAX_GUILDS then
				indices[#indices + 1] = index
			end
		end
		if #indices == 0 then
			Print(GetString(SI_PBSCF_ERROR_ONLY_NEEDS_INDEX))
			return
		end
		self:ShowOnly(indices)
		self:RefreshPanel()
		self:PrintStatus()
		return
	end

	if command == "recruit" then
		-- "recruit whisper on" reads as one thing, so the sub-word is checked before the
		-- switch rather than after it.
		if words[2] == "whisper" then
			local value = ParseSwitch(words[3] or "")
			if value == nil then
				Print(GetString(SI_PBSCF_ERROR_ON_OR_OFF))
				return
			end
			self.sv.recruitWhisper = value
		else
			local value = ParseSwitch(words[2] or "")
			if value == nil then
				Print(GetString(SI_PBSCF_ERROR_ON_OR_OFF))
				return
			end
			self.sv.recruit = value
		end
		self:RefreshPanel()
		Print(GetString(SI_PBSCF_STATUS_RECRUIT), OnOff(self.sv.recruit),
			OnOff(self.sv.recruitWhisper), self.hiddenRecruit)
		return
	end

	if command == "own" then
		local value = ParseSwitch(words[2] or "")
		if value == nil then
			Print(GetString(SI_PBSCF_ERROR_ON_OR_OFF))
			return
		end
		self.sv.keepOwn = value
		self:RefreshPanel()
		Print(GetString(SI_PBSCF_STATUS_OWN), OnOff(value))
		return
	end

	if command == "banner" then
		local value = ParseSwitch(words[2] or "")
		if value == nil then
			Print(GetString(SI_PBSCF_ERROR_ON_OR_OFF))
			return
		end
		self.sv.banner = value
		Print(GetString(SI_PBSCF_REPLY_BANNER), OnOff(value))
		return
	end

	-- The master switch. Bare "on"/"off" with no guild number in front of it.
	local masterSwitch = ParseSwitch(command)
	if masterSwitch ~= nil and not words[2] then
		self.sv.enabled = masterSwitch
		self:RefreshPanel()
		Print("%s", masterSwitch and GetString(SI_PBSCF_STATE_FILTERING) or GetString(SI_PBSCF_STATE_PASSING))
		return
	end

	-- "<n> ..." -- one guild.
	--
	-- Any whole number at all is taken as a guild number, not just 1..5, so that a typo lands
	-- on "you are not in a guild 9" instead of "no such command: 9". GuildIdForIndex refuses
	-- anything past GetNumGuilds() before the client is asked, so no out-of-range index ever
	-- reaches GetGuildId.
	local guildIndex = tonumber(command)
	if guildIndex and guildIndex >= 1 and guildIndex == math.floor(guildIndex) then
		local guildId, name = self:GuildAtIndex(guildIndex)
		if not guildId then
			return
		end

		local second = words[2]
		if not second then
			self:ReportGuild(guildIndex)
			return
		end

		-- "<n> guild on" / "<n> officer off" -- one channel of that guild.
		if second == "guild" or second == "officer" then
			local value = ParseSwitch(words[3] or "")
			if value == nil then
				Print(GetString(SI_PBSCF_ERROR_ON_OR_OFF))
				return
			end
			self:SetChannelShown(guildId, second == "officer", value)
			self:RefreshPanel()
			self:ReportGuild(guildIndex)
			return
		end

		-- "<n> on" / "<n> off" -- both of that guild's channels.
		local value = ParseSwitch(second)
		if value == nil then
			Print(GetString(SI_PBSCF_ERROR_ON_OR_OFF))
			return
		end
		self:SetChannelShown(guildId, false, value)
		self:SetChannelShown(guildId, true, value)
		self:RefreshPanel()
		self:ReportGuild(guildIndex)
		return
	end

	Print(GetString(SI_PBSCF_ERROR_UNKNOWN), command)
	self:PrintHelp()
end

function addon:InitSlashCommand()
	local handler = function(argumentString)
		self:HandleCommand(argumentString)
	end
	SLASH_COMMANDS[SLASH] = handler
	SLASH_COMMANDS[SHORT_SLASH] = handler
end

-- Settings.lua fills this in when the library is there. Defined here so every command can
-- call it without asking whether a panel exists.
function addon:RefreshPanel()
	if self.settingsControls and self.settingsControls.UpdateControls then
		self.settingsControls:UpdateControls()
	end
end

-- ---------------------------------------------------------------------------------------
-- Load
-- ---------------------------------------------------------------------------------------

local function OnPlayerActivated()
	-- The panel is built here, not at load: LibHarvensAddonSettings rows carry fixed labels,
	-- and the labels are guild names. At EVENT_ADD_ON_LOADED the guild list is not up yet, so
	-- a panel built there would be five rows called "Guild 1". Built here it names the guilds
	-- you logged in with; join or leave one and /reloadui redraws it. The chat command reads
	-- the live list and never needs redrawing.
	if not addon.panelBuilt then
		addon.panelBuilt = true
		if addon.InitSettings then
			addon:InitSettings()
		end
	end

	if addon.sv.banner then
		addon:PrintStatus()
	end
end

local function OnAddOnLoaded(_, name)
	if name ~= addon.name then
		return
	end
	em:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)

	addon.sv = ZO_SavedVars:NewAccountWide("PBsChatFilter_Data", 1, nil, DEFAULTS)

	addon:InitSlashCommand()

	-- If this fails the add-on is inert rather than broken: the command still answers, the
	-- panel still draws, and no chat is touched. /pbfilter says so on its second line.
	addon:InstallFilter()

	em:RegisterForEvent(addon.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

em:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

PBS_CHAT_FILTER = addon
