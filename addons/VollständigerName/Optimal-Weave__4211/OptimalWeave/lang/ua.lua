-- =============================================================================
-- === OptimalWeave Language File: Ukrainian (ua.lua)                        ===
-- =============================================================================
--[[
    AddOn Name:         OptimalWeave
    File:               lang/ua.lua
    Description:        Ukrainian localization using ZO_CreateStringId
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

ZO_CreateStringId("OW_MENU_INFO_HEADER", "Інформація & ДОВІДКА")
ZO_CreateStringId("OW_MENU_INFO_TEXT", "Глобальна перезарядка (GCD) становить 1000 мс. OptimalWeave керує чергою здібностей відповідно до обраного режиму для оптимізації плетіння. Використовуйте налаштування для персоналізації поведінки.")
ZO_CreateStringId("OW_MENU_MODE_HEADER", "Основні механіки")
ZO_CreateStringId("OW_MENU_CONDITIONS_HEADER", "Правила активації")
ZO_CreateStringId("OW_MENU_ADVANCED_HEADER", "Розширені налаштування")
ZO_CreateStringId("OW_MENU_PERFORMANCE_HEADER", "Налаштування продуктивності")
ZO_CreateStringId("OW_MENU_MODE_ACTIVE", "Аддон активний")
ZO_CreateStringId("OW_MENU_MODE_INACTIVE", "Аддон неактивний")
ZO_CreateStringId("OW_MENU_DISABLED_TOOLTIP", "Ця опція зараз вимкнена")
ZO_CreateStringId("OW_MENU_LATENCY_WARNING", "Увага: Висока затримка може спричинити затримки введення!")

ZO_CreateStringId("OW_MENU_DISCLAIMER_LABEL", "|cFF0000Застереження|r") 
ZO_CreateStringId("OW_MENU_DISCLAIMER_TOOLTIP",  "|cFF0000Відмова від відповідальності:|r Цей додаток не створений, не пов'язаний і не підтримується ZeniMax Media Inc. The Elder Scrolls® та пов'язані логотипи є зареєстрованими торговими марками ZeniMax Media Inc. у США та/або інших країнах. Усі права захищені.")

-- =============================================================================
-- == CORE SETTINGS ============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_SETTINGS_HEADER", "Основні налаштування")
ZO_CreateStringId("OW_MENU_MODE_LABEL", "Режим роботи")
ZO_CreateStringId("OW_MENU_MODE_TOOLTIP", "|c00FF00Послідовний:|r Дозволяє використовувати вміння лише після легкої атаки.\n|cFF0000Суворий:|r Повне блокування. Черга відсутня під час GCD.\n|cFFFF00Розумний:|r Черга дозволена лише без очікуваної легкої атаки.\n|c00FFFFВідсутній:|r Вимкнено.")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_COND", "Послідовний")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_HARD", "Суворий")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_SOFT", "Розумний")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_NONE", "Відсутній")
ZO_CreateStringId("OW_MENU_COMBAT_LABEL", "Активно лише в бою")
ZO_CreateStringId("OW_MENU_COMBAT_TOOLTIP", "Керує чергою лише під час бою.")
ZO_CreateStringId("OW_MENU_ENEMYTARGET_LABEL", "Потрібна ворожа ціль")
ZO_CreateStringId("OW_MENU_ENEMYTARGET_TOOLTIP", "Працює лише з ворожими цілями.")
ZO_CreateStringId("OW_MENU_BLOCKING_LABEL", "Ігнорувати при блокуванні")
ZO_CreateStringId("OW_MENU_BLOCKING_TOOLTIP", "Вимкнення контролю під час блокування.")
ZO_CreateStringId("OW_MENU_GROUNDAOE_LABEL", "Блокувати подвійне застосування по землі")
ZO_CreateStringId("OW_MENU_GROUNDAOE_TOOLTIP", "Запобігає випадковому подвійному застосуванню.")
ZO_CreateStringId("OW_MENU_DISABLE_TANK", "Вимкнути як Танк")
ZO_CreateStringId("OW_MENU_DISABLE_TANK_TOOLTIP", "Автоматично вимикається в ролі Танка")
ZO_CreateStringId("OW_MENU_DISABLE_HEAL", "Вимкнути як Лікар")
ZO_CreateStringId("OW_MENU_DISABLE_HEAL_TOOLTIP", "Автоматично вимикається в ролі Лікаря")

ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_BACKBAR", "Вимкнути функції на другій панелі")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_BACKBAR_TOOLTIP", "Вимкає більшість функцій аддону на другій панелі зброї.")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_BACKBAR", "Вимкнути асистента плетіння на другій панелі")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_BACKBAR_TOOLTIP", "Вимкає асистента плетіння (керування GCD) на другій панелі зброї.")

