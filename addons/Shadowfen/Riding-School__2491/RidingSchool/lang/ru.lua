-- All the texts that need a translation. 

-- default language is english
RidingSchool_localization_strings = RidingSchool_localization_strings  or {}

RidingSchool_localization_strings["ru"] = {
	RS_STABLE_MASTER = "хозя[^ ]+ конюшни",  -- must be lower case

	RS_NAME = "RidingSchool",
	RS_ACCOUNTWIDE = "Примените эти настройки ко всему аккаунту:",
	RS_ACCOUNTWIDE_TT = "Если включено, эти настройки применяются ко всей учетной записи, а не только к этому одному персонажу.",

    RS_DISABLES_HDR = "Отключение",
    RS_DISABLES_DESC = "Отключите автоматическое обучение для определенной ветки навыков верховой езды.",
    RS_DISABLE_SPEED = "Отключить автоматическую тренировку скорости",
    RS_DISABLE_STAMINA = "Отключить автоматическую тренировку выносливости.",
    RS_DISABLE_CAPACITY = "Отключить автоматическую тренировку грузоподъемности",

    RS_ORDER_HDR = "Порядок обучения",
    RS_ORDER_DESC = "Выберите, в каком порядке будут изучаться отдельные навыки верховой езды (все еще включенные). Выбор навыка из раскрывающегося списка заменит этот навык и поместит предыдущий навык на место другого.",
    RS_ORDER_FIRST = "1-й",
    RS_ORDER_SECOND = "2-й",
    RS_ORDER_THIRD = "3-й",

    RS_THRESHOLDS_HDR = "Установить пороговые значения",
    RS_THRESHOLDS_DESC = "Установите уровень, до которого вы хотите тренироваться, прежде чем переключаться на новый навык для тренировки. Как только все навыки достигнут пороговых уровней, продолжайте тренировать навыки по порядку до максимального уровня.",

    RS_NOPT_SPEED = "Скорость",
	RS_NOPT_STAMINA = "Выносливость",
	RS_NOPT_CAPACITY = "Грузоподъемность",

    RS_UNNEEDED_DESC = "Навыки верховой езды у этого персонажа полностью обученны.",

    RS_SLASH_HELP = "Распечатать это сообщение справки",
    RS_SLASH_SETTINGS = "Открыть окно настроек для RidingSchool",
    RS_SLASH_DEBUG = "Переключить отладочные сообщения для RidingSchool",
    RS_SLASH_DISPLAY = "Отобразить текущий порядок обучения и пороговые значения.",
}