-- Settings
ZO_CreateStringId("SI_ARCHEM_MENU_WARNING" , "Ce réglage doit être appliqué et peut provoquer un écran de chargement.");
ZO_CreateStringId("SI_ARCHEM_MAP_ENHANCEMENTS" , "Modifications de la carte");

ZO_CreateStringId("SI_ARCHEM_PIN_SCALING" , "Modification de l'échelle des marqueurs");
ZO_CreateStringId("SI_ARCHEM_PIN_SCALING_TOOLTIP" , "Active la modification de la dimension des marqueurs.");

ZO_CreateStringId("SI_ARCHEM_PIN_SCALE_FACTOR" , "Taille des marqueurs");
ZO_CreateStringId("SI_ARCHEM_PIN_SCALE_FACTOR_TOOLTIP" , "Détermine la dimension des marqueurs sur la carte (0.1 = minimum, 0.5 = moitié, 1 = taille par défaut, 2 = double).");

ZO_CreateStringId("SI_ARCHEM_ONLY_ESO_MAP_PINS" , "Appliquer uniquement aux marqueurs d'origine");
ZO_CreateStringId("SI_ARCHEM_ONLY_ESO_MAP_PINS_TOOLTIP" , "Modifie uniquement la taille des marqueurs du jeu d'origine.");

ZO_CreateStringId("SI_ARCHEM_CLEAR_PIN_DATA" , "Réinitialisation");
ZO_CreateStringId("SI_ARCHEM_CLEAR_PIN_DATA_TOOLTIP" , "Réinitialise la taille des marqueurs enregistrée en mémoire. L'option 'Modification de l'échelle des marqueurs' devra être réactivée. Activer ce bouton  entraîne le rechargement de l'interface utilisateur.");

ZO_CreateStringId("SI_ARCHEM_LOCATION_TELEPORT" , "Téléportation vers contacts");
ZO_CreateStringId("SI_ARCHEM_LOCATION_TELEPORT_TOOLTIP" , "Active la possibilité de se téléporter vers un lieu dans lequel un ami, un membre de guilde ou de groupe se trouve en faisant un clic droit dans la liste des lieux de la carte principale.");

ZO_CreateStringId("SI_ARCHEM_LOCATION_ORDER" , "Ordre des lieux par date");
ZO_CreateStringId("SI_ARCHEM_LOCATION_ORDER_TOOLTIP" , "Affiche les lieux les plus recemment utilisés pour se téléporter en premier.");

ZO_CreateStringId("SI_ARCHEM_LOCATION_TELEPORT_STATUS" , "Statut des lieux de téléportation");
ZO_CreateStringId("SI_ARCHEM_LOCATION_TELEPORT_STATUS_TOOLTIP" , "Affiche les zones dans lesquelles ne se trouvent aucun joueur vers lequel effectuer un voyage rapide.");

-- Initialize
ZO_CreateStringId("SI_ARCHEM_UI_SHORTCUT_TERTIARY" , "Rafraîchir");
ZO_CreateStringId("SI_ARCHEM_REMOVE_WAYPOINT" , "Retirer le point de passage");
ZO_CreateStringId("SI_ARCHEM_REMOVE_WAYPOINT_HOTKEY" , "- Définir un raccourci pour supprimer le point de passage.");

--[[ EasyTravel Integrated / Embedded Version Translations ]]--
if (EasyTravel_AEM ~= nil) then
	local localization = { -- provided by Ayantir
		JUMP_FAILED_UNHANDLED = "La téléportation a été interrompu, erreur inconnue : %d, %s",
		
		STATUS_TEXT_READY = "Préparation de la téléportation",
		STATUS_TEXT_JUMP_REQUESTED = "Téléportation demandée",
		STATUS_TEXT_JUMP_STARTED = "Téléportation en cours (<<1>> secondes restantes)",
		STATUS_TEXT_JUMP_REQUEST_FAILED = "Échec de la téléportation",
		STATUS_TEXT_NO_JUMP_TARGETS = "Aucun joueur n'a été trouvé pour la téléportation.\nEn attente de nouveaux joueurs.",
		
		DIALOG_TITLE = "Voyager vers <<1>>",
		
		INVALID_TARGET_ZONE = "La destination ne peut être atteinte via la téléportation",
		
		AUTOCOMPLETE_ZONE_LABEL_TEMPLATE = "<<1>> -|caaaaaa <<2[Aucun joueur/$d joueur/$d joueurs]>>",
	}
	ZO_ShallowTableCopy(localization, EasyTravel_AEM.Localization);
end
