local lang = {
	
	--In-gameUI elements
	COMINGBACKHOME_UI_COMING_BACK_TO = "Coming back to<<1>><<2>> (<<3>>)<<4>><<5>>...",
	COMINGBACKHOME_UI_WAITING_FOR_COMBAT_END = "Waiting for combat end...",
	
	
	--Settings
	COMINGBACKHOME_MENU_USE_ACCOUNTWIDE = "Use account-wide profile",
	COMINGBACKHOME_MENU_WILL_RELOADUI = "Will perform reload UI",
	COMINGBACKHOME_MENU_ALLOW_PREVIEW_HOUSES_TITLE = "Remember preview houses",
	COMINGBACKHOME_MENU_ALLOW_PREVIEW_HOUSES_POP_UP = "When 'OFF' addon will ignore empty preview houses",
	COMINGBACKHOME_MENU_ALLOW_OTHER_PLAYERS_HOUSES_TITLE = "Remember other players' houses",
	COMINGBACKHOME_MENU_ALLOW_OTHER_PLAYERS_HOUSES_POP_UP = "When 'OFF' addon will ignore other players' houses",
	COMINGBACKHOME_MENU_DONT_FORGET_TITLE = "Never forget last visited house",
	COMINGBACKHOME_MENU_DONT_FORGET_POP_UP = "When 'ON' addon will keep last visited house info",
	COMINGBACKHOME_MENU_AUTO_TELEPORTATION_TITLE = "Auto teleportation",
	COMINGBACKHOME_MENU_AUTO_TELEPORTATION_POP_UP = "Teleport automatically when left the group in a dungeon",
	COMINGBACKHOME_MENU_NOTIFICATIONS_TITLE = "Notifications",
	COMINGBACKHOME_MENU_NOTIFICATIONS_POP_UP = "Show addon notifications either on center of the screen or in a chat",
	COMINGBACKHOME_MENU_NOTIFICATIONS_OPTION1 = "Center of the screen",
	COMINGBACKHOME_MENU_NOTIFICATIONS_OPTION2 = "Chat",
	COMINGBACKHOME_MENU_NOTIFICATIONS_OPTION3 = "None",
	COMINGBACKHOME_KEYBINDING = "Port to the last visited house",
	COMINGBACKHOME_NO_HOUSE_TO_TELEPORT = "CBH: No house data saved"
}

--Create the string values, so other languages can add new versions
for stringId, stringValue in pairs(lang) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end