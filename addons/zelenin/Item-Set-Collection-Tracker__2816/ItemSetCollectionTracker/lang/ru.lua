local localization_strings = {
    SI_SETTINGS_ICON = "Иконка",
    SI_SETTINGS_ICON_SIZE = "Размер иконки",
    SI_SETTINGS_ICON_X = "Сдвиг иконки по оси X",
    SI_SETTINGS_ICON_Y = "Сдвиг иконки по оси Y",
    SI_SETTINGS_COLOR = "Цвет",
    SI_SETTINGS_LOOT_NOTIFICATIONS = "Уведомления в чате о несобранных предметах",
    SI_SETTINGS_LOOT_NOTIFICATIONS_ONLY_MY = "Только мой лут",
    SI_SETTINGS_LOOT_NOTIFICATIONS_SET_INFO = "Показывать информацию о сете",
    SI_SETTINGS_CHAT_ICONS = "Иконки в чате у ссылок несобранных предметов",
    SI_SETTINGS_AUTO_BIND = "Автопривязка",
    SI_SETTINGS_UI_ENHANCEMENTS = "Улучшения интерфейса",
    SI_SETTINGS_LOOT_POSTING = "Постинг лута",
    --SI_SETTINGS_LOOT_POSTING_ARMOR = GetString(SI_ITEMTYPEDISPLAYCATEGORY2),
    --SI_SETTINGS_LOOT_POSTING_JEWELRY = GetString(SI_ITEMTYPEDISPLAYCATEGORY3),
    --SI_SETTINGS_LOOT_POSTING_WEAPON = GetString(SI_ITEMTYPEDISPLAYCATEGORY1),
    SI_SETTINGS_LOOT_POSTING_MONSTER_SET = "Монстер сет",
}

for stringId, stringValue in pairs(localization_strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end
