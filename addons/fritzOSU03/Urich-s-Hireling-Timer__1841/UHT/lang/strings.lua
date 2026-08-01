local strings = {
	UHT_MAIL_SUBJECT_BS =		"Raw Blacksmith Materials",
	UHT_MAIL_SUBJECT_CL =		"Raw Clothier Materials",
	UHT_MAIL_SUBJECT_WW =		"Raw Woodworker Materials",
	UHT_MAIL_SUBJECT_EN =		"Raw Enchanter Materials",
	UHT_MAIL_SUBJECT_PV =		"Raw Provisioner Materials",
	UHT_SKILL_LINE_NAME_BS =	"Blacksmithing",
	UHT_SKILL_LINE_NAME_CL =	"Clothing",
	UHT_SKILL_LINE_NAME_WW =	"Woodworking",
	UHT_SKILL_LINE_NAME_EN =	"Enchanting",
	UHT_SKILL_LINE_NAME_PV =	"Provisioning",
	UHT_ABILITY_NAME_BS =		"Miner Hireling",
	UHT_ABILITY_NAME_CL =		"Outfitter Hireling",
	UHT_ABILITY_NAME_WW =		"Lumberjack Hireling",
	UHT_ABILITY_NAME_EN =		"Hireling",
	UHT_ABILITY_NAME_PV =		"Hireling",
	
	UHT_MSG_BAD_SLASH =			"Urich's Hireling Timer invalid command.",
	UHT_MSG_CMD_TITLE =			"UHT slash commands:",
	
	UHT_MSG_CMD_OPTION_1 =		"    /uht - %s the addon window. This can be keybound.",
	UHT_MSG_SHOW =				"Show",
	UHT_MSG_HIDE =				"Hide",
	
	UHT_MSG_CMD_OPTION_2 =		"    /uht bs - Show the elapsed time since your last blacksmithing hireling mail.",
	UHT_MSG_CMD_OPTION_3 =		"    /uht cl - Show the elapsed time since your last clothing hireling mail.",
	UHT_MSG_CMD_OPTION_4 =		"    /uht ww - Show the elapsed time since your last woodworking hireling mail.",
	UHT_MSG_CMD_OPTION_5 =		"    /uht en - Show the elapsed time since your last enchanting hireling mail.",
	UHT_MSG_CMD_OPTION_6 =		"    /uht pv - Show the elapsed time since your last provisioning hireling mail.",
	UHT_MSG_CMD_OPTION_7 =		"    /uht all - Show the elapsed time since your last mail from all hirelings.",
	UHT_MSG_CMD_OPTION_8 =		"    /uht help - Show all available slash commands for UHT.",
	
	UHT_MSG_HACK =				"I see you've been hacking my code. There's nothing to see here! Move along.",
	
	UHT_GUI_TITLE =				"Urich's Hireling Timer",
	UHT_GUI_CHAR_NAME =			"Character",
	
	UHT_MSG_LAST_BS =			"Last BS",
	UHT_MSG_NEXT_BS =			"Next BS",
	UHT_MSG_LAST_CL =			"Last CL",
	UHT_MSG_NEXT_CL =			"Next CL",
	UHT_MSG_LAST_WW =			"Last WW",
	UHT_MSG_NEXT_WW =			"Next WW",
	UHT_MSG_LAST_EN =			"Last EN",
	UHT_MSG_NEXT_EN =			"Next EN",
	UHT_MSG_LAST_PV =			"Last PV",
	UHT_MSG_NEXT_PV =			"Next PV",
	
	UHT_MSG_INIT =				"Running UHT for the first time!",
	UHT_MSG_HELP =				"UHT Activated!",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
