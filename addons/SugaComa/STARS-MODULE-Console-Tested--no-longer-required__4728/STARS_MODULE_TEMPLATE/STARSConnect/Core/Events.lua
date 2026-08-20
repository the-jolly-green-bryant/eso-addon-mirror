local Bootstrap = STARSModuleBootstrap
local Project = Bootstrap and Bootstrap.current
if not Project then error("STARSConnect: config.lua must load before Events.lua") end

Project.Events = Project.Events or {}
local Events = Project.Events

Events.registrations = Events.registrations or {}

local function RegistrationName(key)
    return string.format("%s_STARSConnect_%s", tostring(Project.Config.addonName), tostring(key))
end

function Events:Register(key, eventCode, callback)
    if key == nil or eventCode == nil or type(callback) ~= "function" then
        Project.Diagnostics:Warn("Rejected invalid event registration: " .. tostring(key))
        return false
    end

    local name = RegistrationName(key)
    EVENT_MANAGER:UnregisterForEvent(name, eventCode)
    EVENT_MANAGER:RegisterForEvent(name, eventCode, callback)

    self.registrations[key] = {
        name = name,
        eventCode = eventCode,
    }
    return true
end

function Events:Unregister(key)
    local registration = self.registrations[key]
    if not registration then return false end

    EVENT_MANAGER:UnregisterForEvent(registration.name, registration.eventCode)
    self.registrations[key] = nil
    return true
end

function Events:UnregisterAll()
    for key, registration in pairs(self.registrations) do
        EVENT_MANAGER:UnregisterForEvent(registration.name, registration.eventCode)
        self.registrations[key] = nil
    end
end