ZO_CreateStringId("OW_MENU_DEACTIVATE_IN_PVP_HEADER", "Вимкнення в PvP")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_IN_PVP", "Вимкнути функції в PvP")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_IN_PVP_TOOLTIP", "Вимкнути більшість функцій аддона в PvP-зонах")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_IN_PVP", "Вимкнути помічник плетіння в PvP")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_IN_PVP_TOOLTIP", "Вимкнути помічник плетіння (управління GCD) в PvP-зонах")

-- =============================================================================
-- == BLOCK ID SETTINGS ========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKED_HEADER", "Заблоковані здібності")
ZO_CreateStringId("OW_MENU_BLOCKED_ADD_LABEL", "Заблокувати новий ID")
ZO_CreateStringId("OW_MENU_BLOCKED_ADD_TOOLTIP", "Введіть ID здібності (напр. 134160)")
ZO_CreateStringId("OW_MENU_BLOCKED_LIST_LABEL", "Зараз заблоковані ID")
ZO_CreateStringId("OW_MENU_BLOCKED_LIST_TOOLTIP", "Клацніть для видалення")

-- =============================================================================
-- == ADVANCED SETTINGS ========================================================
-- =============================================================================
ZO_CreateStringId("OW_MENU_CHANNEL_NORMAL", "Запас миттєвих (мс)")
ZO_CreateStringId("OW_MENU_CHANNEL_NORMAL_TOOLTIP", "Запас безпеки для миттєвих здібностей (0-100 мс)")
ZO_CreateStringId("OW_MENU_CHANNEL_CHANNELED", "Запас канальних (мс)")
ZO_CreateStringId("OW_MENU_CHANNEL_CHANNELED_TOOLTIP", "Запас для канальних здібностей (0-400 мс)")
ZO_CreateStringId("OW_MENU_GCD_SLOT", "Слот відстеження GCD")
ZO_CreateStringId("OW_MENU_GCD_SLOT_TOOLTIP", "Слот панелі для виявлення GCD (1-8)")
ZO_CreateStringId("OW_MENU_MIN_GCD", "Мінімальний поріг GCD (мс)")
ZO_CreateStringId("OW_MENU_MIN_GCD_TOOLTIP", "Мінімальна тривалість GCD для виявлення (0-20 мс)")
ZO_CreateStringId("OW_MENU_RESET_TIME_LABEL", "Час скидання (секунди)")
ZO_CreateStringId("OW_MENU_RESET_TIME_TOOLTIP", "Скидає відстеження, якщо нічого не застосовувалось протягом цієї кількості секунд.")
ZO_CreateStringId("OW_MENU_AUTO_GCD_SLOT_LABEL", "Автоматичний слот відстеження GCD")
ZO_CreateStringId("OW_MENU_AUTO_GCD_SLOT_TOOLTIP", "Автоматично вибирає найкращий слот для відстеження GCD зі слотів 3-8")
ZO_CreateStringId("OW_MENU_QUEUE_TIME", "Базовий час черги (мс)")
ZO_CreateStringId("OW_MENU_QUEUE_TIME_TOOLTIP", "Типове вікно черги (100-2000 мс)")
ZO_CreateStringId("OW_MENU_RESETONBARSWAP_LABEL", "Скидати при зміні зброї")
ZO_CreateStringId("OW_MENU_RESETONBARSWAP_TOOLTIP", "Скидає GCD при зміні зброї")
ZO_CreateStringId("OW_MENU_RESETONDODGE_LABEL", "Скидати при ухиленні")
ZO_CreateStringId("OW_MENU_RESETONDODGE_TOOLTIP", "Скидає GCD при виконанні ухилення")
ZO_CreateStringId("OW_MENU_AUTO_EQUIP_WEAPONS_LABEL", "Автоматично діставати зброю")
ZO_CreateStringId("OW_MENU_AUTO_EQUIP_WEAPONS_TOOLTIP", "Автоматично діставати зброю в бою")
ZO_CreateStringId("OW_MENU_RESET_SETTINGS_LABEL", "Скинути все")
ZO_CreateStringId("OW_MENU_RESET_SETTINGS_TOOLTIP", "Скинути всі налаштування до значень за замовчуванням")

