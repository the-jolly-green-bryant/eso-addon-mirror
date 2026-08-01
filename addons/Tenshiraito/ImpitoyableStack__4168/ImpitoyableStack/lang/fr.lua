local localization_strings = {
	SLIDER_SIZE = "Taille de l'icone",
	SLIDER_SIZE2 = "Modifie la taille de l'icone",
	SLIDER_TEXT = "Taille du texte",
	SLIDER_TEXT2 = "Modifie la taille du texte",
	COLOR_PICKER = "Choisir la couleur du texte",
	COLOR_PICKER2 = "Modifie la couleur du texte",
	POS_X = "Position X",
	POS_X2 = "Modifie la position X de l'icone",
	POS_Y = "Position Y",
	POS_Y2 = "Modifie la position Y de l'icone",
	SLIDER_STACK = "Nombre de stack avant l'affichage de l'icone",
	SLIDER_STACK2 = "Modifie le nombre de stack",
	BUTTOM_HIDE = "Afficher/Masquer",
	BUTTOM_HIDE2 = "Affiche ou non l'icone pour la personnalisé",
	
	}
	for stringId, stringValue in pairs(localization_strings) do	
		ZO_CreateStringId(stringId, stringValue)
		SafeAddVersion(stringId, 1)
	end