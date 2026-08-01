local strings = {
	SI_GROUP_SYNERGIZER_LANG 		= "en",

	SI_GROUP_SYNERGIZER_ENABLE		= "Enabled",
	SI_GROUP_SYNERGIZER_SOUND		= "Enhanced Sound",
	SI_GROUP_SYNERGIZER_SCREEN		= "Enhanced Visual",
	SI_GROUP_SYNERGIZER_ENHANCE		= "Enhanced LFG",
	SI_GROUP_SYNERGIZER_ACCEPT		= "Auto-Accept Ready Checks",
	SI_GROUP_SYNERGIZER_RELEASE		= "Auto-Release in Battlegrounds",
	--SI_GROUP_SYNERGIZER_AUTO_QUE	= "Auto-Join Que",
	SI_GROUP_SYNERGIZER_SLASH		= "Pledge/Group Slash Commands",
	SI_GROUP_SYNERGIZER_DELAY		= "Sound Notification Delay",

	SI_GROUP_SYNERGIZER_LFG_CHAT	= "Ready Check!",
	SI_GROUP_SYNERGIZER_LFG_CHAT_A	= "Auto-Accepted Ready Check!",
	SI_GROUP_SYNERGIZER_LFG_SCREEN	= "Group Ready Check!",
	
	SI_GROUP_SYNERGIZER_ENABLE_TT	= "Enable/Disable LFG Enhancer",
	SI_GROUP_SYNERGIZER_SOUND_TT	= "More Audible Sound On Ready Check",
	SI_GROUP_SYNERGIZER_SCREEN_TT	= "Better Screen Notification On Ready Check",
	SI_GROUP_SYNERGIZER_ENHANCE_TT	= "Show Daily Pledges/Quests, Auto-Accept, And Check Active Quests In Group & Activity Finder",
	SI_GROUP_SYNERGIZER_ACCEPT_TT	= "Auto-Accept 'Looking For Group' Ready Check",
	SI_GROUP_SYNERGIZER_RELEASE_TT	= "Auto-Release On Battlegrounds Death",
	--SI_GROUP_SYNERGIZER_AUTO_QUE_TT	= "Automatically Join Que After Clicking 'Check Active Quests' Button",
	SI_GROUP_SYNERGIZER_SLASH_TT	= "Slash Commands\nDaily Pledges /pl /pledge\nGroup Leave /lv /leave",
	SI_GROUP_SYNERGIZER_DELAY_TT	= "Delay (In Seconds) Between Sound Nofications On LFG Ready Check",

	SI_GROUP_SYNERGIZER_SLASH_WARN	= "UI Reload Required",

	SI_GROUP_SYNERGIZER_FEEDBACK	= "Send Feedback",
	SI_GROUP_SYNERGIZER_FEEDBACK_TT = "Send the addon author a message with any feedback, suggestions, or bug reports"
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
