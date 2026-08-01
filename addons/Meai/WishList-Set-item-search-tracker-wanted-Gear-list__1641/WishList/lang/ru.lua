--Translations by @Lost.Seeker - 2020-11-23

WishList = WishList or {}
local WL = WishList

local stringsBase = {
    WISHLIST_TITLE                      = "WishList",
    WISHLIST_ALL_WISHLISTS              = "[ ALL WishLists ]",
    WISHLIST_HISTORY_TITLE              = "история",

    WISHLIST_TOOLTIP_COLOR_KEY          = "|cFFA500", --Orange, RGB: 255 165 000
    WISHLIST_TOOLTIP_COLOR_VALUE        = "|cF6F6F6", -- Gray-White, RGB: 246 246 246

    WISHLIST_HEADER_DATE                = "Дата",                                   -- Date
    WISHLIST_HEADER_NAME                = GetString(SI_INVENTORY_SORT_TYPE_NAME),   -- Name
    WISHLIST_HEADER_TYPE                = GetString(SI_SMITHING_HEADER_ITEM),       -- Type
    WISHLIST_HEADER_SLOT                = "Слот",
    WISHLIST_HEADER_TRAIT               = GetString(SI_SMITHING_HEADER_TRAIT),      -- Trait
    WISHLIST_HEADER_CHARS               = GetString(SI_BINDING_NAME_TOGGLE_CHARACTER), -- Character / toon
    WISHLIST_HEADER_USERNAME            = "Игрок",
    WISHLIST_HEADER_LOCALITY            = "Локация",
    WISHLIST_HEADER_QUALITY             = GetString(SI_TRADINGHOUSEFEATURECATEGORY5), --Quality
    WISHLIST_HEADER_LAST_ADDED          = "Последние",

    WISHLIST_CONST_ID                   = "id",
    WISHLIST_CONST_SET                  = "Набор",
    WISHLIST_CONST_BONUS                = "бонус",
    WISHLIST_CONST_ARMORANDWEAPONTYPE   = "Armor / Weapon type",
    WISHLIST_CONST_ARMORTYPE            = "Тип брони",
    WISHLIST_CONST_WEAPONTYPE           = "Тип оружия",
    WISHLIST_CONST_ITEMID               = "Id_предмета",

    WISHLIST_DIALOG_ADD_ITEM            = "Добавить предмет",
    WISHLIST_BUTTON_REMOVE_HISTORY_TT   = "очистить историю",

    WISHLIST_DLC                        = GetString(SI_MARKET_PRODUCT_TOOLTIP_DLC),
    WISHLIST_ZONE                       = GetString(SI_CHAT_CHANNEL_NAME_ZONE),
    WISHLIST_WAYSHRINES                 = GetString(SI_MAPFILTER8),
    WISHLIST_ARMORTYPE                  = GetString(SI_ITEM_FORMAT_STR_ARMOR) .. " " .. GetString(SI_GUILD_HERALDRY_TYPE_HEADER),
    WISHLIST_DROPLOCATIONS              = "Локация",
    WISHLIST_DROPLOCATION_SPECIAL       = "Speziell (Level Up, Prophet)",
    WISHLIST_DROPLOCATION_BG            = GetString(SI_LEADERBOARDTYPE4), --Battleground

    WISHLIST_LIBSETS                    = "LibSets",

    WISHLIST_ARMOR                      = GetString(SI_ITEMTYPE2),
    WISHLIST_WEAPONS                    = GetString(SI_ITEMFILTERTYPE1),
    WISHLIST_JEWELRY                    = GetString(SI_ITEMFILTERTYPE25),
}
WL.stringsBaseEN = stringsBase
for stringId, stringValue in pairs(stringsBase) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end

