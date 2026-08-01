-- -----------------------------------------------------------------------------
-- Lang/Default.lua (English / Base)
-- -----------------------------------------------------------------------------
local defaultStrings = {
    SKILLBLOCKER_NJ_UNLOCK_ALL                         = "Unlock all",
    SKILLBLOCKER_NJ_UNLOCKED                           = "Unlocked",
    SKILLBLOCKER_NJ_LOCKED                             = "Locked",
    SKILLBLOCKER_NJ_LOCKED_COMBAT                      = "Locked in combat",
    SKILLBLOCKER_NJ_LOCKED_ACTIVE                      = "Locked while active",
    SKILLBLOCKER_NJ_LOADED                             = "Loaded Successfully",
    SKILLBLOCKER_NJ_LOCKED_WEREWOLF                    = "Locked in Werewolf form",

    SKILLBLOCKER_NJ_BLOCK_SETTINGS                     = "Block settings",
    SKILLBLOCKER_NJ_BLOCK_STACKS                       = "Block if stacks <",
    SKILLBLOCKER_NJ_BLOCK_CRUX                         = "Block if crux <",
    SKILLBLOCKER_NJ_BLOCK_REVERSE                      = "Block if crux ≥",
    SKILLBLOCKER_NJ_BLOCK_PROC                         = "Block until <<1>> proc",
    SKILLBLOCKER_NJ_BLOCK_HP                           = "Block if target HP >",
    SKILLBLOCKER_NJ_BLOCK_ULTIMATE                     = "Block if < <<1>> points",
    SKILLBLOCKER_NJ_BLOCK_DURATION                     = "Block for <<1>> sec.",
    SKILLBLOCKER_NJ_BLOCK_DEBUFF                       = "Block until <<1>> explosion",

    SKILLBLOCKER_NJ_GENERAL_SETTINGS                   = "General Settings",
    SKILLBLOCKER_NJ_REMEMBER                           = "Remember locked skills?",
    SKILLBLOCKER_NJ_SHOW_ALERT                         = "Show alert",
    SKILLBLOCKER_NJ_ALERT_TOOLTIP                      = "Show system warning when trying to use blocked skill",

    SKILLBLOCKER_NJ_DOUBLE_CAST_BLOCK_SETTINGS         = "Double Cast Protection",
    SKILLBLOCKER_NJ_RESET_DOUBLE_CAST_LA               = "Reset protection after Light Attack",
    SKILLBLOCKER_NJ_RESET_DOUBLE_CAST_LA_TOOLTIP       = "If enabled, a light attack (LMB) instantly removes the double cast protection.",
    SKILLBLOCKER_NJ_DOUBLE_CAST_BLOCK_DURATION         = "Protection duration",
    SKILLBLOCKER_NJ_DOUBLE_CAST_BLOCK_DURATION_TOOLTIP = "Time in seconds the button remains inactive after use (0 = ∞).",

    SKILLBLOCKER_NJ_MENU_ACTIVE_BLOCKS_TITLE           = "My list of blocked skills:",
    SKILLBLOCKER_NJ_MAIN_BAR                           = "Main Bar:",
    SKILLBLOCKER_NJ_BACK_BAR                           = "Back Bar:",

    SKILLBLOCKER_NJ_ACTION_ENABLE                      = "Enable",
    SKILLBLOCKER_NJ_ACTION_DISABLE                     = "Disable",

    SKILLBLOCKER_NJ_MENU_DOUBLE_CAST_TITLE             = "Block double cast",
    SKILLBLOCKER_NJ_MENU_STACK_TITLE                   = "Block by Stacks",
    SKILLBLOCKER_NJ_MENU_CRUX_TITLE                    = "Block by Crux",
    SKILLBLOCKER_NJ_MENU_PROC_TITLE                    = "Block by Skill Proc",
    SKILLBLOCKER_NJ_MENU_DEBUFF_TITLE                  = "Block by Skill «Explosion»",
    SKILLBLOCKER_NJ_MENU_ULTIMATE_TITLE                = "Block by Ultimate Points",
    SKILLBLOCKER_NJ_MENU_DURATION_TITLE                = "Block by Duration",
    SKILLBLOCKER_NJ_MENU_HP_TITLE                      = "Block by Target Health",
    SKILLBLOCKER_NJ_MENU_CRIMINAL_TITLE                = "Block «Criminal Act»",

    SKILLBLOCKER_NJ_DELETE_FROM_SLOT                   = "Delete from slot",

    SI_BINDING_NAME_SKILLBLOCKER_NJ_UNLOCK_ALL         = "Unlock all skills",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_1      = "Toggle Lock: Slot 1",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_2      = "Toggle Lock: Slot 2",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_3      = "Toggle Lock: Slot 3",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_4      = "Toggle Lock: Slot 4",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_5      = "Toggle Lock: Slot 5",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_6      = "Toggle Lock: Ultimate",
}

for stringId, stringValue in pairs(defaultStrings) do
    ZO_CreateStringId(stringId, stringValue)
end