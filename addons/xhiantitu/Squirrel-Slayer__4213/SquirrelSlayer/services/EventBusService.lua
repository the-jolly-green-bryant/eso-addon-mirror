local addon = SquirrelSlayer
addon.Services.Events = addon.Services.Events or {}

local Events = addon.Services.Events

Events.Channels = Events.Channels or {
    SPOTS_UPDATED = "SQUIRREL_SLAYER_SPOTS_UPDATED",
}

--- Publie un message sur le bus interne.
--- @param eventName string
--- @param payload table|nil
function Events.Emit(eventName, payload)
    if not (eventName and CALLBACK_MANAGER and CALLBACK_MANAGER.FireCallbacks) then return end
    CALLBACK_MANAGER:FireCallbacks(eventName, payload)
end

--- S'abonne à un message du bus interne.
--- @param eventName string
--- @param callback function
function Events.On(eventName, callback)
    if not (eventName and callback and CALLBACK_MANAGER and CALLBACK_MANAGER.RegisterCallback) then return end
    CALLBACK_MANAGER:RegisterCallback(eventName, callback)
end

--- Se désabonne d'un message du bus interne.
--- @param eventName string
--- @param callback function
function Events.Off(eventName, callback)
    if not (eventName and callback and CALLBACK_MANAGER and CALLBACK_MANAGER.UnregisterCallback) then return end
    CALLBACK_MANAGER:UnregisterCallback(eventName, callback)
end
