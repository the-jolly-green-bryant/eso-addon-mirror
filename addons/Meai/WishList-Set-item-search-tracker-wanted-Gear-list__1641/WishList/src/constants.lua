WishList = WishList or {}
local WL = WishList

------------------------------------------------
--- Addon data
------------------------------------------------
WL.addonVars =  {}
WL.addonVars.addonRealVersion		    = 3.21
WL.addonVars.addonSavedVarsVersion	    = 2.0 --Changing this will reset the SavedVariables!!!
WL.addonVars.addonName				    = "WishList"
WL.addonVars.addonSavedVars			    = "WishList_Data"
WL.addonVars.addonSavedVarsAllServers   = "WishList_Data_All_Servers"
WL.addonVars.addonSavedVarsDefault      = "Default"
WL.addonVars.addonSavedVarsAccountWide  = "$AccountWide"
WL.addonVars.addonSavedVarsAccountWideDataTab = "AccountwideData"
WL.addonVars.addonSavedVarsDataTab      = "Data"
WL.addonVars.addonSavedVarsWishListTab  = "wishList"
WL.addonVars.addonSavedVarsHistoryTab   = "history"
WL.addonVars.addonSavedVarsLastCharacterIdentifier = "$LastCharacterName"
WL.addonVars.addonSavedVarsAccountWideServerIndependent = "AccountwideDataServerIndependent"
WL.addonVars.settingsName   		    = "WishList"
WL.addonVars.settingsDisplayName   	    = WL.addonVars.settingsName
WL.addonVars.addonAuthor			    = "Meai & Baertram"
WL.addonVars.addonWebsite			    = "http://www.esoui.com/downloads/info1641-WishList.html"
WL.addonVars.addonDonation			    = "https://www.esoui.com/portal.php?id=136&a=faq&faqid=131"
WL.addonVars.addonFeedback			    = "https://www.esoui.com/downloads/info1641-WishList.html#comments"

WL.SVrelated_doReloadUINow = false

--Libraries
WL.addonMenu = LibAddonMenu2
WL.LMM2 = LibMainMenu2
WL.LibSets = LibSets

