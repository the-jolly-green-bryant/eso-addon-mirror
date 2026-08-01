-- =============================================================================
-- === OptimalWeave Language File: Russian (ru.lua)                          ===
-- =============================================================================
--[[
    AddOn Name:         OptimalWeave
    File:               lang/ru.lua
    Description:        Russian localization using ZO_CreateStringId
    Version:            1.17.0
    Author:             Orollas & VollständigerName
--]]
-- =============================================================================

-- =============================================================================
-- == PANEL & AUTHOR INFORMATION ==============================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_PANEL_NAME", "|c6D6D6DOp|r|c8A8A8Atim|r|cA7A7A7al |r|cC4C4C4Wea|r|c6D6D6Dve|r")
ZO_CreateStringId("OW_MENU_AUTHORS", "|cEE82EEO|r|cDD74ECr|r|cCD65EAo|r|cBC57E8l|r|cAB48E6l|r|c9B3AE4a|r|c8A2BE2s|r & |cFFD700Vo|r|cF7D418l|r|cF3D324l|r|cEFD130s|r|cEBD03Ctä|r|cE3CD54n|r|cE0CC60d|r|cDCCA6Ci|r|cD8C978g|r|cD4C784e|r|cD0C690r|r|cCCC49CNa|r|cC4C1B4me|r")
ZO_CreateStringId("OW_MENU_WEBSITE", "https://github.com/VollstaendigerName")

-- =============================================================================
-- == INFORMATION SECTION ======================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_INFO_HEADER", "Информация & Советы")
ZO_CreateStringId("OW_MENU_INFO_TEXT", "Глобальная перезарядка (GCD) 1000мс. OptimalWeave помогает управлять очередью способностей. Настройте поведение ниже.")
ZO_CreateStringId("OW_MENU_MODE_HEADER", "Основные Настройки")
ZO_CreateStringId("OW_MENU_CONDITIONS_HEADER", "Правила Активации")
ZO_CreateStringId("OW_MENU_ADVANCED_HEADER", "Расширенное Управление")
ZO_CreateStringId("OW_MENU_PERFORMANCE_HEADER", "Настройки Производительности")
ZO_CreateStringId("OW_MENU_MODE_ACTIVE", "Аддон активен")
ZO_CreateStringId("OW_MENU_MODE_INACTIVE", "Аддон неактивен")
ZO_CreateStringId("OW_MENU_DISABLED_TOOLTIP", "Эта опция отключена")
ZO_CreateStringId("OW_MENU_LATENCY_WARNING", "Внимание: Высокая задержка может замедлить ввод!")

ZO_CreateStringId("OW_MENU_DISCLAIMER_LABEL", "|cFF0000Примечание|r") 
ZO_CreateStringId("OW_MENU_DISCLAIMER_TOOLTIP",  "|cFF0000Отказ от ответственности:|r Данный аддон не связан с ZeniMax Media Inc. The Elder Scrolls® — зарегистрированная торговая марка ZeniMax Media Inc. Все права защищены.")

-- =============================================================================
-- == CORE SETTINGS ===========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_SETTINGS_HEADER", "Основные Настройки")
ZO_CreateStringId("OW_MENU_MODE_LABEL", "Режим Работы")
ZO_CreateStringId("OW_MENU_MODE_TOOLTIP", "|c00FF00Последовательный:|r Позволяет использовать способности только после лёгкой атаки.\n|cFF0000Строгий:|r Полная блокировка.\n|cFFFF00Умный:|r Очередь без легкой атаки.\n|c00FFFFНет:|r Отключено.")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_COND", "Последовательный")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_HARD", "Строгий")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_SOFT", "Умный")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_NONE", "Нет")
ZO_CreateStringId("OW_MENU_COMBAT_LABEL", "Только в Бою")
ZO_CreateStringId("OW_MENU_COMBAT_TOOLTIP", "Активно только во время боя.")
ZO_CreateStringId("OW_MENU_ENEMYTARGET_LABEL", "Только с Вражеской Целью")
ZO_CreateStringId("OW_MENU_ENEMYTARGET_TOOLTIP", "Требует выбора вражеской цели.")
ZO_CreateStringId("OW_MENU_BLOCKING_LABEL", "Игнорировать Блокировку")
ZO_CreateStringId("OW_MENU_BLOCKING_TOOLTIP", "Отключает управление при блокировке.")
ZO_CreateStringId("OW_MENU_GROUNDAOE_LABEL", "Блокировать Двойные AoE")
ZO_CreateStringId("OW_MENU_GROUNDAOE_TOOLTIP", "Предотвращает двойное применение способностей.")
ZO_CreateStringId("OW_MENU_DISABLE_TANK", "Отключить как Танк")
ZO_CreateStringId("OW_MENU_DISABLE_TANK_TOOLTIP", "Автоотключение в роли Танка")
ZO_CreateStringId("OW_MENU_DISABLE_HEAL", "Отключить как Лекарь")
ZO_CreateStringId("OW_MENU_DISABLE_HEAL_TOOLTIP", "Автоотключение в роли Лекаря")

ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_BACKBAR", "Отключить функции на второй панели")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_BACKBAR_TOOLTIP", "Отключает большинство функций аддона на второй панели оружия.")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_BACKBAR", "Отключить ассистент плетения на второй панели")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_BACKBAR_TOOLTIP", "Отключает ассистент плетения (управление GCD) на второй панели оружия.")