--English WishList translations (using already created base strings)
local strings = {
    WISHLIST_SEARCHDROP_START        = "Поиск по ",
    WISHLIST_SEARCHDROP1       = GetString(WISHLIST_HEADER_NAME) .. "/Id_набора",
    WISHLIST_SEARCHDROP2       = GetString(WISHLIST_CONST_SET) .. " " .. GetString(WISHLIST_CONST_BONUS),
    WISHLIST_SEARCHDROP3       = GetString(WISHLIST_CONST_ARMORTYPE),
    WISHLIST_SEARCHDROP4       = GetString(WISHLIST_CONST_WEAPONTYPE),
    WISHLIST_SEARCHDROP5       = GetString(WISHLIST_HEADER_SLOT),
    WISHLIST_SEARCHDROP6       = GetString(WISHLIST_HEADER_TRAIT),
    WISHLIST_SEARCHDROP7       = GetString(WISHLIST_CONST_ITEMID),
    WISHLIST_SEARCHDROP8       = GetString(WISHLIST_HEADER_DATE),
    WISHLIST_SEARCHDROP9       = GetString(WISHLIST_HEADER_LOCALITY),
    WISHLIST_SEARCHDROP10       = GetString(WISHLIST_HEADER_USERNAME),
    --LibSets searches
    WISHLIST_SEARCHDROP11      = GetString(WISHLIST_LIBSETS) .. ": Тип набора",
    WISHLIST_SEARCHDROP12      = GetString(WISHLIST_LIBSETS) .. ": " .. GetString(WISHLIST_DLC),
    WISHLIST_SEARCHDROP13      = GetString(WISHLIST_LIBSETS) .. ": Необходимая особенность",
    WISHLIST_SEARCHDROP14      = GetString(WISHLIST_LIBSETS) .. ": " .. GetString(WISHLIST_ZONE),
    WISHLIST_SEARCHDROP15      = GetString(WISHLIST_LIBSETS) .. ": " .. GetString(WISHLIST_WAYSHRINES),
    WISHLIST_SEARCHDROP16      = GetString(WISHLIST_LIBSETS) .. ": " .. GetString(WISHLIST_DROPLOCATIONS),

    WISHLIST_LOOT_MSG_YOU            = "ВЫ получили ",
    WISHLIST_LOOT_MSG_OTHER          = " ПОЛУЧИЛ ",
    WISHLIST_LOOT_MSG_STANDARD       = "[<<2>>] получил \"<<1>>\": <<3>>",

    WISHLIST_CONTEXTMENU_FROM        = " из списка",
    WISHLIST_CONTEXTMENU_ADD         = "Добавить в список",
    WISHLIST_CONTEXTMENU_REMOVE      = "Удалить из списка",
    WISHLIST_CONTEXTMENU_REMOVE_FROM_LAST_ADDED = "Удалить из последнего добавления",
    WISHLIST_CONTEXTMENU_CLEAR_LAST_ADDED = "Удалить последние добавления (данное окно закроется!)",
    WISHLIST_CLEAR_LAST_ADDED_TITLE = "Очистить историю последних добавлений?",
    WISHLIST_CLEAR_LAST_ADDED_TEXT = "Do you really want to clear all entries of the last added history?",

    WISHLIST_CONTEXTMENU_SETITEMCOLLECTION_ADD = "Add each single trait to " .. GetString(WISHLIST_TITLE),
    WISHLIST_CONTEXTMENU_SETITEMCOLLECTION_ADD_1_ITEM = "Add all traits as 1 item to " .. GetString(WISHLIST_TITLE),
    WISHLIST_CONTEXTMENU_SETITEMCOLLECTION_REMOVE = "Remove all traits of item from " .. GetString(WISHLIST_TITLE),
    WISHLIST_CONTEXTMENU_SETITEMCOLLECTION_REMOVE_SLOT = "Remove all traits of slot from " .. GetString(WISHLIST_TITLE),

    WISHLIST_ADDED                   = " добавлено в " .. GetString(WISHLIST_TITLE),
    WISHLIST_REMOVED                 = " удалено из " .. GetString(WISHLIST_TITLE),
    WISHLIST_UPDATED                 = " updated <<1>> in " .. GetString(WISHLIST_TITLE),
    WISHLIST_ITEMS_ADDED             = "<<1[No item/1 item/$d items]>> добавлено в " .. GetString(WISHLIST_TITLE),
    WISHLIST_ITEMS_REMOVED           = "<<1[No item/1 item/$d items]>> удалено из " .. GetString(WISHLIST_TITLE),
    WISHLIST_ITEMS_UPDATED           = "<<1[No item/1 item/$d items]>> изменено в " .. GetString(WISHLIST_TITLE),

    WISHLIST_HISTORY_ADDED                   = " добавлено в " .. GetString(WISHLIST_HISTORY_TITLE),
    WISHLIST_HISTORY_REMOVED                 = " удалено из " .. GetString(WISHLIST_HISTORY_TITLE),
    WISHLIST_HISTORY_ITEMS_ADDED             = "<<1[No entry/1 entry/$d entries]>> добавлено в " .. GetString(WISHLIST_HISTORY_TITLE),
    WISHLIST_HISTORY_ITEMS_REMOVED           = "<<1[No entry/1 entry/$d entries]>> удалено из " .. GetString(WISHLIST_HISTORY_TITLE),

    WISHLIST_ITEMTRAITTYPE_SPECIAL  = "Special",

    WISHLIST_DIALOG_ADD_WHOLE_SET_TT         = "Добавить все предметы текущего набора с выбранной особенностью в ваш " .. GetString(WISHLIST_TITLE),
    WISHLIST_DIALOG_ADD_ALL_TYPE_OF_SET_TT   = "Add all items of the current set, with selected item type (<<1>>) and selected trait, to your " .. GetString(WISHLIST_TITLE),
    WISHLIST_DIALOG_ADD_ALL_TYPE_TYPE_OF_SET_TT = "Add all items of the current set, with selected item type (<<1>>), item (<<2>>) and selected trait, to your " .. GetString(WISHLIST_TITLE),
    WISHLIST_DIALOG_ADD_ANY_TRAIT            = "Любая особенность",
    WISHLIST_NO_ITEMS_ADDED_WITH_SELECTED_DATA = "No items found with the selected data -> No items were added to your " .. GetString(WISHLIST_TITLE),
    WISHLIST_DIALOG_ADD_ONE_HANDED_WEAPONS_OF_SET_TT = "Добавить все Одноручное оружее + Щит с выбранной особенностью в Ваш " .. GetString(WISHLIST_TITLE),
    WISHLIST_DIALOG_ADD_TWO_HANDED_WEAPONS_OF_SET_TT = "Добавить все Двуручное оружее с выбранной особенностью в Ваш " .. GetString(WISHLIST_TITLE),
    WISHLIST_DIALOG_ADD_BODY_PARTS_ARMOR_OF_SET_TT = "Добавить 5 частей из набора (верх) с выбранной особенностью в Ваш " .. GetString(WISHLIST_TITLE),
    WISHLIST_DIALOG_ADD_MONSTER_SET_PARTS_ARMOR_OF_SET_TT = "Добавить Шляпу и Наплечники с выбранной особенностью в Ваш " .. GetString(WISHLIST_TITLE),

    WISHLIST_DIALOG_REMOVE_ITEM              = "Удалить предмет",
    WISHLIST_DIALOG_REMOVE_ITEM_QUESTION     = "Удалить <<1>>?",
    WISHLIST_DIALOG_REMOVE_ITEM_DATETIME            = "Удалить все предметы с датой \"<<1>>\"",
    WISHLIST_DIALOG_REMOVE_ITEM_TYPE                = "Удалить всё по типу \"<<1>>\"",
    WISHLIST_DIALOG_REMOVE_ITEM_ARMORORWEAPONTYPE   = "Удалить всё по типу \"<<1>>\"",
    WISHLIST_DIALOG_REMOVE_ITEM_TYPE_ARMORORWEAPONTYPE_SLOT = "Remove items with item type \"<<1>>\", type \"<<2>>\", slot \"<<3>>\"",
    WISHLIST_DIALOG_REMOVE_ITEM_SLOT                = "Удалить всё: \"<<1>>\"",
    WISHLIST_DIALOG_REMOVE_ITEM_TRAIT               = "Удалить всё с особенностью: \"<<1>>\"",
    WISHLIST_DIALOG_REMOVE_ITEM_KNOWN_SETITEMCOLLECTION_OF_SET = "Удалить предметы из набора \"<<1>>\", которые уже в коллекции",
    WISHLIST_DIALOG_REMOVE_ITEM_KNOWN_SETITEMCOLLECTION = "|c779cffУдалить ВСЕ предметы любых наборов, которые уже в коллекции|r",
    WISHLIST_CONTEXTMENU_ADD_ITEM_UNKNOWN_SETITEMCOLLECTION_OF_SET = "Add unknown items of set \"<<1>>\" to " .. GetString(WISHLIST_TITLE),
    WISHLIST_CONTEXTMENU_REMOVE_ITEM_KNOWN_SETITEMCOLLECTION_OF_SET = "Remove known items of set \"<<1>>\" from " .. GetString(WISHLIST_TITLE),
    WISHLIST_CONTEXTMENU_REMOVE_ITEM_KNOWN_SETITEMCOLLECTION = "Remove known items of all sets from " ..GetString(WISHLIST_TITLE),
    WISHLIST_CONTEXTMENU_REMOVE_ITEM_KNOWN_SETITEMCOLLECTION_OF_SET_ALL_WISHLISTS = "Remove known items of set \"<<1>>\" from ALL WishLists",
    WISHLIST_CONTEXTMENU_REMOVE_ITEM_KNOWN_SETITEMCOLLECTION_ALL_WISHLISTS = "Remove known items of all sets from ALL WishLists",

    WISHLIST_DIALOG_REMOVE_WHOLE_SET         = "Удалить набор \"<<1>>\"",
    WISHLIST_DIALOG_REMOVE_WHOLE_SET_QUESTION= "Действительно удалить все предметы \"<<1>>\" из списка?",
    WISHLIST_BUTTON_REMOVE_ALL_TT            = "Remove all items of selected character from " .. GetString(WISHLIST_TITLE),
    WISHLIST_DIALOG_REMOVE_ALL_ITEMS_QUESTION     = "Действительно удалить все предметы?",
    WISHLIST_BUTTON_CLEAR_HISTORY_TT            = GetString(WISHLIST_BUTTON_REMOVE_HISTOTY_TT) .. "?",
    WISHLIST_DIALOG_CLEAR_HISTORY_QUESTION      = "Действительно удалить " .. GetString(WISHLIST_HISTORY_TITLE) .. " для выбранного персонажа?",
    WISHLIST_DIALOG_CHANGE_QUALITY              = "Изменить " .. GetString(SI_TRADINGHOUSEFEATURECATEGORY5),
    WISHLIST_DIALOG_CHANGE_QUALITY_QUESTION     = "Изменить <<1>>?",
    WISHLIST_DIALOG_CHANGE_QUALITY_WHOLE_SET    = "Изменить " .. GetString(SI_TRADINGHOUSEFEATURECATEGORY5) .. " набора",
    WISHLIST_DIALOG_CHANGE_QUALITY_WHOLE_SET_QUESTION   = "Действительно именить все предметы в наборе \"<<1>>\"?",

    WISHLIST_BUTTON_COPY_WISHLIST_TT            = "Копировать " .. GetString(WISHLIST_TITLE),
    WISHLIST_BUTTON_CHOOSE_CHARACTER_TT         = "Выбрать персонажа",
    WISHLIST_BUTTON_CHOOSE_CHARACTER_QUESTION_ADD_ITEM   = GetString(WISHLIST_DIALOG_ADD_ITEM) .. " <<1>>:",
    WISHLIST_BUTTON_CHOOSE_CHARACTER_QUESTION_ADD_ITEM_AND_MORE = GetString(WISHLIST_DIALOG_ADD_ITEM) .. " <<1>>, and <<2>> more:",
    WISHLIST_BUTTON_CHOOSE_CHARACTER_QUESTION_COPY_WL  = "Copy " .. GetString(WISHLIST_TITLE) .. " of <<1>> to:",
    WISHLIST_ITEM_COPIED                        = "Копирую <<1>> с <<2>> на <<3>>",
    WISHLIST_NO_ITEMS_COPIED                    = "No items copied, maybe all items are already on the target's " .. GetString(WISHLIST_TITLE),

    WISHLIST_DIALOG_RELOAD_ITEMS             = "Обновить предметы",
    WISHLIST_DIALOG_RELOAD_ITEMS_QUESTION    = "Это обновит все предметы используя базу \'LibSets\'!\nМожет занять около 5 сек.",
    WISHLIST_LINK_ITEM_TO_CHAT               = GetString(SI_ITEM_ACTION_LINK_TO_CHAT),
    WISHLIST_WHISPER_RECEIVER                = "Шепнуть \"<<C:1>>\" и спросить за <<2>>",
    WISHLIST_WHISPER_RECEIVER_QUESTION       = "Hey <<1>>, can I have <<2>> pls?",

    WISHLIST_SETS_LOADED                     = "<<1[No set/1 set/$d sets]>> загружено",
    WISHLIST_NO_SETS_LOADED                  = "Нет загруженных наборов. Кликни на кнопку для загрузки наборов.\Может занять долгое время и вызовет лаги на время обновления!",
    WISHLIST_LOAD_SETS                       = "Загрузить наборы",
    WISHLIST_LOADING_SETS                    = "Наборы загружаются...",
    WISHLIST_TOTAL_SETS                      = "Всего наборов: ",
    WISHLIST_TOTAL_SETS_ITEMS                = "Всего предметов: ",
    WISHLIST_SETS_FOUND                      = "Наборы найдены: <<1>> включая <<2>> вещей",

    WISHLIST_ITEM_QUALITY_ALL                       = "Любое " .. GetString(SI_TRADINGHOUSEFEATURECATEGORY5),
    WISHLIST_ITEM_QUALITY_MAGIC_OR_ARCANE           = GetString(SI_ITEMQUALITY2) .. ", " .. GetString(SI_ITEMQUALITY3), 		--Magic or arcane
    WISHLIST_ITEM_QUALITY_ARCANE_OR_ARTIFACT        = GetString(SI_ITEMQUALITY3) .. ", " .. GetString(SI_ITEMQUALITY4), 		--Arcane or artifact
    WISHLIST_ITEM_QUALITY_ARTIFACT_OR_LEGENDARY     = GetString(SI_ITEMQUALITY4) .. ", " .. GetString(SI_ITEMQUALITY5), 	    --Artifact or legendary
    WISHLIST_ITEM_QUALITY_MAGIC_TO_LEGENDARY        = GetString(SI_ITEMQUALITY2) .. " -> " .. GetString(SI_ITEMQUALITY5), 		--Magic to legendary
    WISHLIST_ITEM_QUALITY_ARCANE_TO_LEGENDARY       = GetString(SI_ITEMQUALITY3) .. " -> " .. GetString(SI_ITEMQUALITY5), 		--Arcane to legendary

    --Tooltips
    WISHLIST_BUTTON_RELOAD_TT                = "Обновить базу",
    WISHLIST_BUTTON_SEARCH_TT                = "Поиск",
    WISHLIST_BUTTON_WISHLIST_TT              = "Ваш " .. GetString(WISHLIST_TITLE),
    WISHLIST_BUTTON_HISTORY_TT               = zo_strformat("<<C:1>>", GetString(WISHLIST_HISTORY_TITLE)),
    WISHLIST_BUTTON_SETTINGS_TT              = "Настройки " .. GetString(WISHLIST_TITLE),
    WISHLIST_BUTTON_SET_ITEM_COLLECTION_TT   = "Показать коллекции",
    WISHLIST_CHARDROPDOWN_ITEMCOUNT_WISHLIST = "[<<C:1>>]\n<<2[No item/1 item/$d items]>> on " .. GetString(WISHLIST_TITLE),
    WISHLIST_CHARDROPDOWN_ITEMCOUNT_HISTORY  = "[<<C:1>>]\n<<2[No entry/1 entry/$d entries]>> in " .. GetString(WISHLIST_HISTORY_TITLE),

    --Keybindings
    SI_BINDING_NAME_WISHLIST_SHOW           = "Show " .. GetString(WISHLIST_TITLE),
    SI_BINDING_NAME_WISHLIST_ADD_OR_REMOVE  = "Add/Remove to/from " .. GetString(WISHLIST_TITLE),

    -- LAM addon settings
    WISHLIST_WARNING_RELOADUI               = "Внимание:\nИзменение этой настройки автоматически перезагрузит интерфейс!",
    WISHLIST_LAM_ADDON_DESC                 = GetString(WISHLIST_TITLE) .. " - Your list of wanted set items",
    WISHLIST_LAM_SAVEDVARIABLES             = "Способ сохранения",
    WISHLIST_LAM_SV                         = "Настройка на:",
    WISHLIST_LAM_SV_TT                      = "Выберите, хоте ли вы сохнанить настройки на каждого персонажа отдельно или общие на учетную запись.\n\nЭто не влияет на выбор персонажа в списках, а так же на добавление/удаление предметов WishList!",
    WISHLIST_LAM_SV_ACCOUNT_WIDE            = "Аккаунт",
    WISHLIST_LAM_SV_EACH_CHAR               = "Персонаж",
    WISHLIST_LAM_USE_24h_FORMAT             = "24ч формат времени",
    WISHLIST_LAM_USE_24h_FORMAT_TT          = "Use the 24 hours time format for date & time formats",
    WISHLIST_LAM_USE_CUSTOM_DATETIME_FORMAT     = "Настройка времени и даты",
    WISHLIST_LAM_USE_CUSTOM_DATETIME_FORMAT_TT  = "Настройка времени и даты.\nОставить без изменения для стандартных настроек.\nСинтаксис важен!\n\n%a	сокр. день недели (Wed)\n%A	полный день недели (Wednesday)\n%b	сокр. месяц (Sep)\n%B	полное название месяца (September)\n%c	дата и время (09/16/98 23:48:10)\n%d	число [01-31]\n%H	час, 24ч система [00-23]\n%I	час, 12ч система [01-12]\n%M	минуты [00-59]\n%m	месяц [01-12]\n%p	полдень am/pm \n%S	секунды [00-61]\n%w	день недели (3) [0-6 = Sunday-Saturday]\n%x	дата (09/16/98)\n%X	время (23:48:10)\n%Y	год (1998)\n%y	год [00-99]\n%%	персонаж `%´",

    WISHLIST_LAM_SCAN                       = "Сканирование",
    WISHLIST_LAM_SCAN_ALL_CHARS             = "Проверка всех персонажей",
    WISHLIST_LAM_SCAN_ALL_CHARS_TT          = "Scan each of your characters WishLists for looted items, and not only the currently logged in character's WishList",

    --WISHLIST_LAM_ADD_ITEM                   = "Предустановка персонажа " .. GetString(WISHLIST_TITLE),
	WISHLIST_LAM_ADD_ITEM                   = "Предустановка персонажа ",
    WISHLIST_LAM_PRESELECT_CHAR_ON_ITEM_ADD = "Информация по загруженному",
    WISHLIST_LAM_PRESELECT_CHAR_ON_ITEM_ADD_TT = "Выводить таблицы для загруженного персонажа или сохранять последнего выбранного?",

    WISHLIST_LAM_ADD_MAIN_MENU_BUTTON       = "Кнопка в главном меню",
    WISHLIST_LAM_ADD_MAIN_MENU_BUTTON_TT    = "Show a button in the main menu to show the " .. GetString(WISHLIST_TITLE),

    WISHLIST_LAM_SORT                       = "Сортировка",
    WISHLIST_LAM_SORT_USE_TIEBRAKER         = "Сортировать по:",
    WISHLIST_LAM_SORT_USE_TIEBRAKER_TT      = "Use the selected column as 2nd sort tiebraker. Your selected sort column will then also be grouped by your selected column afterwards.",
    WISHLIST_LAM_SORT_USE_TIEBRAKER_NONE    = "Нет",

    WISHLIST_LAM_FCOIS                      = "FCO ItemSaver",
    WISHLIST_LAM_FCOIS_MARK_ITEM_AUTO       = "Помечать предметы",
    WISHLIST_LAM_FCOIS_MARK_ITEM_AUTO_TT    = "Mark a looted set item from your wishlist with this FCO ItemSaver marker icon",
    WISHLIST_LAM_FCOIS_MARKER_ICONS_PER_CHAR         = "FCOItemSaver - Marker icons for each char's WishList",
    WISHLIST_LAM_FCOIS_MARK_ITEM_AUTO_PER_CHAR       = "Mark looted set item indiv. for each char",
    WISHLIST_LAM_FCOIS_MARK_ITEM_AUTO_PER_CHAR_TT    = "Mark a looted set item from a characters wishlist with this FCO ItemSaver marker icon.\nEach character's wishlist can use its own marker icon.",
    WISHLIST_LAM_FCOIS_MARK_ITEM_CHARAKTER_NAME      = "Имя персонажа",
    WISHLIST_LAM_FCOIS_MARK_ITEM_ICON                = "Иконка",

    WISHLIST_LAM_ITEM_FOUND                         = "Настройка уведомлений",
    WISHLIST_LAM_ITEM_FOUND_USE_CHARACTERNAME       = "Имя персонажа",
    WISHLIST_LAM_ITEM_FOUND_USE_CHARACTERNAME_TT    = "Вкл. Имя персонажа получившего предмет из списка " .. GetString(WISHLIST_TITLE) .."\nВыкл: Имя аккаунта персонажа получившего предмет из вашего списка " .. GetString(WISHLIST_TITLE),
    WISHLIST_LAM_ITEM_FOUND_USE_CSA                 = "Экранное уведомление",
    WISHLIST_LAM_ITEM_FOUND_USE_CSA_TT              = "Уведомление в центре экрана, когда кто то из вашей группы получил предмет из списка нужного",
    WISHLIST_LAM_ITEM_FOUND_TEXT                    = "Выводимое сообщение",
    WISHLIST_LAM_ITEM_FOUND_TEXT_TT                 = "Не изменять для вывода сообщения по умолчанию.\nПресеты:\n<<1>>    Предмет(ссылка)\n<<2>>  Имя\n<<3>>   Особенность\n<<4>>  Качество\n<<5>>  Уровень\n<<6>>  Название набора",
    WISHLIST_LAM_ITEM_FOUND_SHOW_HISTORY_CHAT_OUTPUT =      "Выводить историю в чат",
    WISHLIST_LAM_ITEM_FOUND_SHOW_HISTORY_CHAT_OUTPUT_TT =   "",

    WISHLIST_LAM_FORMAT_OPTIONS                     = "Настройка отображения",
    WISHLIST_LAM_SETNAME_LANGUAGES                  = "Языки",
    WISHLIST_LAM_SETNAME_LANGUAGES_TT               = "Enable the set name languages which should be shown in the " .. GetString(WISHLIST_TITLE) .. " sets list (seperated by a / character). The current client language will be shown first (If supported. Else English is shown first).",

    WISHLIST_LAM_ITEM_FOUND_ONLY_MAX_CP             = "Максимальный уровень" ..tostring(GetChampionPointsPlayerProgressionCap()),
    WISHLIST_LAM_ITEM_FOUND_ONLY_MAX_CP_TT          = "Выводить предупреждения, только если предметы максимального уровня Очков героя"..tostring(GetChampionPointsPlayerProgressionCap()),
    WISHLIST_LAM_ITEM_FOUND_ONLY_IN_DUNGEONS        = "Внутри подземелий",
    WISHLIST_LAM_ITEM_FOUND_ONLY_IN_DUNGEONS_TT     = "Выводить уведомления только, если вы находитесь внутри подземелья",

    WISHLIST_SORTHEADER_GROUP_CHANGED               = "[" .. GetString(WISHLIST_TITLE) .. "]Sort grouping changed to: %s",

    WISHLIST_SV_MIGRATION_TO_SERVER_START       = "[WishList]SavedVariables -> Migrating to server dependent now",
    WISHLIST_SV_MIGRATION_STILL_OLD_DATA_FOUND  = "[WishList]OLD non-server dependent WishList SavedVariables still exist -> Removing them now",
    WISHLIST_SV_MIGRATION_TO_SERVER_SUCCESSFULL = "[WishList]SavedVariables were successfully migrated to server dependent ones at: %s!",
    WISHLIST_SV_MIGRATION_TO_SERVER_FAILED      = "[WishList]SavedVariables were NOT migrated. Still using non-server dependent ones!",
    WISHLIST_SV_MIGRATION_RELOADUI              = "[WishList]Reloading the UI due to SavedVariables migration!",
    WISHLIST_SV_MIGRATION_TO_SERVER_FINISHED    = "[WishList]Migration of SavedVariables of account \'%s\' to server \'%s\' finished!",
    WISHLIST_SV_MIGRATED_TO_SERVER              = "[|c00FF00WishList|r]SavedVariables migrated to server!",

    WISHLIST_LAM_ONLY_CURRENT_CHAR              = "Текущий персонаж",
    WISHLIST_LAM_ONLY_CURRENT_CHAR_TT           = "Только для текущего персонажа",
    WISHLIST_LAM_NOT_ANY_TRAIT                  = "Not \'Any\' trait",
    WISHLIST_LAM_NOT_ANY_TRAIT_TT               = "Do not do this if the item's trait on your " .. GetString(WISHLIST_TITLE) .. " is set to \'Any\'",

    WISHLIST_LAM_ITEM_FOUND_AUTO_REMOVE_HEADER  = "Auto-remove from " .. GetString(WISHLIST_TITLE),
    WISHLIST_LAM_ITEM_FOUND_AUTO_REMOVE         = "Auto-Remove found items",
    WISHLIST_LAM_ITEM_FOUND_AUTO_REMOVE_TT      = "Automatically remove found items from your ".. GetString(WISHLIST_TITLE).." if you have looted them yourself.",
}
WL.stringsEN = strings

--Register the language constants so other files can use the function "SafeAddString" too
for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end
