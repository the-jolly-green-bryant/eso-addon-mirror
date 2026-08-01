-- Translated by: GJSmoker

local Register = LibCodesCommonCode.RegisterString

Register("SI_LCK_SCAN_START"                , "Таблица сканируемых предметов; это происходит только один раз за основное обновление игры.")
Register("SI_LCK_SCAN_COMPLETE"             , "Сканирование завершено.")

Register("SI_LCK_SETTINGS_CHATCOMMAND"      , "К этой панели настроек также можно получить доступ через чат команду\n|c00CCFF/lck|r")

Register("SI_LCK_SETTINGS_SERVER"           , "Сервер")

Register("SI_LCK_SETTINGS_USE_DEFAULT"      , "Использовать по умолчанию")

Register("SI_LCK_SETTINGS_TRACKING1"        , "Не отслеживать")
Register("SI_LCK_SETTINGS_TRACKING2"        , "Отслеживать низкое качество")
Register("SI_LCK_SETTINGS_TRACKING3"        , "Отслеживать среднее качество")
Register("SI_LCK_SETTINGS_TRACKING4"        , "Отслеживать все")

Register("SI_LCK_SETTINGS_PRIORITY"         , "Приоритет по символу")
Register("SI_LCK_SETTINGS_PRIORITY_HELP"    , "Несколько персонажей могут иметь один и тот же символа приоритета; персонажи в пределах одного символа выстраиваться по старшинству, при этом более старые персонажи имеют приоритет над более новыми персонажами.")

Register("SI_LCK_SETTINGS_EXPORT"           , "Выбрать для экспорта")

Register("SI_LCK_SETTINGS_MAIN_SECTION"     , "Приоритет и отслеживание")
Register("SI_LCK_SETTINGS_RANKING_PREVIEW"  , "Текущий порядок расстановки персонажей")
Register("SI_LCK_SETTINGS_SYSTEM_DEFAULTS"  , "Эти общесистемные настройки по умолчанию будут применяться для каждого персонажа, если они не отменены на сервере или учетной записи:")
Register("SI_LCK_SETTINGS_SERVER_DEFAULTS"  , "Эти общесерверные настройки по умолчанию будут применяться для каждого персонажа на этом сервере, если они не отменены на учетной записи:")
Register("SI_LCK_SETTINGS_ACCOUNT_DEFAULTS" , "Эти настройки по умолчанию для всей учетной записи будут применяться для каждого персонажа, принадлежащего этой учетной записи, если они не отменены:")

Register("SI_LCK_SETTINGS_SHARE_SECTION"    , "Поделиться данными")
Register("SI_LCK_SETTINGS_SHARE_CAPTION"    , "Экспорт и копирование или вставка и импорт для обмена данными")
Register("SI_LCK_SETTINGS_SHARE_EXPORTC"    , "Экспорт")
Register("SI_LCK_SETTINGS_SHARE_EXPORTCT"   , "Экспорт данных Knowledge для текущего персонажа")
Register("SI_LCK_SETTINGS_SHARE_EXPORTA"    , "Экспорт всех")
Register("SI_LCK_SETTINGS_SHARE_EXPORTAT"   , "Экспорт данных Knowledge для каждого активного персонажа")
Register("SI_LCK_SETTINGS_SHARE_EXPORTS"    , "Экспорт выбранных (%d)")
Register("SI_LCK_SETTINGS_SHARE_EXPORTST"   , "Экспорт данных Knowledge для персонажей с включенной функцией \"Выбрать для экспорта\"")
Register("SI_LCK_SETTINGS_SHARE_IMPORT"     , "Импорт")
Register("SI_LCK_SETTINGS_SHARE_CLEAR"      , "Очистить")

Register("SI_LCK_SETTINGS_RESET_SECTION"    , "Сбросить данные")
Register("SI_LCK_SETTINGS_RESET_WARNING"    , "Это приведет к сбросу всех настроек, удалению всех данных, связанных с LibCharacterKnowledge, и перезагрузке UI.")

Register("SI_LCK_SETTINGS_NOSAVE_SECTION"   , "Исключить аккаунты")
Register("SI_LCK_SETTINGS_NOSAVE_CAPTION"   , "Список имен, разделенных запятыми, для исключения из сохранения")

Register("SI_LCK_SHARE_EXPORT_LIMIT"        , "Пропущено [<<1>>/<<2>>]; достигнут лимит данных.")
Register("SI_LCK_SHARE_IMPORT_STALE"        , "Пропущено [<<1>>/<<2>>]; текущие данные более свежие.")
Register("SI_LCK_SHARE_IMPORT_API"          , "Пропущено [<<1>>/<<2>>]; импортированные данные были созданы другой версией игры..")
Register("SI_LCK_SHARE_IMPORT_DONE"         , "Импортирован [<<1>>/<<2>>]. (<<3>>)")
Register("SI_LCK_SHARE_IMPORT_INVALID"      , "Прерывание импорта; обнаружены поврежденные данные.")
Register("SI_LCK_SHARE_IMPORT_BADVERSION"   , "Импортированные данные были закодированы несовместимой версией LibCharacterKnowledge; убедитесь, что оба пользователя обновили до последней версии LibCharacterKnowledge..")
Register("SI_LCK_SHARE_IMPORT_NEWCHARACTER" , "Вы импортировали одного или несколько новых персонажей, которых ранее не было в базе данных.; |c00CCFF/reloadui|r может потребоваться для отображения вновь добавленных персонажей в меню и настройках.")
Register("SI_LCK_SHARE_IMPORT_TALLY"        , "<<1>> персонажи импортированы.")
