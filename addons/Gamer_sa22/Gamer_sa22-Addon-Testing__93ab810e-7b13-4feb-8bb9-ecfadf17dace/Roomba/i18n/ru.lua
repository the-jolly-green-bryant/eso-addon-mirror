--[[
Author: Ayantir
Filename: ru.lua
Version: 7
]]--

local strings = {
    ROOMBA_GBANK            = "Включить Roomba в гильдейском банке",
    ROOMBA_GBANK_TOOLTIP    = "Если эта опция включена, Roomba будет работать в гильдейском банке.",
	
    ROOMBA_LITEMODE         = "Включить упрощенный режим",
    ROOMBA_LITEMODE_TOOLTIP    = "Если эта опция включена, Roomba будет автоматически объединять в стопки предметы, помещаемые в гильдейский банк.",

    ROOMBA_POSITION         = "Положение кнопки",
    ROOMBA_POSITION_TOOLTIP = "Определяет горизонтальное положение кнопки объединения в стопки",

    ROOMBA_POSITION_CHOICE1 = "Слева",
    ROOMBA_POSITION_CHOICE2 = "По центру",
    ROOMBA_POSITION_CHOICE3 = "Справа"
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(stringId, stringValue, 1)
end