-- =============================================================================
-- == LATENCY COMPENSATION =====================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_LATENCY_HEADER", "Компенсація затримки")
ZO_CreateStringId("OW_MENU_AUTOLATENCY_LABEL", "Авторегулювання")
ZO_CreateStringId("OW_MENU_AUTOLATENCY_TOOLTIP", "Автоматично регулює відповідно до затримки. Рекомендується для стабільних з'єднань.")
ZO_CreateStringId("OW_MENU_MANUALLATENCY_LABEL", "Ручна затримка (мс)")
ZO_CreateStringId("OW_MENU_MANUALLATENCY_TOOLTIP", "Фіксоване значення для нестабільних з'єднань (0-200 мс).")

-- =============================================================================
-- == (SUB)CLASS SETTINGS ======================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_SUBCLASS_HEADER", "Специфічні налаштування класів і гільдій")

ZO_CreateStringId("OW_MENU_SUBCLASS_GRIMFOCUS", "Похмурий фокус")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_STACKS", "Потрібні стаки")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_STACKS_TOOLTIP", "Кількість стаків, необхідних перед активацією Похмурого фокусу (Рекомендовано: 10)")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_ALL_MORPHS", "Блокувати всі морфи Похмурого фокусу")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_ALL_MORPHS_TOOLTIP", "|cFF5555• Невтомний фокус:|r Завжди заблоковано\n|cFFFF00• Похмурий фокус і Безжальна рішучість:|r Можна використовувати лише при 10 стаках\n|cAAAAAAВимкнено:|r Типова поведінка для всіх морфів")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_GRIMFOCUSSTACKS_TOOGLE", "Активувати користувацькі стаки")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_GRIMFOCUSSTACKS_TOOGLE_TOOLTIP", "|cFFD700Увімкнено:|r Використовує налаштування стаків \n|cAAAAAAВимкнено:|r Завжди блокує Похмурий фокус і Безжальну рішучість до 10 стаків, і завжди блокує Невтомний фокус\n")

-- == BLOCK GUILDS SETTINGS ===================================================
ZO_CreateStringId("OW_MENU_SUBCLASS_GUILDS", "Гільдії")
ZO_CreateStringId("OW_MENU_HUNTER_ALL_MORPHS", "Блокувати навички мисливця Гільдії воїнів")
ZO_CreateStringId("OW_MENU_HUNTER_ALL_MORPHS_TOOLTIP", "Блокує всі морфи навичок мисливця Гільдії воїнів (Експертний мисливець, Замаскований мисливець & Мисливець зла)")
ZO_CreateStringId("OW_MENU_LIGHT_ALL_MORPHS", "Блокувати навички світла Гільдії магів")
ZO_CreateStringId("OW_MENU_LIGHT_ALL_MORPHS_TOOLTIP", "Блокує всі морфи навичок світла (Магічне світло, Внутрішнє світло & Сяюче магічне світло)")

ZO_CreateStringId("OW_MENU_DEACTIVATEHUNTERLIGHTINPVP_ALL_MORPHS", "Вимкнути в PvP")
ZO_CreateStringId("OW_MENU_DEACTIVATEHUNTERLIGHTINPVP_ALL_MORPHS_TOOLTIP", "Вимкає блокування навичок Мисливця/Світла в PvP-зонах")

-- == BLOCK MOLTEN WHIP SETTINGS ===============================================
ZO_CreateStringId("OW_MENU_SUBCLASS_MOLTENWHIP", "Розплавлений батіг")
ZO_CreateStringId("OW_MENU_MOLTENWHIP_BLOCK", "Блокувати навичку Розплавлений батіг")
ZO_CreateStringId("OW_MENU_MOLTENWHIP_BLOCK_TOOLTIP", "Блокує навичку Розплавлений батіг, щоб запобігти втраті трьох стаків")

