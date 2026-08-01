local strings = {

	-- BOSSES
	SI_ICTHENEXTBOSS_AMONCRUL = "Amoncrul",
	SI_ICTHENEXTBOSS_THIRSK = "Baron Thirsk",
	SI_ICTHENEXTBOSS_GLORGOLOCH = "Glorgoloch the Destroyer",
	SI_ICTHENEXTBOSS_CHARR = "Immolator Charr",
	SI_ICTHENEXTBOSS_KHROGO = "King Khrogo",
	SI_ICTHENEXTBOSS_MALYGDA = "Lady Malygda",
	SI_ICTHENEXTBOSS_MAZALUHAD = "Mazaluhad",
	SI_ICTHENEXTBOSS_NUNATAK = "Nunatak",
	SI_ICTHENEXTBOSS_MATRON = "The Screeching Matron",
	SI_ICTHENEXTBOSS_VOLGHASS = "Volghass",
	SI_ICTHENEXTBOSS_YSENDA = "Ysenda Resplendent",
	SI_ICTHENEXTBOSS_ZOAL = "Zoal the Ever-Wakeful",
	SI_ICTHENEXTBOSS_MOLAG = "Simulacrum of Molag Bal",

	-- DISTRICTS
	SI_ICTHENEXTBOSS_NOBLESDISTRICT = "5-Nobles District",
	SI_ICTHENEXTBOSS_ARENADISTRICT = "2-Arena District",
	SI_ICTHENEXTBOSS_TEMPLEDISTRICT = "4-Temple District",
	SI_ICTHENEXTBOSS_ARBORETUMDISTRICT = "3-Arboretum District",
	SI_ICTHENEXTBOSS_MEMORIALDISTRICT = "1-Memorial District",
	SI_ICTHENEXTBOSS_ELVENGARDENSDISTRICT = "6-Elven Gardens District",
	SI_ICTHENEXTBOSS_CAN = "0-Imperial Sewers",
	
	
	SI_BINDING_NAME_SI_ICTHENEXTBOSS_NOBLESDISTRICT = "5-Nobles District",
	SI_BINDING_NAME_SI_ICTHENEXTBOSS_ARENADISTRICT = "2-Arena District",
	SI_BINDING_NAME_SI_ICTHENEXTBOSS_TEMPLEDISTRICT = "4-Temple District",
	SI_BINDING_NAME_SI_ICTHENEXTBOSS_ARBORETUMDISTRICT = "3-Arboretum District",
	SI_BINDING_NAME_SI_ICTHENEXTBOSS_MEMORIALDISTRICT = "1-Memorial District",
	SI_BINDING_NAME_SI_ICTHENEXTBOSS_ELVENGARDENSDISTRICT = "6-Elven Gardens District",
	SI_BINDING_NAME_SI_ICTHENEXTBOSS_CAN = "0-Imperial Sewers",

	-- GUI
	SI_ICTHENEXTBOSS_GUI_WIDTH = "230",
	SI_ICTHENEXTBOSS_OPTION_DESCRIPTION = "Tracks spawn times of bosses in Imperial City.",
	SI_ICTHENEXTBOSS_OPTION_TIMETABLE = "Table with spawntimes",
	SI_ICTHENEXTBOSS_OPTION_MAPTIMERS = "Spawntimes on IC map",
	SI_ICTHENEXTBOSS_OPTION_MAPTIMERS_TOOLTIP = "This will disable zoom on Imperial City map.\nDoes not work with Gamepad-Mode!",
	SI_ICTHENEXTBOSS_OPTION_EVENT_TIMERS = "Event timers (7 minutes)",
	SI_ICTHENEXTBOSS_OPTION_OPACITY = "Opacity (cursor away)",
	SI_ICTHENEXTBOSS_OPTION_OPACITY_TOOLTIP = "Box transparency when the mouse is not over it. Fully opaque on hover.",
	SI_ICTHENEXTBOSS_OPTION_HIDE_COMBAT = "Hide in combat",
	SI_ICTHENEXTBOSS_OPTION_HIDE_MOVING = "Hide while moving",
	SI_ICTHENEXTBOSS_OPTION_REDUCED = "Reduced display (next district only)",
	SI_ICTHENEXTBOSS_OPTION_REDUCED_TOOLTIP = "Shrinks the HUD box to show only the next district to hit.",
	SI_ICTHENEXTBOSS_OPTION_DEBUG = "Debug",
	SI_ICTHENEXTBOSS_NO_TIMERS = "No timers",
}

for id, value in pairs(strings) do
	ZO_CreateStringId(id, value)
	SafeAddVersion(id, 1)
end