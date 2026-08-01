local L = {}

for stringId, stringValue in pairs(L) do
	SafeAddString(_G[stringId], stringValue, 0)
end


CarosAutoMarker.PreSetEnemies = {
	[636]= { -- HRC
		"welwa enragé",
		"Primage tresse-chaîne",
		"façonne-feu anka-ra",
		"Primage surchargeur",
		"Primage surchargeuse",
	}, 	
	[638]= { -- AA
		"Primage surchargeur",
		"Primage surchargeuse",
	}, 
	[639]= { -- SO
		"surchargeur de la Cour écailleuse",
	}, 
	[725]= { -- MoL
		"mange-soleil dro-m'Athra",
		"sauvage dro-m'Athra",
		"chaman ogre",
		"déchiqueteur ogre",
	}, 
	[975]= { -- HoF
		"capacitrice",
		"arquebuse refabriquée",
		"chasseur-tueur négatrix",
		"chasseur-tueur positrox",
	}, 
	[1000]= { -- AS
		"purificateur ordonné",
	}, 
	[1051]= { -- CR
		"ombre des défunts",
		"sphère malveillante",
		"ombre de Siroria",
		"ombre de Relequen",
		"ombre de Galenwe",
	}, 
	[1121]= { -- SS
		"destin d'Alkosh",
		"atronach de foudre",
		"volonté d'Alkosh",
		"atronach de feu",
		"statue vigile",
		"griffe-de-vent de Jone".
		"croc-de-feu de Jode",
		"Senche-raht",
		"rugissement d'Alkosh",
	}, 
	[1196]= { -- KA
		"infuseuse vampire",
		"brisemarée demi-géant",
		"chamane marine demi-géante",
		"chaman marin demi-géant",
		"infuseur vampire",
		"rempart demi-géant",
	}, 
	[1263] = { -- RG
		"tisse-âmes sul-xan",
		"Météore principal",
		"bénémoth de feu",
		"abomination de chair",
		"boucher ravagerel",
		"barbare ravagerel",
		"torcheur ravagerel",
		
	}, 	
	[1344] = { -- DSR
		"coupe-quille des Voiles funestes",
		"brasseuse des Voiles funestes",
		"brasseur des Voiles funestes",
	},
}
