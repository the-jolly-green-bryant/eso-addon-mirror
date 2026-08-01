-- Translated by: @XXXspartiateXXX

local Register = LibCodesCommonCode.RegisterString

Register("SI_ITEMBROWSER_TITLE"           , "Item Set Browser")

Register("SI_ITEMBROWSER_HEADER_NAME"     , "Nom")
Register("SI_ITEMBROWSER_HEADER_TYPE"     , "Type")
Register("SI_ITEMBROWSER_HEADER_SOURCE"   , "Source")

Register("SI_ITEMBROWSER_COLLECTED_COUNT" , "%d / %d collecté (%d%%)")

Register("SI_ITEMBROWSER_TYPE_CRAFTED"    , GetString(SI_ITEM_FORMAT_STR_CRAFTED))
Register("SI_ITEMBROWSER_TYPE_MONSTER"    , "Monstre")

Register("SI_ITEMBROWSER_SEARCHDROP1"     , "Rechercher par nom/type/source")
Register("SI_ITEMBROWSER_SEARCHDROP2"     , "Rechercher par bonus d'ensembles")

Register("SI_ITEMBROWSER_FILTERDROP1"     , "Tous")
Register("SI_ITEMBROWSER_FILTERDROP4"     , GetString("SI_SKILLTYPE", SKILL_TYPE_WORLD))
Register("SI_ITEMBROWSER_FILTERDROP8"     , "Arènes")

Register("SI_ITEMBROWSER_WEAPONTYPE4"     , "Épée longue")
Register("SI_ITEMBROWSER_WEAPONTYPE5"     , "Hache de bataille")
Register("SI_ITEMBROWSER_WEAPONTYPE6"     , "Masse d'arme")

Register("SI_ITEMBROWSER_TT_HEADER_ACCTS" , "Collecté par")

Register("SI_ITEMBROWSER_SECTION_GENERAL" , "Général")
Register("SI_ITEMBROWSER_SECTION_TTCLR_P" , "Couleurs d'infobulle: Pièces d'ensemble")
Register("SI_ITEMBROWSER_SECTION_TTCLR_A" , "Couleurs d'infobulle: Comptes")
Register("SI_ITEMBROWSER_SECTION_TTEXT"   , "Infobulles externes et État de la collection")

Register("SI_ITEMBROWSER_SETTING_PERCENT" , "Afficher le % d'achèvement au lieu du coût")
Register("SI_ITEMBROWSER_SETTING_TT"      , "Ajoute les informations des objets externes.")
Register("SI_ITEMBROWSER_SETTING_TT_P"    , "Afficher la collection des pièces d'ensembles.")
Register("SI_ITEMBROWSER_SETTING_TT_A"    , "Afficher la collection pour d'autres comptes.")
Register("SI_ITEMBROWSER_SETTING_TT_A_EX" , "Ces informations n'apparaîtront pas s'il n'existe des données que pour un seul compte. Requiert LibMultiAccountSets.")

Register("SI_ITEMBROWSER_TT_INVALID_HEAD" , "Non collectionnable")
Register("SI_ITEMBROWSER_TT_INVALID_MSG1" , "Cet objet a été arrêté et n'est pas collectionnable.")
Register("SI_ITEMBROWSER_TT_INVALID_MSG2" , "Cet objet ne peut pas être ajouté à vos collections d'ensembles.")
