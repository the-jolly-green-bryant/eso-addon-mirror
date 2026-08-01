local labels = {
    HG_MENU_GLOBAL_SETTINGS = "Général",
    HG_MENU_ENABLED = "Activé",
    HG_MENU_DEBUG = "Debug",
    HG_MENU_OPTIONAL_SETTINGS = "Options",
    HG_MENU_NAMEPLATE_MODE = "Montrer les noms",
    HG_MENU_HEALTHBAR_MODE = "Montrer les barres de vie",
    HG_MENU_CHOICE_NEVER = "Jamais",
    HG_MENU_CHOICE_ALWAYS = "Toujours",
    HG_MENU_CHOICE_INJURED = "Blessé",
}

for key, value in pairs(labels) do
    SafeAddVersion(key, 1)
    ZO_CreateStringId(key, value)
end
