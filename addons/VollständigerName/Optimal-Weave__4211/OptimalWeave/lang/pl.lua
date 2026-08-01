-- =============================================================================
-- === OptimalWeave Language File: Polish (pl.lua)                           ===
-- =============================================================================
--[[
    AddOn Name:         OptimalWeave
    File:               lang/pl.lua
    Description:        Polish localization using ZO_CreateStringId
    Version:            1.17.0
    Author:             Orollas & VollständigerName
--]]
-- =============================================================================

-- =============================================================================
-- == PANEL & AUTHOR INFORMATION ===============================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_PANEL_NAME", "|c6D6D6DOp|r|c8A8A8Atim|r|cA7A7A7al |r|cC4C4C4Wea|r|c6D6D6Dve|r")
ZO_CreateStringId("OW_MENU_AUTHORS", "|cEE82EEO|r|cDD74ECr|r|cCD65EAo|r|cBC57E8l|r|cAB48E6l|r|c9B3AE4a|r|c8A2BE2s|r & |cFFD700Vo|r|cF7D418l|r|cF3D324l|r|cEFD130s|r|cEBD03Ctä|r|cE3CD54n|r|cE0CC60d|r|cDCCA6Ci|r|cD8C978g|r|cD4C784e|r|cD0C690r|r|cCCC49CNa|r|cC4C1B4me|r")
ZO_CreateStringId("OW_MENU_WEBSITE", "https://github.com/VollstaendigerName")

-- =============================================================================
-- == INFORMATION SECTION ======================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_INFO_HEADER", "Informacje & README")
ZO_CreateStringId("OW_MENU_INFO_TEXT", "Globalny czas odnowienia (GCD) wynosi 1000ms. OptimalWeave zarządza kolejką umiejętności w oparciu o wybrany tryb, aby zoptymalizować przeplatanie. Dostosuj zachowanie poniższymi ustawieniami.")
ZO_CreateStringId("OW_MENU_MODE_HEADER", "Podstawowe mechaniki")
ZO_CreateStringId("OW_MENU_CONDITIONS_HEADER", "Zasady aktywacji")
ZO_CreateStringId("OW_MENU_ADVANCED_HEADER", "Kontrola zaawansowana")
ZO_CreateStringId("OW_MENU_PERFORMANCE_HEADER", "Ustawienia wydajności")
ZO_CreateStringId("OW_MENU_MODE_ACTIVE", "Dodatek aktywny")
ZO_CreateStringId("OW_MENU_MODE_INACTIVE", "Dodatek nieaktywny")
ZO_CreateStringId("OW_MENU_DISABLED_TOOLTIP", "Ta opcja jest obecnie wyłączona")
ZO_CreateStringId("OW_MENU_LATENCY_WARNING", "Ostrzeżenie: Wysokie opóźnienie może powodować lagi wejścia!")

ZO_CreateStringId("OW_MENU_DISCLAIMER_LABEL", "|cFF0000Ostrzeżenie|r") 
ZO_CreateStringId("OW_MENU_DISCLAIMER_TOOLTIP", "|cFF0000Ostrzeżenie:|r Ten dodatek nie jest tworzony ani wspierany przez ZeniMax Media Inc. The Elder Scrolls® i powiązane logo są zastrzeżonymi znakami towarowymi ZeniMax Media Inc. Wszystkie prawa zastrzeżone.")

