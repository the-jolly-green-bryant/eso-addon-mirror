local strings = {
	SI_AD_BLOCK_PLUS_ENABLE			= "Enabled",
	SI_AD_BLOCK_PLUS_ENABLE_TT		= "Enable/Disable AdBlock Plus",

	SI_AD_BLOCK_PLUS_NOTIFY			= "Blocked Notifications",
	SI_AD_BLOCK_PLUS_NOTIFY_TT		= "Show Blocked Notifications In Chat",

	SI_AD_BLOCK_PLUS_FRIEND			= "Friend Status Notifications",
	SI_AD_BLOCK_PLUS_FRIEND_TT		= "Show Friend Logged On/Off Notifications In Chat",	
	SI_AD_BLOCK_PLUS_FRIEND_TYPE	= "friend",
	SI_AD_BLOCK_PLUS_FRIEND_ONLINE	= "has logged on",
	SI_AD_BLOCK_PLUS_FRIEND_OFFLINE	= "has logged off",

	SI_AD_BLOCK_PLUS_AGRESSIVE 		= "Aggressive Filtering",
	SI_AD_BLOCK_PLUS_AGRESSIVE_TT	= "Enforce Stricter Checking For All Enabled Blocking Options",

	SI_AD_BLOCK_PLUS_BLOCK			= "Block",
	SI_AD_BLOCK_PLUS_BLOCKED_ADVERT	= "Blocked Advertisement",
	SI_AD_BLOCK_PLUS_BLOCKED_SINCE	= "Since Install",
	SI_AD_BLOCK_PLUS_BLOCKED_TOTAL	= "Total Blocked",

	SI_AD_BLOCK_PLUS_HEADER_BLOCKING = "Blocking",
	SI_AD_BLOCK_PLUS_HEADER_CHANNELS = "Monitored Chat Channels",
	SI_AD_BLOCK_PLUS_HEADER_ADVANCED = "Advanced",

	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET = "Filter Preset",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_TT = "Predefined Options For Blocking",

	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_1 = "Basic",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_2 = "Advanced",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_3 = "Strict",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_4 = "Full",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_5 = "Custom",

	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_TT_1 = "• Achievements, Crowns, Guilds\n• Zone Channel",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_TT_2 = "• Achievements, Crowns, Guilds, URL\n• Zone, Yell, Say Channels",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_TT_3 = "• All Blocking Options\n• Zone, Yell, Say, Guild, Channels",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_TT_4 = "• All Blocking Options\n• All Channels",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_TT_5 = "User-Defined Options",

	SI_AD_BLOCK_PLUS_HISTORY_LAST = "Last",
	SI_AD_BLOCK_PLUS_DESCRIPTION_SLASH = "Slash Commands",
	SI_AD_BLOCK_PLUS_DESCRIPTION_HISTORY = "History Window",
	SI_AD_BLOCK_PLUS_DESCRIPTION_SETTINGS = "Settings Menu",
	SI_AD_BLOCK_PLUS_WELCOME_FIRSTRUN = "Thank You For Using AdBlockPlus!"
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
