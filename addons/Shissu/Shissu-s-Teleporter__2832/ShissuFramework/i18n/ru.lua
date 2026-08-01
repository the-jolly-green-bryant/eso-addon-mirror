-- Automatische Generierung
ShissuLocalization = ShissuLocalization or {}

ShissuLocalization["ShissuFramework"] = {
  DONATE  = "Вам нравится этот аддон и вы хотели бы выразить свою поддержку? Затем отправьте пожертвование в @Shissu :-).",
  LEFT    = "Ссылки",
  RIGHT   = "Справа",     
  MIDDLE  = "Средний",

  NOTE    = "Блокнот",
  FILTER  = "Чат-фильтр",

  TEXT    = "DEINTEXT",   
  INFO    = "ВАШ ТЕКСТ",
  ERR     = "ОШИБКА",
  MISSING = "Файл %1 не найден.",

  ADD     = "Добавить",
  DELETE  = "Удалить",
  SAVE    = "Сохранить",
}

ShissuLocalization["ShissuFileIntegrity"] = {
  TITLE   = "Целостность данных",
  FILES   = "Файлы",
  INFO    = "Следующие файлы были (не) успешно загружены. Если эти файлы отсутствуют, функциональность отдельных модулей не может быть гарантирована. Пожалуйста, переустановите аддон.",
}

ShissuLocalization["ShissuLanguageChanger"] = {
  TITLE   = "TESO Языковые настройки",
  LANG    = "Язык",
  DESC    = "Изменяет язык Старых свитков онлайн на выбранный язык без перезапуска игры.",
  SLASH   = "Кроме того, язык может быть изменен в чате следующей командой: %1/slc LANG",
  WARNING = "%1Внимание|r: Интерфейс перезагружается напрямую.",
}

ShissuLocalization["ShissuStandardCommands"] = {
  TITLE   = "Стандартные команды",
  DESC    = "|cAFD3FF/rl|r - RELOADUI\n\n" .. 
            "|cAFD3FF/on|r - Статус игрока " .. EsoStrings[SI_PLAYERSTATUS1] .. "\n\n" .. 
            "|cAFD3FF/off|r - Статус игрока " .. EsoStrings[SI_PLAYERSTATUS4] .. "\n\n" ..
            "|cAFD3FF/brb|r - Статус игрока " .. EsoStrings[SI_PLAYERSTATUS3] .. "\n\n" ..
            "|cAFD3FF/dnd|r - Статус игрока " .. EsoStrings[SI_PLAYERSTATUS3] .. "\n\n" ..
            "|cAFD3FF/afk|r - Статус игрока " .. EsoStrings[SI_PLAYERSTATUS2] .. "\n\n" ..
            
            "|cAFD3FFКоличество костей|r\n" ..
            "Выбрасывает случайное число от 1 до желаемого числа. Кроме того, результат можно вывести в чат." .. "\n\n" .. 
            
            "|cAFD3FF/dice|r [ZAHL] [de,en,es,fr,jp,ru]" .. "\n\n" .. 
            "|cAFD3FF/roll|r [ZAHL] [de,en,es,fr,jp,ru]" .. "\n\n",

  DE_DICE  = "%1 hat bei einem Zufallswurf (1-%2) die Zahl %3 erwürfelt.",
  EN_DICE  = "%1 has rolled the number %3 on a random roll (1-%2).",
  ES_DICE  = "%1 ha rodado el número %3 en un rodaje aleatorio (1-%2).",
  FR_DICE  = "%1 roule le nombre %3 dans un jet alkatoire de 1-%2.",
  JP_DICE  = "%1 はランダムに %3 を転がしました (1-%2)。",
  RU_DICE  = "%1 выкатила число %3 на случайном отрезке (1-%2).",
}

ZO_CreateStringId("SI_BINDING_NAME_SSC_offlineToogle", "Статус игрока онлайн/оффлайн")
ZO_CreateStringId("SI_BINDING_NAME_SSC_reload", "Reload UI")