-- =============================================================================
-- == CORE SETTINGS ============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_SETTINGS_HEADER", "Ustawienia główne")
ZO_CreateStringId("OW_MENU_MODE_LABEL", "Tryb działania")
ZO_CreateStringId("OW_MENU_MODE_TOOLTIP", "|c00FF00Sekwencyjny:|r Pozwala używać umiejętności tylko po wykonaniu lekkiego ataku.\n|cFF0000Ścisły:|r Pełna blokada. Brak kolejki podczas GCD.\n|cFFFF00Inteligentny:|r Kolejka dozwolona tylko bez oczekującego Lekkiego Ataku.\n|c00FFFFBrak:|r Wyłączone.")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_COND", "Sekwencyjny")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_HARD", "Ścisły")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_SOFT", "Inteligentny")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_NONE", "Brak")
ZO_CreateStringId("OW_MENU_COMBAT_LABEL", "Aktywny tylko w walce")
ZO_CreateStringId("OW_MENU_COMBAT_TOOLTIP", "Zarządza kolejką tylko podczas walki.")
ZO_CreateStringId("OW_MENU_ENEMYTARGET_LABEL", "Wymaga wrogiego celu")
ZO_CreateStringId("OW_MENU_ENEMYTARGET_TOOLTIP", "Wymaga wybrania wrogiego celu.")
ZO_CreateStringId("OW_MENU_BLOCKING_LABEL", "Ignoruj podczas blokowania")
ZO_CreateStringId("OW_MENU_BLOCKING_TOOLTIP", "Wyłącza kontrolę podczas blokowania.")
ZO_CreateStringId("OW_MENU_GROUNDAOE_LABEL", "Blokuj podwójne rzucanie AoE")
ZO_CreateStringId("OW_MENU_GROUNDAOE_TOOLTIP", "Zapobiega przypadkowemu podwójnemu rzucaniu umiejętności obszarowych.")
ZO_CreateStringId("OW_MENU_DISABLE_TANK", "Wyłącz jako Tank")
ZO_CreateStringId("OW_MENU_DISABLE_TANK_TOOLTIP", "Automatycznie wyłącz w roli Tanka")
ZO_CreateStringId("OW_MENU_DISABLE_HEAL", "Wyłącz jako Healer")
ZO_CreateStringId("OW_MENU_DISABLE_HEAL_TOOLTIP", "Automatycznie wyłącz w roli Healera")

ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_BACKBAR", "Wyłącz funkcje na drugim pasku")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_BACKBAR_TOOLTIP", "Wyłącza większość funkcji dodatku na drugim pasku broni.")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_BACKBAR", "Wyłącz asystent przeplatania na drugim pasku")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_BACKBAR_TOOLTIP", "Wyłącza asystenta przeplatania (zarządzanie GCD) na drugim pasku broni.")

ZO_CreateStringId("OW_MENU_DEACTIVATE_IN_PVP_HEADER", "Dezaktywacja w PvP")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_IN_PVP", "Wyłącz funkcje w PvP")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_IN_PVP_TOOLTIP", "Wyłącza większość funkcji dodatku na obszarach PvP")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_IN_PVP", "Wyłącz asystent przeplatania w PvP")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_IN_PVP_TOOLTIP", "Wyłącza asystenta przeplatania (zarządzanie GCD) na obszarach PvP")

-- =============================================================================
-- == BLOCK ID SETTINGS ========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKED_HEADER", "Zablokowane umiejętności")
ZO_CreateStringId("OW_MENU_BLOCKED_ADD_LABEL", "Zablokuj nowe ID")
ZO_CreateStringId("OW_MENU_BLOCKED_ADD_TOOLTIP", "Wprowadź ID umiejętności (np. 134160)")
ZO_CreateStringId("OW_MENU_BLOCKED_LIST_LABEL", "Obecnie zablokowane ID")
ZO_CreateStringId("OW_MENU_BLOCKED_LIST_TOOLTIP", "Kliknij aby usunąć")

