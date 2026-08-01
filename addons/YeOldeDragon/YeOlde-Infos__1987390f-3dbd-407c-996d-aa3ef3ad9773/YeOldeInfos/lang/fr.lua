YeOldeInfos.QUEST_NAME = {
	[CRAFTING_TYPE_BLACKSMITHING] = "Commande de forge",
	[CRAFTING_TYPE_CLOTHIER] = "Commande de tailleur",
	[CRAFTING_TYPE_ENCHANTING] = "Commandes d'enchantement",
	[CRAFTING_TYPE_ALCHEMY] = "Commande d'alchimie",
	[CRAFTING_TYPE_PROVISIONING] = "Commande de cuisine",
	[CRAFTING_TYPE_WOODWORKING] = "Commande de travail du bois",
	[CRAFTING_TYPE_JEWELRYCRAFTING] = "Commande de joaillerie",
}

YeOldeInfos.STATES = {
	[YeOldeInfos.CraftingQuestStatus.UNAVAILABLE] = "Non disponible",
	[YeOldeInfos.CraftingQuestStatus.AVAILABLE] = "Disponible",
	[YeOldeInfos.CraftingQuestStatus.ACTIVE] = "Active",
	[YeOldeInfos.CraftingQuestStatus.READY_TO_DELIVER] = "Prête à déliverer",
	[YeOldeInfos.CraftingQuestStatus.COMPLETED] = "Complétée",
	[YeOldeInfos.CraftingQuestStatus.UNKNOWN] = "Statut inconnu",
}

YeOldeInfos.COND_DELIVER = "Livrez"

