local localization_strings = {
	-- Day of Week
	SI_FRIENDLYREMINDER_WEEKDAY1 = "Понедельник",
	SI_FRIENDLYREMINDER_WEEKDAY2 = "Вторник",
	SI_FRIENDLYREMINDER_WEEKDAY3 = "Среда",
	SI_FRIENDLYREMINDER_WEEKDAY4 = "Четверг",
	SI_FRIENDLYREMINDER_WEEKDAY5 = "Пятница",
	SI_FRIENDLYREMINDER_WEEKDAY6 = ZO_ERROR_COLOR:Colorize("Суббота"),
	SI_FRIENDLYREMINDER_WEEKDAY7 = ZO_ERROR_COLOR:Colorize("Воскресенье"),
	
	-- Month
	SI_FRIENDLYREMINDER_MONTH1 = "Янвapь",
	SI_FRIENDLYREMINDER_MONTH2 = "Фeвpaль",
	SI_FRIENDLYREMINDER_MONTH3 = "Мapт",
	SI_FRIENDLYREMINDER_MONTH4 = "Aпpeль",
	SI_FRIENDLYREMINDER_MONTH5 = "Мaй",
	SI_FRIENDLYREMINDER_MONTH6 = "Июнь",
	SI_FRIENDLYREMINDER_MONTH7 = "Июль",
	SI_FRIENDLYREMINDER_MONTH8 = "Aвгуcт",
	SI_FRIENDLYREMINDER_MONTH9 = "Ceнтябpь",
	SI_FRIENDLYREMINDER_MONTH10 = "Oктябpь",
	SI_FRIENDLYREMINDER_MONTH11 = "Нoябpь",
	SI_FRIENDLYREMINDER_MONTH12 = "Дeкaбpь",
	
	-- Settings
	SI_FRIENDLYREMINDER_DELETE_DAILY = "Удалить ВСЕ ежедневные напоминания.",
	SI_FRIENDLYREMINDER_DELETE_MONTH = "Удалить ВСЕ напоминания за %s.",
	
	SI_FRIENDLYREMINDER_SHOW_ONCE = "Показывать один раз",
	SI_FRIENDLYREMINDER_SHOW_ONCE_DESC = "Показывать напоминание только один раз в день.",

	SI_FRIENDLYREMINDER_SHOW_CHAT = "Выводить в чат",
	SI_FRIENDLYREMINDER_SHOW_CHAT_DESC = "Показывать напоминание в окне чата.",
	
	SI_FRIENDLYREMINDER_SHOW_ANNOUNCEMENT = "Показать на экране",
	SI_FRIENDLYREMINDER_SHOW_ANNOUNCEMENT_DESC = "Показывать напоминание на экране.",

	SI_FRIENDLYREMINDER_SEND_NOTIFICATION = "Создать уведомление",
	SI_FRIENDLYREMINDER_SEND_NOTIFICATION_DESC = "Создать уведомление.\n\nТребуется библиотека 'Circonians LibNotifications'.",
	
	SI_FRIENDLYREMINDER_START_TIME = "Время начала нового дня",
}

for stringId, stringValue in pairs(localization_strings) do
   ZO_CreateStringId(tostring(stringId), stringValue)
   SafeAddVersion(stringId, 1)
end