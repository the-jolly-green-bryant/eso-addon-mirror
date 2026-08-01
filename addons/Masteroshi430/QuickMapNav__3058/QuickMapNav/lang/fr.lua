
local strings = {
	DEFAULT_TOPLEFT = "Noms de zones & heure en haut à gauche",
	PERFECT_PIXEL = "Utile pour les utilisateurs de PerfectPixel ;-)",
	LESS_FLASHY = "Luminosité de la carte",
	LESS_FLASHY_TOOLTIP = "Atténuer la luminosité de la carte pour moins se défoncer les yeux la nuit.\n87 c'est bien\n100 c'est le réglage ESO par défaut",
	DESATURATION = "Désaturation de la carte",
	DESATURATION_TOOLTIP = "Désaturer les couleurs de la carte.\n20 c'est bien\n0 c'est le réglage ESO par défaut",
	SECONDS = "Forcer le format 24h avec secondes sur l'horloge de la carte",
	SECONDS_TOOLTIP = ":-)",
	TO = "Vers ",
	WAYSHRINE = "Sanctuaire",
	WAYSHRINE_ONLY = "Ne peut être visitée que via un sanctuaire.",
	ABBR = "Forts Abréviés",
	ABBR_TOOLTIP = "Afficher le nom international abrévié des forts de Cyrodiil.",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
