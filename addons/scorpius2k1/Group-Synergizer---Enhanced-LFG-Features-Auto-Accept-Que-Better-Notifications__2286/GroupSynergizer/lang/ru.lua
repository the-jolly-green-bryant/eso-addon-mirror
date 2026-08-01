local strings = {
	SI_GROUP_SYNERGIZER_LANG 		= "ru",

	SI_GROUP_SYNERGIZER_ENABLE 		= "Включено",
	SI_GROUP_SYNERGIZER_SOUND 		= "Улучшенный звук",
	SI_GROUP_SYNERGIZER_SCREEN 		= "Улучшенная визуализация",
	SI_GROUP_SYNERGIZER_ENHANCE 	= "Улучшенный LFG",
	SI_GROUP_SYNERGIZER_ACCEPT 		= "Автоматическое принятие проверок готовности",
	SI_GROUP_SYNERGIZER_RELEASE 	= "Авто-релиз на полях боя",
	SI_GROUP_SYNERGIZER_SLASH 		= "Команды залога/групповой косой черты",
	SI_GROUP_SYNERGIZER_DELAY 		= "Задержка звукового уведомления",

	SI_GROUP_SYNERGIZER_LFG_CHAT 	= "Готово, проверка!",
	SI_GROUP_SYNERGIZER_LFG_CHAT_A 	= "Автоматическая проверка готовности!",
	SI_GROUP_SYNERGIZER_LFG_SCREEN 	= "Проверка готовности группы!", 

	SI_GROUP_SYNERGIZER_ENABLE_TT 	= "Включить/отключить LFG Enhancer",
	SI_GROUP_SYNERGIZER_SOUND_TT 	= "Более громкий звук при проверке готовности",
	SI_GROUP_SYNERGIZER_SCREEN_TT 	= "Улучшенное уведомление на экране при проверке готовности",
	SI_GROUP_SYNERGIZER_ENHANCE_TT 	= "Показывать ежедневные обещания/задания, автоматическое принятие и проверять активные задания в поиске групп и действий",
	SI_GROUP_SYNERGIZER_ACCEPT_TT 	= "Авто-Принять 'Поиск группы' Проверка готовности",
	SI_GROUP_SYNERGIZER_RELEASE_TT 	= "Авто-релиз при смерти на поле боя",
	SI_GROUP_SYNERGIZER_SLASH_TT 	= "Команды косой черты \nЕжедневные обещания /pl /pledge \nПокинуть группу /lv /leave",
	SI_GROUP_SYNERGIZER_DELAY_TT 	= "Задержка (в секундах) между звуковыми сообщениями при проверке готовности LFG",

	SI_GROUP_SYNERGIZER_SLASH_WARN	= "Требуется перезагрузка пользовательского интерфейса"
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
