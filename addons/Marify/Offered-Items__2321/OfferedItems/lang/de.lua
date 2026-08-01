------------------------------------------------
-- German localization for OfferedItems
------------------------------------------------

ZO_CreateStringId("OI_CHECK_LISTING",       "Überprüfen Sie Ihre Einträge auf der Registerkarte [Auflistung] des Gildenhändlers.")
ZO_CreateStringId("OI_TOGGLE",              "Toggle display of listings")
ZO_CreateStringId("OI_GUILD_NAME",          "Zu verkaufen|c<<1>>@<<2>>|r　　")
ZO_CreateStringId("OI_IN_SALE",             "Zu verkaufen　　")
ZO_CreateStringId("OI_LISTING",             "Auflistung")
ZO_CreateStringId("OI_HIDE_NO_TRADER",      "Gilden ohne Händler werden ausgeblendet")
ZO_CreateStringId("OI_SOLD_NOTIFICATION",   "Aktiviere Verkaufsbenachrichtigung")
ZO_CreateStringId("OI_OPEN_STORE",          "Mit Store öffnen")
ZO_CreateStringId("OI_MARK",                "Kennzeichen")
ZO_CreateStringId("OI_SHOW_MARK",           "Markierung in Bestandsliste anzeigen")
ZO_CreateStringId("OI_CHOICE_MARK",         "Symbol auswählen")
ZO_CreateStringId("OI_SIZE",                "Größe")
ZO_CreateStringId("OI_VERTICAL_POS",        "Vertikale Position")
ZO_CreateStringId("OI_HORIZONTAL_POS",      "Horizontale Position")
ZO_CreateStringId("OI_LOG",                 "Protokoll anzeigen")
ZO_CreateStringId("OI_DEBUG_LOG",           "Debug-Protokoll anzeigen")




function OfferedItems:GetStoreNPC()
    return {
        "Rolis Hlaalu",     -- [de.lang.csv] "8290981","0","74874","xxxxxxx","Rolis Hlaalu^M"
        "Faustina Curio",   -- [de.lang.csv] "8290981","0","82482","xxxxxxx","Faustina Curio^F"
    }
end

