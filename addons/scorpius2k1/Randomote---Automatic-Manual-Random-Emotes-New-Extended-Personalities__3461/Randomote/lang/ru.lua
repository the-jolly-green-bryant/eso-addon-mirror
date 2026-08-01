local strings = {
	SI_RANDOMOTE_LANG 					= "ru",
	SI_RANDOMOTE_ENABLE					= "автоматический",
	SI_RANDOMOTE_ENABLE_TT				= "Включить/отключить использование случайных эмоций в режиме ожидания",
	SI_RANDOMOTE_STANDARD				= "Стандартные эмоции",
	SI_RANDOMOTE_STANDARD_TT			= "Используйте стандартные эмоции",
	SI_RANDOMOTE_COLLECTIBLE			= "Коллекционные эмоции",
	SI_RANDOMOTE_COLLECTIBLE_TT			= "Используйте коллекционные эмоции (зарабатываемые, Crown Store и т. д.)",
	SI_RANDOMOTE_CHAT_OUTPUT			= "Вывод чата",
	SI_RANDOMOTE_CHAT_OUTPUT_TT			= "Отображение информации через окно чата (полезно, чтобы увидеть команду косой черты, время следующей эмоции и т. д.)",
	SI_RANDOMOTE_DELAY_IDLE				= "Задержка простоя",
	SI_RANDOMOTE_DELAY_IDLE_TT			= "Время в секундах, когда игрок бездействует, чтобы автоматически начать использовать эмоции",
	SI_RANDOMOTE_DELAY_MIN				= "Задержка эмоции (минимум)",
	SI_RANDOMOTE_DELAY_MIN_TT			= "Минимальное время в секундах между эмоциями",
	SI_RANDOMOTE_DELAY_MAX				= "Задержка эмоции (максимум)",
	SI_RANDOMOTE_DELAY_MAX_TT			= "Максимальное время в секундах между эмоциями",
	SI_RANDOMOTE_FEEDBACK 				= "Отправить отзыв",
	SI_RANDOMOTE_FEEDBACK_TT 			= "Отправьте автору дополнения сообщение с любыми отзывами, предложениями или отчетами об ошибках.",
	SI_RANDOMOTE_DESCRIPTION_SLASH		= "Слеш-команды",
	SI_RANDOMOTE_DESCRIPTION_EMOTE		= "Случайная эмоция",
	SI_RANDOMOTE_DESCRIPTION_SETTINGS 	= "Меню настроек",
	SI_RANDOMOTE_EMOTE_LIST				= "Список эмоций",
	SI_BINDING_NAME_INVOKE_RANDOM		= "Случайная эмоция",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
