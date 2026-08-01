--Global language constants with English text
WishList = WishList or {}
local WL = WishList

--English base strings: These need to be seperated from other strings which "use these base strings",
-- so they can be created before the other strings
local stringsBase = {
    WISHLIST_TITLE                      = "WishList",
    WISHLIST_ALL_WISHLISTS              = "[ ALL WishLists ]",
    WISHLIST_HISTORY_TITLE              = "Historia",

    WISHLIST_TOOLTIP_COLOR_KEY          = "|cFFA500", --Orange, RGB: 255 165 000
    WISHLIST_TOOLTIP_COLOR_VALUE        = "|cF6F6F6", -- Gray-White, RGB: 246 246 246

    WISHLIST_HEADER_DATE                = "Data",                                   -- Date
    WISHLIST_HEADER_NAME                = GetString(SI_INVENTORY_SORT_TYPE_NAME),   -- Name
    WISHLIST_HEADER_TYPE                = GetString(SI_SMITHING_HEADER_ITEM),       -- Type
    WISHLIST_HEADER_SLOT                = "Slot",
    WISHLIST_HEADER_TRAIT               = GetString(SI_SMITHING_HEADER_TRAIT),      -- Trait
    WISHLIST_HEADER_CHARS               = GetString(SI_BINDING_NAME_TOGGLE_CHARACTER), -- Character / toon
    WISHLIST_HEADER_USERNAME            = "Użytkowmik",
    WISHLIST_HEADER_LOCALITY            = "Lokalizacja",
    WISHLIST_HEADER_QUALITY             = GetString(SI_TRADINGHOUSEFEATURECATEGORY5), --Quality
    WISHLIST_HEADER_LAST_ADDED          = "Ostatnio dodane",

    WISHLIST_CONST_ID                   = "id",
    WISHLIST_CONST_SET                  = "Zestaw",
    WISHLIST_CONST_BONUS                = "Bonusy",
    WISHLIST_CONST_ARMORANDWEAPONTYPE   = "Typ Zbroi / Broni",
    WISHLIST_CONST_ARMORTYPE            = "Typ Zbroi",
    WISHLIST_CONST_WEAPONTYPE           = "Typ Broni",
    WISHLIST_CONST_ITEMID               = "ItemId",

    WISHLIST_DIALOG_ADD_ITEM            = "Dodaj przedmiot",
    WISHLIST_BUTTON_REMOVE_HISTORY_TT   = "Wyczyść Historię",

    WISHLIST_DLC                        = GetString(SI_MARKET_PRODUCT_TOOLTIP_DLC),
    WISHLIST_ZONE                       = GetString(SI_CHAT_CHANNEL_NAME_ZONE),
    WISHLIST_WAYSHRINES                 = GetString(SI_MAPFILTER8),
    WISHLIST_ARMORTYPE                  = GetString(SI_ITEM_FORMAT_STR_ARMOR) .. " " .. GetString(SI_GUILD_HERALDRY_TYPE_HEADER),
    WISHLIST_DROPLOCATIONS              = "Lokalizacje Dropu",
    WISHLIST_DROPLOCATION_SPECIAL       = "Specjalne (e.g. Level Up, Prophet)",
    WISHLIST_DROPLOCATION_BG            = GetString(SI_LEADERBOARDTYPE4), --Battleground

    WISHLIST_LIBSETS                    = "LibSets",

    WISHLIST_ARMOR                      = GetString(SI_ITEMTYPE2),
    WISHLIST_WEAPONS                    = GetString(SI_ITEMFILTERTYPE1),
    WISHLIST_JEWELRY                    = GetString(SI_ITEMFILTERTYPE25),
}
--Add missing translations from language "en" strings table as "fallback" (metatable)
--setmetatable(stringsBase, {__index = WL.stringsBaseEN})
for stringId, stringValue in pairs(stringsBase) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end