-- == BLOCK FATECARVER SETTINGS ================================================
ZO_CreateStringId("OW_MENU_SUBCLASS_FATECARVER", "Арканіст Різьблення долі")
ZO_CreateStringId("OW_MENU_FATECARVER_ALL_MORPHS", "Блокувати Різьблення долі")
ZO_CreateStringId("OW_MENU_FATECARVER_ALL_MORPHS_TOOLTIP", "Запобігає застосуванню Різьблення долі до виконання умов.")
ZO_CreateStringId("OW_MENU_CRUX_STACKS", "Потрібні стаки Крукс")
ZO_CreateStringId("OW_MENU_CRUX_STACKS_TOOLTIP", "Мінімальні стаки Крукс для застосування Різьблення долі (Рекомендовано: 3)")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM", "Поріг HP (%)")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOLTIP", "Вимкає блокування Різьблення долі, коли HP нижче цього значення")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOGLE", "Активувати перевірку HP для Різьблення долі")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOGLE_TOOLTIP", "Вимкає блокування Різьблення долі при низькому здоров'ї")

ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM", "Поріг Витривалості (%)")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOLTIP", "Вимкнути блокування Fatecarver при низькій витривалості")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOGLE", "Увімкнути перевірку Витривалості для Fatecarver")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOGLE_TOOLTIP", "Вимкає блокування Fatecarver при низькій витривалості")

-- == BLOCK CEPHALIARCH'S FLAIL SETTINGS =======================================   
ZO_CreateStringId("OW_MENU_SUBCLASS_CEPHALIARCHSFLAIL", "Біч цефаліарха")
ZO_CreateStringId("OW_MENU_CEPHALIARCHSFLAIL", "Блокувати Біч цефаліарха")
ZO_CreateStringId("OW_MENU_CEPHALIARCHSFLAIL_TOOLTIP", "Блокує Біч цефаліарха, коли у вас є 3 стаки Крукса")

-- == BLOCK TENTACULAR DREAD SETTINGS ==========================================
ZO_CreateStringId("OW_MENU_SUBCLASS_TENTACULAR", "Щупальцевий жах")
ZO_CreateStringId("OW_MENU_TENTACULAR", "Блокувати Щупальцевий жах")
ZO_CreateStringId("OW_MENU_TENTACULAR_TOOLTIP", "Блокує навичку Щупальцевий жах до виконання умов.")

-- == Execute Check Settings ==========================================
ZO_CreateStringId("OW_MENU_EXECUTE_HEADER", "Перевірка добивання")
ZO_CreateStringId("OW_MENU_EXECUTE_ENABLE", "Увімкнути перевірку добивання")
ZO_CreateStringId("OW_MENU_EXECUTE_ENABLE_TOOLTIP", "Увімкнути або вимкнути функцію перевірки добивання")
ZO_CreateStringId("OW_MENU_EXECUTE_THRESHOLD", "Поріг добивання (%)")
ZO_CreateStringId("OW_MENU_EXECUTE_THRESHOLD_TOOLTIP", "Відсоток здоров'я цілі, нижче якого дозволені заклинання добивання")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELLS_HEADER", "Заклинання добивання")

-- Grouped Execute Spells
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_RADIANTMORPHS", "Сяйливе Руйнування, Сяйлива Слава, Сяйливе Потучення")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_RADIANTMORPHS_TOOLTIP", "Блокує морфи Сяйливого Руйнування, поки ціль не досягне межі добивання")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_ASSASSINSBLADEMORPHS", "Клинок Вбивці, Проколоти, Клинок Вбивці")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_ASSASSINSBLADEMORPHS_TOOLTIP", "Блокує морфи Клинка Вбивці, поки ціль не досягне межі добивання")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_MAGESFURYMORPHS", "Гнів магів, Лють магів, Нескінченна лють")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_MAGESFURYMORPHS_TOOLTIP", "Блокує морфи Лють магів, поки ціль не досягне межі добивання")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_REVERSESLASHMORPHS", "Зворотний розріз, Зворотний удар, Кат")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_REVERSESLASHMORPHS_TOOLTIP", "Блокує морфи Зворотного розрізу, поки ціль не досягне межі добивання")

-- == Work in progress ================================================
ZO_CreateStringId("OW_WIP", "В розробці")