-- =============================================================================
-- == ADVANCED SETTINGS ========================================================
-- =============================================================================
ZO_CreateStringId("OW_MENU_CHANNEL_NORMAL", "Bufor natychmiastowych (ms)")
ZO_CreateStringId("OW_MENU_CHANNEL_NORMAL_TOOLTIP", "Margines bezpieczeństwa dla umiejętności natychmiastowych (0-100ms)")
ZO_CreateStringId("OW_MENU_CHANNEL_CHANNELED", "Bufor kanałowych (ms)")
ZO_CreateStringId("OW_MENU_CHANNEL_CHANNELED_TOOLTIP", "Bufor dla umiejętności kanałowych (0-400ms)")
ZO_CreateStringId("OW_MENU_GCD_SLOT", "Slot śledzenia GCD")
ZO_CreateStringId("OW_MENU_GCD_SLOT_TOOLTIP", "Slot paska akcji do wykrywania GCD (1-8)")
ZO_CreateStringId("OW_MENU_MIN_GCD", "Minimalny próg GCD (ms)")
ZO_CreateStringId("OW_MENU_MIN_GCD_TOOLTIP", "Minimalny czas trwania GCD do rozpoznania (0-20ms)")
ZO_CreateStringId("OW_MENU_RESET_TIME_LABEL", "Czas resetu (sekundy)")
ZO_CreateStringId("OW_MENU_RESET_TIME_TOOLTIP", "Resetuje śledzenie po nieużywaniu żadnych umiejętności przez określoną liczbę sekund.")
ZO_CreateStringId("OW_MENU_AUTO_GCD_SLOT_LABEL", "Automatyczny slot śledzenia GCD")
ZO_CreateStringId("OW_MENU_AUTO_GCD_SLOT_TOOLTIP", "Automatycznie wybiera najlepszy slot śledzenia GCD ze slotów 3-8")
ZO_CreateStringId("OW_MENU_QUEUE_TIME", "Podstawowy czas kolejki (ms)")
ZO_CreateStringId("OW_MENU_QUEUE_TIME_TOOLTIP", "Domyślne okno kolejki (100-2000ms)")
ZO_CreateStringId("OW_MENU_RESETONBARSWAP_LABEL", "Reset przy zmianie broni")
ZO_CreateStringId("OW_MENU_RESETONBARSWAP_TOOLTIP", "Resetuje GCD przy zmianie broni")
ZO_CreateStringId("OW_MENU_RESETONDODGE_LABEL", "Reset przy uniku")
ZO_CreateStringId("OW_MENU_RESETONDODGE_TOOLTIP", "Resetuje GCD przy wykonaniu uniku")
ZO_CreateStringId("OW_MENU_AUTO_EQUIP_WEAPONS_LABEL", "Automatyczne dobywanie broni")
ZO_CreateStringId("OW_MENU_AUTO_EQUIP_WEAPONS_TOOLTIP", "Automatycznie dobywaj broń w walce")
ZO_CreateStringId("OW_MENU_RESET_SETTINGS_LABEL", "Zresetuj wszystko")
ZO_CreateStringId("OW_MENU_RESET_SETTINGS_TOOLTIP", "Zresetuj wszystkie ustawienia do wartości domyślnych")

-- =============================================================================
-- == LATENCY COMPENSATION =====================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_LATENCY_HEADER", "Kompensacja opóźnienia")
ZO_CreateStringId("OW_MENU_AUTOLATENCY_LABEL", "Automatyczna regulacja")
ZO_CreateStringId("OW_MENU_AUTOLATENCY_TOOLTIP", "Automatycznie dostosowuje do opóźnienia. Zalecane przy stabilnym połączeniu.")
ZO_CreateStringId("OW_MENU_MANUALLATENCY_LABEL", "Ręczne opóźnienie (ms)")
ZO_CreateStringId("OW_MENU_MANUALLATENCY_TOOLTIP", "Stała wartość dla niestabilnych połączeń (0-200ms).")

-- =============================================================================
-- == (SUB)CLASS SETTINGS ======================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_SUBCLASS_HEADER", "Ustawienia klas i gildii")
ZO_CreateStringId("OW_MENU_SUBCLASS_GRIMFOCUS", "Ponury Fokus")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_STACKS", "Wymagane stosy")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_STACKS_TOOLTIP", "Liczba stosów wymagana do aktywacji (zalecane: 10)")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_ALL_MORPHS", "Blokuj wszystkie morfy")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_ALL_MORPHS_TOOLTIP", "|cFF5555• Nieustanny Fokus:|r Zawsze zablokowany\n|cFFFF00• Ponury Fokus i Bezwzględna Determinacja:|r Dostępne tylko przy 10 stosach\n|cAAAAAAWyłącz:|r Domyślne zachowanie")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_GRIMFOCUSSTACKS_TOOGLE", "Włącz niestandardowe stosy")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_GRIMFOCUSSTACKS_TOOGLE_TOOLTIP", "|cFFD700Włączone:|r Używa ustawień stosów \n|cAAAAAAWyłączone:|r Zawsze blokuje do 10 stosów\n")

