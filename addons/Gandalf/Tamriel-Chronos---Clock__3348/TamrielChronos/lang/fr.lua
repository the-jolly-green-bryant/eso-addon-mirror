-----------------------------------------------------------------------------
-- 					      									               --
-- 	Title:		 Tamriel Chronos                    					   --
--	Description: Tamriel Time and astronomical data                        --
--	Author: 	 Gandalf (@Gandalf2675)									   --
-- 					      									               --
-----------------------------------------------------------------------------

local strings = {
	-- keybindings
	SI_BINDING_NAME_TAMRIELCHRONOS_CLOCK  = "Afficher / masquer l'horloge",			
	SI_BINDING_NAME_TAMRIELCHRONOS_ZOOM   = "marche / arrêt du zoom de l'horloge",			
	
	-- Chronos.lua		
	SI_TACHRONOS_PLAYER_ALERT		 = "J'ai joué plus de <<1>> minutes, s'il te plaît, fais une pause!",
	SI_TACHRONOS_PLAYER_ALERT_FINAL  = "J'ai joué plus de <<1>> minutes, s'il te plaît, fais une pause! (Rapport final)",
	
	-- cm.lua		
	SI_TACHRONOS_TITLE_CONF          = "Paramètres",
	
	SI_TACHRONOS_MODE                = "Type d'horloge",
	SI_TACHRONOS_MODE_tt             = "",

	SI_TACHRONOS_MODE_h24            = "24h double", 
	SI_TACHRONOS_MODE_monD           = "Lunes numérique",
	SI_TACHRONOS_MODE_mon            = "Lunes",    
	SI_TACHRONOS_MODE_noMoD          = "Horloge numérique",    
	SI_TACHRONOS_MODE_dualA          = "12h double analogique",   
	SI_TACHRONOS_MODE_dualD          = "12h double numérique",     
	SI_TACHRONOS_MODE_e24            = "24h double temps terrestre",     

	SI_TACHRONOS_DESC_h24            = "\nHorloge Tamriel avec 2e heure numérique, affichage jour / nuit, phases de lune et cadran qui s'adapte à la lumière du jour", 
	SI_TACHRONOS_DESC_monD           = "\nHorloge numérique avec phases de lune",
	SI_TACHRONOS_DESC_mon            = "\nPhase de lune",    
	SI_TACHRONOS_DESC_noMoD          = "",    
	SI_TACHRONOS_DESC_dualA          = "\nHorloge Tamriel avec 2e heure analogique et affichage des phases des lunes",   
	SI_TACHRONOS_DESC_dualD          = "\nHorloge Tamriel avec 2e heure numérique et affichage des phases des lunes",   
	SI_TACHRONOS_DESC_e24            = "\nHorloge de la Terre avec 2e heure numérique, superposition pour les nuits de Tamriel, phases de lune et cadran qui s'adapte à la lumière du jour", 
	
		
	SI_TACHRONOS_SECS                = "Afficher les secondes",
	SI_TACHRONOS_SECS_tt             = "",

	SI_TACHRONOS_REAL                = "Horloge numérique dans le temps de la Terre",
	SI_TACHRONOS_REAL_tt             = "ou en TST (Tamriel Standard Time)",

	SI_TACHRONOS_SCALE               = "Facteur d'échelle",
	SI_TACHRONOS_SCALE_tt            = "",

	SI_TACHRONOS_TIME_FONT           = "Fonte de l'horloge numérique",
	SI_TACHRONOS_TIME_FONT_tt        = "Police de l'affichage numérique de l'heure",
	
	SI_TACHRONOS_TIME_COLOR          = "Couleur de l'horloge numérique",
	SI_TACHRONOS_TIME_COLOR_tt       = "Couleur de l'affichage numérique de l'heure",

	SI_TACHRONOS_SHOW_HOLIDAYS       = "Afficher les vacances d'aujourd'hui dans le chat",
	SI_TACHRONOS_SHOW_HOLIDAYS_tt    = "Lors de la connexion, écrivez les liens des vacances d'aujourd'hui dans le chat",
	
	SI_TACHRONOS_HEALTH              = "Pauses en jeu",
	SI_TACHRONOS_HEALTH_tt           = "Rappel d'une pause dans le jeu après tant de minutes",
	
	SI_TACHRONOS_HIDE                = "Masquer l'horloge au démarrage",
	SI_TACHRONOS_HIDE_tt       	   = "",
	
	SI_TACHRONOS_HELP                = "L'aide",
	SI_TACHRONOS_HELP_F              = "",
	SI_TACHRONOS_HELP_F_DESC         = "Tamriel Chronos fournit des horloges basées sur l'heure de Tamriel, des données\n"
	                               .."astronomiques, un outil de conversion de l'heure et un calendrier des vacances.\n"
	                               .."\n"
								   .."Les horloges peuvent être déplacées librement et se souvenir de leur position.\n"
								   .."Les données astronomiques sont fournies dans l'info-bulle de l'horloge.\n"
								   .."Des raccourcis clavier peuvent être définis pour masquer et agrandir l'horloge.\n"
								   .."Cliquez avec le bouton droit de la souris pour afficher les données Chronos dans le chat.\n\n"
								   .."Avec un double-clic sur l'horloge ou avec un raccourci clavier défini, l'outil de conversion de l'heure s'affiche.\n\n"
								   .."Le calendrier des vacances de Tamriel est accessible via le bouton d'information dans l'outil\n"
								   .." de conversion de temps ou via un raccourci clavier.\n\n"
								   .."Les méthodes de conversion de l'heure de Tamriel sont basées sur:\n"
								   .."   - https://esoclock.uesp.net/\n"
								   .."Le calendrier des fêtes de Tamriel est basé sur:\n"
								   .."   - https://www.imperial-library.info/content/calendar-tamriel\n"
								   .."   - https://en.uesp.net/wiki/Lore:Holidays",	
								   								   
	-- base.lua/tooltip
	SI_TACHRONOS_M_WAINING		   = "(décroissante)",
	SI_TACHRONOS_M_WAXING		       = "(croissante)",
	SI_TACHRONOS_T_TITLE             = "Les temps",
	SI_TACHRONOS_T_REAL              = "\n   Terre:             %s  %02d.%02d.%04d",
	SI_TACHRONOS_T_TAMRIEL           = "\n   Tamriel:           %s  %02d.%02d.2E%03d\n",
	SI_TACHRONOS_M_TITLE             = "\Lunes",
	SI_TACHRONOS_M_LEVEL             = "\n   Niveau:            %.0f%%",
	SI_TACHRONOS_M_PHASE             = "\n   Phase:             %s %s\n",
	SI_TACHRONOS_E_TITLE             = "\nProchains événements",
	SI_TACHRONOS_E_SUNSET            = "\n   Coucher du soleil: ",
	SI_TACHRONOS_E_SUNRISE           = "\n   Lever du soleil:   ",
	SI_TACHRONOS_E_FULLMOON          = "\n   Pleine lunes:      ",
	SI_TACHRONOS_E_NEWMOON           = "\n   Nouvelles lunes:   ",
	SI_TACHRONOS_T_PLAYED            = "\nTemps joué:           %s\n",
	
	-- moon.lua
	SI_TACHRONOS_MOON_00X            = "???",
	SI_TACHRONOS_MOON_000            = "Nouvelle",
	SI_TACHRONOS_MOON_025            = "Premier croissant",
	SI_TACHRONOS_MOON_050            = "Premier quartier",
	SI_TACHRONOS_MOON_075            = "Gibbeuse croissante",
	SI_TACHRONOS_MOON_100            = "Pleine",
	SI_TACHRONOS_MOON_125            = "Gibbeuse décroissante",
	SI_TACHRONOS_MOON_150            = "Dernier quartier",
	SI_TACHRONOS_MOON_175            = "Dernier croissant",
	
	-- conv.lua
	SI_TACHRONOS_CONV_TITLE          = "Tamriel Chronos - Conversion",
	SI_TACHRONOS_CONV_EST            = "Heure de la Terre",
	SI_TACHRONOS_CONV_TST            = "Heure Tamriel",
	SI_TACHRONOS_CONV_NUMBER         = "Erreur: Les valeurs doivent être numériques",
	SI_TACHRONOS_CONV_HH             = "Erreur: Les heures doivent être comprises entre 0 et 23",
	SI_TACHRONOS_CONV_MM             = "Erreur: Les minutes doivent être comprises entre 0 et 59",
	SI_TACHRONOS_CONV_SS             = "Erreur: Les secondes doivent être comprises entre 0 et 59",
	SI_TACHRONOS_CONV_DD             = "Erreur: Les jours doivent être comprises entre 1 et 31",
	SI_TACHRONOS_CONV_MO             = "Erreur: Les mois doivent être comprises entre 1 et 12",
	SI_TACHRONOS_CONV_YY             = "Erreur: Les années doivent être comprises entre 2014 et 2037",
	SI_TACHRONOS_CONV_YY_T           = "Erreur: Les années doivent être comprises entre 2E 582..2E 679",
	SI_TACHRONOS_CONV_MOON           = "Lunes:  %.0f%% - %s %s",
	
    SI_TACHRONOS_TODAYS_HOLIDAYS            = "Tamriel Chronos - <<1>>",
    
    SI_TACHRONOS_CALENDAR_TITLE             = "Le calendrier des fêtes de Tamriel",

	SI_TACHRONOS_Legend_Year                = "Les mois",
	SI_TACHRONOS_Jan                        = "Janvier",
	SI_TACHRONOS_Feb                        = "Février",
	SI_TACHRONOS_Mar                        = "Mars",
	SI_TACHRONOS_Apr                        = "Avril",
	SI_TACHRONOS_May                        = "Mai",
	SI_TACHRONOS_Jun                        = "Juin",
	SI_TACHRONOS_Jul                        = "Juillet",
	SI_TACHRONOS_Aug                        = "Août",
	SI_TACHRONOS_Sep                        = "Septembre",
	SI_TACHRONOS_Oct                        = "Octobre",
	SI_TACHRONOS_Nov                        = "Novembre",
	SI_TACHRONOS_Dec                        = "Décembre",

	SI_TACHRONOS_Legend_Week                = "Les jours de la semaine",
	SI_TACHRONOS_Sunday                     = "Dimanche",
	SI_TACHRONOS_Monday                     = "Lundi",
	SI_TACHRONOS_Tuesday                    = "Mardi",
	SI_TACHRONOS_Wednesday                  = "Mercredi",
	SI_TACHRONOS_Thursday                   = "Jeudi",
	SI_TACHRONOS_Friday                     = "Vendredi",
	SI_TACHRONOS_Saturday                   = "Samedi",	
	

}

local pairs = pairs
for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end