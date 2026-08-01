-- Register with LibStub
local MAJOR, MINOR = "Up_ProvidersController", 2
local LIB, _ = LibStub:NewLibrary(MAJOR, MINOR)
if not LIB then return end -- avoid double loading.

--- Controller of providers. Colelcts them for future usage.

--- Creates an base for providers controller.
-- You can operate with registered providers with such way:
-- controller.List[sourceId]:getText(self)
--
function LIB:new()
    local instance = { Size = 0, List = {}, OrderedList = {} }
    self.__index = self
    return setmetatable(instance, self)
end

--- Adds an provider to controller and maps it with source ID.
-- @param sourceId unique indentifier of source.
-- @param provider data provider instance.
--
function LIB:registerProvider(sourceId, provider)
    self.Size = self.Size + 1
    self.List[sourceId] = self.Size
    self.OrderedList[self.Size] = provider
end

--- Returns provider for specified source identifier, if its registered.
-- @param sourceId unique indentifier of source.
-- @return data provider instance or nil if there is no such provider.
--
function LIB:getProvider(sourceId)
    local index = self.List[sourceId]
    if index then
        return self.OrderedList[index]
    end
    return nil
end

--- Stops and removes all providers.
function LIB:clean()
    -- Stop all providers, if possible.
    for index, provider in pairs(self.OrderedList) do
        if provider and provider.stop then
           provider:stop()
        end
        self.OrderedList[index] = nil
    end
    self.List = {}
    self.OrderedList = {}
end
