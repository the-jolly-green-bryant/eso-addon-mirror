local SRC = SupportRotationCallouts
SRC.EffectEvents = SRC.EffectEvents or {}
local Events = SRC.EffectEvents

function Events:Initialize()
    self.listeners = self.listeners or {}
end

function Events:Register(key, listener)
    self:Initialize()
    key = SRC.EffectUtilities:NormalizeKey(key)
    if not key or not listener then return end
    self.listeners[key] = self.listeners[key] or {}
    self.listeners[key][listener] = true
end

function Events:Unregister(key, listener)
    self:Initialize()
    key = SRC.EffectUtilities:NormalizeKey(key)
    if key and self.listeners[key] then self.listeners[key][listener] = nil end
end

function Events:Publish(key, payload)
    self:Initialize()
    key = SRC.EffectUtilities:NormalizeKey(key)
    local listeners = key and self.listeners[key] or nil
    if not listeners then return end
    for listener in pairs(listeners) do
        if type(listener) == "function" then
            listener(payload)
        elseif listener.OnSupportEffectEvent then
            listener:OnSupportEffectEvent(payload)
        end
    end
end