ZO_CreateStringId("OW_MENU_DEACTIVATE_IN_PVP_HEADER", "Отключение в PvP")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_IN_PVP", "Отключить функции в PvP")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_IN_PVP_TOOLTIP", "Отключает большинство функций аддона в PvP-зонах")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_IN_PVP", "Отключить помощник плетения в PvP")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_IN_PVP_TOOLTIP", "Отключает помощник плетения (управление GCD) в PvP-зонах")

-- =============================================================================
-- == BLOCK ID SETTINGS =======================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKED_HEADER", "Заблокированные Способности")
ZO_CreateStringId("OW_MENU_BLOCKED_ADD_LABEL", "Заблокировать Новый ID")
ZO_CreateStringId("OW_MENU_BLOCKED_ADD_TOOLTIP", "Введите ID способности (напр. 134160)")
ZO_CreateStringId("OW_MENU_BLOCKED_LIST_LABEL", "Текущие ID")
ZO_CreateStringId("OW_MENU_BLOCKED_LIST_TOOLTIP", "Кликните для удаления")

-- =============================================================================
-- == ADVANCED SETTINGS =======================================================
-- =============================================================================
ZO_CreateStringId("OW_MENU_CHANNEL_NORMAL", "Буфер Мгновенных (мс)")
ZO_CreateStringId("OW_MENU_CHANNEL_NORMAL_TOOLTIP", "Запас для мгновенных способностей (0-100мс)")
ZO_CreateStringId("OW_MENU_CHANNEL_CHANNELED", "Буфер Канальных (мс)")
ZO_CreateStringId("OW_MENU_CHANNEL_CHANNELED_TOOLTIP", "Запас для канальных способностей (0-400мс)")
ZO_CreateStringId("OW_MENU_GCD_SLOT", "Слот Отслеживания GCD")
ZO_CreateStringId("OW_MENU_GCD_SLOT_TOOLTIP", "Слот панели для GCD (1-8)")
ZO_CreateStringId("OW_MENU_RESET_TIME_LABEL", "Время сброса (секунды)")
ZO_CreateStringId("OW_MENU_RESET_TIME_TOOLTIP", "Сбрасывает отслеживание, если ничего не применялось в течение этого количества секунд.")
ZO_CreateStringId("OW_MENU_AUTO_GCD_SLOT_LABEL", "Автоматический слот отслеживания GCD")
ZO_CreateStringId("OW_MENU_AUTO_GCD_SLOT_TOOLTIP", "Автоматически выбирает лучший слот для отслеживания GCD из слотов 3-8")
ZO_CreateStringId("OW_MENU_MIN_GCD", "Минимальный GCD (мс)")
ZO_CreateStringId("OW_MENU_MIN_GCD_TOOLTIP", "Минимальная длительность GCD (0-20мс)")
ZO_CreateStringId("OW_MENU_QUEUE_TIME", "Базовое Время Очереди (мс)")
ZO_CreateStringId("OW_MENU_QUEUE_TIME_TOOLTIP", "Окно очереди по умолчанию (100-2000мс)")
ZO_CreateStringId("OW_MENU_RESETONBARSWAP_LABEL", "Сброс при смене оружия")
ZO_CreateStringId("OW_MENU_RESETONBARSWAP_TOOLTIP", "Сбрасывает GCD при смене оружия")
ZO_CreateStringId("OW_MENU_RESETONDODGE_LABEL", "Сброс при уклонении")
ZO_CreateStringId("OW_MENU_RESETONDODGE_TOOLTIP", "Сбрасывает GCD при выполнении переката")
ZO_CreateStringId("OW_MENU_AUTO_EQUIP_WEAPONS_LABEL", "Автоматически доставать оружие")
ZO_CreateStringId("OW_MENU_AUTO_EQUIP_WEAPONS_TOOLTIP", "Автоматически доставать оружие в бою")
ZO_CreateStringId("OW_MENU_RESET_SETTINGS_LABEL", "Сбросить всё")
ZO_CreateStringId("OW_MENU_RESET_SETTINGS_TOOLTIP", "Сбросить все настройки к значениям по умолчанию")

