--! Translation done by @JKabak40k and @SupersonicKitten

ITTsDonationBot.i18n = {
	ITTDB_NAME = "ITT's Donation Bot",
	ITTDB_HEADER = "Взносы",
	ITTDB_HEADER_GUILDS = "Гильдии",
	ITTDB_HEADER_NOTIFY = "Уведомления",
	-- time
	ITTDB_TIME_TODAY = "Сегодня",
	ITTDB_TIME_YESTERDAY = "Вчера",
	ITTDB_TIME_2_DAYS = "Два дня назад",
	ITTDB_TIME_THIS_WEEK = "Текущая неделя", --"This Week"? Эта неделя   На эту неделю
	ITTDB_TIME_LAST_WEEK = "Прошлая неделя", --"Last Week"? Прошлая неделя   На прошлую неделю
	ITTDB_TIME_PRIOR_WEEK = "Предыдущая неделя", --"Prior Week" Предыдущая неделя На предыдущуя неделю
	ITTDB_TIME_7_DAYS = "Последних 7 дней", --"Last 7 Days",
	ITTDB_TIME_10_DAYS = "Последних 10 дней", --"Last 14 Days"
	ITTDB_TIME_14_DAYS = "Последних 14 дней", --"Last 14 Days"
	ITTDB_TIME_30_DAYS = "Последних 30 дней", --"Last 30 Days"
	ITTDB_TIME_TOTAL = "Всего",
	-- settings
	ITTDB_SETTINGS_DESC = [[Вы можете включить сканирование, если у Вас есть соответствующие разрешения в гильдии. Если эта опция недоступна - у Вас нет разрешения просматривать количество золота в Банке Гильдии]] --[[If you have the correct permissions with a guild, it will be available below as a toggle option to scan. If a guild option is disabled, you do not have the correct "View Guild Bank Gold" permission]],
	ITTDB_SETTINGS_SCAN_ERROR = "У Вас нет разрешения сканировать эту гильдию", -- You do not have the correct permissions to scan this guild
	ITTDB_SETTINGS_SCAN_PROMPT = "Сканировать ${guild}", --"Turn scanning on or off for ${guild}"
	ITTDB_SETTINGS_SCAN_INFO = [[Приведенный выше список гильдий формируется автоматически и, если он не отображается корректно из-за недавнего изменения - выполните команду /reloadui]], --Whilst we try to handle things automatically, stuff can slip through. If the above guild list is not correct due to a recent change, you may need to run the /reloadui command
	ITTDB_SETTINGS_NOTIFY = [[Уведомления применяются для событий за последние 24 часа]],
	ITTDB_SETTINGS_CHAT = "Уведомления в чате",
	ITTDB_SETTINGS_SCREEN = "Уведомления на экране",
	ITTDB_SETTINGS_LOTTO_NAME = "Сгенерировать список для лотереи", --"Lotto List Generator"
	ITTDB_SETTINGS_LOTTO_DESC = [[Щелкните, чтобы создать столбцы с именами участников и количеством билетов для вашей таблицы лотереи. Вы можете установить стоимость билета, по умолчанию 1k = 1 билет.]],
	ITTDB_SETTINGS_LOTTO_SELECT = "Выбор гильдии",
	ITTDB_SETTINGS_LOTTO_GUILD = "Участвует в лотерее", --"Guild members for lotto"
	ITTDB_SETTINGS_LOTTO_VALUE = "Стоимость билета", --"Lotto ticket value"
	ITTDB_SETTINGS_LOTTO_EXAMPLE = "Пример 1000 за билет", --"Example 1000 per ticket"
	ITTDB_SETTINGS_LOTTO_TIMEFRAME = "Выбор временного промежутка", -- "Select Timeframe"         ??
	ITTDB_SETTINGS_LOTTO_TIMEFRAME_2 = "Выбор временного промежутка для лотереи", --"Timeframe for lotto" ???
	ITTDB_SETTINGS_LOTTO_GENERATE = "Сгенерировать",
	ITTDB_SETTINGS_LOTTO_GENERATE_COL = "Щелкните, чтобы создать столбцы для таблицы", --Click to generate the spreadsheet columns
	ITTDB_SETTINGS_LOTTO_INFO_1 = "Значения для столбца с именами, ячейки 1 - 250", --Values for the name column, rows 1 - 250
	ITTDB_SETTINGS_LOTTO_INFO_2 = "Значения для столбца с билетами, ячейки 1 - 250", --Values for the ticket column, rows
	ITTDB_SETTINGS_LOTTO_INFO_3 = "Значения для столбца с именами, ячейки 251 - 500",
	ITTDB_SETTINGS_LOTTO_INFO_4 = "Значения для столбца с билетами, ячейки 251 - 500",
	ITTDB_SETTINGS_LOTTO_NAMES = "ID участников:", --Name Values
	ITTDB_SETTINGS_LOTTO_TICKETS = "Количество билетов:", --Ticket Values
	ITTDB_SETTINGS_LOTTO_INFO_5 = "Столбец с именами", --Здесь будет создан столбец с именами
	ITTDB_SETTINGS_LOTTO_INFO_6 = "Столбец с количеством билетов ", --Amount column generated here
	ITTDB_LH_OPTIONS = "Настройки LibHistoire",
	ITTDB_LH_OPTION1_DESC = "Отсутствующие записи",
	ITTDB_LH_OPTION1_ENTRY = "Эта опция просканирует LibHistoire на наличие отсутствующих записей.",
	ITTDB_LH_OPTION2_DESC = "Полное сканирование",
	ITTDB_LH_OPTION2_ENTRY = "Сканирование LibHistoire займет время в зависимости от количества сохраненных и отсутствующих данных.",
	ITTDB_LH_OPTION2_WARN = "Выберите эту опцию, чтобы просканировать все данные LibHistoire (может занять время)",
	ITTDB_TRANSFER_OPTIONS = "Параметры импорта",
	ITTDB_TRANSFER_TITLE = "Перенести старые данные",
	ITTDB_TRANSFER_DESC = "|cff0000ВНИМАНИЕ! СОЗДАЙТЕ РЕЗЕРВНУЮ КОПИЮ ВАШИХ СОХРАНЕННЫХ ПЕРЕМЕННЫХ (SAVED VARIABLES) ПЕРЕД НАЖАТИЕМ ЭТОЙ КНОПКИ",
	ITTDB_TRANSFER_WARN = "Вы сделали резервную копию ваших сохраненных переменных (Saved Variables)?",
	ITTDB_TRANSFER_REMINDER = "|cffffffМы обнаружили, что вы сохранили данные до обновления! Не волнуйтесь, ваши данные все еще там. Пожалуйста, перейдите в меню дополнений, нажмите <<Параметры импорта>> и следуйте инструкции. Спасибо!",
	-- Notifications
	ITTDB_NOTIFICATION = "${user} - взнос ${amount} в Банк Гильдии ${guild} ${time}", --"${user} has donated ${amount} to ${guild} ${time}"
	-- Null
	ITTDB_NONE = "Отсутствует",
	-- commands
	ITTDB_CMD_NO_GUILDS = "Не удалось найти гильдию, введите число от 1 до 5", --Could not find guild, please enter a number between 1 and 5
	ITTDB_CMD_GENERATED = "Всплывающие подсказки восстановлены" --Tooltips regenerated
}
