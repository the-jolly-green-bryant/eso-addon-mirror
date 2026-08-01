ZO_CreateStringId("SI_ITEMBROWSER_TITLE"           , "Set Junker");
ZO_CreateStringId("SI_DETAILED_OPTIONS"            , "Detailed Options");

ZO_CreateStringId("SI_ITEMBROWSER_HEADER_NAME"     , "Name");
ZO_CreateStringId("SI_ITEMBROWSER_HEADER_TYPE"     , "Type");
ZO_CreateStringId("SI_ITEMBROWSER_HEADER_SOURCE"   , "Source");
ZO_CreateStringId("SI_ITEMBROWSER_HEADER_JUNK"     , "Junk");

ZO_CreateStringId("SI_ITEMBROWSER_TYPE_CRAFTED"    , GetString(SI_ITEM_FORMAT_STR_CRAFTED));
ZO_CreateStringId("SI_ITEMBROWSER_TYPE_MONSTER"    , GetString("SI_VISUALARMORTYPE", VISUAL_ARMORTYPE_UNDAUNTED));
ZO_CreateStringId("SI_ITEMBROWSER_TYPE_MIXED"      , "Mixed");

ZO_CreateStringId("SI_ITEMBROWSER_SOURCE_SPECIAL1" , GetString(SI_DUNGEON_FINDER_RANDOM_FILTER_TEXT));
ZO_CreateStringId("SI_ITEMBROWSER_SOURCE_SPECIAL2" , GetString(SI_BATTLEGROUND_HUD_HEADER));
ZO_CreateStringId("SI_ITEMBROWSER_SOURCE_SPECIAL3" , GetString(SI_LEVEL_UP_REWARDS_GAMEPAD_ENTRY_NAME));
ZO_CreateStringId("SI_ITEMBROWSER_SOURCE_SPECIAL4" , LocalizeString("<<t:1>>", GetItemLinkName("|H1:item:145577:122:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")));

ZO_CreateStringId("SI_ITEMBROWSER_SEARCHDROP1"     , "Search by name/type/source");
ZO_CreateStringId("SI_ITEMBROWSER_SEARCHDROP2"     , "Search by set bonuses");

ZO_CreateStringId("SI_ITEMBROWSER_FILTERDROP1"     , "All Categories");
ZO_CreateStringId("SI_ITEMBROWSER_FILTERDROP2"     , GetString(SI_ITEMBROWSER_TYPE_CRAFTED));
ZO_CreateStringId("SI_ITEMBROWSER_FILTERDROP3"     , "Overland");
ZO_CreateStringId("SI_ITEMBROWSER_FILTERDROP4"     , GetAchievementCategoryInfo(GetCategoryInfoFromAchievementId(935)));
ZO_CreateStringId("SI_ITEMBROWSER_FILTERDROP5"     , GetAchievementCategoryInfo(GetCategoryInfoFromAchievementId(294)));
ZO_CreateStringId("SI_ITEMBROWSER_FILTERDROP6"     , GetString("SI_RAIDCATEGORY", RAID_CATEGORY_TRIAL));
ZO_CreateStringId("SI_ITEMBROWSER_FILTERDROP7"     , GetString("SI_BINDTYPE", BIND_TYPE_ON_EQUIP));
ZO_CreateStringId("SI_ITEMBROWSER_FILTERDROP8"     , GetString("SI_BINDTYPE", BIND_TYPE_ON_PICKUP));

ZO_CreateStringId("SI_SETJUNKER_RARITY0"     , "Do not junk");
ZO_CreateStringId("SI_SETJUNKER_RARITY1"     , "Normal");
ZO_CreateStringId("SI_SETJUNKER_RARITY2"     , "Fine");
ZO_CreateStringId("SI_SETJUNKER_RARITY3"     , "Superior");
ZO_CreateStringId("SI_SETJUNKER_RARITY4"     , "Epic");
ZO_CreateStringId("SI_SETJUNKER_RARITY5"     , "Legendary");
