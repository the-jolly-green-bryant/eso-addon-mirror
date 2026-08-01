---------------------------------------------------------
--	ARKadium's EGN			English localization file   -
--	Written by @Carter_DC (EU) / coirier.rom1@gmail.com -
--------------------------------------------------------- 

do
	
	ARK_EGN   		= ARK_EGN or {}
	ARK_EGN.i18n 	= ARK_EGN.i18n or {}		
	local Add 		= ZO_CreateStringId

    --Settings
	Add("ARK_EGN_MENU_DESCRIPTION",					"This Addon Probably Does Not Contain Nuts.")	
	Add("ARK_EGN_MENU_GENERAL",						"GENERAL")
	Add("ARK_EGN_MENU_STARTMESSAGE",				"Start Message")	
	Add("ARK_EGN_MENU_STARTMESSAGE_TT",				"Enables or Disables the Start Message")	
	Add("ARK_EGN_MENU_DEBUGMODE",					"Debug Mode")	
	Add("ARK_EGN_MENU_DEBUGMODE_TT",				"Displays Debug Messages")	
	Add("ARK_EGN_MENU_COLOR",						"Addon's Main Color")
	Add("ARK_EGN_MENU_COLOR_TT",					"Default values : r=%d g=%d b=%d")	
	Add("ARK_EGN_MENU_MODULES",						"MODULES")	
	Add("ARK_EGN_MENU_MODULENOTES",					"Guild Notes")	
	Add("ARK_EGN_MENU_MODULENOTES_TT",				"Displays Extended Notes")	
	Add("ARK_EGN_MENU_MODULECHAT",					"Stars In Chat")	
	Add("ARK_EGN_MENU_MODULECHAT_TT",				"Converts emotes to display stars in the chat")	
	Add("ARK_EGN_MENU_MODULEGUILDHOUSE",			"GuildHouse Button")	
	Add("ARK_EGN_MENU_MODULEGUILDHOUSE_TT",			"Adds a Teleport-to-GH button in the Guild panel")	
	Add("ARK_EGN_MENU_MODULECOMBATSTATE",			"CombatState UI")	
	Add("ARK_EGN_MENU_MODULECOMBATSTATE_TT",		"Displays a combat state ui")		
	Add("ARK_EGN_MENU_MODULETESTAGE",				"Testage")	
	Add("ARK_EGN_MENU_MODULETESTAGE_TT",			"Testage")	



	--notes
   Add("ARK_EGN_PVE",            "PvE Roster")
   Add("ARK_EGN_PVP",            "PvP Roster") 
   Add("ARK_EGN_DD",             "DMG. DEALER")
   Add("ARK_EGN_HEAL",           "HEALER")
   Add("ARK_EGN_TANK",           "TANK")
   Add("ARK_EGN_MAEL",           "     Maelstrom : ")
   Add("ARK_EGN_VDSA",           "     VDSA :          ")
   Add("ARK_EGN_EMP",            "     Emperor :      ")
   Add("ARK_EGN_DUEL",           "     Duelist :         ")
	--UI
	
end
