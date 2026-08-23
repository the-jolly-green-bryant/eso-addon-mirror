SugasTestZoneProject = SugasTestZoneProject or {}
local Project = SugasTestZoneProject

Project.Events = Project.Events or {}
local Events = Project.Events

Events.registrations = Events.registrations or {}

function Events:Register(key, eventCode, callback)
    if not key or not eventCode or type(callback) ~= "function" then
        Project.Diagnostics:Warn("Rejected invalid event registration: " .. tostring(key))
        return false
    end

    local registrationName = Project.Config.hostAddonName .. "_Project_" .. tostring(key)
    EVENT_MANAGER:UnregisterForEvent(registrationName, eventCode)
    EVENT_MANAGER:RegisterForEvent(registrationName, eventCode, callback)

    self.registrations[key] = {
        name = registrationName,
        eventCode = eventCode,
    }
    return true
end

function Events:Unregister(key)
    local registration = self.registrations[key]
    if not registration then return end

    EVENT_MANAGER:UnregisterForEvent(registration.name, registration.eventCode)
    self.registrations[key] = nil
end

function Events:UnregisterAll()
    for key, registration in pairs(self.registrations) do
        EVENT_MANAGER:UnregisterForEvent(registration.name, registration.eventCode)
        self.registrations[key] = nil
    end
end
