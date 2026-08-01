-- Event Manager Module
-- Centralized event handling and management for NMGuildHall
-- Dependencies: Message (optional)
-- Provides safe event registration with error handling and owner tracking

local Addon = NMGuildHall

local EventManager = {
    registeredEvents = {},
    eventHandlers = {},
    ownerHandlers = {}, -- Track handlers by owner
    initialized = false,
    dispatchers = {}
}

-- Initialize the event manager
function EventManager:Initialize()
    if self.initialized then
        return
    end
    
    self.registeredEvents = {}
    self.eventHandlers = {}
    self.ownerHandlers = {}
    self.dispatchers = {}
    self.initialized = true
    
    if Addon and Addon.Message then
        Addon.Message:For("EventManager"):Debug(GetString(NMGH_DEBUG_EVENT_MANAGER_INIT))
    end
end

-- Register an event with error handling
function EventManager:RegisterEvent(eventName, handler, owner)
    if not eventName or not handler then
        if Addon and Addon.Message then
            Addon.Message:Error(GetString(NMGH_ERR_EVENT_INVALID_REG))
        end
        return false
    end
    
    if type(handler) ~= "function" then
        if Addon and Addon.Message then
            Addon.Message:Error(GetString(NMGH_ERR_EVENT_HANDLER_NOT_FUNC), {eventName = tostring(eventName)})
        end
        return false
    end
    
    local actualOwner = owner or "NMGuildHall"
    self.eventHandlers[eventName] = self.eventHandlers[eventName] or {}

    for _, entry in ipairs(self.eventHandlers[eventName]) do
        if entry.owner == actualOwner and entry.handler == handler then
            return true
        end
    end

    table.insert(self.eventHandlers[eventName], { owner = actualOwner, handler = handler })
    
    -- Track by owner
    if not self.ownerHandlers[actualOwner] then
        self.ownerHandlers[actualOwner] = {}
    end
    local alreadyTracked = false
    for _, ev in ipairs(self.ownerHandlers[actualOwner]) do
        if ev == eventName then
            alreadyTracked = true
            break
        end
    end
    if not alreadyTracked then
        table.insert(self.ownerHandlers[actualOwner], eventName)
    end
    
    -- Ensure a cached dispatcher exists for this event
    if not self.dispatchers[eventName] then
        local evName = eventName
        self.dispatchers[eventName] = function(...)
            local handlers = self.eventHandlers[evName]
            if not handlers then return end
            for _, entry in ipairs(handlers) do
                local ok, err = pcall(entry.handler, ...)
                if not ok then
                    if Addon and Addon.Message then
                        Addon.Message:For("EventManager"):Error(GetString(NMGH_ERR_EVENT_HANDLER_FAILED), {
                            eventName = tostring(evName),
                            error = tostring(err)
                        })
                    end
                end
            end
        end
    end
    
    local centralOwner = tostring(Addon and Addon.name or "NMGuildHall") .. "_EventManager"
    local success = true
    if not self.registeredEvents[eventName] then
        success = pcall(function()
            EVENT_MANAGER:RegisterForEvent(centralOwner, eventName, self.dispatchers[eventName])
        end)
    end
    
    if success then
        self.registeredEvents[eventName] = centralOwner
        if Addon and Addon.Message then
            Addon.Message:For("EventManager"):Debug(GetString(NMGH_DEBUG_EVENT_MANAGER_INIT), {
                eventName = tostring(eventName),
                owner = tostring(actualOwner)
            })
        end
        return true
    else
        -- Cleanup on failure
        local list = self.eventHandlers[eventName] or {}
        for i = #list, 1, -1 do
            if list[i].owner == actualOwner and list[i].handler == handler then
                table.remove(list, i)
                break
            	end
        end
        
        if Addon and Addon.Message then
            Addon.Message:Error(GetString(NMGH_ERR_EVENT_REG_FAILED), {eventName = tostring(eventName)})
        end
        return false
    end
end

