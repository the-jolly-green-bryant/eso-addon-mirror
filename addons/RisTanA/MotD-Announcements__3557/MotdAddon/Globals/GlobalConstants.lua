-- AddonInfo section; keep formatting intact as it will be parsed
MotdAddon_Globals_AddonInfo = {
    Name = "MotdAddon",
    DisplayName = "MotD Announcements",
    Description = "Addon to print the message of the day for your guilds",
    Author = "RisTanA",
    Version = "1.1",
    SavedVariables = "MotdAddonStorage",
    Libraries = { "EsoAddonFramework", "LibAddonMenu-2.0" }
}

-- These strings are used in Bindings.xml
ZO_CreateStringId("SI_KEYBINDINGS_CATEGORY_MotdAddon_ADDON_NAME", MotdAddon_Globals_AddonInfo.DisplayName)
ZO_CreateStringId("SI_BINDING_NAME_MotdAddon_SHOW_SETTINGS", "Show settings")