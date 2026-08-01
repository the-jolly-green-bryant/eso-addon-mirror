-- GERMAN LANGUAGE LOCALIZATION

-- GUI message

-- When we know dragon repop time
-- %d : Number of hour/minute/second before repop
-- %s : Time unit (see "GUI Timer" translations)
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_GUI_REPOP",  ": Erscheint in ~%d %s")

-- When we don't know repop time, we display killed since...
-- %s : Dragon status (flying/waiting/in fight/...)
-- %d : Number of hour/minute/second since the kill
-- %s : Time unit (see "GUI Timer" translations)
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_GUI_STATUS", ": %s seit %d %s")

-- When we don't since how long a dragon has a status
-- %s : Dragon status (flying/waiting/in fight/...)
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_GUI_SIMPLE", ": %s")

-- GUI Timer

-- Times unit
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_TIMER_SECOND", "Sek")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_TIMER_MINUTE", "Min")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_TIMER_HOUR",   "Std")


-- Bindings
ZO_CreateStringId("SI_BINDING_NAME_WORLD_EVENTS_TRACKER_TOGGLE", "Ein-/Ausblenden")
