--                v 1.7.0               --
--[[
   à : \195\160    è : \195\168    ì : \195\172    ò : \195\178    ù : \195\185
   á : \195\161    é : \195\169    í : \195\173    ó : \195\179    ú : \195\186
   â : \195\162    ê : \195\170    î : \195\174    ô : \195\180    û : \195\187
   ã : \195\163    ë : \195\171    ï : \195\175    õ : \195\181    ü : \195\188
   ä : \195\164                    ñ : \195\177    ö : \195\182
   æ : \195\166                                    ø : \195\184
   ç : \195\167                                    œ : \197\147
   Ä : \195\132   Ö : \195\150   Ü : \195\156    ß : \195\159
]]

TimEmote = TimEmote or {}
local TE = TimEmote
TE.Lang = TE.Lang or {}

TE.Lang["fr"] = {
		LOCALE = "FR",

		Settings_control = "Réglages",
		Settings_title1 = "Fenêtre mobile",
		Settings_description1 = "Autorise le déplacement de la fenêtre TimEmote.",
		Settings_displaySize = "Taille d’affichage",
		Settings_displaySizeTip = "Modifie le texte, la hauteur et la largeur des listes d’emotes.",
		DisplaySize_compact = "Compacte (14)",
		DisplaySize_normal = "Normale (15)",
		DisplaySize_large = "Grande (16)",
		Settings_contrast = "Contraste du fond",
		Settings_contrastTip = "Règle l’intensité du fond des en-têtes et des listes d’emotes.",
		Settings_title3 = "Opacité",
		Settings_description3 = "Modifie l’opacité de la fenêtre TimEmote.",
		Settings_warning = "Rechargez l’interface pour appliquer cette modification.",
		Settings_group = "Noms des groupes",
		Settings_groupItem = "Groupe",
		Settings_groupItemTip = "Nom de ce groupe",
		Settings_groupNoname = "Sans nom",
		Settings_groupDefault = "Favoris",
		Settings_groupNewBtn = "Nouveau",
		Settings_groupNewBtnTip = "Ajouter un nouveau groupe",
		Settings_groupDeleteBtn = "Supprimer",
		Settings_groupDeleteBtnTip = "Supprimer ce groupe",
		Settings_groupDeleteWarning = "Ce groupe et tous ses favoris seront supprimés.",
		UI_list = "Liste",
		Message_notSelGroup = "Sélectionnez d’abord un groupe avec un clic gauche sur son titre.",
		Message_noEmote = "Aucune emote n’est disponible dans ce groupe.",
		Message_lastGroup = "Au moins un groupe doit être conservé.",
		Tooltip_playRandom = "Jouer une emote aléatoire",
		Tooltip_moveDown = "Déplacer vers le bas",
		Tooltip_moveUp = "Déplacer vers le haut",
		Tooltip_listHeader = "Emote :\nClic gauche : jouer\nMaj + clic gauche : ajouter/retirer du groupe actif\nDouble clic : couleur suivante",
		Tooltip_groupHeader = "En-tête :\nClic gauche : activer le groupe\n--------------------\nEmote :\nClic gauche : jouer\nMaj + clic gauche : retirer\nDouble clic : couleur suivante",
	}
