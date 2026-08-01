-- FRENCH LANGUAGE LOCALIZATION

-- GUI message

-- When we know dragon repop time
-- %d : Number of hour/minute/second before repop
-- %s : Time unit (see "GUI Timer" translations)
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_GUI_REPOP", ": Revient dans ~%d %s")

-- When we don't know repop time, we display killed since...
-- %s : Dragon status (flying/waiting/in fight/...)
-- %d : Number of hour/minute/second since the kill
-- %s : Time unit (see "GUI Timer" translations)
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_GUI_STATUS", ": %s depuis %d %s")

-- When we don't since how long a dragon has a status
-- %s : Dragon status (flying/waiting/in fight/...)
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_GUI_SIMPLE", ": %s")


-- GUI Timer

-- Times unit
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_TIMER_SECOND", "sec")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_TIMER_MINUTE", "min")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_TIMER_HOUR",   "h")


-- Bindings
ZO_CreateStringId("SI_BINDING_NAME_WORLD_EVENTS_TRACKER_TOGGLE", "Afficher/Masquer")


-- Settings
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_SETTINGS_LOCK_UI", "Verrouiller l'interface")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_SETTINGS_DISPLAY_WITH_WM", "Afficher avec la carte")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_SETTINGS_POSITION_TYPE", "Type de position")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_SETTINGS_POSITION_TYPE_TOOLTIP", "Ne fonctionne qu'au Nord d'Elsweyr. Les quêtes utilisent les points cardinaux à Elsweyr Sud.")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_SETTINGS_POSITION_TYPE_CHOICE_LN", "Nom du lieu")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_SETTINGS_POSITION_TYPE_CHOICE_CP", "Points cardinaux")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_SETTINGS_TRACK_HEAD", "Quoi suivre")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_SETTINGS_TRACK_DESC", "Choisissez le type d'évènement mondiaux que vous souhaitez suivre")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_SETTINGS_TRACK_DOLMEN", "Dolmen")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_SETTINGS_TRACK_GEYSER", "Geyser")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_SETTINGS_TRACK_DRAGON", "Dragon")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_SETTINGS_TRACK_HARROWSTORM", "Tempête faucheuse")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_SETTINGS_TRACK_VOLCANICVENT", "Jet volcanique")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_SETTINGS_TRACK_MIRRORMOOR", "Lande miroir")
ZO_CreateStringId("SI_WORLD_EVENTS_TRACKER_SETTINGS_TRACK_WRITHING", "Camps de siège (bataille du mur ondulant)")