--English WishList translations (using already created base strings)
local strings = {
    WISHLIST_SEARCHDROP_START        = "Szukaj po ",
    WISHLIST_SEARCHDROP1       = GetString(WISHLIST_HEADER_NAME) .. "/SetId",
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
    WISHLIST_SEARCHDROP11      = GetString(WISHLIST_LIBSETS) .. ": Typ zestawu",
    WISHLIST_SEARCHDROP12      = GetString(WISHLIST_LIBSETS) .. ": " .. GetString(WISHLIST_DLC),
    WISHLIST_SEARCHDROP13      = GetString(WISHLIST_LIBSETS) .. ": Potrzebne Cechy",
    WISHLIST_SEARCHDROP14      = GetString(WISHLIST_LIBSETS) .. ": " .. GetString(WISHLIST_ZONE),
    WISHLIST_SEARCHDROP15      = GetString(WISHLIST_LIBSETS) .. ": " .. GetString(WISHLIST_WAYSHRINES),
    WISHLIST_SEARCHDROP16      = GetString(WISHLIST_LIBSETS) .. ": " .. GetString(WISHLIST_DROPLOCATIONS),

    WISHLIST_LOOT_MSG_YOU            = "ZDOBYTO ",
    WISHLIST_LOOT_MSG_OTHER          = " ZDOBYTO ",
    WISHLIST_LOOT_MSG_STANDARD       = "[<<2>>] zdobyto: \"<<1>>\" z Cechą <<3>>, Jakość: <<4>>, Poziom: <<5>>, Zestaw: \"<<6>>\"",

    WISHLIST_CONTEXTMENU_FROM        = " from " .. GetString(WISHLIST_TITLE),
    WISHLIST_CONTEXTMENU_ADD         = "Dodaj do " .. GetString(WISHLIST_TITLE),
    WISHLIST_CONTEXTMENU_REMOVE      = "Usuń z " .. GetString(WISHLIST_TITLE),
    WISHLIST_CONTEXTMENU_REMOVE_FROM_LAST_ADDED = "Usuń z Ostatnio Dodanych",
    WISHLIST_CONTEXTMENU_CLEAR_LAST_ADDED = "Wyczyść Ostatnio Dodane (to zamknie to okno dialogowe!)",
    WISHLIST_CLEAR_LAST_ADDED_TITLE = "Wyczyścić Historię Ostatnio Dodanych?",
    WISHLIST_CLEAR_LAST_ADDED_TEXT = "Czy naprawdę chcesz wyczyścić wszystkie wpisy z Historii Ostatnio Dodanych?",

    WISHLIST_CONTEXTMENU_SETITEMCOLLECTION_ADD = "Dodaj każdą pojedynczą Cechę do " .. GetString(WISHLIST_TITLE),
    WISHLIST_CONTEXTMENU_SETITEMCOLLECTION_ADD_1_ITEM = "Dodaj wszystkie Cechy jako 1 pozycję dla " .. GetString(WISHLIST_TITLE),
    WISHLIST_CONTEXTMENU_SETITEMCOLLECTION_REMOVE = "Usuń wszystkie Cechy z " .. GetString(WISHLIST_TITLE),
    WISHLIST_CONTEXTMENU_SETITEMCOLLECTION_REMOVE_SLOT = "Usuń wszystkie Cechy slotu z " .. GetString(WISHLIST_TITLE),

    WISHLIST_ADDED                   = " dodano do " .. GetString(WISHLIST_TITLE),
    WISHLIST_REMOVED                 = " usunięto z " .. GetString(WISHLIST_TITLE),
    WISHLIST_UPDATED                 = " zaktualizowano <<1>> w " .. GetString(WISHLIST_TITLE),
    WISHLIST_ITEMS_ADDED             = "<<1[Brak elementu/1 element/$d elementów]>> dodano do " .. GetString(WISHLIST_TITLE),
    WISHLIST_ITEMS_REMOVED           = "<<1[Brak elementu/1 element/$d elementów]>> usunięto z " .. GetString(WISHLIST_TITLE),
    WISHLIST_ITEMS_UPDATED           = "<<1[Brak elementu/1 element/$d elementów]>> zmieniono w " .. GetString(WISHLIST_TITLE),

    WISHLIST_HISTORY_ADDED                   = " dodano do " .. GetString(WISHLIST_HISTORY_TITLE),
    WISHLIST_HISTORY_REMOVED                 = " usunięto z " .. GetString(WISHLIST_HISTORY_TITLE),
    WISHLIST_HISTORY_ITEMS_ADDED             = "<<1[Brak wpisu/1 wpis/$d wpisów]>> dodano do " .. GetString(WISHLIST_HISTORY_TITLE),
    WISHLIST_HISTORY_ITEMS_REMOVED           = "<<1[Brak wpisu/1 wpis/$d wpisów]>> usunięto z " .. GetString(WISHLIST_HISTORY_TITLE),

    WISHLIST_ITEMTRAITTYPE_SPECIAL  = "Specjalne",

    WISHLIST_DIALOG_ADD_WHOLE_SET_TT         = "Dodaj wszystkie przedmioty z bieżącego Zestawu, z wybraną Cechą do Twojego " .. GetString(WISHLIST_TITLE),
    WISHLIST_DIALOG_ADD_ALL_TYPE_OF_SET_TT   = "Dodaj wszystkie przedmioty z bieżącego Zestawu, z wybranym Typem przedmiotu (<<1>>) i wybraną Cechę, do Twojego " .. GetString(WISHLIST_TITLE),
    WISHLIST_DIALOG_ADD_ALL_TYPE_TYPE_OF_SET_TT = "Dodaj wszystkie przedmioty z bieżącego Zestawu, z wybranym Typem przedmiotu (<<1>>), item (<<2>>) i wybraną Cechę, do Twojego " .. GetString(WISHLIST_TITLE),
    WISHLIST_DIALOG_ADD_ANY_TRAIT            = "Dowolna Cecha",
    WISHLIST_NO_ITEMS_ADDED_WITH_SELECTED_DATA = "Nie znaleziono przedmiotów z wybranymi danymi -> Żadne przedmioty nie zostały dodane do Twojego " .. GetString(WISHLIST_TITLE),
    WISHLIST_DIALOG_ADD_ONE_HANDED_WEAPONS_OF_SET_TT = "Dodaj wszystkie Jednoręczne bronie z bieżącego Zestawu, z wybraną Cechą do Twojego  " .. GetString(WISHLIST_TITLE),
    WISHLIST_DIALOG_ADD_TWO_HANDED_WEAPONS_OF_SET_TT = "Dodaj wszystkie Dwuręczne bronie z bieżącego zestawu z wybraną cechą do twojego " .. GetString(WISHLIST_TITLE),
    WISHLIST_DIALOG_ADD_BODY_PARTS_ARMOR_OF_SET_TT = "Dodaj wszystkie(oprócz tych na ramiona i głowę) części Zbroi z bieżącego Zestawu, z wybraną Cechą, do Twojego " .. GetString(WISHLIST_TITLE),
    WISHLIST_DIALOG_ADD_MONSTER_SET_PARTS_ARMOR_OF_SET_TT = "Dodaj części Zbroi na ramiona i głowę z bieżącego Zestawu, z wybraną Cechą, do Twojego " .. GetString(WISHLIST_TITLE),

    WISHLIST_DIALOG_REMOVE_ITEM              = "Usuń przedmiot",
    WISHLIST_DIALOG_REMOVE_ITEM_QUESTION     = "Usuń <<1>>?",
    WISHLIST_DIALOG_REMOVE_ITEM_DATETIME            = "Usuń przedmioty z Datą i Godziną \"<<1>>\"",
    WISHLIST_DIALOG_REMOVE_ITEM_TYPE                = "Usuń przedmioty z Typem przedmiotu \"<<1>>\"",
    WISHLIST_DIALOG_REMOVE_ITEM_ARMORORWEAPONTYPE   = "Usuń przedmioty z Typem \"<<1>>\"",
    WISHLIST_DIALOG_REMOVE_ITEM_TYPE_ARMORORWEAPONTYPE_SLOT = "Usuń przedmioty z Typem przedmiotu \"<<1>>\", Typ \"<<2>>\", Slot \"<<3>>\"",
    WISHLIST_DIALOG_REMOVE_ITEM_SLOT                = "Usuń przedmioty ze Slotem \"<<1>>\"",
    WISHLIST_DIALOG_REMOVE_ITEM_TRAIT               = "Usuń przedmioty z Cechą \"<<1>>\"",
    WISHLIST_DIALOG_REMOVE_ITEM_KNOWN_SETITEMCOLLECTION_OF_SET = "Usuń z Zestawu znane przedmioty, które zostały dodane do Kolekcji Zestawów \"<<1>>\"",
    WISHLIST_DIALOG_REMOVE_ITEM_KNOWN_SETITEMCOLLECTION = "Usuń ze wszystkich Zestawów znane przedmioty, które zostały dodane do Kolekcji Zestawów",
    WISHLIST_CONTEXTMENU_ADD_ITEM_UNKNOWN_SETITEMCOLLECTION_OF_SET = "Dodaj nieznane przedmioty z Zestawu \"<<1>>\" do " .. GetString(WISHLIST_TITLE),
    WISHLIST_CONTEXTMENU_REMOVE_ITEM_KNOWN_SETITEMCOLLECTION_OF_SET = "Usuń znane przedmioty z Zestawu \"<<1>>\" z " .. GetString(WISHLIST_TITLE),
    WISHLIST_CONTEXTMENU_REMOVE_ITEM_KNOWN_SETITEMCOLLECTION = "Usuń znane przedmioty ze wszystkich Zestawów z " ..GetString(WISHLIST_TITLE),
    WISHLIST_CONTEXTMENU_REMOVE_ITEM_KNOWN_SETITEMCOLLECTION_OF_SET_ALL_WISHLISTS = "Usuń znane przedmioty z Zestawu \"<<1>>\" ze WSZYSTKICH WishList",
    WISHLIST_CONTEXTMENU_REMOVE_ITEM_KNOWN_SETITEMCOLLECTION_ALL_WISHLISTS = "Usuń znane przedmioty ze wszystkich Zestawów ze WSZYSTKICH WishList",

    WISHLIST_DIALOG_REMOVE_WHOLE_SET         = "Usuń cały Zestaw \"<<1>>\"",
    WISHLIST_DIALOG_REMOVE_WHOLE_SET_QUESTION= "Naprawdę usunąć wszystkie przedmioty z Zestawu \"<<1>>\"?",
    WISHLIST_BUTTON_REMOVE_ALL_TT            = "Usuń wszystkie przedmioty wybranej Postaci z Twojego " .. GetString(WISHLIST_TITLE),
    WISHLIST_DIALOG_REMOVE_ALL_ITEMS_QUESTION     = "Naprawdę usunąć wszystkie przedmioty?",
    WISHLIST_BUTTON_CLEAR_HISTORY_TT            = GetString(WISHLIST_BUTTON_REMOVE_HISTOTY_TT) .. "?",
    WISHLIST_DIALOG_CLEAR_HISTORY_QUESTION      = "Naprawdę wyczyścić " .. GetString(WISHLIST_HISTORY_TITLE) .. " dla wybranej Postaci?",
    WISHLIST_DIALOG_CHANGE_QUALITY              = "Zmień " .. GetString(SI_TRADINGHOUSEFEATURECATEGORY5),
    WISHLIST_DIALOG_CHANGE_QUALITY_QUESTION     = "Zmień <<1>>?",
    WISHLIST_DIALOG_CHANGE_QUALITY_WHOLE_SET    = "Zmień " .. GetString(SI_TRADINGHOUSEFEATURECATEGORY5) .. " z Zestawu",
    WISHLIST_DIALOG_CHANGE_QUALITY_WHOLE_SET_QUESTION   = "Czy na pewno zmienić wszystkie przedmioty z Zestawu \"<<1>>\"?",

    WISHLIST_BUTTON_COPY_WISHLIST_TT            = "Kopiuj " .. GetString(WISHLIST_TITLE),
    WISHLIST_BUTTON_CHOOSE_CHARACTER_TT         = "Wybierz Postać",
    WISHLIST_BUTTON_CHOOSE_CHARACTER_QUESTION_ADD_ITEM   = GetString(WISHLIST_DIALOG_ADD_ITEM) .. " <<1>>:",
    WISHLIST_BUTTON_CHOOSE_CHARACTER_QUESTION_ADD_ITEM_AND_MORE = GetString(WISHLIST_DIALOG_ADD_ITEM) .. " <<1>>, i <<2>> więcej:",
    WISHLIST_BUTTON_CHOOSE_CHARACTER_QUESTION_COPY_WL  = "Kopiuj " .. GetString(WISHLIST_TITLE) .. " z <<1>> do:",
    WISHLIST_ITEM_COPIED                        = "Skopiowano <<1>> z <<2>> do <<3>>",
    WISHLIST_NO_ITEMS_COPIED                    = "Żadne przedmioty nie zostały skopiowane. Być może wszystkie znajdują się już w miejscu docelowym  " .. GetString(WISHLIST_TITLE),

    WISHLIST_DIALOG_RELOAD_ITEMS             = "Załaduj ponownie przedmioty",
    WISHLIST_DIALOG_RELOAD_ITEMS_QUESTION    = "To ponownie załaduje wszystkie przedmioty z Zwstawów przy użyciu biblioteki \'LibSets\'!\nNie powinno to zająć więcej niż 5 sekund.",
    WISHLIST_LINK_ITEM_TO_CHAT               = GetString(SI_ITEM_ACTION_LINK_TO_CHAT),
    WISHLIST_WHISPER_RECEIVER                = "Szepnij \"<<C:1>>\" i poproś o <<2>>",
    WISHLIST_WHISPER_RECEIVER_QUESTION       = "Hey <<1>>, you have found this item: <<2>>. I'm searching for it and would like to ask if you will trade it to me? Thank you.",

    WISHLIST_SETS_LOADED                     = "załadowano <<1[Brak Zestawu/1 Zestaw/$d Zestawy]>>",
    WISHLIST_NO_SETS_LOADED                  = "Nie załadowano żadnych Zestawów. Kliknij przycisk, aby załadować wszystkie Zestawy.\nMoże to potrwać kilka minut i spowodować spowolnienie działania Twojego Klienta Gry!",
    WISHLIST_LOAD_SETS                       = "Załaduj Zestawy",
    WISHLIST_LOADING_SETS                    = "Ładowanie Zestawów...",
    WISHLIST_TOTAL_SETS                      = "Łącznie Zestawów: ",
    WISHLIST_TOTAL_SETS_ITEMS                = "Łącznie Przedmiotów: ",
    WISHLIST_SETS_FOUND                      = "Znaleziono Zestawów: <<1>> z <<2>> przedmiotami",

    WISHLIST_ITEM_QUALITY_ALL                       = "Dowolny " .. GetString(SI_TRADINGHOUSEFEATURECATEGORY5),
    WISHLIST_ITEM_QUALITY_MAGIC_OR_ARCANE           = GetString(SI_ITEMQUALITY2) .. ", " .. GetString(SI_ITEMQUALITY3), 		--Magic or arcane
    WISHLIST_ITEM_QUALITY_ARCANE_OR_ARTIFACT        = GetString(SI_ITEMQUALITY3) .. ", " .. GetString(SI_ITEMQUALITY4), 		--Arcane or artifact
    WISHLIST_ITEM_QUALITY_ARTIFACT_OR_LEGENDARY     = GetString(SI_ITEMQUALITY4) .. ", " .. GetString(SI_ITEMQUALITY5), 	    --Artifact or legendary
    WISHLIST_ITEM_QUALITY_MAGIC_TO_LEGENDARY        = GetString(SI_ITEMQUALITY2) .. " -> " .. GetString(SI_ITEMQUALITY5), 		--Magic to legendary
    WISHLIST_ITEM_QUALITY_ARCANE_TO_LEGENDARY       = GetString(SI_ITEMQUALITY3) .. " -> " .. GetString(SI_ITEMQUALITY5), 		--Arcane to legendary

    --Tooltips
    WISHLIST_BUTTON_RELOAD_TT                = "Załaduj ponownie dane wszystkich Zestawów",
    WISHLIST_BUTTON_SEARCH_TT                = "Wyszukiwanie Zestawów i Przedmiotów",
    WISHLIST_BUTTON_WISHLIST_TT              = "Twoje " .. GetString(WISHLIST_TITLE),
    WISHLIST_BUTTON_HISTORY_TT               = zo_strformat("<<C:1>>", GetString(WISHLIST_HISTORY_TITLE)),
    WISHLIST_BUTTON_SETTINGS_TT              = GetString(WISHLIST_TITLE) .. " ustawienia",
    WISHLIST_BUTTON_SET_ITEM_COLLECTION_TT   = "Pokaż kolekcje przedmiotów z Zestawów",
    WISHLIST_CHARDROPDOWN_ITEMCOUNT_WISHLIST = "[<<C:1>>]\n<<2[Brak przedmiotu/1 przedmiot/$d przedmiotów]>> Wł. " .. GetString(WISHLIST_TITLE),
    WISHLIST_CHARDROPDOWN_ITEMCOUNT_HISTORY  = "[<<C:1>>]\n<<2[Brak wpisu/1 wpis/$d wpisów]>> w " .. GetString(WISHLIST_HISTORY_TITLE),

    --Keybindings
    SI_BINDING_NAME_WISHLIST_SHOW           = "Pokaż " .. GetString(WISHLIST_TITLE),
    SI_BINDING_NAME_WISHLIST_ADD_OR_REMOVE  = "Dodaj/Usuń do/z " .. GetString(WISHLIST_TITLE),
    SI_BINDING_NAME_WISHLIST_SHOW_ITEM_SET_COLLECTION_CURRENT_ZONE  = "Pokaż bieżącą Strefę w kolekcjach Zestawów",
    SI_BINDING_NAME_WISHLIST_SHOW_ITEM_SET_COLLECTION_CURRENT_PARENT_ZONE  = "Pokaż bieżącą Strefę nadrzędną w kolekcjach Zestawów",
    WISHLIST_SHOW_ITEM_SET_COLLECTION_MORE_OPTIONS = "Więcej opcji",

    -- LAM addon settings
    WISHLIST_WARNING_RELOADUI               = "Uwaga:\nZmiana tej opcji spowoduje automatyczne ponowne załadowanie Interfejsu Użytkownika!",
    WISHLIST_LAM_ADDON_DESC                 = GetString(WISHLIST_TITLE) .. " - Twoja Lista poszukiwanych przedmiotów z Zestawów",
    WISHLIST_LAM_SAVEDVARIABLES             = "Zapis ustawień",
    WISHLIST_LAM_SV                         = "Typ zapisu",
    WISHLIST_LAM_SV_TT                      = "Wybierz, czy chcesz zapisać ustawienia dla całego Konta, czy oddzielnie dla każdej ze swoich Postaci.\n\nNie ma to wpływu na Wish Lists! Możesz tam wybrać dowolną Postać i edytować listę dla niej.",
    WISHLIST_LAM_SV_ACCOUNT_WIDE            = "Dla całego Konta",
    WISHLIST_LAM_SV_EACH_CHAR               = "Dla każdej Postaci oddzielnie",
    WISHLIST_LAM_USE_24h_FORMAT             = "Użyj 24-godzinnego formatu czasu",
    WISHLIST_LAM_USE_24h_FORMAT_TT          = "Użyj 24-godzinnego formatu czasu dla formatów daty i godziny",
    WISHLIST_LAM_USE_CUSTOM_DATETIME_FORMAT     = "Niestandardowy format Daty i Godziny",
    WISHLIST_LAM_USE_CUSTOM_DATETIME_FORMAT_TT  = "Określ własny format daty i godziny.\nPozostaw pole edycji puste, aby używać standardowego formatu daty i godziny.\nUżywalne symbole zastępcze są predefiniowane w języku lua:\n\n%a	abbreviated weekday name (e.g., Wed)\n%A	full weekday name (e.g., Wednesday)\n%b	abbreviated month name (e.g., Sep)\n%B	full month name (e.g., September)\n%c	date and time (e.g., 09/16/98 23:48:10)\n%d	day of the month (16) [01-31]\n%H	hour, using a 24-hour clock (23) [00-23]\n%I	hour, using a 12-hour clock (11) [01-12]\n%M	minute (48) [00-59]\n%m	month (09) [01-12]\n%p	either \"am\" or \"pm\" (pm)\n%S	second (10) [00-61]\n%w	weekday (3) [0-6 = Sunday-Saturday]\n%x	date (e.g., 09/16/98)\n%X	time (e.g., 23:48:10)\n%Y	full year (1998)\n%y	two-digit year (98) [00-99]\n%%	the character `%´",

    WISHLIST_LAM_SCAN                       = "Skanowanie",
    WISHLIST_LAM_SCAN_ALL_CHARS             = "Skanuj WishListy wszystkich Postaci",
    WISHLIST_LAM_SCAN_ALL_CHARS_TT          = "Skanuj WishListy wszystkich swoich Postaci, gdy zbierzesz przedmiot, lub sprawdzaj tylko aktualnie zlogowaną Postać.",

    WISHLIST_LAM_ADD_ITEM                   = "Dodaj przedmioty do " .. GetString(WISHLIST_TITLE),
    WISHLIST_LAM_PRESELECT_CHAR_ON_ITEM_ADD = "Aktualnie zalogowana postać jako domyślna",
    WISHLIST_LAM_PRESELECT_CHAR_ON_ITEM_ADD_TT = "Użyć aktualnie granej Postaci jako domyślnej dla listy wyboru postaci w okienku Dodawania Przedmiotu, czy użyć postaci wybranej w zakładce WishList?",

    WISHLIST_LAM_ADD_MAIN_MENU_BUTTON       = "Pokaż przycisk w Menu Głównym",
    WISHLIST_LAM_ADD_MAIN_MENU_BUTTON_TT    = "Pokaż przycisk w Memu Głównym(u góry ekranu) otwierający okienko " .. GetString(WISHLIST_TITLE),

    WISHLIST_LAM_SORT                       = "Sortowanie",
    WISHLIST_LAM_SORT_USE_TIEBRAKER         = "Sortowanie tworzy Grupy",
    WISHLIST_LAM_SORT_USE_TIEBRAKER_TT      = "Podczas sortowania list, po normalnie wybranej kolumnie sortowania tworzone są dodatkowe grupy, które następnie grupują posortowane przedmioty z drugą wybraną kolumną.",
    WISHLIST_LAM_SORT_USE_TIEBRAKER_NONE    = "Bez grupowania!",

    WISHLIST_LAM_FCOIS                      = "FCO ItemSaver",
    WISHLIST_LAM_FCOIS_MARK_ITEM_AUTO       = "Oznacz zdobyty przedmiot z Zestawu",
    WISHLIST_LAM_FCOIS_MARK_ITEM_AUTO_TT    = "Oznacz zdobyty przedmiot z zestawu z Twojej Wishlisty za pomocą ikony znacznika FCO ItemSaver.",
    WISHLIST_LAM_FCOIS_MARKER_ICONS_PER_CHAR         = "FCOItemSaver - Ikony znaczników dla WishListy każdej Postaci",
    WISHLIST_LAM_FCOIS_MARK_ITEM_AUTO_PER_CHAR       = "Oznacz zdobyty przedmiot z Zestawu indywidualnie dla każdej Postaci",
    WISHLIST_LAM_FCOIS_MARK_ITEM_AUTO_PER_CHAR_TT    = "Oznacz zdobyty przedmiot z Zestawu z Wishlisty danej Postaci za pomocą tej ikony znacznika FCO ItemSaver.\nWishList każdej postaci może korzystać z własnej ikony znacznika.",
    WISHLIST_LAM_FCOIS_MARK_ITEM_CHARAKTER_NAME      = "Nazwa postaci",
    WISHLIST_LAM_FCOIS_MARK_ITEM_ICON                = "Ikona znacznika",

    WISHLIST_LAM_ITEM_FOUND                         = "Znalezione przedmioty na " .. GetString(WISHLIST_TITLE),
    WISHLIST_LAM_ITEM_FOUND_USE_CHARACTERNAME       = "Pokaż nazwę Postaci lub Konta",
    WISHLIST_LAM_ITEM_FOUND_USE_CHARACTERNAME_TT    = "Włączone: Pokazuje nazwę Postaci, która zdobyła przedmiot z Twojej " .. GetString(WISHLIST_TITLE) .."\nWyłączone: Wyświetla nazwę konta, z którego postać zdobyła przedmiot z Twojej  " .. GetString(WISHLIST_TITLE),
    WISHLIST_LAM_ITEM_FOUND_USE_CSA                 = "Pokaż również komunikat ekranowy",
    WISHLIST_LAM_ITEM_FOUND_USE_CSA_TT              = "Wyświetla powiadomienie o zdobyciu przedmiotów dodatkowo do tekstu na czacie, również jako wiadomość ekranową",
    WISHLIST_LAM_ITEM_FOUND_TEXT                    = "Komunikat o zdobyciu przedmiotu",
    WISHLIST_LAM_ITEM_FOUND_TEXT_TT                 = "Określ tekst komunikatu, który bedzie wyświetlany w oknie czatu i (jeśli włączono), również w komunikacie ekranowym, jeśli przedmiot z Twojej " .. GetString(WISHLIST_TITLE) .. " zostanie zdobyty.\nPozostaw puste pole edycji, aby wyświetlić domyślny komunikat o zdobyciu przedmiotu.\n\nW komunikacie można użyć następujących symboli zastępczych, które zostaną zastąpione informacjami o zdobytym przedmiocie:\n<<1>>    Nazwa (link)\n<<2>>  Zdobyto przez\n<<3>>   Cecha\n<<4>>  Jakość\n<<5>>  Poziom\n<<6>>  Nazwa Zestawu",
    WISHLIST_LAM_ITEM_FOUND_WHISPER_TEXT            = "Szepnij: 'Zapytaj o przedmiot",
    WISHLIST_LAM_ITEM_FOUND_WHISPER_TEXT_TT         = "Ten tekst zostanie wysłany jako Szept do użytkownika, którego pytasz o przedmiot (poprzez Historię WishList). W tekście można użyć następujących symboli zastępczych:\n<<1>>   Nazwa Użytkownika, który zdobył przedmiot\n<<2>>Nazwa przedmiotu + link",
    WISHLIST_LAM_ITEM_FOUND_SHOW_HISTORY_CHAT_OUTPUT =      "Informacje na czacie o nowych wpisach w Historii",
    WISHLIST_LAM_ITEM_FOUND_SHOW_HISTORY_CHAT_OUTPUT_TT =   "Pokazuje informację na czacie o nowych wpisach w Historii, gdy coś zostanie zdobyte..",

    WISHLIST_LAM_FORMAT_OPTIONS                     = "Format wyświetlanych powiadomień",
    WISHLIST_LAM_SETNAME_LANGUAGES                  = "Określ języki nazw",
    WISHLIST_LAM_SETNAME_LANGUAGES_TT               = "Aktywuj języki, w któych nazwy Zestawów mają być wyświetlane na " .. GetString(WISHLIST_TITLE) .. " (oddzielone znakiem /). Jako pierwszy wyświetlany jest bieżący język gry (jeśli jest obsługiwany, w przeciwnym razie jako pierwszy wyświetlany jest język angielski).",

    WISHLIST_LAM_ITEM_FOUND_ONLY_MAX_CP             = "Tylko poziom przedmiotu = max CP" ..tostring(GetChampionPointsPlayerProgressionCap()),
    WISHLIST_LAM_ITEM_FOUND_ONLY_MAX_CP_TT          = "Powiadomienia będą wyświetlana tylko wtedy, gdy poziom przedmiotu jest maksymalnym poziomem CP"..tostring(GetChampionPointsPlayerProgressionCap()),
    WISHLIST_LAM_ITEM_FOUND_ONLY_IN_DUNGEONS        = "Tylko w lochach",
    WISHLIST_LAM_ITEM_FOUND_ONLY_IN_DUNGEONS_TT     = "Otrzymuj powiadomienia tylko wtedy, gdy aktualnie znajdujesz się w lochu.",

    WISHLIST_SORTHEADER_GROUP_CHANGED               = "[" .. GetString(WISHLIST_TITLE) .. "]Grupa sortowania została zmieniona na: %s",

    WISHLIST_SV_MIGRATION_TO_SERVER_START       = "[WishList]SavedVariables -> Trwa migracja do danych zależnych od serwera.",
    WISHLIST_SV_MIGRATION_STILL_OLD_DATA_FOUND  = "[WishList]STARE nie zależne od serwera WishList SavedVariables wciąż istnieją -> Removing them now",
    WISHLIST_SV_MIGRATION_TO_SERVER_SUCCESSFULL = "[WishList]SavedVariables zostały pomyślnie zmigrowane do zależnych od serwera w: %s!",
    WISHLIST_SV_MIGRATION_TO_SERVER_FAILED      = "[WishList]SavedVariables NIE zostały zmigrowane. Nadal używasz tych niezależnych od serwera!",
    WISHLIST_SV_MIGRATION_RELOADUI              = "[WishList]Przeładowanie Interfejsu Użytkownika z powodu migracji SavedVariables!",
    WISHLIST_SV_MIGRATION_TO_SERVER_FINISHED    = "[WishList]Migracja SavedVariables konta \'%s\' do serwera \'%s\' zakończona!",
    WISHLIST_SV_MIGRATED_TO_SERVER              = "[|c00FF00WishList|r]SavedVariables zostało zmigrowane na serwer!",

    WISHLIST_LAM_ONLY_CURRENT_CHAR              = "Tylko dla bieżącej Postaci",
    WISHLIST_LAM_ONLY_CURRENT_CHAR_TT           = "Zrób to tylko dla aktualnie zalogowanej postaci",
    WISHLIST_LAM_NOT_ANY_TRAIT                  = "Nie \'Dowolny\' Cecha",
    WISHLIST_LAM_NOT_ANY_TRAIT_TT               = "Nie rób tego, jeśli cecha przedmiotu na Twojej  " .. GetString(WISHLIST_TITLE) .. " jest ustawiona na \'Dowolny\'",

    WISHLIST_LAM_ITEM_FOUND_AUTO_REMOVE_HEADER  = "Automatyczne usuwanie z " .. GetString(WISHLIST_TITLE),
    WISHLIST_LAM_ITEM_FOUND_AUTO_REMOVE         = "Automatyczne usuwanie znalezionych przedmiotów",
    WISHLIST_LAM_ITEM_FOUND_AUTO_REMOVE_TT      = "Automatyczne usuwanie znalezionych przedmiotów z Twojej ".. GetString(WISHLIST_TITLE).." jeśli zostały one zdobyte przez Twoją postać.",

    --Gear
    WISHLIST_LAM_GEAR                           = "Ustawienia Notek",
    WISHLIST_LAM_GEAR_DESC                      = "Ustaw swoją własną Ikonę i kolor dla znacznika\'Notka\',dodaj Tytuł i Treść.\nMożesz przypisać tę ikonę Notki do przedmiotów z Twojej WishList (menu kontekstowe).",
    WISHLIST_LAM_GEARS_DROPDOWN                 = "Dostępne Notki",
    WISHLIST_LAM_GEARS_DROPDOWN_TT              = "Wybierz jedną z utworzonych Notek, aby ją edytować/usunąć.",
    WISHLIST_LAM_GEARS_NAME_EDIT                = "Tytuł Notki",
    WISHLIST_LAM_GEARS_NAME_EDIT_TT             = "Podaj Tytuł Twojej Notki. Zostanie on wyświetlony w podpowiedzi dla ikony Notki przy przedmiotach na WishList.",
    WISHLIST_LAM_GEARS_COMMENT_EDIT             = "Treść Notki",
    WISHLIST_LAM_GEARS_COMMENT_EDIT_TT          = "Podaj Treść Twojej Notki. Zostanie on wyświetlony w podpowiedzi dla ikony Notki przy przedmiotach na WishList.",

    WISHLIST_LAM_GEARS_BUTTON_ADD               = "Dodaj nową",
    WISHLIST_LAM_GEARS_BUTTON_ADD_TT            = "Kliknij tutaj, aby dodać nową Notkę. Musisz wypełnić pole Tytuł Notki.\n\nPo wprowadzeniu Tytułu Notki kliknij przycisk \'Zapisz\'!\nJeśli chcesz edytować Tytuł/Treść/Ikonę/color wybierz dodaną Notkę z rozwijanej listy \'Dostępne Notki\'.",
    WISHLIST_LAM_GEARS_BUTTON_SAVE              = "Zapisz",
    WISHLIST_LAM_GEARS_BUTTON_SAVE_TT           = "Kliknij tutaj, aby zapisać nowo dodawaną Notkę (przy pomocy przycisku \'Dodaj nową\').\nIstniejąca Notka wybrana z rozwijanej listy zostanie zapisna automatycznie kiedy zminisz coś w jej konfiguracji.",
    WISHLIST_LAM_GEARS_BUTTON_DELETE            = "Usuń",
    WISHLIST_LAM_GEARS_BUTTON_DELETE_TT         = "Usuń wybraną Notkę",
    WISHLIST_LAM_GEARS_BUTTON_DELETE_WARN       = "Czy na pewno chcesz usunąć wybraną Notkę?\nPrzedmioty do których już została przypisana ta Notka utracą ten znacznik!",

    WISHLIST_LAM_GEAR_MARKER_ICON               = "Ikona Notki",
    WISHLIST_LAM_GEAR_MARKER_ICON_TT            = "Wybierz ikonę dla Notki",
    WISHLIST_LAM_GEAR_MARKER_ICON_COLOR         = "Kolor ikony Notki",
    WISHLIST_LAM_GEAR_MARKER_ICON_COLOR_TT      = "Wybierz kolor ikony dla Notki",

    WISHLIST_LAM_GEAR_MARKER_ICON_ADD_FCOIS     = "Dodaj FCOIS gear",
    WISHLIST_LAM_GEAR_MARKER_ICON_ADD_FCOIS_TT  = "Jeśli ta opcja jest włączona Twoje \'Dostępne Notki\' zostaną rozszerzone o znaczniki z dodatku FCOItemSaver, dzięki czemu możesz używać tych ikon również do oznaczania Notek WishList.\nTo jest TYLKO \'Kopia wizualna\' ikon znaczników FCOIS i nie daje żadnych benefitów FCOIS!\n\nZnaczniki będą tylko dodawane. Już dodane znaczniki Notek zostaną zachowane! \nMusisz ręcznie wyczyścić duplikaty/błędy!",
    WISHLIST_LAM_GEAR_MARKER_ICON_ADD_FCOIS_WARN = "Chcesz dodać znaczniki FCOIS do swojej Notki?\nZnaczniki będą tylko dodawane. Już dodane znaczniki Notek zostaną zachowane!\nMusisz ręcznie wyczyścić duplikaty/błędy!",

    WISHLIST_GEAR_ASSIGN_ICON                   = "Przypisz znacznik Notki",
    WISHLIST_GEAR_ASSIGN_ICON_SET               = "Przypisz znacznik Notki do Zestawu",
    WISHLIST_GEAR_ASSIGN_ICON_ALL               = "Przypisz znacznik Notki do wszystkich przedmiotów",
    WISHLIST_DIALOG_ADD_GEAR_WHOLE_SET         = "Przypisz Notkę - cały Zestaw \"<<1>>\"",
    WISHLIST_DIALOG_ADD_SELECTED_GEAR_WHOLE_SET_QUESTION= "Czy na pewno przypisać znacznik Notki <<1>> do Zestawu \"<<2>>\"?",
    WISHLIST_DIALOG_ADD_GEAR_MARKER            = "Przypisz Notkę",
    WISHLIST_DIALOG_ADD_GEAR_MARKER_QUESTION   = "Przypisz Notkę <<1>>",
    WISHLIST_DIALOG_ADD_GEAR_MARKER_ALL        = "Przypisz Notkę <<1>> do wszystkich przedmiotów",

    WISHLIST_GEAR_REMOVE_ICON                   = "Usuń ikonę Notki %s",
    WISHLIST_GEAR_REMOVE_ICON_FROM_SET          = "Usuń ikonę Notki %s z Zestawu",
    WISHLIST_GEAR_REMOVE_ALL_ICONS_FROM_SET     = "Usuń wszystkie ikony Notek z Zestawu",
    WISHLIST_GEAR_REMOVE_ICON_FROM_ALL          = "Usuń ikonę Notki %s ze wszystkich przedmiotów",
    WISHLIST_DIALOG_REMOVE_GEAR_WHOLE_SET         = "Usuń Notkę - cały Zestaw \"<<1>>\"",
    WISHLIST_DIALOG_REMOVE_GEAR_WHOLE_SET_QUESTION= "Czy na pewno chcesz usunąć wszystkie znaczniki Notek z całego Zestawu \"<<1>>\"?",
    WISHLIST_DIALOG_REMOVE_SELECTED_GEAR_WHOLE_SET_QUESTION= "Czy na pewno chcesz usunąć znacznik Notki <<1>> z Zestawu \"<<2>>\"?",
    WISHLIST_DIALOG_REMOVE_GEAR_MARKER_ALL        = "Usunąć znacznik Notki <<1>> ze wszystkich przedmiotów?",
    WISHLIST_DIALOG_REMOVE_GEAR_ALL_QUESTION      = "Czy na pewno usunąć wszystkie znaczniki Notek?",
    WISHLIST_DIALOG_REMOVE_GEAR_MARKER            = "Usuń znacznik Notki",
    WISHLIST_DIALOG_REMOVE_GEAR_MARKER_QUESTION   = "Usuń znacznik Notki <<1>>",

    WISHLIST_GEAR_MARKER_ADDED                   = "Dodano znacznik Notki <<1>> do <<2>>",
    WISHLIST_GEAR_MARKER_REMOVED                 = "Usunięto znacznik Notki <<1>> z <<2>>",
    WISHLIST_GEAR_MARKERS_ADDED                  = "Dodano: <<1[Brak znacznika Notki/1 znacznik Notki/$d znaczników Notek]>>",
    WISHLIST_GEAR_MARKERS_REMOVED                = "Usunięto: <<1[Brak znacznika Notki/1 znacznik Notki/$d znaczników Notek]>>",
}

setmetatable(strings, {__index = WL.stringsEN})
--Register the language constants so other files can use the function "SafeAddString" too
for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end

