local strings = {

    -----------
    -- Menu
    GG_MENU_LE_HEADER = "Напоминания о сроке действия находок",
    GG_MENU_LE_DESC = "Напоминания срабатывают, когда игрок меняет локацию. Находки, срок действия которых истекает в указанный период, вызовут напоминание. После показа напоминания уведомления будут приостановлены на заданный интервал.",
    GG_MENU_LE_ENABLED = "Включено",
    GG_MENU_LE_ENABLED_TT = "Включить напоминания о сроке действия находок?",
    GG_MENU_LE_ANNOUNCE_REMINDERS = "Показывать уведомления",
    GG_MENU_LE_ANNOUNCE_REMINDERS_TT = "Показывать уведомления на экране о сроке действия находок?",
    GG_MENU_LE_CHAT_REMINDERS = "Показывать напоминания в чате",
    GG_MENU_LE_CHAT_REMINDERS_TT = "Показывать напоминания в окне чата?",
    GG_MENU_LE_WARNING_PERIOD = "Период предупреждения (дни) [1–20]",
    GG_MENU_LE_WARNING_PERIOD_TT = "За сколько дней до истечения срока действия находки начинать напоминания.",
    GG_MENU_LE_NO_WARNING_PERIOD = "Интервал без напоминаний (минуты) [1–120]",
    GG_MENU_LE_NO_WARNING_PERIOD_TT = "Интервал в секундах между напоминаниями.",
    GG_MENU_GF_HEADER = "Уведомления о записях в Поиске группы",
    GG_MENU_GF_ENABLED = "Включено",
    GG_MENU_GF_ENABLED_TT = "Включить уведомления Поиска группы в окне чата?",
    GG_MENU_GF_CHECK_INTERVAL = "Интервал проверки (секунды) [5–60]",
    GG_MENU_GF_CHECK_INTERVAL_TT = "Интервал в секундах для проверки Поиска группы на новые объявления о Испытаниях. Минимум 5 секунд, максимум 60 секунд.",
    GG_MENU_GF_TRIAL_HEADER = "Испытания для уведомлений из Поиска группы",
    GG_MENU_GF_TRIAL_DESC = "Обратите внимание: объявления, созданные с параметром «Любое испытание», также будут включены в уведомления.",
    GG_MENU_GF_TRIAL_TT = "Включать объявления %s из Поиска группы?",
    GG_MENU_PA_HEADER = "Интеграция Personal Assistant",
    GG_MENU_PA_DESC = "Требования:\n- Аддоны: LibCharacterKnowledge, LibPrice (и активный источник цен, например TamrielTradeCentre, Master Merchant или Arkadius' Trade Tools)\n- Отдельный LOOT-профиль Personal Assistant для Торговца, чтобы излишки и предметы на продажу НЕ изучались автоматически при снятии из банка.\n\nПравила маршрутизации:\n1. Предметы, неизвестные Ремесленнику → отправляются Ремесленнику\n2. Дешёвые предметы направляются следующему персонажу согласно LibCharacterKnowledge\n3. Излишки и дорогие предметы отправляются Торговцу (если включено), иначе остаются в банке.",
    GG_MENU_PA_ENABLED = "Включено?",
    GG_MENU_PA_ENABLED_TT = "Включено ли переопределение Personal Assistant? Отключение требует перезагрузки интерфейса.",
    GG_MENU_PA_SALE_VALUE_THRESHOLD = "Порог стоимости продажи",
    GG_MENU_PA_SALE_VALUE_THRESHOLD_TT = "Предметы со стоимостью продажи ниже или равной этому порогу считаются дешёвыми.",
    GG_MENU_PA_CRAFTER_CHARACTER_NAME = "Имя Ремесленника",
    GG_MENU_PA_CRAFTER_CHARACTER_NAME_TT = "Имя персонажа, выполняющего роль Ремесленника.",
    GG_MENU_PA_TRADER_CHARACTER_NAME = "Имя Торговца",
    GG_MENU_PA_TRADER_CHARACTER_NAME_TT = "Имя персонажа, выполняющего роль Торговца.",
    GG_MENU_PA_WITHDRAW_TO_TRADER_ENABLED = "Снимать Торговцу?",
    GG_MENU_PA_WITHDRAW_TO_TRADER_ENABLED_TT = "Излишки снимаются из банка Торговцу.",

    -----------
    -- core
    GG_LAM_NOT_FOUND = "LibAddonMenu2 не найден, невозможно создать меню.",
    GG_CHARACTERS = "Персонажи",
    GG_SHOW_WINDOW = "Показать окно",
    GG_TOGGLE_LOCATION_TRACKER = "Переключить отслеживание смены локации",
    GG_REMAINING = " Осталось",
    GG_ELAPSED = " Прошло",

    -----------
    -- Lead Expiry
    GG_LE_NEW_LEAD = "Новый/Неоткрытый след",
    GG_LE_LEAD = "След",
    GG_LE_LORE_LEAD = "Незавершённый кодекс/лоровый след",
    GG_LE_EXPIRY_IN = " Истекает через ",
    GG_LE_EXPIRING_IN = "След истекает через ",
    GG_LE_FOUND_IN = " найден в ",
    GG_LE_UNKNOWN_NAME = "Неизвестная наводка",
    GG_LE_UNKNOWN_ZONE = "Неизвестная зона",
    GG_LE_REMIND = "НАП.", 
    GG_LE_IGNORE = "ИГН.",
    GG_LE_DISABLE_REMINDER = "Отключить напоминание",
    GG_LE_ENABLE_REMINDER = "Включить напоминание",
    GG_LE_TOGGLE_REMINDER = "Переключить напоминание",

    -----------
    -- Group Finder
    GG_GF_NEW_LISTING = "Новая запись",
    GG_GF_UPDATED_LISTING = "Обновлённая запись",
    GG_GF_REMOVED_LISTING = "Удалённая запись",
    GG_GF_NO_LISTING = "Поиск группы: |cff0000Записей не найдено.|r Уведомление появится, когда запись будет найдена.",

    -----------
    -- Location Change
    GG_LOCATION_CHANGED = "Локация изменена",
    GG_LOCATION_ENABLED = "Отслеживание смены локации включено",
    GG_LOCATION_DISABLED = "Отслеживание смены локации отключено",

    -----------
    -- Night Market
    GG_NM_MENU_ELMS_GUIDANCE_HEADER = "Подсказки по целям квестов Ночного рынка",
    GG_NM_MENU_BLUE_MARKERS = "Синие маркеры показывают возможное место начала квеста.",
    GG_NM_MENU_GREEN_MARKERS = "Зелёные маркеры показывают возможное место цели квеста.",
    GG_NM_MENU_NOTE_ON_ELMS = "Примечание: чтобы эти маркеры отображались, необходимо установить и включить ElmsMarkers.",
    GG_NM_MENU_QUEST_LIST_HDR = "Номера соответствуют следующим квестам.",
    GG_NM_MENU_HIDE_TRACKER = "Скрыть трекер очков фракций",
    GG_NM_MENU_HIDE_TRACKER_TT = "Скрывает на экране очки фракций Ночного рынка.",
    GG_NM_MENU_ELMS_ENABLE = "Включить добавление маркеров в ElmsMarkers?",
    GG_NM_MENU_ELMS_ENABLE_TT = "Добавляет 3D-маркеры в ElmsMarkers для квестов Ночного рынка.",
    GG_NM_GROUP_AUTO = "Автоматизация группы Argent",
    GG_NM_GROUP_AUTO_OFF = "ВЫКЛ",
    GG_NM_GROUP_AUTO_ON = "ВКЛ",
    GG_NM_GROUP_AUTO_ERROR_NOTINZONE = "Вы не в зоне события",
    GG_NM_GROUP_AUTO_ERROR_ZONENOTACTIVE = "Зона события не активна",
    GG_NM_GROUP_AUTO_ERROR_FAILEDTWICE = "Создание объявления в Поиске группы дважды не удалось",
    GG_NM_GROUP_AUTO_ALLDONE = "Все ключи получены",
    GG_NM_GROUP_AUTO_LISTINGREMOVED = "Объявление удалено",
    GG_NM_GROUP_AUTO_QUESTSHARE1 = "Поделено",
    GG_NM_GROUP_AUTO_QUESTSHARE2 = "квест(ов) с группой.",
    GG_NM_GROUP_AUTOMATION_KEYBIND = "Переключить автоматизацию группы Argent",

    -----------
    -- Time
    GG_TIME_SECONDS = "секунд",
    GG_TIME_MINUTES = "минут",
    GG_TIME_HOURS = "часов",
    GG_TIME_DAYS = "дней",
    GG_TIME_NONE = "Нет",

}

for id, val in pairs(strings) do
   ZO_CreateStringId(id, val)
   SafeAddVersion(id, 1)
end