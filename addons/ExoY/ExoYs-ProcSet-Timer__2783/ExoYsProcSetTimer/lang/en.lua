-- Set Origin Locations
EPT_ORIGIN_ALL = "All"
EPT_ORIGIN_ARENA = "Arena"
EPT_ORIGIN_TRIAL = "Trial"
EPT_ORIGIN_DUNGEON = "Dungeon"
EPT_ORIGIN_UNDAUNTED = "Undaunted"
EPT_ORIGIN_CRAFTING = "Crafting"
EPT_ORIGIN_OVERLAND = "Overland"
EPT_ORIGIN_MYTHIC = "Mythic"
EPT_ORIGIN_MISC = "Miscellaneous"
EPT_ORIGIN_PVP = "PvP"
--
--
EPT_DEMO_GUI_NAME = "Example Set"
EPT_DUMMY_DESCRIPTION = "Use the example interface for easier customization. It can not display the colors or simulate any behaviour (yet)."
EPT_DUMMY_BUTTON = "Show/Hide Example"

EPT_SPECIAL_NOTE = "Note: Design changes only affect special indicators after an /reloadui. \n               This will be fixed with a future update."


EPT_ACTION_TOGGLE_STRING = "Toggle"
--------------
-- Bindings --
--------------

EPT_BINDING_ZEN_TOOGLE = "Zen: Focus on Boss - Toggle"

----------
-- MENU --
----------

--Feedback
EPT_FEEDBACK_DESCRIPTION = "Have you experienced any bugs? \n - Please let me know!"
EPT_FEEDBACK_BUTTON = "Feedback"
EPT_FEEDBACK_WARNING = "I actively play on PC(EU). \n Expect a delay in replies on PC(NA)."

-- Submenu Names
EPT_SETTINGS_INFORMATION = "General Settings"
EPT_SETTINGS_DESIGN = "Design"


-- Settings General



-- Settings Design

EPT_SETTINGS_ICONSIZE_NAME = "IconSize"
EPT_SETTINGS_ICONSIZE_TOOLTIP = ""

EPT_SETTINGS_FONT_NAME = "Font"
EPT_SETTINGS_FONT_TOOLTIP = "This affects all writing except the primary indicator."

EPT_SETTINGS_COLORS = "Colors"

EPT_SETTINGS_COLOR_TIMER = "Countdown"
EPT_SETTINGS_COLOR_ACTIVE_NAME = "Active"
EPT_SETTINGS_COLOR_ACTIVE_TOOLTIP = ""
EPT_SETTINGS_COLOR_COOLDOWN_NAME = "Cooldown"
EPT_SETTINGS_COLOR_COOLDOWN_TOOLTIP = ""
EPT_SETTINGS_COLOR_STANDBY_NAME = "Ready"
EPT_SETTINGS_COLOR_STANDBY_TOOLTIP = ""

EPT_SETTINGS_COLOR_VALUE = "Players Affected"
EPT_SETTINGS_COLOR_HIGH_NAME = "High"
EPT_SETTINGS_COLOR_HIGH_TOOLTIP = "More then 70% of your Group is affected."
EPT_SETTINGS_COLOR_MEDIUM_NAME = "Medium"
EPT_SETTINGS_COLOR_MEDIUM_TOOLTIP = "Between 30% and 70% of your Group is affected."
EPT_SETTINGS_COLOR_LOW_NAME = "Low"
EPT_SETTINGS_COLOR_LOW_TOOLTIP = "Less then 30% of your Group is affected."

EPT_SETTINGS_INDICATOR = "Indicator"
EPT_SETTINGS_INDICATOR_SHOW_DECIMAL_NAME = "Show decimal"
EPT_SETTINGS_INDICATOR_SHOW_DECIMAL_TOOLTIP = "Displays the first decimal digit when less then 10 seconds are remaining"
EPT_SETTINGS_INDICATOR_CHANGE_COLOR_NAME = "Change Color"
EPT_SETTINGS_INDICATOR_CHANGE_COLOR_TOOLTIP = ""
EPT_SETTINGS_INDICATOR_SIZE_NAME = "Size"
EPT_SETTINGS_INDICATOR_SIZE_TOOLTIP = ""
EPT_SETTINGS_INDICATOR_FONT_NAME = "Font"
EPT_SETTINGS_INDICATOR_FONT_TOOLTIP = ""
EPT_SETTINGS_INDICATOR_OFFSETX_NAME = "Offset X"
EPT_SETTINGS_INDICATOR_OFFSETX_TOOLTIP = ""
EPT_SETTINGS_INDICATOR_OFFSETY_NAME = "Offset Y"
EPT_SETTINGS_INDICATOR_OFFSETY_TOOLTIP = ""

