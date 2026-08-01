local addonId = "LibHandler"
local class = ZO_InitializingObject:Subclass()

function class:Initialize(name)
    self.name = name
    self.addonData = self:getAddonData()

    self.currentHandlerId = 0

    self.mapChangeManager = libHandlerMapChangeManager:New(self)
    self.zoneChangeManager = libHandlerZoneChangeManager:New(self)
end

function class:Condition(condition, handler, timeOut)
    return libHandlerCondition:New(self, condition, handler, timeOut)
end

function class:ZoneChange(zoneId, enterHandler, exitHandler)
    self.zoneChangeManager:AddHandler(zoneId, enterHandler, exitHandler)
end

function class:MapChange(mapId, enterHandler, exitHandler)
    self.mapChangeManager:AddHandler(mapId, enterHandler, exitHandler)
end

function class:Limiter(handler, timeout, repeatable)
    return libHandlerLimiter:New(self, handler, timeout, repeatable)
end

function class:LimiterWithDependency(handler, timeout, repeatable)
    return libHandlerLimiterWithDependency:New(self, handler, timeout, repeatable)
end

function class:getAddonData()
    for index = 1, GetAddOnManager():GetNumAddOns() do
        local name, title, author, description, enabled, state, isOutOfDate, isLibrary = GetAddOnManager():GetAddOnInfo(index)
        if name == self.name then
            return {
                name = name,
                title = title,
                author = author,
                version = GetAddOnManager():GetAddOnVersion(index),
                directoryPath = GetAddOnManager():GetAddOnRootDirectoryPath(index)
            }
        end
    end

    return nil
end

function class:getNextHandlerId()
    self.currentHandlerId = self.currentHandlerId + 1
    return self.currentHandlerId
end

EVENT_MANAGER:RegisterForEvent(addonId, EVENT_ADD_ON_LOADED, function(eventCode, addonName)
    if addonName ~= addonId then
        return
    end
    assert(not _G[addonId], string.format("'%s' has already been loaded", addonId))
    _G[addonId] = class:New(addonId)
    EVENT_MANAGER:UnregisterForEvent(addonId, EVENT_ADD_ON_LOADED)
end)
