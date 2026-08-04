local C = Conductor
C.EventBus = C.EventBus or {}
local Bus = C.EventBus

Bus.listeners = Bus.listeners or {}
Bus.sequence = Bus.sequence or 0

function Bus:Subscribe(eventName, owner, callback)
    if type(eventName) ~= "string" or type(callback) ~= "function" then return false end
    self.listeners[eventName] = self.listeners[eventName] or {}
    self.sequence = self.sequence + 1
    self.listeners[eventName][self.sequence] = { owner = owner, callback = callback }
    return self.sequence
end

function Bus:Unsubscribe(eventName, token)
    local bucket = self.listeners[eventName]
    if not bucket then return false end
    bucket[token] = nil
    return true
end

function Bus:UnsubscribeOwner(owner)
    for _, bucket in pairs(self.listeners) do
        for token, listener in pairs(bucket) do
            if listener.owner == owner then bucket[token] = nil end
        end
    end
end

function Bus:Publish(eventName, payload)
    local bucket = self.listeners[eventName]
    if not bucket then return 0 end
    local callbacks = {}
    for token, listener in pairs(bucket) do
        callbacks[#callbacks + 1] = { token = token, listener = listener }
    end
    local delivered = 0
    for _, entry in ipairs(callbacks) do
        local listener = entry.listener
        if listener and listener.callback then
            local ok, err = pcall(listener.callback, payload, eventName)
            if ok then
                delivered = delivered + 1
            elseif C.Diagnostics and C.Diagnostics.AddFields then
                C.Diagnostics:AddFields("EVENT_BUS", "Listener error", { event = eventName, error = tostring(err) })
            end
        end
    end
    return delivered
end

function Bus:Initialize()
    self.initialized = true
end
