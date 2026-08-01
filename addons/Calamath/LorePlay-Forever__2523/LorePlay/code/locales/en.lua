------------------------------------------------
-- LorePlay
-- English localization
------------------------------------------------
LorePlay = LorePlay or {}

local strings = {
	SI_LOREPLAY_LOCATION_KEYWORD_DOLMEN			= "Dolmen", 
	SI_LOREPLAY_LOCATION_KEYWORD_ABYSSAL_GEYSER	= "Abyssal Geyser", 

	SI_LOREPLAY_PC_TITLE_NAME_M_41				= "Emperor", 					-- "Emperor"
	SI_LOREPLAY_PC_TITLE_NAME_M_42				= "Former Emperor", 			-- "Former Emperor"
	SI_LOREPLAY_PC_TITLE_NAME_M_47				= "Daedric Lord Slayer", 		-- "Daedric Lord Slayer"
	SI_LOREPLAY_PC_TITLE_NAME_M_48				= "Savior of Nirn", 			-- "Savior of Nirn"
	SI_LOREPLAY_PC_TITLE_NAME_M_51				= "Dragonstar Arena Champion", 	-- "Dragonstar Arena Champion"
	SI_LOREPLAY_PC_TITLE_NAME_M_54				= "Maelstrom Arena Champion", 	-- "Maelstrom Arena Champion"
	SI_LOREPLAY_PC_TITLE_NAME_M_55				= "Stormproof",                 -- "Stormproof"
	SI_LOREPLAY_PC_TITLE_NAME_M_56				= "The Flawless Conqueror", 	-- "The Flawless Conqueror"
	SI_LOREPLAY_PC_TITLE_NAME_M_63				= "Ophidian Overlord", 			-- "Ophidian Overlord"

	SI_LOREPLAY_PC_TITLE_NAME_F_41				= "Empress", 					-- "Empress"
	SI_LOREPLAY_PC_TITLE_NAME_F_42				= "Former Empress", 			-- "Former Empress"
	SI_LOREPLAY_PC_TITLE_NAME_F_47				= "Daedric Lord Slayer", 		-- "Daedric Lord Slayer"
	SI_LOREPLAY_PC_TITLE_NAME_F_48				= "Savior of Nirn", 			-- "Savior of Nirn"
	SI_LOREPLAY_PC_TITLE_NAME_F_51				= "Dragonstar Arena Champion", 	-- "Dragonstar Arena Champion"
	SI_LOREPLAY_PC_TITLE_NAME_F_54				= "Maelstrom Arena Champion", 	-- "Maelstrom Arena Champion"
	SI_LOREPLAY_PC_TITLE_NAME_F_55				= "Stormproof",                 -- "Stormproof"
	SI_LOREPLAY_PC_TITLE_NAME_F_56				= "The Flawless Conqueror", 	-- "The Flawless Conqueror"
	SI_LOREPLAY_PC_TITLE_NAME_F_63				= "Ophidian Overlord", 			-- "Ophidian Overlord"

	SI_BINDING_NAME_LP_PERFORM_SMART_EMOTE			= "Perform Smart Emote", 
	SI_BINDING_NAME_LP_TOGGLE_IDLEEMOTES			= "Toggle IdleEmotes On/Off", 
	SI_BINDING_NAME_LP_SHOW_HIDE_LOREWEAR_CLOTHES	= "Show/Hide Costumes Only", 
	SI_BINDING_NAME_LP_FORCE_EQUIP_CITY_OUTFIT		= "Force Equip City Outfit", 
	SI_BINDING_NAME_LP_FORCE_EQUIP_HOUSING_OUTFIT	= "Force Equip Housing Outfit", 
	SI_BINDING_NAME_LP_FORCE_EQUIP_DUNGEON_OUTFIT	= "Force Equip Dungeon Outfit", 
	SI_BINDING_NAME_LP_FORCE_EQUIP_ADVENTURE_OUTFIT	= "Force Equip Adventure Outfit", 
	SI_BINDING_NAME_LP_TOGGLE_ALTERNATIVE_OUTFIT	= "Toggle Prefered Outfits", 

	SI_LOREPLAY_UI_WELCOME							= "[LorePlay] Welcome to LorePlay, Soulless One!", 
	SI_LOREPLAY_PANEL_SUPPRESS_STARTUP_MESSAGE_NAME = "Suppress Startup Message", 
	SI_LOREPLAY_PANEL_SUPPRESS_STARTUP_MESSAGE_TIPS = "Suppresses startup message.\n[account-wide settings]", 
	SI_LOREPLAY_PANEL_SE_HEADER						= "Smart Emotes", 
	SI_LOREPLAY_PANEL_SE_DESCRIPTION				= "Contextual, appropriate emotes to perform at the touch of a button.\nBy default, pressing performs an emote based on location. However, it adapts and conforms to many different special environmental situations along your travels as well.\n|cFF0000Don't forget to bind your SmartEmotes button!|r", 
	SI_LOREPLAY_PANEL_SE_EDIT_SIGNIFICANT_CHAR_NAME	= "Significant Other's Character Name", 
	SI_LOREPLAY_PANEL_SE_EDIT_SIGNIFICANT_CHAR_TIPS	= "For those who have wed with the Ring of Mara, entering the exact character name of your loved one allows for special emotes between you two!\n(Note: Must be friends!)", 
	SI_LOREPLAY_PANEL_SE_INDICATOR_SW_NAME			= "Toggle Indicator On/Off", 
	SI_LOREPLAY_PANEL_SE_INDICATOR_SW_TIPS			= "Turns on/off the small, moveable indicator (drama masks) that appears on your screen whenever new special adaptive SmartEmotes are available to be performed.", 
	SI_LOREPLAY_PANEL_SE_INDICATOR_POS_RESET_NAME	= "Reset Indicator Position", 
	SI_LOREPLAY_PANEL_SE_INDICATOR_POS_RESET_TIPS	= "Resets the indicator to be positioned in the top left of the screen.", 
	SI_LOREPLAY_PANEL_IE_HEADER						= "Idle Emotes", 
	SI_LOREPLAY_PANEL_IE_DESCRIPTION				= "Contextual, automatic emotes that occur when you go idle or AFK (Not moving, not fighting, not stealthing).\n|cFF0000Don't forget to bind your IdleEmotes keypress for quick toggling!|r", 
	SI_LOREPLAY_PANEL_IE_SW_NAME					= "Toggle IdleEmotes On/Off", 
	SI_LOREPLAY_PANEL_IE_SW_TIPS					= "Turns on/off the automatic, contextual emotes that occur when you go idle or AFK.\n(Note: Disabling IdleEmotes displays all its settings as off, but will persist after re-enabling.)", 
	SI_LOREPLAY_PANEL_IE_IDLE_TIME_NAME				= "Idle Time", 
	SI_LOREPLAY_PANEL_IE_IDLE_TIME_TIPS				= "Determines the wait time in seconds, until a given idle emote will be performed.\nDefault is 20 seconds.\n[account-wide settings]", 
	SI_LOREPLAY_PANEL_IE_EMOTE_DURATION_NAME		= "Emote Duration", 
	SI_LOREPLAY_PANEL_IE_EMOTE_DURATION_TIPS		= "Determines how long in seconds a given idle emote will be performed before switching to a new one.\nDefault is 30 seconds.", 
	SI_LOREPLAY_PANEL_IE_PLAY_INST_IN_CITY_SW_NAME	= "Can Play Instruments In Cities", 
	SI_LOREPLAY_PANEL_IE_PLAY_INST_IN_CITY_SW_TIPS	= "Determines whether or not your character can perform instrument emotes when idle in cities.", 
	SI_LOREPLAY_PANEL_IE_DANCE_IN_CITY_SW_NAME		= "Can Dance In Cities", 
	SI_LOREPLAY_PANEL_IE_DANCE_IN_CITY_SW_TIPS		= "Determines whether or not your character can perform dance emotes when idle in cities.", 
	SI_LOREPLAY_PANEL_IE_BE_DRUNK_IN_CITY_SW_NAME	= "Can Be Drunk In Cities", 
	SI_LOREPLAY_PANEL_IE_BE_DRUNK_IN_CITY_SW_TIPS	= "Determines whether or not your character can perform drunken emotes when idle in cities.", 
	SI_LOREPLAY_PANEL_IE_EXERCISE_IN_ZONE_SW_NAME	= "Can Exercise Outside Cities", 
	SI_LOREPLAY_PANEL_IE_EXERCISE_IN_ZONE_SW_TIPS	= "Determines whether or not your character can perform exercise emotes when idle outside of cities.", 
	SI_LOREPLAY_PANEL_IE_WORSHIP_SW_NAME			= "Can Worship/Pray", 
	SI_LOREPLAY_PANEL_IE_WORSHIP_SW_TIPS			= "Determines whether or not your character can perform prayer and worship emotes when idle in general.", 
	SI_LOREPLAY_PANEL_IE_ALLOWED_IN_HOUSING_NAME	= "Allow emotes in Housing Editor", 
	SI_LOREPLAY_PANEL_IE_ALLOWED_IN_HOUSING_TIPS	= "Allows for idle emotes to be performed while in housing editor mode.", 
	SI_LOREPLAY_PANEL_IE_CAMERA_SPIN_DISABLER_NAME	= "Camera Spin Disabler", 
	SI_LOREPLAY_PANEL_IE_CAMERA_SPIN_DISABLER_TIPS	= "Allows for emotes to be performed while in menus. Disables camera spin in menus. Removes '" .. GetString(SI_PLAYEREMOTEPLAYFAILURE0) .. "' message.", 
	SI_LOREPLAY_PANEL_LE_SET_OUTFIT_CITY_NAME		= "Set City Outfit", 
	SI_LOREPLAY_PANEL_LE_SET_OUTFIT_CITY_TIPS		= "Sets the current outfit (collectibles) your character is wearing as their city outfit, allowing for automatic collectible changing when entering a city.\nAlso saves |cFF0000empty slots|r if the 'Use Favorite ...' setting for that category is enabled!", 
	SI_LOREPLAY_PANEL_LE_SET_OUTFIT_HOUSING_NAME	= "Set Housing Outfit", 
	SI_LOREPLAY_PANEL_LE_SET_OUTFIT_HOUSING_TIPS	= "Sets the current outfit (collectibles) your character is wearing as their housing outfit, allowing for automatic collectible changing when entering a house.\nAlso saves |cFF0000empty slots|r if the 'Use Favorite ...' setting for that category is enabled!", 
	SI_LOREPLAY_PANEL_LE_SET_OUTFIT_DUNGEON_NAME	= "Set Dungeon Outfit", 
	SI_LOREPLAY_PANEL_LE_SET_OUTFIT_DUNGEON_TIPS	= "Sets the current outfit (collectibles) your character is wearing as their dungeon outfit, allowing for automatic collectible changing when entering a dungeon.\nAlso saves |cFF0000empty slots|r if the 'Use Favorite ...' setting for that category is enabled!", 
	SI_LOREPLAY_PANEL_LE_SET_OUTFIT_ADVENTURE_NAME	= "Set Adventure Outfit", 
	SI_LOREPLAY_PANEL_LE_SET_OUTFIT_ADVENTURE_TIPS	= "Sets the current outfit (collectibles) your character is wearing as their adventuring outfit, allowing for automatic collectible changing when running around the land of Tamriel.\nAlso saves |cFF0000empty slots|r if the 'Use Favorite ...' setting for that category is enabled!", 

	SI_LOREPLAY_PANEL_LW_HEADER						= "Lore Wear", 
	SI_LOREPLAY_PANEL_LW_DESCRIPTION				= "Armor should be worn when venturing Tamriel, but not when in comfortable cities! Your character will automatically and appropriately equip their favorite collectibles depending on where they are.\n|cFF0000Don't forget to bind your LoreWear show/hide clothes button!|r", 
	SI_LOREPLAY_PANEL_LW_SW_NAME					= "Toggle LoreWear On/Off", 
	SI_LOREPLAY_PANEL_LW_SW_TIPS					= "Turns on/off the automatic, contextual clothing that will be put on when entering the areas respective to your outfits.\n(Note: Disabling LoreWear displays all its settings as off, but will persist after re-enabling.)", 
	SI_LOREPLAY_PANEL_LW_EQUIP_WHILE_MOUNT_SW_NAME	= "Allow Equip While Mounted", 
	SI_LOREPLAY_PANEL_LW_EQUIP_WHILE_MOUNT_SW_TIPS	= "Turns on/off the automatic, contextual clothing that can be put on while riding your trusty steed.", 
	SI_LOREPLAY_PANEL_LW_OUTFIT_SW_NAME				= "Use Favorite Outfits managed at the outfit station", 
	SI_LOREPLAY_PANEL_LW_OUTFIT_SW_TIPS				= "", 

}
for stringId, stringToAdd in pairs(strings) do
   ZO_CreateStringId(stringId, stringToAdd)
   SafeAddVersion(stringId, 1)