-- =============================================================================
-- == LATENCY COMPENSATION ====================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_LATENCY_HEADER", "Компенсация Задержки")
ZO_CreateStringId("OW_MENU_AUTOLATENCY_LABEL", "Автонастройка")
ZO_CreateStringId("OW_MENU_AUTOLATENCY_TOOLTIP", "Автоматическая регулировка задержки.")
ZO_CreateStringId("OW_MENU_MANUALLATENCY_LABEL", "Ручная Задержка (мс)")
ZO_CreateStringId("OW_MENU_MANUALLATENCY_TOOLTIP", "Фиксированное значение (0-200мс).")

-- =============================================================================
-- == (SUB)CLASS SETTINGS ======================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_SUBCLASS_HEADER", "Настройки классов и гильдий")

ZO_CreateStringId("OW_MENU_SUBCLASS_GRIMFOCUS", "Мрачный Фокус")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_STACKS", "Необходимые стаки")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_STACKS_TOOLTIP", "Количество стаков, необходимое для активации Мрачного Фокуса (Рекомендуется: 10)")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_ALL_MORPHS", "Блокировать все морфы Мрачного Фокуса")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_ALL_MORPHS_TOOLTIP", "|cFF5555• Неутомимый Фокус:|r Всегда блокируется\n|cFFFF00• Мрачный Фокус и Безжалостная Решимость:|r Доступен только при 10 стаках\n|cAAAAAAОтключить:|r Поведение по умолчанию для всех морфов")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_GRIMFOCUSSTACKS_TOOGLE", "Активировать пользовательские стаки")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_GRIMFOCUSSTACKS_TOOGLE_TOOLTIP", "|cFFD700Включено:|r Использует настройку стака \n|cAAAAAAОтключено:|r Всегда блокирует Мрачный Фокус и Безжалостную Решимость до 10 стаков, а также всегда блокирует Неутомимый Фокус\n")

-- == BLOCK GUILDS SETTINGS ===================================================
ZO_CreateStringId("OW_MENU_SUBCLASS_GUILDS", "Гильдии")
ZO_CreateStringId("OW_MENU_HUNTER_ALL_MORPHS", "Блокировать навыки охотника Гильдии воинов")
ZO_CreateStringId("OW_MENU_HUNTER_ALL_MORPHS_TOOLTIP", "Блокирует все морфы навыков охотника Гильдии воинов (Опытный охотник, Замаскированный охотник & Свирепый охотник)")
ZO_CreateStringId("OW_MENU_LIGHT_ALL_MORPHS", "Блокировать световые навыки Гильдии магов")
ZO_CreateStringId("OW_MENU_LIGHT_ALL_MORPHS_TOOLTIP", "Блокирует все морфы световых навыков (Волшебный свет, Внутренний свет & Сияющий волшебный свет)")

ZO_CreateStringId("OW_MENU_DEACTIVATEHUNTERLIGHTINPVP_ALL_MORPHS", "Отключить в PvP")
ZO_CreateStringId("OW_MENU_DEACTIVATEHUNTERLIGHTINPVP_ALL_MORPHS_TOOLTIP", "Отключает блокировку способностей Охотника/Света в PvP-зонах")

