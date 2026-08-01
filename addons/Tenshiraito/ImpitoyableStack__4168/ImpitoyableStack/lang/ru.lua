local localization_strings_ru = {
    SLIDER_SIZE = "Размер иконки",
    SLIDER_SIZE2 = "Изменить размер иконки",
    SLIDER_TEXT = "Размер текста",
    SLIDER_TEXT2 = "Изменить размер текста",
    COLOR_PICKER = "Цвет текста",
    COLOR_PICKER2 = "Изменить цвет текста",
    POS_X = "Позиция X",
    POS_X2 = "Изменить положение иконки по X",
    POS_Y = "Позиция Y",
    POS_Y2 = "Изменить положение иконки по Y",
    SLIDER_STACK = "Количество стаков до показа иконки",
    SLIDER_STACK2 = "Изменить минимальное количество стаков",
    BUTTOM_HIDE = "Показать/Скрыть",
    BUTTOM_HIDE2 = "Показать или скрыть иконку для настройки",
	
	}
	for stringId, stringValue in pairs(localization_strings) do	
		ZO_CreateStringId(stringId, stringValue)
		SafeAddVersion(stringId, 1)
	end