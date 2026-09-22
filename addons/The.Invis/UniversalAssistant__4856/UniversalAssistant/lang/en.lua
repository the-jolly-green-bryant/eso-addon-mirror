local strings = {

    ADDON_NAME = "Universal Assistant",

    SHOW_WELCOME = "Show welcome message",
    SHOW_WELCOME_TOOLTIP = "Shows a welcome message in chat when you log in with a character.",
    WELCOME_MESSAGE = "|cFFFFFF[|r|c3A92FFU|r|cFFFFFFniversal|r|cFFFF00A|r|cFFFFFFssistant]|r at your service!",

    LANGUAGE = "Language",

    ACCOUNT_WIDE = "Use account-wide settings",
    ACCOUNT_WIDE_TOOLTIP = "Uses one settings profile for every character. A new character profile starts with the default disabled settings.",
    PROFILE_SETTINGS = "Settings profiles",
    PROFILE_SETTINGS_TOOLTIP = "Manage account-wide settings or separate settings for each character.",
    PROFILE_ACCOUNT_WIDE = "Account wide",

    ACTIVE_PROFILE = "Active profile",
    ACTIVE_PROFILE_TOOLTIP = "The settings profile currently in use.",

    COPY_SETTINGS_FROM = "Copy settings from",
    COPY_SETTINGS_FROM_TOOLTIP = "Select another character profile whose settings should be copied.",
    CONFIRM_COPY = "Confirm copy",
    CONFIRM_COPY_TOOLTIP = "Opens a confirmation dialog for copying the selected profile.",
    PROFILE_COPY_CONFIRM_TITLE = "Copy settings",
    PROFILE_COPY_CONFIRM_TEXT = "Copy settings from profile “%s” to profile “%s”? The current settings of profile “%s” will be overwritten.",

    DELETE_PROFILE = "Delete settings profile",
    DELETE_PROFILE_TOOLTIP = "Select another character profile to delete.",
    CONFIRM_DELETE = "Confirm deletion",
    CONFIRM_DELETE_TOOLTIP = "Opens a confirmation dialog for deleting the selected profile.",
    PROFILE_DELETE_CONFIRM_TITLE = "Delete profile",
    PROFILE_DELETE_CONFIRM_TEXT = "Delete settings profile “%s”? This action cannot be undone.",

    MASS_DECONSTRUCT = "Mass Decon",
}

local ua = UAssistant
ua.RegisterLanguage("en", "English", strings)

ZO_CreateStringId("SI_UA_ADDON_NAME", strings.ADDON_NAME)

ZO_CreateStringId("SI_BINDING_NAME_UA_DECONSTRUCT", strings.MASS_DECONSTRUCT)
