local strings = {

	-- BOSSES
	SI_ICTHENEXTBOSS_AMONCRUL = "Amoncrul",
	SI_ICTHENEXTBOSS_THIRSK = "Le baron Thirsk",
	SI_ICTHENEXTBOSS_GLORGOLOCH = "Glorgoloch le destructeur",
	SI_ICTHENEXTBOSS_CHARR = "L'immolateur Charr",
	SI_ICTHENEXTBOSS_KHROGO = "Le roi Khrogo",
	SI_ICTHENEXTBOSS_MALYGDA = "Dame Malygda",
	SI_ICTHENEXTBOSS_MAZALUHAD = "Mazaluhad",
	SI_ICTHENEXTBOSS_NUNATAK = "Nunatak",
	SI_ICTHENEXTBOSS_MATRON = "La matrone hurlante",
	SI_ICTHENEXTBOSS_VOLGHASS = "Volghass",
	SI_ICTHENEXTBOSS_YSENDA = "Ysenda la resplendissante",
	SI_ICTHENEXTBOSS_ZOAL = "Zoal l'Éveillé",
	SI_ICTHENEXTBOSS_MOLAG = "Le simulacre de Molag Bal",

	-- DISTRICTS
	SI_ICTHENEXTBOSS_NOBLESDISTRICT = "5-Nobles",
	SI_ICTHENEXTBOSS_ARENADISTRICT = "2-L'Arene",
	SI_ICTHENEXTBOSS_TEMPLEDISTRICT = "4-Temple",
	SI_ICTHENEXTBOSS_ARBORETUMDISTRICT = "3-L'Arboretum",
	SI_ICTHENEXTBOSS_MEMORIALDISTRICT = "1-Souvenir",
	SI_ICTHENEXTBOSS_ELVENGARDENSDISTRICT = "6-Jardin elfique",
	SI_ICTHENEXTBOSS_CAN = "0-Égouts Impériaux",
	
	SI_BINDING_NAME_SI_ICTHENEXTBOSS_NOBLESDISTRICT = "5-Nobles",
	SI_BINDING_NAME_SI_ICTHENEXTBOSS_ARENADISTRICT = "2-L'Arene",
	SI_BINDING_NAME_SI_ICTHENEXTBOSS_TEMPLEDISTRICT = "4-Temple",
	SI_BINDING_NAME_SI_ICTHENEXTBOSS_ARBORETUMDISTRICT = "3-L'Arboretum",
	SI_BINDING_NAME_SI_ICTHENEXTBOSS_MEMORIALDISTRICT = "1-Souvenir",
	SI_BINDING_NAME_SI_ICTHENEXTBOSS_ELVENGARDENSDISTRICT = "6-Jardin elfique",
	SI_BINDING_NAME_SI_ICTHENEXTBOSS_CAN = "0-Égouts Impériaux",

	-- GUI
	SI_ICTHENEXTBOSS_GUI_WIDTH = "230",
	SI_ICTHENEXTBOSS_OPTION_DESCRIPTION = "Tracks spawn times of bosses in Imperial City.",
	SI_ICTHENEXTBOSS_OPTION_TIMETABLE = "Table with spawntimes",
	SI_ICTHENEXTBOSS_OPTION_MAPTIMERS = "Spawntimes on IC map",
	SI_ICTHENEXTBOSS_OPTION_MAPTIMERS_TOOLTIP = "This will disable zoom on Imperial City map.\nDoes not work with Gamepad-Mode!",
	SI_ICTHENEXTBOSS_OPTION_EVENT_TIMERS = "Event timers (7 minutes)",
	SI_ICTHENEXTBOSS_OPTION_OPACITY = "Opacité (curseur éloigné)",
	SI_ICTHENEXTBOSS_OPTION_OPACITY_TOOLTIP = "Transparence de la fenêtre lorsque la souris n'est pas dessus. Entièrement opaque au survol.",
	SI_ICTHENEXTBOSS_OPTION_HIDE_COMBAT = "Masquer en combat",
	SI_ICTHENEXTBOSS_OPTION_HIDE_MOVING = "Masquer en déplacement",
	SI_ICTHENEXTBOSS_OPTION_REDUCED = "Affichage réduit (prochain district uniquement)",
	SI_ICTHENEXTBOSS_OPTION_REDUCED_TOOLTIP = "Réduit la fenêtre pour n'afficher que le prochain district à frapper.",
	SI_ICTHENEXTBOSS_OPTION_DEBUG = "Débogage",
	SI_ICTHENEXTBOSS_NO_TIMERS = "Aucun timer",
}

for id, value in pairs(strings) do
	ZO_CreateStringId(id, value)
	SafeAddVersion(id, 1)
end