local localization_strings = {
    SI_SETTINGS_ICON = "Icon",
    SI_SETTINGS_ICON_SIZE = "Icon Size",
    SI_SETTINGS_ICON_X = "Icon X axis offset",
    SI_SETTINGS_ICON_Y = "Icon Y axis offset",
    SI_SETTINGS_COLOR = "Color",
    SI_SETTINGS_LOOT_NOTIFICATIONS = "Uncollected items loot notifications",
    SI_SETTINGS_LOOT_NOTIFICATIONS_ONLY_MY = "Only my loot",
    SI_SETTINGS_LOOT_NOTIFICATIONS_SET_INFO = "Show item set info",
    SI_SETTINGS_CHAT_ICONS = "Chat icons on uncollected item links",
    SI_SETTINGS_AUTO_BIND = "Auto Bind",
    SI_SETTINGS_UI_ENHANCEMENTS = "UI enhancements",
    SI_SETTINGS_LOOT_POSTING = "Loot posting",
    SI_SETTINGS_LOOT_POSTING_ARMOR = GetString(SI_ITEMTYPEDISPLAYCATEGORY2),
    SI_SETTINGS_LOOT_POSTING_JEWELRY = GetString(SI_ITEMTYPEDISPLAYCATEGORY3),
    SI_SETTINGS_LOOT_POSTING_WEAPON = GetString(SI_ITEMTYPEDISPLAYCATEGORY1),
    SI_SETTINGS_LOOT_POSTING_MONSTER_SET = "Monster set",
}

for stringId, stringValue in pairs(localization_strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end