--Constants
WISHLIST_SCENE_NAME = "WishListScene"
--For the ZO_SortList row, the datatpye
WISHLIST_DATA = 1
--The tabs of the scene multitab control
WISHLIST_TAB_SEARCH             = 1
WISHLIST_TAB_WISHLIST           = 2
WISHLIST_TAB_HISTORY            = 3
--The state of the multitab's search tab
WISHLIST_TAB_STATE_NO_SETS      = 1
WISHLIST_TAB_STATE_SETS_LOADING = 2
WISHLIST_TAB_STATE_SETS_LOADED  = 3
--The search types
WISHLIST_SEARCH_TYPE_BY_NAME                = 1
WISHLIST_SEARCH_TYPE_BY_SET_BONUS           = 2
WISHLIST_SEARCH_TYPE_BY_ARMORTYPE           = 3
WISHLIST_SEARCH_TYPE_BY_WEAPONTYPE          = 4
WISHLIST_SEARCH_TYPE_BY_SLOT                = 5
WISHLIST_SEARCH_TYPE_BY_TRAIT               = 6
WISHLIST_SEARCH_TYPE_BY_ITEMID              = 7
WISHLIST_SEARCH_TYPE_BY_DATE                = 8
WISHLIST_SEARCH_TYPE_BY_LOCATION            = 9
WISHLIST_SEARCH_TYPE_BY_USERNAME            = 10
WISHLIST_SEARCH_TYPE_BY_LIBSETSSETTYPE      = 11
WISHLIST_SEARCH_TYPE_BY_LIBSETSDLCID        = 12
WISHLIST_SEARCH_TYPE_BY_LIBSETSTRAITSNEEDED = 13
WISHLIST_SEARCH_TYPE_BY_LIBSETSZONEID       = 14
WISHLIST_SEARCH_TYPE_BY_LIBSETSWAYSHRINENODEINDEX = 15
WISHLIST_SEARCH_TYPE_BY_LIBSETSDROPMECHANIC     = 16
WISHLIST_SEARCH_TYPE_ITERATION_BEGIN = WISHLIST_SEARCH_TYPE_BY_NAME
WISHLIST_SEARCH_TYPE_ITERATION_END = WISHLIST_SEARCH_TYPE_BY_LIBSETSDROPMECHANIC
local searchTypesForCriteria = {
    [WISHLIST_SEARCH_TYPE_BY_NAME]                  = true,
    [WISHLIST_SEARCH_TYPE_BY_SET_BONUS]             = true,
    [WISHLIST_SEARCH_TYPE_BY_ARMORTYPE]             = true,
    [WISHLIST_SEARCH_TYPE_BY_WEAPONTYPE]            = true,
    [WISHLIST_SEARCH_TYPE_BY_SLOT]                  = true,
    [WISHLIST_SEARCH_TYPE_BY_TRAIT]                 = true,
    [WISHLIST_SEARCH_TYPE_BY_LOCATION]              = true,
    [WISHLIST_SEARCH_TYPE_BY_USERNAME]              = true,
    [WISHLIST_SEARCH_TYPE_BY_ITEMID]                = true,
    [WISHLIST_SEARCH_TYPE_BY_DATE]                  = true,
    [WISHLIST_SEARCH_TYPE_BY_LIBSETSSETTYPE]        = true,
    [WISHLIST_SEARCH_TYPE_BY_LIBSETSDLCID]          = true,
    [WISHLIST_SEARCH_TYPE_BY_LIBSETSTRAITSNEEDED]   = true,
    [WISHLIST_SEARCH_TYPE_BY_LIBSETSZONEID]         = true,
    [WISHLIST_SEARCH_TYPE_BY_LIBSETSWAYSHRINENODEINDEX] = true,
    [WISHLIST_SEARCH_TYPE_BY_LIBSETSDROPMECHANIC]       = true,
}
WL.searchTypesForCriteria = searchTypesForCriteria
local searchTypesForContextMenuCriteria = {
    [WISHLIST_SEARCH_TYPE_BY_NAME]                  = false,
    [WISHLIST_SEARCH_TYPE_BY_SET_BONUS]             = false,
    [WISHLIST_SEARCH_TYPE_BY_ARMORTYPE]             = true,
    [WISHLIST_SEARCH_TYPE_BY_WEAPONTYPE]            = true,
    [WISHLIST_SEARCH_TYPE_BY_SLOT]                  = true,
    [WISHLIST_SEARCH_TYPE_BY_TRAIT]                 = true,
    [WISHLIST_SEARCH_TYPE_BY_LOCATION]              = false,
    [WISHLIST_SEARCH_TYPE_BY_USERNAME]              = false,
    [WISHLIST_SEARCH_TYPE_BY_ITEMID]                = false,
    [WISHLIST_SEARCH_TYPE_BY_DATE]                  = false,
    [WISHLIST_SEARCH_TYPE_BY_LIBSETSSETTYPE]        = true,
    [WISHLIST_SEARCH_TYPE_BY_LIBSETSDLCID]          = true,
    [WISHLIST_SEARCH_TYPE_BY_LIBSETSTRAITSNEEDED]   = false,
    [WISHLIST_SEARCH_TYPE_BY_LIBSETSZONEID]         = false,
    [WISHLIST_SEARCH_TYPE_BY_LIBSETSWAYSHRINENODEINDEX] = false,
    [WISHLIST_SEARCH_TYPE_BY_LIBSETSDROPMECHANIC]       = true,
}
WL.searchTypesForContextMenuCriteria = searchTypesForContextMenuCriteria
--Constants for the number of search dropdown entries at each tab:
WISHLIST_TAB_SEARCH_ENTRY_COUNT     = WISHLIST_SEARCH_TYPE_ITERATION_END
WISHLIST_TAB_WHISLIST_ENTRY_COUNT   = WISHLIST_SEARCH_TYPE_ITERATION_END
WISHLIST_TAB_HISTORY_ENTRY_COUNT    = WISHLIST_SEARCH_TYPE_ITERATION_END
--The add dialog set part types
WISHLIST_ADD_TYPE_WHOLE_SET                             = 1
WISHLIST_ADD_TYPE_BY_ITEMTYPE                           = 2
WISHLIST_ADD_TYPE_BY_ITEMTYPE_AND_ARMOR_WEAPON_TYPE     = 3
WISHLIST_ADD_ONE_HANDED_WEAPONS                         = 4
WISHLIST_ADD_TWO_HANDED_WEAPONS                         = 5
WISHLIST_ADD_BODY_PARTS_ARMOR                           = 6
WISHLIST_ADD_MONSTER_SET_PARTS_ARMOR                    = 7
--The different types for the remove item dialog
WISHLIST_REMOVE_ITEM_TYPE_NORMAL                        = 1
WISHLIST_REMOVE_ITEM_TYPE_DATEANDTIME                   = 2
WISHLIST_REMOVE_ITEM_TYPE                               = 3
WISHLIST_REMOVE_ITEM_TYPE_ARMORANDWEAPONTYPE            = 4
WISHLIST_REMOVE_ITEM_TYPE_SLOT                          = 5
WISHLIST_REMOVE_ITEM_TYPE_TRAIT                         = 6
WISHLIST_REMOVE_ITEM_TYPE_ARMORANDWEAPONTYPE_SLOT       = 7
WISHLIST_REMOVE_ITEM_TYPE_KNOWN_SETITEMCOLLECTION       = 80
WISHLIST_REMOVE_ITEM_TYPE_KNOWN_SETITEMCOLLECTION_OF_SET = 81
WISHLIST_REMOVE_ITEM_TYPE_KNOWN_SETITEMCOLLECTION_ALL_WISHLISTS       = 82
WISHLIST_REMOVE_ITEM_TYPE_KNOWN_SETITEMCOLLECTION_OF_SET_ALL_WISHLISTS = 83

--Gear marker types (assign/remove)
WISHLIST_ASSIGN_GEAR_MARKER_ITEM_TYPE_NORMAL = 1
WISHLIST_ASSIGN_GEAR_MARKER_ITEM_TYPE_ALL = 999
WISHLIST_REMOVE_GEAR_MARKER_ITEM_TYPE_NORMAL = 1
WISHLIST_REMOVE_GEAR_MARKER_ITEM_TYPE_ALL = 999

