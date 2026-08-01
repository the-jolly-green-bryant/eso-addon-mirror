local labels = {
    HG_MENU_GLOBAL_SETTINGS = "General",
    HG_MENU_ENABLED = "Enabled",
    HG_MENU_DEBUG = "Debug",
    HG_MENU_OPTIONAL_SETTINGS = "Optional",
    HG_MENU_HIDE_NAMEPLATES = "Hide Nameplates",
    HG_MENU_HIDE_HEALTHBARS = "Hide Health Bars"
}

for key, value in pairs(labels) do
    SafeAddVersion(key, 1)
    ZO_CreateStringId(key, value)
end
