local labels = {
    FCI_MENU_GLOBAL_SETTINGS = "General",
    FCI_MENU_DEBUG = "Debug",
    FCI_MENU_KA = "Kyne's Aegis",
    FCI_MENU_KA_FALGRAVN_1ST_FLOOR = "Show Falgravn 1st Floor Icons",
    FCI_MENU_KA_FALGRAVN_2ND_FLOOR = "Show Falgravn 2nd Floor Icons",
    FCI_MENU_KA_FALGRAVN_LIGHTNING = "Show Falgravn Lightning Positions",
    FCI_MENU_KA_FALGRAVN_ICON_SIZE = "Falgravn Icon Size",
}

for key, value in pairs(labels) do
    SafeAddVersion(key, 1)
    ZO_CreateStringId(key, value)
end
