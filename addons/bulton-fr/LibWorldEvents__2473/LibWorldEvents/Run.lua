EVENT_MANAGER:RegisterForEvent(LibWorldEvents.name, EVENT_ADD_ON_LOADED, LibWorldEvents.Events.onLoaded)
EVENT_MANAGER:RegisterForEvent(LibWorldEvents.name, EVENT_PLAYER_ACTIVATED, LibWorldEvents.Events.onLoadScreen)
EVENT_MANAGER:RegisterForEvent(LibWorldEvents.name, EVENT_WORLD_EVENT_ACTIVATED, LibWorldEvents.Events.onWEActivate)
EVENT_MANAGER:RegisterForEvent(LibWorldEvents.name, EVENT_WORLD_EVENT_DEACTIVATED, LibWorldEvents.Events.onWEDeactivate)
EVENT_MANAGER:RegisterForEvent(LibWorldEvents.name, EVENT_WORLD_EVENT_UNIT_CHANGED_PIN_TYPE, LibWorldEvents.Events.onWEUnitPin)
EVENT_MANAGER:RegisterForEvent(LibWorldEvents.name, EVENT_WORLD_EVENT_ACTIVE_LOCATION_CHANGED, LibWorldEvents.Events.onWELocChanged)
-- EVENT_MANAGER:RegisterForEvent(LibWorldEvents.name, EVENT_GAME_CAMERA_UI_MODE_CHANGED, LibWorldEvents.Events.onGuiChanged) -- Used to dump some data, so to debug only
