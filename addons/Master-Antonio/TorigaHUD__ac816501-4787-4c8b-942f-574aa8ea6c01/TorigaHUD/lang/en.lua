-- English Localization Strings for TorigaHUD
local strings = {
    BINDING_NAME_TORIGAHUD_TOGGLE_DRAG = "Unlock/Lock HUD Position",
    
    TORIGAHUD_SETTINGS_DISPLAY_NAME = "|cFFD700TorigaHUD|r Settings",
    TORIGAHUD_SETTINGS_GENERAL_HEADER = "General Settings",
    TORIGAHUD_SETTINGS_HIDE_OOC = "Hide Out of Combat",
    TORIGAHUD_SETTINGS_HIDE_OOC_TT = "If active, hides resource bars when you are out of combat and do not have an active target.",
    TORIGAHUD_SETTINGS_SHOW_SHIELDS = "Show Protective Shield",
    TORIGAHUD_SETTINGS_SHOW_SHIELDS_TT = "If enabled, shows a semi-transparent blue overlay bar on top of health to indicate active shielding.",
    TORIGAHUD_SETTINGS_LERP_SPEED = "Bar Animation Speed",
    TORIGAHUD_SETTINGS_LERP_SPEED_TT = "Adjusts how fast the resource bars slide. (1.00 = instant updates, no animation)",
    TORIGAHUD_SETTINGS_SEGMENT_SIZE = "Value per Segment (Health/Resources)",
    TORIGAHUD_SETTINGS_SEGMENT_SIZE_TT = "Adjusts how many resource points each block represents (Health, Magicka, Stamina, Target). E.g. 2000 means each block is 2000 points.",
    TORIGAHUD_SETTINGS_SCALE = "HUD Scale (Size)",
    TORIGAHUD_SETTINGS_SCALE_TT = "Adjusts the global scale of all HUD elements.",
    TORIGAHUD_SETTINGS_PRESETS_HEADER = "Presets & Positioning",
    TORIGAHUD_SETTINGS_PRESET = "Layout Preset",
    TORIGAHUD_SETTINGS_PRESET_TT = "Select a predefined layout to instantly rearrange the HUD.",
    TORIGAHUD_SETTINGS_PRESET_DEFAULT = "Default",
    TORIGAHUD_SETTINGS_PRESET_VERTICAL = "Focus Combat (Vertical)",
    TORIGAHUD_SETTINGS_PRESET_HORIZONTAL = "Focus Combat (Horizontal)",
    TORIGAHUD_SETTINGS_PRESET_MINIMALIST = "Minimalist (Compact)",
    TORIGAHUD_SETTINGS_UNLOCK = "Unlock HUD Position",
    TORIGAHUD_SETTINGS_UNLOCK_TT = "Enable this option to unlock the frames. This will close the options menu and show an Apply/Cancel dialog to position the elements with your mouse.",
    TORIGAHUD_SETTINGS_RESET = "Reset Default Positions",
    TORIGAHUD_SETTINGS_RESET_TT = "Restores all HUD bars to their original position.",
    
    TORIGAHUD_DRAG_XP = "XP",
    TORIGAHUD_DRAG_TARGET = "TARGET",
    
    TORIGAHUD_DIALOG_TITLE = "DRAG BARS WHEREVER YOU WANT",
    TORIGAHUD_DIALOG_APPLY = "APPLY",
    TORIGAHUD_DIALOG_CANCEL = "CANCEL",
    
    TORIGAHUD_TEXT_HEALTH = "HEALTH",
    TORIGAHUD_TEXT_LEVEL = "LEVEL",
    TORIGAHUD_TEXT_XP = "EXPERIENCE",
    TORIGAHUD_TEXT_MAGICKA = "MAGICKA",
    TORIGAHUD_TEXT_STAMINA = "STAMINA",
    TORIGAHUD_TEXT_TARGET_TEST = "TEST TARGET",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId("SI_" .. stringId, stringValue)
end
