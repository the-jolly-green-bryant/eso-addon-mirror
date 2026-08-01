local strings = {
	SI_AD_BLOCK_PLUS_ENABLE			= "Включено",
	SI_AD_BLOCK_PLUS_ENABLE_TT		= "Включение/отключение AdBlock Plus",

	SI_AD_BLOCK_PLUS_NOTIFY			= "Заблокированные уведомления",
	SI_AD_BLOCK_PLUS_NOTIFY_TT		= "Показывать заблокированные уведомления в чате",

	SI_AD_BLOCK_PLUS_FRIEND			= "Уведомления о статусе друга",
	SI_AD_BLOCK_PLUS_FRIEND_TT		= "Показывать друзьям, вошедшим в систему/отключенным уведомлениями в чате",
	SI_AD_BLOCK_PLUS_FRIEND_TYPE	= "друг",
	SI_AD_BLOCK_PLUS_FRIEND_ONLINE	= "вошел в систему",
	SI_AD_BLOCK_PLUS_FRIEND_OFFLINE	= "вышел из системы",		

	SI_AD_BLOCK_PLUS_AGRESSIVE 		= "Агрессивная фильтрация",
	SI_AD_BLOCK_PLUS_AGRESSIVE_TT	= "Обеспечьте более строгую проверку всех включенных параметров блокировки",

	SI_AD_BLOCK_PLUS_BLOCK			= "Блокировать",
	SI_AD_BLOCK_PLUS_BLOCKED_ADVERT = "Заблокированная реклама",
	SI_AD_BLOCK_PLUS_BLOCKED_SINCE 	= "С момента установки",
	SI_AD_BLOCK_PLUS_BLOCKED_TOTAL 	= "Всего заблокировано",

	SI_AD_BLOCK_PLUS_HEADER_BLOCKING = "Блокировка",
	SI_AD_BLOCK_PLUS_HEADER_CHANNELS = "Контролируемые каналы чата",
	SI_AD_BLOCK_PLUS_HEADER_ADVANCED = "Продвинутый",

	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET = "Предварительная установка фильтра",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_TT = "Предопределенные параметры для блокировки",

	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_1 = "Базовый",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_2 = "Продвинутый",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_3 = "Строгий",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_4 = "Полный",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_5 = "Пользовательский",

	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_TT_1 = "• Достижения, короны, гильдии\n• Зональный канал",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_TT_2 = "• Достижения, короны, гильдии, URL\n• Зона, кричать, говорить каналы",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_TT_3 = "• Все параметры блокировки\n• Зона, кричать, гильдия, говорить каналы",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_TT_4 = "• Все параметры блокировки\n• Все каналы",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_TT_5 = "Пользовательские параметры",

	SI_AD_BLOCK_PLUS_HISTORY_LAST = "Последний",
	SI_AD_BLOCK_PLUS_DESCRIPTION_SLASH = "Команды косой черты",
	SI_AD_BLOCK_PLUS_DESCRIPTION_HISTORY = "Окно истории",
	SI_AD_BLOCK_PLUS_DESCRIPTION_SETTINGS = "Меню настроек",
	SI_AD_BLOCK_PLUS_WELCOME_FIRSTRUN = "Спасибо за использование AdBlockPlus!",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