-- =============================================================================
-- == WEAPON SETTINGS ==========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEADER", "Вимкнення за типом зброї")

ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_WEAPON", "Вимкнути асистент плетіння для типу зброї")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_WEAPON_TOOLTIP", "Вимкає лише асистент плетіння (керування GCD) для вибраних типів зброї")

ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_WEAPON", "Вимкнути функції для типу зброї")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_WEAPON_TOOLTIP", "Вимкає більшість функцій аддону для вибраних типів зброї")

-- Одноручна зброя
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_AXE", "Сокира")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_AXE_TOOLTIP", "Вимкнути при екіпіруванні сокири")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HAMMER", "Молот")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HAMMER_TOOLTIP", "Вимкнути при екіпіруванні молота")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SWORD", "Меч")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SWORD_TOOLTIP", "Вимкнути при екіпіруванні меча")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_DAGGER", "Кинджал")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_DAGGER_TOOLTIP", "Вимкнути при екіпіруванні кинджала")

-- Дворучна зброя
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_SWORD", "Дворучний меч")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_SWORD_TOOLTIP", "Вимкнути при екіпіруванні дворучного меча")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_AXE", "Дворучна сокира")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_AXE_TOOLTIP", "Вимкнути при екіпіруванні дворучної сокири")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_HAMMER", "Дворучний молот")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_HAMMER_TOOLTIP", "Вимкнути при екіпіруванні дворучного молота")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_BOW", "Лук")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_BOW_TOOLTIP", "Вимкнути при екіпіруванні лука")

-- Жезли
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FIRE_STAFF", "Вогняний жезл")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FIRE_STAFF_TOOLTIP", "Вимкнути при екіпіруванні вогняного жезла")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FROST_STAFF", "Крижаний жезл")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FROST_STAFF_TOOLTIP", "Вимкнути при екіпіруванні крижаного жезла")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_LIGHTNING_STAFF", "Жезл блискавки")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_LIGHTNING_STAFF_TOOLTIP", "Вимкнути при екіпіруванні жезла блискавки")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEALING_STAFF", "Цілющий жезл")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEALING_STAFF_TOOLTIP", "Вимкнути при екіпіруванні цілющего жезла")

-- Інша зброя
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SHIELD", "Щит")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SHIELD_TOOLTIP", "Вимкнути при екіпіруванні щита")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RUNE", "Руна")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RUNE_TOOLTIP", "Вимкнути при екіпіруванні руни")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_NONE", "Без зброї")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_NONE_TOOLTIP", "Вимкнути при відсутності зброї")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RESERVED", "Резервна зброя")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RESERVED_TOOLTIP", "Вимкнути при екіпіруванні резервного типу зброї")

-- =============================================================================
-- == CUSTOM BLOCK LIST SETTINGS ===============================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKLIST_HEADER", "Користувацькі списки блокування")
ZO_CreateStringId("OW_MENU_CONFIGURABLEBLOCK_HEADER", "Користувацький список блокування")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_DESC", "Додайте ID здібностей, щоб заблокувати їх використання. Ви також можете додати здібності, клацнувши правою кнопкою миші на слоті панелі дій (потрібно перезавантаження інтерфейсу)")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SPELLID_LABEL", "ID Здібності")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SPELLID_TOOLTIP", "Введіть числовий ID здібності (напр. 185805)")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_ADD_BUTTON", "Додати до списку блокування")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_LIST_HEADER", "Заблоковані здібності:")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST", "Увімкнути користувацький список блокування")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_TOOLTIP", "Увімкнути або вимкнути функціональність користувацького списку блокування")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SV_DESC", "Перевірте ваш файл SavedVariables:\n customBlockList = {\n   [AbilityID] = false/true\n }")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_HEALTH_CHECK", "Увімкнути перевірку здоров'я для списку блокування")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_HEALTH_CHECK_TOOLTIP", "Якщо увімкнено, здібності в списку блокування будуть блокуватися лише тоді, коли ваше здоров'я вище порогу.")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_HEALTH_PERCENT", "Поріг здоров'я для списку блокування (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_HEALTH_PERCENT_TOOLTIP", "Здібності зі списку блокування блокуються лише тоді, коли ваше здоров'я вище цього відсотка.")

