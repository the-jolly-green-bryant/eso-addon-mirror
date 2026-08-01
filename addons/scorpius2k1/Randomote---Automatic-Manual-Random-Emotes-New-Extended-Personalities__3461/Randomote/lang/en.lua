local strings = {
	SI_RANDOMOTE_LANG 					= "en",
	SI_RANDOMOTE_ENABLE					= "Automatic",
	SI_RANDOMOTE_ENABLE_TT				= "Enable/Disable Using Random Emotes When Idle",
	SI_RANDOMOTE_STANDARD				= "Standard Emotes",
	SI_RANDOMOTE_STANDARD_TT			= "Use Standard Emotes",
	SI_RANDOMOTE_COLLECTIBLE			= "Collectible Emotes",
	SI_RANDOMOTE_COLLECTIBLE_TT			= "Use Collectible Emotes (Earnable, Crown Store, etc)",
	SI_RANDOMOTE_CHAT_OUTPUT			= "Chat Output",
	SI_RANDOMOTE_CHAT_OUTPUT_TT			= "Display Information via Chat Window (Useful to see slash command, next emote time, etc)",
	SI_RANDOMOTE_DELAY_IDLE				= "Idle Delay",
	SI_RANDOMOTE_DELAY_IDLE_TT			= "Time In Seconds Player Is Idle To Start Automatically Using Emotes",
	SI_RANDOMOTE_DELAY_MIN				= "Emote Delay (Minimum)",
	SI_RANDOMOTE_DELAY_MIN_TT			= "Minimum Time In Seconds Between Emotes",
	SI_RANDOMOTE_DELAY_MAX				= "Emote Delay (Maximum)",
	SI_RANDOMOTE_DELAY_MAX_TT			= "Maximum Time In Seconds Between Emotes",
	SI_RANDOMOTE_FEEDBACK 				= "Send Feedback",
	SI_RANDOMOTE_FEEDBACK_TT 			= "Send the addon author a message with any feedback, suggestions, or bug reports",
	SI_RANDOMOTE_DESCRIPTION_SLASH		= "Slash Commands",
	SI_RANDOMOTE_DESCRIPTION_EMOTE		= "Invoke Random Emote",
	SI_RANDOMOTE_DESCRIPTION_SETTINGS 	= "Open Settings Menu",
	SI_RANDOMOTE_EMOTE_LIST				= "Emote List",
	SI_BINDING_NAME_INVOKE_RANDOM		= "Invoke Random Emote",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
