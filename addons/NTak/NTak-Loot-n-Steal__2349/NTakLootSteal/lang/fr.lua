--	Bindings
ZO_CreateStringId("SI_BINDING_NAME_NTLOOT_OVERRIDE_SMART", "Outrepasser “Vol malin”")
ZO_CreateStringId("SI_BINDING_NAME_NTLOOT_TOGGLE_AUTOLOOT", "Basculer butin auto.")


--	Options
NTLnS_Texts = {
	choices = {
		hPosition = {
			"Gauche",
			"Centre",
			"Droite",
		},
		vPosition = {
			"Haut",
			"Centre",
			"Bas",
		}
	},
	actions = {
		take	= "Prendre",
		use		= "Utiliser",
	},
	insects = {
		"Papillon",
		"Flammouche",
		"Guêpe",
		"Mouches à viande",
		"Libellule",
		"Jeune netch",
		"Mouche chercheuse",
		"Mouche dovah de Seht",
	},
	seats = {
		"Siège",
	},
	isNeeded	= " doit être activé.",
	align		= "Alignement",
	alpha		= "Opacité",
	cat00 = {
		title	= "PARAMÈTRES PARTAGÉS TOUS PERSONNAGES",
	},
	cat0 = {
		title	= "RÉGLAGES PRÉFÉRÉS DU BUTIN",
		desc0	= "Ces paramètres écrasent les paramètres de butin normaux.",
		opt1	= "Butin automatique",
		opt2	= "Vol automatique",
	},
	cat1 = {
		title	= "AJUSTEMENT DU BUTIN",
		opt1	= "Empêcher le butin auto. si l'espace sac est faible",
		warn1	= "Le réglage de gameplay “Butin auto.” sera modifié dynamiquement.",
		opt1b	= "Seuil d'espace sac faible",
		opt11	= "Cacher l'interaction si le conteneur est vide",
		opt12	= "Cacher l'interaction sur les insectes",
	},
	cat2 = {
		title	= "AJUSTEMENT DU VOL",
		opt1	= "Activer le “Vol malin”",
		opt1b	= "“Override” par double-tap (en ms)",
		warn1	= "Le réglage de gameplay “Butin volé auto.” sera modifié dynamiquement.",
		desc1	= "“Vol malin” peut empêcher des vols accidentels, et donc des poursuites.\nSi incorrectement caché, les contenants seront ouverts mais non pillés,\net le vol à la tire ou d'objets disposés dans le monde seront empêchés.\nNote: Une touche “override” est paramétrable (garder appuyée puis voler).",
		menu	= "PARAMÈTRES AVANCÉS",
			desc10	= "Permet d'utiliser ou non le “Vol malin” pour chaque type d'action.\nDésactiver à vos risques et périls. Vous êtes prévenus !",
			opt10	= "Utiliser les paramètres avancés",
			opt11	= "Utiliser “Vol malin” pour les contenants",
			opt11b	= "Utiliser “Vol malin” pour le crochetage",
			opt12	= "Utiliser “Vol malin” pour les objets dans le monde",
			opt13	= "Utiliser “Vol malin” pour le vol à la tire",
		opt2	= "sur le raccourci clavier quand vol bloqué", -- [icon] ..
		opt2b	= "Position alternative pour ", -- .. icon
		opt3	= "Afficher les décomptes si recherché",
		opt4	= "Empêcher de s'asseoir quand caché",
	},
	cat3 = {
		title	= "AJOUT D'INFORMATIONS",
		sub0	= "DANS L'INVENTAIRE",
			opt01	= "Remplacer “Escape d'inventaire” par ", -- .. [icon]
			opt02	= "Ajouter un filtre “Volés” dans l'inventaire",
			opt03	= "À la ligne (compatibilité avec autres addons)",
			-- opt02tt = "Nécessite la bibliothèque \'LibFilters 3.0\' installée et activée!",
		sub1	= "DANS LA FENÊTRE DE BUTIN",
		sub2	= "INFORMATIONS À AFFICHER",
			opt21	= "Nombre d'objets dans le sac …",
			opt21b	= "Nombre de volés dans le sac", -- 
			opt22	= "Nombre d'objets recélés …",
			opt23	= "Nombre d'objects blanchis …",
			opt223	= "Regrouper recélés et blanchis",
			optRed	= "… en rouge s'il reste moins de :",
			opt24	= "Temps avant mise à zéro du recel/blanchiment",
	},
}