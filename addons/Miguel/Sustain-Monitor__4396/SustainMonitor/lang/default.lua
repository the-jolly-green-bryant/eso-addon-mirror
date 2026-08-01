-- SustainMonitor: English Localization (Default)
SustainMonitor = SustainMonitor or {}

SustainMonitor.L = {
    -- General
    ADDON_NAME          = "Sustain Monitor",
    ADDON_DESCRIPTION   = "Real-time resource dashboard with burn-rate and time-to-empty prediction",

    -- Resources
    MAGICKA             = "Magicka",
    STAMINA             = "Stamina",
    HEALTH              = "Health",
    POTION              = "Potion",
    MAGICKA_SHORT       = "M",
    STAMINA_SHORT       = "S",
    HEALTH_SHORT        = "H",

    -- Display
    INFINITY            = "\226\136\158",  -- UTF-8: ∞
    READY               = "Ready",
    PER_SECOND          = "/s",
    NO_DATA             = "---",

    -- Styles
    STYLE_SIMPLE        = "Simple",
    STYLE_ANALYTICAL    = "Analytical",
    STYLE_COMBAT        = "Combat",

    -- Action Prompts
    PROMPT_HEAVY_ATTACK = "HEAVY ATTACK",
    PROMPT_USE_POTION   = "USE POTION",

    -- Settings: Categories
    SETTINGS_GENERAL    = "General",
    SETTINGS_DISPLAY    = "Display",
    SETTINGS_CALCULATION = "Calculation",
    SETTINGS_WARNINGS   = "Warnings",
    SETTINGS_BEHAVIOR   = "Behavior",
    SETTINGS_HEAVY_ATTACK = "Heavy Attack Suggestion",

    -- Settings: General
    SETTING_ENABLED     = "Enable Addon",
    SETTING_ENABLED_TT  = "Enable or disable the Sustain Monitor overlay",
    SETTING_LOCKED      = "Lock Position",
    SETTING_LOCKED_TT   = "Lock the HUD position to prevent accidental dragging. When locked, the HUD is click-through.",
    SETTING_SCALE       = "UI Scale",
    SETTING_SCALE_TT    = "Scale the HUD element (0.5 = half size, 2.0 = double size)",
    SETTING_RESET_POS   = "Reset Position",
    SETTING_RESET_POS_TT = "Reset the HUD to its default position",

    -- Settings: Display
    SETTING_STYLE       = "Display Style",
    SETTING_STYLE_TT    = "Simple: clean minimal display. Analytical: adds live resource graphs. Combat: large numbers with screen-center action prompts.",
    SETTING_SHOW_MAGICKA    = "Show Magicka",
    SETTING_SHOW_MAGICKA_TT = "Display Magicka burn-rate and time-to-empty",
    SETTING_SHOW_STAMINA    = "Show Stamina",
    SETTING_SHOW_STAMINA_TT = "Display Stamina burn-rate and time-to-empty",
    SETTING_SHOW_HEALTH     = "Show Health",
    SETTING_SHOW_HEALTH_TT  = "Display Health burn-rate and time-to-empty",
    SETTING_SHOW_POTION     = "Show Potion Timer",
    SETTING_SHOW_POTION_TT  = "Display potion cooldown timer",
    SETTING_SHOW_BARS       = "Show Resource Bars",
    SETTING_SHOW_BARS_TT    = "Display mini resource bars next to the values",
    SETTING_SHOW_TIME       = "Show Time-to-Empty",
    SETTING_SHOW_TIME_TT    = "Display estimated time until resource is depleted",
    SETTING_COMPACT         = "Compact Mode",
    SETTING_COMPACT_TT      = "Use a more compact display layout (Simple style only)",
    SETTING_SHOW_GRAPH      = "Show Resource Graph",
    SETTING_SHOW_GRAPH_TT   = "Display a live sparkline graph of resource history (Analytical style)",
    SETTING_SHOW_CASTS      = "Show Casts Remaining",
    SETTING_SHOW_CASTS_TT   = "Show [X] next to time-to-empty: how many abilities you can still cast based on your equipped skills (updates on bar swap)",

    -- Settings: Calculation
    SETTING_SMOOTHING       = "Smoothing Factor",
    SETTING_SMOOTHING_TT    = "Controls how reactive the burn-rate display is. Lower = smoother, Higher = more reactive. Default: 0.3",

    -- Settings: Heavy Attack
    SETTING_HA_ENABLED      = "Enable Suggestion",
    SETTING_HA_ENABLED_TT   = "Show a visual and audio hint when a Heavy Attack would be beneficial",
    SETTING_HA_THRESHOLD    = "Time Threshold (seconds)",
    SETTING_HA_THRESHOLD_TT = "Suggest Heavy Attack when time-to-empty drops below this value",
    SETTING_HA_RESOURCE_PCT = "Resource Threshold (%)",
    SETTING_HA_RESOURCE_PCT_TT = "Only suggest when resource is also below this percentage",

    -- Settings: Warnings
    SETTING_WARNINGS_ON     = "Enable Warnings",
    SETTING_WARNINGS_ON_TT  = "Enable visual warnings when resources are critically low",
    SETTING_THRESH_1        = "Warning Level 1 (Yellow)",
    SETTING_THRESH_1_TT     = "Time-to-empty threshold in seconds for yellow warning",
    SETTING_THRESH_2        = "Warning Level 2 (Orange)",
    SETTING_THRESH_2_TT     = "Time-to-empty threshold in seconds for orange warning",
    SETTING_THRESH_3        = "Warning Level 3 (Red)",
    SETTING_THRESH_3_TT     = "Time-to-empty threshold in seconds for red/flashing warning",
    SETTING_WARN_SOUND      = "Warning Sound",
    SETTING_WARN_SOUND_TT   = "Play a sound when reaching warning level 2 or 3",
    SETTING_WARN_FLASH      = "Warning Flash",
    SETTING_WARN_FLASH_TT   = "Flash the resource display when reaching warning level 3",
    SETTING_SOUND_WARNING   = "Resource Warning Sound",
    SETTING_SOUND_WARNING_TT = "Sound played when resources drop to warning level. Selecting a sound will preview it.",
    SETTING_SOUND_HEAVY     = "Heavy Attack Sound",
    SETTING_SOUND_HEAVY_TT  = "Sound played when a Heavy Attack is suggested. Selecting a sound will preview it.",
    SETTING_SOUND_POTION    = "Potion Ready Sound",
    SETTING_SOUND_POTION_TT = "Sound played when your potion comes off cooldown. Selecting a sound will preview it.",

    -- Settings: Alert Appearance
    SETTINGS_ALERT_APPEARANCE   = "Alert Appearance",
    SETTING_COLOR_WARN_YELLOW   = "Warning Color 1 (Yellow)",
    SETTING_COLOR_WARN_YELLOW_TT = "Color for the first warning level (default: yellow)",
    SETTING_COLOR_WARN_ORANGE   = "Warning Color 2 (Orange)",
    SETTING_COLOR_WARN_ORANGE_TT = "Color for the second warning level (default: orange)",
    SETTING_COLOR_WARN_RED      = "Warning Color 3 (Red)",
    SETTING_COLOR_WARN_RED_TT   = "Color for the third warning level and flashing (default: red)",
    SETTING_ALERT_FONT_SIZE     = "Alert Font Size",
    SETTING_ALERT_FONT_SIZE_TT  = "Font size for the center-screen action prompts (Heavy Attack / Use Potion)",

    -- Settings: Potion Appearance
    SETTINGS_POTION_APPEARANCE      = "Potion Appearance",
    SETTING_COLOR_POTION            = "Potion Color",
    SETTING_COLOR_POTION_TT         = "Color for the potion label and cooldown highlight (default: cyan)",
    SETTING_COLOR_POTION_READY      = "Potion Ready Color",
    SETTING_COLOR_POTION_READY_TT   = "Color shown when the potion is ready and resources are OK (default: green)",
    SETTING_POTION_FONT_SIZE        = "Potion Row Font Size",
    SETTING_POTION_FONT_SIZE_TT     = "Font size for the potion timer row in the HUD",

    -- Settings: Behavior
    SETTING_HIDE_OOC        = "Hide Out of Combat",
    SETTING_HIDE_OOC_TT     = "Automatically hide the HUD when not in combat",
    SETTING_FADE_DELAY      = "Fade Delay (seconds)",
    SETTING_FADE_DELAY_TT   = "Seconds to wait after combat ends before hiding the HUD",

    -- Settings: Debug
    SETTINGS_DEBUG          = "Developer",
    SETTING_DEBUG_MODE      = "Debug Mode",
    SETTING_DEBUG_MODE_TT   = "Print debug messages to chat (also toggleable via /sm debug)",

    -- Resource Focus
    SETTING_FOCUS       = "Resource Focus",
    SETTING_FOCUS_TT    = "Which resource to prioritize for warnings and alerts. Auto detects based on your combat usage.",
    FOCUS_AUTO          = "Auto (detect)",
    FOCUS_ALL           = "All Resources",
    FOCUS_MAGICKA       = "Magicka",
    FOCUS_STAMINA       = "Stamina",
    FOCUS_HEALTH        = "Health",

    -- Potion Focus Mismatch
    FOCUS_MISMATCH          = "Focus!",

    -- Graph Style
    SETTING_GRAPH_STYLE     = "Graph Style",
    SETTING_GRAPH_STYLE_TT  = "Visual style for the resource history graph in Analytical mode",
    GRAPH_STYLE_LINE        = "Line Graph",
    GRAPH_STYLE_BAR         = "Bar Chart",

    -- Slash commands
    SLASH_HELP = "Sustain Monitor commands:\n/sm - Show help\n/sm toggle - Toggle HUD\n/sm sounds - Play test sounds\n/sm debug - Toggle debug mode\n/sm dump - Print diagnostics",
}