-- == BLOCK MOLTEN WHIP SETTINGS ===============================================
ZO_CreateStringId("OW_MENU_SUBCLASS_MOLTENWHIP", "Лавовый Хлыст")
ZO_CreateStringId("OW_MENU_MOLTENWHIP_BLOCK", "Блокировать навык Лавовый Хлыст")
ZO_CreateStringId("OW_MENU_MOLTENWHIP_BLOCK_TOOLTIP", "Блокирует навык Лавовый Хлыст, чтобы не потерять три стака")

-- == BLOCK FATECARVER SETTINGS ================================================
ZO_CreateStringId("OW_MENU_SUBCLASS_FATECARVER", "Arcanist Fatecarver")
ZO_CreateStringId("OW_MENU_FATECARVER_ALL_MORPHS", "Блокировать Fatecarver")
ZO_CreateStringId("OW_MENU_FATECARVER_ALL_MORPHS_TOOLTIP", "Блокирует применение Fatecarver до выполнения условий.")
ZO_CreateStringId("OW_MENU_CRUX_STACKS", "Необходимые стаки Crux")
ZO_CreateStringId("OW_MENU_CRUX_STACKS_TOOLTIP", "Минимальные стаки Crux для применения Fatecarver (Рекомендуется: 3)")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM", "Порог HP (%)")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOLTIP", "Отключить блокировку Fatecarver при HP ниже этого значения")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOGLE", "Включить проверку HP для Fatecarver")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOGLE_TOOLTIP", "Отключает блокировку Fatecarver при низком здоровье")

ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM", "Порог Выносливости (%)")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOLTIP", "Отключить блокировку Fatecarver при низкой выносливости")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOGLE", "Включить проверку Выносливости для Fatecarver")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOGLE_TOOLTIP", "Отключает блокировку Fatecarver при низкой выносливости")

-- == BLOCK CEPHALIARCH'S FLAIL SETTINGS =======================================
ZO_CreateStringId("OW_MENU_SUBCLASS_CEPHALIARCHSFLAIL", "Бич цефалиарха")
ZO_CreateStringId("OW_MENU_CEPHALIARCHSFLAIL", "Блокировать Бич цефалиарха")
ZO_CreateStringId("OW_MENU_CEPHALIARCHSFLAIL_TOOLTIP", "Блокирует Бич цефалиарха, когда у вас 3 стака Крукса")

-- == BLOCK TENTACULAR DREAD SETTINGS ==========================================
ZO_CreateStringId("OW_MENU_SUBCLASS_TENTACULAR", "Ужасное щупальце")
ZO_CreateStringId("OW_MENU_TENTACULAR", "Блокировать Ужасное щупальце")
ZO_CreateStringId("OW_MENU_TENTACULAR_TOOLTIP", "Блокирует способность Ужасное щупальце до выполнения условий.")

-- == Execute Check Settings ==========================================
ZO_CreateStringId("OW_MENU_EXECUTE_HEADER", "Проверка добивания")
ZO_CreateStringId("OW_MENU_EXECUTE_ENABLE", "Включить проверку добивания")
ZO_CreateStringId("OW_MENU_EXECUTE_ENABLE_TOOLTIP", "Включает или отключает функцию проверки добивания")
ZO_CreateStringId("OW_MENU_EXECUTE_THRESHOLD", "Порог добивания (%)")
ZO_CreateStringId("OW_MENU_EXECUTE_THRESHOLD_TOOLTIP", "Процент здоровья цели, ниже которого разрешены заклинания добивания")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELLS_HEADER", "Заклинания добивания")

-- == Grouped Execute Spells ==========================================
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_RADIANTMORPHS", "Сияющее разрушение, Сияющая слава, Сияющее угнетение")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_RADIANTMORPHS_TOOLTIP", "Блокирует морфы Сияющего разрушения, пока цель не достигнет порога добивания")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_ASSASSINSBLADEMORPHS", "Клинок ассасина, Пронзание, Клинок убийцы")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_ASSASSINSBLADEMORPHS_TOOLTIP", "Блокирует морфы Клинка ассасина, пока цель не достигнет порога добивания")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_MAGESFURYMORPHS", "Гнев магов, Ярость магов, Бесконечная ярость")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_MAGESFURYMORPHS_TOOLTIP", "Блокирует морфы Ярости магов, пока цель не достигнет порога добивания")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_REVERSESLASHMORPHS", "Обратный разрез, Обратный удар, Палач")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_REVERSESLASHMORPHS_TOOLTIP", "Блокирует морфы Обратного разреза, пока цель не достигнет порога добивания")

