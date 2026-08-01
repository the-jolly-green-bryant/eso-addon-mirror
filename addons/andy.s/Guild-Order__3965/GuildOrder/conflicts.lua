-- Any addon that assumes that CHAT_CHANNEL_GUILD_1/CHAT_CHANNEL_OFFICER_1 belongs to the guild with index 1 shouldn't use the new GetGuildId() function.
-- The easiest way to solve all conflicts would be to ignore all other addons via checking debug.traceback(),
-- but I want to allow other addons' authors to add compatibility with GuildOrder (check API section in main.lua) and mark a conflict as solved from their addon.

-- AddonName => conflict callback.
-- If conflict callback returns true, then don't overwrite GetGuildId() result.
-- The only callback's argument is current debug.traceback().
-- To disable a conflict, use GuildOrder.DisableConflict(addonName). Make sure to load your addon after GuildOrder by adding "## OptionalDependsOn: GuildOrder" to addonName.txt.
-- It's also probably a good idea to disable a conflict only during addon initialization (or at least before any GetGuildId() calls).
-- To add (and enable) a new conflict, use GuildOrder.AddConflict(addonName, callback).
-- You can change GuildOrder.conflicts[addonName] directly, but it won't take effect if the conflict is disabled.
GuildOrder.conflicts = {
	-- There are plenty of places where pChat assumes (rightfully) that
	-- CHAT_CHANNEL_GUILD_1 corresponds to guild in slot 1, so let pChat show everything in default order for now.
	-- It also changes "Chat Tab Options" dialog, but it seems to be safe to give it updated GetGuildId()
	-- BUG REPORT: BuildNicknames() fails to recognize dots in @names and spaces in character names (possibly more allowed characters too)
	-- ISSUE: guild numbers are wrong when enabled in Chat Channels -> Guild Tweaks. Use GuildOrder function to get the correct number.
	pChat = function(s)
		return s:find('user:/AddOns/pChat/') and not s:find('/pChat/ChatConfig.lua')
	end,

	-- same as pChat
	rChat = function(s)
		return s:find('user:/AddOns/rChat/')
	end,

	-- LGM - Lilith's Group Manager
	-- wrong channel -> guild name in settings
	GroupManager = function(s)
		return s:find('user:/AddOns/GroupManager/')	
	end,

	-- Wrong guild -> channel map in settings
	FCOChatTabBrain = function(s)
		return s:find('user:/AddOns/FCOChatTabBrain/')	
	end,

	-- ShissuChat is bundled with 10+ other addons, so disable for all of them just to be sure
	-- I haven't installed them all, so can't guarantee they will work fine at all with GuildOrder...
	ShissuChat = function(s)
		return s:find('user:/AddOns/Shissu')	
	end,

	-- TOM - Tamriel Online Messenger
	-- same as pChat
	tom = function(s)
		return s:find('user:/AddOns/Tom/')
	end,

	-- wrong guild order in menu
	GuildChatColors = function(s)
		return s:find('user:/AddOns/GuildChatColors/')
	end,

	-- Taz's Chat Notifier
	-- The addon doesn't have guild names in settings, just "guild 1", "guild 2" sounds,
	-- so it's probably not worth adding, although it might be confusing that "guild 1" refers to the default guild with index 1 before GuildOrder changes.

	-- Auto Recruit
	-- I think it works if it's loaded after the player changed guild order, but the problem is
	-- this addon saves guild index instead of guild id, and guild index can change even without GuildOrder (e.g. when player leaves a guild).

	-- ImCallingU
	-- It probably has an issue with guild name => channel map in settings, but it's not that big
}