-- == BLOCK GUILDS SETTINGS ===================================================
ZO_CreateStringId("OW_MENU_SUBCLASS_GUILDS", "Gildie")
ZO_CreateStringId("OW_MENU_HUNTER_ALL_MORPHS", "Blokuj umiejętności myśliwego Gildii Wojowników")
ZO_CreateStringId("OW_MENU_HUNTER_ALL_MORPHS_TOOLTIP", "Blokuje wszystkie morfy umiejętności myśliwego Gildii Wojowników (Ekspert Łowców, Zamaskowany Łowca & Zły Łowca)")
ZO_CreateStringId("OW_MENU_LIGHT_ALL_MORPHS", "Blokuj umiejętności światła Gildii Magów")
ZO_CreateStringId("OW_MENU_LIGHT_ALL_MORPHS_TOOLTIP", "Blokuje wszystkie morfy umiejętności światła (Czarne światło, Wewnętrzne światło & Promieniste czarne światło)")

ZO_CreateStringId("OW_MENU_DEACTIVATEHUNTERLIGHTINPVP_ALL_MORPHS", "Wyłącz w PvP")
ZO_CreateStringId("OW_MENU_DEACTIVATEHUNTERLIGHTINPVP_ALL_MORPHS_TOOLTIP", "Wyłącza blokowanie umiejętności Łowcy/Światła w PvP")

-- == BLOCK MOLTEN WHIP SETTINGS ===============================================
ZO_CreateStringId("OW_MENU_SUBCLASS_MOLTENWHIP", "Rozpalany Bicz")
ZO_CreateStringId("OW_MENU_MOLTENWHIP_BLOCK", "Blokuj umiejętność Rozpalany Bicz")
ZO_CreateStringId("OW_MENU_MOLTENWHIP_BLOCK_TOOLTIP", "Blokuje umiejętność Rozpalany Bicz, aby nie stracić trzech ładunków")

-- == BLOCK FATECARVER SETTINGS ================================================
ZO_CreateStringId("OW_MENU_SUBCLASS_FATECARVER", "Arkanista Fatecarver")
ZO_CreateStringId("OW_MENU_FATECARVER_ALL_MORPHS", "Blokuj rzucanie Fatecarver")
ZO_CreateStringId("OW_MENU_FATECARVER_ALL_MORPHS_TOOLTIP", "Blokuje rzucanie do spełnienia warunków.")
ZO_CreateStringId("OW_MENU_CRUX_STACKS", "Wymagane stosy Crux")
ZO_CreateStringId("OW_MENU_CRUX_STACKS_TOOLTIP", "Minimalne stosy Crux do rzucenia (zalecane: 3)")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM", "Próg HP (%)")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOLTIP", "Wyłącz blokowanie Fatecarver, gdy HP spadnie poniżej tej wartości")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOGLE", "Włącz sprawdzanie HP dla Fatecarver")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOGLE_TOOLTIP", "Wyłącza blokowanie Fatecarver przy niskim zdrowiu")

ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM", "Próg Wytrzymałości (%)")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOLTIP", "Wyłącz blokowanie Fatecarver przy niskiej wytrzymałości")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOGLE", "Włącz sprawdzanie Wytrzymałości dla Fatecarver")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOGLE_TOOLTIP", "Wyłącza blokowanie Fatecarver przy niskiej wytrzymałości")

-- == BLOCK CEPHALIARCH'S FLAIL SETTINGS =======================================
ZO_CreateStringId("OW_MENU_SUBCLASS_CEPHALIARCHSFLAIL", "Bicz Cefaliarchy")
ZO_CreateStringId("OW_MENU_CEPHALIARCHSFLAIL", "Blokuj Bicz Cefaliarchy")
ZO_CreateStringId("OW_MENU_CEPHALIARCHSFLAIL_TOOLTIP", "Blokuje Bicz Cefaliarchy, gdy masz 3 stosy Crux")

