local Register = LibCodesCommonCode.RegisterString

Register("SI_ITEMBROWSER_TITLE"           , "Item Set Browser")

Register("SI_ITEMBROWSER_HEADER_NAME"     , "Name")
Register("SI_ITEMBROWSER_HEADER_TYPE"     , "Type")
Register("SI_ITEMBROWSER_HEADER_SOURCE"   , "Source")

Register("SI_ITEMBROWSER_COLLECTED_COUNT" , "%d / %d collected (%d%%)")

Register("SI_ITEMBROWSER_TYPE_CRAFTED"    , GetString(SI_ITEM_FORMAT_STR_CRAFTED))
Register("SI_ITEMBROWSER_TYPE_MONSTER"    , "Monster")

Register("SI_ITEMBROWSER_SEARCHDROP1"     , "Search by name/type/source")
Register("SI_ITEMBROWSER_SEARCHDROP2"     , "Search by set bonuses")

Register("SI_ITEMBROWSER_FILTERDROP1"     , "All Categories")
Register("SI_ITEMBROWSER_FILTERDROP2"     , GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_COLLECTIBLE))
Register("SI_ITEMBROWSER_FILTERDROP3"     , GetString(SI_ITEMBROWSER_TYPE_CRAFTED))
Register("SI_ITEMBROWSER_FILTERDROP4"     , "Overland")
Register("SI_ITEMBROWSER_FILTERDROP5"     , GetString("SI_GUILDACTIVITYATTRIBUTEVALUE", GUILD_ACTIVITY_ATTRIBUTE_VALUE_PVP))
Register("SI_ITEMBROWSER_FILTERDROP6"     , GetString("SI_GUILDACTIVITYATTRIBUTEVALUE", GUILD_ACTIVITY_ATTRIBUTE_VALUE_DUNGEONS))
Register("SI_ITEMBROWSER_FILTERDROP7"     , GetString("SI_GUILDACTIVITYATTRIBUTEVALUE", GUILD_ACTIVITY_ATTRIBUTE_VALUE_TRIALS))
Register("SI_ITEMBROWSER_FILTERDROP8"     , "Arenas")
Register("SI_ITEMBROWSER_FILTERDROP9"     , GetString(SI_MAP_INFO_MODE_ANTIQUITIES))
Register("SI_ITEMBROWSER_FILTERDROP10"    , GetString("SI_BINDTYPE", BIND_TYPE_ON_EQUIP))
Register("SI_ITEMBROWSER_FILTERDROP11"    , GetString("SI_BINDTYPE", BIND_TYPE_ON_PICKUP))
Register("SI_ITEMBROWSER_FILTERDROP12"    , GetString(SI_ANTIQUITY_SCRYABLE_CURRENT_ZONE_SUBCATEGORY))
Register("SI_ITEMBROWSER_FILTERDROP13"    , GetString(SI_COLLECTIONS_FAVORITES_CATEGORY_HEADER))
Register("SI_ITEMBROWSER_FILTERDROP14"    , "Today's Pledges")

Register("SI_ITEMBROWSER_TT_HEADER_ACCTS" , "Collected By")

Register("SI_ITEMBROWSER_SECTION_GENERAL" , "General")
Register("SI_ITEMBROWSER_SECTION_TTCLR_P" , "Tooltip Colors: Set Pieces")
Register("SI_ITEMBROWSER_SECTION_TTCLR_A" , "Tooltip Colors: Accounts")
Register("SI_ITEMBROWSER_SECTION_TTEXT"   , "External Tooltips")

Register("SI_ITEMBROWSER_SETTING_PERCENT" , "Show completion percentage instead of cost")
Register("SI_ITEMBROWSER_SETTING_TT"      , "Add information to external item tooltips")
Register("SI_ITEMBROWSER_SETTING_TT_P"    , "Show collection status for set pieces")
Register("SI_ITEMBROWSER_SETTING_TT_A"    , "Show collection status for other accounts")
Register("SI_ITEMBROWSER_SETTING_TT_A_EX" , "This information will not appear if there is data for only one account. Requires LibMultiAccountSets.")

Register("SI_ITEMBROWSER_TT_INVALID_HEAD" , "Not Collectible")
Register("SI_ITEMBROWSER_TT_INVALID_MSG1" , "This item has been discontinued and is not collectible.")
Register("SI_ITEMBROWSER_TT_INVALID_MSG2" , "This item cannot be added to your set collections.")
