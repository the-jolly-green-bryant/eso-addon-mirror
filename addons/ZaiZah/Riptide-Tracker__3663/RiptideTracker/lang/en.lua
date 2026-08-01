------------------------------------------------------------------------------------------------------------------
-- English (en)
-- Format and phrasing by ZaiZah
------------------------------------------------------------------------------------------------------------------
-- Every variable must start with this addon's unique ID, as each is a global.
local stringsEN = {
	["SI_RTT_SETTING_NAME"]							= "|c00c1ffCoral Riptide|r Damage Bonus Tracker",
	["SI_RTT_SETTING_NAME_SHORT"]					= "Coral Riptide Tracker",
	["SI_RTT_GENERAL_SETTINGS"] 					= "General Settings",
	["SI_RTT_GENERAL_THEME_DESC"] 					= "Toggle between Progress Bar or Squared Icon Display.",
	["SI_RTT_GENERAL_THEME"]						= "Use Minimal Theme",
	["SI_RTT_GENERAL_THEME_TOOLTIP"]				= "Choose to display as Progress bar(Off) or Squared Icon(On)",
	["SI_RTT_GENERAL_LOCK_DESC"] 					= "Unlock the tracker to allow it to be moved.",
	["SI_RTT_GENERAL_LOCK"]							= "Unlock Tracker Window",
	["SI_RTT_GENERAL_LOCK_TOOLTIP"]					= "When unlocked allow the tracker to be dragged using the mouse.",
	["SI_RTT_GENERAL_LOCB"]							= "Reset tracker position",
	["SI_RTT_GENERAL_LOCB_TOOLTIP"]					= "Resets current tracker window back to the default screen position.",	
	["SI_RTT_GENERAL_COMBAT_DESC"]					= "When ON, tracker will only be visible when you are in combat.",
	["SI_RTT_GENERAL_COMBAT"]						= "Only display in combat",
	["SI_RTT_GENERAL_TICK_DESC"]					= "How fast should the tracker re-render. Default is 500ms",
	["SI_RTT_GENERAL_TICK"]							= "Render Tick Interval",
	["SI_RTT_GENERAL_TICK_TOOLTIP"]					= "The milliseconds for the loop that updates the set bonus of the tracker. You can select the value based on what is the best performance for you.",
	["SI_RTT_GENERAL_THEME_DEF"]					= "Default Theme Options",
	["SI_RTT_GENERAL_BARC_ICON"]					= "Display Coral Riptide Set Icon",
	["SI_RTT_GENERAL_BARC_ICONTOOLTIP"]				= "Display the Coral Riptide set icon on the display bar",
	["SI_RTT_GENERAL_BARC_CDESC"]					= "Change the colors of the Display.",
	["SI_RTT_GENERAL_BARC_CENT"]					= "Display Background Color",
	["SI_RTT_GENERAL_BARC_EDGE"]					= "Display Border Color",
	["SI_RTT_GENERAL_BARC_CTOOLTIP"]				= "Allows you to change the display color.",
	["SI_RTT_GENERAL_BARC_DESC"]					= "Change the colors of the damage Bar.",
	["SI_RTT_GENERAL_BARC"]							= "Damage Bar Color",
	["SI_RTT_GENERAL_BARC_HIGH"]					= "Damage Bar Color Highlight",
	["SI_RTT_GENERAL_BARC_TOOLTIP"]					= "Allows you to change the threshold damage bar color.",
	["SI_RTT_GENERAL_BARC_THRESHDESC"]				= "Set the damage bar percent highlight threshold - Coral Riptide hits cap at 33%",
	["SI_RTT_GENERAL_BARC_THRESH"]					= "Damage Bar Percent Threshold",
	["SI_RTT_GENERAL_BARC_THRESHTOOLTIP"]			= "Sets the % threshold for displaying threshold highlight",
	["SI_RTT_GENERAL_THEME_ALT"]					= "Minimal Theme Options",
	["SI_RTT_GENERAL_ICON_SIZE"]					= "Set Scale of Display",
	["SI_RTT_GENERAL_ICON_SIZETOOLTIP"]				= "0.5 is tiny, 2 is huge - Addon optimized for scale = 1",
	["SI_RTT_GENERAL_ICON_FONTC"]					= "Set Text Color",
	["SI_RTT_GENERAL_ICON_FONTCTOOLTIP"]			= "Set the color of the bonus text display",
	["SI_RTT_GENERAL_ICON_EDGE"]					= "Display Border Color",
	["SI_RTT_GENERAL_ICON_EDGETOOLTIP"]				= "Allows you to change the display color.",
	["SI_RTT_GENERAL_ICON_ALPHA"]					= "Set Display Alpha",
	["SI_RTT_GENERAL_ICON_ALPHATOOLTIP"]			= "Change the display transparency value.",
}

for stringId, stringValue in pairs(stringsEN) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end