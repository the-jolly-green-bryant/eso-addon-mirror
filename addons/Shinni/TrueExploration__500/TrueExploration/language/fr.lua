if not TrueExplor then
	TrueExplor = {}
	TrueExplor.lang = TrueExplor.lang or {}
end
 
local language = {
	chatCommands = "Commandes de chat",
	chatCommandsDesc = "/discovered, /undiscovered, /clearmap, /tedebug [0,1]",
	radiusSetting = "Réglages du rayon de révélation",
	dungeonRadius = "Rayon de révélation des donjons",
	dungeonRadiusDesc = "Détermine le nombre de cases découvertes dans les zones de donjon (taille de la carte <= 768).",
	townRadius = "Rayon de révélation des villages",
	townRadiusDesc = "Détermine le nombre de cases découvertes dans les zones de village (taille de la carte <= 1280).",
	islandRadius = "Rayon de révélation des îles",
	islandRadiusDesc = "Détermine le nombre de cases découvertes dans les zones d'île (ou de grande ville) (taille de la carte  <= 1536).",
	zoneRadius = "Rayon de révélation des zones globales",
	zoneRadiusDesc = "Détermine le nombre de cases découvertes dans les zones sauvages (taille de la carte <= 2048).",
	cyrodiilRadius = "Rayon de révélation en Cyrodiil",
	cyrodiilRadiusDesc = "Détermine le nombre de cases découvertes dans la zone de Cyrodiil (taille de la carte = 5120).",
	mapTypes = "Activation par type de carte",
	zone = "Cartes de zone",
	zoneDesc = "Si non activé, les cartes de zone sont toujours dévoilées.",
	subzone = "Cartes de zone intermédiaire",
	subzoneDesc = "Si non activé,  les cartes de zone intermédiaire (donjons, villes) sont toujours dévoilées.",
	graphicSettings = "Réglages graphiques",
	discovered = "Opacité des zones explorées",
	discoveredDesc = "0 ~ la carte est complètement visible, 255 ~ la carte est complètement cachée.",
	undiscovered = "Opacité des zones non explorées",
	undiscoveredDesc = "0 ~ la carte est complètement visible, 255 ~ la carte est complètement cachée.",
	
}
 
for type, string in pairs(language) do
	TrueExplor.lang[type] = string
end