-- == Work in progress ================================================
ZO_CreateStringId("OW_WIP", "WIP")

-- =============================================================================
-- == WEAPON SETTINGS ==========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEADER", "Отключение по типу оружия")

ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_WEAPON", "Отключить ассистент плетения для типа оружия")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_WEAPON_TOOLTIP", "Отключает только ассистент плетения (управление GCD) для выбранных типов оружия")

ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_WEAPON", "Отключить функции для типа оружия")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_WEAPON_TOOLTIP", "Отключает большинство функций аддона для выбранных типов оружия")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_AXE", "Топор")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_AXE_TOOLTIP", "Отключать при экипировке топора")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HAMMER", "Молот")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HAMMER_TOOLTIP", "Отключать при экипировке молота")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SWORD", "Меч")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SWORD_TOOLTIP", "Отключать при экипировке меча")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_DAGGER", "Кинжал")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_DAGGER_TOOLTIP", "Отключать при экипировке кинжала")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_SWORD", "Двуручный меч")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_SWORD_TOOLTIP", "Отключать при экипировке двуручного меча")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_AXE", "Двуручный топор")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_AXE_TOOLTIP", "Отключать при экипировке двуручного топора")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_HAMMER", "Двуручный молот")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_HAMMER_TOOLTIP", "Отключать при экипировке двуручного молота")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_BOW", "Лук")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_BOW_TOOLTIP", "Отключать при экипировке лука")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FIRE_STAFF", "Огненный посох")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FIRE_STAFF_TOOLTIP", "Отключать при экипировке огненного посоха")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FROST_STAFF", "Ледяной посох")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FROST_STAFF_TOOLTIP", "Отключать при экипировке ледяного посоха")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_LIGHTNING_STAFF", "Посох молний")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_LIGHTNING_STAFF_TOOLTIP", "Отключать при экипировке посоха молний")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEALING_STAFF", "Целительный посох")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEALING_STAFF_TOOLTIP", "Отключать при экипировке целительного посоха")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SHIELD", "Щит")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SHIELD_TOOLTIP", "Отключать при экипировке щита")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RUNE", "Руна")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RUNE_TOOLTIP", "Отключать при экипировке руны")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_NONE", "Без оружия")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_NONE_TOOLTIP", "Отключать при отсутствии оружия")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RESERVED", "Резервное оружие")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RESERVED_TOOLTIP", "Отключать при экипировке резервного типа оружия")