-- =============================================================================
-- == CUSTOM RECAST BLOCK LIST SETTINGS ========================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CONFIGURABLERECASTBLOCK_HEADER", "Користувацький список блокування повторного застосування")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_DESC", "Додайте ID здібностей, щоб заблокувати їх повторне застосування, доки залишковий час ефекту не стане нижче порогу. Ви також можете додати здібності, клацнувши правою кнопкою миші на слоті панелі дій (потрібно перезавантаження інтерфейсу).")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SPELLID_LABEL", "ID Здібності")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SPELLID_TOOLTIP", "Введіть числовий ID здібності (напр. 185805)")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_ADD_BUTTON", "Додати до списку блокування повторного застосування")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_LIST_HEADER", "Здібності, заблоковані для повторного застосування:")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST", "Увімкнути користувацький список блокування повторного застосування")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_TOOLTIP", "Увімкнути або вимкнути функціональність користувацького списку блокування повторного застосування")
ZO_CreateStringId("OW_MENU_RECAST_BLOCK_TIME", "Час блокування повторного застосування (с)")
ZO_CreateStringId("OW_MENU_RECAST_BLOCK_TIME_TOOLTIP", "Час у секундах, нижче якого здібність зі списку блокування повторного застосування може бути застосована знову (1.0 = 1 секунда)")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SV_DESC", "Перевірте ваш файл SavedVariables:\n customRecastBlockList = {\n   [AbilityID] = false/true\n }")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_HEALTH_CHECK", "Увімкнути перевірку здоров'я для списку блокування повторного застосування")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_HEALTH_CHECK_TOOLTIP", "Якщо увімкнено, здібності в списку блокування повторного застосування будуть блокуватися лише тоді, коли ваше здоров'я вище порогу.")
ZO_CreateStringId("OW_MENU_CUSTOM_RECAST_BLOCK_LIST_HEALTH_PERCENT", "Поріг здоров'я для списку блокування повторного застосування (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_RECAST_BLOCK_LIST_HEALTH_PERCENT_TOOLTIP", "Здібності зі списку блокування повторного застосування блокуються лише тоді, коли ваше здоров'я вище цього відсотка.")

-- =============================================================================

ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_MAIN_TEXT", "ID здібності було додано/видалено. Якщо ви не бажаєте додавати або видаляти інші здібності, будь ласка, перезавантажте інтерфейс, щоб зміни відобразилися.")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_BUTTON_YES", "Перезавантажити інтерфейс")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_BUTTON_LATER", "Пізніше")

ZO_CreateStringId("OW_MENU_DIALOG_BUTTON_OK", "OK")
ZO_CreateStringId("OW_MENU_INVALID_ID_DIALOG_MAIN_TEXT", "Помилка: Введіть коректний ID здібності")
ZO_CreateStringId("OW_MENU_ID_NOT_EXIST_DIALOG_MAIN_TEXT", "ID здібності не існує")
ZO_CreateStringId("OW_MENU_ID_IS_IN_SV_DIALOG_MAIN_TEXT", "ID здібності вже у списку блокування")

-- =============================================================================
-- == RESOURCE-BASED BLOCK LIST SETTINGS =======================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CONFIGURABLEBLOCK_RESOURCE_HEADER", "Список блокування на основі ресурсів")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_RESOURCE_DESC", "Додайте ID здібностей, щоб блокувати їх, коли ваш основний ресурс (Магія або Витривалість) нижче порогу. Ви також можете додавати здібності, клацнувши правою кнопкою миші на слоті панелі дій (потрібне перезавантаження інтерфейсу).")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RESOURCE_BLOCK_LIST", "Увімкнути список блокування на основі ресурсів")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RESOURCE_BLOCK_LIST_TOOLTIP", "Увімкнути або вимкнути функціональність списку блокування на основі ресурсів")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_RESOURCE_CHECK", "Увімкнути перевірку ресурсу")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_RESOURCE_CHECK_TOOLTIP", "Якщо увімкнено, здібності в списку блокування ресурсів будуть блокуватися лише тоді, коли ваш основний ресурс (Магія або Витривалість) вище порогу.")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_RESOURCE_PERCENT", "Поріг ресурсу (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_RESOURCE_PERCENT_TOOLTIP", "Здібності в списку блокування ресурсів блокуються лише тоді, коли ваш основний ресурс (Магія або Витривалість) вище цього відсотка.")
ZO_CreateStringId("OW_MENU_RESOURCE_BLOCK_SPELL", "Здібність: ")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_CHECK", "Перевірка Магії")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_CHECK_TOOLTIP", "Увімкнути блокування на основі Магії для цієї здібності")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_BLOCK_MODE", "Блокувати, коли Магія нижче порогу")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_BLOCK_MODE_TOOLTIP", "Блокувати здібність, коли Магія нижче порогу (зніміть прапорець, щоб дозволяти лише коли нижче)")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_THRESHOLD", "Поріг Магії (%)")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_THRESHOLD_TOOLTIP", "Пороговий відсоток Магії")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_CHECK", "Перевірка Витривалості")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_CHECK_TOOLTIP", "Увімкнути блокування на основі Витривалості для цієї здібності")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_BLOCK_MODE", "Блокувати, коли Витривалість нижче порогу")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_BLOCK_MODE_TOOLTIP", "Блокувати здібність, коли Витривалість нижче порогу (зніміть прапорець, щоб дозволяти лише коли нижче)")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_THRESHOLD", "Поріг Витривалості (%)")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_THRESHOLD_TOOLTIP", "Пороговий відсоток Витривалості")

