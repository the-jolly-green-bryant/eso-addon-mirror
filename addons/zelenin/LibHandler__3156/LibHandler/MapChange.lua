local class

class = ZO_InitializingObject:Subclass()
libHandlerMapChangeManager = class

function class:Initialize(owner)
    self.owner = owner
    self.name = string.format("%sMapChangeManager", self.owner.name)

    self.handlers = {}
    self.currentMapId = 0

    CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function(navigateIn)
        self:check()
    end)
end

function class:check()
    local mapId = GetCurrentMapId()

    if mapId == self.currentMapId then
        return
    end

    for _, handler in ipairs(self.handlers) do
        handler:Handle(self.currentMapId, mapId)
    end

    self.currentMapId = mapId
end

function class:AddHandler(mapId, enterHandler, exitHandler)
    local handler = libHandlerMapChangeHandler:New(mapId, enterHandler, exitHandler)
    table.insert(self.handlers, handler)
    handler:Handle(nil, self.currentMapId)
end

class = ZO_InitializingObject:Subclass()
libHandlerMapChangeHandler = class

function class:Initialize(mapId, enterHandler, exitHandler)
    self.mapId = mapId
    self.enterHandler = enterHandler
    self.exitHandler = exitHandler
end

function class:Handle(oldMapId, newMapId)
    if type(self.enterHandler) == "function" and (newMapId == self.mapId or self.mapId == nil) then
        self.enterHandler(oldMapId, newMapId)
    end

    if type(self.exitHandler) == "function" and (oldMapId == self.mapId or self.mapId == nil) then
        self.exitHandler(oldMapId, newMapId)
    end
end
