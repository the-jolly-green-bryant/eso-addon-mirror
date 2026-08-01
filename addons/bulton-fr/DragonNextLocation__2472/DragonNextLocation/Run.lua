EVENT_MANAGER:RegisterForEvent(DragonNextLocation.name, EVENT_ADD_ON_LOADED, DragonNextLocation.Events.onLoaded)
EVENT_MANAGER:RegisterForEvent(DragonNextLocation.name, EVENT_WORLD_EVENT_ACTIVE_LOCATION_CHANGED, DragonNextLocation.Events.onWELocChanged)

LibWorldEvents.Events.callbackManager:RegisterCallback(
    LibWorldEvents.Events.callbackEvents.dragon.new,
    DragonNextLocation.Events.onNewDragon
)
LibWorldEvents.Events.callbackManager:RegisterCallback(
    LibWorldEvents.Events.callbackEvents.dragon.landed,
    DragonNextLocation.Events.onDragonLanded
)
