-- ENGLISH LANGUAGE LOCALIZATION

-- GUI message

-- When we know dragon repop time
-- %d : Number of hour/minute/second before repop
-- %s : Time unit (see "GUI Timer" translations)
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_GUI_REPOP",  ": Repop in ~%d %s")

-- When we don't know repop time, we display killed since...
-- %s : Dragon status (flying/waiting/in fight/...)
-- %d : Number of hour/minute/second since the kill
-- %s : Time unit (see "GUI Timer" translations)
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_GUI_STATUS", ": %s since %d %s")

-- When we don't since how long a dragon has a status
-- %s : Dragon status (flying/waiting/in fight/...)
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_GUI_SIMPLE", ": %s")

-- GUI Timer

-- Times unit
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_TIMER_SECOND", "sec")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_TIMER_MINUTE", "min")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_TIMER_HOUR",   "h")


-- Bindings
ZO_CreateStringId("SI_BINDING_NAME_WORLD_EVENTS_TRACKER_TOGGLE", "Show/Hide")


-- Settings
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_SETTINGS_LOCK_UI", "Lock UI")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_SETTINGS_DISPLAY_WITH_WM", "Displayed with the map")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_SETTINGS_POSITION_TYPE", "Position type")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_SETTINGS_POSITION_TYPE_TOOLTIP", "Work only in Northern Elsweyr. Quests in Southern Elsweyr use cardinal points.")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_SETTINGS_POSITION_TYPE_CHOICE_LN", "Location name")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_SETTINGS_POSITION_TYPE_CHOICE_CP", "Cardinal point")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_SETTINGS_TRACK_HEAD", "What to track")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_SETTINGS_TRACK_DESC", "Choose what world event you want to track")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_SETTINGS_TRACK_DOLMEN", "Dolmen")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_SETTINGS_TRACK_GEYSER", "Geyser")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_SETTINGS_TRACK_DRAGON", "Dragon")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_SETTINGS_TRACK_HARROWSTORM", "Harrowstorm")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_SETTINGS_TRACK_VOLCANICVENT", "Volcanic Vent")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_SETTINGS_TRACK_MIRRORMOOR", "Mirrormoor")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_SETTINGS_TRACK_WRITHING", "Siege camps (Writhing Wall battle)")
