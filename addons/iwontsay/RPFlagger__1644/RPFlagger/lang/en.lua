
-- Check Behavior of GetString
local lang = {
	SI_BINDING_NAME_DISPLAY_LONGTXT = "Get long character info",

	SI_RPF_LONGTXT_NONE = "|cff8888You see nothing special on <<1>>.|r",
	SI_RPF_LONGTXT_INTRO = "|c88ffffOn <<1>> you notice something...|r\n|c88ffff<<2>>|r",
	SI_RPF_EXPLANATION1 = "To have a flag set for others in your guild to be shown, you need to enclose the text in '##RP: ##', for example, '##RP: God amongst mortals ##'. For retrieving purposes, the list in the settings below denote the order of your guilds which are scanned for the other player's flag.",
	SI_RPF_EXPLANATION2 = "Understood tags are: '##RP:', '##RP_<YourCharacterName>:', '##TXT:' and '##TXT_<YourCharacterName>' where '<YourCharacterName>' is the name of the character you want to set the specific flag for.",
	SI_RPF_EXPLANATION3 = "Texts in 'RP' replace the character's title, texts in 'TXT' are for retrieval when someone uses the keypress for looking at the long description.",
	SI_RPF_SETTINGS = "Settings",
	SI_RPF_SETTINGS_TT = "Manage general settings",
	SI_RPF_GUILDORDER = "Guild Ordering",
	SI_RPF_GUILDORDER_TT = "Determine the ordering of the guilds which are scanned for the focused target's flag",
	SI_RPF_MOVEUP = "Move entry up",
	SI_RPF_MOVEDN = "Move entry down",
}

for stringId, stringValue in pairs(lang) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end
