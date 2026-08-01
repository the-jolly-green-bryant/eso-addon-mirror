-------------------------------------------------
-- Russian localization for LRSA
-------------------------------------------------

local strings = {
    LRSA_LEFT_STR = "ЛЕВО",
	LRSA_RIGHT_STR = "ПРАВО",
	LRSA_CHECKBOX1_NAME = "Отображать надписи",
	LRSA_CHECKBOX1_TOOLTIP = "Отображать надписи левой и правой сторон",
	LRSA_SLIDER1_NAME = "Размер шрифта",
	LRSA_SLIDER1_TOOLTIP = "Укажите размер шрифта для надписей",
	LRSA_COLORPICKER1_NAME = "Цвет надписей",
    LRSA_COLORPICKER1_TOOLTIP = "Цвет надписей",
	LRSA_SLIDER2_NAME = "Расстояние по горизонтали",
	LRSA_SLIDER2_TOOLTIP = "Укажите координату отображения по горизонтали",
    LRSA_SLIDER3_NAME = "Расстояние по вертикали",
	LRSA_SLIDER3_TOOLTIP = "Укажите координату отображения по вертикали"
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end