-- Unregister a specific event
function EventManager:UnregisterEvent(eventName)
    if not eventName then
        return false
    end
    
    local centralOwner = self.registeredEvents[eventName]
    if not centralOwner then
        if Addon and Addon.Message then
            Addon.Message:Warn(GetString(NMGH_ERR_EVENT_NOT_FOUND), {eventName = tostring(eventName)})
        end
        return false
    end
    
    local success = pcall(function()
        EVENT_MANAGER:UnregisterForEvent(centralOwner, eventName)
    end)
    
    if success then
        -- Clean up tracking
        self.registeredEvents[eventName] = nil
        self.eventHandlers[eventName] = nil
        self.dispatchers[eventName] = nil
        
        for own, evs in pairs(self.ownerHandlers) do
            for i = #evs, 1, -1 do
                if evs[i] == eventName then
                    table.remove(evs, i)
                end
            end
            if #evs == 0 then
                self.ownerHandlers[own] = nil
            end
        end
        
        if Addon and Addon.Message then
            Addon.Message:For("EventManager"):Debug(GetString(NMGH_DEBUG_CLEANUP_DONE), {
                eventName = tostring(eventName),
                owner = tostring(centralOwner)
            })
        	end
        return true
    else
        if Addon and Addon.Message then
            Addon.Message:Warn(GetString(NMGH_ERR_EVENT_NOT_FOUND), {eventName = tostring(eventName)})
        end
        return false
    end
end

-- Unregister all events for a specific owner
function EventManager:UnregisterEventsByOwner(owner)
    if not owner or not self.ownerHandlers[owner] then
        return false
    end
    
    local eventsToProcess = {}
    for _, eventName in ipairs(self.ownerHandlers[owner]) do
        table.insert(eventsToProcess, eventName)
    end
    
    local unregisteredCount = 0
    for _, eventName in ipairs(eventsToProcess) do
        local list = self.eventHandlers[eventName]
        if list then
            for i = #list, 1, -1 do
                if list[i].owner == owner then
                    table.remove(list, i)
                end
            end
            if #list == 0 and self.registeredEvents[eventName] then
                if self:UnregisterEvent(eventName) then
                    unregisteredCount = unregisteredCount + 1
                end
            end
        end
    end
    
    if Addon and Addon.Message then
        Addon.Message:For("EventManager"):Debug(GetString(NMGH_DEBUG_CLEANUP_DONE), {
            count = unregisteredCount,
            owner = tostring(owner)
        })
    end
    
    return unregisteredCount > 0
end

-- Unregister all events (cleanup)
function EventManager:UnregisterAllEvents()
    for eventName, _ in pairs(self.registeredEvents) do
        self:UnregisterEvent(eventName)
    end
    
    -- Clear all tracking
    self.ownerHandlers = {}
    self.dispatchers = {}
    
    if Addon and Addon.Message then
        Addon.Message:For("EventManager"):Debug(GetString(NMGH_DEBUG_CLEANUP_DONE))
    end
end

-- Get list of registered events
function EventManager:GetRegisteredEvents()
    local events = {}
    for eventName, _ in pairs(self.registeredEvents) do
        table.insert(events, eventName)
    end
    return events
end

-- Check if an event is registered
function EventManager:IsEventRegistered(eventName)
    return self.registeredEvents[eventName] ~= nil
end

-- Register multiple events at once
function EventManager:RegisterMultipleEvents(eventTable, owner)
    local successCount = 0
    local totalCount = 0
    
    for eventName, handler in pairs(eventTable) do
        totalCount = totalCount + 1
        if self:RegisterEvent(eventName, handler, owner) then
            successCount = successCount + 1
        end
    end
    
    if Addon and Addon.Message then
        Addon.Message:For("EventManager"):Debug(GetString(NMGH_DEBUG_MODULES_INIT), {
            success = successCount,
            total = totalCount
        })
    end
    return successCount == totalCount
end

-- Export event manager
NMGuildHall = NMGuildHall or {}
NMGuildHall.EventManager = EventManager

return EventManager