-- =============================================================================
-- == KEYBINDINGS LOCALIZATION =================================================
-- =============================================================================

ZO_CreateStringId("SI_KEYBINDINGS_CATEGORY_OPTIMALWEAVE", "|c6D6D6DOpti|r|c8A8A8AmalWea|r|cC4C4C4ve|r")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_MODE", "Перемкнути режим (Суворий/Розумний/Відсутній)")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_CUSTOM_BLOCK_LIST", "Перемкнути користувацький список блокування")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_CUSTOM_RECAST_BLOCK_LIST", "Перемкнути користувацький список блокування повторного застосування")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_BACKBAR_FEATURES", "Перемкнути вимкнення функцій другої панелі")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_BACKBAR_WEAVE_ASSIST", "Перемкнути вимкнення асистента плетіння на другій панелі")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_EXECUTE_CHECK", "Перемкнути перевірку добивання")

-- =============================================================================
-- == REMOVE BUTTON ============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_REMOVE_BUTTON", "Видалити")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_REMOVE_TOOLTIP", "Видалити цю здібність зі списку блокування (потрібне /reloadui)")

-- =============================================================================
-- == SETTIINGS MODE ===========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_MODE_SELECTION_LABEL", "Режим налаштувань")
ZO_CreateStringId("OW_MENU_MODE_SELECTION_TOOLTIP", "Виберіть, чи будуть налаштування спільними для всіх персонажів цього облікового запису (Загальний для облікового запису), чи зберігатимуться окремо для кожного персонажа (Для персонажа).")
ZO_CreateStringId("OW_MENU_MODE_ACCOUNTWIDE", "Загальний для облікового запису")
ZO_CreateStringId("OW_MENU_MODE_PERCHARACTER", "Для персонажа")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_SETTINGS_MAIN_TEXT", "Режим налаштувань змінено. Перезавантажити інтерфейс, щоб застосувати зміни?")

-- =============================================================================
-- == IN COMBAT MENU BLOCKING ==================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCK_LAST_MENU", "Блокувати останнє меню в бою")
ZO_CreateStringId("OW_MENU_BLOCK_LAST_MENU_TOOLTIP", "Запобігає відкриттю останнього меню (ALT) під час бою.")
ZO_CreateStringId("OW_MENU_BLOCK_CHAR_MENU", "Блокувати меню персонажа в бою")
ZO_CreateStringId("OW_MENU_BLOCK_CHAR_MENU_TOOLTIP", "Запобігає відкриттю меню персонажа (C) під час бою.")

-- =============================================================================
-- == GCD DISPLAY ==============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_SHOW_GCD_LABEL", "Показувати глобальний час відновлення (GCD)")
ZO_CreateStringId("OW_MENU_SHOW_GCD_TOOLTIP", "Відображає індикатор GCD (наданий ZOS) над панеллю дій.")

-- =============================================================================
-- == BLOCKLIST COMBAT ONLY ====================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKLISTS_COMBAT_ONLY_LABEL", "Списки блокування тільки в бою")
ZO_CreateStringId("OW_MENU_BLOCKLISTS_COMBAT_ONLY_TOOLTIP", "Усі спеціальні списки блокування активні лише під час бою. Поза боєм усі списки блокування вимкнено.")

-- =============================================================================
-- === END OF UKRAINIAN LOCALIZATION ===========================================
-- =============================================================================