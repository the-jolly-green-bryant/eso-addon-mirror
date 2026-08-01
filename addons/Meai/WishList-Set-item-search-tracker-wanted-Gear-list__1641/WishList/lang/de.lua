--Translations by @Baertram

WishList = WishList or {}
local WL = WishList

--German base strings: These need to be seperated from other strings which "use these base strings",
-- so they can be created before the other strings
local stringsBase = {
    WISHLIST_TITLE                      = "Wunschliste",
    WISHLIST_ALL_WISHLISTS              = "[ ALLE Wunschlisten ]",
    WISHLIST_HISTORY_TITLE              = "Historie",

    WISHLIST_HEADER_DATE                = "Datum",
    WISHLIST_HEADER_NAME                = GetString(SI_INVENTORY_SORT_TYPE_NAME),   -- Name
    WISHLIST_HEADER_SLOT                = "Slot",
    WISHLIST_HEADER_TYPE                = GetString(SI_SMITHING_HEADER_ITEM),       -- Type
    WISHLIST_HEADER_TRAIT               = GetString(SI_SMITHING_HEADER_TRAIT),      -- Trait
    WISHLIST_HEADER_CHARS               = GetString(SI_BINDING_NAME_TOGGLE_CHARACTER), -- Character / toon
    WISHLIST_HEADER_USERNAME            = "Benutzer",
    WISHLIST_HEADER_LOCALITY            = "Fundort",
    WISHLIST_HEADER_QUALITY             = GetString(SI_TRADINGHOUSEFEATURECATEGORY5), --Quality
    WISHLIST_HEADER_LAST_ADDED          = "Zuletzt hinzugefügt",

    WISHLIST_CONST_ID                   = "Id",
    WISHLIST_CONST_SET                  = "Set",
    WISHLIST_CONST_BONUS                = "Bonus",
    WISHLIST_CONST_ARMORANDWEAPONTYPE   = "Rüstung / Waffen Typ",
    WISHLIST_CONST_ARMORTYPE            = "Rüstung Typ",
    WISHLIST_CONST_WEAPONTYPE           = "Waffen Typ",
    WISHLIST_CONST_ITEMID               = "Gegenstands Id",

    WISHLIST_DIALOG_ADD_ITEM            = "Gegenstand hinzufügen",
    WISHLIST_BUTTON_REMOVE_HISTORY_TT   = "Historie leeren",

    WISHLIST_ZONE                       = GetString(SI_CHAT_CHANNEL_NAME_ZONE),
    WISHLIST_WAYSHRINES                 = GetString(SI_MAPFILTER8),
    WISHLIST_ARMORTYPE                  = GetString(SI_ITEM_FORMAT_STR_ARMOR) .. " " .. GetString(SI_GUILD_HERALDRY_TYPE_HEADER),
    WISHLIST_DROPLOCATIONS              = "Fundorte",
    WISHLIST_DROPLOCATION_SPECIAL       = "Speziell (z.B. Level Aufstieg, Prophet)",
    WISHLIST_DROPLOCATION_BG            = GetString(SI_LEADERBOARDTYPE4), --Battleground

    WISHLIST_LIBSETS                    = "LibSets",
}
--Add missing translations from language "en" strings table as "fallback" (metatable)
--setmetatable(stringsBase, {__index = WL.stringsBaseEN})
for stringId, stringValue in pairs(stringsBase) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end

