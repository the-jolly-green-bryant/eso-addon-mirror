--base language is english, so the file en.lua shuld be kept empty!
FastRide_localization_strings = FastRide_localization_strings  or {}

FastRide_localization_strings["en"] = {
    -- General
	FR_ACCOUNTWIDE = "Account Wide Configuration",
	FR_ABILITYSLOT = "Ability Slot to use for Fast Riding",
	
	FR_SWITCH_MOUNTED = "Enable autoswitch upon mounting/dismounting",
    FR_NOSWITCH_IF_ACTIVE = "Prevent mount autoswitch if Rapids active",
	FR_REVERT_USED = "Revert (leave Rapids-mode) when skill is used",
	FR_SWITCH_FADE = "Reenable Rapids-mode when effect fades",
	FR_SWITCH_FADE_SEC = "How long before effect fades (seconds)",
	FR_ENABLEICON = "Display the mode icon",
	FR_ENABLE_UNSHEATHE = "Automatically unsheathe weapons",
	FR_ENABLE_UNSHEATHE_TT = "Unsheathe weapons when you go into rapids-mode while you are on foot",
	
	FR_SOUND_ENABLED = "Play sound when Rapids-mode is enabled",
	FR_SOUND_INDEX = "Sound to play",
    FR_SOUND_NAME = "Sound Name",
    
    FR_NOTIFY_FAILURE = "Notify in chat if skill cannot be swapped for rapids",
    
    FR_SKILLLOC_NM = "Rapids Skill Name",
    FR_SKILL_LOC = "Choose the name for the Rapids skill in your client language.",
	
	-- section names
	FR_AUTOSWITCH_NM = "Autoswitching",
	FR_SOUND_NM = "Sounds",
    FR_NOTIFY_NM = "Notify",
    FR_SKILL_LOC_NM = "Skill Localization",
	
	-- binding names
	FR_BINDING_TOGGLE = "Toggle Rapids-mode",
    
    -- slash descriptions
    FR_SLASH_HELP = "Print this help message",
    FR_SLASH_KEY = "Swap into/out of rapids mode",
    FR_SLASH_RELOAD = "Reload skills",
    FR_SLASH_DEBUG = "Toggle debug messages for FastRide",
	FR_SLASH_SKILLS = "Set original skills",
}
