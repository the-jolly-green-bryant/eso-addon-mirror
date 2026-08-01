local strings = {
    SI_ACTIVITY_FINDER_PLUS_LANG            = "ru",

    SI_ACTIVITY_FINDER_PLUS_HEADER_LFG    = "Проверка готовности",
    SI_ACTIVITY_FINDER_PLUS_HEADER_FINDER = "Поиск активности",
    SI_ACTIVITY_FINDER_PLUS_HEADER_OTHER  = "Прочее",

    SI_ACTIVITY_FINDER_PLUS_SOUND           = "Улучшенный звук",
    SI_ACTIVITY_FINDER_PLUS_SCREEN          = "Улучшенная индикация",
    SI_ACTIVITY_FINDER_PLUS_ENHANCE         = "Улучшенный поиск активности",
    SI_ACTIVITY_FINDER_PLUS_ACCEPT          = "Автоматически принимать проверку готовности",
    SI_ACTIVITY_FINDER_PLUS_RELEASE         = "Автовозрождение на полях боя",
    SI_ACTIVITY_FINDER_PLUS_DELAY           = "Задержка звукового уведомления",

    SI_ACTIVITY_FINDER_PLUS_LFG_CHAT        = "Проверка готовности!",
    SI_ACTIVITY_FINDER_PLUS_LFG_CHAT_A      = "Проверка готовности принята автоматически!",
    SI_ACTIVITY_FINDER_PLUS_LFG_SCREEN      = "Проверка готовности группы!",

    SI_ACTIVITY_FINDER_PLUS_SOUND_TT        = "Проигрывать более громкий повторяющийся звук при проверке готовности.",
    SI_ACTIVITY_FINDER_PLUS_SCREEN_TT       = "Показывать крупное оповещение на экране при проверке готовности.",
    SI_ACTIVITY_FINDER_PLUS_ENHANCE_TT      = "Показывает статус обетов и заданий, прогресс коллекции сетов и значки достижений. Добавляет кнопки быстрого выбора для обетов, квестов на очко навыка и незавершённых сетов.",
    SI_ACTIVITY_FINDER_PLUS_SET_COLLECTION  = "Прогресс коллекции сетов",
    SI_ACTIVITY_FINDER_PLUS_SET_COLLECTION_TT = "Показывать количество разблокированных и общее число частей коллекции сетов для каждого подземелья. Требуется LibSets.",
    SI_ACTIVITY_FINDER_PLUS_KEYBOARD_TOOLTIP_MODE = "Информация о достижениях в отдельном окне",
    SI_ACTIVITY_FINDER_PLUS_KEYBOARD_TOOLTIP_MODE_TT = "Только для клавиатурного режима. Если включено, информация о достижениях подземелья показывается в отдельном окне под подсказкой игры, что исключает наложение с другими аддонами. Если выключено, она записывается прямо в подсказку игры, что может накладываться на другие аддоны, которые тоже её изменяют (например, DungeonTracker).",
    SI_ACTIVITY_FINDER_PLUS_ACCEPT_TT       = "Автоматически принимать проверку готовности, когда группа найдена.",
    SI_ACTIVITY_FINDER_PLUS_RELEASE_TT      = "Автоматически возрождаться после смерти на поле боя.",
    SI_ACTIVITY_FINDER_PLUS_SLASH_TT        = "Команды чата:\nНастройки  /afp\nЕжедневные обеты  /pl  /pledge\nПокинуть группу  /lv  /leave",
    SI_ACTIVITY_FINDER_PLUS_DELAY_TT        = "Секунды между повторными звуковыми уведомлениями во время проверки готовности.",

    SI_ACTIVITY_FINDER_PLUS_PLEDGE_DAILY    = "Обет",
    SI_ACTIVITY_FINDER_PLUS_PLEDGE_QUEST    = "Задание",
    SI_ACTIVITY_FINDER_PLUS_PLEDGE_DONE     = "Готово",
    SI_ACTIVITY_FINDER_PLUS_PLEDGE_SLASH    = "ЕЖЕДНЕВНЫЕ ОБЕТЫ",
    SI_ACTIVITY_FINDER_PLUS_PLEDGE_NPC1     = "Мадж аль-Рагат",
    SI_ACTIVITY_FINDER_PLUS_PLEDGE_NPC2     = "Глирион Рыжебородый",
    SI_ACTIVITY_FINDER_PLUS_PLEDGE_NPC3     = "Ургарлаг Бич Вождей",
    SI_ACTIVITY_FINDER_PLUS_CHECK_QUESTS    = "Проверить активные задания",
    SI_ACTIVITY_FINDER_PLUS_CHECK_SETS      = "Проверить незавершённые сеты",
    SI_ACTIVITY_FINDER_PLUS_CHECK_SKILL_QUESTS = "Выбрать непройденные квесты",
    SI_ACTIVITY_FINDER_PLUS_CHECK_SKILL_QUESTS_TT = "Выбирает подземелья, в которых текущий персонаж ещё не завершил квест на очко навыка.",
    SI_ACTIVITY_FINDER_PLUS_QUICK_SELECT    = "Быстрый выбор",
    SI_ACTIVITY_FINDER_PLUS_VETERAN_MODE_LABEL = "Режим ветерана",
    SI_ACTIVITY_FINDER_PLUS_VETERAN_MODE    = "Режим ветерана:",
    SI_ACTIVITY_FINDER_PLUS_VETERAN_MODE_TT = "Если отмечено, кнопки быстрого выбора будут выбирать ветеранские подземелья вместо обычных.",
    SI_ACTIVITY_FINDER_PLUS_ACHIEVEMENTS_HEADER = "Испытания ветерана",
    SI_ACTIVITY_FINDER_PLUS_VET_CLEAR       = "Пройдено в режиме ветерана",
    SI_ACTIVITY_FINDER_PLUS_NORMAL_CLEAR    = "Пройдено в обычном режиме",

    SI_BINDING_NAME_ACTIVITY_FINDER_PLUS_QUICK_SELECT = "Быстрый выбор",
    SI_KEYBINDINGS_LAYER_ACTIVITY_FINDER_PLUS       = "Поиск активностей",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
