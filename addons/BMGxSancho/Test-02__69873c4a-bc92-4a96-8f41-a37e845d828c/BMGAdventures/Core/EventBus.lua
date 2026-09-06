local BA = BMGAdventures
BA.EventBus = BA.EventBus or { listeners = {} }

function BA.EventBus:Subscribe(eventType, callback)
    if type(callback) ~= "function" then return end
    self.listeners[eventType] = self.listeners[eventType] or {}
    table.insert(self.listeners[eventType], callback)
end

function BA.EventBus:Publish(eventType, payload)
    local list = self.listeners[eventType]
    if not list then return end
    for i = 1, #list do
        local ok, err = pcall(list[i], payload)
        if not ok and BA.Diagnostics then
            BA.Diagnostics:Record("EVENTBUS_ERROR", tostring(err))
        end
    end
end
