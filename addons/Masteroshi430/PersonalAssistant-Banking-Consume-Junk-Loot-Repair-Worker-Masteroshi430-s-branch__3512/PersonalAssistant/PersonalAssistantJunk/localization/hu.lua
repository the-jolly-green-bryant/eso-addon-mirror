-- Translated by: Silent_Gamer / Modded/Completed

local PAC = PersonalAssistant.Constants
local PAJStrings = {
    -- =================================================================================================================
    -- Language specific texts that need to be translated --

    -- =================================================================================================================
    -- == MENU/PANEL TEXTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PAJunk Menü --
    SI_PA_MENU_JUNK_DESCRIPTION = "A PAJunk szemétként jelölheti meg a tárgyakat, ha azok megfelelnek a kiválasztható feltételeknek; kivéve, ha éppen most lettek legyártva vagy levélből érkeztek", 

    -- Normál tárgyak --
    SI_PA_MENU_JUNK_STANDARD_ITEMS_HEADER = "Normál tárgyak", 
    SI_PA_MENU_JUNK_AUTOMARK_ENABLE = "Tárgyak automatikus szemétként való megjelölésének engedélyezése", 
    SI_PA_MENU_JUNK_AUTOMARK_ENABLE_T = "Csak a 'Normál tárgyakra' vonatkozik. Az egyéni szemétszabályokat ez a kapcsoló nem érinti, azokat külön kell inaktiválni, ha már nem kívánod futtatni őket.", 

    SI_PA_MENU_JUNK_TRASH_AUTOMARK = table.concat({"[", GetString("SI_ITEMTYPE", ITEMTYPE_TRASH), "] típusú tárgyak automatikus megjelölése"}), 
    SI_PA_MENU_JUNK_TRASH_AUTOMARK_T = table.concat({"Automatikusan szemétnek jelölje a [", GetString("SI_ITEMTYPE", ITEMTYPE_TRASH), "] típusú tárgyakat?"}), 
    SI_PA_MENU_JUNK_TRASH_EXCLUDE_ITEMS_DESC = table.concat({"NE jelölje szemétnek a [", GetString("SI_ITEMTYPE", ITEMTYPE_TRASH), "] tárgyakat, ha . . ."}), 
    SI_PA_MENU_JUNK_TRASH_EXCLUDE_NIBBLES_AND_BITS = table.concat({"> szükséges a ", PAC.COLOR.YELLOW:Colorize("Nibbles and Bits"), " napi küldetéshez"}), 
    SI_PA_MENU_JUNK_TRASH_EXCLUDE_NIBBLES_AND_BITS_T = table.concat({PAC.COLOR.YELLOW:Colorize("Küldetés helyszíne: "), PAC.COLOR.ORANGE:Colorize("Clockwork City"), "\nHa BE van kapcsolva, a következő szemét tárgyak NEM lesznek szemétnek jelölve:\n[Carapace]\n[Foul Hide]\n[Daedra Husks]"}), 
    SI_PA_MENU_JUNK_TRASH_EXCLUDE_MORSELS_AND_PECKS = table.concat({"> szükséges a ", PAC.COLOR.YELLOW:Colorize("Morsels and Pecks"), " napi küldetéshez"}), 
    SI_PA_MENU_JUNK_TRASH_EXCLUDE_MORSELS_AND_PECKS_T = table.concat({PAC.COLOR.YELLOW:Colorize("Küldetés helyszíne: "), PAC.COLOR.ORANGE:Colorize("Clockwork City"), "\nHa BE van kapcsolva, a következő szemét tárgyak NEM lesznek szemétnek jelölve:\n[Elemental Essence]\n[Supple Roots]\n[Ectoplasm]"}), 

    SI_PA_MENU_JUNK_COLLECTIBLES_AUTOMARK = table.concat({"[", GetString("SI_ITEMSELLINFORMATION", ITEM_SELL_INFORMATION_PRIORITY_SELL), "] típusú tárgyak automatikus megjelölése"}), 
    SI_PA_MENU_JUNK_COLLECTIBLES_AUTOMARK_T = table.concat({"Automatikusan szemétnek jelölje a [", GetString("SI_ITEMSELLINFORMATION", ITEM_SELL_INFORMATION_PRIORITY_SELL), "] jelzővel ellátott tárgyakat?"}), 
    SI_PA_MENU_JUNK_COLLECTIBLES_EXCLUDE_ITEMS_DESC = table.concat({"NE jelölje szemétnek a [", GetString("SI_ITEMSELLINFORMATION", ITEM_SELL_INFORMATION_PRIORITY_SELL), "] tárgyakat, ha . . ."}), 
    SI_PA_MENU_JUNK_COLLECTIBLES_EXCLUDE_RARE_FISH = table.concat({"> [", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_COLLECTIBLE_RARE_FISH), "] szükséges a ", PAC.COLOR.YELLOW:Colorize("Fish Boon Feast"), " napi küldetéshez"}), 
    SI_PA_MENU_JUNK_COLLECTIBLES_EXCLUDE_RARE_FISH_T = table.concat({PAC.COLOR.YELLOW:Colorize("Küldetés ideje: "), PAC.COLOR.ORANGE:Colorize("New Life Festival"), " (téli esemény)\nHa BE van kapcsolva, az összes [", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_COLLECTIBLE_RARE_FISH),"] NEM lesz szemétnek jelölve"}), 

    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_AUTOMARK = table.concat({"[", GetString("SI_ITEMTYPE", ITEMTYPE_TREASURE), "] típusú tárgyak automatikus megjelölése"}), 
    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_AUTOMARK_T = table.concat({"Automatikusan szemétnek jelölje a [", GetString("SI_ITEMTYPE", ITEMTYPE_TREASURE), "] típusú tárgyakat?"}), 
    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_EXCLUDE_ITEMS_DESC = table.concat({"NE semmisítse meg vagy jelölje szemétnek a [", GetString("SI_ITEMTYPE", ITEMTYPE_TREASURE), "] tárgyakat, ha . . ."}), 
    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_EXCLUDE_A_MATTER_OF_LEISURE = table.concat({"> szükséges a ", PAC.COLOR.YELLOW:Colorize("A Matter of Leisure"), " napi küldetéshez"}), 
    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_EXCLUDE_A_MATTER_OF_LEISURE_T = table.concat({PAC.COLOR.YELLOW:Colorize("Küldetés helyszíne: "), PAC.COLOR.ORANGE:Colorize("Clockwork City"), "\nHa BE van kapcsolva, a következő kincsek NEM lesznek szemétnek jelölve:\n[Children's Toys]\n[Dolls]\n[Games]"}), 
    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_EXCLUDE_A_MATTER_OF_RESPECT = table.concat({"> szükséges a ", PAC.COLOR.YELLOW:Colorize("A Matter of Respect"), " napi küldetéshez"}), 
    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_EXCLUDE_A_MATTER_OF_RESPECT_T = table.concat({PAC.COLOR.YELLOW:Colorize("Küldetés helyszíne: "), PAC.COLOR.ORANGE:Colorize("Clockwork City"), "\nHa BE van kapcsolva, a következő kincsek NEM lesznek szemétnek jelölve:\n[Utensils]\n[Drinkware]\n[Dishes and Cookware]"}), 
    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_EXCLUDE_A_MATTER_OF_TRIBUTES = table.concat({"> szükséges a ", PAC.COLOR.YELLOW:Colorize("A Matter of Tributes"), " napi küldetéshez"}), 
    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_EXCLUDE_A_MATTER_OF_TRIBUTES_T = table.concat({PAC.COLOR.YELLOW:Colorize("Küldetés helyszíne: "), PAC.COLOR.ORANGE:Colorize("Clockwork City"), "\nHa BE van kapcsolva, a következő kincsek NEM lesznek szemétnek jelölve:\n[Cosmetics]\n[Grooming Items]"}), 
    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_EXCLUDE_THE_COVETOUS_COUNTESS = table.concat({"> szükséges a ", PAC.COLOR.YELLOW:Colorize("The Covetous Countess"), " napi küldetéshez"}), 
    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_EXCLUDE_THE_COVETOUS_COUNTESS_T = table.concat({PAC.COLOR.YELLOW:Colorize("Küldetésadó: "), PAC.COLOR.ORANGE:Colorize("Thieves Guild"), "\nHa BE van kapcsolva, a következő kincsek NEM lesznek szemétnek jelölve:\n[Cosmetics]\n[Dry Goods (Linens)]\n[Wardrobe Accessories]\n\n[Drinkware]\n[Utensils]\n[Dishes and Cookware]\n\n[Games]\n[Dolls]\n[Statues]\n\n[Writings] & [Scrivener Supplies]\n[Maps]\n\n[Ritual Objects]\n[Oddities]"}), 
    
    -- Stolen Items --
    SI_PA_MENU_JUNK_AUTOMARK_STOLEN_HEADER = "Lopott tárgyak", 
    SI_PA_MENU_JUNK_ACTION_STOLEN_PLACEHOLDER = "Lopott [%s] automatikus megjelölése", 

    -- Egyedi tárgyak --
    SI_PA_MENU_JUNK_CUSTOM_ITEMS_HEADER = "Egyedi tárgyak", 
    SI_PA_MENU_JUNK_CUSTOM_ITEMS_DESCRIPTION = table.concat({GetString(SI_PA_MENU_RULES_HOW_TO_ADD_PAJ), "\n\n", GetString(SI_PA_MENU_RULES_HOW_TO_FIND_MENU)}), 

    -- Küldetés tárgyak --
    SI_PA_MENU_JUNK_QUEST_ITEMS_HEADER = "Küldetés tárgyak védelme", 
    SI_PA_MENU_JUNK_QUEST_CLOCKWORK_CITY_HEADER = "Clockwork City", 
    SI_PA_MENU_JUNK_QUEST_THIEVES_GUILD_HEADER = "Tolvajcéh (Thieves Guild)", 
    SI_PA_MENU_JUNK_QUEST_NEW_LIFE_FESTIVAL_HEADER = "New Life Festival", 

    -- Automatikus eladás --
    SI_PA_MENU_JUNK_AUTO_SELL_JUNK_HEADER = "Szemét automatikus eladása", 
    
    -- Automatikus tisztára mosás --
    SI_PA_MENU_JUNK_AUTO_LAUNDER_HEADER = "Automatikus tisztára mosás", 
    SI_PA_MENU_JUNK_AUTO_LAUNDER = "Automatikus tisztára mosás orgazdánál?", 
    SI_PA_MENU_JUNK_AUTO_LAUNDER_LOCKPICKS = "Zárnyitók (Lockpicks) tisztára mosása?", 
    SI_PA_MENU_JUNK_AUTO_LAUNDER_INGREDIENTS = "Főzőalapanyagok tisztára mosása?", 
    SI_PA_MENU_JUNK_AUTO_LAUNDER_MATERIALS = "Alapanyagok és nyersanyagok tisztára mosása?", 
    SI_PA_MENU_JUNK_AUTO_LAUNDER_CRAFTING_BOOSTERS = "Kézműves fejlesztők tisztára mosása?", 
    SI_PA_MENU_JUNK_AUTO_LAUNDER_ENCHANTING_RUNES = "Bűvölő rúnák tisztára mosása?", 
    SI_PA_MENU_JUNK_AUTO_LAUNDER_GLYPHS = "Glifek tisztára mosása?", 
    SI_PA_MENU_JUNK_AUTO_LAUNDER_FURNISHING = "Bútorok tisztára mosása?", 
    SI_PA_MENU_JUNK_AUTO_LAUNDER_SOULGEMS = "Lélekkövek tisztára mosása?", 
    SI_PA_MENU_JUNK_AUTO_LAUNDER_TREASURES = "Kincsek tisztára mosása?", 
    SI_PA_MENU_JUNK_AUTO_LAUNDER_TREASURE_MAPS = "Kincses térképek tisztára mosása?", 
    SI_PA_MENU_JUNK_AUTO_LAUNDER_RECIPES = "Receptek és bútor tervek tisztára mosása?", 
    SI_PA_MENU_JUNK_AUTO_LAUNDER_MOTIFS = "Motívumok tisztára mosása?", 
    SI_PA_MENU_JUNK_AUTO_LAUNDER_EDICTS = "Edict-ek tisztára mosása?", 
    SI_PA_MENU_JUNK_AUTO_LAUNDER_CONTAINERS = "Tárolók tisztára mosása?", 
    SI_PA_MENU_JUNK_AUTO_LAUNDER_REPAIR_KITS = "Javítókészletek tisztára mosása?",

    -- Automatikus megsemmisítés --
    SI_PA_MENU_JUNK_AUTO_DESTROY_JUNK_HEADER = "Szemét automatikus megsemmisítése", 
    SI_PA_MENU_JUNK_AUTO_DESTROY_JUNK = "Szemét tárgyak automatikus megsemmisítésének engedélyezése", 
    SI_PA_MENU_JUNK_AUTO_DESTROY_JUNK_T = "Amikor olyan tárgyat zsákmányolsz, amely automatikusan szemétnek lenne jelölve, és a (kereskedői) eladási értéke és minősége az adott küszöbértéken vagy az alatt van, akkor ezzel a beállítással a tárgy megsemmisül. Ez nem vonható vissza!", 
    SI_PA_MENU_JUNK_AUTO_DESTROY_JUNK_W = "FIGYELEM: Kérlek vedd figyelembe, hogy ezzel a beállítással NINCS megerősítő kérdés, hogy a tárgy valóban megsemmisíthető-e.\nEgyszerűen megsemmisül!\nÖrökre!\nSaját felelősségre használd!", 

    SI_PA_MENU_JUNK_AUTO_DESTROY_JUNK_JUNK_HEADER = "Szemét", 
    SI_PA_MENU_JUNK_AUTO_DESTROY_JUNK_MAX_VALUE_THRESHOLD = "HA a kereskedői eladási érték az alábbi értéken vagy az alatt van", 
    SI_PA_MENU_JUNK_AUTO_DESTROY_JUNK_MAX_VALUE_THRESHOLD_T = "Csak akkor semmisítsd meg automatikusan a tárgyakat, ha a kereskedői eladási értékük ezen a küszöbön van vagy az alatt. Ha egy tárgy megsemmisült, az nem állítható helyre!", 
    SI_PA_MENU_JUNK_AUTO_DESTROY_JUNK_MAX_QUALITY_THRESHOLD = "ÉS a tárgy minősége az alábbi szinten vagy az alatt van", 
    SI_PA_MENU_JUNK_AUTO_DESTROY_JUNK_MAX_QUALITY_THRESHOLD_T = "Csak akkor semmisítsd meg automatikusan a tárgyakat, ha a minőségi szintjük ezen a küszöbön van vagy az alatt. Ha egy tárgy megsemmisült, az nem állítható helyre!", 
    SI_PA_MENU_JUNK_AUTO_DESTROY_JUNK_EXCLUSION_DISCLAIMER = "Kivétel: Semmilyen 'ismeretlen' tárgy (receptek, motívumok, stílusoldalak, tulajdonságok, ...) nem lesz automatikusan megsemmisítve, még akkor sem, ha megfelel az eladási érték és minőségi kritériumoknak", 

    SI_PA_MENU_JUNK_AUTO_DESTROY_STOLEN_JUNK_JUNK_HEADER = "Lopott szemét", 
    SI_PA_MENU_JUNK_AUTO_DESTROY_STOLEN_JUNK = "Lopott szemét tárgyak automatikus megsemmisítésének engedélyezése", 
    SI_PA_MENU_JUNK_AUTO_DESTROY_STOLEN_JUNK_T = "Amikor olyan tárgyat lopsz, amely automatikusan szemétnek lenne jelölve, és az (orgazdai) eladási értéke és minősége az adott küszöbértéken vagy az alatt van, akkor ezzel a beállítással a tárgy megsemmisül. Ez nem vonható vissza!", 
    SI_PA_MENU_JUNK_AUTO_DESTROY_STOLEN_JUNK_MAX_VALUE_THRESHOLD = "HA az orgazdai eladási ár az alábbi értéken vagy az alatt van", 
    SI_PA_MENU_JUNK_AUTO_DESTROY_STOLEN_JUNK_MAX_VALUE_THRESHOLD_T = "Csak akkor semmisítsd meg automatikusan a lopott tárgyakat, ha az orgazdai eladási áruk ezen a küszöbön van vagy az alatt. Ha egy tárgy megsemmisült, az nem állítható helyre!", 
    SI_PA_MENU_JUNK_AUTO_DESTROY_STOLEN_JUNK_MAX_QUALITY_THRESHOLD = "ÉS a lopott tárgy minősége az alábbi szinten vagy az alatt van", 
    SI_PA_MENU_JUNK_AUTO_DESTROY_STOLEN_JUNK_MAX_QUALITY_THRESHOLD_T = "Csak akkor semmisítsd meg automatikusan a lopott tárgyakat, ha a minőségi szintjük ezen a küszöbön van vagy az alatt. Ha egy tárgy megsemmisült, az nem állítható helyre!", 
    
    -- Egyéb beállítások --
    SI_PA_MENU_JUNK_MAILBOX_IGNORE = "Soha ne jelölje szemétnek a postaládából kapott tárgyakat", 
    SI_PA_MENU_JUNK_MAILBOX_IGNORE_T = "A postaládából érkező tárgyakat soha ne jelölje szemétnek", 
    SI_PA_MENU_JUNK_CRAFTED_IGNORE = "Soha ne jelölje szemétnek az általad készített tárgyakat", 
    SI_PA_MENU_JUNK_CRAFTED_IGNORE_T = "Azokat a tárgyakat, amelyeket kézműves állomáson készítettél, soha ne jelölje szemétnek", 
    SI_PA_MENU_JUNK_AUTOSELL_JUNK = "Szemét automatikus eladása kereskedőknél és orgazdáknál?", 
    SI_PA_MENU_JUNK_AUTOSELL_JUNK_PIRHARRI = "Automatikusan eladja Pirharri-nak is? (Orgazda asszisztens)", 
    SI_PA_MENU_JUNK_AUTOSELL_JUNK_PIRHARRI_W = "Más orgazdákkal ellentétben Pirharri 35%-os csempészdíjat számít fel a szolgáltatásáért", 

    SI_PA_MENU_JUNK_KEYBINDINGS_HEADER = "Gyorsbillentyűk", 
    SI_PA_MENU_JUNK_KEYBINDINGS_MARK_UNMARK_JUNK_ENABLE = "\"Megjelölés szemétként\" gyorsbillentyű engedélyezése", 
    SI_PA_MENU_JUNK_KEYBINDINGS_MARK_UNMARK_JUNK_SHOW = "\"Megjelölés szemétként\" gyorsbillentyű megjelenítése", 
    SI_PA_MENU_JUNK_KEYBINDINGS_MARK_UNMARK_PERM_JUNK_ENABLE = "\"Megjelölés végleges szemétként\" gyorsbillentyű engedélyezése", 
    SI_PA_MENU_JUNK_KEYBINDINGS_MARK_UNMARK_PERM_JUNK_SHOW = "\"Megjelölés végleges szemétként\" gyorsbillentyű megjelenítése", 
    SI_PA_MENU_JUNK_KEYBINDINGS_DESTROY_ITEM_ENABLE = "\"Tárgy megsemmisítése\" gyorsbillentyű engedélyezése", 
    SI_PA_MENU_JUNK_KEYBINDINGS_DESTROY_ITEM_ENABLE_W = "FIGYELEM: Kérlek vedd figyelembe, hogy ezzel a gyorsbillentyűvel NINCS megerősítő kérdés, hogy a tárgy valóban megsemmisíthető-e.\nEgyszerűen megsemmisül!\nÖrökre!\nSaját felelősségre használd!", 
    SI_PA_MENU_JUNK_KEYBINDINGS_DESTROY_ITEM_SHOW = "\"Tárgy megsemmisítése\" gyorsbillentyű megjelenítése", 
    SI_PA_MENU_JUNK_KEYBINDINGS_EXCLUDE_DESCRIPTION = "Tiltsd le a \"Tárgy megsemmisítése\" gyorsbillentyűt, ha a tárgy . . .", 
    SI_PA_MENU_JUNK_KEYBINDINGS_DESTROY_QUALITY_THRESHOLD = "> a kiválasztott minőségű vagy jobb", 
    SI_PA_MENU_JUNK_KEYBINDINGS_DESTROY_UNKNOWN = "> megtanulható/kikutatható és ismeretlen", 

    -- Általános szövegek: Fegyverek, Páncélzat, Ékszerek
    SI_PA_MENU_JUNK_AUTOMARK_QUALITY_THRESHOLD = "%s automatikus megjelölése (minőség: az alábbi vagy alacsonyabb)", 
    SI_PA_MENU_JUNK_AUTOMARK_QUALITY_THRESHOLD_T = "Automatikusan jelölje szemétnek a %s-eket, ha azok a kiválasztott minőségűek vagy rosszabbak", 
    SI_PA_MENU_JUNK_AUTOMARK_ORNATE = table.concat({"%s automatikus megjelölése [", GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_ORNATE), "] tulajdonsággal"}), 
    SI_PA_MENU_JUNK_AUTOMARK_ORNATE_T = table.concat({"Automatikusan szemétnek jelölje a [", GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_ORNATE), "] tulajdonságú (megnövelt eladási ár) %s-eket?"}), 
    SI_PA_MENU_JUNK_AUTOMARK_INTRICATE = table.concat({"%s automatikus megjelölése [", GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_INTRICATE),"] tulajdonsággal"}), 
    SI_PA_MENU_JUNK_AUTOMARK_INTRICATE_T = table.concat({"Automatikusan szemétnek jelölje a [", GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_INTRICATE), "] tulajdonságú (megnövelt kézműves tapasztalat) %s-eket?"}), 
    SI_PA_MENU_JUNK_AUTOMARK_INCLUDE_SETS = "A szett részét képező %s-ek automatikus megjelölése is", 
    SI_PA_MENU_JUNK_AUTOMARK_INCLUDE_SETS_T = "Ha KI van kapcsolva, csak a nem szetthez tartozó %s-ek lesznek szemétnek jelölve", 
    SI_PA_MENU_JUNK_AUTOMARK_INCLUDE_KNOWN_TRAITS = "Ismert tulajdonságú %s-ek automatikus megjelölése is", 
    SI_PA_MENU_JUNK_AUTOMARK_INCLUDE_KNOWN_TRAITS_T = "Ha KI van kapcsolva, csak a tulajdonság nélküli vagy ismeretlen tulajdonságú %s-ek lesznek szemétnek jelölve", 
    SI_PA_MENU_JUNK_AUTOMARK_INCLUDE_UNKNOWN_TRAITS = "Ismeretlen tulajdonságú %s-ek automatikus megjelölése is", 
    SI_PA_MENU_JUNK_AUTOMARK_INCLUDE_UNKNOWN_TRAITS_T = "Ha KI van kapcsolva, csak a tulajdonság nélküli vagy ismert tulajdonságú %s-ek lesznek szemétnek jelölve", 

    -- =================================================================================================================
    -- == MAIN MENU TEXTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PAJunk --
    SI_PA_MAINMENU_JUNK_HEADER = "Szemét szabályok", 

    SI_PA_MAINMENU_JUNK_HEADER_ITEM = "Tárgy", 
    SI_PA_MAINMENU_JUNK_HEADER_JUNK_COUNT = "Szemét darabszám", 
    SI_PA_MAINMENU_JUNK_HEADER_LAST_JUNK = "Utolsó szemét", 
    SI_PA_MAINMENU_JUNK_HEADER_RULE_ADDED = "Szabály hozzáadva", 
    SI_PA_MAINMENU_JUNK_HEADER_ACTIONS = "Műveletek", 

    SI_PA_MAINMENU_JUNK_ROW_NEVER_JUNKED = "soha", 


    -- =================================================================================================================
    -- == CHAT OUTPUTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PAJunk --
    SI_PA_CHAT_JUNK_MARKED_AS_JUNK_TRASH = table.concat({"%s szemétnek jelölve (", PAC.COLOR.ORANGE:Colorize(GetString("SI_ITEMTYPE", ITEMTYPE_TRASH)), ")"}), 
    SI_PA_CHAT_JUNK_MARKED_AS_JUNK_ORNATE = table.concat({"%s szemétnek jelölve (", PAC.COLOR.ORANGE:Colorize(GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_ORNATE)), ")"}), 
    SI_PA_CHAT_JUNK_MARKED_AS_JUNK_INTRICATE = table.concat({"%s szemétnek jelölve (", PAC.COLOR.ORANGE:Colorize(GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_INTRICATE)), ")"}), 
    SI_PA_CHAT_JUNK_MARKED_AS_JUNK_QUALITY = table.concat({"%s szemétnek jelölve (", PAC.COLOR.ORANGE:Colorize("Minőség"), ")"}), 
    SI_PA_CHAT_JUNK_MARKED_AS_JUNK_MERCHANT = table.concat({"%s szemétnek jelölve (", PAC.COLOR.ORANGE:Colorize("Kereskedő"), ")"}), 
    SI_PA_CHAT_JUNK_MARKED_AS_JUNK_TREASURE = table.concat({"%s szemétnek jelölve (", PAC.COLOR.ORANGE:Colorize("Kincs"), ")"}), 
    SI_PA_CHAT_JUNK_MARKED_AS_JUNK_KEYBINDING = table.concat({"%s szemétnek jelölve (", PAC.COLOR.ORANGE:Colorize("Kézi"), ")"}), 
    SI_PA_CHAT_JUNK_MARKED_AS_JUNK_STOLEN = table.concat({"%s szemétnek jelölve (", PAC.COLOR.ORANGE:Colorize("Lopott"), ")"}), 
    SI_PA_CHAT_JUNK_MARKED_AS_JUNK_PERMANENT = table.concat({"%s szemétnek jelölve (", PAC.COLOR.ORANGE:Colorize("Állandó szabály"), ")"}), 

    SI_PA_CHAT_JUNK_DESTROYED_KEYBINDING = table.concat({PAC.COLOR.ORANGE_RED:Colorize("Megsemmisítve"), " %d x %s"}), 
    SI_PA_CHAT_JUNK_DESTROYED_ALWAYS = table.concat({PAC.COLOR.ORANGE_RED:Colorize("Megsemmisítve"), " %d x %s (", PAC.COLOR.ORANGE:Colorize("Mindig"), ")"}), 
    SI_PA_CHAT_JUNK_DESTROYED_CRITERIA_MATCH = table.concat({PAC.COLOR.ORANGE_RED:Colorize("Megsemmisítve"), " %d x %s (Eladási érték: %s)"}), 
    SI_PA_CHAT_JUNK_AUTO_LAUNDERED = table.concat({PAC.COLOR.ORANGE_RED:Colorize("Tisztára mosva"), " %d x %s (Fizetett ár: %s)"}), 

    SI_PA_CHAT_JUNK_DESTROY_ON = table.concat({"Szemét tárgyak automatikus megsemmisítése ", PAC.COLOR.RED:Colorize("BEKAPCSOLVA")}), 
    SI_PA_CHAT_JUNK_DESTROY_OFF = table.concat({"Szemét tárgyak automatikus megsemmisítése ", PAC.COLOR.GREEN:Colorize("KIKAPCSOLVA")}), 
    SI_PA_CHAT_JUNK_DESTROY_STOLEN_ON = table.concat({"Lopott szemét tárgyak automatikus megsemmisítése ", PAC.COLOR.RED:Colorize("BEKAPCSOLVA")}), 
    SI_PA_CHAT_JUNK_DESTROY_STOLEN_OFF = table.concat({"Lopott szemét tárgyak automatikus megsemmisítése ", PAC.COLOR.GREEN:Colorize("KIKAPCSOLVA")}), 

    SI_PA_CHAT_JUNK_SOLD_ITEMS_INFO = "Tárgyak eladva ennyiért: %s", 
    SI_PA_CHAT_JUNK_FENCE_LIMIT_HOURS = table.concat({GetString("SI_STOREFAILURE", STORE_FAILURE_AT_FENCE_LIMIT), " Kérlek várj ~%d órát"}), 
    SI_PA_CHAT_JUNK_FENCE_LIMIT_MINUTES = table.concat({GetString("SI_STOREFAILURE", STORE_FAILURE_AT_FENCE_LIMIT), " Kérlek várj ~%d percet"}), 
    SI_PA_CHAT_JUNK_FENCE_ITEM_WORTHLESS = table.concat({"Nem adható el: %s. ", GetString("SI_STOREFAILURE", STORE_FAILURE_WORTHLESS_TO_FENCE)}), 
    SI_PA_CHAT_JUNK_CANNOT_SELL_ITEM = "Nem adható el: %s", 

    SI_PA_CHAT_JUNK_RULES_ADDED = table.concat({"%s ", PAC.COLOR.ORANGE:Colorize("hozzáadva"), " az állandó szemétlistához!"}), 
    SI_PA_CHAT_JUNK_RULES_DELETED = table.concat({"%s ", PAC.COLOR.ORANGE:Colorize("eltávolítva"), " az állandó szemétlistából!"}), 


    -- =================================================================================================================
    -- == KEY BINDINGS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- Addon Keybindings menu --
    SI_BINDING_NAME_PA_JUNK_TOGGLE_ITEM = "Megjelölés szemétként", 
    SI_BINDING_NAME_PA_JUNK_PERMANENT_TOGGLE_ITEM = "Megjelölés végleges szemétként", 
    SI_BINDING_NAME_PA_JUNK_DESTROY_ITEM = "Tárgy megsemmisítése", 

    -- Actual keybindings --
    SI_PA_ITEM_ACTION_MARK_AS_PERM_JUNK = "Megjelölés végleges szemétként", 
    SI_PA_ITEM_ACTION_UNMARK_AS_PERM_JUNK = "Végleges szemétjelölés eltávolítása", 


    -- =================================================================================================================
    -- == OTHER STRINGS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- Quest: "A Matter of Leisure"
    SI_PA_TREASURE_ITEM_TAG_DESC_TOYS = "Gyermekjátékok", 
    SI_PA_TREASURE_ITEM_TAG_DESC_DOLLS = "Babák", 
    SI_PA_TREASURE_ITEM_TAG_DESC_GAMES = "Játékok", 

    -- Quest: "A Matter of Respect"
    SI_PA_TREASURE_ITEM_TAG_DESC_UTENSILS = "Evőeszközök", 
    SI_PA_TREASURE_ITEM_TAG_DESC_DRINKWARE = "Ivóedények", 
    SI_PA_TREASURE_ITEM_TAG_DESC_DISHES_COOKWARE = "Edények és főzőeszközök", 

    -- Quest: "A Matter of Tributes"
    SI_PA_TREASURE_ITEM_TAG_DESC_COSMETICS = "Kozmetikumok", 
    SI_PA_TREASURE_ITEM_TAG_DESC_GROOMING = "Ápolási cikkek", 

    -- Quest: "The Covetous Countess" (csak kiegészítő címkék)
    SI_PA_TREASURE_ITEM_TAG_DESC_LINENS = "Szárazáruk", 
    SI_PA_TREASURE_ITEM_TAG_DESC_ACCESSORIES = "Ruhatári kiegészítők", 
    SI_PA_TREASURE_ITEM_TAG_DESC_STATUES = "Szobrok", 
    SI_PA_TREASURE_ITEM_TAG_DESC_WRITINGS = "Írások", 
    SI_PA_TREASURE_ITEM_TAG_DESC_SCRIVENER = "Íróeszközök", 
    SI_PA_TREASURE_ITEM_TAG_DESC_MAPS = "Térképek", 
    SI_PA_TREASURE_ITEM_TAG_DESC_RITUAL_OBJECTS = "Rituális tárgyak", 
    SI_PA_TREASURE_ITEM_TAG_DESC_ODDITIES = "Különlegességek", 

    -- EGYEBEK: Még nem használt
    SI_PA_TREASURE_ITEM_TAG_DESC_INSTRUMENTS = "Hangszerek", 
    SI_PA_TREASURE_ITEM_TAG_DESC_ARTWORK = "Műalkotások", 
    SI_PA_TREASURE_ITEM_TAG_DESC_DECOR = "Fali díszek", 
    SI_PA_TREASURE_ITEM_TAG_DESC_TRIFLES_ORNAMENTS = "Apróságok és dísztárgyak", 
    SI_PA_TREASURE_ITEM_TAG_DESC_DEVICES = "Szerkezetek", 
    SI_PA_TREASURE_ITEM_TAG_DESC_SMITHING = "Kovácseszközök", 
    SI_PA_TREASURE_ITEM_TAG_DESC_TOOLS = "Szerszámok", 
    SI_PA_TREASURE_ITEM_TAG_DESC_MEDICAL_SUPPLIES = "Orvosi kellékek", 
    SI_PA_TREASURE_ITEM_TAG_DESC_CURIOSITIES = "Mágikus érdekességek", 
    SI_PA_TREASURE_ITEM_TAG_DESC_FURNISHINGS = "Berendezési tárgyak", 
    SI_PA_TREASURE_ITEM_TAG_DESC_LIGHTS = "Fényforrások", 
}

