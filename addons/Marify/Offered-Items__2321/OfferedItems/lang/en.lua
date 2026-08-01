------------------------------------------------
-- English localization for OfferedItems
------------------------------------------------

ZO_CreateStringId("OI_CHECK_LISTING",       "Check your listings on the Guild Merchant's [Listings] tab.")
ZO_CreateStringId("OI_TOGGLE",              "Toggle display of listings")
ZO_CreateStringId("OI_GUILD_NAME",          "In sale|c<<1>>@<<2>>|r　　")
ZO_CreateStringId("OI_IN_SALE",             "In sale　　")
ZO_CreateStringId("OI_LISTING",             "Listings")
ZO_CreateStringId("OI_HIDE_NO_TRADER",      "Guilds without a merchant are hidden")
ZO_CreateStringId("OI_SOLD_NOTIFICATION",   "Enable Item Sold Notification")
ZO_CreateStringId("OI_OPEN_STORE",          "Open With Store")
ZO_CreateStringId("OI_MARK",                "Mark")
ZO_CreateStringId("OI_SHOW_MARK",           "Show Mark in Inventory List")
ZO_CreateStringId("OI_CHOICE_MARK",         "Select icon")
ZO_CreateStringId("OI_SIZE",                "Size")
ZO_CreateStringId("OI_VERTICAL_POS",        "Vertical position")
ZO_CreateStringId("OI_HORIZONTAL_POS",      "Horizontal position")
ZO_CreateStringId("OI_LOG",                 "Show log")
ZO_CreateStringId("OI_DEBUG_LOG",           "Show debug log")




function OfferedItems:GetStoreNPC()
    return {
        "Rolis Hlaalu",     -- [en.lang.csv] "8290981","0","74874","xxxxxxx","Rolis Hlaalu^M"
        "Faustina Curio",   -- [en.lang.csv] "8290981","0","82482","xxxxxxx","Faustina Curio^F"
    }
end

