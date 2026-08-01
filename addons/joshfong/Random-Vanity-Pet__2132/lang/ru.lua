local strings = {
	RVP_CHAT_DISPLAY_LABEL		= "Отображать изменения в чате",
	RVP_CHAT_DISPLAY_TOOLTIP	= "Показывать имя нового питомца в чате",
	RVP_FREQ_LABEL				= "Частота",
	RVP_FREQ_TOOLTIP			= "Как часто вы хотите менять питомцев",
	RVP_FREQ_ON_LOGIN			= "При логине",
	RVP_FREQ_ON_LOAD_SCREEN		= "При загрузке",
	RVP_FREQ_NEVER				= "Никогда",
	RVP_FREQ_WARNING			= "Требуется перезагрузка интерфейса",
	RVP_RELOAD_UI_LABEL			= "Перезагрузить интерфейс",
	RVP_PET_CHAT_LOG			= "Питомец изменен на ",
}

for id, value in pairs(strings) do
	--SafeAddString(id, value, 1)
	ZO_CreateStringId(id, value)
end
