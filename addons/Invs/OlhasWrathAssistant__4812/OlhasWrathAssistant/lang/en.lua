local strings = {

    ADDON_NAME = "Olha's Wrath Assistant",

    SETTINGS = "Settings",

    LANGUAGE = "Language",
    ENGLISH = "English",
    UKRAINIAN = "Ukrainian",

    ACCOUNT_WIDE = "Account Wide",

    REPAIR = "Repair & Recharge",
    REPAIR_TOOLTIP = "Enables automatic repair and weapon recharging.",
    REPAIR_PANEL = "OWRepair & Recharge",
    DECONSTRUCT = "Deconstructor",
    DECONSTRUCTOR_PANEL = "OWDeconstructor",
    MERCHANT = "Merchant",
    BANKING = "Banking",

    MASS_DECONSTRUCT = "Mass Decon",

    RELOAD_UI_WARNING = "This change requires a UI reload to take effect.",

    MODULE_IN_DEVELOPMENT = "This module is under development and will be available in a future version.",
    ACCOUNT_WIDE_IN_DEVELOPMENT = "In the test version, settings are always saved account-wide.",

}

local owa = OWAssistant
owa.RegisterLanguage("en", "English", strings)

ZO_CreateStringId(
    "SI_OWA_ADDON_NAME",
    strings.ADDON_NAME
)

ZO_CreateStringId(
    "SI_BINDING_NAME_OWA_DECONSTRUCT",
    strings.MASS_DECONSTRUCT
)