-- == BLOCK TENTACULAR DREAD SETTINGS ==========================================
ZO_CreateStringId("OW_MENU_SUBCLASS_TENTACULAR", "Tentacular Dread")
ZO_CreateStringId("OW_MENU_TENTACULAR", "Blokuj Tentacular Dread")
ZO_CreateStringId("OW_MENU_TENTACULAR_TOOLTIP", "Blokuje umiejętność Tentacular Dread do spełnienia warunków.")

-- == Execute Check Settings ==========================================
ZO_CreateStringId("OW_MENU_EXECUTE_HEADER", "Sprawdzanie Egzekucji")
ZO_CreateStringId("OW_MENU_EXECUTE_ENABLE", "Włącz sprawdzanie egzekucji")
ZO_CreateStringId("OW_MENU_EXECUTE_ENABLE_TOOLTIP", "Włącza lub wyłącza funkcję sprawdzania egzekucji")
ZO_CreateStringId("OW_MENU_EXECUTE_THRESHOLD", "Próg Egzekucji (%)")
ZO_CreateStringId("OW_MENU_EXECUTE_THRESHOLD_TOOLTIP", "Procent zdrowia celu, poniżej którego dozwolone są zaklęcia egzekucji")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELLS_HEADER", "Zaklęcia Egzekucji")

-- == Grouped Execute Spells ==========================================
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_RADIANTMORPHS", "Radiacyjne Zniszczenie, Radiacyjna Chwała, Radiacyjne Uciśnienie")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_RADIANTMORPHS_TOOLTIP", "Blokuje morfy Radiacyjnego Zniszczenia, aż cel znajdzie się w zasięgu egzekucji")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_ASSASSINSBLADEMORPHS", "Ostrze Asasyna, Przebić, Ostrze Zabójcy")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_ASSASSINSBLADEMORPHS_TOOLTIP", "Blokuje morfy Ostrza Asasyna, aż cel znajdzie się w zasięgu egzekucji")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_MAGESFURYMORPHS", "Gniew Magów, Furia Magów, Nieskończona Furia")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_MAGESFURYMORPHS_TOOLTIP", "Blokuje morfy Furii Magów, aż cel znajdzie się w zasięgu egzekucji")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_REVERSESLASHMORPHS", "Odwrócone Cięcie, Odwrócone Cięcie Obszarowe, Egzekutor")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_REVERSESLASHMORPHS_TOOLTIP", "Blokuje morfy Odwróconego Cięcia, aż cel znajdzie się w zasięgu egzekucji")


-- == Work in progress ================================================
ZO_CreateStringId("OW_WIP", "WIP")

-- =============================================================================
-- == WEAPON SETTINGS ==========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEADER", "Dezaktywuj w zależności od typu broni")

ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_WEAPON", "Wyłącz asystent przeplatania dla typu broni")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_WEAPON_TOOLTIP", "Wyłącza tylko asystenta przeplatania (zarządzanie GCD) dla wybranych typów broni")

ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_WEAPON", "Wyłącz funkcje dla typu broni")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_WEAPON_TOOLTIP", "Wyłącza większość funkcji dodatku dla wybranych typów broni")

-- Broń jednoręczna
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_AXE", "Topór")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_AXE_TOOLTIP", "Dezaktywuj gdy topór jest wyposażony")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HAMMER", "Młot")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HAMMER_TOOLTIP", "Dezaktywuj gdy młot jest wyposażony")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SWORD", "Miecz")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SWORD_TOOLTIP", "Dezaktywuj gdy miecz jest wyposażony")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_DAGGER", "Sztylet")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_DAGGER_TOOLTIP", "Dezaktywuj gdy sztylet jest wyposażony")

-- Broń dwuręczna
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_SWORD", "Miecz dwuręczny")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_SWORD_TOOLTIP", "Dezaktywuj gdy miecz dwuręczny jest wyposażony")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_AXE", "Topór dwuręczny")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_AXE_TOOLTIP", "Dezaktywuj gdy topór dwuręczny jest wyposażony")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_HAMMER", "Młot dwuręczny")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_HAMMER_TOOLTIP", "Dezaktywuj gdy młot dwuręczny jest wyposażony")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_BOW", "Łuk")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_BOW_TOOLTIP", "Dezaktywuj gdy łuk jest wyposażony")

