--[[
Author: xTG
Filename: fr.lua
Version: 1
]]--

-- Messages settings
local strings = {
	XTGII_GUI_OPTION_DESCRIPTION_LINE_1 = "Immersive Interface tente d'apporter plus d'immersion au jeu en vous cachant des éléments d'interface afin de vous laisser profiter de la beauté du monde qui vous entoure.",

	XTGII_GUI_OPTION_MENU_INTERFACE = "Interface",
	XTGII_GUI_OPTION_INTERFACE_DESCRIPTION_LINE = "Masquer des éléments de l'interface.",

	XTGII_GUI_OPTION_INTERFACE_QUEST_TRACKER = "Quête en cours",
	XTGII_GUI_OPTION_INTERFACE_COMPASS = "Boussole",
	XTGII_GUI_OPTION_INTERFACE_SKILLBAR = "Compétences",
	XTGII_GUI_OPTION_INTERFACE_PLAYER_ATTRIBUTES_BARS = "Vie/Mana/Stamina",
	XTGII_GUI_OPTION_INTERFACE_TARGET_FRAME = "Cible",
	XTGII_GUI_OPTION_INTERFACE_EQUIPMENT_STATUS = "Status de l'équipement",


	XTGII_GUI_OPTION_MENU_HEALTH = "Santé",

	XTGII_GUI_OPTION_HEALTH_DESCRIPTION_LINE_1 = "Immersive Health tente d'apporter plus d'immersion dans les combats en s'affranchissant de l'indication numéraire des points de vie.",
	XTGII_GUI_OPTION_HEALTH_DESCRIPTION_LINE_2 = "Nous vous proposons ici de configurer l'équivalent d'un battement de coeur qui va devenir de plus en plus insistant à mesure que vous vous rapprochez de la mort.",

	XTGIH_GUI_OPTION_HEALTH_ONLY_IN_FIGHT = "N'afficher qu'en combat",
	XTGIH_GUI_OPTION_HEALTH_HIDETHRESHOLD = "Ne pas afficher avant (% de vie):",
	XTGIH_GUI_TOOLTIP_HEALTH_HIDETHRESHOLD = "Exemple : si vous renseignez 80, vous n'apercevrez les battements de coeur que lorsque vos points de vie descendent en dessous de 80%.",
	XTGIH_GUI_OPTION_HEALTH_ALPHAMIN = "Opacité minimum (%):",
	XTGIH_GUI_TOOLTIP_HEALTH_ALPHAMIN = "L'opacité minimum est la valeur quand aucun battement n'intervient.",
	XTGIH_GUI_OPTION_HEALTH_ALPHAMAX = "Opacité maximum (%):",
	XTGIH_GUI_TOOLTIP_HEALTH_ALPHAMAX = "L'opacité maximum est la valeur quand le battement de coeur est affiché.",

	XTGIH_GUI_OPTION_HEALTH_CRITICALTHRESHOLD = "Seuil critique (% de vie):",
	XTGIH_GUI_TOOLTIP_HEALTH_CRITICALTHRESHOLD = "Exemple : si vous renseignez 45, vous resterez avec un écran teinté de rouge tant que vous ne remonterez pas au dessus de 45% de points de vie.",
}

for stringId, stringValue in pairs(strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end