--[[
Author: Kwisatz
Filename: sp.lua
Version: 1
]]--

-- Messages settings
local strings = {
	XTGII_GUI_OPTION_DESCRIPTION_LINE_1 = "Immersive Interface favorece la inmersión en el juego al ocultar elementos de la interfaz para permitirte disfrutar mejor con la belleza del mundo.",
 
	XTGII_GUI_OPTION_MENU_INTERFACE = "Interfaz",
	XTGII_GUI_OPTION_INTERFACE_DESCRIPTION_LINE = "Ocultar elementos de la interfaz",
 
	XTGII_GUI_OPTION_INTERFACE_QUEST_TRACKER = "Misión activa",
	XTGII_GUI_OPTION_INTERFACE_COMPASS = "Brújula",
	XTGII_GUI_OPTION_INTERFACE_SKILLBAR = "Habilidades",
	XTGII_GUI_OPTION_INTERFACE_PLAYER_ATTRIBUTES_BARS = "Salud/Magia/Aguante",
	XTGII_GUI_OPTION_INTERFACE_TARGET_FRAME = "Objetivo",
	XTGII_GUI_OPTION_INTERFACE_EQUIPMENT_STATUS = "Estado del equipamiento",
 
 
	XTGII_GUI_OPTION_MENU_HEALTH = "Salud",
 
	XTGII_GUI_OPTION_HEALTH_DESCRIPTION_LINE_1 = "Immersive Health quiere favorecer una mejor inmersión en los combates al no mostrar  el valor numérico de los puntos de salud.",
	XTGII_GUI_OPTION_HEALTH_DESCRIPTION_LINE_2 = "Aquí podrás configurar el latido de corazón que te avisará al volverse más insistente cuanto más cerca estés de la muerte.",
 
	XTGIH_GUI_OPTION_HEALTH_ONLY_IN_FIGHT = "Mostrar sólo en combate",
	XTGIH_GUI_OPTION_HEALTH_HIDETHRESHOLD = "No mostrar por encima de los  (% de salud):",
	XTGIH_GUI_TOOLTIP_HEALTH_HIDETHRESHOLD = "Ejemplo : si pones 80, el latido de corazón será visible si tus puntos de salud caen por debajo del 80%.",
	XTGIH_GUI_OPTION_HEALTH_ALPHAMIN = "Opacidad mínima (%):",
	XTGIH_GUI_TOOLTIP_HEALTH_ALPHAMIN = "La opacidad mínima es el valor aplicado cuando no hay latido de corazón.",
	XTGIH_GUI_OPTION_HEALTH_ALPHAMAX = "Opacidad máxima (%):",
	XTGIH_GUI_TOOLTIP_HEALTH_ALPHAMAX = "La opacidad máxima es el valor aplicado cuando aparece el latido de corazón.",
 
	XTGIH_GUI_OPTION_HEALTH_CRITICALTHRESHOLD = "Umbral crítico (% de salud):",
	XTGIH_GUI_TOOLTIP_HEALTH_CRITICALTHRESHOLD = "Ejemplo: si pones 45, tu pantalla no perderá el matiz rojo hasta que tu salud no haya subido por encima del 45%",
}

for stringId, stringValue in pairs(strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end