-- Kostury
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FIRE_STAFF", "Kostur ognia")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FIRE_STAFF_TOOLTIP", "Dezaktywuj gdy kostur ognia jest wyposażony")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FROST_STAFF", "Kostur lodu")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FROST_STAFF_TOOLTIP", "Dezaktywuj gdy kostur lodu jest wyposażony")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_LIGHTNING_STAFF", "Kostur błyskawic")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_LIGHTNING_STAFF_TOOLTIP", "Dezaktywuj gdy kostur błyskawic jest wyposażony")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEALING_STAFF", "Kostur leczniczy")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEALING_STAFF_TOOLTIP", "Dezaktywuj gdy kostur leczniczy jest wyposażony")

-- Inna broń
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SHIELD", "Tarcza")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SHIELD_TOOLTIP", "Dezaktywuj gdy tarcza jest wyposażona")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RUNE", "Runa")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RUNE_TOOLTIP", "Dezaktywuj gdy runa jest wyposażona")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_NONE", "Brak broni")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_NONE_TOOLTIP", "Dezaktywuj gdy brak wyposażonej broni")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RESERVED", "Zarezerwowana broń")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RESERVED_TOOLTIP", "Dezaktywuj gdy zarezerwowany typ broni jest wyposażony")

-- =============================================================================
-- == CUSTOM BLOCK LIST SETTINGS ==============================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKLIST_HEADER", "Niestandardowe listy blokad")
ZO_CreateStringId("OW_MENU_CONFIGURABLEBLOCK_HEADER", "Własna Lista Blokowania")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_DESC", "Dodaj ID umiejętności, aby je zablokować. Możesz także dodać umiejętności, klikając prawym przyciskiem myszy na slot paska akcji (wymaga przeładowania)")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SPELLID_LABEL", "ID Umiejętności")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SPELLID_TOOLTIP", "Wprowadź numeryczne ID umiejętności (np. 185805)")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_ADD_BUTTON", "Dodaj do Listy Blokowania")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_LIST_HEADER", "Zablokowane Umiejętności:")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST", "Włącz Własną Listę Blokowania")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_TOOLTIP", "Włącza lub wyłącza funkcjonalność własnej listy blokowania")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SV_DESC", "Sprawdź swój plik SavedVariables:\n customBlockList = {\n   [AbilityID] = false/true\n }")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_HEALTH_CHECK", "Włącz sprawdzanie zdrowia dla własnej listy blokowania")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_HEALTH_CHECK_TOOLTIP", "Po włączeniu, umiejętności na własnej liście blokowania będą blokowane tylko wtedy, gdy twoje zdrowie jest powyżej progu.")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_HEALTH_PERCENT", "Próg zdrowia dla własnej listy blokowania (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_HEALTH_PERCENT_TOOLTIP", "Umiejętności z własnej listy blokowania są blokowane tylko wtedy, gdy twoje zdrowie jest powyżej tego procentu.")

-- =============================================================================
-- == CUSTOM RECAST BLOCK LIST SETTINGS =======================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CONFIGURABLERECASTBLOCK_HEADER", "Własna Lista Blokowania Powtórnego Rzucania")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_DESC", "Dodaj ID umiejętności, aby zablokować ich powtórne rzucanie, dopóki pozostały czas efektu nie spadnie poniżej progu. Możesz także dodać umiejętności, klikając prawym przyciskiem myszy na slot paska akcji (wymaga przeładowania).")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SPELLID_LABEL", "ID Umiejętności")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SPELLID_TOOLTIP", "Wprowadź numeryczne ID umiejętności (np. 185805)")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_ADD_BUTTON", "Dodaj do Listy Blokowania Powtórnego Rzucania")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_LIST_HEADER", "Umiejętności Zablokowane do Powtórnego Rzucania:")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST", "Włącz Własną Listę Blokowania Powtórnego Rzucania")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_TOOLTIP", "Włącza lub wyłącza funkcjonalność własnej listy blokowania powtórnego rzucania")
ZO_CreateStringId("OW_MENU_RECAST_BLOCK_TIME", "Czas Blokowania Powtórnego Rzucania (s)")
ZO_CreateStringId("OW_MENU_RECAST_BLOCK_TIME_TOOLTIP", "Czas w sekundach, poniżej którego umiejętność z listy blokowania powtórnego rzucania może być ponownie rzucona (1.0 = 1 sekunda)")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SV_DESC", "Sprawdź swój plik SavedVariables:\n customRecastBlockList = {\n   [AbilityID] = false/true\n }")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_HEALTH_CHECK", "Włącz sprawdzanie zdrowia dla własnej listy blokowania powtórnego rzucania")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_HEALTH_CHECK_TOOLTIP", "Po włączeniu, umiejętności na własnej liście blokowania powtórnego rzucania będą blokowane tylko wtedy, gdy twoje zdrowie jest powyżej progu.")
ZO_CreateStringId("OW_MENU_CUSTOM_RECAST_BLOCK_LIST_HEALTH_PERCENT", "Próg zdrowia dla własnej listy blokowania powtórnego rzucania (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_RECAST_BLOCK_LIST_HEALTH_PERCENT_TOOLTIP", "Umiejętności z własnej listy blokowania powtórnego rzucania są blokowane tylko wtedy, gdy twoje zdrowie jest powyżej tego procentu.")

