local strings = {
	-- ---- Settings panel ---------------------------------------------------------------
	SI_PBSCF_EXPLANATION = "Five guilds mean five guild channels and five officer channels arriving in the same chat window, and on console there are no tabs to sort them into. Switch off the ones you do not want to read. Only guild channels are affected -- zone, say, yell, whisper, group, emote and every system message are left exactly as they were.",

	SI_PBSCF_ENABLED = "Filter guild chat",
	SI_PBSCF_ENABLED_TOOLTIP = "The master switch. Turn it off to see every guild channel again for a while without losing the choices below.",

	SI_PBSCF_KEEP_OWN = "Always show my own messages",
	SI_PBSCF_KEEP_OWN_TOOLTIP = "Your own guild messages are shown even in a guild you have switched off. Without this, typing into a hidden guild channel prints nothing at all and looks as though the message was never sent.",

	SI_PBSCF_SECTION_GUILDS = "Your guilds",
	SI_PBSCF_NO_GUILDS_NOTE = "You were not in any guild when you logged in, so there is nothing to list here. Join a guild and reload the UI.",

	SI_PBSCF_GUILD_HEADING = "%d. %s",
	SI_PBSCF_ROW_GUILD = "Guild chat",
	SI_PBSCF_ROW_GUILD_TOOLTIP = "Show this guild's ordinary chat in the chat window.",
	SI_PBSCF_ROW_OFFICER = "Officer chat",
	SI_PBSCF_ROW_OFFICER_TOOLTIP = "Show this guild's officer chat. It is a separate channel and gets its own switch, so you can follow the officer channel of a guild whose main chat you have muted, or the other way round.",

	SI_PBSCF_SECTION_RECRUIT = "Guild recruitment",
	SI_PBSCF_SECTION_RECRUIT_NOTE = "Guilds advertise by linking themselves in zone chat -- the Guild Finder's \"Link in Chat\" puts a guild link in the message. This spots that link, which is an exact test on something the game itself put there rather than a guess about wording, so it works whatever language the advert is written in. An advert typed as plain text with no link in it cannot be told apart from ordinary chat and is not affected.",

	SI_PBSCF_RECRUIT = "Hide messages that link a guild",
	SI_PBSCF_RECRUIT_TOOLTIP = "Applies to zone, say, yell and the rest -- not to guild channels. A guild link in your own guild's chat is your guild talking, and whether you read that channel at all is already decided above.",
	SI_PBSCF_RECRUIT_WHISPER = "Including whispers",
	SI_PBSCF_RECRUIT_WHISPER_TOOLTIP = "Whisper recruitment is real, but a whisper is a person addressing you directly and losing one silently is worse than reading an advert. So whispers are left alone unless you ask for this.",

	SI_PBSCF_SECTION_GENERAL = "General",
	SI_PBSCF_RESET = "Show everything again",
	SI_PBSCF_RESET_TOOLTIP = "Clears every choice on this panel and puts the chat window back the way it is without the add-on.",
	SI_PBSCF_RESET_BUTTON = "Reset",
	SI_PBSCF_RELOAD_HINT = "This list is the guilds you had when you logged in. Join or leave one and reload the UI to redraw it -- the chat command /pbfilter always reads the current list.",

	-- ---- Status -----------------------------------------------------------------------
	SI_PBSCF_ON = "on",
	SI_PBSCF_OFF = "off",
	SI_PBSCF_STATE_FILTERING = "filtering guild chat",
	SI_PBSCF_STATE_PASSING = "off, every channel passing",
	SI_PBSCF_STATUS_NOT_INSTALLED = "the chat hook is NOT installed -- no chat is being touched",
	SI_PBSCF_STATUS_OWN = "own messages always shown: %s",
	SI_PBSCF_STATUS_RECRUIT = "guild recruitment links: %s (in whispers %s) -- hidden this session: %d",
	SI_PBSCF_STATUS_NO_GUILDS = "you are not in any guild",
	SI_PBSCF_STATUS_GUILD_LINE = "%d. %s -- guild %s, officer %s",
	SI_PBSCF_STATUS_HIDDEN_LINE = "     hidden this session: %d guild, %d officer",

	-- ---- Command replies --------------------------------------------------------------
	SI_PBSCF_REPLY_RESET = "every guild shown again",
	SI_PBSCF_REPLY_ALL = "every guild shown",
	SI_PBSCF_REPLY_NONE = "every guild hidden",
	SI_PBSCF_REPLY_BANNER = "login banner %s",

	SI_PBSCF_ERROR_NO_SUCH_GUILD = "you are not in a guild %d",
	SI_PBSCF_ERROR_ONLY_NEEDS_INDEX = "only needs at least one guild number, e.g. /pbfilter only 1 3",
	SI_PBSCF_ERROR_ON_OR_OFF = "say on or off",
	SI_PBSCF_ERROR_UNKNOWN = "no such command: %s",

	-- ---- Help -------------------------------------------------------------------------
	SI_PBSCF_HELP_STATUS = "/pbfilter -- which guild is shown, and how much has been hidden",
	SI_PBSCF_HELP_MASTER = "/pbfilter on | off -- the master switch",
	SI_PBSCF_HELP_GUILD = "/pbfilter <n> on | off -- guild n, both its channels",
	SI_PBSCF_HELP_CHANNEL = "/pbfilter <n> guild | officer  on | off -- one channel of guild n",
	SI_PBSCF_HELP_ONLY = "/pbfilter only <n> [<n> ...] -- show these guilds and hide the rest",
	SI_PBSCF_HELP_ALL = "/pbfilter all -- show every guild",
	SI_PBSCF_HELP_NONE = "/pbfilter none -- hide every guild",
	SI_PBSCF_HELP_OWN = "/pbfilter own on | off -- always show your own messages",
	SI_PBSCF_HELP_RECRUIT = "/pbfilter recruit on | off -- hide messages that link a guild",
	SI_PBSCF_HELP_RECRUIT_WHISPER = "/pbfilter recruit whisper on | off -- and in whispers too",
	SI_PBSCF_HELP_BANNER = "/pbfilter banner on | off -- print the status at login",
	SI_PBSCF_HELP_RESET = "/pbfilter reset -- forget every choice",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
