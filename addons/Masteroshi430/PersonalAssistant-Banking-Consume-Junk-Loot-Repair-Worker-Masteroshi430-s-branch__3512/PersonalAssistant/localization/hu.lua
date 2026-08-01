local PAC = PersonalAssistant.Constants
local PAStrings = {
    -- =================================================================================================================
    -- Language specific texts that need to be translated --

    -- =================================================================================================================
    -- == MENU/PANEL TEXTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- Profile Settings --
    SI_PA_MENU_PROFILE_PLEASE_SELECT = "<Kérlek, válassz profilt>",
    SI_PA_MENU_PROFILE_ACTIVE = "Aktív profil",
    SI_PA_MENU_PROFILE_ACTIVE_T = "Válaszd ki a PersonalAssistant aktív profilját. Ez automatikusan betölti az adott profilhoz tartozó összes beállítást, és a módosítások is ugyanoda kerülnek mentésre.",
    SI_PA_MENU_PROFILE_ACTIVE_RENAME = "Aktív profil átnevezése",

    -- Create Profiles --
    SI_PA_MENU_PROFILE_CREATE_NEW = "Új profil létrehozása",
    SI_PA_MENU_PROFILE_CREATE_NEW_DESC = table.concat({"Megjegyzés: Maximum ", PAC.GENERAL.MAX_PROFILES, " profilod lehet."}),

    -- Copy Profiles --
    SI_PA_MENU_PROFILE_COPY_FROM_DESC = "Beállítások másolása egy meglévő profilból az aktuálisan aktív profilba.",
    SI_PA_MENU_PROFILE_COPY_FROM = "Másolás profilból",
    SI_PA_MENU_PROFILE_COPY_FROM_CONFIRM = "Másolás megerősítése",
    SI_PA_MENU_PROFILE_COPY_FROM_CONFIRM_W = "Ez felülírja az aktív profil beállításait a kiválasztott profil beállításaival. Biztos vagy benne, hogy ezt szeretnéd tenni? \n\nMegjegyzés: Csak az engedélyezett PersonalAssistant modulok beállításai lesznek átmásolva.",

    -- Delete Profiles --
    SI_PA_MENU_PROFILE_DELETE_DESC = "Meglévő és használaton kívüli profilok törlése az adatbázisból a hely felszabadítása és a SavedVariables fájl tisztítása érdekében.",
    SI_PA_MENU_PROFILE_DELETE = "Profil törlése",
    SI_PA_MENU_PROFILE_DELETE_CONFIRM = "Törlés megerősítése",
    SI_PA_MENU_PROFILE_DELETE_CONFIRM_W = "Ez törli a kiválasztott profilt az összes karakter számára. Biztos vagy benne, hogy ezt szeretnéd tenni?",

    -- -----------------------------------------------------------------------------------------------------------------
    -- Rules Menu --
    SI_PA_MENU_RULES_HOW_TO_ADD_PAB = "Új szabály létrehozásához tárgyak be- és kivételéhez, egyszerűen kattints jobb gombbal egy tárgyra a leltárodban vagy a bankodban, és válaszd a helyi menüben:\n> PA Banking > Új szabály hozzáadása",
    SI_PA_MENU_RULES_HOW_TO_ADD_PAJ = "Új szabály létrehozásához egy tárgy végleges szemétként (junk) való megjelölésére, egyszerűen kattints jobb gombbal egy tárgyra a leltárodban vagy a bankodban, és válaszd a helyi menüben:\n> PA Junk > Megjelölés végleges szemétként",
    SI_PA_MENU_RULES_HOW_TO_FIND_MENU = table.concat({"Az összes aktív szabályt megtalálhatod a felső főmenü ikonján keresztül, amit az [Alt] billentyűvel nyithatsz meg, a ", PAC.COLOR.YELLOW:Colorize("/parules"), " paranccsal, vagy erre a gombra kattintva:"}),
    SI_PA_MENU_RULES_HOW_TO_CREATE = "Hogyan hozzak létre új szabályokat?",

    SI_PA_MENU_DANGEROUS_SETTING = "FIGYELEM: Veszélyes beállítás következik! Használd saját felelősségre!",

    -- -----------------------------------------------------------------------------------------------------------------
    -- Generic Menu --
    SI_PA_MENU_OTHER_SETTINGS_HEADER = "Egyéb beállítások",

    SI_PA_MENU_SILENT_MODE = "Csendes üzemmód (MINDEN csevegőüzenet letiltása)",

    SI_PA_MENU_NOT_YET_IMPLEMENTED = table.concat({PAC.COLORS.RED, "Még nincs megvalósítva!"}),


    -- =================================================================================================================
    -- == CHAT OUTPUTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PAGeneral --
    SI_PA_CHAT_GENERAL_NEW_PROFILE_CREATED = table.concat({" új profil ", PAC.COLOR.WHITE:Colorize("%s"), " létrehozva és aktiválva!"}),
    SI_PA_CHAT_GENERAL_SELECTED_PROFILE_COPIED = table.concat({" A(z) ", PAC.COLOR.WHITE:Colorize("%s"), " profil beállításai ", PAC.COLOR.ORANGE_RED:Colorize("átmásolva"), " a(z) ", PAC.COLOR.WHITE:Colorize("%s"), " aktív profilba"}),
    SI_PA_CHAT_GENERAL_SELECTED_PROFILE_DELETED = table.concat({" A kiválasztott ", PAC.COLOR.WHITE:Colorize("%s"), " profil ", PAC.COLOR.ORANGE_RED:Colorize("törölve!")}),

    SI_PA_CHAT_GENERAL_TELEPORT_NO_PRIMARY_HOUSE = table.concat({"Először ki kell jelölnöd egy házat ", PAC.COLOR.ORANGE_RED:Colorize("Elsődleges lakhely"), "-ként"}),
    SI_PA_CHAT_GENERAL_TELEPORT_ZONE_PREVENTED = table.concat({"A jelenlegi helyszíned ", PAC.COLOR.ORANGE_RED:Colorize("nem teszi lehetővé"), " a házadba történő gyorsutazást"}),


    -- =================================================================================================================
    -- == OTHER STRINGS FOR MENU == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PAGeneral --
    SI_PA_PROFILE = "Profil",

    -- -----------------------------------------------------------------------------------------------------------------
    -- Name Spaces --
    SI_PA_NS_BAG_EQUIPMENT = "", -- not required so far
    SI_PA_NS_BAG_BACKPACK = "Hátizsák",
    SI_PA_NS_BAG_BANK = "Bank",
    SI_PA_NS_BAG_SUBSCRIBER_BANK = "ESO Plus bank",
    SI_PA_NS_BAG_VIRTUAL = "Kézműves táska",
    SI_PA_NS_BAG_HOUSE_BANK = "Otthoni tároló",
    SI_PA_NS_BAG_HOUSE_BANK_NR = "Otthoni tároló (%d)",
    SI_PA_NS_BAG_UNKNOWN = "Ismeretlen",

    -- -----------------------------------------------------------------------------------------------------------------
    -- ItemTypes (Custom Singluar/Plural definition) --
    SI_PA_ITEMTYPE4 = "<<1[Étel/Ételek]>>",
    SI_PA_ITEMTYPE5 = "<<1[Trófea/Trófeák]>>",
    SI_PA_ITEMTYPE7 = "<<1[Bájital/Bájitalok]>>",
    SI_PA_ITEMTYPE8 = "<<1[Motívum/Motívumok]>>",
    SI_PA_ITEMTYPE10 = "<<1[Hozzávaló/Hozzávalók]>>",
    SI_PA_ITEMTYPE12 = "<<1[Ital/Italok]>>",
    SI_PA_ITEMTYPE16 = "<<1[Csali/Csalik]>>",
    SI_PA_ITEMTYPE19 = "<<1[Lélekkő/Lélekkövek]>>",
    SI_PA_ITEMTYPE22 = "<<1[Zárnyitó/Zárnyitók]>>",
    SI_PA_ITEMTYPE29 = "<<1[Recept/Receptek]>>",
    SI_PA_ITEMTYPE30 = "<<1[Méreg/Mérgek]>>",
    SI_PA_ITEMTYPE33 = "<<1[Oldószer/Oldószerek]>>",
    SI_PA_ITEMTYPE34 = "<<1[Gyűjthető tárgy/Gyűjthető tárgyak]>>",
    SI_PA_ITEMTYPE47 = "<<1[AvA Javítás/AvA Javítások]>>",
    SI_PA_ITEMTYPE56 = "<<1[Kincs/Kincsek]>>",
    SI_PA_ITEMTYPE60 = "<<1[Mesteri megbízás/Mesteri megbízások]>>",

    -- -----------------------------------------------------------------------------------------------------------------
    -- SpecializedItemTypes (Custom Singluar/Plural definition) --
    SI_PA_SPECIALIZEDITEMTYPE102 = "<<1[Töredék/Töredékek]>>",

    -- -----------------------------------------------------------------------------------------------------------------
    -- Master Writs based on CraftingType (Custom definition) --
    SI_PA_MASTERWRIT_CRAFTINGTYPE0 = table.concat({"Egyéb megbízások (", GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_OTHER), ")"}),
    SI_PA_MASTERWRIT_CRAFTINGTYPE1 = "Lepecsételt kovács megbízás",
    SI_PA_MASTERWRIT_CRAFTINGTYPE2 = "Lepecsételt szabó megbízás",
    SI_PA_MASTERWRIT_CRAFTINGTYPE3 = "Lepecsételt bűvölő megbízás",
    SI_PA_MASTERWRIT_CRAFTINGTYPE4 = "Lepecsételt alkímia megbízás",
    SI_PA_MASTERWRIT_CRAFTINGTYPE5 = "Lepecsételt főző megbízás",
    SI_PA_MASTERWRIT_CRAFTINGTYPE6 = "Lepecsételt asztalos megbízás",
    SI_PA_MASTERWRIT_CRAFTINGTYPE7 = "Lepecsételt ékszerész megbízás",

    -- -----------------------------------------------------------------------------------------------------------------
    -- PABanking --
    SI_PA_BANKING_MOVE_MODE_DONOTHING = "Ne tegyen semmit",
    SI_PA_BANKING_MOVE_MODE_TOBANK = "Bankba helyezés",
    SI_PA_BANKING_MOVE_MODE_TOBACKPACK = "Hátizsákba kivétel",

    SI_PA_MENU_BANKING_ADVANCED_GLYPHS = "Glifák",
    SI_PA_MENU_BANKING_ADVANCED_INTRICATE_ITEMS = "Bonyolult tárgyak",
    SI_PA_MENU_BANKING_ADVANCED_ORNATE_ITEMS = "Díszes tárgyak",

    SI_PA_MENU_BANKING_REPAIRKIT = "Javítókészletek",

    -- -----------------------------------------------------------------------------------------------------------------
    -- Operators --
    SI_PA_REL_OPERATOR_T = "Válaszd ki a matematikai operátort ehhez a tárgyhoz",
    SI_PA_REL_BACKPACK_EQUAL = "HÁTIZSÁK ==",
    SI_PA_REL_BACKPACK_LESSTHAN = "HÁTIZSÁK <", -- not used so far
    SI_PA_REL_BACKPACK_LESSTHANEQUAL = "HÁTIZSÁK <=",
    SI_PA_REL_BACKPACK_GREATERTHAN = "HÁTIZSÁK >", -- not used so far
    SI_PA_REL_BACKPACK_GREATERTHANEQUAL = "HÁTIZSÁK >=",
    SI_PA_REL_BANK_EQUAL = "BANK ==",
    SI_PA_REL_BANK_LESSTHAN = "BANK <", -- not used so far
    SI_PA_REL_BANK_LESSTHANOREQUAL = "BANK <=",
    SI_PA_REL_BANK_GREATERTHAN = "BANK >", -- not used so far
    SI_PA_REL_BANK_GREATERTHANOREQUAL = "BANK >=",

    -- -----------------------------------------------------------------------------------------------------------------
    -- Operator Tooltip --
    SI_PA_REL_BACKPACK_EQUAL_T = "HÁTIZSÁK egyenlő (==)",
    SI_PA_REL_BACKPACK_LESSTHAN_T = "HÁTIZSÁK kisebb, mint (<)", -- not used so far
    SI_PA_REL_BACKPACK_LESSTHANOREQUAL_T = "HÁTIZSÁK kisebb vagy egyenlő (<=)",
    SI_PA_REL_BACKPACK_GREATERTHAN_T = "HÁTIZSÁK nagyobb, mint (>)", -- not used so far
    SI_PA_REL_BACKPACK_GREATERTHANOREQUAL_T = "HÁTIZSÁK nagyobb vagy egyenlő (>=)",
    SI_PA_REL_BANK_EQUAL_T = "BANK egyenlő (==)",
    SI_PA_REL_BANK_LESSTHAN_T = "BANK kisebb, mint (<)", -- not used so far
    SI_PA_REL_BANK_LESSTHANOREQUAL_T = "BANK kisebb vagy egyenlő (<=)",
    SI_PA_REL_BANK_GREATERTHAN_T = "BANK nagyobb, mint (>)", -- not used so far
    SI_PA_REL_BANK_GREATERTHANOREQUAL_T = "BANK nagyobb vagy egyenlő (>=)",

    -- -----------------------------------------------------------------------------------------------------------------
    -- Text Operators --
    SI_PA_REL_TEXT_OPERATOR0 = "-",
    SI_PA_REL_TEXT_OPERATOR1 = "pontosan",
    SI_PA_REL_TEXT_OPERATOR2 = "kevesebb, mint", -- not used so far
    SI_PA_REL_TEXT_OPERATOR3 = "legfeljebb",
    SI_PA_REL_TEXT_OPERATOR4 = "több, mint", -- not used so far
    SI_PA_REL_TEXT_OPERATOR5 = "legalább",
    -- -----------------------------------------------------------------------------------------------------------------
    -- Stacking types --
    SI_PA_ST_MOVE_FULL = "Minden áthelyezése", -- 0: Full deposit
    SI_PA_ST_MOVE_INCOMPLETE_STACKS_ONLY = "Csak a meglévő halmok feltöltése", -- 1: Fill existing stacks
    SI_PA_ST_MOVE_ONE_STACK_ONLY = "Korlátozás: tárgyanként egy halom", -- 2: Deposit to the limit of one stack
    -- -----------------------------------------------------------------------------------------------------------------
    -- Icon Positions --
    SI_PA_POSITION_AUTO = "Automatikus",
    SI_PA_POSITION_MANUAL = "Manuális",

    -- -----------------------------------------------------------------------------------------------------------------
    -- PAJunk --
    SI_PA_ITEM_ACTION_NOTHING = "Ne tegyen semmit",
    SI_PA_ITEM_ACTION_LAUNDER = "Tisztára mosás orgazdánál", -- not used so far
    SI_PA_ITEM_ACTION_MARK_AS_JUNK = "Megjelölés szemétként",
    SI_PA_ITEM_ACTION_JUNK_DESTROY_WORTHLESS = "Szemétnek jelölés, vagy megsemmisítés, ha értéktelen",
    SI_PA_ITEM_ACTION_DESTROY_ALWAYS = "Mindig megsemmisítés",


    -- =================================================================================================================
    -- == CUSTOM SUB MENU == --
    -- -----------------------------------------------------------------------------------------------------------------
    SI_PA_SUBMENU_PAB_ADD_RULE = "Új szabály hozzáadása",
    SI_PA_SUBMENU_PAB_EDIT_RULE = "Szabály módosítása",
    SI_PA_SUBMENU_PAB_DELETE_RULE = "Szabály törlése",
    SI_PA_SUBMENU_PAB_ENABLE_RULE = "Szabály engedélyezése",
    SI_PA_SUBMENU_PAB_DISABLE_RULE = "Szabály letiltása",
    SI_PA_SUBMENU_PAB_ADD_RULE_BUTTON = "Hozzáadás",
    SI_PA_SUBMENU_PAB_UPDATE_RULE_BUTTON = "Mentés",
    SI_PA_SUBMENU_PAB_DELETE_RULE_BUTTON = "Törlés",
    SI_PA_SUBMENU_PAB_NO_RULES = "Még nincsenek definiált banki szabályok",
    SI_PA_SUBMENU_PAB_DISCLAIMER = "Jogi nyilatkozat: Ezek az egyéni banki szabályok az összes többi automatikus banki szabály (Crafting, Special, és AvA tárgyak) végrehajtása után fognak lefutni.",

    SI_PA_SUBMENU_PAJ_MARK_PERM_JUNK = "Megjelölés végleges szemétként",
    SI_PA_SUBMENU_PAJ_UNMARK_PERM_JUNK = "Végleges szemét megjelölés eltávolítása",
    SI_PA_SUBMENU_PAJ_NO_RULES = "Még nincsenek definiált végleges szemét szabályok",


    -- =================================================================================================================
    -- == KEY BINDINGS == --
    -- -----------------------------------------------------------------------------------------------------------------
    SI_KEYBINDINGS_CATEGORY_PA_PROFILES = "|cFFD700P|rersonal|cFFD700A|rssistant Profilok",
    SI_KEYBINDINGS_CATEGORY_PA_MENU = "|cFFD700P|rersonal|cFFD700A|rssistant Menü",

    SI_BINDING_NAME_PA_RULES_MAIN_MENU = "PersonalAssistant szabályok",
    SI_BINDING_NAME_PA_RULES_TOGGLE_WINDOW = "Banki/Szemét szabályok menüjének váltása",
    SI_BINDING_NAME_PA_TRAVEL_TO_HOUSE = "Utazás az elsődleges lakhelyre",
}

for key, value in pairs(PAStrings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end