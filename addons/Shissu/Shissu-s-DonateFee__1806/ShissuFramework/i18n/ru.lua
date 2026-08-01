ShissuLocalization = ShissuLocalization or {}

ShissuLocalization["ShissuFramework"] = {
  DONATE =  "Вам нравится этот аддон и вы хотите оказать поддержку? Тогда отправьте пожертвование игроку @Shissu :-)",
  LEFT =    "ЛКМ",
  RIGHT =   "ПКМ",      
  TEXT =    "ВАШ ТЕКСТ",     
}

ShissuLocalization["ShissuLanguageChanger"] = {
  TITLE =   "Настройки языка ESO",
  LANG =    "Язык",
  DESC =    "Изменяет язык Elder Scrolls Online на выбранный язык без перезапуска игры. %sВнимание|r: Интерфейс будет немедленно перезагружен.",
  SLASH =   "Другим способом язык можно также изменить в чате с помощью следующей команды: %s/slc ЯЗЫК",
}

ShissuLocalization["ShissuStandardCommands"] = {
  TITLE = "Стандартные команды",
  DESC = "|cAFD3FF/rl|r - ПЕРЕЗАГРУЗКА ИНТЕРФЕЙСА\n\n" .. 
    "|cAFD3FF/helm|r - Переключение шлема \n\n" .. 
    "|cAFD3FF/on|r - Статус игрока " .. EsoStrings[SI_PLAYERSTATUS1] .. "\n\n" .. 
    "|cAFD3FF/off|r - Статус игрока " .. EsoStrings[SI_PLAYERSTATUS4] .. "\n\n" ..
    "|cAFD3FF/brb|r - Статус игрока " .. EsoStrings[SI_PLAYERSTATUS3] .. "\n\n" ..
    "|cAFD3FF/dnd|r - Статус игрока " .. EsoStrings[SI_PLAYERSTATUS3] .. "\n\n" ..
    "|cAFD3FF/afk|r - Статус игрока " .. EsoStrings[SI_PLAYERSTATUS2] ..
    
    "|cAFD3FFКоличество костей|r\n" ..
    "Выбрасывает случайное число от 1 до желаемого числа. Кроме того, результат можно вывести в чат." .. "\n\n" .. 
    
    "|cAFD3FF/dice|r [ЧИСЛО] [de,en,fr,ru]" .. "\n\n" .. 
    "|cAFD3FF/roll|r [ЧИСЛО] [de,en,fr,ru]" .. "\n\n",
}

ZO_CreateStringId("SI_BINDING_NAME_SSC_helmToogle", "Показать/скрыть шлем")
ZO_CreateStringId("SI_BINDING_NAME_SSC_offlineToogle", "Статус игрока онлайн/оффлайн")
ZO_CreateStringId("SI_BINDING_NAME_SSC_reload", "Перезагрузить UI")