EPT_SETTINGS_EDGE = "Edge"
EPT_SETTINGS_EDGE_SHOW_NAME = "Show Edge"
EPT_SETTINGS_EDGE_SHOW_TOOLTIP = ""
EPT_SETTINGS_EDGE_CHANGE_COLOR_NAME = "Change Color"
EPT_SETTINGS_EDGE_CHANGE_COLOR_TOOLTIP = ""
EPT_SETTINGS_EDGE_SIZE_NAME = "Size"
EPT_SETTINGS_EDGE_SIZE_TOOLTIP = ""

EPT_SETTINGS_NAME_DISPLAY = "Set Name Display"
EPT_SETTINGS_NAME_DISPLAY_SIZE_NAME = "Size"
EPT_SETTINGS_NAME_DISPLAY_SIZE_TOOLTIP = ""
EPT_SETTINGS_NAME_DISPLAY_POSITION_NAME = "Position"
EPT_SETTINGS_NAME_DISPLAY_POSITION_TOOLTIP = ""
EPT_SETTINGS_NAME_DISPLAY_SHOW_BACKGROUND_NAME = "Show Background"
EPT_SETTINGS_NAME_DISPLAY_SHOW_BACKGROUND_TOOLTIP = ""
EPT_SETTINGS_NAME_DISPLAY_GAME_NAME = "Game Mode"
EPT_SETTINGS_NAME_DISPLAY_GAME_TOOLTIP = ""
EPT_SETTINGS_NAME_DISPLAY_MOUSE_NAME = "Mouse Mode"
EPT_SETTINGS_NAME_DISPLAY_MOUSE_TOOLTIP = ""
EPT_SETTINGS_NAME_DISPLAY_HOVER_NAME = "Only Mouse Hover"
EPT_SETTINGS_NAME_DISPLAY_HOVER_TOOLTIP = ""

EPT_SETTINGS_TRANSPARENCY = "Clear Screen (Experimental)"
EPT_SETTINGS_TRANSPARENCY_NAME = "Hide icons when not in combat"
EPT_SETTINGS_TRANSPARENCY_WARNING = "With this option enabled icons can not be moved when not in combat."


EPT_SETTINGS_SPECIAL = "Special Sets"

EPT_SETTINGS_SPECIAL_ZEN_FOCUS_NAME = "Focus on Boss"
EPT_SETTINGS_SPECIAL_ZEN_FOCUS_TOOLTIP = "Shows Z'en stacks permantly for the boss, if only one is present instead of the targeted unit"
EPT_SETTINGS_SPECIAL_ZEN_FOCUS_HINT = "To change this option during combat a hotkey can be assigned or the chat command used */eptzen* used"
EPT_SETTINGS_SPECIAL_ZEN_FOCUS_NOTE = "Note: Information about units can only be obtained when targeted by rectile or if the unit is classified as a boss.\n"..
"Since Zen is usually only applied to the boss. This option makes it easiert to track it, even when not looking at the boss.\n"..
"However, there may be situations where this is not wanted. Therefore the chat-command and hotkey are provided. \n"

EPT_SETTINGS_SPECIAL_OPPORTUNIST_SLAYER = "Show expected major slayer duration."
EPT_SETTINGS_SPECIAL_OPPORTUNIST_AFFECTED = "Show Number of affected units."

EPT_SETTINGS_SPECIAL_MARTIAL_STAMINA_NAME = "Show Stamina Bar"
EPT_SETTINGS_SPECIAL_MARTIAL_STAMINA_NOTE = "Note: To adapt the stamina bar to icon size changes a /reloadui is needed at the moment."

------------
-- Filter --
------------

EPT_WHITELIST = "Whitelist"
EPT_BLACKLIST = "Blacklist"

EPT_ADD_TO = "Add to"
EPT_REMOVE_FROM = "Remove from"

-----------------
-- Menu Filter --
-----------------

EPT_SETTINGS_FILTER_WHITE = "Whitelist"
EPT_SETTINGS_FILTER_BLACK = "Blacklist"
EPT_SETTINGS_FILTER = "Filter"
EPT_SETTINGS_FILTER_ACTIVE_NAME = "Activate Filter"
EPT_SETTINGS_FILTER_ACTIVE_TOOLTIP = ""
EPT_SETTINGS_FILTER_TYPE_NAME = "Select Filter Type"
EPT_SETTINGS_FILTER_TYPE_TOOLTIP = "Whitelist = ON; Blacklist = OFF"
EPT_SETTINGS_FILTER_MANAGE_LIST = "Manage FIlterlists"
EPT_SETTINGS_FILTER_SELECT_ACTION ="Select Action"
EPT_SETTINGS_FILTER_SELECT_ACTION_TOOLTIP = "Add = ON; Remove = OFF"
EPT_SETTINGS_FILTER_SELECT_ORIGIN = "Select Origin"
EPT_SETTINGS_FILTER_SELECT_SET = "Select Set"
EPT_SETTINGS_BUTTON_ADD = "Add"
EPT_SETTINGS_BUTTON_REMOVE = "Remove"
EPT_SETTINGS_FILTER_BUTTON = "Execute"

EPT_SETTINGS_FILTER_SET_INFO = "Set Info"