--The prefix for the character dropdown entries
WISHLIST_SEARCHDROP_PREFIX= "WISHLIST_SEARCHDROP"
WISHLIST_CHARSDROP_PREFIX = "WISHLIST_CHARSDROP"
--Qualities
WL.ESOquality2WLqualityAdd = 2 --Add this number to the ESO quality returned by GetItemLinkDisplayQuality to get the appropriate WishList quality constant
WISHLIST_QUALITY_ALL = 1
WISHLIST_QUALITY_TRASH = 2
WISHLIST_QUALITY_NORMAL = 3
WISHLIST_QUALITY_MAGIC = 4
WISHLIST_QUALITY_ARCANE = 5
WISHLIST_QUALITY_ARTIFACT = 6
WISHLIST_QUALITY_LEGENDARY = 7
WISHLIST_QUALITY_MAGIC_OR_ARCANE = 8
WISHLIST_QUALITY_ARCANE_OR_ARTIFACT = 9
WISHLIST_QUALITY_ARTIFACT_OR_LEGENDARY = 10
WISHLIST_QUALITY_MAGIC_TO_LEGENDARY = 11
WISHLIST_QUALITY_ARCANE_TO_LEGENDARY = 12
--ZoneIds for LibSets data
WISHLIST_ZONEID_BATTLEGROUNDS = 999999
WISHLIST_ZONEID_SPECIAL       = 999998
--Textures
WISHLIST_TEXTURE_SETITEMCOLLECTION = "esoui/art/collections/collections_tabIcon_itemSets_up.dds"
--Traits
WISHLIST_TRAIT_TYPE_SPECIAL = 998
WISHLIST_TRAIT_TYPE_ALL = 999

--Sort header names
local sortTiebrakerChoicesWithSortHeaderKeys = {
    [-1] = "!None",
    [1] = "name",
    [2] = "armorOrWeaponTypeName",
    [3] = "slotName",
    [4] = "traitName",
    [5] = "quality",
    [6] = "username",
    [7] = "locality",
    [8] = "timestamp",
}
WL.sortTiebrakerChoicesWithSortHeaderKeys = sortTiebrakerChoicesWithSortHeaderKeys

--LAM dropdown box entries for the possible tiebraker choices
local sortTiebrakerChoices = {
    [1] = GetString(WISHLIST_LAM_SORT_USE_TIEBRAKER_NONE),
    [2] = GetString(WISHLIST_HEADER_NAME),
    [3] = GetString(WISHLIST_HEADER_TYPE),
    [4] = GetString(WISHLIST_HEADER_SLOT),
    [5] = GetString(WISHLIST_HEADER_TRAIT),
    [6] = GetString(WISHLIST_HEADER_QUALITY),
    [7] = GetString(WISHLIST_HEADER_USERNAME),
    [8] = GetString(WISHLIST_HEADER_LOCALITY),
    [9] = GetString(WISHLIST_HEADER_DATE),
}
WL.sortTiebrakerChoices = sortTiebrakerChoices

--LAM dropdown box entries for the possible tiebraker choices values
local sortTiebrakerChoicesValues = {}
table.insert(sortTiebrakerChoicesValues, -1)
for value=1, #sortTiebrakerChoices-1 do
    table.insert(sortTiebrakerChoicesValues, value)
end
WL.sortTiebrakerChoicesValues = sortTiebrakerChoicesValues

------------------------------------------------------------------------------------------------------------------------
-- SAVED VARIABLES
------------------------------------------------------------------------------------------------------------------------
--SavedVars accountwide defaults
WL.defaultAccSettings = {
    saveMode = 1,       --1=Each character, 2=Account wide
    sets = {},
    setCount = 0,
    itemCount = 0,
    use24hFormat = false,
    useCustomDateFormat = "",
    setsLastScanned = 0,
    lastAddedViaDialog = {},
}
--SavedVars defaults
WL.defaultSettings = {
    wishList = {},
    history = {},
    sortKey = {
        [WISHLIST_TAB_SEARCH]   = "name",
        [WISHLIST_TAB_WISHLIST] = "name",
    },
    sortOrder = {
        [WISHLIST_TAB_SEARCH]   = ZO_SORT_ORDER_UP,
        [WISHLIST_TAB_WISHLIST] = ZO_SORT_ORDER_UP,
    },
    preSelectLoggedinCharAtItemAddDialog = true,
    scanAllChars                         = false,
    showMainMenuButton                   = false,
    --useSortTiebrakerName                 = true,  --Removed and replaced by WL.defaultSettings.useSortTiebraker
    useSortTiebraker                     = -1,       --No additional group sorting
    fcoisMarkerIconAutoMarkLootedSetPart = false,
    fcoisMarkerIconAutoMarkLootedSetPartPerChar = false,
    fcoisMarkerIconLootedSetPart         = FCOIS_CON_ICON_LOCK or 1, -- Lock icon
    fcoisMarkerIconLootedSetPartPerChar  = {},
    useItemFoundCharacterName            = true,
    useItemFoundCSA                      = true,
    itemFoundText                        = GetString(WISHLIST_LOOT_MSG_STANDARD),
    showItemFoundHistoryChatOutput       = true,
    useLanguageForSetNames               = {
        ["de"] = false,
        ["en"] = true,
        ["fr"] = false,
        ["pl"] = false,
        ["ru"] = false,
        ["jp"] = false,
    },
    notifyOnFoundItemsOnlyMaxCP = false,
    notifyOnFoundItemsOnlyInDungeons = false,
    dialogAddHistory = {},
    askForItemWhisperText = GetString(WISHLIST_WHISPER_RECEIVER_QUESTION),
    --Added with WishList v3.03 - 2022-09-27
    gears = {},
}

