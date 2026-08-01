-- All the texts that need a translation. As this is being used as the
-- default (fallback) language, all strings that the addon uses MUST
-- be defined here.

--base language is english.
TTFAS_localization_strings = TTFAS_localization_strings  or {}

TTFAS_localization_strings["en"] = {
    TTFAS_PANEL_NAME = "ThiefTools - Filtered AutoSteal",
	TTFAS_PANEL_DISPLAYNAME = "ThiefTools - Filtered AutoSteal (TTFAS)",
	
	SI_BINDING_NAME_TTFAS_TOGGLE = "Toggle Addon",

	TTFAS_DEBUG = "Enable debug mode",
	TTFAS_DEBUG_TT = "Recommended OFF. Debug Mode writes tons of jibberish to your chat window, so you probably don't want it.",

	-- Addon Integrations
	TTFAS_INTEGRATIONS = "- Addon Integrations",
	TTFAS_TTC_ADDON = "Tamriel Trade Centre (TTC)",
	TTFAS_TTC_ADDON_DESC = "Provides access to TTC suggested prices and allows you to choose to take items whose TTC values are above a certain minimum.",
	TTFAS_TTCPRICE_BASE = "Base TTC price to use",
	TTFAS_PROFIT = "Use base price or expected profit",
	TTFAS_PROFIT_TT = "Use either the base price selected above for any TTC comparisons or use a calculated expected profit (TTC base price - cost to launder item).",
	TTFAS_UT_ADDON = "Unknown Tracker",
	TTFAS_UT_ADDON_DESC = "Provides access to knowledge UnknownTracker has about which of your characters knows a particular recipe, motif, or style page. Allows you to choose to take items that any one of your characters does not know.",
	TTFAS_UT_ADDON_SETTINGS = "The UnknownTracker addon Settings->Character determine which of your characters will be checked for knowledge. In particular, characters marked as 'Not Learning' will not be considered.",
	TTFAS_TT_ADDON = "ThiefTools",
	TTFAS_CK_ADDON = "Character Knowledge",
	TTFAS_TT_ADDON = "ThiefTools",
	TTFAS_TT_DESC = "The autosteal for ThiefTools conflicts with the autosteal for TTFAS so when one is turned on, the other will be turned off.",
	TTFAS_TT_DESC2 = "ThiefTools provides the command /tt.as to toggle on/off its version of autosteal. When it detects that TTFAS is loaded, it also provides the command /tt.fas which will turn on filtered autostealing (TTFAS) and turn off its own autostealing.",
	TTFAS_TT_DESC3 = "If you have the ThiefTools bar visible then you can see on it which of the autosteals is active. A gold bag with coins indicates that the ThiefTools autosteal is active. A blue bag with coins indicates that the TTFAS autosteal is active.",
	TTFAS_MSAL_ADDON = "Lykeion's Much Smarter AutoLoot",
	TTFAS_MSAL_DESC = "In order for Lykeion's Much Smart AutoLoot to coexist with ThiefTools Filtered AutoSteal, you MUST set the General:\"Stolen Items Rule\" to \"Never Loot\". If MSAL is allowed to process stolen items, then TTFAS will never see them.",

	TTFAS_GAME_SETTINGS = "Game Settings",
	TTFAS_GAME_SETTINGS_DESC = "These are active game settings controls that have been provided here for convenience as they can control how or if TTFAS will work.",
	TTFAS_LOOT_HISTORY="Control the Game's Loot History setting.",
	TTFAS_LOOT_HISTORY_TT="Recommended ON. This is an alternate access to the game's Loot History setting which will notify you when you loot (or steal) items.",

	TTFAS_PROFILE_SETTINGS = "Active Profile",
	TTFAS_PROFILE_DESC = "All defined profiles are available to all of the characters of the current account and multiple characters can use the same profile.",
	TTFAS_PROFILE_DESC2 = "The special (not deletable) profile named \"Account-Wide\" was created for you based on default settings when the addon was installed so that you could immediately start using it.",
	TTFAS_CURRENT_PROFILE = "Currently Active Profile",
	TTFAS_CURRENT_PROFILE_TT = "The following starred (*) settings sections are for the currently active profile. Changes will be saved to the active profile (effecting all characters that use this profile.)",

	TTFAS_GENERAL_SETTINGS = "- General Settings",
	TTFAS_LOOT_FILTERS = "Loot Filters",
	
	TTFAS_ENABLE = "Enable ThiefTools - Filtered AutoSteal",
	TTFAS_ENABLE_TT = "The chat command \'/ttfas\' can also be used to toggle ThiefTools-Filtered AutoSteal on and off. Note: Enabling TT Filtered AutoSteal will turn off the game's built-in AutoSteal setting.",
	TTFAS_ENABLED = "ENABLED",
	TTFAS_DISABLED = "DISABLED",
	
	TTFAS_CLOSE_LOOT_WINDOW = "Auto-Close Loot Window",
	TTFAS_CLOSE_LOOT_WINDOW_TT = "When enabled, the loot window will automatically exit when the TT Filtered AutoSteal is complete. When this feature is enabled, you can still temporarily keep the loot window open by holding down the Shift key when you start looting",
	TTFAS_TURN_OFF_AUTOSTEAL = "Turn off Gameplay AutoSteal setting.",
	TTFAS_TURN_OFF_AUTOSTEAL_TT = "Recommended ON. While the Game's AutoSteal setting is on, then the TTFAS auto-stealing and filtering will not work - it will be overriden by the game's setting. Enabling this option will turn off the Gameplay AutoSteal setting while this addon is enabled.",
	TTFAS_TURN_OFF_AUTOLOOT = "Turn off Gameplay AutoLoot setting.",
	TTFAS_TURN_OFF_AUTOLOOT_TT = "Recommended OFF. Always sneak when you are stealing instead. While the Gameplay AutoLoot setting is on, then the TTFAS auto-stealing and filtering will not work while you are not sneaking - it will be overriden by the game's setting. But if you turn this setting ON, then your non-stealing looting may get wierd.",
	
	TTFAS_BANNER = "Show addon banner in chat",
	TTFAS_BANNER_TT = "When enabled, the first time you log in, you will be prompted in the chat box if ThiefTools - Filtered AutoSteal is enabled",
	TTFAS_LOGIN_CLOSE_LOOT_WINDOW = "TTFAS Close Loot Window: ",
	
	TTFAS_GEAR_FILTERS = "- Gear Filters",
	TTFAS_QUALITY_THRESHOLD = "Min Quality Threshold",
	TTFAS_QUALITY_THRESHOLD_TT = "The minimum quality of items to be taken.",
	TTFAS_VALUE_THRESHOLD = "Value Threshold",
	TTFAS_VALUE_THRESHOLD_TT = "The minimum value of items to be taken",
	TTFAS_TTCVALUE_THRESHOLD = "Min TTC Value Threshold",
	TTFAS_TTCVALUE_THRESHOLD_TT = "The minimum TTC value of items to be taken",

	TTFAS_COMP_QUALITY_THRESHOLD = "Min Companion Gear Quality Threshold",
	TTFAS_COMP_QUALITY_THRESHOLD_TT = "The minimum quality of companion items to be taken.",
	TTFAS_COMPANION_GEARS = "Companion Gear",
	
	TTFAS_SET_ITEMS = "Set Gear Items",
	TTFAS_SET_JEWEL_ITEMS = "Set Jewelry Items",
	TTFAS_UNRESEARCHED_ITEMS = "Unresearched Items",
	TTFAS_ORNATE_ITEMS = "Ornate Items",
	TTFAS_INTRICATE_ITEMS = "Intricate Items",
	TTFAS_CLOTHING_INTRICATE_ITEMS = "- Clothing Intricate Items",
	TTFAS_BLACKSMITHING_INTRICATE_ITEMS = "- Blacksmithing Intricate Items",
	TTFAS_WOODWORKING_INTRICATE_ITEMS = "- Woodworking Intricate Items",
	TTFAS_JEWELRY_INTRICATE_ITEMS = "- Jewelry Intricate Items",
	TTFAS_WEAPONS = "General Weapons",
	TTFAS_ARMORS = "General Armor",
	TTFAS_JEWELRY = "General Jewelry",
	
	TTFAS_MATERIAL_FILTERS = "- Material Filters",
	TTFAS_CRAFTING_MATERIALS = "Crafting Materials",
	TTFAS_CRAFTING_MATERIALS_TT = "Includes clothing, blacksmithing, woodworking and jewelry crafting",
	TTFAS_TRAIT_MATERIALS = "Trait Materials",
	TTFAS_STYLE_MATERIALS = "Style Materials",
	TTFAS_ALCHEMY_INGREDIENTS = "Alchemy Solvents & Reagents",
	TTFAS_COOKING_INGREDIENTS = "Cooking Ingredients",
	TTFAS_ENCHANTING_RUNES = "Enchanting Runes",
	TTFAS_FURNISHING_MATERIALS = "Furnishing Materials",
	
	TTFAS_TREASURES_FILTERS = "- Treasures Filters",
	TTFAS_TREASURES = "Treasures",
	TTFAS_TREASURES_QUALITY_THRESHOLD = "Treasures Quality Threshold",
	TTFAS_TURN_ON_AZANDAR = "Take stuff Azandar likes",
	TTFAS_TURN_ON_AZANDAR_TT = "Enabling this will automatically take certain treasures out of containers that Azandar will give you rapport for even if the quality is not as good as you wanted. (You can discard it later.) Azandar must be out and have rapport less than 5500.",

	TTFAS_CONTAINERS_FILTERS = "- Containers Options",
	TTFAS_CONTAINERS = "Take Containers found within containers",
	TTFAS_INV_CONTAINERS = "Take from Stolen containers found within inventory",
	
	TTFAS_PAPERS_FILTERS = "- Papers",
	TTFAS_RECIPES = "Recipes & Plans",
	TTFAS_MOTIFS = "Motifs",
	TTFAS_STYLE_PAGES = "Outfit Style Pages",
	TTFAS_TREASURE_MAPS = "Treasure Maps",
	TTFAS_WRITS = "Writs",
	TTFAS_TTC_MIN = "Has at least Minimum TTC value",
	TTFAS_PAPER_TTC_MIN_DESC = "If previously unmatched, check to see if the recipe, motif, or style page has at least the minimum specified price in TTC.",

	TTFAS_MISC_FILTERS = "- Miscellaneous",
	TTFAS_SOUL_GEMS = "Soul Gems",
	TTFAS_POTIONS = "Potions",
	TTFAS_POISONS = "Poisons",
	TTFAS_LOCKPICKS_TOOLS = "Lockpicks",
	TTFAS_FOOD_DRINK = "Food & Drink",
	TTFAS_GLYPHS = "Glyphs",

	TTFAS_BAIT = "Fishing Bait",
	
	TTFAS_FURNITURE = "Furniture",
	
	-- Value strings for various fields
	TTFAS_TAKE_ALL = "Take All Items",
	TTFAS_JUST_OPEN = "Just Open",
	TTFAS_FOLLOW = "Follow rules",
	
	TTFAS_ALWAYS_TAKE = "Always Take",
	TTFAS_NEVER_TAKE = "Never Take",
	
	TTFAS_UNCOLLECTED = "Only Uncollected",
	TTFAS_COLLECTED = "Only Collected",
	TTFAS_TTC_MIN_VALUE = "Minimum TTC Value",
	
	TTFAS_TYPE_BASED = "Type-based",
	TTFAS_ONLY_NON_RACIAL = "Only Non-Racial Styles",
	TTFAS_ONLY_FILLED = "Only Filled",
	TTFAS_ONLY_UNFILLED = "Only Unfilled",
	TTFAS_UNKNOWN_BY_ME = "Unknown by Me",
	TTFAS_UNKNOWN_BY_ANY = "Unknown by Any",
	TTFAS_DLC_ZONE = "Only DLC Zone Maps",
	TTFAS_ONLY_POTENT_POTIONS = "Only Potent Potions",
	TTFAS_ONLY_NORMAL_POTIONS = "Only Normal Potions",
	TTFAS_MIN_QUALITY = "Minimum Quality",
	TTFAS_MIN_VALUE = "Minimum Value",
	
	-- TTC Integration strings
	TTFAS_PP_SUGGESTED = "suggested",
	TTFAS_PP_AVERAGE = "average",
	TTFAS_PP_BASEPRICE = "baseprice",
	TTFAS_PP_PROFIT = "profit",
	
	-- Profile Management
	TTFAS_PROFILE_MGMT = "Profile Management",
	TTFAS_CREATE_PROF = "Create New Profile",
	TTFAS_CREATE_PROF_DESC = "Create a new named profile for use by one or more characters on this account.",
	TTFAS_NEW_PROF_NAME = "New Profile Name",
	TTFAS_NEW_PROF_NAME_DESC = "Each profile must have a unique name and cannot be named either \"Default\" or \"Account-Wide\"",
	TTFAS_COPYFROM_PROFILE = "Copy settings from Profile",
	TTFAS_COPYFROM_PROFILE_TT = "The special \"Default\" profile uses the default setting from initial addon-install. The other profiles can have different changed settings that can be copied into the new profile you are creating.",
	TTFAS_SAVE_PROF_BTN = "Save New Profile",
	TTFAS_DELETE_HDR = "Delete Existing Profile",
	TTFAS_DELETE_PROF_BTN = "Delete Profile",
	TTFAS_DEL_PROFILE = "Delete profile by name",
	TTFAS_DEL_PROF_DESC = "The special profile \"Account-Wide\" cannot be deleted.",
	TTFAS_USED_BY = "Characters using this profile: ",
	TTFAS_CONFIRM_DELETE = "Are you sure you want to delete this profile?"
}