--German WishList translations (using already created base strings)
local strings = {
    WISHLIST_SEARCHDROP_START = "Suche nach ",
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
    WISHLIST_SEARCHDROP11      = GetString(WISHLIST_LIBSETS) .. ": Set Typ",
    WISHLIST_SEARCHDROP12      = GetString(WISHLIST_LIBSETS) .. ": " .. GetString(WISHLIST_DLC),
    WISHLIST_SEARCHDROP13      = GetString(WISHLIST_LIBSETS) .. ": Benötigte Eigenschaften",
    WISHLIST_SEARCHDROP14      = GetString(WISHLIST_LIBSETS) .. ": " .. GetString(WISHLIST_ZONE),
    WISHLIST_SEARCHDROP15      = GetString(WISHLIST_LIBSETS) .. ": " .. GetString(WISHLIST_WAYSHRINES),
    WISHLIST_SEARCHDROP16      = GetString(WISHLIST_LIBSETS) .. ": " .. GetString(WISHLIST_DROPLOCATIONS),

    WISHLIST_LOOT_MSG_YOU = "Du findest: ",
    WISHLIST_LOOT_MSG_OTHER = " hat gefunden: ",
    WISHLIST_LOOT_MSG_STANDARD = "[<<2>>] hat \"<<1>>\" gefunden, mit Eigenschaft <<3>>, Qualität <<4>>, Level <<5>>, Set \"<<6>>\"",

    WISHLIST_CONTEXTMENU_FROM        = " von der " .. GetString(WISHLIST_TITLE),
    WISHLIST_CONTEXTMENU_ADD = "Zur " .. GetString(WISHLIST_TITLE) .. " hinzufügen",
    WISHLIST_CONTEXTMENU_REMOVE = "Von " .. GetString(WISHLIST_TITLE) .. " entfernen",
    WISHLIST_CONTEXTMENU_REMOVE_FROM_LAST_ADDED = "Von zuletzt hinzugefügten entfernen",
    WISHLIST_CONTEXTMENU_CLEAR_LAST_ADDED = "Zuletzt hinzugefügte leeren (schließt den aktuellen Dialog!)",
    WISHLIST_CLEAR_LAST_ADDED_TITLE = "Zuletzt hinzugefügt Historie leeren?",
    WISHLIST_CLEAR_LAST_ADDED_TEXT = "Willst du wirklich die zuletzt hinzugefügt Historie komplett leeren?",

    WISHLIST_CONTEXTMENU_SETITEMCOLLECTION_ADD = "Alle Eigenschaften einzeln zur " .. GetString(WISHLIST_TITLE) .. " hinzufügen",
    WISHLIST_CONTEXTMENU_SETITEMCOLLECTION_ADD_1_ITEM = "Alle Eigenschaften als 1 Gegenstand zur " .. GetString(WISHLIST_TITLE) .. " hinzufügen",
    WISHLIST_CONTEXTMENU_SETITEMCOLLECTION_REMOVE = "Alle Eigenschaften von der " .. GetString(WISHLIST_TITLE) .. " entfernen",
    WISHLIST_CONTEXTMENU_SETITEMCOLLECTION_REMOVE_SLOT = "Alle Eigenschaften des Ausrüstungsslot von der " .. GetString(WISHLIST_TITLE) .. " entfernen",

    WISHLIST_ADDED = " zur " .. GetString(WISHLIST_TITLE) .. " hinzugefügt",
    WISHLIST_REMOVED = " von der " .. GetString(WISHLIST_TITLE) .. " entfernt",
    WISHLIST_UPDATED = " <<1>> geändert in " .. GetString(WISHLIST_TITLE),
    WISHLIST_ITEMS_ADDED = "<<1[Kein Gegenstand/1 Gegenstand/$d Gegenstände]>> hinzugefügt zur " .. GetString(WISHLIST_TITLE),
    WISHLIST_ITEMS_REMOVED = "<<1[Kein Gegenstand/1 Gegenstand/$d Gegenstände]>> entfernt von der " .. GetString(WISHLIST_TITLE),
    WISHLIST_ITEMS_UPDATED = "<<1[Kein Gegenstand/1 Gegenstand/$d Gegenstände]>> geändert in der " .. GetString(WISHLIST_TITLE),

    WISHLIST_HISTORY_ADDED = " zur " .. GetString(WISHLIST_HISTORY_TITLE) .. " hinzugefügt",
    WISHLIST_HISTORY_REMOVED = " von der " .. GetString(WISHLIST_HISTORY_TITLE) .. " entfernt",
    WISHLIST_HISTORY_ITEMS_ADDED = "<<1[Kein Eintrag/1 Eintrag/$d Einträge]>> hinzugefügt zur " .. GetString(WISHLIST_HISTORY_TITLE),
    WISHLIST_HISTORY_ITEMS_REMOVED = "<<1[Kein Eintrag/1 Eintrag/$d Einträge]>> entfernt von der " .. GetString(WISHLIST_HISTORY_TITLE),

    WISHLIST_ITEMTRAITTYPE_SPECIAL = "Spezial",

    WISHLIST_DIALOG_ADD_WHOLE_SET_TT = "Alle Gegenstände des aktuell gewählten Sets, mit gewählter Eigenschaft, zu deiner " .. GetString(WISHLIST_TITLE) .. " hinzufügen",
    WISHLIST_DIALOG_ADD_ALL_TYPE_OF_SET_TT = "Alle Gegenstände des aktuell gewählten Sets, mit ausgewählter Art (<<1>>) und gewählter Eigenschaft, zu deiner " .. GetString(WISHLIST_TITLE) .. " hinzufügen",
    WISHLIST_DIALOG_ADD_ALL_TYPE_TYPE_OF_SET_TT = "Alle Gegenstände des aktuell gewählten Sets, mit ausgewählter Art (<<1>>) sowie ausgewähltem Gegenstand (<<2>>) und gewählter Eigenschaft, zu deiner " .. GetString(WISHLIST_TITLE) .. " hinzufügen",
    WISHLIST_DIALOG_ADD_ANY_TRAIT = "Jede Eigenschaft",
    WISHLIST_NO_ITEMS_ADDED_WITH_SELECTED_DATA = "Keine passenden Gegenstände gefunden -> Es wurde nichts zu der " .. GetString(WISHLIST_TITLE) .. " hinzugefügt",
    WISHLIST_DIALOG_ADD_ONE_HANDED_WEAPONS_OF_SET_TT = "Alle 1-händigen Waffen des aktuell gewählten Sets, mit gewählter Eigenschaft, zu deiner " .. GetString(WISHLIST_TITLE) .. " hinzufügen",
    WISHLIST_DIALOG_ADD_TWO_HANDED_WEAPONS_OF_SET_TT = "Alle 2-händigen Waffen des aktuell gewählten Sets, mit gewählter Eigenschaft, zu deiner " .. GetString(WISHLIST_TITLE) .. " hinzufügen",
    WISHLIST_DIALOG_ADD_BODY_PARTS_ARMOR_OF_SET_TT = "Alle Körper Rüstungsteile des aktuell gewählten Sets, mit gewählter Eigenschaft, zu deiner " .. GetString(WISHLIST_TITLE) .. " hinzufügen",
    WISHLIST_DIALOG_ADD_MONSTER_SET_PARTS_ARMOR_OF_SET_TT = "Schulter und Kopf Rüstungsteile des aktuell gewählten Sets, mit gewählter Eigenschaft, zu deiner " .. GetString(WISHLIST_TITLE) .. " hinzufügen",

    WISHLIST_DIALOG_REMOVE_ITEM = "Gegenstand entfernen",
    WISHLIST_DIALOG_REMOVE_ITEM_QUESTION = "Entferne <<1>>?",
    WISHLIST_DIALOG_REMOVE_ITEM_DATETIME = "Entferne Gegenstände mit Datum & Uhrzeit \"<<1>>\"",
    WISHLIST_DIALOG_REMOVE_ITEM_TYPE = "Entferne Gegenstände mit Item Typ \"<<1>>\"",
    WISHLIST_DIALOG_REMOVE_ITEM_ARMORORWEAPONTYPE = "Entferne Gegenstände mit Typ \"<<1>>\"",
    WISHLIST_DIALOG_REMOVE_ITEM_TYPE_ARMORORWEAPONTYPE_SLOT = "Entferne Gegenstände mit Item Typ \"<<1>>\", Typ \"<<2>>\", Slot \"<<3>>\"",
    WISHLIST_DIALOG_REMOVE_ITEM_SLOT = "Entferne Gegenstände mit Slot \"<<1>>\"",
    WISHLIST_DIALOG_REMOVE_ITEM_TRAIT = "Entferne Gegenstände mit Eigenschaft \"<<1>>\"",
    WISHLIST_DIALOG_REMOVE_ITEM_KNOWN_SETITEMCOLLECTION_OF_SET = "Entferne bekannte Set Sammlungs-Gegenst. des Sets \"<<1>>\"",
    WISHLIST_DIALOG_REMOVE_ITEM_KNOWN_SETITEMCOLLECTION = "Entferne alle bekannten Set Sammlungs-Gegenstände",
    WISHLIST_CONTEXTMENU_ADD_ITEM_UNKNOWN_SETITEMCOLLECTION_OF_SET = "Unbekannte Gegenst. des Sets \"<<1>>\" zur " .. GetString(WISHLIST_TITLE) .. " hinzufügen",
    WISHLIST_CONTEXTMENU_REMOVE_ITEM_KNOWN_SETITEMCOLLECTION_OF_SET = "Bekannte Gegenst. des Sets \"<<1>>\" von der " .. GetString(WISHLIST_TITLE) .. " entfernen",
    WISHLIST_CONTEXTMENU_REMOVE_ITEM_KNOWN_SETITEMCOLLECTION = "Alle bekannten Set Gegenstände von der " ..GetString(WISHLIST_TITLE) .. " entfernen",
    WISHLIST_CONTEXTMENU_REMOVE_ITEM_KNOWN_SETITEMCOLLECTION_OF_SET_ALL_WISHLISTS = "Bekannte Gegenst. des Sets \"<<1>>\" von ALLEN WunschListen entfernen",
    WISHLIST_CONTEXTMENU_REMOVE_ITEM_KNOWN_SETITEMCOLLECTION_ALL_WISHLISTS = "Alle bekannten Set Gegenstände von ALLEN WunschListen entfernen",


    WISHLIST_BUTTON_REMOVE_ALL_TT = "Entferne alle Gegenstände des ausgewählten Charakters von deiner " .. GetString(WISHLIST_TITLE),
    WISHLIST_DIALOG_REMOVE_ALL_ITEMS_QUESTION = "Wirklich alle Gegenstände entfernen?",
    WISHLIST_DIALOG_REMOVE_WHOLE_SET = "Entferne gesamtes Set \"<<1>>\"",
    WISHLIST_DIALOG_REMOVE_WHOLE_SET_QUESTION = "Wirklich das gesamte Set \"<<1>>\" entfernen?",
    WISHLIST_BUTTON_CLEAR_HISTORY_TT = GetString(WISHLIST_BUTTON_REMOVE_HISTORY_TT) .. "?",
    WISHLIST_DIALOG_CLEAR_HISTORY_QUESTION = GetString(WISHLIST_HISTORY_TITLE) .. " für ausgewählten Charakter leeren?",
    WISHLIST_DIALOG_CHANGE_QUALITY = GetString(SI_TRADINGHOUSEFEATURECATEGORY5) .." ändern",
    WISHLIST_DIALOG_CHANGE_QUALITY_WHOLE_SET = GetString(SI_TRADINGHOUSEFEATURECATEGORY5) .." des gesamten Sets ändern",
    WISHLIST_DIALOG_CHANGE_QUALITY_QUESTION     = "<<1>> ändern?",
    WISHLIST_DIALOG_CHANGE_QUALITY_WHOLE_SET_QUESTION   = "Wirklich alle Gegenstände vom Set <<1>> ändern?",

    WISHLIST_DIALOG_RELOAD_ITEMS = "Gegenstände neu laden",
    WISHLIST_DIALOG_RELOAD_ITEMS_QUESTION = "Dies wird alle Set Gegenstände über die Bibliothek\n\"LibSets\" neu einlesen!\nDies sollte nicht länger als 5 Sekunden benötigen.",
    WISHLIST_LINK_ITEM_TO_CHAT = GetString(SI_ITEM_ACTION_LINK_TO_CHAT),
    WISHLIST_WHISPER_RECEIVER = "\"<<C:1>>\" anflüstern und nach <<2>> fragen",
    WISHLIST_WHISPER_RECEIVER_QUESTION = "Hallo <<1>>, du hast diesen Gegenstand gefunden: <<2>>. Ich suche danach und wollte dich fragen, ob du mir diesen gibst? Danke sehr.",


    WISHLIST_BUTTON_COPY_WISHLIST_TT = "Kopiere " .. GetString(WISHLIST_TITLE),
    WISHLIST_BUTTON_CHOOSE_CHARACTER_TT = "Wähle Charakter",
    WISHLIST_BUTTON_CHOOSE_CHARACTER_QUESTION_ADD_ITEM = GetString(WISHLIST_DIALOG_ADD_ITEM) .. " <<1>>:",
    WISHLIST_BUTTON_CHOOSE_CHARACTER_QUESTION_ADD_ITEM_AND_MORE = GetString(WISHLIST_DIALOG_ADD_ITEM) .. " <<1>> und <<2>> weitere:",
    WISHLIST_BUTTON_CHOOSE_CHARACTER_QUESTION_COPY_WL = GetString(WISHLIST_TITLE) .. " von <<1>> kopieren nach:",
    WISHLIST_ITEM_COPIED = "<<1>> von <<2>> nach <<3>> kopiert",
    WISHLIST_NO_ITEMS_COPIED = "Keine Gegenstände kopiert. Vielleicht sind bereits alle auf der Ziel " .. GetString(WISHLIST_TITLE),

    WISHLIST_SETS_LOADED = "<<1[Kein Set/1 Set/$d Sets]>> geladen",
    WISHLIST_NO_SETS_LOADED = "Keine Sets geladen. Klicke den Knopf, um alle Sets zu laden.\nDies kann bis zu einigen Minuten dauern und den Spiel Client stark auslasten!",
    WISHLIST_LOAD_SETS = "Lade Sets",
    WISHLIST_LOADING_SETS = "Lese Set Gegenstände ein...",
    WISHLIST_TOTAL_SETS = "Sets insgesamt: ",
    WISHLIST_TOTAL_SETS_ITEMS = "Set Gegenstände: ",
    WISHLIST_SETS_FOUND = "<<1>> Sets gefunden, mit <<2>> Gegenständen",

    WISHLIST_ITEM_QUALITY_ALL   = "Jede " .. GetString(SI_TRADINGHOUSEFEATURECATEGORY5),
    WISHLIST_ITEM_QUALITY_MAGIC_OR_ARCANE           = GetString(SI_ITEMQUALITY2) .. ", " .. GetString(SI_ITEMQUALITY3), 		--Magic or arcane
    WISHLIST_ITEM_QUALITY_ARCANE_OR_ARTIFACT        = GetString(SI_ITEMQUALITY3) .. ", " .. GetString(SI_ITEMQUALITY4), 		--Arcane or artifact
    WISHLIST_ITEM_QUALITY_ARTIFACT_OR_LEGENDARY     = GetString(SI_ITEMQUALITY4) .. ", " .. GetString(SI_ITEMQUALITY5), 	    --Artifact or legendary
    WISHLIST_ITEM_QUALITY_MAGIC_TO_LEGENDARY        = GetString(SI_ITEMQUALITY2) .. " -> " .. GetString(SI_ITEMQUALITY5), 		--Magic to legendary
    WISHLIST_ITEM_QUALITY_ARCANE_TO_LEGENDARY       = GetString(SI_ITEMQUALITY3) .. " -> " .. GetString(SI_ITEMQUALITY5), 		--Arcane to legendary

    --Tooltips
    WISHLIST_BUTTON_RELOAD_TT = "Alle Sets neu einlesen",
    WISHLIST_BUTTON_SEARCH_TT = "Set & Gegenstand Suche",
    WISHLIST_BUTTON_WISHLIST_TT = "Deine " .. GetString(WISHLIST_TITLE),
    WISHLIST_BUTTON_HISTORY_TT = GetString(WISHLIST_HISTORY_TITLE),
    WISHLIST_BUTTON_SETTINGS_TT = GetString(WISHLIST_TITLE) .. " Einstellungen",
    WISHLIST_BUTTON_SET_ITEM_COLLECTION_TT   = "Zeige Set Gegenstands Sammlung",
    WISHLIST_CHARDROPDOWN_ITEMCOUNT_WISHLIST = "[<<C:1>>]\n<<2[Keine Gegenstände/1 Gegenstand/$d Gegenstände]>> auf der " .. GetString(WISHLIST_TITLE),
    WISHLIST_CHARDROPDOWN_ITEMCOUNT_HISTORY = "[<<C:1>>]\n<<2[Keine Einträge/1 Eintrag/$d Einträge]>> in der " .. GetString(WISHLIST_HISTORY_TITLE),

    --Keybindings
    SI_BINDING_NAME_WISHLIST_SHOW = "Zeige/Verstecke " .. GetString(WISHLIST_TITLE),
    SI_BINDING_NAME_WISHLIST_ADD_OR_REMOVE = "Hinzufügen/Entfernen zu/aus " .. GetString(WISHLIST_TITLE),
    SI_BINDING_NAME_WISHLIST_SHOW_ITEM_SET_COLLECTION_CURRENT_ZONE  = "Zeige aktuelle Zone in Sets Sammlungen",
    SI_BINDING_NAME_WISHLIST_SHOW_ITEM_SET_COLLECTION_CURRENT_PARENT_ZONE  = "Zeige aktuelle Übergeordnete Zone in Sets Sammlungen",
    WISHLIST_SHOW_ITEM_SET_COLLECTION_MORE_OPTIONS = "Mehr Optionen",

    -- LAM addon settings
    WISHLIST_WARNING_RELOADUI = "Achtung:\nBeim Verändern dieser Option wird automatisch die Benutzeroberfläche neu geladen!",
    WISHLIST_LAM_ADDON_DESC = GetString(WISHLIST_TITLE) .. " - Deine Liste mit gesuchten Set Gegenständen",
    WISHLIST_LAM_SAVEDVARIABLES = "Sichern der Einstellungen",
    WISHLIST_LAM_SV = "Speicher Art",
    WISHLIST_LAM_SV_TT = "Wähle aus, ob du die Einstellungen für den ganzen Account gleich speichern möchtest, oder für jeden deiner Charaktere einzeln.\n\nDies betrifft nicht deine Wunschliste! Dort kannst du jeden deiner Charaktere auswählen und die Liste bearbeiten.",
    WISHLIST_LAM_SV_ACCOUNT_WIDE = "Account weit",
    WISHLIST_LAM_SV_EACH_CHAR = "Jeder Charakter einzeln",
    WISHLIST_LAM_USE_24h_FORMAT = "Nutze 24h Zeit Format",
    WISHLIST_LAM_USE_24h_FORMAT_TT = "Nutze das 24 Stunden Format für die Darstellung von Datum und Uhrzeit Angaben",
    WISHLIST_LAM_USE_CUSTOM_DATETIME_FORMAT = "Eigenes Datum & Zeit Format",
    WISHLIST_LAM_USE_CUSTOM_DATETIME_FORMAT_TT = "Spezifiziere dein eigenes Datum & Zeit Format.\nLAsse das Editfeld leer, um das Standard Format zu verwenden.\nDie möglichen Platzhalter sind in der lua Sprache bereits vordefiniert wie folgt:\n\n%a	abbreviated weekday name (e.g., Wed)\n%A	full weekday name (e.g., Wednesday)\n%b	abbreviated month name (e.g., Sep)\n%B	full month name (e.g., September)\n%c	date and time (e.g., 09/16/98 23:48:10)\n%d	day of the month (16) [01-31]\n%H	hour, using a 24-hour clock (23) [00-23]\n%I	hour, using a 12-hour clock (11) [01-12]\n%M	minute (48) [00-59]\n%m	month (09) [01-12]\n%p	either \"am\" or \"pm\" (pm)\n%S	second (10) [00-61]\n%w	weekday (3) [0-6 = Sunday-Saturday]\n%x	date (e.g., 09/16/98)\n%X	time (e.g., 23:48:10)\n%Y	full year (1998)\n%y	two-digit year (98) [00-99]\n%%	the character `%´",

    WISHLIST_LAM_SCAN = "Scan",
    WISHLIST_LAM_SCAN_ALL_CHARS = "Jeden Charakter prüfen",
    WISHLIST_LAM_SCAN_ALL_CHARS_TT = "Überprüft die Wunschlisten aller deiner Charaktere, wenn du einen Gegenstand lootest, oder prüfe nur den aktuellen Charakter",

    WISHLIST_LAM_ADD_ITEM = "Hinzufügen zur " .. GetString(WISHLIST_TITLE),
    WISHLIST_LAM_PRESELECT_CHAR_ON_ITEM_ADD = "Aktuellen Charakter als Standard",
    WISHLIST_LAM_PRESELECT_CHAR_ON_ITEM_ADD_TT = "Benutzt den aktuell gespielten Charakter als Vorbelegung für die Charakter Auswahl Liste im Gegenstand hinzufügen Popup, oder benutze den auf dem Wunschliste Tab ausgewählten Charakter?",

    WISHLIST_LAM_ADD_MAIN_MENU_BUTTON = "Hauptmenü Knopf zum Anzeigen",
    WISHLIST_LAM_ADD_MAIN_MENU_BUTTON_TT = "Zeige einen Knopf im Hauptmenü an, um die " .. GetString(WISHLIST_TITLE) .. " anzuzeigen",

    WISHLIST_LAM_SORT = "Sortierung",
    WISHLIST_LAM_SORT_USE_TIEBRAKER     = "Sortierung bildet Gruppe",
    WISHLIST_LAM_SORT_USE_TIEBRAKER_TT  = "Beim Sortieren der Listen werden nach der normal selektierten Sortierspalte auch zusätzlich Gruppen gebildet, welche die sortierten Gegenstände dann mit der hier ausgewählten 2. Spalte gruppiert.",
    WISHLIST_LAM_SORT_USE_TIEBRAKER_NONE= "Keine Gruppierung!",


    WISHLIST_LAM_FCOIS_MARK_ITEM_AUTO = "Markiere gelooteten Gegenstand",
    WISHLIST_LAM_FCOIS_MARK_ITEM_AUTO_TT = "Markiert einen gelooteten Set Gegenstand von deiner Wunschliste mit diesem FCO ItemSaver Markierungssymbol",
    WISHLIST_LAM_FCOIS_MARKER_ICONS_PER_CHAR         = "FCOItemSaver - Markierungssymbol je Charakter Wunschliste",
    WISHLIST_LAM_FCOIS_MARK_ITEM_AUTO_PER_CHAR       = "Mark. gelooteten Gegenstand indiv. je Charakter",
    WISHLIST_LAM_FCOIS_MARK_ITEM_AUTO_PER_CHAR_TT    = "Markiert einen gelooteten Set Gegenstand von der Wunschliste eines deiner Charaktere mit einem FCO ItemSaver Markierungssymbol.\nJeder Charakter kann für seine Wunschliste ein eigenes Symbol nutzen.",
    WISHLIST_LAM_FCOIS_MARK_ITEM_CHARAKTER_NAME      = "Charakter Name",
    WISHLIST_LAM_FCOIS_MARK_ITEM_ICON                = "Markierungssymbol",

    WISHLIST_LAM_ITEM_FOUND = "Gefundene Gegenstände auf der " .. GetString(WISHLIST_TITLE),
    WISHLIST_LAM_ITEM_FOUND_USE_CHARACTERNAME = "Charakter oder Account Name",
    WISHLIST_LAM_ITEM_FOUND_USE_CHARACTERNAME_TT = "Aktiviert: Zeige den Charakter Namen an, welcher einen Gegenstand von deiner " .. GetString(WISHLIST_TITLE) .. " gelooted hat.\nDeaktiviert: Zeige den Accountnamen an, welcher einen Gegenstand von deiner " .. GetString(WISHLIST_TITLE) .. " gelooted hat.",
    WISHLIST_LAM_ITEM_FOUND_USE_CSA = "Zeige auch Bildschirm Nachricht",
    WISHLIST_LAM_ITEM_FOUND_USE_CSA_TT = "Zeige die Loot Benachrichtigung, zusätzlich zum Chat Text, auch als Bildschirm Nachricht an.",
    WISHLIST_LAM_ITEM_FOUND_TEXT = "Nachrichtentext beim Looten",
    WISHLIST_LAM_ITEM_FOUND_TEXT_TT = "Spezifiziere den Nachrichtentext, welcher beim Looten eines Gegenstandes von deiner " .. GetString(WISHLIST_TITLE) .. " im Chat, und falls aktiviert auch in der Bildschirmnachricht, angezeigt werden soll.\nLasse das Editfeld leer um eine Standard Loot Nachricht anzuzeigen.\n\nDu kannst die folgenden Platzhalter in dem Text verwenden, welche dann mit den Daten aus dem gelooteten Gegenstand ersetzt werden:\n<<1>>    Name (Link)\n<<2>>  Gelooted von\n<<3>>   Eigenschaft\n<<4>>  Qualität\n<<5>>  Level\n<<6>>  Set Name",
    WISHLIST_LAM_ITEM_FOUND_WHISPER_TEXT            = "Flüster Nachricht: 'Nach Gegenstand fragen'",
    WISHLIST_LAM_ITEM_FOUND_WHISPER_TEXT_TT         = "Dieser Text wird als Flüster Nachricht an den Benutzer gesendet, welchen du per WunschListe Historie nach einem Gegenstand fragst.\nDie folgenden Platzhalter kannst du verwenden:\n<<1>>   Der Name des Benutzers, welcher den Gegenstand gelootet hat.\n<<2>>Der Gegenstand Name + Link",
    WISHLIST_LAM_ITEM_FOUND_SHOW_HISTORY_CHAT_OUTPUT =      "Chat Ausgabe von neuen Historien Einträgen",
    WISHLIST_LAM_ITEM_FOUND_SHOW_HISTORY_CHAT_OUTPUT_TT =   "Zeige die Chat Ausgabe für neue Historien Einträge an, wenn etwas gelooted wird.",

    WISHLIST_LAM_FORMAT_OPTIONS                     = "Ausgabe Format",
    WISHLIST_LAM_SETNAME_LANGUAGES                  = "Set Name Sprache",
    WISHLIST_LAM_SETNAME_LANGUAGES_TT               = "Aktiviere die Set Name Sprachen welche in der " .. GetString(WISHLIST_TITLE) .. " (mit einem / Zeichen getrennt) angezeigt werden sollen. Die aktuelle Spiel Sprache wird zuerst angezeigt (Wenn unterstützt. Ansonsten wird English zuerst angezeigt).",

    WISHLIST_LAM_ITEM_FOUND_ONLY_MAX_CP             = "Nur mit Level = Max. CP" ..tostring(GetChampionPointsPlayerProgressionCap()),
    WISHLIST_LAM_ITEM_FOUND_ONLY_MAX_CP_TT          = "Nur benachrichtigen, wenn der Gegenstandslevel der aktuell höchste ChampionPunkte Rang CP" ..tostring(GetChampionPointsPlayerProgressionCap()) .. " ist.",
    WISHLIST_LAM_ITEM_FOUND_ONLY_IN_DUNGEONS        = "Nur in Verliesen",
    WISHLIST_LAM_ITEM_FOUND_ONLY_IN_DUNGEONS_TT     = "Nur benachrichtigen, wenn du dich aktuell in einem Verlies befindest.",

    WISHLIST_SORTHEADER_GROUP_CHANGED               = "[" .. GetString(WISHLIST_TITLE) .. "]Sortier Gruppe geändert zu: %s",

    WISHLIST_SV_MIGRATION_TO_SERVER_START       = "[WishList]SavedVariables -> Migriere nun zu Server abhängigen Daten.",
    WISHLIST_SV_MIGRATION_STILL_OLD_DATA_FOUND  = "[WishList]ALTE nicht-Server abhängige WishList SavedVariables existieren noch -> Entferne diese nun",
    WISHLIST_SV_MIGRATION_TO_SERVER_SUCCESSFULL = "[WishList]SavedVariables wurden erfolgreich zu Server abhängigen migriert, am: %s!",
    WISHLIST_SV_MIGRATION_TO_SERVER_FAILED      = "[WishList]SavedVariables wurden NICHT migriert. Du nutzt immer noch die nicht-Server abhängigen!",
    WISHLIST_SV_MIGRATION_RELOADUI              = "[WishList]Benutzeroberfläche wird nun neu geladen. Grund: WishList SavedVariables Migration!",
    WISHLIST_SV_MIGRATION_TO_SERVER_FINISHED    = "[WishList]Migration der SavedVariables vom Account \'%s\' zum Server \'%s\' abgeschlossen!",
    WISHLIST_SV_MIGRATED_TO_SERVER              = "[|c00FF00WishList|r]SavedVariables wurden zum Server migriert!",

    WISHLIST_LAM_ONLY_CURRENT_CHAR              = "Nur aktueller Charakter",
    WISHLIST_LAM_ONLY_CURRENT_CHAR_TT           = "Tue dies nur für den aktuell eingeloggten Charakter",
    WISHLIST_LAM_NOT_ANY_TRAIT                  = "Nicht \'Jede\' Eigenschaft",
    WISHLIST_LAM_NOT_ANY_TRAIT_TT               = "Tue dies nicht wenn die Eigenschaft des Gegenstandes auf deiner " .. GetString(WISHLIST_TITLE) .. " mit \'Jede\' eingestellt ist",

    WISHLIST_LAM_ITEM_FOUND_AUTO_REMOVE_HEADER  = "Auto-Entfernen von der " .. GetString(WISHLIST_TITLE),
    WISHLIST_LAM_ITEM_FOUND_AUTO_REMOVE         = "Auto-Entfernen gefundenet Gegenstände",
    WISHLIST_LAM_ITEM_FOUND_AUTO_REMOVE_TT      = "Entfernt automatisch Gegenstände von der ".. GetString(WISHLIST_TITLE)..", welche du selber gelootet hast.",


    --Gear
    WISHLIST_LAM_GEAR                           = "Gear Einstellungen",
    WISHLIST_LAM_GEAR_DESC                      = "Erstelle deine eigenen \'Gear\' Symbole und Farben, füge eine Beschreibung und einen Kommentar hinzu.\nDiese Gear Symbole kannst du dann deiner Wunschliste hinzufügen (Kontext Menü).",
    WISHLIST_LAM_GEARS_DROPDOWN                 = "Verfügbares Gear",
    WISHLIST_LAM_GEARS_DROPDOWN_TT              = "Wähle ein erstelltes Gear zum Ändern/Löschen",
    WISHLIST_LAM_GEARS_NAME_EDIT                = "Gear Name",
    WISHLIST_LAM_GEARS_NAME_EDIT_TT             = "Gebe den Gear Namen an. Er wird am Gear Symbol an deiner Wunschliste, im Tooltip, angezeigt",
    WISHLIST_LAM_GEARS_COMMENT_EDIT             = "Gear Kommentar",
    WISHLIST_LAM_GEARS_COMMENT_EDIT_TT          = "Gebe den Gear Kommentar an. Er wird am Gear Symbol an deiner Wunschliste, im Tooltip, angezeigt",

    WISHLIST_LAM_GEARS_BUTTON_ADD               = "Neu",
    WISHLIST_LAM_GEARS_BUTTON_ADD_TT            = "Klicke hier, um ein neues Gear Symbol zu erstellen. Du musst den Namen angeben.\n\nNachdem dein Name eingegeben wurde klicke auf den \'Speichern\' Knopf!.\nWenn du dann Kommentar/Symbol/Farbe anpassen möchtest wähle bitte den neuen Eintrag aus der Liste \'Verfügbares Gear\' aus.",
    WISHLIST_LAM_GEARS_BUTTON_SAVE              = "Speichern",
    WISHLIST_LAM_GEARS_BUTTON_SAVE_TT           = "Klicke hier, um dein neu hinzugefügtes (via Knopf \'Neu\') Gear zu speichern.\nBereits existierendes Gear, welches du in der Aufklapp Box ausgewählt hast, wird automatisch gespeichert, sobald du etwas an der Gear Konfiguration veränderst. Hier muss nicht auf den Speichern Knopf gedrückt werden.",
    WISHLIST_LAM_GEARS_BUTTON_DELETE            = "Löschen",
    WISHLIST_LAM_GEARS_BUTTON_DELETE_TT         = "Lösche das aktuell ausgewählte Gear",
    WISHLIST_LAM_GEARS_BUTTON_DELETE_WARN       = "Willst du das gewählte Gear löschen?\nBereits markierte Gegenstände werden diese Gear Markierung verlieren!",

    WISHLIST_LAM_GEAR_MARKER_ICON               = "Gear Symbol",
    WISHLIST_LAM_GEAR_MARKER_ICON_TT            = "Wähle das Symbol für dein Gear",
    WISHLIST_LAM_GEAR_MARKER_ICON_COLOR         = "Gear Symbol Farbe",
    WISHLIST_LAM_GEAR_MARKER_ICON_COLOR_TT      = "Wähle die Farbe für das Symbol deines Gears",

    WISHLIST_LAM_GEAR_MARKER_ICON_ADD_FCOIS     = "+ FCOIS gear",
    WISHLIST_LAM_GEAR_MARKER_ICON_ADD_FCOIS_TT  = "Deine \'Verfügbaren Gears\' werden um die Gear Symbole vom AddOn FCOItemSaver erweitert, so dass du diese verwenden kannst.\nDies ist NUR eie \'visuelle Kopie\' der FCOIS Gear Markierugen und bringt sonst keine FCOIS Vorteile mit!\n\nDie Markierungen werden immer nur hinzugefügt. Sollten diese bereits vorher hinzugefügt worden sein so werden diese nicht überschrieben. Du musst selber doppelte Symbole in den verfügbaren Gears bereinigen!",
    WISHLIST_LAM_GEAR_MARKER_ICON_ADD_FCOIS_WARN = "Möchtest du die FCOIS Gear Symbole hinzufügen?\nSymbole werden nur hinzugefügt.\nBereits vorhandene werden nicht überschrieben.\nDu musst selber doppelte bereinigen!",

    WISHLIST_GEAR_ASSIGN_ICON                   = "Weise Gear Symbol zu",
    WISHLIST_GEAR_ASSIGN_ICON_SET               = "Weise Gear Symbol dem Set zu",
    WISHLIST_GEAR_ASSIGN_ICON_ALL               = "Weise Gear Symbol allen Gegenständen zu",
    WISHLIST_DIALOG_ADD_GEAR_WHOLE_SET         = "Weise Gear zu - Set \"<<1>>\"",
    WISHLIST_DIALOG_ADD_SELECTED_GEAR_WHOLE_SET_QUESTION= "Wirklich Gear Symbol <<1>> dem Set \"<<2>>\" zuweisen?",
    WISHLIST_DIALOG_ADD_GEAR_MARKER            = "Weise Gear zu",
    WISHLIST_DIALOG_ADD_GEAR_MARKER_QUESTION   = "Weise Gear <<1>> zu",
    WISHLIST_DIALOG_ADD_GEAR_MARKER_ALL        = "Weise Gear <<1>> allen Gegenständen zu",

    WISHLIST_GEAR_REMOVE_ICON                   = "Entferne Gear Symbol %s",
    WISHLIST_GEAR_REMOVE_ICON_FROM_SET          = "Entferne Gear Symbol %s vom Set",
    WISHLIST_GEAR_REMOVE_ALL_ICONS_FROM_SET     = "Entferne alle Gear Symbole vom Set",
    WISHLIST_GEAR_REMOVE_ICON_FROM_ALL          = "Entferne Gear Symbol %s von allen Gegenständen",
    WISHLIST_DIALOG_REMOVE_GEAR_WHOLE_SET         = "Entferne Gear - Set \"<<1>>\"",
    WISHLIST_DIALOG_REMOVE_GEAR_WHOLE_SET_QUESTION= "Wirklich alle Gear Symbol vom Set \"<<1>>\" entfernen?",
    WISHLIST_DIALOG_REMOVE_SELECTED_GEAR_WHOLE_SET_QUESTION= "Wirklich Gear Symbol <<1>> vom Set \"<<2>>\" entfernen?",
    WISHLIST_DIALOG_REMOVE_GEAR_MARKER_ALL        = "Entferne Gear Symbol <<1>> von allen Gegenständen?",
    WISHLIST_DIALOG_REMOVE_GEAR_ALL_QUESTION      = "Wirklich alle Gear Symbole entfernen?",
    WISHLIST_DIALOG_REMOVE_GEAR_MARKER            = "Entferne Gear Symbol",
    WISHLIST_DIALOG_REMOVE_GEAR_MARKER_QUESTION   = "Entferne Gear Symbol <<1>>",

    WISHLIST_GEAR_MARKER_ADDED                   = "Gear Symbol <<1>> wurde <<2>> zugewiesen",
    WISHLIST_GEAR_MARKER_REMOVED                 = "Gear Symbol <<1>> von <<2>> entfernt",
    WISHLIST_GEAR_MARKERS_ADDED                  = "<<1[Kein Gear Symbol/1 Gear Symbol/$d Gear Symbole]>> zugewiesen",
    WISHLIST_GEAR_MARKERS_REMOVED                = "<<1[Kein Gear Symbol/1 Gear Symbol/$d Gear Symbole]>> entfernt",
}

--Add missing translations from language "en" strings table as "fallback" (metatable)
setmetatable(strings, {__index = WL.stringsEN})
--Add the german strings as new version to overwrite the exisitng EN strings
for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end
