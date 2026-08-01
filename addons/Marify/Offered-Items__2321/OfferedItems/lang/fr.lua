------------------------------------------------
-- French localization for OfferedItems
------------------------------------------------

ZO_CreateStringId("OI_CHECK_LISTING",       "Vérifiez vos annonces dans l'onglet [Mises en vente] du marchand de guilde.")
ZO_CreateStringId("OI_TOGGLE",              "Toggle display of listings")
ZO_CreateStringId("OI_GUILD_NAME",          "En vente|c<<1>>@<<2>>|r　　")
ZO_CreateStringId("OI_IN_SALE",             "En vente　　")
ZO_CreateStringId("OI_LISTING",             "Mises en vente")
ZO_CreateStringId("OI_HIDE_NO_TRADER",      "Les guildes sans marchand sont cachées")
ZO_CreateStringId("OI_SOLD_NOTIFICATION",   "Activer la Notification des ventes d'objets")
ZO_CreateStringId("OI_OPEN_STORE",          "Ouvrir avec magasin")
ZO_CreateStringId("OI_MARK",                "marque")
ZO_CreateStringId("OI_SHOW_MARK",           "Afficher la marque dans la liste d'inventaire")
ZO_CreateStringId("OI_CHOICE_MARK",         "Sélectionnez l'icône")
ZO_CreateStringId("OI_SIZE",                "Taille")
ZO_CreateStringId("OI_VERTICAL_POS",        "Position verticale")
ZO_CreateStringId("OI_HORIZONTAL_POS",      "Position horizontale")
ZO_CreateStringId("OI_LOG",                 "Afficher le journal")
ZO_CreateStringId("OI_DEBUG_LOG",           "Afficher le journal de débogage")




function OfferedItems:GetStoreNPC()
    return {
        "Rolis Hlaalu",     -- [fr.lang.csv] "8290981","0","74874","xxxxxxx","Rolis Hlaalu^M"
        "Faustina Curio",   -- [fr.lang.csv] "8290981","0","82482","xxxxxxx","Faustina Curio^F"
    }
end

