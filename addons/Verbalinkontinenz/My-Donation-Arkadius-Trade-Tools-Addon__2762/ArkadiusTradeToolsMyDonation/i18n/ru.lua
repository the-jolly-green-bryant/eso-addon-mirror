local localization =
{
    ATT_STR_MYDONATION               = "Мой взнос",
	ATT_STR_NAME                     = "Имя",
    ATT_STR_GUILD                    = "Гильдия",
    ATT_STR_DEPOSIT                  = "Einzahlung",
    ATT_STR_TIME                     = "Время",

    ATT_STR_TODAY                    = "Сегодня",
    ATT_STR_YESTERDAY                = "Вчера",
    ATT_STR_TWO_DAYS_AGO             = "Два дня назад",
    ATT_STR_THIS_WEEK                = "Текущая неделя",
    ATT_STR_LAST_WEEK                = "Прошлая неделя",
    ATT_STR_PRIOR_WEEK               = "Предыдущая неделя",
    ATT_STR_7_DAYS                   = "7 дней",
    ATT_STR_10_DAYS                  = "10 дней",
    ATT_STR_14_DAYS                  = "14 дней",
    ATT_STR_30_DAYS                  = "30 дней",
	ATT_STR_3_MONTHS                 = "3 месяца",
	ATT_STR_6_MONTHS                 = "6 месяцев",
	ATT_STR_365_DAYS                 = "12 месяцев",
		
    ATT_STR_KEEP_DEPOSIT_FOR_DAYS  = "Хранить историю взноса x дней",

    ATT_STR_FILTER_TEXT_TOOLTIP      = "Поиск по имени или названию гильдии",
    ATT_STR_FILTER_SUBSTRING_TOOLTIP = "Переключение между поиском по слову целиком или по части слова. Заглавные буквы игнорируются в обоих случаях.",
    ATT_STR_FILTER_COLUMN_TOOLTIP    = "Включить/Исключить эту колонку в/из поиск(а)",
}

ZO_ShallowTableCopy(localization, ArkadiusTradeTools.Modules.MyDonation.Localization)
