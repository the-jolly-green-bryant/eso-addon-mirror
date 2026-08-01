local class

class = ZO_InitializingObject:Subclass()
libHandlerZoneChangeManager = class

function class:Initialize(owner)
    self.owner = owner
    self.name = string.format("%sZoneChangeManager", self.owner.name)

    self.handlers = {}
    self.currentZoneId = 0

    EVENT_MANAGER:RegisterForEvent(string.format("%s-%d", self.name, self.owner:getNextHandlerId()), EVENT_PLAYER_ACTIVATED, function(eventCode, initial)
        self:check()
    end)
end

function class:check()
    local zoneId, worldX, worldY, worldZ = GetUnitWorldPosition("player")

    if zoneId == self.currentZoneId then
        return
    end

    for _, handler in ipairs(self.handlers) do
        handler:Handle(self.currentZoneId, zoneId)
    end

    self.currentZoneId = zoneId
end

function class:AddHandler(zoneId, enterHandler, exitHandler)
    local handler = libHandlerZoneChangeHandler:New(zoneId, enterHandler, exitHandler)
    table.insert(self.handlers, handler)
    handler:Handle(nil, self.currentZoneId)
end

class = ZO_InitializingObject:Subclass()
libHandlerZoneChangeHandler = class

function class:Initialize(zoneId, enterHandler, exitHandler)
    self.zoneId = zoneId
    self.enterHandler = enterHandler
    self.exitHandler = exitHandler
end

function class:Handle(oldZoneId, newZoneId)
    if type(self.enterHandler) == "function" and (newZoneId == self.zoneId or self.zoneId == nil) then
        self.enterHandler(oldZoneId, newZoneId)
    end

    if type(self.exitHandler) == "function" and (oldZoneId == self.zoneId or self.zoneId == nil) then
        self.exitHandler(oldZoneId, newZoneId)
    end
end
