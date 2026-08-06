--[[
Author: Ayantir
Filename: es.lua
Version: 7
]]--

local strings = {
    ROOMBA_GBANK            = "Activar Roomba en el banco de clan",
    ROOMBA_GBANK_TOOLTIP    = "Si se activa esta opción, Roomba estará activo en el banco de clan.",
	
    ROOMBA_LITEMODE         = "Activar el modo reducido",
    ROOMBA_LITEMODE_TOOLTIP    = "Si se activa esta opción, Roomba volverá a apilar automáticamente los objetos depositados en el banco de clan.",

    ROOMBA_POSITION         = "Posición del botón",
    ROOMBA_POSITION_TOOLTIP = "Define la posición horizontal del botón de reapilar",

    ROOMBA_POSITION_CHOICE1 = "A la izquierda",
    ROOMBA_POSITION_CHOICE2 = "En el centro",
    ROOMBA_POSITION_CHOICE3 = "A la derecha"
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(stringId, stringValue, 1)
end