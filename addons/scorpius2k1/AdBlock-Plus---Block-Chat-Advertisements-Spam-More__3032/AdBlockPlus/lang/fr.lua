local strings = {
	SI_AD_BLOCK_PLUS_ENABLE			= "Activé",
	SI_AD_BLOCK_PLUS_ENABLE_TT		= "Activer/Désactiver AdBlock Plus",
	
	SI_AD_BLOCK_PLUS_NOTIFY			= "Notifications Bloquées",
	SI_AD_BLOCK_PLUS_NOTIFY_TT		= "Afficher Les Notifications Bloquées Dans Le Chat",

	SI_AD_BLOCK_PLUS_FRIEND			= "Notifications de statut d'ami",
	SI_AD_BLOCK_PLUS_FRIEND_TT		= "Afficher les notifications d'activation/désactivation de la connexion d'ami dans le chat",
	SI_AD_BLOCK_PLUS_FRIEND_TYPE	= "amie",
	SI_AD_BLOCK_PLUS_FRIEND_ONLINE	= "est connecté sur",
	SI_AD_BLOCK_PLUS_FRIEND_OFFLINE	= "s'est déconnecté",		

	SI_AD_BLOCK_PLUS_AGRESSIVE 		= "Filtrage Agressif",
	SI_AD_BLOCK_PLUS_AGRESSIVE_TT	= "Appliquer une vérification plus stricte de toutes les options de blocage activées",

	SI_AD_BLOCK_PLUS_BLOCK			= "Bloquer",
	SI_AD_BLOCK_PLUS_BLOCKED_ADVERT = "Annonce bloquée",
	SI_AD_BLOCK_PLUS_BLOCKED_SINCE 	= "Depuis l'installation",
	SI_AD_BLOCK_PLUS_BLOCKED_TOTAL 	= "Total Bloqué",

	SI_AD_BLOCK_PLUS_HEADER_BLOCKING = "Blocage",
	SI_AD_BLOCK_PLUS_HEADER_CHANNELS = "Canaux de chat surveillés",
	SI_AD_BLOCK_PLUS_HEADER_ADVANCED = "Avancé",

	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET = "Filtre prédéfini",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_TT = "Options prédéfinies pour le blocage",

	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_1 = "Basique",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_2 = "Avancé",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_3 = "Strict",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_4 = "Complet",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_5 = "Personnalisé",

	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_TT_1 = "• Succès, couronnes, guildes\n• Zone Channel",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_TT_2 = "• Succès, Couronnes, Guildes, URL\n• Zone, Criez, Dites les chaînes",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_TT_3 = "• Toutes les options de blocage\n• Zone, Crier, Guilde, Dire les canaux",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_TT_4 = "• Toutes les options de blocage\n• Tous les canaux",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_TT_5 = "Options définies par l'utilisateur",

	SI_AD_BLOCK_PLUS_HISTORY_LAST = "Durer",
	SI_AD_BLOCK_PLUS_DESCRIPTION_SLASH = "Commandes Slash",
	SI_AD_BLOCK_PLUS_DESCRIPTION_HISTORY = "Fenêtre Historique",
	SI_AD_BLOCK_PLUS_DESCRIPTION_SETTINGS = "Menu Paramètres",
	SI_AD_BLOCK_PLUS_WELCOME_FIRSTRUN = "Merci d'utiliser AdBlockPlus!",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
