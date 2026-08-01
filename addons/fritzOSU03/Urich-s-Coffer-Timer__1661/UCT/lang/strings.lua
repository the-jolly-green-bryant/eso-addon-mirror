local strings = {
	UCT_MSG_BAD_SLASH =		"Urich's Coffer Timer invalid command.",
	UCT_MSG_CMD_TITLE =		"UCT slash commands:",
	UCT_MSG_CMD_OPTION_1 =	"    /uct - To %s the addon. This can be keybound.",
	UCT_MSG_SHOW =			"show",
	UCT_MSG_HIDE =			"hide",
	
	UCT_MSG_CMD_OPTION_2 =	"    /uct aa - To show the elapsed time since your last %s completion.",
	UCT_MSG_CMD_OPTION_3 =	"    /uct as - To show the elapsed time since your last %s completion.",
	UCT_MSG_CMD_OPTION_4 =	"    /uct cr - To show the elapsed time since your last %s completion.",
	UCT_MSG_CMD_OPTION_5 =	"    /uct hof - To show the elapsed time since your last %s completion.",
	UCT_MSG_CMD_OPTION_6 =	"    /uct hrc - To show the elapsed time since your last %s completion.",
	UCT_MSG_CMD_OPTION_7 =	"    /uct maw - To show the elapsed time since your last %s completion.",
	UCT_MSG_CMD_OPTION_8 =	"    /uct so - To show the elapsed time since your last %s completion.",
	UCT_MSG_CMD_OPTION_9 =	"    /uct ss - To show the elapsed time since your last %s completion.",
	UCT_MSG_CMD_OPTION_10 =	"    /uct all - To show the elapsed time since your last completion of all trials.",
	
	UCT_MSG_HACK =			"I see you've been hacking my code. There's nothing to see here! Move along.",
	
	UCT_GUI_TITLE =			"Urich's Coffer Timer",
	UCT_GUI_CHAR_NAME =		"Character",
	
	UCT_MSG_LAST_AA =		"Last AA: ",
	UCT_MSG_NEXT_AA =		"Next AA: ",
	UCT_MSG_LAST_AS =		"Last AS: ",
	UCT_MSG_NEXT_AS =		"Next AS: ",
	UCT_MSG_LAST_CR =		"Last CR: ",
	UCT_MSG_NEXT_CR =		"Next CR: ",
	UCT_MSG_LAST_HOF =		"Last HoF: ",
	UCT_MSG_NEXT_HOF =		"Next HoF: ",
	UCT_MSG_LAST_HRC =		"Last HRC: ",
	UCT_MSG_NEXT_HRC =		"Next HRC: ",
	UCT_MSG_LAST_SO =		"Last SO: ",
	UCT_MSG_NEXT_SO =		"Next SO: ",
	UCT_MSG_LAST_MAW =		"Last Maw: ",
	UCT_MSG_NEXT_MAW =		"Next Maw: ",
	UCT_MSG_LAST_SS =		"Last SS: ",
	UCT_MSG_NEXT_SS =		"Next SS: ",
	
	UCT_MSG_INIT =			"Running UCT for the first time!",
	UCT_MSG_HELP =			"UCT Activated!",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
