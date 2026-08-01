local labels = {
    HG_MENU_GLOBAL_SETTINGS = "General",
    HG_MENU_ENABLED = "Enabled",
    HG_MENU_DEBUG = "Debug",
    HG_MENU_OPTIONAL_SETTINGS = "Optional",
    HG_MENU_NAMEPLATE_MODE = "Show Nameplates",
    HG_MENU_HEALTHBAR_MODE = "Show Health Bars",
    HG_MENU_CHOICE_NEVER = "Never",
    HG_MENU_CHOICE_ALWAYS = "Always",
    HG_MENU_CHOICE_INJURED = "Injured",
}

for key, value in pairs(labels) do
    SafeAddVersion(key, 1)
    ZO_CreateStringId(key, value)
end