-- =============================================================================
-- == CUSTOM BLOCK LIST SETTINGS ==============================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKLIST_HEADER", "Пользовательские списки блокировки")
ZO_CreateStringId("OW_MENU_CONFIGURABLEBLOCK_HEADER", "Пользовательский список блокировки")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_DESC", "Добавьте ID способностей, чтобы заблокировать их использование. Вы также можете добавить способности, щелкнув правой кнопкой мыши по слоту панели действий (требуется перезагрузка интерфейса)")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SPELLID_LABEL", "ID Способности")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SPELLID_TOOLTIP", "Введите числовой ID способности (напр. 185805)")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_ADD_BUTTON", "Добавить в список блокировки")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_LIST_HEADER", "Заблокированные способности:")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST", "Включить пользовательский список блокировки")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_TOOLTIP", "Включает или отключает функциональность пользовательского списка блокировки")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SV_DESC", "Проверьте ваш файл SavedVariables:\n customBlockList = {\n   [AbilityID] = false/true\n }")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_HEALTH_CHECK", "Включить проверку здоровья для списка блокировки")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_HEALTH_CHECK_TOOLTIP", "Если включено, заклинания в списке блокировки будут блокироваться только если ваше здоровье выше порога.")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_HEALTH_PERCENT", "Порог здоровья для списка блокировки (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_HEALTH_PERCENT_TOOLTIP", "Заклинания из списка блокировки блокируются только когда ваше здоровье выше этого процента.")

-- =============================================================================
-- == CUSTOM RECAST BLOCK LIST SETTINGS =======================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CONFIGURABLERECASTBLOCK_HEADER", "Пользовательский список блокировки повторного применения")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_DESC", "Добавьте ID способностей, чтобы заблокировать их повторное применение, пока оставшееся время эффекта не станет ниже порога. Вы также можете добавить способности, щелкнув правой кнопкой мыши по слоту панели действий (требуется перезагрузка интерфейса).")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SPELLID_LABEL", "ID Способности")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SPELLID_TOOLTIP", "Введите числовой ID способности (напр. 185805)")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_ADD_BUTTON", "Добавить в список блокировки повторного применения")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_LIST_HEADER", "Способности, заблокированные для повторного применения:")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST", "Включить пользовательский список блокировки повторного применения")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_TOOLTIP", "Включает или отключает функциональность пользовательского списка блокировки повторного применения")
ZO_CreateStringId("OW_MENU_RECAST_BLOCK_TIME", "Время блокировки повторного применения (с)")
ZO_CreateStringId("OW_MENU_RECAST_BLOCK_TIME_TOOLTIP", "Время в секундах, ниже которого способность из списка блокировки повторного применения может быть применена снова (1.0 = 1 секунда)")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SV_DESC", "Проверьте ваш файл SavedVariables:\n customRecastBlockList = {\n   [AbilityID] = false/true\n }")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_HEALTH_CHECK", "Включить проверку здоровья для списка блокировки повторного применения")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_HEALTH_CHECK_TOOLTIP", "Если включено, заклинания в списке блокировки повторного применения будут блокироваться только если ваше здоровье выше порога.")
ZO_CreateStringId("OW_MENU_CUSTOM_RECAST_BLOCK_LIST_HEALTH_PERCENT", "Порог здоровья для списка блокировки повторного применения (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_RECAST_BLOCK_LIST_HEALTH_PERCENT_TOOLTIP", "Заклинания из списка блокировки повторного применения блокируются только когда ваше здоровье выше этого процента.")

-- =============================================================================

ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_MAIN_TEXT", "ID способности был добавлен/удален. Если вы не хотите добавлять или удалять другие способности, пожалуйста, перезагрузите интерфейс, чтобы изменения отобразились.")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_BUTTON_YES", "Перезагрузить интерфейс")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_BUTTON_LATER", "Позже")

ZO_CreateStringId("OW_MENU_DIALOG_BUTTON_OK", "OK")
ZO_CreateStringId("OW_MENU_INVALID_ID_DIALOG_MAIN_TEXT", "Ошибка: Введите корректный ID способности")
ZO_CreateStringId("OW_MENU_ID_NOT_EXIST_DIALOG_MAIN_TEXT", "ID способности не существует")
ZO_CreateStringId("OW_MENU_ID_IS_IN_SV_DIALOG_MAIN_TEXT", "ID способности уже в списке блокировки")

-- =============================================================================
-- == RESOURCE-BASED BLOCK LIST SETTINGS =======================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CONFIGURABLEBLOCK_RESOURCE_HEADER", "Блок-лист на основе ресурсов")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_RESOURCE_DESC", "Добавьте ID способностей, чтобы блокировать их, когда ваш основной ресурс (Магия или Выносливость) ниже порога. Вы также можете добавлять способности, щелкнув правой кнопкой мыши по слоту панели действий (требуется перезагрузка интерфейса).")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RESOURCE_BLOCK_LIST", "Включить блок-лист на основе ресурсов")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RESOURCE_BLOCK_LIST_TOOLTIP", "Включить или отключить функциональность блок-листа на основе ресурсов")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_RESOURCE_CHECK", "Включить проверку ресурса")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_RESOURCE_CHECK_TOOLTIP", "Если включено, способности в блок-листе ресурсов будут блокироваться только если ваш основной ресурс (Магия или Выносливость) выше порога.")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_RESOURCE_PERCENT", "Порог ресурса (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_RESOURCE_PERCENT_TOOLTIP", "Способности в блок-листе ресурсов блокируются только когда ваш основной ресурс (Магия или Выносливость) выше этого процента.")
ZO_CreateStringId("OW_MENU_RESOURCE_BLOCK_SPELL", "Способность: ")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_CHECK", "Проверка Магии")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_CHECK_TOOLTIP", "Включить блокировку на основе Магии для этой способности")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_BLOCK_MODE", "Блокировать, когда Магия ниже порога")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_BLOCK_MODE_TOOLTIP", "Блокировать способность, когда Магия ниже порога (снимите флажок, чтобы разрешать только когда ниже)")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_THRESHOLD", "Порог Магии (%)")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_THRESHOLD_TOOLTIP", "Пороговый процент Магии")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_CHECK", "Проверка Выносливости")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_CHECK_TOOLTIP", "Включить блокировку на основе Выносливости для этой способности")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_BLOCK_MODE", "Блокировать, когда Выносливость ниже порога")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_BLOCK_MODE_TOOLTIP", "Блокировать способность, когда Выносливость ниже порога (снимите флажок, чтобы разрешать только когда ниже)")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_THRESHOLD", "Порог Выносливости (%)")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_THRESHOLD_TOOLTIP", "Пороговый процент Выносливости")

