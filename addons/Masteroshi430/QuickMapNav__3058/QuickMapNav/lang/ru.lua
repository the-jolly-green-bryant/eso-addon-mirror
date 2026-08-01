
local strings = {
	DEFAULT_TOPLEFT = "Названия зон и часы слева вверху",
	PERFECT_PIXEL = "в основном для пользователей PerfectPixel ;-)",
	LESS_FLASHY = "Выцветание карты",
	LESS_FLASHY_TOOLTIP = "Слегка затемните карту, чтобы ночью радовать глаз.\n87 подойдет\n100 по умолчанию",
	DESATURATION = "Обесцвечивание карты",
	DESATURATION_TOOLTIP = "Обесцветить цвета на карте.\n20 подойдет\n0 по умолчанию",
	SECONDS = "Установите 24-часовой формат с секундами на карточных часах",
	SECONDS_TOOLTIP = ":-)",
    TO = "в ",
	WAYSHRINE = "Святилище",
	WAYSHRINE_ONLY = "Можно добраться только через дорожные святилища.",
	ABBR = "Сокращенные крепости",
	ABBR_TOOLTIP = "Отображает сокращенные международные названия крепостей в Сиродил.",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