-- =============================================================================

ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_MAIN_TEXT", "ID umiejętności został dodany/usunięty. Jeśli nie chcesz dodawać lub usuwać więcej umiejętności, przeładuj interfejs, aby zmiany zostały wyświetlone.")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_BUTTON_YES", "Przeładuj interfejs")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_BUTTON_LATER", "Później")

ZO_CreateStringId("OW_MENU_DIALOG_BUTTON_OK", "OK")
ZO_CreateStringId("OW_MENU_INVALID_ID_DIALOG_MAIN_TEXT", "Błąd: Wprowadź prawidłowe ID umiejętności")
ZO_CreateStringId("OW_MENU_ID_NOT_EXIST_DIALOG_MAIN_TEXT", "ID umiejętności nie istnieje")
ZO_CreateStringId("OW_MENU_ID_IS_IN_SV_DIALOG_MAIN_TEXT", "ID umiejętności jest już na liście blokowania")

-- =============================================================================
-- == RESOURCE-BASED BLOCK LIST SETTINGS =======================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CONFIGURABLEBLOCK_RESOURCE_HEADER", "Lista blokowania oparta na zasobach")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_RESOURCE_DESC", "Dodaj ID umiejętności, aby blokować je, gdy twój główny zasób (Magia lub Wytrzymałość) jest poniżej progu. Możesz także dodawać umiejętności, klikając prawym przyciskiem na slot paska akcji (wymaga przeładowania interfejsu).")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RESOURCE_BLOCK_LIST", "Włącz listę blokowania opartą na zasobach")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RESOURCE_BLOCK_LIST_TOOLTIP", "Włącza lub wyłącza funkcjonalność listy blokowania opartej na zasobach")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_RESOURCE_CHECK", "Włącz kontrolę zasobów")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_RESOURCE_CHECK_TOOLTIP", "Gdy włączone, umiejętności na liście blokowania zasobów będą blokowane tylko wtedy, gdy twój główny zasób (Magia lub Wytrzymałość) jest powyżej progu.")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_RESOURCE_PERCENT", "Próg zasobu (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_RESOURCE_PERCENT_TOOLTIP", "Umiejętności na liście blokowania zasobów są blokowane tylko wtedy, gdy twój główny zasób (Magia lub Wytrzymałość) jest powyżej tego procentu.")
ZO_CreateStringId("OW_MENU_RESOURCE_BLOCK_SPELL", "Umiejętność: ")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_CHECK", "Kontrola Magii")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_CHECK_TOOLTIP", "Włącz blokowanie oparte na Magii dla tej umiejętności")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_BLOCK_MODE", "Blokuj, gdy Magia jest poniżej progu")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_BLOCK_MODE_TOOLTIP", "Blokuj umiejętność, gdy Magia jest poniżej progu (odznacz, aby zezwalać tylko gdy poniżej)")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_THRESHOLD", "Próg Magii (%)")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_THRESHOLD_TOOLTIP", "Próg procentowy Magii")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_CHECK", "Kontrola Wytrzymałości")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_CHECK_TOOLTIP", "Włącz blokowanie oparte na Wytrzymałości dla tej umiejętności")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_BLOCK_MODE", "Blokuj, gdy Wytrzymałość jest poniżej progu")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_BLOCK_MODE_TOOLTIP", "Blokuj umiejętność, gdy Wytrzymałość jest poniżej progu (odznacz, aby zezwalać tylko gdy poniżej)")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_THRESHOLD", "Próg Wytrzymałości (%)")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_THRESHOLD_TOOLTIP", "Próg procentowy Wytrzymałości")