end

ZO_CreateStringId("SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_NAME_"..tostring(COLLECTIBLE_CATEGORY_TYPE_COSTUME), 			"Use Favorite Costume")
--ZO_CreateStringId("SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_TIPS_"..tostring(COLLECTIBLE_CATEGORY_TYPE_COSTUME), 			"If enabled, uses your favorite costume in outfits, along with your other favrotie collectibles.\n|cFF0000Note|r: Use if you want to save 'None' as your favorite, treating the empty slot as a piece of your outfit.")
ZO_CreateStringId("SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_TIPS_"..tostring(COLLECTIBLE_CATEGORY_TYPE_COSTUME), 			"")
ZO_CreateStringId("SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_NAME_"..tostring(COLLECTIBLE_CATEGORY_TYPE_HAT), 				"Use Favorite Hat")
ZO_CreateStringId("SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_TIPS_"..tostring(COLLECTIBLE_CATEGORY_TYPE_HAT), 				"")
ZO_CreateStringId("SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_NAME_"..tostring(COLLECTIBLE_CATEGORY_TYPE_HAIR), 				"Use Favorite Hair")
ZO_CreateStringId("SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_TIPS_"..tostring(COLLECTIBLE_CATEGORY_TYPE_HAIR), 				"")
ZO_CreateStringId("SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_NAME_"..tostring(COLLECTIBLE_CATEGORY_TYPE_SKIN), 				"Use Favorite Skin")
ZO_CreateStringId("SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_TIPS_"..tostring(COLLECTIBLE_CATEGORY_TYPE_SKIN), 				"")
ZO_CreateStringId("SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_NAME_"..tostring(COLLECTIBLE_CATEGORY_TYPE_POLYMORPH), 			"Use Favorite Polymorphs")
ZO_CreateStringId("SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_TIPS_"..tostring(COLLECTIBLE_CATEGORY_TYPE_POLYMORPH), 			"")
ZO_CreateStringId("SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_NAME_"..tostring(COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY), 	"Use Favorite Facial Accessories")
ZO_CreateStringId("SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_TIPS_"..tostring(COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY), 	"")
ZO_CreateStringId("SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_NAME_"..tostring(COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS),	"Use Favorite Facial Hair")
ZO_CreateStringId("SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_TIPS_"..tostring(COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS),	"")
ZO_CreateStringId("SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_NAME_"..tostring(COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING), 		"Use Favorite Body Markings")
ZO_CreateStringId("SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_TIPS_"..tostring(COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING), 		"")
ZO_CreateStringId("SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_NAME_"..tostring(COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING), 		"Use Favorite Head Markings")
ZO_CreateStringId("SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_TIPS_"..tostring(COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING), 		"")
ZO_CreateStringId("SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_NAME_"..tostring(COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY),	"Use Favorite Jewelry")
ZO_CreateStringId("SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_TIPS_"..tostring(COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY),	"")
ZO_CreateStringId("SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_NAME_"..tostring(COLLECTIBLE_CATEGORY_TYPE_PERSONALITY), 		"Use Favorite Personalities")
ZO_CreateStringId("SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_TIPS_"..tostring(COLLECTIBLE_CATEGORY_TYPE_PERSONALITY), 		"")
ZO_CreateStringId("SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_NAME_"..tostring(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET), 			"Use Favorite Pets")
ZO_CreateStringId("SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_TIPS_"..tostring(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET), 			"")
ZO_CreateStringId("SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_NAME_"..tostring(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT), 			"Use Favorite Assistants")
ZO_CreateStringId("SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_TIPS_"..tostring(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT), 			"")

-- ---
