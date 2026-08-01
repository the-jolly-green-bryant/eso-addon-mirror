------------------------------------------------
-- Russian localization for OfferedItems
------------------------------------------------

ZO_CreateStringId("OI_CHECK_LISTING",       "Check your listings on the Guild Merchant's [Listings] tab.")
ZO_CreateStringId("OI_TOGGLE",              "Переключить отображение списков")
ZO_CreateStringId("OI_GUILD_NAME",          "В продаже|c<<1>>@<<2>>|r　　")
ZO_CreateStringId("OI_IN_SALE",             "В продаже　　")
ZO_CreateStringId("OI_LISTING",             "Список объявлений")
ZO_CreateStringId("OI_HIDE_NO_TRADER",      "Гильдии без торговца скрыты")
ZO_CreateStringId("OI_SOLD_NOTIFICATION",   "Уведомление о продаже предмета")
ZO_CreateStringId("OI_OPEN_STORE",          "Открыть с магазином")
ZO_CreateStringId("OI_MARK",                "знак")
ZO_CreateStringId("OI_SHOW_MARK",           "Показать отметку в инвентарном списке")
ZO_CreateStringId("OI_CHOICE_MARK",         "Выберите значок")
ZO_CreateStringId("OI_SIZE",                "Размер")
ZO_CreateStringId("OI_VERTICAL_POS",        "Вертикальная позиция")
ZO_CreateStringId("OI_HORIZONTAL_POS",      "Горизонтальная позиция")
ZO_CreateStringId("OI_LOG",                 "Показать журнал")
ZO_CreateStringId("OI_DEBUG_LOG",           "Показать журнал отладки")




function OfferedItems:GetStoreNPC()
    return {
        "Ролис Хлаалу",          -- [ru.lang.csv] "8290981","0","74874","xxxxxxx","Ролис Хлаалу^M"
        "Фаустина Куриона",  -- [ru.lang.csv] "8290981","0","82482","xxxxxxx","Фаустина Куриона^F"
    }
end