--For the add item dialog
WL.lastSelectedLastAddedHistoryEntry = nil


--For the gear textures
local gearMarkerTextures = {
    [1]  = [[/esoui/art/campaign/campaignbrowser_fullpop.dds]],
    [2]  = [[/esoui/art/inventory/inventory_tabicon_armor_disabled.dds]],
    [3]  = [[/esoui/art/crafting/smithing_tabicon_research_disabled.dds]],
    [4]  = [[/esoui/art/tradinghouse/tradinghouse_sell_tabicon_disabled.dds]],
    [5]  = [[/esoui/art/campaign/overview_indexicon_bonus_disabled.dds]],
    [6]  = [[/esoui/art/ava/tabicon_bg_score_disabled.dds]],
    [7]  = [[/esoui/art/guild/guild_rankicon_leader_large.dds]],
    [8]  = [[/esoui/art/lfg/lfg_healer_up.dds]],
    [9]  = [[/esoui/art/miscellaneous/timer_32.dds]],
    [10] = [[/esoui/art/crafting/alchemy_tabicon_solvent_up.dds]],
    [11] = [[/esoui/art/buttons/cancel_up.dds]],
    [12] = [[/esoui/art/buttons/info_up.dds]],
    [13] = [[/esoui/art/buttons/pinned_normal.dds]],
    [14] = [[/esoui/art/cadwell/cadwell_indexicon_gold_up.dds]],
    [15] = [[/esoui/art/cadwell/cadwell_indexicon_silver_up.dds]],
    [16] = [[/esoui/art/campaign/campaignbonus_keepicon.dds]],
    [17] = [[/esoui/art/icons/scroll_005.dds]],
    [18] = [[/esoui/art/campaign/campaignbrowser_columnheader_ad.dds]],
    [19] = [[/esoui/art/campaign/campaignbrowser_columnheader_dc.dds]],
    [20] = [[/esoui/art/campaign/campaignbrowser_columnheader_ep.dds]],
    [21] = [[/esoui/art/campaign/campaignbrowser_guild.dds]],
    [22] = [[/esoui/art/campaign/campaignbrowser_indexicon_normal_up.dds]],
    [23] = [[/esoui/art/campaign/overview_indexicon_scoring_up.dds]],
    [24] = [[/esoui/art/charactercreate/charactercreate_bodyicon_up.dds]],
    [25] = [[/esoui/art/characterwindow/gearslot_offhand.dds]],
    [26] = [[/esoui/art/characterwindow/gearslot_mainhand.dds]],
    [27] = [[/esoui/art/characterwindow/gearslot_costume.dds]],
    [28] = [[/esoui/art/chatwindow/chat_mail_up.dds]],
    [29] = [[/esoui/art/chatwindow/chat_notification_up.dds]],
    [30] = [[/esoui/art/crafting/alchemy_tabicon_reagent_up.dds]],
    [31] = [[/esoui/art/crafting/smithing_tabicon_refine_up.dds]],
    [32] = [[/esoui/art/deathrecap/deathrecap_killingblow_icon.dds]],
    [33] = [[/esoui/art/fishing/bait_emptyslot.dds]],
    [34] = [[/esoui/art/guild/guildhistory_indexicon_guildbank_up.dds]],
    [35] = [[/esoui/art/guild/guild_indexicon_member_up.dds]],
    [36] = [[/esoui/art/guild/tabicon_roster_up.dds]],
    [37] = [[/esoui/art/icons/poi/poi_dungeon_complete.dds]],
    [38] = [[/esoui/art/icons/poi/poi_groupinstance_complete.dds]],
    [39] = [[/esoui/art/icons/servicemappins/servicepin_magesguild.dds]],
    [40] = [[/esoui/art/icons/servicemappins/servicepin_fightersguild.dds]],
    [41] = [[/esoui/art/lfg/lfg_dps_up.dds]],
    [42] = [[/esoui/art/lfg/lfg_leader_icon.dds]],
    [43] = [[/esoui/art/lfg/lfg_tank_up.dds]],
    [44] = [[/esoui/art/lfg/lfg_veterandungeon_up.dds]],
    [45] = [[/esoui/art/lfg/lfg_normaldungeon_up.dds]],
    [46] = [[/esoui/art/progression/icon_dualwield.dds]],
    [47] = [[/esoui/art/progression/icon_firestaff.dds]],
    [48] = [[/esoui/art/progression/icon_bows.dds]],
    [49] = [[/esoui/art/progression/icon_2handed.dds]],
    [50] = [[/esoui/art/progression/icon_1handed.dds]],
    [51] = [[/esoui/art/progression/progression_tabicon_backup_inactive.dds]],
    [52] = [[/esoui/art/repair/inventory_tabicon_repair_disabled.dds]],
    [53] = [[/esoui/art/worldmap/selectedquesthighlight.dds]],
    [54] = [[/esoui/art/guild/guildHeraldry_indexIcon_background_up.dds]],
    [55] = [[/esoui/art/crafting/enchantment_tabicon_deconstruction_disabled.dds]],
    [56] = [[/esoui/art/crafting/smithing_tabicon_improve_disabled.dds]],
    [57] = [[/esoui/art/bank/bank_tabicon_deposit_up.dds]],
    [58] = [[/esoui/art/currency/currency_gold.dds]],
    [59] = [[/esoui/art/guild/guild_bankaccess.dds]],
    [60] = [[/esoui/art/progression/progression_indexicon_guilds_up.dds]],
    [61] = [[/esoui/art/buttons/accept_up.dds]],
    [62] = [[/esoui/art/buttons/checkbox_checked.dds]],
    [63] = [[/esoui/art/buttons/checkbox_indeterminate.dds]],
    [64] = [[/esoui/art/buttons/dropbox_arrow_normal.dds]],
    [65] = [[/esoui/art/buttons/decline_up.dds]],
    [66] = [[/esoui/art/buttons/edit_cancel_up.dds]],
    [67] = [[/esoui/art/buttons/edit_up.dds]],
    [68] = [[/esoui/art/buttons/edit_save_up.dds]],
    [69] = [[/esoui/art/buttons/gamepad/console-widget-slider.dds]],
    [70] = [[/esoui/art/buttons/gamepad/console-widget-stepper.dds]],
    [71] = [[/esoui/art/buttons/gamepad/gp_checkbox_down.dds]],
    [72] = [[/esoui/art/buttons/gamepad/gp_checkbox_up.dds]],
    [73] = [[/esoui/art/buttons/gamepad/gp_downarrow.dds]],
    [74] = [[/esoui/art/buttons/gamepad/gp_menu_rightarrow.dds]],
    [75] = [[/esoui/art/buttons/gamepad/gp_uparrow.dds]],
    [76] = [[/esoui/art/buttons/gamepad/gp_spinnerlr.dds]],
    [77] = [[/esoui/art/buttons/gamepad/ps4/nav_ps4_circle.dds]],
    [78] = [[/esoui/art/buttons/gamepad/ps4/nav_ps4_ls.dds]],
    [79] = [[/esoui/art/buttons/gamepad/ps4/nav_ps4_rs.dds]],
    [80] = [[/esoui/art/buttons/gamepad/ps4/nav_ps4_share.dds]],
    [81] = [[/esoui/art/buttons/gamepad/ps4/nav_ps4_square.dds]],
    [82] = [[/esoui/art/buttons/gamepad/ps4/nav_ps4_trackpad_circle.dds]],
    [83] = [[/esoui/art/buttons/gamepad/ps4/nav_ps4_trackpad_leftright.dds]],
    [84] = [[/esoui/art/buttons/gamepad/ps4/nav_ps4_trackpad_lefttoright.dds]],
    [85] = [[/esoui/art/buttons/gamepad/ps4/nav_ps4_triangle.dds]],
    [86] = [[/esoui/art/buttons/gamepad/ps4/nav_ps4_trackpad_updown.dds]],
    [87] = [[/esoui/art/buttons/gamepad/ps4/nav_ps4_x.dds]],
    [88] = [[/esoui/art/buttons/gamepad/xbox/leftarrow_down.dds]],
    [89] = [[/esoui/art/buttons/gamepad/xbox/nav_xbone_a.dds]],
    [90] = [[/esoui/art/buttons/gamepad/xbox/nav_xbone_b.dds]],
    [91] = [[/esoui/art/buttons/gamepad/xbox/nav_xbone_dpadright.dds]],
    [92] = [[/esoui/art/buttons/gamepad/xbox/nav_xbone_rs_menu.dds]],
    [93] = [[/esoui/art/buttons/gamepad/xbox/nav_xbone_x.dds]],
    [94] = [[/esoui/art/buttons/gamepad/xbox/nav_xbone_y.dds]],
    [95] = [[/esoui/art/buttons/radiobuttonup.dds]],
    [96] = [[/esoui/art/buttons/radiobuttondown.dds]],
    [97] = [[/esoui/art/buttons/smoothsliderbutton_up.dds]],
    [98] = [[/esoui/art/buttons/swatchframe_selected.dds]],
    [99] = [[/esoui/art/buttons/switch_disabled.dds]],
    [100] = [[/esoui/art/buttons/unpinned_normal.dds]],
    [101] = [[/esoui/art/mounts/tabicon_mounts_disabled.dds]],
    [102] = [[/esoui/art/mounts/tabicon_ridingskills_disabled.dds]],
    [103] = [[/esoui/art/mounts/ridingskill_stamina.dds]],
    [104] = [[/esoui/art/mounts/ridingskill_speed.dds]],
    [105] = [[/esoui/art/mounts/ridingskill_ready.dds]],
    [106] = [[/esoui/art/mounts/ridingskill_capacity.dds]],
    [107] = [[/esoui/art/mounts/feed_icon.dds]],
    [108] = [[/esoui/art/mounts/activemount_icon.dds]],
    [109] = [[/esoui/art/menubar/gamepad/gp_playermenu_icon_communications.dds]],
    [110] = [[/esoui/art/menubar/gamepad/gp_playermenu_icon_collections.dds]],
    [111] = [[/esoui/art/menubar/gamepad/gp_playermenu_icon_character.dds]],
    [112] = [[/esoui/art/menubar/gamepad/gp_playermenu_icon_champion.dds]],
    [113] = [[/esoui/art/menubar/gamepad/gp_playermenu_icon_achievements.dds]],
    [114] = [[/esoui/art/menubar/gamepad/gp_playermenu_icon_contacts.dds]],
    [115] = [[/esoui/art/menubar/gamepad/gp_playermenu_icon_crowncrates.dds]],
    [116] = [[/esoui/art/menubar/gamepad/gp_playermenu_icon_emotes.dds]],
    [117] = [[/esoui/art/menubar/gamepad/gp_playermenu_icon_groups.dds]],
    [118] = [[/esoui/art/menubar/gamepad/gp_playermenu_icon_journal.dds]],
    [119] = [[/esoui/art/menubar/gamepad/gp_playermenu_icon_logout.dds]],
    [120] = [[/esoui/art/menubar/gamepad/gp_playermenu_icon_lorelibrary.dds]],
    [121] = [[/esoui/art/menubar/gamepad/gp_playermenu_icon_multiplayer.dds]],
    [122] = [[/esoui/art/menubar/gamepad/gp_playermenu_icon_settings.dds]],
    [123] = [[/esoui/art/menubar/gamepad/gp_playermenu_icon_store.dds]],
    [124] = [[/esoui/art/menubar/gamepad/gp_playermenu_icon_submitfeedback.dds]],
    [125] = [[/esoui/art/menubar/gamepad/gp_playermenu_icon_terms.dds]],
    [126] = [[/esoui/art/menubar/gamepad/gp_playermenu_icon_textchat.dds]],
    [127] = [[/esoui/art/menubar/gamepad/gp_playermenu_icon_unstuck.dds]],
    [128] = [[/esoui/art/menubar/gamepad/gp_playermenu_statusicon_pointstospend.dds]],
    [129] = [[/esoui/art/tutorial/bank_tabicon_deposit_up.dds]],
    [130] = [[/esoui/art/bank/bank_tabicon_gold_up.dds]],
    [131] = [[/esoui/art/bank/bank_tabicon_telvar_up.dds]],
    [132] = [[/esoui/art/tutorial/bank_tabicon_withdraw_up.dds]],
    [133] = [[/esoui/art/tutorial/guild_indexicon_misc09_up.dds]],
    [134] = [[/esoui/art/icons/store_upgrade_bank.dds]],
    [135] = [[/esoui/art/campaign/campaignbrowser_guild.dds]],
    [136] = [[/esoui/art/currency/currency_fightersguild.dds]],
    [137] = [[/esoui/art/currency/currency_magesguild.dds]],
    [138] = [[/esoui/art/currency/currency_thievesguild.dds]],
    [139] = [[/esoui/art/guild/gamepad/gp_guild_heraldryaccess.dds]],
    [140] = [[/esoui/art/guild/gamepad/gp_guild_menuicon_customization.dds]],
    [141] = [[/esoui/art/guild/gamepad/gp_guild_menuicon_leaveguild.dds]],
    [142] = [[/esoui/art/guild/gamepad/gp_guild_menuicon_ownership.dds]],
    [143] = [[/esoui/art/guild/gamepad/gp_guild_menuicon_purchases.dds]],
    [144] = [[/esoui/art/guild/gamepad/gp_guild_menuicon_releaseownership.dds]],
    [145] = [[/esoui/art/guild/gamepad/gp_guild_menuicon_trader.dds]],
    [146] = [[/esoui/art/guild/gamepad/gp_guild_menuicon_unlocks.dds]],
    [147] = [[/esoui/art/guild/gamepad/gp_guild_options_changeicon.dds]],
    [148] = [[/esoui/art/guild/gamepad/gp_guild_options_permissions.dds]],
    [149] = [[/esoui/art/guild/gamepad/gp_guild_options_rename.dds]],
    [150] = [[/esoui/art/guild/gamepad/gp_guild_tradinghouseaccess.dds]],
    [151] = [[/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_thievesguild.dds]],
    [152] = [[/esoui/art/tutorial/guild-tabicon_heraldry_up.dds]],
    [153] = [[/esoui/art/tutorial/guild-tabicon_home_up.dds]],
    [154] = [[/esoui/art/tutorial/guild_indexicon_leader_up.dds]],
    [155] = [[/esoui/art/tutorial/guild_indexicon_recruit_up.dds]],
    [156] = [[/esoui/art/tutorial/guild_indexicon_officer_up.dds]],
    [157] = [[/esoui/art/tutorial/guild_indexicon_misc01_up.dds]],
    [158] = [[/esoui/art/tutorial/guild_indexicon_misc02_up.dds]],
    [159] = [[/esoui/art/tutorial/guild_indexicon_misc03_up.dds]],
    [160] = [[/esoui/art/tutorial/guild_indexicon_misc04_up.dds]],
    [161] = [[/esoui/art/tutorial/guild_indexicon_misc05_up.dds]],
    [162] = [[/esoui/art/tutorial/guild_indexicon_misc06_up.dds]],
    [163] = [[/esoui/art/tutorial/guild_indexicon_misc07_up.dds]],
    [164] = [[/esoui/art/tutorial/guild_indexicon_misc08_up.dds]],
    [165] = [[/esoui/art/tutorial/guild_indexicon_misc10_up.dds]],
    [166] = [[/esoui/art/tutorial/guild_indexicon_misc11_up.dds]],
    [167] = [[/esoui/art/tutorial/guild_indexicon_misc12_up.dds]],
    [167] = [[/esoui/art/guild/guildbanner_icon_aldmeri.dds]],
    [168] = [[/esoui/art/guild/guildbanner_icon_daggerfall.dds]],
    [169] = [[/esoui/art/guild/guildbanner_icon_ebonheart.dds]],
    [170] = [[/esoui/art/tutorial/guildheraldry_indexicon_background_up.dds]],
    [171] = [[/esoui/art/guild/guildheraldry_indexicon_crest_up.dds]],
    [172] = [[/esoui/art/tutorial/guildstore-tradinghouse_listings_tabicon_up.dds]],
    [173] = [[/esoui/art/tutorial/progression_tabicon_fightersguild_up.dds]],
    [174] = [[/esoui/art/tutorial/progression_tabicon_magesguild_up.dds]],
    [175] = [[/esoui/art/icons/store_thievesguilddlc_collectable.dds]],
    [176] = [[/esoui/art/tutorial/tabicon_createguild_up.dds]],
    [177] = [[/esoui/art/voip/voip-guild.dds]],
    [178] = [[/esoui/art/death/death_timer_fill.dds]],
    [179] = [[/esoui/art/death/death_soulreservoir_icon.dds]],
    [180] = [[/esoui/art/currency/alliancepoints_32.dds]],
    [181] = [[/esoui/art/tutorial/inventory_trait_retrait_icon.dds]],
    [182] = [[/esoui/art/currency/currency_gold_32.dds]],
    [183] = [[/esoui/art/currency/currency_inspiration_32.dds]],
    [184] = [[/esoui/art/currency/currency_seedcrystal_32.dds]],
    [185] = [[/esoui/art/currency/currency_seedcrystals_multi_mipmap.dds]],
    [186] = [[/esoui/art/currency/currency_telvar_32.dds]],
    [187] = [[/esoui/art/currency/currency_writvoucher.dds]],
    [188] = [[/esoui/art/dye/dye_hat.dds]],
    [189] = [[/esoui/art/dye/dye_swatch_highlight.dds]],
    [190] = [[/esoui/art/dye/dyes_categoryicon_up.dds]],
    [191] = [[/esoui/art/dye/dyes_tabicon_outfitstyledye_up.dds]],
    [192] = [[/esoui/art/dye/outfitslot_staff.dds]],
    [193] = [[/esoui/art/dye/outfitslot_twohanded.dds]],
    [194] = [[/esoui/art/armory/builditem_icon.dds]],
    [195] = [[/esoui/art/armory/newbuild_icon.dds]],
    [196] = [[/esoui/art/unitframes/groupicon_leader.dds]],
    [197] = [[/esoui/art/companion/keyboard/category_u30_companions_up.dds]],
    [198] = [[/esoui/art/battlegrounds/battlegroundscapturebar_teambadge_green.dds]],
    [199] = [[/esoui/art/battlegrounds/battlegroundscapturebar_teambadge_orange.dds]],
    [200] = [[/esoui/art/battlegrounds/battlegroundscapturebar_teambadge_purple.dds]],
    [201] = [[/esoui/art/icons/store_battleground.dds]],
    [202] = [[/esoui/art/collections/collections_tabIcon_itemSets_down.dds]],
    [203] = [[/esoui/art/collections/collections_tabIcon_itemSets_up.dds]],
    [204] = [[/esoui/art/armory/buildicons/buildicon_1.dds]],
    [205] = [[/esoui/art/armory/buildicons/buildicon_2.dds]],
    [206] = [[/esoui/art/armory/buildicons/buildicon_3.dds]],
    [207] = [[/esoui/art/armory/buildicons/buildicon_4.dds]],
    [208] = [[/esoui/art/armory/buildicons/buildicon_5.dds]],
    [209] = [[/esoui/art/armory/buildicons/buildicon_6.dds]],
    [210] = [[/esoui/art/armory/buildicons/buildicon_7.dds]],
    [211] = [[/esoui/art/armory/buildicons/buildicon_8.dds]],
    [212] = [[/esoui/art/armory/buildicons/buildicon_9.dds]],
    [213] = [[/esoui/art/armory/buildicons/buildicon_10.dds]],
    [214] = [[/esoui/art/armory/buildicons/buildicon_11.dds]],
    [215] = [[/esoui/art/armory/buildicons/buildicon_12.dds]],
    [216] = [[/esoui/art/armory/buildicons/buildicon_13.dds]],
    [217] = [[/esoui/art/armory/buildicons/buildicon_14.dds]],
    [218] = [[/esoui/art/armory/buildicons/buildicon_15.dds]],
    [219] = [[/esoui/art/armory/buildicons/buildicon_16.dds]],
    [220] = [[/esoui/art/armory/buildicons/buildicon_17.dds]],
    [221] = [[/esoui/art/armory/buildicons/buildicon_18.dds]],
    [222] = [[/esoui/art/armory/buildicons/buildicon_19.dds]],
    [223] = [[/esoui/art/armory/buildicons/buildicon_20.dds]],
    [224] = [[/esoui/art/armory/buildicons/buildicon_21.dds]],
    [225] = [[/esoui/art/armory/buildicons/buildicon_22.dds]],
    [226] = [[/esoui/art/armory/buildicons/buildicon_23.dds]],
    [227] = [[/esoui/art/armory/buildicons/buildicon_24.dds]],
    [228] = [[/esoui/art/armory/buildicons/buildicon_25.dds]],
    [229] = [[/esoui/art/armory/buildicons/buildicon_26.dds]],
    [230] = [[/esoui/art/armory/buildicons/buildicon_27.dds]],
    [231] = [[/esoui/art/armory/buildicons/buildicon_28.dds]],
    [232] = [[/esoui/art/armory/buildicons/buildicon_29.dds]],
    [233] = [[/esoui/art/armory/buildicons/buildicon_30.dds]],
    [234] = [[/esoui/art/armory/buildicons/buildicon_31.dds]],
    [235] = [[/esoui/art/armory/buildicons/buildicon_32.dds]],
    [236] = [[/esoui/art/armory/buildicons/buildicon_33.dds]],
    [237] = [[/esoui/art/armory/buildicons/buildicon_34.dds]],
    [238] = [[/esoui/art/armory/buildicons/buildicon_35.dds]],
    [239] = [[/esoui/art/armory/buildicons/buildicon_36.dds]],
    [240] = [[/esoui/art/armory/buildicons/buildicon_37.dds]],
    [241] = [[/esoui/art/armory/buildicons/buildicon_38.dds]],
    [242] = [[/esoui/art/armory/buildicons/buildicon_39.dds]],
    [243] = [[/esoui/art/armory/buildicons/buildicon_40.dds]],
    [244] = [[/esoui/art/armory/buildicons/buildicon_41.dds]],
    [245] = [[/esoui/art/armory/buildicons/buildicon_42.dds]],
    [246] = [[/esoui/art/armory/buildicons/buildicon_43.dds]],
    [247] = [[/esoui/art/armory/buildicons/buildicon_44.dds]],
    [248] = [[/esoui/art/armory/buildicons/buildicon_45.dds]],
    [249] = [[/esoui/art/armory/buildicons/buildicon_46.dds]],
    [250] = [[/esoui/art/armory/buildicons/buildicon_47.dds]],
    [251] = [[/esoui/art/armory/buildicons/buildicon_48.dds]],
    [252] = [[/esoui/art/armory/buildicons/buildicon_49.dds]],
    [253] = [[/esoui/art/armory/buildicons/buildicon_50.dds]],
    [254] = [[/esoui/art/armory/buildicons/buildicon_51.dds]],
    [255] = [[/esoui/art/armory/buildicons/buildicon_52.dds]],
    [256] = [[/esoui/art/armory/buildicons/buildicon_53.dds]],
    [257] = [[/esoui/art/armory/buildicons/buildicon_54.dds]],
    [258] = [[/esoui/art/armory/buildicons/buildicon_55.dds]],
    [259] = [[/esoui/art/armory/buildicons/buildicon_56.dds]],
    [260] = [[/esoui/art/armory/buildicons/buildicon_57.dds]],
    [261] = [[/esoui/art/armory/buildicons/buildicon_58.dds]],
    [262] = [[/esoui/art/armory/buildicons/buildicon_59.dds]],
    [263] = [[/esoui/art/armory/buildicons/buildicon_60.dds]],
    [264] = [[/esoui/art/armory/buildicons/buildicon_61.dds]],
    [265] = [[/esoui/art/armory/buildicons/buildicon_62.dds]],
    [266] = [[/esoui/art/armory/buildicons/buildicon_63.dds]],
    [267] = [[/esoui/art/armory/buildicons/buildicon_64.dds]],
    [268] = [[/esoui/art/armory/buildicons/buildicon_65.dds]],
    [269] = [[/esoui/art/armory/buildicons/buildicon_66.dds]],
    [270] = [[/esoui/art/armory/buildicons/buildicon_67.dds]],
    [271] = [[/esoui/art/armory/buildicons/buildicon_68.dds]],
    [272] = [[/esoui/art/armory/buildicons/buildicon_69.dds]],
    [273] = [[/esoui/art/armory/buildicons/buildicon_70.dds]],
    [274] = [[/esoui/art/armory/buildicons/buildicon_71.dds]],
    [275] = [[/esoui/art/armory/buildicons/buildicon_72.dds]],
    [276] = [[/esoui/art/armory/buildicons/buildicon_73.dds]],
    [277] = [[/esoui/art/armory/buildicons/buildicon_74.dds]],
    [278] = [[/esoui/art/inventory/gamepad/gp_inventory_icon_companionitems.dds]],
}
WL.gearMarkerTextures = gearMarkerTextures

--Invers lookup table for texturePath to ID
local gearMarkerTexturesLookup = {}
for textureId, texturePath in ipairs(gearMarkerTextures) do
    gearMarkerTexturesLookup[texturePath] = textureId
end
WL.gearMarkerTexturesLookup = gearMarkerTexturesLookup