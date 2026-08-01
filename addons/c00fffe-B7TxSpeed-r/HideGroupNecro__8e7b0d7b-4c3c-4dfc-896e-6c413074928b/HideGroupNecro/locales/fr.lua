local labels = {
    HG_MENU_GLOBAL_SETTINGS = "Général",
    HG_MENU_ENABLED = "Activé",
    HG_MENU_DEBUG = "Debug",
    HG_MENU_OPTIONAL_SETTINGS = "Options",
    HG_MENU_HIDE_NAMEPLATES = "Cacher les noms",
    HG_MENU_HIDE_HEALTHBARS = "Cacher les barres de vie"
}

for key, value in pairs(labels) do
    SafeAddVersion(key, 1)
    ZO_CreateStringId(key, value)
end
