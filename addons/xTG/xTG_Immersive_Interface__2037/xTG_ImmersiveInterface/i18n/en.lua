--[[
Author: Rhynchelma
Filename: en.lua
Version: 2
]]--

-- Messages settings
local strings = {
	XTGII_GUI_OPTION_DESCRIPTION_LINE_1 = "Immersive Interface tries to give you more immersion by hiding UI elements, to let you appreciate the beauty of the world.",

	XTGII_GUI_OPTION_MENU_INTERFACE = "Interface",
	XTGII_GUI_OPTION_INTERFACE_DESCRIPTION_LINE = "Hide UI elements.",

	XTGII_GUI_OPTION_INTERFACE_QUEST_TRACKER = "Current Quest Frame",
	XTGII_GUI_OPTION_INTERFACE_COMPASS = "Compass",
	XTGII_GUI_OPTION_INTERFACE_SKILLBAR = "Skill bar",
	XTGII_GUI_OPTION_INTERFACE_PLAYER_ATTRIBUTES_BARS = "HP/MP/Stamina",
	XTGII_GUI_OPTION_INTERFACE_TARGET_FRAME = "Target Informations",
	XTGII_GUI_OPTION_INTERFACE_EQUIPMENT_STATUS = "Equipment status",


	XTGII_GUI_OPTION_MENU_HEALTH = "Health",

	XTGII_GUI_OPTION_HEALTH_DESCRIPTION_LINE_1 = "Immersive Health tries to give you more immersion by replacing numerical health point indication by a feeling of a damaged status.",
	XTGII_GUI_OPTION_HEALTH_DESCRIPTION_LINE_2 = "Here we suggest that you configure the equivalent to a heartbeat, which will be more and more insistent as you get closer to death.",

	XTGIH_GUI_OPTION_HEALTH_ONLY_IN_FIGHT = "Show only in combat",
	XTGIH_GUI_OPTION_HEALTH_HIDETHRESHOLD = "Don't show before (% of health):",
	XTGIH_GUI_TOOLTIP_HEALTH_HIDETHRESHOLD = "Example : If you set 80, you will begin to see heartbeat when your health goes below 80%.",
	XTGIH_GUI_OPTION_HEALTH_ALPHAMIN = "Minimum opacity (%):",
	XTGIH_GUI_TOOLTIP_HEALTH_ALPHAMIN = "Minimum opacity is the value used with no heartbeat.",
	XTGIH_GUI_OPTION_HEALTH_ALPHAMAX = "Maximum opacity (%):",
	XTGIH_GUI_TOOLTIP_HEALTH_ALPHAMAX = "Maximum opacity is the value used when the heartbeat is triggered.",

	XTGIH_GUI_OPTION_HEALTH_CRITICALTHRESHOLD = "Critical threshold (% of health):",
	XTGIH_GUI_TOOLTIP_HEALTH_CRITICALTHRESHOLD = "Example : if you set 45, you will get a blood-tinted screen as long as you don't go above 45% of health.",
	XTGII_GUI_OPTION_DESCRIPTION_LINE_1 = "Immersive Interface try to give you some more immersion in hidding UI elements to let you appreciate the beauty of the world.",
}

for stringId, stringValue in pairs(strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end