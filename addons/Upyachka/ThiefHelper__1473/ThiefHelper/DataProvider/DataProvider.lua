-- Used to provide displayable data.
--[[
    TODO
    Actually, such provider could contain logic for data calculation - better to avoid such behavior.
]] --
Up_DataProvider = {}

-- Intializes provider. Override this method to configure your own initialization.
function Up_DataProvider:initialize() end

-- Creates an base for data provider.
function Up_DataProvider:new(base)
    local instance = base or {}
    self.__index = self
    setmetatable(instance, self)
    instance:initialize()
    return instance
end

-- Override this method to provide your custom data. Must return any string for displaying. NOT nil.
function Up_DataProvider:getText(addon)
    d("Data provider has no logic to provide data")
end
