local strings = {
	SI_CSJ_UI_PANEL_HEADER1_TEXT =					"This add-on allows you to set your favorite music theme for each chapter area. Your favorite music will be played based on the player's location.\nNote that this includes the intro music played on the title screen.", 
	SI_CSJ_UI_ACCOUNT_WIDE_OP_NAME =				"Use Account Wide Settings", 
	SI_CSJ_UI_ACCOUNT_WIDE_OP_TIPS =				"When the account wide setting is OFF, then each character can have different configuration options set below.", 
	SI_CSJ_UI_OVERRIDE_COMBAT_MUSIC_NAME =			"Override Combat Music", 
	SI_CSJ_UI_OVERRIDE_COMBAT_MUSIC_TIPS =			"When turned on this option, the jukebox music will continue even in combat. The default is off.", 
}

for stringId, stringToAdd in pairs(strings) do
	ZO_CreateStringId(stringId, stringToAdd)
	SafeAddVersion(stringId, 1)
end