for key, value in pairs(PAJStrings) do
    ZO_CreateStringId(key, value) 
    SafeAddVersion(key, 1) 
end


local PAJGenericStrings = {
    -- =================================================================================================================
    -- Language independent texts (do not need to be translated/copied to other languages --

    -- =================================================================================================================
    -- == MENU/PANEL TEXTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PAJunk Menu --
    SI_PA_MENU_JUNK_TRASH_HEADER = GetString("SI_ITEMTYPE", ITEMTYPE_TRASH), 
    SI_PA_MENU_JUNK_COLLECTIBLES_HEADER = zo_strformat("<<m:1>>", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_COLLECTIBLE)), 
    SI_PA_MENU_JUNK_MISCELLANEOUS_HEADER = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_MISCELLANEOUS), 
    SI_PA_MENU_JUNK_WEAPONS_HEADER = zo_strformat("<<m:1>>", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_WEAPONS)), 
    SI_PA_MENU_JUNK_ARMOR_HEADER = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ARMOR), 
    SI_PA_MENU_JUNK_JEWELRY_HEADER = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_JEWELRY), 


    -- =================================================================================================================
    -- == OTHER STRINGS FOR MENU == --
    -- -----------------------------------------------------------------------------------------------------------------
}

for key, value in pairs(PAJGenericStrings) do
    ZO_CreateStringId(key, value) 
    SafeAddVersion(key, 1) 
end