local STRINGS = {
	SI_YEOLDEINFOS_ACCOUNT_CURRENCY_HEADER = "Monnaies du compte",
	SI_YEOLDEINFOS_BAG = "Sac",
	SI_YEOLDEINFOS_BANK = "Banque: <<1>>",
	SI_YEOLDEINFOS_BAR_CONTENT = "Contenu affiché",
    SI_YEOLDEINFOS_BARS_OPTIONS = "Options des barres",
	SI_YEOLDEINFOS_CRAFTING_MATS = "Matériaux",
	SI_YEOLDEINFOS_CURRENCY_ALLIANCE_POINTS = "Points d'Alliance",
	SI_YEOLDEINFOS_CURRENCY_ARCHIVAL_FORTUNES = "Fortunes de l'Archive",
	SI_YEOLDEINFOS_CURRENCY_CHAOTIC_CREATIA = "Cristaux de transmutation",
	SI_YEOLDEINFOS_CURRENCY_CROWN_GEMS = "Gemmes à couronnes",
	SI_YEOLDEINFOS_CURRENCY_CROWNS = "Couronnes",
	SI_YEOLDEINFOS_CURRENCY_ENDEAVOR_SEALS = "Volontés",
	SI_YEOLDEINFOS_CURRENCY_HEADER = "Monnaies du joueur",
	SI_YEOLDEINFOS_CURRENCY_IMPERIAL_FRAGMENTS = "Fragments impériaux",
	SI_YEOLDEINFOS_CURRENCY_TELVAR_STONES = "Pierres de Tel Var",
	SI_YEOLDEINFOS_CURRENCY_TOME_POINTS = "Points de grimoire",
	SI_YEOLDEINFOS_CURRENCY_TRADE_BARS = "Barres de commerce",
	SI_YEOLDEINFOS_CURRENCY_WRIT_VOUCHERS = "Assignats",
	SI_YEOLDEINFOS_FONT_OPTIONS = "Police",
	SI_YEOLDEINFOS_FONT_SIZE = "Taille du texte",
	SI_YEOLDEINFOS_FONT_TYPE = "Police de caractère",
	SI_YEOLDEINFOS_HIDE_BAR_WHEN_COMPLETED = "Cacher la barre lorsque tout est complété",
	SI_YEOLDEINFOS_HIDE_BLOC_WHEN_COMPLETED = "Cacher chaque tâche complétée",
	SI_YEOLDEINFOS_HIDE_IN_MENU = "Cacher dans les menus",
	SI_YEOLDEINFOS_ICON_SIZE = "Taille des icônes",
	SI_YEOLDEINFOS_INV = "Inv: <<1>>",
	SI_YEOLDEINFOS_MAIL_HIDE_IF_NO_MAIL = "Cacher si aucun nouveau message",
	SI_YEOLDEINFOS_MAIL_HIDE_TEXT = "Afficher l'icône seulement",
	SI_YEOLDEINFOS_MATERIALS = "Matériaux :",
	SI_YEOLDEINFOS_MIN_CRAFTING_MATS = "Quantité minimale recommandée",
	SI_YEOLDEINFOS_MOVE_BAR = "Déplacer dans l'écran",
	SI_YEOLDEINFOS_PROMO_EVENTS_HEADER = "Événements promotionnels",
	SI_YEOLDEINFOS_PROMO_EVENTS_HIDE_WHEN_NO_EVENT = "Cacher si aucun événement actif",
	SI_YEOLDEINFOS_PROMO_EVENTS_NONE = "Aucun événement promotionnel actif.",
	SI_YEOLDEINFOS_SHOW_EXT_SETTINGS = "Personalisations avancées",
    SI_YEOLDEINFOS_SHOW_ONLY_IF_TRAIN = "Afficher seulement si prêt à entrainer",
	SI_YEOLDEINFOS_SHOW_STAMP_ICON = "Afficher les petites icônes ('étampes')",
	SI_YEOLDEINFOS_SPEED_DEFAULT = "Vitesse de base",
	SI_YEOLDEINFOS_SPEED_OPTIONS_DESC = "Options de calcul",
	SI_YEOLDEINFOS_SPEED_UPDATE_INTERVAL = "Vitesse de rafraîchissement",
	SI_YEOLDEINFOS_TIME_FORMAT = "Format 24H",
	SI_YEOLDEINFOS_TIME_SHOW_ICONS = "Afficher les icônes",
	SI_YEOLDEINFOS_TT_CRAFTING_HIDE_BAR =
		"Cacher la barre d'artisanat entière lorsque toutes vos commandes actives sont terminées ou prêtes à être livrées",
	SI_YEOLDEINFOS_TT_CRAFTING_HIDE_BLOC =
		"Cacher l'icône d'une commande d'artisanat spécifique une fois qu'elle est terminée ou prête à être livrée",
	SI_YEOLDEINFOS_TT_CURRENCY_ALLIANCE_POINTS =
		"Basculer l'affichage du widget de monnaie des points d'Alliance.",
	SI_YEOLDEINFOS_TT_CURRENCY_ARCHIVAL_FORTUNES =
		"Basculer l'affichage de monnaie des Fortunes de l'Archive.",
	SI_YEOLDEINFOS_TT_CURRENCY_CHAOTIC_CREATIA =
		"Basculer l'affichage de monnaie des cristaux de transmutation.",
	SI_YEOLDEINFOS_TT_CURRENCY_CROWN_GEMS = "Basculer l'affichage de monnaie des gemmes à couronnes.",
	SI_YEOLDEINFOS_TT_CURRENCY_CROWNS = "Basculer l'affichage de monnaie des couronnes.",
	SI_YEOLDEINFOS_TT_CURRENCY_ENDEAVOR_SEALS = "Basculer l'affichage de monnaie des Volontés.",
	SI_YEOLDEINFOS_TT_CURRENCY_IMPERIAL_FRAGMENTS =
		"Basculer l'affichage de monnaie des Fragments impériaux.",
	SI_YEOLDEINFOS_TT_CURRENCY_TELVAR_STONES =
		"Basculer l'affichage du widget de monnaie des pierres de Tel Var.",
	SI_YEOLDEINFOS_TT_CURRENCY_TOME_POINTS = "Basculer l'affichage de monnaie des Points de grimoire.",
	SI_YEOLDEINFOS_TT_CURRENCY_TRADE_BARS = "Basculer l'affichage de monnaie des barres de commerce.",
	SI_YEOLDEINFOS_TT_CURRENCY_WRIT_VOUCHERS = "Basculer l'affichage du widget de monnaie des assignats.",
	SI_YEOLDEINFOS_TT_FONT_SIZE = "Changer la taille du texte",
	SI_YEOLDEINFOS_TT_FONT_TYPE = "Changer la police d'écriture utilisée pour le texte",
	SI_YEOLDEINFOS_TT_HIDE_IN_MENU = "Cacher la barre lorsque vous ouvrez les menus du jeu",
	SI_YEOLDEINFOS_TT_ICON_SIZE = "Changer la taille des icônes",
	SI_YEOLDEINFOS_TT_MAIL_HIDE =
		"Cacher complètement la barre de courrier lorsque vous n'avez pas de nouveau courrier",
	SI_YEOLDEINFOS_TT_MAIL_HIDE_TEXT =
		"Cacher le texte '1' et n'afficher que l'icône de courrier lorsque vous avez de nouveaux courriers",
	SI_YEOLDEINFOS_TT_MIN_CRAFTING_MATS =
		"Quantité minimale de matériaux à conserver dans votre inventaire pour chaque type d'artisanat",
	SI_YEOLDEINFOS_TT_MOVE_BAR = "Déplacez la barre en utilisant le joystick gauche (Manette uniquement)",
	SI_YEOLDEINFOS_TT_PROMO_HIDE =
		"Cacher la barre des événements promotionnels lorsqu'il n'y a pas d'événement actif",
	SI_YEOLDEINFOS_TT_SHOW_EXT_SETTINGS = "Lorsqu'activé, les paramètres de police sont disponibles pour chaque barre, ainsi que quelques autres options.",
	SI_YEOLDEINFOS_TT_SHOW_STAMP_ICON =
		"Afficher une petite icône par-dessus l'icône principale pour des états spécifiques (ex: sacs pleins)",
	SI_YEOLDEINFOS_TT_SPEED_CALIBRATE = "Définir la valeur de vitesse qui correspond à 100%",
	SI_YEOLDEINFOS_TT_SPEED_UPDATE =
		"Une valeur plus basse mettra à jour la vitesse plus souvent, mais peut impacter les performances (en millisecondes)",
	SI_YEOLDEINFOS_TT_TIME_FORMAT = "Utiliser le format 24h au lieu de 12h AM/PM",
	SI_YEOLDEINFOS_TT_TIME_SHOW_ICONS = "Afficher une icône de soleil ou de lune à côté de l'heure",
	SI_YEOLDEINFOS_TT_TRAIN_READY =
		"N'afficher la barre d'entraînement de la monture que lorsque celle-ci est prête à être entraînée",
	SI_YEOLDEINFOS_UNTRACKED_MATS = "(Matériaux non suivis pour ce type)",
}

local function OverrideString(stringIdName, value)
	local stringId = _G[stringIdName]
	if stringId ~= nil then
		SafeAddString(stringId, value, 2)
	else
		ZO_CreateStringId(stringIdName, value)
	end
end

for stringIdName, value in pairs(STRINGS) do
	OverrideString(stringIdName, value)
end
