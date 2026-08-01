Listener = {
    registerEvents = function(self, addonName)
        EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ZONE_CHANGED, Listener.dispatch)
        EVENT_MANAGER:RegisterForEvent(addonName, EVENT_LOOT_UPDATED, Listener.dispatch)
    end,

    dispatch = function()
        d(os.date("%d.%m.%Y %H:%M:%S"))
    end
}