-- =============================================================================
-- == KEYBINDINGS LOCALIZATION =================================================
-- =============================================================================

ZO_CreateStringId("SI_KEYBINDINGS_CATEGORY_OPTIMALWEAVE", "|c6D6D6DOpti|r|c8A8A8AmalWea|r|cC4C4C4ve|r")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_MODE", "Переключить режим (Строгий/Умный/Отключено)")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_CUSTOM_BLOCK_LIST", "Переключить пользовательский список блокировки")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_CUSTOM_RECAST_BLOCK_LIST", "Переключить пользовательский список блокировки повторного применения")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_BACKBAR_FEATURES", "Переключить отключение функций второй панели")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_BACKBAR_WEAVE_ASSIST", "Переключить отключение ассистента плетения на второй панели")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_EXECUTE_CHECK", "Переключить проверку добивания")

-- =============================================================================
-- == REMOVE BUTTON ============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_REMOVE_BUTTON", "Удалить")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_REMOVE_TOOLTIP", "Удалить это заклинание из списка блокировки (требуется /reloadui)")

-- =============================================================================
-- == SETTIINGS MODE ===========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_MODE_SELECTION_LABEL", "Режим настроек")
ZO_CreateStringId("OW_MENU_MODE_SELECTION_TOOLTIP", "Выберите, будут ли настройки общими для всех персонажей этой учётной записи (Общий для аккаунта) или сохраняться отдельно для каждого персонажа (Для персонажа).")
ZO_CreateStringId("OW_MENU_MODE_ACCOUNTWIDE", "Общий для аккаунта")
ZO_CreateStringId("OW_MENU_MODE_PERCHARACTER", "Для персонажа")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_SETTINGS_MAIN_TEXT", "Режим настроек изменён. Перезагрузить интерфейс, чтобы применить изменения?")

-- =============================================================================
-- == IN COMBAT MENU BLOCKING ==================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCK_LAST_MENU", "Блокировать последнее меню в бою")
ZO_CreateStringId("OW_MENU_BLOCK_LAST_MENU_TOOLTIP", "Предотвращает открытие последнего меню (ALT) во время боя.")
ZO_CreateStringId("OW_MENU_BLOCK_CHAR_MENU", "Блокировать меню персонажа в бою")
ZO_CreateStringId("OW_MENU_BLOCK_CHAR_MENU_TOOLTIP", "Предотвращает открытие меню персонажа (C) во время боя.")

-- =============================================================================
-- == GCD DISPLAY ==============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_SHOW_GCD_LABEL", "Показывать глобальное время восстановления (GCD)")
ZO_CreateStringId("OW_MENU_SHOW_GCD_TOOLTIP", "Отображает индикатор GCD (предоставленный ZOS) над панелью действий.")

-- =============================================================================
-- == BLOCKLIST COMBAT ONLY ====================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKLISTS_COMBAT_ONLY_LABEL", "Списки блокировки только в бою")
ZO_CreateStringId("OW_MENU_BLOCKLISTS_COMBAT_ONLY_TOOLTIP", "Все пользовательские списки блокировки активны только во время боя. Вне боя все списки блокировки отключены.")

-- =============================================================================
-- === END OF RUSSIAN LOCALIZATION =============================================
-- =============================================================================