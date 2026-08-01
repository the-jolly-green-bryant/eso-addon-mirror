strings = {
  TBUST_TRAITBUSTER = "преданный",
  TBUST_ACTIVATED = "Активированный. Используйте %s для опций.",
  TBUST_LONG_SINGULAR = "преданный: 1 другой предмет с тем же исследуемым признаком.",
  TBUST_SHORT_SINGULAR = "1 исследуемый дубликат.",
  TBUST_LONG_PLURAL = "преданный: %s других предметов с той же исследуемой чертой.",
  TBUST_SHORT_PLURAL = "%s исследуемых дубликатов.",
  TBUST_SLASH_TBUST = "/пнный",
  TBUST_SLASH_ON = "на",
  TBUST_SLASH_OFF = "от",
  TBUST_SLASH_LONG = "длинный",
  TBUST_SLASH_SHORT = "короткая",
  TBUST_SLASH_GREET = "приветствовать",
  TBUST_SLASH_DEFAULT = "по умолчанию",
  TBUST_MENU_TITLE = " -=-=-= ГЛАВНОЕ МЕНЮ =-=-=-",
  TBUST_MENU_ON = "= Включает подсказки для этого символа. [ПО УМОЛЧАНИЮ]",
  TBUST_MENU_OFF = "= Отключает всплывающие подсказки для этого символа.",
  TBUST_MENU_LONG = "= Более подробные всплывающие подсказки. [ПО УМОЛЧАНИЮ]",
  TBUST_MENU_SHORT = "= Более короткие краткие подсказки.",
  TBUST_MENU_GREET_ON = "= Включает приветствие входа. [ПО УМОЛЧАНИЮ]",
  TBUST_MENU_GREET_OFF = "= Отключает приветствие входа.",
  TBUST_MENU_DEFAULT = "= Сбросьте настройки по умолчанию.",
  TBUST_MENU_SELECT_ON = "Подсказки включены для этого символа.",
  TBUST_MENU_SELECT_OFF = "Всплывающие подсказки отключены для этого символа.",
  TBUST_MENU_SELECT_LONG = "Подсказки будут длиннее и более описательными.",
  TBUST_MENU_SELECT_SHORT = "Подсказки будут короткими и краткими.",
  TBUST_MENU_SELECT_GREET_ON = "Будет показано приветствие входа.",
  TBUST_MENU_SELECT_GREET_OFF = "Приветствие входа не будет показано.",
  TBUST_MENU_SELECT_DEFAULT = "Загружены настройки по умолчанию."
}

if GetString(TBUST_TRAITBUSTER):len() == 0 then
  for key,value in pairs(strings) do
    SafeAddVersion(key, 1)
    ZO_CreateStringId(key, value)
  end
end