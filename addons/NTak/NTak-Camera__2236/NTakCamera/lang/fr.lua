--	Bindings
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_SWAP",			"Changer d'épaule")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_SWAP_X",		"Changer d'épaule (rapide)")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_SWAPCENTER",	"Changer/Centrer")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_SWAPCENTER_X",	"Changer/Centrer (rapide)")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_CENTER",		"Centrer la caméra")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_CENTER_X",		"Centrer la caméra (rapide)")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_ALT_ALL",		"Alt. Valeurs de caméra")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_ALT_DIST",		"Alt. Distance")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_ALT_FOV",		"Alt. Champ de vision")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_SIEGE",		"Basculer la caméra siège")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_STATIC0",		"Caméra préférée")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_STATIC1",		"Caméra statique n°1")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_STATIC2",		"Caméra statique n°2")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_STATIC3",		"Caméra statique n°3")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_TOGGLE_CHAT",	"ON/OFF - Caméra Discussion")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_TOGGLE_CRAFT",	"ON/OFF - Caméra Artisanat")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_TOGGLE_LOCKP",	"ON/OFF - Caméra Crochetage")


--	Options
NTCam_Texts = {
	cat0 = {
		title	= "PARAMÈTRES PARTAGÉS TOUS PERSONNAGES",
	},
	cat1 = {
		title	= "CAMÉRA PRÉFÉRÉE",
		desc1	= "Ces paramètres écrasent les paramètres caméra normaux.",
		opt1	= "Distance du personnage (0 pour 1ère personne)",
    	opt1b	= "Champ visuel",
		opt2	= "Côté pour la caméra épaule",
		choices = {
			"Centre",
			"Gauche",
			"Droite",
		},
		opt3	= "Position horizontale",
		opt3b	= "Décalage horizontal (statique)",
		warn3b	= "Ce paramètre ne sera pas altéré par les interactions/événements.",
		opt4	= "Décalage vertical",
		opt5	= "Décalage vertical (en centré)",
		warn5	= "Ce réglage n'est utilisé que lors d'un basculement en caméra centrée en utilisant la commande associée.\nSi vous utilisez seulement la caméra en centré, merci de régler les deux “Décalage vertical” à la même valeur.",
		--
		desc11	= "Après une “interaction” ou un “événement”, les paramètres de caméra précédents seront restaurés. Sauf si vous voulez revenir en caméra préférée :",
		opt11	= "Restaurer la caméra préférée (pas précédente)",
		--
	},
	cat2 = {
		title0	= "CAMÉRAS ALTERNATIVES",
		desc0	= "Cela ne peut être fait qu'avec des “commandes”.",
		title1	= "VALEURS ALTERNATIVES",
		desc1	= "Les valeurs alternatives peuvent remplacer les valeurs de la caméra par défaut.", -- KLINGO
		title2	= "CAMÉRAS STATIQUES",
		desc2	= "Vous pouvez basculer vers ces caméras en utilisant les “commandes”.\nElles ne seront PAS affectées par les interactions ou les événements,\n et sont prévues pour un usage temporaire seulement.", -- \nÀ noter que ces caméras disposent d'une plage de position horizontale étendue.",
		opt0	= "Afficher le changement de caméra dans le chat",
		msg0	= "Basculement en caméra statique ",
		menuX	= "Caméra statique n°",
		opt1	= "Distance",
		opt2	= "Champ visuel",
		opt3	= "Position horizontale",
		opt3b	= "Décalage horizontal",
		opt4	= "Décalage vertical",
	},
	menuX = {
		opt0	= "Empêcher le changement de caméra par défaut",
		warn1	= "Vous devez utiliser “Ne pas changer de caméra sur interaction” pour que ceci fonctionne.",
		opt1	= "Profil",
		choices = {
			"Ne rien faire",
			"Centrer en 3ème personne",
			"Basculer en 1ère personne",
			"Basculer en 3ème personne",
			"Dézoomer",
			"Focus",
			"Personnalisé",
		},
		opt2	= "Changer la distance …",
		opt2b	= "Changer le champ visuel …",
		opt3	= "Changer la position horizontale …",
		opt4	= "Changer la position verticale …",
		opt5	= "Délai pour restaurer la caméra (x 100ms)",
		to		= "… en :",
		opt10	= "Pas d'autre changement tant que ", -- .. Menu title
	},
	cat3 = {
		title	= "CAMÉRAS D'INTERACTIONS", -- "CHANGEMENTS DE CAMÉRA SUR INTERACTIONS",
		desc1	= "Gérer comment les interactions changent la caméra préférée.",
		menu1 = {
			title	= "Discussion",
		},
		menu2 = {
			title	= "Atelier d'artisanat",
		},
		menu3 = {
			title	= "Atelier de tenue",
		},
		menu4 = {
			title	= "Crochetage",
		},
	},
	cat4 = {
		title	= "CAMÉRAS D'ÉVÉNEMENTS", -- CHANGEMENTS DE CAMÉRA SUR ÉVÉNEMENTS
		desc1	= "Gérer comment les événements changent la caméra préférée.",
		menu0 = {
			title	= "en mouvement",
			opt1	= "Afficher la vitesse dans le chat",
			opt2	= "Limite mouvement / sprint",
			desc1	= "Quand la vitesse de course est au-dessus de la limite définie (e.g. en sprintant), les paramètres ci-dessous peuvent écraser ceux de dessus.",
		},
		menu1 = {
			title	= "sur monture",
		},
		menu2 = {
			title	= "furtif",
		},
		menu3 = {
			title	= "Dégainer/ranger l'arme",
			desc1	= "L'événement “dégainer/ranger l'arme” n'est déclenché que par l'utilisation du raccourci clavier. (Utiliser des compétences ne le déclenche pas.)\nL'option ci-dessous permet de déclencher l'événement “dégainer” au début d'un combat.",
			opt1	= "Entrer en combat déclenche “dégainer”",
		},
		menu4 = {
			title	= "en combat",
			opt1	= "Ranger automatiquement l'arme après combat",
		},
		menu5 = {
			title	= "en loup-garou",
			opt1	= "Garder cette distance minimum en loup-garou",
		},
	}
}