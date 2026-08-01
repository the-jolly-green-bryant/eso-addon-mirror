if B1UI == nil then B1UI = {} end

local localization_strings = {
		SI_B1UI_ADDON_NAME = "Carnet 1",
		SI_B1UI_AUTHOR = "Bloodspill",
		SI_B1UI_VERSION_NUM = "|c00FF003.2|r",
			
		-- Settings Panel
		SI_B1UI_DESCRIPTION_INFO = "Un ordinateur portable virtuel.",
		
		SI_B1UI_HEADER_GENERAL = "Réglages Généraux",
		
		SI_B1UI_SHOWTITLE_LABEL = "Afficher le titre",
		SI_B1UI_SHOWTITLE_TOOLTIP = "Affiche le titre du livre.",		
		
		SI_B1UI_TITLE_LABEL = "Titre De Livre",		
		SI_B1UI_TITLE_TOOLTIP = "Change le titre du livre.",
		
		SI_B1UI_COLOR_LABEL = "Color Book",
		SI_B1UI_COLOR_TOOLTIP = "Change la couleur du livre.",
		
		SI_B1UI_DIALOG = "Dialogues de confirmation",
		SI_B1UI_DIALOG_TOOLTIP = "Active / désactive les boîtes de dialogue de confirmation.",
		
		SI_B1UI_LOCK_LABEL = "Position Lock",
		SI_B1UI_LOCK_TOOLTIP = "Cela vous permet de sécuriser le portable en place afin qu'il ne peut pas être déplacé.",	
		
		SI_B1UI_BUTTON_LABEL = "Afficher Chat Button",
		SI_B1UI_BUTTON_TOOLTIP = "Ajoute un bouton dans la fenêtre de chat pour ouvrir / fermer le livre.",

		SI_B1UI_OFFSETMAX_LABEL = "Décalage bouton de chat maximisée",
		SI_B1UI_OFFSETMAX_TOOLTIP = "Décalages le bouton dans la fenêtre de chat maximisée.",
		
		SI_B1UI_OFFSETMIN_LABEL = "Décalage bouton de chat minimisé",
		SI_B1UI_OFFSETMIN_TOOLTIP = "Décalages le bouton dans la fenêtre de chat minimisé.",
		
		SI_B1UI_WARNING = "Ce paramètre doit être appliqué et se traduira par un écran de chargement.",		
		
		-- UI Panel	
		SI_B1UI_CLOSEBUTTON_TOOLTIP = "Ferme le livre.",
		
		SI_B1UI_RUNBUTTON_TOOLTIP = "Exécutez cette page comme un script Lua.",		

		SI_B1UI_DELETEBUTTON_TITLE = "Supprimer la page",
		SI_B1UI_DELETEBUTTON_MAINTEXT = "Voulez-vous supprimer cette page?",
		SI_B1UI_DELETEBUTTON_TOOLTIP = "Supprimer cette page.",
		
		SI_B1UI_NEWBUTTON_TITLE = "Nouvelle Page",
		SI_B1UI_NEWBUTTON_MAINTEXT = "Voulez-vous créer une nouvelle page?",
		SI_B1UI_NEWBUTTON_TOOLTIP = "Créer une nouvelle page.",
		
		SI_B1UI_SAVEBUTTON_TITLE = "Enregistrer la page.",
		SI_B1UI_SAVEBUTTON_MAINTEXT = "Voulez-vous enregistrer les modifications apportées à la page?",
		SI_B1UI_SAVEBUTTON_TOOLTIP = "Enregistrer les modifications apportées à cette page.",
		
		SI_B1UI_UNDOPAGE_TITLE = "Annuler la page",
		SI_B1UI_UNDOPAGE_MAINTEXT = "Voulez-vous annuler toutes les modifications apportées à cette page? Il reviendra à la dernière sauvegarde.",
		SI_B1UI_UNDOBUTTON_TOOLTIP = "Annuler les modifications apportées à cette page.",
		
		SI_B1UI_INFORMATION_TOOLTIP = "Commandes:\n|c00FF00/nb1|r bascule la fenêtre on/off.\n|c00FF00/nb1s|r bascule les réglages on/off.\n|c00FF00/rl|r recharge de l'interface utilisateur.",
		
		SI_B1UI_YES_LABEL = "Oui",
		SI_B1UI_NO_LABEL = "Non",

		-- Controls Panel
		SI_B1UI_KEYBIND_LABEL = "Carnet 1",
	}

for stringId, stringValue in pairs(localization_strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end