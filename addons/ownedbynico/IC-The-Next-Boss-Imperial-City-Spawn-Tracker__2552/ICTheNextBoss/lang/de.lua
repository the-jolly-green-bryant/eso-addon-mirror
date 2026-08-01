local strings = {

	-- BOSSES
	SI_ICTHENEXTBOSS_AMONCRUL = "Amoncrul",
	SI_ICTHENEXTBOSS_THIRSK = "Baron Thirsk",
	SI_ICTHENEXTBOSS_GLORGOLOCH = "Glorgoloch der Zerstörer",
	SI_ICTHENEXTBOSS_CHARR = "Entflammer Charr",
	SI_ICTHENEXTBOSS_KHROGO = "König Khrogo",
	SI_ICTHENEXTBOSS_MALYGDA = "Fürstin Malygda",
	SI_ICTHENEXTBOSS_MAZALUHAD = "Mazaluhad",
	SI_ICTHENEXTBOSS_NUNATAK = "Nunatak",
	SI_ICTHENEXTBOSS_MATRON = "Die kreischende Matrone",
	SI_ICTHENEXTBOSS_VOLGHASS = "Volghass",
	SI_ICTHENEXTBOSS_YSENDA = "Ysenda Strahlenpracht",
	SI_ICTHENEXTBOSS_ZOAL = "Zoal der Immerwache",
	SI_ICTHENEXTBOSS_MOLAG = "Das Simulakrum von Molag Bal",

	-- DISTRICTS
	SI_ICTHENEXTBOSS_NOBLESDISTRICT = "5-Adelsbezirk",
	SI_ICTHENEXTBOSS_ARENADISTRICT = "2-Arenabezirk",
	SI_ICTHENEXTBOSS_TEMPLEDISTRICT = "4-Tempelbezirk",
	SI_ICTHENEXTBOSS_ARBORETUMDISTRICT = "3-Baumgartenbezirk",
	SI_ICTHENEXTBOSS_MEMORIALDISTRICT = "1-Gedenkbezirk",
	SI_ICTHENEXTBOSS_ELVENGARDENSDISTRICT = "6-Elfengartenbezirk",
	SI_ICTHENEXTBOSS_CAN = "0-Kanalisation",
	
	
	SI_BINDING_NAME_SI_ICTHENEXTBOSS_NOBLESDISTRICT = "5-Adelsbezirk",
	SI_BINDING_NAME_SI_ICTHENEXTBOSS_ARENADISTRICT = "2-Arenabezirk",
	SI_BINDING_NAME_SI_ICTHENEXTBOSS_TEMPLEDISTRICT = "4-Tempelbezirk",
	SI_BINDING_NAME_SI_ICTHENEXTBOSS_ARBORETUMDISTRICT = "3-Baumgartenbezirk",
	SI_BINDING_NAME_SI_ICTHENEXTBOSS_MEMORIALDISTRICT = "1-Gedenkbezirk",
	SI_BINDING_NAME_SI_ICTHENEXTBOSS_ELVENGARDENSDISTRICT = "6-Elfengartenbezirk",
	SI_BINDING_NAME_SI_ICTHENEXTBOSS_CAN = "0-Kanalisation",

	-- GUI
	SI_ICTHENEXTBOSS_GUI_WIDTH = "200",
	SI_ICTHENEXTBOSS_OPTION_DESCRIPTION = "Trackt die Spawnzeiten der Bosse in der Kaiserstadt.",
	SI_ICTHENEXTBOSS_OPTION_TIMETABLE = "Tabelle mit Countdowns",
	SI_ICTHENEXTBOSS_OPTION_MAPTIMERS = "Countdowns auf Kaiserstadt Karte",
	SI_ICTHENEXTBOSS_OPTION_MAPTIMERS_TOOLTIP = "Deaktiviert den Zoom auf der Kaiserstadt Karte.\nFunktioniert nicht im Gamepad-Modus!",
	SI_ICTHENEXTBOSS_OPTION_EVENT_TIMERS = "Event Timer (7 Minuten)",
	SI_ICTHENEXTBOSS_OPTION_OPACITY = "Deckkraft (Cursor entfernt)",
	SI_ICTHENEXTBOSS_OPTION_OPACITY_TOOLTIP = "Transparenz des Fensters, wenn sich die Maus nicht darüber befindet. Bei Mausberührung voll deckend.",
	SI_ICTHENEXTBOSS_OPTION_HIDE_COMBAT = "Im Kampf ausblenden",
	SI_ICTHENEXTBOSS_OPTION_HIDE_MOVING = "Beim Bewegen ausblenden",
	SI_ICTHENEXTBOSS_OPTION_REDUCED = "Reduzierte Anzeige (nur nächster Bezirk)",
	SI_ICTHENEXTBOSS_OPTION_REDUCED_TOOLTIP = "Verkleinert das Fenster, sodass nur der nächste Bezirk angezeigt wird.",
	SI_ICTHENEXTBOSS_OPTION_DEBUG = "Debug",
	SI_ICTHENEXTBOSS_NO_TIMERS = "Keine Timer",
}

for id, value in pairs(strings) do
	ZO_CreateStringId(id, value)
	SafeAddVersion(id, 1)
end