-- =============================================================================
-- == KEYBINDINGS LOCALIZATION =================================================
-- =============================================================================

ZO_CreateStringId("SI_KEYBINDINGS_CATEGORY_OPTIMALWEAVE", "|c6D6D6DOpti|r|c8A8A8AmalWea|r|cC4C4C4ve|r")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_MODE", "Przełącz Tryb (Ścisły/Inteligentny/Wyłączony)")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_CUSTOM_BLOCK_LIST", "Przełącz Własną Listę Blokowania")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_CUSTOM_RECAST_BLOCK_LIST", "Przełącz Własną Listę Blokowania Powtórnego Rzucania")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_BACKBAR_FEATURES", "Przełącz Wyłączanie Funkcji Drugiego Paska")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_BACKBAR_WEAVE_ASSIST", "Przełącz Wyłączanie Asystenta Przeplatania na Drugim Pasku")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_EXECUTE_CHECK", "Przełącz Sprawdzanie Egzekucji")

-- =============================================================================
-- == REMOVE BUTTON ============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_REMOVE_BUTTON", "Usuń")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_REMOVE_TOOLTIP", "Usuń tę umiejętność z listy blokowania (wymagane /reloadui)")

-- =============================================================================
-- == SETTIINGS MODE ===========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_MODE_SELECTION_LABEL", "Tryb ustawień")
ZO_CreateStringId("OW_MENU_MODE_SELECTION_TOOLTIP", "Wybierz, czy ustawienia są współdzielone między wszystkimi postaciami na tym koncie (Wspólne dla konta), czy przechowywane osobno dla każdej postaci (Na postać).")
ZO_CreateStringId("OW_MENU_MODE_ACCOUNTWIDE", "Wspólne dla konta")
ZO_CreateStringId("OW_MENU_MODE_PERCHARACTER", "Na postać")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_SETTINGS_MAIN_TEXT", "Tryb ustawień został zmieniony. Przeładować interfejs, aby zastosować zmiany?")

-- =============================================================================
-- == IN COMBAT MENU BLOCKING ==================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCK_LAST_MENU", "Blokuj ostatnie menu w walce")
ZO_CreateStringId("OW_MENU_BLOCK_LAST_MENU_TOOLTIP", "Zapobiega otwieraniu ostatniego menu (ALT) podczas walki.")
ZO_CreateStringId("OW_MENU_BLOCK_CHAR_MENU", "Blokuj menu postaci w walce")
ZO_CreateStringId("OW_MENU_BLOCK_CHAR_MENU_TOOLTIP", "Zapobiega otwieraniu menu postaci (C) podczas walki.")

-- =============================================================================
-- == GCD DISPLAY ==============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_SHOW_GCD_LABEL", "Pokaż globalny czas odnowienia (GCD)")
ZO_CreateStringId("OW_MENU_SHOW_GCD_TOOLTIP", "Wyświetla wskaźnik GCD (dostarczony przez ZOS) nad paskiem akcji.")

-- =============================================================================
-- == BLOCKLIST COMBAT ONLY ====================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKLISTS_COMBAT_ONLY_LABEL", "Listy blokad tylko w walce")
ZO_CreateStringId("OW_MENU_BLOCKLISTS_COMBAT_ONLY_TOOLTIP", "Wszystkie niestandardowe listy blokad są aktywne tylko podczas walki. Poza walką wszystkie listy blokad są wyłączone.")

-- =============================================================================
-- === END OF POLISH LOCALIZATION ==============================================
-- =============================================================================