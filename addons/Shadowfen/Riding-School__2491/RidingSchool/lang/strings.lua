-- All the texts that need a translation. As this is being used as the
-- default (fallback) language, all strings that the addon uses MUST
-- be defined here.

-- default language is english
RidingSchool_localization_strings = RidingSchool_localization_strings  or {}

RidingSchool_localization_strings["en"] = {
	RS_STABLE_MASTER = "stablemaster",  -- must be lower case
    
	RS_NAME = "RidingSchool",
	RS_ACCOUNTWIDE = "Apply these settings account-wide:",
	RS_ACCOUNTWIDE_TT = "If ON, these settings apply account-wide instead of just to this one character.",
    
    RS_DISABLES_HDR = "Disables",
    RS_DISABLES_DESC = "Disable the automatic training for a particular riding skill line.",
    RS_DISABLE_SPEED = "Disable automatic training of Speed",
    RS_DISABLE_STAMINA = "Disable automatic training of Stamina",
    RS_DISABLE_CAPACITY = "Disable automatic training of Carry Capacity",
    
    RS_ORDER_HDR = "Training Order",
    RS_ORDER_DESC = "Choose what order the individual riding skills (still enabled) are trained in. Selecting a skill from the dropdown will swap that skill in and put the previous skill in the other's place.",
    RS_ORDER_FIRST = "1st",
    RS_ORDER_SECOND = "2nd",
    RS_ORDER_THIRD = "3rd",
    
    RS_THRESHOLDS_HDR = "Set Thresholds",
    RS_THRESHOLDS_DESC = "Set the level you want to train up to before switching to a new skill to train. Once all skills are at their threshold levels, continue training skills in order up to the maximum level.",
    
    RS_NOPT_SPEED = "Speed",
	RS_NOPT_STAMINA = "Stamina",
	RS_NOPT_CAPACITY = "Carrying Capacity",
    
    RS_UNNEEDED_DESC = "Riding skills are fully trained for this character.",

    RS_SLASH_HELP = "Print this help message",
    RS_SLASH_SETTINGS = "Open settings window for RidingSchool",
    RS_SLASH_DEBUG = "Toggle debug messages for RidingSchool",
    RS_SLASH_DISPLAY = "Display current training order and thresholds",
}
